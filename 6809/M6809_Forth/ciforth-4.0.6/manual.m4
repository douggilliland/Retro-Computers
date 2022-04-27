dnl Copyright(2000): Albert van der Horst, HCC FIG Holland by GNU Public License
dnl $Id: manual.m4,v 4.1 2002/10/17 13:44:08 albert Exp $
divert(-1)
dnl The result must be @var{xxx} , the amount of braces around varies.
dnl This was a misinterpretation, forth variables are not meta
dnl variables, they are samples. Plus that stack diagrams are "samples"
dnl A pity, you must have left forth variables as forthvar.
dnl In that way you could have undone the above wrong opinion
dnl This is wrong, but we can live with it for the moment.
define({forthvar},{{@samp{$1}}})
dnl define({forthvar},{{@var{$1}}})
define({forthfile},{@file{{$1}}})
define({forthkey},{@kbd{{$1}}})
define({forthsamp},{@samp{{$1}}})
define({forthmacro},{@samp{{$1}}})
define({forthprog},{@code{{$1}}})
define({forthcodeni},{@code{{$1}}})
define({forthbreak},{@*})
define({forthurl},{@samp{{$1}}})
define({forthemph},{@b{{$1}}})
dnl There is a problem. Using this and the following
dnl macro at the end of line, leads to a break.
dnl Using ` dnl' after the macro call solves this.
define({forthcode},{@code{{$1}}
@findex $1
})
define({forthdefi},{@dfn{{$1}}
@cindex $1
})
define({forthdefin},{@dfn{{$1}}})
define({forthunderline},{$1})
define({forthxref},{@xref{{$1}},})
define({forthpxref},{@pxref{{$1}}})
define({forthitemize},{{@itemize @bullet}})
define({forthenditemize},{{@end itemize}})
define({forthenumerate},{{@enumerate}})
define({forthendenumerate},{{@end enumerate}})
define({forthquotation},{{@quotation}})
define({forthendquotation},{{@end quotation}})
define({forthitem},{{@item}})
define({forthbullet},{{@bullet}})
define({note},{$2})
dnl define({a},{{@a}}) define({enda},{{@end a}})
dnl be careful, an example always occupies whole lines.
define({forthexample},
{@example
@iftex
@cartouche
$1
@end cartouche
@end iftex
@ifinfo
$1
@end ifinfo
@end example})dnl
divert(0)dnl
