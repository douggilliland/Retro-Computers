; Example of calling machine language routine from BASIC.
; This example takes an integer value passed to it from BASIC,
; multiplies it by 2, and returns the result.
; Code is relocatable, but here use origin of $7530 (30000 decimal)
; as that is what is used in the example.
; For more background see chapter 34 of "Getting Started With Extended Color Basic".
; Will run standalone as the BASIC program ex4.bas

; Sample program run:
;
; VALUE TO PASS? 9
; RESULT WAS 18 
; VALUE TO PASS? 88
; RESULT WAS 176 

; Another simple example, call dissassembler in ROM from BASIC:
; POKE &H5FF0,&H75
; POKE &H5FF1,&H30
; EXEC &HC006

INTCNV  EQU     $DB74           ; Gets integer passed in USR() function and returns in D
GIVABF  EQU     $DC7B           ; Takes value in D and returns value to BASIC

        ORG     $7530           ; Decimal 30000

        JSR     INTCNV          ; Get value passed in basic
        ASLB                    ; 16-bit shift of D: Rotate B, MSB into Carry
        ROLA                    ; Rotate A, Carry into LSB
        JMP     GIVABF          ; Return to BASIC
