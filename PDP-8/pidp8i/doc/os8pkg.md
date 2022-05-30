# os8pkg: A package manager for OS/8

## Motivation

The [os8-run][os8run] language/execution environment allows scripting
under OS/8 that interfaces to the SIMH simulator and to the host POSIX
environment.  The scripts can build subsystems, but managing dependencies,
and integrating the subsystems into bootable media is a missing piece.

`os8pkg` supplies the missing piece. It is integrated into the automake
and Makefile to re-run the builder scripts when necessary.  It manages
the information needed to take the built package and install it onto
bootable media.

## Commands

 * `deps` -- Emits a `.mk` Makefile include for dependencies of each of the
   packages specified on the command line.

 * `include` -- Emits `pkgs.os8` that is a master include file
   used by the .os8 script that wants to install all selected packages.
   **All** desired packages must appear in a single run of `os8pkg include`.

 * `install` -- Parses the .pspec file. Finds the installable package.
   Performs the relevant os8 COPY commands to install the package
   on bootable image specified by --target.  $os8mo/v3d.rk05 if no --target.

 * `uninstall` -- On a specifiec target image file, parse the pspec file
   to identify output files to remove. Remove them from the bootable image
   specified by --target. $os8mo/v3d.rk05 if no --target specified.
   Additionally remove files listed in the cleanups section.

 * `build` -- Run the builder, whether it be the lines from the `build:` section
   or the default build script.  **NOTE:** Use care when building with
   `build:` lines in the `.pspec` file.  The assumption is that your current
   working directory is the top level of the build environment.

 * `all` -- Perform `deps`, then `build` then `install` on the named packages.

 * `conflicts` -- Given a list of packages, reports on any files appearing
   in more than one package.  The case of the same file landing on two
   different destination devices is covered by reporting the package,
   the destination device, and the filename, even if only the filename matches.

 * `verify` -- Given a list of packages and a target image file, verify for
   each package that the files named in `outputs:` are present in the target
   image, and are the same as what is on the built package image file.

The `auto.defs` scans `$srcdir/pspec` and runs the deps command on every
`.pspec` file found there.  This sets the stage to build every known package.

`auto.defs` also evaluates the configuration and determines what
subset of those packages are selected for install on system boot images.
It defines the Makefile variable `@OS8_PKGS_INSTALLED@` with that subset.

`Makefile.in` uses `@OS8_PKGS_INSTALLED@` to call `os8pkg include` to
construct  `.../obj/os8pkgs/pkgs.os8` which is used in boot image build
script to install all configured packages.


## The `.pspec` File

The required dependency and integration information is stored in a file named
for the package being managed with a '.spec` extension.  This file enables creation
of the makefile dependencies and the installer `os8-run` script.

### Searching for .pspec files

By default, all `.pspec` files live in a source top-level `pspec/`
directory. However, `os8pkg` can manipulate target bootable images in
arbitrary locations to install and uninstall packages by name using
`.pspec` files in arbitrary locations. `os8pkg` searches for `.pspec`
files in the following order:

1. The path found by treating naming the package with a POSIX path. For example:

    os8pkg install ~/dev/mypackage.pkg

2. A path provided with the `--destdir` option. (Which also specifies where to
look the bootable image. For example:

    bin/os8pkg -d 10 --destdir /opt/pidp8i/share/media/os8 install mypackage

3. The path found by `$src/pspec/` (the build system default expectation.)
for example:

    bin/os8pkg install mypackage

### Syntax

Blank lines are allowed. They're ignored.

A line beginning with \"#\" is ignored as a comment.

Leading whitespace on a line is ignored to allow human-readability-improving
indentation.

### Sections

Different sections of the `.pspec` file recored different required infomation.

The parser is very simple minded.  Every section is parsed into the list of
lines found associated with that keyword.

A section begins with a line consisting solely of the keyword.  Every line seen
until a new keyword line is appended to the associated line list.

If the parser sees a line before ever having seen a keyword line, it complains
that it doesn't know what to do.

There can be multiple occurrances of a section in the `.pspec` file.  The parser
happily just adds more lines to that sections list of lines.

 * `format:` The format of the package created. It needs to be a valid OS/8 device
 image file.  Currently tu56 and rk05 are supported.  It is expected that addtional
 formats such as rl02 and rx02 will be supported in the future.  If multiple lines
 or instances of the `format:` section appear, the last one wins.

 * `inputs:` Files that are needed to build the subsystem. This is the list of
 dependencies passed to make.  POSIX wild carding is allowed.

 * `outputs:` A specification of what outputs are integrated into the
 target media from the package file.  This looks like an OS/8 command
 decoder file copy specification. However, no wild-carding is allowed
 because outputs is also used for uninstall. Wild cards on uninstall would
 wreck havoc.

 * `cleanups:` A list of files that should also be cleaned up when uninstalling
 a package.

 * `build:` A default build runs an os8-run script found in `.../scripts/misc` with a
 name composed from the package name, and the package format with a `.os8` extension.
 It includes dependencies on `.../bin/os8pkg`, the files in `inputs:`, the os8-run
 script, and on the OS8_TOOLTIME run image.
 
 For example: the `e8` package with the tu56 format would have a default build that
 would depend upon, and run `.../scripts/misc/e8-tu56.os8`.

 When the build: section is filled in, this default is not used. Instead a Makefile
 rule is created that passes in the lines found in the build: section.

### Crafting `outputs:`

The challenge is to create package files that are usable in the
creation of a wide variety of bootable media, and to have flexibility
in the package format.

To make sense of the challenge consider the questions:

 * How do we create a simple tu56 format image that can be used in
   creation of tu56 bootable images?

 * How do we create a rich, large sized rk05 image that can be use in
   creation of both tu56 and rk05 bootable images?

We want to be able to have a system device mounted and the package
image mounted at the same time.  For this reason we synthesize the
os8-run mount and copy commands presuming there will be a system
device mounted on either rk0 or dt0 under SIMH, and that the package
image gets mounted on either rk1 or dt1.

So each `outputs:` line consists of a constrained destination device, a
less than sign (pronounced "comes from" in OS/8 parlance), and
constrained input specification that is aware of what `format:` we are
using, and constrains the device specification.

os8pkg Flags an error if the line in `outputs:` fails to meet the constraints.

### Examples

#### verify

Without the verbose option set, the output names the package and the
target image.  If successful, there is no other output.

    $ bin/os8pkg verify e8
    Verifying package e8 on /Users/wdc/src/pidp8i/trunk/bin/v3d.rk05

With the verbose option set, the individual files are reported on:

    $ bin/os8pkg -v verify e8
    Verifying package e8 on /Users/wdc/src/pidp8i/trunk/bin/v3d.rk05
    Successful verify of SYS:E8.SV
    Successful verify of DSK:E8CMDS.TX
    Successful verify of DSK:E8SRCH.TX


[os8run]:  https://tangentsoft.com/pidp8i/doc/trunk/os8-run.md

### <a id="license"></a>License

Copyright © 2020 by Bill Cattey. Licensed under the terms of [the SIMH license][sl].

[sl]: https://tangentsoft.com/pidp8i/doc/trunk/SIMH-LICENSE.md
