#ifndef SERIAL_H
#define SERIAL_H

#include <hardware/minisoc_hardware.h>
#include <hardware/uart.h>
#include <hardware/ints.h>

#include "chardevice.h"

// TODO -
// Get system clock speed from hardware (needs hardware support)

class RS232Serial : public CharDevice
{
	public:
	RS232Serial(volatile unsigned short *base=(volatile unsigned short *)PERIPHERALBASE)
		: CharDevice(8), base(base), intpending(false)
	{
		while(!((HW_PER(PER_UART)&(1<<PER_UART_TXREADY))))
			;
		SetIntHandler(PER_INT_UART,IntHandler);
	}

	~RS232Serial()
	{
		SetIntHandler(PER_INT_UART,0);
	}

	void SetBaud(int baud=115200)
	{
		// FIXME - get system clock speed from hardware.
		int clk=256; // Master clock speed, in MHz, shifted left 8 bits
		// FIXME - if we add a second UART, we'll need to employ the base pointer.
		HW_PER(PER_UART_CLKDIV)=(clk*1000000)/(baud<<8);
		
	}

	virtual int Write(const char *buf,int len)
	{
		int result=0;
		DisableInterrupts();
		if(!intpending)
		{
;			while(!((HW_PER(PER_UART)&(1<<PER_UART_TXREADY))))
;				;
			HW_PER(PER_UART)=*buf++;
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
	volatile unsigned short *base;
	bool intpending;
};

extern RS232Serial RS232;

#endif

