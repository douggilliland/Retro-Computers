/**
 * @file   redir.h
 * @brief  I/O redirection in command line.
 * @author Miguel I. Garcia Lopez / FloppySoftware
 *
 * Support library for I/O redirection in command line,
 * for MESCC (Mike's Enhanced Small C Compiler for Z80 & CP/M).
 *
 * Supported redirections:
 *  - echo < address.txt
 *  - echo 'Park Avenue, 234b' > address.txt
 *  - echo 'Call Elvis' >> todo.txt
 *
 * Revisions:
 *  - 08 Dec 2014 : 1st version.
 *  - 29 Nov 2016 : Support for '>>' redirection. Optimizations in NULL comparisons.
 *  - 07 Dec 2016 : GPL v3.
 *
 * Copyright (c) 2014-2016 Miguel I. Garcia Lopez / FloppySoftware.
 *
 * Licensed under the GNU General Public License v3.
 *
 * http://www.floppysoftware.es
 * floppysoftware@gmail.com
 */
#ifndef REDIR_H

#define REDIR_H

/**
 * @fn     int redir(int argc, char *argv[])
 * @brief  Stdin & stdout redirection in command line.
 * @param  argc - number of arguments
 * @param  argv - array of arguments
 * @return number of arguments after redirection parsing 
 */
redir(argc, argv)
int argc, argv[];
{
	int i, z; char *p;
	char *fnin, *fnout;
	FILE *fp;

#ifdef CC_FOPEN_A
	int append;
#endif

	fnin = fnout = NULL;

	for(i = 1; i < argc; ++i)
	{
		p = argv[i];

#ifdef CC_FOPEN_A
		if(((*p == '<' || *p == '>') && !(p[1])) || (*p == '>' && p[1] == '>' && !(p[2])))
#else
		if((*p == '<' || *p == '>') && !(p[1]))
#endif
		{
			if(i + 1 == argc)
				return -1;	/* No filename */

			if(*p == '<')
				fnin = argv[i + 1];
			else
			{
				fnout = argv[i + 1];

#ifdef CC_FOPEN_A
				append = p[1];
#endif
			}

			argc -= 2;

			for(z = i; z < argc; ++z)
				argv[z] = argv[z + 2];
			--i;
		}
	}

	if(fnin)
	{
		if((fp = fopen(fnin, "r")))
			stdin = fp;
		else
			return -2;
	}

	if(fnout)
	{
#ifdef CC_FOPEN_A
		if((fp = fopen(fnout, (append ? "a" : "w"))))
#else
		if((fp = fopen(fnout, "w")))
#endif
			stdout = fp;
		else
			return -3;
	}

	return argc;
}

#endif

