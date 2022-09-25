;***************************************************
; FILE: sbug.inc
;
; A header file with SBUG data.
;


;
	bss
	org	$f800	;start of SBUG
;
MONITOR	ds	2
NEXTCMD	ds	2
INCH	ds	2
INCHE	ds	2
INCHEK	ds	2
OUTCH	ds	2
PDATA	ds	2
PCRLF	ds	2
PSTRNG	ds	2
LRA	ds	2
;
; These are additional vectors to useful functions within
; SBUG that other programs can use.
;
OUT1S	ds	2	;output a space
OUT2HEX	ds	2	;output A as 2 hex characters
OUT4HEX	ds	2	;output X as 4 hex characters
GET2HEX	ds	2	;input 2 hex digits, return in A
GET4HEX	ds	2	;input 4 hex digits, return in X
