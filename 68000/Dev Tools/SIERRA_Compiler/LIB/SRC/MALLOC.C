/*
 *  malloc.c	(libc)
 *
 *  Copyright 1987, 1993 by Sierra Systems.  All rights reserved.
 */

#include <stdlib.h>
#include <stddef.h>
#include <string.h>
#include <io.h>

typedef long ALIGN;	    /* most restrictive type on 68000		 */

/* header to each memory block */

typedef union header {
    union header *link;	    /* pointer to next block (free or reserved)	 */
    ALIGN padding;	    /* force alignment of returned pointer	 */
} HEADER;

#define BUSY		0x1			/* set if block reserved */
#define BLOCK		(256 * sizeof(HEADER))	/* sbrk request size	 */
#define roundup(n,g)	((g-1) - ((n-1) % g))
#define isbusy(p)	(((long)p) & BUSY)
#define clrbusy(p)	((HEADER *)(((long)p) & ~BUSY))
#define setbusy(p)	((HEADER *)(((long)p) | BUSY))

static HEADER *rover;
static HEADER *end;
static HEADER *realloc_block;
static HEADER base[2];

/*------------------------------- malloc() ----------------------------------*/

/*
 * malloc is the key routine in the dynamic memory allocation package
 * formed by malloc(), free(), calloc() and realloc().	The algorithm used
 * is an adaptation of the one given by Knuth as Algorithm C in
 * Section 2.5 of "The Art of Computer Programming", Vol. 1,
 * which incorporates some of the recommendations Knuth makes elsewhere in
 * the section as well as other improvements.  The memory pool is maintained
 * as a circular linked list of blocks where each block is preceded by a
 * header containing the link to the next block and any padding necessary
 * to satisfy hardware alignment requirements.	All blocks, whether free or
 * busy, are kept on the list; the state of the least significant bit of the
 * link pointer reflects the status of the following block - cleared for
 * free, set for busy.	As a consequence of this, the size of a block can
 * be computed as the difference between its address and the address
 * contained in its link pointer, and need not be carried along explicitly
 * in the block header.	 New memory is added to the pool via calls to the
 * system routine sbrk().  No relationship between blocks returned by
 * successive calls to sbrk() is assumed, but if such blocks are contiguous
 * they are coalesced with previous blocks when possible.  If a block
 * allocated by sbrk() is not contiguous with the previous block, a stopper
 * block of size zero is placed at the tail end of the previous block and
 * marked as busy, thus preventing any attempt to coalesce the two blocks.
 *
 * When malloc() is called, it chains through the list, ignoring busy blocks
 * and coalescing adjacent free blocks, stopping when a large enough free
 * block is found.  The starting position for the search is kept in a roving
 * pointer; when the search wraps around to this pointer again, a call to
 * sbrk() is generated.	 A block is freed by (a call to free()) simply by
 * clearing the busy bit of its link.
 *
 * A block allocated by malloc() is guaranteed to be aligned properly for
 * all data types supported by C.  This is done by implementing the block
 * header as a union capable of containing the most restrictive data type,
 * and by forcing the size of allocated blocks to be an integer multiple of
 * the header size (by rounding up the size specified by the caller).
 *
 * The constant BLOCK defines the unit size of memory requests made to
 * sbrk().  The definition of BLOCK guarantees that it will be a multiple of
 * the header size.  It is possible to tailor the value of BLOCK to the
 * run-time environment by adjusting the constant by which sizeof(HEADER) is
 * multiplied in the #define BLOCK statement.
 *
 * Usage:
 *	void *malloc( size_t size )
 *
 *	size ---- the size of the desired block in bytes
 *	return -- pointer to the allocated block or NULL if sufficient
 *		  memory could not be allocated
 *
 * The block returned by malloc() is not initialized, and may be larger (but
 * never smaller) than the requested size.  Although malloc() attempts to
 * detect corruption of the memory pool it is not always, or even often,
 * possible to do so, and so the user must take care to use only the memory
 * which has been allocated.
 */

void *malloc(register size_t size)
{
    register HEADER *pcur;
    register HEADER *pnxt;
    register int wrap;
    register int n;
    HEADER *end_free_block;

    if( size <= 0 )
	return(NULL);

    /* Round size up to nearest multiple of sizeof(HEADER) */
    /* and add on sizeof(HEADER) (since a HEADER must be   */
    /* allocated along with the block).			   */

    size += roundup(size, sizeof(HEADER)) + sizeof(HEADER);

    /* If this is the first call to malloc(), initialize empty memory pool. */
    /* base[] contains two HEADER's separated by a block of size zero.	end */
    /* points to end of the list and rover to the current search position.  */

    if( rover == NULL ) {

	/* first call to malloc() */

	base[0].link = setbusy(&base[1]);
	base[1].link = setbusy(&base[0]);
	rover = &base[0];
	end = &base[1];
    }

    /*	current block <- roving search pointer;		     */
    /*	    Block search loop {				     */
    /*	    if( current block free ) {			     */
    /*		coalesce successive free blocks;	     */
    /*		if( block big enough )			     */
    /*		    allocate block and return;		     */
    /*	    }						     */
    /*	    if( search has wrapped around to roving pointer) */
    /*		attempt to increase memory pool via sbrk();  */
    /*	}						     */

    pcur = rover;
    end_free_block = NULL;
    for( ; ; ) {
	if( !isbusy(pcur->link) ) {
	    for( pnxt = pcur->link; !isbusy(pnxt->link); pnxt = pnxt->link ) {

		/* if it wrapped around the rover must be reset (12-6-93) */

		if( pnxt == rover )
		    rover = pcur;

		if( pnxt <= pcur )	/* list corrupted */
		    return(NULL);
	    }
	    wrap = ((pnxt == rover->link) && (pcur != rover));
	    pcur->link = pnxt;
	    if( pnxt == end )
		end_free_block = pcur;
	    n = (char *)pnxt - (char *)pcur;
	    if( n >= size ) {

		/* block is big enough */

		if( (n - size) >= (2 * sizeof(HEADER)) ) { /* 10-29-90 >= */

		    /* Allocate the front end of the block if this is the */
		    /* last block in the list or if this block is being	  */
		    /* reallocated; but do not allocate the front end if  */
		    /* doing so will divide a block being reallocated.	  */

		    if( ((pnxt == end) && 
		    (!realloc_block || (realloc_block->link != pnxt))) ||
		    (pcur == realloc_block) ) {
			pnxt = (HEADER *)((char *)pcur + size);
			rover = pnxt;
			pnxt->link = pcur->link;
		    }

		    /* Otherwise, allocate the tail end of the block to */
		    /* keep busy blocks together (we might not know the */
		    /* status of the previous block).			*/
	
		    else {
			pcur->link = (HEADER *)((char *)pnxt - size);
			rover = pcur;
			pcur = pcur->link;
		    }
		}

		/* rover must be reset if the block returned to the user  */
		/* wraps across rover, that is, it was able to coales the */
		/* last block (it went all the way around) before going	  */
		/* to sbrk()						  */

		/* probably not needed now as a result of fix of 12-6-93  */

		if( (rover < pnxt) && (rover > pcur) )
		    rover = pnxt;

		pcur->link = setbusy(pnxt);
		return((void *)(pcur + 1));
	    }
	}
	else {
	    pnxt = clrbusy(pcur->link);
	    wrap = 0;
	}
	if( ((pcur = pnxt) == rover) || wrap ) {    /* wrapped around list */
	    n = size + sizeof(HEADER);
	    n += roundup(n, BLOCK);
	    if( (pcur = (HEADER *)sbrk(n)) == NULL )
		return(NULL);
	    pnxt = (HEADER *)((char *)pcur + (n - sizeof(HEADER)));
	    pnxt->link = end->link;
	    if( pcur == (end + 1) ) {
		if( end_free_block != NULL )
		    pcur = end_free_block;
		else
		    pcur = end;
	    }
	    else
		end->link = setbusy(pcur);
	    pcur->link = pnxt;
	    end = pnxt;
	    rover = pcur;
	}
    }
}

/*--------------------------------- free() ----------------------------------*/

/*
 * free is the standard C library function which is called to free
 * memory blocks allocated by malloc().	 Because busy blocks are kept
 * on the same list as free blocks, they are freed simply by clearing
 * BUSY in the block header.  No attempt is made by free() to check the
 * validity of the block being freed, but malloc(), when combining adjacent
 * free blocks, does check to ensure that they are in increasing order.
 *
 * Usage:
 *
 *	void free(void *ptr)
 *
 *	ptr -- points to a block of memory previously allocated by malloc()
 *	       or realloc()
 *
 * If a NULL pointer is passed to free(), it returns without taking any
 * action.
 */

void free(void *ptr)
{
    register HEADER *ptr1;

    if( ptr ) {

	ptr1 = ((HEADER *)ptr) - 1;

	/* If malloc's roving allocation pointer is pointing to the    */
	/* block immediately after the one being freed, set it to      */
	/* point to the one being freed.  On the next call to malloc,  */
	/* this block will be coalesced with any adjacent free blocks, */
	/* thus reducing memory fragmentation.			       */

	if( (ptr1->link = clrbusy(ptr1->link)) == rover )
	    rover = ptr1;
    }
}

/*------------------------------- realloc() ---------------------------------*/

/*
 * realloc is a standard C library routine which reallocates a block
 * of memory previously allocated by malloc() with a new size.	If
 * possible, the block is reallocated in place; otherwise it is moved
 * to a new starting address.  In either case, the contents of the
 * block remain fully intact if the new size is equal to or greater
 * the old size; if the new size is smaller than the old size, the
 * previous contents are preserved through the extent of the new block.
 *
 * realloc() is basically a shell for malloc().	 The block being
 * reallocated is freed, and then a call to malloc() is made with the
 * block size as argument.  In order to force malloc to try first to
 * allocate the new block with the same starting address as the one
 * being reallocated, rover, the roving allocation pointer, is set to the
 * address of the old block before the call. In addition, a static pointer
 * realloc_block is loaded with the address of the old block; this will
 * force malloc() to allocate the front end of the block if there is
 * additional space beyond the old block to accomodate the reallocation
 * request.  If the new block does not have the same address as the old
 * block, the contents of the old block are copied to the new block.
 *
 * It should be noted that malloc() and realloc() are a team; changing
 * one might affect the other.	realloc() also makes assumptions about
 * the data structures used in the malloc() package -- particularly,
 * ALIGN is an atomic C type -- which may be invalidated if malloc()
 * is ported.
 *
 * Usage:
 *
 *	void *realloc(void *ptr, size_t size)
 *
 *	ptr -- points to a memory block previously allocated by malloc()
 *	       or realloc()
 *	size -- the desired size of the reallocated block
 *	return -- pointer to reallocated block
 */

void *realloc(register void *ptr, size_t size)
{

    register unsigned oldsize;
    register void *new;

    if( ptr == NULL )
	return(malloc(size));

    /* oldsize is the number of characters in previously allocated block */
    /* free old bolock so that malloc() will try to use it first	 */

    rover = (HEADER *)ptr - 1;
    rover->link = clrbusy(rover->link);
    oldsize = (char *)rover->link - (char *)ptr;

    if (size == 0)		    /* Zero size request means free memory. */
	return(NULL);

    realloc_block = rover;
    new = malloc(size);
    realloc_block = NULL;

    /* if malloc failed, restore callers block of memory */

    if( new == NULL ) {
	rover = (HEADER *)ptr - 1;		/* callers block of memory */
	rover->link = setbusy(rover->link);
	return(NULL);
    }

    /* If the new block is not in the same place as the old, copy the	*/
    /* contents of the old block.  This will never occur if the current */
    /* request is for fewer bytes than the previous one.		*/

    if( ptr != new )
	(void)memcpy(new, ptr, oldsize);
    return(new);
}

/*-------------------------------- calloc() ---------------------------------*/
								    
/*
 * calloc is a standard C library function which allocates and zeroes
 * a contiguous block of memory.  It is basically a call to malloc()
 * followed by a function call to clear the allocated memory.  calloc() is  
 * intended to be used in conjunction with free().
 *
 * Usage:
 *
 *	void *calloc(size_t nbr_elements, size_t element_size);					    
 *
 *	nbr_elements -- the number of contiguous elements to allocate
 *	element_size -- the size of each element in bytes
 *	return -------- pointer to the base of the allocated array
 */

void *calloc(register size_t nbr_elements, register size_t element_size)
{
    register void *ptr;

    element_size *= nbr_elements;

    if( (ptr = malloc(element_size)) == NULL )
	return(NULL);

    /* clear the allocated array */

    (void)memset(ptr, 0, element_size);

    return(ptr);
}

