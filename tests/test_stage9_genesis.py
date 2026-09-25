#!/usr/bin/env python3
"""Public reference vector across real original caller/core/SHA/target slices.
Separate end-to-end offline fixture, NOT a claimed full consumer or live share.
"""
from test_stage9_differential import *
import subprocess
f=json.loads((ROOT/'evidence/stage9/genesis-vector.json').read_text())
d={k:bytes.fromhex(v) for k,v in f['data'].items()};words=bytearray(d['words'])
words[:4]=b'\xa8'*4;words[36:68]=b'\xd3'*32
coinbase=d['coinbase'];c=Candidate();c.version_word=int.from_bytes(d['words'][:4],'little')
c.nonce=int.from_bytes(d['words'][76:80],'little');c.job_word_70=c.job_word_74=0xffffffff
r=RebuildOracle().candidate_prefix(words,coinbase,0,0,bytes(c),[])
assert r['words']==d['words'];v=VerifyOracle();lib=load();count=0
cb=buf(coinbase);snap=Snapshot((U8*112).from_buffer_copy(words),cb,len(coinbase),0,0,None,0)
for selector in range(3):
    original=v.prefilter(r['words'][:80],bytes(32),0,c.nonce,selector)
    assert original['outcome']==0 and original['digest']==d['hash']
    for target in [d['target'],d['hash'],(int.from_bytes(d['hash'],'little')-1).to_bytes(32,'little'),bytes(32)]:
        answer=v.target(d['hash'],target);last=U32(0);result=Check();scratch=buf(coinbase)
        assert lib.vn135_candidate_verify_snapshot(C.byref(c),C.byref(snap),scratch,len(coinbase),buf(target),C.byref(last),selector,C.byref(result))==0
        assert result.prefilter==0 and result.hash_computed==result.target_checked==1
        assert result.meets_target==answer and bytes(result.work.digest)==d['hash'];count+=1
actual=json.loads(subprocess.check_output([str(ROOT/'build/vn135-rebuild-genesis')],text=True))
assert actual['block_hash']==d['hash'][::-1].hex() and actual['meets_target'] is True
assert actual['submitted'] is False and actual['job_freshness_checked'] is False
result={'status':'PASS','separate_original_slice_compositions':count,'known_genesis_header':True,
        'digest':actual['block_hash'],'submitted':False,'hardware_tested':False}
(ROOT/'build/stage9-genesis-results.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result))
