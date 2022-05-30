# Licenses

The PiDP-8/I software distribution is an agglomeration of software from
multiple sources.  Several different licenses apply to its parts.  This
file guides you to those individual licenses.


## <a id="simh"></a>SIMH License

Most of the files in this software distribution are released under the
terms of the SIMH license, a copy of which typically appears at the top
of each file it applies to. This includes not only SIMH proper but also
several files written by PiDP-8/I software project contributors who
chose to license their contributions under the same license, including
E8.

For a few files, textual inclusion of the license inside the file itself
was impractical, so this license is applied by reference to [a file
included with the distribution][sl].

[sl]: https://tangentsoft.com/pidp8i/doc/trunk/SIMH-LICENSE.md


## <a id="hw"></a>PiDP-8/I Design Files

The PiDP-8/I design files in [`hardware/pidp8i`][hwp] were released
under the Creative Commons [Attribution-NonCommercial-ShareAlike 4.0
International][ccl] license [on the mailing list][pdp8il] by their
author, Oscar Vermeulen.

[ccl]: https://creativecommons.org/licenses/by-nc-sa/4.0/
[hwp]: https://tangentsoft.com/pidp8i/dir?name=hardware/pdp8i&ci=trunk
[pdp8il]: https://groups.google.com/d/msg/pidp-8/bcIH9uEB_kU/zg9uho7NDAAJ


## <a id="autosetup"></a>autosetup License

The `configure` script and the contents of the `autosetup` directory are
released under the FreeBSD license given in [`autosetup/LICENSE`][as].

[as]: https://tangentsoft.com/pidp8i/doc/trunk/autosetup/LICENSE


## <a id="palbart"></a>palbart License

The `palbart` program and its manual page are released under the terms
of the license given in [`src/palbart/LICENSE.md`][pl].

[pl]: https://tangentsoft.com/pidp8i/doc/trunk/src/palbart/LICENSE.md


## <a id="d8tape"></a>d8tape License

The `d8tape` program is distributed under the license given in
[`src/d8tape/LICENSE.md`][d8tl].

[d8tl]: https://tangentsoft.com/pidp8i/doc/trunk/src/d8tape/LICENSE.md


## <a id="cc8"></a>CC8 Compiler License

The license for the `src/cc8` sub-tree is messy as it comes to us from
multiple authors over many years.

There are two compilers here.

First we have the OS/8 "native" compiler in `src/cc8/os8`, which is
entirely Ian Schofield's work, released under the terms of the [GNU
General Public License version 3][gpl3].

Then we have the CC8 cross-compiler which is based on Ron Cain's
[Small-C][smc], originally published in [Dr.  Dobbs' Journal][ddj].
Wikipedia describes Small-C as "copyrighted but shareable," which I take
to mean that we cannot claim it as our exclusive property, but we can
modify it and distribute those modifications to others, which is what
we're doing here.

Ian Schofield then took the Small-C source base and added a SABR
back-end, `code8.c`, which is also distributed under the [GPLv3][gpl3].

There is [another PDP-8 C compiler project][smsc] based on Small-C by
Vincent Slyngstad, which uses an entirely different approach for code
generation.  Ian Schofield took some of the library routines from this
implementation.

[ddj]:  https://en.wikipedia.org/wiki/Dr._Dobb%27s_Journal
[gpl3]: https://tangentsoft.com/pidp8i/doc/trunk/src/cc8/GPL3.txt
[smc]:  https://en.wikipedia.org/wiki/Small-C
[smsc]: http://so-much-stuff.com/pdp8/C/C.php


## <a id="os8"></a>OS/8 License

The OS/8 media images included with this software distribution are
released under the Digital License Agreement presented in
[`media/os8/LICENSE.md`][dla].

[dla]: https://tangentsoft.com/pidp8i/doc/trunk/media/os8/LICENSE.md


## <a id="dec"></a>Other DEC Software

The other files in the [`media`][md] and [`examples`][ed] directories
that originate from Digital Equipment Corporation are believed to fall
under the [public domain license][pdp8pd] DEC released all their PDP-8
software under after it stopped being economically viable. Documented
releases for specific software (e.g. TSS/8) may be difficult to come by,
however.

[md]: https://tangentsoft.com/pidp8i/dir?ci=trunk&name=media
[ed]: https://tangentsoft.com/pidp8i/dir?ci=trunk&name=examples
[pdp8pd]: http://mailman.trailing-edge.com/pipermail/simh/2017-January/016164.html


## <a id="etos"></a>ETOS License

ETOS was a commercial product produced outside of DEC. No public
documented declaration of license is known to be available for it, but
we have [a third-hand report][el] that its creators are fine with ETOS
being redistributed.

[el]: http://mailman.trailing-edge.com/pipermail/simh/2017-January/016169.html
