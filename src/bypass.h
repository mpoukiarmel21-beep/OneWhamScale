/* bypass.h - C module init declarations for C++ callers */
#ifndef BYPASS_H
#define BYPASS_H

#ifdef __cplusplus
extern "C" {
#endif

void filebypass_init(void);
void spawnbypass_init(void);
void dylibbypass_init(void);
void sysctlbypass_init(void);
void mgspoof_init(void);

#ifdef __cplusplus
}
#endif

#endif