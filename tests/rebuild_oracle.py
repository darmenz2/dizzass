"""Execute bounded ORIGINAL work-build instructions, including original SHA.
External memory copy and successful rwlocks are explicit injected boundaries.
The original process, its threads, devices and network are never started.
"""
from pathlib import Path
import hashlib, struct, sys
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'tools'))
from elf32 import ELF32
from arm32_rebuild_subset import ARM32Rebuild
from nonce_oracle import NonceOracle, SHA

class ObservedARM(ARM32Rebuild):
    def reset(self,args=()):
        super().reset(args);self.sha_inputs=[]
    def extra_instruction(self,w,pc):
        if pc == 0x108f38:
            p,n=self.r[0],self.r[1];self.check(p,n)
            self.sha_inputs.append(bytes(self.mem[p:p+n]))
        return super().extra_instruction(w,pc)

class RebuildOracle:
    def __init__(self):
        self.elf=ELF32(ROOT/'reference/cgminer.vendor.elf')
        assert hashlib.sha256(self.elf.data).hexdigest()==SHA
        self.m=ObservedARM(self.elf)
    def sha(self,data):
        m=self.m;p=m.DATA_BASE;out=p+0xc000
        assert len(data)<0x8000
        m.mem[p:p+len(data)]=data;m.reset((p,len(data),out))
        m.run(0x108f38,hooks={0x5a2ee8:NonceOracle.copy,0x5a348c:NonceOracle.fill},max_steps=4000000)
        return bytes(m.mem[out:out+32])
    def setup(self,words,coinbase,offset,width,counter,branches):
        assert len(words)==112 and 0<=width<=8 and offset+width<=len(coinbase)
        m=self.m;a=m.DATA_BASE
        template=a;work=a+0x1000;cb=a+0x2000;table=a+0xa000;branchdata=a+0xa800
        assert len(coinbase)<=0x7000 and len(branches)<=32
        image=bytearray(b'\x93'*0x480)
        image[0x298:0x308]=words
        struct.pack_into('<II',image,0x3b4,cb,len(coinbase))
        struct.pack_into('<QII',image,0x3c0,counter,offset,width)
        struct.pack_into('<I',image,0x3d4,table);struct.pack_into('<i',image,0x3e8,len(branches))
        m.mem[template:template+len(image)]=image
        m.mem[cb:cb+len(coinbase)]=coinbase
        for i,b in enumerate(branches):
            assert len(b)==32;m.write(table+4*i,branchdata+32*i)
            m.mem[branchdata+32*i:branchdata+32*(i+1)]=b
        workimage=bytearray(b'\xa7'*632);m.mem[work:work+632]=workimage
        self.pointers=(template,work,cb,table,branchdata)
        return image,workimage
    def prefix(self,words,coinbase,offset,width,counter,branches):
        image,workimage=self.setup(words,coinbase,offset,width,counter,branches)
        m=self.m;template,work,cb,table,branchdata=self.pointers
        m.reset((template,work));events=[]
        def lock(kind):
            def invoke(mm):
                assert mm.r[0]==template+0x30
                events.append(kind);mm.r[0]=0
            return invoke
        hooks={0x11d7c:NonceOracle.copy,0x5a2ee8:NonceOracle.copy,0x5a348c:NonceOracle.fill,
               0x5a6b18:lock('write-lock'),0x5a6a78:lock('unlock'),0x5a68e8:lock('read-lock')}
        m.run(0x30550,stop=0x30a6c,hooks=hooks,max_steps=4000000)
        got=bytes(m.mem[work:work+112]);used=m.read(work+0x190,8);size=m.read(work+0x198)
        workimage[:112]=got;struct.pack_into('<QI',workimage,0x190,used,size)
        assert m.mem[work:work+632]==workimage,'Unexpected prefix work mutation'
        next_counter=m.read(template+0x3c0,8);struct.pack_into('<Q',image,0x3c0,next_counter)
        assert m.mem[template:template+len(image)]==image,'Unexpected template mutation'
        assert events==['write-lock','unlock','read-lock'],events
        return {'words':got,'counter_used':used,'counter_next':next_counter,'counter_size':size,
                'coinbase':bytes(m.mem[cb:cb+len(coinbase)]),'sha_inputs':m.sha_inputs[:],
                'events':events,'steps':m.steps}
    def candidate_prefix(self,words,coinbase,offset,width,candidate,branches):
        """Real caller 0x74f14 -> wrapper 0x300ac -> core 0x30550 prefix.
        Chosen and pinned template/reference are explicit test preconditions.
        Allocation succeeds; locks succeed. Stop excludes core metadata suffix.
        """
        assert len(candidate)==68
        counter=int.from_bytes(candidate[24:32],'little')
        image,workimage=self.setup(words,coinbase,offset,width,0xabcdef0123456789,branches)
        m=self.m;template,work,cb,table,branchdata=self.pointers
        reference=m.DATA_BASE+0xc800;thread=m.DATA_BASE+0xd000
        m.mem[reference:reference+0x480]=bytes(0x480)
        m.write(thread,7);m.write(template+0x3a8,0x4010000000000000,8)
        m.write(reference+0x3a8,0x4020000000000000,8)
        m.reset();sp=m.STACK_TOP-0x800;fp=sp+0x300
        m.r[13]=sp;m.r[11]=fp;m.r[4]=template-0x280;m.r[10]=reference
        m.mem[sp+0x40:sp+0x84]=candidate;m.write(sp+0x84,0xa1b2c3d4)
        m.write(sp+0x24,sp+0x58);m.write(sp+0x28,thread)
        events=[]
        def allocation(mm):
            assert (mm.r[0],mm.r[1])==(1,632)
            m.mem[work:work+632]=bytes(632);mm.r[0]=work;events.append('calloc632')
        def ok(kind):
            def invoke(mm):events.append((kind,mm.r[0]));mm.r[0]=0
            return invoke
        hooks={0x11d7c:NonceOracle.copy,0x5a2ee8:NonceOracle.copy,0x5a348c:NonceOracle.fill,
               0x593bb4:allocation,0x5a6108:ok('mutex-lock'),0x5a66c4:ok('mutex-unlock'),
               0x5a6b18:ok('write-lock'),0x5a6a78:ok('unlock'),0x5a68e8:ok('read-lock')}
        m.run(0x74f14,stop=0x30a6c,hooks=hooks,max_steps=4000000)
        assert bytes(m.mem[sp+0x40:sp+0x84])==candidate
        assert m.read(sp+0x84)==0xa1b2c3d4
        assert m.read(fp-32)==work
        assert m.read(work+0x190,8)==counter
        assert m.read(template+0x3c0,8)==(counter+1)&0xffffffffffffffff
        assert m.read(reference+0x3c0,8)==(counter+1)&0xffffffffffffffff
        assert m.read(template+0x298)==int.from_bytes(candidate[20:24],'little')
        assert m.read(template+0x3a8,8)==0x4020000000000000
        assert [e[0] if isinstance(e,tuple) else e for e in events]==[
            'calloc632','mutex-lock','mutex-unlock','write-lock','unlock',
            'write-lock','unlock','write-lock','unlock','read-lock']
        return {'words':bytes(m.mem[work:work+112]),'counter_used':counter,
                'counter_next':m.read(template+0x3c0,8),'counter_size':m.read(work+0x198),
                'coinbase':bytes(m.mem[cb:cb+len(coinbase)]),
                'sha_inputs':m.sha_inputs[:],'events':events,'steps':m.steps}
if __name__=='__main__':
    o=RebuildOracle();d=bytes(range(113))
    assert o.sha(d)==hashlib.sha256(d).digest()
    x=o.prefix(bytes(range(112)),bytes(range(100)),13,8,0xffffffffffffffff,[b'\x01'*32,b'\x02'*32])
    print({k:(v.hex() if isinstance(v,bytes) else v) for k,v in x.items() if k!='sha_inputs'})
    print('original SHA calls:',len(x['sha_inputs']))
