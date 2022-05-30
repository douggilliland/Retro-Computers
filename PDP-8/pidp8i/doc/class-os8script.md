# class os8script: A high-level interface to OS/8 under SIMH

## Introduction

This class is a higher level abstraction above the class simh.

An understanding of that class as documented in [doc/class-simh.md][class-simh-doc]
is a helpful to working with this class.

Development of this class was driven by the desire to create a scripting
language to engage in complex dialogs programs running under OS/8. The first use
cases were embodied in the [`os8-run`][os8-run-doc] scripting system:

 * Use `BUILD` to perform elaborate system configuration in a repeatable way.
 * Drive commands calling the OS/8 Command decoder to operate on specified
 files under OS/8.
 * Apply patches, first using `ODT` and then using `FUTIL`.
 * Assemble programs using `PAL8`.
 * Reconfigure the SIMH devices, for example switching between having TC08
 or TD8E DECtape devices. (Only one is allowed at a time, and the OS/8 system
 areas are incompatible.)

The latest use case, embodied in the [`os8-progtest`][progtest-doc]
utility, is to allow creation of arbitrary state machines that engage
in complex program dialogs so as to permit programmed, run-time
testing of functionality under OS/8.

This document describes the class os8script API with an eye to assisting
the development of stand-alone programs that use it.  A complete demo
program implementing a complex dialog is provided.

## Housekeeping

Before we describe methods to create the environment and run commands,
it is important to learn the rules of housekeeping in the `class
os8script` environment:

### Important caveat about parallelism:

The pidp8i software package does a lot of complex building both under POSIX
and in a scripted way under OS/8.  The `tools/mmake` POSIX command
runs multiple independent instances of `make` in parallel.

OS/8 comes from a single threaded, single computer design paradigm. The
boot device assumes **NOTHING** else is touching its contents. This means if there
is more than one instance of SIMH booting OS/8 from the same image file
(for example in two terminal windows on the same POSIX host)
the result is **completely unpredictable**.

This was the primary driver for the creation of the `scratch` option
to the `mount` command and the development of the `copy` command.
Care **must** be exercised to do run in a `scratch` boot environment,
so as to manage dependencies and concurrencies.

### Gracefully unmount virtual files

POSIX buffers output.  If you `mount` an image file, modify it, and quit
the program, the buffered modifications may be lost.  In order to guarantee
all buffers are properly flushed, you **must** call `umount` on image files
you've modified.

### Quit SIMH.

This is not a requirement, but is good practice.

### <a id="cleanups"></a>Remove scratch images.

The management of scratch images is rudimentary.  The `mount` command
creates them, and appends them to a global list `scratch_list`. This list
must be used before exiting your program to sweep through and delete
the scratch imagtes.

At this time the API keeps no other association with mounts, and makes
no other inferences about when the scratch file might or might not be
needed.

Note that the [`exit_command`](#exit_command) will do all this cleanup for you.
So be sure to call it on every normal or abnormal exit from your program.

With the housekeeping rules covered, we are ready to learn how to set
up the environment.

## Setup:

The following will include the libraries you need:

    import os
    import sys
    sys.path.insert (0, os.path.dirname (__file__) + '/../lib')
    sys.path.insert (0, os.getcwd () + '/lib')

    from pidp8i import *
    from simh   import *
    from os8script import *


The setup steps:

1. Using the argparse library is recommended to create an args structure containing
the parsed command line arguments.

2. Create the simh object that will do the work.

3. Create the os8script object that calls to the simh object.

The creation method, `os8script` takes up to 5 arguments:

* `simh`: The `simh`: object that will host SIMH.  See [class-simh.md][simh-class-doc].
* `enabled_options`: List of initial options enabled for interpreting script commands.
* `disabled_options`: List of initial options disabled for interpreting script commands.
* `verbose`: Optional argument enabling verbose output. Default value of `False`.
* `debug`: Optional argument enabling debug output. Default value of `True`.

The two options lists were put into the creation call initially because
for the first use of the API, it was easy to pass the arrays returned by
`argparse`.  Conceptually, an initial set of options is passed in at create
time, and thereafter the add/remove calls are used to change the active options
one at a time.

4. Find the system image you want to boot to do the work.

In the example below we default to using the `os8mo` element from the
`dirs` library. That is the default media output directory where the
build process installs the bootable images. The bootable image
defaults to the `v3d.rk05` image or can be specified by a `--target`
option.

5. Mount and boot the image.  Using `scratch` is **highly** recommended.


## Doing the Work:

There are two script-based calls if you have a file on the POSIX host,
or can assemble a string into a file handle, and express your work
as an `os8-run` style script:

`run_script_file` was the first use case.  A filename is passed in,
and the library is responsible for opening the file and acting on its
contents.  There are helper routines for enabling the script to
find the image file to boot.

`run_script_handle` is called by `run_script_file` once the
filename has been successfully opened.  This method allows creation
of in-memory file handles using the `io` library. For example:

    import io

    _test_script =  """
    enable transcript
    os8 DIR
    """

    script_file = io.StringIO(_test_script)
    os8.run_script_handle(script_file)

Otherwise you do direct calls into the API

### Environment check and command startup

The single most important idea to learn in producing a reliable
program using class os8script is the notion of **The Current Context
and State of the os8script Environment**.

The `os8script` class is careful to validate that OS/8 is booted and
active before submitting strings that it expects will be interpreted
by the OS/8 Keyboard Monitor.  It is careful to escape out to SIMH
when sending strings it expects will be interpreted as SIMH commands.
The instantiated `os8script` can be thought of as a set of layered
state machines:

* SIMH starts off at its command level,
  * then OS/8 is booted.
    * When a program is started under OS/8 it creates a new layered
      state machine, the dialog with the program,
  * until the program finishes and returns to the OS/8 keyboard monitor.

To issue more SIMH commands after that you have to escape out
of OS/8, but then return to OS/8 and continue running the program

When you run a complex command with `os8script` class, you will be
writing a state machine that will need to return to OS/8 when it is
finished.

The `os8script` class provides `check_and_run` as a high level startup
method that confirms all is well to run your desired OS/8 command from
the Keyboard Monitor.  It will:

 * make sure we're booted,
 * make sure we're in the OS/8 context,
 * run the command,
 * return the reply status of the initial command
   or -1 if any of the previous steps fail.

It acts like a bridge between the higher level paradigm of script
running and the lower level paradigm of sending OS/8 command lines.
Conceptually, the boot check is a once-only check at the start up of a
more complex dialog. `check-and-run` takes three mandatory arguments:

* `os8_comm`: The OS/8 command line to run.
* `caller`: A name assigned by the calling program to help make it clear which higher
  level program is calling this common start-up routine.
* `script_file`: For API compatibility with the other commands. More fully explained below.
  Often this argument is simply the empty string.

It takes one optional argument, an array of match regular expressions, as managed
by the [`intern_replies`](#intern_replies) method of class simh.  If this argument is
not provided, the default replies array for OS/8 is used.

For example:

    os8.check_and_run ("myprog_main", "DIR", "")

Using this method is not required, but is an easy way to start up an
OS/8 command.

After startup you use the interface methods to Python expect in the `simh` class
to engage in the command dialog:

Send a string and look for results:

* `os8_cmd`

Send a string and leave it to another call to look for results:

* `os8_send_str`
* `os8_send_ctrl`

Look for results:

* `_child_expect`

### Using expect

The Python `pexpect` library for expect allows passing in an array of responses,
and returns the array index of what was matched.

The class `simh` library contains a table of all the normal and error
replies that the OS/8 Keyboard Monitor and Command Decoder are known to emit
in `_os8_replies` and pre-compiled regular expressions for each one in
`_os8_replies_rex`.

<a id="intern_replies"></a>Class `os8script` has a method
`intern_replies` that allows management of additional tables by name,
allowing, for example the `build_command` state machine to create a
table with replies from the `BUILD` command **in addition to** all the
OS/8 replies.

`intern_replies` takes 3 arguments:

* `name`: The name of the new reply table.  If a table of that name already exists
return `False`.

* `replies`: An array of 3 element arrays with the replies. Described below.

* `with_os8`: A boolean flag. True if the array of replies is in addition to
the OS/8 replies. False if the array of replies is instead of OS/8 replies.
This allows fine control of the dialog. Sometimes you want to test for just
the program output. Sometimes you want to also detect OS/8 responses.

#### The `replies` array

The three elemments for each member of the replies array are:

    1. The common name of the match string.  This is used by match test routines.
    2. The regular expression python expect will use to try and match the string.
    3. True if receiving this is a fatal error that returns to the OS/8 Keyboard Monitor.
    Knowing this state change is helpful in establishing correct expectation about
    the state of the enviromnent.

Each regular expression is compiled, and interned in the `os8script` object in
the `replies_rex` dictionary, keyed to the `name` of the `replies` array.
The `replies_rex` dictionary is used to make sense of commands executed by calling
either the [`check_and_run`](#check_and_run) method or the os8_cmd method in the
simh chass.

The array itself is interned in the `os8script` object in the `replies` dictionary
keyed to the `name` of the `replies` array.

The common name is used in match tests:

The `simh` object instantiated within the `os8script` object has a `test_result`
method that takes four arguments:

* `reply`: integer index into the array of replies.
* `name`: the common name of the result we are expecting to match.
* `replies`: the array of replies that we are testing against.
* `caller`: is used to reduce error reporting common code as describe below.

If the common name supplied to `test_result` is found at the `replies`
array at index `reply`, `True` is returned. Otherwise `False` is returned.

If `caller` is not empty, and the match is False, an error is printed
prefaced by the caller string.  However the most common use case is to
leave the `caller` string empty, and perform several `test_result` actions
in succession as shown in the example program.

After the command is executed, driven by the `replies_rex` array, the results
can be tested with the `replies` array.

For example if we wanted to test a start up of `MYPROG` into the command decoder
we could do this:

    reply = os8.check_and_run ("myprog_main", "R MYPROG", "")
    os8.simh.os8_test_result (reply, "Command Decoder Prompt", "start_myprog")

(Notice we left the script file blank, and defaulted to the OS/8 replies arrays.)
If we didn't get the Command Decoder prompt, because MYPROG wasn't found we'd
get something like this:

    start_myprog: failure
    Expected "Command Decoder Prompt". Instead got "File not found".

## A Complete Example

The [documentation for the simh class][class-simh-doc] makes reference to programs
in the source tree as examples.  However those were written primarily to get a job
done, rather than as a tutorial.

The file [`examples/host/class-os8script-demo.py`][demo-script] was written
specifically as a tutorial.

The demo program shows how to create a state machine that engages in a complex
dialog under OS/8:

* It starts up OS/8 BASIC.
* When OS/8 BASIC asks "OLD OR NEW" the program says "NEW".
* When prompted, it supplies the filename, "MYPROG.BA".
* A two-line `1 + 2 = 3` program is input.
* The program is run, and the answer is validated.

Each step of the housekeeping, setup, and work is described and performed.

Here is a non-verbose sample run:

    wdc-home-3:trunk wdc$ examples/host/class-os8script-demo.py 
    Got Expected Result!

Here is a verbose sample run:

    wdc-home-3:trunk wdc$ examples/host/class-os8script-demo.py -v 
    Line 0: mount: att rk0 /Users/wdc/src/pidp8i/trunk/bin/v3d-temp-_2mqkf24.rk05
    att rk0 /Users/wdc/src/pidp8i/trunk/bin/v3d-temp-_2mqkf24.rk05
    att rk0 /Users/wdc/src/pidp8i/trunk/bin/v3d-temp-_2mqkf24.rk05
    sim> show rk0
    att rk0 /Users/wdc/src/pidp8i/trunk/bin/v3d-temp-_2mqkf24.rk05
    sim> show rk0
    RK0	1662KW, attached to /Users/wdc/src/pidp8i/trunk/bin/v3d-temp-_2mqkf24.rk05, write enabled
    Line 0: boot rk0
    boot rk0
    sim> boot rk0
    boot rk0
    
    PIDP-8/I TRUNK:ID[0A1D0ED404] - OS/8 V3D - KBM V3Q - CCL V1F
    CONFIGURED BY WDC@WDC-HOME-3.LAN ON 2020.12.08 AT 00:01:16 EST
    
    RESTART ADDRESS = 07600
    
    TYPE:
        .DIR                -  TO GET A LIST OF FILES ON DSK:
        .DIR SYS:           -  TO GET A LIST OF FILES ON SYS:
        .R PROGNAME         -  TO RUN A SYSTEM PROGRAM
        .HELP FILENAME      -  TO TYPE A HELP FILE
    
    .Line: 0: demo_command: R BASIC
    R BASIC
    NEW OR OLD--Got reply: NEW OR OLD
    NEW
    FILE NAME--Got reply: FILENAME
    MYPROG.BA
    
    READY
    Got reply: READY
    10 PRINT 1 + 2
    20 END
    RUN
    
    MYPROG  BA    5A    
    
     3 
    
    READY
    Got reply: 3 READY
    Got Expected Result!
    Sending ^C
    
    .Deleting scratch_copy: /Users/wdc/src/pidp8i/trunk/bin/v3d-temp-_2mqkf24.rk05
    
    Simulation stopped, PC: 01210 (JMP 1207)
    sim> detach all
    detach all
    sim> quit
    Calling sys.exit (0) at line: 0.


## API reference

This is an alphabetical reference of the public methods of the `os8script` class.

There are setup, housekeeping and helper methods.

The methods that implement the [os8-run][os8-run-doc] commands can be called
directly.  Those method names all end with `_command`. They all take two arguments:

* `line`: The rest of the line in the script file after the command was parsed.
This makes the script file look like a series of command lines.  The parser
sees the command keyword and passes the rest of the line as `line`.
* `script_file`: A handle on the script file.  This gets passed around from
command to command to deal with multi-line files. We rely on this handle
keeping track of where we are in the file over time.  If you call a command
that doesn't deal with multiple lines, you can pass `None` as the `script_file`
handle.  If the command needs more lines, and it sees `None` python will kill
the program and give you a backtrace.

They all return a string, "success" on successful operation,  "fail" on a failed
operation, "die" when the error is so bad that the program really should not proceed.

### `basic_line_parse`

This helper method takes the same two arguments as all `_command` APIs.

It is rarely called from outside of commands, but is critical to the
implementation of commands.  As each line is parsed, this method:

* strips out leading and trailing whitespace.
* filters out comments.
* parses `begin` statements to enter a new begin/end level.
* enforces `enabled` / `disabled` parsing and does the work to skip over disabled blocks.
* parses `end` statements to pop a begin/end level.
* returns `None` if the line in hand is empty and the caller should just exit without doing
  anything more.

### `begin_command`

Although appearing early alphabetically, it's probably one of the
last commands one would use in a program.  `begin_command` runs a
complex but constrained state machine for the OS/8 `BUILD` command or
commands that use the OS/8 Command Decoder.
 
When `begin` is parsed from a line, it opens a new block. That block
is either an `enable` / `disable` block for conditional execution or
one of two sub-commands, `build_subcomm` and `cdprog_subcomm`.

These embody complex state machines to step through command dialogs and detect
error conditions.

`build_subcomm` is for creating dialogs with the OS/8 `BUILD` command.

`cdprog_subcomm` is for starting any OS/8 program that uses the OS/8
Command Decoder.  It is a simple dialog:

* specify one or more files in Command Decoder Syntax.
* repeat if the program runs and gives back the command decoder asterisk `*` prompt.
* detect return to OS/8 by getting a OS/8 keyboard monitor dot `.` prompt.
* detect and report OS/8 errors encountered.
* recognize whether an error is fatal or non-fatal, and act to keep the state machine
  in a known state, generally by sending `^C` on non-fatal errors.

### `boot_command`

Check to see if the device to be booted has something attached.
If not, return "die".
If so, boot it, and set our booted state to `True`.

You need to issue this command before running any OS/8 commands because OS/8
must be booted up to run them.

### `configure_command`

An interface to a constrained subset of high level PDP-8 specific
device configuration changes under SIMH.

`line` is parsed into two arguments: The first arg is the device to configure.
The second arg is the setting.

The following devices and settings are configurable with this command:

* `tape`: `dt` to enable the TC08 DECtape, `td` to enable the TD8E DECtape instead.
* `rx`: `rx01` to enable the single density RX01 floppy, `rx02` to ehable the double density RX02 drive instead.
* `tti`: `KSR` set upper case only operation, and force all lower chase to upper case before forwarding them to OS/8. `7b` to enable SIMH 7bit mode. All characters are passed to OS/8 without case conversion.

### `copy_command`

Allows scripts to say, "Make me a copy of this POSIX file," which is
generally an image file that serves as the basis of a modified
file. This is how we are able to run scripts in parallel: we create
the destination image. If we don't create a destination image via copy
and boot it, then the `scratch` option to `mount` is needed, as
explained above.

### `cpfrom_command`

The way to get files out to the POSIX host from the OS/8
environment. Relies on the OS/8 `PIP` command.  Contains a state
machine for working through dialogs. Handles coding conversion
between POSIX ASCII (7 bit space parity, \n newline delimiter)
and OS/8 ASCII (8 bit mark parity, \r newline delimiter.)

### `cpto_command`

The way to get files into OS/8 from the POSIX host. Relies on the
OS/8 `PIP` command.  Contains a state machine for working through
dialogs. Also handles coding conversion between OS/8 ASCII and
POSIX ASCII.

### `disable_option_command`

Parses the `line` argument as the key to enable.  The end of the key is
delimited by the end of the line or the first whitespace character.

If the key is on the `options_enabled` array, remove it, **and** add the
key to the `options_disabled` array if it is not already present.

Subtle point about `disable` vs. `enable` (as copied from the [`os8-run` Documentation][os8-run-doc]):

Two lists are required because default behavior is different for
enablement versus disablement.

The `begin enabled` block is only executed if the `enabled` list
contains the keyword. If no such keyword is found, the block is ignored.

The `begin default` block is executed by default unless the `disabled`
list contains the keyword. If such a keyword is found, the block is ignored.

The `default` construct allows creation of scripts with conditional
execution  without worrying about informing the build system about new
enablement keywords.

### `enable_option_command`

Parses the `line` argument as the key to enable.  The end of the key is
delimited by the end of the line or the first whitespace character.

If the key is on the `options_disabled` array, remove it, **and** add the
key to the `options_enabled` array if it is not already present.

There is a special enable option `transcript`.  Within an `enable transcript`
block, all OS/8 output is printed on the standard output of your program.

###  `end_command`

Ends the `begin` / `end` block.

### <a id="exit_command"></a>`exit_command`

Make a graceful exit:

1. Remove scratch files.
2. Detach all devices from running image.
3. Quit SIMH.
4. Parse an exit status value from `line`. Default to 0.
5. Call POSIX exit to exit the running program,

### `include_command`

Allows running a script within a script to arbitrary depths.
`line` is the name of a script file. Uses the [`path_expand`](#path_expand)
method to expand variables appearing in the path specification.

### `mount_command`

Does complex parsiing of `line` to get all the parameters needed to attach
an image file to the appropriate SIMH device.  Has additional parameters
that are documented in the [os8-run Documentation][os8-run-doc].

### `ocomp_command`

Simple state machine to pass `line` as command arguments to the OS/8 `OCOMP` utility
and return `success` if two files are identical.  This little machine is used in
`os8pkg` in the `verify` command.

### `os8_command`

Allows no dialog. Just pass `line` to the OS/8 Keyboard monitor to run.
Manage the environment state to make sure we eventually get back to the
keyboard monitor:

* detect return to OS/8 by getting a OS/8 keyboard monitor dot `.` prompt.
* detect and report OS/8 errors encountered.
* recognize whether an error is fatal or non-fatal, and act to keep the state machine
  in a known state, generally by sending `^C` on non-fatal errors.

### `pal8_command`

Runs the OS/8 PAL8 assembler. Contains a state machine to gather up error output nicely.

### `patch_command`

The `patch` command contains a pretty complex state machine. It knows how
interprest patch description files as commands in either `ODT` or `FUTIL`
to modify files under OS/8 and then save them.

### <a id="path_expand"></a>`path_expand`

Helper method -- a simple minded variable substitution in a path.  A
path beginning with a dollar sign parses the characters between the
dollar sign and the first slash seen becomes a name to expand with a
couple local names: $home and the anchor directories defined in
lib/pidp8i/dirs.py.  Returns None if the expansion fails.  That
signals the caller to fail.

Takes one argument, a string, `path` that is parsed.

`path_expand` knows the build-time and run-time destination
directories and expands the following constructs using the `dirs`
library (as copied from the [`os8-run` Documentation][os8-run-doc]):

| $build/   | The absolute path to the root of the build.
| $src/     | The absolute path to the root of the source.
| $bin/     | The directory where executables and runable image files are installed at build time
| $media/   | The absolute path to OS/8 media files
| $os8mi/   | The absolute path to OS/8 media files used as input at build time
| $os8mo/   | The absolute path to OS/8 media files produced as output at build time

### `print_expand`

Helper method -- close kin to path_expand.  Takes a string that may
name a path substitution or the magic $version value and performs the
appropriate value substitution.

Takes one argument, a string, `path` that is parsed.

### `print_command`

Lets scripts send messages.  Needed from inside `os8-run` scripts.
Your program can just use the python `print` command.

### `restart_command`

Call os8_restart in simh to resume OS/8. Returns "die" if we've not booted.

### `resume_command`

Call os8_resume in simh to resume OS/8. Returns "die" if we've not booted.

### `simh_command`

Lets you send arbitrary commands to simh.  Recognizes the boot and
continue commands as setting OS/8 context.  Knows how to suspend OS/8
and escape to SIMH so you don't have to worry about managing that
housekeeping.

### `umount_command`

Cleans out a mount command, except for scratch files. Remember you have to
remove scratch files. Call the [`exit_command`](#exit_command) method to do so.


[class-simh-doc]: https://tangentsoft.com/pidp8i/doc/trunk/doc/class-simh.md
[os8-run-doc]: https://tangentsoft.com/pidp8i/doc/trunk/doc/os8-run.md
[progtest-doc]: https://tangentsoft.com/pidp8i/doc/trunk/doc/os8-progtest.md
[demo-script]: https://tangentsoft.com/pidp8i/doc/trunk/examples/host/class-os8script-demo.py

## <a id="license" name="credits"></a>Credits and License

Written by and copyright © 2017-2020 by Warren Young and William Cattey.
Licensed under the terms of [the SIMH license][sl].

[sl]: https://tangentsoft.com/pidp8i/doc/trunk/SIMH-LICENSE.md
