













      SYSLIB -- An Integrated Library of Assembly Language
  Utility Subroutines for use with the Microsoft M80 Assembler


                               by
                          Richard Conn




                         2 November 1982











    The SYSLIB Library is Copyrighted, 1982, by Richard Conn

.he                 SYSLIB User and Reference Manual
.fo Table of Contents                                  TOC - #
.pn 1

      SYSLIB -- An Integrated Library of Assembly Language
  Utility Subroutines for use with the Microsoft M80 Assembler

                        Table of Contents

     Alphabetical Listing of SYSLIB Routines
     Functional Listing of SYSLIB Routines

 1.0 Introduction                                       1
     1.01 What is SYSLIB?
     1.02 What is Needed to Use SYSLIB?
     1.03 What Does SYSLIB Buy Me?
     1.04 How Do I Assemble with SYSLIB?
     1.05 How Do I Learn to Use SYSLIB Effectively?
     1.06 Who May Use SYSLIB?

 2.0 Directory Manipulation Routines                    6
     2.01 Introduction
     2.02 Generalized Routines -- DIRF and DIRFS
     2.03 Buffer Allocation Routine -- DBUFFER
     2.04 Disk Parameter Extraction Routine -- DPARAMS
     2.05 Free Space Computation Routine -- DFREE
     2.06 File Size Computation Routine -- FSIZE
     2.07 Directory Load Routines -- DIRLOAD and DIRSLOAD
     2.08 Directory Alphabetization Routine -- DIRALPHA
     2.09 Directory Entry Selection Routine -- DIRSEL
     2.10 Directory Pack Routine -- DIRPACK
     2.11 Negative Directory Pack Routine -- DIRNPACK

 3.0 Numeric String Evaluation Routines                15
     3.01 Evaluation of String in All Bases -- EVAL
     3.02 Evaluation of String in Base 16 -- EVAL16
     3.03 Evaluation of String in Base 10 -- EVAL10
     3.04 Evaluation of String in Base  8 -- EVAL8
     3.05 Evaluation of String in Base  2 -- EVAL2

 4.0 Byte-Oriented File Input/Output Routines          18
     4.01 Intro to Byte-Oriented File I/O Routines
     4.02 Byte-Oriented Input and Output File Open
     4.03 Byte-Oriented Input and Output File Close
     4.04 Byte-Oriented Input and Output
     4.05 Error Return Codes











            Table of Contents Continued on Next PageŠ
      SYSLIB -- An Integrated Library of Assembly Language
  Utility Subroutines for use with the Microsoft M80 Assembler

                  Table of Contents, Continued

 5.0 CP/M File Input/Output Routines                   23
     5.01 Introduction
     5.02 Open a File - F$OPEN and F$MOPEN
     5.03 Close a File - F$CLOSE
     5.04 Create a File - F$MAKE
     5.05 Delete a File - F$DELETE
     5.06 Rename a File - F$RENAME
     5.07 Test for the Existance of a File - F$EXIST
     5.08 Read a Block from a File - F$READ
     5.09 Write a Block to a File - F$WRITE

 6.0 File Name String Parser and FCB Init              28

 7.0 Input Line Editors                                30

 8.0 String Output Routines                            34

 9.0 Numeriã Outpuô Routineó                           35
      9.01 Output HL as 4 Hexadecimal Characters
      9.02 Output HL as 5 Decimal Characters
      9.03 Output HL as Up to 5 Decimal Characters
               with Leading Spaces
      9.04 Output A as 2 Hexadecimal Characters
      9.05 Output A as 3 Decimal Characters
      9.06 Output A as Up to 3 Decimal Characters
               with Leading Spaces

10.0 String and Value Comparison Routines              40

11.0 Character-Oriented Input/Output Routines          42
     11.01 <CR> <LF> Output
     11.02 Conditional Input
     11.03 General Input Routines
     11.04 General Output Routines

12.0 Math Routines                                     45
     12.01 Introduction
     12.02 Arithmetic Operations
     12.03 Complement Operations
     12.04 Rotate and Shift Operations
     12.05 Logical Operations

13.0 CRC Routines                                      49

14.0 Random Number Generator Routines                  52

15.0 User/Disk Manipulation Routines                   54

            Table of Contents Continued on Next PageŠ
      SYSLIB -- An Integrated Library of Assembly Language
  Utility Subroutines for use with the Microsoft M80 Assembler

                  Table of Contents, Continued


16.0 Sort Routines                                     56

17.0 ZCPR2 Feature-Specific Routines                   58

18.0 ZCPR2-Specific Named Directory Routines           63

19.0 Misãellaneous Routines                            66

20.0 Cross-Reference Listing of SYSLIB Routines        72

21.0 Sample Programs Using SYSLIB                      76
     21.01 The Classic File Dump Program
     21.02 Byte-Oriented File Input Demonstration
     21.03 Directory Access Demonstration
     21.04 Math Demonstration
     21.05 Sort Demonstration
     21.06 Random Number Generator Demonstration
     21.07 ZCPR2-Specific Function Demonstration


.pn 1
.fo Alphabetical Listing of SYSLIB Routines            AList - #


      SYSLIB -- An Integrated Library of Assembly Language
  Utility Subroutines for use with the Microsoft M80 Assembler

             Alphabetical Listing of SYSLIB Routines


A    ADDHD     45   |    ANDHD     48

B    BBLINE    31   |    BIOS      67
     BDOS      67   |    BLINE     31


C    CAPS      68   |    COMPB     40   |    CRC1K     51
     CAPSTR    68   |    COMPBC    40   |    CRC1UPD   50
     CATH      69   |    COMPHD    40   |    CRCCLR    50
     CCOUT     44   |    CONDIN    42   |    CRCDONE   50
     CIN       43   |    COUT      43   |    CRCK      51
     CLOUT     44   |    CPOUT     44   |    CRCUPD    50
     CMPH      46   |    CRC1CLR   50   |    CRLF      42
     CODEND    69   |    CRC1DONE  50   |    CST       43

D    DBUFFER    8   |    DIRFS      7   |    DIRSEL    12
     DFREE      9   |    DIRLOAD   11   |    DIRSLOAD  11
     DIRALPHA  12   |    DIRNPACK  14   |    DIVHD     46
     DIRF       7   |    DIRPACK   13   |    DPARAMS    9

E    EN        69   |    EVAL16    16
     EVAL      15   |    EVAL2     17
     EVAL10    16   |    EVAL8     17

F    F$CLOSE   24   |    F$OPEN    23
     F$DELETE  25   |    F$READ    27
     F$EXIST   26   |    F$RENAME  26
     F$MAKE    25   |    F$WRITE   27
     F$MOPEN   24

     Fn$GET    21   |    FILLBC    70
     Fn$PUT    21   |    FNAME     28
     FIn$CLOSE 20   |    FOn$CLOSE 20
     FIn$OPEN  19   |    FOn$OPEN  20
     FILLB     70   |    FSIZE     10

G    GETUD     55

H    HFILB     70   |    HMOVB     71
     HFILBC    70   |    HMOVBC    71

I    INITFCB   29   |    INSTR     41
     INLINE    32

                 Listing Continued on Next Page

         Alphabetical Listing of SYSLIB Routines, Con't

L    LA2HC     37   |    LHLDC     36
     LA3DC     38   |    LOGUD     55
     LADC      38   |    LOUT      43
     LCRLF     42   |    LPRINT    34
     LHL4HC    35   |    LPSTR     34
     LHL5DC    36

M    MA2HC     37   |    MHLDC     37
     MA3DC     38   |    MOVEB     71
     MADC      39   |    MOVEBC    71
     MHL4HC    35   |    MULHD     46
     MHL5DC    36

N    NEGH      46

O    ORHD      48

P    PA2HC     37   |    PHLDC     36
     PA3DC     38   |    POUT      43
     PADC      38   |    PRINT     34
     PAUSE     71   |    PSTR      34
     PHL4HC    35   |    PUTUD     54
     PHL5DC    36

R    RETUD     55   |    RND       53
     RIN       43   |    RNDINIT   52
     ROTLH     47   |    RNDSEED   52
     ROTRH     47

S    SCANNER   40   |    SORT      57
     SHFTLH    47   |    SSBINIT   57
     SHFTRH    48   |    SUBHD     45

X    XORHD     48

Z    ZCPRQ     60   |    ZFSTAT    62
     ZCPRSET   59   |    ZINIEXT   59
     ZDNFIND   64   |    ZINIMC    58
     ZFNAME    65   |    ZMCPTR    61
     ZFNINIT   64   |    ZPFIND    61


.pn 1
.fo Functional Listing of SYSLIB Routines              FList - #


      SYSLIB -- An Integrated Library of Assembly Language
  Utility Subroutines for use with the Microsoft M80 Assembler

              Functional Listing of SYSLIB Routines

 2.0 Directory Manipulation Routines -  6
     DIRF, DIRFS: 7  DBUFFER: 8  DPARAMS: 9
     DFREE: 9        FSIZE: 10   DIRLOAD, DIRSLOAD: 11
     DIRALPHA: 12    DIRSEL: 12  DIRPACK: 13  DIRNPACK: 14

 3.0 Numeric String Evaluation Routines - 15
     EVAL: 15  EVAL16: 16  EVAL10: 16  EVAL8: 17  EVAL2: 17

 4.0 Byte-Oriented File Input/Output Routines (0-n-3) - 18
     FIn$OPEN: 19   FOn$OPEN: 20   FIn$CLOSE: 20
     FOn$CLOSE: 20  Fn$GET: 21     Fn$PUT: 21

 5.0 CP/M File Input/Output Routines - 23
     F$OPEN: 23     F$MOPEN: 24    F$CLOSE: 24    F$MAKE: 25
     F$DELETE: 25   F$RENAME: 26   F$EXIST: 26    F$READ: 27
     F$WRITE: 27

 6.0 File Name String Parser and FCB Init - 28
     FNAME: 28      INITFCB: 29

 7.0 Input Line Editors - 30
     BBLINE: 31     BLINE: 31      INLINE: 32

 8.0 String Output Routines - 34
     PRINT, LPRINT: 34        PSTR, LPSTR: 34

 9.0 Numeriã Outpuô Routineó - 35
     PHL4HC¬ LHL4HCº 35  MHL4HCº 35  PHL5DC¬ LHL5DCº 36
     MHL5DCº 36     PHLDC, LHLDC: 36    MHLDC: 37
     PA2HC, LA2HC: 37    MA2HC: 37      PA3DC, LA3DC: 38
     MA3DC: 38   PADC, LADC: 38      MADC: 39

10.0 String and Value Comparison Routines - 40
     COMPHD: 40   COMPB, COMPBC: 40  SCANNER: 40  INSTR: 41

11.0 Character-Oriented Input/Output Routines - 42
     CRLF, LCRLF: 42     CONDIN: 42     CST: 43
     CIN, RIN: 43        COUT, LOUT, POUT: 43
     CCOUT, CLOUT, CPOUT: 44






                 Listing Continued on Next Page


          Functional Listing of SYSLIB Routines, Con't

12.0 Math Routines - 45
     ADDHD: 45      SUBHD: 45      MULHD: 46      DIVHD: 46
     NEGH: 46       CMPH: 46       ROTLH: 47      ROTRH: 47
     SHFTLH: 47     SHFTRH: 48     ANDHD: 48      ORHD: 48
     XORHD: 48

13.0 CRC Routines - 49
     CRCCLR, CRC1CLR: 50      CRCUPD, CRC1UPD: 50
     CRCDONE, CRC1DONE: 50    CRCK, CRC1K: 51

14.0 Random Number Generator Routines - 52
     RNDINIT: 52    RNDSEED: 52    RND: 53

15.0 User/Disk Manipulation Routines - 54
     PUTUD: 54      GETUD: 55      LOGUD: 55      RETUD: 55

16.0 Sort Routines - 56
     SSBINIT: 57    SORT: 57

17.0 ZCPR2 Feature-Specific Routines - 58
     ZINIMC: 58     ZINIEXT: 59    ZCPRSET: 59    ZCPRQ: 60
     ZMCPTR: 61     ZPFIND: 61     ZFSTAT: 62

18.0 ZCPR2-Specific Named Directory Routines - 63
     ZFNINIT: 64    ZDNFIND: 64    ZFNAME: 65

19.0 Misãellaneous Routines - 66
     BDOS: 67       BIOS: 67       CAPS: 68
     CAPSTR: 68     CATH: 69       CODEND: 69
     EN: 69         FILLB, FILLBC, HFILB, HFILBC: 70
     MOVEB, MOVEBC, HMOVB, HMOVBC: 71   PAUSE: 71

