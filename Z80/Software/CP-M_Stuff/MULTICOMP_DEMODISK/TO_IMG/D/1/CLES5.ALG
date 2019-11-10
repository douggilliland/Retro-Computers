%File:  CLES5.ALG  (c)         10/30/79
         The Soft Warehouse %


LINELENGTH (39)$  NEWLINE: 1$  ECHO: TRUE$

%    It  is  often desired  to  extract
parts of an  expression.   Particularly
frequent  is  a  need  to  extract  the
numerator    or   denominator   of   an
expression.    Accordingly,  there  are
built-in  SELECTOR functions named  NUM
and DEN for this purpose:  %

DENNUM: 0 $  EG: (1+X) / X ;  NUM (EG) ;  DEN (EG) ;
NUM (1 + EG);  DEN (1 + EG);
%     As   the   last   two    examples
illustrate,  NUM and DEN do not force a
common   denominator   or   any   other
transformation before selection, so the
denominator   is  always  1  when   the
expression   is  a  sum  or  when   the
expression   is  a  product  having  no
negative powers.   Try out NUM and  DEN
on  a few examples of your own to  gain
some experience:  % RDS: FALSE $
%    The Programming-mode lessons  will
explain  how to completely dismantle an
expression to get at any desired  part,
such  as a specific term,  coefficient,
base, or exponent.

    muMATH  represents  the   imaginary
number  (-1)^(1/2)  as #I,  and  muMATH
does   appropriate  simplification   of
integer powers of #I.  For example: %

#I ^ 7 ;  EXPAND ((3 + #I) * (1 + 2*#I)) ;  EXPAND ((X + #I*Y) ^ 3) ;
%   Try it, you'll like it!  %
RDS: FALSE $
%    The definition of the operator "^"
in file ALGEBRA.ARI also implements two
higher-level  transformations which  we
mention here only in passing:

    muMATH  represents the base of  the
natural logarithms as #E and the  ratio
of the circumference to the diameter of
a  circle as #PI.  Using these,  muMATH
performs the simplification

  #E ^ (n * #I * #PI / 2)  -->  #I^n,

where n is any integer constant,  after
which  the  power  of  #I  is   reduced
appropriately.    Also,  if  a  control
variable  called TRGEXPD is a  negative
multiple    of    7,    then    complex
exponentials     are    converted    to
trigonometric    equivalents.      (The
opposite  transformation for sines  and
cosines  to  complex  exponentials  for
TRGEXPD  = 7,  is implemented  by  file
TRGPOS.ALG.)    If  your   mathematical
background  includes these  facts,  you
might  wish  to experience  them  here.
Otherwise  you  can safely ignore  this
digression:  %  RDS: FALSE $
%    You may have wondered  whether  or
not an assignment to a variable, say X,
automatically  updates  the value of  a
bound  variable,   say  EG,  which  was
previously   assigned   an   expression
containing X.  Let's see:  %

X: 5 $  Y: 'Y $  EG: X + Y ;  X: 3 ;  EG;  EVAL (EG) ;
%   Apparently the answer is  "no",  at
least if X is bound when the assignment
to  EG  is made.   This should  not  be
surprising,  because after contributing
its value to the expression  X + Y, all
traces  of  the name X are absent  from
this expression.  However, suppose that
we  do a similar calculation wherein  X
is initially unbound:  %

X: 'X $  EG: X + Y;  X: 3;  EG;
%     As   when   we   change   control
variables,     previously     evaluated
expressions   are   not   automatically
reevaluated  when  we bind  an  unbound
varible  therein.    However,   we  can
always   use  EVAL  to  force  such   a
reevaluation:  %

EVAL (EG) ;
%   Since we did not assign the  result
to  EG,  reevaluation  of  EG  after  a
different  assignment to X still has an
effect:  %

X: 7 $  EG: EVAL (EG);
%    Since this time we did assign  the
result to EG,  further changes to X can
have  no  effect on  EG  regardless  of
evaluation:  %

X: 9 $  EG: EVAL (EG) ;
%    If these examples are not entirely
clear,  you had better take the time to
experimentally learn the principles  by
trying  some  examples of your  own:  %
RDS: FALSE $
%    It is often desired to  reevaluate
an expression under the influence of  a
temporary  local  assignment to one  of
the    variables    therein     without
disturbing either the existing value of
the   variable  or  else  its   unbound
status.   The  built-in EVSUB  function
provides   a   convenient   method   of
accomplishing   this   effect.    EVSUB
returns a reevaluated copy of its first
argument, wherein every instance of its
second  argument  is  replaced  by  its
third argument.  For example:  %

NUMNUM: 6 $  M: 'M $  C: 'C $  V: 'V $  EG: M*C^2 + M*V^2/2 $
EVSUB (EG, M, 5);  EVSUB (EG, M, M1+M2);  M;
%    Play around with EVSUB for  awhile
until  you are absolutely sure that you
understand   the   difference   between
substitution and assignment:   %   RDS:
FALSE $
%    You may have discovered that EVSUB
also permits substitution for arbitrary
subexpressions as its second  argument.
For example:  %

M: 'M $  C: 'C $  E: 'E $  EVSUB (M*C^2 + 7, M*C^2, E);
%    To keep the algebra package small,
we  have  not endowed  EVSUB  with  any
sophistication       about      finding
algebraically IMPLICIT instances of its
second argument in its first.   See  if
you  can find examples where EVSUB does
not  do a substitution that  you  would
like it to do: %  RDS: FALSE $
%   Here is an example where a  desired
substitution doesn't fully occur:%

NUMNUM: 6 $  C: 'C $  S: 'S $ EVSUB (1 - 2*S^2 + S^4, S^2, 1-C^2);
%    The  reason  we did  not  get  the
desired  simplification to C^4 is  that
if  the second argument is a power,  it
matches  only  the same  power  in  the
first   argument.    We   can   usually
circumvent  such  problems  by  instead
using    an   equivalent   substitution
wherein  the second argument is a  name
rather than a power.  For example:  %

PWREXPD: 2 $ EVSUB (1 - 2*S^2 + S^4, S, (1-C^2)^(1/2));
%     Here  is  a  somewhat   different
example wherein a desired  substitution
does not occur:  %

EVSUB (2*C*S, C*S, C2);
%   The  reason is that if  the  second
argument is a product,  it matches only
the  same COMPLETE product in the first
argument.   Again, the remedy is to use
an equivalent substitution wherein  the
second   argument  is  a   name.    For
example:  %

EVSUB (2*C*S, C, C2/S);
%   Here is a final example for which a
desired substitution does not occur:  %

EVSUB (C^2+S^2-1+C+S, C^2+S^2, 1);
%    Similarly  to  products,   if  the
second  argument is a sum,  it  matches
only the same COMPLETE sum in the first
argument.     As   before,   we   could
circumvent  the difficulty by making an
equivalent substitution of
        (1-C^2) ^ (1/2) for S,
      or  (1-S^2) ^ (1/2)  for C,
but  that  would leave an  ugly  square
root in the answer.   If our goal is to
delete the subexpression
C^2 + S^2 - 1,   then we can use to our
advantage  the  fact that  powers  must
match  exactly  for a  substitution  to
take place:  %

EVSUB (C^2+S^2-1+C+S, C^2, 1-S^2) ;
%    See  now  if  you  can  use   such
techniques  to  get  your  examples  to
work:  %  RDS: FALSE $
%    This  brings us to the end of  the
calculator-mode lessons.  There are, of
course,  higher-level math packages  in
muMATH,  but  the  fact is that from  a
usage  standpoint,   we  have   already
covered  the  hardest  part,  which  is
understanding evaluation, substitution,
and  the  ramifications of the  various
algebraic control variables.   You will
find  that  if you  know  the  relevant
math,  use of the higher-level packages
is   quite   straightforward,    easily
learned from studying the corresponding
DOC files.

    We  suggest that before  commencing
the   Programming-mode   lessons,   you
explore  calculator-mode  usage of  the
higher-level  packages as far  as  your
math    background    permits.     Math
curriculum   sequences   differ,    but
probably   most  users  will  be   most
comfortable   trying  the  higher-level
packaes in the approximate order   EQN,
SOLVE,   ARRAY,  MATRIX,  LOG,  TRGNEG,
TRGPOS,  DIF,  INT and INTMORE.   Since
space  becomes  increasingly scarce  as
higher-level packages are  loaded,  you
may  have to reread file READ1ST.TXT to
learn  how to CONDENSE and SAVE if  you
haven't already.

    Now  for some parting advice  about
getting   the  most  out  of   computer
symbolic math:

     First,     storage    and     time
consumption  tends to grow dramatically
with  the  number of variables  in  the
input expressions, even if the ultimate
result  is  fortuitously  compact.  For
example,  the  number of terms  in  the
expanded form of

       (X1 + X2 + ... + XM) ^ N

grows   outrageously  with  M  and   N.
Consequently,  it  is important to make
every   effort  to   avoid   needlessly
introducing    extra   variables    for
generality's  sake.   Mathematical  and
physical   problems  are  often  stated
using more variables than are  strictly
necessary,  so  it is also important to
exploit every opportunity to reduce the
number  of variables from the  original
problem.    Here   are   some   general
techniques for doing this:

    1.    If   members  of  a  set   of
variables  can  be made to  occur  only
together  as  instances  of  a  certain
subexpression,  consider replacing  the
subexpression  with a single  variable.
For example:

     a)  If K, X, and X0 can be made to
     occur  only  as instances  of  the
     subexpression    K*(X-X0),    then
     consider       replacing      this
     subexpression   with  a   variable
     named perhaps KDX.

     b)     Similarly,     perhaps    a
     combination such as M*C^2 could be
     replaced  with  E,   or  RHO*V^2/L
     could be replaced with RE.

     These  are respectively  instances
     of  absorbing an  offset  together
     with       a       proportionality
     coefficient,       renaming      a
     physically-meaningful
     subexpression,     and    grouping
     quantities    into   dimensionless
     quantities.   Most engineering and
     science   libraries   have   books
     describing   a   more   systematic
     technique    called    DIMENSIONAL
     ANALYSIS,  and  an article in  the
     Journal  of Computational  Physics
     (June 1977) explains how  computer
     algebra can automate the process.

    2.   Even when a variable cannot be
eliminated,     the    complexity    of
expressions   may  be  reduced  if  the
variable  can be made to occur only  as
instances  of  a  subexpression.    For
example:

     a)   If  only  even  powers  of  a
     variable   X    occur,    consider
     replacing   X^2  with  a  variable
     named perhaps XSQ.

     b)  If X only occurs as  instances
     of  2^X,   2^(2*X),   2^(3*X),...,
     consider   replacing  2^X  with  a
     variable  named  perhaps   TWOTOX,
     yielding  mere  integer powers  of
     that variable.

    Some  other  advice  is  to   avoid
fractional  powers and denominators  as
much as possible.   They don't simplify
well,  they consume a lot of space, and
they  tend to be hard to decipher  when
printed  one- dimensionally.   Often  a
change  in  variable  can  eliminate  a
fractional power or a denominator.

    Sometimes,   even  when  a  problem
cannot    be   solved   in   its   full
generality, solving a few special cases
enables one to infer a general solution
which  can perhaps then be verified  by
substitution    or    by     induction.
Alternatively,   perhaps  the  original
problem can be simplified by neglecting
some   lower-order  contributions,   in
order to get an analytic solution which
will  at least convey some  qualitative
information  about the solution to  the
original problem.

    Sometimes only part of a problem or
perhaps   even  none  can   be   solved
symbolically,  and  the  rest  must  be
solved numerically.  If so, the attempt
at an analytic solution at least allows
one  to  proceed  with  an  approximate
numerical    solution    having    more
confidence  that  a concise  analytical
solution has not been overlooked.  %

ECHO: FALSE$  NEWLINE: 0$  RDS ()$
