/*
     fmtout.h - Definitions for formatted conversions

          These definitions describe the structure
          used to pass around information contained
          in a format description used to convert
          data from internal to external form
          [via fprintf(), sprintf(), printf(), etc.]
*/

struct ofmtdesc
{
     char     *fmtptr;        /* Ptr to fmt description */
     char     *ptr;           /* Ptr beyond fmt description */
     int       width;         /* Width field */
     int       precn;         /* Precision field */
     char      type;          /* Type of format */
     char      justify;       /* Reverse-justify flag */
     char      signed;        /* Signed-field flag */
     char      blsign;        /* Blank-leading-sign flag */
     char      alt;           /* Alternate-format flag */
     char      longflg;       /* Long-field flag */
     char      varwidth;      /* Width is variable */
     char      varprecn;      /* Precision is variable */
};
