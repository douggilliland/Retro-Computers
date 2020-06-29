/*
* This file contains the definitions for tokens.
*/

#define SMC 1   /* ; */
#define LCB 2   /* { */
#define RCB 3   /* } */
#define LSB 4   /* [ */
#define RSB 5   /* ] */
#define LPR 6   /* ( */
#define RPR 7   /* ) */
#define COL 8   /* : */
#define SQU 9   /* ' */
#define DQU 10  /* " */
#define BKS 11  /* \ */
#define QUM 12  /* ? */
#define ARO 13  /* -> */
#define KEY 14  /* keyword */
#define VAR 15  /* variable */
#define CON 16  /* constant */
#define CHC 17  /* character constant */
#define STC 18  /* string constant */
#define BAD 127 /* no token */


/* miscellaneous definitions */

#define FALSE 0
#define TRUE 1

/* token table structure */

struct toktab {
  char ch;
  char tok;
};

