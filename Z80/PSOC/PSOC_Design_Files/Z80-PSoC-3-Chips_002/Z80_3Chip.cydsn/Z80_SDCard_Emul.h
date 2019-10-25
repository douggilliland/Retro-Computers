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

#define CMD12   0x4C
#define CMD17   0x51
#define CMD24   0x58
#define CMD13   0x4D
  
extern    volatile uint8 SD_DataOut;
extern    volatile uint8 SD_DataIn;
extern    volatile uint8 SD_Status;
extern    volatile uint8 SD_Command;
extern    volatile uint8 SD_LBA0_Val;
extern    volatile uint8 SD_LBA1_Val;
extern    volatile uint8 SD_LBA2_Val;
extern    volatile uint8 SD_LBA3_Val;

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
