#include "ints.h"

extern void (*IntHandler1)();

void SetIntHandler(short interrupt, void(*handler)())
{
	if(interrupt>0 && interrupt<=7)
	{
		void (**h)()=&IntHandler1;
		h[interrupt-1]=handler;
	}
}
