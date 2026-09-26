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
