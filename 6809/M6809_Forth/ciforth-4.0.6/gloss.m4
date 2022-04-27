dnl Copyright(2000): Albert van der Horst, HCC FIG Holland by GNU Public License
dnl $Id: gloss.m4,v 4.2 2002/10/29 19:02:15 albert Exp $
dnl NOTE IT DOESN'T WORK WITHOUT THE NEW LINE FOR THE RECURSIVE CALL
dnl TO FORALL. THIS IS RATHER MYSTERIOUS.
changequote({,})dnl
define({forall}, {ifelse(len({$2}),0,,
{$1}({{{{{{$2}}}}}})
 {forall({$1},{$3},{$4},{$5},{$6},{$7},{$8},{$9},{$10})}
)})dnl
dnl Define a word definition on channel 9
dnl   the corresponding menu item on channel 6
dnl   and the content including a definition for the second pass on channel 1
define({quote},{{{$1}}})
define({worddoccommon},{
divert(9)dnl
@node $8, _next$3(), _prev(), MyTop()
@subsection {$2}ifelse({$2},{'},{ (This addition because texinfo won't accept a single {quote}) })
@pindex $2
@findex $2

@noindent
Name: @code{{{{{{$2}}}}}}

@noindent
ifelse($4,,
{No stackeffect},
{Stackeffect: $4})

@noindent
Attributes: $5

@noindent
Description:
$6

ifelse(len({$7}),0,, {@noindent
See also: forall({forthsamp},$7)})dnl
    {define({_prev},{$8})dnl}
    divert(1)dnl
{{{$8}})dnl
define({_next$3},}dnl
    divert(6)dnl
* $2  :ifelse($9,,:,$9)
divert(9)dnl
})dnl
define({worddocchapter},
dnl Another macro call, resolved at yet a higher level
wordsetnode_$1()
    {$2}
    {$3}
    {$4}
{{define({MyTop},{{$1}})dnl}}
dnl Leave the first half of the first definition (unused)
{divert(1)dnl}
    {{
define({{_dummy_}},dnl}}
dnl Initialise menu channel
dnl Normal description comes after the definitions but before the menu's
dnl and contents.
{divert(6)dnl}
{{dnl
define({_prev},{{$1}})dnl}}
{
@menu}
)
define({worddoc},
{worddoccommon({$1},{$2},{$3},{$4},{$5},{$6},{$7},{$2},)}
)dnl
define({worddocsafe},
{worddoccommon({$1},{$2},{$3},{$4},{$5},{$6},{$7},{$3},{$3})}
)dnl
define({worddocchapterend},
dnl Complete the last half of the last definition empty
{divert(1)dnl}
    {{)dnl}}
dnl Close menu channel
{divert(6)dnl}
{{@end menu}}
{divert}
{undivert}
)
{define({MyTop},{Glossary})dnl}
