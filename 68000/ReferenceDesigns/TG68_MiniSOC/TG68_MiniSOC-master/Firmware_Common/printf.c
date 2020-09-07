#include <stdio.h>
#include <stdarg.h>

char buf[256];

int printf(const char *fmt,...)
{
	va_list ap;
	va_start(ap, fmt);
	int num = vsnprintf(buf, 256, fmt, ap);
	va_end(ap);
	puts(buf);
	
	return num;
}

