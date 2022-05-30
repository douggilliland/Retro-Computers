/* 
 * Program to convert between POSIX ASCII text files
 * and the output of OS/8 PIP to the Paper Tape Punch.

 * The OS/8 paper tape punch format is:
 *
 *     leader: a bunch of ASCII NUL chars to be ignored.
 *     ASCII with the 8th bit set, CR+LF line endings.
 *     trailer: a bunch of ASCII NUL chars to be ignored.

 * This program can be used as a filter from stdin to stdout or
 * it will create a new file with name ending in .txt if going to
 * POSIX text or .ptp if going to OS/8 PIP Paper Tape format.

 * If the program is called with the name "txt2ptp" then
 * LTCOUNT (default 100) bytes of leader is prepended to the
 * output file and LTCOUNT bytes of leader are appended.
 * The 8th bit of every output character is set, and LF-only
 * input is turned into CR+LF output.  CR+LF input is passed
 * as-is.
 
 * If called by any other name, the ASCII NUL character is
 * ignored anywhere in the file, and the 8th bit is cleared.
 * Line endings are untouched in this case.

 * This program helps work around the issue that the 
 * OS/8 Paper Tape reader handler assumes the last
 * character in the buffer is junk, so that when you send
 * a plain text file into PDP-8 SIMH OS/8 with the
 * ptr device, the last character is lost.
 */

/*
 * Author: Bill Cattey
 * License:  The SIMH License:

 * Copyright © 2015-2017
 * by Bill Cattey et. ux. William Cattey et. ux. Poetnerd

 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject
 * to the following conditions:

 * The above copyright notice and this permission notice shall be include
 * in all copies or substantial portions of the Software.

 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS LISTED ABOVE BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
 * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
 * IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.

 * Except as contained in this notice, the names of the authors
 * above shall not be used in advertising or otherwise to promote
 * the sale, use or other dealings in this Software without
 * prior written authorization from those authors.
 */

#include <errno.h>
#include <fcntl.h>
#include <sys/types.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <libgen.h>

#define BLOCK_SIZE 256
#define TO_PTP 1
#define TO_TXT 2
#define LTCHAR '\0'
/* PIP ASCII mode adds rubout after control chars so we strip them out too. */
#define RUBOUT '\377'
#define LTCOUNT 100

/* global variable: ltbuf */
int global_ltbuf[LTCOUNT];


void make_txt (FILE *fpin, FILE *fpout)
{
    int inchar, outchar;
    int read_ct, n;
    char *obuffp;
    char ibuff[BLOCK_SIZE], obuff[BLOCK_SIZE];

    while ((read_ct = fread (ibuff, sizeof(char), BLOCK_SIZE, fpin))) {
        obuffp = obuff;
        for (n = 0; n < read_ct; n++) {
            inchar = *(ibuff + n);
            if (inchar == LTCHAR || inchar == RUBOUT) continue;
            *obuffp++ = inchar & 0177;
        }
        fwrite (obuff, sizeof(char), obuffp - obuff, fpout);
    }
}

/* We could just create an empty buffer and output it,
   but this is better if for some reason LTCHAR changes. */ 
void init_ltbuf ()
{
    int n;

    for (n = 0; n < LTCOUNT; n++) {
        global_ltbuf[n] = LTCHAR;
    }
}

void make_lt (FILE *fpout)
{
    fwrite (global_ltbuf, sizeof(char), LTCOUNT, fpout);
}

void make_ptp (FILE *fpin, FILE *fpout)
{
    int inchar, outchar, prior = '\0';
    int read_ct, n;
    char *obuffp;
    char ibuff[BLOCK_SIZE];
    /* Every \n might add a \r to the output. 
       Worst case is obuff doubles in size. */
    char obuff[2*BLOCK_SIZE];

    make_lt (fpout);

    while ((read_ct = fread (ibuff, sizeof(char), BLOCK_SIZE, fpin))) {
        obuffp = obuff;
        for (n = 0; n < read_ct; n++) {
            inchar = *(ibuff + n);
            if (inchar == '\n' && prior != '\r') {
                *obuffp++ = (char)('\r' | 0200);
            }
            *obuffp++ = inchar | 0200;
            prior = inchar;
        }
        fwrite (obuff, sizeof(char), obuffp - obuff, fpout);
    }
    /* If we don't already have an EOF, add one. */
    if (inchar != '\032') {
      fwrite ("\232", sizeof(char), 1, fpout);
    }
    make_lt (fpout);
}


void process_file (char *fname, int flag)
{
    FILE *fpin, *fpout;

    char *ofname;
    char *fend;

    if (flag == TO_PTP) fend = ".ptp";
    else fend = ".txt";

    ofname = malloc (((strlen (fname) + strlen(fend)) * sizeof (char)) + 1);
    strcpy (ofname, fname);
    strcat (ofname, fend);

    /* printf ("Filename is: %s.\n", ofname); */

    if ((fpin = fopen (fname, "r")) == NULL) {
        printf ("Open of input file %s failed with status %d.  Skipping.\n",
                fname, errno);
        return;
    }
    if ((fpout = fopen (ofname, "w")) == NULL) {
        printf ("Open of output file %s failed with status %d.  Skipping.\n",
                ofname, errno);
        return;
    }
    if (flag == TO_PTP)
        make_ptp (fpin, fpout);
    else
        make_txt (fpin, fpout);

    fclose (fpin);
    fclose (fpout);
    free (ofname);
}

int main (int argc, char *argv[])
{
    int i, flag;
    char *ltbuf;

    if (strcmp (basename (argv[0]), "txt2ptp") == 0) {
        /* printf ("Flag is TO_PTP"); */
        flag = TO_PTP;
        init_ltbuf ();
    }
    else {
        flag = TO_TXT;
    }

    if (argc == 1) {
        if (flag == TO_PTP) make_ptp (stdin, stdout);
        else make_txt (stdin, stdout);
    }
    else {
        for (i = 1; i < argc; i++) {
            process_file (argv[i], flag);
        }
    }
}

