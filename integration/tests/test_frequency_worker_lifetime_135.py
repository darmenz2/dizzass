#!/usr/bin/env python3
"""Bounded original-instruction witness; detect a dead read, never perform UAF."""
import json
import test_frequency_worker_135 as W
from arm32_difficulty_subset import ARM32Difficulty
class DeadArgumentRead(Exception): pass
class LifetimeMachine(W.Machine):
    dead=False
    current_pc=0
    def read(self,addr,n=4):
        if self.dead and addr<W.ARG+24 and addr+n>W.ARG:
            raise DeadArgumentRead((self.current_pc,addr,n))
        return super().read(addr,n)
    def extra_instruction(self,word,pc):
        self.current_pc=pc
        if 0x65b3c<=pc<0x65f68:
            self.visited.add(pc);return ARM32Difficulty.extra_instruction(self,word,pc)
        return super().extra_instruction(word,pc)
def witness():
    elf=W.ELF32(W.ROOT/'reference/cgminer.vendor.elf');m=LifetimeMachine(elf);m.visited=set()
    m.write(W.BASE+0x18,W.MODEL);m.write(W.BASE+0x230,W.CHAINS)
    m.write(W.MODEL+0xd8,100);m.write(W.MODEL+0xe4,400)
    for i in range(3):
        at=W.CHAINS+800*i;m.write(at+0x20,2);m.write(at+0x24,1,1);m.write(at+0x28,700)
    events=[];pending=[];handles=W.ARG+0x800
    def count(_):m.r[0]=3
    def allocate(_):
        count,stride=m.r[:2];assert count==3 and stride in (8,4)
        m.r[0]=W.ARG if stride==8 else handles;events.append(('allocate',stride))
    def create(_):
        output,attr,entry,arg=m.r[:4];assert attr==0 and entry==0x65fcc
        if pending:m.r[0]=11;events.append(('create_failed',1));return
        pending.append(arg);m.write(output,100);m.r[0]=0;events.append(('created_deferred',0))
    def free(_):
        events.append(('free',m.r[0]));m.dead|=m.r[0]==W.ARG;m.r[0]=0
    def log(_):m.r[0]=0
    def join(_):raise AssertionError('original unexpectedly joined after partial failure')
    m.reset((W.BASE,));m.run(0x65b3c,hooks={0xfe668:count,0x593bb4:allocate,0x593c8c:free,0x5a55cc:create,0x5a5d2c:join,0xfa0c4:log},max_steps=1000)
    assert m.r[0]==11 and len(pending)==1 and m.dead
    m.reset((pending[0],))
    try:m.run(0x65fcc,max_steps=8)
    except DeadArgumentRead as error:
        pc,addr,n=error.args[0];assert pc==0x65fd8 and addr==W.ARG and n==4
    else:raise AssertionError('missing delayed-start lifetime violation')
    report={'result':'delayed_worker_reads_released_argument','parent':'65b3c','worker_read_pc':'65fd8','created_before_failure':1,'joins_before_release':0,'real_threads':False,'actual_uaf_executed':False,'events':events}
    print('FREQUENCY_WORKER135_LIFETIME_WITNESS',json.dumps(report))
    return report
if __name__=='__main__':witness()
