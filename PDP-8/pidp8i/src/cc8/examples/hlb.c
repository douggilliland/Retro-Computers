#define MAXX 1024
#define MAXY 768
 int lstx,stx,lsty,sty;
 int slen;
 int xs,ys;

int stdraw(x1,y1)
int x1,y1;
{

    if (x1 < 0) x1 = 0;
    if (x1 >= MAXX) x1 = MAXX -1;
    if (y1 < 0) y1 = 0;
    if (y1 >= MAXY) y1 = MAXY - 1;
    putc(29);
    putc((y1 / 32) + 32);
    putc((y1 & 31) + 96);
    putc((x1 / 32) + 32);
    putc((x1 & 31) + 64);
    xs = x1;
    ys = y1;
}


int xdraw(x2,y2)
int x2,y2;
{

    if (x2 < 0) x2 = 0;
    if (x2 > MAXX) x2 = MAXX -1;
    if (y2 < 0) y2 = 0;
    if (y2 > MAXY) y2 = MAXY - 1;
    putc((y2 / 32) + 32);
    putc((y2 & 31) + 96);
    putc((x2 / 32) + 32);
    putc((x2 & 31) + 64);
 
    xs = x2;
    ys = y2;
}

int endraw()
{
    putc(31);
}


int drrel(dx,dy)
        int dx,dy;
        {
            xdraw(lstx + dx, lsty + dy);
            lstx = lstx + dx;
            lsty = lsty + dy;
            }

int hlbt(depth,dx,dy)
        int depth,dx,dy;
        {
            if (depth > 1) hlbt(depth - 1, dy, dx);
            drrel(dx, dy);
            if (depth > 1) hlbt(depth - 1, dx, dy);
            drrel(dy, dx);
            if (depth > 1) hlbt(depth - 1, dx, dy);
            drrel(-dx, -dy);
            if (depth > 1) hlbt(depth - 1, -dy, -dx);

        }



 int main()
 {
	 int depth;
 
			slen=20;
			stx=51;
			sty=51;
			depth=5;
			putc(27);
			putc(12);

            {
                /* Draw the curve. */
                lstx=stx;
                lsty=sty;
                stdraw(stx,sty);
                hlbt(depth, slen, 0);
                endraw();
                stdraw(0,0);
		endraw();
            }
            
}
