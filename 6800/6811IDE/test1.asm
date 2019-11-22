	.org 16
	adda #5
	adda #5 
	suba #10
	suba #5
	bra  st ; pc += 10
b	.byte 1,2,3,4,5
	.str "start"
st	adda #5 
	adda b
	suba #30
	suba #5
	tpa ; acc <= flags
;========================
; TEST STATUS BITS 
;========================
	nop
	clra
	tap ; flags <= acc
	inx
	dex
	sev ;set   overflow bit(1)
	clv ;clear overflow bit(1)
	sec ;set   carry bit(0)
	clc ;clear carry bit(0)
	sei ;set   interrupt bit(4)
	cli ;clear interrupt bit(4)
	tpa ; acc <= flags
;========================
; TEST ACCUMULATOR OPS
;======================== 
	adda #5
	addb #3
	sba 	;A <= A - B
	aba 	;A <= A + B
	addb #$C6
	cba 	;compare accumulators
	suba #$C0
	tab 	;B <= A
	addb #32
	tba 	;A <= A
;	daa ; add BCD
;========================
; TEST STACK INSTRUCTIONS
;======================== 
	ins ;SP <= SP + 1
	tsx ;X <= SP + 1
	des ;SP <= SP - 1
	ins ;SP <= SP + 1
	txs ;SP <= X - 1
	adda #5
	psha ;M[SP--] <= A
	pshb ;M[SP--] <= B
	clra
	clrb
	pula ;A <= M[SP++]
	pulb ;B <= M[SP++]
	clra
	clrb
	adda #$7e
	psha ;M[SP--] <= A
	pshb ;M[SP--] <= A
;	rts ;return from function	- pull PC
;	rti ;return from interupt	- pull interrupt stack frame
;	wai ;push interrupt stack frame, wait
;	swi ;push interrupt stack frame, vector
;========================
; branch instructions
;======================== 
	bra 2 ;Branch always 
	.rmb 2
	clc		;clear carry
	bhi 2	;Branch if higher (unsigned)	C or Z == 0
	.rmb 2
	clra	;clear acc
	bls 2	;Branch if lower (unsigned)	C or Z == 1
	.rmb 2
	bcc 2	;Branch if carry clear		C == 0
	.rmb 2
	sec	;set carry
	bcs 2	 ;Branch if carry set		C == 1
	.rmb 2
	adda #1
	bne 2	;Branch if not equal		Z == 0
	.rmb 2
	clra	;clear acc
	beq 2	;Branch if equal		Z == 1
	.rmb 2
	bvc 2	;Branch if overflow clear	V == 0
	.rmb 2
	sev 	;set   overflow bit(1)
	bvs 2	;Branch if overflow set		V == 1
	.rmb 2
	bpl 2	 ;Branch if plus N == 0
	.rmb 2
	suba #1
	bmi 2	;Branch if minus N == 1
	.rmb 2
	blt 2	 ;Branch if <	N xor V == 1
	.rmb 2
	sev		;set overflow
	bge 2	 ;Branch if >=	N xor V == 0
	.rmb 2
	bgt 2	 ;Branch if >	Z or (N xor V) == 0
	.rmb 2
	clra
	ble 2	 ;Branch if <=	Z or (N xor V) == 1
c	.word 0
	nop
;========================
; logical instructions
;========================
	deca ;// increment accum		A <= A + 1
	tsta ;// test accumuator		     A - 0
	nega ;// negate A		A <= 0 - A
	clra ;// clear accumulator	A <= 0
	tsta ;// test accumuator	A - 0
	inca ;// decrement accum	A <= A - 1
	coma ;// compliment accum.	A <= ~A
	asla ;// arith shift left		A <= A << 1
	rola ;// rotate left			A <= (A,C) << 1
	rora ;// rotate right			A <= (A,C) >> 1
	asra ;// arith shift right	A <= A >> 1
	lsra ;// logic shift right	A <= 
;=========================
; memory logical instructions
;=========================
	ldx #0
	inc c,x	;increment	M <= M + 1
	inc c,x	;increment	M <= M + 1
	tst c,x	;test		M - 0
	dec c,x	;decrement	M <= M - 1
	clr c,x	;clear		M <= 0
	inc c,x	;increment	M <= M + 1
	inc c,x	;increment	M <= M + 1
	neg c,x	;negate		M <= M - 0
	com c,x	;compliment	M <= ~M
	asl c	;arith shift left	M <= M << 1
	rol c	;rotate left	M <= (M,C) << 1
	ror c	;rotate right	M <= (M,C) >> 1
	asr c	;arith shift right	M <= M >> 1
	lsr c	;logical shift rightM <= M >> 1
;========================
; arithmetic instructions 
;======================== 
	adda #5	;add				A <= A + M
	suba #10;subtract			A <= A - M
	cmpa #5	;compare			A - M
	sbca #5	;subtract with carryA <= A - M - C
	anda #5	;and				A <= A ^ M
	bita #5	;bit test			A ^ M
	ldaa #5	;load accumulator	A <= M
	eora #5	;exclusive or		A <= A (+) M
	adca #5	;add with carry		A <= A + M + C
	oraa #5	;inclusive or		A <= A . M
;========================
; misc instructions
;========================
	incb ;
	stab c	;store accumulator	M <= A
	staa c	;store accumulator	M <= B
	lds c	;Load SP		SP[H] <= M, SP[L] <= (M + 1)
	ins;	;incr stackptr
	sts c	;store SP	M <= SP[H],  (M + 1) <= SP[L]
	ldx c	;Load XR		XR[H] <= M, XR[L] <= (M + 1)
	stx c	;store XR	M <= XR[H],  (M + 1) <= XR[L]
	bsr 5	;Branch to subroutine
	.rmb 5
	jmp d	;Jump absolute indexed
	.rmb 2
d	jsr e	;Jump to subroutine indexed
	.rmb 2
e	cpx c	;compare XR	XR[H] - M,  XR[L] - (M + 1)
;========================
 .end