/* Selected procedures from /tmp/build/libbitmain/src/psu.c, VNishNet 1.3.5.
 * Partial reconstruction, not a complete PSU driver. See evidence and tests.
 * Native cgminer core is unchanged. No hardware/system I/O in this module.
 */
#include "integration/psu_protocol_135.h"
#include <limits.h>

static uint16_t le16(const uint8_t *p)
{
    return (uint16_t)((uint16_t)p[0] | (uint16_t)((uint16_t)p[1] << 8));
}
static void diag(struct vn135_psu_protocol *p, unsigned line,
                 uint32_t a, uint32_t b, const uint8_t *data, uint32_t n)
{
    if (p->ops && p->ops->log) p->ops->log(p->opaque,line,a,b,data,n);
}
static uint16_t response_sum(uint32_t mode, const uint8_t *r, uint32_t n)
{
    uint32_t sum=0, i;
    if (mode) {
        /* Odd lengths intentionally preserve original halfword inclusion. */
        for (i=2; i<n-2; i+=2) sum+=le16(r+i);
    } else {
        for (i=2; i<n-2; ++i) sum+=r[i];
    }
    return (uint16_t)sum;
}
int vn135_psu_response_check(struct vn135_psu_protocol *p,
    const uint8_t *tx, uint32_t tn, const uint8_t *rx, uint32_t rn)
{
    uint16_t expected, actual;
    (void)tn; /* original r1 is overwritten without a request-length check */
    if (le16(tx)!=le16(rx) || tx[3]!=rx[3] || (uint32_t)rx[2]+2!=rn) {
        diag(p,951,0,0,NULL,0);
        return -1;
    }
    expected=response_sum(p->checksum_mode,rx,rn);
    actual=le16(rx+rn-2);
    if (expected!=actual) {
        diag(p,957,expected,actual,NULL,0);
        return -1;
    }
    return 0;
}
static void dump_pair(struct vn135_psu_protocol *p, const uint8_t *tx,
                      uint32_t tn, const uint8_t *rx, uint32_t rn)
{
    diag(p,937,0,0,tx,tn);
    diag(p,939,0,0,rx,rn);
}
int vn135_psu_exchange_block(struct vn135_psu_protocol *p,
    const uint8_t *tx, uint32_t tn, uint8_t *rx, uint32_t rn)
{
    uint32_t mode=(p->checksum_mode==1)?0:1;
    unsigned attempt;
    int rc=-1;
    (void)p->ops->lock(p->opaque);
    for (attempt=0; attempt<3; ++attempt) {
        (void)p->ops->write_block(p->opaque,0x10,mode,0x11,tx,tn);
        (void)p->ops->delay_ms(p->opaque,400);
        (void)p->ops->read_block(p->opaque,0x10,mode,0x11,rx,rn);
        (void)p->ops->delay_ms(p->opaque,100);
        if (!vn135_psu_response_check(p,tx,tn,rx,rn)) {rc=0;break;}
        dump_pair(p,tx,tn,rx,rn);
    }
    (void)p->ops->unlock(p->opaque);
    return rc;
}
int vn135_psu_exchange_bytes(struct vn135_psu_protocol *p,
    const uint8_t *tx, uint32_t tn, uint8_t *rx, uint32_t rn)
{
    uint32_t mode=(p->checksum_mode==1)?0:1, i;
    unsigned attempt;
    int rc=-1;
    (void)p->ops->lock(p->opaque);
    for (attempt=0; attempt<3; ++attempt) {
        for(i=0;i<tn;++i)
            (void)p->ops->write_byte(p->opaque,p->address,mode,0x11,tx[i]);
        (void)p->ops->delay_ms(p->opaque,400);
        for(i=0;i<rn;++i)
            rx[i]=(uint8_t)p->ops->read_byte(p->opaque,p->address,0,0x11);
        (void)p->ops->delay_ms(p->opaque,100);
        if (!vn135_psu_response_check(p,tx,tn,rx,rn)) {rc=0;break;}
    }
    if(rc) dump_pair(p,tx,tn,rx,rn);
    (void)p->ops->unlock(p->opaque);
    return rc;
}
double vn135_psu_decode_voltage(const struct vn135_psu_voltage_state *s,
                                  int32_t raw)
{
    double a,b;
    if (s->byte_130) {
        switch (s->word_132) {
        case 0: a=0x1.1a5249235f80ap+10; b=0x1.236db6a1e81cbp+6; break;
        case 1: a=0x1.5400000000000p+10; b=0x1.5400000000000p+6; break;
        case 2: a=0x1.3ec0000000000p+10; b=0x1.236db6a1e81cbp+6; break;
        default: return 0.0;
        }
    } else {
        switch(s->model) {
        case 34: a=0x1.2ff93e81450f0p+10; b=0x1.df73b9f127f5fp+5; break;
        case 65: case 66: case 101: case 102: a=0x1.7eb4b4aec8d5cp+9; b=0x1.1eaaaa7ded6bbp+5; break;
        case 67: a=0x1.d29ec447c30d3p+9; b=0x1.de72c1f42bb66p+5; break;
        case 97: a=0x1.1e2025072085bp+10; b=0x1.a1f2deca2552ap+5; break;
        case 106: a=0x1.1b40000000000p+10; b=0x1.1b51eb851eb85p+6; break;
        case 115: case 120: a=0x1.4024fb00bcbe6p+10; b=0x1.27eadea897636p+6; break;
        case 116: case 118: a=0x1.2106e2ac32229p+10; b=0x1.305caa7589efep+6; break;
        case 196: a=0x1.0ef0000000000p+10; b=0x1.1b55555318abdp+6; break;
        case 113: case 114: case 117: case 119:
            if(s->byte_1c) {a=0x1.22484d013a92ap+10;b=0x1.2e0b11409a240p+6;}
            else {a=0x1.29bbdc9c4da90p+10;b=0x1.3af868fd199bbp+6;}
            break;
        case 193: case 194:
            if(s->word_08>3) {a=0x1.0ef0000000000p+10;b=0x1.1b55555318abdp+6;}
            else {a=0x1.3ec0000000000p+10;b=0x1.5400000000000p+6;}
            break;
        default: return 0.0;
        }
    }
    return (a-(double)raw)/b;
}
int vn135_psu_read_voltage(struct vn135_psu_protocol *p,
                          uint8_t rx[8], int32_t *out)
{
    static const uint8_t request[6]={0x55,0xaa,0x04,0x03,0x07,0x00};
    double value;
    int rc;
    if(p->bus_kind==0) rc=vn135_psu_exchange_block(p,request,6,rx,8);
    else if(p->bus_kind==1) rc=vn135_psu_exchange_bytes(p,request,6,rx,8);
    else {diag(p,439,0,0,NULL,0);rc=-1;}
    if(rc) {diag(p,1110,0,0,NULL,0);return -1;}
    value=vn135_psu_decode_voltage(&p->voltage,(int32_t)le16(rx+4))*1000.0;
    /* Match finite VCVT.s32 saturation rather than out-of-range C conversion. */
    if(value>=(double)INT32_MAX) *out=INT32_MAX;
    else if(value<=(double)INT32_MIN) *out=INT32_MIN;
    else *out=(int32_t)value;
    return 0;
}
