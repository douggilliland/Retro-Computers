;*********************************************************
; FILE: config.inc
;
; General configuration file for the Corsham Technologies
; CTMON65 monitor.
;*********************************************************
;
; Current version and revision
;
VERSION		equ	0
REVISION	equ	1
;
;FALSE		equ	0
;TRUE		equ	!FALSE
;
; SS-50 bus constants
;
IO_BASE		equ	$e000
IO_SIZE		equ	16
;
; Memory usage
;
ZERO_PAGE_START	equ	$00f0
ROM_START	equ	$f000
RAM_START	equ	$df00
;
; If enabled, turn on buffered input code.
;
BUFFERED_INPUT	equ	FALSE
;
MAX_ARGC	equ	5
;
; If enabled, the debugger will display the flag register
; in ASCII.  Nice, but takes more code.
;
FULL_STATUS	equ	TRUE
;
; Enable EXTENDED_CMDS to allow linking external commands
; to the command handler.
;
EXTENDED_CMDS	equ	FALSE
;
; Define to enable SD related functions
;
SD_ENABLED	equ	TRUE
;
; Size of the keyboard buffer
;
BUFFER_SIZE	equ	132

