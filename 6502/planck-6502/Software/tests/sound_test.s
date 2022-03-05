SOUND_CARD_ADDRESS = $FFB0
REGISTER_ADDRESS = SOUND_CARD_ADDRESS
REGISTER_DATA = SOUND_CARD_ADDRESS + 1
VIA1_BASE   = $FF90
PORTB = VIA1_BASE
PORTA  = VIA1_BASE+1
DDRB = VIA1_BASE+2
DDRA = VIA1_BASE+3


T1CL = VIA1_BASE + 4
T1CH = VIA1_BASE + 5
T1LL = VIA1_BASE + 6
T1LH = VIA1_BASE + 7
ACR = VIA1_BASE + 11
PCR = VIA1_BASE + 12
IFR = VIA1_BASE + 13
IER = VIA1_BASE + 14

KON = $20

OCTAVE1 = $400
OCTAVE2 = $800
OCTAVE3 = OCTAVE2 | OCTAVE1
OCTAVE4 = $1000
OCTAVE5 = OCTAVE4 | OCTAVE1
OCTAVE6 = OCTAVE4 | OCTAVE2
OCTAVE7 = OCTAVE4 | OCTAVE3

CD = $16B
D = $181
DD = $198
E = $1B0
F = $1CA
FD = $1E5
G = $202
GD = $220
AA = $241
AD = $263
B = $287
C = $2AE


C1 = C | OCTAVE1
C2 = C | OCTAVE2
C3 = C | OCTAVE3
C4 = C | OCTAVE4
C5 = C | OCTAVE5
C6 = C | OCTAVE6
C7 = C | OCTAVE7

CD1 = CD | OCTAVE1
CD2 = CD | OCTAVE2
CD3 = CD | OCTAVE3
CD4 = CD | OCTAVE4
CD5 = CD | OCTAVE5
CD6 = CD | OCTAVE6
CD7 = CD | OCTAVE7

D1 = D | OCTAVE1
D2 = D | OCTAVE2
D3 = D | OCTAVE3
D4 = D | OCTAVE4
D5 = D | OCTAVE5
D6 = D | OCTAVE6
D7 = D | OCTAVE7

DD1 = DD | OCTAVE1
DD2 = DD | OCTAVE2
DD3 = DD | OCTAVE3
DD4 = DD | OCTAVE4
DD5 = DD | OCTAVE5
DD6 = DD | OCTAVE6
DD7 = DD | OCTAVE7

E1 = E | OCTAVE1
E2 = E | OCTAVE2
E3 = E | OCTAVE3
E4 = E | OCTAVE4
E5 = E | OCTAVE5
E6 = E | OCTAVE6
E7 = E | OCTAVE7

F1 = F | OCTAVE1
F2 = F | OCTAVE2
F3 = F | OCTAVE3
F4 = F | OCTAVE4
F5 = F | OCTAVE5
F6 = F | OCTAVE6
F7 = F | OCTAVE7

FD1 = FD | OCTAVE1
FD2 = FD | OCTAVE2
FD3 = FD | OCTAVE3
FD4 = FD | OCTAVE4
FD5 = FD | OCTAVE5
FD6 = FD | OCTAVE6
FD7 = FD | OCTAVE7

G1 = G | OCTAVE1
G2 = G | OCTAVE2
G3 = G | OCTAVE3
G4 = G | OCTAVE4
G5 = G | OCTAVE5
G6 = G | OCTAVE6
G7 = G | OCTAVE7

GD1 = GD | OCTAVE1
GD2 = GD | OCTAVE2
GD3 = GD | OCTAVE3
GD4 = GD | OCTAVE4
GD5 = GD | OCTAVE5
GD6 = GD | OCTAVE6
GD7 = GD | OCTAVE7

AA1 = AA | OCTAVE1
AA2 = AA | OCTAVE2
AA3 = AA | OCTAVE3
AA4 = AA | OCTAVE4
AA5 = AA | OCTAVE5
AA6 = AA | OCTAVE6
AA7 = AA | OCTAVE7

AD1 = AD | OCTAVE1
AD2 = AD | OCTAVE2
AD3 = AD | OCTAVE3
AD4 = AD | OCTAVE4
AD5 = AD | OCTAVE5
AD6 = AD | OCTAVE6
AD7 = AD | OCTAVE7

B1 = B | OCTAVE1
B2 = B | OCTAVE2
B3 = B | OCTAVE3
B4 = B | OCTAVE4
B5 = B | OCTAVE5
B6 = B | OCTAVE6
B7 = B | OCTAVE7
; offset    size    description
; 0 	    char[8] 	Signature (must be DBRAWOPL)
; 8 	    uint16 	First version word
; 10 	    uint16 	Second version word 
; 12 	    uint32 	Song data size (in pairs of bytes)
; 16 	    uint32 	Song data length (in milliseconds)
; 20 	    uint8 	Hardware type (0: OPL2, 1: Dual OPL2, 2: OPL3)
; 21 	    uint8 	Data format (ZDoom only supports data format 0)
; 22 	    uint8 	Compression method (ZDoom only supports compression 0, meaning no compression)
; 23 	    uint8 	Short delay code (command value used to introduce a one-byte delay, should always be 122)
; 24 	    uint8 	Long delay code (command value used to introduce a one-byte delay multiplied by 256, should always be 123)
; 25 	    uint8 	Codemap table size (must be 126 or less, technically should always be 122)
; 26 	    uint8* 	Codemap table (associate OPL registers with index values) 

; CODEMAP_START = DRO_FILE+26
; CODEMAP_LENGTH = DRO_FILE+25
; SHORT_DELAY_CODE = DRO_FILE+23
; LONG_DELAY_CODE = DRO_FILE+24

.macro phax
    pha
    phx
.endmacro
.macro plax
    plx
    pla
.endmacro

; set register
.macro  set_register   address, data
    phax
    ldx address
    lda data
    jsr set_reg
    plax
.endmacro

; Read status register to A
.macro read_status
    ldy #$C0
    jsr delay_short
    lda REGISTER_ADDRESS
.endmacro

.macro load_instrument instrument, channel
    set_register #($20+channel),instrument+1
    set_register #($40+channel),instrument+2
    set_register #($60+channel),instrument+3
    set_register #($80+channel),instrument+4
    set_register #($C0+channel),instrument+5
    set_register #($23+channel),instrument+6
    set_register #($43+channel),instrument+7
    set_register #($63+channel),instrument+8
    set_register #($83+channel),instrument+9
    set_register #($E0+channel),instrument+10
.endmacro

.macro play_note note, channel
    set_register #($A0+channel), #<note
    set_register #($B0+channel), #(>note | KON)
.endmacro



.macro stop_note channel, delay
    
    .ifnblank       delay
        phy
        ldy delay
        jsr delay_long
        ply
    .endif
    set_register #($B0+channel), #($FF & ~KON)
.endmacro

.macro pause length
    phy
    ldy length
    jsr delay_long
    ply
.endmacro

    .segment "ZEROPAGE"
codemap: .res 128
instrument_address: .res 2

codemap_length: .res 1
pos_low: .res 1
pos_high: .res 1
tmp_reg: .res 1
short_delay_code: .res 1
long_delay_code: .res 1

    .segment "CODE"
reset: 
    lda #$FF
    sta DDRB
    sta DDRA
    lda #$01
    sta PORTB



    ; Reset both timers by writing 60h to register 4.
    ; Enable the interrupts by writing 80h to register 4.
    ; NOTE: this must be a separate step from number 1.
    ; Read the status register (port 388h). Store the result.
    ; Write FFh to register 2 (Timer 1).
    ; Start timer 1 by writing 21h to register 4.
    ; Delay for at least 80 microseconds.
    ; Read the status register (port 388h). Store the result.
    ; Reset both timers and interrupts (see steps 1 and 2).
    ; Test the stored results of steps 3 and 7 by ANDing them with E0h. The result of step 3 should be 00h, and the result of step 7 should be C0h. If both are correct, an AdLib-compatible board is installed in the computer.

rs:
    ;read_status
    sta PORTA
    and #$01
    ;bne rs
l:

    load_instrument BANJO1, 0

    ;jsr play_midi

    ; jsr copy_codemap
    ; lda #$04
    ; sta PORTB
    ; jsr play_dro

    ; stop_note 0, #$0
    ; stop_note 1, #$0
    ; stop_note 2, #$0
    ; stop_note 3, #$0
    ; stop_note 4, #$0
    ; stop_note 5, #$0
    ; stop_note 6, #$0
    ; stop_note 7, #$0
    ; stop_note 8, #$0
    ; stop_note 9, #$0
    ; lda #$08
    ; sta PORTB


    play_note D1, 0
    stop_note 0, #$5
    play_note E1, 0
    stop_note 0, #$5
    play_note F1, 0
    stop_note 0, #$5
    play_note G1, 0
    stop_note 0, #$5
    play_note AA1, 0
    stop_note 0, #$5
    play_note B1, 0
    stop_note 0, #$5
    play_note C1, 0
    stop_note 0, #$10

    play_note D2, 0
    stop_note 0, #$5
    play_note E2, 0
    stop_note 0, #$5
    play_note F2, 0
    stop_note 0, #$5
    play_note G2, 0
    stop_note 0, #$5
    play_note AA2, 0
    stop_note 0, #$5
    play_note B2, 0
    stop_note 0, #$5
    play_note C2, 0
    stop_note 0, #$10

    play_note D3, 0
    stop_note 0, #$5
    play_note E3, 0
    stop_note 0, #$5
    play_note F3, 0
    stop_note 0, #$5
    play_note G3, 0
    stop_note 0, #$5
    play_note AA3, 0
    stop_note 0, #$5
    play_note B3, 0
    stop_note 0, #$5
    play_note C3, 0
    stop_note 0, #$10

    play_note D4, 0
    stop_note 0, #$5
    play_note E4, 0
    stop_note 0, #$5
    play_note F4, 0
    stop_note 0, #$5
    play_note G4, 0
    stop_note 0, #$5
    play_note AA4, 0
    stop_note 0, #$5
    play_note B4, 0
    stop_note 0, #$5
    play_note C4, 0
    stop_note 0, #$10

    play_note D5, 0
    stop_note 0, #$5
    play_note E5, 0
    stop_note 0, #$5
    play_note F5, 0
    stop_note 0, #$5
    play_note G5, 0
    stop_note 0, #$5
    play_note AA5, 0
    stop_note 0, #$5
    play_note B5, 0
    stop_note 0, #$5
    play_note C5, 0
    stop_note 0, #$10

    ; pause #$10
    jmp l
stall:
    jmp stall

set_reg:
    stx REGISTER_ADDRESS
    ldy #$60
    jsr delay_short
    sta REGISTER_DATA

    ldy #$60
    jsr delay_short
    rts

track_length: .res 1
tmp_channel: .res 1

play_midi:
    lda MIDI_TRACK+7    ; get track length
    sta track_length
    ldx #0
midi_loop:
    lda MIDI_TRACK+8, x ; load first delay
    beq midi_event
    tay
    jsr delay_long
midi_event:
    inx
    lda MIDI_TRACK+8, x ; load midi command
    and #$F0
    cmp #$90
    beq note_on
    cmp #$80
    beq note_off
event_exit:
    inx
    cpx track_length
    bne midi_loop
    rts

note_on:
    lda MIDI_TRACK+8, x ; load midi command again
    and #$0F            ; mask channel
    sta tmp_channel
    inx
    lda MIDI_TRACK+8, x     ; load note
    jsr play_note_dyn
    bra event_exit

note_off:
    lda MIDI_TRACK+8, x ; load midi command again
    and #$0F            ; mask channel
    sta tmp_channel
    adc #$B0
    phx
    ldx #($FF & ~KON)
    jsr set_reg
    plx
    inx
    bra event_exit

play_note_dyn:
    phx
    pha                 ; data value is in A, save it
    lda tmp_channel
    clc
    adc #$A0
    tax     ; put register address in X
    pla     ; restore A to pass it to set_Reg
    jsr set_reg
    plx
    rts

MIDI:
    .byte "MThd"
    .byte $00, $00, $00, $06        ; chunk length
    .byte $00, $00                  ; format
    .byte $00, $01                   ; ntracks - 0 for format 0
    .byte $00, $60                  ; tickdiv = 96 ppqn, metrical time
MIDI_TRACK:
    .byte "MTrk"
    .byte $00, $00, $00, $08        ; track length
    .byte $00, $90, $3C, $40        ; delate time is $0, note on on channel 0, middle C, default velocity
    .byte $05, $80, $3C, $40        ; note off
    .byte $00, $90, $3E, $40        ; delate time is $0, note on on channel 0, middle D, default velocity
    .byte $05, $80, $3E, $40        ; note off


;           -2	-1	0 	1	2	3 	4	5	6 	7	8
; C 	    00	0C	18	24 	30	3C	48	54 	60	6C	78
; C# / Db 	01	0D	19	25 	31	3D	49	55 	61	6D	79
; D 	    02	0E	1A	26 	32	3E	4A	56 	62	6E	7A
; D# / Eb 	03	0F	1B	27 	33	3F	4B	57 	63	6F	7B
; E 	    04	10	1C	28 	34	40	4C	58 	64	70	7C
; F 	    05	11	1D	29 	35	41	4D	59 	65	71	7D
; F# / Gb 	06	12	1E	2A 	36	42	4E	5A 	66	72	7E
; G 	    07	13	1F	2B 	37	43	4F	5B 	67	73	7F
; G# / Ab 	08	14	20	2C 	38	44	50	5C 	68	74	–
; A 	    09	15	21	2D 	39	45	51	5D 	69	75
; A# / Bb 	0A	16	22	2E 	3A	46	52	5E 	6A	76
; B 	    0B	17	23	2F 	3B	47	53	5F 	6B	77

note_table:
    .word C1, CD1, D1, DD1, E1, F1, FD1, G1, GD1, AA1, AD1, B1
    .word C2, CD2, D2, DD2, E2, F2, FD2, G2, GD2, AA2, AD2, B2
    .word C3, CD3, D3, DD3, E3, F3, FD3, G3, GD3, AA3, AD3, B3
    .word C4, CD4, D4, DD4, E4, F4, FD4, G4, GD4, AA4, AD4, B4
    .word C5, CD5, D5, DD5, E5, F5, FD5, G5, GD5, AA5, AD5, B5
    .word C6, CD6, D6, DD6, E6, F6, FD6, G6, GD6, AA6, AD6, B6
    .word C7, CD7, D7, DD7, E7, F7, FD7, G7, GD7, AA7, AD7, B7

; copy_codemap:
;     lda SHORT_DELAY_CODE
;     sta short_delay_code
;     lda LONG_DELAY_CODE
;     sta long_delay_code
;     ldx CODEMAP_LENGTH
;     stx codemap_length
; copy_codemap_loop:
;     lda CODEMAP_START, x
;     sta codemap, x
;     dex
;     bne copy_codemap_loop
;     lda CODEMAP_START
;     sta codemap
;     rts

; play_dro:
;     lda #>(song_start)         ; put high byte of codemap start position in A
;     sta pos_high                ; store in position high byte
;     ; clc                         ; clear carry before add
;     lda #<(song_start)         ; load low byte of codemap start
;     ; adc codemap_length          ; add codemap length to get song start
;     sta pos_low                 ; store result in low byte of position
;     ; bcc get_index               ; if there was no carry, start straight away
;     ; inc pos_high                ; otherwise, increase the high byte
;     ; clc
; get_index:
;     ldx pos_low                 ; load low byte of position in x
; play_dro_loop:
;     stx pos_low                 ; save current low byte
;     lda pos_high                ; get high byte of song end
;     cmp #>SONG_END              ; compare with end of song high byte
;     bcs play_dro_exit           ; exit play routine if the current position is bigger
;     bne not_end                 ; skip comparing low byte
;     lda pos_low                 ; current high byte and max high byte are equal, so check low byte
;     cmp #<SONG_END              ; compare current low byte with song end low byte
;     bcs play_dro_exit           ; if current pos is bigger, exit
; not_end:
;     ldx pos_low
;     lda pos_high, x             ; load current register address
;     cmp short_delay_code        ; if it is a short delay code
;     beq short_delay             ; do a short delay
;     cmp long_delay_code         ; if it is a long delay code
;     beq long_delay              ; do a long delay
;     cmp #$FF
;     beq ignore
;     sta tmp_reg                 ; otherwise save it to temp
;     phx                         ; save current X low byte of song position
;     ldx tmp_reg                 ; load into X
;     lda codemap, x              ; use as an index into codemap
;     sta tmp_reg                 ; store reg from codemap in temp_reg
;     plx                         ; restore X
;     inx                         ; increment low byte index
;     bne play_dro_set_register   ; if x did not wraparound, continue as normal
;     inc pos_high                ; if X did wraparound, increment high byte
; play_dro_set_register:
;     set_register tmp_reg, {pos_high, x}     ; set register with temporary register address and value from song data
;     inx                         ; get ready to get next register index
;     bne play_dro_loop           ; if X did not wraparound, skip increment
;     inc pos_high                ; X did wraparound, increment high byte
;     bra play_dro_loop

; short_delay:
;     inx                         ; increment index to get delay value
;     bne short_delay_delay       ; if x did not wrap around go get value
;     inc pos_high                ; if X did wraparound, increment high byte
; short_delay_delay:
;     lda pos_high, x             ; load delay value
;     adc #1                      ; add 1 to delay value according to specs

;     tay                         ; move delay into Y
;     jsr delay_short             ; to start a delay

;     inx                         ; increment X, ready to get next register address
;     bne play_dro_loop           ; if X did not wraparound, skip increment
;     inc pos_high                ; X did wraparound, increment high byte
;     bra play_dro_loop

; long_delay:
;     inx                         ; increment index to get delay value
;     bne long_delay_delay        ; if x did not wrap around go get value
;     inc pos_high                ; if X did wraparound, increment high byte
; long_delay_delay:
;     lda pos_high, x             ; load delay value
;     adc #1                      ; add 1 to delay value according to specs
;     tay                         ; move delay into Y
;     jsr delay              ; to start long delay
;     inx                         ; increment X, ready to get next register address
;     bne play_dro_loop           ; if X did not wraparound, skip increment
;     inc pos_high                ; X did wraparound, increment high byte
;     bra play_dro_loop

; ignore:
;     inx
;     bne ignore_inc           ; if X did not wraparound, skip increment
;     inc pos_high                ; X did wraparound, increment high byte
; ignore_inc:
;     inx
;     bne play_dro_loop           ; if X did not wraparound, skip increment
;     inc pos_high                ; X did wraparound, increment high byte
;     bra play_dro_loop

; play_dro_exit:
;     rts
;  *  0 - Transpose
;  *		Tells the number of semi-tones a note that is played using this instrument should be pitched up or down. For
;  *		drum instruments that are played in melodic mode this sets the absolute note to be played for the drum sound.
;  *
;  *  1 - Channel c, operator 1, register 0x20
;  *		Tremolo(1) | Vibrato(1) | Sustain(1) | KSR(1) | Frequency multiplier (4)
;  *
;  *  2 - Channel c, operator 1, register 0x40
;  *		Key scale level(2) | Output level(6)
;  *
;  *  3 - Channel c, operator 1, register 0x60
;  *		Attack(4) | Decay(4)
;  *
;  *  4 - Channel c, operator 1, register 0x80
;  *		Sustain(4) | Release(4)
;  *
;  *  5 - Channel c, register 0xC0
;  *		Undefined(4) | Modulation feedback factor(3) | Synth type(1)
;  *
;  *  6 - Channel c, operator 2, register 0x20
;  *  7 - Channel c, operator 2, register 0x40
;  *  8 - Channel c, operator 2, register 0x60
;  *  9 - Channel c, operator 2, register 0x80
;  *
;  * 10 - Channel c, operators 1 + 2, register 0xE0
;  *		OP1 WaveForm(3) | OP2 Waveform(3)

ACCORDN:  .byte $00, $24, $4F, $F2, $0B, $0E, $31, $00, $52, $0B, $00
BAGPIPE1: .byte $00, $31, $43, $6E, $17, $02, $22, $05, $8B, $0C, $21
BAGPIPE2: .byte $00, $30, $00, $FF, $A0, $00, $A3, $00, $65, $0B, $23
BANJO1:   .byte $00, $31, $87, $A1, $11, $08, $16, $80, $7D, $43, $00
; BASS1:    .byte $00, $01, $15, $25, $2F, $0A, $21, $80, $65, $6C, $00
; BASS2:    .byte $00, $01, $1D, $F2, $EF, $0A, $01, $00, $F5, $78, $00
; BASSHARP: .byte $00, $C0, $6D, $F9, $01, $0E, $41, $00, $F2, $73, $01
; BASSOON1: .byte $00, $30, $C8, $D5, $19, $0C, $71, $80, $61, $1B, $00
; BASSTRLG: .byte $00, $C1, $4F, $B1, $53, $06, $E0, $00, $12, $74, $33
; BELLONG:  .byte $00, $64, $DB, $FF, $01, $04, $3E, $C0, $F3, $62, $00
; BELLS:    .byte $00, $07, $4F, $F2, $60, $08, $12, $00, $F2, $72, $00
; BELSHORT: .byte $00, $64, $DB, $FF, $01, $04, $3E, $C0, $F5, $F3, $00
; BNCEBASS: .byte $00, $20, $4B, $7B, $04, $0E, $21, $00, $F5, $72, $01
; BRASS1:   .byte $00, $21, $16, $71, $AE, $0E, $21, $00, $81, $9E, $00
; CBASSOON: .byte $00, $30, $C5, $52, $11, $00, $31, $80, $31, $2E, $00
; CELESTA:  .byte $00, $33, $87, $01, $10, $08, $14, $80, $7D, $33, $00
; CLAR1:    .byte $00, $32, $16, $73, $24, $0E, $21, $80, $75, $57, $00
; CLAR2:    .byte $00, $31, $1C, $41, $1B, $0C, $60, $80, $42, $3B, $00
; CLARINET: .byte $00, $32, $9A, $51, $1B, $0C, $61, $82, $A2, $3B, $00
; CLAVECIN: .byte $00, $11, $0D, $F2, $01, $0A, $15, $0D, $F2, $B1, $00
; CROMORNE: .byte $00, $00, $02, $F0, $FF, $06, $11, $80, $F0, $FF, $00
; ELCLAV1:  .byte $00, $05, $8A, $F0, $7B, $08, $01, $80, $F4, $7B, $00
; ELCLAV2:  .byte $00, $01, $49, $F1, $53, $06, $11, $00, $F1, $74, $21
; ELECFL:   .byte $00, $E0, $6D, $57, $04, $0E, $61, $00, $67, $7D, $01
; ELECVIBE: .byte $00, $13, $97, $9A, $12, $0E, $91, $80, $9B, $11, $02
; ELGUIT1:  .byte $00, $F1, $01, $97, $17, $08, $21, $0D, $F1, $18, $00
; ELGUIT2:  .byte $00, $13, $96, $FF, $21, $0A, $11, $80, $FF, $03, $00
; ELGUIT3:  .byte $00, $07, $8F, $82, $7D, $0C, $14, $80, $82, $7D, $00
; ELGUIT4:  .byte $00, $05, $8F, $DA, $15, $0A, $01, $80, $F9, $14, $20
; ELORGAN1: .byte $00, $B2, $CD, $91, $2A, $09, $B1, $80, $91, $2A, $12
; ELPIANO1: .byte $00, $01, $4F, $F1, $50, $06, $01, $04, $D2, $7C, $00
; ELPIANO2: .byte $00, $02, $22, $F2, $13, $0E, $02, $00, $F5, $43, $00
; EPIANO1A: .byte $00, $81, $63, $F3, $58, $00, $01, $80, $F2, $58, $00
; EPIANO1B: .byte $00, $07, $1F, $F5, $FA, $0E, $01, $57, $F5, $FA, $00
; FLUTE:    .byte $00, $21, $83, $74, $17, $07, $A2, $8D, $65, $17, $00
; FLUTE1:   .byte $00, $A1, $27, $74, $8F, $02, $A1, $80, $65, $2A, $00
; FLUTE2:   .byte $00, $E0, $EC, $6E, $8F, $0E, $61, $00, $65, $2A, $00
; FRHORN1:  .byte $00, $21, $9F, $53, $5A, $0C, $21, $80, $AA, $1A, $00
; FRHORN2:  .byte $00, $20, $8E, $A5, $8F, $06, $21, $00, $36, $3D, $02
; FSTRP1:   .byte $00, $F0, $18, $55, $EF, $00, $E0, $80, $87, $1E, $32
; FSTRP2:   .byte $00, $70, $16, $55, $2F, $0C, $E0, $80, $87, $1E, $32
; FUZGUIT1: .byte $00, $F1, $00, $97, $13, $0A, $25, $0D, $F1, $18, $10
; FUZGUIT2: .byte $00, $31, $48, $F1, $53, $06, $32, $00, $F2, $27, $20
; GUITAR1:  .byte $00, $01, $11, $F2, $1F, $0A, $01, $00, $F5, $88, $00
; HARP1:    .byte $00, $02, $29, $F5, $75, $00, $01, $83, $F2, $F3, $00
; HARP2:    .byte $00, $02, $99, $F5, $55, $00, $01, $80, $F6, $53, $00
; HARP3:    .byte $00, $02, $57, $F5, $56, $00, $01, $80, $F6, $54, $00
; HARPE1:   .byte $00, $02, $29, $F5, $75, $00, $01, $03, $F2, $F3, $00
; HARPSI1:  .byte $00, $32, $87, $A1, $10, $08, $16, $80, $7D, $33, $00
; HARPSI2:  .byte $00, $33, $87, $A1, $10, $06, $15, $80, $7D, $43, $00
; HARPSI3:  .byte $00, $35, $84, $A8, $10, $08, $18, $80, $7D, $33, $00
; HARPSI4:  .byte $00, $11, $0D, $F2, $01, $0A, $15, $0D, $F2, $B1, $00
; HARPSI5:  .byte $00, $36, $87, $8A, $00, $08, $1A, $80, $7F, $33, $00
; HELICPTR: .byte $00, $F0, $00, $1E, $11, $08, $E2, $C0, $11, $11, $11
; JAVAICAN: .byte $00, $87, $4D, $78, $42, $0A, $94, $00, $85, $54, $00
; JAZZGUIT: .byte $00, $03, $5E, $85, $51, $0E, $11, $00, $D2, $71, $01
; JEWSHARP: .byte $00, $00, $50, $F2, $70, $0E, $13, $00, $F2, $72, $00
; KEYBRD1:  .byte $00, $00, $02, $F0, $FA, $06, $11, $80, $F2, $FA, $11
; KEYBRD2:  .byte $00, $01, $8F, $F2, $BD, $08, $14, $80, $82, $BD, $00
; KEYBRD3:  .byte $00, $01, $00, $F0, $F0, $00, $E4, $03, $F3, $36, $00
; LOGDRUM1: .byte $00, $32, $44, $F8, $FF, $0E, $11, $00, $F5, $7F, $00
; MARIMBA1: .byte $00, $05, $4E, $DA, $25, $0A, $01, $00, $F9, $15, $00
; MARIMBA2: .byte $00, $85, $4E, $DA, $15, $0A, $81, $80, $F9, $13, $00
; MDRNPHON: .byte $00, $30, $00, $FE, $11, $08, $AE, $C0, $F1, $19, $11
; MOOGSYNT: .byte $00, $20, $90, $F5, $9E, $0C, $11, $00, $F4, $5B, $32
; NOISE1:   .byte $00, $0E, $40, $D1, $53, $0E, $0E, $00, $F2, $7F, $30
; OBOE1:    .byte $00, $B1, $C5, $6E, $17, $02, $22, $05, $8B, $0E, $00
; ORGAN1:   .byte $00, $65, $D2, $81, $03, $02, $71, $80, $F1, $05, $00
; ORGAN2:   .byte $00, $24, $80, $FF, $0F, $01, $21, $80, $FF, $0F, $00
; ORGAN3:   .byte $00, $03, $5B, $F0, $1F, $0A, $01, $80, $F0, $1F, $00
; ORGAN3A:  .byte $00, $03, $5B, $F0, $1F, $0A, $01, $8D, $F0, $13, $00
; ORGAN3B:  .byte $00, $03, $5B, $F0, $1F, $0A, $01, $92, $F0, $12, $00
; ORGNPERC: .byte $00, $0C, $00, $F8, $B5, $01, $00, $00, $D6, $4F, $00
; PHONE1:   .byte $00, $17, $4F, $F2, $61, $08, $12, $08, $F1, $B2, $00
; PHONE2:   .byte $00, $17, $4F, $F2, $61, $08, $12, $0A, $F1, $B4, $00
; PIAN1A:   .byte $00, $81, $63, $F3, $58, $00, $01, $80, $F2, $58, $00
; PIAN1B:   .byte $00, $07, $1F, $F5, $FA, $0E, $01, $26, $F5, $FA, $00
; PIAN1C:   .byte $00, $07, $1F, $F5, $FA, $0E, $01, $57, $F5, $FA, $00
; PIANO:    .byte $00, $03, $4F, $F1, $53, $06, $17, $00, $F2, $74, $00
; PIANO1:   .byte $00, $01, $4F, $F1, $53, $06, $11, $00, $D2, $74, $00
; PIANO2:   .byte $00, $41, $9D, $F2, $51, $06, $13, $00, $F2, $F1, $00
; PIANO3:   .byte $00, $01, $4F, $F1, $50, $06, $01, $04, $D2, $7C, $00
; PIANO4:   .byte $00, $01, $4D, $F1, $60, $08, $11, $00, $D2, $7B, $00
; PIANOBEL: .byte $00, $03, $4F, $F1, $53, $06, $17, $03, $F2, $74, $00
; PIANOF:   .byte $00, $01, $CF, $F1, $53, $02, $12, $00, $F2, $83, $00
; POPBASS1: .byte $00, $10, $00, $75, $93, $00, $01, $00, $F5, $82, $11
; SAX1:     .byte $00, $01, $4F, $71, $53, $0A, $12, $00, $52, $7C, $00
; SCRATCH:  .byte $00, $07, $00, $F0, $F0, $0E, $00, $00, $5C, $DC, $00
; SCRATCH4: .byte $00, $07, $00, $F0, $F0, $0E, $00, $00, $5C, $DC, $00
; SDRUM2:   .byte $00, $06, $00, $F0, $F0, $0E, $00, $00, $F6, $B4, $00
; SHRTVIBE: .byte $00, $E4, $0E, $FF, $3F, $00, $C0, $00, $F3, $07, $01
; SITAR1:   .byte $00, $01, $40, $F1, $53, $00, $08, $40, $F1, $53, $00
; SITAR2:   .byte $00, $01, $40, $F1, $53, $00, $08, $40, $F1, $53, $10
; SNAKEFL:  .byte $00, $61, $0C, $81, $03, $08, $71, $80, $61, $0C, $00
; SNRSUST:  .byte $00, $06, $00, $F0, $F0, $0E, $C4, $03, $C4, $34, $00
; SOLOVLN:  .byte $00, $70, $1C, $51, $03, $0E, $20, $00, $54, $67, $22
; STEELGT1: .byte $00, $01, $46, $F1, $83, $06, $61, $03, $31, $86, $00
; STEELGT2: .byte $00, $01, $47, $F1, $83, $06, $61, $03, $91, $86, $00
; STRINGS1: .byte $00, $B1, $8B, $71, $11, $06, $61, $40, $42, $15, $10
; STRNLONG: .byte $00, $E1, $4F, $B1, $D3, $06, $21, $00, $12, $74, $13
; SYN1:     .byte $00, $55, $97, $2A, $02, $00, $12, $80, $42, $F3, $00
; SYN2:     .byte $00, $13, $97, $9A, $12, $0E, $11, $80, $9B, $14, $00
; SYN3:     .byte $00, $11, $8A, $F1, $11, $06, $01, $40, $F1, $B3, $00
; SYN4:     .byte $00, $21, $0D, $E9, $3A, $0A, $22, $80, $65, $6C, $00
; SYN5:     .byte $00, $01, $4F, $71, $53, $06, $19, $00, $52, $7C, $00
; SYN6:     .byte $00, $24, $0F, $41, $7E, $0A, $21, $00, $F1, $5E, $00
; SYN9:     .byte $00, $07, $87, $F0, $05, $04, $01, $80, $F0, $05, $00
; SYNBAL1:  .byte $00, $26, $03, $E0, $F0, $08, $1E, $00, $FF, $31, $00
; SYNBAL2:  .byte $00, $28, $03, $E0, $F0, $04, $13, $00, $E8, $11, $00
; SYNBASS1: .byte $00, $30, $88, $D5, $19, $0C, $71, $80, $61, $1B, $00
; SYNBASS2: .byte $00, $81, $86, $65, $01, $0C, $11, $00, $32, $74, $00
; SYNBASS4: .byte $00, $81, $83, $65, $05, $0A, $51, $00, $32, $74, $00
; SYNSNR1:  .byte $00, $06, $00, $F0, $F0, $0E, $00, $00, $F8, $B6, $00
; SYNSNR2:  .byte $00, $06, $00, $F0, $F0, $0E, $00, $00, $F6, $B4, $00
; TINCAN1:  .byte $00, $8F, $81, $EF, $01, $04, $01, $00, $98, $F1, $00
; TRAINBEL: .byte $00, $17, $4F, $F2, $61, $08, $12, $08, $F2, $74, $00
; TRIANGLE: .byte $00, $26, $03, $E0, $F0, $08, $1E, $00, $FF, $31, $00
; TROMB1:   .byte $00, $B1, $1C, $41, $1F, $0E, $61, $80, $92, $3B, $00
; TROMB2:   .byte $00, $21, $1C, $53, $1D, $0C, $61, $80, $52, $3B, $00
; TRUMPET1: .byte $00, $31, $1C, $41, $0B, $0E, $61, $80, $92, $3B, $00
; TRUMPET2: .byte $00, $31, $1C, $23, $1D, $0C, $61, $80, $52, $3B, $00
; TRUMPET3: .byte $00, $31, $1C, $41, $01, $0E, $61, $80, $92, $3B, $00
; TRUMPET4: .byte $00, $31, $1C, $41, $0B, $0C, $61, $80, $92, $3B, $00
; TUBA1:    .byte $00, $21, $19, $43, $8C, $0C, $21, $80, $85, $2F, $00
; VIBRA1:   .byte $00, $84, $53, $F5, $33, $06, $A0, $80, $FD, $25, $00
; VIBRA2:   .byte $00, $06, $73, $F6, $54, $00, $81, $03, $F2, $B3, $00
; VIBRA3:   .byte $00, $93, $97, $AA, $12, $0E, $91, $80, $AC, $21, $02
; VIOLIN1:  .byte $00, $31, $1C, $51, $03, $0E, $61, $80, $54, $67, $00
; VIOLIN2:  .byte $00, $E1, $88, $62, $29, $0C, $22, $80, $53, $2C, $00
; VIOLIN3:  .byte $00, $E1, $88, $64, $29, $06, $22, $83, $53, $2C, $00
; VLNPIZZ1: .byte $00, $31, $9C, $F1, $F9, $0E, $31, $80, $F7, $E6, $00
; WAVE:     .byte $00, $00, $02, $00, $F0, $0E, $14, $80, $1B, $A2, $00
; XYLO1:    .byte $00, $11, $2D, $C8, $2F, $0C, $31, $00, $F5, $F5, $00
; XYLO3:    .byte $00, $06, $00, $FF, $F0, $0E, $C4, $00, $F8, $B5, $00

; offset    size    description
; 0 	    char[8] 	Signature (must be DBRAWOPL)
; 8 	    uint16 	First version word
; 10 	    uint16 	Second version word 
; 12 	    uint32 	Song data size (in pairs of bytes)
; 16 	    uint32 	Song data length (in milliseconds)
; 20 	    uint8 	Hardware type (0: OPL2, 1: Dual OPL2, 2: OPL3)
; 21 	    uint8 	Data format (ZDoom only supports data format 0)
; 22 	    uint8 	Compression method (ZDoom only supports compression 0, meaning no compression)
; 23 	    uint8 	Short delay code (command value used to introduce a one-byte delay, should always be 122)
; 24 	    uint8 	Long delay code (command value used to introduce a one-byte delay multiplied by 256, should always be 123)
; 25 	    uint8 	Codemap table size (must be 126 or less, technically should always be 122)
; 26 	    uint8* 	Codemap table (associate OPL registers with index values) 
; DRO_FILE:
; dro_signature:    .byte $44, $42, $52, $41, $57, $4F, $50, $4C
; version_h:    .byte $02, $00
; version_l: .byte $00, $00
; song_size: .byte $35, $97, $00, $00
; song_length: .byte $F4, $8F, $01, $00
; hw_type: .byte $00
; data_format: .byte $00
; compression: .byte $00
; sd_code: .byte $7A
; ld_code: .byte $7B
; cm_size: .byte $7A
; cm: .byte $01, $04, $05, $08, $BD, $20, $40, $60       ; 00
;     .byte $80, $E0, $21, $41, $61, $81, $E1, $22      ; 08
;     .byte $42, $62, $82, $E2, $23, $43, $63, $83       ; 10
;     .byte $E3, $24, $44, $64, $84, $E4, $25, $45       ; 18
;     .byte $65, $85, $E5, $28, $48, $68, $88, $E8       ; 20
;     .byte $29, $49, $69, $89, $E9, $2A, $4A, $6A       ; 28
;     .byte $8A, $EA, $2B, $4B, $6B, $8B, $EB, $2C       ; 30
;     .byte $4C, $6C, $8C, $EC, $2D, $4D, $6D, $8D       ; 38
;     .byte $ED, $30, $50, $70, $90, $F0, $31, $51       ; 40
;     .byte $71, $91, $F1, $32, $52, $72, $92, $F2       ; 48
;     .byte $33, $53, $73, $93, $F3, $34, $54, $74       ; 50
;     .byte $94, $F4, $35, $55, $75, $95, $F5, $A0       ; 58
;     .byte $B0, $C0, $A1, $B1, $C1, $A2, $B2, $C2       ; 60
;     .byte $A3, $B3, $C3, $A4, $B4, $C4, $A5, $B5       ; 68

;     .byte $C5, $A6, $B6, $C6, $A7, $B7, $C7, $A8       ; 70
;     .byte $B8, $C8     
; song_start:                            ; 78
;     .byte $00 , $20, $05, $01, $14, $04, $5B, $04, $07, $CF
;     .byte $0C, $FF, $11
;     .byte $FF, $16, $FF
;     .byte $1B, $FF, $20, $FF, $25, $FF
;     .byte $2A, $FF, $2F, $FF, $34, $FF, $39, $FF, $3E
;     .byte $FF, $43, $FF, $48, $FF, $4D, $FF, $52, $FF
;     .byte $57, $FF, $5C, $FF, $08, $09, $0D, $FF, $12, $FF, $17, $06, $1C, $FF, $21, $FF, $26, $FF, $2B, $FF, $30
;     .byte $FF, $35, $FF, $3A, $FF, $3F, $FF, $44, $FF, $49, $FF, $4E, $FF, $53, $FF, $58, $FF, $5D, $FF, $5F
;        .byte $C0
;     .byte $04, $C0, $61, $06, $60, $21, $1C, $07, $19, $03, $0D, $04, $0E, $03, $1A, $02, $0B, $06, $64, $02, $62
;     .byte $87, $63, $26, $21, $05, $1E, $21, $22, $01, $12, $00, $0F, $20, $13, $02, $1F, $0C, $10, $09, $67, $02
;     .byte $65, $87, $66, $2E, $35, $05, $32, $21, $36, $01, $7A, $00, $26, $00, $23, $20, $27, $02, $33, $0C, $24
;     .byte $09, $6A, $02, $68, $81, $69, $31, $3A, $05, $37, $21, $3B, $01, $2B, $00, $28, $20, $2C, $02, $38, $0C
;     .byte $29, $09, $6D, $02, $6B, $E5, $6C, $31, $3F, $05, $3C, $22, $40, $01, $30, $00, $2D, $23, $31, $02, $3D
;     .byte $0C, $2E, $30, $7A, $00, $70, $04, $6E, $81, $6F, $29, $53, $05, $50, $22, $54, $01, $44, $00, $41, $23
;     .byte $45, $02, $51, $0C, $42, $30, $73, $04, $71, $E5, $72, $29, $55, $20, $46, $20, $56, $3F, $47, $3F, $5A
;     .byte $20, $4B, $20, $5B, $3F, $4C, $3F, $7A, $0B, $5F, $B6, $7A, $0D, $5F, $AC, $7A, $0D, $5F, $A2, $66, $0E
;     .byte $69, $11, $6C, $11, $7A, $0D, $5F, $98, $10, $0A, $24, $0A, $7A, $00, $29, $0A, $7A, $0D, $5F, $8E, $7A
;     .byte $0D, $5F, $84, $2E, $2F, $42, $2F, $7A, $0D, $5F, $7A, $60, $01, $63, $06, $7A, $0D, $17, $0A, $14, $0A
;     .byte $7A, $00, $07, $FF, $08, $00, $05, $0F, $61, $0E, $5F, $57, $60, $25, $63, $26, $10, $0B, $24, $0B, $29
;     .byte $0B, $7A, $38, $10, $0C, $24, $0C, $29, $0C, $2E, $2E, $42, $2E, $7A, $29, $60, $05, $63, $06, $7A, $0E
;     .byte $60, $25, $63, $26, $10, $09, $66, $2E, $24, $09, $69, $31, $29, $09, $6C, $31, $7A, $1B, $2E, $2D, $42
;     .byte $2D, $7A, $0D, $66, $0E, $69, $11, $7A, $00, $6C, $11, $7A, $0D, $10, $0A, $24, $0A, $29, $0A, $7A, $29
;     .byte $60, $05, $7A, $00, $63, $06, $7A, $0D, $60, $25, $63, $2A, $10, $09, $66, $2E, $24, $09, $69, $31, $29
;     .byte $09, $6C, $31, $2E, $2C, $42, $2C, $7A, $2A, $66, $0E, $69, $11, $6C, $11, $7A, $0D, $10, $0A, $24, $0A
;     .byte $29, $0A, $7A, $1B, $2E, $2B, $42, $2B, $7A, $0E, $60, $05, $63, $0A, $7A, $0D, $16, $F7, $17, $67, $14
;     .byte $23, $08, $02, $05, $01, $09, $02, $15, $04, $60, $25, $19, $05, $0D, $09, $0A, $04, $0E, $00, $1A, $00
;     .byte $0B, $00, $64, $0F, $62, $6D, $7A, $00, $63, $25, $10, $0B, $24, $0B, $29, $0B, $7A, $0C, $62, $59, $7A
;     .byte $0D, $62, $45, $7A, $0E, $62, $31, $7A, $0D, $62, $1D, $10, $0C, $24, $0C, $29, $0C, $2E, $2A, $42, $2A
;     .byte $7A, $0D, $62, $09, $7A, $0E, $62, $F5, $63, $24, $7A, $0D, $60, $05, $62, $E1, $63, $04, $7A, $0D, $16
;     .byte $FF, $17, $0A, $14, $0A, $08, $00, $05, $0F, $09, $00, $15, $00, $60, $25, $19, $03, $0D, $04, $0A, $00
;     .byte $0E, $03, $1A, $02, $7A, $00, $0B, $06, $64, $02, $62, $41, $63, $26, $10, $09, $66, $2E, $24, $09, $69
;     .byte $31, $29, $09, $6C, $31, $7A, $1B, $2E, $29, $42, $29, $7A, $0D, $66, $0E, $69, $11, $6C, $11, $7A, $0D
;     .byte $10, $0A, $24, $0A, $29, $0A, $7A, $2A, $60, $05, $63, $06, $7A, $0D, $60, $25, $63, $2A, $10, $09, $66
;     .byte $2E, $24, $09, $69, $31, $7A, $00, $29, $09, $6C, $31, $2E, $28, $42, $28, $7A, $29, $66, $0E, $69, $11
;     .byte $6C, $11, $7A, $0D, $10, $0A, $24, $0A, $29, $0A, $7A, $1C, $2E, $27, $42, $27, $7A, $0D, $60, $05, $63
;     .byte $0A, $7A, $0D, $60, $25, $63, $26, $10, $0B, $24, $0B, $7A, $00, $29, $0B, $7A, $29, $60, $05, $7A, $0D
;     .byte $17, $FF, $14, $20, $08, $FF, $7A, $00, $05, $20, $15, $3F, $06, $3F, $61, $00, $10, $0C, $24, $0C, $29
;     .byte $0C, $2E, $26, $42, $26, $7A, $29, $63, $06, $7A, $0D, $17, $06, $7A, $00, $14, $04, $07, $CF, $08, $09
;     .byte $05, $01, $15, $00, $06, $00, $61, $06, $5F, $C0, $60, $21, $62, $87, $63, $26, $10, $09, $66, $2E, $24
;     .byte $09, $69, $31, $29, $09, $6C, $31, $7A, $0D, $5F, $B6, $7A, $0D, $5F, $AC, $2E, $25, $42, $25, $7A, $0D
;     .byte $5F, $A2, $66, $0E, $69, $11, $6C, $11, $7A, $0E, $5F, $98, $10, $0A, $24, $0A, $29, $0A, $7A, $0D, $5F
;     .byte $8E, $7A, $0D, $5F, $84, $7A, $0D, $5F, $7A, $60, $01, $63, $06, $7A, $0E, $17, $0A, $14, $0A, $07, $FF
;     .byte $08, $00, $05, $0F, $61, $0E, $5F, $57, $60, $25, $63, $26, $10, $09, $66, $2E, $24, $09, $69, $31, $29
;     .byte $09, $6C, $31, $2E, $24, $42, $24, $7A, $29, $66, $0E, $69, $11, $7A, $00, $6C, $11, $7A, $0D, $10, $0A
;     .byte $24, $0A, $29, $0A, $7A, $1B, $2E, $23, $42, $23, $7A, $0D, $60, $05, $7A, $00, $63, $06, $7A, $0D, $60
;     .byte $25, $63, $26, $10, $09, $66, $2E, $24, $09, $69, $31, $29, $09, $6C, $31, $7A, $2A, $66, $0E, $69, $11
;     .byte $6C, $11, $7A, $0D, $10, $0A, $24, $0A, $29, $0A, $2E, $22, $42, $22, $7A, $2A, $60, $05, $63, $06, $7A
;     .byte $0D, $60, $25, $63, $2A, $10, $0B, $24, $0B, $29, $0B, $7A, $1B, $2E, $21, $7A, $00, $42, $21, $7A, $1B
;     .byte $10, $0C, $24, $0C, $29, $0C, $7A, $2A, $60, $05, $63, $0A, $7A, $0D, $16, $F7, $17, $67, $14, $23, $08
;     .byte $02, $05, $01, $09, $02, $15, $04, $60, $25, $19, $05, $0D, $09, $0A, $04, $0E, $00, $7A, $00, $1A, $00
;     .byte $0B, $00, $64, $0F, $62, $6D, $63, $25, $10, $09, $66, $2E, $24, $09, $69, $31, $29, $09, $6C, $31, $2E
;     .byte $20, $42, $20, $7A, $0C, $62, $59, $7A, $0E, $62, $45, $7A, $0D, $62, $31, $66, $0E, $69, $11, $6C, $11
;     .byte $7A, $0D, $62, $1D, $10, $0A, $24, $0A, $29, $0A, $7A, $0D, $62, $09, $7A, $0E, $62, $F5, $63, $24, $2E
;     .byte $1F, $42, $1F, $7A, $0D, $60, $05, $62, $E1, $63, $04, $7A, $0D, $16, $FF, $17, $0A, $14, $0A, $08, $00
;     .byte $05, $0F, $09, $00, $15, $00, $60, $25, $7A, $00, $19, $03, $0D, $04, $0A, $00, $0E, $03, $1A, $02, $0B
;     .byte $06, $64, $02, $62, $E5, $63, $25, $10, $09, $66, $2E, $24, $09, $69, $31, $29, $09, $6C, $31, $7A, $29
;     .byte $66, $0E, $69, $11, $6C, $11, $7A, $0D, $10, $0A, $24, $0A, $29, $0A, $2E, $1E, $42, $1E, $7A, $2A, $60
;     .byte $05, $63, $05, $7A, $0D, $60, $25, $62, $41, $63, $26, $10, $0B, $7A, $00, $24, $0B, $29, $0B, $7A, $1B
;     .byte $2E, $1D, $42, $1D, $7A, $1B, $10, $0C, $24, $0C, $7A, $00, $29, $0C, $7A, $29, $60, $05, $63, $06, $7A
;     .byte $0D, $60, $25, $7A, $00, $62, $87, $63, $26, $10, $09, $66, $2E, $24, $09, $69, $31, $29, $09, $6C, $31
;     .byte $2E, $1C, $42, $1C, $7A, $29, $60, $05, $66, $0E, $69, $11, $6C, $11, $7A, $0E, $17, $FF, $14, $20, $08
;     .byte $FF, $05, $20, $15, $3F, $06, $3F, $61, $00, $10, $0A, $24, $0A, $29, $0A, $7A, $1B, $2E, $1B, $42, $1B
;     .byte $7A, $0D, $63, $06, $7A, $0E, $17, $06, $14, $04, $07, $CF, $08, $09, $05, $01, $15, $00, $06, $00, $61
;     .byte $06, $5F, $C0, $60, $21, $63, $26, $10, $09, $66, $2E, $24, $09, $69, $31, $29, $09, $6C, $31, $7A, $0D
;     .byte $5F, $B6, $7A, $0D, $5F, $AC, $7A, $0D, $5F, $A2, $66, $0E, $7A, $00, $69, $11, $6C, $11, $7A, $0D, $5F
;     .byte $98, $10, $0A, $24, $0A, $29, $0A, $2E, $1A, $42, $1A, $7A, $0D
;     .byte $5F, $8E, $7A, $0D, $5F, $84, $7A, $0E, $5F, $7A, $60, $01, $63, $06, $7A, $0D, $17, $0A, $14, $0A, $07, $FF, $08, $00
;     .byte $05, $0F, $61, $0E, $5F, $57, $60, $25, $63, $26, $10, $0B, $24, $0B, $29, $0B, $7A, $1B, $2E, $19, $42, $19, $7A, $1C, $10, $0C
;     .byte $24, $0C, $29, $0C, $7A, $2A, $60, $05, $63, $06, $7A, $0D, $60, $25, $63, $26, $10, $09, $66, $2E, $24, $09, $69, $31, $29, $09
;     .byte $6C, $31, $2E, $18, $42, $18, $7A, $2A, $66, $0E, $69, $11, $6C, $11, $7A, $0D, $10, $0A, $24, $0A, $29, $0A, $7A, $1C, $2E, $17
;     .byte $42, $17, $7A, $0D, $60, $05, $63, $06, $7A, $0D, $60, $25, $63, $2A, $10, $09, $66, $2E, $24, $09, $69, $31, $29, $09, $6C, $31
;     ; .byte $7A, $2A, $66, $0E, $69, $11, $6C, $11, $7A, $0D, $10, $0A, $24, $0A, $29, $0A, $2E, $16, $42, $16, $7A, $2A, $60, $05, $63, $0A, $7A, $0D, $16, $F7, $17, $67, $14, $23, $08, $02, $05, $01, $09, $02, $15, $04, $60, $25, $7A, $00, $19, $05, $0D, $09, $0A, $04, $0E, $00, $1A, $00, $0B, $00, $64, $0F, $62, $6D, $63, $25, $10, $0B, $24, $0B, $29, $0B, $7A, $0C, $62, $59, $7A, $0E, $62, $45, $2E, $15, $42, $15, $7A, $0D, $62, $31, $7A, $0D, $62, $1D, $10, $0C, $24, $0C, $29, $0C, $7A, $0E, $62, $09, $7A, $0D, $62, $F5, $63, $24, $7A, $0D, $60, $05, $62, $E1, $63, $04, $7A, $0D, $16, $FF, $17, $0A, $14, $0A, $08, $00, $05, $0F, $7A, $00, $09, $00, $15, $00, $60, $25, $19, $03, $0D, $04, $0A, $00, $0E, $03, $1A, $02, $0B, $06, $64, $02, $62, $41, $63, $26, $10, $09, $66, $2E, $24, $09, $69, $31, $29, $09, $6C, $31, $2E, $14, $42, $14, $7A, $29, $66, $0E, $69, $11, $6C, $11, $7A, $0D, $10, $0A, $24, $0A, $7A, $00, $29, $0A, $7A, $1B, $2E, $13, $42, $13, $7A, $0D, $60, $05, $63, $06, $7A, $0E, $60, $25, $63, $2A, $10, $09, $66, $2E, $24, $09, $69, $31, $29, $09, $6C, $31, $7A, $29, $66, $0E, $69, $11, $6C, $11, $7A, $0E, $10, $0A, $24, $0A, $29, $0A, $2E, $12, $42, $12, $7A, $29, $60, $05, $63, $0A, $7A, $0E, $60, $25, $63, $26, $10, $0B, $24, $0B, $29, $0B, $7A, $1B, $2E, $11, $42, $11, $7A, $0D, $60, $05, $7A, $0E, $17, $FF, $14, $20, $08, $FF, $05, $20, $15, $3F, $06, $3F, $61, $00, $10, $0C, $24, $0C, $29, $0C, $7A, $2A, $63, $06, $7A, $0D, $17, $06, $14, $04, $07, $CF, $08, $09, $05, $01, $15, $00, $06, $00, $61, $06, $5F, $C0, $60, $21, $62, $87, $63, $26, $10, $09, $66, $2E, $24, $09, $69, $31, $29, $09, $7A, $00, $6C, $31, $2E, $10, $42, $10, $7A, $0C, $5F, $B6, $7A, $0D, $5F, $AC, $7A, $0E, $5F, $A2, $66, $0E, $69, $11, $6C, $11, $7A, $0D, $5F, $98, $10, $0A, $24, $0A, $29, $0A, $7A, $0D, $5F, $8E, $7A, $0D, $5F, $84, $2E, $0F, $7A, $00, $42, $0F, $7A, $0D, $5F, $7A, $60, $01, $63, $06, $7A, $0D, $17, $0A, $14, $0A, $07, $FF, $08, $00, $05, $0F, $61, $0E, $5F, $57, $60, $25, $63, $26, $10, $09, $66, $2E, $24, $09, $69, $31, $7A, $00, $29, $09, $6C, $31, $7A, $29, $66, $0E, $69, $11, $6C, $11, $7A, $0D, $10, $0A, $24, $0A, $29, $0A, $2E, $0E, $42, $0E, $7A, $2A, $60, $05, $63, $06, $7A, $0D, $60, $25, $63, $26, $10, $09, $66, $2E, $24, $09, $69, $31, $29, $09, $6C, $31, $7A, $1C, $2E, $0D, $42, $0D, $7A, $0D, $66, $0E, $69, $11, $6C, $11, $7A, $0D, $10, $0A, $24, $0A, $29, $0A, $7A, $2A, $60, $05, $63, $06, $7A, $0D, $60, $25, $63, $2A, $10, $0B, $24, $0B, $29, $0B, $2E, $0C, $7A, $00, $42, $0C, $7A, $37, $10, $0C, $24, $0C, $29, $0C, $7A, $1C, $2E, $0B, $42, $0B, $7A, $0D, $60, $05, $63, $0A, $7A, $0D, $16, $F7, $17, $67, $14, $23, $08, $02, $7A, $00, $05, $01, $09, $02, $15, $04, $60, $25, $19, $05, $0D, $09, $0A, $04, $0E, $00, $1A, $00, $0B, $00, $64, $0F, $62, $6D, $63, $25, $10, $09, $66, $2E, $24, $09, $69, $31, $29, $09, $6C, $31, $7A, $0D, $62, $59, $7A, $0D, $62, $45, $7A, $0D, $62, $31, $66, $0E, $69, $11, $6C, $11, $7A, $0D, $62, $1D, $10, $0A, $7A, $00, $24, $0A, $29, $0A, $2E, $0A, $42, $0A, $7A, $0D, $62, $09, $7A, $0D, $62, $F5, $63, $24, $7A, $0D, $60, $05, $62, $E1, $63, $04, $7A, $0E, $16, $FF, $17, $0A, $14, $0A, $08, $00, $05, $0F, $09, $00, $15, $00, $60, $25, $19, $03, $0D, $04, $0A, $00, $0E, $03, $1A, $02, $0B, $06, $64, $02, $62, $E5, $63, $25, $10, $09, $66, $2E, $24, $09, $69, $31, $29, $09, $6C, $31, $7A, $1B, $2E, $09, $42, $09, $7A, $0D, $66, $0E, $69, $11, $6C, $11, $7A, $0E, $10, $0A, $24, $0A, $29, $0A, $7A, $29, $60, $05, $63, $05, $7A, $0E, $60, $25, $62, $41, $63, $26, $10, $0B, $24, $0B, $29, $0B, $2E, $08, $42, $08, $7A, $38, $10, $0C, $24, $0C, $29, $0C, $7A, $1B, $2E, $07, $42, $07, $7A, $0E, $60, $05, $63, $06, $7A, $0D, $60, $25, $62, $87, $63, $26, $10, $09, $66, $2E, $24, $09, $69, $31, $29, $09, $6C, $31, $7A, $2A, $60, $05, $66, $0E, $69, $11, $6C, $11, $7A, $0D, $17, $FF, $14, $20, $08, $FF, $05, $20, $15, $3F, $06, $3F, $61, $00, $10, $0A, $24, $0A, $29, $0A, $2E, $08, $42, $08, $7A, $2A, $63, $06, $7A, $0D, $17, $06, $14, $04, $07, $CF, $08, $09, $05, $01, $15, $00, $06, $00, $61, $06, $5F, $C0, $60, $21, $62, $E5, $63, $25, $10, $09, $66, $2E, $7A, $00, $24, $09, $68, $6B, $69, $31, $29, $09, $6C, $31, $6E, $6B, $7A, $0C, $5F, $B6, $7A, $0D, $5F, $AC, $7A, $00, $2E, $09, $42, $09, $7A, $0D, $5F, $A2, $66, $0E, $69, $11, $6C, $11, $7A, $0D, $5F, $98, $10, $0A, $24, $0A, $29, $0A, $7A, $0D, $5F, $8E, $7A, $0E, $5F, $84, $7A, $0D, $5F, $7A, $60, $01, $63, $05, $7A, $0D, $17, $0A, $14, $0A, $07, $FF, $08, $00, $05, $0F, $61, $0E, $5F, $57, $60, $25, $63, $25, $10, $0B, $24, $0B, $7A, $00, $29, $0B, $2E, $0A, $42, $0A, $7A, $37, $10, $0C, $24, $0C, $29, $0C, $7A, $1C, $2E, $0B, $42, $0B, $7A, $0D, $60, $05, $63, $05, $7A, $0D, $60, $25, $63, $25, $10, $09, $66, $2E, $24, $09, $69, $31, $7A, $00, $29, $09, $6C, $31, $7A, $29, $66, $0E, $69, $11, $6C, $11, $7A, $0D, $10, $0A, $24, $0A, $29, $0A, $2E, $0C, $7A, $00, $42, $0C, $7A, $29, $60, $05, $63, $05, $7A, $0D, $60, $25, $63, $29, $7A, $00, $10, $09, $66, $2E, $24, $09, $69, $31, $29, $09, $6C, $31, $7A, $1B, $2E, $0D, $42, $0D, $7A, $0D, $66, $0E, $69, $11, $6C, $11, $7A, $0D, $10, $0A, $7A, $00, $24, $0A, $29, $0A, $7A, $29, $60, $05, $63, $09, $7A, $0E, $16, $F7, $17, $67, $14, $23, $08, $02, $05, $01, $09, $02, $15, $04, $60, $25, $19, $05, $0D, $09, $0A, $04, $0E, $00, $1A, $00, $0B, $00, $64, $0F, $62, $6D, $63, $25, $10, $0B, $24, $0B, $29, $0B, $2E, $0E, $42, $0E, $7A, $0D, $62, $59, $7A, $0D, $62, $45, $7A, $0D, $62, $31, $7A, $0E, $62, $1D, $10, $0C, $24, $0C, $29, $0C, $7A, $0D, $62, $09, $7A, $0D, $62, $F5, $63, $24, $2E, $0F, $42, $0F, $7A, $0D, $60, $05, $62, $E1, $63, $04, $7A, $0E, $16, $FF, $17, $0A, $14, $0A, $08, $00, $05, $0F, $09, $00, $15, $00, $60, $25, $19, $03, $0D, $04, $0A, $00, $0E, $03, $1A, $02, $0B, $06, $64, $02, $62, $B0, $63, $25, $10, $09, $66, $2E, $24, $09, $69, $31, $7A, $00, $29, $09, $6C, $31, $7A, $28, $66, $0E, $7A, $00, $69, $11, $6C, $11, $7A, $0D, $10, $0A, $24, $0A, $29, $0A, $2E, $10, $42, $10, $7A, $2A, $60, $05, $63, $05, $7A, $0D, $60, $25, $63, $29, $10, $09, $66, $2E, $24, $09, $69, $31, $29, $09, $6C, $31, $7A, $1B, $2E, $11, $42, $11, $7A, $0E, $66, $0E, $69, $11, $6C, $11, $7A, $0D, $10, $0A, $24, $0A, $29, $0A, $7A, $2A, $60, $05, $63, $09, $7A, $0D, $60, $25, $63, $25, $10, $0B, $24, $0B, $29, $0B, $2E, $12, $42, $12, $7A, $2A, $60, $05, $7A, $0D, $17, $FF, $14, $20, $08, $FF, $05, $20, $15, $3F, $06, $3F, $61, $00, $10, $0C, $24, $0C, $29, $0C, $7A, $1C, $2E, $13, $42, $13, $7A, $0D, $63, $05, $7A, $0D, $17, $06, $14, $04, $07, $CF, $08, $09, $05, $01, $15, $00, $06, $00, $61, $06, $5F, $C0, $60, $21, $62, $E5, $7A, $00, $63, $25, $10, $09, $66, $2E, $24, $09, $69, $31, $29, $09, $6C, $31, $7A, $0C, $5F, $B6, $7A, $0E, $5F, $AC, $7A, $0D, $5F, $A2, $66, $0E, $69, $11, $6C, $11, $7A, $0D, $5F, $98, $10, $0A, $24, $0A, $29, $0A, $2E, $14, $42, $14, $7A, $0D, $5F, $8E, $7A, $0E, $5F, $84, $7A, $0D, $5F, $7A, $60, $01, $63, $05, $7A, $0D, $17, $0A, $14, $0A, $07, $FF, $08, $00, $05, $0F, $61, $0E, $5F, $57, $7A, $00, $60, $25, $63, $25, $10, $09, $66, $2E, $24, $09, $69, $31, $29, $09, $6C, $31, $7A, $1B, $2E, $15, $42, $15, $7A, $0D, $66, $0E, $69, $11, $6C, $11, $7A, $0D, $10, $0A, $24, $0A, $29, $0A, $7A, $2A, $60, $05, $63, $05, $7A, $0D, $60, $25, $63, $25, $7A, $00, $10, $09, $66, $2E, $24, $09, $69, $31, $29, $09, $6C, $31, $2E, $16, $42, $16, $7A, $29, $66, $0E, $69, $11, $6C, $11, $7A, $0D, $10, $0A, $7A, $00, $24, $0A, $29, $0A, $7A, $1B, $2E, $17, $42, $17, $7A, $0D, $60, $05, $63, $05, $7A, $0E, $60, $25, $63, $29, $10, $0B, $24, $0B, $29, $0B, $7A, $38, $10, $0C, $24, $0C, $29, $0C, $2E, $18, $42, $18, $7A, $29, $60, $05, $63, $09, $7A, $0E, $16, $F7, $17, $67, $14, $23, $08, $02, $05, $01, $09, $02, $15, $04, $60, $25, $19, $05, $0D, $09, $0A, $04, $0E, $00, $1A, $00, $0B, $00, $64, $0F, $62, $6D, $63, $25, $10, $09, $66, $2E, $24, $09, $69, $31, $7A, $00, $29, $09, $6C, $31, $7A, $0C, $62, $59, $7A, $0D, $62, $45, $2E, $19, $42, $19, $7A, $0D, $62, $31, $7A, $00, $66, $0E, $69, $11, $6C, $11, $7A, $0D, $62, $1D, $10, $0A, $24, $0A, $29, $0A, $7A, $0D, $62, $09, $7A, $0D, $62, $F5, $63, $24, $7A, $0E, $60, $05, $62, $E1, $63, $04, $7A, $0D, $16, $FF, $17, $0A, $14, $0A, $08, $00, $05, $0F, $09, $00, $15, $00, $60, $25, $19, $03, $0D, $04, $0A, $00, $0E, $03, $1A, $02, $0B, $06, $64, $02, $62, $6B, $63, $25, $10, $09, $7A, $00, $66, $2E, $24, $09, $69, $31, $29, $09, $6C, $31, $2E, $1A, $42, $1A, $7A, $29, $66, $0E, $69, $11, $6C, $11, $7A, $0D, $10, $0A, $24, $0A, $29, $0A, $7A, $1B, $2E, $1B, $7A, $00, $42, $1B, $7A, $0D, $60, $05, $63, $05, $7A, $0D, $60, $25, $62, $B0, $63, $25, $10, $0B, $24, $0B, $29, $0B, $7A, $38, $10, $0C, $24, $0C, $29, $0C, $2E, $1C, $42, $1C, $7A, $2A, $60, $05, $63, $05, $7A, $0D, $60, $25, $62, $E5, $63, $25, $10, $09, $66, $2E, $24, $09, $69, $31, $29, $09, $7A, $00, $6C, $31, $7A, $1B, $2E, $1D, $42, $1D, $7A, $0D, $60, $05, $66, $0E, $69, $11, $6C, $11, $7A, $0D, $17, $FF, $14, $20, $08, $FF, $05, $20, $15, $3F, $06, $3F, $61, $00, $10, $0A, $7A, $00, $24, $0A, $29, $0A, $7A, $29, $63, $05, $7A, $0D, $17, $06, $14, $04, $07, $CF, $08, $09, $05, $01, $15, $00, $06, $00, $7A, $00, $61, $06, $5F, $C0, $60, $21, $63, $25, $10, $09, $66, $2E, $24, $09, $69, $31, $29, $09, $6C, $31, $2E, $1E, $42, $1E, $7A, $0D, $5F, $B6, $7A, $0D, $5F, $AC, $7A, $0D, $5F, $A2, $66, $0E, $69, $11, $6C, $11, $7A, $0D, $5F, $98, $10, $0A, $24, $0A, $29, $0A, $7A, $0E, $5F, $8E, $7A, $0D, $5F, $84, $2E, $1F, $42, $1F, $7A, $0D, $5F, $7A, $60, $01, $63, $05, $7A, $0D, $17, $0A, $14, $0A, $07, $FF, $7A, $00, $08, $00, $05, $0F, $61, $0E, $5F, $57, $60, $25, $63, $25, $10, $0B, $24, $0B, $29, $0B, $7A, $37, $10, $0C, $7A, $00, $24, $0C, $29, $0C, $2E, $20, $42, $20, $7A, $29, $60, $05, $63, $05, $7A, $0E, $60, $25, $63, $25, $10, $09, $66, $2E, $24, $09, $69, $31, $29, $09, $6C, $31, $7A, $1B, $2E, $21, $42, $21, $7A, $0D, $66, $0E, $69, $11, $6C, $11, $7A, $0E, $10, $0A, $24, $0A, $29, $0A, $7A, $29, $60, $05, $63, $05, $7A, $0E, $60, $25, $63, $29, $10, $09, $66, $2E, $24, $09, $69, $31, $29, $09, $6C, $31, $2E, $22, $42, $22, $7A, $2A, $66, $0E, $69, $11, $6C, $11, $7A, $0D, $10, $0A, $24, $0A, $29, $0A, $7A, $1B, $2E, $23, $42, $23, $7A, $0E, $60, $05, $63, $09, $7A, $0D, $16, $F7, $17, $67, $14, $23, $08, $02, $05, $01, $09, $02, $15, $04, $60, $25, $19, $05, $0D, $09, $0A, $04, $0E, $00, $1A, $00, $0B, $00, $64, $0F, $62, $6D, $63, $25, $10, $0B, $7A, $00, $24, $0B, $29, $0B, $7A, $0C, $62, $59, $7A, $0D, $62, $45, $7A, $0E, $62, $31, $7A, $0D, $62, $1D, $10, $0C, $24, $0C, $29, $0C, $2E, $24, $42, $24, $7A, $0D, $62, $09, $7A, $0D, $62, $F5, $63, $24, $7A, $0E, $60, $05, $62, $E1, $63, $04, $7A, $0D, $16, $FF, $17, $0A, $14, $0A, $08, $00, $05, $0F, $09, $00, $15, $00, $60, $25, $19, $03, $0D, $04, $0A, $00, $0E, $03, $1A, $02, $0B, $06, $7A, $00, $64, $02, $62, $B0, $63, $25, $10, $09, $66, $2E, $24, $09, $69, $31, $29, $09, $6C, $31, $7A, $1B, $2E, $25, $42, $25, $7A, $0D, $66, $0E, $69, $11, $6C, $11, $7A, $0D, $10, $0A, $24, $0A, $29, $0A, $7A, $2A, $60, $05, $63, $05, $7A, $0D, $60, $25, $63, $29, $10, $09, $66, $2E, $24, $09, $69, $31, $29, $09, $6C, $31, $7A, $00, $2E, $26, $42, $26, $7A, $29, $66, $0E, $69, $11, $6C, $11, $7A, $0D, $10, $0A, $24, $0A, $29, $0A, $7A, $1C, $2E, $27, $42, $27, $7A, $0D, $60, $05, $63, $09, $7A, $0D, $60, $25, $63, $25, $10, $0B, $24, $0B, $29, $0B, $7A, $2A, $60, $05, $7A, $0D, $17, $FF, $14, $20, $08, $FF, $05, $20, $15, $3F, $7A, $00, $06, $3F, $61, $00, $10, $0C, $24, $0C, $29, $0C, $2E, $28, $42, $28, $7A, $29, $63, $05, $7A, $0D, $17, $06, $14, $04, $07, $CF, $7A, $00, $08, $09, $05, $01, $15, $00, $06, $00, $61, $06, $5F, $C0, $60, $21, $62, $E5, $63, $25, $10, $09, $66, $2E, $24, $09, $69, $31, $29, $09, $6C, $31, $7A, $0D, $5F, $B6, $7A, $0D, $5F, $AC, $2E, $29, $42, $29, $7A, $0D, $5F, $A2, $66, $0E, $69, $11, $6C, $11, $7A, $0D, $5F, $98, $7A, $00, $10, $0A, $24, $0A, $29, $0A, $7A, $0D, $5F, $8E, $7A, $0D, $5F, $84, $7A, $0D, $5F, $7A, $60, $01, $63, $05, $7A, $0E, $17, $0A, $14, $0A, $07, $FF, $08, $00, $05, $0F, $61, $0E, $5F, $57, $60, $25, $63, $25, $10, $09, $66, $2E, $24, $09, $69, $31, $29, $09, $6C, $31, $2E, $2A, $42, $2A, $7A, $29, $66, $0E, $69, $11, $6C, $11, $7A, $0E, $10, $0A, $24, $0A, $29, $0A, $7A, $1B, $2E, $2B, $42, $2B, $7A, $0D, $60, $05, $63, $05, $7A, $0E, $60, $25, $63, $25, $10, $09, $66, $2E, $24, $09, $69, $31, $29, $09, $6C, $31, $7A, $2A, $66, $0E, $69, $11, $6C, $11, $7A, $0D, $10, $0A, $24, $0A, $29, $0A, $2E, $2C, $42, $2C, $7A, $2A, $60, $05, $63, $05, $7A, $0D, $60, $25, $63, $29, $10, $0B, $24, $0B, $29, $0B, $7A, $1B, $2E, $2D, $42, $2D, $7A, $1C, $10, $0C, $24, $0C, $29, $0C, $7A, $2A, $60, $05, $63, $09, $7A, $0D, $16, $F7, $17, $67, $14, $23, $08, $02, $05, $01, $09, $02, $15, $04, $60, $25, $19, $05, $0D, $09, $0A, $04, $0E, $00, $1A, $00, $0B, $00, $7A, $00, $64, $0F, $62, $6D, $63, $25, $10, $09, $66, $2E, $24, $09, $69, $31, $29, $09, $6C, $31, $2E, $2E, $42, $2E, $7A, $0C, $62, $59, $7A, $0E, $62, $45, $7A, $0D, $62, $31, $66, $0E, $69, $11, $6C, $11, $7A, $0D, $62, $1D, $10, $0A, $24, $0A, $29, $0A, $7A, $0D, $62, $09, $7A, $0E, $62, $F5, $63, $24, $2E, $2F, $42, $2F, $7A, $0D, $60, $05, $62, $E1, $63, $04, $7A, $0D, $16, $FF, $17, $0A, $14, $0A, $08, $00, $05, $0F, $09, $00, $15, $00, $60, $25, $19, $03, $0D, $04, $7A, $00, $0A, $00, $0E, $03, $1A, $02, $0B, $06, $64, $02, $62, $6B, $63, $25, $10, $09, $66, $2E, $24, $09, $69, $31, $29, $09, $6C, $31, $7A, $29, $66, $0E, $69, $11, $6C, $11, $7A, $0D, $10, $0A, $24, $0A, $29, $0A, $2E, $30, $42, $30, $7A, $2A, $60, $05, $63, $05, $7A, $0D, $60, $25, $62, $B0, $63, $25, $10, $0B, $24, $0B, $7A, $00, $29, $0B, $7A, $1B, $2E, $2F, $42, $2F, $7A, $1B, $10, $0C, $24, $0C, $29, $0C, $7A, $2A, $60, $05, $63, $05, $7A, $0D, $60, $25, $62, $E5, $7A, $00, $63, $25, $10, $09, $66, $2E, $24, $09, $69, $31, $29, $09, $6C, $31, $2E, $2E, $42, $2E, $7A, $29, $60, $05, $66, $0E, $69, $11, $6C, $11, $7A, $0D, $17, $FF, $7A, $00, $14, $20, $08, $FF, $05, $20, $15, $3F, $06, $3F, $61, $00, $10, $0A, $24, $0A, $29, $0A, $7A, $1B, $2E, $2D, $42, $2D, $7A, $0D, $63, $05, $7A, $0E, $17, $06, $14, $04, $07, $CF, $08, $09, $05, $01, $15, $00, $06, $00, $61, $06, $5F, $C0, $60, $21, $62, $02, $63, $26, $10, $09, $66, $2E, $24, $09, $68, $81, $69, $31, $29, $09, $6B, $02, $6C, $32, $6E, $81, $71, $02, $72, $2A, $7A, $0D, $5F, $B6, $7A, $0D, $5F, $AC, $7A, $0D, $5F, $A2, $66, $0E, $69, $11, $7A, $00, $6C, $12, $7A, $0D, $5F, $98, $10, $0A, $24, $0A, $29, $0A, $2E, $2C, $42, $2C, $7A, $0D, $5F, $8E, $7A, $0D, $5F, $84, $7A, $0D, $5F, $7A, $60, $01, $7A, $00, $63, $06, $7A, $0D, $17, $0A, $14, $0A, $07, $FF, $08, $00, $05, $0F, $61, $0E, $5F, $57, $60, $25, $63, $26, $10, $0B, $24, $0B, $29, $0B, $7A, $1B, $2E, $2B, $42, $2B, $7A, $1C, $10, $0C, $24, $0C, $29, $0C, $7A, $2A, $60, $05, $63, $06, $7A, $0D, $60, $25, $63, $26, $10, $09, $66, $2E, $24, $09, $69, $31, $29, $09, $6C, $32, $2E, $2A, $42, $2A, $7A, $2A, $66, $0E, $69, $11, $6C, $12, $7A, $0D, $10, $0A, $24, $0A, $29, $0A, $7A, $1C, $2E, $29, $42, $29, $7A, $0D, $60, $05, $63, $06, $7A, $0D, $60, $25, $63, $2A, $10, $09, $66, $2E, $24, $09, $69, $31, $29, $09, $6C, $32, $7A, $2A, $66, $0E, $69, $11, $6C, $12, $7A, $0D, $10, $0A, $24, $0A, $29, $0A, $2E, $28, $42, $28, $7A, $2A, $60, $05, $63, $0A, $7A, $0D, $16, $F7, $17, $67, $14, $23, $08, $02, $05, $01, $09, $02, $15, $04, $60, $25, $19, $05, $0D, $09, $7A, $00, $0A, $04, $0E, $00, $1A, $00, $0B, $00, $64, $0F, $62, $6D, $63, $25, $10, $0B, $24, $0B, $29, $0B, $7A, $0C, $62, $59, $7A, $0E, $62, $45, $2E, $27, $42, $27, $7A, $0D, $62, $31, $7A, $0D, $62, $1D, $10, $0C, $24, $0C, $29, $0C, $7A, $0D, $62, $09, $7A, $0E, $62, $F5, $63, $24, $7A, $0D, $60, $05, $62, $E1, $63, $04, $7A, $0D, $16, $FF, $17, $0A, $14, $0A, $08, $00, $05, $0F, $09, $00, $7A, $00, $15, $00, $60, $25, $19, $03, $0D, $04, $0A, $00, $0E, $03, $1A, $02, $0B, $06, $64, $02, $62, $CA, $63, $25, $10, $09, $66, $2E, $24, $09, $69, $31, $29, $09, $6C, $32, $2E, $26, $42, $26, $7A, $29, $66, $0E, $69, $11, $6C, $12, $7A, $0D, $10, $0A, $24, $0A, $29, $0A, $7A, $1C, $2E, $25, $42, $25, $7A, $0D, $60, $05, $63, $05, $7A, $0D, $60, $25, $7A, $00, $63, $29, $10, $09, $66, $2E, $24, $09, $69, $31, $29, $09, $6C, $32, $7A, $29, $66, $0E, $69, $11, $6C, $12, $7A, $0E, $10, $0A, $24, $0A, $29, $0A, $2E, $24, $42, $24, $7A, $29, $60, $05, $63, $09, $7A, $0E, $60, $25, $63, $25, $10, $0B, $24, $0B, $29, $0B, $7A, $1B, $2E, $23, $42, $23, $7A, $0D, $60, $05, $7A, $0E, $17, $FF, $14, $20, $08, $FF, $05, $20, $15, $3F, $06, $3F, $61, $00, $10, $0C, $24, $0C, $29, $0C, $7A, $29, $63, $05, $7A, $0E, $17, $06, $14, $04, $07, $CF, $08, $09, $05, $01, $15, $00, $06, $00, $61, $06, $5F, $C0, $60, $21, $62, $02, $63, $26, $10, $09, $66, $2E, $24, $09, $69, $31, $29, $09, $6C, $32, $2E, $22, $7A, $00, $42, $22, $7A, $0C, $5F, $B6, $7A, $0D, $5F, $AC, $7A, $0E, $5F, $A2, $66, $0E, $69, $11, $6C, $12, $7A, $0D, $5F, $98, $10, $0A, $24, $0A, $29, $0A, $7A, $0D, $5F, $8E, $7A, $0D, $5F, $84, $2E, $21, $42, $21, $7A, $0E, $5F, $7A, $60, $01, $63, $06, $7A, $0D, $17, $0A, $14, $0A, $07, $FF, $08, $00, $05, $0F, $61, $0E, $5F, $57, $60, $25, $63, $26, $10, $09, $66, $2E, $24, $09, $69, $31, $29, $09, $6C, $32, $7A, $2A, $66, $0E, $69, $11, $6C, $12, $7A, $0D, $10, $0A, $24, $0A, $29, $0A, $2E, $20, $42, $20, $7A, $2A, $60, $05, $63, $06, $7A, $0D, $60, $25, $63, $26, $10, $09, $66, $2E, $24, $09, $69, $31, $29, $09, $6C, $32, $7A, $1C, $2E, $1F, $42, $1F, $7A, $0D, $66, $0E, $69, $11, $6C, $12, $7A, $0D, $10, $0A, $24, $0A, $29, $0A, $7A, $2A, $60, $05, $63, $06, $7A, $0D, $60, $25, $63, $2A, $10, $0B, $24, $0B, $29, $0B, $2E, $1E, $42, $1E, $7A, $38, $10, $0C, $24, $0C, $29, $0C, $7A, $1C, $2E, $1D, $42, $1D, $7A, $0D, $60, $05, $63, $0A, $7A, $0D, $16, $F7, $17, $67, $14, $23, $08, $02, $05, $01, $09, $02, $7A, $00, $15, $04, $60, $25, $19, $05, $0D, $09, $0A, $04, $0E, $00, $1A, $00, $0B, $00, $64, $0F, $62, $6D, $63, $25, $10, $09, $66, $2E, $24, $09, $69, $31, $29, $09, $6C, $32, $7A, $0D, $62, $59, $7A, $0D, $62, $45, $7A, $0D, $62, $31, $66, $0E, $69, $11, $6C, $12, $7A, $0D, $62, $1D, $10, $0A, $24, $0A, $7A, $00, $29, $0A, $2E, $1C, $42, $1C, $7A, $0D, $62, $09, $7A, $0D, $62, $F5, $63, $24, $7A, $0D, $60, $05, $62, $E1, $63, $04, $7A, $0D, $16, $FF, $17, $0A, $7A, $00, $14, $0A, $08, $00, $05, $0F, $09, $00, $15, $00, $60, $25, $19, $03, $0D, $04, $0A, $00, $0E, $03, $1A, $02, $0B, $06, $64, $02, $62, $81, $63, $25, $10, $09, $66, $2E, $24, $09, $69, $31, $29, $09, $6C, $32, $7A, $1B, $2E, $1B, $42, $1B, $7A, $0D, $66, $0E, $69, $11, $6C, $12, $7A, $0E, $10, $0A, $24, $0A, $29, $0A, $7A, $29, $60, $05, $63, $05, $7A, $0E, $60, $25, $62, $CA, $63, $25, $10, $0B, $24, $0B, $29, $0B, $2E, $1A, $42, $1A, $7A, $38, $10, $0C, $24, $0C, $29, $0C, $7A, $1B, $2E, $19, $42, $19, $7A, $0D, $60, $05, $7A, $00, $63, $05, $7A, $0D, $60, $25, $62, $02, $63, $26, $10, $09, $66, $2E, $24, $09, $69, $31, $29, $09, $6C, $32, $7A, $2A, $60, $05, $66, $0E, $69, $11, $6C, $12, $7A, $0D, $17, $FF, $14, $20, $08, $FF, $05, $20, $15, $3F, $06, $3F, $61, $00, $10, $0A, $24, $0A, $29, $0A, $2E, $18, $42, $18, $7A, $2A, $63, $06, $7A, $0D, $17, $06, $14, $04, $07, $CF, $08, $09, $05, $01, $15, $00, $06, $00, $61, $06, $5F, $C0, $60, $21, $63, $26, $10, $09, $66, $2E, $24, $09, $69, $31, $7A, $00, $29, $09, $6C, $32, $7A, $0C, $5F, $B6, $7A, $0D, $5F, $AC, $2E, $17, $7A, $00, $42, $17, $7A, $0D, $5F, $A2, $66, $0E, $69, $11, $6C, $12, $7A, $0D, $5F, $98, $10, $0A, $24, $0A, $29, $0A, $7A, $0D, $5F, $8E, $7A, $0D, $5F, $84, $7A, $0E, $5F, $7A, $60, $01, $63, $06, $7A, $0D, $17, $0A, $14, $0A, $07, $FF, $08, $00, $05, $0F, $61, $0E, $5F, $57, $60, $25, $63, $26, $10, $0B, $24, $0B, $29, $0B, $7A, $00, $2E, $16, $42, $16, $7A, $37, $10, $0C, $24, $0C, $29, $0C, $7A, $1C, $2E, $15, $42, $15, $7A, $0D, $60, $05, $63, $06, $7A, $0D, $60, $25, $63, $26, $10, $09, $66, $2E, $24, $09, $69, $31, $29, $09, $7A, $00, $6C, $32, $7A, $29, $66, $0E, $69, $11, $6C, $12, $7A, $0D, $10, $0A, $24, $0A, $29, $0A, $2E, $14, $42, $14, $7A, $2A, $60, $05, $63, $06, $7A, $0D, $60, $25, $63, $2A, $10, $09, $66, $2E, $7A, $00, $24, $09, $69, $31, $29, $09, $6C, $32, $7A, $1B, $2E, $13, $42, $13, $7A, $0D, $66, $0E, $69, $11, $6C, $12, $7A, $0D, $10, $0A, $24, $0A, $7A, $00, $29, $0A, $7A, $29, $60, $05, $63, $0A, $7A, $0D, $16, $F7, $17, $67, $7A, $00, $14, $23, $08, $02, $05, $01, $09, $02, $15, $04, $60, $25, $19, $05, $0D, $09, $0A, $04, $0E, $00, $1A, $00, $0B, $00, $64, $0F, $62, $6D, $63, $25, $10, $0B, $24, $0B, $29, $0B, $2E, $12, $42, $12, $7A, $0D, $62, $59, $7A, $0D, $62, $45, $7A, $0D, $62, $31, $7A, $0E, $62, $1D, $10, $0C, $24, $0C, $29, $0C, $7A, $0D, $62, $09, $7A, $0D, $62, $F5, $63, $24, $2E, $11, $42, $11, $7A, $0D, $60, $05, $62, $E1, $63, $04, $7A, $0E, $16, $FF, $17, $0A, $14, $0A, $08, $00, $05, $0F, $09, $00, $15, $00, $60, $25, $19, $03, $0D, $04, $0A, $00, $0E, $03, $1A, $02, $0B, $06, $64, $02, $62, $CA, $63, $25, $10, $09, $66, $2E, $24, $09, $69, $31, $29, $09, $6C, $32, $7A, $29, $66, $0E, $69, $11, $7A, $00, $6C, $12, $7A, $0D, $10, $0A, $24, $0A, $29, $0A, $2E, $10, $42, $10, $7A, $29, $60, $05, $7A, $00, $63, $05, $7A, $0D, $60, $25, $63, $29, $10, $09, $66, $2E, $24, $09, $69, $31, $29, $09, $6C, $32, $7A, $1B, $2E, $0F, $42, $0F, $7A, $0E, $66, $0E, $69, $11, $6C, $12, $7A, $0D, $10, $0A, $24, $0A, $29, $0A, $7A, $2A, $60, $05, $63, $09, $7A, $0D, $60, $25, $63, $25, $10, $0B, $24, $0B, $29, $0B, $2E, $0E, $42, $0E, $7A, $2A, $60, $05, $7A, $0D, $17, $FF, $14, $20, $08, $FF, $05, $20, $15, $3F, $06, $3F, $61, $00, $10, $0C, $24, $0C, $29, $0C, $7A, $1C, $2E, $0D, $42, $0D, $7A, $0D, $63, $05, $7A, $0D, $17, $06, $14, $04, $07, $CF, $08, $09, $05, $01, $15, $00, $06, $00, $61, $06, $5F, $C0, $60, $21, $62, $02, $63, $26, $7A, $00, $10, $09, $66, $2E, $24, $09, $69, $31, $29, $09, $6C, $32, $7A, $0C, $5F, $B6, $7A, $0E, $5F, $AC, $7A, $0D, $5F, $A2, $66, $0E, $69, $11, $6C, $12, $7A, $0D, $5F, $98, $10, $0A, $24, $0A, $29, $0A, $2E, $0C, $42, $0C, $7A, $0D, $5F, $8E, $7A, $0E, $5F, $84, $7A, $0D, $5F, $7A, $60, $01, $63, $06, $7A, $0D, $17, $0A, $14, $0A, $07, $FF, $08, $00, $05, $0F, $61, $0E, $5F, $57, $60, $25, $63, $26, $7A, $00, $10, $09, $66, $2E, $24, $09, $69, $31, $29, $09, $6C, $32, $7A, $1B, $2E, $0B, $42, $0B, $7A, $0D, $66, $0E, $69, $11, $6C, $12, $7A, $0D, $10, $0A, $24, $0A, $29, $0A, $7A, $2A, $60, $05, $63, $06, $7A, $0D, $60, $25, $63, $26, $10, $09, $66, $2E, $7A, $00, $24, $09, $69, $31, $29, $09, $6C, $32, $2E, $0A, $42, $0A, $7A, $29, $66, $0E, $69, $11, $6C, $12, $7A, $0D, $10, $0A, $24, $0A, $7A, $00, $29, $0A, $7A, $1B, $2E, $09, $42, $09, $7A, $0D, $60, $05, $63, $06, $7A, $0D, $60, $25, $7A, $00, $63, $2A, $10, $0B, $24, $0B, $29, $0B, $7A, $38, $10, $0C, $24, $0C, $29, $0C, $2E, $08, $42, $08, $7A, $29, $60, $05, $63, $0A, $7A, $0E, $16, $F7, $17, $67, $14, $23, $08, $02, $05, $01, $09, $02, $15, $04, $60, $25, $19, $05, $0D, $09, $0A, $04, $0E, $00, $1A, $00, $0B, $00, $64, $0F, $62, $6D, $63, $25, $10, $09, $66, $2E, $24, $09, $69, $31, $29, $09, $7A, $00, $6C, $32, $7A, $0C, $62, $59, $7A, $0D, $62, $45, $2E, $07, $42, $07, $7A, $0D, $62, $31, $66, $0E, $7A, $00, $69, $11, $6C, $12, $7A, $0D, $62, $1D, $10, $0A, $24, $0A, $29, $0A, $7A, $0D, $62, $09, $7A, $0D, $62, $F5, $63, $24, $7A, $0D, $60, $05, $7A, $00
; SONG_END:

    .include "../drivers/delayroutines.s"
    .segment "ROM_VECTORS"  
nmivec: 
    .WORD  reset
resvec:
    .WORD  reset
irqvec:
    .WORD  reset 