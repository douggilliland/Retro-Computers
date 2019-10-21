	z80

	predef math,logic
	org	0100H
FPCommand	equ	0a4h
FPpsw	equ	0a4h	;FP Condition Code Register 
FPGetPut	equ	0a5h
FPStatus	equ	0a5h	;FP General status
FPDstSrc	equ	0a6h
FPVector	equ	0a7h

FPdata	equ	0a8h

	jmp 	start
sp0	i3ed_le	10
sp1	i3es_le	-5
sp2	i3es_le	PI
sp3	i3es_le	-50
dp0	i3ed_le	10
dp1	i3ed_le	-5
dp2	i3ed_le	PI
dp3	i3ed_le	-50
dsr0	dw 0,0
dsr1	dw 0,0
dsr2	dw 0,0
dpr0	dw 0,0,0,0
dpr1	dw 0,0,0,0
dpr2	dw 0,0,0,0
*
* Get\Put port
*  0 123 4567
* |-|---|----|
* | |   |    |
* |-|---|----|
*  G/P=0/1
*    Conversion Type =0-7
*        FPA # = 0-15
start	
;Load dp0 into FPA0 
	mvi	b,8	;load fp data in registers
	mvi	c,FPdata
	lxi	h,dp0
..loop	mov	a,m
	outp	a
	inr	c
	inx	h
	dcr	b
	jnz	..loop

	mvi	a,1$111$0000b	;put $ double $ FPA0
	out	FPGetPut

;Load dp1 into FPA1
	mvi	b,8	;load fp data in registers
	mvi	c,FPdata
	lxi	h,dp1
..loop	mov	a,m
	outp	a
	inr	c
	inx	h
	dcr	b
	jnz	..loop

	mvi	a,1$111$0001b	;put $ double $ FPA1
	out	FPGetPut

; Execute Multiply
	mvi	a,0001$0000b	;dst=FPA1 $ src=FPA0
	out	FPDstSrc
	mvi	a,5		;mult
	out	FPCommand
	mvi	c,FPpsw		;Read Fp psw into z80 psw
	inp	m		;  using special Zilog instruction
	jz	$		;use regular conditionals

;Get FPA1 into dpr2
	mvi	a,0$111$0001b	;get $ double $ FPA0
	out	FPGetPut

	mvi	b,8	;get fp data out registers
	mvi	c,FPdata
	lxi	h,dpr2
..loop	inp	a
	mov	m,a
	inr	c
	inx	h
	dcr	b
	jnz	..loop

	jmp 	start

	end	0100h