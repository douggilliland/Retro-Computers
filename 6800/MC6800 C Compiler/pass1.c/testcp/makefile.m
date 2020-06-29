boolean.h::&.r;kill &.r +q
condit
cprep
define
errorhan
imt
interface
lineman
m-tables
misccom
options
%
class.h::&.r;kill &.r +q
define
interface
subs
%
cp.h::&.r;kill &.r +q
cp-exp
cp-lex
cp-main
%
errnum.h::&.r;kill &.r +q
condit
cprep
define
errorhan
interface
lineman
misccom
options
subs
%
il.h::&.r;kill &.r +q
cp-exp
cp-lex
cp-main
%
miscdefs.h::&.r;kill &.r +q
condit
cprep
define
errorhan
imt
interface
misccom
subs
%
nxtchr.h::&.r;kill &.r +q
cprep
interface
%
tbdef.h::&.r;kill &.r +q
interface
lineman
m-tables
%
tbdef.h::&.h;touch &.h
tables
%
tables.h::&.r;kill &.r +q
condit
cprep
define
imt
lineman
misccom
options
subs
%
&.c::&.r;tscc &.c +r +vbq
cp-exp
cp-lex
cp-main
cprep
condit
define
errorhan
imt
interface
lineman
m-tables
misccom
move
options
printer
subs
%
&.r::loadcontrol;touch loadcontrol
cp-exp
cp-lex
cp-main
cprep
condit
define
errorhan
imt
interface
lineman
m-tables
misccom
move
options
printer
subs
%
&::cprep;!tscc
 cprep.r
 condit.r
 cp-exp.r
 cp-lex.r
 cp-main.r
 define.r
 errorhan.r
 imt.r
 interface.r
 lineman.r
 m-tables.r
 misccom.r
 move.r
 options.r
 printer.r
 subs.r
 +l=/lib/loclib
 +x=ms
 +o=cprep !
loadcontrol
