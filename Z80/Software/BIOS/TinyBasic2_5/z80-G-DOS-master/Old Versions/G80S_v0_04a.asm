;----------------------------------------------------
; Project: G80S.zdsp
; Main File: G80S.asm
; Date: 12-Feb-17 19:16:29
;
; Created with zDevStudio - Z80 Development Studio.
; Design and Code by Doug Gabbard (2017)
;----------------------------------------------------

SIOA_D          EQU     00H    ;SIO CHANNEL A DATA REGISTER
SIOA_C          EQU     02H    ;SIO CHANNEL A CONTROL REGISTER
SIOB_D          EQU     01H    ;SIO CHANNEL B DATA REGISTER
SIOB_C          EQU     03H    ;SIO CHANNEL B CONTROL REGISTER

ROM_TOP         EQU     07FFFH
RAM_BOT         EQU     08000H
RAM_TOP         EQU     0FFFFH
STACK           EQU     0FBFFH
BUF_BOT         EQU     0FFDAH
BUF_TOP         EQU     0FFFFH
BUF_POINTER     EQU     0FFD9H



SPACE           EQU     020H            ; Space
CTRLC           EQU     03H             ; Control "C"
CTRLG           EQU     07H             ; Control "G"
BKSP            EQU     08H             ; Back space
LF              EQU     0AH             ; Line feed
CS              EQU     0CH             ; Clear screen
CR              EQU     0DH             ; Carriage return
CTRLO           EQU     0FH             ; Control "O"
CTRLQ	        EQU     011H            ; Control "Q"
CTRLR           EQU     012H            ; Control "R"
CTRLS           EQU     013H            ; Control "S"
CTRLU           EQU     015H            ; Control "U"
ESC             EQU     01BH            ; Escape
DEL             EQU     07FH            ; Delete

;-------------------------------------------------------------------------------
; BEGINNING OF CODE
;-------------------------------------------------------------------------------
                ORG     0000h

BOOT:
        DI
        LD SP,STACK                     ;STACK OCCUPIES FBFF AND BELOW.
        JP INIT                         ;GO INITIALIZE THE SYSTEM.

;-------------------------------------------------------------------------------
; SERIAL MONITOR/OS
;-------------------------------------------------------------------------------
                ORG     0100H
; INIT IS THE ROUTINE THAT SETS UP, OR INITIALIZES, THE PERIPHERALS.
INIT:
        CALL SERIAL_INIT
        LD HL,SIGNON_MSG
        CALL PRINT_STRING
        CALL PRINT_PROMPT

; SERMAIN_LOOP, THE MAIN LOOP FOR THE SERIAL MONITOR.
MAIN_LOOP:
        CALL RXA_RDY
        JR MAIN_LOOP

;-------------------------------------------------------------------------------
; SYSTEM CALLS & SUBROUTINES
;-------------------------------------------------------------------------------

; RAMCLR IS A FUNCTION THAT CLEARS THE RAM FROM BOTTOM TO TOP.
;  IT LOADS THE ADDRESS INTO B&C AND LOADS THE ADDRESS WITH
;  00h UNTIL THE ADDRESS REACHES FBF9h (LEAVING THE STACK INTACT), THEN CLEARS
;  THE MEMORY ABOVE THE STACK, THEN RETURNS.
;  IT DESTROYS: A,B & C REGISTERS
RAM_CLR:
        LD  BC,ROM_TOP
RAM_CLRL:
	INC BC
	LD A, 00H
    	LD (BC),A
        LD A,0FBH
	SUB B
	JR NZ,RAM_CLRL
	LD A, 0F9H
    	SUB C
    	JR NZ ,RAM_CLRL
RAM_CLR2:
        LD BC,STACK+1
RAM_CLRL2:
        LD A,00H
        LD (BC),A
        LD A,0FFH
        SUB B
        JR NZ,RAM_CLRL2
        LD A,0FFH
        SUB C
        JR NZ,RAM_CLRL2
        RET


; DELAY IS A FUNCTION THAT BURNS 1,499,992 CLOCK CYCLES.
;  AT 6MHZ [(57,692 LOOPS X 26 CLOCKS CYCLES) / 6,000,000] = 0.249998 SECONDS
;  THIS IS A GENERAL PURPOSE DELAY TIMER THAT CAN BE USED TO DEBOUNCE INPUTS,
;  OR ANY OTHER APPLICATION WHERE A DELAY IS NEEDED.
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


; HALF_DELAY IS A FUNCTION THAT IS FUNCTIONALLY IDENTICAL TO DELAY.
;  IT IS DESIGNED TO BURN 749,996 CLOCK CYCLES.
;  AT 6MHZ [(28,846 LOOPS X 26 CLOCK CYCLES) / 6,000,000] = 0.124999 SECONDS
HALF_DLY:
        PUSH AF
        PUSH BC
        LD  BC,070AEH           ; 28,846 LOOPS
HALF_DLYL:
	DEC BC
	LD  A,C
	OR  B
	JR  NZ,HALF_DLYL
        POP BC
        POP AF
	RET


; BUF_CLR IS A FUNCTION THAT CLEARS THE BUFFER FROM BOTTOM TO TOP.
;  IT LOADS THE ADDRESS INTO B&C AND LOADS THE ADDRESS WITH
;  00h UNTIL THE ADDRESS REACHES FFFFh, THEN RETURNS.
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

; BUF_WRITE IS THE ROUTINE FOR WRITING TO THE KEYBOARD BUFFER FROM REGISTER A.
;  IT EXPECTS THE CHARACTER TO BE IN REGISTER A, AND ALSO CHECKS TO MAKE SURE
;  THAT THE BUFFER IS NOT GOING TO OVERFLOW.
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
        OUT (SIOA_D),A

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
        OUT (SIOA_D),A          ;ECHO THE CHARACTER
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
        CALL TXA_RDY
        LD A,B
        OUT (SIOA_D),A          ;SEND THE BACKSPACE TO THE TERMINAL
        CALL TXA_RDY
        LD A,SPACE
        OUT (SIOA_D),A
        CALL TXA_RDY
        LD A,B
        OUT (SIOA_D),A
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

BUF_LOWERCASE_UPPER:
        LD C,061H
        SUB C
        JP M,BUF_UPPER_RETURN
        LD A,B
        LD C,020H
        SUB C
        RET
BUF_UPPER_RETURN:
        LD A,B
        RET

; OVERFLOW IS THE ROUTINE TO ACKNOWLEDGE THAT THE BUFFER HAS OVERFLOWED, INFORM
;  THE USER OF THE OVERFLOW, CLEAR THE BUFFER, RESETS THE POINTER, RESET THE
;  STACK, AND RETURN TO THE MAIN PROGRAM LOOP. THE SYSTEM ESSENTIALLY RESETS TO
;  THE PROMPT.
OVERFLOW:
        LD HL,OVERFLOW_ERROR_MSG
        CALL PRINT_STRING
        CALL BUF_CLR
        LD SP,STACK
        CALL PRINT_PROMPT
        JP MAIN_LOOP

;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
; SERIAL SUBROUTINES
;-------------------------------------------------------------------------------



; PRINT_CHAR IS A ROUTINE THAT PRINTS A CHARACTER TO SERIAL PORT A.
;  IT CALLS TXA_RDY TO SEE IF THE SERIAL PORT IS READY TO TRANSMIT, THEN
;  SENDS WHATEVER CHARACTER IS IN REGISTER A.
PRINT_CHAR:
        PUSH AF
        PUSH BC
        CALL TXA_RDY            ; CHECK IF READY TO SEND
        POP BC
        POP AF
        OUT (SIOA_D),A          ; PRINT IT
        RET



; PRINT_STRING IS A ROUTINE THAT PRINTS A STRING TO SERIAL PORT A.
;  IT CALLS TXA_RDY TO SEE IF THE SERIAL PORT IS READY TO TRANSMIT, LOADS
;  A CHARACTER FROM THE MEMORY ADDRESS POINTED TO BY HL, CHECKS IF IT IS 00H,
;  RETURNS IF IT IS 00H, IF NOT IT SENDS THE CHARACTER, INCREMENTS HL,
;  THEN JUMPS BACK TO THE BEGINNING.
PRINT_STRING:
        PUSH AF
        PUSH BC
        CALL TXA_RDY            ;CHECK IF READY TO SEND
        POP BC
        POP AF
        LD A,(HL)               ;GET CHARACTER
        OR A
        RET Z                   ;RETURN IF ZERO
        OUT (SIOA_D),A          ;SEND CHARACTER
        INC HL
        JR PRINT_STRING         ;LOOP FOR NEXT BYTE



; TXA_RDY IS A ROUTINE THAT CHECKS THE STATUS OF THE SERIAL PORT A TO SEE IF
;  THE PORT IS DONE TRANSMITTING THE PREVIOUS BYTE.  IT READS THE STATUS BYTE
;  OF PORT A, ROTATES RIGHT TWICE, THEN ANDS WITH 01h AND SUBS 01h TO DETERMINE
;  IF THE TRANSMIT BUSY FLAG IS SET.  IF NOT IT RETURNS, IF IT IS SET IT
;  CONTINUES TO CHECK BY LOOPING.
;----------------
; DESTROYS A & C.
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



; RXA_RDY IS A ROUTINE THAT CHECKS THE STATUS OF THE SERIAL PORT A TO SEE IF
;  THE PORT HAS RECEIVED A BYTE.  IT READS THE STATUS BYTE OF PORT A,
;  ANDS WITH 01h AND SUBS 01h TO DETERMINE IF THE RECEIVER FLAG IS SET.
;  IF NOT IT RETURNS. IF IT IS SET, IT JUMPS TO GET_KEY.
;  DESTROYS REGISTERS: A & C.
RXA_RDY:
        LD A,00H                ;SETUP THE STATUS REGISTER
        OUT (SIOA_C),A
        IN A,(SIOA_C)           ;LOAD THE STATUS BYTE
        LD C,01H                ;LOAD BYTE TO COMPARE THE BIT, AND COMPARE
        AND C
        SUB C
        RET NZ                  ;RETURN IF NOT SET
        JP GET_KEY



; GET_KEY SIMPLY GETS THE KEY AND JUMPS TO ECHO_CHAR AT THE MOMENT. IN THE
;  FUTURE IT WILL EITHER POINT TO A ROUTINE TO STORE THE CHARACTER IN THE
;  BUFFER AND TEST FOR A COMMAND, OR POINT TO A ROUTINE THAT DOES THIS.
; DESTROYS: A
GET_KEY:
        IN A,(SIOA_D)
        CALL BUF_WRITE
        LD C,LF                 ;
        SUB C
        RET NZ
        JP PRINT_PROMPT         ;
        ;CALL ECHO_CHAR
        ;RET


; ECHO_CHAR TAKES THE BYTE RECEIVED THROUGH SERIAL, LOCATED IN REGISTER A,
;  AND ECHOS IT BACK TO THE SENDER, SO THAT THE CHARACTER MAY BE DISPLAYED
;  ON THE SCREEN. IF LF, CONTINUES ON TO PRINT_PROMPT.
;  DESTROYS A & C.
;
;  CURRENTLY RETURNS WITHOUT STORING THE BYTE.
ECHO_CHAR:
        OUT (SIOA_D),A          ;GET THE BYTE
        LD C,LF                 ;CHECK IF LF
        SUB C
        RET NZ                  ;RETURN IF NOT
        JP PRINT_PROMPT



; PRINT_PROMPT DOES EXACTLY WHAT IT SAYS, IT PRINTS A PROMPT TO SERIAL
;  PORT A, THEN RETURNS.
;  DESTROYS A.
PRINT_PROMPT:
        LD A,03EH               ;PRINT A ">"
        OUT (SIOA_D),A
        CALL BUF_CLR
        RET
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
; INITIALIZATION ROUTINES
;-------------------------------------------------------------------------------

; SERIAL_INIT IS A ROUTINE TO INITALIZE THE Z80 DART OR SIO-0 FOR SERIAL
;  TRANSMITTING AND RECEIVING ON BOTH PORT A AND PORT B.  THIS SETS UP
;  BOTH PORTS FOR 57,600 BAUD (WITH 1.8432MHZ CLOCK) WITHOUT HANDSHANKING,
;  AND NO INTERRUPTS. THEN RETURNS.  DESTROYS REGISTERS: A.
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
        LD A,084H               ;WRITE #4 WITH X/32 CLOCK 1X STOP BIT
        OUT (SIOA_C),A          ;  AND NO PARITY

        LD A,03H                ;REQUEST TRANSFER TO REGISTER #3
        OUT (SIOA_C),A
        LD A,0C1H
        OUT (SIOA_C),A          ;WRITE #3 WITH COH - RECEIVER 8 BITS & RX ENABLE

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
        LD A,084H               ;WRITE #4 WITH X/32 CLOCK 1X STOP BIT
        OUT (SIOB_C),A          ;  AND NO PARITY

        LD A,03H                ;REQUEST TRANSFER TO REGISTER #3
        OUT (SIOB_C),A
        LD A,0C1H
        OUT (SIOB_C),A          ;WRITE #3 WITH COH - RECEIVER 8 BITS & RX ENABLE

        LD A,05H                ;REQUEST TRANSFER TO REGISTER #5
        OUT (SIOB_C),A
        LD A,068H
        OUT (SIOB_C),A          ;WRITE #5 WITH 60H - TRANSMIT 8 BITS & TX ENABLE

        RET
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
; MESSAGES
;-------------------------------------------------------------------------------
SIGNON_MSG:
        DB      CS,CR,LF
        DB      "G80-S Computer by Doug Gabbard - 2017",CR,LF
        DB      "G-DOS Prototype v0.04a",CR,LF,LF,00H

MEMORY_CLR_MSG:
        DB      "CLEARING MEMORY...",CR,LF,00H

STORAGE_CHK_MSG:
        DB      "CHECKING FOR STORAGE...",00H

STORE_NO_FOUND_MSG:
        DB      "STORAGE NOT FOUND.",CR,LF,00H

STORAGE_FOUND_MSG:
        DB      "STORAGE FOUND.",CR,LF,00H

CMD_ERROR_MSG:
        DB      CR,LF
        DB      "  ERROR - NOT RECOGNIZED ",CR,LF,00H

OVERFLOW_ERROR_MSG:
        DB      CR,LF
        DB      "  ERROR - BUFFER OVERFLOW ",CR,LF,00H

LOADING_MSG:
        DB      CR,LF
        DB      " LOADING...",00H

DONE_MSG:
        DB      "DONE.",00H

;-------------------------------------------------------------------------------
