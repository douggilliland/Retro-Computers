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

#if !defined(Z80SDCARDEMU_H)
#define Z80SDCARDEMU_H

#include <project.h>

//extern  volatile uint8 SD_Status;

extern    volatile uint8 SD_DataOut;
extern    volatile uint8 SD_DataIn;
extern    volatile uint8 SD_Status;
extern    volatile uint8 SD_Command;
extern    volatile uint8 SD_LBA0_Val;
extern    volatile uint8 SD_LBA1_Val;
extern    volatile uint8 SD_LBA2_Val;
extern    volatile uint8 SD_LBA3_Val;
    
// SD_Status bit values from Neal Crook's documentation of Grant's SD card
// b7     Write Data Byte can be accepted
// b6     Read Data Byte available
// b5     Block Busy
// b4     Init Busy
// b3     Unused. Read 0
// b2     Unused. Read 0
// b1     Unused. Read 0
// b0     Unused. Read 0

#define SD_CARD_WR_RDY      0x80    // 128 dec
#define SD_CARD_RD_DATA_RDY 0x40
#define SD_CARD_BLOCK_BUSY  0x20
#define SD_CARD_INIT_BUSY   0x10
// Composite values
#define SD_CARD_READY       0x80    // 128 dec
#define SD_CARD_TX_RDY      0xA0    // 160 dec
#define SD_CARD_RX_READY    0xE0    // 224 dec

void    SDInit(void);
void    SDReadData(void);
void    SDWriteData(void);
void    SDReadStatus(void);
void    SDWriteCommand(void);
void    SDWriteLBA0(void);
void    SDWriteLBA1(void);
void    SDWriteLBA2(void);
void    SdWriteLBA3(void);

    
/* [] END OF FILE */
#endif
