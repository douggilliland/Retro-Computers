%File:  CLES4.ALG  (c)         10/30/79
         The Soft Warehouse %


LINELENGTH (39)$  NEWLINE: 1$  ECHO: TRUE$

%   This is the fourth of a sequence of
muMATH calculator-mode lessons.

    There   are  some  other  algebraic
control   variables  besides   PWREXPD,
NUMNUM,  DENDEN,  and DENNUM;  and they
are occasionally crucial for  achieving
a desired effect.   One of these, named
NUMDEN, provides the logical completion
of the latter three, by controlling the
distribution  of factors in  numerators
over  the  terms of  denominator  sums.
NUMDEN  is  initially  0,  but  integer
numerators    are   distributed    over
denominator   sums  when  NUMDEN  is  a
positive   integer   multiple   of   2,
monomial  numerators  are   distributed
over  denominator sums when NUMDEN is a
positive  integer multiple  of  3,  and
numerator  sums  are  distributed  over
denominator   sums  when  NUMDEN  is  a
positive  integer multiple of  5.   For
example:  %

NUMNUM: DENDEN: DENNUM: 0 $  NUMDEN: 30 $
X / (X^3 + X + 1) / (Y + 1) ;  EG: (X+Y) / (1+X+Y) / (Y+1) ;
%   Isn't that intriguing?  It yields a
sort      of       "continued-fraction"
representation.   Now  for the  reverse
direction,  which  performs a denesting
of  denominators which is less  drastic
than a single common denominator:  %

NUMDEN: -6 $  Z + 1 / (1/X + 1/Y) / (1+Y) ;
%    See  if you  can  devise  examples
exhibiting   dramatic   simplifications
arising  from either direction for this
novel transformation.  The fact that it
so   naturally   complements    NUMNUM,
DENDEN,  and  DENNUM  suggests that  it
must be useful for something!   %  RDS:
FALSE $
%    Another  control  variable   named
BASEXP  controls distribution of a BASe
over  terms in an EXPonent which  is  a
sum,  or  controls the reverse  process
which is collection of similar factors.
As might be expected, integer bases are
distributed  over  exponent  sums  when
BASEXP  is a positive integer  multiple
of  2,  monomial bases are  distributed
over  exponent  sums when BASEXP  is  a
positive  integer  multiple of  3,  and
base sums are distributed over exponent
sums when BASEXP is a positive  integer
multiple    of   5.     Morever,    the
corresponding  negative  values   cause
collection  of  similar factors  having
the   corresponding  types  of   bases.
BASEXP  is  initially  -30.    However,
distribution   (followed   perhaps   by
collection)  is sometimes necessary  to
let  some of the terms in  an  exponent
sum   combine  with  the   base.    For
example:  %

EG: 2^(2+X) / 4 ;  BASEXP: 2 ;  EVAL (EG) ;
%    See  if you can devise an  example
which requires evaluating an expression
first   with   sufficiently    positive
BASEXP,    then    reevaluating    with
sufficiently negative BASEXP,  or vice-
versa:  %  RDS: FALSE $
%     Another  control  variable  named
EXPBAS  controls  the  distribution  of
EXPonents   over   BASes   which    are
PRODUCTS.     Integer   exponents   are
distributed  over  base  products  when
EXPBAS  is a positive integer  multiple
of    2,    monomial   exponents    are
distributed  over  base  products  when
EXPBAS  is a positive integer  multiple
of 3, and exponent sums are distributed
over  base  products when EXPBAS  is  a
positive   integer   multiple   of   5.
Naturally,  the  corresponding negative
multiples  request collection of  bases
which  have  similar exponents  of  the
indicated type.   The initial value  is
30,  and  here are some examples  where
distribution         permits        net
simplification:  %

(X^(1/2) * Y) ^ 2 ;  (X*Y)^2 - X^2*Y^2 ;  (4*X^2*Y) ^ (1/2) ;
%    However,  the user  should  beware
that   as   with  manual   computation,
distribution of noninteger exponents is
not   always    valid.    Consequently,
conservative   users   may  prefer   to
generally operate with EXPBAS being  2.
Moreover,   distribution  of  exponents
tends  to  make expressions more  bulky
when  no  cancellations   occur.    For
example %

(X * Y * Z) ^ (1/2) ;
%   In fact,  there are instances where
negative   settings   of   EXPBAS   are
necessary  to acheive a desired result.
For example:  %

EG: 2^X * 3^X  + (1+X)^(1/2) * (1-X)^(1/2) - (1-X^2)^(1/2) ;
EXPBAS: -6 ;  NUMNUM: 30 ;  EVAL (EG) ;
%    See if you can devise  an  example
which requires evaluating an expression
first    with   sufficiently   positive
EXPBAS,    then    reevaluating    with
sufficiently negative EXPBAS,  or vice-
versa, in order to simplify acceptably:
%  RDS: FALSE $
%   The variable named  PBRCH,  already
discussed     in    conjunction    with
fractional  powers  of  numbers,   also
controls  transformations of  the  form
u^v^w --> u^(v*w).   PBRCH is initially
TRUE,  but  when  PBRCH is  FALSE,  the
transformation occurs only for  integer
w.  Otherwise the transformation occurs
for  any w.   The user should be  aware
that in some circumstances the selected
branch is an inappropriate one, so that
it  may  sometimes be necessary to  set
PBRCH to FALSE.   See if you can devise
such an instance:  %  RDS: FALSE $
%  Now,  try the examples  0^X and X^0,
to see what happens:  %
RDS: FALSE $
%     The  reason  that  0^X   is   not
automatically  simplified to 0 is  that
0^X is undefined for nonpositive values
of X,  so the transformation could lead
to   invalid   results.    Of   course,
sometimes  users know that the exponent
is  positive,  or they are  willing  to
assume  it  is positive and verify  the
result afterwards.  Consequently, there
is  a control variable  named  ZEROBAS,
initially  FALSE,   which  permits  the
transformation when nonFALSE.

    Why   then   do  we   automatically
simplify  X^0 to 1 even though X  could
perhaps take on the value 0, giving the
undefined form 0^0?  Well, we also have
a  control  variable  for  that,  named
ZEROEXP of course,  but we  initialized
it to TRUE because:

     1.    If   we   are  thinking   of
polynomials  in X rather than  any  one
specific  value of X,  then we are free
to  regard the polynomial X^0 as  being
formally equivalent to 1.

     2.    One   cannot  do   effective
simplification  of  rational  functions
without     this    widely     accepted
transformation.

     3.  Since 1 is the limit of X^0 as
X  approaches 0 from either side of the
real   axis,    1   is   a   reasonable
interpretation even for 0^0.

     Nevertheless,  there  is room  for
disagreement,  and anyone who wishes is
free  to run with ZEROEXP  FALSE.   Why
don't you try it,  using some  rational
expression  examples,  in order to  see
how you feel about this issue?  %  RDS:
FALSE $
%    It  is easy to forget the  current
control-variable  settings,  and it  is
even  easy to forget the  existence  of
certain  control-variables,  so we have
provided  a handy-dandy function  named
FLAGS  which returns the empty name  ""
after  printing  a display of  all  the
flags and their values:  %

FLAGS ();
%   If you ever get frustrated  because
you  can't  get an answer close to  the
desired form, try this command.  It may
reveal  some inappropriate settings  or
remind  you  of some  alternatives  you
forgot,  or  reveal  the  existence  of
potentially relevant flags of which you
were unaware.

    Often  a  dialogue  proceeds   best
under  some control settings which  are
suitable   for  the  majority  of   the
computations,  with  an occasional need
for   an  evaluation  under   different
control settings.   Each such exception
could   involve  new   assignments   to
several control variables,  followed by
an   evaluation  then  assignments   to
restore  the  variables to their  usual
values.    This   process  can   become
tedious,   and  baffling  effects   can
result from inadvertently forgetting to
restore a control variable to its usual
value.  Consequently, as a convenience,
we  have provided some functions which,
for  the most commonly desired sets  of
"drastic" control  values,  establishes
these values, reevaluates its argument,
then  allows  the control variables  to
revert  to their former  values  before
returning the reevaluated argument.

    One  of  these functions is  called
EXPAND,   because   it  requests   full
expansion   with   fully    distributed
denominators,   bases,  and  exponents.
More   specifically,    it   uses   the
following settings:

        PWREXPD: 6;  NUMDEN: 0;
NUMNUM:DENDEN:DENNUM:BASEXP:EXPBAS: 30;

   To   see  its  effect,   try  EXPAND
(((1+X)/(1-X))^2);  %  RDS: FALSE $
%    Another one of  these  convenience
functions is called EXPD,  and it fully
expands   over  a  common  denominator.
Thus the internal control settings  are
the  same  as for EXPAND,  except  that
DENNUM: -30.  Try
          EXPD (1/(X+1) + (X+1)^2);  %
RDS: FALSE $
%    Finally,  there is  a  convenience
function  named  FCTR,   and  it  semi-
factors over a common denominator.   It
evaluates   its   argument  under   the
following control-variable settings:

          NUMNUM: DENDEN: -6;
     DENNUM: BASEXP: EXPBAS: -30;
          PWREXPD: NUMDEN: 0;

    Since   semi-factoring   is    done
termwise,  it  may be necessary to  use
EXPD   before   applying  FCTR  to   an
expression, in order to get the desired
result.   See  if  you  can  devise  an
instance where this is true:  %
RDS: FALSE $
%   This brings us to the end of lesson
CLES4.ALG.     The   next   lesson   is
CLES5.ALG,   but  as  before,   it   is
advisable  to  start a fresh muMATH  to
avoid    conflicts    with     bindings
established in the current lesson.  %

ECHO: FALSE$  NEWLINE: 0$  RDS ()$
