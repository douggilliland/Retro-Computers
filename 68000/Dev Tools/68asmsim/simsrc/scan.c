
/***************************** 68000 SIMULATOR ****************************

File Name: SCAN.C
Version: 1.0

This file contains the routine scan() which is used to scan strings that
were input at the simulator command line.

***************************************************************************/


#include "extern.h"


scan (str, ptrbuf, maxcnt)               /* scan up to maxcnt words in str */
char	*str;
char	*ptrbuf[];
int	maxcnt;
{
	int count;
	char qflag;

	count = 0;
	qflag = 0;
	while (*str)
		{
		if (*str == ';' && !qflag) break;		/* comment introducer */
		if (count == maxcnt) break;				/* enough words scanned */
		while (iswhite(*str++,&qflag));			/* flush leading white space */
		if (*--str)
			{
			ptrbuf[count++] = str;
			while (!iswhite(*++str,&qflag))		/* find end of */
				if (!*str) return(count);			/* non-white space */
			*str++ = '\0';
			}
		}

	return count;

}



iswhite (c, qflag)
char c, *qflag;
{

	if (c == '\'') *qflag = ~*qflag;
	if (*qflag) return(0);					/* inside a pair of 'quotes' */
	if (c == ' ') return(1);
	if (c == '\t') return(1);
	if (c == '\n') return(1);

	return (0);

}


