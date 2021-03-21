/*	make_cc.c

	Mike's Enhanced Small C Compiler for Z80 & CP/M

	Build the compiler itself with MESCC under a z80 & CP/M environment.

	Copyright (c) 1999-2016 Miguel I. Garcia Lopez, FloppySoftware.

	This program is free software; you can redistribute it and/or modify it
	under the terms of the GNU General Public License as published by the
	Free Software Foundation; either version 2, or (at your option) any
	later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program; if not, write to the Free Software
	Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.

	How to build MESCC with this file:

	cc make_cc -s:1024
	ccopt make_cc
	zsm make_cc
	hextocom make_cc

	Now MAKE_CC.COM is the new version of the compiler.

	Revisions:

	16 Jan 2001 : Last revision.
	16 Apr 2007 : GPL'd.
	04 Sep 2015 : Modified some comments.
	26 Oct 2015 : Added c_defs.c. Modified some comments.
	10 Jan 2015 : Added CC_FILEIO_SMALL def.
	19 Jul 2016 : Removed CC_FILEIO_SMALL def.
	11 Oct 2016 : Added c_parser.c. Documented.
	20 Oct 2016 : Added c_string.c.
*/

// MESCC #definitions
// ------------------

// Nothing yet...

// MESCC runtime
// -------------

#include <mescc.h>

// MESCC libraries
// ---------------

#include <fileio.h>
#include <conio.h>
#include <string.h>
#include <ctype.h>
#include <mem.h>

// Compiler modules
// ----------------

#include "c_defs.c"
#include "c_string.c"
#include "c_main.c"
#include "c_parser.c"
#include "c_cpp.c"
#include "c_expr.c"
#include "c_asm.c"
#include "c_error.c"
#include "c_buf.c"
#include "c_iocon.c"
#include "c_iofile.c"
