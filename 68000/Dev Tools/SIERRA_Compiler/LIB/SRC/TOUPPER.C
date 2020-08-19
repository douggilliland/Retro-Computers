/*
 *  toupper.c
 *
 *  Copyright 1987, 1992 by Sierra Systems.  All rights reserved.
 */

#include <ctypex.h>

/*--------------------------------- toupper() -------------------------------*/

/*
 * toupper converts lower-case characters to upper-case alphabetic
 * characters.	Non lower-case characters are returned without modification.
 * Note, _toupper() also converts characters to upper-case but if the
 * argument to _toupper() is not a lower-case character the result will be
 * incorrect.
 */

int (toupper)(int c)
{
    return(toupper(c));
}
