/*
* This file contains the general expression setup for code
* production from expressions.
*/

#include "pass2.h"
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
extern char enclev;

/* Entry routine for processing expressions */

doexp() {

  filexp();
  initexp();
  replcnd();
  simpbra();
  explev = 0;
  while (explev < lstlev) {
    doentry();
    explev++;
  }
  if (stksiz)
    clnstk(stksiz);
}

/* Initialize all variables for generating expression code */

initexp() {
  struct addreg *ptr;

/*  for(ptr = adregs; ptr < &adregs[NUMADR]; *ptr++ = 0); */
  for (ptr = adregs; ptr < &adregs[NUMADR]; ptr++)
    ptr->ar_ref = 0;
  revcon = stklev = stksiz = 0;
  enclev = 0;
  condit = NE;
  sawcnd = brntyp = unscom = '\0';
/*if (!dvalid) */
    ccok = '\0';
  dcont = NULL;
  xcont = NULL;
  localv = 9;
  orp = orstk;
  andp = andstk;
  cndp = cndstk;
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
    ep->rtype = expw();
    ep->rslt = 0;
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
  }
  if (i == MAXEXP) {
    perror("Intermediate expression too complex - pass2 aborted.\n");
    exit(255);
  }
  rtrnc( filbrs(tok, i) );
}

/* Get an operand from the I file and place in matrix entry */

getopr(tok, p)
int tok;
struct operand *p;
{
  int i, *cptr;
  register struct operand *ptr;

  ptr = p;
  ptr->optype = tok;
  switch (tok) {
    case NNAME:
      ptr->opkind.name.nclass = expb();
      ptr->opkind.name.ntype = expw();
      if (ptr->opkind.name.nclass == EXTN) {
        for (i=0; i<8; i++) {
          if ((ptr->opkind.name.ndata.namext[i] = expb()) == 0)
            break;
        }
        if (i == 8)
          while (expb() != 0);
      }
      else
        ptr->opkind.name.ndata.nampos = expw();
      break;
    case NCON:
      ptr->opkind.cons.ctype = expb();
      cptr = &ptr->opkind.cons.cdata;
      ptr->opkind.cons.cdata.cint = expw();
      cptr++;
      if (ptr->opkind.cons.ctype > UNSND)
        *cptr++ = expw();
      if (ptr->opkind.cons.ctype == DUBLE) {
        *cptr++ = expw();
        *cptr = expw();
      }
      break;
    case NNODE:
      ptr->opkind.node.nnum = expw();
      break;
    default:
      badfile();
  }
}

/* Continue filling matrix with branch and label ops from I file */

filbrs(tok, i)
int i, tok;
{
  register struct express *ptr;

  for (; (tok >= LABEL) && (tok <= CBRNCH) && (i < MAXEXP); i++) {
    ptr = &exptbl[i];
    ptr->op2.optype = '\0';
    ptr->op1.optype = '\0';
    switch (tok) {
      case LABEL:
        ptr->operator = LBL;
        ptr->op1.opkind.lbl.lnum = expw();
        ptr->op1.opkind.lbl.ltype = 1;
        break;
      case BRANCH:
        ptr->operator = BRX;
        ptr->op1.opkind.brx.bxcon = 2;
        ptr->op1.opkind.brx.bxtyp = 1;
        ptr->op1.opkind.brx.bxlnum = expw();
        break;
      case CBRNCH:
        ptr->operator = BRX;
        ptr->op1.opkind.brx.bxcon = expb();
        ptr->op1.opkind.brx.bxtyp = 1;
        ptr->op1.opkind.brx.bxlnum = expw();
        break;
    }
    tok = expb();
  }
  if ((lstlev = i) == MAXEXP) {
    perror("Expression table overflow - pass2 aborted.\n");
    exit(255);
  }
  ptr = &exptbl[i];
  ptr->operator = '\0';
  ptr->op1.optype ='\0';
  ptr->op2.optype = '\0';
  return(tok);
}

/* Generate code for one expression matrix entry */

doentry() {

  locop1 = locate(&exptbl[explev].op1);
  locop2 = locate(&exptbl[explev].op2);
  curopr = exptbl[explev].operator & 0xff;
  curtyp = exptbl[explev].rtype;
  if (curopr <= NOP)
    switch(curopr) {
      case NOP:
        nop();
        break;
      default:
        cvt();
        break;
    }
  else if (curopr <= COM && curopr >= FPP)
    switch (curopr) {
      case FPP:
        fpp();
        break;
      case FMM:
        fmm();
        break;
      case BPP:
        bpp();
        break;
      case BMM:
        bmm();
        break;
      case NOT:
        not();
        break;
      case ADR:
        adr();
        break;
      case IND:
        ino();
        break;
      case UNM:
        unm();
        break;
      case COM:
        com();
        break;
    }
  else if (curopr <= XOR && curopr >= ADD)
    switch(curopr) {
      case ADD:
        add();
        break;
      case SUB:
        sub();
        break;
      case MUL:
        mul();
        break;
      case DIV:
        div();
        break;
      case MOD:
        mod();
        break;
      case SHR:
        shr();
        break;
      case SHL:
        shl();
        break;
      case AND:
        and();
        break;
      case BOR:
        bor();
        break;
      case XOR:
        xor();
        break;
    }
  else if (curopr <= GRT && curopr >= EQU)
    cnd();
  else if (curopr <= ASN && curopr >= ADA)
    switch(curopr) {
      case ASN:
        asn();
        break;
      default:
        opasn();
        break;
    }
  else if (curopr <= OZT && curopr >= OZF)
    switch(curopr) {
      case OZR:
        ozr();
        break;
      case OZF:
        ozf();
        break;
      case OZT:
        ozt();
        break;
    }
  else if (curopr <= SAV && curopr >= DOT)
    switch(curopr) {
      case DOT:
        dot();
        break;
      case CAL:
        cal();
        break;
      case PRM:
        prm();
        break;
      case LOD:
      case SWT:
        lod();
        break;
      case ENC:
        enc();
        break;
      case RET:
        ret();
        break;
      case SPL:
        spl();
        break;
      case SPR:
        spr();
        break;
      case CMA:
        cma();
        break;
      case SAV:
        sav();
        break;
    }
  else if (curopr <= LBL && curopr >= BRX)
    switch(curopr) {
      case BRX:
        brx();
        break;
      case BLX:
        blx();
        break;
      case LBL:
        lbl();
        break;
    }
  else {
    perror("Bad ifile - pass2 aborted!\n");
    abort();
  }
}

/* Locate and classify the operand at opptr */

locate(opptr)
struct operand *opptr;
{
  int i,j;
  register struct addreg *arptr;

  switch(opptr->optype & 0xff) {
    case NNODE:
      return(exptbl[opptr->opkind.node.nnum-1].rslt);
    case NCON:
      arptr = &adregs[i=getar()];
      arptr->ar_ref = CREF;
      arptr->ar_ind = -1;
      arptr->ar_con = &opptr->opkind.cons.cdata;
      return(0x80 | i);
    case NNAME:
      arptr = &adregs[i=getar()];
      j = (opptr->opkind.name.ntype & 0x30) >> 4;
      if (j == ARAY || j == FNCT)
        arptr->ar_ind = -1;
      switch(opptr->opkind.name.nclass) {
        case AUTO:
          arptr->ar_ref = ADRREG + YREG;
          arptr->ar_data.ad_val = opptr->opkind.name.ndata.nampos;
          return(0x80 | i);
        case STAT:
          arptr->ar_ref = LREF;
          arptr->ar_data.ad_val = opptr->opkind.name.ndata.nampos;
          return(0x80 | i);
        case REG:
          arptr->ar_ref = ADRREG + UREG;
          arptr->ar_ind = -1;
          return( 0x80 | i);
        case EXTN:
          arptr->ar_ref = NREF;
          for (j=0; j<8; j++)
            arptr->ar_data.ad_nam[j] = opptr->opkind.name.ndata.namext[j];
          return( 0x80 | i);
        case MOS:
        case MOU:
          arptr->ar_ref = CREF;
          arptr->ar_con = &opptr->opkind.name.ndata.nampos;
          return(0x80 | i);
        default:
          perror("Bad operand!\n");
          abort();
      }
    default:
      return(0);
  }
}

/* Get an available address register from the list */

getar() {
  int i, j;
  register struct addreg *ptr;
  char *pc;

  ptr = adregs;
  for( i=0; i<NUMADR; i++) {
    if (ptr->ar_ref == 0) {
      pc = &adregs[i];
      for (j=0; j<sizeof(struct addreg); j++)
        *pc++ = '\0';
      return(i);
      }
    ptr++;
  }
  perror("Fatal addressing error!\n");
  abort();
}
