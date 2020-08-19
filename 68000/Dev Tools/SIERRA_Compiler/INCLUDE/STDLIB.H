/*--------------------------------- stdlib.h --------------------------------*/

/*
 *  Copyright 1987, 1992 by Sierra Systems.  All rights reserved.
 */

#ifndef _SIZE_T
#define _SIZE_T
typedef unsigned long size_t;	/* type returned by sizeof operator	   */
#endif

#ifndef _WCHAR_T
#define _WCHAR_T
typedef unsigned char wchar_t;	/* type that fits widest defined character */
#endif

#define NULL (void *)0

typedef struct {
    int quot;
    int rem;
} div_t;

typedef struct {
    long quot;
    long rem;
} ldiv_t;

#define EXIT_SUCCESS	0
#define	EXIT_FAILURE	1
#define	RAND_MAX	32767

double atof(const char *str);
int atoi(const char *str);
long atol(const char *str);
double strtod(const char *str, char **end_ptr);
long strtol(const char *str, char **end_ptr, int base);
unsigned long strtoul(const char *str, char **end_ptr, int base);
int rand(void);
void srand(unsigned int seed);
void *calloc(size_t nbr_elements, size_t size);
void free(void *ptr);
void *malloc(size_t size);
void *realloc(void *ptr, size_t size);
void abort(void);
int atexit(void (*func)(void));
void exit(int status);
char *getenv(const char *name);
int system(const char *str);
int abs(int value);
div_t div(int numerator, int denominator);
long labs(long value);
ldiv_t ldiv(long numerator, long denominator);
void *bsearch(const void *key, const void *base, size_t nbr_members,
	      size_t size, int (*compare)(const void *, const void *));
void qsort(void *base, size_t nbr_members, size_t size,
	   int (*compare)(const void *, const void *));

#if 1
float strtodf(const char *str, char **end_ptr);
float strtodff(const char *str, char **end_ptr);
float atoff(const char *str);
float atofff(const char *str);
#endif
