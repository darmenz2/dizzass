#!/usr/bin/env python3
from pathlib import Path
import hashlib,json,random,subprocess
ROOT=Path(__file__).resolve().parents[1];exe=ROOT/'build/vn135-verify-header';rng=random.Random(8135);count=0
for i in range(32):
    h=rng.randbytes(80);d=hashlib.sha256(hashlib.sha256(h).digest()).digest();v=int.from_bytes(d,'little')
    for t in (0,(1<<256)-1,v,max(0,v-1),min((1<<256)-1,v+1)):
        p=subprocess.run([str(exe),h.hex(),t.to_bytes(32,'little').hex()],capture_output=True,text=True,check=True)
        out=json.loads(p.stdout);assert out=={'sha256d_raw':d.hex(),'meets_target':v<=t,'job_freshness_checked':False,'submitted':False};count+=1
for args in ([],['00'*80],['00'*79,'00'*32],['gg'*80,'00'*32],['00'*80,'00'*33],['00'*80,'xz'*32]):
    p=subprocess.run([str(exe)]+args,capture_output=True,text=True);assert p.returncode==2 and not p.stdout;count+=1
out={'status':'PASS','separate_cli_cases':count,'no_network':True};(ROOT/'build/stage8-cli-results.json').write_text(json.dumps(out,indent=2)+'\n');print(json.dumps(out))
