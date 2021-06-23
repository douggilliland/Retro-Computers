
		.export _errno
		.export erroutb
		.export erroutbff
		.export fcb_to_errno
		.export fms_and_errno

		.data

_errno:	.word 0

		.code

;
;	Set errno to B return 0
;
erroutb:
		stab _errno+1
		clra
		staa _errno
		clrb
		rts
;
;	Ditto return -1
;
erroutbff:
		stab _errno+1
		clra
		staa _errno
		deca
		tab
		rts

;
;	Load errno from the FCB at X
;
fcb_to_errno:
		ldab 1,x		; 	error code
		beq noerr
		stx @tmp
		ldx #errtab
		jsr $AD36		;	add B to X
		ldab ,x
		stab errno+1
		clr errno
		ldx @tmp
noerr:
		rts

;
;	Do an FMS call on the FCB at X, if there is an error then set the
;	error code and return -1 if not return 0
;
fms_and_errno:
		jsr $BE06
		bne waserr
		clra
		clrb
		rts
waserr:
		bsr fcb_to_errno
		ldab #$FF
		tba
		rts

