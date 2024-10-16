; ReadStringTest.asm
; Minimal monitor program used for hardware testing

; Define the ACIA control and data register addresses
ACIA_CTRL   .EQU 80H  ; Control register address
ACIA_DATA   .EQU 81H  ; Data register address

; Define the initialization values
ACIA_RESET  .EQU 03H	; Master reset
ACIA_INIT   .EQU 15H	; Disable receive interrupt
						; Set RTS low and transmit interrupt disabled
						; 8 data bits
						; No parity
						; 1 stop bit;
						; /1 clock (115200 baud with 1.8432 MHz clock)

; Define the reset vector address
RESET_VECTOR .EQU 0000H

CR          .EQU     0DH
LF          .EQU     0AH

; RESET VECTOR GOES TO JUMP TO START
	.ORG RESET_VECTOR
	JP START          ; Jump to the start of the program

; START OF THE CODE
START:
	DI                	; Disable interrupts

	LD SP, 0FFFFH        ; Load the Stack Pointer with the top address of RAM (64K)
	
	LD A, ACIA_RESET	; Reset ACIA command
	OUT (ACIA_CTRL), A	; Write to the control register

	LD A, ACIA_INIT		; Load the initialization value into register A
	OUT (ACIA_CTRL), A	; Write to the control register

; Print the banner/prompt
	LD HL, MESSAGE		; Load the address of the message into HL
	CALL PRINT			; Call the print subroutine

; Interpreter loop
INTERP_LP:
    LD DE, IN_BUFF      ; Load the address of the buffer into DE
    CALL READ_STRING    ; Call the routine to read the string	
	LD HL, CRLF_MSG		; Pass the pointer to the CRLF message in HL register
	CALL PRINT			; Call the print subroutine
    LD DE, IN_BUFF      ; Load the address of the buffer into DE
	LD A, (DE)
	CP 'D'				; Dump Command Routine
	JR Z, DUMP_RTN
	CP 'L'				; LED Control Routine
	JR Z, LED_RTN
	CP 'X'				; X Command
	JR Z, X_RTN
	CP '?'				; Help Command
	JR Z, HLP_RTN
	LD HL, UNK_MSG		; Load the address of the message into HL
	CALL PRINT			; Call the print subroutine
	JR	INTERP_LP
	
; Turn LED On/Off Command
;	L0 - Turn off LED
;	L1 - Turn on LED
LED_RTN:
    LD DE, IN_BUFF+1    ; Load the address of the buffer into DE
	LD A, (DE)			; GET THE 2ND CHAR IN THE INPUT STRING
	LD HL, 00000H		; STORE THE CHAR TO THE LED
	LD (HL), A
	JR	INTERP_LP

; Dump memory block
; D PP - Dump page PP to the serial port
DUMP_RTN:
	LD HL, DUMP_MSG		; Load the address of the message into HL
	CALL PRINT			; Call the print subroutine
	CALL GET_DUMP_ADDR
	JR	INTERP_LP

; X Example function
X_RTN:
	LD HL, XRTN_MSG		; Load the address of the message into HL
	CALL PRINT			; Call the print subroutine
	LD A, 05AH
	CALL PRINT_HEX
	LD A, ' '
	CALL WRITE_CHAR
	LD A, 0A5H
	CALL PRINT_HEX
	LD HL, CRLF_MSG		; Load the address of the message into HL
	CALL PRINT			; Call the print subroutine
	JR	INTERP_LP

; Print the commands
HLP_RTN:
	LD HL, HELP_MSG		; Load the address of the message into HL
	CALL PRINT			; Call the print subroutine
	JR	INTERP_LP

; Pull the two ascii hex digits from the input buffer
GET_DUMP_ADDR:
	LD	HL, IN_BUFF+2
	LD A, (HL)
	CALL CONVERT_CHAR
	LD B, A
	LD	HL, IN_BUFF+3
	LD A, (HL)
	CALL CONVERT_CHAR
	LD C, A
	RET

; CONVERT_CHAR - Convert an ASCII character (0-9,A-F) into a nibble value
CONVERT_CHAR:
    CP '0'               ; Compare with '0'
    JR C, INVALID_CHAR   ; Jump if less than '0'
    CP '9' + 1           ; Compare with '9' + 1
    JR NC, CHECK_A_F     ; Jump if not less than '9' + 1
    SUB '0'              ; Convert '0'-'9' to 0-9
    RET
CHECK_A_F:
    CP 'A'               ; Compare with 'A'
    JR C, INVALID_CHAR   ; Jump if less than 'A'
    CP 'F' + 1           ; Compare with 'F' + 1
    JR NC, INVALID_CHAR  ; Jump if not less than 'F' + 1
    SUB 'A' - 10         ; Convert 'A'-'F' to 10-15
    RET
INVALID_CHAR:
    LD A, 0              ; Invalid character, set A to 0
    RET

; Print a byte as two hexadecimal ASCII digits
PRINT_HEX:
    LD D, A             ; Save the byte in D
    SRL A               ; Shift right 4 times to get the high nibble
    SRL A
    SRL A
    SRL A
    CALL NIBBLE_TO_HEX  ; Convert high nibble to ASCII
    CALL WRITE_CHAR     ; Print the high nibble

    LD A, D             ; Restore the byte
    AND 00FH            ; Mask out the high nibble to get the low nibble
    CALL NIBBLE_TO_HEX  ; Convert low nibble to ASCII
    CALL WRITE_CHAR     ; Print the low nibble

    RET

NIBBLE_TO_HEX:
    ADD A, '0'          ; Convert 0-9 to ASCII
    CP '9' + 1          ; If greater than '9'
    JR C, DONE          ; If less than or equal to '9', done
    ADD A, 7            ; Convert A-F to ASCII
DONE:
    RET

; Routine to read a string into buffer
READ_STRING:
    LD B, 00H          	; Initialize B as the string length counter
READ_CHARLP:
	CALL	READ_CHAR
	CALL	WRITE_CHAR
    CP CR             	; Compare with carriage return (Enter key)
    JR Z, END_READ      ; If Enter is pressed, end reading
    LD (DE), A          ; Store the character in the buffer
    INC DE              ; Increment the buffer pointer
    INC B               ; Increment the counter
    JR READ_CHARLP      ; Repeat until Enter is pressed

END_READ:
    LD	A, 00H			; Null-terminate the string
	LD (DE), A
    RET                 ; Return from subroutine

; Subroutine to print a string
PRINT:
	LD A, (HL)			; Load the character pointed to by HL into A
	CP 0          		; Compare A with 0 (end of string)
	RET Z         		; Return if zero (end of string)
	CALL WRITE_CHAR		; Write out the character
	INC HL				; Increment HL to point to the next character
	JR PRINT			; Repeat

; Routine to write a character to the ACIA
WRITE_CHAR:
	PUSH AF				; Preserve the A register
WAIT_TX_READY:
	IN A, (ACIA_CTRL)	; Read the status register
	BIT 1, A			; Check if the transmitter is ready
	JR Z, WAIT_TX_READY	; Wait until the transmitter is ready
	POP AF				; Restore the A register
	OUT (ACIA_DATA), A	; Write the character in register A to the data register
	RET

; Routine to read a character from the ACIA
READ_CHAR:
	IN A, (ACIA_CTRL) 	; Read the status register
	BIT 0, A			; Check if data is available
	JR Z, READ_CHAR		; Wait until data is available
	IN A, (ACIA_DATA)	; Read the character from the data register
	RET

; ROM data section
MESSAGE:
    .BYTE	"LB-Z80-01",CR,LF,0
DUMP_MSG:
    .BYTE	"DUMP CMD",CR,LF,0
XRTN_MSG:
    .BYTE	"XRTN CMD",CR,LF,0
UNK_MSG:
    .BYTE	"UNKNOWN CMD",CR,LF,0
HELP_MSG:
    .BYTE	"D-Dump, X-X_routine, L#-SetLED, ?-Help",CR,LF,0
CRLF_MSG:
    .BYTE	CR,LF,0

	.ORG 8000H		; 8KB
; Data section
IN_BUFF: .DS 256          ; Allocate 256 bytes for the buffer

; End of the program
            .END START
