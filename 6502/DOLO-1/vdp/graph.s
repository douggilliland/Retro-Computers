;**********************************************************
;*
;*	DOLO-1 HOMEBREW COMPUTER
;*	Hardware and software design by Dolo Miah
;*	Copyright 2014-18
;*  Free to use for any non-commercial purpose subject to
;*  full credit of original my authorship please!
;*
;*  GRAPH.S
;*  This is the graphics module, to handle text and hires
;*  graphics.  On startup, the BBC DIP settings define
;*  whether the computer will go in to 32 or 40 column
;*  screen mode.  The kernel code calls the right
;*  initialisation code.
;*  For text modes, this module keeps track of where to
;*  next put a character, and also takes care of wrapping
;*  to the next line as well as scrolling the contents up
;*  when the cursor has reached the bottom right.  This
;*  module also enables text input which is echoed to the
;*  screen, to allow interactive input and editing.
;*
;**********************************************************

	; ROM code
	code

;****************************************
;* gr_init_screen_common
;* Common screen initialisation code
;* A = Blank character
;****************************************
gr_init_screen_common
	; Store blank char
	sta vdp_blank
	
	; VRAM address of screen data
	lda vdp_base+vdp_addr_nme
	sta gr_scrngeom+gr_screen_start
	lda vdp_base+vdp_addr_nme+1
	sta gr_scrngeom+gr_screen_start+1

	; Cursor pointer in to screen
	lda gr_scrngeom+gr_screen_start
	sta gr_scrngeom+gr_screen_ptr
	lda gr_scrngeom+gr_screen_start+1
	sta gr_scrngeom+gr_screen_ptr+1

	; Top left cursor position 0,0
	stz gr_scrngeom+gr_cur_x
	stz gr_scrngeom+gr_cur_y
	
	jsr gr_cls
	
	rts

;****************************************
;* gr_init_screen_g1
;* initialise the screen in graphic mode 1
;****************************************
gr_init_screen_g1
	jsr init_vdp_g1

	; Size of screen in bytes
	lda #lo(768)					
	sta gr_scrngeom+gr_screen_size
	lda #hi(768)	
	sta gr_scrngeom+gr_screen_size+1

	; Width and height
	lda #32
	sta gr_scrngeom+gr_screen_w
	lda #24
	sta gr_scrngeom+gr_screen_h

	lda #' '						; Blank is SPACE
	jsr gr_init_screen_common
	rts

;****************************************
;* gr_init_screen_txt
;* initialise the screen in text mode
;****************************************
gr_init_screen_txt
	jsr init_vdp_txt

	; Size of screen in bytes
	lda #lo(960)					
	sta gr_scrngeom+gr_screen_size
	lda #hi(960)	
	sta gr_scrngeom+gr_screen_size+1

	; Width and height
	lda #40
	sta gr_scrngeom+gr_screen_w
	lda #24
	sta gr_scrngeom+gr_screen_h

	lda #' '						; Blank is SPACE
	jsr gr_init_screen_common

	rts

;****************************************
;* gr_init_screen_hires
;* Input : X = Colour table fill value
;* initialise the screen in hires mode
;****************************************
gr_init_screen_hires
	phx

	inc vdp_curoff
	
	jsr init_vdp_hires

	; Size of screen in bytes
	lda #lo(6144)					
	sta gr_scrngeom+gr_screen_size
	lda #hi(6144)	
	sta gr_scrngeom+gr_screen_size+1

	; Width and height
	lda #32
	sta gr_scrngeom+gr_screen_w
	lda #192
	sta gr_scrngeom+gr_screen_h

	sei
	; point to colour table
	ldx vdp_base+vdp_addr_col
	lda vdp_base+vdp_addr_col+1
	jsr vdp_wr_addr
	; set colour for 0x18 pages (6144) bytes
	pla							; Get the saved value from stack
	ldx #0
	ldy #0x18
	jsr vdp_fill_vram

	cli
	
	; Now point screen at pattern for HIRES
	lda vdp_base+vdp_addr_pat
	sta vdp_base+vdp_addr_nme
	lda vdp_base+vdp_addr_pat+1
	sta vdp_base+vdp_addr_nme+1
	
	lda #0							; Blank is ZERO
	jsr gr_init_screen_common
	

	rts

;****************************************
;* gr_init_screen
;* A = Mode (0 = text, Not zero = graphic)
;* initialise the screen in text mode
;****************************************
gr_init_screen
	cmp #0
	bne gr_init_skip_txt
	jmp gr_init_screen_txt
gr_init_skip_txt
	jmp gr_init_screen_g1

;****************************************
;* gr_cls
;* Clear the screen
;****************************************
gr_cls
	pha
	phx
	phy
	
	; Set VDP Address
	sei
	ldx gr_scrngeom+gr_screen_start
	lda gr_scrngeom+gr_screen_start+1
	jsr vdp_wr_addr

	; X and Y count bytes to fill
	ldx #0
	ldy #0
	lda vdp_blank
gr_cls_loop
	jsr vdp_wr_vram_fast
	inx
	bne gr_cls_skipy
	iny
gr_cls_skipy
	cpx gr_scrngeom+gr_screen_size
	bne gr_cls_loop
	cpy gr_scrngeom+gr_screen_size+1
	bne gr_cls_loop
	
	cli
	
	ply
	plx
	pla
	
	rts
	
;****************************************
;* gr_plot
;* Write a byte in the current cursor pos
;* Input : A = Byte to put
;* Output : None
;* Regs affected : None
;****************************************
gr_plot
	_pushAXY
	ldx gr_scrngeom+gr_screen_ptr
	ldy gr_scrngeom+gr_screen_ptr+1
	sta vdp_curval					; Update cursor value
	jsr vdp_poke
	_pullAXY
	rts

;****************************************
;* gr_point
;* Write a point to the X,Y coordinates with mode A
;* Input : X,Y = coord, A = mode (0,1,2)
;* Output : None
;* Regs affected : None
;****************************************
gr_point
	; Save A and X for later
	pha
	phx
	; Low byte = X&F8 | Y&07
	txa
	and #0xf8
	sta tmp_alo
	tya
	and #0x07
	ora tmp_alo
	sta tmp_alo
	; High byte = Y>>3
	tya
	lsr a
	lsr a
	lsr a
	sta tmp_ahi
	; Get the current VRAM byte (address in X,A)
	ldx tmp_alo
	jsr vdp_peek
	; Save in temp
	sta tmp_blo
	; Get X back and mask off 3 LSBs
	pla
	and #0x07
	; Use this to find the bit number mask and save in temp
	tax
	lda gr_point_mask,x
	sta tmp_bhi
	; Get the mode number in to X
	plx
	; load VRAM byte
	lda tmp_blo
	; first assume that we want to set a bit - OR with VRAM
	ora tmp_bhi
	; if that is correct then done
	cpx #1
	beq gr_point_done
	; now assume that actually we want to erase but - EOR with VRAM
	eor tmp_bhi
	; if that is correct then done
	cpx #0
	beq gr_point_done
	; else we want to really just do an eor of VRAM with bit mask
	lda tmp_blo
	eor tmp_bhi
	; so now we have the VRAM bit set properly in temp - poke it back
gr_point_done
	ldx tmp_alo
	ldy tmp_ahi
	jsr vdp_poke
	rts
gr_point_mask
	db 0x80,0x40,0x20,0x10,0x08,0x04,0x02,0x01

;****************************************
;* gr_line
;* Draw a line from x0,y0 -> x1,y1 in mode A
;* Input :	num_a   = x0
;*			num_a+1 = y0
;*			num_a+2 = x1
;*			num_a+3 = y1
;*			A = mode (0,1,2)
;* Output : None
;* Regs affected : None
;****************************************
gr_line

grl_x0 	= (num_a)
grl_y0 	= (num_a+1)
grl_x1 	= (num_a+2)
grl_y1 	= (num_a+3)
grl_m	= (num_b)
grl_dx	= (num_b+1)
grl_dy	= (num_b+2)
grl_xyyx= (num_b+3)
grl_2dx	= (num_x)
grl_2dy	= (num_x+2)
grl_2dxy= (num_tmp)
grl_inx	= (num_tmp+2)
grl_iny = (num_tmp+3)
grl_p	= (num_buf)

	sta grl_m					; Save mode for later
	stz grl_xyyx				; Assume normal xy axis
	
;    int dx, dy, p, x, y;
	; check if abs(dy)>abs(dx) if so need to swap xy
	; num_b = abs(x), num_b+1 = abs(dy)
	sec
	lda grl_x1
	sbc grl_x0
	bcs gr_line_skip_dx_neg
	eor #0xff
	inc a
gr_line_skip_dx_neg
	sta grl_dx
	sec
	lda grl_y1
	sbc grl_y0
	bcs gr_line_skip_dy_neg
	eor #0xff
	inc a
gr_line_skip_dy_neg
	sta grl_dy
	cmp grl_dx
	bcc gr_line_skip_xy_swap
	; swap xy axes and also dx and dy
	lda grl_x0					; swap x0 and y0
	ldx grl_y0
	sta grl_y0
	stx grl_x0
	lda grl_x1					; swap x1 and y1
	ldx grl_y1
	sta grl_y1
	stx grl_x1
	lda grl_dx					; swap dy and dx
	ldx grl_dy
	sta grl_dy
	stx grl_dx
	inc grl_xyyx				; set flag to Not Z to know about axis change
	
gr_line_skip_xy_swap	
	; assume going from left to right
	lda #1
	sta grl_inx
	lda grl_x0
	cmp grl_x1
	bcc gr_line_skip_x_swap
	lda #0xff					; make x increment negative
	sta grl_inx
	
gr_line_skip_x_swap
	; assume going from top to bottom
	lda #1
	sta grl_iny
	lda grl_y0
	cmp grl_y1
	bcc gr_line_skip_y_up
	lda #0xff					; make y increment negative
	sta grl_iny

gr_line_skip_y_up
	lda grl_dx
	asl a
	sta grl_2dx					; 2*dx (word)
	stz grl_2dx+1
	rol grl_2dx+1

	lda grl_dy
	asl a
	sta grl_2dy					; 2*dy (word)
	stz grl_2dy+1
	rol grl_2dy+1
	
;    p=2*dy-dx;					; p (word)
	sec
	lda grl_2dy
	sbc grl_dx
	sta grl_p
	lda grl_2dy+1
	sbc #0
	sta grl_p+1
	
;   2*(dy-dx)					; num_tmp+2 = 2*(dy-dx)
	sec
	lda grl_2dy
	sbc grl_2dx
	sta grl_2dxy
	lda grl_2dy+1
	sbc grl_2dx+1
	sta grl_2dxy+1

gr_line_pixel
	; plot the current pixel position
	ldx grl_x0
	ldy grl_y0
	lda grl_xyyx				; is xy swapped?
	beq gr_skip_xy_swap2
	ldx grl_y0
	ldy grl_x0	
gr_skip_xy_swap2
	lda grl_m
	jsr gr_point
	
	lda grl_x0					; Check if done
	cmp grl_x1
	beq gr_line_done

	; check sign of p
	lda grl_p+1
	bmi gr_line_neg_p

	; if p >=0
	
	; y=y+increment
	clc
	lda grl_y0
	adc grl_iny
	sta grl_y0

	; p=p+2*dy-2*dx
	_addZPWord grl_p,grl_2dxy
	bra gr_line_incx

gr_line_neg_p
	; if p < 0
	; p=p+2*dy
	_addZPWord grl_p,grl_2dy
	
gr_line_incx
	clc
	lda grl_x0
	adc grl_inx
	sta grl_x0
	bra gr_line_pixel
gr_line_done
	rts
	

;    while(x<x1)
;    {
;        if(p>=0)
;        {
;            putpixel(x,y,7);
;            y=y+1;
;            p=p+2*dy-2*dx;
;        }
;        else
;        {
;            putpixel(x,y,7);
;            p=p+2*dy;
;        }
;        x=x+1;
;    }


;****************************************
;* gr_scroll_up
;* Scroll screen one line up
;****************************************
gr_scroll_up
	pha
	phx
	phy

	
	; Get VDP Address of line + 1 line (source addr)
	clc
	lda gr_scrngeom+gr_screen_start
	adc gr_scrngeom+gr_screen_w
	sta tmp_alo
	lda gr_scrngeom+gr_screen_start+1
	adc #0
	sta tmp_ahi
	
	; Get destinaton address = first line of screen
	lda gr_scrngeom+gr_screen_start
	sta tmp_blo
	lda gr_scrngeom+gr_screen_start+1
	sta tmp_bhi
	
	ldy gr_scrngeom+gr_screen_h
	dey
	sei

	; Cursor off
	inc vdp_curoff
gr_scroll_cpy_ln
	; Set VDP with source address to read
	ldx tmp_alo
	lda tmp_ahi
	jsr vdp_rd_addr

	; Read in a line worth of screen
	ldx gr_scrngeom+gr_screen_w
gr_scroll_read_ln
	jsr vdp_rd_vram_fast
	sta scratch,x
	dex
	nop
	nop
	bne gr_scroll_read_ln

	; Set VDP with destinaton to write
	ldx tmp_blo
	lda tmp_bhi
	jsr vdp_wr_addr
	
	; Write out a line worth of screen
	ldx gr_scrngeom+gr_screen_w
gr_scroll_write_ln
	lda scratch,x
	jsr vdp_wr_vram_fast
	dex
	bne gr_scroll_write_ln

	; Update source address
	clc
	lda tmp_alo
	adc gr_scrngeom+gr_screen_w
	sta tmp_alo
	lda tmp_ahi
	adc #0
	sta tmp_ahi
	; Update destinaton address
	clc
	lda tmp_blo
	adc gr_scrngeom+gr_screen_w
	sta tmp_blo
	lda tmp_bhi
	adc #0
	sta tmp_bhi

	; One line complete
	dey
	bne gr_scroll_cpy_ln
	
	; VDP is pointing at last line
	; Needs to be filled with blank
	lda vdp_blank
	ldx gr_scrngeom+gr_screen_w
gr_scroll_erase_ln
	jsr vdp_wr_vram_fast
	dex
	bne gr_scroll_erase_ln

	; Cursor on
	dec vdp_curoff
	
	cli
	
	ply
	plx
	pla
	
	rts
	
;****************************************
;* gr_set_cur_pos
;* Set the cursor position
;* Input : X, Y = position
;* Output : None
;* Regs affected : None
;****************************************
gr_set_cur_pos
	pha
	phx
	phy

	; Initialise pointer to start of screen
;	lda gr_scrngeom+gr_screen_start
;	sta gr_scrngeom+gr_screen_ptr
;	lda gr_scrngeom+gr_screen_start+1
;	sta gr_scrngeom+gr_screen_ptr+1
	
	; 32 or 40 columns table selection
	lda gr_scrngeom+gr_screen_w
	cmp #40
	bne gr_set_skip_40

	clc
	lda gr_offset_40lo, y
	adc gr_scrngeom+gr_screen_start
	sta gr_scrngeom+gr_screen_ptr
	lda gr_offset_40hi, y
	adc gr_scrngeom+gr_screen_start+1
	sta gr_scrngeom+gr_screen_ptr+1
	bra gr_add_x_offset

gr_set_skip_40
	clc
	lda gr_offset_32lo, y
	adc gr_scrngeom+gr_screen_start
	sta gr_scrngeom+gr_screen_ptr
	lda gr_offset_32hi, y
	adc gr_scrngeom+gr_screen_start+1
	sta gr_scrngeom+gr_screen_ptr+1

gr_add_x_offset	
	clc
	txa
	adc gr_scrngeom+gr_screen_ptr
	sta gr_scrngeom+gr_screen_ptr
	lda gr_scrngeom+gr_screen_ptr+1
	adc #0
	sta gr_scrngeom+gr_screen_ptr+1

	; Update cursor x,y position
	stx gr_scrngeom+gr_cur_x
	sty gr_scrngeom+gr_cur_y

	; A already contains high byte of pointer
	sei
	ldx gr_scrngeom+gr_screen_ptr	; Load low byte of pointer
	jsr vdp_rd_addr
	jsr vdp_rd_vram_fast			; Read contents of new position
	sta vdp_curval					; Update current value
	cli
	
	ply
	plx
	pla
	
	rts

;****************************************
;* gr_cur_right
;* Advance cursor position (do after a vdp_wr_vram)
;* to keep system parameters up to date
;* Input : None
;* Output : None
;* Regs affected : None
;****************************************
gr_cur_right
	pha
	phx
	phy

	; Load cursor x,y position
	ldx gr_scrngeom+gr_cur_x
	ldy gr_scrngeom+gr_cur_y

	
	; Move cursor right
	inx
	; Check if reached past edge of line
	cpx gr_scrngeom+gr_screen_w
	bne gr_adv_skip_nl
	; If got here then wrap to next line
	ldx #0
	iny
	cpy gr_scrngeom+gr_screen_h
	bne gr_adv_skip_nl
	; If got here then screen needs to scroll
	dey
	jsr gr_scroll_up
gr_adv_skip_nl
	jsr gr_set_cur_pos
	
	ply
	plx
	pla
	
	rts

;****************************************
;* gr_cur_left
;* Advance cursor left (do after a vdp_wr_vram)
;* to keep system parameters up to date
;* Input : None
;* Output : None
;* Regs affected : None
;****************************************
gr_cur_left
	phx
	phy

	; Load cursor x,y position, load X last to check for 0
	ldy gr_scrngeom+gr_cur_y
	ldx gr_scrngeom+gr_cur_x
	
	; Decrement screen pointer
	; Move cursor left
	bne gr_cur_skip_at_left		; If already at the left
	cpy #0						; If already at the top left
	beq gr_cur_skip_at_tl
	dey
	ldx gr_scrngeom+gr_screen_w
gr_cur_skip_at_left
	dex
	jsr gr_set_cur_pos

gr_cur_skip_at_tl	
	
	ply
	plx
	
	rts

;****************************************
;* gr_cur_up
;* Advance cursor up (do after a vdp_wr_vram)
;* to keep system parameters up to date
;* Input : None
;* Output : None
;* Regs affected : None
;****************************************
gr_cur_up
	phx
	phy

	; Load cursor x,y position, load Y last to check for zero
	ldx gr_scrngeom+gr_cur_x
	ldy gr_scrngeom+gr_cur_y
	
	beq gr_cur_skip_at_top	; If already at the top, don't do anything
	dey
	jsr gr_set_cur_pos

gr_cur_skip_at_top
	ply
	plx
	
	rts

;****************************************
;* gr_cur_down
;* Advance cursor down (do after a vdp_wr_vram)
;* to keep system parameters up to date
;* Input : None
;* Output : None
;* Regs affected : None
;****************************************
gr_cur_down
	phx
	phy

	; Load cursor x,y position
	ldx gr_scrngeom+gr_cur_x
	ldy gr_scrngeom+gr_cur_y
	iny
	cpy gr_scrngeom+gr_screen_h			; If already at  bottom
	beq gr_cur_skip_at_bot				; then don't do anything
	
	jsr gr_set_cur_pos

gr_cur_skip_at_bot
	
	ply
	plx
	
	rts


;****************************************
;* gr_new_ln
;* Carry out a new line
;* Input : None
;* Output : None
;* Regs affected : None
;****************************************
gr_new_ln
	phx
	phy

	; X pos is zero, Y needs to increment
	ldx #0
	ldy gr_scrngeom+gr_cur_y
	iny
	cpy gr_scrngeom+gr_screen_h
	bne gr_nl_skip_nl
	; If got here then screen needs to scroll
	dey
	jsr gr_scroll_up
gr_nl_skip_nl
	jsr gr_set_cur_pos
	
	ply
	plx
	
	rts
	
;****************************************
;* gr_del
;* Action del
;* Input : None
;* Output : None
;* Regs affected : None
;****************************************
gr_del
	pha
	jsr gr_cur_left
	lda #' '							; Put a space
	jsr gr_plot
	pla
	rts


;****************************************
;* gr_get_key
;* Waits for a key press, C=1 synchronous
;* A = Key code
;****************************************
gr_get_key
	jsr kb_get_key
	bcs gr_key_no_key
	cmp #UTF_ACK						; Copy key pressed?
	bne gr_not_copy
	lda vdp_curval						; If yes the get char under cursor
	and #0x7f							; Make it standard ASCII range
gr_not_copy
	clc
gr_key_no_key
	rts	
	
;****************************************
;* gr_put_byte
;* Put a byte out
;* Input : A = Byte to put
;* Output : None
;* Regs affected : None
;****************************************
gr_put_byte
	phx
	pha

	cmp #UTF_DEL			; Del key
	beq gr_process_special
	cmp #32					; Special char?
	bcs gr_pb_notspecial	; >=32 == carry clear

gr_process_special
	; Restore char under cursor
	lda vdp_curval
	and #0x7f
	jsr gr_plot
	pla
	plx
	
	cmp #UTF_CR				; New line?
	bne gr_skip_new_ln
	jmp gr_new_ln
gr_skip_new_ln
	cmp #UTF_DEL			; Delete?
	bne gr_skip_del
	jmp gr_del
gr_skip_del
	cmp #CRSR_LEFT
	bne gr_skip_left
	jmp gr_cur_left
gr_skip_left
	cmp #CRSR_RIGHT
	bne gr_skip_right
	jmp gr_cur_right
gr_skip_right
	cmp #CRSR_UP
	bne gr_skip_up
	jmp gr_cur_up
gr_skip_up
	cmp #CRSR_DOWN
	bne gr_skip_down
	jmp gr_cur_down
gr_skip_down
	cmp #UTF_FF
	bne gr_skip_cls
	jmp gr_cls
gr_skip_cls
	rts

;	Normal caracter processing here.
gr_pb_notspecial
	; Load current cursor position
	jsr gr_plot
	jsr gr_cur_right

	pla
	plx

	rts

;* These tables are to speed up calculating the 
;* offset for plot commands, rather than using
;* a series of left shifts and additions.
;* Not sure if it is worth the 96 bytes :-O
gr_offset_40lo
	db lo(0*40), lo(1*40), lo(2*40), lo(3*40)
	db lo(4*40), lo(5*40), lo(6*40), lo(7*40)
	db lo(8*40), lo(9*40), lo(10*40), lo(11*40)
	db lo(12*40), lo(13*40), lo(14*40), lo(15*40)
	db lo(16*40), lo(17*40), lo(18*40), lo(19*40)
	db lo(20*40), lo(21*40), lo(22*40), lo(23*40)
gr_offset_40hi
	db hi(0*40), hi(1*40), hi(2*40), hi(3*40)
	db hi(4*40), hi(5*40), hi(6*40), hi(7*40)
	db hi(8*40), hi(9*40), hi(10*40), hi(11*40)
	db hi(12*40), hi(13*40), hi(14*40), hi(15*40)
	db hi(16*40), hi(17*40), hi(18*40), hi(19*40)
	db hi(20*40), hi(21*40), hi(22*40), hi(23*40)
gr_offset_32lo
	db lo(0*32), lo(1*32), lo(2*32), lo(3*32)
	db lo(4*32), lo(5*32), lo(6*32), lo(7*32)
	db lo(8*32), lo(9*32), lo(10*32), lo(11*32)
	db lo(12*32), lo(13*32), lo(14*32), lo(15*32)
	db lo(16*32), lo(17*32), lo(18*32), lo(19*32)
	db lo(20*32), lo(21*32), lo(22*32), lo(23*32)
gr_offset_32hi
	db hi(0*32), hi(1*32), hi(2*32), hi(3*32)
	db hi(4*32), hi(5*32), hi(6*32), hi(7*32)
	db hi(8*32), hi(9*32), hi(10*32), hi(11*32)
	db hi(12*32), hi(13*32), hi(14*32), hi(15*32)
	db hi(16*32), hi(17*32), hi(18*32), hi(19*32)
	db hi(20*32), hi(21*32), hi(22*32), hi(23*32)
	