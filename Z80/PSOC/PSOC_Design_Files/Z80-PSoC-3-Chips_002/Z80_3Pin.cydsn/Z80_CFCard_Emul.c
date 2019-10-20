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

#include <project.h>

#include "Hardware_Config.h"
#include "Z80_CFCard_Emul.h"
#include "Z80_IO_Handle.h"

#ifdef USING_CFCARD

    volatile uint8 CF_DataOut;
    volatile uint8 CF_DataIn;
    volatile uint8 CF_Status;
    volatile uint8 CF_ErrorStatus;
    volatile uint8 CF_Features;
    volatile uint8 CF_SectorCount;
    volatile uint8 CF_ReadSector;
    volatile uint8 CF_LBA0;
    volatile uint8 CF_LBA1;
    volatile uint8 CF_LBA2;
    volatile uint8 CF_LBA3;
    volatile uint8 CF_CylLow;
    volatile uint8 CF_CylHigh;
    volatile uint8 CF_WriteCommand;
    volatile uint8 CF_Head;

    ///////////////////////////////////////////////////////////////////////////////
    // void CFInit(void)
        
    void CFInit(void)
    {
        CF_DataOut = 0x0;
        CF_DataIn = 0x0;
        CF_Status = 0x0;
        CF_ErrorStatus = 0;
        CF_Features = 0;
        CF_SectorCount = 0;
        CF_ReadSector = 0;
        CF_LBA0 = 0;
        CF_LBA1 = 0;
        CF_LBA2 = 0;
        CF_LBA3 = 0;
        CF_CylLow = 0;
        CF_CylHigh = 0;
        CF_WriteCommand = 0;
        CF_Head = 0;
    }
        
    ///////////////////////////////////////////////////////////////////////////////
    // void CFReadData(void)
    // CF_DATA		.EQU	$10
    // In Grant's monitor code - IN - Function rdByte
    // In cbios128 - IN - In functions rdByte512, readhst

    void CFReadData(void)
    {
        Z80_Data_In_Write(CF_DataIn);
        ackIO();
    }

    ///////////////////////////////////////////////////////////////////////////////
    // void CFWriteData(void)
    // CF_DATA		.EQU	$10
    // In Grant's monitor code - No OUT - Read only
    // In cbios128 - OUT - In function wrByte
        
    void CFWriteData(void)
    {
        CF_DataOut = Z80_Data_Out_Read();
        ackIO();
        return;
    }

    ///////////////////////////////////////////////////////////////////////////////
    // void CFReadErrorStat(void)
    // CF_ERROR	.EQU	$11
    // In Grant's monitor code - Not used
    // In cbios128 - Not used
        
    void CFReadErrorStat(void)
    {
        Z80_Data_In_Write(CF_ErrorStatus);
        ackIO();
    }

    ///////////////////////////////////////////////////////////////////////////////
    // void CFWriteFeatures(void)
    // CF_FEATURES	.EQU	$11
    // In Grant's monitor code - OUT - In function CPMLOAD2
    // In cbios128 - OUT - In function boot
    // Values to write CF_8BIT, CF_NOCACHE
        
    void CFWriteFeatures(void)
    {
        CF_Features = Z80_Data_Out_Read();
        ackIO();
        return;
    }

    ///////////////////////////////////////////////////////////////////////////////
    // void CFReadSectorCount(void)
    // CF_SECCOUNT	.EQU	$12
    // In Grant's monitor code - No IN - Not used
    // In cbios128 - OUT - In function rdSectors
        
    void CFReadSectorCount(void)
    {
        Z80_Data_In_Write(CF_SectorCount);
        ackIO();
        return;
    }

    ///////////////////////////////////////////////////////////////////////////////
    // void CFWriteSectorCount(void)
    // CF_SECCOUNT	.EQU	$12
    // In Grant's monitor code - OUT - In function processSectors
    // In cbios128 - OUT - in function rdSectors - In functions rdSectors, setLBAaddr
        
    void CFWriteSectorCount(void)
    {
        CF_SectorCount = Z80_Data_Out_Read();
        ackIO();
        return;
    }

    ///////////////////////////////////////////////////////////////////////////////
    // void CFReadSector(void)
    // CF_SECTOR	.EQU	$13
    // In Grant's monitor code - Not used
    // In cbios128 - Not used
        
    void CFReadSector(void)
    {
        Z80_Data_In_Write(CF_ReadSector);
        ackIO();
        return;
    }

    ///////////////////////////////////////////////////////////////////////////////
    // void CFWriteLBA0(void)
    // CF_LBA0		.EQU	$13
    // In Grant's monitor code - OUT - in function processSectors
    // In cbios128 - OUT - In functions setLBAaddr, CF_LBA0
        
    void CFWriteLBA0(void)
    {
        CF_LBA0 = Z80_Data_Out_Read();
        ackIO();
        return;
    }

    ///////////////////////////////////////////////////////////////////////////////
    // void CFReadCylLow(void)
    // CF_CYL_LOW	.EQU	$14
    // In Grant's monitor code - Not used
    // In cbios128 - Not used
        
    void    CFReadCylLow(void)
    {
        Z80_Data_In_Write(CF_CylLow);
        ackIO();
        return;
    }

    ///////////////////////////////////////////////////////////////////////////////
    // void CFWriteLBA1(void)
    // CF_LBA1		.EQU	$14
    // In Grant's monitor code - OUT - in function processSectors
    // Hard coded to 0x00
    // In cbios128 - OUT - In functions setLBAaddr, CF_LBA0
    // Hard coded to 0x00
        
    void    CFWriteLBA1(void)
    {
        CF_LBA1 = Z80_Data_Out_Read();
        ackIO();
        return;
    }

    ///////////////////////////////////////////////////////////////////////////////
    // void CFReadCylHigh(void)
    // F_CYL_HI	.EQU	$15
    // In Grant's monitor code - Not used
    // Hard coded to 0x00
    // In cbios128 - Not used
        
    void    CFReadCylHigh(void)
    {
        Z80_Data_In_Write(CF_CylHigh);
        ackIO();
        return;
    }

    ///////////////////////////////////////////////////////////////////////////////
    // void CFWriteLBA2(void)
    // CF_LBA2		.EQU	$15
    // In Grant's monitor code - OUT - in function processSectors
    // Hard coded to 0x00
    // In cbios128 - OUT - In functions setLBAaddr, CF_LBA0
    // Hard coded to 0x00
        
    void    CFWriteLBA2(void)
    {
        CF_LBA2 = Z80_Data_Out_Read();
        ackIO();
        return;
    }

    ///////////////////////////////////////////////////////////////////////////////
    // void CFReadHead(void)
    // F_CYL_HI	.EQU	$16
    // In Grant's monitor code - 
    // In cbios128 - Not used
        
    void    CFReadHead(void)
    {
        Z80_Data_In_Write(CF_Head);
        ackIO();
        return;
    }

    ///////////////////////////////////////////////////////////////////////////////
    // void CFWriteLBA3(void)
    // CF_LBA3		.EQU	$16
    // In Grant's monitor code
    // In cbios128 - OUT - In functions setLBAaddr, CF_LBA0
    // Hard coded to 0xE0
        
    void    CFWriteLBA3(void)
    {
        CF_LBA3 = Z80_Data_Out_Read();
        ackIO();
        return;
    }

    ///////////////////////////////////////////////////////////////////////////////
    // void CFReadStatus(void)
    // CF_STATUS	.EQU	$17
    // In Grant's monitor code - IN - In function cfWait
    // Wait for disk to be ready (busy=0,ready=1)
    // In cbios128 - IN - Used in function cfWait1

    void CFReadStatus(void)
    {
        Z80_Data_In_Write(CF_Status);
        ackIO();
    }

    ///////////////////////////////////////////////////////////////////////////////
    // void CFWriteCommand(void)
    // CF_COMMAND	.EQU	$17
    // In Grant's monitor code - OUT - In function CPMLOAD2
    // In cbios128 - OUT - In functions boot, CF_LBA0(wboot), readhst, writehst

    void CFWriteCommand(void)
    {
        CF_WriteCommand = Z80_Data_Out_Read();
        ackIO();
        return;
    }

#endif

/* [] END OF FILE */
