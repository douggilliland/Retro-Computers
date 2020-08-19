
START: ORG    $0000
    DC.L      $0      ; Initial Stack Pointer
    DC.L      $8      ; Initial Program Counter
    
    ADDQ.W    #1,d0
    MOVE.W   d0,$dff180
    BRA.S    START

    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
