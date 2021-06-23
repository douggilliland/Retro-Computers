;
;	On entry the command typed is in the line buffer. The line buffer
;	pointer points to the next argument
;
;	Turn this into a C style argc/argv.
;
;
start:		
		bra l1
		.byte 1
		;
		; Out of memory
		;
nofit:
		ldx #nomem
		jsr $AD1E
		jmp $AD03
l1:
		;
		;	See if we look like we fit. Allow 512 byts for args
		;	and stack minimum
		;
		ldab #<__bss
		addb #<__bss_size
		ldaa #>__bss
		adca #>__bss_size
		staa @tmp
		stab @tmp+1
	
		ldaa AC2B
		ldab AC2C
		subb @tmp+1
		sbca @tmp
		bcs nofit
		; Allow some stack space
		deca
		bcs nofit
		deca
		bcs nofit

		ldx #__bss
wipebss:	cpx @tmp
		beq wiped
		clr ,x
		inx
		bra wipebss

wiped:
		;
		; Runtime DP constants
		;
		clra
		staa @zero
		staa @zero+1
		inca
		staa @one+1

		; Memory layout
		ldaa AC2B
		ldab AC2C
		subb #$80		; 128 byte line copy
		sbca #$00
		staa @tmp
		stab @tmp+1
		ldx @tmp
		subb #$82		; 130 byte line arg worst case
		sbca #$00
		staa @tmp2
		stab @tmp2+1
		lds @tmp2

		clr @tmp1		; argc

		; We can't easily get argv[0] as it's been eaten by
		; the OS

		; Ideally we'd use nxtch but nxtch has very non C ideas!

		; tmp is our string copy buffer
		; tmp2 is our argv pointers
		; and stack sits just below that
		
		; Assign argv[0] to a constant string

		ldaa #>arg0
		ldaa #<arg0
		bsr storearg
		;
		; Start processing the next argument
		;
nextarg:
		ldx $AC14
		;
		; Skip spaces, terminate on end marker
		;
leadspace:
		ldab ,x
		cmpb #$0D
		beq done
		; FIXME - and check ttyset char
		inx
		cmpb #$20
		beq leadspace
		;
		; Set up the argument pointer as we found an argument
		;
		stx $AC14
		ldaa @tmp		; arg pointer
		ldab @tmp+1
		bsr storearg
		;
		;	Copy the argument
		;
copynext:
		stx $AC14
		ldx @tmp
		stab ,x
		inx
		stx @tmp
		ldx $AC14
		ldab ,x
		cmpb #$0D
		beq argend
		; FIXME - and check ttyset char
		cmpb #$20
		beq argend
		inx
		beq copynext
argend:
		;
		; End of string marker
		;
		ldx @tmp
		clr ,x
		inx
		stx @tmp
		;
		; Look for more
		;
		bra nextarg

storearg:
		ldx @tmp2
		staa ,x
		stab 1,x
		inx
		inx
		stx @tmp2
		inc @tmp1
		rts

		;
		; Now set up the C environment
		;
done:
		clra
		clrb
		bsr storearg
		dec @tmp1		; argc is the NULL marker arg
		sts @tmp		; S is balanced so is argv[0] ptr
		ldab @tmp1		; argc
		clra
		pshb
		psha
		ldaa @tmp
		ldab @tmp+1
		pshb
		psha
		jsr _main
		; if this returns it's an exit()
		pshb
		psha
		jsr _exit
		; Never returns


		.data

nomem:		.ascii 'NOT ENOUGH RAM'
		.byte 4
arg0:
		.ascii 'cmd'
		.byte 0
