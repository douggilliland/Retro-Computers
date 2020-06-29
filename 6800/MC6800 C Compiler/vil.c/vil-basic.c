/*
* This file contains routines for all code generation except
* expressions.
*/

#include "vil.h"
#include "il.h"

extern int revcon, nxtlab;
extern char *nexts(), dvalid;
extern char namebuf[10];
extern char brntyp;
extern int retlab;

/* The main I file processing loop. */

loop() {
  int byte, number, value;
  int number2;
  char *strptr;

  while((byte = nextc()) != EOF) {
    switch (byte) {
      case BEGMOD: /* Begin module */
        outcode(" Begin module - %s\n", nexts(namebuf));
        break;
      case BEGEXP: /* Begin expression */
        outcode("* Begin expression - %u\n", nextw());
        doexp();
        break;
      case BEGFNT: /* Begin function */
        strptr = nexts(namebuf);
        number = nextw();
        outcode(" Start function %s - %u\n", strptr, number);
        break;
      case ENDFNT: /* End function */
        outcode(" End function  ");
        otyp(nextw());
        number = nextw();
        outcode(" AR=%d  DR=%d\n", number>>8, number&0xff);
        break;
      case TEXT: /* Text segment */
        outcode(" Text\n");
        break;
      case DATA: /* Data segment */
        outcode(" Data\n");
        break;
      case BSS: /* Bss segment */
        outcode(" Bss\n");
        break;
      case GLOBAL: /* Global variable definition */
        outcode(" Global %s\n", nexts(namebuf));
        break;
      case BEGBLK: /* Begin block */
        outcode(" Enter block %d\n", nextw());
        break;
      case ENDBLK: /* End block */
        number = nextw();
        value = nextw();
        outcode(" End block %d %d %d\n",number,value,nextc());
        break;
      case ENDMOD: /* End module */
        outcode(" End module\n");
        break;
      case STVAR: /* String variable description */
        number = nextw();
        outcode(" Static %d %s\n",number, nexts(namebuf));
        break;
      case AUTVAR: /* Auto variable description */
        number = nextw();
        outcode(" Auto %d %s\n",number, nexts(namebuf));
        break;
      case REGVAR: /* Register variable description */
        number = nextw();
        outcode(" Register %d %s\n", number, nexts(namebuf));
        break;
      case SSPACE: /* Save space */
#ifdef BIG
        number = nextw();
        outcode(" Variable space %u %u\n", number, nextw());
#else
        outcode(" Variable space %u\n", nextw());
#endif
        break;
      case DNAME: /* Data name */
        outcode(" Data name %s\n", nexts(namebuf));
        break;
      case BRANCH: /* Branch (GOTO) */
        outcode(" Branch L%u\n", nextw());
        break;
      case CBRNCH: /* Conditional branch */
        number = nextc();
        outcode(" Cbranch %u L%u\n", number, nextw());
        break;
      case LABEL: /* Generate label */
        outcode("L%u\n", nextw());
        break;
      case BYTES: /* Data bytes */
        outcode(" Byte data -");
        for(number = nextc(); number > 0; number--) {
          outcode(" %d", nextc());
        }
        outcode("\n");
        break;
      case WORDS: /* Data words */
        outcode(" Word data -");
        for(number = nextc(); number > 0; number--) {
          outcode(" %d", nextw());
        }
        outcode("\n");
        break;
      case STRNG: /* String data */
        number = nextw();
        outcode(" String %u \"%s\"\n", number, nexts(namebuf));
        break;
      case SWIT: /* Generate switch statement code */
        number = nextw();
        outcode(" Switch %u %u\n", number, nextw());
#ifdef BIG
        while (value=nextw(), number=nextw()) {
          number2 = nextw();
          outcode("   %u %u, %u %u\n", value,number,number2,nextw());
        }
#else
        while (value = nextw())
          outcode("   %u, %u\n", value, nextw());
#endif
        break;
      case LABELS: /* Generate code with labels */
        outcode(" Label data - ");
        for (value = nextc(); value != 0; value--) {
          switch( nextc() ) {
            case 0:
#ifdef BIG
              number2 = nextw();
#endif
              number = nextw();
              outcode("L%u", nextw());
              if (number != 0)
                outcode("+%u", number);
              break;
            case 1:
#ifdef BIG
              number2 = nextw();
#endif
              outcode("%u", nextw());
              break;
            case 2:
#ifdef BIG
              number2 = nextw();
#endif
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
      case LONGS: /* Data longs */
        outcode(" Long data -");
        for(number = nextc(); number > 0; number--) {
          number2 = nextw();
          outcode("  %u %u", number2, nextw());
        }
        outcode("\n");
        break;
      case EVEN:
        outcode(" Even\n");
        break;
      case CMNT:
        outcode("* Start Info\n%s* End Info\n", nexts(namebuf));
        break;
      case FPV:
        outcode("* Floating point variables in module\n");
        break;
      default:
        perror("Illegal intermediate token encountered - ");
        perror("Pass 2 aborted!\n");
        abort(byte, namebuf);
    }
  }
}

