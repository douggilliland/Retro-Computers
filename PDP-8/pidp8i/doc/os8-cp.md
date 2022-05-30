# os8-cp: A tool to copy files to and from OS/8 running in SIMH

## Motivation

There have been various tools for copying files between OS/8
device image files and the platform hosting those image files.
For example, the graphical [OS8View by Ian Schofield][os8view-forum].

This tool was designed to be called from the command line in the POSIX
environment, and to interface between the POSIX filesystem and OS/8
running underi SIMH.

The semantics are like the POSIX `cp` program, except that a source or
destination containing a colon is interpreted to refer to files within
OS/8.

Additional arguments allow for specifying how the simulation is configured
and booted. I.E. various POSIX files containing OS/8 device images are
attached to SIMH.

The reason why direct copy into and out of image files was not pursued
was that is seemed easier to use OS/8 and SIMH tools to copy files around
rather than learning the low level directory formats and binary data
representations for the various OS/8 image files.  Anything that can
be moved around by `PIP` under OS/8 is fair game for `os8-cp`.

The tool is written in Python and utilizes the pexpect library for
starting up and communication with SIMH.

## Capabilities

* Copy files from and to OS/8 booted up under SIMH.
* In ASCII text mode, convert between OS/8 and POSIX newline codings.
* Allow attaching of arbitrary image files to arbitrary devices.
* Copy files within OS/8 if both source and destination specify OS/8 rather than POSIX names.
* For POSIX file specifications expand directories to lists of files, and use POSIX
style globbing to expand wild cards.
* For OS/8 file specificaitons, allow appropriate wild carding as well.

## Limitations

The architecture of OS/8 makes it impossible to operate with a write-locked
boot device.  (Many would argue that this is a serious defect, and I agree.
However this is the reality we are dealing with.)

This means that there really should only be one instance of `os8-cp`
manipulating a particular bootable image at a time.

When this tool was used in a Makefile, care had to be taken with dependencies
so that a parallel make would never run more than a single instance of
`os8-cp`.

There are a couple ways that this could be dealt with:

* Create a scratch image for the running boot image:  The problem with this
is that often os8-cp is used in the manipulation of a boot image to be used
later by others.  A scratch image would carefully throw away any such work.

* Manage a lock file that would be checked at run-time: This would actually work.
Indeed a lock file with a name based on the path to the boot image would allow
multiple instances of os8-cp acting on different boot images to run simultaneously.
The downside is complexity.  Lock files in Python are platform specific, so
Linux, Windows, BSD, etc platforms might require specific code.  Cleanup of
the lock file on any kind of abnormal exit would have to be managed.  And
design of what to do when waiting for the lock.

Ultimately the implementation decision was:  Be careful not to run
multiple instances os8-cp in parallel against the same boot image file.

## Usage

> `os8-cp` [`-dhvq`] [-<_dev_><_unit_>[`s`] _image_] ... [[`-abiyz`] <_src_>] ... <_dest_>
> `os8-cp` [`-dhvq`] [`--action-file` _action-file_]

| <_dev_>   | **Device**: one of `rk`, `td`, `dt`, `rx`, corresponding to SIMH PDP-8 devices
| <_unit_>  | **Unit**: must be a valid unit number for the device in both SIMH and
|           | the booted OS/8 system. A unit number is required.  Following
|           | the unit with an "s" names the system device to boot.  The
|           | system image file must exist, and contain a working boot
|           | image.  Only one designated system device is allowed.
| <_src_>   | **Source**: is a source file or wild card specification.
| <_dest_>  | **Destination**: is a destination file if a single _src_ file is specified;
|           | if multiple <_src_> files are given, it is either a POSIX
|           | directory or an OS/8 device name.

 Specifying an action file overrides any device or file argument
 previously specified on the command line.

 Example:
 
    os8-cp -rk0s os8v3d-patched.rk05 -dt0 scratch.tu56 -a prog.pa DTA0:PROG.PA 

### Further Details

The copying direction is determined by which file name arguments have a colon in them:

* copy-within: The source and destination file arguments have
colons, so copy within the OS/8 environment from one volume to
another.

* copy-into: Only the dest argument has a colon, so assume the
source file names are POSIX-side and copy those files into the
SIMH OS/8 environment.

* copy-from: The dest argument has no colon but the source file
names do, so copy the named OS/8 files out from the simulation.

If none of the file arguments has a colon in it and you give exactly
two such arguments, we operate in a special case of copy-within
mode: the source and destination volumes are assumed to be DSK:, so
the file is simply copied within the OS/8 DSK: volume from one name
to the other.  If you give greater than two file name arguments
without a colon in any of them, it is not possible to make sense of
the command since we do not intend to try and replace your perfectly
good POSIX cp implementation, so it errors out.

If you give only one file name argument, the program always errors
out: it requires at least one source and one destination.

The `-a`, `-b`, `-i`, `-y`, and `-z` flags correspond to the OS/8 PIP options:

| flag | `PIP` | Description
|------|-------|----------------------------------------------------------
| `-a` | `/A` | ASCII format.  OS/8 and POSIX newlines are translated.
|      |      | Such transfers are lossless if line endings are  well-formed.
| `-b` | `/B` | Binary OS/8 ABSLDR format with leader/trailer and other
|      |      | specific formatting that is detected and enforced by PIP.
| `-i` | `/I` | Image mode.  Files are copied byte for byte verbatim.
| `-z` | `/Z` | ZERO directory of destination OS/8 device.
| `-y` | `/Y` | Yank system area from source to destination.

If no format flag is set, the default transfer format is `/I`.

(This priogram currently uses PIP as its primary handler for the
OS/8 side of the work.)  They must be followed by at least one source
file name, and they affect all subsequent source file names until
another such option is found.  For example:

    $ os8-cp -a foo bar -b qux sys:

Files foo and bar are copied to SYS: in ASCII mode, overriding the
default binary mode, then binary mode is restored for the copy of
file qux to the SYS: volume.

Beware that -i means something very different to this program than
it means to POSIX cp: destination files will be unceremoniously
overwritten!

More about image file mounts:

image files for non-boot dev specifications, if they do not
already exist, are created. Their directories are initalized
with the ZERO command. Multi-partition devices initialize all.

A future version will include a default system device if
no dev system mount is made.

Examples:

    $ os8-cp -td0s my.tu56 -rk0 my.rk05 foo DSK:

...will boot from my.tu56, which is presumed to be a bootable OS/8
DECtape attached to SIMH device TD0.  The RK05 disk image my.rk05
will be attached to RK0, since the default boot disk is not attached
there in this example.  It will copy POSIX-side file foo to DSK:FOO
which will probably be interpreted as DTA0:FOO by the typical BUILD
options for a bootable OS/8 TU56 DECtape.  Beware therefore of using
the generic SYS: and DSK: device names!  You would be better advised
to use DTA0:, RKA0: or RKB0: as the destination in this example.

    $ os8-cp -td0s my.tu56 -rx1 my.rx01 foo RXA1:

This fixes the almost-certainly incorrect use of DSK: in the prior 
example.

The -dt and -td options are handled similarly to the -r* options,
differing only in whether we use the SIMH DT or TD PDP-8 devices,
which correspond to the TC08 or TD8E DECtape controllers.  Which one
you give depends on the device support built into the OS/8 media
you've booted from.

### More about _src_ and _dest_ specifications:

When only a destination device, directory, or volume name is given,
file names are normalized when coping between POSIX and OS/8
systems.  File names are uppercased and truncated to 6.2 limits when
copying into OS/8.  File names are lowercased on copying from OS/8
unless you give the *source* file name in all-uppercase.
Then file name case is preserved.  This behavior is overridden
if you give a complete file name for the destination:

    $ os8-cp my-long-file-name.txt DSK:MLF.FD

If you gave "DSK:" as the destination instead, you would have gotten
"MY-LON.TX" as the desintation file name instead.

### Run-time Options:

| `-d`    | run in debug mode.
| `-v`    | enable verbose status reporting.
| `-h -v` | print detailed usage message.


[os8view-forum]: http://groups.google.com/forum/#!topic/pidp-8/1hojqAATum4

## TODOs

* No TODOs as of yet.

## Notes

* No notes as of yet.

### <a id="license"></a>License

Copyright © 2018 by Bill Cattey and Warren Young. Licensed under the
terms of [the SIMH license][sl].

[sl]: https://tangentsoft.com/pidp8i/doc/trunk/SIMH-LICENSE.md
