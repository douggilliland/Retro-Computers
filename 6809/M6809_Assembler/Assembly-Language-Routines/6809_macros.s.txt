
	.macro	ABA
		PSHS	B
		ADDA	,S+
	.endm

	.macro	CBA
		PSHS	B
		CMPA	,S+
	.endm

	.macro	CLC
		ANDCC	#$FE
	.endm

	.macro	CLI
		ANDCC	#$EF
	.endm

	.macro	CLV
		ANDCC	#$FD
	.endm

	.macro	CPX	src
;;		CMPX	P
;		CMP	X,S
		CMP	X,src

	.endm

	.macro	DES
		LEAS	-1,S
	.endm

	.macro	DEX
		LEAX	-1,X
	.endm

	.macro	INS
		LEAS	1,S
	.endm

	.macro	INX
		LEAX	1,X
	.endm

	.macro	LDAA	val
		LDA	val
	.endm

	.macro	LDAB	val
		LDB	val
	.endm

	.macro	ORAA
		ORA
	.endm

	.macro	ORAB	val
		ORB	val
	.endm

	.macro	PSHA
		PSHS	A
	.endm

	.macro	PSHB
		PSHS	B
	.endm

	.macro	PULA
		PULS	A
	.endm

	.macro	PULB
		PULS	B
	.endm

	.macro	SBA
		PSHS	B
		SUBA	,S+
	.endm

	.macro	SEC
		ORCC	#$01
	.endm

	.macro	SEI
		ORCC	#$10
	.endm

	.macro	SEV
		ORCC	#$02
	.endm

	.macro	STAA
;		STA
		nop
	.endm

	.macro	STAB
;		STB
		nop
	.endm

	.macro	TAB
		TFR	A,B
		TSTA
	.endm

	.macro	TAP
		TFR	A,CC
	.endm

	.macro	TBA
		TFR	B,A
		TSTA
	.endm

	.macro	TPA
		TFR	CC,A
	.endm

	.macro	TSX
		TFR	S,X
	.endm

	.macro	TXS
		TFR	X,S
	.endm

	.macro	WAI
		CWAI	#$FF
	.endm

	org 0
  ABA
  CBA
  CLC
  CLI
  CLV
;  CPX
  DES
  DEX
  INS
  INX
  LDAA
  LDAB
  ORAA
  ORAB
  PSHA
  PSHB
  PULA
  PULB
  SBA
  SEC
  SEI
  SEV
  STAA
  STAB
  TAB
  TAP
  TBA
  TPA
  TSX
  TXS
  WAI

;	CPX	#$DEAD
    
    NOP
	end

