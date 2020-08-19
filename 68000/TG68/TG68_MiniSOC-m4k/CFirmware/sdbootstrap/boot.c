
#include "textbuffer.h"

char sector_buf[512];

int volstart;

int FindVolume(int drive)
{
	volstart=0;
	spi_read_sector(buf,volstart);
	if((_buf[0x1fe]!=0x55) || (_buf[0x1ff]!=0xaa))
	{
		puts("Bad signature");
		return(0);
	}
	if((drive&0x70)==0x40) // Superfloppy
	{

	}
}

_FindVolume:
		moveq		#0,d0	;partitionstable
		move.l		d0,_volstart
		bsr			cmd_read_sector
		bne.s 		_error

		cmpi.b		#$55,$1fe(a0)
		bne.s		_error
		cmpi.b		#$AA,$1ff(a0)
		bne.s		_error
			
		move.w		_drive,d0
		and.w		#$70,d0
		cmp.w		#$40,d0
		bcc.s		_testfat	;Superfloppy
	
		lea			$1be(a0),a1		; pointer to partition table
		adda.w		d0,a1
		
		move.l		8(a1),d0	;LBA
		ror.w		#8,d0
		swap		d0
		ror.w		#8,d0
		move.l		d0,_volstart
		bsr			cmd_read_sector	; read sector 
		bne.s		_error
		cmpi.b		#$55,$1fe(a0)
		bne.s		_error
		cmpi.b		#$AA,$1ff(a0)
		beq.s		_testfat
_error:
		moveq		#-1,d0
		rts


_testfat:
		cmpi.l		#$46415431,$36(a0)	;"FAT1"
		bne.s		_testfat_2
		move.b		#12,_fstype
		cmpi.l		#$32202020,$3A(a0)	;"2   "
		beq.s		_testfat_ex
		move.b		#16,_fstype
		cmpi.l		#$36202020,$3A(a0)	;"6   "
		beq.s		_testfat_ex
_testfat_2:
		move.b		#$00,_fstype
		cmpi.l		#$46415433,$52(a0)	;"FAT3"
		bne.s		_error
		cmpi.l		#$32202020,$56(a0)	;"2   "
		bne.s		_error
		move.b		#32,_fstype
_testfat_ex:
		move.l		$0a(a0),d0	; make sure sector size is 512
		and.l		#$FFFF00,d0
		cmpi.l		#$00200,d0
		bne		_error
		
		move.l		_volstart,d1
		move.w		$e(a0),d0		;reserved Sectors
		ror.w		#8,d0
		add.l		d0,d1
		move.l		d1,_fatstart			;Fat Table
		cmpi.b		#32,_fstype
		bne.s		 _fat16
		
;@fat32:
		move.l		$2c(a0),d0	; cluster of root directory
		ror.w		#8,d0
		swap		d0
		ror.w		#8,d0
		move.l		d0,_rootcluster
; find start of clusters
		move.l		$24(a0),d0	;FAT Size
		ror.w		#8,d0
		swap		d0
		ror.w		#8,d0
_add_start32		
		add.l		d0,d1
		subq.b		#1,$10(a0)
		bne.s		_add_start32
		bra.s		subcluster
		
_fat16
			moveq		#0,d0
			move.l		d0,_rootcluster
			move.w		$16(a0),d0				;Sectors per Fat
			ror.w		#8,d0
root_sect	add.l		d0,d1
			sub.b		#1,16(a0)			;number of FAT Copies
			bne			root_sect
			move.l		d1,_rootsector
	move.l	d1,d0		
			move.b		$12(a0),d0
			lsl.w		#8,d0
			move.b		$11(a0),d0
			move.w		d0,_rootdirentrys
			lsr.w		#4,d0
			add.l		d0,d1
subcluster:	
			moveq		#0,d0
			move.b		$d(a0),d0
			move.w		d0,_clustersize
			sub.l		d0,d1					; subtract two clusters to compensate
			sub.l		d0,d1					; for reserved values 0 and 1
			move.l		d1,_datastart			;start of clusters
			
fat_ex:
			moveq		#0,d0
			rts


fat_cdroot:
			move.l		_rootcluster,d0	; cluster of basic directory
			move.l		d0,_cluster	
			bne.s		 cdfat_32
		
			clr.l		_cluster
			move.w		_rootdirentrys,d0
			lsr.w			#4,d0
			move.w		d0,_sectorcnt
			move.l		_rootsector,d0
			move.l		d0,_sectorlba		;lba
			rts

cluster2lba:		
			move.l		_cluster,d0
cdfat_32:	
			move.w		_clustersize,d1
			move.w		d1,_sectorcnt
_fat32_1:		
			lsr.w			#1,d1
			bcs.s		_fat32_2
			lsl.l		#1,d0
			bra.s		_fat32_1
_fat32_2:
			add.l		_datastart,d0
			move.l		d0,_sectorlba	
			rts


		
fat_findfile
		movem.l		d2/a2,-(a7)
		move.l		a1,a2
fat_findfile_m4

		bsr			cmd_read_sector	; read sector 
		bne		fat_findfile_m8
			moveq		#15,d2
fat_findfile_m3
			tst.b	(a0)		;end
			beq.s		fat_findfile_m8
			moveq		#10,d0
fat_findfile_m2			
			move.b		(a2,d0),d1
			cmp.b		(a0,d0),d1
			beq			fat_findfile_m1
			add.b		#$20,d1		;
			cmp.b		(a0,d0),d1
			bne			fat_findfile_m9
fat_findfile_m1	
			dbra		d0,fat_findfile_m2

			moveq	#0,d0
			move.b	11(a0),d0
			move.w	d0,_attrib
			cmpi.b		#32,_fstype
			bne.s		 sfs_m3
			move.w	20(a0),d0		;high cluster
			ror.w	#8,d0
			swap	d0
sfs_m3:		move.w	26(a0),d0		;high cluster
			ror.w	#8,d0
			move.l	d0,_cluster
		movem.l		(a7)+,d2/a2
			moveq	#-1,d0
			rts


fat_findfile_m9
			adda		#$0020,a0
			dbra		d2,fat_findfile_m3		
			
			move.l 		_sectorlba,d0	
			addq.l		#1,d0		 
			move.l 		d0,_sectorlba			 

			subi.w		#1,_sectorcnt
			bne 		fat_findfile_m4
			bsr			next_cluster
			beq.s		fat_findfile_m8
			bsr			cluster2lba		
			bra			fat_findfile_m4
fat_findfile_m8			
		movem.l		(a7)+,d2/a2
			moveq		#0,d0			;file not found
			rts



_LoadFile:
;			move.l 		4(a7),a0	;Loadaddr
			
_LoadFile2:
			bsr			cluster2lba
_LoadFile1:	
			lea _secbuf,a0
			bsr			cmd_read_block
			bne.s		lferror
			
			move.l	#$200,d7
			movem.l	d0/a0,-(a7)
			move.b	(a0)+,d0
			bsr	HandleByte
			movem.l	(a7)+,d0/a0
			
			move.l 		_sectorlba,d0	
			addq.l		#1,d0		 
			move.l 		d0,_sectorlba			 

			subi.w		#1,_sectorcnt
			bne 		_LoadFile1
			bsr			next_cluster
			bne			_LoadFile2
			move.l		a0,d0
			rts
lferror:	moveq		#0,d0		
			rts
			
			
next_cluster:
		cmpi.b		#32,_fstype
		beq.s		 fnc_m32
		cmpi.b		#12,_fstype
		beq.s		 fnc_m12

;FAT16
		move.l    	_cluster,D0
		lsr.l     	#8,D0
		add.l		_fatstart,D0
		bsr			cmd_read_sector	; read sector 
		bne.s		fnc_end
		move.b    	_cluster+3,D0
		add.w		d0,d0
		move.w		(a0,d0),d0
		ror.w		#8,d0
		move.l    	D0,_cluster
		or.l		#$ffff000f,d0
		cmp.w		#$ffff,d0
		rts
fnc_m32:	
;FAT32
		move.l    	_cluster,D0
		lsr.l     	#7,D0
		add.l		_fatstart,D0
		bsr			cmd_read_sector	; read sector 
		bne.s		fnc_end
		move.b    	_cluster+3,D0
		and.w		#$7f,d0
		add.w		d0,d0
		add.w		d0,d0
		move.l		(a0,d0),d0
		ror.w		#8,d0
		swap		d0
		ror.w		#8,d0
		move.l    	D0,_cluster
		or.l		#$f0000007,d0
		cmp.l		#$ffffffff,d0
		rts
fnc_end:
		moveq		#0,d0
		rts
		

fnc_m12:	
;FAT12
		move.l		d2,-(a7)
		move.l    	_cluster,D0	;cluster
		move.l		d0,d1
		add.l		d0,d0
		add.l		d1,d0		;*3
		move.l		d0,d1		;nibbles
		lsr.l     	#8,D0		
		lsr.l     	#2,D0		;cluster*1.5/256
		add.l		_fatstart,D0
		move.l		d0,d2
		bsr			cmd_read_sector	; read sector 
		bne.s		fnc_end2
		move.l		d1,d0
		lsr.l		#1,d0
		and.w		#$1ff,d0
		cmp			#$1ff,d0
		bne			fnc_m14
		
		move.b		(a0,d0),d0
		exg.l		d0,d2
		addq.l		#1,d0
		bsr			cmd_read_sector	; read sector 
		bne.s		fnc_end2
		lsl			#8,d2
		move.b		(a0),d2
		bra.s		fnc_m15
		
fnc_m14:		
		move.b		(a0,d0),d2
		lsl			#8,d2
		move.b		1(a0,d0.w),d2
fnc_m15:
		rol.w		#8,d2
		and.w			#1,d1
		beq.s		fnc_m13
		lsr			#4,d2
fnc_m13:
		and.l		#$FFF,d2
		move.l    	D2,_cluster
		or.l		#$fffff00f,d2
		move.l		d2,d0

		move.l		(a7)+,d2
		cmp.w		#$ffff,d0
		rts

fnc_end2:
		move.l		(a7)+,d2
		moveq		#0,d0
		rts

