"""Current-checkout pins for exact reviewed dependency transitions.

Historical evidence JSON remains byte-identical. See
integration/CURRENT_DEPENDENCY_PINS_135.md for the old/new witnesses.
"""
import hashlib
from pathlib import Path, PurePosixPath
import stat

THERMAL_PATH = 'integration/thermal-routes-135.mk'
THERMAL_OLD_BLOB = 'f68baf7a096b3b261e6249600b726eb120bebfbb'
THERMAL_CURRENT_BLOB = '40d0fb336501875982f22ac6453ee4ddd58d8762'
OLD_FLAGS_PREFIX = b'\nROUTES135_FLAGS = -I. -std=c11 '
CURRENT_FLAGS_PREFIX = b'\nROUTES135_FLAGS = -I. -Iinclude -std=c11 '
DISPATCH_PATH = 'libbitmain/src/transport-dispatch.c'
DISPATCH_OLD_BLOB = '8ceb8405390e3eaf9f7b34480eb3cdd040a3b0ef'
DISPATCH_CURRENT_BLOB = 'd030308564c47bf409a3d381f16ddf262e6acf26'
DISPATCH_OLD_SIZE = 2305
BM1368_PATH = 'libbitmain/src/chip/chip1368.c'
BM1368_OLD_BLOB = 'c64374454e6e458ec1a175f21f03af141e29a3aa'
BM1368_OLD_SIZE = 920
BM1368_CONSTRUCTOR_BLOB = '0de837d281e81eb4503b4193b45ef076ec600b6e'
BM1368_CONSTRUCTOR_SHA256 = 'b0d68763aa141ffa25e4df3b70e6e55a444cd59f44db405f51b9a80aea6a7a2a'
BM1368_CONSTRUCTOR_SIZE = 3803
BM1368_RESET_BLOB = 'e024519eda8df9c1c85697548e8e0629f7c0f5cf'
BM1368_RESET_SHA256 = 'e3c8cecb8869c59847db357d26541e95123fa1cb4cf2ef04642a62c2e1e0738d'
BM1368_RESET_SIZE = 7519
BM1368_CURRENT_BLOB = '1cd2c6e7612b494c28f0bbbab0e62434d104881d'
BM1368_CURRENT_SHA256 = 'ed818babcb847fb38094af8f08ae3c0ac6ef690192aa1e6030c3f8326e9968d9'
BM1368_CURRENT_SIZE = 8350


def require(ok, message):
    # Explicit exceptions retain every check under python -O.
    if not ok:
        raise ValueError(message)


def git_blob(data):
    return hashlib.sha1(b'blob ' + str(len(data)).encode() + b'\0' + data).hexdigest()


def historical_thermal_bytes(current):
    """Validate the exact new blob and reconstruct the exact old witness.

    This is not historical-checkout acceptance: callers must supply PR #102's
    current blob, and the old blob itself is rejected.
    """
    require(git_blob(current) == THERMAL_CURRENT_BLOB,
            'thermal makefile is not the reviewed PR #102 blob')
    require(current.count(CURRENT_FLAGS_PREFIX) == 1,
            'thermal ROUTES135_FLAGS transition is not unique')
    old = current.replace(CURRENT_FLAGS_PREFIX, OLD_FLAGS_PREFIX, 1)
    require(git_blob(old) == THERMAL_OLD_BLOB,
            'thermal transition does not reconstruct the historical witness')
    return old


def historical_dispatch_bytes(current):
    """Validate PR #103's exact gated append and its byte-identical old prefix."""
    require(git_blob(current) == DISPATCH_CURRENT_BLOB,
            'transport dispatch is not the reviewed PR #103 blob')
    old, added = current[:DISPATCH_OLD_SIZE], current[DISPATCH_OLD_SIZE:]
    require(git_blob(old) == DISPATCH_OLD_BLOB,
            'transport dispatch historical prefix changed')
    require(added.count(b'\n#ifdef VN135_TRANSPORT_INITIALIZE_135\n') == 1
            and added.count(b'#if') == 1 and added.count(b'#endif') == 1
            and added.endswith(b'\n#endif\n'),
            'transport initialization append is not separately gated')
    return old


def reset_bm1368_bytes(current):
    """Validate the exact ticket append and recover the unchanged L10 source."""
    require(len(current) == BM1368_CURRENT_SIZE
            and hashlib.sha256(current).hexdigest() == BM1368_CURRENT_SHA256
            and git_blob(current) == BM1368_CURRENT_BLOB,
            'BM1368 chip source is not the reviewed ticket-mask blob')
    reset, added = current[:BM1368_RESET_SIZE], current[BM1368_RESET_SIZE:]
    require(len(reset) == BM1368_RESET_SIZE
            and hashlib.sha256(reset).hexdigest() == BM1368_RESET_SHA256
            and git_blob(reset) == BM1368_RESET_BLOB,
            'BM1368 preserved reset source prefix changed')
    require(added.startswith(b'\n#ifdef VN135_BM1368_TICKET_MASK_135\n'
                             b'#include "integration/bm1368_ticket_mask_135.h"\n')
            and added.count(b'#if') == 1 and added.count(b'#endif') == 1
            and added.count(b'#include') == 1
            and b'#else' not in added and b'#elif' not in added
            and added.endswith(b'\n#endif\n'),
            'BM1368 ticket-mask append is not separately gated')
    return reset


def constructor_bm1368_bytes(current):
    """Validate ticket and reset layers, then recover the constructor witness."""
    current = reset_bm1368_bytes(current)
    require(len(current) == BM1368_RESET_SIZE
            and hashlib.sha256(current).hexdigest() == BM1368_RESET_SHA256
            and git_blob(current) == BM1368_RESET_BLOB,
            'BM1368 chip source is not the reviewed reset blob')
    constructor, added = (current[:BM1368_CONSTRUCTOR_SIZE],
                          current[BM1368_CONSTRUCTOR_SIZE:])
    require(git_blob(constructor) == BM1368_CONSTRUCTOR_BLOB
            and hashlib.sha256(constructor).hexdigest() == BM1368_CONSTRUCTOR_SHA256,
            'BM1368 constructor source prefix changed')
    require(added.startswith(b'\n#ifdef VN135_BM1368_RESET_135\n'
                             b'#include "integration/bm1368_reset_135.h"\n')
            and added.count(b'#if') == 1 and added.count(b'#endif') == 1
            and added.count(b'#include') == 1
            and b'#else' not in added and b'#elif' not in added
            and added.endswith(b'\n#endif\n'),
            'BM1368 reset append is not separately gated')
    return constructor


def historical_bm1368_bytes(current):
    """Validate all three exact appends and recover the unchanged nonce witness."""
    constructor = constructor_bm1368_bytes(current)
    old, added = constructor[:BM1368_OLD_SIZE], constructor[BM1368_OLD_SIZE:]
    require(git_blob(old) == BM1368_OLD_BLOB,
            'BM1368 chip historical prefix changed')
    require(added.startswith(b'\n#ifdef VN135_BM1368_INITIALIZE_135\n')
            and added.count(b'\n#ifdef VN135_BM1368_INITIALIZE_135\n') == 1
            and added.count(b'#if') == 1 and added.count(b'#endif') == 1
            and added.endswith(b'\n#endif\n'),
            'BM1368 constructor append is not separately gated')
    return old


def check_current_dependency(root, path, expected):
    """Enforce an existing pin, allowing only the precisely reviewed transition."""
    require(isinstance(path, str) and path != ''
            and not PurePosixPath(path).is_absolute()
            and all(part not in ('', '.', '..') for part in path.split('/')),
            'dependency path must be canonical and repository-relative')
    target = Path(root)
    parts = path.split('/')
    for index, part in enumerate(parts):
        target = target / part
        mode = target.lstat().st_mode  # Missing files fail; never follow symlinks.
        if index < len(parts) - 1:
            require(stat.S_ISDIR(mode), 'dependency parent is not a directory: ' + path)
        else:
            require(stat.S_ISREG(mode) and not mode & 0o111,
                    'dependency must be a non-executable regular file: ' + path)
    raw = target.read_bytes()
    if path == THERMAL_PATH:
        require(expected == THERMAL_OLD_BLOB, 'historical thermal pin changed')
        historical_thermal_bytes(raw)
    elif path == DISPATCH_PATH:
        require(expected == DISPATCH_OLD_BLOB, 'historical transport dispatch pin changed')
        historical_dispatch_bytes(raw)
    elif path == BM1368_PATH:
        require(expected == BM1368_OLD_BLOB, 'historical BM1368 chip pin changed')
        historical_bm1368_bytes(raw)
    else:
        require(git_blob(raw) == expected, 'old dependency changed: ' + path)
