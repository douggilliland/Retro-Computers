
/*
 *	dasm.c
 *
 *	(C) Copyright 2003 by Robert Krten, all rights reserved.
 *	Please see the LICENSE file for more information.
 *
 *	This module contains the PDP-8 disassembler.
 *	Note that the 8/I and 8/L are featured at this point; other models
 *	should be added (particularly the 8/E's EAE instructions, as well
 *	as new IOT decodings, etc)
 *
 *	2003 12 16	R. Krten		created
 *	2007 10 29	R. Krten		added better output formatting
 *	2007 11 02	R. Krten		added xrefs
 *	2009 02 08	D. North		fixups for missing 7002 BSW and removal of
 *								7600 CLA case (conflicts with 7200 on reassembly)
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <errno.h>
#include <time.h>

#include "d8tape.h"
#include "iot.h"							// decode table for IOTs

extern	char	*progname;					// main.c
extern	char	*version;					// version.c

extern	int		optv;						// main.c
extern	char	*tapename;					// main.c, name of tape image

extern	short int	core [];				// main.c, in-core image (-1 means location never used)
extern	uint16_t	tags [];				// main.c, analysis tags
extern	segment_t	*segments;				// main.c, used to accumulate runs of data (from origin for nwords)
extern	int			nsegments;				// main.c, indicates how many segments we have

static void header (void);
static void disassemble_range (int start, int end);
static void pad (char *buf, int off, int pos);
static void xrefs (int addr);

/*
 *	dasm8
 *
 *	This takes the current address and the instruction value
 *	and prints the decoded instruction.  A static variable
 *	is used to kludge up 2-word instructions (e.g., MUY <const>).
 *
 *	The IOTs are coded in a table; in some cases, conflicts exist, you'll
 *	need to select the appropriate #defines to make them go away :-)
 *	As shipped, the #defines match my preferences.
 *
 *	Formatting rules:
 *		- the following types of output exist:
 *			- labels
 *			- banners
 *			- code
 *			- data
 *
 *	For each type, the following format is used (all tabs, as shown by the single backtick
 *	character, are assumed to be at 4 character tabstops.  If you don't like this, pipe
 *	the output through "expand -4").
 *
 *		Labels:
 *			          1111111111222222222233333333334444444444555555555566666666667777777777
 *			01234567890123456789012345678901234567890123456789012345678901234567890123456789
 *			t	t	t	t	t	t	t	t	t	t	t	t	t	t	t	t	t	t	t	t
 *			TAAAA,
 *
 *				where "T" is the label type, one of "D" for data, "L" for executable label,
 *				and "S" for subroutine entry, and "AAAA" is the four digit octal address.
 *				(See "Data" below for additional details of the "D" type).
 *
 *		Banners:
 *			          1111111111222222222233333333334444444444555555555566666666667777777777
 *			01234567890123456789012345678901234567890123456789012345678901234567890123456789
 *			t	t	t	t	t	t	t	t	t	t	t	t	t	t	t	t	t	t	t	t
 *			////////////////////////////////////////////////////////////////////////////////
 *			/
 *			/```CONTENT
 *			/
 *			////////////////////////////////////////////////////////////////////////////////
 *
 *				Where "CONTENT" is the content of the banner, e.g., "SUBROUTINE S1234".
 *
 *		Code:
 *			          1111111111222222222233333333334444444444555555555566666666667777777777
 *			01234567890123456789012345678901234567890123456789012345678901234567890123456789
 *			t	t	t	t	t	t	t	t	t	t	t	t	t	t	t	t	t	t	t	t
 *				op1`````````````````````/ COMMENTS..............................@@=AAAA,OOOO
 *				opc1````````````````````/ COMMENTS..............................@@=AAAA,OOOO
 *				op1 TAAAA```````````````/ COMMENTS..............................@@=AAAA,OOOO
 *				op1 I TAAAA`````````````/ COMMENTS..............................@@=AAAA,OOOO
 *				op1 op2 op3 op4 op5 op6`/ COMMENTS..............................@@=AAAA,OOOO
 *				12345678911234567892123   1234567891123456789212345678931234567		(DISLEN and COMLEN, resp.)
 *			01234567891123456789212345678 234567891123456789212345678931234567890	(COMSTART and DATASTART, resp.)
 *
 *				Where "op1", "opc1", "op2" through "op6" are 3 or 4 character mnemonic
 *				opcodes.  "T" is the label type (as above), and "AAAA" is the address.
 *				Tabs are used to fill whitespace to the "/" comment delimiter, and from the
 *				end of the comment to the @@.  The area at the "@@" indicates the address
 *				and the contents.
 *
 *				This is where the COMLEN and DISLEN buffer sizes are derived from, and the
 *				COMSTART position (28, the start of the "/")
 *
 *		Data:
 *			          1111111111222222222233333333334444444444555555555566666666667777777777
 *			01234567890123456789012345678901234567890123456789012345678901234567890123456789
 *			t	t	t	t	t	t	t	t	t	t	t	t	t	t	t	t	t	t	t	t
 *			CAAAA,``VVVV````````````````/ op1 op2 op3 op4 op5 op6 COMMENTS..................
 *			DAAAA,``VVVV````````````````/ op1 op2 op3 op4 op5 op6 COMMENTS..................
 *			KVVVV,``VVVV````````````````/ op1 op2 op3 op4 op5 op6 COMMENTS..................
 *
 *				Where "C" is used for constants whose values are not unique, "D" is used
 *				for writable data, and "K" is used for constants that can be added in the
 *				symbol table.  The distinction between "C" and "K" is that if two different
 *				memory locations both define the same constant value, we need to use "C"
 *				because it's tagged based on the address, whereas "K" is tagged based on
 *				the value.
 *
 *	Other types to consider are comment blocks imported from a control file.
*/

static const char *codes [6] = {"AND", "TAD", "ISZ", "DCA", "JMS", "JMP"};	// IOT and OPR are decoded elsewhere

static unsigned short int two_word = 0;		// set to hold two-word instruction (e.g., EAE ops), else zero (instruction 0, AND, is not a two-word instruction)

#define	COMLEN			37					// length of comment, see "Code", above (both the number of bytes and the max number of characters; tabs will only make the number of bytes less)
#define	DISLEN			23					// length of disassembly area, see "Code" above (ditto)
#define	COMSTART		28					// 0-based column number where the comments start
#define	DATASTART		40					// 0-based column number where the data (@@=AAAA,OOOO) starts
static char disbuf [DISLEN + 1];
static char combuf [COMLEN + 1];

void
dasm8 (int addr, unsigned short int buf)
{
	int		ind, cur;
	int		eff_addr;
	int		primary;						// is primary disassembly 'c'ode or 'd'ata?

	if (optv > 1) {
		printf ("dasm8 (addr 0%04o word 0%04o tag 0x%04x)\n", addr, buf, tags [addr]);
	}

	eff_addr = ea (addr, buf, &ind, &cur);

	if (two_word) {
		printf ("\t%04o /\t\t\t\t\t / (operand)\n", buf);
		two_word = 0;
		return;
	}

	// prepare buffer areas for disassembly and comments.
	memset (disbuf, 0, sizeof (disbuf));
	memset (combuf, 0, sizeof (combuf));

	primary = 'c';							// default to code disassembly

	if (tags [addr] & TAG_LABEL) {
		printf ("L%04o,\n", addr);
	}

	if (tags [addr] & TAG_SUB) {
		printf ("\n");
		printf ("////////////////////////////////////////////////////////////////////////////////\n");
		printf ("/\n");
		printf ("/\tSUBROUTINE:  S%04o\n", addr);
		printf ("/\n");
		xrefs (addr);
		printf ("////////////////////////////////////////////////////////////////////////////////\n");
		printf ("S%04o,\n", addr);
		printf ("\t0\t\t\t\t\t\t/ return area\n");
		// done; can't be SUB and anything else (except label, perhaps)
		return;
	}

	if (tags [addr] & TAG_DATA) {
		// if it's data, set primary as data
		primary = 'd';
		if ((addr & 07770) == 00010) {	// addresses 0010 -> 0017 are autoindex
			printf ("AI%o,\t%04o\t\t\t\t/ AUTO-INDEX REGISTER", addr & 7, core [addr]);
		} else {
			if (tags [addr] & TAG_INDIRECTFC) {
				printf ("C%04o,\n", addr);
			}
			printf ("%c%04o,\t", tags [addr] & TAG_KONSTANT ? 'K' : tags [addr] & TAG_WRITABLE ? 'D' : 'C', tags [addr] & TAG_KONSTANT ? core [addr] : addr);
			printf ("%04o\t\t\t\t/", core [addr]);
		}
	}

	switch (buf & 07000) {
	case	00000:			// AND
	case	01000:			// TAD
	case	02000:			// ISZ
	case	03000:			// DCA
	case	04000:			// JMS
	case	05000:			// JMP
		sprintf (disbuf, "%s ", codes [buf >> 9]);

		if (ind) {
			strcat (disbuf, "I ");
		} else {
			strcat (disbuf, "  ");
		}

		if (tags [eff_addr] & TAG_SUB) {
			strcat (disbuf, "S");
		} else if (tags [eff_addr] & TAG_LABEL) {
			strcat (disbuf, "L");
		} else {
			if ((eff_addr & 07770) == 00010) {	// addresses 0010 -> 0017
				strcat (disbuf, "AI");
				strcat (combuf, "AUTO INDEX REGISTER");
			} else {
				strcat (disbuf, (tags [eff_addr] & TAG_KONSTANT) ? "K" : tags [eff_addr] & TAG_WRITABLE ? "D" : "C");
			}
		}

		if (tags [addr] & TAG_RETURN) {
			strcat (combuf, "return ");
		} else {
			// comment indirect flow control change to reflect ultimate target
			switch (buf & 07400) {
			case	04400:
				sprintf (combuf + strlen (combuf), "long call to S%04o ", core [eff_addr]);
				break;
			case	05400:
				sprintf (combuf + strlen (combuf), "long jump to L%04o ", core [eff_addr]);
				break;
			}
		}

		if ((eff_addr & 07770) == 00010) {		// address 0010 -> 0017
			sprintf (disbuf + strlen (disbuf), "%o ", eff_addr & 7);
		} else {
			sprintf (disbuf + strlen (disbuf), "%04o ", (tags [eff_addr] & TAG_KONSTANT) ? core [eff_addr] : eff_addr);
		}

		break;

	case	06000:			// IOT
		fetch_iot (buf, disbuf, combuf);
		break;

	case	07000:			// OPR
		// perform "short form" OPRs here first...
		switch (buf) {
			case	07000: sprintf (disbuf, "NOP");																		break;
			case	07002: sprintf (disbuf, "BSW");																		break;
			case	07041: sprintf (disbuf, "CIA");																		break;
			case	07120: sprintf (disbuf, "STL");																		break;
			case	07204: sprintf (disbuf, "GLK");																		break;
			case	07240: sprintf (disbuf, "STA");					strcat (combuf, "AC = 7777 (-0001)");				break;
			case	07300: sprintf (disbuf, "CLA CLL");				strcat (combuf, "AC = 0000");						break;
			case	07301: sprintf (disbuf, "CLA CLL IAC");			strcat (combuf, "AC = 0001");						break;
			case	07302: sprintf (disbuf, "CLA IAC BSW");			strcat (combuf, "AC = 0100 (64)");					break;
			case	07305: sprintf (disbuf, "CLA CLL IAC RAL");		strcat (combuf, "AC = 0002");						break;
			case	07325: sprintf (disbuf, "CLA CLL CML IAC RAL");	strcat (combuf, "AC = 0003");						break;
			case	07326: sprintf (disbuf, "CLA CLL CML RTL");		strcat (combuf, "AC = 0002");						break;
			case	07307: sprintf (disbuf, "CLA CLL IAC RTL");		strcat (combuf, "AC = 0004");						break;
			case	07327: sprintf (disbuf, "CLA CLL CML IAC RTL");	strcat (combuf, "AC = 0006");						break;
			case	07330: sprintf (disbuf, "CLA CLL CML RAR");		strcat (combuf, "AC = 4000 (-4000 = -2048 dec)");	break;
			case	07332: sprintf (disbuf, "CLA CLL CML RTR");		strcat (combuf, "AC = 2000 (1024)");				break;
			case	07333: sprintf (disbuf, "CLA CLL CML IAC RTL");	strcat (combuf, "AC = 6000 (-2000 = -1024 dec)");	break;
			case	07340: sprintf (disbuf, "CLA CLL CMA");			strcat (combuf, "AC = 7777 (-0001)");				break;
			case	07344: sprintf (disbuf, "CLA CLL CMA RAL");		strcat (combuf, "AC = 7776 (-0002)");				break;
			case	07346: sprintf (disbuf, "CLA CLL CMA RTL");		strcat (combuf, "AC = 7775 (-0003)");				break;
			case	07350: sprintf (disbuf, "CLA CLL CMA RAR");		strcat (combuf, "AC = 3777 (2047)");				break;
			case	07352: sprintf (disbuf, "CLA CLL CMA RTR");		strcat (combuf, "AC = 5777 (-2001 = -1025 dec)");	break;
			case	07401: sprintf (disbuf, "NOP");																		break;
			case	07410: sprintf (disbuf, "SKP");																		break;
			case	07600: sprintf (disbuf, "7600");				strcat (combuf, "AKA \"CLA\"");						break;
			case	07610: sprintf (disbuf, "SKP CLA");																	break;
			case	07604: sprintf (disbuf, "LAS");																		break;
			case	07621: sprintf (disbuf, "CAM");																		break;
			default:

				// determine group (0401 is 0000/0001 for group 1, 0400 for group 2, 0401 for EAE)
				switch (buf & 00401) {
				case	00000:	// group 1
				case	00001:	// group 1
					// sequence 1
					if (buf & 00200) {
						strcat (disbuf, "CLA ");
					}
					if (buf & 00100) {
						strcat (disbuf, "CLL ");
					}
					// sequence 2
					if (buf & 00040) {
						strcat (disbuf, "CMA ");
					}
					if (buf & 00020) {
						strcat (disbuf, "CML ");
					}
					// sequence 3
					if (buf & 00001) {
						strcat (disbuf, "IAC ");
					}
					// sequence 4
					if (buf & 00010) {
						if (buf & 00002) {
							strcat (disbuf, "RTR ");
						} else {
							strcat (disbuf, "RAR ");
						}
					}
					if (buf & 00004) {
						if (buf & 00002) {
							strcat (disbuf, "RTL ");
						} else {
							strcat (disbuf, "RAL ");
						}
					}
					break;

				case	00400:	// group 2
					// sequence 1
					if (buf & 00100) {
						if (buf & 00010) {
							strcat (disbuf, "SPA ");
						} else {
							strcat (disbuf, "SMA ");
						}
					}
					if (buf & 00040) {
						if (buf & 00010) {
							strcat (disbuf, "SNA ");
						} else {
							strcat (disbuf, "SZA ");
						}
					}
					if (buf & 00020) {
						if (buf & 00010) {
							strcat (disbuf, "SZL ");
						} else {
							strcat (disbuf, "SNL ");
						}
					}
					// sequence 2
					if (buf & 00200) {
						strcat (disbuf, "CLA ");
					}
					// sequence 3
					if (buf & 00004) {
						strcat (disbuf, "OSR ");
					}
					if (buf & 00002) {
						strcat (disbuf, "HLT ");
					}
					break;
				case	00401:	// EAE
					// sequence 1
					if (buf & 00200) {
						strcat (disbuf, "CLA ");
					}
					// sequence 2
					if (buf & 00100) {
						strcat (disbuf, "MQA ");
					}
					if (buf & 00040) {
						strcat (disbuf, "SCA ");
					}
					if (buf & 00020) {
						strcat (disbuf, "MQL ");
					}
					// sequence 3
					switch (buf & 00016) {
					case	0:		// no further ops, done
						break;
					case	002:
						strcat (disbuf, "SCL ");
						two_word = buf;
						break;
					case	004:
						strcat (disbuf, "MUY ");
						two_word = buf;
						break;
					case	006:
						strcat (disbuf, "DVI ");
						two_word = buf;
						break;
					case	010:
						strcat (disbuf, "NMI");
						break;
					case	012:
						strcat (disbuf, "SHL ");
						two_word = buf;
						break;
					case	014:
						strcat (disbuf, "ASR ");
						two_word = buf;
						break;
					case	016:
						strcat (disbuf, "LSR ");
						two_word = buf;
						break;
					}
					break;
				}
				break;
		}
		break;
	}
	if (two_word) {
		strcat (disbuf, "+");
	}
	// trim any trailing spaces
	while (*disbuf && disbuf [strlen (disbuf) - 1] == ' ') {
		disbuf [strlen (disbuf) - 1] = 0;
	}

	if (primary == 'c') {				// if primary is code, then spill data too
		pad (disbuf, 0, COMSTART - 4);	// add tabs to get disassembly to comment start (one tab less because we print it next)
		printf ("\t%s", disbuf);		// print disassembly so far
		printf ("/ ");					// print comment start
		pad (combuf, 2, DATASTART);		// pad comment buffer to get to data area
		printf ("%s@@%04o=%04o\n", combuf, addr, buf);	// print comment, address and opcode
	} else {							// else we've already spilled both, just terminate the line
		pad (disbuf, 2, DATASTART);
		printf (" %s", disbuf);
		printf ("\n");
		two_word = 0;					// we don't care that it's a two-word when we're printing it as data
	}
}

/*
 *	ea
 *
 *	Calculate the effective address given the
 *	address and opcode.  Opcodes that don't have
 *	an effective address (e.g., IOTs), return -1.
 *
 *	The indirect pointer is optional, and, if specified,
 *	will cause the location to be returned with a zero
 *	or one indicating indirection.  The indirect pointer
 *	is not modified in case of a non-EA opcode.
 *
 *	Similarly for the curpage pointer.
*/

int
ea (int addr, int opcode, int *indirect, int *curpage)
{
	int		eff_addr;
	int		c;
	int		i;

	if (opcode >= 06000) {			// IOTs and OPRs don't have an EA
		return (-1);
	}

	i = opcode & 00400;
	c = opcode & 00200;
	eff_addr = c ? (addr & 07600) + (opcode & 00177) : opcode & 00177;
	if (indirect) {
		*indirect = i;
	}
	if (curpage) {
		*curpage = c;
	}
	return (eff_addr);
}

/*
 *	disassemble
 *
 *	This drives disassembly once the flow analysis has been done.
 *
 *	We disassemle in segment order.
*/

void
disassemble (void)
{
	int		snum;

	header ();
	for (snum = 0; snum < nsegments; snum++) {
		printf ("\n*%04o\n", segments [snum].saddr);
		disassemble_range (segments [snum].saddr, segments [snum].saddr + segments [snum].nwords);
	}
}

static void
header (void)
{
	struct	tm *tm;
	time_t	now;
	int		nused, ndata, ncode;
	int		i;

	time (&now);
	tm = localtime (&now);

	nused = ndata = ncode = 0;
	for (i = 0; i < CORE_SIZE; i++) {
		if (core [i] >= 0) {
			nused++;
			if (tags [i] & TAG_DATA) {
				ndata++;
			} else {
				ncode++;
			}
		}
	}

	printf ("TITLE \"AUTOMATIC DISASSEMBLY OF %s BY D8TAPE\"\n", tapename);
	printf ("////////////////////////////////////////////////////////////////////////////////\n");
	printf ("/\n");
	printf ("/\tAutomatic Disassembly of %s\n", tapename);
	printf ("/\tGenerated %04d %02d %02d %02d:%02d:%02d\n", tm -> tm_year + 1900, tm -> tm_mon + 1, tm -> tm_mday, tm -> tm_hour, tm -> tm_min, tm -> tm_sec);
	printf ("/\tGenerated by d8tape version %s\n", version);
	printf ("/\tVisit http://www.pdp12.org/pdp8/software/index.html for updates\n");
	printf ("/\n");
	printf ("/\tSymbol format:\n");
	printf ("/\t\tAIx   -- Auto-index variables (address range 001x)\n");
	printf ("/\t\tCaaaa -- Constants (non-unique)\n");
	printf ("/\t\tDaaaa -- Data (read/write variables)\n");
	printf ("/\t\tKvvvv -- Program-wide unique constants\n");
	printf ("/\t\tLaaaa -- Labels for control flow targets\n");
	printf ("/\t\tSaaaa -- Subroutines\n");
	printf ("/\n");
	printf ("/\tWhere:\n");
	printf ("/\t\taaaa is the definition address\n");
	printf ("/\t\tvvvv is the value of the constant\n");
	printf ("/\t\tx    is the last digit of the address 001x for auto-index variables\n");
	printf ("/\n");
	printf ("/\t%04o locations used, %04o code and %04o data\n", nused, ncode, ndata);
	printf ("////////////////////////////////////////////////////////////////////////////////\n");
}

static void
disassemble_range (int start, int end)
{
	int		addr;

	for (addr = start; addr < end; addr++) {
		dasm8 (addr, core [addr]);
	}
}

/*
 *	fetch_iot
 *
 *	This function looks up in the iot table (iot.h) to find
 *	the opcode passed in "code" and updates the disassembled
 *	output "dis" and the comment "com".
 *
 *	More work needs to be done here for conflicting IOTs.
 *
 *	Current, I assume that there are no conflicts (actually, I
 *	return the first match, regardless of conflicts).  A command
 *	line / control file option needs to be created to allow
 *	the selection of devices.  Something like "-i vc8i", for example
 *	to allow the VC8/I IOTs to be enabled.
*/

int
fetch_iot (int code, char *dis, char *com)
{
	int		i;

	for (i = 0; i < sizeof (iots) / sizeof (iots [0]); i++) {
		if (code == iots [i].code) {
			if (dis) {
				strcpy (dis, iots [i].mnemonic);
			}
			if (com) {
				strncpy (com, iots [i].comment, COMLEN - 1);
			}
			return (1);
		}
	}
	if (dis) {
		sprintf (dis, "%04o", code);
	}
	if (com) {
		sprintf (com, "unknown IOT");
	}
	return (0);
}

/*
 *	pad
 *
 *	Figures out where the current print position is based on expanding
 *	the current tabs in "buf" and adds more tabs to get to "pos".
*/

static void
pad (char *buf, int loc, int pos)
{
	for (; *buf; buf++) {
		if (*buf == '\t') {
			if ((loc & 3) == 0) {
				loc += 4;
			} else {
				loc += 4 - (loc & ~3);
			}
		} else {
			loc++;
		}
	}

	loc = pos / 4 - loc / 4;
	while (loc--) {
		*buf++ = '\t';
	}
	*buf = 0;
}

int
is_data (int v)
{
	return ((v & TAG_TYPE_MASK) == TAG_DATA);
}

static void
xrefs (int addr)
{
	int		i;
	int		eff;
	int		count;

	count = 0;
	for (i = 0; i < CORE_SIZE; i++) {
		if (core [i] < 0) {
			continue;
		}

		if (tags [i] & TAG_DATA) {
//printf ("+XREF ADDR %04o CHECK %04o IS DATA\n", addr, i);
			continue;
		}


		if ((core [i] & 07400) == 04000) {	// direct JMS
			eff = ea (i, core [i], NULL, NULL);
//printf ("+XREF ADDR %04o CHECK %04o %04o JMS EA %04o\n", addr, i, core [i], eff);
			if (eff == addr) {
				if (!count) {
					printf ("/\tCalled from:\n/\t");
				}
				printf ("%04o ", i);
				count++;
				if ((count % 15) == 0) {
					printf ("\n/\t");
				}
			}
		} else if ((core [i] & 07400) == 04400) {	// indirect JMS
			eff = ea (i, core [i], NULL, NULL);
//printf ("+XREF ADDR %04o CHECK %04o %04o JMS I EA %04o\n", addr, i, core [i], eff);
			if (tags [eff] & TAG_WRITABLE) {
				continue;
			}
//printf ("+XREF ADDR %04o CHECK %04o %04o JMS I is not writable\n", addr, i, core [i]);
			if (core [eff] < 0) {
				continue;
			}
//printf ("+XREF ADDR %04o CHECK %04o %04o JMS I has valid indirect value\n", addr, i, core [i]);
			if (core [eff] == addr) {
				if (!count) {
					printf ("/\tCalled from:\n/\t");
				}
				printf ("%04o ", i);
				count++;
				if ((count % 15) == 0) {
					printf ("\n/\t");
				}
			}
		}
	}
	if (count) {
		printf ("\n");
		printf ("/\tTotal %04o (%d) calls\n", count, count);
	} else {
		printf ("/\tNever called\n");
	}
}

