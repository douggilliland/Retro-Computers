/*
 *  qsort.c
 *
 *  Copyright 1987, 1992 by Sierra Systems.  All rights reserved.
 */

#include <stdlib.h>

#define MINPART	7

typedef struct {
    long el_size;			    /* width			   */
    long pt_size;			    /* min partition size in bytes */
    int (*gbl_cmpf)(const void *, const void *);    /* compare function	   */
    int int_size;			    /* set if array is int-aligned */
} COMMON_VARIABLES;

static void part(char *, char *, COMMON_VARIABLES *);
static void isort(char *, char *, COMMON_VARIABLES *);

/*--------------------------------- qsort() ---------------------------------*/

/*
 * qsort sorts a sequential list of objects using the Quicksort	algorithm
 * as given by Knuth in "The Art of Programming".  The list is partitioned
 * into runs of MINPART or less items not sorted internally, but ordered
 * with respect to each other; then an insertion sort (which runs faster the
 * closer its data is to being already sorted) is used to finish up the sort.
 *
 * Usage:
 *
 *	void qsort(void *base, size_t nbr_elements, size_t size,
 *	int (*compare_func)(const void *, const void *))
 *
 *	base ---------- pointer to the first element in the list
 *	nbr_elements -- the number of elements in the list
 *	size ---------- the size of each element in bytes
 *	compare_func -- pointer to a function which, when passed pointers to
 *			two elements in the list, will return an integer
 *			less than zero, zero, or greater than zero, according
 *			to whether the item pointed to by the first pointer
 *			is less than, equal to, or greater than the item
 *			pointed to by the second pointer.
 */

void qsort
(
void *base,
size_t nbr_elements,
size_t size,
int (*compare_func)(const void *, const void *)
)
{
    COMMON_VARIABLES cv;
    char *pend;

    cv.el_size = size;
    cv.pt_size = size * MINPART;
    cv.gbl_cmpf = compare_func;
    cv.int_size =
    (((long)base & 0x1) == 0) && ((size & (sizeof(int) - 1)) == 0);

    pend = (char *)base + (nbr_elements * size);

    if( nbr_elements > MINPART )	    /* partition list */
	part(base, pend, &cv);
    else
	isort(base, pend, &cv);
}
	
/*-------------------------------- part() ----------------------------------*/
								    
/*
 * part is a utility used by qsort() to partition a sublist of the original
 * list into two runs ordered relative to each other. This is done by
 * choosing the median of the first, middle, and last elements in the sublist
 * and placing it in its correct position in the sublist, making sure in the
 * process that all elements less than it are on its left and all elements
 * greater than it are on its right.  Then each of the two resulting halves
 * is partitioned again if it has at least MINPART elements; the half with
 * the smaller number of elements is partitioned by a recursive call to
 * part(), and the remaining half is partitioned by branching back to the
 * start of the function. (This conserves stack usage). bas points to the
 * fisrt element in the sublist and end points to the first byttte beyond
 * the last element in the sublist.
 */			

static void part(char *base, char *end, COMMON_VARIABLES *cv)
{
    register char *p_left; 
    register char *p_right; 
    register char *p_el; 
    register int *p_int_left;
    register int *p_int_right;
    register size_t esize;
    register char tmp_char;
    register int tmp_int;
    register int (*cmpf)(const void *, const void *);
    long i;

    esize = cv->el_size;
    cmpf = cv->gbl_cmpf;

cont:

    /* set p_el to point to median of first, middle, and last elements	*/

    p_left = base;
    p_right = end - esize;

    i = (p_right - p_left) >> 1;	    /* assume middle is median	 */
    p_el = p_left + (i - (i % esize));	    /* p_el pts to middle	 */

    if( cmpf(p_left, p_right) >= 0 ) {	    /* compare p_left & p_right	 */
	p_left = p_right;		    /* swap ptr values		 */
	p_right = base;			    /* now p_left <= p_right	 */
    }

    if( cmpf(p_right, p_el) <= 0 )	    /* p_left <= p_right <= p_el? */
	p_el = p_right;			    /* p_right is median	  */
    else if( cmpf(p_el, p_left) <= 0 )	    /* p_el <= p_left <= p_right? */
	p_el = p_left;			    /* p_left is median		  */

    p_left = base;			    /* restore p_left		  */

    /* If p_el is not p_left, exchange p_el and p_left so that we know */
    /* where to find the element we are using as a partition	       */

    if( p_el != p_left ) {
	p_right = p_el;
	p_el += esize;
	if( cv->int_size ) {
	    for( p_int_right = (int *)p_right, p_int_left = (int *)p_left;
	    (char *)p_int_right < p_el; ) {
		tmp_int = *p_int_right;
		*p_int_right++ = *p_int_left;
		*p_int_left++ = tmp_int;
	    }
	}
	else {
	    while( p_right < p_el ) {
		tmp_char = *p_right;
		*p_right++ = *p_left;
		*p_left++ = tmp_char;
	    }
	}
	p_left = base;
    }

    /* p_right gets the address of last element in list.  p_left already  */
    /* points to the first element in the list.	 Scan inward with these	  */
    /* two pointers, comparing each element with the partition element	  */
    /* (at p_el) and halting whenever p_left points to an element greater */
    /* than or equal to p_el or p_right points to an element less than or */
    /* equal to p_el.  After halting, if p_left and p_right have not	  */
    /* crossed, exchange the elements they point to and continue.	  */
    /* Otherwise, fall out of the loop.					  */

    p_right = end;
    p_el = base;
    for( ; ; ) {
	while( cmpf(p_left += esize, p_el) < 0 );
	while( cmpf(p_right -= esize, p_el) > 0 );
	if( p_left < p_right ) {
	    p_el = p_right + esize;
	    if( cv->int_size ) {
		for( p_int_right = (int *)p_right, p_int_left = (int *)p_left;
		(char *)p_int_right < p_el; ) {
		    tmp_int = *p_int_right;
		    *p_int_right++ = *p_int_left;
		    *p_int_left++ = tmp_int;
		}
		p_left = (char *)p_int_left;
		p_right = (char *)p_int_right;
	    }
	    else {
		while( p_right < p_el ) {
		    tmp_char = *p_right;
		    *p_right++ = *p_left;
		    *p_left++ = tmp_char;
		}
	    }
	    p_el = base;
	    p_left -= esize;
	    p_right -= esize;
	}
	else
	    break;
    }

    /* p_right and p_left have now crossed.  Their point of convergence */
    /* is where the partition element-- pointed to by p_el-- belongs.	*/
    /* So, exchange p_el and p_right.					*/

    p_left = base;
    p_el = p_right + esize;
    if( cv->int_size ) {
	for( p_int_right = (int *)p_right, p_int_left = (int *)p_left;
	(char *)p_int_right < p_el; ) {
	    tmp_int = *p_int_right;
	    *p_int_right++ = *p_int_left;
	    *p_int_left++ = tmp_int;
	}
	p_right = (char *)p_int_right;
    } else {
	while( p_right < p_el ) {
	    tmp_char = *p_right;
	    *p_right++ = *p_left;
	    *p_left++ = tmp_char;
	}
    }

    /* Check to see if each of the resulting half-lists has at least	  */
    /* MINPART elements.  If so, partition further, by recursion	  */
    /* (for the smaller half) and by branching back (for the larger	  */
    /* half).  Use insertion sort to finish sorting the small partitions. */

    p_left = p_right - esize;
    if( (p_left - base) > (end - p_right) ) {
	if( (end - p_right) > cv->pt_size ) {
	    part(p_right, end, cv);
	    end = p_left;
	    goto cont;
	}
	else if( (end - p_right) > esize )	/* more than one left? */
	    isort(p_right, end, cv);

	if( (p_left - base) > cv->pt_size ) {
	    end = p_left;
	    goto cont;
	}
	else if( (p_left - base) > esize )	/* more than one left? */
	    isort(base, p_left, cv);
    }
    else {
	if( (p_left - base) > cv->pt_size ) {
	    part(base, p_left, cv);
	    base = p_right;
	    goto cont;
	}
	else if( (p_left - base) > esize )	/* more than one left? */
	    isort(base, p_left, cv);

	if( (end - p_right) > cv->pt_size ) {
	    base = p_right;
	    goto cont;
	}
	else if( (end - p_right) > esize )	/* more than one left? */
	    isort(p_right, end, cv);
    }
}

/*--------------------------------- isort() ---------------------------------*/
								    
/*
 * isort is a utility used by qsort() that sorts a parition using insertion
 * sort.  base points to the first element in the sublist and end points to
 * the first byte beyond the last element in the sublist.			
 */

static void isort(char *base, char *end, COMMON_VARIABLES *cv)
{
    register char *pi;
    register char *pj;
    register char *pstop;
    register int *pint_i;
    register int *pint_j;
    register size_t esize;
    register char *pstart;
    register int tmp;
    register long dist;
    register int (*cmpf)(const void *, const void *);

    esize = cv->el_size;
    cmpf = cv->gbl_cmpf;

    /* place the smallest element in the list in the first position */
    /* to act as a sentinel in the insertion sort.		    */

    for( pi = pj = base; (pi += esize) < end; ) {
	if( cmpf(pi, pj) < 0 )
	    pj = pi;
    }
    if( pj != base ) {
	pi = base;
	pstop = pi + esize;
	if( cv->int_size ) {
	    for( pint_i = (int *)pi, pint_j = (int *)pj;
	    (char *)pint_i < pstop; ) {
		tmp = *pint_j;
		*pint_j++ = *pint_i;
		*pint_i++ = tmp;
	    }
	}
	else {
	    while( pi < pstop ) {
		tmp = *pj;
		*pj++ = *pi;
		*pi++ = tmp;
	    }
	}
    }
	
    /* Now run the insertion sort as follows: for each element in the list */
    /* (starting with the third element), scan backwards until the first   */
    /* element smaller than it is found.  Then move the element into its   */
    /* proper place and shift the list to the right simultaneously.	   */

    pj = base + (esize << 1);
    while( pj < end ) {
	pi = pj;
	while( cmpf((pi -= esize), pj) > 0 );
	if( (pi += esize) != pj ) {
	    pstop = pi + esize;
	    dist = (pj - pi);
	    dist += cv->int_size ? sizeof(int) : sizeof(char);

	    for( pstart = pj + esize; pj < pstart; pj += dist ) {
		if( cv->int_size ) {
		    pint_j = (int *)pj;
		    tmp = *pint_j;
		    while( (pint_i = pint_j) >= (int *)pstop )
			*pint_i = *(pint_j -= esize / sizeof(int));
		    *pint_j = tmp;
		    pj = (char *)pint_j;
		}
		else {
		    tmp = *pj;
		    while( (pi = pj) >= pstop )
			*pi = *(pj -= esize);
		    *pj = tmp;
		}
	    }
	}
	else
	    pj += esize;
    }
}
