/*
 *  sbrk.c
 *
 *  Copyright 1987, 1992 by Sierra Systems.  All rights reserved.
 */

#include <stddef.h>
#include <errno.h>

#define MARGIN	1000

static unsigned long hp_org(void);
static unsigned long hp_len(void);

char *_heap_base;

/* The symbols heap_org and heap_len are referenced inside of an assembly */
/* language routine because the names do not begin with a leading	  */
/* underscore (_) character. The compiler would prefix an underscore onto */
/* the names when referencing them which would be incorrect.		  */

asm("	.text");
asm("	.align	2");
asm("hp_org:");
asm("_hp_org:");
asm("	move.l	#heap_org,d0");
asm("	rts");

asm("hp_len:");
asm("_hp_len:");
asm("	move.l	#heap_len,d0");
asm("	rts");

/*-------------------------------- sbrk() -----------------------------------*/

/*
 * sbrk gets a new chunk of memory from the heap.  Requests are alinged
 * to a 4 byte boundary and a null pointer is returned if the request
 * exceeds available memory.
 */

void *sbrk(register unsigned long nbr_bytes)
{
    register unsigned long i;
    register void *ptr;
    register char *_heap_org;
    char stack_bottom;	    /* current bottom of stack */

    _heap_org = (char *)(unsigned long)hp_org();

    if( _heap_base == NULL ) {
	if( _heap_org == NULL ) {
	    errno = ENOHEAP;
	    return(NULL);
	}
	i = (unsigned long)_heap_org;
	_heap_base = _heap_org + (((i + 3) & ~3) - i);
    }
    ptr = _heap_base;
    _heap_base += (nbr_bytes + 3) & ~3;

    if( ((_heap_base - 1) > ((_heap_org - 1) + hp_len())) ||
    ((_heap_base > (&stack_bottom - MARGIN)) &&
    (&stack_bottom > _heap_org)) ) {
	_heap_base = ptr;   /* a smaller request may subsequently succeed */
	errno = ENOMEM;
	return(NULL);
    }
    return(ptr);
}
