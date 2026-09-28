/* Read-only hwscan output consumer. New integration API, GPL-3.0-or-later. */
#ifndef DIZZASS_HWSCAN_PROFILE_H
#define DIZZASS_HWSCAN_PROFILE_H
#include <stdint.h>
#include <stddef.h>
#define DIZZASS_PROFILE_MAX_BOARDS 16u
#define DIZZASS_PROFILE_TEXT 96u
#define DIZZASS_PROFILE_MAX_JSON (256u * 1024u)
enum dizzass_profile_status {
    DIZZASS_PROFILE_OK=0, DIZZASS_PROFILE_INVALID=-500,
    DIZZASS_PROFILE_UNSUPPORTED=-501, DIZZASS_PROFILE_NOT_READY=-502,
    DIZZASS_PROFILE_IO=-503, DIZZASS_PROFILE_CHANGED=-504
};
struct dizzass_profile_board {
    uint32_t id;
    int ready;
    char model[DIZZASS_PROFILE_TEXT];
};
struct dizzass_hwscan_profile {
    uint32_t platform, algorithm, chip;
    uint32_t chips_per_chain, nominal_boards, board_count, uart_speed;
    uint32_t ver_roll_mask, ticket_mask;
    char model[DIZZASS_PROFILE_TEXT];
    char detected_model[DIZZASS_PROFILE_TEXT];
    struct dizzass_profile_board boards[DIZZASS_PROFILE_MAX_BOARDS];
};
/* Inputs are bounded JSON buffers from the SAME quiescent scan. No scanner,
 * hardware probe, baud selection, default chip count or power configuration.
 * Uses native cgminer Jansson, rejects duplicate keys and invalid types.
 * Only AML + sha256d + BM1368, non-bypass mode are accepted in this increment.
 * Profile and detected model strings are preserved separately: equality and
 * T21 identity are NOT inferred. All output is unchanged on error.
 */
int dizzass_hwscan_profile_parse(const char *fw, size_t fw_size,
    const char *model, size_t model_size, const char *hw, size_t hw_size,
    struct dizzass_hwscan_profile *out);
/* Trusted directory descriptors; fixed basenames, no symlinks, regular files
 * only, bounded reads. Checks metadata before/after and pathname replacement.
 * This detects observed changes, NOT cross-file atomic publication: the caller
 * must stop/join hwscan or consume a coherently published snapshot first.
 * fw_dir: fw-info.json; scan_dir: miner-model.json and hw-info.json.
 */
int dizzass_hwscan_profile_read_at(int fw_dir, int scan_dir,
    struct dizzass_hwscan_profile *out);
int dizzass_hwscan_profile_validate(const struct dizzass_hwscan_profile *profile,
    uint32_t chain_id);
#endif
