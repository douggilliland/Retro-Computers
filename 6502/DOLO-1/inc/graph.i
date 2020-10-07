;**********************************************************
;*
;*	DOLO-1 HOMEBREW COMPUTER
;*	Hardware and software design by Dolo Miah
;*	Copyright 2014-18
;*  Free to use for any non-commercial purpose subject to
;*  full credit of original my authorship please!
;*
;*  GRAPH.I
;*  This is the definition file for graphics, specifically
;*  The graphics screen handling module.  It is just a
;*  structure definition - but this structure is used to
;*  record the important attributes of a text screen.
;*  Needed because there is both a 40 and 32 columns mode
;*  supported by the VDP, and the screens are not in the
;*  same location.
;*
;**********************************************************

	struct gr_screen
	dw gr_screen_start			;* Start of screen memory in VDP
	dw gr_screen_size			;* Number of bytes screen occupies
	db gr_screen_w				;* Number of columns
	db gr_screen_h				;* Number of rows
	dw gr_screen_ptr			;* VDP dddress of cursor
	db gr_cur_x					;* Current X position of cursor
	db gr_cur_y					;* Current Y position of cursor					
	end struct