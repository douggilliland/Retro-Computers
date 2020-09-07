#include <stdio.h>

#include "ps2.h"
#include "minisoc_hardware.h"
#include "ints.h"
#include "keyboard.h"
#include "textbuffer.h"

void ps2_ringbuffer_init(struct ps2_ringbuffer *r)
{
	r->in_hw=0;
	r->in_cpu=0;
	r->out_hw=0;
	r->out_cpu=0;
}

void ps2_ringbuffer_write(struct ps2_ringbuffer *r,unsigned char in)
{
//	DisableInterrupts();
	while(r->out_hw==((r->out_cpu+1)&(PS2_RINGBUFFER_SIZE-1)))
		;
//	{
//		EnableInterrupts();
//		DisableInterrupts();
//	}
	DisableInterrupts();
	r->outbuf[r->out_cpu]=in;
	r->out_cpu=(r->out_cpu+1) & (PS2_RINGBUFFER_SIZE-1);
	PS2Handler();
	EnableInterrupts();
}


short ps2_ringbuffer_read(struct ps2_ringbuffer *r)
{
	unsigned char result;
	if(r->in_hw==r->in_cpu)
		return(-1);	// No characters ready
	result=r->inbuf[r->in_cpu];
	r->in_cpu=(r->in_cpu+1) & (PS2_RINGBUFFER_SIZE-1);
	return(result);
}

short ps2_ringbuffer_count(struct ps2_ringbuffer *r)
{
	if(r->in_hw>=r->in_cpu)
		return(r->in_hw-r->in_cpu);
	return(r->in_hw+PS2_RINGBUFFER_SIZE-r->in_cpu);
}

struct ps2_ringbuffer kbbuffer;
struct ps2_ringbuffer mousebuffer;


void PS2Handler()
{
	short kbd=HW_PER(PER_PS2_KEYBOARD);
	short mouse=HW_PER(PER_PS2_MOUSE);
//	printf("PS2H %04x %04x ",kbd,mouse);

	if(kbd & (1<<PER_PS2_RECV))
	{
		HW_PER(PER_UART)='k';
//		printf("KRCV, %d\n",kbbuffer.in_hw);
		kbbuffer.inbuf[kbbuffer.in_hw]=(unsigned char)kbd;
		kbbuffer.in_hw=(kbbuffer.in_hw+1) & (PS2_RINGBUFFER_SIZE-1);
	}
	if(kbd & (1<<PER_PS2_CTS))
	{
//		printf("KCTS, %d, %d\n",kbbuffer.out_hw, kbbuffer.out_cpu);
		if(kbbuffer.out_hw!=kbbuffer.out_cpu)
		{
//			printf("Send kb %02x\n",kbbuffer.buf[kbbuffer.out_hw]);
			HW_PER(PER_PS2_KEYBOARD)=kbbuffer.outbuf[kbbuffer.out_hw];
			kbbuffer.out_hw=(kbbuffer.out_hw+1) & (PS2_RINGBUFFER_SIZE-1);
		}
	}
	if(mouse & (1<<PER_PS2_RECV))
	{
		HW_PER(PER_UART)='m';
//		printf("MRCV, %d\n",kbbuffer.in_hw);
		mousebuffer.inbuf[mousebuffer.in_hw]=(unsigned char)mouse;
		mousebuffer.in_hw=(mousebuffer.in_hw+1) & (PS2_RINGBUFFER_SIZE-1);
	}
	if(mouse & (1<<PER_PS2_CTS))
	{
//		printf("MCTS, %d, %d\n",mousebuffer.out_hw, mousebuffer.out_cpu);
		if(mousebuffer.out_hw!=mousebuffer.out_cpu)
		{
//			printf("Send ms %02x\n",kbbuffer.buf[kbbuffer.out_hw]);
			HW_PER(PER_PS2_MOUSE)=mousebuffer.outbuf[mousebuffer.out_hw];
			mousebuffer.out_hw=(mousebuffer.out_hw+1) & (PS2_RINGBUFFER_SIZE-1);
		}
	}
}

void PS2Init()
{
	ps2_ringbuffer_init(&kbbuffer);
	ps2_ringbuffer_init(&mousebuffer);
	SetIntHandler(PER_INT_PS2,&PS2Handler);
	ClearKeyboard();
}

