"""Stage8 bounded reference calls, never execute the ELF as a Linux process.
Real original SHA/comparator, injected memcpy/memset/getters/logging/hash callback.
A SHA-bound prefilter deliberately binds the callback to 0x2d994; this is a test
configuration, NOT proof of T21's production function-pointer selection.
"""
from pathlib import Path
import hashlib,struct,sys
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'tools'))
from elf32 import ELF32
from arm32_verify_subset import ARM32Verify
from nonce_oracle import NonceOracle,SHA
class VerifyOracle:
    def __init__(self):
        self.elf=ELF32(ROOT/'reference/cgminer.vendor.elf')
        assert hashlib.sha256(self.elf.data).hexdigest()==SHA
        self.m=ARM32Verify(self.elf)
    def hash_words(self,words):
        assert len(words)==80
        m=self.m;work=m.DATA_BASE+0x1000
        image=bytearray(b'\xa7'*632);image[:80]=words
        m.mem[work:work+632]=image;m.reset((work,))
        m.run(0x2d994,hooks={0x5a2ee8:NonceOracle.copy,0x5a348c:NonceOracle.fill},max_steps=80000)
        digest=bytes(m.mem[work+0x120:work+0x140])
        image[0x120:0x140]=digest
        assert m.mem[work:work+632]==image,'Unexpected work write outside hash'
        return digest
    def target(self,h,t):
        assert len(h)==len(t)==32
        m=self.m;a=m.DATA_BASE;b=a+64
        m.mem[a:a+32]=h;m.mem[b:b+32]=t;m.reset((a,b))
        answer=m.run(0x10c1c,max_steps=1000)
        assert bytes(m.mem[a:a+32])==h and bytes(m.mem[b:b+32])==t
        return answer
    def prefilter(self,words,old_digest,last,nonce,selector,forced_digest=None):
        assert len(words)==80 and len(old_digest)==32
        m=self.m;a=m.DATA_BASE
        thread=a;state=a+0x200;work=a+0x1000;global_config=a+0x2000
        config=a+0x2200;model=a+0x2500;fake_hash=a+0x3000
        m.reset((thread,work,nonce))
        m.write(thread+0x24,state);m.write(state+0xe8,last)
        m.write(global_config+0x14,config);m.write(config+0x18,model)
        m.write(config+0x208,fake_hash if forced_digest is not None else 0x2d994)
        m.write(model+0x34,selector)
        image=bytearray(b'\xb9'*632);image[:80]=words;image[0x120:0x140]=old_digest
        m.mem[work:work+632]=image
        events=[];outcome=[]
        def config_get(mm):
            assert mm.r[0]==0;events.append(('getter',));mm.r[0]=global_config
        def log(mm):events.append(('duplicate-log',))
        def hash_call(mm):
            assert mm.r[0]==work
            events.append(('hash',mm.read(state+0xe8),bytes(mm.mem[work:work+80])))
            mm.mem[work+0x120:work+0x140]=forced_digest
        def passed(mm):outcome.append(0);mm.r[14]=mm.RETURN
        def rejected(mm):outcome.append(1 if last==nonce else 2);mm.r[14]=mm.RETURN
        hooks={0x29238:config_get,0xfa0c4:log,0x330a4:passed,0x33520:rejected,
               0x5a2ee8:NonceOracle.copy,0x5a348c:NonceOracle.fill}
        if forced_digest is not None:hooks[fake_hash]=hash_call
        # Prologue allocates 72 stack bytes and sets fp=entry_sp-8; its VFP
        # save is outside the observed prefix and no FP register is read here.
        m.r[13]=m.STACK_TOP-72;m.r[11]=m.STACK_TOP-8
        m.run(0x32f74,hooks=hooks,max_steps=85000)
        assert len(outcome)==1
        result={'outcome':outcome[0],'last':m.read(state+0xe8),
                'words':bytes(m.mem[work:work+80]),
                'digest':bytes(m.mem[work+0x120:work+0x140]),'events':events}
        image[:80]=result['words'];image[0x120:0x140]=result['digest']
        assert m.mem[work:work+632]==image,'Unexpected prefilter work write'
        return result
    def setup_registry(self, references, count=None):
        m=self.m;a=m.DATA_BASE;table=a+0x6000
        if count is None:count=len(references)
        # Original PIC accesses load GOT slots pointing at count/list globals.
        count_global=m.read((0x34d74+8+m.read(0x34dcc))&0xffffffff)
        list_global=m.read((0x34d8c+8+m.read(0x34dd0))&0xffffffff)
        m.write(count_global,count);m.write(list_global,table)
        for i,reference in enumerate(references):m.write(table+4*i,reference)
    def membership(self,references,target,count=None):
        m=self.m;m.reset((target,));self.setup_registry(references,count)
        calls=[]
        def lock(mm):calls.append(('lock',mm.r[0]));mm.r[0]=0
        def unlock(mm):calls.append(('unlock',mm.r[0]));mm.r[0]=0
        result=m.run(0x34d54,hooks={0x5a6108:lock,0x5a66c4:unlock},max_steps=10000)
        assert len(calls)==2 and calls[0][1]==calls[1][1]
        return result
    def job(self,records,key,reject_result,registry=None):
        """records = (key, nonnull opaque token, word_1fc). No concurrent mutation."""
        assert len(records)==3
        m=self.m;a=m.DATA_BASE;base=a+0x1000;m.reset()
        m.r[5]=base;m.r[8]=a;m.r[7]=a+4;m.write(a,0);m.write(a+4,0)
        m.write(m.r[13]+0x4c,key)
        pointer_tokens={};token_pointers={};events=[];outcome=[]
        for i,(k,token,status) in enumerate(records):
            p=a+0x3000+i*0x400 if token else 0
            m.write(base+0x278+i*0x478,k);m.write(base+0x27c+i*0x478,p)
            if p:
                m.write(p+0x1fc,status);pointer_tokens[p]=token;token_pointers[token]=p
        def reject(mm):
            token=pointer_tokens[mm.r[0]];events.append(token);mm.r[0]=reject_result&0xffffffff
        def selected(mm):
            outcome.append((True,(mm.r[4]-base)//0x478));mm.r[14]=mm.RETURN
        def skipped(mm):outcome.append((False,None));mm.r[14]=mm.RETURN
        hooks={0x74f14:selected,0x74e7c:skipped}
        if registry is None:hooks[0x34d54]=reject
        else:
            assert len(token_pointers)==len(pointer_tokens),'Registry mode requires distinct record references'
            # Nonrecord tokens remain distinct pointers, never dereferenced by membership.
            self.setup_registry([token_pointers.get(t,0 if t==0 else a+0x7800+4*t) for t in registry])
            def lock(mm):events.append('registry-lock');mm.r[0]=0
            def unlock(mm):events.append('registry-unlock');mm.r[0]=0
            hooks.update({0x5a6108:lock,0x5a66c4:unlock})
        m.run(0x74de4,hooks=hooks,max_steps=10000)
        assert len(outcome)==1
        return outcome[0],events
if __name__=='__main__':
    o=VerifyOracle();w=bytes(range(80))
    swapped=b''.join(w[i:i+4][::-1] for i in range(0,80,4))
    assert o.hash_words(w)==hashlib.sha256(hashlib.sha256(swapped).digest()).digest()
    print('hash',o.hash_words(w).hex())
    print('target',o.target(bytes(32),bytes(32)))
    for d in (bytes(32),b'\xff'*32,None):
        print('prefilter',o.prefilter(w,bytes(32),3,4,0,d))
    print('duplicate',o.prefilter(w,b'\xef'*32,4,4,0,bytes(32)))
    print('job',o.job([(1,1,1),(2,2,1),(3,3,1)],2,0))
