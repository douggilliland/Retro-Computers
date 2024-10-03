; ACIA loopback code

; Define the ACIA control and data register addresses
ACIA_CTRL   .EQU 80H  ; Control register address
ACIA_DATA   .EQU 81H  ; Data register address

; Define the initialization values
ACIA_RESET  .EQU 03H	; Master reset
ACIA_INIT   .EQU 15H	; Disable receive interrupt
						; Set RTS low and transmit interrupt disabled
						; 8 data bits
						; no parity
						; 1 stop bit;
						; /1 clock (115200 baud with 1.8432 MHz clock)

; Define the reset vector address
RESET_VECTOR .EQU 0000H

; Start of the program
            .ORG RESET_VECTOR
            JP START          ; Jump to the start of the program

START:
			DI                	; Disable interrupts
            LD A, ACIA_RESET	; Load the reset value into register A
            OUT (ACIA_CTRL), A	; Write to the control register to reset the ACIA

            LD A, ACIA_INIT   ; Load the initialization value into register A
            OUT (ACIA_CTRL), A ; Write to the control register to initialize the ACIA

; Loop forever to read and write characters
MAIN_LOOP:
            CALL READ_CHAR    ; Read a character
            CALL WRITE_CHAR   ; Write the character that was read
            JR MAIN_LOOP      ; Repeat the loop

; Routine to write a character to the ACIA
WRITE_CHAR:
            PUSH AF           ; Preserve the A register
WAIT_TX_READY:
            IN A, (ACIA_CTRL) ; Read the status register
            BIT 1, A          ; Check if the transmitter is ready
            JR Z, WAIT_TX_READY ; Wait until the transmitter is ready
            POP AF            ; Restore the A register
            OUT (ACIA_DATA), A ; Write the character in register A to the data register
            RET
; Routine to read a character from the ACIA
READ_CHAR:
WAIT_RX_READY:
            IN A, (ACIA_CTRL) ; Read the status register
            BIT 0, A          ; Check if data is available
            JR Z, WAIT_RX_READY ; Wait until data is available
            IN A, (ACIA_DATA) ; Read the character from the data register
            RET

; End of the program
            .END START
