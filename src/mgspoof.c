/* ============================================================
 * mgspoof.c - MobileGestalt hardware ID spoofing (Substrate)
 * ============================================================ */

#include <substrate.h>
#include <CoreFoundation/CoreFoundation.h>
#include <dlfcn.h>
#include "hardwarespoof.h"

static CFTypeRef (*orig_MGCopyAnswer)(CFStringRef key);

static CFTypeRef hook_MGCopyAnswer(CFStringRef key) {
    if (key != NULL) {
        if (CFStringCompare(key, CFSTR("SerialNumber"), kCFCompareCaseInsensitive) == kCFCompareEqualTo) {
            return CFStringCreateWithCString(NULL, spoofedSerialNumber(), kCFStringEncodingUTF8);
        }
        if (CFStringCompare(key, CFSTR("UniqueDeviceID"), kCFCompareCaseInsensitive) == kCFCompareEqualTo) {
            return CFStringCreateWithCString(NULL, spoofedUDID(), kCFStringEncodingUTF8);
        }
        if (CFStringCompare(key, CFSTR("UniqueChipID"), kCFCompareCaseInsensitive) == kCFCompareEqualTo) {
            return CFStringCreateWithCString(NULL, spoofedChipID(), kCFStringEncodingUTF8);
        }
        if (CFStringCompare(key, CFSTR("MLBSerialNumber"), kCFCompareCaseInsensitive) == kCFCompareEqualTo) {
            return CFStringCreateWithCString(NULL, spoofedSerialNumber(), kCFStringEncodingUTF8);
        }
        if (CFStringCompare(key, CFSTR("WifiAddress"), kCFCompareCaseInsensitive) == kCFCompareEqualTo) {
            return CFStringCreateWithCString(NULL, spoofedWiFiAddress(), kCFStringEncodingUTF8);
        }
        if (CFStringCompare(key, CFSTR("BluetoothAddress"), kCFCompareCaseInsensitive) == kCFCompareEqualTo) {
            return CFStringCreateWithCString(NULL, spoofedBluetoothAddress(), kCFStringEncodingUTF8);
        }
        if (CFStringCompare(key, CFSTR("UserAssignedDeviceName"), kCFCompareCaseInsensitive) == kCFCompareEqualTo) {
            return CFSTR("iPhone");
        }
    }
    return orig_MGCopyAnswer(key);
}

void mgspoof_init(void) {
    void *mg = dlsym(RTLD_DEFAULT, "MGCopyAnswer");
    if (mg) {
        MSHookFunction(mg, (void *)hook_MGCopyAnswer, (void **)&orig_MGCopyAnswer);
    }
}