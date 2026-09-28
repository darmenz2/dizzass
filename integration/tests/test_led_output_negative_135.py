#!/usr/bin/env python3
"""Require actual compiled semantic mismatches against unchanged ARM bytes."""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT/'libbitmain/src/led-output.c'
MUTATIONS = {
    'clear_requires_exact_one': ('state->ready == 0', 'state->ready != 1'),
    'set_accepts_any_nonzero': ('state->ready != 1', 'state->ready == 0'),
    'clear_wrong_level': ('state->pins[0], 0);', 'state->pins[0], 1);'),
    'set_wrong_first_pin': ('state->pins[0], 1);', 'state->pins[1], 1);'),
    'clear_skips_second': ('if (selector == 1 || selector == 2)\n        (void)ops->set_value(context, state->pins[1], 0);',
        'if (selector == 1)\n        (void)ops->set_value(context, state->pins[1], 0);'),
    'clear_rechecks_ready': ('if (selector == 1 || selector == 2)\n        (void)ops->set_value(context, state->pins[1], 0);',
        'if (state->ready && (selector == 1 || selector == 2))\n        (void)ops->set_value(context, state->pins[1], 0);'),
    'clear_truncates_selector': ('if (state->ready == 0)', 'selector &= 255u;\n    if (state->ready == 0)'),
    'clear_stops_on_error': ('(void)ops->set_value(context, state->pins[0], 0);',
        'if (ops->set_value(context, state->pins[0], 0)) return;'),
    'gpio_replaced_by_success': ('return vn135_gpio_set_value_135((const struct vn135_gpio_io *)context,\n        pin, value);',
        '(void)context; (void)pin; (void)value; return 0;'),
    'routing_swaps_clear_and_set': ('if (entry == 0xf98b8u)\n        vn135_led_clear_135',
        'if (entry == 0xf9840u)\n        vn135_led_clear_135'),
}
FLAGS = ['-I.','-std=c11','-O1','-g','-Wall','-Wextra','-Wpedantic','-Werror',
         '-fno-fast-math','-ffp-contract=off','-DVN135_LED_OUTPUT_135',
         '-DVN135_GENERAL_MONITOR_135','-DVN135_MONITOR_HANDLERS_135',
         '-DVN135_BACKEND_SHUTDOWN_135','-DVN135_STOP_POLICY_135','-DVN135_EXIT_CLEANUP_135']

def main():
    ap=argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--cc',default='cc');ap.add_argument('--out',type=Path,required=True)
    args=ap.parse_args();out=args.out.resolve();out.mkdir(parents=True,exist_ok=True)
    original=SOURCE.read_text();records=[]
    for name, mutation in [('baseline',None),*MUTATIONS.items()]:
        candidate=original
        if mutation:
            old,new=mutation
            assert candidate.count(old)==1,(name,'ambiguous replacement')
            candidate=candidate.replace(old,new)
        source=out/(name+'.c');library=out/(name+'.so');source.write_text(candidate)
        build=subprocess.run([args.cc,*FLAGS,'-shared','-fPIC',str(source),
             'libbitmain/src/gpio.c','src/backend/base.c','-Wl,-z,defs','-o',str(library)],
             cwd=ROOT,text=True,capture_output=True,timeout=40)
        (out/(name+'.build.log')).write_text(build.stdout+build.stderr)
        if build.returncode: raise RuntimeError((name,'did not compile',build.stderr))
        run=subprocess.run(['python3','integration/tests/test_led_output_135.py',str(library),'--quick'],
             cwd=ROOT,text=True,capture_output=True,timeout=40)
        (out/(name+'.log')).write_text(run.stdout+run.stderr)
        if mutation:
            if run.returncode!=1 or 'MISMATCH' not in run.stderr:
                raise RuntimeError((name,'not a semantic rejection',run.returncode,run.stdout,run.stderr))
        elif run.returncode or 'LED_OUTPUT135_ORIGINAL_PASS' not in run.stdout:
            raise RuntimeError((name,'baseline failed',run.returncode,run.stderr))
        records.append(dict(name=name,build_exit=0,test_exit=run.returncode))
    report=dict(status='PASS',compiler=args.cc,rejected=len(MUTATIONS),
                source_sha256=hashlib.sha256(SOURCE.read_bytes()).hexdigest(),records=records)
    (out/'results.json').write_text(json.dumps(report,indent=2)+'\n')
    print('LED_OUTPUT135_NEGATIVE_PASS',json.dumps(report))
if __name__=='__main__':main()
