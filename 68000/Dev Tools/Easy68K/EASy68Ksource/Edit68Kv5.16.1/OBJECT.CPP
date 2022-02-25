/***********************************************************************
 *
 *		OBJECT.C
 *		S-Record File Routines for 68000 Assembler
 *
 *    Function: initObj()
 *		Opens the specified object code file for writing. If
 *		the file cannot be opened, then the routine prints a
 *		message and exits. 
 *
 *		outputObj()
 *		Places the data whose size, value, and address are
 *		specified in the object code file. If the new data
 *		would cause the current S-record to exceed a certain
 *		length, or if the address of the current item doesn't
 *		follow immediately after the address of the previous
 *		item, then the current S-record is written to the file
 *		(using writeObj) and a new S-record is started,
 *		beginning with the specified data.
 *
 *		writeObj()
 *		Writes the current S-record to the object code file.
 *		The record length and checksum fields are filled in
 *		before the S-record is written. If an error occurs
 *		during the writing, the routine prints a message and
 *		exits. 
 *
 *		finishObj()
 *		Flushes the S-record buffer by writing out the data in
 *		it (using writeObj), if any, then writes a termination
 *		S-record and closes the object code file. If an error 
 *		occurs during this write, the routine prints a messge
 *		and exits.
 *
 *	 Usage: initObj(name)
 *		char *name;
 *
 *		outputObj(newAddr, data, size)
 *		int data, size;
 *
 *		writeObj()
 *
 *		finishObj()
 *
 *      Author: Paul McKee
 *		ECE492    North Carolina State University
 *
 *        Date:	12/13/86
 *
 *    Modified: Charles Kelly
 *              Monroe County Community College
 *              http://www.monroeccc.edu/ckelly
 *
DESCRIPTION

An S-record file consists of a sequence of specially formatted ASCII character
strings. An S-record will be less than or equal to 78 bytes in length.
The order of S-records within a file is of no significance and no particular
order may be assumed.

The general format of an S-record follows:

+-------------------//------------------//-----------------------+
| type | count | address  |            data           | checksum |
+-------------------//------------------//-----------------------+

type     -- A char[2] field. These characters describe the type of record
            (S0, S1, S2, S3, S5, S7, S8, or S9).
count    -- A char[2] field. These characters when paired and interpreted as a
            hexadecimal value, display the count of remaining character pairs
            in the record.

address  -- A char[4,6, or 8] field. These characters grouped and interpreted
            as a hexadecimal value, display the address at which the data field
            is to be loaded into memory. The length of the field depends on the
            number of bytes necessary to hold the address. A 2-byte address uses
            4 characters, a 3-byte address uses 6 characters, and a 4-byte
            address uses 8 characters.

data     -- A char [0-64] field. These characters when paired and interpreted as
            hexadecimal values represent the memory loadable data or descriptive
            information.

checksum -- A char[2] field. These characters when paired and interpreted as a
            hexadecimal value display the least significant byte of the ones
            complement of the sum of the byte values represented by the pairs of
            characters making up the count, the address, and the data fields.

Each record is terminated with a line feed. If any additional or different
record terminator(s) or delay characters are needed during transmission to the
target system it is the responsibility of the transmitting program to provide them.

************************************************************************/


#include <vcl.h>
#include <stdio.h>
#include <ctype.h>
#include "asm.h"

/* Define the maximum number of bytes (address, data,
   and checksum) that can be in one S-record */
#define SRECSIZE  36

extern char line[256];
extern FILE *objFile;
extern char buffer[256];  //ck used to form messages for display in windows
extern char numBuf[20];
extern unsigned int startAddress;     // starting address of program
extern bool offsetMode;

extern bool mapROM;                     // memory map
extern int mapROMStart, mapROMEnd;
extern bool mapRead;
extern int mapReadStart, mapReadEnd;
extern bool mapProtected;
extern int mapProtectedStart, mapProtectedEnd;
extern bool mapInvalid;
extern int mapInvalidStart, mapInvalidEnd;

static char sRecord[80], *objPtr;
static char byteCount, checksum;
static bool lineFlag;
static int objAddr;
static char objErrorMsg[] = "Error writing to object file\n";


//------------------------------------------------------------
// Output S0-record file header
int initObj(char *name)
{
  objFile = fopen(name, "w");
  if (!objFile) {
    sprintf(buffer,"Unable to create S-Record file");
    Application->MessageBox(buffer, "Error", MB_OK);
    return MILD_ERROR;
  }

  /* Output S0-record file header
  S0 Record. The type of record is 'S0'. The address field is unused and will
  be filled with zeros (0x0000). The header information within the data field is
  divided into the following subfields.

    mname is char[20] and is the module name.
    ver is char[2] and is the version number.
    rev is char[2] and is the revision number.
    description is char[0-36] and is a text comment.

  Each of the subfields is composed of ASCII bytes whose associated characters,
  when paired, represent one byte hexadecimal values in the case of the version
  and revision numbers, or represent the hexadecimal values of the ASCII
  characters comprising the module name and description.

  Beginning with EASy68K v4.8.10 additional S0 records may be used to indicate
  a memory map. The memory map is used displayed in the simulator hardware form.
  */
  //                   /-byte count $21          /-version number
  //                  /     module name         / /-revision number
  //              S0 /0000 6 8 K P R O G       2 0 C R E A T E D   B Y   E A S Y 6 8 K
  strcpy(sRecord,"S021000036384B50524F47202020323043524541544544204259204541535936384B");
  byteCount =     0x21;
  writeObj();
  byteCount = 0;
  lineFlag = false;

  return NORMAL;
}

//------------------------------------------------------------
int outputObj(int newAddr, int data, int size)
{
  try {
    if (offsetMode)       // don't write data if processing Offset directive
      return NORMAL;

    // If the new data doesn't follow the previous data, or if the S-record
    // would be too long, then write out this S-record and start a new one
    if ((lineFlag && (newAddr != objAddr)) || (byteCount + size > SRECSIZE))
    {
      writeObj();
      lineFlag = false;
    }

    // If no S-record is already being assembled, then start making one
    if (!lineFlag) {
      if ((newAddr & 0xFFFF) == newAddr) {
	sprintf(sRecord, "S1  %04X", newAddr);
	byteCount = 3;
      }	else if ((newAddr & 0xFFFFFF) == newAddr) {
	sprintf(sRecord, "S2  %06X", newAddr);
	byteCount = 4;
      }	else {
	sprintf(sRecord, "S3  %08lX", newAddr);
	byteCount = 5;
      }
      objPtr = sRecord + 4 + (byteCount-1)*2;
      objAddr = newAddr;
      lineFlag = true;
    }

    // Add the new data to the S-record
    switch (size) {
      case BYTE_SIZE :
        data &= 0xFF;
	sprintf(objPtr, "%02X", data);
	byteCount++;
	break;
      case WORD_SIZE :
        data &= 0xFFFF;
	sprintf(objPtr, "%04X", data);
	byteCount += 2;
	break;
      case LONG_SIZE :
        sprintf(objPtr, "%08lX", data);
	byteCount += 4;
	break;
      default :
        sprintf(buffer,"outputObj: INVALID SIZE CODE!\n");
        Application->MessageBox(buffer, "Error", MB_OK);
	return MILD_ERROR;
    }
    objPtr += size*2;
    objAddr += (int) size;
  }
  catch( ... ) {
    sprintf(buffer, "ERROR: An exception occurred in routine 'initObj'. \n");
    printError(NULL, EXCEPTION, 0);
    return MILD_ERROR;
  }
    return NORMAL;
}

//------------------------------------------------------------
int writeObj()
{
  char recLen[3];
  AnsiString str = "0x";
  char* sRec = sRecord;

  try {
    // Fill in the record length (including the checksum in the record length
    sprintf(recLen, "%02X", byteCount);
    sRec += 2;          // point to byte count location
    strncpy(sRec, recLen, 2);

    // Calculate checksum and add to record
    checksum = 0;
    for (int i=0; i<byteCount; i++) {
      str = "0x";
      str += *sRec++;
      str += *sRec++;
      checksum += (char) (StrToInt(str) & 0xFF);
    }
    sprintf(sRec, "%02X\n", (~checksum & 0xFF)); // put checksum in sRecord

    // Output the S-record to the object file
    fputs(sRecord, objFile);
    if (ferror(objFile)) {
      sprintf(buffer,objErrorMsg);
      Application->MessageBox(buffer, "Error", MB_OK);
      return MILD_ERROR;
    }
  }
  catch( ... ) {
    sprintf(buffer, "ERROR: An exception occurred in routine 'writeObj'. \n");
    printError(NULL, EXCEPTION, 0);
    return MILD_ERROR;
  }

  return NORMAL;

}


//------------------------------------------------------------
// Pre:
//   name points to string of 20 character name
//   start and end contain addresses
int writeMap(char* name, int start, int end)
{
  char data[6];

  try {
    sprintf(sRecord, "S0  %04X", 0);
    byteCount = 3;
    objPtr = sRecord + 4 + (byteCount-1)*2;

    sprintf(objPtr, name);
    objPtr += 20;
    byteCount += 10;
    sprintf(data,"%06X", start);
    for (int i=0; i<6; i++) {
      sprintf(objPtr, "%02X", data[i]);
      objPtr += 2;
    }
    byteCount += 6;
    sprintf(objPtr, "2C");                    // ","
    objPtr += 2;
    byteCount += 1;
    sprintf(data, "%06X", end);
    for (int i=0; i<6; i++) {
      sprintf(objPtr, "%02X", data[i]);
      objPtr += 2;
    }
    byteCount += 6;
  }
  catch( ... ) {
    sprintf(buffer, "ERROR: An exception occurred in routine 'writeMap'. \n");
    printError(NULL, EXCEPTION, 0);
    return MILD_ERROR;
  }

  return (writeObj());
}

//------------------------------------------------------------
int finishObj()
{

  try {
    // Write out the last real S-record, if present
    if (lineFlag)
      writeObj();

    // Write S0 records for memory map
    if (mapROM) {
      //                     R O M
      writeMap("202020202020524F4D20", mapROMStart, mapROMEnd);
    }
    if (mapRead) {
      //                   R E A D
      writeMap("20202020205245414420", mapReadStart, mapReadEnd);
    }
    if (mapProtected) {
      //         P R O T E C T E D
      writeMap("50524F54454354454420", mapProtectedStart, mapProtectedEnd);
    }
    if (mapInvalid) {
      //             I N V A L I D
      writeMap("2020494E56414C494420", mapInvalidStart, mapInvalidEnd);
    }

    // Write out a S8 record and close the file
    // S8 Record. The address field contains a 3-byte starting execution address.
    // There is no data field.
    sprintf(sRecord, "S8  %06X", startAddress);
    byteCount = 4;
    objPtr = sRecord + 4 + (byteCount-1)*2;
    writeObj();

    if (ferror(objFile)) {
      sprintf(buffer,objErrorMsg);
      Application->MessageBox(buffer, "Error", MB_OK);
      return MILD_ERROR;
    }
    fclose(objFile);

  }
  catch( ... ) {
    fclose(objFile);
    sprintf(buffer, "ERROR: An exception occurred in routine 'finishObj'. \n");
    printError(NULL, EXCEPTION, 0);
    return MILD_ERROR;
  }
  return NORMAL;
}

