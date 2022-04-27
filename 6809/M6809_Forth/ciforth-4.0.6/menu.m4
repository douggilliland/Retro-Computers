dnl $Id: menu.m4,v 4.1 2002/10/17 13:44:09 albert Exp $
changequote({,})dnl
define({worddoc},{dnl})dnl ignore those
define({worddocsafe},{dnl})dnl ignore those
define({worddocchapterend},{dnl})dnl ignore those
define({worddocchapter},{* $1 ::})dnl
@menu
divert(2)dnl
@end menu
divert(1)dnl So the actual menu appears between the @menu commands
