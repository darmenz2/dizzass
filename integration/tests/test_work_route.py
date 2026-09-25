"""Compare compiled route/TX88 functions with original instructions."""
from pathlib import Path
import binascii
import ctypes as C
import random
import sys
from work_route_oracle import WorkRouteOracle
from tx88_oracle import Tx88Oracle

def main(path):
    lib = C.CDLL(str(Path(path).resolve()))
    route = lib.dizzass_work_route_select
    route.argtypes = [C.c_uint32, C.c_uint32, C.POINTER(C.c_int)]
    route.restype = C.c_int
    enc = lib.dizzass_tx88_encode_words
    enc.argtypes = [C.c_void_p, C.c_size_t, C.c_uint32, C.c_void_p, C.c_size_t]
    enc.restype = C.c_int
    crc = lib.dizzass_tx88_crc16
    crc.argtypes = [C.c_void_p, C.c_size_t, C.c_uint16, C.POINTER(C.c_uint16)]
    crc.restype = C.c_int
    oracle = WorkRouteOracle()
    names = {b'sha256d': 0, b'scrypt': 1, b'': 2, b'SHA256D': 2,
             b'sha256': 2, b'scrypt ': 2, b'x'*128: 2}
    for name, expected in names.items():
        assert oracle.algorithm(name) == expected
    for chip in range(8):
        for bypass in (0, 1):
            assert oracle.caller_platform(chip, 108, bypass) == (2, chip, 108)
    mapping = {0xbfce8: 1, 0xc3b54: 2, 0xc1c0c: 3}
    for platform in range(5):
        for algorithm in range(2):
            result = C.c_int(99)
            assert route(platform, algorithm, C.byref(result)) == 0
            assert result.value == mapping[oracle.select(platform, algorithm)[0]]
    for platform, algorithm in [(5,0),(0xffffffff,0),(2,2),(2,0xffffffff)]:
        result = C.c_int(99)
        assert route(platform, algorithm, C.byref(result)) == -401
        assert result.value == 99
    assert route(2,0,None) == -400
    assert oracle.worker_entries(oracle.select(2,0)[0]) == (0xc4054,0xc2498,0xc4b18)
    assert oracle.worker_entries(oracle.select(2,1)[0]) == (0xc0018,)
    table = oracle.shared_slot_table()
    packet_oracle = Tx88Oracle()
    rng = random.Random(0x882026)
    packets = 0
    for slot in range(32):
        for i in range(4):
            header = rng.randbytes(80)
            inp = C.create_string_buffer(header,80)
            out = C.create_string_buffer(b'\xa5'*94,94)
            assert enc(inp,80,slot,C.byref(out,3),88) == 0
            packet = out.raw[3:91]
            assert packet == packet_oracle.frame(header,slot)
            assert packet[:10] == bytes([0x55,0xaa,0x21,0x36,slot<<3,1,0,0,0,0])
            assert packet[10:86] == header[:76][::-1]
            assert int.from_bytes(packet[86:88],'big') == binascii.crc_hqx(packet[2:86],0xffff)
            assert out.raw[:3] == out.raw[91:] == b'\xa5'*3
            packets += 1
    crc_cases = 0
    for size in (0,1,2,3,7,16,31,64,84,255,1024,4096):
        for seed in (0,0xffff,0x1234):
            data = rng.randbytes(size)
            inp = C.create_string_buffer(data or b'\0')
            out = C.c_uint16()
            assert crc(inp,size,seed,C.byref(out)) == 0
            assert out.value == packet_oracle.crc(data,seed) == binascii.crc_hqx(data,seed)
            crc_cases += 1
    print(f'WORK_ROUTE_ORIGINAL_PASS names={len(names)} caller_snapshots=16 selections=10 worker_sets=2 shared_table=0x{table:x}')
    print(f'TX88_ORIGINAL_PASS packets={packets} crc={crc_cases}')
if __name__ == '__main__':
    if len(sys.argv) != 2:
        raise SystemExit('usage: test_work_route.py SHARED_LIBRARY')
    main(sys.argv[1])
