"""Current-checkout pins for the two exact PR #102/#103 dependency transitions.

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
    else:
        require(git_blob(raw) == expected, 'old dependency changed: ' + path)
