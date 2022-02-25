*-----------------------------------------------------------
* Title         : FileIO
* Written by    : Chuck Kelly
* Date Created  : December-2-2004
* Description   : Demonstrate file I/O in EASy68K
* Modification  : Oct-18-2008 by CK
* Dec-25-2012 by CK, Uses SIMHALT
*-----------------------------------------------------------
    ORG     $800
START
    lea     filename,a1
    move    #52,d0          open new file
    trap    #15

    lea     data,a1         data to write
    move    #datasize,d2    # bytes to write
    move    #54,d0          write to file
    trap    #15

    move    #0,d2           file position
    move    #55,d0
    trap    #15

    lea     buffer,a1
    move    #datasize,d2    # bytes to read
    move    #53,d0          read from file
    trap    #15

    move    #50,d0
    trap    #15             close all files

    lea     filename,a1
    move    #57,d0          delete file
    trap    #15

    SIMHALT                 Halt Simulator

filename    dc.b    'test1.txt',0
data        dc.b    'this is a test'
            dc.b    1,2,3,4,5,6,7,8,9,0
datasize    equ     *-data
buffer      ds.b    80

    END     START



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
