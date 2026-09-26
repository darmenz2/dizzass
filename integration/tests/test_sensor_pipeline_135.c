/* C composition only: recovered monitor -> full reader -> AML SMBus -> updater.
 * Failure -> recovered shutdown worker -> existing power-stop and sensor reset.
 * External syscalls, physical I/O, thread creation, and remaining cleanup bodies
 * are explicit RAM scenarios, NOT working-device defaults. */
#include "integration/sensor_monitor_135.h"
#include "integration/thermal_reader_135.h"
#include "integration/aml_smbus_135.h"
#include "integration/backend_shutdown_135.h"
#include <assert.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
static unsigned scenarios,checks;
#define CHECK(x) do{++checks;assert(x);}while(0)
struct fixture {
    struct vn135_sensor_monitor monitor;
    struct vn135_route_chain chain;
    struct vn135_temperature_sensor sensor;
    struct vn135_i2c_iface iface;
    struct vn135_reader_context context;
    struct vn135_reader_scratch scratch;
    struct vn135_shutdown_state shutdown;
    unsigned laps,limit,reads,transfers,words,bytes,mux_writes,addresses;
    unsigned sensor_locks,sensor_unlocks,bus_locks,bus_unlocks,sm_locks,sm_unlocks;
    unsigned aggregates,overheats,refreshes,stop_calls,events,creates,off_calls;
    unsigned reset_calls,marks,exits,cleanup_calls,mutex_inits,power_tick,cleanup_tick,tick;
    unsigned fail_all,fail_prefix,create_fail,off_fail,force_hot,backend_action;
    uint8_t raw,remote;uint32_t active_address;double clock;
};
static const struct vn135_reader_ops reader_ops;
static const struct vn135_temperature_ops temp_ops;
static const struct vn135_shutdown_ops shutdown_ops;
static const struct vn135_backend_power_ops power_ops;
static const struct vn135_smbus_ops smbus_ops;
static double now(void *p){struct fixture *f=p;return f->clock+=0.125;}
static int32_t sensor_init(void *p,struct vn135_temperature_sensor *s)
{struct fixture*f=p;CHECK(s==&f->sensor);++f->mutex_inits;return -9;}
static int32_t sensor_lock(void *p,struct vn135_temperature_sensor *s)
{struct fixture*f=p;if(s){CHECK(s==&f->sensor);++f->sensor_locks;}else ++f->bus_locks;return -1;}
static int32_t sensor_unlock(void *p,struct vn135_temperature_sensor *s)
{struct fixture*f=p;if(s){CHECK(s==&f->sensor);++f->sensor_unlocks;}else ++f->bus_unlocks;return -2;}
static int32_t delay(void *p,uint32_t ms)
{
    struct fixture*f=p;CHECK(ms==20||ms==65||ms==100||ms==150||ms==200||ms==1000);
    if(ms==1000 && ++f->laps>=f->limit)f->monitor.running=0;
    return -3;
}
static int32_t sm_lock(void*p,struct vn135_i2c_iface*i)
{struct fixture*f=p;CHECK(i==&f->iface);++f->sm_locks;return -4;}
static int32_t sm_unlock(void*p,struct vn135_i2c_iface*i)
{struct fixture*f=p;CHECK(i==&f->iface);++f->sm_unlocks;return -5;}
static int32_t address(void*p,int32_t fd,uint32_t v)
{struct fixture*f=p;CHECK(fd==f->iface.fd);++f->addresses;f->active_address=v;return 0;}
static int32_t ready(void*p,int32_t nfds,uint32_t reading,uint32_t b[32],struct vn135_smbus_timeout*t)
{
    struct fixture*f=p;unsigned i;CHECK(nfds==f->iface.fd+1);CHECK(reading<=1);
    for(i=0;i<32;++i)CHECK(b[i]==(i==(unsigned)f->iface.fd/32?1u<<((unsigned)f->iface.fd%32):0));
    CHECK(t->seconds==0&&t->microseconds==50000);t->microseconds=17;return 1;
}
static int32_t transaction(void*p,int32_t fd,uint8_t reading,uint8_t command,uint32_t protocol,void*data)
{
    struct fixture*f=p;uint8_t*d=data;CHECK(fd==f->iface.fd);++f->transfers;
    if(reading){
        CHECK(d);CHECK(protocol==2||protocol==3);CHECK(f->active_address==76);
        if(protocol==2){CHECK(command==3);d[0]=0;++f->bytes;}
        else{CHECK(command<=1);d[0]=command?f->remote:f->raw;d[1]=0xc5;++f->words;}
    }else if(protocol==1){CHECK(!d&&f->active_address==112);CHECK(command==0||command==1);++f->mux_writes;}
    else{CHECK(protocol==2&&d&&command==9&&f->active_address==76);CHECK(d[0]==0);++f->bytes;}
    /* As in the real ioctl contract a failed transaction may modify output. */
    return f->fail_all||f->transfers<=f->fail_prefix?-1:0;
}
static int32_t sleep_us(void*p,uint32_t us){(void)p;CHECK(us==20000||us==100000);return -6;}
static uint32_t platform(void*p){(void)p;return 2;}
static int32_t transfer(void*p,uint32_t ep,uint32_t ad,uint32_t mode,uint32_t reg,uint8_t*buf,uint32_t protocol)
{
    struct fixture*f=p;CHECK(mode==0);CHECK(ep==0xfe440||ep==0xfe518);
    if(ep==0xfe440)return vn135_aml_smbus_read_135(&f->iface,ad,reg,buf,protocol,&smbus_ops,p);
    return vn135_aml_smbus_write_135(&f->iface,ad,reg,buf,protocol,&smbus_ops,p);
}
static int32_t compare(void*p,const char*a,const char*b){(void)p;return strcmp(a,b);}
static int32_t offset(void*p,uint32_t chain,uint32_t index,int32_t*out)
{(void)p;CHECK(chain==1&&index==0);*out=5;return 1;}
static const struct vn135_smbus_ops smbus_ops={.lock=sm_lock,.unlock=sm_unlock,.set_address=address,.select_ready=ready,.transfer=transaction,.sleep_us=sleep_us};
static const struct vn135_temperature_ops temp_ops={.mutex_init=sensor_init,.lock=sensor_lock,.unlock=sensor_unlock,.now=now,.delay_ms=delay};
static const struct vn135_reader_ops reader_ops={&temp_ops,platform,transfer,compare,offset};
static int32_t count(void*p){(void)p;return 1;}
static int32_t cancel_type(void*p,uint32_t t){(void)p;CHECK(t==1);return -1;}
static int32_t name(void*p,const char*n){(void)p;CHECK(!strcmp(n,"temp_read@btm")||!strcmp(n,"failure@btm"));return -2;}
static int32_t read_sensor(void*p,struct vn135_route_chain*c,struct vn135_temperature_sensor*s)
{struct fixture*f=p;CHECK(c==&f->chain&&s==&f->sensor);++f->reads;return vn135_temperature_read_135(s,&f->context,&reader_ops,p,&f->scratch);}
static int32_t samples_supported(void*p){(void)p;return 0;}
static int32_t chain_lock(void*p,struct vn135_route_chain*c){struct fixture*f=p;CHECK(c==&f->chain);return -1;}
static int32_t chain_unlock(void*p,struct vn135_route_chain*c){struct fixture*f=p;CHECK(c==&f->chain);return -1;}
static const struct vn135_reply_ops aggregate_ops={.temperature=&temp_ops,.chip_samples_supported=samples_supported,.chain_lock=chain_lock,.chain_unlock=chain_unlock};
static void aggregate(void*p,struct vn135_route_chain*c)
{struct fixture*f=p;++f->aggregates;vn135_temperature_aggregate_135(c,&aggregate_ops,p);}
/* Thermal trip itself is already independently recovered; here its result is
 * injected deliberately to test the poller's termination order, not re-created. */
static int32_t overheat(void*p,struct vn135_route_chain*c)
{struct fixture*f=p;CHECK(c==&f->chain);++f->overheats;return f->force_hot?-1:0;}
static int32_t stop_chain(void*p,struct vn135_route_chain*c,const char*r)
{struct fixture*f=p;CHECK(c==&f->chain&&!strcmp(r,"Lost temp sensors"));++f->stop_calls;c->state=3;return -1;}
static int32_t after_stop(void*p){(void)p;return 1;}
static int32_t refresh(void*p,struct vn135_route_chain*c)
{struct fixture*f=p;CHECK(c==&f->chain);++f->refreshes;return -1;}
static void action(void*p){++((struct fixture*)p)->backend_action;}
static int32_t event(void*p,uint32_t code){struct fixture*f=p;CHECK(code==2006);++f->events;return -1;}
static int32_t off(void*p){struct fixture*f=p;++f->off_calls;f->power_tick=++f->tick;return f->off_fail?-1:0;}
static int32_t reset_line(void*p,uint32_t chain){struct fixture*f=p;CHECK(chain==0);++f->reset_calls;return -1;}
static const struct vn135_backend_power_ops power_ops={.psu_off=off,.chain_count=count,.reset_chain=reset_line};
static int32_t power_stop(void*p){struct fixture*f=p;return vn135_backend_power_stop_135(&f->shutdown.power,&power_ops,p);}
static int32_t zero(void*p){(void)p;return 0;}
static uint32_t self(void*p){(void)p;return 999;}
static int32_t detach(void*p,uint32_t handle){(void)p;CHECK(handle==999);return -1;}
static uint32_t step(void*p,uint32_t ep,uint32_t arg)
{
    struct fixture*f=p;
    if(ep==0xfdeb4)return 1;
    if(ep==0xfdfbc)return 4;
    if(ep==0x58d08){CHECK(arg==0);++f->cleanup_calls;f->cleanup_tick=++f->tick;vn135_temperature_chain_cleanup_135(&f->chain,1,&temp_ops,p);return 0;}
    CHECK(ep==0x8291c||ep==0xa6080||ep==0x663cc||ep==0x19c||ep==0x5ac80||ep==0x1082b4||ep==0x2f6ec||ep==0xf98b8||ep==0xf9840);
    /* Explicit unknown-cleanup boundary. No claim that these bodies ran. */
    return 0;
}
static int32_t cleanup(void*p,uint32_t scratch[2],uint32_t value)
{(void)p;(void)value;scratch[0]=1;scratch[1]=2;return -1;}
static int32_t marker(void*p,const char*path)
{struct fixture*f=p;CHECK(!strcmp(path,"/tmp/stopped")&&f->shutdown.state==6);++f->marks;return -1;}
static const struct vn135_shutdown_ops shutdown_ops={.trylock=zero,.unlock=zero,.delay_ms=delay,.self=self,.detach=detach,.set_thread_name=name,.step=step,.cleanup=cleanup,.mark_stopped=marker};
static int32_t create(void*p,uint32_t ep,uint32_t*handle)
{
    struct fixture*f=p;struct vn135_shutdown_scratch scratch={{0,0},0};CHECK(ep==0x72ba4);++f->creates;*handle=456;
    if(f->create_fail)return -1;
    /* Synchronous C composition, explicitly NOT a real pthread-create test. */
    CHECK(vn135_backend_shutdown_worker_135(&f->shutdown,&shutdown_ops,&power_ops,p,&scratch)==0);
    return 0;
}
static void leave(void*p,uint32_t code){struct fixture*f=p;CHECK(code==0);++f->exits;}
static const struct vn135_sensor_monitor_ops monitor_ops={.chain_count=count,.set_cancel_type=cancel_type,.set_name=name,.now=now,.delay_ms=delay,.read_sensor=read_sensor,.aggregate=aggregate,.overheat=overheat,.stop_chain=stop_chain,.after_chain_stop=after_stop,.refresh_chip_temperatures=refresh,.before_timed_abort=action,.event=event,.create_shutdown=create,.power_stop=power_stop,.worker_exit=leave};
static void init(struct fixture*f,uint32_t kind)
{
    memset(f,0,sizeof(*f));f->limit=1;f->raw=74;f->remote=80;f->clock=100;
    f->iface.fd=31;f->monitor.state=2;f->monitor.sensor_count=1;f->monitor.chains=&f->chain;f->monitor.last_chip_poll=100;
    f->chain.present=1;f->chain.state=2;f->chain.sensor_count=1;f->chain.sensors=&f->sensor;
    f->sensor.state=2;f->sensor.access_kind=kind;f->sensor.address=76;f->sensor.role=2;
    f->sensor.sampled_at=77;f->sensor.local_offset=4;f->sensor.remote_offset=-3;
    f->context=(struct vn135_reader_context){0,112,1,1,"u3s21exph"};
    f->shutdown.state=2;f->shutdown.model_chip_selector=4;f->shutdown.power.byte_ff1=1;f->shutdown.power.word_20c=13500;
}
static int32_t signed_byte(uint8_t v){return v<128?(int32_t)v:(int32_t)v-256;}
int main(void)
{
    unsigned kind,remote,v,fail,create_fail,off_fail;uint32_t handle=0;
    for(kind=3;kind<=4;++kind)for(remote=0;remote<2;++remote)for(v=0;v<256;++v){
        struct fixture*f=malloc(sizeof(*f));int32_t expected;CHECK(f);init(f,kind);f->sensor.remote_enabled=(uint8_t)remote;f->raw=(uint8_t)v;f->remote=(uint8_t)(255-v);
        vn135_temperature_monitor_135(&f->monitor,&monitor_ops,f,&handle);
        CHECK(f->exits==1&&f->reads==1);CHECK(f->sm_locks==f->sm_unlocks);CHECK(f->sensor_locks==f->sensor_unlocks&&f->bus_locks==f->bus_unlocks);
        if(kind==3&&remote){CHECK(f->creates==1&&f->off_calls==1&&f->transfers==0&&f->sensor.state==0);}
        else{
            expected=signed_byte((uint8_t)v);CHECK(f->sensor.sample==expected&&f->sensor.state==2);
            if(remote)CHECK(f->sensor.corrected==(int32_t)((double)signed_byte(f->remote)*0x1.2666666666666p+0-5.0)-3);
            else CHECK(f->sensor.corrected==expected+4);
            CHECK(f->creates==0&&f->laps==1&&f->monitor.running==0);
            CHECK(f->words==(kind==3?1u:remote?2u:1u));CHECK(f->transfers==(kind==3?1u:remote?7u:6u));
            CHECK(f->chain.local[0]==expected&&f->chain.local[2]==expected);
            if(kind==4){CHECK(f->scratch.bytes[6]==0xc5);if(remote)CHECK(f->scratch.bytes[8]==0xc5);}
        }
        free(f);++scenarios;
    }
    for(kind=3;kind<=4;++kind)for(fail=0;fail<2;++fail)for(create_fail=0;create_fail<2;++create_fail)for(off_fail=0;off_fail<2;++off_fail){
        struct fixture f;init(&f,kind);f.limit=3;f.fail_all=fail;f.force_hot=!fail;f.create_fail=create_fail;f.off_fail=off_fail;
        vn135_temperature_monitor_135(&f.monitor,&monitor_ops,&f,&handle);
        CHECK(f.creates==1&&f.off_calls==1&&f.exits==1);
        CHECK(f.reads==(fail?3u:1u));CHECK(f.stop_calls==(fail?1u:0u));CHECK(f.events==(fail?1u:0u));
        CHECK(f.shutdown.power.byte_ff1==(off_fail?1u:0u));
        if(!create_fail){CHECK(f.cleanup_calls==1&&f.mutex_inits==1&&f.sensor.state==0);CHECK(f.cleanup_tick<f.power_tick&&f.marks==1&&f.shutdown.state==6);CHECK(f.sensor.local_offset==4);if(fail)CHECK(f.sensor.failures==3&&f.sensor.sampled_at==77);}
        else{CHECK(f.cleanup_calls==0&&f.marks==0&&f.shutdown.state==2);}
        CHECK(f.reset_calls==(off_fail?0u:1u));++scenarios;
    }
    /* Successful recovery after failures inside the lower retry budget. */
    for(kind=3;kind<=4;++kind)for(fail=0;fail<=4;++fail){
        struct fixture f;init(&f,kind);f.fail_prefix=fail;
        vn135_temperature_monitor_135(&f.monitor,&monitor_ops,&f,&handle);
        if(kind==3&&fail>=3)CHECK(f.sensor.failures==1&&f.sensor.sampled_at==77);
        else CHECK(f.sensor.sample==74&&f.sensor.failures==0);
        CHECK(f.creates==0&&f.exits==1);++scenarios;
    }
    /* The complete loop intentionally skips asynchronous and failed sensors. */
    for(kind=0;kind<6;++kind){
        struct fixture f;init(&f,kind);f.sensor.state=3;f.monitor.last_chip_poll=100;
        vn135_temperature_monitor_135(&f.monitor,&monitor_ops,&f,&handle);
        CHECK(f.reads==0&&f.transfers==0&&f.exits==1);++scenarios;
    }
    printf("SENSOR_PIPELINE135_NATIVE_PASS scenarios=%u assertions=%u hardware=no threads=scripted\n",scenarios,checks);
    return 0;
}
