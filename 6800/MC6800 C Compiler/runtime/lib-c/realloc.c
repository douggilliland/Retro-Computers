/*
     char *realloc(orig_buf, req_size)
          char     *orig_buf;
          unsigned  req_size;

          This function changes the size of the buffer
          referenced by <orig_buf> to <req_size> bytes
          and returns a pointer to the possibly moved
          buffer.

          If the buffer is being shrunk, the excess memory
          is returned to the free pool.

          If the buffer is being enlarged, the current buffer
          is freed then another is allocated with the data
          copied from the old buffer to the new buffer.
          [Relies on free() not changing the buffer's data.]

     Arguments:
          orig_buf:  A(buffer to reallocate)
          req_size:  # bytes to allocate to the buffer

     Returns:  char *
          A(possibly moved buffer) or NULL if failed

     Notes:
        - If NULL is returned, the original block may be
          destroyed.

     Revision History:
          06/08/84 kpm - New

*/

/*
     Allocation definitions
*/
#include  "machine.h"
#include  "alloc.h"
#include  <memory.h>

/*
   External variables referenced
*/
     extern    union header  *_allocp;
     extern    union header   _base;



char *realloc(orig_buf, req_size)
     ADDRREG5  char     *orig_buf;
     DATAREG1  unsigned  req_size;
{
     ADDRREG0  union header  *orig_blk;
     ADDRREG1  union header  *r;
     ADDRREG2  union header  *t;
     ADDRREG3  union header  *q;
     ADDRREG4  char          *new_buf;
     DATAREG0  unsigned       req_nu;
     DATAREG2  unsigned       j;
     DATAREG3  unsigned       orig_nu;

     /*
        Calculate the number of units we need and
        the address of the block being reallocated
     */
     req_nu = 1 +
         ((req_size + (sizeof(union header)-1)) / 
          sizeof(union header));
     orig_blk = hdraddr(orig_buf);

     /*
        If we're not making the block bigger,
        free the units not needed and return the
        address of the original buffer
     */
     if (req_nu <= (orig_nu = n_units(orig_blk)))
     {
        /* Not making the block any bigger */
        if (req_nu < orig_nu)
        {
           /* Making the block smaller */
           j = orig_nu - req_nu;
           n_units(orig_blk) = req_nu;
           n_units(after(orig_blk)) = j;
           free(bufaddr(after(orig_blk)));
        }
        return(orig_buf);
     }


     /*
        Making the block bigger
     */

     /*
        Find the free block, if any, that is closest to but
        after the block being reallocated (t) and the free
        block that is closest to but before the block being
        reallocated (r)
     */
     r = &_base;
     t = next(r);
     while((t != &_base) && (t < orig_blk))
     {
        q = r;
        r = t;
        t = next(t);
     }

     /*
        Merge the next block with the realloc block
        if they are contiguous
     */
     if ((t != &_base) && (t == after(orig_blk)))
     {
        /*
           Remove the free block following the realloc block
           from the free list, combining it with the realloc
           block.  Be sure to change the free-list head if
           it points to the free block being combined.
        */
        if (_allocp == t) _allocp = next(t);
        next(r) = next(t);
        /*
           If the newly enlarged block is large enough,
           use it
        */
        if ((n_units(orig_blk) += n_units(t)) >= req_nu)
        {
           if (n_units(orig_blk) > req_nu)
           {
              n_units(orig_blk+req_nu) = n_units(orig_blk) - req_nu;
              n_units(orig_blk) = req_nu;
              free(bufaddr(after(orig_blk)));
           }
           return(orig_buf);
        }
     }

     /*
        If the preceeding block is contiguous with the block
        being reallocated, merge the two blocks
     */
     if ((r != &_base) && (after(r) == orig_blk))
     {
        /*
           Combine the preceeding free block with the block
           being reallocated.  Be sure to change the free
           list head if it references the block being combined
           with the realloc block.
        */
        if (_allocp == r) _allocp = next(r);
        next(q) = next(r);

        /*
           If the newly enlarged block is large enough,
           use it
        */
        if ((n_units(r) += n_units(orig_blk)) >= req_nu)
        {
           if (n_units(r) > req_nu)
           {
              n_units(r) -= req_nu;
              n_units(after(r)) = req_nu;
              free(bufaddr(r));    /* No combining possible */
              r = after(r);        /* so after(r) still ok  */
           }
           memcpy(bufaddr(r), orig_buf,
                  (orig_nu-1)*sizeof(union header));
           return(bufaddr(r));
        }
     }
     else
          r = orig_blk;

     /*
          Not enough room for the reallocation, even after
          combining buffer with adjacent blocks of
          free space (if any).  Must allocate space from
          main memory to perform the reallocation.

          Note that this algorithm works only because we
          know that the current block (pointed to by "r")
          is not contiguous to any free block, and that it
          is not large enough for the requested bytesize,
          so the data in the block will not be changed
          by malloc().  "orig_blk" points to the original block
     */

     j = (orig_nu-1) * sizeof(union header);
     free(bufaddr(r));
     if ((new_buf = malloc(req_size)) == NULL)
          return(NULL);

     /*
          Copy the bytes if necessary (may have allocated space
          off of the end of the original block.  If so, no need
          to copy the bytes
     */
     if (orig_blk != hdraddr(new_buf)) 
          memcpy(new_buf, bufaddr(orig_blk), j);
     return(new_buf);
}
