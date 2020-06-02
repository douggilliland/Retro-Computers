
* Program.: SP-MAIN.CMD 
* Author..: Debby Moody
* Date....: 02/06/84 
* Notice..: Copyright 1984, ASHTON-TATE. All rights reserved.

SET ESCAPE OFF
SET TALK OFF 
SET BELL OFF
SET INTENSITY OFF
DO WHILE T

ERASE
@  1, 0 SAY "========================================"
@  1,40 SAY "========================================"
@  2, 0 SAY "||"
@  2,78 SAY "||" 
@  2,15 SAY "D B A S E    I I    S A M P L E    P R O G R A M S" 
@  3, 0 SAY "========================================" 
@  3,40 SAY "========================================" 
@  4, 0 SAY "||" 
@  4,78 SAY "||" 
@  5, 0 SAY "||" 
@  5,78 SAY "||" 
@  6, 0 SAY "||" 
@  6,78 SAY "||"
@  7, 0 SAY "||"
@  7,78 SAY "||"
@  8, 0 SAY "||"
@  8,78 SAY "||"
@  9, 0 SAY "||" 
@  9,78 SAY "||" 
@ 10, 0 SAY "||" 
@ 10,78 SAY "||" 
@ 11, 0 SAY "||" 
@ 11,78 SAY "||" 
@ 12, 0 SAY "========================================" 
@ 12,40 SAY "========================================"
@  5,29 SAY " 0. exit"
@  6,29 SAY " 1. mailing labels"
@  7,29 SAY " 2. inventory program"
@  8,29 SAY " 3. checkbook program"
@  9,29 SAY " 4. help"
STORE  5 TO select
DO WHILE select < 0 .OR. select >  4
   STORE " " TO mselect
   @ 12,33 SAY " select : : "
   @ 12,41 GET mselect PICTURE "#" 
   READ 
   STORE VAL(mselect) TO select
ENDDO

DO CASE
   CASE select= 0
      SET TALK ON
      SET INTENSITY ON
      SET ESCAPE ON
      SET BELL ON
      CLEAR
      RETURN
   CASE select= 1
      DO Lb-print
   CASE select= 2
      DO In-main
   CASE select= 3
      DO Cb-main
   CASE select= 4
      DO Sp-help
ENDCASE

ENDDO T
* EOF SP-MAIN.CMD
