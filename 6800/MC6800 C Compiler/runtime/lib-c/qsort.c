/****************************************************************/

#include  "machine.h"
#define MAX_ELEM 256

static /*void*/ qsortx();
static /*void*/ cpy_elem();

int qsort(base, nel, width, compar)
  char         *base;         /* Address of first element */
  unsigned int  nel;          /* Number of elements */
  unsigned int  width;        /* Width of each element */
  int         (*compar)();    /* Element comparison routine */
{
  char temp_elem[MAX_ELEM];
  REGISTER int  rtnval;       /* Value to return */

  if (width <= MAX_ELEM) {
    qsortx(base, base+((nel-1)*width), width, compar, temp_elem);
    rtnval = 0;
  } else rtnval = -1;
  return(rtnval);
}

static /*void*/ qsortx(left, right, width, compar, median)
               char          *left;
               char          *right;
     REGISTER  unsigned int   width;
               int          (*compar)();
     REGISTER  char          *median;
{
     register  char          *l;
     REGISTER  char          *r;
     REGISTER  char          *medpos;

  if (left != right)
  {
    l = left;  r = right;  cpy_elem(median, right, width);
    while (l < r)
    {
      while ((*compar)(l, median) < 0) l += width;
      if (l < r)
      {
        cpy_elem(r, l, width);  cpy_elem(l, median, width);  r -= width;
        while ((*compar)(median, r) < 0) r -= width;
        if (l < r)
        {
          cpy_elem(l, r, width); cpy_elem(r, median, width); l += width;
        }
      }
    }
    medpos = l;
    if (left < (medpos-width))
      qsortx(left, medpos-width, width, compar, median);
    if ((medpos+width) < right)
      qsortx(medpos+width, right, width, compar, median);
  }
}

static /*void*/ cpy_elem(dest, src, width)
     register  char          *dest;
     REGISTER  char          *src;
     REGISTER  unsigned int   width;
{
  while(width--)
    *dest++ = *src++;
}
