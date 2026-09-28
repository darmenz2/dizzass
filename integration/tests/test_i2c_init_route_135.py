#!/usr/bin/env python3
"""Verify original AML selector installation and PSU caller up to exchange entry."""
import argparse
import hashlib
import json
from pathlib import Path
from i2c_init_135_oracle import Oracle, ROOT, cstr
from test_i2c_init_135 import INITIAL, Script

TABLE={0x654b74:0x11c5c0,0x654b78:0x11c978,0x654b7c:0x11ca74,
       0x654b80:0x11c968,0x654b88:0x119a1c,0x654b90:0x119c84,
       0x654b9c:0x11a6b0,0x654ba0:0x11ab24}
def run():
    oracle=Oracle();m=oracle.m
    m.reset((2,0));m.allowed=[(0xfb994,0xfd784)];m.run(0xfb994,stop=0xfd784,max_steps=20000)
    assert {p:m.read(p) for p in TABLE}==TABLE
    registration=[]
    # Both initializers and their nested register/open/GPIO calls execute.
    for name in ('hw','psu'):
        script=Script(exported=1)
        rc,final,events=oracle.run(name,script,INITIAL)
        assert rc==0
        registration.append({'kind':final[0],'name':final[2],'bus':hex(oracle.reg)})
    results=[]
    for kind,entry,label in ((1,0x105938,'byte'),(0,0x10560c,'block'),(2,0xfa0c4,'unsupported')):
        # 0 is a negative-control mutation, NOT a newly observed AML fallback.
        m.write(0x655fb4+0x18,kind)
        m.reset((0,));m.allowed=[(0xfe420,0xfe440),(0x11c968,0x11c978)];assert m.run(0xfe420,max_steps=1000)==0x655fb4
        for mode in (0,1,2,0xffffffff):
            device=0x848000;m.mem[device:device+0x40]=bytes(0x40)
            m.reset((device,10000,15000,mode))
            m.allowed=[(0x100fc4,0x101128),(0xfe420,0xfe430),(0x11c968,0x11c978)]
            calls=[]
            def mutex(m):calls.append('mutex_init');m.r[0]=0
            m.run(0x100fc4,stop=entry,hooks={0x5a60dc:mutex},max_steps=6000)
            assert m.read(device+0x18)==0x655fb4 and m.read(device+0x1c,1)==16
            assert calls==['mutex_init']
            if kind<2:
                assert m.r[2]==6 and m.read(m.r[13])==8
                packet=bytes(m.mem[m.r[1]:m.r[1]+6]).hex()
                assert packet==('55aa04020600' if mode==0 else '55aa04020402')
            else:
                assert m.r[3]==439;packet=None
            results.append({'kind':kind,'checksum_mode':mode,'entry':hex(entry),'route':label,'request':packet})
    m.write(0x655fb4+0x18,1)
    for index in (0,1,2,0xffffffff):
        m.reset((index,));m.allowed=[(0xfe420,0xfe440),(0x11c968,0x11c978)];assert m.run(0xfe420,max_steps=1000)==0x655fb4
        m.reset((index,));m.allowed=[(0xfe420,0xfe440),(0x119c84,0x119ccc)];assert m.run(0xfe430,max_steps=1000)==0x68c180
    return {'table':{hex(k):hex(v) for k,v in TABLE.items()},'interfaces':registration,
            'caller_prefix_cases':len(results),'getter_pairs':4,'results':results,
            'physical_device':False,'stop_before_exchange':True,
            'negative_controls':'bus kind 0/2 deliberately changed after original init; no automatic fallback claimed'}
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--summary',required=True);a=p.parse_args()
    r=run();Path(a.summary).parent.mkdir(parents=True,exist_ok=True);Path(a.summary).write_text(json.dumps(r,indent=2)+'\n')
    print('I2C_INIT_ROUTE_PASS',json.dumps(r,sort_keys=True))
