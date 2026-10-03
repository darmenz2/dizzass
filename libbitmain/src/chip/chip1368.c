/* BM1368 nonce attribution: valid-domain behavior of ARM helpers e4600/e4688.
 * The original file path is decoded by constructor e5408..e54cc. Only these
 * helpers are reconstructed here, not the full chip driver. GPL-3.0-or-later.
 */
#include "integration/bm1368_nonce.h"

int dizzass_bm1368_locate(uint32_t chip_selector, uint32_t chips_per_chain,
    uint32_t nonce_word, struct dizzass_bm1368_location *out)
{
    struct dizzass_bm1368_location result;
    uint32_t field;

    if (!out || chips_per_chain == 0 ||
        chips_per_chain > DIZZASS_BM1368_MAX_CHAIN_CHIPS)
        return DIZZASS_BM1368_INVALID;
    if (chip_selector != DIZZASS_BM1368_SELECTOR)
        return DIZZASS_BM1368_UNSUPPORTED;

    field = (nonce_word >> 9) & UINT32_C(0xffff);
    result.chip = ((field * chips_per_chain) >> 16) & UINT32_C(0xff);
    result.core = nonce_word >> 25;
    *out = result;
    return DIZZASS_BM1368_OK;
}

#ifdef VN135_BM1368_INITIALIZE_135
#include "integration/bm1368_initialize_135.h"

/* Original e1450: fixed cgminer method identities, in observed store order. */
int32_t vn135_bm1368_initialize_135(
    uint32_t method_words[static VN135_BM1368_METHOD_WORDS_135])
{
    method_words[0xdc / 4] = UINT32_C(0xe4a6c);
    method_words[0xbc / 4] = UINT32_C(0xe49bc);
    method_words[0xc0 / 4] = UINT32_C(0xe49c4);
    method_words[0xc4 / 4] = UINT32_C(0xe49cc);
    method_words[0xc8 / 4] = UINT32_C(0xe49d4);
    method_words[0xcc / 4] = UINT32_C(0xe49dc);
    method_words[0xd0 / 4] = UINT32_C(0xe49e4);
    method_words[0xd4 / 4] = UINT32_C(0xe49ec);
    method_words[0xd8 / 4] = UINT32_C(0xe4a2c);
    method_words[0x9c / 4] = UINT32_C(0xe40e8);
    method_words[0xa0 / 4] = UINT32_C(0xe4198);
    method_words[0xa4 / 4] = UINT32_C(0xe41a0);
    method_words[0xa8 / 4] = UINT32_C(0xe4600);
    method_words[0xac / 4] = UINT32_C(0xe4688);
    method_words[0xb0 / 4] = UINT32_C(0xe4690);
    method_words[0xb4 / 4] = UINT32_C(0xe47b8);
    method_words[0xb8 / 4] = UINT32_C(0xe48fc);
    method_words[0x7c / 4] = UINT32_C(0xe35b4);
    method_words[0x80 / 4] = UINT32_C(0xe35c0);
    method_words[0x84 / 4] = UINT32_C(0xe3728);
    method_words[0x88 / 4] = UINT32_C(0xe3a1c);
    method_words[0x8c / 4] = UINT32_C(0xe3bbc);
    method_words[0x90 / 4] = UINT32_C(0xe3bc4);
    method_words[0x94 / 4] = UINT32_C(0xe3c04);
    method_words[0x98 / 4] = UINT32_C(0xe3dd8);
    method_words[0x5c / 4] = UINT32_C(0xe2e18);
    method_words[0x60 / 4] = UINT32_C(0xe2eb8);
    method_words[0x64 / 4] = UINT32_C(0xe3090);
    method_words[0x68 / 4] = UINT32_C(0xe3098);
    method_words[0x6c / 4] = UINT32_C(0xe3290);
    method_words[0x70 / 4] = UINT32_C(0xe32c0);
    method_words[0x74 / 4] = UINT32_C(0xe33e0);
    method_words[0x78 / 4] = UINT32_C(0xe34cc);
    method_words[0x3c / 4] = UINT32_C(0xe2978);
    method_words[0x40 / 4] = UINT32_C(0xe2980);
    method_words[0x44 / 4] = UINT32_C(0xe2988);
    method_words[0x48 / 4] = UINT32_C(0xe29c8);
    method_words[0x4c / 4] = UINT32_C(0xe2a08);
    method_words[0x50 / 4] = UINT32_C(0xe2a10);
    method_words[0x54 / 4] = UINT32_C(0xe2a18);
    method_words[0x58 / 4] = UINT32_C(0xe2d78);
    method_words[0x1c / 4] = UINT32_C(0xe1818);
    method_words[0x20 / 4] = UINT32_C(0xe1b5c);
    method_words[0x24 / 4] = UINT32_C(0xe1b64);
    method_words[0x28 / 4] = UINT32_C(0xe2130);
    method_words[0x2c / 4] = UINT32_C(0xe2210);
    method_words[0x30 / 4] = UINT32_C(0xe249c);
    method_words[0x34 / 4] = UINT32_C(0xe2808);
    method_words[0x38 / 4] = UINT32_C(0xe2810);
    method_words[0x04 / 4] = UINT32_C(0xe1790);
    method_words[0x08 / 4] = UINT32_C(0xe1798);
    method_words[0x0c / 4] = UINT32_C(0xe17a0);
    method_words[0x10 / 4] = UINT32_C(0xe17a8);
    method_words[0x14 / 4] = UINT32_C(0xe17f0);
    return 0;
}
#endif

#ifdef VN135_BM1368_RESET_135
#include "integration/bm1368_reset_135.h"

static int32_t reset_signed_index_135(uint32_t word)
{
    return word <= INT32_MAX ? (int32_t)word :
        (int32_t)((int64_t)word - INT64_C(4294967296));
}

static void reset_diagnostic_135(
    const struct vn135_bm1368_reset_ops_135 *ops,
    const struct vn135_bm1368_frequency_device *device,
    uint32_t line, const char *format, uint32_t has_index)
{
    const struct vn135_bm1368_reset_diagnostic_135 diagnostic = {
        "driver", "/tmp/build/libbitmain/src/chip/chip1368.c", "[redacted]",
        format, line, 1, has_index, has_index ? device->index + UINT32_C(1) : 0
    };
    ops->emit(ops->log_context, &diagnostic);
}

int32_t vn135_bm1368_reset_cores_135(
    struct vn135_bm1368_frequency_device *device,
    const vn135_chip_reference *chip, uint32_t fast, uint32_t unused,
    uint32_t clock, uint32_t pulse, const struct vn135_bm1368_reset_ops_135 *ops)
{
    uint32_t value = 0, misc;
    const uint32_t delay = fast != 0 ? 1u : 5u;
    const char *const misc_error = "Failed to read cached misc contol register";
    const char *const core_error = "chain#%d - failed to send core command";
    (void)unused;
    if (ops->read_cached(ops->read_context, reset_signed_index_135(device->index),
            chip->cache_index, 0x18, &value) != 0)
        reset_diagnostic_135(ops, device, 844, misc_error, 0);
    else
        (void)ops->write_register(ops->write_context, device, 0, chip,
            0x18, value & ~UINT32_C(0x300));

    value = 0;
    misc = 0; /* Original separate R3 output is zeroed before R2. */
    if (ops->read_cached(ops->read_context, reset_signed_index_135(device->index),
            chip->cache_index, 0xa8, &value) != 0)
        reset_diagnostic_135(ops, device, 816,
            "Failed to read cached soft reset register", 0);
    else if (ops->read_cached(ops->read_context, reset_signed_index_135(device->index),
            chip->cache_index, 0x18, &misc) != 0)
        reset_diagnostic_135(ops, device, 821, misc_error, 0);
    else {
        value |= UINT32_C(0x1f0);
        misc = (misc & UINT32_C(0x00f0ffff)) | UINT32_C(0xf0000000);
        if (ops->write_register(ops->write_context, device, 0, chip,
                0xa8, value) == 0)
            (void)ops->write_register(ops->write_context, device, 0, chip, 0x18, misc);
    }
    (void)ops->wait_ms(ops->wait_context, delay);

    value = 0;
    if (ops->read_cached(ops->read_context, reset_signed_index_135(device->index),
            chip->cache_index, 0x18, &value) != 0)
        reset_diagnostic_135(ops, device, 844, misc_error, 0);
    else
        (void)ops->write_register(ops->write_context, device, 0, chip,
            0x18, value | UINT32_C(0x300));
    if (ops->write_register(ops->write_context, device, 0, chip,
            0x3c, UINT32_C(0x80008b00)) != 0)
        reset_diagnostic_135(ops, device, 444,
            "chain#%d - failed to set SWEEP_CLOCK_CTRL", 1);
    (void)ops->wait_ms(ops->wait_context, delay);

    value = UINT32_C(0x80008000) | ((pulse & 3u) << 6) | ((clock & 7u) << 3);
    if (ops->write_register(ops->write_context, device, 0, chip, 0x3c, value) != 0) {
        reset_diagnostic_135(ops, device, 387, core_error, 1);
        reset_diagnostic_135(ops, device, 538,
            "chain#%d - failed to set CLOCK_DELAY_CTRL", 1);
    }
    (void)ops->wait_ms(ops->wait_context, delay);

    if (ops->write_register(ops->write_context, device, 0, chip,
            0x3c, UINT32_C(0x800082aa)) != 0)
        reset_diagnostic_135(ops, device, 387, core_error, 1);
    (void)ops->wait_ms(ops->wait_context, delay);
    (void)ops->wait_ms(ops->wait_context, 10);
    return 0;
}
#endif

#ifdef VN135_BM1368_TICKET_MASK_135
#include "integration/bm1368_ticket_mask_135.h"

int32_t vn135_bm1368_set_ticket_mask_135(
    struct vn135_bm1368_frequency_device *device, uint32_t mask,
    const struct vn135_bm1368_register_ops *writer, void *write_context,
    const struct vn135_bm1368_ticket_mask_log_135 *log)
{
    const uint32_t value = vn135_bm1398_ticket_mask_word(mask);
    if (vn135_bm1368_write_register_135(device, 1, NULL, 0x14, value,
            writer, write_context) == 0)
        return 0;
    const struct vn135_bm1368_ticket_mask_diagnostic_135 diagnostic = {
        "driver", "/tmp/build/libbitmain/src/chip/chip1368.c", "[redacted]",
        "chain#%d - failed to set TICKET_MASK", 507, 1,
        device->index + UINT32_C(1)
    };
    log->emit(log->context, &diagnostic);
    return -1;
}
#endif

#ifdef VN135_BM1368_SWEEP_CLOCK_135
#include "integration/bm1368_sweep_clock_135.h"

int32_t vn135_bm1368_set_sweep_clock_135(
    struct vn135_bm1368_frequency_device *device,
    uint32_t ignored_2, uint32_t field1_2,
    const struct vn135_bm1368_register_ops *writer, void *write_context,
    const struct vn135_bm1368_sweep_clock_log_135 *log)
{
    (void)ignored_2;
    const uint32_t value = UINT32_C(0x80008b00) | ((field1_2 & 3u) << 1);
    if (vn135_bm1368_write_register_135(device, 1, NULL, 0x3c, value,
            writer, write_context) == 0)
        return 0;
    const struct vn135_bm1368_sweep_clock_diagnostic_135 diagnostic = {
        "driver", "/tmp/build/libbitmain/src/chip/chip1368.c", "[redacted]",
        "chain#%d - failed to set SWEEP_CLOCK_CTRL", 463, 1,
        device->index + UINT32_C(1)
    };
    log->emit(log->context, &diagnostic);
    return -1;
}
#endif

#ifdef VN135_BM1368_ADDRESS_COMMANDS_135
#include "integration/bm1368_address_commands_135.h"
#include "integration/bm1368_control.h"

int32_t vn135_bm1368_inactivate_135(
    const struct vn135_common_read_device_135 *device,
    const struct vn135_transport_dispatch_135 *transport,
    const struct vn135_bm1368_address_log_135 *log)
{
    uint8_t frame[7];
    size_t written = 0;
    if (dizzass_bm1368_command_encode(DIZZASS_BM1368_INACTIVE, 0, 0, 0, 0,
            frame, sizeof frame, &written) || written != sizeof frame)
        return -1; /* Unreachable for the pinned encoder's bounded arguments. */
    if (vn135_transport_send_135(transport, device->identity, frame + 2, 5) == 0)
        return 0;
    const struct vn135_bm1368_address_diagnostic_135 diagnostic = {
        "driver", "/tmp/build/libbitmain/src/chip/chip1368.c", "[redacted]",
        "chain#%d - failed to inactivate the chain", 669, 1,
        *device->index + UINT32_C(1), 0, 0
    };
    log->emit(log->context, &diagnostic);
    return -1;
}

int32_t vn135_bm1368_assign_address_135(
    const struct vn135_common_read_device_135 *device,
    const vn135_chip_reference *chip,
    const struct vn135_transport_dispatch_135 *transport,
    const struct vn135_bm1368_address_log_135 *log)
{
    uint8_t frame[7];
    size_t written = 0;
    if (dizzass_bm1368_command_encode(DIZZASS_BM1368_SET_ADDRESS, 0,
            chip->wire_address & 255u, 0, 0, frame, sizeof frame, &written) ||
            written != sizeof frame)
        return -1; /* Unreachable for the pinned encoder's bounded arguments. */
    if (vn135_transport_send_135(transport, device->identity, frame + 2, 5) == 0)
        return 0;
    const struct vn135_bm1368_address_diagnostic_135 diagnostic = {
        "driver", "/tmp/build/libbitmain/src/chip/chip1368.c", "[redacted]",
        "chain#%d - failed to assign chip address to 0x%02x", 699, 1,
        *device->index + UINT32_C(1), 1, chip->wire_address
    };
    log->emit(log->context, &diagnostic);
    return -1;
}
#endif

#ifdef VN135_BM1368_DRIVE_STRENGTH_135
#include "integration/bm1368_drive_strength_135.h"

static int32_t drive_strength_signed_index_135(uint32_t word)
{
    return word <= INT32_MAX ? (int32_t)word :
        (int32_t)((int64_t)word - INT64_C(4294967296));
}

int32_t vn135_bm1368_drive_strength_cache_chain_135(
    void *cache, int32_t chain, uint32_t reg, uint32_t *value)
{
    return vn135_reg_cache_get_chain(cache, chain, reg, value);
}

int32_t vn135_bm1368_drive_strength_cache_chip_135(
    void *cache, int32_t chain, int32_t chip, uint32_t reg, uint32_t *value)
{
    return vn135_reg_cache_get_chip(cache, chain, chip, reg, value);
}

static void drive_strength_diagnostic_135(
    const struct vn135_bm1368_drive_strength_log_135 *log,
    const struct vn135_bm1368_frequency_device *device,
    uint32_t line, const char *format, uint32_t has_index)
{
    const struct vn135_bm1368_drive_strength_diagnostic_135 diagnostic = {
        "driver", "/tmp/build/libbitmain/src/chip/chip1368.c", "[redacted]",
        format, line, 1, has_index, has_index ? device->index + UINT32_C(1) : 0
    };
    log->emit(log->context, &diagnostic);
}

int32_t vn135_bm1368_set_chain_drive_strength_135(
    struct vn135_bm1368_frequency_device *device, uint32_t setting,
    const struct vn135_bm1368_drive_strength_read_135 *read,
    const struct vn135_bm1368_register_ops *writer, void *write_context,
    const struct vn135_bm1368_drive_strength_log_135 *log)
{
    uint32_t value = 0;
    if (read->chain(read->context, drive_strength_signed_index_135(device->index),
            0x58, &value) != 0) {
        drive_strength_diagnostic_135(log, device, 635,
            "Failed to read cached driver strenght register", 0);
        return -1;
    }
    value = (value & UINT32_C(0xffff0fff)) | ((setting & 15u) << 12);
    if (vn135_bm1368_write_register_135(device, 1, NULL, 0x58, value,
            writer, write_context) == 0)
        return 0;
    drive_strength_diagnostic_135(log, device, 645,
        "chain#%d - failed to config drive strength", 1);
    return -1;
}

int32_t vn135_bm1368_set_chip_drive_strength_135(
    struct vn135_bm1368_frequency_device *device, const vn135_chip_reference *chip,
    uint32_t setting, const struct vn135_bm1368_drive_strength_read_135 *read,
    const struct vn135_bm1368_register_ops *writer, void *write_context,
    const struct vn135_bm1368_drive_strength_log_135 *log)
{
    uint32_t value = 0;
    if (read->chip(read->context, drive_strength_signed_index_135(device->index),
            chip->cache_index, 0x58, &value) != 0) {
        drive_strength_diagnostic_135(log, device, 609,
            "Failed to read cached drive strength register", 0);
        return -1;
    }
    value = (value & UINT32_C(0xffff0fff)) | ((setting & 15u) << 12);
    if (vn135_bm1368_write_register_135(device, 0, chip, 0x58, value,
            writer, write_context) == 0)
        return 0;
    drive_strength_diagnostic_135(log, device, 619,
        "chain#%d - failed to config drive strength", 1);
    return -1;
}
#endif
