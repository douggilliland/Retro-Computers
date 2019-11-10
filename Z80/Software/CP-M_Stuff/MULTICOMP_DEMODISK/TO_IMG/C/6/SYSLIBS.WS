21.0 Sample Programs Using SYSLIB

21.01 The Classic File Dump Program

B>;  Demo of File Dump Program

B>type systest.mac
;
;  PROGRAM:  SYSTEST
;  AUTHOR:  Richard Conn
;  PURPOSE:  This program dumps the disk file specified by the user
;		in hexadecimal and ASCII
;  NOTE:  This test demonstrates the use of the SYSLIB Byte-Oriented
;		File Input routines
;

;  External CP/M Buffers
fcb	equ	5ch	; address of FCB filled in by CP/M's CCP
			; (or ZCPR2)

;  External References for SYSLIB routines used
	ext	fi1$open	; Open File for Byte-Oriented Input
	ext	fi1$close	; Close File
	ext	f1$get		; Get Byte from File
	ext	cout		; Character Output
	ext	pa2hc		; Print A as 2 Hex Chars
	ext	phldc		; Print HL as up to 5 decimal digits
	ext	print		; String Print
	ext	crlf		; New Line

;
;  Start of Routine -- Print Banner
;
	call	print
	db	'SYSTEST - Sample DUMP Program to Illustrate SYSLIB '
	db	'Byte-Oriented File Input'
	db	0
	call	crlf	; new line

;
;  Set Offset Counter
;
	lxi	h,0	; Init to zero
	shld	counter

;
;  Open File for Input
;
	lxi	d,fcb	; pt to FCB filled in by Operating System
	call	fi1$open	; try to open it
	jz	loop	; continue if OK
	call	print	; not ok, so file must not have been found
	db	'File Not Found',0
	ret		; return to Operating System
Š;
;  Main Loop
;
loop:
	lhld	counter	; get counter value
	call	phldc	; print as decimal number
	lxi	d,16	; add 16 to counter for next print
	dad	d
	shld	counter	; save count away
	call	print
	db	': ',0
	mvi	b,0	; set byte count to zero
	lxi	h,buffer	; point to first byte of buffer
readlp:
	call	f1$get	; get next byte
	jnz	readdn	; done if past EOF
	mov	m,a	; store byte into buffer
	inx	h	; point to next byte in buffer
	inr	b	; increment byte count
	mov	a,b	; check for done
	cpi	16	; read in 16 bytes?
	jnz	readlp
	call	bufprint	; print contents of buffer
	call	crlf	; new line
	jmp	loop	; continue until End of File

;
;  Done with Read -- Print current Buffer and Exit
;  B = Number of bytes to print
;
readdn:
	call	bufprint	; print buffer
	call	crlf		; new line
	call	fi1$close	; close file
	ret

;
;  Buffer print routine; print the contents of the buffer for B bytes
;
bufprint:
	lxi	h,buffer	; point to first byte of buffer
	push	b	; save character count
bufploop:
	mov	a,b	; check count first (in case it is zero)
	ora	a	; done?
	jz	ascprint	; print as ASCII chars if done
	dcr	b	; count down
	mov	a,m	; get byte from buffer
	inx	h	; point to next byte in buffer
	call	pa2hc	; print byte as 2 Hex chars
	mvi	a,' '	; print a space
	call	cout
	jmp	bufploop
;  Now print buffer as ASCII characters
ascprint:Š	lxi	h,buffer	; point to first character
	pop	b	; get character count
	call	print	; print a separator
	db	'! ',0
ascploop:
	mov	a,b	; check for empty buffer
	ora	a	; done if zero
	rz		; return to caller if so
	dcr	b	; count down
	mov	a,m	; get byte to output
	ani	7fh	; mask out most significant bit
	mov	c,a	; save character in C
	cpi	' '	; test for printable character
	jnc	ascp	; print character if printable
	mvi	c,'.'	; print dot if not printable character
ascp:
	mov	a,c	; get char to print
	call	cout	; print it
	inx	h	; point to next character
	jmp	ascploop	; continue until count is exhausted

counter:
	ds	2	; Offset Counter
buffer:
	ds	16	; 16-byte buffer for input bytes

	end


B>; Now to assemble the file
B>sub m80 systest
SUB for ZCPR2, Version 2.0
Process SUBMIT File
Writing SUBMIT Execution File to Disk
B$;  M80.SUB -- MACRO-80 ASSEMBLER AND LINKER
B$M80 =SYSTEST

No  Fatal error(s)

B$SUB /A  PLEASE ABORT IF ERROR(S) EXIST
SUB for ZCPR2, Version 2.0
Abort SUBMIT File
Do you wish to abort execution?
  Enter A or ^C to Abort or anything else to continue -  
Continuing Execution
B$ERA SYSTEST.BAK
No File
B$ERA SYSTEST.COM
SYSTEST .COM
B$L80 /P:100,SYSTEST,A:SYSLIB/S,SYSTEST/N,/U,/E

Link-80  3.37  08-May-80  Copyright 1979,80 (C) Microsoft

Data    0100    0745



Data    0100    0745


[0000   0745    7]

B$ERA SYSTEST.REL
SYSTEST .REL
B$;  ASSEMBLY COMPLETE


B>;  Now to create a file to test the dump program on
B>ed demo.txt

NEW FILE
     : *i
    1:  This is a very short demonstration file to test the operation
    2:  of SYSTEST, whose function is to dump the contents of this
    3:  file in hexadecimal and ascii.
    4:  
    5:  Bye for now.
    6:  
     : *e

B>type demo.txt
This is a very short demonstration file to test the operation
of SYSTEST, whose function is to dump the contents of this
file in hexadecimal and ascii.

Bye for now.

B>;  Test the dump program
B>systest demo.txt
SYSTEST - Sample DUMP Program to Illustrate SYSLIB Byte-Oriented File Input
    0: 54 68 69 73 20 69 73 20 61 20 76 65 72 79 20 73 ! This is a very s
   16: 68 6F 72 74 20 64 65 6D 6F 6E 73 74 72 61 74 69 ! hort demonstrati
   32: 6F 6E 20 66 69 6C 65 20 74 6F 20 74 65 73 74 20 ! on file to test 
   48: 74 68 65 20 6F 70 65 72 61 74 69 6F 6E 0D 0A 6F ! the operation..o
   64: 66 20 53 59 53 54 45 53 54 2C 20 77 68 6F 73 65 ! f SYSTEST, whose
   80: 20 66 75 6E 63 74 69 6F 6E 20 69 73 20 74 6F 20 !  function is to 
   96: 64 75 6D 70 20 74 68 65 20 63 6F 6E 74 65 6E 74 ! dump the content
  112: 73 20 6F 66 20 74 68 69 73 20 66 69 6C 65 0D 0A ! s of this file..
  128: 69 6E 20 68 65 78 61 64 65 63 69 6D 61 6C 20 61 ! in hexadecimal a
  144: 6E 64 20 61 73 63 69 69 2E 0D 0A 0D 0A 42 79 65 ! nd ascii.....Bye
  160: 20 66 6F 72 20 6E 6F 77 2E 0D 0A 1A 1A 1A 1A 1A !  for now........
  176: 1A 1A 1A 1A 1A 1A 1A 1A 1A 1A 1A 1A 1A 1A 1A 1A ! ................
  192: 1A 1A 1A 1A 1A 1A 1A 1A 1A 1A 1A 1A 1A 1A 1A 1A ! ................
  208: 1A 1A 1A 1A 1A 1A 1A 1A 1A 1A 1A 1A 1A 1A 1A 1A ! ................
  224: 1A 1A 1A 1A 1A 1A 1A 1A 1A 1A 1A 1A 1A 1A 1A 1A ! ................
  240: 1A 1A 1A 1A 1A 1A 1A 1A 1A 1A 1A 1A 1A 1A 1A 1A ! ................
  256: ! 


21.02 Byte-Oriented File Input Demonstration


B>;  Demo of Byte-Oriented File Input
B>type systest1.mac
;
;  PROGRAM:  SYSTEST1
;  AUTHOR:  Richard Conn
;  PURPOSE:  This program creates a file and then accepts lines
;		of text to input into that file.
;  NOTE:  This test illustrates the use of the byte-oriented file
;		output routines and the use of SYSLIB.
;

;  Define the <CR> and <LF> constants
cr	equ	0dh
lf	equ	0ah

;  External Definitions of Routines to be Used
	ext	fname		; Convert file name into FCB format
	ext	print		; Print string
	ext	bbline		; Input Line Editor
	ext	fo0$open	; Open File for Output
	ext	fo0$close	; Close File
	ext	f0$put		; Write Byte to File

;
;  This part of the program prompts the user and inputs a line
;
	call	print	; print prompt to user
	db	'SYSTEST1 - Byte-Oriented File Output Demonstration'
	db	cr,lf,'Name of File to Create? ',0
	xra	a	; A=0 so BBLINE does not capitalize line
	call	bbline	; input file name from user
	ora	a	; check char count for zero
	rz		; return to CP/M if no line input

;
;  The file name specified by the user is converted into the FCB
;  format and stored into an FCB
;
;  First char of filename is pointed to by HL, as returned by BBLINE
;
	lxi	d,fcb	; load fcb
	call	fname

;
;  Now we open the file for byte-oriented output; since FNAME does
;  not affect DE, DE still points to the FCB
;
	call	fo0$open	; open file for output
	jz	loop	; ok to proceed

;Š;  File could not be opened -- print error message and abort
;
	call	print
	db	cr,lf,'Cannot Open File -- Abort',0
	ret

;
;  This loop prompts the user for a line and stores it in the file.
;  If the user types an empty line (just <CR>), we exit and close the
;  output file.
;
loop:
	call	print	; print prompt
	db	cr,lf,'Input Line (<CR>=Done)? ',0
	xra	a	; A=0 so BBLINE does not capitalize line
	call	bbline	; get line from user
	ora	a	; check char count
	jz	done	; done if no chars

;
;  This loop writes the string pted to by HL (from BBLINE) to disk.
;
oloop:
	mov	a,m	; get char
	ora	a	; done if zero
	jz	odone
	call	f0$put	; write to disk
	jnz	derr	; check for disk error
	inx	h	; pt to next char to output
	jmp	oloop

;
;  This routine terminates the string just written to disk with a
;  <CR> <LF> pair, and the creation of the file is continued.
;
odone:
	mvi	a,cr	; new line
	call	f0$put
	mvi	a,lf
	call	f0$put
	jmp	loop

;
;  The user has typed an empty line (just <CR>), so we close the file
;  and exit.
;
done:
	call	fo0$close	; close file
	ret


;
;  Error message and abort if error occurs while writing to disk.
;
derr:
	call	print
	db	cr,lf,'Disk Output Error',0
	ret

;
;  FCB used by program
;
fcb:
	ds	36

	end

B>;  Assemble the Program
B>sub m80 systest1
SUB for ZCPR2, Version 2.0
Process SUBMIT File
Writing SUBMIT Execution File to Disk
B$;  M80.SUB -- MACRO-80 ASSEMBLER AND LINKER
B$M80 =SYSTEST1

No  Fatal error(s)

B$SUB /A  PLEASE ABORT IF ERROR(S) EXIST
SUB for ZCPR2, Version 2.0
Abort SUBMIT File
Do you wish to abort execution?
  Enter A or ^C to Abort or anything else to continue -  
Continuing Execution
B$ERA SYSTEST1.BAK
No File
B$ERA SYSTEST1.COM
SYSTEST1.COM
B$L80 /P:100,SYSTEST1,A:SYSLIB/S,SYSTEST1/N,/U,/E

Link-80  3.37  08-May-80  Copyright 1979,80 (C) Microsoft

Data    0100    08E1



Data    0100    08E1


[0000   08E1    8]

B$ERA SYSTEST1.REL
SYSTEST1.REL
B$;  ASSEMBLY COMPLETE

B>era demo.txt
DEMO    .TXT
B>systest1
SYSTEST1 - Byte-Oriented File Output Demonstration
Name of File to Create? demo.txt
Input Line (<CR>=Done)? This is a test
Input Line (<CR>=Done)? This is only a test
Input Line (<CR>=Done)? Bye for now
Input Line (<CR>=Done)? 
B>type demo.txt
This is a test
This is only a test
Bye for now


21.03 Directory Access Demonstration


B>;  Demo of Directory Routines in SYSLIB
B>type systest2.mac
;
;  PROGRAM:  SYSTEST2
;  AUTHOR:  Richard Conn
;  PURPOSE:  To demonstrate the SYSLIB routines for directory
;              manipulation.
;  NOTE:  This program loads the disk directory and selects and
;              prints files which match the ambiguous file spec
;              given by the user
;

;
;  Externals
;
	ext	dirf	; Fast Directory Load/Select/Alpha/Pack
	ext	print	; Print String
	ext	cout	; Char out
	ext	crlf	; New Line
	ext	retud	; Return User and Disk
	ext	codend	; End of Code/Beginning of Buffer

;
;  CP/M Equates
;
fcb	equ	5ch	; address of FCB loaded by CP/M
cr	equ	0dh
lf	equ	0ah

;
;  I would normally look at the FCB to see if any file was specified
;  and make it wild (all ?'s) if so, but I won't do this so we can
;  get right to the problem at hand.  Hence, if the user simply
;  types SYSTEST2 as his command, the FCB will be all spaces and
;  no file will match it.
;
	call	print
	db	'SYSTEST2 - Demo of Directory Routines in SYSLIB'
        db      cr,lf,0
	call	codend	; get buffer address in HL
	lxi	d,fcb	; pt to fcb in DE
	call	retud	; get user number in C
	mov	a,c	; user number in A
	ori	10000000b	; Mask in MSB so only Non-System
                        ; files selected
	call	dirf	; load dir/select files/alphabetize/pack


;
;  We now have a set of fixed-length records in memory, the first
;  one being pointed to by HL.  The number of records is in BC,
;  and the length of each record is 16 bytes.  These are the first
;  16 bytes of the FCBs of all files which matched the files we
;  were looking for.
;
;  I will now print out these file names horizontally across the
;  screen.
;
	mvi	d,0	; set 4 count (new line every 4 entries)
	mov	a,b	; any file names?
	ora	c	; zero if so
	jnz	loop	; continue if any names
	call	print
	db	cr,lf,'No Files Match Ambiguous File Name',0
	ret		; return to OS

;
;  This is the main loop to print the matching file names.
;
loop:
	push	d	; save 4-count in D
	call	prfile	; print file name (HL, BC not affected)
	lxi	d,16	; point to next file name by adding 16 to HL
	dad	d
	pop	d	; get 4-count in D
	inr	d	; add 1 to 4-count
	mov	a,d	; check to see if it is a 4 multiple
	ani	3	; zero if so
	cz	crlf	; ... and new line
	dcx	b	; count down
	mov	a,b
	ora	c
	jnz	loop
	ret		; return to Operating System when done


;
;  Print file name whose FCB is pointed to by HL.  Do not affect
;  HL or BC.
;
prfile:
	push	b	; save regs
	push	h
	inx	h	; pt to first char of file name
	mvi	b,8	; print 8 bytes
	call	prch	; my routine to do this (not in SYSLIB)
	mvi	a,'.'	; print dot
	call	cout
	mvi	b,3	; print 3 bytes
	call	prch
	call	print
	db	'  !  ',0	; print name separator
	pop	h	; restore regs
	pop	b
	ret

;
;  Print B chars pointed to by HL
;
prch:
	mov	a,m	; get char
	inx	h	; pt to next
	call	cout	; print char
	dcr	b	; count down
	jnz	prch
	ret

	end


B>;  Assemble the Program
B>sub m80 systest2
SUB for ZCPR2, Version 2.0
Process SUBMIT File
Writing SUBMIT Execution File to Disk
B$;  M80.SUB -- MACRO-80 ASSEMBLER AND LINKER
B$M80 =SYSTEST2

No  Fatal error(s)

B$SUB /A  PLEASE ABORT IF ERROR(S) EXIST
SUB for ZCPR2, Version 2.0
Abort SUBMIT File
Do you wish to abort execution?
  Enter A or ^C to Abort or anything else to continue -  
Continuing Execution
B$ERA SYSTEST2.BAK
No File
B$ERA SYSTEST2.COM
SYSTEST2.COM
B$L80 /P:100,SYSTEST2,A:SYSLIB/S,SYSTEST2/N,/U,/E

Link-80  3.37  08-May-80  Copyright 1979,80 (C) Microsoft

Data    0100    0867



Data    0100    0867


[0000   0867    8]

B$ERA SYSTEST2.REL
SYSTEST2.REL
B$;  ASSEMBLY COMPLETE

B>era demo.txt
DEMO    .TXT
B>;  Display files so the reader can see what files are on disk
B>;  NOTE:  I select all files that do NOT match *.COM in Non-Sys
B>xdir *.com /n
XDIR III, Version 1.2    Vertical Listing by File Type and Name
 Disk: B  User:   0, File Attributes:  Non-System

Filename.Typ Size K RS   Filename.Typ Size K RS   Filename.Typ Size K RS
-------- --- ------ --   -------- --- ------ --   -------- --- ------ --
 DD0    .-40      0 R    MLONGINT.MAC     10      SYSTEST3.MAC      4      
FNDFILE .ASM      4      SYSTEST .MAC      4      SYSTEST4.MAC      6      
MCHECK  .ASM     12      SYSTEST1.MAC      4      SYSTEST5.MAC      2      
LU      .DOC     24      SYSTEST2.MAC      4      SYSTEST6.MAC      6      
MCOPY   .MAC     22      
   13 Files Occupying   102K,    26 Files on Disk and   426K Free

B>systest2
SYSTEST2 - Demo of Directory Routines in SYSLIB

No Files Match Ambiguous File Name
B>systest2 *.mac
SYSTEST2 - Demo of Directory Routines in SYSLIB
MCOPY   .MAC  !  MLONGINT.MAC  !  SYSTEST .MAC  !  SYSTEST1.MAC  !  
SYSTEST2.MAC  !  SYSTEST3.MAC  !  SYSTEST4.MAC  !  SYSTEST5.MAC  !  
SYSTEST6.MAC  !  
B>systest2 *.asm
SYSTEST2 - Demo of Directory Routines in SYSLIB
FNDFILE .ASM  !  MCHECK  .ASM  !  



21.04 Math Demonstration


B>;  Demo of Evaluation and Math Routines
B>type systest3.mac
;
;  PROGRAM:  SYSTEST3
;  AUTHOR:  Richard Conn
;  PURPOSE:  This program demonstrates the EVAL routines and the
;		Math routines within SYSLIB
;

;
;  Externals
;
	EXT	ADDHD	; HL = HL + DE
	EXT	SUBHD	; HL = HL - DE
	EXT	NEGH	; HL = NEGATE OF HL
	EXT	MULHD	; HL = HL * DE
	EXT	DIVHD	; HL = HL / DE
	EXT	ANDHD	; HL = HL AND DE
	EXT	ORHD	; HL = HL OR DE
	EXT	XORHD	; HL = HL XOR DE
	EXT	SHFTRH	; HL = HL shifted right one bit position
	EXT	SHFTLH	; HL = HL shifted left one bit position
	EXT	ROTRH	; HL = HL rotated right one bit position
	EXT	ROTLH	; HL = HL rotated left one bit position

	EXT	PRINT	; Print String
	EXT	BBLINE	; Input Line Editor
	EXT	EVAL	; Number Evaluator
	EXT	PHLDC	; Print HL as up to 5 decimal chars
	EXT	PHL4HC	; Print HL as 4 Hex chars

;
;  ASCII Char defns
;
cr	equ	0dh
lf	equ	0ah

;
;  Print Banner
;
	call	print
	db	'SYSTEST3 -- Math Routines and Evaluation Demo',0


;
;  This is the main loop and a prompt to the user.
;
loop:
	call	print
	db	cr,lf,'Input Two Numbers, Separated by a Comma '
        db      '(<CR> to Stop) -- ',0
	call	bbline	; get user input
	ora	a	; no input if A=0
	rz		; return to Operating System
	call	eval	; evaluate the first number (pted to by HL)
	xchg		; place number in HL
	shld	num1	; save it away as 1st number
	xchg		; restore ptr to comma after number in HL
	inx	h	; skip comma
	call	eval	; evaluate the 2nd number (returned in DE)

;
;  Through the rest of this loop, DE contains the 2nd number.
;  Note that none of the routines affect it.
;
	call	print
	db	cr,lf,'First Number is ',0
	lhld	num1	; get and print first number
	call	phldc	; print in decimal
	call	print
	db	' in Decimal or ',0
	call	phl4hc	; print in hex
	call	print
	db	' in Hex',cr,lf,0
	call	print
	db	'The Second Number is ',0
	xchg		; get 2nd number into HL
	call	phldc	; print in decimal
	call	print
	db	' in Decimal or ',0
	call	phl4hc	; print in hex
	call	print
	db	' in Hex',cr,lf,0
	xchg		; save 2nd number in DE for rest of loop
	call	print
	db	cr,lf,'Sum = ',0
	lhld	num1	; get first number again
	call	addhd	; HL = HL + DE
	call	phldc	; print sum
	call	print
	db	'  Difference = ',0
	lhld	num1	; get first number (since destroyed by ADDHD)
	call	subhd	; ... and so on ...
	call	phldc	; print difference

	call	print
	db	'  Product = ',0
	lhld	num1
	call	mulhd
	call	phldc	; print product
	call	print
	db	'  Quotient = ',0
	lhld	num1
	call	divhd
	call	phldc	; print quotient
	call	print
	db	cr,lf,'  Negative of First Argument = ',0
	lhld	num1
	call	negh
	call	phldc	; print negative
	call	print
	db	cr,lf,'AND = ',0
	lhld	num1	; get first number
	call	andhd
	call	phl4hc
	call	print
	db	'  OR = ',0
	lhld	num1
	call	orhd
	call	phl4hc
	call	print
	db	'  XOR = ',0
	lhld	num1
	call	xorhd
	call	phl4hc
	call	print
	db	cr,lf,'First Argument:  SHIFT L = ',0
	lhld	num1
	call	shftlh
	call	phl4hc
	call	print
	db	'  SHIFT R = ',0
	lhld	num1
	call	shftrh
	call	phl4hc
	call	print
	db	'  ROT L = ',0
	lhld	num1
	call	rotlh
	call	phl4hc
	call	print
	db	'  ROT R = ',0
	lhld	num1
	call	rotrh
	call	phl4hc
	jmp	loop


num1:	ds	2	; first number

	db	0

	end

B>;  Assemble the Program
B>sub m80 systest3
SUB for ZCPR2, Version 2.0
Process SUBMIT File
Writing SUBMIT Execution File to Disk
B$;  M80.SUB -- MACRO-80 ASSEMBLER AND LINKER
B$M80 =SYSTEST3

No  Fatal error(s)

B$SUB /A  PLEASE ABORT IF ERROR(S) EXIST
SUB for ZCPR2, Version 2.0
Abort SUBMIT File
Do you wish to abort execution?
  Enter A or ^C to Abort or anything else to continue -  
Continuing Execution
B$ERA SYSTEST3.BAK
No File
B$ERA SYSTEST3.COM
SYSTEST3.COM
B$L80 /P:100,SYSTEST3,A:SYSLIB/S,SYSTEST3/N,/U,/E

Link-80  3.37  08-May-80  Copyright 1979,80 (C) Microsoft

Data    0100    07F6



Data    0100    07F6


[0000   07F6    7]

B$ERA SYSTEST3.REL
SYSTEST3.REL
B$;  ASSEMBLY COMPLETE


B>;  Run the assembled program
B>systest3
SYSTEST3 -- Math Routines and Evaluation Demo
Input Two Numbers, Separated by a Comma (<CR> to Stop) -- 10,5
First Number is    10 in Decimal or 000A in Hex
The Second Number is     5 in Decimal or 0005 in Hex

Sum =    15  Difference =     5  Product =    50  Quotient =     2
  Negative of First Argument = 65526
AND = 0000  OR = 000F  XOR = 000F
First Argument:  SHIFT L = 0014  SHIFT R = 0005  ROT L = 0014
                                             >>  ROT R = 0005
Input Two Numbers, Separated by a Comma (<CR> to Stop) -- 11,5
First Number is    11 in Decimal or 000B in Hex
The Second Number is     5 in Decimal or 0005 in Hex

Sum =    16  Difference =     6  Product =    55  Quotient =     2
  Negative of First Argument = 65525
AND = 0001  OR = 000F  XOR = 000E
First Argument:  SHIFT L = 0016  SHIFT R = 0005  ROT L = 0016
                                             >>  ROT R = 8005
Input Two Numbers, Separated by a Comma (<CR> to Stop) -- 825,15
First Number is   825 in Decimal or 0339 in Hex
The Second Number is    15 in Decimal or 000F in Hex

Sum =   840  Difference =   810  Product = 12375  Quotient =    55
  Negative of First Argument = 64711
AND = 0009  OR = 033F  XOR = 0336
First Argument:  SHIFT L = 0672  SHIFT R = 019C  ROT L = 0672
                                             >>  ROT R = 819C
Input Two Numbers, Separated by a Comma (<CR> to Stop) -- 9999,2
First Number is  9999 in Decimal or 270F in Hex
The Second Number is     2 in Decimal or 0002 in Hex

Sum = 10001  Difference =  9997  Product = 19998  Quotient =  4999
  Negative of First Argument = 55537
AND = 0002  OR = 270F  XOR = 270D
First Argument:  SHIFT L = 4E1E  SHIFT R = 1387  ROT L = 4E1E
                                             >>  ROT R = 9387
Input Two Numbers, Separated by a Comma (<CR> to Stop) -- 


21.05 Sort Demonstration

B>;  Demo of Sort Routines in SYSLIB
B>type systest4.mac
;
;  PROGRAM:  SYSTEST4
;  AUTHOR:  Richard Conn
;  PURPOSE:  To allow the user to input a list of text elements
;               and then sort that list in alphabetical order
;  NOTE:  This program demonstrates the use of SYSLIB and its
;               Sort Routines
;

;
;  External Routines
;
	ext	ssbinit	; Initialize Sort Specification Block (SSB)
	ext	sort	; SORT Routine
	ext	crlf	; New Line
	ext	cin	; Char In
	ext	caps	; Capitalize char
	ext	print	; Print string
	ext	bbline	; Input Line Editor
	ext	cout	; Print Char
	ext	codend	; End of code/beginning of scratch buffer

;
;  Equates
;
cr	equ	0dh
lf	equ	0ah

;
;  Start of Program
;
	jmp	go
done:
	ret		; placed here for testing purposes

;
;  First we have to use the routine CODEND to determine where the
;  first free byte in the scratch data area which follows the
;  program is.
;
go:
	call	print
	db	'SYSTEST4 -- Sort Demonstration',cr,lf,0
go1:
	call	codend	; get address of end of code
	shld	start	; save address of first byte of first record
	xchg		; ... in DE

;
;  I will use BC to contain a count of the number of records entered
;  and DE to point to the next location in memory to store the
;  next record.
;
	lxi	b,0	; set record count

;
;  Prompt user for input and get a line of text from him.
;
loop:
	call	print
	db	cr,lf,'Entry (<CR>=Done)? ',0
	xra	a	; do not capitalize input line
	call	bbline	; get line from user
	ora	a	; A=char count=0 if done (just <CR> typed)
	jz	sort1	; do sort if done
	inx	b	; incr record count
	push	b	; save record count
	mvi	b,40	; copy user input into next record
                        ; (pted to by DE)

;
;  This loop copies the user's string, which was input by BBLINE
;  and pointed to by HL, into the next record position, which is
;  pointed to by DE.
;
lp1:
	mov	a,m	; get byte
	ora	a	; done if zero
	jz	lp2
	stax	d	; put byte
	inx	h	; pt to next
	inx	d
	dcr	b	; count down
	jmp	lp1

;
;  This loop fills the rest of the record with spaces.  This is not
;  a very good program in the sense that it does not do any error
;  checking to see if the user typed more than 40 chars, but it
;  is OK for this demo.
;
lp2:
	mvi	a,' '	; store <SP>
	stax	d	; put byte
	inx	d	; pt to next
	dcr	b	; count down
	jnz	lp2

;
;  Now we get our record count back and continue the program.
;
	pop	b	; get rec count
	jmp	loop	; continue until done

;
;  The user has typed an empty line, and the number of records
;  is in BC.
;
sort1:

;
;  Set up record count field of SSB
;
	mov	h,b	; save record count
	mov	l,c
	shld	recnt	; save record count field of Sort
                        ; Specification Block

;
;  Test for no records and abort if so
;
	mov	a,h	; any records?
	ora	l
	jnz	sort2
	call	print
	db	cr,lf,'No Records -- Aborting Sort',0
	ret		; Return to OS

;
;  Set up record size field of SSB
;
sort2:
	lxi	h,40	; 40 bytes/record
	shld	recsiz	; save record size field of Sort Spec
                        ; Block (SSB)

;
;  Set up compare routine address field of SSB
;
	lxi	h,comp	; address of compare routine
	shld	cmpadr	; save compare address in proper field
                        ; of SSB


;
;  I shall now use SSBINIT to set up the ORDER buffer and check
;  to see that it does not overflow the TPA.  SSBINIT will also
;  set FIRSTP to the byte after the order buffer, but I will
;  discard this and reset FIRSTP to point to the first byte of
;  my first record.
;
	xchg		; HL pts to next available entry
	lxi	d,ssb	; Pt to SSB
	call	ssbinit	; initialize the SSB FIRSTP and ORDER buffers
	lhld	start	; set start address field of SSB since
                        ; ORDER buffer
	shld	firstp	; is located AFTER the FIRSTP buffer

;
;  Set the flag to tell SORT to use pointers to do the sort.
;
	mvi	a,0ffh	; non-zero
	sta	sflag	; set flag in SSB

;
;  The Sort Specification Block (SSB) is now properly loaded, so
;  let's sort!
;
	call	print
	db	cr,lf,'Starting Sort --',cr,lf,0
	lxi	d,ssb	; pt to ssb
	call	sort	; sort it

;
;  Buffer is now sorted -- print out results
;
	call	print
	db	cr,lf,'Buffer After Sort --',cr,lf,0
	call	prbuf

;
;  Prompt the user to continue
;
	call	print
	db	cr,lf,'Do you wish to run this test again (Y/N)? '
        db      0
	call	cin
	call	caps
	call	cout
	call	crlf	; new line
	cpi	'N'
	jnz	go	; rerun if not No
	jmp	done


;
;  Print the contents of the buffer containing all loaded records
;
prbuf:
	lhld	recnt	; get record count
	xchg		; ... in DE
	lhld	firstp	; pt to address of first record
prloop:
	call	crlf	; new line
	mvi	b,40	; print 40 chars
prl1:
	mov	a,m	; get char
	inx	h	; pt to next
	call	cout	; print char
	dcr	b	; count down chars
	jnz	prl1
	dcx	d	; count recs
	mov	a,d
	ora	e
	jnz	prloop
	ret

;
;  Compare Routine for SORT
;  This is a simple byte-for-byte comparison routine, which exists
;  as soon as two bytes which are not equal are encountered.
;
;  This routine returns with the Zero Flag Set (Z) if the two records
;  pointed to by HL and DE are equal (each byte the same).  It returns
;  with the Carry Flag Set (C) if the record pointed to by DE is
;  less than the record pointed to by HL in ASCII sorting sequence.
;
comp:
	push	h	; save regs
	push	d
	push	b
	mvi	b,40	; 40 bytes max
cmpl:
	ldax	d	; get byte
	cmp	m	; compare
	jz	cmpok	; continue or fall thru with proper flags
cmpd:
	pop	b	; restore regs -- flag set
	pop	d
	pop	h
	ret
cmpok:
	inx	h	; pt to next
	inx	d
	dcr	b	; count down
	jnz	cmpl	; continue
	jmp	cmpd	; done


;
; Buffers
;
start:	ds	2	; address of 1st record
ssb:			; this is the Sort Specification Block
firstp:	ds	2	; Pointer to the first byte of first record
recnt:	ds	2	; Number of records
recsiz:	ds	2	; Size of record
cmpadr:	ds	2	; Address of comparison routine
order:ds	2	; Address of pointer table (if used)
sflag:	ds	2	; Flag telling SORT to use pointers (0=no)

	end

B>;  Assemble Program
B>sub m80 systest4
SUB for ZCPR2, Version 2.0
Process SUBMIT File
Writing SUBMIT Execution File to Disk
B$;  M80.SUB -- MACRO-80 ASSEMBLER AND LINKER
B$M80 =SYSTEST4

No  Fatal error(s)

B$SUB /A  PLEASE ABORT IF ERROR(S) EXIST
SUB for ZCPR2, Version 2.0
Abort SUBMIT File
Do you wish to abort execution?
  Enter A or ^C to Abort or anything else to continue -  
Continuing Execution
B$ERA SYSTEST4.BAK
No File
B$ERA SYSTEST4.COM
SYSTEST4.COM
B$L80 /P:100,SYSTEST4,A:SYSLIB/S,SYSTEST4/N,/U,/E

Link-80  3.37  08-May-80  Copyright 1979,80 (C) Microsoft

Data    0100    06E6



Data    0100    06E6


[0000   06E6    6]

B$ERA SYSTEST4.REL
SYSTEST4.REL
B$;  ASSEMBLY COMPLETE

B>; Run Sort
B>systest4
SYSTEST4 -- Sort Demonstration

Entry (<CR>=Done)? Rick
Entry (<CR>=Done)? Jane
Entry (<CR>=Done)? David
Entry (<CR>=Done)? Debbie
Entry (<CR>=Done)? Arnold
Entry (<CR>=Done)? Scott
Entry (<CR>=Done)? 
Starting Sort --

Buffer After Sort --

Arnold                                  
David                                   
Debbie                                  
Jane                                    
Rick                                    
Scott                                   
Do you wish to run this test again (Y/N)? N




21.06 Random Number Generator Demonstration


B>;  Demo of Random Number Generator
B>type systest5.mac
;
;  PROGRAM:  SYSTEST5
;  AUTHOR:  Richard Conn
;  PURPOSE:  This program obtains a seed value and then generates
;		10 random numbers
;

;
;  Externals
;
	ext	cin	; char in
	ext	cout	; char out
	ext	print	; print string
	ext	rndinit	; init random number generator by keypress
	ext	rnd	; return random number
	ext	rndseed	; init random number generator by user seed
	ext	crlf	; new line
	ext	padc	; print A as up to 3 decimal digits
	ext	caps	; capitalize char
	ext	bbline	; get line from user
	ext	eval	; evaulate string

;
;  Constants
;
cr	equ	0dh
lf	equ	0ah

	call	print
	db	'SYSTEST5 - Random Number Demo',0

;
;  Start of main loop, which generates 10 random numbers each
;  time it is executed.
;
start:

;
;  Prompt user to see if he wants to select his own seed
;
	call	print
	db	cr,lf,'Do you want to pick your own seed (Y/N)? '
        db      0
	call	cin	; get single-char response from user
	call	caps
	call	cout
	cpi	'N'
	jz	rseed
Š;
;  Input a seed value from the user.
;
	call	print
	db	cr,lf,'What is your seed value? ',0
	xra	a	; no caps
	call	bbline	; get string
	call	eval	; evaluate string and return value in HL
                        ; and A=L
	call	rndseed	; set seed from 8-bit value in A
	call	print	; print seed stored
	db	cr,lf,'Your seed is: ',0
	call	padc
	jmp	rseed1

;
;  Prompt user and wait for keypress to set seed.
;
rseed:
	call	print
	db	cr,lf,'Wait a little and then press a key to set'
        db      ' the seed - ',0
	call	rndinit

;
;  Generate 10 random numbers
;
rseed1:
	call	print
	db	cr,lf,'10 Random Numbers follow --',cr,lf,0
	mvi	b,10	; 10 numbers
loop:
	call	rnd	; get number
	call	padc	; print it as decimal
	mvi	a,' '	; print <SP>
	call	cout
	dcr	b	; count down
	jnz	loop

;
;  Prompt user to continue
;
	call	print
	db	cr,lf,'Do you want to run this test again (Y/N)? '
        db      0
	call	cin	; get response
	call	caps
	call	cout
	cpi	'N'
	jnz	start
	ret		; return to OS if done

	end

B>;  Assemble the Program
B>sub m80 systest5
SUB for ZCPR2, Version 2.0
Process SUBMIT File
Writing SUBMIT Execution File to Disk
B$;  M80.SUB -- MACRO-80 ASSEMBLER AND LINKER
B$M80 =SYSTEST5

No  Fatal error(s)

B$SUB /A  PLEASE ABORT IF ERROR(S) EXIST
SUB for ZCPR2, Version 2.0
Abort SUBMIT File
Do you wish to abort execution?
  Enter A or ^C to Abort or anything else to continue -  
Continuing Execution
B$ERA SYSTEST5.BAK
No File
B$ERA SYSTEST5.COM
SYSTEST5.COM
B$L80 /P:100,SYSTEST5,A:SYSLIB/S,SYSTEST5/N,/U,/E

Link-80  3.37  08-May-80  Copyright 1979,80 (C) Microsoft

Data    0100    0615



Data    0100    0615


[0000   0615    6]

B$ERA SYSTEST5.REL
SYSTEST5.REL
B$;  ASSEMBLY COMPLETE

B>;  Run the Program
B>systest5
SYSTEST5 - Random Number Demo
Do you want to pick your own seed (Y/N)? N
Wait a little and then press a key to set the seed - 
10 Random Numbers follow --
 21 170  12  25 166   8  33 200 197  66 
Do you want to run this test again (Y/N)? Y
Do you want to pick your own seed (Y/N)? N
Wait a little and then press a key to set the seed - 
10 Random Numbers follow --
112 232  62 196  75 148 134 111 131 239 
Do you want to run this test again (Y/N)? Y
Do you want to pick your own seed (Y/N)? Y
What is your seed value? 25
Your seed is:  25
10 Random Numbers follow --
171 196 237 100 161 189 176  54 125  21 
Do you want to run this test again (Y/N)? Y
Do you want to pick your own seed (Y/N)? Y
What is your seed value? 25
Your seed is:  25
10 Random Numbers follow --
  7 112  53 158 194 150 210 178 228 145 
Do you want to run this test again (Y/N)? Y
Do you want to pick your own seed (Y/N)? Y
What is your seed value? 0
Your seed is:   0
10 Random Numbers follow --
  1 129  67 230 155  94 123 210 201  61 
Do you want to run this test again (Y/N)? N



21.07 ZCPR2-Specific Function Demonstration

B>type systest6.mac
;
;  PROGRAM:  SYSTEST6
;  AUTHOR:  Richard Conn
;  PURPOSE:  To illustrate the ZCPR2-specific routines in SYSLIB
;

;
;  Externals
;
	EXT	ZCPRSET		; Set DMA, et al
	EXT	ZINIEXT		; Set External Path Address
	EXT	ZPFIND		; Find File Along Path
	EXT	ZFSTAT		; Return Status of File
	EXT	ZFNAME		; Extended File Name Parser

	EXT	RETUD		; Return Current User/Disk
	EXT	CRLF		; New Line
	EXT	BBLINE		; Input Line Editor
	EXT	PRINT		; Print String
	EXT	PSTR		; Another Print String
	EXT	CIN		; Char in
	EXT	COUT		; Char out
	EXT	CAPS		; Capitalize char
	EXT	PADC		; Print A as decimal
	EXT	BDOS		; BDOS Call
	EXT	PHL4HC		; Print HL as 4 Hex chars
	EXT	CODEND		; End of code/beginning of buffer

;
;  Constants
;
CR	EQU	0DH
LF	EQU	0AH

;
;  THIS INITIALIZATION MUST BE DONE WHENEVER THE ZCPR-ORIENTED
;	ROUTINES ARE TO BE USED WITH THE USER'S EXTERNAL PATH
;
	LXI	H,40H		; BASE OF EXTERNAL PATHS
	CALL	ZINIEXT		; SET BASE ADDRESS

;
;  THIS INITIALIZATION NEED NOT ALWAYS BE DONE, ESPECIALLY WHEN THE
;	DEFAULTS ARE USED, BUT I'M DOING IT HERE FOR PURPOSE OF
;       EXAMPLE
;
	MVI	A,'$'	; CURRENT INDICATOR
	LXI	H,80H	; DMA ADDRESS
	CALL	ZCPRSET	; SET THESE VALUES FOR ZCPR ROUTINES


;
;  SINCE I AM PLAYING WITH DISKS AND USER AREAS, GET THE CURRENT
;  DISK/USER
;
	CALL	RETUD	; GET CURRENT USER AND DISK
	MOV	A,B	; SAVE DISK
	STA	CDISK
	MOV	A,C	; SAVE USER
	STA	CUSER

;
;  TEST LOOP
;
LOOP:
	CALL	PRINT
	DB	CR,LF,'Current Disk is ',0
	LDA	CDISK	; GET DISK
	PUSH	PSW	; SAVE IF
	ADI	'A'	; CONVERT TO ASCII
	CALL	COUT
	POP	PSW	; GET DISK
	MOV	E,A
	MVI	C,14	; SELECT DISK
	CALL	BDOS
	CALL	PRINT
	DB	', and Current User is ',0
	LDA	CUSER	; GET USER
	CALL	PADC	; PRINT AS DECIMAL
	MOV	E,A	; SELECT USER
	MVI	C,32
	CALL	BDOS
	CALL	PRINT
	DB	CR,LF,'Name of File to Search For (<CR>=Done)? ',0
	XRA	A	; NO CAP
	CALL	BBLINE	; GET LINE FROM USER
	ORA	A	; ANY INPUT?
	RZ
	CALL	PRINT
	DB	CR,LF,'File Name: ',0
	PUSH	H	; SAVE HL, SINCE MODIFIED BY PSTR
	CALL	PSTR
	CALL	CODEND	; GET ADDRESS OF SCRATCH AREA FOR ZFNAME
	MOV	B,H	; ... IN BC
	MOV	C,L
	POP	H
	LXI	D,FCB	; PT TO FCB
	CALL	ZFNAME	; CONVERT TO FCB FORM
	JZ	UDERR	; USER OR DISK ERROR?

	CALL	PRINT
	DB	CR,LF,'Selected Disk is ',0
	MOV	A,B	; GET DISK NUMBER
	CPI	0FFH	; CURRENT?
	JNZ	DN1
	CALL	PRINT
	DB	'Current',0
	JMP	DN2
DN1:
	DCR	A	; CONVERT TO 0-15
	ADI	'A'	; CONVERT TO LETTER
	CALL	COUT
	SUI	'A'	; CONVERT BACK
	MOV	E,A	; IN E
	PUSH	B	; SAVE BC
	MVI	C,14	; SELECT DISK
	CALL	BDOS
	POP	B	; GET BC
DN2:
	CALL	PRINT
	DB	', and Selected User is ',0
	MOV	A,C	; GET USER
	CPI	0FFH	; CURRENT?
	JNZ	DN3
	CALL	PRINT
	DB	'Current',0
	JMP	DN4
DN3:
	CALL	PADC	; PRINT AS DECIMAL
	MOV	E,A	; USER IN E
	MVI	C,32	; SELECT USER
	CALL	BDOS
DN4:
	CALL	PRINT
	DB	CR,LF,'Selected User and Disk Now Logged In'
	DB	CR,LF,'File Name from FCB: ',0
	LXI	H,FCB+1
	MVI	C,8	; PRINT 8 CHARS
	CALL	PCH
	MVI	A,'.'
	CALL	COUT
	MVI	C,3	; PRINT 3 MORE CHARS
	CALL	PCH
	CALL	CRLF
	LXI	D,FCB	; PT TO FCB
	MVI	B,0	; DON'T SEARCH CURRENT
	CALL	ZPFIND	; SEARCH FOR FILE ALONG PATH (DE PTS TO FCB)
	JZ	FNF	; FILE NOT FOUND IF A=0 AND ZERO FLAG SET
	CALL	PRINT
	DB	CR,LF,'File Found on Disk ',0
	MOV	A,B	; GET DISK NUMBER
	ADI	'A'	; CONVERT TO LETTER
	CALL	COUT

	CALL	PRINT
	DB	' in User ',0
	MOV	A,C	; GET USER NUMBER
	CALL	PADC	; PRINT AS DECIMAL
	PUSH	D	; SAVE FCB PTR
	PUSH	B	; SAVE USER/DISK
	MOV	E,B	; SELECT DISK
	MVI	C,14	; BDOS FCT
	CALL	BDOS	; SELECT USER
	POP	B	; GET USER
	MOV	E,C
	MVI	C,32	; BDOS FCT
	CALL	BDOS	; SELECT USER
	POP	D	; GET FCB PTR
	CALL	ZFSTAT	; GET STATUS OF FILE
	JNZ	FNF1	; FILE NOT FOUND?  SHOULD NOT HAPPEN
	CALL	PRINT
	DB	CR,LF,'File is ',0
	MOV	A,C	; GET R/O FLAG
	ORA	A	; 0=NOT R/O
	JNZ	LOOP1
	CALL	PRINT
	DB	'NOT ',0
LOOP1:
	CALL	PRINT
	DB	'Read/Only, and File is ',0
	MOV	A,B	; GET SYSTEM FLAG
	ORA	A	; 0=NOT SYSTEM
	JNZ	LOOP2
	CALL	PRINT
	DB	'Non-',0
LOOP2:
	CALL	PRINT
	DB	'System',0
	JMP	LOOP
FNF1:
	CALL	PRINT
	DB	CR,LF,'This should not happen',0
FNF:
	CALL	PRINT
	DB	CR,LF,'File Not Found',0
	JMP	LOOP
UDERR:
	CALL	PRINT
	DB	CR,LF,'Error in User or Disk Numbers',0
	JMP	LOOP
PCH:
	MOV	A,M	; GET CHAR
	CALL	COUT	; PRINT CHAR
	INX	H	; PT TO NEXT
	DCR	C	; COUNT DOWN
	JNZ	PCH
	RET
ŠCDISK:
	DS	1	; CURRENT DISK
CUSER:
	DS	1	; CURRENT USER
FCB:
	DS	36

	END


B>;  I won't repeat the assembly on this one (because I'm tired
B>;  of going thru all those assemblies!)

B>;  Demo of ZCPR2-Specific Routines in SYSLIB, Particularly Path
B>;  Search I will now look around on the various disks to show
B>;  you what files are "hanging around"
B>xdir *.com /aa
XDIR III, Version 1.2    Vertical Listing by File Type and Name
 Disk: B  User:   0, File Attributes:  Non-System System

Filename.Typ Size K RS   Filename.Typ Size K RS   Filename.Typ Size K RS
-------- --- ------ --   -------- --- ------ --   -------- --- ------ --
GETSYS  .COM     10 RS   SYSTEST .COM      2      SYSTEST4.COM      2      
LU      .COM     18      SYSTEST1.COM      2      SYSTEST5.COM      2      
MCOPY   .COM      4 RS   SYSTEST2.COM      2      SYSTEST6.COM      4      
PIP     .COM      8 RS   SYSTEST3.COM      2      XDIR    .COM     10 RS   
   12 Files Occupying    66K,    26 Files on Disk and   426K Free

B>xdir a:*.com /aa
XDIR III, Version 1.2    Vertical Listing by File Type and Name
 Disk: A  User:   0, File Attributes:  Non-System System

Filename.Typ Size K RS   Filename.Typ Size K RS   Filename.Typ Size K RS
-------- --- ------ --   -------- --- ------ --   -------- --- ------ --
ASM2    .COM      8      HELP    .COM      4 RS   PROTECT .COM      4 RS   
CALC    .COM      4 RS   INUSE   .COM      4 RS   RENAME  .COM      4 RS   
CHDIR   .COM     14 RS   IOLOADER.COM      2 RS   SGEN    .COM      2 RS   
COMPARE .COM      2 RS   L80     .COM     10      SUB     .COM      4 RS   
DASM    .COM     10 RS   LIB     .COM      6      SYSGEN  .COM      2      
DASMT   .COM      8 RS   LOAD    .COM      2      TIME    .COM      6 RS   
DEVICE  .COM     10 RS   M80     .COM     20      TINIT   .COM      6 RS   
DIFF    .COM      4 RS   MAC     .COM     12      WM      .COM     10 RS   
ED      .COM      8      MCOPY   .COM      4 RS   XDIR    .COM     10 RS   
ERASE   .COM      6 RS   PATH    .COM     12 RS   XLATE2  .COM      6 RS   
FINDBAD .COM      4 RS   PIP     .COM      8 RS   ZSID    .COM     10 RS   
GETSYS  .COM     10 RS   PRINT   .COM      6 RS   
   35 Files Occupying   242K,    58 Files on Disk and   222K Free


B>xdir 5:
XDIR III, Version 1.2    Vertical Listing by File Type and Name
 Disk: B  User:   5, File Attributes:  Non-System

Filename.Typ Size K RS   Filename.Typ Size K RS   Filename.Typ Size K RS
-------- --- ------ --   -------- --- ------ --   -------- --- ------ --
TEST    .TXT      2      
    1 Files Occupying     2K,    26 Files on Disk and   426K Free


B>;  To display the current named directories --

B>chdir /d
CHDIR, Version 2.0  -- Option: Display Directory Names
Defined Directory Names --
        A0: ROOT        B0: DEV B5: TEST
5 Directory Names Defined, Space Left for 59 More Names

Current Directory --    B0: DEV


B>;  To display the path --

B>path
PATH Version 2.1
Current Symbolic Path --
        $$: --> $0: --> A$: --> A0:
Current Absolute Path --
        B0: --> B0: --> A0: --> A0:
Current Named Path --
        DEV: --> DEV: --> ROOT: --> ROOT:
B>user 5
B5>path
PATH Version 2.1
Current Symbolic Path --
        $$: --> $0: --> A$: --> A0:
Current Absolute Path --
        B5: --> B0: --> A5: --> A0:
Current Named Path --
        TEST: --> DEV: --> Noname: --> ROOT:

B5>;  Now to run the test program
B5>systest6

Current Disk is B, and Current User is   5
Name of File to Search For (<CR>=Done)? xdir.com
File Name: xdir.com
Selected Disk is Current, and Selected User is Current
Selected User and Disk Now Logged In
File Name from FCB: XDIR    .COM

File Found on Disk B in User   0
File is Read/Only, and File is System
Current Disk is B, and Current User is   5
Name of File to Search For (<CR>=Done)? test.txt
File Name: test.txt
Selected Disk is Current, and Selected User is Current
Selected User and Disk Now Logged In
File Name from FCB: TEST    .TXT

File Found on Disk B in User   5
File is NOT Read/Only, and File is Non-System
Current Disk is B, and Current User is   5
Name of File to Search For (<CR>=Done)? zsid.com
File Name: zsid.com
Selected Disk is Current, and Selected User is Current
Selected User and Disk Now Logged In
File Name from FCB: ZSID    .COM

File Found on Disk A in User   0
File is Read/Only, and File is System
Current Disk is B, and Current User is   5
Name of File to Search For (<CR>=Done)? aa.com
File Name: aa.com
Selected Disk is Current, and Selected User is Current
Selected User and Disk Now Logged In
File Name from FCB: AA      .COM

File Not Found
Current Disk is B, and Current User is   5
Name of File to Search For (<CR>=Done)? a10:xdir.com
File Name: a10:xdir.com
Selected Disk is A, and Selected User is  10
Selected User and Disk Now Logged In
File Name from FCB: XDIR    .COM

File Found on Disk A in User   0
File is Read/Only, and File is System
Current Disk is B, and Current User is   5
Name of File to Search For (<CR>=Done)? 
