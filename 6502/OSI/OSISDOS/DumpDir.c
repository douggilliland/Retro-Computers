/* DumpDir.c - Minimal Operating System for OSI C1P/SuperBoard ][ 	*/
/* SDHC card based disk operating system							*/
/* 8KB Microsoft BASIC-In-ROM has I/O support routines				*/
/* CEGMON has various hooks to the I/O in BASIC						*/
/* Uses Banked SRAM from $E000-$EFFF to buffer SD card data.		*/
/* Intended to fit within a small ROM space below CEGMON			*/
/*	Target ROM space goes from $F100-$F7FF (1.75kb)					*/
/*																	*/
/* Compiled using CC65 toolchain 									*/

/* 
Memory Map
	$0000-$9FFF - SRAM (40KB)
	$A000-$BFFF - Microsoft BASIC-in-ROM (8KB)
		$D000-$D3FF - 1KB Display RAM
		$DC00 - PS/2 Keyboard
		$E000-$EFFF - Bank Selectable SRAM (not detectable as BASIC RAM)
		$F000-$FFFF - CEGMON Monitor ROM 4K
		$F000-$F001 - ACIA (UART) 61440-61441 dec
		$F002 - J6 I/O Connector 61442 dec
		$F003 - J8 I/O Connector 61443 dec
 	$F004 - LEDS 61444 dec
		d0-d1 LEDs are on the FPGA card
 	$F005 - Bank Select Register 61445 dec
		d0..d3 used for 128KB SRAMs
	$F010-$F017 - SD card
	   	0    SDDATA        read/write data
		1    SDSTATUS      read
		1    SDCONTROL     write
		2    SDLBA0        write-only
		3    SDLBA1        write-only
		4    SDLBA2        write-only (only bits 6:0 are valid)
*/

//#include "osic1p.h"

/* Hardware specific defines follow		*/
#define READ_BUFFER_START	0xE000	/* Banked SRAM			*/
#define WRITE_BUFFER_START	0xE200	
#define LED_BITS_01			0xF004
#define BANK_SELECT_REG_ADR	0xF005
#define START_BANKED_RAM 	0xE000
#define SD_DATA				0xF010
#define SD_CTRL				0xF011
#define SD_STATUS			0xF011
#define SD_LBA0				0xF012
#define SD_LBA1				0xF013
#define SD_LBA2				0xF014
#define READ_COMMMAND		0x00
#define WRITE_COMMMAND		0x01

/* SD Card specific defines follow		*/
#define BPB_SecPerClus_OFFSET		13
#define BPB_RsvdSecCnt_16_OFFSET	14	// 14-15
#define BPB_NumFATs_8_OFFSET		16
#define BPB_FATSz32_32_OFFSET		36	// 36-39 0x24-0x27
#define DIR_FstClusHI_16_OFFSET		20
#define DIR_FstClusLo_16_OFFSET		26

/* Globals		 */
unsigned char	BPB_SecPerClus_8;
unsigned short	BPB_RsvdSecCnt_16;
unsigned char	BPB_NumFATs_8;
unsigned long	BPB_FATSz32_32;
unsigned short	DIR_FstClusHI_16;
unsigned short	DIR_FstClusLo_16;
unsigned short	fileNumber;
unsigned long	firstDataSectorNum_32;
unsigned long	fileSectorNum_32;

/* issueSDCardCommand - Send read or write command to SD Card		*/
void issueSDCardCommand(unsigned char rwCmd)
{
	*(unsigned char *) SD_CTRL = rwCmd;
}

/* waitSDCardReady - Wait for the SD Card to be ready				*/
void waitSDCardReady(void)
{
	* (unsigned char *) LED_BITS_01 = 0x1;
	while (*(unsigned char *) SD_STATUS != 0x80);
	* (unsigned char *) LED_BITS_01 = 0x0;
}

/* waitSDCardRcvDataReady - Wait for the SD Card to have data ready	*/
void waitSDCardRcvDataReady(void)
{
	while (*(unsigned char *) SD_STATUS != 0xE0);
}

/* waitSDCardTxDataEmpty - Wait for transmit ready from SD ctrlr	*/
void waitSDCardTxDataEmpty(void)
{
	while (*(unsigned char *) SD_STATUS != 0xA0);
}

/* readByteFromSDCard - Read a byte from the SD Card				*/
unsigned char readByteFromSDCard(void)
{
	char rdChar;
	waitSDCardRcvDataReady();
	rdChar = *(unsigned char *) SD_DATA;
	return(rdChar);
}

/* writeByteToSDCard - Write a byte to the SD Card					*/
void writeByteToSDCard(unsigned char outChar)
{
	waitSDCardTxDataEmpty();
	*(unsigned char *) SD_DATA = outChar;
}

/* readBlock - -Read a block from the SD Card						*/
void readBlock(void)
{
	unsigned short loopCount;
	unsigned char * inBuffer;
	inBuffer = (unsigned char *) READ_BUFFER_START;
	waitSDCardReady();
	issueSDCardCommand(READ_COMMMAND);
	for (loopCount = 0; loopCount < 512; loopCount++)
	{
		*inBuffer++ = readByteFromSDCard();
	}
}

/* writeBlock - Write a block to the SD Card							*/
/* secNum is the sector number											*/
void writeBlock(unsigned long secNum)
{
	unsigned short loopCount;
	unsigned char * outBuffer;
	/* The SD Card controller needs the three LBA registers to be written	*/
	*(unsigned char *) SD_LBA0 = (unsigned char) secNum;
	*(unsigned char *) SD_LBA1 = (unsigned char) (secNum>>8);
	*(unsigned char *) SD_LBA2 = (unsigned char) (secNum>>16);
	outBuffer = (unsigned char *) WRITE_BUFFER_START;
	waitSDCardReady();
	issueSDCardCommand(WRITE_COMMMAND);
	for (loopCount = 0; loopCount < 512; loopCount++)
	{
		writeByteToSDCard(*outBuffer++);
	}
}

/* Read in a sector to the Bank SRAM									*/
/* secNum is the sector number											*/
void readSector(unsigned long secNum)
{
	/* The SD Card controller needs the three LBA registers to be written	*/
	*(unsigned char *) SD_LBA0 = (unsigned char) secNum;
	*(unsigned char *) SD_LBA1 = (unsigned char) (secNum>>8);
	*(unsigned char *) SD_LBA2 = (unsigned char) (secNum>>16);
	readBlock();
}

/* 16 banks of 4KB each in memory map from 0xE000-0xEFFF	*/
void setSRAMBank(unsigned char bankNum)
{
	*(unsigned char*) BANK_SELECT_REG_ADR = bankNum;
}

#define HARD_CODED_FILE_NUMBER		4	// Hard coded for the 4th file

/* main - Test the SD Card interface								*/
void main(void)
{
	setSRAMBank(0);		/* Set bank register to first bank */
	readSector(0UL);		/* Master boot record at sector 0 */
	/* Get the sector count, number of FATs, and FAT size	*/
	BPB_RsvdSecCnt_16	= * (unsigned long *) (READ_BUFFER_START + BPB_RsvdSecCnt_16_OFFSET);
	BPB_NumFATs_8		= * (unsigned char *) (READ_BUFFER_START + BPB_NumFATs_8_OFFSET);
	BPB_FATSz32_32		= * (unsigned long *) (READ_BUFFER_START + BPB_FATSz32_32_OFFSET);
	BPB_SecPerClus_8	= * (unsigned long *) (READ_BUFFER_START + BPB_SecPerClus_OFFSET);
	/* Assumes that BPB_NumFATs_8 = 2 */
	/* Do the math to find the directory sector				*/
	firstDataSectorNum_32 = BPB_RsvdSecCnt_16 + (BPB_FATSz32_32 << 1);
	/* Read the directory into the banked SRAM	*/
	readSector(firstDataSectorNum_32);
	/* First 512 bytes of the directory is now in the Banked SRAM	*/
	fileNumber = HARD_CODED_FILE_NUMBER;	/* File table has 32 values for each file	*/
	DIR_FstClusHI_16	= * (unsigned short *) (READ_BUFFER_START + (fileNumber << 5) + DIR_FstClusHI_16_OFFSET);
	DIR_FstClusLo_16	= * (unsigned short *) (READ_BUFFER_START + (fileNumber << 5) + DIR_FstClusLo_16_OFFSET);
	fileSectorNum_32	= DIR_FstClusHI_16;
	fileSectorNum_32	= fileSectorNum_32 << 16;
	fileSectorNum_32	= fileSectorNum_32	+ DIR_FstClusLo_16;
	fileSectorNum_32	= (fileSectorNum_32 + - 2) * BPB_SecPerClus_8;
	fileSectorNum_32	= fileSectorNum_32 + firstDataSectorNum_32;
	readSector(fileSectorNum_32);
	/* First 512 bytes of the file are in the Banked SRAM	*/
}
