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

        IF (BASIC = 1)
        LD C,TOK_BASIC          ;TEST FOR BASIC
        CP C
        JP Z,START              ;START TINY BASIC
        ENDIF

        IF (CFORTH = 1)
        LD C,TOK_FORTH          ;TEST FOR FORTH
        CP C
        JP Z,FORTH              ;START CamelForth
        ENDIF

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
        DB      "CALL",00H
        DB      "CLS",00H
        DB      "DUMP",00H
        DB      "IN",00H
        DB      "HELP",00H
        DB      "HEXLOAD",00H
        DB      "MODMEM",00H
        DB      "OUT",00H
        DB      "RAMCLR",00H
        DB      "RESTART",00H
        DB      "TEST",00H

        IF (BASIC = 1)
        DB      "BASIC",00H
        ENDIF
        IF (CFORTH = 1)
        DB      "FORTH",00H
        ENDIF
CMD_TABLE_END:
        DB      00H
CMD_ERROR:
        LD HL,CMD_ERROR_MSG
        CALL PRINT_STRING
        CALL PRINT_PROMPT
        RET

;COMMAND TOKEN VALUES

TOK_CALL        EQU     01CH
TOK_CLS         EQU     0E2H
TOK_DUMP        EQU     036H
TOK_IN          EQU     097H
TOK_HELP        EQU     029H
TOK_HEXLOAD     EQU     05H
TOK_MODMEM      EQU     0BFH
TOK_OUT         EQU     0F8H
TOK_RAMCLR      EQU     0C1H
TOK_RESTART     EQU     025H
TOK_TEST        EQU     040H

IF (BASIC = 1)
TOK_BASIC       EQU     062H
ENDIF
IF (CFORTH = 1)
TOK_FORTH       EQU     083H
ENDIF
;-------------------------------------------------------------------------------



