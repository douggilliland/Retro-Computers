#ifndef TEXTBUFFER_H
#define TEXTBUFFER_H

void ClearTextBuffer();

int tb_printf(const char *fmt,...);
int tb_putchar(int c);
int tb_puts(const char *str);

#endif
