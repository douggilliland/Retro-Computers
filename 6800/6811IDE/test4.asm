; test index register and interrupts

    ldx #$0020
    ldx $0020
    ldx #$01FE
    stx $0100    ; 

    inc $0100
    inc $0101

    ldx $0100    ; 

    ldx #$0100
    stx 0,x        ; 
    stx 2,x        ; 
    
    ldx #$FFFB
    ldaa #a
    staa ,x
    swi
    incb
    incb
    ldx #$0100
b   jmp 4,x     ; 
   
    .org $40
a   ldaa #7
    rti


    .org $104
    inca
    jmp b
    nop