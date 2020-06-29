/*
     fmtin.h - Definitions for formatted conversions

          These definitions describe the structure
          used to pass around information contained
          in a format description used to convert
          data from external to internal form
          [via fscanf(), sscanf(), scanf(), etc.]
*/

struct ifmtdesc
{
     char     *fmtptr;        /* Ptr to fmt description */
     char     *ptr;           /* Ptr beyond fmt description */
     char     *charbuf;       /* Ptr to matching char buffer */
     int       width;         /* Width field */
     char      type;          /* Type of format */
     char      noasgflg;      /* No-assignment flag */
     char      longflg;       /* Long-target flag */
     char      shortflg;      /* Short-target flag */
};
