;*********************************************************
; FILE: io.asm
;
; This contains slightly higher level console related
; functions like text output, reading a line, etc.
;*********************************************************
;
;		zpage
;putsp		ds	2
;
		bss
BUFFER		ds	BUFFER_SIZE
argc		ds	1
argv		ds	MAX_ARGC
;
		code
;
;*********************************************************
; Print the string that follows the JSR to this code.
; Taken from http://www.6502.org/source/io/primm.htm
; The last example by Ross Archer.
;
putsil		pla		;Get the low part of "return" address
				;(data start address)
		sta	putsp
		pla
		sta	putsp+1	;Get the high part of "return" address
				;(data start address)
				;Note: actually we're pointing one short
PSINB		ldy	#1
		lda	(putsp),y	;Get the next string character
		inc	putsp	;update the pointer
		bne	PSICHO	;if not, we're pointing to next character
		inc	putsp+1	;account for page crossing
PSICHO		ora	#0	;Set flags according to contents of
				;   Accumulator
		beq	PSIX1	;don't print the final NULL
		jsr	cout	;write it out
		jmp	PSINB	;back around
PSIX1		inc	putsp
		bne	PSIX2
		inc	putsp+1	;account for page crossing
PSIX2		jmp	(putsp)	;return to byte following final NULL
;
;=====================================================
; This prints the null terminated string pointed to by
; INL and INH.  Modifies those locations to point to
; the end of the string.
;
puts		ldy	#0
putsy		lda	(INL),y
		inc	INL
		bne	puts1
		inc	INH
puts1		ora	#0
		beq	putsdone
		sty	SaveY
		jsr	cout	;print character
		ldy	SaveY
		jmp	putsy
putsdone	rts
;
;*********************************************************
; Get a line of text from the console and put it into
; BUFFER.  This only allows printable characters, will
; limit the amount of text to BUFFER_SIZE-1 characters,
; and allows some editing.  Returns the string with a null
; byte at the end and the length in A.  If the length is
; zero, return Z set.
;
getline
	if 0
		ldx	#0
		beq	getline1
;
; This outputs a bell.  Used when the user
; does something bad, like non-printable
; characters or exceeding line length.
;
getline2	lda	#BELL
		jsr	cout
;
; Get the next character
;
getline1	jsr	cin	;get character
		cmp	#' '
		bcc	getline2	;not printable
		cmp	#'~'+1
		bcs	getline2	;not printable
		cmp	#CR	;end of input?
		beq	getline3
		cpx	#BUFFER_SIZE-1
		beq	getline1	;too long
		sta	BUFFER,x
		jsr	cout	;echo, echo, echo...
		inx
		bne	getline1
;
; Got a CR, so terminate the string.
;
getline3	lda	#0
		sta	BUFFER,x
		txa		;will set/clear Z
	endif
		rts
;
;*********************************************************
; This converts the buffer to all lower case.
;
ToLower		ldx	#0
ToLower1	lda	BUFFER,x
		beq	ToLowerDone
;
		cmp	#'a'
		bcc	ToLower2
		cmp	#'z'+1
		bcs	ToLower2
		clc
		sbc	#$20	;convert
		sta	BUFFER,x
ToLower2	inx
		bne	ToLower1
;
ToLowerDone	rts
;
;*********************************************************
; This parses the current contents of BUFFER.  It scans
; until finding whitespace, terminates the string (puts a
; null), then scans until finding the next non-whitespace
; and repeats the process again.  Saves the offset to each
; word in argc, and has a total count in argv.  Yes, I am
; a C programmer.
;
parse
	if 0
		ldx	#0
		stx	argc	;clear count
		dex
;
; Skip whitespace
;
parse1		inx
		lda	BUFFER,x
		beq	parse2	;at EOL
		cmp	#' '
		beq	parse1	;whitespace
;
; Not whitespace
;
		ldy	argc
		stx	argv,y
		iny
		cpy	#MAX_ARGC
		beq	parse2
		sty	argv
;
; Now skip until whitespace found again
;
parse3		inx
		lda	BUFFER,x
		beq	parse2
		cmp	#' '
		bne	parse3
		lda	#0
		sta	BUFFER,x	;terminate
		jmp	parse1
;
	endif
parse2		rts
;
;*********************************************************
; Dump the contents of A as two hex digits.  Preserves
; all registers.
;
HexA		pha		;save value
		pha
		lsr	a
		lsr	a
		lsr	a
		lsr	a
		jsr	HexDigit
		pla
		jsr	HexDigit
		pla		;restore value
		rts
;
HexDigit	and	#$0f
		cmp	#$0a
		clc
		bmi	HexDigit1
		adc	#7
HexDigit1	adc	#'0'
		jmp	cout
;
;*********************************************************
; Output a CR/LF combination to the console.  Preserves
; all registers.
;
crlf		pha
		lda	#CR
		jsr	cout
		lda	#LF
		jsr	cout
		pla
		rts
;
;*********************************************************
; Output one, two or three spaces.  Preserves all
; register.
;
space3		jsr	space
space2		jsr	space
space		pha
		lda	#' '
		jsr	cout
		pla
		rts


