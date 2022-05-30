/*
 * This file is part of the CC8 OS/8 C compiler.
 *
 * The CC8 OS/8 C compiler is free software: you can redistribute it
 * and/or modify it under the terms of the GNU General Public License 
 * as published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * The CC8 OS/8 C compiler is distributed in the hope that it will be
 * useful, but WITHOUT ANY WARRANTY; without even the implied warranty
 * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with the CC8 OS/8 C compiler as ../GPL3.txt.  If not, see
 * <http://www.gnu.org/licenses/>.
 */

/*
 * PDP8/E LIBC routines for Small-C compiler.
 *
 * This is a complex collection of mixed C and SABR assembly routines.
 * Some functions have been substantially shortened to save space
 * relative to the original versions.  Over time, we expect to rewrite
 * the remaining pure C routines in hand-optimized SABR.
 */

#asm
// DECLARE LIBC GLOBALS.  ALTHOUGH THESE OVERLAP THOSE DECLARED IN
// INIT.H AND HEADER.SB, THOSE ARE IN A DIFFERENT FIELD AND BELONG
// TO CODE IN THAT FIELD.  THERE IS NO PARTICULAR NEED FOR THESE
// VARIABLES TO MATCH UP TO THOSE IN ANY WAY.  CODE IN NEITHER FIELD
// MODIFIES THE OTHER'S GLOBALS.
/ 000 AND 001 BELONG TO THE PDP-8 INTERRUPT SYSTEM
/ 002 THRU 007 ARE RESERVED FOR USER CODE
/ 010-017 ARE THE PDP-8 AUTO-INDEX REGISTERS; YES, IN ALL FIELDS!
/ 020-177 BELONG TO [F]PRINTF; SEE BELOW
ABSYM POP 147
ABSYM PSH 150
ABSYM JLC 151
ABSYM STKP 152
ABSYM PTSK 153
ABSYM POPR 154
ABSYM PCAL 155
ABSYM TMP 156
ABSYM GBL 157
ABSYM ZTMP 146
ABSYM ZPTR 145
ABSYM ZCTR 144
ABSYM FPTR 160
/
/
/
/
/
		DUMMY ARGST
		DUMMY ARGNM
ARGST,	BLOCK 2
ARGNM,	BLOCK 2
/
		ENTRY LIBC
LIBC,	BLOCK 2
		CLA CLL
		TAD I LIBC
		DCA ARGST
		INC LIBC#
		TAD I LIBC
		DCA ARGST#
		INC LIBC#
		TAD I ARGST
		DCA STKP
		IAC
		TAD LCALL	/ INIT ? LCALL==-1 
		SZA CLA
		JMP LB1
		TAD STKP
		DCA GBL		/ SET LOCAL GBL(LITPTR)
		ISZ GBL
		TAD PVL
		DCA PSH
		TAD OVL
		DCA POP
		TAD MVL
		DCA PTSK
		TAD PVR
		DCA POPR
		TAD PVC
		DCA PCAL
		RIF
		TAD (6201		/ BUILD CDF + IF INSTR...
		DCA PCL1		/ ...AND SAVE AS FIRST OF PCL1 SUBROUTINE
		TAD PCL1
		DCA DCC0
		JMS MCC0
		TAD STKP
		DCA I ARGST		/ UPDATE MASTER STKP
		DCA ZPTR		/ INIT PRINTF FLAG
		DCA FPTR		/ INIT FPRINTF FLAG
LB1,	ACL				/ CALL INDEX IN MQ
		SPA
		JMP LRET
		TAD CPNT
		DCA LCALL
		TAD I LCALL
		DCA LCALL
		JMSI PCAL
LCALL,	-1
		RETRN LIBC
LRET,	CLA MQL
		DCA LCALL		/ INIT OK
		RETRN LIBC
/
PUSH,	0
		CDF1
		ISZ STKP
		DCAI STKP
		TADI STKP
		JMPI PUSH
PPOP,	0
		CDF1
		DCA TMP
		TADI STKP
		MQL
		CMA
		TAD STKP
		DCA STKP
		TAD TMP
		JMPI PPOP
PUTSTK,	0
		JMSI POP
		SWP
		DCA JLC
		SWP
		DCAI JLC
		TADI JLC
		JMPI PUTSTK
POPRET,	JMSI POP
		SWP
		DCA ZTMP
		TAD STKP
		DCA I ARGST		/ UPDATE MASTER STKP
		SWP
		CDF1
		JMPI ZTMP
PCALL,	0
		CLA CLL
PCL1,	0
		TADI PCALL
		DCA ZTMP
		TAD PCALL
		IAC
		JMSI PSH		/ PUSH RETURN
		CLA
		TAD STKP
		DCA I ARGST		/ UPDATE MASTER STKP
		CDF1
		JMPI ZTMP
PVL,	PUSH
OVL,	PPOP
MVL,	PUTSTK
PVR,	POPRET
PVC,	PCALL
/
CPNT,	CLIST
		CPAGE 41        / # OF ENTRIES IN CLIST BELOW, IN OCTAL
/
/		THIS IS THE DISPATCH LIST FOR THIS LIBRARY
/		MAKE SURE LIBC.H MATCHES
/
CLIST,  ITOA
		PUTS
		DISPXY
		GETC
		GETS
		ATOI
		STRPD
		XINIT
		MEMCPY
		KBHIT
		PUTC
		STRCPY
		STRCAT
		STRSTR
		EXIT
		ISNUM
		ISALPHA
		TOUPPER
		MEMSET
		FGETC
		FOPEN
		FPUTC
		FCLOSE
		REVCPY
		ISALNUM
		ISSPACE
		FGETS
		FPUTS
		STRCMP
		CUPPER
		FPRINTF
		PRINTF
        SPRINTF
		SSCANF
        SCANF
        FSCANF
#endasm

#define stdout 0
#define NULL 0
#define isdigit isnum



fgetc()
{
#asm

	CLA CLL
	CALL 2,CHRIO
	ARG (-4
	ARG FRSL
	TAD FRSL
	TAD (D-26		/^Z
	SNA CLA
	DCA FRSL
	TAD FRSL
	CDF1
	JMPI POPR
FRSL,BLOCK 2

//	CHRIO - CHARACTER I/O.
/
/	CALL CHRIO(IDEVN,ICHAR)
/
/	IDEV = FORT II DEVICE NUMBER.
/
/	ICHAR = 7 OR 8 BIT CHARACTER.
/
/	IF IDEV IS POSITIVE, THE CHAR IS OUTPUTTED.
/
/	IF IDEV IS NEGATIVE, THE NEXT CHAR IS
/	READ FROM THE DEVICE, AND PUT IN ICHAR.
/
//
		ENTRY CHRIO
CHRIO,	BLOCK 2
	JMS GETP
	SPA		/WHAT IS DEVICE SIGN?
	JMP RCHAR	/NEG DEV.   MEANS READ.
	JMS SETDEV	/POS DEV.  MEANS WRITE.
	0000
	JMS GETP
	DCA ICHAR
	JMS CHSUB
	JMP XIT

IDEV,	0
ICHAR,	0
ADDR,	0

RCHAR,	CIA		/READ A CHAR.
	JMS SETDEV
	2000		/SET BIT FOR READ. (8 UNITS NOW!)
	JMS GETP
	CLA
	TAD CDFB
	DCA CDFCH
	JMS CHSUB
CDFCH,	HLT
	AND (177	/ 7 BIT FOR NOW
	DCAI ADDR
XIT,	CLA
	RETRN CHRIO

SETDEV,	0
	TAD (-1
	AND (7
	CLL RAR;RTR;RTR
	TAD I SETDEV
	INC SETDEV
	DCA IDEV
	JMP I SETDEV

CHSUB,	0
	TAD ICHAR
	AND (377	/ DEAL IN 8 BIT CHARS, MAX
	TAD IDEV
	CALL 0,GENIO
	JMP I CHSUB

GETP,	0
	TAD CHRIO
	DCA CDFA
CDFA,	HLT
	TADI CHRIO#
	DCA CDFB
	INC CHRIO#
	TADI CHRIO#
	DCA ADDR
	INC CHRIO#
CDFB,	HLT
	TADI ADDR
	JMP I GETP
#endasm
}

fputc(ch)
int ch;
{
	ch;
#asm
	DCA FRSL
	CALL 2,CHRIO
	ARG (4
	ARG FRSL
	CDF1
	TAD FRSL
#endasm
}
		sixbit(p)
char *p;
{
	*p++;
#asm
		AND (77		/ MASK OFF LOWER 6 BITS
		BSW
		MQL
#endasm
	*p;
#asm
		AND (77
		MQA
#endasm
}

fputs(p)
int *p;
{
	while (*p++)
#asm
		DCA FRSL
		CALL 2,CHRIO
		ARG (4
		ARG FRSL
		CDF1
#endasm
}

xinit()
{
	puts("PDP-8 C Compiler V2.0:\r\n");
}


memcpy(dst,src,cnt)
int dst,src,cnt;
{
#asm
	CLA
	TAD STKP
	TAD (-4
	DCA 14
	CMA
	TADI 14
	DCA 13
	CMA
	TADI 14
	DCA 12
	TADI 14
	CIA
	DCA ZTMP
CP1,	TADI 12
		DCAI 13
		ISZ ZTMP
		JMP CP1
#endasm

}

kbhit()
{
#asm
		CLA CMA
		KSF
		CLA
#endasm	
}


fopen (fnm,flg)
char *fnm;
int flg;
{
	char *p;
	p=fnm;
	p=strstr(fnm,".");
	if (p==0)
		return(-1);
	if (*flg=='w') {
#asm
		CLA
		TAD FC1#
		DCA FBSE#
		JMP FC3
FC1,	CALL 0,OOPEN
FC2,	CALL 0,IOPEN
#endasm
	}
	if (*flg=='r') {
#asm
		CLA
		TAD FC2#
		DCA FBSE#
FC3,	CDF1
#endasm
	*p++=0;
	sixbit(p);
#asm
		PAGE
		DCA ZTMP
		TAD FC2#		/ CODE
		AND (77
		TAD (200
		DCA FDCT
		CDF0
		TADI FDCT
		DCA FEX1
		TAD FDCT
		TAD (100
		DCA FDCT
		TADI FDCT
		TAD (121		/ OFFSET OF EXTENSION (FILEEX) IN IOPEN CODE
		DCA FDCT
FEX1,	HLT
		TAD ZTMP
		DCAI FDCT
		CDF1
#endasm
	fnm;
#asm
		DCA ZTMP	/ PACK 6 8BIT CHARS INTO FILENAME
		TAD (-3
		DCA FDCT
		TAD FDCA
		DCA FP4
FP1,	CAM
		TADI ZTMP
		SNA
		JMP FP2
		AND (77		/ MASK OFF LOWER 7 BITS
		BSW
		MQL
		ISZ ZTMP
FP2,	TADI ZTMP	/ WILL USE STACK FIELD
		AND (77
		SZA
		ISZ ZTMP
		MQA
FP4,	DCA FFNM
		ISZ FP4
		ISZ FDCT
		JMP FP1
		TAD (56     / ASCII '.'
		DCAI ZTMP	/ PUT . BACK INTO FNM
		CLA CLL CMA
		TAD STKP
		DCA STKP
FBSE,	CALL 2,IOPEN
		ARG FDEV
		ARG FFNM
		JMPI POPR
FDCA,	DCA FFNM
FDCT,	0
FFNM,	TEXT /TM@@@@/
FDEV,	TEXT /DSK@@@/
#endasm
	}
}

fclose()
{
#asm
		CALL 0,OCLOS
#endasm
}


puts(p)
char *p;
	{
		while (*p++) 
#asm
		TLS
XC1,	TSF
		JMP XC1
#endasm
	}

dispxy(x,y)
int x,y;
{
	x;      /* put x param in AC */
#asm
	DILX	/ load x into display X reg
#endasm
	y;
#asm
	DILY	/ load y into display Y reg
	DIXY	/ pulse display at loaded X,Y coordinate
#endasm
}

getc()
{
#asm
	 CLA CLL
GT1, KSF
	 JMP GT1
	 KRB
	 TAD (D-254
	 CLA
	 KRB
	 SNL			/ DO NOT ECHO BS
	 TLS
	 TAD (D-131		/ ? ^C
	 SNA CLA
	 JMP OSRET
	 KRB
	 AND (177		/ 7 BITS!
#endasm
}

gets(p)
char *p;
{
int q,tm;
		tm=1;
		q=p;
		while (tm) {
		getc();
#asm
		AND (177
		TAD (D-13	/ CR IS END OF STRING -> 0
		SZA
		TAD (D13
	    DCAI STKP
#endasm
		if (tm-127)	/* Handle BS */
		  *p++=tm;
		else
			if (p-q) {
		   puts("\b \b");
		   p--;
			}
	}
	putc(10);	/* newline */
	return q;		
}

atoi(p,rsl)
char *p;
int *rsl;
{
    *p;
#asm
    OPDEF MUY 7405

    CLA CLL
   	DCA ZTMP        / FINAL VALUE
	DCA ZCTR        / CAHR COUNTER
AT777,    TADI JLC
    TAD(-40         / SPACE+1
    SZA CLA
    JMP AT000
    ISZ JLC
    JMP AT777
AT000,	TAD (7000		/ NOP
	DCA TMP             / STORE SIGN
	TADI JLC
	TAD (-55		/ -
	SZA CLA
	JMP AT001
	TAD (7041		/ CIA
	DCA TMP
	ISZ JLC
	ISZ ZCTR
AT001,	TAD (12		/ DEFAULT BASE 10
	DCA FPTR
	TADI JLC
	TAD (-60		/ 0
	SZA CLA
	JMP AT004
	TAD (10
	DCA FPTR
	ISZ JLC
	ISZ ZCTR
AT002,	TADI JLC
	TAD (-170		/ LC X
	SZA CLA
	JMP AT003
	TAD (20
	DCA FPTR
	ISZ JLC
	ISZ ZCTR
AT003,	TADI JLC
	TAD (-142		/ LC B
	SZA CLA
	JMP AT004
	CLA CLL IAC RAL
	DCA FPTR
	ISZ JLC
	ISZ ZCTR
AT004,	TADI JLC
	SNA
	JMP AT006
	TAD (-60		/ 0
	SPA
	JMP AT006
	TAD (-12		/ 10
	SMA
	JMP AT005
	TAD (12
    JMP AT51        / RANGE 0-9
AT005,  TAD (-47    / LC A-F 0-5
     SPA
     JMP AT006
     TAD (12
AT51,    DCA ZPTR
    TAD FPTR
    CIA
    TAD ZPTR
    SMA CLA
    JMP AT006
    TAD ZTMP
	CALL 1,MPY
    ARG FPTR
	CDF1
	TAD ZPTR
	DCA ZTMP
	ISZ JLC
	ISZ ZCTR
	JMP AT004
AT006,	CLA
    TAD TMP
    DCA XINV
    CLA CLL CMA
	TAD STKP
	DCA TMP
	TADI TMP
	DCA TMP
	TAD ZTMP
XINV,	NOP
	DCAI TMP
    DCA FPTR
    DCA ZPTR
	TAD ZCTR	
#endasm
;
}



putc(p)
char p;
{
	p;
#asm
		TLS
MP1,	TSF
		JMP MP1
#endasm
}

strcmp( dm , sm )
char *dm,*sm;
{
	int rsl;

	rsl=0;
	while (*dm)
		rsl|=(*sm++-*dm++);
	return rsl;
}

strcpy( dm , sm )
char *dm,*sm;
{
	while (*dm++=*sm++);
}

strcat( dm , sm )
char *dm,*sm;
{
	int qm;
	qm=dm;
	while(*dm) dm++;
	strcpy(dm,sm);
	return qm;
}

strstr ( s , o )
char *s , *o ;
{
char *x , *y , *z ;
 for ( x = s ; * x ; x ++ ) {
  for ( y = x , z = o ; * z && * y == * z ; y ++ ) z ++ ;
  if ( z >= o && ! * z ) return x ;
 } return 0 ;
}

exit(retval)
int retval;
{
#asm
OSRET,	CALL 0,EXIT
		HLT
#endasm
}

isalnum(vl)
int vl;
{
	return (isnum(vl) + isalpha(vl));
}

isnum(vl)
int vl;
{
		vl;
#asm
		TAD (D-48		/ ASCII '0'
		SPA
		JMP XNO
		TAD (D-10		/ # OF DECIMAL DIGITS
		SMA CLA
XNO,	CLA SKP
		CMA
#endasm
}

isspace(vl)
int vl;
{
		vl;
#asm
		SNA
		JMP YNO
		TAD (D-33		/ ONE PAST ASCII ' '
		SMA CLA
YNO,	CLA SKP
		CMA
#endasm
}


isalpha(vl)
int vl;
{
		vl;				/* Include '?' and '@' as alpha vars */
#asm
		TAD (D-65		/ ASCII 'A'
		SPA
		JMP ANO
		TAD (D-26		/ # OF UPPERCASE ENGLISH LETTERS
		SPA
		JMP BNO
		TAD (D-6		/ 'a' - 'Z' IN ASCII
		SPA
		JMP ANO
		TAD (D-26		/ # OF LOWERCASE ENGLISH LETTERS
BNO,	SMA CLA
ANO,	CLA SKP
		CMA
#endasm
}

cupper(p)				/* In place convert to uppercase */
int p;
{
	p;
#asm
		DCA ZTMP
CPP1,	CLA
		TADI ZTMP
		SNA
		JMP CPP2
		TAD (D-97		/ ASCII 'a'
		SPA
		JMP CPP3
		TAD (D-26		/ # OF LOWERCASE ENGLISH LETTERS
		SMA
		JMP CPP3
		TAD (D91		/ 97 + 26 - 91 = 32 = ('a' - 'A')
		DCAI ZTMP
CPP3,	ISZ ZTMP
		JMP CPP1
CPP2,
#endasm
}

toupper(p)
int p;
{
	p;
#asm
TPP1,		DCA ZTMP    / AALT ENTRY USED BY ATOI
		TAD ZTMP
		TAD (D-97		/ SEE cupper() COMMENTARY
		SPA
		JMP TPP3
		TAD (D-26
		SMA
		JMP TPP3
		TAD (D91
		JMP TPP2
TPP3,	CLA CLL
		TAD ZTMP
TPP2,
#endasm
}

strpd(buff,sym)
char *buff,*sym;
{
	strcpy(buff,"         ");  /* 9 spaces */
	while (*sym)
		*buff++=*sym++;

}

/* Arbitrary fgets(). Read until LF, CR/LF are retained*/
/* EOF returns null, else strlen(*p) */

fgets(p)
char *p;
{
char *q;
	q=p;
	while(*p=fgetc()) {
		if (*p++==10)
			break;
	}
	*p=0;
	return (p-q);
}

memset(dst, dt, sz)
char *dst;
int dt,sz;
{
#asm
	CLA
	TAD STKP
	TAD (-4
	DCA 14
	CMA
	TADI 14
	DCA 13
	TADI 14
	DCA 12
	TADI 14
	CIA
	DCA ZTMP
CP2,	TAD  12
		DCAI 13
		ISZ ZTMP
		JMP CP2
#endasm
}


/*
** reverse string in place 
*/
reverse(s) char *s; {
  char *j;
  int c;
  j = s + strlen(s) - 1;
  while(s < j) {
    c = *s;
    *s++ = *j;
    *j-- = c;
    }
  }

/*
    This is somewhat involved in that the vararg system in SmallC is
    rather limited.

    For printf and fprintf, we pass a static buffer to sprintf(), which
    isn't formally allocated at the SABR level.  We use just locations
    10020-10170, (104 chars + NUL terminator) which is otherwise unused.
    
    The first 20 (octal) locations and the last several on this page are
    taken: see the ABSYM declarations the top of of this file.
    
    LOADER also reserves this space for itself, placing a small library
    of routines here, but none of the code in this module calls them,
    so we can safely stomp over them.  (They're used by FORTRAN II.)
*/

fprintf(nxtarg) int nxtarg;
{
#asm
		ISZ FPTR
		JMP PRINTF
#endasm
}


printf(nxtarg) int nxtarg;
{
#asm
	TAD (K20      / SEE BLOCK COMMENT ABOVE
	DCA ZPTR      / SPRINTF EXPECTS ITS BUFFER LOCATION IN ZPTR
	JMP SPRINTF
#endasm
}

/*
** sprintf(obfr, ctlstring, arg, arg, ...)
** Called by printf().
*/
sprintf(nxtarg) int nxtarg; {
  int  arg, left, pad, cc, len, maxchr, width;
  char *ctl, *sptr, str[17],*obfr,zptr;

#asm
	TAD ZPTR
	DCAI STKP	/ POINTS TO ZPTR
#endasm
  cc = 0;
  nxtarg = &nxtarg-nxtarg;
  if (zptr)
    obfr=zptr;
  else
	obfr = *nxtarg++;
  ctl = *nxtarg++;                          
  while(*ctl) {
    if(*ctl!='%') {*obfr++=*ctl++; ++cc; continue;}
    else ++ctl;
    if(*ctl=='%') {*obfr++=*ctl++; ++cc; continue;}
    if(*ctl=='-') {left = 1; ++ctl;} else left = 0;       
    if(*ctl=='0') pad = '0'; else pad = ' ';
	width=0;
    if(isdigit(*ctl)) {
      ctl+=atoi(ctl, &width);
      }
	maxchr=0;
    if(*ctl=='.') {            
      ctl+=atoi(++ctl,&maxchr)+1;
      }
    arg = *nxtarg++;
    sptr = str;
    switch(*ctl++) {
      case 'c': str[0] = arg; str[1] = NULL; break;
      case 's': sptr = arg;        break;
      case 'd': itoa(arg,str,10);  break;
      case 'b': itoab(arg,str,2);  break;
      case 'o': itoab(arg,str,8);  break;
      case 'u': itoab(arg,str,10); break;
      case 'x': itoab(arg,str,16); break;
      case 'X': itoab(arg,str,16); cupper(str); break;
      default:  return -1;
      }
    len = strlen(sptr);
    if(maxchr && maxchr<len) len = maxchr;
    if(width>len) width = width - len; else width = 0; 
    if(!left) while(width--) {*obfr++=pad; ++cc;}
    while(len--) {*obfr++=*sptr++; ++cc; }
    if(left) while(width--) {*obfr++=pad; ++cc;}  
    }
  *obfr=0;
  zptr;
#asm
		SNA				/ IF ZPTR, EITHER USE PUTS OR FPUTS
		JMP PF1
		JMSI PSH
		CLA
		TAD FPTR
		SNA CLA
		JMP PF2
		JMSI PCAL
		FPUTS
		JMP PF3
PF2,	JMSI PCAL
		PUTS
PF3,	JMSI POP
PF1,	CLA
		DCA ZPTR
		DCA FPTR
#endasm

  return(cc);
  }

/*
** itoa(n,s,r) - Convert n to numeric string form in s, radix r
*/

itoa(n, s, r) char *s; int n; int r; {
  char *ptr;
  ptr = s;
  if (r == 10 && n < 0) {
	  n = -n;
	  *ptr++='-';
  }
  itoab(n,ptr,r);
}


/*
** itoab(n,s,b) - Convert "unsigned" n to characters in s using base b.
**                NOTE: This is a non-standard function.
*/
itoab(n, s, b) int n; char *s; int b; {
  char *ptr;
  int lowbit;
  ptr = s;
  b >>= 1;
  do {
    lowbit = n & 1;
    n = (n >> 1) & 4095;
    *ptr = ((n % b) << 1) + lowbit;
    if(*ptr < 10) *ptr += '0'; else *ptr += 87; /* 87 == 'a' - 10 */
    ++ptr;
    } while(n /= b);
  *ptr = 0;
  reverse (s);
  }


strlen(p)
char *p;
{
#asm
    DCA TMP
#endasm
	while (*p++)
#asm
        ISZ TMP
#endasm
#asm
        TAD TMP
#endasm
}

fscanf(nxtarg) int nxtarg;
{
    fgets(16);     /* USE PRINTF BUFFER FOR INPUT STRING */
#asm
	JMP SC1
#endasm
}



scanf(nxtarg) int nxtarg;
{
    gets(16);     /* USE PRINTF BUFFER FOR INPUT STRING */
#asm
SC1, CLA CLL
    TAD (20
    DCA ZPTR      / FOR FSCANF,SCANF, BUFFER LOCATION IN ZPTR = 20 (8)
	JMP SSCANF
#endasm
}

#define EOF 0

sscanf(nxtarg) int nxtarg; {
  char *ctl;
  int u;
  int  *narg, ac, width, ch, cnv, base, ovfl, sign, *ibfr,zptr;

#asm
	TAD ZPTR
	DCAI STKP	/ POINTS TO ZPTR
#endasm
  ac = 0;
  nxtarg = &nxtarg-nxtarg;
  if (zptr)
    ibfr=zptr;
  else
	ibfr = *nxtarg++;
  ctl = *nxtarg++;
  while(*ctl) {
    if(*ctl++ != '%') continue;
    narg = *nxtarg++;
    ctl += atoi(ctl, &width);
	if (!width)
		width=-1;
    if(!(cnv = *ctl++)) break;
    switch(cnv) {
      case 'c':
        *narg = *ibfr++;
        break;
      case 's':
        while(width--)
          if((*narg++ = *ibfr++) == 0) break;
        *narg = 0;
        break;
      default:
        switch(cnv) {
          case 'b': base =  2; break;
          case 'd': base = 10; break;
          case 'o': base =  8; break;
          case 'x': base = 16; break;
          default:  return (ac);
          }
        *narg = u = 0;
		sign = 1;
        while (isspace(*ibfr))
            ibfr++;
        while(width-- && (ch=*ibfr++)>32) {
          if(ch == '-') {sign = -1; continue;}
          if(ch < '0') break;
          if(ch >= 'a')      ch -= 87;
          else if(ch >= 'A') ch -= 55;
          else               ch -= '0';
          u = u * base + ch;
          }
        *narg = sign * u;
      }
    ++ac;                          
    }
#asm
    	CLA
		DCA ZPTR        / CLEAR FLAGS
		DCA FPTR
#endasm
  return (ac);
  }

revcpy(dst,src,cnt)
int *dst,*src,cnt;
{
	dst+=cnt;
	src+=cnt;
	while (cnt--)
		*dst--=*src--;
}
