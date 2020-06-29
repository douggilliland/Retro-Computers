/*
     void free(p)
          char     *p;

          Return the allocated block of memory referenced
          by <p> to the free-list.  The block of memory must
          have been allocated by malloc(), calloc(), or
          realloc().

     Arguments:
          p         Pointer to block to free

     Revision History:

*/

/*
     Allocation definitions
*/
#include  "machine.h"
#include  "alloc.h"


/*
     Global data used by:
     free(), realloc(), calloc(), malloc()
*/

     union header  *_allocp = NULL;
     union header   _base;
     int            __msz = NALLOC * sizeof(union header);




void free(ap)
     char     *ap;
{
     ADDRREG0  union header  *p;
     ADDRREG1  union header  *q;


     /* Get A(alloc'd block's header) */
     p = hdraddr(ap);

     /*
          Look for the place in the free list where this block
          belongs.
     */
     for (q = _allocp ; (p < q) || (p >= next(q)) ; q = next(q))
          if ((q >= next(q)) && ((p >= q) || (p < next(q))))
               break;

     if (p != q)
     {
          /*
               If the block we're freeing is contiguous to the next
               block, join the two.  Otherwise, link the two
          */
          if (after(p) == next(q))
          {
               n_units(p) += n_units(next(q));
               next(p) = next(next(q));
          }
          else
               next(p) = next(q);

          /*
               If the block we're freeing is contiguous to the previous
               block, join the two.  Otherwise, link the two
          */
          if (after(q) == p)
          {
               n_units(q) += n_units(p);
               next(q) = next(p);
          }
          else
               next(q) = p;
     }

     /*
          Begin subsequent allocations with the block just freed
     */
     _allocp = q;
}
