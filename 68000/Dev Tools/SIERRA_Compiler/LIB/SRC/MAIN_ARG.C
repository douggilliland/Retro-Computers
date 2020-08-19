/*
 *  main_arg.c
 *
 *  Copyright 1987, 1992 by Sierra Systems.  All rights reserved.
 */

#include <stdio.h>
#include <ctype.h>

#define CMDLEN	128	/* maximum length of a command line		*/
#define MAXARGS	32	/* maximum number of commands on a command line */

/*----------------------------- _main_arg() ---------------------------------*/

/*
 * _main_arg propts for command line arguments and calls main() with the
 * appropriate argc, argv vector
 */

int _main_arg()
{
    char cmd_line[CMDLEN];
    char *argv[MAXARGS];
    int argc;
    char *ptr;

    putc('>', stdout);
    putc(' ', stdout);
    fgets(cmd_line, CMDLEN, stdin);

#ifdef PASS_CMD_NAME
    argc = 0;
#else
    argc = 1;
    argv[0] = "";
#endif

    /* parse the command line */

    ptr = cmd_line;
    for( ; argc < MAXARGS; ) {
	while( (isspace)(*ptr) )
	    ptr++;
	if( *ptr == '\0' )
	    break;
	argv[argc++] = ptr;
	while( *ptr && !(isspace)(*ptr) )
	    ptr++;
	if( *ptr == '\0' )
	    break;
	else
	    *ptr++ = '\0';
    }
    argv[argc] = NULL;
    return(main(argc, argv));
}
