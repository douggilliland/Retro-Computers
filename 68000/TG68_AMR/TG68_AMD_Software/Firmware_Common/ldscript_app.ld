SECTIONS
{
	. = 0x0;
	CODE : {
	  *startup*
	}
	.code : {
	  *(.text)
	  *(.rodata)
	  *(.rodata.*)
	  *(.data)
	}
	.extra : {
		__bss_start__ = . ;
	  *(.bss)
	  	__bss_end__ = . ;
	}
	.eh_frame : {
	  *(.eh_frame)
	}
	_romend=.;
	heap_low = .; /* region added to malloc heap */
	heap_top = 0x7f0000;

	start = 0x100;
}

ENTRY(start)
