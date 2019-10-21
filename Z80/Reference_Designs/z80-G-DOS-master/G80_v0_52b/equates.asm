;-------------------------------------------------------------------------------
;       DEFINITIONS OF NAMES
;-------------------------------------------------------------------------------
; SIO LABLES
;-------------------------------------------------------------------------------
SIOA_D          EQU     00H    ;SIO CHANNEL A DATA REGISTER
SIOA_C          EQU     02H    ;SIO CHANNEL A CONTROL REGISTER
SIOB_D          EQU     01H    ;SIO CHANNEL B DATA REGISTER
SIOB_C          EQU     03H    ;SIO CHANNEL B CONTROL REGISTER
IF (SIOA_BAUD = 0)
SIOA_CLK        EQU     4CH     ;SIO 1/16 CLOCK
ENDIF
IF (SIOA_BAUD = 1)
SIOA_CLK        EQU     8CH     ;SIO 1/32 CLOCK
ENDIF
IF (SIOA_BAUD = 2)
SIOA_CLK        EQU     0CCH    ;SIO 1/64 CLOCK
ENDIF
IF (SIOB_BAUD = 0)
SIOB_CLK        EQU     4CH     ;SIO 1/16 CLOCK
ENDIF
IF (SIOB_BAUD = 1)
SIOB_CLK        EQU     8CH     ;SIO 1/32 CLOCK
ENDIF
IF (SIOB_BAUD = 2)
SIOB_CLK        EQU     0CCH    ;SIO 1/64 CLOCK
ENDIF
;-------------------------------------------------------------------------------
; PIO LABELS
;-------------------------------------------------------------------------------
PIOA            EQU     80H    ;PIO PORT A
PIOB            EQU     81H    ;PIO PORT B
PIOC            EQU     82H    ;PIO PORT C
PIOCMD          EQU     83H    ;PIO CONTROL PORT
;-------------------------------------------------------------------------------
; OS LABELS
;-------------------------------------------------------------------------------
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


MON_LOOP        EQU     MAIN_LOOP

;-------------------------------------------------------------------------------
; LABELS FOR TINYBASIC
;-------------------------------------------------------------------------------
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
