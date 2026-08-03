#ifndef UTILITY_H
#define UTILITY_H

#include <sys/stat.h>
#include <dirent.h>
#include <stdio.h>
#include <stdbool.h>
#include <string.h>
#include <unistd.h>

bool isKnownBadPath(const char *path);
bool isKnownSpawnPath(const char *path);
bool isKnownDylib(const char *path);
bool isKnownJailbreakApp(const char *path);
bool isRestrictedSystemPath(const char *path);

#endif