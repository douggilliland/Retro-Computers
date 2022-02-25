/***********************************************************************
 *
 *		BINFILE.CPP
 *		Teeside binary file routines for 68000 Assembler
 *              This file contains the routines that generate a binary
 *              file compatible with the Teeside 68000 emulator. I am
 *              not sure about the header configuration of the Teeside
 *              binary files. Several of the bytes in the header appear
 *              to be constant (perhaps version number info etc.) and
 *              are simply copied from a Teeside binary file.
 *
 *    Function: initBin()
 *		Opens the specified binary code file for writing. If
 *		the file cannot be opened, then the routine prints a
 *		message and exits.
 *
 *		outputBin()
 *		Places the data whose size, value, and address are
 *		specified in the binary code file.
 *
 *		finishBin()
 *              Closes the object code file and writes the Teeside header.
 *
 *      Author: Chuck Kelly
 *              Jan-28-2002
 *              Monroe County Community College
 *              http://www.monroeccc.edu/ckelly
 *
 ************************************************************************/


#include <vcl.h>
#include <stdio.h>
#include <ctype.h>
#include "mainS.h"
#include "textS.h"
#include "asm.h"

// prototype
void writeBigEndian(int data, int size);

extern char line[256];
extern FILE *binFile;
extern char newOrg;
extern char buffer[256];  //ck used to form messages for display in windows
extern char numBuf[20];
extern bool offsetMode;

int binAddr;
bool newFile = false;
unsigned int sectionCount;     // number of sections
unsigned int byteCount;        // code bytes in current program section
int byteCountFP;               // byte count file position
int currentFP;                 // save current file position
unsigned int startAddress;     // starting address of program
int fileSize;                  // count bytes in file


int initBin(char *name)
{
  binFile = fopen(name, "wb");  // create binary file
  if (!binFile) {
    sprintf(buffer,"Unable to create binary file!");
    Application->MessageBox(buffer, "Error", MB_OK);
    return MILD_ERROR;
  }

  newFile = true;
  sectionCount = 0;                     // # of sections
  byteCount = 0;                        // clear section byte count
  binAddr = 0;                          // default address

  fileSize = 0;                         // 0 bytes in header
//  fileSize = 20;                        // 20 bytes in header

  // write Teeside header to file (removed in EASy68K v4.4.4)
  //writeBigEndian(0x0001, WORD_SIZE);         // version # ?
  //writeBigEndian(0, LONG_SIZE);              // # of sections (update later)
  //writeBigEndian(0, LONG_SIZE);              // unknown
  //writeBigEndian(0, LONG_SIZE);              // starting address (update later)
  //writeBigEndian(0x2800, WORD_SIZE);         // unknown
  //writeBigEndian(0, LONG_SIZE);              // unknown

  return NORMAL;
}


int outputBin(int newAddr, int data, int size)
{
//  int zero = 0;

  try {
  if (offsetMode)       // don't write data if processing Offset directive
    return NORMAL;

  // init starting address of new file
  if (newFile)
  {
    binAddr = newAddr;
    newFile = false;
    sectionCount++;                 // count sections
    writeBigEndian(newAddr, LONG_SIZE);  // write new address to file
    byteCountFP = ftell(binFile);   // save file position of byteCount
    writeBigEndian(0, LONG_SIZE);        // save room for byte count (update later)
    fileSize += 8;                      // keep track of file size
  }

  // If the new address doesn't follow the previous data's address
  if (newAddr != binAddr) {
    currentFP = ftell(binFile);          // save current file position
    // position file at previous sections byte count
    fseek(binFile, byteCountFP, SEEK_SET);
    writeBigEndian(byteCount, LONG_SIZE);     // write previous sections byte count
    fseek(binFile, currentFP, SEEK_SET); // return file to current position
    byteCount = 0;                       // clear byte count for new section

    sectionCount++;                 // count sections
    writeBigEndian(newAddr, LONG_SIZE);  // write new address to file
    byteCountFP = ftell(binFile);   // save file position of byteCount
    writeBigEndian(0, LONG_SIZE);        // save room for byte count (update later)
    binAddr = newAddr;
    fileSize += 8;                      // keep track of file size
  }

  // if writing WORD_SIZE or LONG_SIZE data to odd address
  if ((size != BYTE_SIZE) && (binAddr % 2)) {
    writeBigEndian(0, BYTE_SIZE);            // pad with byte of 0
    byteCount++;                        // count the byte
    binAddr++;                          // next address
    fileSize += 1;                      // keep track of file size
  }

  writeBigEndian(data, size);           // write the data to the file
  byteCount += (int) size;             // count the bytes
  binAddr += (int) size;               // next address
  fileSize += size;                     // keep track of file size

  }
  catch( ... ) {
    sprintf(buffer, "ERROR: An exception occurred in routine 'outputBin'. \n");
    printError(NULL, EXCEPTION, 0);
    return MILD_ERROR;
  }
  return NORMAL;
}

int finishBin()
{
  try {
  // make sure file contains an even number of bytes
  if (fileSize % 2)                     // if odd size
    writeBigEndian(0, 1);               // write an extra byte of 0

  currentFP = ftell(binFile);          // save current file position
  // position file at previous sections byte count
  fseek(binFile, byteCountFP, SEEK_SET);
  writeBigEndian(byteCount, LONG_SIZE);     // write previous sections byte count

  rewind(binFile);                      // rewind to start of file

  // write Teeside header to file  removed in EASy68K v4.4.4
  //writeBigEndian(0x0001, WORD_SIZE);         // version # ?
  //writeBigEndian(sectionCount, LONG_SIZE);   // # of sections
  //writeBigEndian(0, LONG_SIZE);              // unknown
  //writeBigEndian(startAddress, LONG_SIZE);   // starting address
  //writeBigEndian(0x2800, WORD_SIZE);         // unknown
  //writeBigEndian(0, LONG_SIZE);              // unknown

  // close the file
  fclose(binFile);
  }
  catch( ... ) {
    sprintf(buffer, "ERROR: An exception occurred in routine 'finishBin'. \n");
    printError(NULL, EXCEPTION, 0);
    return MILD_ERROR;
  }

  return NORMAL;
}

// Write size bytes from data to file in Big-Endian format
// Always writes WORD_SIZE and LONG_SIZE data to even address.
void writeBigEndian(int data, int size)
{
  unsigned char dataByte;

  try {
  // if writing WORD_SIZE or LONG_SIZE data to odd address
  if ((size != BYTE_SIZE) && (ftell(binFile) % 2))
  {
    dataByte = 0;
    fwrite(&dataByte, 1, 1, binFile);   // pad with byte of 0
  }

  // write data to file
  for (int i=size-1; i>=0; i--)
  {
    dataByte = data >> 8*i;
    fwrite(&dataByte, 1, 1, binFile);
  }
  }
  catch( ... ) {
    sprintf(buffer, "ERROR: An exception occurred in routine 'writeBigEndian'. \n");
    printError(NULL, EXCEPTION, 0);
  }
}


