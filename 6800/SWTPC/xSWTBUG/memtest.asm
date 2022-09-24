;=====================================================
; A basic memory test for the 6800, using some calls
; in SWTBUG.  August, 2014 by Bob Applegate
; bob@corshamtech.com
;
; This uses a 9 byte repeating sequence.  Since the
; pattern repeats every nine locations, it can detect
; shorted address bits.
;
	if	~IN_SWTBUG	;SWTUB provides much of this
EOT		equ	$04
LF		equ	$0a
CR		equ	$0d

BADDR		equ	$e047
PDATA1		equ	$e07e
OUT4HS		equ	$e0c8
OUT2HS		equ	$e0ca
CONTRL		equ	$e0e3
;OUTCH		equ	$e1d1
	endif

;
; After rolling through all 8 bits, this is the
; ninth value written.  Can be anything, but I'd
; suggest not using a power of two.
;
SPECIAL		equ	$55


		bss
		org	$a080
LOMEM		dw	$a300
HIMEM		dw	$bfff
pattern		ds	1
expected	ds	1
got		ds	1
failaddr	ds	2

;
; If part of SWTBUG then don't set ORG, let SWTBUG do that.
;
		code
	if	~IN_SWTBUG
		org	$a100
	endif
MemTest		ldx	#startmsg	;initial hello message
		jsr	PDATA1
;
; Ask for and save the starting address to test
;
		ldx	#lomsg
		jsr	PDATA1
		jsr	BADDR
		stx	LOMEM
		jsr	crlf
;
; Now ask for the ending address
;
		ldx	#himsg
		jsr	PDATA1
		jsr	BADDR
		stx	HIMEM
;
; Display the range we're testing just for a sanity check
;
		ldx	#addrmsg
		jsr	PDATA1
		ldx	#LOMEM
		jsr	OUT4HS
		ldx	#endmsg
		jsr	PDATA1
		ldx	#HIMEM
		jsr	OUT4HS
		ldx	#anykeymsg
		jsr	PDATA1
;
; Initialize loop
;
		lda	#$01		;starting pattern
;
; Upon entry, the contents of A are saved as the starting
; pattern for the next fill operation.
;
save_start	sta	pattern		;save for comparison
		ldx	LOMEM
;
; Loop to fill the next memory location
;
fill		sta	0,x
		cpx	HIMEM		;at last byte?
		beq	dotest		;yes, test memory
		inx			;move to next address
;
; Move to next pattern
;
		cmpa	#$80		;last bit roll?
		beq	fspec		;yes, so do special
		cmpa	#SPECIAL	;just did special?
		beq	fbit		;yes, so back to the starting bit pattern
		asla			;roll bit
		bra	fill		;write next pattern
fspec		lda	#SPECIAL
		bra	fill
fbit		lda	#$01
		bra	fill
;
; Done filling
;
dotest		lda	pattern		;get first pattern written
		ldx	LOMEM		;starting address
test		ldab	0,x		;load expected value
		cba			;what it should be?
		bne	fail		;no
		cpx	HIMEM		;at end?
		beq	passed
		inx
;
		cmpa	#$80		;last bit roll?
		beq	tspec		;yes, so do special
		cmpa	#SPECIAL	;just did special?
		beq	tbit		;yes, so back to the starting bit pattern
		asla			;else roll bit
		bra	test		;write next pattern
tspec		lda	#SPECIAL
		bra	test
tbit		lda	#$01
		bra	test
;
; It passed!  Print a progress dot and move on.
;
passed		psha
		lda	#'.'
		jsr	myOUTCH
;
; See if the user pressed a key.  If so, get it and then exit
; this program.
;
;		lda	$8004
;		anda	#$01
;		beq	continue
;		pula
;		lda	$8005		;get waiting character
;		bra	exit		;and then exit
;
;continue
		pula
		jmp	save_start
;
; Failed.  On entry, A contains the expected pattern, X contains
; the address that failed, and B is the actual value.
;
fail		sta	expected	;save values for later display
		stab	got
		stx	failaddr
		ldx	#failmsg
		jsr	PDATA1
;
		ldx	#failaddr	;display the failed address
		jsr	OUT4HS
		ldx	#fail2msg
		jsr	PDATA1
		ldx	#expected	;display expected value
		jsr	OUT2HS
		ldx	#fail3msg
		jsr	PDATA1
		ldx	failaddr	;display the actual value
		jsr	OUT2HS
		jsr	crlf
;
; Return to SWTBUG
;
exit
	if	IN_SWTBUG
		jmp	ExtCmd
	else
		jmp	CONTRL
	endif
;
;------------------------------------------------
; Print carriage return/line feed
;
	if	~IN_SWTBUG
crlf		ldx	#crlfmsg
		jmp	PDATA1
	endif
;
;------------------------------------------------
; I wrote my own OUTCH rather than using SWTBUG's
; because this will output the character in A,
; then check to see if a key has been hit.  If so,
; exit the program.
;
myOUTCH		psha			;save character
outch1		lda	$8004		;ACIA status register
		anda	#$02		;transmitter free?
		beq	outch1		;loop if not
		pula
		sta	$8005
		psha			;save it again
		lda	$8004
		anda	#$01		;char waiting in receiver?
		beq	outch2		;no
		bra	exit		;yes, so exit
outch2		pula
		rts

startmsg	db	CR,LF,LF
	if	~IN_SWTBUG
		db	"Bob's RAM test - bob@corshamtech.com"
		db	CR,LF,LF
	endif
		db	EOT
lomsg		db	"Enter starting address (4 hex digits): ",EOT
himsg		db	"Enter ending address:                  ",EOT
addrmsg		db	CR,LF,"Testing from ",EOT
endmsg		db	"to ",EOT
	if	~IN_SWTBUG
crlfmsg		db	CR,LF,EOT
	endif	
anykeymsg	db	CR,LF,"Press any key to abort",EOT
failmsg		db	CR,LF
		db	"Failed at address ",EOT
fail2msg	db	"expected ",EOT
fail3msg	db	"but got ",EOT
;
last		equ	$

