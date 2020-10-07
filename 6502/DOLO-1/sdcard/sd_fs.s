;**********************************************************
;*
;*	DOLO-1 HOMEBREW COMPUTER
;*	Hardware and software design by Dolo Miah
;*	Copyright 2014-18
;*  Free to use for any non-commercial purpose subject to
;*  full credit of original my authorship please!
;*
;*  SD_FS.S
;*  FAT16 filesystem module.  Implements a basic FAT16
;*  filesystem to enable mass storage support.
;*  I've been a bit naughty in that I have assumed a 1GB
;*  sd card size and sector 0 is the MBR.  This is not
;*  always the case, but it works for me so I couldn't at
;*  the time be asked to sort it out. I may fix this for
;*  more general use at some point..
;*  The filesystem doesn't support sub directories and
;*  implements the folling:
;*  - load a file
;*  - save a file
;*  - delete a file from the card
;*  - perform a directory listing
;*  I have to say I am pretty pleased with this, took a lot
;*  of reading and research!
;*
;**********************************************************


	; ROM code
	code

;****************************************
;* init_fs
;* Initialise filesystem - after sd card!
;* Input : None
;* Output : None
;* Regs affected : None
;****************************************
init_fs
	_println msg_initialising_fs

	ldx #0x03					; Init sector to 0
init_fs_clr_sect
	stz sd_sect,x
	dex
	bpl init_fs_clr_sect

	lda #hi(sd_buf)				; Read in to the buffer
	jsr sd_sendcmd17			; Call read block

	;Extract data from boot record
	ldx #0x03					; Assuming boot sector 0
init_fs_clr_boot
	stz fs_bootsect,x
	dex
	bpl init_fs_clr_boot

	; Calculate start of FAT tables
	; Assumeing there are about 64k clusters
	; Each cluster assumed to be 32k sectors
	; Giving 64k x 32k x 0.5 ~ 1GB storage
	clc
	lda fs_bootsect
	adc sd_buf+MBR_ResvSect
	sta fs_fatsect
	lda fs_bootsect+1
	adc sd_buf+MBR_ResvSect+1
	sta fs_fatsect+1
	stz fs_fatsect+2
	stz fs_fatsect+3
	
	; Calculate start of Root Directory
	lda sd_buf+MBR_SectPerFAT	; Initialise to 1 * SectPerFAT
	sta fs_rootsect
	lda sd_buf+MBR_SectPerFAT+1
	sta fs_rootsect+1
	clc							; Add again = *2
	lda sd_buf+MBR_SectPerFAT
	adc fs_rootsect
	sta fs_rootsect
	lda sd_buf+MBR_SectPerFAT+1
	adc fs_rootsect+1
	sta fs_rootsect+1
	stz fs_rootsect+2
	stz fs_rootsect+3

	; Now add FAT offset
	clc
	ldx #0x00
	ldy #0x04
fs_init_add_fat
	lda fs_fatsect,x
	adc fs_rootsect,x
	sta fs_rootsect,x
	inx
	dey
	bne fs_init_add_fat
	
	; Calculate start of data area
	; Assuming 512 root dir entries!
	lda #1						; 512/512 = 1
	sta fs_datasect
	stz fs_datasect+1
	stz fs_datasect+2
	stz fs_datasect+3
	
	ldy #5						; Multiply by 32 to get root dir size in sectors
fs_rootmult1
	clc
	asl fs_datasect
	rol fs_datasect+1
	rol fs_datasect+2
	rol fs_datasect+3
	dey
	bne fs_rootmult1

	; Now add root directory offset
	clc
	ldx #0x00
	ldy #0x04
fs_init_data
	lda fs_rootsect,x
	adc fs_datasect,x
	sta fs_datasect,x
	inx
	dey
	bne fs_init_data

	sec							; Now subtract 2 clusters worth of sector
	lda fs_datasect+0			; to enable easy use of clusters in main
	sbc #0x40					; FS handling routines
	sta fs_datasect+0			; Each cluster = 32 sectors
	lda fs_datasect+1			; Therefore take off 0x40 sectors from datasect
	sbc #0
	sta fs_datasect+1
	lda fs_datasect+2
	sbc #0
	sta fs_datasect+2
	lda fs_datasect+3
	sbc #0
	sta fs_datasect+3

	; Current directory = root dir
	ldx #0x03
fs_init_dir_sect
	lda fs_rootsect,x
	sta fs_dirsect,x
	dex
	bpl fs_init_dir_sect
	
	rts

;****************************************
;* fs_getbyte_sd_buf
;* Given a populated SD buffer, get byte
;* Indexed by X,Y (X=lo,Y=hi) 
;* Input : X,Y make 9 bit index
;* Output : A=Byte
;* Regs affected : None
;****************************************
fs_getbyte_sd_buf
	tya
	and #1
	bne fs_getbyte_sd_buf_hi
	lda sd_buf,x
	rts
fs_getbyte_sd_buf_hi
	lda sd_buf+0x100,x
	rts

;****************************************
;* fs_putbyte_sd_buf
;* Given a populated SD buffer, put byte
;* Indexed by X,Y (X=lo,Y=hi), A=Val 
;* Input : X,Y make 9 bit index, A=byte
;* Output : None
;* Regs affected : None
;****************************************
fs_putbyte_sd_buf
	pha
	tya
	and #1
	bne fs_putbyte_sd_buf_hi
	pla
	sta sd_buf,x
	rts
fs_putbyte_sd_buf_hi
	pla
	sta sd_buf+0x100,x
	rts

;****************************************
;* fs_getword_sd_buf
;* Given a populated SD buffer, get word
;* Indexed by Y which is word aligned 
;* Input : Y=Word offset in to sd_buf
;* Output : X,A=Word
;* Regs affected : None
;****************************************
fs_getword_sd_buf
	tya
	asl a
	tax
	bcs fs_getword_sd_buf_hi
	lda sd_buf,x
	pha
	lda sd_buf+1,x
	plx
	rts
fs_getword_sd_buf_hi
	lda sd_buf+0x100,x
	pha
	lda sd_buf+0x100+1,x
	plx
	rts

;****************************************
;* fs_putword_sd_buf
;* Given a populated SD buffer, put word
;* Indexed by Y which is word aligned 
;* Input : Y=Word offset in to sd_buf
;* Output : X,A=Word
;* Regs affected : None
;****************************************
fs_putword_sd_buf
	phy
	pha
	phx
	tya
	asl a
	tay
	bcs fs_putword_sd_buf_hi
	pla
	tax
	sta sd_buf,y
	pla
	sta sd_buf+1,y
	ply
	rts
fs_putword_sd_buf_hi
	pla
	tax
	sta sd_buf+0x100,y
	pla
	sta sd_buf+0x100+1,y
	ply
	rts


;****************************************
;* fs_dir_root_start
;* Initialise ready to read root directory
;* Input : dirsect is current directory pointer
;* Output : None
;* Regs affected : None
;****************************************
fs_dir_root_start
	pha
	phx

	; Set SD sector to root directory
	ldx #0x03
fs_dir_set_sd
	lda fs_dirsect,x
	sta sd_sect,x
	dex
	bpl fs_dir_set_sd

	; SD buffer is where blocks will be read to
	stz sd_slo
	lda #hi(sd_buf)
	sta sd_shi

	; Load up first sector in to SD buf
	lda #hi(sd_buf)
	jsr sd_sendcmd17

	plx
	pla
	rts

;****************************************
;* fs_dir_find_entry
;* Read directory entry
;* Input : sd_slo, sd_shi : Pointer to directory entry in SD buffer
;* Input : C = 0 only find active files.  C = 1 find first available slot
;* Output : None
;* Regs affected : None
;****************************************
fs_dir_find_entry
	pha
	phx
	phy
	php							; Save C state for checking later
fs_dir_check_entry
	; Not LFN aware
	ldy #FAT_Attr				; Check attribute
	lda #0x5e					; Any of H, S, V, D, I then skip
	and (sd_slo),y
	bne fs_dir_invalid_entry
	ldy #FAT_Name				; Examine 1st byte of name
	lda (sd_slo),y
	plp							; Check C
	php
	bcc	fs_find_active_slot		; Looking to find an active file
	cmp #0						; Else looking for 0 or 0xe5
	beq fs_dir_found_entry
	cmp #0xe5
	beq fs_dir_found_entry
	bra fs_dir_invalid_entry	; Else not an entry we're interested in
fs_find_active_slot
	cmp #0
	beq fs_dir_done				; If zero then no more entries
	cmp #0xe5					; Deleted entry?
	bne fs_dir_found_entry
fs_dir_invalid_entry
	jsr fs_dir_next_entry		; Advance read for next iteration
	bra fs_dir_check_entry

	; Found a valid entry or finished
fs_dir_done						; No more entries
	plp							; Remove temp P from stack
	sec							; Set carry to indicate no more
	bra fs_dir_fin
fs_dir_found_entry
	plp							; Remove temp P from stack
	jsr fs_dir_copy_entry		; Copy the important entry details
	jsr fs_dir_next_entry		; Advance read for next iteration
	clc							; Clear carry to indicate found
fs_dir_fin						; Finalise
	ply
	plx
	pla
	rts
	
;****************************************
;* fs_dir_next_entry
;* Jump to next directory entry (32 bytes)
;* Load next sector if required
;* Input : sd_slo, sd_shi : Pointer to directory entry in SD buffer
;* Output : None
;* Regs affected : None
;****************************************
fs_dir_next_entry
	pha
	phx
	phy
	
	clc							; Jump to next 32 byte entry
	lda sd_slo					; Update sd_slo, sd_shi
	adc #32
	sta sd_slo
	lda sd_shi
	adc #0
	sta sd_shi
	cmp #5						; If not at end of sector (page 5)
	bne fs_dir_next_done		; then don't load next sector

	; Advance the sector
	ldx #0x00
	ldy #0x04
	sec
fs_dir_inc_sect
	lda sd_sect,x
	adc #0
	sta sd_sect,x
	inx
	dey
	bne fs_dir_inc_sect
	
	; Reset SD buffer  where blocks will be read to
	stz sd_slo
	lda #hi(sd_buf)
	sta sd_shi

	lda #hi(sd_buf)				; Goes in to sd_buf
	jsr sd_sendcmd17			; Load it

fs_dir_next_done
	ply
	plx
	pla
	rts
	

;****************************************
;* fs_dir_copy_entry
;* Copy directory entry
;* Input : sd_slo, sd_shi : Pointer to directory entry in SD buffer
;* Input : C = 0 for an active entry (copy loaded directory info)
;* Input : C = 1 for an empty entry (don't copy size, filename etc)
;* Output : None
;* Regs affected : None
;****************************************
fs_dir_copy_entry
	pha
	phx
	phy
	bcs fs_dir_empty_slot		; If an empty slot, then most info not relevant

	;Normal processing of an entry loaded from the directory
	ldx #FH_Name				; Point to where name will go
	ldy #FAT_Name
fs_dir_get_name_ch
	lda (sd_slo),y				; Get name char
	cmp #' '					; Don't copy space
	beq	fs_dir_skip_name_ch
	cpy #FAT_Ext				; At extension?
	bne fs_dir_skip_ext_ch
	pha							; Save A
	lda #'.'					; Inject '.'
	sta fh_dir,x				; Copy byte
	pla							; Restore A
	inx							; Advance
fs_dir_skip_ext_ch
	sta fh_dir,x				; Copy byte
	inx							; Advance
fs_dir_skip_name_ch
	iny							; Next SD dir entry
	cpy #FAT_Attr				; Passed end of name?
	bne fs_dir_get_name_ch	
fs_dir_entry_pad_name
	cpx #FH_Size				; End of FH name space?
	beq fs_dir_entry_size		; Yes, then copy size
	stz fh_dir,x				; Else put 0
	inx
	bra fs_dir_entry_pad_name

fs_dir_entry_size
	ldx #FH_Size				; Point to where size will go
	ldy #FAT_FileSize			; Point to get size from
	jsr fs_dir_util_copy		; Copy 4 bytes
	jsr fs_dir_util_copy
	jsr fs_dir_util_copy
	jsr fs_dir_util_copy
	
fs_dir_entry_attr
	ldx #FH_Attr				; Point to where attributes go
	ldy #FAT_Attr				; Point from where to get attributes
	jsr fs_dir_util_copy		; Copy 1 byte

fs_dir_entry_clust
	ldx #FH_FirstClust
	ldy	#FAT_FirstClust
	jsr fs_dir_util_copy		; Copy 2 bytes
	jsr fs_dir_util_copy

	; Empty slot data goes here
fs_dir_empty_slot
fs_dir_entry_dirsect			; Directory sector in which FH entry belongs
	ldx #0x03
fs_dir_copy_sd_sect
	lda sd_sect,x
	sta fh_dir+FH_DirSect,x
	dex
	bpl fs_dir_copy_sd_sect
	
fs_dir_entry_diroffset			; Offset in to directory sector of FH entry
	lda sd_slo
	sta fh_dir+FH_DirOffset
	lda sd_shi
	sta fh_dir+FH_DirOffset+1
	
	ply
	plx
	pla
	
	rts
	

;****************************************
;* fs_dir_util_copy
;* Copy SD bytes to directory entry area
;* Input 	: y = offset in to sd directory
;*		 	: x = offset in to dir entry
;* Output 	: None
;* Regs affected : All
;****************************************
fs_dir_util_copy
	pha
	lda (sd_slo),y
	sta fh_dir,x
	iny
	inx
	pla
	rts



;****************************************
;* fs_get_next_cluster
;* Given current cluster, find the next
;* Input : fh_handle
;* Output : 
;* Regs affected : None
;****************************************
fs_get_next_cluster
	pha
	phx
	phy

	; Get the FAT sector that current clust is in
	jsr fs_get_FAT_clust_sect

	; Get next from this cluster index need low byte only
	; as each FAT cluster contains 256 cluster entries
	ldy fh_handle+FH_CurrClust
	; X = Low byte, A = High byte of cluster
	jsr fs_getword_sd_buf
	; Make this the current cluster
	stx fh_handle+FH_CurrClust
	sta fh_handle+FH_CurrClust+1
	
	; Calculate the sector address
	jsr fs_get_start_sect_data
	lda #0x20					; 32 sector per cluster countdown			
	sta fh_handle+FH_SectCounter

	ply
	plx
	pla
	rts
	
;****************************************
;* fs_IsEOF
;* End of File check (compare file pointer to file size)
;* Input : fh_handle
;* Output : 
;* Regs affected : None
;****************************************
fs_isEOF
	pha
	phx
	
	ldx #0x03
fs_is_eof_cmp
	lda fh_handle+FH_Pointer,x
	cmp fh_handle+FH_Size,x
	bne fs_notEOF
	dex
	bpl fs_is_eof_cmp

	plx
	pla
	sec							; C = 1 for EOF
	rts

fs_notEOF	
	plx
	pla
	clc							; C = 0 for not EOF
	rts

	
;****************************************
;* fs_inc_pointer
;* Increment file point, loading sectors and clusters as appropriate
;* This results in sd_buf containing the sector that the pointer points to
;* Input : fh_handle
;* Output : 
;* Regs affected : None
;****************************************
fs_inc_pointer
	pha
	phx
	phy
	
	;Increment pointer
	ldx #0x00
	ldy #0x04
	sec									; Always adds 1 first
fs_inc_fh_pointer
	lda fh_handle+FH_Pointer,x
	adc #0x00
	sta fh_handle+FH_Pointer,x
	inx
	dey
	bne fs_inc_fh_pointer

	lda fh_handle+FH_Pointer			; If low order == 0
	beq fs_inc_sector_ov				; Then sector 8 bits has overflowed
fs_inc_fin
	ply
	plx
	pla
	
	rts
fs_inc_sector_ov						; Check if sector bit 8 has overflowed
	lda fh_handle+FH_Pointer+1			; Load up next highest byte
	and #1								; If bit zero = 0 then must have
	bne fs_inc_fin						; overflowed.
	;Sector change required
	ldx #0x00
	ldy #0x04
	sec									; Always adds 1 first
fs_inc_fh_sect
	lda fh_handle+FH_CurrSec,x
	adc #0x00
	sta fh_handle+FH_CurrSec,x
	inx
	dey
	bne fs_inc_fh_sect
fs_inc_skip_sec_wrap
	dec fh_handle+FH_SectCounter		; If reached the end of a cluster
	bne fs_inc_load_sector				; Then get next cluster
	; Cluster change required
	jsr fs_get_next_cluster				; Get next cluster based on current	
	jsr fs_load_curr_sect				; Load it
fs_inc_load_sector
	jsr fs_isEOF						; Check not EOF
	bcs fs_skip_load_sect				; if so then don't load sector
	jsr fs_load_curr_sect				; Load the sector
fs_skip_load_sect
	ply
	plx
	pla
	rts


	
;****************************************
;* fs_get_next_byte
;* Get a byte
;* Input : fh_handle
;* Output : A = char, C = 1 (EOF)
;* Regs affected : None
;****************************************
fs_get_next_byte
	phx
	phy

	jsr fs_isEOF						; If at EOF then error
	bcc fs_get_skip_EOF

	lda #FS_ERR_EOF
	sta errno
	sec
	ply
	plx
	rts

fs_get_skip_EOF
	ldx fh_handle+FH_Pointer			; Low 8 bits of sector index
	ldy fh_handle+FH_Pointer+1			; Which half of sector?
	; A=SD buffer byte
	jsr fs_getbyte_sd_buf
	jsr fs_inc_pointer					; Increment file pointers

	clc									; No error
	stz errno
	ply
	plx
	rts
	


;****************************************
; Find the sector given the data cluster
; Given clust in LoX,HiA
; Outputs to fh_handle->FH_CurrSec
;****************************************
fs_get_start_sect_data
	pha
	phx
	phy
	
	stx fh_handle+FH_CurrClust
	sta fh_handle+FH_CurrClust+1
	
	; Initialise to input sector
	stx fh_handle+FH_CurrSec+0
	sta fh_handle+FH_CurrSec+1
	stz fh_handle+FH_CurrSec+2
	stz fh_handle+FH_CurrSec+3
	
	; Sector = Cluster * 32
	; Shift left 5 times
	ldy #5
fs_get_data_sect_m5
	clc
	asl fh_handle+FH_CurrSec+0
	rol fh_handle+FH_CurrSec+1
	rol fh_handle+FH_CurrSec+2
	rol fh_handle+FH_CurrSec+3
	dey
	bne fs_get_data_sect_m5

	; Add data sector offset
	ldx #0x00
	ldy #0x04
	clc
fs_get_start_data
	lda fh_handle+FH_CurrSec,x
	adc fs_datasect,x
	sta fh_handle+FH_CurrSec,x
	inx
	dey
	bne fs_get_start_data

	ply
	plx
	pla
	rts
	
;****************************************
; Load the current sector in FH
;****************************************
fs_load_curr_sect
	pha
	phx

	ldx #0x03
fs_load_cpy_sect
	lda fh_handle+FH_CurrSec,x
	sta sd_sect,x
	dex
	bpl fs_load_cpy_sect
	lda #hi(sd_buf)
	jsr sd_sendcmd17

	plx
	pla
	rts

;****************************************
; Flush the current sector
;****************************************
fs_flush_curr_sect
	pha
	phx

	ldx #0x03
fs_flush_cpy_sect
	lda fh_handle+FH_CurrSec,x
	sta sd_sect,x
	dex
	bpl fs_flush_cpy_sect
	lda #hi(sd_buf)				; Sending data in sd_buf
	jsr sd_sendcmd24
	
	plx
	pla
	rts


;****************************************
;* fs_copy_dir_to_fh
;* Copy directory entry (fh) to file handle
;* Input : fh_dir contains directory entry
;* Output : None
;* Regs affected : None
;****************************************
fs_copy_dir_to_fh
	pha
	phx
	ldx #FH_Name			; By default copy all
	bcc fs_copy_dir_to_fh_byte
	ldx #FH_Size			; But skip name if new file
fs_copy_dir_to_fh_byte
	lda fh_dir,x
	sta fh_handle,x
	inx
	cpx #FileHandle
	bne fs_copy_dir_to_fh_byte
	plx
	pla
	rts

;****************************************
;* fs_find_empty_clust
;* Find an empty cluster to write to
;* Input : None
;* Output : fh_handle->FH_CurrClust is the empty cluster
;* Regs affected : None
;****************************************
fs_find_empty_clust
	pha
	phx
	phy

	; Starting at cluster 0x0002
	lda #02
	sta fh_handle+FH_CurrClust
	stz fh_handle+FH_CurrClust+1

	
	; Start at the first FAT sector
	ldx #0x03
fs_find_init_fat
	lda fs_fatsect,x
	sta fh_handle+FH_CurrSec,x
	dex
	bpl fs_find_init_fat

	; There is only enough room for 512/2 = 256 cluster entries per sector
	; There are 256 sectors of FAT entries

fs_check_empty_sector
	jsr fs_load_curr_sect			; Load a FAT sector
fs_check_curr_clust
	ldy fh_handle+FH_CurrClust		; Index in to this FAT sector
	jsr fs_getword_sd_buf
	cpx #0
	bne fs_next_fat_entry
	cmp #0
	bne fs_next_fat_entry
	
	; If got here then empty cluster found
	; fh_handle->FH_CurrClust is the empty cluster
	
	; Mark this cluster as used
	ldx #0xff
	lda #0xff
	jsr fs_putword_sd_buf

	; flush this FAT entry back so this cluster is safe from reuse
	jsr fs_flush_curr_sect
	
	stz fh_handle+FH_SectCounter	; Zero the sector count
	ldx fh_handle+FH_CurrClust
	lda fh_handle+FH_CurrClust+1
	jsr fs_get_start_sect_data		; Initialise the sector
	ply
	plx
	pla
	rts
	; If got here then need to find another cluster
fs_next_fat_entry
	_incZPWord fh_handle+FH_CurrClust	; Increment the cluster number
	; Only 256 FAT entries in a sector of 512 bytes
	lda fh_handle+FH_CurrClust		; Check low byte of cluster number
	bne fs_check_curr_clust			; Else keep checking clusters in this sector
	; Every 256 FAT entries, need to get a new FAT sector
fs_next_fat_sect
	jsr fs_inc_curr_sec				; Increment to the next FAT sector
	bra fs_check_empty_sector		; Go an load the new FAT sector and continue
	

;****************************************
;* fs_inc_curr_sec
;* Increment sector by 1
;* Input : fh_handle has the sector
;****************************************
fs_inc_curr_sec
	pha
	phx
	phy
	
	; add 1 to LSB as sector address is little endian
	ldx #0x00
	ldy #0x04
	sec
fs_inc_sec_byte
	lda fh_handle+FH_CurrSec,x
	adc #0x00
	sta fh_handle+FH_CurrSec,x
	inx
	dey
	bne fs_inc_sec_byte

	ply
	plx
	pla
	rts
	

;****************************************
;* fs_get_FAT_clust_sect
;* Given FH_CurrClust, set FH_CurrSec so that
;* the sector contains the FAT entry
;* Input : fh_handle has the details
;* Output : None
;* Regs affected : None
;****************************************
fs_get_FAT_clust_sect
	pha
	phx
	phy
	
	; Sector offset in to FAT = high byte
	; because a sector can hold 256 FAT entries
	lda fh_handle+FH_CurrClust+1
	sta fh_handle+FH_CurrSec
	stz fh_handle+FH_CurrSec+1
	stz fh_handle+FH_CurrSec+2
	stz fh_handle+FH_CurrSec+3
	
	; Add the FAT offset
	clc
	ldx #0x00
	ldy #0x04
fs_get_add_fat
	lda fh_handle+FH_CurrSec,x
	adc fs_fatsect,x
	sta fh_handle+FH_CurrSec,x
	inx
	dey
	bne fs_get_add_fat

	; Now load the sector containing this cluster entry
	jsr fs_load_curr_sect

	ply
	plx
	pla
	rts
	
;****************************************
;* fs_update_FAT_entry
;* FH_LastClust updated with FH_CurrClust
;* Input : fh_handle has the details
;* Output : None
;* Regs affected : None
;****************************************
fs_update_FAT_entry
	pha
	phx
	phy
	
	lda fh_handle+FH_CurrClust+0	; Save current cluster lo byte
	pha
	lda fh_handle+FH_CurrClust+1	; Save current cluster hi byte
	pha
	; Move back to the last cluster entry
	_cpyZPWord fh_handle+FH_LastClust,fh_handle+FH_CurrClust

	jsr fs_get_FAT_clust_sect		; Get the FAT sector to update
	; Index in to the FAT sector
	ldy fh_handle+FH_LastClust
	; Get current cluster hi,lo from stack
	pla
	plx
	; Update FAT entry Y with cluster X,A
	jsr fs_putword_sd_buf

	; The appropriate FAT sector has been updated
	; Now flush that sector back	
	jsr fs_flush_curr_sect
	
	; And restore the current cluster
	stx fh_handle+FH_CurrClust		; Make it the current cluster again
	sta fh_handle+FH_CurrClust+1	; Make it the current cluster again
	
	ply
	plx
	pla
	rts
	

;****************************************
;* fs_put_byte
;* Put out a byte, incrementing size
;* and committing clusters as necessary
;* including reflecting this in the FAT table
;* Input : fh_handle has the details, A = Byte to write
;* Output : None
;* Regs affected : None
;****************************************
fs_put_byte
	phx
	phy
	pha

	; Before writing a byte, need to check if the current
	; sector is full.
	; Check low 9 bits of size and if zero size (i.e. 1st byte being put)
	lda fh_handle+FH_Size
	bne fs_put_do_put
	lda fh_handle+FH_Size+1
	beq fs_put_do_put
	and #1
	bne fs_put_do_put

	; We need to flush this sector to disk
	jsr fs_flush_curr_sect
	; Move to next sector in the cluster
	jsr fs_inc_curr_sec
	; Bump the sector counter
	inc fh_handle+FH_SectCounter
	; Check if counter at sectors per cluster limit
	lda fh_handle+FH_SectCounter
	cmp #0x20
	bne fs_put_do_put
	; We need to find a new cluster now
	; But first update the FAT chain
	; so that the last cluster points to this
	jsr fs_update_FAT_entry
	; Before finding a new cluster
	; make the current the last
	_cpyZPWord fh_handle+FH_CurrClust,fh_handle+FH_LastClust
	; Go find a new empty clust
	; starts at sector 0
	jsr fs_find_empty_clust
	; Finally, can write a byte to the
	; SD buffer in memory
fs_put_do_put	
	ldx fh_handle+FH_Size			; Load size low as index in to buffer
	ldy fh_handle+FH_Size+1			; Check which half
	pla								; Get A off stack and put back
	pha
	jsr fs_putbyte_sd_buf
fs_put_inc_size
	sec
	ldx #0x00
	ldy #0x04
fs_put_inc_size_byte
	lda fh_handle+FH_Size,x
	adc #0
	sta fh_handle+FH_Size,x
	inx
	dey
	bne fs_put_inc_size_byte
fs_put_fin
	pla
	ply
	plx
	rts

;****************************************
;* fs_dir_save_entry
;* Save dir entry back to disk
;* Input : fh_handle has all the details
;* Output : None
;* Regs affected : None
;****************************************
fs_dir_save_entry
	pha
	phx
	phy

	; Retrieve the sector where the file entry goes
	ldx #0x03
fs_dir_curr_sect
	lda fh_handle+FH_DirSect,x
	sta fh_handle+FH_CurrSec,x
	dex
	bpl fs_dir_curr_sect
	
	jsr fs_load_curr_sect

	; Restore index in to the correct entry
	lda fh_handle+FH_DirOffset
	sta sd_slo
	lda fh_handle+FH_DirOffset+1
	sta sd_shi
	
	;Save the filename
	ldx #FH_Name				; Point to where name will go
	ldy #FAT_Name
fs_dir_save_name_ch
	lda fh_handle,x				; Get a char
	beq fs_dir_name_done		; If zero then name done
	cmp #'.'					; Is it '.'
	bne fs_dir_name_skip		; If so then don't consider
	inx							; Jump over '.'
	bra fs_dir_name_done		; and start processing the ext
fs_dir_name_skip
	cpy #FAT_Ext				; Reached the end of the name?
	beq fs_dir_name_done
	sta (sd_slo),y				; No, so store the byte in name
	inx
	iny
	bra fs_dir_save_name_ch
fs_dir_name_done
	
	lda #' '					; Pad name with spaces
fs_dir_pad_name
	cpy #FAT_Ext				; Padded enough?
	beq fs_dir_pad_name_done
	sta (sd_slo),y				; Fill with space
	iny
	bra fs_dir_pad_name
fs_dir_pad_name_done
	
fs_dir_save_ext_ch
	cpy #FAT_Attr				; End of extension?
	beq fs_dir_ext_done
	lda fh_handle,x				; Get a char
	beq fs_dir_ext_done			; If zero then name done
	sta (sd_slo),y
	inx
	iny
	bra fs_dir_save_ext_ch	
fs_dir_ext_done
	
	lda #' '					; Pad out any remaining with space
fs_dir_ext_pad
	cpy #FAT_Attr				; Reached the end of the extension?
	beq fs_dir_ext_pad_done
	sta (sd_slo),y
	iny
	bra fs_dir_ext_pad
	; At the Attribute byte, zero out everything until size
fs_dir_ext_pad_done
	
	lda #0
fs_dir_save_rest_ch
	sta (sd_slo),y
	iny
	cpy #FAT_FirstClust
	bne fs_dir_save_rest_ch
	; Now save first cluster
	lda fh_handle+FH_FirstClust
	sta (sd_slo),y
	iny
	lda fh_handle+FH_FirstClust+1
	sta (sd_slo),y
	iny

	; Now save size
	ldx #0
df_dir_save_size_ch
	lda fh_handle+FH_Size,x
	sta (sd_slo),y
	iny
	inx
	cpx #4
	bne df_dir_save_size_ch

	; Ok done copying data to directory entry
	; Now flush this back to disk
	
	jsr fs_flush_curr_sect
	
	; Phew we are done
	ply
	plx
	pla
	rts
	
	
;****************************************
;* fs_open_read
;* Open a file for reading
;* Input : fh_handle has the name
;* Output : None
;* Regs affected : None
;****************************************
fs_open_read
	pha
	phx
	phy

	jsr fs_dir_root_start		; Start at root
fs_open_find
	clc							; Only look for active files
	jsr fs_dir_find_entry		; Find a valid entry
	bcs	fs_open_not_found		; If C then no more entries
	ldx #0						; Check name matches
fs_open_check_name
	lda fh_handle,x
	cmp fh_dir,x
	bne fs_open_find
	cmp #0						; If no more bytes in name to check
	beq fs_open_found
	inx
	bra fs_open_check_name
fs_open_found
	jsr fs_copy_dir_to_fh		; Put entry in to fh_handle

	lda #0x20					; 32 sector per cluster countdown			
	sta fh_handle+FH_SectCounter

	ldx fh_handle+FH_FirstClust	; Load up first cluster
	lda fh_handle+FH_FirstClust+1

	jsr fs_get_start_sect_data	; Calc the first sector
	jsr fs_load_curr_sect		; Load it in to sd_buf


	ldx #0x03					; Initialise pointer to beginning
fs_open_init_pointer
	stz fh_handle+FH_Pointer,x
	dex
	bpl fs_open_init_pointer

	; Set file mode to read
	lda #0x00
	sta fh_handle+FH_FileMode

	clc
fs_open_not_found
	ply
	plx
	pla
	rts


;****************************************
;* fs_open_write
;* Open a file for writing
;* Input : fh_handle has the name
;*		 : existing file will overwritten
;*		 : new file will be created
;* Output : None
;* Regs affected : None
;****************************************
fs_open_write
	pha
	phx
	phy

	; try and delete any file with the same name first
	lda fh_handle+FH_Name		; save first char as it gets deleted
	pha
	jsr fs_delete				; now delete it
	pla							; restore first char
	sta fh_handle+FH_Name
	jsr fs_dir_root_start		; Start at root
	sec							; Find an empty file entry
	jsr fs_dir_find_entry		; Find a valid entry
	bcs	fs_open_write_fin		; Error, didn't find!
	sec
	jsr fs_copy_dir_to_fh		; Copy entry to file handle

	stz fh_handle+FH_Size+0		; Size is zero initially
	stz fh_handle+FH_Size+1
	stz fh_handle+FH_Size+2
	stz fh_handle+FH_Size+3

	jsr fs_find_empty_clust		; Where will be the first cluster

	; Set current, last and first cluster
	lda fh_handle+FH_CurrClust
	sta fh_handle+FH_FirstClust
	sta fh_handle+FH_LastClust
	lda fh_handle+FH_CurrClust+1
	sta fh_handle+FH_FirstClust+1
	sta fh_handle+FH_LastClust+1

	; Set file mode to write
	lda #0xff
	sta fh_handle+FH_FileMode

	clc
fs_open_write_fin
	ply
	plx
	pla
	rts


;****************************************
;* fs_close
;* Close a file, only important for new files
;* Input : fh_handle details
;* Output : None
;* Regs affected : None
;****************************************
fs_close
	pha

	; Only need to close down stuff in write mode
	lda fh_handle+FH_FileMode
	beq fs_close_done
	
	; Flush the current sector
	jsr fs_flush_curr_sect

	; Update the chain from the last cluster
	jsr fs_update_FAT_entry

	; Make current sector = last
	lda fh_handle+FH_CurrClust
	sta fh_handle+FH_LastClust
	lda fh_handle+FH_CurrClust+1
	sta fh_handle+FH_LastClust+1
	; Need to update the FAT entry
	; to show this cluster is last
	lda #0xff
	sta fh_handle+FH_CurrClust
	sta fh_handle+FH_CurrClust+1
	; Now update the FAT entry to mark the last cluster

	jsr fs_update_FAT_entry

	jsr fs_dir_save_entry

fs_close_done
	pla
	rts

;****************************************
;* fs_delete
;* Delete a file
;* Input : fh_handle has the name
;* Output : None
;* Regs affected : None
;****************************************
fs_delete
	pha
	phx
	phy

	jsr fs_open_read			; Try and open the file
	bcs fs_delete_fin			; If not found then fin
	
	; Mark first char with deleted indicator
	lda #0xe5
	sta fh_handle+FH_Name

	; Save this back to directory table
	jsr fs_dir_save_entry

	; Now mark all related clusters as free
	ldx fh_handle+FH_FirstClust
	stx fh_handle+FH_CurrClust
	ldy fh_handle+FH_FirstClust+1
	sty fh_handle+FH_CurrClust+1
fs_delete_clust
	; X and Y always contain current cluster
	; Make last = current
	stx fh_handle+FH_LastClust
	sty fh_handle+FH_LastClust+1

	; Given current cluster, find next
	; save in X,Y
	jsr fs_get_next_cluster
	; load X,Y with the next cluster
	ldx fh_handle+FH_CurrClust
	ldy fh_handle+FH_CurrClust+1
	
	; Zero out the cluster number
	stz fh_handle+FH_CurrClust
	stz fh_handle+FH_CurrClust+1

	; Update FAT entry of Last Cluster with zero
	jsr fs_update_FAT_entry

	; Restore the next cluster found earlier
	stx fh_handle+FH_CurrClust
	sty fh_handle+FH_CurrClust+1

	; If the next cluster is not 0xffff
	; then continue
	cpx #0xff
	bne fs_delete_clust
	cpy #0xff
	bne fs_delete_clust
	clc
fs_delete_fin
	ply
	plx
	pla
	rts


	
msg_initialising_fs
	db "Initialising filesystem\r",0
fs_msg_directory_listing
	db "SD Card Directory\r",0
