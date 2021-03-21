/*  xgrapfnt.c

    Manages the Multicomp internal font from disk.

    Uses the XGRAPH library.

    Copyright (c) 2015 Miguel Garcia / FloppySoftware

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

    To compile with MESCC:

    cc xgrapfnt
    ccopt xgrapfnt
    zsm xgrapfnt
    hexcom xgrapfnt
    gencom xgrapfnt.com xgraph.rsx

    Changes:

    23 Sep 2015 : v1.00 : 1st version.
    17 Nov 2016 : v1.01 : Documented a bit. Minor modifications in usage text.
   ===========================================================================
    19 Mar 2019 : v1.00 : Adaption for Multicomp 'xgraph'
*/

/* Defs. for MESCC
   ---------------
*/
#define CC_FREAD   // To include fread()
#define CC_FWRITE  // To include fwrite()

/* Standard MESCC library
   ----------------------
*/
#include <mescc.h>

/* Standard MESCC libraries
   ------------------------
*/
#include <printf.h>
#include <alloc.h>
#include <fileio.h>

/* xgraph libraries
   --------------
*/
#include "xgraph.h"
#include "xchrdef.h"

/* Project defs.
   -------------
*/
#define APP_NAME    "XGRAPH-Font"
#define APP_VERSION "v1.00 / 25 Mar 2019"
#define APP_COPYRGT "Multicomp Z80"
#define APP_USAGE   "xgrapfnt -option filename"

/* Main
   ----
*/
int main(argc, argv)
int argc;
unsigned int argv[]; /* char *argv[] */
{
    char *p;

    /* Check arguments */

    p = argv[1];

    if(argc < 2 || (*p != '-' || p[1] == 0 || p[2] != 0))
    {
        usage();
    }

    /* Check if the xgraph RSX is in memory */

    if(!HelloRsx()) {
        error("The xgraph RSX is not in memory");
    }

    /* Run the selected option */

    switch(p[1]) {
        case 'L': /* Load font */
            if(argc != 3) {
                usage();
            }

            load(argv[2]);
            break;
        case 'S': /* Save font */
            if(argc != 3) {
                usage();
            }
            save(argv[2]);
            break;
        default :
            usage();
            break;
    }

    /* Exit */

    return 0;
}

/* Change the internal font from a file
   ------------------------------------
*/
load(fn)
char *fn;
{
    FILE *fp;
    BYTE *buf, *p;
    int i;

    /* Buffer */

    if((buf = p = malloc(2048)) == NULL) {
        no_mem();
    }

    /* Open file */

    if((fp = fopen(fn, "rb")) == NULL) {
        cant_open();
    }

    /* Read font from file */

    if(fread(buf, 2048, 1, fp) != 1) {
        cant_read();
    }

    /* Close file */

    fclose(fp);

    /* Set the internal font */

    WrFntROM(255, 0x00, p);

    /* Free buffer */

    free(buf);
}

/* Save the internal font to a file
   --------------------------------
*/
save(fn)
char *fn;
{
    FILE *fp;
    BYTE *buf, *p;
    int i;

    /* Buffer */

    if((buf = p = malloc(2048)) == NULL) {
        no_mem();
    }

    /* Get the internal font to buffer p */

    RdFntROM(255, 0x00, p);

    /* Open file */

    if((fp = fopen(fn, "wb")) == NULL) {
        cant_open();
    }

    /* Write font to file */

    if(fwrite(buf, 2048, 1, fp) != 1) {
        cant_write();
    }

    /* Close file */

    if(fclose(fp)) {
        cant_write();
    }

    /* Free buffer */

    free(buf);
}

/* Show usage and exit
   -------------------
*/
usage()
{
    printf("%s %s - %s\n\n", APP_NAME, APP_VERSION, APP_COPYRGT);
    printf("Manage Multicomp xgraph fonts.\n\n");
    printf("Usage: xgrapfnt -option filename\n\n");
    printf("Load font: -L fname\n");
    printf("Save font: -S fname\n");

    exit(0);
}

/* Print error and exit
   --------------------
*/
error(txt)
char *txt;
{
    printf("ERROR: %s.\n", txt);

    exit(1);
}

/* Error: Not enough memory
   ------------------------
*/
no_mem()
{
    error("Not enough memory");
}

/* Error: Can't open file
   ----------------------
*/
cant_open()
{
    error("Can't open file");
}

/* Error: Can't read file
   ----------------------
*/
cant_read()
{
    error("Can't read file");
}

/* Error: Can't write file
   -----------------------
*/
cant_write()
{
    error("Can't write file");
}



