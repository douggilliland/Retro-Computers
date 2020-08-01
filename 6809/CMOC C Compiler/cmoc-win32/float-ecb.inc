; float-ecb.inc - Part of Standard CMOC library under Extended Color Basic.
;
; This file contains code that calls Color Basic and Extended Color
; Basic routines.

FP0ADDR	EQU	$004F
FP1ADDR	EQU	$005C

; Fields of Color Basic's first two (unpacked) float point accumulators.
FP0EXP	EQU	FP0ADDR
FP0MAN	EQU	FP0ADDR+1
FP0SGN	EQU	FP0ADDR+5
FP1EXP	EQU	FP1ADDR
FP1MAN	EQU	FP1ADDR+1
FP1SGN	EQU	FP1ADDR+5

VALTYP	EQU	$0006		; variable type (0 = numeric)
FPCARY  EQU     $005B           ; floating point carry byte
RESSGN	EQU	$0062		; sign of result of operation
FPSBYT  EQU     $0063           ; floating point sub byte

GETCCH	EQU	$00A5
CHARAD	EQU	$00A6		; interpreter's input pointer
COEFCT	EQU	$0055		; polynomial coefficient counter


#if defined(_CMOC_NEED_initSingleFromSignedWord_)

; Initializes the single-precision float at X with the signed word in D.
;
initSingleFromSignedWord
	pshs	u,y,x
	jsr	$B4F4			; load D (signed) into FPA0
	puls	x
	jsr	$BC35			; pack FPA0 into X
	puls	y,u,pc			; not implemented

#endif  /* defined(initSingleFromSignedWord_) */


#if defined(_CMOC_NEED_initSingleFromUnsignedWord_)

; Initializes the single-precision float at X with the unsigned word in D.
;
initSingleFromUnsignedWord
	pshs	u,y,x
	lbsr	loadUnsignedDInFPA0	; load D (unsigned) into FPA0
	puls	x
	jsr	$BC35			; pack FPA0 into X
	puls	y,u,pc			; not implemented

#endif  /* defined(_CMOC_NEED_initSingleFromUnsignedWord_) */


#if defined(_CMOC_NEED_initSingleFromDWord_)

; Initializes the single-precision float at X with the dword whose address is in D.
; The carry must be the signedness flag (0 for unsigned dword, non-zero for signed).
;
initSingleFromDWord
	pshs	u,y,x,cc
	clr	VALTYP			; variable type: numeric
	tfr	d,x			; X => dword
	ldd	2,x			; copy dword to mantissa
	std	FP0MAN+2
	ldd	,x
	std	FP0MAN
; A is now high byte of mantissa, as expected by $BC84
	ldb	#128+32			; exponent: 32
	stb	FP0EXP
	clr	FPSBYT
	clr	FP0SGN
	puls	cc			; test signedness flag
	bcc	@unsigned
	suba	#$80			; set carry if non-negative mantissa
	bra	@normalize
@unsigned
	orcc	#1			; consider mantissa non-negative
@normalize
	jsr	$BA18			; normalize FPA0 (reads carry)
	puls	x
	jsr	$BC35			; pack FPA0 into X
	puls	y,u,pc			; not implemented

#endif  /* defined(initSingleFromDWord_) */


#ifdef _CMOC_NEED_initSignedWordFromSingle_

; Based on Color Basic's routine at $B3ED.
; Input: D => address of source number. X => address of destination number.
;
initSignedWordFromSingle
	pshs	u,y,x		; save X that points to destination
	tfr	d,x		; point X to source real
	jsr	$BC14		; load FPA0 from X
;
	lda	FP0EXP
	cmpa	#$80+16		; is FPA0 >= 32768?
	bhs	@tooHigh
	ldx	#$B3DF		; packed -32768
	jsr	$BC96		; compare FPA0 to -32768
	blt	@tooLow
;
; Shift the mantissa right until the binary point is 16 bits from the left of the mantissa.
; We do not use Color Basic's $BCC8 routine because it is off by one on negative values, for C.
        lda     FP0EXP
        suba    #$80            ; real exponent in A (0..15); we want to increase it to 16
        bls     @zero
        cmpa    #8
        bhi     @byteShiftDone
; Shift 8 bits right.
        ldb     FP0MAN
        stb     FP0MAN+1
        clr     FP0MAN
        adda    #8
        bra     @shiftCond
@byteShiftDone
@shiftLoop
        lsr     FP0MAN
        ror     FP0MAN+1
        inca
@shiftCond
        cmpa    #16
        blo     @shiftLoop
; Absolute value of result is in FP0MAN. Apply the sign.
        tst     FP0SGN
        bpl     @nonNeg
        clra
        clrb
        subd    FP0MAN
        bra     @store
@nonNeg
        ldd     FP0MAN
	bra	@store
@zero
        clra
        clrb
	bra	@store
@tooHigh
        tst     FP0SGN
        bpl     @max
        ldd     #-32768
        bra     @store
@max
	ldd	#32767
	bra	@store
@tooLow
	ldd	#-32768
@store
	std	[,s]		; get dest address from stack, store word there
	puls	x,y,u,pc

#endif  /* _CMOC_NEED_initSignedWordFromSingle_ */


#ifdef _CMOC_NEED_initSignedByteFromSingle_

; Based on Color Basic's routine at $B3ED.
;
initSignedByteFromSingle
	pshs	u,y,x		; save X that points to destination
	tfr	d,x		; point X to source real
	jsr	$BC14		; load FPA0 from X
;
	lda	FP0EXP
	cmpa	#$80+8		; is FPA0 >= 128?
	bhs	@tooHigh
	leax	packedMinus128,pcr
	jsr	$BC96		; compare FPA0 to -128
	blt	@tooLow
;
; Shift the mantissa right until the binary point is 8 bits from the left of the mantissa.
; We do not use Color Basic's $BCC8 routine because it is off by one on negative values, for C.
        lda     FP0EXP
        suba    #$80            ; real exponent in A (0..7); we want to increase it to 16
        bls     @zero
        ldb     FP0MAN
@shiftLoop
        lsrb
        inca
        cmpa    #8
        blo     @shiftLoop
; Absolute value of result is in FP0MAN. Apply the sign.
        tst     FP0SGN
        bpl     @store
        negb
        bra     @store
@zero
        clrb
	bra	@store
@tooHigh
        tst     FP0SGN
        bpl     @max
        ldb     #-128
        bra     @store
@max
	ldb	#127
	bra	@store
@tooLow
	ldb	#-128
@store
	stb	[,s]		; get dest address from stack, store byte there
	puls	x,y,u,pc
packedMinus128
	fdb	$8880
	fdb	$0000
	fcb	$00

#endif  /* _CMOC_NEED_initSignedByteFromSingle_ */


#ifdef _CMOC_NEED_initUnsignedWordFromSingle_

; Based on Color Basic's routine at $B3ED.
;
initUnsignedWordFromSingle
	pshs	u,y,x		; save X that points to destination
	tfr	d,x		; point X to source real
	jsr	$BC14		; load FPA0 from X
;
	tst	FP0SGN		; check sign of FPA0
	bmi	@tooLow		; if < 0
	lda	FP0EXP
	beq	@tooLow		; FPA0 is 0.0, so result is 0
	cmpa	#$80+16		; is FPA0 >= 65536?
	bhi	@tooHigh	; if yes
; Denormalize FPA0 until exponent is 16.
	beq	@denormDone	; if exponent is 16, denorm done
	cmpa	#$80+8		; if exponent is in 9..15
	bhi	@shiftBits	; then go shift mantissa right by 1 to 7 bits
; Exponent is in 1..8. Shift mantissa right by 8 bits.
	ldb	FP0MAN		; load high byte of mantissa
	stb	FP0MAN+1	; shift it 8 bits right
	clr	FP0MAN		; clear high byte of mantissa
	adda	#8		; exponent is now 8 more than initially (now 9..16)
	cmpa	#$80+16
	beq	@denormDone
@shiftBits			; exponent is in 9..15
	ldx	#0
	tfr	a,b
	abx			; X = $80 + exponent
	ldd	FP0MAN		; load high 16 bits of mantissa
@shiftLoop
	lsra			; shift D right one bit
	rorb
	leax	1,x		; increment exponent
	cmpx	#$80+16
	blo	@shiftLoop	; loop if exponent not yet 16
	bra	@store		; go store D as result
@denormDone
	ldd	FP0MAN
	bra	@store
@tooHigh
	ldd	#65535
	bra	@store
@tooLow
	clra
	clrb
@store
	std	[,s]		; get dest address from stack, store word there
	puls	x,y,u,pc

#endif  /* _CMOC_NEED_initUnsignedWordFromSingle_ */


#ifdef _CMOC_NEED_initUnsignedByteFromSingle_

; Based on Color Basic's routine at $B3ED.
;
initUnsignedByteFromSingle
	pshs	u,y,x		; save X that points to destination
	tfr	d,x		; point X to source real
	jsr	$BC14		; load FPA0 from X
;
	tst	FP0SGN		; check sign of FPA0
	bmi	@tooLow		; if < 0
	lda	FP0EXP
	beq	@tooLow		; FPA0 is 0.0, so result is 0
	cmpa	#$80+8		; is FPA0 >= 256?
	bhi	@tooHigh	; if yes
; Denormalize FPA0 until exponent is 8.
	beq	@denormDone	; if exponent is 8, denorm done
@shiftBits			; exponent is in 9..15
	ldb	FP0MAN		; load high 8 bits of mantissa
@shiftLoop
	lsrb
	inca			; increment exponent
	cmpa	#$80+8
	blo	@shiftLoop	; loop if exponent not yet 8
	bra	@store		; go store D as result
@denormDone
	ldb	FP0MAN
	bra	@store
@tooHigh
	ldb	#255
	bra	@store
@tooLow
	clrb
@store
	stb	[,s]		; get dest address from stack, store byte there
	puls	x,y,u,pc

#endif  /* _CMOC_NEED_initUnsignedByteFromSingle_ */


#if defined(_CMOC_NEED_initDWordFromSingle_)

; Based on Color Basic's routine at $B3ED.
; Input: Carry = signedness flag: 0 if input long is unsigned, non-zero if signed.
; 	 D => address of source number. X => address of destination number.
;
initDWordFromSingle
	pshs	u,y,x,cc
	tfr	d,x		; point X to source real
	jsr	$BC14		; load FPA0 from X
;
	puls	cc			; get signedness flag in C
	bcc	@checkUnsignedRange	; if unsigned
;
	lda	FP0EXP
	cmpa	#$80+32		; is FPA0 >= 2^32?
	bhs	@tooHighSigned
	leax	packedMinus2To31,pcr
	jsr	$BC96		; compare FPA0 to -2^31
	blt	@tooLowSigned
	bra	@inRange
;
@checkUnsignedRange
	tst	FP0SGN
	bmi	@zero		; if FPA0 negative, return 0UL
	lda	FP0EXP
	cmpa	#$80+32		; is FPA0 > 2^32?
	bhi	@tooHighUnsigned
;
@inRange
;
; Shift the mantissa right until the binary point is 32 bits from the left of the mantissa.
; We do not use Color Basic's $BCC8 routine because it is off by one on negative values, for C.
        lda     FP0EXP
        suba    #$80            ; real exponent in A (0..32); we want to increase it to 32
        bls     @zero
	bra	@byteShiftCond
@byteShiftLoop
; Shift 8 bits right.
        ldx     FP0MAN+1
        stx     FP0MAN+2
        ldb     FP0MAN
        stb     FP0MAN+1
        clr     FP0MAN
        adda    #8
@byteShiftCond
        cmpa    #32
	beq	@shiftDone
        cmpa    #24
        bls     @byteShiftLoop
@shiftLoop			; shift one bit at a time under A is 32
        lsr     FP0MAN
        ror     FP0MAN+1
        ror     FP0MAN+2
        ror     FP0MAN+3
        inca
@shiftCond
        cmpa    #32
        blo     @shiftLoop
@shiftDone
; Absolute value of result is in FP0MAN. Apply the sign.
        tst     FP0SGN
        bpl     @store
        ldx	#FP0MAN
	lbsr	negateDWord
        bra     @store
@zero
        clr	FP0MAN
        clr	FP0MAN+1
        clr	FP0MAN+2
        clr	FP0MAN+3
	bra	@store
@tooHighUnsigned
	ldd	#$FFFF
	std	FP0MAN
	std	FP0MAN+2
	bra	@store
@tooHighSigned
        tst     FP0SGN
        bpl     @maxSigned
@tooLowSigned
        ldd     #$8000
	std	FP0MAN
        clr	FP0MAN+2
        clr	FP0MAN+3
        bra     @store
@maxSigned
	ldd	#$7FFF
	std	FP0MAN
	lda	#$FF
	std	FP0MAN+2
@store				; FP0MAN now contains final dword
	puls	x		; get dest address from stack
	ldd	FP0MAN
	std	,x
	ldd	FP0MAN+2
	std	2,x
	puls	y,u,pc
packedMinus2To31
	fcb	$a0		; 128 + exponent 32
	fdb	$8000
	fdb	$0000
#endif


#if defined(_CMOC_NEED_negateSingle_)

; Negates the packed single-precision float at X.
; Preserves X.
;
negateSingle
	ldb	1,x
	eorb	#$80
	stb	1,x
	rts

#endif  /* defined(_CMOC_NEED_negateSingle_) */


#if defined(_CMOC_NEED_isSingleZero_)

; Sets the Z flag to 1 if the packed single-precision float at X is zero.
; Sets the Z flag to 0 otherwise.
; Preserves X and D.
;
isSingleZero
	tst	,x		; null exponent byte means number is zero
	rts

#endif  /* defined(_CMOC_NEED_isSingleZero_) */


#if defined(_CMOC_NEED_incrementSingle_)

; Adds one 1 to the packed single-precision float at X.
; Preserves X.
;
incrementSingle
	pshs	u,y,x
	jsr	$BC14		; unpack into Basic's FPA0 (preserves X)
	leax	packed1,DAT
	jsr	$B9C2		; add number at X to FPA0 (trashes X)
	ldx	,s		; retrieve original number address
	jsr	$BC35		; pack FPA0 into X
	puls	x,y,u,pc
packed1
	fcb	$81		; packed 1.0
	fdb	0
	fdb	0

#endif  /* defined(_CMOC_NEED_incrementSingle_) */


#if defined(_CMOC_NEED_decrementSingle_)

; Subtracts one 1 from the packed single-precision float at X.
; Preserves X.
;
decrementSingle
	pshs	u,y,x
	jsr	$BC14		; unpack into Basic's FPA0 (preserves X)
	leax	packedMinus1,DAT
	jsr	$B9C2		; add number at X to FPA0 (trashes X)
	ldx	,s		; retrieve original number address
	jsr	$BC35		; pack FPA0 at X
	puls	x,y,u,pc
packedMinus1
	fcb	$81		; packed -1.0
	fdb	$8000
	fdb	0

#endif  /* defined(_CMOC_NEED_decrementSingle_) */


#if defined(_CMOC_NEED_copySingle_)

; Copies a packed single-precision number.
; Input: D = address of source number.
;        X = address of destination number.
; Preserves X. Trashes D.
;
copySingle
	pshs	u
	tfr     d,u	; address of source number
	ldd	,u
	std	,x
	ldd	2,u
	std	2,x
	ldb	4,u
	stb	4,x
	puls	u,pc

#endif  /* defined(_CMOC_NEED_copySingle_) */


#if defined(_CMOC_NEED_addSingleSingle_) || defined(_CMOC_NEED_subSingleSingle_) \
    || defined(_CMOC_NEED_mulSingleSingle_) || defined(_CMOC_NEED_divSingleSingle_)

; Does a binary operation on two numbers and writes the result at a third location.
; Synopsis:
;	pshs	rightOpAddr
;	pshs	leftOpAddr
;	leax	result,PCR
;	lbsr	addSingleSingle		; for example
;	leas	4,s
;   [...]
; addSingleSingle
;	pshs	u,y,x
;	ldu	#colorBasicRoutine	; routine uses FPA0 & FPA1, result in FPA0
;	bsr	binOpSingleSingle
;	puls	u,x,y,pc
; Preserves X.
;
binOpSingleSingle
	ldx	12,s		; rightOpAddr
	jsr	$BC14		; unpack from X to FPA0
	ldx	10,s		; leftOpAddr
	jsr	,u		; unpack from X to FPA1; FPA0 = op(FPA0, FPA1)
	ldx	2,s		; result address
	jmp	$BC35		; pack FPA0 into X

#endif  /* defined(_CMOC_NEED_addSingleSingle_) */


#ifdef _CMOC_NEED_addSingleSingle_

; Adds two numbers and writes the result at a third location.
; Synopsis:
;	pshs	rightOpAddr
;	pshs	leftOpAddr
;	leax	result,PCR
;	lbsr	addSingleSingle
;	leas	4,s
; Preserves X.
;
addSingleSingle
	pshs	u,y,x
	ldu	#$B9C2		; unpack from X to FPA1; FPA0 += FPA1
	lbsr	binOpSingleSingle
	puls	x,y,u,pc

#endif  /* defined(_CMOC_NEED_addSingleSingle_) */


#ifdef _CMOC_NEED_subSingleSingle_

; Subtracts two numbers and writes the result at a third location.
; Synopsis:
;	pshs	rightOpAddr
;	pshs	leftOpAddr
;	leax	result,PCR
;	lbsr	subSingleSingle
;	leas	4,s
; Preserves X.
;
subSingleSingle
	pshs	u,y,x
	ldu	#$B9B9		; unpack from X to FPA1; FPA0 = FPA1 - FPA0
	lbsr	binOpSingleSingle
	puls	x,y,u,pc

#endif  /* defined(_CMOC_NEED_subSingleSingle_) */


#ifdef _CMOC_NEED_addSingleInt_

addSingleInt
	pshs	u,y,x
	ldd	10,s		; right (signed int)
	jsr	$B4F4		; load D (signed) into FPA0
	ldx	8,s		; left (single)
	jsr	$BB2F		; unpack from X to FPA1
	lbra	addFPA0FPA1

#endif  /* _CMOC_NEED_addSingleInt_ */


#if    defined(_CMOC_NEED_addSingleInt_) \
    || defined(_CMOC_NEED_addIntSingle_) \
    || defined(_CMOC_NEED_addSingleUnsignedInt_) \
    || defined(_CMOC_NEED_addUnsignedIntSingle_) \
    || defined(_CMOC_NEED_addSingleUnsignedDWord_) \
    || defined(_CMOC_NEED_addUnsignedDWordSingle_) \
    || defined(_CMOC_NEED_addSingleSignedDWord_) \
    || defined(_CMOC_NEED_addSignedDWordSingle_)

* Input: FPA1 = number to add to FPA0.
*        Pushed argument = address of resulting packed float.
* Output: Sum (packed single) stored at X.
* Trashes FPA0.
* Preserves X.
*
addFPA0FPA1
	lda     FP1EXP		; load exponent of FPA1
	ldb     FP0EXP		; load exponent of FPA0
	jsr     $B9C5		; FPA0 += FPA1

	ldx	,s		; result
	jsr	$BC35		; pack FPA0 into X
	puls	x,y,u,pc

#endif


#if    defined(_CMOC_NEED_addSingleUnsignedInt_) \
    || defined(_CMOC_NEED_addUnsignedIntSingle_) \
    || defined(_CMOC_NEED_mulSingleUnsignedInt_) \
    || defined(_CMOC_NEED_mulUnsignedIntSingle_) \
    || defined(_CMOC_NEED_initSingleFromUnsignedWord_) \
    || defined(_CMOC_NEED_subSingleUnsignedInt_) \
    || defined(_CMOC_NEED_subUnsignedIntSingle_) \
    || defined(_CMOC_NEED_divSingleUnsignedInt_) \
    || defined(_CMOC_NEED_divUnsignedIntSingle_)

loadUnsignedDInFPA0
	clr	VALTYP		; set variable type (VALTYP) to numeric
	std	FP0MAN		; store in upper mantissa of FPA0
	ldb	#128+16 	; 16 = exponent required
	orcc	#1		; set carry so value seen as non-negative (see $BA18)
	jmp	$BC86		; continue with rest of routine started at $B4F4

#endif


#if    defined(_CMOC_NEED_addSingleUnsignedDWord_) \
    || defined(_CMOC_NEED_addUnsignedDWordSingle_) \
    || defined(_CMOC_NEED_subSingleUnsignedDWord_) \
    || defined(_CMOC_NEED_subUnsignedDWordSingle_) \
    || defined(_CMOC_NEED_mulUnsignedDWordSingle_) \
    || defined(_CMOC_NEED_mulSingleUnsignedDWord_) \
    || defined(_CMOC_NEED_divSingleUnsignedDWord_)

; Input: X => unsigned dword.
;
loadUnsignedDWordInFPA0
	clr	VALTYP		; set value type to numeric
	ldd	,x
	std	FP0MAN		; store in upper mantissa of FPA0
	ldd	2,x
	std	FP0MAN+2	; store in upper mantissa of FPA0
	ldb	#128+32 	; 32 = exponent required
	stb	FP0EXP
	clr	FPSBYT
	clr	FP0SGN
	orcc	#1		; set carry so value seen as non-negative (see $BA18)
	jmp	$BA18		; normalize FPA0 (reads carry)

#endif

#if    defined(_CMOC_NEED_addSingleSignedDWord_) \
    || defined(_CMOC_NEED_addSignedDWordSingle_) \
    || defined(_CMOC_NEED_subSingleSignedDWord_) \
    || defined(_CMOC_NEED_subSignedDWordSingle_) \
    || defined(_CMOC_NEED_mulSingleSignedDWord_) \
    || defined(_CMOC_NEED_mulSignedDWordSingle_) \
    || defined(_CMOC_NEED_divSingleSignedDWord_)

; Input: X => unsigned dword.
;
loadSignedDWordInFPA0
	clr	VALTYP		; set value type to numeric
	ldd	,x
	std	FP0MAN		; store in upper mantissa of FPA0
	ldd	2,x
	std	FP0MAN+2	; store in upper mantissa of FPA0
	ldb	#128+32 	; 32 = exponent required
	stb	FP0EXP
	clr	FPSBYT
	clr	FP0SGN
	ldb	FP0MAN
	subb	#$80		; set carry if value is non-negative (see $BA18)
	jmp	$BA18		; normalize FPA0 (reads carry)

#endif


#ifdef _CMOC_NEED_addIntSingle_

addIntSingle
	pshs	u,y,x
	ldd	8,s		; right (signed int)
	jsr	$B4F4		; load D (signed) into FPA0
	ldx	10,s		; left (single)
	jsr	$BB2F		; unpack from X to FPA1
	lbra	addFPA0FPA1

#endif  /* _CMOC_NEED_addIntSingle_ */


#ifdef _CMOC_NEED_addSingleUnsignedInt_

addSingleUnsignedInt
	pshs	u,y,x
	ldd	10,s		; right (unsigned int)
	lbsr	loadUnsignedDInFPA0
	ldx	8,s		; left (single)
	jsr	$BB2F		; unpack from X to FPA1
	lbra	addFPA0FPA1

#endif  /* _CMOC_NEED_addSingleUnsignedInt_ */


#ifdef _CMOC_NEED_addUnsignedIntSingle_

addUnsignedIntSingle
	pshs	u,y,x
	ldd	8,s		; left (unsigned int)
	lbsr	loadUnsignedDInFPA0
	ldx	10,s		; right (single)
	jsr	$BB2F		; unpack from X to FPA1
	lbra	addFPA0FPA1

#endif  /* _CMOC_NEED_addUnsignedIntSingle_ */


#ifdef _CMOC_NEED_addSingleUnsignedDWord_

addSingleUnsignedDWord
	pshs	u,y,x
	ldx	10,s		; right (unsigned dword)
	lbsr	loadUnsignedDWordInFPA0
	ldx	8,s		; left (single)
	jsr	$BB2F		; unpack from X to FPA1
	lbra	addFPA0FPA1

#endif  /* _CMOC_NEED_addSingleUnsignedDWord_ */


#ifdef _CMOC_NEED_addUnsignedDWordSingle_

addUnsignedDWordSingle
	pshs	u,y,x
	ldx	8,s		; left (unsigned dword)
	lbsr	loadUnsignedDWordInFPA0
	ldx	10,s		; right (single)
	jsr	$BB2F		; unpack from X to FPA1
	lbra	addFPA0FPA1

#endif  /* _CMOC_NEED_addUnsignedDWordSingle_ */


#ifdef _CMOC_NEED_addSingleSignedDWord_

addSingleSignedDWord
	pshs	u,y,x
	ldx	10,s		; right (unsigned dword)
	lbsr	loadSignedDWordInFPA0
	ldx	8,s		; left (single)
	jsr	$BB2F		; unpack from X to FPA1
	lbra	addFPA0FPA1

#endif  /* _CMOC_NEED_addSingleSignedDWord_ */


#ifdef _CMOC_NEED_addSignedDWordSingle_

addSignedDWordSingle
	pshs	u,y,x
	ldx	8,s		; left (unsigned dword)
	lbsr	loadSignedDWordInFPA0
	ldx	10,s		; right (single)
	jsr	$BB2F		; unpack from X to FPA1
	lbra	addFPA0FPA1

#endif  /* _CMOC_NEED_addSignedDWordSingle_ */


#ifdef _CMOC_NEED_subSingleInt_

subSingleInt
	pshs	u,y,x

	clra
	clrb
	subd	10,s		; load right operand, negated
	jsr	$B4F4		; load D (signed) into FPA0

	; The left operand must be loaded second because $B4F4
	; appears to trash FPA1.

	ldx	8,s		; left (single)
	jsr	$BB2F		; unpack from X to FPA1

	lbra	subSingle_common_add

#endif  /* _CMOC_NEED_subSingleInt_ */


#ifdef _CMOC_NEED_subSingleUnsignedInt_

subSingleUnsignedInt
	pshs	u,y,x

	ldd	10,s		; load right operand
	lbsr	loadUnsignedDInFPA0
	com	FP0SGN		; negate FPA0

	; The left operand is loaded second in case the
	; preceding call trashes FPA1.

	ldx	8,s		; left (single)
	jsr	$BB2F		; unpack from X to FPA1

	lbra	subSingle_common_add

#endif  /* _CMOC_NEED_subSingleUnsignedInt_ */


#ifdef _CMOC_NEED_subSingleUnsignedDWord_

subSingleUnsignedDWord
	pshs	u,y,x

	ldx	10,s		; load right operand
	lbsr	loadUnsignedDWordInFPA0
	com	FP0SGN		; negate FPA0

	; The left operand is loaded second in case the
	; preceding call trashes FPA1.

	ldx	8,s		; left (single)
	jsr	$BB2F		; unpack from X to FPA1

	lbra	subSingle_common_add

#endif  /* _CMOC_NEED_subSingleUnsignedDWord_ */


#ifdef _CMOC_NEED_subSingleSignedDWord_

subSingleSignedDWord
	pshs	u,y,x

	ldx	10,s		; load right operand
	lbsr	loadSignedDWordInFPA0
	com	FP0SGN		; negate FPA0

	; The left operand is loaded second in case the
	; preceding call trashes FPA1.

	ldx	8,s		; left (single)
	jsr	$BB2F		; unpack from X to FPA1

	lbra	subSingle_common_add

#endif  /* _CMOC_NEED_subSingleSignedDWord_ */


#if defined(_CMOC_NEED_subSingleInt_) \
    || defined(_CMOC_NEED_subSingleUnsignedInt_) \
    || defined(_CMOC_NEED_subIntSingle_) \
    || defined(_CMOC_NEED_subUnsignedIntSingle_) \
    || defined(_CMOC_NEED_subSingleUnsignedDWord_) \
    || defined(_CMOC_NEED_subUnsignedDWordSingle_)

; Input: FPA0 = left operand;
;        10,S (before call) => right operand (single-precision).
; Output: ,S (before call) => address where to pack the result.
; Preserves X, Y, U. Trashes D.
;
subSingle_common
	ldx	10,s		; right (single)
	jsr	$BB2F		; unpack from X to FPA1
	com	FP1SGN		; invert sign of FPA1

        ; Compute sign of result.
        ldb     FP0SGN
        eorb    FP1SGN
        stb     RESSGN

subSingle_common_add
	lda     FP1EXP		; load exponent of FPA1
	ldb     FP0EXP		; load exponent of FPA0
	jsr     $B9C5		; FPA0 += FPA1

	ldx	,s		; result
	jsr	$BC35		; pack FPA0 into X
	puls	x,y,u,pc

#endif


#ifdef _CMOC_NEED_subIntSingle_

subIntSingle
	pshs	u,y,x
	ldd	8,s		; load left operand
	jsr	$B4F4		; load D (signed) into FPA0
	lbra	subSingle_common

#endif  /* _CMOC_NEED_subIntSingle_ */


#ifdef _CMOC_NEED_subUnsignedIntSingle_

subUnsignedIntSingle
	pshs	u,y,x
	ldd	8,s		; load left operand
	lbsr	loadUnsignedDInFPA0
	lbra	subSingle_common

#endif  /* _CMOC_NEED_subUnsignedIntSingle_ */


#ifdef _CMOC_NEED_subUnsignedDWordSingle_

subUnsignedDWordSingle
	pshs	u,y,x
	ldx	8,s		; load left operand
	lbsr	loadUnsignedDWordInFPA0
	lbra	subSingle_common

#endif  /* _CMOC_NEED_subUnsignedDWordSingle_ */


#ifdef _CMOC_NEED_subSignedDWordSingle_

subSignedDWordSingle
	pshs	u,y,x
	ldx	8,s		; load left operand
	lbsr	loadSignedDWordInFPA0
	lbra	subSingle_common

#endif  /* _CMOC_NEED_subSignedDWordSingle_ */


#ifdef _CMOC_NEED_mulSingleSingle_

; Multiplies two numbers and writes the result at a third location.
; Synopsis:
;	pshs	rightOpAddr
;	pshs	leftOpAddr
;	leax	result,PCR
;	lbsr	mulSingleSingle
;	leas	4,s
; Preserves X.
;
mulSingleSingle
	pshs	u,y,x
	leau	unpackXToFPA1AndMul,pcr
	lbsr	binOpSingleSingle
	puls	x,y,u,pc

#endif  /* defined(_CMOC_NEED_mulSingleSingle_) */


#if    defined(_CMOC_NEED_mulSingleSingle_) \
    || defined(_CMOC_NEED_mulSingleUnsignedInt_) \
    || defined(_CMOC_NEED_mulUnsignedIntSingle_) \
    || defined(_CMOC_NEED_mulSingleInt_) \
    || defined(_CMOC_NEED_mulIntSingle_) \
    || defined(_CMOC_NEED_divSingleSingle_) \
    || defined(_CMOC_NEED_divSingleUnsignedInt_) \
    || defined(_CMOC_NEED_divUnsignedIntSingle_) \
    || defined(_CMOC_NEED_divSingleInt_) \
    || defined(_CMOC_NEED_divIntSingle_) \
    || defined(_CMOC_NEED_divSingleUnsignedDWord_) \
    || defined(_CMOC_NEED_divUnsignedDWordSingle_) \
    || defined(_CMOC_NEED_divSingleSignedDWord_) \
    || defined(_CMOC_NEED_divSignedDWordSingle_)

unpackXtoFPA0AndPrep
	jsr	$BC14		; unpack from X to FPA0
	bra	prepBinFloatOp

unpackXtoFPA1AndPrep
	jsr	$BB2F		; unpack from X to FPA1

prepBinFloatOp
        ; Compute sign of result, as in $BB2F.
        ldb     FP0SGN
        eorb    FP1SGN
        stb     RESSGN

        lda     FP1EXP
        ldb     FP0EXP          ; as in $BB2F; sets N and Z
	rts

#endif


#if    defined(_CMOC_NEED_mulSingleSingle_) \
    || defined(_CMOC_NEED_mulSingleUnsignedInt_) \
    || defined(_CMOC_NEED_mulUnsignedIntSingle_) \
    || defined(_CMOC_NEED_mulSingleInt_) \
    || defined(_CMOC_NEED_mulIntSingle_) \
    || defined(_CMOC_NEED_mulSingleUnsignedDWord_) \
    || defined(_CMOC_NEED_mulSingleSignedDWord_) \
    || defined(_CMOC_NEED_mulUnsignedDWordSingle_) \
    || defined(_CMOC_NEED_mulSignedDWordSingle_)

; To be called by binOpSingleSingle.
; Input: X => packed single to be unpacked to FPA1.
;        FPA0 => factor of the multiplication to be done.
; Output: FPA0 = FPA0 * single at X.
;
unpackXToFPA1AndMul
	lbsr	unpackXtoFPA1AndPrep
        jmp     $BACC           ; starts with BEQ instruction

#endif


#if    defined(_CMOC_NEED_divSingleSingle_) \
    || defined(_CMOC_NEED_divSingleUnsignedInt_) \
    || defined(_CMOC_NEED_divUnsignedIntSingle_) \
    || defined(_CMOC_NEED_divSingleInt_) \
    || defined(_CMOC_NEED_divIntSingle_) \
    || defined(_CMOC_NEED_divSingleUnsignedDWord_) \
    || defined(_CMOC_NEED_divUnsignedDWordSingle_) \
    || defined(_CMOC_NEED_divSingleSignedDWord_) \
    || defined(_CMOC_NEED_divSignedDWordSingle_)

; To be called by binOpSingleSingle.
; Input: X => packed single to be unpacked to FPA1.
;        FPA0 => factor of the division to be done.
; Output: FPA0 = FPA0 / single at X.
;
unpackXToFPA0AndDiv
	lbsr	unpackXtoFPA0AndPrep
        jmp     $BB91           ; starts with BEQ instruction

unpackXToFPA1AndDiv
	lbsr	unpackXtoFPA1AndPrep
        jmp     $BB91           ; starts with BEQ instruction

#endif


#ifdef _CMOC_NEED_mulSingleUnsignedInt_

mulSingleUnsignedInt
	pshs	u,y,x
	ldd	10,s		; right (unsigned int)
	lbsr	loadUnsignedDInFPA0
	ldx	8,s		; left (single)
	lbsr	unpackXToFPA1AndMul
	ldx	,s		; result address
	jsr	$BC35		; pack FPA0 into X
	puls	x,y,u,pc

#endif  /* defined(_CMOC_NEED_mulSingleUnsignedInt_) */


#ifdef _CMOC_NEED_mulSingleUnsignedDWord_

mulSingleUnsignedDWord
	pshs	u,y,x
	ldx	10,s		; right (unsigned dword)
	lbsr	loadUnsignedDWordInFPA0
	ldx	8,s		; left (single)
	lbsr	unpackXToFPA1AndMul
	ldx	,s		; result address
	jsr	$BC35		; pack FPA0 into X
	puls	x,y,u,pc

#endif  /* defined(_CMOC_NEED_mulSingleUnsignedDWord_) */


#ifdef _CMOC_NEED_mulSingleSignedDWord_

mulSingleSignedDWord
	pshs	u,y,x
	ldx	10,s		; right (unsigned dword)
	lbsr	loadSignedDWordInFPA0
	ldx	8,s		; left (single)
	lbsr	unpackXToFPA1AndMul
	ldx	,s		; result address
	jsr	$BC35		; pack FPA0 into X
	puls	x,y,u,pc

#endif  /* defined(_CMOC_NEED_mulSingleSignedDWord_) */


#ifdef _CMOC_NEED_mulUnsignedIntSingle_

mulUnsignedIntSingle
	pshs	u,y,x
	ldd	8,s		; left (unsigned int)
	lbsr	loadUnsignedDInFPA0
	ldx	10,s		; right (single)
	lbsr	unpackXToFPA1AndMul
	ldx	,s		; result address
	jsr	$BC35		; pack FPA0 into X
	puls	x,y,u,pc

#endif  /* defined(_CMOC_NEED_mulUnsignedIntSingle_) */


#ifdef _CMOC_NEED_mulUnsignedDWordSingle_

mulUnsignedDWordSingle
	pshs	u,y,x
	ldx	8,s		; left (unsigned dword)
	lbsr	loadUnsignedDWordInFPA0
	ldx	10,s		; right (single)
	lbsr	unpackXToFPA1AndMul
	ldx	,s		; result address
	jsr	$BC35		; pack FPA0 into X
	puls	x,y,u,pc

#endif  /* defined(_CMOC_NEED_mulUnsignedIntSingle_) */


#ifdef _CMOC_NEED_mulSignedDWordSingle_

mulSignedDWordSingle
	pshs	u,y,x
	ldx	8,s		; left (unsigned dword)
	lbsr	loadSignedDWordInFPA0
	ldx	10,s		; right (single)
	lbsr	unpackXToFPA1AndMul
	ldx	,s		; result address
	jsr	$BC35		; pack FPA0 into X
	puls	x,y,u,pc

#endif  /* defined(_CMOC_NEED_mulSignedIntSingle_) */


#ifdef _CMOC_NEED_mulSingleInt_

mulSingleInt
	pshs	u,y,x
	ldd	10,s		; right (unsigned int)
	jsr	$B4F4		; load D (signed) into FPA0
	ldx	8,s		; left (single)
	lbsr	unpackXToFPA1AndMul
	ldx	,s		; result address
	jsr	$BC35		; pack FPA0 into X
	puls	x,y,u,pc

#endif  /* defined(_CMOC_NEED_mulSingleInt_) */


#ifdef _CMOC_NEED_mulIntSingle_

mulIntSingle
	pshs	u,y,x
	ldd	8,s		; right (unsigned int)
	jsr	$B4F4		; load D (signed) into FPA0
	ldx	10,s		; left (single)
	lbsr	unpackXToFPA1AndMul
	ldx	,s		; result address
	jsr	$BC35		; pack FPA0 into X
	puls	x,y,u,pc

#endif  /* defined(_CMOC_NEED_mulIntSingle_) */


#ifdef _CMOC_NEED_divSingleSingle_

; Divides two numbers and writes the result at a third location.
; Synopsis:
;	pshs	rightOpAddr
;	pshs	leftOpAddr
;	leax	result,PCR
;	lbsr	divSingleSingle
;	leas	4,s
; Preserves X.
;
divSingleSingle
	tst	[4,s]		; check exponent of right operand (divisor)
	lbeq	divByZeroSingle
	pshs	u,y,x
	ldu	#$BB8F		; unpack from X to FPA1; FP0 = FPA1 / FPA0
	lbsr	binOpSingleSingle
	puls	x,y,u,pc

#endif  /* defined(_CMOC_NEED_divSingleSingle_) */


#ifdef _CMOC_NEED_divSingleUnsignedInt_

divSingleUnsignedInt
	ldd	4,s		; check right operand (divisor)
	lbeq	divByZeroSingle
	pshs	u,y,x
	ldd	10,s		; right (unsigned int)
	lbsr	loadUnsignedDInFPA0
	ldx	8,s		; left (single)
	lbsr	unpackXToFPA1AndDiv
	ldx	,s		; result address
	jsr	$BC35		; pack FPA0 into X
	puls	x,y,u,pc

#endif  /* defined(_CMOC_NEED_divSingleUnsignedInt_) */


#ifdef _CMOC_NEED_divSingleUnsignedDWord_

divSingleUnsignedDWord
	lbsr	isDWordZeroSpecial	; check right operand (divisor)
	lbeq	divByZeroSingle
@noDivBy0
	pshs	u,y,x
	ldx	10,s		; right (unsigned dword)
	lbsr	loadUnsignedDWordInFPA0
	ldx	8,s		; left (single)
	lbsr	unpackXToFPA1AndDiv
	ldx	,s		; result address
	jsr	$BC35		; pack FPA0 into X
	puls	x,y,u,pc

#endif  /* defined(_CMOC_NEED_divSingleUnsignedDWord_) */


#ifdef _CMOC_NEED_divSingleSignedDWord_

divSingleSignedDWord
	lbsr	isDWordZeroSpecial	; check right operand (divisor)
	lbeq	divByZeroSingle
@noDivBy0
	pshs	u,y,x
	ldx	10,s		; right (signed dword)
	lbsr	loadSignedDWordInFPA0
	ldx	8,s		; left (single)
	lbsr	unpackXToFPA1AndDiv
	ldx	,s		; result address
	jsr	$BC35		; pack FPA0 into X
	puls	x,y,u,pc

#endif  /* defined(_CMOC_NEED_divSingleSignedDWord_) */


#if    defined(_CMOC_NEED_divSingleSingle_) \
    || defined(_CMOC_NEED_divSingleUnsignedInt_) \
    || defined(_CMOC_NEED_divUnsignedIntSingle_) \
    || defined(_CMOC_NEED_divSingleInt_) \
    || defined(_CMOC_NEED_divIntSingle_) \
    || defined(_CMOC_NEED_divSingleUnsignedDWord_) \
    || defined(_CMOC_NEED_divUnsignedDWordSingle_) \
    || defined(_CMOC_NEED_divSingleSignedDWord_) \
    || defined(_CMOC_NEED_divSignedDWordSingle_)

; Input: X => Result of division (packed single).
;
divByZeroSingle
	clr	,x		; store 0.0f in result
	rts
#endif


#if    defined(_CMOC_NEED_divSingleUnsignedDWord_) \
    || defined(_CMOC_NEED_divSingleSignedDWord_)

; Input: 4,S (before call) => dword.
; Output: Z is set iff divisor is zero.
; Preserves X. Trashes D.
;
isDWordZeroSpecial
	pshs	x
	ldx	8,s	; address of dword to check
	ldd	,x
	bne	@done
	ldd	2,x
@done
	puls	x,pc

#endif


#ifdef _CMOC_NEED_divUnsignedIntSingle_

divUnsignedIntSingle
	tst	[4,s]		; check exponent of right operand (divisor)
	lbeq	divByZeroSingle
	pshs	u,y,x
	ldd	8,s		; left (unsigned int)
	lbsr	loadUnsignedDInFPA1
	ldx	10,s		; right (single)
	lbsr	unpackXToFPA0AndDiv
	ldx	,s		; result address
	jsr	$BC35		; pack FPA0 into X
	puls	x,y,u,pc

* Trashes FPA0.
loadUnsignedDInFPA1
	lbsr	loadUnsignedDInFPA0
	ldd	FP0ADDR
	std	FP1ADDR
	ldd	FP0ADDR+2
	std	FP1ADDR+2
	ldd	FP0ADDR+4
	std	FP1ADDR+4
	rts

#endif  /* defined(_CMOC_NEED_divUnsignedIntSingle_) */


#ifdef _CMOC_NEED_divUnsignedDWordSingle_

divUnsignedDWordSingle
	tst	[4,s]		; check exponent of right operand (divisor)
	lbeq	divByZeroSingle
	pshs	u,y,x
	ldx	8,s		; left (unsigned dword)
	lbsr	loadUnsignedDWordInFPA1
	ldx	10,s		; right (single)
	lbsr	unpackXToFPA0AndDiv
	ldx	,s		; result address
	jsr	$BC35		; pack FPA0 into X
	puls	x,y,u,pc

* Trashes FPA0.
loadUnsignedDWordInFPA1
	lbsr	loadUnsignedDWordInFPA0
	ldd	FP0ADDR
	std	FP1ADDR
	ldd	FP0ADDR+2
	std	FP1ADDR+2
	ldd	FP0ADDR+4
	std	FP1ADDR+4
	rts

#endif  /* defined(_CMOC_NEED_divUnsignedDWordSingle_) */


#ifdef _CMOC_NEED_divSignedDWordSingle_

divSignedDWordSingle
	tst	[4,s]		; check exponent of right operand (divisor)
	lbeq	divByZeroSingle
	pshs	u,y,x
	ldx	8,s		; left (signed dword)
	lbsr	loadSignedDWordInFPA1
	ldx	10,s		; right (single)
	lbsr	unpackXToFPA0AndDiv
	ldx	,s		; result address
	jsr	$BC35		; pack FPA0 into X
	puls	x,y,u,pc

* Trashes FPA0.
loadSignedDWordInFPA1
	lbsr	loadSignedDWordInFPA0
	ldd	FP0ADDR
	std	FP1ADDR
	ldd	FP0ADDR+2
	std	FP1ADDR+2
	ldd	FP0ADDR+4
	std	FP1ADDR+4
	rts

#endif  /* defined(_CMOC_NEED_divSignedDWordSingle_) */


#ifdef _CMOC_NEED_divSingleInt_

divSingleInt
	ldd	4,s		; check right operand (divisor)
	lbeq	divByZeroSingle
	pshs	u,y,x
	ldd	10,s		; right (unsigned int)
	jsr	$B4F4		; load D (signed) into FPA0
	ldx	8,s		; left (single)
	lbsr	unpackXToFPA1AndDiv
	ldx	,s		; result address
	jsr	$BC35		; pack FPA0 into X
	puls	x,y,u,pc

#endif  /* defined(_CMOC_NEED_divSingleInt_) */


#ifdef _CMOC_NEED_divIntSingle_

divIntSingle
	tst	[4,s]		; check exponent of right operand (divisor)
	lbeq	divByZeroSingle
	pshs	u,y,x
	ldd	8,s		; left (signed int)
	lbsr	loadSignedDInFPA1
	ldx	10,s		; left (single)
	lbsr	unpackXToFPA0AndDiv
	ldx	,s		; result address
	jsr	$BC35		; pack FPA0 into X
	puls	x,y,u,pc

* Trashes FPA0.
loadSignedDInFPA1
	jsr	$B4F4		; load D (signed) into FPA0
	ldd	FP0ADDR
	std	FP1ADDR
	ldd	FP0ADDR+2
	std	FP1ADDR+2
	ldd	FP0ADDR+4
	std	FP1ADDR+4
	rts

#endif  /* defined(_CMOC_NEED_divIntSingle_) */


#if defined(_CMOC_NEED_cmpSingleSingle_)

* Input: Stacked arguments: address of left packed single, address of right.
* Output: B = -1, 0 or +1. CC reflects signed comparison of B with 0.
* Preserves X.
*
cmpSingleSingle
	pshs	u,y,x

	ldx	8,s		; point to left operand (single)
	jsr	$BC14		; unpack from X to FPA0

	ldx	10,s		; point to right operand (single)
	jsr	$BC96		; compare FPA0 to X: puts -1, 0 or +1 in B, sets CC

	puls	x,y,u,pc

#endif  /* _CMOC_NEED_cmpSingleSingle_ */


#if defined(_CMOC_NEED_cmpSingleSignedInt_)

* Input: Stacked arguments: address of left packed single, right signed int.
* Output: B = -1, 0 or +1. CC reflects signed comparison of B with 0.
* Preserves X.
*
cmpSingleSignedInt
	pshs	u,y,x

	ldd	10,s		; right operand (signed int)
	jsr	$B4F4		; load D (signed) into FPA0

	ldx	8,s		; point to left operand (single)
	jsr	$BC96		; compare FPA0 to X: puts -1, 0 or +1 in B, sets CC

	negb			; invert result because comparison was inverted
	cmpb	#0		; signed comparison, so no TSTB
	puls	x,y,u,pc

#endif  /* _CMOC_NEED_cmpSingleSignedInt_ */


#if defined(_CMOC_NEED_cmpSignedIntSingle_)

cmpSignedIntSingle
	pshs	u,y,x

	ldd	8,s		; left operand (signed int)
	jsr	$B4F4		; load D (signed) into FPA0

	ldx	10,s		; point to right operand (single)
	jsr	$BC96		; compare FPA0 to X: puts -1, 0 or +1 in B, sets CC

	puls	x,y,u,pc

#endif  /* _CMOC_NEED_cmpSignedIntSingle_ */


#if defined(_CMOC_NEED_cmpSingleUnsignedInt_)

cmpSingleUnsignedInt
	pshs	u,y,x

	ldd	10,s		        ; right operand (unsigned int)
	lbsr	loadUnsignedDInFPA0	; load D (unsigned) into FPA0

	ldx	8,s		; point to left operand (single)
	jsr	$BC96		; compare FPA0 to X: puts -1, 0 or +1 in B, sets CC

	negb			; invert result because comparison was inverted
	cmpb	#0		; signed comparison, so no TSTB
	puls	x,y,u,pc

#endif  /* _CMOC_NEED_cmpSingleUnsignedInt_ */


#if defined(_CMOC_NEED_cmpUnsignedIntSingle_)

cmpUnsignedIntSingle
	pshs	u,y,x

	ldd	8,s		        ; left operand (unsigned int)
	lbsr	loadUnsignedDInFPA0	; load D (unsigned) into FPA0

	ldx	10,s		; point to right operand (single)
	jsr	$BC96		; compare FPA0 to X: puts -1, 0 or +1 in B, sets CC

	puls	x,y,u,pc

#endif  /* _CMOC_NEED_cmpUnsignedIntSingle_ */

#if defined(_CMOC_NEED_strtof_)

; float strtof(char *nptr, char **endptr);
;
; The string must have at most 255 characters (before the null terminator).
; Caution: Passing a excessive value will make Basic fail with an OV ERROR.
;
_strtof

	pshs	u,y

	ldd	CHARAD		; save interpreter's input pointer
	pshs	b,a
	ldx	10,s		; nptr: string to parse
	stx	CHARAD		; point interpreter to caller's string

	jsr	GETCCH		; get current char
	jsr	$BD12		; result in FPA0; trashes FPA1

	ldx	8,s		; address of returned float (hidden parameter)
	jsr	$BC35		; pack FPA0 into X

	ldd	CHARAD		; get address in nptr where parsing stopped
	std	[12,s]		; store at *endptr

	puls	a,b
	std	CHARAD		; restore interpreter's input pointer

	puls	y,u,pc

#endif  /* _CMOC_NEED_strtof_ */


#if defined(_CMOC_NEED_ftoa_)

; char *ftoa(char out[38], float f);
;
; Writes 'f' in ASCII decimal to 'out'.
; Does not precede the string with a space if 'f' is positive or zero.
;
_ftoa
	pshs	u,y		; protect against Basic

	leax	8,s		; f: number to convert to string
	jsr	$BC14		; load FPA0 from X

	ldu	6,s		; out: where to write string

	ldb	FP0SGN		; get sign of 'f'
	bpl	@positive
	lda	#'-'
	sta	,u+		; output minus sign
	bra	@signDone
@positive
	lda	#' '
@signDone
	jsr	$BDE6		; let Basic do rest of conversion

	ldd	6,s		; success: return 'out'
	puls	y,u,pc

#endif  /* _CMOC_NEED_ftoa_ */
