












      SYSLIB -- An Integrated Library of Assembly Language
  Utility Subroutines for use with the Microsoft M80 Assembler

                   User's Guide for SYSLIB 2.3

                               by
                          Richard Conn




                   Revision B of User's Guide


                        14 December 1982





     Thió User'ó Guide“ ió á supplemenô tï thå SYSLIÂ 2.3 Useò anä 
Referencå Manual¬ dateä 14 December 1982.








    The SYSLIB Library is Copyrighted, 1982, by Richard Conn

.he                    User's Guide for SYSLIB 2.3
.pn 1
.fo Table of Contents                             TOC - #


      SYSLIB -- An Integrated Library of Assembly Language
  Utility Subroutines for use with the Microsoft M80 Assembler

                   User's Guide for SYSLIB 2.3


                        Table of Contents

     1.0 Introduction and Purpose of the User's Guide  1
         1.01 What is SYSLIB?                          1
         1.02 SYSLIB Documentation                     2

     2.0 SYSLIB Output, Math, and Some Misc Routines   3
         2.01 Printing Stuff with SYSLIB               3
         2.02 Math with SYSLIB                        10
         2.03 Some Miscellaneous Routines             11
         2.04 The CODEND Routine                      14

     3.0 SYSLIB Input Line Editors                    16
         3.01 What Is an Input Line Editor?           16
         3.02 The BDOS-Based Input Line Editors       16
         3.03 The INLINE Input Line Editor            18
  
     4.0 SYSLIB Disk Input/Output                     19
         4.01 Directory Manipulation Routines         20
         4.02 Block-Oriented File Input/Output        28
         4.03 Byte-Oriented File Input/Output         29
         4.04 File Control Block (FCB) Manipulation   31
         4.05 ZCPR2-Specific Functions                33
               Multiple Commands and SYSLIB           36
               External Paths and SYSLIB              37
               Named Directories and SYSLIB           44

     5.0 Numeric String Evaluation, CRC Check, and
               Sort Routines                          48
         5.01 Numeric String Evaluation               48
         5.02 Cyclic Redundancy Checking              50
         5.03 The SYSLIB Sort Routines                51
   
     6.0 What is SYSLIB?  SYSLIB Overview             54
         6.01 Functional Overview of SYSLIB           54
         6.02 SYSLIB Documentation and Files and
              SYSLIB Availability                     56
         6.03 Distribution Statement for SYSLIB       56

.pn 1
.fo Alphabetical Listing of SYSLIB Routines            AList - #


      SYSLIB -- An Integrated Library of Assembly Language
  Utility Subroutines for use with the Microsoft M80 Assembler

             Alphabetical Listing of SYSLIB Routines


A    ADDHD     10   |    ANDHD     10

B    BBLINE    16   |    BIOS      11
     BDOS      11   |    BLINE     16

C    CAPS      11   |    COMPB     13   |    CRC2CLR   50
     CAPSTR    11   |    COMPBC    13   |    CRC2DONE  50
     CATH      11   |    COMPHD    13   |    CRC2UPD   50
     CCOUT      3   |    CONDIN     4   |    CRCCLR    50
     CIN        3   |    COUT       3   |    CRCDONE   50
     CLINE     11   |    CPOUT      3   |    CRCUPD    50
     CLOUT      3   |    CRC1CLR   50   |    CRLF       3
     CMPH      10   |    CRC1DONE  50   |    CST        4
     CODEND    14   |    CRC1UPD   50

D    DBUFFER   20   |    DIRFS     27   |    DIRSEL    23
     DFREE     28   |    DIRLOAD   22   |    DIRSLOAD  22
     DIRALPHA  25   |    DIRNPACK  24   |    DIVHD     10
     DIRF      27   |    DIRPACK   24   |    DPARAMS   21

E    EN        11   |    EVAL16    48
     EVAL      48   |    EVAL2     48
     EVAL10    48   |    EVAL8     48

F    F$CLOSE   28   |    F$OPEN    28
     F$DELETE  28   |    F$READ    28
     F$EXIST   28   |    F$RENAME  28
     F$MAKE    28   |    F$WRITE   28
     F$MOPEN   28

     Fn$GET    30   |    FILLBC    12
     Fn$PUT    30   |    FNAME     31
     FIn$CLOSE 30   |    FOn$CLOSE 30
     FIn$OPEN  30   |    FOn$OPEN  30
     FILLB     12   |    FSIZE     28

G    GETUD     41

H    HFILB     12   |    HMOVB     12
     HFILBC    12   |    HMOVBC    12

I    INITFCB   31   |    INSTR     13
     INLINE    18

                 Listing Continued on Next Page

         Alphabetical Listing of SYSLIB Routines, Con't

L    LA2HC      6   |    LHLDC      6
     LA3DC      6   |    LOGUD     41
     LADC       6   |    LOUT       3
     LCRLF      3   |    LPRINT     4
     LHL4HC     6   |    LPSTR      4
     LHL5DC     6

M    MA2HC      9   |    MHLDC      9
     MA3DC      9   |    MOVEB     12
     MADC       9   |    MOVEBC    12
     MHL4HC     9   |    MULHD     10
     MHL5DC     9

N    NEGH      10

O    ORHD      10

P    PA2HC      6   |    PHLDC      6
     PA3DC      6   |    POUT       3
     PADC       6   |    PRINT      4
     PAUSE     12   |    PSTR       4
     PHL4HC     6   |    PUTUD     41
     PHL5DC     6

R    RETUD     41   |    RND       13
     RIN        3   |    RNDINIT   13
     ROTLH     10   |    RNDSEED   13
     ROTRH     10

S    SCANNER   13   |    SORT      52
     SHFTLH    10   |    SSBINIT   52
     SHFTRH    10   |    SUBHD     10

V    VERSION   12

X    XORHD     10

Z    ZCPRQ     43   |    ZGPINS    43
     ZCPRQ2    43   |    ZINICI    42
     ZDNAME    45   |    ZINIDMA   42
     ZDNFIND   46   |    ZINIEXT   40
     ZFNAME    47   |    ZINIMC    36
     ZFNINIT   45   |    ZMCPTR    36
     ZFSTAT    43   |    ZPFIND    40

.fo 1 - Introduction                                   Page #
.pn 1
      SYSLIB -- An Integrated Library of Assembly Language
  Utility Subroutines for use with the Microsoft M80 Assembler

                   User's Guide for SYSLIB 2.3

1.0  Introduction

1.01 What is SYSLIB?

     SYSLIÂ (SYSteí LIBrary© ió á collectioî oæ oveò 13°  subrou
tineó whicè arå designeä tï providå tï thå CP/Í 8080/Z8° assemblù 
languagå  programmeò  á seô oæ functionó upoî whicè hå caî  builä 
hió programs®  Thió librarù ió intendeä tï relievå thå programmeò 
oæ thå tasë oæ frequentlù "reinventinç thå wheel¢ anä tï  providå 
hií witè á tooì environmenô whicè encourageó structureä programm
inç aô thå assemblù languagå level.

     Eacè  subroutinå  withiî SYSLIÂ caî bå vieweä aó á  reliablå 
"blacë box.¢  Thå subroutineó iî SYSLIÂ arå completelù documenteä 
withiî  thå SYSLIÂ Useò anä Referencå Manuaì foò  SYSLIÂ  Versioî 
2.3¬  thå  companioî documenô tï thió guide¬  anä thå SYSLIBx.HLĞ 
files®   Thå programmeò ió consistentlù provideä witè thå follow
inç informatioî oî eacè subroutinå withiî SYSLIB:

          1.  Name of Subroutine
          2.  Function it performs
          3.  What its inputs are
          4.  What its outputs are
          5.  What registers are affected by it
          6.  What other library routines it calls upon
          7.  What errors can occur and how it handles them

     Thå routineó withiî SYSLIÂ arå designeä tï worë togetheò anä 
complemenô eacè other®   Parameteò passinç ió consistenô  betweeî 
thå variouó subroutines®   Foò instance¬  alì routineó whicè neeä 
tï  bå  passeä á pointeò tï á Filå Controì Blocë arå passeä  thaô 
pointeò iî thå DÅ registeò pair®   Also¬  aó á generaì rule¬ iæ á 
registeò ió noô returneä aó aî outpuô froí thå SYSLIÂ subroutine¬ 
theî  itó valuå ió noô affecteä (iô haó thå samå valuå  wheî  thå 
routine is exited as it had when the routine was called).

     SYSLIÂ  itselæ  ió á librarù oæ relocatablå  objecô  moduleó 
createä  iî  thå Microsofô M8° relocatablå  objecô  format®   Alì 
subroutineó withiî SYSLIÂ arå groupeä withiî functionally-relateä 
modules®   Oncå  á routinå ió referenceä (bù thå EXÔ statemenô iî 
thå M8° assemblù languagå program)¬  itó modulå ió loadeä anä  iô 
ió  availablå  tï thå programmeò bù meanó oæ á simplå  subroutinå 
call®   Alì  otheò subroutineó withiî thaô particulaò modulå  arå 
alsï loaded¬  buô theù arå noô availablå tï thå programmeò unlesó 
hå  haó alsï referenceä theí bù EXÔ statements®   Thå  modulå  ió 
loadeä  onlù  once¬  regardlesó oæ ho÷ manù routineó  withiî  thå 
modulå  arå referenced®   Foò thió reason¬  É havå designeä  eacè 
modulå  tï contaiî routineó whicè arå frequentlù useä togetheò oò 
arå  calleä  bù eacè otheò (onå routinå withiî thå  modulå  calló 
anotheò routinå withiî thå module).Š1.02 SYSLIB Documentation

     Thå followinç documentó arå associateä witè SYSLIÂ --

          ï SYSLIÂ Useò anä Referencå Manuaì foò SYSLIÂ Version
               2.3“ bù Richarä Conn¬ 14 Decembeò 1982, 112+ pages
               (I occasionally refer to this as SYSLIB User and
                Reference Manual)

          ï  User'ó Guidå foò SYSLIÂ 2.3“ bù Richarä Conn¬ 14 
               December 1982, 57+ pages

          o  SYSLIBx.HLP files by Richard Conn
               (SYSLIB.HLP, SYSLIB1.HLP-SYSLIB9.HLP,
                SYSLIBA.HLP-SYSLIBC.HLP)

     Thå  SYSLIÂ Useò anä Referencå Manuaì foò SYSLIÂ Versioî 2.3“  
ió  divideä intï 2± chapters®   Thió documenô provideó aî  intro
ductioî  tï SYSLIB¬  explaininç whaô iô ió anä whaô iô  buyó  thå 
user¬  anä  theî  proceedó tï describå alì oæ thå SYSLIÂ  subrou
tines¬ groupeä bù function¬ iî detail®  Thå lasô chapteò containó 
seveî samplå programó whicè uså SYSLIB¬  anä iô showó thå  sourcå 
listinç oæ theså programs¬  thå assemblù process¬ anä runó oæ thå 
programs.

     Thå  SYSLIBx.HLĞ  fileó arå intendeä tï bå  useä  aó  onlinå 
referencå  manualó foò SYSLIB®   Thå HELĞ commanä giveó thå  useò 
accesó tï thå contentó oæ thå HLĞ fileó iî aî indexeä manner¬  sï 
thå  useò maù quicklù identifù thå routinå hå needó anä determinå 
ho÷ tï uså it®   Thå informatioî iî thå SYSLIÂ Useò anä Referencå 
Manuaì  foò SYSLIÂ Versioî 2.3“ oî thå SYSLIÂ subroutineó ió  dup
licateä iî theså HLĞ files.

     Thió ió thå User'ó Guidå foò SYSLIÂ 2.3®   Iô ió designeä tï 
bå  useä  aó aî instructionaì supplemenô tï thå SYSLIÂ  Useò  anä 
Referencå  Manuaì foò SYSLIÂ Versioî 2.3®   Thå Referencå  Manuaì 
presentó  thå  "harä facts¢ oî thå SYSLIÂ subroutines¬  anä  thió 
User'ó  Guidå  presentó thå philosophù behinä thå desigî  oæ  thå 
SYSLIÂ subroutineó anä aî explanatioî oæ ho÷ theù arå intendeä tï 
interacô witè eacè otheò anä worë togetheò tï providå á flexible¬ 
powerfuì  tooì  seô foò thå assemblù  languagå  programmer®   Thå 
Referencå  Manuaì ió jusô thaô -- á booë tï refeò tï iî ordeò  tï 
answeò  specifiã questionó abouô thå detailó oæ thå  SYSLIÂ  rou
tines®  Thå User'ó Guide¬ oî thå otheò hand¬ ió á tutorial.




.fo 2 - SYSLIB Output, Math, and Some Misc Routines    Page #

2.0 SYSLIB Output, Math, and Some Misc Routines

2.01 Printing Stuff Using SYSLIB

     Á  paiò oæ SYSLIÂ Subroutineó perforí á simplå functioî  foò 
thå  programmeò  anä havå nï neô effecô oî anù registeró  whatso
ever®   Hence¬ theù caî bå useä aô wilì withouô anù concerî what
soeveò oî sidå effects®  Thió paiò oæ routineó includes:

          o CRLF   -- Output CR LF to the Console
          o LCRLF  -- Output CR LF to the LST: Device

     Thå  paiò oæ SYSLIÂ Subroutineó jusô discusseä  ió  probablù 
thå  simplesô oæ thå entirå library®   Nexô tï theí iî complexitù 
arå thå singlå characteò input/outpuô routines:

          o CIN     -- Input Character from Console in A
          o RIN     -- Input Character from Reader in A

          o COUT    -- Output Character in A to Console
          o LOUT    -- Output Character in A to LST: Device
          o POUT    -- Output Character in A to PUN: Device

          o CCOUT   -- Output Character in A to Console with
                         Control Character Processing
          o CLOUT   -- Output Character in A to LST: Device with
                         Control Character Processing
          o CPOUT   -- Output Character in A to PUN: Device with
                         Control Character Processing

     Notå  thaô  theså routines¬  likå  alì  SYSLIÂ  subroutines¬ 
perforí  exactlù  thå  functioî aó documenteä anä  nothinç  else®  
CIN¬ foò example¬ onlù inputó á character¬ anä doeó noô echï thió 
character.  To input and then echo a character, a sequence like

          CALL CIN  ; input ch
          CALL COUT ; echo ch

woulä  bå  used®   Onlù thå Á registeò ió affecteä bù  thå  inpuô 
routines¬ anä nï registeò ió affecteä bù thå outpuô routines.

     Thå  outpuô  routineó caî outpuô characteró witè oò  withouô 
controì characteò processing®  Thå routineó whicè procesó controì 
characteró wilì outpuô characteró likå control-Ã (binarù 3© aó ^Ã 
anä thå routineó whicè dï noô dï sucè processinç woulä outpuô thå 
exact binary code.


     Thå Consolå Statuó routine¬  CST¬  returnó thå statuó oæ thå 
consolå iî registeò A¬  sayinç iæ á keù haó beeî presseä oò  not®  
Iæ  datá  ió  available¬  A=0®   Iô woulä typicallù  bå  useä  aó 
follows:

          CALL CST  ; get status
          ORA  A    ; see if A=0
          JNZ  NOIN ; routine to process if no input
          CALL CIN  ; get character and process

     Thå   Conditionaì  Inpuô  routine¬   CONDIN¬   provideó  thå 
functionó  jusô describeä iî á somewhaô simpleò anä  morå  usefuì 
form®   CONDIÎ  wilì  samplå  thå consolå inpuô  anä  returî  thå 
characteò iæ onå ió availablå witè á flaç sayinç thaô á characteò 
ió returned®  Iæ á characteò ió noô available¬ CONDIÎ wilì simplù 
returî  witè thå appropriatå flag®   Thå samå routinå implementeä 
using CONDIN looks like this:

          CALL CONDIN    ; get conditional input
          JZ   NOIN      ; routine to process if no input
          ...            ; process char in A from CONDIN

     Aó  thå readeò caî see¬  wå alreadù havå takeî á  nicå  steğ 
forwarä  froí conventionaì assemblù languagå programminç  withouô 
thå uså oæ á librarù likå SYSLIB®  É thinë thaô simplå character-
orienteä input/outpuô ió handleä nicelù now¬ anä thå nexô logicaì 
steğ ió tï outpuô á grouğ oæ characteró easily®   Thió ió donå bù 
the print routines:

          o PRINT   -- Print String Pointed to by Return Address
                         on Console
          o LPRINT  -- Print String Pointed to by Return Address
                         on LST: Device

          o PSTR    -- Print String Pointed to by HL on Console
          ï LPSTÒ   -- Prinô Strinç Pointeä tï bù HÌ oî LSTº 
                         Device

     Thió  ió thå firsô introductioî oæ thå concepô oæ á  string®  
Iî thå SYSLIÂ terminology¬  á string“ ió á sequencå oæ  characteró 
terminateä  bù á binarù 0®   Thå programmeò coulä definå á strinç 
iî thå followinç ways:

          DB   'This is a string',0
          DB   0dh,0ah,'This is another string',0dh,0ah,0

     PRINÔ  anä LPRINÔ prinô stringó pointeä tï bù  theiò  returî 
addresses¬  anä theù returî tï thå bytå followinç thå strinç theù 
just printed.  They would typically be used as follows:

          CALL PRINT     ; Print the following string
          DB   'This is a test',0
          ...            ; Continue processing
Š     PSTÒ  anä  LPSTÒ  requirå thaô HÌ pointó tï á  valiä  strinç 
before they are called.  An example of the use of PSTR is:

          LXI  H,MYNAME  ; point to string
          CALL PSTR      ; print it
          ...            ; continue processing
MYNAME:   DB   'Rick',0  ; string to be printed

     Warningº   PSTÒ anä LPSTÒ affecô thå HÌ registeò pair®  Upoî 
exit¬  HÌ  pointó  tï thå bytå followinç thå  indicateä  strings®  
Theså  routineó  werå  designeä  iî  thió  waù  tï  easilù  allo÷ 
successive calls to them to print one string after another:

          LXI  H,LIST    ; point to first string
          MVI  B,0       ; init counter
LOOP:     MOV  A,M       ; get first character
          ORÁ  Á         » checë tï seå iæ lisô enä (nexô ch=0)
          JZ   DONE      ; continue processing
          INR  B         ; increment count
          MOV  A,B       ; get count
          CALL PADC      ; print number
          MVI  A,' '     ; print space
          CALL COUT
          CALL PSTR      ; print string
          CALL CRLF      ; print new line
          JMP  LOOP      ; continue until end of list
DONE:                    ; continue processing
          ...
LIST:
          DB   'Rick',0       ; first name in list
          DB   'Olivia',0     ; second name in list
          DB   'Carolyn',0    ; third name in list
          DB   0         ; end of list

     The output from this code segment will be:

  1 Rick
  2 Olivia
  3 Carolyn

     Thió examplå ió intendeä tï drivå severaì keù pointó homå tï 
the reader:
          1®   SYSLIÂ routineó arå designeä tï perforí á functioî 
anä havå minimaì sidå effects®   Notå thaô thå Â registeò ió useä 
aó á counteò iî thió routine¬ anä É don'ô savå iô anywhere®  Nonå 
of these SYSLIB routines have any effect on B.
          2®   SYSLIÂ routineó arå designeä tï bå cohesive®  Theù 
"bonä together¢ tï forí á functionaì modulå anä maù bå calleä onå 
after the other to collectively provide a function for the user.
          3®   SYSLIÂ  haó  beeî designeä tï eliminatå á  loô  oæ 
overheaä iî assemblù languagå programming®  Imaginå ho÷ mucè morå 
oæ  á programminç tasë iô woulä bå iæ yoõ haä tï writå  thå  PADÃ 
(Print A as Decimal Characters with Leading Spaces) routine.

     Which leads us into the next set of routines ...Š     Á  numbeò oæ SYSLIÂ routineó arå designeä tï outpuô  numberó 
tï  thå  user®   Botè  8-biô numberó anä 16-biô  numberó  maù  bå 
output¬  anä  iî  alì cases¬  thå Á registeò containó  thå  8-biô 
numbeò  tï  outpuô anä thå HÌ registeò paiò containó  thå  16-biô 
number to output.  These routines are:

          o PADC, LADC        -- Print the number in the A
                                   register as up to 3 digits in
            PADC = Print           a 3-character field.  If 3
                   A as            significant digits are not
                   Decimal         required (there are leading
                   Characters      zeroes), print spaces in their
            LADC = List            places.  PADC prints to the
                   A as D.C.       Console, LADC prints to the
                                   LST: Device

          o PA3DC, LA3DC      -- Like PADC and LADC, but print
                                   3 digits, including the
            PA3DC = Print          leading zeroes
                    A as
                    3
                    Decimal
                    Characters

          o PA2HC, LA2HC      -- Like PA3DC and LA3DC, but print
                                   2 hexadecimal digits,
            PA2HC = Print          including the leading zeroes
                    A as
                    2
                    Hexadecimal
                    Characters

          o PHLDC, LHLDC      -- Print the number in the HL
                                   register pair as up to 5
            PHLDC = Print          digits in a 5-character
                    H and          field.  If 5 significant
                    L as           digits are not required
                    Decimal        (there are leading zeroes),
                    Characters     print spaces in their places.
                                   PHLDC prints to the Console,
                                   LHLDC prints to the LST:
                                   Device

          o PHL5DC, LHL5DC    -- Like PHLDC and LHLDC, but
                                   print 5 digits, including
            PHL5DC = Print         the leading zeroes
                     HL as
                     5 D.C.

          o PHL4HC, LHL5HC    -- Like PHL5DC and LHL5DC, but
                                   print 4 hexadecimal digits,
            PHL4HC = Print         including the leading zeroes
                     HL as
                     4 Hex Chars
Š     Nonå  oæ  theså  prinô  routineó havå  anù  effectó  oî  anù 
registers¡   Yoõ  maù uså theí freelù tï prinô ouô  values®   Thå 
followinç tableó providå exampleó oæ whaô outputó woulä looë likå 
from these routines:


                      8-Bit Numeric Outputs

A Register     PADC, LADC     PA3DC, LA3DC   PA2HC, LA2HC
----------     ----------     ------------   ------------
     0            __0             000             00
    16            _16             016             10
   100            100             100             64
   255            255             255             FF



                     16-Bit Numeric Outputs

HL Register    PHLDC, LHLDC   PHL5DC, LHL5DC   PHL4HC, LHL4HC
-----------    ------------   --------------   --------------
       0           ____0          00000             0000
      16           ___16          00016             0010
     100           __100          00100             0064
     256           __256          00256             0100
    4096           _4096          04096             1000
   16536           16536          16536             4000

Note: _ denotes a space.



     This sample code segment:

          LXI  H,100     ; set value

          CALL PRINT     ; print text
          DB   'HL = ',0

          CALL PHLDC     ; print HL as decimal chars

          CALL PRINT     ; print more text
          DB   ' Decimal or ',0

          CALL PHL4HC    ; print HL as hexadecimal chars

          CALL PRINT     ; print ending text
          DB   ' Hexadecimal',0

          ...

prints this text:

HL_=___100_Decimal_or_0064_Hexadecimal

     (Note: _ denotes a space)

     Thå  readeò caî seå thaô SYSLIÂ comeó througè again¬  makinç 
thå  joâ  nicå anä easy®   Notå thaô HÌ ió NOÔ  AFFECTEÄ  bù  thå 
numeriã  prinô  routineó (PHLDC¬  PHL4HC© oò bù thå strinç  prinô 
routinå (PRINT)®  Foò thaô matter¬ NÏ registeò ió affecteä bù thå 
calls to these routines.

     Thió  example¬  likå thå previouó example¬  ió  intendeä  tï 
drivå severaì keù pointó homå tï thå reader:

          1®   SYSLIÂ routineó arå designeä tï perforí á functioî 
anä havå minimaì sidå effects®

          2®   SYSLIÂ routineó arå designeä tï bå cohesive®  Theù 
"bonä together¢ tï forí á functionaì modulå anä maù bå calleä onå 
after the other to collectively provide a function for the user.

          3®   SYSLIÂ  haó  beeî designeä tï eliminatå á  loô  oæ 
overheaä iî assemblù languagå programming®

          4®   SYSLIÂ  routineó arå frequentlù nameä tï servå  aó 
mnemoniã  aidó iî ordeò tï helğ thå programmeò remembeò whaô  thå 
routinå does.


     Flexibilitù ió á keù worä foò SYSLIB¬  anä onå gooä questioî 
tï  asë ió whaô capabilitù doeó SYSLIÂ givå må tï outpuô mù  num
beró  iî anù waù É desirå (likå HÌ aó uğ tï ´ decimaì  characteró 
insteaä oæ 5)¿  Thå nexô seô oæ routineó solveó thió problem:

          o MADC    -- Place up to 3 ASCII digit characters
                         into memory which represent the number
          MADC = Memory  in the A register and use leading
                 (store) spaces.  The first byte of a three-
                 A as    byte memory buffer is pointed to by
                 Dec     the DE register pair.
                 Chars

          o MA3DC   -- Like MADC, but including leading zeroes

          o MA2HC   -- Like MA3DC, but hexadecimal digits

          o MHLDC   -- 5 ASCII digits characters stored in
                         memory to represent the value in HL

          o MHL5DC  -- Like MHLDC, but including leading zeroes

          o MHL4HC  -- Like MHL5DC, but hexadecimal digits


     Noteº   DÅ  ió affecteä bù theså  routines¡   Oî  entry¬  DÅ 
pointó  tï thå firsô bytå oæ thå buffeò useä tï storå thå desireä 
characters¬  and¬  oî exit¬ DÅ pointó tï thå firsô bytå afteò thå 
lasô  characteò stored®   Theså routineó arå seô uğ thió  waù  sï 
thaô  wholå stringó oæ texô caî bå sequentiallù storeä iî  memorù 
with some ease.

     Sample Code:

          LXI  D,NUM3    ; 3-byte buffer
          MVI  A,10      ; Number 10
          CALL MADC      ; Store in Buffer
          LXI  H,400     ; Number 400
          CALL MHLDC     ; Store in 5-byte buffer
          ...
NUM3:     DS   3         ; reserve 3 bytes
NUM5:     DS   5         ; reserve 5 bytes

     Results:

               Address   ASCII Char     Address   ASCII Char
               -------   ----------     -------   ----------
               NUM3        (space)      NUM5        (space)
               NUM3+1         1         NUM5+1      (space)
               NUM3+2         0         NUM5+2         4
                                        NUM5+3         0
                                        NUM5+4         0

2.02 Math with SYSLIB

     Matè  functionó arå particularlù easù witè  SYSLIB®   SYSLIÂ 
containó  á wholå modulå oæ 16-biô matè functionó whicè worë witè 
jusô thå HÌ registeò paiò iæ onlù onå argumenô ió requireä oò thå 
HÌ anä DÅ registeò pairó iæ twï argumentó arå necessary®   Iî alì 
cases, the HL register pair contains the final result.

     Followinç  thå  generaì philosophù oæ thå  SYSLIÂ  routines¬ 
theså matè functionó affecô ONLÙ thå HÌ registeò paiò anä havå nï 
effecô oî anù otheò registers¬  includinç thå Á registeò anä  thå 
condition code flags, unless so noted.

     The math functions provided in SYSLIB are:

          o ADDHD   HL = HL + DE
          o SUBHD   HL = HL - DE
          o MULHD   HL = HL * DE
          o DIVHD   HL = HL / DE

          o NEGH    HL = 2's Complement of HL
          o CMPH    HL = 1's Complement of HL

          o ANDHD   HL = HL (Logical AND) DE
          o ORHD    HL = HL (Logical OR) DE
          o XORHD   HL = HL (Logical XOR) DE

          o ROTLH   HL is Rotated Left one Bit
                         The old MSB is rotated into the LSB
          o ROTRH   HL is Rotated Right one Bit
                         The old LSB is rotated into the MSB
          o SHFTLH  HL is Shifted Left one Bit
                         The LSB becomes 0
          o SHFTRH  HL is Shifted Right one Bit
                         The MSB becomes 0

     Noteº   MSÂ  anä LSÂ refeò tï Mosô Significanô Biô anä Leasô 
Significant Bit, resp.

     Noteº   Erroò  Conditionó arå handleä iî á  logicaì  manner®  
Thå completå descriptionó oæ theså routineó founä iî thå Useò anä 
Referencå Manuaì anä thå SYSLIBx.HLĞ fileó exactlù statå whaô thå 
error conditions and return codes are.


2.03 Some Miscellaneous Routines

     Some miscellaneous routines contained within SYSLIB include:

          ï BDOÓ anä BIOÓ -- routineó tï allo÷ thå SYSLIÂ 
               programmeò tï directlù accesó thå CP/Í BDOÓ oò 
               BIOS with minimum effect on the registers

          o CAPS -- capitalize the character in the A register;
               if a <= A reg <= z, then the capital is returned,
               else no change; the Most Significant Bit of A is
               masked out in this process and ignored

          o CAPSTR -- capitalize the string pointed to by HL
               in place:

                    LXI  H,CSTR    ; point to string
                    CALL CAPSTR    ; capitalize it
                    ...
               CSTR: DB  'test',0  ; initial string

               results in:

               CSTR: DB  'TEST',0  ; resulting string


          o CATH -- Convert ASCII to Hexadecimal; if the
               register A contains any one of the following
               ASCII characters

                    '0'-'9', 'A'-'F', 'a'-'f'

               the representative hexadecimal value (binary
               0-F) is returned in A; if an error occurs,
               the number 20 Hex is returned

          o CLINE -- Save the command line pointed to by HL
               away in an internal buffer as a string.  The
               command line starts with a character count which
               is followed by the characters of the line.  This
               is exactly the format of the line returned by
               ZCPR2 in the buffer at 80H and by the BDOS Fct 10.
               CLINE is useful when you want to work with the
               linå aó á strinç anä noô havå tï worrù abouô 
               saving it from becoming garbaged by disk I/O.
               Also, CLINE returns a pointer to this line as
               a string terminated by a binary 0 (you don't
               have to worry about the character count).  HL
               points to the first character of this string.

          o EN -- Exchange Nybbles in the A register; the
               low-order 4 bits of A are switched with the
               high-order 4 bits of A
Š          o VERSION -- Return the Version Number of SYSLIB
               in the HL register pair

          o PAUSE -- Delay so many tenths of a second; inputs
               to this routine are the number of 1/10 secs
               to delay in HL and the speed of your processor
               in B

          o FILL Routines -- These routines serve to fill
               an area of memory pointed to by HL with a
               constant byte value contained in the A
               register; no registers are affected by
               FILLB and FILLBC, and only HL is affected
               by HFILB and HFILBC; the FILL Routines are:

                    FILLB -- number of bytes to fill
                         is in the B register
                    FILLBC -- number of bytes to fill
                         is in the BC register pair
                    HFILB -- like FILLB, but HL is
                         affected, and HL points to
                         the byte following the last
                         byte filled when done
                    HFILBC -- like FILLBC, but HL is
                         affected as in HFILB

          o MOVE Routines -- These routines copy a block of
               memory starting at the address contained in
               HL to another place in memory starting at the
               address contained in DE; these routines auto-
               matically determine if the move is forwards
               or backwards and compensate for any overlap;
               no registers are affected by MOVEB and MOVEBC,
               and HL and DE are affected by HMOVB and HMOVBC;
               the MOVE Routines are:

                    MOVEB -- number of bytes to move in
                         the B register
                    MOVEBC -- number of bytes to move in
                         the BC register pair
                    HMOVB -- like MOVEB, but HL and DE are
                         affected, pointing to after the
                         last byte copied in each block
                    HMOVBC -- like MOVEBC, but HL and DE
                         are affected as in HMOVB


          o Compare Routines -- These routines are used for
               various types of comparisons, including simple
               HL-to-DE comparison, fixed-length byte compare,
               and subgroup comparisons.  The compare routines
               are:
                    COMPHD -- Compare HL to DE; on return,
                         Zero Flag Set means HL=DE, Carry
                         Flag Set means HL<DE
                    COMPB and COMPBC -- Compare the group
                         of bytes pointed to by HL to the
                         group of bytes pointed to by DE;
                         the groups are of equal length,
                         being B bytes long for COMPB and
                         BC bytes long for COMPBC; on return,
                         Zero Flag Set means (HL)=(DE),
                         Carry Flag Set means (HL)<(DE)
                    SCANNER -- Scan the group of bytes
                         pointed to by HL to see if it
                         contains the group of bytes
                         pointed to by DE; the HL group
                         is B bytes long, and the DE
                         group is C bytes long; if found,
                         HL points to first byte of sub-
                         group and Zero Flag is Set (Z); if not
                         found, Zero Flag is Clear (NZ) and HL
                         is not affected
                    INSTR -- Scan the string pointed to by
                         HL for the string pointed to by DE;
                         if found, Zero Flag is Set (Z) and
                         HL points to first byte of substring

          o Random Number Generator Routines -- Two routines
               arå provideä tï initializå thå SYSLIÂ randoí num-
               beò generatoò anä onå routinå returnó aî 8-biô 
               randoí numbeò froí thå generator.  These routines
               are:
                    RNDINIT -- Enters a counting loop and waits
                         for a keypress from the user.  The count
                         value at the keypress sets the random
                         seed.
                    RNDSEED -- Allows the programmer to provide
                         a seed value.  This is input in the A
                         register.
                    RND -- Returns a random number in the A
                         register, and uses this number as the
                         seed value for the next call to RND.



2.04 The CODEND Routine

     Therå arå manù timeó wheî iô ió necessarù tï kno÷ wherå youò 
prograí  anä datá areaó enä anä thå beginninç oæ thå scratcè areá 
whicè extendó froí thå enä oæ youò program/datá areaó tï thå  enä 
oæ thå Transienô Prograí Areá (TPA© ió located®  Thå followinç ió 
á memorù mağ oæ thå situatioî described:

          Top of Memory       --------------------------
                              |  CP/M BIOS and Buffers |
                              --------------------------
                              |  CP/M BDOS             |
                            / --------------------------
                           /  |  CP/M CCP              |
                          /   --------------------------
                          T   |  Unused Memory Space   |
                          P   |  above your program    |
                          A   |  and its data areas    |
                          \   |    ----------------    |
                           \  |  Your Program          |
          100H              \ --------------------------
                              |  CP/M Buffers and JMPs |
          Bottom of Memory    --------------------------


     Thå  routinå  CODENÄ  iî SYSLIÂ provideó yoõ  witè  thå  enä 
addresó  oæ  youò  program/datá areaó anä thå  beginninç  oæ  thå 
Unuseä Memorù Spacå diagrammeä above®  CODENÄ ió á routinå locat
eä iî thå SCODEÎ modulå oæ SYSLIB¬  anä thió modulå ió ALWAYÓ thå 
lasô modulå iî thå library®   Durinç thå linkinç process¬  SYSLIÂ 
ió  tï bå thå lasô librarù specifieä tï L8° foò  thå  link¬  and¬ 
sincå SCODEÎ ió thå lasô modulå iî SYSLIB¬  iæ thå CODENÄ routinå 
ió referenceä bù thå program¬ theî iô wilì bå loaded¬ anä iô wilì 
ALWAYÓ  bå  thå lasô subroutinå iî youò program®   CODENÄ  simplù 
returnó  thå addresó oæ thå nexô pagå followinç thå lasô bytå  oæ 
code.

     Diagrammatically, the situation described looks like this:

          End of BDOS         --------------------------
                              | BDOS                   |
          Start of BDOS/      --------------------------
            End of Scratch    | Scratch Space for your |
                              | work area, as desired  |
     -->  Next Page After Pgm --------------------------
     |                        | Dead Space (Not Used)  |
     |    End of Your Program --------------------------
     |                        | CODEND Routine         |
     |                        --------------------------
     CODEND Returns This      | Other SYSLIB Routines  |
     Address                  --------------------------
                              | Your Program Code      |
          100H                --------------------------
Š
     Aó iî thå normaì CP/Í environment¬  thå baså oæ thå BDOÓ caî 
bå determineä bù loadinç thå addresó oæ thå BDOÓ calì aô locatioî 
5 into HL:

          LHLD 6    ; load address of BDOS call

Noteº  Aô locatioî µ ió á CALÌ instructioî (CALÌ Address)¬ sï thå 
desireä  Addresó  ió  aô locationó ¶ anä  7¬  low-ordeò  bytå  aô 
location 6.

     CODENÄ  caî  bå useä tï determinå thå starô oæ  thå  scratcè 
area¬  sï  thå followinç codå segmenô illustrateó á techniquå  tï 
determine the size of the scratch area.

     ;
     ;  SYSLIB EXTERNAL REFERENCES -- NOTE THAT ORDER OF THESE
     ;  EXT PSEUDO-OPS IS NOT IMPORTANT
     ;
               EXT  CODEND    ; CODEND ROUTINE
               EXT  SUBHD     ; HL=HL-DE
               EXT  PRINT     ; PRINT STRING
               EXT  PHLDC     ; PRINT HL AS UP TO 5 DEC CHARS
               ...
     ENTRY     EQU  5         ; BDOS ENTRY CALL
               ...
               CALL CODEND    ; GET ADDRESS IN HL
               XCHG           ; ... ADDRESS IN DE
               LHLD ENTRY+1   ; GET ADDRESS OF BDOS BASE
               MVI  L,0       ; SET ON PAGE BOUNDARY
               CALL SUBHD     ; HL=HL-DE (SIZE OF SCRATCH AREA)
               CALL PRINT
               DB   'The size of the scratch area is ',0
               CALL PHLDC     ; PRINT IN DECIMAL
               CALL PRINT
               DB   ' bytes',0
               ...

.fo 3 - SYSLIB Input Line Editors                      Page #

3.0 SYSLIB Input Line Editors

3.01 What is an Input Line Editor?

     Aî Inpuô Linå Editoò ió á routinå whicè ió verù  fundamentaì 
tï  mosô  user-interactivå programó anä timesharinç oò  dedicateä 
operatinç systems®  Thió routinå caî bå calleä bù aî applicationó 
prograí anä allo÷ thå useò tï enteò á linå oæ texô (whicè ió  whù 
É  calì iô á line“ editoò aó opposeä tï á filå editor© anä correcô 
hió typinç mistakeó aó hå goes.

     CP/Í  provideó thå useò witè aî inpuô linå editoò whicè  maù 
bå calleä bù BDOÓ Functioî 10®  Thió inpuô linå editoò ió useä bù 
thå  CP/Í Consolå Commanä Processoò (CCP© itself¬  anä  iô  comeó 
intï  plaù wheî thå A¾ (oò whateveò disk© prompô  appears®   Wheî 
thå useò typeó hió CP/Í command¬ hå ió withiî thå BDOÓ inpuô linå 
editor¬  and¬  aó  thå readeò ió probablù welì aware¬  hå haó thå 
abilitù  tï deletå thå previouó character¬  eraså thå wholå  linå 
anä starô oveò again¬  retypå thå linå aó entereä sï far¬  anä sï 
on.

     Thió  ió á verù importanô kinä oæ function¬  and SYSLIÂ con
tainó threå subroutineó whicè servå aó inpuô linå  editors®   Twï 
oæ  them¬  BLINÅ anä BBLINE¬  turî arounä anä calì thå BDOÓ inpuô 
linå  editoò  anä mainlù servå aó á shelì arounä thå  BDOÓ  inpuô 
linå editoò whicè preserveó registeró anä setó uğ  buffers®   Thå 
thirä inpuô linå editor¬  INLINE¬ ió á completå inpuô linå editoò 
iî itó owî right¬  anä iô ió intendeä tï bå useä wheî securitù ió 
important.


3.02 The BDOS-Based Input Line Editors

     Thå  twï  BDOS-Baseä inpuô linå editoró iî SYSLIÂ arå  BLINÅ 
anä BBLINE®   Theù diffeò mainlù iî thå waù theù handlå  buffers¬ 
and¬  iî  botè cases¬  theù returî witè HÌ pointinç tï thå  firsô 
characteò  oæ  thå  strinç inpuô bù thå useò anä thå  Á  registeò 
containinç  á  counô  oæ  thå numbeò  oæ  characteró  typeä  (noô 
countinç thå endinç zero)®   Notå thaô HÌ ió returneä aó á strinç 
pointer¬ anä thå inpuô linå ió storeä aó á NULL-terminateä strinç 
of characters in the standard SYSLIB sense.

     BBLINÅ  containó á 200-bytå buffeò internallù iî  whicè  thå 
linå tï bå inpuô ió stored®  Thió ió probablù thå mosô frequentlù 
useä  oæ  thå SYSLIÂ inpuô linå editoró sincå iô ió sï simplå  tï 
use®   Itó  onlù inpuô ió á flaç iî thå Á registeò -- iæ Á ió  0¬ 
thå inpuô linå ió noô capitalized¬  anä iæ Á ió noô 0¬  thå inpuô 
linå ió capitalized.  Example:


               EXT  BBLINE    ; Reference BBLINE
               EXT  PRINT     ; PRINT STRING ROUTINE
               EXÔ  PSTÒ      » PRINÔ STRINÇ PTEÄ TÏ BÙ HL
               ...
               CALL PRINT
               DB   'What Is Your Name? ',0
               XRA  A         ; A=0 SO DON'T CAPITALIZE LINE
               CALL BBLINE    ; GET LINE FROM USER
                              ; ON RETURN, HL PTS TO FIRST CHAR
                              ;   AND A IS NUMBER OF CHARS TYPED
               CALL PRINT
               DB   0DH,0AH   ; NEW LINE
               DB   'Your Name is: ',0
               CALL PSTR      ; PRINT STRING PTED TO BY HL
                              ; ... HL WAS SET BY BBLINE
               ...


     Thå BLINÅ routinå ió similaò tï BBLINE¬ witè thå onå differ
encå thaô thå useò provideó aî externaì buffer®  Thå onlù advant
agå oæ BLINÅ oveò BBLINÅ ió thaô iô ió smalleò (doeó noô  contaiî 
thaô 200-bytå buffer)¬ buô witè BLINÅ thå programmeò haó tï worrù 
abouô allocatinç buffeò space®  Thå samå prograí usinç BLINE:

               EXT  BLINE     ; Reference BLINE
               EXT  PRINT     ; PRINT STRING ROUTINE
               EXÔ  PSTÒ      » PRINÔ STRINÇ PTEÄ TÏ BÙ HL
               ...
               CALL PRINT
               DB   'What Is Your Name? ',0
               XRA  A         ; A=0 SO DON'T CAPITALIZE LINE
               LXI  H,INLINE  ; PT TO BUFFER
               CALL BLINE     ; GET LINE FROM USER
                              ; ON RETURN, HL PTS TO BUFF AND
                              ;   A IS NUMBER OF CHARS TYPED
               CALL PRINT
               DB   0DH,0AH   ; NEW LINE
               DB   'Your Name is: ',0
               CALL PSTR      ; PRINT STRING PTED TO BY HL
                              ; ... HL WAS SET BY BBLINE
               ...
     INLINE:   DB   40        ; SIZE OF BUFFER
               DB   0         ; RETURNED SIZE OF LINE
     BUFF:     DS   41        ; BUFFER SPACE + 1 FOR ENDING 0



3.03 The INLINE Input Line Editor

     INLINE¬  aó  mentioneä earlier¬  ió intendeä tï bå useä  foò 
securå  applications®   Iô  haó twï keù featureó whicè comå  intï 
play for such applications:

          1®   INLINÅ cannoô bå aborteä bù ^C»  thå ^Ã ió  simplù 
stored in the input line buffer if the user types it

          2®   INLINÅ  caî bå madå tï echï itó inpuô oò noô  echï 
itó input» iæ somethinç likå á passworä ió beinç entered¬ theî iô 
may be desirable not to echo the password back to the user


     INLINÅ  doeó  noô perforí optionaì capitalizatioî  likå  thå 
otheò two¬ and¬ iæ capitalizatioî ió required¬ thå CAPSTÒ routinå 
caî  bå useä immediatelù afteò thå calì tï INLINÅ tï correcô thió 
problem.

     Aó á tradeoff¬  INLINÅ takeó uğ morå spacå thaî eitheò BLINÅ 
oò BBLINE¬  anä thå useò stilì haó tï providå aî externaì buffer®  
INLINÅ wilì noô permiô morå thaî 25¶ characteró tï bå stored¬  sï 
the buffer size should generally be 256+1 for the ending 0.

     Foò inputs¬ INLINÅ requireó HÌ tï poinô tï thå firsô bytå oæ 
thå buffeò anä Á tï contaiî á ° iæ nï echï ió desireä oò noô ° iæ 
echï  ió desired®   Notå thaô INLINÅ requireó HÌ tï poinô tï  thå 
firsô  bytå oæ thå buffeò itself¬  anä NOÔ á buffeò  sizå  value®  
Thå examplå abovå implementeä witè INLINÅ lookó likå this:

               EXT  INLINE    ; Reference INLINE
               EXT  PRINT     ; PRINT STRING ROUTINE
               EXÔ  PSTÒ      » PRINÔ STRINÇ PTEÄ TÏ BÙ HL
               ...
               CALL PRINT
               DB   'What Is Your Password? ',0
               XRA  A         ; A=0 SO DON'T ECHO USER INPUT
               LXI  H,BUFF    ; PT TO BUFFER
               CALL INLINE    ; GET LINE FROM USER
                              ; ON RETURN, HL PTS TO BUFF
               CALL CAPSTR    ; CAPITALIZE INPUT STRING
               CALL PRINT
               DB   0DH,0AH   ; NEW LINE
               DB   'Your Password is: ',0
               CALL PSTR      ; PRINT STRING PTED TO BY HL
                              ; ... HL WAS SET BY BBLINE
               ...
     BUFF:     DS   257       ; BUFFER SPACE + 1 FOR ENDING 0

.fo 4 - SYSLIB Disk Input/Output                       Page #

4.0 SYSLIB Disk Input/Output

     SYSLIÂ  provideó á numbeò oæ convenienceó tï thå  programmeò 
wheî  iô comeó tï manipulatinç thå disë undeò CP/M®   Thå librarù 
provideó fivå groupó oæ utilitieó foò disë input/output:

          1.  Directory Manipulation Routines
               -- Allocate Buffer Space
               -- Extract Disk Parameter Information
               -- Determine Amount of Free Space on Disk
               -- Determine the Size of a Disk File
               -- Load a Disk Directory into Memory
               -- Alphabetize a Loaded Disk Directory
               -- Select Files from a Loaded Disk Directory
               -- Pack (Compress) a Loaded Disk Directory
               -- Combination Utility (Load, Select, Alphabetize,
                    and Pack a Disk Directory)

          2.  Block-Oriented File Input/Output
               -- Open, Create, and Close a File
               -- Delete a File
               -- Rename a File
               -- See if a File Exists
               -- Read and Write Blocks from and to a File

          3.  Byte-Oriented File Input/Output
               -- Open and Close a File
               -- Read and Write a Byte from and to a File

          4.  File Control Block (FCB) Manipulation
               -- Set Up an FCB from a String
               -- Initialize an FCB

          5.  ZCPR2-Specific Functions
               -- Initialize ZCPR2 SYSLIB Buffers
               -- Return Pointer to Next Character in Multiple
                    Command Line
               -- Return Status of a ZCPR2 File
               -- Search for a File Along the ZCPR2 Command
                    Path
               -- Determine User and Disk Referred to by a
                    ZCPR2 Named Directory
               -- Find a ZCPR2 Named Directory Index File
               -- Set Up an FCB from a String with ZCPR2
                    Named Directories Permitted


     Notå thaô thå lasô seô oæ routineó applù tï ZCPR2®  ZCPR² ió 
á  replacemenô  foò  thå  CP/Í CCĞ  thaô  É  aí  designinç  whicè 
significantlù  enhanceó  thå poweò oæ thå CCĞ anä giveó  iô  manù 
capabilities similar to some found in the UNIX Operating System.


4.01 Directory Manipulation Routines

     Thå  directorù manipulatioî routineó oæ SYSLIÂ arå  designeä 
witè á maximuí oæ generalitù anä flexibilitù iî mind®   Actinç tï 
relievå  thå  programmeò  oæ thå tasë oæ writinç  routineó  whicè 
accesó thå directorù informatioî oî disk¬  theså routineó  accesó 
thå  disë  directorù foò hií anä loaä itó contentó intï á  memorù 
buffer in a form which is relatively easy to use.

     Thå imagå oæ á disë directorù aó placeä iî memorù bù  SYSLIÂ 
is a series of 16-byte entries organized as follows:

     ----------------------------------------------------------
     | 1 Byte | 8 Bytes | 3 Bytes | 1 Byte | 2 Bytes | 1 Byte |
     ----------------------------------------------------------
         ^         ^         ^         ^        ^         ^
         |         |         |         |        |         |
     ----------------------------------------------------------
     |User Num|File Name|File Type| Extent |  Unused | Rec Cnt|
     ----------------------------------------------------------

     Notå  thaô  thió ió identicaì tï thå firsô 1¶ byteó  oæ  thå 
CP/Í directorù entrù aó iô existó oî disë anä ió specifieä iî thå 
Filå Controì Blocë (FCB)®   Notå alsï thaô thå firsô bytå ió useä 
tï indicatå thå Useò Numbeò associateä witè thå file¬ anä NOÔ thå 
disë numbeò (aó thió bytå ió useä foò iî thå FCB).

     Beforå thå disë directorù ió accessed¬ however¬ iô ió usual
lù  á  gooä ideá tï uså thå SYSLIÂ DBUFFEÒ  routinå  tï  allocatå 
memorù spacå foò thå loadeä directorù entries¬  especiallù iæ thå 
alphabetizatioî routinå ió tï bå useä later®  Thå DBUFFEÒ routinå 
ió passeä á pointeò tï á scratcè memorù areá whicè extendó tï thå 
toğ  oæ thå TPA¬  anä iô accesseó thå disë parameteò information¬ 
allocateó pointeò spacå foò thå alphabetizatioî  routine¬  checkó 
foò Transienô Prograí Areá (TPA© overflow¬  anä returnó á pointeò 
tï thå nexô availablå bytå afteò thå pointeò spacå intï whicè thå 
directorù ió tï bå lateò loaded.

     Thå  memorù  addresó requireä bù DBUFFEÒ caî  bå  frequentlù 
provideä  bù thå CODENÄ routinå (unlesó thå scratcè areá  ió  al
readù beinç useä bù thå program¬ iî whicè caså thå programmeò haó 
tï providå thió valuå froí withiî hió code)®   DBUFFEÒ anä CODENÄ 
fiô  nicelù togetheò foò thió purpose®   Thå typicaì callinç  se
quencå lookó likå this:

               ...
               CALL CODEND
;  HL now points to the bottom of the scratch area
               CALL DBUFFER
;  HL now points to the bottom of the directory load area
;    and A = 0 and Zero Flag is Set (Z) if TPA Overflow
               JZ   TPAOVFL   ; Handle Error and Abort
               ...
     The memory map for directory access looks like this:

                         -------------------------------
                         | CP/M BDOS                   |
     Top of TPA/Bottom   -------------------------------
       of BDOS           | Unused Space                |
                         -------------------------------
     DIRLOAD or DIRSLOAD | Directory Entries (16 Bytes)|
       Load This ----->  |   are loaded here           |
                         -------------------------------
     DBUFFER Computes    | Pointer Space for Alphabet- |
       This ---------->  |   ization                   |
     Beginning of        -------------------------------
       Scratch Area      | Dead Space                  |
     End of Program      -------------------------------
                         | CODEND Routine              |
                         -------------------------------
                         | Other SYSLIB Routines       |
                         -------------------------------
                         | Programmer's Code           |
     100H                -------------------------------

     Noteº   Iô ió assumeä thaô thå programmeò haó alreadù loggeä 
iî thå requireä disë beforå DBUFFEÒ ió called®   Iæ not¬ thå disë 
parameteò informatioî maù bå iî  error¬  and¬  consequently¬  in
sufficienô pointeò spacå maù bå allocated.

     DBUFFEÒ calló thå routinå DPARAMÓ tï determinå thå specificó 
oî  thå  CP/Í disë structurå anä thå informatioî iô  requireó  tï 
allocatå thå pointeò space®   Iî particular¬  DPARAMÓ returnó thå 
maximuí numbeò oæ disë directorù entries¬  anä DBUFFEÒ  allocateó 
enougè pointeò spacå tï loaä alì directorù entrieó iæ necessary.

     DPARAMÓ  extractó mucè necessarù informatioî foò uså bù SYS
LIÂ iî dealinç witè disë directories®  Thå programmeò neeä noô bå 
concerneä  witè exactlù whaô thió informatioî  is¬  sincå  SYSLIÂ 
useó iô internallù anä provideó thå programmeò witè whaô hå needó 
tï kno÷ througè itó subroutines®  Foò thå interesô oæ thå reader¬ 
however¬  thå  followinç informatioî ió extracteä bù DPARAMÓ  foò 
internaì SYSLIÂ use:

          o Block Shift Factor
          o Block Mask
          o Extent Mask
          o Maximum Number of Blocks on Disk
          o Maximum Number of Directory Entries

     Thoså readeró familiaò witè CP/Í internaló maù bå interesteä 
tï  kno÷ thaô thió ió alì oæ thå informatioî requireä tï  perforí 
theså  disë functions®   DPARAMÓ alsï determineó whaô versioî  oæ 
CP/Í ió beinç useä (1.´ oò 2.² oò MP/M)¬ anä extractó thió infor
matioî  froí thå BDOÓ internaló iæ CP/Í 1.´ ió beinç useä oò froí 
thå BDOÓ Functioî Calló iæ CP/Í 2.² oò MP/Í ió beinç used®  Thoså 
reallù interesteä iî pursuinç morå detaiì arå inviteä tï reaä thå 
SYSLIÂ sourcå code.Š     No÷ thaô thå preliminarieó arå overwitè anä thå bufferó havå 
beeî properlù initialized¬  thå nexô logicaì steğ ió tï loaä  thå 
disë  directory®   Twï  SYSLIÂ routineó arå provideä tï dï  thisº  
DIRLOAD and DIRSLOAD.

     Botè DIRLOAÄ anä DIRSLOAÄ loaä thå directorù buffeò  pointeä 
tï  bù  HÌ witè thå entrieó oæ alì uneraseä fileó oî thå disë  iî 
alì  useò areaó oæ thå disk®   Also¬  botè DIRLOAÄ  anä  DIRSLOAÄ 
returî  á  flaç  iî thå Á registeò iæ TPÁ  Overflo÷  occuró  (noô 
enougè  rooí tï storå alì thå directorù entries)¬  and¬  iæ á TPÁ 
overflo÷ haó noô occurred¬ theî thå BÃ registeò paiò containó thå 
numbeò oæ directorù entrieó loadeä intï memory.

     Thå  tradeofæ  betweeî  DIRLOAÄ anä DIRSLOAÄ  lieó  iî  whaô 
informatioî  ió  requireä bù thå  programmer®   DIRLOAÄ  executeó 
fasteò thaî DIRSLOAD¬  anä iô loadó onlù thå firsô entrù foò eacè 
file®  DIRSLOAD¬ however¬ loadó thå LASÔ entrù foò eacè file¬ anä 
iæ  thå  programmeò  wisheó  tï lateò computå  thå  sizå  oæ  hió 
selected files, DIRSLOAD must be used instead of DIRLOAD.

     Tï  recap¬  DIRLOAÄ anä DIRSLOAÄ providå thå  "procesó  box¢ 
whicè  loadó á directorù froí disë intï memory®   Ouò  developinç 
program now looks like this:

               ...
               CALL CODEND
;  HL now points to the bottom of the scratch area
               CALL DBUFFER
;  HL now points to the bottom of the directory load area
;    and A = 0 and Zero Flag is Set (Z) if TPA Overflow
               JZ   TPAOVFL   ; Handle Error and Abort
               CALL DIRLOAD   ; Load Disk Directory
;  DIRLOAD/DIRSLOAD only affect BC, so, at this point:
;    HL = address of first directory entry loaded
;    BC = number of directory entries loaded if no error
;    A = error flag (A=0 and Zero Flag Set if TPA Overflow)
               JZ   TPAOVFL   ; Handle Error and Abort
               ...

     No÷  thaô  thå disë directorù haó beeî loadeä  intï  memory¬ 
whaô typeó oæ thingó woulä onå wanô tï dï witè it¿  Undeò SYSLIB¬ 
routineó arå provideä tï dï thå following:

          o Select Entries (Match Target FCB)
          o Pack Directory Image (Get Rid of Unselected Entries)
          o Alphabetize the Directory Image
          o Compute Sizes of Files


     DIRSEÌ  ió thå routinå useä tï selecô entrieó froí á  loadeä 
disk directory.  DIRSEL requires the following information:

          HL = address of first entry
          DE = address of FCB containing of desired files
               - only the file name and file type fields are
                 used, so a full FCB need not be allocated
               - only the first 12 bytes of an FCB are required
                 by DIRSEL, and the first byte is ignored
          BC = number of files in the directory
          A  = selection flag, organized as follows:
               - Bit 7 = Select Non-System Files if Set
               - Bit 6 = Select System Files if Set
               - Bit 5 = Select Files in All User Areas if Set
               - Bits 4-0 = If Bit 5 is 0, user number (5 bits)
                    of user area to select files from

     Ouò evolvinç prograí no÷ containó á DIRSEÌ calì aó thå  nexô 
logicaì step:

               ...
               CALL CODEND
;  HL now points to the bottom of the scratch area
               CALL DBUFFER
;  HL now points to the bottom of the directory load area
;    and A = 0 and Zero Flag is Set (Z) if TPA Overflow
               JZ   TPAOVFL   ; Handle Error and Abort
               CALL DIRLOAD   ; Load Disk Directory
;  DIRLOAD/DIRSLOAD only affect BC, so, at this point:
;    HL = address of first directory entry loaded
;    BC = number of directory entries loaded if no error
;    A = error flag (A=0 and Zero Flag Set if TPA Overflow)
               JZ   TPAOVFL   ; Handle Error and Abort
;  Prepare for DIRSEL Call
;  HL and BC already contained values required by DIRSEL
               LXI  D,FCB     ; Point to FCB
               MVI  A,11100000B    ; Select Non-System and System
                                   ;   Files in All User Areas
               CALL DIRSEL
;  No Error Code is Returned, and
;  All Registers are Unchanged; Hence, the following important
;  values are retained:
;    HL = address of first directory entry loaded
;    BC = number of directory entres loaded
               ...
;
;  Data Buffer Area
;
FCB:
     DB   0    ; Just Filler
     DB   'ANYFIL? TXT'  ; File Spec, may include wild card of ?


     DIRSEÌ selectó itó fileó bù settinç thå Mosô Significanô Biô 
oæ  thå Useò Numbeò fielä oæ thå selecteä directorù entrieó tï  á 
1®   Hence¬ sincå thió ió alì thaô ió changed¬ DIRSEÌ maù bå useä 
repeatedlù  tï selecô severaì groupó oæ files¬  anä theså  groupó 
maù includå thå samå fileó (MYF?¿  anä MYF¿ maù matcè somå oæ thå 
samå files)®   Sincå DIRSEÌ changeó nï registers¬  onå calì afteò 
another may be made:

          ...
          LXI  D,FCB1    ; Match first set
          MVI  A,11100000B    ; Non-Sys, Sys, and All Users
          CALL DIRSEL
          LXI  D,FCB2    ; Match 2nd set
          CALL DIRSEL
          ...

     Oncå  alì thå desireä fileó havå beeî selected¬  DIRPACË anä 
DIRNPACË arå useä tï pacë thå directorù buffer¬  leavinç iî  onlù 
thoså entrieó desired®  Iæ DIRPACË ió used¬ entrieó NOÔ markeä bù 
DIRSEÌ  arå discarded¬  anä thå buffeò ió reorganizeä tï  contaiî 
onlù  thoså entrieó markeä bù DIRSEL®   Iæ DIRNPACË ió used¬  en
trieó  markeä bù DIRSEÌ arå discardeä (negativå  selection)¬  anä 
thå  buffeò  ió  reorganizeä tï contaiî onlù  thoså  entrieó  NOÔ 
markeä bù DIRSEL.

     DIRPACK and DIRNPACK require the following inputs:
          HL = address of first entry in directory buffer
          BC = number of entries in directory buffer

     DIRPACK and DIRNPACK return the following values:
          HL = address of first entry in directory buffer
          BC = number of desired entries left in directory buffer

     Notå thaô onlù thå BÃ registeò paiò maù bå changed¬  anä alì 
otheò registeró arå noô affected®  Again¬ ouò prograí no÷ evolveó 
as indicated:


               ...
               CALL CODEND
;  HL now points to the bottom of the scratch area
               CALL DBUFFER
;  HL now points to the bottom of the directory load area
;    and A = 0 and Zero Flag is Set (Z) if TPA Overflow
               JZ   TPAOVFL   ; Handle Error and Abort
               CALL DIRLOAD   ; Load Disk Directory
;  DIRLOAD/DIRSLOAD only affect BC, so, at this point:
;    HL = address of first directory entry loaded
;    BC = number of directory entries loaded if no error
;    A = error flag (A=0 and Zero Flag Set if TPA Overflow)
               JZ   TPAOVFL   ; Handle Error and Abort
;  Prepare for DIRSEL Call
;  HL and BC already contained values required by DIRSEL
               LXI  D,FCB     ; Point to FCB
               MVI  A,11100000B    ; Select Non-System and System
                                   ;   Files in All User Areas
               CALL DIRSEL
;  No Error Code is Returned, and
;  All Registers are Unchanged; Hence, the following important
;  values are retained:
;    HL = address of first directory entry loaded
;    BC = number of directory entries loaded
               CALL DIRPACK   ; Pack Directory
;  Only BC is changed, and now:
;    BC = number of remaining (desired) directory entries
;  This is typically followed by a test to see if BC=0 (no
;  entries selected
               MOV  A,B       ; See if BC=0
               ORA  C
               JZ   EMPTY     ; Process No Selected File Routine
               ...
;
;  Data Buffer Area
;
FCB:
     DB   0    ; Just Filler
     DB   'ANYFIL? TXT'  ; File Spec, may include wild card of ?


     Finally¬  no÷  thaô wå havå loadeä thå directorù froí  disk¬ 
selecteä thå files¬  anä finallù packeä thå loadeä directory¬  wå 
maù  wisè tï alphabetizå thió loadeä directorù foò easå oæ accesó 
anä user-friendlinesó iî ouò prograí (lisô thå fileó tï thå  useò 
alphabetically)®  DIRALPHÁ ió thå SYSLIÂ routinå whicè doeó this.

     DIRALPHÁ  requireó thå followinç inputó anä haó nï effecô oî 
any registers:

          HL = address of first directory entry
          BC = number of directory entries to sort
          A  = sort flag; if A=0, sort first by file name and
               then by file type (HISFILE.TXT comes before
               MYFILE.MAC), else sort first by file type and
               then by file name (MYFILE.MAC comes before
               HISFILE.TXT)

     Our program has finally evolved into the following:

               ...
               CALL CODEND
;  HL now points to the bottom of the scratch area
               CALL DBUFFER
;  HL now points to the bottom of the directory load area
;    and A = 0 and Zero Flag is Set (Z) if TPA Overflow
               JZ   TPAOVFL   ; Handle Error and Abort
               CALL DIRLOAD   ; Load Disk Directory
;  DIRLOAD/DIRSLOAD only affect BC, so, at this point:
;    HL = address of first directory entry loaded
;    BC = number of directory entries loaded if no error
;    A = error flag (A=0 and Zero Flag Set if TPA Overflow)
               JZ   TPAOVFL   ; Handle Error and Abort
;  Prepare for DIRSEL Call
;  HL and BC already contained values required by DIRSEL
               LXI  D,FCB     ; Point to FCB
               MVI  A,11100000B    ; Select Non-System and System
                                   ;   Files in All User Areas
               CALL DIRSEL
;  No Error Code is Returned, and
;  All Registers are Unchanged; Hence, the following important
;  values are retained:
;    HL = address of first directory entry loaded
;    BC = number of directory entries loaded
               CALL DIRPACK   ; Pack Directory
;  Only BC is changed, and now:
;    BC = number of remaining (desired) directory entries
;  This is typically followed by a test to see if BC=0 (no
;  entries selected
               MOV  A,B       ; See if BC=0
               ORA  C
               JZ   EMPTY     ; Process No Selected File Routine
               CALL DIRALPHA  ; Alphabetize Directory
;  No error codes are returned, and the following registers are
;  significant:
;    HL = address of first directory entry loaded
;    BC = number of directory entries loaded
;  The programmer may now continue with his specific application
               ...
;
;  Data Buffer Area
;
FCB:
     DB   0,'ANYFIL? TXT'  ; File Spec, may include wild card of ?Š
     Aó  thå readeò caî see¬  thå SYSLIÂ routineó  arå  certainlù 
cohesivelù designeä anä worë togetheò witè á minimuí oæ overhead¡  
Sincå thå abovå sequencå oæ instructionó arå sï frequentlù needeä 
iî exactlù thå samå order¬ É havå toppeä ofæ thå SYSLIÂ directorù 
manipulation routine module with the DIRF and DIRFS routines.

     DIRÆ anä DIRFÓ perforí thå followinç operationó iî thå ordeò 
indicated:

          1.  Initialize Buffer Area (DBUFFER call)
          2.  Load the Disk Directory into the Buffer
               (DIRF calls DIRLOAD, DIRFS calls DIRSLOAD)
          3.  Select a Set of Files (DIRSEL call)
          4.  Pack the Files in the Memory Buffer (DIRPACK call)
          5.  Alphabetize the Files in the Memory Buffer
               (DIRALPHA call) by file name and then file type

     DIRF and DIRFS require the following input parameters:

          HÌ ½ baså oæ dynamiã buffeò areá (aó returneä bù
               CODEND)
          DE = address of FCB containing file spec to match
               (only 1st 12 bytes required)
          A  = selection flag, as for DIRSEL

     DIRF and DIRFS return the following output parameters:

          HL = address of first file entry
          BC = number of file entries
          A  = error flag; A=0 and Zero Flag Set (Z) if TPA
               Overflow occurred

     The DIRF/DIRFS calling sequence is typically:

          ...
          EXT  CODEND    ; Use CODEND
          EXT  DIRF      ; Use DIRF
          ...
          CALL CODEND    ; Get Scratch Area Address
          LXI  D,FCB     ; Pt to FCB
          MVI  A,11100000B    ; Non-Sys, Sys, in all User Areas
          CALL DIRF      ; Do It!
          ...
     FCB: DB   0,'????????TXT'     ; Select all TXT files
          ...


     Finally¬  thå  lasô twï subroutineó availablå iî SYSLIÂ  foò 
directory manipulation are DFREE and FSIZE.

     DFREÅ  computeó thå amounô oæ freå spacå lefô oî  disk¬  anä 
returnó  thió valuå (iî Ë bytes© iî DE®   Nï otheò registeró  arå 
affected®   Thå desireä disë shoulä bå loggeä in¬  DPARAMÓ shoulä 
bå calleä tï extracô thå desireä informatioî foò thaô disk'ó disë 
parameter block, and then DFREE should be called.

     FSIZÅ  computeó thå sizå oæ thå filå whoså loadeä  directorù 
entrù (musô havå beeî loadeä bù DIRSLOAÄ througè eitheò á calì tï 
DIRSLOAÄ  oò á calì tï DIRFS© ió pointeä tï bù HL®   Thå sizå  oæ 
this file in K bytes is returned as a binary number in DE.

     Thió completeó thå discussioî oæ thå directorù  manipulatioî 
routineó oæ SYSLIB®   Onå finaì noteº   alì oæ theså routineó arå 
containeä iî thå SDIÒ module¬  anä thå entirå modulå ió loadeä iæ 
anù  onå  oæ  theså routineó ió  called®   Sincå  thå  programmeò 
frequentlù wantó tï uså severaì oæ theså routineó iî hió code¬  É 
did not consider this to be an unnecessary overhead burdon.


4.02 Block-Oriented File Input/Output

     Thå block-orienteä filå input/outpuô routineó oæ SYSLIÂ wilì 
bå  discusseä brieflù iî thió documenô sincå theù arå quitå simi
laò  tï  theiò BDOÓ counterparts®   Thå majoò thinç  thaô  SYSLIÂ 
offeró  witè  theså  routineó ió noô havinç tï  worrù  abouô  thå 
effectó oæ theså routineó oî registers®   Iî alì cases¬  onlù thå 
PS× ió affecteä bù theså routines¬ anä iô ió useä tï returî erroò 
codes®   Thå Block-Orienteä Filå Input/Outpuô routineó iî  SYSLIÂ 
are:

          F$OPEN    Open the file whose FCB is pointed to by DE
                    Returns normal CP/M Error Code in A
          F$MOPEN   FCB is pointed to by DE, and, if the file is
                    not already existing, it is created; other-
                    wise, it is just opened;
                    Returns Error Code in A
          F$CLOSE   Close the file whose FCB is pointed to by DE
          F$MAKE    Create the file whose FCB is pointed to by
                    DE
          F$DELETE  Delete the file whose FCB is pointed to by DE
          F$RENAME  Rename the file whose FCB is pointed to by DE
                    to that whose FCB is pointed to by HL; only
                    the first 12 bytes of each FCB is required;
                    F$RENAME returns with the Zero Flag Set if
                    the original file was not found
          F$EXIST   Determine if the file whose FCB is pointed to
                    bù DÅ existó iî thå currenô disë anä useò
                    area; F$EXIST returns with the Zero Flag Set
                    if the file does not exist
          F$READ    Read Block; usual error code
          F$WRITE   Write Block; usual error codeŠ
     Notå  thaô  theså  routineó arå mainlù  reflectionó  oæ  thå 
conventionaì BDOÓ functions®  Significanô extensionó arå F$MOPEN¬ 
F$RENAME, and F$EXIST.  Example follows:

          ...
          LXI  D,FCB2    ; test for existance of file
          CALL F$EXIST
          JZ   NOFILE
;
;  DE Still Points to FCB of Old File
;
          LXI  H,FCB1    ; new FCB
          CALL F$RENAME  ; rename file
          ...
FCB1:     DB   0,'NEWFILE TXT'     ; new file name
FCB2:     DB   0,'OLDFILE TXT'     ; old file name
          ...



4.03 Byte-Oriented File Input/Output

     SYSLIÂ takeó á significanô steğ beyonä thå conventionaì CP/Í 
block-orienteä  filå  input/outpuô  capabilitieó witè  itó  byte-
orienteä filå input/outpuô capabilities®   Theså routines¬ unlikå 
thå  otheró  whicè requirå thå useò tï reaä tï anä writå  froí  á 
filå oî á blocë basió (12¸ byteó aô á time)¬ allo÷ thå programmeò 
tï  reaä froí anä writå tï á CP/Í filå oî á byte-for-bytå  basis®  
Theså routines¬ oî read¬ reaä iî á blocë aó requireä anä continuå 
tï returî onlù thå nexô bytå requesteä bù thå programmer¬ and¬ oî 
write¬  collecô uğ tï 12¸ byteó senô ouô bù thå programmer¬ writå 
thaô block¬ anä theî continuå collectinç bytes.

     Thå  utilitù oæ theså routineó ió enhanceä bù thå facô  thaô 
theù  caî bå useä withouô carå bù thå programmer®   Foò  example¬ 
F0$PUÔ  ió useä tï outpuô onå bytå tï filå 0¬  anä thå  followinç 
samplå codå printó á strinç oæ byteó tï thå console¬ printer¬ anä 
disk file, using SYSLIB routines:


          ...
          LXI  D,FCB     ; POINT TO FCB OF OUTPUT FILE
          CALL INITFCB   ; CLEAR PROPER FCB FIELDS
          CALL FO0$OPEN  ; OPEN FILE 0 FOR OUTPUT
          JZ   FERR      ; FILE ERROR HANDLER
          LXI  H,STRING  ; POINT TO STRING TO OUTPUT
LOOP:
          MOV  A,M       ; GET NEXT CHARACTER
          ORA  A         ; END OF STRING IF 0
          JZ   DONE      ; DONE IF END OF STRING
          CALL F0$PUT    ; WRITE BYTE TO DISK
          JZ   FERR
          CALL COUT      ; WRITE BYTE TO CONSOLE
          CALL LOUT      ; WRITE BYTE TO PRINTER
          INX  H         ; POINT TO NEXT BYTE
          JMP  LOOP      ; CONTINUE UNTIL DONE
DONE:
          CALL FO0$CLOSE ; CLOSE OUTPUT FILE
          ...
FERR:                    ; ERROR HANDLER
          ...
FCB:      DB   0,'OUTFILE TXT'     ; OUTPUT FILE FCB
          DS   4
          DS   16
          DS   4         ; FOUR MORE BYTES FOR SYSLIB
          ...


     Thió examplå ió probablù adequatå tï sho÷ thå readeò ho÷  tï 
uså  SYSLIÂ  iî general®   Thå followinç arå thå SYSLIÂ  routineó 
used to support Byte-Oriented File Input and Output:

 File Open for       File Close for           Byte-Oriented
Input     Output    Input     Output         Read      Write
-----     ------    -----     ------         ----      -----
FI0$OPEN  FO0$OPEN  FI0$CLOSE FO0$CLOSE      F0$GET    F0$PUT
FI1$OPEN  FO1$OPEN  FI1$CLOSE FO1$CLOSE      F1$GET    F1$PUT
FI2$OPEN  FO2$OPEN  FI2$CLOSE FO2$CLOSE      F2$GET    F2$PUT
FI3$OPEN  FO3$OPEN  FI3$CLOSE FO3$CLOSE      F3$GET    F3$PUT

     Uğ tï eighô fileó caî bå opeî aô onå timå -- fouò foò  inpuô 
anä fouò foò output®  Thå sequencå oæ calló tï uså theså routineó 
is always the same:

          < Open Files for Input or Output >
          < Read or Write Bytes using GET and PUT >
          < Close Files for Input or Output >


     Thå abovå examplå showeä ho÷ thió waó donå foò writinç tï  á 
file®   Thå $OPEÎ routineó requirå á 36-bytå FCÂ whicè ió pointeä 
tï bù DÅ aó aî inpuô argument¬ anä theù returî witè thå Zerï Flaç 
Seô  iæ aî erroò occurred®   Thå $CLOSÅ routineó requirå nï inpuô 
argumenô (theù kno÷ whaô fileó theù arå dealinç with)¬  anä  theù 
returî  witè  Zerï Flaç Seô iæ aî erroò occurred®   Thå $GEÔ  anä 
$PUÔ  routineó onlù requirå Á tï contaiî thå characteò tï  outpuô 
(foò  thå $PUÔ routines© oò inpuô (foò thå  $GEÔ  routines)¬  anä 
theù returî aî erroò flaç (Zerï Flaç Seô iæ Error© anä erroò codå 
(iî  A© iæ aî erroò occurs®   Iæ aî erroò occurs¬  Á returnó  thå 
erroò code» iæ nï erroò occurs¬ Á ió unchanged.

     Chapteò  ´  oæ thå SYSLIÂ Useò anä Referencå Manual“ giveó  á 
little more detail, including the error code information.


4.04 File Control Block (FCB) Manipulation

     SYSLIB provides two simple routines for FCB manipulation.

     Thå keù fieldó wå arå interesteä iî aî FCÂ arå thå filå namå 
anä filå typå fields®   Thå FCÂ useä bù SYSLIÂ ió alwayó 3¶ byteó 
long¬ anä iô typicallù declareä witè thå followinç code:

          FCB: DB   0              ; Zero Disk Number
               DB   'FILENAMETYP'  ; File Name and Type
               DS   4              ; Rest of first 16 bytes
               DS   16             ; Second 16 bytes
               DS   4              ; Last required by SYSLIB

     Thå firsô ió INITFCB®  Thió routinå simplù clearó alì oæ thå 
fieldó (excepô thå filå namå anä filå typå fields© oæ thå 36-bytå 
FCÂ pointeä tï bù DÅ tï zero®   Iô ió á nice¬  quicë waù tï init
ializå aî FCÂ fully.

     Notå  thaô iô clearó thå disë numbeò fielä (thå firsô field© 
aó well¬ therebù selectinç thå currenô disk®  Iô ió intendeä thaô 
thå  useò manuallù selecô thå disë himselæ ratheò  thaî  allowinç 
thå BDOÓ tï auto-selecô á disk.

     Thå seconä SYSLIÂ routinå discusseä herå ió FNAME®   Thió ió 
á filå namå strinç parser¬ anä iô buildó aî FCÂ anä extractó useò 
anä  disë informatioî froí á grouğ oæ characteró terminateä bù  á 
delimiter®  Oî input¬ HÌ pointó tï thå firsô bytå oæ thå grouğ oæ 
characteró  anä DÅ pointó tï thå FCB®   Oî output¬  thå followinç 
regster values are returned:

          B  = Number of Disk Specified (A=1 to P=16 or 0FFH if
               no disk specified)
          C  = User Number Specified (0 to 31, '?' if all users,
               or 0FFH if no user specified)
          HL = address of delimiter which ended the scan
          A  = error flag; A=0 and Zero Flag Set if invalid disk
               or user number specifiedŠ     Scanninç  viá  FNAMÅ ió stoppeä wheî á delimiteò ió  encoun
tered®  Thå followinç arå classifieä bù SYSLIÂ aó delimiters:

          <NULL or Binary 0>       <Space Character>
          =    _    ;    ,    <    >

     Thå grouğ oæ characteró ió intendeä tï bå á filå  specifica
tion¬ similaò tï thå CP/Í standard®  Iô ió oæ thå generaì form:

          du:filename.typ

wherå  d=disë letter¬  u=useò number¬  anä thå resô ió  standard®  
Valiä  disë letteró arå A-P¬  anä valiä useò numberó arå 0-3± anä 
the '?' character.

     Thå  FCÂ ió initializeä bù thió routine¬  anä onlù thå  filå 
namå  anä filå typå fieldó arå seô (tï thå filename.tyğ partó  oæ 
thå  string)®   Alì loweò caså characteró arå converteä tï  uppeò 
case.

     Examples of valid character sequences are:

          Sequence       Returned Values
          --------       ---------------

          test.txt       File Name = TEST    File Type = TXT
                         B Reg = 0FFH        C Reg = 0FFH

          a:t            File Name = T       File Type = <spaces>
                         B Reg = 1           C Reg = 0FFH

          5:.t           File Name = <space> File Type = T
                         B Reg = 0FFH        C Reg = 5

          c10:x*.t?t     File Name = X???????  File Type = T?T
                         B Reg = 3           C Reg = 10


     FNAMÅ  ió frequentlù useä iî processinç useò input®   Á codå 
examplå is:


          ...
          CALL PRINT
          DB   'Name of File? ',0
          CALL BBLINE    ; GET NAME OF FILE FROM USER
          LXI  D,FCB     ; PT TO FCB WITH DE, HL ALREADY PTS TO
                         ;   FIRST CHAR OF FILE NAME
          CALL FNAME     ; EXTRACT INFORMATION
          JZ   FNERR     ; ERROR HANDLER
          MOV  A,B       ; SAVE DISK NUMBER
          STA  DISK
          MOV  A,C       ; SAVE USER NUMBER
          STA  USER
          ...
FCB:      DS   36        ; NO INITIALIZATION NECESSARY FOR FCB
DISK:     DS   1         ; USER-SPECIFIED DISK NUMBER
USER:     DS   1         ; USER-SPECIFIED USER NUMBER
          ...


4.05 ZCPR2-Specific Functions

     É aí currentlù iî thå throwó oæ designinç á ne÷ CP/Í compat
ablå  CCP-replacemenô  calleä  ZCPR2¬  anä thå desigî  oæ  SYSLIÂ 
reflectó thió tï somå extent®   SYSLIÂ containó twï moduleó whicè 
supporô  ZCPR2-specifiã capabilities¬  anä theså moduleó  contaiî 
siø SYSLIB-internaì buffeò initializatioî routineó anä siø  ZCPR² 
utilitù routines®  Somå oæ thå readeró maù bå familiaò witè ZCPR± 
(whicè  ió  availablå foò freå iî Volumeó 5´ anä 7· oæ thå  SIG/Í 
User'ó  Group)®   Afteò  writinç ZCPR1¬  É founä severaì  oæ  itó 
featureó tï bå lackinç (especiallù afteò É gaineä somå experiencå 
usinç UNIX)®   ZCPR² ió á significanô extensioî tï ZCPR1¬  anä iô 
containó varientó oæ severaì featureó founä iî non-CP/Í operatinç 
systems¬ sucè aó UNIX.

     Giveî  thå CP/Í memorù mapó froí beforå (thå readeò  ió  in
viteä  tï  refeò bacë tï theí iæ desired)¬  thå followinç ió  thå 
memorù mağ foò á typicaì ZCPR2-baseä systeí whicè supportó alì oæ 
thå extendeä features:


          Comments       Size Memory Map

     High Memory              ----------------------------
                           1K | ZCPR2 Buffers, incl      |
                      (May be |   Multiple Command Line  |
                       less)  ----------------------------
                           2K | ZCPR2 BIOS, incl special |
                              |   Cold Boot Init routines|
                              ----------------------------
                         3.5K | CP/M BDOS or other BDOS  |
                        ->    ----------------------------
                       /   2K | ZCPR2                    |
     Normal ZCPR2     /       ----------------------------
       TPA (when     /   0.5K | ZEX Monitor and Buffer   |
       ZEX is not    \(Approx)|   Optionally Loaded      |
       loaded)        \       ----------------------------
                       \      | COM File Space           |
                        \     |    TPA when ZEX is       |
                         \    |        loaded in with    |
                          \   |        ZCPR2             |
     Address 100H          -> ----------------------------
                        0.25K | System Buffers and Entry |
                              |   Points                 |
     Address 0H               ----------------------------



     É wilì noô gï intï á detaileä explanatioî oæ ZCPR2¬ particu
larlù  ZEX¬  aô  thió time®   Extensivå detailó oî ZCPR² wilì  bå 
releaseä later.

     Beforå expoundinç oî whaô thå ZCPR2-orienteä SYSLIÂ routineó 
do¬  iô  woulä  bå á gooä ideá tï explaiî somå  oæ  thå  extendeä 
featureó  oæ ZCPR² whicè arå supporteä bù theså routines®   Threå 
ZCPR² featureó arå supporteä iî SYSLIB:

          1. Multiple Command Lines
               -- ZCPR² caî bå seô uğ tï allo÷ thå useò tï enteò 
                  command lines like the following:
                    xdir;b3:;a7:display myfile
                         <-- run XDIR from current user/disk,
                             log into Disk B/User 3, run DISPLAY
                             from Disk A/User 7 on MYFILE in B3

          2. Command Search Paths (File Search Paths)
               -- wheî ZCPR² receiveó á command¬ iæ iô determineó 
                  thaô á commanä filå (COÍ file© ió necessarù tï 
                  executå thå command¬ ZCPR² searcheó alonç á 
                  patè foò thå command¬ movinç froí onå disë anä 
                  useò areá tï anotheò untiì thå enä oæ thå patè 
                  ió reached; example is --


                    $$ $0 a$ a0    <-- ZCPR2 will look for file
                                       from current disk/user to
                                       cur disk/user 0 to disk A
                                       cur user to disk A/U 0


          3® Nameä Directorieó (maù bå implementeä oî 
             conventional CP/M systems as well)
               -- ZCPR² haó thå addeä abilitù tï supporô á 
                  disk/userº forí whereveò jusô á diskº forí waó 
                  permitteä before» exampleó arå --
                    a5:            <-- change to disk A/User 5
                    b6:cmnd        <-- execute command from B6
                    type a7:myfile <-- type file in A7
                    dir c11:       <-- directory of C11
                    a:             <-- change to disk A/Cur User
                    5:             <-- change to cur disk/User 5
                    erá 1:myfilå   <-- eraså filå oî cuò disk/Õ 1

                  Thió ió furtheò extendeä bù aî implementatioî 
                  oæ nameä directorieó iî COÍ filå thrõ SYSLIB» á 
                  directory in the ZCPR2 vernacular is a disk and
                  useò areá combination¬ sucè aó disë Á anä useò 
                  5» sucè directorieó caî bå giveî mnemoniã 
                  names¬ sucè aó JEFFº oò MYWORK:» exampleó oæ 
                  existing ZCPR2 utilities are --
                    xdiò jeffº     <-- XDIÒ oî dir named JEFF
                    cd mytext:     <-- change dir (log into)
                                       dir named MYTEXT
                    mcopy backup:=work:*.txt
                                   <-- copy *.TXT files from
                                       WORK: to BACKUP:


     Beinç iî lovå witè thå SYSLIÂ concept¬  É decideä tï relievå 
somå  oæ thå tediouó ZCPR2-specifiã codinç requireä tï  implemenô 
oò  accesó theså featureó froí thå programmeò anä placå  iô  intï 
SYSLIB®  Oncå thå wheeì ió invented¬ whù dï iô again¬ right?




                  Multiple Commands and SYSLIB

     Accesó  tï  thå  ZCPR² multiplå commanä linå  ió  thå  firsô 
featurå É placeä intï SYSLIÂ iî thió regard®   Undeò  ZCPR2¬  thå 
multiplå commanä linå featurå maù bå engageä oò disengageä aô thå 
systeí programmer'ó discretion®  Thå tradeofæ foò thió featurå ió 
that¬  iæ disengaged¬ thå buffeò useä tï storå thå user'ó commanä 
linå  ió storeä internaì tï ZCPR2¬  anä thió prohibitó thå uså oæ 
multiplå  commandó oî á singlå linå anä takeó uğ  valuablå  spacå 
withiî  ZCPR² whicè maù bå useä foò otheò options®   Iæ  engaged¬ 
thå  buffeò  useä tï storå thå user'ó commanä linå ió storeä  ex
ternallù tï ZCPR2¬  anä somå codå musô bå placeä intï thå BIOÓ sï 
thaô thå BIOS¬  oî Colä Boot¬ wilì allocatå spacå foò thió buffeò 
anä initializå it®  Onå thinç nicå abouô thió featurå ió that¬ iî 
initializinç thió buffer¬  á startuğ commanä line¬  possiblù con
sistinç oæ severaì commands¬ caî bå seô tï bå executeä wheneveò á 
colä booô (systeí startup© ió performed.

     Twï thingó musô bå knowî bù thå SYSLIÂ multiplå commanä linå 
routineº   (1©  ió thå multiplå commanä linå featurå engageä  anä 
(2©  wherå  ió thå multiplå commanä  linå  buffeò  located¿   Thå 
ZINIMÃ  routinå initializeó (oò changes© thå internaì SYSLIÂ buf
feò  whicè  containó  thå addresó oæ thå  multiplå  commanä  linå 
buffer®   Iæ  ZINIMÃ ió called¬  iô assumeó thaô HÌ containó  thå 
addresó  oæ thió buffeò anä telló SYSLIÂ thaô  multiplå  commandó 
arå  availablå  anä  wherå theù arå located®   Iæ ZINIMÃ  ió  noô 
called¬ SYSLIÂ assumeó thaô multiplå commandó arå noô available.

     Oncå  ZINIMÃ haó beeî called¬  thå SYSLIÂ routinå ZMCPTÒ  ió 
availablå tï thå programmer®  Thió routinå returnó thå addresó oæ 
thå nexô characteò iî thå multiplå commanä line®   Thå programmeò 
caî  theî  reaä thå resô oæ thå currenô  multiplå  commanä  line¬ 
realizinç  thaô eacè commanä ió separateä bù á semicoloî (;©  anä 
thaô  thå entirå linå ió terminateä bù á binarù 0®   ZMCPTÒ  alsï 
returnó  aî erroò codå iî A¬  iî whicè caså A=° anä thå Zerï Flaç 
ió Seô (Z© iæ multiplå commandó arå noô available.


     To illustrate, if the multiple command line is:

          myprog p1;myprog p2;myprog p3

and MYPROG.COM contains the following code:

          ...
          LXI  H,MCBASE  ; base adr of MC line
          CALL ZINIMC    ; init SYSLIB
          CALÌ ZMCPTÒ    » geô adò oæ firsô bytå oæ resô oæ MC
                         ;   adr returned in HL
          CALL PRINT
          DB   'The rest of the command line is -- ',0
          CALL PSTR      ; print rest of command line, as pted
                         ;   to by HL and ending in a binary 0
          ...

then the command 'myprog p1' will print:

          The rest of the command line is -- myprog p2;myprog p3

and the command 'myprog p2' will print:

          The rest of the command line is -- myprog p3



                    External Paths and SYSLIB

     Thå  externaì  path“ ió thå seconä  ZCPR²  featurå  supporteä 
extensivelù bù SYSLIB®  Again¬ likå mosô ZCPR² features¬ externaì 
pathó  maù bå enableä oò disableä aô thå discretioî oæ thå systeí 
programmer®   Iî ordeò tï understanä thå concepô oæ thå  externaì 
path¬ thå concepô oæ thå SYSLIÂ directory“ musô bå understood®  Iî 
thå SYSLIÂ vernacular¬  á directory“ ió á logicaì entitù oî á disë 
iî whicè fileó arå stored®  Iô ió designateä witè aî X-Ù coordin
ate¬  thå Ø coordinatå beinç thå namå oæ thå disë (A¬ B¬ C¬ etc.© 
anä thå Ù coordinatå beinç thå numbeò oæ thå useò areá (° tï 31)®  
Undeò  CP/Í  2.² anä ZCPR2¬  therå arå 3² directorieó oî eacè  oæ 
youò  disks¬  anä  thå overalì directorù systeí  (NOÔ  thå  nameä 
directorù system¬ tï bå discusseä later© identifieó theså direct
orieó bù thå form

          du:

wherå  'd§  ió  á letteò (A-P© anä 'u§ ió á useò  numbeò  (0-31)®  
Examples of directories are:

          A5:  B7:  A30: C12:


     Undeò  CP/Í 2.² anä ZCPR2¬  distincô fileó maù bå placeä  iî 
eacè  oæ thå directorieó anä bå handleä aó uniquå files¬  regard
lesó  oæ theiò names®   Specifically¬  á filå nameä TEST.TXÔ  maù 
residå iî directorieó A5:¬ A10:¬ A20:¬ anä B3:¬ anä therå wilì bå 
fouò  distincô fileó herå bù thå samå namå  (TEST.TXT)®   Editinç 
TEST.TXÔ iî A5º  doeó noô changå thå contentó oæ TEST.TXÔ iî  thå 
otheò  directories®   Onå exceptioî tï thió rulå  exists¬  namelù 
thaô  whicè occuró wheî thå DUPUSÒ prograí ió employed¬  anä thió 
wilì bå discusseä later.

     Undeò CP/Í 2.2¬  thå utilitù oæ theså directorieó waó  some
whaô  limiteä  since¬  oncå thå useò waó loggeä intï á  directorù 
likå  A5º  (hå issueä thå commanä 'A:§ iæ hå waó noô  alreadù  oî 
disë  Á  anä thå commanä 'USEÒ 5')¬  anù commanä hå issueä  whicè 
requireä á COÍ filå tï executå iô haä tï uså á COÍ filå whicè waó 
eitheò  iî hió currenô directorù oò oî anotheò disë iî  thå  samå 
useò  areá (iî whicè caså hå coulä issuå á commanä likå "A:PIP")®  
Hence¬  iæ hå wanteä tï separatå hió fileó intï useò areaó 5¬  6¬ 
anä · oî disë Aº  anä hå wanteä tï alwayó havå PIĞ available¬  hå 
haä tï havå á copù oæ thå PIP.COÍ filå iî alì threå useò areas.

     Problemó  werå immediatelù recognizeä witè thió  environmenô 
undeò  CP/Í 2.2¬  anä á prograí calleä DUPUSÒ waó releaseä  whicè 
createä  duplicatå directorù entrieó oæ á filå iî differenô  useò 
areas®   Iî thió way¬ additionaì directorù entrieó werå takeî up¬ 
pointinç tï thå samå file¬ buô thå filå itselæ diä noô havå tï bå 
duplicateä iî eacè useò area®   Thió waó nice¬  buô iô addeä dan
gers¬ especiallù wheî á filå waó changeä oò deleteä froí onå useò 
areá anä noô iî alì thå others®   ZCPR± camå ouô lateò tï relievå 
thió probleí anä eliminatå thå neeä foò DUPUSÒ tï somå extent.

     Undeò ZCPR1¬  thå systeí programmer¬  aô installatioî  time¬ 
coulä configurå ZCPR± tï dï á limiteä directorù searcè wheneveò á 
COÍ  filå waó tï bå executed®   Thå ZCPR± defaulô waó tï looë foò 
thå COÍ filå iî thå currenô disë anä currenô useò area¬  iæ  thió 
faileä  tï droğ dowî tï useò areá ° oî thå currenô disk¬  iæ thió 
faileä  tï  droğ  dowî tï disë Á anä useò areá  0¬  anä  iæ  thió 
failed¬ tï issuå thå standarä erroò messagå thaô thå COÍ filå waó 
noô  found®   DUPUSÒ anä itó associateä dangeró coulä bå  elimin
ated¬  anä  thå  useò coulä placå himselæ intï anù useò  areá  hå 
desired¬  keepinç  alì oæ hió systeí utilitieó oî disë Á iî  useò 
areá  0¬  and¬  wheneveò hå woulä issuå á  command¬  ZCPR±  woulä 
searcè foò it®   Thankó tï sucè á concept¬ ZCPR± alloweä thå useò 
tï creatå á workinç environmenô iî which¬  say¬ disë Bº containeä 
alì  oæ hió workinç fileó anä disë A:/useò ° containeä alì oæ hió 
COÍ files®   Hå coulä issuå anù commanä froí anù useò areá oî B:¬ 
saù  froí B5:¬  anä ZCPR± woulä searcè foò thå COÍ  file¬  movinç 
froí B5º tï B0º tï A0:.


     Thió was¬  iî mù opinioî (buô I'í prejudice)¬  á significanô 
enhancemenô  tï  thå CP/Í concept®   No÷ thå worë disë  coulä  bå 
totallù  dedicateä tï worë fileó (beinç devoiä oæ commands© whilå 
á  systeí  disë coulä contaiî alì oæ thå  user'ó  commands®   Thå 
ZCPR±  capabilitù tï movå froí onå disk/useò areá tï anotheò  waó 
nice¬  buô  stilì  somewhaô limited®   Thå ZCPR± useò  coulä  noô 
changå  thió  commanä searcè patè (á path“  being¬  iî  thå  ZCPR² 
definitions¬ á vectoò oæ directorieó alonç whicè á filå searcè ió 
performed© tï stoğ aô A10º insteaä oæ A0º withouô modifyinç ZCPR± 
anä reinstallinç it¬ foò instance®  Noò coulä hå specifù á longeò 
path¬ sucè aó á 4-directorù search¬ withouô somå effort.

     ZCPR²  significantlù  extendó thå commanä searcè  patè  ideá 
froí ZCPR1®  ZCPR² supportó á patè definition¬ whicè ió containeä 
iî  á memorù buffer®   Thå ZCPR² patè ió á serieó oæ bytå  pairs¬ 
thå  firsô  bytå indicatinç thå disë numbeò anä thå  seconä  bytå 
indicatinç  thå useò number¬  whicè maù bå oæ anù lengtè  anä  ió 
terminateä bù á binarù 0®   Internally¬ thå patè maù bå storeä aó 
á parô oæ ZCPR² itself¬ takinç uğ spacå withiî ZCPR2¬ oò externaì 
tï  ZCPR2¬  iî á buffeò iî lo÷ memorù (belo÷ 100H¬  sucè aó  40H¬ 
whicè É use© oò iî higè memorù (abovå thå BIOS¬  whicè ió wherå É 
currentlù placå mù multiplå commanä linå buffer).

     Iæ thå patè ió storeä internaì tï ZCPR2¬ iô cannoô typicallù 
bå  changeä bù thå programmeò iî hió utilities®   Iæ thå patè  ió 
externaì  tï ZCPR² iî á precisely-defineä locatioî (knowî bù  thå 
systeí  programmer)¬  theî  á programmeò maù writå  utilitieó  tï 
changå  thió  patè  aô will¬  addinç TONÓ oæ flexibilitù  tï  thå 
system!   ZCPR2¬  wheî  iô ió released¬  wilì includå  á  commanä 
calleä PATÈ iî itó distribution¬ anä thió commanä allowó thå useò 
tï changå hió ZCPR² patè aô wilì tï anythinç hå desires.

     Eacè  directorù  specifieä iî thå patè ió representeä  bù  á 
bytå pair®  Thå firsô bytå ió thå disë number¬ anä iô maù takå oî 
valueó froí ± tï 1¶ (binary© tï represenô diskó Aº  tï P:¬  oò iô 
maù  takå oî thå valuå oæ thå characteò '$§ (24H)¬  whicè  standó 
foò  thå currenô disë (thå disë thå useò ió  loggeä  into)®   Thå 
seconä bytå ió thå useò number¬  anä iô maù takå oî valueó froí ° 
tï 3± (binary© tï presenô useró ° tï 31®   Thå patè ió terminateä 
bù á binarù ° (whicè woulä bå iî thå placå oæ á disë number¬  anä 
° ió aî invaliä disë number).

     A path, stored in memory, could look like this:

          01H 24H    24H 00H    01H 00H   00H
             \          \          \       \__ End of Path
              \          \          \
               \          \          \__ Disk A/User 0
                \          \
                 \          \__ Current Disk/User 0
                  \
                   \__ Disk A/Current User


     Iî  designinç  thå  PATÈ  commanä  oæ  ZCPR2¬  É  havå  alsï 
establisheä  á  standarä waù tï represenô á ZCPR² patè  iî  text®  
Thå following¬ foò example¬ ió á PATÈ commanä whicè maù bå issueä 
by the user to set the path in the example above:

          PATH A$ $0 A0

     Thå  PATÈ commanä wilì bå discusseä agaiî wheî É coveò nameä 
directories.

     Gettinç  bacë tï pathó anä SYSLIB¬  twï SYSLIÂ utilitieó arå 
provideä  whicè  arå  designeä tï specificallù  deaì  witè  ZCPR² 
paths®  Theså utilitieó are:

          ï ZINIEXÔ -- telì SYSLIÂ thå baså addresó (addresó oæ 
               the first byte) of the ZCPR2 path to be used;
               note that this may be the address of any path,
               and not necessarily that of the ZCPR2 system,
               so many paths may be used by different programs
               under ZCPR2 (such as having a path for HELP
               commands and another path to access special
               programs)

               ZINIEXT expects the base address of a path to
               be passed to it in HL; if ZINIEXT is not called,
               the SYSLIB routines assume that there is no path
               and just check the current disk/current user when
               called

          o ZPFIND -- search for a file along the current path
               whose base was identified by a call to ZINIEXT
               for the file whose FCB is pointed to by DE;
               B is a flag, and if B=0, search just the path,
               while if B<>0, search the current disk/user
               first and then follow the path

               ZPFIND returns with the Zero Flag Clear (NZ)
               and A=0FFH if the file is found, and the
               disk number of the file in B (B=0 for disk A)
               and the user number of the file in C (0-31) if
               the file is found

               ZPFIND leaves the user logged into the directory
               he was in originally before the path search began



     Tï makå lifå eveî easieò foò thå SYSLIÂ  programmer¬  SYSLIÂ 
provideó  fouò  routineó whicè manipulatå useò anä disë areaó  sï 
thaô  thå  programmeò caî movå betweeî  theí  witè  ease®   Theså 
routines are:

          o PUTUD -- save the current disk/current user away in
                     an internal SYSLIB buffer; PUTUD affects
                     no registers

          o GETUD -- read the contents of the internal SYSLIB
                     buffer used by PUTUD and log the user into
                     his original disk/user; GETUD affects no
                     registers

          o LOGUD -- log the user into the disk/user specified
                     by BC; B is the disk number (B=0 for disk
                     A) and C is the user number (0-31); no
                     registers are affected by LOGUD

          o RETUD -- return the current user/disk numbers;
                     RETUD requires no inputs, and returns B with
                     the current disk (B=0 for disk A) and
                     C with the current user (0-31)


     Notå  thaô theså routineó mesè iî nicelù witè ZPFIND¬  whicè 
returnó  disë numbeò iî Â (B=° foò disë A© anä useò numbeò iî  C®  
Thå followinç codå illustrateó ho÷ thå SYSLIÂ programmeò maù  uså 
these routines to his advantage:


          ...
          LXI  H,MYPATH  ; Set ZCPR2 Path Base Address
          CALL ZINIEXT
          ...
          LXI  D,MYFCB   ; Find the desired file
          CALL INITFCB   ; Init FCB
          MVI  B,0FFH    ; Search current disk/user first
          CALL ZPFIND    ; Search along path
          JZ   FNF       ; Routine to execute if file not found
;
;  At this point, B=disk number and C=user number in which
;  file was found
;
          CALL PUTUD     ; Save current directory
          CALL LOGUD     ; Go to file's directory
          < Work With File -- Detail Left Out >
          CALL GETUD     ; Return to original directory
          ...
FNF:      ...            ; Routine to process if file not found
          ...
;
;  Path used by ZPFIND
;
MYPATH:   DB   '$',0     ; Current disk/user 0
          DB   1,'$'     ; Disk A/current user
          DB   1,0       ; Disk A/user 0
          DB   0         ; End of path
;
;  FCB for desired file
;
MYFCB:
          DB   0
          DB   'MYFILE TXT'
          DS   4
          DS   16
          DS   4         ; 36 bytes long


     Beforå  wå leavå thió subject¬  let'ó hiô jusô á couplå morå 
oæ  thå ZCPR2-specifiã routineó iî SYSLIÂ whicè maù bå usefuì  tï 
the programmer:

          o ZINICI -- this initializes the character used to
                      indicate the Current User or Disk to ZCPR2;
                      if not called, the ZCPR2 default of '$' is
                      selected

          o ZINIDMA -- this initializes the DMA address for Disk
                       I/O of the ZCPR2 utilities; if not called,
                       the ZCPR2 default of 80H is selected



          o ZCPRQ -- this returns a pointer to a set of buffers
                     which contain the following information:
                         Bytes     Contents
                           0       Multiple Command Buffer
                                   Available Flag; 0=no buffer
                          1-2      Multiple Command Buffer
                                   Address, if available
                          3-4      Address of External Path
                                   (pts to empty path if not
                                   initialized)
                           5       Current User/Disk Indicator
                          6-7      DMA Address

          o ZCPRQ2 -- this returns a pointer to a set of buffers
                      in the 2nd ZCPR2 module of SYSLIB:
                         Bytes     Contents
                           °       Maø Numbeò oæ Nameä Dirs
                          1-2      Address of Memory-Resident
                                   Named Directory Buffer
                          3-38     FCB for NAMES.DIR file

          o ZFSTAT -- this returns the attributes of the file
                      whose FCB is pointed to by DE; ZFSTAT
                      returns the following information:
                         B = System Flag (B=0 means Not Sys)
                         C = R/O Flag (C=0 means Not R/O)
                         A = File Found Flag (A=0 and Z mean
                              file NOT found, so BC invalid)


          o ZGPINS -- General Purpose Installation; with all of
                      these initializations to perform, I rapidly
                      became tired of coding up an installation
                      for SYSLIB as I wrote each ZCPR2 utility
                      program.  Hence, I added one more init
                      utility to SYSLIB -- ZGPINS.  This utility
                      assumes the program it resides in has a
                      set of standard ZCPR2 buffers starting at
                      location 103H, and it completely inits
                      SYSLIB based upon the contents of these
                      buffers.  The exact structure of these
                      buffers will not be discussed here, but the
                      filå SINSFORM.MAÃ iî thå SYSLIÂ distribu-
                      tion gives this information.




                  Named Directories and SYSLIB

     Thå  thirä  anä  finaì ZCPR2-specifiã featurå  supporteä  bù 
SYSLIÂ  ió  thaô oæ nameä directories®   Reiteratinç  á  previouó 
definition¬  á  directory“ ió á logicaì entitù oî á disë iî  whicè 
fileó arå stored®  Iô ió designateä witè aî X-Ù coordinate¬ thå Ø 
coordinatå beinç thå namå oæ thå disë (A¬  B¬  C¬ etc.© anä thå Ù 
coordinatå beinç thå numbeò oæ thå useò areá (° tï 31)®  Hence¬ á 
directorù  woulä bå somethinç likå disë A/useò µ oò  disë  B/useò 
12¬  anä iô ió designateä bù thå forí "du:¢ iî thå ZCPR² vernacu
lar:

          A5:  B12: C31: D0:

     Á nameä directory“ undeò ZCPR² (iô coulä alsï bå  implementeä 
undeò  CP/Í  2.² foò thaô matter¬  buô iô makeó morå senså  undeò 
ZCPR2©  ió á directorù whicè haó beeî identifieä iî á nameä  dir
ectorù filå (sucè filå calleä NAMES.DIÒ iî thå ZCPR²  vernacular© 
anä  haó á mnemoniã namå associateä witè it¬  likå WORË oò  JEFF®  
Alì  oæ thå ZCPR² utilitieó arå designeä tï supporô thió feature¬ 
anä theù permiô thå useò tï issuå commandó like:

          XDIR WORK:*.TXT
          MCOPY BACKUP:=*.MAC,BACKUP:=WORK:*.TXT
          ERASE TEXT:DEMO.TXT,TEMP:DEMO.TMP
          PROTECT *.COM,ROOT:*.COM RS
          CD TEXT:

     Thå nameó oæ thå directorù arå storeä iî á file¬  standardlù 
calleä NAMES.DIR¬ whicè shoulä typicallù bå locateä aô thå bottoí 
oæ  thå  commanä searcè patè oæ ZCPR² (thå lasô  directorù  ZCPR² 
stopó at)®   Wheî á ZCPR² utilitù receiveó á commanä containinç á 
directorù name¬  iô searcheó alonç thå ZCPR² patè foò  NAMES.DIR¬ 
loadó  it¬  anä trieó tï matcè thå namå giveî tï thå nameó storeä 
iî thió file®   Iæ nï match¬  iô issueó aî error»  otherwise¬  iô 
proceeds.

     Iî  ordeò  tï  reducå  thå overheaä  oæ  searchinç  foò  thå 
NAMES.DIÒ  file¬  ZCPR² maù bå optionallù configureä tï supporô á 
memory-residenô  nameä directorù buffer®   Iæ thió ió  done¬  thå 
contentó oæ á nameä directorù filå (NAMES.DIR© caî bå loadeä  anä 
storeä iî memory¬ and¬ oncå thå ZCPR² utilitieó kno÷ thió (bù thå 
ZFNINIÔ  routine)¬  theù  wilì looë herå beforå goinç oî  á  disë 
search®   Thió  dramaticallù reduceó thå overheaä wheî nameä dir
ectorieó arå referenced.

     Thå  ZCPR²  utilitù calleä CHDIÒ caî bå useä tï  creatå  anä 
ediô  á  NAMES.DIÒ file¬  aó welì aó movå froí onå  directorù  tï 
another®   CHDIÒ (CHangå DIRectory© wilì noô bå discusseä iî  anù 
further detail in this paper.


     SYSLIÂ   containó  fouò  routineó  whicè  deaì  witè   nameä 
directories.  They are:

          o ZFNINIT -- Init Named Directory Buffers
          o ZDNFIND -- Scan for Disk Directory Name
          o ZDNAME  -- Load All Disk Directory Name Data
          o ZFNAME  -- Named Directory File Name Scanner
                         (like FNAME)

     ZFNINIT is passed four arguments:

          HL = address of memory-resident named directory buffer
          DE = address of FCB (36 bytes) containing name of
               disk directory file (NAMES.DIR)
          C  = maximum number of names in NAMES.DIR
          A  = flag which indicates the following:
               if Bit 7 = 1, pay attention to DE and set buffer
               if Bit 6 = 1, pay attention to C and set buffer
               if Bit 5 = 1, pay attention to HL and set buffer

     Iæ ZFNINIÔ ió noô called¬  thå namå oæ thå directorù filå ió 
assumeä  tï bå NAMES.DIR¬  anä iô ió assumeä tï contaiî á maximuí 
of 64 names.

     ZDNAMÅ  loadó  thå contentó oæ thå NAMES.DIÒ filå  intï  thå 
memorù buffeò pointeä tï bù HÌ sï thaô thå programmeò maù  accesó 
thió informatioî aó hå desires®  Eacè entrù iî thió file¬ aó welì 
aó  thå  memory-baseä nameä directorù buffer¬  ió  structureä  aó 
follows:

          Byte 0: Disk Number (Disk A = 0)
          Byte 1: User Number
          Bytes 2-9: Directory Name (all caps), 8 chars max,
                     space fill at end

     So¬  representinç á NAMES.DIÒ filå iî assemblù language¬ onå 
may look like this:

          DB   0,0            ; disk A/user 0
          DB   'ROOT    '     ; directory named ROOT:
          DB   0,1            ; disk A/user 1
          DB   'MINEWORK'     ; directory named MINEWORK:
          DB   0,0            ; disk A/user 0
          DB   0              ; no entry, so ignored
          DS   7              ; don't care
          DB   1,0            ; disk B/user 0
          DB   'DEVELOPE'     ; directory named DEVELOPE:
          ...


     ZDNAMÅ compresseó thió informatioî somewhat¬  removinç thoså 
entrieó whicè arå empty®  Oî input¬ ZDNAMÅ expectó HÌ tï poinô tï 
á  dynamiã  memorù  buffeò (CODENÄ ió  gooä  foò  providinç  thió 
address).  On output, ZDNAME provides the following:

          HL = address of first entry in the buffer
          C  = number of valid entries
          B  = 0
          A  = error flag (A=0 and Z if NAMES.DIR not found or
                              memory overflow)

     ZDNAMÅ  wilì dï alì thå worë foò thå programmer®   Wheî  in
voked¬  iô searcheó alonç thå patè foò NAMES.DIÒ (startinç aô thå 
currenô disk/user)¬  logó intï thå directorù containinç thå firsô 
NAMES.DIÒ iô finds¬  loadó thå buffer¬  processeó thå buffer¬ anä 
returns¬ leavinç thå prograí loggeä intï itó originaì directory.

     Glancinç  aô thå SYSLIÂ referencå manual¬  notå thaô  ZDNAMÅ 
useó thå FI3$OPEÎ anä F3$GEÔ routines®   Hence¬  theså shoulä noô 
bå useä bù thå programmer®  Alsï notå thaô iô useó ZPFIND¬ sï thå 
programmeò  shoulä  initializå  thå  patè  usinç  ZINIEXÔ  beforå 
calling ZDNAME.  A sample code segment using ZDNAME follows:

          ...
          LXI  H,MYPATH  ; set ZCPR2 path for SYSLIB
          CALL ZINIEXT
          CALL CODEND    ; get beginning of scratch area in HL
          CALL ZDNAME    ; load memory buffer
          JZ   NERR      ; process error routine
          ...

     Thå nexô SYSLIÂ routine¬  ZDNFIND¬ ió useä tï quicklù deter
minå  thå directorù referreä tï bù á strinç oæ characteró oæ  thå 
forí  "du:¢ oò "dir:¢ (conventionaì ZCPR² directorù  nomenclaturå 
oò ZCPR² nameä directorù forí allowed).

     ZDNFIND accepts two inputs:

          HL = address of first byte of DIR: or DU: prefix
               this prefix may be terminated by a colon (:),
               space, or binary 0
          A  = flag; if A=0, ZDNFIND does not permit the DU:
               form to be used and assumes that only a DIR:
               form is given and issues an error if it is not

     ZDNFIND returns these values:

          HL = address of character which terminated the prefix
               (usually the address of the colon)
          B  = disk number (disk A = 1, or 0FFH if current disk)
          C  = user number (0-31, or 0FFH if current user)
          Zero Flag Set if error

Š     Again¬  ZDNFINÄ useó Bytå Inpuô Filå 3¬  sï thió filå shoulä 
noô bå activå wheî ZDNFINÄ ió called.


     Thå finaì nameä directorù routinå iî SYSLIÂ ió  ZFNAME®   Iô 
ió  á  filå  namå  scanner¬  likå FNAME¬  buô  iô  permitó  nameä 
directorieó tï bå used®  Oî input¬ DÅ pointó tï á 36-bytå FCÂ anä 
HÌ  pointó tï thå firsô bytå oæ á strinç tï scan®   Stringó  likå 
this may be evaluated by ZFNAME:

          HELP:*.HLP          A5:TEST.TXT
          C?:ABC.*            PASCAL:*.COM

     Notå thaô thå useò numbeò fielä oæ thå DUº  forí maù contaiî 
á questioî mark»  thió indicateó alì useò areas®  Thå samå valueó 
arå  returneä  aó  witè ZDNFIND¬  buô Ã caî alsï takå  oî  á  '?§ 
character¬  anä  thå scaî ió terminateä bù anù SYSLIÂ  delimiter¬ 
including:

          <Binary 0 or NULL>       <Space>
          = _ ; , < >

     An example on the use of ZFNAME:

          ...
          LXI  H,MYPATH  ; SET PATH FOR ZPFIND (USED BY ZFNAME)
          CALL ZINIEXT
          ...
          CALL PRINT
          DB   'Input Your File Name: ',0
          CALL BBLINE    ; GET LINE FROM USER
          RZ             ; ABORT IF EMPTY LINE
                         »   HÌ NO× POINTÓ TÏ FIRSÔ CHAÒ OÆ LINE
          LXI  D,FCB     ; PT TO FCB
          CALL ZFNAME    ; PARSE NAME AND GET DATA
          JZ   FERR      ; ERROR IF ZERO FLAG SET
;
;  B IS NOW DISK NUMBER, C IS NOW USER NUMBER, AND HL PTS TO
;  TERMINATING CHAR ... PROCESSING MAY NOW CONTINUE AS DESIRED
;
          ...
FERR:     ...            ; ERROR ROUTINE
          ...
MYPATH    EQU  40H       ; ZCPR2 PATH BASE
FCB:      DS   36        ; SYSLIB FCB
          ...

.fo 5 - Numbers, CRC Check, and Sort Routines          Page #

5.0 Numeric String Evaluation, CRC Check, and Sort Routines

     Thå  lasô threå setó oæ SYSLIÂ routineó whicè remaiî  tï  bå 
discusseä  deaì witè evaluatioî oæ ASCIÉ characteò stringó  whicè 
arå intendeä tï represenô numberó (like¬ "110¢ foò decimaì 11° oò 
"ABCH¢  foò  hexadecimaì ABC)¬  performinç erroò  checkinç  usinç 
Cycliã  Redundancù Checë algorithms¬  anä thå SYSLIÂ general-pur
poså sorô routines.


5.01 Numeric String Evaluation

     Recognizinç  thaô iô wilì bå occasionallù necessarù foò  thå 
programmeò tï bå ablå tï accepô á numbeò aó typeä iî bù thå  useò 
anä  converô iô tï á binarù forí thaô caî bå useä bù thå codå  oæ 
thå  program¬  É havå provideä SYSLIÂ witè á serieó oæ µ routineó 
which perform such conversions.  These routines are:

          o EVAL2  -- convert binary digit strings to binary
          o EVAL8  -- convert octal digit strings to binary
          o EVAL10 -- convert decimal digit strings to binary
          o EVAL16 -- convert hexadecimal digit strings to binary
          o EVAL   -- determine base employed by user based on
                        an optional suffix character and convert

     Iî  alì  cases¬  thå addresó oæ thå firsô characteò  oæ  thå 
strinç ió passeä tï thå routinå iî thå HÌ registeò pair¬  anä thå 
routinå  returnó  á 16-biô valuå iî DÅ anä aî 8-biô  valuå  iî  Á 
(A=E)®   Evaluatioî oæ thå strinç progresseó froí thå firsô char
acteò  untiì  aî invaliä digiô (foò thå appropriatå base© ió  en
countered¬  anä thå routinå returnó HÌ pointinç tï thå  characteò 
whicè terminateä thå scan.

     EVAL²  evaluateó binarù characteò stringó (onlù '0§ anä  '1§ 
arå  thå  valiä digits)®   Stringó likå "1010¢ arå evaluateä  anä 
converteä tï binary®   Giveî á strinç likå "1010B"¬  thå  routinå 
wilì  stoğ wheî iô encounteró thå "B¢ anä returî witè HÌ pointinç 
to this character.

     EVAL¸ evaluateó octaì characteò stringó (onlù '0§ tï '7§ arå 
thå  valiä digits)®   EVAL1° evaluateó decimaì characteò  stringó 
(onlù  '0§  tï '9§ arå thå digits)¬  anä EVAL1¶  evaluateó  hexa
decimaì characteò stringó (onlù '0§ tï '9§ anä 'A§ tï 'F§ arå thå 
digits¬ anä caså ió noô significanô witè thå letters).

     EVAÌ  ió thå grandaddù oæ thå group¬  anä iô acceptó stringó 
of the following forms:

          bbbbbbbbbbbbbbbbB -- b='0' or '1'; Binary string
          oooooooO or oooooooQ -- '0' <= o <= '7'; Octal string
          ttttt or tttttD -- '0' <= t <= '9'; Decimal string
          hhhhH or hhhhX -- '0' <= h <= 'F'; Hexadecimal string


     EVAÌ determineó thå typå oæ strinç useä anä calló thå appro
priatå routinå tï perforí thå conversion®  EVAÌ returnó onå otheò 
flaç thaî thå others» Carrù Flaç Seô meanó thaô aî invaliä strinç 
formaô  waó  given¬  anä HÌ pointó tï thå offendinç characteò  oî 
exit.

     Thå followinç ió aî examplå oæ á codå segmenô whicè  acceptó 
two numbers input by the user and adds them together:

          ...
          EXT  PRINT     ; USE SYSLIB PRINT STRING ROUTINE
          EXT  BBLINE    ; USE SYSLIB INPUT LINE EDITOR
          EXT  PHLDC     ; USE SYSLIB PRINT HL AS DEC ROUTINE
          EXT  CRLF      ; USE SYSLIB NEW LINE ROUTINE
          EXT  EVAL      ; USE SYSLIB EVAL ROUTINE
          ...
          CALL PRINT     ; PROMT USER
          DB   'Input Your Numbers, Separated by a Comma: ',0
          CALL BBLINE    ; GET LINE FROM USER
                         ;  HL POINTS TO FIRST ARGUMENT
          CALL EVAL      ; EXTRACT FIRST ARGUMENT
          JC   NUMERR    ; ERROR IF CARRY SET
          PUSH D         ; SAVE FIRST NUMBER ON STACK
          MOV  A,M       ; GET OFFENDING CHARACTER
          CPI  ','       ; ERROR IF IT IS NOT A COMMA
          JNZ  CERR
          INX  H         ; SKIP OVER THE COMMA
          CALL EVAL      ; GET THE 2ND NUMBER IN DE
          JC   NUMERR    ; PROCESS ERROR
          POP  H         ; GET FIRST NUMBER FROM STACK
          CALL CRLF      ; NEW LINE
          DAD  D         ; HL=HL+DE
          CALL PRINT
          DB   'The sum of these numbers is ',0
          CALL PHLDC     ; PRINT AS DECIMAL
          ...


     Aó  thå readeò caî see¬  thå EVAÌ familù oæ  routineó  makeó 
numeriã inpuô conversioî reallù easy.



5.02 Cyclic Redundancy Checking

     Thå SYSLIÂ CRÃ routineó maù bå useä tï checë thå validitù oæ 
aî  incominç seriaì bytå streaí oæ arbitrarù  length®   Theù  arå 
particularlù gooä iî makinç surå thaô á giveî filå containó valiä 
datá oò thaô datá transmitteä viá thå phonå lineó (aó peò á modeí 
program©  waó  correctlù received®   Theså routineó  computå  anä 
checë  á truå 16-biô Cycliã Redundancù Codå (CRC)¬  anä theiò uså 
will guarantee the detection of:

          o all single- and double-bit errors
          o all errors with an odd number of error bits
          o all burst errors of length 16 or less

Also, the CRC routines will detect the following:

          o 99.9969% of all 17-bit error bursts
          o 99.9984% of all possible longer error bursts

     Three sets of CRC routines are provided.  They are:

          CRC       CRC1        CRC2    Function
          CRCCLR    CRC1CLR   CRC2CLR   Clear CRC Accumulator
          CRCUPD    CRC1UPD   CRC2UPD   Update CRC Accumulator
          CRCDONE   CRC1DONE  CRC2DONE  Done and Return CRC Value

     The polynomials used by these routines are:
          CRC  = X^16 + X^12 + X^5 + 1
          CRC1 = X^16 + X^15 + X^2 + 1
          CRC2 = X^16 + X^15 + X^13 + X^7 + X^4 + X^2 + X + 1

     Thå  SYSLIÂ  programmeò neeä noô bå concerneä witè ho÷  thió 
polynomiaì ió applieä internallù ..®  jusô thaô iô doeó itó  job®  
Thå interesteä readeò ió inviteä tï examinå thå sourcå code®   Aó 
á  sidå note¬  CRC² ió useä bù thå publiã domaiî CRCË prograí  oæ 
Keitè Petersen.

     Thå  CRCCLÒ routinå requireó nï argumentó anä returnó  none®  
It has no effect on any register.

     Thå  CRCUPÄ  routinå  updateó thå CRÃ Accumulatoò  witè  thå 
valuå oæ thå nexô byte¬  whicè ió passeä tï iô iî thå Á register®  
No registers are affected by this routine.

     Thå  CRCDONÅ routinå returnó thå calculateä 16-biô CRÃ valuå 
iî  thå HÌ registeò pair®   Iô simplù returnó á valuå anä maù  bå 
called as many times as desired.



     Thå followinç codå segmenô illustrateó á typicaì waù tï  uså 
these routines:

          ...
          EXT  CRCCLR    ; CLEAR CRC
          EXT  CRCUPD    ; UPDATE CRC
          EXT  CRCDONE   ; RETURN CRC
          EXT  COMPHD    ; COMPARE HL TO DE AND RET W/Z IF EQUAL
          ...
;
;  ROUTINE TO COMPUTE TRANSMITTED CRC
;
CRC$MAKE:
          CALL CRCCLR    ; CLEAR ACCUMULATOR
          < Loop CALLing CRCUPD with Byte Values in A >
          CALL CRCDONE   ; GET VALUE
          PUSH H         ; SAVE IT
          ...
;
;  ROUTINE TO EVALUATE INCOMING DATA FOR VALID CRC
;
CRC$CHECK:
          CALL CRCCLR    ; CLEAR ACCUMULATOR
          < Loop CALLing CRCUPD with Byte Values in A >
          CALL CRCDONE   ; GET CRC VALUE IN HL
          POP  D         ; GET FIRST CRC VALUE IN DE
          CALL COMPHD    ; COMPARE HL TO DE
          JZ   OK        ; PROCESS IF OK
;
;  THE ERROR ROUTINE GOES HERE
;
          ...



5.03 The SYSLIB Sort Routines

     Therå   arå  twï  SYSLIÂ  routineó  whicè  givå  thå  SYSLIÂ 
programmeò  accesó tï á verù flexiblå sortinç system®   Thå  maiî 
routinå ió calleä SORT¬  anä iô provideó á utilitù whicè doeó  aî 
in-memorù  sorô  oæ á seô oæ fixed-lengtè records®   Thå  sortinç 
techniquå  useä ió á Shelì Sort¬  adapteä froí thå booë  Softwarå 
Tools“ bù Kernigaî anä Plaugher¬ publisheä bù Addison-Wesly¬ 1976¬ 
page 106.  This sort is much faster than the simple bubble sort.


     Thå SORÔ routinå caî bå instructeä tï perforí thå  in-memorù 
sorô  iî  onå  oæ  twï wayó -- witè oò  withouô  usinç  pointers®  
Sortinç  withouô usinç pointeró ió typicallù sloweò thaî  sortinç 
witè pointers¬ mainlù becauså wheî usinç pointers¬ á swağ ió donå 
bù  simplù  exchanginç pointeró (² bytå  values)¬  whilå  á  sorô 
withouô  pointeró  requireó á swağ tï completelù exchangå thå  n-
bytå  recordó  beinç sorted®   Thå onlù advantagå  tï  noô  usinç 
pointeró  ió  thå  savingó oæ thå spacå takeî uğ bù  thå  pointeò 
table®  Thió tablå requireó 2*(numbeò oæ entrieó tï bå sorted© iî 
bytes.

     Thå  SORÔ  ió controlleä bù passinç á pointeò  tï  thå  Sorô 
Specificatioî  Blocë (SSB© iî DÅ tï thå SORÔ routine®   Thió Sorô 
Specificatioî Blocë ió á serieó oæ siø 2-bytå wordó whicè contaiî 
the following information:

          Bytes 0&1 -- Starting Address of 1st Record
          Bytes 2&3 -- Number of Records to Sort
          Bytes 4&5 -- Size of Each Record (in Bytes)
          Bytes 6&7 -- Address of Compare Routine Provided
                         by the Programmer
          Bytes 8&9 -- Address of a Pointer Table (if needed)
          Byte 10   -- Flag; 0 means to use pointers, 0FFH not
          Byte 11   -- Unused

     Twï  routineó  arå provideä iî thå SSORÔ modulå  oæ  SYSLIB®  
Theù  arå  SSBINIT¬  whicè ió useä tï initializå bufferó  anä  ió 
describeä fullù iî thå SYSLIÂ referencå manual¬  anä SORT¬  whicè 
performó thå actuaì sort®   É wilì noô coveò SSBINIÔ herå ..® thå 
interested reader is invited to read the reference manual.

     SORÔ acceptó aó inpuô á pointeò tï aî SSÂ iî DÅ anä performó 
thå sort®  Nï erroró arå generated¬ anä nï registeró arå affecteä 
by SORT.  An example of a code sequence using SORT follows:

          ...
          EXT  SORT      ; SORT ROUTINE IN SYSLIB
          ...
          CALL CODEND    ; GET ADDRESS OF SCRATCH AREA FOR PTRS
          SHLD SSBPTR    ; SET ADDRESS IN SSB
          LXI  D,SSB     ; POINT TO SSB
          CALL SORT      ; DO THE SORT
          ...
;
;  THIS IS THE COMPARE ROUTINE
;
COMPARE:
          PUSH H         ; ONLY PSW MAY BE AFFECTED
          PUSH D
          PUSH B
          MVI  B,RECSIZ  ; SIZE OF RECORDS
CLOOP:
          LDAX D         ; COMPARE (DE) TO (HL)
          CMP  M
          JNZ  CDONE     ; RETURN WITH CARRY SET IF (DE)<(HL)
          INX  H         ; PT TO NEXT BYTE
          INX  D
          DCR  B         ; COUNT DOWN REQUIRED NUMBER OF BYTES
          JNZ  CLOOP
CDONE:
          POP  B         ; RESTORE REGISTERS
          POP  D
          POP  H
          RET            ; RETURN WITH CARRY SET IF (DE)<(HL)
                         ;   OR ZERO SET IF (DE)=(HL)
          ...
;
;  THE SORT SPECIFICATION BLOCK DEFINES THE SORT PARAMETERS
;
SSB:
          DW   REC1      ; ADDRESS OF FIRST RECORD
          DW   NREC      ; NUMBER OF RECORDS TO SORT
          DW   RECSIZ    ; SIZE OF EACH RECORD
          DW   COMPARE   ; ADDRESS OF COMPARE ROUTINE
SSBPTR:
          DS   2         ; ADDRESS OF POINTER TABLE, FILLED IN
                         ;   ABOVE
          DB   0,0       ; USE POINTERS
          ...
;
;  THE DATA TO SORT
;
REC1:
          DB   'THIS'    ; 4-BYTE RECORDS
          DB   'IS  '
          DB   'A   '
          DB   'TEST'
RECSIZ    EQU  4                   ; SIZE OF EACH RECORD
NREC      EQU  ($-REC1)/RECSIZ     ; NUMBER OF RECORDS
          ...Š.fo 6 - What is SYSLIB?  SYSLIB Overview               Page #

6.0 What is SYSLIB?  SYSLIB Overview

     Froí thå beginninç oæ thió document¬ SYSLIÂ (SYSteí LIBrary© 
waó  describeä aó á collectioî oæ oveò 13° subroutineó whicè  arå 
designeä  tï providå tï thå CP/Í 8080/Z8° assemblù languagå  pro
grammeò á seô oæ functionó upoî whicè hå caî builä hió  programs®  
Thió librarù ió intendeä tï relievå thå programmeò oæ thå tasë oæ 
frequentlù  "reinventinç  thå wheel¢ anä tï providå hií  witè  aî 
environmenô  oæ  reliablå tooló whicè encourageó structureä  pro
gramminç aô thå assemblù languagå level.

     Iî thió document¬ É havå takeî yoõ througè alì 130« routineó 
iî  SYSLIB¬  describinç  theí iî á functionaì  senså  anä  givinç 
exampleó  aó tï ho÷ É intendeä theí tï bå useä anä designeä  theí 
tï worë together.



6.01 Functional Overview of SYSLIB

     Thå  SYSLIÂ routineó arå groupeä intï á numbeò oæ functionaì 
categories.  In a nutshell, these categories are:

     Directory Manipulation Routines
          DIRF      DIRFS     DBUFFER   DPARAMS
          DFREE     FSIZE     DIRLOAD   DIRSLOAD
          DIRALPHA  DIRSEL    DIRPACK   DIRNPACK

     Numeric String Evaluation Routines
          EVAL      EVAL16    EVAL10    EVAL8
          EVAL2

     Byte-Oriented File Input/Output Routines (0<=n<=3)
          FIn$OPEN  FOn$OPEN  FIn$CLOSE FOn$CLOSE
          Fn$GET    Fn$PUT

     CP/M File Input/Output Routines
          F$OPEN    F$MOPEN   F$CLOSE   F$MAKE
          F$DELETE  F$RENAME  F$EXIST   F$READ
          F$WRITE

     File Name String Parser and FCB Initialization
          FNAME     INITFCB

     Input Line Editors
          BBLINE    BLINE     INLINE

     String Output Routines
          PRINT     LPRINT    PSTR      LPSTR


     Numeriã Outpuô Routineó
          PHL4HC    LHL4HC    MHL4HC    PHL5DC
          LHL5DC    MHL5DC    PHLDC     LHLDC
          MHLDC     PA2HC     LA2HC     MA2HC
          PA3DC     LA3DC     MA3DC     PADC
          LADC      MADC

     String and Value Comparison Routines
          COMPHD    COMPB     COMPBC    SCANNER
          INSTR

     Character-Oriented Input/Output Routines
          CRLF      LCRLF     CONDIN    CST
          CIN       RIN       COUT      LOUT
          POUT      CCOUT     CLOUT     CPOUT

     Math Routines
          ADDHD     SUBHD     MULHD     DIVHD
          NEGH      CMPH      ROTLH     ROTRH
          SHFTLH    SHFTRH    ANDHD     ORHD
          XORHD

     CRC Routines
          CRCCLR    CRC1CLR   CRC2CLR
          CRCUPD    CRC1UPD   CRC2UPD
          CRCDONE   CRC1DONE  CRC2DONE

     Random Number Generator Routines
          RNDINIT   RNDSEED   RND

     User/Disk Manipulation Routines
          PUTUD     GETUD     LOGUD     RETUD

     Sort Routines
          SSBINIT   SORT

     ZCPR2 Feature-Specific Routines
          ZINICI    ZINIDMA   ZINIMC    ZINIEXT
          ZGPINS    ZCPRQ     ZCPRQ2    ZMCPTR
          ZPFIND    ZFSTAT

     ZCPR2-Specific Named Directory Routines
          ZFNINIT   ZDNAME    ZDNFIND   ZFNAME

     Misãellaneous Routines
          BDOS      BIOS      CAPS      CAPSTR
          CATH      CLINE     CODEND    EN
          FILLB     FILLBC    HFILB     HFILBC
          MOVEB     MOVEBC    HMOVB     HMOVBC
          PAUSE     VERSION



6.02 SYSLIB Documentation and Files and SYSLIB Availability

     SYSLIÂ  documentatioî ió somewhaô extensive¬  consistinç  oæ 
(1©  á 112« pagå SYSLIÂ Useò anä Referencå Manual“ whicè  containó 
detailó  oî alì oæ thå SYSLIÂ routineó anä á seô oæ seveî  samplå 
programs¬  completå  witè á samplå assemblù anä ruî oæ eacè  pro
graí anä (2© á seô oæ 1³ HELĞ fileó whicè caî bå accesseä  onlinå 
via the HELP program (new release coming out shortly to SIG/M).

     Thå originaì SYSLIB¬  Versioî 1¬  ió currentlù availablå  iî 
Volumå 1³ oæ thå SIG/Í disks®   Uså oæ thió versioî ió noô recom
mendeä  becauså  thå versioî describeä iî thió  documenô  greatlù 
enhanceó  thå  featureó oæ thå originaì SYSLIÂ anä  thå  originaì 
SYSLIÂ haä somå problemó dealinç witè CP/Í 2.2®   Thå ne÷ SYSLIB¬ 
describeä  iî thió document¬  wilì bå availablå iî thå SIG/Í lib
rary.



6.03 Distribution Statement for SYSLIB

     SYSLIÂ ió releaseä tï thå publiã domain®   Anyonå whï wisheó 
tï USÅ iô maù dï sï witè nï stringó attached®  Thå authoò assumeó 
nï  responsibilitù  oò liabilitù foò thå uså oæ  SYSLIB®   Iô  ió 
copyrighteä bù thå author¬  Richarä Conn¬  whï haó solå rightó tï 
it®   SYSLIÂ  anä  itó  associateä documentatioî maù bå  solä  bù 
itselæ  oò aó aî independenô parô oæ á packagå oæ  programó  onlù 
witè  thå express¬  writteî consenô oæ thå author®   Thå  author¬ 
however¬ supportó thå uså oæ SYSLIÂ bù commerciaì softwarå devel
opers¬  anä  placeó nï restrictioî oî thå salå oæ programó  whicè 
arå  baseä oî SYSLIÂ anä uså routineó containeä withiî SYSLIÂ  tï 
perforí theiò majoò functions.


