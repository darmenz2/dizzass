"""Bounded original registration/init/getter execution. External calls are RAM scripts."""
from pathlib import Path
import hashlib
import json
import sys
ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'tools'))
from elf32 import ELF32
from arm32_verify_subset import ARM32Verify
from arm32_subset import signed

ENTRIES = {'register':0x125a28, 'gpio':0x126084, 'close':0x126d14,
           'psu':0x11c5c0, 'hw':0x119a1c,
           'psu_get':0x11c968, 'hw_get':0x119c84}
CTORS = (0x125e74,0x1289c4,0x11cc8c,0x11af60)
REFERENCE = 'b2663b3aa753cc14ae9d3b11a14d3d93c74b605a3e433b02101c3c17c69d95e9'
RANGES = [(0x125a28,0x125bf4),(0x125cf4,0x125e74),(0x126084,0x126e0c),
          (0x11c5c0,0x11c978),(0x119a1c,0x119ccc)]
class Tracked(ARM32Verify):
    def reset(self,args=()):
        super().reset(args)
        self.visited=set()
        self.allowed=None
    def extra_instruction(self,w,pc):
        if self.allowed and not any(a<=pc<b for a,b in self.allowed):
            raise ValueError('Unexpected PC '+hex(pc))
        self.visited.add(pc)
        return super().extra_instruction(w,pc)

def cstr(m,p):
    m.check(p,1)
    data=bytes(m.mem[p:p+512])
    assert b'\0' in data
    return data.split(b'\0')[0].decode('utf-8')

class Oracle:
    def __init__(self):
        self.elf=ELF32(ROOT/'reference/cgminer.vendor.elf')
        assert hashlib.sha256(self.elf.data).hexdigest()==REFERENCE
        evidence=ROOT/'integration/evidence/i2c_init_135.json'
        if evidence.exists():
            e=json.loads(evidence.read_text())
            for r in e['ranges']:
                a,b=int(r['start'],16),int(r['end_exclusive'],16)
                assert hashlib.sha256(self.elf.read(a,b-a)).hexdigest()==r['sha256']
            for r in e['source_paths']:
                raw=self.elf.read(int(r['address'],16),len(r['text'])+1)
                assert bytes(b^r['xor'] for b in raw)==r['text'].encode()+b'\0'
        self.m=Tracked(self.elf)
        for a in CTORS:
            self.m.reset();self.m.run(a,max_steps=25000)
        assert cstr(self.m,0x5ee422)=='/dev/i2c-1'
        assert cstr(self.m,0x5ee887)=='i2c:psu-bus'
    def begin(self,name,initial):
        m=self.m
        self.reg=0x655fb4 if name.startswith('psu') else 0x68c180 if name.startswith('hw') else 0x840000
        self.gpio=self.reg+0x24
        m.mem[self.reg:self.reg+0x448]=b'\xa5'*0x448
        m.mem[0x845000:0x845004]=b'old\0'
        m.write(self.reg+0x18,initial['kind']);m.write(self.reg+0x1c,initial['index']);m.write(self.reg+0x20,0x845000)
        m.write(self.gpio,initial['direction'],1)
        m.write(self.gpio+4,initial['sda_mode']);m.write(self.gpio+0x214,initial['scl_mode'])
        for off,key in ((0x208,'sda'),(0x418,'scl'),(0x20c,'fd'),(0x210,'dirfd'),(0x41c,'sclfd')):
            m.write(self.gpio+off,initial[key])
        if name.startswith('hw'):m.write(self.reg+0x24,initial['hwfd'])
        m.write(0x6563f8,initial['ready'],1)
        self.name=name
    def snapshot(self):
        m=self.m;r=self.reg;g=self.gpio
        reg=(m.read(r+0x18),m.read(r+0x1c),cstr(m,m.read(r+0x20)) if m.read(r+0x20) else None)
        if self.name=='register':return reg
        if self.name.startswith('hw'):return reg+(signed(m.read(r+0x24)),)
        fields=(m.read(g,1),m.read(g+4),m.read(g+0x214),
                signed(m.read(g+0x208)),signed(m.read(g+0x418)),
                signed(m.read(g+0x20c)),signed(m.read(g+0x210)),signed(m.read(g+0x41c)))
        return reg+fields+(m.read(0x6563f8,1),)
    def final(self):
        s=self.snapshot()
        if self.name in ('gpio','close','psu'):
            s+=(tuple(bytes(self.m.mem[self.gpio+o:self.gpio+o+256]) for o in (8,0x108,0x218,0x318)),)
        return s
    def hooks(self,script):
        m=self.m
        def result(v):m.r[0]=v&0xffffffff
        def open_(m):result(script.open(cstr(m,m.r[0]),m.r[1]))
        def close(m):result(script.close(signed(m.r[0])))
        def write(m):
            m.check(m.r[1],m.r[2]);result(script.write(signed(m.r[0]),bytes(m.mem[m.r[1]:m.r[1]+m.r[2]])))
        def snprintf(m):
            fmt=cstr(m,m.r[2]);text=(fmt%signed(m.r[3])).encode();n=m.r[1]
            if n:
                chunk=text[:n-1]+b'\0';m.check(m.r[0],len(chunk));m.mem[m.r[0]:m.r[0]+len(chunk)]=chunk
            result(len(text))
        def memset(m):
            m.check(m.r[0],m.r[2]);m.mem[m.r[0]:m.r[0]+m.r[2]]=bytes([m.r[1]&255])*m.r[2]
        def strlen(m):result(len(cstr(m,m.r[0]).encode()))
        def strcmp(m):
            a,b=cstr(m,m.r[0]),cstr(m,m.r[1]);result((a>b)-(a<b))
        def duplicate(m):
            text=cstr(m,m.r[0]);success=script.duplicate(text)
            if success:
                raw=text.encode()+b'\0';m.mem[0x846000:0x846000+len(raw)]=raw;result(0x846000)
            else:result(0)
        def mutex(m,k):result(script.mutex(k,m.r[1] if k==1 else 0))
        def log(m):
            lr=m.r[14]
            source=1 if 0x11c5c0<=lr<0x11c968 else 2 if 0x119a1c<=lr<0x119c84 else 0
            script.log(source,m.r[3]);result(0)
        return {0x5936dc:open_,0x5a811c:close,0x5a8684:write,0x59f558:snprintf,
                0x5a348c:memset,0x5a3a48:strlen,0x5a40bc:strcmp,0x5a38a0:duplicate,
                0x5a6880:lambda m:mutex(m,0),0x5a6890:lambda m:mutex(m,1),
                0x5a60dc:lambda m:mutex(m,2),0x5a6878:lambda m:mutex(m,3),
                0x124b5c:lambda m:result(script.check(signed(m.r[0]))),
                0x1251b8:lambda m:result(script.unexport(signed(m.r[0]))),
                0x1248e4:lambda m:result(script.direction(signed(m.r[0]),m.r[1])),0xfa0c4:log}
    def run(self,name,script,initial,args=()):
        self.begin(name,initial)
        m=self.m
        if name=='register':
            raw=args[2].encode()+b'\0';m.mem[0x847000:0x847000+len(raw)]=raw
            call=(self.reg,args[0],args[1],0x847000)
        elif name=='gpio':call=(self.gpio,*args)
        elif name=='close':call=(self.gpio,)
        elif name.endswith('_get'):call=(args[0],)
        else:call=()
        m.reset(call);m.allowed=RANGES;script.state=self.snapshot
        rc=m.run(ENTRIES[name],hooks=self.hooks(script),max_steps=30000)
        if name.endswith('_get'):rc=rc==self.reg
        elif name=='close':rc=None
        else:rc=signed(rc)
        return rc,self.final(),script.events
