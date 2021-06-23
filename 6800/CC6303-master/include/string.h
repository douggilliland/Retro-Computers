#ifndef __STRING_H
#define __STRING_H

#include <types.h>
#include <stddef.h>

/* Only a small subset so far */

extern char *strcat(char *__dest, const char *__src);
extern char *strcpy(char *__dest, const char *__src);
extern int strcmp(const char *__s1, const char *__s2);
extern int strncmp(const char *__s1, const char *__s2);
extern char *strchr(const char *__s, int __c);
extern char *strrchr(const char *__s, int __c);
extern size_t strlen(const char *__s);
extern size_t strnlen(const char *__s, size_t n);

extern void *memcpy(void *__dest, const void *__src, size_t __n);
extern void *memset(void *__s, int __c, size_t __n);
extern char *strchr(const char *__s, int __c, size_t __n);
extern char *strrchr(const char *__s, int __c, size_t __n);

#endif
