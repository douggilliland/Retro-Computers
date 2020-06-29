#include <stdio.h>
#include "boolean.h"
 
int  *current;
int  nrows, ncols;

main()

{
   int  *next;
   int  size;
   int  i, j;
   char ch;
   int  c;
   int  value;
   int  where;
   int  spot;
   BOOLEAN change;
   BOOLEAN done;
   int  generation;
   int  cell_count;
   int  max_cells;
   int  numb_spot;
   int  count_spot;
   int  max_spot;
   char numb_buf[10];
   extern int last_row, last_column, row, column;

   if ( !terminit() ) {
      printf("Cannot initialize terminal.\n");
      exit(255);
   }
   nrows = last_row+1;
   ncols = last_column+1;
   size = nrows*ncols;
   if ( (current=(int)alloc(size*sizeof(int))) == NULL ||
        (next=(int)alloc(size*sizeof(int))) == NULL ) {
      printf("Cannot get memory.\n");
      exit(255);
   }
   for ( i=0; i < size; i++) *(current+i) = 0;
   set_raw(0);
   command_line(0);
   s_output("Enter starting pattern.");
   move_to(last_column/2,last_row/2);
   while ( (c=input(TRUE,FALSE)) != 0x03) {
      if ( c > 0 ) {
         if (c==(int)' ') {
            ch = ' ';
            value = 0;
         }
         else {
            ch = '*';
            value = 1;
         }
         *(current+row*ncols+column)=value;
         c_output(ch);
      }
      else cursor(c);
   }
   command_line(0);
   blank_line();
   s_output("Generation: ");
   numb_spot=column;
   c_output('0');
   done = FALSE;
   max_cells = 0;
   while ( !done && (c=input(FALSE,FALSE)) != 0x03) {
      cell_count = 0;
      for (i=0; i<nrows; i++) {
         where = i*ncols;
         for (j=0; j<ncols; j++) {
            spot=where+j;
            switch (*(current+spot)) {
            case 0:
               *(next+spot) = (ncount(j,i)==3)? 1: 0;
               break;
            case 1:
               *(next+spot)=((value=ncount(j,i))==2 ||
                  value==3)? 1: 0;
               break;
            }
         cell_count += *(next+spot);
         }
      }
      change=FALSE;
      for (i=0; i<nrows; i++) {
         where = i*ncols;
         for (j=0; j<ncols; j++) {
            spot=where+j;
            if (*(next+spot)!=*(current+spot)) {
               *(current+spot)=*(next+spot);
               change=TRUE;
               move_to(j,i);
               c_output( (*(next+spot)==0)? ' ': '*');
            }
         }
      }
      sprintf(numb_buf,"%d",++generation);
      command_line(numb_spot);
      blank_line();
      s_output(numb_buf);
      done = !change || cell_count==0;
      }
   clear_raw(0);
}

int ncount(x,y)
int x, y;

{
   int c;
   int where;
   extern int last_column, last_row;

   c = 0;
   if (y > 0) {
      where = ncols*(y-1);
      if (x > 0) c += *(current+where+x-1);
      if (x < last_column) c += *(current+where+x+1);
      c += *(current+where+x);
   }
   where = ncols*y;
   if (x > 0) c += *(current+where+x-1);
   if (x < ncols-1) c += *(current+where+x+1);
   if (y < last_row) {
      where = ncols*(y+1);
      if (x > 0) c += *(current+where+x-1);
      if (x < last_column) c += *(current+where+x+1);
      c += *(current+where+x);
   }
   return c;
}
