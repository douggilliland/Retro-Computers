/*
     char *malloc(n)
          unsigned  n;

          malloc() allocates <n> bytes from the
          free memory pool and returns the address
          of the allocated memory or NULL if none
          is available.  The memory allocates is
          suitable aligned for any use.

     Arguments:
          n         Number of bytes to allocate

     Returns:  char *
          The address of the allocated memory if any,
          or NULL if none is available

     Revision History:
          06/12/84 kpm - From UniFLEX alloc()
*/

/*
     Memory allocation definitions
*/
#include  "machine.h"
#include  "alloc.h"

/*
     External variables referenced
*/
     extern    union header  *_allocp;
     extern    union header   _base;
     extern    int            __msz;



char *malloc(nbytes)
     unsigned  nbytes;
{
               union header  *morecore();
     ADDRREG0  union header  *p;
     ADDRREG1  union header  *q;
     DATAREG0  int            nu;

     /*
          Initialize the free-list if it has not yet
          been initialized
     */
     nu = 1 + (nbytes + sizeof(union header)-1) / sizeof(union header);
     if ((q = _allocp) == NULL)   /* no free list yet */
     {
          _base.s.ptr = _allocp = q = &_base;
          _base.s.size = 0;
     }

     /*
          Circle through the free-list, looking for the
          first fit for the requested memory
     */
     for (p = next(q) ; ; q = p , p = next(p))
     {
          /* Check for a fit */
          if (n_units(p) >= nu)
          {
               /*  Check for an exact fit */
               if(n_units(p) == nu)

                    /* Exact fit -- Remove block */
                    next(q) = next(p);

               else
               {
                    /* Allocate from end of block */
                    n_units(p) -= nu;
                    p = after(p);
                    n_units(p) = nu;
               }

               /* Begin next look from where we left off */
               _allocp = q;

               /* Return pointer to block found */
               return (bufaddr(p));

          }

          /*
               If wrapped around free list, allocate more memory
               to the free-memory arena
          */
          if (p == _allocp)
               if ((p = morecore(nu)) == NULL)
                    return(NULL);
     }
}

/*   Local routine

     static union header *morecore(nu)
          unsigned  nu;

          Allocate atleast <nu> units of memory (a unit being
          sizeof(union header) bytes) and add that memory
          to the free list so memory can be allocated from
          it.  It always allocates atleast NALLOC blocks
          and adds to that enough blocks to reach the bottom
          of the page.  It will not allocate a partial unit
          from the bottom of the page -- that will be allocated
          by the next "malloc()" call.  (Avoids a hole at the
          bottom of the page.)

     Arguments:
          nu        Number of "units" to allocate.  A "unit"
                    is sizeof(union header) bytes

     Returns:  union header *
          Address of the allocated memory, or NULL if none

     Routine History:
          06/12/84 kpm - From UniFLEX alloc()
*/

static union header *morecore(nu)
     DATAREG1  unsigned       nu;
{
               char          *sbrk();
     ADDRREG1  char          *cp;
     ADDRREG0  union header  *up;
     DATAREG0  int            rnu;
     DATAREG2  int            bksz;

               void           free();

     if ((rnu = ((unsigned int) sbrk(0)) & _PGOFSTM) != 0)
          rnu = (_PAGESIZ - rnu) / sizeof(union header);
     bksz = __msz / sizeof(union header);
     if (rnu < nu) rnu += bksz * ((nu+(bksz-1)) / bksz);
     cp = sbrk(rnu * sizeof(union header));
     if (cp == ((char *) -1))
          return(NULL);
     up = (union header *)cp;
     n_units(up) = rnu;
     free(bufaddr(up));
     return(_allocp);
}
