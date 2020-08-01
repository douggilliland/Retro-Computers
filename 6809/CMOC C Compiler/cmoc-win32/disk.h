/*  disk.h - Support for use of CoCo Disk Basic

    By Pierre Sarrazin <http://sarrazip.com/>.
    This file is in the public domain.

    Version 0.1.1 - Fall 2017 - Now uses uint32_t (unsigned long).
    Version 0.2.0 - January 2018 - MUST now call initdisk() first.
                                   This file does not call sbrk() anymore.
*/

#include "coco.h"
#include "assert.h"


// MUST be called before any other functions of this file.
// newFATBuffer: Must be a non-null pointer to an area of MAX_NUM_GRANULES bytes.
// Returns 1 on success, 0 on failure.
// 
byte initdisk(byte newFATBuffer[]);


// DSKCON operation codes.
//
#define DSKCON_READ  2
#define DSKCON_WRITE 3


byte findDirEntry(char *dirEntry, char *filename);
byte *updateFAT();
byte computeFileLength(uint32_t dwLength, byte firstGran, word numBytesLastSector);
void rewind(struct FileDesc *fd);
word getGranuleLength(byte *fat, byte granule, word numBytesLastSector);
byte *getCurrentlyAvailableBytes(struct FileDesc *fd, word *numAvailBytes);
void advanceOffset(struct FileDesc *fd, word numBytes);
byte getNextSector(struct FileDesc *fd);
void granuleToTrack(byte granule, byte *track, byte *sec);
byte isLastSectorOfFile(struct FileDesc *fd);
void normalizeFilename(char *dest, char *src);


#ifdef _COCO_BASIC_

// operation: DSKCON operation code
// dest: non null pointer to a 256-byte region.
// drive: 0..3.
// track: 0..34.
// sector: 1..18 (sic).
// Returns TRUE for success, FALSE for failure.
//
byte dskcon(byte operation, byte *buffer, byte drive, byte track, byte sector)
{
    //printf("- dskcon(%u, 0x%04x, %u, %u, %u)\n", operation, buffer, drive, track, sector);
    if (operation != DSKCON_READ && operation != DSKCON_WRITE)
        return FALSE;
    if (buffer == 0)
        return FALSE;
    if (drive >= 4)
        return FALSE;
    if (track >= 35)
        return FALSE;
    if (sector == 0)
        return FALSE;
    if (sector > 18)
        return FALSE;

    // Fill DSKCON input variables.
    * (byte *) 0x00EA = operation;  // DCOPC
    * (byte *) 0x00EB = drive;      // DCDRV
    * (byte *) 0x00EC = track;      // DCTRK
    * (byte *) 0x00ED = sector;     // DCSEC
    * (word *) 0x00EE = buffer;       // DCBPT

    asm("PSHS", "U,Y,X,A");  // protect against BASIC routine
    asm("JSR", "[$C004]");  // call DSKCON
    asm("PULS", "A,X,Y,U");

    return (* (byte *) 0x00F0) == 0;  // zero in DCSTA means success
}


#else  /* ndef _COCO_BASIC_ */


byte dskcon(byte operation, byte *buffer, byte drive, byte track, byte sector)
{
    //printf("- dskcon(%u, 0x%04x, %u, %u, %u)\n", operation, buffer, drive, track, sector);
    if (operation != DSKCON_READ && operation != DSKCON_WRITE)
        return FALSE;
    if (buffer == 0)
        return FALSE;
    if (drive >= 4)
        return FALSE;
    if (track >= 35)
        return FALSE;
    if (sector == 0)
        return FALSE;
    if (sector > 18)
        return FALSE;

    // Fill input variables of simulated DSKCON routine.
    byte *dskConUSimVars = (byte *) 0xFF04;
    dskConUSimVars[1] = drive;   // DCDRV
    dskConUSimVars[2] = track;   // DCTRK
    dskConUSimVars[3] = sector;  // DCSEC
    * (word *) (dskConUSimVars + 4) = buffer;  // DCBPT

    // Specifying the operation code causes the simulated DSKCON routine to run
    // (and block the execution).
    //
    dskConUSimVars[0] = operation;  // DCOPC: DSKCON read operation code

    return !dskConUSimVars[6];  // zero in DCSTA means success
}


#endif  /* ndef _COCO_BASIC_ */


byte readDiskSector(byte *dest, byte drive, byte track, byte sector)
{
    return dskcon(DSKCON_READ, dest, drive, track, sector);
}


byte writeDiskSector(byte *src, byte drive, byte track, byte sector)
{
    return dskcon(DSKCON_WRITE, src, drive, track, sector);
}


struct FileDesc
{
    byte drive;
    byte firstGran;  // 0..67
    word numBytesLastSector;  // 0..256
    uint32_t length;  // length of file
    byte curGran;  // 0..67, 255 means at EOF
    byte curSec;  // 1..9 (relative to current granule)
    word curGranLen;  // 0..GRANULE_SIZE
    uint32_t offset;  // reading offset
    word secOffset;  // 0..256: index into curSector[] (256 means beyond sector)
    byte curSector[256];
    word curSectorAvailBytes;  // number valid bytes in curSector[] (0..256)
};


#define MAX_NUM_GRANULES 68

byte curDriveNo = 0;
byte *fatBuffer = 0;  // will point to an array of MAX_NUM_GRANULES entries
byte fatUpToDate = FALSE;  // when TRUE, fatBuffer[] does not need to be reloaded


byte initdisk(byte newFATBuffer[])
{
    fatBuffer = newFATBuffer;
    return 1;
}


// CAUTION: As of version 0.2.0 of this file, initdisk() MUST have been called
//          before calling this or any other function of this file.
//          Otherwise, a call to openfile() will fail.
//          To force users of this file to be aware of the change, function open()
//          has been renamed to openfile().
//
// Initializes a file descriptor with the given filename.
// The filename must not contain a drive specification
// (the drive used is the one set by setDefautlDriveNo()).
// Filename search is not case sensitive.
// Period must be used as extension separator.
// Filenames do not have to be padded to 8 characters,
// nor extensions to 3.
// fileDesc must point to a 3-byte region.
// Returns 1 upon success, 0 upon failure (*fd is then undefined).
// close() must be called with fileDesc to release the
// underlying resources.
//
byte openfile(struct FileDesc *fd, const char *filename)
{
    if (fd == 0 || filename == 0 || fatBuffer == 0)
        return 0;  // invalid arguments, or initdisk() not called
    //printf("- openfile(0x%x, %s): fd->curSector=0x%x\n", fd, filename, fd->curSector);
    assert(fd->curSector != 0);

    char dirEntry[16];
    if (!findDirEntry(dirEntry, filename))
        return 0;  // file not found

    byte *fat = updateFAT();
    if (!fat)
        return 0;

    byte firstGran = dirEntry[13];
    word numBytesLastSector = * (word *) (dirEntry + 14);

    fd->drive = curDriveNo;
    fd->firstGran = firstGran;
    fd->numBytesLastSector = numBytesLastSector;
    computeFileLength(fd->length, fd->firstGran, fd->numBytesLastSector);

    rewind(fd);

    return 1;
}


void rewind(struct FileDesc *fd)
{
    if (fd == 0)
        return;  // invalid arguments

    byte *fat = updateFAT();
    if (!fat)
        return;

    fd->curGran = fd->firstGran;
    fd->curSec = 1;
    fd->curGranLen = getGranuleLength(fat, fd->firstGran, fd->numBytesLastSector);
    fd->offset = 0;
    fd->secOffset = 0;
    fd->curSectorAvailBytes = 0;
}


// Reads the current drive's FAT and returns the address of the
// internal buffer that contains it.
//
// Returns 0 if the FAT buffer pointer is null.
// Reads the FAT sector the first time, but not the following times,
// unless fatUpToDate is reset to 0.
//
// All accesses to the FAT must use the pointer returned by this function.
//
byte *updateFAT()
{
    if (fatUpToDate)
        return fatBuffer;

    if (!fatBuffer)
        return (byte *) 0;

    byte fatSector[256];
    if (!readDiskSector(fatSector, curDriveNo, 17, 2))
    {
        //printf("updateFAT: failed to read FAT of drive %u\n", curDriveNo);
        return (byte *) 0;
    }

    memcpy(fatBuffer, fatSector, MAX_NUM_GRANULES);
    fatUpToDate = TRUE;
    return fatBuffer;
}


// Returns 0 upon success, -1 upon failure.
// 'fd' allows to be null; nothing done then, and 1 is returned.
//
sbyte close(struct FileDesc *fd)
{
    return 0;
}


// Returns number of bytes read.
//
word read(struct FileDesc *fd, char *buf, word numBytesRequested)
{
    //printf("- read(%u bytes): start: offset=$%04x%04x, secOffset=$%04x, curGran=%2u\n",
    //        numBytesRequested, fd->offset[0], fd->offset[1], fd->secOffset, fd->curGran);
    if (fd == 0)
        return 0;
    if (buf == 0)
        return 0;
    if (numBytesRequested == 0)
        return 0;

    char *bufStart = buf;
    for (;;)
    {
        word numAvailBytes;
        byte *availBytes = getCurrentlyAvailableBytes(fd, &numAvailBytes);
        //printf("- read: AVAIL=%u, $%x\n", numAvailBytes, availBytes);

        if (numAvailBytes >= numBytesRequested)  // enough to finish request
        {
            memcpy(buf, availBytes, numBytesRequested);
            buf += numBytesRequested;
            advanceOffset(fd, numBytesRequested);
            //printf("- read: enough to finish request: %p - %p\n", buf, bufStart);
            return buf - bufStart;
        }

        // Currently loaded sector not enough.

        if (numAvailBytes > 0)
        {
            //printf("- read: delivering %u avail bytes\n", numAvailBytes);
            memcpy(buf, availBytes, numAvailBytes);  // send what we currently have
            buf += numAvailBytes;
            numBytesRequested -= numAvailBytes;
            advanceOffset(fd, numAvailBytes);
        }

        if (!getNextSector(fd))  // if reached EOF
        {
            //printf("- read: reached EOF: %p - %p\n", buf, bufStart);
            return buf - bufStart;
        }
    }
}


enum { GRANULE_SIZE = 2304 };


// newPos: 2-word position in bytes.
// Returns 0 for success, -1 for failure.
//
sbyte seek(struct FileDesc *fd, uint32_t newPos)
{
    //printf("\n- seek(at %lu): start\n", newPos);
    if (fd == 0)
        return -1;

    // If requested position is beyond end of file, clamp requested position.
    //
    if (newPos > fd->length)
    {
        //printf("- seek: clamping\n");
        newPos = fd->length;
    }

    // Compute granule index by dividing newPos by GRANULE_SIZE.
    // The granule index is relative to logical file contents,
    // it is not an index into the FAT.
    //
    byte granIndex = 0;
    uint32_t pos = newPos;
    //printf("- seek: before while: pos=%lu granIndex=%2u\n", pos, granIndex);
    while (pos >= GRANULE_SIZE)
    {
        ++granIndex;
        pos -= GRANULE_SIZE;
        //printf("- seek:      pos=%lu granIndex=%2u\n", pos, granIndex);
    }

    // Here, pos[1] is the offset in the last granule.
    word offsetInLastGranule = (word) pos;
    assert(offsetInLastGranule < GRANULE_SIZE);

    // Determine the granule (0..67) from granIndex and the FAT.
    //
    byte *fat = updateFAT();
    if (!fat)
        return -1;
    byte gran = fd->firstGran;
    //printf("- seek: granIndex=%u, offsetInLastGranule=%u, gran=%u\n",
    //        granIndex, offsetInLastGranule, gran);
    for ( ; granIndex; --granIndex)
    {
        assert(gran < 0xC0);  // not supposed to be the last granule
        gran = fat[gran];
    }
    assert(gran >= 0 && gran < MAX_NUM_GRANULES);
    fd->curGran = gran;

    // Determine the sector (1..9) inside granule 'gran'.
    //
    fd->curSec = (byte) ((offsetInLastGranule >> 8) + 1);
    assert(fd->curSec >= 1 && fd->curSec <= 9);

    // Determine the current granule's length in bytes.
    //
    fd->curGranLen = getGranuleLength(fat, gran, fd->numBytesLastSector);

    fd->secOffset = offsetInLastGranule & 0xFF;

    fd->curSectorAvailBytes = 0;

    fd->offset = newPos;
    //printf("- seek: %u %u %u %lu %u %u\n",
    //        fd->curGran, fd->curSec, fd->curGranLen,
    //        fd->offset, fd->secOffset,
    //        fd->curSectorAvailBytes);

    return 0;  // success
}


byte *getCurrentlyAvailableBytes(struct FileDesc *fd, word *numAvailBytes)
{ 
    //printf("- getCurrentlyAvailableBytes: start: %u, %u\n",
    //        fd->secOffset, fd->curSectorAvailBytes);

    if (fd->curSectorAvailBytes == 0)
    {
        // This is the state after a seek. secOffset can be 0..256.
        //
        *numAvailBytes = 0;
        return (byte *) 0;
    }

    assert(fd->secOffset <= fd->curSectorAvailBytes);

    byte *availBytes = (byte *) fd->curSector + fd->secOffset;

    *numAvailBytes = fd->curSectorAvailBytes - fd->secOffset;

    //printf("- getCurrentlyAvailableBytes: %u at 0x%x\n", *numAvailBytes, availBytes);
    return availBytes;
}


void advanceOffset(struct FileDesc *fd, word numBytes)
{
    fd->offset += numBytes;
    fd->secOffset += numBytes;

    //printf("- advanceOffset: now 0x%04x%04x\n", fd->offset[0], fd->offset[1]);
    assert(fd->secOffset <= fd->curSectorAvailBytes);

    if (fd->secOffset >= fd->curSectorAvailBytes)  // if reached end of available bytes
    {
        // Declare 'fd' to be empty of available bytes.
        // This will force another read.
        //
        fd->secOffset = 0;
        fd->curSectorAvailBytes = 0;
    }
}


// Returns true if sector successfully read, false otherwise.
//
byte getNextSector(struct FileDesc *fd)
{
    //printf("- getNextSector: start: curGran=%u, curSec=%u\n",
    //        fd->curGran, fd->curSec);
    if (fd->curGran == 0xFF)  // if at EOF
    {
        //printf("- getNextSector: EOF\n");
        return 0;
    }

    byte track;
    byte sec;
    granuleToTrack(fd->curGran, &track, &sec);
    if (!readDiskSector(fd->curSector, fd->drive, track, sec + fd->curSec))
        return 0;

    // Sector read successfully.
    // Determine how many bytes in it are part of the file.
    //
    if (isLastSectorOfFile(fd))
        fd->curSectorAvailBytes = fd->numBytesLastSector;
    else
        fd->curSectorAvailBytes = 256;

    // Determine number of sectors in current granule that are
    // part of the file (1..9).
    //
    byte *fat = updateFAT();
    if (!fat)
        return 0;
    byte g = fat[fd->curGran];
    byte numSectorsCurGran;
    if (g >= 0xC1)
        numSectorsCurGran = g - 0xC0;
    else
        numSectorsCurGran = 9;

    //printf("- getNextSector: sector has %u, g=%2u, gran has %u\n",
    //        fd->curSectorAvailBytes, g, numSectorsCurGran);

    // Advance sector index. Go to next granule if needed.
    //
    ++fd->curSec;
    if (fd->curSec > numSectorsCurGran)  // if current granule finished
    {
        if (g >= 0xC1)  // if current granule is last
            fd->curGran = 0xFF;  // marks file descriptor as at EOF, for next call
        else
        {
            fd->curSec = 1;
            fd->curGran = g;
        }
    }
    //printf("- getNextSector: end: curGran=%u, curSec=%u\n", fd->curGran, fd->curSec);
    return 1;
}


// Output:
// *track: 0..16, 18..34.
// *sec: 0 or 9.
//
void granuleToTrack(byte granule, byte *track, byte *sec)
{
    byte t = granule;
    asm("LSR", t);  // t = granule / 2
    if (t >= 17)  // if granule is after dir track
        asm("INC", t);
    byte s = granule;
    asm("ANDB", "#1");  // we assume that B still holds 's'
    asm("STB", s);
    if (s > 0)
        s = 9;

    *track = t;
    *sec = s;
}


byte isLastSectorOfFile(struct FileDesc *fd)
{
    byte *fat = updateFAT();
    if (!fat)
        return 1;  // hope that caller will stop using disk...
    byte g = fat[fd->curGran];
    if (g >= 0xC1)
        if (fd->curSec == g - 0xC0)
            return 1;
    return 0;
}


byte getFileLength(struct FileDesc *fd, uint32_t dwLengthInBytes)
{
    if (!fd)
    {
        dwLengthInBytes = 0;
        return FALSE;
    }

    return computeFileLength(dwLengthInBytes,
                             fd->firstGran, fd->numBytesLastSector);
}


//TODO: test this on file whose length is multiple of 256 bytes.
byte computeFileLength(uint32_t dwLength, byte firstGran, word numBytesLastSector)
{
    if (dwLength == 0)
        return FALSE;

    // Presume error:
    dwLength = 0xFFFFFFFFUL;

    if (firstGran > 67)
        return FALSE;
    if (numBytesLastSector > 256)
        return FALSE;

    byte *fat = updateFAT();
    if (!fat)
        return FALSE;

    byte curGran = fat[firstGran];
    dwLength = 0;
    while (curGran <= 0xC0)
    {
        dwLength += GRANULE_SIZE;
        curGran = fat[curGran];
    }

    word numBytesLastGran = curGran - 0xC1;  // for now, this is number of full sectors
    asm("LDD", numBytesLastGran);  // B = num full sectors, A = 0
    asm("EXG", "A,B");  // A = num full sectors, B = 0, i.e., D = num bytes in full sectors
    asm("STD", numBytesLastGran);
    numBytesLastGran += numBytesLastSector;

    dwLength += numBytesLastGran;  // add numBytesLastGran to dwLength[0]:dwLength[1]

    return TRUE;
}


word getGranuleLength(byte *fat, byte granule, word numBytesLastSector)
{
    if (fat == 0)
        return 0;
    if (granule < 0)
        return 0;
    if (granule > 67)
        return 0;

    byte entry = fat[granule];
    if (entry > 0xC9)
        return 0;  // free granule, or invalid FAT entry
    if (entry >= 0xC1)
        return ((word) entry - 0xC1) * 256 + numBytesLastSector;

    return GRANULE_SIZE;  // this entry points to a following granule, so 'granule' is full
}


// dirEntry: 16-byte region
//
byte findDirEntry(char *dirEntry, const char *filename)
{
    char normalizedFilename[12];
    normalizeFilename(normalizedFilename, filename);
    //printf("Normalized filename: '%s'\n", normalizedFilename);

    for (byte sector = 3; sector <= 18; ++sector)
    {
        byte dirSector[256];
        if (!readDiskSector(dirSector, curDriveNo, 17, sector))
            return 0;  // TODO: report I/O error instead of "not found"

        byte *entry;
        for (word index = 0; index < 256; index += 32)
        {
            entry = dirSector + index;
            if (!*entry)  // if erased entry
                continue;
            if (*entry == 0xFF)  // if end of dir
                break;

            if (memcmp(entry, normalizedFilename, 11) == 0)  // if filename matches
            {
                memcpy(dirEntry, entry, 16);
                return 1;  // found
            }
        }
        if (*entry == 0xFF)  // if end of dir
            break;
    }

    return 0;  // not found
}


// Normalizes the filename in 'src' into the 12-byte buffer
// designated by 'dest'.
// Expects period as extension separator in 'src'.
// Converts letters to upper case.
// Pads filename and extension with spaces.
// Writes 11 non-null characters to the destination buffer,
// followed by a terminating '\0' character.
//
void normalizeFilename(char *dest, const char *src)
{
    const char *reader = src;
    byte i;
    for (i = 0; i < 8; ++i)  // copy filename until period
    {
        if (*reader == '.')
        {
            ++reader;  // skip the point: it is not part of the extension
            break;
        }
        if (*reader == 0)
            break;
        *dest = (char) toupper(*reader);
        ++dest;
        ++reader;
    }
    if (i == 8)  // if filename is at least 8 chars long
    {
        // Check if filename too long.
        while (*reader != 0 && *reader != '.')
            ++reader;
        if (*reader == '.')  // skip the point
            ++reader;
    }
    else
        while (i < 8)  // pad filename with spaces
        {
            *dest++ = ' ';
            ++i;
        }
    for (i = 0; i < 3; ++i)  // copy extension
    {
        if (*reader == 0)
            break;
        *dest = (char) toupper(*reader);
        ++reader;
        ++dest;
    }
    while (i < 3)  // pad extension with spaces
    {
        *dest++ = ' ';
        ++i;
    }
    *dest = '\0';
}


byte getLastBasicDriveNo()
{
    #ifdef _COCO_BASIC_
    return * (byte *) 0xEB;
    #else
    return 0;
    #endif
}


byte setDefaultDriveNo(byte no)
{
    if (no > 3)
        return FALSE;
    curDriveNo = no;
    return TRUE;
}


#define getDefautlDriveNo() getDefaultDriveNo()  /* oops */


byte getDefaultDriveNo()
{
    return curDriveNo;
}
