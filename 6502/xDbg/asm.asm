;=====================================================
; dis.asm
;
; This is the disassembler for the debugger.
;
; This is coded to support the WDC 65C02 chip.  In the
; future I might have a 6502 mode.
;
		code
Assembler	jsr	ChkParam
		jsr	GetHex
		jsr	XferPOINT	;put into POINT
;
; The starting address is now in POINT.
;
assemloop	jsr	PRTPNT
		lda	#':'
		jsr	xkOUTCH
		jsr	space
		jsr	GetLine
		beq	assemexit	;empty line exits
		jsr	SkipSpaces
;
; Compress the mnemonic into a 16 bit value.  It's far
; easier to work with a 16 value than multi-byte ASCII.
;
		jsr	asmcompress
		bcc	assem1
asmbadop	jsr	putsil		;bad mnemonic
		db	"Bad mnemonic",CR,LF,0
		jmp	assemloop
assemexit	jmp	MainLoop
;
; During development and debugging there were a lot of issues
; with branches being out of range so these vectors are close
; enough to branch to.  Once everything is working it will be
; possible to rearrange code so most branches are in range.
;
asmimplv	jmp	asmimpl
asmrelav	jmp	asmrela
asmindiv	jmp	asmindi
asmaccuv	jmp	asmaccu
asmimmev	jmp	asmimme
asmodd2v	jmp	asmodd2
asmodd3v	jmp	asmodd3
;
; Mnemonic compressed properly
;
assem1		jsr	asmFindMnem	;look up mnemonic
		beq	asmbadop
;
; Figure out addressing mode.  Some instructions have only
; one addressing mode, so weed those out first.
;
		ldy	#0		;offset
		lda	(INL),y		;get first mode
		cmp	#AM_RELA
		beq	asmrelav	;relative!
		cmp	#AM_IMPL
		beq	asmimplv
		cmp	#AM_ODD2
		beq	asmodd2v
		cmp	#AM_ODD3
		beq	asmodd3v
;
; Could be other modes, so look at the argument format
; to figure it out.
;
		jsr	SkipToSpace	;skip over mnemonic
		jsr	SkipSpaces
		lda	buffer,x
		cmp	#'#'		;immediate?
		beq	asmimmev
		cmp	#'('		;indirect?
		beq	asmindiv
		cmp	#'A'		;Accumulator?
		beq	asmaccuv
;
; Absolute or zero page.  Worry about whether it's
; zero page or not later.  First it is necessary to
; see if there is anything after the number like
; ",X" or ",Y".
;
;    addr	AM_ABSO
;    addr,X	AM_AIWX
;    addr,Y	AM_AIWY
;    zp,X	AM_ZIWX
;    zp,Y	AM_ZIWY
;
assem2		jsr	GetHex		;advances cmdOffset
		lda	buffer,x
		beq	asmabszero	;just a number
;
; Check for ,Y and ,X
;
		cmp	#','
		bne	asmabszero
		lda	buffer+1,x
		cmp	#'X'
		beq	asm113
		cmp	#'Y'
		bne	asmbadam
;
; ,Y
;
		lda	Temp16+1	;MSB
		bne	asm111
		lda	#AM_ZIWY	;try zero page version
		jsr	asmfindop
		bcs	asm111		;try absolute
		jmp	asmfini8

asm111		lda	#AM_AIWY	;it is absolute
		jsr	asmfindop
		bcs	asmbadam	;bad addressing mode
		jmp	asmfini16
;
; ,X
;
asm113		lda	Temp16+1	;MSB
		bne	asm112
		lda	#AM_ZIWX	;try zero page version
		jsr	asmfindop
		bcs	asm112		;try absolute
		jmp	asmfini8

asm112		lda	#AM_AIWX	;it is absolute
		jsr	asmfindop
		bcs	asmbadam	;bad addressing mode
		jmp	asmfini16
;
; It's just an address so if it is < 256 then try
; finding a zero page version, else try absolute.
;
asmabszero	lda	Temp16+1
		bne	asm114
		lda	#AM_ZERO	;try zero page version
		jsr	asmfindop
		bcs	asm114		;try absolute
		jmp	asmfini8

asm114		lda	#AM_ABSO	;it is absolute
		jsr	asmfindop
		bcs	asmbadam	;bad addressing mode
		jmp	asmfini16
;
;-----------------------------------------------------
; Implied.  Any instruction with an implied addressing
; mode will have no other modes, so no need to look up
; the opcode again.
;
asmimpl		iny
		lda	(INL),y		;get opcode
		jmp	asmfini0	;Y = 0
;
;-----------------------------------------------------
; Immediate
;
asmimme		lda	#AM_IMME
		jsr	asmfindop
		bcs	asmbadam	;bad addressing mode
		pha
		inc	cmdOffset	;skip '#'
		jsr	GetHex		;get value
		pla
		jmp	asmfini8
;
;-----------------------------------------------------
; This can be jumped to anytime the addressing mode
; is invalid.
;
asmbadam	jsr	putsil
		db	"Bad addressing mode",CR,LF,0
		jmp	assemloop
;
;-----------------------------------------------------
; Accumulator
; The next character has to be a 0 or else this might
; be the start of a number.
;
asmaccu		ldx	cmdOffset
		inx
		lda	buffer,x
		bne	assem2v		;must be number
		lda	#AM_ACCU
		jsr	asmfindop
		bcs	asmbadam	;bad addressing mode
		jmp	asmfini0
assem2v		jmp	assem2
asmbadamv2	jmp	asmbadam
;
;-----------------------------------------------------
; Indirect.  This is more complicated because there are
; several indirect modes, so skip past the numeric
; value to see what the mode is.
;
;    (addr)	AM_INDI
;    (addr,X)	AM_AIIX
;    (zp,X)	AM_ZIIX
;    (zp)	AM_ZPIN
;    (zp),Y	AM_IIWY
;
asmindi		inc	cmdOffset
		jsr	GetHex		;get address
;
; The next character should be either ')' or ','
;
		lda	buffer,x
		cmp	#')'
		beq	asmindpar
		cmp	#','
		bne	asmbadamv	;else not valid
;
; The next two characters must be "X)"
;
		lda	buffer+1,x
		cmp	#'X'
		bne	asmbadamv
		lda	buffer+2,x
		cmp	#')'
		bne	asmbadamv
;
; It's either Absolute Indexed Indirect with X or
; Zero Page Indexed Indirect based on whether the
; address is < 100 or not.
;
		lda	Temp16+1
		bne	asm115
		lda	#AM_ZIIX	;try zero page version
		jsr	asmfindop
		bcs	asm115		;try absolute
		jmp	asmfini8

asm115		lda	#AM_AIIX	;it is absolute
		jsr	asmfindop
		bcs	asmbadamv2	;bad addressing mode
		jmp	asmfini16
asmbadamv	jmp	asmbadam
;
; The remainder can be nothing, or ",Y"
;
asmindpar	lda	buffer+1,x
		beq	asm116		;no ,Y
		cmp	#','
		bne	asmbadamv
		lda	buffer+2,x
		cmp	#'Y'
		bne	asmbadamv
;
; It is (zp),Y so make sure address is < 100.
;
		lda	Temp16+1
		bne	asmbadamv
		lda	#AM_IIWY
		jsr	asmfindop
		bcs	asm115		;try absolute
		jmp	asmfini8
;
; It's just indirect
;
asm116		lda	Temp16+1	;MSB
		bne	asm117
		lda	#AM_ZPIN	;try zero page version
		jsr	asmfindop
		bcs	asm117		;try absolute
		jmp	asmfini8

asm117		lda	#AM_INDI	;it is absolute
		jsr	asmfindop
		bcs	asmbadamv	;bad addressing mode
		jmp	asmfini16
;
;-----------------------------------------------------
; Relative.  the argument is the target address.
;
asmrela		jsr	SkipToSpace	;skip over mnemonic
		jsr	SkipSpaces
		jsr	GetHex		;get target addr
;
; Call a function in xKIM to do the calculation.  The
; address of the branch instruction is in SAL/SAH and
; the target address is in EAL/EAH.  If within range,
; returns C clear and offset in A.
;
		lda	POINTL
		sta	SAL
		lda	POINTH
		sta	SAH
		jsr	XferEA		;target address
		jsr	calcOffset
		bcs	asmbadoor	;branch if out of range
;
		sta	opcode		;save offset
		lda	#AM_RELA
		jsr	asmfindop
;		bcs	asmbadam	;should never happen
;
; Because the second byte is calculated, this code must
; manually set up memory.
;
		ldy	#0
		sta	(POINTL),y		;save opcode
		iny
		lda	opcode
		sta	(POINTL),y
		jmp	asmfinipr
;
; Branch is out of range
;
asmbadoor	jsr	putsil
		db	"Branch out of range",CR,LF,0
		jmp	assemloop
;
;-----------------------------------------------------
; Handle the odd RMBx and SMBx mnemomnics.  This does
; not validate the digit following the mnemonic.  Bug.
;
asmodd2		jsr	asmoddhelp
		jmp	asmfini8
;
;-----------------------------------------------------
; Handle the odd BBRx and BBSx mnemonics.  These are
; weird in that there is a zero page address followed
; by a target address for the jump: zp,addr
;
asmodd3		jsr	asmoddhelp
		sta	opcode		;save for later
		lda	Temp16		;save address
		sta	storeX
;
; There must be a comma and then a target address.
;
		ldx	cmdOffset
		lda	buffer,x
		cmp	#','
		bne	asmsynerr
		inc	cmdOffset	;point to address
		jsr	GetHex
;
; Now compute the offset.  The xKIM function assumes the
; branch is a two byte instruction, but these odd 
; instructions are three bytes, so add one to the start
; address.
;
		lda	POINTL
		sta	SAL
		lda	POINTH
		sta	SAH
		inc	SAL
		bne	asmodd31
		inc	SAH
asmodd31	jsr	XferEA		;target address
		jsr	calcOffset
		bcs	asmbadoor	;branch if out of range
;
; We've got all the pieces, just put them all into
; memory.
;
		pha			;save offset
		ldy	#0
		lda	opcode
		sta	(POINTL),y
		iny
		lda	storeX
		sta	(POINTL),y
		iny
		pla
		sta	(POINTL),y
		jmp	asmfinipr
;
asmsynerr	jsr	putsil
		db	"Syntax error",CR,LF,0
;
;-----------------------------------------------------
; Function to assist with the odd instructions.  It
; will get the bit number from the end of the
; mnemonic and properly add it into the base opcode.
; Verifies the target address is in zero page and
; will not return if not.  Address is in Temp16 and
; the opcode is returned in A.
;
asmoddhelp	iny
		lda	(INL),y		;get opcode
		sta	opcode
;
		jsr	SkipToSpace	;skip over mnemonic
		dec	cmdOffset	;move back to digi
		ldx	cmdOffset
		lda	buffer,x
;
; Make sure the bit number is from 0 to 7.
;
		sec
		sbc	#'0'
		bcc	asmoddbadmn
		cmp	#8
		bcs	asmoddbadmn
;
		asl	a
		asl	a
		asl	a
		asl	a
		ora	opcode
		sta	opcode		;got value
		jsr	SkipToSpace
		jsr	SkipSpaces	;move to args
		jsr	GetHex
;
; Make sure it is a zero page address
;
		lda	Temp16+1
		bne	asmodderror	;branch if too big
		lda	opcode
		rts
;
asmodderror	pla			;clean up stack
		pla
		jmp	asmbadamv
asmoddbadmn	jmp	asmbadop
;
;-----------------------------------------------------
; Three very handy entry points.  Call each with the
; opcode in A, which is placed at (IN),0.  If asmfini0
; is called then just the opcode is stored.  If
; asmfini8 is called then the LSB of Temp16 is placed
; in the next location.  If asmfini16 is called then
; move all of Temp16 into the next two bytes.  Updates
; POINT to the next location after this instruction.
;
asmfini0	ldy	#0
		sta	(POINTL),y	;save opcode
		jmp	asmfinipr
;
asmfini8	ldy	#0
		sta	(POINTL),y	;save opcode
		iny
		lda	Temp16		;get LSB
		sta	(POINTL),y
		jmp	asmfinipr
;
asmfini16	ldy	#0
		sta	(POINTL),y	;save opcode
		iny
		lda	Temp16		;get LSB
		sta	(POINTL),y
		iny
		lda	Temp16+1	;get MSB
		sta	(POINTL),y
;
;-----------------------------------------------------
; This finishes up by displaying all the bytes of the
; instruction.  On entry, IN points to the first byte
; and Y is the offset to the last byte.  Ie, a one byte
; instruction has y set to 0.  On exit IN will be
; moved to the next free location.
;
asmfinipr	sty	ID		;a counter
		jsr	PRTPNT		;print address
		lda	#':'
		jsr	xkOUTCH
		jsr	space
;
; Now print the right number of bytes
;
asmfiniloop	ldy	#0
		lda	(POINTL),y
		jsr	xkPRTBYT
		jsr	space
		jsr	INCPT
		dec	ID		;enough bytes?
		bpl	asmfiniloop
		jsr	CRLF
		jmp	assemloop
;
;=====================================================
; Compress the three character string at cmdOffset
; into Temp16.  Uses the same encoding as the
; disassembler.  This is NOT VERY SMART and does
; MINIMAL ERROR CHECKING!!!
;
; Returns C clear if good, C set if not.  In the future
; I'll add better error testing.
;
asmcompress	ldx	cmdOffset
		lda	buffer+2,x	;last char first
		sec
		sbc	#'?'		;? is the base
		sta	Temp16+1
		lda	buffer+1,x
;
		sec
		sbc	#'?'
		asl	a
		asl	a
		asl	a
		asl	a
		rol	Temp16+1
		asl	a
		rol	Temp16+1
		sta	Temp16
		lda	buffer,x
;
		sec
		sbc	#'?'
		ora	Temp16
		sta	Temp16
		clc			;all is good
		rts
;
;=====================================================
; Given the addressing mode in A and a
; pointer to the mnemonics entry in IN, find the
; addressing mode and return the opcode in A and C
; clear.  If that mode is not found, return C set.
;
asmfindop	sta	ID		;save for compare
		ldy	#0
asmfindop1	lda	(INL),y
		cmp	#AM_BADD	;not found
		beq	asmfindnope
		cmp	ID		;one we want?
		beq	asmfindyup	;branch if yes
		iny
		iny
		bne	asmfindop1
;
asmfindnope	sec
		rts
;
asmfindyup	iny			;move to opcode
		lda	(INL),y
		clc
		rts
;
;=====================================================
; Using the compressed mnemonic in Temp16, look up the
; entry for that mnemonic in the MNEMlookup table.
; Up on success, return Z clear and IN points to the
; first byte after the compressed mnemonic.  If not
; found, returns Z set.
;
asmFindMnem	lda	#MNEMlookup&$ff
		sta	INL
		lda	#MNEMlookup>>8
		sta	INH
;
; See if the current entry is the one we want
;
asmfindloop	ldy	#0
		lda	(INL),y		;0 is end of table
		beq	asmfindmemnf
		lda	(INL),y		;LSB of mnemonic
		cmp	Temp16
		bne	asmfindmem1	;no match
		iny
		lda	(INL),y
		cmp	Temp16+1	;MSB
		beq	asmfindmem2	;this is it!
		bne	asmfindmem3
;
; Not the right one, so skip bytes until AM_BADD is
; found.
;
asmfindmem1	iny
asmfindmem3	iny
		lda	(INL),y		;get add mode
		cmp	#$ff		;end of entire list?
		beq	asmfindmemnf
		cmp	#AM_BADD	;end of this list?
		beq	asmfindnext	;yes, not found
;
		iny			;skip add mode
		bne	asmfindmem3
;
; Skip to the next entry and try again
;
asmfindnext	tya
		sec			;need to add one
		adc	INL
		sta	INL
		bcc	asmfindloop
		inc	INH
		bne	asmfindloop
;
; Not found
;
asmfindmemnf	lda	#0		;not found
		rts
;
; Found it!  Woohoo!  Bump IN by two so it points
; to the first item.
;
asmfindmem2	lda	INL
		clc
		adc	#2
		sta	INL
		bcc	asmfindA
		inc	INH
asmfindA	lda	#$ff		;clear Z flag
		rts
;
;=====================================================
; Table to look up mnemonic, and also get a list of
; supported addressing modes for it.  Each entry is
; kind of messy, but contains:
;
;    Encoded mnemonic (16 bits)
;    A list of one or more sets of:
;       Addressing mode (1 byte)
;       opcode (1 byte)
;    Final entry is one byte of AM_BADD.
;
; Eventually this table should be merged with the
; disassembler's MNEMS table since they contain some
; duplicate data, but it would require more mods to
; the disassembler and this table might change anyway.
;
MNEMlookup
asm_ADC		dw	$10a2
		db	AM_ZIWX,$61,AM_ZERO,$65
		db	AM_IMME,$69,AM_ABSO,$6d
		db	AM_IIWY,$71,AM_ZPIN,$72
		db	AM_ZIWX,$75,AM_AIWY,$79
		db	AM_AIWX,$7d,AM_BADD
;
asm_AND		dw	$15e2
		db	AM_ZIWX,$21,AM_ZERO,$25
		db	AM_IMME,$29,AM_ABSO,$2d
		db	AM_IIWY,$31,AM_ZPIN,$32
		db	AM_ZIWX,$35,AM_AIWY,$39
		db	AM_AIWX,$3d,AM_BADD
;
asm_ASL		dw	$3682
		db	AM_ABSO,$0e,AM_AIWX,$1e
		db	AM_ACCU,$0a,AM_ZERO,$06
		db	AM_ZIWX,$16,AM_BADD
;
asm_BBR		dw	$4c63
		db	AM_ODD3,$0f,AM_BADD	;ODD MENMONIC!!!
;
asm_BBS		dw	$5063
		db	AM_ODD3,$8f,AM_BADD	;ODD MNEMONIC!!!
;
asm_BCC		dw	$1083
		db	AM_RELA,$90,AM_BADD
;
asm_BCS		dw	$5083
		db	AM_RELA,$b0,AM_BADD
;
asm_BEQ		dw	$48c3
		db	AM_RELA,$f0,AM_BADD
;
asm_BIT		dw	$5543
		db	AM_ABSO,$2c,AM_AIWX,$3c
		db	AM_IMME,$89,AM_ZERO,$24
		db	AM_ZIWX,$34,AM_BADD
;
asm_BMI		dw	$29c3
		db	AM_RELA,$30,AM_BADD
;
asm_BNE		dw	$19e3
		db	AM_RELA,$d0,AM_BADD
;
asm_BPL		dw	$3623
		db	AM_RELA,$10,AM_BADD
;
asm_BRA		dw	$0a63
		db	AM_RELA,$80,AM_BADD
;
asm_BRK		dw	$3263
		db	AM_IMPL,$00,AM_BADD
;
asm_BVC		dw	$12e3
		db	AM_RELA,$50,AM_BADD
;
asm_BVS		dw	$52e3
		db	AM_RELA,$70,AM_BADD
;
asm_CLC		dw	$11a4
		db	AM_IMPL,$18,AM_BADD
;
asm_CLD		dw	$15a4
		db	AM_IMPL,$d8,AM_BADD
;
asm_CLI		dw	$29a4
		db	AM_IMPL,$58,AM_BADD
;
asm_CLV		dw	$5da4
		db	AM_IMPL,$b8,AM_BADD
;
asm_CMP		dw	$45c4
		db	AM_ABSO,$cd,AM_AIWX,$dd
		db	AM_AIWY,$d9,AM_IMME,$c9
		db	AM_ZERO,$c5,AM_ZIIX,$c1
		db	AM_ZIWX,$d5,AM_ZPIN,$d2
		db	AM_IIWY,$d1,AM_BADD
;
asm_CPX		dw	$6624
		db	AM_ABSO,$ec,AM_IMME,$e0
		db	AM_ZERO,$e4,AM_BADD
;
asm_CPY		dw	$6a24
		db	AM_ABSO,$cc,AM_IMME,$c0
		db	AM_ZERO,$c4,AM_BADD
;
asm_DEC		dw	$10c5
		db	AM_ABSO,$ce,AM_AIWX,$de
		db	AM_ACCU,$3a,AM_ZERO,$c6
		db	AM_ZIWX,$d6,AM_BADD
;
asm_DEX		dw	$64c5
		db	AM_IMPL,$ca,AM_BADD
;
asm_DEY		dw	$68c5
		db	AM_IMPL,$88,AM_BADD
;
asm_EOR		dw	$4e06
		db	AM_ABSO,$4d,AM_AIWX,$5d
		db	AM_AIWY,$59,AM_IMME,$49
		db	AM_ZERO,$45,AM_ZIIX,$41
		db	AM_ZIWX,$45,AM_ZPIN,$52
		db	AM_IIWY,$51,AM_BADD
;
asm_INC		dw	$11ea
		db	AM_ABSO,$ee,AM_AIWX,$fe
		db	AM_ACCU,$1a,AM_ZERO,$e6
		db	AM_ZIWX,$f6,AM_BADD
;
asm_INX		dw	$65ea
		db	AM_IMPL,$e8,AM_BADD
;
asm_INY		dw	$69ea
		db	AM_IMPL,$c8,AM_BADD
;
asm_JMP		dw	$45cb
		db	AM_ABSO,$4c,AM_AIIX,$7c
		db	AM_INDI,$6c,AM_BADD
;
asm_JSR		dw	$4e8b
		db	AM_ABSO,$20,AM_BADD
;
asm_LDA		dw	$08ad
		db	AM_ABSO,$ad,AM_AIWX,$bd
		db	AM_AIWY,$b9,AM_IMME,$a9
		db	AM_ZERO,$a5,AM_ZIIX,$a1
		db	AM_ZIWX,$b5,AM_ZPIN,$b2
		db	AM_IIWY,$b1,AM_BADD
;
asm_LDX		dw	$64ad
		db	AM_ABSO,$ae,AM_AIWY,$be
		db	AM_IMME,$a2,AM_ZERO,$a6
		db	AM_ZIWY,$b6,AM_BADD
;
asm_LDY		dw	$68ad
		db	AM_ABSO,$ac,AM_AIWX,$bc
		db	AM_IMME,$a0,AM_ZERO,$a4
		db	AM_ZIWX,$b4,AM_BADD
;
asm_LSR		dw	$4e8d
		db	AM_ABSO,$4e,AM_AIWX,$5e
		db	AM_ACCU,$4a,AM_ZERO,$46
		db	AM_ZIWX,$56,AM_BADD
;
asm_NOP		dw	$460f
		db	AM_IMPL,$ea,AM_BADD
;
asm_ORA		dw	$0a70
		db	AM_ABSO,$0d,AM_AIWX,$1d
		db	AM_AIWY,$19,AM_IMME,$09
		db	AM_ZERO,$05,AM_ZIIX,$01
		db	AM_ZIWX,$15,AM_ZPIN,$12
		db	AM_IIWY,$11,AM_BADD
;
asm_PHA		dw	$0931
		db	AM_IMPL,$48,AM_BADD
;
asm_PHP		dw	$4531
		db	AM_IMPL,$08,AM_BADD
;
asm_PHX		dw	$6531
		db	AM_IMPL,$da,AM_BADD
;
asm_PHY		dw	$6931
		db	AM_IMPL,$5a,AM_BADD
;
asm_PLA		dw	$09b1
		db	AM_IMPL,$68,AM_BADD
;
asm_PLP		dw	$45b1
		db	AM_IMPL,$28,AM_BADD
;
asm_PLX		dw	$65b1
		db	AM_IMPL,$fa,AM_BADD
;
asm_PLY		dw	$69b1
		db	AM_IMPL,$7a,AM_BADD
;
asm_RMB		dw	$0dd3
		db	AM_ODD2,$07,AM_BADD	;ODD MNEMONIC!!!
;
asm_ROL		dw	$3613
		db	AM_ABSO,$2e,AM_AIWX,$3e
		db	AM_ACCU,$2a,AM_ZERO,$26
		db	AM_ZIWX,$36,AM_BADD
;
asm_ROR		dw	$4e13
		db	AM_ABSO,$6e,AM_AIWX,$7e
		db	AM_ACCU,$6a,AM_ZERO,$66
		db	AM_ZIWX,$76,AM_BADD
;
asm_RTI		dw	$2ab3
		db	AM_IMPL,$40,AM_BADD
;
asm_RTS		dw	$52b3
		db	AM_IMPL,$60,AM_BADD
;
asm_SBC		dw	$1074
		db	AM_ABSO,$ed,AM_AIWX,$fd
		db	AM_AIWY,$f9,AM_IMME,$e9
		db	AM_ZERO,$e5,AM_ZIIX,$e1
		db	AM_ZIWX,$f5,AM_ZPIN,$f2
		db	AM_IIWY,$f1,AM_BADD
;
asm_SEC		dw	$10d4
		db	AM_IMPL,$38,AM_BADD
;
asm_SED		dw	$14d4
		db	AM_IMPL,$f8,AM_BADD
;
asm_SEI		dw	$28d4
		db	AM_IMPL,$78,AM_BADD
;
asm_SMB		dw	$0dd4
		db	AM_ODD2,$87,AM_BADD	;ODD MNEMONIC!!!
;
asm_STA		dw	$0ab4
		db	AM_ABSO,$8d,AM_AIWX,$9d
		db	AM_AIWY,$99,AM_ZERO,$85
		db	AM_ZIIX,$81,AM_ZIWX,$95
		db	AM_ZPIN,$92,AM_IIWY,$91
		db	AM_BADD
;
asm_STP		dw	$46b4
		db	AM_IMPL,$db,AM_BADD
;
asm_STX		dw	$66b4
		db	AM_ABSO,$8e,AM_ZERO,$86
		db	AM_ZIWY,$96,AM_BADD
;
asm_STY		dw	$6ab4
		db	AM_ABSO,$8c,AM_ZERO,$84
		db	AM_ZIWX,$94,AM_BADD
;
asm_STZ		dw	$6eb4
		db	AM_ABSO,$9c,AM_AIWX,$9e
		db	AM_ZERO,$64,AM_ZIWX,$74
		db	AM_BADD
;
asm_TAX		dw	$6455
		db	AM_IMPL,$aa,AM_BADD
;
asm_TAY		dw	$6855
		db	AM_IMPL,$a8,AM_BADD
;
asm_TRB		dw	$0e75
		db	AM_ABSO,$1c,AM_ZERO,$14
		db	AM_BADD
;
asm_TSB		dw	$0e95
		db	AM_ABSO,$0c,AM_ZERO,$04
		db	AM_BADD
;
asm_TSX		dw	$6695
		db	AM_IMPL,$ba,AM_BADD
;
asm_TXA		dw	$0b35
		db	AM_IMPL,$8a,AM_BADD
;
asm_TXS		dw	$5335
		db	AM_IMPL,$9a,AM_BADD
;
asm_TYA		dw	$0b55
		db	AM_IMPL,$98,AM_BADD
;
asm_WAI		dw	$2858
		db	AM_IMPL,$cb,AM_BADD
;
asm_END		dw	$ffff		;marks end

