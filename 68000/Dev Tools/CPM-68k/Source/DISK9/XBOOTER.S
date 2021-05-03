***************************************
*  Information to go on the 256 byte  *
*    boot sector of an ExorMacs	      *
***************************************

	.text
	.dc.l	$4000		* starting stack pointer
	.dc.l	start		* starting program counter
	.dc.w	1		* garbage
	.dc.w	1		* length of SAT
	.dc.l	2		* secondary directory start
	.dc.l	0		* primary directory PSN list start
	.dc.l	0		* start of boot loader
	.dc.w	26		* length of boot loader
	.dc.l	$0		* boot execution address
	.dc.l	$0		* boot load address
	.dc.b	'9/30'		* generation date
	.dc.b	'CP/M-68K of 9/30/82 '  * volume descriptor
	.dc.b	'0020'		* version/revision
	.dc.w	$0a484		* checksum (god help us)
	.dc.l	$0f1e2d3c	* diagnostic test pattern
	.dc.l	$4b5a6978
	.dc.l	$8796a5b4
	.dc.l	$c3d2e1f0
	.dc.l	$0f1e2d3c	* diagnostic test pattern
	.dc.l	$4b5a6978
	.dc.l	$8796a5b4
	.dc.l	$c3d2e1f0
	.dc.l	$4f8f0f07	* diagnostic test pattern
	.dc.l	$0b0d0e06
	.dc.l	$0a0c0408
	.dc.l	$04020100
	.dc.l	00, 00, 00, 00	* diagnostic test pattern
	.dc.l	0		* diagnostic test area directory
	.dc.l	0		* start of dump area
	.dc.w	0		* length of dump area
	.dc.l	0		* start of sector lockout table
	.dc.w	0		* length of sector lockout table
	.dc.l	0,0,0,0,0,0,0	* unused, reserved
	.dc.l	0,0,0,0,0,0
	.dc.l	0,0,0,0,0,0,0
	.dc.l	0,0,0,0,0,0
	.dc.b	'EXORMACS'	* let's hear it for Motorola
*
*	end of volume id
*
*	begin boot info proper
*
	.ds.b	$300		* skip over exception vectors
	.even
start:	move	#$2700,sr
	move.l	#$8,a0
	move.w	#253,d0
exlp:	move.l	#expdef,(a0)+
	dbf	d0,exlp
	jmp	grunt
expdef:	rte
grunt:	move	#$2000,sr
	.end
ve.l	#$8,a0
	move.w	#2