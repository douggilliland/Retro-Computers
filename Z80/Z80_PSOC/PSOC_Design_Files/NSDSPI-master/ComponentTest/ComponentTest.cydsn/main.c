/* ========================================
 * Example project for NSDSPI component.
 * DMA - capable SD card interface with FatFS
 * Filesystem integrated as GCC Cortex M3
 * library. Intended for PSoC 5 series
 *
 * Performs read/write benchmarks and writes
 * results to SD card (BACKUP SD CARD FIRST
 * IF YOU HAVE IMPORTANT FILES ON IT! I
 * cannot promise this won't scramble your
 * SD card!)
 *
 * This example shows how to start component
 * and filesystem, how to enable DMA mode,
 * and how to read / write files.
 * See FatFS online documentation for more
 * information regarding the FatFS API
 * http://elm-chan.org/fsw/ff/00index_e.html
 *
 * ========================================
*/
/*---------------------------------------------------------------------------/
/ FatFs module is a free software that opened under license policy of
/ following conditions.
/
/ Copyright (C) 2015, ChaN, all right reserved.
/
/ 1. Redistributions of source code must retain the above copyright notice,
/    this condition and the following disclaimer.
/
/ This software is provided by the copyright holder and contributors "AS IS"
/ and any warranties related to this software are DISCLAIMED.
/ The copyright owner or contributors be NOT LIABLE for any damages caused
/ by use of this software.
/---------------------------------------------------------------------------*/

#include <project.h>
#include "string.h"

volatile unsigned long nmillis = 0; //used for time measurement

void MillisISR()
{
    nmillis++;          //used for time measurements
    disk_timerproc();   //MUST attach this to 1kHz interrupt for file system timeouts to work
}

void SDCARD_FAST()
{
    SD_CLK_SetDivider(3); //This should work even at 79.5 MHz clock, giving (79.5/5) MHz bitrate
    //this can push up to 10.6 Mbps reads in my tests so far, and 5.3 Mbps writes (possibly faster depending on SD card)
}

void SDCARD_SLOW()
{
    SD_CLK_SetDivider(200);   //SD card must be initialised at max. 400 kHz
}

void PrintFxn(char* pString)
{
    //Only used for test purposes! If you attach this to a print routine for your system,
    //you should see output when you run the function: scan_files()
    //e.g.
    //  char path[512];     //create buffer
    //  sprintf(path, "/"); //set to root path
    //  scan_files(path);   //run scan_files to test that the card seems to be working by listing files
}

#define BUFFER_SIZE 16000   //Test buffer size. This will be read/written

int main()
{
    CyGlobalIntEnable;              //Enable interrupts
    
    MillisecISR_StartEx(MillisISR); //start millisec ISR
    
    NSDSPI_Start(SDCARD_SLOW, SDCARD_FAST, PrintFxn);   //Initialise SD card and file system (note: PrintFxn can be NULL)
    
    
    FATFS FileSys;          //this will be our mounted file system
    disk_initialize(0);     //initialise FatFS

    //and mount. Note: if/else and case statements below allow identification of status. 
    //in this example, I just assume everything went ok, and have left the below for reference.
    FRESULT nRes;
    if((nRes = f_mount(&FileSys, "/", 1)) != FR_OK) //Fail to mount...
    {
        switch(nRes)    //reasons...
        {
            case FR_INVALID_DRIVE: break;
            case FR_DISK_ERR: break;
            case FR_NOT_READY: break;
            case FR_NO_FILESYSTEM: break;
            default: break;
        }
    }

    else    //Mounted
    {
        switch(FileSys.fs_type) //In case filesys type is of interest
        {
            case FS_FAT12: break;
            case FS_FAT16: break;
            case FS_FAT32: break;
            default: break;
        }
    }    
    
    //Now for the benchmarking step...
    NSDSPI_SetDMAMode(0);    
   
    //Open a file and write "Testing Output" to it
    FIL File;
    f_open(&File, "//test.txt", FA_CREATE_ALWAYS | FA_WRITE);
    char tmpchr[100];
    UINT BytesWritten, BytesRead;
    sprintf(tmpchr, "Testing Speed\n");
    f_write(&File, tmpchr, strlen(tmpchr), &BytesWritten);

    //generate dataset...
    double vals[BUFFER_SIZE/sizeof(double)];
    double i = 0;
    for(i = 0; i < BUFFER_SIZE/sizeof(double); i++)
    {
        vals[(int)i] = i*i;
    }

    
    //First, we'll write the dataset to a file in the root direcory, time the operation, then
    //output results to test.txt in the SD card root.
    
    //Indicate in test.txt what we're doing
    sprintf(tmpchr, "Writing %d bytes to file, non-DMA\n", BUFFER_SIZE);
    f_write(&File, tmpchr, strlen(tmpchr), &BytesWritten);

    //perform operation
    unsigned long nCurrentMillis = nmillis; //get current millisecond count
    FIL BinFile;
    f_open(&BinFile, "//binarray.bin", FA_CREATE_ALWAYS | FA_WRITE);
    f_write(&BinFile, vals, BUFFER_SIZE, &BytesWritten);
    f_close(&BinFile);
    
    //indicate in test.txt how long it took
    unsigned long nTime = nmillis-nCurrentMillis;
    sprintf(tmpchr, "Took %lu ms\n", nTime);
    f_write(&File, tmpchr, strlen(tmpchr), &BytesWritten);
    
    unsigned long kbps = BUFFER_SIZE*8 / nTime;
    sprintf(tmpchr, "Rate %lu kbps\n\n", kbps);
    f_write(&File, tmpchr, strlen(tmpchr), &BytesWritten);
    
    //Next, read file in
    
    //Indicate in test.txt what we're doing
    sprintf(tmpchr, "Reading %d bytes to file, non-DMA\n", BUFFER_SIZE);
    f_write(&File, tmpchr, strlen(tmpchr), &BytesWritten);

    //perform operation
    nCurrentMillis = nmillis; //get current millisecond count
    
    f_open(&BinFile, "//binarray.bin", FA_OPEN_EXISTING | FA_READ);
    f_read(&BinFile, vals, BUFFER_SIZE, &BytesRead);
    f_close(&BinFile);
    
    //indicate in test.txt how long it took
    nTime = nmillis-nCurrentMillis;
    sprintf(tmpchr, "Took %lu ms\nVerifying...", nTime);
    f_write(&File, tmpchr, strlen(tmpchr), &BytesWritten);
    
    unsigned char bVerifyFail = 0;
    for(i = 0; i < 500; i++)
    {
        if(vals[(int)i] != i*i) bVerifyFail = 1;
    }
    if(bVerifyFail)
        sprintf(tmpchr, "FAIL :O\n");       
    else
        sprintf(tmpchr, " All Good! :D\n");               
    f_write(&File, tmpchr, strlen(tmpchr), &BytesWritten);

    kbps = BUFFER_SIZE*8 / nTime;
    sprintf(tmpchr, "Rate %lu kbps\n\n", kbps);
    f_write(&File, tmpchr, strlen(tmpchr), &BytesWritten);

    //Now, enable DMA...
    NSDSPI_SetDMAMode(1);
    
    //and repeat tests
    //Indicate in test.txt what we're doing
    sprintf(tmpchr, "Writing %d bytes to file, DMA\n", BUFFER_SIZE);
    f_write(&File, tmpchr, strlen(tmpchr), &BytesWritten);

    //perform operation
    nCurrentMillis = nmillis; //get current millisecond count
    f_open(&BinFile, "//binarrayDMA.bin", FA_CREATE_ALWAYS | FA_WRITE);
    f_write(&BinFile, vals, BUFFER_SIZE, &BytesWritten);
    f_close(&BinFile);
    
    //indicate in test.txt how long it took
    nTime = nmillis-nCurrentMillis;
    sprintf(tmpchr, "Took %lu ms\n", nTime);
    f_write(&File, tmpchr, strlen(tmpchr), &BytesWritten);
    
    kbps = BUFFER_SIZE*8 / nTime;
    sprintf(tmpchr, "Rate %lu kbps\n\n", kbps);
    f_write(&File, tmpchr, strlen(tmpchr), &BytesWritten);
    //Next, read file in
    
    //Indicate in test.txt what we're doing
    sprintf(tmpchr, "Reading %d bytes to file, DMA\n", BUFFER_SIZE);
    f_write(&File, tmpchr, strlen(tmpchr), &BytesWritten);

    //perform operation
    nCurrentMillis = nmillis; //get current millisecond count
    
    f_open(&BinFile, "//binarrayDMA.bin", FA_OPEN_EXISTING | FA_READ);
    f_read(&BinFile, vals, BUFFER_SIZE, &BytesRead);
    f_close(&BinFile);
    
    //indicate in test.txt how long it took
    nTime = nmillis-nCurrentMillis;
    sprintf(tmpchr, "Took %lu ms\nVerifying...", nTime);
    f_write(&File, tmpchr, strlen(tmpchr), &BytesWritten);
    
    bVerifyFail = 0;
    for(i = 0; i < 500; i++)
    {
        if(vals[(int)i] != i*i) bVerifyFail = 1;
    }
    if(bVerifyFail)
        sprintf(tmpchr, "FAIL :O\n");       
    else
        sprintf(tmpchr, " All Good! :D\n");               
    f_write(&File, tmpchr, strlen(tmpchr), &BytesWritten); 
    
    kbps = BUFFER_SIZE*8 / nTime;
    sprintf(tmpchr, "Rate %lu kbps\n\n", kbps);
    f_write(&File, tmpchr, strlen(tmpchr), &BytesWritten);

    f_close(&File);

    
    for(;;)
    {
        /* done. */
    }
}

/* [] END OF FILE */
