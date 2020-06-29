/*******************************************************************/
/*                                                                 */
/*             Managed Table Structure Definitions.                */
/*                                                                 */
/*******************************************************************/

struct table {   /* Managed Table control block */
   char *fwad;
   char *lwad;
   char *ptr1;
   char *ptr2;
   char *lwas;
   unsigned  incr;
   struct table *prev;
   struct table *next;
};

typedef struct table *TABLE;
