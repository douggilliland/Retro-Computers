;**********************************************************
;*
;*	DOLO-1 HOMEBREW COMPUTER
;*	Hardware and software design by Dolo Miah
;*	Copyright 2014-18
;*  Free to use for any non-commercial purpose subject to
;*  full credit of original my authorship please!
;*
;*  ERROR.I
;*  Error definitions file.
;*  The macro to throw an error is elswhere, but basically
;*  It issues a 6502 BRK commmand with the next byte being
;*  the error code.  The BRK handler then picks up the
;*  code and shows the appropriate message plus any line
;*  number if a program was running.
;*
;**********************************************************

	; ROM code
	code  

; Error message numbers
DFERR_OK		=	0
DFERR_ERROR		=	1
DFERR_SYNTAX	=	2
DFERR_RUNTIME	=	3
DFERR_TYPEMISM	=	4
DFERR_DIM		=	5
DFERR_UNTIL		=	6
DFERR_NOPROC	=	7
DFERR_PROCPARM	=	8
DFERR_IMMEDIATE	=	9
DFERR_UNCLOSEDIF=	10
DFERR_NOIF		=	11
DFERR_NEXTFOR	=	12
DFERR_FNAME		=	13
DFERR_STRLONG	=	14
DFERR_BREAK		=	15
DFERR_NODATA	=	16
DFERR_WEND		=	17
DFERR_NOLINE	=	18
DFERR_RETURN	=	19

