"""Bounded original command/reset/CRC instructions, not a firmware process.
Cache, transport, waits and logging are explicit hooks in reset sequencing.
Command encoders execute the original CRC, stopping before hardware transport.
"""
from pathlib import Path
import hashlib
import sys
ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'tools'))
from elf32 import ELF32
from arm32_nonce_subset import ARM32Nonce

ELF_SHA256 = 'b2663b3aa753cc14ae9d3b11a14d3d93c74b605a3e433b02101c3c17c69d95e9'

class ControlARM(ARM32Nonce):
    """Only adds the non-flag-setting UMULL/MLS used by delay conversion.
    Unlike generic data processing, other multiply-family encodings fail.
    Historical interpreter code is not modified by this scoped extension.
    """
    def extra_instruction(self, word, pc):
        op=word & 0x0ff000f0
        if op==0x00800090:  # UMULL RdLo,RdHi,Rm,Rs (S=0)
            hi,lo,rs,rm=(word>>16)&15,(word>>12)&15,(word>>8)&15,word&15
            if 15 in (hi,lo,rs,rm) or hi==lo:
                raise ValueError('Unsupported UMULL operands')
            value=self.get(rm,pc)*self.get(rs,pc)
            self.r[lo]=value&0xffffffff;self.r[hi]=(value>>32)&0xffffffff
            return True
        if op==0x00600090:  # MLS Rd,Rm,Rs,Ra
            rd,ra,rs,rm=(word>>16)&15,(word>>12)&15,(word>>8)&15,word&15
            if 15 in (rd,ra,rs,rm):
                raise ValueError('Unsupported MLS operands')
            value=self.get(ra,pc)-self.get(rm,pc)*self.get(rs,pc)
            self.r[rd]=value&0xffffffff
            return True
        if word & 0x0f0000f0==0x00000090 and word & 0x0fc000f0!=0x00000090:
            raise ValueError('Unsupported multiply-family encoding')
        return super().extra_instruction(word,pc)

class ControlOracle:
    def __init__(self):
        self.elf = ELF32(ROOT / 'reference/cgminer.vendor.elf')
        if hashlib.sha256(self.elf.data).hexdigest() != ELF_SHA256:
            raise ValueError('Unexpected reference ELF')
        self.m = ControlARM(self.elf)

    def dispatch_and_delay(self):
        m=self.m
        m.reset((m.DATA_BASE,))
        m.run(0xe1450,max_steps=5000)
        expected={0x20:0xe1b5c,0x24:0xe1b64,0xb4:0xe47b8,0xb8:0xe48fc}
        for offset,address in expected.items():
            if m.read(m.DATA_BASE+offset)!=address:
                raise ValueError('Original BM1368 callback mismatch')
        for milliseconds in (1,5,10,1000,1234):
            m.reset((milliseconds,))
            m.run(0x10ed2c,stop=0x10ee24,max_steps=5000)
            ptr=m.r[0]
            if (m.read(ptr),m.read(ptr+4),m.read(ptr+8)) != (
                    milliseconds//1000,0,(milliseconds%1000)*1000000):
                raise ValueError('Unexpected original delay units')
        return len(expected),5

    def crc(self, data, bits):
        if not 0 < len(data) <= 16 or not 0 <= bits <= len(data)*8:
            raise ValueError('Outside bounded CRC test domain')
        m = self.m
        m.reset((m.DATA_BASE, bits))
        m.mem[m.DATA_BASE:m.DATA_BASE+len(data)] = data
        return m.run(0xf7f10, max_steps=10000)

    def command(self, kind, broadcast, address, reg, value):
        m = self.m
        board, chip = m.DATA_BASE, m.DATA_BASE + 256
        if kind == 0:
            args, start, stop = (board,), 0xe47b8, 0xe47f8
        elif kind == 1:
            args, start, stop = (board, chip), 0xe48fc, 0xe494c
        elif kind == 2:
            args, start, stop = (board, broadcast, chip, reg), 0xd253c, 0xd25a4
        elif kind == 3:
            args, start, stop = (board, broadcast, chip, reg, value), 0xe4a74, 0xe4b04
        else:
            raise ValueError('Unknown command')
        m.reset(args)
        m.write(board+0x18, 2)
        m.write(chip, 3)
        m.write(chip+4, address)
        m.run(start, stop=stop, max_steps=10000)
        ptr, size = m.r[1:3]
        if size not in (5,9):
            raise ValueError(f'Unexpected original command size {size}')
        return b'\x55\xaa' + bytes(m.mem[ptr:ptr+size])

    def reset(self, misc, soft, fast, clock, pulse, fail_write=0):
        m = self.m
        board, chip = m.DATA_BASE, m.DATA_BASE+256
        m.reset((board,chip,fast,0,clock,pulse))
        m.write(board+0x18,2)
        m.write(chip,3)
        m.write(chip+4,0x20)
        regs = {0x18:misc, 0xa8:soft}
        events, packets, cached_writes, logs = [], [], [], []
        def read_cached(x):
            chain,index,reg,ptr = x.r[:4]
            if (chain,index) != (2,3) or reg not in regs:
                raise ValueError('Unexpected cache read')
            events.append(('read',reg,regs[reg]))
            x.write(ptr,regs[reg]); x.r[0]=0
        def send(x):
            b,ptr,size = x.r[:3]
            if b != board or size != 9:
                raise ValueError('Unexpected reset transport')
            packet=bytes(x.mem[ptr:ptr+size])
            packets.append(b'\x55\xaa'+packet)
            events.append(('write',packet[3],int.from_bytes(packet[4:8],'big')))
            x.r[0]=0xffffffff if fail_write == len(packets) else 0
        def write_cached(x):
            chain,index,reg,value=x.r[:4]
            if (chain,index)!=(2,3): raise ValueError('Unexpected cache write')
            regs[reg]=value; cached_writes.append((reg,value)); x.r[0]=0
        def wait(x):
            events.append(('wait',x.r[0],0)); x.r[0]=0
        def log(x):
            logs.append(x.r[3]); x.r[0]=0
        hooks={0x1079f0:read_cached,0x107ed0:write_cached,
               0xd26ac:send,0x10ed2c:wait,0xfa0c4:log}
        rc=m.run(0xe1b64,hooks=hooks,max_steps=30000)
        return dict(rc=rc, events=events, packets=packets, cached_writes=cached_writes,
                    logs=logs, steps=m.steps)

if __name__ == '__main__':
    o=ControlOracle()
    for kind in range(4):
        print(kind, o.command(kind,0,0 if kind==0 else 32,0 if kind<2 else 24,0 if kind<3 else 0x12345678).hex())
    for fast in (0,1):
        for fail in (0,1):
            x=o.reset(0x12345678,0x98765432,fast,3,2,fail)
            print('RESET',fast,fail,x['rc'],x['events'],len(x['packets']),len(x['logs']),x['steps'])
