#define NULL 0

typedef int ALIGN;

union header {
  struct {
    union header *ptr;
    unsigned size;
  } s;
  ALIGN x;
};

typedef union header HEADER;

#define NALLOC 128

static HEADER *morecore(nu)
unsigned nu;
{
  char *sbrk();
  register char *cp;
  register HEADER *up;
  register int rnu;

  rnu = NALLOC * ((nu+NALLOC-1) / NALLOC);
  cp = sbrk(rnu * sizeof(HEADER));
  if ((int)cp == -1)
    return(NULL);
  up = (HEADER *)cp;
  up->s.size = rnu;
  free((char *)(up+1));
  return(allocp);
}
