;----------------------------------------------------
; Project: G80S.zdsp
; Main File: G80S.asm
; Date: 12-Feb-17 19:16:29
;
; Created with zDevStudio - Z80 Development Studio.
; Design and Code by Doug Gabbard (2017)
;----------------------------------------------------

DWA     MACRO WHERE
        DB   (WHERE SHR 8) + 128
        DB   WHERE AND 0FFH
        ENDM

SIOA_D          EQU     00H    ;SIO CHANNEL A DATA REGISTER
SIOA_C          EQU     02H    ;SIO CHANNEL A CONTROL REGISTER
SIOB_D          EQU     01H    ;SIO CHANNEL B DATA REGISTER
SIOB_C          EQU     03H    ;SIO CHANNEL B CONTROL REGISTER

ROM_TOP         EQU     07FFFH
RAM_BOT         EQU     08000H
RAM_TOP         EQU     0FFFFH
USRSPC_TOP      EQU     0FAFFH
USRSPC_BOT      EQU     08000H
STACK           EQU     0FBFFH
BUF_BOT         EQU     0FFDAH
BUF_TOP         EQU     0FFFFH
BUF_POINTER     EQU     0FFD9H



SPACE           EQU     020H            ; Space
TAB             EQU     09H             ; HORIZONTAL TAB
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

;DEFINES FOR BASIC

STACKB          EQU     0FFFFH          ; STACKB
OCSW            EQU     08000H          ;SWITCH FOR OUTPUT
CURRNT          EQU     OCSW+1          ;POINTS FOR OUTPUT
STKGOS          EQU     OCSW+3          ;SAVES SP IN 'GOSUB'
VARNXT          EQU     OCSW+5          ;TEMP STORAGE
STKINP          EQU     OCSW+7          ;SAVES SP IN 'INPUT'
LOPVAR          EQU     OCSW+9          ;'FOR' LOOP SAVE AREA
LOPINC          EQU     OCSW+11         ;INCREMENT
LOPLMT          EQU     OCSW+13         ;LIMIT
LOPLN           EQU     OCSW+15         ;LINE NUMBER
LOPPT           EQU     OCSW+17         ;TEXT POINTER
RANPNT          EQU     OCSW+19         ;RANDOM NUMBER POINTER
IN_BYTE         EQU     OCSW+21         ;STORE FOR 'IN' COMMAND
CALL_LOC        EQU     OCSW+22
TXTUNF          EQU     OCSW+24         ;->UNFILLED TEXT AREA
TXTBGN          EQU     OCSW+26         ;TEXT SAVE AREA BEGINS

TXTEND          EQU     0FF00H          ;TEXT SAVE AREA ENDS

;-------------------------------------------------------------------------------
; BEGINNING OF CODE
;-------------------------------------------------------------------------------
                ORG     0000h
BOOT:
        DI
        LD SP,STACK                     ;STACK OCCUPIES FBFF AND BELOW.
        JP INIT                         ;GO INITIALIZE THE SYSTEM.

;-------------------------------------------------------------------------------
; ZERO PAGE FOR BASIC
;-------------------------------------------------------------------------------
                ORG     0008H
RST08:  EX (SP),HL                      ;*** TSTC OR RST 08H ***
        RST 28H                         ;IGNORE BLANKS AND
        CP (HL)                         ;TEST CHARACTER
        JP TC1                          ;REST OF THIS IS AT TC1

CRLFB:
        LD A,CR                         ;*** CRLF ***

RST10:  PUSH AF                         ;*** OUTC OR RST 10H ***
        LD A,(OCSW)                     ;PRINT CHARACTER ONLY
        OR A                            ;IF OCSW SWITCH IS ON
        JP OUTC                         ;REST OF THIS AT OUTC

RST18:  CALL EXPR2                      ;*** EXPR OR RST 18H ***
        PUSH HL                         ;EVALUATE AN EXPRESSION
        JP EXPR1                        ;REST OF IT AT EXPR1
        DB 'W'

RST20:  LD A,H                          ;*** COMP OR RST 20H ***
        CP D                            ;COMPARE HL WITH DE
        RET NZ                          ;RETURN CORRECT C AND
        LD A,L                          ;Z FLAGS
        CP E                            ;BUT OLD A IS LOST
        RET
        DB 'AN'

SS1:
RST28:  LD A,(DE)                       ;*** IGNBLK/RST 28H ***
        CP 20H                          ;IGNORE BLANKS
        RET NZ                          ;IN TEXT (WHERE DE->)
        INC DE                          ;AND RETURN THE FIRST
        JP SS1                          ;NON-BLANK CHAR. IN A

RST30:  POP AF                          ;*** FINISH/RST 30H ***
        CALL FIN                        ;CHECK END OF COMMAND
        JP QWHAT                        ;PRINT "WHAT?" IF WRONG
        DB 'G'

RST38:  RST 28H                         ;*** TSTV OR RST 38H ***
        SUB 40H                         ;TEST VARIABLES
        RET C                           ;C:NOT A VARIABLE
        JR NZ,TV1                       ;NOT "@" ARRAY
        INC DE                          ;IT IS THE "@" ARRAY
        CALL PARN                       ;@ SHOULD BE FOLLOWED
        ADD HL,HL                       ;BY (EXPR) AS ITS INDEX
        JR C,QHOW                       ;IS INDEX TOO BIG?
        PUSH DE                         ;WILL IT OVERWRITE
        EX DE,HL                        ;TEXT?
        CALL SIZE                       ;FIND SIZE OF FREE
        RST 20H                         ;AND CHECK THAT
        JP C,ASORRY                     ;IF SO, SAY "SORRY"
        LD HL,VARBGN                    ;IF NOT GET ADDRESS
        CALL SUBDE                      ;OF @(EXPR) AND PUT IT
        POP DE                          ;IN HL
        RET                             ;C FLAG IS CLEARED

TV1:
        CP 1BH                          ;NOT @, IS IT A TO Z?
        CCF                             ;IF NOT RETURN C FLAG
        RET C
        INC DE                          ;IF A THROUGH Z
        LD HL,VARBGN                    ;COMPUTE ADDRESS OF
        RLCA                            ;THAT VARIABLE
        ADD A,L                         ;AND RETURN IT IN HL
        LD L,A                          ;WITH C FLAG CLEARED
        LD A,00H
        ADC A,H
        LD H,A
        RET

TC1:
        INC HL                          ;COMPARE THE BYTE THAT
        JR Z,TC2                        ;FOLLOWS THE RST INST.
        PUSH BC                         ;WITH THE TEXT (DE->)
        LD C,(HL)                       ;IF NOT =, ADD THE 2ND
        LD B,00H                        ;BYTE THAT FOLLOWS THE
        ADD HL,BC                       ;RST TO THE OLD PC
        POP BC                          ;I.E., DO A RELATIVE
        DEC DE                          ;JUMP IF NOT =

TC2:
        INC DE                          ;IF =, SKIP THOSE BYTES
        INC HL                          ;AND CONTINUE
        EX (SP),HL
        RET

TSTNUM:
        LD HL,0000H                     ;*** TSTNUM ***
        LD B,H                          ;TEST IF THE TEXT IS
        RST 28H                         ;A NUMBER

TN1:
        CP 30H                          ;IF NOT, RETURN 0 IN
        RET C                           ;B AND HL
        CP 3AH                          ;IF NUMBERS, CONVERT
        RET NC                          ;TO BINARY IN HL AND
        LD A,0F0H                       ;SET B TO # OF DIGITS
        AND H                           ;IF H>255, THERE IS NO
        JR NZ,QHOW                      ;ROOM FOR NEXT DIGIT
        INC B                           ;B COUNTS # OF DIGITS
        PUSH BC
        LD B,H                          ;HL=10*HL+(NEW DIGIT)
        LD C,L
        ADD HL,HL                       ;WHERE 10* IS DONE BY
        ADD HL,HL                       ;SHIFT AND ADD
        ADD HL,BC
        ADD HL,HL
        LD A,(DE)                       ;AND (DIGIT) IS FROM
        INC DE                          ;STRIPPING THE ASCII
        AND 0FH                         ;CODE
        ADD A,L
        LD L,A
        LD A,00H
        ADC A,H
        LD H,A
        POP BC
        LD A,(DE)                       ;DO THIS DIGIT AFTER
        JP P,TN1                        ;DIGIT. S SAYS OVERFLOW

QHOW:
        PUSH DE                         ;*** ERROR "HOW?" ***
AHOW:
        LD DE,HOW
        JP ERROR_ROUTINE


HOW:    DB "HOW?",CR
OK:     DB "OK",CR
WHAT:   DB "WHAT?",CR
SORRY:  DB "SORRY",CR


;-------------------------------------------------------------------------------
; SERIAL MONITOR/OS
;-------------------------------------------------------------------------------
                ORG     0100H
; INIT IS THE ROUTINE THAT SETS UP, OR INITIALIZES, THE PERIPHERALS.
INIT:
        CALL SERIAL_INIT
        LD HL,CS_MSG
        CALL PRINT_STRING
        LD HL,SIGNON_MSG
        CALL PRINT_STRING
        CALL PRINT_PROMPT

; SERMAIN_LOOP, THE MAIN LOOP FOR THE SERIAL MONITOR.
MAIN_LOOP:
        CALL RXA_RDY
        JR MAIN_LOOP


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
CS_MSG:
        DB      ESC,"[2J",ESC,"[H",00H
SIGNON_MSG:
        DB      LF
        DB      "G80-S Computer by Doug Gabbard - 2017",CR,LF
VERSION:
        DB      "G-DOS Prototype v0.51b",CR,LF,LF
        DB      "Type 'HELP' for command list.",CR,LF,LF,00H

MEMORY_CLR_MSG:
        DB      "CLEARING MEMORY...",00H

STORAGE_CHK_MSG:
        DB      "CHECKING FOR STORAGE...",00H

STORE_NO_FOUND_MSG:
        DB      "STORAGE NOT FOUND.",CR,LF,00H

STORAGE_FOUND_MSG:
        DB      "STORAGE FOUND.",CR,LF,00H

CMD_NOT_IMPLE_MSG:
        DB      " ERROR - COMMAND NOT IMPLEMENTED",CR,LF,00H

CMD_ERROR_MSG:
        DB      CR,LF,"  ERROR - NOT RECOGNIZED ",CR,LF,LF,00H

OVERFLOW_ERROR_MSG:
        DB      CR,LF,"  ERROR - BUFFER OVERFLOW ",CR,LF,00H

LOADING_MSG:
        DB      CR,LF
        DB      " LOADING...",00H

DONE_MSG:
        DB      "DONE.",CR,LF,00H

TEST_MSG:
        DB      CR,LF," COMMAND RECOGNITION TEST WORKED!",CR,LF,00H
DUMP_HEADER_MSG:
        DB      "  ________________________________________________________________________ ",CR,LF
        DB      " |                                DUMPER                                  |",CR,LF
        DB      " |------------------------------------------------------------------------|",CR,LF
        DB      " |       0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F"
        DB      "         ASCII     |",CR,LF
        DB      " |------------------------------------------------------------------------|",CR,LF,00H
DUMP_FOOTER_MSG:
        DB      CR,LF," |________________________________________________________________________|",00H
MODMEM_MSG:
        DB      CR,LF,"  'X' TO EXIT",CR,LF,00H
IN_MSG:
        DB      CR,LF," PORT=",00H
HELP_MSG:
        DB      CR,LF," G80-S COMMANDS:",CR,LF,LF
        DB      TAB,"BASIC - TINY BASIC 2.5g",CR,LF
        DB      TAB,"CALL XXXX - RUN CODE AT LOCATION XXXX",CR,LF
        DB      TAB,"CLS - CLEAR THE TERMINAL SCREEN",CR,LF
        DB      TAB,"DUMP XXXX - DUMP 256 BYTES OF MEMORY",CR,LF
        DB      TAB,"HELP - THIS SCREEN",CR,LF
        DB      TAB,"HEXLOAD - LOAD INTEL HEX FILES OVER SERIAL",CR,LF
        DB      TAB,"IN XX - READ INPUT FROM PORT XX",CR,LF
        DB      TAB,"MODMEM XXXX - MODIFY MEMORY STARTING AT XXXX",CR,LF
        DB      TAB,"OUT XX HH - WRITE HH TO PORT XX",CR,LF
        DB      TAB,"RAMCLR - CLEAR USER AREA OF MEMORY",CR,LF
        DB      TAB,"RESTART - SOFT RESTART",CR,LF,LF
HELP_PORTS_MSG:
        DB      " PORTS:",CR,LF
        DB      TAB,"SIO (00-03H)",CR,LF
        DB      TAB,"PIO (80-83H)",CR,LF,00H

;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
; SYSTEM CALLS & SUBROUTINES
;-------------------------------------------------------------------------------

; RAMCLR IS A FUNCTION THAT CLEARS THE RAM FROM BOTTOM TO TOP.
;  IT LOADS THE ADDRESS INTO B&C AND LOADS THE ADDRESS WITH
;  00h UNTIL THE ADDRESS REACHES FAF9h (LEAVING THE STACK INTACT), THEN CLEARS
;  THE MEMORY ABOVE THE STACK, THEN RETURNS.
;  IT DESTROYS: A,B & C REGISTERS
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
; DELAY OF 1 MILLISECOND
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
        OUT (SIOA_D),A          ;ECHO THE CHARACTER BACK TO TERMINAL

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

; PRINT_HEX IS A ROUTINE THAT CONVERTS A NUMBER TO THE ASCII REPRESENTATION
;  OF THE NUMBER, AND SENDS THE CHARACTERS TO THE PRINT_CHAR ROUTINE TO BE
;  SENT OVER SERIAL.  IT EXPECTS THE NUMBER TO PRINT TO BE STORED IN A. I HAVE
;  MADE MODIFICATIONS TO THE CODE TO ALLOW IT TO RUN ON THE G80. THIS CODE IS
;  AVAILABLE ON SEVERAL PLACES THROUGHOUT THE WEB, AND I DO NOT KNOW IF THE
;  ORIGINAL AUTHOR'S NAME HAS BEEN LOST TO TIME. THE VERSION I USED IS BELOW.
;  ORIGIN:  WWW.KNOERIG.DE/ELEKTRONIK/Z80/BILDER/MONITOR.ASM
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
        LD C,LF                 ;CHECK IF LINE FEED
        SUB C
        RET NZ
        JP IN_CMD_CHK           ;JUMP TO COMMAND RECOGNITION


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

; CONVERTS THE ASCII CHARACTER IN A TO IT'S HEX VALUE IN A, ERROR RETURNS 0FFH
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
;-------------------------------------------------------------------------------
;COMMAND RECOGNITION
;-------------------------------------------------------------------------------
IN_CMD_CHK:
        LD HL,BUF_BOT-1         ;BOTTOM OF BUFFER-1
        LD DE,CMD_TABLE-1
IN_CMD_CHKL:
        INC HL
        INC DE

        LD A,(HL)               ;GET THE CHAR FROM BUFFER
        EX DE,HL                ;EXCHANGE THE REGISTERS
        LD B,A                  ;STORE THE VALUE
        LD A,(HL)               ;GET THE CHAR FROM THE TABLE
        EX DE,HL                ;RE-EXCHANGE THE REGISTERS

        LD C,00H                ;CHECK IF END OF WORD
        CP C
        JR Z,IN_CMD_TOKEN       ;IF END OF WORD AND PASS, GET TOKEN

        SUB B
        JR Z,IN_CMD_CHKL        ;IF MATCH, GET NEXT CHAR
        JR IN_CMD_NEXT_WORD     ;IF NOT, TRY NEXT WORD



IN_CMD_TOKEN:                   ;FIND THE TOKEN VALUE

        LD A,(HL)               ;FIRST, MAKE SURE THAT IT'S THE END OF
        LD C,020H               ;WORD IN THE BUFFER, BY CHECKING FOR <SPACE>
        SUB C
        JP NZ,CMD_ERROR         ;IF IT'S NOT, JUMP TO THE ERROR ROUTINE.

        LD HL,BUF_BOT-1         ;LOAD BUFFER ADDRESS AND START VALUE
        LD B,00H
IN_CMD_TOKENL:                  ;HEX - 0023H
        INC HL
        LD A,(HL)               ;GET CHARACTER FROM BUFFER
        LD C,020H               ;CHECK IF SPACE
        CP C
        JR Z,IN_CMD_GO          ;GO TO COMMAND IF SO
        ADD A,B
        LD B,A                  ;ADD AND STORE VALUE
        JR IN_CMD_TOKENL        ;GET NEXT CHARACTER

;----------------
;CMD JUMP ROUTINE
;----------------
IN_CMD_GO:                      ;FIND MATCHING TOKEN AND GO  -  002E
        LD A,B                  ;RESTORE THE TOKEN VALUE

        LD C,TOK_BASIC          ;TEST FOR BASIC
        CP C
        JP Z,START              ;START TINY BASIC

        LD C,TOK_CALL
        CP C
        JP Z,CALL_CMD            ;RUN CALL ROUTINE
        LD C,TOK_CLS
        CP C
        JP Z,CLS                ;CLEAR SCREEN ROUTINE
        LD C,TOK_TEST           ;NOW CHECK WHICH COMMAND AND GOTO
        CP C
        JP Z,TEST               ;TEST ROUTINE
        LD C,TOK_DUMP
        CP C
        JP Z,DUMP               ;MEMORY DUMP ROUTINE
        LD C,TOK_HELP
        CP C
        JP Z,HELP               ;HELP ROUTINE
        LD C,TOK_HEXLOAD
        CP C
        JP Z,HEXLOAD
        LD C,TOK_IN
        CP C
        JP Z,IN_CMD             ;IN ROUTINE
        LD C,TOK_MODMEM
        CP C
        JP Z,MODMEM             ;MEMORY MODIFY ROUTINE
        LD C,TOK_OUT
        CP C
        JP Z,OUT_CMD            ;OUT ROUTINE
        LD C,TOK_RAMCLR
        CP C
        JP Z,RAM_CLR            ;RAMCLR ROUTINE
        LD C,TOK_RESTART
        CP C
        JP Z,RESTART            ;RESTART MONITOR


        CALL BUF_CLR
        CALL PRINT_PROMPT

        RET
        ;JP BOOT                 ;RESET IF CRASH
;----------------


IN_CMD_NEXT_WORD:               ;GRAB NEXT WORD
        INC DE

        ;NEED SOMETHING TO SEE IF TOP OF COMMAND TABLE HERE.
        LD HL,CMD_TABLE_END     ;SHOULD BE TOP OF CMD_TABLE
        LD A,L                  ;THE ADDRESS TO TEST FOR
        CP E                    ;COMPARE THE ADDRESS
        JR Z,CMD_ERROR


        LD A,(DE)               ;INCREMENT AND CHECK UNTIL 00H IS FOUND
        LD C,00H
        SUB C
        JR NZ,IN_CMD_NEXT_WORD  ;TRY AGAIN IF NOT FOUND
        LD HL,BUF_BOT-1         ;RESET BUFFER AND CHECK THAT WORD.
        JP IN_CMD_CHKL

CMD_TABLE:                      ;COMMAND WORD LIST
        DB      "BASIC",00H
        DB      "CALL",00H
        DB      "CLS",00H
        DB      "TEST",00H
        DB      "DUMP",00H
        DB      "IN",00H
        DB      "HELP",00H
        DB      "HEXLOAD",00H
        DB      "MODMEM",00H
        DB      "OUT",00H
        DB      "RAMCLR",00H
        DB      "RESTART",00H
 CMD_TABLE_END:
        DB      00H
CMD_ERROR:
        LD HL,CMD_ERROR_MSG
        CALL PRINT_STRING
        CALL PRINT_PROMPT
        RET



;COMMAND TOKEN VALUES
TOK_BASIC       EQU     062H
TOK_CALL        EQU     01CH
TOK_CLS         EQU     0E2H
TOK_TEST        EQU     040H
TOK_DUMP        EQU     036H
TOK_IN          EQU     097H
TOK_HELP        EQU     029H
TOK_HEXLOAD     EQU     05H
TOK_MODMEM      EQU     0BFH
TOK_OUT         EQU     0F8H
TOK_RAMCLR      EQU     0C1H
TOK_RESTART     EQU     025H
;-------------------------------------------------------------------------------


;-------------------------------------------------------------------------------
;COMMANDS
;-------------------------------------------------------------------------------
; TEST IS A TEST ROUTINE TO SEE IF THE COMMAND RECOGINITION ROUTINES WORK.
;  IT SHOULD JUST PRINT SOME VERY BASIC STUFF TO THE SCREEN.
TEST:
        LD HL,TEST_MSG
        CALL PRINT_STRING
        CALL PRINT_PROMPT
        RET

CALL_CMD:

        LD A,(BUF_BOT+5)        ;GET THE BYTES, CONVERT TO BINARY ADDRESS
        LD D,A
        LD A,(BUF_BOT+6)
        LD E,A
        CALL ASCIIHEX_TO_BYTE
        LD H,A                  ;PLACE UPPER BYTE IN H
        LD A,(BUF_BOT+7)
        LD D,A
        LD A,(BUF_BOT+8)        ;FOR NICE ROUND-NUMBER DUMP.
        LD E,A
        CALL ASCIIHEX_TO_BYTE
        LD L,A                  ;PLACE LOWER BYTE IN L
        JP (HL)

CLS:
        LD HL,CS_MSG
        CALL PRINT_STRING
        CALL PRINT_PROMPT
        RET

;DUMP COMMAND
;-------------------------
DUMP:
        LD HL,CS_MSG
        CALL PRINT_STRING
        LD HL,DUMP_HEADER_MSG
        CALL PRINT_STRING
        LD A,(BUF_BOT+5)          ;GET THE BYTES, CONVERT TO BINARY ADDRESS
        LD D,A
        LD A,(BUF_BOT+6)
        LD E,A
        CALL ASCIIHEX_TO_BYTE
        LD H,A                  ;PLACE UPPER BYTE IN H
        LD A,(BUF_BOT+7)
        LD D,A
        LD A,030H                ;FOR NICE ROUND-NUMBER DUMP.
        LD E,A
        CALL ASCIIHEX_TO_BYTE
        LD L,A                  ;PLACE LOWER BYTE IN L
        LD B,0FH                ;LOAD ROW COUNTER BYTE
        LD C,010H                ;LOAD COLUMN COUNTER BYTE
        LD A, SPACE
        CALL PRINT_CHAR
        LD A,'|'
        CALL PRINT_CHAR
        CALL DUMP_ADDR
        LD A,SPACE
        CALL PRINT_CHAR
        CALL PRINT_CHAR
DUMP2:
        LD A,C
        CP 00H
        JR Z,DUMP4
        LD C,A
DUMP3:
        LD A,(HL)
        CALL PRINT_HEX
        INC HL
        LD A,C
        DEC A
        LD C,A
        LD A,SPACE
        CALL PRINT_CHAR
        JR DUMP2
DUMP4:
        CALL DUMP_ASCII
        LD A,B
        CP 00H
        JR Z,DUMP_EXIT
        DEC A
        LD B,A
        LD C,010H
        LD A,CR
        CALL PRINT_CHAR
        LD A,LF
        CALL PRINT_CHAR
        LD A,SPACE
        CALL PRINT_CHAR
        LD A,'|'
        CALL PRINT_CHAR
        CALL DUMP_ADDR
        LD A,SPACE
        CALL PRINT_CHAR
        CALL PRINT_CHAR
        JR DUMP2
DUMP_ASCII:
        PUSH AF
        PUSH BC
        PUSH DE
        PUSH HL
        LD A,SPACE
        CALL PRINT_CHAR
        CALL PRINT_CHAR
        LD DE,0010H
        SBC HL,DE
        LD B,010H
DUMP_ASCII2:
        LD A,B
        CP 00H
        JR Z,DUMP_ASCII3
        DEC A
        LD B,A
        LD A,(HL)
        CALL DUMP_ASCII_CONVERT
        CALL PRINT_CHAR
        INC HL
        JR DUMP_ASCII2
DUMP_ASCII3:
        LD A,'|'
        CALL PRINT_CHAR
        POP HL
        POP DE
        POP BC
        POP AF
        RET
DUMP_ASCII_CONVERT:
        CP 07FH
        JP P,DUMP_ASCII_CONVERT2
        CP 0FFH
        JR Z,DUMP_ASCII_CONVERT2
        AND 07FH
        CP 020H
        JP M,DUMP_ASCII_CONVERT2
        JR DUMP_ASCII_CONVERT3
DUMP_ASCII_CONVERT2:
        LD A,'.'
DUMP_ASCII_CONVERT3:
        RET
DUMP_ADDR:
        LD A,H
        CALL PRINT_HEX
        LD A,L
        CALL PRINT_HEX
        RET
;DUMP_ADDR_MODMEM:
;        LD A,H
;        CALL PRINT_HEX
;        LD A,L
;        CALL PRINT_HEX
;        LD A, " "
;        CALL PRINT_CHAR
;        LD A,(HL)
;        CALL PRINT_HEX
;        RET
DUMP_EXIT:
        LD HL,DUMP_FOOTER_MSG
        CALL PRINT_STRING
        CALL BUF_CLR
        LD A,CR
        CALL PRINT_CHAR
        LD A,LF
        CALL PRINT_CHAR
        CALL PRINT_PROMPT
        RET
DUMP_NEXT_BUF:
        INC HL
        LD A,(HL)
        CALL PRINT_CHAR
        RET
;--------------------------

HELP:
        LD HL,HELP_MSG
        CALL PRINT_STRING
        CALL PRINT_PROMPT
        RET

IN_CMD:
        LD HL,IN_MSG
        CALL PRINT_STRING
        LD A,(BUF_BOT+3)          ;GET THE BYTES, CONVERT TO BINARY ADDRESS
        LD D,A
        LD A,(BUF_BOT+4)
        LD E,A
        CALL ASCIIHEX_TO_BYTE
        LD C,A
        IN A,(C)
        CALL PRINT_HEX
        LD A,'h'
        CALL PRINT_CHAR
        CALL BUF_CLR
        CALL PRINT_PROMPT
        RET

MODMEM:
        LD HL,MODMEM_MSG
        CALL PRINT_STRING
        LD A,(BUF_BOT+7)          ;GET THE BYTES, CONVERT TO BINARY ADDRESS
        LD D,A
        LD A,(BUF_BOT+8)
        LD E,A
        CALL ASCIIHEX_TO_BYTE
        LD H,A                  ;PLACE UPPER BYTE IN H
        LD A,(BUF_BOT+9)
        LD D,A
        LD A,(BUF_BOT+10)        ;FOR NICE ROUND-NUMBER DUMP.
        LD E,A
        CALL ASCIIHEX_TO_BYTE
        LD L,A                  ;PLACE LOWER BYTE IN L
        CALL MODMEM_DUMP_ADDR
        LD A,'>'
        CALL PRINT_CHAR
MODMEM2:
        CALL MODMEM_GET
        CP 'X'
        JR Z,MODMEM_EXIT
        CP 'x'
        JR Z,MODMEM_EXIT
        LD D,A
        CALL MODMEM_GET
        CP 'X'
        JR Z,MODMEM_EXIT
        CP 'x'
        JR Z,MODMEM_EXIT
        LD E,A
MODMEM3:
        CALL ASCIIHEX_TO_BYTE
        CP 0FEH                 ; Added to fix 'Enter Bug'
        CALL Z,MODMEM_ERROR     ;
        CP 0F6H                 ;
        CALL Z,MODMEM_ERROR     ;
        LD (HL),A
        INC HL
        LD A,CR
        CALL PRINT_CHAR
        LD A,LF
        CALL PRINT_CHAR
        CALL MODMEM_DUMP_ADDR
        LD A,'>'
        CALL PRINT_CHAR
        JR MODMEM2
MODMEM_GET:
        LD A,00H                ;SETUP THE STATUS REGISTER
        OUT (SIOA_C),A
        IN A,(SIOA_C)           ;LOAD THE STATUS BYTE
        LD C,01H                ;LOAD BYTE TO COMPARE THE BIT, AND COMPARE
        AND C
        SUB C
        JR NZ,MODMEM_GET
        IN A,(SIOA_D)
        CALL PRINT_CHAR         ;ECHO
        RET
MODMEM_DUMP_ADDR:
        LD A,H
        CALL PRINT_HEX
        LD A,L
        CALL PRINT_HEX
        LD A, " "
        CALL PRINT_CHAR
        LD A,(HL)
        CALL PRINT_HEX
        RET
MODMEM_EXIT:
        CALL BUF_CLR
        CALL PRINT_PROMPT
        RET

MODMEM_ERROR:                   ;Added to fix 'Enter Bug'
        LD A,(HL)               ;
        RET                     ;

OUT_CMD:
        LD A,(BUF_BOT+4)
        LD D,A
        LD A,(BUF_BOT+5)
        LD E,A
        CALL ASCIIHEX_TO_BYTE
        LD C,A
        LD A,(BUF_BOT+7)
        LD D,A
        LD A,(BUF_BOT+8)
        LD E,A
        CALL ASCIIHEX_TO_BYTE
        OUT (C),A
        CALL BUF_CLR
        CALL PRINT_PROMPT
        RET

RESTART:
        JP BOOT

HEXLOAD:
        CALL IH_LOAD
        CALL PRINT_PROMPT
        RET
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
;///////////////////////////////////////////////////////////////////////////////
;-------------------------------------------------------------------------------
; THIS IS A ROUTINE FOR LOADING AN INTEL HEX FILE INTO MEMORY FROM SERIAL.
;   THE SOURCE FROM THIS WAS TAKEN FROM: http://www.vaxman.de/projects/tiny_z80/
;
; According to Bernd Ulmann, the author of the site listed above, he took this
; routine from Andrew Lynch's boot loader program.  While aware of who Andrew
; is, I have not had any conversations with him concerning this program, and
; I have not laid eyes on the code.  Bernd has modified this code to work with
; his own computer, a z80 machine with IDE support. I have further modified it
; to work with my own system, although those modifications were minor.  I did
; include several of Bernd's system calls, as they were different enough in
; nature from my own that it would wreak havoc, and cause me to either rewrite
; essentially the same code, or to modify the flow of the rest of my monitor
; program in order to make it work. However, I also recreated several of his
; calls to better suit my needs, but have credit him by placing them within
; this block of code.  To see the original source, please visit the site listed
; above.
;
;
;   The end of Bernd's and Andrews code will be clearly noted in my source.
;-------------------------------------------------------------------------------
;


IH_LOAD:
        PUSH AF
        PUSH DE
        PUSH HL
        LD HL,IH_LOAD_MSG_1
        CALL PRINT_STRING
IH_LOAD_LOOP:
        CALL GETC                       ;GET A CHARACTER
        CP CR                           ;DONT CARE ABOUT CR
        JR Z,IH_LOAD_LOOP
        CP LF                           ;...OR LF
        JR Z,IH_LOAD_LOOP
        CP SPACE                        ;...OR A SPACE
        JR Z,IH_LOAD_LOOP
        CALL TO_UPPER                   ;CONVERT TO UPPER CASE
        CALL PUTC                       ;ECHO CHARACTER
        CP ':'                          ; IS IT A COLON?
        JR NZ,IH_LOAD_ERROR
        CALL GET_BYTE                   ;GET RECORD LENGTH INTO A
        LD D,A                          ;LENGTH IS NOW IN D
        LD E,00H                        ;CLEAR CHECKSUM
        CALL IH_LOAD_CHK                ;COMPUTE CHECKSUM
        CALL GET_WORD                   ;GET LOAD ADDRESS INTO HL
        LD A,H                          ;UPDATE CHECKSUM BY THIS ADDRESS
        CALL IH_LOAD_CHK
        LD A,L
        CALL IH_LOAD_CHK

        ;THINK I NEED THE ADDRESS ADJUSTER HERE
        ;PUSH DE
        ;LD DE,08000H
        ;ADD HL,DE
        ;CALL IH_ADDR_TST
        ;POP DE
        ;END OF ADDRESS ADJUST

        CALL GET_BYTE                   ;GET THE RECORD TYPE
        CALL IH_LOAD_CHK                ;UPDATE CHECKSUM
        CP 01H                          ;HAVE WE READED EOF MARKER?
        JR NZ,IH_LOAD_DATA              ;NO - GET SOME DATA
        CALL GET_BYTE                   ;YES - EOF,READ CHECKSUM DATA
        CALL IH_LOAD_CHK                ;UPDATE OUR OWN CHECKSUM
        LD A,E
        AND A                           ;IS OUR CHECKSUM ZERO?
        JR Z,IH_LOAD_EXIT               ;YES - EXIT THIS ROUTINE

IH_LOAD_CHK_ERR:
        LD HL,IH_LOAD_MSG_3
        CALL PRINT_STRING               ;NO - PRINT AN ERROR MESSAGE
        JR IH_LOAD_EXIT                 ; AND EXIT

IH_LOAD_DATA:
        LD A,D                          ;RECORD LENGTH IS NOW IN A
        AND A                           ;DID WE PROCESS ALL BYTES?
        JR Z,IH_LOAD_EOL                ;YES - PROCESS END OF LINE
        CALL GET_BYTE                   ;READ TWO HEX DIGITS INTO A
        CALL IH_LOAD_CHK                ;UPDATE CHECKSUM
        LD (HL),A                       ;STORE BYTE INTO MEMORY
        INC HL                          ;INCREMENT POINTER
        DEC D                           ;DECREMENT REMAINING RECORD LENGTH
        JR IH_LOAD_DATA                 ;GET NEXT BYTE

IH_LOAD_EOL:
        CALL GET_BYTE                   ;READ THE LAST BYTE IN THE LINE
        CALL IH_LOAD_CHK                ;UPDATE CHECKSUM
        LD A,E
        AND A                           ;IS THE CHECKSUM ZERO?
        JR NZ,IH_LOAD_CHK_ERR
        CALL CRLF
        JR IH_LOAD_LOOP                 ;YES - READ NEXT LINE

IH_LOAD_ERROR:
        LD HL,IH_LOAD_MSG_2
        CALL PRINT_STRING               ;PRINT ERROR MESSAGE

IH_LOAD_EXIT:
        CALL CRLF
        POP HL                          ;RESTORE REGISTERS
        POP DE
        POP AF
        RET                             ;RETURN FROM HEX LOADER

IH_LOAD_CHK:
        LD C,A                          ;ALL IN ALL COMPUTE E=E-A
        LD A,E
        SUB C
        LD E,A
        LD A,C
        RET

IH_LOAD_MSG_1:
        DB "INTEL HEX LOAD: ",00H
IH_LOAD_MSG_2:
        DB " SYNTAX ERROR!",00H
IH_LOAD_MSG_3:
        DB " CHECKSUM ERROR!",00H
IH_LOAD_MSG_CRLF:
        DB CR,LF,00H
IH_LOAD_MSG_OUTSPC:
        DB CR,LF,LF,"OUT OF MEMORY.",CR,LF,00H

;--------------
;PUTC
;SENDS THE CHARACTER CODE IN REG-A TO THE SERIAL LINE
;----------------
; DESTROYS A & C.
;----------------
PUTC:
        PUSH AF
        PUSH BC
PUTC2
        LD A,00H
        OUT (SIOA_C),A          ;SELECT REGISTER 0
        IN A,(SIOA_C)           ;READ REGISTER 0
        RRC A
        RRC A
        LD C,01H                ;ROTATE, AND, THEN SUB
        AND C
        SUB C                   ;TRANMIT READY?
        JR NZ,PUTC2             ;NO - TRY AGAIN
        POP BC                  ;YES - RESTORE
        POP AF
PUTC3:
        OUT (SIOA_D),A          ;SEND CHARACTER CODE
        RET

;----------------
; CRLF
; SENDS A CR/LF TO THE SERIAL LINE
;-----------------
CRLF:
        PUSH HL                 ;SAVE THE POINTER
        LD HL,IH_LOAD_MSG_CRLF  ;LOAD NEW POINTER
        CALL PRINT_STRING       ;PRINT IT
        POP HL                  ;RESTORE OLD POINTER
        RET
;----------------
;TO_UPPER
;CONVERTS ASCII CODE IN REG-A INTO UPPER CASE, RETURNS IN REG-A
;----------------
TO_UPPER:
        CP 61H
        RET C
        CP 7BH
        RET NC
        AND 5FH
        RET
;----------------
;GETC
;READS A CHARACTER CODE FROM SERIAL INTO REG-A
;----------------
GETC:
        PUSH AF
        PUSH BC
GETC2:
        LD A,00H                ;SETUP THE STATUS REGISTER
        OUT (SIOA_C),A
        IN A,(SIOA_C)           ;LOAD THE STATUS BYTE
        LD C,01H                ;LOAD BYTE TO COMPARE THE BIT, AND COMPARE
        AND C
        SUB C
        JR NZ,GETC2
        POP BC
        POP AF
GETC3:
        IN A,(SIOA_D)
        RET

;---------------
; GET_BYTE
; Get a byte in hexadecimal notation. The result is returned in A. Since
; the routine get_nibble is used only valid characters are accepted - the
; input routine only accepts characters 0-9a-f.
;---------------
GET_BYTE:
        PUSH BC                         ;SAVE THE REGISTERS
        CALL GET_NIBBLE                 ;GET UPPER NIBBLE
        RLC A
        RLC A
        RLC A                           ;ROTATE RIGHT
        RLC A
        LD B,A                          ;SAVE UPPER NIBBLE
        CALL GET_NIBBLE                 ;GET LOWER NIBBLE
        OR B                            ;COMBINE
        POP BC                          ;RESTORE OLD REGISTERS
        RET
;----------------
; GET_NIBBLE
; Get a hexadecimal digit from the serial line. This routine blocks until
; a valid character (0-9a-f) has been entered. A valid digit will be echoed
; to the serial line interface. The lower 4 bits of A contain the value of
; that particular digit.
;----------------
GET_NIBBLE:
        CALL GETC                       ;READ A CHARACTER
        CALL TO_UPPER                   ;CONVERT TO UPPER CASE
        CALL IS_HEX                     ;WAS IT A HEX DIGIT
        JR NC,GET_NIBBLE                ;NO, GET ANOTHER CHARACTER
        CALL NIBBLE2VAL                 ;CONVERT NIBBLE TO VALUE
        CALL PRINT_NIBBLE
        RET
;-----------------
; IS_HEX
; is_hex checks a character stored in A for being a valid hexadecimal digit.
; A valid hexadecimal digit is denoted by a set C flag.
;-----------------
IS_HEX:
        CP 47H                          ;GREATER THAN 'F' ?
        RET NC                          ;YES - RETURN
        CP 30H                          ;LESS THAN '0'
        JR NC,IS_HEX_1                  ;NO - CONTINUE
        CCF                             ; COMPLIMENT CARRY - I.E. CLEAR IT
        RET
IS_HEX_1:
        CP 3AH                          ;LESS OR EQUAL TO '9'?
        RET C                           ;YES - RETURN
        CP 41H                          ;LESS THAN 'A'?
        JR NC,IS_HEX_2                  ;NO - CONTINUE
        CCF                             ;YES - CLEAR CARRY AND RETURN
        RET
IS_HEX_2:
        SCF                             ;SET CARRY AND RETURN
        RET
;------------------
; NIBBLE2VAL
; nibble2val expects a hexadecimal digit (upper case!) in A and returns the
; corresponding value in A.
;
NIBBLE2VAL:
        CP 3Ah                          ;IS IT A DIGIT?
        JR C,NIBBLE2VAL1                ;YES
        SUB 7                           ;ADJUST FOR A-F
NIBBLE2VAL1:
        SUB 30H                         ;FOLD BACK TO 0..15
        AND 0FH
        RET

;------------------
; PRINT_NIBBLE
; print_nibble prints a single hex nibble which is contained in the lower
; four bits of A:
;------------------
PRINT_NIBBLE:
        PUSH AF                         ;SAVE REGISTERS
        AND 0FH                         ;JUST IN CASE...
        ADD A,30h                       ;IF DIGIT, WE ARE DONE
        CP 3AH                          ;IS RESULT > 9?
        JR C,PRINT_NIBBLE1
        ADD A,07H                       ;TAKE CARE OF A-F ('A'-'0'-0AH)
PRINT_NIBBLE1:
        CALL PUTC                       ;PRINT THE NIBBLE
        POP AF                          ;POP AF
        RET
;----------------
; GETS
;  Read a string from STDIN - HL contains the buffer start address,
; B contains the buffer length.
;----------------
; NOT SURE IF THIS WILL WORK OR NOT...
GETS:
        PUSH AF
        PUSH BC
        PUSH HL
GETS_LOOP:
        CALL GETC                               ;GET A CHARACTER
        CP CR                                   ;SKIP CR
        JR Z,GETS_LOOP                          ;LF WILL TERMINATE INPUT
        CALL TO_UPPER
        CALL PUTC                               ;ECHO CHARACTER
        CP LF                                   ;TERMINATE STRING AT LF
        JR Z,GETS_EXIT                          ;  OR COPY TO BUFFER
        LD (HL),A
        INC HL
        DJNZ GETS_LOOP
GETS_EXIT:
        LD (HL),00H                             ;INSERT TERMINATION BYTE
        POP HL
        POP BC
        POP AF
        RET
;------------------
; GET_WORD
; Get a word (16 bit) in hexadecimal notation. The result is returned in HL.
; Since the routines get_byte and therefore get_nibble are called, only valid
; characters (0-9a-f) are accepted.
;------------------
; PROBABLY NEED TO ADJUST FOR RAM ADDRESS TO LOAD INTO..
GET_WORD:
        PUSH AF                         ;SAVE THE REGISTERS
        CALL GET_BYTE                   ;GET THE UPPER BYTE
        LD H,A
        CALL GET_BYTE                   ;GET THE LOWER BYTE
        LD L,A
        POP AF                          ;RESTORE THE REGISTERS
        RET

        ;END OF BERND'S AND ANDREW'S CODE - NOTHING ELSE FOLLOWS


IH_OUTSPC:
        LD HL,IH_LOAD_MSG_OUTSPC
        CALL PRINT_STRING
        JP IH_LOAD_EXIT
IH_ADDR_TST:
        PUSH AF
        LD A,0FBH
        SUB H
        JR Z,IH_ADDR_TST2
        POP AF
        RET
IH_ADDR_TST2:
        CALL DELAY                      ;BURN TIME TO LET THE TRANSFER
        CALL DELAY                      ; FINISH
        CALL DELAY
        CALL DELAY
        CALL GETC                       ;GET RID OF CHARACTER STILL IN BUFFER
        CALL GETC
        POP AF                          ;RESTORE REGISTERS
        POP DE
        JR IH_OUTSPC                    ;PRINT MEMORY MSG AND EXIT

;-------------------------------------------------------------------------------
;///////////////////////////////////////////////////////////////////////////////
;-------------------------------------------------------------------------------













;*************************************************************
; *** ZERO PAGE SUPPLEMENT ***
;*************************************************************

START:
        CALL BUF_CLR
        LD SP,STACKB                     ;*** COLD START ***
        LD A,0FFH
        JP INITB

;*************************************************************
;
; *** MAIN ***
;
; THIS IS THE MAIN LOOP THAT COLLECTS THE TINY BASIC PROGRAM
; AND STORES IT IN THE MEMORY.
;
; AT START, IT PRINTS OUT "(CR)OK(CR)", AND INITIALIZES THE
; STACKB AND SOME OTHER INTERNAL VARIABLES.  THEN IT PROMPTS
; ">" AND READS A LINE.  IF THE LINE STARTS WITH A NON-ZERO
; NUMBER, THIS NUMBER IS THE LINE NUMBER.  THE LINE NUMBER
; (IN 16 BIT BINARY) AND THE REST OF THE LINE (INCLUDING CR)
; IS STORED IN THE MEMORY.  IF A LINE WITH THE SAME LINE
; NUMBER IS ALREADY THERE, IT IS REPLACED BY THE NEW ONE.  IF
; THE REST OF THE LINE CONSISTS OF A CR ONLY, IT IS NOT STORED
; AND ANY EXISTING LINE WITH THE SAME LINE NUMBER IS DELETED.
;
; AFTER A LINE IS INSERTED, REPLACED, OR DELETED, THE PROGRAM
; LOOPS BACK AND ASKS FOR ANOTHER LINE.  THIS LOOP WILL BE
; TERMINATED WHEN IT READS A LINE WITH ZERO OR NO LINE
; NUMBER; AND CONTROL IS TRANSFERED TO "DIRECT".
;
; TINY BASIC PROGRAM SAVE AREA STARTS AT THE MEMORY LOCATION
; LABELED "TXTBGN" AND ENDS AT "TXTEND".  WE ALWAYS FILL THIS
; AREA STARTING AT "TXTBGN", THE UNFILLED PORTION IS POINTED
; BY THE CONTENT OF A MEMORY LOCATION LABELED "TXTUNF".
;
; THE MEMORY LOCATION "CURRNT" POINTS TO THE LINE NUMBER
; THAT IS CURRENTLY BEING INTERPRETED.  WHILE WE ARE IN
; THIS LOOP OR WHILE WE ARE INTERPRETING A DIRECT COMMAND
; (SEE NEXT SECTION). "CURRNT" SHOULD POINT TO A 0.
;*************************************************************

RSTART:
        LD SP,STACKB

ST1:
        CALL CRLFB                      ;AND JUMP TO HERE
        LD DE,OK                        ;DE->STRING
        SUB A                           ;A=0
        CALL PRTSTG                     ;PRINT STRING UNTIL CR
        LD HL,ST2+1                     ;LITERAL 0
        LD (CURRNT),HL                  ;CURRENT->LINE # = 0

ST2:
        LD HL,0000H
        LD (LOPVAR),HL
        LD (STKGOS),HL

ST3:
        LD A,'>'                        ;PROMPT '>' AND
        CALL GETLN                      ;READ A LINE
        PUSH DE                         ;DE->END OF LINE
        LD DE,BUFFER                    ;DE->BEGINNING OF LINE
        CALL TSTNUM                     ;TEST IF IT IS A NUMBER
        RST 28H
        LD A,H                          ;HL=VALUE OF THE # OR
        OR L                            ;0 IF NO # WAS FOUND
        POP BC                          ;BC->END OF LINE
        JP Z,DIRECT
        DEC DE                          ;BACKUP DE AND SAVE
        LD A,H                          ;VALUE OF LINE # THERE
        LD (DE),A
        DEC DE
        LD A,L
        LD (DE),A
        PUSH BC                         ;BC,DE->BEGIN, END
        PUSH DE
        LD A,C
        SUB E

        PUSH AF                         ;A=# OF BYTES IN LINE
        CALL FNDLN                      ;FIND THIS LINE IN SAVE
        PUSH DE                         ;AREA, DE->SAVE AREA
        JR NZ,ST4                       ;NZ:NOT FOUND, INSERT
        PUSH DE                         ;Z:FOUND, DELETE IT
        CALL FNDNXT                     ;FIND NEXT LINE
                                        ;DE->NEXT LINE
        POP BC                          ;BC->LINE TO BE DELETED
        LD HL,(TXTUNF)                  ;HL->UNFILLED SAVE AREA
        CALL MVUP                       ;MOVE UP TO DELETE
        LD H,B                          ;TXTUNF->UNFILLED ARA
        LD L,C
        LD (TXTUNF),HL                  ;UPDATE

ST4:
        POP BC                          ;GET READY TO INSERT
        LD HL,(TXTUNF)                  ;BUT FIRST CHECK IF
        POP AF                          ;THE LENGTH OF NEW LINE
        PUSH HL                         ;IS 3 (LINE # AND CR)
        CP 03H                          ;THEN DO NOT INSERT
        JR Z,RSTART                     ;MUST CLEAR THE STACKB
        ADD A,L                         ;COMPUTE NEW TXTUNF
        LD L,A
        LD A,00H
        ADC A,H
        LD H,A                          ;HL->NEW UNFILLED AREA
        LD DE,TXTEND                    ;CHECK TO SEE IF THERE
        RST 20H                         ;IS ENOUGH SPACE
        JP NC,QSORRY                    ;SORRY, NO ROOM FOR IT
        LD (TXTUNF),HL                  ;OK, UPDATE TXTUNF
        POP DE                          ;DE->OLD UNFILLED AREA
        CALL MVDOWN
        POP DE                          ;DE->BEGIN, HL->END
        POP HL
        CALL MVUP                       ;MOVE NEW LINE TO SAVE
        JR ST3                          ;AREA

;*************************************************************
;
; WHAT FOLLOWS IS THE CODE TO EXECUTE DIRECT AND STATEMENT
; COMMANDS.  CONTROL IS TRANSFERED TO THESE POINTS VIA THE
; COMMAND TABLE LOOKUP CODE OF 'DIRECT' AND 'EXEC' IN LAST
; SECTION.  AFTER THE COMMAND IS EXECUTED, CONTROL IS
; TRANSFERED TO OTHERS SECTIONS AS FOLLOWS:
;
; FOR 'LIST', 'NEW', AND 'STOP': GO BACK TO 'RSTART'
; FOR 'RUN': GO EXECUTE THE FIRST STORED LINE IF ANY, ELSE
; GO BACK TO 'RSTART'.
; FOR 'GOTO' AND 'GOSUB': GO EXECUTE THE TARGET LINE.
; FOR 'RETURN' AND 'NEXT': GO BACK TO SAVED RETURN LINE.
; FOR ALL OTHERS: IF 'CURRENT' -> 0, GO TO 'RSTART', ELSE
; GO EXECUTE NEXT COMMAND.  (THIS IS DONE IN 'FINISH'.)
;*************************************************************
;
; *** NEW *** STOP *** RUN (& FRIENDS) *** & GOTO ***
;
; 'NEW(CR)' SETS 'TXTUNF' TO POINT TO 'TXTBGN'
;
; 'STOP(CR)' GOES BACK TO 'RSTART'
;
; 'RUN(CR)' FINDS THE FIRST STORED LINE, STORE ITS ADDRESS (IN
; 'CURRENT'), AND START EXECUTE IT.  NOTE THAT ONLY THOSE
; COMMANDS IN TAB2 ARE LEGAL FOR STORED PROGRAM.
;
; THERE ARE 3 MORE ENTRIES IN 'RUN':
; 'RUNNXL' FINDS NEXT LINE, STORES ITS ADDR. AND EXECUTES IT.
; 'RUNTSL' STORES THE ADDRESS OF THIS LINE AND EXECUTES IT.
; 'RUNSML' CONTINUES THE EXECUTION ON SAME LINE.
;
; 'GOTO EXPR(CR)' EVALUATES THE EXPRESSION, FIND THE TARGET
; LINE, AND JUMP TO 'RUNTSL' TO DO IT.
;*************************************************************

NEW:
        CALL ENDCHK                     ;*** NEW(CR) ***
        LD HL,TXTBGN
        LD (TXTUNF),HL
STOP:
        CALL ENDCHK                     ;*** STOP(CR) ***
        JP RSTART
RUN:
        CALL ENDCHK                     ;*** RUN(CR) ***
        LD DE,TXTBGN                    ;FIRST SAVED LINE
RUNNXL:
        LD HL,00H                       ;*** RUNNXL ***
        CALL FNDLP                      ;FIND WHATEVER LINE #
        JP C,RSTART                     ;C:PASSED TXTUNF, QUIT
RUNTSL:
        EX DE,HL                        ;*** RUNTSL ***
        LD (CURRNT),HL                  ;SET 'CURRENT'->LINE #
        EX DE,HL
        INC DE                          ;BUMP PASS LINE #
        INC DE
RUNSML:
        CALL CHKIO                      ;*** RUNSML ***
        LD HL,TAB2-1                    ;FIND COMMAND IN TAB2
        JP EXEC                         ;AND EXECUTE IT
GOTO:
        RST 18H                         ;*** GOTO EXPR ***
        PUSH DE                         ;SAVE FOR ERROR ROUTINE
        CALL ENDCHK                     ;MUST FIND A CR
        CALL FNDLN                      ;FIND THE TARGET LINE
        JP NZ,AHOW                      ;NO SUCH LINE #
        POP AF                          ;CLEAR THE PUSH DE
        JR RUNTSL                       ;GO DO IT

;*************************************************************
;
; *** LIST *** & PRINT ***
;
; LIST HAS TWO FORMS:
; 'LIST(CR)' LISTS ALL SAVED LINES
; 'LIST #(CR)' START LIST AT THIS LINE #
; YOU CAN STOP THE LISTING BY CONTROL C KEY
;
; PRINT COMMAND IS 'PRINT ....;' OR 'PRINT ....(CR)'
; WHERE '....' IS A LIST OF EXPRESIONS, FORMATS, BACK-
; ARROWS, AND STRINGS.  THESE ITEMS ARE SEPERATED BY COMMAS.
;
; A FORMAT IS A POUND SIGN FOLLOWED BY A NUMBER.  IT CONTROLS
; THE NUMBER OF SPACES THE VALUE OF A EXPRESION IS GOING TO
; BE PRINTED.  IT STAYS EFFECTIVE FOR THE REST OF THE PRINT
; COMMAND UNLESS CHANGED BY ANOTHER FORMAT.  IF NO FORMAT IS
; SPECIFIED, 6 POSITIONS WILL BE USED.
;
; A STRING IS QUOTED IN A PAIR OF SINGLE QUOTES OR A PAIR OF
; DOUBLE QUOTES.
;
; A BACK-ARROW MEANS GENERATE A (CR) WITHOUT (LF)
;
; A (CRLF) IS GENERATED AFTER THE ENTIRE LIST HAS BEEN
; PRINTED OR IF THE LIST IS A NULL LIST.  HOWEVER IF THE LIST
; ENDED WITH A COMMA, NO (CRLF) IS GENERATED.
;*************************************************************

LIST:
        CALL TSTNUM                     ;TEST IF THERE IS A #
        CALL ENDCHK                     ;IF NO # WE GET A 0
        CALL FNDLN                      ;FIND THIS OR NEXT LINE
LS1:
        JP C,RSTART                     ;C:PASSED TXTUNF
        CALL PRTLN                      ;PRINT THE LINE
        CALL CHKIO                      ;STOP IF HIT CONTROL-C
        CALL FNDLP                      ;FIND NEXT LINE
        JR LS1                          ;AND LOOP BACK
PRINT:
        LD C,06H                        ;C = # OF SPACES
        RST 08H                         ;F NULL LIST & ";"
        DB 3BH
        DB PR2-$-1
        CALL CRLFB                      ;GIVE CR-LF AND
        JR RUNSML                       ;CONTINUE SAME LINE
PR2:
        RST 08H                         ;IF NULL LIST (CR)
        DB CR
        DB PR0-$-1
        CALL CRLFB                      ;ALSO GIVE CR-LF AND
        JR RUNNXL                       ;GO TO NEXT LINE
PR0:
        RST 08H                         ;ELSE IS IT FORMAT?
        DB '#'
        DB PR1-$-1
        RST 18H                         ;YES, EVALUATE EXPR.
        LD C,L                          ;AND SAVE IT IN C
        JR PR3                          ;LOOK FOR MORE TO PRINT
PR1:
        CALL QTSTG                      ;OR IS IT A STRING?
        JR PR8                          ;IF NOT, MUST BE EXPR.
PR3:
        RST 08H                         ;IF ",", GO FIND NEXT
        DB ','
        DB PR6-$-1
        CALL FIN                        ;IN THE LIST.
        JR PR0                          ;LIST CONTINUES
PR6:
        CALL CRLFB                      ;LIST ENDS
        RST 30H
PR8:
        RST 18H                         ;EVALUATE THE EXPR
        PUSH BC
        CALL PRTNUM                     ;PRINT THE VALUE
        POP BC
        JR PR3                          ;MORE TO PRINT?
;
;*************************************************************
;
; *** GOSUB *** & RETURN ***
;
; 'GOSUB EXPR;' OR 'GOSUB EXPR (CR)' IS LIKE THE 'GOTO'
; COMMAND, EXCEPT THAT THE CURRENT TEXT POINTER, STACKB POINTER
; ETC. ARE SAVE SO THAT EXECUTION CAN BE CONTINUED AFTER THE
; SUBROUTINE 'RETURN'.  IN ORDER THAT 'GOSUB' CAN BE NESTED
; (AND EVEN RECURSIVE), THE SAVE AREA MUST BE STACKBED.
; THE STACKB POINTER IS SAVED IN 'STKGOS', THE OLD 'STKGOS' IS
; SAVED IN THE STACKB.  IF WE ARE IN THE MAIN ROUTINE, 'STKGOS'
; IS ZERO (THIS WAS DONE BY THE "MAIN" SECTION OF THE CODE),
; BUT WE STILL SAVE IT AS A FLAG FOR NO FURTHER 'RETURN'S.
;
; 'RETURN(CR)' UNDOS EVERYTHING THAT 'GOSUB' DID, AND THUS
; RETURN THE EXECUTION TO THE COMMAND AFTER THE MOST RECENT
; 'GOSUB'.  IF 'STKGOS' IS ZERO, IT INDICATES THAT WE
; NEVER HAD A 'GOSUB' AND IS THUS AN ERROR.
;*************************************************************

GOSUB:
        CALL PUSHA                      ;SAVE THE CURRENT "FOR"
        RST 18H                         ;PARAMETERS
        PUSH DE                         ;AND TEXT POINTER
        CALL FNDLN                      ;FIND THE TARGET LINE
        JP NZ,AHOW                      ;NOT THERE. SAY "HOW?"
        LD HL,(CURRNT)                  ;FOUND IT, SAVE OLD.
        PUSH HL                         ;'CURRNT' OLD 'STKGOS'
        LD HL,(STKGOS)
        PUSH HL
        LD HL,0000H                     ;AND LOAD NEW ONES
        LD (LOPVAR),HL
        ADD HL,SP
        LD (STKGOS),HL
        JP RUNTSL                       ;THEN RUN THAT LINE
RETURN:
        CALL ENDCHK                     ;THERE MUST BE A CR
        LD HL,(STKGOS)                  ;OLD STACKB POINTER
        LD A,H                          ;0 MEANS NOT EXIST
        OR L
        JP Z,QWHAT                      ;SO, WE SAY: "WHAT?"
        LD SP,HL                        ;ELSE, RESTORE IT
        POP HL
        LD (STKGOS),HL                  ;AND THE OLD "STKGOS"
        POP HL
        LD (CURRNT),HL                  ;AND THE OLD 'CURRNT'
        POP DE                          ;OLD TEXT POINTER
        CALL POPA                       ;OLD "FOR" PARAMETERS
        RST 30H                         ;AND WE ARE BACK HOME

;*************************************************************
;
; *** FOR *** & NEXT ***
;
; 'FOR' HAS TWO FORMS:
; 'FOR VAR=EXP1 TO EXP2 STEP EXP3' AND 'FOR VAR=EXP1 TO EXP2'
; THE SECOND FORM MEANS THE SAME THING AS THE FIRST FORM WITH
; EXP3=1.  (I.E., WITH A STEP OF +1.)
; TBI WILL FIND THE VARIABLE VAR, AND SET ITS VALUE TO THE
; CURRENT VALUE OF EXP1.  IT ALSO EVALUATES EXP2 AND EXP3
; AND SAVE ALL THESE TOGETHER WITH THE TEXT POINTER ETC. IN
; THE 'FOR' SAVE AREA, WHICH CONSISTS OF 'LOPVAR', 'LOPINC',
; 'LOPLMT', 'LOPLN', AND 'LOPPT'.  IF THERE IS ALREADY SOME-
; THING IN THE SAVE AREA (THIS IS INDICATED BY A NON-ZERO
; 'LOPVAR'), THEN THE OLD SAVE AREA IS SAVED IN THE STACKB
; BEFORE THE NEW ONE OVERWRITES IT.
; TBI WILL THEN DIG IN THE STACKB AND FIND OUT IF THIS SAME
; VARIABLE WAS USED IN ANOTHER CURRENTLY ACTIVE 'FOR' LOOP.
; IF THAT IS THE CASE, THEN THE OLD 'FOR' LOOP IS DEACTIVATED.
; (PURGED FROM THE STACKB..)
;
; 'NEXT VAR' SERVES AS THE LOGICAL (NOT NECESSARILLY PHYSICAL)
; END OF THE 'FOR' LOOP.  THE CONTROL VARIABLE VAR. IS CHECKED
; WITH THE 'LOPVAR'.  IF THEY ARE NOT THE SAME, TBI DIGS IN
; THE STACKB TO FIND THE RIGHT ONE AND PURGES ALL THOSE THAT
; DID NOT MATCH.  EITHER WAY, TBI THEN ADDS THE 'STEP' TO
; THAT VARIABLE AND CHECK THE RESULT WITH THE LIMIT.  IF IT
; IS WITHIN THE LIMIT, CONTROL LOOPS BACK TO THE COMMAND
; FOLLOWING THE 'FOR'.  IF OUTSIDE THE LIMIT, THE SAVE AREA
; IS PURGED AND EXECUTION CONTINUES.
;*************************************************************

FOR:
        CALL PUSHA                      ;SAVE THE OLD SAVE AREA
        CALL SETVAL                     ;SET THE CONTROL VAR.
        DEC HL                          ;HL IS ITS ADDRESS
        LD (LOPVAR),HL                  ;SAVE THAT
        LD HL,TAB5-1                    ;USE 'EXEC' TO LOOK
        JP EXEC                         ;FOR THE WORK 'TO'
FR1:
        RST 18H                         ;EVALUATE THE LIMITE
        LD (LOPLMT),HL                  ;SAVE THAT
        LD HL,TAB6-1                    ;USE 'EXEC' TO LOOK
        JP EXEC                         ;FOR THE WORD 'STEP'
FR2:
        RST 18H                         ;FOUND IT, GET STEP
        JR FR4
FR3:
        LD HL,0001H                     ;NOT FOUND, SET TO 1
FR4:
        LD (LOPINC),HL                  ;SAVE THAT TOO
FR5:
        LD HL,(CURRNT)                  ;SAVE CURRENT LINE #
        LD (LOPLN),HL
        EX DE,HL                        ;AND TEXT POINTER
        LD (LOPPT),HL
        LD BC,0AH                       ;DIG INTO STACKB TO
        LD HL,(LOPVAR)                  ;FIND 'LOPVAR'
        EX DE,HL
        LD H,B
        LD L,B                          ;HL=0 NOW
        ADD HL,SP                       ;HERE IS THE STACKB
        DB 3EH                          ;DISASSEMBLY SAID "ld a,09h"
FR7:
        ADD HL,BC                       ;EACH LEVEL IS 10 DEEP - DIS = 09
        LD A,(HL)                       ;GET THAT OLD 'LOPVAR'
        INC HL
        OR (HL)
        JR Z,FR8                        ;0 SAYS NO MORE IN IT
        LD A,(HL)
        DEC HL
        CP D                            ;SAME AS THIS ONE?
        JR NZ,FR7
        LD A,(HL)                       ;THE OTHER HALF?
        CP E
        JR NZ,FR7
        EX DE,HL                        ;YES, FOUND ONE
        LD HL,0000H
        ADD HL,SP                       ;TRY TO MOVE SP
        LD B,H
        LD C,L
        LD HL,000AH
        ADD HL,DE
        CALL MVDOWN                     ;AND PURGE 10 WORDS
        LD SP,HL                        ;IN THE STACKB
FR8:
        LD HL,(LOPPT)                   ;JOB DONE, RESTORE DE
        EX DE,HL
        RST 30H                         ;AND CONTINUE
;
NEXT:
        RST 38H                         ;GET ADDRESS OF VAR.
        JP C,QWHAT                      ;NO VARIABLE, "WHAT?"
        LD (VARNXT),HL                  ;YES, SAVE IT
NX0:
        PUSH DE                         ;SAVE TEXT POINTER
        EX DE,HL
        LD HL,(LOPVAR)                  ;GET VAR. IN 'FOR'
        LD A,H
        OR L                            ;0 SAYS NEVER HAD ONE
        JP Z,AWHAT                      ;SO WE ASK: "WHAT?"
        RST 20H                         ;ELSE WE CHECK THEM
        JR Z,NX3                        ;OK, THEY AGREE
        POP DE                          ;NO, LET'S SEE
        CALL POPA                       ;PURGE CURRENT LOOP
        LD HL,(VARNXT)                  ;AND POP ONE LEVEL
        JR NX0                          ;GO CHECK AGAIN
NX3:
        LD E,(HL)                       ;COME HERE WHEN AGREED
        INC HL
        LD D,(HL)                       ;DE=VALUE OF VAR.
        LD HL,(LOPINC)
        PUSH HL
        LD A,H
        XOR D
        LD A,D
        ADD HL,DE                       ;ADD ONE STEP
        JP M,NX4
        XOR H
        JP M,NX5
NX4:
        EX DE,HL
        LD HL,(LOPVAR)                  ;PUT IT BACK
        LD (HL),E
        INC HL
        LD (HL),D
        LD HL,(LOPLMT)                  ;HL->LIMIT
        POP AF                          ;OLD HL
        OR A
        JP P,NX1                        ;STEP > 0
        EX DE,HL                        ;STEP < 0
NX1:
        CALL CKHLDE                     ;COMPARE WITH LIMIT
        POP DE                          ;RESTORE TEXT POINTER
        JR C,NX2                        ;OUTSIDE LIMIT
        LD HL,(LOPLN)                   ;WITHIN LIMIT, GO
        LD (CURRNT),HL                  ;BACK TO THE SAVED
        LD HL,(LOPPT)                   ;'CURRNT' AND TEXT
        EX DE,HL                        ;POINTER
        RST 30H
NX5:
        POP HL
        POP DE
NX2:
        CALL POPA                       ;PURGE THIS LOOP
        RST 30H
;
;*************************************************************
;
; *** REM *** IF *** INPUT *** & LET (& DEFLT) ***
;
; 'REM' CAN BE FOLLOWED BY ANYTHING AND IS IGNORED BY TBI.
; TBI TREATS IT LIKE AN 'IF' WITH A FALSE CONDITION.
;
; 'IF' IS FOLLOWED BY AN EXPR. AS A CONDITION AND ONE OR MORE
; COMMANDS (INCLUDING OTHER 'IF'S) SEPERATED BY SEMI-COLONS.
; NOTE THAT THE WORD 'THEN' IS NOT USED.  TBI EVALUATES THE
; EXPR. IF IT IS NON-ZERO, EXECUTION CONTINUES.  IF THE
; EXPR. IS ZERO, THE COMMANDS THAT FOLLOWS ARE IGNORED AND
; EXECUTION CONTINUES AT THE NEXT LINE.
;
; 'INPUT' COMMAND IS LIKE THE 'PRINT' COMMAND, AND IS FOLLOWED
; BY A LIST OF ITEMS.  IF THE ITEM IS A STRING IN SINGLE OR
; DOUBLE QUOTES, OR IS A BACK-ARROW, IT HAS THE SAME EFFECT AS
; IN 'PRINT'.  IF AN ITEM IS A VARIABLE, THIS VARIABLE NAME IS
; PRINTED OUT FOLLOWED BY A COLON.  THEN TBI WAITS FOR AN
; EXPR. TO BE TYPED IN.  THE VARIABLE IS THEN SET TO THE
; VALUE OF THIS EXPR.  IF THE VARIABLE IS PROCEDED BY A STRING
; (AGAIN IN SINGLE OR DOUBLE QUOTES), THE STRING WILL BE
; PRINTED FOLLOWED BY A COLON.  TBI THEN WAITS FOR INPUT EXPR.
; AND SET THE VARIABLE TO THE VALUE OF THE EXPR.
;
; IF THE INPUT EXPR. IS INVALID, TBI WILL PRINT "WHAT?",
; "HOW?" OR "SORRY" AND REPRINT THE PROMPT AND REDO THE INPUT.
; THE EXECUTION WILL NOT TERMINATE UNLESS YOU TYPE CONTROL-C.
; THIS IS HANDLED IN 'INPERR'.
;
; 'LET' IS FOLLOWED BY A LIST OF ITEMS SEPERATED BY COMMAS.
; EACH ITEM CONSISTS OF A VARIABLE, AN EQUAL SIGN, AND AN EXPR.
; TBI EVALUATES THE EXPR. AND SET THE VARIABLE TO THAT VALUE.
; TBI WILL ALSO HANDLE 'LET' COMMAND WITHOUT THE WORD 'LET'.
; THIS IS DONE BY 'DEFLT'.
;*************************************************************

REM:
        LD HL,0000H                     ;*** REM ***
        DB 3EH                          ;THIS IS LIKE 'IF 0'
IFF:
        RST 18H                         ;*** IF ***
        LD A,H                          ;IS THE EXPR.=0?
        OR L
        JP NZ,RUNSML                    ;NO, CONTINUE
        CALL FNDSKP                     ;YES, SKIP REST OF LINE
        JP NC,RUNTSL                    ;AND RUN THE NEXT LINE
        JP RSTART                       ;IF NO NEXT, RE-START
INPERR:
        LD HL,(STKINP)                  ;*** INPERR ***
        LD SP,HL                        ;RESTORE OLD SP
        POP HL                          ;AND OLD 'CURRNT'
        LD (CURRNT),HL
        POP DE                          ;AND OLD TEXT POINTER
        POP DE                          ;REDO INPUT
INPUT:                                  ;*** INPUT ***
IP1:
        PUSH DE                         ;SAVE IN CASE OF ERROR
        CALL QTSTG                      ;IS NEXT ITEM A STRING?
        JR IP2                          ;NO
        RST 38H                         ;YES, BUT FOLLOWED BY A
        JR C,IP4                        ;VARIABLE? NO.
        JR IP3                          ;YES. INPUT VARIABLE
IP2:
        PUSH DE                         ;SAVE FOR 'PRTSTG'
        RST 38H                         ;MUST BE VARIABLE NOW
        JP C,QWHAT                      ;"WHAT?" IT IS NOT?
        LD A,(DE)                       ;GET READY FOR 'PRTSTR'
        LD C,A
        SUB A
        LD (DE),A
        POP DE
        CALL PRTSTG                     ;PRINT STRING AS PROMPT
        LD A,C                          ;RESTORE TEXT
        DEC DE
        LD (DE),A
IP3:
        PUSH DE                         ;SAVE TEXT POINTER
        EX DE,HL
        LD HL,(CURRNT)                  ;ALSO SAVE 'CURRNT'
        PUSH HL
        LD HL,IP1                       ;A NEGATIVE NUMBER
        LD (CURRNT),HL                  ;AS A FLAG
        LD HL,0000H                     ;SAVE SP TOO
        ADD HL,SP
        LD (STKINP),HL
        PUSH DE                         ;OLD HL
        LD A,3AH                        ;PRINT THIS TOO
        CALL GETLN                      ;AND GET A LINE
        LD DE,BUFFER                    ;POINTS TO BUFFER
        RST 18H                         ;EVALUATE INPUT
        NOP                             ;CAN BE 'CALL ENDCHK'
        NOP
        NOP
        POP DE                          ;OK,GET OLD HL
        EX DE,HL
        LD (HL),E                       ;SAVE VALUE IN VAR.
        INC HL
        LD (HL),D
        POP HL                          ;GET OLD 'CURRNT'
        LD (CURRNT),HL
        POP DE                          ;AND OLD TEXT POINTER
IP4:
        POP AF                          ;PURGE JUNK IN STACKB
        RST 08H                         ;IS NEXT CH. ','?
        DB ','
        DB IP5-$-1
        JR IP1                          ;YES, MORE ITEMS.
IP5:
        RST 30H
DEFLT:
        LD A,(DE)                       ;***  DEFLT ***
        CP CR                           ;EMPTY LINE IS OK
        JR Z,LT1                        ;ELSE IT IS 'LET'
LET:
        CALL SETVAL                     ;*** LET ***
        RST 08H                         ;SET VALUE TO VAR
        DB ','                          ;---DISASSEMBLE = INC L
        DB LT1-$-1                      ;---DISASSEMBLE = INC BC
        JR LET                          ;ITEM BY ITEM
LT1:
        RST 30H                         ;UNTIL FINISH
;*************************************************************
;
; *** EXPR ***
;
; 'EXPR' EVALUATES ARITHMETICAL OR LOGICAL EXPRESSIONS.
; <EXPR>::<EXPR2>
;         <EXPR2><REL.OP.><EXPR2>
; WHERE <REL.OP.> IS ONE OF THE OPERATORS IN TAB8 AND THE
; RESULT OF THESE OPERATIONS IS 1 IF TRUE AND 0 IF FALSE.
; <EXPR2>::=(+ OR -)<EXPR3>(+ OR -<EXPR3>)(....)
; WHERE () ARE OPTIONAL AND (....) ARE OPTIONAL REPEATS.
; <EXPR3>::=<EXPR4>(* OR /><EXPR4>)(....)
; <EXPR4>::=<VARIABLE>
;           <FUNCTION>
;           (<EXPR>)
; <EXPR> IS RECURSIVE SO THAT VARIABLE '@' CAN HAVE AN <EXPR>
; AS INDEX, FUNCTIONS CAN HAVE AN <EXPR> AS ARGUMENTS, AND
; <EXPR4> CAN BE AN <EXPR> IN PARANTHESE.
;*************************************************************

EXPR1:
        LD HL,TAB8-1                    ;LOOKUP REL.OP.
        JP EXEC                         ;GO DO IT
XP11:
        CALL XP18                       ;REL.OP.">="
        RET C                           ;NO, RETURN HL=0
        LD L,A                          ;YES, RETURN HL=1
        RET
XP12:
        CALL XP18                       ;REL.OP."#"
        RET Z                           ;FALSE, RETURN HL=0
        LD L,A                          ;TRUE, RETURN HL=1
        RET
XP13:
        CALL XP18                       ;REL.OP.">"
        RET Z                           ;FALSE
        RET C                           ;ALSO FALSE, HL=0
        LD L,A                          ;TRUE, HL=1
        RET
XP14:
        CALL XP18                       ;REL.OP."<="
        LD L,A                          ;SET HL=1
        RET Z                           ;REL. TRUE, RETURN
        RET C
        LD L,H                          ;ELSE SET HL=0
        RET
XP15:
        CALL XP18                       ;REL.OP."="
        RET NZ                          ;FALSE, RETURN HL=0
        LD L,A                          ;ELSE SET HL=1
        RET
XP16:
        CALL XP18                       ;REL.OP."<"
        RET NC                          ;FALSE, RETURN HL=0
        LD L,A                          ;ELSE SET HL=1
        RET
XP17:
        POP HL                          ;NOT .REL.OP
        RET                             ;RETURN HL=<EXPR2>
XP18:
        LD A,C                          ;SUBROUTINE FOR ALL
        POP HL                          ;REL.OP.'S
        POP BC
        PUSH HL                         ;REVERSE TOP OF STACKB
        PUSH BC
        LD C,A
        CALL EXPR2                      ;GET 2ND <EXPR2>
        EX DE,HL                        ;VALUE IN DE NOW
        EX (SP),HL                      ;1ST <EXPR2> IN HL
        CALL CKHLDE                     ;COMPARE 1ST WITH 2ND
        POP DE                          ;RESTORE TEXT POINTER
        LD HL,0000H                     ;SET HL=0, A=1
        LD A,01H
        RET
EXPR2:
        RST 08H                         ;NEGATIVE SIGN?
        DB '-'
        DB XP21-$-1
        LD HL,0000H                     ;YES, FAKE '0-'
        JR XP26                         ;TREAT LIKE SUBTRACT
XP21:
        RST 08H                         ;POSITIVE SIGN? IGNORE
        DB '+'
        DB XP22-$-1
XP22:
        CALL EXPR3                      ;1ST <EXPR3>
XP23:
        RST 08H                         ;ADD?
        DB  '+'
        DB XP25-$-1
        PUSH HL                         ;YES, SAVE VALUE
        CALL EXPR3                      ;GET 2ND <EXPR3>
XP24:
        EX DE,HL                        ;2ND IN DE
        EX (SP),HL                      ;1ST IN HL
        LD A,H                          ;COMPARE SIGN
        XOR D
        LD A,D
        ADD HL,DE
        POP DE                          ;RESTORE TEXT POINTER
        JP M,XP23                       ;1ST AND 2ND SIGN DIFFER
        XOR H                           ;1ST AND 2ND SIGN EQUAL
        JP P,XP23                       ;SO IS RESULT
        JP QHOW                         ;ELSE WE HAVE OVERFLOW
XP25:
        RST 08H                         ;SUBTRACT?
        DB '-'
        DB XP42-$-1
XP26:
        PUSH HL                         ;YES, SAVE 1ST <EXPR3>
        CALL EXPR3                      ;GET 2ND <EXPR3>
        CALL CHGSGN                     ;NEGATE
        JR XP24                         ;AND ADD THEM
;
EXPR3:
        CALL EXPR4                      ;GET 1ST <EXPR4>
XP31:
        RST 08H                         ;MULTIPLY?
        DB '*'
        DB XP34-$-1
        PUSH HL                         ;YES, SAVE 1ST
        CALL EXPR4                      ;AND GET 2ND <EXPR4>
        LD B,00H                        ;CLEAR B FOR SIGN
        CALL CHKSGN                     ;CHECK SIGN
        EX (SP),HL                      ;1ST IN HL
        CALL CHKSGN                     ;CHECK SIGN OF 1ST
        EX DE,HL
        EX (SP),HL
        LD A,H                          ;IS HL > 255 ?
        OR A
        JR Z,XP32                       ;NO
        LD A,D                          ;YES, HOW ABOUT DE
        OR D
        EX DE,HL                        ;PUT SMALLER IN HL
        JP NZ,AHOW                      ;ALSO >, WILL OVERFLOW
XP32:
        LD A,L                          ;THIS IS DUMB
        LD HL,0000H                     ;CLEAR RESULT
        OR A                            ;ADD AND COUNT
        JR Z,XP35
XP33:
        ADD HL,DE
        JP C,AHOW                       ;OVERFLOW
        DEC A
        JR NZ,XP33
        JR XP35                         ;FINISHED
XP34:
        RST 08H                         ;DIVIDE?
        DB '/'
        DB XP42-$-1
        PUSH HL                         ;YES, SAVE 1ST <EXPR4>
        CALL EXPR4                      ;AND GET THE SECOND ONE
        LD B,00H                        ;CLEAR B FOR SIGN
        CALL CHKSGN                     ;CHECK SIGN OF 2ND
        EX (SP),HL                      ;GET 1ST IN HL
        CALL CHKSGN                     ;CHECK SIGN OF 1ST
        EX DE,HL
        EX (SP),HL
        EX DE,HL
        LD A,D                          ;DIVIDE BY 0?
        OR E
        JP Z,AHOW                       ;SAY "HOW?"
        PUSH BC                         ;ELSE SAVE SIGN
        CALL DIVIDE                     ;USE SUBROUTINE
        LD H,B                          ;RESULT IN HL NOW
        LD L,C
        POP BC                          ;GET SIGN BACK
XP35:
        POP DE                          ;AND TEXT POINTER
        LD A,H                          ;HL MUST BE +
        OR A
        JP M,QHOW                       ;ELSE IT IS OVERFLOW
        LD A,B
        OR A
        CALL M,CHGSGN                   ;CHANGE SIGN IF NEEDED
        JR XP31                         ;LOOK FOR MORE TERMS
EXPR4:
        LD HL,TAB4-1                    ;FIND FUNCTION IN TAB4
        JP EXEC                         ;AND GO DO IT
XP40:
        RST 38H                         ;NO, NOT A FUNCTION
        JR C,XP41                       ;NOR A VARIABLE
        LD A,(HL)                       ;VARIABLE
        INC HL
        LD H,(HL)                       ;VALUE IN HL
        LD L,A
        RET
XP41:
        CALL TSTNUM                     ;OR IS IT A NUMBER
        LD A,B                          ;# OF DIGIT
        OR A
        RET NZ                          ;OK
PARN:
        RST 08H
        DB '('
        DB XP43-$-1
        RST 18H                         ;"(EXPR)"
        RST 08H
        DB ')'
        DB XP43-$-1
XP42:
        RET
XP43:
        JP QWHAT                        ;ELSE SAY: "WHAT?"
RND:
        CALL PARN                       ;*** RND(EXPR) ***
        LD A,H                          ;EXPR MUST BE +
        OR A
        JP M,QHOW
        OR L                            ;AND NON-ZERO
        JP Z,QHOW
        PUSH DE                         ;SAVE BOTH
        PUSH HL
        LD HL,(RANPNT)                  ;GET MEMORY AS RANDOM
        LD DE,LSTROM                    ;NUMBER
        RST 20H
        JR C,RA1                        ;WRAP AROUND IF LAST
        LD HL,START
RA1:
        LD E,(HL)
        INC HL
        LD D,(HL)
        LD (RANPNT),HL
        POP HL
        EX DE,HL
        PUSH BC
        CALL DIVIDE                     ;RND (N)=MOD(M,N)+1
        POP BC
        POP DE
        INC HL
        RET
ABS:
        CALL PARN                       ;*** ABS (EXPR) ***
        DEC DE
        CALL CHKSGN                     ;CHECK SIGN
        INC DE
        RET
SIZE:
        LD HL,(TXTUNF)                  ;*** SIZE ***
        PUSH DE                         ;GET THE NUMBER OF FREE
        EX DE,HL                        ;BYTES BETWEEN 'TXTUNF'
        LD HL,VARBGN                    ;AND 'VARBGN'
        CALL SUBDE
        POP DE
        RET
;*************************************************************
;
; *** DIVIDE *** SUBDE *** CHKSGN *** CHGSGN *** & CKHLDE ***
;
; 'DIVIDE' DIVIDES HL BY DE, RESULT IN BC, REMAINDER IN HL
;
; 'SUBDE' SUBSTRACTS DE FROM HL
;
; 'CHKSGN' CHECKS SIGN OF HL.  IF +, NO CHANGE.  IF -, CHANGE
; SIGN AND FLIP SIGN OF B.
;
; 'CHGSGN' CHECKS SIGN N OF HL AND B UNCONDITIONALLY.
;
; 'CKHLDE' CHECKS SIGN OF HL AND DE.  IF DIFFERENT, HL AND DE
; ARE INTERCHANGED.  IF SAME SIGN, NOT INTERCHANGED.  EITHER
; CASE, HL DE ARE THEN COMPARED TO SET THE FLAGS.
;*************************************************************

DIVIDE:
        PUSH HL                         ;*** DIVIDE ***
        LD L,H                          ;DIVIDE H BY DE
        LD H,00H
        CALL DV1
        LD B,C                          ;SAVE RESULT IN B
        LD A,L                          ;(REMAINDER+L)/DE
        POP HL
        LD H,A
DV1:
        LD C,0FFH                       ;RESULT IN C
DV2:
        INC C                           ;DUMB ROUTINE
        CALL SUBDE                      ;DIVIDE BY SUBTRACT
        JR NC,DV2                       ;AND COUNT
        ADD HL,DE
        RET
SUBDE:
        LD A,L                          ;*** SUBDE ***
        SUB E                           ;SUBSTRACT DE FROM
        LD L,A                          ;HL
        LD A,H
        SBC A,D
        LD H,A
        RET
CHKSGN:
        LD A,H                          ;*** CHKSGN ***
        OR A                            ;CHECK SIGN OF HL
        RET P
CHGSGN:
        LD A,H                          ;*** CHGSGN ***
        PUSH AF
        CPL                             ;CHANGE SIGN OF HL
        LD H,A
        LD A,L
        CPL
        LD L,A
        INC HL
        POP AF
        XOR H
        JP P,QHOW
        LD A,B                          ;AND ALSO FLIP B
        XOR 80H
        LD B,A
        RET
CKHLDE:
        LD A,H                          ;SAME SIGN?
        XOR D                           ;YES, COMPARE
        JP P,CK1                        ;NO, XCHANGE AND COMP
        EX DE,HL
CK1:
        RST 20H
        RET
;*************************************************************
;
; *** SETVAL *** FIN *** ENDCHK *** & ERROR (& FRIENDS) ***
;
; "SETVAL" EXPECTS A VARIABLE, FOLLOWED BY AN EQUAL SIGN AND
; THEN AN EXPR.  IT EVALUATES THE EXPR. AND SET THE VARIABLE
; TO THAT VALUE.
;
; "FIN" CHECKS THE END OF A COMMAND.  IF IT ENDED WITH ";",
; EXECUTION CONTINUES.  IF IT ENDED WITH A CR, IT FINDS THE
; NEXT LINE AND CONTINUE FROM THERE.
;
; "ENDCHK" CHECKS IF A COMMAND IS ENDED WITH CR.  THIS IS
; REQUIRED IN CERTAIN COMMANDS.  (GOTO, RETURN, AND STOP ETC.)
;
; "ERROR" PRINTS THE STRING POINTED BY DE (AND ENDS WITH CR).
; IT THEN PRINTS THE LINE POINTED BY 'CURRNT' WITH A "?"
; INSERTED AT WHERE THE OLD TEXT POINTER (SHOULD BE ON TOP
; OF THE STACKB) POINTS TO.  EXECUTION OF TB IS STOPPED
; AND TBI IS RESTARTED.  HOWEVER, IF 'CURRNT' -> ZERO
; (INDICATING A DIRECT COMMAND), THE DIRECT COMMAND IS NOT
; PRINTED.  AND IF 'CURRNT' -> NEGATIVE # (INDICATING 'INPUT'
; COMMAND), THE INPUT LINE IS NOT PRINTED AND EXECUTION IS
; NOT TERMINATED BUT CONTINUED AT 'INPERR'.
;
; RELATED TO 'ERROR' ARE THE FOLLOWING:
; 'QWHAT' SAVES TEXT POINTER IN STACKB AND GET MESSAGE "WHAT?"
; 'AWHAT' JUST GET MESSAGE "WHAT?" AND JUMP TO 'ERROR'.
; 'QSORRY' AND 'ASORRY' DO SAME KIND OF THING.
; 'AHOW' AND 'AHOW' IN THE ZERO PAGE SECTION ALSO DO THIS.
;*************************************************************

SETVAL:
        RST 38H                         ;*** SETVAL ***
        JP C,QWHAT                      ;"WHAT?" NO VARIABLE
        PUSH HL                         ;SAVE ADDRESS OF VAR.
        RST 08H                         ;PASS "=" SIGN
        DB '='
        DB SV1-$-1
        RST 18H                         ;EVALUATE EXPR.
        LD B,H                          ;VALUE IS IN BC NOW
        LD C,L
        POP HL                          ;GET ADDRESS
        LD (HL),C                       ;SAVE VALUE
        INC HL
        LD (HL),B
        RET
SV1:
        JP QWHAT                        ;NO "=" SIGN
FIN:
        RST 08H                         ;*** FIN ***
        DB 3BH
        DB FI1-$-1
        POP AF                          ;";", PURGE RET. ADDR.
        JP RUNSML                       ;CONTINUE SAME LINE
FI1:
        RST 08H                         ;NOT ";", IS IT CR?
        DB CR
        DB FI2-$-1
        POP AF                          ;YES, PURGE RET. ADDR.
        JP RUNNXL                       ;RUN NEXT LINE
FI2:
        RET                             ;ELSE RETURN TO CALLER
ENDCHK:
        RST 28H                         ;*** ENDCHK ***
        CP CR                           ;END WITH CR?
        RET Z                           ;OK, ELSE SAY: "WHAT?"
QWHAT:
        PUSH DE                         ;*** QWHAT ***
AWHAT:
        LD DE,WHAT                      ;*** AWHAT ***
ERROR_ROUTINE:
        SUB A                           ;*** ERROR ***
        CALL PRTSTG                     ;PRINT 'WHAT?', 'HOW?'
        POP DE                          ;OR 'SORRY'
        LD A,(DE)                       ;SAVE THE CHARACTER
        PUSH AF                         ;AT WHERE OLD DE ->
        SUB A                           ;AND PUT A 0 THERE
        LD (DE),A
        LD HL,(CURRNT)                  ;GET CURRENT LINE #
        PUSH HL
        LD A,(HL)                       ;CHECK THE VALUE
        INC HL
        OR (HL)
        POP DE
        JP Z,RSTART                     ;IF ZERO, JUST RESTART
        LD A,(HL)                       ;IF NEGATIVE,
        OR A
        JP M,INPERR                     ;REDO INPUT
        CALL PRTLN                      ;ELSE PRINT THE LINE
        DEC DE                          ;UPTO WHERE THE 0 IS
        POP AF                          ;RESTORE THE CHARACTER
        LD (DE),A
        LD A,3FH                        ;PRINT A "?"
        RST 10H
        SUB A                           ;AND THE REST OF THE
        CALL PRTSTG                     ;LINE
        JP RSTART                       ;THEN RESTART
QSORRY:
        PUSH DE                         ;*** QSORRY ***
ASORRY:
        LD DE,SORRY                     ;*** ASORRY ***
        JR ERROR_ROUTINE
;*************************************************************
;
; *** GETLN *** FNDLN (& FRIENDS) ***
;
; 'GETLN' READS A INPUT LINE INTO 'BUFFER'.  IT FIRST PROMPT
; THE CHARACTER IN A (GIVEN BY THE CALLER), THEN IT FILLS
; THE BUFFER AND ECHOS.  IT IGNORES LF'S AND NULLS, BUT STILL
; ECHOS THEM BACK.  RUB-OUT IS USED TO CAUSE IT TO DELETE
; THE LAST CHARACTER (IF THERE IS ONE), AND ALT-MOD IS USED TO
; CAUSE IT TO DELETE THE WHOLE LINE AND START IT ALL OVER.
; CR SIGNALS THE END OF A LINE, AND CAUSE 'GETLN' TO RETURN.
;
; 'FNDLN' FINDS A LINE WITH A GIVEN LINE # (IN HL) IN THE
; TEXT SAVE AREA.  DE IS USED AS THE TEXT POINTER.  IF THE
; LINE IS FOUND, DE WILL POINT TO THE BEGINNING OF THAT LINE
; (I.E., THE LOW BYTE OF THE LINE #), AND FLAGS ARE NC & Z.
; IF THAT LINE IS NOT THERE AND A LINE WITH A HIGHER LINE #
; IS FOUND, DE POINTS TO THERE AND FLAGS ARE NC & NZ.  IF
; WE REACHED THE END OF TEXT SAVE AREA AND CANNOT FIND THE
; LINE, FLAGS ARE C & NZ.
; 'FNDLN' WILL INITIALIZE DE TO THE BEGINNING OF THE TEXT SAVE
; AREA TO START THE SEARCH.  SOME OTHER ENTRIES OF THIS
; ROUTINE WILL NOT INITIALIZE DE AND DO THE SEARCH.
; 'FNDLNP' WILL START WITH DE AND SEARCH FOR THE LINE #.
; 'FNDNXT' WILL BUMP DE BY 2, FIND A CR AND THEN START SEARCH.
; 'FNDSKP' USE DE TO FIND A CR, AND THEN START SEARCH.
;*************************************************************

GETLN:
        RST 10H                         ;*** GETLN ***
        LD DE,BUFFER                    ;PROMPT AND INIT.
GL1:
        CALL CHKIO                      ;CHECK KEYBOARD
        JR Z,GL1                        ;NO INPUT, WAIT
        CP 7FH                          ;DELETE LAST CHARACTER?
        JR Z,GL3                        ;YES
        RST 10H                         ;INPUT, ECHO BACK
        CP 0AH                          ;IGNORE LF
        JR Z,GL1
        OR A                            ;IGNORE NULL
        JR Z,GL1
        CP 7DH                          ;DELETE THE WHOLE LINE?
        JR Z,GL4                        ;YES
        LD (DE),A                       ;ELSE SAVE INPUT
        INC DE                          ;AND BUMP POINTER
        CP 0DH                          ;WAS IT CR
        RET Z                           ;YES, END OF LINE
        LD A,E                          ;ELSE MORE FREE ROOM?
        CP BUFEND AND 0FFH
        JR NZ,GL1                       ;YES, GET NEXT INPUT
GL3:
        LD A,E                          ;DELETE LAST CHARACTER
        CP BUFFER AND 0FFH              ;BUT DO WE HAVE ANY?
        JR Z,GL4                        ;NO, REDO WHOLE LINE
        DEC DE                          ;YES, BACKUP POINTER
        LD A,5CH                        ;AND ECHO A BACK-SLASH
        RST 10H
        JR GL1                          ;GO GET NEXT INPUT
GL4:
        CALL CRLFB                      ;REDO ENTIRE LINE
        LD A,05EH                       ;CR, LF AND UP-ARROW
        JR GETLN
FNDLN:
        LD A,H                          ;*** FNDLN ***
        OR A                            ;CHECK SIGN OF HL
        JP M,QHOW                       ;IT CANNOT BE -
        LD DE,TXTBGN                    ;INIT TEXT POINTER
FNDLP:                                  ;*** FDLNP ***
FL1:
        PUSH HL                         ;SAVE LINE #
        LD HL,(TXTUNF)                  ;CHECK IF WE PASSED END
        DEC HL
        RST 20H
        POP HL                          ;GET LINE # BACK
        RET C                           ;C,NZ PASSED END
        LD A,(DE)                       ;WE DID NOT, GET BYTE 1
        SUB L                           ;IS THIS THE LINE?
        LD B,A                          ;COMPARE LOW ORDER
        INC DE
        LD A,(DE)                       ;GET BYTE 2
        SBC A,H                         ;COMPARE HIGH ORDER
        JR C,FL2                        ;NO, NOT THERE YET
        DEC DE                          ;ELSE WE EITHER FOUND
        OR B                            ;IT, OR IT IS NOT THERE
        RET                             ;NC,Z;FOUND, NC,NZ:NO
FNDNXT:                                 ;*** FNDNXT ***
        INC DE                          ;FIND NEXT LINE
FL2:
        INC DE                          ;JUST PASSED BYTE 1 & 2
FNDSKP:
        LD A,(DE)                       ;*** FNDSKP ***
        CP CR                           ;TRY TO FIND CR
        JR NZ,FL2                       ;KEEP LOOKING
        INC DE                          ;FOUND CR, SKIP OVER
        JR FL1                          ;CHECK IF END OF TEXT
;*************************************************************
;
; *** PRTSTG *** QTSTG *** PRTNUM *** & PRTLN ***
;
; 'PRTSTG' PRINTS A STRING POINTED BY DE.  IT STOPS PRINTING
; AND RETURNS TO CALLER WHEN EITHER A CR IS PRINTED OR WHEN
; THE NEXT BYTE IS THE SAME AS WHAT WAS IN A (GIVEN BY THE
; CALLER).  OLD A IS STORED IN B, OLD B IS LOST.
;
; 'QTSTG' LOOKS FOR A BACK-ARROW, SINGLE QUOTE, OR DOUBLE
; QUOTE.  IF NONE OF THESE, RETURN TO CALLER.  IF BACK-ARROW,
; OUTPUT A CR WITHOUT A LF.  IF SINGLE OR DOUBLE QUOTE, PRINT
; THE STRING IN THE QUOTE AND DEMANDS A MATCHING UNQUOTE.
; AFTER THE PRINTING THE NEXT 3 BYTES OF THE CALLER IS SKIPPED
; OVER (USUALLY A JUMP INSTRUCTION.
;
; 'PRTNUM' PRINTS THE NUMBER IN HL.  LEADING BLANKS ARE ADDED
; IF NEEDED TO PAD THE NUMBER OF SPACES TO THE NUMBER IN C.
; HOWEVER, IF THE NUMBER OF DIGITS IS LARGER THAN THE # IN
; C, ALL DIGITS ARE PRINTED ANYWAY.  NEGATIVE SIGN IS ALSO
; PRINTED AND COUNTED IN, POSITIVE SIGN IS NOT.
;
; 'PRTLN' PRINTS A SAVED TEXT LINE WITH LINE # AND ALL.
;*************************************************************

PRTSTG:
        LD B,A                          ;*** PRTSTG ***
PS1:
        LD A,(DE)                       ;GET A CHARACTER
        INC DE                          ;BUMP POINTER
        CP B                            ;SAME AS OLD A?
        RET Z                           ;YES, RETURN
        RST 10H                         ;NO, NEXT
        CP CR                           ;WAS IT A CR?
        JR NZ,PS1                       ;NO, NEXT
        RET                             ;YES, RETURN
QTSTG:
        RST 08H                         ;*** QTSTG ***
        DB '"'
        DB QT3-$-1
        LD A,22H                        ;IT IS A "
QT1:
        CALL PRTSTG                     ;PRINT UNTIL ANOTHER
        CP CR                           ;WAS LAST ONE A CR?
        POP HL                          ;RETURN ADDRESS
        JP Z,RUNNXL                     ;WAS CR, RUN NEXT LINE
QT2:
        INC HL                          ;SKIP 3 BYTES ON RETURN
        INC HL
        INC HL
        JP (HL)                         ;RETURN
QT3:
        RST 08H                         ;IS IT A '?
        DB 27H
        DB QT4-$-1
        LD A,27H                        ;YES, DO THE SAME
        JR QT1                          ;AS IN "
QT4:
        RST 08H                         ;IS IT BACK-ARROW?
        DB 5FH
        DB QT5-$-1
        LD A,8DH                        ;YES, CR WITHOUT LF
        RST 10H                         ;DO IT TWICE TO GIVE
        RST 10H                         ;TTY ENOUGH TIME
        POP HL                          ;RETURN ADDRESS
        JR QT2
QT5:
        RET                             ;NONE OF ABOVE
;
PRTNUM:
        LD B,00H                        ;*** PRTNUM ***
        CALL CHKSGN                     ;CHECK SIGN
        JP P,PN1                        ;NO SIGN
        LD B,'-'                        ;B=SIGN
        DEC C                           ;'-' TAKES SPACE
PN1:
        PUSH DE                         ;SAVE
        LD DE,000AH                     ;DECIMAL
        PUSH DE                         ;SAVE AS FLAG
        DEC C                           ;C=SPACES
        PUSH BC                         ;SAVE SIGN & SPACE
PN2:
        CALL DIVIDE                     ;DIVIDE HL BY 10
        LD A,B                          ;RESULT 0?
        OR C
        JR Z,PN3                        ;YES, WE GOT ALL
        EX (SP),HL                      ;NO, SAVE REMAINDER
        DEC L                           ;AND COUNT SPACE
        PUSH HL                         ;HL IS OLD BC
        LD H,B                          ;MOVE RESULT TO BC
        LD L,C
        JR PN2                          ;AND DIVIDE BY 10
PN3:
        POP BC                          ;WE GOT ALL DIGITS IN
PN4:
        DEC C                           ;THE STACKB
        LD A,C                          ;LOOK AT SPACE COUNT
        OR A
        JP M,PN5                        ;NO LEADING BLANKS
        LD A,20H                        ;LEADING BLANKS
        RST 10H
        JR PN4                          ;MORE?
PN5:
        LD A,B                          ;PRINT SIGN
        OR A
        CALL NZ,0010H
        LD E,L                          ;LAST REMAINDER IN E
PN6:
        LD A,E                          ;CHECK DIGIT IN E
        CP 0AH                          ;10 IS FLAG FOR NO MORE
        POP DE
        RET Z                           ;IF SO, RETURN
        ADD A,30H                       ;ELSE, CONVERT TO ASCII
        RST 10H                         ;PRINT THE DIGIT
        JR PN6                          ;GO BACK FOR MORE
PRTLN:
        LD A,(DE)                       ;*** PRTLN ***
        LD L,A                          ;LOW ORDER LINE #
        INC DE
        LD A,(DE)                       ;HIGH ORDER
        LD H,A
        INC DE
        LD C,04H                        ;PRINT 4 DIGIT LINE #
        CALL PRTNUM
        LD A,20H                        ;FOLLOWED BY A BLANK
        RST 10H
        SUB A                           ;AND THEN THE NEXT
        CALL PRTSTG
        RET
;*************************************************************
;
; *** MVUP *** MVDOWN *** POPA *** & PUSHA ***
;
; 'MVUP' MOVES A BLOCK UP FROM WHERE DE-> TO WHERE BC-> UNTIL
; DE = HL
;
; 'MVDOWN' MOVES A BLOCK DOWN FROM WHERE DE-> TO WHERE HL->
; UNTIL DE = BC
;
; 'POPA' RESTORES THE 'FOR' LOOP VARIABLE SAVE AREA FROM THE
; STACKB
;
; 'PUSHA' STACKBS THE 'FOR' LOOP VARIABLE SAVE AREA INTO THE
; STACKB
;*************************************************************

MVUP:
        RST 20H                         ;*** MVUP ***
        RET Z                           ;DE = HL, RETURN
        LD A,(DE)                       ;GET ONE BYTE
        LD (BC),A                       ;MOVE IT
        INC DE                          ;INCREASE BOTH POINTERS
        INC BC
        JR MVUP                         ;UNTIL DONE
MVDOWN:
        LD A,B                          ;*** MVDOWN ***
        SUB D                           ;TEST IF DE = BC
        JP NZ,MD1                       ;NO, GO MOVE
        LD A,C                          ;MAYBE, OTHER BYTE?
        SUB E
        RET Z                           ;YES, RETURN
MD1:
        DEC DE                          ;ELSE MOVE A BYTE
        DEC HL                          ;BUT FIRST DECREASE
        LD A,(DE)                       ;BOTH POINTERS AND
        LD (HL),A                       ;THEN DO IT
        JR MVDOWN                       ;LOOP BACK
POPA:
        POP BC                          ;BC = RETURN ADDR.
        POP HL                          ;RESTORE LOPVAR, BUT
        LD (LOPVAR),HL                  ;=0 MEANS NO MORE
        LD A,H
        OR L
        JR Z,PP1                        ;YEP, GO RETURN
        POP HL                          ;NOP, RESTORE OTHERS
        LD (LOPINC),HL
        POP HL
        LD (LOPLMT),HL
        POP HL
        LD (LOPLN),HL
        POP HL
        LD (LOPPT),HL
PP1:
        PUSH BC                         ;BC = RETURN ADDR.
        RET
PUSHA:
        LD HL,STKLMT                    ;*** PUSHA ***
        CALL CHGSGN
        POP BC                          ;BC=RETURN ADDRESS
        ADD HL,SP                       ;IS STACKB NEAR THE TOP?
        JP NC,QSORRY                    ;YES, SORRY FOR THAT
        LD HL,(LOPVAR)                  ;ELSE SAVE LOOP VAR'S
        LD A,H                          ;BUT IF LOPVAR IS 0
        OR L                            ;THAT WILL BE ALL
        JR Z,PU1
        LD HL,(LOPPT)                   ;ELSE, MORE TO SAVE
        PUSH HL
        LD HL,(LOPLN)
        PUSH HL
        LD HL,(LOPLMT)
        PUSH HL
        LD HL,(LOPINC)
        PUSH HL
        LD HL,(LOPVAR)
PU1:
        PUSH HL
        PUSH BC                         ;BC = RETURN ADDR.
        RET
;*************************************************************
;
; *** OUTC *** & CHKIO ***
;
; THESE ARE THE ONLY I/O ROUTINES IN TBI.
; 'OUTC' IS CONTROLLED BY A SOFTWARE SWITCH 'OCSW'.  IF OCSW=0
; 'OUTC' WILL JUST RETURN TO THE CALLER.  IF OCSW IS NOT 0,
; IT WILL OUTPUT THE BYTE IN A.  IF THAT IS A CR, A LF IS ALSO
; SEND OUT.  ONLY THE FLAGS MAY BE CHANGED AT RETURN. ALL REG.
; ARE RESTORED.
;
; 'CHKIO' CHECKS THE INPUT.  IF NO INPUT, IT WILL RETURN TO
; THE CALLER WITH THE Z FLAG SET.  IF THERE IS INPUT, Z FLAG
; IS CLEARED AND THE INPUT BYTE IS IN A.  HOWEVER, IF THE
; INPUT IS A CONTROL-O, THE 'OCSW' SWITCH IS COMPLIMENTED, AND
; Z FLAG IS RETURNED.  IF A CONTROL-C IS READ, 'CHKIO' WILL
; RESTART TBI AND DO NOT RETURN TO THE CALLER.
;*************************************************************

INITB:
        ;CALL SIO_INIT                   ;INITIALIZE THE SIO
        LD (OCSW),A                     ;SET INITIAL SWITCH VALUE
        LD D,03H                        ;3X LINE FEEDS
PATLOP:
        CALL CRLFB
        DEC D
        JR NZ,PATLOP
        SUB A
        LD DE,MSG1
        CALL PRTSTG
        LD DE,MSG2
        CALL PRTSTG
        LD DE,MSG3
        CALL PRTSTG
        LD HL,START
        LD (RANPNT),HL
        LD HL,TXTBGN
        LD (TXTUNF),HL
        JP RSTART
OUTC:
        JR NZ,OUTC2                     ;IT IS ON
        POP AF                          ;IT IS OFF
        RET                             ;RESTORE AF AND RETURN
OUTC2:
        CALL TX_RDY                     ;SEE IF TRANSMIT IS AVAILABLE
        POP AF                          ;RESTORE THE REGISTER
        OUT (SIOA_D),A                  ;SEND THE BYTE
        CP CR
        RET NZ
        LD A,LF
        RST 10H
        LD A,CR
        RET
CHKIO:
        CALL RX_RDY                     ;CHECK IF CHARACTER AVAILABLE
        RET Z                           ;RETURN IF NO CHARACTER AVAILABLE

        PUSH BC                         ;IF IT'S A LF, IGNORE AND RETURN
        LD B,A                          ; AS IF THERE WAS NO CHARACTER.
        SUB LF
        JR Z,CHKIO2
        LD A,B                          ;OTHERWISE RESTORE 'A' AND 'BC'
        POP BC                          ; AND CONTINUE ON.

        CP 0FH                          ;IS IT CONTROL-0?
        JR NZ,CI1                       ;NO, MORE CHECKING
        LD A,(OCSW)                     ;CONTROL-0 FLIPS OCSW
        CPL                             ;ON TO OFF, OFF TO ON
        LD (OCSW),A
        JR CHKIO                        ;GET ANOTHER INPUT
CHKIO2:
        LD A,00H                        ;CLEAR A
        OR A                            ;ZET THE Z-FLAG
        POP BC                          ;RESTORE THE 'BC' PAIR
        RET                             ;RETURN WITH 'Z' SET.
CI1:
        CP 03H                          ;IS IT CONTROL-C?
        RET NZ                          ;NO, RETURN "NZ"
        JP RSTART                       ;YES, RESTART TBI
;
MSG1:
        DB      ESC,"[2J",ESC,"[H"
        DB      'Z80 TinyBASIC 2.5g Patch 1',CR
MSG2:   DB      'Ported by Doug Gabbard, 2017',CR
MSG3:
        DB      LF,LF,'HELP - New Instructions',LF,LF,CR
;*************************************************************
;
; *** TABLES *** DIRECT *** & EXEC ***
;
; THIS SECTION OF THE CODE TESTS A STRING AGAINST A TABLE.
; WHEN A MATCH IS FOUND, CONTROL IS TRANSFERED TO THE SECTION
; OF CODE ACCORDING TO THE TABLE.
;
; AT 'EXEC', DE SHOULD POINT TO THE STRING AND HL SHOULD POINT
; TO THE TABLE-1.  AT 'DIRECT', DE SHOULD POINT TO THE STRING.
; HL WILL BE SET UP TO POINT TO TAB1-1, WHICH IS THE TABLE OF
; ALL DIRECT AND STATEMENT COMMANDS.
;
; A '.' IN THE STRING WILL TERMINATE THE TEST AND THE PARTIAL
; MATCH WILL BE CONSIDERED AS A MATCH.  E.G., 'P.', 'PR.',
; 'PRI.', 'PRIN.', OR 'PRINT' WILL ALL MATCH 'PRINT'.
;
; THE TABLE CONSISTS OF ANY NUMBER OF ITEMS.  EACH ITEM
; IS A STRING OF CHARACTERS WITH BIT 7 SET TO 0 AND
; A JUMP ADDRESS STORED HI-LOW WITH BIT 7 OF THE HIGH
; BYTE SET TO 1.
;
; END OF TABLE IS AN ITEM WITH A JUMP ADDRESS ONLY.  IF THE
; STRING DOES NOT MATCH ANY OF THE OTHER ITEMS, IT WILL
; MATCH THIS NULL ITEM AS DEFAULT.
;*************************************************************

TAB1:                                   ;DIRECT COMMANDS
        DB 'HELP'
        DWA HELP_CMDS
        DB 'LIST'
        DWA LIST
        DB 'NEW'
        DWA NEW
        DB 'QUIT'
        DWA QUIT
        DB 'RUN'
        DWA RUN

TAB2:                                   ;DIRECT/STATEMENT

        DB 'CALL'                       ;ADDED CALL PROTOTYPE
        DWA CALL_MCODE
        DB 'CLS'                        ;ADDED CLS CMD
        DWA CLSB
        DB 'DELAY'
        DWA DELAYB
        DB 'FOR'
        DWA FOR
        DB 'GOSUB'
        DWA GOSUB
        DB 'GOTO'
        DWA GOTO
        DB 'HEX'
        DWA HEX
        DB 'IF'
        DWA IFF
        DB 'INPUT'
        DWA INPUT
        DB 'IN'                         ;ADDED IN CMD
        DWA INB
        DB 'LET'
        DWA LET
        DB 'NEXT'
        DWA NEXT
        DB 'OUT'                        ;ADDED OUT CMD
        DWA OUTB
        DB 'PEEK'                       ;ADDED PEEK
        DWA PEEK
        DB 'POKE'                       ;ADDED POKE
        DWA POKE
        DB 'PRINT'
        DWA PRINT
        DB 'REM'
        DWA REM
        DB 'RETURN'
        DWA RETURN
        DB 'STOP'
        DWA STOP
        DWA DEFLT

TAB4:                                   ;FUNCTIONS
        DB 'ABS'
        DWA ABS
        DB 'RND'
        DWA RND
        DB 'SIZE'
        DWA SIZE
        DWA XP40
TAB5:                                   ;"TO" IN "FOR"
        DB 'TO'
        DWA FR1
        DWA QWHAT
TAB6:                                   ;"STEP" IN "FOR"
        DB 'STEP'
        DWA FR2
        DWA FR3
TAB8:                                   ;RELATION OPERATORS
        DB '>='
        DWA XP11
        DB '#'
        DWA XP12
        DB '>'
        DWA XP13
        DB '='
        DWA XP15
        DB '<='
        DWA XP14
        DB '<'
        DWA XP16
        DWA XP17
DIRECT: LD HL,TAB1-1                   ;*** DIRECT ***
EXEC:                                   ;*** EXEC ***
EX0:    RST 28H                         ;IGNORE LEADING BLANKS
        PUSH DE                         ;SAVE POINTER
EX1:
        LD A,(DE)                       ;IF FOUND '.' IN STRING
        INC DE                          ;BEFORE ANY MISMATCH
        CP 23H                          ;WE DECLARE A MATCH
        JR Z,EX3
        INC HL                          ;HL->TABLE
        CP (HL)                         ;IF MATCH, TEST NEXT
        JR Z,EX1
        LD A,7FH                        ;ELSE SEE IF BIT 7
        DEC DE                          ;OF TABLE IS SET, WHICH
        CP (HL)                         ;IS THE JUMP ADDR. (HI)
        JR C,EX5                        ;C:YES, MATCHED
EX2:
        INC HL                          ;NC:NO, FIND JUMP ADDR.
        CP (HL)
        JR NC,EX2
        INC HL                          ;BUMP TO NEXT TAB. ITEM
        POP DE                          ;RESTORE STRING POINTER
        JR EX0                          ;TEST AGAINST NEXT ITEM
EX3:
        LD A,7FH                        ;PARTIAL MATCH, FIND
EX4:
        INC HL                          ;JUMP ADDR., WHICH IS
        CP (HL)                         ;FLAGGED BY BIT 7
        JR NC,EX4
EX5:
        LD A,(HL)                       ;LOAD HL WITH THE JUMP
        INC HL                          ;ADDRESS FROM THE TABLE
        LD L,(HL)
        AND 7FH                         ;MASK OFF BIT 7
        LD H,A
        POP AF                          ;CLEAN UP THE GABAGE
        JP (HL)                         ;AND WE GO DO IT


;*************************************************************
;  *** TinyBASIC Expansion ***
;
;   *** QUIT *** INB *** OUTB *** CLSB ***
;   *** DELAYB *** PEEK *** POKE ***
;
;  QUIT IS A ROUTINE THAT QUITS BASIC, AND RETURNS TO THE
;   MONITOR PROGRAM.  THIS WILL LIKELY NEED TO BE MODIFIED
;   TO WORK ON YOUR COMPUTER.  IT WAS DESIGNED FOR G80-S
;   SOFTWARE.

;  INB IS THE ROUTINE FOR READING THE VALUE OF A PORT AND
;   ASSIGNING IT TO A VARIABLE.
;
;  OUTB IS THE ROUTINE FOR READIGN THE VALUE OF A VARIABLE AND
;   WRITING IT TO A HARDWARE PORT.
;
;  CLSB IS A ROUTINE TO CLEAR THE SCREEN.
;
;  DELAYB IS A ROUTINE DESIGNED TO GIVE APPROXIMATELY 2ms DELAY
;   AT 6MHZ.
;
;  PEEK IS A ROUTINE TO READ THE VALUE OF A MEMORY LOCATION
;   AND STORE THAT VALUE IN A VARIABLE.
;
;  POKE IS A ROUTINE USED TO READ A VARIABLE, AND WRITE THE
;   INFORMATION INTO A MEMORY LOCATION.
;
;
;*************************************************************

QUIT:                                   ;QUIT BASIC
        LD SP,STACK                     ;SETUP THE STACK FOR THE MONITOR
        LD A,LF
        CALL TX_RDY
        OUT (SIOA_D),A
        CALL TX_RDY
        OUT (SIOA_D),A
        LD HL,VERSION
        CALL PRINT_STRING
        CALL BUF_CLR
        JP MAIN_LOOP                    ;GO BACK TO THE MONITOR
;-------------------------------------------------------------------------------

INB:                                    ;'IN' ROUTINE
        PUSH AF                         ;SAVE THE REGISTERS
        PUSH BC
INB2:
        INC DE
        LD A,(DE)
        LD B,SPACE
        CP B
        JR Z,INB2                      ;IF IT'S NOT A SPACE GET THE LOCATION
INB3:
        CALL GET_HEX
        LD C,A                          ;PORT IS NOW IN 'C'.
INB4:
        INC DE
        LD A,(DE)
        LD B,','                        ; COMPARE COMA
        CP B
        JR Z,INB4
        LD B,' '                        ; COMPARE SPACE
        CP B
        JR Z,INB4
        LD B,'='
        CP B
        JR Z,INB4

        LD B,40H                        ;IF NOT IT IS VARIABLE
        SUB B                           ;ADJUST FOR MEMORY LOCATION

        LD HL,VARBGN                    ;COMPUTE ADDRESS OF
        RLCA                            ;THAT VARIABLE
        ADD A,L                         ;AND RETURN IT IN HL
        LD L,A                          ;WITH C FLAG CLEARED
        LD A,00H
        ADC A,H
        LD H,A

        IN A,(C)                        ;GET BYTE
        LD (HL),A                       ;STORE IT IN THE VARIALBLE LOCATION
        INC HL                          ;PAD THE EXTRA MEMORY LOCATION
        LD (HL),00H

        INC DE
        POP BC                          ;RESTORE THE REGISTERS
        POP AF
        JP RUNSML                       ;NEXT LINE
;-------------------------------------------------------------------------------
OUTB:                                   ;'OUT' ROUTINE
        PUSH AF
        PUSH BC
OUTB2:
        INC DE
        LD A,(DE)
        LD B,SPACE
        CP B
        JR Z,OUTB2
OUTB3:
        CALL GET_HEX
        PUSH AF                         ;PORT IS IN THE STACK
OUTB4:
        INC DE
        LD A,(DE)
        LD B,','                        ; COMPARE COMA
        CP B
        JR Z,OUTB4
        LD B,' '                        ; COMPARE SPACE
        CP B
        JR Z,OUTB4
        LD B,'='
        CP B
        JR Z,OUTB4

        LD B,40H                        ;IF NOT IT IS VARIABLE
        SUB B                           ;ADJUST FOR MEMORY LOCATION

        LD HL,VARBGN                    ;COMPUTE ADDRESS OF
        RLCA                            ;THAT VARIABLE
        ADD A,L                         ;AND RETURN IT IN HL
        LD L,A                          ;WITH C FLAG CLEARED
        LD A,00H
        ADC A,H
        LD H,A                          ;VARIABLE LOCATION IN HL

        POP AF                          ;PORT BACK IN 'A'
        LD C,A                          ;PORT IS NOW IN C
        LD A,(HL)                       ;Load the value from memory into 'A'

        OUT (C),A                       ;WRITE THE BYTE TO THE PORT

        POP BC                          ;RESTORE REGISTERS
        POP AF

        INC DE
        JP RUNSML
;-------------------------------------------------------------------------------

CLSB:                                   ;CLS ROUTINE FOR BASIC
        PUSH AF
        PUSH BC
        PUSH DE
        LD DE,CLSB_MSG
        CALL PRTSTG
        POP DE
        POP BC
        POP AF
        INC DE
        JP RUNNXL
CLSB_MSG:
        DB      ESC,"[2J",ESC,"[H",CR
;-------------------------------------------------------------------------------

DELAYB:
        PUSH AF
        PUSH BC
        PUSH DE
        PUSH HL

        CALL MILLI_DLY
        POP HL
        POP DE
        POP BC
        POP AF
        INC DE
        JP RUNNXL
;-------------------------------------------------------------------------------
PEEK:
        PUSH AF                         ;SAVE THE REGISTERS
        PUSH BC
PEEK2:
        INC DE
        LD A,(DE)
        LD B,SPACE
        CP B
        JR Z,PEEK2                      ;IF IT'S NOT A SPACE GET THE LOCATION
PEEK3:
        CALL GET_HEX
        LD H,A
        INC DE
        CALL GET_HEX
        LD L,A                          ;MEMORY LOCATION IN 'HL' NOW.
        LD A,(HL)                       ;GET THE BYTE FROM MEMORY.
        PUSH AF                         ;NOW STORE THE BYTE ON THE STACK.
PEEK4:
        INC DE
        LD A,(DE)
        LD B,','                        ; COMPARE COMA
        CP B
        JR Z,PEEK4
        LD B,' '                        ; COMPARE SPACE
        CP B
        JR Z,PEEK4
        LD B,'='
        CP B
        JR Z,PEEK4

        LD B,40H                        ;IF NOT IT IS VARIABLE
        SUB B                           ;ADJUST FOR MEMORY LOCATION

        LD HL,VARBGN                    ;COMPUTE ADDRESS OF
        RLCA                            ;THAT VARIABLE
        ADD A,L                         ;AND RETURN IT IN HL
        LD L,A                          ;WITH C FLAG CLEARED
        LD A,00H
        ADC A,H
        LD H,A

        POP AF                          ;RESTORE THE BYTE FROM THE STACK
        LD (HL),A                       ;STORE IT IN THE VARIALBLE LOCATION
        INC HL                          ;PAD THE EXTRA MEMORY LOCATION
        LD (HL),00H

        INC DE
        POP BC                          ;RESTORE THE REGISTERS
        POP AF
        JP RUNSML                       ;NEXT LINE
;-------------------------------------------------------------------------------

POKE:                                   ;POKE ROUTINE
        PUSH AF
        PUSH BC
POKE2:
        INC DE
        LD A,(DE)
        LD B,SPACE
        CP B
        JR Z,POKE2
POKE3:
        CALL GET_HEX
        LD H,A
        INC DE
        CALL GET_HEX
        LD L,A                          ;LOCATION NOW 'HL'
        PUSH HL                         ;STORE LOCATION IN STACK.

POKE4:
        INC DE
        LD A,(DE)
        LD B,','                        ; COMPARE COMA
        CP B
        JR Z,POKE4
        LD B,' '                        ; COMPARE SPACE
        CP B
        JR Z,POKE4
        LD B,'='
        CP B
        JR Z,POKE4
        LD B,'('                        ;IS IT HEX?
        CP B
        JR Z,POKE5

        LD B,40H                        ;IF NOT IT IS VARIABLE
        SUB B                           ;ADJUST FOR MEMORY LOCATION

        LD HL,VARBGN                    ;COMPUTE ADDRESS OF
        RLCA                            ;THAT VARIABLE
        ADD A,L                         ;AND RETURN IT IN HL
        LD L,A                          ;WITH C FLAG CLEARED
        LD A,00H
        ADC A,H
        LD H,A                          ;VARIABLE LOCATION IN HL

        ;POP AF                          ;PORT BACK IN 'A'
        ;LD C,A                          ;PORT IS NOW IN C
        LD A,(HL)                       ;Load the value from memory into 'A'

        POP HL                          ;GET THE MEMORY LOCATION BACK
        LD (HL),A
        ;OUT (C),A                       ;WRITE THE BYTE TO THE PORT

        POP BC                          ;RESTORE REGISTERS
        POP AF

        INC DE
        JP RUNSML
POKE5:
        INC DE                          ;NEXT CHARACTER
        LD A,(DE)
        LD B,')'                        ;IS IT THE END OF HEX?
        CP B
        JR Z,POKE6                      ;IF SO, GO TO END
        CALL GET_HEX                    ;IF NOT, GET THE VALUE AND WRITE
        POP HL
        LD (HL),A
        INC HL                          ;NEXT LOCATION TO WRITE
        PUSH HL                         ;STORE THE LOCATION
        JR POKE5                        ;NEXT BYTE.
POKE6:
        POP BC
        POP AF
        INC DE
        JP RUNSML

;-------------------------------------------------------------------------------

CALL_MCODE:
        PUSH AF
        PUSH BC
        PUSH HL
CALL2:
        INC DE
        LD A,(DE)
        LD B,SPACE
        CP B
        JR Z,CALL2
CALL3:
        LD HL,CALL5                     ;SET RETURN VECTOR - I THINK...
        PUSH HL                         ;PLACE IT ON THE STACK FOR RETURN...

        CALL GET_HEX
        LD H,A
        INC DE
        CALL GET_HEX
        LD L,A                          ;LOCATION NOW 'HL'
CALL4:
        PUSH DE                         ;SAVE CURRENT DE LOCATION.
        JP (HL)
CALL5:
        POP HL
        POP DE                          ;KEEPS RETURNING 'WHAT?' ERROR....
        POP BC
        POP AF
        INC DE
        JP RUNSML
;-------------------------------------------------------------------------------

GET_HEX:
        LD A,(DE)
        LD B,A
        INC DE
        LD A,(DE)
        LD C,A
        PUSH DE                         ;SAVE DE LOCATION
        LD D,B                          ;SEND THE ASCII TO CONVERT
        LD E,C
        CALL ASCIIHEX_TO_BYTE           ;BYTE IS RETURNED IN 'A'
        POP DE
        RET

;-------------------------------------------------------------------------------

HEX:                                    ;'HEX' ROUTINE
        PUSH AF
        PUSH BC
HEX2:
        INC DE
        LD A,(DE)
        LD B,SPACE
        CP B
        JR Z,HEX2
HEX3:
        CALL GET_HEX
        PUSH AF                         ; HEX VALUE IS IN THE STACK
HEX4:
        INC DE                          ; NOW FIND THE VARIABLE
        LD A,(DE)
        LD B,','                        ; COMPARE COMA
        CP B
        JR Z,HEX4
        LD B,' '                        ; COMPARE SPACE
        CP B
        JR Z,HEX4
        LD B,'='
        CP B
        JR Z,HEX4

        LD B,40H                        ; IF NOT IT IS VARIABLE
        SUB B                           ; ADJUST FOR MEMORY LOCATION

        LD HL,VARBGN                    ; COMPUTE ADDRESS OF
        RLCA                            ; THAT VARIABLE
        ADD A,L                         ; AND RETURN IT IN HL
        LD L,A                          ; WITH C FLAG CLEARED
        LD A,00H
        ADC A,H
        LD H,A                          ; VARIABLE LOCATION IN HL
        ;LD (HL),00H             ;???
        ;INC HL                  ;???

        POP AF                          ; VALUE BACK IN 'A'
        LD (HL),A                       ; LOAD THE VALUE INTO THE VARIABLE
        INC HL
        LD (HL),00H

        POP BC                          ; RESTORE REGISTERS AND GO.
        POP AF
        INC DE
        JP RUNSML

;-------------------------------------------------------------------------------
HELP_CMDS:
        PUSH AF
        PUSH BC
        PUSH DE
        LD DE,HELP_CMD_MSG1
        CALL PRTSTG
        LD DE,HELP_CMD_MSG2
        CALL PRTSTG
        LD DE,HELP_CMD_MSG3
        CALL PRTSTG
        LD DE,HELP_CMD_MSG4
        CALL PRTSTG
        LD DE,HELP_CMD_MSG5
        CALL PRTSTG
        LD DE,HELP_CMD_MSG6
        CALL PRTSTG
        LD DE,HELP_CMD_MSG7
        CALL PRTSTG
        LD DE,HELP_CMD_MSG8
        CALL PRTSTG
        LD DE,HELP_CMD_MSG9
        CALL PRTSTG
        POP DE
        POP BC
        POP AF
        INC DE
        ;JP RUNSML
        JP RUNNXL
HELP_CMD_MSG1:
        DB      LF,LF,TAB,'TinyBASIC 2.5g Expanded Instructions',LF,LF,CR
HELP_CMD_MSG2:
        DB      TAB,'OUT PP,V',LF,CR
HELP_CMD_MSG3:
        DB      TAB,'IN PP,V',LF,CR
HELP_CMD_MSG4:
        DB      TAB,'HEX HH,V',LF,CR
HELP_CMD_MSG5:
        DB      TAB,'POKE AAAA,V',LF,CR
HELP_CMD_MSG6:
        DB      TAB,'PEEK AAAA,V',LF,CR
HELP_CMD_MSG7:
        DB      TAB,'DELAY',LF,CR
HELP_CMD_MSG8:
        DB      TAB,'CLS',LF,LF,LF,CR
HELP_CMD_MSG9:
        DB      TAB,'PP=HEX PORT  AAAA=HEX ADDR  V=VARIABLE  HH=HEX',LF,LF,CR
;-------------------------------------------------------------------------------
;///////////////////////////////////////////////////////////////////////////////
;-------------------------------------------------------------------------------
;G80-S SPECIFIC ROUTINES.
;-------------------------------------------------------------------------------
TX_RDY:                         ;CHECK IF TRASMIT AVAILABLE, LOOP UNTIL READY
        PUSH AF
        PUSH BC
TX_RDY2:
        LD A,00H
        OUT (SIOA_C),A          ;SELECT REGISTER 0
        IN A,(SIOA_C)           ;READ REGISTER 0
        RRC A
        RRC A
        LD C,01H                ;ROTATE, AND, THEN SUB
        AND C
        SUB C
        JR Z,TX_RDY3            ;RETURN IF AVAILABLE
        JR TX_RDY2              ;OTHERWISE, TRY AGAIN.
TX_RDY3:
        POP BC                  ;RESTORE REGISTERS AND RETURN.
        POP AF
        RET
;-------------------------------------------------------------------------------
RX_RDY:                         ;CHECK FOR INPUT CHARACTER
        PUSH BC
        LD A,00H                ;SETUP THE STATUS REGISTER
        OUT (SIOA_C),A
        IN A,(SIOA_C)           ;LOAD THE STATUS BYTE
        LD C,01H                ;LOAD BYTE TO COMPARE THE BIT, AND COMPARE
        AND C
        SUB C
        JR NZ,RX_RDY3           ;RETURN IF NOT SET
RX_RDY2:
        IN A,(SIOA_D)           ;CHARACTER IS NOW IN 'A'
        OR A                    ;RESET THE 'Z' FLAG
        POP BC
        RET                     ;RETURN
RX_RDY3:
        LD A,00H                ;DATA IS NOT READY
        OR A
        POP BC
        RET

;-------------------------------------------------------------------------------
;///////////////////////////////////////////////////////////////////////////////
;-------------------------------------------------------------------------------
;
LSTROM:                                 ;ALL ABOVE CAN BE ROM
;       ORG  1000H                      ;HERE DOWN MUST BE RAM
        ORG  08000H
        ORG  0FF00H
VARBGN: DS   55                         ;VARIABLE @(0)
BUFFER: DS   64                         ;INPUT BUFFER
BUFEND: DS   1                          ;BUFFER ENDS
STKLMT: DS   1                          ;TOP LIMIT FOR STACKB
        END
