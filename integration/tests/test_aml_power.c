#include "integration/aml_power.h"
#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
static unsigned checks;
#define CHECK(x) do{++checks;if(!(x)){fprintf(stderr,"power:%d:%s\n",__LINE__,#x);exit(1);}}while(0)
struct trace {unsigned at,fail;};
static int step(struct trace *t,unsigned expected)
{unsigned at=t->at++;CHECK(at==expected);return t->fail&(1u<<at)?-(int)(at+20):0;}
static int stop(void *p,uint32_t chain){return step(p,chain);}
static int gpio(void *p,const struct dizzass_gpio_request *r)
{
    struct trace *t=p;unsigned at=t->at;
    CHECK(at>=3&&at<7);
    CHECK(r->pin==(at==3?437u:454u+at-4));CHECK(r->value==(at==3?1u:0u));
    return step(t,at);
}
int main(void)
{
    struct dizzass_gpio_request r,old;unsigned i,j,mask;
    for(i=0;i<3;++i)for(j=0;j<2;++j){CHECK(!dizzass_aml_reset_request(2,i,j,&r));CHECK(r.pin==454+i&&r.value==1-j);}
    for(j=0;j<2;++j){CHECK(!dizzass_aml_power_request(2,1,j,&r));CHECK(r.pin==437&&r.value==1-j);}
    memset(&r,0xa5,sizeof(r));old=r;
    CHECK(dizzass_aml_power_request(2,0,0,&r)==DIZZASS_POWER_NOT_READY);
    CHECK(!memcmp(&r,&old,sizeof(r)));
    CHECK(dizzass_aml_power_request(2,2,0,&r)==DIZZASS_POWER_INVALID);
    CHECK(dizzass_aml_power_request(1,1,0,&r)==DIZZASS_POWER_UNSUPPORTED);
    CHECK(dizzass_aml_power_request(2,1,-1,&r)==DIZZASS_POWER_INVALID);
    CHECK(dizzass_aml_reset_request(2,3,1,&r)==DIZZASS_POWER_INVALID);
    CHECK(dizzass_aml_reset_request(2,UINT32_MAX,1,&r)==DIZZASS_POWER_INVALID);
    CHECK(dizzass_aml_reset_request(2,1,3,&r)==DIZZASS_POWER_INVALID);
    CHECK(!memcmp(&r,&old,sizeof(r)));
    for(mask=0;mask<128;++mask){
        struct trace t={0,mask};struct dizzass_shutdown_ops ops={&t,stop,gpio};
        struct dizzass_shutdown_receipt receipt;int rc=dizzass_aml_quench(2,&ops,&receipt);
        CHECK(rc==(mask?DIZZASS_POWER_SHUTDOWN_FAILED:0));CHECK(t.at==7);
        CHECK(receipt.attempted_mask==127&&receipt.reported_ok_mask==(127u^mask));
        for(i=0;i<7;++i)CHECK(receipt.status[i]==(mask&(1u<<i)?-(int)(i+20):0));
    }
    {struct dizzass_shutdown_ops ops={0};struct dizzass_shutdown_receipt r2,save;
     memset(&r2,0xa5,sizeof(r2));save=r2;
     CHECK(dizzass_aml_quench(1,&ops,&r2)==DIZZASS_POWER_UNSUPPORTED);
     CHECK(!memcmp(&r2,&save,sizeof(r2)));
     CHECK(dizzass_aml_quench(2,&ops,&r2)==DIZZASS_POWER_SHUTDOWN_FAILED);
     CHECK(r2.attempted_mask==127&&r2.reported_ok_mask==0);
     for(i=0;i<7;++i)CHECK(r2.status[i]==DIZZASS_POWER_NOT_READY);}
    {struct dizzass_thermal_sample s={9,1000,50,60,15,1,1},save=s;
     struct dizzass_thermal_limits l={80,90,100};
     CHECK(dizzass_thermal_sample_check(&s,&l,9,1099)==0);
     CHECK(dizzass_thermal_sample_check(&s,&l,9,1100)==DIZZASS_THERMAL_TELEMETRY);
     CHECK(dizzass_thermal_sample_check(&s,&l,9,999)==DIZZASS_THERMAL_CLOCK);
     CHECK(dizzass_thermal_sample_check(&s,&l,8,1000)==DIZZASS_THERMAL_TELEMETRY);
     CHECK(dizzass_thermal_sample_check(NULL,&l,9,1000)==DIZZASS_THERMAL_TELEMETRY);
     for(mask=0;mask<15;++mask){s=save;s.valid=mask;CHECK(dizzass_thermal_sample_check(&s,&l,9,1000)==DIZZASS_THERMAL_TELEMETRY);}
     s=save;s.fans_ok=0;CHECK(dizzass_thermal_sample_check(&s,&l,9,1000)==DIZZASS_THERMAL_FAN);
     s=save;s.psu_ok=0;CHECK(dizzass_thermal_sample_check(&s,&l,9,1000)==DIZZASS_THERMAL_PSU);
     s=save;s.fans_ok=2;CHECK(dizzass_thermal_sample_check(&s,&l,9,1000)==DIZZASS_THERMAL_TELEMETRY);
     s=save;s.pcb=80;s.chip=90;CHECK(dizzass_thermal_sample_check(&s,&l,9,1000)==DIZZASS_THERMAL_PCB);
     s.pcb=79;CHECK(dizzass_thermal_sample_check(&s,&l,9,1000)==DIZZASS_THERMAL_CHIP);
     s=save;s.observed_ms=UINT64_MAX;CHECK(dizzass_thermal_sample_check(&s,&l,9,0)==DIZZASS_THERMAL_CLOCK);
     s.observed_ms=0;CHECK(dizzass_thermal_sample_check(&s,&l,9,UINT64_MAX)==DIZZASS_THERMAL_TELEMETRY);
     l.max_age_ms=0;CHECK(dizzass_thermal_sample_check(&s,&l,9,0)==DIZZASS_POWER_INVALID);}
    CHECK(dizzass_thermal_cutoff(INT32_MIN,INT32_MIN,INT32_MAX,INT32_MAX)==0);
    CHECK(dizzass_thermal_cutoff(INT32_MAX,INT32_MAX,INT32_MAX,INT32_MAX)==DIZZASS_THERMAL_PCB);
    printf("AML_POWER_C_PASS checks=%u shutdown_failure_combinations=128 hardware=no\n",checks);
    return 0;
}
