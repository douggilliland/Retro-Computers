*   load_tbl.s
*
*   Copyright 1987, 1992 by Sierra Systems.  All rights reserved.

*------------------------------ LOAD TABLE FORMAT ---------------------------*

* The load table resides in the .ld_tbl section and it contains the information
* necessary to fill BSS type sections and copy data from one address to a
* second address at run-time.
*
* The load table begins with the label __load_tbl and has the following format:
*
* fill_value  base_address  byte_count (each member is a long, total 12 bytes)
*		   .
*		   .
* fill_value  base_address  byte_count
*
*      0	   0		0      (fill terminator)
*
* load_addr  run_time_addr  byte_count (each member is a long, total 12 bytes)
*		   .
*		   .
* load_addr  run_time_addr  byte_count
*
*      0	   0		0	(copy terminator)

*------------------------------ load_tbl() ----------------------------------*

* load_tbl fills bss sections and copies sections from their load address to
* their run-time (org or virtual) address

 .ifdef M68020
HIGH_END = 0
 .else
 .ifdef M68040
HIGH_END = 0
 .else
 .ifdef M68332
HIGH_END = 0
 .endif
 .endif
 .endif

    .opt    proc=68020

 .ifdef PC_REL
    .opt    pcf
 .endif

 .ifdef HIGH_END
    .opt    fr32
 .else
    .opt    fr16
 .endif

    .text
    .align  2

    .globl  load_tbl

load_tbl:
;   move.l  d2,-(sp)
    lea	    __load_tbl,a1	; move address of load table into a1
    bsr.w   fill_bss		; fill bss sections
    bsr.w   cpy_sects		; copy sections from load addr to run-time addr
;   move.l  (sp)+,d2
    rts
    
*------------------------------- fill_bss() ---------------------------------*

* fill_bss fills bss sections with there initilization value
*
* arguments: a1 is the address of the load table and it is left pointing to
* just past the end of the load table on return
*
* the load table is an array of structures with an element for each each bss
* section
*
* each structure in the table has the form:
* { fill_value	base_address  byte_count } where each member is a long
* and the byte_count is a multiple of 4

fill_bss:
f_tbl_loop:			; loop on table entries
    move.l  (a1)+,d0		; fill value
    move.l  (a1)+,a0		; run-time address of bss
 .ifdef A5_16
    adda.l  a5,a0		; if a5 relative, offset by value in a5
 .endif
 .ifdef A5_32
    adda.l  a5,a0		; if a5 relative, offset by value in a5
 .endif
    move.l  (a1)+,d1		; length of bss in bytes
    bne.s   fill
    rts				; quit if byte count is 0
    
* set d2 = byte_cnt % 32
* set d1 = byte_cnt - d2

fill:
    move.l  d1,d2
    andi.l  #0x1f,d2		; d2 is now byte_cnt % 32
    sub.l   d2,d1		; d1 is remainder
    asr.w   #2,d2		; d2 is now number of longs
    bra.s   f_short_test

f_short_loop:			; loop until byte cnt is multiple of 8
    move.l  d0,(a0)+		; stuff a long
f_short_test:
    dbf	    d2,f_short_loop	; loop

    add.l   a0,d1		; d1 is now ending adr
    bra.s   f_long_test
f_long_loop:			; stuffs 8 longs at a time
    move.l  d0,(a0)+
    move.l  d0,(a0)+
    move.l  d0,(a0)+
    move.l  d0,(a0)+
    move.l  d0,(a0)+
    move.l  d0,(a0)+
    move.l  d0,(a0)+
    move.l  d0,(a0)+
f_long_test:
    cmp.l   a0,d1		; reached end address?
    bhi.s   f_long_loop		; no -> loop
    bra.s   f_tbl_loop		; process next table entry

*--------------------------------- cpy_sects --------------------------------*

* cpy_sects copies sections from their load address to their run-time address
*
* arguments: a1 is the address of the copy table (2nd half of load table)
*
* the copy table is an array of structures with an element for each section
* that must be copied over at run-time
*
* each structure in the table has the form:
* { load_address  run_time_address  byte_count } where each member is a long
* and the byte_count is a multiple of 4

cpy_sects:
c_tbl_loop:			; loop on table entries
 .ifdef PC_REL
    add.l   (a1)+,a2		; copy from address -- set a2 prior to load_tbl
 .else
    move.l  (a1)+,a2		; copy from address
 .endif
    move.l  (a1)+,a0		; run-time address
 .ifdef A5_16
    adda.l  a5,a0		; if a5 relative, offset by value in a5
 .endif
 .ifdef A5_32
    adda.l  a5,a0		; if a5 relative, offset by value in a5
 .endif
    move.l  (a1)+,d1		; number of bytes to copy
    bne.s   copy
    rts				; quit if byte count is 0
    
* set d2 = byte_cnt % 32
* set d1 = byte_cnt - d2

copy:
    move.l  d1,d2
    andi.l  #0x1f,d2		; d2 is now byte_cnt % 32
    sub.l   d2,d1		; d1 is remainder
    asr.w   #2,d2		; d2 is now number of longs
    bra.s   c_short_test

c_short_loop:			; loop until byte cnt is multiple of 8
    move.l  (a2)+,(a0)+		; copy a long
c_short_test:
    dbf	    d2,c_short_loop	; loop

    add.l   a0,d1		; d1 is now ending adr
    bra.s   c_long_test
c_long_loop:			; copy 8 longs at a time
    move.l  (a2)+,(a0)+
    move.l  (a2)+,(a0)+
    move.l  (a2)+,(a0)+
    move.l  (a2)+,(a0)+
    move.l  (a2)+,(a0)+
    move.l  (a2)+,(a0)+
    move.l  (a2)+,(a0)+
    move.l  (a2)+,(a0)+
c_long_test:
    cmp.l   a0,d1		; reached end address?
    bhi.s   c_long_loop		; no -> loop
    bra.s   c_tbl_loop		; process next table entry
