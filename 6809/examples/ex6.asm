; Bubble sort example program from the book "Programming the 6809" by
; Rodnay Zaks and William Labiak, p.284
;
; Note that the table length cannot be greater than 127.
; Data is sorted as signed bytes, e.g. $80 is interpreted as -1. If
; you want unsigned comparison, replace "bge noswit" with "bhs noswit".

        org     $1000

bubble  ldx     #base           ; Get table
        ldb     #length         ; Get length
        decb
        leax    b,x             ; Point to end
        clr     exchg           ; Clear exchange flag
next    lda     ,x              ; A = current entry
        cmpa    ,-x             ; Compare with next
        bge     noswit          ; Go to noswitch if current >= next (signed)
        pshs    b               ; Save B
        ldb     ,x              ; Get next
        stb     1,x             ; Store in current
        sta     ,x              ; Store current in next
        puls    b               ; Restore B
        inc     exchg           ; Set exchange flag
noswit  decb                    ; Decrement B
        bne     next            ; Continue until zero
        tst     exchg           ; Exchange = 0?
        bne     bubble          ; Restart of no = 0
        rts

; Storage

exchg   rmb     1               ; Exchange flag

; Data to be sorted (random)

        org     $2000

length  equ      100             ; Number of data items

base    fcb     203, 187, 184, 205, 165, 126,  19, 253
        fcb      30,  24, 152, 140, 103,  65, 131, 131
        fcb     189, 161,  45,  44,  37, 216, 199, 226
        fcb     247, 179, 164, 230,  78,  28,  64, 160
        fcb     188,   4, 199,  50,  77, 221,  73, 204
        fcb      64, 215,  96, 151, 124, 135, 111, 190
        fcb      52,  19,  67,  88, 174, 167,  70, 183
        fcb     171,  54, 245, 253, 100,  81, 227,  85
        fcb     149,  41, 239, 197, 148, 100, 240, 249
        fcb     223, 249, 138, 242,  34, 175, 101,   1
        fcb      49, 106, 131, 243, 229, 245, 224, 225
        fcb      82, 105,  36, 116,  94, 215, 151,  38
        fcb      30, 103,  10,   7
