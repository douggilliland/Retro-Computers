/*******************************************************************/
/*                                                                 */
/*                  Managed Table Routines                         */
/*                                                                 */
/*******************************************************************/

#include  <ctype.h>
#include "tbdef.h"
#include "boolean.h"

#define INCREMENT 128  /* Default increment */
#define START_SIZE 256 /* Default starting table space size */
#define NULL 0 /* null pointer */

static BOOLEAN allocated;  /* true if allocation routine called */
static BOOLEAN preset;     /* true if user specified bounds */
static TABLE last_table;   /* end of table list */
static TABLE first_table;  /* start of table list */
static char *mem_begin;    /* start of memory */
static char *mem_end;      /* end of memory */


BOOLEAN add_data(tb,d,n)  /*  add data to managed table  */
TABLE tb;
register char *d;
register unsigned n;

{
   register char *p;
   char *get_space();
   BOOLEAN adjustment = FALSE;   /* TRUE if source data may move */
   register TABLE tabptr;        /* scratch table pointer */
   int tab_offset;      /* offset of data in table */

   if(allocated && d >= tb->fwad && d <= mem_end) {  /* if data may move */
      tabptr = tb; /* initialize loop control */
      while(tabptr != NULL) { /* determine where data is located */
         if(d >= tabptr->fwad && d < tabptr->lwad) {   /* found data loc */
            tab_offset = d - tabptr->fwad;   /* determine offset */
            adjustment = TRUE;   /* indicate adjustment may be necessary */
            break;
         }
         else
            tabptr = tabptr->next;
      }
   }
   if ( (p=get_space(tb,n)) == NULL) return FALSE;
   if(adjustment) d = tabptr->fwad + tab_offset; /* reset data address */
   while (n--) *p++ = *d++;
   return TRUE;
}

del_data(tb,item,size)  /*  remove data from table */
TABLE tb;
char *item;      /* address of item */
unsigned size;   /* size of item */

{
   if (item+size < tb->lwad)
       move(item+size,item,tb->lwad-item-size);
   tb->lwad -= size;
}

char *get_space(tb,amt)  /*  Allocate space in table */
TABLE tb;    /* pointer to table structure */
unsigned amt; /* amount of space required */

{
   char *p;
   register TABLE q;
   unsigned inc;
   char *new_end;
   char *sbrk();         /* request memory */

   if (last_table == NULL) return NULL; /* no tables defined */
   if (!allocated) {
       if (!preset) mem_end = mem_begin = sbrk(0);
       for (q=last_table; q != NULL; q=q->prev)
           q->ptr1=q->ptr2=q->fwad=q->lwad=q->lwas=mem_begin;
       allocated = TRUE;
   }
   if (tb->lwad+amt > tb->lwas) {
       inc = (amt > tb->incr)? amt : tb->incr;
       inc = (inc + 1) & (~1);     /* force even */
       new_end = last_table->lwas+inc;
       if (new_end > mem_end) {
           if (preset) return NULL;
           if(brk(new_end) == 0) mem_end = new_end;
           else {
#ifndef M68000
               if( ((int)mem_end & 0xF000) == 0xE000 &&
                   ((int)(&inc) & 0xF000) == 0xF000 &&
                   ((int)new_end & 0xFF00) < 0xF800) mem_end = (char *)0xF800;
               else return NULL;
#else
               return NULL;
#endif
           }
       }
       for (q=last_table; q != tb; tbmov(q,inc),q=q->prev);
       tb->lwas += inc;
   }
   p=tb->lwad;
   tb->lwad += amt;
   return p;
}

struct table *new_table(increment)  /* define new table */
unsigned increment;

{
   register TABLE p;
   char *malloc();

   if (allocated ||
       ((p = (TABLE)malloc(sizeof(struct table))) == NULL) )
       return NULL;
   p->fwad = p->lwad = p->lwas = p->ptr1 = p->ptr2 = NULL;
   p->incr = (increment == 0) ? INCREMENT : increment;
   p->incr = (p->incr + 1) & (~1); /* force even */
   p->prev = last_table;
   p->next = NULL;
   if (first_table == NULL) first_table = p;
   else last_table->next = p;
   return (last_table = p);
}

tbgbc(reduce)    /* Garbage collect tables */
int  reduce;

/*   If "reduce" is non-zero, drop memory end to end of last table. */

{    register TABLE p;

     p = first_table;
     while ( p != NULL ) {
          p->lwas = p->lwad;
          if ( p->next != NULL )
               tbmov(p->next,p->lwas - p->next->fwad);
          p = p->next;
     }
     if(last_table != NULL && reduce != 0) {
          sbrk(last_table->lwas - mem_end);
          mem_begin = mem_end = sbrk(0);
     }
}

static tbmov(tb,amt)  /* move table */
register TABLE tb;
register int amt;

{
   move(tb->fwad,tb->fwad+amt,tb->lwad-tb->fwad);
   tb->fwad += amt;
   tb->lwad += amt;
   tb->lwas += amt;
   tb->ptr1 += amt;
   tb->ptr2 += amt;
}

tbrdi(tb,addr,size)
TABLE     tb;  /* table from which to remove */
char*     addr;     /* address of data to be removed */
int       size;     /* size of data to be removed */

{    if (size <= 0) return;   /* if nothing to remove */
     if (tb->lwad == addr+size) {  /* if the last item in the table */
          tb->lwad = addr;  /* truncate table */
          return;
     }
     move(addr+size,addr,tb->lwad - (addr+size));  /* move data down */
     tb->lwad -= size;   /* set new table end */
}

set_limits(b,e)   /*  set limits on table space  */
char *b;
char *e;

{
   if (e < b) e=b;
   mem_begin = b;
   mem_end = e;
   preset = TRUE;
}
#ifdef DEBUG
print_table(tb,f)
TABLE tb;
int   f;       /* If non-zero, print table contents */
{
     printf("Table address: %4x\n",tb);
     printf("Data start:    %4x\n",tb->fwad);
     printf("Data end:      %4x\n",tb->lwad);
     printf("Pointer 1:     %4x\n",tb->ptr1);
     printf("Pointer 2:     %4x\n",tb->ptr2);
     printf("Storage end:   %4x\n",tb->lwas);
     printf("Increment:     %d\n",tb->incr);
     printf("Prev table:    %4x\n",tb->prev);
     printf("Next table:    %4x\n",tb->next);
     if (f != 0) {
          if (tb->fwad == tb->lwad) printf("Table is empty.\n");
          else {
               char *cp, *cp1, ch;
               int  cnt, i;
               for (cp = tb->fwad; cp < tb->lwad; ) {
                    cp1 = cp;
                    if ( (cnt=tb->lwad-cp) > 16) cnt = 16;
                    for (i=0; i<cnt; i++) printf("%2x ",(int)(*cp++)&0xff);
                    while ( i < 16) {
                         printf("   ");
                         i++;
                    }
                    for (i=0; i<cnt; i++) {
                         ch = *cp1 & 0x7F;
                         printf("%c", isprint(ch)? ch: '.');
                         cp1++;
                    }
                    printf("\n");
               }
          }
     }
}
all_tables(f)
int  f;        /* if printing data */
{    TABLE     p;

     p=first_table;
     while (p != NULL) {
          print_table(p,f);
          p = p->next;
     }
}
#endif
