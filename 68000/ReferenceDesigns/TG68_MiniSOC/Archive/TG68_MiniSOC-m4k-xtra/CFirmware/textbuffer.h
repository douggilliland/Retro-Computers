#ifndef TEXTBUFFER_H
#define TEXTBUFFER_H

void ClearTextBuffer();

int printf(const char *fmt,...);
#undef putchar
int putchar(int c);
int puts(const char *str);

#endif
