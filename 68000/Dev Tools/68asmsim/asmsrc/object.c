/***********************************************************************
 *
 *		OBJECT.C
 *		Object File Routines for 68000 Assembler
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
 ************************************************************************/


#include <stdio.h>
#include <ctype.h>
#include "asm.h"

/* Define the maximum number of bytes (address, data, 
   and checksum) that can be in one S-record */
#define SRECSIZE  36	

extern char line[256];
extern FILE *objFile;

static char sRecord[80], *objPtr;
static char byteCount, checksum, lineFlag;
static long	objAddr;
static char objErrorMsg[] = "Error writing to object file\n";

int	initObj(name)
char *name;
{

	objFile = fopen(name, "w");
	if (!objFile) {	
		puts("Can't open object file");
		exit(0);
		}
	/* Output S-record file header */
/*	fputs("Here comes an S-record...\n", objFile); */
	fputs("S004000020DB\n", objFile);
	lineFlag = FALSE;

	return NORMAL;

}


int	outputObj(newAddr, data, size)
long	newAddr, data;
int	size;
{
	/* If the new data doesn't follow the previous data, or if the S-record
	   would be too long, then write out this S-record and start a new one */
	if ((lineFlag && (newAddr != objAddr)) || (byteCount + size > SRECSIZE))
		{
		writeObj();
		lineFlag = FALSE;
		}

	/* If no S-record is already being assembled, then start making one */
	if (!lineFlag) {
		if ((newAddr & 0xFFFF) == newAddr) {
			sprintf(sRecord, "S1  %04X", newAddr);
			byteCount = 2;
			}
		else if ((newAddr & 0xFFFFFF) == newAddr) {
			sprintf(sRecord, "S2  %06X", newAddr);
			byteCount = 3;
			}
		else {
			sprintf(sRecord, "S3  %08lX", newAddr);
			byteCount = 4;
			}
		objPtr = sRecord + 4 + byteCount*2;
		checksum = (char) (checkValue(newAddr) & 0xff);
		objAddr = newAddr;
		lineFlag = TRUE;
		}
	
	/* Add the new data to the S-record */
	switch (size) {
		case BYTE : data &= 0xFF;
			    		sprintf(objPtr, "%02X", data);
			    		byteCount++;
			    		checksum += (char) (data & 0xff);
			    		break;
		case WORD : data &= 0xFFFF;
			    		sprintf(objPtr, "%04X", data); 
			    		byteCount += 2;
			    		checksum += (char) (checkValue(data) & 0xff);
			    		break;
		case LONG : sprintf(objPtr, "%08lX", data);
			    		byteCount += 4;
			    		checksum += (char) (checkValue(data) & 0xff);
			    		break;
		default   : printf("outputObj: INVALID SIZE CODE!\n");
						exit(0);
		}
	objPtr += size*2;
	objAddr += (long) size;

	return NORMAL;

}	
	


long	checkValue(data)
long	data;
{
	return (data + (data >> 8) + (data >> 16) + (data >> 24)) & 0xFF;
}


int	writeObj()
{
char recLen[3];

	/* Fill in the record length (including the checksum in the record length */
	sprintf(recLen, "%02X", ++byteCount);
	strncpy(sRecord+2, recLen, 2);
	
	/* Add the checksum (including in the checksum the record length) */
	checksum += byteCount;
	sprintf(objPtr, "%02X\n", (~checksum & 0xFF));
	
	/* Output the S-record to the object file */
/*	fputs("Here comes an S-record...\n", objFile); */
	fputs(sRecord, objFile);
	if ferror(objFile) {
		fputs(objErrorMsg, stderr);
		exit(0);
		}

	return NORMAL;

}


int	finishObj()
{
	/* Write out the last real S-record, if present */
	if (lineFlag)
		writeObj();

	/* Write out a termination S-record and close the file*/
	fputs("S9030000FC\n", objFile);
	if ferror(objFile) {
		fputs(objErrorMsg, stderr);
		exit(0);
		}
	fclose(objFile);

	return NORMAL;

}	

