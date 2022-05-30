# Using Our Binary OS Images

## Imaging the SD Card

The Raspberry Pi OS OS images you can download from [the PiDP-8/I development
site][1] are based on the [official Raspberry Pi OS images][2], so the
Raspberry Pi Foundation’s [installation guide][3] applies just as well
to our PiDP-8/I software images.  I particularly like using the
[Etcher][7] method, even on a POSIX system, since it can write the SD
card directly from the Zip file, without requiring that you unpack the
`*.img` file within first.

As of the 2021.02.14 release, you will need to use a 8 GB or larger
SD card.  Prior releases allowed use of 2 GB cards, but you can't
even do an "`apt upgrade`" on such a card after flashing it with a
fresh copy of the current "Lite" OS image. We jumped from 2 GB to
8 not only because we don't happen to have any 4 GB cards laying
around, but because the Raspberry Pi Foundation docs recommend 8 GB
for this release.

The contents of the Zip file are:

| File Name         | Description
|--------------------------------
| `README.md`       | this file
| `pidp8i-*.img`    | the OS image, based on Raspberry Pi OS Stretch Lite
| `MANIFEST.txt`    | SHA-256 hash and file size for the OS image file


## Logging In

Aside from having the PiDP-8/I software installed and running, the
primary difference between our OS images those provided by the Raspberry
Pi Foundation is the default user name and password:

*   **username:** `pidp8i`
*   **password:** `edsonDeCastro1968`

You will be made to change that password on first login.

Remember, [the S in IoT stands for Security.][5]  If we want security,
we have to see to it ourselves!

If you do not want your PiDP-8/I to be secure, see our
"[How to Run a Naked PiDP-8/I][6]" guide.


## <a id="sshd"></a>Enabling the SSH Server

The OpenSSH server is enabled and running by default on our OS images,
but for security reasons, our build process wipes out the generated SSH
host keys, else they’d be the same on everyone's PiDP-8/I, which would
be a massive security hole. Unfortunately, the `sshd` service on
Raspberry Pi OS is not smart enough to regenerate these keys if they are
missing on boot, so you need to do this once by hand:

    $ sudo dpkg-reconfigure openssh-server

You should be able to log in via SSH immediately after that command
completes.

We can’t do this for you automatically because our software doesn’t run
as root, so our startup script cannot make system-wide changes. This is
properly one of the tasks for you, the system’s administrator.

<div id="this-space-intentionally-left-blank" style="min-height:50em"></div>


[1]: https://tangentsoft.com/pidp8i/
[2]: https://raspberrypi.org/downloads/raspbian/
[3]: https://raspberrypi.org/documentation/installation/installing-images/
[4]: https://en.wikipedia.org/wiki/Internet_of_things
[5]: http://www.testandverification.com/iot/s-iot-stands-security/
[6]: https://tangentsoft.com/pidp8i/wiki?name=How+to+Run+a+Naked+PiDP-8/I
[7]: https://www.balena.io/etcher
