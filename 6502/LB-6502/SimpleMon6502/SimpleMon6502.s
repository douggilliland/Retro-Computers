; SimpleMon6502 - Simple Monitor for the 6502
; COMMAND LINE DRIVEN
; 	I = TEST INPUT STRING
; 	D = DUMP HEX MEMORY BLOCK
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
RAMSTART	:= $0
INSTRBUFFER	:= $400	; RESERVE 64 BYTES FOR INPUT STRING $400-$43F
VAL16L		:= $440	; 16-BIT VALUE
VAL16H		:= $441
VAL8		:= $442	; 8-BIT VALUE

; VARIOUS DEFINES
CR := $0D ; COMMAND TERMINATION
LF := $0A

.segment "CODE"
.org $C000

; MACRO TO PASS A 16-BIT ADDRESS TO A FUNCTION AND CALL THE FUNCTION
;	A REGISTER IS THE UPPER 8-BITS OF THE ADDRESS
;	Y REGISTER IS THE LOWER 8-BITS OF THE ADDRESS
;	FNC_NAME IS THE FUNCTION THAT IS CALLED
.macro CALLPASS16 FNC_NAME, ADDR16
	PHA					; SAVE A ON STACK
	TYA					; SAVE Y ON STACK
	PHA
	LDA	#ADDR16/256		; A IS THE UPPER 8-BITS OF THE ADDRESS
	LDY	#ADDR16&255		; Y IS THE LOWER 8-BITS OF THE ADDRESS
	JSR FNC_NAME	
	PLA					; RESTORE Y
	TAY
	PLA					; RESTORE A
.endmacro

.macro SETUPSCRADDR VAL32
	PHA
	LDA	#VAL32&255
	STA SCR16L
	LDA	#VAL32/256
	STA SCR16H
	PLA
.endmacro

.macro PUSHY
	TYA
	PHA
.endmacro

.macro PULLY
	PLA
	TAY
.endmacro

Reset:
	CLD
	SEI
	LDX     #$FF
	TXS
BEGIN_RAM_TEST:
; TEST FIRST LOCATION
	LDA	#$55
	STA	$0
	LDA $0
	CMP #$55
	BNE	RAMFAIL
	LDA	#$AA
	STA	$0
	LDA $0
	CMP #$AA
	BNE	RAMFAIL
; TEST 2ND LOCATION
	LDA	#$55
	STA	$1
	LDA $1
	CMP #$55
	BNE	RAMFAIL
	LDA	#$AA
	STA	$1
	LDA $1
	CMP #$AA
	BNE	RAMFAIL
; TEST PAGE ZERO RAM
;
	LDX	#2
FILLRAMTST:
	TXA
	STA RAMSTART,X
	INX
	CPX	#0
	BNE FILLRAMTST
CHKFILL:
	LDX	#2
CHKNXT:
	TXA
	CMP	RAMSTART,X
	BNE	RAMFAIL
	INX
	CPX	#0
	BNE	CHKNXT
; FILL PAGE ZERO
FILLPAGEZERO:
	LDA #$00
	LDX	#00
LOOPFILLPAGEZERO:
	STA	$0,X
	INX
	CPX	#0
	BNE LOOPFILLPAGEZERO
; FILL THE REST OF THE RAM
FILLRAM:
	LDA	#$00
	STA	$0
	LDX	#1			; PAGE NUMBER, START AT PAGE 1
	LDA #$00		; FILL VALUE
FILLPAGESLOOP:
	STX	$1
FILLCURRENTPAGE:
	STA	($0),Y
	INY
	CPY	#$00
	BNE	FILLCURRENTPAGE
; INCREMENT PAGE COUNT
	INX
	CPX	#80
	BNE	FILLPAGESLOOP
	
; JUMP TO OK
	JMP	RAMOK
; RAMFAIL
RAMFAIL:
	JMP	RAMFAIL
	
RAMOK:
; Setup ACIA
	JSR INITACIA
	CALLPASS16 PRINTSTR, CRLFMsg
; SETUP INPUT BUFFER POINTER
	LDA	#INSTRBUFFER/256		; A IS THE UPPER 8-BITS OF THE ADDRESS
	STA INSTRH
	LDA	#INSTRBUFFER&255		; Y IS THE LOWER 8-BITS OF THE ADDRESS
	STA	INSTRL
; Display startup message
	CALLPASS16 PRINTSTR, StartupMsg
; INTERPRETER LOOP
	LDA	ACIAData			; flush input
LOOP1:
	JSR INPUTSTR
	LDA	INSTRBUFFER
CHKA:
	CMP	#'I'
	BNE	SKIPA
	JSR INSTRTST
	JMP	ENDLOOP
SKIPA:
	CMP #'D'
	BNE SKIPC
	JSR DUMPRTN
	JMP ENDLOOP
SKIPC:
	CMP #'?'
	BNE SKIPD
	CALLPASS16 PRINTSTR, StartupMsg
	CALLPASS16 PRINTSTR, TestInStrMsg
	CALLPASS16 PRINTSTR, TestDumpStrMsg
	JMP ENDLOOP
SKIPD:

; UNKNOWN COMMAND
	CALLPASS16 PRINTSTR, HelpMsg
	JMP ENDLOOP
ENDLOOP:
    JMP	LOOP1

; DUMPRTN - DUMP A PAGE OF MEMORY TO THE SCREEN
; EXAMPLE: D C0XX - DUMP BLOCK $C000-$C0FF
; CONVERT_HEX_STRING_TO_BYTE
;	The address of the string is in SCR16L/SCR16H.
DUMPRTN:
	LDA	#$02		; Start of address part of input string
	STA	SCR16L
	LDA	#$04
	STA	SCR16H
	JSR	CONVERT_HEX_STRING_TO_BYTE
	LDA	VAL8
	STA	SCR16H
	LDA #0
	STA	SCR16L
	CALLPASS16 PRINTSTR, HeaderDumpMsg
	LDY #0			; Y COUNTS THE BUFFER OFFSET
LOOPB2:				; WRITE OUT THE ADDRESS
	TYA
	PHA
	LDA	SCR16H
	JSR PRHEXSTR
	PLA
	TAY
	JSR PRHEXSTR
	LDA #' '
	JSR	PUTCHAR
	LDX #0			; X IS CHARS PER LINE COUNTER
LPBRTN:
	LDA	(SCR16L),Y
	INY
	CPY #00
	BEQ	ENDRTNB
	JSR PRHEXSTR
	LDA #' '
	JSR	PUTCHAR
	INX
	CPX	#16
	BNE	LPBRTN
	CALLPASS16 PRINTSTR, CRLFMsg
	LDA	#0
	BEQ	LOOPB2
	BNE LPBRTN
ENDRTNB:
	LDA	#$FF
	TAY
	LDA	(SCR16L),Y
	JSR PRHEXSTR
	CALLPASS16 PRINTSTR, CRLFMsg
	RTS

; CONVERT_HEX_STRING_TO_BYTE subroutine converts a null-terminated string of 
;	hexadecimal digits to an 8-bit value.
; The address of the string is in SCR16L/SCR16H.
; The subroutine processes each character, converts it from ASCII hex to binary,
;	shifts the current result left by 4 bits (to make room for the next nibble), 
;	and combines it with the new digit.
; If a non-hex character is encountered, the subroutine returns an error value ($99).
CONVERT_HEX_STRING_TO_BYTE:
		LDA     #$00           ; Clear A to start with 0
        STA     VAL8           ; Clear the result variable
        LDA		INSTRBUFFER+2
;		JSR		PUTCHAR
        JSR     HEX_TO_BIN     ; Convert ASCII hex digit to binary
        ASL                    ; Shift left to make room for the next nibble
        ASL
        ASL
        ASL
        STA     VAL8           ; Store the new result
        LDA		INSTRBUFFER+3
;		JSR		PUTCHAR
        JSR     HEX_TO_BIN     ; Convert ASCII hex digit to binary
		ORA		VAL8
		STA		VAL8
;		JSR		PRHEXSTR
		RTS

HEX_TO_BIN:
        CMP     #'0'           ; Compare with '0'
        BCC     HEX_ERROR1     ; If less than '0', it's an error
        CMP     #'9'+1         ; Compare with '9'+1
        BCC     HEX_NUM		   ; If equal to or less then '9', it's a number
        CMP     #'A'           ; Compare with 'A'
        BCC     HEX_ERROR2     ; If less than 'A', it's an error
        CMP     #'F'+1         ; Compare with 'F'+1
        BCS     HEX_ERROR3     ; If greater than 'F', it's an error
		SEC
        SBC     #'A'-10        ; Convert 'A'-'F' to 10-15
        RTS

HEX_NUM:
        SEC
		SBC     #'0'           ; Convert '0'-'9' to 0-9
        RTS

CONVERT_DONE:
        LDA     VAL8           ; Load the final result into A
        RTS                    ; Return from subroutine

HEX_ERROR1:
		CALLPASS16 PRINTSTR, HexErr1Msg
        LDA     #$99           ; Load error value into A
        RTS                    ; Return from subroutine

HEX_ERROR2:
		CALLPASS16 PRINTSTR, HexErr2Msg
        LDA     #$99           ; Load error value into A
        RTS                    ; Return from subroutine

HEX_ERROR3:
		CALLPASS16 PRINTSTR, HexErr3Msg
        LDA     #$99           ; Load error value into A
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
	LDA	(PRSTRL),Y
	CMP #0
	BEQ DONESTR		; If the character is null (end of string), exit
	JSR	PUTCHAR		; Call subroutine to print the character
	INY				; Increment X to point to the next character
	BNE	LPPRSTR		; Repeat the loop (always true since X is 8-bit)
DONESTR:
	PLA
	RTS

INSTRTST:
	CALLPASS16 PRINTSTR, InputStrMsg
	JSR INPUTSTR	; READ IN THE STRING
	CALLPASS16 PRINTSTR, InputStrWasMsg
	CALLPASS16 PRINTSTR, INSTRBUFFER
	CALLPASS16 PRINTSTR, CRLFMsg
	RTS

PRHEXSTR:
        PHA                    ; Push A onto the stack to save its value
        PHA                    ; Push A onto the stack to save its value
        LSR                    ; Shift right to get the high nibble
        LSR
        LSR
        LSR
        JSR     PRINT_NIBBLE   ; Print the high nibble
        PLA                    ; Pull A from the stack to restore its value
        AND     #$0F           ; Mask out the high nibble
        JSR     PRINT_NIBBLE   ; Print the low nibble
        PLA                    ; Pull A from the stack to restore its value
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
	.byte	$0D,$0A,"Simple Monitor 6502 v1.0",$0D,$0A,$00
HelpMsg:
	.byte	"I-TEST INPUT STRING, D-DUMP HEX, H-TEST HEX STR, ?-DETAILED HELP",$0D,$0A,$00
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
HeaderDumpMsg:
	.byte	$0D,$0A,"ADDR 0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F",$0D,$0A,$00
HexErr1Msg:
	.byte	$0D,$0A,"Hex Error (1)",$0D,$0A,$00
HexErr2Msg:
	.byte	$0D,$0A,"Hex Error (2)",$0D,$0A,$00
HexErr3Msg:
	.byte	$0D,$0A,"Hex Error (3)",$0D,$0A,$00
TestInStrMsg:
	.byte " I-Test Input String (type and show string)",$0D,$0A,$00
TestDumpStrMsg:
	.byte " D-Dump Memory Block (Ex: DA0 dumps block $DA-$DAFF",$0D,$0A,$00
.segment "VECTS"
.org $FFFA
	.word	Reset		; NMI 
	.word	Reset		; RESET 
	.word	Reset		; IRQ 
