#include "minisoc_hardware.h"
#include "textbuffer.h"

short SDHCtype=1;

// #define SPI_WAIT(x) while(HW_PER(PER_SPI_CS)&(1<<PER_SPI_BUSY));
// #define SPI(x) {while((HW_PER(PER_SPI_CS)&(1<<PER_SPI_BUSY))); HW_PER(PER_SPI)=(x);}
// #define SPI_READ(x) (HW_PER(PER_SPI)&255)

#define SPI_WAIT(x) ;
#define SPI(x) HW_PER(PER_SPI_BLOCKING)=(x)
#define SPI_PUMP(x) HW_PER(PER_SPI_PUMP)
#define SPI_PUMP_L(x) HW_PER_L(PER_SPI_PUMP)
#define SPI_READ(x) (HW_PER(PER_SPI_BLOCKING)&255)

#define SPI_CS(x) {while((HW_PER(PER_SPI_CS)&(1<<PER_SPI_BUSY))); HW_PER(PER_SPI_CS)=(x);}

#define cmd_reset(x) cmd_write(0x950040,0) // Use SPI mode
#define cmd_init(x) cmd_write(0xff0041,0)
#define cmd_read(x) cmd_write(0xff0051,x)

#define cmd_CMD8(x) cmd_write(0x870048,0x1AA)
#define cmd_CMD16(x) cmd_write(0xFF0050,x)
#define cmd_CMD41(x) cmd_write(0x870069,0x40000000)
#define cmd_CMD55(x) cmd_write(0xff0077,0)
#define cmd_CMD58(x) cmd_write(0xff007A,0)

#define printf

unsigned char SPI_R1[6];


short cmd_write(unsigned long cmd, unsigned long lba)
{
	int ctr;
	short result=0xff;

	SPI(cmd & 255);

	if(!SDHCtype)	// If normal SD then we have to use byte offset rather than LBA offset.
		lba<<=9;

	SPI((lba>>24)&255);
	SPI((lba>>16)&255);
	SPI((lba>>8)&255);
	SPI(lba&255);

	SPI((cmd>>16)&255); // CRC, if any

	ctr=1000;
	SPI_WAIT();
	result=SPI_READ();
	while(--ctr && (result==0xff))
	{
		SPI(0xff);
		SPI_WAIT();
		result=SPI_READ();
	}
	return(result);
}

void spi_spin()
{
//	puts("SPIspin\n");
	int i;
	for(i=0;i<200;++i)
		SPI(0xff);
//	puts("Done - waiting\n");
	SPI_WAIT();
//	puts("Done\n");
}

short wait_initV2()
{
	int i=20000;
	short r;
	spi_spin();
	while(--i)
	{
		if((r=cmd_CMD55())==1)
		{
			printf("CMD55 %x\n",r);
			SPI(0xff);
			if((r=cmd_CMD41())==0)
			{
				printf("CMD41 %x\n",r);
				SPI(0xff);
				return(1);
			}
			else
				printf("CMD41 %x\n",r);
			spi_spin();
		}
		else
			printf("CMD55 %x\n",r);
	}
	return(0);
}


short wait_init()
{
	int i=200;
	short r;
	SPI(0xff);
	puts("Cmd_init\n");
	while(--i)
	{
		if((r=cmd_init())==0)
		{
			printf("init %x\n  ",r);
			SPI(0xff);
			return(1);
		}
		else
			printf("init %x\n  ",r);
		spi_spin();
	}
	return(0);
}


short is_sdhc()
{
	int i,r;

	spi_spin();

	r=cmd_CMD8();		// test for SDHC capability
	printf("cmd_CMD8 response: %x\n",r);
	if(r!=1)
	{
		wait_init();
		return(0);
	}

	SPI(0xff);
	SPI_WAIT(); r=SPI_READ();
	printf("CMD8_1 response: %x\n",r);
	SPI(0xff);
	SPI_WAIT(); r=SPI_READ();
	printf("CMD8_2 response: %x\n",r);
	SPI(0xff);
	SPI_WAIT(); r=SPI_READ();
	if(r!=1)
	{
		wait_init();
		return(0);
	}

	printf("CMD8_3 response: %x\n",r);
	SPI(0xff);
	SPI_WAIT(); r=SPI_READ();
	if(r!=0xaa)
	{
		wait_init();
		return(0);
	}
	printf("CMD8_4 response: %x\n",r);

	SPI(0xff);

	// If we get this far we have a V2 card, which may or may not be SDHC...

	i=50;
	while(--i)
	{
		if(wait_initV2())
		{
			if((r=cmd_CMD58())==0)
			{
				printf("CMD58 %x\n  ",r);
				SPI(0xff);
				SPI_WAIT();
				r=SPI_READ();
				printf("CMD58_2 %x\n  ",r);
				SPI(0xff);
				SPI(0xff);
				SPI(0xff);
				SPI(0xff);
				if(r&0x40)
					return(1);
				else
					return(0);
			}
			else
				printf("CMD58 %x\n  ",r);
		}
		if(i==2)
		{
			puts("SDHC Initialization error!\n");
			return(0);
		}
	}

	return(0);
}


int spi_init()
{
	int i;
	int r;
	puts("In spi_init\n");
	SDHCtype=1;
	HW_PER(PER_TIMER_DIV7)=150;	// About 350KHz
	SPI_CS(0);	// Disable CS
	spi_spin();
	SPI_CS(1);
	i=50;
	puts("Initialising SD card\n");
	while(--i)
	{
		if(cmd_reset()==1) // Enable SPI mode
			i=1;
		if(i==2)
		{
			puts("SD card init error!\n");
			SPI_CS(0);	// Disable CS
			return(1);
		}
	}
	SDHCtype=is_sdhc();
	if(SDHCtype)
		puts("SDHC card detected\n");

	cmd_CMD16(1);
	SPI(0xFF);
	SPI_CS(0);

	HW_PER(PER_TIMER_DIV7)=1;	// Enable fast SPI
	return(0);
}


short sd_write_sector(unsigned long lba,unsigned char *buf) // FIXME - Stub
{
	return(0);
}


extern void spi_readsector(long *buf);


short sd_read_sector(unsigned long lba,unsigned char *buf)
{
	short result=0;
	int i;
	int r;
	SPI_CS(1);
	SPI(0xff);

	r=cmd_read(lba);
	if(r!=0)
	{
		printf("Read command failed at %ld (0x%x)\n",lba,r);
		return(result);
	}

	i=50000;
	while(--i)
	{
		short v;
		SPI(0xff);
		SPI_WAIT();
		v=SPI_READ();
		if(v==0xfe)
		{
			spi_readsector((long *)buf);
//			int j;
//			SPI_PUMP();
//			for(j=0;j<256;++j)
//			{
//				*(long *)buf=SPI_PUMP_L();
//				buf+=4;				
//			}
#if 0
			for(j=0;j<256;++j)
			{
				int t;
				SPI(0xff);
				SPI_WAIT();
				v=SPI_READ()&255;
				t=v<<8;

				SPI(0xff);
				SPI_WAIT();
				v=SPI_READ()&255;
				t|=v&255;

				*(short *)buf=t;
				buf+=2;
			}
			SPI(0xff); SPI(0xff); // Fetch CRC
			SPI(0xff); SPI(0xff);
#endif
			i=1; // break out of the loop
			result=1;
		}
	}
//	SPI(0xff);
	SPI_CS(0);
	return(result);
}


/*
; CSTART.ASM  -  C startup-code for SIM68K

lomem  equ       $0100             ; Lowest usable address
himem  equ       $1000           ; Highest memory addres + 1
RS232_base	            equ			$DA8000
SPIbase		equ			$DA4000
KEYbase		equ			$DE0000
_secbuf		equ			$1000

start:     
       move.w		 #$5555,_cachevalid
       jsr		spi_init
       bne.s     start2
       
	move.w		#$40,_drive	;Superfloppy
	bsr			_FindVolume		

       beq.s     start5

	clr.w		_drive		;1.Partition
	bsr			_FindVolume		
       bne.s     start3
       
start5
			bsr			fat_cdroot
			;d0 - LBA
			lea		mmio_name,a1
			bsr		fat_findfile
			beq.s     start3	
				
			lea		found_MM,a0
			bsr		put_msg
			move.l		#$2000,a0
			bsr		_LoadFile2
			beq.s     start4	
			jmp		$2000
start4     move.w  #$60fe,$2000
			jmp		$2000

start3			
			lea		notfound,a0
			bsr		put_msg
			
start2     bra.s     start2
notfound   dc.b "not "
found_MM   dc.b	"found "
;mmio_name:	dc.b	"MENUE   SYS",0
mmio_name:	dc.b	"OSD_CA01SYS",0

 
;***************************************************
; SPI 
;***************************************************


;***************************************************
; SPI Commands
;INPUT:   D0 - sector
;         (A0 - Inputbuffer)
;RETURN:  D0=0 => OK D0|=0 => fail
;         D1 - used
;         A0 - Inputbuffer Start
;         
;***************************************************
cmd_read_sector:
	; vor Einsprung A0 setzen
			lea			_secbuf,a0
				cmp 		#$AAAA,_cachevalid
				bne.s		read_sd11
				cmp.l		_cachelba,d0
				bne.s		read_sd11
				moveq		#0,d0						;OK
				rts
read_sd11:
				move.w		 #$AAAA,_cachevalid
				move.l		d0,_cachelba
cmd_read_block
			bsr		cmd_read
			bne		read_error3		;Error
read1
			move.w	#20000,d1		;Timeout counter
			move.b	#-1,(a1)		;8 Takte fürs Lesen
read2		subq.w	#1,d1
			beq		read_error2		;Timeout
read_w1		move.w	(a1),d0
			move.b	#-1,(a1)		;8 Takte fürs Lesen
			cmp.b	#$fe,d0
			bne		read2			;auf Start warten
			move.w	#511,d1
read_w2		move.w	(a1),d0
			move.b	#-1,(a1)		;8 Takte fürs Lesen
			move.b	d0,(a0)+
			dbra	d1,read_w2
;read_w3		move	(a1),d0
			move.b	#-1,(a1)		;8 Takte fürs Lesen CRC
			move.w	#3,4(a1)		;sd_cs high
			lea		-$200(a0),a0
			moveq	#0,d0
			rts
read_error2	
			move.w	#$5555,_cachevalid
			lea		msg_timeout_Error,a0
			bsr		put_msg
			moveq	#-2,d0
			rts		
read_error3	move.w	#$5555,_cachevalid
			lea		msg_cmdtimeout_Error,a0
			bsr		put_msg
			moveq	#-1,d0
			rts		

		

;******************************************************
; SPI Commands
; INPUT:   D0 - sector
; RETURN:  D0=$FF => Timeout D0|=$FF => Command Return
;          D1|=$00 => Timeout
;          A1 - SPIbase
;******************************************************
cmd_reset:	move.l	#$950040,d1
			moveq	#0,d0
			bra		cmd_wr
			
cmd_init:	move.l	#$ff0041,d1
			moveq	#0,d0
			bra		cmd_wr
			
cmd_CMD8:	move.l	#$870048,d1
			move.l	#$1AA,d0
			bra		cmd_wr
			
cmd_CMD41:	move.l	#$870069,d1
			move.l	#$40000000,d0
			bra		cmd_wr
			
cmd_CMD55:	move.l	#$ff0077,d1
			moveq	#0,d0
			bra		cmd_wr
			
cmd_CMD58:	move.l	#$ff007A,d1
			moveq	#0,d0
			bra		cmd_wr
	
cmd_read:	move.l	#$ff0051,d1

cmd_wr
			lea		SPIbase,a1
			move.b	#-1,(a1)	;8x clock
			move.w	#2,4(a1)	;sd_cs low
			move.b	d1,(a1)		;cmd
			swap	d1
			tst.w	SDHCtype
			beq		cmd_wr12	
			rol.l		#8,d0
			move.b	d0,(a1)		;31..24
			rol.l		#8,d0
			move.b	d0,(a1)		;23..16
			rol.l		#8,d0
			move.b	d0,(a1)		;15..8
			rol.l		#8,d0
			bra		cmd_wr13
			
cmd_wr12				
			add.l	d0,d0
			swap	d0
			move.b	d0,(a1)		;31..24
			swap	d0
			rol.w		#8,d0
			move.b	d0,(a1)		;23..16
			rol.w		#8,d0
			move.b	d0,(a1)		;15..8
			moveq	#0,d0
cmd_wr13	move.b	d0,(a1)		;7..0
			move.b	d1,(a1)		;crc
			move.l	#40000,d1	;Timeout counter
			
cmd_wr10	subq.l		#1,d1
			beq		cmd_wr11	;Timeout
			move.b	#-1,(a1)	;8 Takte fürs Lesen
cmd_wr9		move.w	(a1),d0
			cmp.b	#$ff,d0
			beq		cmd_wr10
cmd_wr11
			or.b	d0,d0
			rts					;If d0=$FF => Timeout 
								
calc_crc    add.b	d1,d1
			eor.b	d0,d1
			bpl		crc1a
			eor.b	#$9,d1
crc1a		eor.b	d0,d1
			add.b	d0,d0
			
			add.b	d1,d1
			eor.b	d0,d1
			bpl		crc2a
			eor.b	#$9,d1
crc2a		eor.b	d0,d1
			add.b	d0,d0			
			
			add.b	d1,d1
			eor.b	d0,d1
			bpl		crc3a
			eor.b	#$9,d1
crc3a		eor.b	d0,d1
			add.b	d0,d0			
			
			add.b	d1,d1
			eor.b	d0,d1
			bpl		crc4a
			eor.b	#$9,d1
crc4a		eor.b	d0,d1
			add.b	d0,d0			
			
			add.b	d1,d1
			eor.b	d0,d1
			bpl		crc5a
			eor.b	#$9,d1
crc5a		eor.b	d0,d1
			add.b	d0,d0			
			
			add.b	d1,d1
			eor.b	d0,d1
			bpl		crc6a
			eor.b	#$9,d1
crc6a		eor.b	d0,d1
			add.b	d0,d0			
			
			add.b	d1,d1
			eor.b	d0,d1
			bpl		crc7a
			eor.b	#$9,d1
crc7a		eor.b	d0,d1
			add.b	d0,d0			
			
			add.b	d1,d1
			eor.b	d0,d1
			bpl		crc8a
			eor.b	#$9,d1
crc8a		eor.b	d0,d1
			add.b	d0,d0	
			rts		

msg_start_init		dc.b	"Start Init"	,$d,$a,0
msg_init_done		dc.b	"Init done"	    ,$d,$a,0
msg_init_fail		dc.b	"Init failure"	    ,$d,$a,0
msg_reset_fail		dc.b	"Reset failure"	    ,$d,$a,0
msg_cmdtimeout_Error	dc.b	"Command Timeout_Error"	    ,$d,$a,0
msg_timeout_Error	dc.b	"Timeout_Error"	    ,$d,$a,0
msg_SDHC			dc.b	"SDHC found "	    ,$d,$a,0
			

		

;	A0	Stringpointer 
put_msg		;lea 		RS232_base,a1
put_msg1	move.b		(a0)+,d0
			beq			put_msg_end
			move.b		d0,RS232_base
			bra			put_msg1
put_msg_end	rts

put_msga7	move.l		a0,-(a7)
			move.l		8(a7),a0
put_msg2	tst.b		(a0)
			beq			put_msg3
			move.b		(a0)+,RS232_base
			bra			put_msg2
put_msg3	move.l		(a7)+,a0
			rts

;_secbuf  ds.b 512
		
cluster				ds.b	4	;$00		; 32-bit clusters
part_fat			ds.b	4	;$04		; 32-bit start of fat
part_rootdir		ds.b	4	;$08		; 32-bit root directory address
part_cstart			ds.b	4	;$0c		; 32-bit start of clusters
part_rootdirentrys	ds.b	2	;$10		; entris in root directory
vol_fstype			ds.b	2	;$12
vol_secperclus		ds.b	2	;$14
scount				ds.b	2	;$16		; number of sectors to read
dir_is_fat16root	ds.b	4	;$18		; marker for rootdir
sector_ptr			ds.b	4	;$1c
;dir_is_fat16root	equ	$20
lba					ds.b	4	;$24
spipass 			ds.b	2	;$10000
SDHCtype			ds.b	2	

_cachevalid			ds.w	1
_cachelba			ds.l	1
_drive				ds.w	1
_fstype				ds.w	1
_rootcluster		ds.l	1
_rootsector			ds.l	1
_cluster			ds.l	1
_sectorcnt			ds.w	1
_sectorlba			ds.l	1
_attrib				ds.w	1

_volstart			ds.l	1	;start LBA of Volume
_fatstart			ds.l	1	;start LBA of first FAT table
;_dirstart			ds.l	1	;start LBA of directory table
_datastart			ds.l	1	;start LBA of data field
_clustersize		ds.w	1	;size of a cluster in blocks
_rootdirentrys		ds.w	1	;number of entry's in directory table


		

;unsigned char _FindVolume(void)
_FindVolume:

;@checktype:
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
		
;_foundfat:
;read_vol_sector	
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

;@next:
;test floppy format CF	

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
			subi.b		#1,$10(a0);d2			;number of FAT Copies
			bne			root_sect
			move.l		d1,_rootsector
	move.l	d1,d0		
;	bsr debug_hex			
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
;file found	
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
			
;fat_read_next_sector:
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
			move.l 		4(a7),a0	;Loadaddr
			
_LoadFile2:
			bsr			cluster2lba
_LoadFile1:	
			bsr			cmd_read_block
			bne.s		lferror
			
;fat_read_next_sector:
			adda.l		#$200,a0
			move.l 		_sectorlba,d0	
			addq.l		#1,d0		 
			move.l 		d0,_sectorlba			 

			subi.w		#1,_sectorcnt
			bne 		_LoadFile1
			move.l		a0,-(a7)
			bsr			next_cluster
			move.l		(a7)+,a0
			bne			_LoadFile2
;			moveq		#0,d0
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
;		bsr			_read_secbuf
		bsr			cmd_read_sector	; read sector 
		bne.s		fnc_end
;		moveq		#0,d0
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
;		bsr			_read_secbuf
		bsr			cmd_read_sector	; read sector 
		bne.s		fnc_end
;		moveq		#0,d0
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
		

		
		
			
*/
