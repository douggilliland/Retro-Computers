

            .export _getchar

            .code
            
_getchar:
            jsr __getc
            clra
            rts
