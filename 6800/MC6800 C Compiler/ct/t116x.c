main(argc, argv)   /* sort input lines */
int argc;
char *argv[];
{
   char *lineptr[100];
   int nlines;
   int strcmp(), numcmp();
   int swap();
   int numeric; /* = 0 */

   if (argc>1 && argv[1][0] == '-' && argv[1][1] == 'n')
      numeric = 1;
   if ((nlines = readlines(lineptr, 100)) >= 0) {
      if (numeric)
         sort(lineptr, nlines, numcmp, swap);
      else
         sort(lineptr, nlines, strcmp, swap);
      writelines(lineptr, nlines);
   } else
      printf("input too big to sort\n");
}

sort(v, n, comp, exch)   /* sort strings v[0]...v[n-1] */
char *v[];               /* into increasing order */
int n;
int (*comp) (), (*exch) ();
{
   int gap, i, j;

   for (gap = n/2; gap > 0; gap /= 2)
      for (i = gap; i < n; i++)
         for (j = i-gap; j>= 0; j -= gap) {
            if ((*comp) (v[j], v[j+gap]) <= 0)
               break;
            (*exch) (&v[j], &v[j+gap]);
         }
}

swap(px, py)  /* interchange *px and *py */
char *px[], *py[];
{
   char *temp;

   temp = *px;
   *px = *py;
   *py = temp;
}
