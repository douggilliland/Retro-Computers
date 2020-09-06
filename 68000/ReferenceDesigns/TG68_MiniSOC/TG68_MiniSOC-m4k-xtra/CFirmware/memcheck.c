#include <stdio.h>
#include <string.h>
#include <malloc.h>

#include "minisoc_hardware.h"
#include "ints.h"
#include "ps2.h"
#include "keyboard.h"
#include "textbuffer.h"
#include "spi.h"
#include "fat.h"


void AddMemory()
{
	size_t low;
	size_t size;
	low=(size_t)&heap_low;
	low+=7;
	low&=0xfffffff8; // Align to SDRAM burst boundary
	size=((char*)&heap_top)-low;
	printf("Heap_low: %lx, heap_size: %lx\n",low,size);
	malloc_add((void*)low,size);
}


//#define CYCLE_LFSR {lfsr<<=1; if(lfsr&0x80000000) lfsr|=1; if(lfsr&0x10000000) lfsr^=1;}

//#define CYCLE_LFSR {lfsr<<=1; if(lfsr&0x80000000) lfsr|=1; if(lfsr&0x10000000) lfsr^=1;}
#define CYCLE_LFSR {lfsr<<=1; if(lfsr&0x400000) lfsr|=1; if(lfsr&0x200000) lfsr^=1;}

void c_entry()
{
	unsigned int *p;
	ClearTextBuffer();

	AddMemory();

	puts("Checking memory...\n");

	if((p=(unsigned int *)malloc(0x400000)))
	{
		unsigned int lfsr=12467;
		while(1)
		{
			int i;
			unsigned int lfsrtemp=lfsr;
			for(i=0;i<262144;++i)
			{
				unsigned int w=lfsr&0xfffff;
				unsigned int j=lfsr&0xfffff;
				CYCLE_LFSR;
				unsigned int x=lfsr&0xfffff;
				unsigned int k=lfsr&0xfffff;
				p[j]=w;
				p[k]=x;
				CYCLE_LFSR;
			}
			lfsr=lfsrtemp;
			for(i=0;i<262144;++i)
			{
				unsigned int w=lfsr&0xfffff;
				unsigned int j=lfsr&0xfffff;
				CYCLE_LFSR;
				unsigned int x=lfsr&0xfffff;
				unsigned int k=lfsr&0xfffff;
				if(p[j]!=w)
				{
					printf("Error at %x\n",w);
					printf("expected %x, got %x\n",w,p[j]);
				}
				if(p[k]!=x)
				{
					printf("Error at %x\n",w);
					printf("expected %x, got %x\n",w,p[j]);
				}
				CYCLE_LFSR;
			}
		}
	}
}

