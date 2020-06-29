/* malloc for pass1 only */

extern int end;

static unsigned mend = 0;

char *malloc(nbytes)
unsigned nbytes;
{
  unsigned temp;

  if (!mend)
    mend = &end + 1;
  if (brk(mend + nbytes))
    return(0);
  temp = mend;
  mend += nbytes;
  return(temp);
}
