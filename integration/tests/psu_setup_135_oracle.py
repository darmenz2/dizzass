"""Bounded execution of original 1.3.5 PSU setup instructions.

Only the added finite, nearest/even VFP and extend instructions are modeled.
No original firmware process, hardware I/O, floating exception emulation, or
claim of independent ARM certification. Historic interpreters are unchanged.
"""
import math
import struct
import hashlib
import json
from pathlib import Path
from psu_protocol_135_oracle import Oracle, PSUArm, signed

from arm32_freshness_subset import ARM32Freshness

class SetupArm(PSUArm,ARM32Freshness):
    def extra_instruction(self,w,pc):
        if not any(a <= pc < b for a,b in self.allowed):
            raise ValueError('Unexpected setup PC '+hex(pc))
        self.visited.add(pc)
        if getattr(self,'observe',None):self.observe(pc)
        if hasattr(self,'pcs'): self.pcs.append(pc)
        # VLDR/VSTR single, immediate offset; no writeback/multiple transfer.
        if w & 0x0f200f00 == 0x0d000a00:
            rn=(w>>16)&15; sd=((w>>12)&15)*2+((w>>22)&1)
            addr=self.get(rn,pc)+((w&255)*4 if w&(1<<23) else -(w&255)*4)
            if w & (1<<20): self.s[sd]=self.read(addr,4)
            else: self.write(addr,self.s[sd],4)
            return True
        dn=((w>>12)&15)+(((w>>22)&1)*16)
        mn=(w&15)+(((w>>5)&1)*16)
        # VCMPE double/single against zero. FP exception flags not modeled.
        if w & 0x0fbf0fff in (0x0eb50bc0,0x0eb50ac0):
            if (w>>8)&15 == 11: v=self.d(dn)
            else:
                sn=((w>>12)&15)*2+((w>>22)&1)
                v=struct.unpack('<f',struct.pack('<I',self.s[sn]))[0]
            if not math.isfinite(v): raise ValueError('Non-finite setup comparison')
            self.fp_flags=(v<0.0,v==0.0,v>=0.0,False); return True
        unary=w&0x0fbf0fd0
        if unary==0x0eb10b40: # VNEG.f64, preserve all bits except sign
            self.set_dbits(dn,self.dbits(mn)^(1<<63)); return True
        if unary==0x0eb70bc0: # VCVT.f32.f64: default round-to-nearest/even
            sd=((w>>12)&15)*2+((w>>22)&1); v=self.d(mn)
            if not math.isfinite(v): raise ValueError('Non-finite narrowing')
            self.s[sd]=int.from_bytes(struct.pack('<f',v),'little'); return True
        # VMOV.f64 immediate: only the witnessed constants used by round().
        immed=w&0x0fbf0fff
        if immed in (0x0eb60b00,0x0ebe0b00,0x0eb70b00):
            self.set_d(dn,{0x0eb60b00:0.5,0x0ebe0b00:-0.5,0x0eb70b00:1.0}[immed]); return True
        if w&0x0fff0ff0==0x06bf0fb0: # REV16, independent halfwords
            rd=(w>>12)&15;rm=w&15
            if 15 in (rd,rm):raise ValueError('REV16 PC')
            v=self.r[rm];self.r[rd]=((v&0x00ff00ff)<<8)|((v&0xff00ff00)>>8);return True
        # Signed byte reversal and extension; source snapshotted before write.
        if w&0x0fff0ff0==0x06ff0fb0:
            rd=(w>>12)&15; rm=w&15
            if 15 in (rd,rm): raise ValueError('REVSH PC')
            v=self.r[rm]&65535;v=((v&255)<<8)|(v>>8)
            self.r[rd]=(v if v<32768 else v-65536)&0xffffffff; return True
        if w&0x0fff03f0==0x06bf0070:
            rd=(w>>12)&15; rm=w&15; rotate=((w>>10)&3)*8
            if 15 in (rd,rm): raise ValueError('SXTH PC')
            v=self.r[rm];v=((v>>rotate)|(v<<(32-rotate)))&0xffffffff if rotate else v
            v&=65535;self.r[rd]=(v if v<32768 else v-65536)&0xffffffff;return True
        if w&0x0ff003f0 in (0x06e00070,0x06f00070):
            rd=(w>>12)&15; rn=(w>>16)&15; rm=w&15; rotate=((w>>10)&3)*8
            if 15 in (rd,rn,rm): return super().extra_instruction(w,pc)
            v=self.r[rm];v=((v>>rotate)|(v<<(32-rotate)))&0xffffffff if rotate else v
            mask=255 if (w&0x0ff003f0)==0x06e00070 else 65535
            self.r[rd]=(self.r[rn]+(v&mask))&0xffffffff; return True
        return super().extra_instruction(w,pc)

class SetupOracle(Oracle):
    def __init__(self):
        super().__init__(); self.m=SetupArm(self.elf)
        self.setup_evidence=json.loads((Path(__file__).resolve().parents[1]/'evidence/psu_setup_135.json').read_text())
        assert self.setup_evidence['reference_sha256']==hashlib.sha256(self.elf.data).hexdigest()
        for r in self.setup_evidence['ranges']:
            a,b=int(r['start'],16),int(r['end_exclusive'],16)
            assert hashlib.sha256(self.elf.read(a,b-a)).hexdigest()==r['sha256']
        for r in self.setup_evidence['data']:
            assert hashlib.sha256(self.elf.read(int(r['address'],16),r['size'])).hexdigest()==r['sha256']
    def begin_setup(self, *, state=(34,0,0,0,0),mode=0,kind=0,address=16,
                    lower=10000,upper=15000,enabled=0,count=0,x=None,y=None,args=()):
        super().begin(mode,state,args,kind,address)
        m=self.m
        m.allowed += [(0xffff8,0x100878),(0x100f3c,0x1024b8),
                      (0x103058,0x104218),(0x596778,0x596818),(0x1024b8,0x102988),
                      (0x105d30,0x105f58),(0xf7e90,0xf7f10)]
        m.write(self.STATE+0x10,enabled,1)
        m.write(self.STATE+0x14,lower&0xffffffff)
        m.write(self.STATE+0x18,upper&0xffffffff)
        m.write(self.STATE+0x30,count)
        for base,values in ((0x38,x),(0xb0,y)):
            vals=values if values is not None else [1234.0+i for i in range(15)]
            assert len(vals)==15
            m.mem[self.STATE+base:self.STATE+base+120]=struct.pack('<15d',*vals)
        m.pcs=[];m.observe=None
    def tables(self):
        m=self.m
        return m.read(self.STATE+0x30),bytes(m.mem[self.STATE+0x38:self.STATE+0x128])
    def calibration(self,fmt,data,**kw):
        self.begin_setup(args=(self.RX,),**kw);m=self.m
        m.mem[self.RX:self.RX+len(data)]=data
        before=bytes(m.mem[self.STATE:self.STATE+0x134])
        rc=m.run(0x1004f8 if fmt=='A' else 0x1000f0,max_steps=50000)
        after=bytes(m.mem[self.STATE:self.STATE+0x134])
        # Only count/x/y may change; old tails must match actual original writes.
        assert before[:0x30]==after[:0x30] and before[0x34:0x38]==after[0x34:0x38]
        assert before[0x128:]==after[0x128:]
        return signed(rc),self.tables()
    def knots(self,fmt,count,**kw):
        self.begin_setup(args=(self.OUT,count&0xffffffff),**kw);m=self.m
        m.mem[self.OUT:self.OUT+128]=b'\xa5'*128
        rc=m.run(0x100438 if fmt=='A' else 0xffff8,max_steps=50000)
        return signed(rc),bytes(m.mem[self.OUT:self.OUT+128])
    def original_round(self,v):
        self.begin_setup();m=self.m;m.set_d(0,v)
        m.run(0x596778,max_steps=500)
        return m.dbits(0)
    def family(self,model):
        self.begin_setup(state=(model,0,0,0,0))
        return self.m.run(0x100f3c,max_steps=1000)
    def setup_log(self,m):
        line=m.r[3];a=b=0;data=b''
        if line in (957,1016):a=m.read(m.r[13]+8);b=m.read(m.r[13]+12)
        elif line in (515,519,540,868,1037,1069):a=m.read(m.r[13]+8)
        elif line in (768,813):data=bytes(m.mem[m.read(m.r[13]+8):m.read(m.r[13]+8)+17])
        elif line in (937,939):data=self.dumps[m.read(m.r[13]+8)]
        elif line not in (439,500,510,951,556,762,775,807,820,851,857,873,1045,1064,1077):
            raise ValueError('Unrecognized setup log '+str(line))
        self.events.append(('log',line,a,b,data));m.r[0]=0
    def operation(self,op,request=12000,scenario=None,initial=None,**kw):
        sc=scenario or {};rets=sc.get('returns',{});m=self.m
        self.begin_setup(args=(self.DEVICE,request),**kw)
        mode=kw.get('mode',0)
        size=40 if op=='initialize' else 14 if op=='extended' else 8 if op in ('identify','raw') or op=='dispatch' and not mode else 10
        if initial is None:initial=bytes([0xa7]*size)
        assert len(initial)==size
        if op=='initialize':
            m.r[1]=kw.get('lower',10000)&0xffffffff;m.r[2]=kw.get('upper',15000)&0xffffffff;m.r[3]=mode
            rxptr=m.STACK_TOP-76;entry=0x100fc4;stop=None
            m.write(self.STATE,0x55667788)
            m.write(self.STATE+0x128,0x11223344)
            m.mem[self.STATE+0x1d:self.STATE+0x2f]=b'old-serial-1234567'
            # Initializer calls extended helper with its own frame. Both of the
            # helper's alternative stack scratch locations are seeded explicitly.
            for a in (m.STACK_TOP-104-56,m.STACK_TOP-104-80):m.mem[a:a+14]=b'\xa9'*14
            auxptr=m.STACK_TOP-104-56 if mode==1 else m.STACK_TOP-104-80
        elif op=='extended':
            entry=0x1024b8;stop=None
            rxptr=m.STACK_TOP-56 if mode==1 else m.STACK_TOP-80
        elif op=='identify':
            # Start after the original bus/mutex prologue, not at a fictitious
            # whole-function entry. Seed the already-established frame exactly.
            m.r[13]=m.STACK_TOP-104;m.r[11]=m.STACK_TOP-8
            m.r[4]=self.DEVICE;m.r[6]=self.STATE
            m.write(m.STACK_TOP-4,m.RETURN)
            rxptr=m.r[13]+28;entry=0x10100c;stop=0x1015b4
        else:
            entry={'raw':0x103058,'float':0x103ae8,'dispatch':0x104134}[op];stop=None
            rxptr=m.STACK_TOP-64 if size==8 else m.STACK_TOP-52
            if op=='dispatch' and not mode:rxptr-=24
        m.mem[rxptr:rxptr+size]=initial
        runtime=BusScript(sc); aux_snapshot=[b'\xa9'*14]
        if op=='initialize':
            def observe(pc):
                if pc==0x1024b8:
                    where=m.STACK_TOP-160 if m.read(self.STATE+12)==1 else m.STACK_TOP-184
                    m.mem[where:where+14]=b'\xa9'*14
                if pc==0x101e20:
                    where=m.STACK_TOP-160 if m.read(self.STATE+12)==1 else m.STACK_TOP-184
                    aux_snapshot[0]=bytes(m.mem[where:where+14])
            m.observe=observe
        if op in ('initialize','extended'):runtime.full=True
        def lock(x):self.events.append(('lock',));x.r[0]=rets.get('lock',0)&0xffffffff
        def unlock(x):self.events.append(('unlock',));x.r[0]=rets.get('unlock',0)&0xffffffff
        def delay(x):
            v=x.r[0];self.events.append(('delay',v))
            if v==400:runtime.new_attempt(m.read(self.STATE+12))
            x.r[0]=rets.get('delay',0)&0xffffffff
        def params(x):
            assert x.r[0]==self.BUS
            return tuple(x.r[1:4])
        def wb(x):
            ptr,n=x.read(x.r[13]),x.read(x.r[13]+4);tx=bytes(x.mem[ptr:ptr+n])
            runtime.tx=bytearray(tx);self.events.append(('write_block',*params(x),tx))
            x.r[0]=rets.get('write',0)&0xffffffff
        def rb(x):
            ptr,n=x.read(x.r[13]),x.read(x.r[13]+4)
            if op=='initialize':
                assert ptr in (rxptr,m.STACK_TOP-160,m.STACK_TOP-184),hex(ptr)
                if n==14:
                    nonlocal auxptr
                    auxptr=ptr
            else:assert ptr==rxptr,(hex(ptr),hex(rxptr))
            self.events.append(('read_block',*params(x),n))
            chunk=runtime.response(n)
            if chunk is not None:x.mem[ptr:ptr+len(chunk)]=chunk
            x.r[0]=rets.get('read',0)&0xffffffff
        def wy(x):
            v=x.read(x.r[13]);runtime.write_byte(v)
            self.events.append(('write_byte',*params(x),v));x.r[0]=rets.get('write',0)&0xffffffff
        def ry(x):
            self.events.append(('read_byte',*params(x)));x.r[0]=runtime.read_byte(size)&0xffffffff
        before=bytes(m.mem[self.STATE:self.STATE+0x134]); memory_size=len(m.mem)
        def select_bus(x):
            self.events.append(('select_bus',x.r[0]));assert x.r[0]==0;x.r[0]=self.BUS
        def mutex_init(x):
            assert x.r[0]==self.DEVICE and x.r[1]==0
            self.events.append(('mutex_init',));x.r[0]=rets.get('mutex_init',0)&0xffffffff
        hooks={0x5a6108:lock,0x5a66c4:unlock,
            0x10ed2c:delay,0xfe538:wb,0xfe528:rb,0x126fcc:wy,0x128188:ry,
            0xfa0c4:self.setup_log,0x10f170:self.fmt,0xfe420:select_bus,0x5a60dc:mutex_init,
            0x591480:self.udiv64}
        result=m.run(entry,stop=stop,hooks=hooks,max_steps=200000)
        if op=='identify' and m.r[15]==stop:result=1
        after=bytes(m.mem[self.STATE:self.STATE+0x134]); assert len(m.mem)==memory_size
        if op=='initialize':
            return (signed(result),bytes(m.mem[rxptr:rxptr+40]),aux_snapshot[0],
                    self.events,m.read(self.STATE+12),m.read(self.STATE+4,2),m.read(self.STATE+8),
                    m.read(self.DEVICE+28,1),m.read(self.STATE),m.read(self.STATE+0x128),
                    bytes(m.mem[self.STATE+0x1d:self.STATE+0x2f]),m.read(self.STATE+0x10,1),self.tables())
        if op!='identify':assert before==after
        else:
            assert before[:4]==after[:4] and before[6:12]==after[6:12] and before[16:]==after[16:]
        if runtime.attempt:assert 0x102bd0 in m.visited
        return signed(result),bytes(m.mem[rxptr:rxptr+size]),self.events,m.read(self.STATE+12),m.read(self.STATE+4,2)

    def udiv64(self,m):
        # Explicit compiler-runtime boundary: unsigned 64/64 division, divisor
        # 36 in original serial formatting. Original callee instructions are
        # not claimed executed by this hook. R4..R11 are left intact.
        a=m.r[0]|m.r[1]<<32;b=m.r[2]|m.r[3]<<32
        assert b==36
        q,r=divmod(a,b);m.r[0]=q&0xffffffff;m.r[1]=q>>32;m.r[2]=r;m.r[3]=0
    def serial(self,data):
        self.begin_setup(args=(self.RX,));m=self.m
        m.mem[self.RX:self.RX+12]=data
        m.mem[self.STATE+0x1d:self.STATE+0x2f]=b'old-serial-1234567'
        rc=m.run(0x105d30,hooks={0x591480:self.udiv64},max_steps=50000)
        return signed(rc),bytes(m.mem[self.STATE+0x1d:self.STATE+0x2f])
    def crc(self,data,init):
        self.begin_setup(args=(self.RX,len(data),init));m=self.m
        m.mem[self.RX:self.RX+len(data)]=data
        return m.run(0xf7e90,max_steps=50000)
    def date(self,value):
        self.begin_setup();m=self.m
        m.r[8]=self.STATE;m.write(m.r[13]+61,((value&255)<<8)|(value>>8),2)
        m.run(0x101bfc,stop=0x101c70,max_steps=1000)
        return m.read(self.STATE+0x128)

class BusScript:
    """Explicit RAM-only external transport; never picks algorithm results."""
    def __init__(self,scenario):
        self.sc=scenario;self.tx=bytearray();self.attempt=0;self.read_index=0
        self.pending_new=False;self.mode=0;self.rn=0;self.full=False
    def write_byte(self,v):
        if self.pending_new:self.tx=bytearray();self.pending_new=False
        self.tx.append(v&255)
    def new_attempt(self,mode):
        self.attempt+=1;self.read_index=0;self.pending_new=True;self.mode=mode
    def response(self,n):
        self.rn=n
        if self.sc.get('no_read'):return None
        r=bytearray((i*17+13)&255 for i in range(n))
        r[:2]=self.tx[:2];r[2]=n-2;r[3]=self.tx[3]
        if r[3]==2:r[4:6]=struct.pack('<H',self.sc.get('model',193))
        else:r[4:6]=struct.pack('<H',self.sc.get('raw',123))
        if self.full:
            if r[3]==1:r[4:6]=struct.pack('<H',self.sc.get('revision',4))
            if r[3] in (10,14):r[8:12]=struct.pack('>I',self.sc.get('extended',123456))
            if r[3]==6:
                off=5 if n==39 else 6
                record=dict(self.sc);record.update(self.sc.get('a' if n==39 else 'b',{}))
                body=bytearray(30)
                body[:8]=struct.pack('>Q',record.get('serial_first',123456789012345))
                body[8:12]=struct.pack('>I',record.get('serial_second',123456789))
                body[12:14]=struct.pack('>H',record.get('offset',17))
                for i in range(14):body[14+i]=record.get('delta',1)&255
                end=record.get('sentinel',8)
                if end<14:body[14+end]=128
                body[28:30]=struct.pack('>H',record.get('date',5678))
                crc=independent_crc(body,65535)
                if record.get('bad_record_crc'):crc^=1
                r[off:off+30]=body;r[off+30:off+32]=struct.pack('>H',crc)
        
        r[-2:]=b'\0\0'
        mode=self.sc.get('hardware_mode',self.mode)
        check=(sum(r[2:-2]) if not mode else sum(int.from_bytes(r[i:i+2],'little') for i in range(2,n-2,2)))&65535
        if mode and n&1:check=(check+256*(check&255))&65535
        r[-2:]=struct.pack('<H',check)
        if self.attempt<=self.sc.get('bad_attempts',0) or self.tx[3] in self.sc.get('bad_commands',[]):r[-1]^=1
        return bytes(r)
    def read_byte(self,n):
        if self.full:n=8 if self.tx[3] in (1,2) else 14 if self.tx[3] in (10,14) else 39 if len(self.tx)==8 else 40
        r=self.response(n)
        value=self.sc.get('returns',{}).get('read',-1) if r is None else r[self.read_index]
        self.read_index+=1
        return value


def independent_crc(data,init):
    crc=init
    for b in data:
        crc^=b
        for _ in range(8):crc=(crc>>1)^ (0xa001 if crc&1 else 0)
    return crc&65535
