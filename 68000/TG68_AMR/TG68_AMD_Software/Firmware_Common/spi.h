#ifndef SPI_H
#define SPI_H

#define SPIBASE 0x81000000
#define HW_SPI(x) *(volatile unsigned short *)(SPIBASE+x)
#define HW_SPI_L(x) *(volatile unsigned long *)(SPIBASE+x)

/* SPI register */
#define REG_SPI 0x20
#define REG_SPI_CS 0x22	/* CS bits are write-only, but bit 15 reads as the SPI busy signal */
#define REG_SPI_BLOCKING 0x24
#define REG_SPI_PUMP 0x100 /* Pump registers allow speedy throughput with a construct like "movem.l (a0)+,d0-d4" */

#define BIT_SPI_BUSY 15


short spi_init();
short sd_read_sector(unsigned long lba,unsigned char *buf);
short sd_write_sector(unsigned long lba,unsigned char *buf); // FIXME - stub

#endif
