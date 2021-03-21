/*	$template.c

	Short description of this project. Replace $template in the contents of this file,
	with the real name of your program.

	Copyright (c) 2016-2018 Miguel Garcia / FloppySoftware

	This program is free software; you can redistribute it and/or modify it
	under the terms of the GNU General Public License as published by the
	Free Software Foundation; either version 3, or (at your option) any
	later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program; if not, write to the Free Software
	Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.

	Author's contact:

		www.floppysoftware.es
		cpm-connections.blogspot.com
		floppysoftware@gmail.com

	To compile with MESCC under CP/M:

		cc $template
		ccopt $template
		zsm $template
		hextocom $template

	Usage:

		$template [-options...] [filename...]

	Revisions:

		06 Jan 2016 : Last update of template.
		02 Jun 2016 : Add stderr support in usage(). Added error(). Add some comments.
		20 Jul 2016 : Remove CC_FILEIO_SMALL. Added CC_FOPEN_A, CC_FREAD, CC_FWRITE, CC_FGETS.
		11 Nov 2016 : Update GPL license to v3.
		30 Nov 2016 : Add APP_INFO. Update usage(). Improve command line parsing.
		18 Dec 2018 : Better descriptions.
*/

/* Defines for MESCC libraries
   ---------------------------
   Leave only what you need.
*/
#define CC_STDIO      // Support for stdin, stdout, stderr.
#define CC_REDIR      // Support for command line redirection - needs CC_STDIO.

#define CC_CONIO_BIOS // Console I/O through BIOS instead of BDOS.

#define CC_FCX        // Support for user number in filenames - ie: "a01:letter.doc".
#define CC_FCX_DIR    // Support for named directories (aliases) - needs CC_FCX and DirToDrvUsr() - ie: "docs:letter.doc".

#define CC_FOPEN_A    // Enable modes "a" and "ab" for fopen().
#define CC_FREAD      // Include fread().
#define CC_FWRITE     // Include fwrite().
#define CC_FGETS      // Include fgets().

#define CC_NO_MUL     // Exclude support for MULTIPLICATION.
#define CC_NO_DIV     // Exclude support for DIVISION and MODULUS.
#define CC_NO_SWITCH  // Exclude support for SWITCH.

#define CC_NO_ARGS    // Exclude support for ARGC and ARGV in main().

/* Standard MESCC library
   ----------------------
   You must include this library;
   it contains some defs. and the runtime.
*/
#include <mescc.h>

/* Standard MESCC libraries
   ------------------------
   Leave only what you need.
*/
#include <alloc.h>
#include <atexit.h>
#include <bsearch.h>
#include <clock.h>
#include <conio.h>
#include <cpm.h>
#include <ctype.h>
#include <fileio.h>
#include <fprintf.h>
#include <mem.h>
#include <printf.h>
#include <qsort.h>
#include <rand.h>
#include <setjmp.h>
#include <sprintf.h>
#include <stdbool.h>
#include <string.h>
#include <z80.h>

#ifdef CC_REDIR
	#include <redir.h>
#endif

/* Project libraries
   -----------------
*/
#include "$template.h"

/* Project defs.
   -------------
*/
#define APP_NAME    "$template"
#define APP_VERSION "v1.00 / 06 Jan 2016"
#define APP_COPYRGT "(c) 2016 FloppySoftware"
#define APP_INFO    "This program does something."
#define APP_USAGE   "$template [-option...] [filename...]"

/* Program entry
   -------------
*/
main(argc, argv)
int argc;
unsigned int argv[]; // char *argv[] - unsupported by MESCC (yet?)
{
	char *pch;
	int i, n, inopt;

	// Show usage if there are no arguments
	if(argc == 1)
		usage();

	// Check arguments in command line
	for(i = 1; i < argc; ++i)
	{
		pch = argv[i];

		if(*pch == '-' && pch[1])
		{
			// Option/s
			inopt = 1;

			while(inopt && *(++pch))
			{
				switch(*pch)
				{
					// -a
					case 'A' :
						// Do someting
						break;

					// -n256
					case 'N' :
						if(isdigit(*(++pch)))
						{
							n = atoi(pch);
							inopt = 0;
						}
						else
						{
							error("Bad argument");
						}
						break;
					default  :
						error("Bad option");
						break;
				}
			}
		}
		else
		{
			break;
		}
	}

	// Check filenames in command line
	if(i < argc)
	{
		// First filename is argv[i]
	}

	// Success
	exit(0);
}

/* Show usage and exit
   -------------------
*/
usage()
{
#ifdef CC_REDIR
	fprintf(stderr, "%s %s - %s\n\n", APP_NAME, APP_VERSION, APP_COPYRGT);
	fprintf(stderr, "%s\n\n", APP_INFO);
	fprintf(stderr, "Usage: %s\n\n", APP_USAGE);
#else
	printf("%s %s - %s\n\n", APP_NAME, APP_VERSION, APP_COPYRGT);
	printf("%s\n\n", APP_INFO);
	printf("Usage: %s\n\n", APP_USAGE);
#endif

	exit(0);
}

/* Print error and exit
   --------------------
*/
error(msg)
char *msg;
{
#ifdef CC_REDIR
	fprintf(stderr, "%s: %s\n", APP_NAME, msg);
#else
	printf("%s: %s\n", APP_NAME, msg);
#endif

	exit(-1);
}

