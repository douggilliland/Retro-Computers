SECTIONS
{
	. = 0x100;
	CODE : {
	  BUILD/startup.o	/* VASM assembled */
	}
	.code : {
	  *(.text)
	  *(.rodata)
	  *(.rodata.*)
	  *(.data)
	}
	.extra : {
		__s_bss = . ;
	  *(.bss)
	  	__e_bss = . ;
	}
	.eh_frame : {
	  *(.eh_frame)
	}
	heap_low = .; /* region added to malloc heap */
	heap_top = 0x7f0000;

	stack_top = 0x7ffffe; /* for startup.s */
	start = 0x100;
}

ENTRY(start)
