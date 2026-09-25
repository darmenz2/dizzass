#!/usr/bin/env python3
"""Compare register-cache state transitions to complete original A32 routines.

Only calloc/free/memcpy and diagnostics are intercepted. No I/O, hardware, OS,
opaque-predicate patching, or vendor process execution. The singleton addresses
are explicit evidence. New C uses native pointers and a caller-owned context.
"""
from pathlib import Path
import collections, ctypes as C, hashlib, json, os, random, sys, time
ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT/'tools'))
from elf32 import ELF32
from arm32_subset import ARM32, signed
EXPECTED = 'b2663b3aa753cc14ae9d3b11a14d3d93c74b605a3e433b02101c3c17c69d95e9'
elf = ELF32(ROOT/'reference/cgminer.vendor.elf')
assert hashlib.sha256(elf.data).hexdigest() == EXPECTED
lib = C.CDLL(os.environ.get('VN135_TEST_LIB', str(ROOT/'build/libvn135_recovered.so')))
u32, i32, sz, ptr = C.c_uint32, C.c_int32, C.c_size_t, C.c_void_p
class Entry(C.Structure): _fields_ = [('address',u32),('value',u32)]
class Table(C.Structure): _fields_ = [('entries',Entry*64)]
class Chain(C.Structure):
    _fields_ = [('common',Table),('chips',C.POINTER(Table)),('chip_count',i32)]
ALLOC = C.CFUNCTYPE(ptr,ptr,sz,sz)
FREE = C.CFUNCTYPE(None,ptr,ptr)
class Allocator(C.Structure): _fields_ = [('context',ptr),('allocate',ALLOC),('release',FREE)]
class Cache(C.Structure):
    _fields_ = [('chains',C.POINTER(Chain)),('chain_count',i32),('initialized',C.c_uint8),('allocator',Allocator)]
P = C.POINTER(Cache)
lib.vn135_reg_cache_init.argtypes = [P,u32,i32,i32,C.POINTER(Allocator)]
lib.vn135_reg_cache_reset.argtypes = [P,u32,i32,i32]
lib.vn135_reg_cache_destroy.argtypes = [P];lib.vn135_reg_cache_destroy.restype = None
lib.vn135_reg_cache_defaults.argtypes = [u32,C.POINTER(Table)]
for name, args in [('get_chain',[P,i32,u32,C.POINTER(u32)]),('set_chain',[P,i32,u32,u32]),
                   ('get_chip',[P,i32,i32,u32,C.POINTER(u32)]),('set_chip',[P,i32,i32,u32,u32])]:
    getattr(lib,'vn135_reg_cache_'+name).argtypes = args
GLOBAL_PTR, GLOBAL_COUNT, GLOBAL_READY = 0x654d68,0x654d6c,0x654d70
ENTRY = {'init':0x106a58,'reset':0x106e58,'get_chain':0x107188,'set_chain':0x107648,
         'get_chip':0x1079f0,'set_chip':0x107ed0,'destroy':0x1082b4}
SENTINEL = 0xa5e17f39
m = ARM32(elf)
counts = collections.Counter();rng = random.Random(0x135004)
beg = time.monotonic()
class Pair:
    def __init__(self, fail=-1, zero_is_null=False):
        self.cache = Cache(); self.fail = fail;self.zero_is_null = zero_is_null
        self.old_trace = [];self.new_trace = [];self.old_blocks = {};self.new_blocks = {}
        self.keep = [];self.errors = [];self.old_allocs = self.new_allocs = 0
        self.heap = m.DATA_BASE
        m.mem[m.DATA_BASE:m.DATA_BASE+0x10000] = b'\0'*0x10000
        m.write(GLOBAL_PTR,0);m.write(GLOBAL_COUNT,0);m.write(GLOBAL_READY,0,1)
        @ALLOC
        def allocate(_, size, count):
            n = self.new_allocs;self.new_allocs += 1
            required = C.sizeof(Chain) if n == 0 else 512
            if size != required:self.errors.append(('allocation size',n,size,required))
            self.new_trace.append(['alloc',n,520 if n==0 else 512,count])
            if n == self.fail or (count == 0 and self.zero_is_null):return None
            total = size*count
            block = C.create_string_buffer(max(total,1)+64)
            address = C.addressof(block)+32
            C.memset(C.addressof(block),0xc7,32)
            C.memset(address+max(total,1),0x7c,32)
            self.keep.append(block);self.new_blocks[address] = (n,total)
            return address
        @FREE
        def release(_, address):
            if address not in self.new_blocks:
                self.errors.append(('invalid free',address));return
            n,total = self.new_blocks.pop(address)
            self.new_trace.append(['free',n])
        self.allocator = Allocator(None,allocate,release)
    def old_calloc(self,mm):
        size,count = mm.r[:2];n = self.old_allocs;self.old_allocs += 1
        assert size == (520 if n==0 else 512)
        self.old_trace.append(['alloc',n,size,count])
        if n == self.fail or (count == 0 and self.zero_is_null):mm.r[0]=0;return
        total = size*count;assert self.heap+total+64 < m.DATA_BASE+0xe000
        address = self.heap+32; self.heap = address+max(total,1)+32
        self.old_blocks[address] = (n,total)
        mm.mem[address-32:address] = b'\xc7'*32
        mm.mem[address:address+max(total,1)] = b'\0'*max(total,1)
        mm.mem[address+max(total,1):address+max(total,1)+32] = b'\x7c'*32
        mm.r[0]=address
    def old_free(self,mm):
        address=mm.r[0];assert address in self.old_blocks
        n,total=self.old_blocks.pop(address);self.old_trace.append(['free',n]);mm.r[0]=0
    def old_memcpy(self,mm):
        dst,src,n=mm.r[:3];mm.check(dst,n);mm.check(src,n)
        mm.mem[dst:dst+n]=mm.mem[src:src+n];mm.r[0]=dst
    def run(self,name,args):
        m.reset(args)
        return signed(m.run(ENTRY[name],hooks={0x593bb4:self.old_calloc,0x593c8c:self.old_free,
                       0x5a2ee8:self.old_memcpy,0xfa0c4:lambda _:None},max_steps=100000))
    def compare(self):
        assert not self.errors,self.errors
        assert self.old_trace == self.new_trace,(self.old_trace,self.new_trace)
        base = m.read(GLOBAL_PTR); n = signed(m.read(GLOBAL_COUNT))
        assert (bool(base),n,m.read(GLOBAL_READY,1)) == (bool(self.cache.chains),self.cache.chain_count,self.cache.initialized)
        if base:
            for i in range(n):
                cbase=base+i*520;c=self.cache.chains[i]
                assert bytes(m.mem[cbase:cbase+512]) == bytes(c.common),('common',i)
                chips=m.read(cbase+512);nc=signed(m.read(cbase+516))
                assert (bool(chips),nc)==(bool(c.chips),c.chip_count)
                if chips:
                    for j in range(nc):
                        assert bytes(m.mem[chips+j*512:chips+(j+1)*512])==bytes(c.chips[j]),('chip',i,j)
        for address,(_,total) in self.old_blocks.items():
            assert m.mem[address-32:address]==b'\xc7'*32
            assert m.mem[address+max(total,1):address+max(total,1)+32]==b'\x7c'*32
        for address,(_,total) in self.new_blocks.items():
            assert C.string_at(address-32,32)==b'\xc7'*32
            assert C.string_at(address+max(total,1),32)==b'\x7c'*32
    def init(self,selector,chains,chips):
        old = self.run('init',(selector,chains,chips))
        new = lib.vn135_reg_cache_init(C.byref(self.cache),selector,chains,chips,C.byref(self.allocator))
        assert old==new,('init',selector,chains,chips,old,new)
        self.compare(); counts['init: return, all tables and allocation ownership']+=1
        return new
    def destroy(self):
        self.run('destroy',())
        lib.vn135_reg_cache_destroy(C.byref(self.cache));self.compare()
        assert not self.old_blocks and not self.new_blocks
        counts['destroy: release order, globals and no retained allocations']+=1
    def operation(self,name,chain,reg,chip=0,value=0,null_output=False):
        out=u32(SENTINEL);outptr=None if null_output else C.byref(out)
        original_out=m.DATA_BASE+0xf000;m.write(original_out,SENTINEL)
        argout=0 if null_output else original_out
        if name=='get_chain':args=(chain,reg,argout);cargs=(C.byref(self.cache),chain,reg,outptr)
        elif name=='set_chain':args=(chain,reg,value);cargs=(C.byref(self.cache),chain,reg,value)
        elif name=='get_chip':args=(chain,chip,reg,argout);cargs=(C.byref(self.cache),chain,chip,reg,outptr)
        else:args=(chain,chip,reg,value);cargs=(C.byref(self.cache),chain,chip,reg,value)
        old=self.run(name,args);new=getattr(lib,'vn135_reg_cache_'+name)(*cargs)
        assert (old,m.read(original_out))==(new,out.value),(name,args,old,new,m.read(original_out),out.value)
        self.compare();counts[name+': return, output and whole cache state']+=1
    def reset(self,selector,chains,chips):
        old=self.run('reset',(selector,chains,chips))
        new=lib.vn135_reg_cache_reset(C.byref(self.cache),selector,chains,chips)
        assert old==new,('reset',selector,chains,chips,old,new)
        self.compare();counts['reset: return, all tables and preserved counts/flag']+=1

