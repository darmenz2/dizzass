#!/usr/bin/env python3
"""C vs bounded original instructions; a script controls external effects only."""
import argparse, collections, ctypes as C, itertools, json, random
from pathlib import Path
from gpio_power_135_oracle import Oracle, REF_SHA
I=C.c_int32;U=C.c_uint32;V=C.c_void_p;H=C.c_size_t;B8=C.c_uint8
P8=C.POINTER(B8);PU=C.POINTER(U)
CB0=C.CFUNCTYPE(I,V); OPEN=C.CFUNCTYPE(H,V,C.c_char_p,C.c_char_p)
NUM=C.CFUNCTYPE(I,V,H,C.c_char_p,U); TEXT=C.CFUNCTYPE(I,V,C.c_char_p,H)
CLOSE=C.CFUNCTYPE(I,V,H); ACCESS=C.CFUNCTYPE(I,V,C.c_char_p,I)
SCAN=C.CFUNCTYPE(I,V,H,P8); UINTSCAN=C.CFUNCTYPE(I,V,C.c_char_p,PU)
PERROR=C.CFUNCTYPE(None,V,C.c_char_p); LOG=C.CFUNCTYPE(None,V,I,U,U)
SET=C.CFUNCTYPE(I,V,C.c_uint16); RESET=C.CFUNCTYPE(I,V,U)
class Gops(C.Structure):
    _fields_=[('lock',CB0),('unlock',CB0),('open',OPEN),('number',NUM),('text',TEXT),
      ('close',CLOSE),('access',ACCESS),('scan',SCAN),('uintscan',UINTSCAN),('perror',PERROR),('log',LOG)]
class Gio(C.Structure):_fields_=[('ops',C.POINTER(Gops)),('opaque',V)]
class State(C.Structure):_fields_=[('byte_ff1',B8),('word_20c',U)]
class Pops(C.Structure):
    _fields_=[('on',CB0),('off',CB0),('set',SET),('count',CB0),('reset',RESET),('log',LOG)]
class Script:
    def __init__(self,overrides=None,scan_byte=ord('1'),scan_write=True,uint_value=987,uint_write=True):
        self.overrides=overrides or {};self.events=[];self.seen=collections.Counter()
        self.scan_byte=scan_byte;self.scan_write=scan_write
        self.uint_value=uint_value;self.uint_write=uint_write;self.snapshot=lambda:None
    def call(self,name,args=()):
        self.seen[name]+=1
        defaults={'open':0x842000,'number':1,'text':1,'scan_char':1,'scan_uint':1,'chain_count':3}
        value=self.overrides.get((name,self.seen[name]),self.overrides.get(name,defaults.get(name,0)))
        self.events.append((name,args,self.snapshot()))
        return value
    def fresh(self):
        return Script(self.overrides,self.scan_byte,self.scan_write,self.uint_value,self.uint_write)
class Native:
    def __init__(self,path):
        self.lib=C.CDLL(str(Path(path).resolve()))
        for name in ['export_direction','set_value','set_direction']:
            f=getattr(self.lib,'vn135_gpio_'+name+'_135');f.argtypes=[C.POINTER(Gio),U,U];f.restype=I
        for name in ['is_exported','unexport']:
            f=getattr(self.lib,'vn135_gpio_'+name+'_135');f.argtypes=[C.POINTER(Gio),U];f.restype=I
        self.lib.vn135_gpio_get_value_135.argtypes=[C.POINTER(Gio),U,P8,PU]
        for name in ['on','off']:
            f=getattr(self.lib,'vn135_aml_psu_'+name+'_135');f.argtypes=[C.POINTER(Gio),B8];f.restype=I
        self.lib.vn135_backend_power_start_135.argtypes=[C.POINTER(State),C.POINTER(Pops),V,U]
        self.lib.vn135_backend_power_stop_135.argtypes=[C.POINTER(State),C.POINTER(Pops),V]
        self.lib.vn135_power_caller_value_135.argtypes=[U,U,B8,U];self.lib.vn135_power_caller_value_135.restype=U
    def run(self,entry,script,pin=437,arg=1,ready=1,old=(0x92,0x12345678),seed=0x48):
        state=State(*old);out=U(0xdeadbeef);scratch=B8(seed)
        script.snapshot=lambda:(state.byte_ff1,state.word_20c,out.value)
        errors=[]
        def cb(ctype,fn):
            def safe(*a):
                try:return fn(*a)
                except BaseException as e:errors.append(e);return 0
            return ctype(safe)
        def scan(_,h,p):
            rc=script.call('scan_char',(h,p[0]))
            if script.scan_write:p[0]=script.scan_byte
            return rc
        def scanuint(_,text,p):
            rc=script.call('scan_uint',(text,))
            if script.uint_write:p[0]=script.uint_value
            return rc
        go=Gops(cb(CB0,lambda _:script.call('lock')),cb(CB0,lambda _:script.call('unlock')),
          cb(OPEN,lambda _,p,m:script.call('open',(p,m))),
          cb(NUM,lambda _,h,f,v:script.call('number',(h,f,v))),
          cb(TEXT,lambda _,t,h:script.call('text',(t,h))),cb(CLOSE,lambda _,h:script.call('close',(h,))),
          cb(ACCESS,lambda _,p,m:script.call('access',(p,m))),cb(SCAN,scan),cb(UINTSCAN,scanuint),
          cb(PERROR,lambda _,t:script.call('perror',(t,))),cb(LOG,lambda _,s,l,a:script.call('log',(s,l,a))))
        g=Gio(C.pointer(go),None)
        def voltage(_,v):
            rc=script.call('set_voltage',(v,))
            return script.setter(v) if hasattr(script,'setter') else rc
        po=Pops(cb(CB0,lambda _:self.lib.vn135_aml_psu_on_135(C.byref(g),ready)),
          cb(CB0,lambda _:self.lib.vn135_aml_psu_off_135(C.byref(g),ready)),
          cb(SET,voltage),cb(CB0,lambda _:script.call('chain_count')),
          cb(RESET,lambda _,i:script.call('reset_chain',(i,))),go.log)
        fn={'export':'export_direction','probe':'is_exported','set':'set_value','get':'get_value',
            'direction':'set_direction','unexport':'unexport'}
        if entry in ['start','stop']:
            f=getattr(self.lib,'vn135_backend_power_'+entry+'_135')
            args=[C.byref(state),C.byref(po),None]+([arg] if entry=='start' else [])
        elif entry in ['aml_on','aml_off']:
            f=getattr(self.lib,'vn135_aml_psu_'+entry[4:]+'_135');args=[C.byref(g),ready]
        else:
            f=getattr(self.lib,'vn135_gpio_'+fn[entry]+'_135');args=[C.byref(g),pin]
            if entry=='get':args += [C.byref(scratch),C.byref(out)]
            elif entry not in ['probe','unexport']:args += [arg]
        rc=f(*args)
        if errors:raise errors[0]
        return rc,script.snapshot(),script.events

def main():
    ap=argparse.ArgumentParser();ap.add_argument('library');ap.add_argument('--summary');ap.add_argument('--smoke',action='store_true');a=ap.parse_args()
    native=Native(a.library);original=Oracle();counts=collections.Counter();events=0
    def compare(entry,script=None,**kw):
        nonlocal events
        script=script or Script()
        x=original.run(entry,script.fresh(),**kw);y=native.run(entry,script.fresh(),**kw)
        if x!=y:
            print('FAIL',entry,kw,script.overrides,'original=',x,'native=',y)
            raise AssertionError('differential mismatch')
        counts[entry]+=1;events+=len(x[2])
    for entry in ['export','probe','set','get','direction','unexport','aml_on','aml_off','start','stop']:
        compare(entry);compare(entry,Script({('open',1):0}))
    if not a.smoke:
        pins=[0,1,437,476,477,0x7fffffff,0x80000000,0xffffffff]
        vals=[0,1,2,255,65535,65536,0x7fffffff,0x80000000,0xffffffff]
        for entry in ['export','set','direction']:
            for pin,arg in itertools.product(pins,vals):
                compare(entry,pin=pin,arg=arg)
                for fail in [('open',1),('number',1),('text',1),('close',1),('lock',1),('unlock',1),('open',2),('close',2)]:
                    compare(entry,Script({fail:0 if fail[0]=='open' else -1}),pin=pin,arg=arg)
        for pin in pins:
            for r in [0,-1,-2,1,0x7fffffff,-2147483648]:compare('probe',Script({'access':r}),pin=pin)
            for name in ['lock','open','number','close','unlock']:
                compare('unexport',Script({name:0 if name=='open' else -1}),pin=pin)
        for byte in range(256):
            compare('get',Script(scan_byte=byte),seed=255-byte)
            compare('get',Script({'scan_char':-1},scan_write=False),seed=byte)
            compare('get',Script({'scan_uint':0,'close':-1},scan_byte=byte,uint_write=False),seed=0)
        for ready in range(256):
            for entry in ['aml_on','aml_off']:
                compare(entry,ready=ready)
                compare(entry,Script({'open':0}),ready=ready)
        for old,ready,v,rc in itertools.product([(0,0),(1,0xdeadbeef),(255,0xffffffff)],
                                                [0,1,2],vals,[0,-1,-2,1]):
            compare('start',Script({'set_voltage':rc}),ready=ready,arg=v,old=old)
        for old,ready,count,failed in itertools.product([(0,0),(1,42),(255,0xffffffff)],
                         [0,1,2],[-2,-1,0,1,3,8],['none','open','number','close','reset_chain']):
            compare('stop',Script({'chain_count':count,failed:0 if failed=='open' else -1}),ready=ready,old=old)
        rng=random.Random(135)
        pairs=list(itertools.product(vals,vals,[0,1,255],[0,4,5,6,0xffffffff]))
        pairs += [(rng.getrandbits(32),rng.getrandbits(32),rng.randrange(256),rng.choice([5,0xffffffff]))for _ in range(256)]
        for base,limit,flag,sel in pairs:
            x=original.selection(base,limit,flag,sel)
            y=native.lib.vn135_power_caller_value_135(base,limit,flag,sel)
            assert x==y,(base,limit,flag,sel,x,y)
            counts['caller_value_slice']+=1
    result={'reference_sha256':REF_SHA,'counts':dict(counts),'total':sum(counts.values()),'compared_events':events,
      'visited_instruction_addresses':len(original.m.visited),'new_arm_opcodes':0,
      'physical_gpio':False,'firmware_process':False,'setter_and_reset':'scripted external callbacks',
      'nested_gpio_aml_dispatch':True}
    print('GPIO_POWER135_ORIGINAL_PASS',json.dumps(result,sort_keys=True))
    if a.summary:Path(a.summary).write_text(json.dumps(result,indent=2)+'\n')
if __name__=='__main__':main()
