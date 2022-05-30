# BASIC Games and Demos

When this package is installed, the files are found on the `DSK:` partition of the
bootable image.

Many of them were ported to OS/8 BASIC by DEC employee Kay R. Fisher.
Most were published in the DEC publication, *101 BASIC Computer
Games*. That book describes itself as follows:

>It is the first collection of games all in BASIC. It is also the only
collection that contains both a complete listing and a sample run of
each game along with a descriptive write-up.

The first printing was in 1973. Apparently the original version of
the programs were in PDP-11 RSTS BASIC, so porting to the OS/8 BASIC
dialect would often be needed.  A quite readable preserved version of
the 1975 edition can be [found online][book].  If a demo is from this
book, it is designated `-101-` instead of `-----` below. The book
provides a page or two of useful lore, and a sample run.

This file provides usage, history, and ongoing curation information about
the items in this package.  (An HTML table is used instead of a markdown table
to take greater control of the display of the information.)

[book]: http://bitsavers.trailing-edge.com/pdf/dec/_Books/101_BASIC_Computer_Games_Mar75.pdf

<table>
<tr><th>File name</th><th>Src</th><th>Description</th></tr>
<tr><td><tt>BINGO .BA</tt></td><td>-101-</td><td>Computer generates bingo card for you and itself and calls out numbers at random.</td></tr>
<tr><td><tt>BLKJAC.BA</td></td><td>-101-</td><td>Play the card game of 21 against the computer.</td></tr>
<tr><td><tt>BLKJAK.BA</td></td><td>-101-</td><td>Blackjack written for PDP-8 Edusystem 30 BASIC by Tom Kloos, Oregon Museum of Science and Industry.</td></tr>
<tr><td><tt>BUNNY .BA</td></td><td>-101-</td><td>Prints the Playboy rabbit as typewriter art.</td></tr>
<tr><td><tt>CALNDR.BA</td></td><td>-101-</td><td>Perpetual calendar program, by Geoffrey Chase, OSB, Portsmouth Abbey School.<br><b>Usage: </b>You must modify line 160 to name the day of the week for January 1 of your year.  (0 for Sunday, -1 for Monday, etc.).
You also need to modify lines 360 and 620 for leap years:
Change the number 365 on line 360 to 366, and change the third element of the array in line 620 from 28 to 29.
</td></tr>
<tr><td><tt>CHECKR.BA</td></td><td>-101-</td><td>Written by Alan J. Segal. Play checkers against the computer.</td></tr>
<tr><td><tt>CRAPS .BA</td></td><td>-----</td><td>The dice game of craps.  Surprisingly it's not the version from <i>101 BASIC Computer Games</i>.</td></tr>
<tr><td><tt>DICE  .BA</td></td><td>-101-</td><td>Simulates rolling of dice, and prints the distribution of values returned.</td></tr>
<tr><td><tt>FOOTBL.BA</td></td><td>-101-</td><td>The first of two football simulations from <i>101 BASIC Computer Games</i>.</td></tr>
<tr><td><tt>FOTBAL.BA</td></td><td>-101-</td><td>The other football game from *101 BASIC GAMES* by Raymond W. Miseyka, Butler Sr. High School, Butler, PA.</td></tr>
<tr><td><tt>GOLF  .BA</td></td><td>-----</td><td>A not so great golf simulation.  The one in <i>101 BASIC Computer Games</i> looks a lot better.</td></tr>
<tr><td><tt>HELLO .BA</td></td><td>-101-</td><td>Simple conversation program where Petey P. Eight gives advice.</td></tr>
<tr><td><tt>HOCKEY.BA</td></td><td>-101-</td><td>Simulation of regulation hockey game.  Written by Charles Buttrey, Eaglebrook School, Deerfield, MA .</td></tr>
<tr><td><tt>KING  .BA</td></td><td>-101-</td><td>Land management simulation by James A. Storer, Lexington High School, Lexington, MA. Missing a bit of the text output in the game published in the 1975 edition of <i>101 BASIC Computer Games</i>, but functionally equivalent.</td></tr>
<tr><td><tt>LIFE  .BA</td></td><td>-101-</td><td>Conway's game of life by Clark Baker, Project DELTA, Delaware School Auxiliary Assoc., Newport, Delaware.</td></tr>
<tr><td><tt>LIFE2 .BA</td></td><td>-101-</td><td>Two players put pieces on the board. Rules of Conway's game of life determines survivor. Written by Brian Wyvill, Bradford University, Bradford, Yorkshire, England.</td></tr>
<tr><td><tt>MONPLY.BA</td></td><td>-101-</td><td>Monopoly board game simulation, by David Barker, Southeastern State College, Durant, OK. Ported to OS/8 BASIC by Kay R. Fisher who eliminated the original RSTS-E virtual files.</td></tr>
<tr><td><tt>POKER .BA</td></td><td>-101-</td><td>Play poker against the computer. Original author: A. Christopher Hall, Trinity College, Hartford, CT. Re-ported to OS/8 BASIC from <a href="https://amaus.org/static/S100/MESSAGE%20BOARDS/CPM%20Users%20Group/cpmug020/POKER.BAS">CPM Users Group POKER.BAS</a> source by Bill Cattey fixing constructs OS/8 BASIC didn't like.
</td></tr>
<tr><td><tt>RESEQ.BA</td></td><td>-----</td><td>Re-sequence line numbers of a BASIC program. Not from the DEC BASIC book.</td></tr>
<tr><td><tt>ROCKET.BA</td></td><td>-101-</td><td>Lunar lander simulation. Written by Jim Storer, Lexington High School. Ported from Focal by David Ahl, Digital. Lost for a while due to bad disk bits.
Using a partial copy from <a href="http://www.pdp8online.com/pdp8cgi/os8_html/ROCKET.BA?act=file;fn=images/os8/diag-games-kermit.rk05;blk=561,9,1;to=ascii">Dave Gesswein's Archive</a>, a RSTS-11 version
was found at <a href="http://pdp-11.trailing-edge.com/rsts11/rsts-11-013/ROCKET.BAS">pdp-11.trailing-edge.com</a> and re-ported to OS/8 by Bill Cattey, 
converting RSTS BASIC constructs to OS/8 constructs, and eliminating ON ERROR GOTO that does
not exist in OS/8. This code diverged significantly from the version appearing in <i>101 BASIC Computer Games</i>, but is functionally equivalent.
</td></tr>
<tr><td><tt>ROCKT1.BA</td></td><td>-101-</td><td>Another Lunar Lander Simulator. Written by Eric Peters, Digital. Thought lost.  Recovered from <a href="http://www.pdp8online.com/pdp8cgi/os8_html/ROCKT1.BA?act=file;fn=images/os8/diag-games-kermit.rk05;blk=570,8,1;to=auto">Dave Gesswein's Archive</a>.</td></tr>
<tr><td><tt>ROULET.BA</td></td><td>-----</td><td>European Roulette Wheel game.  Written by David Joslin. Converted to BASIC-PLUS by David Ahl, Digital.  Ported to OS/8 BASIC By Kay R. Fisher, DEC.  Thought lost.
Recovered from <a href="http://www.pdp8online.com/pdp8cgi/os8_html/ROULET.BA?act=file;fn=images/os8/diag-games-kermit.rk05;blk=578,17,1;to=auto">Dave Gesswein's Archive.</td></tr>
<tr><td><tt>SIGNS .BA</td></td><td>-----</td><td>Program to print posters by Daniel R. Vernon, Butler High School, Butler PA.<br><b>Usage: </b>When tested the under OS/8 BASIC we get <tt>SU  AT LINE 00261</tt> which is a Subscript out of Bounds error.</td></tr>
<tr><td><tt>SNOOPY.BA</td></td><td>-----</td><td>The old <i>Curse You Red Barron</i> Snoopy poster.</td></tr>
<tr><td><tt>SPACWR.BA</td></td><td>-101-</td><td>Space war game based on classic Star Trek.  Game written by Mike Mayfield, Centerline Engineering.</td></tr>
<tr><td><tt>TICTAC.BA</td></td><td>-----</td><td>Play tic-tac-toe with the computer.  Simple version. Thought lost.  Recovered from <a href="http://www.pdp8online.com/pdp8cgi/os8_html/TICTAC.BA?act=file;fn=images/os8/diag-games-kermit.rk05;blk=595,7,1;to=auto">Dave Gesswein's Archive.</td></tr>
<tr><td><tt>WAR.BA</td></td><td>-101-</td><td>Play the game of war against the computer. Was thought lost.  Recovered from [Dave Gesswein's Archive](). However, that port to OS/8
BASIC contained a bug and could never run.  Line 230 defines the array for the cards.
In OS/8 BASIC the maximum string size needed to be specified, as well as the number of strings.
`230 DIM A$(52,3),L(54)` will not accomodate the 10-value card.  The 3 needed to be a 4. 
Program fixed and run-tested.</td></tr>
<tr><td><tt>WAR2.BA</td></td><td>-101-</td><td>Deploy 72,000 soldiers to Army, Navy, and Air Force against the computer. Written by Bob Dores, Milton, MA.</td></tr>
<tr><td><tt>WEKDAY.BA</td></td><td>-101-</td><td>Input a birth date and learn fun facts about happenings in the elapsed time. Written by Tom Kloos, Oregon Museum of Science and 'Industry.</td></tr>
<tr><td><tt>WUMPUS.BA</td></td><td>-----</td><td>Hunt the wumpus.</td></tr>
<tr><td><tt>YAHTZE.BA</td></td><td>-101-</td><td>Dice game of Yahtze.  Author unknown.  Quite an elaborate and comprehensive implementation.</td></tr>
</table>

## License

Copyright © 2017-2020 by Bill Cattey. This document is licensed under the terms of [the SIMH license][sl].

[sl]:   https://tangentsoft.com/pidp8i/doc/trunk/SIMH-LICENSE.md

