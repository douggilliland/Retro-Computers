.PN
.FO Page #
.PC 5
.MT 3
.MB 3

















============================================================================

                       BBBB          222         9999   
                       B   B        2   2       9    9  
                       B   B            2       9    9  
                       BBBB            2         99999  
                       B   B          2              9  
                       B   B         2               9  
                       BBBB         22222        9999   

============================================================================
 


 


                                  B29.COM
                  Version 3.04     Written by Gary Conway
                     Infinity Design Concepts  (c) 1985,86


     MEMBER : KKUG - Kentuckiana Kaypro Users Group
              IEEE - Institute of Electrical and Electronics Engineers, INC.
              PCCL - Portable Computer Club of Louisville

















Š                                  FORWARD

     Thió  prograí ió án Newsweeğ work-alikå anä É musô pauså herå  tï  givå 
crediô  wherå crediô ió due®  Anyonå whï haó useä Newsweeğ tï anù degreå  aô 
alì  haó  surelù realizeä alì oæ thå worë anä efforô thaô haó gonå intï  thå 
creatioî oæ thió excellenô program®  Mr®  Ranä haó certainlù donå á finå joâ 
iî thå developmenô oæ Newsweep®  Thå layouô alonå anä iî particulaò thå ideá 
oæ  tagginç  fileó foò masó operationó ió onå oæ thå  finesô  features®  Thå 
layouô  oæ B2¹ ió verù similaò anä É musô offeò á heartù thank-yoõ  tï  Davå 
Rand¬  whoí  É havå neveò eveî spokeî tï anä tï thå creator/ó oæ SWEEP¬  thå 
original®  É  havå beeî á religouó useò oæ Newsweeğ foò somå timå anä  beinç 
onå  whï cannoô leavå welì enougè alone¬  É firsô wanteä tï adä á reaì  timå 
clocë  featurå anä pagebreakó iî printinç tï Newsweep®  Afteò somå  timå  oæ 
playing¬  É  decideä tï writå mù owî versioî oæ á sweeğ prograí addinç  somå 
features® Thå maiî featureó thaô É havå addeä arå listeä below:

     <1> Pagebreaks and expanded TAB's when printing files.
     <2> Print tagged files.
     <3> Printing of .COM files.
     <4> Prints filename on printout.
     <5> Printer strings.
     <6> Printing multiple copies.
     <7> Clean abort of print.
     <8> A HEX dump facility for viewing .COM files (DDT type Dump).
     <9> An easier to use Set file attribute function.
    <10> If the user tries to View a .COM file, it will simply give a HEX
         dump to the screen, the same goes for printing a .COM file
    <11> Real time display.
    <12> Moving files from one user area to another (without copying).
    <13> Library File Sweep Mode (View,Print,Extract).


     Yoõ wilì noticå thå lacë oæ á squeezå  facility® Thå reasoî foò thió ió 
quitå simple®  Aô present¬  É don'ô kno÷ ho÷ tï squeezå files® Thaô ió oî mù 
agendá  oæ  thingó tï learn®  Wheî É do¬  É wilì incorporatå thió  intï  thå 
prograí also®  Thió prograí ió writteî witè thå standarä CP/Í assembler® Anù 
commentó oò suggestionó wilì gladlù bå accepteä aó welì aó á $10.0° donatioî 
iæ  yoõ  enjoù usinç thå program®  Thió prograí ió copyrighteä anä ió  giveî 
freelù intï thå publiã domain¬ however¬ nï parô oæ thió prograí ió permitteä 
tï  bå useä iî conjunctioî witè anù salå whatsoever¬  withouô prioò  writteî 
consenô froí thå author.


CP/M 3.0 and MP/M

     B2¹ versioî 3.°x ió thå firsô versioî tï bå compatiblå witè CP/Í 3.° anä 
MP/M.

Sort to Disk Option GONE !

     Versioî  3.° haó losô thå sorô tï disë option®  Iô becamå á probleí  oî 
manù  machineó witè harä diskó tï keeğ alì oæ thå directorù  informatioî  iî 
concurrenô  RAÍ  witè  B2¹ ¬  itó bufferó anä CP/Í  itself®  Iô  waó  almosô 
impossiblå  tï  uså oî á bulletiî boarä systeí witè á harä drivå alonç  witè 
thå RAÍ residenô bulletiî boarä softwarå ¨ BYÅ etc®  )® If¬ foò example¬ yoõ 
havå á harä disë witè 100° directorù entries¬  thió wilì requirå 32Ë oæ  RAÍ 
tï  holä thå entirå directory»  coupleä witè thå facô thaô B2¹ useó 14Ë  anä 
haó aî 8Ë generaì purposå buffer¬  thió accountó foò 54Ë oæ á 64Ë RAÍ systeí 
anä coulä easilù clobbeò CP/M®  Iî ordeò tï makå thå prograí aó universaì aó 
possible, I reluctantly decided to remove the sort to disk option.Š

     Send Comments To:   Infinity Design Concepts
                         Gary Conway
                         1052 Parkway Drive
                         Louisville, Kentucky  40217
                         (502)634-0054


     - OR -  E-MAIL c/o
                         The SoftStone RCP/M   (FOG #24)
                         Louisville, Kentucky
                         (502)241-4109
               Leave Message to My Attention OR to the SYSOP








                            ERRORS CAUGHT BY B29 

     1® BDOÓ erroò oî Xº  selecô -   Wheî selectinç á ne÷ drive¬  B29‚ checkó 
                                     firsô  tï seå iæ thå drivå ió indeeä oî 
                                     linå  beforå actuallù makinç thå  drivå 
                                     selection®  Thió  ió donå witè  á  BIOÓ 
                                     calì  aó  opposeä  tï á  BDOÓ  calì  tï 
                                     avoiä   thå   inherenô  BDOÓ   checkinç 
                                     procedure.
     2® COPÙ  tï samå drive/useò -   Thió ió somethinç thaô  mosô  peoplå 
                and filename         would not wish to do and B29 will not
                                     allow this.
     3® ANÙ operatioî oî aî R/Ï filå - Iæ thå useò trieó tï copù oveò  oò 
                                     deletå  an R/Ï file¬ thå useò ió advised
                                     oæ thió conditioî anä ió askeä  whetheò or
                                     not to proceed with the operation.
     4®  Nï directorù spacå lefô -   Iæ á copù operatioî ió attempteä tï á disk
                                     thaô haó nï directorù spacå available¬ the
                                     user is advised of this and the copy is 
                                     aborted.
     5®  Nï spacå lefô oî dest® dò - Iæ á copù operatioî ió attempteä tï á dr.
                                     that has no space left or if the drive
                                     runs out of space before the copy is 
                                     complete, the copy is aborted.

                               G E N E R A L

          1.   Upper or lower case may be used throughout the program.
          2.   Carriage return aborts any operation or question.
          3.   Any operation or prompt may be aborted by simply hitting
               <RETURN>.
          4.   Any attempt to VIEW,PRINT or DUMP Squeezed files, will cause
               the file to be unsqueezed first.
          5.   Viewing an .LBR file will envoke Library File Sweep Mode. 



Š          
Thå  listinç belo÷ showó whicè functionó operatå oî singlå fileó  anä  whicè 
functions operate on severaì files.

          SINGLE OPERATIONS                       MASS OPERATIONS

          1. Single file copy                     1. Wildcard tag
          2. Hexdump file                         2. Mass copy
          3. View file                            3. Erase tagged files
          4. Rename file                          4. Move files to new user
          5. Tag file                             5. Print tagged files
          6. Untag file                           6. Unsqueeze files
          7. Delete file                          7. Rename files
          8. Find file      

                             -----------------

ACKNOWLEDGEMENTS:
     É  woulä likå tï thanë severaì folkó foò theiò undyinç participatioî iî 
thå ever-importanô beta-testinç stageó aó welì aó actinç aó sourceó oæ ideaó 
anä  bouncinç boardó foò mù owî ideas®  É woulä likå tï thanë  Jerrù  Tayloò 
(Mr®  Find-a-buç himself)¬  anä Curô Edwardó foò ideaó aó welì aó testinç oî 
thå olå OZZY® É woulä likå tï extenä á heartù remotå thankó tï Stevå Sanderó 
foò  hió  ideá  oæ puttinç thå installatioî parameteró aô thå starô  oæ  thå 
program¬ whicè ultimatelù leä tï thå creatioî oæ thå B29INST.COÍ program¬ aó 
welì aó hió supplyinç  thå sourcå tï Unsqueezinç files® É woulä alsï likå tï 
expresó  mù appreciatioî tï Ernesô Drydeî (SYSOĞ FOG#23© foò hió aiä iî  thå 
implementatioî  oæ  CP/Í  3.° anä foò hió aiä iî debugginç thå  3.°  versioî 
also.

     INVOKING B29
There are several ways to call B29.

A0>B29 *          logs all users on the default drive
A0>B29 B          logs drive B in the current user
A0>B29 B3         logs drive B in user 3
A0>B29 B12        logs drive B in user 12
A0>B29 B*         logs drive B all files in all users
A0>B29 B7*        logs drive B user 7 and displays all files in all users
A0>B29 B12;*.COM  logs B, user 12 and all .COM files
A0>B29 B*;*.COM   logs all users and all .COM files


     Thå  bottoí  linå ió thaô yoõ maù uså jusô abouô anù commanä linå  thaô 
makes sense to you. All CP/M wildcards are also valid.
     Iæ  aî invaliä drivå designatioî ió given¬  theî thå defaulô drivå  anä 
useò  arå loggeä in®  Afteò B2¹ beginó executioî anä iô haó reaä anä  sorteä 
thå  disë  directory¬  thå  useò ió askeä iæ hå wisheó tï writå  thå  sorteä 
directorù bacë tï thå disk®  Iæ thå useò chooseó tï dï this¬  theî thå  disë 
directorù  wilì bå writteî bacë tï thå disë iî á sorteä anä packeä  fashion® 
Thå  packinç featurå removeó alì deleteä filenameó froí thå directory®  Thió 
ió  thå  onlù  poinô  iî thå prograí wherå thå useò  maù  writå  thå  sorteä 
directorù bacë tï thå disk®  Onå mighô asë whù noô dï iô everù timå thaô yoõ 
loç iî á ne÷ disk®  Thió waó á poinô oæ somå thoughô anä discussioî anä  thå 
resultanô  decisioî  tï offeò thió onlù oncå waó madå iî aî efforô  tï  keeğ 
thió  selectioî  iî thå realí oæ optionó ratheò thaî á nuisance®  Iô ió  noô 
thaô  ofteî thaô onå wisheó tï sorô anä pacë thå disë  directory®  Oncå  thå 
directorù  ió  sorteä tï disk¬  theî therå ió nï waù tï recoveò  anù  ERAseä 
fileó witè UNERA.COÍ oò otheò sucè programs®  Also¬ afteò thå disë directorù 
ió sorted¬  wheî thå useò useó thå DIÒ commanä iî CP/M¬ hå wilì seå á sorteä Šdirectory.
     Thå sorô formaô ió  USEÒ AREA¬ FILENAME¬ FILÅ EXTENSION® Thió formaô ió 
noô quitå thå samå aó NSWEEP®  Thå resulô ió thaô alì fileó wilì bå showî iî 
ascendinç useò areaó witè thå filenameó subsorteä withiî eacè useò area® Thå 
potentiaì  probleí herå ió iæ thå useò logó ALÌ useró anä haó thå samå  filå 
iî twï oò morå useò areaó anä wisheó tï FINÄ thå file® Thå FINÄ commanä wilì 
only find the first occurence.

                            --------------------

     RETAG FILES              <A> command
Thió  optioî  wilì retaç fileó thaô werå previoulsù taggeä beforå  anù  masó 
operation.

                            -------------------

     FORWARD ONE FILE         <CR) or <SP> command
     
     Thió  commanä wilì movå tï thå nexô filå iî thå list®  Carriagå  returî 
will move one file only, while the space bar will move forward continously.

                            -------------------


     BACK ONE FILE            <B> command
Thió  optioî moveó thå cursoò bacë onå filå iî thå directory®  Wheî  aô  thå 
beginning of the directory, the cursor is returned to the last file.

                            -------------------




     COPY SINGLE FILE         <C> command
Thió optioî wilì copù á singlå filå tï anù drive/user®  Iæ onlù thå drivå oò 
drivå anä useò codeó arå given¬  theî thå filå ió copieä witè thå samå name® 
Iæ  aî  attempô ió madå tï copù tï thå samå drivå anä useò aó  thå  originaì 
file, then the copy is simply not made.
     Valid entries are:  B
                         B3
                         B12
                         B3:
                         B3;MICKEY
                         B12:MICKEY.MSE
     oò  anù combinatioî thereof®  Nï wildcardó arå permitteä  here®  Iæ  nï 
filenamå  ió  given¬  theî thå filå ió copieä tï thå destinatioî  drive/useò 
witè thå filenamå unchanged®  Thå "Verify¢ option¬  iæ selected¬ wilì rereaä 
thå  destinatioî filå anä checë thå CRÃ valuå witè thå valuå oæ thå originaì 
file and report any mismatch.

                             -----------------


     DELETE CURRENT FILE      <D> command
Thió  optioî wilì deletå thå currenô file®  Iæ thå filå haó beeî seô tï R/O¬ 
theî  anotheò messagå ió giveî anä thå useò ió askeä iæ hå stilì  wisheó  tï 
deletå  thå file®  Iæ hå does¬  hå musô answeò witè 'Y¢ oò 'y§ anä thå  filå 
wilì bå deleted¬  otherwiså therå ió nï deletion® Á carriagå returî alonå aô 
anù oæ thå promptó wilì aborô thå deletå operation® Thå filå wilì bå deleteä 
froí thå disë directorù aó welì aó froí thå directorù iî RAÍ thaô B2¹  uses® ŠThå  filå  numbeò  thaô  haä beeî assigneä tï thaô filå wilì  nï  longeò  bå 
displayeä oî thå screeî anä thå remaininç fileó wilì noô bå renumbered® Thió 
waó  donå  purposelù  sï thaô iæ á filå ió deleteä anä theî  lateò  yoõ  asë 
yourselæ  whaô yoõ haä jusô deleted¬  yoõ wilì havå somå ideá becauså oæ thå 
missinç filå number. If you must renumber, just log the drive in again.

                            --------------------

     ERASE TAGGED FILES       <E> command
Thió optioî wilì onlù deletå thå taggeä files¬ whereaó Newsweeğ woulä deletå 
eitheò  taggeä  oò  untaggeä  files®  Afteò á  greaô  deaì  oæ  thoughô  anä 
discussion¬ É decideä noô tï includå thå optioî tï deletå taggeä oò untaggeä 
files¬  becauså thió seemó toï dangerouó anä É personallù havå onlù useä thå 
deletioî oæ taggeä files®  Iæ thå filå ió R/O¬  thå useò wilì bå prompteä aó 
with DELETE.

                            --------------------

     FIND FILE                <F> command
Enteò  anù  filespeã  oò wildcarä filespeã anä thå prograí wilì  locatå  thå 
firsô filå thaô complies®  Thió maù bå aó brieæ aó á singlå characteò oò  aó 
complex as wildcards will allow.
     
                         WS???.COM
                         ?-GETS.*
                         B*.*
                         B29*.C?? 
                         DD          etc...

                            --------------------

     LOG NEW DRIVE/USER/MASK       <L> command

     Thió  optioî  allowó  logginç iî oæ á ne÷ drivå oò useò  oò  mask®  Thå 
minimuí requiremenô ió thå drivå code®  Thå drivå codå ió checkeä tï seå  iæ 
thaô drivå ió oî line®  Iæ iô is¬  processinç continues¬  however¬  iæ iô ió 
not¬  á  messagå  ió  displayeä  anä thå useò ió prompteä tï loç  iî  á  ne÷ 
drive/user®  Thå useò maù wisè tï givå thå useò numbeò oò '*§ foò alì  useró 
oò á masë sucè aó *.com¬ whicè wilì loç iî alì .COÍ files® Yoõ caî alsï omiô 
thå  drivå  anä jusô givå thå useò anä B2¹  wilì loç yoõ intï thaô  useò  oî 
the previously selected drive.

                         B
                         B: (or ;)
                         B0;*.COM
                         B12;WS??.COM 
                         B*:WS*.*       etc...

                            --------------------

     MENU           <?> or </> command
     Thå menõ ió displayeä initiallù wheî B2¹ ió calleä anä eacè timå á  ne÷ 
drivå  ió logged®  Tï displaù thå menõ aô anù otheò time¬  hiô thå  questioî 
marë  key®  Thió maù bå donå witè oò withouô thå shifô key®  Iî otheò words¬ 
the menu is called by '?' or '/'. Total disk space is also shown.

                           ---------------------

     TAG FILES           <T> command
     Thió  optioî  tagó fileó foò masó operationó copyinç  oò  settinç  filå Šattributes¬  etc®  Thå screeî wilì sho÷ thå numbeò oæ K-byteó thaô havå beeî 
taggeä includinç thå currentlù taggeä file® Iæ inverså videï ió active¬ theî 
theså  wilì bå showî iî inverså video®  Afteò tagginç thå currenô file¬  thå 
currenô filå pointeò ió incrementeä tï thå nexô file.

                           ----------------------

     UNTAG FILES         <U> command
     Thió  commanä ió thå oppositå oæ thå TAÇ commanä iî thaô iô untagó  thå 
currenô  filå  (iæ  tagged© anä subtractó thå filå sizå froí thå  numbeò  oæ 
tagged bytes and displays the new total.

                           ----------------------

     WILDCARD TAG        <W> command
     Thió  commanä allowó tagginç oæ anù oò alì fileó usinç CP/Í  wildcards® 
Any wildcards or even an unambigous filename may be used. See FIND command.

                           ----------------------

     MASS COPY           <M> command
     Thió commanä wilì allo÷ copyinç oæ alì taggeä fileó tï anù drivå anä oò 
useò  desired®  Tï  aborô  anù copy¬  simplù hiô anù  keù  durinç  thå  copù 
operatioî anä wheî thå currenô filå ió finisheä copying¬ thå copyinç procesó 
wilì bå aborteä witè á messagå tï thaô effect® Thå remaininç fileó thaô havå 
noô beeî copied¬  wilì stilì bå tagged® Thå fileó thaô havå beeî copied¬ arå 
puô intï aî "alreadù copied¢ state¬  signifieä bù á "#¢ iî placå oæ "*"® B2¹ 
knowó  whicè fileó arå currentlù taggeä (*© oò "havå beeî tagged"(#© anä caî 
uså thió foò RETAGGING® Alì fileó thaô arå seô tï "#"¬ wilì bå retaggeä wheî 
usinç thå (A)¬ retaç command® Thió optioî alsï allowó CRC® (seå SINGLÅ COPY)

                            --------------------

     VIEW FILE           <V> command

     Thå  vie÷ commanä wilì prinô thå currenô filå onscreen®  Aô thió  poinô 
B2¹ will check to see if this is a squeezed file and unsqueeze if necessary.
     Iæ yoõ trù tï vie÷ á .COÍ file¬  normallù yoõ woulä seå garbagå oî  thå 
screen¬  howeveò B29‚ wilì catcè thió anä dï á HEXDUMĞ instead® Iæ thå useò
trieó tï VIE× á Squeezeä file¬ thå filå wilì bå unsqueezeä first.
     Thå  filå  wilì bå presenteä onå screeî aô á time®  Tï  vie÷  thå  nexô 
screen¬  simplù hiô <RETURN>¬  foò thå nexô line¬  hiô -SPACÅ BAR-® Tï aborô 
hiô  "A¢ oò "a"®  Wheî finished¬  thå screeî wilì bå cleareä anä yoõ wilì bå 
returneä tï thå commanä mode.

     LIBRARY FILE SWEEP MODE
     
     B2¹ allowó viewing¬  printinç anä extractinç fileó froí libraries® Thió 
modå  ió  invokeä bù positioninç thå cursoò oî thå .LBÒ filå anä theî  usinç 
thå  'V§  command®  B2¹  wilì intercepô thå vie÷ commanä  anä  initiatå  thå 
Librarù  Filå  Sweeğ Mode®  Thió modå oæ operatioî ió verù  similaò  tï  thå 
Normaì  Sweeğ Mode®  Thå screeî wilì cleaò anä á lisô oæ commandó ió  shown® 
Therå ió nï tagginç alloweä here® Alì operationó deaì witè singlå fileó witè 
thå  exceptioî  oæ  Extracô All¬  whicè wilì dï exactlù  that®  Alì  oæ  thå 
commands in the menu operate the same as the Normal Sweep Mode commands.


                             ------------------

Š     HEX DUMP FILE       <H> command

     Thió commanä wilì takå ANY‚ filå anä dumğ iô iî HEØ formaô tï thå screeî 
foò  viewing®  Thå optionó availablå arå thå samå aó witè thå VIE×  command® 
Squeezeä fileó wilì automaticallù bå unsqueezed. This is a HEX/ASCII dump.

                           ______________________


     RENAME FILE         <E> command

     Thå  renamå functioî wilì dï exactlù that®  Thå useò maù givå  aó  manù 
characteró  aó hå wisheó foò thå ne÷ filenamå uğ tï thå CP/Í limiô oæ eight® 
Thå  extensioî ió (aó witè CP/M© optional®  Thió functioî alsï checkó tï seå 
iæ  thå  ne÷ namå alreadù existó oî thå disë anä iæ iô does¬  á  messagå  ió 
issued and the rename is aborted.
     Thå renamå functioî alsï haó thå capabilitù tï dï wildcarä renaming® Bù 
enterinç  "*¢ iî responså tï thå renamå prompt¬  thå useò wilì bå askeä  foò 
thå OLÄ filenamå (*.COM¬  WS*.ª etc.© ¬  followeä bù thå NE× name¬ whicè haó 
thå samå syntaø aó thå OLÄ filename®  FOÒ EXAMPLEº Tï renamå alì oæ thå .PRÇ 
fileó tï .CMD¬  thå useò woulä givå *.PRÇ foò thå OLÄ filenamå anä *.CMÄ foò 
thå  NE× name®  Thió woulä causå alì oæ thå fileó witè thå .PRÇ extensioî oî 
that disk to be renamed using the .CMD extension.

                           ---------------------

     SPACE ON DISK       <S> command

     Thå  checkspacå  functioî wilì asë foò whicè drivå tï checë  spacå  on¬ 
checë tï seå iæ thaô drivå ió oî linå anä iæ iô is¬ thå byteó useä anä spacå 
remaininç arå displayed®  Iæ thå selecteä drivå ió noô oî line¬  thå useò ió 
prompteä foò onå thaô is®  Thå blocë sizå ió alsï shown® Thió ió thå minimuí 
file size on your machine.

                            --------------------
     MOVE FILES          <N> command

     Thió  functioî  wilì movå TAGGEÄ fileó froí onå useò areá  tï  another® 
Therå  ió  nï copyinç involveä sincå thå directorù ió reaä anä  scanneä  foò 
matcheó  oæ thå taggeä fileó anä theî thå useò numbeò ió changeä tï thå  ne÷ 
value.
NOTEº  Thió  commanä wilì OBVIOUSLÙ NOÔ moveó fileó tï á differenô useò areá 
       on another disk! Sorry, but you still have to copy...
                            ____________________

     SET FILE ATTRIBUTES      <Y> command

     Thå seô filå attributeó functioî workó witè TAGGEÄ fileó only® Thå useò 
wilì  firsô  taç thå fileó thaô arå tï havå certaiî attributeó seô oò  reseô 
anä  theî select thå <Y¾ option®  B29‚ theî askó whicè attributeó arå tï  bå 
seô  (SYSteí   DIRectorù   R/Ï  - reaä  onlù   oò  R/×  - reaä  write)®  Thå 
attributeó  thaô  havå beeî seô wilì sho÷ uğ aó inverså characteró wheî  B2¹ 
listó thå files® Theså "status¢ bitó arå locateä iî thå Extensioî portioî oæ 
thå filename®  Thå firsô bytå oæ thå extensioî ("C¢ iî  á ".COM¢ file© holdó 
thå  R/Ï oò R/× attributes®  Thå "O¢ byte  holdó thå SYÓ oò DIÒ  attributes® 
Whaô  reallù happenó herå ió thaô witè normaì ASCIÉ characteró thå higè  biô 
ió zero®  Iæ yoõ looë aô aî ASCIÉ charô anä iî particular¬  thå HEØ  values¬ 
yoõ wilì noticå thaô thå charô stopó aô 7F® 7F(HEX)¬ iî binary¬ ió 01111111¬ 
thå  higè  biô  beinç zero®  Alì otheò ASCIÉ valueó arå smalleò  thaî  this¬ 
therefore¬  theiò  higè biô ió alsï zero®  CP/Í doeó noô uså thió  biô  wheî Šopeninç  á  file¬  iî  otheò words¬  iæ yoõ givå CP/Í á  filenamå  witè  thå 
ASCIÉ  characteò "A¢ whicè ió 41(HEX)¬  yoõ coulä jusô aó easilù havå  giveî 
C1(HEX)®  41(HEX© ½ 0100000± binarù anä C1(HEX© ½ 1100000± binary®  Thå onlù 
difference is the high order bit. 
     The purpose of these attributes is given below:

     SYS ....... The file will not be shown when using the CP/M  DIR command
     DIR ....... The file WILL be shown with the DIR command
     R/O ....... A read only file cannot be deleted or written to by any
                     normal CP/M commands.
     R/W ....... A read write file is the normal setting for CP/M files,
                     i.e. they can be read, written, deleted.
                           ----------------------
     PRINT TAGGED FILES       <P> command

     Thå  prinô  fileó commanä wilì prinô alì taggeä files®  Wheî thå  PRINÔ 
optioî ió selected¬  thå useò ió prompteä foò á printeò pitch®  Thå codå foò 
thå  printeò  iî uså shoulä havå beeî installeä witè  B29INST.COÍ  prioò  tï 
printing¬ iî ordeò tï worë correctly.(Seå Useò Patcè Section).Thå fileó wilì 
bå  printeä witè thå filenamå printeä oî thå printouô aô thå top®  Tabó wilì 
bå expandeä tï ¸ characters®  Pagebreakó arå alsï provideä witè 5¶ lineó peò 
pagå  anä 8° columnó peò line®  Thå retaç commanä caî alsï theî bå  useä  tï 
retaç  thå fileó tï bå printeä agaiî foò thoså oæ yoõ thaô arå intï printinç 
copieó  foò youò friends®  Iæ anù onå oæ thå followinç filå typeó ió  taggeä 
foò print¬ theù wilì insteaä bå HEXPRINT-ed.

                COM  REL  OVR  OVL  DBF  DAT  DTA  HEX  OBJ

     Also, their squeezed counterparts will be HEXPRINT-ed.

                             -----------------

Printing Multiple Copies

     Thió optioî wilì allo÷ printinç uğ tï 9¹ copieó oæ anù giveî file® Wheî 
yoõ havå positioneä thå cursoò besidå thå filå thaô yoõ wisè tï prinô copieó 
of¬  hiô  thå  « key®  Yoõ wilì bå askeä ho÷ manù copieó tï  prinô  anä  thå 
printeò pitcè anä ofæ yoõ go®  Notå thaô thió doeó noô applù tï taggeä fileó 
as with normal printing, but only to the "Current File".
.paŠ


                            * * * * * * * * * *

                          U S E R    P A T C H E S

                            * * * * * * * * * *

     Thå  installatioî  prograí (B29INST.COM© wilì instalì certaiî  featureó 
intï  B29¬  sucè aó printeò stringó anä videï sequences®  Wheî  thå  instalì 
prograí firsô comeó up¬ thå useò ió prompteä foò thå drivå wherå B29.COÍ is¬ 
sï  thaô B29INSÔ knowó wherå tï puô thå ne÷ codes®  Wheî thå drivå ió given¬ 
thå  instalì  prograí lookó oî thaô drivå tï insurå thaô B29.COÍ  ió  indeeä 
there®  Iæ iô ió not¬ thå useò ió adviseä oæ thió anä haó thå opportunitù tï 
retry or abort.
     Wheî  enterinç  codå  sequenceó witè thå instalì  program¬  iô  ió  noô 
necessarù tï looë uğ strangå anä ambiguouó codes¬ sincå mosô manualó providå 
thå codeó iî severaì "dialects¢ anyway¬ thió shoulä bå easy® Foò example¬ iæ 
thå  printeò manuaì sayó thaô thå codå foò 1² cpé (ELITÅ pitch© ió "ESÃ  Q"¬ 
theî  aô thå prompô foò 1² cpi¬  thå useò woulä hiô thå ESCapå keù anä  theî 
thå  Ñ  key®  Alì  oæ thå codeó tï bå installeä allo÷  á  maximuí  oæ  threå 
characters¬  whicè  shoulä bå sufficienô foò anù printer®  Tï NULÌ á string¬ 
uså thå -SPACÅ BAR-® Stringó caî bå NULLeä foò thoså machineó noô havinç anù 
videï  sequences®  THE  CLOCK SHOULD ALSO BE MADE INACTIVE ON ALL   MACHINES 
EXCEPÔ THÅ KAYRPO'Ó WITÈ THÅ REAÌ TIMÅ CLOCË BUILT-IN®  Thå "REMEMBEÒ CURSOÒ 
POSITION¢  anä "STATUÓ LINÅ PRESERVATION¢ functionó shoulä bå NULLeä ouô foò 
non-Kayprï Reaì timå Clocë machineó aó well®  Theså twï codeó arå onlù  useä 
oî  thå Kayprï anä caî servå nï purposå oî anù otheò machines®  Thå  "CUSTOÍ 
CURSOR¢  shoulä  alsï bå disableä oî non-Kayprï machineó sincå thió  routinå 
calló specifiã ports¬  iô wilì causå B2¹ tï bomâ oî otheò machines.Thå lineó 
peò  pagå  anä lineó peò screeî codeó caî bå entereä  iî  decimal¬  however¬ 
B29INSÔ wilì noô allo÷ morå thaî 6¶ lineó peò page® Thå defaulô valueó showî 
iî thå installatioî prograí arå takeî froí thå actuaì COÍ file¬  thaô ió yoõ 
arå showî whaô thå currenô valueó arå beforå yoõ changå them.
     Tï  makå thå changeó permanent¬  selecô thå "X¢ optioî anä yoõ wilì  bå 
prompted for Saving the changes or Aborting the session.


NOTE:
     Geminé  10ø  anä  Starmicronicó  10ø  owners®  Thå  printeò  manuaì  ió 
misleadinç  aó faò aó thå printeò stringó arå concerned®  Thå booë showó thå 
codeó  foò characteò fontó aó ESÃ "B¢ î anä chr$(27© chr$(66©  chr$(n)®  Thå 
"n¢ wheî useä foò fontó ió NOÔ aî ASCIÉ numbeò ± oò ² oò 3¬  iô ió insteaä á 
HEØ ± oò ² oò 3®  Wheî usinç thå instalì prograí tï instalì theså  printers¬ 
yoõ musô uså ^Á foò 1¬  ^Â foò ² anä ^Ã foò 3®  Exampleº Tï instalì thå PICÁ 
pitch string, you would type, ESC B ^A. 


NOTE:   ( Reiterating )
     Iæ yoõ arå noô usinç B2¹ oî á Kayprï witè thå built-iî clock¬  yoõ MUSÔ 
disablå  thå CLOCK¬  CUSTOÍ CURSOR¬  REMEMBEÒ CURSOÒ POSITION¬  STATUÓ  LINÅ 
PRESERVATIOÎ optionó witè B29INST.COÍ aó theså optionó arå Kayprï specific® 






Š     Ok Hackers, here we go. A little prayer of thanks to DDT and off we go!


     Thå  installatioî  prograí (B29INST.COM)¬  wilì instalì  thå  followinç 
byteó  intï B29¬  however¬  thå tablå belo÷ ió provideä aó á  referencå  foò 
those with other things in mind.

 
- PATCH LOCATION -       - LABEL - - BYTES AVAIL -    -FUNCTION-
 --------------------------------------------------------------------------
Decimal         Hex
 --------------------------------------------------------------------------
  361          0169      IRV OFF->     - 6 -      Inverse Video OFF
  377          0179       IRV 0N->     - 6 -      Inverse Video ON 
  392          0188       STĞ ON-¾     - ³ -      Preservå Statuó Line ON
  404          0194      STP OFF->     - 3 -      Preserve Status Line OFF
  419          01A3           RÃ-¾     - ³ -      Remembeò Currenô Curs® Pos.
  427          01AB          GRC->     - 3 -      Go Last Rem. Curs. Pos.
  436          01B4           LP->     - 1 -      Lines per Page, Printer
  441          01B9           LS->     - 1 -      Lines on Screen
  446          01BE          CLS->     - 3 -      Clear Screen Code
  455          01C7         PICA->     - 3 -      Select 10 cpi
  465          01D1        ELITE->     - 3 -      Select 12 cpi
  476          01DC        COMPR->     - 3 -      Select 17 cpi
  487          01E7        CLOCK->     - 1 -      Clock Enable 00=y  C9=n
  495          01EF       CURSOR-¾     - ± -      Cusô Cursoò Enablå 00=ù C9=n 
 --------------------------------------------------------------------------

     Thå  labeló showî abovå caî bå founä iî thå firsô two sectoòs oæ 
thå  .COÍ  filå  aó  DDT'ó  HEX/ASCIÉ dumğ wilì  sho÷  theí  up®  Thå  byteó 
immediatelù  tï  thå righô oæ thå "->¢ portioî oæ eacè labeì  ió  wherå  thå 
actuaì  codå  resides®  Thå  patcè locationó showî  represenô  the  startinç 
address of  the label®   Afteò patcheó  arå  complete¬  yoõ caî savå thå ne÷ 
imagå witè ...
 

                            A0>SAVÅ 64 B29.COM.



     Therå  ió  á  tablå iî thå COÍ file¬  whicè ió á lisô oæ alì  thå  filå 
extensionó  thaô wilì automaticallù  bå hexdumpeä iæ thå useò trieó tï  VIE× 
them. The list is marked in the file by an ASCII marker;

                               HEX-DUMP TABLE

     The table follows:

                    REL RQL COM CQM OBJ OQJ HEX HQX DTA 
                   DQA OVR OQR OVL OQL DBF DQF DAT DQT FF

     Thå bytå aô thå enä oæ thå tablå (FF© musô remain¬  aó iô ió thå enä oæ 
tablå  delimiteò  foò thå routinå thaô scanó thå  table®  Thå  spaceó  showî 
betweeî  thå  extensionó  iî  thå  abovå tablå arå  showî  herå  merelù  foò 
clarity, as they are run together in the actual table in B29.COM.

     Thå extensionó iî thió tablå caî bå modifieä oò deleted¬  buô therå arå 
á fe÷ precautions®  Iæ iô waó desireä tï removå aî entrù froí thå table¬  iô 
ió  noô possiblå simplù tï deletå it®  Iæ aî entrù waó deleteä anä  replaceä 
witè  spaces¬  theî  anù  filå  thaô diä noô  havå  aî  extensioî  woulä  bå Šhexdumped®  Iô ió necessarù tï havå thå tablå contiguouó witè nï spaceó  anä 
aî  FÆ  bytå  aô thå end®  Tï removå aî entrù froí thå table¬  iô  woulä  bå 
easiesô  tï movå thå lasô entrù tï thå spoô wherå aî entrù ió tï bå  removeä 
anä theî movå thå FÆ bytå tï thå ne÷ enä oæ table®  Alsï notå thaô thå tablå 
ió noô expandable¬ i.e® dï noô movå thå tablå pasô thå FÆ byte!

     É  aí onå whï cannoô leavå welì enougè alonå anä alwayó seeí tï havå tï 
adä somethinç elså tï á program¬  thå abovå informatioî ió  foò thoså oæ yoõ 
whï  arå  oæ thå samå statå oæ mentaì disordeò aó I®  Iæ yoõ arå  intï  somå 
seriouó  patches¬  É woulä bå interesteä iî whaô theù arå aó welì  aó  offeò 
assistancå  iæ  needed®  Thió wholå prograí camå abouô becauså É  wanteä  tï 
patcè  thå  reaì timå clocë iî thå Kayprï 4-8´ intï NSWEEP¬  consequentlù  É 
encouragå useò patchinç anä wilì helğ wheî asked.


                               W_A_R_N_I_N_G 
     Iæ  yoõ patcè intï thå wronç area¬  aó witè anù program¬  B2¹ wilì  noô 
work® Iæ anù oæ thå copyrighô messageó arå removed¬ B2¹ wilì issuå á messagå 
and exit and you will need a fresh copy of B29.


* EOF:B29xxx.WS
