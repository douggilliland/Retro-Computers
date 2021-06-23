;
;	We don't have a 16bit right arithmetic shift but we do have an
;	8bit one so this is not too hard. Smaller shifts are inlined, bigger
;	ones are done by byte shifting first
;
	.export asrax7
	.export asrax6
	.export asrax5
	.export asrax4
	.export asrax3
	.export asrax2

	.code
asrax7:
	asra
	rorb
asrax6:
	asra
	rorb
asrax5:
	asra
	rorb
asrax4:
	asra
	rorb
asrax3:
	asra
	rorb
asrax2:
	asra
	rorb
	asra
	rorb
	rts

