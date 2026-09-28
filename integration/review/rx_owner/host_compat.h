/* Host test's abort-wrapper declaration only; not a USB implementation. */
#include "config.h"
#ifndef USE_USBUTILS
typedef struct libusb_context libusb_context;
#endif
