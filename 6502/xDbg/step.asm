;
;=====================================================
; Steps one instruction.  Note that this fails if the
; instruction is followed by data rather than another
; instruction, such as "jsr putsil" which is followed
; by ASCII text.  Sorry, no easy way to figure this
; out.  cmdOffset points to char after S.
;
; So there are three scenarios to figure out where to
; place the BRK instruction:
;
; (1) There is a JMP or JSR which transfers control
;     to another address.
; (2) There is a branch instruction.  This can be a
;     BRA, or a conditional.  The BRK's placement
;     depends on whether the branch will be taken or
;     not.
; (3) There is a BBSx or BBRx instruction.  Very 
;     much like the relative branches but a specific
;     but must be Set or Reset in a specific zero
;     page address to take the branch.  The nstruction
;     is three bytes long.
; (4) RTS where the next address is on the stack.
; (5) RTI where the return address and flags are on
;     the stack.
; (6) The easiest case, put the BRK at the next
;     instruction after the current one.
;
Step		ldy	#0
		sty	ID		;assume not step-ver
		ldx	cmdOffset
		lda	buffer,x
		beq	stepnoto
		cmp	#'O'		;Over?
		bne	stepnoto
		inc	ID		;do step-over
stepnoto	lda	(PCL),y		;get opcode
		tax			;just in case
		sta	opcode		;save for later
;
; See if it is one of the few special cases.
;
		cmp	#$20		;JSR abs
		beq	stepJSR
		cmp	#$4c		;JMP abs
		beq	stepJMP
		cmp	#$6c		;JMP (indirect)
		beq	stepIndirection
		cmp	#$60		;RTS
		beq	stepRTS
		cmp	#$40		;RTI
		beq	stepRTI
		cmp	#$7c		;JMP (absolute,X)
		bne	steptrybv	;try branches
;
; This handles the case of absolute indexed indirect,
; (absolute,X).  The X register is added to the 2nd and
; 3rd bytes of the instruction.  This then points to a
; pointer to the next instruction.
;
		ldy	#2
		lda	(PCL),y
		sta	INH
		dey			;now 1
		lda	(PCL),y
		sta	INL
;
		clc
		lda	XREG
		adc	INL
		sta	INL
		bcc	stepaii1
		inc	INH
stepaii1	ldy	#0
		jmp	stepindir1
;
steptrybv	jmp	steptryb
;
; The next two bytes contain the address of where the
; actual address is located.  Get the address, then
; install the BRK.
;
stepIndirection	ldy	#2
		lda	(PCL),y
		sta	INH
		dey			;now 1
		lda	(PCL),y
		sta	INL
		dey			;now 0
;
; Get the actual address now
;
stepindir1	lda	(INL),y		;LSB
		pha
		iny
		lda	(INL),y		;MSB
		sta	INH
		pla
		sta	INL
		jmp	stepJMP2
;
; It's a JSR.  If they want to step over, then set
; the breakpoint at the next address and not inside
; the subroutine.
;
stepJSR		lda	ID
		beq	stepJMP		;step in
		jmp	stepnobranch	;else skip
;
; The next two bytes contain the address of the next
; instruction, so put the BRK there.
;
stepJMP		ldy	#2
		lda	(PCL),y
		sta	INH
		dey			;now 1
		lda	(PCL),y
		sta	INL
;
; INL/INH point to the address of the next instruction.
; Save data about it, install the BRK, then run the code.
;
stepJMP2	ldy	#0
		lda	(INL),y		;get opcode
		sta	StepOpcode	;for restoration
		lda	#BRK
		sta	(INL),y		;install BRK
		sta	StepActive
		inc	StepActive	;make non-zero
;
		lda	INL
		sta	StepAddress
		lda	INH
		sta	StepAddress+1
		jmp	ContinueNoBrk	;go!
;
; The address of the next instruction-1 is on the stack.
; Well, 0100+SP+1 = LSB, 0100+SP+2 = MSB.
;
stepRTI					;for now
stepRTS		ldx	SPUSER
		inx
		lda	$0100,x
		sta	INL
		inx
		lda	$0100,x
		sta	INH
;
; Add one since the 6502 saves the address of the last
; byte of the JSR, not the first byte of the next
; instruction.
;
		inc	INL
		bne	stepJMP2
		inc	INH
		jmp	stepJMP2
;
;-----------------------------------------------------
; Now it gets complicated.  If this is a branch
; instruction and if the condition is true, then
; compute the target address of the branch.
;
steptryb	lda	opcode
		cmp	#$80		;BRA?
		beq	steptakebranch	;branch always taken
		and	#$0f
		bne	stepnobranch	;not a branch
;
; All other branches have bit 4 set.
;
		lda	opcode
		and	#%00010000	;all branches set
		beq	stepnobranch	;not a branch
;
; Now convert upper nibble to index to get which bit must be
; set in the P register for the branch to be taken.  Shift
; right 5 bits because the top three bits identify which 
; instruction this is.  BPL=000, BMI=001, BVC=010, BVS=011,
; BCC=100, BCS=101, BNE=110, BEQ=111
;
		lda	opcode
		lsr	a		;upper nibble...
		lsr	a		;becomes index
		lsr	a
		lsr	a
		lsr	a
		tax
		lda	pflagbits,x
		and	PREG		;isolate bit
		beq	stepflag0	;not a branch
;
; Bit 5 indicates if the flag should be set or not to take
; the branch.  If set and the flag is set, then take the
; branch.  If clear and the flag is clear, then take the
; branch.  Else, just skip to the next instruction.
;
; If we get here, the flag bit is set.
;
		lda	opcode		;get back opcode
		and	#%00100000
		beq	stepnobranch	;branch if should be 0
		jmp	steptakebranch
;
; If we get here, the flag bit is clear.
;
stepflag0	lda	opcode
		and	#%00100000	;must be clear
		bne	stepnobranch
;
; The branch condition is true so compute the target address
;
steptakebranch	ldy	#0
		sty	Temp16+1	;for sign extension
		iny			;point to offset
		lda	(PCL),y
		bpl	steptakebr2
		dec	Temp16+1	;make negative
steptakebr2	clc
		adc	PCL
		sta	INL
		lda	PCH
		adc	Temp16+1
		sta	INH
;
; Now add two since the branch is relative to the byte
; after the offset, not the branch instruction.
;
		clc
		lda	INL
		adc	#2
		sta	INL
		bcc	steptakebr3
		inc	INH
steptakebr3	jmp	stepJMP2
;
; This table is used to lookup which bit in the flags
; register a branch instruction cares about.
;
pflagbits	db	$80,$80,$40,$40	;BMI,BPL,BVC,BVS
		db	$01,$01,$02,$02	;BCC,BCS,BNE,BEQ
;
;-----------------------------------------------------
; Check for a BBSx or BBRx instruction.  the opcode is
; in A.
;
stepnobranch	lda	opcode
		and	#$0f
		cmp	#$0f
		bne	stepnormal	;nope
;
; The lower 3 bits of the top nibble contain the bit
; number to test.  The most significant bit indicates
; if the bit has to be set or reset (clear) to take
; the branch.
;
		ldy	#1
		lda	(PCL),y
		lsr	a
		lsr	a
		lsr	a
		lsr	a
		and	#$07		;which bit
		tax
		ldx	#7		;how many shifts
		lda	#1
stepnb1		dex
		bmi	stepnb2
		asl	a
		bne	stepnb1
;
; A has the bitmap
;
stepnb2		pha
		iny
		lda	(PCL),y		;get zp address
		tax
		pla
		and	$00,x		;see if bit set
		bne	stepnb3		;brach if set
;
; Bit is not set, see if that's what we are
; supposed to branch on.
;
		dey
		lda	(PCL),y
		bmi	stepnbNo	;do not take branch
;
; Take the branch.
;
stepnbYes	ldy	#0
		sty	Temp16+1	;for sign extension
		iny			;point to offset
		iny
		lda	(PCL),y
		bpl	stepnbYes2
		dec	Temp16+1	;make negative
stepnbYes2	clc
		adc	PCL
		sta	INL
		lda	PCH
		adc	Temp16+1
		sta	INH
;
; Now add three since the branch is relative to the byte
; after the offset, not the branch instruction.
;
		clc
		lda	INL
		adc	#3
		sta	INL
		bcc	stepnbYes3
		inc	INH
stepnbYes3	jmp	stepJMP2
;
; Bit was not set so see if the branch is based on it
; being reset.
;
stepnb3		dey
		lda	(PCL),y
		bcc	stepnbYes	;take branch
;
; Not set, so the next step is three bytes after this
; instruction.
;
stepnbNo	lda	#3		;lenght of instruction
		bne	stepnormal2
;
;-----------------------------------------------------
; Not a branch, so place the BRK at the next
; instruction in series.  On entry, X contains
; the opcode.
;
stepnormal	ldx	opcode
		lda	addmodeTbl,x	;get addr mode
		tax
		lda	addmodeLen,x	;get length
;
; Compute the address of the next instruction and save
; the address for later restoration of the opcode.
;
stepnormal2	clc
		adc	PCL
		sta	INL
		sta	StepAddress
		lda	#0
		adc	PCH
		sta	INH
		sta	StepAddress+1
;
; Save the original instruction for later restoration.
;
		ldy	#0
		lda	(INL),y
		sta	StepOpcode	;save for later
		lda	#$ff
		sta	StepActive	;step is active
		lda	#BRK
		sta	(INL),y		;set breakpoint
		jmp	ContinueNoBrk	;go!
