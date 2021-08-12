; Simple 6809 assembler example.
; Does not do anything meaningful, but can be used for testing file
; loading and running from ASSIST09.

        ORG     $1000           ; Start address

START:  LDA     #$00
        TFR     A,DP
        LDA     #$01
        LDB     #$02
        LDX     #$0304
        LDY     #$0506
        LDU     #$0708
        ANDCC   #$00
        NOP
        NOP
        RTS
