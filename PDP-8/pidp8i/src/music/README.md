#  MUSIC: PDP-8 Music Playing Program

A program that inputs musical scores and outputs sound using a PDP-8
either by radio frequency interference, or a special IOT instruction that
would be implemented in hardware.

A collection of scores is included.

Originally distributed as DECUS 8-804.

Upstream source: [Vince Slyngstad's DECUS archive 8-804][8-804].

There is another set of sources on the [dbit ftp site][dbit].

The score files are also available in an RK05 image at
[Dave Gesswein's Archive: diag-games-kermit.rk05][gesswein].

I'm not quite sure which source I used.  This set of sources includes a patch to CCL
`PLAYOV`, (that may not work for some versions of CCL) to add a `PLAY` command.

SIMH does not have support to get useful sound from this program.
However [Randy Dawson in 2017][dawson] came up with a hack that enabled SIMH to
output something that was post-processed into audible sound.

A detailed instruction manual can be found in the file decus-8-884.pdf.

## Original DECUS Writeup:

8-804 MUSIC: PDP-8 Music Playing Program

**Author:** Richard Wilson and others Digital Equipment Corporation, Maynard, MA
**Operating System:** Paper Tape or OS/8

**Source Language:** PAL-8

**Memory Required:** 4K

**Abstract:**

MUSIC is a program which will play music in four part
harmony on any PDP-8 family core memory computer, except the 8/S or
PDP-12. The music to be played is input to the program as a standard
OS/8 ASCII file. The music may be picked up by the use of an AM radio,
or by a simple interface. The OS/8 distribution media include the source
of the player, which can be customized for various configurations, along
with approximately 45 minutes of music, such as Joplin, Bach, Beetho-
ven, movie tunes, etc.

The binary paper tape is intended for any 1.5 microsecond PDP-8, and
runs in 4K, but will only play short tunes. Several short tunes are
available on paper tape.

**Media Price Code:** A2, F5, H32, K54

**Format:** OS/8

**Catalog:** August 1978

[8-804]: http://svn.so-much-stuff.com/svn/trunk/pdp8/src/decus/8-804
[gesswein]: ftp://ftp.pdp8online.com/images/os8/diag-games-kermit.rk05
[dbit]: ftp://ftp.dbit.com/pub/pdp8/nickel/music/music1/os8/
[dawson]: http://www.classiccmp.org/pipermail/cctech/2017-April/027526.html
