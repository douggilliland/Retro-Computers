/**
 * @file   qsort.h
 * @brief  Sort function.
 * @author Miguel I. Garcia Lopez / FloppySoftware
 *
 * This library implements a sort function of general use,
 * which uses the bubble sort algorithm, for MESCC (Mike's Enhanced
 * Small C Compiler for Z80 & CP/M).
 *
 * Revisions:
 *  - 30 Nov 2015 : First version (bubble sort).
 *  - 15 Aug 2016 : Documented. GPL v3.
 *
 * Copyright (c) 2015-2016 Miguel I. Garcia Lopez / FloppySoftware.
 *
 * Licensed under the GNU General Public License v3.
 *
 * http://www.floppysoftware.es
 * floppysoftware@gmail.com
 */
#ifndef QSORT_H

#define QSORT_H

/**
 * @fn     void qsort(void *base, size_t items, size_t size, int (*comp)(const void *, const void*))
 * @brief  Sort an array of elements.
 *
 * Sort an array of elements into ascending order.
 *
 * The comparison function must return:
 *  - <0 on elem1 <  elem2
 *  - =0 on elem1 == elem2
 *  - >0 on elem1 >  elem2
 *
 * @param  base  - address of first element
 * @param  items - number of elements in the array
 * @param  size  - size in bytes of each element
 * @param  comp  - comparison function
 */
qsort(base, items, size, comp)
BYTE *base; int items, size; WORD comp;
{
	int i, j, k;
	BYTE *pi, *pj, t;

	for(i = 0; i < items; ++i)
	{
  		for(j = i + 1; j < items; ++j)
		{
			pi = base + i * size;
			pj = base + j * size;

   			if(comp(pi, pj) > 0)
			{
				for(k = 0; k < size; ++k) {
					t = *pi;
					*pi++ = *pj;
					*pj++ = t;
				}
   			}
  		}
 	}
}

#endif

