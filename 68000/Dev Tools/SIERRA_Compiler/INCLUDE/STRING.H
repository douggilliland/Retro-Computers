/*--------------------------------- string.h --------------------------------*/

/*
 *  Copyright 1987, 1992 by Sierra Systems.  All rights reserved.
 */

#ifndef _SIZE_T
#define _SIZE_T
typedef unsigned long size_t;	/* type returned by sizeof operator	   */
#endif

#define NULL (void *)0

void* memcpy(void *s1, const void *s2, size_t count);
void *memmove(void *s1, const void *s2, size_t count);
char* strcpy(char *s1, const char *s2);
char* strncpy(char *s1, const char *s2, size_t count);
char *strcat(char *s1, const char *s2);
char *strncat(char *s1, const char *s2, size_t count);
int memcmp(const void *s1, const void *s2, size_t count);
int strcmp(const char *s1, const char *s2);
int strncmp(const char *s1, const char *s2, size_t count);
void *memchr(const void *str, int c, size_t count);
char *strchr(const char *str, int c);
size_t strcspn(const char *s1, const char *s2);
char *strpbrk(const char *s1, const char *s2);
char *strrchr(const char *str, int c);
size_t strspn(const char *s1, const char *s2);
char* strstr(const char *s1, const char *s2);
char* strtok(char *s1, const char *s2);
void *_memset(void *str, int c, size_t count);
void *memset(void *str, int c, size_t count);
char *strerror(int error_nbr);
size_t strlen(const char *str);
