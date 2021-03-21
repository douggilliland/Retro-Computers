        .z80
        ORG     0100

XOFF:   out     (094H),a    ;graphic screen = OFF
        jp      0000
