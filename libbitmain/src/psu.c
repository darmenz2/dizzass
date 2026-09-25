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

/* Further original setup paths; see integration/PSU_SETUP_135_RU.md. */
#include "integration/psu_setup_135.h"
#include <float.h>
#include <math.h>
#include <string.h>
_Static_assert(sizeof(double)==8 && DBL_MANT_DIG==53 && DBL_MAX_EXP==1024,
               "Recovery requires IEEE binary64");
_Static_assert(sizeof(float)==4 && FLT_MANT_DIG==24 && FLT_MAX_EXP==128,
               "Recovery requires IEEE binary32");
static int32_t setup_s16(uint32_t v)
{ return (v&0x8000u)?(int32_t)(v&65535u)-65536:(int32_t)(v&65535u); }
static int32_t setup_s32(uint32_t v)
{ return v<=INT32_MAX?(int32_t)v:-1-(int32_t)(UINT32_MAX-v); }
static int32_t setup_trunc(double v)
{
    /* Original VCVT truncation/saturation; finite numeric domain only. */
    if(v>=(double)INT32_MAX)return INT32_MAX;
    if(v<=(double)INT32_MIN)return INT32_MIN;
    return (int32_t)v;
}
static void setup_put16(uint8_t *p,uint32_t v)
{ p[0]=(uint8_t)v;p[1]=(uint8_t)(v>>8); }
static void setup_sum(uint32_t mode,uint8_t *p,uint32_t n)
{ setup_put16(p+n-2,response_sum(mode,p,n)); }
static int setup_exchange(struct vn135_psu_protocol *p,const uint8_t *tx,
                          uint32_t tn,uint8_t *rx,uint32_t rn)
{
    if(p->bus_kind==0)return vn135_psu_exchange_block(p,tx,tn,rx,rn);
    if(p->bus_kind==1)return vn135_psu_exchange_bytes(p,tx,tn,rx,rn);
    diag(p,439,0,0,NULL,0);return -1;
}
int vn135_psu_knots_voltage(const struct vn135_psu_calibration *s,double *out,int32_t n)
{
    double lo,hi,step;int32_t i;
    if(n<2)return -1;
    lo=(double)s->lower/1000.0;hi=(double)s->upper/1000.0;
    if(lo<0.0||hi<0.0)return -1;
    step=(hi-lo)/(double)(n-1);
    for(i=0;i<n;++i)out[i]=hi-step*(double)i;
    return 0;
}
int vn135_psu_knots_raw(double *out,uint32_t n)
{
    double step;uint32_t i;
    if(n-2u>13u)return -1;
    step=255.0/(double)n-1.0;
    for(i=0;i<n;++i)out[i]=round(step*(double)i);
    return 0;
}
static uint32_t setup_count(const uint8_t *delta)
{
    uint32_t i;
    for(i=0;i<14;++i)if(delta[i]==0x80)return i+1;
    return 15;
}
int vn135_psu_load_calibration_a(const struct vn135_psu_protocol *p,
    struct vn135_psu_calibration *s,const uint8_t r[33])
{
    uint32_t i,n=setup_count(r+19),acc;
    s->count=n;
    if(n<2)return -1;
    (void)vn135_psu_knots_raw(s->x,n);
    acc=(uint32_t)r[17]*256u+r[18];
    for(i=0;i<n;++i){
        if(i){uint32_t v=r[18+i];acc+=(uint32_t)(v<128?(int32_t)v:(int32_t)v-256);}
        s->y[i]=vn135_psu_decode_voltage(&p->voltage,setup_trunc(s->x[i]))+
                 (double)setup_s16(acc)/1000.0;
    }
    return 0;
}
int vn135_psu_load_calibration_b(struct vn135_psu_calibration *s,const uint8_t r[34])
{
    uint32_t i,n=setup_count(r+20),acc;
    s->count=n;
    if(n<2)return -1;
    if(vn135_psu_knots_voltage(s,s->x,(int32_t)n))return -1;
    acc=(uint32_t)r[18]*256u+r[19];
    for(i=0;i<n;++i){
        if(i){uint32_t v=r[19+i];acc+=(uint32_t)(v<128?(int32_t)v:(int32_t)v-256);}
        s->y[i]=s->x[i]+(double)setup_s16(acc)/1000.0;
    }
    return 0;
}
int vn135_psu_model_family(uint16_t model)
{
    switch(model){case 100:case 101:case 103:case 105:case 106:
        case 193:case 194:case 196:case 197:return 1;default:return 0;}
}
static int setup_supported_model(uint16_t model)
{
    switch(model){case 34:case 65:case 66:case 67:case 97:case 98:
        case 100:case 101:case 102:case 103:case 105:case 106:
        case 113:case 114:case 115:case 116:case 117:case 118:case 119:case 120:
        case 193:case 194:case 196:case 197:return 1;default:return 0;}
}
int vn135_psu_identify_prefix(struct vn135_psu_protocol *p,uint8_t rx[8])
{
    uint8_t request[6]={0x55,0xaa,0x04,0x02,0,0};
    setup_sum(p->checksum_mode,request,6);
    if(setup_exchange(p,request,6,rx,8)){
        diag(p,500,0,0,NULL,0);
        p->checksum_mode=p->checksum_mode==0?1u:0u;
        setup_sum(p->checksum_mode,request,6);
        if(setup_exchange(p,request,6,rx,8)){
            diag(p,510,0,0,NULL,0);diag(p,851,0,0,NULL,0);return -1;
        }
    }
    diag(p,515,le16(rx+4),0,NULL,0);
    p->voltage.model=le16(rx+4);
    if(!setup_supported_model(p->voltage.model)){
        diag(p,519,p->voltage.model,0,NULL,0);diag(p,851,0,0,NULL,0);return -1;
    }
    return VN135_PSU_IDENTIFIED_CONTINUE;
}
static double setup_interpolate(const struct vn135_psu_calibration *s,double v)
{
    uint32_t i=0,n=s->count;
    const double epsilon=0x1.0624dd2f1a9fcp-10;
    if(s->y[0]>v)i=0;
    else if(s->y[n-1]<v)i=n-2;
    else{
        for(i=0;i<n-1;++i){
            if(s->y[i]-epsilon<v && s->y[i+1]+epsilon>v)break;
            if(s->y[i]+epsilon>v && s->y[i+1]-epsilon<v)break;
        }
    }
    /* Contract requires finite valid table and a nonzero selected denominator.
     * This keeps the original endpoint/segment choice, including descending
     * tables. No sorting, clamping of the input voltage or table repair. */
    return s->x[i]+(v-s->y[i])*((s->x[i+1]-s->x[i])/(s->y[i+1]-s->y[i]));
}
static int setup_static_code(const struct vn135_psu_voltage_state *s,double v)
{
    double a,b;int32_t code;
    if(s->byte_130){
        switch(s->word_132){
        case 0:a=0x1.1a5249235f80ap+10;b=-0x1.236db6a1e81cbp+6;break;
        case 1:a=0x1.5400000000000p+10;b=-0x1.5400000000000p+6;break;
        case 2:a=0x1.3ec0000000000p+10;b=-0x1.236db6a1e81cbp+6;break;
        default:return 255;
        }
    }else{
        switch(s->model){
        case 34:a=0x1.2ff93e81450f0p+10;b=-0x1.df73b9f127f5fp+5;break;
        case 65:case 66:case 101:case 102:a=0x1.7eb4b4aec8d5cp+9;b=-0x1.1eaaaa7ded6bbp+5;break;
        case 67:a=0x1.d29ec447c30d3p+9;b=-0x1.de72c1f42bb66p+5;break;
        case 97:a=0x1.1e2025072085bp+10;b=-0x1.a1f2deca2552ap+5;break;
        case 106:a=0x1.1b40000000000p+10;b=-0x1.1b51eb851eb85p+6;break;
        case 115:case 120:a=0x1.4024fb00bcbe6p+10;b=-0x1.27eadea897636p+6;break;
        case 116:case 118:a=0x1.2106e2ac32229p+10;b=-0x1.305caa7589efep+6;break;
        case 196:a=0x1.0ef0000000000p+10;b=-0x1.1b55555318abdp+6;break;
        case 113:case 114:case 117:case 119:
            if(s->byte_1c){a=0x1.22484d013a92ap+10;b=-0x1.2e0b11409a240p+6;}
            else{a=0x1.29bbdc9c4da90p+10;b=-0x1.3af868fd199bbp+6;}
            break;
        case 193:case 194:
            if(s->word_08>3){a=0x1.0ef0000000000p+10;b=-0x1.1b55555318abdp+6;}
            else{a=0x1.3ec0000000000p+10;b=-0x1.5400000000000p+6;}
            break;
        default:return 255;
        }
    }
    code=setup_trunc(a+v*b);
    return code<0?0:code>255?255:code;
}
int vn135_psu_set_voltage_raw(struct vn135_psu_protocol *p,
    const struct vn135_psu_calibration *s,uint32_t request,uint8_t rx[8])
{
    uint8_t tx[8]={0x55,0xaa,0x06,0x83,0,0,0,0};
    double v=(double)request/1000.0;int32_t code;
    if(p->voltage.byte_130 || !s->enabled)code=setup_static_code(&p->voltage,v);
    else if(s->count<2)code=-1;
    else{code=setup_trunc(round(setup_interpolate(s,v)));code=code<0?0:code>255?255:code;}
    setup_put16(tx+4,(uint32_t)code);setup_sum(p->checksum_mode,tx,8);
    if(s->lower>setup_s32(request)||s->upper<setup_s32(request)){
        diag(p,1037,request,0,NULL,0);return -1;
    }
    if(setup_exchange(p,tx,8,rx,8)){diag(p,1045,0,0,NULL,0);return -1;}
    return 0;
}
int vn135_psu_set_voltage_float(struct vn135_psu_protocol *p,
    const struct vn135_psu_calibration *s,uint32_t request,uint8_t rx[10])
{
    uint8_t tx[10]={0x55,0xaa,0x08,0x83,0,0,0,0,0,0};
    double v=(double)request/1000.0,target=v;float narrowed;uint32_t bits,i;
    if(s->enabled){
        target=-1.0;
        if(s->count>=2){
            double interpolated=setup_interpolate(s,v);
            if(interpolated>(double)s->upper/1000.0+0.5 ||
               interpolated<(double)s->lower/1000.0-0.5){
                uint64_t b;memcpy(&b,&interpolated,8);
                diag(p,1016,(uint32_t)b,(uint32_t)(b>>32),NULL,0);
            }else target=interpolated;
        }
    }
    narrowed=(float)target;memcpy(&bits,&narrowed,4);
    for(i=0;i<4;++i)tx[4+i]=(uint8_t)(bits>>(8*i));
    setup_sum(p->checksum_mode,tx,10);
    if(narrowed<0.0f){diag(p,1064,0,0,NULL,0);return -1;}
    if(s->lower>setup_s32(request)||s->upper<setup_s32(request)){
        diag(p,1069,request,0,NULL,0);return -1;
    }
    if(setup_exchange(p,tx,10,rx,10)){diag(p,1077,0,0,NULL,0);return -1;}
    return 0;
}
int vn135_psu_set_voltage(struct vn135_psu_protocol *p,
    const struct vn135_psu_calibration *s,uint32_t request,uint8_t rx[10])
{
    return p->checksum_mode?vn135_psu_set_voltage_float(p,s,request,rx):
        vn135_psu_set_voltage_raw(p,s,request,rx);
}

#include "integration/psu_crc16_135_table.h"
uint16_t vn135_psu_calibration_crc(const uint8_t *data,uint32_t n,uint16_t init)
{
    uint16_t crc=init;
    while(n--){crc=(uint16_t)(psu_crc16_table_135[(uint8_t)crc^*data++]^(crc>>8));}
    return crc;
}
static uint32_t setup_be32(const uint8_t *p)
{ return (uint32_t)p[0]<<24|(uint32_t)p[1]<<16|(uint32_t)p[2]<<8|p[3]; }
int vn135_psu_decode_serial(struct vn135_psu_identity *s,const uint8_t data[12])
{
    static const char alphabet[]="0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    uint64_t first=((uint64_t)(setup_be32(data)&0x01ffffffu)<<32)|setup_be32(data+4);
    uint32_t second=setup_be32(data+8),value=second;
    int i;
    s->serial[11]=0;
    for(i=10;i>=0;--i){s->serial[i]=alphabet[first%36];first/=36;}
    if(first)return -1; /* Original keeps the already written 11-byte prefix. */
    s->serial[17]=0;
    for(i=16;i>=11;--i){s->serial[i]=alphabet[value%36];value/=36;}
    return second>0x81bf0fffu?-1:0;
}
uint32_t vn135_psu_decode_date(uint16_t packed)
{
    uint32_t v=packed;
    return (v/372u)*10000u+((v/31u)%12u+1u)*100u+v%31u+1u;
}
int32_t vn135_psu_read_extended(struct vn135_psu_protocol *p,uint8_t rx[14])
{
    uint8_t tx[6]={0x55,0xaa,0x04,0x0a,0,0};
    int special=p->checksum_mode==1;
    if(special){tx[3]=0x0e;tx[4]=0x04;tx[5]=0x0e;}
    else setup_sum(p->checksum_mode,tx,6);
    if(setup_exchange(p,tx,6,rx,14)){
        if(special)diag(p,556,0,0,NULL,0);
        return -1;
    }
    return setup_s32(setup_be32(rx+8));
}
static int setup_cal_record(struct vn135_psu_protocol *p,
    struct vn135_psu_calibration *s,struct vn135_psu_identity *identity,
    uint8_t *rx,int format_b)
{
    uint32_t offset=format_b?6u:5u;
    uint16_t crc=vn135_psu_calibration_crc(rx+offset,30,65535);
    if(crc!=(uint16_t)((uint16_t)rx[offset+30]*256u+rx[offset+31]))return -1;
    if(vn135_psu_decode_serial(identity,rx+offset)){
        diag(p,format_b?807:762,0,0,NULL,0);return -1;
    }
    s->enabled=1;
    diag(p,format_b?813:768,0,0,(const uint8_t *)identity->serial,17);
    identity->date_word=vn135_psu_decode_date((uint16_t)((uint16_t)rx[offset+28]*256u+rx[offset+29]));
    if(format_b?vn135_psu_load_calibration_b(s,rx):vn135_psu_load_calibration_a(p,s,rx)){
        diag(p,format_b?820:775,0,0,NULL,0);return -1;
    }
    return 0;
}
int vn135_psu_initialize(struct vn135_psu_protocol *p,
    struct vn135_psu_calibration *s,struct vn135_psu_identity *identity,
    int32_t lower,int32_t upper,uint32_t initial_mode,
    const struct vn135_psu_init_ops *ops,struct vn135_psu_init_scratch *scratch)
{
    uint8_t *rx=scratch->response;
    uint16_t model;
    s->lower=lower;s->upper=upper;identity->initial_word=0;p->checksum_mode=initial_mode;
    p->bus_kind=ops->select_bus_kind(p->opaque,0);p->address=16;
    (void)ops->mutex_init(p->opaque);
    if(vn135_psu_identify_prefix(p,rx)!=VN135_PSU_IDENTIFIED_CONTINUE)return -1;
    model=p->voltage.model;
    if(model>=193 && model<=197 && model!=195){
        uint8_t revision[6]={0x55,0xaa,0x04,0x01,0,0};
        uint8_t calibration[8]={0x55,0xaa,0x06,0x06,0x00,0x20,0,0};
        setup_sum(p->checksum_mode,revision,6);
        if(setup_exchange(p,revision,6,rx,8))diag(p,857,0,0,NULL,0);
        else{diag(p,540,le16(rx+4),0,NULL,0);p->voltage.word_08=le16(rx+4);}
        setup_sum(p->checksum_mode,calibration,8);
        if(setup_exchange(p,calibration,8,rx,39)||setup_cal_record(p,s,identity,rx,0))s->enabled=0;
    }
    if(vn135_psu_model_family(model)){
        int32_t value=vn135_psu_read_extended(p,scratch->auxiliary);
        if(value==-1)return -1;
        diag(p,868,(uint32_t)value,0,NULL,0);
    }
    if(p->checksum_mode==1){
        static const uint8_t calibration[10]={0x55,0xaa,0x08,0x06,0x00,0x00,0x20,0x00,0x28,0x06};
        if(setup_exchange(p,calibration,10,rx,40)||setup_cal_record(p,s,identity,rx,1)){
            diag(p,873,0,0,NULL,0);s->enabled=0;
        }
    }
    return 0;
}
