#include "minisoc_hardware.h"
#include "textbuffer.h"

short SDHCtype=1;

// #define SPI_WAIT(x) while(HW_PER(PER_SPI_CS)&(1<<PER_SPI_BUSY));
// #define SPI(x) {while((HW_PER(PER_SPI_CS)&(1<<PER_SPI_BUSY))); HW_PER(PER_SPI)=(x);}
// #define SPI_READ(x) (HW_PER(PER_SPI)&255)

#define SPI_WAIT(x) ;
#define SPI(x) HW_PER(PER_SPI_BLOCKING)=(x)
#define SPI_PUMP(x) HW_PER(PER_SPI_PUMP)
#define SPI_PUMP_L(x) HW_PER_L(PER_SPI_PUMP)
#define SPI_READ(x) (HW_PER(PER_SPI_BLOCKING)&255)

#define SPI_CS(x) {while((HW_PER(PER_SPI_CS)&(1<<PER_SPI_BUSY))); HW_PER(PER_SPI_CS)=(x);}

#define cmd_reset(x) cmd_write(0x950040,0) // Use SPI mode
#define cmd_init(x) cmd_write(0xff0041,0)
#define cmd_read(x) cmd_write(0xff0051,x)

#define cmd_CMD8(x) cmd_write(0x870048,0x1AA)
#define cmd_CMD16(x) cmd_write(0xFF0050,x)
#define cmd_CMD41(x) cmd_write(0x870069,0x40000000)
#define cmd_CMD55(x) cmd_write(0xff0077,0)
#define cmd_CMD58(x) cmd_write(0xff007A,0)


unsigned char SPI_R1[6];


short cmd_write(unsigned long cmd, unsigned long lba)
{
	int ctr;
	short result=0xff;

	SPI(cmd & 255);

	if(!SDHCtype)	// If normal SD then we have to use byte offset rather than LBA offset.
		lba<<=9;

	SPI((lba>>24)&255);
	SPI((lba>>16)&255);
	SPI((lba>>8)&255);
	SPI(lba&255);

	SPI((cmd>>16)&255); // CRC, if any

	ctr=40000;
	SPI_WAIT();
	result=SPI_READ();
	while(--ctr && (result==0xff))
	{
		SPI(0xff);
		SPI_WAIT();
		result=SPI_READ();
	}
	return(result);
}

void spi_spin()
{
	puts("SPIspin\n");
	int i;
	for(i=0;i<200;++i)
		SPI(0xff);
	puts("Done - waiting\n");
	SPI_WAIT();
	puts("Done\n");
}

short wait_initV2()
{
	int i=20000;
	short r;
	spi_spin();
	while(--i)
	{
		if((r=cmd_CMD55())==1)
		{
			printf("CMD55 %x\n",r);
			SPI(0xff);
			if((r=cmd_CMD41())==0)
			{
				printf("CMD41 %x\n",r);
				SPI(0xff);
				return(1);
			}
			else
				printf("CMD41 %x\n",r);
			spi_spin();
		}
		else
			printf("CMD55 %x\n",r);
	}
	return(0);
}


short wait_init()
{
	int i=20;
	short r;
	SPI(0xff);
	puts("Cmd_init\n");
	while(--i)
	{
		if((r=cmd_init())==0)
		{
			printf("init %x\n  ",r);
			SPI(0xff);
			return(1);
		}
		else
			printf("init %x\n  ",r);
		spi_spin();
	}
	return(0);
}


short is_sdhc()
{
	int i,r;

	spi_spin();

	r=cmd_CMD8();		// test for SDHC capability
	printf("cmd_CMD8 response: %x\n",r);
	if(r!=1)
	{
		wait_init();
		return(0);
	}

	SPI(0xff);
	SPI_WAIT(); r=SPI_READ();
	printf("CMD8_1 response: %x\n",r);
	SPI(0xff);
	SPI_WAIT(); r=SPI_READ();
	printf("CMD8_2 response: %x\n",r);
	SPI(0xff);
	SPI_WAIT(); r=SPI_READ();
	if(r!=1)
	{
		wait_init();
		return(0);
	}

	printf("CMD8_3 response: %x\n",r);
	SPI(0xff);
	SPI_WAIT(); r=SPI_READ();
	if(r!=0xaa)
	{
		wait_init();
		return(0);
	}
	printf("CMD8_4 response: %x\n",r);

	SPI(0xff);

	// If we get this far we have a V2 card, which may or may not be SDHC...

	i=50;
	while(--i)
	{
		if(wait_initV2())
		{
			if((r=cmd_CMD58())==0)
			{
				printf("CMD58 %x\n  ",r);
				SPI(0xff);
				SPI_WAIT();
				r=SPI_READ();
				printf("CMD58_2 %x\n  ",r);
				SPI(0xff);
				SPI(0xff);
				SPI(0xff);
				SPI(0xff);
				if(r&0x40)
					return(1);
				else
					return(0);
			}
			else
				printf("CMD58 %x\n  ",r);
		}
		if(i==2)
		{
			printf("SDHC Initialization error!\n");
			return(0);
		}
	}

	return(0);
}


short spi_init()
{
	int i;
	int r;
	SDHCtype=1;
	HW_PER(PER_TIMER_DIV7)=150;	// About 350KHz
	SPI_CS(0);	// Disable CS
	spi_spin();
	SPI_CS(1);
	i=8;
	while(--i)
	{
		if(cmd_reset()==1) // Enable SPI mode
			i=1;
		if(i==2)
		{
			printf("SD card initialization error!\n");
			return(0);
		}
	}
	SDHCtype=is_sdhc();
	if(SDHCtype)
		printf("SDHC card detected\n");

	cmd_CMD16(1);
	SPI(0xFF);
	SPI_CS(0);

	HW_PER(PER_TIMER_DIV7)=HW_PER(PER_CAP_SPISPEED);
	return(1);
}


short sd_write_sector(unsigned long lba,unsigned char *buf) // FIXME - Stub
{
	return(0);
}


extern void spi_readsector(long *buf);


short sd_read_sector(unsigned long lba,unsigned char *buf)
{
	short result=0;
	int i;
	int r;
	SPI_CS(1);
	SPI(0xff);

	r=cmd_read(lba);
	if(r!=0)
	{
		printf("Read command failed at %ld (0x%x)\n",lba,r);
		return(result);
	}

	i=1500000;
	while(--i)
	{
		short v;
		SPI(0xff);
		SPI_WAIT();
		v=SPI_READ();
		if(v==0xfe)
		{
			spi_readsector((long *)buf);
//			int j;
//			SPI_PUMP();
//			for(j=0;j<256;++j)
//			{
//				*(long *)buf=SPI_PUMP_L();
//				buf+=4;				
//			}
#if 0
			for(j=0;j<256;++j)
			{
				int t;
				SPI(0xff);
				SPI_WAIT();
				v=SPI_READ()&255;
				t=v<<8;

				SPI(0xff);
				SPI_WAIT();
				v=SPI_READ()&255;
				t|=v&255;

				*(short *)buf=t;
				buf+=2;
			}
			SPI(0xff); SPI(0xff); // Fetch CRC
			SPI(0xff); SPI(0xff);
#endif
			i=1; // break out of the loop
			result=1;
		}
	}
	SPI(0xff);
	SPI_WAIT();
	SPI_CS(0);
	return(result);
}

