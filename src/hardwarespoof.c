/* ============================================================
   hardwarespoof.c - MobileGestalt hardware ID spoofing
   Spoofs: SerialNumber, UniqueDeviceID, UniqueChipID, MLBSerialNumber,
   WifiAddress, BluetoothAddress
   Used against: Hily (deep MG), Tinder, Bumble
   ============================================================ */

#include "hardwarespoof.h"
#include <stdlib.h>
#include <string.h>
#include <time.h>

static const char *generateSerial(void) {
    static char serial[16];
    if (serial[0] != '\0') return serial;
    const char *chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    srand((unsigned int)time(NULL) ^ (unsigned int)getpid());
    serial[0] = 'C'; serial[1] = '0';
    for (int i = 2; i < 11; i++) serial[i] = chars[rand() % 36];
    serial[11] = '\0';
    return serial;
}

static const char *generateUDID(void) {
    static char udid[41];
    if (udid[0] != '\0') return udid;
    const char *hex = "0123456789abcdef";
    srand((unsigned int)time(NULL) ^ (unsigned int)getpid());
    for (int i = 0; i < 40; i++) udid[i] = hex[rand() % 16];
    udid[40] = '\0';
    return udid;
}

static const char *generateChipID(void) {
    static char chip[20];
    if (chip[0] != '\0') return chip;
    srand((unsigned int)time(NULL) ^ (unsigned int)getpid());
    snprintf(chip, sizeof(chip), "%u", (unsigned int)(rand() % 100000000 + 800000000));
    return chip;
}

static const char *generateMAC(const char *prefix) {
    static char mac[18];
    if (mac[0] != '\0') return mac;
    const char *hex = "0123456789abcdef";
    srand((unsigned int)time(NULL) ^ (unsigned int)getpid());
    snprintf(mac, sizeof(mac), "%s:%c%c:%c%c:%c%c",
        prefix,
        hex[rand() % 16], hex[rand() % 16],
        hex[rand() % 16], hex[rand() % 16],
        hex[rand() % 16], hex[rand() % 16]);
    return mac;
}

const char *spoofedSerialNumber(void) { return generateSerial(); }
const char *spoofedUDID(void) { return generateUDID(); }
const char *spoofedChipID(void) { return generateChipID(); }
const char *spoofedWiFiAddress(void) { return generateMAC("ac:bc:32"); }
const char *spoofedBluetoothAddress(void) { return generateMAC("ac:bc:32"); }