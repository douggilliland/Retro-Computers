#ifndef PS2_H
#define PS2_H

#include <stdio.h>

#include <hardware/minisoc_hardware.h>
#include <hardware/ps2regs.h>
#include <hardware/ints.h>
#include "rs232serial.h"
#include "chardevice.h"

class PS2Device : public CharDevice
{
	public:
	PS2Device(int device=PER_PS2_KEYBOARD) : CharDevice(8), device(device), intpending(false)
	{
		while(!((HW_PER(device)&(1<<PER_PS2_CTS))))
			;
		SetIntHandler(PER_INT_PS2,IntHandler);
	}
	virtual ~PS2Device()
	{
		SetIntHandler(PER_INT_UART,0);
	}
	virtual int Write(const char *buf,int len)
	{
		int result=0;
		DisableInterrupts();
		if(!intpending)
		{
			HW_PER(device)=*buf++;
			--len;
			result=1;
			intpending=true;
		}			
		result+=CharDevice::Write(buf,len);
		EnableInterrupts();
		return(result);
	}

	virtual int Read(char *buf,int len)
	{
		int result;
		DisableInterrupts();
		result=CharDevice::Read(buf,len);
		EnableInterrupts();
		return(result);
	}

	static void IntHandler();
	protected:
	int device;
	bool intpending;
};


class PS2Mouse : public PS2Device
{
	public:
	PS2Mouse() : PS2Device(PER_PS2_MOUSE), x(0), y(0), dx(0),dy(0),dz(0),mousetimeout(0)
	{
	}
	virtual ~PS2Mouse()
	{

	}
	void Init()
	{
		unsigned char buf[4];
		RS232.PutS("Initializing PS/2 mouse\n\r");
		while(inbuffer.ReadReady())
			Read((char *)buf,3); // Drain the buffer;

		RS232.PutS("Buffer drained\n\r");

		buf[0]=0xf4;
		Write((char *)buf,1);

		RS232.PutS("Sent reset command, awaiting reply\n\r");

//		SetIntHandler(PER_INT_TIMER,&timer_int);
//		SetTimeout(10000);
		while(buf[0]!=0xfa && mousetimeout==0)
		{
			if(inbuffer.ReadReady())
			{
				char hex[4];
				Read((char*)buf,1);
				hex[0]=buf[0]>>4;
				if(hex[0]>9)
					hex[0]+='@'-'9';
				hex[0]+='0';
				hex[1]=buf[0]&15;
				if(hex[1]>9)
					hex[1]+='@'-'9';
				hex[1]+='0';
				hex[2]=0;

				RS232.PutS(hex);
				RS232.PutS("Received\n\r");
			}
		}
		RS232.PutS("Got reply\n\r");
	}
	inline int X()
	{
		x+=DX();
		return(x);
	}
	inline int Y()
	{
		y+=DY();
		return(y);
	}
	inline int DX()
	{
		int result=dx;
		dx-=result;
		return(result);
	}
	inline int DY()
	{
		int result=dy;
		dy-=result;
		return(result);
	}
	inline int DZ()
	{
		int result=dz;
		dz-=result;
		return(result);
	}
	short x,y;
	short dx,dy,dz;
	short buttons;
	bool mousetimeout;
};

extern PS2Device PS2_Keyboard;
extern PS2Mouse PS2_Mouse;

#endif
