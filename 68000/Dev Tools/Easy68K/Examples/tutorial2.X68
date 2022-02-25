*-----------------------------------------------------------
* Title         : Tutorial 2 for EASy68k
* Written by    : Chuck Kelly
* Date Created  : Mar-07-2003
* Dec-25-2012 by CK, Uses SIMHALT
* Description   :
*
* A simple number guessing game. The program generates a random number between 1 and 100
* and asks the player to guess the number. After each guess the program displays higher or lower
* until the player guesses the correct number.
*
* Demonstrates Input/Output & Branching.
*-----------------------------------------------------------
    ORG     $1000

start   move.b  #14,d0      Display instructions
    lea     instrMsg,a1
    trap    #15

* Generate random number for player to guess
* Uses timer as random number generator. This may not be the best way to
* generate a random number but it will work for this demonstration.
* Trap code 8 returns time in hundredths of a second since midnight in D1.L

    move.b  #8,d0
    trap    #15
    and.l   #$5FFFFF,d1     prevent overflow in divu
    divu    #100,d1         time count / 100
    swap    d1              swap upper and lower words of D1 to put remainder in low word
    addq.w  #1,d1           d1.w contains number from 1 to 100
    move    d1,d2           d2 = d1

again:
    move.b  #14,d0          Display 'enter guess' prompt
    lea     enterMsg,a1
    trap    #15

    move.b  #4,d0           get user guess in D1.L
    trap    #15

    cmp     #0,d1           if exit
    beq     end

    cmp     d2,d1           compare the user guess in d1 to the number in d2
    bhi     tooBig          if the guess is too big
    blo     tooSmall        if the guess is too small

* The user guessed the number
    move.b  #14,d0          Display 'Good Guess' message
    lea     goodMsg,a1
    trap    #15

    bra     start           goto start

tooBig  move.b  #14,d0      Display 'Too Big'
    lea     bigMsg,a1
    trap    #15

    bra     again           guess again

tooSmall    move.b  #14,d0  Display 'Too Small'
    lea     smallMsg,a1
    trap    #15

    bra     again           guess again

end     SIMHALT

CR      EQU     $0D
LF      EQU     $0A

instrMsg    dc.b    CR,LF
    dc.b    '----- Number guessing game -----',CR,LF
    dc.b    ' Guess the number from 1 to 100',CR,LF
    dc.b    ' Enter a 0 to quit the game',CR,LF,CR,LF,0

enterMsg    dc.b    CR,LF,'Enter your guess: ',0
goodMsg     dc.b    CR,LF,'Good guess, that is correct!',CR,LF,0
bigMsg      dc.b    CR,LF,'Your guess is too big',CR,LF,0
smallMsg    dc.b    CR,LF,'Your guess is too small',CR,LF,0
        
    END     start




*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
