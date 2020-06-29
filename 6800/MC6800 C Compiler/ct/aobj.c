#include "aliens.h"

/*
/* global variables   all defined in aliens.c
*/
extern  int vs_cols;
extern  int scores,bases,game;
extern  int danger,max_danger;
extern  int flip,flop,left,al_num,b;
extern  int al_cnt,bmb_cnt;

extern  char *barrin1;
extern  char *barrin2;
extern  char *barrin3;
extern  char *barrin4;

extern  char barr1[80];
extern  char barr2[80];
extern  char barr3[80];
extern  char barr4[80];

extern  int al_row[55];
extern  int al_col[55];

extern  int bmb_row[BOMB_MAX];
extern  int bmb_col[BOMB_MAX];

extern  int shp_vel;
extern  int shp_val;
extern  int shp_col;

extern  int bas_row;
extern  int bas_col;
extern  int bas_vel;

extern  int bem_row;
extern  int bem_col;

/*
/* base -- move the laser base left or right
*/
base()
        {
        bas_col += bas_vel;
        if (bas_col<1)   bas_col = 1;
        else if (bas_col>72)   bas_col = 72;
        pos(bas_row,bas_col);
        ds_obj(7);
        }

/*
/* beam -- activate or advance the laser beam if required
*/
beam()
        {
        int i,j;
        /*
         * display beam
         */
        switch (bem_row) {
                case 0:         return;
                case 21:        pos(21,bem_col);
                        putchar('|');
                        break;
                case 22:bem_col = bas_col + 3;
                        pos(22,bem_col);
                        putchar('|');
                        break;
                default:        pos(bem_row,bem_col);
                        printf("|\010\012\012 ");
                        break;
        }
        /*
         * check for contact with an alien
         */
        for (i=0;i<55;i++) {
                if ((al_row[i]==bem_row)&&((al_col[i]+1)<=bem_col)
                        &&((al_col[i]+3)>=bem_col)) {
                        /*
                         * contact!
                         */
                        scores = scores + (i/22) + 1;   /* add points */
                        pos(0,9);
                        printf("%-d",scores);
                        pos(bem_row+1,bem_col);
                        putchar(' ');
                        pos(al_row[i],al_col[i]);
                        ds_obj(6);      /* erase beam and alien */
                        bem_row=0;
                        al_row[i]=0;    /* clear beam and alien state */
                        al_cnt--;
                        return;
                }
        }
        /*
         * check for contact with a bomb
         */
        for (i=0;i<BOMB_CNT;i++) {
                if ((bem_row==bmb_row[i])&&(bem_col==bmb_col[i])) {
                        pos(bem_row,bem_col);
                        printf(" \010\012 ");
                        bem_row = 0;
                        bmb_cnt--;
                        bmb_row[i] = 0;
                        return;
                }
        }
        /*
         * check for contact with a barricade
         */
        if ((bem_row>=19)&&(bem_row<=22)
         &&(barrx(bem_row-19,bem_col)!=' ')) {
                pos(bem_row,bem_col);
                printf(" \010\012 ");
                barrxp(bem_row-19,bem_col,' ');
                bem_row = 0;
                return;
        }
        /*
         * check for contact with a mystery ship
         */
        if ((shp_vel!=0)&&(bem_row==1)
                &&(bem_col>(i=shp_col-shp_vel))&&(bem_col<i+7)) {
                /*
                 * contact!
                 */
                pos(1,i);
                printf("        ");  /* erase ship */
                shp_vel = 0;
                scores += shp_val/3;
                pos(0,9);
                printf("%-d",scores);
        }
        /*
         * update beam position
         */
        if ((--bem_row)==0) {
                pos(1,bem_col);
                putchar(' ');
                pos(2,bem_col);
                putchar(' ');
        }
        return;
}

/*
/* bomb -- advance the next active bomb
*/
bomb() {
        int i,j;
        if (bmb_cnt==0)   return;
        while (1) {
                if (++b >= BOMB_CNT)  b = 0;
                if (bmb_row[b]!=0)   break;
        }
        /*
         * now advance the bomb, check for hit, and display
         */
        bmb_row[b]++;
        if (bmb_row[b]==23) {
                if ((bmb_col[b] > bas_col)&&(bmb_col[b]<= (bas_col+5) ) ) {
                        /*
                         * the base is hit!
                         */
                        bases--;
                        pos(0,70);
                        printf("Lasers: %d",bases);
                        /*
                         * make heart-rending noise
                         */
                        for (i=0;i<10;i++) {
                                printf("\7\1\1\1\1\1\1\1\1\1\1");
                                printf("\7\1\1\1\1\1\1\1\1\1\1");
                                printf("\7\1\1\1\1\1\1\1\1\1\1");
                                printf("\7\1\1\1\1\1\1\1\1\1\1");
                                printf("\7\1\1\1\1\1\1\1\1\1\1");
                                printf("\7\1\1\1\1\1\1\1\1\1\1");
                                printf("\7\1\1\1\1\1\1\1\1\1\1");
                                printf("\7\1\1\1\1\1\1\1\1\1\1");
                                printf("\7\1\1\1\1\1\1\1\1\1\1");
                                printf("\7\1\1\1\1\1\1\1\1\1\1");
                                printf("\7\1\1\1\1\1\1\1\1\1\1");
                        }
                        if (bases==0) {
                                /*
                                 * game over
                                 */
                                over();
                        }
                        sleep(2);
                        pos(23,bas_col);
                        printf("       ");
                        bas_col = 72;
                }
        }
        if((bmb_row[b]>=19)&&(bmb_row[b]<23)
        &&(barrx(bmb_row[b]-19,bmb_col[b])!=' ')) {
                /*
                 * the bomb has hit a barricade
                 */
                pos(bmb_row[b]-1,bmb_col[b]);
                printf(" \010\012*\010 ");
                barrxp(bmb_row[b]-19,bmb_col[b],' ');
                bmb_row[b] = 0;
                bmb_cnt--;
                return;
        }
        pos(bmb_row[b],bmb_col[b]);
        putchar('*');
        pos(bmb_row[b]-1,bmb_col[b]);
        putchar(' ');
        if (bmb_row[b]==23) {
                bmb_cnt--;
                pos(bmb_row[b],bmb_col[b]);
                putchar(' ');
                bmb_row[b] = 0;
        }
        return;
}
/*
/* ship -- create or advance a mystery ship if desired
*/
ship() {
        int i;
        if (shp_vel==0) {
                if (i) {
/*                      if ((i=rand())<32) {                    */
                        /*
                         * create a mystery ship
                         * this occurs about once every minute
                         */
                        if (i<16) {
                                shp_vel = -1;
                                shp_col = vs_cols - 8;
                        }
                        else {
                                shp_vel = 1;
                                shp_col = MINCOL;
                        }
                        shp_val = 90;
                }
        }
        else {
                /*
                 * update an existing mystery ship
                 */
                pos(1,shp_col);
                if (game!=4)
                        printf(" <=%2d=> ",shp_val);
                shp_val--;
                shp_col += shp_vel;
                if (((i=shp_col)>(vs_cols-8))||(i<MINCOL))   {
                        /*
                         * remove the mystery ship
                         */
                        pos(1,shp_col-shp_vel);
                        printf("        ");
                        shp_vel = 0;
                }
        }
}

/*
/* alien -- advance the next alien
*/
alien()
{
        int i,j;
        while (1)
        {
                if (++al_num >= 55)
                {
                        if (al_cnt==0)   return; /* check if done */
                        flop = 0;
                        if (flip) { left = (left+1) % 2;
                                flop = 1;
                        }
                        flip = 0;
                        al_num = 0;
                }
                if ((i = al_row[al_num])>0)   break;
        }
        if (i>=23)
        {

                /* game over, aliens have overrun base */
                over();
        }

        if (left)   al_col[al_num]--;
        else   al_col[al_num]++;
        if (((j = al_col[al_num])==0)||(j==75))   flip = 1;
        pos(i,j);
        if (flop) {
                ds_obj(6);
                i = ++al_row[al_num];
                pos(i,j);
        }
        ds_obj(((j+(i/2))&1) + (2*(al_num/22)));
        /*
         * check for bomb release
         */
        if ((game==1)||(game==2))   return;     /* disable bombs */
        for (i=al_num-11;i>=0;i -= 11) {
                if (al_row[i]!=0)   return;
        }
        if ((al_col[al_num]>=bas_col)&&
        (al_col[al_num]<(bas_col+3))&&
           (al_row[al_num]<=BOMB_MAX)) {
                for (i=0;i<BOMB_CNT;i++) {
                        if (bmb_row[i]==0) {
                                bmb_row[i] = al_row[al_num];
                                bmb_col[i] = al_col[al_num] + 2;
                                bmb_cnt++;
                                break;
                        }
                }
        }
        return;
}
