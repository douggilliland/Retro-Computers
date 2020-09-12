
//#include "minisoc_hardware.h"
#include "board.h"
#include "timer.h"
#include "interrupts.h"
#include "ps2.h"
#include "keyboard.h"
#include "textbuffer.h"
#include "spi.h"
#include "fat.h"
#include "uart.h"
#include "vga.h"

#include <stdio.h>
#include <string.h>
#include <malloc.h>

#include "dhry.h"

short *FrameBuffer;
extern short pen;
extern void DrawIteration();

static short framecount=0;
short MouseX=0,MouseY=0,MouseZ=0,MouseButtons=0;
short mousetimeout=0;

int microseconds=0;

static void heartbeat_int()
{
	microseconds+=10000;	// 100 HZ heartbeat
}

void SetHeartbeat()
{
	HW_TIMER(REG_TIMER_DIV0)=HW_BOARD(REG_CAP_CLOCKSPEED)*2; // Timers 1 through 6 are now based on 100kHZ base clock.
	HW_TIMER(REG_TIMER_CONTROL)=(1<<BIT_TIMER_EN1);
	HW_TIMER(REG_TIMER_DIV1)=1000; // 100HZ heartbeat
	SetIntHandler(TIMER_INT,&heartbeat_int);
}

int screenwidth=640;

static void vblank_int()
{
	static short mousemode=0;
	char a=0;
	int yoff;
	framecount++;
//	microseconds+=(16667*1250)/HW_PER(PER_CAP_CLOCKSPEED);	// Assumes 60HZ video mode.

//	microseconds+=16667;	// Assumes 60HZ video mode.

	if(framecount==959)
		framecount=0;
	if(framecount>=480)
		yoff=959-framecount;
	else
		yoff=framecount;
	HW_VGA_L(FRAMEBUFFERPTR)=(unsigned long)(&FrameBuffer[yoff*screenwidth]);

	while(PS2MouseBytesReady()>=(3+mousemode))	// FIXME - institute some kind of timeout here to re-sync if sync lost.
	{
		short nx;
		short w1,w2,w3,w4;
		w1=PS2MouseRead();
		w2=PS2MouseRead();
		w3=PS2MouseRead();
		if(mousemode)	// We're in 4-byte packet mode...
		{
			w4=PS2MouseRead();
			if(w4&8)	// Negative
				MouseZ-=(w4^15)&15;
			else
				MouseZ+=w4&15;
		}
		MouseButtons=w1;
//		printf("%02x %02x %02x\n",w1,w2,w3);
		if(w1 & (1<<5))
			w3|=0xff00;
		if(w1 & (1<<4))
			w2|=0xff00;
//			HW_PER(PER_HEX)=(w2<<8)|(w3 & 255);

		nx=MouseX+w2;
		if(nx<0)
			nx=0;
		if(nx>639)
			nx=639;
		MouseX=nx;

		nx=MouseY-w3;
		if(nx<0)
			nx=0;
		if(nx>479)
			nx=479;
		MouseY=nx;

		mousetimeout=0;
	}
	HW_VGA(SP0XPOS)=MouseX;
	HW_VGA(SP0YPOS)=MouseY;

	// Clear any incomplete packets, to resync the mouse if comms break down.
	if(PS2MouseBytesReady())
	{
		++mousetimeout;
		if(mousetimeout==20)
		{
			while(PS2MouseBytesReady())
				PS2MouseRead();
			mousetimeout=0;
			mousemode^=1;	// Toggle 3/4 byte packets
		}
	}

	// Receive any keystrokes
	if(PS2KeyboardBytesReady())
	{
		while((a=HandlePS2RawCodes()))
		{
			char buf[2]={0,0};
//			HW_PER(PER_UART)=a;
			buf[0]=a;
			tb_puts(buf);
		}
	}
}


static void mousetimer_int()
{
	if(HW_TIMER(REG_TIMER_CONTROL) & (1<<BIT_TIMER_TR5))
		mousetimeout=1;
//	puts("Timer int received\n");
}


void SetMouseTimeout(int delay)
{
	mousetimeout=0;
	HW_TIMER(REG_TIMER_CONTROL)=(1<<BIT_TIMER_EN5);
	HW_TIMER(REG_TIMER_DIV5)=delay;
	SetIntHandler(TIMER_INT,&mousetimer_int);
}


extern char heap_low;
void AddMemory()
{
	size_t low;
	size_t size;
	low=(size_t)&heap_low;
	low+=15;
	low&=0xfffffff0; // Align to SDRAM burst boundary
	size=1L<<HW_BOARD(REG_CAP_RAMSIZE);
	size-=low;
	size-=0x1000; // Leave room for the stack
	printf("Heap_low: %lx, heap_size: %lx\n",low,size);
	malloc_add((void*)low,size);
}


extern DIRENTRY DirEntry[MAXDIRENTRIES];
extern unsigned char sort_table[MAXDIRENTRIES];
extern unsigned char nDirEntries;
extern unsigned char iSelectedEntry;
extern unsigned long iCurrentDirectory;
extern char DirEntryLFN[MAXDIRENTRIES][261];
char DirEntryInfo[MAXDIRENTRIES][5]; // disk number info of dir entries
char DiskInfo[5]; // disk number info of selected entry

// print directory contents
void PrintDirectory(void)
{
	unsigned char i;
	unsigned char k;
	unsigned long len;
	char *lfn;
	char *info;
	char *p;
	unsigned char j;

	for (i = 0; i < 8; i++)
	{
		k = sort_table[i]; // ordered index in storage buffer
		lfn = DirEntryLFN[k]; // long file name pointer
		if (lfn[0]) // item has long name
		{
			puts(lfn);
		}
		else  // no LFN
		{
			puts(&DirEntry[k].Name[0]);
		}

		if (DirEntry[k].Attributes & ATTR_DIRECTORY) // mark directory with suffix
			puts("<DIR>\n");
		else
			puts("\n");
	}
}


#define CYCLE_LFSR {lfsr<<=1; if(lfsr&0x400000) lfsr|=1; if(lfsr&0x200000) lfsr^=1;}
void DoMemcheckCycle(unsigned int *p)
{
	int i;
	static int lfsr=1;
	static int inv=1;
	unsigned int lfsrtemp=lfsr;
	if((lfsr&0xfffff)==1)
		inv=1-inv;

	if(inv)
	{
		for(i=0;i<65536;++i)
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
		for(i=0;i<65536;++i)
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
	else
	{
		for(i=0;i<65536;++i)
		{
			unsigned int w=lfsr&0xfffff;
			unsigned int j=lfsr&0xfffff;
			CYCLE_LFSR;
			unsigned int x=lfsr&0xfffff;
			unsigned int k=lfsr&0xfffff;
			p[j]=w^0xfffff;
			p[k]=x^0xfffff;

			CYCLE_LFSR;
		}
		lfsr=lfsrtemp;
		for(i=0;i<65536;++i)
		{
			unsigned int w=lfsr&0xfffff;
			unsigned int j=lfsr&0xfffff;
			CYCLE_LFSR;
			unsigned int x=lfsr&0xfffff;
			unsigned int k=lfsr&0xfffff;
			if(p[j]!=(w^0xfffff))
			{
				printf("Error at %x\n",w);
				printf("expected %x, got %x\n",w,p[j]);
			}
			if(p[k]!=(x^0xfffff))
			{
				printf("Error at %x\n",w);
				printf("expected %x, got %x\n",w,p[j]);
			}
			CYCLE_LFSR;
		}
	}
}


short SDCardInit()
{
	puts("Initialising SD card\n");
	if(spi_init())
	{
		FindDrive();
		puts("FindDrive() returned\n");

		ChangeDirectory(DIRECTORY_ROOT);
		puts("Changed directory\n");

		ScanDirectory(SCAN_INIT, "*", 0);
		return(1);
	}
	return(0);
}


char printf_buffer[256];

int main(int argc,char *argv)
{
	enum mainstate_t {MAIN_IDLE,MAIN_LOAD,MAIN_MEMCHECK,MAIN_RECTANGLES,MAIN_DHRYSTONE};
	fileTYPE file;
	unsigned char *fbptr;
	ClearTextBuffer();

	HW_UART(REG_UART_CLKDIV)=(1000*HW_BOARD(REG_CAP_CLOCKSPEED))/1152;
	HW_TIMER(REG_TIMER_DIV0)=HW_BOARD(REG_CAP_CLOCKSPEED)*2; // Clocks 1 through 6 are now based on 100kHZ base clock.

	AddMemory();

	PS2Init();
	VGA_SetSprite();

	FrameBuffer=(short *)malloc(sizeof(short)*640*960+15);
	FrameBuffer=(short *)(((int)FrameBuffer+15)&~15); // Align to nearest 16 byte boundary.
	HW_VGA_L(FRAMEBUFFERPTR)=FrameBuffer;

	memset(FrameBuffer,0,sizeof(short)*640*960);

	EnableInterrupts();

	while(PS2MouseRead()>-1)
		; // Drain the buffer;
	PS2MouseWrite(0xf4);

	SetMouseTimeout(1000);
	while(PS2MouseRead()!=0xfa && mousetimeout==0)
		; // Read the acknowledge byte

	if(mousetimeout)
		puts("Mouse timed out\n");

	// Don't set the VBlank int handler until the mouse has been initialised.
	SetIntHandler(VGA_INT_VBLANK,&vblank_int);

	SetHeartbeat();

	tb_puts("\r\nWelcome to TG68MiniSOC, a minimal System-on-Chip,\r\nbuilt around Tobias Gubener's TG68k processor core.\r\n");

	tb_puts("Initializing SD card...\r\n");
	if(!SDCardInit())
		tb_puts("  SD card error!\r\n");

	tb_puts("Press F1 through F4 to change test mode.\r\n");
	tb_puts("Press F5 through F9 to change screenmode.\r\n");
	tb_puts("Press F12 to toggle character overlay.\r\n");

	enum mainstate_t mainstate=MAIN_DHRYSTONE;

	while(1)
	{
		if(TestKey(KEY_F1))
		{
			mainstate=MAIN_LOAD;
			puts("Switching to image mode\n");
			while(TestKey(KEY_F1))
				;
		}
		if(TestKey(KEY_F2))
		{
			mainstate=MAIN_MEMCHECK;
			puts("Switching to Memcheck mode\n");
			while(TestKey(KEY_F2))
				;
		}
		if(TestKey(KEY_F3))
		{
			mainstate=MAIN_RECTANGLES;
			puts("Switching to Rectangles mode\n");
			while(TestKey(KEY_F3))
				;
		}
		if(TestKey(KEY_F4))
		{
			mainstate=MAIN_DHRYSTONE;
			puts("Switching to image mode\n");
			while(TestKey(KEY_F4))
				;
		}
		if(TestKey(KEY_F5))
		{
			puts("640 x 480\n");
			screenwidth=640;
			VGA_SetScreenMode(MODE_640_480_60HZ);
			while(TestKey(KEY_F5))
				;
		}
		if(TestKey(KEY_F6))
		{
			puts("320 x 480\n");
			screenwidth=320;
			VGA_SetScreenMode(MODE_320_480_60HZ);
			while(TestKey(KEY_F6))
				;
		}
		if(TestKey(KEY_F7))
		{
			puts("800 x 600 @ 50HZ\n");
			screenwidth=800;
			VGA_SetScreenMode(MODE_800_600_52HZ);
			while(TestKey(KEY_F7))
				;
		}
		if(TestKey(KEY_F8))
		{
			puts("768 x 576\n");
			screenwidth=768;
			VGA_SetScreenMode(MODE_768_576_57HZ);
			while(TestKey(KEY_F8))
				;
		}

		if(TestKey(KEY_F9))
		{
			puts("800 x 600 @ 72HZ\n");
			screenwidth=800;
			VGA_SetScreenMode(MODE_800_600_72HZ);
			while(TestKey(KEY_F9))
				;
		}

		if(TestKey(KEY_F12))
		{
			static short overlay=0;
			puts("Toggling overlay\n");
			overlay=~overlay;
			if(overlay)
				VGA_HideOverlay();
			else
				VGA_ShowOverlay();
			while(TestKey(KEY_F12))
				;
		}

		// Main loop iteration.
		switch(mainstate)
		{
			case MAIN_IDLE:
				break;
			case MAIN_LOAD:
				if(FileOpen(&file,"TEST    IMG"))
				{
					int errorcount=6;
					fbptr=(unsigned char *)FrameBuffer;
					short imgsize=file.size/512;
					int c=0;
					while(c<=((640*960*2-1)/512) && c<imgsize)
					{
						if(FileRead(&file, fbptr))
						{
							c+=1;
							FileNextSector(&file);
							fbptr+=512;
						}
						else	// Read failed, retry, and if it still failed re-init the card.
						{
							--errorcount;
							if(!errorcount)
								break;
							if(errorcount==3)
							{
								if(!SDCardInit())
									break;
								if(!FileOpen(&file,"TEST    IMG"))
									break;
							}
						}
					}
				}
				else
					printf("Couldn't load test.img\n");
				mainstate=MAIN_IDLE;
				break;
			case MAIN_MEMCHECK:
				DoMemcheckCycle((unsigned int *)FrameBuffer);
				break;
			case MAIN_RECTANGLES:
				if(MouseButtons&1)
					pen+=0x400;
				if(MouseButtons&2)
					pen-=0x400;
				DrawIteration();
				HW_BOARD(REG_HEX)=pen;
				break;
			case MAIN_DHRYSTONE:
				tb_puts("Running Dhrystone benchmark...\r\n");
				{
					int result=Dhrystone();

					sprintf(printf_buffer, "%d DMIPS\r\n",result);
					tb_puts(printf_buffer);
				}
				mainstate=MAIN_RECTANGLES;
				break;
		}
	}
}

