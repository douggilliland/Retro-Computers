*-----------------------------------------------------------
* Title         : Tutorial 3 for EASy68k
* Written by    : Chuck Kelly
* Date Created  : May-06-2004
* Dec-25-2012 by CK, Uses SIMHALT
* Description   : 
*
* A simple number guessing game. The program generates a random number between 1 and 100
* and asks the player to guess the number. After each guess the program displays higher or lower
* until the player guesses the correct number.
*
* Demonstrates Structured Assembly, SECTION directive & Macros with EASy68K
*-----------------------------------------------------------
    OPT     MEX         Expand macro calls
    OPT     SEX         Expand structured statements

CODE    EQU     0
TEXT    EQU     1
CR      EQU     $0D
LF      EQU     $0A


    SECTION TEXT
    ORG     $800        set the address for TEXT data

    SECTION CODE
    ORG     $2000       set the address for program code

PRINT   MACRO
    lea     \1,a1
    move.b  #14,d0
    trap    #15
    ENDM

GETNUM  MACRO
    move.b  #4,d0       get user guess in D1.L
    trap    #15
    ENDM

*----------------------------------------------------
* Program execution begins here
*----------------------------------------------------
START

  repeat
    PRINT instr_Msg     print instructions

    * generate random number for player to guess
    * Uses timer as random number generator. This may not be the best way to
    * generate a random number but it will work for this demonstration.
    * Trap code 8 returns time in hundredths of a second since midnight in D1.L

    move.b  #8,d0
    trap    #15
    and.l   #$5FFFFF,d1 prevent overflow in divu
    divu    #100,d1     time count / 100
    swap    d1          swap upper and lower words of D1 to put remainder in low word
    addq.w  #1,d1       d1.w contains number from 1 to 100
    move    d1,d2       d2 = d1

    repeat
      PRINT enterMsg    Display 'enter guess' prompt
      GETNUM            get user guess in D1.L

      if d1 <ne> #0 then
        if d1 <hi> d2 then  if the player guessed hi
          PRINT bigMsg      Display 'Too Big'
        else
          if d1 <lo> d2 then    if the player guessed lo
            PRINT smallMsg      Display 'Too Small'
          else                  The user guessed the number
            PRINT goodMsg       Display 'Good Guess'
          endi
        endi
      endi
    until d1 <eq> #0 OR d1 <eq> d2 do
  until d1 <eq> #0 do

    SIMHALT

    SECTION     TEXT
instr_Msg   dc.b    CR,LF
        dc.b    '----- Number guessing game -----',CR,LF
        dc.b    ' Guess the number from 1 to 100',CR,LF
        dc.b    ' Enter a 0 to quit the game',CR,LF,CR,LF,0

enterMsg    dc.b    CR,LF,'Enter your guess: ',0
goodMsg     dc.b    CR,LF,'Good guess, that is correct!',CR,LF,0
bigMsg      dc.b    CR,LF,'Your guess is too big',CR,LF,0
smallMsg    dc.b    CR,LF,'Your guess is too small',CR,LF,0
        
    END     START



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
