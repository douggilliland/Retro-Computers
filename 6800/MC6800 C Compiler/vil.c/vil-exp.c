/*
* This file contains the general expression setup for code
* production from expressions.
*/

#include "vil.h"
#include "il.h"

extern int revcon;
extern char *nexts();
extern char namebuf[10], sawcnd, dvalid;
extern struct express exptbl[];
extern struct addreg adregs[];
extern int lstlev, explev;
extern int locop1, locop2;
extern int curopr, curtyp;
extern int stklev, stksiz, condit;
extern char ccok, brntyp, unscom;
extern struct express *dcont;
extern struct addreg *xcont;
extern int localv, *orp, *andp, *cndp;
extern int andstk[], orstk[], cndstk[];

/* operator names array */

char *opnames[] = {
  "xxx",
  "xxx",
  "xxx",
  "xxx",
  "xxx",
  "CVT", /* 5 */
  "xxx",
  "xxx",
  "xxx",
  "xxx",
  "xxx",
  "xxx",
  "xxx",
  "xxx",
  "xxx",
  "xxx",
  "xxx",
  "xxx",
  "xxx",
  "xxx",
  "xxx",
  "xxx",
  "xxx",
  "xxx",
  "xxx",
  "xxx",
  "xxx",
  "xxx",
  "xxx", /* 28 */
  "NOP",
  "++O",
  "--O",
  "O++",
  "O--",
  " ! ",
  " &O",
  " *O",
  " -O",
  " ~O",
  "xxx", /* 39 */
  " + ",
  " - ",
  " * ",
  " / ",
  " % ",
  " >>",
  " <<",
  " & ",
  " | ",
  " ^ ", /*49 */
  "xxx",
  "xxx",
  "xxx",
  " &&",
  " ||",
  "xxx",
  "xxx",
  "xxx",
  "xxx",
  "xxx", /* 59 */
  " ==",
  " !=",
  " <=",
  " < ",
  " >=",
  " > ",
  "xxx",
  "xxx",
  "xxx",
  "xxx", /* 69 */
  " +=",
  " -=",
  " *=",
  " /=",
  " %=",
  ">>=",
  "<<=",
  " &=",
  " |=",
  " ^=",
  " = ", /* 80 */
  "xxx",
  "xxx",
  "xxx",
  "xxx",
  "xxx",
  "xxx",
  "OZF",
  "OZR",
  "OZT", /* 89 */
  "CXB",
  "CBR",
  "CEN",
  "ORB",
  "ORE",
  "ANB",
  "ANE",
  "ORC",
  "ANC",
  " . ", /* 99 */
  "CAL",
  "PSH",
  "LOD",
  "SPL",
  "SPR",
  "CMA",
  "RET",
  "SWT",
  "ENC",
  "SIZ",
  "BEX",
  "BCL",
  "BXC",
  "SAV"
};

/* type names array */

char *tpnames[] = {
  "vod",
  "xxx",
  "chr",
  "uch",
  "shr",
  "ush",
  "int",
  "uns",
  "lng",
  "uln",
  "flt",
  "dbl",
  "str",
  "unn",
  "enm",
  "con"
};

/* class names array */

char *clnames[] = {
  "xxx",
  "aut",
  "stc",
  "reg",
  "ext",
  "typ",
  "xxx",
  "xxx",
  "stt",
  "unt",
  "ent",
  "xxx",
  "mos",
  "mou",
  "moe"
};

/* Entry routine for processing expressions */

doexp() {

  filexp();
}

/* Fill the expression matrix from the I file */

filexp() {
  register char *ptr;
  int tok, i;
  struct operand *opptr;
  struct express *ep;

/*ptr = &exptbl[0];
  while (ptr < &exptbl[MAXEXP])
    *ptr++ = 0; */
  tok = expb();
  for (i=0; (i < MAXEXP) && (tok < ENDITM); i++) {
    ep = &exptbl[i];
    ep->op1.optype = '\0';
    ep->op2.optype = '\0';
    ep->operator = tok;
    outcode("    ( %u )  \"%s\" ", i+1, opnames[tok]);
    ep->rtype = expw();
    otyp(ep->rtype);
    tok = expb();
    if ((tok >= NNAME) && (tok <= NNODE)) {
      opptr = &ep->op1;
      getopr(tok, opptr);
      tok = expb();
      if ((tok >= NNAME) && (tok <= NNODE)) {
        opptr = &ep->op2;
        getopr(tok, opptr);
        tok = expb();
      }
    }
    outcode("\n");
  }
  if (i == MAXEXP) {
    perror("Intermediate expression too complex - pass2 aborted.\n");
    exit(255);
  }
  rtrnc(tok);
}

/* Get an operand from the I file and place in matrix entry */

getopr(tok, p)
int tok;
struct operand *p;
{
  int i, *cptr;
  register struct operand *ptr;
  int tc;

  ptr = p;
  ptr->optype = tok;
  switch (tok) {
    case NNAME:
      outcode("Var ");
      tc = expb();
      ocls(tc);
      otyp(expw());
      if (tc == EXTN) {
        outcode("%s ", nexts(namebuf));
      }
      else
        outcode("%d ", expw());
      break;
    case NCON:
      outcode("Con ");
      i = expb();
      otyp(i);
      outcode("%d ", expw());
      if ((i>UNSND) || (SIZINT==4))
        outcode("%d ", expw());
      if (i == DUBLE) {
        outcode("%d ", expw());
        outcode("%d ", expw());
      }
      break;
    case NNODE:
      outcode("Node %u ", expw());
      break;
    default:
      badfile();
  }
}

/* output type specifier */

otyp(tp) {
  int i;
  unsigned ct;

  ct = tp>>4;
  ct &= 0xfff;
  while (ct & 0x03) {
    switch (ct & 3) {
      case 1:
        outcode("p");
        break;
      case 2:
        outcode("f");
        break;
      case 3:
        outcode("a");
        break;
    }
    ct >>= 2;
  }
  outcode("-%s ", tpnames[tp & 0x0f]);
}

/* output class */

ocls(c) {
  outcode("%s ", clnames[c]);
}
