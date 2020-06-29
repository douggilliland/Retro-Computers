
/*  Terminal Capability Structure Definition */

#define STRSIZE 192 /* Size of string area */

struct ttycap {
   char    c_rows;     /* Number of rows */
   char    c_cols;     /* Number of columns */
   char    c_inxy;     /* Invert x and y when positioning */
   char    c_wait;     /* Screen settling time */
   char    *c_home;    /* Home up */
   char    *c_up;      /* Cursor up */
   char    *c_down;    /* Cursor down */
   char    *c_left;    /* Cursor left */
   char    *c_right;   /* Cursor right */
   char    *c_clear;   /* Clear screen */
   char    *c_pos;     /* Position to x y */
   char    *c_init;    /* Initialize terminal */
   char    *c_blank;   /* Blank to end of current line */
   char    *c_backg;   /* Set background mode */
   char    *c_foreg;   /* Set foreground mode */
   char    *c_darrow;  /* Down arrow key */
   char    *c_uarrow;  /* Up arrow key */
   char    *c_larrow;  /* Left arrow key */
   char    *c_rarrow;  /* Right arrow key */
   char    *c_hmkey;   /* Home key */
   char    *c_fn0;     /* Function key 0 */
   char    *c_fn1;     /* Function key 1 */
   char    *c_fn2;     /* Function key 2 */
   char    *c_fn3;     /* Function key 3 */
   char    *c_fn4;     /* Function key 4 */
   char    *c_fn5;     /* Function key 5 */
   char    *c_fn6;     /* Function key 6 */
   char    *c_fn7;     /* Function key 7 */
   char    *c_fn8;     /* Function key 8 */
   char    *c_fn9;     /* Function key 9 */
   char    *unused[4]; /* Spares */
   char    c_caps[STRSIZE];/* Capability strings */
} ;

#define HOME_KEY -1
#define UP_KEY -2
#define DOWN_KEY -3
#define LEFT_KEY -4
#define RIGHT_KEY -5
#define KEY(WHICH) (-10-WHICH)
#define NO_DATA -100
