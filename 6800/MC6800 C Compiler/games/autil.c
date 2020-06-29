#include "sgtty.h"

struct sgttyb mode;

#include "aliens.h"

extern int game;

/*
/* pos -- positions cursor to a display position.  Row 0 is top-of-screen
/*      row 23 is bottom-of-screen.  The leftmost column is 0; the rightmost
/*      is 79.
*/
pos(row,col)
int row,col;
{
        putchar(0x1b);
        putchar('[');
        aschar(row);
        putchar(';');
        aschar(col);
        putchar('H');
}

aschar(x) {

  x++;
  if (x>9) {
    putchar("0123456789"[x/10]);
    x %= 10;
  }
  putchar("0123456789"[x]);
}

/*
/* clr -- issues an escape sequence to clear the display
*/
clr()
{
        pos(0,0);
        printf("\033[2J");
        flush();
        sleep(3);
}
/*
/* ds_obj -- display an object
*/
ds_obj(class)
int class;
{

        if ((game==4)&&(class>=0)&&(class<=5))   class = 6;
        switch (class)
        {
                case 0: printf(" OXO ");
                        break;
                case 1: printf(" XOX ");
                        break;
                case 2: printf(" \\o/ ");
                        break;
                case 3: printf(" /o\\ ");
                        break;
                case 4: printf(" \"M\" ");
                        break;
                case 5: printf(" wMw ");
                        break;
                case 6: printf("     ");
                        break;
                case 7: printf(" xx|xx ");
        }
}
/*
 * instructions -- print out instructions
 */
instruct() {
        clr();
        pos(0,0);
        printf("Attention: Alien invasion in progress!\n\n");
        printf("        Type:   <,>     to move the laser base left\n");
        printf("                <z>     as above, for lefties\n");
        printf("                <.>     to halt the laser base\n");
        printf("                <x>     for lefties\n");
        printf("                </>     to move the laser base right\n");
        printf("                <c>     for lefties\n");
        printf("                <space> to fire a laser beam\n\n");
        printf("                <1>     to play Bloodbath\n");
        printf("                <2>     to play We come in peace\n");
        printf("                <3>     to play Invasion of the Aliens\n");
        printf("                <4>     to play Invisible Alien Weasels\n");
        printf("                <q>     to quit\n\n");
        flush();
        return;
}
/*
 * leave -- flush buffers,kill the Child, reset tty, and delete tempfile
 */
leave() {
        pos(23,0);
        nl();
        echo();
        flush();
        exit();
}
sleep(n) int n; {
        int i;
        while (n--)
                for (i=0; i < 10000; i++);
}

nonl(){
        gtty(0,&mode);
        mode.sg_flags &= ~CRMOD;
        mode.sg_flags |= CBREAK;
        stty(0,&mode);
}
nl(){
        gtty(0,&mode);
        mode.sg_flags |= (CRMOD+CBREAK);
        mode.sg_flags &= ~CBREAK;
        stty(0,&mode);
}
noecho(){
        gtty(0,&mode);
        mode.sg_flags &= ~ECHO;
        stty(0,&mode);
}
echo(){
        gtty(0,&mode);
        mode.sg_flags |= ECHO;
        stty(0,&mode);
}
