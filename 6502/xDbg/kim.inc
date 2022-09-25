;=====================================================
; Common KIM addresses and constants
;
;=====================================================
; Hardware
;
SAD		equ	$1740
PADD		equ	$1741
SBD		equ	$1742
PBDD		equ	$1743
CLK1T		equ	$1744
CLK8T		equ	$1745
CLK64T		equ	$1746
CLKKT		equ	$1747
CLKRD1		equ	$1747
CLKRDT		equ	$1746
;
;=====================================================
; Zero page RAM
;
PCL		equ	$00ef
PCH		equ	$00f0
PREG		equ	$00f1
SPUSER		equ	$00f2
ACC		equ	$00f3
YREG		equ	$00f4
XREG		equ	$00f5
CHKHI		equ	$00f6
CHKSUM		equ	$00f7
INL		equ	$00f8
INH		equ	$00f9
POINTL		equ	$00fa
POINTH		equ	$00fb
TEMP		equ	$00fc
TMPX		equ	$00fd
CHAR		equ	$00fe
MODE		equ	$00ff
;
;=====================================================
; High RAM located in the 6530s
;
CHKL		equ	$17e7
CHKH		equ	$17e8
SAVX		equ	$17e9
VEB		equ	$17ec
CNTL30		equ	$17f2
CNTH30		equ	$17f3
TIMH		equ	$17f4
SAL		equ	$17f5
SAH		equ	$17f6
EAL		equ	$17f7
EAH		equ	$17f8
ID		equ	$17f9
NMIV		equ	$17fa
RSTV		equ	$17fc
IRQV		equ	$17fe
;
;=====================================================
; Subroutines
;
PRTPNT		equ	$1e1e	;print POINT
CRLF		equ	$1e2f	;print CR/LF
OUTSP		equ	$1e9e	;print a space
INCPT		equ	$1f63	;inc POINTL/POINTH

