%File:  CLES3.ALG  (c)        09/15/80
         The Soft Warehouse %

LINELENGTH (39)$  NEWLINE: 1$
NUMNUM: DENNUM: 6$  DENDEN: 2$
NUMDEN: PWREXPD: 0$  PBRCH: TRUE$
X: 'X$  ECHO: TRUE$

%    This  file  is  the  third  of  a
sequence of interactive lessons on how
to use muMATH in the calculator  mode.
This  lesson presumes that the  muMATH
files  through  ALGEBRA.ARI have  been
loaded  and that the user has  studied
the arithmetic lessons  CLES1.ARI  and
CLES2.ARI.

     An  UNBOUND  VARIABLE is  one  to
which  no  value  has  been  assigned.
Mathematicians  call  such   variables
INDETERMINATES.  You  may have already
inadvertently  discovered that if  you
use   an   unbound  variable   in   an
expression, muMATH treats the variable
as  a  legitimate  algebraic  unknown.
Moreover,  muMATH attempts to simplify
expressions  containing  such  unbound
variables by collecting similar  terms
and   similar   factors,   etc.    For
example: %

2*X - X^2/X ;
%      See  if  muMATH   automatically
simplifies the expressions
  0+Y,  Y+0, 0*Y,  Y*0,  1*Y,  Y*1,
  Y^1,  1^Y,  and  2*(X+Y) - 2*X.  %
RDS: FALSE $
%     Sometimes  it  is  desirable  to
change   a  bound  variable  back   to
unbound  status.   This can be done by
using    the    single-quote    prefix
operator,   ',  which  looks  like  an
apostrophe  on  many  terminals.   For
example:  %

EG: X + 5;  EG: 'EG;  EG + 2;
%     Try assigning the  value   M*C^2
to  E, then change  E  back to unbound
status:  %  RDS: FALSE $
%    You may have noticed that some of
the more drastic transformations, such
as   expanding  products  or   integer
powers  of  sums,  are not  automatic.
The  reason  is  that  such  transfor-
mations  are not always  advantageous.
They  may  make  an  expression   much
larger    and   less   comprehensible.
However,  they  may  be  necessary  in
order  to permit  cancellations  which
make  an  expression smaller and  more
comprehensible.

   Accordingly,   there   are  a   few
control variables whose values specify
whether  or not  such  transformations
are  performed.    For  example,   the
variable   controlling  expansion   of
integer   powers  of  sums  is  called
PWREXPD.      This     variable     is
conservatively initialized to zero, so
that  integer powers of sums  are  not
expanded.  For example: %

EG: (X+1)^2 - (X^2-2*X-1) ;
%    Clearly this is an instance where
expansion is desirable.   When PWREXPD
is  a positive integer multiple of  2,
then  positive integer powers of  sums
are expanded, so let's try it:  %

PWREXPD: 2 $  EG;
%    Nothing happened!

     The  reason  is that muMATH  does
not      automatically      reevaluate
previously evaluated expressions  just
because  we  change a  control  value.
Not  only  would this be  rather  time
consuming,  but  the  ability to  form
expressions  from  other   expressions
constructed  under  different  control
settings     provides    a    valuable
flexibility for constructing partially
expanded expressions.

     On  the other hand,  it is  often
desirable  to  reevaluate  expressions
under  the  influence of  new  control
settings,   and   the  built-in   EVAL
function enables this:  %

EVAL (EG) ;
%     Now that PWREXPD is 2,  see  how
(X+Y)^2 - (X-Y)^2 simplifies:  %
RDS: FALSE $
%     In  muMATH,   denominators   are
represented   internally  as  negative
powers, and negative integer powers of
sums  are  expanded if  PWREXPD  is  a
positive  integer multiple of 3.   For
example:  %

PWREXPD: 3 $  1 / (X+1)^2 ;
%     What happens if
         1 / ((X+1)^2 - X)^2
is  evaluated  under the influence  of
PWREXPD   being  3?    For  a   little
surprise, try it.% RDS: FALSE $
%    Even though  (X+1)^2 is WITHIN  a
negative   power,   it  is  itself   a
positive  power,  so how about  trying
again with PWREXPD being 2*3: %
RDS: FALSE $
%     Now,  we would like to suggest a
little experiment for you:   The  size
limitation  on  algebraic  expressions
depends  primarily upon the amount  of
unemployed space available for storing
the  data structure used to  represent
algebraic expressions.   We can always
determine    the   total   amount   of
unemployed space expressed in bytes by
the command: %

RECLAIM ();
%     Numbers and nodes which  are  no
longer a part of any value that we can
retrieve  are  automatically  recycled
intermittently,    but   the   RECLAIM
function    forces    this    "garbage
collection"  process.  The  collection
takes   on  the  order  of  a  second,
depending on memory size and processor
speed;  and  these slight  pauses  are
sometimes noticable in the middle of a
printout or a trivial computation.  On
a  computer  with front panel  lights,
the   collections  are  also   usually
recognizable  by the change  in  light
patterns.

     Naturally,    if   we   load   an
extravagant  number  of  muMATH  files
into a single muMATH dialogue or if we
save  a  number  of  relatively  large
expressions    as   the   values    of
variables,    then   there   will   be
relatively little unemployed space for
our  next computation.   Not only does
this  limit  the  size  of  the   next
expression,  but computation time also
increases    dramatically   as   space
becomes  scarce,   because  relatively
more    time   becomes   devoted    to
increasingly   frequent   collections.
The  moral  of the  story  is:   don't
unnecessarily  load  too  many  muMATH
files  or retain numerous  expressions
as the values of variables.

     Now,   for  the  experiment:   In
order to gain an appreciation for  how
computation  time depends on the  size
of the input expression,  answer,  and
unemployed  storage,  try timing  each
computation in the following sequence,
until  it  appears that your space  or
patience is nearly exhausted:

     EG:(1+X)^2;  RECLAIM();
 EG:EG^2;  RECLAIM();  EG:EG^2; ... %

RDS: FALSE $
%     These  polynomials  are   called
"dense",  because there are no missing
terms  less than the maximum degree in
each  unbound variable.   In  contrast
"sparse"  polynomials  are  missing  a
large percentage of the possible terms
less than the maximum degrees.  If you
are still in an experimental mood, you
may   wish   to  try   the   following
analogous   sequence  which   produces
extremely sparse results:
    RECLAIM();  (A+B)^2;  RECLAIM();
      (A+B+C)^2;  RECLAIM(); ... %

RDS: FALSE $
%    Distribution of sums over sums is
another   transformation   which   can
dramatically increase expression  size
but  is sometimes necessary to  permit
cancellations.    For  example,   this
transformation is clearly desirable in
the expression: %

EG: X^2 - 1 - (X+1)*(X-1) ;
%     When the control variable  named
NUMNUM  is a positive integer multiple
of 2,  then integers in NUMerators are
distributed  over sums in  NUMerators.
Similarly  when  the  variable  is   a
positive  integer multiple of 3,  then
monomials     in    numerators     are
distributed  over sums in  numerators,
whereas   when  the  variable   is   a
positive  integer multiple of 5,  then
sums  in  numerators  are  distributed
over sums in numerators.

     The   reason   for   using    the
successive primes 2, 3, and 5, is that
it   provides  a  convenient  way   to
independently  control the three types
of   distribution  using  one   easily
remembered control variable name.

     The initial value of NUMNUM is 6,
because    numeric    and     monomial
distribution  are  recoverable (as  we
shall    see),     because     neither
distribution   dramatically  increases
expression size, and because a lack of
these  distributions  often   prevents
annoyingly obvious cancellations.  For
instance the expression  2*(X+1) - 2*X
will  not simplify unless NUMNUM is  a
positive multiple of 2.  Similarly X+1
- (X+1)   will  not  simplify  to   0,
since  the  expression is  represented
internally  as X+1 + -1*(X+1),   which
requires the -1 to be distributed over
the sum.

     Thus, to return to our example, %

EG;  NUMNUM: 5 * NUMNUM;  EVAL(EG) ;
%     To witness the great variety  of
possible expansions, we set %

NUMNUM: 0 $  EG:  4 * X^3 * (1+X) * (1-X);
%     Now,  successively EVAL EG  with
NUMNUM being 2,  3,  5, 6, 10, 15, and
30:  %  RDS: FALSE $
%    In interpreting these results, it
is important to recall that  negations
are   represented   internally  as   a
product with the integer coefficient -
1,   so  NUMNUM  must  be  a  positive
multiple of 2 to distribute  negations
over sums.

     If   positive  values  of  NUMNUM
cause expansion in numerators,  how do
we request factoring in numerators?

     Negative  values of NUMNUM  cause
factoring of numerators. Moreover, the
specific    negative   values    cause
factoring  of the type which  reverses
the  corresponding   expansion.    For
example: %

X: 'X $  Y: 'Y $  NUMNUM: -2 $  EG: 10*X^2*Y + 15*X^3;
NUMNUM: 3*NUMNUM;  EVAL(EG);
%     What about negative multiples of
5?    Sorry  folks,  that's  hard  for
computers as well as humans.  However,
we  are  working  on  it  for   future
releases.    Meanwhile,  try  out  our
semifactoring on the example
 3*X*Y^3/7 - 15*X*Y^2/14 + 9*X^4*Y^2/7
%  RDS: FALSE $
%    As you may have guessed, there is
a  flag  named DENDEN  which  controls
expansion and factoring among negative
powers  in a manner entirely analogous
to  NUMNUM.    Use  it  together  with
NUMNUM to expand the denominator  then
semifactor   the  denominator  of  the
expression
     X^2/((X-Y)*(X+Y) + Y^2 + X^2*Y)
%  RDS: FALSE $
%     You  may have  wondered  why  we
chose  the  names NUMNUM  and  DENDEN.
The  reason  is that there is  another
closely related control variable named
DENNUM,     which     controls     the
distribution   of  various  kinds   of
denominator factors over the terms  of
corresponding numerator factors:

     A  positive multiple of 2  causes
integer   denominator  factors  to  be
distributed;  a positive multiple of 3
causes   monomial   factors   to    be
distributed;  and  a positive multiple
of   5  causes  sum  factors   to   be
distributed.  For example:  %

Y: 'Y $  DENNUM: DENDEN: NUMNUM: 0 $  EG: (5+3*X^2) / (15*X*(4+X));
DENNUM: 2 $  EVAL(EG);
DENNUM: 3*DENNUM;  EVAL(EG);
DENNUM: 5*DENNUM;  EVAL(EG);
%     Positive  setting of DENNUM  and
NUMNUM  are  particularly  useful  for
work with truncated series or  partial
fraction expansions.  For example, see
if you can put the expression (6 + 6*X
+   3*X^2   +  X^3)/6  into   a   more
attractive form:  %  RDS: FALSE $
%     What  about negative  values  of
DENNUM?

     A little reflection confirms that
forming  a common denominator reverses
the    effect   of   distributing    a
denominator.   Thus,  expressions  are
put over a common integer  denominator
when  DENNUM  is  a  negative  integer
multiple  of  2,  expressions are  put
over  a  common  monomial  denominator
when  DENNUM  is  a  negative  integer
multiple of 3, and expressions are put
over  a  common sum  denominator  when
DENNUM is a negative integer  multiple
of 5.  For example:  %

X: 'X $  DENNUM: DENDEN: 0 $  EG:  1 + X/3 + (1+X)/X + (1-X)/(1+X);
DENNUM: -2 $  EG: EVAL(EG);
DENNUM: 3*DENNUM;  EG: EVAL(EG);
DENNUM: 5*DENNUM;  EG: EVAL(EG);
%      Try   fully   simplifying   the
expression   X^4/(X^3+X^2) + 1/(X+1) -
1   by   expanding   over   a   common
denominator,  then factoring:  %  RDS:
FALSE $
%     As with NUMNUM and  DENDEN,  the
initial setting of DENNUM is 6,  which
causes  distribution  of  numeric  and
monomial   denominator  factors   over
numerator  sums.   This tends to  give
attractive  results for polynomials or
series      with       rational-number
coefficients,   but   the   relatively
costly   common-denominator  operation
may   be   necessary   for    problems
involving ratios of polynomials.

     You  have now been exposed to the
four most important algebraic  control
variables  in muMATH.   Together  with
EVAL,   the  various  combinations  of
settings   of  these  variables   give
rather  fine control over the form  of
algebraic expressions.   muMATH cannot
read   the  user's  mind,   so  it  is
important  for the user to  thoroughly
master  the use of these variables  in
order to achieve the desired effects.

     Here  are  the  most   frequently
useful  combinations  of settings  for
these three variables:

PWREXPD: 0; NUMNUM: DENDEN: DENNUM: 6;

    These  initial values are  usually
good  for general-purpose  work,  when
the  user wants to view  some  results
before   doing  anything  drastic   or
potentially quite time consuming.

   PWREXPD: 6;  NUMNUM: DENDEN: 30;
             DENNUM: -30;

     These   settings  yield  a  fully
expanded   numerator  over   a   fully
expanded  common  denominator.    This
form  gives  the  maximum  chance  for
combination    of    similar    terms.
Moreover,    a    rational    function
equivalent   to  0  is  guaranteed  to
simplify  to  0.    However,  valuable
factoring    information    may     be
irrecoverably lost.

   PWREXPD: 0;  NUMNUM: DENDEN: -6;
             DENNUM: -30;

     These     settings    yield     a
semifactored  numerator  over a  semi-
factored  common  denominator.    This
form  gives  the  maximum  chance  for
cancellation  of  factors  between   a
numerator  and denominator.   However,
the  factoring is done  incrementally,
term by term,  so it may be  necessary
to   first   expand  over   a   common
denominator  so  that all  cancellable
terms  have an opportunity  to  cancel
before attempting factorization.

      PWREXPD: 2;   NUMNUM: 30;
      DENDEN: -6;  DENNUM: -30;

     These   settings   are   a   good
compromise  between the advantages  of
expansion   and   factoring.     Semi-
factoring  is done in the  denominator
where  it  is usually most  important,
but there is a maximum opportunity for
combination  of similar terms  in  the
numerator.

PWREXPD:6; NUMNUM: DENDEN: DENNUM: 30;

    These settings are good for series
expansions   or   partial   fractions,
because  each  term is fully  expanded
over its own denominator.

    Again,  we can't overemphasize the
importance  of  mastering the  use  of
these  four control  variables.   They
are  your  primary tool  for  imposing
your   will  on   the   simplification
process, and any lack of understanding
of  their  proper use will  ultimately
lead to frustration.  Accordingly, why
don't  you try the above  and  various
other combinations on examples of your
own choosing,  until the usage becomes
second nature:  %
RDS: FALSE $
%      Congratulations  on  completing
CLES3.ALG.   If the mathematical level
was  uncomfortably  high,  proceed  to
lesson PLES1.ARI.   Otherwise  proceed
to CLES4.ALG.   In either event, it is
advisable  to initiate a fresh  muMATH
environment,  because  our experiments
have  altered control values and  made
assignments which could interfere with
those lessons in nefarious ways.  %

ECHO: FALSE$  NEWLINE: 0$  RDS ()$
