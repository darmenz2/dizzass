"""Execute bounded original PSU slices, not a firmware process or device.
External I2C, mutex, delay and diagnostic operations are explicit hooks.
The original validator and voltage decoder run inside the exchange/read test.
"""
from pathlib import Path
import hashlib
import json
import sys
ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'tools'))
from elf32 import ELF32
from arm32_difficulty_subset import ARM32Difficulty
from arm32_subset import signed

class PSUArm(ARM32Difficulty):
    def reset(self,args=()):
        super().reset(args);self.allowed=[];self.visited=set()
    def extra_instruction(self,w,pc):
        if not any(a<=pc<b for a,b in self.allowed):
            raise ValueError('Unexpected original PC '+hex(pc))
        self.visited.add(pc)
        # Only the witnessed VSTR s0,[r4] form needed by read-voltage.
        # Operands and instruction identity are separately fixture-tested.
        if w==0xed840a00:
            self.write(self.r[4],self.s[0],4);return True
        # Conversion-only UMULL/MLS required by the original delay routine.
        if w & 0x0ff000f0 == 0x00800090:  # no S, no accumulate
            lo=(w>>12)&15;hi=(w>>16)&15;rs=(w>>8)&15;rm=w&15
            if 15 in (lo,hi,rs,rm) or lo==hi:raise ValueError('UMULL registers')
            z=self.r[rs]*self.r[rm]
            self.r[lo]=z&0xffffffff;self.r[hi]=z>>32;return True
        if w & 0x0ff000f0 == 0x00600090:
            rd=(w>>16)&15;ra=(w>>12)&15;rs=(w>>8)&15;rm=w&15
            if 15 in (rd,ra,rs,rm):raise ValueError('MLS registers')
            z=(self.r[ra]-self.r[rs]*self.r[rm])&0xffffffff
            self.r[rd]=z;return True
        return super().extra_instruction(w,pc)

class Oracle:
    STATE=0x654c30
    DEVICE=0x840000
    BUS=0x841000
    TX=0x842003
    RX=0x844005
    OUT=0x846000
    def __init__(self):
        self.evidence=json.loads((ROOT/'integration/evidence/psu_protocol_135.json').read_text())
        self.elf=ELF32(ROOT/self.evidence['reference_elf'])
        assert hashlib.sha256(self.elf.data).hexdigest()==self.evidence['reference_sha256']
        for r in self.evidence['ranges']:
            a,b=int(r['start'],16),int(r['end_exclusive'],16)
            assert hashlib.sha256(self.elf.read(a,b-a)).hexdigest()==r['sha256']
        r=self.evidence['original_path'];s=r['text'].encode()+b'\0'
        assert bytes(x^r['xor'] for x in self.elf.read(int(r['address'],16),len(s)))==s
        self.m=PSUArm(self.elf)
    def begin(self,mode,state=(34,0,0,0,0),args=(),kind=0,address=16):
        m=self.m;m.reset(args)
        m.allowed=[(int(r['start'],16),int(r['end_exclusive'],16))
                   for r in self.evidence['ranges']]
        m.write(self.STATE+12,mode)
        model,w08,b1c,b130,w132=state
        for off,val,size in [(4,model,2),(8,w08,4),(28,b1c,1),(304,b130,1),(306,w132,2)]:
            m.write(self.STATE+off,val,size)
        m.write(self.DEVICE+24,self.BUS);m.write(self.DEVICE+28,address,1)
        m.write(self.BUS+24,kind)
        self.events=[];self.dumps={}
    def log(self,m):
        line=m.r[3]
        if line==957:self.events.append(('log',line,m.read(m.r[13]+8),m.read(m.r[13]+12),b''))
        elif line in (937,939):
            ptr=m.read(m.r[13]+8)
            if ptr not in self.dumps:raise ValueError('Unformatted dump')
            self.events.append(('log',line,0,0,self.dumps[ptr]))
        elif line in (951,439,1110):self.events.append(('log',line,0,0,b''))
        else:raise ValueError('Unexpected log line '+str(line))
        m.r[0]=0
    def fmt(self,m):
        dest,cap,ptr,n=m.r[:4]
        assert cap==1024 and n<=257
        m.check(ptr,n);self.dumps[dest]=bytes(m.mem[ptr:ptr+n]);m.r[0]=0
    def validate(self,mode,tx,rx,request_size=None):
        m=self.m
        self.begin(mode,args=(self.TX,len(tx) if request_size is None else request_size,self.RX,len(rx)))
        m.mem[self.TX:self.TX+len(tx)]=tx;m.mem[self.RX:self.RX+len(rx)]=rx
        rc=m.run(0x102bd0,hooks={0xfa0c4:self.log},max_steps=20000)
        return signed(rc),self.events
    def voltage(self,state,raw):
        self.begin(0,state,args=(raw,));m=self.m
        m.run(0x100878,max_steps=5000)
        return m.dbits(0)
    def exchange(self,kind,mode,tx,responses,initial,address=16,returns=None,
                 mutate_mode=None,read_command=False,state=(34,0,0,0,0)):
        m=self.m
        self.begin(mode,state,args=((self.DEVICE,self.OUT) if read_command else
                  (self.DEVICE,self.TX,len(tx),self.RX,len(initial))),kind=kind,address=address)
        m.mem[self.TX:self.TX+len(tx)]=tx;m.mem[self.RX:self.RX+len(initial)]=initial
        m.write(self.OUT,0x11223344);rets=returns or {}
        self.attempt=0;self.read_index=0;self.rxptr=self.RX
        if read_command:
            # Explicit seed for otherwise uninitialized original stack scratch.
            # Prologue reserves 40 bytes; RX begins at caller SP-32.
            self.rxptr=m.STACK_TOP-32
            m.mem[self.rxptr:self.rxptr+len(initial)]=initial
        def lock(x):
            assert x.r[0]==self.DEVICE;self.events.append(('lock',));x.r[0]=rets.get('lock',0)&0xffffffff
        def unlock(x):
            assert x.r[0]==self.DEVICE;self.events.append(('unlock',));x.r[0]=rets.get('unlock',0)&0xffffffff
        def delay(x):
            v=x.r[0];assert v in (100,400);self.events.append(('delay',v))
            if v==400:self.attempt+=1;self.read_index=0
            if v==100 and mutate_mode is not None:x.write(self.STATE+12,mutate_mode)
            x.r[0]=rets.get('delay',0)&0xffffffff
        def params(x):
            assert x.r[0]==self.BUS
            return tuple(x.r[1:4])
        def wb(x):
            q=params(x);ptr,n=x.read(x.r[13]),x.read(x.r[13]+4)
            self.events.append(('write_block',*q,bytes(x.mem[ptr:ptr+n])))
            x.r[0]=rets.get('write',0)&0xffffffff
        def rb(x):
            q=params(x);ptr,n=x.read(x.r[13]),x.read(x.r[13]+4);self.rxptr=ptr
            self.events.append(('read_block',*q,n))
            chunk=responses[min(self.attempt-1,len(responses)-1)]
            if chunk is not None:
                assert len(chunk)<=n;x.mem[ptr:ptr+len(chunk)]=bytes(chunk)
            x.r[0]=rets.get('read',0)&0xffffffff
        def wy(x):
            self.events.append(('write_byte',*params(x),x.read(x.r[13])))
            x.r[0]=rets.get('write',0)&0xffffffff
        def ry(x):
            self.events.append(('read_byte',*params(x)))
            seq=responses[min(self.attempt-1,len(responses)-1)]
            if seq is None:val=rets.get('read',-1)
            else:val=seq[self.read_index]
            self.read_index+=1;x.r[0]=val&0xffffffff
        hooks={0x5a6108:lock,0x5a66c4:unlock,0x10ed2c:delay,0xfe538:wb,0xfe528:rb,
               0x126fcc:wy,0x128188:ry,0xfa0c4:self.log,0x10f170:self.fmt}
        entry=0x104218 if read_command else (0x10560c if kind==0 else 0x105938)
        rc=m.run(entry,hooks=hooks,max_steps=50000)
        # Original validator runs; it is not stubbed with a chosen outcome.
        if not read_command or kind in (0,1):assert 0x102bd0 in m.visited
        if read_command and rc==0:assert 0x100878 in m.visited
        return signed(rc),bytes(m.mem[self.rxptr:self.rxptr+len(initial)]),self.events,signed(m.read(self.OUT))
    def delay(self,value):
        self.begin(0,args=(value,));m=self.m;seen=[]
        def nanosleep(x):
            assert x.r[0]==x.r[1]
            seen.append((x.read(x.r[0],8),x.read(x.r[0]+8)))
            x.r[0]=0
        def errno_ptr(x):x.r[0]=0x84e000
        rc=m.run(0x10ed2c,hooks={0x5a7584:nanosleep,0x5931e4:errno_ptr},max_steps=2000)
        if signed(value)<0:
            assert signed(rc)==-1 and not seen and m.read(0x84e000)==22
        else:
            assert rc==0 and seen==[(value//1000,(value%1000)*1000000)]
        return seen
