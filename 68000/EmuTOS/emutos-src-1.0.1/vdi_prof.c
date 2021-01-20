/* Types */
typedef short WORD;
typedef long  LONG;
typedef unsigned short UWORD;
typedef unsigned long ULONG;
typedef struct Line_ Line;
struct Line_
{
    WORD x1,y1;
    WORD x2,y2;
};
typedef struct Rect_ Rect;
struct Rect_
{
    WORD x1,y1;
    WORD x2,y2;
};
typedef struct {
    WORD clip;                  /* polygon clipping on/off */
    WORD multifill;             /* Multi-plane fill flag   */
    UWORD patmsk;               /* Current pattern mask    */
    const UWORD *patptr;        /* Current pattern pointer */
    WORD wrt_mode;              /* Current writing mode    */
    UWORD color;                /* fill color */
} VwkAttrib;

/* Global variables */
extern WORD LN_MASK;
extern WORD v_planes;
extern UWORD v_lin_wr;

/* External functions */
void draw_rect_common(const VwkAttrib *attr, const Rect *rect);
UWORD * get_start_addr(const WORD x, const WORD y);

/* Inlines and Macros */

/*
 * rolw1(WORD x);
 *  rotates x leftwards by 1 bit
 */
#ifdef __mcoldfire__
#define rolw1(x)    x=(x>>15)|(x<<1)
#else
#define rolw1(x)                    \
    __asm__ volatile                \
    ("rol.w #1,%1"                  \
    : "=d"(x)       /* outputs */   \
    : "0"(x)        /* inputs */    \
    : "cc"          /* clobbered */ \
    )
#endif

/*
 * rorw1(WORD x);
 *  rotates x rightwards by 1 bit
 */
#ifdef __mcoldfire__
#define rorw1(x)    x=(x>>1)|(x<<15)
#else
#define rorw1(x)                    \
    __asm__ volatile                \
    ("ror.w #1,%1"                  \
    : "=d" (x)      /* outputs */   \
    : "0" (x)       /* inputs */    \
    : "cc"          /* clobbered */ \
    )
#endif

void abline (const Line * line, WORD wrt_mode, UWORD color)
{
    UWORD *adr;
    UWORD x1,y1,x2,y2;          /* the coordinates */
    WORD dx;                    /* width of rectangle around line */
    WORD dy;                    /* height of rectangle around line */
    WORD yinc;                  /* in/decrease for each y step */
    const WORD xinc = v_planes; /* positive increase for each x step, planes WORDS */
    UWORD msk;
    int plane;
    UWORD linemask = LN_MASK;   /* linestyle bits */

    /* Always draw from left to right */
    if (line->x2 < line->x1) {
        /* if delta x < 0 then draw from point 2 to 1 */
        x1 = line->x2;
        y1 = line->y2;
        x2 = line->x1;
        y2 = line->y1;
    } else {
        /* positive, start with first point */
        x1 = line->x1;
        y1 = line->y1;
        x2 = line->x2;
        y2 = line->y2;
    }

/* Not relevant here */
    /*
     * optimize drawing of horizontal lines
     */
    if (y1 == y2) {
        VwkAttrib attr;
        Rect rect;
        attr.clip = 0;
        attr.multifill = 0;
        attr.patmsk = 0;
        attr.patptr = &linemask;
        attr.wrt_mode = wrt_mode;
        attr.color = color;
        rect.x1 = x1;
        rect.y1 = y1;
        rect.x2 = x2;
        rect.y2 = y2;
        draw_rect_common(&attr,&rect);
        return;
    }

    dx = x2 - x1;
    dy = y2 - y1;

    /* calculate increase values for x and y to add to actual address */
    if (dy < 0) {
        dy = -dy;                       /* make dy absolute */
        yinc = (LONG) -1 * v_lin_wr / 2; /* sub one line of words */
    } else {
        yinc = (LONG) v_lin_wr / 2;     /* add one line of words */
    }

    adr = get_start_addr(x1, y1);       /* init address counter */
    msk = 0x8000 >> (x1&0xf);           /* initial bit position in WORD */

    for (plane = v_planes-1; plane >= 0; plane-- ) {
        UWORD *addr;
        WORD  eps;              /* epsilon */
        WORD  e1;               /* epsilon 1 */
        WORD  e2;               /* epsilon 2 */
        WORD  loopcnt;
        UWORD bit;

        /* load values fresh for this bitplane */
        addr = adr;             /* initial start address for changes */
        bit = msk;              /* initial bit position in WORD */
        linemask = LN_MASK;

        if (dx >= dy) {
            e1 = 2*dy;
            eps = -dx;
            e2 = 2*dx;

            switch (wrt_mode) {
            case 3:              /* reverse transparent  */
                if (color & 0x0001) {
                    for (loopcnt=dx;loopcnt >= 0;loopcnt--) {
                        rolw1(linemask);        /* get next bit of line style */
                        if (linemask&0x0001)
                            *addr &= ~bit;
                        rorw1(bit);
                        if (bit&0x8000)
                            addr += xinc;
                        eps += e1;
                        if (eps >= 0 ) {
                            eps -= e2;
                            addr += yinc;       /* increment y */
                        }
                    }
                } else {
                    for (loopcnt=dx;loopcnt >= 0;loopcnt--) {
                        rolw1(linemask);        /* get next bit of line style */
                        if (linemask&0x0001)
                            *addr |= bit;
                        rorw1(bit);
                        if (bit&0x8000)
                            addr += xinc;
                        eps += e1;
                        if (eps >= 0 ) {
                            eps -= e2;
                            addr += yinc;       /* increment y */
                        }
                    }
                }
                break;
            case 2:              /* xor */
                for (loopcnt=dx;loopcnt >= 0;loopcnt--) {
                    rolw1(linemask);        /* get next bit of line style */
                    if (linemask&0x0001)
                        *addr ^= bit;
                    rorw1(bit);
                    if (bit&0x8000)
                        addr += xinc;
                    eps += e1;
                    if (eps >= 0 ) {
                        eps -= e2;
                        addr += yinc;       /* increment y */
                    }
                }
                break;
            case 1:              /* or */
                if (color & 0x0001) {
                    for (loopcnt=dx;loopcnt >= 0;loopcnt--) {
                        rolw1(linemask);        /* get next bit of line style */
                        if (linemask&0x0001)
                            *addr |= bit;
                        rorw1(bit);
                        if (bit&0x8000)
                            addr += xinc;
                        eps += e1;
                        if (eps >= 0 ) {
                            eps -= e2;
                            addr += yinc;       /* increment y */
                        }
                    }
                } else {
                    for (loopcnt=dx;loopcnt >= 0;loopcnt--) {
                        rolw1(linemask);        /* get next bit of line style */
                        if (linemask&0x0001)
                            *addr &= ~bit;
                        rorw1(bit);
                        if (bit&0x8000)
                            addr += xinc;
                        eps += e1;
                        if (eps >= 0 ) {
                            eps -= e2;
                            addr += yinc;       /* increment y */
                        }
                    }
                }
                break;
            case 0:              /* rep */
                if (color & 0x0001) {
                    for (loopcnt=dx;loopcnt >= 0;loopcnt--) {
                        rolw1(linemask);        /* get next bit of line style */
                        if (linemask&0x0001)
                            *addr |= bit;
                        else
                            *addr &= ~bit;
                        rorw1(bit);
                        if (bit&0x8000)
                            addr += xinc;
                        eps += e1;
                        if (eps >= 0 ) {
                            eps -= e2;
                            addr += yinc;       /* increment y */
                        }
                    }
                }
                else {
                    for (loopcnt=dx;loopcnt >= 0;loopcnt--) {
                        rolw1(linemask);        /* get next bit of line style */
                        *addr &= ~bit;
                        rorw1(bit);
                        if (bit&0x8000)
                            addr += xinc;
                        eps += e1;
                        if (eps >= 0 ) {
                            eps -= e2;
                            addr += yinc;       /* increment y */
                        }
                    }
                }
            }
        } else {
            e1 = 2*dx;
            eps = -dy;
            e2 = 2*dy;

            switch (wrt_mode) {
            case 3:              /* reverse transparent */
                if (color & 0x0001) {
                    for (loopcnt=dy;loopcnt >= 0;loopcnt--) {
                        rolw1(linemask);        /* get next bit of line style */
                        if (linemask&0x0001)
                            *addr &= ~bit;
                        addr += yinc;
                        eps += e1;
                        if (eps >= 0 ) {
                            eps -= e2;
                            rorw1(bit);
                            if (bit&0x8000)
                                addr += xinc;
                        }
                    }
                } else {
                    for (loopcnt=dy;loopcnt >= 0;loopcnt--) {
                        rolw1(linemask);        /* get next bit of line style */
                        if (linemask&0x0001)
                            *addr |= bit;
                        addr += yinc;
                        eps += e1;
                        if (eps >= 0 ) {
                            eps -= e2;
                            rorw1(bit);
                            if (bit&0x8000)
                                addr += xinc;
                        }
                    }
                }
                break;
            case 2:              /* xor */
                for (loopcnt=dy;loopcnt >= 0;loopcnt--) {
                    rolw1(linemask);        /* get next bit of line style */
                    if (linemask&0x0001)
                        *addr ^= bit;
                    addr += yinc;
                    eps += e1;
                    if (eps >= 0 ) {
                        eps -= e2;
                        rorw1(bit);
                        if (bit&0x8000)
                            addr += xinc;
                    }
                }
                break;
            case 1:              /* or */
                if (color & 0x0001) {
                    for (loopcnt=dy;loopcnt >= 0;loopcnt--) {
                        rolw1(linemask);        /* get next bit of line style */
                        if (linemask&0x0001)
                            *addr |= bit;
                        addr += yinc;
                        eps += e1;
                        if (eps >= 0 ) {
                            eps -= e2;
                            rorw1(bit);
                            if (bit&0x8000)
                                addr += xinc;
                        }
                    }
                } else {
                    for (loopcnt=dy;loopcnt >= 0;loopcnt--) {
                        rolw1(linemask);        /* get next bit of line style */
                        if (linemask&0x0001)
                            *addr &= ~bit;
                        addr += yinc;
                        eps += e1;
                        if (eps >= 0 ) {
                            eps -= e2;
                            rorw1(bit);
                            if (bit&0x8000)
                                addr += xinc;
                        }
                    }
                }
                break;
            case 0:              /* rep */
                if (color & 0x0001) {
                    for (loopcnt=dy;loopcnt >= 0;loopcnt--) {
                        rolw1(linemask);        /* get next bit of line style */
                        if (linemask&0x0001)
                            *addr |= bit;
                        else
                            *addr &= ~bit;
                        addr += yinc;
                        eps += e1;
                        if (eps >= 0 ) {
                            eps -= e2;
                            rorw1(bit);
                            if (bit&0x8000)
                                addr += xinc;
                        }
                    }
                }
                else {
                    for (loopcnt=dy;loopcnt >= 0;loopcnt--) {
                        rolw1(linemask);        /* get next bit of line style */
                        *addr &= ~bit;
                        addr += yinc;
                        eps += e1;
                        if (eps >= 0 ) {
                            eps -= e2;
                            rorw1(bit);
                            if (bit&0x8000)
                                addr += xinc;
                        }
                    }
                }
            }
        }
        adr++;
        color >>= 1;    /* shift color index: next plane */
    }
    LN_MASK = linemask;
}