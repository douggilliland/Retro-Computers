;
; fig-FORTH 6800 initial screens for RAM disk
;
NBLK	equ	4		;# of disc buffer blocks for virtual memory
MEMEND	equ	132*NBLK+$3000	;end of RAM for fig-FORTH
;
;  each block is 132 bytes in size, holding 128 characters
;
;
	org	MEMEND	;simulating disc in RAM above fig-FORTH
;
; SCREEN 0
	fcc	"0) Index to screens in RAM disk                                 "
	fcc	"1)                                                              "
	fcc	"2)                                                              "
	fcc	"3)                                                              "
	fcc	"4) ERROR MESSAGES  ( fig-FORTH default, 1 WARNING !  to use )   "
	fcc	"4) ERROR MESSAGES  ( fig-FORTH default, 1 WARNING !  to use )   "
	fcc	"6)                                                              "
	fcc	"7)                                                              "
	fcc	"8)                                                              "
	fcc	"9)                                                              "
	fcc	"10)                                                             "
	fcc	"11)                                                             "
	fcc	"12)                                                             "
	fcc	"13)                                                             "
	fcc	"14)                                                             "
	fcc	"15)                                                             "
;
; SCREEN 1
	fcc	" 1 WARNING !                                                    " 
	fcc	"                                                                " 
	fcc	" VOCABULARY DEBUG DEFINITIONS                                   " 
	fcc	"                                                                " 
	fcc	" ( addr n -- )                                                  " 
	fcc	" : DUMPHEX BASE @ >R HEX                                        " 
	fcc	"           0 DO DUP I + C@ 0 <# # # #> TYPE SPACE LOOP          " 
	fcc	"           DROP R> BASE ! ;                                     " 
	fcc	"                                                                " 
	fcc	" FORTH DEFINITIONS                                              " 
	fcc	"                                                                " 
	fcc	"                                                                " 
	fcc	"                                                                " 
	fcc	"                                                                " 
	fcc	"                                                                " 
	fcc	" ;S                                                             " 
;
; SCREEN 2
	fcc	"                                                                " 
	fcc	"                                                                " 
	fcc	"                                                                " 
	fcc	"                                                                " 
	fcc	"                                                                " 
	fcc	"                                                                " 
	fcc	"                                                                " 
	fcc	"                                                                " 
	fcc	"                                                                " 
	fcc	"                                                                " 
	fcc	"                                                                " 
	fcc	"                                                                " 
	fcc	"                                                                " 
	fcc	"                                                                " 
	fcc	"                                                                " 
	fcc	"                                                                " 
;
; SCREEN 3
	fcc	"                                                                " 
	fcc	"                                                                " 
	fcc	"                                                                " 
	fcc	"                                                                " 
	fcc	"                                                                " 
	fcc	"                                                                " 
	fcc	"                                                                " 
	fcc	"                                                                " 
	fcc	"                                                                " 
	fcc	"                                                                " 
	fcc	"                                                                " 
	fcc	"                                                                " 
	fcc	"                                                                " 
	fcc	"                                                                " 
	fcc	"                                                                " 
	fcc	"                                                                " 
;
; SCREEN 4
	fcc	"( ERROR MESSAGES )                                              " 
	fcc	"DATA STACK UNDERFLOW                                            " 
	fcc	"DICTIONARY FULL                                                 " 
	fcc	"ADDRESS RESOLUTION ERROR                                        " 
	fcc	"HIDES DEFINITION IN                                             " 
	fcc	"NULL VECTOR WRITTEN                                             " 
	fcc	"DISC RANGE?                                                     " 
	fcc	"DATA STACK OVERFLOW                                             " 
	fcc	"DISC ERROR!                                                     " 
	fcc	"CAN'T EXECUTE A NULL!                                           " 
	fcc	"CONTROL STACK UNDERFLOW                                         " 
	fcc	"CONTROL STACK OVERFLOW                                          " 
	fcc	"ARRAY REFERENCE OUT OF BOUNDS                                   " 
	fcc	"ARRAY DIMENSION NOT VALID                                       " 
	fcc	"NO PROCEDURE TO ENTER                                           " 
	fcc	"               ( WAS REGISTER )                                 " 
;
; SCREEN 5
	fcc	"                                                                " 
	fcc	"COMPILATION ONLY, USE IN DEF                                    " 
	fcc	"EXECUTION ONLY                                                  " 
	fcc	"CONDITIONALS NOT PAIRED                                         " 
	fcc	"DEFINITION INCOMPLETE                                           " 
	fcc	"IN PROTECTED DICTIONARY                                         " 
	fcc	"USE ONLY WHEN LOADING                                           " 
	fcc	"OFF CURRENT EDITING SCREEN                                      "  
	fcc	"DECLARE VOCABULARY                                              " 
	fcc	"DEFINITION NOT IN VOCABULARY                                    " 
	fcc	"IN FORWARD BLOCK                                                " 
	fcc	"ALLOCATION LIST CORRUPTED: LOST                                 " 
	fcc	"CAN'T REDEFINE nul!                                             " 
	fcc	"NOT FORWARD REFERENCE                                           " 
	fcc	"              ( WAS IMMEDIATE )                                 " 
	fcc	"                                                                " 
;
; SCREEN 6
	fcc	"                                                                " 
	fcc	"                                                                " 
	fcc	"                                                                " 
	fcc	"                                                                " 
	fcc	"                                                                " 
	fcc	"                                                                " 
	fcc	"                                                                " 
	fcc	"                                                                " 
	fcc	"                                                                " 
	fcc	"                                                                " 
	fcc	"                                                                " 
	fcc	"                                                                " 
	fcc	"                                                                " 
	fcc	"                                                                " 
	fcc	"                                                                " 
	fcc	"                                                                " 
;
; SCREEN 7
	fcc	"                                                                " 
	fcc	"                                                                " 
	fcc	"                                                                " 
	fcc	"                                                                " 
	fcc	"                                                                " 
	fcc	"                                                                " 
	fcc	"                                                                " 
	fcc	"                                                                " 
	fcc	"                                                                " 
	fcc	"                                                                " 
	fcc	"                                                                " 
	fcc	"                                                                " 
	fcc	"                                                                " 
	fcc	"                                                                " 
	fcc	"                                                                " 
	fcc	"                                                                " 
;
;
RAMDEN	equ	*
RAMDSZ	equ	RAMDEN-MEMEND
;
;	END
;
