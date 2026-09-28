#!/usr/bin/env python3
"""Bounded creator, name decoder and worker prefix: not a live preset switch."""
import json
import test_mining_stop_135 as M
from arm32_difficulty_subset import ARM32Difficulty
class Machine(ARM32Difficulty):
    def extra_instruction(self,w,pc):
        assert any(a<=pc<b for a,b in ((0x4caf4,0x4cd4c),(0x4cda0,0x4cde0),(0x4d324,0x4d350)))
        return super().extra_instruction(w,pc)
def main():
    elf=M.R.ELF32(M.ROOT/'reference/cgminer.vendor.elf');m=Machine(elf)
    # Execute the actual 20-byte XOR decoder, then the worker name/flag prefix.
    m.reset();m.run(0x4d324,stop=0x4d350,max_steps=200)
    assert bytes(m.mem[0x5e38ad:0x5e38ad+20])==b'preset_switcher@btm\0'
    names=[]
    def name(_):
        assert m.r[0]==15 and m.r[1]==0x5e38ad and m.r[2:4]==[0,0] and m.read(m.r[13])==0
        names.append('preset_switcher@btm');m.r[0]=0
    m.write(M.BASE+0x1049,0,1);m.reset((M.BASE,))
    m.run(0x4cda0,stop=0x4cde0,hooks={0x593af8:name},max_steps=40)
    assert names==['preset_switcher@btm'] and m.read(M.BASE+0x1049,1)==1
    cases=0
    for flag,joinable,rc in ((0,0,0),(0,0,3),(0,1,0),(0,255,3),(1,0,0),(255,1,0)):
        m.write(M.BASE+0x1049,flag,1);m.write(M.BASE+0x104a,joinable,1);m.write(M.BASE+0x104c,555)
        calls=[]
        def create(_):
            assert tuple(m.r[:4])==(M.BASE+0x104c,0,0x4cda0,M.BASE)
            calls.append('create');m.r[0]=rc
        def join(_):
            assert m.r[0]==555 and m.r[1]==0
            calls.append('join');m.r[0]=(-3)&M.MASK
        def log(_):m.r[0]=0
        m.reset((M.BASE,));m.run(0x4caf4,hooks={0x5a55cc:create,0x5a5d2c:join,0xfa0c4:log},max_steps=200)
        assert calls==([] if flag else (['join'] if joinable else [])+['create'])
        assert m.read(M.BASE+0x104a,1)==(joinable if flag else int(rc==0))
        cases+=1
    print('MINING_STOP135_PROVENANCE_PASS',json.dumps(dict(creator_cases=cases,decoder_bytes=20,
        worker_prefix_cases=1,full_worker_recovered=False,real_threads=False)))
if __name__=='__main__':main()
