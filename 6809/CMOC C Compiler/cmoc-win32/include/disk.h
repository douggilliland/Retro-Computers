/*  disk.h - Support for read-only files under CoCo Disk Basic

    For read and write operations, see the decbfile library on the CMOC page.

    By Pierre Sarrazin <http://sarrazip.com/>.
    This file is in the public domain.

    Version 0.1.1 - Fall 2017 - Now uses uint32_t (unsigned long).
    Version 0.2.0 - January 2018 - MUST now call initdisk() first.
                                   This file does not call sbrk() anymore.
*/

#ifndef _H_disk
#define _H_disk

#ifndef _COCO_BASIC_
#error This header file defines functions that only work on the CoCo.
#endif

#include "coco.h"
#include "assert.h"


// MUST be called before any other functions of this file.
// newFATBuffer: Must be a non-null pointer to an area of MAX_NUM_GRANULES bytes.
// Returns 1 on success, 0 on failure.
// 
byte initdisk(byte newFATBuffer[]);


enum
{
    // DSKCON operation codes.
    //
    DSKCON_READ = 2,
    DSKCON_WRITE = 3,

    MAX_NUM_GRANULES = 68,
    GRANULE_SIZE = 2304,
};


// operation: DSKCON operation code
// dest: non null pointer to a 256-byte region.
// drive: 0..3.
// track: 0..34.
// sector: 1..18 (sic).
// Returns TRUE for success, FALSE for failure.
//
byte dskcon(byte operation, byte *buffer, byte drive, byte track, byte sector);


byte readDiskSector(byte *dest, byte drive, byte track, byte sector);


byte writeDiskSector(byte *src, byte drive, byte track, byte sector);


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



extern byte curDriveNo;
extern byte *fatBuffer;  // will point to an array of MAX_NUM_GRANULES entries
extern byte fatUpToDate;  // when TRUE, fatBuffer[] does not need to be reloaded


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
// For read and write operations, see the decbfile library on the CMOC page.
//
byte openfile(struct FileDesc *fd, const char *filename);


void rewind(struct FileDesc *fd);


// Reads the current drive's FAT and returns the address of the
// internal buffer that contains it.
//
// Returns 0 upon failure to allocate memory or to read the FAT sector.
// Reads the FAT sector the first time, but not the following times,
// unless fatUpToDate is reset to 0.
//
// All accesses to the FAT must use the pointer returned by this function.
//
byte *updateFAT();


// Returns 0 upon success, -1 upon failure.
// 'fd' allowed to be null (0 is returned).
//
sbyte close(struct FileDesc *fd);


// Returns number of bytes read.
//
word read(struct FileDesc *fd, char *buf, word numBytesRequested);


// newPos: 2-word position in bytes.
// Returns 0 for success, -1 for failure.
//
sbyte seek(struct FileDesc *fd, uint32_t newPos);


byte *getCurrentlyAvailableBytes(struct FileDesc *fd, word *numAvailBytes);


void advanceOffset(struct FileDesc *fd, word numBytes);


// Returns true if sector successfully read, false otherwise.
//
byte getNextSector(struct FileDesc *fd);


// Output:
// *track: 0..16, 18..34.
// *sec: 0 or 9.
//
void granuleToTrack(byte granule, byte *track, byte *sec);


byte isLastSectorOfFile(struct FileDesc *fd);


// Upon success, stores the file length in bytes in *pLength and returns TRUE.
//
byte getFileLength(struct FileDesc *fd, uint32_t *pLength);


byte computeFileLength(uint32_t *pLength, byte firstGran, word numBytesLastSector);


word getGranuleLength(byte *fat, byte granule, word numBytesLastSector);


// dirEntry: 16-byte region
//
byte findDirEntry(char *dirEntry, const char *filename);


// Normalizes the filename in 'src' into the 12-byte buffer
// designated by 'dest'.
// Expects period as extension separator in 'src'.
// Converts letters to upper case.
// Pads filename and extension with spaces.
// Writes 11 non-null characters to the destination buffer,
// followed by a terminating '\0' character.
//
void normalizeFilename(char *dest, const char *src);


byte getLastBasicDriveNo();


byte setDefaultDriveNo(byte no);


#define getDefautlDriveNo() getDefaultDriveNo()  /* oops */


#define getDefaultDriveNo() (curDriveNo)


#endif  /* _H_disk */
