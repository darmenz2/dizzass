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
