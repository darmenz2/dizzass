/* SPDX-License-Identifier: GPL-3.0-only
 * Real A-14 gate; scripted WHOLE A-13 call. No fd or hardware operations. */
#include "integration/native/protocol_channel_tx.h"
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
static unsigned cases, checks, calls;
#define CHECK(x) do { ++checks; if (!(x)) { fprintf(stderr,"PROTOCOL_TX_ASSERT %d: %s\n",__LINE__,#x); exit(1); } } while (0)
static uint8_t expected[88], words[80];
static size_t expected_size;
static uint64_t expected_deadline = 1234567;
static unsigned expected_budget = 73;
static struct dizzass_uart_result lower;
int __wrap_dizzass_uart_posix_now_ms(uint64_t *t) { *t=100; return 0; }
struct dizzass_uart_result __wrap_dizzass_uart_posix_write_all(int fd,
    const uint8_t *p,size_t n,uint64_t deadline,unsigned budget)
{
    CHECK(fd==61 && n==expected_size && deadline==expected_deadline && budget==expected_budget);
    CHECK(!memcmp(p,expected,n)); ++calls; return lower;
}
static struct dizzass_uart_channel *gate(void)
{ struct dizzass_uart_channel *c=NULL; CHECK(!dizzass_uart_channel_create(&c,61)); return c; }
static void dispose(struct dizzass_uart_channel **c)
{ CHECK(!dizzass_uart_channel_stop(*c,0)); CHECK(!dizzass_uart_channel_destroy(c)); }
static struct dizzass_uart_channel_state snapshot(struct dizzass_uart_channel *c)
{ struct dizzass_uart_channel_state s; CHECK(!dizzass_uart_channel_snapshot(c,&s)); return s; }
static void expect_command(enum dizzass_bm1368_command cmd,uint32_t b,uint32_t a,uint32_t reg,uint32_t v)
{ CHECK(!dizzass_bm1368_command_encode(cmd,b,a,reg,v,expected,sizeof expected,&expected_size)); }
static void expect_work(uint32_t slot)
{ CHECK(!dizzass_tx88_encode_words(words,sizeof words,slot,expected,sizeof expected));expected_size=88; }
static void exact(struct dizzass_protocol_tx_receipt r,unsigned before)
{
    CHECK(r.prepare_status==0 && r.channel_called && r.frame_size==expected_size);
    CHECK(r.transport.status==lower.status && r.transport.written==lower.written && r.transport.error==lower.error);
    CHECK(calls==before+1); ++cases;
}
static void rejected(struct dizzass_protocol_tx_receipt r,int error,unsigned before)
{
    CHECK(r.prepare_status==error && !r.channel_called && !r.frame_size);
    CHECK(r.transport.status==DIZZASS_UART_INVALID_INPUT && !r.transport.written && !r.transport.error);
    CHECK(calls==before);++cases;
}
static struct dizzass_protocol_tx_receipt send_command(struct dizzass_uart_channel *c)
{ return dizzass_channel_bm1368_command(c,DIZZASS_BM1368_SET_CONFIG,1,17,8,0x12345678,expected_deadline,expected_budget); }
static struct dizzass_protocol_tx_receipt send_work(struct dizzass_uart_channel *c)
{ return dizzass_channel_work_tx88(c,words,sizeof words,2,0,31,expected_deadline,expected_budget); }
static void successful_frames(void)
{
    struct dizzass_uart_channel *c=gate();
    for(unsigned cmd=0;cmd<4;++cmd) for(unsigned k=0;k<128;++k){
        uint32_t b=cmd>=2 ? k%2 : 0, a=cmd ? (k*17)%256 : 0;
        uint32_t reg=cmd>=2 ? (k*31)%256 : 0, value=cmd==3 ? k*UINT32_C(123456789) : 0;
        expect_command((enum dizzass_bm1368_command)cmd,b,a,reg,value);
        lower=(struct dizzass_uart_result){DIZZASS_UART_OK,expected_size,0};unsigned before=calls;
        exact(dizzass_channel_bm1368_command(c,(enum dizzass_bm1368_command)cmd,b,a,reg,value,expected_deadline,expected_budget),before);
    }
    for(unsigned platform=1;platform<=4;++platform) for(unsigned slot=0;slot<32;++slot){
        for(unsigned j=0;j<80;++j) words[j]=(uint8_t)(j*13+slot*7+platform);
        uint8_t old[80];memcpy(old,words,80);expect_work(slot);
        lower=(struct dizzass_uart_result){DIZZASS_UART_OK,88,0};unsigned before=calls;
        exact(dizzass_channel_work_tx88(c,words,80,platform,0,slot,expected_deadline,expected_budget),before);
        CHECK(!memcmp(old,words,80));
    }
    CHECK(!snapshot(c).stopped);dispose(&c);
}
static void error_receipts(void)
{
    static const enum dizzass_uart_status errors[]={DIZZASS_UART_WRITE_ERROR,DIZZASS_UART_WAIT_ERROR,
        DIZZASS_UART_CLOCK_ERROR,DIZZASS_UART_TIMEOUT,DIZZASS_UART_CANCELED,DIZZASS_UART_NO_PROGRESS,
        DIZZASS_UART_INVALID_CALLBACK};
    for(unsigned work=0;work<2;++work) for(unsigned s=0;s<sizeof errors/sizeof errors[0];++s)
        for(size_t written=0;written<=(work?88u:11u);++written){
            struct dizzass_uart_channel *c=gate();
            if(work)expect_work(31);else expect_command(DIZZASS_BM1368_SET_CONFIG,1,17,8,0x12345678);
            lower=(struct dizzass_uart_result){errors[s],written,s==3?ETIMEDOUT:s==4?ECANCELED:EIO};
            unsigned before=calls;exact(work?send_work(c):send_command(c),before);
            struct dizzass_uart_channel_state st=snapshot(c);
            CHECK(st.stopped && !st.active && st.has_result && st.last.written==written);
            struct dizzass_protocol_tx_receipt r=work?send_command(c):send_work(c);
            CHECK(r.prepare_status==0 && r.channel_called && r.transport.status==DIZZASS_UART_CANCELED && !r.transport.written);
            CHECK(calls==before+1 && snapshot(c).last.written==written);dispose(&c);
        }
}
static void bad_inputs(void)
{
    struct dizzass_uart_channel *c=gate();unsigned before=calls;
    rejected(send_command(NULL),DIZZASS_PROTOCOL_TX_INVALID,before);
    rejected(send_work(NULL),DIZZASS_PROTOCOL_TX_INVALID,before);
    rejected(dizzass_channel_bm1368_command(c,3,1,0,8,0,999,0),DIZZASS_PROTOCOL_TX_INVALID,before);
    rejected(dizzass_channel_work_tx88(c,words,80,2,0,0,999,0),DIZZASS_PROTOCOL_TX_INVALID,before);
    for(unsigned cmd=0;cmd<4;++cmd){
        rejected(dizzass_channel_bm1368_command(c,(enum dizzass_bm1368_command)cmd,256,0,0,0,999,1),DIZZASS_CONTROL_INVALID,before);
        rejected(dizzass_channel_bm1368_command(c,(enum dizzass_bm1368_command)cmd,0,256,0,0,999,1),DIZZASS_CONTROL_INVALID,before);
        rejected(dizzass_channel_bm1368_command(c,(enum dizzass_bm1368_command)cmd,0,0,256,0,999,1),DIZZASS_CONTROL_INVALID,before);
    }
    rejected(dizzass_channel_bm1368_command(c,4,0,0,0,0,999,1),DIZZASS_CONTROL_INVALID,before);
    rejected(dizzass_channel_bm1368_command(c,0,0,1,0,0,999,1),DIZZASS_CONTROL_INVALID,before);
    rejected(dizzass_channel_bm1368_command(c,2,0,0,8,1,999,1),DIZZASS_CONTROL_INVALID,before);
    const uint32_t selectors[]={0,1,2,3,4,5,256,UINT32_MAX};
    for(size_t p=0;p<sizeof selectors/sizeof selectors[0];++p) for(unsigned a=0;a<3;++a){
        if(selectors[p]>=1 && selectors[p]<=4 && a==0)continue;
        rejected(dizzass_channel_work_tx88(c,words,80,selectors[p],a,0,999,1),DIZZASS_ROUTE_UNSUPPORTED,before);
    }
    const uint32_t slots[]={32,256,UINT32_MAX};
    for(unsigned j=0;j<3;++j)rejected(dizzass_channel_work_tx88(c,words,80,2,0,slots[j],999,1),DIZZASS_TX88_INVALID,before);
    for(size_t n=0;n<83;++n)if(n!=80)rejected(dizzass_channel_work_tx88(c,words,n,2,0,0,999,1),DIZZASS_TX88_INVALID,before);
    rejected(dizzass_channel_work_tx88(c,NULL,80,2,0,0,999,1),DIZZASS_TX88_INVALID,before);
    CHECK(!snapshot(c).stopped && !snapshot(c).has_result);
    /* Preparation errors must not erase a previously completed result. */
    expect_work(31);lower=(struct dizzass_uart_result){DIZZASS_UART_OK,88,0};exact(send_work(c),before);before=calls;
    rejected(dizzass_channel_bm1368_command(c,3,3,0,0,0,999,1),DIZZASS_CONTROL_INVALID,before);
    CHECK(snapshot(c).has_result && snapshot(c).last.written==88 && !snapshot(c).stopped);dispose(&c);
}
static void stopped_and_expired(void)
{
    struct dizzass_uart_channel *c=gate();unsigned before=calls;
    for(unsigned work=0;work<2;++work){
        struct dizzass_protocol_tx_receipt r=work?
            dizzass_channel_work_tx88(c,words,80,2,0,0,100,1):
            dizzass_channel_bm1368_command(c,3,1,0,8,0,100,1);
        CHECK(r.prepare_status==0 && r.channel_called && r.frame_size==(work?88u:11u));
        CHECK(r.transport.status==DIZZASS_UART_TIMEOUT && !r.transport.written && r.transport.error==ETIMEDOUT);
        CHECK(!snapshot(c).stopped && !snapshot(c).has_result && calls==before);++cases;
    }
    CHECK(!dizzass_uart_channel_stop(c,0));
    for(unsigned work=0;work<2;++work){
        struct dizzass_protocol_tx_receipt r=work?send_work(c):send_command(c);
        CHECK(!r.prepare_status && r.channel_called && r.transport.status==DIZZASS_UART_CANCELED && !r.transport.written);
        CHECK(calls==before);++cases;
    }
    dispose(&c);
}
int main(void)
{
    alarm(20);successful_frames();error_receipts();bad_inputs();stopped_and_expired();alarm(0);
    printf("PROTOCOL_TX_CONTROL_PASS cases=%u checks=%u actual_channel=1 lower_frame_scripted=1\n",cases,checks);
    return 0;
}
