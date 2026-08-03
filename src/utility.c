#include "utility.h"

/* ============================================================
   Comprehensive jailbreak path database
   Covers: unc0ver, checkra1n, palera1n, Dopamine, XinaA15,
   rootful, rootless (/var/jb), Sileo, Zebra, Substitute, ElleKit
   ============================================================ */

static const char *statPaths[] = {
    /* Rootful jailbreak markers */
    "/.bootstrapped_electra",
    "/.installed_unc0ver",
    "/.jbroot",
    "/.palera1n",

    /* Applications */
    "/Applications/Cydia.app",
    "/Applications/Sileo.app",
    "/Applications/Zebra.app",
    "/Applications/Filza.app",
    "/Applications/FakeCarrier.app",
    "/Applications/Icy.app",
    "/Applications/IntelliScreen.app",
    "/Applications/Loader.app",
    "/Applications/MxTube.app",
    "/Applications/RockApp.app",
    "/Applications/SBSettings.app",
    "/Applications/WinterBoard.app",
    "/Applications/blackra1n.app",
    "/Applications/checkra1n.app",
    "/Applications/Dopamine.app",
    "/Applications/Palera1n.app",
    "/Applications/TrollStore.app",
    "/Applications/Snoop-itConfig.app",
    "/Applications/TrustMe.app",
    "/Applications/iCleaner.app",
    "/Applications/AppAdmin.app",
    "/Applications/AppCake.app",
    "/Applications/CrackTool.app",
    "/Applications/GBA4iOS.app",
    "/Applications/iFile.app",
    "/Applications/Installous.app",
    "/Applications/intelliscreenx.app",
    "/Applications/LocationFaker.app",
    "/Applications/SysSecInfo.app",

    /* MobileSubstrate */
    "/Library/MobileSubstrate",
    "/Library/MobileSubstrate/MobileSubstrate.dylib",
    "/Library/MobileSubstrate/DynamicLibraries",
    "/Library/MobileSubstrate/CydiaSubstrate.dylib",

    /* LaunchDaemons */
    "/Library/LaunchDaemons/com.openssh.sshd.plist",
    "/Library/LaunchDaemons/com.saurik.Cydia.Startup.plist",
    "/Library/LaunchDaemons/com.ikey.bbot.plist",

    /* Binaries */
    "/bin/bash",
    "/bin/sh",
    "/bin/mv",
    "/bin/apt",

    /* Etc */
    "/etc/apt",
    "/etc/ssh/sshd_config",

    /* Rootless /var/jb (palera1n, Dopamine, etc.) */
    "/var/jb",
    "/var/jb/Applications",
    "/var/jb/usr",
    "/var/jb/etc",
    "/var/jb/Library",
    "/var/jb/bin",
    "/var/jb/basebin",
    "/var/jb/preboot",
    "/var/jb/var",

    /* Rootful /var */
    "/var/binpack",
    "/var/binpack/Applications",
    "/var/binpack/usr",
    "/var/cache/apt",
    "/var/checkra1n.dmg",
    "/var/lib/apt",
    "/var/lib/cydia",
    "/var/lib/dpkg/info/mobilesubstrate.md5sums",
    "/var/lib/undecimus",
    "/var/log/apt",
    "/var/log/syslog",
    "/var/tmp/cydia.log",
    "/var/containers/Bundle/tweaksupport",
    "/var/containers/Bundle/Application/trollstorehelper",
    "/var/containers/Bundle/trollstore",
    "/var/mobile/Library/palera1n",
    "/var/mobile/Library/xyz.willy.Zebra",

    /* Private paths */
    "/private/var/lib/apt",
    "/private/var/lib/cydia",
    "/private/var/mobile/Library/SBSettings/Themes",
    "/private/var/stash",
    "/private/var/tmp/cydia.log",
    "/private/var/root",
    "/private/var/Users",
    "/private/etc/apt",
    "/private/etc/dpkg/origins/debian",
    "/private/etc/ssh/sshd_config",
    "/private/var/cache/apt",
    "/private/var/log/syslog",

    /* Usr paths */
    "/usr/bin/cycript",
    "/usr/bin/ssh",
    "/usr/bin/sshd",
    "/usr/lib/apt",
    "/usr/lib/libapt-inst.dylib",
    "/usr/lib/libcycript.dylib",
    "/usr/lib/tweakloader.dylib",
    "/usr/lib/substrate",
    "/usr/lib/TweakInject",
    "/usr/lib/libhooker.dylib",
    "/usr/lib/libsubstitute.dylib",
    "/usr/lib/libjailbreak.dylib",
    "/usr/lib/libellekit.dylib",
    "/usr/libexec/cydia",
    "/usr/libexec/sftp-server",
    "/usr/libexec/ssh-keysign",
    "/usr/local/bin/cycript",
    "/usr/sbin/frida-server",
    "/usr/sbin/sshd",
    "/usr/share/jailbreak",

    /* Additional */
    "/jb",
    "/jb/amfid_payload.dylib",
    "/jb/jailbreakd.plist",
    "/jb/libjailbreak.dylib",
    "/jb/lzma",
    "/jb/offsets.plist",

    NULL
};

static const char *spawnPaths[] = {
    "/bin/df",
    "/bin/ps",
    "/usr/bin/taskinfo",
    "/usr/bin/vm_stat",
    "/usr/bin/ipconfig",
    "/usr/sbin/syslogd",
    "/usr/sbin/mDNSResponder",
    "/usr/bin/vm_stat",
    "/usr/bin/top",
    "/usr/bin/apt-get",
    "/usr/bin/dpkg",
    "/usr/bin/cycript",
    NULL
};

static const char *dylibList[] = {
    "SubstrateLoader",
    "MobileSubstrate",
    "CydiaSubstrate",
    "libhooker",
    "libsubstitute",
    "libellekit",
    "libjailbreak",
    "SubstrateBootstrap",
    "RocketBootstrap",
    "AppList",
    "PreferenceLoader",
    "tweakloader",
    "SSLKillSwitch",
    "SSLKillSwitch2",
    "MobileSafety",
    "cynject",
    "libcycript",
    "libsubstrate",
    "libapt-inst",
    "libcycrypt",
    "patcyh",
    "substrate",
    "FridaGadget",
    "frida",
    "Shadow",
    "ABypass",
    "Liberty",
    "Hestia",
    "iHide",
    "FlyJB",
    "A-Bypass",
    "KernBypass",
    "vnodebypass",
    NULL
};

/* ==================== FUNCTIONS ==================== */

bool isKnownBadPath(const char *path) {
    if (!path) return false;

    for (int i = 0; statPaths[i] != NULL; i++) {
        if (strcmp(path, statPaths[i]) == 0) {
            return true;
        }
    }

    /* /var/jb prefix (rootless jailbreaks) */
    if (strncmp(path, "/var/jb/", 8) == 0) return true;

    /* .cydia_no_stash */
    if (strstr(path, ".cydia_no_stash") != NULL) return true;

    /* DynamicLibraries + .plist */
    if (strstr(path, "DynamicLibraries") != NULL && strstr(path, ".plist") != NULL) return true;

    /* Additional rootless */
    if (strstr(path, "/var/jb") != NULL) return true;

    return false;
}

bool isKnownSpawnPath(const char *path) {
    if (!path) return false;

    for (int i = 0; spawnPaths[i] != NULL; i++) {
        if (strcmp(path, spawnPaths[i]) == 0) return true;
    }

    const char *base = strrchr(path, '/');
    if (base) base++;
    else base = path;

    if (strcmp(base, "ssh") == 0) return true;
    if (strcmp(base, "sshd") == 0) return true;
    if (strcmp(base, "dpkg") == 0) return true;
    if (strcmp(base, "apt-get") == 0) return true;
    if (strcmp(base, "cycript") == 0) return true;

    return false;
}

bool isKnownDylib(const char *path) {
    if (!path) return false;

    for (int i = 0; dylibList[i] != NULL; i++) {
        if (strstr(path, dylibList[i]) != NULL) return true;
    }

    if (strstr(path, "/Library/MobileSubstrate/") != NULL) return true;
    if (strstr(path, "/var/jb/") != NULL && strstr(path, ".dylib") != NULL) return true;
    if (strstr(path, "TweakInject") != NULL) return true;
    if (strstr(path, "/usr/lib/") != NULL && strstr(path, "hooker") != NULL) return true;

    return false;
}

bool isKnownJailbreakApp(const char *path) {
    if (!path) return false;

    static const char *jbApps[] = {
        "Cydia", "Sileo", "Zebra", "Filza", "NewTerm",
        "iTerminal", "MTerminal", "checkra1n", "Palera1n",
        "Dopamine", "unc0ver", "TrollStore", "Installer",
        "iCleaner", "FilzaFileManager", NULL
    };

    for (int i = 0; jbApps[i] != NULL; i++) {
        if (strstr(path, jbApps[i]) != NULL) return true;
    }

    return false;
}

bool isRestrictedSystemPath(const char *path) {
    if (!path) return false;

    if (strncmp(path, "/private/", 9) == 0) return true;
    if (strncmp(path, "/System/", 8) == 0) return true;
    if (strncmp(path, "/etc/", 5) == 0) return true;
    if (strncmp(path, "/usr/", 5) == 0) return true;
    if (strncmp(path, "/bin/", 5) == 0) return true;
    if (strncmp(path, "/sbin/", 6) == 0) return true;
    if (strncmp(path, "/var/", 6) == 0) return true;
    if (strncmp(path, "/var/jb", 7) == 0) return true;
    if (strncmp(path, "/jb", 3) == 0) return true;

    return false;
}