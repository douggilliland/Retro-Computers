COPYRIGHT (c) 2000-2004 Albert van der Horst, THE NETHERLANDS
                   LICENSE
This program is free software; you can redistribute it and/or
modify it under the terms of version 2 of the GNU General
Public License as published by the Free Software Foundation.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public
License along with this program; if not, write to the
            Free Software Foundation, Inc.,
   59 Temple Place, Suite 330, Boston, MA 02111, USA.

( -a :_Make_require_available_silently ) \ AvdH A2jan20
( PRESENT? REQUIRE REQUIRED ) \ AvdH A1oct04
\ This screen must be at a fixed location. To find REQUIRED.
\ For LINE and WORD sc's : line CONTAINS word.
CREATE pad 80 ALLOT    : CONTAINS   0 pad !   BL pad $C+
pad $+!   BL pad $C+   pad @ - OVER + SWAP
    DO   I pad $@ CORA   0= IF -1 UNLOOP EXIT THEN   LOOP   0 ;
\ Find WORD in the block library and load it.
: FIND&LOAD     256 ERRSCR @ 4 +
DO 0 I (LINE) 2OVER CONTAINS IF I LOAD LEAVE THEN LOOP
2DROP ;
: PRESENT? PRESENT 0= 0= ;  \ For WORD sc: it IS found as such
\ Make sure WORD is present in the ``FORTH'' vocabulary.
: REQUIRED 2DUP PRESENT 0= IF 2DUP FIND&LOAD THEN
    2DUP PRESENT 0= IF ETYPE 24 MESSAGE _ _ THEN 2DROP ;
: REQUIRE (WORD) REQUIRED ;    : CF: "CONFIG" REQUIRED ;
( -b :_This_option_is_available )

  .S












\
( -c PROGRAM :_compile_PROGRAM_to_binary ) \ AvdH A1oct02
1 LOAD   REQUIRE OLD:   REQUIRE TURNKEY   REQUIRE SWAP-DP
REQUIRE ARG[]   REQUIRE INCLUDE   REQUIRE SRC>EXEC
: MY-ERROR  DUP EXIT-CODE ! OLD: ERROR BYE ;
\ Be economic with disk space
: INCD'   SWAP-DP GET-FILE SWAP-DP EVALUATE ;

: MY-OPTIONS DROP 0 ;  \ No options, no sign on.
'MY-ERROR DUP 'ERROR 3 CELLS CMOVE  HIDDEN
'INCD' DUP 'INCLUDED 3 CELLS MOVE   HIDDEN

'MY-OPTIONS DUP 'OPTIONS 3 CELLS MOVE  HIDDEN
ARGC 3 < 13 ?ERROR  0 HANDLER ! ( We are being caught!)
2 ARG[] INCLUDED
LATEST   2 ARG[] SRC>EXEC   TURNKEY

( -d :_This_option_is_available )














\
( -e :_Load_system_electives ) \ AvdH A3sep01
DROP .SIGNON CR 0 LIST  1 LOAD    : REQ REQUIRE ;

REQ CONFIG      REQ HELP        REQ ORDER
REQ L-S         REQ DO-DEBUG    REQ H.          REQ DUMP
REQ SUPER-QUAD  REQ FARDUMP     REQ $.          REQ ^
REQ INCLUDE     REQ CRACK       REQ LOCATE      REQ OS-IMPORT
REQ CASE-INSENSITIVE          ( CASE-INSENSITIVE )
\ REQ EDITOR      REQ OOPS
\ REQ ASSEMBLERi86 REQ DEADBEEF

( REQ DIR )     REQ ls    \ Select os-interface DOS/Unix

: TASK ;
 ( BACKUP        250 LOAD   77 81 THRU )
0 ( No signon) OK
( -f :_Forth_words_to_be_executed_80_chars) \ AvdH A1oct05
DROP 1 LOAD
REQUIRE ARG[]   REQUIRE Z$@
CREATE COMMAND-BUFFER 0 , 1000 ALLOT
: DOIT
    BEGIN SHIFT-ARGS ARGC 1 > WHILE
    1 ARG[] COMMAND-BUFFER $+!   BL COMMAND-BUFFER $C+
    REPEAT ;
DOIT    COMMAND-BUFFER $@
\ 'DOIT HIDDEN   COMMAND-BUFFER HIDDEN
2DUP TYPE EVALUATE    0 ( No signon)




\
( -g GROW :_grow_by_megabytes ) \ AvdH A4oct26
'FORTH >WID >LFA @    HERE CONSTANT HERE-NOW
1 LOAD      REQUIRE ARG[]  CF: ?LI
ARGC 4 <> 13 ?ERROR    REQUIRE SAVE-SYSTEM
SM HERE-NOW OVER - $, CONSTANT thisforth$
 2 ARG[] EVALUATE 20 LSHIFT CONSTANT INCREASE
 thisforth$ CELL+ SM - CONSTANT >TARGET
: PATCH   >TARGET + INCREASE SWAP +! ;
: PATCH-CONSTANT   >DFA PATCH ;
: PATCH-ALL   5 0 DO I CELLS +ORIGIN PATCH LOOP
  STALEST PATCH   PREV PATCH   SIZE^ PATCH
  'EM PATCH-CONSTANT   'FIRST PATCH-CONSTANT
  'LIMIT PATCH-CONSTANT  ;
: GROW   'FORTH >WID >LFA >TARGET + ! PATCH-ALL
thisforth$ $@ 3 ARG[]   PUT-FILE ;
GROW BYE
( -h :_help,_show_options ) \ AvdH A1oct04
DROP .SIGNON   1 20 INDEX CR
.( See also the pdf documentation ) CR
.( or print the PostScript documentation ) CR

OK BYE









\
( -i BINARY_PATH LIBRARY_PATH SHELL_PATH )\ A3aug30
CREATE task     1 LOAD
   REQUIRE ARG[]   REQUIRE SAVE-SYSTEM
: INSTALL-LIB BLOCK-FILE $@ GET-FILE   3 ARG[] PUT-FILE
    3 ARG[] BLOCK-FILE $! ;
\ Trim back to before ``task''. Save system at binary path.
\ Must be done all at once, because of forgetting.
: INSTALL-BIN 'task    DUP 'FORTH FORGET-VOC   >NFA @ DP !
    2 ARG[] SAVE-SYSTEM  BYE ;
\ Specify shell name.
: INSTALL-SHELL 4 ARG[] SHELL $! ;
: DOIT   ARGC 4 6 WITHIN 0=
    IF ." -i requires 2 or 3 arguments" CR BYE THEN
    ARGC 5 = IF INSTALL-SHELL THEN   INSTALL-LIB INSTALL-BIN ;
DOIT
\
( -j :_This_option_is_available )














\
( -k :_This_option_is_available )














\
( -l LIBRARY :_LIBRARY_to_be_used_for_blocks ) \ AvdH A1oct05
CREATE task
1 LOAD   REQUIRE SHIFT-ARGS   REQUIRE ARG[]
\ Install other library
: SWITCH-LIBS   BLOCK-EXIT
    2 ARG[] BLOCK-FILE $!
    2 BLOCK-INIT
    SHIFT-ARGS   SHIFT-ARGS
    'task 'FORTH FORGET-VOC COLD ;

\ Must all be done in one go!
SWITCH-LIBS



\
( -m/--/--help/--version :_Help_and_version_information )
1 31 INDEX   OK         \ Help
22 LOAD












\
( -n :_This_option_is_available )














\
( -o :_This_option_is_available )














\
( -p :_Load_system_preferences ) \ AvdH A1oct02
5 LOAD














( -q :_This_option_is_available )














\
( -r :_Make_require_available ) \ AvdH A1oct04
.SIGNON   1 LOAD   OK













\
( -s SCRIPT-FILE :_Interpret_SCRIPT-FILE ) \ AvdH A1oct02
DROP  1 LOAD   REQUIRE OLD:   REQUIRE ARG[]
REQUIRE CTYPE   2 ARG[] $, CONSTANT SCRIPT-NAME
: BY-WHO   "LINOS" PRESENT? IF " run by " TYPE
INTERPRETER $@ TYPE THEN ;
\ This error handler may be overwritten by the script.
: MY-ERROR    DECIMAL
    "In file " TYPE SCRIPT-NAME $@ TYPE BY-WHO CR
    IN @ 20 - 40 TYPE CR
    "Fatal error at : " TYPE   OLD: ERROR CR CR    ;
-1 WARNING !     'MY-ERROR >DFA @     'ERROR >DFA !
SHIFT-ARGS  SHIFT-ARGS
SCRIPT-NAME $@ GET-FILE
^J $S 2DROP     \ Line with #!lina
EVALUATE
BYE
( -t FILE :_Try_to_compile_FILE_by_all_means ) \ AvdH A1oct26
.SIGNON 1 LOAD
\ Reload REQUIRE with new ``CORA'' but hide it direct after.
REQUIRE CORA-IGNORE
: CORA CORA-IGNORE ;   1 LOAD   'CORA HIDDEN

REQUIRE [IF]   REQUIRE ARG[]   REQUIRE PREFIX

REQUIRE CASE-INSENSITIVE    CASE-INSENSITIVE
REQUIRE AUTOLOAD            AUTOLOAD

2 ARG[] INCLUDED
SECOND-PASS @ 0= ?LEAVE-BLOCK
2 ARG[] INCLUDED

\
( -u :_This_option_is_available )














\
( -v :_Version_and_copyright_information_)
"CPU  NAME  VERSION" TYPE .SIGNON CR
"LIBRARY FILE: " TYPE
"$RCSfile: options.frt,v $ $Revision: 4.6.2.11 $" TYPE CR
CR
0 LIST
BYE








\
( -w :_This_option_is_available )














\
( -x :_This_option_is_available )














\
( -y :_This_option_is_available )














\
( -z :_This_option_is_available )














\
(    :_This_option_is_available )














\
(    :_This_option_is_available )














\
(    :_This_option_is_available )














\
( -  :_This_option_is_available )














\
( -? :_This_option_is_available )

8 LOAD












\
