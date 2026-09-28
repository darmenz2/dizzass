#ifndef _GNU_SOURCE
#define _GNU_SOURCE 1
#endif
#include "integration/hwscan_profile.h"
#include "integration/tests/hwscan_fixture.h"
#include <jansson.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <unistd.h>
static unsigned checks;
#define CHECK(x) do {++checks;if(!(x)){fprintf(stderr,"profile %d: %s\n",__LINE__,#x);exit(1);}}while(0)
static int parse(const char *f,const char *m,const char *h,struct dizzass_hwscan_profile *p)
{ return dizzass_hwscan_profile_parse(f,strlen(f),m,strlen(m),h,strlen(h),p); }
static void save(int dir,const char *name,const char *data)
{
    int fd=openat(dir,name,O_WRONLY|O_CREAT|O_TRUNC,0600);
    CHECK(fd>=0);CHECK(write(fd,data,strlen(data))==(ssize_t)strlen(data));CHECK(close(fd)==0);
}
int main(void)
{
    struct dizzass_hwscan_profile p,before;json_t *m,*h,*obj;char *encoded;
    const char *bad[]={"null","[]","{","{\"platform\":\"aml\",\"platform\":\"aml\"}","{\"platform\":17}"};
    unsigned i;char path[]="/tmp/dizzass-profile-XXXXXX";int dir;
    memset(&p,0xa5,sizeof(p));before=p;
    for(i=0;i<sizeof(bad)/sizeof(bad[0]);++i) {
        CHECK(parse(bad[i],fixture_model_json,fixture_hw_json,&p)==DIZZASS_PROFILE_INVALID);
        CHECK(!memcmp(&p,&before,sizeof(p)));
    }
    CHECK(parse("{\"platform\":\"xil\"}",fixture_model_json,fixture_hw_json,&p)==DIZZASS_PROFILE_UNSUPPORTED);
    CHECK(parse(fixture_fw_json,fixture_model_json,fixture_hw_json,&p)==0);
    CHECK(p.platform==2&&p.algorithm==0&&p.chip==4&&p.chips_per_chain==108&&p.board_count==2&&p.uart_speed==115200);
    CHECK(strcmp(p.model,p.detected_model)!=0); /* No unproven identity equivalence. */
    CHECK(dizzass_hwscan_profile_validate(&p,2)==0);
    CHECK(dizzass_hwscan_profile_validate(&p,0)==DIZZASS_PROFILE_NOT_READY);
    CHECK(dizzass_hwscan_profile_validate(&p,1)==DIZZASS_PROFILE_NOT_READY);
    for(i=0;i<5;++i) {
        m=json_loads(fixture_model_json,0,NULL);CHECK(m);
        if(i==0)CHECK(json_object_set_new(m,"algorithm",json_string("scrypt"))==0);
        if(i==1)CHECK(json_object_set_new(m,"bypass_mode",json_true())==0);
        obj=json_object_get(m,"chip");
        if(i==2)CHECK(json_object_set_new(obj,"model",json_string("BM1398"))==0);
        if(i==3)CHECK(json_object_set_new(obj,"uart_speed",json_integer(0))==0);
        if(i==4)CHECK(json_object_set_new(json_object_get(m,"board"),"num_chips",json_integer(257))==0);
        encoded=json_dumps(m,0);CHECK(encoded);before=p;
        CHECK(parse(fixture_fw_json,encoded,fixture_hw_json,&p)!=0);
        CHECK(!memcmp(&p,&before,sizeof(p)));free(encoded);json_decref(m);
    }
    h=json_loads(fixture_hw_json,0,NULL);CHECK(h);
    obj=json_array_get(json_object_get(h,"boards"),1);CHECK(json_object_set_new(obj,"id",json_integer(2))==0);
    encoded=json_dumps(h,0);CHECK(encoded);before=p;
    CHECK(parse(fixture_fw_json,fixture_model_json,encoded,&p)==DIZZASS_PROFILE_INVALID);
    CHECK(!memcmp(&p,&before,sizeof(p)));free(encoded);json_decref(h);
    CHECK(mkdtemp(path));dir=open(path,O_DIRECTORY|O_RDONLY|O_CLOEXEC);CHECK(dir>=0);
    save(dir,"fw-info.json",fixture_fw_json);save(dir,"miner-model.json",fixture_model_json);save(dir,"hw-info.json",fixture_hw_json);
    CHECK(dizzass_hwscan_profile_read_at(dir,dir,&p)==0);CHECK(p.chips_per_chain==108);
    before=p;CHECK(unlinkat(dir,"hw-info.json",0)==0);
    CHECK(symlinkat("miner-model.json",dir,"hw-info.json")==0);
    CHECK(dizzass_hwscan_profile_read_at(dir,dir,&p)==DIZZASS_PROFILE_IO);
    CHECK(!memcmp(&p,&before,sizeof(p)));CHECK(unlinkat(dir,"hw-info.json",0)==0);
    CHECK(mkfifoat(dir,"hw-info.json",0600)==0);
    CHECK(dizzass_hwscan_profile_read_at(dir,dir,&p)==DIZZASS_PROFILE_INVALID);
    CHECK(unlinkat(dir,"hw-info.json",0)==0);
    save(dir,"hw-info.json",fixture_hw_json);
    {int fd=openat(dir,"miner-model.json",O_WRONLY);CHECK(fd>=0);CHECK(ftruncate(fd,DIZZASS_PROFILE_MAX_JSON+1)==0);close(fd);}
    CHECK(dizzass_hwscan_profile_read_at(dir,dir,&p)==DIZZASS_PROFILE_INVALID);
    CHECK(!memcmp(&p,&before,sizeof(p)));
    CHECK(unlinkat(dir,"fw-info.json",0)==0&&unlinkat(dir,"miner-model.json",0)==0&&unlinkat(dir,"hw-info.json",0)==0);
    close(dir);CHECK(rmdir(path)==0);
    printf("HWSCAN_PROFILE_PASS checks=%u live_scan=no\n",checks);return 0;
}
