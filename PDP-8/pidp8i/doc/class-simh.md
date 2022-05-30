# How to Control SIMH and OS/8 from Python

## Introduction

While we were building the `mkos8` tool (predecessor to
[`os8-run`][ori]), we built a set of facilities for driving SIMH and
OS/8 running under SIMH from the outside using [Python][py], a very
powerful programming language well suited to scripting tasks. It
certainly beats writing PDP-8 code to achieve the same ends!

When someone on the mailing list asked for a way to automatically
drive a demo script he'd found online, it was natural to generalize
the core functionality of `mkos8` as a reusable Python class, then
write a script to make use of it. The result is `class simh`, currently
used by six different scripts in the PiDP-8/I software distribution
including `os8-run` and the `teco-pi-demo` demo script.

The basis for this work is `pexpect` the Python Expect library.

This document describes how `teco-pi-demo` works, and through it, how
`class simh` works, with an eye toward teaching you how to reuse this
functionality for your own ends.

[ori]: https://tangentsoft.com/pidp8i/doc/trunk/doc/os8-run.md
[py]:  https://www.python.org/


## Invocation

Because we do not install these components in the system's Python
library path, you must modify that path to allow your script to find
these components. Simply copy this invocation block into the top of your
script:

    import os
    import sys
    sys.path.insert (0, os.path.dirname (__file__) + '/../lib')
    sys.path.insert (0, os.getcwd () + '/lib')

    from pidp8i import *
    from simh   import *

That adjusts the path, then imports all of the generic functionality
from the PiDP-8/I `lib` directory into the current namespace.

The `sys.path.insert` business assumes that your script is installed
into the PiDP-8/I's `bin` directory alongside `teco-pi-demo`. If you've
installed it somewhere else, you'll need to adjust these paths.


## Starting SIMH

The first thing we'll do is start SIMH as a child process of our
Python script under control of an instance of `class simh`:

    s = simh (dirs.build)

We call that instance `s` for short, because we will be calling its
methods a lot in this script. 

We pass `dirs.build` as the first parameter to the constructor, which
tells it how to find the PDP-8 simulator program, derived from the
code shipped on GitHub by the SIMH project, configured and modified
for the needs of the PiDP-8/I project.  We call this the child program,
as it is what `class simh` controls from the outside.

There is an optional second parameter to the constructor, a Boolean
flag that controls whether `class simh` starts the fully-featured
PiDP-8/I simulator or falls back to something closer to the pristine
upstream SIMH PDP-8 simulator.  By default, we do the former, so
that the simulator updates front panel LEDs with internal simulator
state, and toggling front panel switches affect the internal state
of the simulator.

If you don't want the PiDP-8/I GPIO thread to run while your script
runs, pass True here instead, since this is the "skip GPIO" flag,
and its default is therefore False.  We do that from programs like
`os8-run` and `os8-cp` because we want them to run everywhere, even on
an RPi while another simulator is running; we also don't want the front
panel switches to affect these programs' operations.  If your program
never runs on an RPi, passing True here will usuall make it run faster,
since the GPIO thread saps computer resources and so shouldn’t be
started if it isn’t needed.


## Logging

The next step is to tell the `s` object where to send its logging
output:

    s.set_logfile (os.fdopen (sys.stdout.fileno (), 'wb', 0))

Contrast the corresponding line in `os8-run` which chooses whether to send
logging output to the console or to a log file:

    s.set_logfile (open (dirs.log + 'os8-run' + '.log', 'ab') \
        if not VERY_VERBOSE else os.fdopen (sys.stdout.fileno (), 'wb', 0))

Note that this more complicated scheme appends to the log file instead
of overwriting it because there are cases where `os8-run` gets run
more than once with different script inputs, so we want to preserve
the prior script outputs, not keep only the latest.


## Driving SIMH and OS/8

The basic control flow is:

1. Send to SIMH text to act upon.
2. Harvest results.
3. Check results.
4. Goto 1 or quit.

## Checking results

There are a number of helper methods and data structures to help
in checking results.

Although `pexpect` can search replies for a regular expression string,
or a list of such strings, the helper methods use an array of compiled
regular expressions.

The simh class contains two arrays, `_simh_replies` and `_os8_replies`
with corresponding arrays of compiled regular expressions, `_simh_replies_rex`,
and `_os8_replies_rex`.

You can use the simh Class replies or define some for yourself. Example:

```
my_replies = [
  ["Sample Reply", "Sample Reply\s+.*\n$", "False"],
  ["Fatal Error", "Fatal error was\s+.*\n$", "True"]
]

my_replies_rex = []
for item in my_replies:
   my_replies_rex.append(re.compile(item[1].encode()))

```

Often you want your replies in addition to the errors you might
want from OS/8.  In that case you'd do something like:

```
my_replies.extend(s._os8_replies)
```
Of course the extend would appear before the computation of
`my_replies_rex`.

## Running SIMH or OS/8 commands

High level calls to run commands in SIMH can be made from

`simh_cmd` for SIMH commands and
`os8_cmd` for OS/8 commands.

These two methods default to searching results for replies in the relevant arrays.
They return an index into the array that says which reply was received.

The `test_result` method takes a reply number, an expected reply name, an array
replies and a string for helping identify the caller of the test.  (There's also an
optional debug flag. These scripts can be difficult to debug.)

To see if the reply from running a command that would reply with
`my_replies` the code would be:

```
s.test_result(reply, "Fatal Error", my_replies, "myfunc")
```

The reply item at the index given by `reply` is examined. And the desired reply
is matched against the first element of that item.  If it matches, `True` is returned,
otherwise `False` is returned.  If the caller string is present, (in this case,
`"myfunc"`, a message is printed if the reply doesn't match the expected reply.
If the caller string is the empty string, no message is printed.  This makes it
easy to add error diagnostics without a lot of extra work.

Sometimes you want to try a couple different expected values, and don't want
to print anything if there isn't a match.  That's why we special case an empty
caller string.

For SIMH and OS/8 command testing, there are convenience wrappers, `simh_test_result`
and `os8_test_result` that use the relevant array so you don't have to keep typing it.
So the following two are equivalent:

```
s.test_result(reply, "Prompt", s._simh_replies, "myfunc", debug=True)

s.simh_test_result(reply, "Prompt", "myfunc", debug=True)
```

Armed with an understanding of how we make calls into SIMH and OS/8, and
how we test results, we're ready to continue our exploration.

## Finding and Booting the OS/8 Media

If your program will use our OS/8 boot disk, you can find it
programmatically by using the `dirs.os8mo` constant, which means "OS/8
media output directory", where "output" refers to the worldview of
`os8-run`.  Contrast `dirs.os8mi`, which points to the directory holding
the input media for `os8-run`.

This snippet shows how to use it:

    rk = os.path.join (dirs.os8mo, 'v3d.rk05')
    if not os.path.isfile (rk):
        print "Could not find " + rk + "; OS/8 media not yet built?"
        exit (1)

Now we attach the RK05 disk image to the PiDP-8/I simulator found by the
`simh` object and boot from it:

    print "Booting " + rk + "..."
    s.simh_cmd ("att rk0 " + rk)
    s.simh_test_result (reply, "Prompt", "main 1")
    reply = s.simh_cmd ("boot rk0", s._os8_replies_rex)
    s.os8_test_result (reply, "Monitor Prompt", "main 2")

A couple subtle points:  We issued a command to SIMH to attach the rk0
device. If we didn't get the SIMH prompt back, `simh_test_result` would
have said,

    main 1: Expecting Prompt. Instead got: Fatal Error

Then we issued the SIMH command to boot that device. We used the `os8_test_result`
method instead of the `simh_test_result` method because we expected
the panoply of replies would more likely be from the OS/8 list.

After the simulator starts up, and we've confirmed we've got our
OS/8 monitor prompt as a result, we send the first OS/8 command to start our demo.

    s.os8_cmd ("R TECO")
    s.os8_test_result (reply, "Command Decoder Prompt", "main 2")



The bulk of `teco-pi-demo` consists of more calls to `simh.os8_cmd`
and `simh.cmd`. Read the script if you want more examples.

**IMPORTANT:** When you specify the [regular expression][re] strings
for result matching, and want literal matches for characters that
are special to regular expressions such as dot `.`, asterisk `*`,
etc., you need to be preface the characterpair of backslashes.
Example:  To match a literal dollar sign you would say `\\$`.

[re]: https://en.wikipedia.org/wiki/Regular_expression


## Contexts

The operation of OS/8 under SIMH requires awareness of who
is getting the commands: SIMH, the OS/8 Keyboard Monitor,
the OS/8 Command Decoder, or some read/eval/print loop in
a program being run.

Your use of the simh class needs to be mindful of this.
Throughout this document every attempt has been made to be clear
on which methods keep track of context switches for you and
which do not.


### Context Within a program under OS/8

If you've forgotten to exit a sub-program, that program
will still be getting your subsequent commands instead of
OS/8.

You may have a program that keeps running and asking for more input,
for example OS/8 `PIP` returns to the command decoder after each
action.

There is a subtle issue with program interrupts:  You **need**
to check for the string that gets echoed when you do an interrupt.
Otherwise pexpect can get confused.

Two methods that abstract this for you are provided: `os8_ctrl_c`
and `os8_escape` which send those interrupt characters, ask
pexpect to listen for their echo back (`$` comes back from
escape), and confirms a return to the OS/8 monitor.

Here is the implementation of `os8_ctrl_c` as an example if you
need to run a sub-program with a different interrupt character:


```
  #### os8_ctrl_c ##################################################
  # Return to OS/8 monitor using the ^C given escape character.
  # We need to listen for the ^C echo or else cfm_monitor gets confused.
  # Confirm we got our monitor prompt.
  # Optional caller argument enables a message if escape failed.
  # Note: OS/8 will respond to this escape IMMEDIATELY,
  # even if it has pending output.
  # You will need to make sure all pending output is in
  # a known state and the running program is quiescent
  # before calling this method. Otherwise pexpect may get lost.

  def os8_ctrl_c (self, caller = "", debug=False):
    self.os8_send_ctrl ("c")
    self._child.expect("\\^C")
    return self.os8_cfm_monitor (caller)

```

### Sending Control Characters

Several OS/8 programs expect an <kbd>Escape</kbd> (a.k.a. `ALTMODE`)
keystroke to do things. Examples are `TECO` and `FRTS`. 

(Yes, <kbd>Escape</kbd> is <kbd>Ctrl-\[</kbd>. Now you can be the life of
the party with that bit of trivia up your sleeve. Or maybe you go to
better parties than I do.)

The `os8_send_ctrl` method enables you to send arbitrary control
characters but it does not keep track of whether you're in the OS/8 or
SIMH context.  Note also that the `e` control character escapes to SIMH.
So avoid writing programs that need that control character as input.


### Context Between SIMH and OS/8

It is important to make sure that commands intended for SIMH
go there, and not to OS/8 or any programs running under SIMH.  The
`os8_cmd` amd `simh_cmd` methods keep track of context. If
you call the `simh_cmd` method but aren't actually escaped out to
SIMH, an escape will be made for you, and the context change will be
recorded.

If you issue `os8_cmd` when OS/8 is not running, it will complain
and refuse to send the command.

The cleanest way to explicitly escape from OS/8 to SIMH
is to call `esc_to_simh`. It manages the context switch, and tests
to see that you got the SIMH prompt.  Example:

    esc_to_simh()

Subtle points:  Calling  `simh_cmd` will leave you in SIMH. You will
need to resume OS/8 explicitly.  There are a variety of ways
to do this.


## Getting Back to OS/8 from SIMH

There are several ways to get back to the simulated OS/8 environment
from SIMH context, each with different tradeoffs.

*FIXME*  We used to have a lot of trouble with continue commands.
We think they're all fixed now, so we can fully flesh out this section.


### Rebooting

You saw the first one above: send a `boot rk0` command to SIMH. This
restarts OS/8 entirely. This is good if you need a clean environment.
If you need to save state between one run of OS/8 and the next, save it
to the RK05 disk pack or other SIMH media, then re-load it when OS/8
reboots.

It's important to check that you got your OS/8 prompt so the recommended
code looks like this:

```
    reply = s.simh_cmd ("boot rk0", my_replies_rex)
    s.os8_test_result (reply, "Monitor Prompt", "myprog")
```

### Continuing

The way `teco-pi-demo` does it is to send a `cont` command to SIMH:

```
    s.send_line ('cont')
```

A previous version of the simh class would sometime hang the
simulator unless a small delay were inserted before escaping to
the SIMH context.  We believe this is no longer necessary.
However the problems with `cont` made implementors gun shy
using it.  Most code you will see does a restart with an explicit
confirmation we are at the OS/8 command level.


### Re-starting OS/8

If your use of OS/8 is such that all required state is saved to disk
before re-entering OS/8, you can call the `simh_restart_os8` method to
avoid the need for a delay *or* a reboot.

It sends the simh command `go 7600` which is the traditional "restart
at the OS/8 entrypoint" commonly used from the PDP-8 front panel.
It then uses `os8_test_result` to confirm that it got a monitor prompt.
`simh_restart_os8` has an optional `caller` argument to make it
quick and easy to print an error if returning to the monitor failed.

    s.simh_restart_os8 (caller = "myprog")

`os8-run` uses this option extensively.


## Sending without testing results.

At some point you always need to test your results and make sure
you are where you think you are.  Otherwise some corner case will
trip up your use of the simh class, and the error message you will
get is a 60 second pause, and a big backtrace.

But often you need to send and receive data in a much less structured
way than that used by `os8_cmd` and `simh_cmd`.  Here is what you need:

| Method           | Description                                                   |
|----------------  |----------------------------------------------------------------
| `send_line`      | Send the given line blind without before or after checks.
| `simh_send_line` | Like `send_line` above, but mindful of context. Will escape to SIMH if necessary.|
| `os8_kbd_delay`  | Wait an amount of time proportional to what OS/8 should be able to handle on the hosting platform without overflowing the input buffer and dying. |
| `os8_send_ctrl`  | Send a control character to OS/8.  Use `os8_kbd_delay` to prevent overflowin the input buffer and killing OS/8.|
| `os8_send_str`   | Send a string of characters to OS/8, and wait for os8_kbd_delay afterwards. |
| `os8_send_line`  | Add a carriage return to the given string and call `os8_send_str` to send it to OS/8.|


## Other Operations

### Quitting the simulator

It is recommended that you use the `quit` method to exit the simulator.
It will make sure it selects the simh context before trying to quit.

Indeed it's further recommended that you send a command to simh to
detach all devices to make sure any buffered output is flushed.
You need to test for the SIMH prompt to make sure you've succeeded.


```
  s.simh_cmd ("detach all")
  s.simh_test_result(reply, "Prompt", my_replies_rex, "myprog")
  s._child.sendline("quit")

```


### Zero Core

SIMH's PDP-8 simulator doesn't start with core zeroed, on purpose,
because the actual hardware did not do that.  SIMH does not attempt to
simulate the persistence of core memory by saving it to disk between
runs, but the SIMH developers are right to refuse to do this by
default: you cannot trust the prior state of a PDP-8's core memory
before initializing it yourself.


### Zero OS/8 Core

Sometimes we want to zero out core, but leave OS/8 in tact.
The `os8_zero_core` method zeros  all of core excepting:

 * 0. page zero - many apps put temporary data here
 * 1. the top pages of fields 1 & 2 - OS/8 is resident here
 *  2. the top page of field 2 - OS/8's TD8E driver (if any) lives here

We then restart OS/8, which means we absolutely need to do #1 and
may need to do #2.  We could probably get away with zeroing page 0.


## But There's More!

The above introduced you to most of the functionality of `class simh`
used by `teco-pi-demo`. It is a useful exercise to read through [the
simh class's source code][ssc]. There are many useful and interesting
methods in the simh class that are documented there not here. Although
it started off as a simple class amenable to quick study, some heavy
duty drivers for configuration of OS/8 devices under SIMH were added.
The source file is organized places the lower level methods first and
proceeds through progressively higher level ones, first for simh
direct interaction and the OS/8 interaction.

The `os8-run` script has a whole [higher level library][os8script]
built on top of the simh class that includes state machines for
executing complex commands like BUILD and applying patches with
ODT and FUTIL.

Another useful module is [`pidp8i.dirs`][dsc] which contains paths to
many directories in the PiDP-8/I system, which you can reuse to avoid
having to hard-code their locations.  This not only makes your script
independent of the installation location, which is configurable at build
time via `./configure --prefix=/some/path`, but also allows it to run
correctly from the PiDP-8/I software's build directory, which has a
somewhat different directory structure from the installation tree.

[ssc]: https://tangentsoft.com/pidp8i/file/lib/simh.py.in
[dsc]: https://tangentsoft.com/pidp8i/file/lib/pidp8i/dirs.py.in
[os8script]: https://tangentsoft.com/pidp8i/file/lib/os8script.py.in


## <a id="license" name="credits"></a>Credits and License

Written by and copyright © 2017-2020 by Warren Young and William Cattey.
Licensed under the terms of [the SIMH license][sl].

[sl]: https://tangentsoft.com/pidp8i/doc/trunk/SIMH-LICENSE.md
