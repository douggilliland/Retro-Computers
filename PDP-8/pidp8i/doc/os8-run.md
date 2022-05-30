# os8-run: A Scripting Language for Driving OS/8

## History and Motivation

In the beginning, the PiDP-8/I project shipped a hand-made and
hand-maintained OS/8 disk image. This image had multiple problems, and
sometimes the by-hand fixes to those problems caused other problems.

For the 2017.12.22 release, [we][auth] created a tool called `mkos8`
which creates this disk programmatically based on the user's configuration
choices. This has many virtues:

*   The OS/8 system media is created from pristine distribution media,
    rather than being built up in an undocumented *ad hoc* fashion.
    
*   The build sequence is documented in the source code of `mkos8`,
    rather than being a mysterious product of history, most of which
    happened before the OS/8 media came under version control.

*   The build products can be [tested][tm], because the process is
    purposefully done in a way that it is [reproducible][rb].

*   Because `mkos8` is written in Python, we have a full-strength
    scripting language for making the build conditional. The old manual
    process produced just one OS/8 system disk image, but the new scheme
    can now produce tens of thousands of different configurations.

That process worked fine for the limited scope of problem it was meant to
cover: creation of an OS/8 V3D RK05 image meant for use with SIMH's PDP-8
simulator, which was configured in a very particular way. It doesn't solve
a number of related problems that should be simple extensions to the idea:

*   What if we want a different version of OS/8, such as V3F?

*   What if we want this to happen on a storage device other than an
    RK05? Other common boot devices choices are RL01, RX02, and TD8E,
    and they all have consequences in the way you build the media.

*   What if we’re building media targeted at specific real PDP-8
    hardware, and thus need certain non-default choices for OS/8 device
    drivers? SIMH can be soft-reconfigured to accommodate whatever
    `mkos8` put out, but real hardware is what it is.

*   How do we make it drive other tools not already hard-coded into
    `mkos8` or its underlying helper library?

Shortly after release 2017.12.22 came out, Bill Cattey began work on
`os8-run` to solve these problems. This new tool implements a scripting
language and a lot of new underlying functionality so that we can not
only implement all of what `mkos8` did, we can now write scripts to do
much more.

The goals of the project are:

*   Entirely replace `mkos8`, in that `os8-run` plus a suitable script
    should be able to do everything that `mkos8` currently does.

*   Provide a suite of scripts and documentation support for creating
    one's own scripts to solve problems we haven't even anticipated.

*   Make it flexible enough to build media images suitable for arbitrary
    real PDP-8 hardware.


[auth]: https://tangentsoft.com/pidp8i/doc/trunk/AUTHORS.md
[rb]:   https://reproducible-builds.org/
[tm]:   https://tangentsoft.com/pidp8i/doc/trunk/tools/test-os8-run


## <a id="capabilities"></a>Capabilities

`os8-run` is a general script running facility that can:

* attach device image files with options that include but also go beyond what SIMH offers:
    * Protect image by attaching it read-only.
    * Recognize the use case of working with a pre-existing image, and abort the script if the image is not found, rather than creating a new, blank image.
    * Protect a master boot image that will not boot read-only by creating a scratch copy and booting the copy instead.
    * Recognize the use case of creating a new, blank image, but preserving any pre-existing image files of the same name.
* boot OS/8 on an arbitrary attached device image.
* create a duplicate of an existing file. This is the use case of building new image files from an existing baseline while preserving the baseline image file.
* copy files from the running OS/8 environment into the POSIX environment
running SIMH.
* copy files to the running OS/8 from the POSIX environment running SIMH.
* run any OS/8 command as long as it returns immediately to the OS/8 Keyboard
Monitor. This includes BATCH scripts.
* run `ABSLDR` and `FOTP`, cycling an arbitrary number of times through the OS/8
Command Decoder.
* run `PAL8` and report any errors encountered.
* run `BUILD` with arbitrarily complex configuration scripts, including
the `BUILD` of a system head that inputs `OS8.BN` and `CD.BN`.
* configure the `tti`, `rx`, `td`, and `dt` devices at run time to allow
shifting between otherwise incompatible configurations of SIMH and OS/8
device drivers.
* run included script files so that common code blocks can be written once
in an external included script.
* run of patch scripts that will use `ODT` or `FUTIL` to patch files in
the booted system image.
* perform actions in a script conditionally on feature enablement matching
an arbitrary keyword.
* perform actions in a script unless a disablement keyword has been specified.
* set enable or disable keywords anywhere in the execution of a script.


## <a id="expect"></a>Key Implementation Detail: Pexpect

Under the covers, `run-os8` is a Python script that uses the [Python
`pexpect` library][pex] to interact programmatically with SIMH and OS/8.
In principle, there is no limit to the complexity of the dialogs we can
script with this.

In practice, the major difficulty in constructing correct Pexpect
scripts is that if you fall out of step with what is "expect"ed, the
expect engine can get into a state where it is blocked waiting for
input that either never will arrive or that already passed by and now
can no longer be matched.  To avoid blocking forever in such situations,
`os8-run` configures Pexpect to time out eventually, resulting in a big
ugly Python backtrace.  The `os8-run` scripts that ship with the
PiDP-8/I software distribution should never do this, but as you write
your own, you may find yourself having to debug such problems.

Running `os8-run` with the `-v` option gives verbose output that
enables you to watch every step of the script as it runs.

[pex]: https://pexpect.readthedocs.io/


## <a id="conventions"></a>Conventions

In the documentation below, we use the term "POSIX" to refer to the
host side of the conversation or to resources available on that side.
We use this generic term because the PiDP-8/I software runs on [many
different platforms][osc], currently limited only to those that are either
POSIX-compliant (e.g. macOS) or those sufficiently close (e.g. Linux).
Thus, a "file from POSIX" refers to a file being copied from the host
system running `os8-run` and SIMH's PDP-8 simulator into the simulated
environment.

Very few script language commands fail fatally.  The design principle
was to ask, "Is the primary use case of this command a prerequisite
for other work that would make no sense if this command failed?"  If
the answer is, "yes", then the failure of command kills the execution
of the whole script and aborts `os8-run`.  Commands that have fatal
exits are mentioned specifically in the [command reference
section](#scripting) below.

### Case Sensitivity -- a tricky issue

It is expected that scripts will be written on the POSIX platform with
a case-sensitive text editor.  `os8-run` should be considered
case-sensitive as well. Scripts should specify the `os8-run` commands
and options in lower case, and the OS/8 commands, options, and
filenames in upper case.

POSIX is ostensibly a case-sensitive platform, filenames, commands
and command arguments are always case sensitive. This was a basic
design decision from the earliest days of ancestral Multics.

The OS/8 platform began as an upper-case only environment.  Only late in
the evolution of the PDP-8 as a word processing platform, did lower
case even exist on OS/8.  SIMH addresses this reality with two different
console device setups, `KSR` and `7b`.

In `KSR` mode, typed lower case characters are upcased automatically before
being sent to the running system.

In `7b` mode, all characters are passed to OS/8 without case conversion.

The current OS/8 default OS/8 system image run with this software distribution
is called `v3d.rk05`. It is configured to be as modern as possible.
It contains patches to force lower case characters typed to the Keyboard Monitor
to upper case so they will be understood.  A patch is made to OS/8
BASIC to do the same thing.  However many programs available for use under
OS/8 are upper case only, and get confused unless you set `CAPS LOCK` on
your keyboard.

All of the example scripts specify OS/8 commands in upper case.  Such
commands could have been specified in lower case, and would work just
fine if run in the default `v3d.rk05` system image.
However, since a basic use case of `os8-run` is to be able to run
scripts against arbitrary system images (which probably will not have
patches to deal with lower case), use of lower case for OS/8 commands,
arguments, or filenames is discouraged.

`os8-run` does not get involved with forcing OS/8 commands or filenames
to upper case if they appear as lower case in scripts. `os8-run` does
offer commands to toggle the SIMH console support between `KSR` and `7b`.
See the [`configure`](#configure-comm) command.

Although the `os8-run` commands and options could have been made case
insensitive, and the OS/8 commands, options, and filenames could have
been forced to upper case, rendering them case insensitive, there would
still be that aspect where the script developer would have to deal with
establishing case-sensitive POSIX filename conventions that would fit
with OS/8's upper case only filenames.  The decision was made to have
the scripting language require, mindfulness of case, where the developer
adopts a discipline to use lower case for scripting commands, and upper
case when dealing with OS/8.

Apologies in advance for the inconvenience of having to do that. Time
will tell if it was or was not the right decision to have been made.

[osc]: https://tangentsoft.com/pidp8i/wiki?name=OS+Compatibility


## <a id="first"></a>An Illustrative First Example

Here are some example `os8-run` scripts:

Example 1: Begin work on a new RK05 image that gets an updated version
of the OS/8 `BUILD` utility from POSIX source. (Perhaps it was found
on the net.)

    mount rk0 $bin/v3d.rk05 required
    mount rk1 $bin/os8-v3f-build.rk05 preserve
    
    cpto $src/os8/v3f/BUILD.PA RKA1:BUILD.PA /A
    
    boot rk0
    
    pal8 RKB1:BUILD.BN<RKA1:BUILD.PA
    
    begin cdprog SYS:ABSLDR.SV
    RKB1:BUILD.BN
    end cdprog SYS:ABSLDR.SV
    
    os8 SAVE RKB1:BUILD.SV

The above script does the following:

* Attach the system that will do the work on rk0. It must exist.
* Create a new rk05 image, `os8-v3f-build.rk05` but preserve pre-exising versions of the same image.
* Copy the source `BUILD.PA` from the POSIX environment to the OS/8 environment.
* Run `PAL8` to assemble `BUILD.PA` into `BUILD.BN`.
* Run `ABSLDR` to load `BUILD.PA` into memory.
* Save the run image of `BUILD` as an executable on `RKB1:` of the new rk05 image.


## <a id="paths"></a>POSIX Path Expansions

Notice in the [above example](#first) the use of the variables `$bin/`
and `$src/` in the POSIX path specifications.  These refer to particular
directories which vary depending on whether you run this script from
the PiDP-8/I source tree or from the installation tree.  Not only does
using these variables allow the same script to work in both trees, it
allows your script to run regardless of where those source and
installation trees are on any given system.

The scheme works much like predefined POSIX shell variables, but the
underlying mechanism is currently very limited.  First, the substitution
can only occur at the very beginning of a POSIX file specification.
Second, the only values currently defined are:

| $build/   | The absolute path to the root of the build.
| $src/     | The absolute path to the root of the source.
| $bin/     | The directory where executables and runable image files are installed at build time
| $media/   | The absolute path to OS/8 media files
| $os8mi/   | The absolute path to OS/8 media files used as input at build time
| $os8mo/   | The absolute path to OS/8 media files produced as output at build time

To add new values, modify `.../lib/pidp8i/dirs.py.in` and rebuild the
PiDP-8/I software.  Beware that changing this generates the `dirs.py`
file, which is a very deep dependency.  Touching this file will cause
all the OS/8 bootable system image files to be rebuilt, which can take
quite some time even on a fast host computer.


## <a id="contexts"></a>Execution Contexts

It is important to be mindful of the different command contexts when
running scripts under `os8-run`:

* __SIMH context:__  Commands are interpreted by SIMH command processor.
* __OS/8 context:__  Commands are interpreted by the OS/8 Keyboard Monitor.
* __`begin` / `end` blocks:__  These create special interpreter loops with their
own rules.

Examples of `begin` / `end` blocks:

* __Command Decoder:__  Programs like `ABSLDR` and `FOTP` call the OS/8 Command Decoder
to get file specifications and operate on them. `os8-run` uses a `begin` / `end` block to
define set of files to feed to the Command Decoder and to indicate the last file, and
a return to the OS/8 context.
* __OS/8 `BUILD`:__ Commands are passed to `BUILD` and output is interpreted.  The `end`
of the block signifies the end of the `BUILD` program and a return to the OS/8 context.
* __Conditional Execution:__ Blocks of script code, delimited by a `begin` / `block` can be
either executed or ignored depending on the key word that is enabled when that block
is encountered.  This context is very interesting and is more fully documented below.

The commands that execute in the OS/8 environment require a system image
to be attached and booted.  Attempts to run OS/8 commands without having
booted OS/8 kill the script.

Scripting commands such as `mount`, `umount`, and `configure` execute
in the SIMH context. OS/8 is suspended for these commands.

Ideally we would just resume OS/8 with a SIMH continue command when we are
finished running SIMH commands. Unfortunately this does not work under Python
expect.  The expect engine needs a command prompt.

Although hitting the erase character (`RUBOUT`) or the line kill character
(`CTRL/U`) to a terminal-connected SIMH OS/8 session gives a command prompt,
these actions don't work under Python expect. We don't know why.

Booting OS/8 gives a fresh prompt.

Restarting the OS/8 Monitor with a SIMH command line of \"`go 7600`\"
works.

The least disruptive way we have found to resume OS/8 under Python expect
after having escaped to SIMH is to issue the SIMH `continue` command, then
pause for an keyboard delay, then send `CTRL/C` then pause again, then send
`\r\n`.  That wakes OS/8 back up and produces a Keyboard Monitor prompt.

The simh.py code that underlies all this keeps track of the switch
between the SIMH and OS/8 contexts.  However it does not presume to
do this resumption because the `CTRL/C` will quit out of any program
being run under OS/8, and return to the keyboard monitor level.

Because `os8-run` creates the `begin` / `end` blocks with their own
interpreter loops, around commands with complex command structures,
it guarantees that the switch into SIMH context will only happen
when OS/8 is quiescent in the Keyboard Monitor.

Although `os8-run` provides a `resume` command that can appear in
scripts after the commands that escape out to SIMH, using it is optional.
`os8-run` checks the context and issues its own resume call if needed.


## <a id="usage"></a>Usage

> `os8-run` [`-h`] [`-d`] [`-v`] [`-vv`] [`--enable` _enable_option_] ... [`--disable` _disable_option_] ... _script-file_ ...

|                           | **Positional Arguments**
| _script-file_   | One or more script files to run
|                 | **Optional Arguments**
| `-h`            | show this help message and exit
| `-d`            | add extra debugging output, normally suppressed
| `-v`            | verbose script status output instead of the usual few progress messages
| `-vv`           | very verbose: Includes SIMH expect output with the verbose output.
|                 | **Known Enable Options**
| `focal69`       | Add `FOCAL69` to the built OS/8 RK05 image
| `music`         | Add *.MU files to the built OS/8 RK05 image
| `vtedit`        | Add the TECO VTEDIT setup to the built OS/8 RK05 image
|                 | **Known Disable Options**
| `ba`            | Leave *.BA `BASIC` games and demos off the built OS/8 RK05 image
| `uwfocal`       | Leave U/W FOCAL (only) off the built OS/8 RK05 image
| `macrel`        | Leave the `MACREL` assembler off the built OS/8 RK05 image
| `dcp`           | Leave the `DCP` disassembler off the built OS/8 RK05 image
| `k12`           | Leave 12-bit Kermit off the built OS/8 RK05 image
| `cc8`           | Leave the native OS/8 CC8 compiler off the built OS/8 RK05 image
| `crt`           | Leave CRT-style rubout processing off the built OS/8 RK05 image
| `advent`        | Leave Adventure off the built OS/8 RK05 image
| `fortran-ii`    | Leave FORTRAN II off the built OS/8 RK05 image
| `fortran-iv`    | Leave FORTRAN IV off the built OS/8 RK05 image
| `init`          | Leave the OS/8 INIT message off the built OS/8 RK05 image
| `chess`         | Leave the CHECKMO-II game of chess off the built OS/8 RK05 image
| `lcmod`         | Disable the OS/8 command upcasing patch. Used when SIMH has `tti ksr` set.


## Script Language Command Inventory

Here is a list of the `os8-run` scripting language commands in alphabetical order.


| [`boot`](#boot-comm)           | Boot the named SIMH device.                      |
| [`begin`](#begin-end-comm)     | Begin complex conditional or sub-command block.  |
| [`configure`](#configure-comm) | Perform specific SIMH configuration activities.  |
| [`copy`](#copy-com)            | Make a copy of a POSIX file.                     |
| [`cpfrom`](#copy-from-comm) | Copy *from* OS/8 into a file in POSIX environment.  |
| [`cpto`](#copy-to-comm)     | Copy POSIX file *to* OS/8 environment.              |
| [`disable`](#en-dis-comm)      | Set disablement of a feature by keyword.         |
| [`enable`](#en-dis-comm)       | Set enablement of a feature by keyword.          |
| [`end`](#begin-end-comm)       | End complex conditional or sub-command block.    |
| [`exit`](#exit-comm)           | Exit os8-run and send status                     |
| [`include`](#include-comm)     | Execute a subordinate script file.               |
| [`mount`](#mount-comm)         | Mount an image file as a SIMH attached device.   |
| [`ocomp`](#ocomp-com           | Run the OS/8 Octal Compare Utility.              |
| [`os8`](#os8-comm)             | Run arbitrary OS/8 command.                      |
| [`pal8`](#pal8-comm)           | Run OS/8 `PAL8` assembler.                       |
| [`patch`](#patch-comm)         | Run a patch file.                                |
| [`print`](#print-comm)         | Print information from running script.           |
| [`resume`](#resume-comm)       | Resume OS/8 at Keyboard Monitor command level.   |
| [`restart`](#restart-comm)     | Restart OS/8.                                    |
| [`umount`](#umount-comm)       | Unmount a SIMH attached device image.            |

These commands are described in subsections of [Script Language
Command Reference](#scripting) below. That section presents commands
in an order appropriate to building up an understanding of making
first simple and then complex scripts with `os8-run`.


## <a id="scripting"></a>Script Language Command Reference

### <a id="print-comm"></a>`print` - Print information from a running script.

`print` _output_

The simplest script command is `print` which allows display of status
information from the running script.  _output_ is simply displayed.
If the `verbose` option to `os8-run` is set, the line number of the 
print command is included in the output.


### <a id="exit-comm"></a>`exit` - Exit `os8-run` and send status.

`exit` [_status_]

The `exit` command allows immediate termination of the `os8-run` script.   

The _status_ argument is optional.  If the argument is an integer, `os8-run`
will return that status to the calling command shell.  This enables rich
signalling of status when `os8-run` itself is run as a script.

The _status_ argument can also be a string.  If a string is specified,
the status returned by `os8-run` to the command shell is 1, and the
string is printed on exit.  (This is the default behavior of the python
`sys.exit()` procedure.)


### <a id="include-comm"></a>`include` — Execute a subordinate script file.

`include` _script-file-path_

The script file named in _script-file-path_ is executed.  If no fatal
errors are encountered during that execution, then the main script
continues on.

A fatal error in an included script kills the whole execution of
`os8-run`.


### <a id="mount-comm"></a>`mount` — Mount an image file as a SIMH attached device.

`mount` _simh-dev_ _image-file_ [_option_ ...]

Because the primary expectation with `os8-run` scripts is that image
files are mounted, booted and operated on, the failure of a `mount`
command is fatal.


#### `mount` Options

| `new`      | If there is an existing file, rename it with a `.save` extension
|            | because we want to create a new empty image file. If there is
|            | already an existing `.save` version, the existing `.save` version is lost.
| `required` | _image-file_ is required to exist, otherwise abort the script.
| `preserve` | If _image-file_ already exists, create a copy with a version number suffix.
|            | This is useful when you want to prevent overwrites of a good image file
|            | with changes that might not work.  `os8-run` preserves all versions seen
|            | and creates new version that doesn't overwrite any of the previous ones.
| `readonly` | Passes the `-r` option to SIMH attach to mount the device in read only mode.
| `ro`       | Abbreviation for `readonly`.
| `scratch`  | Create a writeable scratch version of the named image file and mount it.
|            | This is helpful when you are booting a distribution DECtape.
|            | Booted DECtape images must be writeable. To protect a distribution DECtape,
|            | use the `scratch` option.  When all script runs are done, the scratch version
|            | is deleted.

Note that the `preserve` and `new` options approach preservation in fundamentally
different ways: `preserve` keeps all old copies, but `new` only keeps the most recent
copy.  This is because it is expected that the `new` option is used with the expectation
that old content is not precious, but that we have a backstop.  Whereas the expectation
of the use of `preserve` is that any and all old versions are precious and should be left
to a person explicitly to delete.

When new image files are created, some sort of initialization is necessary before
files can be written to them.  Although the `new` and `preserve` options could have
performed an OS/8 `ZERO` command to initialize the directories, it was decided
not to do so because in some cases, the OS/8 device drivers required to perform
such actions might not be active until farther down in a complex script.

 
#### `mount` Examples

Mount the `v3d.rk05` image, to be found in in the install directory
for runable image files, which must exist, on SIMH `rk0`.

    mount rk0 $bin/v3d.rk05 required

Mount the `advent.tu56` image, to be found in the media input directory,
which must exist, on SIMH `dt1` in read only mode, which will protect
it from inadvertent modification.

    mount dt1 $os8mi/subsys/advent.tu56 readonly required

Create a new image file in the media output directory, and mount it on
the SIMH `dt0` device.

    mount dt0 $os8mo/test_copy.tu56 new

Create a writeable copy of the distribution DECtape,
`al-4711c-ba-os8-v3d-1.1978.tu56`, to be found in the media input directory,
which must exist.  Mount it on SIMH dt0 ready for for a read/write boot.
Delete the copy when the script is done.

     mount dt0 $os8mi/al-4711c-ba-os8-v3d-1.1978.tu56 required scratch

Create a new image file `system.tu56` in the install director for
runable image files.  If the file already exists, create a new
version.  If the numbered version file exists, keep incrementing the
version number for the new file until a pre-existing file is not
found.

For example, if `system.tu56` was not found, the new file would be
called `system.tu56`.  If it was found the next version would be
called `system_1.tu56`.  If `system_1.tu56` and `system_2.tu56` were
found the new file would be called `system_3.tu56`, and so on.

     mount dt0 $bin/system.tu56 preserve

The `preserve` option is helpful when experimenting with scripts that may
not work the first time.


### <a id="umount-comm"></a>umount — Unmount a SIMH attached device image.

`umount` _simh-device_

This is just a wrapper for the SIMH `detach` command.

Here is the rationale for having added a `umount` command instead of
just calling the `detach` command from SIMH by its own same name:

Starting from the idea of providing some abstract but useful actions
to take around the SIMH `attach` command, the decision was made to
lean on the POSIX  `mount` command because people familiar with
`mount` were used to hanging lots of different abstract but useful
actions off of it.

`umount` was adopted as _what people familiar with `mount` would
expect as the command to undo what `mount` had done_. This seemed
preferable to inventing _`attach` with more features_ as a wholly
new syntactic/semantic design.


### <a id="boot-comm"></a>`boot` — Boot the named SIMH device.

`boot` _simh-device_

Boot OS/8 on the named _simh-device_ and enter the OS/8 run-time context.

The `boot` command tests to see if something is attached to the
SIMH being booted.  If nothing is attached, the command fails with a
fatal error.

This test does not protect against trying to boot an image lacking a
system area and thus not bootable.  This can't be tested in advance
because booting a non-bootable image simply hangs the virtual machine.
Heroic measures, like looking for magic system area bits in the image
file were deemed too much work.

If an attempt is made to boot an image with no system area, `os8-run`
hangs for a while and then gives a timeout backtrace.


### <a id="resume-comm"></a>`resume` — Resume OS/8 at Keyboard Monitor command level.

`resume`

The least disruptive way to resume operations under SIMH is to issue
the `continue` command. Although it took a while, we finally got this
command working reliably.  There were timing and workflow issues
that had to be resolved.

The `resume` command checks to see if OS/8 has been booted and refuses
to act if it has not.


### <a id="restart-comm"></a>`restart` — Restart OS/8.

`restart`

Equivalent to the SIMH command line of \"`go 7600`\", but which confirms
we got our Monitor prompt.

Before `resume` was developed, the next less disruptive way to get an
OS/8 Keyboard Monitor prompt was to restart SIMH at address 07600.
This is considered a soft-restart of OS/8.  It is less disruptive than
a `boot` command, because the `boot` command loads OS/8 into main
memory from the boot device, whereas restarting at location 07600 is
just a resart without a reload.

The `restart` command checks to see if OS/8 has been booted and refuses
to act if it has not.


### <a id="copy-comm"></a>`copy` — Make a copy of a POSIX file.

`copy` _source-path_ _destination-path_

The most common activity for `os8-run` is to modify a system image.

However, we often want to keep the original and modify a copy.
For example, the PiDP-8/I software build system creates the default
OS/8 RK05 disk image `v3d.rk05`, which in turn is a modified version
of `v3d-dist.rk05`.  We keep the latter around so we don't have to
keep rebuilding the baseline.

Instead of requiring some external caller to carefully preserve the
old file, the "make a copy with arbitrary name" functionality was
added by way of this command.

Adding an option to `mount` was considered, but in the interests
of allowing an arbitrary name for the modified image, a separate
command was created.


### <a id="copy-to-comm"></a>`cpto` — Copy POSIX file *to* OS/8 environment.

`cpto` _posix-path_ [_option_]

`cpto` _posix-path_ _os8-filespec_ [_option_]

The option is either empty or exactly one of

| `/A` | OS/8 `PIP` ASCII format. POSIX newlines are converted to OS/8 newlines.
| `/B` | OS/8 `PIP` `BIN` format. Paper tape leader/trailer may be added.
| `/I` | OS/8 `PIP` image format. Bit for Bit copy.

If no option is specified, `/A` is assumed.

**IMPORTANT:** Because we are parsing both OS/8 and POSIX file specifications,
we can't just parse out the slash in the options. Options must be preceded with
whitespace. Otherwise it would be mis-parsed as part of a file spec.

In the first form of the command, the OS/8 file specification is left
out, and one is synthesized from the file component of the _posix-path_.

This is how you get files *to* OS/8 from the outside world.  For
example, this enables source code management using modern tools.  The
builder script would check out the latest source and use an `os8-run`
script beginning with a `cpto` command to send it to OS/8 for
assembly, linking, installation, etc.

Example:

Copy a POSIX file init.cm onto the default OS/8 device `DSK:` under the name `INIT.CM`:

     cpto ../media/os8/init.cm


### <a id="copy-from-comm"></a>`cpfrom` — Copy *from* OS/8 to a file in POSIX environment. 

`cpfrom`_os8-filespec_ _posix-path_ [_option_]

The option is either empty or exactly one of

| `/A` | OS/8 `PIP` ASCII format. POSIX newlines are converted to OS/8 newlines.
| `/B` | OS/8 `PIP` `BIN` format. Paper tape leader/trailer may be added.
| `/I` | OS/8 `PIP` image format. Bit for Bit copy.

If no option is specified, `/A` is assumed.

**IMPORTANT:** Because we are parsing both OS/8 and POSIX file specifications,
we can't just parse out the slash in the options. Options must be preceded with
whitespace. Otherwise it would be mis-parsed as part of a file spec.

Unlike `cpto` there is only one form of the command.  Both the
_os8-filespec_ and the _posix-path_ must be specified.  The options
are the same for both `cpfrom` and `cpto`.

Copy files from the running OS/8 environment to the POSIX environment running SIMH.

Example:

Copy a listing file into the current working directory of the
executing `os8-run`:

    cpfrom DSK:OS8.LS ./os8.ls /A


### <a id="os8-comm"></a>`os8` — Run arbitrary OS/8 command.

`os8` _os8-command-line_

Everything on the script command line after \"os8 \" is passed,
uninterpreted, to the OS/8 keyboard monitor with the expectation that
the command will return to the monitor command level and the command
prompt, "`.`" will be produced.

This command should be used ONLY for OS/8 commands that return
immediately to command level.  `BATCH` scripts do this, and they can
be run from here.

The `os8` command is aware of a special enablement keyword: `transcript`.
(See the [`enable` \ `disable`](#en-dis-comm) section below.)
If `transcript` is enabled, the output from running the OS/8
command line is printed.  

For example, if you wanted to display the contents of a DECtape image
you are constructing but no other command lines fed to the `os8`
command you would do this:

```
enable transcript
os8 DIR DTA0:
disable transcript
```

This transcript capability provides a fine grained debugging aid.


### <a id="pal8-comm"></a>`pal8` — Run OS/8 `PAL8` assembler.

Actually, the `PAL8` assembler can be called just fine
by using the `os8` command, for example:

    os8 PAL8 RKB1:RL0.BN<RKA1:RL0.PA
   
However, an separate pal8 command was created to enable richer display
of errors.

Examples:

Create a binary `OS8.BN` on partition B of rk05 drive 1 from `OS8.PA`
source file found on partition A of rk05 drive 1.

    pal8 RKB1:OS8.BN<RKA1:OS8.PA

Create a binary `OS8.BN` on partition B of rk05 drive 1 and a listing
file `OS8.LS` on the default device `DSK:` from `OS8.PA` source file
found on partition A of rk05 drive 1.

    pal8 RKB1:OS8.BN,OS8.LS<RKA1:OS8.PA


### <a id="ocomp-comm"></a>`ocomp` — Run OS/8 `OCOMP` Octal Compare and Dump Utility.

This command was added to allow file verification.  It wraps a call to the
OS/8 `OCOMP` utility with some expect parsing to recognize when two files
are identical, or when one is missing.

A typical command line would look like this:

    ocomp TTY:<DTA1:E8.SV,SYS:E8.SV

To confirm that the `E8` executable on `SYS:` matches the one found on the
image mounted on `DTA1:`

Note that, although one can use the full power of the `OCOMP` utility, the setup
here in `os8-run` considers anything other than the "NOTHING OUTPUT" indicating
identical files to be a "failure".

However, the `transcript` option is available so that octal dumps can be
produced. For example, the script:

    mount rk0 $bin/v3d.rk05 required scratch
    boot rk0

    enable transcript
    ocomp TTY:<PS.C

produces the following output

    $ bin/os8-run scripts/test/ocomp.os8 
    Running script file: scripts/test/ocomp.os8
    TTY:<PS.C
    0000   ( ABSOLUTE BLOCK 2302 )
    0000  5257 0252 7320 4762  5356 0364 7720 1741  7343 6341 5247 0363
    0014  7364 4762 7341 3756  5354 0345 4252 6657  5212 5257 7240 7311
    0030  7366 5757 7745 3640  7351 4364 6240 2656  5330 0305 6703 1303
    0044  7240 7341 7344 2640  7356 2764 7762 2240  7750 1751 7240 4746
    0060  7354 7345 5355 0345  4252 6657 4212 5215  5215 1612 7344 3345
    0074  7351 2756 6240 7703  6725 2316 5640 2261  4215 6612 7212 4611
    0110  5356 0364 6741 5762  6662 6660 5254 6351  4352 6673 4212 5215
    0124  7751 2356 7240 0755  5351 4356 4251 5215  4373 5215 7211 7746
    0140  5362 4240 5751 0675  5673 6351 6703 2717  5716 5724 5351 5653
    0154  7651 5640 4215 4612  7611 1341 6733 6751  5675 5661 4215 4612
    0170  7211 7746 5362 4240  7352 4675 5655 5661  5752 0676 5273 6752
    0204  4255 6651 4212 4611  7611 1341 6733 6752  7675 1341 5333 6752
    0220  5261 5735 6741 5762  5752 5735 4215 4612  7211 7746 5362 4240
    0234  5752 0275 5673 6352  5262 4252 6703 2717  5316 6724 5751 0655
    0250  7251 5273 5253 4653  4215 4612 7611 0211  7365 1764 5250 0247
    0264  5647 5651 4215 4612  7211 7746 5362 4240  5752 0675 5673 6352
    0300  5751 0653 5273 5752  4253 6651 4212 4611  7611 1360 7751 2356
    0314  5346 1250 7245 2264  7242 0654 7362 5333  5735 5651 4215 4612
    0330  7611 1360 7751 2356  5346 1250 6734 6362  5356 4642 4273 5215
    0344  4211 6775 7612 0211  7362 7351 5364 4346  7242 7703 7355 6360
    0360  7345 2764 7744 1334  5334 1356 4251 6673  4212 6775 0212 0232
    0374  0000 0000 0000 0000
    Non-fatal error encountered in scripts/test/ocomp.os8 at line 5:
    	ocomp TTY:<PS.C

Note how `os8-run` complains about a non-fatal error.  Again, this is because
the use-case is for detecting two identical files, and calling everything else
a failure.

### <a id="begin-end-comm"></a>`begin` / `end` — Complex conditionals and sub-command blocks.

`begin` _keyword_ _argument_

`end` _keyword_

_keyword_ is either one of the following:

| `cdprog`  | Command loop through OS/8 Command Decoder with _argument_ specifying |
|           | an OS/8 executable program by name and (optionally) device.|
| `build`        | `BUILD` command interpreter with dialogs manged with Python expect.    |
| `enabled`      | Execution block only if _argument_ is enabled. (See the [`enable` \ `disable`](#en-dis-comm)) section below. |
| `default` | Execution block that runs by default but is ignored if _argument_ is disabled. |
|           | (See the [`enable` \ `disable`](#en-dis-comm) section below.) |
| `version` | Execution block that runs if the current version of the `os8-run` |
|           | scripting language is equal to or greater than the specified version string. |
|           | (See [version test](#vers-test) below.)|

For `cdprog`, and `build`, _argument_ is passed uninterpreted to the
OS/8 `RUN` command.  It is expected that _argument_ will be the name
of an executable, optionally prefixed by a device specification. This
enables running the OS/8 command from specific devices. This is
necessary for running specific `BUILD` command for construction of
system images for specific versions of OS/8 that are __different__
from the default run image.

Example:

Run `FOTP.SV` from device `RKA0` and cycle through the command decoder
to copy files onto a DECtape under construction from two different
places: the old system on `RKA0:` and the newly built components from
`RKB1:`.

    begin cdprog RKA0:FOTP.SV
    DTA0:<RKA0:FOTP.SV
    DTA0:<RKA0:DIRECT.SV
    DTA0:<RKB1:CCL.SV
    DTA0:<RKB1:RESORC.SV
    end cdprog RKA0:FOTP.SV

The `build` command has had a lot of work put into parsing dialogs.
This enables not only device driver related `BUILD` commands of
`LOAD`, `UNLOAD`, `ENABLE` and `DISABLE`, but also answers "yes" to
the "ZERO SYS" question when the `BOOT` command is issued on a brand
new image file.

Example:

Build a rudimentary system for a TC08 DECtape.

    begin build SYS:BUILD
    DELETE SYS,RKA0,RKB0
    DELETE RXA0
    INSERT RK05,RKA0,RKB0
    SYSTEM TC08
    INSERT TC08,DTA0
    INSERT TC,DTA1
    DSK TC08:DTA0
    BOOT
    end build


Most importantly there is full support for the dialog with the `BUILD`
command within the `BUILD` program to create a new OS/8 system head
with new versions of `OS8.BN` and `CD.BN` assembled from source.

Example:

To create a system tape with new OS/8 Keyboard Monitor and Command
Decoder, the above example would add the following just before the
`BOOT` line:

    BUILD DSK:OS8.BN DSK:CD.BN

Note: OS/8 disables the `BUILD` command within the `BUILD`
program after it has been issued during a run.  Traditionally, the
first action after a `BOOT` of a newly built system is to `SAVE` the
just executed memory image of `BUILD`.  That saves all the device
configurations, but also saves a version with the `BUILD` command
within the `BUILD` program disabled.

For this reason, you have to run a fresh version of `BUILD` from
distribution media rather than one saved from a previous run.  This
situation is what drove support for the _argument_ specifier to name
the location of the program to run rather than always running from a
default location.

Also, `BUILD` is too sensitive to the location of the `OS8.BN` and
`CD.BN` files. It pretty much only works if you use `PTR:` or `DSK:`.
Anything else seems to just hang.  I believe the root cause is that,
although the device and file are parsed, the actual device has to be
either `PTR:` or the active system device.

`os8-run` contains two lists of keywords that have been set as enabled
or disabled.  The setting is done either with `os8-run` command line
arguments or with the `enable` and `disable` commands (documented
below.)

Two lists are required because default behavior is different for
enablement versus disablement.

The `begin enabled` block is only executed if the `enabled` list
contains the keyword. If no such keyword is found, the block is ignored.

The `begin default` block is executed by default unless the `disabled`
list contains the keyword. If such a keyword is found, the block is ignored.

The `default` construct allows creation of scripts with conditional
execution  without worrying about informing the build system about new
enablement keywords.
 
All these conditional and sub-command blocks must terminate with an
`end` command.  The _keyword_ of the end command must always match the
_begin_ command.  The argument of `enabled` and `default` blocks
must also match. Nesting is possible, but care should be exercised to
avoid crossing nesting boundaries.

For example:

    begin enabled outer
    begin enabled inner
    end enabled inner
    end enabled outer

is correct, but:

    begin enabled first
    begin enabled second
    end enabled first
    end enabled second

is an error.


### <a id="en-dis-comm"></a>`enable` / `disable` — Set an enablement or disablement.

`enable` _keyword_

`disable` _keyword_

The `enable` and `disable` commands are used within scripts to
dynamically set enablement and disablement.  This expands the scope of
conditional execution beyond setting passed in from the `os8-run`
command line.

As mentioned above, there are two lists of keywords, one for `enabled`
keywords and one for `disabled` keywords.

The `enable` command not only adds the keyword to the `enabled`
list. It also looks for the keyword on the `disabled` list.  If the
keyword is found on the `disabled` list, it is **removed**.

Similarly, the `disable` command adds the keyword to the `disabled`
list, and searches the `enabled` list for the keyword.  If it is found
on the `enabled` list, it is removed.

A keyword, will appear only once, if present at all, and will be on
only one of the two lists.

The rule is: Last action wins.

Why all this complexity? Here is an example we tripped over and had to
implement:  We normally apply patches to the version of `FUTIL` that
came on the OS/8 v3d distribution DECtapes.  We also have an add-on
for the `MACREL` assembler.  That add-on contains a version of `FUTIL`
with updates required to work with binaries assembled with `MACREL` v2.
The `v3d-rk05.os8` script needed to either avoid trying to
patch an updated `FUTIL` if `MACREL` was present, or to perform the
patching action if `MACREL` was not present.

A further complication is that we opt in to including the `MACREL`
add-on by default.  We deal with this triple negative by setting
`disable futil_patch` by default, unless `macrel` gets disabled:

    # MACREL is enabled by default with no settings.
    # We need to avoid patching FUTIL in that default case
    # So we have to set a disablement of that action
    # Conditional on macrel default as well.
    
    begin default macrel
    disable futil_patch
    end default macrel
    
    begin default futil_patch
    # The two FUTIL patches only get applied to FUTIL V7 which comes with
    # OS/8 V3D to bring it up to V7D.
    # MACREL V2 comes with FUTIL V8B, so these patches are skipped
    # unless we pass --disable os8-macrel to configure.
    patch ../media/os8/patches/FUTIL-31.21.1M-v7B.patch8
    patch ../media/os8/patches/FUTIL-31.21.2M-v7D.patch8
    end default futil_patch


### <a id="vers-test"></a> version test

The `os8-run` scripting language is expected to evolve over time.  An internal
language version number is kept, and incremented when major or minor changes
are made to the language.

This version numbering scheme can be detected and acted upon within a script
by specifying a `version` match string in a `begin` / `end` block.

The language version string is sequence of numerical sub version numbers of arbitrary
depth separated by periods. Examples of valid language version strings:

    3
    3.1
    3.10
    3.10.1

Each sub version is an integer of arbitrary precision.

Clarifying exmple:  3.10 is higher than 3.1.0.

No whitespace is allowed within a version match string.


Therefore a conditional block requiring language version 2.0 and higher
would look like this:

    begin version 2.0
    # The symprini command exists only in version 2 and above.
    symprini
    end version 2.0


### <a id="patch-comm"></a>`patch` — Run a patch file.

`patch` _patch-file-path_

Run _patch-file-path_ file as a script that uses `ODT` or `FUTIL` to
patch the booted system image.


### `configure` — Perform specific SIMH configuration activities.

`configure` _device_ _setting_

The settings are device specific:

| -------- | --------------------------------------------------------------- |
| **tape** | **DECtape device settings**                                |
| `dt`     | Set TC08 operation by enabling `dt` as the SIMH DECtape device. |
| `td`     | Set TD8e operation by enabling `td` as the SIMH DECTape device. |
| -------- | --------------------------------------------------------------- |
| **tti**  | **Console terminal input device settings**               |
| `KSR`    | Upper case only operation. Typed lower case characters    |
|          | are upcased automatically before being sent to OS/8      |
| `7b`     | SIMH 7bit mode.  All characters are passed to OS/8       |
|          | without case conversion.                                 |
| -------- | --------------------------------------------------------------- |
| **rx**   | **Floppy Disk device settings**                          |
| `RX8E`   | Set the SIMH `rx` to `RX8E` mode compatible with RX01    |
|          | Floppy Disk Drives.                                      |
| `RX28`   | Set the SIMH `rx` to `RX28` mode compatible with RX02    |
|          | Floppy Disk Drives.                                      |
| `rx01`   | Synonym for the `RX8E` option. Compatible with RX01.     |
| `rx02`   | Synonym for the `RX28` option. Compatible with RX02.     |
| -------- | --------------------------------------------------------------- |

This command allows reconfiguration of the SIMH devices during the
execution of a `os8-run` script.  This command makes it possible to
create system images for hardware configurations that are not what are
commony used for OS/8 operation under SIMH.

The best example is the dichotomy between TD8e and TC08 DECTape.

TC08 is a DMA device. It is trivial to emulate. The SIMH device driver
simply copies blocks around in the .tu56 DECtape image.

TD8e is an inexpensive, DECtape interface on a single hex width card
for PDP8 hardware supporting the Omnibus&tm.  The CPU does most of the
work. Although a SIMH emulation is available for TD8e, it runs
perceptably and often unacceptably more slowly than the simple TC08
emulation.

However, hardware in the field most often has the TD8e DECtape because
it was inexpensive.

By allowing reconfiguration inside a script, we can use TC08 by
default, switch to TD8e to run `BUILD` and create .tu55 tape images
suitable for deployment on commonly found hardware out in the real
world. 


## TODOs

* Add sanity check parse of sub-commands to confirm command. **OR** Change the 
begin command to treat _argument_ not as a full command, but merely
a device from which to fetch the command.  Maybe make _argument_ optional.


## Notes

* No notes as of yet.

### <a id="license"></a>License

Copyright © 2018 by Bill Cattey and Warren Young. Licensed under the
terms of [the SIMH license][sl].

[sl]: https://tangentsoft.com/pidp8i/doc/trunk/SIMH-LICENSE.md
