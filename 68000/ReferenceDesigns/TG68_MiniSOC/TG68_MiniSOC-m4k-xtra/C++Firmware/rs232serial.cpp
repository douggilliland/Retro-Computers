#include "rs232serial.h"

RS232Serial RS232;

void RS232Serial::IntHandler()
{
	int v=HW_PER(PER_UART);
//	if(v&(1<<PER_UART_TXREADY)) //FIXME - why is TXINT unreliable?  (Because it's cleared on read of course!)
//	{
		if(RS232.outbuffer.ReadReady())
		{
			if (HW_PER(PER_UART)&(1<<PER_UART_TXREADY))
			{
				HW_PER(PER_UART)=RS232.outbuffer.GetC();
				RS232.intpending=true;
			}
		}
		else
			RS232.intpending=false;
//	}
	// FIXME - losing characters?  Probably due to reading register in userspace code?
	if(v&(1<<PER_UART_RXINT))
	{
		if(RS232.inbuffer.WriteReady())
			RS232.inbuffer.PutC(v&255);
	}
}

