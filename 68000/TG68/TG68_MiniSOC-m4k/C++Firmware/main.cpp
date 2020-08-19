#include <new>
#include <string.h>

#include "rs232serial.h"
#include "ps2.h"

int main(int argc,char**argv)
{
	char buf[32];
	sprintf(buf,"X: %d\n\r",32);
	RS232.PutS(buf);
	RS232.PutS("Hello world!\n\r");
	PS2_Mouse.Init();
	int c=0;
	while(1)
	{
//		HW_PER(PER_HEX)=++c;
		int x=PS2_Mouse.X();
		int y=PS2_Mouse.Y();
		int z=PS2_Mouse.DZ();
		HW_PER(PER_HEX)=(x<<8) | (y&255);
	}
	return(0);
}


extern "C"
{
//	_reent *_impure_ptr;
	void c_entry()
	{
		main(0,0);
	}

	int __cxa_atexit(void(*func)(void))
	{
		return(0);
	}
#if 0
	void abort()
	{
		// Kill the program here.
		while(1);
	}
	int write(int, void *, size_t s)
	{
		return(s);
	}
	int fwrite(void *,size_t s,size_t t,void *)
	{
		return(s*t);
	}
	int fputs(const char *c,void *)
	{
		return(strlen(c));
	}
	int fputc(char c,void *)
	{
		return(c);
	}
#endif
}
