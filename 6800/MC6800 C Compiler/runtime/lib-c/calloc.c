/*
     char *calloc(num, size)
          unsigned  num;
          unsigned  size;

          calloc() allocates a block of memory, num*size bytes,
          from the pool of available memory and returns the
          address of the allocated block.  If unsuccessful,
          it returns NULL

          The boundary alignment of the allocated block of memory
          makes it suitable for any purpose.

     Arguments:
          num       Number of elements to allocate
          size      Size of an element

     Notes:
        - The allocated block of memory may be freed using free().

     Routine History:
          06/07/84 kpm - New

*/

/*
     Allocation definitions
*/
#include  "machine.h"
#include  "alloc.h"


/*
     External variables referenced
*/
     extern    union header  *_allocp;


char *calloc(num,size)
     unsigned  num;
     unsigned  size;
{
               char     *malloc();
     ADDRREG0  char     *p;
     DATAREG0  unsigned  i;

     /* Allocate memory from the free-memory pool */
     if ((p = malloc(i = num * size)) != NULL)
     {
          /* Clear the allocated block of memory */
          p += i;
          do
               *--p = 0;
          while(--i);
     }
     return(p);
}
