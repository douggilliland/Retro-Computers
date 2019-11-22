		ldx #screen		
		inx 
		inx 
		inx
		stx pcaret	;at addr
; print numbers 1-60
		clrb;			;B=0
;		addb #95
pnums	tba				;A=B
		jsr outdec		;print A
		incb			;B += 1
		ldaa #32		;space
		jsr  outchar
		cmpb #10
		bne pnums;		;
;--
		ldaa #$56 
		jsr outdec
		ldx	 #message	;address
		jsr	outstrn		
		wai
		ldaa keyin
		jsr outchar
		jsr	clrscrn
;=========================
keyin	.equ $FFFF
screen	.equ $FB00
;-------------------------
;OutStrn [called using SWI]
;  strn at addr passed in X
;------------------------- 
outstrn	ldaa 0,x	;get char
		beq  term
		stx  strptr
		jsr  outchar
		ldx  strptr
		inx	 		;next char
		bra	 outstrn
term	rts			;return		
strptr	.rmb 2		;strptr
;-------------------------
;OutChar [called using SWI]
;-------------------------
outchar	ldx  pcaret	;current pos
		staa 0,x
		inx			;
		stx  pcaret	;
		rts			;return
;-------------------------
;OutDec [called using SWI]
;-------------------------
outdec	ldx  pcaret	;current pos
		staa store	;
		pshb		;save B
		ldab #10		;A < 10
		cba			;compare A-B
		blt  ones
		ldab #100	; A < 100
		cba			;compare A-B
		blt  tens
huns	jsr  divten	;A /= 10
		jsr  divten	;A /= 10
		adda #48	;to ASCII
		jsr  outchar
		suba #48	;reconstitute
		jsr  multen
		jsr  multen
		suba store	;A=[A]-A
		nega		;A=A-[A]
		staa store
tens	jsr  divten	;A /= 10
		adda #48	;to ASCII
		jsr outchar
		suba #48	;reconstitute
		jsr  multen
		suba store	;A=[A]-A
		nega		;A=A-[A]
		staa store
ones	adda #48	;to ASCII
		jsr outchar		
		pulb		;restore
		rts			;return
store	.rmb 1
;-------------------------
;DivTen [called using jsr]
;-------------------------
divten	pshb	;save B
		ldab	#8
		stab	count
		clrb 	;P=0
loopz 	aslb  	;P*2
		asla    ;A*2
		bcc skip1	;skip if not overflow
		incb		;P++
skip1	cmpb #10	;(P-B) 
		bmi skip2	;if < skip
		subb #10	;P=P-10 
		inca 	;A++		
skip2	tst	count
		dec count
		bne loopz
		pulb	;restore B
		rts		;return
count   .rmb 1
;-------------------------
;MulTen [called using jsr]
;-------------------------
multen	pshb	;save B
		asla 	;A*2
		tab		;B = A
		asla 	;A*4
		asla 	;A*8
		aba		;A = A + B
		pulb	;restore B
		rts		;return
;-------------------------
;Clear Screen [called using SWI]
;-------------------------
clrscrn	ldx	 #screen	
		stx  pcaret	;reset caret
;--
		ldaa #36
		staa 0,x
		staa 1,x
		staa 2,x
		staa 3,x
;--
csnlp1	clr 0,x		;[x] = 0
		inx			;x++
		cpx	#$FEE8	;screen+1000
		bne	csnlp1	;loop
		rts			;return
;-------------------------
pcaret	.stw $FB00
message	.str "this is a test. Press any key to continue"