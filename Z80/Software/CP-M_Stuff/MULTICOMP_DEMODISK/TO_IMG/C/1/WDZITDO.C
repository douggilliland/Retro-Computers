/*
			WADUZITDO

	Mini-interpreter from Byte Magazine, The Byte Book of 
Pascal, by Larry Kheriaty.  WADUZITDO is a PILOT-like little 
language, that actually seems to be fairly useful.  My 8-year
old nephew took to it right away.  I wrote this version to
prove to myself how easy it is to translate Pascal to C; I
think Pascal is vastly over-rated.  This version I can
understand; the Pascal version I can't even get to run.

	Syntax as follows:

	T:string	Type string on console
	A:		Accept character from console
	M:character	Match 'character' against last
			character Accepted, set Y if the 
			same, N if not
	J:0		Jump back to last ACCEPT statement
	J:n		Jump forward to the nth program
			marker from here.  A program marker
			is a '*' at the beginning of a 
			statement.  1<= n <=9.
	S:		Stop execution of program. 
			MUST BE LAST STATEMENT IN PROGRAM!!!!!

In addition, any statement may have a 'Y' or 'N' attached to it
(after a '*', if one is present) for conditional execution.  
The status of the last 'M' executed is tested; if this status
and the conditional match, the statment is executed, otherwise
the statement is skipped.  All key chaaracters may be upper or
lower case.  

	Controls are as follows:

	'\'		Moves the 'cursor' to the beginning
			of the program
	BACKSPACE	Backs 'cursor' up one position
	'/'		Lists current program line
	'$'		Begin execution
	'%'		Deletes from current 'cursor' to EOL
			(a newline); actually replaces all
			characters with nulls. This gives a
			sort of 'insert' capability.

	Anything else simply goes into the buffer as a program
	character.  Of course, feel free to change any damn 
	thing you please.  

Very small, but kinda fun...

*/

#include <bdscio.h>

#define CLEAR 0x0c	/* Clear screen on my video */
#define BACKSPACE '\010'
#define do_forever for(;;)
#define BUFFSIZE 5000	/* Program buffer size */
#define TRUE 1
#define FALSE 0

char *p_cntr;
char cbuf;
char program[BUFFSIZE];

main()
{
char i;
putchar(CLEAR);
puts("\t\t\tWADUZITDO V.1.1\n\n>");
setmem(program,BUFFSIZE,'\0');
cbuf='\\';
do_forever{
	switch(cbuf){
		case '\\':p_cntr=program;
			  break;
		case BACKSPACE:if(p_cntr!=program)--p_cntr;
			  break;
		case '/' :putchar('\n');
			  list();
			  break;
		case '$' :putchar('\n');
			  execute();
			  break;
		case '%' :for(i=0;(i<64)&&(*p_cntr!='\n');++i)
				*p_cntr++ = '\0';
			  *p_cntr++ = '\n';
			  puts("\n");
			  break;
		default  :*p_cntr++ = cbuf;
		}
	if((cbuf = getchar()) == '\n')putchar('>');
	}
}

execute()
{
char done,flg,lchr,i,*lst;
p_cntr=program;
done=FALSE;
while(done != TRUE){
	cbuf = *p_cntr;
	if(cbuf<'*')cbuf='*';
	switch(toupper(cbuf)){
		case '*':++p_cntr;
			 break;
	case 'Y':case 'N':if(toupper(cbuf)==flg)++p_cntr;
		         else while((cbuf = *p_cntr++) != '\n');
		         break;
		case 'A':lst=p_cntr;
			 lchr=getchar();
			 puts("\n");
			 p_cntr += 3;
			 break;
		case 'M':p_cntr += 2;
			 flg = ((lchr == *p_cntr++) ? 'Y' : 'N');
			 break;
		case 'J':if(*(p_cntr+2) == '0')p_cntr=lst;
			 else {
				i = *(p_cntr+2)-'0';
				while(i)
				    if(*++p_cntr=='*')--i;
			      }
			 break;
		case 'T':p_cntr+=2;
			 list();
			 break;
		case 'S':done=TRUE;
			 p_cntr=program;
			 break;
		default: list();
		}
	}
}

list()
{
char i;
i=0;
do {
	putchar(cbuf = *p_cntr++);
   } while((++i<=64) && (cbuf != '\n'));
}
