#!/usr/bin/env python3
"""Compare new C helpers against ORIGINAL A32 slices, offline and bounded.

Scope: argument transformations up to SET_CONFIG; packet bytes up to transport;
CRC5 function. No claim about hardware, side effects, logging or full functions.
"""
from pathlib import Path
import ctypes as C
import hashlib,json,random,sys,time
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'tools'))
from elf32 import ELF32
from arm32_subset import ARM32
EXPECTED='b2663b3aa753cc14ae9d3b11a14d3d93c74b605a3e433b02101c3c17c69d95e9'
binary=ROOT/'reference/cgminer.vendor.elf'
assert hashlib.sha256(binary.read_bytes()).hexdigest()==EXPECTED,'Wrong reference binary'
lib=C.CDLL(str(ROOT/'build/libvn135_recovered.so'))
u32=C.c_uint32;u8=C.c_uint8;sz=C.c_size_t
for name,n in [('ticket_mask',1),('sweep_clock',2),('clock_delay',3),('analog_mux',1),('misc_control',2)]:
    f=getattr(lib,'vn135_bm1398_'+name+'_word');f.argtypes=[u32]*n;f.restype=u32
lib.vn135_crc5_bits.argtypes=[C.POINTER(u8),sz,sz,C.POINTER(u8)]
lib.vn135_crc5_bits.restype=C.c_int
lib.vn135_bm1398_set_config_packet.argtypes=[u32,u32,u32,u32,C.POINTER(u8),sz]
lib.vn135_bm1398_set_config_packet.restype=C.c_int
m=ARM32(ELF32(binary));rng=random.Random(0x135)
ctx=m.DATA_BASE+0x1000;chip=m.DATA_BASE+0x2000
counts={};start=time.monotonic()

def record(name):counts[name]=counts.get(name,0)+1

def command(entry,args,*,hooks=None):
    m.reset(args);m.run(entry,stop=0xee8e4,hooks=hooks)
    return (m.r[0],m.r[1],m.r[2],m.r[3],m.read(m.r[13]))

# Exhaustively cover each input byte, plus values with non-zero high bits.
for x in list(range(256))+[rng.getrandbits(32) for _ in range(128)]:
    got=command(0xeb750,(ctx,x));want=lib.vn135_bm1398_ticket_mask_word(x)
    assert got==(ctx,1,0,0x14,want),(hex(x),got,want)
    record('ticket-mask argument slice')

for a,b in [(a,b) for a in range(8) for b in range(16)]+[(rng.getrandbits(32),rng.getrandbits(32)) for _ in range(128)]:
    got=command(0xec9f0,(ctx,a,b));want=lib.vn135_bm1398_sweep_clock_word(a,b)
    assert got==(ctx,1,0,0x3c,want),(a,b,got,want)
    record('sweep-clock argument slice')

for a,b,c in [(a,b,c) for a in range(8) for b in range(8) for c in range(4)]+[tuple(rng.getrandbits(32) for _ in range(3)) for _ in range(128)]:
    want=lib.vn135_bm1398_clock_delay_word(a,b,c)
    assert command(0xecca0,(ctx,a,b,c))==(ctx,1,0,0x3c,want)
    assert command(0xecb68,(ctx,chip,a,b,c))==(ctx,1,chip,0x3c,want)
    record('clock-delay argument slice, null context')
    record('clock-delay argument slice, chip context')

for x in list(range(32))+[rng.getrandbits(32) for _ in range(128)]:
    assert command(0xece3c,(ctx,x))==(ctx,1,0,0x54,lib.vn135_bm1398_analog_mux_word(x))
    record('analog-mux argument slice')

for old in [0,0xffffffff,0x00400000,0xf0000000]+[rng.getrandbits(32) for _ in range(128)]:
    for active in (0,1,2,0xffffffff):
        def cache(mm):
            assert mm.r[1]==0x18
            mm.write(mm.r[2],old);mm.r[0]=0
        got=command(0xecf64,(ctx,active),hooks={0x107188:cache})
        assert got==(ctx,1,0,0x18,lib.vn135_bm1398_misc_control_word(old,active))
        record('misc-control transform after injected successful cache read')

# CRC widths include non-byte-aligned bit counts and zero-length input.
for nbits in list(range(81))*2+[rng.randrange(0,513) for _ in range(32)]:
    nbytes=(nbits+7)//8;data=bytes(rng.randrange(256) for _ in range(nbytes))
    buf=(u8*max(1,nbytes))(*data);out=u8()
    assert lib.vn135_crc5_bits(buf,nbytes,nbits,C.byref(out))==0
    m.reset((m.DATA_BASE,nbits));m.mem[m.DATA_BASE:m.DATA_BASE+nbytes]=data
    original=m.run(0xf7f10)
    assert original==out.value,(nbits,data.hex(),original,out.value)
    record('CRC5 complete function')

# Entire SET_CONFIG encoding, original CRC included, stops BEFORE transport.
packet_vectors=[]
for mode in (0,1,2,0xffffffff):
    for index in range(64):
        address=rng.getrandbits(32);reg=rng.getrandbits(32);value=rng.getrandbits(32)
        chip_ptr=chip if index%2 else 0
        m.reset((ctx,mode,chip_ptr,reg,value));m.write(chip+4,address)
        m.run(0xee8e4,stop=0xd26ac)
        assert m.r[0]==ctx and m.r[2]==9
        original=bytes(m.mem[m.r[1]:m.r[1]+9])
        out=(u8*9)()
        assert lib.vn135_bm1398_set_config_packet(mode,address if chip_ptr else 0,reg,value,out,9)==0
        assert original==bytes(out),(mode,address,reg,value,original.hex(),bytes(out).hex())
        record('SET_CONFIG packet through original CRC, before transport')
        if len(packet_vectors)<8:
            packet_vectors.append(dict(mode=mode,chip_address=address if chip_ptr else 0,register=reg,value=value,packet_hex=original.hex()))

result={'reference_sha256':EXPECTED,'passed':True,'cases':counts,'total_cases':sum(counts.values()),
        'elapsed_seconds':round(time.monotonic()-start,3),'method':'New host C versus bounded local A32 instruction interpreter on original ELF',
        'hardware_tested':False,'full_miner_tested':False,'packet_vectors':packet_vectors,
        'limits':['Local subset interpreter, not a hardware or independently certified ARM emulator.',
                  'Payload-building prefixes do not verify full callers, error paths, timing or hardware effects.',
                  'Cache read for misc-control is a declared test input, not reconstructed cache implementation.',
                  'No equivalence claim for untested inputs, ABI, vendor data structures, full transport, full PLL programming or autotune.']}
(ROOT/'build/differential-results.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps({'passed':True,'total_cases':result['total_cases'],'cases':counts,'seconds':result['elapsed_seconds']},indent=2))
