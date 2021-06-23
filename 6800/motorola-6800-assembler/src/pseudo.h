/*
 *      pseudo --- pseudo op processing
 */

#ifndef _PSEUDO_H_
#define _PSEUDO_H_

extern struct oper pseudo[];

int sizeof_pseudo(void);
void do_pseudo(int op /* which op */);

#endif // _PSEUDO_H_

