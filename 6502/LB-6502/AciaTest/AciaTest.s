.debuginfo +

.setcpu "6502"
.macpack longbranch

STACK_TOP		:= $FC
ACIA := $A000
ACIAControl := ACIA+0
ACIAStatus := ACIA+0
ACIAData := ACIA+1

.segment "CODE"
.org $C000

Reset:
	LDX     #$7F
	TXS
; Setup ACIA
	LDA 	#$03		; Master Reset ACIA
	STA	ACIAControl
	LDA 	#$15		; Set ACIA baud rate, word size and Rx interrupt (to control RTS)
	STA	ACIAControl
	NOP
	LDA	ACIAData
LOOP1:
	LDA	ACIAStatus
	AND #1
	CMP #1
	BNE LOOP1
	NOP
	LDA	ACIAData
	NOP
	STA ACIAData
	NOP
    JMP	LOOP1

.segment "VECTS"
.org $FFFA
	.word	Reset		; NMI 
	.word	Reset		; RESET 
	.word	Reset		; IRQ 
