; Copyright 2020 Jonathan Foucher

; Permission is hereby granted, free of charge, to any person obtaining a copy of this software 
; and associated documentation files (the "Software"), to deal in the Software without restriction, 
; including without limitation the rights to use, copy, modify, merge, publish, distribute, 
; sublicense, and/or sell copies of the Software, and to permit persons to whom the Software 
; is furnished to do so, subject to the following conditions:

; The above copyright notice and this permission notice shall be included in all copies or 
; substantial portions of the Software.

; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
; INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR 
; PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
; FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR 
; OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
; DEALINGS IN THE SOFTWARE.


; this routine delays by 2304 * y + 23 cycles
delay:
  phx       ; 3 cycles
  phy       ; 3 cycles
two:
  ldx #$ff  ; 2 cycles
one:
  nop       ; 2 cycles
  nop       ; 2 cycles
  dex       ; 2 cycles
  bne one   ; 3 for all cycles, 2 for last
  dey       ; 2 cycles
  bne two   ; 3 for all cycles, 2 for last
  ply       ; 4 cycles
  plx       ; 4 cycles
  rts       ; 6 cycles

; delay is in Y register
delay_long:
  pha
  phy
  phx
  tya
  tax
delay_long_loop:
  ldy #$ff
  jsr delay
  dex
  bne delay_long_loop
  plx
  ply
  pla
  rts

delay_short:        ; delay Y * 19 cycles
  phy
delay_short_loop:
  nop               ; 2 cycles
  nop               ; 2 cycles
  nop               ; 2 cycles
  nop               ; 2 cycles
  nop               ; 2 cycles
  nop               ; 2 cycles
  nop               ; 2 cycles

  
  dey               ; 2 cycles
  bne delay_short_loop   ; 2 or 3 cycles
  ply
  rts