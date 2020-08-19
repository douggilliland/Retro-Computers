/*
 *  main.c
 *
 *  Copyright 1987, 1992 by Sierra Systems.  All rights reserved.
 *
 *  Setup argc and argv, and then call the user's main() routine.
 */

#include <stddef.h>

int _main()
{
    char *argv[1];
    
    argv[0] = NULL;
    return(main(0, argv));
}
