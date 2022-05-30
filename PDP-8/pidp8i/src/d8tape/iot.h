
/*
 *	iot.h
 *
 *	(C) Copyright 2003 by Robert Krten, all rights reserved.
 *	Please see the LICENSE file for more information.
 *
 *	This module contains the IOT decode table.
 *
 *	2003 12 16	R. Krten		created
*/

/*
 *	Conflicting decodes for IOTs
 *
 *	6050 - 6077		VC8I or KV8I; one only
 *	6440 - 6457		PT08 uses some of the data areas from the Data Communications System 680/I -- definition of PT08 is optional
 *	6530 - 6547		AF01A or AF04A; one only
 *	6551			used by AA01A, AA05, or not used.  Define zero or one only.
 *	6571			used by AF04A, AC01A, or not used.  Define zero or one only.
 *	6600 - 6667		used by DP01AA, overrides DF32/RF08 selection.  If defining DP01AA, don't bother with DF32/RF08
 *	6600 - 6627		used by DF32 and RF08, define one only.
 *	6640 - 6647		used by RF08 or not used, define RF08 or not.
 *	6700 - 6727		used by TC58, TR02, and TA8A, define one only
*/

// Select one of the following:
#define	VC8I
//#define	KV8I

// Select PT08 if required; it will override some of the IOTs from the Data Communications System 680/I
//#define PT08

// Select one of the following:
#define	AF01A
//#define	AF04A

// Select one of the following:
#define	AA01A
//#define AA05

// If selecting DP01AA, don't bother with DF32/RF08
//#define	DP01AA
#ifndef	DP01AA
// Select one of the following:
#define	DF32
// #define RF08
#endif	// DP01AA

// Select one of the following:
#define	TA8A
//#define TC58
//#define TR02

typedef struct
{
	int		code;				// code number, e.g. 06001
	char	*option;			// hardware option, e.g., vc8i
	char	*mnemonic;			// decoded value, e.g., "ION"
	char	*comment;			// code description of IOT, e.g., "clear x coordinate buffer"
}	one_iot_t;

#define	OP_ALL		""
one_iot_t iots [] =
{
	// 6000			Interrupts
{	06001,		OP_ALL,		"ION",		"Enable Interrupts"},
{	06002,		OP_ALL,		"IOF",		"Disable Interrupts"},
	// 6010			High Speed Perforated Tape Reader and Control
{	06011,		OP_ALL,		"RSF",		"Skip if reader flag is a 1."},
{	06012,		OP_ALL,		"RFB",		"Read the content of the reader buffer and clear the reader flag. This instructions does not clear the AC.  RB v AC4-11 -> AC4-11"},
{	06014,		OP_ALL,		"RFC",		"Clear reader flag and reader buffer, fetch one character from tape and load it into the reader buffer, and set the reader flag when done."},
	// 6020			High Speed Perforated Tape Punch and Control
{	06021,		OP_ALL,		"PSF",		"Skip if punch flag is a 1"},
{	06022,		OP_ALL,		"PCF",		"Clear punch flag and punch buffer."},
{	06024,		OP_ALL,		"PPC",		"Load the punch buffer from bits 4 through 11 of the AC and punch the character.  This instructions does not clear the punch flag or punch buffer.  AC4-11 v PB -> PB"},
{	06026,		OP_ALL,		"PLS",		"Clear the punch flag, clear the bunch buffer, load the punch buffer from the content of bits 4 through 11 of the accumulator, punch the character, and set the punch flag to 1 when done."},
	// 6030			Teletype Keyboard / Reader
{	06031,		OP_ALL,		"KSF",		"Skip if keyboard flag is a 1."},
{	06032,		OP_ALL,		"KCC",		"Clear AC and clear keyboard flag."},
{	06034,		OP_ALL,		"KRS",		"Read keyboard buffer static. This is a static command in that neither the AC nor the keyboard flag is cleared.  TTI v AC4-11 -> AC4-11"},
{	06036,		OP_ALL,		"KRB",		"Clear AC, clear keyboard flag, and read the content of the keyboard buffer into the content of AC4-11."},
	// 6040			Teletype Teleprinter / Punch
{	06041,		OP_ALL,		"TSF",		"Skip if teleprinter flag is a 1."},
{	06042,		OP_ALL,		"TCF",		"Clear teleprinter flag."},
{	06044,		OP_ALL,		"TPC",		"Load the TTO from the content of AC4-11 and print and/or punch the character."},
{	06046,		OP_ALL,		"TLS",		"Load the TTO from the content of AC4-11, clear the teleprinter flag, and print and/or punch the character."},
#ifdef	VC8I
	// 6050			Oscilloscope Display Type VC8/I [VC8/L]
{	06051,		OP_ALL,		"DCX",		"Clear X coordinate buffer"},
{	06053,		OP_ALL,		"DXL",		"Clear and load X coordinate buffer.  AC2-11 -> YB"},
{	06054,		OP_ALL,		"DIX",		"Intensify the point defined by the content of the X and Y coordinate buffers."},
{	06057,		OP_ALL,		"DXS",		"Executes the combined functions of DXL followed by DIX"},
	// 6060			(continued)
{	06061,		OP_ALL,		"DCY",		"Clear Y coordinate buffer"},
{	06063,		OP_ALL,		"DYL",		"Clear and load Y coordinate buffer.  AC2-11 -> YB"},
{	06064,		OP_ALL,		"DIY",		"Intensify the point defined by the content of the X and Y coordinate buffers."},
{	06067,		OP_ALL,		"DYS",		"Executes the combined functions of DYL followed by DIY"},
	// 6070			(continued)
{	06071,		OP_ALL,		"DSF",		"(Light Pen Type 370) Skip if display flag is a 1."},
{	06072,		OP_ALL,		"DCF",		"(Light Pen Type 370) Clear the display flag."},
{	06074,		OP_ALL,		"DSB",		"Zero brightness"},
{	06075,		OP_ALL,		"DSB",		"Set minimum brightness"},
{	06076,		OP_ALL,		"DSB",		"Set medium brightness"},
{	06077,		OP_ALL,		"DSB",		"Set maximum brightness"},
#endif
#ifdef	KV8I
	// 6050			Storage Tube Display Control, Type KV8/I [KV8/L]
{	06051,		OP_ALL,		"SNC",		"Senses the condition of the cursor interrupt flag.  The flag produces an interrupt request when set by operation of the interrupt pushbutton on the joystick.  The flag is initially cleared when the computer is started.  As with all flag-sent instructions, SNC can be used under interrupt conditions to detect the source of the interrupt, or it can be used under interrupt on (ION) when the interrupt request has been caused by the operation of thecursor interrupt button.  In a program running with the interrupt off, SNC can be used to ignore the cursor successive approximation subroutine in the program if a request for service has not been made from the joystick controller."},
{	06052,		OP_ALL,		"CCF",		"This instruction is used to clear the cursor flag after a request for service has been acknowledged by the program."},
	// 6060			(continued)
{	06062,		OP_ALL,		"SAC",		"The analog comparator is set to compare the analog content of any one of six analog sources with the content of the digital-to-analog converter.  The analog sources are chosen according to a 3-bit binary code.  This code establishes the parameter for choosing the wanted register according to the content of AC2, AC3, and AC6."},
{	06063,		OP_ALL,		"LDF",		"This instruction is used to establish the mode in which a wanted graphic is to be produced according to a 2-bit binary code.  This code determines whether the wanted vector will be linear absolute relative, whether the point plot mode will be used, or whether the cursor will be displayed.  This code establishes the paramteres for these formats according to the content of AC2 and AC3.  The LDF instruction must precede the LDX and LDY instructions."},
{	06064,		OP_ALL,		"LDX",		"The X-axis sample and hold register is loaded with the binary equivalent of the X-axis coordinate according to the contents of AC2-11.  This data appears at the output of the digital-to-analog converter as the analog equivalent of the X-axis value of the binary word stored in the AC.  The LDX instruction clears an existing ready flag and sets the ready flag after 100 +/- 20 us."},
{	06065,		OP_ALL,		"LDY",		"The Y-axis sample and hold register is loaded with the binary equivalent of the Y-axis coordinate according to the contents of AC2-11.  This data appears at the output of the digital-to-analog converter as the analog equivalent of the binary word in the AC.  The LDY instruction clears an existing ready flag and sets the ready flag after 100 +/- 20 us."},
{	06066,		OP_ALL,		"EXC",		"Used to execute the wanted vector according to the contents of AC2-4 and AC6-11.  The parameter word establishes long or short formats, circular vectors, display erasure, reset of the integrators, and intensification of the vector.  The EXC instruction clears an existing ready flag and sets the ready flag as follows:  a) after 20 +/- 5 us for a point or vector continue; b) after 250 us for short vectors; c) after 4.05 ms for long vectors; d) after 500 ms for an erase."},
	// 6070			(continued)
{	06071,		OP_ALL,		"SRF",		"Used to determine when the controller is ready to perform the next execute instruction.  The ready flag produces an interrupt condition when set.  The flag can be set by pressing the erase pushbutton on the VT01 unit.  Normally, however, the state of this flag is determined by the controller.  This flag is initially cleared when the computer is started and prior to an LDX, LDY, or EXC instruction."},
{	06072,		OP_ALL,		"CRF",		"This instruction clears the ready flag after a skip instruction has been acknowledged."},
{	06073,		OP_ALL,		"SDA",		"Used in the successive approximation subroutine to determine the digital equivalent of the selected analog holding register.  This instruction is used with the SAC (6062) instruction."},
{	06074,		OP_ALL,		"LDA",		"This instruction is used to load the content of AC2-11.  This instruction is used with DSA (6073) in the successive approximation subroutine to determine the digital value of the content of the selected analog holding register.  Does not change flag states."},
#endif
	// 6100			Memory Parity Type MP8/I [MP8/L]
	// 6100			Automatic Restart Type KP8/I [KP8/L]
{	06101,		OP_ALL,		"SMP",		"(MP8/I) Skip if memory parity error flag = 0."},
{	06102,		OP_ALL,		"SPL",		"(KP8/I) Skip if power low"},
{	06104,		OP_ALL,		"CMP",		"(MP8/I) Clear memory parity error flag."},
	// 6110			Multiple Asynchronous Serial Line Interface Unit, Type DC02D
{	06111,		OP_ALL,		"MKSF",		"Skip the next instruction if the keyboard flag is set."},
{	06112,		OP_ALL,		"MKCC",		"Clear the keyboard and reader flags; clear the AC."},
{	06113,		OP_ALL,		"MTPF",		"(DC02A) Transfer status of teleprinter flags to AC 0-3."},
{	06114,		OP_ALL,		"MKRS",		"Transfer the shift register contents to AC 4-11."},
{	06115,		OP_ALL,		"MINT",		"(DC02A) Interrupt on if AC 11 is set (interrupt request, if any flags)."},
{	06116,		OP_ALL,		"MKRB",		"Clear the keyboard and reader flags, clear the AC, trasnfer the shift register contents to AC 4-11 (MKCC and MKRS combined)."},
{	06117,		OP_ALL,		"MTON",		"Transfer AC0-3 to selection register (SELF) (select stations when bit is set)."},
	// 6120			Multiple Asynchronous Line Unit, Type DC02A
{	06121,		OP_ALL,		"MTSF",		"Skip the next instruction if the teleprinter flag is set."},
{	06122,		OP_ALL,		"MTCF",		"Clear the teleprinter flag."},
{	06123,		OP_ALL,		"MTKF",		"Transfer status of keyboard flags to AC 0-3."},
{	06124,		OP_ALL,		"MTPC",		"Load AC4-11 into the shift register (begin print/punch)."},
{	06125,		OP_ALL,		"MINS",		"Skip if the interrupt request is active (if interrupt is on and any flag is raised)."},
{	06126,		OP_ALL,		"MTLS",		"Clear the teleprinter flag and load AC4-11 into the shift register (MTCF and MTPC combined)"},
{	06127,		OP_ALL,		"MTRS",		"Trasnfer the status of the selection register to AC 0-3."},
	// 6130			Real Time Clock, Type KW8/I [KW8/L]
{	06132,		OP_ALL,		"CCFF",		"The flag, flag buffer, clock enable, and interrupt enable flip-flops are cleared.  This disables the real-time clock."},
{	06133,		OP_ALL,		"CSCF",		"When the flag flip-flop has been set by a clock pulse, the flag buffer flip-flop is set to a 1.  Upon execution of this instruction, an IO BUS IN SKIP is generated if the flag is set.  The content of the PC is incremented by 1, so that the next sequential instruction is skipped.  The flag flip-flop is then cleared.  If the flag flip-flop has not been set, no skip is generated nor is the flag flip-flop cleared."},
{	06134,		OP_ALL,		"CRCA",		"The output buffer is gated to the I/O BUS during IOP4, and a CLK AC CLR signal generated.  This register contains the last count in the count register.  The transfer from the count register is synchronized with this instruction so that a transfer that would occur during this instruction is not made."},
{	06136,		OP_ALL,		"CCEC",		"All clock control flip-flops are first cleared, then the clock enable flip-flop is set.  For the variable frequency clock, the frequency source is enabled synchronously with program operation.  With all clocks, the data input to the flag is enabled after IOP2 time.  This represents an 800-ns mask, after the clock is enabled."},
{	06137,		OP_ALL,		"CECI",		"All clock control flip-flops are cleared, then the clock enable, and interrupt enable flip-flops are set.  The clock enable flip-flop is described with the CCEC instruction.  The interrupt enable flip-flop allows an IO BUS IN INT signal when the flag is set."},
	// 6140
	// 6150
	// 6160
	// 6170
	// 6200 through 6277	Memory Extension Control Type MC8/I [MC8/L]
{	06201,		OP_ALL,		"CDF0",		"Change to data field 0. The data field register is loaded with the selected field number (0).  All subsequent memory requests for operands are automatically switched to that data field until the data field number is changed by a new CDF command."},
{	06202,		OP_ALL,		"CIF0",		"Prepare to change to instruction field N (0).  The instruction buffer register is loaded with the selected field number (0).  The next JMP or JMS instruction causes the new field to be entered."},
{	06204,		OP_ALL,		"CINT",		"(KT8/I) Clear user interrupt.  Resets the user interrupt (UINT) flip-flop to the 0 state."},
	// 6210
{	06211,		OP_ALL,		"CDF0",		"Change to data field 1. The data field register is loaded with the selected field number (1).  All subsequent memory requests for operands are automatically switched to that data field until the data field number is changed by a new CDF command."},
{	06212,		OP_ALL,		"CIF0",		"Prepare to change to instruction field N (1).  The instruction buffer register is loaded with the selected field number (1).  The next JMP or JMS instruction causes the new field to be entered."},
{	06214,		OP_ALL,		"RDF",		"Read data field into AC6-8.  Bit 0-5 and 9-11 of the AC are not affected."},
	// 6220
{	06221,		OP_ALL,		"CDF0",		"Change to data field 2. The data field register is loaded with the selected field number (2).  All subsequent memory requests for operands are automatically switched to that data field until the data field number is changed by a new CDF command."},
{	06222,		OP_ALL,		"CIF0",		"Prepare to change to instruction field N (2).  The instruction buffer register is loaded with the selected field number (2).  The next JMP or JMS instruction causes the new field to be entered."},
{	06224,		OP_ALL,		"RIF",		"Same as RDF except reads the instruction field"},
	// 6230
{	06231,		OP_ALL,		"CDF0",		"Change to data field 3. The data field register is loaded with the selected field number (3).  All subsequent memory requests for operands are automatically switched to that data field until the data field number is changed by a new CDF command."},
{	06232,		OP_ALL,		"CIF0",		"Prepare to change to instruction field N (3).  The instruction buffer register is loaded with the selected field number (3).  The next JMP or JMS instruction causes the new field to be entered."},
{	06234,		OP_ALL,		"RIB",		"Read interrupt buffer.  The instruction field and data field stored during an interrupt are read into AC6-8 and AC9-11, respectively."},
	// 6240
{	06241,		OP_ALL,		"CDF0",		"Change to data field 4. The data field register is loaded with the selected field number (4).  All subsequent memory requests for operands are automatically switched to that data field until the data field number is changed by a new CDF command."},
{	06242,		OP_ALL,		"CIF0",		"Prepare to change to instruction field N (4).  The instruction buffer register is loaded with the selected field number (4).  The next JMP or JMS instruction causes the new field to be entered."},
{	06244,		OP_ALL,		"RMF",		"Restore memory field.  Used to exit from a program interrupt."},
	// 6250
{	06251,		OP_ALL,		"CDF0",		"Change to data field 5. The data field register is loaded with the selected field number (5).  All subsequent memory requests for operands are automatically switched to that data field until the data field number is changed by a new CDF command."},
{	06252,		OP_ALL,		"CIF0",		"Prepare to change to instruction field N (5).  The instruction buffer register is loaded with the selected field number (5).  The next JMP or JMS instruction causes the new field to be entered."},
{	06254,		OP_ALL,		"SINT",		"(KT8/I) Skip on user interrupt.  When the user interrupt (UINT) flip-flop is in the 1 state, sets the user skip flip-flop (USF) to the 1 state and causes the program to skip the next instruction."},
	// 6260
{	06261,		OP_ALL,		"CDF0",		"Change to data field 6. The data field register is loaded with the selected field number (6).  All subsequent memory requests for operands are automatically switched to that data field until the data field number is changed by a new CDF command."},
{	06262,		OP_ALL,		"CIF0",		"Prepare to change to instruction field N (6).  The instruction buffer register is loaded with the selected field number (6).  The next JMP or JMS instruction causes the new field to be entered."},
{	06264,		OP_ALL,		"CUF",		"(KT8/I) Clears the user flag.  Clears the user buffer (UB) flip-flop."},
	// 6270
{	06271,		OP_ALL,		"CDF0",		"Change to data field 7. The data field register is loaded with the selected field number (7).  All subsequent memory requests for operands are automatically switched to that data field until the data field number is changed by a new CDF command."},
{	06272,		OP_ALL,		"CIF0",		"Prepare to change to instruction field N (7).  The instruction buffer register is loaded with the selected field number (7).  The next JMP or JMS instruction causes the new field to be entered."},
{	06274,		OP_ALL,		"SUF",		"(KT8/I) Sets the user flag.  Sets user buffer (UB) and inhibits processor interrupts until the next JMP or JMS instruction.  Generation of IB -> IF during the next JMP or JMS instruction transfers the state of UB to the user field (UF) flip-flop."},
	// 6400			Data Communications System 680/I
{	06401,		OP_ALL,		"TTINCR",	"This instruction causes the contents of the line register to be incremented by 1.  This command, when microprogrammed with a TTO command is executed."},
{	06402,		OP_ALL,		"TTI",		"Causes a JMS to be executed (N+3) if the R register does not equal 0 and either the line hold bit of the selected line (specified by bits 2-8 of the LSW) is in the 1 state, or as a result of jamming the line state into and shifting the CAW; bit 11 of the CAW is a 1."},
{	06404,		OP_ALL,		"TTO",		"Clears the link and shifts the link and accumulator one bit position to the right.  Bit 11 of the accumulator is shifted into the line unit specified by the line register.  The previuos contents (1 bit) of the selected line unit is lost."},
	// 6410
{	06411,		OP_ALL,		"TTCL",		"The command sets the contents of the line register to 0."},
{	06412,		OP_ALL,		"TTSL",		"The contents of AC5-11 are ORed into the line register."},
{	06413,		OP_ALL,		"TTLL",		"The contents of AC5-11 are trasnferred into the line register.  This is a microprogram of TTCL and TTSL."},
{	06414,		OP_ALL,		"TTRL",		"The contents of the line register are ORed into AC5-11.  The AC must be 0 for a true transfer."},
	// 6420
{	06421,		OP_ALL,		"T1skip",	"(Data Communications System 680/I) Clock Control Instruction:  Causes the program to skip the next instruction if clock flag 1 is in the 1 state.  To clear the flag, either T1on or T1off can be used."},
{	06422,		OP_ALL,		"T1off",	"(Data Communications System 680/I) Clock Control Instruction:  Inhibits clock 1 from setting its flag.  This instruction also sets the flag to the 0 state."},
{	06424,		OP_ALL,		"T1on",		"(Data Communications System 680/I) Clock Control Instruction:  Enables clock 1 to set its flag at the predetermined lcock rate.  The flag in the 1 state causes a program interrupt when the interrupt is enabled.  This instruction also sets the flag to the 0 state."},
	// 6430
{	06431,		OP_ALL,		"T2skip",	"(Data Communications System 680/I) same as T1skip except for clock 2"},
{	06432,		OP_ALL,		"T2off",	"(Data Communications System 680/I) same as T1off except for clock 2"},
{	06434,		OP_ALL,		"T2on",		"(Data Communications System 680/I) same as T1on except for clock 2"},
#ifdef	PT08
	// 6440			Asynchronous Serial Line Interface, Type PT08
{	06441,		OP_ALL,		"TSFXXX",		"Skip if teleprinter/punch 3 flag is a 1."},
{	06442,		OP_ALL,		"TCFXXX",		"Clear teleprinter/punch 3 flag."},
{	06444,		OP_ALL,		"TPCXXX",		"Load teleprinter 3 buffer (TTOX) with AC4-11 and print/punch the character."},
{	06446,		OP_ALL,		"TLSXXX",		"Load TTOX with AC4-11, 3 flag, print/punch the character and clear teleprinter/punch."},
{		"6450"},
{	06451,		OP_ALL,		"KSFXXX",		"Skip if keyboard/reader 3 flag is a 1."},
{	06452,		OP_ALL,		"KCCXXX",		"Clear AC and keyboard/reader 3 flag."},
{	06454,		OP_ALL,		"KRSXXX",		"Read keyboard/reader 3 buffer (TTI3) static.  TTI3 is loaded into AC4-11 by an OR transfer."},
{	06456,		OP_ALL,		"KRBXXX",		"Clear the AC, read TTI3 into AC4-11, and clear keyboard 3 flag."},
{#else		"PT08"},
{	06441,		OP_ALL,		"T3skip",		"(Data Communications System 680/I) same as T1skip except for clock 3"},
{	06442,		OP_ALL,		"T3off",		"(Data Communications System 680/I) same as T1off except for clock 3"},
{	06444,		OP_ALL,		"T3on",		"(Data Communications System 680/I) same as T1on except for clock 3"},
{	06451,		OP_ALL,		"T4skip",		"(Data Communications System 680/I) same as T1skip except for clock 4"},
{	06452,		OP_ALL,		"T4off",		"(Data Communications System 680/I) same as T1off except for clock 4"},
{	06454,		OP_ALL,		"T4on",		"(Data Communications System 680/I) same as T1on except for clock 4"},
#endif
{	06461,		OP_ALL,		"TTRINC",		"(Data Communications System 680/I) This command causes the contents of the R register to be incremented by 1.  Because it is loaded with a 2's complement number, the result is a subtract.  This instruction can be microprogrammed with TTRR."},
{	06464,		OP_ALL,		"TTRR",		"(Data Communications System 680/I) This command reads the contents of the R register into AC7-11.  The contents of the AC must be 0s before issuing this instruction.  This instruction, when microprogrammed with TTINCR, causes the incremented results to be read into the AC."},
	// 6470
{	06471,		OP_ALL,		"TTCR",		"(Data Communications System 680/I) This command causes the R register to be set to 0"},
{	06472,		OP_ALL,		"TTLR",		"(Data Communications System 680/I) This command causes the contents of AC7-11 to be trasnferred into the R register."},
	// 6500			Incremental Plotter and Control Type VP8/I
{	06501,		OP_ALL,		"PLSF",		"Skip if plotter flag is a 1."},
{	06502,		OP_ALL,		"PLCF",		"Clear plotter flag."},
{	06504,		OP_ALL,		"PLPU",		"Plotter pen up.  Raise pen off of paper."},
	// 6510
{	06511,		OP_ALL,		"PLPR",		"Plotter pen right."},
{	06512,		OP_ALL,		"PLDU",		"Plotter drum (paper) upward"},
{	06514,		OP_ALL,		"PLDD",		"Plotter drum (paper) downward."},
	// 6520
{	06521,		OP_ALL,		"PLPL",		"Plotter pen left."},
{	06522,		OP_ALL,		"PLUD",		"Plotter drum (paper) upward. Same as 6512"},
{	06524,		OP_ALL,		"PLPD",		"Plotter pen down.  Lower pen on to paper."},
#ifdef	AF01A
	// 6530			General Purpose Converter and Multiplexer Control Type AF01A (this option is mutually exclusive with AF04A)
{	06531,		OP_ALL,		"ADSE",		"Skip if A/D converter flag is a 1."},
{	06532,		OP_ALL,		"ADCV",		"Clear A/D converter flag and convert input voltage to a digital number, flag will set to 1 at end of conversion.  Number of bits in converted number determined by switch setting, 11 bits maximum."},
{	06534,		OP_ALL,		"ADRB",		"Read A/D converter buffer into AC, left justified, and clear flag."},
	// 6540
{	06541,		OP_ALL,		"ADCC",		"Clear multiplexer channel address register."},
{	06542,		OP_ALL,		"ADSC",		"Set up multiplexer channel as per AC6-11.  Maximum of 64 single ended or 32 differntial input channels."},
{	06544,		OP_ALL,		"ADIC",		"Index multiplexer channel address (present address + 1).  Upon reaching address limit, increment will cause channel 00 to be selected."},
#endif	// AF01A
#ifdef	AF04A
	// 6530			Guarded Scanning Digital Voltmeter Type AF04A (this option is mutually exclusive with AF01A)
{	06531,		OP_ALL,		"VSDR",		"Skip if data ready flag is a 1."},
{	06532,		OP_ALL,		"VRD",		"Selected byte of voltmeter is transferred to the accumulator and the data ready flag is cleared."},
{	06534,		OP_ALL,		"VBA",		"BYTE ADVANCE command requests next twelve bits, data ready flag is set."},
	// 6540
{	06541,		OP_ALL,		"VCNV",		"The contents of the accumulator are transferred to the AF04A channel address register.  Analog signal on selected channel is automatically digitized."},
{	06542,		OP_ALL,		"VSEL",		"The contents of the accumulator are transferred to the AF04A control register."},
{	06544,		OP_ALL,		"VINX",		"The last channel address is incremented by one and the analog signal on the selected channel is automatically digitized."},
#endif	// AF04A
	// 6550
#ifdef	AA01A
{	06551,		OP_ALL,		"DAL1",		"(AA01A) The character in the accumulator is loaded into the channel 1 buffer.  The DAC then converts the buffered value to the analog equivalent.  NOTE: Similar instructions for DAL2 and DAL3 load respective DACs."},
#else	// AA01A
#ifdef	AA05
{	06551,		OP_ALL,		"CLDA",		"The address register in the AA05/AA07 is cleared."},
#else	// AA05
#endif	// AA05
#endif	// AA01A
{	06552,		OP_ALL,		"LDAD",		"(AA05/AA07) The address register in the AA05/AA07 is loaded with the contents of AC0-5."},
	// 6560
{	06562,		OP_ALL,		"LDAR",		"(AA05/AA07) The buffer (input buffer, if the channel is double-buffered) of the DAC is loaded from AC0-9."},
{	06564,		OP_ALL,		"UPDT",		"(AA05/AA07) The contents of the input buffers of all double-buffered channels are trasnferred to their respective output buffers.  The input buffer is not affected by this instruction."},
	// 6570
#ifdef	AF04A
{	06571,		OP_ALL,		"VSCC",		"SAMPLE CURRENT CHANNEL when required to digitize analog signal on current channel repeatedly (AF04A)"},
#else	// AF04A
#ifdef	AC01A
{	06571,		OP_ALL,		"HRAN",		"The contents of AC3-5 are trasnferred to the channel address register (CHAR).  The 3-bit code is decoded to address any of the 8 channels."},
#else	// AC01A
#endif	// AC01A
#endif	// AF04A
#ifdef	AC01A
{	06572,		OP_ALL,		"HSIM",		"Simultaneously places all 8 channels into the hold mode."},
#else	// AC01A
#endif	// AC01A
{	06574,		OP_ALL,		"SAMP",		"(AA01A) Places all 8 channels into the sample (or track) mode."},
#ifdef	DP01AA
	// 6600			Synchronous Modem Interface, Type DP01AA
{	06601,		OP_ALL,		"TAC",		"Causes the contents of the AC (6, 7, 8, or 9 bits right-justified) to be transferred into the TB."},
{	06602,		OP_ALL,		"CTF",		"Resets the trasnmit flag.  If trasnmit active flag is set, CTF also causes the program to skip the next instruction."},
{	06604,		OP_ALL,		"CIM",		"Resets the transmit logic idle mode (IM) flip-flop."},
{	06611,		OP_ALL,		"STF",		"Causes the program to skip the next instruction if the transmit flag is in the 0 state.  When the transmit flag is in the 1 state, the trasnmit buffer register (TB) is ready to accept another character."},
{	06612,		OP_ALL,		"RRB",		"Transfers the contents of the receiver buffer (RB) (6, 7, 8, or 9 bits, right-justified) to the computer AC.  RRB also resets the receive flag."},
{	06614,		OP_ALL,		"SIM",		"Sets the transmit idle mode (IM) flip-flop."},
{	06621,		OP_ALL,		"SEF",		"Causes the program to skip the next instruction if the receive end flag is 0.  The receive end flag slip-flop is set when the receive logic has stopped receiving serial data from the communications equipment due to termination of th SERIAL CLOCK RECEIVE pulse train."},
{	06622,		OP_ALL,		"CEF",		"Clears the receive end flag"},
{	06624,		OP_ALL,		"SRE",		"Sets the ring enable (RE) flip-flop to a 1, which permits the ring flag to request a program interrupt."},
{	06631,		OP_ALL,		"SRI",		"Causes the program to skip the next instruction if the ring flag is 0.  The ring flag is set when a ring input is received."},
{	06632,		OP_ALL,		"CRF",		"Clears the ring flag."},
{	06634,		OP_ALL,		"STR",		"Sets the terminal read (TR) flip-flop to the 1 state.  This causes the terminal ready lead to the modem to be set on the ON state.  The state changes to OFF for CTR"},
{	06641,		OP_ALL,		"SSR",		"Causes the program to skip the next instruction if the data-set-ready lead from the modem is in the ON state."},
{	06642,		OP_ALL,		"CTR",		"Clears the terminal ready (TR) flip-flop (see STR)"},
{	06644,		OP_ALL,		"CRE",		"Clears the ring enable (RE) flip-flop."},
{	06651,		OP_ALL,		"SRF",		"Causes the program to skip the next instruction if the receive flag is 0.  The flag is set when a received character is ready for trasnfer to the AC and the flag is cleared when an RRB instruction is issued."},
{	06652,		OP_ALL,		"CRA",		"Clears the receive active (RA) flip-flop, taking the receive logic out of the active state.  This inhibits any more receive flags until a new sync character is received."},
{	06654,		OP_ALL,		"XOB",		"Causes an exclusive OR of the AC with the buffer register (BR)."},
{	06661,		OP_ALL,		"COB",		"Clears the XOR buffer."},
{	06662,		OP_ALL,		"ROB",		"Transfers the buffer register (BR) content to the AC."},
{	06664,		OP_ALL,		"IOB",		"Transfers 1s from the AC to the buffer register (BR)."},
#else	// DP01AA
#ifdef	DF32
	// 6600			Random Access Disc File (type DF32)
{	06601,		OP_ALL,		"DCMA",		"Clears memory address register, parity erorr and completion flags.  This instruction clears the disk memory request flag and interrupt flags."},
{	06603,		OP_ALL,		"DMAR",		"The contents of the AC are loaded into the disk memory address register and the AC is cleared.  Begin to read information from the disk into the specified core location.  Clears parity error and completion flags.  Clears interrupt flags."},
{	06605,		OP_ALL,		"DMAW",		"The contents of the AC are loaded into the disk memory address register and the AC is cleared.  Begin to write information into the disk from the specified core location.  Clears parity error and completion flags."},
	// 6610
{	06611,		OP_ALL,		"DCEA",		"Clears the disk extended address and memory address extension register."},
{	06612,		OP_ALL,		"DSAC",		"Skips next instruction if address confirmed flag is a 1.  AC is cleared."},
{	06615,		OP_ALL,		"DEAL",		"The disk extended-address extension registers are cleared and loaded with the track data held in the AC."},
{	06616,		OP_ALL,		"DEAC",		"Clear the AC then loads the contents of the disk extended-address register into the AC to allow program evaluation.  Skip next instruction if address confirmed flag is a 1."},
	// 6620
{	06621,		OP_ALL,		"DFSE",		"Skip next instruction if the completion flag is a 1.  Indicates data transfer is complete."},
{	06626,		OP_ALL,		"DMAC",		"Clear the AC then loads contents of disk memory address register into the AC to allow program evaluation."},
#endif	// DF32
#ifdef	RF08
	// 6600			Disk File and Control, Type RF08/Expander Disk File, Type RS08
	// 6610
{	06611,		OP_ALL,		"DCIM",		"Clear the disk interrupt enable and core memory address extension register."},
{	06615,		OP_ALL,		"DIML",		"Clear the interrupt enable and memory address extension register, then load the interrupt enable and memory address extension registers with data held in the AC.  Then clear the AC.  NOTE: Transfers cannot occur across memory fields.  Attempts to do so will cause the transfer to "wrap around" within the specified memory field."},
{	06616,		OP_ALL,		"DIMA",		"Clear the AC.  Then load the contents of the status register (STR) into the AC to allow program evaluation."},
	// 6620
{	06621,		OP_ALL,		"DFSE",		"Skip next instruction if there is a parity error, data request late, write lock status, or nonexistent disk flag set."},
{	06623,		OP_ALL,		"DISK",		"If either the error or data completion flag (or both) is set, the next instruction is skipped."},
#endif	// RF08
	// 6630			Card Reader and Control Type CR8/I [CR8/L] (see also 6670)
{	06631,		OP_ALL,		"RCSF",		"Generates an IOP pulse (IOP 1) to test the data-ready flag output.  If the data ready flag is 1, the next sequential program instruction is skipped."},
{	06632,		OP_ALL,		"RCRA",		"Generates an IOP pulse (IOP 2) to read the alphanumeric data at the control-logic buffer register and clear the data ready flag."},
{	06634,		OP_ALL,		"RCRB",		"Generates an IOP pulse (IOP 4) to read the BCD data at the control logic buffer register and clear the data ready flag."},
#ifdef	RF08
	// 6640
{	06641,		OP_ALL,		"DCXA",		"Clear the high order 8-bits of the disk address register (DAR)."},
{	06643,		OP_ALL,		"DXAL",		"Clear the high order 8 bits of the DAR.  Then load the DAR from data stored in the AC.  Then clear the AC."},
{	06645,		OP_ALL,		"DXAC",		"Clear the AC; then load the contents of the high order 8-bit DAR into the AC."},
{	06646,		OP_ALL,		"DMMT",		"For maintenance purposes only with the appropriate maintenance cable connections and the disk disconnected from the RS08 logic, the (given) standard signals may be generated by IOT 6646 and associated AC bits.  The AC is cleared and the maintenance register is initiated by issuing an IOT 6601 command."},
#else	// RF08
	// 6640
#endif	// RF08
	// 6650			Automatic Line Printer and Control Type 645
{	06651,		OP_ALL,		"LSE",		"Skip if line printer error flag is a 1."},
{	06652,		OP_ALL,		"LCB",		"Clear both sections of the printing buffer."},
{	06654,		OP_ALL,		"LLB",		"Load printing buffer from the content of AC6-11 and clear the AC"},
	// 6660			Automatic Line Printer and Control Type 645 (continued)
{	06661,		OP_ALL,		"LSD",		"Skip if the printer done flag is a 1."},
{	06662,		OP_ALL,		"LCF",		"Clear line printer done and error flags."},
{	06664,		OP_ALL,		"LPR",		"Clear the format register, load the format register from the content of AC9-11, print the line contained in the section of the printer buffer loaded last, clear the AC, and advance the paper in accordance with the selected channel of the format tape if the content of AC8=1.  If the content of AC8=0, the line is printed and paper advance is inhibited."},
#endif	// DP01AA
	// 6670			Card Reader and Control Type CR8/I [CR8/L] (see also 6630)
{	06671,		OP_ALL,		"RCSD",		"Generates an IOP pulse (IOP 1) to test the card-done flag output.  If the card done flag is 1, the next sequential program instruction is skipped."},
{	06672,		OP_ALL,		"RCSE",		"Generates an IOP pulse (IOP 2) to advance the card, clear the card done flag, and produce a skip flag is reader is ready.  If skip flag is generated, the next sequential program instruction is skipped."},
{	06674,		OP_ALL,		"RCRD",		"Generates an IOP pulse (IOP 4) to clear the card done flag."},
#ifdef	TA8A
	// 6700 -> 6707	TU60 DECassette Controller TA8A
{	06700,		OP_ALL,		"KCLR",		"Clear All; clear the status A and B register"},
{	06701,		OP_ALL,		"KSDR",		"Skip the next instruction if the data flag is set during read or write operations"},
{	06702,		OP_ALL,		"KSEN",		"Skip the next instruction if any of the following are true:  a) tape is at EOT/BOT, b) the TU60 is not ready or the selected drive is empty"},
{	06703,		OP_ALL,		"KSBF",		"Skip the next instruction if the ready flag is set"},
{	06704,		OP_ALL,		"KLSA",		"Load status A from AC4-AC11, clear the AC, and load the complement of status A back into the AC"},
{	06705,		OP_ALL,		"KSAF",		"Skip on any flag or error condition"},
{	06706,		OP_ALL,		"KGOA",		"Assert the contents of the status A register and transfer data into the AC during a read operation or out of the AC to the Read/Write buffer during a write operation.  This instruction has three functions:  a) enables the command in the status A register to be executed by the TU60, b) for read operations, the first KGOA instruction causes the tape to start moving, and when the data flag sets, a second KGOA transfers the first byte from the read/write buffer to the AC.  The data flag sets after each 8-bit byte is read from the TU60. c) for write operations, the status A register is set up for a write, and the AC contains the first byte to be written on tape.  When the KGOA instruction is executed, the tape starts to move and the first byte is transferred to the TU60."},
{	06707,		OP_ALL,		"KRSB",		"Transfer the contents of the status B register into AC4-AC11."},
#endif
#ifdef	TC58
	// 6700			Automatic Magnetic Tape Control Type TC58
{	06701,		OP_ALL,		"MTSF",		"Skip on error flag or magnetic tape flag.  The status of the error flag (EF) and the magnetic tape flag (MTF) are sampled.  If either or both are set to 1, the content of the PC is incremented by one to skip the next sequential instruction."},
{	06702,		OP_ALL,		"6702",		"(no mnemonic assigned) Clear the accumulator."},
{	06704,		OP_ALL,		"6704",		"(no mnemonic assigned) Inclusively OR the contents of the status register into AC0-11"},
{	06706,		OP_ALL,		"MTRS",		"Read the contents of the status register into AC0-11."},
	// 6710
{	06711,		OP_ALL,		"MTCR",		"Skip on tape control ready (TCR).  If the tape control is ready to receive a command, the PC is incremented by one to skip the next sequential instruction."},
{	06712,		OP_ALL,		"MTAF",		"Clear the status and command registers, and the EF and MTF if tape control ready.  If tape control not ready, clears MTF and EF flags only."},
{	06714,		OP_ALL,		"MTCM",		"Inclusively OR the contents of AC0-5, AC9-11 into the command register; JAM transfer bits 6, 7, 8 (command function)"},
{	06716,		OP_ALL,		"MTLC",		"Load the contents of AC0-1j1 into the command register."},
	// 6720
{	06721,		OP_ALL,		"MTTR",		"Skip on tape transport ready (TTR).  The next sequential instruction is skipped if the tape transport is ready."},
{	06722,		OP_ALL,		"MTGO",		"Set "go" bit to execute command in the command register if command is legal."},
{	06724,		OP_ALL,		"MTRC",		"Inclusively OR the contents of the contents of the command register into AC0-11."},
#endif	// TC58
#ifdef	TR02
	// 6700			Incremental Magnetic Tape Controller, Type TR02
{	06701,		OP_ALL,		"IRS",		"When data is ready to be strobed into the AC from the read buffer (RB), the PC is incremented by one to skip the next sequential instruction.  The read done flag is cleared only if the skip occurs."},
{	06702,		OP_ALL,		"ISR",		"The content of the status register (STR) is read into AC0-8.  The AC should be cleared before it is read by this instruction."},
{	06703,		OP_ALL,		"IWS",		"If the write done flag is set, the next instruction is skipped and the write done flag is cleared."},
{	06704,		OP_ALL,		"IMC",		"The move command decoded from AC0-2 is generated.  This instruction also clears the read done, write done, and gap detect flags.  The indicated flag is set when the command has been executed."},
{	06705,		OP_ALL,		"IGS",		"If the gap detect flag is set, the next instruction is skipped and the gap detect flag is cleared."},
{	06706,		OP_ALL,		"IWR",		"The contents of the AC are loaded into the tape input data buffer (WB) and a write step command is generated.  The write done flag is set when writing is completed."},
{	06707,		OP_ALL,		"IRD",		"The AC is cleared and the content of the read buffer (RB) is loaded into the AC.  Data bits are transferred into AC6-11 (7-track) or AC4-11 (9-track).  Parity error is transferred into AC0 which is 0 if there is no parity error."},
	// 6710
{	06711,		OP_ALL,		"IRSA",		"When data is ready to be strobed into the AC from the read buffer (RB), the PC is incremented by one to skip the next sequential instruction.  The read done flag is cleared only if the skip occurs."},
{	06712,		OP_ALL,		"ISRA",		"The content of the status register (STR) is read into AC0-8.  The AC should be cleared before it is read by this instruction."},
{	06713,		OP_ALL,		"IWSA",		"If the write done flag is set, the next instruction is skipped and the write done flag is cleared."},
{	06714,		OP_ALL,		"IMCA",		"The move command decoded from AC0-2 is generated.  This instruction also clears the read done, write done, and gap detect flags.  The indicated flag is set when the command has been executed."},
{	06715,		OP_ALL,		"IGSA",		"If the gap detect flag is set, the next instruction is skipped and the gap detect flag is cleared."},
{	06716,		OP_ALL,		"IWRA",		"The contents of the AC are loaded into the tape input data buffer (WB) and a write step command is generated.  The write done flag is set when writing is completed."},
{	06717,		OP_ALL,		"IRDA",		"The AC is cleared and the content of the read buffer (RB) is loaded into the AC.  Data bits are transferred into AC6-11 (7-track) or AC4-11 (9-track).  Parity error is transferred into AC0 which is 0 if there is no parity error."},
	// 6720
#endif	// TC58
	// 6730
	// 6740
	// 6750
	// 6760			DECtape Transport Type TU55 and DECtape Control Type TC01
{	06761,		OP_ALL,		"DTRA",		"The content of status register A is read into AC0-9 by an OR transfer.  The bit assignments are:  AC0-2 = Transport unit select numnber; AC3-4 = Motion; AC5 = Mode; AC6-8 = Function; AC9 = Enable/disable DECtape control flag."},
{	06762,		OP_ALL,		"DCTA",		"Clear status register A.  All flags undisturbed."},
{	06764,		OP_ALL,		"DTXA",		"Status register A is loaded by an exclusive OR transfer from the content of the AC, and AC10 and AC11 are sampled.  If AC10 = 0, the error flags are cleared.  If AC11 = 0, the DECtape control flag is cleared."},
	// 6770
{	06771,		OP_ALL,		"DTSF",		"Skip if error flag is a 1 or if DECtape control flag is a 1."},
{	06772,		OP_ALL,		"DTRB",		"The content of status register B is read into the AC by an OR transfer.  The bit assignments are:  AC0 = Error flag; AC1 = Mark track error; AC2 = End of tape ; AC3 = Select error ; AC4 = Parity error; AC5 = Timing error; AC6-8 = Memory field; AC9-10 = Unused; AC11 = DECtape flag."},
{	06774,		OP_ALL,		"DTLB",		"The memory field portion of status register B is loaded from the content of AC6-8."},
};

