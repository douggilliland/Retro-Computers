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

  xxxxx(up);
}
