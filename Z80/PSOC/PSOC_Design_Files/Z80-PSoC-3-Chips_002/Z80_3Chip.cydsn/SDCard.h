/* ========================================
 *
 * Copyright LAND BOARDS, LLC, 2019
 * All Rights Reserved
 * UNPUBLISHED, LICENSED SOFTWARE.
 *
 * CONFIDENTIAL AND PROPRIETARY INFORMATION
 * WHICH IS THE PROPERTY OF Land Boards, LLC.
 *
 * ========================================
*/

#if !defined(SDCARD_H)
#define SDCARD_H
    
#include <project.h>

#define CMD12   0x4C
#define CMD13   0x4D
#define CMD17   0x51    // Read a single block
#define CMD24   0x58    // Write a single block
  
extern    uint16 readPointer;
extern    uint16 writePointer;
    
extern    uint8 readSDBuffer[512];
extern    uint8 writeSDBuffer[512];

void SDInit(void);
void readSDCard(uint32);
void writeSDCard(uint32);
void dumpBuffer(uint8 *);
void SPI_write_byte(uint8 charToWrite);
uint8 SD_command(unsigned char, unsigned long, unsigned char, unsigned char);
void SD_ReadSector(uint32, uint8 *);
uint8 SD_WriteSector(uint32, uint8 *);

/* [] END OF FILE */
#endif