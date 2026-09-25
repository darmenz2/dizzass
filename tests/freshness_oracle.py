"""Execute original predicates, original signed64->double; external clock,
strcmp, successful rwlocks/post-unlock callback and diagnostics explicitly hooked.
Only snapshot-domain success paths: not concurrency, I/O or full consumer.
"""
from pathlib import Path
import hashlib,struct,sys
R=Path(__file__).resolve().parents[1];sys.path.insert(0,str(R/'tools'))
from elf32 import ELF32
from arm32_freshness_subset import ARM32Freshness
SHA='b2663b3aa753cc14ae9d3b11a14d3d93c74b605a3e433b02101c3c17c69d95e9'
class FreshnessOracle:
    def __init__(self):
        self.elf=ELF32(R/'reference/cgminer.vendor.elf');assert hashlib.sha256(self.elf.data).hexdigest()==SHA
        self.m=ARM32Freshness(self.elf)
    def gate(self,state):
        m=self.m;a=m.DATA_BASE;image=bytearray(b'\xa7'*0x420)
        struct.pack_into('<I',image,0x1fc,state[0])
        for off,v in zip((0x3fc,0x3fe,0x209,0x1ea),state[1:]):image[off]=v
        m.mem[a:a+len(image)]=image;m.reset((a,));r=m.run(0x2a560,max_steps=1000)
        assert m.mem[a:a+len(image)]==image
        return r
    def stale(self,block,current,roll,share,active,notify,staged,now,job,pooljob):
        m=self.m;a=m.DATA_BASE;work=a+0x100;pool=a+0x1000
        image=bytearray(b'\xa7'*632);pi=bytearray(b'\xb8'*0x420)
        struct.pack_into('<I',image,0x1b8,block);struct.pack_into('<I',image,0x16c,pool)
        struct.pack_into('<i',image,0x184,roll);struct.pack_into('<Q',image,0x170,staged & ((1<<64)-1))
        pi[0x3fc]=active;pi[0x3fe]=notify
        for data,offset,text,addr in [(image,0x18c,job,a+0x2000),(pi,0x3d0,pooljob,a+0x4000)]:
            struct.pack_into('<I',data,offset,0 if text is None else addr)
            if text is not None:
                assert len(text)<0x1000 and b'\0' not in text
                m.mem[addr:addr+len(text)+1]=text+b'\0'
        m.mem[work:work+632]=image;m.mem[pool:pool+len(pi)]=pi
        # Original PC-relative global, not a guessed pool field.
        global_addr=0x32060+8+m.read(0x324c8);m.write(global_addr,current)
        indirect=m.read(0x323c8+8+m.read(0x32508));callback=a+0xf000;m.write(indirect,callback)
        self.events=[]
        def clock(mm):
            self.events.append('clock');mm.write(mm.r[0],now & ((1<<64)-1),8);mm.write(mm.r[0]+8,123456,4);mm.r[0]=0
        def lock(mm):assert mm.r[0]==pool+0x30;self.events.append('lock');mm.r[0]=0
        def unlock(mm):assert mm.r[0]==pool+0x30;self.events.append('unlock');mm.r[0]=0
        def after(mm):self.events.append('after_unlock');mm.r[0]=0
        def string(mm):
            assert mm.r[0]==a+0x2000 and mm.r[1]==a+0x4000
            self.events.append('strcmp');mm.r[0]=(0 if job==pooljob else (1 if job>pooljob else 0xffffffff))
        def log(mm):self.events.append('log');mm.r[0]=0
        hooks={0x1222c:clock,0x5a68e8:lock,0x5a6a78:unlock,callback:after,0x5a375c:string,0xfa0c4:log}
        m.reset((work,share));r=m.run(0x32040,hooks=hooks,max_steps=20000)
        assert m.mem[work:work+632]==image and m.mem[pool:pool+len(pi)]==pi
        return {'stale':r,'events':self.events[:], 'steps':m.steps}
if __name__=='__main__':
    o=FreshnessOracle()
    for roll in [0,60,61,600]:
        for age in [0,60,61,599,600]:print(roll,age,o.stale(1,1,roll,0,1,1,0,age,b'a',b'a'))
