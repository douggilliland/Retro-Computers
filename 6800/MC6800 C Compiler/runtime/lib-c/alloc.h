/*
     alloc.h - Definitions for memory allocation routines

          malloc() - Allocate a block of memory from the
                     available arena

          calloc() - Allocate a block of memory from the
                     available arena (different method of
                     specifying the size of memory needed)

          realloc() - Reallocate a block of memory

          free() - Free an allocated block of memory
*/

#ifndef    NULL
#define    NULL    0       /* null pointer */
#endif

/*
     Minimum number of units to allocate from main memory
*/
#define NALLOC     (_PAGESIZ/sizeof(union header))

typedef int ALIGN;         /* alignment for 68000 */

static union header {      /* free block header */
   struct {
       union header *ptr;  /* next free block */
       unsigned size;      /* size of this free block */
   } s;
   ALIGN x;                /* force alignment of blocks */
};


#define next(x)    ((x)->s.ptr)
#define after(x)   ((x)+(x)->s.size)
#define n_units(x) ((x)->s.size)
#define bufaddr(x) ((x)?(char*)(((union header *)(x))+1):(char*)(x))
#define hdraddr(x) ((x)?(((union header *)(x))-1):(union header *)(x))
