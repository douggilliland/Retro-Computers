;
;		File open. Rather limited by FMS
;
		.export _fopen
		.code
_fopen:
		ldab #<322
		ldaa #>322
		jsr __malloc
		staa @tmp
		orab @tmp
		beq nospace
		stab @tmp+1	; @tmp is the struct
		tsx
		ldx 4,x
		jsr parsename	; parse name into fcb at @tmp + 2
		beq badname
		tsx
		ldx 2,x
		ldab ,x
		cmpb #'r'
		beq open_read
		cmpb #'w'
		beq open_write
badname:
		ldab #22		; EINVAL
		jmp erroutb
nospace:	ldab #12		; ENOMEM
		jmp erroutb

open_read:
		ldab 1,x
		beq do_read
		cmpb #'a'
		beq do_read
		cmpb #'b'
		bne badname
		ldab #$FF		; no space compression
do_read:
		ldaa #$01		; read open
do_open:
		pshb
		ldx @tmp
		inx
		inx			; FCB
		clr 1,x
		staa ,x			; command mode
		jsr $BE06
		bne pulopenfail
		pulb
		stab 59,x		; binary/ascii set
		ldab @tmp+1
		ldaa @tmp
		rts			; return the handle
pulopenfail:	pulb
openfail:
		jsr fcb_to_errno
		clra			; NULL return
		clrb
opendone:
		rts
open_write:
		ldab 1,x
		beq write_ascii
		cmpb #'a'
		beq write_ascii
		cmpb #'b'
		bne badname
		ldab #$FF
write_ascii:
		ldaa #$02		; open for write
		jsr do_open
		tsta
		bne opendone
		tstb
		bne opendone
		; The open for write failed
		ldab 1,x		; X is pointing at the FMS right now
		cmpb #3			; exists
		bne openfail
		; ok delete and retry
		ldab #12
		jsr $BE06
		bne openfail		; Couldn't delete it (eg protected)
		; we deleted it, and it went away
		tsx
		ldx 2,x
		bra open_write		; try again
