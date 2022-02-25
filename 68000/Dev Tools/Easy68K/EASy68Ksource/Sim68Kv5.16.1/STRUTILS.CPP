
/***************************** 68000 SIMULATOR ****************************

File Name: STRUTILS.C
Version: 1.0

This file contains various routines for manipulating strings

The routines are :  

	getText(), same(), eval(), eval2(), getval(), strcopy(), mkfname(),
	pchange()

***************************************************************************/



#include <iostream.h>
#include <stdio.h>
#include "extern.h"


char *getText(int WORD_MASK, char *prompt)     /* returns pointer to scanned WORD_MASK, prompts */
{
	int i, p, pwrd;

	if (wcount >= WORD_MASK)
		return(wordptr[WORD_MASK-1]);
	else
		errflg = true;
	while (errflg)
		{
		printf("%s",prompt);
                cin.getline(lbuf,20);
		if (*lbuf==NULL) exit(0);
		scrollWindow();
		if ((p = scan(lbuf,wordptr,5)) < 1) 
			errflg = true;
		else 
			{
			errflg = false;
			pwrd = WORD_MASK - 1;
			for (i= (p-1);i>=0;i--)
				wordptr[pwrd + i] = wordptr[i];
			wcount = pwrd + p;
			}
		}
	return(wordptr[pwrd]);

}



int same(char *str1, char *str2)                         /* checks if two strings match */
{

	while (toupper(*str1++) == toupper(*str2++))
		if (*str1 == '\0') return 1;                        /* strings match */
	return 0;                                      /* strings are different */

}



int eval(char *string)                                        /* evaluate string */
{
	char *tmpptr, bit;
	int value;

	errflg = false;
	switch (*string)	/* look at the first character */
		{
		case '$':		/* hex input */
			if (sscanf(string+1,"%x",&value) != 1)
				errflg = true;
			break;
		case '.':		/* decimal input */
			if (sscanf(string+1,"%d",&value) != 1)
				errflg = true;
			break;
		case '@':		/* octal input */
			if (sscanf(string+1,"%o",&value) != 1)
				errflg = true;
			break;
		case '\'':		/* ASCII input */
		case '\"':
			value = BYTE_MASK & *(string+1);
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
					errflg = true;
					break;
					}
				}
			break;
		default:		/* default is hex input */
			if (sscanf(string,"%x",&value) != 1)
				errflg = true;
		}
	return value;

}



int eval2(char *string, long *result)      /* evaluate string and return result in the */
{
	char *tmpptr, bit;
	long int value;

	errflg = false;
	switch (*string)	/* look at the first character */
		{
		case '$':		/* hex input */
			if (sscanf(string+1, "%08lx", &value) != 1)
				errflg = true;
			break;
		case '.':		/* decimal input */
			if (sscanf(string+1,"%d",&value) != 1)
				errflg = true;
			break;
		case '@':		/* octal input */
			if (sscanf(string+1,"%o",&value) != 1)
				errflg = true;
			break;
		case '\'':		/* ASCII input */
		case '\"':
			value = BYTE_MASK & *(string+1);
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
					errflg = true;
					break;
					}
				}
			break;
		default:		/* default is hex input */
			if (sscanf(string, "%08lx", &value) != 1)
				errflg = true;
		}
	*result = value;
	return -1;

}



int getval(int WORD_MASK, char *prompt)
{
int value, p, i, pwrd;

	if (wcount >= WORD_MASK)
		value = eval(wordptr[WORD_MASK-1]);
	else
		errflg = true;
	while (errflg)
		{
		printf("%s",prompt);
                cin.getline(lbuf,20);
		if (*lbuf==NULL) exit(0);
		scrollWindow();
		if ((p = scan(lbuf,wordptr,5)) < 1)
			errflg = true;
		else
			{
			pwrd = WORD_MASK - 1;
			for (i= (p-1);i>=0;i--)
				wordptr[pwrd + i] = wordptr[i];
			wcount = pwrd + p;
			value = eval(wordptr[pwrd]);
			}
		}
	return value;

}



int strcopy(char *str1, char *str2)
{
  while ((*str2++ = *str1++) != 0);
  return SUCCESS;
}



char *mkfname(char *cp1, char *cp2, char *outbuf)
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



int pchange(char oldval)
{
	char nval;

	errflg = 0;
        cin.getline(lbuf,80);
	if (*lbuf == NULL)
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