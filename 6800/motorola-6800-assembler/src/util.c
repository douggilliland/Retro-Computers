
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "util.h"
#include "as.h"
#include "globals.h"

/*
 *      fatal --- fatal error handler
 */
void fatal(char *str)
{
	printf("%s\n",str);
	exit(-1);
}

/*
 *      error --- error in a line
 *                      print line number and error
 */
void error(char *str)
{
	if(N_files > 1)
		printf("%s,",Argv[Cfn]);
	printf("%d: ",Line_num);
	printf("%s\n",str);
	Err_count++;
}

/*
 *      warn --- trivial error in a line
 *                      print line number and error
 */
void warn(char *str)
{
	if(N_files > 1)
		printf("%s,",Argv[Cfn]);
	printf("%d: ",Line_num);
	printf("Warning --- %s\n",str);
}

/*
 *      delim --- check if character is a delimiter
 */
int delim(char c)
{
	if( any(c," \t\n"))
		return(YES);
	return(NO);
}

/*
 *      skip_white --- move pointer to next non-whitespace char
 */
char *skip_white(char *ptr)
{
	while(*ptr==BLANK || *ptr==TAB)
		ptr++;
	return(ptr);
}

/*
 *      eword --- emit a word to code file
 */
void eword(int wd)
{
	emit(hibyte(wd));
	emit(lobyte(wd));
}

/*
 *      emit --- emit a byte to code file
 */
int emit(int byte)
{
#ifdef DEBUG
	printf("%2x @ %4x\n",byte,Pc);
#endif
	if(Pass==1){
		Pc++;
		return(YES);
		}
	if(P_total < P_LIMIT)
		P_bytes[P_total++] = byte;
	E_bytes[E_total++] = byte;
	Pc++;
	if(E_total == E_LIMIT)
		f_record();
	return(NO);
}

/*
 *      f_record --- flush record out in `S1' format
 */
void f_record(void)
{
	int     i;
	int     chksum;

	if(Pass == 1)
		return;
	if(E_total==0){
		E_pc = Pc;
		return;
		}
	chksum =  E_total+3;    /* total bytes in this record */
	chksum += lobyte(E_pc);
	chksum += E_pc>>8;
	fprintf(Objfil,"S1");   /* record header preamble */
	hexout(E_total+3);      /* byte count +3 */
	hexout(E_pc>>8);        /* high byte of PC */
	hexout(lobyte(E_pc));	/* low byte of PC */
	for(i=0;i<E_total;i++){
		chksum += lobyte(E_bytes[i]);
		hexout(lobyte(E_bytes[i]));	/* data byte */
		}
	chksum =~ chksum;       /* one's complement */
	hexout(lobyte(chksum));	/* checksum */
	fprintf(Objfil,"\n");
	E_pc = Pc;
	E_total = 0;
}

char    *hexstr = { "0123456789ABCDEF" } ;

void hexout(int byte)
{
	char hi,lo;

	byte = lobyte(byte);
	fprintf(Objfil,"%c%c",hexstr[byte>>4],hexstr[byte&017]);
}

/*
 *      print_line --- pretty print input line
 */
void print_line(void)
{
	int     i;
	register char *ptr;

        printf ("%04d ",Line_num);
	if(P_total || P_force)
		printf("%04x",Old_pc);
	else
		printf("    ");

	for(i=0;i<P_total && i<6;i++)
		printf(" %02x",lobyte(P_bytes[i]));
	for(;i<6;i++)
		printf("   ");
	printf("  ");

	if(Cflag){
		if(Cycles)
			printf("[%2d ] ",Cycles);
		else
			printf("      ");
		}
	ptr = Line;
	while( *ptr != '\n' )   /* just echo the line back out */
		putchar(*ptr++);
	for(;i<P_total;i++){
		if( i%6 == 0 )
			printf("\n    ");
		printf(" %02x",lobyte(P_bytes[i]));
		}
	printf("\n");
}

/*
 *      any --- does str contain c?
 */
int any(char c, char *str)
{
	while(*str != EOS)
		if(*str++ == c)
			return(YES);
	return(NO);
}

/*
 *      mapdn --- convert A-Z to a-z
 */
char mapdn(char c)
{
	if( c >= 'A' && c <= 'Z')
		return(c+040);
	return(c);
}

/*
 *      lobyte --- return low byte of an int
 */
int lobyte(int i)
{
	return(i&0xFF);
}

/*
 *      hibyte --- return high byte of an int
 */
int hibyte(int i)
{
	return((i>>8)&0xFF);
}

/*
 *      head --- is str2 the head of str1?
 */
int head(char *str1, char *str2)
{
	while( *str1 != EOS && *str2 != EOS){
		if( *str1 != *str2 )break;
		str1++;
		str2++;
		}
	if(*str1 == *str2)return(YES);
	if(*str2==EOS)
		if( any(*str1," \t\n,+-];*") )return(YES);
	return(NO);
}

/*
 *      alpha --- is character a legal letter
 */
int alpha(char c)
{
	if( c<= 'z' && c>= 'a' )return(YES);
	if( c<= 'Z' && c>= 'A' )return(YES);
	if( c== '_' )return(YES);
	if( c== '.' )return(YES);
	return(NO);
}

/*
 *      alphan --- is character a legal letter or digit
 */
int alphan(char c)
{
	if( alpha(c) )return(YES);
	if( c<= '9' && c>= '0' )return(YES);
	if( c == '$' )return(YES);      /* allow imbedded $ */
	return(NO);
}

/*
 *	white --- is character whitespace?
 */
int white(char c)
{
	if( c == TAB || c == BLANK || c == '\n' )return(YES);
	return(NO);
}

/*
 *	alloc --- allocate memory
 */
char *alloc(int nbytes)
{
	//char *malloc();	// This prototype is not needed.

	return(malloc(nbytes));
}

