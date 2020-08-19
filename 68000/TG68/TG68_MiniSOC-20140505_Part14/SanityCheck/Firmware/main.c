#include "uart.h"

static int _cvt(int val)
{
	int c;
	int i;
	int nz=0;
//	if(val<0)
//	{
//		putchar('-');
//		val=-val;
//	}
	if(val)
	{
		for(i=0;i<8;++i)
		{
			c=(val>>28)&0xf;
			val<<=4;
			if(c)
				nz=1;	// Non-zero?  Start printing then.
			if(c>9)
				c+='A'-10;
			else
				c+='0';
			if(nz)	// If we've encountered only zeroes so far we don't print.
				putchar(c);
		}
	}
	else
		putchar('0');
	putchar('\n');
	return(0);
}


void flushcacheline(void *base)
{
	volatile long *p=(long *)base;
	long t;
	t=p[0x1000];
	t=p[0x4001];
	t=p[0x2000];
	t=p[0x3003];
	t=p[0x3001];
	t=p[0x2003];
	t=p[0x4000];
	t=p[0x1002];
}


unsigned long MisalignedLongCheck(void *base,unsigned long l1,unsigned long l2)
{
	int badbits=0;
	unsigned long t;
	volatile unsigned long *longptr=(unsigned long *)base;
	unsigned long k=(l1<<16)&0xffff0000;
	k|=(l2>>16)&0xffff;

	longptr[0]=l1;
	longptr[1]=l2;
	longptr=(volatile unsigned long *)(base+2);
	
	t=longptr[0];
	if(t!=k)
	{
		puts("Misaligned long check (cache) failed: ");
		_cvt(t);
		badbits|=(t^k);
	}
	flushcacheline(base+8);
	t=longptr[0];
	if(t!=k)
	{
		puts("Misaligned long check (flush) failed: ");
		_cvt(t);
		badbits|=(t^k);
	}
	return(badbits);
}


unsigned long LongShortCheck(void *base,unsigned long l1,unsigned short s1)
{
	int badbits=0;
	unsigned long t;
	volatile unsigned long *longptr=(unsigned long *)base;
	volatile unsigned short *shortptr=(unsigned short *)base;
	unsigned long k=(l1&0xffff0000)|(s1&0xffff);
	unsigned long k2=(l1&0xffff)|(s1<<16);

	longptr[0]=l1;
	shortptr[0]=s1;
	
	t=longptr[0];
	if(t!=k2)
	{
		puts("Long Short check 1 (cache) failed: ");
		_cvt(t);
		badbits|=(t^k2);
	}
	flushcacheline(base);
	t=longptr[0];
	if(t!=k2)
	{
		puts("Long Short check 1 (flush) failed: ");
		_cvt(t);
		badbits|=(t^k2);
	}

	longptr[1]=l1;
	shortptr[3]=s1;
	t=longptr[1];
	if(t!=k)
	{
		puts("Long Short check 2 (cache) failed: ");
		_cvt(t);
		badbits|=(t^k);
	}
	flushcacheline(base+4);
	t=longptr[1];
	if(t!=k)
	{
		puts("Long Short check 2 (flush) failed: ");
		_cvt(t);
		badbits|=(t^k);
	}

	return(badbits);
}


unsigned long LongByteCheck(void *base,unsigned long l1,unsigned char s1)
{
	int badbits=0;
	unsigned long t;
	volatile unsigned long *longptr=(unsigned long *)base;
	volatile unsigned char *byteptr=(unsigned char *)base;
	unsigned long k=(l1&0xffffff00)|(s1);
	unsigned long k2=(l1&0xffff00ff)|(s1<<8);
	unsigned long k3=(l1&0xff00ffff)|(s1<<16);
	unsigned long k4=(l1&0x00ffffff)|(s1<<24);

	longptr[0]=l1;
	byteptr[3]=s1;

	longptr[1]=l1;
	byteptr[6]=s1;

	longptr[2]=l1;
	byteptr[9]=s1;

	longptr[3]=l1;
	byteptr[12]=s1;
	
	t=longptr[0];
	if(t!=k)
	{
		puts("Long Byte check 1 (cache) failed: ");
		_cvt(t);
		_cvt(l1);
		_cvt(s1);
		badbits|=(t^k);
	}
	flushcacheline(base+8);
	t=longptr[0];
	if(t!=k)
	{
		puts("Long Byte check 1 (flush) failed: ");
		_cvt(t);
		_cvt(l1);
		_cvt(s1);
		badbits|=(t^k);
	}

	t=longptr[1];
	if(t!=k2)
	{
		puts("Long Byte check 2 (cache) failed: ");
		_cvt(t);
		_cvt(l1);
		_cvt(s1);
		badbits|=(t^k2);
	}
	flushcacheline(base+8);
	t=longptr[1];
	if(t!=k2)
	{
		puts("Long Byte check 2 (flush) failed: ");
		_cvt(t);
		_cvt(l1);
		_cvt(s1);
		badbits|=(t^k2);
	}

	t=longptr[2];
	if(t!=k3)
	{
		puts("Long Byte check 3 (cache) failed: ");
		_cvt(t);
		_cvt(l1);
		_cvt(s1);
		badbits|=(t^k3);
	}
	flushcacheline(base+8);
	t=longptr[2];
	if(t!=k3)
	{
		puts("Long Byte check 3 (flush) failed: ");
		_cvt(t);
		_cvt(l1);
		_cvt(s1);
		badbits|=(t^k3);
	}

	t=longptr[3];
	if(t!=k4)
	{
		puts("Long Byte check 4 (cache) failed: ");
		_cvt(t);
		_cvt(l1);
		_cvt(s1);
		badbits|=(t^k4);
	}
	flushcacheline(base+8);
	t=longptr[3];
	if(t!=k4)
	{
		puts("Long Byte check 4 (flush) failed: ");
		_cvt(t);
		_cvt(l1);
		_cvt(s1);
		badbits|=(t^k4);
	}


	return(badbits);
}


int memorycheck(void *base)
{
	int result=1;
	int t;
	volatile unsigned char *byteptr=(char*)base;
	volatile unsigned short *wordptr=(short *)base;
	volatile unsigned long *longptr=(long *)base;
	unsigned long i,j,badbits,overallbadbits;

	// Test 1

	overallbadbits=0;
	badbits=0;

	puts("\nLong/short test...\n");

	for(i=0;i<0x7fff0000;i+=0x212345)
	{
		for(j=0;j<0x7fff0000;j+=0x318765)
		{
			badbits|=LongShortCheck(base,i,j);
		}
		putchar('.');
	}
	if(badbits)
	{
		result=0;
		puts("Bad bits from Long Short test: ");
		_cvt(badbits);
	}

	// Test 2
	puts("\nMisaligned Long test...\n");

	overallbadbits|=badbits;
	badbits=0;

	for(i=0;i<0x7fff0000;i+=0x134567)
	{
		for(j=0;j<0x7fff0000;j+=0x198765)
		{
			badbits|=MisalignedLongCheck(base,i,j);
		}
		putchar('.');
	}
	if(badbits)
	{
		result=0;
		_cvt(badbits);
	}

	overallbadbits|=badbits;
	badbits=0;

	// Test 2
	puts("Long / byte test...\n");

	for(i=0;i<0x7fff0000;i+=0x712341)
	{
		for(j=0;j<0x7fff0000;j+=0x287653)
		{
			badbits|=LongByteCheck(base,i,j);
		}
		putchar('.');
	}
	if(badbits)
	{
		result=0;
		_cvt(badbits);
	}

	overallbadbits|=badbits;

	// Tests complete.

	if(overallbadbits)
	{
		puts("Bad bits detected: ");
		_cvt(overallbadbits);
	}

	return(result);	
}


int main(int argc, char **argv)
{
	HW_UART(REG_UART_CLKDIV)=(HW_UART(REG_CAP_FREQ)*1000)/1152;
	puts("Commencing sanity checks...\n");

	if(memorycheck(0x10000))
		puts("Memory check passed\n");
	else
		puts("Memory check failed\n");

	return(0);
}

