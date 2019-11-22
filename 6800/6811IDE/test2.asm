;==============================
; Sum 1 to 10
;==============================
ten		.equ 10
sum10	clra		;A = 0
		ldab #ten	;B = 10
loop1	aba			;A = A + B 
		decb		;B--
		tstb		;test (B==0)
		bne	 loop1	;repeat if B!=0
		staa sum	;sum = A
;==============================
; Sum Array values, zero terminated
;==============================
sumarry	ldx #array	;X = array
		clra		;A = 0
		clrb		;B = 0
loop2	adda 0,x	;A += array[0]
		inx			;next item
		tst  0,x	;check item
		bne	 loop2	;repeat if B!=0
		staa sum	;sum = A
;==============================
; factorial with subroutine 
; variables passed in A & B regs
;==============================
five	.equ 5
fact1	ldaa #five	;A = 5
		tab			;B = A
loop3	decb		;B = B - 1
		tstb		;test (B==0)
		beq	 fin1	;repeat if B=0
		pshb		;save B
		jsr mult1	;r = A * B 
		pulb		;restore B
		tstb		;test (B==0)
		bne	 loop3	;repeat if B!=0
		jmp  fin1
;-- multiply 2 values on stack
var		rmb	1		;variable A
mult1	staa var	;var = A
		clra 		;A = 0
loopm	adda var	;A += var 
		decb		;B--
		tstb		;test (B==0)
		bne	 loopm	;repeat if B!=0
		rts			;return
;-----------
fin1	staa sum	;sum = A
;==============================
; factorial with subroutine 
;==============================
fact2	ldaa #five	;A = 5
		tab			;B = A
loop4	decb		;B = B - 1
		tstb		;test (B==0)
		beq	 fin2	;repeat if B=0
		pshb		;save B
		staa var1	;
		stab var2	;
		jsr mult2	;r = A * B 
		pulb		;restore B
		tstb		;test (B==0)
		bne	 loop4	;repeat if B!=0
		jmp  fin2
;-- multiply 2 values on stack
var1	rmb	1		;variable A
var2	rmb	1		;variable B
mult2	clra 		;A = 0
		ldab var2	;
loopn	adda var1	;A += var1 
		decb		;B--
		tstb		;test (B==0)
		bne	 loopn	;repeat if B!=0
		rts			;return
;-----------
fin2	staa sum	;sum = A
;==============================
; factorial with subroutine 
; variables passed on stack
;==============================
fact3	ldaa #five	;A = 5
		tab			;B = A
loop5	decb		;B = B - 1
		tstb		;test (B==0)
		beq	 fin3	;repeat if B=0
		pshb		;save B
		tsx			;X = SP
		dex
		psha		;var A
		pshb		;var B
		jsr mult3	;r = A * B 
		pulb
		pulb
		pulb		;restore B
		tstb		;test (B==0)
		bne	 loop5	;repeat if B!=0
		jmp  fin3
;-- multiply 2 values on stack
var3	rmb	1		;variable A
mult3	ldaa 0,x	;A = var1
		ldab 1,x	;B = var2
		staa var3	;var = A
		clra 		;A = 0
loopo	adda var3	;A += var 
		decb		;B--
		tstb		;test (B==0)
		bne	 loopo	;repeat if B!=0
		rts			;return
;-----------
fin3	staa sum	;sum = A
;==============================
;==============================
;-- variables ---
sum		.rmb 1
array	.byte	3,5,7,0	
aptr	.rmb 2		;array ptr
		.end  

