#include "hardware/ints.h"

extern void (*IntHandler1)();
extern "C" void DummyIntHandler();

void SetIntHandler(short interrupt, void(*handler)())
{
	if(!handler)
		handler=DummyIntHandler;
	if(interrupt>0 && interrupt<=7)
	{
		void (**h)()=&IntHandler1;
		h[interrupt-1]=handler;
	}
}
