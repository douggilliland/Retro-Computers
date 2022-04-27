/* $Id: toblock.c,v 4.1 2002/10/17 13:44:31 albert Exp $                   */
/* Copyright(2000): Albert van der Horst, HCC FIG Holland by GNU Public License */
#include <stdio.h>
#include <string.h>

#define CPL 64
int line = 0;
char *progname;

void error(char *message)
{
    fprintf(stderr, "Error in program %s\n"
        "    at input line %d\n"
        "   %s\n", progname, line, message);
    exit(1);
}

void check_index(char buffer[])
{
    char *pc;
    static int infoline = 1;

    if ( '(' == buffer[0] ) return;

    for(pc=buffer; *pc; pc++ )
        if (' ' != *pc && '\n' != *pc )
        {
            if ( infoline )
            {
                fprintf(stderr, "Possible non-index line in block file \n");
                infoline = 0 ;
            }
            fprintf(stderr, " at block %d:%s", line/16, buffer);
            return;
        }
}

int main( int argc , char **argv )
{
    int count = 0;
    int i;
     /* One extra for the '\n', one for the '\000', and one to detect
      * oversized lines  */
    char buffer[CPL+3];
    int ch;

    progname = argv[0];

    while(NULL != fgets(buffer, CPL+3, stdin))
    {
        if ( 0 == line%16 ) check_index(buffer);
        line += 1;
        count = strlen(buffer);
        if ( CPL < count ) error("line too long");
        buffer[--count] = '\000';  /* Remove '\n' */
        for(i=0; i<CPL-1; i++)
            putchar(i<count?buffer[i]:' ');
        putchar('\n');
    }
    return 0;
}
