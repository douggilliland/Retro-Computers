
/***************************** 68000 SIMULATOR ****************************

File Name: STRUTILS.C
Version: 1.0

This file contains various routines for manipulating strings

The routines are :  

	gettext(), same(), eval(), eval2(), getval(), strcopy(), mkfname(),
	pchange()

***************************************************************************/




#include <stdio.h>
#include "extern.h"


char *gettext(word,prompt)     /* returns pointer to scanned word, prompts */
int	word;                                      /* for input if necessary */
char	*prompt;
{
	int i, p, pwrd;

	if (wcount >= word) 
		return(wordptr[word-1]);
	else 
		errflg = TRUE;
	while (errflg)
		{
		printf("%s",prompt);
		
		if (gets(lbuf,20)==NULL) exit(0);
		scrollWindow();
		if ((p = scan(lbuf,wordptr,5)) < 1) 
			errflg = TRUE;
		else 
			{
			errflg = FALSE;
			pwrd = word - 1;
			for (i= (p-1);i>=0;i--)
				wordptr[pwrd + i] = wordptr[i];
			wcount = pwrd + p;
			}
		}
	return(wordptr[pwrd]);

}



int same(str1,str2)                         /* checks if two strings match */
char *str1, *str2;
{

	while (toupper(*str1++) == toupper(*str2++))
		if (*str1 == '\0') return 1;                        /* strings match */
	return 0;                                      /* strings are different */

}



int eval(string)                                        /* evaluate string */
char *string;
{
	char *tmpptr, bit;
	int value;

	errflg = FALSE;
	switch (*string)	/* look at the first character */
		{
		case '$':		/* hex input */
			if (sscanf(string+1,"%x",&value) != 1)
				errflg = TRUE;
			break;
		case '.':		/* decimal input */
			if (sscanf(string+1,"%d",&value) != 1)
				errflg = TRUE;
			break;
		case '@':		/* octal input */
			if (sscanf(string+1,"%o",&value) != 1)
				errflg = TRUE;
			break;
		case '\'':		/* ASCII input */
		case '\"':
			value = BYTE & *(string+1);
			break;
		case '%':		/* binary input */
			tmpptr = string;
			value = 0;
			while ((bit = *++tmpptr) != '\0')
				{
				value <<= 1;
				if (bit == '1') ++value;
				else if (bit != '0')
					{
					errflg = TRUE;
					break;
					}
				}
			break;
		default:		/* default is hex input */
			if (sscanf(string,"%x",&value) != 1)
				errflg = TRUE;
		}
	return value;

}



int eval2(string, result)      /* evaluate string and return result in the */
char *string;                                            /* long parameter */
long	*result;
{
	char *tmpptr, bit;
	long int value;

	errflg = FALSE;
	switch (*string)	/* look at the first character */
		{
		case '$':		/* hex input */
			if (sscanf(string+1, "%08lx", &value) != 1)
				errflg = TRUE;
			break;
		case '.':		/* decimal input */
			if (sscanf(string+1,"%d",&value) != 1)
				errflg = TRUE;
			break;
		case '@':		/* octal input */
			if (sscanf(string+1,"%o",&value) != 1)
				errflg = TRUE;
			break;
		case '\'':		/* ASCII input */
		case '\"':
			value = BYTE & *(string+1);
			break;
		case '%':		/* binary input */
			tmpptr = string;
			value = 0;
			while ((bit = *++tmpptr) != '\0')
				{
				value <<= 1;
				if (bit == '1') ++value;
				else if (bit != '0')
					{
					errflg = TRUE;
					break;
					}
				}
			break;
		default:		/* default is hex input */
			if (sscanf(string, "%08lx", &value) != 1)
				errflg = TRUE;
		}
	*result = value;
	return -1;

}



int getval(word,prompt)
int word;
char *prompt;
{
int value, p, i, pwrd;

	if (wcount >= word) 
		value = eval(wordptr[word-1]);
	else 
		errflg = TRUE;
	while (errflg)
		{
		printf("%s",prompt);
		if (gets(lbuf,20)==NULL) exit(0);
		scrollWindow();
		if ((p = scan(lbuf,wordptr,5)) < 1) 
			errflg = TRUE;
		else 
			{
			pwrd = word - 1;
			for (i= (p-1);i>=0;i--)
				wordptr[pwrd + i] = wordptr[i];
			wcount = pwrd + p;
			value = eval(wordptr[pwrd]);
			}
		}
	return value;

}



int strcopy(str1,str2)
char *str1, *str2;
{

	while (*str2++ = *str1++);
	return SUCCESS;

}



char *mkfname(cp1,cp2,outbuf)
char *cp1, *cp2, *outbuf;
{
	char *tptr;

	tptr = outbuf;
	while (*cp1 != '\0')
		*tptr++ = *cp1++;
	while (*cp2 != '\0')
		*tptr++ = *cp2++;
	*tptr = '\0';
	return outbuf;

}



int pchange(oldval)
char oldval;
{
	char nval;

	errflg = 0;
	if (gets(lbuf,80) == NULL) 
		exit(0);
	scrollWindow();
	wcount = scan(lbuf,wordptr,1);
	nval = oldval;
	if ((wcount > 0) && (!same(".",wordptr[0]))) {
		nval = eval(wordptr[0]);
		if (errflg)
			nval = oldval;
		}
	return nval;

}


