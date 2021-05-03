*	@(#)booter.s	1.6		*
**************************************
*  Information to go on track 0 and  *
*     start of boot of a VME/10      *
**************************************

	.text
first:	.dc.l	'CP/M'		* volume identifier
	.dc.l	0		* user number
	.dc.w	1		* garbage
	.dc.w	1		* length of SAT
	.dc.l	2		* secondary directory start
	.dc.l	0		* primary directory PSN list start
	.dc.l	8		* start of boot loader
	.dc.w	32		* length of boot loader
	.dc.l	$0		* boot execution address
	.dc.l	$1300		* boot load address
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
	.dc.l	$f1f2f4f8	* diagnostic test pattern
	.dc.l	$f9fafcfe
	.dc.l	$ff7fbfdf
	.dc.l	$ef6fafcf
	.dc.l	$4f8f0f07	* diagnostic test pattern
	.dc.l	$0b0d0e06
	.dc.l	$0a0c0408
	.dc.l	$04020100
	.dc.l	0		* diagnostic test area directory
	.dc.l	0		* start of dump area
	.dc.w	0		* length of dump area
	.dc.l	0		* start of sector lockout table
	.dc.w	0		* length of sector lockout table
	.dc.l	1		* configuration parameters sector
	.dc.b	1		* length of config area (sectors)
	.dc.b	0,0,0		* unused reserved
	.dc.l	0,0,0,0,0	* unused, reserved
	.dc.l	0,0,0,0,0,0
	.dc.l	0,0,0,0,0,0,0
	.dc.l	0,0,0,0,0,0
	.dc.b	'EXORMACS'	* let's hear it for Motorola
*
*	end of volume id
*
*	begin configuration area
*
	.dc.l	0,0		* reserved
	.dc.w	$0f		* attributes word
	.dc.w	0		* reserved
	.dc.l	0,0,0
	.dc.b	8		* sectors per track on disk
	.dc.b	2		* sides on disk
	.dc.w	80		* cylinders on disk
	.dc.w	0		* reserved
*
* WARNING: the following word is modified by
* putboot for the hard disk.  It must remain
* at this offset.
*
	.dc.w	512		* sector size
	.dc.l	0		* reserved
	.dc.w	40		* precompensation cylinder
	.dc.l	0		* reserved
*
*	end configuration area
*
	.ds.b	$800-(*-first)	* skip rest of first track
*
*	begin boot info proper
*
	.globl	_bootdsk
	.even
	.dc.l	$4000		* stack pointer
	.dc.l	start		* program counter
start:	move	#$2700,sr
	move.w	d0,_bootdsk
	and.b	#$fc,$f19f05
	move.b	#$10,$f19f09
	clr.b	$f19f0b
	move.b	#$80,$f19f11
	.end
:	move	#$2700,sr
	move.w	d0,_bootdsk
	and.b