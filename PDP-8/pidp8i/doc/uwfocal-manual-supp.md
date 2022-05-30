# U/W FOCAL Manual Supplement for the PiDP-8/I

## Introduction

This document is a supplement to the [U/W FOCAL Manual][uwfm]. ("The
Manual") Although it is not a complete FOCAL tutorial — much less a
reference guide! — we suggest that you start learning about our
distribution of FOCAL by skimming through this document *first*, then
proceeding to [the Manual][uwfm], since this document will alert you to
the areas of the Manual that are simply incorrect for the PiDP-8/I
distribution of U/W FOCAL. Having gotten through the Manual, come back
here and re-read this supplement more carefully; you will get more out
of this supplement on that second pass with the context from the Manual.

Other helpful sources are the [U/W FOCAL reference cards][uwfr], the
[U/W FOCAL DECUS submission][uwfd], the [DECUS and OMSI manuals for PS/8
FOCAL, 1971][f71], and the [DEC FOCAL-8 Manual][df8]. To a first
approximation, those are ordered in decreasing degree of application to
our distribution of U/W FOCAL. The final document in that series is
still quite useful for understanding U/W FOCAL, however.

See [below](#rationale) for the reasons why we felt it was necessary to
write this document.


## <a id="starting" name="stopping"></a>Starting and Stopping U/W FOCAL

The section "Starting the Program" in [the Manual][uwfm] is entirely
concerned with loading U/W FOCAL from paper tape using the front panel
and the BIN loader.

The PiDP-8/I software project does not currently ship U/W FOCAL in SIMH
paper tape image form. Instead, it's installed by default on the OS/8
system disk, which greatly simplifies starting it:

     .R UWF16K

Yes, that's all. You're welcome. `:)`

To get back to OS/8, just hit <kbd>Ctrl-C</kbd>.


## <a id="loading" name="saving"></a>Loading and Saving Programs

There are many ways to get program text into U/W FOCAL other than simply
typing it in. This section gives several methods, because each may be of
use to you in different circumstances. Some of them may not be of direct
use to you, but may open your eyes to techniques that may be useful to
you in other contexts, so we encourage you to read this entire section.


### <a id="ls-pasting"></a>Pasting Text in from a Terminal Emulator

#### The Na&iuml;ve Way

If you are SSHing into your PiDP-8/I, you might think to write your
FOCAL programs in your favorite text editor on your client PC then copy
and paste that text into U/W FOCAL over SSH. That won't work.
We believe it is because of the way U/W FOCAL handles
terminal I/O and interrupts, being written with the assumption that
such input is coming from a 110 bps Teletype or at most a 300 bps
“high-speed” paper tape reader. If you try this over a modern gigabit
class SSH connection, the input ends up trashed in FOCAL.


#### <a id="ls-pip"></a>The Way That Works

"But I really really want to write my FOCAL programs in [my favorite
text editor][mfte] and paste them into my PiDP-8/I," I hear you say.
Dispair not. There is a path. Follow.

The problem affecting U/W FOCAL which prevents it from handling input at
modern paste-through-SSH speeds doesn't affect OS/8 itself, so we'll use
it as an intermediary:

    .R PIP
    *HELLO.DA<TTY:                  ⇠ use default extension for O I
    01.10 TYPE "Hello, world!"!     ⇠ paste your program text here
    ^Z                              ⇠ hit Ctrl-Z to tell PIP it's reached end-of-file (EOF)
    *$                              ⇠ hit Escape to return to OS/8 from PIP ($ = Esc)
    .R UWF16K                       ⇠ run U/W FOCAL
    *O I HELLO                      ⇠ open text file for input; "types" pgm in for us
    _G                              ⇠ underscore = EOF seen, G starts program
    Hello, world!                   ⇠ and it runs!

That is, we use OS/8's `PIP` command to accept text input from the
terminal (a.k.a. TTY = teletype) and write it to a text file. Then we
load that text in as program input using commands we'll explain in
detail [below](#ls-write).

[mfte]: https://duckduckgo.com/?q=%22my+favorite+text+editor%22


### <a id="ls-punch"></a>The `PUNCH` Command

When [the Manual][uwfm] talks about loading and saving programs, it is
in terms of the `PUNCH` command, which punches the current program out
on paper tape, because the Manual was written for the paper tape based
version of U/W FOCAL.

The PiDP-8/I software project ships the OS/8 version of U/W FOCAL
instead, which doesn't even have a `PUNCH` command. (We get the [`PLOT`
command](#miss-hw) instead.)

Even if it did work, mounting and unmounting simulated paper tapes under
SIMH is a bit of a hassle. We can do better.


### <a id="ls-library"></a>The `LIBRARY` Command

The effective replacement for `PUNCH` in the OS/8 version of U/W FOCAL
is the `LIBRARY` command.

If you've read [the Manual][uwfm], you may be wondering if it's
overloaded with `LINK` and `LOOK`, but no: those commands are apparently
missing from the OS/8 version. (Open question: how do you use multiple
fields of core for program code with the OS/8 version, then?)

Briefly, then, I'll show how to use some of these commands:

    .R UWF16K                           ⇠ start fresh
    *1.10 TYPE "Hello, world!"!         ⇠ input a simple one-line program
    *L S HELLO                          ⇠ write program to disk with LIBRARY SAVE
    *L O HELLO                          ⇠ verify that it's really there
    HELLO .FD   1                       ⇠ yup, there it is!
    *E                                  ⇠ ERASE all our hard work so far
    *W                                  ⇠ is it gone?
    C U/W-FOCAL:  16K-V4  NO/DA/TE      ⇠ goneski
    *L C HELLO                          ⇠ load it back in with LIBRARY CALL
    *W                                  ⇠ did it come back?
    C U/W-FOCAL:  HELLO   NO/DA/TE

    01.10 TYPE "Hello, world!"!         ⇠ yay, there it is!
    *L D HELLO                          ⇠ nuke it on disk; it's the only way to
    *L O HELLO                          ⇠ ...be sure
    *                                   ⇠ Houston, we have no program

See the [DECUS submission][uwfd] and `CARD2.DA` in the [refcards][uwfr]
for more examples.


### <a id="ls-write"></a>The `WRITE` Command

U/W FOCAL's `LIBRARY` command saves programs as core images, which are
a) non-relocatable; and b) non-portable to other versions of FOCAL. We
can fix both of these problems by saving the program to an ASCII text
file instead.

With a program already typed in or loaded from disk:

    *O O HELLO; W; O C

All of that has to be on a single line, with the semicolons. If you give
these three commands separately, you end up with the `WRITE` command as
the first line in the output file and the `OUTPUT CLOSE` command as the
last; you must then either edit those commands out of the output file or
tolerate having FOCAL run those two commands again every time you load
the program from disk.

What this does is opens a data output file (extension `.DA`) and makes
it the output destination, so that the following `WRITE` command sends
its text there, and then it is immediately closed with `O C`, returning
control back to the terminal.

You can then load that program back into U/W FOCAL with the same command
we used above with the `PIP` solution:

    *O I HELLO

If you `TYPE` that file from OS/8, you might be wondering why the banner
line doesn't cause a problem on loading the file back in:

    C U/W-FOCAL:  HELLO   NO/DA/TE

That leading `C` causes U/W FOCAL to treat it as a comment. Since we're
in "direct mode" at that point, the comment is simply eaten.


### <a id="ls-ptr"></a>The Paper Tape Reader

Above, I warned you off trying to save programs to simulated paper tape
via the `PUNCH` command, but what about *reading* programs back in? You
can do that, but it's trickier than you might guess.

First, if you've read [the Manual][uwfm], you may think to attach a
paper tape to SIMH then use U/W FOCAL's `OPEN READER` command, but as
with `PUNCH`, that command has been replaced in this version of U/W
FOCAL. With the removal of paper tape support in U/W FOCAL proper, they
felt free to reassign `O R` to `OPEN RESTART/RESUME`.

Thus, we again have to pop back out to OS/8 and use PIP to pull this
off.

First we must create that paper tape. If you place your FOCAL source
code in `examples/*.fc`, you can simply type `make` at the top level of
the PiDP-8/I source tree to have it translated to `bin/*-focal.pt` with
the same base name.

(This is done by Bill Cattey's `txt2ptp` program; there is also the
inverse filter, `ptp2txt`. We include the `-focal` tag to distinguish
these files from `*-pal.pt` files produced from `*.pal` source files by
a similar process.)

We'll work with the provided `examples/tratbl.fc` example program,
which got translated to `bin/tratbl-focal.pt` when the PiDP-8/I software
was built.

To attach that paper tape to SIMH's paper tape reader device, hit
<kbd>Ctrl-E</kbd> to get to the SIMH command prompt, then:

    sim> att ptr bin/tratbl-focal.pt
    sim> c

On re-entering the simulator with the `c` ("continue") command, we can
read that tape into OS/8:

    .R PIP
    *TRATBL.DA<PTR:                    ⇠ hit Esc *then* Enter
    .TYPE TRATBL.DA

If the final command doesn't show you the program text you expect,
something went wrong in the process above. There are a couple of likely
possibilities:

1.  You hit <kbd>Enter</kbd> at the end of the PIP command, either
    instead of <kbd>Esc</kbd> or *before* hitting <kbd>Esc</kbd>.
    
    If you do it right, it should appear on screen as:

        *TRATBL.DA<PTR:$^

    with the `$^` appearing when you hit <kbd>Esc</kbd>, signifying that
    it has read the paper tape and hit the end. Hitting <kbd>Enter</kbd>
    should then drop you back to the OS/8 prompt, not leave you in
    `PIP`. If you get another `*` prompt from `PIP` on hitting
    <kbd>Enter</kbd>, you fat-fingered something. Try again.

2.  Every time you cause the PDP-8 to read the paper tape, you must
    re-attach it to SIMH to read it again.  Neither SIMH nor OS/8 warns
    you if you try to read from the paper tape reader with nothing
    attached; you just get no input.

    This mimics what happens with real paper tapes: once the reader has
    read the tape, it falls out of the machine and needs to be fed back
    in to be read again. The difference between the real paper tape
    reader and SIMH is that that repeated sequence is much more of a
    hassle than just sticking the tape back in the reader:

        .<Ctrl-E>
        sim> ATT PTR ...
        sim> C

    That `TTY:` based `PIP` method above will start to look awfully
    attractive after a while...

Once you make it through that gauntlet, loading the ASCII program text
into U/W FOCAL is just as above: `O I TRATBL`.


## <a id="lowercase"></a>Lowercase Input

The version of U/W FOCAL we include by default on the PiDP-8/I's OS/8
system disk copes with lowercase input only within a fairly narrow
scope. The fact that it copes with lowercase input at all is likely due
to the fact that the version we ship was released late in the commercial
life of OS/8, by which time lowercase terminals were much more common
than at the beginning of OS/8's lifetime.

The examples in [the Manual][uwfm] are given in all-uppercase, which
means there is no reason you would immediately understand how U/W FOCAL
deals with lowercase input, having no examples to build a mental model
from. If you just guess, chances are that you will be wrong sooner or
later, because U/W FOCAL's behavior in this area can be surprising!

The two main rules to keep in mind are:

1.  U/W FOCAL is case-sensitive for variable and built-in function
    names, but it is case-insensitive for command names.

2.  U/W FOCAL doesn't support lowercase variable and function names. It
    may sometimes appear to work, but internally, U/W FOCAL isn't doing
    what you want it to.

The following gives incorrect output because of a violation of rule 1:

    *type fsin(pi/2)!
     0.000000000E+00*

The correct answer is 1. It fails because there is no built-in function
called `fsin` nor a built-in constant `pi`.

FOCAL gives an answer here instead of detecting our failure to call
things by their right names because it is falling back to its rule to
use a value of 0 where no value or function is available to do what you
asked. Zero divided by 2 is 0; then it tries to subscript a nonexistent
`fsin` variable with index 0, so it punts and gives the answer you see
above, zero.

A better language would have detected your errors and given a
diagnostic, but U/W FOCAL is implemented in less than a page of PDP-8
core memory, roughly the same number of bytes as
[Clang](http://clang.llvm.org/) gives when compiling an empty C program
on the machine I'm typing this on. The fact that U/W FOCAL detects
errors *at all* is somewhat impressive.

To get the expected result, call the `FSIN` function and use the `PI`
constant, which are very much not the same thing as `fsin` and `pi` to
FOCAL:

    *type FSIN(PI/2)!
     1.000000000E+00

U/W FOCAL doesn't care that you gave the `type` command in lowercase,
but it *does* care about the case of the function and variable names.

U/W FOCAL's tolerance of lowercase in command names doesn't extend to
arguments. In particular, the `OPEN` command's argument must be
uppercase: `o o` doesn't work, nor does `O o`, but `o O` does.

Violating rule 2 can be even more surprising:

    .R UWF16K               ⇠ We need a fresh environment for this demo.
    *s a=1                  ⇠ What, no error?  I thought you said...
    *s b=2
    *s c=3
    *type $ !
    *

No, that transcript isn't cut off at the end: the `TYPE` command simply
doesn't give any output! Why?

The reason is that U/W FOCAL can't \[currently\] cope with lowercase
variable names.

But wait, it gets weird:

    *s A=1
    *s foo=42
    *type $ !
    A (+00) 1.000000000E+00
    &/(+00) 4.200000001E+01

We now see output for our uppercased `A` variable, but what is that `&/`
noise? Apparently "`foo`" somehow gets mangled into `&/` by FOCAL's
command parser.

We have not yet tried to investigate the reason `foo` gets saved into a
mangled variable name and `a`, `b`, and `c` above do not, because the
workaround is simple: keep <kbd>CAPS LOCK</kbd> engaged while typing
FOCAL programs except when typing text you want FOCAL to send back out
to the terminal:

    *1.1 TYPE "Hello, world!"!
    *G
    Hello, world!

See the [Variables section][vars] of [`CARD2.DA`][card2] for more
information on variable naming.

[card2]: uwfocal-refcards.md#card2
[vars]:  uwfocal-refcards.md#variables


## <a id="output-format"></a>Default Output Format

FOCAL is primarily a scientific programming language. That, coupled with
the small memory size of the PDP-8 family and the slow terminals of the
day mean its default output format might not be what you initially
expect. Consider these two examples pulled from the [U/W FOCAL
Manual][uwfm]:

    *TYPE FSGN(PI), FSGN(PI-PI), FSGN(-PI) !
     1.000000000E+00 0.000000000E+00-1.000000000E+00
    *TYPE 180*FATN(-1)/PI !
    -4.500000000E+01

This may raise several questions in your mind, such as:

1.  Why is there no space between the second and third outputs of the
    first command?

2.  Why does the ouptut of the first command begin in the second column
    and the second begin at the left margin?

3.  Is the second command giving an answer of -4.5°?

If you've read the U/W FOCAL Manual carefully, you know the answer to
all three of these questions, but those used to modern programming
environments might have skimmed those sections and thus be surprised by
the above outputs.

The first two questions have the same answer: U/W FOCAL reserves space
for the sign in its numeric outputs even if it doesn't end up being
needed. This was done, no doubt, so that columns of positive and
negative numbers line up nicely. It might help to see what's going on if
you mentally replace the spaces in that first output line above with `+`
signs.

This then explains the apparent discrepancy between the first and second
commands' outputs: the first output of the first command is positive,
while the second command's output is negative, so there is a space at
the beginning of the first output for the implicit `+` sign.

As for the third question, the default output format is in scientific
notation with full precision displayed: 4.5&times;10¹ = 45 degrees, the
correct answer.


### Improving the Output Format

The following changes to the examples as given in [the Manual][uwfm]
show how you can get output more suitable to your purposes:

    *TYPE %1, FSGN(PI):5, FSGN(PI-PI):5, FSGN(-PI)!
     1    0    -1

That sets the output precision to 1 significant digit, which is all we
need for the expected {-1, 0, -1} ouptut set. The tabstop formatting
options (`:5`) put space between the answers, but there is a trick which
gives similar output with a shorter command:

    *TYPE %5.0, FSGN(PI), FSGN(PI-PI), FSGN(-PI)!
         1     0    -1

That tells it to use 5 significant digits with zero decimal digits.
Since the answers have only one significant digit, FOCAL right-justifies
each output with 4 spaces. There are 5 spaces between the `1` and `0`
outputs because of that pesky implicit `+` sign, though.

The second example above can be improved thus:

    *TYPE %3.2, 180*FATN(-1)/PI !
    -45.0

That tells FOCAL to display 3 significant digits, and to include up to 2
decimal places even if the traling one(s) would be 0, thus showing all 3
significant digits in an answer expected in degrees. If you'd wanted 4
significant digits with any trailing zeroes instead, you'd give `%4.3`
instead. If you'd given `%3`, the output would be `-45`, the trailing
zero being deemed unnecessary.


## <a id="ascii"></a>ASCII Character & Key Names

Many of the common names for keys and their ASCII character equivalents
have shifted over the years, and indeed they shifted considerably even
during the time when the PDP-8 was a commercially viable machine. The
following table maps names used in [the Manual][uwfm] to their decimal
ASCII codes and their common meaning today.

| Old Name    | ASCII | Current Name  |
| ----------- | ----- | ------------- |
| `RUBOUT`    | 127   | Delete or Del |
| `BACKARROW` | 95    | Underscore    |
| `UNDERLINE` | 95    | Underscore    |

Beware that the ASCII values above differ from the values given in the
U/W FOCAL Manual Appendix "Decimal Values for All Character Codes."
FOCAL sets the 8th bit on ASCII characters for reasons unimportant here.
Just add 128 to the values above if you need to get the FOCAL
equivalent.

Some terminals and terminal emulator software may remap Backspace and
Delete, either making one equivalent to the other or swapping them.
Without such remapping, if you hit the key most commonly marked
Backspace on modern keyboards, U/W FOCAL will just insert an ASCII
character 8 at that point in the program entry, almost certainly not
what you want. You either need to remap Backspace to Delete or hit the
key most commonly marked Del.

The U/W FOCAL Manual also references keys that used to appear on some
terminals, most especially teletypes, which no longer appear on modern
keyboards:

| Teletype Key | Modern Equivalent |
| ------------ | ----------------- |
| `LINE FEED`  | <kbd>Ctrl-J</kbd> |
| `FORM FEED`  | <kbd>Ctrl-L</kbd> |


## <a id="overloading"></a>Command Overloading

[The Manual][uwfm] tells you right up front that U/W FOCAL only pays
attention to the first letter of each command when trying to decide what
you're asking it to do, which is why we have strange commands like
`YNCREMENT`: `I` was already taken by `IF`.

What it *doesn't* make as clear is how the creators of U/W FOCAL began
adding a second layer of overloading to this scheme after they began
running out of letters in the English alphabet.

Early examples of FOCAL's command overloading scheme are the `ON`,
`OPEN` and `OUTPUT` commands. By looking at the first argument to the
command, FOCAL can tell which of the three you mean. If you give a valid
FOCAL expression in parentheses, it is clearly an `ON` command. If you
give anything beginning with a letter, FOCAL decides whether it's an
`OPEN` or `OUTPUT` command based on which letter that is; you will
notice that the first letter of no `OPEN` sub-command is the same as the
first letter of any `OUTPUT` sub-command.

In later versions of U/W FOCAL, they added a third level to some
commands. We have `OPEN RESTART READ` and `OPEN RESUME INPUT`, for
example. It may help to abbreviate the commands, as the first letter of
each word is all that really matters: `O R R` is clearly not the same as
`O R I`.

There are other examples of this, such as `LIBRARY` and `LIST`. It is
the first letter of the first argument to these commands that determines
what FOCAL does.

In at least one case, you can see this feature of FOCAL used to talk
about a single command under different names. Some FOCAL documents talk
about a `ZVR` command, meaning Zero VaRiable. It's just another way of
spelling the `ZERO` command: it does the same thing.

FOCAL *only* checks the first letter of the command and any necessary
disambiguating arguments. The following is therefore a perfectly legal
FOCAL program:

    01.10 SPEW I = 0
    01.20 YGGDRASIL I
    01.30 LOOGIE BRAIN 1.2 ; TARPIT I !

It does exactly the same thing as a program we will encounter
[shortly](#lbranch).


## <a id="library"></a>`LIBRARY`

The OS/8 version of U/W FOCAL includes a "library" feature modeled on a
similar feature in OMSI PS/8 FOCAL. These features collectively allow
the user access to FOCAL program files stored in the OS/8 file system
from within a U/W FOCAL program or as immediate commands to U/W FOCAL.

We showed how you can use some of these commands to save and load
programs to disk [above](#ls-library), but there's a lot more to it.
Coverage of this begins on page 34 of [the DECUS submission][uwfd].


## `LIST ALL`, `LIST ONLY`, `ONLY LIST`

These commands allow you to get OS/8 directory listings from within U/W
FOCAL:

*    **<code>LIST ALL</code>** — Same as `DIR` under OS/8. Accepts an
     optional OS/8 device name, e.g. `L A SYS:` to show the contents of the
     `SYS:` device.

*    **<code>LIST ONLY</code>** — Same as `DIR *.FC` under OS/8. You can
     also give a device name, a file name, or both to be more specific. For
     example, you could check for the existence of a `FOO.FC` file on
     the first half of the second RK05 device with `L O RKA1:FOO`.

*    **<code>ONLY LIST</code>** — Same as `LIST ONLY` except for FOCAL
     data files, `*.DA`. The [DECUS submission][uwfd] says it looks for
     `*.FD`, but that does not appear to be correct in my testing.


## <a id="lbranch"></a>`LOGICAL BRANCH`

Our distribution of U/W FOCAL includes the `LOGICAL BRANCH` feature,
which is not documented in [the Manual][uwfm], but it *is* documented on
page 37 of [the DECUS submission][uwfd]. Briefly, it acts like a `GOTO`
command where the jump is only made if keyboard input is detected.

The following program counts upward continuously until a key is pressed,
then it prints how many iterations it ran:

    01.10 SET I = 0
    01.20 YNCR I
    01.30 LOGICAL BRANCH 01.20 ; TYPE I !

The DECUS document suggests using this feature to turn the keyboard into
a giant "switch register," allowing the user to control the behavior of
a long-running program without stopping to wait for user input. Can you
say "video games"?


## <a id="lexit"></a>`LOGICAL EXIT`

Another addition to our version of U/W FOCAL as compared to the version
documented in [the Manual][uwfm] is `LOGICAL EXIT` which immediately
exits U/W FOCAL and returns you to OS/8, just as if you had hit
<kbd>Ctrl-C</kbd>.


## <a id="fsf"></a>FOCAL Statement Functions

This appears to be the same thing [the Manual][uwfm] calls Program
Defined Functions. Therefore, you may look on the material beginning on
page 63 of [the DECUS submission][uwfd] as just another take on the same
issue. Some of the examples are more enlightening than the one in the
manual. The first example in the DECUS submission, `F(EXP)`, is more
robustly coded than the same function in the Manual; comparing the two
is instructive.


## `FRA` Built-In Function

This function is not documented in [the Manual][uwfm], but it is
documented on page 60 of [the DECUS submission][uwfd]. It allows you to
set up random access to a file, storing numbers in various raw binary
formats directly to the file as if it were a large in-memory array.

If you've been trying to use the `FCOM` function but have run into the
limit on the size of a PDP-8 core memory field, switching to `FRA` is
the logical next step.


## <a id="front-panel"></a>Front Panel Differences

Whenever [the Manual][uwfm] refers to the PDP-8's front panel, it is
speaking generically of all the models it ran on as of October 1978. The
PDP-8 models introduced in the decade following the introduction of the
PDP-8/I differ in many ways, and one of the greatest areas of difference
is in their front panel controls and indicators. We do not intend to
fully document all of the differences here, but only to clarify the
differences brought up by the U/W FOCAL Manual.

You normally will not need to use the front panel with the OS/8 version
of U/W FOCAL we distribute with the PiDP-8/I software distribution since
you start and stop U/W FOCAL through OS/8 rather than the front panel.
However, we thought these matters could use clarification anyway.

Beyond this point, when we refer to the PDP-8/e, we also mean the 8/f,
which shared the same front panel design. We also include the 8/m, which
normally came with a minimal front panel, but there was an optional
upgrade for an 8/e/f style front panel. These three models are therefore
interchangeable for our purposes here.


### <a id="clear-regs"></a>`START` vs. `CLEAR` + `CONTINUE` vs. `RESET`

With the PDP-8/e, DEC replaced the `START` front panel switch of the
preceding PDP-8/I with a `CLEAR` switch. Why did they do this?

On a PDP-8/I, the difference between `START` and `CONTINUE` is sometimes
confusing to end users, since in many cases they appear to do the same
thing. Why have both? The difference is that `CONTINUE` simply resumes
operation from the current point in the program where it is stopped,
whereas `START` resets several key registers and *then* continues.

The PDP-8/e change splits this operation up to avoid the confusion: the
old `START` keypress is equivalent to `CLEAR` followed by `CONTINUE`.
(This pair of switches also has a `START` label above them, a clear
functional grouping.)

The U/W FOCAL Manual also speaks of a `RESET` switch in conjunction with
the FOCAL starting and restarting the computer. I haven't been able to
track down which PDP-8 model has such a switch yet, but for our purposes
here, I can say that it just means to load the starting address and hit
`START` on a PDP-8/I.


### <a id="if-df"></a>`EXTD. ADDR LOAD`

The PDP-8/e has many fewer switches on its front panel than the PDP-8/I,
yet it is a more functional machine. One of the ways DEC achieved this
is by removing the `IF` and `DF` switch groups and adding the
`EXTD. ADDR LOAD` switch, which lets you set the `IF` and `DF` registers
using the same 12-bit switch register used by the `ADDR LOAD` switch.

The `ADDR LOAD` switch on a PDP-8/e does the same thing as the
`Load Add` switch on a PDP-8/I.


### <a id="sw-dir"></a>Switch Direction

DEC reversed the meaning of switch direction between the PDP-8/I and the
PDP-8/e, and [the Manual][uwfm] follows the 8/e convention: on the 8/I,
up=0=off, whereas on the 8/e, up=1=on. Keep this in mind when reading
the U/W FOCAL Manual's references to front panel switch settings.


### <a id="sw-order"></a>Switch Ordering

When [the Manual][uwfm] talks about the switch register (SR), it numbers
the switches left to right, not by their logical bit number in the
switch register. That is, "Switch 0" is the leftmost (high order bit) SR
switch, not "bit 0" in the SR, which would be the rightmost SR switch.


## Error Codes

The [U/W FOCAL Manual][uwfm] gives a somewhat different error code table
than the one on `CARD4.DA` of the [U/W FOCAL reference cards][uwfr]. For
the most part, the latter is just a simple superset of the former, and
both apply. In some cases, though, the two tables differ, or one of them
differs from the `UWF16K` program we ship on the OS/8 system disk.


### `?18.32` vs `?18.42` — `FCOM` index out of range

The two error code tables give different error codes for this condition.
However, since I have not been able to get this error to happen, I do
not know which code is correct for our current version of FOCAL.


### `?31.<7` — Non-existent program area called by `LOOK` or `LINK`

Our current implementation of U/W FOCAL removed those commands in favor
of `LIBRARY`, so you can't make this one happen. An error in a `LIBRARY`
command is most likely to give `?26.07` instead.


### Irreproducible Errors

There are some errors listed in one or both tables that I have been
unable to cause, though I have tried:

| Code   | Meaning 
| ------ | -------
| ?07.44 | Operator missing or illegal use of an equal sign
| ?18.32 | `FCOM` index out of range (value given in the manual)
| ?18.42 | `FCOM` index out of range (value given on the refcard)
| ?27.90 | Zero divisor


### Untested Error Cases

I have not yet created programs large enough to test the "out of space"
codes `?06.41` (too many variables), `?10.50` (program too large),
`?13.65` (insufficient memory for `BATCH` operation), `?23.18` (too much
space requested in `OUTPUT ABORT` or `CLOSE`), `?23.37` (output file
overflow), and `?25.02` (stack overflow).

There are also some errors I simply have not yet tried to cause:
`?01.03`, `?01.11`, `?12.10`, `?12.40`.


## <a id="miss-hw"></a>Missing Hardware Support

The [U/W FOCAL reference cards][uwfr] and the [DECUS submission][uwfd]
talk about features for hardware we don't have. Either the
command/feature doesn't exist at all in the version of U/W FOCAL we
distribute or it doesn't do anything useful, lacking support within the
version of SIMH we distribute.

Broadly, these features are for the PDP-12, the LAB-8/e, Tektronix
terminals, and pen plotters. Should anyone extend SIMH with a way to
control such hardware (or emulations of it) we may consider putting
these features back into our distribution of U/W FOCAL.

In the meantime, the following facilities do not work:

*   The `FADC`, `FJOY`, `FLS`, `FRS`, and `FXL` functions don't exist

*   There is no plotter support in SIMH, so the `PLOT` command doesn't
    exist

*   Although support for the VC8E point-plot display exists in SIMH, the
    `VIEW` command to drive it is not present in our version of U/W
    FOCAL.

*   Error code `?14.15` can't happen; we have no "display buffer"

*   Error codes `?14.50` and `?14.56` can't happen; SIMH doesn't
    simulate a PDP-12 or a LAB-8/e


## <a id="diffs"></a>Differences Between U/W FOCAL and Other FOCALs

The [DECUS submission for U/W FOCAL][uwfd] lists the following
advantages for the version of U/W FOCAL included with the PiDP-8/I
software distribution as compared to FOCAL,1969, FOCAL-8, and OMSI PS/8
FOCAL:

1.  Extended library features with device-independent chaining and
    subroutine calls between programs.

2.  File reading and writing commands, 10 digit precision, full 32k
    memory support, 36 possible functions, 26 possible command letters.

3.  Computed line numbers and unlimited line lengths.

4.  Tabulation on output, format control for scientific notation.

5.  Double subscripting allowed.

6.  Negative exponentiation operators permitted.

7.  `FLOG`, `FEXP`, `FATN`, `FSIN`, `FCOS`, `FITR`, and `FSQT` rewritten
    for 10-digit accuracy.

8.  Character manipulations handled with `FIN`, `FOUT`, and `FIND`.

9.  Function return improvements:

    *   `FSGN(0)=0` in U/W FOCAL; `=1` in FOCAL,1969
    *   `FOUT(A)=0` in U/W FOCAL; `=A` in PS/8 FOCAL

10. n/a; see [above](#miss-hw)

11. 6 special variables are protected from the `ZERO` command: `PI`,
    `!`, `"`, `$`, `%`, and `#`.

    `PI` is initialized as 3.141592654.

12. The limit on the number of variables is 676

13. Text buffer expanded to 15 blocks

14. Two-page handlers permitted

15. Program and file names are wholly programmable. File size may be
    specified. OS/8 block numbers may be used in place of file names.

16. The `OPEN` and `DELETE` commands can have programmed error returns.

17. Improved distribution and random initialization of `FRAN`.

18. `ERASE`, `MODIFY`, and `MOVE` do not erase variables.

19. `WRITE` doesn't terminate a line; `MODIFY` doesn't echo form feed.

20. U/W FOCAL's starting address is 100 (field 0) or 10200 (field 1).


## <a id="converting"></a>Converting Programs from Other Versions of FOCAL

Programs saved by other versions of FOCAL generally don't have the same
format as the core images used by U/W FOCAL. You must therefore use one
of the [text based loading methods](#loading) to save your program text
out of the other FOCAL and load it into U/W FOCAL.

Also, while the `ERASE` command may be used to zero variables in other
FOCALs, you must use `ZERO` for that in U/W FOCAL. If your program
starts off with `ERASE` commands to initialize its variables, there's a
pretty good chance your program will just erase itself under U/W FOCAL.


## <a id="rationale"></a>Why Did We Write This?

[The Manual][uwfm] is well written as far as it goes, but there are
gaps:

1.  It is written somewhat generically for the whole PDP-8 family as of
    late 1978, whereas the PiDP-8/I project is focused on a single model
    from 1968. Those not familiar with the differences can therefore be
    confused by some of its directions.

1.  There are considerations in our simulated PiDP-8/I world that simply
    did not apply to those running U/W FOCAL on the real hardware.

1.  There are multiple versions of U/W FOCAL; the version covered by
    [the Manual][uwfm] isn't the one we actually ship.  Our two
    [other][uwfr] primary [sources][uwfd] also do not cover exactly the
    version of U/W FOCAL we ship.

1.  It inspires questions in the reader's mind without providing an
    answer.  Whether this was intentional — with the author intending
    that the user answer these questions on his own — or otherwise, some
    of these questions we felt needed answering here within the PiDP-8/I
    U/W FOCAL documentation.

This document is our attempt to fill these gaps and to supplement those
other documents.  [Extensions and corrections][hack] are welcome.


## <a id="references"></a>References

The primary sources for this supplement are:

*   [U/W FOCAL Manual][uwfm], October 1978, by Jim van Zee of the
    University of Washington.

*   [U/W FOCAL reference cards][uwfr] from the U/W FOCAL distribution,
    approximately contemporaneous with the Manual, but clearly for a
    different version of U/W FOCAL than is documented in the Manual.

*   [DECUS Submission for U/W FOCAL][uwfd], also by van Zee, from August
    1978.
    
    This document describes the OS/8 version of U/W FOCAL rather than
    the paper tape version described by [the Manual][uwfm] we use as our
    primary document here within the PiDP-8/I project. We chose to
    convert the Manual to Markdown rather than this DECUS submission
    because the DECUS document's scan is terrible, resulting in nearly
    worthless OCR output; we *really* did not want to retype the whole
    thing! Additionally, we think the Manual is a better tutorial than
    the DECUS submission, though the DECUS submission is perhaps a
    better reference text.

[df8]:  http://www.ibiblio.org/pub/academic/computer-science/history/pdp-8/FOCL69%20Files/DEC-08-AJAD-D.pdf
[f71]:  http://svn.so-much-stuff.com/svn/trunk/pdp8/src/decus/focal8-177/
[hack]: https://tangentsoft.com/pidp8i/doc/trunk/CONTRIBUTING.md#patches
[uwfd]: http://www.pdp8.net/pdp8cgi/query_docs/view.pl?id=191
[uwfm]: https://tangentsoft.com/pidp8i/doc/trunk/doc/uwfocal-manual.md
[uwfr]: https://tangentsoft.com/pidp8i/doc/trunk/doc/uwfocal-refcards.md


### <a id="license"></a>License

Copyright © 2017, 2021 by Warren Young and Bill Cattey. Licensed under the
terms of [the SIMH license][sl].

[sl]: https://tangentsoft.com/pidp8i/doc/trunk/SIMH-LICENSE.md
