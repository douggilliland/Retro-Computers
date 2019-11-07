	ORG 100h
	LD DE,2000h	; move code above ROM space
	LD HL,reset
	LD BC,5h
	LDIR
	JP 2000h	; jump to reset
reset:	OUT (39h),A	; page in ROM
	JP 0000h	; run ROM
	END
