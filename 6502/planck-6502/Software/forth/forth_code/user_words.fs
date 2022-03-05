\ List of optional Forth words for Tali Forth 2 for the 65c02
\ Scot W. Stevenson <scot.stevenson@gmail.com>
\ This version: 18. Dec 2018

\ When changing these words, edit them here and then use the 
\ forth_to_ophisbin.py tool to convert them to the required format
\ for inclusion in Ophis. This is handled automatically by "make"
\ when run from the top level. See forth_words/README.md for details

\ Note that these programs are not necessarily in the public domain,
\ see the original sources for details

\ -------------------------------------------------------
\ WORDS&SIZES prints all known words and the sizes of their codes
\ in bytes. It can be used to test the effects of different native
\ compile parameters
        \ : words&sizes  latestnt begin dup 0<> while dup name>string
        \ type space  dup wordsize u. cr  2 + @ repeat drop ;

\ -------------------------------------------------------
\ FIBONACCI, contributed by leepivonka at
\ http://forum.6502.org/viewtopic.php?f=9&t=2926&start=90#p58899
\ Prints fibonacci numbers up to and including 28657
         \ : fib ( -- ) 0 1 begin dup . swap over + dup 0< until 2drop ;
        
\ -------------------------------------------------------
\ FACTORIAL from 
\ https://www.complang.tuwien.ac.at/forth/gforth/Docs-html/Recursion-Tutorial.html
        \ : fact ( n -- n! )
        \  dup 0> if
        \     dup 1- recurse * else
        \     drop 1 then ;

\ -------------------------------------------------------
\ PRIMES from 
\ https://www.youtube.com/watch?v=V5VGuNTrDL8 (Forth Freak)
        \  : primes ( n -- )
        \      2 . 3 .
        \      2 swap 5 do
        \           dup dup * i < if 1+ then
        \            1 over 1+ 3 do
        \                  j i mod 0= if 1- leave then
        \            2 +loop
        \            if i . then
        \      2 +loop
        \    drop ;
        
\ -------------------------------------------------------
\ MANDELBROT by Martin Heermance
\ https://github.com/Martin-H1/Forth-CS-101/blob/master/mandelbrot.fs
\ http://forum.6502.org/viewtopic.php?f=9&t=3706
\ https://www.youtube.com/watch?v=fVa3Fx7dwBM
        \  setup constants to remove magic numbers to allow
        \  for greater zoom with different scale factors
20 constant maxiter
-39 constant minval
20 constant maxval
-29 constant mincol
29  constant maxcol



( these variables hold values during the escape calculation )
variable creal
variable cimag
variable zreal
variable zimag
variable cnt
variable scale_factor
variable rescale
variable s_escape


( compute squares, but rescale to remove extra scaling factor) 
: zr_sq zreal @ dup rescale @ */ ;
: zi_sq zimag @ dup rescale @ */ ;

( translate escape cnt to ascii greyscale )
: .char
\ s" ..,'~!^:;[/<&?oxox#  " 
s"    ,-!:=;*/I3X6A8%NW  "
drop + 1 
type ; 

( numbers above 4 will always escape, so compare to a scaled value) 
: escapes? s_escape @ > ; 

( increment cnt and compare to max iterations)
: count_and_test? 
cnt @ 1+ dup cnt ! 
maxiter > ; 

( stores the row column values from the stack for the escape calculation)
: init_vars 
5 lshift dup creal ! zreal ! 
5 lshift dup cimag ! zimag ! 
scale_factor @ 5 lshift rescale !
rescale @ 4 * s_escape !
1 cnt ! ; 

( performs a single iteration of the escape calculation)
: doescape 
zr_sq zi_sq 2dup + 
escapes? if 
2drop 
true 
else 
- creal @ +   ( leave result on stack ) 
zreal @ zimag @ rescale @ */ 1 lshift 
cimag @ + zimag ! 
zreal !                   ( store stack item into zreal ) 
count_and_test? 
then ; 

( iterates on a single cell to compute its escape factor)
: docell 
init_vars 
begin 
doescape 
until 
cnt @ 
.char ;
( for each cell in a row) 
: dorow 
maxval minval do 
dup i 
docell 
loop 
drop ; 

( for each row in the set)
: mandelbrot 
cr 
maxcol mincol do 
i dorow cr 
loop ; 

: uptime  130 @ 132 @ 200 um/mod s>d 60 um/mod s>d 60 um/mod cr . ." h " . ." m " . ." ," 2/ . ." s" cr ;
: l 256 0 do i 65425 ! loop ;
: lights 0 do l loop ;

: delay 0 do loop ;
: delay_long 0 do 255 delay loop ;
: sl 256 0 do 255 delay i 65425 ! loop ;
: slights 0 do sl loop ;

\ : cmandel scale_factor @ 0 = if 20 scale_factor ! then cls mandelbrot ;

: mandel scale_factor @ 0 = if 20 scale_factor ! then mandelbrot ;

: tmandel uptime mandel uptime ;

\ : tcmandel uptime cmandel uptime ;

: multimandel 18 scale_factor ! 0 do scale_factor @ 1+ 1+ scale_factor ! mandel loop ;

: tmultimandel 18 scale_factor ! 0 do scale_factor @ 1+ 1+ scale_factor ! tmandel loop ;

\ : tcmultimandel 18 scale_factor ! 0 do scale_factor @ 1+ 1+ scale_factor ! tcmandel loop ;



\ cr .( Welcome to Planck 6502 ) cr
\ END 

