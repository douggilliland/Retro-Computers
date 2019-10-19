;-------------------------------------------------------------------------------
; MESSAGES
;-------------------------------------------------------------------------------
CS_MSG:
        IF (BOARD = 0)
        DB      ESC,"[2J",ESC,"[H",00H
        ENDIF
        IF (BOARD = 1)
        DB      CS,00H
        ENDIF
SIGNON_MSG:
        DB      LF
        IF (BOARD = 0)
        DB      "G80-S/USB Computer by Doug Gabbard - 2017",CR,LF,LF
        ENDIF
        IF (BOARD = 1)
        DB      "G80-UVK Computer by Doug Gabbard - 2017",CR,LF,LF
        ENDIF
VERSION:
        DB      "G-DOS Prototype v0.52b",CR,LF
        DB      "Dev-Team: Doug Gabbard, Mike Veit, & Amardeep Chana",CR,LF,LF
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
        DB      CR,LF," G80 COMMANDS:",CR,LF,LF
        DB      " LANGUAGES:",CR,LF
        IF (BASIC = 1)
        DB      TAB,"BASIC - TINY BASIC 2.5g",CR,LF
        ENDIF
        IF (CFORTH = 1)
        DB      TAB,"FORTH - CamelForth v1.2a",CR,LF,LF
        ENDIF
        DB      " MONITOR:",CR,LF
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
        IF (BOARD = 0)
        DB      TAB,"PIO (80-83H)",CR,LF
        ENDIF
        DB      00H

;-------------------------------------------------------------------------------
