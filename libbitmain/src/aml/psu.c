/* Observed /tmp/build/libbitmain/src/aml/psu.c, VNishNet 1.3.5.
 * 0x11c5c0: interface initialization; 0x11c968: getter.
 * Partial original-domain translation. No new shutdown or fallback policy.
 */
#include "integration/i2c_init_135.h"
static int psu_init_error(const struct vn135_i2c_init_ops *o, void *p, uint32_t line)
{
    if (o->log) o->log(p,VN135_INIT_AML_PSU,line);
    return -1;
}
int vn135_aml_psu_bus_initialize_135(struct vn135_aml_psu_bus *s,
    const struct vn135_i2c_init_ops *o, void *p)
{
    if (o->is_exported(p,437)) (void)o->unexport(p,437);
    if (o->set_direction(p,437,1)) return psu_init_error(o,p,38);
    if (vn135_i2c_register_135(&s->registration,o,p,1,0,"i2c:psu-bus"))
        return psu_init_error(o,p,43);
    if (vn135_i2c_gpio_initialize_135(&s->gpio,o,p,477,476))
        return psu_init_error(o,p,48);
    s->ready=1;
    return 0;
}
struct vn135_i2c_registration *vn135_aml_psu_bus_get_135(
    struct vn135_aml_psu_bus *s, uint32_t index)
{
    (void)index;
    return &s->registration;
}
