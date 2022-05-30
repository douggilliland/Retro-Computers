
/*
 *	main.c
 *
 *	(C) Copyright 2000 by Robert Krten, all rights reserved.
 *	Please see the LICENSE file for more information.
 *
 *	This module represents the main module for the RIM/BIN
 *	dumper/disassembler/converter/reverse engineering tool.
 *
 *	This program will dump a RIM/BIN-formatted image to stdout, or
 *	convert a tape from one format to another, or clean up a tape,
 *	or disassemble a tape with reverse-engineering aids.
 *
 *	2001 01 07	R. Krten		created
 *	2003 12 16	R. Krten		added disassembler
 *	2003 12 17	R. Krten		made it RIM/BIN aware.
 *	2007 10 25	R. Krten		added reverse-engineering features
 *	2007 11 04	R. Krten		fixed header skip logic (see dumptape())
*/

#ifdef __USAGE

%C [options] papertapefile [papertapefile...]

where [options] are optional parameters chosen from:
    -b             generate a BIN-formatted output (adds ".bin")
    -d             suppress disassembly (useful for conversion-only mode)
    -r             generate a RIM-formatted output (adds ".rim")
    -T             generate test pattern 0000=0000..7756=7756
    -v             verbose operation

Dumps the RIM- or BIN-formatted input file(s) specified on
the command line.  If the "-r" and/or "-b" options are
present, also creates a RIM and/or BIN version of the output
by adding ".rim" and/or ".bin" (respectively) to the input
filename (can be used to "clean up" BIN and RIM images by
deleting excess data before and after the leader/trailer).

#endif

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#include <limits.h>

#include <sys/types.h>
#include <sys/stat.h>

#include "d8tape.h"

static	void seg_add (uint16_t addr, int len);
static	void seg_more (int len);

static	void	optproc (int, char **);
static	int		dumptape (unsigned char *t, int n);
static	int		dumprim (unsigned char *t, int n);
static	int		dumpbin (unsigned char *t, int n);
static	int		checkrim (unsigned char *t, int n);
static	int		checkbin (unsigned char *t, int n);
static	void	writebin (void);
static	void	writerim (void);
static	int		blank (short int *core, int size);

const	char	*progname = "d8tape";
const	char	*blankname= "      ";
extern	char	*version;					// version.c

int				optb;
int				optd;
int				optr;
int				optT;
int				optv;
unsigned char	*tape;						// paper tape image
short int		core [CORE_SIZE];			// in-core image (-1 means location never used)
uint16_t		tags [CORE_SIZE];			// analysis tags
segment_t		*segments;					// used to accumulate runs of data (from origin for nwords)
int				nsegments;					// indicates how many segments we have
char			*tapename;

/*
 *	main
 *
 *	Main simply calls the option processor, from which everything happens.
*/

int
main (int argc, char **argv)
{
	optproc (argc, argv);
	exit (EXIT_SUCCESS);
}

/*
 *	usageError
 *
 *	This is the usage message
*/

static void
usageError ()
{
	fprintf (stderr, "\nUsage:  %s [options] papertapefile [papertapefile...]\n\n", progname);
	fprintf (stderr, "where [options] are optional parameters chosen from:\n");
	fprintf (stderr, "    -b             generate a BIN-formatted output (adds \".bin\")\n");
	fprintf (stderr, "    -d             suppress disassembly (useful for conversion-only mode)\n");
	fprintf (stderr, "    -r             generate a RIM-formatted output (adds \".rim\")\n");
	fprintf (stderr, "    -v             verbose operation\n");
	fprintf (stderr, "\n");
	fprintf (stderr, "Dumps the RIM- or BIN-formatted input file(s) specified on\n");
	fprintf (stderr, "the command line.  If the \"-r\" and/or \"-b\" options are\n");
	fprintf (stderr, "present, also creates a RIM and/or BIN version of the output\n");
	fprintf (stderr, "by adding \".rim\" and/or \".bin\" (respectively) to the input\n");
	fprintf (stderr, "filename (can be used to \"clean up\" BIN and RIM images by\n");
	fprintf (stderr, "deleting excess data before and after the leader/trailer).\n");
	fprintf (stderr, "\n");
	fprintf (stderr, "Disassembly conforms to PAL III input requirements\n");
	fprintf (stderr, "\n");
	exit (EXIT_FAILURE);
}

/*
 *	optproc
 *
 *	This is the option processor.  It detects the command line options, and
 *	then processes the individual files.
*/

static void
optproc (int argc, char **argv)
{
	int		opt;
	int		got_any;
	int		fd;
	int		i;
	struct	stat statbuf;
	int		sts;

	if (!argc) {
		usageError ();
	}

	// clear out option values to defaults
	optb = optr = optT = 0;

	// handle command line options
	got_any = 0;
	while ((opt = getopt (argc, argv, "bdrTv")) != -1) {
		switch (opt) {
		case	'b':
			optb++;
			break;
		case	'd':
			optd++;
			break;
		case	'r':
			optr++;
			break;
		case	'T':
			optT++;
			break;
		case	'v':
			optv++;
			if (optv > 1) {
				fprintf (stderr, "Verbosity is %d\n", optv);
			}
			break;
		default:
			usageError ();
			break;
		}
	}

	// handle command line arguments
	for (; optind < argc; optind++) {
		got_any++;
		tapename = argv [optind];				// snap tapename to global

		// open the tape
		fd = open (tapename, O_RDONLY);
		if (fd == -1) {
			fprintf (stderr, "%s:  couldn't open %s for O_RDONLY, errno %d\n", progname, tapename, errno);
			perror (NULL);
			exit (EXIT_FAILURE);
		}
		fstat (fd, &statbuf);					// get the size, so we can read it into memory

		tape = calloc (1, statbuf.st_size);
		if (tape == NULL) {
			fprintf (stderr, "%s:  can't allocate %zu bytes during processing of %s, errno %d (%s)\n", progname, statbuf.st_size, tapename, errno, strerror (errno));
			exit (EXIT_FAILURE);
		}

		// initialize data areas
		memset (core, 0xff, sizeof (core));		// set to -1 -- since we are only using 12 bits of each 16 bit word, -1 isn't a valid PDP-8 core value
		memset (tags, 0, sizeof (tags));		// reset tags
		nsegments = 0;
		segments = NULL;

		if (read (fd, tape, statbuf.st_size) < 0) {
            fprintf (stderr, "%s:  read failed: %s\n", progname, strerror (errno));
            return;
        }
		close (fd);

		// dump the tape (this also reads the tape into "core" and disassembles)
		sts = dumptape (tape, statbuf.st_size);

		free (tape);

		if (!sts) {
			continue;							// skip tape
		}

		// convert to RIM/BIN if required (-b and/or -r)
		if (optb || optr) {
			// see if there is any data there at all..
			if (blank (core, CORE_SIZE)) {
				fprintf (stderr, "%s:  tape image from %s is empty, not creating a BIN version\n", progname, tapename);
				return;
			}
			if (optb) {
				writebin ();
			}
			if (optr) {
				writerim ();
			}
		}
	}

	// if no arguments given, dump usage message
	if (optT) {
		memset (core, 0xff, sizeof (core));		// set to -1 (assumption; all 0xff's in an int is -1; pretty safe)
		for (i = 0; i < 07600; i++) {
			core [i] = ((i & 07700) >> 6) + ((i & 00077) << 6);
		}
		tapename = "test";
		if (optb) {
			writebin ();
		}
		if (optr) {
			writerim ();
		}
	} else {
		if (!got_any) {
			usageError ();
		}
	}
}

/*
 *	dumptape
 *
 *	This function does some basic processing (detecting and skipping the
 *	header, killing off data past the trailer) and then determines via
 *	checkrim() and ckeckbin() the format of the tape.  Depending on the
 *	type of tape, dumprim() or dumpbin() is called to read the tape into
 *	the "core" array and disassemble it.
 *
 *	20071104:  Changed the 'skip header' logic to look for a character
 *	less than 0x80, not just not equal to, because a tape I received
 *	had the following:
 *		0000000   200 200 200 200 200 200 200 200 200 200 200 200 200 200 200 200
 *		*
 *		0000100   300 100 000 000 000 050 001 000 002 000 003 000 000 000 000 054
 *
 *	Notice the "300" (0xc0) at location 0100.
 *
 *	Returns 0 on error.
*/

static int
dumptape (unsigned char *t, int n)
{
	int		i;

	// basic preprocessing; find header
	for (i = 0; i < n; i++) {
		if (t [i] == 0x80) {		// got a header
			break;
		}
	}
	if (i == n) {
		fprintf (stderr, "%s:  couldn't find a 0x80 leader on tape %s; tape ignored\n", progname, tapename);
		return (0);
	}

	// skip header
	for (; i < n; i++) {
		if (t [i] < 0x80) {			// RK 20071104 was "!= 0x80"; 
			break;
		}
	}
	if (i == n) {
		fprintf (stderr, "%s:  no data content found after 0x80 leader on tape %s; tape ignored\n", progname, tapename);
		return (0);
	}

	// at this point, we're positioned on the first-non-leader byte of the tape
	if (n - i < 4) {
		fprintf (stderr, "%s:  tape %s is too short; tape ignored\n", progname, tapename);
		return (0);
	}

	// skip leader (t now points to start of tape; n indicates remaining # bytes)
	if (optv) {
		fprintf (stderr, "%s:  tape %s skipped %d (0x%0X, 0%0o) bytes of header, original size %d new size %d\n", progname, tapename, i, i, i, n, n - i);
	}
	t += i;
	n -= i;

	// find first 0x80 -- trailer
	for (i = 0; i < n; i++) {
		if (t [i] == 0x80) {
			break;
		}
	}
	if (i == n) {
		fprintf (stderr, "%s:  warning -- tape %s does not have a trailer\n", progname, tapename);
		// find first data >= 0x80, then
		for (i = 0; i < n; i++) {
			if (t [i] >= 0x80) {
				// at least stop on the first invalid character, then
				break;
			}
		}
	}

	// reset end-of-tape to last character
	if (optv > 2) {
		printf ("%s:  tape %s skipped %d bytes of trailer, new size is %d bytes\n", progname, tapename, n - i, i);
	}
	n = i;

	// determine type of tape and dump it
	if (checkrim (t, n)) {
		if (!dumprim (t, n)) {
			return (0);
		}
	} else if (checkbin (t, n)) {
		if (!dumpbin (t, n)) {
			return (0);
		}
	} else {
		fprintf (stderr, "%s:  tape %s is neither RIM nor BIN (first four bytes are 0%03o 0%03o 0%03o 0%03o)\n", progname, tapename, t [0], t [1], t [2], t [3]);
		return (0);
	}

	if (!optd) {
		flow ();				// perform flow analysis
		disassemble ();			// disassemble
		printf ("\n$\n");
	}
	return (1);
}

/*
 *	checkrim
 *	checkbin
 *
 *	These two functions try to determine what format the tape is in.
 *	A zero return indicates the tape is not in the given format; a one
 *	indicates it is.  The heuristics used here are fairly simple.
*/

static int
checkrim (unsigned char *t, int n)
{
	int		i;

	if (n % 4) {
		if (optv > 2) {
			printf ("%s:  tape %s size (%d bytes) is not divisible by four; not a RIM tape\n", progname, tapename, n);
		}
		return (0);
	}

	// see if it's a RIM-formatted tape; we're looking for 01xxxxxx 00xxxxxx 00xxxxxx 00xxxxxx
	for (i = 0; i < n; i += 4) {
		if ((t [i] & 0xC0) != 0x40 || (t [i + 1] & 0xC0) || (t [i + 2] & 0xC0) || (t [i + 3] & 0xC0)) {
			if (optv > 2) {
				printf ("%s:  tape %s does not have the RIM signature at offset 0%04o; expected 01xxxxxx 00xxxxxx 00xxxxxx 00xxxxxx, got 0%04o 0%04o 0%04o 0%04o\n", progname, tapename, i, t [i], t [i + 1], t [i + 2], t [i + 3]);
			}
			return (0);
		}
	}
	return (1);
}

static int
checkbin (unsigned char *t, int n)
{
	if (n % 2) {
		if (optv > 2) {
			printf ("%s:  tape %s size (%d bytes) is not divisible by two; not a BIN tape\n", progname, tapename, n);
		}
		return (0);
	}

	// see if it's a BIN-formatted tape; 01xxxxxx 00xxxxxx (i.e., we at least expect an origin)
	if ((t [0] & 0xC0) != 0x40 || (t [1] & 0xC0)) {
		if (optv > 2) {
			printf ("%s:  tape %s does not have the BIN origin signature; expected header of 01xxxxxx 00xxxxxx, got 0%04o 0%04o\n", progname, tapename, t [0], t [1]);
		}
		return (0);
	}

	return (1);
}

/*
 *	From the PDP-8/I & PDP-8/L Small Computer Handbook (099-00272-A1983 / J-09-5)
 *	Appendix D, "Perforated-Tape Loader Sequences", page 383
 *
 *	READIN MODE LOADER
 *	The readin mode (RIM) loader is a minimum length, basic perforated-tape
 *	reader program for the ASR33, it is initially stored in memory by manual use
 *	of the operator console keys and switches.  The loader is permanently stored in
 *	18 locations of page 37.
 *
 *	A perforated tape to be read by the RIM loader must be in RIM format:
 *
 *	   Tape Channel
 *	 8 7 6 5 4 3 2 1  OCTAL  Format
 *	 ---------------  -----  ------------------------
 *	 1 0 0 0 0 0 0 0   200   Leader-trailer code
 *	 0 1 -A1-  -A2-    1AA   Absolute address to
 *	 0 0 -A3-  -A4-    0AA   contain next 4 digits
 *	 0 0 -X1-  -X2-    0XX   Content of previous
 *	 0 0 -X3-  -X4-    0XX   4-digit address
 *	 0 1 -A1-  -A2-    1AA   Address
 *	 0 0 -A3-  -A4-    0AA
 *	 0 0 -X1-  -X2-    0XX   Content
 *	 0 0 -X3-  -X4-    0XX
 *	     (etc)                (etc)
 *	 1 0 0 0 0 0 0 0   200   Leader-trailer code
 *
 *	The RIM loader can only be used in conjunction with the ASR33 reader (not
 *	the high-speed perforated-tape reader).  Because a tape in RIM format is, in
 *	effect, twice as long as it need be, it is suggested that the RIM loader be used
 *	only to read the binary loader when using the ASR33. (Note that PDP-8 diag-
 *	nostic program tapes are in RIM format.)
 *
 *	The complete PDP-8/I RIM loader (SA=7756) is as follows:
 *
 *	Absolute	Octal
 *	Address		Content		Tag		Instruction I Z		Comments
 *	7756,		6032		BEG,	KCC					/CLEAR AC AND FLAG
 *	7757,		6031				KSF					/SKIP IF FLAG = 1
 *	7760,		5357				JMP .-1				/LOOKING FOR CHARACTER
 *	7761,		6036				KRB					/READ BUFFER
 *	7762,		7106				CLL RTL
 *	7763,		7006				RTL					/CHANNEL 8 IN AC0
 *	7764,		7510				SPA					/CHECKING FOR LEADER
 *	7765,		5357				JMP BEG+1			/FOUND LEADER
 *	7766,		7006				RTL					/OK, CHANNEL 7 IN LINK
 *	7767,		6031				KSF
 *	7770,		5367				JMP .-1
 *	7771,		6034				KRS					/READ, DO NOT CLEAR
 *	7772,		7420				SNL					/CHECKING FOR ADDRESS
 *	7773,		3776				DCA I TEMP			/STORE CONTENT
 *	7774,		3376				DCA TEMP			/STORE ADDRESS
 *	7775,		5356				JMP BEG				/NEXT WORD
 *	7776,		0			TEMP,	0					/TEMP STORAGE
 *	7777,		5XXX				JMP X				/JMP START OF BIN LOADER
*/

/*
 *	dumprim
 *
 *	This is a finite-state-machine that runs through the tape reading the address
 *	and data records, stuffs them into core[], and disassembles the opcodes unless
 *	"-d" is specified.
 *
 *	Note that disassembly is done after the complete tape has been read in, this
 *	allows us to do some flow analysis.
*/

#define	RIM_Initial			1				// waiting for address
#define	RIM_Addr			2				// got top part of address, process bottom part
#define	RIM_Data1			3				// got address, process top part of data
#define	RIM_Data2			4				// got top part of data, process bottom part

static int
dumprim (unsigned char *t, int n)
{
	int			state;
	int			i;
	uint16_t	addr, data;
	uint16_t	cur_addr;

	state = RIM_Initial;

	cur_addr = 0xffff;						// impossible address for PDP-8

	for (i = 0; i < n; i++) {
		if (optv > 2) {
			printf ("[%03o] ", t [i]); fflush (stdout);
			if ((i % 13) == 12) {
				printf ("\n");
			}
		}
		switch (state) {
		case	RIM_Initial:
			if (t [i] & 0100) {				// indicates 1st part of address
				addr = (t [i] & 0077) << 6;	// store top part
				state = RIM_Addr;
			}
			break;
		case	RIM_Addr:
			addr |= (t [i] & 0077);
			state = RIM_Data1;
			break;
		case	RIM_Data1:
			data = (t [i] & 0077) << 6;		// store top part
			state = RIM_Data2;
			break;
		case	RIM_Data2:					// final decode complete, store data
			data |= (t [i] & 0077);
			core [addr] = data;				// stash data into core image

			// segment management -- if it's the next byte, add, else create new
			if (addr == cur_addr) {
				cur_addr++;
				seg_more (1);
			} else {
				seg_add (addr, 1);
				cur_addr = addr + 1;
			}
			state = RIM_Initial;
			break;
		}
	}
	if (optv > 2) {
		printf ("\n");
	}
	return (1);
}

/*
 *	BIN format, from the same doc as above, page 384:
 *
 *	BINARY LOADER
 *	The binary loader (BIN) is used to read machine language tapes (in binary
 *	format) produced by the program assembly language (PAL).  A tape in binary
 *	format is about one-half the length of the comparable RIM format tape.  It can,
 *	therefore, be read about twice as fast as a RIM tape and is, for this reason,
 *	the more desirable format to use with the 10 cps ASR33 reader or the Type
 *	PR8/I High-Speed Perforated-Tape Reader.
 *
 *	The format of a binary tape is as follows:
 *
 *		LEADER: about 2 feet of leader-trailer codes.
 *
 *		BODY: characters representing the absolute, machine language program
 *		in easy-to-read binary (or octal) form.  The section of tape may contain
 *		characters representing instructions (channel 8 and 7 not punched) or
 *		origin resettings (channel 8 not punched, channel 7 punched) and is
 *		concluded by 2 characters (channel 8 and 7 not punched) that represent
 *		a check sum for the entire section.
 *
 *		TRAILER: same as leader.
 *
 *	I.e.,
 *
 *	  Tape Channel
 *	8 7 6 5 4 3 2 1  OCTAL  Format
 *	---------------  -----  ------------------------
 *	1 0 0 0 0 0 0 0	  200	Leader
 *	0 1 A A A A A A   1AA	Address (top)
 *	0 1 B B B B B B	  1BB	Address (bottom)
 *	0 0 C C C C C C	  0CC	Data (top)
 *	0 0 D D D D D D	  0DD	Data (bottom)
 *	0 0 C C C C C C	  0CC	Data (top)
 *	0 0 D D D D D D	  0DD	Data (bottom)
 *	     . . .		  ...	next data (2 bytes)
 *	0 1 A A A A A A   1AA	New address (top)
 *	0 1 B B B B B B	  1BB	New address (bottom)
 *	     . . .		  ...	next data (2 bytes)
 *	0 0 X X X X X X	  0XX	Checksum (top)
 *	0 0 Y Y Y Y Y Y	  0YY	Checksum (bottom)
 *		
*/

/*
 *	dumpbin
 *
 *	This is a finite-state-machine that runs through the tape looking for the
 *	origin and subsequent data fields, stuffs them into the core[] array, and
 *	optionally disassembles the opcodes.
 *
 *	Every time we hit an origin change, we create a new segment and accumulate
 *	bytes into it.
*/

#define	BIN_Initial				1			// initial state; we require an origin to get out of it
#define	BIN_Origin				2			// we got the top part of the origin, now need to get the bottom part
#define	BIN_DataHW				3			// we have an address, so we are looking for another origin or the top part of the data
#define	BIN_DataLW				4			// we have the top part of the data, now fetching the low part

static int
dumpbin (unsigned char *t, int n)
{
	int		tape_checksum;					// checksum stored on tape
	int		calc_checksum;					// calculated checksum
  	int		i;
  	int		state;
  	unsigned short int addr, data;

	if (n < 4) {
		fprintf (stderr, "%s:  tape %s is too short; tape skipped\n", progname, tapename);
		return (0);
	}

	tape_checksum = ((t [n - 2] & 0x3f) << 6) + (t [n - 1] & 0x3f);
	if (optv > 1) {
		printf ("%s:  tape %s expected checksum 0%04o\n", progname, tapename, tape_checksum);
	}
	n -= 2;									// tape is now shorter by the two bytes

	// now calculate checksum
	calc_checksum = 0;
	for (i = 0; i < n; i++) {
		calc_checksum += t [i];
	}
	calc_checksum &= 07777;					// mask to 12 bits
	if (optv > 1) {
		printf ("%s:  tape %s calculated checksum 0%04o\n", progname, tapename, calc_checksum);
	}

	if (tape_checksum != calc_checksum) {
		fprintf (stderr, "%s:  tape %s calculated checksum [0%04o] != stored checksum [0%04o]; tape skipped\n", progname, tapename, calc_checksum, tape_checksum);
		return (0);
	}

	// now we can dump the binary data via the state machine
	state = BIN_Initial;
	for (i = 0; i < n; i++) {
		if (optv > 2) {
			printf ("[%03o] ", t [i]); fflush (stdout);
			if ((i % 13) == 12) {
				printf ("\n");
			}
		}
		switch (state) {
		case	BIN_Initial:
			if (t [i] & 0100) {				// indicates origin setting code
				addr = (t [i] & 0077) << 6;	// store top part
				state = BIN_Origin;
			}
			break;
		case	BIN_Origin:
			addr += (t [i] & 0077);			// store bottom part
			state = BIN_DataHW;
			seg_add (addr, 0);
			break;
		case	BIN_DataHW:
			if (t [i] & 0100) {				// another origin; skip loading data and load address instead
				addr = (t [i] & 0077) << 6;
				state = BIN_Origin;
			} else {
				data = (t [i] & 0077) << 6;	// store top part of data
				state = BIN_DataLW;
			}
			break;
		case	BIN_DataLW:
			data += (t [i] & 0077);
			core [addr] = data;
			seg_more (1);
			addr++;							// the magic of BIN-format is the autoincrement of the address
			state = BIN_DataHW;
		}
	}
	if (optv > 2) {
		printf ("\n");
	}
	return (1);
}

/*
 *	writebin
 *	writerim
 *
 *	These two functions write the BIN and RIM format tapes to a file.
 *	The filename is constructed by appending ".bin" or ".rim" to the
 *	input filename.
 *
 *	The header and trailer written are short, LEADER_LENGTH bytes.
 *
 *	The writebin() uses a finit-state-machine to generate the origin.
*/

#define	LEADER_LENGTH	16					// 16 chars of leader/trailer should be plenty

#define	WBIN_Initial	1					// looking for first/next in-use core[] element
#define	WBIN_Writing	2					// origin written, dumping consecutive words

static	void
writebin (void)
{
	char	fname [PATH_MAX];
	char	leader [LEADER_LENGTH];
	FILE	*fp;
	int		i;
	int		cksum;
	int		state;

	// create filename and open it
	sprintf (fname, "%s.bin", tapename);
	if ((fp = fopen (fname, "w")) == NULL) {
		fprintf (stderr, "%s:  unable to open BIN output file %s for w, errno %d (%s); creation of output file skipped\n", progname, fname, errno, strerror (errno));
		return;
	}

	// write leader
	memset (leader, 0x80, sizeof (leader));
	fwrite (leader, 1, sizeof (leader), fp);

	// now scan through "core" and write the data out...
	cksum = 0;
	state = WBIN_Initial;
	for (i = 0; i < CORE_SIZE; i++) {
		switch (state) {
		case	WBIN_Initial:				// transit out of WBIN_Initial on a "used" core position
			if (core [i] != -1) {
				state = WBIN_Writing;
				fprintf (fp, "%c%c", 0x40 | ((i & 07700) >> 6), i & 00077);		// write origin directive
				fprintf (fp, "%c%c", (core [i] & 07700) >> 6, core [i] & 00077);	// write data
				cksum += (0x40 | ((i & 07700) >> 6)) + (i & 00077) + ((core [i] & 07700) >> 6) + (core [i] & 00077);
			}
			break;
		case	WBIN_Writing:
			if (core [i] == -1) {
				state = WBIN_Initial;		// waiting again for a used core position
			} else {
				fprintf (fp, "%c%c", (core [i] & 07700) >> 6, core [i] & 00077);
				cksum += ((core [i] & 07700) >> 6) + (core [i] & 00077);
			}
			break;
		}
	}

	// now write the checksum
	fprintf (fp, "%c%c", (cksum & 07700) >> 6, cksum & 00077);

	// write trailer
	fwrite (leader, 1, sizeof (leader), fp);

	fclose (fp);
}

static	void
writerim (void)
{
	char	fname [PATH_MAX];
	char	leader [LEADER_LENGTH];
	FILE	*fp;
	int		i;

	// create the filename and open it
	sprintf (fname, "%s.rim", tapename);
	if ((fp = fopen (fname, "w")) == NULL) {
		fprintf (stderr, "%s:  unable to open RIM output file %s for w, errno %d (%s); creation of output file skipped\n", progname, fname, errno, strerror (errno));
		return;
	}

	// write leader
	memset (leader, 0x80, sizeof (leader));
	fwrite (leader, 1, sizeof (leader), fp);

	for (i = 0; i < CORE_SIZE; i++) {
		if (core [i] != -1) {
			fprintf (fp, "%c%c%c%c", 0x40 + ((i & 07700) >> 6), i & 00077, (core [i] & 07700) >> 6, core [i] & 00077);
		}
	}

	// write trailer
	fwrite (leader, 1, sizeof (leader), fp);

	fclose (fp);
}

/*
 *	blank
 *
 *	A utility routine to see if core[] is blank (returns 1).
 *	Used to avoid writing an empty tape.
*/

static int
blank (short int *c, int size)
{
	int		i;

	for (i = 0; i < size; i++) {
		if (c [i] != -1) {
			return (0);
		}
	}
	return (1);
}

/*
 *	seg_add (addr, len)
 *	seg_more (more)
 *
 *	These functions manipulate the segment data stored
 *	in "segments[]" and "nsegments".
 *
 *	seg_add creates a new segment with the given address
 *	and length.
 *
 *	seg_more lengthens the current segment by "more"
 *	words.
*/

static void
seg_add (uint16_t addr, int len)
{
	if (optv > 3) {
		printf ("seg_add (0%04o, %d (0%04o))\n", addr, len, len);
	}

	segments = realloc (segments, (nsegments + 1) * sizeof (segments [0]));
	if (segments == NULL) {
		fprintf (stderr, "%s:  couldn't realloc segments array to be %d elements (%ld bytes) long, errno %d (%s)\n", progname, nsegments + 1, (nsegments + 1) * sizeof (segments [0]), errno, strerror (errno));
		exit (EXIT_FAILURE);
	}
	segments [nsegments].saddr = addr;
	segments [nsegments].nwords = len;
	nsegments++;
}

static void
seg_more (int len)
{
	if (optv > 3) {
		printf ("seg_more (+%d (0%04o))\n", len, len);
	}

	if (nsegments) {
		segments [nsegments - 1].nwords += len;
	} else {
		fprintf (stderr, "%s:  seg_more called with no segments in existence\n", progname);
		exit (EXIT_FAILURE);
	}
}

