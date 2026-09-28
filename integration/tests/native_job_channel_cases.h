/* SPDX-License-Identifier: GPL-3.0-only; test-only cases in actual core harness. */
#ifdef NJ_CONTROL
static struct {
    struct dizzass_jobs *jobs;
    struct work *source;
    unsigned slot,variant,calls,finishes;
    uint64_t deadline;
    unsigned budget;
    bool pause,cancel;
    struct dizzass_uart_result response;
} nj_script;
int __wrap_dizzass_uart_posix_now_ms(uint64_t *t) { *t=100; return 0; }
struct dizzass_uart_result __wrap_dizzass_uart_posix_write_all(int fd,
    const uint8_t *data,size_t length,uint64_t deadline,unsigned budget)
{
    ++nj_script.calls;
    NJ_CHECK(fd==101 && length==88 && deadline==nj_script.deadline && budget==nj_script.budget);
    uint8_t expected[88];
    NJ_CHECK(!dizzass_native_work_tx88(nj_script.source,2,0,nj_script.slot,expected,sizeof expected));
    NJ_CHECK(!memcmp(data,expected,88));
    struct dizzass_nonce_reply p=nj_reply(nj_script.slot,nj_script.variant);
    struct dizzass_job_result q={0};
    NJ_CHECK(dizzass_jobs_check(nj_script.jobs,41,&p,&q)==DIZZASS_JOBS_PENDING && !q.check.work);
    int old;
    NJ_CHECK(!pthread_setcancelstate(PTHREAD_CANCEL_DISABLE,&old));
    NJ_CHECK(old==PTHREAD_CANCEL_DISABLE);
    if(nj_script.pause) NJ_CHECK(!dizzass_jobs_pause(nj_script.jobs,41));
    if(nj_script.cancel) NJ_CHECK(!pthread_cancel(pthread_self()));
    return nj_script.response;
}
int __real_dizzass_jobs_finish(struct dizzass_jobs *,const struct dizzass_job_ticket *,enum dizzass_tx_result);
int __wrap_dizzass_jobs_finish(struct dizzass_jobs *j,const struct dizzass_job_ticket *t,enum dizzass_tx_result outcome)
{
    int old; NJ_CHECK(!pthread_setcancelstate(PTHREAD_CANCEL_DISABLE,&old));
    NJ_CHECK(old==PTHREAD_CANCEL_DISABLE); ++nj_script.finishes;
    return __real_dizzass_jobs_finish(j,t,outcome);
}
static void nj_control_create(struct dizzass_jobs **j,struct dizzass_uart_channel **c,struct work *w,unsigned slot,unsigned variant)
{
    NJ_CHECK(!dizzass_jobs_create(2,41,j)); NJ_CHECK(!dizzass_uart_channel_create(c,101));
    memset(&nj_script,0,sizeof nj_script); nj_script.jobs=*j;nj_script.source=w;
    nj_script.slot=slot;nj_script.variant=variant;nj_script.deadline=8000;nj_script.budget=29;
    nj_script.response=(struct dizzass_uart_result){DIZZASS_UART_OK,88,0};
}
static struct dizzass_native_job_tx_receipt nj_send(struct dizzass_jobs *j,struct dizzass_uart_channel *c,struct work *w,unsigned slot,unsigned variant)
{ return dizzass_native_job_channel_send(j,c,41,2,0,slot,variant,w,8000,29); }
static void nj_outcomes(void)
{
    const size_t counts[]={0,1,43,87,88,89}; const int errors[]={0,EIO,ETIMEDOUT,ECANCELED};
    for(unsigned status=0;status<=DIZZASS_UART_NO_PROGRESS;++status)
    for(unsigned n=0;n<sizeof counts/sizeof counts[0];++n)
    for(unsigned e=0;e<sizeof errors/sizeof errors[0];++e) {
        struct work *w=nj_work(), before=*w;
        struct dizzass_jobs *j=NULL;struct dizzass_uart_channel *c=NULL;
        nj_control_create(&j,&c,w,3,2);
        nj_script.response=(struct dizzass_uart_result){(enum dizzass_uart_status)status,counts[n],errors[e]};
        struct dizzass_native_job_tx_receipt r=nj_send(j,c,w,3,2);
        bool ok=status==DIZZASS_UART_OK && counts[n]==88 && errors[e]==0;
        NJ_CHECK(!r.entry_error && r.prepare_called && !r.prepare_status && !r.cancel_restore_error);
        NJ_CHECK(r.channel_called && r.frame_size==88 && r.finish_called && !r.finish_status);
        NJ_CHECK(r.ticket.chain_id==2 && r.ticket.epoch==41 && r.ticket.slot==3 && r.ticket.serial==1);
        NJ_CHECK(r.transport.status==status && r.transport.written==counts[n] && r.transport.error==errors[e]);
        NJ_CHECK(r.outcome==(ok?DIZZASS_TX_WRITTEN:DIZZASS_TX_UNCERTAIN));
        NJ_CHECK(r.stop_called==!ok && !r.stop_status && nj_script.calls==1 && nj_script.finishes==1);
        NJ_CHECK(nj_state(c).stopped==!ok && !memcmp(w,&before,sizeof before));
        NJ_CHECK(dizzass_jobs_ticket_live(j,&r.ticket)==(ok?0:DIZZASS_JOBS_QUARANTINED));
        if(ok) nj_match(j,3,2);
        struct dizzass_job_ticket again={0};
        NJ_CHECK(dizzass_jobs_prepare(j,41,3,2,nj_le(w->data),w,&again)==(ok?DIZZASS_JOBS_BUSY:DIZZASS_JOBS_QUARANTINED));
        NJ_CHECK(!again.serial);
        nj_dispose(&j,&c);free_work(w);++nj_cases;
    }
}
static void nj_guards(void)
{
    for(unsigned i=0;i<11;++i){
        struct work *w=nj_work();struct dizzass_jobs *j=NULL;struct dizzass_uart_channel *c=NULL;
        nj_control_create(&j,&c,w,3,2); uint32_t old_count=total_work;
        struct dizzass_native_job_tx_receipt r=dizzass_native_job_channel_send(
            i==0?NULL:j,i==1?NULL:c,i==4?42:41,i==5?0:i==6?9:2,i==7?1:0,
            i==8?32:i==9?UINT32_MAX:3,i==10?3:2,i==2?NULL:w,8000,i==3?0:29);
        if(i<4){NJ_CHECK(r.entry_error==EINVAL && !r.prepare_called);}
        else if(i<11){NJ_CHECK(r.prepare_called && r.prepare_status!=0 && !r.ticket.serial);}
        else { NJ_CHECK(!r.prepare_status); }
        if(i<11){NJ_CHECK(!r.channel_called && !r.finish_called && !r.stop_called && nj_script.calls==0 && total_work==old_count);}
        nj_dispose(&j,&c);free_work(w);++nj_cases;
    }
    for(unsigned i=0;i<4;++i){
        struct work *w=nj_work();struct dizzass_jobs *j=NULL;struct dizzass_uart_channel *c=NULL;
        nj_control_create(&j,&c,w,3,2);nj_fail_strdup=(int)i;
        struct dizzass_native_job_tx_receipt r=nj_send(j,c,w,3,2);nj_fail_strdup=-1;
        NJ_CHECK(r.prepare_status==DIZZASS_NONCE_PARTIAL_COPY && !r.ticket.serial && !r.channel_called && !r.finish_called);
        NJ_CHECK(nj_script.calls==0);r=nj_send(j,c,w,3,2);NJ_CHECK(!r.prepare_status && !r.finish_status);nj_match(j,3,2);
        nj_dispose(&j,&c);free_work(w);++nj_cases;
    }
}
static void nj_capacity_lifetime(void)
{
    struct work *w=nj_work();struct pool pool={0};w->pool=&pool;
    struct dizzass_jobs *j=NULL;struct dizzass_uart_channel *c=NULL;
    struct dizzass_job_ticket tickets[32];nj_control_create(&j,&c,w,0,0);
    for(unsigned slot=0;slot<32;++slot){nj_script.slot=slot;nj_script.variant=slot%3;
        struct dizzass_native_job_tx_receipt r=nj_send(j,c,w,slot,slot%3);NJ_CHECK(!r.prepare_status && !r.finish_status && r.outcome==DIZZASS_TX_WRITTEN);tickets[slot]=r.ticket;++nj_cases;}
    unsigned calls=nj_script.calls;nj_script.slot=0;nj_script.variant=0;
    struct dizzass_native_job_tx_receipt r=nj_send(j,c,w,0,0);NJ_CHECK(r.prepare_status==DIZZASS_JOBS_BUSY && !r.channel_called && nj_script.calls==calls);
    memset(w->data,0,sizeof w->data);memset(w->job_id,'X',strlen(w->job_id));free_work(w);
    for(unsigned slot=0;slot<32;++slot){nj_match(j,slot,slot%3);
        struct dizzass_nonce_reply p=nj_reply(slot,slot%3);struct dizzass_job_result q={0};
        NJ_CHECK(!dizzass_jobs_check(j,41,&p,&q) && q.check.work->pool==&pool);dizzass_job_result_clear(&q);
        NJ_CHECK(dizzass_jobs_check(j,40,&p,&q)==DIZZASS_JOBS_OLD_EPOCH);
        NJ_CHECK(!dizzass_jobs_retire(j,&tickets[slot]));NJ_CHECK(dizzass_jobs_ticket_live(j,&tickets[slot])==DIZZASS_JOBS_QUARANTINED);
    }
    nj_dispose(&j,&c);++nj_cases;
}
static void *nj_cancel_sender(void *arg)
{ struct dizzass_uart_channel *c=arg;(void)nj_send(nj_script.jobs,c,nj_script.source,3,2);pthread_testcancel();return NULL; }
static void nj_pause_cancel_refusal(void)
{
    for(unsigned action=0;action<5;++action){
        struct work *w=nj_work();struct dizzass_jobs *j=NULL;struct dizzass_uart_channel *c=NULL;nj_control_create(&j,&c,w,3,2);
        if(action==0){nj_script.pause=true;struct dizzass_native_job_tx_receipt r=nj_send(j,c,w,3,2);
            NJ_CHECK(r.finish_status==DIZZASS_JOBS_PAUSED && r.transport.status==DIZZASS_UART_OK && r.stop_called && !r.stop_status && nj_state(c).stopped);}
        if(action==1){nj_script.cancel=true;pthread_t t;void *v;NJ_CHECK(!pthread_create(&t,NULL,nj_cancel_sender,c));NJ_CHECK(!pthread_join(t,&v) && v==PTHREAD_CANCELED);NJ_CHECK(nj_script.finishes==1);nj_match(j,3,2);}
        if(action==2 || action==3){if(action==2)NJ_CHECK(!dizzass_uart_channel_stop(c,0));
            struct dizzass_native_job_tx_receipt r=dizzass_native_job_channel_send(j,c,41,2,0,3,2,w,action==3?100:8000,29);
            NJ_CHECK(r.channel_called && r.finish_called && r.outcome==DIZZASS_TX_UNCERTAIN && !r.finish_status && r.transport.written==0 && r.stop_called && !r.stop_status && nj_script.calls==0);
            NJ_CHECK(dizzass_jobs_ticket_live(j,&r.ticket)==DIZZASS_JOBS_QUARANTINED);}
        if(action==4){NJ_CHECK(!dizzass_jobs_pause(j,41));struct dizzass_native_job_tx_receipt r=nj_send(j,c,w,3,2);NJ_CHECK(r.prepare_status==DIZZASS_JOBS_PAUSED && !r.channel_called && !r.finish_called && !nj_state(c).stopped);}
        nj_dispose(&j,&c);free_work(w);++nj_cases;
    }
}
static void nj_controls(void) { nj_outcomes();nj_guards();nj_capacity_lifetime();nj_pause_cancel_refusal(); }
#else
/* PTY mode: actual kernel writes, except explicitly identified error injection. */
static int nj_fd=-1,nj_fail_after=-1;
static size_t nj_accepted;
ssize_t __real_write(int,const void *,size_t);
ssize_t __wrap_write(int fd,const void *p,size_t n)
{
    if(fd==nj_fd && nj_fail_after>=0){
        if(nj_accepted==(size_t)nj_fail_after){errno=EIO;return -1;}
        if(n>(size_t)nj_fail_after-nj_accepted)n=(size_t)nj_fail_after-nj_accepted;
    }
    ssize_t got=__real_write(fd,p,n);int e=errno;
    if(fd==nj_fd && got>0)nj_accepted+=(size_t)got;
    errno=e;return got;
}
static void nj_pair(int *m,int *s,struct dizzass_jobs **j,struct dizzass_uart_channel **c)
{
    NJ_CHECK(!openpty(m,s,NULL,NULL,NULL));struct termios t;NJ_CHECK(!tcgetattr(*s,&t));cfmakeraw(&t);NJ_CHECK(!tcsetattr(*s,TCSANOW,&t));
    NJ_CHECK(!fcntl(*s,F_SETFL,fcntl(*s,F_GETFL)|O_NONBLOCK));NJ_CHECK(!fcntl(*m,F_SETFL,fcntl(*m,F_GETFL)|O_NONBLOCK));
    NJ_CHECK(!dizzass_jobs_create(2,41,j));NJ_CHECK(!dizzass_uart_channel_create(c,*s));nj_fd=*s;nj_accepted=0;nj_fail_after=-1;
}
static void nj_read_exact(int fd,uint8_t *p,size_t length)
{
    uint64_t until=nj_now()+5000;size_t have=0;
    while(have<length && nj_now()<until){ssize_t n=read(fd,p+have,length-have);if(n>0){have+=(size_t)n;continue;}
        NJ_CHECK(n<0 && (errno==EAGAIN || errno==EINTR));struct pollfd q={fd,POLLIN,0};int rc=poll(&q,1,10);NJ_CHECK(rc>=0 || errno==EINTR);}
    NJ_CHECK(have==length);
}
static void nj_no_extra(int fd){struct pollfd q={fd,POLLIN,0};NJ_CHECK(poll(&q,1,15)==0);}
static void nj_close(int m,int s,struct dizzass_jobs **j,struct dizzass_uart_channel **c)
{nj_dispose(j,c);nj_fd=-1;NJ_CHECK(!close(m) && !close(s));}
static void nj_pty_single(void)
{
    for(unsigned mode=0;mode<4;++mode){int m,s;struct dizzass_jobs *j=NULL;struct dizzass_uart_channel *c=NULL;nj_pair(&m,&s,&j,&c);
        struct work *w=nj_work();uint8_t expected[88],got[88];NJ_CHECK(!dizzass_native_work_tx88(w,2,0,3,expected,88));
        if(mode==1)nj_fail_after=7;
        if(mode==2)NJ_CHECK(!dizzass_uart_channel_stop(c,0));
        struct dizzass_native_job_tx_receipt r=dizzass_native_job_channel_send(j,c,41,2,0,3,2,w,mode==3?0:nj_now()+2000,29);
        NJ_CHECK(!r.prepare_status && r.channel_called && r.finish_called && !r.finish_status);
        if(mode==0){NJ_CHECK(r.outcome==DIZZASS_TX_WRITTEN && r.transport.written==88);nj_read_exact(m,got,88);NJ_CHECK(!memcmp(expected,got,88));free_work(w);nj_match(j,3,2);}
        else {NJ_CHECK(r.outcome==DIZZASS_TX_UNCERTAIN && nj_state(c).stopped && r.stop_called && !r.stop_status);
            NJ_CHECK(r.transport.written==(mode==1?7:0));if(mode==1){nj_read_exact(m,got,7);NJ_CHECK(!memcmp(expected,got,7));}
            NJ_CHECK(dizzass_jobs_ticket_live(j,&r.ticket)==DIZZASS_JOBS_QUARANTINED);free_work(w);
            struct dizzass_protocol_tx_receipt cmd=dizzass_channel_bm1368_command(c,DIZZASS_BM1368_SET_CONFIG,1,0,8,123,nj_now()+1000,29);
            NJ_CHECK(cmd.channel_called && cmd.transport.status==DIZZASS_UART_CANCELED && !cmd.transport.written);}
        nj_no_extra(m);nj_close(m,s,&j,&c);++nj_cases;
    }
}
struct nj_producer {struct dizzass_jobs *j;struct dizzass_uart_channel *c;struct work *w;unsigned begin;bool commands;};
static void *nj_produce(void *arg)
{
    struct nj_producer *p=arg;
    for(unsigned i=0;i<8;++i){if(p->commands){struct dizzass_protocol_tx_receipt r=dizzass_channel_bm1368_command(p->c,DIZZASS_BM1368_SET_CONFIG,1,0,8,i,nj_now()+5000,29);NJ_CHECK(r.transport.status==DIZZASS_UART_OK && r.transport.written==11);}
        else {struct dizzass_native_job_tx_receipt r=dizzass_native_job_channel_send(p->j,p->c,41,2,0,p->begin+i,2,p->w,nj_now()+5000,29);NJ_CHECK(!r.prepare_status && !r.finish_status && r.outcome==DIZZASS_TX_WRITTEN && r.transport.written==88);}}
    return NULL;
}
static void nj_mixed(void)
{
    int m,s;struct dizzass_jobs *j=NULL;struct dizzass_uart_channel *c=NULL;nj_pair(&m,&s,&j,&c);
    /* Observation counter belongs to the sole write owner, but disable it here
     * rather than assume this test instrumentation is synchronized by a gate. */
    nj_fd=-1;
    struct work *w=nj_work();enum{TOTAL=32*88+8*11};uint8_t got[TOTAL],work[32][88],cmd[8][11];
    for(unsigned i=0;i<32;++i)NJ_CHECK(!dizzass_native_work_tx88(w,2,0,i,work[i],88));
    for(unsigned i=0;i<8;++i){size_t len=0;NJ_CHECK(!dizzass_bm1368_command_encode(DIZZASS_BM1368_SET_CONFIG,1,0,8,i,cmd[i],11,&len) && len==11);}
    pthread_t ts[5];struct nj_producer ps[5];
    for(unsigned i=0;i<5;++i){ps[i]=(struct nj_producer){j,c,w,i*8,i==4};NJ_CHECK(!pthread_create(&ts[i],NULL,nj_produce,&ps[i]));}
    nj_read_exact(m,got,sizeof got);for(unsigned i=0;i<5;++i)NJ_CHECK(!pthread_join(ts[i],NULL));
    uint32_t seen_work=0;unsigned seen_cmd=0;size_t pos=0;
    while(pos<sizeof got){bool match=false;
        for(unsigned i=0;i<32 && !match;++i)if(!(seen_work&(UINT32_C(1)<<i)) && sizeof got-pos>=88 && !memcmp(got+pos,work[i],88)){seen_work|=UINT32_C(1)<<i;pos+=88;match=true;}
        for(unsigned i=0;i<8 && !match;++i)if(!(seen_cmd&(1u<<i)) && sizeof got-pos>=11 && !memcmp(got+pos,cmd[i],11)){seen_cmd|=1u<<i;pos+=11;match=true;}
        NJ_CHECK(match);
    }
    NJ_CHECK(seen_work==UINT32_MAX && seen_cmd==255);nj_no_extra(m);free_work(w);
    for(unsigned i=0;i<32;++i)nj_match(j,i,2);
    printf("NATIVE_JOB_TX_PTY_MIXED native_jobs=32 commands=8 bytes=%u exact_native_matches=32\n",TOTAL);
    nj_close(m,s,&j,&c);++nj_cases;
}
struct nj_filler {struct dizzass_uart_channel *c; uint8_t *data; struct dizzass_uart_result result;};
static void *nj_fill_send(void *arg)
{struct nj_filler *f=arg;f->result=dizzass_uart_channel_send(f->c,f->data,1048576,nj_now()+700,10000);return NULL;}
static void nj_queued(void)
{
    int m,s;struct dizzass_jobs *j=NULL;struct dizzass_uart_channel *c=NULL;nj_pair(&m,&s,&j,&c);nj_fd=-1;
    uint8_t *data=malloc(1048576),*got=malloc(1048576);NJ_CHECK(data && got);memset(data,0x71,1048576);
    struct nj_filler filler={c,data,{0}};pthread_t t;NJ_CHECK(!pthread_create(&t,NULL,nj_fill_send,&filler));
    uint64_t end=nj_now()+2000;while(!nj_state(c).active && nj_now()<end){struct timespec p={0,1000000};nanosleep(&p,NULL);}NJ_CHECK(nj_state(c).active);
    struct work *w=nj_work();struct dizzass_native_job_tx_receipt r=dizzass_native_job_channel_send(j,c,41,2,0,3,2,w,nj_now()+30,29);
    NJ_CHECK(r.transport.status==DIZZASS_UART_TIMEOUT && !r.transport.written && r.outcome==DIZZASS_TX_UNCERTAIN && !r.finish_status);
    NJ_CHECK(r.stop_called && r.stop_status==ETIMEDOUT && nj_state(c).active && fcntl(s,F_GETFL)>=0);
    NJ_CHECK(dizzass_jobs_ticket_live(j,&r.ticket)==DIZZASS_JOBS_QUARANTINED);
    NJ_CHECK(!pthread_join(t,NULL));NJ_CHECK(filler.result.status==DIZZASS_UART_TIMEOUT && filler.result.written>0 && filler.result.written<1048576);
    nj_read_exact(m,got,filler.result.written);NJ_CHECK(!memcmp(data,got,filler.result.written));nj_no_extra(m);
    NJ_CHECK(!dizzass_uart_channel_stop(c,0));free_work(w);free(data);free(got);nj_close(m,s,&j,&c);
    printf("NATIVE_JOB_TX_PTY_QUEUE quarantined=1 stop_timeout_keeps_fd=1 work_bytes=0\n");++nj_cases;
}
static void nj_ptys(void){nj_pty_single();nj_mixed();nj_queued();}
#endif
