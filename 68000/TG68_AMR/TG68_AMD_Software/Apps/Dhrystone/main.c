#include "vga.h"
#include "ints.h"
#include "uart.h"
#include "dhry.h"
#include "board.h"
#include "timer.h"

int microseconds=0;

static void heartbeat_int()
{
	microseconds+=10000;	// 100 Hz heartbeat
}

void SetHeartbeat()
{
	HW_TIMER(REG_TIMER_DIV0)=HW_BOARD(REG_CAP_CLOCKSPEED)*2; // Timers 1 through 6 are now based on 100khz base clock.
	HW_TIMER(REG_TIMER_CONTROL)=(1<<REG_TIMER_EN1);
	HW_TIMER(REG_TIMER_DIV1)=1000; // 100Hz heartbeat
	SetIntHandler(TIMER_INT,&heartbeat_int);
}

int main(int argc,char **argv)
{
	HW_UART(REG_UART_CLKDIV)=(1000*HW_BOARD(REG_CAP_CLOCKSPEED))/1152;
	SetHeartbeat();
	EnableInterrupts();

	Dhrystone();
}

