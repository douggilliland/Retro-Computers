        .Z80
        org  0100h


; -----------
; Definitions
; -----------

MaxGraRAM  equ 19200    ; Length Graphic-RAM


; -----------------------------------------------
; Clear the graphic screen with 'data', uses
; internal (par3), (par5) for calling "PutScrRC"
; to clear the Screen, (par3) & (par5) are saved
; and restored after clearing.
;
; Param: par1  par2    par3   par4  par5
; Entry:  --    --     count  byte  addr
; Exit:   --
; -----------------------------------------------
GClrScr:
        ld      (oldsp),sp
        ld      sp,newsp
        push    hl            ;save hl

        ld      hl,0000
        ld      (par5),hl     ;Start-Address = 0000h

        ld      hl,MaxGraRAM  ;clear the whole screen
        ld      (par3),hl
        call    PutScrRC

        pop     hl
        ld      sp,oldsp
        jp      0000

; ------------------------------------------------------------
; Write to graphic screen from addr to addr+count with 'byte'.
; This could be used to write any byte to graphic screen.
;
; Param: par1  par2    par3   par4  par5
; Entry:  --    --     count  byte  addr
; Exit:   --
; ------------------------------------------------------------
PutScrRC:
        push    hl          ;save used register
        push    de
        push    af

        ld      de,(par5)   ; get start-address
        ld      hl,(par3)   ;Length RAM-Block

PutScr1:
        ld      a,(par4)    ;get byte for clearing
        call    WrScrPort   ;write byte to screen
        inc     de          ; incr. screen addr.
        dec     hl          ; decr. byte-count
        ld      a,l
        or      h
        jr      nz,PutScr1  ;are we ready ?
PutScr2:
        pop     af          ;Restore register
        pop     de
        pop     hl
        ret

; -----------------------------------------
; Write addr in de to Screen Port $96/$97
; Write a to Screen Port $92
; Entry: de = addr, a = byte
; Exit:  --
; -----------------------------------------
WrScrPort:
        push    af              ;save data
        ld      a,e
        out     (096h),a        ;set low-byte addr.
        ld      a,d
        out     (097h),a        ;set high-byte addr.
        pop     af              ;restore data
        out     (092h),a        ;write byte to screen
        ret

; ----------
; Data Area
; ----------

oldsp:  defw 0         ;store old sp here

par3:   defw MaxGraRAM
par4:   defw 0         ; CHAR
par5:   defw 0         ; ADDR

        defs 14        ;new return-stack
newsp:
