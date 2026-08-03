#ifndef HARDWARESPOOF_H
#define HARDWARESPOOF_H

#include <CoreFoundation/CoreFoundation.h>
#include <unistd.h>

const char *spoofedSerialNumber(void);
const char *spoofedUDID(void);
const char *spoofedChipID(void);
const char *spoofedWiFiAddress(void);
const char *spoofedBluetoothAddress(void);

#endif