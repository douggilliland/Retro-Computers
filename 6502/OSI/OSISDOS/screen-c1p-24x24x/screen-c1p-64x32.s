;
; Implementation of 64x32 screen-layout related functions for Challenger 1P
;

        .include        "osiscreen.inc"

C1P_SCR_BASE    := $D000        ; Base of C1P video RAM
								; offset due to hidden lines
C1P_VRAM_SIZE   = $0800         ; Size of C1P video RAM (2 kB)
C1P_SCR_WIDTH   = $40           ; Screen width (64)
C1P_SCR_HEIGHT  = $20           ; Screen height (32)
C1P_SCR_FIRSTCHAR = $00         ; Offset of cursor position (0, 0) from base
                                ; of video RAM
C1P_SCROLL_DIST = $40           ; Memory distance for scrolling by one line (64 chars/line)

osi_screen_funcs C1P_SCR_BASE, C1P_VRAM_SIZE, C1P_SCR_FIRSTCHAR, \
		C1P_SCR_WIDTH, C1P_SCR_HEIGHT, C1P_SCROLL_DIST
