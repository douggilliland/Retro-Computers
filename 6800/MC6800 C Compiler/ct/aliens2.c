/* Aliens -- an animated video game
/*      the original version is from
/*      Fall 1979                       Cambridge               Jude Miller

/* Score keeping modified and general terminal handling (termcap routines
/* from UCB's ex) added by Rob Coben, BTL, June, 1980.
/*
/* If MSG is defined, the program uses the inter-process message facility
/* of UNIX/TS Augmented to optimize reading the tty while updating the
/* screen. Otherwise, the child process (reading the tty) writes
/* a temporary communications file, which the parent (updating the screen)
/* is constantly seeking to the beginning of and re-reading. (UGH!)
/* If your system has a non-blocking read (read-without-wait), it should
/* be implemented, and the child process could be dispensed with entirely.
/*
/* extensively modified i/o for Purdue Unix by Phil Hochstetler 9/14/80
/*  Most printf's  replaced by "prints" and "printd" routines.
/* additional mods for use on a z80 board by  Phil Hochstetler 2/22/81
/*  Printf's reinstalled for z80 use..  2/26/81
*/

#include "aliens.h"
#include "getchar.c"
#include "putchar.c"

/*
/* global variables
*/
        int vs_cols = 80;
        int scores,bases,game;
        int danger,max_danger;
        int flip,flop,left,al_num,b;
        int al_cnt,bmb_cnt;
        char *barrin1 =
"         ########          ########          ########          ########";

        char *barrin2 =
"        ##########        ##########        ##########        ##########";

        char *barrin3 =
"        ###    ###        ###    ###        ###    ###        ###    ###";

        char *barrin4 =
"        ###    ###        ###    ###        ###    ###        ###    ###";

        char barr1[80];
        char barr2[80];
        char barr3[80];
        char barr4[80];

        int al_row[55];
        int al_col[55];

        int bmb_row[BOMB_MAX];
        int bmb_col[BOMB_MAX];

        int shp_vel;
        int shp_val;
        int shp_col;

        int bas_row;
        int bas_col;
        int bas_vel;

        int bem_row;
        int bem_col;

/*
 * over -- game over processing
 */
over() {
        int i;
        /*
         * display the aliens if they were invisible
         */
        if (game==4) {
                game = 3;       /* remove the cloak of invisibility */
                for (i=0;i<55;i++)   if (al_row[i] !=0) {
                        pos(al_row[i],al_col[i]);
                        ds_obj(((al_col[i]+(al_row[i]/2))&1) + (2*(i/22)));
                }
                game = 4;       /* be tidy */
        }
        pos(9,20);
        printf(" __________________________ ");
        pos(10,20);
        printf("|                          |");
        pos(11,20);
        printf("| G A M E   O V E R        |");
        pos(12,20);
        printf("|                          |");
        pos(13,20);
        printf("| Game type : %d            |",game);
        pos(14,20);
        printf("|  FINAL SCORE  %4d       |",scores);
        pos(15,20);
        printf("|__________________________|");
        leave();
}

/*
/* init -- does global initialization and spawns a child process to read
/*      the input terminal.
*/
init()
{
        /*
         * New game starts here
         */
        game = 0;
        instruct();
        while (!game) poll();
        scores = 0;
        bases = 3;
        danger = 11;
        max_danger = 22;
}

/*
/* tabl -- tableau draws the starting game tableau.
*/
tabl()
{
        int j,i;
        clr();
        pos(0,0);
        printf("Score:");
        pos(0,9);
        printf("%-d",scores);
        pos(0,18);
        printf("I N V A S I O N   O F   T H E   A L I E N S !");
        pos(0,70);
        printf("Lasers: %d",bases);
        /* initialize alien co-ords, display */

        al_cnt = 55;
        for (j=0;j<=4;j++)
        {
                pos(danger-(2*j),0);
                for (i=0;i<=10;i++)
                {
                        ds_obj(((i+j)&1)+(2*(j/2)));
                        putchar(' ');
                        al_row[(11*j)+i] = danger - (2*j);
                        al_col[(11*j)+i] = (6*i);
                }
        }
        if (danger<max_danger)   danger++;
        al_num = 54;
        flip = 0;
        flop = 0;
        left = 0;
        /*
         * initialize laser base position, velocity
         */
        bas_row = 23;
        bas_col = 72;
        bas_vel = 0;
        bem_row = 0;
        /*
         * initialize bomb arrays (row = 0 implies empty)
         */
        for (i=0;i<BOMB_CNT;i++)   bmb_row[i] = 0;
        b = 0;
        bmb_cnt = 0;
        /*
         * initialize barricades
         */
        for (j=0; j < 79; j++) {
                barr1[j]=' ';
                barr2[j]=' ';
                barr3[j]=' ';
                barr4[j]=' ';
        }
        barr1[79]=barr2[79]=barr3[79]=barr4[79]=0;


        pos(19,0);

        for(j=0;barrin1[j];j++)
                barr1[j] = barrin1[j];
        printf(barr1);

        pos(20,0);
        for(j=0;barrin2[j];j++)
                barr2[j] = barrin2[j];
        printf(barr2);

        pos(21,0);
        for(j=0;barrin3[j];j++)
                barr3[j] = barrin3[j];
        printf(barr3);

        pos(22,0);
        for(j=0;barrin4[j];j++)
                barr4[j] = barrin4[j];
        printf(barr4);


        /*
         * initialize mystery ships
         */
        return(shp_vel = 0);
}
/*
/* poll -- read characters sent by input subprocess and set global flags
*/
poll() {
        int cbuf;
        if (game==1) {
                if (bas_col<=1)   bas_vel = 1;
                if (bas_col>=72)  bas_vel = -1;
        }

        if (!chaready())
                return;

        cbuf=getchar();

        switch (cbuf&0177) {     /* do case char */
                case FIRE:      if (bem_row==0)   bem_row = 22;
                                return;
                case LLEFT:     ;
                case LEFT:      if (game==1)   return;
                                return(bas_vel = -1);
                case LRIGHT:    ;
                case RIGHT:     if (game==1)   return;
                                return(bas_vel = 1);
                case LHALT:     ;
                case HALT:      if (game==1)   return;
                                return(bas_vel = 0);
                case DELETE:
                case ABORT:
                case QUIT:      over();
                case GAME1:     if (game!=0)   return;
                                return(game = 1);
                case GAME2:     if (game!=0)   return;
                                return(game = 2);
                case GAME3:     if (game!=0)   return;
                                return(game = 3);
                case GAME4:     if (game!=0)   return;
                                return(game = 4);
        }
}

/*
/* main -- scheduler and main entry point for aliens
*/
main()
{
        noecho();
        init();
        nonl();
        while (1)
        {
                tabl();
                while (1)
                {
                        poll();
                        beam();
                        base();
                        bomb();
                        ship();
                        alien();
                        alien();
                        if (al_cnt==0)   break;
                }
        }
}
barrx(row,col)  /* Simulate a two dimensional index into an array */
int row,col;
{
        switch(row) {

                case 0: return(barr1[col]);
                case 1: return(barr2[col]);
                case 2: return(barr3[col]);
                case 3: return(barr4[col]);
        }
}
barrxp(row,col,val)  /* Simulate a two dimensional index into an array */
int row,col;
char val;
{
        switch(row) {

                case 0: return(barr1[col]=val);
                case 1: return(barr2[col]=val);
                case 2: return(barr3[col]=val);
                case 3: return(barr4[col]=val);
        }
}
