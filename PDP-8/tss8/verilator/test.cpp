//
// test.cpp
//
//

#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Vtest.h"

#include <iostream>

Vtest *top;                      // Instantiation of module

unsigned int main_time = 0;     // Current simulation time

double sc_time_stamp () {       // Called by $time in Verilog
    return main_time;
}

int main(int argc, char** argv)
{
    VerilatedVcdC* tfp = NULL;
    Verilated::commandArgs(argc, argv);   // Remember args

    top = new Vtest;             // Create instance

#ifdef VM_TRACE
    if (0) {
	    Verilated::traceEverOn(true);
	    VL_PRINTF("Enabling waves...\n");
	    tfp = new VerilatedVcdC;
	    top->trace(tfp, 99);	// Trace 99 levels of hierarchy
	    tfp->open("test.vcd");	// Open the dump file
    }
#endif

    top->v__DOT__io__DOT__rf__DOT__buffer__DOT__ram_debug = 1;
    top->v__DOT__sysclk = 0;

    while (!Verilated::gotFinish()) {

	// Resets
	if (main_time < 500) {
	    if (main_time == 20) {
		    VL_PRINTF("reset on\n");
		    top->v__DOT__reset = 1;
		    top->v__DOT__initial_pc = 07400;
	    }
	    if (main_time == 50) {
		    VL_PRINTF("reset off\n");
		    top->v__DOT__reset = 0;
	    }
	}

	// Toggle clock
	top->v__DOT__sysclk = ~top->v__DOT__sysclk;

	// Evaluate model
        top->eval();

        //if (top->v__DOT__sysclk) {
	//printf("state %d\n", top->v__DOT__state);
	//}

        if (top->v__DOT__sysclk &&
	    top->v__DOT__state == 1)
	{
		VL_PRINTF("pc %o ir %o l%d ac %o ion %o "
			  "(IF%o DF%o UF%o SF%o IB%o UB%o) state %d\n",
			  top->v__DOT__cpu__DOT__pc,
			  top->v__DOT__mb,
			  top->v__DOT__cpu__DOT__l,
			  top->v__DOT__cpu__DOT__ac,
			  top->v__DOT__cpu__DOT__interrupt_enable,
			  top->v__DOT__cpu__DOT__IF,
			  top->v__DOT__cpu__DOT__DF,
			  top->v__DOT__cpu__DOT__UF,
			  top->v__DOT__cpu__DOT__SF,
			  top->v__DOT__cpu__DOT__IB,
			  top->v__DOT__cpu__DOT__UB,
			  top->v__DOT__state);
	}

#ifdef VM_TRACE
//#define MIN_TIME 0
//#define MAX_TIME 100000

#define MIN_TIME 5196000
#define MAX_TIME 5313000


	if (tfp) {
		if (main_time > MIN_TIME)
			tfp->dump(main_time);

		if (main_time > MAX_TIME)
			vl_finish("test.cpp",__LINE__,"");
	}
#endif

        main_time += 10;
    }

    top->final();

    if (tfp)
	    tfp->close();
}
