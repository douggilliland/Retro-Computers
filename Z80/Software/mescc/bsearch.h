/**
 * @file   bsearch.h
 * @brief  Binary search.
 * @author Miguel I. Garcia Lopez / FloppySoftware
 *
 * This library implements a binary search function of general use,
 * for MESCC (Mike's Enhanced Small C Compiler for Z80 & CP/M).
 *
 * Revisions:
 *  - 30 Nov 2015 : First version.
 *  - 15 Aug 2016 : Bug solved. Documented. GPL v3.
 *
 * Copyright (c) 2015-2016 Miguel I. Garcia Lopez / FloppySoftware.
 *
 * Licensed under the GNU General Public License v3.
 *
 * http://www.floppysoftware.es
 * floppysoftware@gmail.com
 */
#ifndef BSEARCH_H

#define BSEARCH_H

/**
 * @fn     void *bsearch(const void *key, const void *base, size_t items, size_t size, int (*comp)(const void *, const void *))
 * @brief  Binary search.
 *
 * Search an element in an array, which must be in ascending order.
 *
 * The comparison function must return:
 *  - <0 on key <  base[x]
 *  - =0 on key == base[x]
 *  - >0 on key >  base[x]
 *
 * @param  key   - element to search
 * @param  base  - address of first element
 * @param  items - number of elements in the array
 * @param  size  - size in bytes of each element
 * @param  comp  - comparison function
 * @return pointer to matching element, or null pointer on failure
 */
BYTE *bsearch(key, base, items, size, comp)
BYTE *key, *base; int items, size; WORD comp;
{
	int a, b, c, dir;
	BYTE *p;

	a = 0;
	b = items - 1;

	while (a <= b) {

		c = (a + b) >> 1;  // c = (a + b) / 2;
		p = (base + (c * size));

		if (dir = comp(p, key)) {
			if (dir > 0)
				b = c - 1;
			else
				a = c + 1;
		}
		else
			return p;
	}

	return NULL;
}

#endif

