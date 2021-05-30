* 12/24/17 trace command in DDT does not mask off interrupts.  mask off 68681 interrupt
*   in the 68681 device itself.
* 10/30/17 rev5, fix the console input so data is not filtered at all.  This resolves the
*  problem with gkermit binary load.
* 10/28/17 rev 4, DMA address can be odd or even, so word or long word move to/from dma
*  may cause address error.  Replace the longword move with 4 byte moves.
* 7/12/17 Rev 3, Add RAM drive to DRAM, 8 megbyte, from $700000 to $F00000
*  reduce the size of TPA so it is now from $20000 to $700000
* 7/6/17 Use blocking/deblocking algorithm provided by Roger Hanscom
*  The blocking/deblocking algorithm is also described in section 5.3.1 of
*  CP/M-68K System Guide
* 6/28/2017
* start with ERGBIOS.s in distribution disk #7 of CPM68kv1_3
* use CPM15000.SR, CPM S record starts at location 0x15000
*****************************************************************
DUART	equ $FFF000	* base address of 68692 DUART
MRA	equ $FFF001	* mode reg A
SRA	equ $FFF003	* status A (read)
CSRA	equ $FFF003	* clock select reg (write)
CRA	equ $FFF005	* command register (write only)
RHRA	equ $FFF007	* Rx Hold reg A (read)
THRA	equ $FFF007	* Tx Holding reg (write)
IPCR	equ $FFF009	* Input port change reg (read)
ACR	equ $FFF009	* Aux control reg (write)
ISRD	equ $FFF00B	* interrupt status reg (read)
IMRD	equ $FFF00B	* interrupt mask reg (write)			
CTU	equ $FFF00D	* Counter/timer upper (read)
CTL	equ $FFF00F	* counter/timer lower (read)
CTUR	equ $FFF00D	* Counter/timer preload upper (write)
CTLR	equ $FFF00F	* counter/timer preload lower (write)
MR1B	equ $FFF011	* mode reg B
SRB	equ $FFF013	* status reg B
RHRB	equ $FFF017	* Rx holding reg B
IVRD	equ $FFF019	* interrupt vector reg
STOPCTR	equ $FFF01F	* stop counter command reg (read)
STARTCTR equ $FFF01D	* start counter command reg (read)
SETOPR	equ $FFF01D	* bit set output register bits (write)
CLROPR	equ $FFF01F	* bit clear output register (write)
OPCR	equ $FFF01B	* output configuration register(write)

_ccp     equ $150BC                  * hard location for _ccp of CPM15000.SR
         org $1B000                 * this is the hard location for _init for CPM15000.SR
_init:	
         bra.s init1
         dc.b '0.6',0               * rev 0.6 of TinyBIOS
init1:         
         move.b #0,IMRD             * mask off 68681 interrupts
         move.w #$2700,sr           * disable interrupts
*****************
* need to initialize DUART here instead of relying on Tinybug
****************
         move.l	#traphndl,$8c	* set up trap #3 handler
	clr.l	d0		* log on disk A, user 0
	move.b   #$40,CF2427       * set Logical Address addressing mode
	rts

traphndl:
	cmpi	#nfuncs,d0
	bcc	trapng
	lsl	#2,d0		* multiply bios function by 4
**X won't assemble         movea.l 6(pc,d0),a0        * get handler address
**X replace with this:
	movea.l	*+8(pc,d0),a0	* get handler address
	jsr	(a0)		* call handler
trapng:
	rte

biosbase:
	dc.l  _init
	dc.l  wboot
	dc.l  constat
	dc.l  conin
	dc.l  conout
	dc.l  lstout
	dc.l  pun
	dc.l  rdr
	dc.l  home
	dc.l  seldsk
	dc.l  settrk
	dc.l  setsec
	dc.l  setdma
	dc.l  read
	dc.l  write
	dc.l  listst
	dc.l  sectran
	dc.l  setdma
	dc.l  getseg
	dc.l  getiob
	dc.l  setiob
	dc.l  flush
	dc.l  setexc

nfuncs   equ (*-biosbase)/4

wboot:	jmp	_ccp

constat: 
* Check for keyboard input. Set d0 to 1 if keyboard input is pending, otherwise set to 0.

         btst.b #0,SRA     * Does receiver has a char input?
         beq noton         * branch if no input
	moveq.l	#$1,d0		* set result to true
	rts
noton:	clr.l	d0		* set result to false
	rts

conin:	
* Read single ASCII character from the keyboard into d0
         bsr	constat		* see if key pressed
	tst	d0
	beq	conin		* wait until key pressed
         move.b RHRA,d0             * get character
	rts

conout: 
* Display single ASCII character in d1
         btst.b #2,SRA              * check for transmit ready
         beq conout                 * wait until it is ready
         move.b d1,THRA             * put char in d1.b out to console
	rts			* and exit

lstout:	rts

pun:	rts

rdr:	rts

listst:	move.b	#$ff,d0
	rts

* Compact flash registers
maxdsk   equ 5             * five drives
dphlen   equ 26            * length of disk parameter header

CFdata   equ $FFE000       * CF data register
CFerr    equ $FFE002       * CF error reg
CFsectcnt equ $FFE005      * CF sector count reg
CF07     equ $FFE007       * CF LA0-7
CF815    equ $FFE009       * CF LA8-15
CF1623   equ $FFE00B       * CF LA16-23
CF2427   equ $FFE00D       * CF LA24-27
CFstat   equ $FFE00F       * CF status/command reg

home:	clr.w	track
	rts

seldsk:	
*	select disk given by register d1.b
	moveq	#0,d0
	cmp.b	#maxdsk,d1	* valid drive number?
	bpl	selrtn		* if no, return 0 in d0
	move.b	d1,seldrv	* else, save drive number
	move.b	seldrv,d0
	mulu	#dphlen,d0
	add.l	#dph0,d0	         * point d0 at correct dph
selrtn:	rts

settrk:	move.w	d1,track
	rts

setsec:	
         move.w	d1,sector
	rts

sectran:
*	no sector translate, put d1 into d0 and return
         move.w d1,d0
         rts

setdma:
	move.l	d1,dma
	rts

read:
* Read one sector from requested disk, track, sector to dma address
* Retry if necessary, return in d0 00 if ok, else non-zero
         cmp.b #4,seldrv            * RAM drive?
         beq RAMdrvRd               * if RAM drive, handle it differently
         clr.l d0                   * make sure d0 is all zero
         move.w sector,d0           * check if need to read a new sector from CF
         ror.w #2,d0                * 2 lsb are 128-byte index into CF data, save to high byte

         move.l track,d1            * this will read in track (in high word) and sector 
                                    * (in low word)
         and.l #$fffffffc,d1        * mask off the 2 lsb
         cmp.l curCFsect,d1         * does it match track/sect of CF data in the buffer?                           

         beq move2dma                * data already there, 
readCF:         
         move.l d1,curCFsect        * update current CF sector
         move.b #1,CFsectcnt        * read 1 sector
         move.b track,CF1623        * MSB of track goes to LA16-23
         move.b track+1,CF815       * LSB of 16-bit track value goes to LA8-15
         move.b d0,CF07             * CF sector goes to LA07
         lea sectCF,a0             * read into CF sector data buffer
         move.b #$20,CFstat         * read sector command
readdrq:
         btst.b #3,CFstat           * check data request bit set before reading
         beq readdrq
         move.w #$ff,d2             * read 512 bytes
readCF1:
         move.w CFdata,(a0)+        * 16-bit read
         dbra d2,readCF1
move2dma:
         clr.b d0                   * clear the low byte 
         lsr.w #7,d0                * forming 128 byte offset using values in high byte of d0
         add.l #sectCF,d0          * index into CF data buffer
         move.l d0,a0               * a0 points to the CP/M sector 
         move.l dma,a1              * a1 points to buffer pointed by dma
         move.w #31,d2              * transfer 128 bytes
cpdma:
*         move.l (a0)+,(a1)+         * copy long word at a time
         move.b (a0)+,(a1)+         * move long word, byte at a time
         move.b (a0)+,(a1)+         * DMA pointer may be odd or even address
         move.b (a0)+,(a1)+         *  so move word or move longword may cause address error

         move.b (a0)+,(a1)+
         dbra d2,cpdma 
         bra readexit
RAMdrvRd:
         bsr setupRD                * translate track/sector values into RAM loc
RAMdrvR:
*         move.l (a0)+,(a1)+
         move.b (a0)+,(a1)+         * move long word, byte at a time
         move.b (a0)+,(a1)+         * DMA pointer may be odd or even address
         move.b (a0)+,(a1)+         *  so move word or move longword may cause address error

         move.b (a0)+,(a1)+
         dbra d2,RAMdrvR
readexit:
         clr.l d0                   * return OK status         
         rts         
setupRD:
* translate track/sector into RAM location on the RAM drive
         move.l track,d0            * get track & sector values
         lsl.w #6,d0                * multiply by 64
         lsl.l #1,d0                * multiply the track/sector by 128 to index into RAM
         add.l #$700000,d0          * add base address of RAM drive
         move.l d0,a0               * point to the track/sector in RAM drive
         move.l dma,a1             * get dma
         move.w #(128/4)-1,d2        * long word move 128 bytes of sector data
         rts
write:
* Write one sector to requested disk, track, sector from dma address
* Retry if necessary, return in d0 00 if ok, else non-zero
*         cmp.w #2,d1                * if new block, skip pre-read
*         beq writeCF         
         cmp.b #4,seldrv            * RAM drive?
         beq RAMdrvWr               * if RAM drive, handle it differently
         clr.l d0                   * make sure d0 is all zero
         move.w sector,d0           * pre-read the CF sector before write
         ror.w #2,d0                * 2 lsb are 128-byte index into CF data, save to high byte
         move.l track,d1            * this will read in track (in high word) and sector 
                                    * (in low word)
         and.l #$fffffffc,d1        * mask off the 2 lsb
         move.l d1,curCFsect        * update current CF sector 
         move.b #1,CFsectcnt        * read 1 sector
         move.b track,CF1623        * MSB of track goes to LA16-23
         move.b track+1,CF815       * LSB of 16-bit track value goes to LA8-15
         move.b d0,CF07             * CF sector goes to LA07

         lea sectCF,a0             * read into CF sector data buffer
         move.b #$20,CFstat         * read sector command
readdrqw:
         btst.b #3,CFstat           * check data request bit set before reading
         beq readdrqw
         move.w #$ff,d2             * read 512 bytes
preadCF:
         move.w CFdata,(a0)+        * 16-bit read
         dbra d2,preadCF

writeCF:
* calculate the index into CF data block
         clr.b d0                   * clear the low byte 
         lsr.w #7,d0                * forming 128 byte offset with values in high byte of d0
         add.l #sectCF,d0          * index into CF data buffer
         move.l d0,a0               * a0 points to the CP/M sector 
         move.l dma,a1              * a1 points to buffer pointed by dma
         move.w #31,d2              * transfer 128 bytes
wrcpdma:
*         move.l (a1)+,(a0)+         * copy data to be written, long word at a time
         move.b (a1)+,(a0)+         * move long word, byte at a time
         move.b (a1)+,(a0)+         * DMA pointer may be odd or even address
         move.b (a1)+,(a0)+         *  so move word or move longword may cause address error
         move.b (a1)+,(a0)+
         dbra d2,wrcpdma 
                       
         lea sectCF,a0             * points to the 512 byte CF buffer to be written
         move.b #1,CFsectcnt        * read 1 sector
* no need to write CF07, CF815, CF1623.  They are already done with pre-read
         move.b #$30,CFstat
writedrq
         btst.b #3,CFstat          * check data request bit set before writing sector
         beq writedrq        
         move.w #$ff,d2            * write 512 bytes
WriteCF1:
         move.w (a0)+,CFdata        * write data
         dbra d2,WriteCF1           * write 512 bytes of data
WriteCF2:
         btst.b #7,CFstat           * check busy bit for write completed
         bne WriteCF2         
         bra wrexit
RAMdrvWr:
         bsr setupRD                * translate track/sector values into RAM loc
RAMdrvW:
*         move.l (a1)+,(a0)+
         move.b (a1)+,(a0)+         * move long word, byte at a time
         move.b (a1)+,(a0)+         * DMA pointer may be odd or even address
         move.b (a1)+,(a0)+         *  so move word or move longword may cause address error

         move.b (a1)+,(a0)+
         dbra d2,RAMdrvW
wrexit:
         clr.l d0
         rts         

flush:
	clr.l	d0		* return successful
	rts

getseg:
	move.l	#memrgn,d0	* return address of mem region table
	rts

getiob:
	rts

setiob:
	rts

setexc:
	andi.l	#$ff,d1		* do only for exceptions 0 - 255
	cmpi	#47,d1
	beq	noset		* this BIOS doesn't set Trap 15
*	cmpi	#9,d1		* or Trace
*	beq	noset
	lsl	#2,d1		* multiply exception nmbr by 4
	movea.l	d1,a0
	move.l	(a0),d0		* return old vector value
	move.l	d2,(a0)		* insert new vector
noset:	rts


**X	.data

seldrv:	dc.b	$ff	* drive requested by seldsk
resv:    dc.b    0         * reserve byte, padding
curCFsect: dc.l   -1 * current CF sector, the 512 bytes data of curtrk is in sectCF
track:	dc.w	0	* track requested by settrk
sector:	dc.w	0        * max sector value is 0x3FF
dma:	dc.l	0
selcode: dc.b	0	* reserve byte
resv1:   dc.b     0        * reserve byte, padding
pLog     dc.l     $c00000  * diagnostic buffer

memrgn:	dc.w	1	* 1 memory region
         dc.l     $20000   * starts above CP/M
         dc.l     $6e0000  * goes until $7000000.  RAM drive above it
*         dc.l     $dd0000   * goes until $df0000, TPA is ~14meg bytes

* disk parameter headers

dph0:	
         dc.l     0        * no sector translation table
	dc.w	0	* dummy
	dc.w	0
	dc.w	0
	dc.l	dirbuf	* ptr to directory buffer
	dc.l	dpb0	* ptr to disk parameter block
	dc.l	0	* permanent drive, no check vector
	dc.l	alv0	* ptr to allocation vector

dph1:
         dc.l     0        * no sector translation table
	dc.w	0	* dummy
	dc.w	0
	dc.w	0
	dc.l	dirbuf	* ptr to directory buffer
	dc.l	dpb1	* ptr to disk parameter block
	dc.l	0	* permanent drive, no check vector
	dc.l	alv1	* ptr to allocation vector

dph2:
         dc.l     0        * no sector translation table
	dc.w	0	* dummy
	dc.w	0
	dc.w	0
	dc.l	dirbuf	* ptr to directory buffer
	dc.l	dpb2	* ptr to disk parameter block
	dc.l	0	* permanent drive, no check vector
	dc.l	alv2	* ptr to allocation vector

dph3:
         dc.l     0        * no sector translation table
	dc.w	0	* dummy
	dc.w	0
	dc.w	0
	dc.l	dirbuf	* ptr to directory buffer
	dc.l	dpb3	* ptr to disk parameter block
	dc.l	0	* permanent drive, no check vector
	dc.l	alv3	* ptr to allocation vector
	
dph4:
         dc.l     0        * no sector translation table
	dc.w	0	* dummy
	dc.w	0
	dc.w	0
	dc.l	dirbuf	* ptr to directory buffer
	dc.l	dpb4	* ptr to disk parameter block
	dc.l	0	* permanent drive, no check vector
	dc.l	alv4	* ptr to allocation vector

* disk parameter block
* choose a BLS of 4096
* 1024 sectors (128 byte sector) per track
* 64 sectors per block
* 62 tracks per drive 
dpb0:	
         dc.w     1024      * 1024 sectors per track
         dc.b     5        * block shift for BLS of 4096
         dc.b     31       * block mask for BLS of 4096
	dc.b	1	* extent mask, EXM
	dc.b	0	* dummy fill
         dc.w     1983     * DSM, does not count the 1st track, and leave a head room of 1 track
                           * 62 tracks * 1024 sectors * 128 bytes = 1984 blocks or ~8meg
         dc.w     511      * DRM, 512 directory entries
	dc.w	0	* directory mask
         dc.w     0        * permanent mounted drive, check size is zero
         dc.w     1        * track offset of 1

* disk parameter block
* choose a BLS of 4096
* 1024 sectors (128 byte sector) per track
* 64 sectors per block
* 63 tracks per drive 
dpb1:	
         dc.w     1024      * 1024 sectors per track
         dc.b     5        * block shift for BLS of 4096
         dc.b     31       * block mask for BLS of 4096
	dc.b	1	* extent mask, EXM
	dc.b	0	* dummy fill
         dc.w     2015     * DSM, leave a head room of 1 track before next drive
                           * 63 tracks * 1024 sectors * 128 bytes ~ 8 meg or 2016 blocks
         dc.w     511      * DRM, 512 directory entries
	dc.w	0	* directory mask
         dc.w     0        * permanent mounted drive, check size is zero
         dc.w     64       * track offset of 64

* disk parameter block
* choose a BLS of 4096
* 1024 sectors (128 byte sector) per track
* 64 sectors per block
* 63 tracks per drive 
dpb2:	
         dc.w     1024      * 1024 sectors per track
         dc.b     5        * block shift for BLS of 4096
         dc.b     31       * block mask for BLS of 4096
	dc.b	1	* extent mask, EXM
	dc.b	0	* dummy fill
         dc.w     2015     * DSM, leave a head room of 1 track before next drive
                           * 63 tracks * 1024 sectors * 128 bytes ~ 8 meg or 2016 blocks
         dc.w     511      * DRM, 512 directory entries
	dc.w	0	* directory mask
         dc.w     0        * permanent mounted drive, check size is zero
         dc.w     128       * track offset of 128
         
* disk parameter block
* choose a BLS of 4096
* 1024 sectors (128 byte sector) per track
* 64 sectors per block
* 63 tracks per drive 
dpb3:	
         dc.w     1024      * 1024 sectors per track
         dc.b     5        * block shift for BLS of 4096
         dc.b     31       * block mask for BLS of 4096
	dc.b	1	* extent mask, EXM
	dc.b	0	* dummy fill
         dc.w     2015     * DSM, leave a head room of 1 track before next drive
                           * 63 tracks * 1024 sectors * 128 bytes ~ 8 meg or 2016 blocks
         dc.w     511      * DRM, 512 directory entries
	dc.w	0	* directory mask
         dc.w     0        * permanent mounted drive, check size is zero
         dc.w     192        * track offset of 192

* RAM drive in memory from $700000 to $E00000
* disk parameter block
* choose a BLS of 4096
* 1024 sectors (128 byte sector) per track
* 64 sectors per block
* 63 tracks per drive 
dpb4:	
         dc.w     1024      * 1024 sectors per track
         dc.b     5        * block shift for BLS of 4096
         dc.b     31       * block mask for BLS of 4096
	dc.b	1	* extent mask, EXM
	dc.b	0	* dummy fill
         dc.w     2047     * DSM, leave a head room of 1 track before next drive
                           * 63 tracks * 1024 sectors * 128 bytes ~ 8 meg or 2016 blocks
         dc.w     511      * DRM, 512 directory entries
	dc.w	0	* directory mask
         dc.w     0        * permanent mounted drive, check size is zero
         dc.w     0        * no track offset

**X no sector translation table

**X	.bss

dirbuf:	ds.b	128	* directory buffer

* block/deblock buffer area
* data from a CF sector (512 bytes) are stored here
sectCF:  ds.b     512      * CF sector data buffer

alv0:	ds.b	256	* allocation vector, DSM/8+1 = 249
alv1:	ds.b	256      * DSM/8 +1 = 253, round up to 256
alv2:	ds.b	256      * DSM/8 +1 = 253, round up to 256
alv3:	ds.b	256      * DSM/8 +1 = 253, round up to 256
alv4:	ds.b	256      * DSM/8 +1 = 253, round up to 256

*	end $15000        * start executing CPM at $15000
         end 0























*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~9~
