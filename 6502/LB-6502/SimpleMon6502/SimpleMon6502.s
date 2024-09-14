; SimpleMon6502 - Simple Monitor for the 6502

.debuginfo +

.setcpu "6502"
.macpack longbranch

STACK_TOP		:= $FC
ACIA := $A000
ACIAControl := ACIA+0
ACIAStatus := ACIA+0
ACIAData := ACIA+1
; PAGE ZERO LOCATIONS USED
PRSTRL := $10	; POINTER TO PRINT STRING
PRSTRH := $11
INSTRL := $12	; POINTER TO INPUT STRING
INSTRH := $13

;
INSTR := $400	; RESERVE 64 BYTES FOR INPUT STRING

CR := $0D
LF := $0A

.segment "CODE"
.org $C000

.macro printString addr
	LDA	#addr/256		; A IS THE UPPER 8-BITS OF THE ADDRESS
	LDY	#addr&255		; Y IS THE LOWER 8-BITS OF THE ADDRESS
	JSR PRINTSTR	
.endmacro

Reset:
	LDX     #$7F
	TXS
; Setup ACIA
	JSR INITACIA
	printString CRLF
; SETUP INPUT BUFFER POINTER
	LDA	#INSTR/256		; A IS THE UPPER 8-BITS OF THE ADDRESS
	STA INSTRH
	LDA	#INSTR&255		; Y IS THE LOWER 8-BITS OF THE ADDRESS
; Display startup message
	printString StartupMessage
; INTERPRETER LOOP
LOOP1:
	LDA	ACIAData
	JSR GETCHAR
CHKA:
	CMP	#'I'
	BNE	SKIPA
	JSR ARTN
	JMP	ENDLOOP
SKIPA:
	CMP #'D'
	BNE SKIPB
	JSR BRTN
	JMP ENDLOOP
SKIPB:
; UNKNOWN COMMAND
	printString HelpMessage
	JMP ENDLOOP
ENDLOOP:
    JMP	LOOP1

; READ STRING INTO BUFFER
;
INPUTSTR:
	LDY #0
LOOPISTR:
	JSR GETCHAR			; READ THE CHARACTER
	JSR	PUTCHAR			; ECHO OUT THE CHARACTER
	CMP	#CR
	BEQ DONEIS
	CMP	#LF
	BEQ DONEIS
	STA	(INSTRL),Y
	INY
	BNE	LOOPISTR
DONEIS:
	LDA	#0				; NULL TERMINATE STRING
	STA	(INSTRL),Y
	RTS

; PRINTSTR - PRINT STRING
; INPUT POINTER TO STRING IN PAGE ZERO
;	A IS UPPER 8-BITS OF ADDRESS
;	Y IS LOWER 8-BITS OF ADDRESS
PRINTSTR:
	PHA
	STA PRSTRH
	TYA
	STA PRSTRL
	LDY	#0
LPPRSTR:
	LDA (PRSTRL),Y
	CMP #0
	BEQ DONESTR		; If the character is null (end of string), exit
	JSR	PUTCHAR		; Call subroutine to print the character
	INY				; Increment X to point to the next character
	BNE	LPPRSTR		; Repeat the loop (always true since X is 8-bit)
DONESTR:
	PLA
	RTS

ARTN:
	printString InputStr
	JSR INPUTSTR	; READ IN THE STRING
	printString InputStrWas
	printString INSTR
	printString CRLF
	RTS

BRTN:
	LDA $C000
	JSR PRHEXSTR
	LDA #' '
	JSR PUTCHAR
	LDA $C001
	JSR PRHEXSTR
	LDA #' '
	JSR PUTCHAR
	LDA $C002
	JSR PRHEXSTR
	LDA #' '
	JSR PUTCHAR
	LDA $C003
	JSR PRHEXSTR
	printString CRLF
	RTS

PRHEXSTR:
        PHA                    ; Push A onto the stack to save its value
        LSR                    ; Shift right to get the high nibble
        LSR
        LSR
        LSR
        JSR     PRINT_NIBBLE   ; Print the high nibble
        PLA                    ; Pull A from the stack to restore its value
        AND     #$0F           ; Mask out the high nibble
        JSR     PRINT_NIBBLE   ; Print the low nibble
        RTS                    ; Return from subroutine

PRINT_NIBBLE:
        PHA                    ; Push A onto the stack to save its value
        CMP     #$0A           ; Compare with 10
        BCC     PRINT_DIGIT    ; If less than 10, it's a digit
        ADC     #$06           ; If 10 or more, convert to ASCII letter (A-F)
PRINT_DIGIT:
        ADC     #$30           ; Convert to ASCII digit
        JSR     PUTCHAR	       ; Print the character
        PLA                    ; Pull A from the stack to restore its value
        RTS                    ; Return from subroutine
	
; INITIALIZE THE ACIA
INITACIA:
	LDA 	#$03		; Master Reset ACIA
	STA	ACIAControl
	LDA 	#$15		; Set ACIA baud rate, word size and Rx interrupt (to control RTS)
	STA	ACIAControl
	RTS

; GET A CHARACTER FROM THE ACIA
; RETURN CHAR IN A REGISTER
GETCHAR:
	LDA	ACIAStatus
	AND #1
	CMP #1
	BNE GETCHAR
	LDA	ACIAData
	RTS

; PUT A CHARACTER FROM THE A REGISTER OUT THE ACIA
PUTCHAR:
	PHA
LPUTC:
	LDA	ACIAStatus
	AND #2
	CMP #2
	BNE LPUTC
	PLA
	STA ACIAData
	RTS

StartupMessage:
	.byte	$0D,$0A,"Simple Monitor 6502",$0D,$0A,$00
HelpMessage:
	.byte	"I-TEST INPUT STRING, D-DUMP HEX",$0D,$0A,$00
InputStr:
	.byte	"Input string:",$00
InputStrWas:
	.byte	$0D,$0A,"Input string was:",$00
CRLF:
	.byte	$0D,$0A,$00

.segment "VECTS"
.org $FFFA
	.word	Reset		; NMI 
	.word	Reset		; RESET 
	.word	Reset		; IRQ 
