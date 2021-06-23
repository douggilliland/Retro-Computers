
            .export _unlink
            .export _remove

            .code
_unlink:
_remove:
            tsx
            ldx 2,x
            jsr nametosysfcb
            ldx #$A840		; system FCB
            clr 1,x
            ldab #12
            jmp fms_and_errno
