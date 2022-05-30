# os8-progtest: Perform Tests on a Program Under OS/8

This program uses Python expect to work through tests of a program
under OS/8.  The test cases and expected output are expressed in YAML format
utilizing the [pyyaml library][pyyaml].

It is found in the `tools` directory of the source tree.


## Usage

    os8-progtest [options] <prog_spec>

The `prog_spec` is the program to test optionally followed by a subset
of tests. For example:

    $ tools/os8-progtest cc8

…runs all CC8 tests, while:

    $ tools/os8-progtest cc8:ps,fib

…runs just the two CC8 tests on `ps.c` and `fib.c`.

More than one `prog_spec` can appear on the command line to test more than
one program at a time.

Because this test system is based on the [pexpect] library, success is
determined by seeing a sequence of expected outputs come from the test
program. If one or more of these fail to occur, the test will appear to
hang until pexpect times out while waiting.

[pexpect]: https://pexpect.readthedocs.io/en/stable/



### Options

| Argument             | Meaning
| -------------------- | ----------------------------------------------
| `--help, -h`         | show this help message and exit
| `--verbose`, `-v`    | increase output verbosity
| `-d DEBUG`           | set debug level; 0-14
| `--destdir DESTDIR`  | destination directory for output files
| `--srcdir SRCDIR`    | source directory for test `.yml` files
| `--target TARGET`    | target image file
| `--dry-run`, `-n`    | dry run: only print what would happen
| `--exitfirst`, `-x`  | exit on first failure

When `--srcdir` is not given, `os8-progtest` looks for YAML files in
`scripts/os8-progtest` relative to the PiDP-8/I source tree root.

The default debug level of 0 suppresses all debug output, while 14 makes
it quite noisy.

The `--exitfirst` option is used when we want a non zero status exit from
the run of `os8-progtest` on the very first failure, rather than the usual
behavior of a successful run being performance all tests and reporting
failures along the way.

## The Test Definition File

The `.yml` files defines a series of tests, each one of which consists of
a state machine.  The state machine consists of a state name, the
test text string to send, and an array of possible responses and the
state to go to if the response is received.

In the abstract, each test name begins starts at the beginning of a line,
and all the associated states are indented one tab stop.
Each state consists of a name followed by an array specification,
where the first element is the test text string to send, and the
second element is an array of 1 or more `[response, newstate]` pairs.

Every state machine must have a “`start`” state.

Every state machine should have at least one state that names “`success`” or
“`failure`” as termination states.

The `-n`, `--dry-run` option should be used at development time to
confirm that the test state machine will terminate with success if all
tests come back successful.

The easiest way to understand how to define the state machine is to
study an example:

    'ps':
        'start': ["EXE CCR\r", [["PROGRAMME\\s+>", 'progname']]]
        'progname': ["ps.c\r", [
                [ ".*924.*COMPLETED\r\n\r\n#END BATCH\r\n\r\n.$",
                  'success'
                ]
            ]
        ]
    'fib':
        'start': ["EXE CCR\r", [["PROGRAMME\\s+>", 'progname']]]
        'progname': ["fib.c\r", [
                [ "OVERFLOW AT #18 = 2584\r\n\r\n#END BATCH\r\n\r\n.$",
                  'success'
                ]
            ]
        ]

This file defines two tests for the `cc8` package, `ps` and `fib`, which
follow a very similar structure:

 * Both have the requisite `start` state and terminating `success` condition.
 * Both run the OS/8 command `EXE CCR` which runs `DSK:CCR.BI`,
   part of the CC8 package.
 * Both react to the program name input prompt by linking to the `progname` state.
 * Each test answers the `progname` state by sending the name of a C
   program installed with CC8, after which the test was named.
 * Each test looks for expected output from the test program followed by
   the common `#END BATCH` after a completed `CCI.BI` run. If found,
   sends the test state machine to the `success` condition.

Because the second element of each test is an array of pairs, you can
have the test check for multiple expected possible answers, sending the
state machine to potentially different conditions depending on which one
comes back. This gives the system a simple sort of conditional logic:

    'advent': ["ADVENT\e", [
            [ "LOCATION OF TEXT DATABASE\\s+\\(\\S+\\).*", 'database' ],
            [ "WELCOME TO ADVENTURE!!", 'instructions' ]
        ]
    ]

You can see the rest of the test [here][ayml], but this shows the
essential elements: two possible responses, sending the test to one of
two states, `database` or `instructions` depending on whether Adventure
has been run on the boot media used by the test before. Without this
logic, we’d have to either rebuild the test media each time we ran the
test or roll back all state changes made to it.

Notice the use of `\e` to start `ADVENT`, terminating the OS/8 Command Decoder
input with an ASCII escape character.

[ayml]: /file/scripts/os8-progtest/advent.yml


### Additional Syntax Information

A line beginning with a `#` is ignored as a comment.


## Crafting New State Machines

1. The YAML quoting conventions are carefully chosen!

    *   Surround state names with single quotes.  Otherwise state names
        like `yes` get evaluated and turned into something else. (`yes`
        becomes `True`.)

    *   Surround send and reply strings with double quotes. The YAML
        evaluation of quoted strings is the simplest to understand as it
        gets translated into Python pexpect regular expressions.

2.  OS/8 commands end with a carriage return denoted by `\r` or escape
    denoted by `\e`.

3.  For programs needing <kbd>Ctrl-C</kbd> to get out of some loop, use
    the YAML hex code `\x03`.

4.  `pexpect` translates all TTY output you see from running the
    simulator to upper case, so take anything you see and translate it
    to upper case in the reply string.

5.  It is important to escape characters that normally have regex
    meaning: `.` `+` `*` `$` `(` `)` and `\`.  To do this in YAML,
    preface each occurrence with two backslashes. So for example, to
    pass in a literal question mark, replace `?` with `\\?`.

6.  To pass in regex escapes that have a backslash — for example `\s`
    for whitespace — double the backslash, so `\s` becomes `\\s`.

7.  Use of regex’s end-of-string match (`$`) can often improve
    reliability, because it ensures the state machine doesn’t proceed
    before OS/8 or the program running under it is ready. Keep in mind
    that `os8-progtest` runs in your host machine’s context, and while
    the program under test is running unthrottled on the PDP-8
    simulator, it’s still likely a program from the 1960s or 1970s
    expecting to run on a machine capable of only a few hundred thousand
    instructions per second, being fed interactive input by a 110 bps
    teletype. Some programs can get spammed if you don’t wait out the
    full reply line before sending the next bit of input.

8.  Sometimes guessing the exact whitespace is difficult.  The `\\s+`
    construct to match on one or more whitespace characters is often
    helpful.

9.  Helpful match strings:

    String     |  Meaning
    ---------- | -----------------
    `"\n\.$"`  | OS/8 Monitor prompt.  Always look for this at the end.
    `"\n\*$"`  | OS/8 Command decoder prompt.  Often the first step in running programs.

### Problems matching against long strings of output characters.

Python expect has been observed to misbehave on long strings of
output, for example when trying out BASIC games that print typewritter
art.  The match times out and fails, and the `before` match string is
only a partial read of the whole output.

Neither enlarging the pexpect `maxread` option for the spawned sub-process,
nor setting a sleep between tests helped.  However, there is a work around:
Perform another write/expect cycle.  Doing this is challenging, because
ideally you want to send input that won't mess up the output.

Under BASIC, an attempt was made to send `XOFF` ('\0x011') but sometimes, instead
of sending `XOFF` that would be ignored, OS/8 would echo "X011".  The work-around
that actually worked was to:

1. Detect stalled output with careful crafting of additional state matches. And adding
a new state.

2. Prevent false positive tests of stalled output, by putting the longest,
definitive match first in the list.

3. Send a newline.

4. Retest.

5. If necessary loop a couple times.

6. Make sure tests after the kick handle the additional newlines gracefully.

Example:  The playboy bunny typewriter art kept hanging at random points.
The old version:

    'bunny':
        'start': ["R BASIC\r", [["NEW OR OLD--$", 'old']]]
        'old': ["OLD\r", [["FILE NAME--$", 'name']]]
        'name': ["BUNNY.BA\r", [["READY\r\n$", 'run']]]
        'run': ["RUN\r", [[".*BUNNY.*\r\nREADY\r\n$", 'success']]]
        'quit': ["\x03", [["\n\\.$", 'success']]]

becomes:

    'bunny':
        'start': ["R BASIC\r", [["NEW OR OLD--$", 'old']]]
        'old':   ["OLD\r", [["FILE NAME--$", 'name']]]
        'name':  ["BUNNY.BA\r", [["READY\r\n$", 'run']]]
        'run':   ["RUN\r", [
                   [".*BUNNY.*\r\nREADY\r\n$", 'quit'],
                   ["^RUN.*", 'kick']
                 ]
        ]
        'kick':  ["\r", [
                   [".*\r\nREADY\r\n", 'quit'],
                   [".*BUNNY.*", 'kick']
                 ]
        ]
        'quit':  ["\x03", [["\n\\.$", 'success']]]

A few subtle aspects:

 * The `kick` state can loop until it gets the "READY" signifying the end of the run.
 * The test for "READY\r\n" in the `run` state contains the detection of end of string ('$')
   but the test in the `kick` state does not, because there will be extra newlines.
 * The work-around here relies on the hope that there'll be a string with the whole word
   "BUNNY" in it with the partial read.
 * Note that the wild card matches ('.*') are non-greedy, and match on the smallest success.
   That's why the longest match for the successful run is the first test to apply.

[pyyaml]: https://pyyaml.org/wiki/PyYAMLDocumentation

### <a id="license"></a>License

Copyright © 2020 by Bill Cattey. Licensed under the terms of [the SIMH license][sl].

[sl]: https://tangentsoft.com/pidp8i/doc/trunk/SIMH-LICENSE.md
