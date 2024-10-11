/* ========================================
 *
 * Copyright Land Boards, LLC, 2016
 * All Rights Reserved
 * UNPUBLISHED, LICENSED SOFTWARE.
 *
 * CONFIDENTIAL AND PROPRIETARY INFORMATION
 * WHICH IS THE PROPERTY OF your company.
 *
 * ========================================
*/

#include "project.h"
#include "proEnv.h"
#undef DEBUG_ON_PC
//#define DEBUG_ON_PC 1

#ifdef DEBUG_ON_PC
uint8 memoryArray[32768];
#include "mytypes.h"

void initMemArray(void)
{
    uint16 loopCount;
    for (loopCount=0; loopCount<32768; loopCount++)
    {
        memoryArray[loopCount] = (uint8) (loopCount&0xff);
    }
}
#endif

////////////////////////////////////////////////////////////////
// uint32 readLong(uint32 readAddress)
////////////////////////////////////////////////////////////////

uint32 readLong(uint32 readAddress)
{
#ifndef DEBUG_ON_PC
    uint32 * rdAdr;
    rdAdr = (uint32 *) readAddress;
    return(*rdAdr);
#endif
#ifdef DEBUG_ON_PC
    uint32 rLong = 0;
    rLong = memoryArray[(readAddress&0x7ffc)+0]<< 24;
    rLong |= memoryArray[(readAddress&0x7ffc)+1]<< 16;
    rLong |= memoryArray[(readAddress&0x7ffc)+2]<< 8;
    rLong |= memoryArray[(readAddress&0x7ffc)+3]<< 0;
    return(rLong);
#endif
}

////////////////////////////////////////////////////////////////
// uint16 readShort(uint32 readAddress)
////////////////////////////////////////////////////////////////

uint16 readShort(uint32 readAddress)
{
#ifndef DEBUG_ON_PC
    uint16 * rdAdr;
    rdAdr = (uint16 *) readAddress;
    return(*rdAdr);
#endif
#ifdef DEBUG_ON_PC
    uint16 rShort=0;
    rShort |= memoryArray[(readAddress&0x7ffe)+0]<< 8;
    rShort |= memoryArray[(readAddress&0x7ffe)+1]<< 0;
    return(rShort);
#endif
}

////////////////////////////////////////////////////////////////
// uint8 readByte(uint32 readAddress)
////////////////////////////////////////////////////////////////

uint8 readByte(uint32 readAddress)
{
#ifndef DEBUG_ON_PC
    uint8 * rdAdr;
    rdAdr = (uint8 *) readAddress;
    return(*rdAdr);
#endif
#ifdef DEBUG_ON_PC
    uint8 rByte = memoryArray[readAddress&0x7fff];
    return(rByte);
#endif
}

////////////////////////////////////////////////////////////////
// void writeLong(uint32 writeAddress, uint32 writeData)
////////////////////////////////////////////////////////////////

void writeLong(uint32 writeAddress, uint32 writeData)
{
#ifndef DEBUG_ON_PC
    uint32 * wrAdr;
    wrAdr = (uint32 *) writeAddress;
    *wrAdr = writeData;
    return;
#endif
#ifdef DEBUG_ON_PC
    memoryArray[(writeAddress&0x7ffc)+0] = (writeData&0x000000ff) >> 0;
    memoryArray[(writeAddress&0x7ffc)+1] = (writeData&0x0000ff00) >> 8;
    memoryArray[(writeAddress&0x7ffc)+2] = (writeData&0x00ff0000) >> 16;
    memoryArray[(writeAddress&0x7ffc)+3] = (writeData&0xff000000) >> 24;
    return;
#endif
}

////////////////////////////////////////////////////////////////
// void writeLong(uint32 writeAddress, uint32 writeData)
////////////////////////////////////////////////////////////////

void writeShort(uint32 writeAddress, uint16 writeData)
{
#ifndef DEBUG_ON_PC
    uint16 * wrAdr;
    wrAdr = (uint16 *) writeAddress;
    *wrAdr = writeData;
    return;
#endif
#ifdef DEBUG_ON_PC
    memoryArray[(writeAddress&0x7ffc)+0] = (writeData&0x000000ff) >> 0;
    memoryArray[(writeAddress&0x7ffc)+1] = (writeData&0x0000ff00) >> 8;
    return;
#endif
}

////////////////////////////////////////////////////////////////
// void writeLong(uint32 writeAddress, uint32 writeData)
////////////////////////////////////////////////////////////////

void writeByte(uint32 writeAddress, uint8 writeData)
{
#ifndef DEBUG_ON_PC
    uint8 * wrAdr;
    wrAdr = (uint8 *) writeAddress;
    *wrAdr = writeData;
    return;
#endif
#ifdef DEBUG_ON_PC
    memoryArray[(writeAddress&0x7ffc)+0] = (writeData&0x000000ff) >> 0;
    return;
#endif
}

/* [] END OF FILE */
