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


ps2_init:
  sei ; prevent interrupts while initializing
kb_conn_msg:
  ldx #0
kb_conn_loop:
  lda kb_conn_msg_text,x
  beq kb_conn_msg_end
  jsr kernel_putc
  inx
  bra kb_conn_loop
kb_conn_msg_text: .byte "Detecting keyboard", $0D, $00
kb_conn_msg_end:

  lda IER
  ora #$88      ;enable interrupt on neg transition on CB2
  sta IER

  lda #0
  sta PCR
  sta KB_TEMP
  sta KB_BIT
  sta KB_STATE
  sta to_send
  sta KB_PARITY
  sta KB_BUF_W_PTR
  sta KB_BUF_R_PTR
  sta KB_INIT_STATE
  sta KB_INIT_WAIT
  sta ready
  sta ignore_next
  sta character
  jsr clear_buffer
  
  ; jsr kb_reset
  ; jsr kb_leds
  ; jsr kb_leds_data

  ; jmp done_init

  lda #KB_INIT_STATE_RESET
  sta KB_INIT_STATE
  cli           ;enable interrupts

@wait1:
  ldy #10
  jsr delay
  inc KB_INIT_WAIT
  beq done_init     ; nothing to show yet
  lda to_send
  bne @wait1       ; do nothing while sending
  
  ;jsr lcd_print
  
  ldx KB_INIT_STATE
  cpx #KB_INIT_STATE_RESET
  beq @do_reset
  cpx #KB_INIT_STATE_RESET_ACK
  beq done_init
  ; beq @self_test_ok  ; Wait for 256 loops with nothing. if still nothing, reset keyboard

  bra done_init
  ;sta PORTA
  ; wait for keyboard self test (#$AA)

@do_reset: 
  jsr kb_reset
  lda #KB_INIT_STATE_RESET_ACK  ; next state should be an acknowledgment
  sta KB_INIT_STATE
  bra @wait1


done_init:
  lda #0
  sta DDRB
  sta PCR
  sta ignore_next
  sta ready
  sta control_keys
  sta to_send
  sta ready
  sta character
  sta KB_TEMP
  sta KB_INIT_STATE
  sta KB_BIT
  sta KB_STATE
  sta KB_BUF_W_PTR
  sta KB_BUF_R_PTR
  cli ; enable interrupts again
  rts


kb_reset:
  lda #0
  sta KB_INIT_WAIT
  lda #$F0
  sta PORTA
  sei                   ;disable interrupts
  jsr prepare_send
  lda #$FF
  sta to_send
  cli                   ; enable interrupts
  rts

no_kb_msg:
  ldx #0
no_kb_loop:
  lda no_kb_msg_text,x
  beq done_init
  jsr kernel_putc
  inx
  bra no_kb_loop
no_kb_msg_text: .byte "No keyboard connected", $0D, $00


prepare_send:
  pha
  phy
  ; ready to send, pull clock low for a while
  lda #$C0
  sta PCR       ;set CB2 low
  ;delay 
  ldy #$80
  jsr delay
  ; delay end
  ; pull data low now
  lda PORTB
  and #[$FF^DATA]
  sta PORTB
  lda DDRB
  ora #DATA   ;data as output to set it low
  sta DDRB
  ldy #$40
  jsr delay
  lda #KB_STATE_DATA    ; no start bit when sending
  sta KB_STATE
  ; release clock
  lda #0
  sta to_send
  sta KB_PARITY
  sta PCR       ;set CB2 to negative edge input
  
  ply
  pla
  rts


reset_ps2:          ; routine called during a timer interrupt to check 
  pha
                    ; if the elasped time since the last ps2 interrupt allows us to reset it
  lda time+3
  cmp last_ps2_time+3
  bcc @reset
  lda time+2
  cmp last_ps2_time+2
  bcc @reset
  lda time+1
  cmp last_ps2_time+1
  bcc @reset
  lda time
  adc #$1
  cmp last_ps2_time
  bcc @reset
@exit2:
  pla
  rts
@reset:
  lda #0
  sta KB_TEMP
  sta KB_BIT
  sta KB_STATE
  sta KB_BUF_W_PTR
  sta KB_BUF_R_PTR
  beq @exit2

clear_buffer:
  phx
  ldx #$ff
@clear_loop:
  stz KB_BUF, x
  dex
  bne @clear_loop
  plx
  rts

  .include "ps2_irq.s"



ASCIITBL:
    .byte $00               ; 00 no key pressed
    .byte $89               ; 01 F9
    .byte $87               ; 02 relocated F7
    .byte $85               ; 03 F5
    .byte $83               ; 04 F3
    .byte $81               ; 05 F1
    .byte $82               ; 06 F2
    .byte $8C               ; 07 F12
    .byte $00               ; 08 
    .byte $8A               ; 09 F10
    .byte $88               ; 0A F8
    .byte $86               ; 0B F6
    .byte $84               ; 0C F4
    .byte $09               ; 0D tab
    .byte $60               ; 0E `~
    .byte $8F               ; 0F relocated Print Screen key
    .byte $03               ; 10 relocated Pause/Break key
    .byte $A0               ; 11 left alt (right alt too)
    .byte $00               ; 12 left shift
    .byte $E0               ; 13 relocated Alt release code
    .byte $00               ; 14 left ctrl (right ctrl too)
    .byte $71               ; 15 qQ
    .byte $31               ; 16 1!
    .byte $00               ; 17 
    .byte $00               ; 18 
    .byte $00               ; 19 
    .byte $7A               ; 1A zZ
    .byte $73               ; 1B sS
    .byte $61               ; 1C aA
    .byte $77               ; 1D wW
    .byte $32               ; 1E 2@
    .byte $A1               ; 1F Windows 98 menu key (left side)
    .byte $02               ; 20 relocated ctrl-break key
    .byte $63               ; 21 cC
    .byte $78               ; 22 xX
    .byte $64               ; 23 dD
    .byte $65               ; 24 eE
    .byte $34               ; 25 4$
    .byte $33               ; 26 3#
    .byte $A2               ; 27 Windows 98 menu key (right side)
    .byte $00               ; 28
    .byte $20               ; 29 space
    .byte $76               ; 2A vV
    .byte $66               ; 2B fF
    .byte $74               ; 2C tT
    .byte $72               ; 2D rR
    .byte $35               ; 2E 5%
    .byte $A3               ; 2F Windows 98 option key (right click, right side)
    .byte $00               ; 30
    .byte $6E               ; 31 nN
    .byte $62               ; 32 bB
    .byte $68               ; 33 hH
    .byte $67               ; 34 gG
    .byte $79               ; 35 yY
    .byte $36               ; 36 6^
    .byte $00               ; 37
    .byte $00               ; 38
    .byte $00               ; 39
    .byte $6D               ; 3A mM
    .byte $6A               ; 3B jJ
    .byte $75               ; 3C uU
    .byte $37               ; 3D 7&
    .byte $38               ; 3E 8*
    .byte $00               ; 3F
    .byte $00               ; 40
    .byte $2C               ; 41 ,<
    .byte $6B               ; 42 kK
    .byte $69               ; 43 iI
    .byte $6F               ; 44 oO
    .byte $30               ; 45 0)
    .byte $39               ; 46 9(
    .byte $00               ; 47
    .byte $00               ; 48
    .byte $2E               ; 49 .>
    .byte $2F               ; 4A /?
    .byte $6C               ; 4B lL
    .byte $3B               ; 4C ;:
    .byte $70               ; 4D pP
    .byte $2D               ; 4E -_
    .byte $00               ; 4F
    .byte $00               ; 50
    .byte $00               ; 51
    .byte $27               ; 52 '"
    .byte $00               ; 53
    .byte $5B               ; 54 [{
    .byte $3D               ; 55 =+
    .byte $00               ; 56
    .byte $00               ; 57
    .byte $00               ; 58 caps
    .byte $00               ; 59 r shift
    .byte $0D               ; 5A <Enter>
    .byte $5D               ; 5B ]}
    .byte $00               ; 5C
    .byte $5C               ; 5D \|
    .byte $00               ; 5E
    .byte $00               ; 5F
    .byte $00               ; 60
    .byte $00               ; 61
    .byte $00               ; 62
    .byte $00               ; 63
    .byte $00               ; 64
    .byte $00               ; 65
    .byte $08               ; 66 bkspace
    .byte $00               ; 67
    .byte $00               ; 68
    .byte $31               ; 69 kp 1
    .byte $2f               ; 6A kp / converted from E04A in code
    .byte $34               ; 6B kp 4
    .byte $37               ; 6C kp 7
    .byte $00               ; 6D
    .byte $00               ; 6E
    .byte $00               ; 6F
    .byte $30               ; 70 kp 0
    .byte $2E               ; 71 kp .
    .byte $32               ; 72 kp 2
    .byte $35               ; 73 kp 5
    .byte $36               ; 74 kp 6
    .byte $38               ; 75 kp 8
    .byte $1B               ; 76 esc
    .byte $00               ; 77 num lock
    .byte $8B               ; 78 F11
    .byte $2B               ; 79 kp +
    .byte $33               ; 7A kp 3
    .byte $2D               ; 7B kp -
    .byte $2A               ; 7C kp *
    .byte $39               ; 7D kp 9
    .byte $8D               ; 7E scroll lock
    .byte $00               ; 7F 
    ;
    ; Table for shifted scancodes 
    ;        
    .byte $00               ; 80 
    .byte $C9               ; 81 F9
    .byte $C7               ; 82 relocated F7 
    .byte $C5               ; 83 F5 (F7 actual scancode=83)
    .byte $C3               ; 84 F3
    .byte $C1               ; 85 F1
    .byte $C2               ; 86 F2
    .byte $CC               ; 87 F12
    .byte $00               ; 88 
    .byte $CA               ; 89 F10
    .byte $C8               ; 8A F8
    .byte $C6               ; 8B F6
    .byte $C4               ; 8C F4
    .byte $09               ; 8D tab
    .byte $7E               ; 8E `~
    .byte $CF               ; 8F relocated Print Screen key
    .byte $03               ; 90 relocated Pause/Break key
    .byte $A0               ; 91 left alt (right alt)
    .byte $00               ; 92 left shift
    .byte $E0               ; 93 relocated Alt release code
    .byte $00               ; 94 left ctrl (and right ctrl)
    .byte $51               ; 95 qQ
    .byte $21               ; 96 1!
    .byte $00               ; 97 
    .byte $00               ; 98 
    .byte $00               ; 99 
    .byte $5A               ; 9A zZ
    .byte $53               ; 9B sS
    .byte $41               ; 9C aA
    .byte $57               ; 9D wW
    .byte $40               ; 9E 2@
    .byte $E1               ; 9F Windows 98 menu key (left side)
    .byte $02               ; A0 relocated ctrl-break key
    .byte $43               ; A1 cC
    .byte $58               ; A2 xX
    .byte $44               ; A3 dD
    .byte $45               ; A4 eE
    .byte $24               ; A5 4$
    .byte $23               ; A6 3#
    .byte $E2               ; A7 Windows 98 menu key (right side)
    .byte $00               ; A8
    .byte $20               ; A9 space
    .byte $56               ; AA vV
    .byte $46               ; AB fF
    .byte $54               ; AC tT
    .byte $52               ; AD rR
    .byte $25               ; AE 5%
    .byte $E3               ; AF Windows 98 option key (right click, right side)
    .byte $00               ; B0
    .byte $4E               ; B1 nN
    .byte $42               ; B2 bB
    .byte $48               ; B3 hH
    .byte $47               ; B4 gG
    .byte $59               ; B5 yY
    .byte $5E               ; B6 6^
    .byte $00               ; B7
    .byte $00               ; B8
    .byte $00               ; B9
    .byte $4D               ; BA mM
    .byte $4A               ; BB jJ
    .byte $55               ; BC uU
    .byte $26               ; BD 7&
    .byte $2A               ; BE 8*
    .byte $00               ; BF
    .byte $00               ; C0
    .byte $3C               ; C1 ,<
    .byte $4B               ; C2 kK
    .byte $49               ; C3 iI
    .byte $4F               ; C4 oO
    .byte $29               ; C5 0)
    .byte $28               ; C6 9(
    .byte $00               ; C7
    .byte $00               ; C8
    .byte $3E               ; C9 .>
    .byte $3F               ; CA /?
    .byte $4C               ; CB lL
    .byte $3A               ; CC ;:
    .byte $50               ; CD pP
    .byte $5F               ; CE -_
    .byte $00               ; CF
    .byte $00               ; D0
    .byte $00               ; D1
    .byte $22               ; D2 '"
    .byte $00               ; D3
    .byte $7B               ; D4 [{
    .byte $2B               ; D5 =+
    .byte $00               ; D6
    .byte $00               ; D7
    .byte $00               ; D8 caps
    .byte $00               ; D9 r shift
    .byte $0D               ; DA <Enter>
    .byte $7D               ; DB ]}
    .byte $00               ; DC
    .byte $7C               ; DD \|
    .byte $00               ; DE
    .byte $00               ; DF
    .byte $00               ; E0
    .byte $00               ; E1
    .byte $00               ; E2
    .byte $00               ; E3
    .byte $00               ; E4
    .byte $00               ; E5
    .byte $08               ; E6 bkspace
    .byte $00               ; E7
    .byte $00               ; E8
    .byte $91               ; E9 kp 1
    .byte $2f               ; EA kp / converted from E04A in code
    .byte $94               ; EB kp 4
    .byte $97               ; EC kp 7
    .byte $00               ; ED
    .byte $00               ; EE
    .byte $00               ; EF
    .byte $90               ; F0 kp 0
    .byte $7F               ; F1 kp .
    .byte $92               ; F2 kp 2
    .byte $95               ; F3 kp 5
    .byte $96               ; F4 kp 6
    .byte $98               ; F5 kp 8
    .byte $1B               ; F6 esc
    .byte $00               ; F7 num lock
    .byte $CB               ; F8 F11
    .byte $2B               ; F9 kp +
    .byte $93               ; FA kp 3
    .byte $2D               ; FB kp -
    .byte $2A               ; FC kp *
    .byte $99               ; FD kp 9
    .byte $CD               ; FE scroll lock



