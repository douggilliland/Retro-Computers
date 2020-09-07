SECTIONS
{
	. = 0x0000;
	CODE : {
	  sdbootstrap.o	/* VASM assembled */
	}
	start = 0x0008;
}

ENTRY(start)
