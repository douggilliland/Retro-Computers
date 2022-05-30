# PiDP-8/I Software Release Process

This documents the process for producing release versions of the
software.


## *Can* You Release Yet?

Before release, you must:

*   Fix all Immediate, High, and Medium priority [Bugs](/bugs)
*   Implement all Immediate and High priority [Features](/features)

Or reclassify them, of course.

Most of the bug levels simply aid scheduling: Immediate priority bugs
should be fixed before High, etc. Low priority bugs are "someone should
fix this someday" type of problems; these are the only ones allowed to
move from release to release. Think of bugs at this level as analogous
to the `BUGS` section of a Unix man page: our "low" intent to fix these
problems means they may stay at this level indefinitely, acting only as
advisories to the software's users.

The Features levels may be read as:

*   **Immediate**: ASAP, or sooner. :)
*   **High**: Features for the upcoming release.
*   **Medium**: Features we'll look at lifting to High for the release
    after that.
*   **Low**: "Wouldn't it be nice if..."


## Update SIMH

If `tools/simh-update` hasn't been run recently, you might want to do
that and re-test before publishing a new version.


## Test

1.  Build the software on the version of Raspberry Pi OS we’ll
    [use for BOSI, below](#bosi). Fix any problems.

2.  Run `make test` on the BOSI host. Fix any problems.

3.  Repeat above on [all other platforms previously known to work][oscomp].
    Update the article to list caveats and such, or fix the problems.

(See “[How the PiDP-8/i Software Is Tested](./testing.md)” for details
on the philosophy and methods behind this process.)

[oscomp]: https://tangentsoft.com/pidp8i/wiki?name=OS+Compatibility


## Publish OS/8 RK05s

Re-configure the software with default settings, remove `bin/*.rk05`,
rebuild, and run `tools/publish-os8` to send the "final" OS/8 disk
images for this version of the software up to tangentsoft.com as
unversioned assets.

Update the date stamp in the "OS/8 RK05 Media" section of the project
home page.


## Update ChangeLog.md

Trawl the Fossil timeline for user-visible changes since the last
release, and write them up in user-focused form into [the `ChangeLog.md`
file][cl]. If a regular user of the software cannot see a given change,
it shouldn't go in the `ChangeLog.md`; let it be documented via the
timeline only.

Immediately prior to release, `/doc`, `/dir`, `/file` and similar links
should point to trunk, but immediately prior to release, re-point them
to the `release` branch, since this document describes prior releases.

[cl]: https://tangentsoft.com/pidp8i/doc/trunk/ChangeLog.md


## Update the Release Branch

Run `make release` to check the `ChangeLog.md` file changes in, merge
trunk to the `release` branch, and apply a tag of the form vYYYYMMDD to
that marge checkin.

It runs entirely automatically unless an error occurs, in which case it
stops immediately, so check its output for errors before continuing.


## Update the Home Page Links

The zip and tarball links on the front page produce files named after
the date of the release. Those dates need to be updated immediately
after tagging the release, since they point at the "release" tag applied
by the previous step, so they begin shipping the new release immediately
after tagging it.


## <a id="bosi"></a>Produce the Normal Binary OS Image

Start with the latest version of [Raspberry Pi OS Lite][os] on a multi-core
Raspberry Pi.

1.  If the version of the base OS has changed since the last binary OS
    image was created, download the new one. Be sure to update the “`$os`”
    variable at the top of `tools/bosi` to match if the major version
    has changed.

    While the OS is downloading, zero the SD card you're going to use
    for this, so the prior contents don't affect this process.
    
    Blast the base OS image onto the cleaned SD card.

2.  Boot it up on a multi-core Pi.

    Log in as user `pi`, password `raspberry`, then retreive and
    initialize BOSI:

        $ wget https://tangentsoft.com/bosi
        $ chmod +x bosi
        $ exec sudo ./bosi init

    The `exec` bit is required so that the `bosi` invocation is run as
    root without any processes running as `pi` in case the `init` step
    sees that user `pi` hasn't been changed to `pidp8i` here: the
    `usermod` command we give to make that change will refuse to do what
    we ask if there are any running processes owned by user `pi`.

    It will either reboot the system after completing its tasks
    successfully or exit early, giving the reason it failed.

3.  Log in as user `pidp8i` since the prior step changed it from `pi`.
    The password remains unchanged at this point.

    Clone the software repo and build the software:

        $ ./bosi build [nls]

    Adding the “nls” parameter lets the slow single-core Pi build share
    the multicore ILS build’s OS/8 images, saving a tremendous amount of
    build time.

    On reboot, say `top -H` to make sure the software is running and
    that the CPU percentages are reasonable for the platform: if the CPU
    is mostly idle, the simulator isn’t running, and you need to figure
    out why before proceeding.

    You may also want to check that it is running properly with a
    `pidp8i` command.  Is the configuration line printed by the
    simulator correct?  Does OS/8 run?  Are there any complaints from
    SIMH, such as about insufficient CPU power?

4.  Do the final inside-the-image steps:

        $ ./bosi prepare

5.  After the Pi shuts down, move the SD card to a micro SD card reader plugged
    into the Mac¹ and say:

        $ bosi image [nls]

    Give "ils" as a parameter or leave it blank for the ILS image.

6.  The prior step rewrote the SD card with the image file it created.
    Boot it up and make sure it still works.  If you're happy with it,
    give this command *on the Mac*.

        $ bosi finish [nls]

    As above, the parameter can be "ils" or left off for the ILS images.

[os]: https://www.raspberrypi.org/software/operating-systems/


## Produce the "No Lamp Simulator" Binary OS Image

Do the same series of steps above on a single-core Raspberry Pi, except
that you give "nls" parameters to the `build`, `image`, and `finish` steps.


## Publicizing

While the NLS image uploads — the ILS image was already sent in step 7
in the first pass through the list above — compose the announcement
message, and modify the front page to point to the new images.  You
might also need to update the approximate image sizes reported on that
page.  Post the announcement message and new front page once that second
upload completes.


----------------------

### Footnotes

1.  The image production steps could just as well be done on a Linux box
    or on a Windows box via Cygwin or WSL, but the commands in that
    final stage change due to OS differences.  Since this document
    exists primarily for use by the one who uses it, there is little
    point in having alternatives for other desktop OSes above.  Should
    someone else take over maintainership, they can translate the above
    commands for their own desktop PC.


### License

Copyright © 2016-2021 by Warren Young. This document is licensed under
the terms of [the SIMH license][sl].

[sl]: https://tangentsoft.com/pidp8i/doc/trunk/SIMH-LICENSE.md
