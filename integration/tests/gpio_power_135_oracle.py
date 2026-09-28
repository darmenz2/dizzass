"""Bounded execution of saved 1.3.5 instructions; external I/O is scripted RAM.
No firmware process, GPIO, device descriptors, or voltage changes are executed.
"""
from pathlib import Path
import hashlib, json, sys
ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'tools'))
from elf32 import ELF32
from arm32_verify_subset import ARM32Verify
from arm32_subset import signed
REF_SHA='b2663b3aa753cc14ae9d3b11a14d3d93c74b605a3e433b02101c3c17c69d95e9'
ENTRIES={'export':0x1248e4,'probe':0x124b5c,'set':0x124ba4,'get':0x124d64,
 'direction':0x124f70,'unexport':0x1251b8,'aml_on':0x11c978,'aml_off':0x11ca74,
 'start':0x6c224,'stop':0x6b778}
B=0x840100; OUT=0x840020; CHAINS=0x844000
class Checked(ARM32Verify):
    def extra_instruction(self,w,pc):
        if not any(a<=pc<b for a,b in self.allowed):
            raise ValueError('Unexpected code address '+hex(pc))
        self.visited.add(pc)
        return super().extra_instruction(w,pc)
class Oracle:
    def __init__(self):
        self.elf=ELF32(ROOT/'reference/cgminer.vendor.elf')
        assert hashlib.sha256(self.elf.data).hexdigest()==REF_SHA
        manifest=json.loads((ROOT/'integration/evidence/gpio_power_135.json').read_text())
        for span in manifest['ranges']:
            a,b=int(span['start'],16),int(span['end_exclusive'],16)
            assert hashlib.sha256(self.elf.read(a,b-a)).hexdigest()==span['sha256']
        for text in manifest['source_paths']:
            raw=self.elf.read(int(text['address'],16),len(text['text']))
            assert bytes(x^text['xor'] for x in raw).decode()==text['text']
        self.m=Checked(self.elf);self.m.visited=set()
        self.m.allowed=[(int(s['start'],16),int(s['end_exclusive'],16)) for s in manifest['ranges']]
        for ep in [0x125338,0x11cc8c]:
            self.m.reset();self.m.run(ep,max_steps=100000)
        # Execute original AML table setup, stopping BEFORE peripheral calls.
        self.m.reset((2,4));self.m.run(0xfb994,stop=0xfd784,max_steps=20000)
        assert self.m.read(0x654b78)==0x11c978
        assert self.m.read(0x654b7c)==0x11ca74
    def cbytes(self,p):
        self.m.check(p,1)
        x=bytes(self.m.mem[p:p+512]);assert b'\0' in x
        return x.split(b'\0')[0]
    def run(self,entry,script,pin=437,arg=1,ready=1,old=(0x92,0x12345678),seed=0x48,augment=None):
        m=self.m
        m.mem[B:B+0x1100]=bytes([0xa5])*0x1100
        m.write(B+0xff1,old[0],1);m.write(B+0x20c,old[1]);m.write(B+0x230,CHAINS)
        m.write(0x6563f8,ready,1);m.write(OUT,0xdeadbeef)
        def snapshot():return (m.read(B+0xff1,1),m.read(B+0x20c),m.read(OUT))
        script.snapshot=snapshot
        def ret(x):m.r[0]=x&0xffffffff
        def simple(name,args=()):
            def call(_):ret(script.call(name,args() if callable(args) else args))
            return call
        def fmt(_):
            fmt=self.cbytes(m.r[2]);v=(fmt.decode()%signed(m.r[3])).encode();n=m.r[1]
            assert n==256
            m.mem[m.r[0]:m.r[0]+len(v)+1]=v+b'\0';ret(len(v))
        def log(_):
            line=m.r[3];lr=m.r[14]
            src=0 if 0x1248e4<=lr<0x125338 else 1 if 0x11c978<=lr<0x11cbe0 else 2
            value=m.read(m.r[13]+8) if (src==0 and line==72) or (src==2 and line in [1973,1976]) else 0
            if src==2:assert m.r[1]==0x5e50be
            script.call('log',(src,line,value));ret(0)
        def scan(_):
            assert self.cbytes(m.r[1])==b'%c'
            before=m.read(m.r[2],1)
            rc=script.call('scan_char',(m.r[0],before))
            if script.scan_write:m.write(m.r[2],script.scan_byte,1)
            ret(rc)
        def scan_uint(_):
            assert self.cbytes(m.r[1])==b'%u'
            text=self.cbytes(m.r[0]);rc=script.call('scan_uint',(text,))
            if script.uint_write:m.write(m.r[2],script.uint_value)
            ret(rc)
        def set_voltage(_):
            assert m.r[0]==B+0x108c
            ret(script.call('set_voltage',(m.r[1],)))
        def reset_chain(_):
            d=m.r[0]-CHAINS;assert d>=0 and d%800==0
            ret(script.call('reset_chain',(d//800,)))
        hooks={0x59f558:fmt,0x59e5b0:simple('open',lambda:(self.cbytes(m.r[0]),self.cbytes(m.r[1]))),
          0x5a6108:simple('lock'),0x5a66c4:simple('unlock'),
          0x59e658:simple('number',lambda:(m.r[0],self.cbytes(m.r[1]),m.r[2])),
          0x59e818:simple('text',lambda:(self.cbytes(m.r[0]),m.r[1])),
          0x59e084:simple('close',lambda:(m.r[0],)),
          0x5a8104:simple('access',lambda:(self.cbytes(m.r[0]),signed(m.r[1]))),
          0x59e958:scan,0x59f648:scan_uint,0xfa0c4:log,
          0x59ef60:simple('perror',lambda:(self.cbytes(m.r[0]),)),
          0x104134:set_voltage,0xfe668:simple('chain_count'),0x55370:reset_chain}
        args=(B,arg) if entry in ['start','stop'] else (pin,OUT if entry=='get' else arg)
        allowed=list(m.allowed)
        m.reset(args)
        m.allowed=allowed
        # Explicit initial stack byte for the original failed-fscanf case.
        m.mem[m.STACK_TOP-1024:m.STACK_TOP]=bytes([seed])*1024
        if augment:augment(m,hooks)
        rc=signed(m.run(ENTRIES[entry],hooks=hooks,max_steps=50000))
        return rc,snapshot(),script.events
    def selection(self,base,limit,flag,selector):
        m=self.m;m.reset();m.r[4]=B;m.r[9]=0x847000
        m.write(B+0xdc,base);m.write(B+0xec,flag,1);m.write(B+0x1c,0x847100)
        m.write(0x847134,limit);m.write(0x847000,selector)
        m.run(0x7140c,stop=0x71450,max_steps=1000)
        return m.r[5]
