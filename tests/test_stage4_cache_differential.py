#!/usr/bin/env python3
"""Register-cache differential cases; see cache_oracle.py for the bounded harness."""
from cache_oracle import *

# Initialization, including calloc(0) outcomes and every partial failure position.
for selector in range(8):
    for nc in (0,1,2,4):
        for n in (0,1,3,8):
            for fail in [-1]+list(range(nc+1)):
                p=Pair(fail);p.init(selector,nc,n);p.destroy();p.destroy()
    for nc,n in [(0,3),(2,0)]:
        p=Pair(zero_is_null=True);p.init(selector,nc,n);p.destroy()
for selector in [8,9,0xffffffff]:
    p=Pair();p.init(selector,2,3);p.destroy()

# Use original initialization to verify standalone default export for all 8 selectors.
for selector in range(8):
    p=Pair();p.init(selector,1,1);out=Table()
    assert lib.vn135_reg_cache_defaults(selector,C.byref(out))==0
    assert bytes(out)==bytes(p.cache.chains[0].common)
    counts['default table: all 512 bytes against original init']+=1;p.destroy()

# Every byte-valued register against every real table, with both lookup scopes.
for selector in range(8):
    p=Pair();p.init(selector,2,3)
    for reg in range(256):
        p.operation('get_chain',1,reg)
        p.operation('get_chip',0,reg,chip=2)
    for _ in range(256):
        name=rng.choice(['get_chain','set_chain','get_chip','set_chip'])
        p.operation(name,rng.choice([-2,-1,0,1,2,0x7fffffff]),
            rng.choice([rng.randrange(256),256,0xffffffff]),
            chip=rng.choice([-1,0,1,2,3,0x7fffffff]),value=rng.getrandbits(32),
            null_output=rng.randrange(8)==0)
    # Guaranteed successful mutation sequences, including non-aligned 0x25.
    for entry in p.cache.chains[0].common.entries:
        reg=entry.address
        if reg>=256:continue
        p.operation('set_chip',0,reg,chip=1,value=rng.getrandbits(32))
        p.operation('get_chain',0,reg)
        p.operation('get_chip',0,reg,chip=1)
        p.operation('set_chain',0,reg,value=rng.getrandbits(32))
        p.operation('get_chip',0,reg,chip=2)
    # Table entries intentionally reordered: broadcast uses common slot index.
    base=m.read(GLOBAL_PTR); chips=m.read(base+512)
    table=p.cache.chains[0].chips[0]
    temp=bytes(table.entries[0]); table.entries[0]=Entry.from_buffer_copy(bytes(table.entries[1]));table.entries[1]=Entry.from_buffer_copy(temp)
    aa=bytes(m.mem[chips:chips+8]);bb=bytes(m.mem[chips+8:chips+16]);m.mem[chips:chips+16]=bb+aa
    p.operation('set_chain',0,p.cache.chains[0].common.entries[0].address,value=0xdeadbeef)
    # Duplicate key: first match semantics, not direct register/4 indexing.
    reg=table.entries[0].address;table.entries[4].address=reg;m.write(chips+4*8,reg)
    p.operation('set_chip',0,reg,chip=0,value=0xaabbccdd)
    p.operation('get_chip',0,reg,chip=0)
    for nchain,nchip in [(0,0),(1,0),(1,1),(2,2),(2,3)]:p.reset((selector+1)%8,nchain,nchip)
    p.reset(9,2,3)
    # Disabling cache prevents accessor use, while reset itself leaves flag alone.
    p.cache.initialized=0;m.write(GLOBAL_READY,0,1)
    for name in ['get_chain','set_chain','get_chip','set_chip']:p.operation(name,0,8,chip=0,value=123)
    p.reset(selector,2,3);assert p.cache.initialized==0;p.destroy()
# Reset on missing global storage and on a later missing chip array.
for fail in [0,1,2,3]:
    p=Pair(fail);p.init(2,3,2)
    p.reset(5,3,2);p.destroy()

result={'passed':True,'reference_sha256':EXPECTED,'total_cases':sum(counts.values()),'cases':dict(counts),
        'seconds':round(time.monotonic()-beg,3),'host_chain_size':C.sizeof(Chain),'original_chain_size':520,
        'original_global_addresses':{'pointer':hex(GLOBAL_PTR),'chain_count':hex(GLOBAL_COUNT),'enabled':hex(GLOBAL_READY)},
        'hardware_tested':False,'full_miner_tested':False,
        'method':'Native compiled C state and return compared to complete original A32 cache routines',
        'limits':['Local bounded A32 interpreter; not an independent certified emulator.',
                  'calloc/free/memcpy are intercepted; diagnostics are suppressed.',
                  'Explicit C context/native pointers replace vendor singleton and ARM32 pointers.',
                  'Allocation sizes normalized for native pointer width; table contents and ownership compared.',
                  'New integration guards for negative/oversized counts, live reinit and corrupt context tested separately.',
                  'No hardware/cache coherency, multithreading, timing, actual model selection or miner acceptance.']}
(ROOT/'build/stage4-cache-differential-results.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(result,indent=2))
