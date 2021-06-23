#ifndef __SETJMP_H
#define __SETJMP_H

typedef char jmp_buf[4];
extern int _setjmp(jmp_buf __env);
#define setjmp(x) _setjmp(x)
extern void longjmp(jmp_buf __env, int __rv);

#endif
