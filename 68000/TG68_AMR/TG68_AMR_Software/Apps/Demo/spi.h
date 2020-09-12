#ifndef SPI_H
#define SPI_H

short spi_init();
short sd_read_sector(unsigned long lba,unsigned char *buf);
short sd_write_sector(unsigned long lba,unsigned char *buf); // FIXME - stub

#endif
