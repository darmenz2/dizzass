#!/usr/bin/env python3
"""e249c C/unchanged-ARM comparison. No firmware process or device I/O.
Two scopes: scripted solver output, then actual ff288 instructions versus the
already recovered legacy C solver. Only the latter claims solver composition.
"""
import argparse, collections, ctypes as C, hashlib, itertools, json, math, random, struct, sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'tools'))
from elf32 import ELF32
from arm32_vfp_subset import ARM32VFP
from arm32_subset import MASK, signed
from bm1368_control_oracle import ControlOracle
START,END,DEVICE,LIMITS=0xe249c,0xe27c0,0x840000,0x5eb6c0
HASH='b2663b3aa753cc14ae9d3b11a14d3d93c74b605a3e433b02101c3c17c69d95e9'
I,U,D,P=C.c_int32,C.c_uint32,C.c_double,C.c_void_p
class Limits(C.Structure):
    _fields_=[(n,D) for n in ('reference','maximum','threshold','minimum')]+[(n,I) for n in ('ref','feedback','post','reserved')]+[('error',D)]
class Result(C.Structure):
    _fields_=[('vco',D)]+[(n,I) for n in ('ref','feedback','post1','post2','written','reserved')]
class Device(C.Structure):_fields_=[('index',U)]
SOLVE=C.CFUNCTYPE(I,P,C.POINTER(Limits),D,C.POINTER(Result))
WRITE=C.CFUNCTYPE(I,P,C.POINTER(Device),U,P,U,U)
LOG=C.CFUNCTYPE(None,P,U,U,D)
class Ops(C.Structure):_fields_=[('solve',SOLVE),('write',WRITE),('log',LOG)]
def bits(f):return struct.pack('<d',f).hex()
def sample_result(p):
    return Result(p.get('vco',2400.),*(signed(v&MASK) for v in p.get('divisors',(2,192,4,1))),1,0)
def pick(p,key,n,default=0):
    v=p.get(key,default);return v[min(n,len(v)-1)] if isinstance(v,list) else v
class Script:
    def __init__(self,p,get_index,set_index):
        self.p=p;self.get_index=get_index;self.set_index=set_index;self.events=[];self.counts=collections.Counter()
    def call(self,name,*args):
        n=self.counts[name];self.counts[name]+=1
        self.events.append((name,*args,self.get_index()))
        for at,occurrence,value in self.p.get('mutations',[]):
            if (at,occurrence)==(name,n):self.set_index(value&MASK)
        return pick(self.p,name,n)
class Machine(ARM32VFP):
    def extra_instruction(self,w,pc):
        assert START<=pc<END or 0xff288<=pc<0xff630,('unreviewed pc',hex(pc))
        self.visited.add(pc);return super().extra_instruction(w,pc)
    def read(self,a,n=4):
        if getattr(self,'poison',None):
            lo,hi=self.poison
            assert a+n<=lo or a>=hi,'failed solver output was read'
        return super().read(a,n)
class Original:
    def __init__(self,elf):
        self.elf=elf;self.m=Machine(elf);self.steps=0;self.visited=set();self.solver_logs=0
    def run(self,p):
        m=self.m;m.poison=None;m.visited=set();m.mem[DEVICE:DEVICE+64]=b'\xa5'*64
        m.write(DEVICE+0x18,p.get('index',2));before=bytes(m.mem[DEVICE:DEVICE+64])
        # Same original opaque words in wrapper and nested solver; they do not
        # justify new duplicate writes. Their low-bit predicates still execute.
        for lit,pc in ((0xe27f4,0xe251c),(0xe27f8,0xe2524),(0xe27d4,0xe258c),
                       (0xe27d8,0xe25a0),(0xe27dc,0xe26dc),(0xe27e0,0xe26f0),
                       (0xff648,0xff2d4),(0xff64c,0xff2f8)):
            target=m.read((pc+8+m.read(lit))&MASK);m.write(target,p.get('opaque',MASK))
        sc=Script(p,lambda:m.read(DEVICE+0x18),lambda v:m.write(DEVICE+0x18,v))
        def solve(mm):
            assert mm.r[0]==LIMITS and mm.d(0)==p.get('frequency',600.75)
            sc.call('solve',bits(mm.d(0)),self.elf.read(LIMITS,56).hex())
            out=mm.r[1];rc=pick(p,'solve',0)
            if rc:m.poison=(out,out+32)
            else:mm.mem[out:out+32]=bytes(sample_result(p))
            mm.r[0]=rc&MASK
        def write(mm):
            assert mm.r[:4]==[DEVICE,1,0,8]
            mm.r[0]=sc.call('write',mm.r[1],mm.r[2],mm.r[3],mm.read(mm.r[13]))&MASK
        def log(mm):
            # Old computational solver omits its internal failure diagnostic.
            # Account for that exclusion, never conflate it with wrapper logs.
            if mm.r[3]==73 and p.get('nested'):
                self.solver_logs+=1;mm.r[0]=0;return
            line=mm.r[3];sp=mm.r[13]
            assert line in (966,972) and mm.r[:3]==[0x5eb3e0,0x5eb3e7,0x5eb411]
            assert mm.read(sp)==1 and mm.read(sp+4)==(0x5eb6f8 if line==966 else 0x5eb729)
            if line==972:assert mm.read(sp+12)==0
            f=struct.unpack('<d',mm.read(sp+16,8).to_bytes(8,'little'))[0]
            if not p.get('nolog'):sc.call('log',line,mm.read(sp+8),bits(f))
            mm.r[0]=0xabcdef
        hooks={0xe4a74:write,0xfa0c4:log}
        if not p.get('nested'):hooks[0xff288]=solve
        results=[]
        for _ in range(p.get('repeat',1)):
            m.poison=None;m.reset((DEVICE,));m.set_d(0,p.get('frequency',600.75))
            m.set_d(8,17.125);m.set_d(9,23.625)
            results.append(signed(m.run(START,hooks=hooks,max_steps=60000)))
            assert m.r[13]==m.STACK_TOP and m.d(8)==17.125 and m.d(9)==23.625
            self.steps+=m.steps;self.visited|=m.visited
        m.poison=None;after=bytearray(m.mem[DEVICE:DEVICE+64]);after[24:28]=before[24:28]
        assert bytes(after)==before,'unexpected device write'
        return results,m.read(DEVICE+24),sc.events
class Native:
    def __init__(self,lib):
        self.lib=lib;self.f=lib.vn135_bm1368_set_frequency_135
        self.f.argtypes=[C.POINTER(Device),D,C.POINTER(Ops),P];self.f.restype=I
        self.solve=lib.vn135_bm1368_frequency_solve_135
        self.solve.argtypes=[P,C.POINTER(Limits),D,C.POINTER(Result)];self.solve.restype=I
    def run(self,p):
        dev=Device(p.get('index',2));sc=Script(p,lambda:dev.index,lambda v:setattr(dev,'index',v));errors=[]
        expected=bytes(Limits.in_dll(self.lib,'vn135_bm1368_frequency_limits_135'))
        def guard(ty,fn):
            def cb(*a):
                try:return fn(*a)
                except BaseException as e:errors.append(e);return None if ty==LOG else -999
            return ty(cb)
        def solve(_,limits,f,out):
            assert bytes(limits.contents)==expected
            if p.get('nested'):return self.solve(None,limits,f,out)
            rc=sc.call('solve',bits(f),bytes(limits.contents).hex())
            if not rc:C.memmove(out,C.byref(sample_result(p)),C.sizeof(Result))
            # Intentionally do not initialize out when solve fails.
            return rc
        def write(_,device,broadcast,chip,reg,word):
            assert C.addressof(device.contents)==C.addressof(dev)
            return sc.call('write',broadcast,chip or 0,reg,word)
        callbacks=(guard(SOLVE,solve),guard(WRITE,write),LOG() if p.get('nolog') else guard(LOG,lambda _,l,i,f:sc.call('log',l,i,bits(f))))
        ops=Ops(*callbacks);results=[self.f(C.byref(dev),p.get('frequency',600.75),C.byref(ops),None) for _ in range(p.get('repeat',1))]
        if errors:raise errors[0]
        return results,dev.index,sc.events

def cases(quick=False):
    for vco in (1999.9,2000.,2399.999,2400.,3200.,3200.001):
        for rc1,rc2 in ((0,0),(-7,0),(0,-9),(-7,-9)):
            yield dict(vco=vco,write=[rc1,rc2])
    for rc in (-1,1,-99):yield dict(solve=rc)
    for values in ((0,0,0,0),(2,192,4,1),(63,4095,8,8),(64,4096,9,0),(MASK,)*4):
        yield dict(divisors=values)
    yield dict(write=[-2,-3],mutations=[('solve',0,5),('write',0,10),('write',1,MASK)])
    if quick:return
    for edge in (2000.,2400.,3200.):
        for direction in (-math.inf,math.inf):yield dict(vco=math.nextafter(edge,direction))
    for slot in range(4):
        for word in list(range(17))+[31,63,64,255,4095,4096,0x7fffffff,0x80000000,MASK]:
            div=[2,192,4,1];div[slot]=word;yield dict(divisors=div)
    for step in ('solve','write','log'):
        for n in (0,1):
            for idx in (0,1,0x7fffffff,MASK):
                for error in (0,1,2):
                    yield dict(solve=-1 if error==1 else 0,write=[-1,-1] if error==2 else [0,0],mutations=[(step,n,idx)],repeat=2)
    rng=random.Random(0xe249c)
    for _ in range(160):
        yield dict(divisors=[rng.getrandbits(32) for _ in range(4)],vco=rng.uniform(1950,3250),
                   frequency=rng.uniform(0,5000),write=[rng.choice([0,-1,7]),rng.choice([0,-1,7])],
                   index=rng.getrandbits(32),opaque=rng.getrandbits(32),nolog=rng.choice([False,True]))

def nested_cases(quick=False):
    freqs=[0.,1.,50.,400.,449.9,450.,600.75,625.,800.,2399.,2400.,3125.,3200.,3201.,1e9]
    if not quick:freqs+=list(map(float,range(100,1501,25)))+[math.nextafter(600.,0.),math.nextafter(600.,math.inf)]
    for f in freqs:
        for writes in ((0,0),(-1,0),(0,-1),(-1,-1)):
            yield dict(nested=True,frequency=f,write=list(writes))

def packets(lib,words):
    encode=lib.dizzass_bm1368_command_encode
    encode.argtypes=[I,U,U,U,U,C.POINTER(C.c_uint8),C.c_size_t,C.POINTER(C.c_size_t)];encode.restype=I
    oracle=ControlOracle();count=0
    for word in sorted(set(words)):
        m=oracle.m;m.reset((DEVICE,1,0,8,word));m.write(DEVICE+0x18,2)
        m.run(0xe4a74,stop=0xe4b04,max_steps=10000)
        ptr,n=m.r[1:3];assert n==9
        original=b'\x55\xaa'+bytes(m.mem[ptr:ptr+n])
        out=(C.c_uint8*11)();written=C.c_size_t()
        assert encode(3,1,0,8,word,out,11,C.byref(written))==0 and written.value==11
        assert bytes(out)==original,(hex(word),bytes(out).hex(),original.hex());count+=1
    return count

def main():
    ap=argparse.ArgumentParser();ap.add_argument('library');ap.add_argument('--summary');ap.add_argument('--quick',action='store_true');args=ap.parse_args()
    elf=ELF32(ROOT/'reference/cgminer.vendor.elf');assert hashlib.sha256(elf.data).hexdigest()==HASH
    lib=C.CDLL(str(Path(args.library).resolve()));old=Original(elf);new=Native(lib)
    assert bytes(Limits.in_dll(lib,'vn135_bm1368_frequency_limits_135'))==elf.read(LIMITS,56)
    totals=collections.Counter();words=set()
    for group,inputs in (('scripted',cases(args.quick)),('nested_solver',nested_cases(args.quick))):
        for n,p in enumerate(inputs):
            want=old.run(p);got=new.run(p)
            assert want==got,('SEMANTIC_MISMATCH',group,n,p,want,got)
            totals[group+'_cases']+=1;totals[group+'_events']+=len(want[2])
            words.update(e[4] for e in want[2] if e[0]=='write')
    totals['packet_comparisons']=packets(lib,words)
    totals.update({'original_steps':old.steps,'visited_instructions':len(old.visited),'excluded_solver_diagnostics':old.solver_logs})
    print('BM1368_FREQUENCY135_ORIGINAL_PASS',json.dumps(dict(totals),sort_keys=True))
    if args.summary:Path(args.summary).write_text(json.dumps(dict(totals),indent=2)+'\n')
if __name__=='__main__':main()
