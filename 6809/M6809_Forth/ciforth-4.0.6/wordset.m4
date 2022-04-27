dnl $Id: wordset.m4,v 4.1 2002/10/17 13:44:32 albert Exp $
changequote({,})dnl
define({worddoc},{dnl})dnl ignore those
define({worddocsafe},{dnl})dnl ignore those
define({worddocchapterend},{dnl})dnl ignore those
define({worddocchapter},{
divert(2)
{define({_prev$1},_previous})
{define({_next}{}_previous,$1})
{define({_previous},$1})
divert(4)
{define({wordsetnode_$1},{
@node $1, _next$1(),_prev$1(), Glossary
@section $1})}
})
divert(1)dnl Start of file
{divert(-1)}
{changequote({,})}
{define({_previous},)}
divert(3)dnl Middle of file
{define({_next}{}_previous,)}
divert(5)dnl End of file
{divert(0)} 

