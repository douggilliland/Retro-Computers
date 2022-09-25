;*********************************************************
; FILE: acia.asm
;*********************************************************
;
CONSOLE_SLOT	equ	1
;
ACIA		equ	(CONSOLE_SLOT*IO_SIZE)+IO_BASE
RDRF		equ	%00000001
TDRE		equ	%00000010
;
;*********************************************************
; Initialize the ACIA
;
cinit		lda	#%00000011	;reset
		sta	ACIA
		nop
		lda	#%00010001	;8N2
		sta	ACIA
		rts
;
;*********************************************************
; Output the character in A to the console.  This will
; block until the character is queued.  Preserves all
; registers.
;
cout		pha
cout1		lda	ACIA
		and	#TDRE
		beq	cout1		;not empty
		pla
		sta	ACIA+1
		rts
;
;*********************************************************
; Gets a character from the console and returns it in A.
; Modifies no other registers.  This blocks until a
; character is available.
;
cin		lda	ACIA
		and	#RDRF
		beq	cin
		lda	ACIA+1
		rts
;
;*********************************************************
; Get the status of the console.  Returns Z set if no
; characters are available, Z clear if a character is
; ready.
;
cstatus		lda	ACIA
		and	#RDRF
		rts
