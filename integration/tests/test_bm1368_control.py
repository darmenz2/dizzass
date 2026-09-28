#!/usr/bin/env python3
"""C helpers against bounded original instructions and independent CRC bits."""
import ctypes as C
from pathlib import Path
import random
import sys
from bm1368_control_oracle import ControlOracle

U8=C.c_uint8; U32=C.c_uint32; SIZE=C.c_size_t
READ=C.CFUNCTYPE(C.c_int,C.c_void_p,U8,C.POINTER(U32))
WRITE=C.CFUNCTYPE(C.c_int,C.c_void_p,U8,U32)
WAIT=C.CFUNCTYPE(C.c_int,C.c_void_p,U32)
class Ops(C.Structure):
    _fields_=[('context',C.c_void_p),('read',READ),('write',WRITE),('wait',WAIT)]
class Result(C.Structure):
    _fields_=[('completed',U32),('failed_step',U32),('callback_status',C.c_int)]

def independent_crc(data,bits):
    state=31
    for bit in range(bits):
        feedback=((state>>4)^((data[bit//8]>>(7-bit%8))&1))&1
        state=((state<<1)&31)^(5 if feedback else 0)
    return state

def main(path):
    lib=C.CDLL(str(Path(path).resolve())); oracle=ControlOracle()
    encode=lib.dizzass_bm1368_command_encode
    encode.argtypes=[C.c_int,U32,U32,U32,U32,C.POINTER(U8),SIZE,C.POINTER(SIZE)]
    encode.restype=C.c_int
    crc=lib.dizzass_bm1368_reply_crc5
    crc.argtypes=[U32,U32,C.POINTER(U8),SIZE];crc.restype=C.c_int
    reset=lib.dizzass_bm1368_reset_cores
    reset.argtypes=[C.POINTER(Ops),U32,U32,U32,C.POINTER(Result)];reset.restype=C.c_int
    # Golden opcode layouts taken from the original delay converter. Check
    # aliases and NZCV preservation before relying on the two added opcodes.
    m=oracle.m
    for a in (0,1,0x7fffffff,0x80000000,0xffffffff):
        for b in (0,1,0x7fffffff,0x80000000,0xffffffff):
            m.reset((a,0,b));m.n,m.z,m.c,m.v=True,False,True,True
            assert m.extra_instruction(0xe0853290,0x10ed98)
            assert (m.r[3],m.r[5])==((a*b)&0xffffffff,(a*b)>>32)
            assert (m.n,m.z,m.c,m.v)==(True,False,True,True)
            m.reset((0x12345678,));m.r[4]=a;m.r[5]=b
            m.n,m.z,m.c,m.v=True,False,True,True
            assert m.extra_instruction(0xe0640495,0x10edb8)
            assert m.r[4]==(0x12345678-a*b)&0xffffffff
            assert (m.n,m.z,m.c,m.v)==(True,False,True,True)
    try:
        m.extra_instruction(0xe0953290,0x10ed98) # UMULLS intentionally unsupported
    except ValueError:
        pass
    else:
        raise AssertionError('Unsupported multiply was accepted')
    assert oracle.dispatch_and_delay()==(4,5)
    rng=random.Random(13681368)
    packets=crc_vectors=flipped=sequences=faults=0
    vectors=[(0,0,0,0,0)]+[(1,0,a,0,0) for a in range(256)]
    vectors += [(k,b,rng.randrange(256),rng.randrange(256),rng.getrandbits(32) if k==3 else 0)
                for k in (2,3) for b in (0,1) for _ in range(64)]
    for kind,bcast,addr,reg,value in vectors:
        out=(U8*13)(*([0xa5]*13));size=SIZE(999)
        assert encode(kind,bcast,addr,reg,value,out,11,C.byref(size))==0
        packet=bytes(out[:size.value])
        assert packet==oracle.command(kind,bcast,addr,reg,value)
        assert packet[-1]==independent_crc(packet[2:-1],(len(packet)-3)*8)
        assert bytes(out[size.value:])==bytes([0xa5])*(13-size.value)
        packets+=1
    for n in range(256):
        payload=bytearray(rng.randbytes(9));payload[8]&=0xe0
        checksum=oracle.crc(payload,67)
        assert checksum==independent_crc(payload,67)
        payload[8]|=checksum
        assert oracle.crc(payload,72)==0
        buf=(U8*9).from_buffer_copy(payload)
        assert crc(4,2,buf,9)==0
        for bit in range(72):
            bad=bytearray(payload);bad[bit//8]^=1<<(bit%8)
            assert crc(4,2,(U8*9).from_buffer_copy(bad),9)==-802
            flipped+=1
        crc_vectors+=1

    def c_reset(misc,soft,fast,clock,pulse,fail_step=0):
        regs={0x18:misc,0xa8:soft};events=[]
        def failed(): return fail_step==len(events)
        def read(_,reg,out):
            events.append(('read',reg,regs[reg]))
            if failed(): return -77
            out[0]=regs[reg];return 0
        def write(_,reg,value):
            events.append(('write',reg,value))
            if failed(): return -77
            regs[reg]=value;return 0
        def wait(_,ms):
            events.append(('wait',ms,0))
            return -77 if failed() else 0
        funcs=(READ(read),WRITE(write),WAIT(wait))
        ops=Ops(None,*funcs);result=Result(99,99,99)
        rc=reset(C.byref(ops),fast,clock,pulse,C.byref(result))
        return rc,events,result

    for fast in (0,1):
        for clock in range(8):
            for pulse in range(4):
                misc,soft=rng.getrandbits(32),rng.getrandbits(32)
                original=oracle.reset(misc,soft,fast,clock,pulse)
                rc,events,result=c_reset(misc,soft,fast,clock,pulse)
                assert original['rc']==rc==0
                assert original['events']==events
                assert (result.completed,result.failed_step,result.callback_status)==(16,0,0)
                writes=[e for e in events if e[0]=='write']
                assert len(writes)==len(original['packets'])==7
                for (_,reg,value),packet in zip(writes,original['packets']):
                    buf=(U8*11)();size=SIZE()
                    assert encode(3,0,32,reg,value,buf,11,C.byref(size))==0
                    assert bytes(buf)==packet
                sequences+=1
    for step in range(1,17):
        rc,events,result=c_reset(0x12345678,0x98765432,0,3,2,step)
        assert rc==-812 and len(events)==step
        assert (result.completed,result.failed_step,result.callback_status)==(step-1,step,-77)
        faults+=1
    original=oracle.reset(0x12345678,0x98765432,0,3,2,fail_write=1)
    assert original['rc']==0 and len(original['packets'])==7 and len(original['logs'])>=1
    print(f'BM1368_CONTROL_ORIGINAL_PASS commands={packets} crc_vectors={crc_vectors} '
          f'bit_corruptions={flipped} reset_traces={sequences} fail_fast_steps={faults} '
          'dispatch_entries=4 delay_vectors=5 original_continues_after_first_write_error=yes hardware=no')

if __name__=='__main__':
    if len(sys.argv)!=2: raise SystemExit('usage: test_bm1368_control.py LIBRARY.so')
    main(sys.argv[1])
