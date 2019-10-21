
;System Routines

;-------------------------------------------------------------------------------
; SERIAL_INIT IS A ROUTINE TO INITALIZE THE Z80 DART OR SIO-0 FOR SERIAL
;  TRANSMITTING AND RECEIVING ON BOTH PORT A AND PORT B.  THIS SETS UP
;  BOTH PORTS FOR 57,600 BAUD (WITH 1.8432MHZ CLOCK) WITHOUT HANDSHANKING,
;  AND NO INTERRUPTS. THEN RETURNS.  DESTROYS REGISTERS: A.
;-------------------------------------------------------------------------------
SERIAL_INIT:                    ;WORKING MODEL OF SERIAL INITIALIZATION
                                ;SETTING UP FOR 57600 BAUD
        ;SETUP PORT A
        LD A,00H                ;REQUEST REGISTER #0
        OUT (SIOA_C),A
        LD A,18H                ;LOAD #0 WITH 18H - CHANNEL RESET
	OUT (SIOA_C),A
        NOP

	LD A,04H                ;REQUEST TRANSFER TO REGISTER #4
	OUT (SIOA_C),A
        LD A,SIOA_CLK           ;WRITE #4 WITH X/32 CLOCK 1X STOP BIT
        OUT (SIOA_C),A          ;  AND NO PARITY

        LD A,03H                ;REQUEST TRANSFER TO REGISTER #3
        OUT (SIOA_C),A
        LD A,0C1H
        OUT (SIOA_C),A          ;WRITE #3 WITH C1H - RECEIVER 8 BITS & RX ENABLE

        LD A,05H                ;REQUEST TRANSFER TO REGISTER #5
        OUT (SIOA_C),A
        LD A,068H
        OUT (SIOA_C),A          ;WRITE #5 WITH 60H - TRANSMIT 8 BITS & TX ENABLE

        ;SETUP PORT B
        LD A,00H                ;REQUEST REGISTER #0
        OUT (SIOB_C),A
        LD A,18H                ;LOAD #0 WITH 18H - CHANNEL RESET
	OUT (SIOB_C),A
        NOP

	LD A,04H                ;REQUEST TRANSFER TO REGISTER #4
	OUT (SIOB_C),A
        LD A,SIOB_CLK           ;WRITE #4 WITH X/32 CLOCK 1X STOP BIT
        OUT (SIOB_C),A          ;  AND NO PARITY

        LD A,03H                ;REQUEST TRANSFER TO REGISTER #3
        OUT (SIOB_C),A
        LD A,0C1H
        OUT (SIOB_C),A          ;WRITE #3 WITH C1H - RECEIVER 8 BITS & RX ENABLE

        LD A,05H                ;REQUEST TRANSFER TO REGISTER #5
        OUT (SIOB_C),A
        LD A,068H
        OUT (SIOB_C),A          ;WRITE #5 WITH 60H - TRANSMIT 8 BITS & TX ENABLE

        RET

;-------------------------------------------------------------------------------
; PIO_INIT IS A ROUTINE FOR SETTING THE PIO UP FOR THE G80-UVK COMPUTER.
;-------------------------------------------------------------------------------
PIO_INIT:
        IF (BOARD = 1)
        LD A,82H
        OUT (PIOCMD),A
        RET
        ENDIF
;-------------------------------------------------------------------------------
; RAMCLR IS A FUNCTION THAT CLEARS THE RAM FROM BOTTOM TO TOP.
;  IT LOADS THE ADDRESS INTO B&C AND LOADS THE ADDRESS WITH
;  00h UNTIL THE ADDRESS REACHES FAF9h (LEAVING THE STACK INTACT), THEN CLEARS
;  THE MEMORY ABOVE THE STACK, THEN RETURNS.
;  IT DESTROYS: A,B & C REGISTERS
;-------------------------------------------------------------------------------
RAM_CLR:
        LD HL,MEMORY_CLR_MSG
        CALL PRINT_STRING
        LD  BC,ROM_TOP
RAM_CLRL:
	INC BC
	LD A, 0FFH
    	LD (BC),A
        LD A,0FAH
	SUB B
	JR NZ,RAM_CLRL
	LD A, 0F9H
    	SUB C
    	JR NZ ,RAM_CLRL
        LD HL,DONE_MSG
        CALL PRINT_STRING
        CALL PRINT_PROMPT
        RET

;-------------------------------------------------------------------------------
; DELAY IS A FUNCTION THAT BURNS 1,499,992 CLOCK CYCLES.
;  AT 6MHZ [(57,692 LOOPS X 26 CLOCKS CYCLES) / 6,000,000] = 0.249998 SECONDS
;  THIS IS A GENERAL PURPOSE DELAY TIMER THAT CAN BE USED TO DEBOUNCE INPUTS,
;  OR ANY OTHER APPLICATION WHERE A DELAY IS NEEDED.
;-------------------------------------------------------------------------------
DELAY:
        PUSH AF
        PUSH BC
        LD  BC,0E15CH           ; 57,692 LOOPS
DELAYL:
	DEC BC
	LD  A,C
	OR  B
	JR  NZ,DELAYL
        POP BC
        POP AF
	RET
;-------------------------------------------------------------------------------
; HALF_DELAY IS A FUNCTION THAT IS FUNCTIONALLY IDENTICAL TO DELAY.
;  IT IS DESIGNED TO BURN 749,996 CLOCK CYCLES.
;  AT 6MHZ [(28,846 LOOPS X 26 CLOCK CYCLES) / 6,000,000] = 0.124999 SECONDS
; DELAY OF 1 MILLISECOND
;-------------------------------------------------------------------------------
MILLI_DLY:
        PUSH AF
        PUSH BC
        LD  BC,00E7H           ; 6006 INSTRUCTIONS
MILLI_DLYL:
	DEC BC
	LD  A,C
	OR  B
	JR  NZ,MILLI_DLYL
        POP BC
        POP AF
	RET
;-------------------------------------------------------------------------------
; BUF_CLR IS A FUNCTION THAT CLEARS THE BUFFER FROM BOTTOM TO TOP.
;  IT LOADS THE ADDRESS INTO B&C AND LOADS THE ADDRESS WITH
;  00h UNTIL THE ADDRESS REACHES FFFFh, THEN RETURNS.
;-------------------------------------------------------------------------------
BUF_CLR:
        PUSH AF                 ;SAVE THE REGISTERS
        PUSH BC
        LD  BC,BUF_POINTER      ;LOAD UP THE POINTER ADDRESS
BUF_CLRL:
	INC BC                  ;INCREMENT THE COUNTER
	LD A, 00H               ;LOAD BYTE TO FILL WITH, AND WRITE
    	LD (BC),A
        LD A,0FFH               ;NOW CHECK IF END OF BUFFER
	SUB C
	JR NZ,BUF_CLRL          ;IF NOT DO AGAIN
        LD BC,BUF_POINTER       ;IF YES RELOAD THE POINTER ADDRESS
        LD A,01H
        LD (BC),A               ;WRITE THE POINTER.
        POP BC
        POP AF
	RET
;-------------------------------------------------------------------------------
; BUF_WRITE IS THE ROUTINE FOR WRITING TO THE KEYBOARD BUFFER FROM REGISTER A.
;  IT EXPECTS THE CHARACTER TO BE IN REGISTER A, AND ALSO CHECKS TO MAKE SURE
;  THAT THE BUFFER IS NOT GOING TO OVERFLOW.
;-------------------------------------------------------------------------------
BUF_WRITE:
        PUSH AF                 ;SAVE THE REGISTERS
        PUSH HL
        PUSH BC

        LD B,A                  ;SAVE THE CHARACTER
        LD C,CR
        SUB C                   ;CHECK IF CARRIAGE RETURN
        JP Z,BUF_RESTORE


        LD A,B                  ;RESTORE THE BYTE
        LD C,LF
        SUB C                   ;NOW CHECK IF LINE FEED
        JP Z,BUF_RESTORE

        LD A,B
        LD C,BKSP
        SUB C
        JP Z,BUF_BACKSPACE

        LD A,B                  ;RESTORE THE BYTE
        CALL PRINT_CHAR         ;ECHO THE CHARACTER BACK TO TERMINAL

        CALL BUF_LOWERCASE_UPPER ;CALL ROUTINE TO CONVERT THE BYTE TO UPPERCASE

        LD HL,BUF_POINTER       ;LOAD UP THE POINTER
        LD BC,0000H             ;ZERO THE REGISTER, SO THAT THERE IS NO ERROR
        LD C,(HL)
        ADD HL,BC               ;DETERMINE BUFFER LOCATION, STORES IN HL
BUF_WR_CHK:
        LD B,A                  ;SAVE THE BYTE TO BE WRITTEN
        LD A,0FFH               ;LOAD TOP OF BUFFER.
        LD C,L                  ;COMPARE
        SUB C
        JP Z,OVERFLOW           ;IF OVERFLOW, GO TO OVERFLOW ROUTINE
BUF_WR:
        LD A,B                  ;RESTORE THE BYTE
        LD (HL),A               ;WRITE THE BYTE TO THE BUFFER
        LD HL,BUF_POINTER
        LD A,(HL)               ;LOAD THE POINTER
        INC A                   ;INC THE POINTER
        LD (HL),A               ;STORE THE POINTER
        POP BC
        POP HL                  ;RESTORE THE REGISTERS
        POP AF
        RET

BUF_RESTORE:
        LD A,B
        CALL PRINT_CHAR         ;ECHO THE CHARACTER

        LD HL,BUF_POINTER       ;LOAD UP THE POINTER
        LD BC,0000H             ;ZERO THE REGISTER, SO THAT THERE IS NO ERROR
        LD C,(HL)
        ADD HL,BC               ;DETERMINE BUFFER LOCATION, STORES IN HL
        LD A,SPACE
        LD (HL),A               ;WRITE A SPACE SO THAT CMD RECOG CAN DETERMINE

        POP BC                  ;RESTORE THE REGISTERS
        POP HL
        POP AF
        RET                     ;RETURN

BUF_BACKSPACE:
        LD HL,BUF_POINTER       ;FIRST, TEST IF THERE IS SOMETHING TO DELETE
        LD A,(HL)
        LD C,01H
        SUB C
        JP Z,BUF_BACKSPACE_RET  ;RETURN IF SO.
        IF (SERIAL = 0)
        CALL TXA_RDY
        ENDIF
        IF (SERIAL = 1)
        CALL TXB_RDY
        ENDIF
        LD A,B
        CALL PRINT_CHAR         ;SEND THE BACKSPACE TO THE TERMINAL
        IF (SERIAL = 0)
        CALL TXA_RDY
        ENDIF
        IF (SERIAL = 1)
        CALL TXB_RDY
        ENDIF
        LD A,SPACE
        CALL PRINT_CHAR
        IF (SERIAL = 0)
        CALL TXA_RDY
        ENDIF
        IF (SERIAL = 1)
        CALL TXB_RDY
        ENDIF
        LD A,B
        CALL PRINT_CHAR
        LD A,00H
        LD BC,0000H             ;ZERO THE REGISTER, SO THAT THERE IS NO ERROR
        LD C,(HL)
        ADD HL,BC
        LD (HL),A               ;CLEAR THE ITEM FROM THE BUFFER
        LD HL,BUF_POINTER
        LD A,(HL)               ;NOW ADJUST THE POINTER
        DEC A
        LD (HL),A
BUF_BACKSPACE_RET:
        POP BC
        POP HL                  ;RESTORE REGISTERS AND RETURN
        POP AF
        RET

BUF_LOWERCASE_UPPER:            ;CONVERT TO UPPERCASE, OR RETURN IF UPPER
        LD C,061H
        SUB C
        JP M,BUF_UPPER_RETURN   ;RETURN IF UPPER
        LD A,B
        LD C,020H
        SUB C
        RET
BUF_UPPER_RETURN:
        LD A,B                  ;RESTORE THE CHARACTER THEN RETURN
        RET
;-------------------------------------------------------------------------------
; OVERFLOW IS THE ROUTINE TO ACKNOWLEDGE THAT THE BUFFER HAS OVERFLOWED, INFORM
;  THE USER OF THE OVERFLOW, CLEAR THE BUFFER, RESETS THE POINTER, RESET THE
;  STACK, AND RETURN TO THE MAIN PROGRAM LOOP. THE SYSTEM ESSENTIALLY RESETS TO
;  THE PROMPT.
;-------------------------------------------------------------------------------
OVERFLOW:
        LD HL,OVERFLOW_ERROR_MSG
        CALL PRINT_STRING
        CALL BUF_CLR
        LD SP,STACK
        CALL PRINT_PROMPT
        JP MAIN_LOOP
;-------------------------------------------------------------------------------
; PRINT_CHAR IS A ROUTINE THAT PRINTS A CHARACTER TO SERIAL PORT A.
;  IT CALLS TXA_RDY TO SEE IF THE SERIAL PORT IS READY TO TRANSMIT, THEN
;  SENDS WHATEVER CHARACTER IS IN REGISTER A.
;-------------------------------------------------------------------------------
PRINT_CHAR:
        IF (BOARD = 0)
        PUSH AF
        PUSH BC
        IF (SERIAL = 0)
        CALL TXA_RDY            ; CHECK IF READY TO SEND
        ENDIF
        IF (SERIAL = 1)
        CALL TXB_RDY
        ENDIF
        POP BC
        POP AF
        IF (SERIAL = 0)
        OUT (SIOA_D),A          ; PRINT IT
        ENDIF
        IF (SERIAL = 1)
        OUT (SIOB_D),A
        ENDIF
        RET
        ENDIF

        IF (BOARD = 1)
        PUSH AF                 ;Save the Registers
        PUSH BC
        OUT (PIOA),A            ;Latch the data
PRINT_CHAR2:
        IN A,(PIOB)             ;Get Status Byte Value
        LD C,01H
        AND C                   ;Mask the bit off.
        CP 00H                  ;Is it a 1 or 0?
        JR Z,PRINT_CHAR3        ;Move on if 0.
        LD A,00H                ;If not make it 0.
        JR PRINT_CHAR4
PRINT_CHAR3:
        LD A,01H                ;Make it a 1.
PRINT_CHAR4:
        LD C,0FEH               ;Unmask the bit.
        OR C
        OUT (PIOC),A            ;Flip the bit.
PRINT_CHAR5:
        IN A,(PIOB)             ;Get the Status Byte
        LD C,03H
        AND C                   ;Mask it off
        CP 03H                  ;Acknowledged?
        JR Z,PRINT_CHAR6        ;If so go on.
        CP 00H
        JR Z,PRINT_CHAR6
        JR PRINT_CHAR5          ;If not, try again.
PRINT_CHAR6:
        POP BC
        POP AF
        RET
        ENDIF
;-------------------------------------------------------------------------------
; PRINT_HEX IS A ROUTINE THAT CONVERTS A NUMBER TO THE ASCII REPRESENTATION
;  OF THE NUMBER, AND SENDS THE CHARACTERS TO THE PRINT_CHAR ROUTINE TO BE
;  SENT OVER SERIAL.  IT EXPECTS THE NUMBER TO PRINT TO BE STORED IN A. I HAVE
;  MADE MODIFICATIONS TO THE CODE TO ALLOW IT TO RUN ON THE G80. THIS CODE IS
;  AVAILABLE ON SEVERAL PLACES THROUGHOUT THE WEB, AND I DO NOT KNOW IF THE
;  ORIGINAL AUTHOR'S NAME HAS BEEN LOST TO TIME. THE VERSION I USED IS BELOW.
;  ORIGIN:  WWW.KNOERIG.DE/ELEKTRONIK/Z80/BILDER/MONITOR.ASM
;-------------------------------------------------------------------------------
PRINT_HEX:
        PUSH AF
        PUSH BC
        PUSH DE
        LD B,A          ;STORE THE NUMBER
        CALL PRINT_HEX_1
        LD A,B          ;RESTORE THE NUMBER
        CALL PRINT_HEX_3
        POP DE
        POP BC
        POP AF
        RET
PRINT_HEX_1:
        RRA
        RRA
        RRA
        RRA
PRINT_HEX_2:
        OR 0F0H
        DAA
        ADD A,0A0H
        ADC A,040H
        CALL PRINT_CHAR
        ;INC DE         ;I DO NOT THINK THIS IS NEEDED, IF NOT, PRINT_HEX_3
        RET             ;IS NOT NEEDED EITHER.
PRINT_HEX_3:
        OR 0F0H
        DAA
        ADD A,0A0H
        ADC A,040H
        CALL PRINT_CHAR
        RET
;-------------------------------------------------------------------------------
; PRINT_STRING IS A ROUTINE THAT PRINTS A STRING TO SERIAL PORT A.
;  IT CALLS TXA_RDY TO SEE IF THE SERIAL PORT IS READY TO TRANSMIT, LOADS
;  A CHARACTER FROM THE MEMORY ADDRESS POINTED TO BY HL, CHECKS IF IT IS 00H,
;  RETURNS IF IT IS 00H, IF NOT IT SENDS THE CHARACTER, INCREMENTS HL,
;  THEN JUMPS BACK TO THE BEGINNING.
;-------------------------------------------------------------------------------
PRINT_STRING:
        IF (BOARD = 0)
        PUSH AF
        PUSH BC
        IF (SERIAL = 0)
        CALL TXA_RDY            ;CHECK IF READY TO SEND
        ENDIF
        IF (SERIAL = 1)
        CALL TXB_RDY
        ENDIF
        POP BC
        POP AF
        ENDIF
        LD A,(HL)               ;GET CHARACTER
        OR A
        RET Z                   ;RETURN IF ZERO
        CALL PRINT_CHAR         ;SEND CHARACTER
        INC HL
        JR PRINT_STRING         ;LOOP FOR NEXT BYTE
;-------------------------------------------------------------------------------
; TX*_RDY IS A ROUTINE THAT CHECKS THE STATUS OF THE SERIAL PORT A TO SEE IF
;  THE PORT IS DONE TRANSMITTING THE PREVIOUS BYTE.  IT READS THE STATUS BYTE
;  OF PORT A, ROTATES RIGHT TWICE, THEN ANDS WITH 01h AND SUBS 01h TO DETERMINE
;  IF THE TRANSMIT BUSY FLAG IS SET.  IF NOT IT RETURNS, IF IT IS SET IT
;  CONTINUES TO CHECK BY LOOPING.
;  DESTROYS A & C.
;-------------------------------------------------------------------------------
TXA_RDY:
        LD A,00H
        OUT (SIOA_C),A          ;SELECT REGISTER 0
        IN A,(SIOA_C)           ;READ REGISTER 0
        RRC A
        RRC A
        LD C,01H                ;ROTATE, AND, THEN SUB
        AND C
        SUB C
        RET Z                   ;RETURN IF AVAILABLE
        JR TXA_RDY
TXB_RDY:
        LD A,00H
        OUT (SIOB_C),A          ;SELECT REGISTER 0
        IN A,(SIOB_C)           ;READ REGISTER 0
        RRC A
        RRC A
        LD C,01H                ;ROTATE, AND, THEN SUB
        AND C
        SUB C
        RET Z                   ;RETURN IF AVAILABLE
        JR TXB_RDY
;-------------------------------------------------------------------------------
; RX*_RDY IS A ROUTINE THAT CHECKS THE STATUS OF THE SERIAL PORT A TO SEE IF
;  THE PORT HAS RECEIVED A BYTE.  IT READS THE STATUS BYTE OF PORT A,
;  ANDS WITH 01h AND SUBS 01h. THE RESULT IS THEN RETURNED TO THE CALLER.
;  DESTROYS REGISTERS: A & C.
;-------------------------------------------------------------------------------
RXA_RDY:
        LD A,00H                ;SETUP THE STATUS REGISTER
        OUT (SIOA_C),A
        IN A,(SIOA_C)           ;LOAD THE STATUS BYTE
        LD C,01H                ;LOAD BYTE TO COMPARE THE BIT, AND COMPARE
        AND C
        SUB C
        RET
RXB_RDY:
        LD A,00H                ;SETUP THE STATUS REGISTER
        OUT (SIOB_C),A
        IN A,(SIOB_C)           ;LOAD THE STATUS BYTE
        LD C,01H                ;LOAD BYTE TO COMPARE THE BIT, AND COMPARE
        AND C
        SUB C
        RET
;-------------------------------------------------------------------------------
; GET_KEY SIMPLY GETS THE KEY PRESS IF AVAILABLE.
;-------------------------------------------------------------------------------
GET_KEY:
        IF (BOARD = 0)          ;G80-S/USB VERSION
        IF (SERIAL = 0)
        CALL RXA_RDY
        ENDIF
        IF (SERIAL = 1)
        CALL RXB_RDY
        ENDIF
        JR NZ, GET_KEY
        IF (SERIAL = 0)
        IN A,(SIOA_D)
        ENDIF
        IF (SERIAL = 1)
        IN A,(SIOB_D)
        ENDIF
        RET
        ENDIF

        IF (BOARD = 1)          ;G80-UVK VERSION
        IF (SERIAL = 0)
        CALL RXA_RDY
        ENDIF
        IF (SERIAL = 1)
        CALL RXB_RDY
        ENDIF
        JR NZ, GET_KEY
        IF (SERIAL = 0)
        IN A,(SIOA_D)
        ENDIF
        IF (SERIAL = 1)
        IN A,(SIOB_D)
        ENDIF
        RET
        ENDIF
;-------------------------------------------------------------------------------
; PRINT_PROMPT DOES EXACTLY WHAT IT SAYS, IT PRINTS A PROMPT TO SERIAL
;  PORT A, THEN RETURNS.
;  DESTROYS A.
;-------------------------------------------------------------------------------
PRINT_PROMPT:
        LD A,CR
        CALL PRINT_CHAR
        LD A,LF
        CALL PRINT_CHAR
        LD A,'>'               ;PRINT A ">"
        CALL PRINT_CHAR
        CALL BUF_CLR
        RET
;-------------------------------------------------------------------------------
; ASCIIHEX_TO_BYTE IS A ROUTINE THAT CONVERTS TWO ASCII BYTES REPRESENTING A HEX
;  NUMBER IN DE TO THE BINARY NUMBER TO BE RETURNED IN THE ACCUMULATOR.
;  THE D REGISTER SHOULD BE THE MOST SIGNIFICANT NIBBLE, AND THE E REGISTER
;  SHOULD BE THE LEAST SIGNIFICANT NIBBLE.  THIS CODE IS A MODIFIED VERSION
;  OF SOME CODE I FOUND FLOATING AROUND ON THE INTERNET.  I DO NOT KNOW THE
;  SOURCE OF THE ORIGINAL CODE.
;-------------------------------------------------------------------------------
ASCIIHEX_TO_BYTE:
        PUSH BC                 ;SAVE REGISTERS
        LD A,D                  ;LOAD UPPER CHARACTER
        CALL CONVERT_HEX_VAL    ;CONVERT THE CHARACTER
        RLA
        RLA
        RLA
        RLA
        LD B,A                  ;STORE THE FIRST NIBBLE
        LD A,E                  ;GET SECOND CHARACTER
        CALL CONVERT_HEX_VAL    ;CONVERT THE CHARACTER
        ADD A,B                 ;ADD THE TWO NIBBLES
        POP BC
        RET
;-------------------------------------------------------------------------------
; CONVERTS THE ASCII CHARACTER IN A TO IT'S HEX VALUE IN A, ERROR RETURNS 0FFH
;-------------------------------------------------------------------------------
CONVERT_HEX_VAL:
        CP 'G'                  ;GREATER THAN "F"
        JP P,CONVERT_HEX_ERROR    ;IF SO, ERROR.
        CP '0'                  ;LESS THAN "ZERO"
        JP M,CONVERT_HEX_ERROR    ;IF SO, ERROR.
        CP 03AH                 ;LESS THAN OR EQUAL TO "9"
        JP M,CONVERT_MASK         ;IF SO, CONVERT AND RETURN.
        CP 'A'                  ;LESS THAN "A"
        JP M,CONVERT_HEX_ERROR    ;IF SO, ERROR.
        SUB 037H                ;MUST BE "A" TO "F", CONVERT.
        RET
CONVERT_MASK:
        AND 0FH
        RET
CONVERT_HEX_ERROR:
        LD A,0FFH               ;IF ERROR, RETURN 0FFH
        RET
;-------------------------------------------------------------------------------
