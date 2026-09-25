#!/usr/bin/env python3
"""Check deterministic time/hash vectors derived from the existing Stage9 fixture.
Not mined blocks or pool-approved time values. hashlib is an independent check.
"""
from pathlib import Path
import hashlib,json,argparse
ROOT=Path(__file__).resolve().parents[1]
def payload():
    g=json.loads((ROOT/'evidence/stage9/genesis-vector.json').read_text())['data']
    header=bytes.fromhex(g['header']);start=int.from_bytes(header[68:72],'little')
    rows=[]
    for delta in (0,1,2,1000,0xffffffff,0x80000000):
        time=(start+delta)&0xffffffff;h=bytearray(header);h[68:72]=time.to_bytes(4,'little')
        digest=hashlib.sha256(hashlib.sha256(h).digest()).digest()
        rows.append({'delta':delta,'time':time,'time_hex':f'{time:08x}','raw_sha256d':digest.hex()})
    return {'source':'evidence/stage9/genesis-vector.json','start_time':start,'synthetic_rolled_headers':True,
            'pool_policy_checked':False,'submitted':False,'rows':rows}
def ctext(v):
    s='/* Generated synthetic time vectors; no newly mined blocks. */\n'
    s+='typedef struct { uint32_t delta,time; uint8_t digest[32]; } time_vector;\n'
    s+='static const time_vector time_vectors[]={\n'
    for r in v['rows']:
        d=','.join('0x'+r['raw_sha256d'][i:i+2] for i in range(0,64,2))
        s+=f'    {{UINT32_C({r["delta"]}),UINT32_C({r["time"]}),{{{d}}}}},\n'
    return s+'};\n'
def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--write',action='store_true');a=p.parse_args()
    v=payload();out={ROOT/'evidence/stage12/time-vectors.json':json.dumps(v,indent=2)+'\n',ROOT/'tests/fixtures/time_roll_vectors.h':ctext(v)}
    for path,text in out.items():
        if a.write:path.parent.mkdir(parents=True,exist_ok=True);path.write_text(text)
        else:assert path.read_text()==text,path
    print('Stage12 hashlib vectors:',len(v['rows']),'written' if a.write else 'PASS')
if __name__=='__main__':main()
