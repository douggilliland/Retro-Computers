#ifndef SMALL_PRINTF_H
#define SMALL_PRINTF_H

#ifdef DISABLE_PRINTF
#define small_printf(x,...)
#define printf(x,...)
#define puts(x)
#else
int small_printf(const char *fmt, ...);
#define printf small_printf
#endif

#endif

