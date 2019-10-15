/* simple code that tests I/O */

#include <z80.h>

#pragma output REGISTER_SP = 0x4000

void main(void)
{
	unsigned char data;
	data = z80_inp(0x10);
	z80_outp(0x10,data);
	while(1);
}
	