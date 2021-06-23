/*
 *	CC6303:  A C compiler for the 6803/6303 processors
 *	(C) 2019 Alan Cox
 *
 *	This compiler is built out of a much modified CC65 and all new code
 *	is placed under the same licence as the original. Please direct all
 *	cc6303 bugs to the author not to the cc65 developers unless you find
 *	a bug that is also present in cc65.
 */
/*
 *	6800 code generator, heavily based on the cc65 code generator
 *
 *	The main differences we have are
 *	- We have a real stack and use it
 *	- Functions clean up their own arguments
 *	- We remove the 256 byte stack size limitation using a helper
 *	  that fixes up our offset/base.
 *
 *	The basic logic is the same except that we use sreg A B as the
 *	32bits of accumulator and we use X to index things, mostly the
 *	stack. Because we can push 16bits at once only in X and because X
 *	has index uses we also know how to load an immediate into X
 *
 *	We will need a post compiler pass to clean up tsx generation and
 *	also to switch some cases of ldd pusha/b to ldx etc
 *
 *	The 16bit operations mean we inline a lot more code than the 6502
 *	port.
 *
 *	The lack of an extra register (aka Y in cc65 land) isn't usually
 *	a problem as we have less need of it.
 */


/*****************************************************************************/
/*                                                                           */
/*                                 codegen.c                                 */
/*                                                                           */
/*                            6502 code generator                            */
/*                                                                           */
/*                                                                           */
/*                                                                           */
/* (C) 1998-2013, Ullrich von Bassewitz                                      */
/*                Roemerstrasse 52                                           */
/*                D-70794 Filderstadt                                        */
/* EMail:         uz@cc65.org                                                */
/*                                                                           */
/*                                                                           */
/* This software is provided 'as-is', without any expressed or implied       */
/* warranty.  In no event will the authors be held liable for any damages    */
/* arising from the use of this software.                                    */
/*                                                                           */
/* Permission is granted to anyone to use this software for any purpose,     */
/* including commercial applications, and to alter it and redistribute it    */
/* freely, subject to the following restrictions:                            */
/*                                                                           */
/* 1. The origin of this software must not be misrepresented; you must not   */
/*    claim that you wrote the original software. If you use this software   */
/*    in a product, an acknowledgment in the product documentation would be  */
/*    appreciated but is not required.                                       */
/* 2. Altered source versions must be plainly marked as such, and must not   */
/*    be misrepresented as being the original software.                      */
/* 3. This notice may not be removed or altered from any source              */
/*    distribution.                                                          */
/*                                                                           */
/*****************************************************************************/



#include <stdio.h>
#include <string.h>
#include <stdarg.h>

/* common */
#include "check.h"
#include "cpu.h"
#include "inttypes.h"
#include "strbuf.h"
#include "xmalloc.h"
#include "xsprintf.h"
#include "version.h"

/* cc65 */
#include "asmcode.h"
#include "asmlabel.h"
#include "casenode.h"
#include "codeseg.h"
#include "dataseg.h"
#include "error.h"
#include "expr.h"
#include "global.h"
#include "segments.h"
#include "stackptr.h"
#include "util.h"
#include "codegen.h"



/*****************************************************************************/
/*                                  Helpers                                  */
/*****************************************************************************/



static void typeerror (unsigned type)
/* Print an error message about an invalid operand type */
{
    /* Special handling for floats here: */
    if ((type & CF_TYPEMASK) == CF_FLOAT) {
        Fatal ("Floating point type is currently unsupported");
    } else {
        Internal ("Invalid type in CF flags: %04X, type = %u", type, type & CF_TYPEMASK);
    }
}



static const char* GetLabelName (unsigned Flags, uintptr_t Label, long Offs)
{
    static char Buf [256];              /* Label name */

    /* Create the correct label name */
    switch (Flags & CF_ADDRMASK) {

        case CF_STATIC:
            /* Static memory cell */
            if (Offs) {
                xsprintf (Buf, sizeof (Buf), "%s%+ld", LocalLabelName (Label), Offs);
            } else {
                xsprintf (Buf, sizeof (Buf), "%s", LocalLabelName (Label));
            }
            break;

        case CF_EXTERNAL:
            /* External label */
            if (Offs) {
                xsprintf (Buf, sizeof (Buf), "_%s%+ld", (char*) Label, Offs);
            } else {
                xsprintf (Buf, sizeof (Buf), "_%s", (char*) Label);
            }
            break;

        case CF_ABSOLUTE:
            /* Absolute address */
            xsprintf (Buf, sizeof (Buf), "$%04X", (unsigned)((Label+Offs) & 0xFFFF));
            break;

        case CF_REGVAR:
            /* Variable in register bank */
            xsprintf (Buf, sizeof (Buf), "@reg+%u", (unsigned)((Label+Offs) & 0xFFFF));
            break;

        default:
            Internal ("Invalid address flags: %04X", Flags);
    }

    /* Return a pointer to the static buffer */
    return Buf;
}

/* X versus S tracking */

unsigned FramePtr;		/* True if we are using a frame pointer */
unsigned XState;

#define XSTATE_VALID	0x8000

/* Force a TSX and reset the tracking state */
static int ForceTSX(void)
{
        AddCodeLine("tsx");
        XState = XSTATE_VALID;
        return 0;
}

/* Return the offset between S and X, if need be issue a TSX. The
   caller is assumed to be able to handle any positive offset needed
   and generate appropriate code */
static int GenTSX(int low)
{
    int8_t n = (int8_t)(XState & 0xFF);

    /* If our TSX value is below the desired range then it's cheaper
       to TSX. */
    if (!(XState & XSTATE_VALID) || n > low || n + low < 0)
        return ForceTSX();
    return n;
}

/* The caller wants to do a byte operation on low,S, where it knows that
   low,S is in reach if X = S. Provide the relevant offset if we can still
   stay within reach but if not or if we need to index negative then do
   a TSX */
static int GenTSXByte(int low)
{
    int n = GenTSX(low);
    if (n + low > 255)
        return ForceTSX();
    return n;
}

/* Ditto but the caller also wants low+1,S */
static int GenTSXWord(int low)
{
    int n = GenTSX(low);
    if (n + low > 254) {
        ForceTSX();
        return 0;
    }
    return n;
}

static void ModifyX(int Bias)
{
    int16_t offset;
    if (!(XState & XSTATE_VALID))
        return;
    offset = ((int8_t)(XState & 0xFF)) + Bias;
    if (offset < -128 || offset > 127) {
        XState = 0;
        return;
    }
    XState &= 0xFF00;
    XState |= offset & 0xFF;
}

static void InvalidateX(void)
{
    XState = 0;
}

/* Assign a value to D in the most efficient way possible. This is mostly
   ready for when we add 6800 support */

static void AssignD(unsigned short value, int keepc)
{
    uint8_t hi = value >> 8;
    uint8_t lo = value;
    /* Optimizations using clr. clr clears the C flag so we can't always
       use it */
    if (!keepc) {
        if (value == 0) {
            AddCodeLine("clra");
            AddCodeLine("clrb");
            return;
        } else if (CPU == CPU_6800 && !hi) {
            AddCodeLine("clra");
            AddCodeLine("ldab #$%02X", lo);
            return;
        } else if (CPU == CPU_6800 && !lo) {
            AddCodeLine("ldaa #$%02X", value >> 8);
            AddCodeLine("clrb");
            return;
        }
    }
    if (CPU == CPU_6800) {
        /* For things like 0xFF this is a shade shorter */
        if (hi == lo) {
            AddCodeLine("ldaa #$%02X", lo);
            AddCodeLine("tab");
            return;
        }
        /* No 16bit ops on a 6800 */
        AddCodeLine("ldaa #$%02X", hi);
        AddCodeLine("ldab #$%02X", lo);
        return;
    }
    /* We have LDD */
    if (value == 0)
        AddCodeLine("ldd @zero");
    else if (value == 1)
        AddCodeLine("ldd @one");
    else
        AddCodeLine("ldd #$%04X", value);
}

static void AssignX(unsigned short value)
{
    if (value == 0)
        AddCodeLine("ldx @zero");
    else if (value == 1)
        AddCodeLine("ldx @one");
    else
        AddCodeLine("ldx #$%04X", value);
}

static void LoadD(const char *from, int offset)
{
    if (CPU == CPU_6800) {
        if (offset) {
            AddCodeLine("ldaa %s+$%02X", from, offset);
            AddCodeLine("ldab %s+$%02X", from, offset + 1);
        } else {
            AddCodeLine("ldaa %s", from);
            AddCodeLine("ldab %s+1", from);
        }
    } else {
        if (offset)
            AddCodeLine("ldd %s+$%02X", from, offset);
        else
            AddCodeLine("ldd %s", from);
    }
}

static void LoadDViaX(unsigned short offset)
{
    if (CPU == CPU_6800) {
        if (offset > 254)
            Internal("Bad offset $%02X in LoadDViaX.\n", offset);
        AddCodeLine("ldab $%02X,x", offset + 1);
        AddCodeLine("ldaa $%02X,x", offset);
    } else {
        if (offset > 255)
            Internal("Bad offset $%02X in LoadDViaX.\n", offset);
        AddCodeLine("ldd $%02X,x", offset);
    }
}

/* Store D somewhere */
static void StoreD(const char *where, int offset)
{
    if (CPU == CPU_6800) {
        if (offset) {
            AddCodeLine("staa %s+$%04X", where, offset);
            AddCodeLine("stab %s+$%04X", where, offset + 1);
        } else {
            AddCodeLine("staa %s", where);
            AddCodeLine("stab %s+1", where);
        }
    } else {
        if (offset)
            AddCodeLine("std %s+$%04X", where, offset);
        else
            AddCodeLine("std %s", where);
    }
}

static void StoreDViaX(int offset)
{
    if (CPU == CPU_6800) {
        if (offset > 254)
            Internal("Bad offset $%02X in StoreDViaX.\n", offset);
        AddCodeLine("stab $%02X,x", offset + 1);
        AddCodeLine("staa $%02X,x", offset);
    } else {
        if (offset > 255)
            Internal("Bad offset $%02X in StoreDViaX.\n", offset);
        AddCodeLine("std $%02X,x", offset);
    }
}

/* Issue a a pullx or equivalent code on 6800, nv tells us if the value is
   needed. We might one day also want to pass a 'preserve X' flag as it's
   only one instruction more to ins ins when discarding */
static void PullX(int nv)
{
    if (CPU == CPU_6800) {
        if (nv) {
            int offs = GenTSXByte(1);
            AddCodeLine("ldx $%02X,x", offs);
            InvalidateX();
        }
        AddCodeLine("ins");
        AddCodeLine("ins");
        /* Caller is responsible for stack tracking */
    } else {
        AddCodeLine("pulx");
        InvalidateX();
    }
}

static void SubDConst(int value)
{
    if (CPU == CPU_6800) {
        if ((value & 0xFF) == 1) {
            AddCodeLine("decb");
            AddCodeLine("sbca #$%02X", (value >> 8) & 0xFF);
        } else if (value & 0xFF) {
            AddCodeLine("subb #$%02X", value & 0xFF);
            AddCodeLine("sbca #$%02X", (value >> 8) & 0xFF);
        } else
            AddCodeLine("suba #$%02X", (value >> 8) & 0xFF);
    } else {
        if (value == 0)	/* Valid as we may be trying to set flags */
            AddCodeLine("subd @zero");
        else if (value == 1)
            AddCodeLine("subd @one");
        else
            AddCodeLine("subd #$%04X", value & 0xFFFF);
    }
}

/* Like a constant subtract but we don't shortcut anything so that we get
   the carry flag - but not zero flag -correct */
static void SubDConstCompare(int value)
{
    if (CPU == CPU_6800) {
        unsigned L = GetLocalLabel();
        AddCodeLine("cmpa #$%02X", (value >> 8) & 0xFF);
        AddCodeLine("bne %s", LocalLabelName(L));
        AddCodeLine("cmpb #$%02X", value & 0xFF);
        g_defcodelabel(L);
    } else {
        if (value == 0)	/* Valid as we may be trying to set flags */
            AddCodeLine("subd @zero");
        else if (value == 1)
            AddCodeLine("subd @one");
        else
            AddCodeLine("subd #$%04X", value & 0xFFFF);
    }
}

static void SubD(const char *where, int offset)
{
    if (CPU == CPU_6800) {
        if (offset)
            AddCodeLine("subb %s+%d", where, offset);
        else
            AddCodeLine("subb %s", where);
        AddCodeLine("sbca %s+%d", where, offset + 1);
    } else {
        if (offset == 0)
            AddCodeLine("subd %s", where);
        else
            AddCodeLine("subd %s+%d", where, offset);
    }
}

static void SubDViaX(int offset)
{
    if (CPU == CPU_6800) {
        if (offset > 254)
            Internal("Bad offset $%02X in LoadDViaX.\n", offset);
        AddCodeLine("subb $%02X,x", offset + 1);
        AddCodeLine("sbca $%02X,x", offset);
    } else {
        if (offset > 255)
            Internal("Bad offset $%02X in LoadDViaX.\n", offset);
        AddCodeLine("subd $%02X,x", offset);
    }
}

static void AddDConst(int value)
{
    if (CPU == CPU_6800) {
        if ((value & 0xFF) == 1) {
            AddCodeLine("incb");
            AddCodeLine("adca #$%02X", (value >> 8) & 0xFF);
        } else if (value & 0xFF) {
            AddCodeLine("addb #$%02X", value & 0xFF);
            AddCodeLine("adca #$%02X", (value >> 8) & 0xFF);
        } else
            AddCodeLine("adda #$%02X", (value >> 8) & 0xFF);
    } else {
        if (value == 0)
            AddCodeLine("addd @zero");
        else if (value == 1)
            AddCodeLine("addd @one");
        else
            AddCodeLine("addd #$%04X", value & 0xFFFF);
    }
}

static void AddD(const char *where, int offset)
{
    if (CPU == CPU_6800) {
        if (offset)
            AddCodeLine("addb %s+%d", where, offset);
        else
            AddCodeLine("addb %s", where);
        AddCodeLine("adca %s+%d", where, offset + 1);
    } else {
        if (offset == 0)
            AddCodeLine("addd %s", where);
        else
            AddCodeLine("addd %s+%d", where, offset);
    }
}

static void AddDViaX(int offset)
{
    if (CPU == CPU_6800) {
        if (offset > 254)
            Internal("Bad offset $%02X in LoadDViaX.\n", offset);
        AddCodeLine("addb $%02X,x", offset + 1);
        AddCodeLine("adca $%02X,x", offset);
    } else {
        if (offset > 255)
            Internal("Bad offset $%02X in LoadDViaX.\n", offset);
        AddCodeLine("addd $%02X,x", offset);
    }
}


/*
 *	No 6800 series processor has a nice simple 16bit add to X. The
 *	6800 only has inx/dex, the others have ABX for an 8bit add. The
 *	6303 has xgdx which does make life a bit easier
 *
 *	There is a corner case where values close to $FFFF are best done
 *	by DEX but we simply don't generate those use cases.
 */

static void AddByINX(int value)
{
    while(value--)
        AddCodeLine("inx");
}

static int AddByABX255(int value)
{
    if (value < 255)
        return value;
    AddCodeLine("ldab #$FF");
    while(value >= 255) {
        AddCodeLine("abx");
        value -= 255;
    }
    return value;
}

static void AddConstViaABX(int value)
{
    int off;

    /* Add 255 until we are within 255 */
    off = AddByABX255(value);

    if (off <= 3)
        AddByINX(value);
    else {
        AddCodeLine("ldab #$%02X", value);
        AddCodeLine("abx");
    }
}

/* The main entry point: Add a constant to X by whatever means the processor
   requires. Can be told to preserve D and if so will pick the right approach
   for efficiency allowing for stacking cost. We optimize only for size. */
static void AddXConst(int value, int save_d)
{
    int cost;
    int costval = value;

    switch(CPU) {
    case CPU_6803:
        if (value >= 255) {
            /* Cost of ldab #$FF, and repeated abx */
            cost = 2 + costval / 255;
            costval %= 255;	/* What is left ? */
        }
        if (costval < 3)
            cost += costval;	/* Cost of INX INX .. */
        else
            cost += 3;		/* Cost of LDAB #n, ABX */

        if (save_d)
            cost += 2;		/* PSHB PULB */

        /* For small values it's cheaper to use INX */
        if (value <= cost) {
            AddByINX(value);
            return;
        }
        if (cost < 9 + 2 * save_d) {
            /* Worth doing via ABX */
            if (save_d)
                AddCodeLine("pshb");
            AddConstViaABX(value);
            if (save_d)
                AddCodeLine("pulb");
            return;
        }
        /* Fall through: very big values are cheaper to do using D */
    case CPU_6800:
        /* The 6800 case is a bit long winded */
        if (value < 12 + 4 * save_d) {
            AddByINX(value);
            return;
        }
        if (save_d) {
            AddCodeLine("pshb");
            AddCodeLine("psha");
        }
        AddCodeLine("stx @tmp");
        AssignD(value, 0);
        AddD("@tmp", 0);
        AddCodeLine("ldx @tmp");
        if (save_d) {
            AddCodeLine("pula");
            AddCodeLine("pulb");
        }
        return;
    case CPU_6303:
    default:
        if (value <= 5) {
            AddByINX(value);
            return;
        }
        AddCodeLine("xgdx");
        AddCodeLine("addd #$%04X", value);
        AddCodeLine("xgdx");
        return;
    }
}

/*
 *	Adjust the X register so it plus an offset are within the range
 *	of value. We don't need to be exact. This is used in the cases where
 *	we generate an X index and then use off,X forms.
 */

static int AddXRange(int value, int maxoff, int save_d)
{
    int cost;
    int costval = value;
    int minval = value - maxoff;	/* Smallest modify of X we can do
                                           to get into range */

    /* In all cases if we are within range already we do nothing */
    if (value <= maxoff)
        return value;

    switch(CPU) {
    case CPU_6803:
        if (minval >= 255) {
            /* Cost of ldab #$FF, and repeated abx */
            cost = 2 + costval / 255;
            costval %= 255;	/* What is left ? */
        }
        /* We don't need to cost any final adjustments as we won't bother
           generating any fix up but just leave the trailing offset */
        if (save_d)
            cost += 2;		/* PSHB PULB */

        /* For small values it's cheaper to use INX */
        if (minval <= cost) {
            AddByINX(minval);
            return maxoff;
        }
        /* See if using ABX of 255 repeatedly is a win */
        if (cost < 9 + 2 * save_d) {
            /* Worth doing via ABX */
            if (save_d)
                AddCodeLine("pshb");
            AddCodeLine("ldab #$FF");
            /* Keep adding 255 until X is within range. */
            while(value > maxoff) {
                AddCodeLine("abx");
                value -= 255;
            }
            if (save_d)
                AddCodeLine("pulb");
            /* The remainder becomes the offset */
            return value;
        }
        /* Fall through: very big values are cheaper to do using D */
    case CPU_6800:
        /* The 6800 case is a bit long winded */
        if (minval < 12 + 4 * save_d) {
            AddByINX(minval);
            return maxoff;
        }
        /* If we can't do it via INX we have to do the long approach */
        if (save_d) {
            AddCodeLine("pshb");
            AddCodeLine("psha");
        }
        AddCodeLine("stx @tmp");
        AssignD(value, 0);
        AddD("@tmp", 0);
        AddCodeLine("ldx @tmp");
        if (save_d) {
            AddCodeLine("pula");
            AddCodeLine("pulb");
        }
        return 0;
    case CPU_6303:
    default:
        /* See if it is cheapest to INX into range */
        if (minval <= 5) {
            AddByINX(minval);
            return maxoff;
        }
        /* If not, then on the 6303 the cheapest is just do the maths */
        AddCodeLine("xgdx");
        AddCodeLine("addd #$%04X", value);
        AddCodeLine("xgdx");
        return 0;
    }
}

/* ASR is much harder to shortcut */
static void AsrD(void)
{
    AddCodeLine("asra");
    AddCodeLine("rorb");
}

static void LsrD(void)
{
    if (CPU == CPU_6800) {
        AddCodeLine("lsra");
        AddCodeLine("rorb");
    } else
        AddCodeLine("lsrd");
}

static int lsrcost6800[16] = {
    0, 2, 4, 6, 8, 10, 12, 14, 2, 3, 4, 5, 6, 7, 8, 5
};

static int lsrcost6803[16] = {
    0, 1, 2, 3, 4, 5, 6, 7, 2, 3, 4, 5, 6, 7, 8, 4
};

static void LsrDBy(int n)
{
    int cost;
    if (n > 15) {
        AssignD(0, 0);
        return;
    }
    if (CPU == CPU_6800)
        cost = lsrcost6800[n];
    else
        cost = lsrcost6803[n];

    if (IS_Get(&CodeSizeFactor) < ((100 * cost) / 3) - 100) {
        AddCodeLine("jsr shrax%d", n);
        return;
    }

    if (n == 15) {
        AddCodeLine("rola");	/* top bit into carry */
        AssignD(0, 1);
        AddCodeLine("rorb");	/* carry into bottom bit */
        return;
    }

    if (n >= 8) {
        AddCodeLine("tab");
        AddCodeLine("clra");
        while(n-- > 8)
            AddCodeLine("lsrb");	/* Upper bits already done */
        return;
    }
    while(n--)
        LsrD();
}

static void AslD(void)
{
    if (CPU == CPU_6800) {
        AddCodeLine("aslb");
        AddCodeLine("rola");
    } else
        AddCodeLine("asld");
}

static int aslcost6800[16] = {
    0, 2, 4, 6, 8, 10, 12, 14, 2, 3, 4, 5, 6, 7, 8, 4
};

static int aslcost6803[16] = {
    0, 1, 2, 3, 4, 5, 6, 7, 2, 3, 4, 5, 6, 7, 8, 5
};

static void AslDBy(int n)
{
    int cost;
    if (n > 15) {
        AssignD(0, 0);
        return;
    }
    if (CPU == CPU_6800)
        cost = aslcost6800[n];
    else
        cost = aslcost6803[n];

    if (IS_Get(&CodeSizeFactor) < ((100 * cost) / 3) - 100) {
        AddCodeLine("jsr shlax%d", n);
        return;
    }

    if (n == 15) {
        AddCodeLine("rolb");		/* Low bit into carry */
        AssignD(0, 1);			/* Clear */
        AddCodeLine("rora");		/* Carry into top bit */
        return;
    }
    if (n >= 8) {
        AddCodeLine("tba");
        AddCodeLine("clrb");
        while(n-- > 8)
            AddCodeLine("asla");	/* Low bits already done */
        return;
    }
    while(n--)
        AslD();
}

/* Get D into X, may mash D */
static void DToX(void)
{
    switch (CPU) {
        case CPU_6800:
        case CPU_6803:
            StoreD("@tmp", 0);
            AddCodeLine("ldx @tmp");
            break;
        default:
            AddCodeLine("xgdx; DtoX");	/* Comments to help optimizer tracking */
            break;
    }
    InvalidateX();
}
    

/* Get X into D, may mash D */
static void XToD(void)
{
    switch (CPU) {
        case CPU_6803:
            AddCodeLine("stx @tmp");
            LoadD("@tmp", 0);
            break;
        default:
            AddCodeLine("xgdx; XtoD");
            break;
    }
}

/* Generate an offset from the stack into X. We try and minimise the
   required code by using off,x for smaller offsets and maths only
   for bigger ones. The maths for really big offsets is horrible so don't
   write C with big stack arrays ....

   To further complicate things we may be an L-R stacked vararg function
   in which case @fp is the base for arguments (Offs >= 0)
 */

static int GenOffset(unsigned Flags, int Offs, int save_d, int exact)
{
    unsigned s = sizeofarg(Flags) - 1;
    int curoffs;
    int far;

    /* Frame pointer using function, use the frame pointer only for
       arguments not locals */
    if (Offs > 0 && FramePtr) {
        InvalidateX();
        AddCodeLine(";Genoffset %u %d %d %d\n",
            Flags, Offs, save_d, exact);
        Offs += 2;	/* FP is from SP but also have stacked fp */
        if (Offs < 256 - s) {

            /* Usual simple case. X holds fp, caller is using n,X format
               so we just load x with @fp on any CPU type */
            if (!exact) {
                AddCodeLine("ldx @fp");
                return Offs;
            }
            /* The caller needs the actual exact value in X and the adjustment
               is small. Use inx if cheaper */
            if (exact && Offs < (save_d ? 5 : 7)) {
                AddCodeLine("ldx @fp");
                while(Offs--)
                    AddCodeLine("inx");
                return 0;
            }
            /* On a non 6800 processor we can add 0-255 with ABX. This costs
               us a bit more but is still OK */
            if (CPU != CPU_6800) {
                if (save_d)
                    AddCodeLine("pshb");
                AddCodeLine("ldx @fp");
                AddCodeLine("ldab #$%02X", Offs);
                AddCodeLine("abx");
                if (save_d)
                    AddCodeLine("pulb");
                return 0;
            }
            /* For the 6800 fall through to the hard case */
        }
        /* This is not terribly efficient but it almost never happens */
        if (save_d) {
            AddCodeLine("pshb");
            AddCodeLine("psha");
        }
        LoadD("@fp", 0);
        AddDConst(Offs);
        DToX();
        if (save_d) {
            AddCodeLine("pula");
            AddCodeLine("pulb");
        }
        return 0;
    }

    /* The non vararg argument case. Everything is relative to S, X may hold
       something related to S already */

    /* Adjust for current stack pointer */
    Offs -= StackPtr;

    /* How many bytes offset before we give up and go via D */
    if (CPU != CPU_6800)
        far = 2040;
    else {
        /* We have no ABX on 6800 so our range is more limited */
        if (exact)
            far = 3 - s;
        else
            far = 258 - s;
    }
    /* Big offsets are ugly and we have to go via D */
    if (Offs + s >= far) {
        if (save_d) {
            AddCodeLine("pshb");
            AddCodeLine("psha");
        }
        AddCodeLine("sts @tmp");
        AssignD(Offs + 1, 0);		/* So it matches a TSX based offset */
        AddCodeLine("addd @tmp");
        DToX();
        if (save_d) {
            AddCodeLine("pula");
            AddCodeLine("pulb");
        }
        return 0;
    }

    /* Generate the tsx if needed */
    curoffs = GenTSX(Offs);

    /* We are in range of n,x so do nothing but tsx */
    if (curoffs + Offs + s <= 255 && !exact)
        return curoffs + Offs;

    /* If we are in the range of the current S then it's usually
       cheaper to TSX than adjust */
    if (Offs + s <= 255 && !exact) {
        InvalidateX();
        curoffs = GenTSX(0);
        return curoffs + Offs;
    }

    /* Calculate the actual target */    
    Offs += curoffs;

    /* Range we must be within in order to finish the job with inx or
       just return */
    far = 258;
    if (exact)
        far = 3;

    /* Repeatedly add 255 until we are in range or it is cheaper to use
       inx for the rest */
    if (Offs + s >= far) {
        if (save_d)
            AddCodeLine("pshb");
        AddCodeLine("ldab #$FF");
        while(Offs >= 255) {
            Offs -= 255;
            AddCodeLine("abx");
        }
        if (exact) {
            AddCodeLine("ldab #$%02X", Offs + s);
            AddCodeLine("abx");
            Offs  = 0;
        }
        if (save_d)
            AddCodeLine("pulb");
        InvalidateX();
    }
    /* Make sure we are fully reachable. That means being within 254/255
       for a non exact request, or within 3 for an exact one. We do the final
       tidy up with inx */
    switch(Offs + s) {
    case 258:
    case 3:
        AddCodeLine("inx");
        ModifyX(1);
        Offs--;
        /* Falls through */
    case 257:
    case 2:
        AddCodeLine("inx");
        ModifyX(1);
        Offs--;
        /* Falls through */
    case 256:
    case 1:
        AddCodeLine("inx");
        ModifyX(1);
        Offs--;
        /* Falls through */
    default: ;
    }
    return Offs;
}
    
/*****************************************************************************/
/*                            Pre- and postamble                             */
/*****************************************************************************/



void g_preamble (void)
/* Generate the assembler code preamble */
{
    /* Identify the compiler version */
    AddTextLine (";");
    AddTextLine ("; File generated by cc68 v %s", GetVersionAsString ());
    AddTextLine (";");

    /* If we're producing code for some other CPU, switch the command set */
    switch (CPU) {
        case CPU_6800:	    AddTextLine ("\t.setcpu\t\t6800");	    break;
        case CPU_6803:      AddTextLine ("\t.setcpu\t\t6803");      break;
        case CPU_6303:      AddTextLine ("\t.setcpu\t\t6303");      break;
        default:            Internal ("Unknown CPU: %d", CPU);
    }

    /* Import dp variables */
    /* FIXME: */
}



void g_fileinfo (const char* Name, unsigned long Size, unsigned long MTime)
/* If debug info is enabled, place a file info into the source */
{
    /* TODO */
}

/* The code that follows may be moved around */
void g_moveable (void)
{
    InvalidateX();
}

/* We have generted code and thrown it away. FIXME: we can do better in this
   case I think */
void g_removed (void)
{
    InvalidateX();
}


/*****************************************************************************/
/*                              Segment support                              */
/*****************************************************************************/



void g_userodata (void)
/* Switch to the read only data segment */
{
    UseDataSeg (SEG_RODATA);
}



void g_usedata (void)
/* Switch to the data segment */
{
    UseDataSeg (SEG_DATA);
}



void g_usebss (void)
/* Switch to the bss segment */
{
    UseDataSeg (SEG_BSS);
}



void g_segname (segment_t Seg)
/* Emit the name of a segment if necessary */
{
    /* Emit a segment directive for the data style segments */
    DataSeg* S;
    switch (Seg) {
        case SEG_RODATA: S = CS->ROData; break;
        case SEG_DATA:   S = CS->Data;   break;
        case SEG_BSS:    S = CS->BSS;    break;
        default:         S = 0;          break;
    }
    if (S) {
        DS_AddLine (S, ".segment\t\"%s\"", GetSegName (Seg));
    }
}



/*****************************************************************************/
/*                                   Code                                    */
/*****************************************************************************/



unsigned sizeofarg (unsigned flags)
/* Return the size of a function argument type that is encoded in flags */
{
    switch (flags & CF_TYPEMASK) {

        case CF_CHAR:
            return (flags & CF_FORCECHAR)? 1 : 2;

        case CF_INT:
            return 2;

        case CF_LONG:
            return 4;

        case CF_FLOAT:
            return 4;

        default:
            typeerror (flags);
            /* NOTREACHED */
            return 2;
    }
}


/* We need to track the state of X versus S here. As we push and pop
   we may well be able to supress the use of TSX but we can't assume the
   offset versus S is the same any more */
int pop (unsigned flags)
/* Pop an argument of the given size */
{
    unsigned s = sizeofarg (flags);
    ModifyX(s);
    return StackPtr += s;
}



int push (unsigned flags)
/* Push an argument of the given size */
{
    unsigned s = sizeofarg (flags);
    ModifyX(-s);
    return StackPtr -= s;
}



static unsigned MakeByteOffs (unsigned Flags, unsigned Offs)
/* The value in Offs is an offset to an address in d. Make sure, an object
** of the type given in Flags can be loaded or stored into this address by
** adding part of the offset to the address in d, so that the remaining
** offset fits into an index register. Return the remaining offset.
*/
{
    /* For many cases 257 is ok because we work on words and 255,x is good */
    if (Offs <= 256 - sizeofarg (Flags))
        return Offs;
    AddDConst(Offs);
    return 0;
}



/*****************************************************************************/
/*                      Functions handling local labels                      */
/*****************************************************************************/



void g_defcodelabel (unsigned label)
/* Define a local code label */
{
    AddCodeLine("%s:", LocalLabelName(label));
    /* Overly pessimistic but we don't know what our branch will come from */
    InvalidateX();
}

void g_defdatalabel (unsigned label)
/* Define a local data label */
{
    AddDataLine ("%s:", LocalLabelName (label));
}



void g_aliasdatalabel (unsigned label, unsigned baselabel, long offs)
/* Define label as a local alias for baselabel+offs */
{
    /* We need an intermediate buffer here since LocalLabelName uses a
    ** static buffer which changes with each call.
    */
    StrBuf L = AUTO_STRBUF_INITIALIZER;
    SB_AppendStr (&L, LocalLabelName (label));
    SB_Terminate (&L);
    AddDataLine ("%s .equ\t%s+%ld",
                 SB_GetConstBuf (&L),
                 LocalLabelName (baselabel),
                 offs);
    SB_Done (&L);
}



/*****************************************************************************/
/*                     Functions handling global labels                      */
/*****************************************************************************/



void g_defgloblabel (const char* Name)
/* Define a global label with the given name */
{
    /* Global labels are always data labels */
    AddDataLine ("_%s:", Name);
}



void g_defexport (const char* Name, int ZP)
/* Export the given label */
{
    if (ZP) {
        AddTextLine ("\t.exportzp\t_%s", Name);
    } else {
        AddTextLine ("\t.export\t\t_%s", Name);
    }
}



void g_defimport (const char* Name, int ZP)
/* Import the given label */
{
}



void g_importstartup (void)
/* Forced import of the startup module */
{
}



void g_importmainargs (void)
/* Forced import of a special symbol that handles arguments to main */
{
}



/*****************************************************************************/
/*                          Function entry and exit                          */
/*****************************************************************************/

void g_enter (const char *name, unsigned flags, unsigned argsize)
/* Function prologue */
{
    push (CF_INT);		/* Return address */
    AddCodeLine(".export _%s", name);
    AddCodeLine("_%s:",name);

    /* We have no valid X state on entry */

    /* Uglies from the L->R stack handling for varargs */
    if ((flags & CF_FIXARGC) == 0) {
        /* Frame pointer is required for varargs mode */
        if (CPU == CPU_6800) {
            AddCodeLine("des");
            AddCodeLine("des");
            AddCodeLine("jsr fixfp");
        } else {
            AddCodeLine("ldx @fp");
            AddCodeLine("pshx");
            AddCodeLine("tsx");
            AddCodeLine("abx");
            AddCodeLine("stx @fp");
        }
        FramePtr = 1;
    } else
        FramePtr = 0;
    InvalidateX();
}



void g_leave(int voidfunc, unsigned flags, unsigned argsize)
/* Function epilogue */
{
    /* Should always be zero : however ignore this being wrong if we took
       a C level error as that may be the real cause. Only valid code failing
       this check is a problem */

    if (StackPtr && !ErrorCount)
        Internal("g_leave: stack unbalanced by %d", StackPtr);

    /* Recover the previous frame pointer if we were vararg */
    if (FramePtr) {
        if (CPU == CPU_6800) {
            AddCodeLine("jmp restorefp");
            return;
        } else {
            PullX(1);
            AddCodeLine("stx @fp");
        }
    } else {
        if (CPU == CPU_6800 && argsize) {
            /* The 6800 ABI is for space reasons called function cleans up
               arguments. The 6803/303 ABI is not because it's rather faster
               and cleaner that way */
            if (argsize <= 12)	/* usual case */
                AddCodeLine("jmp ret%d", argsize);
            else if (argsize < 256) {
                if (!voidfunc)
                    AddCodeLine("pshb");
                AddCodeLine("ldab #$%02X", argsize);
                AddCodeLine("stab @tmp + 1");
                if (!voidfunc)
                    AddCodeLine("pulb");
                AddCodeLine("jmp retn8");
            } else {	/* Insane cases */
                if (!voidfunc)
                    AddCodeLine("pshb");
                AddCodeLine("ldab #$%02X", argsize >> 8);
                AddCodeLine("stab @tmp");
                AddCodeLine("ldab #$%02X", argsize);
                AddCodeLine("stab @tmp + 1");
                if (!voidfunc)
                    AddCodeLine("pulb");
                AddCodeLine("jmp retn");
            }
        } else
            AddCodeLine("rts");
    }
}



/*****************************************************************************/
/*                           Fetching memory cells                           */
/*****************************************************************************/



void g_getimmed (unsigned Flags, unsigned long Val, long Offs)
/* Load a constant into the primary register, or into X for some special
   cases we want to optimize */
{
    unsigned short W1,W2;


    if ((Flags & CF_CONST) != 0) {

        /* Numeric constant */
        switch (Flags & CF_TYPEMASK) {

            case CF_CHAR:
                if ((Flags & CF_USINGX) == 0 && (Flags & CF_FORCECHAR) != 0) {
                    if (Val == 0)
                        AddCodeLine("clrb");
                    else
                        AddCodeLine ("ldab #$%02X", (unsigned char) Val);
                    break;
                }
                /* FALL THROUGH */
            case CF_INT:
                if (Flags & CF_USINGX) {
                    AssignX(Val);
                    InvalidateX();
                } else
                    AssignD(Val, 0);
                break;

            case CF_LONG:
                /* Split the value into 4 bytes */
                W1 = (unsigned short) (Val >> 0);
                W2 = (unsigned short) (Val >> 16);
                if (Flags & CF_USINGX) {
                    /* Important: This is deliberately arranged so that
                       the 32bit value is also in D:X so that callers can
                       go either way - TODO check ok to kill X in D case */
                    AssignD(W2, 0);
                    StoreD("@sreg", 0);
                    AssignX(W1);
                    InvalidateX();
                } else {
                    /* Load the value */
                    AssignD(W2, 0);
                    StoreD("@sreg", 0);
                    /* TODO: for 6800 we should try and do byte not word sized
                       pair optimizing */
                    if (W1 != W2)
                        AssignD(W1, 0);
                }
                break;

            default:
                typeerror (Flags);
                break;

        }

    } else {

        /* Some sort of label */
        const char* Label = GetLabelName (Flags, Val, Offs);

        /* Load the address into the primary */
        if (Flags & CF_USINGX) {
            AddCodeLine("ldx #%s", Label);
            InvalidateX();
        } else {
            if (CPU == CPU_6800) {
                AddCodeLine("ldaa #>%s", Label);
                AddCodeLine("ldab #<%s", Label);
            } else
                AddCodeLine ("ldd #%s", Label);
        }
    }
}



void g_getstatic (unsigned flags, uintptr_t label, long offs)
/* Fetch an static memory cell into the primary register */
{
    /* Create the correct label name */
    const char* lbuf = GetLabelName (flags, label, offs);

    /* Check the size and generate the correct load operation */
    switch (flags & CF_TYPEMASK) {

        case CF_CHAR:
            /* No byte loads into X and they don't usually make sense
               so flag them as not happening and let the caller try again
               via D */
            NotViaX();
            if ((flags & CF_FORCECHAR) || (flags & CF_TEST)) {
                AddCodeLine ("ldab %s", lbuf);   /* load A from the label */
            } else {
                AddCodeLine ("clra");
                AddCodeLine ("ldab %s", lbuf);   /* load A from the label */
                if (!(flags & CF_UNSIGNED)) {
                    /* Must sign extend */
                    unsigned L = GetLocalLabel ();
                    AddCodeLine ("bpl %s", LocalLabelName (L));
                    AddCodeLine ("coma");
                    g_defcodelabel (L);
                }
            }
            break;

        case CF_INT:
            if (flags & CF_USINGX) {
                    InvalidateX();
                    AddCodeLine ("ldx %s", lbuf);
            }
            else
                LoadD(lbuf, 0);
            break;

        case CF_LONG:
            if (flags & CF_TEST) {
                NotViaX();
                LoadD(lbuf, 2);
                AddCodeLine ("orab %s+1", lbuf);
                AddCodeLine ("orab %s+0", lbuf);
            } else {
                LoadD(lbuf, 0);
                StoreD("@sreg", 0);
                if (flags & CF_USINGX) {
                    InvalidateX();
                    AddCodeLine ("ldx %s+2", lbuf);
                } else
                    LoadD(lbuf, 2);
            }
            break;

        default:
            typeerror (flags);

    }
}



void g_getlocal (unsigned Flags, int Offs)
/* Fetch specified local object (local var). */
{
    NotViaX();

    Offs = GenOffset(Flags, Offs, 0, 0);

    switch (Flags & CF_TYPEMASK) {

        case CF_CHAR:
            if ((Flags & CF_FORCECHAR) || (Flags & CF_TEST)) {
                AddCodeLine ("ldab $%02X,x", Offs);
            } else {
                AddCodeLine ("clra");
                AddCodeLine ("ldab $%02X,x ", Offs);
                if ((Flags & CF_UNSIGNED) == 0) {
                    unsigned L = GetLocalLabel();
                    AddCodeLine ("bpl %s", LocalLabelName (L));
                    AddCodeLine ("coma");
                    g_defcodelabel (L);
                }
            }
            break;

        case CF_INT:
            LoadDViaX(Offs);
            break;

        case CF_LONG:
            LoadDViaX(Offs);
            StoreD("@sreg", 0);
            LoadDViaX(Offs + 2);
            if (Flags & CF_TEST)
                g_test (Flags);
            break;

        default:
            typeerror (Flags);
    }
}

void g_getlocal_x (unsigned Flags, int Offs)
/* Fetch specified local object (local var) into x. */
{
    Offs = GenOffset(Flags, Offs, 0, 0);

    InvalidateX();

    switch (Flags & CF_TYPEMASK) {

        case CF_CHAR:
            if (Flags & CF_FORCECHAR) {
                Internal("ForceChar in getlocal_x");
                break;
            }

        case CF_INT:
            AddCodeLine ("ldx $%02X,x", Offs);
            break;

        case CF_LONG:
            LoadDViaX(Offs + 2);
            StoreD ("@sreg", 0);
            AddCodeLine ("ldx $%02X,x", Offs);
            break;

        default:
            typeerror (Flags);
    }
}


/* FIXME: in the case we are generating code for X do these become no-op */

void g_primary_to_x(void)
{
    DToX();
}

void g_x_to_primary(void)
{
    XToD();
}

/* For now we use D but there is a good case for optimising a lot of these
   paths to use X when they don't need X again shortly */

/* FIXME: endiannes */

void g_getind (unsigned Flags, unsigned Offs)
/* Fetch the specified object type indirect through the primary register
** into the primary register
*/
{
    /* If the offset is greater than 255, add the part that is > 255 to
    ** the primary. This way we get an easy addition and use the low byte
    ** as the offset
    **
    ** FIXME: for 6803 we want to fold this into the xdgx helper as it's
    ** cheaper then
    *
    * We want to end up with either
    *
    *	addd Offs		(if offs > 255)
    *	xgdx
    *
    * or for 6801/3 it's nastier as we must do
    *
    *	addd Offs		(if offs > 255)
    *	std @tmp
    *	ldx @tmp
    *	
    */
    Offs = MakeByteOffs (Flags, Offs);

    /* FIXME: For now. We really want D into X and X into X forms */
    NotViaX();

    /* Handle the indirect fetch */
    switch (Flags & CF_TYPEMASK) {

        case CF_CHAR:
            /* Character sized */
            DToX();		/* 6803 is uglier */
            AddCodeLine ("clra");
            AddCodeLine ("ldab $%02X,x", Offs);
            if ((Flags & CF_UNSIGNED) == 0) {
                    unsigned L = GetLocalLabel();
                    AddCodeLine ("bpl %s", LocalLabelName (L));
                    AddCodeLine ("coma");
                    g_defcodelabel (L);
            }
            break;

        case CF_INT:
            DToX();
            LoadDViaX(Offs);
            break;

        case CF_LONG:
            DToX();
            LoadDViaX(Offs);
            StoreD("@sreg", 0);
            LoadDViaX(Offs + 2);
            if (Flags & CF_TEST) {
                g_test (Flags);
            }
            break;

        default:
            typeerror (Flags);

    }
}



void g_leasp (unsigned Flags, int Offs)
/* Fetch the address of the specified symbol into the primary register */
{
    /* FramePtr indicates a Varargs function where arguments are relative
       to fp */
    AddCodeLine(";leasp %d %d\n", FramePtr, Offs);
    if (FramePtr && Offs > 0) {
        /* Because of the frame pointer */
        Offs += 2;
        if (!(Flags & CF_USINGX) || Offs > 255 || CPU == CPU_6800) {
            LoadD("@fp", 0);
            AddDConst(Offs);
            if (Flags & CF_USINGX)
                DToX();
        } else {
            InvalidateX();
            AddCodeLine("ldx @fp");
            AddCodeLine("ldab #$%02X", Offs);
            AddCodeLine("abx");
        }
        return;
    }
    Offs = -Offs;
    /* Calculate the offset relative to sp */
    Offs += StackPtr;

    AddCodeLine(";+leasp %d %d\n", FramePtr, Offs);

    if (!(Flags & CF_USINGX)) {
        if (CPU == CPU_6800) {
            Offs = -Offs;
            Offs += 2;		/* Cost of the jsr */
            if (Offs < 256) {
                if (Offs)
                    AddCodeLine("ldab #$%02X", Offs);
                else
                    AddCodeLine("clrb");
                AddCodeLine("jsr leasp8");
            } else {
                AssignD(Offs, 0);
                AddCodeLine("jsr leasp");
            }
        } else {
            /* No smarter way when going via D */
            AddCodeLine("sts @tmp1");
            Offs --;		/* Because 1,sp is the top of stack vars */
            if (Offs) {
                AssignD(-Offs, 0);
                AddD("@tmp1", 0);
            } else {
                LoadD("@tmp1", 0);
            }
        }
        return;
    }

    /* Easier to work backwards */
    Offs = -Offs;

    InvalidateX();		/* FIXME: can we use GenOffset type logic */
    AddCodeLine("tsx");
    /* FIXME: probably > 1018 - work this out properly */
    if (Offs < 1018 && CPU != CPU_6800) {
        InvalidateX();	/* FIXME: rework off existing X if we can */
        AddCodeLine("tsx");
        if (Offs >= 255) {
            AddCodeLine("ldab #$255");
            while(Offs >= 255) {
                AddCodeLine("abx");
                Offs -= 255;
            }
        }
        if (Offs) {
            AddCodeLine("ldab #$%02X", Offs);
            AddCodeLine("abx");
        }
    } else {
        /* Hard case - probably better just to go via D */
        NotViaX();
        /* FIXME: we need to deal with this case so we can do sane codegen when
        working with X as constant */
        Internal("FIXME: g_leasp");
    }
}

/*****************************************************************************/
/*                             Store into memory                             */
/*****************************************************************************/

void g_putstatic (unsigned flags, uintptr_t label, long offs)
/* Store the primary register into the specified static memory cell */
{
    /* Create the correct label name */
    const char* lbuf = GetLabelName (flags, label, offs);

    /* Check the size and generate the correct store operation */
    switch (flags & CF_TYPEMASK) {

        case CF_CHAR:
            NotViaX();
            AddCodeLine ("stab %s", lbuf);
            break;

        case CF_INT:
            if (flags & CF_USINGX) {
                InvalidateX();
                AddCodeLine ("stx %s", lbuf);
            } else
                StoreD(lbuf, 0);
            break;

        case CF_LONG:
            if (flags & CF_USINGX) {
                AddCodeLine ("stx %s+2", lbuf);
                AddCodeLine ("ldx @sreg");
                AddCodeLine ("stx %s", lbuf);
                InvalidateX();
            } else {
                StoreD(lbuf, 2);
                LoadD("@sreg", 0);
                StoreD(lbuf, 0);
            }
            break;

        default:
            typeerror (flags);

    }
}



void g_putlocal (unsigned Flags, int Offs, long Val)
/* Put data into local object. */
{
    Offs = GenOffset (Flags, Offs, (Flags & CF_CONST) ? 0 : 1, 0);

    NotViaX();		/* We need X for our index */

    switch (Flags & CF_TYPEMASK) {

        case CF_CHAR:
            if (Flags & CF_CONST) {
                if ((Val & 0xFF) == 0)
                    AddCodeLine("clrb");
                else
                    AddCodeLine ("ldab #$%02X", (unsigned char) Val);
            }
            AddCodeLine ("stab $%02X,x", Offs);
            break;

        case CF_INT:
            if (Flags & CF_CONST)
                AssignD(Val, 0);
            StoreDViaX(Offs);
            break;

        case CF_LONG:
            if (Flags & CF_CONST) {
                AssignD(Val >> 16, 0);
                StoreDViaX(Offs);
                if ((Val >> 16) != (Val & 0xFFFF))
                    AssignD(Val & 0xFFFF, 0);
                StoreDViaX(Offs + 2);
            } else {
                NotViaX();	/* For now. May be worth it via X and @tmp */
                StoreDViaX(Offs + 2);
                LoadD("@sreg", 0);
                StoreDViaX(Offs);
            }
            break;

        default:
            typeerror (Flags);

    }
}



/* FIXME: needs a complete review */
void g_putind (unsigned Flags, unsigned Offs)
/* Store the specified object type in the primary register at the address
** on the top of the stack
*/
{
    /* FIXME: work out actual case values */
    unsigned viaabx = 1536;
    unsigned size = 256;

    /* For now and probably always */
    NotViaX();
    InvalidateX();
    
    if (CPU == CPU_6303)
        viaabx = 1024;
    if (CPU == CPU_6800)
        viaabx = 0;	/* No ABX instruction */

    if ((Flags & CF_TYPEMASK) == CF_LONG)
        size -= 2;

    /* For 0-255 (0-253 for long) range we can just use n,X */
    if (Offs < size)
        PullX(1);
    /* For 254 and long we need to inx first so n+2 is in range */
    else if (Offs == 254) {
        PullX(1);
        AddCodeLine("inx");
        Offs--;
    /* Same for 255 with two */
    } else if (Offs == 255) {
        PullX(1);
        AddCodeLine("inx");
        AddCodeLine("inx");
        Offs -= 2;
    }
    /* Use abx loops to meet the target. Keep adding 255 until we are in
       range. If need be use inx to line up the +2 case */
    else if (Offs < viaabx) {
        PullX(1);
        AddCodeLine("pshb");
        AddCodeLine("ldab #$FF");
        /* 255 per loop */
        while(Offs >= 255) {
            AddCodeLine("abx");
            Offs -= 255;
        }
        /* Pathalogical case. Remaining offset is 254 and we have a long. In
           that case we inx so that n+2 is 255 */
        if (Offs == 254 && size == 254) {
            AddCodeLine("inx");
            Offs -= 1;
        }
        AddCodeLine("pulb");
    } else {
        /* The yucky path we try and avoid. It's not so bad on 6303 but very
           ugly on 6803 as we have to stash things and go via d */
        if (CPU == CPU_6303) {
            AddCodeLine("pulx");
            AddCodeLine("xgdx");
            AddDConst(Offs);
            AddCodeLine("xgdx");
        } else {
            StoreD("@tmp2", 0);
            AddCodeLine("pula");
            AddCodeLine("pulb");
            AddDConst(Offs);
            StoreD("@tmp", 0);
            AddCodeLine("ldx @tmp");
            LoadD("@tmp2", 0);
        }
        Offs = 0;
    }

    /* X now points into the object, and Offs is the remaining offset to
       allow for. D holds the stuff to store */                
    switch (Flags & CF_TYPEMASK) {
        case CF_CHAR:
            AddCodeLine ("stab $%02X,x", Offs);
            break;

        case CF_INT:
            StoreDViaX(Offs);
            break;

        case CF_LONG:
            StoreDViaX(Offs + 2);
            LoadD("@sreg", 0);
            StoreDViaX(Offs);
            break;

        default:
            typeerror (Flags);

    }
    InvalidateX();

    /* Pop the argument which is always a pointer */
    pop (CF_PTR);
}



/*****************************************************************************/
/*                    type conversion and similiar stuff                     */
/*****************************************************************************/


/* FIXME: move off stack ? */

void g_toslong (unsigned flags)
/* Make sure, the value on TOS is a long. Convert if necessary */
{
    switch (flags & CF_TYPEMASK) {

        case CF_CHAR:
        case CF_INT:
            NotViaX();	/* For now */
            InvalidateX();
            if (flags & CF_UNSIGNED) {
                /* Push a new upper 16bits of zero */
                if (CPU == CPU_6800) {
                    AddCodeLine("clrb");
                    AddCodeLine("pshb");
                    AddCodeLine("pshb");
                } else {
                    AssignX(0);
                    AddCodeLine("pshx");
                }
            } else {
                if (CPU == CPU_6800) {
                    /* need to sign extend */
                    unsigned L = GetLocalLabel();
                    AddCodeLine("pula");
                    AddCodeLine("clrb");
                    AddCodeLine("oraa #0");	/* generate N flag */
                    AddCodeLine("bpl %s", LocalLabelName (L));
                    AddCodeLine("decb");  /* B to -1 */
                    g_defcodelabel (L);
                    AddCodeLine("psha");
                    AddCodeLine("pshb");
                    AddCodeLine("pshb");
                } else {
                    /* need to sign extend */
                    unsigned L = GetLocalLabel();
                    AddCodeLine("pula");
                    AssignX(0);
                    AddCodeLine("oraa #0");	/* generate N flag */
                    AddCodeLine("bpl %s", LocalLabelName (L));
                    AddCodeLine("dex");	/* X to -1 */
                    g_defcodelabel (L);
                    AddCodeLine("psha");
                    AddCodeLine("pshx");
                }
            }
            push (CF_INT);
            break;

        case CF_LONG:
            break;

        default:
            typeerror (flags);
    }
}



void g_tosint (unsigned flags)
/* Make sure, the value on TOS is an int. Convert if necessary */
{
    switch (flags & CF_TYPEMASK) {

        case CF_CHAR:
        case CF_INT:
            break;

        case CF_LONG:
            /* We have a big endian long at s+4,3,2,1 so we just need to
               throw out the top. Use ins so we don't trash X */
            AddCodeLine("ins");
            AddCodeLine("ins");
            pop (CF_INT);
            break;

        default:
            typeerror (flags);
    }
}



static void g_regchar (unsigned Flags)
/* Make sure, the value in the primary register is in the range of char. Truncate if necessary */
{
    unsigned L;

    AddCodeLine ("clra");

    if ((Flags & CF_UNSIGNED) == 0) {
        NotViaX();
        /* Sign extend */
        L = GetLocalLabel();
        AddCodeLine ("cmpb #$80");
        AddCodeLine ("bcs %s", LocalLabelName (L));
        AddCodeLine ("coma");
        g_defcodelabel (L);
    }
}



void g_regint (unsigned Flags)
/* Make sure, the value in the primary register an int. Convert if necessary */
{
    switch (Flags & CF_TYPEMASK) {

        case CF_CHAR:
            if (Flags & CF_FORCECHAR) {
                /* Conversion is from char */
                g_regchar (Flags);
            }
            /* FALLTHROUGH */

        case CF_INT:
        case CF_LONG:
            break;

        default:
            typeerror (Flags);
    }
}



void g_reglong (unsigned Flags)
/* Make sure, the value in the primary register a long. Convert if necessary */
{
    unsigned L;

    switch (Flags & CF_TYPEMASK) {

        case CF_CHAR:
            NotViaX();
            if (Flags & CF_FORCECHAR) {
                /* Conversion is from char */
                AssignX(0);
                AddCodeLine("clra");
                if ((Flags & CF_UNSIGNED) == 0) {
                    L = GetLocalLabel();
                    AddCodeLine ("bitb #$80");
                    AddCodeLine ("beq %s", LocalLabelName (L));
                    AddCodeLine ("dex");
                    AddCodeLine ("coma");
                    g_defcodelabel (L);
                }
                AddCodeLine("stx @sreg");
                InvalidateX();
                break;   
            }
            /* FALLTHROUGH */

        case CF_INT:
            NotViaX();
            AssignX(0);
            if ((Flags & CF_UNSIGNED)  == 0) {
                L = GetLocalLabel();
                AddCodeLine ("bita #$80");
                AddCodeLine ("beq %s", LocalLabelName (L));
                AddCodeLine ("dex");
                g_defcodelabel (L);
            }
            AddCodeLine("stx @sreg");
            InvalidateX();
            break;

        case CF_LONG:
            break;

        default:
            typeerror (Flags);
    }
}



unsigned g_typeadjust (unsigned lhs, unsigned rhs)
/* Adjust the integer operands before doing a binary operation. lhs is a flags
** value, that corresponds to the value on TOS, rhs corresponds to the value
** in (e)ax. The return value is the the flags value for the resulting type.
*/
{
    unsigned ltype, rtype;
    unsigned result;

    /* Get the type spec from the flags */
    ltype = lhs & CF_TYPEMASK;
    rtype = rhs & CF_TYPEMASK;

    /* Check if a conversion is needed */
    if (ltype == CF_LONG && rtype != CF_LONG && (rhs & CF_CONST) == 0) {
        /* We must promote the primary register to long */
        g_reglong (rhs);
        /* Get the new rhs type */
        rhs = (rhs & ~CF_TYPEMASK) | CF_LONG;
        rtype = CF_LONG;
    } else if (ltype != CF_LONG && (lhs & CF_CONST) == 0 && rtype == CF_LONG) {
        /* We must promote the lhs to long */
        if (lhs & CF_REG) {
            g_reglong (lhs);
        } else {
            g_toslong (lhs);
        }
        /* Get the new rhs type */
        lhs = (lhs & ~CF_TYPEMASK) | CF_LONG;
        ltype = CF_LONG;
    }

    /* Determine the result type for the operation:
    **  - The result is const if both operands are const.
    **  - The result is unsigned if one of the operands is unsigned.
    **  - The result is long if one of the operands is long.
    **  - Otherwise the result is int sized.
    */
    result = (lhs & CF_CONST) & (rhs & CF_CONST);
    result |= (lhs & CF_UNSIGNED) | (rhs & CF_UNSIGNED);
    if (rtype == CF_LONG || ltype == CF_LONG) {
        result |= CF_LONG;
    } else {
        result |= CF_INT;
    }
    return result;
}



unsigned g_typecast (unsigned lhs, unsigned rhs)
/* Cast the value in the primary register to the operand size that is flagged
** by the lhs value. Return the result value.
*/
{
    /* Check if a conversion is needed */
    if ((rhs & CF_CONST) == 0) {
        switch (lhs & CF_TYPEMASK) {

            case CF_LONG:
                /* We must promote the primary register to long */
                g_reglong (rhs);
                break;

            case CF_INT:
                /* We must promote the primary register to int */
                g_regint (rhs);
                break;

            case CF_CHAR:
                /* We must truncate the primary register to char */
                g_regchar (lhs);
                break;

            default:
                typeerror (lhs);
        }
    }

    /* Do not need any other action. If the left type is int, and the primary
    ** register is long, it will be automagically truncated. If the right hand
    ** side is const, it is not located in the primary register and handled by
    ** the expression parser code.
    */

    /* Result is const if the right hand side was const */
    lhs |= (rhs & CF_CONST);

    /* The resulting type is that of the left hand side (that's why you called
    ** this function :-)
    */
    return lhs;
}



void g_scale (unsigned flags, long val)
/* Scale the value in the primary register by the given value. If val is positive,
** scale up, is val is negative, scale down. This function is used to scale
** the operands or results of pointer arithmetic by the size of the type, the
** pointer points to.
*/
{
    int p2;

    /* FIXME: check if we get called for char and if so return before
       NotViaX. */
    NotViaX();
    /* Value may not be zero */
    if (val == 0) {
        Internal ("Data type has no size");
    } else if (val > 0) {

        /* Scale up */
        if ((p2 = PowerOf2 (val)) > 0 && p2 <= 4) {

            /* Factor is 2, 4, 8 and 16, use special function */
            switch (flags & CF_TYPEMASK) {

                case CF_CHAR:
                    if (flags & CF_FORCECHAR) {
                        while (p2--) {
                            AddCodeLine ("aslb");
                        }
                        break;
                    }
                    /* FALLTHROUGH */

                case CF_INT:
                    if (CPU == CPU_6800 && p2 > 2)
                        AddCodeLine("jsr shlax%d\n", p2);
                    else {
                        while (p2--)
                            AslD();
                    }
                    break;

                case CF_LONG:
                    InvalidateX();
                    if (flags & CF_UNSIGNED) {
                        AddCodeLine ("jsr shleax%d", p2);
                    } else {
                        AddCodeLine ("jsr asleax%d", p2);
                    }
                    break;

                default:
                    typeerror (flags);

            }

        } else if (val != 1) {

            /* Use a multiplication instead */
            g_mul (flags | CF_CONST, val);

        }

    } else {

        /* Scale down */
        val = -val;
        if ((p2 = PowerOf2 (val)) > 0 && p2 <= 4) {

            /* Factor is 2, 4, 8 and 16 use special function */
            switch (flags & CF_TYPEMASK) {

                case CF_CHAR:
                    if (flags & CF_FORCECHAR) {
                        if (flags & CF_UNSIGNED) {
                            while (p2--)
                                AddCodeLine("lsrb");
                        } else {
                            while (p2--)
                                AddCodeLine ("asrb");
                        }
                        break;
                    }
                    /* FALLTHROUGH */

                case CF_INT:
                    if (flags & CF_UNSIGNED) {
                        LsrDBy(p2);
                    } else  {
                        InvalidateX();
                        if (p2 == 1)
                            AsrD();
                        else
                            /* There is no asrd */
                            AddCodeLine ("jsr asrax%d", p2);
                    }
                    break;

                case CF_LONG:
                    InvalidateX();
                    if (flags & CF_UNSIGNED) {
                        AddCodeLine ("jsr lsreax%d", p2);
                    } else {
                        AddCodeLine ("jsr asreax%d", p2);
                    }
                    break;

                default:
                    typeerror (flags);

            }

        } else if (val != 1) {

            /* Use a division instead */
            g_div (flags | CF_CONST, val);

        }
    }
}



/*****************************************************************************/
/*              Adds and subs of variables fix a fixed address               */
/*****************************************************************************/



void g_addlocal (unsigned flags, int offs)
/* Add a local variable to d */
{
    NotViaX();

    switch (flags & CF_TYPEMASK) {

        case CF_CHAR:
            offs = GenOffset(flags, offs, 1, 0);
            AddCodeLine ("addb $%02X,x", offs & 0xFF);
            AddCodeLine ("adca #0");
            break;

        case CF_INT:
            offs = GenOffset(flags, offs, 1, 0);
            AddCodeLine ("addd $%02X,x", offs & 0xFF);
            break;

        case CF_LONG:
            /* Do it the old way */
            /* FIXME: optimise */
            g_push (flags, 0);
            g_getlocal (flags, offs);
            g_add (flags, 0);
            break;

        default:
            typeerror (flags);

    }
}



void g_addstatic (unsigned flags, uintptr_t label, long offs)
/* Add a static variable to ax */
{
    /* Create the correct label name */
    const char* lbuf = GetLabelName (flags, label, offs);

    NotViaX();

    switch (flags & CF_TYPEMASK) {

        case CF_CHAR:
            AddCodeLine("addb %s", lbuf);
            AddCodeLine("adca #0");
            break;

        case CF_INT:
            AddD(lbuf, 0);
            break;

        case CF_LONG:
            AddD(lbuf, 2);
            StoreD("@tmp", 0);
            LoadD(lbuf, 0);
            AddCodeLine("adcb @sreg+1");
            AddCodeLine("adca @sreg");
            StoreD("@sreg", 0);
            LoadD("@tmp", 0);
            break;

        default:
            typeerror (flags);

    }
}



/*****************************************************************************/
/*                           Special op= functions                           */
/*****************************************************************************/



void g_addeqstatic (unsigned flags, uintptr_t label, long offs,
                    unsigned long val)
/* Emit += for a static variable */
{
    /* Create the correct label name */
    const char* lbuf = GetLabelName (flags, label, offs);


    /* Check the size and determine operation */
    switch (flags & CF_TYPEMASK) {

        case CF_CHAR:
            if (CPU == CPU_6800) {
                AddCodeLine("ldx #%s", lbuf);
                if (flags & CF_FORCECHAR) {
                    if (flags & CF_CONST) {
                        if (val <= 4) {
                            if (flags & CF_UNSIGNED) {
                                while(val--)
                                    AddCodeLine("inc ,x");
                                AddCodeLine("ldab ,x");
                            } else {
                                AddCodeLine("jsr baddeqstatic%d", (int)val);
                                return;
                            }
                        } else {
                            AddCodeLine("ldab #%d", (int)val);
                        }
                    }
                    if (flags & CF_UNSIGNED) {
                        AddCodeLine("clra");
                        AddCodeLine("addb ,x");
                        AddCodeLine("stab ,x");
                    } else
                        AddCodeLine("jsr baddeqstatic");
                    return;
                }
            } else {
                NotViaX();
                if (flags & CF_FORCECHAR) {
                    AddCodeLine ("clra");
                    if (flags & CF_CONST) {
                        if (val == 1) {
                            AddCodeLine ("inc %s", lbuf);
                            AddCodeLine ("ldab %s", lbuf);
                        } else {
                            AddCodeLine ("ldab %s", lbuf);
                            AddCodeLine ("addb #$%02X", (unsigned char)val);
                            AddCodeLine ("stab %s", lbuf);
                        }
                    } else {
                        AddCodeLine ("addb %s", lbuf);
                        AddCodeLine ("stab %s", lbuf);
                    }
                    if ((flags & CF_UNSIGNED) == 0) {
                        unsigned L = GetLocalLabel();
                        AddCodeLine ("bpl %s", LocalLabelName (L));
                        AddCodeLine ("coma");
                        g_defcodelabel (L);
                    }
                    break;
                }
            }
            /* FALLTHROUGH */

        case CF_INT:
            if (CPU == CPU_6800) {
                AddCodeLine("ldx #%s", lbuf);
                if (flags & CF_CONST) {
                    if (val <= 4) {
                        AddCodeLine("jsr addeqstatic%d", (int)val);
                        return;
                    } else if (val < 256) {
                        AddCodeLine("ldab #$%02X", (int)val);
                        AddCodeLine("jsr addeqstaticb");
                        return;
                    } else
                        AssignD(val, 0);
                }
                AddCodeLine("jsr addeqstatic");
                return;
            }
            if (flags & CF_CONST) {
                if ((flags & CF_USINGX) && val <= 2) {
                    InvalidateX();
                    AddCodeLine ("ldx %s", lbuf);
                    switch(val) {
                        case 2:
                            AddCodeLine ("inx");
                            /* Fall through */
                        case 1:
                            AddCodeLine ("inx");
                            break;
                    }
                    AddCodeLine("stx %s", lbuf);
                    break;
                }
                NotViaX();

                if (val == 1) {
                    unsigned L = GetLocalLabel ();
                    AddCodeLine ("inc %s+1", lbuf);
                    AddCodeLine ("bne %s", LocalLabelName (L));
                    AddCodeLine ("inc %s", lbuf);
                    g_defcodelabel (L);
                    LoadD(lbuf, 0);
                } else {
                    NotViaX();
                    AssignD(val, 0);
                    AddD(lbuf, 0);
                    StoreD(lbuf, 0);
                }
            } else {
                NotViaX();
                AddD(lbuf, 0);
                StoreD(lbuf, 0);
            }
            break;

        case CF_LONG:
            NotViaX();
            if (flags & CF_CONST) {
                if (val < 0x100 && CPU == CPU_6800) {
                    AddCodeLine ("ldx #%s", lbuf);
                    AddCodeLine("ldab #%d", (int)val);
                    AddCodeLine("jsr laddeqstatic8");
                    return;
                }
                if (val < 0x10000) {
                    InvalidateX();
                    AddCodeLine ("ldx #%s", lbuf);
                    AssignD(val, 0);
                    AddCodeLine("jsr laddeqstatic16");
                } else {
                    g_getstatic (flags, label, offs);
                    g_inc (flags, val);
                    g_putstatic (flags, label, offs);
                }
            } else {
                /* No offs case here ? */
                InvalidateX();
                AddCodeLine ("ldx #%s", lbuf);
                AddCodeLine ("jsr laddeq");
            }
            break;

        default:
            typeerror (flags);
    }
}



void g_addeqlocal (unsigned flags, int Offs, unsigned long val)
/* Emit += for a local variable */
{
    NotViaX();
    
    /* Check the size and determine operation */
    switch (flags & CF_TYPEMASK) {

        case CF_CHAR:
            if (flags & CF_FORCECHAR) {
                Offs = GenOffset(flags, Offs, (flags & CF_CONST) ? 0 : 1, 0);
                AddCodeLine("clra");
                if ((flags & CF_CONST) && val == 1) {
                    AddCodeLine("ldab $%02X,x", Offs);
                    AddCodeLine("incb");
                    AddCodeLine ("stab $%02X,x", Offs);
                } else {
                    if (flags & CF_CONST)
                        AddCodeLine ("ldab #$%02X", (int)(val & 0xFF));
                    AddCodeLine ("addb $%02X,x", Offs);
                    AddCodeLine ("stab $%02X,x", Offs);
                }

                if ((flags & CF_UNSIGNED) == 0) {
                    unsigned L = GetLocalLabel();
                    AddCodeLine ("bpl %s", LocalLabelName (L));
                    AddCodeLine ("coma");
                    g_defcodelabel (L);
                }
                break;
            }
            /* FALLTHROUGH */

        case CF_INT:
            Offs = GenOffset(flags, Offs, (flags & CF_CONST) ? 0 : 1, 0);
            /* Uninline the usual 6800 case */
            if ((flags & CF_CONST) && Offs == 0 && CPU == CPU_6800) {
                if (val < 256) {
                    AddCodeLine ("ldab #$%02X", (unsigned char)val);
                    AddCodeLine ("jsr addtotosb");
                } else {
                    AssignD(val, 0);
                    AddCodeLine ("jsr addtotos");
                }
            }
            if (flags & CF_CONST)
                AssignD(val, 0);
            AddDViaX(Offs);
            StoreDViaX(Offs);
            break;

        case CF_LONG:
            /* FIXME: this needs much improvement for 680x */
            if (flags & CF_CONST) {
                g_getimmed (flags, val, 0);
            }
            InvalidateX();
            AddCodeLine ("ldx #$%04X", Offs);
            AddCodeLine ("jsr laddeqysp");
            break;

        default:
            typeerror (flags);
    }
}


/* FIXME: we need a notion not just of using X but of "from X" to fix this
   to generate x relative code when it can. And probably smarts in the caller */
void g_addeqind (unsigned flags, unsigned offs, unsigned long val)
/* Emit += for the location with address in d */
{
    /* If the offset is too large for a byte register, add the high byte
    ** of the offset to the primary. Beware: We need a special correction
    ** if the offset in the low byte will overflow in the operation.
    */
    offs = MakeByteOffs (flags, offs);

    /* Check the size and determine operation */
    switch (flags & CF_TYPEMASK) {

        case CF_CHAR:
            DToX();
            AddCodeLine("ldab $%02X,x", offs);
            if (val == 1)
                AddCodeLine("incb");
            else
                AddCodeLine("addb #$%04X", (unsigned char)val);
            AddCodeLine("stab $%02X,x", offs);
            break;

        case CF_INT:
            DToX();
            LoadDViaX(offs);
            AddDConst(val);
            StoreDViaX(offs);
            break;
            
            /* Fall through */
        case CF_LONG:
            AddCodeLine ("pshb ; addeqind");         /* Push the address */
            AddCodeLine ("psha");
            push (CF_PTR);                      /* Correct the internal sp */
            g_getind (flags, offs);             /* Fetch the value */
            g_inc (flags, val);                 /* Increment value in primary */
            g_putind (flags, offs);             /* Store the value back */
            break;

        default:
            typeerror (flags);
    }
}



void g_subeqstatic (unsigned flags, uintptr_t label, long offs,
                    unsigned long val)
/* Emit -= for a static variable */
{
    /* Create the correct label name */
    const char* lbuf = GetLabelName (flags, label, offs);

    /* Check the size and determine operation */
    switch (flags & CF_TYPEMASK) {

        case CF_CHAR:
            NotViaX();
            if (flags & CF_FORCECHAR) {
                AddCodeLine ("clra");
                if (flags & CF_CONST) {
                    if (val == 1) {
                        AddCodeLine ("dec %s", lbuf);
                        AddCodeLine ("ldab %s", lbuf);
                    } else {
                        AddCodeLine ("ldab %s", lbuf);
                        AddCodeLine ("subb #$%02X", (int)(val & 0xFF));
                        AddCodeLine ("stab %s", lbuf);
                    }
                } else {
                    AddCodeLine ("negb");
                    AddCodeLine ("addb %s", lbuf);
                    AddCodeLine ("stab %s", lbuf);
                }
                if ((flags & CF_UNSIGNED) == 0) {
                    unsigned L = GetLocalLabel();
                    AddCodeLine ("bpl %s", LocalLabelName (L));
                    AddCodeLine ("coma");
                    g_defcodelabel (L);
                }
                break;
            }
            /* FALLTHROUGH */

        case CF_INT:
            if ((flags & CF_CONST) && (flags & CF_USINGX) && val <= 2) {
                InvalidateX();
                AddCodeLine ("ldx %s", lbuf);
                if (val == 2)
                    AddCodeLine("dex");
                if (val == 1 || val == 2)
                    AddCodeLine("dex");
                AddCodeLine("stx %s", lbuf);
                break;
            }
            NotViaX();
            if (flags & CF_CONST) {
                LoadD(lbuf, 0);
                SubDConst(val);
                StoreD(lbuf, 0);
            } else {
                /* This seems to be simpler than playing with coma/b and subd */
                StoreD("@tmp", 0);
                LoadD(lbuf, 0);
                SubD("@tmp", 0);
                StoreD(lbuf, 0);
            }
            break;

        case CF_LONG:
            NotViaX();
            if (flags & CF_CONST) {
                if (val < 0x10000) {
                    LoadD(lbuf, 0);
                    SubDConst(val);
                    StoreD(lbuf, 0);
                } else {
                    g_getstatic (flags, label, offs);
                    g_dec (flags, val);
                    g_putstatic (flags, label, offs);
                }
            } else {
                InvalidateX();
                AddCodeLine ("ldx #%s", lbuf);
                AddCodeLine ("jsr lsubeq");
            }
            break;

        default:
            typeerror (flags);
    }
}



void g_subeqlocal (unsigned flags, int Offs, unsigned long val)
/* Emit -= for a local variable */
{
    NotViaX();

    /* Check the size and determine operation */
    switch (flags & CF_TYPEMASK) {

        case CF_CHAR:
            Offs = GenOffset(flags, Offs, (flags & CF_CONST) ? 0 : 1, 0);
            if (flags & CF_FORCECHAR) {
                AddCodeLine ("clra");
                if (flags & CF_CONST) {
                    AddCodeLine ("ldab $%02X,x", Offs);
                    if (val == 1)
                        AddCodeLine ("decb");
                    else
                        AddCodeLine ("subb #$%02X", (unsigned char)val);
                } else {
                    AddCodeLine ("comb");
                    AddCodeLine ("addb $%02X,x", Offs);
                }
                AddCodeLine ("stab $%02X,x", Offs);
                if ((flags & CF_UNSIGNED) == 0) {
                    unsigned L = GetLocalLabel();
                    AddCodeLine ("bpl %s", LocalLabelName (L));
                    AddCodeLine ("coma");
                    g_defcodelabel (L);
                }
                break;
            }
            /* FALLTHROUGH */

        case CF_INT:
            Offs = GenOffset(flags, Offs, (flags & CF_CONST) ? 0 : 1, 0);
            if (flags & CF_CONST) {
                LoadDViaX (Offs);
                SubDConst(val);
                StoreDViaX(Offs);
                break;
            }
            StoreD("@tmp", 0);
            LoadDViaX(Offs);
            SubD("@tmp", 0);
            StoreDViaX(Offs);
            break;

        case CF_LONG:
            if (flags & CF_CONST) {
                g_getimmed (flags, val, 0);
            }
            InvalidateX();
            AssignX(Offs);
            AddCodeLine ("jsr lsubeqysp");
            break;

        default:
            typeerror (flags);
    }
}



void g_subeqind (unsigned flags, unsigned offs, unsigned long val)
/* Emit -= for the location with address in X */
{
    /* If the offset is too large for a byte register, add the high byte
    ** of the offset to the primary. Beware: We need a special correction
    ** if the offset in the low byte will overflow in the operation.
    */
    offs = MakeByteOffs (flags, offs);

    NotViaX();	/* For now see note on addeqind */
    /* Check the size and determine operation */
    switch (flags & CF_TYPEMASK) {

        case CF_CHAR:
            /* No need to care about sign extension ? */
            /* FIXME: would a combo makebyteoffs/dtox(offs) help */
            DToX();
            AddCodeLine ("clra");
            AddCodeLine ("ldab $%02X,x", offs);
            AddCodeLine ("adda #$%02X", (unsigned char)val);
            AddCodeLine ("stab $%02X,x", offs);
            break;

        case CF_INT:
            DToX();
            LoadDViaX(offs);
            SubDConst(val);
            StoreDViaX(offs);
            break;
        case CF_LONG:
            InvalidateX();
            AddCodeLine ("jsr pushd");          /* Push the address */
            push (CF_PTR);                      /* Correct the internal sp */
            g_getind (flags, offs);             /* Fetch the value */
            g_dec (flags, val);                 /* Increment value in primary */
            g_putind (flags, offs);             /* Store the value back */
            break;

        default:
            typeerror (flags);
    }
}



/*****************************************************************************/
/*                 Add a variable address to the value in d                 */
/*****************************************************************************/



void g_addaddr_local (unsigned flags attribute ((unused)), int offs)
/* Add the address of a local variable to d */
{
    /* FIXME: varargs */
    /* Add the offset */
    NotViaX();		/* For now: can improve on this due to abx */
    offs -= StackPtr;
    if (offs != 0)
        AddDConst(offs);
    AddCodeLine("sts @tmp");
    AddD("@tmp", 0);
}



void g_addaddr_static (unsigned flags, uintptr_t label, long offs)
/* Add the address of a static variable to d */
{
    /* Create the correct label name */
    const char* lbuf = GetLabelName (flags, label, offs);

    NotViaX();
    if (CPU == CPU_6800) {
        AddCodeLine ("addb #<%s", lbuf);
        AddCodeLine ("adca #>%s", lbuf);
    } else
        AddCodeLine ("addd #%s", lbuf);
}



/*****************************************************************************/
/*                                                                           */
/*****************************************************************************/

/* This is used internally for certain increment cases only */

void g_save (unsigned flags)
/* Copy primary register to hold register. */
{
    NotViaX();
    /* Check the size and determine operation */
    switch (flags & CF_TYPEMASK) {

        case CF_CHAR:
            if (flags & CF_FORCECHAR) {
                AddCodeLine ("stab @tmp1");
                break;
            }
            /* FALLTHROUGH */

        case CF_INT:
            StoreD("@tmp1", 0);
            break;

        case CF_LONG:
            InvalidateX();
            AddCodeLine ("jsr saveeax");
            break;

        default:
            typeerror (flags);
    }
}



void g_restore (unsigned flags)
/* Copy hold register to primary. */
{
    NotViaX();
    /* Check the size and determine operation */
    switch (flags & CF_TYPEMASK) {

        case CF_CHAR:
            if (flags & CF_FORCECHAR) {
                AddCodeLine ("ldab @tmp1");
                break;
            }
            /* FALLTHROUGH */

        case CF_INT:
            LoadD("@tmp1", 0);
            break;

        case CF_LONG:
            InvalidateX();
            /* FIXME: INLINE */
            AddCodeLine ("jsr resteax");
            break;

        default:
            typeerror (flags);
    }
}



void g_cmp (unsigned flags, unsigned long val)
/* Immidiate compare. The primary register will not be changed, Z flag
** will be set.
*/
{
    unsigned L;

    NotViaX();

    /* Check the size and determine operation */
    switch (flags & CF_TYPEMASK) {

        case CF_CHAR:
            if (flags & CF_FORCECHAR) {
                AddCodeLine ("cmpb #$%02X", (unsigned char)val);
                break;
            }
            /* FALLTHROUGH */

        case CF_INT:
            /* No cmpd */
            L = GetLocalLabel();
            AddCodeLine ("cmpb #$%02X", (unsigned char)val);
            AddCodeLine ("bne %s", LocalLabelName (L));
            AddCodeLine ("cmpa #$%02X", (unsigned char)(val >> 8));
            g_defcodelabel (L);
            break;

        case CF_LONG:
            Internal ("g_cmp: Long compares not implemented");
            break;

        default:
            typeerror (flags);
    }
}



static void oper (unsigned Flags, unsigned long Val, const char* const* Subs)
/* Encode a binary operation. subs is a pointer to four strings:
**      0       --> Operate on ints
**      1       --> Operate on unsigneds
**      2       --> Operate on longs
**      3       --> Operate on unsigned longs
**
**  Sets up X for accesses. Don't use oper for magic via X code
*/
{
    /* Determine the offset into the array */
    if (Flags & CF_UNSIGNED) {
        ++Subs;
    }
    if ((Flags & CF_TYPEMASK) == CF_LONG) {
        Subs += 2;
    }

    /* Load the value if it is not already in the primary */
    if (Flags & CF_CONST) {
        /* Load value - we call the helpers with the value in D, except
           for longs */
        g_getimmed (Flags, Val, 0);
    }

    AddCodeLine ("jsr %s", *Subs);
    InvalidateX();

    /* The operation will pop it's argument */
    pop (Flags);
}



void g_test (unsigned flags)
/* Test the value in the primary and set the condition codes */
{
    NotViaX();
    switch (flags & CF_TYPEMASK) {
        case CF_CHAR:
            if (flags & CF_FORCECHAR) {
                AddCodeLine ("tstb");
                break;
            }
            /* FALLTHROUGH */

        case CF_INT:
            /* FIXME: are there better options for 6303 at least ? */
            AddCodeLine ("staa @tmp1");
            AddCodeLine ("orab @tmp1");
            /* Check we get all the codes we need this way */
            break;

        case CF_LONG:
            InvalidateX();
            if (flags & CF_UNSIGNED) {
                AddCodeLine ("jsr utsteax");
            } else {
                AddCodeLine ("jsr tsteax");
            }
            break;

        default:
            typeerror (flags);

    }
}



void g_push (unsigned flags, unsigned long val)
/* Push the primary register or a constant value onto the stack */
{
    /* FIXME: we need to do long better especially in the 6800 case */
    if ((flags & CF_CONST) && (flags & CF_TYPEMASK) != CF_LONG) {

        /* We have a constant 8 or 16 bit value */
        if ((flags & CF_TYPEMASK) == CF_CHAR && (flags & CF_FORCECHAR)) {
            NotViaX();
            /* Handle as 8 bit value */
            if (val == 0)
                AddCodeLine("clrb");
            else
                AddCodeLine ("ldab #$%02X", (unsigned char) val);
            AddCodeLine ("pshb");

        } else {
            if (CPU == CPU_6800) {
                g_getimmed (flags, val, 0);
                AddCodeLine ("pshb");
                AddCodeLine ("psha");
            } else {
                /* We force this case via X in all cases */
                /* Handle as 16 bit value via X */
                g_getimmed (CF_USINGX|flags, val, 0);
                InvalidateX();
                AddCodeLine ("pshx");
            }
        }

    } else {

        /* Value is not 16 bit or not constant */
        if (flags & CF_CONST) {
            /* Take big values via X or D:X */
            if ((flags & CF_TYPEMASK) != CF_CHAR || (flags & CF_FORCECHAR) == 0) {
                if (CPU == CPU_6800) {
                    g_getimmed (flags , val, 0);
                    switch(flags & CF_TYPEMASK) {
                    case CF_INT:
                        AddCodeLine("pshb");
                        AddCodeLine("psha");
                        break;
                    case CF_LONG:
                        /* This is ugly FIXME: for 6800 make g_getimmed
                           put the other bits not in X but a reg ? */
                        AddCodeLine("pshb");
                        AddCodeLine("psha");
                        AddCodeLine("stx @tmp");
                        AddCodeLine("ldab @tmp+1");
                        AddCodeLine("pshb");
                        AddCodeLine("ldaa @tmp");
                        AddCodeLine("psha");
                    }
                } else {
                    /* Force immediates via X */
                    /* FIXME: 6800 support needs adding here */
                    if (CPU == CPU_6800) {
                        /* No pshx so do it the hard way */
                        g_getimmed (flags, val, 0);
                        AddCodeLine("pshb");
                        AddCodeLine("psha");
                        switch (flags & CF_TYPEMASK) {
                        case CF_INT:
                            break;
                        case CF_LONG:
                            LoadD("@sreg", 0);
                            AddCodeLine("pshb");
                            AddCodeLine("psha");
                            break;
                        }
                    } else {
                        g_getimmed (flags | CF_USINGX, val, 0);
                        InvalidateX();
                        switch(flags & CF_TYPEMASK) {
                        case CF_INT:
                            AddCodeLine("pshx");
                            break;
                        case CF_LONG:
                            /* X is the low bits in this case */
                            AddCodeLine("pshx");
                            AddCodeLine("pshb");
                            AddCodeLine("psha");
                            break;
                        default:
                            typeerror (flags);
                        }
                    }
                    push (flags);
                    return;
                }
            }
            g_getimmed (flags, val, 0);
        }

        /* Push the primary register */
        switch (flags & CF_TYPEMASK) {

            case CF_CHAR:
                if (flags & CF_FORCECHAR) {
                    NotViaX();
                    /* Handle as char */
                    AddCodeLine ("pshb");
                    break;
                }
                /* FALL THROUGH */
            case CF_INT:
                if (flags & CF_USINGX)
                    AddCodeLine("pshx");
                else {
                    AddCodeLine ("pshb");
                    AddCodeLine ("psha");
                }
                break;

            case CF_LONG:
                if (flags & CF_USINGX)
                    AddCodeLine("pshx");
                else {
                    AddCodeLine ("pshb");
                    AddCodeLine ("psha");
                }
                NotViaX();
                InvalidateX();
                /* Could go via D if it helps other stuff */
                if (CPU == CPU_6800) {
                    LoadD("@sreg", 0);
                    AddCodeLine ("pshb");
                    AddCodeLine ("psha");
                } else {
                    AddCodeLine ("ldx @sreg");
                    AddCodeLine ("pshx");
                }
                break;

            default:
                typeerror (flags);

        }

    }

    /* Adjust the stack offset */
    push (flags);
}



void g_swap (unsigned flags)
/* Swap the primary register and the top of the stack. flags give the type
** of *both* values (must have same size).
*/
{
    NotViaX();
    InvalidateX();
    switch (flags & CF_TYPEMASK) {

        case CF_CHAR:
        case CF_INT:
            if (CPU == CPU_6303) {
                AddCodeLine("pulx");
                AddCodeLine("xgdx");
                AddCodeLine("pshx");
            } else
                AddCodeLine ("jsr swapstk");
            break;

        case CF_LONG:
            AddCodeLine ("jsr swapestk");
            break;

        default:
            typeerror (flags);

    }
}



/* Flags tells us if it is varargs, ArgSize is the number of *extra* bytes
   pushed for the ... */
void g_call (unsigned Flags, const char* Label, int ArgSize)
/* Call the specified subroutine name */
{
    InvalidateX();
    if ((Flags & CF_FIXARGC) == 0) {
        if (ArgSize > 254)
            Error("too many arguments to function");
        if (ArgSize)
            AddCodeLine("ldab #$%02X", ArgSize);
        else
            AddCodeLine("clrb");
    }
    AddCodeLine ("jsr _%s", Label);
}



/* Flags tells us if it is varargs, ArgSize is the number of *extra* bytes
   pushed for the ... */
void g_callind (unsigned Flags, int Offs, int ArgSize)
/* Call subroutine indirect */
{
    InvalidateX();
    if ((Flags & CF_LOCAL) == 0) {
        /* Address is in d */
        if ((Flags & CF_USINGX) == 0)
            DToX();
        if ((Flags & CF_FIXARGC) == 0) {
            if (ArgSize)
                AddCodeLine("ldab #$%02X", ArgSize);
            else
                AddCodeLine("clrb");
        }
        AddCodeLine ("jsr ,x");
    } else {
        /* FIXME: check flag type is right here */
        GenOffset(Flags, Offs, 1, 1);
        if ((Flags & CF_FIXARGC) == 0) {
            if (ArgSize)
                AddCodeLine("ldab #$%02X", ArgSize);
            else
                AddCodeLine("clrb");
        }
        AddCodeLine("jsr jumpx");
        /* jumpx is just jmp ,x" */
    }
}



void g_jump (unsigned Label)
/* Jump to specified internal label number */
{
    AddCodeLine ("jmp %s", LocalLabelName (Label));
}



void g_truejump (unsigned flags attribute ((unused)), unsigned label)
/* Jump to label if zero flag clear */
{
    AddCodeLine ("jne %s", LocalLabelName (label));
}



void g_falsejump (unsigned flags attribute ((unused)), unsigned label)
/* Jump to label if zero flag set */
{
    AddCodeLine ("jeq %s", LocalLabelName (label));
}


void g_lateadjustSP (unsigned label)
/* Adjust stack based on non-immediate data */
{
    NotViaX();
    if (CPU == CPU_6800) {
        /* On the 6800 it inlines to 14 bytes, on 6803+
           to only 9 */
        AddCodeLine("ldx #%s",LocalLabelName (label));
        AddCodeLine("jsr lateadjustsp");
        InvalidateX();
    } else {
        AddCodeLine ("sts @tmp");
        LoadD("@tmp", 0);
        AddD(LocalLabelName (label), 0);
        AddCodeLine ("lds @tmp");
        InvalidateX();
    }
}

void g_drop (unsigned Space, int save_d)
/* Drop space allocated on the stack */
/* We have ABX but nothing the other way */
{
    /* There are a few cases we could save X FIXME */
    InvalidateX();
    if (Space > 10 + 4 * save_d) {
        /* Preserve @sreg/D */
        if (Space < 256 && CPU != CPU_6800) {
            AddCodeLine("tsx");
            if (save_d)
                AddCodeLine("stab @tmp");
            AddCodeLine("ldab #$%02X", Space);
            AddCodeLine("abx");
            AddCodeLine("txs");
            if (save_d)
                AddCodeLine("ldab @tmp");
        } else {           
            if (save_d)
                StoreD("@tmp2", 0);
            AddCodeLine("sts @tmp");
            LoadD("@tmp", 0);
            AddDConst(Space);
            StoreD("@tmp", 0);
            AddCodeLine("lds @tmp");
            if (save_d)
                LoadD("@tmp2", 0);
        }
    } else {
        if (CPU != CPU_6800) {
            while(Space > 1) {
                AddCodeLine("pulx");
                Space -= 2;
            }
        }
        while (Space--)
            AddCodeLine("ins");
    }
}


void g_space (int Space, int save_d)
/* Create or drop space on the stack */
{
    /* There are some cases we could save X but not clear they matter FIXME */
    InvalidateX();
    if (Space < 0) {
        /* This is actually a drop operation */
        g_drop (-Space, save_d);
    } else if (Space > 4 * save_d + ((CPU == CPU_6800) ? 18 : 22)) {
        if (save_d)
            StoreD("@tmp2", 0);
        AddCodeLine("sts @tmp");
        AssignD(-Space, 0);
        AddD("@tmp", 0);
        StoreD("@tmp", 0);
        AddCodeLine("lds @tmp");
        if (save_d)
            LoadD("@tmp2", 0);
    } else {
        if (CPU != CPU_6800) {
            while(Space > 1) {
                AddCodeLine("pshx");
                Space -= 2;
            }
        }
        while (Space--)
            AddCodeLine("des");
    }
}


void g_cstackcheck (void)
/* Check for a C stack overflow */
{
    AddCodeLine ("jsr cstkchk");
}

void g_stackcheck (void)
/* Check for a stack overflow */
{
    AddCodeLine ("jsr stkchk");
}

void g_add (unsigned flags, unsigned long val)
/* Primary = TOS + Primary */
{
    static const char* const ops[4] = {
        "tosaddax", "tosaddax", "tosaddeax", "tosaddeax"
    };

    if (flags & CF_CONST) {
        switch (flags & CF_TYPEMASK) {
            case CF_CHAR:
                if (flags & CF_FORCECHAR) {
                    NotViaX();
                    if (val == 1)
                        AddCodeLine("incb");
                    else
                        AddCodeLine("addb #$%02X", (unsigned char) val);
                    break;
                }
                /* Fall through */
            case CF_INT:
                if (flags & CF_USINGX) {
                    if (val == 1) {
                        AddCodeLine("inx");
                        break;
                    }
                    if (val == 2) {
                        AddCodeLine("inx");
                        AddCodeLine("inx");
                        break;
                    }
                    if (val == 3) {
                        AddCodeLine("inx");
                        AddCodeLine("inx");
                        AddCodeLine("inx");
                        break;
                    }
                    if (val == 4) {
                        AddCodeLine("inx");
                        AddCodeLine("inx");
                        AddCodeLine("inx");
                        AddCodeLine("inx");
                        break;
                    }
                    NotViaX();
                } else
                    AddDConst(val);
                break;
            case CF_LONG:
                InvalidateX();
                NotViaX();
                flags &= CF_CONST;
                g_push(flags & ~CF_CONST, 0);
                oper(flags, val, ops);
        }
    } else {
        int offs;
        /* We can optimize some of these in terms of ,x */
        switch (flags & CF_TYPEMASK) {
            case CF_CHAR:
                if (flags & CF_FORCECHAR) {
                    offs = GenTSXByte(1);
                    AddCodeLine ("addb $%02X,x", offs);
                    AddCodeLine ("ins");
                    pop(flags);
                    return;
                }
            /* Fall through */
            case CF_INT:
                offs = GenTSXByte(1);
                AddDViaX(offs);
                PullX(0);
                pop(flags);
                return;
        }
        InvalidateX();
        oper (flags, val, ops);
    }
}



void g_sub (unsigned flags, unsigned long val)
/* Primary = TOS - Primary */
{
    static const char* const ops[4] = {
        "tossubax", "tossubax", "tossubeax", "tossubeax"
    };

    NotViaX();
    if (flags & CF_CONST) {
        /* This shouldn't ever happen as the compiler will turn constant
           subtracts in this form into something else */
        flags &= ~CF_FORCECHAR; /* Handle chars as ints */
        g_push (flags & ~CF_CONST, 0);
    }
    /* It would be nice to spot these higher up and turn them from TOS - Primary
       into negate and add */
    switch(flags & CF_TYPEMASK) {
        case CF_CHAR:
        case CF_INT:
            if (CPU != CPU_6800 && IS_Get(&CodeSizeFactor) >= 50) {
                /* 6 bytes direct versus 3 for call */
                StoreD("@tmp", 0);
                AddCodeLine("pula");
                AddCodeLine("pulb");
                SubD("@tmp", 0);
                pop(flags);
                return;
            }
            /* Else fall through into helper */
    }
    oper (flags, val, ops);
}



void g_rsub (unsigned flags, unsigned long val)
/* Primary = Primary - TOS */
{
    static const char* const ops[4] = {
        "tosrsubax", "tosrsubax", "tosrsubeax", "tosrsubeax"
    };
    if (flags & CF_CONST) {
        switch (flags & CF_TYPEMASK) {
            case CF_CHAR:
                NotViaX();
                if (flags & CF_FORCECHAR) {
                    if (val == 1)
                        AddCodeLine("decb");
                    else
                        AddCodeLine("subb #$%02X", (unsigned char) val);
                    break;
                }
                /* Fall through */
            case CF_INT:
                if (flags & CF_USINGX) {
                    if (val == 1) {
                        AddCodeLine("dex");
                        break;
                    }
                    if (val == 2) {
                        AddCodeLine("dex");
                        AddCodeLine("dex");
                        break;
                    }
                    if (val == 3) {
                        AddCodeLine("dex");
                        AddCodeLine("dex");
                        AddCodeLine("dex");
                        break;
                    }
                    if (val == 4) {
                        AddCodeLine("dex");
                        AddCodeLine("dex");
                        AddCodeLine("dex");
                        AddCodeLine("dex");
                        break;
                    }
                    NotViaX();
                }
                SubDConst(val);
                break;
            case CF_LONG:
                NotViaX();
                flags &= CF_CONST;
                g_push(flags & ~CF_CONST, 0);
                InvalidateX();
                oper(flags, val, ops);
        }
    } else {
        NotViaX();
        InvalidateX();
        oper (flags, val, ops);
    }
}



void g_mul (unsigned flags, unsigned long val)
/* Primary = TOS * Primary */
{
    static const char* const ops[4] = {
        "tosmulax", "tosumulax", "tosmuleax", "tosumuleax"
    };

    int p2;

    NotViaX();
    /* Do strength reduction if the value is constant and a power of two */
    if (flags & CF_CONST && (p2 = PowerOf2 (val)) >= 0) {
        /* Generate a shift instead */
        g_asl (flags, p2);
        return;
    }

    /* FIXME: Spot near powers of two by bit count for add/push/add/pop/add
       sequences ? */
    /* If the right hand side is const, the lhs is not on stack but still
    ** in the primary register.
    */
    if (flags & CF_CONST) {

        switch (flags & CF_TYPEMASK) {

            case CF_CHAR:
                if (flags & CF_FORCECHAR) {
                    /* Handle some special cases */
                    switch (val) {

                        case 3:
                            AddCodeLine ("stab @tmp1");
                            AddCodeLine ("aslb");
                            AddCodeLine ("addb @tmp1");
                            return;

                        case 5:
                            AddCodeLine ("stab @tmp1");
                            AddCodeLine ("aslb");
                            AddCodeLine ("aslb");
                            AddCodeLine ("addb @tmp1");
                            return;

                        case 6:
                            AddCodeLine ("stab @tmp1");
                            AddCodeLine ("aslb");
                            AddCodeLine ("addb @tmp1");
                            AddCodeLine ("aslb");
                            return;

                        case 10:
                            AddCodeLine ("stab @tmp1");
                            AddCodeLine ("aslb");
                            AddCodeLine ("aslb");
                            AddCodeLine ("addb @tmp1");
                            AddCodeLine ("aslb");
                            return;
                    }
                }
                /* FALLTHROUGH */

            case CF_INT:
                InvalidateX();
                switch (val) {
                    case 3:
                        AddCodeLine ("jsr mulax3");
                        return;
                    case 5:
                        AddCodeLine ("jsr mulax5");
                        return;
                    case 6:
                        AddCodeLine ("jsr mulax6");
                        return;
                    case 7:
                        AddCodeLine ("jsr mulax7");
                        return;
                    case 9:
                        AddCodeLine ("jsr mulax9");
                        return;
                    case 10:
                        AddCodeLine ("jsr mulax10");
                        return;
                    case 12:
                        AddCodeLine ("jsr mulax12");
                        return;
                }
                break;

            case CF_LONG:
                break;

            default:
                typeerror (flags);
        }

        /* If we go here, we didn't emit code. Push the lhs on stack and fall
        ** into the normal, non-optimized stuff.
        */
        flags &= ~CF_FORCECHAR; /* Handle chars as ints */
        g_push (flags & ~CF_CONST, 0);

    }

    /* Use long way over the stack */
    InvalidateX();
    oper (flags, val, ops);
}



void g_div (unsigned flags, unsigned long val)
/* Primary = TOS / Primary */
{
    static const char* const ops[4] = {
        "tosdivax", "tosudivax", "tosdiveax", "tosudiveax"
    };

    /* Do strength reduction if the value is constant and a power of two */
    int p2;

    NotViaX();

    if ((flags & CF_CONST) && (p2 = PowerOf2 (val)) >= 0) {
        /* Generate a shift instead */
        g_asr (flags, p2);
    } else {
        /* Generate a division */
        if (flags & CF_CONST) {
            /* lhs is not on stack */
            flags &= ~CF_FORCECHAR;     /* Handle chars as ints */
            g_push (flags & ~CF_CONST, 0);
        }
        InvalidateX();
        oper (flags, val, ops);
    }
}



void g_mod (unsigned flags, unsigned long val)
/* Primary = TOS % Primary */
{
    static const char* const ops[4] = {
        "tosmodax", "tosumodax", "tosmodeax", "tosumodeax"
    };
    int p2;

    NotViaX();
    /* Check if we can do some cost reduction */
    if ((flags & CF_CONST) && (flags & CF_UNSIGNED) && val != 0xFFFFFFFF && (p2 = PowerOf2 (val)) >= 0) {
        /* We can do that with an AND operation */
        g_and (flags, val - 1);
    } else {
        /* Do it the hard way... */
        if (flags & CF_CONST) {
            /* lhs is not on stack */
            flags &= ~CF_FORCECHAR;     /* Handle chars as ints */
            g_push (flags & ~CF_CONST, 0);
        }
        oper (flags, val, ops);
    }
}



void g_or (unsigned flags, unsigned long val)
/* Primary = TOS | Primary */
{
    int offs;
    static const char* const ops[4] = {
        "tosorax", "tosorax", "tosoreax", "tosoreax"
    };

    NotViaX();
    /* If the right hand side is const, the lhs is not on stack but still
    ** in the primary register.
    */
    if (flags & CF_CONST) {

        switch (flags & CF_TYPEMASK) {

            case CF_CHAR:
                if (flags & CF_FORCECHAR) {
                    if ((val & 0xFF) != 0) {
                        AddCodeLine ("orab #$%02X", (unsigned char)val);
                    }
                    return;
                }
                /* FALLTHROUGH */

            case CF_INT:
                val &= 0xFFFF;
            case CF_LONG:
                if (val <= 0xFFFF) {
                    if ((val & 0xFF) != 0)
                        AddCodeLine ("orab #$%02X", (unsigned char)val);
                    if ((val & 0xFF00) != 0)
                        AddCodeLine ("oraa #$%02X", (unsigned char)(val >> 8));
                    return;
                }
                break;

            default:
                typeerror (flags);
        }

        /* If we go here, we didn't emit code. Push the lhs on stack and fall
        ** into the normal, non-optimized stuff. Note: The standard stuff will
        ** always work with ints.
        */
        flags &= ~CF_FORCECHAR;
        g_push (flags & ~CF_CONST, 0);
    }

    /* We can optimize some of these in terms of ,x */
    switch (flags & CF_TYPEMASK) {
        case CF_CHAR:
            if (flags & CF_FORCECHAR) {
                offs = GenTSXByte(1);
                AddCodeLine ("orab $%02X,x", offs);
                AddCodeLine ("ins");
                pop(flags);
                return;
            }
            /* Fall through */
        case CF_INT:
            offs = GenTSXWord(1);
            AddCodeLine ("orab $%02X,x", offs + 1);
            AddCodeLine ("oraa $%02X,x", offs);
            PullX(0);
            pop(flags);
            return;
    }

    /* Use long way over the stack */
    InvalidateX();
    oper (flags, val, ops);
}



void g_xor (unsigned flags, unsigned long val)
/* Primary = TOS ^ Primary */
{
    int offs;
    static const char* const ops[4] = {
        /* Only tosxoreax should ever be generated */
        "tosxorax", "tosxorax", "tosxoreax", "tosxoreax"
    };

    NotViaX();

    /* If the right hand side is const, the lhs is not on stack but still
    ** in the primary register.
    */
    if (flags & CF_CONST) {

        switch (flags & CF_TYPEMASK) {

            case CF_CHAR:
                if (flags & CF_FORCECHAR) {
                    if ((val & 0xFF) != 0) {
                        AddCodeLine ("eorb #$%02X", (unsigned char)val);
                    }
                    return;
                }
                /* FALLTHROUGH */

            case CF_INT:
                val &= 0xFFFF;
            case CF_LONG:
                if (val <= 0xFFFF) {
                    if ((val & 0xFF) != 0)
                        AddCodeLine ("eorb #$%02X", (unsigned char)val);
                    if ((val & 0xFF00) != 0)
                        AddCodeLine ("eora #$%02X", (unsigned char)(val >> 8));
                    return;
                }
                break;

            default:
                typeerror (flags);
        }
        /* If we go here, we didn't emit code. Push the lhs on stack and fall
        ** into the normal, non-optimized stuff. Note: The standard stuff will
        ** always work with ints.
        */
        flags &= ~CF_FORCECHAR;
        g_push (flags & ~CF_CONST, 0);
    }

    /* We can optimize some of these in terms of ,x */
    switch (flags & CF_TYPEMASK) {
        case CF_CHAR:
            if (flags & CF_FORCECHAR) {
                offs = GenTSXByte(1);
                AddCodeLine ("eorb $%02X,x", offs);
                AddCodeLine ("ins");
                pop(flags);
                return;
            }
            /* Fall through */
        case CF_INT:
            offs = GenTSXWord(1);
            AddCodeLine ("eorb $%02X,x", offs + 1);
            AddCodeLine ("eora $%02X,x", offs);
            PullX(0);
            pop(flags);
            return;
    }


    /* Use long way over the stack */
    InvalidateX();
    oper (flags, val, ops);
}

/* Compute the constand and shortest forms */
static void generate_and16(unsigned short val)
{
    unsigned char hi = val >> 8;
    unsigned char lo = val;

    switch(hi) {
        case 0:
            AddCodeLine("clra");
            break;
        case 0xFF:
            break;
        default:
            AddCodeLine("anda #$%02X", hi);
    }
    switch(lo) {
        case 0:
            AddCodeLine("clrb");
            break;
        case 0xFF:
            break;
        default:
            AddCodeLine("andb #$%02X", lo);
    }
}

void g_and (unsigned Flags, unsigned long Val)
/* Primary = TOS & Primary */
{
    int offs;
    static const char* const ops[4] = {
        "tosandax", "tosandax", "tosandeax", "tosandeax"
    };

    NotViaX();
    /* If the right hand side is const, the lhs is not on stack but still
    ** in the primary register.
    */
    if (Flags & CF_CONST) {

        switch (Flags & CF_TYPEMASK) {

            case CF_CHAR:
                if (Flags & CF_FORCECHAR) {
                    if ((Val & 0xFF) == 0x00) {
                        AddCodeLine ("clrb");
                    } else if ((Val & 0xFF) != 0xFF) {
                        AddCodeLine ("andb #$%02X", (unsigned char)Val);
                    }
                    return;
                }
                /* FALLTHROUGH */

            case CF_INT:
                generate_and16(Val);
                return;

            case CF_LONG:
                /* Trap the many common easy 32bit cases we can do inline */
                if (Val <= 0xFFFF) {
                    AddCodeLine("clr @sreg+1");
                    AddCodeLine("clr @sreg");
                    generate_and16(Val);
                    return;
                } else if (Val >= 0xFFFF0000UL) {
                    generate_and16(Val);
                    return;
                } else if (!(Val & 0xFFFF)) {
                    LoadD("@sreg", 0);
                    generate_and16(Val >> 16);
                    StoreD("@sreg", 0);
                    AssignD(0, 0);
                    return;
                }
                break;

            default:
                typeerror (Flags);
        }

        /* If we go here, we didn't emit code. Push the lhs on stack and fall
        ** into the normal, non-optimized stuff. Note: The standard stuff will
        ** always work with ints.
        */
        Flags &= ~CF_FORCECHAR;
        g_push (Flags & ~CF_CONST, 0);
    }
    /* We can optimize some of these in terms of ,x */
    switch (Flags & CF_TYPEMASK) {
        case CF_CHAR:
            if (Flags & CF_FORCECHAR) {
                offs = GenTSXByte(1);
                AddCodeLine ("andb $%02X,x", offs);
                AddCodeLine ("ins");
                pop(Flags);
                return;
            }
            /* Fall through */
        case CF_INT:
            offs = GenTSXWord(1);
            AddCodeLine ("andb $%02X,x", offs + 1);
            AddCodeLine ("anda $%02X,x", offs);
            PullX(0);
            pop(Flags);
            return;
    }


    /* Use long way over the stack */
    InvalidateX();
    oper (Flags, Val, ops);
}



void g_asr (unsigned flags, unsigned long val)
/* Primary = TOS >> Primary */
{
    static const char* const ops[4] = {
        "tosasrax", "tosshrax", "tosasreax", "tosshreax"
    };

    NotViaX();
    InvalidateX();
    /* If the right hand side is const, the lhs is not on stack but still
    ** in the primary register.
    */
    if (flags & CF_CONST) {

        switch (flags & CF_TYPEMASK) {

            case CF_CHAR:
            case CF_INT:
                if (flags & CF_UNSIGNED) {
                    LsrDBy(val);
                    return;
                }
                /* Approximate: varies by shift */
                if (val > 2 && IS_Get(&CodeSizeFactor) < 50) {
                    AddCodeLine ("jsr asrax%d", (unsigned int)val);
                    return;
                }
                val &= 0x0F;
                if (val >= 8) {
                    unsigned L = GetLocalLabel();
                    AddCodeLine ("tab");
                    AddCodeLine ("clra");
                    AddCodeLine ("cmpb #$80");   /* Sign bit into carry */
                    AddCodeLine ("bcc %s", LocalLabelName (L));
                    AddCodeLine ("coma");        /* Make $FF */
                    g_defcodelabel (L);
                    val -= 8;
                }
                if (val > 2) {
                    AddCodeLine ("jsr asrax%d", (unsigned int)val);
                    return;
                }
                while(val--)
                    AsrD();
                return;

            case CF_LONG:
                /* FIXME: we could go with oversize shift = 0 better ? */
                val &= 0x1F;
                if (val >= 24) {
                    AssignX(0);
                    AddCodeLine ("ldab @sreg+1");
                    if ((flags & CF_UNSIGNED) == 0) {
                        unsigned L = GetLocalLabel();
                        AddCodeLine ("bpl %s", LocalLabelName (L));
                        AddCodeLine ("dex");
                        g_defcodelabel (L);
                    }
                    AddCodeLine ("stx @sreg");
                    /* FIXME: overwrites a byte beyond @sreg, but it's worth
                       having a scribble byte I think */
                    AddCodeLine ("stx @sreg+1");
                    val -= 24;
                }
                if (val >= 16) {
                    AssignX(0);
                    LoadD("@sreg", 0);
                    if ((flags & CF_UNSIGNED) == 0) {
                        unsigned L = GetLocalLabel();
                        AddCodeLine ("bpl %s", LocalLabelName (L));
                        AddCodeLine ("dex");
                        g_defcodelabel (L);
                    }
                    AddCodeLine ("stx @sreg");
                    val -= 16;
                }
                if (val >= 8) {
                    if (flags & CF_UNSIGNED) {
                        AddCodeLine ("jsr shreax8");
                    } else {
                        AddCodeLine ("jsr asreax8");
                    }
                    val -= 8;
                }
                if (val >= 4) {
                    if (flags & CF_UNSIGNED) {
                        AddCodeLine ("jsr shreax4");
                    } else {
                        AddCodeLine ("jsr asreax4");
                    }
                    val -= 4;
                }
                if (val > 0) {
                    if (flags & CF_UNSIGNED) {
                        AddCodeLine ("jsr shreax%ld", val);
                    } else {
                        AddCodeLine ("jsr asreax%ld", val);
                    }
                }
                return;

            default:
                typeerror (flags);
        }

        /* If we go here, we didn't emit code. Push the lhs on stack and fall
        ** into the normal, non-optimized stuff. Note: The standard stuff will
        ** always work with ints.
        */
        flags &= ~CF_FORCECHAR;
        g_push (flags & ~CF_CONST, 0);
    }

    /* Use long way over the stack */
    oper (flags, val, ops);
}

void g_asl (unsigned flags, unsigned long val)
/* Primary = TOS << Primary */
{
    static const char* const ops[4] = {
        "tosaslax", "tosshlax", "tosasleax", "tosshleax"
    };

    NotViaX();

    /* If the right hand side is const, the lhs is not on stack but still
    ** in the primary register.
    */
    if (flags & CF_CONST) {

        switch (flags & CF_TYPEMASK) {

            case CF_CHAR:
            case CF_INT:
                AslDBy(val);
                return;

            case CF_LONG:
                val &= 0x1F;
                if (val >= 24) {
                    AddCodeLine ("stab @sreg+1");
                    AddCodeLine ("clrb");
                    AddCodeLine ("clra");
                    AddCodeLine ("stab @sreg");
                    val -= 24;
                }
                if (val >= 16) {
                    StoreD("@sreg", 0);
                    AddCodeLine ("clra");
                    AddCodeLine ("clrb");
                    val -= 16;
                }
                if (val >= 8) {
                    /* One case that is awkward on 6803 */
                    AddCodeLine ("psha");
                    AddCodeLine ("ldaa @sreg+1");
                    AddCodeLine ("staa @sreg");
                    AddCodeLine ("pula");
                    AddCodeLine ("staa @sreg+1");
                    AddCodeLine ("tba");
                    AddCodeLine ("clrb");
                    val -= 8;
                }
                if (val > 4) {
                    InvalidateX();
                    if (flags & CF_UNSIGNED) {
                        AddCodeLine ("jsr shleax4");
                    } else {
                        AddCodeLine ("jsr asleax4");
                    }
                    val -= 4;
                }
                if (val > 0) {
                    InvalidateX();
                    if (flags & CF_UNSIGNED) {
                        AddCodeLine ("jsr shleax%ld", val);
                    } else {
                        AddCodeLine ("jsr asleax%ld", val);
                    }
                }
                return;

            default:
                typeerror (flags);
        }

        /* If we go here, we didn't emit code. Push the lhs on stack and fall
        ** into the normal, non-optimized stuff. Note: The standard stuff will
        ** always work with ints.
        */
        flags &= ~CF_FORCECHAR;
        g_push (flags & ~CF_CONST, 0);
    }

    /* Use long way over the stack */
    InvalidateX();
    oper (flags, val, ops);
}



void g_neg (unsigned Flags)
/* Primary = -Primary */
{
    NotViaX();
    switch (Flags & CF_TYPEMASK) {

        case CF_CHAR:
            if (Flags & CF_FORCECHAR) {
                AddCodeLine ("negb");
                return;
            }
            /* FALLTHROUGH */

        case CF_INT:
            SubDConst(1);
            AddCodeLine ("coma");
            AddCodeLine ("comb");
            break;

        case CF_LONG:
            InvalidateX();
            AddCodeLine ("jsr negeax");
            break;

        default:
            typeerror (Flags);
    }
}



void g_bneg (unsigned flags)
/* Primary = !Primary */
{
    NotViaX();
    InvalidateX();
    switch (flags & CF_TYPEMASK) {

        case CF_CHAR:
            AddCodeLine ("jsr bnega");
            break;

        case CF_INT:
            AddCodeLine ("jsr bnegax");
            break;

        case CF_LONG:
            AddCodeLine ("jsr bnegeax");
            break;

        default:
            typeerror (flags);
    }
}



void g_com (unsigned Flags)
/* Primary = ~Primary */
{
    NotViaX();
    switch (Flags & CF_TYPEMASK) {

        case CF_CHAR:
            if (Flags & CF_FORCECHAR) {
                AddCodeLine ("comb");
                return;
            }
            /* FALLTHROUGH */

        case CF_INT:
            AddCodeLine ("coma");
            AddCodeLine ("comb");
            break;

        case CF_LONG:
            InvalidateX();
            AddCodeLine ("jsr compleax");
            break;

        default:
            typeerror (Flags);
    }
}



void g_inc (unsigned flags, unsigned long val)
/* Increment the primary register by a given number */
{
    unsigned Label;

    /* Don't inc by zero */
    if (val == 0) {
        return;
    }

    /* Generate code for the supported types */
    flags &= ~CF_CONST;
    switch (flags & CF_TYPEMASK) {

        case CF_CHAR:
            if (flags & CF_FORCECHAR) {
                NotViaX();
                if (val == 1)
                    AddCodeLine("incb");
                else
                    AddCodeLine("addb #$%02X", (unsigned char)val);
                break;
            }
            /* FALLTHROUGH */

        case CF_INT:
            if (flags & CF_USINGX) {
                if (val == 1) {
                    AddCodeLine("inx");
                    ModifyX(1);
                    break;
                }
                if (val == 2) {
                    AddCodeLine("inx");
                    AddCodeLine("inx");
                    ModifyX(2);
                    break;
                }
                if (val == 3) {
                    AddCodeLine("inx");
                    AddCodeLine("inx");
                    AddCodeLine("inx");
                    ModifyX(3);
                    break;
                }
                if (val == 4) {
                    AddCodeLine("inx");
                    AddCodeLine("inx");
                    AddCodeLine("inx");
                    AddCodeLine("inx");
                    ModifyX(4);
                    break;
                }
                NotViaX();
            }
            AddDConst(val);
            break;

        case CF_LONG:
            InvalidateX();
            NotViaX();
            Label = GetLocalLabel();
            if (val <= 0xFFFF) {
                AddDConst(val);
                AddCodeLine("bcc %s", LocalLabelName (Label));
                AddCodeLine("ldx @sreg");
                AddCodeLine("inx");
                AddCodeLine("stx @sreg");
                g_defcodelabel (Label);
            } else
                g_add (flags | CF_CONST, val);
            break;

        default:
            typeerror (flags);

    }
}



void g_dec (unsigned flags, unsigned long val)
/* Decrement the primary register by a given number */
{
    unsigned Label;

    /* Don't dec by zero */
    if (val == 0) {
        return;
    }

    /* Generate code for the supported types */
    flags &= ~CF_CONST;
    switch (flags & CF_TYPEMASK) {

        case CF_CHAR:
            if (flags & CF_FORCECHAR) {
                NotViaX();
                if (val == 1)
                    AddCodeLine("decb");
                else
                    AddCodeLine("subb #$%02X", (unsigned char)val);
                break;
            }
            /* FALLTHROUGH */

        case CF_INT:
            if (flags & CF_USINGX) {
                if (val == 1) {
                    AddCodeLine("dex");
                    ModifyX(-1);
                    break;
                }
                if (val == 2) {
                    AddCodeLine("dex");
                    AddCodeLine("dex");
                    ModifyX(-2);
                    break;
                }
                if (val == 3) {
                    AddCodeLine("dex");
                    AddCodeLine("dex");
                    AddCodeLine("dex");
                    ModifyX(-3);
                    break;
                }
                if (val == 4) {
                    AddCodeLine("dex");
                    AddCodeLine("dex");
                    AddCodeLine("dex");
                    AddCodeLine("dex");
                    ModifyX(-4);
                    break;
                }
                NotViaX();
            }
            SubDConst(val);
            break;

        case CF_LONG:
            NotViaX();
            InvalidateX();
            Label = GetLocalLabel();
            if (val <= 0xFFFF) {
                SubDConst(val);
                AddCodeLine("bcc %s", LocalLabelName (Label));
                AddCodeLine("ldx @sreg");
                AddCodeLine("dex");
                AddCodeLine("stx @sreg");
                g_defcodelabel (Label);
            } else
                g_sub (flags | CF_CONST, val);
            break;

        default:
            typeerror (flags);

    }
}

/*
** Following are the conditional operators. They compare the TOS against
** the primary and put a literal 1 in the primary if the condition is
** true, otherwise they clear the primary register
*/



void g_eq (unsigned flags, unsigned long val)
/* Test for equal */
{
    int offs;

    static const char* const ops[4] = {
        "toseqax", "toseqax", "toseqeax", "toseqeax"
    };


    /* FIXME look at x for NULL case only */
    NotViaX();
    /* If the right hand side is const, the lhs is not on stack but still
    ** in the primary register.
    */
    if (flags & CF_CONST) {

        switch (flags & CF_TYPEMASK) {

            case CF_CHAR:
                if (flags & CF_FORCECHAR) {
                    if (val)
                        AddCodeLine ("cmpb #$%02X", (unsigned char)val);
                    else
                        AddCodeLine ("tstb");
                    AddCodeLine ("jsr booleq");
                    return;
                }
                /* FALLTHROUGH */

            case CF_INT:
                SubDConstCompare(val);
                AddCodeLine ("jsr booleq");
                return;

            case CF_LONG:
                break;

            default:
                typeerror (flags);
        }

        /* If we go here, we didn't emit code. Push the lhs on stack and fall
        ** into the normal, non-optimized stuff. Note: The standard stuff will
        ** always work with ints.
        */
        flags &= ~CF_FORCECHAR;
        g_push (flags & ~CF_CONST, 0);
    }
    /* We can optimize some of these in terms of subd ,x */
    switch (flags & CF_TYPEMASK) {
        case CF_CHAR:
            if (flags & CF_FORCECHAR) {
                offs = GenTSXByte(1);
                AddCodeLine ("cmpb $%02X,x", offs);
                AddCodeLine("ins");
                AddCodeLine ("jsr booleq");
                pop(flags);
                return;
            }
            /* Fall through */
        case CF_INT:
            if (CPU != CPU_6800) {
                offs = GenTSXByte(1);
                SubDViaX(offs);
                PullX(0);
                AddCodeLine ("jsr booleq");
                pop(flags);
                return;
            }
            break;
    }

    /* Use long way over the stack */
    oper (flags, val, ops);
}



void g_ne (unsigned flags, unsigned long val)
/* Test for not equal */
{
    int offs;

    static const char* const ops[4] = {
        "tosneax", "tosneax", "tosneeax", "tosneeax"
    };

    /* FIXME look at x for NULL case only */
    NotViaX();
    /* If the right hand side is const, the lhs is not on stack but still
    ** in the primary register.
    */
    if (flags & CF_CONST) {

        switch (flags & CF_TYPEMASK) {

            case CF_CHAR:
                if (flags & CF_FORCECHAR) {
                    if (val)
                        AddCodeLine ("cmpb #$%02X", (unsigned char)val);
                    else
                        AddCodeLine ("tstb");
                    AddCodeLine ("jsr boolne");
                    return;
                }
                /* FALLTHROUGH */

            case CF_INT:
                SubDConstCompare(val);
                AddCodeLine ("jsr boolne");
                return;

            case CF_LONG:
                break;

            default:
                typeerror (flags);
        }

        /* If we go here, we didn't emit code. Push the lhs on stack and fall
        ** into the normal, non-optimized stuff. Note: The standard stuff will
        ** always work with ints.
        */
        flags &= ~CF_FORCECHAR;
        g_push (flags & ~CF_CONST, 0);
    }

    /* We can optimize some of these in terms of subd ,x */
    switch (flags & CF_TYPEMASK) {
        case CF_CHAR:
            if (flags & CF_FORCECHAR) {
                offs = GenTSXByte(1);
                AddCodeLine ("cmpb $%02X,x", offs);
                AddCodeLine ("ins");
                AddCodeLine ("jsr boolne");
                pop(flags);
                return;
            }
            /* Fall through */
        case CF_INT:
            if (CPU != CPU_6800) {
                offs = GenTSXByte(1);
                SubDViaX(offs);
                PullX(0);
                AddCodeLine ("jsr boolne");
                pop(flags);
                return;
            }
    }

    /* Use long way over the stack */
    oper (flags, val, ops);
}



void g_lt (unsigned flags, unsigned long val)
/* Test for less than */
{
    static const char* const ops[4] = {
        "tosltax", "tosultax", "toslteax", "tosulteax"
    };

//    AddCodeLine(";g_lt");
    NotViaX();
    /* If the right hand side is const, the lhs is not on stack but still
    ** in the primary register.
    */
    if (flags & CF_CONST) {

        /* Because the handling of the overflow flag is too complex for
        ** inlining, we can handle only unsigned compares, and signed
        ** compares against zero here.
        */
        if (flags & CF_UNSIGNED) {

            /* Give a warning in some special cases */
            if (val == 0) {
                Warning ("Condition is never true");
                AssignD(0, 0);
                return;
            }

            /* Look at the type */
            switch (flags & CF_TYPEMASK) {

                case CF_CHAR:
                    if (flags & CF_FORCECHAR) {
                        AddCodeLine ("cmpb #$%02X", (unsigned char)val);
                        AddCodeLine ("jsr boolult");
                        return;
                    }
                    /* FALLTHROUGH */

                case CF_INT:
                    SubDConstCompare(val);
                    AddCodeLine ("jsr boolult");
                    return;

                case CF_LONG:
                    /* Do a subtraction */
                    /* TODO */
                    AddCodeLine ("subb #$%02X", (unsigned char)val);
                    AddCodeLine ("sbca #$%02X", (unsigned char)(val >> 8));
                    AddCodeLine ("ldab @sreg+1");
                    AddCodeLine ("sbcb #$%02X", (unsigned char)(val >> 16));
                    AddCodeLine ("ldaa @sreg");
                    AddCodeLine ("sbca #$%02X", (unsigned char)(val >> 24));
                    AddCodeLine ("jsr boolult");
                    return;

                default:
                    typeerror (flags);
            }

        } else if (val == 0) {

            /* A signed compare against zero must only look at the sign bit */
            switch (flags & CF_TYPEMASK) {

                case CF_CHAR:
                    if (flags & CF_FORCECHAR) {
                        AddCodeLine ("aslb");          /* Bit 7 -> carry */
                        AssignD(0, 1);
                        AddCodeLine ("rolb");
                        return;
                    }
                    /* FALLTHROUGH */

                case CF_INT:
                    /* Just check the high byte */
                    AddCodeLine ("asla");           /* Bit 15 -> carry */
                    AssignD(0, 1);
                    AddCodeLine ("rolb");
                    return;

                case CF_LONG:
                    /* Just check the high byte */
                    AddCodeLine ("ldab @sreg+1");
                    AddCodeLine ("aslb");              /* Bit 7 -> carry */
                    AssignD(0, 1);
                    AddCodeLine ("rolb");
                    return;

                default:
                    typeerror (flags);
            }

        } else {

            /* Signed compare against a constant != zero */
            switch (flags & CF_TYPEMASK) {

                case CF_CHAR:
                    if (flags & CF_FORCECHAR) {
                        AddCodeLine ("subb #$%02X", (unsigned int)val);
                        AddCodeLine ("jsr boollt");
                        return;
                    }
                    /* FALLTHROUGH */

                case CF_INT:
                    if (CPU != CPU_6800) {
                        /* Do a subtraction */
                        SubDConst(val);
                        AddCodeLine ("jsr boollt");
                        return;
                    }

                case CF_LONG:
                    /* This one is too costly */
                    break;

                default:
                    typeerror (flags);
            }

        }

        /* If we go here, we didn't emit code. Push the lhs on stack and fall
        ** into the normal, non-optimized stuff. Note: The standard stuff will
        ** always work with ints.
        */
        flags &= ~CF_FORCECHAR;
        g_push (flags & ~CF_CONST, 0);
    }
     else {
        int offs;
        switch (flags & CF_TYPEMASK) {
            case CF_CHAR:
                if (flags & CF_FORCECHAR) {
                    AddCodeLine("tba");
                    AddCodeLine("pulb");
                    AddCodeLine("sba");
                    AddCodeLine("tba");
                    if (flags & CF_UNSIGNED)
                        AddCodeLine ("jsr boolult");
                    else
                        AddCodeLine ("jsr boollt");
                    pop (flags);
                    return;
                }
            case CF_INT:
                if (CPU != CPU_6800) {
                    offs = GenTSXByte(1);
                    StoreD("@tmp", 0);
                    LoadDViaX(offs);
                    PullX(0);
                    SubD("@tmp", 0);
                    if (flags & CF_UNSIGNED)
                        AddCodeLine ("jsr boolult");
                    else
                        AddCodeLine ("jsr boollt");
                    pop (flags);
                    return;
                }
        }
    }
    /* Use long way over the stack */
    oper (flags, val, ops);
}



void g_le (unsigned flags, unsigned long val)
/* Test for less than or equal to */
{
    static const char* const ops[4] = {
        "tosleax", "tosuleax", "tosleeax", "tosuleeax"
    };


    NotViaX();
    /* If the right hand side is const, the lhs is not on stack but still
    ** in the primary register.
    */
    if (flags & CF_CONST) {

        /* Look at the type */
        switch (flags & CF_TYPEMASK) {

            case CF_CHAR:
                if (flags & CF_FORCECHAR) {
                    if (flags & CF_UNSIGNED) {
                        /* Unsigned compare */
                        if (val < 0xFF) {
                            /* Use < instead of <= because the former gives
                            ** better code on the 6502 than the latter.
                            */
                            g_lt (flags, val+1);
                        } else {
                            /* Always true */
                            Warning ("Condition is always true");
                            AddCodeLine ("jsr return1");
                        }
                    } else {
                        /* Signed compare */
                        if ((long) val < 0x7F) {
                            /* Use < instead of <= because the former gives
                            ** better code on the 6502 than the latter.
                            */
                            g_lt (flags, val+1);
                        } else {
                            /* Always true */
                            Warning ("Condition is always true");
                            AddCodeLine ("jsr return1");
                        }
                    }
                    return;
                }
                /* FALLTHROUGH */

            case CF_INT:
                if (flags & CF_UNSIGNED) {
                    /* Unsigned compare */
                    if (val < 0xFFFF) {
                        /* Use < instead of <= because the former gives
                        ** better code on the 6502 than the latter.
                        */
                        g_lt (flags, val+1);
                    } else {
                        /* Always true */
                        Warning ("Condition is always true");
                        AddCodeLine ("jsr return1");
                    }
                } else {
                    /* Signed compare */
                    if ((long) val < 0x7FFF) {
                        g_lt (flags, val+1);
                    } else {
                        /* Always true */
                        Warning ("Condition is always true");
                        AddCodeLine ("jsr return1");
                    }
                }
                return;

            case CF_LONG:
                if (flags & CF_UNSIGNED) {
                    /* Unsigned compare */
                    if (val < 0xFFFFFFFF) {
                        /* Use < instead of <= because the former gives
                        ** better code on the 6502 than the latter.
                        */
                        g_lt (flags, val+1);
                    } else {
                        /* Always true */
                        Warning ("Condition is always true");
                        AddCodeLine ("jsr return1");
                    }
                } else {
                    /* Signed compare */
                    if ((long) val < 0x7FFFFFFF) {
                        g_lt (flags, val+1);
                    } else {
                        /* Always true */
                        Warning ("Condition is always true");
                        AddCodeLine ("jsr return1");
                    }
                }
                return;

            default:
                typeerror (flags);
        }

        /* If we go here, we didn't emit code. Push the lhs on stack and fall
        ** into the normal, non-optimized stuff. Note: The standard stuff will
        ** always work with ints.
        */
        flags &= ~CF_FORCECHAR;
        g_push (flags & ~CF_CONST, 0);
    }
    else {
        int offs;
        switch (flags & CF_TYPEMASK) {
            case CF_CHAR:
                if (flags & CF_FORCECHAR) {
                    AddCodeLine("tba");
                    AddCodeLine("pulb");
                    AddCodeLine("sba");
                    AddCodeLine("tba");
                    if (flags & CF_UNSIGNED)
                        AddCodeLine ("jsr boolule");
                    else
                        AddCodeLine ("jsr boolle");
                    pop (flags);
                    return;
                }
            case CF_INT:
                if (CPU != CPU_6800) {
                    offs = GenTSXByte(1);
                    StoreD("@tmp", 0);
                    LoadDViaX(offs);
                    PullX(0);
                    SubD("@tmp", 0);
                    if (flags & CF_UNSIGNED)
                        AddCodeLine ("jsr boolule");
                    else
                        AddCodeLine ("jsr boolle");
                    InvalidateX();
                    pop (flags);
                    return;
                }
        }
    }
    /* Use long way over the stack */
    oper (flags, val, ops);
}



void g_gt (unsigned flags, unsigned long val)
/* Test for greater than */
{
    static const char* const ops[4] = {
        "tosgtax", "tosugtax", "tosgteax", "tosugteax"
    };


    NotViaX();
    /* If the right hand side is const, the lhs is not on stack but still
    ** in the primary register.
    */
    if (flags & CF_CONST) {

        /* Look at the type */
        switch (flags & CF_TYPEMASK) {

            case CF_CHAR:
                if (flags & CF_FORCECHAR) {
                    if (flags & CF_UNSIGNED) {
                        if (val == 0) {
                            /* If we have a compare > 0, we will replace it by
                            ** != 0 here, since both are identical but the
                            ** latter is easier to optimize.
                            */
                            g_ne (flags, val);
                        } else if (val < 0xFF) {
                            /* Use >= instead of > because the former gives
                            ** better code on the 6502 than the latter.
                            */
                            g_ge (flags, val+1);
                        } else {
                            /* Never true */
                            Warning ("Condition is never true");
                            AssignD(0, 0);
                        }
                    } else {
                        if ((long) val < 0x7F) {
                            /* Use >= instead of > because the former gives
                            ** better code on the 6502 than the latter.
                            */
                            g_ge (flags, val+1);
                        } else {
                            /* Never true */
                            Warning ("Condition is never true");
                            AssignD(0, 0);
                        }
                    }
                    return;
                }
                /* FALLTHROUGH */

            case CF_INT:
                if (flags & CF_UNSIGNED) {
                    /* Unsigned compare */
                    if (val == 0) {
                        /* If we have a compare > 0, we will replace it by
                        ** != 0 here, since both are identical but the latter
                        ** is easier to optimize.
                        */
                        g_ne (flags, val);
                    } else if (val < 0xFFFF) {
                        /* Use >= instead of > because the former gives better
                        ** code on the 6502 than the latter.
                        */
                        g_ge (flags, val+1);
                    } else {
                        /* Never true */
                        Warning ("Condition is never true");
                        AssignD(0, 0);
                    }
                } else {
                    /* Signed compare */
                    if ((long) val < 0x7FFF) {
                        g_ge (flags, val+1);
                    } else {
                        /* Never true */
                        Warning ("Condition is never true");
                        AssignD(0, 0);
                    }
                }
                return;

            case CF_LONG:
                if (flags & CF_UNSIGNED) {
                    /* Unsigned compare */
                    if (val == 0) {
                        /* If we have a compare > 0, we will replace it by
                        ** != 0 here, since both are identical but the latter
                        ** is easier to optimize.
                        */
                        g_ne (flags, val);
                    } else if (val < 0xFFFFFFFF) {
                        /* Use >= instead of > because the former gives better
                        ** code on the 6502 than the latter.
                        */
                        g_ge (flags, val+1);
                    } else {
                        /* Never true */
                        Warning ("Condition is never true");
                        AssignD(0, 0);
                    }
                } else {
                    /* Signed compare */
                    if ((long) val < 0x7FFFFFFF) {
                        g_ge (flags, val+1);
                    } else {
                        /* Never true */
                        Warning ("Condition is never true");
                        AssignD(0, 0);
                    }
                }
                return;

            default:
                typeerror (flags);
        }

        /* If we go here, we didn't emit code. Push the lhs on stack and fall
        ** into the normal, non-optimized stuff. Note: The standard stuff will
        ** always work with ints.
        */
        flags &= ~CF_FORCECHAR;
        g_push (flags & ~CF_CONST, 0);
    }
    else {
        int offs;
        switch (flags & CF_TYPEMASK) {
            case CF_CHAR:
                if (flags & CF_FORCECHAR) {
                    AddCodeLine("tba");
                    AddCodeLine("pulb");
                    AddCodeLine("sba");
                    AddCodeLine("tba");
                    if (flags & CF_UNSIGNED)
                        AddCodeLine ("jsr boolugt");
                    else
                        AddCodeLine ("jsr boolgt");
                    pop (flags);
                    return;
                }
            case CF_INT:
                if (CPU != CPU_6800) {
                    offs = GenTSXByte(1);
                    StoreD("@tmp", 0);
                    LoadDViaX (offs);
                    PullX(0);
                    SubD("@tmp", 0);
                    if (flags & CF_UNSIGNED)
                        AddCodeLine ("jsr boolugt");
                    else
                        AddCodeLine ("jsr boolgt");
                    pop (flags);
                    return;
                }
        }
    }
    /* Use long way over the stack */
    oper (flags, val, ops);
}

void g_ge (unsigned flags, unsigned long val)
/* Test for greater than or equal to */
{
    static const char* const ops[4] = {
        "tosgeax", "tosugeax", "tosgeeax", "tosugeeax"
    };


    NotViaX();

    /* If the right hand side is const, the lhs is not on stack but still
    ** in the primary register.
    */
    if (flags & CF_CONST) {

        /* Because the handling of the overflow flag is too complex for
        ** inlining, we can handle only unsigned compares, and signed
        ** compares against zero here.
        */
        if (flags & CF_UNSIGNED) {

            /* Give a warning in some special cases */
            if (val == 0) {
                Warning ("Condition is always true");
                AddCodeLine ("jsr return1");
                return;
            }

            /* Look at the type */
            switch (flags & CF_TYPEMASK) {

                case CF_CHAR:
                    if (flags & CF_FORCECHAR) {
                        /* Do a subtraction. Condition is true if carry or z set */
                        AddCodeLine ("cmpb #$%02X", (unsigned char)val);
                        /* Do not usr clr as it clears carry */
                        AddCodeLine ("jsr booluge");
                        return;
                    }
                    /* FALLTHROUGH */

                case CF_INT:
                    /* Do a subtraction. Condition is true if carry clear */
                    SubDConst(val);
                    AddCodeLine ("jsr booluge");
                    return;

                case CF_LONG:
                    /* Do a subtraction. Condition is true if carry clear */
                    SubDConst(val);
                    AddCodeLine ("ldab @sreg");
                    AddCodeLine ("sbcb #$%02X", (unsigned char)(val >> 16));
                    AddCodeLine ("ldab @sreg+1");
                    AddCodeLine ("sbcb #$%02X", (unsigned char)(val >> 24));
                    AddCodeLine ("jsr booluge");
                    return;

                default:
                    typeerror (flags);
            }

        } else if (val == 0) {

            /* A signed compare against zero must only look at the sign bit */
            switch (flags & CF_TYPEMASK) {

                case CF_CHAR:
                    if (flags & CF_FORCECHAR) {
                        AddCodeLine ("comb");
                        AddCodeLine ("rolb");
                        AddCodeLine ("ldab #0");
                        AddCodeLine ("rolb");
                        return;
                    }
                    /* FALLTHROUGH */

                case CF_INT:
                    /* Just test the high byte */
                    AddCodeLine ("coma");
                    AddCodeLine ("rola");
                    AssignD(0, 1);
                    AddCodeLine ("rolb");
                    return;

                case CF_LONG:
                    /* TODO 6303 can use TIM */
                    /* Just test the high byte */
                    AddCodeLine ("ldab @sreg+1");
                    AddCodeLine ("comb");
                    AddCodeLine ("rolb");
                    AssignD(0, 1);
                    AddCodeLine ("rolb");
                    return;

                default:
                    typeerror (flags);
            }

        } else {

            /* Signed compare against a constant != zero */
            switch (flags & CF_TYPEMASK) {

                case CF_CHAR:
                    if (flags & CF_FORCECHAR) {
                        AddCodeLine ("subb #$%02X", (unsigned char)val);
                        if (flags & CF_UNSIGNED)
                            AddCodeLine ("jsr booluge");
                        else
                            AddCodeLine ("jsr boolge");
                        return;
                    }
                    /* FALLTHROUGH */

                case CF_INT:
                    /* Do a subtraction */
                    SubDConstCompare(val);
                    if (flags & CF_UNSIGNED)
                        AddCodeLine ("jsr booluge");
                    else
                        AddCodeLine ("jsr boolge");
                    return;

                case CF_LONG:
                    /* This one is too costly */
                    break;

                default:
                    typeerror (flags);
            }
        }

        /* If we go here, we didn't emit code. Push the lhs on stack and fall
        ** into the normal, non-optimized stuff. Note: The standard stuff will
        ** always work with ints.
        */
        flags &= ~CF_FORCECHAR;
        g_push (flags & ~CF_CONST, 0);
    }
    else {
        int offs;
        switch (flags & CF_TYPEMASK) {
            case CF_CHAR:
                if (flags & CF_FORCECHAR) {
                    AddCodeLine("tba");
                    AddCodeLine("pulb");
                    AddCodeLine("sba");
                    AddCodeLine("tba");
                    if (flags & CF_UNSIGNED)
                        AddCodeLine ("jsr booluge");
                    else
                        AddCodeLine ("jsr boolge");
                    pop (flags);
                    return;
                }
            case CF_INT:
                if (CPU != CPU_6800) {
                    offs = GenTSXByte(1);
                    StoreD("@tmp", 0);
                    LoadDViaX (offs);
                    PullX(0);
                    SubD("@tmp", 0);
                    if (flags & CF_UNSIGNED)
                        AddCodeLine ("jsr booluge");
                    else
                        AddCodeLine ("jsr boolge");
                    pop (flags);
                    return;
                }
        }
    }
    /* Use long way over the stack */
    oper (flags, val, ops);
}



/*****************************************************************************/
/*                         Allocating static storage                         */
/*****************************************************************************/


/* TODO: BSS v DATA v CONST */

void g_res (unsigned n)
/* Reserve static storage, n bytes */
{
    AddDataLine ("\t.blkb\t%u", n);
}



void g_defdata (unsigned flags, unsigned long val, long offs)
/* Define data with the size given in flags */
{
    if (flags & CF_CONST) {

        /* Numeric constant */
        switch (flags & CF_TYPEMASK) {

            case CF_CHAR:
                AddDataLine ("\t.byte\t$%02lX", val & 0xFF);
                break;

            case CF_INT:
                AddDataLine ("\t.word\t$%04lX", val & 0xFFFF);
                break;

            case CF_LONG:
                AddDataLine ("\t.word\t$%04lX", (val >> 16) & 0xFFFF);
                AddDataLine ("\t.word\t$%04lX", val & 0xFFFF);
                break;

            default:
                typeerror (flags);
                break;

        }

    } else {

        /* Create the correct label name */
        const char* Label = GetLabelName (flags, val, offs);

        /* Labels are always 16 bit */
        AddDataLine ("\t.word\t%s", Label);

    }
}



void g_defbytes (const void* Bytes, unsigned Count)
/* Output a row of bytes as a constant */
{
    unsigned Chunk;
    char Buf [128];
    char* B;

    /* Cast the buffer pointer */
    const unsigned char* Data = (const unsigned char*) Bytes;

    /* Output the stuff */
    while (Count) {

        /* How many go into this line? */
        if ((Chunk = Count) > 16) {
            Chunk = 16;
        }
        Count -= Chunk;

        /* Output one line */
        strcpy (Buf, "\t.byte\t");
        B = Buf + 7;
        do {
            B += sprintf (B, "$%02X", *Data++);
            if (--Chunk) {
                *B++ = ',';
            }
        } while (Chunk);

        /* Output the line */
        AddDataLine ("%s", Buf);
    }
}



void g_zerobytes (unsigned Count)
/* Output Count bytes of data initialized with zero */
{
    if (Count > 0) {
        AddDataLine ("\t.blkb\t%u", Count);
    }
}



void g_initregister (unsigned Label, unsigned Reg, unsigned Size)
/* Initialize a register variable from static initialization data */
{
    /* Register variables do always have less than 128 bytes */
    while(Size > 1) {
        Size -= 2;
        LoadD(GetLabelName(CF_STATIC, Label, 0), Size);
        StoreD(GetLabelName(CF_REGVAR, Reg, 0), Size);
    }
    if (Size) {
        AddCodeLine("ldab %s", GetLabelName(CF_STATIC, Label, 0));
        AddCodeLine("stab %s", GetLabelName(CF_REGVAR, Reg, 0));
    }
}


/* FIXME: we want to move away from this to psh/pop of constant bits */
void g_initauto (unsigned Label, unsigned Size)
/* Initialize a local variable at stack offset zero from static data */
{
#if 0
    unsigned CodeLabel = GetLocalLabel ();
    /* FIXME */
    if (Size <= 128) {
        AddCodeLine ("ldy #$%02X", Size-1);
        g_defcodelabel (CodeLabel);
        AddCodeLine ("lda %s,y", GetLabelName (CF_STATIC, Label, 0));
        AddCodeLine ("sta (sp),y");
        AddCodeLine ("dey");
        AddCodeLine ("bpl %s", LocalLabelName (CodeLabel));
    } else if (Size <= 256) {
        AddCodeLine ("ldy #$00");
        g_defcodelabel (CodeLabel);
        AddCodeLine ("lda %s,y", GetLabelName (CF_STATIC, Label, 0));
        AddCodeLine ("sta (sp),y");
        AddCodeLine ("iny");
        AddCmpCodeIfSizeNot256 ("cpy #$%02X", Size);
        AddCodeLine ("bne %s", LocalLabelName (CodeLabel));
    }
#endif
}



void g_initstatic (unsigned InitLabel, unsigned VarLabel, unsigned Size)
/* Initialize a static local variable from static initialization data */
{
    if (Size <= 8) {
        while(Size > 1) {
            Size -= 2;
            LoadD(GetLabelName(CF_STATIC, InitLabel, 0), Size);
            StoreD(GetLabelName(CF_STATIC, VarLabel, 0), Size);
        }
        if (Size) {
            AddCodeLine("ldab %s", GetLabelName(CF_STATIC, InitLabel, 0));
            AddCodeLine("stab %s", GetLabelName(CF_STATIC, VarLabel, 0));
        }
    } else {
        if (CPU == CPU_6800) {
            g_getimmed(CF_STATIC, VarLabel, 0);
            AddCodeLine("pshb");
            AddCodeLine("psha");
            g_getimmed(CF_STATIC, InitLabel, 0);
            AddCodeLine("pshb");
            AddCodeLine("psha");
            g_getimmed (CF_INT | CF_UNSIGNED | CF_CONST, Size, 0);
            AddCodeLine("pshb");
            AddCodeLine("psha");
        } else {
            /* Use the easy way here: memcpy() */
            InvalidateX();
            g_getimmed (CF_USINGX|CF_STATIC, VarLabel, 0);
            AddCodeLine ("pshx");
            InvalidateX();
            g_getimmed (CF_STATIC|CF_USINGX, InitLabel, 0);
            AddCodeLine ("pshx");
            InvalidateX();
            g_getimmed (CF_USINGX |CF_INT | CF_UNSIGNED | CF_CONST, Size, 0);
            AddCodeLine ("pshx");
        }
        AddCodeLine ("jsr %s", GetLabelName (CF_EXTERNAL, (uintptr_t) "memcpy", 0));
        PullX(0);
        PullX(0);
        PullX(0);
    }
}


/* For one byte registers we end up saving an extra byte. It avoids having
   to touch D so who cares. We don't allow long registers */

void g_save_regvar(int Offset, int Reg, unsigned Size)
{
    if (CPU == CPU_6800) {
        AddCodeLine("ldaa @reg+%u", Reg);
        AddCodeLine("ldab @reg+%u", Reg + 1);
        AddCodeLine("pshb");
        AddCodeLine("psha");
    } else {
        AddCodeLine("ldx @reg+%u", Reg);
        AddCodeLine("pshx");
        InvalidateX();
    }
    push(CF_INT);
    NotViaX();
}

void g_restore_regvar(int Offset, int Reg, unsigned Size)
{
    AddCodeLine(";offset %d\n", Offset);
    PullX(1);
    AddCodeLine("stx @reg+%u", Reg);
    pop(CF_INT);
    InvalidateX();
    NotViaX();
}

/*****************************************************************************/
/*                             Switch statement                              */
/*****************************************************************************/



void g_switch (Collection* Nodes, unsigned DefaultLabel, unsigned Depth)
/* Generate code for a switch statement */
{
    unsigned NextLabel = 0;
    unsigned I;

    NotViaX();
    InvalidateX();

    /* Setup registers and determine which compare insn to use */
    const char* Compare;
    switch (Depth) {
        case 1:
            Compare = "cmpb #$%02X";
            break;
        case 2:
            Compare = "cmpa #$%02X";
            break;
        case 3:
            AddCodeLine ("psha");
            AddCodeLine ("ldaa @sreg");
            Compare = "cmpa #$%02X";
            break;
        case 4:
            AddCodeLine ("psha");
            AddCodeLine ("ldaa @sreg+1");
            Compare = "cmpa #$%02X";
            break;
        default:
            Internal ("Invalid depth in g_switch: %u", Depth);
    }

    /* Walk over all nodes */
    for (I = 0; I < CollCount (Nodes); ++I) {

        /* Get the next case node */
        CaseNode* N = CollAtUnchecked (Nodes, I);

        /* If we have a next label, define it */
        if (NextLabel) {
            g_defcodelabel (NextLabel);
            NextLabel = 0;
        }

        /* Do the compare */
        AddCodeLine (Compare, CN_GetValue (N));
        if (Depth > 2)
            AddCodeLine("pula");

        /* If this is the last level, jump directly to the case code if found */
        if (Depth == 1) {

            /* Branch if equal */
            g_falsejump (0, CN_GetLabel (N));

        } else {

            /* Determine the next label */
            if (I == CollCount (Nodes) - 1) {
                /* Last node means not found */
                g_truejump (0, DefaultLabel);
            } else {
                /* Jump to the next check */
                NextLabel = GetLocalLabel ();
                g_truejump (0, NextLabel);
            }

            /* Check the next level */
            g_switch (N->Nodes, DefaultLabel, Depth-1);

        }
    }

    /* If we go here, we haven't found the label */
    g_jump (DefaultLabel);
}



/*****************************************************************************/
/*                       Optimizer Hinting                                   */
/*****************************************************************************/

void g_statement(void)
{
    if (XState & XSTATE_VALID)
        AddCodeLine(";invalid DP");
    else
        AddCodeLine(";invalid XDP");
}

/*****************************************************************************/
/*                       User supplied assembler code                        */
/*****************************************************************************/



void g_asmcode (struct StrBuf* B)
/* Output one line of assembler code. */
{
    AddCodeLine ("%.*s", (int) SB_GetLen (B), SB_GetConstBuf (B));
}
