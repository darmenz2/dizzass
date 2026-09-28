/* Original entry b4c58. Source filename not established; this is an explicit
 * integration/support path, NOT an invented vendor filename. */
#include "integration/fan_control_135.h"
_Static_assert(sizeof(struct vn135_fan_record)==36,"Known record stride");
int vn135_fan_records_init(struct vn135_fan_records *s,
    const struct vn135_fan_records_ops *o,void *p)
{
    struct vn135_fan_record *first=o->allocate(p,(uint32_t)s->configured_count,36);
    int32_t i;
    s->records=first;
    if(!first)return -1;
    if(s->configured_count>=1){
        first->value=0;first->lost=1;first->index=0;
        (void)o->mutex_init(p,first);
        for(i=1;i<s->configured_count;++i){
            struct vn135_fan_record *r=&s->records[i];
            r->value=0;r->lost=1;r->index=(uint32_t)i;
            (void)o->mutex_init(p,r);
        }
    }
    (void)o->controller_init(p,s->ceiling);
    return 0;
}
