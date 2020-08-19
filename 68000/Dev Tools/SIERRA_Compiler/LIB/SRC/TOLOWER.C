/*
 *  tolower.c
 *
 *  Copyright 1987, 1992 by Sierra Systems.  All rights reserved.
 */

#include <ctypex.h>

/*--------------------------------- tolower() -------------------------------*/

/*
 * tolower converts upper-case characters to lower-case alphabetic
 * characters.	Non upper-case characters are returned without modification.
 * Note, _tolower() also converts characters to lower-case but if the
 * argument to _tolower() is not an upper-case character the result will be
 * incorrect.
 */

int (tolower)(int c)
{
    return(tolower(c));
}
