;
;	Shift the 32bit primary left 1-4 bits
;

	.export shleax1
	.export shleax2
	.export shleax3
	.export shleax4
	.export asleax1
	.export asleax2
	.export asleax3
	.export asleax4

	.setcpu 6803
	.code

shleax4:
asleax4:
	lsld
	rol @sreg+1
	rol @sreg
shleax3:
asleax3:
	lsld
	rol @sreg+1
	rol @sreg
shleax2:
asleax2:
	lsld
	rol @sreg+1
	rol @sreg
shleax1:
asleax1:
	lsld
	rol @sreg+1
	rol @sreg
	rts

