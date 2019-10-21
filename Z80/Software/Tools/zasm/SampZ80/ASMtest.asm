	Z80
	PreDef	Math
	MacLib	CPM22
	Entry	0x100
	Include CPM22.ASI	
	Globals
gExitMsg	db	'Thank you,	Goodbye',cr,lf,'$'
gWelcomeMsg	db	'Welcome String',cr,lf,'$'
gPiSP	i3es_le	PI	;Single precision Pi in little-endian
gPiDP	i3ed_be	PI	;Double precision Pi in big-endian
	Stack	020h
	Startup
	Print	gWelcomeMsg
	Print$	<'This is a message\r\n'>
	Print	gExitMsg
	Exit
	end	~Entry		;set entry point
