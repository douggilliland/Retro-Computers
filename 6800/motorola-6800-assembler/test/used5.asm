*
*	    Copied from:
*	    MEK6802D5 Microcomputer Evaluation Board User's Manual
*	    Page 3-8
*
*	    Assemble with the following command:
*		as0 used5.asm -l cre c s
*
        nam     used5
*       Options set in file override command line option settings
*        opt     c       * options must be in lower case
        org     $0
disbuf  equ     $e41d
diddle  equ     $f0a2
mnptr   equ     $e419
put     equ     $f0bb
*
beg     ldaa    #$3e     "U"
        staa    disbuf   store to first display
        ldaa    #$6d     "S"
        staa    disbuf+1
        ldaa    #$79     "E"
        staa    disbuf+2
        ldaa    #$00     blank
        staa    disbuf+3
        ldaa    #$5e     "D"
        staa    disbuf+4
        ldaa    #$6d     "5"
        staa    disbuf+5 store to last display
        ldaa    #diddle  adder of diddle routine
        stx     mnptr    establish as active sub of "PUT"
        jmp     put      call display routine
        end
