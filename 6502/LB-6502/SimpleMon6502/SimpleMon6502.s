; SimpleMon6502 - Simple Monitor for the 6502
; COMMAND LINE DRIVEN
; 	I = TEST INPUT STRING
; 	D = DUMP HEX
; SOME OF THE CODE WAS WRITTEN BY AI - COPILOT
; BUILD PROCESS USES CC65 TOOLCHAIN UNDER WINDOWS
;	https://cc65.github.io/doc/
; ca65 WAS USED TO ASSEMBLE THE PROGRAM
;	ca65 SimpleMon6502.s -o SimpleMon6502.o -l
; LD65 WAS USED TO LINK THE PROGRAM
;	ld65 -C LB65022.cfg SimpleMon6502.o -o SimpleMon6502.bin
; SREC_CAT WAS USED TO CREATE A .HEX FILE
;	srec_cat.exe SimpleMon6502.bin -binary -o SimpleMon6502.hex -Intel

.debuginfo +

.setcpu "6502"
.macpack longbranch

STACK_TOP		:= $FC

; HARDWARE LOCATIONS
ACIA := $A000
ACIAControl := ACIA+0
ACIAStatus := ACIA+0
ACIAData := ACIA+1

; PAGE ZERO LOCATIONS USED
PRSTRL := $10	; POINTER TO PRINT STRING
PRSTRH := $11
INSTRL := $12	; POINTER TO INPUT STRING
INSTRH := $13
SCR16L := $14	; 16-BIT SCRATCH LOCATION OFTEN USED TO PASS ADDRESSES
SCR16H := $15

; RAM LOCATIONS
INSTRPTR	:= $400	; RESERVE 64 BYTES FOR INPUT STRING $400-$43F
VAL16L		:= $440	; 16-BIT VALUE
VAL16H		:= $441
VAL8		:= $442	; 8-BIT VALUE

; VARIOUS DEFINES
CR := $0D ; COMMAND TERMINATION
LF := $0A

.segment "CODE"
.org $C000

.macro SETUPSCRADDR VAL32
	PHA
	LDA	VAL32/256
	STA SCR16H
	LDA	VAL32&255
	STA SCR16L
	PLA
.endmacro


; MACRO TO PASS A 16-BIT ADDRESS TO A FUNCTION AND CALL THE FUNCTION
;	A REGISTER IS THE UPPER 8-BITS OF THE ADDRESS
;	Y REGISTER IS THE LOWER 8-BITS OF THE ADDRESS
;	FNC_NAME IS THE FUNCTION THAT IS CALLED
.macro CALLPASS16 ADDR32, FNC_NAME
	LDA	#ADDR32/256		; A IS THE UPPER 8-BITS OF THE ADDRESS
	LDY	#ADDR32&255		; Y IS THE LOWER 8-BITS OF THE ADDRESS
	JSR FNC_NAME	
.endmacro

Reset:
	LDX     #$7F
	TXS
; Setup ACIA
	JSR INITACIA
	CALLPASS16 CRLFMsg, PRINTSTR
; SETUP INPUT BUFFER POINTER
	LDA	#INSTRPTR/256		; A IS THE UPPER 8-BITS OF THE ADDRESS
	STA INSTRH
	LDA	#INSTRPTR&255		; Y IS THE LOWER 8-BITS OF THE ADDRESS
; Display startup message
	CALLPASS16 StartupMsg, PRINTSTR
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
	CMP #'H'
	BNE SKIPC
	SETUPSCRADDR TestValu8			; POINTS TO THE STRING
	JSR CONVERT_HEX_STRING_TO_BYTE
	CMP	#$5A
	BNE HCONVERR
	CALLPASS16 FailMsg, PRINTSTR
	JMP ENDLOOP
HCONVERR:
	CALLPASS16 PassMsg, PRINTSTR
	JMP ENDLOOP
SKIPC:
; UNKNOWN COMMAND
	CALLPASS16 TestValu8, PRINTSTR
	JMP ENDLOOP
ENDLOOP:
    JMP	LOOP1

; CONVERT_HEX_STRING_TO_BYTE subroutine converts a null-terminated string of 
;	hexadecimal digits to an 8-bit value.
; The address of the string is in SCR16L/SCR16H.
; The subroutine processes each character, converts it from ASCII hex to binary,
;	shifts the current result left by 4 bits (to make room for the next nibble), 
;	and combines it with the new digit.
; If a non-hex character is encountered, the subroutine returns an error value ($FF).
CONVERT_HEX_STRING_TO_BYTE:
        LDA     #$00           ; Clear A to start with 0
        STA     VAL8           ; Clear the result variable
        LDY     #$00           ; Initialize Y to 0 for indexing

CONVERT_LOOP:
        LDA     (SCR16L),Y     ; Load the next character from the string
        BEQ     CONVERT_DONE   ; If null terminator, we're done
        JSR     HEX_TO_BIN     ; Convert ASCII hex digit to binary
        ASL                    ; Shift left to make room for the next nibble
        ASL
        ASL
        ASL
        ORA     VAL8           ; Combine with the current result
        STA     VAL8           ; Store the new result
        INY                    ; Increment Y to point to the next character
        BNE     CONVERT_LOOP   ; Repeat the loop

CONVERT_DONE:
        LDA     VAL8           ; Load the final result into A
        RTS                    ; Return from subroutine

HEX_TO_BIN:
        CMP     #'0'           ; Compare with '0'
        BCC     HEX_ERROR      ; If less than '0', it's an error
        CMP     #'9'+1         ; Compare with '9'+1
        BCS     HEX_LETTER     ; If greater than '9', check for letters
        SBC     #'0'           ; Convert '0'-'9' to 0-9
        RTS

HEX_LETTER:
        CMP     #'A'           ; Compare with 'A'
        BCC     HEX_ERROR      ; If less than 'A', it's an error
        CMP     #'F'+1         ; Compare with 'F'+1
        BCS     HEX_ERROR      ; If greater than 'F', it's an error
        SBC     #'A'-10        ; Convert 'A'-'F' to 10-15
        RTS

HEX_ERROR:
        LDA     #$FF           ; Load error value into A
        RTS                    ; Return from subroutine

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
	CALLPASS16 InputStrMsg, PRINTSTR
	JSR INPUTSTR	; READ IN THE STRING
	CALLPASS16 InputStrWasMsg, PRINTSTR
	CALLPASS16 INSTRPTR, PRINTSTR
	CALLPASS16 CRLFMsg, PRINTSTR
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
	CALLPASS16 CRLFMsg, PRINTSTR
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

; Strings kept in ROM (constant values)
StartupMsg:
	.byte	$0D,$0A,"Simple Monitor 6502",$0D,$0A,$00
HelpMsg:
	.byte	"I-TEST INPUT STRING, D-DUMP HEX",$0D,$0A,$00
InputStrMsg:
	.byte	"Input string:",$00
InputStrWasMsg:
	.byte	$0D,$0A,"Input string was:",$00
CRLFMsg:
	.byte	$0D,$0A,$00
TestValu8:
	.byte	"5A",$00
FailMsg:
	.byte	$0D,$0A,"FAIL",$0D,$0A,$00
PassMsg:
	.byte	$0D,$0A,"PASS",$0D,$0A,$00


.segment "VECTS"
.org $FFFA
	.word	Reset		; NMI 
	.word	Reset		; RESET 
	.word	Reset		; IRQ 
