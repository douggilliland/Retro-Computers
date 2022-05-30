# Using the Examples

This directory contains several example programs. We will use the
`calc.c` example throughout this section.

The program may be compiled using the cc8 cross-compiler to SABR sources
like so:

    $ cc8 calc.c

You can then use the `txt2ptp` program to turn the resulting `calc.sb`
file into a paper tape to be loaded into OS/8:

    $ txt2ptp < calc.sb > calc.pt
    $ pidp8i             ⇠ ...start PDP-8 sim somehow, then hit Ctrl-E
    sim> att ptr calc.pt
    sim> cont
    .R PIP
    *CALC.SB<PTR:        ⇠ hit Enter, then Escape twice

The <kbd>Enter</kbd> key starts the transfer in the final command. The
transfer stops when `PIP` sees the <kbd>Ctrl-Z</kbd> EOF marker added to
the end of the paper tape by `txt2ptp`. The first <kbd>Escape</kbd>
finalizes the transfer and the second exits PIP, returning you to the
OS/8 command prompt.

See the [assembly examples' `README.md` file][aerm] or the [U/W FOCAL
manual supplement][uwfs] for more ideas on how to get text files like
this SABR file into OS/8.

However you manage it, you can then assemble, load, and run the programs
on the OS/8 side with:

    .COMP CALC.SB
    .R LOADER
    *CALC,LIBC/I/O/G     ⇠ press Esc to execute command and exit LOADER

The `/G` flag causes the loader to run the linked program immediately,
but once you're done modifying the program, you probably want to save it
as a core image so it can be run directly instead of being linked and
loaded again each time. You can give `/M` instead, which finalizes the
link and then exits, printing a map file before it does so. You can then
save the result where the OS/8 `R` command can find it with:

    .SAVE SYS:CALC

That produces `SYS:CALC.SV`, which an `R CALC` command will load and
run.

The `/I` and `/O` flags might not be strictly necessary, depending on
what kind of I/O your C program does.  See the OS/8 FORTRAN II manual's
information on device-independent I/O for more on this.

If you wish to compile from C source code on the OS/8 side rather than
cross-compile, I recommend using the `CC.BI` wrapper rather than running
the compiler directly:

    .EXE CCR
    >calc.c

Note that it tolerates lowercase input.

See [the CC8 manual][ccmn] for more information.


[aerm]: /doc/trunk/examples/README.md
[ccmn]: /doc/trunk/doc/cc8-manual.md
[uwfs]: /doc/trunk/doc/uwfocal-manual-supp.md


# The Examples

In order of complexity, they are:

## calc.c

This is a simple 4-function calculator.


## ps.c

This prints several levels of [Pascal's triangle][pt].

[pt]: https://en.wikipedia.org/wiki/Pascal%27s_triangle


## fib.c

This program calculates [Fibonacci humbers][fn], which implicitly
demonstrates the C compiler's ability to handle [recursion][rec].

[fn]:  https://en.wikipedia.org/wiki/Fibonacci_number
[rec]: https://en.wikipedia.org/wiki/Recursion_(computer_science)


## basic.c

A very simple BASIC interpreter. This program tests a broad swath of the
compiler's functionality.
