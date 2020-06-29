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
  int *a;
  register HEADER *up;
  char *p;
  HEADER array[100];

  a = ((HEADER *)p) + 1;
  a = up+1;
  a = ((char *)up) + 1;
  a = &array[10] + 1;
}
