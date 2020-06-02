.he                 SYSLIB User and Reference Manual
.fo  1 - Introduction                                      Page #
.pn 1



      SYSLIB -- An Integrated Library of Assembly Language
  Utility Subroutines for use with the Microsoft M80 Assembler


1.0  Introduction

1.01 What is SYSLIB?

     SYSLIÂ  (SYSteí LIBrary© ió á collectioî oæ oveò 13° subrou
tineó whicè arå designeä tï providå tï thå CP/Í 8080/Z8° assemblù 
languagå  programmeò á seô oæ functionó upoî whicè hå  caî  builä 
hió programs®  Thió librarù ió intendeä tï relievå thå programmeò 
oæ  thå tasë oæ frequentlù "reinventinç thå wheel¢ anä tï providå 
hií witè aî environmenô oæ reliablå tooló whicè encourageó struc
tureä programminç aô thå assemblù languagå level.

     Eacè  subroutinå withiî SYSLIÂ caî bå vieweä aó  á  reliablå 
"blacë box.¢  Thå subroutineó iî SYSLIÂ arå completelù documenteä 
withiî  thió 112« pagå manuaì anä thå SYSLIBx.HLĞ files¬  anä thå 
programmeò  ió consistentlù provideä witè thå followinç  informa
tion:
          1.  Name of Subroutine
          2.  Function it performs
          3.  What its inputs are
          4.  What its outputs are
          5.  What registers are affected by it
          6.  What other library routines it calls upon
          7.  What errors can occur and how it handles them

     Thå routineó withiî SYSLIÂ arå designeä tï worë togetheò anä 
complemenô eacè other®   Parameteò passinç ió consistenô  betweeî 
thå variouó subroutines»   Foò instance¬  alì routineó whicè neeä 
tï  bå  passeä á pointeò tï á Filå Controì Blocë arå passeä  thaô 
pointeò iî thå DÅ registeò pair®   Aó á generaì rule¬ iæ á regis
teò ió noô returneä aó aî outpuô froí thå SYSLIÂ subroutine¬ theî 
itó valuå ió noô affecteä (iô haó thå samå valuå wheî thå routinå 
ió exiteä aó iô haä wheî thå routinå waó called).

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
another routine within the module).Š
1.02 What is Needed to Use SYSLIB?

     Yoõ  neeä aî 8080- oò Z80-baseä microcomputeò witè aô  leasô 
48Ë  byteó oæ contiguouó memorù runninç CP/Í 2.2¬  thå  Microsofô 
M8°  assembleò tooì seô (specifically¬  thå M8° assembleò anä thå 
L8° linker)¬  anä thå usuaì seô oæ softwarå developmenô tooló (aî 
editoò and¬ preferably¬ á debugger© tï uså SYSLIB.



1.03 What Does SYSLIB Buy Me?

     Thå bottoí linå ió that¬  tï thå experienceä SYSLIÂ program
mer¬  SYSLIÂ haó thå potentiaì oæ beinç á significanô tooì  whicè 
enableó hií to:

          1.  Solve his programming task quickly
               -- becauså  hå spendó lesó timå writinç  com
    monly-useä subroutineó anä worryinç abouô ho÷ hió regis
    teró  arå  affecteä bù theså subroutineó anä  morå  timå 
    concentratinç oî thå probleí aô hand

          2.  Write space- and speed-efficient code
               -- becauså  alì  oæ thå SYSLIÂ routineó  havå 
    beeî gonå oveò timå anä timå agaiî tï reducå theiò  sizå 
    anä  makå  theí morå efficienô iî termó  oæ  speed»  foò 
    example¬  thå  SORÔ routinå ió á Shelì Sorô thaô caî  bå 
    calleä tï perforí thå sorô usinç pointeró (iî whicè caså 
    iô  exchangeó pointeró ratheò thaî recordó wheî iô needó 
    tï dï á swap© oò perforí thå sorô withouô usinç pointeró 
    (wheî spacå ió á factoò anä therå maù noô bå enougè rooí 
    foò á pointeò table)

          3®  Writå morå maintainablå code
               -- becauså SYSLIÂ ió designeä witè structureä 
    programminç philosophù iî mind» eacè subroutinå ió equi
    valenô  tï á procesó box¬  havinç (1© onlù onå  entrancå 
    anä onå exit¬  (2© á precisely-defineä function¬ anä (3© 
    á precisely-defineä seô oæ inpuô anä outpuô  parameters» 
    havinç  useä  SYSLIÂ foò somå timå now¬  thå authoò  haó 
    noteä thaô hió programminç thoughô processeó anä prograí 
    designó  havå tendeä morå anä morå towarä  end-in“  (top-
    dowî froí thå objectivå poinô oæ vie÷ anä bottom-uğ froí 
    thå SYSLIÂ subroutinå poinô oæ view)¬ structureä designó 
    thaô  hå  caî  gï bacë tï aô á lateò  datå  anä  readilù 
    decipheò anä modify


          4.  Reduce the programming effort
               -- becauså  SYSLIÂ provideó á numbeò oæ  verù 
    involveä routineó whicè would¬ iî themselves¬ takå quitå 
    somå  timå tï code»  foò example¬  thå DIRÆ routinå wilì 
    loaä thå directorù oæ á disë intï memory¬  selecô á  seô 
    oæ  fileó  froí thaô loadeä directorù aó specifieä bù  á 
    Filå Controì Blocë anä á flaç whicè indicateó whetheò tï 
    includå Systeí oò Non-Systeí fileó anä whaô useò areá ió 
    tï  bå examined¬  packó thå loadeä  directorù  (removinç 
    entrieó noô selecteä froí thå memorù buffer)¬  alphabet
    izeó  thå directorù entrieó bù filå namå anä typå oò  bù 
    filå  typå anä name¬  anä returnó á pointeò tï thå firsô 
    entrù anä á counô oæ thå numbeò oæ entrieó selected


     Iî manù ways¬  SYSLIÂ bringó somå oæ thå advantageó oæ  pro
gramminç  iî  á High-Ordeò Language¬  likå Ã oò  Pascal¬  tï  thå 
assemblù  languagå  programmer®  Iô  allowó hií tï  maintaiî  thå 
smalleò codå sizå anä greateò efficiencù whicè caî bå realizeä iî 
assemblù  languagå programminç anä simultaneouslù realizå  á  re
duceä  life-cyclå  cosô  (froí developmenô tï fieldinç  tï  post-
fieldinç  maintenancå  anä modification© oveò  assemblù  languagå 
programminç withouô á SYSLIB-likå tooì set.



1.04 How Do I Assemble with SYSLIB?

     Eacè  examplå iî Sectioî 2± oæ thió manuaì showó aî assemblù 
oæ thå samplå program®   É frequentlù uså á commanä file¬ whicè É 
calì M80.SUB¬  tï assemblå mù programs®   Thió commanä filå takeó 
onlù onå parameter¬  thå namå oæ thå filå tï bå assembleä WITHOUÔ 
its type (MAC is assumed).  Warning:  The command MUST be:

                        SUB M80 filename

and it MUST NOT be:

                      SUB M80 filename.typ

Iæ  iô  ió oæ thå latteò form¬  thå sourcå codå wilì  bå  deleteä 
durinç thå assemblù process¡  Yoõ maù wisè tï removå the

                           ERÁ $1.BAK 

commanä iî thå M80.SUÂ filå tï eliminatå thió problem®  É onlù dï 
this for a space savings.


     My M80.SUB command file is:

;  M80.SUB -- MACRO-80 Assembler and Linker
M80 =$1
SUB /A  PLEASE ABORT IF ERROR(S) EXIST
ERA $1.BAK
ERA $1.COM
L80 /P:100,$1,A:SYSLIB/S,$1/N,/U,/E
ERA $1.REL
;  ASSEMBLY COMPLETE

     É ruî ZCPR² insteaä oæ thå CP/Í 2.² CCP¬  anä É aí alwayó oî 
Drivå  Bº  doinç  mù  developmenô  work¬  whilå  mù  editoró  anä 
assembleró (anä SYSLIB.REL© arå oî Drivå A:®   Notå thaô thió  ió 
reflected in M80.SUB, where L80 looks for A:SYSLIB for the scan.



1.05 How Do I Learn to Use SYSLIB Effectively?

     Thió is¬ oæ course¬ opinion¬ buô É feeì thaô thå besô waù tï 
learn how to use SYSLIB would involve the following steps:

          1®   Studù  thå  SYSLIÂ manuaì iî aî overvie÷  fashion¬ 
familiarizinç  yourselæ  witè thå functionó  oæ  thå  subroutineó 
available

          2®   Studù iî somå detaiì thå samplå sourcå programó iî 
Sectioî 21¬ jumpinç bacë tï thå maiî bodù oæ thå manuaì froí timå 
tï  timå tï seå whù thå routineó É selecteä iî thå programó  werå 
used in the way I used them

          3®  Trù codinç á couplå oæ thå routineó iî thió manual¬ 
copying them verbatim and assembling them

          4®  Trù makinç uğ á fe÷ simplå problemó oæ youò owî anä 
use SYSLIB to code them

          5®   Applù  SYSLIÂ tï á significanô prograí yoõ wanô tï 
write

     É aí á stronç advocatå oæ writinç programó iî ordeò tï learî 
ho÷ tï program¬  anä É feeì thaô iô ió mosô importanô tï (1© gaiî 
aó  mucè familiaritù witè thå SYSLIÂ routineó aó yoõ caî anä  (2© 
tï writå programó usinç theså routines.




1.06 Who May Use SYSLIB?

     SYSLIÂ ió herebù releaseä tï thå publiã domain®   Anyonå whï 
wisheó tï USÅ iô maù dï sï witè nï stringó attached®   Thå authoò 
assumeó nï responsibilitù oò liabilitù foò thå uså oæ SYSLIB®  Iô 
ió copyrighteä bù thå author¬  Richarä Conn¬  whï haó solå rightó 
tï  it®   SYSLIÂ anä itó associateä documentatioî maù bå solä  bù 
itselæ  oò  aó aî independenô parô oæ á packagå oæ programó  onlù 
witè  thå express¬  writteî consenô oæ thå author®   Thå  author¬ 
however¬ supportó thå uså oæ SYSLIÂ bù commerciaì softwarå devel
opers¬  anä  placeó nï restrictioî oî thå salå oæ programó  whicè 
arå  BASEÄ oî SYSLIÂ anä uså routineó containeä withiî SYSLIÂ  tï 
perforí theiò majoò functions.



     É  hopå yoõ enjoù usinç SYSLIÂ anä finä iô tï bå aó usefuì á 
tool as I do.

                                        Richard Conn

.fo  2 - Directory Manipulation Routines                   Page #

2.0  SYSLIB Directory Manipulation Routines


2.01 Introduction
     Thió seô oæ SYSLIÂ routineó concernó itselæ witè thå loadinç 
oæ anä accesó oæ á disë directorù foò thå generaì purposeó oæ thå 
user.  Included in this set of routines are the functions of:

          1.  Preallocation of buffer space for the routines

          2.  Two routines which load all undeleted directory
               entries into a buffer, constantly checking for
               memory overflow as they go
                    DIRLOAD loads the first entry for each file
                         (this is the faster of the two)
                    DIRSLOAD loads the last entry for each file
                         (this routine is required if the
                              user wishes to compute file sizes)

          3.  A routine to determine the amount of free space on
               the disk

          4.  A routine to compute the size of a file in K

          5.  A routine to sort a loaded directory by file name
               and type or by file type and name

          6.  A routine to select (by marking) a set of directory
               entries which match a given ambiguous file spec

          7.  A routine to pack the loaded directory, leaving in
               it only those entries marked by the select routine



2.02 Generalized Routines -- DIRF and DIRFS
     Routine Name: DIRF and DIRFS
     Functionº
          Thió routinå initializeó thå buffeò area¬  loadó á disë 
directory¬  selectó  á  seô  oæ fileó froí thå  loadeä  directorù 
specifieä  bù  thå user'ó ambiguouó filå namå anä á  passeä  flaç 
(whicè indicateó iæ Systeí fileó arå selected¬  Non-systeí  fileó 
arå  selected¬  alì  useò  areaó  arå tï  bå  covered¬  anä  whaô 
particulaò  useò areá ió tï bå covereä iæ alì useò areaó arå  noô 
selected)¬ packó thå directory¬ anä alphabetizeó thå directorù bù 
filå namå anä filå type.
     Iæ  DIRÆ ió used¬  thå processinç proceedó fasteò sincå onlù 
thå  firsô entrù oæ eacè filå ió loadeä intï thå  memorù  buffer®  
Filå sizinç informatioî ió noô includeä iî thió load¬ however.
     Iæ DIRFÓ ió used¬ thå processinç ió somewhaô slower¬ buô thå 
lasô  entrù foò eacè filå ió loadeä ratheò thaî thå first®   Filå 
sizinç  informatioî  ió  containeä  iî  thió  entry¬   anä   thió 
informatioî caî bå useä bù thå FSIZÅ routine.

     Inputs:  HL points to a dynamic buffer which extends from
               after the user's code and buffer areas to the
               end of the TPA
              DE points to the first byte of the FCB used to
               specify the ambiguous file name; only the chars
               in the FN and FT fields are significant, so this
               need not be a true FCB and may be as short as 12
               bytes
              A is the selection flag, structured as follows:
               Bit 7 - If Set, Select Non-System Files
               Bit 6 - If Set, Select System Files
               Bit 5 - If Set, Select All User Areas
               Bits 4-0 - If Bit 5 is Cleared, contains number
                    of User Area to Select

     Outputs:  HL points to the first file entry in the buffer;
                each file entry is 16 bytes long
               BC contains the number of files selected
               A contains an error flag; A=0 and Zero Flag Set
                (Z) indicates TPA overflow error during load of
                directory entries; A<>0 and NZ indicates load OK

     Registers Affected:  HL, BC, PSW

     SYSLIB Routines Called:  DBUFFER, DIRLOAD, DIRSEL, DIRPACK,
                              DIRALPHA

     Special Error Conditions:  As outline for the A register
          above.



2.03 Buffer Allocation Routine -- DBUFFER
     Routine Name: DBUFFER
     Function:
          Thió  routinå allocateó thå buffeò spacå necessarù  foò 
thå  seô oæ directorù functionó iî general®   Iî  particular¬  iô 
allocateó thå necessarù spacå foò thå alphabetizatioî functioî aó 
welì aó thå loadeä directorù itself®   Thió routinå musô bå  useä 
iæ  thå  DIRALPHÁ  routinå  ió  tï bå  lateò  useä  tï  sorô  thå 
directory»  thió  routinå  allocateó alì thå spacå  necessarù  bù 
DIRALPHÁ tï sorô thå routinå (pointeò space)®  Iæ thió routinå ió 
called¬ iô ió noô necessarù tï calì thå DPARAMÓ routine.

     Inputs:  HL points to the beginning address of a dynamic
               buffer area which extends to under the CCP

     Outputs:  HL points to the first byte at which the directory
                entries are to be loaded
               A=0 and Zero Flag is Set (Z) if the CCP is
                already overrun; else, A<>0 and NZ

     Registers Affected:  HL, PSW

     SYSLIB Routines Called:  DPARAMS

     Special Error Conditions:  As indicated by A reg and Z flag



2.04 Disk Parameter Information Extraction Routine -- DPARAMS
     Routine Name:  DPARAMS
     Function:
     Thió  routinå  extractó necessarù informatioî froí thå  Disë 
Parameteò  Blocë (DPB© anä storeó iô awaù iî somå globaì  bufferó 
useä bù otheò Disë Directorù Routines®  Thå informatioî extracteä 
ió noô oæ generaì concerî bù thå programmer®   ALÌ THÅ PROGRAMMEÒ 
NEEDÓ  TÏ KNO× IÓ THAÔ THIÓ ROUTINÅ MUSÔ BÅ CALLEÄ AÔ LEASÔ  ONCÅ 
BEFORÅ THÅ DIRLOAÄ OÒ DIRSLOAÄ ROUTINÅ IÓ CALLED®  Iæ thå DBUFFEÒ 
routinå  ió  called¬  theî iô ió noô necessarù  tï  calì  DPARAMÓ 
again.
     Foò thå informatioî oæ thå reader¬ thå followinç informatioî 
ió extracted:
               BLKSHF <-- Block Shift Factor (1 Byte)
               BLKMSK <-- Block Mask (1 Byte)
               EXTENT <-- Extent Mask (1 Byte)
               BLKMAX <-- Max Number of Blocks on Disk (2 Bytes)
               DIRMAØ <-- Maø Numbeò oæ Diò Entrieó (² Bytes)
     Thió  routinå automaticallù adjustó foò versionó 1.´ anä 2.² 
oæ CP/Í anä ió compatablå witè botè versionó oæ CP/M.

     Inputs:  None

     Outputs:  None (Information Extracted into Buffers)

     Registers Affected:  None

     SYSLIB Routines Called:  None

     Special Error Conditions:  None



2.05 Free Space Computation Routine -- DFREE
     Routine Name: DFREE
     Function:
          Thió  routinå  computeó thå amounô oæ freå spacå (iî  Ë 
bytes© lefô oî disk.

     Inputs:  None

     Outputs:  DE = Amount of Free Disk Space in K Bytes

     Registers Affected:  DE

     SYSLIB Routines Called:  DPARAMS

     Special Error Conditions:  None




2.06 File Size Computation Routine -- FSIZE
     Routine Name: FSIZE
     Function:
          Thió  routinå  computeó thå sizå oæ á filå whoså  entrù 
(whicè  MUSÔ bå loadeä bù DIRSLOAD© ió pointeä tï  bù  HL®   Thió 
routinå wilì work¬ buô generallù returî incorrecô results¬ iæ thå 
entrù pointeä tï waó loadeä bù DIRLOAÄ instead.

     Inputs:  HL points to first byte of file entry

     Outputs:  DE contains the file size in K Bytes

     Registers Affected:  DE

     SYSLIB Routines Called:  DPARAMS

     Special Error Conditions:  None


2.07 Directory Load Routines -- DIRLOAD and DIRSLOAD
     Routine Names: DIRLOAD and DIRSLOAD
     Function:
          DIRLOAÄ  anä  DIRSLOAÄ loaä entrieó foò  alì  undeleteä 
fileó  oî  thå  currentlù loggeä iî disë intï thå  memorù  buffeò 
pointeä tï bù HL®  Alì entrieó arå 1¶ byteó long.
     DIRLOAÄ  ió fasteò thaî DIRSLOAD®   Iô loadó jusô thå  firsô 
entrù oæ eacè filå oî disk®   DIRLOAD¬  however¬  shoulä bå  useä 
onlù   iæ  filå  sizinç  informatioî  ió  noô  requireä  bù   thå 
applicationó program.
     DIRSLOAÄ  loadó  jusô thå LASÔ entrù oæ eacè filå  oî  disk®  
Thió  entrù containó thå necessarù filå sizinç informatioî  whicè 
maù bå useä bù FSIZÅ tï computå thå sizå oæ thå loadeä file.
     Iæ  thå  TPÁ ió filleä durinç DIRLOAÄ oò DIRSLOAÄ anä  therå 
arå stilì morå filå entrieó tï load¬  thå loaä wilì bå halteä anä 
aî erroò returî wilì bå madå tï thå caller®   Oî return¬  iæ  A=° 
anä  thå  Zerï  Flaç  ió Seô (Z)¬  theî á  loaä  erroò  occurred» 
otherwise¬ thå loaä waó OK.

     Inputs:  HL points to the first byte of the directory buffer
               area; this area extends from after the last buffer
               used by the applications program to the page
               before the CCP.  If alphabetization is to be done,
               the value returned in HL by DBUFFER is a correct
               input for DIRLOAD or DIRSLOAD
              A=0 and Zero Flag is Set (Z) if TPA Overflow;
               A<>0 and NZ if load OK

     Outputs:  BC is the number of files loaded into the buffer

     Registers Affected:  BC

     SYSLIB Routines Called:  None

     Special Error Conditions:  If TPA is filled and load is
          incomplete, A=0 and Zero Flag is Set (Z) as error indic


2.08 Directory Alphabetization Routine -- DIRALPHA
     Routine Name: DIRALPHA
     Function:
          Tï alphabetizå thå fileó iî thå directorù pointeä tï bù 
HÌ  bù eitheò filå namå anä typå (STEST.ASÍ goeó beforå TEST.AAA© 
oò bù filå typå anä namå (TEST.AAÁ goeó beforå STEST.ASM).

     Inputs:  HL points to first directory entry
              BC contains the number of files to sort
              Á ió thå sorô flag» A=° meanó sorô bù filå namå anä 
               then file type, A<>0 means by file type and name

     Outputs:  None (directory list is sorted)

     Registers Affected:  PSW

     SYSLIB Routines Called:  PRINT

     Special Error Conditions:
          Iô  ió possible¬  althï highlù unlikelù froí alì  testó 
     giveî  sï  far¬  thaô  DIRALPHÁ maù experiencå  aî  internaì 
     error.  If this happens, the message:
               DIRALPHA -- Pointer Error
     wilì bå printeä anä thå routinå wilì aborô tï CP/M®  Iæ thió 
     happens¬  pleaså  reporô  thió probleí anä  bå  prepareä  tï 
     duplicatå thå exacô situatioî whicè causeä thió erroò tï thå 
     author, Richard Conn.



2.09 Directory Entry Selection Routine -- DIRSEL
     Routine Name: DIRSEL
     Function:
          DIRSEÌ  selectó  alì  entrieó iî thå  directorù  buffeò 
whicè  matcè thå ambiguouó filå namå specifieä iî thå FÎ  anä  FÔ 
fieldó  oæ  thå  FCÂ pointeä tï bù DÅ upoî entrù  tï  DIRSEL®   Á 
selectioî  flaç ió alsï passeä tï DIRSEÌ iî thå Á  register¬  anä 
thió flaç telló DIRSEÌ whetheò oò noô tï includå Non-Systeí fileó 
anä Systeí fileó iî thå selectioî anä whetheò tï selecô fileó  iî 
alì useò areaó oò iî á particulaò useò area.
     DIRSEÌ  identifieó thå selecteä filå entrieó bù settinç  thå 
Mosô  Significanô Biô oæ thå firsô bytå oæ eacè oæ theså  entrieó 
tï ± iæ thå entrù ió selected®   DIRSEÌ makeó nï otheò changeó tï 
thå filå entrieó iî thå directorù buffer.


     Inputs:  HL points to the directory buffer
              DÅ  pointó tï thå FCÂ containinç thå  ambiguouó  FÎ 
               and FT fields; only the first 12 bytes are needed
              BC contains the number of files in the directory
              A contains a selection flag, organized as follows:
               Bit 7 - Select Non-System Files
               Bit 6 - Select System Files
               Bit 5 - Select Files in All User Areas
               Bits 4-0 - If Bit 5 is 0, indicates number of
                    User Area to select files from

     Outputs:  None (MSBs of selected entries are set)

     Registers Affected:  None

     SYSLIB Routines Called:  None

     Special Error Conditions:  None



2.10 Directory Pack Routine -- DIRPACK
     Routine Name:  DIRPACK
     Function:
          DIRPACË  restructureó thå directorù buffeò  tï  contaiî 
onlù thoså entrieó markeä bù DIRSEL®   Iî thió way¬ thoså entrieó 
NOÔ  markeä  bù DIRSEÌ arå discardeä froí thå  buffeò  (actually¬ 
jusô  takeî ouô oæ consideration¬  buô thå contentó oæ thå buffeò 
afteò  thå  lasô  selecteä entrù ió  noô  guaranteeä  tï  contaiî 
anythinç significant).
     Thå  Mosô  Significanô Biô oæ thå firsô bytå oæ alì  entrieó 
remaininç iî thå directorù buffeò ió reseô tï ° aó á sidå  effecô 
oæ DIRPACK.

     Inputs:  HL points to the directory buffer
              BC contains the number of files in the buffer

     Outputs:  BC contains the number of files (those selected by
                DIRSEL) remaining in the directory buffer

     Registers Affected:  BC

     SYSLIB Routines Called:  None

     Special Error Conditions:  None


2.11 Negative Directory Pack Routine
     Routine Name:  DIRNPACK
     Function:
          DIRNPACË  restructureó thå directorù buffeò tï  contaiî 
onlù  thoså  entrieó NOÔ markeä bù DIRSEL®   Iî thió  way¬  thoså 
entrieó markeä bù DIRSEÌ arå discardeä froí thå buffeò (actually¬ 
jusô takeî ouô oæ consideration¬  buô thå contentó oæ thå  buffeò 
afteò  thå  lasô  selecteä  entrù ió noô  guaranteeä  tï  contaiî 
anythinç significant).
     Thå  Mosô Significanô Biô oæ thå firsô bytå oæ  alì  entrieó 
remaininç  iî thå directorù buffeò ió reseô tï ° aó á sidå effecô 
oæ DIRNPACK.

     Inputs:  HL points to the directory buffer
              BC contains the number of files in the buffer

     Outputs:  BC contains the number of files (those NOT selected
                by DIRSEL) remaining in the directory buffer

     Registers Affected:  BC

     SYSLIB Routines Called:  DIRPACK

     Special Error Conditions:  None

.fo  3 - Numeric String Evaluation Routines                Page #

3.0  Numeric String Evaluation Routines

3.01 Evaluation of String at All Bases -- EVAL
     Routine Name:  EVAL
     Functionº
          Thió  routinå convertó thå characteò strinç pointeä  tï 
bù  HÌ  intï thå 16-biô binarù numbeò representeä  bù  it®   EVAÌ 
performó  thå  conversioî  untiì á non-hexadecimaì  characteò  ió 
encountered¬ aô whicè timå iô lookó aô thå lasô characteò anä thå 
previouó  characteò tï determinå iæ thå strinç ió representinç  á 
binary¬  octal¬  decimal¬  oò hexadecimaì number®   Inpuô  strinç 
characteró  maù bå upper- oò lower-case®   Valiä formató foò  thå 
inpuô strinç arå --
          bbbbbbbbbbbbbbbbB -- b=0 or b=1; Binary string
          ttttt or tttttD -- 0 <= t <= 9; Decimal string
          hhhhH or hhhhX -- 0 <= h <= F; Hexadecimal string
          oooooooO or oooooooQ -- 0 <= o <= 7; Octal string

     Inputs:  HL points to the first byte of the string to convert
              String is loaded in a buffer

     Outputs:  HL points to next character after converted string
               DE contains 16-bit value
               A = E
               CARRÙ  Flaç Seô meanó aî erroò waó encountereä  iî 
strinç format

     Registers Affected:  PSW, DE, HL

     SYSLIB Routines Called:  CAPS, EVAL16, EVAL10, EVAL8, EVAL2

     Speciaì  Erroò Conditionsº
          CARRÙ  Flaç Seô indicateó thaô aî erroò waó encountereä 
iî  thå  evaluatioî  oæ thå string»  iæ  so¬  HÌ  pointó  tï  thå 
offendinç character


3.02 Evaluation of String in Base 16 -- EVAL16
     Routine Name:  EVAL16
     Functionº
          EVAL1¶   convertó  thå  strinç  oæ  ASCIÉ   hexadecimaì 
characteró   pointeä  tï  bù  HÌ  intï  á  16-biô  binarù  value®  
Conversioî progresseó untiì aî invaliä hexadecimaì digiô (0-9¬ A-
F© ió encountered.

     Inputs:  HL points to the first byte of the string to convert
              String is loaded in a buffer

     Outputs:  HL points to the offending character
               DE contains the 16-bit value
               A = E

     Registers Affected:  PSW, DE, HL

     SYSLIB Routines Called:  CAPS

     Special Error Conditions:  -None-


3.03 Evaluation of String in Base 10 -- EVAL10
     Routine Name:  EVAL10
     Functionº
          EVAL1° convertó thå strinç oæ ASCIÉ decimaì  characteró 
pointeä  tï  bù  HÌ  intï  á  16-biô  binarù  value®   Conversioî 
progresseó untiì aî invaliä decimaì digiô (0-9© ió encountered.

     Inputs:  HL points to the first byte of the string to convert
              String is loaded in a buffer

     Outputs:  HL points to the offending character
               DE contains the 16-bit value
               A = E

     Registers Affected:  PSW, DE, HL

     SYSLIB Routines Called:  -None-

     Special Error Conditions:  -None-



3.04 Evaluation of String in Base 8 -- EVAL8
     Routine Name:  EVAL8
     Functionº
          EVAL¸  convertó  thå strinç oæ ASCIÉ  octaì  characteró 
pointeä  tï  bù  HÌ  intï  á  16-biô  binarù  value®   Conversioî 
progresseó untiì aî invaliä octaì digiô (0-7© ió encountered.

     Inputs:  HL points to the first byte of the string to convert
              String is loaded in a buffer

     Outputs:  HL points to the offending character
               DE contains the 16-bit value
               A = E

     Registers Affected:  PSW, DE, HL

     SYSLIB Routines Called:  -None-

     Special Error Conditions:  -None-


3.05 Evaluation of String in Base 2 -- EVAL2
     Routine Name:  EVAL2
     Functionº
          EVAL²  convertó  thå strinç oæ ASCIÉ binarù  characteró 
pointeä  tï  bù  HÌ  intï  á  16-biô  binarù  value®   Conversioî 
progresseó untiì aî invaliä binarù digiô (0-1© ió encountered.

     Inputs:  HL points to the first byte of the string to convert
              String is loaded in a buffer

     Outputs:  HL points to the offending character
               DE contains the 16-bit value
               A = E

     Registers Affected:  PSW, DE, HL

     SYSLIB Routines Called:  -None-

     Special Error Conditions:  -None-

.fo  4 - Byte-Oriented File Input/Output Routines          Page #

4.0 Byte-Oriented File Input/Output Routines

4.01 Introduction to Byte-Oriented File Input/Output Routines

     Thå  followinç  documentatioî  coveró thå  serieó  oæ  byte-
orienteä  filå input/outpuô routineó iî SYSLIB®   Theså  routineó 
allo÷ thå useò tï sequentiallù reaä froí (GET© anä writå tï (PUT© 
á filå oî á byte-for-bytå basis®   Hence¬  theså routineó providå 
aî exceptionallù simplå methoä foò handlinç inpuô froí anä outpuô 
tï á file.

     Á typicaì prograí whicè employó theså routineó musô opeî thå 
requireä fileó beforå doinç anù processing¬ musô theî perforí thå 
processinç  oî thå openeä files¬  anä musô theî closå  thå  fileó 
wheî  thå  processinç ió completå (closinç thå fileó ió  optionaì 
foò inpuô fileó anä mandatorù foò outpuô files).

     SYSLIÂ provideó fouò setó oæ routineó foò byte-orienteä filå 
inpuô anä output®  Theså routineó arå --

Input Open  Output Open  GET    PUT   Input Close  Output Close
----------  -----------  ---    --­   -----------  ------------
 FI0$OPEN    FO0$OPEN   F0$GET F0$PUT  FI0$CLOSE    FO0$CLOSE
 FI1$OPEN    FO1$OPEN   F1$GET F1$PUT  FI1$CLOSE    FO1$CLOSE
 FI2$OPEN    FO2$OPEN   F2$GET F2$PUT  FI2$CLOSE    FO2$CLOSE
 FI3$OPEN    FO3$OPEN   F3$GET F3$PUT  FI3$CLOSE    FO3$CLOSE

     Thió  systeí  allowó  thå useò tï havå uğ tï  ¸  fileó  opeî 
simultaneouslù -- fouò arå opeî foò inpuô usinç GEÔ anä fouò  arå 
opeî  foò  outpuô usinç PUT®   Foò example¬  thå followinç  ió  á 
samplå codå sectioî usinç theså routineó foò twï files:

          EXT  FI0$OPEN   ; DECLARE LIBRARY REFERENCES
          EXT  FO0$OPEN
          EXT  FI0$CLOSE
          EXT  FO0$CLOSE
          EXT  F0$GET
          EXT  F0$PUT
          ...
          LXI  D,FCBI    ; PT TO FCB OF INPUT FILE
          CALL FI0$OPEN
          LXI  D,FCBO    ; PT TO FCB OF OUTPUT FILE
          CALL FO0$OPEN
          ...
          [body containing CALL F0$GET and CALL F0$PUT where required]
          ...
          CALL FI0$CLOSE  ; CLOSE FILE
          CALL FO0$CLOSE
          ...
          END


     Notå thaô onlù thå routineó tï bå useä arå referenceä iî thå 
EXÔ statements®   Iæ yoõ dï noô neeä á particulaò routine¬ dï noô 
referencå  it®   Noô  referencinç aî unneedeä  routinå  generallù 
saveó thå overheaä memorù spacå oæ loadinç iô froí thå library.

     Eacè seô oæ INPUÔ OPEN¬  INPUÔ CLOSE¬  OUTPUÔ  OPEN¬  OUTPUÔ 
CLOSE¬  GET¬ anä PUÔ routineó ió containeä iî onå librarù module¬ 
sï  referencinç anù oæ theså routineó causeó thå entirå modulå tï 
bå  loaded¬  anä  alì  thå routineó arå accessablå  tï  thå  useò 
(provideä theù arå mentioneä iî thå externaì definitions© withouô 
anù   additionaì  memorù   overhead®    Specifically¬   FI0$OPEN¬ 
FI0$CLOSE¬  FO0$OPEN¬ FO0$CLOSE¬ F0$GET¬ anä F0$PUÔ arå containeä 
iî onå module¬  anä referencå tï anù oæ theså routineó loadó  thå 
entirå module» thå samå ió truå foò thå otheò setó oæ routines.

     Thå CLOSÅ routinå foò outpuô (FOn$CLOSE© ió ALWAYÓ required» 
iô  filló  thå resô oæ thå currenô blocë witè Ctrl-Ú followeä  bù 
<NULL¾  byteó anä properlù closeó file®   Thå CLOSÅ  routinå  foò 
inpuô (FIn$CLOSE© ió requireä ONLÙ IÆ yoõ arå goinç tï lateò opeî 
anotheò  filå  foò  inpuô usinç thå  correspondinç  OPEÎ  routinå 
(FIn$OPEN)®   FIn$CLOSÅ  onlù serveó tï reseô thå OPEÎ flaç (useä 
tï GEÔ tï ascertaiî thaô thå filå haó beeî properlù opened).



4.02 Byte-Oriented Input and Output File Open
     Routine Names:  FI0$OPEN, FI1$OPEN, FI2$OPEN, FI3$OPEN
     Functionº
          Opeî  thå filå whoså FCÂ ió pointeä tï bù DÅ foò  inpuô 
(uså witè F$GET).

     Inputs:  DE = ptr to FCB of file to open

     Outputs:  Z Flag is Error Indicator, A is Error Code

     Registers Affected:  PSW

     SYSLIB Routines Called:  Internal

     Special Error Conditions:  See Section on Error Codes



     Routine Names:  FO0$OPEN, FO1$OPEN, FO2$OPEN, FO3$OPEN
     Functionº
          Opeî thå filå whoså FCÂ ió pointeä tï bù DÅ foò  outpuô 
(uså witè F$PUT).

     Inputs:  DE = ptr to FCB of file to open

     Outputs:  Z Flag is Error Indicator, A is Error Code

     Registers Affected:  PSW

     SYSLIB Routines Called:  Internal

     Special Error Conditions:  See Section on Error Codes



4.03 Byte-Oriented Input and Output File Close
     Routine Names:  FI0$CLOSE, FI1$CLOSE, FI2$CLOSE, FI3$CLOSE
     Functionº
          Closå  thå filå previouslù openeä bù thå  correspondinç 
FI$OPEÎ  routine®   Uså  oæ  theså routineó ió  optionaì  iæ  thå 
anotheò  filå  wilì  noô bå openeä lateò iî thå  prograí  bù  thå 
correspondinç FI$OPEÎ routine.

     Inputs:  -None-

     Outputs:  Z Flag is Error Indicator, A is Error Code

     Registers Affected:  PSW

     SYSLIB Routines Called:  Internal

     Speciaì Erroò Conditions:  See Section on Error Codes



     Routine Names:  FO0$CLOSE, FO1$CLOSE, FO2$CLOSE, FO3$CLOSE
     Functionº
          Closå  thå filå previouslù openeä bù thå  correspondinç 
FO$OPEÎ routine®  Uså oæ theså routineó ió MANDATORÙ afteò outpuô 
tï thå filå (usinç thå correspondinç F$PUÔ routine© ió complete.

     Inputs:  -None-

     Outputs:  Z Flag is Error Indicator, A is Error Code

     Registers Affected:  -None-

     SYSLIB Routines Called:  Internal

     Speciaì Erroò Conditions:  See Section on Error Codes

Š
4.04 Byte-Oriented Input and Output
     Routine Names:  F0$GET, F1$GET, F2$GET, F3$GET
     Functionº
          Geô thå nexô bytå iî sequencå froí thå filå  previouslù 
openeä bù thå correspondinç FI$OPEÎ routine®  Bytå ió returneä iî 
Registeò A.

     Inputs:  -None-

     Outputs:  A = Next byte from file if no error
               If Error, NZ and A = Error Code

     Registers Affected:  PSW

     SYSLIB Routines Called:  Internal

     Speciaì Erroò Conditions:  See Section on Error Codes



     Routine Names:  F0$PUT, F1$PUT, F2$PUT, F3$PUT
     Functionº
          Puô  thå  bytå iî Registeò Á ontï thå enä oæ  thå  filå 
previouslù openeä bù thå correspondinç FO$OPEÎ routine.

     Inputs:  A = Byte to PUT

     Outputs:  Z Flag is Error Indicator, A is Error Code

     Registers Affected:  PSW

     SYSLIB Routines Called:  Internal

     Speciaì  Erroò Conditionsº  See Section on Error Codes



4.05 Error Return Codes

     Foò  eacè oæ thå routineó iî thió seô oæ byte-orienteä  filå 
I/Ï routines¬ thå Zerï Flaç anä thå Á Registeò plaù á keù rolå iî 
indicating the error conditions of the routines.

     Iæ  thå  Zerï  Flaç  ió Seô (Z© afteò  á  routinå  haó  beeî 
executed¬  theî thió indicateó thaô nï erroò haó occurred®  Thå Á 
Registeò  ió  eitheò  unaffecteä (iî mosô cases©  oò  containó  á 
returned value (if so indicated, as in Fn$GET routines).

     Iæ  thå  Zerï Flaç ió Cleaò (NZ© afteò á  routinå  haó  beeî 
executed¬  theî thió indicateó thaô aî erroò haó occurred®  Thå Á 
Registeò  no÷  containó  thå Erroò  Code®   Thå  followinç  tablå 
summarizeó  thå  Erroò  Codeó  whicè maù bå  returneä  iî  thå  Á 
Register.
Š
     The following display summarizes the Error Codes.


                     Summary of Error Codes
           Returned by Byte-Oriented File I/O Routines

          Code Meaning
          ---- -------

            1  GET or PUT attempted on an unopened file
            2  Disk Full (Ran out of space)
            3  Input File Not Found
            4  Attempt to Read Past EOF
            5  Directory Full
            6  Error in Closing a File
            7  Attempt to Open a File which is already Open


.fo  5 - CP/M File Input/Output Routines                   Page #

5.0 CP/M File Input/Output Routines

5.01 Introduction

     Thå followinç routineó arå general-purposå filå I/Ï routineó 
whicè  interfacå  tï CP/Í througè thå Entrù Poinô aô locatioî  5®  
Theù preservå BC¬  DE¬  anä HL¬ anä theù returî witè thå standarä 
CP/Í erroò codeó foò thå correspondinç routines.

     Specifically, these routines are --

          F$OPEN    Open a file
          F$MOPEN   Open/Create a file
          F$CLOSE   Close a file
          F$MAKE    Create a file
          F$DELETE  Delete a file
          F$RENAME  Rename a file
          F$EXIST   Test of existance of a file
          F$READ    Read a block (128 bytes) from a file
          F$WRITE   Write a block (128 bytes) to a file



5.02 Open a File
     Routine Name:  F$OPEN
     Functionº
          Opeî  thå  filå specifieä bù thå FCÂ pointeä tï bù  DE®  
Iæ filå noô found¬  F$OPEÎ returnó witè aî erroò codå iî Á (0FFH© 
anä Zerï Flaç Cleaò (NZ).

     Inputs:  DE = pointer to FCB

     Outputs:  A = Error Code and PSW Flags Set (Zero Flag)
                   0    --> No Error
                   0FFH --> File not opened

     Registers Affected:  PSW

     SYSLIB Routines Called:  BDOS, CAPS, CIN, COUT, CRLF, PRINT

     Special Error Conditions:  -None-




     Routine Name:  F$MOPEN
     Functionº
          Opeî  thå filå specifieä bù thå FCÂ pointeä tï  bù  DE®  
Iæ  filå ió noô found¬  F$MOPEÎ trieó tï creatå one®   Iô returnó 
thå  erroò codå oæ 0FFÈ iî Á iæ therå waó noô enougè rooí iî  thå 
disë directorù tï creatå thå directorù entry.

     Inputs:  DE = pointer to FCB

     Outputs:  A = Error Code and PSW Flags (Zero Flag) Set
                   0    --> No Error
                   0FFH --> File not opened

     Registers Affected:  PSW

     SYSLIB Routines Called:  BDOS, CAPS, CIN, COUT, CRLF, PRINT

     Special Error Conditions:  -None-



5.03 Close a File
     Routine Name:  F$CLOSE
     Function:
          Close the file whose FCB is pointed to by DE.

     Inputs:  DE = pointer to FCB

     Outputs:  A = Error Code
                   0    --> No Error
                   0FFH --> Error in closing file

     Registers Affected:  PSW

     SYSLIB Routines Called:  BDOS

     Special Error Conditions:  -None-




5.04 Create a File
     Routine Name:  F$MAKE
     Function:
          Create (Make) the file whose FCB is pointed to by DE.

     Inputs:  DE = pointer to FCB

     Outputs:  A = Error Code
                   0FFH --> No directory space available
                   Not 0FFH --> No Error; Value is byte address in
                                TBUFF (80H-0FFH) of directory entry
                                allocated to the FCB

     Registers Affected:  PSW

     SYSLIB Routines Called:  BDOS, F$DELETE

     Special Error Conditions:  -None-



5.05 Delete a File
     Routine Name:  F$DELETE
     Functionº
          Deletå thå filå whoså FCÂ ió pointeä tï bù DE®  Iæ filå 
doeó  noô  exist¬  nothinç happenó (nï erroò messagå oò  codå  ió 
given).

     Inputs:  DE = pointer to FCB

     Outputs:  -None-

     Registers Affected:  PSW

     SYSLIB Routines Called:  BDOS

     Special Error Conditions:  -None-



5.06 Rename a File
     Routine Name:  F$RENAME
     Functionº
          F$RENAMÅ  maù bå useä tï renamå á file®   Oî entry¬  DÅ 
ptó tï thå firsô twelvå byteó oæ thå file'ó FCÂ anä HÌ ptó tï thå 
firsô twelvå byteó oæ thå FCÂ foò thå ne÷ filå (thaô is¬ onlù thå 
FÎ anä FÔ fieldó arå significant¬  sï thå resô oæ aî FCÂ neeä noô 
bå  presenô  foò thió functioî tï work)®   F$RENAMÅ  containó  aî 
internaì FCÂ whicè ió structureä froí thå twï entrieó tï properlù 
rename the file.

     Inputs:  HL pts to 1st 12 bytes of new FCB
              DE pts to 1st 12 bytes of old FCB

     Outputs:  Zero Flag Set (Z) means error (file not found)

     Registers Affected:  PSW

     SYSLIB Routines Called: BDOS, FILLB, MOVEB

     Speciaì Erroò Conditionsº   Filå Noô Founä error¬  indicateä 
by Z flag



5.07 Test for the Existance of a File
     Routine Name:  F$EXIST
     Functionº
          F$EXISÔ testó foò thå presencå oæ thå filå whoså FCÂ ió 
pteä  tï bù DÅ iî thå currenô disk/useò area®   Iæ thió filå doeó 
noô  exisô iî thió area¬  F$EXISÔ returnó witè thå Zerï Flaç  Seô 
(Z); if this file does exist, F$EXIST returns with NZ.

     Inputs:  DE pts to FCB of file to test for

     Outputs:  Zero Flag Set (Z) means file not found; NZ means
                    file found

     Registers Affected:  PSW

     SYSLIB Routines Called:  BDOS

     Speciaì  Erroò Conditionsº  None




5.08 Read a Block from a File
     Routine Name:  F$READ
     Functionº
          Reaä  nexô blocë (12¸ bytes© froí thå openeä filå whoså 
FCÂ ió pointeä tï bù DÅ intï TBUFÆ (buffeò aô 80È - 0FFH).

     Inputs:  DE = pointer to FCB

     Outputs:  A = Error Code
                   0 --> No Error
                   1 --> Read past end of file
                   2 --> Reading unwritten data in random access

     Registers Affected:  PSW

     SYSLIB Routines Called:  BDOS

     Special Error Conditions:  -None-



5.09 Write a Block to a File
     Routine Name:  F$WRITE
     Functionº
          Writå  nexô blocë (12¸ bytes© froí TBUFÆ (buffeò aô 80È 
tï 0FFH© tï thå openeä filå whoså FCÂ ió pointeä tï bù DE.

     Inputs:  DE = pointer to FCB

     Outputs:  A = Error Code
                   0    --> No Error
                   1    --> Error in extending file
                   2    --> End of disk data
                   0FFH --> No more directory space

     Registers Affected:  PSW

     SYSLIB Routines Called:  BDOS

     Special Error Conditions:  -None-

.fo  6 - File Name String Parser and FCB Init              Page #

6.0 File Name String Parser and FCB Init

     Routine Name: FNAME
     Function:
          FNAMÅ  ió á filå namå scanner®   Pointinç tï thå  firsô 
characteò oæ á filå namå specificatioî oæ thå form:

               du:filename.typ

wherå  anù  parô oæ thå specificatioî ió optional¬  thió  routinå 
filló iî aî FCÂ witè zeroeó (3¶ bytes)¬  properlù initializeó thå 
FÎ (Filå Name© fielä iæ 'filename§ ió presenô anä FÔ (Filå  Type© 
fielä iæ 'typ§ ió present¬ anä returnó thå numbeò oæ thå selecteä 
disë  (iî  thå rangå froí ± foò Á tï 1¶ foò P© iæ 'd§ ió  presenô 
anä  thå numbeò oæ thå selecteä useò (iî thå rangå froí °  tï  3± 
anä  thå questioî marë '?§ character© iæ 'u§ ió present®   Iæ 'd§ 
ió noô present¬ 0FFÈ ió returneä foò iô tï indicatå currenô disk¬ 
anä  iæ 'u§ ió noô present¬  0FFÈ ió returneä foò iô tï  indicatå 
currenô user.

     Thå strinç pointeä tï bù HÌ ió noô á conventionaì strinç  iî 
thå  senså  oæ thå resô oæ thå SYSLIÂ routines®   Thió strinç  ió 
terminateä bù anù oæ thå followinç delims¬  aó opposeä bù  simplù 
alwayó beinç terminateä bù á binarù zero®  Thå delimiteò lisô is:

               <NULL or Binary 0>       <SP or Space>
               =    _    ;    ,    <    >

     Thå followinç arå valiä examples:
               test.txt   <-- FN=TEXT  FT=TXT, B reg = 0FFH,
                              C reg = 0FFH
               a:t        <-- FN=T  FT=<SP>, B reg = 1,
                              C reg = 0FFH
               5:t        <-- FN=T  FT=<SP>, B reg = 0FFH,
                              C reg = 5
               c10:x.y    <-- FN=X  FT=Y, B reg = 3,
                              C reg = 10


     Inputs:  HL points to the first byte of the target string
                    (which ends in a delimiter)
              DE pts to the first byte of a 36-byte long FCB

     Outputs:  B=Disk Number (1 for A to 16 for P, or 0FFH if
                    no disk specified)
               C=User Number (0 to 31 or '?' for all users, or
                    0FFH if no user specified)
               HL points to the character which ended the scan
               A = 0 and Zero Flag Set (Z) if invalid Disk or User
                    Specified; A = 0FFH and NZ if no error
     Registers Affected: PSW, BC, HL
     SYSLIB Routines Called:  CAPS
     Special Error Conditions:  None
Š
     Routine Name:  INITFCB
     Functionº
          INITFCÂ  simplù  clearó alì oæ thå fieldó oæ á  36-bytå 
     FCÂ  tï  zerï excepô foò thå FÎ anä FÔ (Filå Namå  anä  Filå 
     Type© fields¬ whicè iô leaveó untouched.

     Inputs:  DE = pointer to FCB buffer

     Outputs:  None

     Registers Affected:  None

     SYSLIB Routines Called:  FILLB

     Special Error Conditions:  None

.fo  7 - Input Line Editors                                Page #

7.0 Input Line Editors

     Aî  Inpuô Linå Editoò ió useä tï accepô á linå oæ texô  froí 
thå user¬ allowinç hií tï issuå commandó likå backspacå anä Ctrl-
Ø  (eraså  alì  oæ linå typeä sï far© tï ediô hió texô aó  hå  ió 
inputtinç  it®   Oncå thå texô haó beeî entered¬  thå Inpuô  Linå 
Editoò returnó tï thå callinç prograí witè thå user'ó texô storeä 
in a buffer.  This text is terminated by a binary 0.

     Twï oæ thå Inpuô Linå Editoró iî SYSLIÂ uså thå CP/Í BDOÓ tï 
providå thå linå editoò function®   Theù mainlù servå tï preservå 
thå  registeró  durinç  thå  functioî  calì  anä  tï  storå   thå 
terminatinç zerï aô thå enä oæ thå text®   Theù occupù lesó spacå 
than the third Input Line Editor, INLINE.

     Thå thirä Inpuô Linå Editor¬  INLINE¬  ió useä wheî securitù 
ió  important®   Unlikå  thå otheò two¬  wheî typinç á Ctrl-Ã  tï 
INLINE¬  thå  Inpuô  Linå  Editoò (anä callinç  program©  ió  noô 
aborteä anä controì returneä tï CP/M®   Instead¬  thå Ctrl-Ã chaò 
ió simplù storeä iî thå user'ó line®  Also¬ unlikå thå otheò two¬ 
INLINÅ  caî  bå  instructeä  tï  echï  oò  noô  echï  thå   inpuô 
characters®   Thió  featurå ió usefuì foò programó whicè wanô  tï 
inpuô  á  password®   INLINÅ  caî bå instructeä noô tï  echï  thå 
password¬  buô  iô wilì stilì providå thå linå editinç  functionó 
for the user so that he can correct mistakes if he makes them.


     Routine Name:  BBLINE
     Function:
          BBLINÅ provideó á verù convenienô interfacå tï thå BDOÓ 
foò  inpuô linå editoò functions®   Iô containó itó owî  internaì 
buffeò  foò storagå oæ thå inpuô linå (20° byteó allocated)¬  anä 
iô  returnó á pointeò tï thå firsô bytå oæ thå linå upoî  return®  
Thå  linå  storeä iî thió buffeò ió terminateä bù á  binarù  zerï 
(0).

     Tï  uså  BBLINE¬   thå  useò  neeä  onlù  calì  it¬  witè  á 
capitalizatioî flaç storeä iî thå Á Register®   Iæ Á ½ 0¬  BBLINÅ 
doeó noô capitalizå thå inpuô linå characters»  iæ Á <¾ 0¬ BBLINÅ 
capitalizeó  thå  inpuô linå characteró beforå returninç  tï  thå 
caller.

     Nï erroò codeó arå returneä bù BBLINE®  Oî return¬ HÌ pointó 
tï thå firsô bytå oæ thå inpuô linå anä Á containó á counô oæ thå 
numbeò oæ characteró iî thaô linå (noô countinç thå endinç zero).


     Inputs:  A=0 to Not Capitalize Line, A<>0 to Capitalize Line

     Outputs:  HL pts to first char in the line
               A is number of characters in the line (not
                    counting the ending zero)

     Registers Affected:  PSW, HL

     SYSLIB Routines Called:  CAPS

     Special Error Conditions:  None



     Routine Name:  BLINE
     Function:
          BLINÅ provideó á verù convenienô interfacå tï thå  BDOÓ 
foò  inpuô linå editoò functions®   Iô performó thå samå typå  oæ 
functioî  aó  BBLINE¬  buô iô doeó noô contaiî itó  owî  internaì 
buffer®   Thå useò ió expecteä tï providå sucè á buffer¬ whicè ió 
structureä aó follows:

               SIZE:     DB   <Size of Buffer>
               CCNT:     DS   1
               LINE:     DS   <Size of Buffer + 1>
 
BLINÅ returnó á pointeò tï thå firsô bytå oæ thå linå (LINE© upoî 
return®  Thå linå storeä iî thió buffeò ió terminateä bù á binarù 
zerï (0).

     Tï uså BLINE¬  thå useò neeä onlù calì it¬ witè á pointeò tï 
thå user'ó buffeò iî HÌ anä á capitalizatioî flaç storeä iî thå Á 
Register®   Iæ  Á ½ 0¬  BLINÅ doeó noô capitalizå thå inpuô  linå 
characters»   iæ  Á  <¾  0¬  BLINÅ  capitalizeó  thå  inpuô  linå 
characteró beforå returninç tï thå caller.

     Nï erroò codeó arå returneä bù BLINE®   Oî return¬ HÌ pointó 
tï thå firsô bytå oæ thå inpuô linå anä Á containó á counô oæ thå 
numbeò oæ characteró iî thaô line (not counting the ending zero).

     Inputs:  A=0 to Not Capitalize Line, A<>0 to Capitalize Line
              HL pts to first byte (SIZE) of user-supplied buffer

     Outputs:  HL pts to first char in the line
               A is number of characters in the line (not
                    counting the ending zero)

     Registers Affected:  PSW, HL

     SYSLIB Routines Called:  CAPS

     Special Error Conditions:  None



     Routine Name:  INLINE
     Functionº
          INLINÅ  allowó  thå useò tï inpuô á linå oæ  texô  froí 
CONº  intï thå buffeò pointeä tï bù HL®   Thå useò ió alloweä  tï 
ediô  thå  texô  aó  hå typeó it¬  anä  INLINÅ  respondó  tï  thå 
followinç editoò commands:

   Key Command    Function
     <BS>           Delete previous character and back up cursor
     <DEL>          Delete previous character and echo it
     <CR>           Input complete -- return to calling program
     <LF>           Skip down to next physical line and insert a
                      <CR> <LF> into buffer
     <TAB>          Tabulate to next tab stop (every 8)
     Ctrl-U,        Erase current line (clear buffer) and restart
       Ctrl-X         input
     Ctrl-R         Retype current line
     Ctrl-Å         Skiğ dowî tï nexô physicaì line» inserô 
                      nothing into buffer

     Oî exit¬  thå buffeò containó thå texô entereä followeä bù á 
<NULL¾ (binarù 0)»  thå <CR¾ typeä tï enä thå inpuô ió NOÔ placeä 
iî thå buffer.


    Inputs:  HL = pointer to input line buffer
              A = Echo Flag (A=0 Means Don't Echo Input)
     Outputs:  -None- (Input line buffer contains text typed by user)
     Registers Affected:  -None-
     SYSLIB Routines Called:  CCOUT, CIN, COUT, CRLF

     Speciaì  Erroò Conditionsº
          <BEL¾  (Beeğ aô CON:© ió outpuô iæ attempô ió  madå  tï 
deletå  characteò (<BS¾ oò <DEL>© beforå beginninç oæ  line®   Nï 
limiô  oò  erroò checkinç ió donå oî thå sizå oæ thå  inpuô  linå 
buffeò  (buffeò overflo÷ ió possible¬  sï iô ió recommendeä  thaô 
buffeò  ió madå arbitrarilù large)®   Hasè marë (#© ió printeä iî 
responså tï Ctrl-R¬ Ctrl-U¬ anä Ctrl-X.

     Noteº   INLINÅ  offeró  twï featureó noô founä iî BLINÅ  anä 
BBLINE®   First¬  iô cannoô bå aborteä bù á Ctrl-C» thió ió good¬ 
sincå  iô  caî bå useä iî "secure¢ programó withouô feaò  oæ  thå 
useò breakinç ouô oæ thå program®  Second¬ iô caî bå madå tï echï 
oò  noô  echï  thå  input»  thió  provideó  somå  protectioî  foò 
inputtinç sensitivå information¬ likå á password.

     INLINÅ  essentiallù  provideó alì oæ thå conventionaì  inpuô 
linå editoò functions®   Iô ió somewhaô morå flexiblå thaî  BLINÅ 
anä  BBLINE¬  buô thå tradeofæ ió thaô INLINÅ takeó uğ morå spacå 
thaî eitheò BLINÅ oò BBLINE®   Iæ securitù ió noô required¬ iô ió 
recommendeä thaô thå programmeò emploù BLINÅ oò BBLINÅ insteaä oæ 
INLINE.


.fo  8 - String Output Routines                            Page #

8.0 String Output Routines -- PRINT, LPRINT, PSTR, LPSTR

     Routine Names:  PRINT, LPRINT
     Functionº
          Prinô  strinç pointeä tï bù thå returî addresó oî  CONº 
(PRINT©  oò LSTº  (LPRINT)®   Strinç ió terminateä bù á binarù 0®  
Controì ió returneä tï bytå followinç string.

     Inputs:  Return Address = pointer to string to be printed

     Outputs:  HL points to byte after string
               (string is printed on CON: or LST:)

     Registers Affected:  HL

     SYSLIB Routines Called:  PSTR (for PRINT); LSTR (for LPRINT)

     Speciaì Erroò Conditions:
          Thå strinç MUSÔ bå terminateä bù á binarù 0!!!



     Routine Names:  PSTR, LPSTR
     Functionº
          Prinô  strinç pointeä tï bù HÌ oî CONº  (PSTR© oò  LSTº 
(LPSTR)®  Strinç ió terminateä bù á binarù 0.

     Inputs:  HL = pointer to string to be printed

     Outputs:  -None- (string is printed on CON: or LST:)

     Registers Affected:  -None-

     SYSLIÂ  Routineó Calledº  CCOUT¬  COUÔ (foò PSTR)»
                               LCOUT¬ LOUÔ (foò LPSTR)

     Speciaì Erroò Conditions:
          Thå strinç MUSÔ bå terminateä bù á binarù 0!!!

.fo  9 - Numeric Output Routines                           Page #

9.0 Numeric Output Routines

9.01 Output HL as 4 Hexadecimal Characters

     Routine Names:  PHL4HC, LHL4HC
     Functionº
          Prinô  HÌ  aó fouò (4© hexadecimaì characteró  oî  CONº 
(PHL4HC© oò LSTº (LHL4HC).

     Inputs:  HL = value to be printed

     Outputs:  -None- (Value is printed)

     Registers Affected:  -None-

     SYSLIB Routines Called:  PA2HC (for PHL4HC);
                              LA2HC (for LHL4HC)

     Special Error Conditions:  -None-



     Routine Name:  MHL4HC
     Functionº
          Storå  HÌ aó fouò (4© hexadecimaì characteró iî thå  4-
bytå memorù buffeò pointeä tï bù DE®  Oî return¬ DÅ pointó tï thå 
bytå followinç thió buffer.

     Inputs:  HL = value to be converted and stored
              DE points to 4-byte buffer

     Outputs:  DE points to byte after buffer

     Registers Affected:  DE

     SYSLIB Routines Called:  MA2HC

     Special Error Conditions:  -None-



9.02 Output HL as 5 Decimal Character

     Routine Names:  PHL5DC, LHL5DC
     Functionº
          Prinô  HÌ  aó  fivå  (5©  decimaì  characteró  oî  CONº 
(PHL5DC© oò LSTº (LHL5DC).

     Inputs:  HL = value to be printed

     Outputs:  -None- (Value is printed)

     Registers Affected:  -None-

     SYSLIB Routines Called:  POUT (for PHL5DC); LOUT (for LHL5DC)

     Special Error Conditions:  -None-



     Routine Name:  MHL5DC
     Functionº
          Storå  HÌ aô fivå (5© decimaì characteró iî  memorù  iî 
thå 5-bytå buffeò pointeä tï bù DE®   Oî return¬ DÅ pointó tï thå 
bytå afteò thió buffer.

     Inputs:  HL = value to be converted and stored
              DE points to a 5-byte buffer

     Outputs:  DE points to the byte following the buffer

     Registers Affected:  DE

     SYSLIB Routines Called:  -None-

     Special Error Conditions:  -None-



9.03 Output HL as Up to 5 Decimal Character with Leading Spaces

     Routine Names:  PHLDC, LHLDC
     Functionº
          Prinô  HÌ  aó  uğ tï fivå (5© decimaì  characteró  witè 
leadinç spaceó (<SP>© oî CONº (PHLDC© oò LSTº (LHLDC).

     Inputs:  HL = value to be printed

     Outputs:  -None- (Value is printed)

     Registers Affected:  -None-

     SYSLIB Routines Called:  POUT (for PHLDC); LOUT (for LHLDC)

     Special Error Conditions:  -None-Š
     Routine Name:  MHLDC
     Functionº
          Storå  HÌ  aó uğ tï fivå (5©  decimaì  characteró  witè 
leadinç spaceó iî thå 5-bytå memorù buffeò pointeä tï bù DE.

     Inputs:  HL = value to be converted and printed
              DE points to the 5-byte buffer

     Outputs:  DE points to the byte after the buffer

     Registers Affected:  DE

     SYSLIB Routines Called:  -None-

     Special Error Conditions:  -None-


9.04 Output A as 2 Hexadecimal Characters

     Routine Names:  PA2HC, LA2HC
     Functionº
          Prinô  Á  aó  twï (2© hexadecimaì  characteró  oî  CONº 
(PA2HC© oò LSTº (LA2HC).

     Inputs:  A = value to be printed

     Outputs:  -None- (Value is printed)

     Registers Affected:  -None-

     SYSLIÂ Routineó Calledº   EÎ (foò both)»  POUÔ (foò  PA2HC)» 
LOUÔ (foò LA2HC)

     Special Error Conditions:  -None-



     Routine Name:  MA2HC
     Functionº
          Storå Á aó twï (2© hexadecimaì characteró iî thå 2-bytå 
memorù  buffeò pointeä tï bù DE®   Oî return¬  DE pointó tï  bytå 
afteò buffer.

     Inputs:  A = value to be converted and stored
              DE points to 2-byte buffer

     Outputs:  DE points to byte after this buffer

     Registers Affected:  DE

     SYSLIB Routines Called:  EN

     Special Error Conditions:  -None-
Š
9.05 Output A as 3 Decimal Characters

     Routine Names:  PA3DC, LA3DC
     Functionº
          Prinô Á aó threå (3© decimaì characteró oî CONº (PA3DC© 
oò LSTº (LA3DC).

     Inputs:  A = value to be printed

     Outputs:  -None- (Value is printed)

     Registers Affected:  -None-

     SYSLIB Routines Called:  POUT (for PA3DC); LOUT (for LA3DC)

     Special Error Conditions:  -None-



     Routine Name:  MA3DC
     Functionº
          Storå  Á aó threå (3© decimaì characteró iî thå  3-bytå 
memorù buffeò pointeä tï bù DE®  Oî return¬ DE pointó tï thå bytå 
afteò thå buffer.

     Inputs:  A = value to be converted and stored
              DE points to the 3-byte buffer

     Outputs:  DE points to the byte after the buffer

     Registers Affected:  DE

     SYSLIB Routines Called:  -None-

     Special Error Conditions:  -None-


9.06 Output A as Up to 3 Decimal Characters with Leading Spaces

     Routine Names:  PADC, LADC
     Functionº
          Prinô  Á  aó  uğ tï threå (3© decimaì  characteró  witè 
leadinç spaceó (<SP>© oî CONº (PADC© oò LSTº (LADC).

     Inputs:  A = value to be printed

     Outputs:  -None- (Value is printed)

     Registers Affected:  -None-

     SYSLIB Routines Called:  POUT (for PADC); LOUT (for LADC)

     Special Error Conditions:  -None-
Š
     Routine Name:  MADC
     Functionº
          Storå  Á  aó uğ tï threå (3©  decimaì  characteró  witè 
leadinç spaceó iî thå 3-bytå memorù buffeò pointeä tï bù DE®   Oî 
return¬ DE pointó tï thå bytå afteò thå buffer.

     Inputs:  A = value to be converted and stored
              DE points to the 3-byte memory buffer

     Outputs:  DE points to the byte after the buffer

     Registers Affected:  DE

     SYSLIB Routines Called:  -None-

     Special Error Conditions:  -None-

.fo 10 - String and Value Comparison Routines              Page #

10.0 String and Value Comparision Routines

     Routine Name:  COMPHD
     Functionº
          Comparå HÌ tï DE®   Oî return¬  Zerï Flaç Seô =¾ HL=DE¬ 
Carrù Flaç Seô =¾ HL<DE.

     Inputs:  HL, DE -- Values to compare

     Outputs:  Zero and Carry Flags

     Registers Affected:  PSW

     SYSLIB Routines Called:  -None-

     Special Error Conditions:  -None-



     Routine Names:  COMPB, COMPBC
     Functionº
          Vectoò Comparå Routines®  Comparå thå vectoò pointeä tï 
bù  HÌ witè thaô pointeä tï bù DÅ (Vectoró arå oæ equaì  length)®  
Vectoró  arå Â byteó lonç foò COMPÂ anä BÃ byteó lonç foò COMPBC®  
Oî  exit¬  Zerï  Flaç Seô indicateó thaô vectoró  arå  identical» 
Carrù Flaç Seô indicateó thaô thå vectoò pointeä tï bù HÌ ió lesó 
thaî thå vectoò pointeä tï bù DE.

     Inputs:  HL, DE -- Pointers to vectors to compare
              B (for COMPB), BC (for COMPBC) -- number of bytes
               in vectors

     Outputs:  Zero and Carry Flags

     Registers Affected:  PSW

     SYSLIB Routines Called:  -None-

     Special Error Conditions:  -None-



     Routine Name:  SCANNER
     Functionº
          SCANNEÒ scanó thå vectoò oæ byteó pointeä tï bù HÌ  foò 
thå  vectoò oæ byteó pointeä tï bù DE®   Thå HL-bytå vectoò ió  Â 
byteó lonç anä thå DE-bytå vectoò ió Ã byteó long®  Oî return¬ iæ 
found¬ HÌ pointó tï thå beginninç locatioî withiî thå originaì HÌ 
vectoò  oæ  thå locateä vectoò anä thå Zerï Flaç ió Set»  iæ  noô 
found¬ Zerï Flaç ió noô seô anä HÌ ió noô affecteä (pointó tï thå 
beginninç oæ thå originaì HL-bytå vector).


     Inputs:  HL = Pointer to vector to be scanned
              DE = Pointer to vector to scan for
              B = Number of bytes in HL-vector
              C = Number of bytes in DE-vector

     Outputs:  If found, Zero Set and HL pts to located vector
               If not found, Zero Reset and HL unaffected

     Registers Affected:  PSW, HL

     SYSLIB Routines Called:  -None-

     Speciaì  Erroò  Conditionsº   Automatiã  succesó  iæ  vectoò 
searcheä foò ió null.



     Routine Name:  INSTR
     Functionº
          INSTRINÇ  Function®   Scaî thå strinç pointeä tï bù  HÌ 
foò thå strinç pointeä tï bù DE®   Á strinç ió á vectoò oæ  byteó 
terminateä bù á binarù 0.

          Oî return¬  iæ found¬ Zerï Flaç ió Seô anä HÌ pointó tï 
1sô bytå oæ substrinç withiî scanneä string»  iæ noô found¬  Zerï 
Flaç ió noô seô anä HÌ ió noô affected.


     Inputs:  HL = Pointer to string to be scanned
              DE = Pointer to string to scan for

     Outputs:  If found, Zero Set and HL pts to located substring
               If not found, Zero Reset and HL unaffected

     Registers Affected:  PSW, HL

     SYSLIB Routines Called:  -None-

     Speciaì Erroò Conditions:
          Automatiã succesó iæ strinç searcheä foò ió null.
.fo 11 - Character Input/Output Routines                   Page #

11.0 Character Input/Output Routines

11.01 <CR> <LF> Output

     Routine Names:  CRLF, LCRLF
     Function:
          Print <CR> and <LF> on CON: (CRLF) or LST: (LCRLF).

     Inputs:  -None-

     Outputs:  -None- (<CR> <LF> is printed)

     Registers Affected:  -None-

     SYSLIB Routines Called:  POUT (for CRLF); LOUT (for LCRLF)

     Special Error Conditions:  -None-



11.02 Conditional Input

     Routine Name:  CONDIN
     Functionº
          Inpuô  á  characteò  froí CONº  iæ  onå  ió  available» 
otherwise¬  returî  á  flaç  statinç  thaô  á  characteò  ió  noô 
availablå oî CON:.

     Inputs:  -None-

     Outputs:  A = character typed at CON: (if available)
               Zero Flag is set (Z) if no character is available
               Zero Flag is reset (NZ) if character is available

     Registers Affected:  PSW

     SYSLIB Routines Called:  CST, CIN

     Special Error Conditions:  -None-


11.03 General Input Routines

     Routine Name:  CST
     Functionº
          Inpuô thå statuó oî CONº  iî Registeò A®   Iæ Reaä Datá 
Available¬ A=0» otherwise¬ A=1.

     Inputs:  -None-

     Outputs:  A = Console Status
                   0 --> Read Data Available (RDA)
                   1 --> Read Data Not Available (Not RDA)

     Registers Affected:  PSW

     SYSLIB Routines Called:  -None-

     Special Error Conditions:  -None-



     Routine Names:  CIN, RIN
     Functionº  Inpuô characteò froí CONº  (CIN© oò RDRº (RIN© iî 
Registeò A.

     Inputs:  -None-

     Outputs:  A = Character input from CON: or RDR:

     Registers Affected:  PSW

     SYSLIB Routines Called:  -None-

     Special Error Conditions:  -None-



11.04 General Output Routines

     Routine Names:  COUT, LOUT, POUT
     Functionº
          Outpuô  characteò iî Registeò Á tï  CONº  (COUT)¬  LSTº 
(LOUT)¬ oò PUNº (POUT).

     Inputs:  A = Character to output

     Outputs:  -None- (Character is output)

     Registers Affected:  -None-

     SYSLIB Routine Called:  -None-

     Special Error Conditions:  -None-
Š
     Routine Names:  CCOUT, CLOUT, CPOUT
     Functionº
          Outpuô  characteò iî Registeò Á tï  CONº  (COUT)¬  LSTº 
(LOUT)¬  oò PUNº  (POUT© witè controì characteò processing®   Alì 
characteró witè ASCIÉ codeó lesó thaî <SP¾ (spacå ½ 20H© iî valuå 
excepô  <NULL>¬  <BEL>¬  <BS>¬  <LF>¬  anä <CR¾ arå outpuô aó  aî 
uparro÷  (^©  followeä bù thå correspondinç letteò  generateä  bù 
addinç 40È tï thå characteò valuå (i.e.¬  ± outputó aó "^A"¬ ² aó 
"^B"¬  etc.)®   Again¬ thå characteró lesó thaî <SP¾ iî valuå NOÔ 
outpuô iî thió manneò arå --

          <NULL>  <BEL>  <BS>  <LF>  <CR>

Anù characteò oæ valuå greateò thaî <SP¾ ió outpuô normally.

     Inputs:  A = Character to output

     Outputs:  -None- (Character/Code is output)

     Registers Affected:  PSW (only the Flags;
                              Register A is NOT affected)

     SYSLIÂ Routineó Calledº  COUÔ (foò CCOUT)»
                              LOUÔ (foò CLOUT)» POUÔ (foò CPOUT)

     Special Error Conditions:  -None-

.fo 12 - Math Routines                                     Page #

12.0 Math Routines

12.01 Introduction

     Thió  modulå  containó á seô oæ 16-biô  unsigneä  arithmetiã 
routines®   Alì routineó uså HÌ aó thå accumulatoò oò thå result¬ 
anä  HÌ anä DÅ contaiî thå operandó requireä (iæ onlù onå operanä 
is needed, HL contains it).

     The available routines are:

          ADDHD -- HL = HL + DE    SUBHD -- HL = HL - DE
          MULHD -- HL = HL * DE    DIVHD -- HL = HL / DE
          NEGH  -- HL = 2's Complement of HL
          CMPH  -- HL = 1's Complement of HL
          ROTLH -- HL is rotated left one bit position
          ROTRH -- HL is rotated right one bit position
          SHFTLH -- HL is shifted left one bit position
          SHFTRH -- HL is shifted right one bit position
          ANDHD  -- HL = HL AND DE
          ORHD   -- HL = HL OR DE
          XORHD  -- HL = HL XOR DE



12.02 Arithmetic Operations -- ADDHD, SUBHD, MULHD, DIVHD

     Alì  oæ  theså routineó operatå oî HÌ anä  DE¬  placinç  thå 
resulô  iî HL®   Thå Carrù Flaç ió affected¬  frequentlù useä  tï 
indicate overflow.


     Routine Name:  ADDHD
     Functionº
          HL = HL + DE
     Inputs:  HL, DE are operands
     Outputs:  HL is result, Carry Flag Set (C) means overflow
     Registers Affected:  HL, PSW
     SYSLIB Routines Called:  None
     Speciaì  Erroò Conditionsº  None




     Routine Name:  SUBHD
     Functionº
          HL = HL - DE
     Inputs:  HL, DE are operands
     Outputs:  HL is result, Carry Flag Set (C) if HL<DE
     Registers Affected:  HL, PSW
     SYSLIB Routines Called:  None
     Speciaì  Erroò Conditionsº  None


     Routine Name:  MULHD
     Functionº
          HL = HL * DE
     Inputs:  HL, DE are operands
     Outputs:  HL is result, Carry Set means Overflow
     Registers Affected:  HL, PSW
     SYSLIB Routines Called:  SHFTRH, SHFTLH
     Speciaì  Erroò Conditionsº  None
     Noteº   Thió  routinå ió optimizeä foò speed¬  witè á  minoò 
sacrificå  oî size¬  anä iô alwayó takeó 1¶ loopó tï perforí  anù 
multiplication.




     Routine Name:  DIVHD
     Functionº
          HL = HL / DE
     Inputs:  HL, DE are operands
     Outputs:  HL is result
     Registers Affected:  HL
     SYSLIB Routines Called:  SHFTLH
     Speciaì  Erroò Conditionsº  None
     Noteº   Thió  routinå ió optimizeä foò speed¬  witè á  minoò 
sacrificå  oî size¬  anä iô alwayó takeó 1¶ loopó tï perforí  anù 
division.



12.03 Complement Operations -- NEGH and CMPH

     These routines operate on HL, placing the result into HL.


     Routine Name:  NEGH
     Functionº
          HL = 2's Complement of HL
     Inputs:  HL is operand
     Outputs:  HL is result
     Registers Affected:  HL
     SYSLIB Routines Called:  CMPH
     Speciaì  Erroò Conditionsº  None




     Routine Name:  CMPH
     Functionº
          HL = 1's Complement of HL
     Inputs:  HL is operand
     Outputs:  HL is result
     Registers Affected:  HL
     SYSLIB Routines Called:  None
     Speciaì  Erroò Conditionsº  NoneŠ
12.04 Rotate and Shift Operations -- ROTLH, ROTRH, SHFTLH, SHFTRH


     These operations operate on HL, placing the result into HL.


     Routine Name:  ROTLH
     Functionº
          HÌ  ió  rotateä  lefô onå  biô  position®   Thió  ió  á 
circulaò  rotate¬  anä  thå mosô significanô biô oæ È ió  rotateä 
into the least significant bit position of L.
     Inputs:  HL is operand
     Outputs:  HL is result
     Registers Affected:  HL
     SYSLIB Routines Called:  None
     Speciaì  Erroò Conditionsº  None




     Routine Name:  ROTRH
     Functionº
          HÌ  ió  rotateä  righô onå biô  position®   Thió  ió  á 
circulaò  rotate¬  anä thå leasô significanô biô oæ Ì ió  rotateä 
into the most significant bit position of H.
     Inputs:  HL is operand
     Outputs:  HL is result
     Registers Affected:  HL
     SYSLIB Routines Called:  None
     Speciaì  Erroò Conditionsº  None




     Routine Name:  SHFTLH
     Functionº
          HÌ  ió  shifteä  lefô  onå  biô  position®   Thå  leasô 
significant bit of L is filled with a Zero.
     Inputs:  HL is operand
     Outputs:  HL is result
     Registers Affected:  HL
     SYSLIB Routines Called:  None  
     Speciaì  Erroò Conditionsº  None



     Routine Name:  SHFTRH
     Functionº
          HÌ  ió  shifteä  righô  onå  biô  position®   Thå  mosô 
significant bit of H is filled with a Zero.
     Inputs:  HL is operand
     Outputs:  HL is result
     Registers Affected:  HL
     SYSLIB Routines Called:  None  
     Speciaì  Erroò Conditionsº  None




12.05 Logical Operations -- ANDHD, ORHD, XORHD

     These operate on HL and DE, placing the result into HL.


     Routine Name:  ANDHD
     Functionº
          HL = HL AND DE
     Inputs:  HL and DE are operands
     Outputs:  HL is result
     Registers Affected:  HL
     SYSLIB Routines Called:  None  
     Speciaì  Erroò Conditionsº  None




     Routine Name:  ORHD
     Functionº
          HL = HL OR DE
     Inputs:  HL and DE are operands
     Outputs:  HL is result
     Registers Affected:  HL
     SYSLIB Routines Called:  None  
     Speciaì  Erroò Conditionsº  None




     Routine Name:  XORHD
     Functionº
          HL = HL XOR DE
     Inputs:  HL and DE are operands
     Outputs:  HL is result
     Registers Affected:  HL
     SYSLIB Routines Called:  None
     Speciaì  Erroò Conditionsº  None

.fo 13 - CRC Routines                                      Page #

13.0 CRC Routines

     Thå  CRÃ  Routineó maù bå useä tï checë thå validitù  oæ  aî 
incominç seriaì bytå streaí oæ arbitrarù length®   Theså routineó 
computå anä checë á truå 16-biô Cycliã Redundancù Codå (CRC).
     The use of these routines will guarantee detection of:
          1) all single- and double-bit errors
          2) all errors with an odd number of error bits
          3) all burst errors of length 16 or less
     Additionally, the following statistics:
          1) 99.9969% of all 17-bit error bursts
          2) 99.9984% of all possible longer error bursts

     Thå followinç displaù illustrateó á typicaì waù tï uså theså 
routines:

     ;
     ;  EXTERNAL DECLARATIONS OF SYSLIB ROUTINES
     ;
          ...
          EXT  CRCCLR    ; CLEAR CRC ACCUMULATOR
          EXT  CRCUPD    ; UPDATE CRC ACCUMULATOR
          EXT  CRCDONE   ; RETURN CRC ACCUMULATOR VALUE
          EXT  COMPHD    ; COMPARE HL TO DE, RETURN ZERO IF EQUAL
          ...
     CRC$MAKE:                ; ROUTINE TO ESTABLISH OUTGOING CRC
          CALL CRCCLR    ; CLEAR CRC
          <loop CALLing CRCUPD>    ; ACQUIRE VALUES
          CALL CRCDONE   ; GET VALUE
          PUSH H         ; SAVE VALUE
     CRC$CHECK:          ; ROUTINE TO CHECK INCOMING CRC VALUE
          CALL CRCCLR    ; CLEAR CRC
          <loop CALLing CRCUPD>    ; ACQUIRE VALUES
          CALL CRCDONE   ; GET 2ND CRC
          POP  D         ; GET 1ST CRC IN DE, 2ND IN HL
          CALL COMPHD    ; COMPARE HL TO DE (SYSLIB ROUTINE)
          JNZ  ERROR     ; ERROR IF NO MATCH
          ...

     Thå  followinç  screeî displayó describå thå  CRÃ  routines®  
Therå arå threå differenô setó oæ CRÃ computatioî routines¬  eacè 
seô  workinç witè á differenô polynomial®   Thå routinå  seô  foò 
CRC²  useó thå samå polynomiaì aó thå publiã domaiî CRCË  prograí 
bù Keitè Petersen.

          CRC Routine    Polynomial
          -----------    ----------
             CRC         X^16 + X^12 + X^5 + 1
             CRC1        X^16 + X^15 + X^2 + 1
             CRC2        X^16 + X^15 + X^13 + X^7 + X^4 +
                              X^2 + X + 1



     Routine Name:  CRCCLR, CRC1CLR, CRC2CLR
     Functionº
          Cleaò  thå  internaì CRÃ Accumulatoò iî preparatioî  tï 
CRÃ computation.

     Inputs:  None

     Outputs:  None

     Registers Affected:  None

     SYSLIB Routines Called:  None

     Special Error Conditions:  None



     Routine Name:  CRCUPD, CRC1UPD, CRC2UPD
     Function:
          Updatå thå CRÃ Accumulatoò valuå witè thå nexô byte.

     Input:  A=byte to be included in CRC

     Outputs:  None

     Registers Affected:  None

     SYSLIB Routines Called:  None

     Special Error Conditions:  None



     Routine Name:  CRCDONE, CRC1DONE, CRC2DONE
     Functionº
          Terminatå   CRÃ  valuå  accumulatioî  anä  returî   thå 
calculateä 16-biô CRÃ value.

     Inputs:  None

     Output:  HL = calculated CRC value

     Registers Affected:  HL

     SYSLIB Routines Called:  None

     Special Error Conditions:  None











          **** This Page Intentionally Left Blank ****





.fo 14 - Random Number Generator Routines                  Page #

14.0 Random Number Generator Routines

     Thå followinç seô oæ routineó arå useä tï (1© providå á seeä 
valuå  foò  thå  randoí numbeò generatoò anä (2©  calì  á  randoí 
number generator to return a random number.

     RNDINIÔ  counts¬  waitinç foò thå user'ó keypress¬  aô whicè 
poinô iô stopó countinç anä useó thå counô aó thå seeä valuå  foò 
the random number generator.

     RNDSEEÄ  allowó  thå  useò tï specifù á seeä valuå  foò  thå 
random number generator.

     RND returns a random number.


     Routine Name:  RNDINIT
     Functionº
          RNDINIÔ enteró á countinç loop¬ waitinç foò thå useò tï 
strikå á keù aô hió console®  Iô theî setó thå seeä valuå foò thå 
randoí numbeò generatoò baseä upoî itó counô valuå aô thå instanô 
of keypress.  The seed value is an 8-bit quantity.

     Inputs:  None (User Keypress)

     Outputs:  None  (Seed is set)

     Registers Affected:  None

     SYSLIB Routines Called:  CONDIN, RND

     Speciaì  Erroò Conditionsº  None




     Routine Name:  RNDSEED
     Functionº
          Thió  routinå  allowó thå useò tï providå á seeä  valuå 
foò  thå randoí numbeò generator®   Thå seeä ió passeä iî  thå  Á 
register.

     Inputs:  A = Seed

     Outputs:  None  (Seed is set)

     Registers Affected:  None

     SYSLIB Routines Called:  RND

     Speciaì  Erroò Conditionsº  None


Š
     Routine Name:  RND
     Functionº
          Thió ió thå user-callablå randoí numbeò generator®   Iô 
returnó  á  pseudo-randoí numbeò (8-bit© iî thå Á  registeò  wheî 
called.

     Inputs:  None

     Outputs:  A = Random Number

     Registers Affected:  PSW

     SYSLIB Routines Called:  None

     Speciaì  Erroò Conditionsº  None


.fo 15 - User/Disk Manipulation Routines                   Page #

15.0 User/Disk Manipulation Routines

     Thió  ió  á  seô oæ fouò routineó whicè allo÷  thå  useò  tï 
readilù movå arounä betweeî diskó anä useò areas®  Theså routineó 
are:
          PUTUD -- to save away the current disk/user
          GETUD -- to restore the disk/user saved by PUTUD
          RETUD -- to return the current disk/user
          LOGUD -- to log the user into a specified disk/user

     PUTUÄ  anä GETUÄ arå designeä tï bå useä aó á  placå  markeò 
anä  returî  combination®   Theù arå intendeä tï bå useä iî  codå 
sequences like the following:

          CALL PUTUD     ; Mark current location
          < move around on disks/users >
          CALL GETUD     ; Return to marked location

     RETUÄ anä LOGUÄ arå tï bå useä tï finä ouô wherå thå prograí 
is (RETUD) and to enter a specific disk/user area (LOGUD).



     Routine Name:  PUTUD
     Functionº
          PUTUÄ  saveó thå currenô useò anä disë numberó awaù foò 
lateò  retrievaì bù GETUD®   PUTUÄ anä GETUÄ arå intendeä  tï  bå 
useä  tï  savå anä restorå thå currenô disë anä useò arounä  somå 
set of operations in another user/disk area.

     Inputs:  None

     Outputs:  None

     Registers Affected:  None

     SYSLIB Routines Called:  RETUD

     Speciaì  Erroò Conditionsº  None




     Routine Name:  GETUD
     Functionº
          GETUÄ  restoreó  thå currenô useò anä  disë  whicè  waó 
saved by PUTUD.

     Inputs:  None

     Outputs:  None

     Registers Affected:  None

     SYSLIB Routines Called:  BDOS

     Speciaì  Erroò Conditionsº  None



     Routine Name:  LOGUD
     Functionº
          LOGUÄ logó iî thå disë specifieä bù thå Â registeò (B=° 
foò Disë A) and the user specified by the C register.

     Inputs:  B=Disk (B=0 for Disk A), C=User

     Outputs:  None

     Registers Affected:  None

     SYSLIB Routines Called:  BDOS

     Speciaì  Erroò Conditionsº  None




     Routine Name:  RETUD
     Functionº
          RETUÄ  returnó thå numberó oæ thå currenô useò iî Ã anä 
current disk in B (B=0 for disk A).

     Inputs:  None

     Outputs:  B=Disk (B=0 for disk A), C=User

     Registers Affected:  BC

     SYSLIB Routines Called:  BDOS

     Speciaì  Erroò Conditionsº  None


.fo 16 - Sort Routines                                     Page #

16.0 Sort Routineó 

     Twï  routineó arå provideä whicè givå thå SYSLIÂ  programmeò 
accesó  tï á verù flexiblå sortinç system®   Thå maiî routinå  ió 
calleä  SORT¬  anä iô provideó á utilitù whicè doeó aî  in-memorù 
sorô  oæ  á seô oæ fixed-lengtè records®   Thå sortinç  techniquå 
useä ió á Shelì Sort¬  adapteä froí thå booë "Softwarå Tools¢  bù 
Kernigaî  anä Plaugher¬  publisheä bù Addison-Wesly¬  1976¬  pagå 
106®  Thió sorô ió verù fast¬ mucè morå sï thaî thå simplå bubblå 
sort.

     Thió  Shelì Sorô caî bå donå iî twï waysº   witè oò  withouô 
usinç  pointers®   Sortinç  withouô usinç pointeró  ió  typicallù 
sloweò thaî sortinç witè pointers¬  anä thå onlù advantagå tï noô 
usinç  pointeró ió thå savingó oæ spacå whicè ió takeî uğ bù  thå 
pointeró (2*numbeò oæ entrieó bytes)®   Iæ pointeró arå useä  foò 
thå  sort¬  theî wheneveò aî exchangå ió done¬  thå pointeró  arå 
simplù exchanged¬  ratheò thaî thå fulì records¬ anä thió greatlù 
decreases the sort time in most cases.

     Thå SORÔ routinå ió controlleä bù passinç tï iô á pointeò tï 
á Sorô Specificatioî Blocë (SSB© iî DE®   Thió Sorô Specificatioî 
Blocë  ió  á serieó oæ 2-bytå wordó whicè contaiî  thå  followinç 
information:

          Bytes 0&1: Starting Address of 1st Record
          Bytes 2&3: Number of Records to Sort
          Bytes 4&5: Size of Each Record (in Bytes)
          Bytes 6&7: Address of Compare Routine Provided by User
                         Thió  routinå compareó twï records¬  onå 
                     pointeä tï bù HÌ anä thå otheò pointeä tï bù 
                     DE®   Iæ thå recorä pointeä tï bù DÅ ió lesó 
                     iî sortinç ordeò thaî thaô pointeä tï bù HL¬ 
                     thió Comparå Routinå ió tï returî witè Carrù 
                     Seô  (C)®   Iæ  thå  recordó  arå  equaì  iî 
                     sortinç  order¬  thió Comparå Routinå ió  tï 
                     returî witè Zerï Seô (Z)®   Onlù thå PS×  ió 
                     to be affected by the Compare Routine.
          Bytes 8&9: Address of Pointer Table
          Bytå 10º  Flag» °FFH meanó tï uså pointers¬ 0 meanó not
          Byte 11:  Unused

     Aó mentioneä previously¬  twï routineó arå availablå iî thió 
sorô module®   Thå firsô routine¬ SSBINIT¬ lookó aô thå beginninç 
oæ  á  scratcè  areá  anä  thå initiaì contentó  oæ  aî  SSÂ  anä 
allocateó spacå foò thå pointeò table®   Iô alsï checkó tï seå iæ 
thå  buffeò  requireä wilì overflo÷ thå  TPÁ  (Transienô  Prograí 
Area).

     Thå seconä routine¬  SORT¬ performó thå sort¬ anä controlleä 
by the SSB pointer passed to it in DE.


     Routine Name:  SSBINIT
     Functionº
          Thió  routinå loadó byteó 0&± (addresó oæ firsô record© 
anä  8&¹ (addresó oæ pointeò table© oæ aî SSB¬  checkinç foò  TPÁ 
overflow®   Iô ió passeä thå starô addresó oæ á scratcè area¬ anä 
setó  thå pointeò tablå tï starô here¬  lookó aô thå recorä  sizå 
anä recorä counô entrieó oæ aî SSB¬  anä addó thió producô tï thå 
addresó oæ thå pointeò table®   Thå resultanô addresó ió returneä 
as the address of the first record.
     Thió  routinå  maù  bå useä aó describeä  abovå  beforå  anù 
recordó  arå loadeä intï memorù foò thå sort¬  oò iô maù bå  useä 
afteò thå recordó havå alreadù beeî loaded®   Iî thå latteò case¬ 
thå  useò shoulä savå thå starô addresó oæ thå firsô  recorä  anä 
calì  SSBINIÔ  witè thå addresó oæ thå firsô bytå afteò thå  lasô 
record®   Oncå  SSBINIÔ  haó loadeä thå bufferó iî  thå  SSÂ  anä 
checkeä  foò  á  TPÁ  overflo÷ (notå thaô thió ió  donå  foò  thå 
pointeró only)¬  iô wilì returî tï thå caller¬  aô whicè timå thå 
calleò  shoulä  restorå thå firsô twï byteó oæ thå SSÂ  tï  theiò 
proper values, the actual start address of the first record.

     Inputs:  HL pts to start of scratch area, DE pts to SSB

     Outputs:  Z Flag is Set (Z) if TPA overflow; NZ if OK

     Registers Affected:  PSW

     SYSLIB Routines Called:  MOVEB

     Speciaì  Erroò Conditionsº  None




     Routine Name:  SORT
     Functionº
          SORÔ sortó thå seô oæ fixeä lengtè recordó accordinç tï 
thå  controì  informatioî iî thå Sorô Specificatioî  Blocë  (SSB© 
pointed to by DE.

     Inputs:  DE pts to SSB

     Outputs:  None (Records are Sorted)

     Registers Affected:  None

     SYSLIB Routines Called:  MOVEB, PRINT

     Speciaì  Erroò Conditionsº
          Thå Erroò Messagå "SORÔ Pointeò Error¢ maù bå  printed¬ 
buô ió highlù unlikely®  Thió indicateó á fla÷ haó developeä witè 
thå SORÔ routinå foò thió particulaò case¬  anä iô coulä noô SORÔ 
thå  seô  oæ recordó aó desired®   Thió erroò ió fataì  anä  wilì 
abort to CP/M.
.fo 17 - ZCPR2 Feature-Specific Routines                   Page #

17.0 ZCPR2 Feature-Specific Routines

     Thió modulå containó á serieó oæ routineó whicè arå designeä 
tï  allo÷ thå programmeò tï takå advantagå oæ keù ZCPR²  Featureó 
withouô doinç á loô oæ programminç foò himself®   Iî  particular¬ 
facilitieó sucè aó thå followinç arå provided:

  ZINIMC  -  Initializatioî -- Settinç thå locatioî oæ the
                    multiple command line buffer
  ZINIEXT -  Initialization -- Defining the location of a command
                    search path
  ZINICI  -  Initialization -- Setting the current disk/user
                    character definition
  ZINIDMA -  Initialization -- Set the DMA address for ZCPR2 disk
                    Input/Output
  ZGPINS  -  Initialization -- Setting all ZCPR2 buffers as
                    required from buffers set up as per the
                    ZCPR2 Utility Standard General Purpose
                    Installation Format
  ZCPRÑ   -  Utilitù -- Returninç á pointeò tï thå internaì 
                    buffers of the first ZCPR2 SYSLIB Module
  ZMCPTR  -  Utility -- Returning a pointer to the first byte
                    of the next command
  ZPFIND  -  Utility -- Searching for a file along the command
                    search path
  ZFSTAT  -  Utility -- Determining the attributes of a file

     Á  notå  oî  statuó routinesº   therå arå threå  moduleó  iî 
SYSLIÂ  whicè  containó  ZCPR2-specifiã  routines®    Onå  modulå 
containó jusô ZGPINÓ anä containó nï statuó returî  routine¬  buô 
thå otheò twï moduleó contaiî ZCPRÑ anä ZCPRQ2¬  resp¬  tï returî 
pointeró  tï  importanô  internaì bufferó aó  describeä  iî  thió 
manual®   Thió chapteò describeó thå firsô ZCPR² module¬  anä itó 
status routine is ZCPRQ.


     Routine Name:  ZINIMC
     Functionº
          ZINIMÃ defineó thå baså addresó oæ thå multiplå commanä 
linå  buffeò foò thå ZCPR² system®   Thå initializatioî performeä 
bù  thió  routinå  ió useä bù thå ZMCPTÒ routinå  tï  returî  thå 
pointer to the first character of the next command.

     Inputs:  HL = base address of multiple command line buffer
     Outputs:  None
     Registers Affected:  None
     SYSLIB Routines Called:  None
     Speciaì  Erroò Conditionsº  None

     Noteº   Iæ  thió routinå ió noô called¬  iô ió assumeä  thaô 
multiple command lines are not supported.



     Routine Name:  ZINIEXT
     Functionº
          ZINIEXÔ  defineó thå baså addresó oæ á  commanä  searcè 
path®   Thå  ZPFINÄ  routinå useó thió baså addresó tï starô  itó 
searcè foò á file®   Notå thaô thió provideó addeä flexibilitù iî 
thaô  thió neeä noô necessarilù bå thå baså addresó oæ thå  ZCPR² 
Systeí commanä searcè path¬ buô iô maù bå thå baså addresó oæ anù 
path (such as a separate path to look for HLP files).

     Inputs:  HL = base address of path

     Outputs:  None

     Registers Affected:  None

     SYSLIB Routines Called:  None

     Speciaì  Erroò Conditionsº  None

     Noteº   Iæ  thió  routinå ió noô called¬  thå externaì  patè 
defaultó tï aî emptù path¬  sï nï harí ió donå anä nï searcè  caî 
bå performed.


     Routine Name:  ZINICI
     Functionº
          ZINICÉ  defineó  thå  characteò useä  tï  indicatå  thå 
currenô  useò  oò disë iî thå ZCPR² commanä  searcè  path®   Thió 
characteò  ió passeä iî A®   Iæ thió routinå ió noô  called¬  thå 
ZCPR2 default of '$' is assumed.
     Inputs:  A = Current Indicator
     Outputs:  None
     Registers Affected:  None
     SYSLIB Routines Called:  None
     Speciaì  Erroò Conditionsº  None
     Noteº   Iæ  thió  routinå ió noô called¬  Currenô  Indicatoò 
defaults to '$'.


     Routine Name:  ZINIDMA
     Functionº
          ZINIDMÁ defineó thå DMÁ addresó useä foò alì disë Inpuô 
anä  Output®   Thió addresó ió passeä iî HL®   Iæ thió routinå ió 
noô called¬ thå ZCPR² defaulô oæ 80È ió assumed.
     Inputs:  HL = DMA Address
     Outputs:  None
     Registers Affected:  None
     SYSLIB Routines Called:  None
     Speciaì  Erroò Conditionsº  None
     Noteº   Iæ thió routinå ió noô called¬  DMÁ Addresó defaultó 
tï 80H.


     Routine Name:  ZGPINS
     Functionº
          ZGPINÓ  initializeó thå ZCPR2-Specifiã Bufferó froí thå 
ZCPR²  Utilitù Standarä General-Purposå Installatioî Formaô  Buf
fers®   Thió ió tï bå useä bù ZCPR² Utilities¬  sucè aó XDIR3¬ tï 
completelù initializå alì thå necessarù buffers.
     Thå bufferó iî thå utilitieó arå locateä aó indicateä iî thå 
ZCPR² Utilitieó Manual.

     Inputs:  None

     Outputs:  None

     Registers Affected:  None

     SYSLIB Routines Called:  MOVEB, ZINIMC, ZINIEXT, ZCPRSET,
                              ZFNINIT

     Speciaì  Erroò Conditionsº  None





     Routine Name:  ZCPRQ
     Functionº
          ZCPRÑ  querieó  thå statuó oæ thå SZCPÒ  module¬  whicè 
containó theså routines®  Oî exit¬ thió routinå returnó á pointeò 
tï  thå  internaì bufferó oæ thå firsô ZCPR²  modulå  iî  SYSLIB®  
These buffers are structured as follows:
		Byte 0:  Multiple command available flag (0=no)
		Bytes 1-2:  Address of multiple command line
				buffer, if available
		Bytes 3-4:  Address of external path (empty
				path if path not set)
		Byte 5:  Current User/Disk Indicator
		Bytes 6-7:  DMA Address

     Inputs:  None
     Outputs:  HL = Base Address of Buffers
     Registers Affected:  HL
     SYSLIB Routines Called:  None
     Speciaì  Erroò Conditionsº  None


     Routine Name:  ZMCPTR
     Functionº
          ZMCPTÒ  returnó á pointeò tï thå nexô characteò iî  thå 
multiplå commanä linå iæ multiplå commandó arå enabled®   Á  flaç 
is returned which says if multiple commands are enabled or not.

     Inputs:  None

     Outputs:  HL pts to next char in line
               A=0 and Zero Flag Set (Z) if multiple commands
                    are not available; NZ otherwise

     Registers Affected:  HL, PSW

     SYSLIB Routines Called:  None

     Speciaì  Erroò Conditionsº  None




     Routine Name:  ZPFIND
     Functionº
          ZPFINÄ  searcheó  foò á filå alonç thå  commanä  searcè 
patè  whoså  baså addresó waó defineä wheî thå programmeò  calleä 
ZINIEXT®   Iô  logó intï eacè disë anä useò areá alonç thå  path¬ 
lookinç foò thå filå whoså FCÂ ió pteä tï bù DE¬  untiì iô eitheò 
findó  thå filå oò reacheó thå enä oæ thå patè (filå noô  found)®  
Iæ thå filå ió found¬  iô returnó thå disë anä useò areá iî whicè 
thå filå resides®   ZPFINÄ alwayó returnó thå procesó tï thå disë 
and user area it is "currently" logged into.

     Inputs:  DE pts to the FCB of the file to find
              B is a flag; if B <> 0, search the current disk and
                    user area first; if B=0, do not search the
                    current disk and user area first

     Outputs:  Zero Flag Clear (NZ) and A=0FFH if file found
               B = Disk (B=0 if Disk A), C=User if file found
               Zero Flag Set (Z) and A=0 if file not found

     Registers Affected:  BC, PSW

     SYSLIB Routines Called:  BDOS

     Speciaì  Erroò Conditionsº  None


     Routine Name:  ZFSTAT
     Functionº
          ZFSTAÔ  determineó  thå attributeó oæ thå filå  iî  thå 
currenô disë anä useò areá whoså FCÂ ió pteä tï bù DE®   Iô telló 
the programmer if the file is SYSTEM or not and READ/ONLY or not.

     Inputs:  DE pts to FCB of file

     Outputs:  B=0 means file is NOT System, B<>0 means file is
               C=0 means file is NOT R/O, C<>0 means file is
               Zerï Flaç Seô (Z© anä A=° iæ filå founä anä BC
                    valid, and Zero Flag Clear (NZ) if file not
                    found

     Registers Affected:  BC, PSW

     SYSLIB Routines Called:  BDOS

     Speciaì  Erroò Conditionsº  None

     Note:  ZFSTAT does NOT do a search.


.fo 18 - ZCPR2-Specific Named Directory Routines           Page #

18.0 ZCPR2-Specific Named Directory Routines

     Thió seô oæ routineó ió specifiã tï thå ZCPR2-Specifiã Nameä 
Directorù Structure®   Theså routineó providå thå programmeò witè 
á  seô  oæ routineó whicè resolvå thå nameä directorù  referenceó 
foò him¬ translatinç á nameä directorù intï thå disk/useò areá iô 
refers to.

     Five routines are included in this set:
          o ZCPRQ2 -- Return Status
          o ZFNINIT -- Initialize Named Directory Buffers
          o ZDNFIND -- Scan for Disk Directory Name
          o ZDNAME -- Load All Disk Directory Name Data
          o ZFNAME -- Named Directory File Name Scanner


     Routine Name:  ZCPRQ2
     Function:
          ZCPRQ²  ió  thå companioî tï ZCPRQ¬  anä iô  returnó  á 
pointeò  tï thå internaì bufferó oæ thå seconä ZCPR² modulå whicè 
contains such buffers.  The organization of these buffers is:

               Byte 0:  Max Number of Named Directory Entries
               Bytes 1-2:  Address of memory-resident named
                              directory buffer (or 0 if none)
               Bytes 3-38:  FCB of NAMES.DIR

     Inputs:  None
     Outputs:  HL points to first byte of buffer
     Registers Affected:  HL
     SYSLIB Routines Called:  None
     Special Error Conditions:  None


     Routine Name:  ZFNINIT
     Functionº
          ZFNINIÔ  allowó thå useò tï specifù thå addresó oæ  thå 
memory-residenô  nameä directorù buffer¬  initializå thå namå  oæ 
thå  nameä  directorù filå (defaulô namå oæ  NAMES.DIR©  tï  somå 
otheò  name¬  anä  tï changå thå numbeò oæ nameó permitteä  iî  á 
directorù filå (defaulô oæ 64).

     Inputs:  DE pts to FCB containing the new file name
              HL contains address of memory-resident buffer
              C is the new maximum number of directory names
              A is a flag indicating values to set as follows:
                    Bit 7 -- Set to 1 to load default FCB fm DE
                    Bit 6 -- Set to 1 to load name count fm C
                    Bit 5 -- Set to 1 to load address fm HL
     Outputs:  None
     Registers Affected:  None
     SYSLIB Routines Called:  MOVEB
     Speciaì  Erroò Conditionsº  None

     Routine Name:  ZDNAME
     Function:
          ZDNAMÅ  loadó thå contentó oæ thå NAMES.DIÒ  filå  intï 
thå memorù buffeò pointeä tï bù HL®  Eacè entrù iî thió buffeò ió 
structured as follows:
               Byte 0:  Disk Number (A=0)
               Byte 1:  User Number
               Bytes 2-9:  Directory Name, 8 Chars Max, Space
                    Fill at End

     Inputs:  HL pts to the memory buffer extending to the base
               of the BDOS

     Outputs:  HL pts to the first entry in the buffer
               C is the number of valid entries, B=0
               A is the error flag (A=0 and Z if error)

     Registers Affected:  HL, BC, PSW

     SYSLIB Routines Called:  INITFCB, ZPFIND, FI3$OPEN, F3$GET

     Special Error Conditions:  None





     Routine Name:  ZDNFIND
     Functionº
          ZDNFINÄ examineó thå DIRº  prefiø foò eitheò á DUº forí 
oò á directorù name®  Iæ iô ió determineä thaô thå DIRº prefiø ió 
noô oæ thå DUº form¬ theî thå memory-residenô directorù buffeò ió 
scanned¬  iæ present¬  and¬  failinç that¬  thå NAMES.DIÒ filå ió 
soughô  alonç thå ZCPR² path¬  loaded¬  anä scanneä foò á corres
pondinç name®   Iæ found¬  thå correspondinç useò anä disë valueó 
arå returned» iæ noô found¬ aî erroò codå ió returned.

     Inputs:  HL pts to first byte of DIR: prefix
              A=° iæ DUº forí NOÔ allowed

     Outputs:  B=Disk (B=1 if Disk A, B=0FFH if Current Disk),
               C=User (C=0FFH if Current User), HL pts to colon,
               Zerï Flaç Cleaò (NZ© iæ nï error» Zerï Flaç Seô 
               (Z) if error, and no valid values returned

     Registers Affected:  BC, HL, PSW
     SYSLIB Routines Called:  INITFCB, ZPFIND, FI3$OPEN,
                              FI3$CLOSE, F3$GET

     Speciaì Erroò Conditionsº  Notå thaô ZDNFINÄ useó Inpuô Filå 
3¬  sï  Inpuô  Filå ³ shoulä noô bå openeä wheî thió  routinå  ió 
called®   Also¬  ZPFINÄ ió used¬ sï thå programmeò musô bå surå á 
proper external path is specified if needed by calling ZINIEXT.

     Routine Name:  ZFNAME
     Functionº
          ZFNAMÅ  ió á filå namå scanner®   Pointinç tï thå firsô 
characteò   oæ   á   filå  namå   specificatioî   oæ   thå   forí 
'DIR:FILENAME.TYP'¬  wherå  anù  parô  oæ thió  specificatioî  ió 
optional¬  thió  routinå filló iî aî FCÂ  witè  zeroes¬  properlù 
initializeó  thå  FÎ anä FÔ (Filå Namå anä Filå Type©  fieldó  iæ 
'FILENAME.TYP§  oò anù parô thereoæ ió present¬  anä returnó  thå 
valuå oæ disë anä useò iæ theù arå specifieä (oò 0FFÈ iæ not).
     Thå directorù indicatoò 'DIR:'¬  iæ specified¬ maù bå oæ onå 
of four forms:
          DIRECT: -- A named directory, of up to 8 chars long
          d:      -- A disk drive letter
          u:      -- A user number
          du:     -- A disk drive letter and a user number
     Thå duº  forí ió checkeä first¬ sï unnecessarù disë activitù 
in looking for the NAMES.DIR file is avoided.
     Examples of valid input strings:
          HELP:*.HLP     A5:TEST.TXT    C?:ABC.*  PASCAL:*.COM

     Inputs:  DE pts to FCB to fill, HL pts to first byte of
               targeô string; FCB is 36 bytes long

     Outputs:  B=Disk (B=1 for Disk A), C=User
               B=0FFH if no disk specified (current disk)
               C=0FFH if no user specified (current user)
               C=? if all user areas specified
               HL pts to terminating character
               A=0 and Zero Flag Set (Z) if error in disk
                    or user numbers; A=0FFH and NZ if no error

     Registers Affected:  BC, HL, PSW

     SYSLIB Routines Called:  ZDNFIND

     Speciaì   Erroò   Conditionsº    Seå   FNAMÅ   routinå   foò 
similarities


.fo 19 - Miscellaneous Routines                            Page #

19.0 Miscellaneouó Routineó 

     Thió sectioî describeó thå followinç Miscellaneouó Routines:


          BDOS      For Direct BDOS Interface
          BIOS      For Direct BIOS Interface
          CAPS      For Character Capitalization
          CAPSTR    For String Capitalization
          CATH      Convert ASCII Character to Hexadecimal
          CLINE     Save Command Line Buffer
          CODEND    Provide End of Code/Data Area
          EN        Exchange Nybbles in A
          FILLB     Fill Memory (up to 255 bytes)
           FILLBC   Fill Memory (up to 65,535 bytes)
           HFILB    Fill Memory (up to 255 bytes)
           HFILBC   Fill Memory (up to 65,535 bytes)
          MOVEB     Move Memory (up to 255 bytes)
           MOVEBC   Move Memory (up to 65,535 bytes)
           HMOVB    Move Memory (up to 255 bytes)
           HMOVBC   Move Memory (up to 65,535 bytes)
          PAUSE     Delay N 10ths of a Second
          VERSION   Return Version Number of SYSLIB


     Routine Name:  BDOS
     Functionº
          Calì  CP/Í  Entrù  Poinô  aô locatioî  µ  anä  preservå 
Registeró DE anä BC.

     Inputs:  C and DE provide input parameters

     Outputs:  A and HL provide output parameters

     Registers Affected:  PSW, HL

     SYSLIB Routines Called:  -None-

     Special Error Conditions:  -Determined by Routines Called-



     Routine Name:  BIOS
     Functionº
          BIOÓ provideó thå useò witè á direcô interfacå intï thå 
CP/Í  BIOS®   Iô  ió calleä witè thå Á Reç containinç  thå  indeø 
offseô  intï thå BIOÓ JMĞ table®   Nï registeró arå preserveä  bù 
thió routine®   Thå contentó oæ HL¬  DE¬ anä BÃ arå passeä tï thå 
BIOS unchanged.

     The following table summarizes the BIOS JMP Table Entries --

   Offset Function
      0   Cold Start
      1   Warm Start
      2   Console Status; Returns A=0FFH if char ready, A=0 if
               not
      3   Console Input; Returns char in A
      4   Console Output; Char passed in C
      5   List Output; Char passed in C
      6   Punch Output; Char passed in C
      7   Reader Input; Returns char in A

      8   Home Disk Head (Return Version Number); Returns
               Version Number in HL
      9   Select Disk; Disk Number (A=0, etc) passed in C
     10   Set Track Number; Track Number passed in C
     11   Set Sector Number; Sector Number passed in C
     12   Set DMA Address; DMA Address passed in BC
     13   Read Block from Disk; Returns A=0 if OK, A=1 if Error
     14   Write Block to Disk; Returns A=0 if OK, A=1 if Error

     15   List Status; Returns A=0FFH if ready to output, A=0
               if not
     16   Sector Translation; Logical-to-Physical Sector
               Translation; Logical Sector Number passed in BC
               and Translate Table Address passed in DE; Returns
               Physical Sector Number in HL
Š
     Inputs:  A = Offset (as per Table Above)
              BC = Input Parameters

     Outputs:  A, HL = Output Parameters

     Registers Affected:  All

     SYSLIB Routines Called:  -None-

     Special Error Conditions:  -None-



     Routine Name:  CAPS
     Functionº
          Capitalizå  ASCIÉ  characteò  iî Registeò Á  iæ  iô  ió 
lower-caså  alphabetiã  (a-z)»  otherwise¬  returî Á  unaffected®  
Onlù  thå loweò seveî bitó oæ thå bytå arå  considered¬  anä  thå 
Mosô Significanô Biô ió maskeä ouô tï zero.

     Inputs:  A = character to capitalize

     Outputs:  A = capitalized character

     Registers Affected:  PSW

     SYSLIB Routins Called:  -None-

     Special Error Conditions:  -None-



     Routine Name:  CAPSTR
     Function:
          CAPSTÒ capitalizeó thå <NULL>-terminateä strinç pointeä 
to by HL.  No Registers are affected.

     Inputs:  HL pts to first byte of string

     Outputs:  None (String is Capitalized)

     Registers Affected:  None

     SYSLIB Routines Called:  CAPS

     Special Error Conditions:  None



     Routine Name:  CATH
     Functionº
          Converô  thå  ASCIÉ  Hexadecimaì  characteò  iî  thå  Á 
Registeò tï binarù iî thå Á Register®   Iæ invaliä characteò (noô 
0-9¬ A-F)¬ returî <SP¾ (2° Hex© iî Á Registeò aó erroò code.

     Input:  A = ASCII Hex Character (0-9, A-F)

     Output:  A = Binary value represented by char

     Registers Affected:  PSW

     SYSLIB Routines Called:  -None-
     Speciaì Erroò Conditions:
          Iæ  invaliä  heø  char¬  <SP¾ (2° Hex©  returneä  iî  Á 
Register.



     Routine Name:  CLINE
     Function:
          Tï  savå thå commanä linå buffeò pteä tï bù HÌ awaù  iî 
aî internaì buffeò aó á string®   Thå characteò counô ió  pointeä 
tï bù HÌ (likå thå buffeò aô 80È seô bù ZCPR² anä CP/Í 2.2)¬  anä 
thå  buffeò contentó (noô includinç thå characteò count© ió saveä 
awaù aó á null-terminateä string®   Thió routinå returnó witè  HÌ 
pointing to the first character of this string.

     Inputs:  HL points to command line

     Outputs:  HL points to first character of string

     Registers Affected:  HL

     SYSLIB Routines Called:  -None-
     Special Error Conditions:  -None-



     Routine Name:  CODEND
     Functionº
          Returî  thå addresó oæ thå nexô pagå followinç thå lasô 
bytå  oæ code®   Thió ió usefuì iî determininç wherå thå  scratcè 
areá begins.

     Inputs:  None

     Output:  HL=Address of next page

     Registers Affected:  HL

     SYSLIB Routines Called:  -None-
     Special Error Conditions:  -None-

     Routine Name:  EN
     Functionº
          Exchangå  Nybbleó iî Registeò A»  High-ordeò fouò  bitó 
arå exchangeä witè Low-ordeò fouò bitó oæ Registeò A.

     Inputs:  A = Byte input

     Outputs:  A = Byte output

     Registers Affected:  PSW

     SYSLIB Routines Called:  -None-

     Special Error Conditions:  -None-



     Routine Names:  FILLB, FILLBC, HFILB, HFILBC
     Functionº
          Theså  routineó filì aî areá oæ memorù witè á  constanô 
bytå value®   FILLÂ caî filì uğ tï á 256-bytå buffer¬  anä FILLBÃ 
caî filì uğ tï á 65,536-bytå (withiî reason© buffer.
     FILLÂ  anä FILLBÃ havå nï effectó oî anù  registers®   HFILÂ 
anä HFILBÃ botè affecô thå HÌ registeò pair¬ anä theù returî witè 
HÌ  pointinç tï thå bytå afteò thå lasô bytå filled®   HFILÂ  anä 
HFILBÃ  arå  usefuì wheî furtheò processinç froí thå  lasô  poinô 
filled is desired.

     Inputs:  HL points to the first byte of the buffer
              B (for FILLB) or BC (for FILLBC) = number of bytes
               in buffer
              A = byte value to fill buffer with

     Outputs:  None for FILLB and FILLBC (Buffer is filled)
               HÌ pointó tï nexô bytå foò HFILÂ anä HFILBC

     Registers Affected:  None for FILLB, FILLBC; HL for HFILB,
                              HFILBC

     SYSLIB Routines Called:  -None-

     Special Error Conditions:  -None-



     Routine Names:  MOVEB, MOVEBC, HMOVB, HMOVBC
     Functionº
          Movå thå blocë oæ memorù pointeä tï bù HÌ tï thå memorù 
locatioî  pointeä  tï bù DE®   MOVEÂ caî movå uğ  tï  á  256-bytå 
buffer¬ anä MOVEBÃ caî movå uğ tï á 65,536-bytå buffer.

     MOVEÂ  anä MOVEBÃ havå nï effectó oî anù  registers®   HMOVÂ 
anä HMOVBÃ botè affecô thå HÌ registeò pair¬ anä theù returî witè 
HÌ anä DÅ pointinç tï thå bytå afteò thå lasô bytå moved®   HMOVÂ 
anä HMOVBÃ arå usefuì wheî furtheò processinç froí thå lasô poinô 
filleä ió desired.


     Inputs:  HL points to the 1st byte of the buffer to move
              DE points to the 1st byte of the buffer to move to
              B (for MOVEB) or BC (for MOVEBC) = number of bytes
               in buffer

     Outputs:  None for MOVEB and MOVEBC (Buffer is moved)
               HL and DE pt to byte after last byte moved for
                    HMOVB and HMOVBC

     Registers Affected:  None for MOVEB, MOVBC; HL, DE for
                              HMOVB, HMOVBC

     SYSLIB Routines Called:  -None-

     Special Error Conditions:  -None-




     Routine Name:  PAUSE
     Function:
          Delay N 10ths of a Second.
     Inputs:  HL = N (Number of 10ths of a Second Delay desired)
              B = Processor Speed in MHz (1, 2, 3, 4, ...)
     Outputs:  None (Routine returns N 10ths of a Second later)
     Registers Affected:  None
     SYSLIB Routines Called:  None
     Special Error Conditons:  None




     Routine Name:  VERSION
     Function:
          Return Version Number of SYSLIB.
     Inputs:  None
     Outputs:  HL = Version Number (H=Major, L=Minor)
     Registers Affected:  HL
     SYSLIB Routines Called:  None
     Special Error Conditons:  None
.fo 20 - Cross-Reference Listing of SYSLIB Routines        Page #

20.0 Cross-Reference Listing of SYSLIB Routines

Symbol	Defined	Referenced

ADDHD   SMATH
ADRCPY  SFILEI  S0FILE  S1FILE  S2FILE  S3FILE  
ANDHD   SMATH

BBLINE	SBBLIN
BDOS    SBODS   SZFNAM  SZCPR   SFOPEN  SFEXIS  SFMAKE
                SFCLOS  SRENAM  SFREAD  SFWRIT  SFDEL
                SUD
BIOS    SBIOS   
BLINE	SBLINE

CAPS    SCAPS   SZFNAM  SFNAME  SEVAL   SEVAL2  SBBLIN
                SBLINE  SCAPST  
CAPSTR  SCAPST  
CATH    SCATH   
CCOUT	SCCOUT	SINLIN	SPSTR
CIN     SCIN    SCONDI  SINLIN  
CLINE   SCLINE
CLOUT	SCLOUT	SLPSTR
CMPH    SMATH
CODEND  SCODEN  
COMPB   SCOMP   
COMPBC  SCOMP   
COMPHD  SCOMPH  
CONDIN  SCONDI  SRAND
COUT	SCOUT	SINLIN	SPSTR	SPHL5D	SPA2HC	SPADC
			SCRLF	SCCOUT
CPOUT   SCPOUT  
CRC1CL  SCRC1   
CRC1DO  SCRC1   
CRC1UP  SCRC1   
CRC2CL  SCRC2
CRC2DO  SCRC2
CRC2UP  SCRC2
CRCCLR  SCRC    
CRCDON  SCRC    
CRCUPD  SCRC    
CRLF	SCRLF	SINLIN
CST     SCST    SCONDI  

DBUFFE  SDIR
DFREE	SDIR
DIRALP	SDIR
DIRF	SDIR
DIRFS	SDIR
DIRLOA	SDIR
DIRNPA	SDIR
DIRPAC	SDIR
DIRSEL	SDIR
DIRSLO	SDIRŠSymbol	Defined	Referenced

DIVHD   SMATH
DPARAM  SDIR    

EN      SEN     SMA2HC  SLA2HC  SPA2HC  
EVAL    SEVAL   
EVAL10  SEVAL1  SEVAL   
EVAL16  SEVAL2  SEVAL   
EVAL2   SEVAL4  SEVAL   
EVAL8   SEVAL3  SEVAL   

F$CLOS	SFCLOS
F$DELE	SFDEL	SFMAKE
F$EXIS  SFEXIS
F$GET   SFILEI  S0FILE  S1FILE  S2FILE  S3FILE  
F$MAKE	SFMAKE
F$MOPE	SFOPEN	SFILEI
F$OPEN	SFOPEN	SFILEI
F$PUT   SFILEI  S0FILE  S1FILE  S2FILE  S3FILE  
F$READ	SFREAD
F$RENA  SRENAM
F$WRIT	SFWRIT

F0$GET  S0FILE  
F1$GET	S1FILE  
F2$GET  S2FILE  
F3$GET  S3FILE  SZFNAM
F0$PUT  S0FILE  
F1$PUT  S1FILE  
F2$PUT  S2FILE  
F3$PUT  S3FILE  
FI$CLO  SFILEI  S0FILE  S1FILE  S2FILE  S3FILE  
FI0$CL  S0FILE  
FI1$CL  S1FILE  
FI2$CL  S2FILE
FI3$CL  S3FILE  SZFNAM
FI$OPE  SFILEI  S0FILE  S1FILE  S2FILE  S3FILE  
FI0$OP  S0FILE  
FI1$OP  S1FILE  
FI2$OP  S2FILE  
FI3$OP  S3FILE  SZFNAM

FILLB	SFILL	SINITF
FILLBC  SFILL   
FNAME   SFNAME  


Symbol	Defined	Referenced

FO$CLO  SFILEI  S0FILE  S1FILE  S2FILE  S3FILE
FO$OPE  SFILEI  S0FILE  S1FILE  S2FILE  S3FILE  
FO0$CL  S0FILE  
FO1$CL  S1FILE  
FO2$CL  S2FILE  
FO3$CL	S3FILE
FO0$OP  S0FILE  
FO1$OP  S1FILE  
FO2$OP  S2FILE  
FO3$OP	S3FILE

FSIZE   SDIR    

GETUD   SUD

HFILB	SFILL   
HFILBC  SFILL   
HMOVB   SMOVE   
HMOVBC  SMOVE   

INITFC	SINITF	SFIELI  SZFNAM
INLINE	SINLIN
INSTR   SINSTR  

LA2HC	SLA2HC	SLHL4H
LA3DC	SLADC
LADC	SLADC
LCRLF   SLCRLF  
LHL4HC	SLHL4H
LHL5DC	SLHL5D
LHLDC	SLHL5D
LOGUD   SUD
LOUT	SLOUT	SLPSTR	SLHL5D	SLA2HC	SLADC	SLCRLF
			SCLOUT
LPRINT	SLPRIN
LPSTR	SLPSTR	SLPRIN

MA2HC   SMA2HC  SMHL4H  
MA3DC   SMADC   
MADC    SMADC   
MHL4HC  SMHL4H  
MHL5DC  SMHL5D  
MHLDC   SMHL5D  
MOVEB   SMOVE   SZFNAM  SSORT   SRENAM  SZGPIN
MOVEBC  SMOVE   
MULHD   SMATH

NEGH    SMATH

ORHD    SMATH


Symbol	Defined	Referenced

PA2HC   SPA2HC  SPHL4H  
PA3DC   SPADC   
PADC    SPADC   
PAUSE   SPAUSE  
PHL4HC  SPHL4H  
PHL5DC  SPHL5D  
PHLDC   SPHL5D  
POUT    SPOUT   SCPOUT  
PRINT   SPRINT  SDIR    SSORT   SRAND
PSTR    SPSTR   SPRINT  
PUTUD   SUD

RETUD   SUD
RIN     SRIN    
ROTLH   SMATH
ROTRH   SMATH
RND     SRAND
RNDINI  SRAND
RNDSEE  SRAND

SCANNE  SSCANN  
SHFTLH  SMATH
SHFTRH  SMATH
SORT    SSORT   
SSBINI  SSORT
SUBHD   SMATH

VERSIO  SVERSI

XORHD   SMATH

ZCPRQ   SZCPR
ZCPRQ2  SZFNAM
ZDNAME  SZFNAM
ZDNFIN  SZFNAM
ZFNAME  SZFNAM
ZFNINI  SZFNAM  SZGPIN
ZFSTAT  SZCPR
ZGPINS  SZGPIN
ZINICI  SZCPR   SZGPIN
ZINIDM  SZCPR   SZGPIN
ZINIEX  SZCPR   SZGPIN
ZINIMC  SZCPR   SZGPIN
ZMCPTR  SZCPR
ZPFIND  SZCPR   SZFNAM

.fo 21 - Sample Programs Using SYSLIB                      Page #

.FI SYSLIBS.WS

