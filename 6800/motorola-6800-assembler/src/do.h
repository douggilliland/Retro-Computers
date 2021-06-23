/*
 *	MC6800/02 specific processing
 */

#ifndef _DO_H_
#define _DO_H_

void localinit(void);
void do_op(int opcode /* base opcode */, int class /* mnemonic class */);

#endif // _DO_H_

