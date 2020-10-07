;**********************************************************
;*
;*	DOLO-1 HOMEBREW COMPUTER
;*	Hardware and software design by Dolo Miah
;*	Copyright 2014-18
;*  Free to use for any non-commercial purpose subject to
;*  full credit of original my authorship please!
;*
;*  DFLAT.I
;*  This is the main definitions file for dflat.  The key
;*  definitions are in here to access the data structures
;*  used by dflat.
;*
;**********************************************************

;* Start dflat program memory
DF_PROGSTART=	mem_start
;* This is the top of usable dflat memory plus 1
DF_MEMTOP	=	0xb000

;* Offset in to tokenised line of length and line number
DFTK_LINLEN	=	0x00
DFTK_LINNUM	=	0x01

;* Flags for token, escape value for data types and line end
DFTK_TOKEN	=	0x80
DFTK_ESCVAL	=	0x20
DFTK_EOL	=	0x00

;* Numeric constants are encoded based on size and original
;* user representation.
;* For example the decimal value 16 will be encoded as
;* DFTK_INTDEC followed by the bytes 0 and 16 to form the word
;* The same value in binary will be encoded as DFTK_INTBIN
;* followed by the same 0 and 16 bytes.  This is to allow the
;* tokenised value to be displayed in original representation.
;* So in the two examples, they will be shown as '16' and
;* '0x0010' respectively.
DFTK_CHR	=	0x00
DFTK_RESV1	=	0x01
DFTK_RESV2	=	0x02
DFTK_RESV3	=	0x03
DFTK_RESV4	=	0x04
DFTK_BYTDEC	=	0x05
DFTK_BYTHEX = 	0x06
DFTK_BYTBIN =	0x07
DFTK_RESV8	=	0x08
DFTK_INTDEC	=	0x09
DFTK_INTHEX =	0x0a
DFTK_INTBIN	=	0x0b
DFTK_RESVC	=	0x0c
DFTK_RESVD	=	0x0d
DFTK_RESVE	=	0x0e
DFTK_RESVF	=	0x0f

;* String constant, variable and procedure tokens
DFTK_STRLIT	=	0x10
DFTK_VAR	=	0x11
DFTK_PROC	=	0x12
DFTK_STEND	=	0x1f

;* Qualifier for non-local parameters passed to a proc
DFTK_VARPARM=	'&'

;* Variable Value Table (VVT) definitions
;* The VVT records the values of variables defined in
;* the Variable Name Table (VNT).  When a variable is
;* used, it is added to the VNT, and the position in
;* VNT is used as an index in to the VVT.
;* Every VVT entry is 8 bytes - so the VNT index is
;* shifted left 3 bits to get the VVT offset.
;* The VNT grows from top of memory down, the VVT
;* grows from start of VNT down.

;* Index in to each entry of the VVT
DFVVT_TYPE	=	0x00
DFVVT_LO	=	0x01
DFVVT_HI	=	0x02
DFVVT_DIM1	=	0x03
DFVVT_DIM2	=	0x04
DFVVT_SZ	=	0x08	;VVT is aligned to 8 byte blocks

;* The meaning of the DFVVT_TYPE entry
DFVVT_INT	=	0x01
DFVVT_BYT	=	0x02
DFVVT_STR	=	0x04
DFVVT_FLT	=	0x08
DFVVT_PROC	=	0x40
DFVVT_ARRY	=	0x80

;* Flags indicating the meaning of a token
;* A token has the top bit set (0x80), then the
;* remaining bits indicate what it represents.
DFTK_KW		=	0x01
DFTK_FN		=	0x02
DFTK_STROP	=	0x04
DFTK_OP		=	0x08
DFTK_INT	=	0x10
DFTK_BYT	=	0x20
DFTK_STR	=	0x40
DFTK_FLT	=	0x80
DFTK_OPMSK	=	0x07
DFTK_RTMSK	= 	0xf8

;* Defines what type of value is on the parameter stack
;* All numerics are stored as INT, all STR
;* are pointers to the actual string, thus
;* all entries in the parmeter stack are 3 bytes
DFST_INT	=	0x01
DFST_STR	=	0x80

;* Token values of specific commands, used during
;* command processing.
;* ANY CHANGE TO THE ORDER OF KEYWORDS NEEDS TO REFLECT HERE!
DFRT_DEF	=	0x85
DFRT_ENDDEF	=	0x86
DFRT_RETURN	=	0x87
DFRT_REPEAT	=	0x8a
DFRT_FOR	=	0x8c
DFRT_NEXT	=	0x8d
DFRT_WHILE	=	0x8e
DFRT_WEND	=	0x8f
DFRT_IF		=	0x90
DFRT_ELSE	=	0x91
DFRT_ENDIF	=	0x92
DFRT_ELSEIF	=	0x93
DFRT_DATA	=	0x94
