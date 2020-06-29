/*
* This file contains routines for all code generation except
* expressions.
*/

#include "pass2.h"
#include "il.h"

extern int revcon, nxtlab;
extern char *nexts(), dvalid;
extern char namebuf[10];
extern char brntyp;
extern int retlab;
extern int reguse;
extern int lretlab;
extern char optc;
extern char opts;
extern char optf;

/* The main I file processing loop. */

loop() {
  int byte, number, value;
  int number2;
  int strsiz;
  char infobuf[100];
  register char *p;
  char ch;

  while((byte = nextc()) != EOF) {
    switch (byte) {
      case BEGMOD: /* Begin module */
        outcode(" name %s\n", nexts(namebuf));
        break;
      case BEGEXP: /* Begin expression */
        if (optc)
          outcode("* Begin expression - %u\n", nextw());
        else
          nextw();
        doexp();
        break;
      case BEGFNT: /* Begin function */
        nexts(namebuf);
        strsiz = nextw();
        outcode("%s pshs u,y\n leay 2,s\n", namebuf);
        dvalid = '\0';
        lretlab = retlab = 0;
        break;
      case ENDFNT: /* End function */
        value = nextw();
        nextw();
        if (value & 0x30)
          outcode(" tfr x,d\n");
        outcode(" leas -2,y\n puls y,u,pc\n");
        if (lretlab)
          outcode(" bss\nL%u rmb 4\n text\n", lretlab);
        break;
      case TEXT: /* Text segment */
        outcode(" text\n");
        break;
      case DATA: /* Data segment */
        outcode(" data\n");
        break;
      case BSS: /* Bss segment */
        outcode(" bss\n");
        break;
      case GLOBAL: /* Global variable definition */
        outcode(" global %s\n", nexts(namebuf));
        break;
      case BEGBLK: /* Begin block */
        if ((number = nextw()) == 0)
          break;
        if (opts == 0)
          outcode(" leax -(L%u+256),s\n cmpx stk_base\n bhs 1f\n jsr grows\n1\n", number);
        outcode(" leas -L%u,s\n", number);
        if (!retlab)
          retlab = number-1;
        break;
      case ENDBLK: /* End block */
        number = nextw();
        value = nextw() + 2;
        byte = nextc();
        if (number == 0)
          break;
        outcode("L%u equ %u\n", number, value);
        break;
      case ENDMOD: /* End module */
        outcode(" end\n");
        break;
      case STVAR: /* String variable description */
        number = nextw();
        if (optc)
          outcode("* Static %s L%u\n", nexts(namebuf), number);
        else
          nexts(namebuf);
        break;
      case AUTVAR: /* Auto variable description */
        number = nextw();
        if (optc)
          outcode("* Auto %d %s\n", number, nexts(namebuf));
        else
          nexts(namebuf);
        break;
      case REGVAR: /* Register variable description */
        number = nextw();
        if (optc)
          outcode("* Register %d %s\n", number, nexts(namebuf));
        else
          nexts(namebuf);
        break;
      case SSPACE: /* Save space */
        outcode(" rmb %u\n", nextw());
        break;
      case DNAME: /* Data name */
        outcode("%s", nexts(namebuf));
        break;
      case BRANCH: /* Branch (GOTO) */
        outcode(" lbra L%u\n", nextw());
        break;
      case CBRNCH: /* Conditional branch */
        if (nextc() != 0)
          byte = BTRUE;
        else
          byte = BFALSE;
        brntyp = REGLAB;
        gbrnch(byte, nextw());
        break;
      case LABEL: /* Generate label */
        outcode("L%u\n", nextw());
        dvalid = '\0';
        break;
      case BYTES: /* Data bytes */
        value = 0;
        for(number = nextc(); number > 0; number--) {
          if ((value & 0xF) == 0)
            outcode(" fcb ");
          if (((value & 0xF) == 0xF) || (number == 1))
            outcode("%u\n", nextc());
          else
            outcode("%u,", nextc());
          value++;
        }
        break;
      case WORDS: /* Data words */
        value = 0;
        for(number = nextc(); number > 0; number--) {
          if ((value & 0xF) == 0)
            outcode(" fdb ");
          if (((value & 0xF) == 0xF) || (number == 1))
            outcode("%u\n", nextw());
          else
            outcode("%u,", nextw());
          value++;
        }
        break;
      case LONGS: /* Data longs */
        value = 0;
        for(number = nextc(); number > 0; number--) {
          number2 = nextw();
          if ((value & 0x7) == 0)
            outcode(" fdb ");
          if (((value & 0x7) == 0x7) || (number == 1))
            outcode("%u,%u\n", number2, nextw());
          else
            outcode("%u,%u,", number2, nextw());
          value++;
        }
        break;
      case STRNG: /* String data */
        value = 0;
        outcode("L%u", nextw());
        while(1) {
          number = nextc();
          if ((value & 0xF) == 0)
            outcode(" fcb ");
          if (((value & 0xF) == 0xF) || (number == 0))
            outcode("%u\n", number);
          else
            outcode("%u,", number);
          value++;
          if (number == 0)
            break;
        }
        break;
      case SWIT: /* Generate switch statement code */
        outswit();
        break;
      case LABELS: /* Generate code with labels */
        outcode(" fdb ");
        for (value = nextc(); value != 0; value--) {
          switch( nextc() ) {
            case 0:
              number = nextw();
              outcode("L%u", nextw());
              if (number != 0)
                outcode("+%u", number);
              break;
            case 1:
              outcode("%u", nextw());
              break;
            case 2:
              number = nextw();
              outcode("%s", nexts(namebuf));
              if (number != 0)
                outcode("+%u", number);
              break;
            default:
              badfile();
          }
          if (value != 1)
            outcode(",");
        }
        outcode("\n");
        break;
      case EVEN:
        break;
      case CMNT:
        p = infobuf;
        while (ch = nextc()) {
          if (ch == EOF)
            badfile();
          *p++ = ch;
          if (p == &infobuf[98]) {
            *p = 0;
            outcode("%s", infobuf);
            p = infobuf;
          }
        }
        if (p != infobuf) {
          *p = 0;
          outcode("%s", infobuf);
        }
        break;
      default:
        perror("Illegal intermediate token encountered - ");
        perror("Pass 2 aborted!\n");
        abort();
    }
  }
}

/* Generate next local label value */

genlab() {
  return(++nxtlab);
}

/* Generate switch code */

outswit() {
  int count, swline, swdefl, swtrml;
  int swlpl, swlabl, swlstl;
  register int *swptr;
  int swtlst[MAXSWT*4];

  swline = nextw();
  swdefl = nextw();
  dvalid = '\0';
  if ((swtrml = swdefl) == 0)
    swtrml = genlab();
  swlpl = genlab();
  swlabl = genlab();
  swlstl = genlab();
  for(swptr = swtlst; (*swptr++ = nextw()) != 0; *swptr++ = nextw());
  if (optf) {
    swptr = swtlst;
    while (*swptr) {
      outcode(" cmpd #%d\n lbeq L%u\n", *(swptr+1), *swptr);
      swptr += 2;
    }
    if (swdefl)
      outcode(" lbra L%u\n", swdefl);
  }
  else {
    outcode(" ldx #L%u\n std L%u\n",swlstl, swlabl);
    outcode("L%u cmpd 0,x++\n bne L%u\n", swlpl, swlpl);
    outcode(" jmp [L%u-L%u,x]\n data\n",swlabl, swlstl);
    outcode("L%u ", swlstl);
    swptr = swtlst;
    count = 0;
    while (*swptr++ != 0) {
      if ((count & 0xF) == 0)
        outcode(" fdb ");
      if (((count & 0xF) == 0xF) || ( *(swptr+1) == 0))
        outcode("%u\n", *swptr++);
      else
        outcode("%u,", *swptr++);
      count++;
    }
    outcode("L%u fdb 0\n", swlabl);
    count = 0;
    swptr = swtlst;
    while (*swptr != 0) {
      if ((count & 0xF) == 0)
        outcode(" fdb ");
      if (((count & 0xf) == 0xF) && ( *(swptr+2) != 0))
        outcode("L%u\n", *swptr++);
      else
        outcode("L%u,", *swptr++);
      count++;
      swptr++;
    }
    if (swdefl != 0)
      outcode("L%u\n", swdefl);
    else {
      outcode("L%u\n", swtrml);
      outcode(" text\nL%u\n", swtrml);
    }
  }
}
