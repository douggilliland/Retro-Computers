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

extern    uint16 readPointer;
extern    uint16 writePointer;
    
extern    uint8 readSDBuffer[512];
extern    uint8 writeSDBuffer[512];

void readSDCard(uint32);
void dumpBuffer(uint8 *);
void SPI_write(uint8 charToWrite);
uint8 SD_command(unsigned char, unsigned long, unsigned char, unsigned char);
void SD_readSector(uint32, uint8 *);
void SD_WriteSector(uint32, uint8 *);

/* [] END OF FILE */
#endif