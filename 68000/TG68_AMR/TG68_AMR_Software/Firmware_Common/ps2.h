#ifndef PS2_H
#define PS2_H

#define PS2BASE 0x81000000
#define HW_PS2(x) *(volatile unsigned short *)(TIMERBASE+x)

#define REG_PS2_KEYBOARD 8
#define REG_PS2_MOUSE 0xA

#define BIT_PS2_RECV 11
#define BIT_PS2_CTS 10

// Private
#define PS2_RINGBUFFER_SIZE 32   // 32 bytes 
struct ps2_ringbuffer
{
	volatile int in_hw;
	volatile int in_cpu;
	volatile int out_hw;
	volatile int out_cpu;
	unsigned char inbuf[PS2_RINGBUFFER_SIZE];
	unsigned char outbuf[PS2_RINGBUFFER_SIZE];
};
void ps2_ringbuffer_init(struct ps2_ringbuffer *r);
void ps2_ringbuffer_write(struct ps2_ringbuffer *r,unsigned char in);
short ps2_ringbuffer_read(struct ps2_ringbuffer *r);
short ps2_ringbuffer_count(struct ps2_ringbuffer *r);
extern struct ps2_ringbuffer kbbuffer;
extern struct ps2_ringbuffer mousebuffer;
void PS2Handler();

// Public interface

void PS2Init();

#define PS2KeyboardRead(x) ps2_ringbuffer_read(&kbbuffer)
#define PS2KeyboardBytesReady(x) ps2_ringbuffer_count(&kbbuffer)
#define PS2KeyboardWrite(x) ps2_ringbuffer_write(&kbbuffer,x);

#define PS2MouseRead(x) ps2_ringbuffer_read(&mousebuffer)
#define PS2MouseBytesReady(x) ps2_ringbuffer_count(&mousebuffer)
#define PS2MouseWrite(x) ps2_ringbuffer_write(&mousebuffer,x);

#define PS2_INT 4

#endif
