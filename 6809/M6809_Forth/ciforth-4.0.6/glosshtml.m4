dnl Copyright(2000): Albert van der Horst, HCC FIG Holland by GNU Public License
dnl $Id: glosshtml.m4,v 4.1.2.1 2004/02/11 17:55:26 albert Exp $
divert(-1)
define({forall}, {ifelse(len({$2}),0,,
{$1}({{{$2}}}) &nbsp;
 {forall({$1},{$3},{$4},{$5},{$6},{$7},{$8},{$9},{$10})}
)})dnl
dnl Define a word definition on channel 9
dnl        the corresponding menu item on channel 6
dnl        and a definition for the second pass on channel 0
define({forthvar}, <I>$1</I>)
define({forthdefi}, <I>$1</I>)
define({forthdefin}, <I>$1</I>)
define({forthsamp}, <B>$1</B>)
define({forthemph}, <B>$1</B>)
define({forthkey}, <B>$1</B>)
define({forthfile}, ``$1'')
define({forthexample},<P><B>$1</B><P>)
define({forthcode}, <A HREF="#$1">$1</A>)
define({forthxref}, <A HREF="#$1">See also $1</A>)
define({forthpxref}, <A HREF="#$1">See also $1</A>)
dnl ----------------------- worddoc ------------------------------------
define({worddoc},{
divert(9)dnl
<P>
<HR><A NAME="$2"></A>
<H2>
$2</H2>
<P>

STACKEFFECT: $4
<P>

DESCRIPTION:
<P>
$6
<P>
<A HREF="#GLOSSARY_INDEX">GLOSSARY INDEX</A>
<P>
SEE ALSO: forthcode($1) &nbsp; forall({forthcode},$7)
divert(6)dnl
<LI>
<A HREF="#$2">$2</A></LI>
divert(9)dnl
})dnl
dnl ----------------------- worddocchapter -----------------------------
define({worddocchapter},{
divert(9)dnl
<P>
<HR><A NAME="$1"></A>
<H1>
$1</H1>
<P>

OVERVIEW:
<P>
$3
ifelse(len({$7}),0,,{
<P>

SEE ALSO: forall({forthcode},$7)})
divert(6)dnl
<P>
<A NAME="$1INDEX"></A>
<H4>WORDSET $1</H4>
<LI>
<A HREF="#$1">OVERVIEW OF $1</A></LI>
divert(9)dnl
})dnl
dnl ----------------------- worddocchapterend  -----------------------------
define({worddocchapterend},{dnl})dnl
dnl ----------------------- get rid of test doc markers ------------------
divert(-1)undivert(2,4)
divert(0)dnl
dnl Normal description comes after the definitions but before the menu's
dnl and contents.
