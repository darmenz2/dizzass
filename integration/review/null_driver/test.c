/* GPL-3.0-or-later. Exercise the actual core driver table and stop API.
 * No freed pointers: an old wake is a harmless counter/error sentinel. */
#define R13_STOP_EMBED
#include "integration/review/queue_stop/test.c"

static unsigned cases15, checks15, retired_wake_calls;
static int wake_error15;
static struct cgpu_info *expected15;
#define C15(x) do { ++checks15; if (!(x)) { fprintf(stderr, "R15_ASSERT line=%d expr=%s calls=%u\n", __LINE__, #x, retired_wake_calls); exit(1); } } while (0)

static int old_wake15(struct cgpu_info *g)
{
    C15(g == expected15);
    ++retired_wake_calls;
    C15(pthread_mutex_trylock(stgd_lock) == 0);
    C15(pthread_mutex_unlock(stgd_lock) == 0);
    return wake_error15;
}
static void fixture15(struct device_drv *drv, struct cgpu_info *g, int error)
{
    memset(drv, 0, sizeof(*drv)); memset(g, 0, sizeof(*g));
    drv->queued_stop_wake = old_wake15; g->drv = drv;
    expected15 = g; retired_wake_calls = 0; wake_error15 = error;
}
static void neutralized15(int error)
{
    struct device_drv drv; struct cgpu_info g; fixture15(&drv, &g, error);
    null_device_drv(&drv);
    int rc = cgminer_request_queued_stop(&g);
    /* Deliberately check observed call behavior before checking the pointer. */
    C15(retired_wake_calls == 0 && rc == 0);
    C15(drv.queued_stop_wake == NULL && cgminer_queued_stopped(&g));
    C15(drv.queue_full == noop_queue_full && drv.hash_work == noop_hash_work);
    ++cases15;
}
static void live15(void)
{
    struct device_drv drv; struct cgpu_info g; fixture15(&drv, &g, EIO);
    fill_device_drv(&drv);
    C15(drv.queued_stop_wake == old_wake15);
    for (unsigned i = 0; i < 3; ++i) C15(cgminer_request_queued_stop(&g) == EIO);
    C15(retired_wake_calls == 3 && cgminer_queued_stopped(&g));
    ++cases15;
}
static void retry15(void)
{
    struct device_drv drv; struct cgpu_info g; fixture15(&drv, &g, EIO);
    C15(cgminer_request_queued_stop(&g) == EIO && retired_wake_calls == 1);
    null_device_drv(&drv);
    C15(cgminer_request_queued_stop(&g) == 0 && retired_wake_calls == 1);
    C15(cgminer_queued_stopped(&g)); ++cases15;
}
static void refill15(void)
{
    struct device_drv drv; struct cgpu_info g; fixture15(&drv, &g, EIO);
    null_device_drv(&drv); fill_device_drv(&drv);
    C15(drv.queued_stop_wake == NULL);
    C15(cgminer_request_queued_stop(&g) == 0 && retired_wake_calls == 0);
    ++cases15;
}
static void copied15(void)
{
    struct device_drv original; struct cgpu_info source;
    fixture15(&original, &source, EIO);
    struct device_drv *copy = copy_drv(&original);
    C15(copy != &original && copy->copy && copy->queued_stop_wake == old_wake15);
    struct cgpu_info retired = {.drv = copy}; expected15 = &retired;
    null_device_drv(copy);
    C15(original.queued_stop_wake == old_wake15);
    C15(cgminer_request_queued_stop(&retired) == 0 && retired_wake_calls == 0);
    expected15 = &source;
    C15(cgminer_request_queued_stop(&source) == EIO && retired_wake_calls == 1);
    C15(copy->queued_stop_wake == NULL && copy->copy);
    free(copy); ++cases15;
}
static void repeated15(void)
{
    struct device_drv drv = {0}; struct cgpu_info g = {.drv = &drv};
    expected15 = &g; retired_wake_calls = 0;
    null_device_drv(&drv); null_device_drv(&drv);
    for (unsigned i = 0; i < 3; ++i) C15(cgminer_request_queued_stop(&g) == 0);
    C15(!drv.queued_stop_wake && !retired_wake_calls && cgminer_queued_stopped(&g));
    ++cases15;
}
static void semaphores15(void)
{
    struct device_drv drv; struct cgpu_info g; fixture15(&drv, &g, EIO);
    struct thr_info thread[3] = {{0}};
    struct thr_info *list[4] = {&thread[0], NULL, &thread[1], &thread[2]};
    for (unsigned i = 0; i < 3; ++i) { thread[i].cgpu = &g; cgsem_init(&thread[i].sem); }
    g.threads = 4; g.thr = list; null_device_drv(&drv);
    C15(cgminer_request_queued_stop(&g) == 0);
    for (unsigned i = 0; i < 3; ++i) {
        int n = -1; C15(sem_getvalue(&thread[i].sem, &n) == 0 && n == 1);
    }
    C15(cgminer_request_queued_stop(&g) == 0 && !retired_wake_calls);
    for (unsigned i = 0; i < 3; ++i) {
        int n = -1; C15(sem_getvalue(&thread[i].sem, &n) == 0 && n == 1);
        cgsem_destroy(&thread[i].sem);
    }
    ++cases15;
}
int main(void)
{
    alarm(20); rwlock_init(&devices_lock); mutex_init(&stats_lock);
    mutex_init(&console_lock); cglock_init(&control_lock);
    getq = tq_new(); C15(getq != NULL); stgd_lock = &getq->mutex;
    C15(pthread_cond_init(&gws_cond, NULL) == 0);
    opt_debug = false; opt_quiet = true; opt_realquiet = true;
    neutralized15(EIO); neutralized15(0); live15(); retry15();
    refill15(); copied15(); repeated15(); semaphores15();
    C15(cases15 == 8 && !staged_work && !staged_rollable);
    tq_free(getq); getq = NULL; stgd_lock = NULL;
    C15(pthread_cond_destroy(&gws_cond) == 0);
    printf("R15_PASS cases=%u checks=%u real_core=1 sentinel_only=1 hardware=0\n", cases15, checks15);
    return 0;
}
