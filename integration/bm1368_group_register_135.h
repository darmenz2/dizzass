/* Typed projection of original cgminer b58e4, not a recovered header/ABI.
 * Exact original source-file attribution is unproved; no driver.c claim. */
#ifndef VN135_BM1368_GROUP_REGISTER_135_H
#define VN135_BM1368_GROUP_REGISTER_135_H
#include "integration/bm1368_drive_strength_135.h"

/* Named values from the board view returned by the pure model+38 accessor.
 * These are not original offsets or a layout that can be cast from firmware. */
struct vn135_bm1368_group_board_135 {
    uint32_t address_stride;   /* original board+00 */
    uint32_t chips_per_group;  /* original board+14 */
    int32_t group_count;       /* original board+18, signed */
    uint8_t enabled;           /* original board+3c, entire byte */
    uint8_t drive_strength;    /* original board+40 */
};
typedef int32_t (*vn135_bm1368_group_method_135)(void *,
    struct vn135_bm1368_frequency_device *, vn135_chip_reference *, uint32_t);
struct vn135_bm1368_group_owner_135 {
    struct vn135_bm1368_group_board_135 *board;
    vn135_bm1368_group_method_135 configure; /* selected original owner+194 */
    void *context; /* new host association, no original offset */
};
struct vn135_bm1368_group_chain_135 {
    struct vn135_bm1368_group_owner_135 *owner; /* original C+1c identity */
    struct vn135_bm1368_frequency_device *device; /* original C+2b8 identity */
};
struct vn135_bm1368_group_binding_135 {
    const struct vn135_bm1368_drive_strength_read_135 *read;
    const struct vn135_bm1368_register_ops *writer;
    void *write_context;
    const struct vn135_bm1368_drive_strength_log_135 *log;
};
/* Explicit callable bridge to the actual recovered chip wrapper, not a cast
 * of constructor identity e3728 or a successful hardware placeholder. */
int32_t vn135_bm1368_group_drive_strength_135(void *,
    struct vn135_bm1368_frequency_device *, vn135_chip_reference *, uint32_t);

/* b58e4: retain the entry board view; whole-byte enabled==0 returns zero.
 * If enabled, capture signed group_count and the current owner. Counts<=0
 * return zero without method/device dereference. Positive groups descend to1.
 * Each iteration rereads retained board.chips_per_group/address_stride/strength
 * and retained owner.configure/context. The count and enabled byte are never
 * reread. Compute word index=(chips_per_group*group)-1 and address=index*stride
 * modulo2^32. Convert index bits exactly to the existing signed cache index.
 * Pass one temporary two-field descriptor to the selected method; any nonzero
 * result stops immediately with -1. Return zero after all calls return zero.
 *
 * Live chain/owner/board storage is required on entry. For a reached call,
 * retain captured owner/board/device identities and a returning method. The
 * method may synchronously change valid board fields, its own method/context,
 * chain.owner/device, or the borrowed descriptor fields. Captured identities
 * stay fixed; the next iteration overwrites BOTH descriptor fields. Context
 * is an added typed association, not a recovered ABI argument. No callback may
 * retain the descriptor past this invocation. No raw original0x60 stride,
 * arbitrary memory access, count clamp, delay, cache algorithm or production
 * startup binding is introduced. Invalid cache indices are handled by the
 * selected method/cache API, not by dereferencing a computed address here. */
int32_t vn135_bm1368_configure_group_drive_strength_135(
    struct vn135_bm1368_group_chain_135 *);
#endif
