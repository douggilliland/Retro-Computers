/**
 * @file   alloc.h
 * @brief  Dynamic memory allocation.
 * @author Miguel I. Garcia Lopez / FloppySoftware
 *
 * Dynamic memory allocation functions, for MESCC (Mike's Enhanced
 * Small C Compiler for Z80 & CP/M).
 *
 * Format of each memory block:
 *  - WORD size;        size of data
 *  - BYTE used;        0 = no, 1 = yes
 *  - BYTE data[size];  data
 *
 * Revisions:
 *  - 13 Dec 2000 : Last revision.
 *  - 16 Apr 2007 : GPL'd.
 *  - 26 Aug 2012 : Changed some things for more speed.
 *  - 19 Feb 2015 : Now free() checks if pointer is NULL.
 *  - 15 Aug 2016 : Optimized and documented. GPL v3.
 *  - 21 Aug 2018 : Optimized a bit.
 *
 * Copyright (c) 1999-2016 Miguel I. Garcia Lopez / FloppySoftware.
 *
 * Licensed under the GNU General Public License v3.
 *
 * http://www.floppysoftware.es
 * floppysoftware@gmail.com
 */
#ifndef ALLOC_H

#define ALLOC_H

//#define XM_DEBUG

#define XM_HDR_SIZE 3  // Header size of block in bytes
#define XM_INI_SIZE 6  // Size in bytes needed for setup

extern BYTE *ccfreefirst;
extern WORD ccfreebytes;

BYTE *xm_top, // First block
     *xm_end; // Last block

/**
 * @fn     void *malloc(unsigned int size)
 * @brief  Allocate memory.
 *
 * This function tries to allocated a memory block of requested
 * size in bytes.
 *
 * The contents of the allocated memory block is undefined.
 *
 * @param  size - needed size in bytes
 * @return pointer to allocated memory, or null pointer on failure
 */
malloc(size)
unsigned int size;
{
	BYTE *mptr;
	unsigned int msize;
	WORD *pw;

	// Setup library if needed

	if(!xm_top)
	{
		if(ccfreebytes > XM_INI_SIZE)
		{
			xm_top = ccfreefirst;
			xm_end = xm_top + ccfreebytes - XM_HDR_SIZE;

			// First block has all free memory
			*(pw = xm_top) = ccfreebytes - XM_INI_SIZE;
			xm_top[2] = 0;

			// Last block uses 0 bytes
			*(pw = xm_end) = 0;
			xm_end[2] = 1;
		}
	}

	// Search a free block

	for(mptr = xm_top; mptr != xm_end; mptr += msize + XM_HDR_SIZE)
	{
		msize = *(pw = mptr);

		if(!mptr[2])
		{
			if(msize >= size)
			{
				mptr[2] = 1;

				if(msize >= size + XM_HDR_SIZE)
				{
					*(pw = mptr) = size;
					*(pw = mptr + size + XM_HDR_SIZE) = msize - size - XM_HDR_SIZE;
					*(mptr + size + 5) = 0;
				}

#ifdef XM_DEBUG
	alloc_dbg("malloc", size);
#endif
				return mptr + XM_HDR_SIZE;
			}
		}
	}

#ifdef XM_DEBUG
	alloc_dbg("malloc", size);
#endif

	return NULL;
}

/**
 * @fn     void free(void *ptr)
 * @brief  Deallocate memory.
 *
 * This function deallocates memory, previously allocated with malloc.
 *
 * If ptr is a null pointer, the function does nothing.
 *
 * @param  ptr - memory block to deallocate
 */
free(ptr)
BYTE *ptr;
{
	BYTE *mptr;
	unsigned int msize;
	WORD *pw;

	// Do nothing on null pointer

	if(!ptr)
		return;

	// Make free

	*(ptr - 1) = 0;

	// Join to another free memory blocks if possible

	for(mptr = xm_top; mptr != xm_end; mptr += msize + XM_HDR_SIZE)
	{
		msize = *(pw = mptr);

		if(!mptr[2])
		{
			if(!(*(mptr + msize + 5)))
			{
				msize += *(pw = mptr + msize + XM_HDR_SIZE) + XM_HDR_SIZE;

				if(!(*(mptr + msize + 5)))
					msize += *(pw = mptr + msize + XM_HDR_SIZE) + XM_HDR_SIZE;

				*(pw = mptr) = msize;

				break;
			}
		}
	}

#ifdef XM_DEBUG
	alloc_dbg("free", ptr);
#endif
}

#ifdef XM_DEBUG

// void alloc_dbg(char *fn, WORD wrd) : Quick and dirty debug.

alloc_dbg(fn, wrd)
char *fn; WORD wrd;
{
	BYTE *pb, data[4];
	WORD size, *pw;
	int use;

	printf("SP = %04x (%s %04x)\n", alloc_sp(), fn, wrd);

	printf("Addr Size       Next Use Data\n");

	for(pb = xm_top; pb != xm_end; pb += size + XM_HDR_SIZE)
	{
		pw = pb;
		size = *pw;
		use = pb[2];
		memcpy(data, pb + XM_HDR_SIZE, 4);

		printf("%04x %04x %5u %04x %s \n", pb, size, size, pb + XM_HDR_SIZE + size, use ? "Used" : "Free");
	}

	getch();
}

#asm
alloc_sp
	LD  HL,0
	ADD HL,SP
	RET
#endasm

#endif

// Cleaning

#undef XM_DEBUG
#undef XM_HDR_SIZE
#undef XM_INI_SIZE

#endif

