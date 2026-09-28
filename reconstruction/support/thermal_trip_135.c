/* Original complete chain overheat decision, entry 0x58e68.
 * Its source filename is not established: this is an explicit support path.
 * Stop/action callbacks do not imply physical shutdown or job-drain proof.
 */
#include "integration/thermal_sensors_135.h"
int vn135_thermal_check_overheat(const struct vn135_thermal_chain *c,
    const struct vn135_thermal_limits *limits,const struct vn135_thermal_trip_ops *o,void *p)
{
    int32_t pcb,chip;uint32_t code,line,index=0,number;
    (void)o->lock(p);pcb=c->board_temperature;chip=c->chip_temperature;(void)o->unlock(p);
    if(pcb>=limits->board){
        code=3002;line=1297;number=c->index+1u;
        if(o->log)o->log(p,line,number,pcb,0);
        (void)o->stop_chain(p,0);(void)o->full_airflow(p);(void)o->event(p,code,pcb);
        return -1;
    }
    if(chip>=limits->chip){
        uint32_t selector=o->chip_selector(p);number=c->index+1u;
        if(selector==4||selector==7){
            int32_t i;double highest;
            line=1307;
            if(c->chip_count>0){
                highest=c->chips[0].value;
                /* The first record never wins a strict comparison against itself:
                 * original output index stays zero unless a later value is higher. */
                for(i=1;i<c->chip_count;++i)if(c->chips[i].value>highest){
                    highest=c->chips[i].value;index=c->chips[i].index;
                }
            }
        }else line=1310;
        if(o->log)o->log(p,line,number,chip,index);
        (void)o->stop_chain(p,1);(void)o->full_airflow(p);(void)o->event(p,3003,chip);
        return -1;
    }
    return 0;
}

/* Complete original sensor-timeout decision, entry 0x591c8. */
int vn135_temperature_check_timeouts(const struct vn135_temperature_group *g,
    const struct vn135_temperature_ops *o,void *p,uint32_t chain,uint32_t mode)
{
    int32_t i,count=g->count;
    for(i=0;i<count;++i){
        struct vn135_temperature_sensor *s=g->sensors+i;
        if(!vn135_temperature_fresh(s,o,p,g->sensor_timeout) &&
            (mode==2 || s->role==2)){
            if(o->log)o->log(p,1338,chain+1u,s->index+1u,0);
            return -1;
        }
    }
    if(!vn135_temperature_group_fresh(g,o,p)){
        if(o->log)o->log(p,1344,chain+1u,0,0);
        return -1;
    }
    return 0;
}
