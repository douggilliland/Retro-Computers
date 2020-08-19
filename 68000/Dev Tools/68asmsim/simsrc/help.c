
/***************************** 68000 SIMULATOR ****************************

File Name: HELP.C
Version: 1.0

This file contains the routines to display online help information

***************************************************************************/



#include <stdio.h>
#include "extern.h"


show_topics()
{

	clrscr();
	home();
	printf("BIT_OFF      BIT_ON       Break Points  CHange       CLEAR\n");
	printf("DEC          EX_ON        EX_OFF        EXCeption processing\n");
	printf("EXIT         GO           HELP          HEX          LoaD\n");
	printf("Mem Display  REFRESH      SSOFF         SSTEP        TRACE\n");
	printf("TROFF        VERSION      QUIT to end help.\n");
	printf("\n");
	printf("subtopic ?");

	return SUCCESS;

}

gethelp()
{
	char *sub;

	show_topics();
	at (7,12);
	if (wcount > 1)
		sub = gettext(2,"");
	else {
		if (gets(lbuf,80)==NULL)
			exit(0);
		wcount = scan(lbuf,wordptr,10);
		sub = wordptr[0];
		}

while (!same("quit",sub))
	{
	show_topics();
	at (10,1);
if (same("exc",sub))
	{
	printf("Exception processing can begin in several different ways.\n");
	printf("Generally, there are three classes of exception conditions:\n");
	printf("\n");
	printf("   Group 0: Reset, Address error, Bus error.\n");
	printf("   Group 1: Trace, Interrupt, Illegal, Privilege violation.\n");
	printf("   Group 2: TRAP, TRAPV, CHK, and Divide by zero.\n");
	printf("\n");
	printf("Reset cannot occur in this simulator.\n");
	printf("Address error occurs when an word or long word is written or\n");
	printf("   read from an odd word boundary.  i.e. an odd memory address.\n");
	printf("Bus error can occur in this simulator by attempting to read\n");
	printf("   or write outside of the virtual memory space.  The virtual\n");
	printf("   memory for this simulator is from location 0 to location\n");
	printf("   0FFF (hex).\n");
	printf("\n");
	printf("Trace is entered if on the completion of an instruction, the\n");
	printf("   trace bit of the status register is on.\n");
	printf("Interrupt occurs when an external device interrupts the\n");
	printf("   processor's operation.  Presently, this cannot occur on\n");
	printf("   this simulator.\n");
	printf("\n");
	printf("<HIT RETURN TO CONTINUE>\n");
	if (gets(lbuf,80)==NULL) exit(0);
	printf("\n");
	printf("Illegal exception occurs when an illegal instruction opcode\n");
	printf("   is executed.  It also occurs when the ILLEGAL instruction\n");
	printf("   is executed.\n");
	printf("Privilege violation occurs when a privileged instruction\n");
	printf("   is attempted and the supervisor bit in the status register\n");
	printf("   is not set.\n");
	printf("\n");
	printf("TRAP exception occurs when a TRAP instruction is executed\n");
	printf("TRAPV exception occurs when a TRAPV instruction is executed\n");
	printf("CHK exception occurs when a CHK instruction is executed\n");
	printf("Divide by zero exception occurs when a DIVU or DIVS instruction\n");
	printf("   attempts a division by zero.\n");
	printf("\n");
	printf("<HIT RETURN TO CONTINUE>\n");
	if (gets(lbuf,80)==NULL) exit(0);
	printf("\n");
	printf("Exception processing begins by creating the appropriate\n");
	printf("   exception stack frame for the particular exception group\n");
	printf("   on the supervisor stack.  Then, the supervisor mode is\n");
	printf("   turned on and trace mode is turned off.  After that,\n");
	printf("   instruction execution resumes at the location referenced\n");
	printf("   by the appropriate exception vector.  The exception vector\n");
	printf("   locations that can be used in this simulator are listed\n");
	printf("   below:\n");
	printf("\n");
	printf("<HIT RETURN TO CONTINUE>\n");
	if (gets(lbuf,80)==NULL) exit(0);
	printf("\n");
	printf("       Location (Hex)        Assignment\n");
	printf("\n");
	printf("           008               Bus error\n");
	printf("           00C               Address error\n");
	printf("           010               Illegal instruction\n");
	printf("           014               Divide by zero\n");
	printf("           018               CHK instruction\n");
	printf("           01C               TRAPV instruction\n");
	printf("           020               Privilege violation\n");
	printf("           024               Trace\n");
	printf("           028               Line 1010 emulator\n");
	printf("           02C               Line 1111 emulator\n");
	printf("        080 to 0BC           TRAP instruction vectors\n");
	printf("\n");
	printf("<HIT RETURN TO CONTINUE>\n");
	if (gets(lbuf,80)==NULL) exit(0);
	printf("\n");
	printf("When the simulator starts up the supervisor bit is set on\n");
	printf("   and the supervisor stack pointer is set to the value\n");
	printf("   F00 (hex).  Note that the stack grows downward, so the\n");
	printf("   stack frame for any exceptions will grow from F00 downward.\n");
	printf("\n");
	printf("For complete information on exception processing, refer to\n");
	printf("   the 68000 Programmer's Reference Manual, Section 4.\n");
	printf("\n");
	printf("<HIT RETURN TO CONTINUE>\n");
	if (gets(lbuf,80)==NULL) exit(0);
	show_topics();
	}
if (same("bp",sub))
	{
	printf("Break Points allows you to set clear and show break points.\n");
	printf("\n");
	printf("sp <loc>  sets a break point at loc.\n");
	printf("dp        displays a list of the break points.\n");
	printf("cp <loc>  clears the break point at loc.\n");
	}
if (same("bit_on",sub))
	{
	printf("bit_on allows you to turn on a specific bit in the status ");
	printf("register");

	printf("\n");
	printf("s_on         turns on the supervisor bit\n");
	printf("t_on         turns on the trace bit\n");
	printf("x_on         turns on the extend bit\n");
	printf("n_on         turns on the negative bit\n");
	printf("z_on         turns on the zero bit\n");
	printf("v_on         turns on the overflow bit\n");
	printf("c_on         turns on the carry bit\n");
	}
if (same("bit_off",sub))
	{
	printf("bit_off allows you to turn off a specific bit in the status ");
	printf("register");

	printf("\n");
	printf("s_off         turns off the supervisor bit\n");
	printf("t_off         turns off the trace bit\n");
	printf("x_off         turns off the extend bit\n");
	printf("n_off         turns off the negative bit\n");
	printf("z_off         turns off the zero bit\n");
	printf("v_off         turns off the overflow bit\n");
	printf("c_off         turns off the carry bit\n");
	}
if (same("hex",sub))
	{
	printf("Hex allows you to convert a decimal number into hexadecimal");
	printf("    format.\n");

	printf("\n");
	printf("hex <number>  shows the number in hexadecimal format.\n");
	printf("              <number> must be input in decimal format.\n");
	}
if (same("dec",sub))
	{
	printf("Dec allows you to convert a hexadecimal number into decimal");
	printf("    format.\n");

	printf("\n");
	printf("dec <number>  shows the number in decimal format. <number> must\n");
	printf("              be input in hexadecimal format.\n");
	}
if (same("ch",sub))
	{
	printf("Ch allows you to change the values of elements in the\n");
	printf("    simulator.\n");
	printf("\n");
	printf("D<num> <val>     places val in register D<num>.\n");
	printf("                   <num> is in the range 0 - 7.\n");
	printf("A<num> <val>     places val in A register # num.\n");
	printf("                   <num> is in the range 0 - 8.\n");
	printf("                 NOTE: the supervisor stack pointer (A7') is\n");
	printf("                   referenced as 'A8'.\n");
	printf("PC <val>         places val in the program counter.\n");
	printf("int <val>        places val in the interrupt mask bits of the\n");
	printf("                   status register.  <val> is in the range 0 - 7.\n");
	printf("mem <loc> <val>  places val in location loc.\n");
	printf("io               allows you to modify the port registers.\n");
	}
if (same("clear",sub))
	{
	printf("CLEAR allows you to clear different elements within the processor\n");
	printf("and the simulator.\n");
	printf("\n");
	printf("mem         fills the memory space with zero's.\n");
	printf("reg         fills all the registers with zero's.\n");
	printf("port        clears port.\n");
	printf("int         clears any pending interrupts.\n");
	printf("cy          clears the cycle counter.\n");
	printf("all         clears all of the above items.\n");
	}
if (same("exit",sub))
	{
	printf("EXIT exits the simulator and returns you to the command language.\n");
	}
if (same("go",sub))
	{
	printf("GO starts executing a hector program at the location specified.\n");
	printf("\n");
	printf("go <loc>    start executing at loc.\n");
	}
if (same("help",sub))
	{
	printf("HELP allows access to this help session.\n");
	}
if (same("ld",sub))
	{
	printf("LoaD loads a file from hard disk or floppy disk.\n");
	printf("\n");
	printf("ld <file>   loads ASCII hex file (\".lod\" file\n");
	printf("            produced by the 68000 assembler)\n");
	printf("            into memory.\n");
	}
if (same("md",sub))
	{
	printf("Memory Display allows you to view the contents of a set of\n");
	printf("memory locations.");
	printf("\n");
	printf("md <start> <stop> displays locations between start and stop\n");
	printf("            inclusive. If only a start value is specifed then\n");
	printf("            only that location will be displayed.\n");
	}
if (same("refresh",sub))
	{
	printf("refresh     updates the register set and other\n");
	printf("            on-screen information (such as port registers, SR,\n");
	printf("            and cycles.\n");
	}
if (same("trace",sub))
	{
	printf("trace       turn on trace mode.\n");
	printf("            this activates trace mode while running\n");
	printf("            a program.\n");
	}
if (same("sstep",sub))
	{
	printf("sstep       turns on single stepping mode.\n");
	printf("            this makes the 'go' command run only\n");
	printf("            one instruction at a time.\n");
	}
if (same("ssoff",sub))
	{
	printf("ssoff       turns off single stepping mode.\n");
	printf("            this makes the 'go' command run\n");
	printf("            instructions until one of the following\n");
	printf("            of the following conditions occur :\n");
	printf("               1. the processor encounters a breakpoint,\n");
	printf("               2. an exception condition occurs.\n");
	}
if (same("troff",sub))
	{
	printf("troff       turns off trace mode.\n");
	printf("            this deactivates trace mode while running\n");
	printf("            a program.\n");
	}
if (same("version",sub))
	{
	printf("version     displays the current version number of the simulator.\n");
	}
if (same("ex_on",sub))
	{
	printf("ex_on       enables true exception processing simulation.\n");
	printf("            in this mode, the simulator will respond to\n");
	printf("            exception processing situations as explained under\n");
	printf("            the heading 'EXCeption processing' in the help menu.\n");
	}
if (same("ex_off",sub))
	{
	printf("ex_off      disables true exception processing simulation.\n");
	printf("            this allows easier debugging of programs without\n");
	printf("            the simulator going off to an exception-handling\n");
	printf("            routine if you make a programming mistake.\n");
	}

	at (7,12);
	if (gets(lbuf,80)==NULL)
		exit(0);
	wcount = scan(lbuf,wordptr,10);
	sub = wordptr[0];
	}

return SUCCESS;

}


