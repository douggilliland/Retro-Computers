;
; Implementation of 48x16 screen-layout related functions for Challenger 1P
;

        .include        "osiscreen.inc"

C1P_SCR_BASE    := $D040        ; Base of C1P video RAM
								; offset due to hidden lines
C1P_VRAM_SIZE   = $0400         ; Size of C1P video RAM (1 kB)
C1P_SCR_WIDTH   = $30           ; Screen width (48)
C1P_SCR_HEIGHT  = $10           ; Screen height (16)
C1P_SCR_FIRSTCHAR = $0b         ; Offset of cursor position (0, 0) from base
                                ; of video RAM
C1P_SCROLL_DIST = $40           ; Memory distance for scrolling by one line (64 chars/line)

osi_screen_funcs C1P_SCR_BASE, C1P_VRAM_SIZE, C1P_SCR_FIRSTCHAR, \
		C1P_SCR_WIDTH, C1P_SCR_HEIGHT, C1P_SCROLL_DIST
