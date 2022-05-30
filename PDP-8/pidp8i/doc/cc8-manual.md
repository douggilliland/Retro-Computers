# CC8 Manual


## A Bit of Grounding History

The PDP-8 was introduced by DEC in 1965 with the intention of being a
small and cheap processor that could be used in a variety of use cases
that were, at the time, considered low end, compared to where the rest
of the minicomputer world was at the time. It filled niches at the time
that today we’d fill with either desktop computers or embedded
processors. That makes the PDP-8 the spiritual ancestor of the iMac I’m
typing this on and of the Raspberry Pi this software is intended to run
on.

The PiDP-8/I project is part of an effort to prevent the PDP-8 from
sliding into undeserved obscurity. Whether you consider it the ancestor
of the desktop computer or the embedded processor, it is a machine worth
understanding.

The PDP-8 was roughly contemporaneous with a much more famous machine,
the PDP-11, upon which the C programming language was created. Although
a low-end PDP-11 is more powerful than even a high-end PDP-8, the fact
that their commercial lifetimes overlapped by so many years made one of
us (Ian Schofield) wonder if the PDP-8 could also support a C compiler.

The first implementation of C was on the PDP-11 as part of the early
work on the Unix operating system, and it was initially used to write
system utilities that otherwise would have been written in assembly. A C
language compiler first appeared publicly in Version 2 Unix, released
later in 1972. Much of PDP-11 Unix remained written in assembly until
its developers decided to rewrite the operating system in C, for Version
4 Unix, released in 1973. That decision allowed Unix to be relatively
easily ported to a wholly different platform — the Interdata 8/32 — in
1978 by writing a new code generator for the C compiler, then
cross-compiling everything. That success in porting Unix led to C’s own
success first as a systems programming language, and then later as a
general-purpose programming language.

Although we are not likely to use CC8 to write a portable operating
system for the PDP-8, it is powerful enough to fill C’s original niche
in writing system utilities for a preexisting OS written in assembly.


## What Is CC8?

The CC8 system includes two different compilers, each of which
understands a different dialect of C:

1.  A [cross-compiler](#cross) that builds and runs on any host computer
    with a C compiler that still understands K&R C. This compiler
    understands most of K&R C itself, with the exceptions documented
    below.

2.  A [native OS/8 compiler](#native), cross-compiled on the host
    machine to PDP-8 assembly code by the cross-compiler. This compiler
    is [quite limited](#nlim) compared to the cross-compiler.

CC8 also includes [a small C library](#libc) shared by both compilers.


## CC8’s Developmental Sparks

The last high-level language compiler to be attempted for the PDP-8, as
far as this document’s authors are aware, was Pascal in 1979 by Heinz
Stegbauer.

In more recent times, Vince Slyngstad and Paolo Maffei wrote a C
cross-compiler based on Ron Cain’s Small-C using a VM approach. [This
code][sms] is most certainly worth examining, and we are delighted to
acknowledge this work as we have used some of their C library code in
this project.

Finally, we would like to refer the reader to [Fabrice Bellard’s
OTCC][otcc]. Although it targets the i386, it was this bit of remarkable
software that suggested that there may be a chance to implement a native
PDP-8 compiler.

[otcc]: https://bellard.org/otcc/
[sms]:  http://so-much-stuff.com/pdp8/C/C.php


## Requirements

The CC8 system generally assumes the availability of:

*   [At least 16&nbsp;kWords of core](#memory) at run time for programs
    compiled with CC8.  The [native OS/8 CC8 compiler passes](#ncpass)
    require 20&nbsp;kWords to compile programs.

    CC8 provides no built-in way to use more memory than this, so you
    will probably have to resort to [inline assembly](#asm) or FORTRAN
    II library linkage to get access to more than 16&nbsp;kWords of core.

*   A PDP-8/e or higher class processor.  The CC8 compiler code and its
    [LIBC implementation](#libc) make liberal use of the MQ register
    and the BSW OPR instruction introduced with the PDP-8/e.

    This code will not run on, for example, a PDP-8/I with the EAE
    option installed, because although the EAE adds the MQ register, it
    does not give the older processor the BSW instruction.

    CC8 works on the PiDP-8/I because it is only the front panel that
    emulates a PDP-8/I. The underlying SIMH PDP-8 simulator is catholic
    in its support for PDP-8 family features: it doesn’t simulate any
    single PDP-8 family member exclusively. It is probably closest in
    behavior to a highly tricked-out PDP-8/a, meaning in part that it
    does support the MQ register and the BSW instruction.

    (Many of the CPU features of the SIMH PDP-8 simulator are hard-coded
    into the instruction decoding loop, so that there is no way to
    disable them at run time with configuration directives. If you have
    a PiDP-8/I and were expecting a strict PDP-8/I simulation underneath
    that pretty front panel, we’re sorry to pop your bubble, but the
    fact of the matter is that a PiDP-8/I is a Family-of-8 mongrel.)

*   At build time, the OS/8 FORTRAN II/SABR subsystem must be available.

*   At run time, any [stdio](#fiolim) operation involving file I/O
    assumes it is running atop OS/8. For instance, file name arguments
    to [`fopen()`](#fopen) are passed to OS/8 for interpretation.

There is likely a subset of CC8-built programs which will run
independently of OS/8, but the bounds on that class of programs is not
currently clear to us.


<a id="cross" name="posix"></a>
## The Cross-Compiler

The CC8 cross-compiler is the [SmallC-85 C compiler][sc85] with a PDP-8
[SABR][sabr] code generator strapped to its back end. That means the C
language dialect understood by the CC8 cross-compiler is [K&R C
(1978)][krc] minus function pointers and the `float` and `long` data
types.

The code for this is in the `src/cc8/cross` subdirectory of the PiDP-8/I
source tree, and it is built along with the top-level PiDP-8/I software.
When installed, this compiler is in your `PATH` as `cc8`.

CC8 also includes a [small C library](#libc) in the files
`src/cc8/os8/libc.[ch]`, which is shared with the [native OS/8
compiler](#native). This library covers only a small fraction of what
the K&R C library does, in part due to system resource constraints.

Ian Schofield originally wrote the SABR code generator atop a version of
Ron Cain’s famous [Small-C compiler][sc80], originally published in [Dr
Dobb’s Journal][ddj], with later versions published elsewhere.  William
Cattey later ported this code base to SmallC-85, a living project
currently [available on GitHub][sc85].

The CC8 cross-compiler can successfully compile itself, but it produces
a SABR assembly file that is too large (28K) to be assembled on the
PDP-8.  Thus [the separate native compiler](#native).

The key module for targeting Small-C to the PDP-8 is `code8.c`. It
does the code generation to emit SABR assembly code. However, the
targeting is not confined to that one file. There is code in various
of the other modules that is specific to the PDP-8 port that should be
abstracted out and cleaned up in the fullness of time.

[Currently](/tktview?name=e1f6a5e4fe), the simplest way to get SABR
outputs from the CC8 cross-compiler into the PiDP-8/I simulator is to
use our `os8-cp` program in ASCII mode to copy SABR outputs from the
cross-compiler onto the simulator’s disk image:

    $ os8-cp -a -rk0s /opt/pidp8i/share/media/os8/v3d.rk05 \
      src/cc8/examples/ps.sb dsk:

That results in a file `DSK:PS.SB` with the POSIX LF-only line endings
translated to the CRLF line endings OS/8 wants. You can then assemble,
link, and run within the simulator, as described [below](#exes).

For related ideas, see the PiDP-8/I wiki article “[Getting Text In][gti].”

[ddj]:  https://en.wikipedia.org/wiki/Dr._Dobb%27s_Journal
[gti]:  http://localhost:8080/wiki?name=Getting+Text+In
[krc]:  https://en.wikipedia.org/wiki/The_C_Programming_Language
[sabr]: /wiki?name=A+Field+Guide+to+PDP-8+Assemblers#sabr
[sc80]: https://en.wikipedia.org/wiki/Small-C
[sc85]: https://github.com/ncb85/SmallC-85


<a id="cpp"></a>
### The Cross-Compiler’s Preprocessor Features

The cross-compiler has rudimentary C preprocessor features:

*   Literal `#define` only.  You cannot define parameterized macros.

*   There are no token pasting (`##`), stringization (`#`), or
    charization (`#@`) features, there being little point to these
    featuers of the C preprocessor without parameterized macros.

*   `#undef` removes a symbol previously defined with `#define`

*   There are no `-D` or `-U` flags to define and undefine macros from
    the command line.

*   `#include`, but only for files in the current directory.  There is
    no include path, either hard-coded within the compiler or modifiable
    via the traditional `-I` compiler flag. It is legal to nest `#include`
    statements, but the depth is currently limited to 3 levels, maximum.

*   [Inline assembly](#asm) via `#asm`.

*   `#ifdef`, `#ifndef`, `#else` and `#endif` work as expected, within
    the limitations on macros given above.

*   There is no support for `#if`, not even for simple things like `#if
    0`, much less for expressions such as `#if defined(XXX) &&
    !defined(YYY)`


### <a id="nhead"></a>Necessary Headers

There are two header files, for use with the cross-compiler only:

*   `libc.h` — Declares the entry points used by [LIBC](#libc) using
    CC8 [library linkage directives](#linkage). If your program makes
    use of any library functions, you must `#include` this at the top of
    your program.

*   `init.h` — Inserts a block of [inline assembly](#asm) startup code
    into your program, which initializes the program environment, sets
    up LIBC, and defines a few low-level routines. Unless you know this
    file’s contents and have determined that you do not need any of what
    it does for you, you probably cannot write a valid CC8 program that
    does not `#include` this header.

Because the cross-compiler lacks an include path feature, you generally
want to symlink these files to the directory where your source files
are. This is already done for the CC8 examples and such.

If you compare the examples in the source tree (`src/cc8/examples`) to
those with uppercased versions of those same names on the OS/8 `DSK:`
volume, you’ll notice that these `#include` statements were stripped out
as part of the disk pack build process. This is [necessary](#os8pp); the
linked documentation tells you why and how the OS/8 version of CC8 gets
away without a `#include` feature.

If you need to write C programs that build with both compilers, you can
convert the files like so:

    sed '/^#include/d' < my-program-cross.c > MYPROG.C


<a id="native" name="os8"></a>
## The Native OS/8 Compiler

Whereas the [CC8 cross-compiler](#cross) is basically just a PDP-8 code
generator strapped to the preexisting Small-C compiler, the native OS/8
CC8 compiler was written from scratch by Ian Schofield. It gets
cross-compiled, assembled, linked, and saved to the OS/8 disk packs as
part of the PiDP-8/I software build process. Thereafter, it is a
standalone system using only OS/8 resources.

Because this compiler must work entirely within the stringent limits of
the PDP-8 computer architecture and its OS/8 operating system, it speaks
a [much simpler dialect of C](#nfeat) than the cross-compiler, which
gets to use your host’s much greater resources.

Unlike with the original CC8 software distribution, the PiDP-8/I
software project does not ship any pre-built CC8 binaries.  Instead, we
bootstrap CC8 binaries from source code with the powerful
[`os8-run`][os8r] scripting language interpreter and the PiDP-8/I
software build system.  (You can suppress this by passing the
`--disable-os8-cc8` option to the `configure` script.) This process is
controlled by the [`cc8-tu56.os8`][cctu] script, which you may want to
examine along with the `os8-run` documentation to understand this
process better.

If you change the OS/8 CC8 source code, saying `make` at the PiDP-8/I
build root will update `bin/v3d.rk05` with new binaries automatically.

Because the CC8 native compiler is compiled by the CC8 *cross*-compiler,
the [standard memory layout](#memory) applies to both.  Among other
things, this means each pass of the native compiler requires
approximately 20&nbsp;kWords of core.

The native OS/8 CC8 compiler’s source code is in the `src/cc8/os8`
subdirectory of the PiDP-8/I software distribution.

<a id="ncpass"></a>The compiler passes are:

1.  `c8.c` &rarr; `c8.sb` &rarr; `CC.SV`: The compiler driver: accepts
    the input file name from the user, does some [rudimentary
    preprocessing](#os8pp) on it, and calls the first proper compiler
    pass, `CC1`.

2.  `n8.c` &rarr; `n8.sb` &rarr; `CC1.SV`: The parser/tokeniser section
    of the compiler.

3.  `p8.c` &rarr; `p8.sb` &rarr; `CC2.SV`: The token to SABR code
    converter section of the compiler.

There is also `libc.c` &rarr; `libc.sb` &rarr; `LIBC.RL`, the [C
library](#libc) linked to any program built with CC8, including the
passes above, but also to your own programs.

All of these binaries end up on the automatically-built OS/8 boot disk:
`CC?.SV` on `SYS:`, and everything else on `DSK:`, based on the defaults
our OS/8 distribution is configured to use when seeking out files.

Input programs should go on `DSK:`. Compiler outputs are also placed on
`DSK:`.

[cctu]: /file?fn=media/os8/scripts/cc8-tu56.os8
[os8r]: ./os8-run.md


<a id="nfeat" name="features"></a>
### Features of the Native OS/8 Compiler

The following is the subset of C known to be understood by the native
OS/8 CC8 compiler:

1.  **Local and global variables**

1.  **Pointers,** within limitations given below.

1.  **Functions:** Parameter lists must be declared in K&R form:

        int foo (a, b)
        int a, b;
        {
            ...
        }

1.  **Recursion:** See [`FIB.C`][fib] for an example of this.

1.  **Simple arithmetic operators:** `+`, `-`, `*`, `/`, etc.

1.  **Bitwise operators:** `&`, `|`, `~` and `!`

1.  **Simple comparison operators:** False expressions evaluate as 0 and
    true as -1 in two’s complement form, meaning all 1's in binary form.
    See the list of limitations below for the operators excluded by our
    "simple" qualifier.

1.  **2-character operators:** `++`, `--`, `==`, `!=`,`>=`, `<=`, `&&`,
    and `||`. Note that `++` and `--` are postfix only, and
    that `&&` and `||` are [implemented as `&` and `|`](#2cbo).

1.  **Ternary operator:** The `?:` operator works as of May 2020; it may
    be nested.

1.  **Limited library:** See [below](#libc) for a list of library
    functions provided, including their known limitations relative to
    Standard C.

    There are many limitations in this library relative to Standard C or
    even K&R C, which are documented below.

1.  **Limited structuring constructs:** `if`, `while`, `for`, etc. are
    supported. There is a nesting limit of 10 which is rarely exceeded in 
    most applications. In addition, `switch` statements are now supported
    via a code re-write in the C pre-processor (cc.sv). See  [`FORTH.C`][forth]
    for an example.

[fib]:   /doc/trunk/src/os8/examples/fib.c
[forth]: /doc/trunk/src/os8/examples/forth.c

<a id="nlim" name="limitations"></a>
### Known Limitations of the OS/8 CC8 Compiler

The OS/8 version of CC8 supports a subset of the C dialect understood by
[the cross-compiler](#cross), and thus of K&R C:

1.  <a id="typeless"></a>The language is typeless in that everything is
    a 12 bit integer, and any variable/array can interpreted as `int`,
    `char` or pointer.  All variables and arrays must be declared as
    `int`. As with K&R C, the return type may be left off of a
    function's definition; it is implicitly `int` in all cases.

    It is not necessary to give argument types when declaring function
    arguments, but you must declare a return type with the OS/8 CC8
    compiler:

        int myfn(n) { /* do something with n */ }

    This declares a function taking an `int` called `n` and returning
    an `int`.
    
    Contrast the CC8 cross-compiler, which requires function argument
    types to be declared but not the return type, per K&R C rules:

        int myfn(n)
        int n;
        {
            /* do something with n, then _maybe_ return something */
        }

    The type int is mandatory for all functions.

    The cross-compiler supports `void` as an extension to K&R C. This type
    is converted to `int` in the pre-processor. Similarly, the type `char` is
    converted. These type may be used for readability purposes.

2.  There must be an `int main()`, and it must be the last function
    in the single input C file.

    Since OS/8 has no way to pass command line arguments to a program
    — at least, not in a way that is compatible with the Unix style
    command lines expected by C — the `main()` function is never
    declared to take arguments.

3.  We do not yet support separate compilation of multiple C modules
    that get linked together.  You can produce relocatable libraries in
    OS/8 `*.RL` format and link them with the OS/8 LOADER, but because
    of the previous limitation, only one of these can be written in C.

4.  <a id="os8pp"></a>The OS/8 compiler has extremely rudimentary
    support for preprocessor directives.

    *   Literal `#define` only: no parameterized macros, and no `#undef`.

    *   `#include` is not supported and must not appear in the C source
        code fed to the Native OS/8 Compiler.

        This means you cannot use `#include` directives to string
        multiple C modules into a single program.

        It also means that if you take a program that the cross-compiler
        handles correctly and just copy it straight into OS/8 and try to
        compile it, it probably still has the `#include <libc.h>` line and
        possibly one for `init.h` as well. *Such code will fail to compile.*
        You must strip such lines out when copying C files into OS/8.

        (The native compiler emits startup code automatically, and it
        hard-codes the LIBC call table in the [final compiler
        pass](#ncpass), implemented in `p8.c`, so it doesn’t need
        `#include` to make these things work.)

    *   No conditional compilation: `#if`, `#ifdef`, `#else`, etc.

    *   [Inline assmembly](#asm) via `#asm` / `#endasm`. See
        [`FIB.C`][fib] for an example

5.  Variables are implicitly `static`, even when local.

6.  Arrays may only be single indexed. See `PS.C` for an example.

7.  The compiler does not yet understand how to assign a variable's
    initial value as part of its declaration. This:

        int i = 5;

    must instead be:

        int i;
        i = 5;

8.  <a name="2cbo"></a>`&&` and `||` work, but because they
    are internally converted to `&` and `|`, their precedence has
    changed, and they do not short-circuit as in a conforming C
    compiler.

    You can work around such differences with clever coding. For
    example, this code for a conforming C compiler:

        if (i != 0 || j == 5)

    should be rewritten for CC8 to avoid the precedence changes as:

        if (!(i == 0) || (j == 5))

    because a true result in each subexpression yields -1 per the
    previous point, which when bitwise OR'd together means you get -1 if
    either subexpression is true, which means the whole expression
    evaluates to true if either subexpression is true.

    If the code you were going to write was instead:

        if (i != 0 || j != 5)

    then the rewrite is even simpler owing to the rules of [Boolean
    algebra](https://en.wikipedia.org/wiki/Boolean_algebra):

        if (!(i == 0 & j == 5))

    These rules mean that if we negate the entire expression, we get the
    same truth table if we flip the operators around and swap the
    logical test from OR to AND, which in this case converts the
    expression to a form that is now legal in our limited C dialect. All
    of this comes from the Laws section of the linked Wikipedia article;
    if you learn nothing else about Boolean algebra, you would be well
    served to memorize those rules.

9. Dereferencing parenthesized expressions does not work: `*(<expr>)`

10. There is no argument list checking, not even for functions
    previously declared in the same C file. If we did fix this, the
    problem would still exist for functions in other modules, such as
    [`LIBC`](#libc), since K&R C doesn’t have prototypes; ANSI added
    that feature to C.

11. `do/while` loops are parsed, but the code is not properly generated.
    Regular `while` loops work, as does `break`, so one workaround for a
    lack of `do/while` is:

        while (1) { /* do something useful */; if (cond) break; }

    We have no intention to fix this.

12. As of May 2020, `switch` is implemented via re-write to cascading
    `if`/`then` statements. There are a number of limitations to this
    approach that a CC8 user should be aware of.

    The primary one to keep in mind is that that if you use a
    memory-mutating expression in the `switch` clause with a conforming
    C compiler, it is evaluated just once at the start of the block, but
    in CC8, it is evaluated once for each generated `if` sub-expression
    that the code visits. That is, you should not say things like this
    in code meant to be compiled with the CC8 native compiler:

        switch (*p++) {...}

    Say instead:

        int temp = *p++;
        switch (temp) {....}

    Also, there **must** be a `default` case, and cases (including the
    default case) must be terminated with a `break`. CC8 does not allow
    for cases that fall through to the following case. The following
    code has at least three syntax errors:

        switch (x) {
            case 1:  foo();
            case 2:  bar();
            default: qux();
        }

13. `sizeof()` is not implemented.



<a id="warning"></a>
#### GOVERNMENT HEALTH WARNING

**You are hereby warned**: The native OS/8 compiler does not contain any
error checking whatsoever. If the source files contain an error or you
mistype a build command, you may get:

*   A runtime crash in the compiler
*   SABR assembly output that won't assemble
*   Output that assembles but won't run correctly

Rarely will any of these failure modes give any kind of sensible hint as
to the cause. OS/8 CC8 cannot afford the hundreds of kilobytes of error
checking and text reporting that you get in a modern compiler like GCC
or Clang. That would have required a roomful of core memory to achieve
on a real PDP-8. Since we're working within the constraints of the old
PDP-8 architecture, we only have about 3&nbsp;kWords to construct the parse
result, for example.

In addition, the native OS/8 compiler is severely limited in code space,
so it does not understand the full C language. It is less functional
than K&R C 1978; we do not have a good benchmark for what it compares to
in terms of other early C dialects, but we can sum it up in a single
word: primitive.

Nonetheless, our highly limited C dialect is Turing complete. It might
be better to think of it as a high-level assembly language that
resembles C rather than as "C" proper.


## <a id="libc"></a>The CC8 C Library: Documentation

In this section, we will explain some high-level matters that cut across
multiple functions in the C library. This material is therefore not
appropriate to repeat below, in the [C library function
reference](#libref).


### <a id="ctype"></a>ctype

The ISO C Standard does not define what the `is*()` functions do when
the passed character is not representable as `unsigned char`. Since this
C compiler [does not distinguish types](#typeless), our `is*()`
functions return false for any value outside of the ASCII range, 0-127.


### <a id="cset"></a>Character Set

The stdio implementation currently assumes US-ASCII 7-bit text I/O.

Input characters have their upper 5 bits masked off so that only the
lower 7 bits are valid in the returned 12 bit PDP-8 word. Code using
[`fgetc`](#fgetc) cannot be used on arbitrary binary data because its
“end of file” return case is indistinguishable from reading a 0 byte.

The output functions will attempt to store 8-bit data, but since you
can’t read it back in safely with this current implementation, per
above, you should only write ASCII text to output files with this
implementation. Even if you are reading your files with some other code
which is capable of handling 8-bit data, there are further difficulties
such as a lack of functions taking an explicit length, like `fwrite()`,
which makes dealing with ASCII NUL difficult. You could write a NUL to
an output file with `fputc()`, but not with `fputs()`, since NUL
terminates the output string.


### <a id="wordstr"></a>Strings are of Words, Not of Bytes or Characters

In several places, the Standard says a conforming C library is supposed
to operate on “bytes” or “characters,” at least according to [our chosen
interpretation][cppr]. Except for the text I/O restrictions called out
[above](#cset), LIBC operates on strings of PDP-8 words, not on these
modern notions of fixed 8-bit bytes or the ever-nebulous “characters.”

Because you may be used to the idea that string and memory functions
like [`memcpy()`](#memcpy) and [`strcat()`](#strcat) will operate on
bytes, we’ve marked all of these cases with a reference back to this
section.

By the same token, most functions that operate on NUL-terminated string
buffers in a conforming C library implementation actually check for a
word equal to 0000₈ in this implementation. The key thing to understand
is that these routines are not carefully masking off the top 4 or 5 bits
to check *only* against a 7- or 8-bit NUL character.

This is another manifestation of [CC8’s typeless nature](#typeless).


### <a id="fiolim"></a>File I/O Limitations

Because LIBC’s stdio implementation is built atop the OS/8 FORTRAN II
library, it only allows one file to be open at a time for reading and
one for writing. OS/8’s underlying limit is 5 output files and 9 input
files, which appears to be an accommodation specifically for its FORTRAN
IV implementation, so it is possible that a future CC8 would be
retargeted at FORTRAN IV to lift this limitation, but it would be a
nontrivial amount of work.

Meanwhile, we generally defer to the OS/8 FORTRAN II manual where it
comes to documentation of these functions behavior.  The only time we
bring it up in this manual is when there is either a mismatch between
expected C behavior and actual FORTRAN II behavior or between the way
OS/8 FORTRAN II is documented and the way things actually work when it’s
being driven by CC8.

This underlying base has an important implication: programs built with
CC8 which use its file I/O functions are dependent upon OS/8.  That
underlying base determines how file names are interpreted, what devices
get used, etc.

Because of this single-file limitation, the stdio functions operating on
files do not take a `FILE*` argument as in Standard C, there being no
need to specify which file is meant. Output functions use the one and
only output file, and input functions use the one and only input file.
Our [`fopen()`](#fopen) doesn’t return a `FILE*` because the caller
doesn’t need one to pass to any of the other functions. That leaves only
[`fclose()`](#fclose), which would be an ambiguous call without a
`FILE*` argument if it wasn’t for the fact that OS/8 FORTRAN II doesn’t
have an `ICLOSE` library function, there apparently being no resources
to free on closing an input file.

All of this means that to open multiple output files, you have to
`fclose` each file before calling [`fopen("FILENA.ME", "w")`](#fopen) to
open the next.  To open multiple input files, simply call `fopen()` to
open each subsequent file, implicitly closing the prior input file.


### <a id="crlf"></a>CR+LF Handling

Because the PDP-8 started life in a world where “terminal” was
synonymous with “Teletype,” OS/8 uses CR+LF line endings, and its
FORTRAN II implementation does not translate bare LF to CR+LF on output.
This means that in order to properly write text files, you must use an
explicit “`\r\n`” sequence in programs compiled with CC8.

We’ve tried fixing it, and it’s messy to do a complete job of it given
the constraints involved.


### <a id="ctrlc"></a>Ctrl-C Handling

Unlike on modern operating systems, there is nothing like `SIGINT` in
OS/8, which means Ctrl-C only kills programs that explicitly check for
it.  The keyboard input loop in the CC8 LIBC standard library does do
this.

The thing to be aware of is, this won’t happen while a program is stuck
in an infinite loop or similar. The only way to get out of such a
program is to either restart OS/8 — assuming the broken program hasn’t
corrupted the OS’s resident parts — or restart the PDP-8.

(You can restart OS/8 by causing a jump to core memory location 07600.
Within the `pidp8i` environment, you can hit Ctrl-E, then say “`go
7600`”.  From the front panel, press the Stop key, toggle 7600 into the
switch register, press the Load Add key, then press the Start key.)


### <a id="missing"></a>Missing Functions

The bulk of the Standard C Library is not provided, including some
functions you’d think would go along nicely with those we do provide,
such as `feof()` or `fseek()`.  Keep in mind that the library is
currently restricted to [a single 4&nbsp;kWord field](#memory), and we
don’t want to lift that restriction. Since the current implementation
nearly fills that space, it is unlikely that we’ll add much more
functionality beyond the currently provided 33 LIBC functions plus [the
9 additional functions](#addfn). If we ever fix any of the limitations
we’ve identified below, consider it “gravy” rather than any kind of
obligation fulfilled.

Some of these missing functions are less useful in the CC8 world than in
more modern C environments. The low-memory nature of this world
encourages writing loops over [word strings](#wordstr) in terms of
pointer arithmetic and implicit zero testing (e.g. `while (*p++) { /*
use p */ }`) rather than make expensive calls to `strlen()`, so that
function isn’t provided.

Do not bring your modern C environment expectations to CC8!


## <a id="libref"></a>The CC8 C Library: Reference

CC8 offers a very limited standard library, which is shared between the
native and cross-compilers. While some of its function names are the
same as functions defined by Standard C, these functions generally do
not conform completely to any given standard due to the severe resource
constraints imposed by the PDP-8 architecture. This section of the
manual documents the known limitations of these functions relative to
[the current C standard as interpreted by `cppreference.com`][cppr], but
it is likely that we have overlooked corner cases that our library does
not yet implement.  When in doubt, [read the source][libcsrc].

[The LIBC implementation][libcsrc] is currently stored in the same
source tree directory as the native compiler, even though it’s shared
between the two compilers. This is because the two compilers differ only
from the code generation layer up: if you cross-compile a C program with
`bin/cc8`, you must still *assemble and link* it under OS/8, which means
using the `LIBC.RL` binary produced for use by the native compiler.

Contrast [the `libc.h` file][libch] which is symlinked or copied
everywhere it needs to be. This is because neither version of CC8 has
the notion of an include path. This file must therefore be available in
the same directory as each C file that uses it.

In the following text, we use OS/8 device names as a handwavy kind of
shorthand, even when the code would otherwise run on any PDP-8 in
absence of OS/8. Where we use “`TTY:`”, for example, we’d be more
precise to say instead “the console teleprinter, being the one that
responds to [IOT device code][iot] 3 for input and to device code 4 for
output.” We’d rather not write all of that for every stdio function
below, so we use this shorthand.

[cppr]:    https://en.cppreference.com/w/c
[iot]:     /wiki?name=IOT+Device+Assignments
[libch]:   /doc/trunk/src/cc8/include/libc.h
[libcsrc]: /doc/trunk/src/cc8/os8/libc.c


### <a id="atoi"></a>`int atoi(s, *result)`

Takes a null-terminated ASCII character string pointer `s` and tries to
interpret it as a 12-bit PDP-8 two’s complement signed integer, storing
the value in `*result` and returning the number of bytes in `s`
consumed.

**Standard Violations:**

*   Instead of returning the converted integer, this function stores
    that value in `*result`.

*   Whereas `atoi()` in Standard C returns the converted value, in this
    function, `s[retval]` is the first invalid — non-sign, non-digit,
    non-space — character in the string, where `retval` is the return
    value.

*   Skips leading ASCII 32 (space) characters only, not those matched by
    [`isspace()`](#isspace), as the Standard requires.


### <a id="cupper"></a>`cupper(p)`

Implements this loop more efficiently:

    char* tmp = p;
    while (*tmp) {
        *tmp = toupper(*tmp);
        ++tmp;
    }

That is, it does an in-place conversion of the passed [0-terminated word
string](#wordstr) to all-uppercase.

This function exists in LIBC because it is useful for ensuring that file
names are uppercase, as OS/8 requires. With the current CC8 compiler
implementation, the equivalent code above requires 24 more instructions
than calling `cupper()` instead, best-case! That means a single call
converted from a loop around [`toupper()`](#toupper) to a `cupper()`
call more than pays for the 21 instructions and one extra jump table
slot this function requires in LIBC.

Do not depend on the return value. There is a predictable mapping, but
it has no inherent meaning, so we are not documenting that mapping here.
If CC8 had a “`void`” return type feature, we’d be using that here.

**Nonstandard.** No known analog in any other C library.


### <a id="dispxy"></a>`dispxy(x,y)`

Plot a point at coordinate (x,y) on a [VC8E point-plot display][vc8e].

This is the display type assumed by the PiDP-8/I Spacewar!
implementation. There were many other display types designed for and
sold with PDP-8 family computers, which generally used different IOT
codes. If you’re trying to control something other than a VC8E, you
might want to replace this routine’s internals rather than code a
separate implementation, leading to wasted space in your LIBC.

**Nonstandard.**

[dixy]: http://homepage.divms.uiowa.edu/~jones/pdp8/man/vc8e.html
[vc8e]: https://homepage.divms.uiowa.edu/~jones/pdp8/man/vc8e.html


### <a id="exit"></a>`exit(ret)`

Exits the program.

This function is implemented in terms of the [FORTRAN II library
subroutine `EXIT`][f2exit], which in the OS/8 implementation simply
returns control to the OS/8 keyboard monitor.

If `EXIT` returns for any reason, LIBC halts the processor.

**Standard Violations:**

*   The passed return code is ignored, there being no such thing as a
    program’s “status code” in OS/8.

*   There is no `atexit()` mechanism in the CC8 LIBC.

[f2exit]: https://archive.org/details/bitsavers_decpdp8os8_39414792/page/n702


### <a id="fclose"></a>`fclose()`

Closes the currently-opened output file.

This function simply calls the OS/8 FORTRAN II library subroutine
[`OCLOSE`][f2fio].

**Standard Violations:**

*   Does not take a `FILE*` argument.  (See [`fopen()`](#fopen) for
    justification.)

*   Always closes the last-opened *output* file, only, there being
    [no point](#fiolim) in explicitly closing input files in this
    implementation.

[f2fio]: https://archive.org/details/bitsavers_decpdp8os8_39414792/page/n700


### <a id="fgets"></a>`fgets(s)`

Reads a string of ASCII characters from the last file opened for input
by [`fopen()`](#fopen), storing it at core memory location `s`. It reads
until it encounters an LF character, storing that and a trailing NUL
before returning, because it assumes the OS/8 convention of CR+LF
terminated text files.

OS/8 text files frequently include form feed characters — ASCII 12 —
owing to the PDP-8’s close association with teleprinters. `fgets()` does
not do anything with these other than give them to the program
literally. These should typically be removed from input or replaced with
an ASCII space character, 32.

Returns 0 on EOF, as Standard C requires.

**Standard Violations:**

*   Returns the number of characters read on success, rather than `s` as
    Standard C requires.

*   Since EOF is the only error exit case from this implementation of
    `fgets()`, this LIBC does not provide `feof()`.


### <a id="fopen"></a>`fopen(name, mode)`

Opens OS/8 file `DSK:NA.ME`.

The `name` parameter must point to at most six 0-terminated characters,
[one character per word](#wordstr), plus a 2-letter file name extension,
all in upper case.  (See [`cupper()`](#cupper).)

The file is opened for reading if `mode` points to an ”`r`” character,
and it is opened for writing if `mode` points to a “`w`” character. This
need only point to a single character, since only that one memory
location is ever referenced. No terminator is required.

The OS/8 device name is hard-coded, despite the fact that the OS/8
FORTRAN II [`IOPEN` and `OOPEN`][f2fio] subroutines that `fopen()` is
implemented in terms of accept a device name parameter. This means there
is currently no way to use this `stdio` implementation to read from or
write to files on OS/8 devices other than `DSK:`.

The underlying FORTRAN II routines are documented as hard-coding the
file name extension to `DA`, but inspection of the code reveals that
this LIBC does some hackery to overwrite that, allowing aribtrary
extensions.  **TODO:** Verify this for both read and write.


**Standard Violations:**

*   Does not return a `FILE*`. Functions which, in Standard C, take a
    `FILE*` argument do not do so in the CC8 LIBC, because there can be
    only one opened input file and one opened output file at a time, so
    the file that is meant is implicit in the call.

    This also means `fopen()` has no way to signal a failure to open the
    requested file name!  ...Which is just as well, since there is also
    no `ferror()` or `errno` in our LIBC.

    This function will return -1 if no file name extension is given,
    which is good in that it means this function does have *some* error
    checking, it’s a nonstandard way to signal it.

*   Does not accept the standard mode `a`, for append.  Since there is
    also no `fseek()` in CC8’s LIBC, a preexisting file named for
    writing is always overwritten.

*   Does not accept the standard `+` modifier to combine read/write
    modes: files are only readable or only writeable under this
    implementation.  Neither is it possible to give “`rw`”, the
    nonstandard but widely supported way to specify “open for
    read/write”.

*   Does not support the `b` modifier for binary I/O: files are assumed
    to contain ASCII text only.

*   Does not diagnose null pointers as required by the Standard: it will
    probably do something silly like reference [core memory location 0
    in the user data field](#udf), then return without having done
    anything useful, causing the subsequent I/O calls on that file to
    fail.

*   There appears to be a bug in the current implementation that
    requires you to open the input file before opening an output file
    when you need both.  It may not be possible to fix this within the
    current limitations on the library, but if you come up with
    something, [we accept patches][hakp].

[hakp]: /doc/trunk/CONTRIBUTING.md#patches


### <a id="fprintf"></a>`fprintf(fmt, args...)`

Writes its arguments (`args`...) to the currently-opened output file
according to format string `fmt`.

Returns the number of characters written to the output file.

This function is just a simple wrapper around [`printf()`](#printf)
which sets a flag that causes `printf()` to write the formatted string
to the current output file using [`fputs()`](#fputs) instead of to
`TTY:`, so you must read those two functions’ documentation to fully
understand `fprintf()`. Since `printf()` is in turn based on
[`sprintf()`](#sprintf), you must read that function’s documentation as
well.

**Standard Violations:**

*   `fprintf` does not take a `FILE*` pointer as its first argument. It
    simply writes to the one and only output file that can be opened at
    a time by [`fopen()`](#fopen).

*   File I/O errors are not diagnosed.


### <a id="getc" name="fgetc"></a>`getc()`, `fgetc()`

Reads a single ASCII character from `TTY:` or from the last file opened
for input by [`fopen()`](#fopen), respectively.

**Standard Violations:**

*   Returns ASCII NUL (0) to signal EOF, not an implementation-defined
    out-of-range EOF constant.  (Most commonly -1 in other C library
    implementations.)  Since there is no `feof()` function in CC8 LIBC
    to disambiguate the cases, this function cannot safely be called for
    files that could contain a 0 byte, since it will result in a false
    truncation.


### <a id="gets"></a>`gets(s)`

Reads a string of ASCII characters from `TTY:`, up to and including the
terminating CR character, storing it at core memory location `s`, and
following the terminating CR with a NUL character.

Backspace characters from the terminal remove the last character from
the string.

Returns the passed string pointer on success.

**Standard Violations:**

*   Cannot return 0 for “no input” as Standard C requires: always
    succeeds.


### <a id="isalnum"></a>`isalnum(c)`

Returns nonzero if either [`isdigit()`](#isdigit) or
[`isalpha()`](#isalpha) returns nonzero for `c`.

**Standard Violations:**

*   Does not know anything about locales; assumes US-ASCII input.


### <a id="isalpha"></a>`isalpha(c)`

Returns nonzero if the passed character `c` is either between 65 and 90
or between 97 and 122 inclusive, being the ASCII alphabetic characters.

**Standard Violations:**

*   Does not know anything about locales; assumes US-ASCII input.


### <a id="isdigit" name="isnum"></a>`isdigit(c)`, `isnum(c)`

Returns nonzero if the passed character `c` is between 48 an 57,
inclusive, being the ASCII decimal digit characters.

**Standard Violations:**

*   `isnum` is a nonstandard alias for `isdigit` conforming to no other
    known C library implementation.  Both are implemented with the same
    LIBC code.

*   Does not know anything about locales; assumes US-ASCII input.


### <a id="isspace"></a>`isspace(c)`

Returns nonzero if the passed character `c` is considered a “whitespace”
character.

This function is not used by `atoi`: its whitespace matching is
hard-coded internally.

**Standard Violations:**

*   Whitespace is currently defined as ASCII 1 through 32, inclusive.
    Yes, this is a *vast* overreach.


### <a id="itoa"></a>`itoa(num, str, radix)`

Convert a 12-bit PDP-8 integer `num` to an [ASCII word string](#wordstr)
expressing that number in the given `radix`, stored in memory pointed to
by `str`.

If `radix` is 10, `num` is treated as a two’s complement integer, so
that `str[0] == '-'` for negative numbers.

For other radices, `num` is treated as an unsigned value.

Radices beyond 10 use ASCII characters in the range “`a`” upward for
digits, giving a practical limit of base 36, though this is not checked
in the code.  We chose to use lowercase letters because conversion to
uppercase is easily done with the existing [`cupper()`](#cupper)
function, which we need anyway, whereas the reverse conversion would
have required extra code space, a precious commodity in the PDP-8.

This function does not check for sufficient buffer space before
beginning work. For radix 10, if the bounds on `num` are not known in
advance, `str` should point to 6 words of memory to cover the worst-case
condition, e.g. "-1234\\0". Lower radices generally require more
storage space.

There is no thousands separator in the output string.

**Nonstandard.** Emulates the `itoa()` function as defined in the
[Visual C++][itoam] and [Embarcadero C++][itoae] reference manuals.

[itoae]: http://docs.embarcadero.com/products/rad_studio/radstudio2007/RS2007_helpupdates/HUpdate4/EN/html/devwin32/itoa_xml.html
[itoam]: https://docs.microsoft.com/cpp/c-runtime-library/reference/itoa-itow


### <a id="kbhit"></a>`kbhit()`

Returns nonzero if `TTY:` has sent an input character that has not yet
been read, which may then be read by a subsequent call to
[`getc()`]((#getc). Returns 0 otherwise.

This function’s intended purpose is to let the program do work while
waiting for keyboard, since calling `getc()` before input is available
would block the program.

**Nonstandard.** Emulates a function common in DOS C libraries or those
descended from them, such as [Embarcadero C++][kbhite] and [Visual
C++][kbhitm].

[kbhite]: http://docs.embarcadero.com/products/rad_studio/radstudio2007/RS2007_helpupdates/HUpdate4/EN/html/devwin32/kbhit_xml.html
[kbhitm]: https://docs.microsoft.com/cpp/c-runtime-library/reference/kbhit


### <a id="memcpy"></a>`memcpy(dst, src, n)`

Copies `n` words from core memory location `src` to `dst` in the [user
data field](#memory).

Beware that the copy will [wrap around](#ptrwrap) to the beginning of
the field if either `src+n` or `dst+n` &ge; 4096.

The `dst` buffer can safely overlap the `src` buffer only if it is at a
lower address in memory. (Note that there is no `memmove()` in this
implementation.)

**Standard Violations:**

*   Returns 0 instead of the `dst` pointer as required by the Standard.
    A NULL return is specified as a failure condition by the Standard.

    This function has no internally-detected failure cases, so there is
    no ambiguity in the meaning of the return value.


### <a id="memset"></a>`memset(dst, c, len)`

Sets a run of `len` core memory locations starting at `dst` to `c`.

Beware that this function will [wrap around](#ptrwrap) if `dst+len-1`
&ge; 4096.

**Standard Violations:**

*   Returns 0 instead of the `dst` pointer as required by the Standard.

*   This function has no internally-detected failure cases, so the
    Standard’s requirement that this function return 0 in error cases
    means there is no ambiguity in the meaning of the return value.

    If we ever fix the prior violation, there will still be no ambiguity
    with the error case since [a valid pointer in CC8 cannot be
    zero](#memory).


### <a id="printf"></a>`printf(fmt, args...)`

Writes its arguments (`args`) formatted according to format string `fmt`
to `TTY:`.

This function is implemented in terms of [`sprintf()`](#sprintf), so see
its documentation for details on string formatting.

This function calls [`puts()`](#puts) after formatting the output
string, so see its documentation for information on how LIBC writes raw
character strings.

**WARNING:** Because `printf()` is implemented in terms of `sprintf()`
and it points at [a static buffer in the user data field](#memory), you
can only safely print up to *112* characters at a time with `printf()`.
Printing more will corrupt program data and most likely crash the
program.


### <a id="putc" name="fputc"></a>`putc(c)`, `fputc(c)`

Writes a character `c` either to `TTY:` or to the currently-opened
output file.

The characters pointed to are expected to be 7-bit ASCII bytes stored
within each PDP-8 word, with the top 5 bits unset, but no attempt is
currently made to enforce this.

Both functions return the written character.

**Standard Violations:**

*   Neither function can fail without locking up the computer or
    crashing the program, so an EOF return can never happen.

*   Neither function take a `FILE*` as their second parameter. `putc()`
    always writes to `TTY:`, and `fputc()` always writes to the
    currently-opened output file.


### <a id="puts" name="fputs"></a>`puts(s)`, `fputs(s)`

Writes a null-terminated character string `s` either to `TTY:` or to the
currently-opened output file.

The characters pointed to are expected to be 7-bit ASCII bytes stored
within each PDP-8 word, with the top 5 bits unset.

**Standard Violations:**

*   The `puts()` implementation does not write a newline after the
    passed string.

    (Neither does our `fputs()`, but that’s actually Standard behavior.)

*   Both `puts()` and `fputs()` are supposed to return nonzero on
    success, but this implementation returns 0.
    
    Technically, these functions aren’t explicitly “returning” anything,
    they’re just leaving 0 in AC, that being the ASCII NUL character
    that terminated the loop inside each function’s implementation.

*   `fputs()` detects no I/O error conditions, and thus cannot return
    EOF to signal an error. It always returns 0, whether an error
    occurred or not.

*   `fputs()` does not take a `FILE*` as its first parameter due to the
    [implicit single output file](#fiolim).


### <a id="revcpy"></a>`revcpy(dst, src, n)`

For non-overlapping buffers, has the same effect as
[`memcpy()`](#memcpy), using less efficient code.

Because it copies words in the opposite order from `memcpy()`, you may
be willing to pay its efficiency hit when copying between overlapping
buffers when the destination follows the source.

**Nonstandard.** Conforms to no known C library implementation.


### <a id="sprintf"></a>`sprintf(outstr, fmt, args...)`

Formats its arguments (`args`) for output to `outstr` based on format
string `fmt`.

The allowed standard conversion specifiers are `%`, `c`, `d`, `o`, `s`,
`u`, `x`, and `X`.  See your favorite C manual for their meaning.

The CC8 LIBC does support one nonstandard conversion specifier, `b`,
meaning binary output. Think of it like `x`, but in base 2.

The `b`, `d`, `o`, `u`, `x`, and `X` specifiers are implemented in terms
of [`itoa()`](#itoa). Our `%X` therefore involves a call to
[`cupper()`](#cupper) after `itoa()`, making `%x` the more efficient
option.

Left and right-justified padding is supported. Space and zero-padding
is supported.

Width prefixes are obeyed.

Precision specifiers are parsed but have no effect on the output.
**TODO**: Claim based on code inspection; verify with tests.

On success, it returns the number of characters written to the output
stream, not including the trailing NUL character. If it encounters an
unknown format specifier, it terminates the output string with a NUL and
returns -1.

**WARNING:** This function does not check its buffer pointer for
end-of-field, so if you cause it to print more than can be stored at the
end of a field, it will wrap around and begin writing at the beginning
of the same field. This also has effects on the behavior of
[`printf()`](#printf) and [`fprintf()`](#fprintf).

**Standard Violations:**

*   As long as CC8 has no floating-point support, the `a`, `e`, `f`, and
    `g` format specifiers (and their capitalized variants) cannot be
    supported.

*   Since CC8 does not support the `long` integer type qualifier, this
    function does not support the `l` format specifier.

*   The standard `n` and `p` format specifiers could be supported, but
    currently are not.

*   The `i` alias for the more common `d` specifier is not supported.

*   Unsupported input specifiers cause the function to return the number
    of characters written so far, not a negative value as the Standard
    requires.  In the case of `sprintf()`, this means the trailing NUL
    character will not be written!

*   There is no `snprintf()`, `vprintf()`, etc.


### <a id="scanf" name="fscanf"></a>`fscanf`, `scanf`, `sscanf`

Parse strings according to a `printf`-like format specification. `scanf`
gets the string from the interactive terminal, `fscanf` gets it from a
file opened with [`fopen()`](#fopen), and `sscanf` gets it from a
NUL-terminated C string already in core.

**DOCUMENTATION INCOMPLETE**


### <a id="strcat"></a>`strcat(dst, src)`

Concatenates one [0-terminated word string](#wordstr) to the end of
another in the [user data field](#udf).

This function will not copy data between fields.

If the terminating 0 word is not found in `dst` by the end of the
current field, it will wrap around to the start of the field and resume
searching there; the concatenation will occur wherever it does find a 0
word. If there happen to be no 0 words in the field, it will iterate
forever!

Beware that this function will [wrap around](#ptrwrap) if
`dst + strlen(dst) + strlen(src)` &ge; 4096 and stomp on whatever’s
at the start of the field.

These are not technically violations of Standard C as it leaves such
matters [undefined][ub].

Returns a copy of `dst`.

**Standard Violations:**

*   None known.


### <a id="strcpy"></a>`strcpy(dst, src)`

Copies one [0-terminated word string](#wordstr) to another memory
location in the [user data field](#udf).

This function will not copy data between fields.

Beware that this function will [wrap around](#ptrwrap) if either
`src+strlen(src)` or `dst+strlen(dst)` &ge; 4096.

The `dst` buffer can safely overlap the `src` buffer only if it is at a
lower address in memory.

**Standard Violations:**

*   Returns 0, not a copy of `dst` as the Standard requires.


### <a id="strstr"></a>`strstr(haystack, needle)`

Attempts to find the first instance of `needle` within `haystack`, which
are [0-terminated word strings](#wordstr). This function’s behavior is
[undefined][ub] if either buffer is not 0-terminated.

The implementation uses the [naïve string search algorithm][nssa], so
the typical execution time is O(n+m), but the worst case time is
&Theta(nm). Don’t go expecting us to buy execution speed with
preprocessing steps as with [BMH][bmh] or [KMP][kmp]!

Both the `haystack` and `needle` buffer pointers are offsets within the
[user data field](#udf).

Beware that this function will [wrap around](#ptrwrap) if either
`haystack+strlen(haystack)` or `needle+strlen(needle)` &ge; 4096,
continuing the search or match (respectively) from that point.

**Returns:**

*   *a pointer to the first needle*, if one is found within the haystack

*   *zero* if either no needle is in the haystack, *or* the haystack is
    zero-length (i.e. `*haystack == '\0'`), *or* the needle is bigger
    than the haystack

**Standard Violations:**

*   None known.

[bmh]:  https://en.wikipedia.org/wiki/Boyer%E2%80%93Moore%E2%80%93Horspool_algorithm
[kmp]:  https://en.wikipedia.org/wiki/Knuth%E2%80%93Morris%E2%80%93Pratt_algorithm
[nssa]: https://en.wikipedia.org/wiki/String-searching_algorithm#Na%C3%AFve_string_search


### <a id="toupper"></a>`toupper(c)`

Returns the uppercase form of ASCII character `c` if it is lowercase,
Otherwise, returns `c` unchanged.

**Standard Violations:**

*   There is no `tolower()` in the CC8 LIBC.

*   Does not know anything about locales; assumes US-ASCII input.


### <a id="xinit"></a>`xinit()`

Prints the CC8 compiler’s banner message. This is in LIBC only because
it’s called from several places within CC8 itself.

**Nonstandard.**


## <a id="addfn"></a>Additional Utility Routines

The functions that CC8 uses to manipulate the software stack are also
available to be called by end-user programs: `PUSH`, `POP`, `PUTSTK`,
`POPRET`, and `PCALL`. The page zero pointers for this stack are
initialized by code in `header.sb`, which is injected into your
program’s startup sequence during compilation.

In addition, there are a set of functions that may be used to provide
temporary storage in field 4, acting like a temporary binary file:

`void iinit(int address)`: Reset the file pointer to an arbitrary
address range 0-4095.

`void stri(int value)`: Store ‘value’ at the current address, and
increment the address pointer.

`int strl()`: Read the word at the current address, and do not increment
the address.

`int strd()`: Read the word at the current address, and increment the
address.

As field 4 is not used by OS/8, your program may use the entire field.
This library code does not check for overflow: going beyond address 4095
will simply wrap to address 0.



<a id="examples"></a>
## Trying the Examples

The standard PiDP-8/I OS/8 RK05 boot disk contains several example
C programs that the OS/8 version of CC8 is able to compile.

To try the OS/8 version of CC8 out, boot OS/8 within the PiDP-8/I
environment as you normally would, then try building one of the
examples:

    .EXE CCR   ⇠ BATCH wrapper around CC?.SV: "Compile C and Run"
    >ps.c      ⇠ takes name of C program, builds, links, and runs it

This example is particularly interesting. It generates
Pascal’s triangle without using factorials, which are a bit out of
range for 12 bits!

The other examples preinstalled are:

*   **<code>calc.c</code>** - A simple 4-function calculator program.

*   **<code>pd.c</code>** - Shows methods for doing double-precision
    (i.e. 24-bit) integer calculations.

*   **<code>hlb.c</code>** - Generates [Hilbert curves][hc] on a Tek4010
    series display using raw terminal codes. Therefore, you must be
    running a Tek4010 emulator when running this program, else you will
    get garbage on the display!

*   **<code>fib.c</code>** - Calculates the first 10 Fibonacci numbers.
    This implicitly demonstrates CC8's ability to handle recursive
    function calls.

*   **<code>basic.c</code>** - A simple Basic interpreter used to test
    a simple recursive expression processor.

*   **<code>forth.c</code>** - A simple Forth interpreter used to test
    switch statemments etc.

The two interpeters are quite complex, particularly the Forth
interpreter, which contains 300 lines of code and implements a number of
basic Forth functions. This example is intended to show what can be
crammed into 4k of core.


Another set of examples not preinstalled on the OS/8 disk are
`examples/pep001-*.c`, which are described [elsewhere][pce].

[hc]:  https://en.wikipedia.org/wiki/Hilbert_curve
[pce]: /wiki?name=PEP001.C


## <a id="exes"></a>Making Executables 

Executing `CCR.BI` loads, links, and runs your C program without
producing an executable file on disk.  You need only a small variation
on this BATCH file's contents to get an executable core image that
you can run with the OS/8 `R` command:

    .R CC                   ⇠ kinda like Unix cc(1)
    >myprog.c
    .COMP CC.SB
    .R LOADER
    *CC,LIBC/I/O$           ⇠ $ = Escape
    .SAVE SYS:MYPROG

If you've just run `EXE CCR` on `myprog.c`, you can skip the `CC` and
`COMP` steps above, reusing the `CC.RL` file that was left behind.

Basically, we leave the `/G` "go" switch off of the command to LOADER
so that the program is left in its pre-run state in core so that
`SAVE` can capture it to disk.


## <a id="memory"></a>Memory Model

The OS/8 FORTRAN II linking loader (`LOADER.SV`) determines the core
memory layout for the built programs. It is free to place code and data
wherever it likes, but the following is a plausible layout it could
choose:

**Field 0:** FORTRAN library utility functions and OS/8 I/O system

**Field 1:** The user data field (UDF): globals, literals, and stack

**Field 2:** The program's executable code

**Field 3:** The LIBC library code

**Field 4:** (Optional) see the binary utilities above (stri...).

### <a id="os8res"></a>OS/8 Reservations

The uppermost page of fields 0 thru 2 hold the
[resident portion of OS/8][os8res] and therefore must not be touched by
a program built with CC8 while running under OS/8. For example, the
[OS/8 keyboard monitor][os8kbd] re-entry point is at 07600₈, [the output
file table][os8oft] is at 17600₈, and [the USR][os8usr] is at 17700₈.
The resident parts of device drivers also live up here.


### <a id="zeropg"></a>Zero Page Usage

The first thing to get clear in your mind is that there are at least
*three* zero pages involved here, and possibly four, depending on how
`LOADER.SV` chooses to arrange your program in memory. (We get into the
nitty gritty of that [below](#flayout).) There are different rules for
each field.

The field containing the user’s executable code can also have code from
the FORTRAN II run time library in it, especially when the user’s
program is small and its use of FORTRAN II based library routines is
modest. (We give an example of this [below](#flayout).) In such fields,
LOADER places a small library of routines, which to a first
approximation means user code should not use the zero page.

Some of the space in the user code field’s zero page is left unused by
LOADER, so we use it for a small number of internal globals maintained
by the CC8 program initialization code: `init.h` for the cross-compiler,
and `header.sb` for the native compiler, which we’ll refer to
generically as “INIT” from here on.

It is not currently clear to us if, between LOADER and INIT, if there is
any space at all left over in the user code field. We’ll need to
undertake a mapping quest to work this out. We’ll report the results
here if our quest party manages to return alive. :)

None of this applies to the field containing LIBC because it contains no
FORTRAN II code, hence no LOADER internal helper routines or the globals
for those routines. LIBC therefore uses the zero page in its field for
entirely different purposes, which we do not document here because it
never conflicts with the end user code and data fields. If you want to
know how LIBC uses its field’s zero page, see `src/cc8/os8/libc.c`.

The [user data field](#udf) also runs on entirely different rules from
the above, since it contains no executable code at all, hence no prior
reservations by LOADER or LIBC. See the next section for how the UDF
uses its zero page.


### <a id="udf"></a>The User Data Field

The user data field is always field 1. Its layout breaks down like this:

| range         | use |
| ------------- | --- |
| `10000-10001` | PDP-8 interrupt handling; see Small Computer Handbook |
| `10002-10007` | reserved for future LIBC use |
| `10010-10017` | PDP-8 auto-index registers; see Small Computer Handbook |
| `10020-10177` | static output buffer used by [`[f]printf()`](#printf) in [`sprintf()`](#sprintf) call |
| `10200-1xxxx` | globals first, then literals packed together at the bottom |
| `1xxxx-17577` | user stack, grows upward from end of literals |
| `17600-17777` | last page of UDF reserved by OS/8 ([see above](#os8res)) |

The maximum size of globals + literals + stack in a CC8 program is
therefore 7400₈ words. (3840 decimal.)


#### <a id="nulptr"></a>C NULL Pointers

Because the PDP-8 interrupt system sets aside the first two locations of
each field for itself, and CC8 plays along, a valid C pointer can never
have value 0, preserving the expected falsy nature of a C NULL pointer.
This has practical positive consequences such as the fact that you can
depend on a call to [`gets()`](#gets) to always return a truthy value on
success, provided you’ve passed it a normal C pointer.

C gives you plenty of power to create a pointer equal to 0 and
dereference it, but you’d be out in [undefined behavior][ub] territory
by that point, so on your head be the consequences!


### <a id="ptrwrap"></a>Pointers Wrap Around

Pointers in this C implementation are generally confined to [the user
data field](#udf). That is to say, the code generated by CC8 does not
use 15-bit extended addresses; it just flips between pages depending on
what type of data or code it’s trying to access.

This means it is possible to iterate a pointer past the end of a 4096
word core memory field, causing it to wrap around to 0 and continue
blithely along.  Since the last page of the user data field [is reserved
for use by OS/8](#os8res) and the first page of the UDF has [several
special uses](#udf), programs that do this will most likely crash and
may even destroy data. Our [LIBC implementation](#libc) generally does
not try to check for such wraparound problems, much less signal errors
when it happens. The programmer is expected to avoid doing this.

Code that operates on pointers will generally only do its work within
the user data field. You will likely need to resort to [inline
assembly](#asm) and `CIF`/`CDF` instructions to escape that field.
Getting our [LIBC](#libc) to operate on other fields may be tricky or
even more difficult than it’s worth.

On the bright side, pointers are always 12-bit values, accessed with
indirect addressing, rather than page-relative 7-bit addresses, so that
programs built with CC8 need not concern themselves with [page
boundaries][memadd].


### <a id="heap"></a>There Is No Heap

There is no `malloc()` in this C library and no space reserved for its
heap in [the user data field](#udf). Everything in a CC8 program is
statically-allocated, if you’re using stock C-level mechanisms. If your
program needs additional dynamically-allocated memory, you’ll need to
arrange access to it some other way, such as [via inline
assembly](#asm).


#### Fun Trivia: The History of `malloc()`

There is no “`malloc()`” in K&R C, either, at least as far as the first
edition of “[The C Programming Language”][krc] goes. About halfway into
the book they give a simple function called `alloc()` that just
determined whether the requested amount of space was available within a
large static `char[]` array it managed for its callers. If so, it
advanced the pointer that much farther into the buffer and returned that
pointer. The corresponding `free()` implementation just chopped the
globally-allocated space off again, so if you called that `alloc()`
twice and freed the first pointer, the second would be invalid, too!

Then in Appendix A, Kernighan & Ritchie give a much smarter alternative
based on the old Unix syscall [`sbrk(2)`][sbrk]. The impression given is
that memory allocation isn’t part of the language, it’s part of the
operating system, and different implementations of C were expected to
provide this facility in local ways.

[V6 UNIX][v6ux] preceded K&R C by several years, and there is no
`malloc()` there, either. There’s an `alloc()` implementation in its
`libc` that’s scarcely more complicated than the `char[]` based one
first presented in K&R. There is no `free()` in V6: new allocations just
keep extending the amount of core requested.

`malloc()` apparently first appeared about a year after K&R was
published, in [V7 UNIX][v7ux]. It and its corresponding `free()` call
are based on similar techniques to the `sbrk()`-based `alloc()` and
`free()` published in K&R Appendix A, though clearly with quite a lot of
evolution between the two.

[sbrk]: https://pubs.opengroup.org/onlinepubs/7908799/xsh/brk.html
[v6ux]: https://en.wikipedia.org/wiki/Version_6_Unix
[v7ux]: https://en.wikipedia.org/wiki/Version_7_Unix


### <a id="vonn"></a>There Are No Storage Type Distinctions

Literals are placed in the same field as globals and the call stack,
rather that inline within the generated executable code. This may cause
surprise size limitations of the user programs.

CC8 does it this way because the FORTRAN II / SABR system does allow any
initialisation of COMMON storage in field 1, so the literals have to be
stored in the user program page and then be copied into field 1 at
program initialization time.  Various pointers to these regions are
mainatined by the compiler.


### <a id="sover"></a>Stack Overflow

Since CC8 places the call stack immediately after the last literal
stored in core, a program with many globals and/or literals will have
less usable stack space than a program with fewer of each.

Neither version of CC8 generates code to detect stack overflow. If you
try to push too much onto the stack, it will simply begin overwriting
the page OS/8 is using at the top of field 1. If you manage to blow the
stack by more than a page without crashing the program or the computer
first, the [stack pointer will wrap around](#ptrwrap) and the stack will
begin overwriting the first page of field 1.


### <a id="flayout"></a>Field Layout, Concrete Example

The field layout given [at the start of this section](#memory) is not
fixed. The linking loader is free to use any layout it likes, consistent
with any constraints in the input binaries. You can use the `/M` option
with `LOADER.SV` to get a core memory map for a given output. Let’s work
an example using the `ps.c` example program:

    .R CC
    >ps.c
    .COMP CC.SB
    .R LOADER
    *CC,LIBC/I/O/M
    V 4A
    MAIN    01000
    LIBC    20204
    OPEN    00000 U
    EXIT    00000 U
    ...

The `MAIN` line tells us that `LOADER.SV` has chosen to place our C
program in field 0, not field 2 as suggested above.

(This is not to be confused with the C `main()` *function*: we’re
viewing things from the FORTRAN II level here, not the C level. `MAIN`
is the name of the whole module as far as `LOADER.SV` is concerned.)

The loader doubtless did this because `ps.c` is small, so there was more
than enough space in field 0 to hold our `MAIN` module and all of the
FORTRAN II library routines it needs. We’ll see how much more below.

The map then tells us that LIBC is in field 2, not 3 as suggested above.
This is again a consequence of not needing two separate fields for the
FORTRAN II library and the `MAIN` module.

The “00000 U” lines on each of the FORTRAN II library routine locations
tell us that those locations hadn’t yet been determined at the time it
was told to produce the core map. (U = “undefined.”)

If we want to pin down the location of those FORTRAN II routines, we can
ask the loader to give us the map *after* it’s finalized everything by
telling it to run the program (`/G`), then give us the map:

    *CC,LIBC/I/O/G/M
    V 4A
    MAIN    02400
    LIBC    20204
    OPEN    03633
    EXIT    04133
    MPY     04206
    CHRIO   20470
    GENIO   03403
    OOPEN   04625
    IOPEN   04602
    OCLOS   04647
    DIV     04251
    IREM    04355
    ERROR   04013
    CKIO    04141
    CLEAR   04437
    IABS    04400
    IRDSW   04421
    SUBSC   04462
    CHAIN   04733
    0013
    0000
    0000
    0036
    0036
    0036
    0036
    0036

Now we can see that, indeed, all of the FORTRAN II library routines did
in fact land in field 0.

The tail end of the map file is also helpful. There are 8 lines at the
end for a 32&nbsp;kWord machine, one for each field. The value is the
number of core memory pages left free, in octal, after loading the
program.

This tells us that field 0 has 13₈ pages free, giving us at least 2600₈
words of space to use with C code and FORTRAN II library references
before the loader will be forced to put `MAIN` in a separate field.

Fields 1 and 2 are marked as wholly used up. This is another good clue
that this is the UDF is in field 1 in this program, since we know LIBC
is in field 2. Every last word of these pages isn’t actually in use, but
the LOADER considers these spaces hands-off as far as loading other
code.

The value 36₈ in the remaining lines reflects the way the loader works.
The size of a core memory field in the PDP-8 is 40₈ pages. The lowest
page is [set aside for use by LOADER itself](#ldrts). The remaining 3
pages per field are due to our use of device-independent I/O, requested
from LOADER with the `/I/O` flags. Programs not needing that can save
between 1 and 3 of these pages per field.

For more on this topic, see the companion article [PDP-8 Memory
Addressing][memadd].


[memadd]: /wiki?name=PDP-8+Memory+Addressing
[os8kbd]: https://archive.org/details/bitsavers_decpdp8os8up_5566495/page/n9
[os8oft]: https://archive.org/details/bitsavers_decpdp8os8up_5566495/page/n35
[os8res]: https://archive.org/details/bitsavers_decpdp8os8up_5566495/page/n69
[os8usr]: https://archive.org/details/bitsavers_decpdp8os8up_5566495/page/n17
[ub]:     https://en.wikipedia.org/wiki/Undefined_behavior
[zp]:     https://homepage.divms.uiowa.edu/~jones/pdp8/man/mri.html#pagezero


<a id="asm"></a>
## Inline Assembly Code

Both the [cross-compiler](#cross) and the [native compiler](#native)
allow inline [SABR][sabr] assembly code between `#asm` and `#endasm`
markers in the C source code:

    #asm
        TAD (42      / add 42 to AC
    #endasm

Such code is copied literally from the input C source file into the
compiler’s SABR output file, so it must be written with that context in
mind.


### <a id="calling"></a>The CC8 Calling Convention

You can write whole functions in inline assembly, though for simplicity,
we recommend that you write the function wrapper in C syntax, with the
body in assembly:

    add48(a)
    int a
    {
        a;          /* load 'a' into AC; explained below */
    #asm
        TAD (D48
    #endasm
    }

Doing it this way saves you from having to understand the way the CC8
software stack works, which we’ve chosen not to document here yet, apart
from [its approximate location in core memory](#memory). All you need to
know is that parameters are passed on the stack and *somehow* extracted
when they’re referenced in C code.

CC8 returns values from functions in AC, so our example does not require
an explicit “`return`” statement: we’ve arranged for our intended return
value to be in AC at the end of the function body, so the implicit
return does what we want here.

The above snippet therefore declares a function `add48` taking a single
parameter “`a`” and returning `a+48`.

Keep in mind when reading such code that CC8 is [essentially
typeless](#typeless): it’s tempting to think of the above code as taking
an integer and returning an integer, but you can equally correctly think
of it as taking a character and returning a character. Indeed, that
function will take a value in the range 0 thru 9 and return the
equivalent ASCII digit! CC8’s typeless nature mates well with K&R C’s
indifference toward return type declaration.


### Equivalence to Statements

A block of inline assembly functions as single statement in the C
program, from a syntactic point of view. Consider the implementation of
the Standard C function `puts` from the CC8 LIBC:

    puts(p)
    char *p;
        {
            while (*p++) 
    #asm
            TLS
    XC1,    TSF
            JMP XC1
    #endasm
        }

Notice that there is no opening curly brace on the `while` loop: when
the `TSF` op-code causes the `JMP` instruction to be skipped — meaning
the console terminal is ready for another output character — control
goes back to the top of the `while` loop. That is, these three
instructions behave as if they were a single C statement and thus
constitute the whole body of the `while` loop.


### Optimization

There are several clever optimizations that you might want to use in
your own programs, some of which are shown in the examples above:

*   In the `add48` example the line “`a;`” means “load `a` into AC”. In
    a Standard C compiler, this would be considered use of a variable in
    `void` context and thus be optimized out, but K&R C has no such
    notion, so it has this nonstandard meaning in CC8.  This technique
    is used quite a lot in our [LIBC](#libc), so you can be sure the
    behavior won’t be going away.

*   In the `puts` example, the statement `*p++` implicitly stores the
    value at the core memory location referred to by `p` in AC, so we
    can use it within the assembly body of that loop without ever
    explicitly referring to `p`.

*   Knowing that functions return their value in AC, you can call
    another C function from the middle of a block of assembly code but
    never store its return value explicitly: just use its return value
    directly from AC to save space on the stack.

Beware that CC8 isn’t a particularly smart compiler. It performs few of
the automatic tricks you’d expect from a modern C compiler, not even
handling simple things like constant expression reduction:

    char c = 'a' - 10;      /* save ASCII character 10 back from “a” */
    char c = 87;            /* same effect, but gives shorter output! */

That example is based on real code, the implementation of
[`itoa()`](#itoa) for radices beyond 10: we tried it both ways and ended
up doing it the obscure way to save code space in LIBC.

For the most part, CC8 currently leaves the task of optimization to the
end user.


### <a id="asmoct"></a>Inline Assembly is in Octal

Like the OS/8 FORTRAN II compiler, the CC8 compilers leave SABR in its
default octal mode. All integer constants emited by both compilers are
in octal.  (Even those in generated labels and in error output
messages!) This means integer constants in your inline assembly also get
interpreted as octal, by default.

If you use the `DECIM` SABR pseudo-op to get around this, you must be
careful to add an `OCTAL` op before the block ends to shift the mode
back. The compiler doesn’t detect use of `DECIM`, and it doesn’t blindly
inject `OCTAL` ops after every inline assembly block to force the mode
back on the off chance that the user had shifted the assembler into
decimal mode. If you leave the assembler in `DECIM` mode at the end of
an inline assembly block, the resulting SABR output will probably
assemble but won’t run correctly because all integer constants from that
point on will be misinterpreted.

It’s safer, if you wan a given constant to be interpreted as decimal, to
prefix it with a `D`. See the SABR manual for more details on this.


### <a id="linkage" name="varargs"></a>Library Linkage and Varargs

CC8 has some non-standard features to enable the interface between the
main program and the C library. This constitutes a compile time linkage
system to allow for standard and vararg functions to be called in the
library.

**TODO:** Explain this.


### <a id="os8asm"></a>Inline Assembly Limitations in the Native CC8 Compiler

The native compiler has some significant limitations in the way it
handles inline assembly.

The primary one is that snippets of inline assembly are gathered by the
[first pass](#ncpass) of the compiler in a core memory buffer that’s
only 1024 characters in size. If the total amount of inline assembly in
your program exceeds this amount, `CC.SV` will overrun this buffer and
produce corrupt output.

It’s difficult to justify increasing the size of that buffer, because
it’s already over [&frac14; the space given](#udf) in CC8 to global
variables.

It all has to be gathered in one pass, because this 1&nbsp;kWord buffer
is written to a text file (`CASM.TX`) at the end of the [first compiler
pass](#ncpass), where it waits for the final compiler pass to read it
back in to be inserted into the output SABR code.  Since LIBC’s
[`fopen()`](#fopen) is limited to a [single output file at a
time](#fiolim) and it cannot append to an existing file, it’s got one
shot to write everything it collected.

This is one reason the CC8 LIBC has to be cross-compiled: its inline
assembly is over 6&times; the size of this buffer.

Another problem to watch out for is that this inline assembly buffer is
broken into sections with `!` and `$` characters so that the final pass
of the compiler can break the `CASM.TX` file up into sections for
insertion into the SABR output. It is therefore unsafe to use these
characters in your inline assembly, lest they be seen as separators,
causing incorrect output.  This is especially easy to do in comments;
watch out! (See how easy it is to use an exclamation point when making
comments?)


### <a id="opdef"></a>Predefined OPDEFs

In addition to the op-codes predefined for SABR — which you can find in
[Appendix C of the OS/8 Handbook, 1974 edition][os8hac] — the following
`OPDEF` directives are inserted at the top of every SABR file output
from CC8, allowing your SABR code to use these as well:

|op-code|value|meaning|
|-------|-----|-------|
|`ANDI` |0400 |same as `AND I` in PAL8|
|`TADI` |1400 |same as `TAD I` in PAL8|
|`ISZI` |2400 |same as `ISZ I` in PAL8|
|`DCAI` |3400 |same as `DCA I` in PAL8|
|`JMSI` |4400 |same as `JMS I` in PAL8|
|`JMPI` |5400 |same as `JMP I` in PAL8|
|`MQL`  |7421 |load MQ from AC, clear AC|
|`ACL`  |7701 |load AC from MQ (use `CLA SWP` to give inverse of `MQL`)|
|`MQA`  |7501 |OR MQ with AC, result in MQ|
|`SWP`  |7521 |swap AC and MQ|
|`DILX` |6053 |set VC8E X coordinate (used by [`dispxy()`](#dispxy))|
|`DILY` |6054 |set VC8E Y coordinate|
|`DIXY` |6054 |pulse VC8E at (X,Y) set by `DIXY`,`DILY`|
|`CDF0` |6201 |change DF to field 0|
|`CDF1` |6211 |change DF to field 1|
|`CAF0` |6203 |change both IF and DF to field 0|
|`RIF`  |6224 |read instruction field: OR IF with bits 6-8 of AC|
|`BSW`  |7002 |exchange the high and low 6 bits of AC|
|`CAM`  |7621 |clear AC and MQ|

The first six operations require some explanation. SABR tries to present
a flat memory model to the user, which means that if you write something
like `TAD I VAL` it doesn’t emit a single instruction like simpler PDP-8
assemblers will. These PAL8 emulating op-codes allow the programmer to
bypass this behavior of SABR when it isn’t helpful. See the
documentation on SABR link generation in the OS/8 Handbook.

[os8hac]: https://archive.org/details/bitsavers_decpdp8os8_39414792/page/n875


## Conclusion

This is a somewhat limited manual which attempts to give an outline of a
very simple compiler for which we apologise as the source code is
obscure and badly commented. However, the native OS/8 compiler/tokeniser
(`n8.c`) is only 600 lines which is a nothing in the scale of things
these days.  However, we hope this project gives some insight into
compiler design and code generation strategies to target a most
remarkable computer. We would also like to give credit to the builders
of OS/8 and in particular the FORTRAN II system which was never designed
to survive the onslaught of this kind of modern software.

Don’t expect too much! This compiler will not build this week’s bleeding
edge kernel. But, it may be used to build any number of useful utility
programs for OS/8.


## License

This document is under the [GNU GPLv3 License][gpl], copyright © May,
June, and November 2017 by [Ian Schofield][ian], with later improvements
by [Warren Young][wy] in 2017 and 2019.

[gpl]: https://www.gnu.org/licenses/gpl.html
[ian]: mailto:Isysxp@gmail.com
[wy]:  https://tangentsoft.com/
