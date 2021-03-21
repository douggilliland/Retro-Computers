/*
 * opt - three pass optimiser for small-C compiler
 *         (Small C compiler is Z80 version on CP/M UG UK Vol 15)
 *
 * usage: optimise source-file
 *        sources-file is assumed to have extension .zsm
 *        output file has extension .opt
 *
 * Program written by:   R M Yorston
 *                       147a Evesham Road
 *                       Headless Cross
 *                       Redditch
 *                       Worcs  B97 4LJ
 *
 * This program is completely and utterly in the public domain:
 * do whatever you like with it except sell it.
 *
 */

#include crun.lib
#include conio.lib
#include file.lib
#include string.lib
#include numio.lib

#define TRUE	1
#define FALSE	0

#define NULL	0
#define TAB	9
#define LF	10
#define CR	13
#define EOF	26
#define SPACE	32

#define CONBUF	130

int Ichan, Ochan ;
char Line1[256], Line2[256], Line3[256], Line[256] ;
char *Lastline, *Thisline, *Nextline, *Temp, *Tail ;
int Saved[9] ;


#asm
;/*
; * match - match token against string
; *         returns NULL if no match
; *         else returns pointer to Tail of string
; */
;match( token, input )
;char *token, *input ;
;{
;	while ( *input++ == *token++ ) ;
;	--token ;
;	if ( *token == NULL )
;		return --input ;
;	else
;		return NULL ;
;}
;
match:
	POP BC
	POP HL		;HL is input
	POP DE		;DE is token
	PUSH DE
	PUSH HL
	PUSH BC
match1:
	LD A,(DE)	;fetch *token
	CP (HL)
	JP NZ,match2	;return if *token != *input
	INC HL
	INC DE
	JP match1
match2:
	OR A
	RET Z		;return input if *token == NULL
	LD HL,0		;else return 0
	RET
#endasm


main()
{
	char file1[20], file2[20] ;
	char *pin ;

	pin = CONBUF - 2 ;
	if( *pin <= -1 ) {
		puts( "No files given" ) ;
		exit() ;
	}
	pin = CONBUF ;
	strcpy( file1, pin ) ;
	strcat( file1, ".zsm" ) ;
	strcpy( file2, pin ) ;
	strcat( file2, ".opt") ;

	open( file1, file2 ) ;
	pass1() ;

	open( file2, file1 ) ;
	pass2() ;

	open( file1, file2 ) ;
	pass3() ;

}


/*
 * open - open f1 for reading, f2 for writing
 *        Ichan is input channel number
 *        Ochan is output channel number
 */
open( f1, f2 )
char *f1, *f2 ;
{
	Ichan = fopen( f1, "r" ) ;
	if ( Ichan == 0 ) {
		puts( "Cannot open file" ) ;
		exit() ;
	}

	Ochan = fopen( f2, "w" ) ;
	if ( Ochan == 0 ) {
		puts ( "Cannot open file" ) ;
		exit() ;
	}
}


/*
 * getline - fetch line from input channel
 *           puts line at pointer, returns FALSE on end of file
 *           returns TRUE for successful get
 */
getline( pointer )
char *pointer ;
{
	char ch ;

	while ( ((ch=getc(Ichan)) != EOF) & (eof()==0) ) {
		if( ch == CR ) {
			*pointer = NULL ;
			getc(Ichan) ;
			return TRUE ;
		}
		else
			*pointer++ = ch ;
	}
	return FALSE ;
}

/*
 * putline - send line to output file
 */
putline( pointer )
char *pointer ;
{
	while ( *pointer ) {
		putc( *pointer++, Ochan ) ;
	}
	putc( CR, Ochan ) ;
	putc( LF, Ochan ) ;
}


/*
 * allnum - checks if string consists entirely of decimal numbers
 *          returns TRUE if it does
 */
allnum( string )
char *string ;
{
	while ( *string ) {
		if ( (*string<'0') | (*string>'9') ) {
			return FALSE ;
		}
		++string ;
	}
	return TRUE ;
}


pass1()
{
	int i ;

	Saved[0] = Saved[1] = Saved[2] = Saved[3] = Saved[4] = 0 ;
	Saved[5] = Saved[6] = Saved[7] = 0 ;

	getline( Line1 ) ;
	getline( Line2 ) ;

	Lastline = Line1 ;
	Thisline = Line2 ;
	Nextline = Line3 ;

	while ( getline( Nextline ) ) {

		/* negative constant */
		if (strcmp( "	CALL ccneg", Nextline) == 0) {
			if ( (Tail=match("	LD HL,",Thisline)) != NULL ) {
				if ( allnum( Tail ) ) {
					strcpy( Line, "	LD HL,0-" ) ;
					strcat( Line, Tail ) ;
					strcpy( Thisline, Line ) ;
					getline( Nextline ) ;
					++Saved[0] ;
				}
			}
		}

		/* double constant */
		if ( strcmp("	ADD HL,HL",Nextline) == 0 ) {
		  if( (Tail=match("	LD HL,",Thisline)) != NULL ) {
		    if( allnum( Tail ) ) {
			strcpy( Line, "	LD HL,2*" ) ;
			strcat( Line, Tail ) ;
			strcpy( Thisline, Line ) ;
			getline( Nextline ) ;
			++Saved[4] ;
		    }
		  }
		}

		/* push and pop round ld hl */
		if ( (strcmp("	PUSH HL", Lastline) == 0) ) {
		  if ( (strcmp("	POP DE", Nextline) == 0) ) {
		    if ( match("	LD HL,",Thisline) != NULL ) {
				strcpy( Lastline, "	EX DE,HL" ) ;
				getline(Nextline) ;
				++Saved[1] ;
		    }
		  }
		}

		/* zero subscript */
		if ( strcmp("	EX DE,HL",Lastline) == 0 ) {
		  if ( (strcmp("	LD HL,0",Thisline) == 0) |
		       (strcmp("	LD HL,2*0",Thisline) == 0) )  {
		    if ( strcmp("	ADD HL,DE",Nextline) == 0 ) {
			strcpy(Lastline,"	LD D,H") ;
			strcpy(Thisline,"	LD E,L") ;
			getline(Nextline) ;
			++Saved[2] ;
		    }
		  }
		}

		/* one subscript */
		if ( strcmp("	EX DE,HL",Lastline) == 0 ) {
		  if ( strcmp("	LD HL,1",Thisline) == 0 ) {
		    if ( strcmp("	ADD HL,DE",Nextline) == 0 ) {
			strcpy(Lastline,"	LD D,H") ;
			strcpy(Thisline,"	LD E,L") ;
			strcpy(Nextline,"	INC HL") ;
			++Saved[3] ;
		    }
		  }
		}

		/* two subscript */
		if ( strcmp("	EX DE,HL",Lastline) == 0 ) {
		  if ( (strcmp("	LD HL,2",Thisline) == 0) |
		       (strcmp("	LD HL,2*1",Thisline) == 0) )  {
		    if ( strcmp("	ADD HL,DE",Nextline) == 0 ) {
			putline( "	LD D,H" ) ;
			strcpy(Lastline,"	LD E,L") ;
			strcpy( Thisline, "	INC HL" ) ;
			strcpy( Nextline, "	INC HL" ) ;
			++Saved[6] ;
		    }
		  }
		}

		/* fetch int from top of stack */
		if ( strcmp("	LD HL,0", Lastline) == 0 ) {
		  if ( strcmp("	ADD HL,SP", Thisline) == 0 ) {
		    if ( strcmp("	CALL ccgint", Nextline ) == 0 ) {
			strcpy( Lastline, "	POP HL" ) ;
			strcpy( Thisline, "	PUSH HL" ) ;
			getline( Nextline ) ;
			++Saved[7] ;
		    }
		  }
		}

		/* fetch second int from top of stack */
		if ( strcmp("	LD HL,2", Lastline) == 0 ) {
		  if ( strcmp("	ADD HL,SP", Thisline) == 0 ) {
		    if ( strcmp("	CALL ccgint", Nextline ) == 0 ) {
			putline( "	POP BC" ) ;
			strcpy( Lastline, "	POP HL" ) ;
			strcpy( Thisline, "	PUSH HL" ) ;
			strcpy( Nextline, "	PUSH BC " ) ;
			++Saved[5] ;
		    }
		  }
		}


		putline( Lastline ) ;
		Temp = Lastline ;
		Lastline = Thisline ;
		Thisline = Nextline ;
		Nextline = Temp ;
	}
	putline( Lastline ) ;
	putline( Thisline ) ;

	puts("Negative constants:           "); putdec(Saved[0]) ; crlf() ;
	puts("Double constants:             "); putdec(Saved[4]) ; crlf() ;
	puts("PUSH HL, POP DE round LD HL:  "); putdec(Saved[1]) ; crlf() ;
	puts("Zero subscript:               "); putdec(Saved[2]) ; crlf() ;
	puts("One subscript:                "); putdec(Saved[3]) ; crlf() ;
	puts("Two subscript:                "); putdec(Saved[6]) ; crlf() ;
	puts("Fetch top of stack:           "); putdec(Saved[7]) ; crlf() ;
	puts("Fetch 2nd top of stack:       "); putdec(Saved[5]) ; crlf() ;
	crlf() ;
	i = Saved[0]*3 + Saved[1] + Saved[2]*3 + Saved[3]*2 + Saved[4] ;
	i = i + Saved[5]*3 + Saved[6] + Saved[7]*5 ;
	puts("Total bytes saved: ") ; putdec( i ) ; crlf() ;

	fclose( Ichan ) ;
	fclose( Ochan ) ;
}

pass2()
{
	int i ;

	Saved[0] = Saved[1] = Saved[2] = Saved[3] = Saved[4] = 0 ;
	Saved[5] = Saved[6] = Saved[7] = Saved[8] = 0 ;

	getline( Line1 ) ;
	getline( Line2 ) ;

	Lastline = Line1 ;
	Thisline = Line2 ;
	Nextline = Line3 ;

	while ( getline( Nextline ) ) {

		/* double EX DE,HL */
		if ( strcmp( "	EX DE,HL",Lastline) == 0 ) {
		  if ( strcmp( "	EX DE,HL",Thisline) == 0 ) {
		    Temp = Lastline ;
		    Lastline = Nextline ;
		    Nextline = Temp ;
		    getline( Thisline ) ;
		    getline( Nextline ) ;
		    ++Saved[0] ;
		  }
		}


		/* DE<-HL followed by EX DE,HL */
		if ( strcmp("	LD D,H",Lastline) == 0 ) {
		  if ( strcmp("	LD E,L",Thisline) == 0 ) {
		    if ( strcmp("	EX DE,HL",Nextline) == 0 ) {
			getline(Nextline) ;
			++Saved[1] ;
		    }
		  }
		}

		/* DE<-HL followed by LD HL */
		if ( strcmp("	LD D,H",Lastline) == 0 ) {
		  if ( strcmp("	LD E,L",Thisline) == 0 ) {
		    if ( match("	LD HL,",Nextline) != 0 ) {
			strcpy( Lastline, "	EX DE,HL" ) ;
			Temp = Thisline ;
			Thisline = Nextline ;
			Nextline = Temp ;
			getline(Nextline) ;
			++Saved[2] ;
		    }
		  }
		}

		/* expand ccpchar */
		if ( strcmp("	CALL ccpchar",Lastline) == 0 ) {
			putline( "	LD A,L" ) ;
			strcpy( Lastline, "	LD (DE),A" ) ;
			++Saved[8] ;
		}

		/* ccgint to DE expanded */
		if ( strcmp("	CALL ccgint",Lastline) == 0 ) {
		  if ( strcmp("	EX DE,HL",Thisline) == 0 ) {
		    if ( match("	LD HL,",Nextline) != NULL ) {
			putline( "	LD E,(HL)" ) ;
			strcpy( Lastline, "	INC HL" ) ;
			strcpy( Thisline, "	LD D,(HL)" ) ;
			++Saved[3] ;
		    }
		  }
		}

		/* expand ccgint */
		if( strcmp("	CALL ccgint", Lastline) == 0 ) {
			putline( "	LD A,(HL)" ) ;
			putline( "	INC HL" ) ;
			putline( "	LD H,(HL)" ) ;
			strcpy( Lastline, "	LD L,A" ) ;
			--Saved[4] ;
		}

		/* expand ccpint */
		if ( strcmp( "	CALL ccpint", Lastline) == 0 ) {
			putline( "	LD A,L" ) ;
			putline( "	LD (DE),A" ) ;
			putline( "	INC DE " ) ;
			putline( "	LD A,H" ) ;
			strcpy( Lastline, "	LD (DE),A" ) ;
			--Saved[5] ;
		}

		/* expand ccgchar to DE */
		if ( strcmp("	CALL ccgchar",Lastline) == 0 ) {
		  if ( strcmp("	EX DE,HL",Thisline) == 0 ) {
		    if ( match("	LD HL,",Nextline) != NULL ) {
			putline( "	LD A,(HL)" ) ;
			putline( "	LD E,A" ) ;
			putline( "	RLCA" ) ;
			strcpy( Lastline, "	SBC A,A" ) ;
			strcpy( Thisline, "	LD D,A" ) ;
			--Saved[6] ;
		    }
		  }
		}

		/* expand ccgchar */
		if ( strcmp("	CALL ccgchar",Lastline) == 0 ) {
			putline( "	LD A,(HL)" ) ;
			putline( "	LD L,A" ) ;
			putline( "	RLCA" ) ;
			putline( "	SBC A,A" ) ;
			strcpy( Lastline, "	LD H,A" ) ;
			--Saved[7] ;
		}

		putline( Lastline ) ;
		Temp = Lastline ;
		Lastline = Thisline ;
		Thisline = Nextline ;
		Nextline = Temp ;
	}
	putline( Lastline ) ;
	putline( Thisline ) ;

	puts("Double EX DE,HL:              "); putdec(Saved[0]) ; crlf() ;
	puts("DE<-HL, followed by EX DE,HL: "); putdec(Saved[1]) ; crlf() ;
	puts("DE<-HL, followed by LD HL:    "); putdec(Saved[2]) ; crlf() ;
	puts("Expand ccpchar:               "); putdec(Saved[8]) ; crlf() ;
	puts("Expand ccgint to DE:          "); putdec(Saved[3]) ; crlf() ;
	puts("Expand ccgint:                "); putdec(Saved[4]) ; crlf() ;
	puts("Expand ccpint:                "); putdec(Saved[5]) ; crlf() ;
	puts("Expand ccgchar to DE:         "); putdec(Saved[6]) ; crlf() ;
	puts("Expand ccgchar:               "); putdec(Saved[7]) ; crlf() ;
	crlf() ;
	i = Saved[0]*2 + Saved[1] + Saved[2] + Saved[3] + Saved[4] ;
	i = i + Saved[5]*2  + Saved[6] + Saved[7]*2 + Saved[8] ;
	puts("Total bytes saved: ") ; putdec( i ) ; crlf() ;

	fclose( Ichan ) ;
	fclose( Ochan ) ;
}

/*
 * islower - returns TRUE if character is lower case, else FALSE
 */
islower( ch )
char ch ;
{
	return (ch >= 'a') & (ch <= 'z') ;
}

/*
 * uncomma - split string with two tokens separated by commas
 */
uncomma( string, token1, token2 )
char *string, *token1, *token2 ;
{
	while ( *string != ',' )
		*token1++ = *string++ ;
	*token1 = 0 ;
	++string ;
	strcpy( token2, string ) ;
}

pass3()
{
	char source1[20], source2[20], dest1[20], dest2[20] ;
	char *tail2 ;
	int i ;

	Saved[0] = Saved[1] = Saved[2] = Saved[3] = Saved[4] = 0 ;
	Saved[5] = Saved[6] = 0 ;

	getline( Line1 ) ;
	getline( Line2 ) ;

	Lastline = Line1 ;
	Thisline = Line2 ;
	Nextline = Line3 ;

	while ( getline( Nextline ) ) {


		/* ld hl, ex, ld hl -> ld de, ld hl */
		if ( (Tail=match("	LD HL,",Lastline)) != NULL ) {
		  if ( strcmp("	EX DE,HL",Thisline) == 0 ) {
		    if ( match("	LD HL,",Nextline) != NULL ) {
			if ( *Tail != '(' ) {
				strcpy( Line, "	LD DE," ) ;
				strcat( Line, Tail ) ;
				strcpy( Lastline, Line ) ;
				Temp = Thisline ;
				Thisline = Nextline ;
				Nextline = Temp ;
				getline( Nextline ) ;
				++Saved[0] ;
			}
		    }
		  }
		}

		/* jump on zero round unconditional jump */
		if ( (Tail=match("	JP Z,",Lastline)) != NULL ) {
		  if ( match(Tail,Nextline) != NULL ) {
		    if ( (Tail=match("	JP ",Thisline)) != NULL ) {
		      if ( islower( *Tail ) ) {
				strcpy( Line, "	JP NZ," ) ;
				strcat( Line, Tail ) ;
				strcpy( Lastline, Line ) ;
				Temp = Thisline ;
				Thisline = Nextline ;
				Nextline = Temp ;
				getline( Nextline ) ;
				++Saved[1] ;
		      }
		    }
		  }
		}

		/* store followed by load */
		if ( (Tail=match("	LD ",Thisline)) != NULL ) {
		  if ( (tail2=match("	LD ",Nextline)) != NULL ) {
			uncomma( Tail, dest1, source1 ) ;
			uncomma( tail2, dest2, source2 ) ;
			if ( strcmp(dest1,source2) == 0 ) {
			  if ( strcmp(dest2,source1) == 0 ) {
				getline( Nextline ) ;
				++Saved[2] ;
			  }
			}
		  }
		}


		putline( Lastline ) ;
		Temp = Lastline ;
		Lastline = Thisline ;
		Thisline = Nextline ;
		Nextline = Temp ;
	}
	putline( Lastline ) ;
	putline( Thisline ) ;

	puts("LD HL;EX;LD HL > LD DE;LD HL: "); putdec(Saved[0]) ; crlf() ;
	puts("JP Z round JP:                "); putdec(Saved[1]) ; crlf() ;
	puts("Store followed by load:       "); putdec(Saved[2]) ; crlf() ;
	crlf() ;
	i = Saved[0] + Saved[1]*3 + Saved[2]*2 ;
	puts("Total bytes saved: ") ; putdec( i ) ; crlf() ;

	fclose( Ichan ) ;
	fclose( Ochan ) ;
}
