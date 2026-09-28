"""Compare bounded vendor procedures; prove differences without physical I/O."""
import ctypes as C
import itertools
import json
from pathlib import Path
import random
import sys
from aml_power_oracle import PowerOracle
ROOT = Path(__file__).resolve().parents[2]
class Request(C.Structure):
    _fields_=[('pin',C.c_uint32),('value',C.c_uint32)]

lib=C.CDLL(str(Path(sys.argv[1]).resolve()))
lib.dizzass_aml_power_request.argtypes=[C.c_uint32,C.c_int,C.c_int,C.POINTER(Request)]
lib.dizzass_aml_reset_request.argtypes=[C.c_uint32,C.c_uint32,C.c_int,C.POINTER(Request)]
lib.dizzass_thermal_cutoff.argtypes=[C.c_int32]*4
for f in ('dizzass_aml_power_request','dizzass_aml_reset_request','dizzass_thermal_cutoff'):
    getattr(lib,f).restype=C.c_int
oracle=PowerOracle()
counts={}
assert oracle.pins==(454,455,456)
for chips in (1,2,64,108,128,255,256):
    route=oracle.select(chips)
    assert route=={'0x654b08':2,'0x654b0c':4,'0x654b14':chips,'0x654b28':0x11b750,
                  '0x654b44':0x11b6c8,'0x654b5c':0x11bc14,'0x654b74':0x11c5c0,
                  '0x654b78':0x11c978,'0x654b7c':0x11ca74}
counts['original_callback_routes']=7
n=0
for initialized,enable,status in itertools.product((0,1,2,255),(0,1),(0,-1,1,-7)):
    rc,trace=oracle.gate(initialized,enable,status)
    assert rc==(0 if not initialized==1 and not enable else -1 if initialized!=1 or status else 0)
    assert trace==([(437,1-enable)] if initialized==1 else [])
    r=Request(0xa5a5a5a5,0xa5a5a5a5)
    port=lib.dizzass_aml_power_request(2,initialized,enable,C.byref(r))
    if initialized==1:
        assert port==0 and (r.pin,r.value)==trace[0]
    else:
        assert port<0 and (r.pin,r.value)==(0xa5a5a5a5,0xa5a5a5a5)
    n+=1
counts['original_gate_cases']=n
n=0
for chain,asserted,status in itertools.product((0,1,2,3,0xffffffff),(0,1),(0,-1,7)):
    rc,trace=oracle.reset_chain(chain,asserted,status)
    assert (rc,trace)==((status,[(454+chain,1-asserted)]) if chain<3 else (-1,[]))
    r=Request();port=lib.dizzass_aml_reset_request(2,chain,asserted,C.byref(r))
    if chain<3:assert port==0 and (r.pin,r.value)==trace[0]
    else:assert port<0
    n+=1
counts['original_chain_reset_cases']=n
n=0
for initialized in (0,1):
    for mask in range(16):
        statuses=tuple(-1 if mask&(1<<i) else 0 for i in range(4))
        rc,trace,fields=oracle.shutdown(initialized,statuses)
        if initialized and statuses[0]:
            assert (rc,trace,fields)==(-1,[(437,1)],(1,123))
        else:
            assert rc==0 and fields==(0,0)
            assert trace==([(437,1)] if initialized else [])+[(454,0),(455,0),(456,0)]
        n+=1
counts['original_shutdown_cases']=n
n=0
for opened,printf_status,close_status,level in itertools.product((False,True),(-1,0,1),(-1,0),(0,1,9)):
    rc,trace=oracle.gpio_stdio(opened,printf_status,close_status,level)
    assert rc==(0 if opened else -1)
    assert trace==[('format',437),('open',)]+([('write',int(bool(level))),('close',)] if opened else [])
    n+=1
counts['original_stdio_cases']=n
values=(-2147483648,-1,0,79,80,89,90,2147483647)
vectors=list(itertools.product(values,values,(-1,80,2147483647),(-1,90,2147483647)))
rng=random.Random(437454)
vectors += [tuple(rng.randrange(-2147483648,2147483648) for _ in range(4)) for _ in range(256)]
for pcb,chip,pl,cl in vectors:
    expected=1 if pcb>=pl else 2 if chip>=cl else 0
    rc,trace=oracle.thermal(pcb,chip,pl,cl)
    assert lib.dizzass_thermal_cutoff(pcb,chip,pl,cl)==expected
    assert rc==(-1 if expected else 0)
    assert trace==([('stop_chain',),('secondary_action',),('event',3001+expected,pcb if expected==1 else chip)] if expected else [])
counts['original_thermal_cases']=len(vectors)
counts['hardware_access']=False
print('AML_POWER_ORIGINAL_PASS '+json.dumps(counts,sort_keys=True))
print('ORIGINAL_OFF_UNINITIALIZED=success_without_GPIO')
print('ORIGINAL_GPIO_STDIO_FAILURE=ignored_after_successful_open')
print('ORIGINAL_SHUTDOWN_RESET_FAILURES=ignored')
