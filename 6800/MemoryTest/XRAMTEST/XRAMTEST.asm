; ------------------------------------------------------------------------------
; XRAMTEST.ASM - Extended RAM Test
; RETRO-EP4CE15 card has (2) 8KB windows with 64 banks in each window
; Tests all banks in both windows
; Prints:
;	S0++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;	1+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++D
;	S = start
;	0/1 = block number
;	+ = block good
;	X = bad
;	D = done
; Hit a key at end to avoid resetting the Serial port until done
; Jumps to SmithBUG when done
; 
; Assembled using A68 assembler
; 	"..\..\A68 6800 Assembler\a68.exe" XRAMTEST.ASM -l XRAMTEST.LST -s XRAMTEST.SRE
;
; Memory Map
;	0xA000-0xBFFF - 512KB External SRAM
;		8KB Windows, 64 frames
;		MMU1 provides additional address bits
;		MMU1 initialized to 0
;	0xC000-0xDFFF - 512KB External SRAM
;		8KB Window, 64 frames
;		MMU2 provides additional address bits
;		MMU2 initialized to 0
;	0xFC18-0xFC19 - VDU  (serSelect J3 JUMPER REMOVED)
;	0xFC28-0xFC19 - ACIA (serSelect J3 JUMPER INSTALLED)
;	0xFC30 - MMU0 Latch 6-bits
;	0xFC31 - MMU1 Latch 6-bits
; ------------------------------------------------------------------------------

; I/O
ACIACS:		EQU	$FC18
ACIADA:		EQU	$FC19
MMUREG0:	EQU $FC30
MMUREG1:	EQU $FC31
; MEMORY RANGES
XRAMST0:	EQU	$A000
XRAMEND0:	EQU	$BFFF
XRAMST1:	EQU	$C000
XRAMEND1:	EQU	$DFFF
TOPBANKNUM:	EQU	$3F
; SmithBUG re-start address
SMITHBUGSTART:	EQU $f01f

; The variables memory
	ORG	$0
STARTADR:	RMB	2
ENDADR:		RMB	2
BANKNUM:	RMB 1
BANK0VAL:	RMB	1
BANK1VAL:	RMB	1

	ORG	$100		; Program starts here
	jsr	CRLF
	lda	a	#'S'	; Start test
	jsr OUTEEE
	lda	a	#'0'	; Print Bank Number
	jsr OUTEEE

; Inits
	lda	a #0		; init bank number, bank values
	sta a BANKNUM
	sta a BANK0VAL
; loop through the first bank
LOOP_BNK0:
	jsr	SETENDS
	jsr	testRAM		; Do RAM test
	cmp a #0
	bne	GOTERR
	lda a #'+'
	jsr	OUTEEE
	lda a BANK0VAL
	inc a
	sta a BANK0VAL
	cmp a #TOPBANKNUM
	ble	LOOP_BNK0
; Init for 2nd bank
	jsr	CRLF
	lda	a	#'1'	; Print Bank Number
	jsr OUTEEE
	lda	a #1		; init bank number, bank values
	sta a BANKNUM
	sta a BANK1VAL
; loop through the second bank
LOOP_BNK1:
	jsr	SETENDS
	jsr	testRAM		; Do RAM test
	cmp a #0
	bne	GOTERR
	lda a #'+'
	jsr	OUTEEE
	lda a BANK1VAL
	inc a
	sta a BANK1VAL
	cmp a #TOPBANKNUM
	ble	LOOP_BNK1
	
DONETEST:
	lda a #0
	sta a MMUREG0		; Reset back bank
	sta a MMUREG1
	lda	a	#'D'		; PASSED TEST
	jsr OUTEEE
	jsr	CRLF
	jsr	INEEE			; Hit a char to end
	JMP	SMITHBUGSTART	; Restart SmithBUG

GOTERR:
	lda a #0
	sta a MMUREG0		; Reset back bank
	sta a MMUREG1
	lda	a	#'X'	; Error
	jsr OUTEEE
	jsr	CRLF
	jsr	INEEE			; Hit a char to end
	rts

; Set up the RAM variables for the test boundaries
SETENDS:
	lda	a BANKNUM
	cmp	a #0
	bne	BANK1
	lda	a BANK0VAL	; BANK0 SETUP
	sta	a MMUREG0
	ldx	#XRAMST0	; set start ADDRESS
	stx	STARTADR
	ldx	#XRAMEND0
	stx	ENDADR
	rts
BANK1:				; BANK1 SETUP
	lda	a BANK1VAL
	sta	a MMUREG1
	ldx	#XRAMST1	; set start number
	stx	STARTADR
	ldx	#XRAMEND1
	stx	ENDADR
	rts

; Do the RAM Test
; BANKNUM = 0,1
; STARTADR = START ADDRESS OF THE TEST
; ENDADR - END ADDRESS OF THE TEST
; Returns
;	0 = Pass
;	1 - False

testRAM:
	ldx	STARTADR
	lda a  #0
FILLOOP:
	sta	a x
	inx
	inc a
	cpx	ENDADR
	ble	FILLOOP
; Check
	ldx	STARTADR
	lda a #0
GOODRD:
	cmp a x
	bne	BADREAD
OKREAD:
	inx
	inc a
	cpx	ENDADR
	ble	GOODRD
	clr a			; Finished check
	rts
BADREAD:
	lda a #1		; Bad
	rts

CRLF:
	lda	a #$0a
	jsr	OUTEEE
	lda	a #$0d
	jsr	OUTEEE
	rts

INEEE:	NOP
IN1	LDA A	ACIACS
	ASRA
	BCC	IN1	;RECEIVE NOT READY
	LDA A	ACIADA	;INPUT CHARACTER
	ANDA	#$7F	;RESET PARITY BIT
	CMPA	#$7F
	BEQ	IN1	;IF RUBOUT, GET NEXT CHAR
	RTS
;
;	OUTPUT ONE CHAR IN REG A
;
OUTEEE:	PSH	A
OUTEEE1 LDA A	ACIACS
	ASR A
	ASR A
	BCC	OUTEEE1
	PUL A
	STA A	ACIADA
	RTS
;

	END
	