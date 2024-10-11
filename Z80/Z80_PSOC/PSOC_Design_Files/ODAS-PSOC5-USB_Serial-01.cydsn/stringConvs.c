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
#include "stringConvs.h"

////////////////////////////////////////////////////////////////
// findInString
////////////////////////////////////////////////////////////////

int8 findInString(char * stringToParse, char valToFind)
{
    char * stringPointer = stringToParse;
    int8 offset = 0;
    //writeLine("looking for");
    //writeLine(stringToParse);
    while (stringPointer[offset] != 0)
    {
        if (stringPointer[offset] == valToFind)
            return(offset);
        offset++;
    }
    return(-1);
}

////////////////////////////////////////////////////////////////
// uint8 charToNibble(char)
////////////////////////////////////////////////////////////////

uint8 charToNibble(char digitChar)
{
    //writeLine("charToNibble: got here");
    if (digitChar >= '0' && digitChar <= '9')
        return(digitChar-'0');
    else if (digitChar >= 'a' && digitChar <= 'f')
       return(digitChar-'a'+10);
    else if (digitChar >= 'A' && digitChar <= 'F')
       return(digitChar-'A'+10);
    return(0);
}

////////////////////////////////////////////////////////////////
// uint32 stringToLong(char *)
////////////////////////////////////////////////////////////////

uint32 stringToLong(char * numString)
{
    uint8 offset = 0;
    uint32 theBigNumber = 0;
    
    //writeLine("stringToLong: got here");
    //writeLine(numString);
    while (numString[offset] != 0)
    {
        theBigNumber = ((theBigNumber * 16) + charToNibble(numString[offset]));
        offset++;
    }
    return theBigNumber;
}

////////////////////////////////////////////////////////////////
// void longToString(uint32 lValue, char * resultString)
////////////////////////////////////////////////////////////////

void longToString(uint32 lValue, char * resultString)
{
    uint32 nibbleMask = 0xf0000000;
    uint8 nibbleOffset = 28;
    uint32 nibbleVal;
    uint8 resultOffset=0;
    //writeLine("longToString: got here");
    for (resultOffset = 0; resultOffset < 8; resultOffset++)
    {
        nibbleVal = ((lValue&nibbleMask)>>nibbleOffset);
        if (nibbleVal <= 9)
            resultString[resultOffset] = nibbleVal+'0';
        else
            resultString[resultOffset] = nibbleVal-10+'A';
        nibbleMask >>= 4;
        nibbleOffset -= 4;
    }
    resultString[8] = 0;
}

////////////////////////////////////////////////////////////////
// void longToString(uint32 lValue, char * resultString)
////////////////////////////////////////////////////////////////

void shortToString(uint16 sValue, char * resultString)
{
    uint32 nibbleMask = 0xf000;
    uint8 nibbleOffset = 12;
    uint32 nibbleVal;
    uint8 resultOffset=0;
    //writeLine("longToString: got here");
    for (resultOffset = 0; resultOffset < 4; resultOffset++)
    {
        nibbleVal = ((sValue&nibbleMask)>>nibbleOffset);
        if (nibbleVal <= 9)
            resultString[resultOffset] = nibbleVal+'0';
        else
            resultString[resultOffset] = nibbleVal-10+'A';
        nibbleMask >>= 4;
        nibbleOffset -= 4;
    }
    resultString[4] = 0;
}

////////////////////////////////////////////////////////////////
// void byteToString(uint8 bValue, char * resultString)
////////////////////////////////////////////////////////////////

void byteToString(uint8 bValue, char * resultString)
{
    uint32 nibbleMask = 0xf0;
    uint8 nibbleOffset = 4;
    uint32 nibbleVal;
    uint8 resultOffset=0;
    //writeLine("byteToString: got here");
    for (resultOffset = 0; resultOffset < 2; resultOffset++)
    {
        nibbleVal = ((bValue&nibbleMask)>>nibbleOffset);
        if (nibbleVal <= 9)
            resultString[resultOffset] = nibbleVal+'0';
        else
            resultString[resultOffset] = nibbleVal-10+'A';
        nibbleMask >>= 4;
        nibbleOffset -= 4;
    }
    resultString[2] = 0;
}

/* [] END OF FILE */
