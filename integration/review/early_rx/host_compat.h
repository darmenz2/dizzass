/* Test-only forward declaration when ANTS2 does not include USB headers. */
#include "config.h"
#ifndef USE_USBUTILS
typedef struct libusb_context libusb_context;
#endif
