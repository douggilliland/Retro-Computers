;WARNING - this code is not debugged
; IT MAY NOT RUN CORRECTLY
;(just for testing the Assembler in pseudo real world situation)
	Z80
	PreDef	Math
	MacLib	CPM22test
	Entry	0x100
	Include CPM22.ASI	
	Globals
g16bit	dw	0xa5a5
g8bit	db	0xE5
gPiSP	i3es_le	PI	;Single precision Pi in little-endian
gPiDP	i3ed_be	PI	;Double precision Pi in big-endian
gExitMsg	db	'Thank you,	Goodbye',cr,lf,'$'
gWelcomeMsg	db	'Welcome String\r\n$'
;	Stack	0400h
	Startup
	Print	gWelcomeMsg
	Print$	<'This is a message',cr,lf>
;Function Function1(P16bit as integer,byval PStack as integer,byval P8bit as byte)as integer
; g8bit=Function1(g16bit,gStack,g8bit)
	SetReturnSize	2
	lda	g8bit
	PassByVal	A	;parameter 3
	lbcd	gStack
	PassByVal	BC	;parameter 2
	lxi	hl,g16bit
	PassByRef	HL	;parameter 1
	Call	Function1
	RemovePassed
	GetReturn	A	;get 8 bit return value in A
	sta	g8bit
	;GetReturn	BC	;optionally a 16 bit value
	;RemoveReturn	;  or just thow returned value away

	Print	gExitMsg
	Exit
Function1
	SetParameterSize	6
	LinkIX	-4	;4 bytes of local storage
;local storage accessed by IX - 1 to -4
;parameter 3 is at IX +8
;parameter 2 is at IX +6
;parameter 1 is at IX +4

;next six are just for fun
	GetByVal	BC,2	;bc = value of PStack
	GetByRef	DE,1	;de = value pointed to by P16bit	
	PtrToByVal	HL,3	;hl -> P8bit
	ptrToByVal	DE,2	;de -> PStack
	PtrToByRef	BC,1	;bc = P16bit -> g16bit
	PutByRef	hl,1

;P16bit=PStack
	PtrToByRef	de,1	;de = P16bit -> g16bit
	ptrToByVal	hl,2	;hl -> PStack
	lxi	bc,2
	ldir
;P16bit=PStack (another possibility)
	mov	l,4(ix)	;hl = P16bit -> g16bit
	mov	h,5(ix)
	mov	a,6(ix)	
	mov	m,a
	inx	hl
	mov	a,7(ix)
	mov	m,a
;localx=PStack
	PtrToByVal	hl,2	;hl=points to PStack
	mov	a,(hl)
	mov	-2(ix),a
	inx	hl
	mov	a,(hl)
	mov	-1(ix),a
;localx=PStack(another possibility)
	GetByVal	bc,2
	PutLocal	bc,1
;PStack=localx
	GetLocal	bc,1
	PutByVal	bc,2
;P16bit=localx
	GetLocal	bc,1
	PutByRef	bc,1
;Function1=P8bit or Return(P8bit)
	GetByVal	A,3	;a= P8bit passed by value
	PutReturn	A
;	PutReturn	BC	;COULD RETURN 16 BIT VALUE
	UnlkIX	
	ret
	end	~Entry		;set entry point
