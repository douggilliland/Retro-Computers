/* OSISDOS.c - Minimal Operating System for OSI C1P/SuperBoard ][ 	*/
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

/* issueSDCardCommand - Send read or write command to SD Card		*/
void issueSDCardCommand(unsigned char rwCmd)
{
	*(unsigned char *) SD_CTRL = rwCmd;
}

/* setLBA0 - Set the least significant logical block address bits	*/
void setLBA0(unsigned char lba0)
{
	*(unsigned char *) SD_LBA0 = lba0;
}

/* setLBA1 - Set the middle 8 bits of the logical block addr bits	*/
void setLBA1(unsigned char lba1)
{
	*(unsigned char *) SD_LBA1 = lba1; 
}

/* setLBA2 - Set the upper 8 bits of the logical block addr bits	*/
void setLBA2(unsigned char lba2)
{
	*(unsigned char *) SD_LBA2 = lba2;
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

/* writeBlock - Write a block to the SD Card						*/
void writeBlock(void)
{
	unsigned short loopCount;
	unsigned char * outBuffer;
	outBuffer = (unsigned char *) WRITE_BUFFER_START;
	waitSDCardReady();
	issueSDCardCommand(WRITE_COMMMAND);
	for (loopCount = 0; loopCount < 512; loopCount++)
	{
		writeByteToSDCard(*outBuffer++);
	}
}

void readSector(unsigned long secNum)
{
	setLBA0((unsigned char)secNum);
	setLBA1((unsigned char)(secNum>>8));
	setLBA2((unsigned char)(secNum>>16));
	readBlock();
}

#define BPB_RsvdSecCnt_16	14	// 14-15
#define BPB_NumFATs_8		16
#define BPB_FATSz32_32		36	// 36-39 0x24-0x27

/* 16 banks of 4KB each in memory map from 0xE000-0xEFFF	*/
void setSRAMBank(unsigned char bankNum)
{
	*(unsigned char*) BANK_SELECT_REG_ADR = bankNum;
}

/* main - Test the SD Card interface								*/
void main(void)
{
	unsigned long dirSectorySectorNumber;
	unsigned short sectorCount;
	unsigned char numFATs;
	unsigned long FATSz;
	setSRAMBank(0);					/* Set bank register to first bank */
	readSector((unsigned long)0);	/* Master boot record at sector 0 */
	/* Read the directory into the bank SRAM*/
	/* Get the sector count, number of FATs, and FAt size	*/
	sectorCount = * (unsigned long *) (READ_BUFFER_START + BPB_RsvdSecCnt_16);
	numFATs = * (unsigned char *) (READ_BUFFER_START + BPB_NumFATs_8);
	FATSz = * (unsigned long *) (READ_BUFFER_START + BPB_FATSz32_32);
	/* Assumes that numFATs = 2 */
	/* Do the math to find the directory sector				*/
	dirSectorySectorNumber = sectorCount + (FATSz << 1);
	/* read the directory 		*/
	readSector(dirSectorySectorNumber);
}
