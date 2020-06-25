		TITL	"6800/6801 Cross-Assembler Test Source File"
		PAGE	60
;
; The 6801 opcodes in opcode numerical order:
;
		CPU	6801

IMMEDIATE	EQU	0
OFFSET	EQU	0

DIRECT	ORG	0

EXTENDED	ORG	$100

; $00 - $0F.
						; $00 is undefined.
		NOP
						; $02 - $03 are undefined.
		LSRD
		ASLD
		TAP
		TPA
		INX
		DEX
		CLV
		SEV
		CLC
		SEC
		CLI
		SEI
; $10 - $1F.
		SBA
		CBA
						; $12 - $15 are undefined.
		TAB
		TBA
						; $18 is undefined.
		DAA
						; $1A is undefined.
		ABA
						; $1B - $1F are undefined.
; $20 - $2F.
		BRA	* + 2
		BRN	* + 2
		BHI	* + 2
		BLS	* + 2
		BCC	* + 2
		BCS	* + 2
		BNE	* + 2
		BEQ	* + 2
		BVC	* + 2
		BVS	* + 2
		BPL	* + 2
		BMI	* + 2
		BGE	* + 2
		BLT	* + 2
		BGT	* + 2
		BLE	* + 2
; $30 - $3F.
		TSX
		INS
		PULA
		PULB
		DES
		TXS
		PSHA
		PSHB
		PULX
		RTS
		ABX
		RTI
		PSHX
		MUL
		WAI
		SWI
; $40 - $4F.
		NEGA
						; $41 - $42 are undefined.
		COMA
		LSRA
						; $45 is undefined.
		RORA
		ASRA
		ASLA
		ROLA
		DECA
						; $4B is undefined.
		INCA
		TSTA
						; $5E is undefined.
		CLRA
; $50 - $5F.
		NEGB
						; $51 - $52 are undefined.
		COMB
		LSRB
						; $55 is undefined.
		RORB
		ASRB
		ASLB
		ROLB
		DECB
						; $5B is undefined.
		INCB
		TSTB
						; $5E is undefined.
		CLRB
; $60 - $6F.
		NEG	X, OFFSET
						; $61 - $62 are undefined.
		COM	X, OFFSET
		LSR	X, OFFSET
						; $65 is undefined.
		ROR	X, OFFSET
		ASR	X, OFFSET
		ASL	X, OFFSET
		ROL	X, OFFSET
		DEC	X, OFFSET
						; $6B is undefined.
		INC	X, OFFSET
		TST	X, OFFSET
		JMP	X, OFFSET
		CLR	X, OFFSET
; $70 - $7F.
		NEG	EXTENDED
						; $71 - $72 are undefined.
		COM	EXTENDED
		LSR	EXTENDED
						; $75 is undefined.
		ROR	EXTENDED
		ASR	EXTENDED
		ASL	EXTENDED
		ROL	EXTENDED
		DEC	EXTENDED
						; $7B is undefined.
		INC	EXTENDED
		TST	EXTENDED
		JMP	EXTENDED
		CLR	EXTENDED
; $80 - $8F.
		SUBA	#IMMEDIATE
		CMPA	#IMMEDIATE
		SBCA	#IMMEDIATE
		SUBD	#IMMEDIATE
		ANDA	#IMMEDIATE
		BITA	#IMMEDIATE
		LDAA	#IMMEDIATE
						; $87 is undefined.
		EORA	#IMMEDIATE
		ADCA	#IMMEDIATE
		ORAA	#IMMEDIATE
		ADDA	#IMMEDIATE
		CPX	#IMMEDIATE
		BSR	* + 2
		LDS	#IMMEDIATE
						; $8F is undefined.
; $90 - $9F.
		SUBA	DIRECT
		CMPA	DIRECT
		SBCA	DIRECT
		SUBD	DIRECT
		ANDA	DIRECT
		BITA	DIRECT
		LDAA	DIRECT
		STAA	DIRECT
		EORA	DIRECT
		ADCA	DIRECT
		ORAA	DIRECT
		ADDA	DIRECT
		CPX	DIRECT
		JSR	DIRECT
		LDS	DIRECT
		STS	DIRECT
; $A0 - $AF.
		SUBA	X, OFFSET
		CMPA	X, OFFSET
		SBCA	X, OFFSET
		SUBD	X, OFFSET
		ANDA	X, OFFSET
		BITA	X, OFFSET
		LDAA	X, OFFSET
		STAA	X, OFFSET
		EORA	X, OFFSET
		ADCA	X, OFFSET
		ORAA	X, OFFSET
		ADDA	X, OFFSET
		CPX	X, OFFSET
		JSR	X, OFFSET
		LDS	X, OFFSET
		STS	X, OFFSET
; $B0 - $BF.
		SUBA	EXTENDED
		CMPA	EXTENDED
		SBCA	EXTENDED
		SUBD	EXTENDED
		ANDA	EXTENDED
		BITA	EXTENDED
		LDAA	EXTENDED
		STAA	EXTENDED
		EORA	EXTENDED
		ADCA	EXTENDED
		ORAA	EXTENDED
		ADDA	EXTENDED
		CPX	EXTENDED
		JSR	EXTENDED
		LDS	EXTENDED
		STS	EXTENDED
; $C0 - $CF.
		SUBB	#IMMEDIATE
		CMPB	#IMMEDIATE
		SBCB	#IMMEDIATE
		ADDD	#IMMEDIATE
		ANDB	#IMMEDIATE
		BITB	#IMMEDIATE
		LDAB	#IMMEDIATE
						; $C7 is undefined.
		EORB	#IMMEDIATE
		ADCB	#IMMEDIATE
		ORAB	#IMMEDIATE
		ADDB	#IMMEDIATE
		LDD	#IMMEDIATE
						; $CD is undefined.
		LDX	#IMMEDIATE
						; $CF is undefined.
; $D0 - $DF.
		SUBB	DIRECT
		CMPB	DIRECT
		SBCB	DIRECT
		ADDD	DIRECT
		ANDB	DIRECT
		BITB	DIRECT
		LDAB	DIRECT
		STAB	DIRECT
		EORB	DIRECT
		ADCB	DIRECT
		ORAB	DIRECT
		ADDB	DIRECT
		LDD	DIRECT
		STD	DIRECT
		LDX	DIRECT
		STX	DIRECT
; $E0 - $EF.
		SUBB	X, OFFSET
		CMPB	X, OFFSET
		SBCB	X, OFFSET
		ADDD	X, OFFSET
		ANDB	X, OFFSET
		BITB	X, OFFSET
		LDAB	X, OFFSET
		STAB	X, OFFSET
		EORB	X, OFFSET
		ADCB	X, OFFSET
		ORAB	X, OFFSET
		ADDB	X, OFFSET
		LDD	X, OFFSET
		STD	X, OFFSET
		LDX	X, OFFSET
		STX	X, OFFSET
; $F0 - $FF.
		SUBB	EXTENDED
		CMPB	EXTENDED
		SBCB	EXTENDED
		ADDD	EXTENDED
		ANDB	EXTENDED
		BITB	EXTENDED
		LDAB	EXTENDED
		STAB	EXTENDED
		EORB	EXTENDED
		ADCB	EXTENDED
		ORAB	EXTENDED
		ADDB	EXTENDED
		LDD	EXTENDED
		STD	EXTENDED
		LDX	EXTENDED
		STX	EXTENDED
;
; old Motorola opcodes which seperated A/B from mnemonic
;
            ADD A,1			
		 DEC A 
		 PSH A  		
            AND A,1  		
		INC A
  		PUL A	
            ASL A
  		LDA A,1
  		SBC A,1
              CLR A
  		LSR A	
		STA A  
            CMP A,1
  		ORA A,1 
 		SUB A,1  

;
; Let's test the rest of the pseudo-ops while we're at it:
;
VARIABLE	SET	-1

		IF	VARIABLE
		FCB	-1, , +1
		ELSE
		FCB	+1, , -1
		ENDI

VARIABLE	SET	VARIABLE EQ 0

		IF	VARIABLE
		FDB	, +1
		ELSE
		FDB	, -1
		ENDI
;
;numeric & string constants
;
		RMB	10H	;hex, 16 decimal
		RMB	10O	;octal, 8 decimal
		RMB	10B	;binary, 2 decimal
		RMB	10D	;decimal, 10 decimal
AAA		EQU	255	;hex FF
BBB		EQU	%11000011 ;hex C3
CCC		EQU	@017	;hex 0F
DDD		EQU	$0ff	;hex FF
EEE		EQU	2*2

		FCC	"EXPLOSION"

;
;labels
;
BANANA	NOP
band:		NOP	;lable defined as "band" not "band:"
		BRA	band
		BRA	BAND ;upper/lowercase NOT the same, error

; this is a comment
* is this a comment?
   ; this is a comment
   * this is not a comment (could be an expression)


		END
		