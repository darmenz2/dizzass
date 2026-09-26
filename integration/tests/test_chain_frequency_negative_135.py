#!/usr/bin/env python3
"""Each compiled semantic mutant must be rejected by the original oracle."""
import argparse,json,subprocess,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
def main():
    ap=argparse.ArgumentParser();ap.add_argument('--cc',default='cc');ap.add_argument('--out',required=True);args=ap.parse_args()
    out=Path(args.out).resolve();out.mkdir(parents=True,exist_ok=True)
    src=(ROOT/'src/backend/chain-frequency.c').read_text()
    mutations={
        'inactive-state-five':('(c->state-3u)<3u','(c->state-3u)<2u'),
        'first-error-success':('return -1;','return 0;'),
        'count-before-lock':('(void)ops->lock(opaque,chain);\n    count=frequency_signed(chain->detected_8c);','count=frequency_signed(chain->detected_8c);\n    (void)ops->lock(opaque,chain);'),
        'rounded-cache':('return (int32_t)x;','return (int32_t)(x+0.5);'),
        'inclusive-450':('cleared_words[0])<450','cleared_words[0])<=450'),
        'reversed-pulse-arguments':('chain,word_10,word_20,1u','chain,word_20,word_10,1u'),
        'late-method-owner':('methods=view->methods;\n    if(ops->platform(opaque)!=4u)return 0;','if(ops->platform(opaque)!=4u)return 0;\n    methods=view->methods;'),
        'lost-mean':('c->cleared_words[2]=(uint32_t)(bits>>32);','c->cleared_words[2]=0;'),
    }
    for name,(old,new) in mutations.items():
        assert old in src,name
        text=src.replace(old,new,1);c=out/(name+'.c');lib=out/(name+'.so');c.write_text(text)
        build=subprocess.run([args.cc,'-I.', '-std=c11','-O1','-g','-Wall','-Wextra','-Werror','-fno-fast-math','-ffp-contract=off','-DVN135_CHAIN_FREQUENCY_135','-shared','-fPIC',str(c),'-Wl,-z,defs','-o',str(lib)],cwd=ROOT,capture_output=True,text=True,timeout=30)
        assert build.returncode==0,(name,'compile failure is not a rejection',build.stderr)
        run=subprocess.run([sys.executable,'integration/tests/test_chain_frequency_135.py',str(lib),'--quick'],cwd=ROOT,capture_output=True,text=True,timeout=30)
        (out/(name+'.log')).write_text(run.stdout+run.stderr)
        assert run.returncode!=0 and 'CHAIN_FREQUENCY135_MISMATCH' in run.stdout,(name,run.stdout,run.stderr)
    print('CHAIN_FREQUENCY135_NEGATIVE_PASS',json.dumps({'rejected':len(mutations),'compiler':args.cc}))
if __name__=='__main__':main()
