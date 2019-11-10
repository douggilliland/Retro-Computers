                         What is SYSLIB?

     SYSLIÂ  (SYSteí LIBrary© ió á collectioî oæ oveò 13° subrou
tineó whicè arå designeä tï providå tï thå CP/Í 8080/Z8° assemblù 
languagå  programmeò á seô oæ functionó upoî whicè hå  caî  builä 
hió programs®  Thió librarù ió intendeä tï relievå thå programmeò 
oæ  thå tasë oæ frequentlù "reinventinç thå wheel¢ anä tï providå 
hií   witè  aî  tooì  environmenô  whicè  encourageó   structureä 
programminç aô thå assemblù languagå level.

     Eacè  subroutinå withiî SYSLIÂ caî bå vieweä aó  á  reliablå 
"blacë box.¢  Thå subroutineó iî SYSLIÂ arå completelù documenteä 
withiî  thió 100« pagå manuaì anä thå SYSLIBx.HLĞ files¬  anä thå 
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
complemenô  eacè other®   Parameteò passinç ió consistenô betweeî 
thå variouó subroutines» foò instance¬ alì routineó whicè neeä tï 
bå  passeä  á  pointeò tï á Filå Controì Blocë  arå  passeä  thaô 
pointeò iî thå DÅ registeò pair®   Also¬  aó á generaì rule¬ iæ á 
registeò ió noô returneä aó aî outpuô froí thå SYSLIÂ subroutine¬ 
theî  itó valuå ió noô affecteä (iô haó thå samå valuå  wheî  thå 
routinå ió exiteä aó iô haä wheî thå routinå waó called).

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
another routine within the module).


                  What is Needed to Use SYSLIB?

     Yoõ  neeä aî 8080- oò Z80-baseä microcomputeò witè aô  leasô 
48Ë  byteó oæ contiguouó memorù runninç CP/Í 2.2¬  thå  Microsofô 
M8°  assembleò tooì seô (specifically¬  thå M8° assembleò anä thå 
L8° linker)¬  anä thå usuaì seô oæ softwarå developmenô tooló (aî 
editoò and¬ preferably¬ á debugger© tï uså SYSLIB.Š
                    What Does SYSLIB Buy Me?

     Thå bottoí linå ió that¬  tï thå experienceä SYSLIÂ program
mer¬  SYSLIÂ haó thå potentiaì oæ beinç á significanô tooì  whicè 
enableó hií to:

          1.  Solve his programming task quickly
               -- becauså  hå spendó lesó timå writinç  com
    monly-useä subroutineó anä worryinç abouô ho÷ hió regis
    teró  arå  affecteä bù theså subroutineó anä  morå  timå 
    concentratinç oî thå probleí aô hand

          2.  Write space- and speed-efficient code
               -- becauså  alì oæ thå SYSLIÂ  routineó  havå 
    beeî  gonå oveò timå agaiî tï reducå theiò sizå anä makå 
    theí morå efficienô iî termó oæ speed»  foò example¬ thå 
    SORÔ  routinå  ió  á Shelì Sorô thaô caî  bå  calleä  tï 
    perforí  thå sorô usinç pointeró (iî whicè caså  iô  ex
    changeó pointeró ratheò thaî recordó wheî iô needó tï dï 
    á swap© oò perforí thå sorô withouô usinç pointeró (wheî 
    spacå ió á factoò anä therå maù noô bå enougè rooí foò á 
    pointeò table)

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
assemblù languagå programmer¬  whilå allowinç hií tï maintaiî thå 
smalleò codå sizå anä greateò efficiencù whicè caî bå realizeä iî 
assemblù  languagå  programminç anä simultaneouslù realizå á  re
duceä  life-cyclå  cosô (froí developmenô tï  fieldinç  tï  post-
fieldinç  maintenancå  anä modification© oveò  assemblù  languagå 
programminç withouô á SYSLIB-likå tooì set.



                 How Do I Assemble with SYSLIB?

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



            How Do I Learn to Use SYSLIB Effectively?

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



                       Who May Use SYSLIB?

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
