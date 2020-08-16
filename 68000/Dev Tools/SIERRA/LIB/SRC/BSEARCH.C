/*
 *  bsearch.c
 *
 *  Copyright 1987, 1992 by Sierra Systems.  All rights reserved.
 */

#include <stdlib.h>
#include <stddef.h>

/*--------------------------------- bsearch() -------------------------------*/

/*
 * bsearch function searches an array of nbr_elements objects, the initial
 * element of which is pointed to by base, for an element that matches the
 * object pointed to by key.  The size of each element in the array is
 * specified by size.
 *
 * The comparision function pointed to by compare_func is called with two
 * arguments that point to the key object and to an array element in that
 * order.  The function returns an integer less than, equal to or greater
 * than zero if the key object compares less than, equal to or greater than
 * the array element.  The array must consist elements sorted in ascending
 * order as determined by the compare function.
 *
 * The bsearch() function returns a pointer t the matching element of the
 * array, or a null pointer if no match is found.  If two or more elements
 * of the array compare equal to the key, the element that is matched is
 * unspecified.
 *
 * Usage:
 *
 *	void *bsearch(const void *key, const void *base, size_t nbr_elements,
 *	size_t size, int (*compare_func)(const void *, const void *))
 *
 *	key ----------- the object to compare to
 *	base ---------- the first element in the sorted array to be search
 *	nbr_elements -- the number of elements in the array to be searched
 *	size ---------- the size of each element in bytes
 *	compare_func -- pointer to a function which, when passed pointers to
 *			two object, the key and an array element, will return
 *			an integer less than zero, zero, or greater than
 *			zero, according to whether the item pointed to by the
 *			key is less than, equal to, or greater than the item
 *			pointed to by the second pointer.
 */

void *bsearch
(
register const void *key,
register const void *base,
register size_t nbr_elements,
register size_t size,
register int (*compare_func)(const void *, const void *)
)
{
    register char *mid;
    register int test;

    while( nbr_elements > 0 ) {
	mid = (char *)base + size * (nbr_elements / 2);
	if( (test = compare_func(key, mid)) < 0 )
	    nbr_elements /= 2;
	else if( test > 0 ) {	
	    base = mid + size;
	    nbr_elements = --nbr_elements / 2;
	}
	else
	    return((void *)mid);
    }
    return(NULL);
}
