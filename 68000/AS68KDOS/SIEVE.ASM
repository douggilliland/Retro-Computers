***********************************************
*
*       sieve of eratosthenes
*
*       flags:     a0       ;pointer to array
*       iter:      d0
*       count:     d1
*       i:         d2
*       prime:     d3
*       k:         d4
*
***********************************************

        org     $1000
size    equ     8191            ;array size
flags   ds      size            ;array of boolean
iter    equ     10              ;10 iterations
TRUE    equ     %00000001       ;
FALSE   equ     %00000000       ;
tutor   equ     228             ;return to OS

        org     $3000
start   move    #iter,d0        ;set max iterations
        movea.l #flags,a0       ;point to flags
again   moveq   #0,d1           ;count <-- 0
        moveq   #0,d2           ;i <-- 0
setflg  move.b  #TRUE,0(a0,d2)  ;flags[i] <-- TRUE
        addq    #1,d2           ;i <-- i + 1
        cmp     #size,d2        ;i > size?
        ble.s   setflg          ;
        moveq   #0,d2           ;i <-- 0
next    cmpi.b  #TRUE,0(a0,d2)  ;flags[i] = TRUE?
        bne.s   notrue          ;
        move    d2,d3           ;prime <-- i + i + 3
        add     d2,d3           ;
        addq    #3,d3           ;
        move    d2,d4           ;k <-- i + prime
        add     d3,d4           ;
more    cmp     #size,d4        ;k <= size?
        bgt.s   nxtcnt          ;
        move.b  #FALSE,0(a0,d4) ;
        add     d3,d4           ;k <-- k + prime
        bra.s   more            ;
nxtcnt  addq    #1,d1           ;count <-- count + 1
notrue  addq    #1,d2           ;i <-- i + 1
        cmp     #size,d2        ;i > size?
        ble.s   next            ;
        subq    #1,d0           ;iter <-- iter - 1
        bne     again           ;last iteration?
        move    #tutor,d7       ;escape to supervisor
        trap    #14             ;
        end
