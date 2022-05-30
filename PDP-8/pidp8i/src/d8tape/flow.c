
/*
 *	flow.c
 *
 *	(C) Copyright 2007 by Robert Krten, all rights reserved.
 *	Please see the LICENSE file for more information.
 *
 *	This module contains the PDP-8 flow analyzer.
 *
 *	2007 10 25	R. Krten		created
 *	2007 10 28	R. Krten		added TAG_INDIRECTFC
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <errno.h>

#include "d8tape.h"

extern	char	*progname;					// main.c
extern	char	*version;					// version.c

extern	int		optv;						// main.c
extern	short int	core [];				// main.c, in-core image (-1 means location never used)
extern	uint16_t	tags [];				// main.c, analysis tags

char	konstmap [4096];					// 12 bits gives us 0..4095, so 4096 different constants (0 == not used, 1 == unique, 2 == used but not unique)

static void pass1 (void);
static void pass2 (void);
static void pass3 (void);
static void pass4 (void);
static void verify_subroutines (void);
static int valid_opr (int opr);

/*
 *	Main flow analysis
 *
 *	See individual functions for more details
 *
 *	Basic idea is that there is a shadow array called "tags", which indicates
 *	information about the given memory location (e.g., tags [0017] gives
 *	information about core [0017]).
 *
 *	The various passes affect the tags[] array with whatever they can detect.
*/

void
flow (void)
{
	pass1 ();
	pass2 ();
	pass3 ();
//	pass4 ();	// this pass is fundamentally broken (well, maybe not the pass, but the interpretation of the results in dasm.c)
	verify_subroutines ();
}

/*
 *	pass1
 *
 *	On pass 1, we can say with certainty only the following statements:
 *		- if it's an invalid IOT or OPR, then it's data.
 *		- if the instruction must have a valid EA, and it's invalid,
 *		   then it's data.
 *		- if the JMS (direct only) target is not zero or the same as the
 *		  address, then it's data
*/

static void
pass1 (void)
{
	int		addr, eff;

	for (addr = 0; addr < CORE_SIZE; addr++) {
		// skip unused
		if (core [addr] == -1) {
			continue;
		}
		// handle IOTs
		if ((core [addr] & 07000) == 06000) {
			// if we can't decode it, it's not valid
			if (!fetch_iot (core [addr], NULL, NULL)) {
				tags [addr] |= TAG_DATA;
			}
			continue;
		}
		// check OPRs; if they're invalid, tag as DATA, else skip
		if ((core [addr] & 07000) == 07000) {
			if (!valid_opr (core [addr])) {
				tags [addr] |= TAG_DATA;
				if (optv > 1) {
					printf ("+FLOW1 %04o %04o has invalid OPR -> DATA\n", addr, core [addr]);
				}
			}
			// done OPRs, skip
			continue;	// @@@ NOTE:  this does not work with EAE OPRs that take the next location as their parameter...
		}

		// ea() is always valid for opcodes < 06000
		eff = ea (addr, core [addr], NULL, NULL);

		// if the instruction should have a valid EA and doesn't...
		if (core [eff] == -1) {
			// then it's not an instruction
			tags [addr] |= TAG_DATA;
			if (optv > 1) {
				printf ("+FLOW1 %04o %04o has EA %04o (invalid or not in core) and OP < 6000 -> DATA\n", addr, core [addr], eff);
			}
			continue;
		}

		// if it's a plain JMS
		if ((core [addr] & 07400) == 04000) {
			// and the target isn't zero or it's not the same as the address
			if (core [eff] && core [eff] != eff) {
				tags [addr] |= TAG_DATA;
				if (optv > 1) {
					printf ("+FLOW1 %04o %04o JMS target not 0000 or ADDR (EA %04o is %04o)\n", addr, core [addr], eff, core [eff]);
				}
				continue;
			}
			// else, if it's ok, then the target is writable, after all (JMS drops the return address there)
			tags [eff] |= TAG_WRITABLE;
			if (optv > 1) {
				printf ("+FLOW1 %04o %04o JMS target is 0000 or ADDR, marking EA %04o as WRITABLE\n", addr, core [addr], eff);
			}
		}
	}
}

/*
 *	pass2
 *
 *	In this pass, we operate on the direct targets (no indirection)
 *	and mark the targets as data, variable, label, or subroutine
 *	target.
*/

static void
pass2 (void)
{
	int		addr;
	int		eff;

	for (addr = 0; addr < CORE_SIZE; addr++) {
		// skip unused or data locations
		if (core [addr] == -1 || (tags [addr] & TAG_DATA)) {
			continue;
		}

		eff = ea (addr, core [addr], NULL, NULL);

		switch (core [addr] & 07400) {		// check opcode
		case	00000:						// AND
		case	00400:						// AND I
		case	01000:						// TAD
		case	01400:						// TAD I
		case	02000:						// ISZ
		case	02400:						// ISZ I
		case	03000:						// DCA
		case	03400:						// DCA I
			tags [eff] |= TAG_DATA;			// the referenced EA is data
			if (optv > 1) {
				printf ("+FLOW2 %04o %04o is AND/TAD/ISZ/DCA's EA %04o tagged as DATA\n", addr, core [addr], eff);
			}

			// mark as writable if someone writes to it directly (ISZ and DCA only)
			if ((core [addr] & 07400) == 02000 || (core [addr] & 07400) == 03000) {
				tags [eff] |= TAG_WRITABLE;
				if (optv > 1) {
					printf ("+FLOW2 %04o %04o is ISZ/DCA so EA %04o is WRITABLE\n", addr, core [addr], eff);
				}
			}
			break;

		case	04000:						// JMS
			if (core [eff] == 0 || core [eff] == eff) {	// first word of JMS target must be zero or the address itself
				tags [eff] |= TAG_SUB;		// otherwise, it's a valid subroutine target
				if (optv > 1) {
					printf ("+FLOW2 %04o %04o is JMS with good target %04o content (%04o) so tagged as SUB\n", addr, core [addr], eff, core [eff]);
				}
			} else {
				tags [addr] |= TAG_DATA;	// then invalidate this "instruction", it's bogus
				if (optv > 1) {
					printf ("+FLOW2 %04o %04o is JMS with bad target %04o content (%04o) so tagged as DATA\n", addr, core [addr], eff, core [eff]);
				}
			}
			break;

		case	05000:						// JMP
			tags [eff] |= TAG_LABEL;
			if (optv > 1) {
				printf ("+FLOW2 %04o %04o is JMP so EA %04o is LABEL\n", addr, core [addr], eff);
			}
			break;

			break;

		// JMS I, JMP I, IOTs, and OPRs are not handled in this pass
		}
	}
}

/*
 *	pass3
 *
 *	In this pass, we verify and mark the indirects
*/

static void
pass3 (void)
{
	int		addr;
	int		eff;

	for (addr = 0; addr < CORE_SIZE; addr++) {
		// skip unused, data, or non-indirect opcodes
		if (core [addr] == -1 || (tags [addr] & TAG_DATA) || core [addr] >= 06000 || !(core [addr] & 00400)) {
			if (optv > 2 && core [addr] != -1) {
				printf ("+FLOW3 %04o %04o tags 0x%04x skipped\n", addr, core [addr], tags [addr]);
			}
			continue;
		}

		eff = ea (addr, core [addr], NULL, NULL);

		switch (core [addr] & 07000) {		// check opcode (indirectness assured above)
		case	00000:						// AND I
		case	01000:						// TAD I
		case	02000:						// ISZ I
		case	03000:						// DCA I
			if (core [eff] != -1 && !(tags [eff] & TAG_WRITABLE)) {	// if it's valid and constant
				tags [core [eff]] |= TAG_DATA;	// then the target is data
				if (optv > 1) {
					printf ("+FLOW3 %04o %04o is AND/TAD/ISZ/DCA I through constant EA %04o so target %04o is DATA\n", addr, core [addr], eff, core [eff]);
				}

				// mark as writable if someone writes to it (ISZ and DCA only)
				if ((core [addr] & 07000) == 02000 || (core [addr] & 07000) == 03000) {
					tags [core [eff]] |= TAG_WRITABLE;
					if (optv > 1) {
						printf ("+FLOW3 %04o %04o is ISZ/DCA I thorugh constant EA %04o so target %04o is WRITABLE\n", addr, core [addr], eff, core [eff]);
					}
				}
			}
			break;

		case	04000:						// JMS I
			if (core [eff] != -1 && !(tags [eff] & TAG_WRITABLE)) {	// if it's valid and constant
				if (core [core [eff]] == 0 || core [core [eff]] == core [eff]) {	// valid first word of JMS I target
					tags [core [eff]] |= TAG_SUB;	// ultimate target is a valid subroutine target
					tags [eff] |= TAG_DATA;			// and the pointer is a valid data type
					tags [eff] |= TAG_INDIRECTFC;	// and the pointer is used in an indirect flow control target
					if (optv > 1) {
						printf ("+FLOW3 %04o %04o is JMS I through constant EA %04o so target %04o (content %04o) is ok, so tagged as SUB\n", addr, core [addr], eff, core [eff], core [core [eff]]);
					}
				} else {
					tags [addr] |= TAG_DATA;	// then this isn't a valid instruction
					if (optv > 1) {
						printf ("+FLOW3 %04o %04o is JMS I through constant EA %04o with target %04o (invalid content %04o), so tagged as DATA\n", addr, core [addr], eff, core [eff], core [core [eff]]);
					}
				}
			}
			break;

		case	05000:						// JMP I
			if (core [eff] != -1) {				// if it's valid
				if (!(tags [eff] & TAG_WRITABLE)) {	// and constant
					tags [eff] |= TAG_DATA;			// pointer is a valid data type
					tags [eff] |= TAG_INDIRECTFC;	// and the pointer is used in an indirect flow control target
					tags [core [eff]] |= TAG_LABEL;	// ultimate target is a valid JMP target
					if (optv > 1) {
						printf ("+FLOW3 %04o %04o is JMP I through constant EA %04o with valid target %04o, so EA tagged as DATA | INDIRECTFC and target data %04o tagged as LABEL\n", addr, core [addr], eff, core [eff], core [core [eff]]);
					}
				}
			} else {
				tags [addr] |= TAG_DATA;	// else, it's not really a valid constant expression
				if (optv > 1) {
					printf ("+FLOW3 %04o %04o is JMP I through constant EA %04o with invalid target %04o, so tagged as DATA\n", addr, core [addr], eff, core [eff]);
				}
			}
			break;
		}
	}
}

/*
 *	pass4
 *
 *	In this pass, we update the constant map (konstmap).
 *
 *	This effectively converts Cxxxx to Kxxxx, and results in more human-
 *	friendly code.  So, instead of:
 *
 *		C1234, 0777
 *
 *	you'd see:
 *
 *		K0777, 0777
 *
 *	The only trick to this is that since symbols must be unique in 6
 *	characters (for PAL compatibility), we need to ensure that the
 *	items that convert from Cxxxx to Kxxxx are unique.  That's why
 *	konstmap[] has the values 0, 1, and 2:
 *
 *		0 == constant is not used anywhere in the code
 *		1 == constant is defined exactly once (can be converted)
 *		2 == constant has been defined more than once (cannot be converted)
 *
 *	Any constant that's used in an indirect flow control manner, however,
 *	is not a candidate, because technically it's not used as a K-style
 *	constant.
*/

static void
pass4 (void)
{
	int		i;

	memset (konstmap, 0, sizeof (konstmap));

	// populate konstant[] map
	for (i = 0; i < CORE_SIZE; i++) {
		if (core [i] == -1) {
			continue;
		}

		if (tags [i] & TAG_WRITABLE) {
			if (optv > 1) {
				printf ("+FLOW4 %04o %04o TAG %02X is writable, therefore, not a constant\n", i, core [i], tags [i]);
			}
			continue;
		}

		if (optv > 1) {
			printf ("+FLOW4 %04o %04o TAG %02X\n", i, core [i], tags [i]);
		}
		if ((tags [i] & TAG_DATA) && !(tags [i] & TAG_INDIRECTFC)) {
			switch (konstmap [core [i]]) {
			case	0:
				if (optv > 1) {
					printf ("+FLOW4 %04o %04o FRESH KONSTANT\n", i, core [i]);
				}
				konstmap [core [i]]++;		// this is our first one, bump the counter
				break;
			case	1:
				if (optv > 1) {
					printf ("+FLOW4 %04o %04o NO LONGER UNIQUE KONSTANT\n", i, core [i]);
				}
				konstmap [core [i]]++;		// this is our second one, go to "2"
				break;
			case	2:
				if (optv > 1) {
					printf ("+FLOW4 %04o %04o PROMISCUOUS CONSTANT\n", i, core [i]);
				}
				// do nothing, we're at "2" indicating "non-unique"
				break;
			}
		}
	}

	// analyze konstant[] map
	for (i = 0; i < CORE_SIZE; i++) {
		if (core [i] == -1) {
			continue;
		}
		if (tags [i] & TAG_WRITABLE) {
			if (optv > 1) {
				printf ("+FLOW4 %04o %04o TAG %02X is writable, therefore, not a constant\n", i, core [i], tags [i]);
			}
			continue;
		}

		if (optv > 1) {
			printf ("+FLOW4 %04o %04o TESTING (%02X)\n", i, core [i], tags [i]);
		}
		if (tags [i] & TAG_DATA) {
			if (optv > 1) {
				printf ("+FLOW4 %04o %04o TESTING...DATA\n", i, core [i]);
			}
			if (konstmap [core [i]] == 1) {	// if it's unique
				tags [i] |= TAG_KONSTANT;	// then go ahead and tag it
				if (optv > 1) {
					printf ("+FLOW4 %04o %04o TAGGED AS KONSTANT\n", i, core [i]);
				}
			}
		}
	}
}

/*
 *	verify_subroutines
 *
 *	This is used to verify that a target really is a subroutine.
 *	Verification consists of ensuring that somewhere within the
 *	same page is a JMP I through the return address.  If not,
 *	then the subroutine is bogus, because you can't return from
 *	it, so we knock down the "TAG_SUB" flag.
 *
 *	BUG:  This misses the following case:
 *
 *		*0
 *		0 /return area
 *		*4000
 *		jmp i 0	/ return through zero page
 *
 *	because we only search for returns within the page that the
 *	subroutine definition is in.  I don't think this is a major
 *	problem, just something to be aware of.  Plus, the TAG_RETURN
 *	is *really* only used as a comment field indicator anyway.
*/

static void
verify_subroutines (void)
{
	int		addr;
	int		page;
	int		found;

	for (addr = 0; addr < CORE_SIZE; addr++) {
		if (!(tags [addr] & TAG_SUB)) {
			continue;
		}

		// try and find returns within page
		found = 0;
		for (page = addr; page <= (addr | 00177); page++) {
			if ((core [page] & 07400) == 05400) {
				if (ea (page, core [page], NULL, NULL) == addr) {	// JMP I <start of subroutine> found!
					tags [page] |= TAG_RETURN;	// mark the returns
					found++;
				}
			}
		}
		if (!found) {
			tags [addr] &= ~TAG_SUB;			// not a subroutine, no return
		}
	}
}

static int
valid_opr (int opr)
{
	// a valid OPR must be 07xxx
	if ((opr & 07000) != 07000) {
		return (0);
	}

	if ((opr & 07400) == 07000) {						// group 1
		if ((opr & 00014) == 00014) {					// with both L and R rotate bits on
			return (0);
		}
	} else if ((opr & 07401) == 07400) {				// group 2
		// all ok
	} else if ((opr & 07401) == 07401) {				// EAE
		// if bits 6, 8, 9, or 10 are set...
		if (opr & 00056) {
			return (0);										// @@@ we're disabling EAE for now
		}
		// otherwise it's an "MQ microinstruction", which is ok
	}
	return (1);
}

