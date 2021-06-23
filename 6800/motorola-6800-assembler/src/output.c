

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "output.h"

/*
 *  stable --- prints the symbol table in alphabetical order
 */
void stable(struct nlist *ptr)
{
  if (ptr != NULL)
    {
      stable (ptr->Lnext);
        printf ("%-10s %04x\n",ptr->name,ptr->def);
      stable (ptr->Rnext);
    }
}
/*
 *  cross  --  prints the cross reference table 
 */
void cross(struct nlist *point)
{
struct link *tp;
int i = 1;
  if (point != NULL)
    {
      cross (point->Lnext);
        printf ("%-10s %04x *",point->name,point->def);
         tp = point->L_list;
          while (tp != NULL)
           {
             if (i++>10)
              {
               i=1;
               printf("\n                      ");
              }
              printf ("%04d ",tp->L_num);
               tp = tp->next;
           }
         printf ("\n");
      cross (point->Rnext);
    }
}
