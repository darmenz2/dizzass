/* Pure control/CRC checks; no devices, syscalls, real waits or PSU operations. */
#include "integration/bm1368_control.h"
#include "integration/rx_crc5.h"
#include "xminer/recovery/chip1398.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
static unsigned checks;
#define CHECK(x) do { ++checks;if(!(x)){fprintf(stderr,"control %d: %s\n",__LINE__,#x);exit(1);} } while(0)
struct state { uint32_t regs[256];unsigned calls,fail; };
static int read_cache(void *p,uint8_t reg,uint32_t *value)
{struct state*s=p;if(++s->calls==s->fail)return -77;*value=s->regs[reg];return 0;}
static int write_config(void *p,uint8_t reg,uint32_t value)
{struct state*s=p;if(++s->calls==s->fail)return -77;s->regs[reg]=value;return 0;}
static int wait_ms(void *p,uint32_t ms)
{struct state*s=p;CHECK(ms==1||ms==5||ms==10);return ++s->calls==s->fail?-77:0;}
int main(void)
{
    uint8_t out[16],saved[16],payload[9]={0},crc;size_t n;
    unsigned cmd,cap,fail,fast,clock,pulse,bit;
    memset(saved,0xa5,sizeof(saved));
    for(cmd=0;cmd<4;++cmd)for(cap=0;cap<16;++cap){
        size_t need=cmd==3?11:7;n=999;memcpy(out,saved,sizeof(out));
        int rc=dizzass_bm1368_command_encode(cmd,0,cmd?32:0,cmd>=2?24:0,cmd==3?0x12345678:0,out+1,cap,&n);
        CHECK(rc==(cap<need?DIZZASS_CONTROL_NO_SPACE:0));
        if(rc){CHECK(n==999);CHECK(!memcmp(out,saved,sizeof(out)));}
        else{CHECK(n==need&&out[0]==0xa5);CHECK(!memcmp(out+1+need,saved+1+need,15-need));}
    }
    memcpy(out,saved,sizeof(out));n=999;
#define BAD(call) do{CHECK((call)==DIZZASS_CONTROL_INVALID);CHECK(n==999&&!memcmp(out,saved,sizeof(out)));}while(0)
    BAD(dizzass_bm1368_command_encode(-1,0,0,0,0,out,16,&n));
    BAD(dizzass_bm1368_command_encode(4,0,0,0,0,out,16,&n));
    BAD(dizzass_bm1368_command_encode(0,1,0,0,0,out,16,&n));
    BAD(dizzass_bm1368_command_encode(0,0,1,0,0,out,16,&n));
    BAD(dizzass_bm1368_command_encode(2,0,0,0,1,out,16,&n));
    BAD(dizzass_bm1368_command_encode(3,2,0,0,0,out,16,&n));
    BAD(dizzass_bm1368_command_encode(3,0,256,0,0,out,16,&n));
    BAD(dizzass_bm1368_command_encode(3,0,0,256,0,out,16,&n));
    BAD(dizzass_bm1368_command_encode(3,0,0,0,0,NULL,16,&n));
    BAD(dizzass_bm1368_command_encode(3,0,0,0,0,out,16,NULL));
#undef BAD
    for(fast=0;fast<2;++fast)for(clock=0;clock<8;++clock)for(pulse=0;pulse<4;++pulse)
      for(fail=0;fail<=16;++fail){
        struct state s={{0},0,fail};struct dizzass_bm1368_reset_ops ops={&s,read_cache,write_config,wait_ms};
        struct dizzass_bm1368_reset_result result={99,99,99};
        s.regs[24]=0x12345678;s.regs[168]=0x98765432;
        int rc=dizzass_bm1368_reset_cores(&ops,fast,clock,pulse,&result);
        CHECK(rc==(fail?DIZZASS_CONTROL_CALLBACK:0));
        CHECK(s.calls==(fail?fail:16));CHECK(result.completed==(fail?fail-1:16));
        CHECK(result.failed_step==fail&&result.callback_status==(fail?-77:0));
      }
    {struct state s={{0},0,0};struct dizzass_bm1368_reset_ops ops={&s,read_cache,write_config,wait_ms};
     struct dizzass_bm1368_reset_result result={99,99,99},before=result;
     CHECK(dizzass_bm1368_reset_cores(&ops,2,0,0,&result)==DIZZASS_CONTROL_INVALID);
     CHECK(dizzass_bm1368_reset_cores(&ops,0,8,0,&result)==DIZZASS_CONTROL_INVALID);
     CHECK(dizzass_bm1368_reset_cores(&ops,0,0,4,&result)==DIZZASS_CONTROL_INVALID);
     CHECK(dizzass_bm1368_reset_cores(NULL,0,0,0,&result)==DIZZASS_CONTROL_INVALID);
     ops.wait_ms=NULL;CHECK(dizzass_bm1368_reset_cores(&ops,0,0,0,&result)==DIZZASS_CONTROL_INVALID);
     CHECK(!memcmp(&result,&before,sizeof(result))&&s.calls==0);}
    payload[8]=0x80;CHECK(vn135_crc5_bits(payload,9,67,&crc)==0);payload[8]|=crc;
    CHECK(dizzass_bm1368_reply_crc5(4,2,payload,9)==0);
    for(bit=0;bit<72;++bit){payload[bit/8]^=(uint8_t)(1u<<(bit%8));CHECK(dizzass_bm1368_reply_crc5(4,2,payload,9)==DIZZASS_RX_CRC_MISMATCH);payload[bit/8]^=(uint8_t)(1u<<(bit%8));}
    for(cap=0;cap<=16;++cap)if(cap!=9)CHECK(dizzass_bm1368_reply_crc5(4,2,payload,cap)==DIZZASS_RX_CRC_INVALID);
    CHECK(dizzass_bm1368_reply_crc5(4,2,NULL,9)==DIZZASS_RX_CRC_INVALID);
    CHECK(dizzass_bm1368_reply_crc5(3,2,payload,9)==DIZZASS_RX_CRC_UNSUPPORTED);
    CHECK(dizzass_bm1368_reply_crc5(4,1,payload,9)==DIZZASS_RX_CRC_UNSUPPORTED);
    printf("BM1368_CONTROL_BOUNDS_PASS checks=%u reset_cases=1088 hardware=no\n",checks);return 0;
}
