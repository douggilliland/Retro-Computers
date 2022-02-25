//---------------------------------------------------------------------------
//   Author: Chuck Kelly,
//           http://www.easy68k.com
//---------------------------------------------------------------------------
// File Name: fileIO.cpp
// File I/O routines.
// EASyBIN binary file creation and editing utility for EASy68K
//---------------------------------------------------------------------------

#pragma hdrstop
#include "fileIO.h"
#pragma package(smart_init)
#include <stdio.h>
#include <iostream.h>
#include <fstream.h>
#include "Form1u.h"

const int MAXBUF = 515;
char	lbuf[MAXBUF+1];
extern unsigned int startAddr;  // start address of loaded S-Record
extern unsigned int endAddr;    // ending address of loaded S-Record
extern unsigned int length;     // length of data loaded from S-Record
extern char *memory;            // pointer for main binary memory

/*
Motorola S-records in EASy68K

DESCRIPTION
An S-record file consists of a sequence of specially formatted ASCII character
strings. An S-record will be less than or equal to 78 bytes in length.
The original Unix man page on S-records is the only place that a 78-byte limit
on total record length or 64-byte limit on data length is documented. These
values shouldn't be trusted for the general case.
If you write code to convert S-Records, you should always assume that a record
can be as long as 514 (decimal) characters in length (255 * 2 = 510, plus 4
characters for the type and count fields), plus any terminating character(s).
That is, in establishing an input buffer in C, you would declare it to be an
array of 515 chars, thus leaving room for the terminating null character.

The order of S-records within a file is of no significance and no particular
order may be assumed with the exception of the termination record at the end.

The general format of an S-record follows:
+-------------------//------------------//-----------------------+
| type | count | address  |            data           | checksum |
+-------------------//------------------//-----------------------+

type -- A char[2] field. These characters describe the type of record
        (S0, S1, S2, S3, S5, S7, S8, or S9).
count -- A char[2] field. These characters when paired and interpreted as a
        hexadecimal value, display the count of remaining character pairs in
        the record. The count field can have values in the range of 0x3 (2 bytes
        of address + 1 byte checksum = 3) to 0xff.
address -- A char[4,6, or 8] field. These characters grouped and interpreted as
        a hexadecimal value, display the address at which the data field is to
        be loaded into memory. The length of the field depends on the number of
        bytes necessary to hold the address. A 2-byte address uses 4 characters,
        a 3-byte address uses 6 characters, and a 4-byte address uses 8
        characters.
data -- A char [0-64] field. These characters when paired and interpreted as
        hexadecimal values represent the memory loadable data or descriptive
        information.
checksum -- A char[2] field. These characters when paired and interpreted as a
        hexadecimal value display the least significant byte of the ones
        complement of the sum of the byte values represented by the pairs of
        characters making up the count, the address, and the data fields.

Each record is terminated with a line feed. If any additional or different
record terminator(s) or delay characters are needed during transmission to the
target system it is the responsibility of the transmitting program to provide
them.

S0 Record. The address field is unused and will be filled with zeros (0x0000).
        The code/data field contains descriptive information identifying the
        following block of S-records as having been created by EASy68K.
S1 Record. The address field is interpreted as a 2-byte address. The data field
        is composed of memory loadable data.
S2 Record. The address field is interpreted as a 3-byte address. The data field
        is composed of memory loadable data.
S3 Record. The address field is interpreted as a 4-byte address. The data field
        is composed of memory loadable data.
S5 Record. The address field is interpreted as a 2-byte value and contains the
        count of S1, S2, and S3 records previously transmitted. There is no data
        field. (EASy68K does not generate this record.)
S7 Record. Termination record. The address field contains the starting execution
        address and is interpreted as 4-byte address. There is no data field.
        This is the last record in the file.
S8 Record. Termination record. The address field contains the starting execution
        address and is interpreted as 3-byte address. There is no data field.
        This is the last record in the file. (EASy68K always uses this
        termination record type.)
S9 Record. Termination record. The address field contains the starting execution
        address and is interpreted as 2-byte address. There is no data field.
        This is the last record in the file.
*/

//-----------------------------------------------------------------------
// Load S Record file
// Returns true on success, false on error
// sets global startAddr with starting address of S-Record data
// sets global length with length of S-Record data
bool loadSrec(char *name)        // load memory with contents of s_record file
{
  FILE *fp;
  int 	bytecount, line, end__of__file;
  unsigned int loc, lowAddr = 0xFFFFFFFF, highAddr = 0;   // determine high and low address
  char 	s_byte[4], s_type, nambuf[40];
  char 	*bufptr, *bufend, checksum;
  AnsiString str, errorStr, s0str, startAdrStr;
  bool sRecError = false;

  try {
    fp = fopen(name, "rt");
    if (fp == NULL) {             // if file cannot be opened, print message
      ShowMessage(str.sprintf("error: cannot open file %s", name));
      return false;
    }

    line = 0;
    end__of__file = false;
    s_type = 0;
    s0str = "";
    errorStr = "";

    if (!sRecError) {                // if no error
      while (fgets(lbuf, MAXBUF, fp) != NULL) { // read file until end
        bufptr = lbuf;
        line++;
        sscanf (lbuf, "S%c%2x", &s_type, &bytecount);
        bufptr += 4;
        switch (s_type) {         // what type of S record ?
          // S0  Description of S-Record
          case '0' : for (bufend = bufptr; *bufend != '\0'; bufend++);  // put bufend at end of line
                     bufptr += 4;               // skip empty address field
                     s0str = s0str + "S0 = ";
                     //while (sscanf(bufptr,"%02x",&byte)) {
                     while (sscanf(bufptr,"%2x",&s_byte)) {
                       bufptr += 2;
                       if ((bufptr + 2) >= bufend) break;
                       if (s_byte[0] >= ' ' && s_byte[0] <= '~')         // if displayable
                         s0str = s0str + s_byte[0];
                       else
                         s0str = s0str + '.';
                     }
                     s0str += "\n";
                     break;
          // S1 2-byte address
          case '1' : if (sscanf(bufptr,"%04x", &loc) != 1)
                       sRecError = true;
                     else bufptr += 4;
                     break;
          // S2 3-byte address
          case '2' : if (sscanf(bufptr,"%06x", &loc) != 1)
                       sRecError = true;
                     else bufptr += 6;
                     break;
          // S3 4-byte address
          case '3' : if (sscanf(bufptr,"%08x", &loc) != 1)
                       sRecError = true;
                     else bufptr += 8;
                     break;
          // S5 length count
          case '5' : break;       // ignore
          // S7 4-byte starting address
          case '7' : if (sscanf(bufptr,"%08x", &loc) != 1)
                       sRecError = true;
                     else {
                       startAddr = loc;
                       end__of__file = true;
                     }
                     break;
          // S8 3-byte starting address
          case '8' : if (sscanf(bufptr,"%06x", &loc) != 1)
                       sRecError = true;
                     else {
                       startAddr = loc;
                       end__of__file = true;
                     }
                     break;
          // S9 2-byte starting address
          case '9' : if (sscanf(bufptr,"%04x", &loc) != 1)
                       sRecError = true;
                     else {
                       startAddr = loc;
                       end__of__file = true;
                     }
                     break;
          default :  sRecError = true;
        }
        if (end__of__file) break;
        if (sRecError) break;
        for (bufend = bufptr; *bufend != '\0'; bufend++);  // put bufend at end of line
        while (sscanf(bufptr,"%02x",&s_byte)) {
          bufptr += 2;
          if ((bufptr + 2) >= bufend) break;
          if (loc > (MEMSIZE - 1)) {
            errorStr = "ERROR, Address exceeds $FFFFFF\n";
            sRecError = true;
            break;
          }
          else {
            if (loc < lowAddr)
              lowAddr = loc;            // save lowest address
            if (loc > highAddr)
              highAddr = loc;           // save highest address
            memory[loc++] = s_byte[0];
          }
        }
        if (sRecError) break;
      }
    }
    if (sRecError)                     // if error reading file, print message
    {
      str.sprintf("Invalid data on line %d\n",line);
      errorStr += str;
      str.sprintf ("%d: %s\n", line, lbuf);
      errorStr += str;
      errorStr += "\nOpen stopped.";
      ShowMessage(errorStr);
      fclose(fp);			// close file specified
      return false;
    }else{
      fclose(fp);			// close file specified
      startAddr = lowAddr;              // global start
      endAddr = highAddr;               // global end
      length = highAddr - lowAddr + 1;  // global length
      ShowMessage("S Record loaded successfully.\n\nS0 description record contains:\n" + s0str);
      return true;
    }
  }
  catch( ... ) {
    ShowMessage("Unexpected Error reading S-Record file");
    return false;
  }
}

//---------------------------------------------------------------------------
// load binary file into memory at First Address
// split data to all, every 2nd or every 4th byte
// split is 0, 2 or 4
// returns 0 on error, total memory size loaded on success
int loadBinary(char *name, int split) // load memory with contents of binary file
{
  ifstream iFile;
  AnsiString str;
  unsigned int memAddr;
  int size = 0;

  iFile.open(name,ios::binary);
  if (!iFile) {         // if error
    ShowMessage(str.sprintf("Error openning %s",name));
    return 0;
  }

  // get address to load data
  str = "0x";
  memAddr = StrToInt(str + Form1->OutputFirstAddress->EditText);

  if (split == 0)
    split = 1;          // split is 1, 2 or 4

  while( !iFile.eof() && memAddr < MEMSIZE) {   // read all of file
    iFile.read(reinterpret_cast<char*>(&memory[memAddr]),1);
    memAddr += split;
    size += split;
  }
  return size-1;
}

//---------------------------------------------------------------------------
// save Length bytes of binary data from FirstAddress
// split data to all, every 2nd or every 4th byte
// split is 0, 2 or 4
void saveBinary(int split)
{
  AnsiString str0, str1, str2, str3, ext;    // file names
  ofstream oFile0, oFile1, oFile2, oFile3;

  unsigned int fromAddr, toAddr, outLength, i;
  char data[4];

  str0 = "0x";
  fromAddr = StrToInt(str0 + Form1->OutputFirstAddress->EditText);
  outLength = StrToInt(str0 + Form1->OutputLength->EditText);
  toAddr = fromAddr + outLength;

  if (toAddr >= MEMSIZE) {
    Beep();
    Application->MessageBox("Invalid memory range.", "Information", MB_OK);
    return;
  }

  try {
    if(Form1->SaveDialog->Execute()) {
      ext = ExtractFileExt(Form1->SaveDialog->FileName);
      if (split == 0)
        str0 = Form1->SaveDialog->FileName;
      else
        str0 = ChangeFileExt(Form1->SaveDialog->FileName,"_0" + ext);

      str1 = ChangeFileExt(Form1->SaveDialog->FileName,"_1" + ext);
      str2 = ChangeFileExt(Form1->SaveDialog->FileName,"_2" + ext);
      str3 = ChangeFileExt(Form1->SaveDialog->FileName,"_3" + ext);
      if (FileExists(str0)||FileExists(str1)||FileExists(str2)||FileExists(str3)) {
        int response = Application->MessageBox("File exists! OK to replace?", "Alert", MB_YESNO);
        if (response == IDNO)
          return;
      }
      oFile0.open(str0.c_str(),ios::binary);
      if(!oFile0) {     // error
        ShowMessage("Error creating " + str0);
        return;
      }
      if (split > 0) {
          oFile1.open(str1.c_str(),ios::binary);
        if(!oFile1) {     // error
          ShowMessage("Error creating " + str1);
          return;
        }
      }
      if (split > 2) {
        oFile2.open(str2.c_str(),ios::binary);
        if(!oFile2) {     // error
          ShowMessage("Error creating " + str2);
          return;
        }
        oFile3.open(str3.c_str(),ios::binary);
        if(!oFile3) {     // error
          ShowMessage("Error creating " + str3);
          return;
        }
      }

      if (split == 0)
        oFile0.write( reinterpret_cast<char*>(&memory[fromAddr]), outLength);
      else {
        i=0;
        while(i<outLength) {
          if (split == 2) {
            oFile0.write( reinterpret_cast<char*>(&memory[fromAddr+i]), 1);
            if (fromAddr+i+1 <= toAddr)  // if valid data
              oFile1.write( reinterpret_cast<char*>(&memory[fromAddr+i+1]), 1);
            i += 2;
          } else {  // split == 4
            oFile0.write( reinterpret_cast<char*>(&memory[fromAddr+i]), 1);
            if (fromAddr+i+1 <= toAddr)  // if valid data
              oFile1.write( reinterpret_cast<char*>(&memory[fromAddr+i+1]), 1);
            if (fromAddr+i+2 <= toAddr)  // if valid data
              oFile2.write( reinterpret_cast<char*>(&memory[fromAddr+i+2]), 1);
            if (fromAddr+i+3 <= toAddr)  // if valid data
              oFile3.write( reinterpret_cast<char*>(&memory[fromAddr+i+3]), 1);
            i += 4;
          }
        }
      }
      oFile0.close();
      if (split > 0)
        oFile1.close();
      if (split > 2) {
        oFile2.close();
        oFile3.close();
      }
    }
  }
  catch( ... ) {
    MessageDlg("Error saving 68K memory to file.",mtInformation, TMsgDlgButtons() << mbOK,0);
    return;
  }
}

//---------------------------------------------------------------------------
// save S-Record file
void saveSRecord()
{
  // The maximum number of data bytes in one S-record
  const int SRECDATA = 32;

  AnsiString str, fileName;
  ofstream oFile;

  unsigned int fromAddr, toAddr, sRecAddr, outLength, sRecData, byteCount;
  unsigned int dataCount;       // total of data bytes output
  char data[4];
  char sRecord[80], *sRecPtr;

  str = "0x";
  fromAddr = StrToInt(str + Form1->From->EditText);
  sRecAddr = fromAddr;
  toAddr = StrToInt(str + Form1->To->EditText);
  outLength = toAddr - fromAddr;

  if (fromAddr > toAddr || outLength >= MEMSIZE) {
    Beep();
    Application->MessageBox("Invalid memory range.", "Information", MB_OK);
    return;
  }

  try {

    if(Form1->SaveDialog->Execute()) {
      fileName = Form1->SaveDialog->FileName;
      if (FileExists(fileName)) {
        int response = Application->MessageBox("File exists! OK to replace?", "Alert", MB_YESNO);
        if (response == IDNO)
          return;
      }
      oFile.open(fileName.c_str());
      if(!oFile) {     // if error creating file
        ShowMessage("Error creating " + fileName);
        return;
      }

      // Write S0 record (description)
      //                   /-byte count $21          /-version number
      //                  /     module name         / /-revision number
      //              S0 /0000 S R E C O R D       1 1 C R E A T E D   B Y   E A S Y B I N
      strcpy(sRecord,"S0210000535245434F5244202020313143524541544544204259204541535942494E");
      finish(sRecord, 0x21);
      oFile << sRecord;

      // Write S1, S2 or S3 record
      dataCount = 0;    // total data bytes output
      while(dataCount<outLength) {
        // Write record type and address
        if ((sRecAddr & 0xFFFF) == sRecAddr) {
          sprintf(sRecord, "S1  %04X", sRecAddr);
          byteCount = 2;
        } else if ((sRecAddr & 0xFFFFFF) == sRecAddr) {
          sprintf(sRecord, "S2  %06X", sRecAddr);
          byteCount = 3;
        } else {
          sprintf(sRecord, "S3  %08lX", sRecAddr);
          byteCount = 4;
        }
        sRecPtr = sRecord + 4 + byteCount*2;  // pointer into current sRecord
        sRecData = 0;         // data bytes in S-Record

        // Write data for record
        while(sRecData < SRECDATA && dataCount < outLength) {
          sprintf(sRecPtr, "%02X", memory[sRecAddr++]);
          sRecPtr += 2;
          sRecData++;
          dataCount++;
        }
        // Add checksum and byte count to record
        finish(sRecord, sRecData + byteCount + 1);
        oFile << sRecord;       // save it to file
      }

      // all data written
      // Write out a S7 record and close the file
      sprintf(sRecord, "S7  %08X", StrToInt(str + Form1->startAddress->EditText));
      finish(sRecord, 5);
      oFile << sRecord;
      oFile.close();
    }
  }
  catch( ... ) {
    ShowMessage("Error saving S-Record file.");
    return;
  }
}

//---------------------------------------------------------------------------
// add checksum and byte count to S-Record
void finish(char *sRec, int bytes)
{
  try {
    char checksum = 0;
    AnsiString str = "0x";
    char byteC[3];

    // Fill in the byte count
    sRec += 2;                          // point to byte count location
    sprintf(byteC, "%02X", bytes);
    strncpy(sRec, byteC, 2);

    for (int i=0; i<bytes; i++) {
      str = "0x";
      str += *sRec++;
      str += *sRec++;
      checksum += (char) (StrToInt(str) & 0xFF);
    }
    sprintf(sRec, "%02X\n", (~checksum & 0xFF));    //put checksum in sRecord
  }
  catch( ... ) {
    ShowMessage("Error creating S-Record.");
    return;
  }
}
