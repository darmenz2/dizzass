#!/usr/bin/env python3
"""Exact A-13 historical raw-diff predicate; no Git or firmware execution.

The workflow obtains the complete D/M/R/T raw diff from the unchanged historical
baseline. Keep the six prior accepted combinations and exact constructor group;
retain reset and ticket groups and add only the complete sweep compatibility group. No subset or path-only waiver.
"""
import sys

# Exact accepted thermal/transport/pulse records before the constructor addition.
PRIOR_RECORDS = (
    ':100644 100644 9c839aca1ebf0a1347fded59b631a30d960940a5 4ebf163af82be3cde11d5c7b3b65fce61d3409db M\t.github/workflows/bm1368-pulse-width-135.yml',
    ':100644 100644 aa0a043df461bfc7e15487d60ebf8a4dcd915b52 dcc8a6f2b1d8b0b981f461f1d4f99448bbf328e3 M\t.github/workflows/thermal-routes-135.yml',
    ':100644 100644 21c016abf12cd427c53704f52f213572f3178438 cce7d0abfa75e7343158f1dbd4dbc30b93cf8c64 M\tintegration/tests/check_bm1368_pulse_width_evidence_135.py',
    ':100644 100644 f68baf7a096b3b261e6249600b726eb120bebfbb 40d0fb336501875982f22ac6453ee4ddd58d8762 M\tintegration/thermal-routes-135.mk',
    ':100644 100644 f66d7c37b3d4e9f87ff892f35488db6140cb341c 0c0a6970e15c690af918aeeddbcc38fae5a06925 M\tlibbitmain/src/aml/platform.c',
    ':100644 100644 8ceb8405390e3eaf9f7b34480eb3cdd040a3b0ef d030308564c47bf409a3d381f16ddf262e6acf26 M\tlibbitmain/src/transport-dispatch.c',
)
PRIOR_MASKS = (0, 32, 26, 58, 37, 63)

# One coherent group: retained thermal/transport changes, unchanged pulse checker,
# exact constructor source, and exact frequency/register/pulse compatibility edits.
CONSTRUCTOR_RECORDS = (
    ':100644 100644 faba7b3e4ef7527f0b939c886897fcf8b5a7e334 d2c804b019f5ad0f69d223be613cd437f6d42623 M\t.github/workflows/bm1368-frequency-135.yml',
    ':100644 100644 9c839aca1ebf0a1347fded59b631a30d960940a5 ccc44d8e4ed85662b2df08c2a08f563e1802dbae M\t.github/workflows/bm1368-pulse-width-135.yml',
    ':100644 100644 2812317d6f54f5810c535d57a6c6fb15baed82cb facb570f83aea59e705b1fa3fd85c7b6c6e84f06 M\t.github/workflows/bm1368-register-write-135.yml',
    ':100644 100644 aa0a043df461bfc7e15487d60ebf8a4dcd915b52 dcc8a6f2b1d8b0b981f461f1d4f99448bbf328e3 M\t.github/workflows/thermal-routes-135.yml',
    ':100644 100644 b65756c6b4323f227e4b500c2d2db34500ff68bc eab6ba22853558d3d847eb1a27b3ee981aeeec99 M\tintegration/tests/check_bm1368_frequency_evidence_135.py',
    ':100644 100644 21c016abf12cd427c53704f52f213572f3178438 cce7d0abfa75e7343158f1dbd4dbc30b93cf8c64 M\tintegration/tests/check_bm1368_pulse_width_evidence_135.py',
    ':100644 100644 8b704f2ab26e23314f1bd66970d517095556a8e7 75a8088363e37cfff1d8ae47b7c1bdf1a0aaccae M\tintegration/tests/check_bm1368_register_write_evidence_135.py',
    ':100644 100644 f68baf7a096b3b261e6249600b726eb120bebfbb 40d0fb336501875982f22ac6453ee4ddd58d8762 M\tintegration/thermal-routes-135.mk',
    ':100644 100644 f66d7c37b3d4e9f87ff892f35488db6140cb341c 0c0a6970e15c690af918aeeddbcc38fae5a06925 M\tlibbitmain/src/aml/platform.c',
    ':100644 100644 c64374454e6e458ec1a175f21f03af141e29a3aa 0de837d281e81eb4503b4193b45ef076ec600b6e M\tlibbitmain/src/chip/chip1368.c',
    ':100644 100644 8ceb8405390e3eaf9f7b34480eb3cdd040a3b0ef d030308564c47bf409a3d381f16ddf262e6acf26 M\tlibbitmain/src/transport-dispatch.c',
)


# One complete current state; all seven earlier accepted states stay exact.
RESET_RECORDS = (
    ':100644 100644 faba7b3e4ef7527f0b939c886897fcf8b5a7e334 d2c804b019f5ad0f69d223be613cd437f6d42623 M\t.github/workflows/bm1368-frequency-135.yml',
    ':100644 100644 9c839aca1ebf0a1347fded59b631a30d960940a5 ccc44d8e4ed85662b2df08c2a08f563e1802dbae M\t.github/workflows/bm1368-pulse-width-135.yml',
    ':100644 100644 2812317d6f54f5810c535d57a6c6fb15baed82cb facb570f83aea59e705b1fa3fd85c7b6c6e84f06 M\t.github/workflows/bm1368-register-write-135.yml',
    ':100644 100644 aa0a043df461bfc7e15487d60ebf8a4dcd915b52 dcc8a6f2b1d8b0b981f461f1d4f99448bbf328e3 M\t.github/workflows/thermal-routes-135.yml',
    ':100644 100644 b65756c6b4323f227e4b500c2d2db34500ff68bc eab6ba22853558d3d847eb1a27b3ee981aeeec99 M\tintegration/tests/check_bm1368_frequency_evidence_135.py',
    ':100644 100644 21c016abf12cd427c53704f52f213572f3178438 cce7d0abfa75e7343158f1dbd4dbc30b93cf8c64 M\tintegration/tests/check_bm1368_pulse_width_evidence_135.py',
    ':100644 100644 8b704f2ab26e23314f1bd66970d517095556a8e7 75a8088363e37cfff1d8ae47b7c1bdf1a0aaccae M\tintegration/tests/check_bm1368_register_write_evidence_135.py',
    ':100644 100644 f68baf7a096b3b261e6249600b726eb120bebfbb 40d0fb336501875982f22ac6453ee4ddd58d8762 M\tintegration/thermal-routes-135.mk',
    ':100644 100644 f66d7c37b3d4e9f87ff892f35488db6140cb341c 0c0a6970e15c690af918aeeddbcc38fae5a06925 M\tlibbitmain/src/aml/platform.c',
    ':100644 100644 c64374454e6e458ec1a175f21f03af141e29a3aa e024519eda8df9c1c85697548e8e0629f7c0f5cf M\tlibbitmain/src/chip/chip1368.c',
    ':100644 100644 8ceb8405390e3eaf9f7b34480eb3cdd040a3b0ef d030308564c47bf409a3d381f16ddf262e6acf26 M\tlibbitmain/src/transport-dispatch.c',
)


# One complete ticket state; all eight earlier states remain exact witnesses.
TICKET_RECORDS = (
    ':100644 100644 faba7b3e4ef7527f0b939c886897fcf8b5a7e334 d2c804b019f5ad0f69d223be613cd437f6d42623 M\t.github/workflows/bm1368-frequency-135.yml',
    ':100644 100644 9c839aca1ebf0a1347fded59b631a30d960940a5 ccc44d8e4ed85662b2df08c2a08f563e1802dbae M\t.github/workflows/bm1368-pulse-width-135.yml',
    ':100644 100644 2812317d6f54f5810c535d57a6c6fb15baed82cb facb570f83aea59e705b1fa3fd85c7b6c6e84f06 M\t.github/workflows/bm1368-register-write-135.yml',
    ':100644 100644 aa0a043df461bfc7e15487d60ebf8a4dcd915b52 dcc8a6f2b1d8b0b981f461f1d4f99448bbf328e3 M\t.github/workflows/thermal-routes-135.yml',
    ':100644 100644 b65756c6b4323f227e4b500c2d2db34500ff68bc eab6ba22853558d3d847eb1a27b3ee981aeeec99 M\tintegration/tests/check_bm1368_frequency_evidence_135.py',
    ':100644 100644 21c016abf12cd427c53704f52f213572f3178438 cce7d0abfa75e7343158f1dbd4dbc30b93cf8c64 M\tintegration/tests/check_bm1368_pulse_width_evidence_135.py',
    ':100644 100644 8b704f2ab26e23314f1bd66970d517095556a8e7 75a8088363e37cfff1d8ae47b7c1bdf1a0aaccae M\tintegration/tests/check_bm1368_register_write_evidence_135.py',
    ':100644 100644 f68baf7a096b3b261e6249600b726eb120bebfbb 40d0fb336501875982f22ac6453ee4ddd58d8762 M\tintegration/thermal-routes-135.mk',
    ':100644 100644 f66d7c37b3d4e9f87ff892f35488db6140cb341c 0c0a6970e15c690af918aeeddbcc38fae5a06925 M\tlibbitmain/src/aml/platform.c',
    ':100644 100644 c64374454e6e458ec1a175f21f03af141e29a3aa 1cd2c6e7612b494c28f0bbbab0e62434d104881d M\tlibbitmain/src/chip/chip1368.c',
    ':100644 100644 8ceb8405390e3eaf9f7b34480eb3cdd040a3b0ef d030308564c47bf409a3d381f16ddf262e6acf26 M\tlibbitmain/src/transport-dispatch.c',
)


# One complete sweep state; all nine earlier states remain exact witnesses.
SWEEP_RECORDS = (
    ':100644 100644 faba7b3e4ef7527f0b939c886897fcf8b5a7e334 d2c804b019f5ad0f69d223be613cd437f6d42623 M\t.github/workflows/bm1368-frequency-135.yml',
    ':100644 100644 9c839aca1ebf0a1347fded59b631a30d960940a5 ccc44d8e4ed85662b2df08c2a08f563e1802dbae M\t.github/workflows/bm1368-pulse-width-135.yml',
    ':100644 100644 2812317d6f54f5810c535d57a6c6fb15baed82cb facb570f83aea59e705b1fa3fd85c7b6c6e84f06 M\t.github/workflows/bm1368-register-write-135.yml',
    ':100644 100644 aa0a043df461bfc7e15487d60ebf8a4dcd915b52 dcc8a6f2b1d8b0b981f461f1d4f99448bbf328e3 M\t.github/workflows/thermal-routes-135.yml',
    ':100644 100644 b65756c6b4323f227e4b500c2d2db34500ff68bc eab6ba22853558d3d847eb1a27b3ee981aeeec99 M\tintegration/tests/check_bm1368_frequency_evidence_135.py',
    ':100644 100644 21c016abf12cd427c53704f52f213572f3178438 cce7d0abfa75e7343158f1dbd4dbc30b93cf8c64 M\tintegration/tests/check_bm1368_pulse_width_evidence_135.py',
    ':100644 100644 8b704f2ab26e23314f1bd66970d517095556a8e7 75a8088363e37cfff1d8ae47b7c1bdf1a0aaccae M\tintegration/tests/check_bm1368_register_write_evidence_135.py',
    ':100644 100644 f68baf7a096b3b261e6249600b726eb120bebfbb 40d0fb336501875982f22ac6453ee4ddd58d8762 M\tintegration/thermal-routes-135.mk',
    ':100644 100644 f66d7c37b3d4e9f87ff892f35488db6140cb341c 0c0a6970e15c690af918aeeddbcc38fae5a06925 M\tlibbitmain/src/aml/platform.c',
    ':100644 100644 c64374454e6e458ec1a175f21f03af141e29a3aa f23565c15c9d174e644fc51a401e81dbe072dfd7 M\tlibbitmain/src/chip/chip1368.c',
    ':100644 100644 8ceb8405390e3eaf9f7b34480eb3cdd040a3b0ef d030308564c47bf409a3d381f16ddf262e6acf26 M\tlibbitmain/src/transport-dispatch.c',
)


def approved_changes():
    prior = tuple('\n'.join(record for index, record in enumerate(PRIOR_RECORDS)
                           if mask & (1 << index)) for mask in PRIOR_MASKS)
    return prior + ('\n'.join(CONSTRUCTOR_RECORDS), '\n'.join(RESET_RECORDS),
                    '\n'.join(TICKET_RECORDS), '\n'.join(SWEEP_RECORDS))


def check_historical_changes(raw):
    """Accept exact command-substitution output, including modes and blob IDs."""
    if not isinstance(raw, str) or raw not in approved_changes():
        raise ValueError('Unexpected historical source changes:\n' + str(raw))


def main():
    if len(sys.argv) != 2:
        raise SystemExit('usage: check_uart_posix_historical_135.py RAW_DIFF')
    try:
        check_historical_changes(sys.argv[1])
    except ValueError as error:
        raise SystemExit(str(error)) from error
    print('UART_POSIX_HISTORICAL135_PASS')


if __name__ == '__main__':
    main()
