/* New bounded consumer of the observed hwscan schema; not a hwscan reimplementation. */
#ifndef _GNU_SOURCE
#define _GNU_SOURCE 1
#endif
#include "integration/hwscan_profile.h"
#include <jansson.h>
#include <errno.h>
#include <fcntl.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <unistd.h>

static int text(json_t *object, const char *key, char *out, size_t capacity)
{
    json_t *v=json_object_get(object,key);
    const char *s; size_t n;
    if (!json_is_string(v)) return -1;
    s=json_string_value(v); n=json_string_length(v);
    if (!n || n>=capacity || memchr(s,0,n)) return -1;
    memcpy(out,s,n); out[n]=0; return 0;
}
static int number(json_t *o,const char *key,uint32_t low,uint32_t high,uint32_t *out)
{
    json_t *v=json_object_get(o,key); json_int_t n;
    if (!json_is_integer(v)) return -1;
    n=json_integer_value(v);
    if (n<0 || (uint64_t)n<low || (uint64_t)n>high) return -1;
    *out=(uint32_t)n; return 0;
}
static int bounded_text(const char *s)
{ return s[0] && memchr(s,0,DIZZASS_PROFILE_TEXT)!=NULL; }
int dizzass_hwscan_profile_validate(const struct dizzass_hwscan_profile *p,uint32_t id)
{
    uint32_t i,j; int found=0;
    if (!p || !bounded_text(p->model) || !bounded_text(p->detected_model) ||
        !p->board_count || p->board_count>DIZZASS_PROFILE_MAX_BOARDS ||
        !p->nominal_boards || p->nominal_boards>DIZZASS_PROFILE_MAX_BOARDS ||
        p->board_count>p->nominal_boards || !p->chips_per_chain ||
        p->chips_per_chain>256 || !p->uart_speed || p->uart_speed>10000000)
        return DIZZASS_PROFILE_INVALID;
    if (p->platform!=2 || p->algorithm!=0 || p->chip!=4)
        return DIZZASS_PROFILE_UNSUPPORTED;
    for(i=0;i<p->board_count;++i) {
        if(p->boards[i].id>=DIZZASS_PROFILE_MAX_BOARDS ||
            !bounded_text(p->boards[i].model) ||
            (p->boards[i].ready!=0 && p->boards[i].ready!=1))
            return DIZZASS_PROFILE_INVALID;
        for(j=0;j<i;++j) if(p->boards[j].id==p->boards[i].id)
            return DIZZASS_PROFILE_INVALID;
        if(p->boards[i].id==id) found=p->boards[i].ready ? 1 : -1;
    }
    return found==1 ? 0 : DIZZASS_PROFILE_NOT_READY;
}
int dizzass_hwscan_profile_parse(const char *fw,size_t nf,const char *model,size_t nm,
    const char *hw,size_t nh,struct dizzass_hwscan_profile *out)
{
    json_t *f=NULL,*m=NULL,*h=NULL,*board,*chip,*a,*v;
    struct dizzass_hwscan_profile p={0};
    char name[DIZZASS_PROFILE_TEXT]; uint32_t i,j;
    int rc=DIZZASS_PROFILE_INVALID;
    if(!out||!fw||!model||!hw||!nf||!nm||!nh||nf>DIZZASS_PROFILE_MAX_JSON||
        nm>DIZZASS_PROFILE_MAX_JSON||nh>DIZZASS_PROFILE_MAX_JSON) return rc;
    f=json_loadb(fw,nf,JSON_REJECT_DUPLICATES,NULL);
    m=json_loadb(model,nm,JSON_REJECT_DUPLICATES,NULL);
    h=json_loadb(hw,nh,JSON_REJECT_DUPLICATES,NULL);
    if(!json_is_object(f)||!json_is_object(m)||!json_is_object(h)) goto done;
    if(text(f,"platform",name,sizeof(name))) goto done;
    if(strcmp(name,"aml")) { rc=DIZZASS_PROFILE_UNSUPPORTED; goto done; }
    p.platform=2;
    if(text(m,"algorithm",name,sizeof(name))) goto done;
    if(strcmp(name,"sha256d")) { rc=DIZZASS_PROFILE_UNSUPPORTED; goto done; }
    p.algorithm=0;
    if(text(m,"model",p.model,sizeof(p.model)) ||
       text(h,"model",p.detected_model,sizeof(p.detected_model)) ||
       text(h,"status",name,sizeof(name))) goto done;
    if(strcmp(name,"ok")) { rc=DIZZASS_PROFILE_NOT_READY; goto done; }
    v=json_object_get(m,"bypass_mode");
    if(!json_is_boolean(v)) goto done;
    if(json_is_true(v)) { rc=DIZZASS_PROFILE_UNSUPPORTED; goto done; }
    board=json_object_get(m,"board"); chip=json_object_get(m,"chip");
    if(!json_is_object(board)||!json_is_object(chip)) goto done;
    if(text(chip,"model",name,sizeof(name))) goto done;
    if(strcmp(name,"BM1368")) { rc=DIZZASS_PROFILE_UNSUPPORTED; goto done; }
    p.chip=4;
    if(number(m,"num_boards",1,DIZZASS_PROFILE_MAX_BOARDS,&p.nominal_boards)||
       number(board,"num_chips",1,256,&p.chips_per_chain)||
       number(chip,"uart_speed",1,10000000,&p.uart_speed)||
       number(chip,"ver_roll_mask",0,UINT32_MAX,&p.ver_roll_mask)||
       number(chip,"ticket_mask",0,UINT32_MAX,&p.ticket_mask)) goto done;
    a=json_object_get(h,"boards");
    if(!json_is_array(a)||!json_array_size(a)||json_array_size(a)>p.nominal_boards) goto done;
    p.board_count=(uint32_t)json_array_size(a);
    for(i=0;i<p.board_count;++i) {
        v=json_array_get(a,i);
        if(!json_is_object(v)||number(v,"id",0,DIZZASS_PROFILE_MAX_BOARDS-1,&p.boards[i].id)||
           text(v,"model",p.boards[i].model,sizeof(p.boards[i].model))||
           text(v,"status",name,sizeof(name))) goto done;
        p.boards[i].ready=!strcmp(name,"ok");
        for(j=0;j<i;++j) if(p.boards[i].id==p.boards[j].id) goto done;
    }
    /* A not-ready board is preserved but never admitted by validate(). */
    rc=0; *out=p;
done:
    json_decref(h); json_decref(m); json_decref(f); return rc;
}
struct input_file { int fd; char *data; size_t size; struct stat st; };
static int same_file(const struct stat *a,const struct stat *b)
{
    return a->st_dev==b->st_dev&&a->st_ino==b->st_ino&&a->st_size==b->st_size&&
        a->st_mtim.tv_sec==b->st_mtim.tv_sec&&a->st_mtim.tv_nsec==b->st_mtim.tv_nsec&&
        a->st_ctim.tv_sec==b->st_ctim.tv_sec&&a->st_ctim.tv_nsec==b->st_ctim.tv_nsec;
}
static int read_one(int dir,const char *name,struct input_file *f)
{
    size_t pos=0; ssize_t n; struct stat after;
    f->fd=openat(dir,name,O_RDONLY|O_CLOEXEC|O_NOFOLLOW|O_NONBLOCK);
    if(f->fd<0||fstat(f->fd,&f->st)) return DIZZASS_PROFILE_IO;
    if(!S_ISREG(f->st.st_mode)||f->st.st_size<=0||
       (uint64_t)f->st.st_size>DIZZASS_PROFILE_MAX_JSON) return DIZZASS_PROFILE_INVALID;
    f->size=(size_t)f->st.st_size;
    f->data=malloc(f->size+1); if(!f->data) return DIZZASS_PROFILE_IO;
    while(pos<f->size+1) {
        n=read(f->fd,f->data+pos,f->size+1-pos);
        if(n<0&&errno==EINTR) continue;
        if(n<0) return DIZZASS_PROFILE_IO;
        if(!n) break;
        pos+=(size_t)n;
    }
    if(pos!=f->size||fstat(f->fd,&after)||!same_file(&f->st,&after))
        return DIZZASS_PROFILE_CHANGED;
    return 0;
}
int dizzass_hwscan_profile_read_at(int fw_dir,int scan_dir,struct dizzass_hwscan_profile *out)
{
    const char *names[3]={"fw-info.json","miner-model.json","hw-info.json"};
    int dirs[3]={fw_dir,scan_dir,scan_dir},rc=0,i;
    struct input_file f[3]={{.fd=-1},{.fd=-1},{.fd=-1}};
    struct dizzass_hwscan_profile p;
    if(!out||fw_dir<0||scan_dir<0) return DIZZASS_PROFILE_INVALID;
    for(i=0;i<3;++i) if((rc=read_one(dirs[i],names[i],&f[i]))) goto done;
    rc=dizzass_hwscan_profile_parse(f[0].data,f[0].size,f[1].data,f[1].size,f[2].data,f[2].size,&p);
    if(rc) goto done;
    for(i=0;i<3;++i) {
        struct stat st,byname;
        if(fstat(f[i].fd,&st)||fstatat(dirs[i],names[i],&byname,AT_SYMLINK_NOFOLLOW)||
           !S_ISREG(byname.st_mode)||!same_file(&f[i].st,&st)||!same_file(&st,&byname)) {
            rc=DIZZASS_PROFILE_CHANGED; goto done;
        }
    }
    *out=p;
done:
    for(i=0;i<3;++i) { if(f[i].fd>=0) close(f[i].fd); free(f[i].data); }
    return rc;
}
