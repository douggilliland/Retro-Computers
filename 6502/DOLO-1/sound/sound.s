;**********************************************************
;*
;*	DOLO-1 HOMEBREW COMPUTER
;*	Hardware and software design by Dolo Miah
;*	Copyright 2014-18
;*  Free to use for any non-commercial purpose subject to
;*  full credit of original my authorship please!
;*
;*  SOUND.S
;*  Sound driver module - routines to access the AY-3-8910
;*  This sound chip was found in a number of popular micros
;*  in the early to mid 80s, including my first computer,
;*  the Oric-1, as well as the MSX range.  Interfacing this
;*  chip is through port A of VIA 2 because it cannot be
;*  connected directly to the 6502 bus.  This means that it
;*  is a bit clunky to drive, but this is how the Oric-1
;*  did it, so I guess I can't be too wrong with this
;*  approach.
;*  The AY doesn't only produce sound, it also has a couple
;*  of 8 bit IO port - one of them I am using for joystick.
;*
;**********************************************************


	; ROM code
	code

;****************************************
;* snd_set
;* Set AY register X to value Y
;* Input : X = Reg no, Y = Value
;* Output : None
;* Regs affected : None
;****************************************
snd_set
	pha

	lda #0xff				; Set Port A to output
	sta IO_1 + DDRA

	stx SND_ADBUS			; Put X on the sound bus (X = reg address)

	lda SND_MODE			; Need to preserve contents of other bits
	and #SND_DESELECT_MASK	; Mask off mode bits
	ora #SND_SELSETADDR		; Select AY mode to latch address
	sta SND_MODE			; This write will process the data in ADBUS according to SND_MODE

	and #SND_DESELECT_MASK	; Mask off mode bits
	sta SND_MODE			; This write will deselect the AY ready for next command
	
	sty SND_ADBUS			; Put Y on the sound bus (Y = value)
	ora #SND_SELWRITE		; Select mode for writing data
	sta SND_MODE			; This write will process the data in ADBUS according to SND_MODE
	
	and #SND_DESELECT_MASK	; Mask off mode bits
	sta SND_MODE			; This write will deselect the AY ready for next command

	pla
	
	rts

;****************************************
;* snd_get
;* Get AY register X to Y
;* Input : X = Reg no
;* Output : Y = Value
;* Regs affected : None
;****************************************
snd_get
	pha

	lda #0xff				; Set Port A to output
	sta IO_1 + DDRA

	stx SND_ADBUS			; Put X on the sound bus (X = reg address)

	lda SND_MODE			; Need to preserve contents of other bits
	and #SND_DESELECT_MASK	; Mask off mode bits
	ora #SND_SELSETADDR		; Select AY mode to latch address
	sta SND_MODE			; This write will process the data in ADBUS according to SND_MODE

	and #SND_DESELECT_MASK	; Mask off mode bits
	sta SND_MODE			; This write will deselect the AY ready for next command

	lda #0x00				; Set Port A to input
	sta IO_1 + DDRA

	lda SND_MODE			; Need to preserve contents of other bits
	and #SND_DESELECT_MASK	; Mask off mode bits
	ora #SND_SELREAD		; Select mode for reading data
	sta SND_MODE			; This write will process the data in ADBUS according to SND_MODE

	ldy SND_ADBUS			; Get value in to Y
	
	and #SND_DESELECT_MASK	; Mask off mode bits
	sta SND_MODE			; This write will deselect the AY ready for next command

	pla
	
	rts

;****************************************
;* snd_get_joy0
;* Return value of joystick 0
;* Input : None
;* Output : Y = Value
;* Regs affected : X
;****************************************
snd_get_joy0
	ldx #SND_REG_IOB		; Joystick is plugged in to IOB
	jsr snd_get				; Get IOB, result in Y
	rts

	
;****************************************
;* init_snd
;* Initialise sound - after cia 1 has been initialised
;* Input : None
;* Output : None
;* Regs affected : All
;****************************************
init_snd
	ldx #0x00
init_snd_regs
	ldy snd_init_tab,x
	jsr snd_set				; Set X to Y
	inx
	cpx #16					; Done 16?
	bne init_snd_regs		; Nope	
	
	rts						; return from sub

	; Register array initialisation values
snd_init_tab
	db 0x80				; R0 = Channel A Tone Low
	db 0x00				; R1 = Channel A Tone High
	db 0x00				; R2 = Channel B Tone Low
	db 0x01				; R3 = Channel B Tone High
	db 0x00				; R4 = Channel C Tone Low
	db 0x02				; R5 = Channel C Tone High
	db 0x00				; R6 = Noise period
	db 0b00111110		; R7 = Control : IOB input, IOA input, No Noise, only A enabled
	db 0x1f				; R8 = Channel A Vol
	db 0x1f				; R9 = Channel B Vol
	db 0x1f				; R10 = Channel C Vol
	db 0x00				; R11 = Envelope Period Low
	db 0x09				; R12 = Envelope Period High
	db 0b00000000		; R13 = Envelope Shape : 0000
	db 0x00				; R14 = IO Port A
	db 0x00				; R15 = IO Port B ; Initialise to 0

snd_music_tab
	dw 2565				; C		0
	dw 2421				; C#	1
	dw 2286				; D		2
	dw 2157				; D#	3
	dw 2036				; E		4
	dw 1922				; F		5
	dw 1814				; F#	6
	dw 1712				; G		7
	dw 1616				; G#	8
	dw 1525				; A		9
	dw 1440				; A#	10
	dw 1359				; B		11
	
	dw 1283				; C
	dw 1211				; C#
	dw 1143				; D
	dw 1079				; D#
	dw 1018				; E
	dw 961 				; F
	dw 907 				; F#
	dw 856 				; G
	dw 808 				; G#
	dw 763 				; A
	dw 720 				; A#
	dw 679 				; B

	dw 641				; C
	dw 605				; C#
	dw 571				; D
	dw 539				; D#
	dw 509				; E
	dw 480				; F
	dw 453				; F#
	dw 428				; G
	dw 404				; G#
	dw 381				; A
	dw 360				; A#
	dw 340				; B

	dw 321				; C
	dw 303				; C#
	dw 286				; D
	dw 270				; D#
	dw 254				; E
	dw 240				; F
	dw 227				; F#
	dw 214				; G
	dw 202				; G#
	dw 191				; A
	dw 180				; A#
	dw 170				; B

	dw 160				; C
	dw 151				; C#
	dw 143				; D
	dw 135				; D#
	dw 127				; E
	dw 120				; F
	dw 113				; F#
	dw 107				; G
	dw 101				; G#
	dw 95 				; A
	dw 90 				; A#
	dw 85 				; B

	dw 80				; C
	dw 76				; C#
	dw 71				; D
	dw 67				; D#
	dw 64				; E
	dw 60				; F
	dw 57				; F#
	dw 54				; G
	dw 51				; G#
	dw 48				; A
	dw 45				; A#
	dw 42				; B

	dw 40				; C
	dw 38				; C#
	dw 36				; D
	dw 34				; D#
	dw 32				; E
	dw 30				; F
	dw 28				; F#
	dw 27				; G
	dw 25				; G#
	dw 24				; A
	dw 22				; A#
	dw 21				; B
