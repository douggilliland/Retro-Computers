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
        CALL GET_KEY                    ;GET A CHARACTER
        CP CR                           ;DONT CARE ABOUT CR
        JR Z,IH_LOAD_LOOP
        CP LF                           ;...OR LF
        JR Z,IH_LOAD_LOOP
        CP SPACE                        ;...OR A SPACE
        JR Z,IH_LOAD_LOOP
        CALL TO_UPPER                   ;CONVERT TO UPPER CASE
        CALL PRINT_CHAR                 ;ECHO CHARACTER
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
        CALL GET_KEY                    ;READ A CHARACTER
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
        CALL PRINT_CHAR                 ;PRINT THE NIBBLE
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
        CALL GET_KEY                            ;GET A CHARACTER
        CP CR                                   ;SKIP CR
        JR Z,GETS_LOOP                          ;LF WILL TERMINATE INPUT
        CALL TO_UPPER
        CALL PRINT_CHAR                         ;ECHO CHARACTER
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
        CALL GET_KEY                    ;GET RID OF CHARACTER STILL IN BUFFER
        CALL GET_KEY
        POP AF                          ;RESTORE REGISTERS
        POP DE
        JR IH_OUTSPC                    ;PRINT MEMORY MSG AND EXIT

;-------------------------------------------------------------------------------
;///////////////////////////////////////////////////////////////////////////////
;-------------------------------------------------------------------------------

