        .z80
        ORG     0100

xon:    out     (095H),a    ;graphic screen = ON
        jp      0000
