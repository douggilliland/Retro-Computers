        list    off
        list    noxref  ; (use this line only with ASMB version 3.08 or later)

; mode definitions for TP tape devices

; c-register values for .GETMODE and .SETMODE system calls
tpmmin          equ     -60             ; minimum mode number
TPABORT         equ     tpmmin + 0      ; re-initialize tape driver
TPFMARK         equ     tpmmin + 2      ; write file mark
TPSECURE        equ     tpmmin + 3      ; security erase
TPREWIND        equ     tpmmin + 4      ; rewind
TPUNLOAD        equ     tpmmin + 5      ; rewind and unload
TPMODE          equ     tpmmin + 6      ; mode bits
TPFILNO         equ     tpmmin + 7      ; file number
TPBLKNO         equ     tpmmin + 8      ; block number
TPOBLKLN        equ     tpmmin + 9      ; block length for next block written
TPIBLKLN        equ     tpmmin + 10     ; block length of first block read
TPOBLKS         equ     tpmmin + 11     ; number of blocks written
TPSTAT          equ     tpmmin + 12     ; get error (status-2, status-1)

tpgmmin         equ     TPMODE          ; minimum getmode number
tpgmmax         equ     TPSTAT          ; maximum getmode number

tpsmmin         equ     TPABORT         ; minimum setmode number
tpsmmax         equ     TPOBLKLN        ; maximum setmode number


; TPMODE bits
EOFCLOSE        equ     7               ; write EOF to tape when device closes

; TPSTAT status bits, returned in e-register (obtained from PIO input port A)
DRVBUSY         equ     7               ; drive busy
WRRDY           equ     6               ; FIFO ready for input (used for write)
RDRDY           equ     5               ; FIFO output ready (used for read)
LOADPT          equ     4               ; load point
FBUSY           equ     3               ; formatter busy
ONLINE          equ     2               ; on line
IDENT           equ     1               ; ident?
RDY             equ     0               ; ready

; TPSTAT status bits, returned in d-register (obtained from PIO input port B)
HISPEED         equ     7               ; high speed status
HARDERR         equ     5               ; hard error
FLMARK          equ     4               ; file mark
CORERR          equ     3               ; correctable error
WRPROT          equ     2               ; file write-protected
EOT             equ     1               ; end of tape
RWINDING        equ     0               ; rewinding

        list    xref    ; (use this line only with ASMB version 3.08 or later)
        list    on
