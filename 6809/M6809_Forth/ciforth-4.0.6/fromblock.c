/* $Id: fromblock.c,v 4.1 2002/10/17 13:44:04 albert Exp $                   */
/* Copyright(2000): Albert van der Horst, HCC FIG Holland by GNU Public License */
#include <stdio.h>
#include <string.h>

/* Tabs are not printable, I think. */
#define isrealprint(a)   (isprint(a) && 9 != a )

main(char **argv, int argc)
{
    int count = 0;
    int ch;

    while(EOF !=(ch=getchar()))
    {
        char buffer[64];

        buffer[count++] = isrealprint(ch)?ch:' ';
        if ( 64 == count)
        {
            int i;
            /* Get rid of '\n' always. */
            do{ count -= 1; } while( ' ' == buffer[count-1] );
            for(i=0; i<count; i++) putchar(buffer[i]);
            putchar('\n');
            count = 0;
        }
    }
    return 0;
}
