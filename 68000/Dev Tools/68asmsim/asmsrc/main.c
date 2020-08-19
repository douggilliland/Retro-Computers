/***********************************************************************
 *
 *		MAIN.C
 *		Main Module for 68000 Assembler
 *
 *    Function: main()
 *		Parses the command line, opens the input file and
 *		output files, and calls processFile() to perform the
 *		assembly, then closes all files. 
 *
 *	 Usage: main(argc, argv);
 *		int argc;
 *		char *argv[];
 *
 *      Author: Paul McKee
 *		ECE492    North Carolina State University
 *
 *        Date:	12/13/86
 *
 ************************************************************************/


#include <stdio.h>
#include <ctype.h>
#include "asm.h"


extern FILE *inFile;	/* Input file */
extern FILE *listFile;	/* Listing file */
extern FILE *objFile;	/* Object file */
extern char line[256];	/* Source line */
extern int errorCount, warningCount;	/* Number of errors and warnings */


extern char listFlag;	/* True if a listing is desired */
extern char objFlag;	/* True if an object code file is desired */
extern char xrefFlag;	/* True if a cross-reference is desired */
extern char cexFlag;	/* True is Constants are to be EXpanded */


int	main(argc, argv)
int argc;
char *argv[];
{
char fileName[64], outName[64], *p;
int i;

	puts("68000 Assembler by PGM\n");
	setFlags(argc, argv, &i);
	/* Check whether a name was specified */
	if (i >= argc) {
		fputs("No input file specified\n\n", stderr);
		help();
		}
	if (!strcmp("?", argv[i]))
		help();


	strcpy(fileName, argv[i]);
	inFile = fopen(fileName, "r");
	if (!inFile) {
		fputs("Input file not found\n", stderr);
		exit(0);
		}

	/****************************************************************
	 *								*
	 *	NOTE: The following filename manipulations are		*
	 *	intended for VMS filenames only. Other file naming	*
	 *	conventions may require changes here.			*
	 *								*
	 *	VMS filenames have the form				*
	 *								*
	 *	    node::device:[dir1.dir2.dir3]filename.ext;vers	*
	 *								*
	 *	For use here, we want the listing and object files	*
	 *	to be the most recent version in the default		*
	 *	directory, so we strip off the node, device, and	*
	 *	directory names, extension, and version number, then	*
	 *	append the appropriate file extension (.LIS or .H68)	*
	 *	for each file. 						*
	 *								*
	 ****************************************************************/

	/* Process output file names in their own buffer */
	strcpy(outName, fileName);

	/* Delete version number from output file names */
	p = strchr(outName, ';');
	if (p)
		*p = '\0';

	/* Remove directory name from output file names */
	p = outName + strlen(outName);
	while (p >= outName && *p != ':' && *p != ']')
		p--;
	if (p >= outName)
		strcpy(outName, ++p);
	
	/* Change extension to .LIS */
	p = strchr(outName, '.');
	if (!p)
		p = outName + strlen(outName);

	if (listFlag) {
		strcpy(p, ".LIS");
		initList(outName);
		}

	if (objFlag) {
		strcpy(p, ".H68");
		initObj(outName);
	}

	/* Assemble the file */
	processFile();

	/* Close files and print error and warning counts */
	fclose(inFile);
	if (listFlag) {
		putc('\n', listFile);
		if (errorCount > 0)
			fprintf(listFile, "%d error%s detected\n", errorCount,
				(errorCount > 1) ? "s" : "");
		else
			fprintf(listFile, "No errors detected\n");
		if (warningCount > 0)
			fprintf(listFile, "%d warning%s generated\n", warningCount,
				(warningCount > 1) ? "s" : "");
		else
			fprintf(listFile, "No warnings generated\n");
		fclose(listFile);
		}
	if (objFlag)
		finishObj();
	if (errorCount > 0)
		fprintf(stderr, "%d error%s detected\n", errorCount,
			(errorCount > 1) ? "s" : "");
	else
		fprintf(stderr, "No errors detected\n");
	if (warningCount > 0)
		fprintf(stderr, "%d warning%s generated\n", warningCount,
			(warningCount > 1) ? "s" : "");
	else
		fprintf(stderr, "No warnings generated\n");

	return NORMAL;

}


int	strcap(d, s)
char *d, *s;
{
char capFlag;

	capFlag = TRUE;
	while (*s) {
		if (capFlag)
			*d = toupper(*s);
		else
			*d = *s;
		if (*s == '\'')
			capFlag = (char) !capFlag;
		d++;
		s++;
		}
	*d = '\0';

	return NORMAL;

}


char *skipSpace(p)
char *p;
{
	while (isspace(*p))
		p++;
	return p;
}


int	setFlags(argc, argv, argi)
int argc;
char *argv[];
int *argi;
{
int option;

	while ((option = getopt(argc, argv, "cln", argi)) != EOF) {
		switch (option) {
			case 'c' : cexFlag = TRUE; break;
			case 'h' : help(); break;
			case 'l' : listFlag = TRUE; break;
			case 'n' : objFlag = FALSE; break;
			case '?' : help(); break;
			}
		}

	return NORMAL;

}


/**********************************************************************
 *
 *	Function getopt() scans the command line arguments passed
 *	via argc and argv for options of the form "-x". It returns
 *	the letters of the options, one per call, until all the
 *	options have been returned; it then returns EOF. The argi
 *	argument is set to the number of the argv string that
 *	is currently being examined.
 *
 *********************************************************************/

int getopt(argc, argv, optstring, argi)
int argc;
char *argv[];
char *optstring;
int *argi;
{
static char *scan = NULL;	/* Scan pointer */
static int optind = 0;		/* argv index */

char c;
char *place;
char *strchr();

	if (scan == NULL || *scan == '\0') {
		if (optind == 0)
			optind++;

		if (optind >= argc || argv[optind][0] != '-' || argv[optind][1] == '\0') {
			*argi = optind;
			return(EOF);
			}
		if (strcmp(argv[optind], "--")==0) {
			optind++;
			*argi = optind;
			return(EOF);
		}

		scan = argv[optind]+1;
		optind++;
	}

	c = *scan++;
	place = strchr(optstring, c);

	if (place == NULL || c == ':') {
		fprintf(stderr, "Unknown option -%c\n", c);
		*argi = optind;
		return('?');
	}

	place++;
	if (*place == ':') {
		if (*scan != '\0')
			scan = NULL;
		else
			optind++;
	}

	*argi = optind;
	return c;
}


/**********************************************************************
 *
 *	Function help() prints out a usage explanation if a bad
 *	option is specified or no filename is given.
 *
 *********************************************************************/

int	help()
{
	puts("Usage: asm [-cln] infile.ext\n");
	puts("Options: -c  Show full constant expansions for DC directives");
	puts("         -l  Produce listing file (infile.lis)");
	puts("         -n  Produce NO object file (infile.h68)");
	exit(0);
	return NORMAL;
}


