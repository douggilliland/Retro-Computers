;
;	Save and restore the 32bit working register to a workspace
;

	.export saveeax
	.export resteax

	.setcpu 6803
	.code

saveeax:
	std @regsave
	ldd @sreg
	std @regsaveh
	rts
resteax:
	ldd @regsaveh
	std @sreg
	ldd @regsave
	rts

	.zp

regsave:
	.word 0
regsaveh:
	.word 0
