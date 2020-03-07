;********************************************************************
; MTEST: Altair 680 Memory Test Program
;
; Revision History:
;    Date        Author         Comment
;  23OCT2011  M. Eberhard  Created
;  27OCT2011  M. Eberhard  Don't use page 0 memory, so we can test it
;  27OCT2011  M. Eberhard  Make code relocatable and relocating
;  03NOV2011  M. Eberhard  comp. tsts, and check memory immediately
;  03NOV2011  M. Eberhard  combine fill and test passes for speed
;
; Descriprion:
;  This program tests a range of Altair 680 memory, specified by the
;  user. Before specifying the test memory range, the user is asked
;  to specify where in memory the MTEST itself should sit. MTEST
;  installs a little 'mover'program in memory at 0000. This mover
;  moves MTEST from its current location to the specified location,
;  then transfer control to the newley moved code. Once moved, the
;  code at 0000 is no longer needed, and can be wiped out by the
;  memory test.
;
;  The purpose of this relocation is to allow all portions of the
;  Altair 680's memory to be tested. This program will prevent the
;  user from locating MTEST below 0100, because the PROM monitor's
;  I/O routines use flags in this area.. But it does not check to
;  see if the range of memory to test overlaps MTEST itself.
;  (perhaps this check can be done in a future version.) The mover
;  does check to see if it wrote correctly as it is moving the code.
;  if a code write fails, then the program simply aborts to the PROM
;  monitor.
;
;  The memory test algorithm is designed to ferret out a variety of
;  memory problems. It is based on a test pattern that contains two
;  walking bit patterns - one with the bit high, and the other with
;  the bit low. It also contains various high-frequency patterns
;  like 55 and AA. These pattern elements are scrambled to maximize
;  the number of times each memory bit changes value during the
;  test. The entire pattern is deliberately 29 bytes  long -- a 
;  prime number. The pattern is written repeatedly  through the test
;  memory range, then read back and checked. Then the pattern is
;  incremented for another pass through memory. This is repeated
;  until every memory location in the test range has been tried with
;  each byte in the test pattern. This should catch all address-line
;  shorts, data line shorts, coupling between nearby cells, stuck
;  bits, and even catch some longer-term memory loss faults.
;
; Program Notes:
; * Written to assemble with PseudoCode's A68.com, a DOS-based cross
;   assembler for the MC6800
; * A68.com vers. 1.2.02 assembles 'jsr' incorrectly. to fix, patch
;   A68.com address AFABh to be 8Dh (was 9Dh).
; * A68.com does not generate 'direct' versions of lda and sta. We
;   generate them the hard way (with .db) here.
;*  This program uses several I/O routines in the PROM monitor, and
;   is therefore dependant on the standard Altair PROM monitor being
;   present. (See 'PROM monitor entry points' below.)
; * This program uses no page-0 memory, so that page 0 can be tested.
; * The main program is completely relocatable -- it relocates itself
;   to an address specified by the user, so that all of memory can be
;   tested. We pay a high performance and code-size penalty for
;   having the code relocatable and not using page-0.
; * The various subroutines are located in somewhat odd places, so
;   that the bsr's reach, and everything remains relocatable.
;
; TO DO
; * Replace PROM Mon's 'inch' routine so we can relocate to page 0.
;   Note that 'inch' use 'echo' in page 0.
;
;********************************************************************
;**
;* Program Equates
;**
	.equ	maxers,64	;max number of errors before we quit
;**
;* ASCII equates
;**
	.equ	CTRLC,h'03	;control C
	.equ	CR,h'0d		;carriage return
	.equ	LF,h'0a		;line feed
;**
;* 6800 equates
;**
	.equ	SKIP2,h'8c	;CPX instruction for SKIP2 trick
;stupid assembler can't do direct addressing for some instructions
	.equ	ldaad,h'96	;ldaa direct
	.equ	ldabd,h'd6	;ldab direct
	.equ	staad,h'97	;staa direct
	.equ	stabd,h'd7	;stab direct
	.equ	addad,h'9b	;adda direct
	.equ	adcad,h'99	;adca direct
	.equ	subad,h'90	;suba direct
	.equ	sbcad,h'92	;sbca direct
	.equ	subbd,h'd0	;subb direct
	.equ	sbcbd,h'd2	;sbcd direct
;**
;* PROM Monitor entry points
;**
	.equ	inch,h'ff00	;get chr in b
	.equ	out2h,h'ff6d	;print a in hex, clobber b
	.equ	outch,h'ff81	;print chr in b on console
	.equ	outs,h'ff82	;print a space on the console
	.equ	reset,h'ffd8	;cold start
	.equ	echo,h'f3	;PROM monitor echo flag

;**************************************************************
;* Disable echo during load
;**************************************************************
	.org	echo
	.db	h'80

;**************************************************************
;* page 0 variables for mover
;**************************************************************
	.org 0

mdest:	.rs	2		;destination address
msourc:	.rs	2		;source address
mtstrt:	.rs	2		;mtest start address for user
mvbase:	.rs	2		;new vbase
	.rs	1		;stack space for 1 bsr
mstack:	.rs	1		;initial stack pointer address
gotoa:	.rs	2		;this is actually on the stack

; The following variables must be in this order, before exemov
; becasue they get initialized when the mover is installed

mmdest:
mcount:	.rs	2		;bytes of code
mtlen:	.rs	2		;mtest ofset to last byte
exemov:				;execution address for mover

;**************************************************************
;* MTEST Start of Execution
;**************************************************************
	.org	h'0100		;start out low in ram

mtest:	sei			;mask interrupts

; Print sign-on message

	ldab	#somsg-vbase	;print sign-on message
	bsr	prntc2		;...and set x=vbase

; Set up parameters to move little mover into page 0 memory

	stx	msourc		;source will need mover-vbase offset
	ldab	#movend-mover	;b= number of bytes to move
	ldx	#mmdest		;destination in page 0
	stx	mdest

; Copy little mover program into page 0 memory, initializing
; a couple of variables at the same time

putmov:	ldx	msourc		;get a source byte, bump ptr
	ldaa	mover-vbase,x
	inx
	stx	msourc

	ldx	mdest		;put at dest, bump ptr
	staa	0,x
	inx
	stx	mdest

	decb			;count down to end
	bne	putmov

; Compute address of this code's beginning = source of code move

	bsr	getbeg		;shove PC onto stack
getbeg:	pulb			;pull PC high byte
	pula			;pull PC low byte
	suba	#getbeg-mtest	;correct for above code
	sbcb	#0		;borrow
	.db	staad,msourc+1	;save low byte
	.db	stabd,msourc	;save high byte

; Ask user where we should put the code. Make sure the address is
; not in page 0, where our little mover and the 'echo' flag are

getca:	ldab	#camsg-vbase	;ask for code address
	bsr	getadr		;code address is in mdest
				;a=low(mdest), b=high(mdest)
				;Z set if b=0
	beq	getca		;try again if high byte=0

; Compute vbase for post-move code

	adda	#(vbase-mtest)%h'100
	.db	staad,mvbase+1
	adcb	#(vbase-mtest)/256
	.db	stabd,mvbase

; Remember the code start address for later reporting and testing

	ldx	mdest
	stx	mtstrt		;save to tell user

; Set up 'return' to the post-move code (x=(mdest) here)

	ldab	#init-mtest
	
gotolp:	inx			;loop: compute x=x+b
	decb
	bne	gotolp
	stx	gotoa		;this is on mover's local stack	

; b=0 here
; Test for forward or reverse copy, so this will work even if
; the destination overlaps the source. 
; b=0 for forward (mdest<msourc)
; b=1 for reverse (mdest>msourc)
; This will do the copy even if msourc=mdest

	.db	ldaad,msourc+1	;lsb compare
	.db	subad,mdest+1
	.db	ldaad,msourc	;msb compare
	.db	sbcad,mdest
	bcc	mcopy	;source is larger address. copy forward

; copy backward - first need to compute end addresses

	incb		;note reverse copy

	ldx	#msourc	;compute source last addresses
	bsr	addlen
	ldx	#mdest	;compute destination last address
	bsr	addlen

; Now use the page-0 Little Mover code to move this program

mcopy:	lds	#mstack		;set up stack for little mover
	jmp	exemov

;**************************************************************
;* Subroutines here for bsr reach
;**************************************************************

;**************************************************************
;* Subroutine to print message, then get an address from user
;* retry until we get good hex
;* Entry at gtsadr asks the user for the start address of the code
;* on entry at getadr:
;*   vbase+b=address of message string
;* on exit:
;*   mdest=16-bit value from user
;*   a=(mdest+1) = low byte of received hex
;*   b=(mdest) = high byte of received hex
;*   Z flag set if b=0
;*   x=vbase
;*   errcnt=0
;**************************************************************
getadr:	pshb		;save string in in a case of bad input

	bsr	prntc2		;print ask message, x=vbase

	clr	errcnt-vbase,x	;no hex errors yet

	bsr	in2hex		;get high byte into tend
	.db	staad,mdest
	bsr	in2hex		;get low byte into tend+1
	.db	staad,mdest+1	;...and into a

	pulb			;recover ask msg pointer

	tst	errcnt-vbase,x	;any errors with hex input?
	bne	getadr

	.db	ldabd,mdest	;set up b, Z for return
	rts

;**************************************************************
;* stepping stones for longer branches
;**************************************************************
prntc2:	bra	prntc1

;**************************************************************
;* subroutine to add (16-bit) (mtlen) to (x)
;* this subroutine cannot be used during the actual memory
;* test, because it uses page-0 memory.
;* On Exit:
;*    (x)=(x)+(mtlen)
;*    x unchanged. trashes a
;**************************************************************
addlen:	ldaa	1,x	;low byte
	.db	addad,mtlen+1
	staa	1,x
	ldaa	0,x	;high byte + carry
	.db	adcad,mtlen
	staa	0,x
	rts

;**************************************************************
;* Subroutine to a get 2 hex digits into a
;* Abort to PROM if user types control-C
;* on entry:
;*    x=vbase
;* on exit:
;*    a=hex byte
;*    errcnt=0 for good hex, <>0 for bad chr
;*    b trashed
;*    x=vbase
;**************************************************************
in2hex:	bsr	inhex	;get 1st hex nibble into b
	aslb		;shift to high-order nibble
	aslb
	aslb
	aslb
	tba		;save high nibble in a

; fall into inhex

;***
;* Local subroutine to get one hex digit into b
;* Jump to error if invalid character
;* on exit, result is in b, and a=a+b (nibble combine)
;* if bad hex digit, inc errcnt, a,b=garbage
;* Control-C aborts to the PROM monitor
;**
inhex:	jsr	inch	;get a chr
	cmpb	#CTRLC	;abort?
	beq	abort

	subb	#'0'	;convert ASCII number to hex
	cmpb	#h'09
	ble	hexdon	;done already?
	cmpb	#h'11
	bmi	hexerr	;not hex 
	subb	#h'07	;convert ASCII letter to hex
	cmpb	#h'0f
	ble	hexdon	;good hex: branch

hexerr:	inc	errcnt-vbase,x	;flag error

hexdon:	aba		;combine with high digit in a
	rts

abort:	jmp	reset

;**************************************************************
; subroutine to print the address range of this program, and
; then get start and end test addresses from the user
;* On entry:
;*    mtstrt = first address of this program
;*    mtlen  = byte length of this program
;* On Exit:
;*    mtstrt = first address of this program
;*    mtlen  = byte length of this program
;*    mcount = last address of this program
;*    errcnt=0
;*    x=vbase
;*    a,b, trashed
;**************************************************************
gparms:
;* Print address range of this program
;* mtstrt = first code address
;* mcount = last code address

gparm1:	ldab	#rngmsg-vbase	;'mtest:'
	bsr	prntc1

	ldx	#mtstrt
	bsr	outadr		;print address as 4 hex digits

	ldx	mtstrt		;compute last code address
	stx	mcount		;result will be in mcount
	ldx	#mcount
	bsr	addlen		;(mcount)=(mstrt)+(mtlen)
	bsr	outadr		;print address as 4 hex digits
	
; Get memory test parameters. gtsadr returns with the user-
; entered address in mdest and also in a & b, and x=vbase.

gparm2:	ldab	#samsg-vbase		;'start address?'
	bsr	getadr			;sets x=vbase too
	staa	tstart-vbase+1,x	;low byte is in a	
	stab	tstart-vbase,x		;high byte is in b

	ldab	#eamsg-vbase		;'end address?'
	bsr	getadr
	staa	tend-vbase+1,x		;low byte is in a	
	stab	tend-vbase,x		;high byte is in b

; Bounds checks
;   mtstrt = first code address
;   mcount = last code address
;   tstart = first test address
;   tend = a,b = last test address
;   x=vbase

; make sure tend>=tstart (a=tend low byte, b=tend high byte)

	suba	tstart-vbase+1,x
	sbcb	tstart-vbase,x
	bcs	gparm2

; See if tstart>mcount (which is the last code address now)

	.db	ldaad,mcount+1
	suba	tstart-vbase+1,x
	.db	ldaad,mcount
	sbca	tstart-vbase,x
	bcs	gparm3		;test mem is above code
	
; make sure mtstrt>tend (test mem is below code)

	ldaa	tend-vbase+1,x
	.db	subad,mtstrt+1
	ldaa	tend-vbase,x
	.db	sbcad,mtstrt
	bcc	gparm1		;overlap error

gparm3:	rts

;**************************************************************
;* stepping stones for longer branches
;**************************************************************
getvb2:	bra	getvb1
prntc1:	bra	printc

;**************************************************************
;* Subroutine to print (x) as 4 hex digits preceeded by
;* a space. This subroutine cannot be used during the actual
;* memory test.
;**************************************************************
outadr:	jsr	outs		;print leading space

	ldaa	0,x		;high byte
	bsr	outahx
	ldaa	1,x		;low byte

outahx:	jmp	out2h		;use PROM monitor routine

;**************************************************************
;* Initialize variables for the actual memory test
;* We return here after the code has been moved
;**************************************************************
init:	ldx	mvbase		;new vbase for new code
	stx	0,x

; Initialize the stack (x=vbase here)

	ldab	#stack-vbase	;compute address of stack
stklp:	inx
	decb
	bne	stklp

	txs			;set up stack

; Get and validate memory test parameters from the user

	bsr	gparms

; Initialize RAM variables
; Note: errcnt was cleared by getadr in gparms

	clr	pflag-vbase,x	;we need to print 'pass'
	clr	passno-vbase,x	;start with pass number 0
	ldaa	#patlen+1	;initial pattern start
	staa	pxstrt-vbase,x

; fall into nxtpas

;**************************************************************
;* Main program loop
;*
;* this will perform on full pass through the user-specified
;* range of memory for each element in the test pattern plus
;* one - thirty passes in total.
;*
;* On initial pass through memory, just fill with the pattern,
;* quickly complimenting it a few times with each write to
;* torture memory.
;* 
;* On subsequent passes, each byte against what was written,
;* then fill with the next pattern entry.
;*
;* No page-0 memory may be used past this point.
;*
;* On entry:
;*    x=vbase
;**************************************************************
;**
;* Start a new pass through memory:
;* Set pointer to beginning of memory, and the start of this
;* pass's pattern
;**
nxtpas:	ldaa	tstart-vbase,x	;set memory pointer to the
	staa	tptr-vbase,x	;...beginning of test memory
	ldaa	tstart-vbase+1,x
	staa	tptr-vbase+1,x

	ldaa	pxstrt-vbase,x	;set pattern pointer to this
	staa	pxptr-vbase,x	;...pass's pattern start	
;**
;* Test & write the next byte in memory:
;* Compute pointer to next pattern entry +1
;* x=vbase here.
;** 
nxtbyt:	ldaa	pxptr-vbase,x	;point to pattern entry
	deca
	bne	fltst1		;modulo bump
	ldaa	#patlen
fltst1:	staa	pxptr-vbase,x

; Get pattern entry the hard way
; a = (vbase+patrn+a)
; This loop is the worst penalty for relocatable code.

xplusa:	inx			;compute x=x+a
	deca			;to get this pattern entry
	bne	xplusa

	ldab	patrn-vbase-1,x	;a=expected pattern entry
	ldaa	patrn-vbase,x	;a=previous pattern entry

	pshb			;save next data

	bsr	getvb1		;get address of 'vbase'
	ldab	passno-vbase,x	;first pass?
	ldx	tptr-vbase,x	;get current memory address

; a=expected value, b=passno, (stack)=next value, x=address

	tstb			;first pass?
	beq	fltst3		;don't test if so

fltst2:	ldab	0,x		;read memory into b
	cba			;compare to pattern in a
	beq	fltst3		;ok - keep going
	bsr	memerr		;report error on console
fltst3:	pulb			;recover next data

; Write new data to this memory location

	stab	0,x		;b<>0: fill memory this pass

	com	0,x		;flip a few times to torture
	com	0,x		;be fast: don't use a loop
	com	0,x
	com	0,x

; Bump memory pointer and see if we've reached the end

	bsr	getvb1		;get address of 'vbase'
	inc	tptr-vbase+1,x	;bump current memory address
	bne	fltst4
	inc	tptr-vbase,x	;16-bit bump
fltst4:
	ldaa	tend-vbase+1,x	;compare address low bytes
	suba	tptr-vbase+1,x	;set C on borrow
	ldaa	tend-vbase,x	;compare address high bytes
	sbca	tptr-vbase,x	;including borrow

	bcc	nxtbyt		;next byte this pass
;**
;* We made it all the way through memory. time for another pass
;**
	bsr	ppass		;print pass number for user

; Bump starting point in the pattern to loop through all
; patterns in every memory location

	dec	pxstrt-vbase,x	;bump pattern start point
	bne	nxtpas		;next pass through memory

; All done - report error count and return to PROM monitor

	ldab	#crmsg-vbase	;ending CRLF
	bra	exit

;**************************************************************
;* Subroutines here for bsr reach
;**************************************************************

;**************************************************************
;* stepping stone for longer branches
;**************************************************************
getvb1:	bra	getvb

;**************************************************************
;* Subroutine to print CRLF, then the string at vbase+b
;* On entry:
;*   b=string address offset from vbase (b>0)
;* On exit:
;*   b trashed
;*   x=vbase
;**************************************************************
printc:	pshb			;save string reference
	bsr	getvb		;x=vbase
	ldab	#crmsg-vbase	;CRLF
	bsr	printb
	pulb			;recover string address

; fall into printb

;**************************************************************
;* Subroutine to print null-terminated string at vbase+b
;* On entry:
;*   b=string address offset from vbase (b>0)
;*   x=vbase (we exit through getvb)
;* On exit:
;*   b trashed
;*   x=vbase
;**************************************************************
printb:	
xplusb:	inx			;count x register up
	decb
	bne	xplusb		;loop until x points to string

printx:	ldab	0,x		;get a string byte
	beq	getvb		;null: exit through getvb
	inx			;next
	jsr	outch		;PROM: print chr in b
	bra	printx

;**************************************************************
;* Subroutine to report memory error
;* on entry:
;*   a=expected data
;*   b=found data
;*   x= tptr=address
;* on exit:
;*   b trashed
;*   errcnt is decremented, and abort if errcnt=0
;*   x=tptr
;**************************************************************
memerr:	bsr	getvb		;get address of 'vbase'

	pshb			;found data onto stack
	psha			;expected data onto stack

	inc	errcnt-vbase,x	;too many errors?
	ldab	#maxers		;max allowed errors
	cmpb	errcnt-vbase,x
	beq	erdone		;quit if so

	clr	pflag-vbase,x	;we need to print 'pass'

	ldab	#errms1-vbase	;'error at'
	bsr	printc

	ldaa	tptr-vbase,x	;high byte of address
	bsr	outshx
	ldaa	tptr-vbase+1,x	;low byte of address
	bsr	outhex

	ldab	#errms2-vbase	;' wrote'
	bsr	printb

	pula			;recover expected value
	bsr	outshx

	ldab	#errms3-vbase	;' read'
	bsr	printb

	ldx	tptr-vbase,x	;recover address pointer

	pula			;recover found value
	bra	outshx		;exit via outshx

;**************************************************************
;* Subroutine to print pass # for user, with 'pass' if needed
;* On entry: x=vbase
;**************************************************************
ppass:	dec	pflag-vbase,x	;enough entries on this line?
	bpl	ppass1
	ldab	#15		;max 16 entries per line
	stab	pflag-vbase,x
	
	ldab	#pasmsg-vbase	;print CRLF,'pass'
	bsr	printc

ppass1:	ldaa	passno-vbase,x	;print pass number
	inc	passno-vbase,x	;bump pass number

; fall into outshx for return

;**************************************************************
;* Subroutine to print a space, then print a as 2 hex digits
;* does not touch a
;**************************************************************
outshx:	jsr	outs		;print leading space

;fall into outhex

;**************************************************************
;* Subroutine to print a as 2 hex digits
;**************************************************************
outhex:	jmp	out2h		;use PROM monitor routine

;**************************************************************
;* Exits: erdone for too many errors
;* exit (with string address in x) for normal exit
;* error count in errcnt
;**************************************************************
erdone:	ldab	#mormsg-vbase	;'>'

exit:	bsr	printc		;print with preceeding CR LF
	ldaa	errcnt-vbase,x	;print error count
	bsr	outhex
	ldab	#donmsg-vbase
	bsr	printb		;print final message

	jmp	reset		;return to PROM monitor

;**************************************************************
;* Subroutine to get value of vbase into x (This subroutine
;* must be at end, right before strings and variables.)
;* This nasty little piece of self-modifying code makes the 
;* rest of the code location-independent
;* On exit: x=vbase
;**************************************************************
getvb:	.db	h'ce	;ldx immediate
vbase:	.dw	vbase	;this gets modified when the code
	rts		;...gets moved

;**************************************************************
;* Null-terminated strings
;* nulls after CRLF have parity bit set
;**************************************************************
pasmsg:	.db	"PASS:",0
somsg:	.db	"680 MTEST 1.4"
	.db	CR,LF,h'80,"BY M. EBERHARD"	;fall into crmsg
crmsg:	.db	CR,LF,h'80,0
camsg:	.db	"CODE ADDR (>00FF)? ",0
samsg:	.db	"BEG ADDR? ",0
eamsg:	.db	"END ADDR? ",0
rngmsg:	.db	"MTEST:",0
errms1:	.db	"ERR AT",0
errms2:	.db	" WROTE:",0
errms3:	.db	" READ:",0
donmsg:	.db	" ERRORS"	;fall into nulmsg
nulmsg:	.db	h'80,h'80,0	;nulls protect for ACIA reset
mormsg:	.db	"> ",0

;**************************************************************
;* Test pattern sequence, a prime number in length
;* Designed to cause a lot of bit-flipping and to catch
;* any bit-coupling and address-coupling problems
;**************************************************************
patrn:	.db	h'01,h'fe,h'02,h'fd,h'04,h'fb,h'08,h'f7
	.db	h'10,h'ef,h'20,h'fd,h'40,h'bf,h'80,h'7f
	.db	h'00,h'ff,h'55,h'aa,h'33,h'cc,h'f0,h'0f
	.db	h'c3,h'3c,h'66,h'99,h'78
patend:	.db	h'01		;wrap pattern one byte
	
	.equ	patlen,patend-patrn

;**************************************************************
;* RAM variables not in page 0, so that we can test page 0 RAM
;**************************************************************

	.rs	15	;reserve space for stack
stack:	.rs	1	;needs to be before RAM variables

tstart:	.rs	2	;first memory address to test
pxstrt:	.rs	1	;pattern starting point
tptr:	.rs	2	;current memory test location
pxptr:	.rs	1	;current place in pattern
tend:	.rs	2	;last memory address to test
errcnt:	.rs	1	;error count
pflag:	.rs	1	;0 means we need to print 'pass'
passno:	.rs	1	;current pass number

;**************************************************************
;* Little Code Mover
;* copy code to new location. test for good write, and reset
;* if not.
;* This code gets put in page 0 before running
;*   b=0 for forward copy (mdest<msourc)
;*   b=1 for reverse copy (mdest>msourc)
;* 16-bit Variables On Entry:
;*   msourc = first address of source
;*   mdest = first address of destination
;*   mcount = number of bytes to copy
;* Must be here, so that 'mover' is close to vbase.  
;**************************************************************

;* initialize these two variables while we install the mover


mover:	.dw	movend-mtest	;this initializes mcount
	.dw	movend-mtest-1	;this initializes mtlen

movlup:	ldx	msourc	;get a source byte
	ldaa	0,x
	bsr	incdec	;bump and save pointer
	stx	msourc

	ldx	mdest	;save byte at destination
	staa	0,x

	cmpa	0,x	;make sure it wrote
	bne	reset+mover-exemov ;wrap around to reset

	bsr	incdec	;bump and save pointer
	stx	mdest

	ldx	mcount	;bump and test loop count
	dex
	stx	mcount
	bne	movlup

id1:	inx		;a little code recycling
mdone:	rts		;jump to new code
;*
;* subroutine to either increment or decrement x
;* based on b. b=0 means increment
;*
incdec:	tstb
	beq	id1
	dex
	rts
movend:

;**************************************************************
;* enable echo after load
;**************************************************************
	.org	echo
	.db	0

	.end

