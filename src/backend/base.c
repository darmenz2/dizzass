/* Selected original /tmp/build/src/backend/base.c, VNishNet 1.3.5.
 * Whole entries: 0x6c224 power-on + voltage; 0x6b778 power-off + chain reset.
 * Upper resume entry 0x70e30 is translated below through explicit callees.
 * Cold initialization 0x730d8 remains separate. See evidence/README.
 */
#include "integration/gpio_power_135.h"
static void log_line(const struct vn135_backend_power_ops *o,void *p,
                     uint32_t line,uint32_t arg)
{ if(o->log)o->log(p,VN135_GP_BASE,line,arg); }
int vn135_backend_power_start_135(struct vn135_backend_power_state *s,
    const struct vn135_backend_power_ops *o,void *p,uint32_t requested)
{
    log_line(o,p,4997,0);
    if(o->psu_on(p)) {log_line(o,p,5000,0);return -1;}
    log_line(o,p,1973,requested);
    if(o->set_voltage(p,(uint16_t)requested)) {
        log_line(o,p,1976,requested);
        log_line(o,p,5005,0);
        return -1;
    }
    s->byte_ff1=1;
    s->word_20c=requested;
    return 0;
}
int vn135_backend_power_stop_135(struct vn135_backend_power_state *s,
    const struct vn135_backend_power_ops *o,void *p)
{
    int32_t count=o->chain_count(p),i;
    log_line(o,p,5019,0);
    if(o->psu_off(p)) {log_line(o,p,5022,0);return -1;}
    for(i=0;i<count;++i)(void)o->reset_chain(p,(uint32_t)i);
    s->byte_ff1=0;
    s->word_20c=0;
    return 0;
}
static int32_t bits_signed(uint32_t x)
{ return x<=INT32_MAX?(int32_t)x:-1-(int32_t)(UINT32_MAX-x); }
uint32_t vn135_power_caller_value_135(uint32_t base,uint32_t limit,
                                    uint8_t flag,uint32_t selector)
{
    if(!flag && selector==5)base+=1000u;
    return bits_signed(base)<bits_signed(limit)?base:limit;
}

/* Original upper resume control flow 0x70e30..0x725e8.
 * This is distinct from cold initialization at 0x730d8.
 */
#include "integration/backend_resume_135.h"
static int32_t resume_call(const struct vn135_resume_ops *o, void *p,
    enum vn135_resume_step op, uint32_t a, uint32_t b, uint32_t c)
{ return o->step(p,op,a,b,c); }
static void resume_log(const struct vn135_resume_ops *o, void *p,
    uint32_t line, uint32_t level, uint32_t a, uint32_t b)
{ if (o->log) o->log(p,line,level,a,b); }
static uint32_t resume_chain_usable(const struct vn135_resume_chain *c)
{
    /* Original 0x56fcc: byte flag and UNSIGNED (state-3)>2. */
    return c->byte_24 && (c->word_20-3u)>2u;
}
int vn135_backend_resume_135(struct vn135_resume_state *s,
    const struct vn135_resume_ops *o, const struct vn135_backend_power_ops *power,
    void *p, uintptr_t *join_scratch)
{
    struct vn135_resume_description *d=s->description;
    int32_t initial_count, count, i, j, result=1, rc;
    uint32_t mode, requested, total;
#define CALL(op,a,b,c) resume_call(o,p,(op),(a),(b),(c))
#define LOG(line,level,a,b) resume_log(o,p,(line),(level),(a),(b))
    initial_count=CALL(VN135_R_CHAIN_COUNT,0,0,0);
    mode=(uint32_t)CALL(VN135_R_MODE_82D60,0,0,0);
    *s->platform_byte=(uint8_t)mode;
    rc=CALL(VN135_R_CHECK_B86D0,0,0,0);
    if (rc && s->byte_85) {
        if (CALL(VN135_R_APPLY_4F0A0,0,0,0)) {
            result=-1;
            goto common_exit;
        }
        (void)CALL(VN135_R_REFRESH_B9148,0,0,0);
    }
    if (s->word_20!=5u) return 1;
    if (!CALL(VN135_R_POOL_CHECK,0,0,0)) {
        LOG(6112,2,0,0);
        return 2;
    }
    if (CALL(VN135_R_TRYLOCK,0,0,0)) return 1;
    LOG(6119,3,0,0);
    s->word_20=1;
    if (s->word_d4>=1) {
        int32_t random_value=CALL(VN135_R_RANDOM,0,0,0);
        int32_t remainder=random_value%s->word_d4;
        LOG(6124,3,(uint32_t)remainder,0);
        LOG(6125,3,0,0);
        (void)CALL(VN135_R_DELAY,(uint32_t)remainder*1000u,0,0);
    }
    if (s->byte_1054) {
        s->byte_1054=0;
        (void)o->thread_join(p,s->thread_1050,join_scratch);
        if (*join_scratch) { LOG(6131,1,0,0); result=-1; goto common_exit; }
    }
    if (!mode) (void)CALL(VN135_R_PLATFORM_FE190,0,0,0);
    if (CALL(VN135_R_PREPARE_106E58,d->chip_selector,
              (uint32_t)initial_count,d->board_word_10)) {
        LOG(6140,1,0,0); result=-1; goto common_exit;
    }
    requested=vn135_power_caller_value_135(s->word_dc,s->limit_34,
                                         s->byte_ec,d->chip_selector);
    if (vn135_backend_power_start_135(&s->power,power,p,requested)) {
        LOG(6151,1,0,0); result=-1; goto common_exit;
    }
    if (CALL(VN135_R_CHECK_66504,0,0,0)) {
        count=CALL(VN135_R_CHAIN_COUNT,0,0,0); total=0;
        for (i=0;i<count;++i) total+=s->chains[i].byte_24;
        LOG(6157,1,total,d->word_10); result=-1; goto common_exit;
    }
    if (CALL(VN135_R_CHAIN_6C61C,0,0,0)) {
        LOG(6162,1,0,0); result=-1; goto common_exit;
    }
    if (CALL(VN135_R_CHAIN_6C89C,0,0,0)) {
        LOG(6167,1,0,0); result=-1; goto common_exit;
    }
    for (i=0;i<d->table_count;++i) {
        if (d->table_types[i]!=4u) continue;
        if (CALL(VN135_R_TYPE4_6E31C,0,0,0)) {
            LOG(6172,1,0,0); result=-1; goto common_exit;
        }
        break; /* first matching entry only */
    }
    if (d->chip_selector!=7u && CALL(VN135_R_CONFIG_6E734,d->chip_word_2c,0,0)) {
        LOG(6178,1,0,0); result=-1; goto common_exit;
    }
    if (CALL(VN135_R_CONFIG_6EC4C,0,0,0)) {
        LOG(6184,1,0,0); result=-1; goto common_exit;
    }
    if ((d->chip_selector&~1u)!=6u &&
        o->thread_create(p,0x1044,0x790c0,&s->thread_1044)) {
        LOG(3397,1,0,0); LOG(6189,1,0,0); result=-1; goto common_exit;
    }
    if (o->thread_create(p,0x101c,0x79778,&s->thread_101c)) {
        LOG(6194,1,0,0); result=-1; goto common_exit;
    }
    rc=CALL(VN135_R_PLATFORM_KIND,0,0,0);
    if (((uint32_t)rc|2u)==2u &&
        o->thread_create(p,0x1014,0x7bc78,&s->thread_1014)) {
        LOG(6200,1,0,0); result=-1; goto common_exit;
    }
    if (CALL(VN135_R_CONFIG_6F1CC,0,0,0)) {
        LOG(6206,1,0,0);
        (void)CALL(VN135_R_EVENT_49C98,0xbbe,0,0);
        result=-1; goto common_exit;
    }
    j=d->table_count;
    count=CALL(VN135_R_CHAIN_COUNT,0,0,0);
    for (i=0;i<count;++i) {
        if (j>0 && resume_chain_usable(s->chains+i)) {
            int32_t k;
            for (k=0;k<j;++k)
                s->chains[i].items[k].word_44=s->chains[i].items[k].word_3c;
        }
    }
    (void)CALL(VN135_R_CONFIG_6F550,0,0,0);
    if (s->text_fc8) { o->release(p,s->text_fc8); s->text_fc8=NULL; }
    s->text_fc8=o->duplicate(p,s->text_90); /* original does not check NULL */
    (void)CALL(VN135_R_CONFIG_6F6F4,0,0,0);
    if ((d->chip_selector&~1u)!=6u) {
        if (CALL(VN135_R_CONFIG_6709C,s->byte_ec,0,0)) {
            LOG(6224,1,0,0); result=-1; goto common_exit;
        }
        (void)CALL(VN135_R_CONFIG_66244,mode,0,0);
    }
    if (!mode && CALL(VN135_R_CONFIG_6F8AC,0,0,0)) {
        LOG(6233,1,0,0); result=-1; goto common_exit;
    }
    if (d->chip_selector!=7u && CALL(VN135_R_CONFIG_6FAE8,0,0,0)) {
        (void)CALL(VN135_R_REPORT_F8C70,0,0,0); result=-1; goto common_exit;
    }
    rc=CALL(VN135_R_START_644A8,mode^1u,0,0);
    if (rc) {
        if (rc==1) {
            (void)CALL(VN135_R_UNLOCK,0,0,0);
            (void)CALL(VN135_R_RECOVERY_6BB70,0,0,0);
            return 1;
        }
        if (rc==2) {
            (void)CALL(VN135_R_UNLOCK,0,0,0);
            LOG(6254,1,0,0);
            (void)CALL(VN135_R_EVENT_49C98,0x3f1,0,0);
            (void)CALL(VN135_R_STOP_5E92C,0,0,0);
            return 0;
        }
        LOG(6259,1,0,0); result=rc; goto common_exit;
    }
    if (!mode) {
        count=CALL(VN135_R_CHAIN_COUNT,0,0,0);
        for (i=0;i<count;++i) {
            if (resume_chain_usable(s->chains+i) &&
                CALL(VN135_R_CHAIN_55400,(uint32_t)i,0,0)) {
                LOG(6265,1,0,0); result=0; goto common_exit;
            }
        }
    }
    if ((d->chip_selector&~1u)==6u) (void)CALL(VN135_R_CONFIG_66244,0,0,0);
    if (CALL(VN135_R_CONFIG_A20A0,0,0,0)) {
        LOG(6274,1,0,0); result=0; goto common_exit;
    }
    (void)CALL(VN135_R_FINISH_5DE64,0,0,0);
    result=0;
    if (CALL(VN135_R_FINISH_60A2C,0,0,0)) goto common_exit;
    count=CALL(VN135_R_CHAIN_COUNT,0,0,0); total=0;
    for (i=0;i<count;++i) total+=resume_chain_usable(s->chains+i);
    if (total) {
        s->byte_24=1;
        s->double_28=o->timestamp(p);
        LOG(6294,3,0,0);
    }
common_exit:
    (void)CALL(VN135_R_UNLOCK,0,0,0);
    if (CALL(VN135_R_FLAG_8291C,0,0,0)) (void)CALL(VN135_R_SET_829E8,0,0,0);
#undef CALL
#undef LOG
    return result;
}

/* 0x730d8..0x73f14: cold object construction/registration, NOT 0x7409c. */
#include "integration/backend_cold_135.h"
static void cold_log(const struct vn135_cold_ops *o, void *p, uint32_t line, uint32_t level)
{ if(o->log)o->log(p,line,level); }
static int32_t cold_object(const struct vn135_cold_ops *o,void *p,uint32_t op,
    void *object,uint32_t off,void *second,uint32_t a,uint32_t b)
{ return o->object(p,op,object,off,second,a,b); }
static enum vn135_cold_boundary cold_fatal(struct vn135_cold_result *r,uint32_t code)
{ r->fatal_code=code;return VN135_C_FATAL_BOUNDARY; }
uint32_t vn135_cold_chip_identifier_135(uint32_t selector)
{
    /* Original 0xa72b4 lookup at 0x5b0928. Numeric IDs, not guessed names. */
    static const uint32_t ids[8]={4960,4962,5016,4966,4968,4976,5257,5265};
    return selector<8?ids[selector]:0;
}
enum vn135_cold_boundary vn135_backend_construct_135(
    struct vn135_cold_result *r,const struct vn135_cold_ops *o,void *p,uintptr_t driver)
{
    /* Order is backend fields +1f0,+1f4,...,+208. Tokens are not invoked. */
    static const uint32_t targets[3][7]={
      {0xbfce8,0xbfd70,0xbf43c,0xbf8f0,0xbfb94,0xbf440,0x2d994},
      {0xc1c0c,0xc1e40,0xc0c3c,0xc0e40,0xc1970,0xc0cf8,0xbace4},
      {0xc3b54,0xc3e18,0xc4050,0xc33d0,0xc39a8,0xc3148,0x2d994}};
    struct vn135_cold_backend *b;
    struct vn135_cold_profile *m;
    int32_t count,i,j; uint32_t route,k;
    void *limits;
    r->fatal_code=0;r->backend=NULL;
    r->device=o->allocate(p,VN135_C_DEVICE,1,416);
    r->model=o->allocate(p,VN135_C_MODEL,1,704);m=r->model;
    if(!m){cold_log(o,p,7354,1);return VN135_C_RETURNED;}
    if(o->load_model(p,m))return cold_fatal(r,1001);
    if(!(m->capability[0]|m->capability[1]|m->capability[2]|m->capability[3])){
        cold_log(o,p,7333,1);cold_log(o,p,7334,3);return cold_fatal(r,1001);
    }
    (void)o->scalar(p,0xfdfdc,vn135_cold_chip_identifier_135(m->chip_selector),0,0);
    (void)o->scalar(p,0xfe038,m->capability[0]!=0,0,0);
    (void)o->scalar(p,0xfe000,m->board_word_0,0,0);
    if(o->scalar(p,0xfb994,m->chip_selector,(uint32_t)m->board_word_10,m->model_byte_2c)){
        cold_log(o,p,7375,1);return cold_fatal(r,1003);
    }
    b=o->allocate(p,VN135_C_BACKEND,1,0x1348);r->backend=b;
    count=o->scalar(p,0xfe668,0,0,0);
    (void)cold_object(o,p,0x5a6880,NULL,0,NULL,0,0);
    (void)cold_object(o,p,0x5a6890,NULL,0,NULL,1,0);
    (void)cold_object(o,p,0x5a60dc,b,0,NULL,1,0);
    (void)cold_object(o,p,0x5a60dc,b,0x1074,NULL,1,0);
    (void)cold_object(o,p,0x5a60dc,b,0x244,NULL,0,0);
    (void)cold_object(o,p,0x5a6878,NULL,0,NULL,0,0);
    (void)cold_object(o,p,0x5a60dc,b,0x214,NULL,0,0);
    (void)cold_object(o,p,0x5a6c48,b,0xfd4,NULL,0,0);
    b->alias_74=m;b->model_18=m;b->word_7c=(uint32_t)m->board_word_10;
    b->chains_230=o->allocate(p,VN135_C_CHAINS,(uint32_t)count,800);
    if(!b->chains_230){cold_log(o,p,7147,1);goto failed_arrays;}
    b->records_100=o->allocate(p,VN135_C_RECORDS,(uint32_t)count,12);
    if(!b->records_100){cold_log(o,p,7154,1);goto failed_arrays;}
    if(cold_object(o,p,0x82048,m,0,b->records_100,(uint32_t)count,0)){
        cold_log(o,p,7159,1);
        if(b->records_100){
            (void)cold_object(o,p,0x593c8c,b->records_100,0,NULL,0,0);
            b->records_100=NULL;
        }
        goto failed_arrays;
    }
    for(i=0;i<count;++i){
        struct vn135_cold_chain *c=&b->chains_230[i];
        c->index=(uint32_t)i;c->parent=b;
        c->chips=o->allocate(p,VN135_C_CHIPS,(uint32_t)m->board_word_10,96);
        if(!c->chips){cold_log(o,p,7172,1);goto failed_arrays;}
        c->items=o->allocate(p,VN135_C_ITEMS,(uint32_t)m->table_count,128);
        if(!c->items){cold_log(o,p,7178,1);goto failed_arrays;}
        for(j=0;j<m->board_word_10;++j){
            c->chips[j].index=(uint32_t)j;
            c->chips[j].word_04=(uint32_t)j*m->board_word_0; /* original 0x53d98 */
        }
        (void)cold_object(o,p,0x5a60dc,c,0,NULL,0,0);
    }
    (void)cold_object(o,p,0x5a60dc,b,0x260,NULL,0,0);
    (void)cold_object(o,p,0x5a60dc,b,0x6d8,NULL,0,0);
    (void)cold_object(o,p,0x5a60dc,b,0xb50,NULL,0,0);
    b->byte_211=0;b->word_20=0;
    (void)cold_object(o,p,0x5c4dc,b,0x12e0,NULL,m->model_word_34,0);
    route=(uint32_t)o->scalar(p,0xfdfac,0,0,0);
    k=(m->model_word_34|route)?(m->model_word_34==1?1u:2u):0u;
    for(j=0;j<7;++j)b->targets[j]=targets[k][j];
    limits=o->allocate(p,VN135_C_LIMITS,1,72);b->limits_1c=limits;
    if(!limits){cold_log(o,p,7393,1);return VN135_C_RETURNED;}
    b->alias_78=limits;
    if(cold_object(o,p,0xb2a88,limits,0,NULL,0,0)){cold_log(o,p,7399,1);goto failed_setup;}
    if(cold_object(o,p,0x49b38,b,0x10b4,NULL,0,0)){cold_log(o,p,7405,1);goto failed_setup;}
    if(cold_object(o,p,0xb86fc,b,0,NULL,0,0)){cold_log(o,p,7411,1);goto failed_setup;}
    if(cold_object(o,p,0x81f68,b,0,NULL,0,0)){cold_log(o,p,7418,1);goto failed_setup;}
    if(cold_object(o,p,0xd21dc,b,0x110,NULL,m->chip_selector,m->model_byte_2c)){
        cold_log(o,p,7427,1);
        (void)cold_object(o,p,0x49c98,b,0x10b4,NULL,1004,0);
        return cold_fatal(r,1004);
    }
    r->device->word_98=1;r->device->word_20=0;
    r->device->driver=driver;r->device->data=b;
    (void)cold_object(o,p,0x35830,r->device,0,NULL,0,0);
    return VN135_C_RETURNED;
failed_arrays:
    cold_log(o,p,7382,1);
    /* Original puts literal 0x10b4 into r0 on these failure paths.
     * Report only the callee boundary; NEVER dereference that address. */
    (void)cold_object(o,p,0x49c98,NULL,0x10b4,NULL,1001,0);
    return cold_fatal(r,1001);
failed_setup:
    (void)cold_object(o,p,0x49c98,b,0x10b4,NULL,1001,0);
    return cold_fatal(r,1001);
}

/* Original callees 0x5db54 and 0x6c61c; cached data is not a live sensor. */
#include "integration/backend_peripheral_135.h"
int vn135_backend_collect_5db54_135(struct vn135_peripheral_state *s,
    const struct vn135_peripheral_ops *o,void *p,int32_t *out)
{
    int32_t count=o->chain_count(p),i;int found=0;
    for(i=0;i<count;++i){
        struct vn135_peripheral_chain *c=&s->chains[i];
        /* Existing original chain predicate 0x56fcc. */
        if(!c->byte_24 || c->word_20-3u<=2u)continue;
        (void)o->lock(p,(uint32_t)i);
        if(c->byte_2b0){
            if(!found)*out=c->word_2ac;
            if(*out<c->word_2ac)*out=c->word_2ac;
            found=1;
        }
        (void)o->unlock(p,(uint32_t)i);
    }
    return found?0:-1;
}
int vn135_backend_configure_6c61c_135(struct vn135_peripheral_state *s,
    const struct vn135_peripheral_ops *o,void *p)
{
    struct vn135_peripheral_profile *profile=s->profile;
    uint32_t count_type4=0;int32_t i,reading=0;int aggregate=0;
    if(s->mode_50==2)return 0;
    for(i=0;i<profile->table_count;++i)
        if(profile->entries[i].type==4)
            count_type4+=(uint32_t)(profile->entries[i].byte_19^1u);
    aggregate=bits_signed(count_type4)>1;
    if(!aggregate)for(i=0;i<profile->table_count;++i)
        if(profile->entries[i].type==0||profile->entries[i].type==3){aggregate=1;break;}
    if(!aggregate){(void)o->apply_f8a30(p,profile->model_bc_08);return 0;}
    if(vn135_backend_collect_5db54_135(s,o,p,&reading)){
        if(o->log)o->log(p,1504);
        return -1;
    }
    (void)o->apply_f86a8(p,profile->model_f0_00,
                       (uint32_t)(reading>45?reading:45),s->word_6c,s->word_70);
    return 0;
}

/* Original preparation 0x7409c and fan polling 0x7755c.
 * See integration/BACKEND_PREPARE_135_RU.md for exact callee boundaries.
 */
#include "integration/backend_prepare_135.h"
static int32_t prepare_step(const struct vn135_prepare_ops *o,void *p,
    uint32_t source,uint32_t a,uint32_t b,uint32_t c)
{ return o->step(p,source,a,b,c); }
static void prepare_log(const struct vn135_prepare_ops *o,void *p,
    uint32_t line,uint32_t level,uint32_t a,uint32_t b,const char *text)
{ if(o->log)o->log(p,line,level,a,b,text); }
static int prepare_fail(const struct vn135_prepare_ops *o,void *p,
    uint32_t line,uint32_t code)
{
    prepare_log(o,p,line,1,0,0,NULL);
    (void)prepare_step(o,p,0x49c98,code,0,0);
    (void)prepare_step(o,p,0x5e92c,0,0,0);
    return 0;
}
void vn135_backend_poll_fans_135(struct vn135_prepare_state *s,
    const struct vn135_prepare_ops *o,void *p)
{
    struct vn135_prepare_profile *f=s->profile;
    int32_t i,ceiling;
    if(f->fan_count<1)return;
    ceiling=bits_signed((uint32_t)f->fan_word_0c*3u);
    for(i=0;i<f->fan_count;++i){
        struct vn135_prepare_fan *fan=&s->fans[i];
        int32_t scale=prepare_step(o,p,0xfe2f0,0,0,0);
        int32_t reading,first;
        (void)prepare_step(o,p,0x5a6108,(uint32_t)i,0,0);
        first=prepare_step(o,p,0xfe300,(uint32_t)i,0,0);
        reading=f->fan_word_0c;
        if(first<reading)reading=prepare_step(o,p,0xfe300,(uint32_t)i,0,0);
        fan->word_20=reading;
        if(reading<=ceiling && reading>=1 && fan->byte_1c){
            fan->byte_1c=0;
            s->word_23c=bits_signed((uint32_t)s->word_23c+1u);
        }else if(!(reading!=0 && reading<=ceiling) && scale>=10 && !fan->byte_1c){
            fan->byte_1c=1;
            s->word_23c=bits_signed((uint32_t)s->word_23c-1u);
        }
        (void)prepare_step(o,p,0x5a66c4,(uint32_t)i,0,0);
    }
}
int vn135_backend_prepare_135(struct vn135_prepare_state *s,
    const struct vn135_prepare_ops *o,void *p,struct vn135_prepare_scratch *scratch)
{
    struct vn135_prepare_limits *limits=s->limits;
    struct vn135_prepare_profile *fans;
    void *stream;
    int32_t value,i;
    unsigned remaining;
    uint32_t mode;
    uint8_t flag;
    s->word_28=0;s->word_2c=0;s->byte_24=0;s->byte_fe5=0;
    s->byte_104a=0;s->word_1070=0;
    if(prepare_step(o,p,0x4f2d0,0x50,0,0))return prepare_fail(o,p,7480,1002);
    if(prepare_step(o,p,0xb86d0,0,0,0) && s->byte_85)
        (void)prepare_step(o,p,0xb9148,0,0,0);
    value=o->stat_path(p,s->byte_f4?"/config/stopped":"/tmp/stopped");
    s->byte_210=(uint8_t)(value>=0);
    s->text_fc8=o->duplicate(p,s->text_90);
    mode=(uint32_t)prepare_step(o,p,0x82d60,0x50,0,0);
    *s->platform_byte=(uint8_t)mode;
    if(o->initialize_psu(p,limits->lower_30,limits->upper_34,limits->word_14))
        return prepare_fail(o,p,7495,2001);
    value=s->word_10c;
    if(value){
        if(value<1500)value=1500;
        if(value>s->limits->word_3c)value=s->limits->word_3c;
    }else value=s->profile->word_1c;
    s->word_10c=value;
    stream=o->serial_open(p,"/config/serial","r");
    if(stream){
        if(o->serial_read(p,stream,"%255s",scratch->serial)==1)
            prepare_log(o,p,201,3,0,0,scratch->serial);
        (void)o->serial_close(p,stream);
    }
    if(prepare_step(o,p,0xf96a0,0,0,0))return prepare_fail(o,p,7506,2002);
    if(prepare_step(o,p,0xb4c58,0,0,0))return prepare_fail(o,p,7513,2003);
    fans=s->profile;
    if(s->mode_50==2){
        (void)prepare_step(o,p,0xf8b60,0,0,0);
    }else{
        (void)prepare_step(o,p,0xf8a30,30,0,0);
        prepare_log(o,p,253,3,0,0,NULL);
        for(remaining=15;remaining;--remaining){
            vn135_backend_poll_fans_135(s,o,p);
            (void)prepare_step(o,p,0x10ef3c,1000,0,0);
            if(s->word_23c>=fans->fan_count)break;
        }
        for(i=0;i<fans->fan_count;++i){
            (void)prepare_step(o,p,0x5a6108,(uint32_t)i,0,0);
            flag=s->fans[i].byte_1c;
            (void)prepare_step(o,p,0x5a66c4,(uint32_t)i,0,0);
            prepare_log(o,p,271,3,(uint32_t)i+1u,0,flag?"lost":"ok");
        }
        value=s->word_23c;
        if(value<s->word_68){
            prepare_log(o,p,275,1,(uint32_t)value,(uint32_t)fans->fan_count,NULL);
            (void)prepare_step(o,p,0x49c98,2004,(uint32_t)s->word_23c,
                              (uint32_t)fans->fan_count);
            prepare_log(o,p,7520,1,0,0,NULL);
            (void)prepare_step(o,p,0x5e92c,0,0,0);
            return 0;
        }
    }
    if(prepare_step(o,p,0xa1fe0,0,0,0))return prepare_fail(o,p,7526,1001);
    if(o->thread_create(p,0xff4,0x7bfc0,&s->thread_ff4))
        return prepare_fail(o,p,7533,1001);
    return 1;
}

#ifdef VN135_THERMAL_ROUTES_135
/* Opt-in offline target: old isolated base tests keep their link boundary. */
/* Original decoded hashchip temperature reply, entry 0x78aa4. */
#include "integration/thermal_routes_135.h"
static void note(vn135_route_log fn,void *p,enum vn135_route_log_source src,
    uint32_t line,const uint32_t *a,size_t n)
{ if(fn)fn(p,src,line,a,n); }
int vn135_temperature_reply_135(const struct vn135_reply_profile *profile,
    struct vn135_route_chain *chains,const struct vn135_temperature_reply *r,
    const struct vn135_reply_ops *o,void *p,uint32_t *thread_scratch)
{
    int32_t i,slot,count=o->chain_count(p);
    struct vn135_route_chain *c;struct vn135_temperature_sensor *s;
    uint32_t local,remote,status,error,args[6];
    for(i=0;i<profile->sensor_count;++i)if(profile->description_types[i]==2)break;
    if(profile->sensor_count<1 || i==profile->sensor_count)return 0;
    if(r->chain_index<0 || r->chain_index>=count)return 0;
    c=chains+r->chain_index;
    slot=vn135_temperature_lookup_chip_135(c,r->chip_address);
    if(slot<0){args[0]=r->chip_address;note(o->log,p,VN135_ROUTE_REPLY,1577,args,1);return -1;}
    s=c->sensors+slot;local=(r->payload>>16)&255u;error=r->payload>>24;
    remote=s->remote_enabled?(r->payload&255u):local;
    status=s->remote_enabled?((r->payload>>8)&255u):1u;
    if(error || status!=1){
        args[0]=c->index+1u;args[1]=s->index+1u;args[2]=status;
        args[3]=remote;args[4]=error;args[5]=local;
        note(o->log,p,VN135_ROUTE_REPLY,1595,args,6);return 0;
    }
    vn135_temperature_accept_chip_135(c,bits_signed(s->index),(int32_t)local,(int32_t)remote,o,p);
    vn135_temperature_aggregate_135(c,o,p);
    if(o->overheat(p,c)){
        note(o->log,p,VN135_ROUTE_REPLY,1603,NULL,0);
        (void)o->backend_action(p,c);
        if(o->create_stop_thread(p,0x72ba4u,thread_scratch)){
            note(o->log,p,VN135_ROUTE_REPLY,6483,NULL,0);
            (void)o->power_stop(p);
        }
    }
    return 0;
}

#endif /* VN135_THERMAL_ROUTES_135 */

#ifdef VN135_BACKEND_SHUTDOWN_135
#include "integration/backend_shutdown_135.h"
static void shutdown_thread_135(struct vn135_shutdown_thread *t,
    const struct vn135_shutdown_ops *o,void *p)
{
    uint32_t self,handle;
    if(!t->running)return;
    t->running=0;self=o->self(p);handle=t->handle;
    if(self==handle)(void)o->detach(p,self);
    else{(void)o->cancel(p,handle);(void)o->join(p,t->handle,NULL);}
}
void vn135_backend_shutdown_135(struct vn135_shutdown_state *s,
    const struct vn135_shutdown_ops *o,const struct vn135_backend_power_ops *power,
    void *p,struct vn135_shutdown_scratch *scratch)
{
    const char *marker=s->persistent_marker?"/config/stopped":"/tmp/stopped";
    int32_t count,i;uint32_t v;uint8_t board_flag;
#define STEP(ep,a) o->step(p,(ep),(a))
    while(o->trylock(p))(void)o->delay_ms(p,100);
    if((s->state|2u)==6u){(void)o->unlock(p);return;}
    if(o->log)o->log(p,6504);
    if(!STEP(0xfdeb4,0) && !s->state)goto finish;
    if(STEP(0x8291c,0))(void)STEP(0x860b8,0);
    if((s->model_chip_selector&~1u)!=6u)shutdown_thread_135(&s->threads[0],o,p);
    if((STEP(0xfdfbc,0)|2u)==2u)shutdown_thread_135(&s->threads[1],o,p);
    (void)STEP(0xa6080,0);
    shutdown_thread_135(&s->threads[2],o,p);
    shutdown_thread_135(&s->threads[3],o,p);
    shutdown_thread_135(&s->threads[4],o,p);
    (void)STEP(0x663cc,0);
    for(i=5;i<9;++i)shutdown_thread_135(&s->threads[i],o,p);
    count=power->chain_count(p);
    for(i=0;i<count;++i)(void)STEP(0x58d08,(uint32_t)i);
    v=STEP(0x19c,0);(void)o->cleanup(p,scratch->cleanup,v);
    if(s->fan_readings && s->mode!=2u)
        for(i=0;i<s->fan_count;++i)s->fan_readings[i]=0;
    board_flag=s->board_byte_4f;
    count=power->chain_count(p);
    s->byte_fe6=0;s->word_fe8=0;s->word_fec=0;
    for(i=0;i<count;++i)(void)STEP(board_flag?0x5a9fc:0x5ac80,(uint32_t)i);
    (void)STEP(0x1082b4,0);
    (void)vn135_backend_power_stop_135(&s->power,power,p);
    (void)STEP(0x2f6ec,0);
    if(s->threads[9].running){
        v=s->threads[9].handle;s->threads[9].running=0;
        (void)o->join(p,v,&scratch->join_result);
    }
    (void)STEP(0xf98b8,1);(void)STEP(0xf9840,0);
finish:
    s->state=6;(void)o->mark_stopped(p,marker);
#undef STEP
    (void)o->unlock(p);
}
int vn135_backend_shutdown_worker_135(struct vn135_shutdown_state *s,
    const struct vn135_shutdown_ops *o,const struct vn135_backend_power_ops *power,
    void *p,struct vn135_shutdown_scratch *scratch)
{
    (void)o->set_thread_name(p,"failure@btm");
    (void)o->detach(p,o->self(p));
    (void)vn135_backend_shutdown_135(s,o,power,p,scratch);
    return 0;
}
#endif

/* Original temperature-read worker 668a8 and abort dispatcher 66f80.
 * Explicit source selection: separate from the native cgminer runtime. */
#ifdef VN135_SENSOR_MONITOR_135
#include "integration/sensor_monitor_135.h"
static void monitor_log(const struct vn135_sensor_monitor_ops *o,void *p,
    uint32_t line,uint32_t chain,uint32_t sensor,int32_t failures)
{ if(o->log)o->log(p,line,chain,sensor,failures); }
void vn135_temperature_monitor_abort_135(const struct vn135_sensor_monitor_ops *o,
    void *p,uint32_t *thread_scratch)
{
    if(o->create_shutdown(p,0x72ba4,thread_scratch)) {
        monitor_log(o,p,6483,0,0,0);
        (void)o->power_stop(p);
    }
}
void vn135_temperature_monitor_135(struct vn135_sensor_monitor *s,
    const struct vn135_sensor_monitor_ops *o,void *p,uint32_t *thread_scratch)
{
    int32_t sensor_count=s->sensor_count;
    int32_t chain_count=o->chain_count(p),i,j;
    (void)o->set_cancel_type(p,1);
    (void)o->set_name(p,"temp_read@btm");
    s->running=1;
    do {
        double elapsed=o->now(p)-s->last_chip_poll;
        for(i=0;i<chain_count;++i) {
            struct vn135_route_chain *chain=&s->chains[i];
            if(!chain->present || chain->state-3u<3u)continue;
            for(j=0;j<sensor_count;++j) {
                struct vn135_temperature_sensor *sensor=&chain->sensors[j];
                if(sensor->access_kind>4 || sensor->access_kind==2 || sensor->state==3)continue;
                if(s->state==4)goto wait_next;
                if(o->read_sensor(p,chain,sensor))
                    monitor_log(o,p,4907,chain->index+1u,sensor->index+1u,sensor->failures);
                if(sensor->state==3 && (s->mode==2 || sensor->role==2)) {
                    monitor_log(o,p,4912,chain->index+1u,sensor->index+1u,0);
                    if(s->suppress_fault_stop)continue;
                    (void)o->stop_chain(p,chain,"Lost temp sensors");
                    if(o->after_chain_stop(p)) {
                        (void)o->event(p,2006);
                        goto abort_worker;
                    }
                }
                o->aggregate(p,chain);
                if(o->overheat(p,chain)) {
                    monitor_log(o,p,4929,0,0,0);
                    goto abort_worker;
                }
                (void)o->delay_ms(p,200);
            }
            if(elapsed>5.0 && (s->state|1u)==3u) {
                (void)o->refresh_chip_temperatures(p,chain);
                o->aggregate(p,chain);
                if(o->overheat(p,chain)) {
                    monitor_log(o,p,4943,0,0,0);
                    o->before_timed_abort(p);
                    goto abort_worker;
                }
            }
        }
        if(elapsed>5.0)s->last_chip_poll=o->now(p);
wait_next:
        (void)o->delay_ms(p,1000);
    } while(s->running);
    o->worker_exit(p,0);
    return;
abort_worker:
    vn135_temperature_monitor_abort_135(o,p,thread_scratch);
    o->worker_exit(p,0);
}
#endif

/* Original general control worker 79778..7bb44 (literals through 7bc78).
 * Reuses the existing temperature and fan field views. Only this separate
 * offline target enables the body; it is not linked into production cgminer. */
#ifdef VN135_GENERAL_MONITOR_135
#include "integration/general_monitor_135.h"
#include <stdio.h>
#include <string.h>
static int general_alive(const struct vn135_general_chain *c)
{ return c->thermal.present && (c->thermal.state-3u)>2u; }
static int general_active_state(uint32_t state)
{ return (state|1u)==3u; }
static int32_t general_call(const struct vn135_general_ops *o,void *p,
    uint32_t op,uint32_t a,uint32_t b)
{ return o->call(p,op,a,b); }
static void general_log(const struct vn135_general_ops *o,void *p,
    uint32_t line,uint32_t level,uint32_t a,uint32_t b,double value,const char *detail)
{ if(o->log)o->log(p,line,level,a,b,value,detail); }
static void general_abort(const struct vn135_general_ops *o,void *p,
    struct vn135_general_scratch *scratch,uint32_t slot)
{
    if(o->create_shutdown(p,slot,0x72ba4,&scratch->handles[slot])){
        general_log(o,p,6483,1,0,0,0.0,NULL);
        (void)general_call(o,p,VN135_G_POWER_STOP,0,0);
    }
}
void vn135_general_monitor_135(struct vn135_general_monitor *s,
    const struct vn135_general_ops *o,void *p,struct vn135_general_scratch *scratch)
{
    double limit,now,rate,total,gap,measured;
    int32_t n,i,j,required,available,target,current,maximum,prior,next,count;
    uint32_t power,alive,kind;
    uint8_t boot;
    struct vn135_general_model *m;
    struct vn135_general_chain *c;
    struct vn135_temperature_sensor *sensors;
    char reason[256];
#define GC(op,a,b) general_call(o,p,(op),(uint32_t)(a),(uint32_t)(b))
#define G0(op) GC(op,0,0)
#define GL(line,level,a,b,v) general_log(o,p,(line),(level),(uint32_t)(a),(uint32_t)(b),(v),NULL)
    (void)GC(VN135_G_CANCEL_TYPE,1,0);
    (void)G0(VN135_G_NAME);
    s->running=1;
    limit=s->model->kind_34==0?1.0e9:s->model->kind_34==1?3.0e9:0.0;
    do {
        (void)G0(VN135_G_FANS);
        m=s->model;
        if(s->running){
            required=s->required_fans;available=s->available_fans;
            if(general_active_state(s->state) && s->mode!=2 && s->active &&
               o->now(p)-s->started_at>=10.0){
                /* The descriptor count is reread after each fan unlock. */
                for(i=0;i<m->fan_count_bc;++i){
                    (void)GC(VN135_G_LOCK,VN135_G_FAN_LOCK,i);
                    if(s->fans[i].lost && available<required)
                        GL(2207,3,s->fans[i].index+1u,0,0.0);
                    (void)GC(VN135_G_UNLOCK,VN135_G_FAN_LOCK,i);
                }
                if(available<required){
                    (void)GC(VN135_G_EVENT,2004,s->available_fans);
                    (void)G0(VN135_G_STOP);
                }
            }
        }
        n=G0(VN135_G_CHAIN_COUNT);
        if(s->running && general_active_state(s->state)){
            if(!s->suppress_thermal){
                for(i=0;i<n;++i){
                    c=&s->chains[i];
                    if(general_alive(c) && GC(VN135_G_THERMAL,i,s->mode)){
                        (void)o->stop_chain(p,&c->thermal,"Lost temp sensors");
                        (void)G0(VN135_G_FULL_FAN);
                        if(G0(VN135_G_AFTER_STOP)){
                            (void)GC(VN135_G_EVENT,2006,0);
                            general_abort(o,p,scratch,0);
                            break;
                        }
                    }
                }
            }else if(!G0(VN135_G_SENSOR_TEST) && !G0(VN135_G_CHIP_SENSOR_TEST)){
                m=s->model;
                n=G0(VN135_G_CHAIN_COUNT);
                if(n>0){
                    count=m->sensor_count;
                    for(i=0;i<n;++i){
                        c=&s->chains[i];
                        if(!general_alive(c) || count<1)continue;
                        sensors=c->thermal.sensors;
                        for(j=0;j<count;++j)
                            if(sensors[j].access_kind==4 && sensors[j].role==2 &&
                               sensors[j].state!=3)goto sensors_finished;
                    }
                }
                GL(2364,1,0,0,0.0);
                (void)G0(VN135_G_FULL_FAN);
                (void)GC(VN135_G_EVENT,2006,0);
                general_abort(o,p,scratch,1);
            }
        }
sensors_finished:
        m=s->model;
        kind=(uint32_t)G0(VN135_G_PLATFORM);
        n=G0(VN135_G_CHAIN_COUNT);
        if(s->running && s->active && !s->suppress_chain_check && !s->tuning &&
           general_active_state(s->state)){
            if((kind&~2u)==0){
                for(i=0;i<n;++i){
                    c=&s->chains[i];
                    if(!general_alive(c) || c->detected_8c==(uint32_t)m->expected_chips_48)continue;
                    (void)snprintf(reason,sizeof reason,
                        "Chain break detected (%d of %d chips replied)",
                        bits_signed(c->detected_8c),m->expected_chips_48);
                    general_log(o,p,2565,2,c->thermal.index+1u,0,0.0,reason);
                    if(s->model->query_fault_87){
                        (void)o->read_chain_fault(p,(uint32_t)i,&c->fault_3c);
                        GL(2569,2,c->thermal.index+1u,c->fault_3c,0.0);
                        (void)o->stop_chain(p,&c->thermal,reason);
                    }
                    (void)GC(VN135_G_EVENT,2008,0);
                    (void)G0(VN135_G_PRE_STOP);
                    (void)G0(VN135_G_STOP);
                }
            }else if(kind==1 || kind-3u<5u){
                now=o->now(p);
                if(now-s->history->chain_check>=10.0){
                    (void)GC(VN135_G_LOCK,VN135_G_BACKEND_LOCK,0);
                    for(i=0;i<n;++i){
                        c=&s->chains[i];
                        if(!general_alive(c) || !GC(VN135_G_CHAIN_CHECK,i,0))continue;
                        GL(2604,2,c->thermal.index+1u,0,0.0);
                        if(s->model->query_fault_87){
                            (void)o->read_chain_fault(p,(uint32_t)i,&c->fault_3c);
                            GL(2608,2,c->thermal.index+1u,c->fault_3c,0.0);
                            (void)o->stop_chain(p,&c->thermal,"Chain break detected");
                        }
                        (void)GC(VN135_G_EVENT,2008,0);
                        (void)G0(VN135_G_PRE_STOP);
                        (void)G0(VN135_G_STOP);
                    }
                    (void)GC(VN135_G_UNLOCK,VN135_G_BACKEND_LOCK,0);
                    s->history->chain_check=now;
                }
            }
        }
        if(s->running && general_active_state(s->state) && s->psu_monitoring && (s->psu_valid&7u)){
            maximum=0;
            if((s->psu_valid&1u) && s->psu_temperatures[0]>0)maximum=s->psu_temperatures[0];
            if((s->psu_valid&2u) && s->psu_temperatures[1]>maximum)maximum=s->psu_temperatures[1];
            if((s->psu_valid&4u) && s->psu_temperatures[2]>maximum)maximum=s->psu_temperatures[2];
            if(maximum>=s->psu_temperature_limit){
                GL(2894,2,maximum,0,0.0);GL(2895,1,0,0,0.0);
                (void)G0(VN135_G_PRE_STOP);
                (void)GC(VN135_G_EVENT,3005,maximum);
                general_abort(o,p,scratch,2);
            }
        }
        (void)G0(VN135_G_UPDATE);
        now=o->now(p);power=0;
        if(now-s->history->power_sample>=5.0 && general_active_state(s->state)){
            if(s->psu_monitoring){
                (void)o->read_power(p,&power);
            }else{
                n=G0(VN135_G_CHAIN_COUNT);
                for(i=0;i<n;++i)
                    if(general_alive(&s->chains[i]))power+=(uint32_t)GC(VN135_G_CHAIN_POWER,i,0);
            }
            s->sampled_power=power;
            s->history->power_sample=now;
        }
        boot=s->boot_flag;
        n=G0(VN135_G_CHAIN_COUNT);
        if(s->minimum_rate_percent && general_active_state(s->state) && !G0(VN135_G_POOL_FLAG)){
            now=o->now(p);
            if(s->tuning){
                s->history->rate_check=now;
            }else if(s->tune_percent==100 && s->running && s->active &&
                     now-s->started_at>=(boot?600.0:300.0) && now-s->history->rate_check>=90.0){
                count=G0(VN135_G_CHAIN_COUNT);alive=0;
                for(i=0;i<count;++i)alive+=(uint32_t)general_alive(&s->chains[i]);
                if(alive){
                    total=0.0;
                    for(i=0;i<n;++i){
                        c=&s->chains[i];
                        if(!general_alive(c))continue;
                        (void)GC(VN135_G_LOCK,VN135_G_CHAIN_LOCK,i);
                        memcpy(&measured,c->thermal.statistics,sizeof measured);
                        rate=0.0;
                        if(measured>=0.001)rate=(measured/o->number(p,0x59810,(uint32_t)i))*100.0;
                        (void)GC(VN135_G_UNLOCK,VN135_G_CHAIN_LOCK,i);
                        total+=rate;
                    }
                    rate=total/(double)bits_signed(alive);
                    if(rate<(double)s->minimum_rate_percent){
                        GL(2461,2,s->minimum_rate_percent,0,rate);
                        GL(2462,2,s->minimum_rate_percent,0,rate);
                        (void)GC(VN135_G_EVENT,1008,0);
                        (void)G0(VN135_G_STOP);
                    }
                    s->history->rate_check=now;
                }
            }
        }
        maximum=0;
        if(s->running && !s->mode && general_active_state(s->state)){
            current=G0(VN135_G_FAN_TARGET);
            if(current==s->target_temperature){
                s->history->fan_adjust=o->now(p);
            }else if(o->collect_temperature(p,&maximum)){
                GL(2654,2,0,0,0.0);
            }else{
                now=o->now(p);
                if(s->history->fan_adjust==0.0)s->history->fan_adjust=now;
                target=s->target_temperature;
                prior=s->history->previous_temperature;
                next=current;
                if(target>current){
                    if(maximum<prior && current<prior){
                        next=prior<target?prior:target;
                    }else if(maximum==prior){
                        gap=o->number(p,0xf8df0,0);
                        if(current<=maximum && (gap<1.0 || now-s->history->fan_adjust>=30.0)){
                            next=bits_signed((uint32_t)current+10u);
                            if(next>s->target_temperature)next=s->target_temperature;
                        }
                    }
                }else{
                    if(maximum>prior && current>prior){
                        next=prior>target?prior:target;
                    }else if(maximum==prior){
                        gap=o->number(p,0xf8df0,0);
                        if(current>=maximum && (gap<1.0 || now-s->history->fan_adjust>=30.0)){
                            next=bits_signed((uint32_t)current-10u);
                            if(next<s->target_temperature)next=s->target_temperature;
                        }
                    }
                }
                if(next!=current){
                    (void)GC(VN135_G_SET_FAN_TARGET,next,0);
                    s->history->fan_adjust=now;
                }
                s->history->previous_temperature=maximum;
            }
        }
        now=o->now(p);
        if(general_active_state(s->state) && G0(VN135_G_PSU_AVAILABLE) &&
           now-s->history->psu_sample>=5.0){
            (void)o->read_psu(p,&s->psu_valid,s->psu_temperatures);
            s->history->psu_sample=now;
        }
        (void)G0(VN135_G_MAINTAIN);
        (void)G0(VN135_G_TUNE_MAINTAIN);
        (void)G0(VN135_G_STATE_MAINTAIN);
        if(G0(VN135_G_POOL_FLAG) && G0(VN135_G_POOL_MODE)==1)(void)G0(VN135_G_POOL_UPDATE);
        if(limit>0.001 && *s->global_rate>=limit)(void)G0(VN135_G_RATE_ACTION);
        (void)GC(VN135_G_DELAY,1000,0);
    }while(s->running);
    (void)G0(VN135_G_EXIT);
#undef GL
#undef G0
#undef GC
}
#endif

/* Original internal monitor handlers 60730/60a2c/60d58/5e53c. */
#ifdef VN135_MONITOR_HANDLERS_135
#ifndef VN135_GENERAL_MONITOR_135
#error "Monitor handlers use the existing general-monitor field views"
#endif
#include "integration/monitor_handlers_135.h"
#include <stdlib.h>
static int32_t handler_call(const struct vn135_monitor_handler_ops *o,void *p,
    uint32_t entry,uint32_t a,uint32_t b)
{ return o->call(p,entry,a,b); }
static void handler_log(const struct vn135_monitor_handler_ops *o,void *p,
    uint32_t line,uint32_t level,uint32_t a,uint32_t b,const char *detail)
{ if(o->log)o->log(p,line,level,a,b,detail); }
static uint32_t handler_active_count(struct vn135_monitor_handlers *s,
    const struct vn135_monitor_handler_ops *o,void *p)
{
    int32_t i,n=handler_call(o,p,VN135_H_CHAIN_COUNT,0,0);
    uint32_t count=0;
    for(i=0;i<n;++i)count+=(uint32_t)general_alive(&s->general->chains[i]);
    return count;
}
int32_t vn135_monitor_chain_decision_135(struct vn135_monitor_handlers *s,
    const struct vn135_monitor_handler_ops *o,void *p)
{
    uint32_t active=handler_active_count(s,o,p),bad=0;
    int32_t i,n;
    /* Counts and fields are reread in source order. A missing/present flag
     * does not suppress the original state-3 and state-5 tests. */
    if(!s->general->model->query_fault_87 && !s->partial_chains_105){
        n=handler_call(o,p,VN135_H_CHAIN_COUNT,0,0);
        for(i=0;i<n;++i)bad+=(s->general->chains[i].thermal.state==3u);
        if(!bad){
            n=handler_call(o,p,VN135_H_CHAIN_COUNT,0,0);
            for(i=0;i<n;++i)bad+=(s->general->chains[i].thermal.state==5u);
        }
        if(bad){handler_log(o,p,445,1,0,0,NULL);return -1;}
    }
    if(bits_signed(active)<s->minimum_chains_f8){
        handler_log(o,p,451,1,active,(uint32_t)s->minimum_chains_f8,NULL);
        return -1;
    }
    return 0;
}
void vn135_monitor_check_chains_135(struct vn135_monitor_handlers *s,
    const struct vn135_monitor_handler_ops *o,void *p)
{
    if(!s->general->running || !general_active_state(s->general->state))return;
    if(vn135_monitor_chain_decision_135(s,o,p)){
        handler_log(o,p,2167,1,0,0,NULL);
        (void)handler_call(o,p,VN135_H_EVENT,2007,0);
        (void)handler_call(o,p,VN135_H_STOP,0,0);
    }
    /* No extra gate/return after STOP. The original recounts even when its
     * callback changes running/state, and can report a second event. */
    if(!handler_active_count(s,o,p)){
        handler_log(o,p,2173,1,0,0,NULL);
        (void)handler_call(o,p,VN135_H_EVENT,2007,0);
        (void)handler_call(o,p,VN135_H_STOP,0,0);
    }
}
void vn135_monitor_finish_warmup_135(struct vn135_monitor_handlers *s,
    const struct vn135_monitor_handler_ops *o,void *p)
{
    struct vn135_general_monitor *g=s->general;
    uint32_t entry,voltage;
    int32_t temperature,rc;
    double now;
    if(handler_call(o,p,VN135_H_PLATFORM,0,0)!=4 &&
       handler_call(o,p,VN135_H_PLATFORM,0,0)!=5)goto completed;
    now=o->now(p);
    if(now-g->started_at>900.0 || !s->warmup_e4 || g->mode || g->state==3u)
        goto completed;
    if(g->state!=2u || !g->active)return;
    if(o->collect_temperature(p,&temperature))return;
    if(temperature<g->target_temperature || s->warmup_done_22c)return;
    while(handler_call(o,p,VN135_H_TRYLOCK,0x1074,0))
        (void)handler_call(o,p,VN135_H_DELAY,10,0);
    (void)handler_call(o,p,VN135_H_CLEANUP_PUSH,0x5cf34,0);
    entry=handler_call(o,p,VN135_H_PLATFORM,0,0)==0?0x6100cu:0x61170u;
    voltage=s->power->word_20c;
    rc=o->reset_cores(p,entry,0,voltage);
    if(rc)handler_log(o,p,entry==0x6100cu?2737u:2740u,2,0,0,NULL);
    (void)handler_call(o,p,VN135_H_CLEANUP_POP,0,0);
    (void)handler_call(o,p,VN135_H_UNLOCK,0x1074,0);
completed:
    /* Failure of reset_cores does not leave this byte unset in the original. */
    s->warmup_done_22c=1;
}
void vn135_monitor_lower_preset_135(struct vn135_monitor_handlers *s,
    const struct vn135_monitor_handler_ops *o,void *p)
{
    const char *current;
    struct vn135_handler_profiles *table;
    struct vn135_handler_profile *previous=NULL;
    int32_t i;
    if(!s->lower_preset_95)return;
    current=s->current_preset_fc8;
    if(!current)return;
    table=s->profiles;
    for(i=table->count;i>1;){
        --i;
        if(!strcmp(table->entries[i].key,current)){
            previous=&table->entries[i-1];break;
        }
    }
    if(!previous)return;
    if(s->minimum_enabled_b0){
        const char *minimum=s->minimum_preset_b8;
        if(!minimum || atoi(previous->key)<atoi(minimum))return;
    }
    handler_log(o,p,2084,3,0,0,previous->label);
    handler_log(o,p,2065,3,0,0,previous->label);
    (void)o->set_profile(p,"autotune-profile",previous->key);
    handler_log(o,p,2067,3,0,0,previous->label);
}
int vn135_monitor_handler_dispatch_135(struct vn135_monitor_handlers *s,
    const struct vn135_monitor_handler_ops *o,void *p,uint32_t entry,int32_t *result)
{
    switch(entry){
    case 0x60730:vn135_monitor_check_chains_135(s,o,p);*result=0;return 1;
    case 0x60a2c:*result=vn135_monitor_chain_decision_135(s,o,p);return 1;
    case 0x60d58:vn135_monitor_finish_warmup_135(s,o,p);*result=0;return 1;
    case 0x5e53c:vn135_monitor_lower_preset_135(s,o,p);*result=0;return 1;
    default:return 0;
    }
}
#endif

/* Original stop/retry decision 5e92c and retry-count writer 5cea8. */
#ifdef VN135_STOP_POLICY_135
#include "integration/stop_policy_135.h"
#include <stdlib.h>
#include <string.h>

static void stop_policy_log(const struct vn135_stop_policy_ops *o, void *p,
    uint32_t line, uint32_t level, uint32_t a, uint32_t b, const char *detail)
{
    if (o->log) o->log(p, line, level, a, b, detail);
}

void vn135_restart_count_store_135(const struct vn135_restart_count_ops *o,
                                  void *p, int32_t value)
{
    void *stream = o->open(p, "/tmp/restart_count", "w");
    if (stream) {
        (void)o->print(p, stream, "%d", value);
        (void)o->close(p, stream);
    }
}

static enum vn135_stop_flow stop_policy_exit(const struct vn135_stop_policy_ops *o,
                                            void *p)
{
    o->before_process_exit(p);
    o->request_process_exit(p, 0);
    return VN135_STOP_PROCESS_EXIT;
}

enum vn135_stop_flow vn135_stop_policy_135(struct vn135_stop_policy *s,
    const struct vn135_stop_policy_ops *o, void *p)
{
    uint32_t saved_event = o->event_code(p);
    char description[512] = {0};
    struct vn135_handler_profile *profile;
    void *stream;
    int32_t attempts = 0, limit;

    if (s->handlers->minimum_enabled_b0 && s->raise_failed_c8 && s->word_30 == 1) {
        profile = o->profile(p, 0x82ee8, s->text_3c);
        if (profile) {
            const char *key = profile->key;
            const char *top = *s->top_preset_90;
            int32_t value = (int32_t)atoi(key);
            int32_t ceiling = (int32_t)atoi(top);
            if (value >= ceiling) {
                (void)o->profile_action(p, 0x4dedc, key);
                (void)o->describe_event(p, description, sizeof(description));
                stop_policy_log(o, p, 2113, 2, 0, 0, description);
                stop_policy_log(o, p, 2114, 3, 0, 0, profile->label);
            }
        }
    }

    stream = o->counter->open(p, "/tmp/restart_count", "rb");
    if (stream) {
        (void)o->counter->scan(p, stream, "%d", &attempts);
        (void)o->counter->close(p, stream);
    }
    limit = s->retry_limit_88;
    if (limit >= 1 && attempts < limit) {
        uint32_t next = (uint32_t)attempts + 1u;
        (void)o->describe_event(p, description, sizeof(description));
        /* The limit is read again AFTER the description callback. The branch
         * has already been chosen; mutations do not re-evaluate that choice. */
        stop_policy_log(o, p, 2123, 3, next, (uint32_t)s->retry_limit_88, description);
        vn135_restart_count_store_135(o->counter, p, bits_signed(next));
        return stop_policy_exit(o, p);
    }

    if (limit != 0 && s->retune_104 && strcmp(*s->top_preset_90, "disabled") != 0) {
        uint32_t probe[5] = {0};
        profile = o->profile(p, 0x82d68, NULL);
        if (profile) {
            int32_t rc = o->probe_profile(p, profile->key, probe);
            /* Probe runs before checking the event captured at ENTRY, even
             * when a different event now occupies the backend event record. */
            if (saved_event == 2008u && rc == 0) {
                stop_policy_log(o, p, 2139, 1, 0, 0, profile->label);
                (void)o->profile_action(p, 0x94090, profile->key);
                return stop_policy_exit(o, p);
            }
        }
    }

    o->shutdown(p);
    return VN135_STOP_RETURNED;
}

int vn135_stop_policy_dispatch_135(struct vn135_stop_policy *s,
    const struct vn135_stop_policy_ops *o, void *p, uint32_t entry,
    enum vn135_stop_flow *flow)
{
    if (entry != 0x5e92c) return 0;
    *flow = vn135_stop_policy_135(s, o, p);
    return 1;
}
#endif /* VN135_STOP_POLICY_135 */

/* Original pre-exit teardown 5f0fc, distinct from common shutdown 5fc54. */
#ifdef VN135_EXIT_CLEANUP_135
#ifndef VN135_BACKEND_SHUTDOWN_135
#error "Exit cleanup reuses the existing shutdown thread helper"
#endif
#include "integration/exit_cleanup_135.h"
void vn135_backend_before_exit_135(struct vn135_shutdown_state *s,
    const struct vn135_shutdown_ops *o,const struct vn135_backend_power_ops *power,
    void *p,struct vn135_shutdown_scratch *scratch)
{
    int32_t count,i;uint32_t value;
#define EXIT_STEP(ep,a) o->step(p,(ep),(a))
    while(o->trylock(p))(void)o->delay_ms(p,100);
    if((s->state|2u)==6u)goto unlock;
    if(o->log)o->log(p,6420);
    if(!EXIT_STEP(0xfdeb4,0) && !s->state)goto unlock;
    s->state=4;
    if(EXIT_STEP(0x8291c,0))(void)EXIT_STEP(0x860b8,0);
    if((s->model_chip_selector&~1u)!=6u)shutdown_thread_135(&s->threads[0],o,p);
    if((EXIT_STEP(0xfdfbc,0)|2u)==2u)shutdown_thread_135(&s->threads[1],o,p);
    (void)EXIT_STEP(0xa6080,0);
    shutdown_thread_135(&s->threads[2],o,p);
    shutdown_thread_135(&s->threads[3],o,p);
    shutdown_thread_135(&s->threads[4],o,p);
    (void)EXIT_STEP(0x663cc,0);
    for(i=5;i<9;++i)shutdown_thread_135(&s->threads[i],o,p);
    (void)EXIT_STEP(0x287a4,0);
    count=power->chain_count(p);
    for(i=0;i<count;++i)(void)EXIT_STEP(0x58d08,(uint32_t)i);
    value=EXIT_STEP(0x19c,0);(void)o->cleanup(p,scratch->cleanup,value);
    if(s->fan_readings && s->mode!=2u)
        for(i=0;i<s->fan_count;++i)s->fan_readings[i]=0;
    if(s->board_byte_4f){
        count=power->chain_count(p);
        s->byte_fe6=0;s->word_fe8=0;s->word_fec=0;
        for(i=0;i<count;++i)(void)EXIT_STEP(0x5a9fc,(uint32_t)i);
    }
    (void)vn135_backend_power_stop_135(&s->power,power,p);
    (void)EXIT_STEP(0xf98b8,2);
unlock:
#undef EXIT_STEP
    (void)o->unlock(p);
}
#endif /* VN135_EXIT_CLEANUP_135 */

/* Shared thread-stop adapter for original rescue-service stop 287a4. */
#ifdef VN135_RESCUE_STOP_135
#ifndef VN135_BACKEND_SHUTDOWN_135
#error "Rescue stop requires the recovered thread helper"
#endif
#include "integration/rescue_stop_135.h"
void vn135_shutdown_thread_stop_135(struct vn135_shutdown_thread *worker,
    const struct vn135_shutdown_ops *ops, void *opaque)
{
    shutdown_thread_135(worker, ops, opaque);
}
#endif
