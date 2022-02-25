#include <stdlib.h>
#include <stdio.h>
#include <ctype.h>
#include <string.h>

#include "as.h"
#include "table.h"
#include "lookup.h"


extern char *File_name;
extern int Line_num;
extern Err_count;
extern char *Optr;

/*
 *      fatal --- fatal error handler
 */
fatal(char *str)
{
	printf("%s\n",str);
	exit(-1);
}

/*
 *      error --- error in a line
 *                      print line number and error
 */
error(char *str)
{
	printf("%s,%d: %s\n",File_name,Line_num,str);
	Err_count++;
}

/*
 *      serror --- error in a line
 *                      print line number and error
 */
serror(char *fmt, char *s)
{
	printf("%s,%d: ",File_name,Line_num);
	printf(fmt,s);
	printf("\n");
	Err_count++;
}
/*
 *      warn --- trivial error in a line
 *                      print line number and error
 */
warn(char *str)
{
	extern	int	Pass;

	if(Pass==1)return;	/* save warnings till second pass */
	printf("%s,%d: ",File_name,Line_num);
	printf("Warning --- %s\n",str);
}


/*
 *      delim --- check if character is a delimiter
 */
delim(char c)
{
	return( isspace(c) );
}

/*
 *      skip_white --- move pointer to next non-whitespace char
 */
char *skip_white(char *ptr)
{
	while(*ptr==' ' || *ptr=='\t')
		ptr++;
	return(ptr);
}

/*
 *      any --- does str contain c?
 */
any(char c, char *str)
{
	while(*str)
		if(*str++ == c)
			return(1);
	return(0);
}

/*
 *      mapdn --- convert A-Z to a-z
 */
char mapdn(char c)
{
	return( isupper(c) ? tolower(c) : c);
}

/*
 *      loword --- return low word of a long
 */
loword(long i)
{
	return(i&0xFFFF);
}

/*
 *      hiword --- return high word of a long
 */
hiword(long i)
{
	return((i>>16)&0xFFFF);
}

/*
 *      lobyte --- return low byte of a long
 */
lobyte(long i)
{
	return(i&0xFF);
}

/*
 *      hibyte --- return high byte of a short int
 */
hibyte(int i)
{
	return((i>>8)&0xFF);
}

/*
 *      head --- is str2 the head of str1?
 */
head(char *str1, char *str2)
{
	while( *str1 && *str2 ){
		if( *str1 != *str2 )break;
		str1++;
		str2++;
		}
	if(*str1 == *str2)return(1);
	if(*str2=='\0')
		if( any(*str1," \t\n,+-];*.") )return(1);
	return(0);
}

/*
 *      alpha --- is character a legal letter
 */
alpha(char c)
{
	return( isalpha(c) || c== '_');
}
/*
 *      alphan --- is character a legal letter or digit
 */
alphan(char c)
{
	return( alpha(c) || isdigit(c) || c=='$');
}

/*
 *	white --- is character whitespace?
 */
white(char c)
{
	return( c == '\t' || c == ' ' || c == '\n' );
}

/*
 *      reverse --- reverse the bits in an int
 *
 *      Algorithm from Dr. Dobbs Journal #46, June/July 1980, p.48
 *      Original by C. Strachey [CACM 4:3 961 p.146]
 */
reverse(long val)
{
	static long mask[] = { 0x55555555, 0x33333333,
			      0x0F0F0F0F, 0x00FF00FF, 0x0000FFFF };
	long i = val;
	register int j = 16;
	register int k = 4;

	while(j){
		i = ((i&mask[k])<<j)|((i>>j)&mask[k]);
		j >>= 1;
		k--;
		}
	return(i);
}

/*
 *      next_str --- get next string from Operand field
 *
 *      The string is copied into a private buffer that gets
 *      overwritten on each call to next_str.  Returns NULL
 *      if no arguments are left.
 */
char *next_str()
{
	static char nsbuf[100];
	char *p = nsbuf;

	while( *Optr ){
		if( *Optr == ',' || *Optr == '\n'){
			Optr++;
			*p = '\0';
			return(nsbuf);
			}
		else
			*p++ = *Optr++;
		}
	return(NULL);
}
