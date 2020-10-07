;**********************************************************
;*
;*	DOLO-1 HOMEBREW COMPUTER
;*	Hardware and software design by Dolo Miah
;*	Copyright 2014-18
;*  Free to use for any non-commercial purpose subject to
;*  full credit of original my authorship please!
;*
;*  IO.I
;*  Definitions file for the IO module.  The key structure
;*  used by the IO system is defined here.
;*
;**********************************************************

;* General IO structure allows the system to swap in
;* different IO devices by using indirect calls to
;* the appropriate routines.
	struct io_struct
	ds	io_get_byte,	2			;* Address of get byte
	ds	io_put_byte,	2			;* Address of put byte
	ds	io_open_r,		2			;* Address of open file for read
	ds	io_open_w,		2			;* Address of open file for write
	ds	io_close_f,		2			;* Address of close file
	ds	io_del_f,		2			;* Address of delete file
	ds	io_ext1,		2			;* Address of extended function 1
	ds	io_ext2,		2			;* Address of extended function 2
	end struct