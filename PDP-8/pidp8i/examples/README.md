# Example Programs

## What's Provided

The `examples` directory holds short example programs for your PiDP-8/I,
plus a number of subroutines you may find helpful in writing your own
programs:

| Example           | What It Does
-----------------------------
| `add.pal`         | 2 + 3 = 5  The simplest program here; used below as a meta-example
| `hello.pal`       | writes "HELLO, WORLD!" to the console; tests PRINTS subroutine
| `pep001*`         | Project Euler Problem #1 solutions, various languages
| `routines/decprt` | prints an unsigned 12-bit decimal integer to the console
| `routines/prints` | prints an ASCIIZ string stored as a series of 8-bit bytes to the console

The `pep001.*` files are a case study series in solving a simple
problem, which lets you compare the solutions along several axes. Some
are much longer than others, but some will run faster and/or take less
memory. It is interesting to compare them. There are writeups on each of
these:

*   [**`pep001.pal`**][pal] — PAL8 Assembly Language
*   [**`pep001.bas`**][bas] — OS/8 BASIC
*   [**`pep001-*.c`**][c] — two solutions for the CC8 dialects of C
*   [**`pep001.fc`**][fc] — U/W FOCAL
*   [**`pep001-f?.ft`**][ft] — FORTRAN II and IV

[pal]:  https://tangentsoft.com/pidp8i/wiki?name=PEP001.PA
[bas]:  https://tangentsoft.com/pidp8i/wiki?name=PEP001.BA
[c]:    https://tangentsoft.com/pidp8i/wiki?name=PEP001.C
[fc]:   https://tangentsoft.com/pidp8i/wiki?name=PEP001.FC
[ft]:   https://tangentsoft.com/pidp8i/wiki?name=PEP001.FT


## How to Use the BASIC Examples

Here's one way to run the `pep001.ba` program mentioned above:

    .R BASIC
    NEW OR OLD--NEW
    FILE NAME--PEP001.BA

    READY
    10 FOR I = 1 TO 999
    10 FOR I = 1 TO 999
    20 A = I / 3 \ B = I / 5
    30 IF INT(A) = A GOTO 60
    40 IF INT(B) = B GOTO 60
    50 GOTO 70
    60 T = T + I
    70 NEXT I
    80 PRINT "TOTAL: "; T
    90 END
    SAVE

    READY
    RUN

    PEP001  BA    5A

    TOTAL:  xxxxxxx

    READY
    BYE

While you could simply type all of that, if you're SSH'd into the
PiDP-8/I, you could instead just copy-and-paste the bulk of the text
above into OS/8 BASIC from the `examples/pep001.ba` file on the host
side. This and several more useful methods are given in the companion
article [Getting Text In][gti].

Other methods given in that article let you create the `PEP001.BA` file
on the OS/8 disk first, allowing you to load it up within OS/8 BASIC
like so:

    .R BASIC
    NEW OR OLD--old pep001.ba

Notice that you can give the file name with the `NEW` or `OLD` command
above, rather than wait for OS/8 BASIC to prompt you for it separately.
Also notice that our version of OS/8 BASIC has a patch applied to it by
default which allows it to tolerate lowercase input. (This patch may be
disabled by giving the [`--lowercase` option to the `configure`
script][lcopt].)


I obscured the output in the first terminal transcript above on purpose,
since I don't want this page to be a spoiler for the Project Euler site.

If you get a 2-letter code from BASIC in response to your `RUN` command,
it means you have an error in the program. See the BASIC section of the
OS/8 Handbook for a decoding guide.

[gti]:   https://tangentsoft.com/pidp8i/wiki?name=Getting+Text+In
[lcopt]:  https://tangentsoft.com/pidp8i/doc/trunk/README.md#lowercase


## How to Use the Assembly Language Examples

For each PAL8 assembly program in `src/asm/*.pal` or `examples/*.pal`,
the build process produces several output files:

| Extension       | Meaning
| --------------- | ---------------
| `*.pal`         | the PAL8 assembly source code for the program; input to the process
| `obj/*.lst`     | the human-readable assembler output
| `bin/*-pal.pt`  | the machine-readable assembler output (RIM format)
| `boot/*.script` | a SIMH-readable version of the assembled code

Each of those files has a corresponding way of getting the example
running in the simulator:

1.  Transcribe the assembly program text to a file within a PDP-8
    operating system and assemble it inside the simulator.

2.  Toggle the machine code for the program in from the front panel. I
    can recommend this method only for very short programs.

3.  Attach the `*-pal.pt` file to the simulator and read the assembly
    language text in, such as via the PiDP-8/I [automatic media mounting
    feature][howto].

4.  Boot SIMH with the example in core, running the program immediately.

I cover each of these options below, in the same order as the list
above.


### Option 1: Transcribing the Assembly Code into an OS/8 Session

Perhaps the most period-correct of the options given here is to
transcribe [`examples/add.pal`][pal] into the OS/8 simulation on a
PiDP-8/I using the OS/8 `EDIT` program:

    .R EDIT
    *ADD.PA<

    #A                          ← append to ADD.PA
    *0200   CLA CLL
    MAIN,   TAD A
            TAD B
            DCA C
            HLT
    A,      2
    B,      3
    C,
                                ← hit Ctrl-L to leave text edit mode
    #E                          ← saves program text to disk

    .PAL ADD-LS
    ERRORS DETECTED: 0
    LINKS GENERATED: 0

    .DIR ADD.* /A

    ADD   .PA   1             ADD   .BN   1             ADD   .LS    1

     399 FREE BLOCKS

If you see some cryptic line from the assembler like `DE C` instead
of the `ERRORS DETECTED: 0` bit, an error has occurred. Table 3-3 in
my copy the OS/8 Handbook explains these. You will also have an `ADD.ER`
file explaining what happened.

You can instead say `EXE ADD` to assemble and execute that program in a
single step, but beware that because the program halts the processor,
your OS/8 session also halts. If you take the opportunity as intended to
examine memory location `C` — 0207 — pressing `Start` to resume will
cause the processor to try executing the instruction at 0210, and who
knows what that will do? Even if you pass up the opportunity to examine
`C`, pressing `Start` immediately after the halt will do the same,
except that we know what it will do: it will try to execute the 0002
value stored at `A` as an instruction! (I believe it means `AND` the
accumulator with memory location 2.)

The solution to these problems is simple:

    .EDIT ADD                   ← don't need "R" because file exists
    #R                          ← read first page in; isn't automatic!
    #4D                         ← get rid of that pesky DCA line
    #5I                         ← insert above "A" def'n, now on line 5
            JMP 7600            ← Ctrl-L again to exit edit mode
    #E                          ← save and exit

    .EXE ADD

As before, the processor stops, but this time because we didn't move the
result from the accumulator to memory location `C`, we can see the
answer on the accumulator line on the front panel. Pressing `Start` this
time continues to the next instruction which re-enters OS/8. Much nicer!

This option is the most educational, as it matches the working
experience of PDP-8 assembly language programmers back in the day. The
tools may differ — the user may prefer [`TECO`][teco] over `EDIT` or
[MACREL][macrel] over [PAL8][pal8] — but the idea is the same
regardless.

There are [many more methods][gti] for getting program text into the
simulator than simply transcribing it into an `EDIT` or `TECO` session.

[macrel]: https://tangentsoft.com/pidp8i/wiki?name=A+Field+Guide+to+PDP-8+Assemblers#macrel
[pal8]:   https://tangentsoft.com/pidp8i/wiki?name=A+Field+Guide+to+PDP-8+Assemblers#pal8
[teco]:   https://en.wikipedia.org/wiki/TECO_(text_editor)


### Option 2: Toggling Programs in Via the Front Panel

One of the automatic steps in building the PiDP-8/I software is that
each of the `examples/*.pal` and `src/asm/*.pal` files are assembled by
`palbart` which writes out a human-readable listing file to `obj/*.lst`,
each named after the source file.

Take [`obj/add.lst`][lst] as an example, in which you will find three
columns of numbers on the code-bearing lines:

    10 00200 7300
    11 00201 1205
    12 00202 1206
    13 00203 3207
    14 00204 7402
    16 00205 0002
    17 00206 0003

The first number refers to the corresponding line number in
[`add.pal`][pal], the second is a PDP-8 memory address, and the third is
the value stored at that address.

To toggle the `add` program in, press `Stop` to halt the processor, then
twiddle the switches like so:

| Set SR Switches To... | Then Toggle... | Because...
|--------------------------------------- | ----------
| 000 010 000 000       | `Load Add`     | 000010000000 is binary for octal 0200, the program's start address
| 111 011 000 000       | `Dep`          | the first instruction, 7300 octal, is 111011000000 in binary
| 001 010 000 101       | `Dep`          | 1205 octal in binary
| 001 010 000 110       | `Dep`          | etc, etc.
| 011 010 000 111       | `Dep`          |
| 111 100 000 010       | `Dep`          |
| 000 000 000 010       | `Dep`          |
| 000 000 000 011       | `Dep`          |

To run it, repeat the first step in the table above, loading the
program's starting address (0200) first into the switch register (SR)
and then into the PDP-8's program counter (PC) via `Load Add`. Then
toggle `Start` to run the program.

If you then toggle 000 010 000 111 into SR, press `Load Add` followed by
`Exam`, you should see 000 000 000 101 in the fourth row of lights — the
Accumulator — that being the bit pattern for "five" at memory location
0207, the correct answer for "2 + 3", the purpose of `add.pal`. You
could load that address back up again and `Dep` a different value into
that location, then start the program over again at 0200 to observe that
this memory location does, indeed, get overwritten with 0005.

We only need one `Load Add` operation in the table above because all of
the memory addresses in this program are sequential; there are no jumps
in the values in the second column. Not all programs are that way, so
pay attention!

Beware that this program does not contain an explicit value for memory
location 0207 at the start, but it does overwrite this location with the
answer, since location `C` is defined as having the address just after
the last value you entered via SR above, 0206. That is the source of the
"07" in the lower two digits of the fourth instruction, 3207.


### Option 3: Loading a Program from Paper Tape

The `palbart` assembly process described above also produces paper tape
output files in RIM format in `bin/*-pal.pt`.

One way to load these assembly examples into your PiDP-8/I is to copy
each such file to a USB stick, one file per stick. Then, use the
automatic USB media mounting feature of the PiDP-8/I to attach it to the
simulator.

The following is distilled from the [How to Use the PiDP-8/I][howto]
section of the PiDP-8/I documentation:

1.  Set the IF switches (first white group) to 001, and toggle `Sing
    Step` to reboot the simulator into the high-speed RIM loader. If the
    simulator wasn't already running, restarting the simulator with IF=1
    will achieve the same end as toggling `Sing Step` while it's
    running. Reset the IF switches to 0.

2.  Insert the USB stick containing the `*-pal.pt` file you want to load
    into the Pi.

3.  Set the DF switches (first brown group) to 001, then toggle `Sing
    Step` again. This attaches the tape to the high-speed paper tape
    reader peripheral within the PDP-8 simulator. Set DF back to 0.

4.  Set the switch register (SR) to 7756 (111 111 101 110) then press
    `Load Add`, then `Start`.

5.  Hit `Stop`, then reset SR to 0200 (000 010 000 000), that being the
    starting location of these example programs. Press `Load Add`, then
    `Start` to run the program.

There is an SVG template for USB stick labels in the distribution under
the [`labels/`][label] directory, for use if you find yourself creating
long-lived USB sticks. See [`labels/README.md`][lread] for more
information.

This USB method is most convenient for often-reused binary media images.


### Option 4: Booting SIMH with the Example in Core

Another step in the PiDP-8/I software build process produces a
`boot/*.script` file for each `obj/*.lst` file produced. These files are
direct translations of the machine code from the assembler's listing
file into SIMH `deposit` commands, populating the simulated PDP-8's core
memory with the program's machine code. Each script ends with a jump to
the start of the program.

You can thus load and run each example at the Linux command line with a
command like this:

    $ bin/pidp8i-sim boot/add.script

That runs the `examples/add.pal` program's assembled binary code under
the simulator, just as if you'd loaded it there with option #3 above.


## License

Copyright © 2016-2018 by Warren Young. This document is licensed under
the terms of [the SIMH license][sl].


[lst]:   https://tangentsoft.com/pidp8i/doc/trunk/examples/add.lst
[pal]:   https://tangentsoft.com/pidp8i/doc/trunk/examples/add.pal
[label]: https://tangentsoft.com/pidp8i/dir?ci=trunk&name=labels
[lread]: https://tangentsoft.com/pidp8i/doc/trunk/labels/README.md
[howto]: http://obsolescence.wixsite.com/obsolescence/how-to-use-the-pidp-8
[sl]:    https://tangentsoft.com/pidp8i/doc/trunk/SIMH-LICENSE.md
