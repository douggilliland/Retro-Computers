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

DATA = $80   ; Data is in bit 7 of PORTA
; clock is on CA2
SHIFT = $1
ALT = $2

KB_STATE_START = $0
KB_STATE_DATA = $1
KB_STATE_PARITY = $2
KB_STATE_STOP = $3

KB_INIT_STATE_RESET = $0
KB_INIT_STATE_RESET_ACK = $1
KB_INIT_STATE_LEDS = $2
KB_INIT_STATE_LEDS_ACK = $3
KB_INIT_STATE_LEDS_DATA = $4
KB_INIT_STATE_LEDS_DATA_ACK = $5

LSHIFT_KEY = $12
RSHIFT_KEY = $59

TIMER_DELAY = $C4

