*-----------------------------------------------------------
* Title         : Tutorial 4 for EASy68k
* Written by    : Chuck Kelly
* Date Created  : Nov-10-2012
* Feb-14-2013 by CK, Comment change
* Description   : This program demonstrates how to pass
* parameters and return values from a subroutine.
*    Adder1 subroutine uses registers to pass the parameters.
*    Adder2 subroutine uses the stack to pass the parameters.
* This program is public domain.
*-----------------------------------------------------------

START   ORG $1000

    * Input 2 numbers and add them with Adder1 subroutine.
    * The parameters and return value are passed using registers
    move    #14,D0      task 14, display string
    lea     prompt,A1   address of string to display in A1
    trap    #15         trap #15 performs task

    move    #4,D0       task 4, input number into D1.L
    trap    #15         perform task
    move.l  D1,D2       D2 = num1

    move    #14,D0      task 14, display string
    lea     prompt,A1   address of string to display in A1
    trap    #15         trap #15 performs task

    move    #4,D0       task 4, input number into D1.L
    trap    #15         perform task, D1 = num2

    bsr     Adder1      D1 = D1 + D2

    move    #14,D0      task 14, display string
    lea     result,A1   address of string to display in A1
    trap    #15         trap #15 performs task
    move    #3,D0       task 3, display number in D1.L
    trap    #15         trap #15 performs task

    bsr     newLine

    * Input 2 numbers and add them with Adder2 subroutine.
    * The parameters and return value are passed on the stack
    move    #14,D0      task 14, display string
    lea     prompt,A1   address of string to display in A1
    trap    #15         trap #15 performs task

    move    #4,D0       task 4, input number into D1.L
    trap    #15         perform task
    move.l  D1,-(SP)    push num1

    move    #14,D0      task 14, display string
    lea     prompt,A1   address of string to display in A1
    trap    #15         trap #15 performs task

    move    #4,D0       task 4, input number into D1.L
    trap    #15         perform task
    move.l  D1,-(SP)    push num2
    move.l  #0,-(SP)    make room for sum on the stack
    
    bsr     Adder2      sum = num1 + num2
    move.l  (SP)+,D1    pull sum from stack, D1 = sum
    lea     (8,SP),SP   clean up the stack

    move    #14,D0      task 14, display string
    lea     result,A1   address of string to display in A1
    trap    #15         trap #15 performs task

    move    #3,D0       task 3, display number in D1.L
    trap    #15         trap #15 performs task

    bsr     newLine

    SIMHALT				stop program execution

*------------------------------------
* Add the number in register D1 to the number in register D2.
* The sum is returned in register D1. 
* D1 = D1 + D2
Adder1
    add.l   d2,d1
    rts                         return

*------------------------------------
* Add two numbers passed as parameters on the stack.
* The sum is returned on the stack. 
* The OFFSET directive is used to access the parameters by name.
* 4 bytes for A0 saved by link, 4 bytes for return address
        offset  4+4
sum     ds.l    1 
num2    ds.l    1 
num1    ds.l    1 
        org     *           end the offset

Adder2
    link    A0,#0           create stack frame 
    move.l  D0,-(SP)        save D0 
    move.l  (num1,A0),D0    access num1 parameter
    add.l   (num2,A0),D0    add num2 parameter
    move.l  D0,(sum,A0)     store result in sum parameter
    move.l  (SP)+,D0        restore D0
    unlk    A0
    rts                     return

*------------------------------------
* Subroutine to display Carriage Return and Line Feed
newLine 
    movem.l d0/a1,-(SP)         push d0 & a1
    move    #14,d0              task number into D0
    lea     crlf,a1             address of string
    trap    #15                 display return, linefeed
    movem.l (SP)+,d0/a1         restore d0 & a1
    rts                         return

*------------------------------------
* Variable storage and strings
* ds (define storage) is used to reserve memory for variables
* dc (define constant) is used to place data in memory
prompt  dc.b    'Enter number: ',0  null terminated string
result  dc.b    'The sum is: ',0
crlf    dc.b    $d,$a,0         carriage return & line feed, null

        END     START           end of program with start address specified




*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
