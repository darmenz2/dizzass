/* SPDX-License-Identifier: GPL-3.0-only */
/* TEST-ONLY wire data between the native harness and Python oracle. */
#ifndef RT135_FIXTURE_H
#define RT135_FIXTURE_H
#include <stdint.h>
#define RT_NC 3
#define RT_NS 2
#define RT_SNAP 256
#define RT_EVENTS 1024
struct rt_case {
    uint32_t state,mode,selector,platform,kind,role;
    int32_t sensors,count;
    uint32_t fault_mask,fault_kind,partial,suppress;
    int32_t minimum,create_fail,create_rc;
    uint32_t error_write,scheduled;
    int32_t on_rc,voltage_rc,off_rc;
    uint32_t fail_step;
    int32_t fail_rc;
    uint32_t followup,repeat_stop,join_flag,join_seed,join_value;
    int32_t join_rc;
    uint32_t join_writes,self_handle,board_flag,key,present_mask,chain_state,no_log;
};
struct rt_result {
    int32_t resume_rc;
    uint32_t event_count,length[3],phase_events[3];
    uint32_t snapshot[3][RT_SNAP];
    uint32_t events[RT_EVENTS][6];
};
enum rt_event { E_STEP=1,E_LOG,E_POWER_LOG,E_SENSOR_LOG,E_CREATE,E_JOIN,
    E_DUP,E_FREE,E_TIME,E_REGISTER,E_STOP,E_CONFIG,E_READ,E_WRITE,E_FINISH,
    E_SELF,E_CANCEL,E_DETACH,E_MARK,E_ON,E_VOLT,E_OFF,E_RESET,E_COUNT };
void rt135_default(struct rt_case *);
int rt135_run(const struct rt_case *,struct rt_result *);
#endif
