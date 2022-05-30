# PiDP-8/I Changes

<a id="20210214"></a>
## Version 2021.02.14 — The Quarantine Release

*   Raspberry Pi 4 support.

*   Increased SD card requirement from 2 GB to 8 GB.  See
    [the OS images doc](doc/OS-images.md) for details.

*   Integrated Bill Silver’s E8 Emacs-like text editor for the PDP-8.

*   Updated Ian Schofield’s CC8 C compiler to V2.0:

    *   The OS/8 (“native”) compiler now has support for every K&R C
        1978 construct except for `struct`, `float`, and function
        pointers.  There are numerous compliance problems, but we’ve
        tried to document all of them in [`doc/cc8-manual.md`][cc8m].

        Most notably, this release adds support for `switch` and all of
        the remaining 2-character operators: `!=`, `>=`, `<=` and `?:`

    *   Added several more examples, including a Forth interpreter.

*   The software build now creates a [bootable RK05 disk image][OCK] of the
    [OS/8 Combined Kit (OCK)][kit] which is effectively the last
    official release of OS/8, with all patches. You can elect to use
    this for the IF=0 boot option instead of OS/8 V3D by configuring the
    software with the `--use-ock` flag.

    Bill Cattey did almost all of the work for this.

    Contrast the OS/8 V3F release, which wasn’t a formal release from
    DEC, but was rather V3D plus the Device Extensions Kit to support
    newer hardware that came out after V3D.

*   Added the [`os8pkg` package manager][os8pkg], allowing installation and
    uninstallation of packages on the installed RK05 OS/8 boot media,
    whether OCK or V3D. This is the new mechanism behind the existing
    `--with-os8-*` options, allowing you to get different feature sets
    on existing media without rebuilding it from scratch.  Bill Cattey
    did almost all of the work on this.

*   Many packages previously copied in as binary blobs have been shifted
    to the source tree to be built from source, or at the very least as
    individual binary files copied in from the source tree under code
    management.  This not only permits “clean” builds, it allows adding
    and removing packages from OS/8 media after installation, where
    previously you had to rebuild the entire medium after reconfiguring
    the source tree using `--enable-os8-*` type flags. Bill Cattey did
    this integration.

    The packages newly managed in this way are:

    *   [`advent`][adventrm]: The game of Adventure, built from
        [source][advsrc].

    *   [`basic-games`][gamesrm]: The collection of BASIC games and
        demos.  Although this is a [collection of ASCII text
        files][bgsrc], and OS/8 BASIC is an interpreter of those text
        program files, not a compiler, we still build this package of
        PDP-8 ASCII text files from POSIX ASCII text files.

        This not only permits later package add and remove options, it
        also allows fun things like editing the sources on the Pi side,
        rebuilding the package, and reinstalling, rather than editing
        the sources directly under OS/8.  Or, skip the middleman and use
        [`os8-cp`][os8cp] to copy the edited version to the boot media.

    *   [`cc8`][cc8m]: Ian Schofield's C compiler was always built from
        [source][cc8src], but now it’s built to an intermediate package
        rather than copied straight to the OS/8 boot media.

    *   [`chekmo`][chekmorm]: The Chekmo II chess playing program, built
        from [source][ckmsrc].

    *   [`dcp`][dcprm]: The OS/8 PDP-8 dissassembler, built from binary
        executables, since source has apparently been lost.

    *   [`e8`][e8man]: Bill Silver's E8 editor, built from
        [source][e8src].

    *   [`focal69`][focalrm]: The first DEC FOCAL interpreter, built
        from [source][f69src].

    *   [`kermit`][kermitrm]: The communication and text encode/decode
        suite, built from [source][krmsrc].

    *   [`lcmod`][lcsrc]: The batch scripts `UCSYS.BI`, `LCSYS.BI`,
        `UCBAS.BI` and `LCBAS.BI` are now under source control. Being
        patches to OS/8, the sources are scattered within our [OS/8
        source subtree][os8src].

    *   [`music`][musicrm]: The PDP-8 Music compiler is now built from
        [source][mussrc] with the scores under source control. Note that
        we still can't actually hear the output owing to lack of
        connection between the sound generation and SIMH.

    *   [`uwfocal`][uwfocalrm]: The U/W FOCAL interpreter. The main
        module is built from [source][uwfsrc], but other components are
        considered legacy and treated as binary blobs for now. This is
        documented in the `uwfocal.pspec` file.

    *   [`vtedit`][vteditdoc]: The VT screen editor extensions to TECO
        are now packaged separately, built from [source][vtesrc].

*   Added [`os8-progtest`][progtest] tool for testing software under OS/8. Tests
    in `pyyaml` format create state machines for starting programs
    engaging in run dialogs, and confirming success. Test harnesses
    exist for advent, cc8, chekmo, uwfocal, and basic-games. Bill Cattey
    did almost all the work on this.

*   The distribution now follows a [documented testing protocol][testing].

*   [Configurable screen manager][rmsm], allowing either tmux or "none"
    as an alternative to GNU screen.  Initial work on this feature done
    by Ryan Finnie.

*   Updated the PiDP-8/I KiCad hardware files to Oscar Vermeulen’s 2019
    kit version.

*   Integrated the octal comparison tool `ocomp` into the lower level
    `dist-v3d.rk05` and `dist-ocomp.rk05` images. Used for validation of
    packages installed by `os8pkg`. Integration by Bill Cattey.

*   Added udev rules to allow mounting media from disks on USB
    floppy drives.  (Thanks to Ryan Finnie for this feature.)

*   Updated SIMH to 2021-02-03 version, GitHub commit 2f66e74c50.  The
    primary user-visible changes from the perspective of a PiDP-8/I user
    are:

    *   The paper tape punch and LPT output devices now default to
        append mode for existing files, rather than overwriting them on
        `ATTACH`.  This not only follows the principle of least surprise
        for modern users, it also replicates the way actual hardware
        operated: reopening such devices and sending more data to them
        just advanced the tape thru the punch or the paper thru the
        teletypewriter.

    *   RF08: Fixed a bug that could cause loss of photo cell unit
        events.

    *   The simulator now does a precalibration pass to achieve a good
        initial guess at the host's IPS rate rather than drop sharply
        into a calibrated level some seconds past the simulator startup
        time, as in the prior release.

    *   Improvements to SCP, the command shell / script interpreter:

        *   Add the `RENAME/MOVE/MV`, `MKDIR`, and `RMDIR` commands.

        *   The `SAVE` command can now overwrite existing files.

        *   The unimplemented `DUMP` command now gives a helpful
            diagnostic message recommending use of `EXAMINE`.

        *   Several improvements to power-of-2 unit handling in command
            output and parameter input.

        *   Regular expressions in SIMH `EXPECT` commands now use
            PCRE syntax if available instead of the POSIX regex
            library.

    *   Many improvements to magnetic tape device handling.  (Nothing
        PDP-8 specific, just generic SIMH improvements.)

*   Fixed a bug in the `SING_STEP` + `IF` feature for switching between
    boot scripts (e.g. IF=2 for running TSS/8) that could cause the
    simulator to crash rather than execute the new script.

    In typical use, this may not even be noticed by the user because
    systemd will restart a crashed simulator, which will then choose its
    boot script based on the same `IF` switch setting.

    Likely the only people to notice this fix are those running the
    simulator attached to a terminal, such as in development.

*   The build system now detects the availability of Python 3 and
    prefers it if available. All documentation now assumes that you’re
    using Python 3. These changes mean we’re no longer testing regularly
    with Python 2, so there may be breakages going forward. These should
    be inadvertent, but we don’t rule out the possibility of a hard
    cut-over in the future that permanently breaks compatibility with
    Python 2. We believe we retain that compatibility in this release,
    but this may be the last such release of the PiDP-8/I software.

*   Considerable updates to the Python library classes we’ve built our
    tooling atop to support all of the above.  Some library behaviors
    and interfaces may have changed in ways that affect outside users.

*   Updated Autosetup to v0.7.0+, allowing builds under Tcl 8.7.

*   The previous release shipped with a broken version of the UCSYS.BI
    script on the v3d.rk05 boot image. The script is supposed to
    turn off forcing lower case characters to upper case in the OS/8
    keyboard monitor, and re-enable the linefeed key's command to
    re-echo the command line. (Cleaning up messy character echoing.)
    Instead linefeed would hang the keyboard monitor.  This is because
    the script for the v3f keyboard monitor was installed on the v3d
    packs.
    
*   Fixed a bug with the MB display in Sing Inst mode when poking around
    with Load Add and Exam.  This only affects some configurations, not
    all, but the fix appears benign on the non-affected ones.

*   The `os8script.py` class has been [documented][os8script] to explain
    the design and assist others in writing programs that can drive operation
    under OS/8 in SIMH using Python expect and all the layers developed
    above it.

*   Portability and documentation improvements.

[adventrm]:  https://tangentsoft.com/pidp8i/doc/release/src/advent/README.md
[advsrc]:    https://tangentsoft.com/pidp8i/dir?ci=release&name=src/advent
[bgsrc]:     https://tangentsoft.com/pidp8i/dir?ci=release&name=src/basic-games
[cc8src]:    https://tangentsoft.com/pidp8i/dir?ci=release&name=src/cc8/os8
[chekmorm]:  https://tangentsoft.com/pidp8i/doc/release/src/chekmo/README.md
[ckmsrc]:    https://tangentsoft.com/pidp8i/dir?ci=release&name=src/chekmo
[dcprm]:     https://tangentsoft.com/pidp8i/doc/release/src/dcp/README.md
[e8man]:     https://tangentsoft.com/pidp8i/doc/release/doc/e8-manual.md
[e8src]:     https://tangentsoft.com/pidp8i/dir?ci=release&name=src/e8
[f69src]:    https://tangentsoft.com/pidp8i/dir?ci=release&name=src/focal69
[focalrm]:   https://tangentsoft.com/pidp8i/doc/release/src/focal69/README.md
[gamesrm]:   https://tangentsoft.com/pidp8i/doc/release/src/basic-games/README.md
[kermitrm]:  https://tangentsoft.com/pidp8i/doc/release/src/kermit-12/README.md
[kit]:       https://tangentsoft.com/pidp8i/doc/release/doc/os8-combined-kit.md
[krmsrc]:    https://tangentsoft.com/pidp8i/dir?ci=release&name=src/kermit-12
[lcsrc]:     https://tangentsoft.com/pidp8i/dir?ci=release&name=src/os8/ock/SYSTEM
[musicrm]:   https://tangentsoft.com/pidp8i/doc/release/src/music/README.md
[mussrc]:    https://tangentsoft.com/pidp8i/dir?ci=release&name=src/music
[OCK]:       https://tangentsoft.com/pidp8i/doc/release/src/os8/ock/README.md
[ocomprm]:   https://tangentsoft.com/pidp8i/doc/release/src/os8/tools/ocomp/README.md
[os8cp]:     https://tangentsoft.com/pidp8i/doc/release/doc/os8-cp.md
[os8pkg]:    https://tangentsoft.com/pidp8i/doc/release/doc/os8pkg.md
[os8src]:    https://tangentsoft.com/pidp8i/dir?ci=release&name=src/os8
[progtest]:  https://tangentsoft.com/pidp8i/doc/release/doc/os8-progtest.md
[rmsm]:      https://tangentsoft.com/pidp8i/doc/release/README.md#rc-screen-manager
[testing]:   https://tangentsoft.com/pidp8i/doc/release/doc/testing.md
[uwfocalrm]: https://tangentsoft.com/pidp8i/doc/release/src/uwfocal/README.md
[uwfsrc]:    https://tangentsoft.com/pidp8i/dir?ci=release&name=src/uwfocal
[vtesrc]:    https://tangentsoft.com/pidp8i/dir?ci=release&name=src/vtedit
[os8script]: https://tangentsoft.com/pidp8i/doc/release/doc/class-os8script.md


<a id="20190425"></a>
## Version 2019.04.25 — The "OS/8 V3F and os8-run" Release

*   The banner feature in this release is that Bill Cattey transformed
    our `mkos8` tool into the `os8-run` script interpreter, giving us
    many new features and capabilities:

    *   The OS/8 V3D RK05 media build steps previously hard-coded in
        Python within `mkos8` are now in a series of scripts in the
        `os8-run` language.  This abstracts the process, making it
        easier to understand and change.  Non-Python programmers can
        examine these `os8-run` input scripts to learn how their media
        are built.  It's easier to modify the `os8-run` scripts to get
        custom results than to modify the prior release's `mkos8` Python
        script.

    *   Replaced the hand-maintained `media/os8/os8.tu56` OS/8 V3D TU56
        tape image used by boot option IF=3 with an `os8-run` script
        that's run at build time to generate a series of four similar
        tape images from pristine, curated source media, just like
        we did for the RK05 media in the prior release.

        These four tapes are the result of a 2×2 matrix of choices
        between which virtual DECtape hardware ([TC08 or TD8E][tctd])
        and which OS/8 version ([V3D or V3F][v3df]):

        *   You can ask to have the IF=3 boot option use the OS/8 V3F
            tape instead of the OS/8 V3D default.  Both versions get
            built, always, but only one gets to be the boot tape for
            this option.  This may be the first time that V3F was
            ever easily available to SIMH users.  Previously, you
            had to assemble it from pieces found all over the Internet.

            (Bootable V3F RK05 media are planned for a future release.)

        *   You can also select whether the IF=3 boot option uses
            the boot tape configured for a PDP-8 with the TD8E tape
            controller instead of the default, which assumes a TC08.
            The prior release was hard-coded for the TD8E.

            This new driver is more efficient and it will allow you to
            copy the medium image to an actual DECtape and boot it on a
            PDP-8 with the TC08 or compatible tape drive controller.
            That wasn't possible before because the TD8E and TC08 share
            the same IOT device ID, so you can have only one or the
            other installed into OS/8 at a time, and that tape didn't
            have `BUILD` on it, so the manually maintained tape image we
            were running didn't allow you to easily switch it.

    *    In the prior release, we offered the Python `simh` API for
         scripting OS/8 and SIMH, plus the `teco-pi-demo` script to show
         off this API.  The `os8-run` command language is based on this
         same mechanism, offering a simpler method of achieving custom
         results.  The `os8-run` script language is more like a command
         language at this time than a programming language, so it should
         be much easier for non-programmers to learn.

    *   We've been working on this new mechanism for many months now,
        during which we did a lot of manual testing.  But as with `mkos8`
        before it, we've also got an automatic tester for `os8-run`,
        which gives us tested quality assurance on several axes:

        *   <p>**Complete**: We've repeatedly tested all 32768 possible
            OS/8 RK05 configurations afforded by the configure
            script.</p>

        *   <p>**Repeatable**: We've re-tested those builds on the
            original build systems, on multiple computers at a site, and
            across sites.  This assures us that the builds are
            deterministic: given the same inputs, you always get the
            same outputs.  That sounds like it should be obvious and
            easy, but it didn't come for free!</p>

        *   <p>**Platform-Independent**: By copying these test exemplars
            between Pi and non-Pi systems and re-testing, we've
            convinced ourselves that the build is platform-independent,
            at least within the scope of the systems we've tried it
            on.</p>

        *   <p>**Reliable**: Some of these configurations have been
            tested many times over, and all of them have been built at least
            four times.  We've come to expect that this new mechanism
            will reliably build standard media on your Pi, too.</p>

    This is largely the work of Bill Cattey.

*   Added Bill Cattey's `os8-cp` script, which makes it nearly as easy
    as `cp(1)` to get files into and out of a SIMH OS/8 media image.

    Also added his `diff-os8` program, which is not general-purpose, but
    it shows a useful application of `os8-cp`: to compare two RK05 media
    images by copying out all of the files from OS/8 into the local
    filesystem and then comparing the files individually on the host.
    Imagine your own possibilities!

*   Major improvements to Ian Schofield’s CC8 compiler:

    *   <p>Bill Cattey retargeted the CC8 cross-compiler against
        [SmallC-85][sc85], which greatly improves the capabilty of the
        compiler.  It also allows this compiler to run without crashing
        on 64-bit hosts for the first time.</p>

    *   <p>Bill merged in some of the updates Ian has made to CC8, which
        affects the native OS/8 compiler and its standard library.</p>

    *   <p>Bill wrote an `os8-run` script to generate the `cc8.tu56`
        DECtape image dynamically at build time, as needed, rather than
        use a static binary image shipped in the Fossil code repository.
        The primary practical upshot of this is that you can now change
        the native OS/8 CC8 source code on the host side and just say
        “`make`” to get a new RK05 disk pack with the new code running
        in it. If you don’t get how cool this is, you don’t understand
        it properly. :)</p>

    *   <p>Warren Young quadrupled the size of the [CC8 user manual][cc8m].
        It now answers many more questions, reveals many previously
        hidden details, fully documents LIBC’s interfaces and internal
        behaviors, and documents the CC8 memory model.</p>

    *   <p>Warren and Ian collaborated on fixes to the native compiler
        and its LIBC to fix a bunch of bugs and improve its conformance
        to Standard C. It’s still miles from passing any ISO C
        conformance suite, but it should violate fewer expectations now.
        This work does change the API and ABI of CC8’s LIBC somewhat, so
        if you have existing code, you might want to read the new manual
        to work out what’s needed to port that code.</p>

        <p>Notable improvements are that <tt>itoa()</tt> now takes a
        radix parameter to match its implementation in other C
        libraries; <tt>sprintf()</tt> returns an error code when the
        format string contains an unsupported format specifier; and the
        <tt>printf()</tt> family of functions now handle <tt>%x</tt> and
        <tt>%X</tt> properly. In the prior release, only <tt>%x</tt>
        was supported, and it gave uppercase output, not lowercase as
        the Standard requires.</p>

    *   <p>Warren changed CC8 to use octal when generating constants in
        SABR output, that being SABR’s default radix. Since CC8 leaves
        SABR in its default octal mode, the primary user benefit of this
        is that inline assembly now behaves the same in CC8 as in OS/8
        FORTRAN II, which is also built atop SABR. That is to say, your
        inline assembly code can safely assume that the assembler is in
        octal mode when it processes your code.</p>

        <p>This does mean that if you had C programs built with CC8 that
        had inline assembly and that code had integer constants within
        it, it will have to be changed to work with the new
        compilers.</p>

        <p>The default radix for C code remains 10, so if you were not
        using inline assembly, this change does not affect you.</p>

*   Since the beginning of this project, we've called our modified
    version of the SIMH PDP-8 simulator `pidp8i-sim`.  With this
    release, we hard link that program to `pdp8`, the simulator's name
    in the upstream distribution of SIMH.  When called by that name, our
    simulator suppresses all of the PiDP-8/I extensions.

    This not only means we don’t start the GPIO thread that blinks the
    LEDs and scans for switch changes, it means we revert behavioral
    changes like the one that affects how the HLT instruction ("halt")
    is processed: just as with the upstream version, this drops you down
    to the SIMH command prompt when you call the simulator as `pdp8`,
    rather than halt the processor and wait for a front panel CONT or
    START keypress to get it out of STOP state.

    If you install this software on a non-Raspbian systemd-based Linux
    distribution, the new `pidp8i start` command will notice that there
    is no PiDP-8/I front panel available and will run `pdp8` instead of
    our extended `pidp8i-sim` simulator.

    When the GPIO thread is not running, the simulator runs considerably
    faster.  It’s not clear to me why that should be so on multi-core
    boxes, since the expensive parts of the PiDP-8/I extensions are
    running on a separate core, but the measurements are clear.

*   Added the [`--enable-savestate`][esco] configuration option.

*   The Python `simh` API now supports automatic transitions between
    OS/8 and SIMH context, largely removing the need to manage this
    manually as in the prior release.  This is largely Bill Cattey's
    work.

*   The `pidp8i` program now takes optional [verb arguments][pv] that
    let you avoid giving verbose `systemctl` or `service` commands.
    Instead of `sudo systemctl restart pidp8i` as in prior releases, you
    can now say `pidp8i restart`, for example.

*   Gracefully stopping the simulator (e.g. `pidp8i stop` or
    <kbd>Ctrl-E, q</kbd>) now turns off all front panel LEDs before
    shutting down.

    We’ve made no attempt to do similar cleanups when the simulator is
    killed outright.  The most common case is during a Pi reboot, where
    you’ll still see traces of the last state on the front panel
    briefly.  We also make no attempt to cope with badness like `killall
    pidp8i-sim`.

*   The `pidp8i-test` program's scan-switch feature now debounces the
    switches in software so that each state change results in only one
    line printed on the console.  This is not just cosmetic: the prior
    behavior could fool a builder into believing their correctly-working
    PiDP-8/I had a hardware problem.

*   Changed the SysV init script to a systemd unit file.  This gets us
    several new features:

    *   <p>It fixes a problem introduced between Raspbian Jessie and
        Stretch that caused dangling `pidp8i-sim` processes when you
        stopped the simulator.</p>

    *   <p>SysV init was pretty much limited to use by root, so we had
        to use `sudo` in many cases even though we'd largely divorced the
        PiDP-8/I software from needing root privileges itself.  systemd
        allows a service to be installed under the account of a normal
        user, which lets you start and stop the simulator without
        needing root privilege.</p>

    *   <p>We get detailed service status for free via <tt>pidp8i
        status</tt>, a short alias for the full command, <tt>systemctl
        --user status pidp8i</tt>.</p>

    *   <p>Gets us away from the SysV init backwards compatibility that
        may go away in a future release of Raspbian.</p>

*   Applied a fix from Ian Schofield for a serious problem with the
    accuracy of the MB register lights in certain contexts, such as
    while in STOP mode.  Bill Cattey verified this fix against a real
    PDP-8 at the Rhode Island Computer Museum.

*   Fixed some bugs in our version of the James L-W alt-serial mod
    feature relative to the mailing list patch.  Bug reports and
    diagnosis by Dylan McNamee.

*   Fixed a bug going clear back to the epochal v20151215 release which
    can cause an OSR instruction to incorrectly set the Link bit if the
    next GPIO pin up from those used by the SR lines happens to be set
    when you issue that instruction.

*   The `tools/mkbootscript` program which translates palbart assembly
    listing files into SIMH boot scripts was only writing a SIMH "dep"
    command for the first word on a line of listing output.  It’s legal
    in PAL format listings to have multiple words on a line, as is
    common with data arrays and such. Any program that makes use of that
    feature is affected, including the tty output from `hello.script`
    and `pep001.script`.

    While in there, made several other improvements to the script.

*   The `examples/hello.pal` program was badly broken in prior releases.

    *   <p>It was skipping the first character ("H") in its output
        message.</p>

    *   <p>Set the 8th bit set on the ASCII output bytes in case you use
        a Teletype Model 33 ASR or similar, which requires mark parity.</p>

    *   <p>It now uses the same optimized `PRINTS` routine as
        `pep001.pal`, which we're also shipping as
        `examples/routines/prints.pal`.</p>

    Between these weaknesses and the `mkbootscript` bug fixed above,
    this example was entirely broken since being shipped.  Our thanks
    for the tests and diagnosis of these problems go to Greg Christie
    and Bill Cattey.

*   The `SING_STEP` + `IF` switch combo to restart the simulator with a
    new boot script (e.g. IF=2 for TSS/8) now does a full restart of the
    simulator rather than simply executing the script’s commands in the
    context of the current simulator instance.  This can make the
    relaunch more reliable by starting with the simulator with known
    register values, device states, etc.

*   Improved `examples/pep001.pal`:

    *   This program no longer gets stuck in the TSF loop on startup if
        you run it with the terminal unready for output.  The terminal
        would typically be ready when launching this program from within
        OS/8, but it could get stuck in other conditions, such as when
        running it under a freshly started simulator:

             $ bin/pdp8 boot/pep001.script

    *   Applied same high-bit improvement as for `hello.pal`.

*   Updated SIMH to commit ID 4e0450cff (2019-04-18):

    *   <p>Simulated PDP-8 devices now have description strings so that
        SIMH commands like `SHOW FEATURES` gives more descriptive
        output.</p>

    *   <p>SCP (the Ctrl-E command processor) has seen a lot of work
        since our last release, and the included PiDP-8/I boot scripts
        make use of two of these improvements: `ELSE` directives in
        command scripts and `ON SIGTERM` handling.</p>

    *   <p>The core SIMH timing and throttling mechanism has seen a lot
        of work.</p>

    *   <p>Lots of small improvements to the terminal muxer.</p>

*   The software now builds and runs on FreeBSD.  This just a step
    toward support for FreeBSD for the Raspberry Pi: we haven’t tried to
    make the GPIO stuff work at all yet.  For now, it just lets this
    software be used on your FreeBSD desktop or server machine.  It may
    allow building on other BSDs, but that is untested.

*   `scanswitch` now returns 127 on “no GPIO” rather than 255.

*   16 months of maintenance and polishing: better documentation, build
    system improvements, etc.

[cc8m]: https://tangentsoft.com/pidp8i/doc/release/doc/cc8-manual.md
[esco]: https://tangentsoft.com/pidp8i/doc/release/README.md#savestate
[pv]:   https://tangentsoft.com/pidp8i/doc/release/README.md#systemd
[sc85]: https://github.com/ncb85/SmallC-85
[tctd]: https://tangentsoft.com/pidp8i/wiki?name=TD8E+vs+TC08
[v3df]: https://tangentsoft.com/pidp8i/wiki?name=OS/8+V3D+vs+V3F


<a id="20171222"></a>
## Version 2017.12.22 — The "Languages and Custom OS/8 Disk Packs" Release

*   All prior versions of the PiDP-8/I software distribution included
    `os8.rk05`, a "Field Service Diagnostic" OS/8 disk pack image with
    uncertain provenance, configuration, and modification history.  We
    have replaced that canned disk image with a script which is run at
    build time which programmatically assembles a set of clean OS/8 RK05
    disk images from curated, pristine, tested sources based on the
    user's chosen configuration options.

    This provides the following features and benefits as compared to the
    old `os8.rk05`:

    -   The PiDP-8/I software build process now builds up to three RK05
        disk images:

        -   `os8v3d-bin.rk05` is a bootable OS/8 V3D disk configured
            according to your chosen configuration options, which are
            described below and in [`README.md`][tlrm].  It is made from
            the pristine DECtape images shipped by DEC for OS/8 V3D plus
            several third-party tapes curated for and built by the
            project's maintainers.  See [the OS/8 media `README.md`
            file][os8rm] for more details.

        -   `os8v3d-patched.rk05` is a copy of the `bin` disk with
            [most][os8p] of the patches DEC published over the years for
            OS/8 V3D applied.  That set of patches was chosen and tested
            for applicability to our modern PiDP-8/I world and for
            mutual compatibility.

            This is the boot disk used for the IF=0 and IF=7 cases
            unless you give `--disable-os8-patches` to the `configure`
            script, in which case these boot options use the `bin` disk.

        -   `os8v3d-src.rk05` is a non-bootable disk containing the
            contents of the OS/8 V3D source code tapes plus the source
            code for the extensions to OS/8 V3D.  The *ten* TU56 tape
            images used as input to this process are also included among
            the PiDP-8/I software — see `media/os8/al-*-sa-*.tu56` — but
            we find it much more convenient to explore the sources on a
            single RK05 disk than to repeatedly attach and detach the
            TU56 tapes.

            You can suppress building this with `--disable-os8-src`.

        Default versions of these disk images are also now published on
        the project's home page for the benefit of those not running our
        PiDP-8/I software.  There are quite a few OS/8 RK05 disk images
        floating around on the Internet these days, and many of them
        have bugs and breakage in them that we've fixed.  It would
        completely fail to break our hearts if these images were used by
        many people outside the PiDP-8/I project.

    -   U/W FOCAL V4E is installed on SYS: by default. Start with our
        [U/W FOCAL Manual Supplement for the PiDP-8/I][uwfs], then
        follow links from there to further information.
        
        The primary linked source is the [U/W FOCAL Manual][uwfm] by Jim
        van Zee (creator of U/W FOCAL) converted from scanned and OCR'd
        PDF form to Markdown format, which Fossil renders nicely for us
        on the web.

        This is a fascinating programming language, well worth studying!

    -   Ian Schofield's CC8 OS/8 C compiler is installed on `SYS:` by
        default, and its examples and other files are on `DSK:`.  We
        have also merged in his `cc8` host-side cross-compiler.  See
        [the CC8 `README`][cc8rm] for details.
        
        This is a considerably improved compiler relative to what
        was distributed on the mailing list in August 2017.  Ian has
        been working within the PiDP-8/I project since that initial
        public release, which we are now distributing publicly for
        the first time.  We thank him for trusting us to host and
        distribute his project.

    -   The MACREL v2 macro assembler and its associated FUTIL V8B tool
        are installed by default.  Not only is this new functionality
        relative to prior releases of the PiDP-8/I software, it is a
        considerable upgrade over to the original MACREL and FUTIL V7
        that are more commonly found on the net.

    -   DCP disassembler is installed by default.

    -   John Comeau's CHECKMO-II chess program is installed by default.

    -   By default, SIMH no longer folds lowercase input and output to
        uppercase.  Instead, we apply patches to OS/8's command
        processor and its BASIC implementation to up-case input, since
        neither OS/8 nor BASIC can cope with lowercase input.

        All other programs are left to fend for themselves, which
        often works out fine.  U/W FOCAL, Adventure, and TECO all handle
        lowercase input to some extent, for example, and all three can
        emit lowercase text if given it.  With the prior SIMH setting,
        you could not use lowercase in these programs at all.

        This default can be overridden.  See the documentation for the
        new `--lowercase` configuration option in `README.md`.

    -   The `INIT.TX` message displayed by default on OS/8 boot is now
        more informative than the old `FIELD SERVICE PDP-8 DIAGNOSTIC
        SYSTEM` message.  It also now uses lowercase unless you built
        the simulator to force uppercase with `--lowercase=upper`.

        Those that do not want any boot message can disable it at
        configuration time with the `--disable-os8-init` flag.

        The message can be modified by editing `media/os8/init.tx.in`
        and saying `make`, which will rebuild the OS/8 media.

    -   All of the above features can be disabled if not wanted, as can
        several features present on the old `os8.rk05` disk: Adventure,
        FORTRAN IV, FORTRAN II, Kermit-12, and the BASIC game and demo
        programs.

        You can disable each feature above with a `--disable-os8-*`
        option to the `configure` script, or you can disable all of them
        collectively with the `--os8-minimal` option, which gets you a
        nearly bare-bones OS/8 installation with lots of spare disk
        space with which you can do what *you* want.

    -   Replaced the mismatched FORTRAN compiler and runtime with
        matched versions from the distribution DECtapes, and ensured that
        Adventure runs under this version of the FORTRAN Run Time System
        (FRTS). At various points in the past, either FORTRAN or
        Adventure has been broken.

    -   Repaired several broken BASIC programs on `RKB0:` by going back
        to primary sources.  Either the `os8.rk05` disk image was corrupted
        at some point or it is an image of a real RK05 disk pack that
        was corrupted, causing several of these BASIC programs to not
        run properly.

    -   The `*.MU` and music player files are left off of `RKB0:` by
        default, since they apparently do not cause sufficient RFI on
        the PiDP-8/I hardware to be picked up by normal AM radios.  This
        saves space for things that *do* work.

    -   No longer installing the `VTEDIT` macros for TECO by default.
        Although some may enjoy this alternative way of running TECO, it
        was decided that we should offer stock TECO by default for its
        historical value.  If you want VTEDIT back, it can be re-enabled
        with a `configure` script option.

    -   In the old `os8.rk05` disk image, both `SYS:` and `DSK:` were
        set to `RKA0:`, which meant that to address anything on `RKB0:`, you
        had to specify the device path explicitly or manually change the
        default in OS/8 with an `ASSIGN RKB0 DSK` command or similar.

        In the new disk pack, programs run with the OS/8 `R` command are
        installed on `RKA0:` which is the `SYS:` disk, and user data
        files, FOCAL and BASIC programs, etc. are on `RKB0:` which is
        assigned as `DSK:`. This means OS/8 and its programs are now far
        more likely to find files without an explicit device name,
        because files are installed where OS/8 looks for them by
        default.  Example:

            .R FRTS                   ⇠ loads FRTS from SYS: (RKA0:)
            *ADVENT                   ⇠ loads ADVENT.LD from DSK: (RKB0:)
            *[Esc]
            Welcome to Adventure!!

        Notice that no device names had to be specified.  OS/8 did the
        right thing by default here, even though the files involved are
        on two separate OS/8 devices.

        To a very rough approximation, `SYS:` on these new RK05 disk
        packs acts like the Unix `PATH` and `DSK:` acts like your user's
        home directory.

        The idea for this came from the `cc8.rk05` disk image which Ian
        Schofield included with his original CC8 distribution on the
        PiDP-8/I mailing list.

        (A version of `cc8.rk05` is still buried in our code repository
        if you want to pull it out, but it is not part of the release
        because our `os8v3d-patched.rk05` disk image is functionally a
        complete replacement.)

    -   OS/8 has a limit on the number of devices it can support, and we
        made different choices than the creator of `os8.rk05`.

        Briefly, we replaced the second floppy (`RXA1:`) with a third
        RK05 disk, that being deemed a more useful configuration for
        this hard disk based OS/8 configuration.  A dual-floppy
        configuration implies that you are booting from floppy and need
        the second one for user files and such.  In our RK05 based
        configuration, users should need floppy disk support rarely, and
        then primarily to get data on and off of the attached hard
        disk(s).

        We chose to stick with the dual TU56 tape drive setup of the
        prior version as we found the ability to mount two tapes very
        helpful, particularly during the `mkos8` build process.

        The difference in the `RESORC` output between the versions is:

            Old: RKA0,RKB0,RKA1,RKB1,          RXA0,RXA1,DTA0,DTA1,TTY,LPT,PTP,PTR
            New: RKA0,RKB0,RKA1,RKB1,RKA2,RKB2,RXA0,     DTA0,DTA1,TTY,LPT,PTP,PTR

    This automatic OS/8 media build feature was suggested by Jonathan
    Trites who wrote the initial version of the script that is now
    called `libexec/mkos8`.  That script was then extended and factored
    into its current form by Bill Cattey and Warren Young.  The author
    of Autosetup, Steve Bennett, helped with the code which allows the
    `configure` and `mkos8` scripts to share a single set of option
    definitions.

    Warren thinks Bill did most of the hard work in the items above.

    The source media used by the `mkos8` script comes from many sources
    and was curated for the PiDP-8/I project by Bill Cattey.  See the
    [OS/8 media README][os8rm] for more details.

    See the [the top-level `README`][tlrm] for information on modifying
    the default OS/8 configuration.  Pretty much everything above can be
    disabled if it's enabled by default, and vice versa.

*   Added several new wiki articles covering the above:

    *   More Project Euler Problem #1 solutions in:

        *   [C][pe1c]
        *   [FORTRAN IV][pe1f4]
        *   [FORTRAN II][pe1f2]
        *   [U/W FOCAL][pe1u]

    *   [Demos in BASIC][dibas], describing `DSK:*.BA`

    *   [OS/8 Console TTY Setup][os8ct], describing how we have
        modified the stock behavior of OS/8 to behave appropriately
        with a glass terminal or SSH on its console, as opposed to
        its default behavior, which assumes a teletype.

    *   [OS/8 LCSYS.BI Disassembled][os8lc], a symbolic
        disassembly of the `LCSYS.BI` patch we distribute with the
        system, which is widely available online elsewhere. That script
        is a raw binary patch, which makes its operation a mystery
        unless you happen to be able to read PDP-8 machine code.

*   Added Bill Cattey's `txt2ptp` program which converts plain ASCII
    text files files to the paper tape format used by SIMH, which eases
    transfer of text data into the simulator.  That program is also
    linked to `ptp2txt`, which makes it perform the inverse function:
    given a SIMH paper tape image file, produce an ASCII text file on
    the host machine with its contents.

    This program was originally written to ease the movement of FOCAL
    program text between SIMH and its host OS, but it is now a key part
    of the OS/8 RK05 disk building process, used whenever we need to
    inject the contents of a text file from the host into the simulated
    PDP-8 running OS/8.

    These filters should prove broadly useful.

*   Integrated Robert Krten's `d8tape` PDP-8 host-side disassembler.
    This is distinct from the OS/8 DCP disassembler, which runs inside
    the simulator.  It is intended as a companion to `palbart`, which we
    integrated last year.

*   Added a new "blinkenlights" demo program called `bin/teco-pi-demo`
    which drives SIMH from the outside, running a TECO macro under OS/8
    to calculate *pi* to 248 digits at a very slow rate, producing a
    display that manages to land somewhere between the random default
    display of [Deeper Thought][dt2vk] and the clear, boring patterns of
    our preexisting IF=5 demo script.

    Why 248 digits?  Because at 249, TECO8 runs out of memory, aborting
    the demo early.  At the default execution rate, it would take over
    17 years to complete this demo, making it a good choice to run on
    PiDP-8/I units primarily being used as *objets d'art*.  The demo has
    a finite run time, but your Raspberry Pi is likely to die before it
    completes. `;)`

    This script is also included as a demonstration of how the end user
    can reuse the technology that we developed to automatically build
    the custom OS/8 disk images described above to achieve different
    ends.  Perhaps you have some other program you'd like to run within
    SIMH in an automated fashion?  This shows one way how, and
    demonstrates a pre-built and tested set of tools for achieving it.

    We have also written [a tutorial][csd] explaining how
    `bin/teco-pi-demo` works and how to reuse the components it is built
    atop for your own ends.

    This demo also has a benchmark mode (command line option `-b`) which
    has two purposes:

    1.  It lets you see how much faster your host system runs PDP-8 code
        than a Raspberry Pi Model B+ running the PiDP-8/I simulator.

    2.  Given that information, the benchmark overrides a hardcoded
        timing value in the source code as distributed which prevents
        programs like `teco-pi-demo` from spamming the OS/8 terminal
        input handler.  The default is for the slowest host we support
        this software on, that same Model B+ referred to above, but if
        we know you're running on a faster host, we can shorten this
        delay and remain reliable.
        
    If you run the demo in benchmark mode twice, you'll notice that the
    TECO script is input nearly instantaneously the second time, whereas
    you can see the demo "type" the script in very quickly the first
    time.  (Remove `lib/pidp8i/ips.py`, say `make reconfig` and run the
    demo again to see the difference.)

*   The `DF` + `SING_STEP` feature for automatically attaching binary
    media images to the simulator from files on USB sticks now looks
    at all directories under `/media`, not just `usb0` through `usb7`
    so that it works with several other common Linux USB automounting
    schemes, such as the one Raspbian Desktop uses.

*   Fixed the order of initialization in the GPIO setup code for the
    James L-W serial mod case.  Fix by Dylan McNamee.

*   The helper program that selects which boot script to run when the
    PiDP-8/I boots based on the IF switch settings broke at some point
    in the past, apparently because it was using its own idiosyncratic
    GPIO handling code, and thus did not track our evolving GPIO
    handling methods.  Now it shares the same code used by `pidp8i-sim`
    and `pidp8i-test`, so it works properly again.

*   The SysV init script that starts `pidp8i-sim` under GNU Screen on
    the PiDP-8/I now sets the working directory to `$prefix/share/media`
    on start, so relative paths given to SIMH commands (e.g. `ATTACH`)
    are more likely to do what you want.  In prior releases, you
    generally had to give absolute paths to attach media and such
    because CWD would be set somewhere unhelpful.

*   The Fetch LED is no longer lit when in STOP or single-step mode.  In
    real hardware, it can be either on or off in this mode, depending
    on various conditions, but it is most often off, so while it is not
    perfectly correct now, it is less wrong.  Most of the investigation
    into this issue is by Bill Cattey, with the current partial fix by
    me.  A more precise fix may come later.  (See ticket [347ae45403] if
    you care to know the details.)

*   The Pause LED state was over-counted in the LED sub-sampling scheme
    so that it would tend to be brighter than it should have been.
    Problem noticed by Ian Schofield.

*   The MB row's state was not showing the right thing.  The problem was
    noticed in comparison to real PDP-8/I hardware by Vincent Slyngstad
    and verified by William Cattey.  Ian Schofield suggested the current
    fix.

*   Updated SIMH to upstream checkin ID 27f9fc3c3, December 11, 2017.

    There have been no substantial changes to the PDP-8 simulator since
    the last update, 8 months ago, but there have been a lot of bug
    fixes to the SCP, that being the common core of all of the SIMH
    simulators.

    One upstream change had to be backed out to work around a bug they
    introduced, which was not fixed by release time.
    
    (See [GitHub issue \#508][gh508].)

*   Updated for Raspbian Stretch, released in September 2017.  (Our
    binary OS images are built against the subsequent 2017-11-29
    release, with updates as of 2017-12-22 applied.)

    The only significant difference found is that the old, abandoned
    `usbmount` package no longer works, apparently due to some change in
    `systemd`.  We've replaced that with a set of scripts based on
    [those by Mike Blackwell][mbua].

    It should still run on Raspbian Jessie, however.

*   The binary OS images produced with this version automatically expand
    the root partition to fill your SD card.  (Prior versions required
    that you manually do this with `raspi-config`.)

*   Assorted portability, build system, and documentation improvements.

[apt]:   https://linux.die.net/man/8/apt
[cc8rm]: https://tangentsoft.com/pidp8i/doc/release/doc/cc8-manual.md
[csd]:   https://tangentsoft.com/pidp8i/doc/release/doc/class-simh.md
[dibas]: https://tangentsoft.com/pidp8i/wiki?name=Demos+in+BASIC
[dt2vk]: https://github.com/VentureKing/Deeper-Thought-2
[gh508]: https://github.com/simh/simh/issues/508
[mbua]:  https://serverfault.com/a/767079
[os8ct]: https://tangentsoft.com/pidp8i/wiki?name=OS/8+Console+TTY+Setup
[os8lc]: https://tangentsoft.com/pidp8i/wiki?name=OS/8+LCSYS.BI+Disassembled
[os8p]:  https://tangentsoft.com/pidp8i/doc/release/doc/os8-patching.md
[os8rm]: https://tangentsoft.com/pidp8i/doc/release/media/os8/README.md
[pe1c]:  https://tangentsoft.com/pidp8i/wiki?name=PEP001.C
[pe1f2]: https://tangentsoft.com/pidp8i/wiki?name=PEP001.FT#fortran-ii
[pe1f4]: https://tangentsoft.com/pidp8i/wiki?name=PEP001.FT#fortran-iv
[pe1u]:  https://tangentsoft.com/pidp8i/wiki?name=PEP001.FC
[uwfm]:  https://tangentsoft.com/pidp8i/doc/release/doc/uwfocal-manual.md
[uwfs]:  https://tangentsoft.com/pidp8i/doc/release/doc/uwfocal-manual-supp.md


<a id="20170404"></a>
## Version 2017.04.04

*   Removed the PDP-8 CPU idle detection feature.  Oscar Vermeulen
    reports that it also interfered with NLS LED driving mode in his
    last version, and we have no reason to believe our NLS code is
    sufficiently different to avoid the problem.

    This does not affect ILS users, since enabling ILS mode disables
    this change.

    NLS system upgrades wouldn't normally be affected because the
    changed files are not normally overwritten on installation.  If
    you're affected, you know it, and how to fix it.

*   Replaced the earlier attempts at finding an ideal IPS rate for the
    simulator when run on single-core hosts with usage of SIMH's
    percentage style throttle rates.  We now explicitly set the throttle
    rate to "50%" which not only achieves an even higher throttle rate
    than in earlier releases, it's reliable in the face of varying
    background CPU usage.  See the single-core section of
    `README-throttle.md` for details.


<a id="20170401"></a>
## Version 2017.04.01 — The "I May Be a Fool, but I am *Your* Fool" Release

*   Added the `configure --alt-serial-mod` option to change the GPIO
    code to work with [James L-W's alternative serial mod][sm2].

*   Increased the stock CPU throttle from 0.67 MIPS to 0.85 MIPS on most
    Pi 1 class devices, except for the Pi Zero which is a bit faster and
    so is able to run at 1.25 MIPS.

    (Testing shows that increasing it further causes SIMH to complain
    that it doesn't have enough CPU power to run that fast, despite the
    fact that top(1) shows it taking only about half the available CPU
    power.  It's just as well: we don't want to hog all the CPU power on
    a single-core Pi, anyway.)

*   When built in NLS mode, most of the PDP-8 simulator configuration
    files we generate now have CPU idle detection enabled, allowing host
    CPU usage to drop when the simulated CPU is basically idle, such as
    when waiting for keyboard input.

*   Replaced a simplistic 2-second delay in the startup sequence of the
    simulator, `pidp8i-test`, and "[Incandescent Thought][it]" with a
    smarter interlocked startup sequencing mechanism that largely
    eliminates the delay.

*   Fixed a problem introduced in v20170204 which causes the `LOAD_ADD`
    and `DEPOSIT` switch handlers to generate incorrect core addresses
    when the SIMH PDP-8 CPU core sets bits beyond the lower 12 in the PC
    register.  We were assuming this register is always 12-bit clean,
    but it isn't.

*   Merged in upstream SIMH improvements.  Changes relevant to the
    PiDP-8/I include:

    *   The PDP-8 CPU reset mechanism now does more of what our
        preexisting `START` switch handler did, so we now delegate to
        that upstream mechanism, reducing behavior differences between
        the cases.

    *   Improved keyboard polling behavior in terminal handler.

    *   Fixed many bugs identified by Coverity Scan in many different
        subsystems of the simulator.  Normally I wouldn't note such a
        low-level change in this user-centric document, but it is
        possible that some of these improvements fix user-visible bugs.

*   SIMH's default PDP-8 configuration enables the DF32 disk device with
    the short name "DF", but since the SIMH `DEPOSIT` command works on
    both devices and registers, a command like `d df 0` is ambiguous,
    causing the default configuration of SIMH to give a "Too few
    arguments" error for this command, even though it's obvious that you
    mean the CPU DF register here.  (Surely you didn't mean to overwrite
    the first word of your disk image instead?)  Since upstream refuses
    to fix it, I have disabled the DF32 device in all of the default
    `boot/*.script` files.

    Since these scripts aren't overwritten on installation, this will
    only affect new installs unless you say `make mediainstall`, in
    which case your binary OS media is also overwritten.  Do this at
    your own risk!

*   Many improvements to the `SING_STEP` + `DF` USB auto-mounting and
    SIMH attaching feature:

    *   Prior versions apparently could only mount paper tape images
        correctly.  This release includes a fix that allows RX type
        floppy images and TU type DECtape images to autoattach.

    *   Changed the meaning of `SING_STEP` + `DF=7` from attaching an RL
        type removable hard disk cartridge image to the first RL01 drive
        to attaching an older and more period-correct RK type image to
        the *second* RK05 drive.  The second half of the change lets you
        use this feature along with the stock OS/8 image to attach a
        second hard disk at runtime.

    *   The file name matching code used by this feature was only using
        the first character of the file name extension, and it wasn't
        pinning the match to the end of the file name string.  Thus, if
        you'd set `DF=0`, it would look for the first file with `.p`
        anywhere in the file name, not `.pt` at the end, as expected.

    *   Improved error messages given when this feature doesn't work.

*   The `pidp8i-test` program now accepts a `-v` flag to make it give
    the version and configuration string and exit.

*   `pidp8i-test` now exits more cleanly, shutting down ncurses, turning
    off the front panel LEDs, and writing a diagnostic message on signal
    exits.

*   The version number part of the configuration string written by
    `pidp8i-test -v` and as the first line of output from the simulator
    now uses the same 10-digit Fossil checkin ID format as the Fossil
    timeline, making it easier to match that version to a particular
    Fossil checkin.

*   The Raspberry Pi model detection code behind the Pi model tag in the
    configuration string was only doing the right thing for the more
    common Pi models.  It now reports the correct Pi model for the
    various flavors of Compute Module and the Pi Zero.

*   Improved error handling in the process that inserts the version info
    into the configuration string emitted when the simulator and test
    programs start up.

*   We now build and link in the upstream `sim_video` module, which
    allows access to a video display via SDL.  We do not currently
    use this in the project core, but I recall hearing about a
    third-party project that uses this for a local graphical X-Y
    vector display implementation for playing Spacewar!  When built
    on a system without SDL or even a local bitmap display, this
    code becomes nearly a no-op, affecting build time very little.

*   SIMH changes to a different delay mechanism at CPU throttle rates
    below 1000 IPS, which prevents our incandescent lamp simulator from
    running correctly.  Therefore, when you give a `./configure
    --throttle` flag value that would use this throttle mode, we disable
    the ILS even when building on multi-core Raspberry Pis.

    (This fix doesn't disable the ILS at run time if you manually set a
    throttle value under 1000 IPS via a SIMH command.  We'll try to help
    you avoid accidentally shooting yourself in the foot, but if you're
    going to *aim*, you're on your own.)

*   Several internal refactorings to improve code style, reduce the
    [upstream SIMH patch footprint][foot], and fix corner case bugs.

[foot]: http://pastebin.com/5Jnx15QX
[it]:   https://tangentsoft.com/pidp8i/wiki?name=Incandescent+Thought
[sm2]:  https://groups.google.com/d/msg/pidp-8/-leCRMKqI1Q/Dy5RiELIFAAJ


<a id="20170204"></a>
## Version 2017.02.04

*   Largely rewrote the incandescent lamp simulator (ILS) feature.
    The core of Ian Schofield's original contribution is still hiding
    in there if you go spelunking, but everything surrounding it
    is different.

    The changes and design decisions surrounding this are [complicated
    and subtle][ilsstory], but the end result is that the ILS is now
    free of judders, blips, shudders, and chugs.  (Those are nuanced
    technical terms for "badness.")  The ILS is now buttery smooth from
    1 kIPS to the many-MIPS rate you get running un-throttled on a Pi 3.

*   Although most of the ILS work does not directly apply to the "no
    lamp simulator" (NLS) case, the sample rate dithering reduces
    display update artifacts seen in this case as well.

*   Slowed the ILS brightness rates down a bit: more lampy, less
    snappy.  Whether this is accurate or not is something we'll have
    to determine through research separately in progress.

*   The ILS display is a bit brighter: the delay values used in prior
    versions put a cap on max brightness that was well under the full
    LED brightness achievable.

*   For the first time, it is possible to build Deeper Thought (any
    version) against the ILS, with minor adjustments.  Prior versions of
    the ILS had too different an external interface to allow this.  Full
    details are in a [new wiki article][ithought].

*   In normal free-running mode, the simulator lights the Fetch and
    Execute LEDs at 50%, whereas before there was an imbalance that
    purely had to do with the much lower complexity of fetching an
    instruction inside the simulator vs executing it.
    
    (In real hardware, the complexities were different: fetch involved a
    core memory retrieval, very much non-instantaneous, whereas the
    execution of the fetched instruction kind of happened all at once in
    complicated electron flows, rather than the sequential C code of the
    SIMH PDP-8 simulator.  Thus, it was reasonable for DEC to talk about
    PDP-8/I fetch-and-execute cycles as if the two steps were of equal
    time complexity.)

    I haven't compared the resulting LED appearance to a real PDP-8/I.

*   Several other tweaks to LED state handling to better match real
    hardware.

*   Redesigned the `pidp8i-test` program to allow manual stepping
    forwards and backwards in addition to the previous auto-advancing
    behavior.
    
    As soon as you press one of the arrow keys, the test program moves
    to the next or previous action in the sequence and stops
    auto-advancing.  This mode is useful when testing the hardware with
    a multimeter or similar, and you need a certain row or column to
    stay lit up indefinitely.

    You can also press <kbd>R</kbd> to resume auto-advancing behavior,
    or either <kbd>Ctrl-C</kbd> or <kbd>X</kbd> to exit the program
    gracefully.

    This requires that you have `libncurses-dev` installed on your Pi.

*   The SIMH PDP-8 simulator's internal SR register now matches the
    hardware switches when you say Ctrl-E then `ex sr`.  Prior versions
    only loaded the hardware switch register values into the internal
    register when it executed an `OSR` instruction.

*   Copied the KiCad design files into the source tree since they are
    now formally released by Oscar Vermeulen under a Creative
    Commons license.  Also included the PDF version of the schematic
    produced by Tony Hill.  (This is all in the `hardware/` directory.)

*   Lowered the default simulator throttle value for single-core Pi
    boards from 1332 kIPS to 666 kIPS after doing some testing with
    the current code on a Raspberry Pi 1 Model B+.  This value was
    chosen since it is approximately twice the speed of a PDP-8/I.
    This leaves a fair bit of CPU left over for background tasks,
    including interactive shell use.

    This value may be a bit low for Pi Zero users, but it is easily
    [adjustable][rmth].

*   Merged in the relevant SIMH updates.  This is all internal stuff
    that doesn't affect current PiDP-8/I behavior.

*   Many build system and documentation improvements.

[ilsstory]: https://tangentsoft.com/pidp8i/wiki?name=Incandescent+Lamp+Simulator
[ithought]: https://tangentsoft.com/pidp8i/wiki?name=Incandescent+Thought


<a id="20170123"></a>
## Version 2017.01.23

*   When any program that talks to the PiDP-8/I front panel starts up,
    it now prints out a banner modeled on the [Erlang configuration
    line][ecl].  For example, when I run the software in the development
    tree on my PiDP-8/I, I get the following:

        PiDP-8/I trunk:i49cd065c [pi3b] [ils] [serpcb] [gpio]

    It tells me that:
    
    *   I'm running code built from Fossil checkin ID 49cd065c on the
        trunk branch, as opposed to a release version, which would be
        marked `release:v20170123` or similar.  (The `i` here is a tag
        standing for "ID", as in Fossil checkin ID.  Contrast `v` used
        to tag release version numbers.)

    *   I'm running it on a Raspberry Pi 3 Model B with Ian Schofield's
        incandescent lamp simulator (ILS) feature enabled.

    *   The software is built to expect that the PiDP-8/I PCB and the Pi
        board attached to it have had the serial mods made to them.

    *   The GPIO module found the GPIO hardware and was able to attach
        to it.

*   I get a very different result when running it on my desktop machine:

        PiDP-8/I trunk:id8536d91 [cake] [nls] [nopcb] [rt]

    This tells me:

    *   I'm running a different version of the development branch (i.e.
        the "trunk") of the code than what's running on the Pi.

    *   It's not running on a Pi at all.  (Cake ≠ pi.)

    *   I've disabled the ILS feature, so it's running with the "no lamp
        simulator" (NLS) GPIO module.
    
    *   Which is all to the good, because there's no point burning CPU
        power running the ILS code on a host machine that doesn't have a
        PiDP-8/I PCB attached.

    *   The GPIO thread is running with real-time privileges.

*   The ILS feature can now be disabled at `configure` time via the new
    `--no-lamp-simulator` flag.  This option is automatically set when
    building on a single-core Raspberry Pi.  (The flag is there only to
    allow someone building the software on a multi-core host machine to
    disable the ILS.)

*   Tweaked the ILS decay constants to be asymmetric, better mimicking
    the way real incandescent lamps work: they heat up to full
    brightness faster than they fade to perceptively "off."

*   The LED values used by the GPIO thread were being recalculated way
    too often.

    In the ILS case, it was updating the values approximately at the
    same rate as the ILS's PWM core frequency, roughly 7,500 times per
    second, which is far higher than the human persistence of vision
    limit.  While the PWM rate does need to be that fast to do its job,
    the underlying LED state values do not need to change nearly that
    often to fool the human into seeing instantaneous updates.

    The NLS case was actually worse, recalculating the LED values on
    every instruction executed by the PDP-8 CPU simulator, which even on
    a Pi 1 is likely to be a few MHz.

    In both the ILS and NLS cases, we now update the LED values about
    100 times a second, maintaining that rate dynamically based on the
    current execution speed of the simulator.

*   In prior versions, the ILS was only updating at its intended rate
    when the PDP-8 simulator was running flat-out on a current
    multi-core Raspberry Pi.  If you throttled the SIMH simulator to a
    slower execution rate, the display quality would start to degrade
    noticeably below about 1 MIPS.

*   With the prior fix, we now ship 5.script (i.e. the handler for
    starting the simulator with IF=5, or restarting it with IF=5 +
    `SING_STEP`) set to a throttle value of 30 kIPS, which allows the
    human to see each AC/MQ modification.  The built-in delay loops are
    still there, else we'd have to drop this to well under 1 kIPS.

*   The `SING_INST` switch now immediately puts the processor into
    single instruction mode, not requiring a separate press of the
    `STOP` key, as in prior versions.  This is the correct behavior
    according to the 1967-1968 edition of DEC's Small Computer Handbook
    for the PDP-8/I.

*   Greatly simplified the way single-instruction mode, processor
    stoppage, and the `CONT` key work.  The prior implementation was
    error-prone and difficult to understand.  This fixes a particularly
    bad interaction between the way `HLT` instructions and `CONT` key
    presses were handled, causing the processor to not resume correctly
    from `HLT` state.

*   Consolidated and cleaned up the bulk of the PiDP-8/I switch handling
    code so that it is not so intimately tied into the guts of the PDP-8
    CPU emulator.  This will greatly increase the chance that future
    updates to the upstream SIMH code will apply cleanly to our version.

*   Fixed a bug in `examples/bit-rotate.pal` which caused it to skip the
    actual bit rotation step.  We were trying to microcode two
    instructions into one that the PDP-8 won't accept together, and we
    didn't catch it until now because the HLT bug masked it, and the
    `palbart` assembler we ship isn't smart enough to notice the bug.

*   Fully generalized the mechanism for generating `obj/*.lst`,
    `bin/*.pt`, and `boot/*.script` from `examples/*.pal`.  You can now
    drop any PAL assembly language program into the `examples` directory
    and type `make` to build these various output forms automatically
    using the shipped version of `palbart`.  This effectively turns this
    PiDP-8/I software distribution into a PDP-8 assembly language
    development environment: rapidly build, test, and debug your PAL
    programs on your PC before you deploy them to real hardware.  Or,
    write PAL programs to debug the hardware or simulator, as we did
    with `examples/bit-rotate.pal`.

*   Fixed a sorting bug in the tool that generates `boot/*.script` from
    `obj/*.lst`, resulting in `dep` instructions that weren't sorted by
    core address.  This didn't cause any real problem, but it made
    tracing the execution of a PAL assembly program difficult if you
    were trying to refer to the `boot/*.script` file to check that the
    PiDP-8/I's front panel is showing the correct register values.

*   Updated SIMH to the latest upstream version and shipping a subset of
    the SIMH docs as unversioned files from tangentsoft.com.

*   The `configure` script now aborts the build if it sees that you're
    trying to build the software as root, since that means it generates
    the init script and the pidp8i script expecting to run the installed
    software as root, not as your normal user.  The most common way this
    happens is that you have a configured source tree, then change one
    of the `*.in` files and say `sudo make install`, thinking to build
    and install the change in one step.  This fixes that.

*   Several improvements to the build system.

[ecl]: http://stackoverflow.com/q/1182025/142454


<a id="20170116"></a>
## Version 2017.01.16

*   Prior releases did not include proper licensing for many of the
    included files.  This project was, therefore, not a proper Open
    Source Software project.  This problem has been fixed.

    In this release, many files that were previously technically only
    under standard copyright due to having no grant of license now have
    an explicit license, typically the same as SIMH itself.  (Thank you
    to all of the authors who allowed me to apply this license to their
    contributions!)

    For several other files, I was able to trace down some prior license
    and include its text here for the first time.

    There remain a few "gray" items: the TSS/8 and ETOS disk images.
    See the [`COPYING.md` file][copying] for more on the current status
    of these OS images.  If the legal status of these files clarifies in
    the future, this software distribution will react accordingly, even
    if that means removing these files from the distribution if we learn
    that these files are not freely-redistributable, as we currently
    believe them to be today.

*   The Step Counter LEDs on the front panel weren't being lit properly
    when EAE instructions were being used.  Thanks for this patch go to
    Henk Gooijen and Paul R. Bernard.

*   The prior `boot/1.script` and `boot/5.script` files are no longer
    simply opaque lists of octal addresses and machine code.  They are
    generated from PAL assembly files provided in the `examples`
    directory, so that you can now modify the assembly code and type
    `make` to rebuild these boot scripts.

*   The mechanism behind the prior item is fully general-purpose, not
    something that only works with `1.script` and `5.script`.  Any
    `examples/*.pal` file found at `make` time is transformed into a
    SIMH boot script named after the PAL file and placed in the `boot`
    directory.  This gives you an easier way to run PDP-8 assembly code
    inside the simulator.  After saying `make` to transform `*.pal` into
    `*.script` files, you can run the program with `bin/pidp8i-sim
    boot/my-program.script` to poke your program's octal values into
    core and run it.  This round-trip edit-and-run process is far faster
    than any of the options given in the [examples' `README.md`
    file][ex].

*   Disassembled both versions of the RIM loader to commented, labeled
    PAL assembly language files.  If you ever wanted to know what those
    16 mysterious instructions printed on the front panel of your
    PiDP-8/I did, you can now read my pidgin interpretation of these
    programs in `examples/*-rim.loader.pal` and become just as confused
    as I am now. :)

*   The two RIM loader implementations now start with a nonstandard
    `HLT` instruction so that when you fire up the simulator with IF=1 to
    start the high-speed RIM loader, it automatically halts for you, so
    you don't have to remember to STOP the processor manually.

    There is currently [a bug][hltbug] in the way the simulator handles
    `HLT` instructions which prevents you from simply pressing START or
    CONT to enter the RIM loader after you've attached your paper tape,
    so you still have to manually toggle in the 7756 starting address
    and press START to load the tape into core.  (I hope to fix this
    before the next release, but no promises.)

*   Added the `configure --throttle` feature for making the simulator
    run at a different speed than it normally does.  See
    [`README-throttle.md`][rmth] for details.

*   The build system now reacts differently when building the PiDP-8/I
    software on a single-core Raspberry Pi:

    *   If you're building the trunk or release branch, you'll get a
        configure error because it knows you can't run the current
        implementation of the incandescent lamp simulator on a
        single-core Pi.  (Not enough spare CPU power, even with heavy
        amounts of throttling.)

    *   If you're building the no-lamp-simulator branch, it inserts a
        throttle value into the generated `boot/*.script` files that do
        not already contain a throttle value so that the simulator
        doesn't hog 100% of the lone core, leaving some spare cycles for
        background tasks.  The above `--throttle` feature overrides
        this.

    These features effectively replace the manual instructions in the
    old `README-single-core.md` file, which is no longer included with
    this software distribution, starting with this release.

*   Lowered the real-time priority of the GPIO thread from 98 to 4.
    This should not result in a user-visible change in behavior, but it
    is called out here in case it does.  (In our testing, such high
    values simply aren't necessary to get the necessary performance,
    even on the trunk branch with the incandescent lamp simulator.)

*   Since v20161128, when you `make install` on a system with an
    existing PiDP-8/I software installation, the binary OS media images
    were not being overwritten, on purpose, since you may have modified
    them locally, so the installer chose not to overwrite your versions.

    With this release, the same principle applies to the SIMH boot
    scripts (e.g. `$prefix/share/boot/0.script`) since those are also
    things the user might want to modify.

    This release and prior ones do have important changes to some of
    these files, so if you do not wish to overwrite your local changes
    with a `make mediainstall` command, you might want to diff the two
    versions and decide which changes to copy over or merge into your
    local files.

[hltbug]:  https://tangentsoft.com/pidp8i/info/f961906a5c24f5de
[copying]: https://tangentsoft.com/pidp8i/doc/release/COPYING.md
[rmth]:    https://tangentsoft.com/pidp8i/doc/release/README-throttle.md


<a id="20170105"></a>
## Version 2017.01.05

*   Automated the process for merging in new SIMH updates.  From within
    the PiDP-8/I software build directory, simply say `make simh-update`
    and it will do its best to merge in the latest upstream changes.

    This process is more for the PiDP-8/I software maintainers than for
    the end users of that software, but if you wish to update your SIMH
    software without waiting for a new release of *this* software, you
    now have a nice automated system for doing that.

*   Updated SIMH using that new process.  The changes relevant to the
    PiDP-8/I since the prior update in release v20161226 are:

    *   Many more improvements to the simulator's internal timer system.
        This should make deliberate underclocking more accurate.

    *   It is now possible to get hex debug logs for the simulator console
        port by cranking up the simulator's debug level.

*   The simulator now reports the upstream Git commit ID it is based on
    in its version string, so that if you report bugs upstream to the
    SIMH project, you can give them a version number that will be
    meaningful to them.  (They don't care about our vYYYYMMDD release
    numbers or our Fossil checkin IDs.)


<a id="20161226"></a>
## Version 2016.12.26 — The Boxing Day Release

*   Tony Hill updated SIMH to the latest upstream version.

    This change represents about 15 months worth of work in the
    [upstream project][simh] — plus a fair bit of work by Tony to merge
    it all — so I will only summarize the improvements affecting the
    PDP-8 simulator here:

    *   Many improvements to the internal handling of timers.
    
        The most user-visible improvement is that you can now clock your
        emulated PDP-8 down to well below the performance of a real
        PDP-8 via `SET THROTTLE`, which can be useful for making
        blinkenlights demos run at human speeds without adding huge
        delay loops to the PDP-8 code implementing that demo.

    *   Increased the number of supported terminals from four to either
        twelve or sixteen, depending on how you look at it.  Eight of
        the additional supported terminal devices are conflict-free,
        while the final four variously conflict with one or more of the
        other features of the simulated PDP-8.  If you want to use all
        16, you will be unable to use the FPP, CT, MT and TSC features
        of the system.

        This limitation reflects the way the PDP-8 worked.  It is not an
        arbitrary limitation of SIMH.

    *   Added support for the LS8E printer interface option used by the
        WPS8 word processing system.

    *   The simulator's command console now shows the FPP register
        descriptions when using it as a PDP-8 debugger.

    *   Added the `SHOW TTIX/TTOX DEVNO` SIMH command to display the
        device numbers used for TTIX and TTOX.

    *   The `SHOW TTIX SUMMARY` SIMH command is now case-insensitive.

    *   Upstream improvements to host OS/compiler compatibility.  This
        increases the chances that this software will build out of the
        box on random non-Raspbian systems such as your development
        laptop running some uncommon operating system.

*   When you `make install`, we now disable Deeper Thought 2 and the
    legacy `pidp8` service if we find them, since they conflict with our
    `pidp8i` service.

*   Added the install user to the `gpio` group if you `make install` if
    that group is present at install time.  This is useful when building
    and installing the software on an existing Raspbian SD card while
    logged in as a user other than `pi` or `pidp8i`.

[simh]: https://github.com/simh/simh/


## Version 2016.12.18

*   The entire software stack now runs without explicit root privileges.
    It now runs under the user and group of the one who built the
    software.

    For the few instances where it does need elevated privileges, a
    limited-scope set of sudo rules are installed that permit the
    simulator to run the necessary helper programs.

*   The power down and reboot front panel switch combinations are no
    longer sensitive to the order you flip the switches.

*   Changed the powerdown front panel switch combination to the more
    mnemonically sensible `Sing_Step` + `Sing_Inst` + `Stop`.

    Its prior switch combo — `Sing_Step` + `Sing_Inst` + `Start` — is
    now the reboot sequence, with the mnemomic "restart."

*   Removed the USB stick mount/unmount front panel switch combos.  The
    automount feature precludes a need for a manual mount command, and
    unmount isn't necessary for paper tape images on FAT sticks.

*   The simulator now runs correctly on systems where the GPIO setup
    process fails.  (Basically, anything that isn't a Raspberry Pi.)
    Prior to this, this failure was just blithely ignored, causing
    subsequent code to behave as though all switches were being pressed
    at the same time, causing utter havoc.

    The practical benefit of this is that you can now work with the
    software on your non-Pi desktop machine, losing out only on the
    front panel LEDs and switches.  Everything else works just as on the
    Pi.  You no longer need a separate vanilla SimH setup.

*   Added a locking mechanism that prevents `pidpi8-test` and
    `pidp8i-sim` from fighting over the front panel LEDs.  While
    one of the two is running, the other refuses to run.

*   Added `examples/ac-mq-blinker.pal`, the PAL8 assembly code for the
    `boot/5.script` demo.

*   Fixed two unrelated problems with OS/8's FORTRAN IV implementation
    which prevented it from a) building new software; and b) running
    already-built binaries.  Thanks go to Rick Murphy for providing the
    working OS/8 images from which the files needed to fix these two
    problems were extracted.

*   Added the VT100-patched `VTEDIT` TECO macro from Rick Murphy's OS/8
    images, and made it automatically run when you run TECO from the
    OS/8 disk pack.  Also added documentation for it in `VTEDIT.DC` on
    the disk pack as well as [in the wiki][vteditdoc].

*   The default user name on the binary OS images is now `pidp8i`
    instead of `pi`, its password has changed to `edsonDeCastro1968`,
    and it demands a password change on first login.  I realize it's a
    hassle, but I decided I didn't want to contribute to the plague of
    open-to-the-world IoT boxes.

*   Many build system and documentation improvements.

[vteditdoc]: https://tangentsoft.com/pidp8i/wiki?name=Using+VTEDIT


## Version 2016.12.06

*   The `pidp8i-test` program's LED test routines did not work correctly
    when built against the incandescent lamp simulator version of the
    GPIO module.  Reworked the build so that this test program builds
    against the no-lamp-simulator version instead so that you don't have
    to choose between having the lamp simulator or having a working
    `pidp8i-test` program.

*   More improvements to `examples/pep001.pal`.

*   Extracted improved `PRINTS` routine from that example as
    `examples/routines/prints.pal`.


<a id="20161205"></a>
## Version 2016.12.05

*   This release marks the first binary SD card image released under my
    maintainership of the software.  As such, the major user-visible
    features in this release of the Fossil tree simply support that:

    *   The `pidp8i-init` script now understands that the OS's SSH host
        keys may be missing, and re-generates them.  Without this
        security measure, anyone who downloads that binary OS image
        could impersonate the SSH server on *your* PiDP-8/I.

    *   Added a `RELEASE-PROCESS.md` document.  This is primarily for my
        own benefit, to ensure that I don't miss a step, particularly
        given the complexity of producing the binary OS image.  However,
        you may care to look into it to see what goes on over here on
        the other side of the Internet. :)

*   Added an OS/8 BASIC solution to Project Euler Problem #1, so you can
    see how much simpler it is compared to the PAL8 assembly language
    version added in the prior release.

*   Updated the PAL8 assembly version with several clever optimizations
    by Rick Murphy, the primary effect of which is that it now fits into
    a single page of PDP-8 core memory.


<a id="20161203"></a>
## Version 2016.12.03

*   Debounced the switches.  See [the mailing list post][cdb] announcing
    this fix for details.

*   Merged the [`pidp8i-test` program][testpg] from the mailing list.
    The LED testing portion of this program [currently][gpiols] only works
    correctly without the incandescent lamp simulation patch applied.

*   Added a solution to [Project Euler Problem #1][pep001] in PAL8
    assembly language and wrote the [saga of my battle][p1saga] with
    this problem into the wiki.  This also adds a couple of useful PAL8
    routines in `examples/routines`.

*   Integrated David Gesswein's latest `palbart` program (v2.13) into
    the source distribution so that we don't have to:
    
    1.  ship pre-built RIM format paper tapes for the examples; and

    2.  put up with the old versions that OS package repos tend to have
        (Ubuntu is still shipping v2.4, from 6 years ago!)

*   Fixed a bug in the `make install` script that caused it to skip
    installing `screen` and `usbmount` from the OS's package repo when
    they are found to be missing.

*   Fixed a related bug that prevented it from disabling the serial
    console if you configure the software without `--serial-mod` and
    then install it, causing the serial console and the GPIO code in the
    PiDP-8/I simulator to fight over GPIO pins 14 and 15.

*   Removed the last of the duplicate binary media entries.  This makes
    the zip files for this version well under half the size of those for
    the 2015.12.15 upstream release despite having more features.

[cdb]:    https://groups.google.com/d/msg/pidp-8/Fg9I8OFTXHU/VjamSoFxDAAJ
[testpg]: https://groups.google.com/d/msg/pidp-8/UmIaBv2L9Ts/wB1CVeGDAwAJ
[gpiols]: https://tangentsoft.com/pidp8i/tktview?name=9843cab968
[pep001]: https://projecteuler.net/problem=1
[p1saga]: https://tangentsoft.com/pidp8i/wiki?name=PEP001.PA


<a id="20161128"></a>
## Version 2016.11.28

*   Added an intelligent, powerful build system, replacing the
    bare-bones `Makefile` based build system in the upstream version.
    See [`README.md`][tlrm] for more info on this.

*   The installation is now completely relocatable via `./configure
    --prefix=/some/other/place`. The upstream version would not work if
    installed somewhere other than `/opt/pidp8` due to many hard-coded
    absolute paths.  (This is enabled by the new build system, but
    fixing it was not simply a matter of swapping out the build system.)

*   Changed all of the various "PDP," "PDP-8", and "PiDP-8" strings to
    variants on "PiDP-8/I", partly for consistency and partly because it
    seems unlikely that this software will ever be used with anything
    other than the PiDP-8/I project.

    Part of this renaming means that the default installation location
    is now `/opt/pidp8i`, which has the nice side benefit that
    installing this version of the software will not overwrite an
    existing installation of the upstream version in `/opt/pidp8`.

    Another user-visible aspect of this change is that the upstream
    version's `pdp.sh` script to [re]enter the simulator is now called
    `pidp8i`.

*   Merged Ian Schofield's [Display update for the PiDP8][dupatch]
    patch.  Currently it is not optional, but there is [a plan][dudis] to
    allow this feature to be disabled via a `configure` script option.

*   The scripts that control the startup sequence of the PiDP-8/I
    simulator now include helpful header comments and emit useful
    status messages to the console.  Stare no more at opaque lists
    of SimH commands, wondering what each script does!

*   Merged `scanswitch` into the top-level `src` directory, since the
    only thing keeping it in a separate directory was the redundant
    `gpio.h` file. There were minor differences between the two `gpio.h`
    files, but their differences do not matter.

*   Installing multiple times no longer overwrites the binary OS/program
    media, since the disk images in particular may contain local
    changes.  If you want your media images overwritten, you can insist
    on it via `make mediainstall`.

*   The installation tree follows the Linux Filesystem Hierarchy
    Standard, so that files are in locations an experienced Linux user
    would expect to find them.  The biggest changes are that the content
    of the upstream `bootscripts` tree is now installed into
    `$prefix/share/boot`, and the OS/program media images which used to
    be in `imagefiles` are now in `$prefix/share/media`.

*   Added a bunch of ancillary material: [wiki articles][wiki],
    [USB stick label artwork][art], a PAL8 assembly [example program][ex]
    for you to toggle in, etc. Also filed a bunch of [tickets][tix]
    detailing feature proposals, known bugs and weaknesses, etc. If you
    were looking for ways to contribute to the development effort, these
    new resources provide a bunch of ideas.

*   Made some efforts toward portability.

    While this project will always center around Raspbian and the
    PiDP-8/I add-on board, the intent is that you should be able to
    unpack the project on any other Unix type system and at least get
    the simulator up and running with the normal SimH manual control
    over execution instead of the nice front panel controls provided by
    the PiDP-8/I board.

    In particular, the software now builds under Mac OS X, though it
    does not yet run properly.  (The modified SimH PDP-8 simulator
    currently misbehaves if the PiDP-8/I panel is not present.  Fixing
    this is on the radar.)

*   Fixed a bunch of bugs!

[tlrm]:    https://tangentsoft.com/pidp8i/doc/release/README.md
[dupatch]: https://groups.google.com/forum/#!topic/pidp-8/fmjt7AD1gIA
[dudis]:   https://tangentsoft.com/pidp8i/tktview?name=e06f8ae936
[wiki]:    https://tangentsoft.com/pidp8i/wcontent
[ex]:      https://tangentsoft.com/pidp8i/doc/release/examples/README.md
[art]:     https://tangentsoft.com/pidp8i/dir?c=trunk&name=labels
[tix]:     https://tangentsoft.com/pidp8i/tickets


<a id="20151215"></a>
## Version 2015.12.15

*   The last release of the software made by Oscar Vermeulen, the
    creator of the PiDP-8/I project. This version of the software
    derives from it, but differs in many ways. (See above.)

    Since May of 2017, this version of the software is now considered
    the current stable version.
