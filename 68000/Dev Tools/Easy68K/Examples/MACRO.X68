*-----------------------------------------------------------
* Title        :  Macro
* Written by   :  Chuck Kelly
* Date Created :  Jan-6-2006
* Description  :  Demo of macros
* Macro definitions should be placed at the top of the source file.
* Dec-25-2012 by CK, Uses SIMHALT
*-----------------------------------------------------------
        OPT     MEX
CODE    EQU     0
TEXT    EQU     1

    SECTION     TEXT
    ORG         $2000
    SECTION     CODE
    ORG         $1000

* print the text string
* use ENDL as second argument to add return and linefeed
PRINT   MACRO
    SECTION     TEXT
MSG\@    DC.B    '\1'
    IFARG    2
      IFC      '\2','ENDL'
        DC.B    $D,$A
      ENDC
    ENDC
    DC.B    0
    SECTION     CODE
    MOVEM.L     D0/A1,-(SP)
    LEA         MSG\@,A1
    MOVE.B      #14,D0
    TRAP        #15
    MOVEM.L     (SP)+,D0/A1
    ENDM

* print the number
PRINTN    MACRO
    SECTION     CODE
    MOVEM.L     D0/D1,-(SP)
    IFNC '\1','D1'          if some register other than D1
      MOVE.L    \1,D1       put number to display in D1
    ENDC
    MOVE.B  #3,D0
    TRAP    #15             display number in D1
    MOVEM.L (SP)+,D0/D1
    ENDM


* Usage POWER N, P
* Raises N to the P power
* Resulting number is in D1
POWER    MACRO
    MOVEM.L     D0/D2,-(A7) save
    IFNC '\2','D2'
      MOVE.W    \2,D2
    ENDC
    IFNC '\1','D1'          if first param is not D1
      MOVE.W    \1,D1
    ENDC
    IFNC '\1','D0'
      MOVE.W    \1,D0
    ENDC
    WHILE.W D2 <HI> #1 DO.S
      MULU  D0,D1           compute power
      SUB.W #1,D2
    ENDW
    MOVEM.L (A7)+,D0/D2
    ENDM

**********************
*    Program Start
**********************
START
    PRINT   <Macro Demonstration Program>,ENDL

    POWER   #4,#3
    PRINT   <4^3 = >
    PRINTN  D1

    SIMHALT                 Halt the program
    END     START





*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
