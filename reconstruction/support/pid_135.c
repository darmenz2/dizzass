/* Numeric helper cluster from the pinned 1.3.5 image, entries fb530..fb98c.
 * Original source path is unknown. This support filename is an integration name.
 * Finite binary64 translation; no new PID policy or hardware operations. */
#include "integration/fan_control_135.h"
#include <float.h>
#include <math.h>
_Static_assert(sizeof(double)==8 && DBL_MANT_DIG==53,"IEEE binary64 required");
void vn135_pid_init(struct vn135_pid *s,double kp,double ki,double kd)
{
    s->integral=0.0;s->direction=0;s->kp=kp;s->ki=ki;s->kd=kd;
    s->target=0.0;s->input=0.0;s->output=0.0;
    s->lower=-DBL_MAX;s->upper=DBL_MAX;
    /* Source does NOT initialize previous_error or the padding word. */
}
void vn135_pid_gains(struct vn135_pid *s,double p,double i,double d)
{ s->kp=p;s->ki=i;s->kd=d; }
void vn135_pid_limits(struct vn135_pid *s,double lo,double hi)
{ if(lo-hi<=0x1.0624dd2f1a9fcp-10){s->lower=lo;s->upper=hi;} }
void vn135_pid_target(struct vn135_pid *s,double x){s->target=x;}
double vn135_pid_get_target(const struct vn135_pid *s){return s->target;}
void vn135_pid_direction(struct vn135_pid *s,uint32_t x){s->direction=x;}
void vn135_pid_input(struct vn135_pid *s,double x){s->input=x;}
void vn135_pid_seed(struct vn135_pid *s,double x)
{
    double hi=s->upper,lo=s->lower,span=hi-lo,error=s->target-s->input;
    double v=(s->direction==1?hi-x:x)-s->kp*error;
    double margin=span*0x1.999999999999ap-3;
    double top=s->direction?span:hi+margin;
    double bottom=s->direction?0.0-margin:lo;
    double out=v;
    if(top<v)out=top;
    if(bottom>v)out=bottom;
    s->output=x;s->integral=out;
}
void vn135_pid_step(struct vn135_pid *s,double dt)
{
    const double eps=0x1.47ae147ae147bp-7;
    double error,derivative,integral,p,candidate,limited,excess,lo,hi;
    if(dt<eps)return;
    error=s->target-s->input;
    derivative=(s->kd*(error-s->previous_error))/dt;
    integral=s->integral+(error*s->ki)*dt;
    p=s->kp*error;
    candidate=(p+integral)+derivative;
    hi=s->direction?s->upper-s->lower:s->upper;
    lo=s->direction?0.0:s->lower;
    limited=candidate;
    if(hi<candidate)limited=hi;
    if(lo>candidate)limited=lo;
    excess=candidate-limited;
    s->previous_error=error;
    if(fabs(excess)>eps && error*excess>0.0){
        candidate=(p+s->integral)+derivative;
        integral=s->integral;
    }
    s->integral=integral;
    s->output=s->direction==1?s->upper-candidate:candidate;
}
double vn135_pid_output(const struct vn135_pid *s)
{
    double v=s->output,result=v;
    if(v>s->upper)result=s->upper;
    if(v<s->lower)result=s->lower;
    return result;
}
