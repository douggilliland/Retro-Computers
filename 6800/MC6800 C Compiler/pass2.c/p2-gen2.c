#include "pass2.h"
/*
* This file has the routine to generate code for most of the
* binary operators.
*/

#include "il.h"

extern int locop1, locop2, explev;
extern struct express exptbl[];
extern struct addreg adregs[];
extern char ccok, dvalid;
extern struct express *dcont;
extern int curtyp;
extern int stksiz, stklev;

/* Generate code for addition. */

add() {
  struct addreg *p1;
  register struct addreg *p2;
  int i;
  int tp;

  switch (curtyp & 0xfffe) {
    case CHR:
      if ((locop1 & 0xf0) != DATREG) {
        switch (where()) {
          case 1:
          case 3:
          case 6:
            i = locop1;
            locop1 = locop2;
            locop2 = i;
        }
      }
      loadc(locop1);
      finar(locop2);
      ccok++;
      outcode(" addb ");
      genadr(locop2 & (NUMADR-1));
      dvalid = '\0';
      rsltb();
      break;
    case SHORT:
    case INT:
      if ((locop1 & 0xf0) != DATREG) {
        switch (where()) {
          case 1:
          case 3:
          case 6:
            i = locop1;
            locop1 = locop2;
            locop2 = i;
        }
      }
      loadi(locop1);
      finar(locop2);
      ccok++;
      outcode(" addd ");
      genadr(locop2 & (NUMADR-1));
      dvalid = '\0';
      rsltd();
      break;
    case LONG:
      slong(locop1);
      slong(locop2);
      outcode(" jsr addlong\n");
      slrslt();
      sclnlong();
      ccok = 0;
      break;
    default: /* pointer */
      ptrloc1();
      p2 = &adregs[locop2 & (NUMADR-1)];
      if ((locop2 & ARREF) && p2->ar_ref==CREF) {
        setoff(*p2->ar_con, locop1 & (NUMADR-1));
        p2->ar_ref = 0;
      }
      else {
        if ((tp = typeop(&exptbl[explev].op2)) < SHORT) {
          loadc(locop2);
          setofr(OFFB, locop1 & (NUMADR-1));
        }
        else if (tp < LONG) {
          loadi(locop2);
          setofr(OFFD, locop1 & (NUMADR-1));
        }
        else {
          slong(locop2);
          outcode(" ldd 2,s\n leas 4,s\n");
          stksiz -= 4;
          stklev--;
          rsltd();
          setofr(OFFD, locop1 & (NUMADR-1));
          ccok++;
        }
        dcont = locop1;
      }
      setrslt(locop1);
      break;
  }
}

/* Generate code for subtraction */

sub() {
  struct addreg *p1;
  register struct addreg *p2;
  int i;
  int tp;

  if (typeop(&exptbl[explev].op2) & 0x30)
    ptrsub();
  else {
    switch (curtyp & 0xfffe) {
      case CHR:
        i = where();
        ccok++;
        switch (i) {
          case 1:
          case 3:
          case 6:
            loadc(locop2);
            finar(locop1);
            outcode(" negb\n addb ");
            genadr(locop1 & (NUMADR-1));
            break;
          default:
            loadc(locop1);
            finar(locop2);
            outcode(" subb ");
            genadr(locop2 & (NUMADR-1));
            break;
        }
        dvalid = '\0';
        rsltb();
        break;
      case SHORT:
      case INT:
        ccok++;
        switch (where()) {
          case 1:
            loadi(locop2);
          case 3:
            finar(locop1);
            outcode(" nega\n negb\n sbca #0\n addd ");
            genadr(locop1 & (NUMADR-1));
            break;
          default:
            loadi(locop1);
            finar(locop2);
            outcode(" subd ");
            genadr(locop2 & (NUMADR-1));
            break;
        }
        dvalid = '\0';
        rsltd();
        break;
      case LONG:
        i = slong(locop1);
        i = i | (slong(locop2) << 1);
        if (i < 2)
          outcode(" jsr sublong\n");
        else
          outcode(" jsr rsublong\n");
        slrslt();
        sclnlong();
        ccok = 0;
        break;
      default:
        p2 = &adregs[locop2 & (NUMADR-1)];
        if (p2->ar_ref == CREF)
          setoff(-*p2->ar_con, locop1 & (NUMADR-1));
        else {
          if ((tp = typeop(&exptbl[explev].op2)) < SHORT) {
            loadc(locop2);
            outcode(" negb\n");
            setofr(OFFB, locop1 & (NUMADR-1));
          }
          else if (tp < LONG) {
            loadi(locop2);
            outcode(" nega\n negb\n sbca #0\n");
            setofr(OFFD, locop1 & (NUMADR-1));
          }
          else {
            slong(locop2);
            outcode(" ldd 2,s\n leas 4,s\n");
            stksiz -= 4;
            stklev--;
            rsltd();
            outcode(" nega\n negb\n sbca #0\n");
            setofr(OFFD, locop1 & (NUMADR-1));
            ccok++;
          }
          dvalid = 0;
          dcont = locop1;
        }
        setrslt(locop1);
        break;
    }
  }
}

/* Generate code for pointer minus pointer operation. */

ptrsub() {
  register struct addreg *p1, *p2;
  int ref1, ref2;

  p1 = &adregs[locop1 & (NUMADR-1)];
  p2 = &adregs[locop2 & (NUMADR-1)];
  p1->ar_ind++;
  p2->ar_ind++;
  finarx(locop1);
  finarx(locop2);
  p1->ar_ind--;
  p2->ar_ind--;
  ref1 = p1->ar_ref;
  ref2 = p2->ar_ref;
  if (ref1==(ADRREG|XREG) || ref1==(ADRREG|UREG)) {
    tfrxd();
    ref2 = p2->ar_ref;
    if (ref2==(ADRREG|XREG))
      freex();
    else if (ref2==(ADRREG|UREG))
      stacku(locop2);
  }
  else {
    loadi(locop1);
    if (ref2==(ADRREG|XREG) || ref2==(ADRREG|UREG)) {
      if (ref2==(ADRREG|XREG))
        freex();
      else
        stacku(locop2);
    }
    else
      finar(locop2);
  }
  ccok++;
  outcode(" subd ");
  genadr(locop2 & (NUMADR-1));
  dvalid = '\0';
  rsltd();
}

/* Generate code for multiply */

mul() {
  int i, j;

  i = where();
  j = 0;
  if (curtyp & UNS)
    j++;
  switch (curtyp & 0xfffe) {
    case CHR:
      break;
    case SHORT:
    case INT:
      switch (i) {
        case 5:
        case 6:
        case 7:
          loadi(locop1);
        case 4:
          ipush();
        case 1:
          loadi(locop2);
          break;
/*      case 6:
          loadi(locop2);  */
        case 3:
          ipush();
        case 2:
          loadi(locop1);
          break;
      }
      if (j)
        outcode(" jsr umul\n");
      else
        outcode(" jsr imul\n");
      clntwo();
      ccok++;
      dvalid = '\0';
      rsltd();
      break;
    case LONG:
      slong(locop1);
      slong(locop2);
      if (j)
        outcode(" jsr umullong\n");
      else
        outcode(" jsr mullong\n");
      slrslt();
      sclnlong();
      ccok = 0;
      break;
  }
}

/* Generate code for divide. */

div() {
  int i, j;
  char r;

  i = where();
  j = 0;
  r = '\0';
  if (curtyp & UNS)
    j++;
  switch (curtyp & 0xfffe) {
    case CHR:
      break;
    case SHORT:
    case INT:
      switch (i) {
        case 5:
        case 7:
          loadi(locop1);
        case 4:
          ipush();
        case 1:
          loadi(locop2);
          break;
        case 6:
          loadi(locop2);
        case 3:
          ipush();
        case 2:
          loadi(locop1);
          r++;
          break;
      }
      if (j)
        if (r)
          outcode(" jsr urdiv\n");
        else
          outcode(" jsr udiv\n");
      else
        if (r)
          outcode(" jsr irdiv\n");
        else
          outcode(" jsr idiv\n");
      clntwo();
      ccok++;
      dvalid = '\0';
      rsltd();
      break;
    case LONG:
      i = slong(locop1);
      i = i | (slong(locop2) << 1);
      if (i < 2) {
        if (j)
          outcode(" jsr udivlong\n");
        else
          outcode(" jsr divlong\n");
      }
      else {
        if (j)
          outcode(" jsr rudivlong\n");
        else
          outcode(" jsr rdivlong\n");
      }
      slrslt();
      sclnlong();
      ccok = 0;
      break;
  }
}

/* Generate code for the MOD operator */

mod() {
  int i, j;
  char r;

  i = where();
  j = 0;
  r = '\0';
  if (curtyp & UNS)
    j++;
  switch (curtyp & 0xfffe) {
    case CHR:
      break;
    case SHORT:
    case INT:
      switch (i) {
        case 5:
        case 7:
          loadi(locop1);
        case 4:
          ipush();
        case 1:
          loadi(locop2);
          break;
        case 6:
          loadi(locop2);
        case 3:
          ipush();
        case 2:
          loadi(locop1);
          r++;
          break;
      }
      if (j)
        if (r)
          outcode(" jsr urmod\n");
        else
          outcode(" jsr umod\n");
      else
        if (r)
          outcode(" jsr irmod\n");
        else
          outcode(" jsr imod\n");
      clntwo();
      ccok++;
      dvalid = '\0';
      rsltd();
      break;
    case LONG:
      i = slong(locop1);
      i = i | (slong(locop2) << 1);
      if (i < 2) {
        if (j)
          outcode(" jsr umodlong\n");
        else
          outcode(" jsr modlong\n");
      }
      else {
        if (j)
          outcode(" jsr rumodlong\n");
        else
          outcode(" jsr rmodlong\n");
      }
      slrslt();
      sclnlong();
      ccok = 0;
      break;
  }
}

/* Generate code for shift right operation. */

shr() {
  int i, j, con, didcon;
  char r;

  i = where();
  j = didcon = 0;
  r = '\0';
  if (curtyp & UNS)
    j++;
  switch (curtyp & 0xfffe) {
    case CHR:
    case SHORT:
    case INT:
      switch (i) {
        case 5:
        case 7:
          if (curtyp < SHORT) {
            loadc(locop1);
            if (curtyp & UNS)
              outcode(" clra\n");
            else
              outcode(" sex\n");
          }
          else
            loadi(locop1);
          if (i==7) {
            con = *adregs[locop2 & (NUMADR-1)].ar_con;
            if (con>=8 && con<=11) {
              outcode(" tfr a,b\n");
              if (j)
                outcode(" clra\n");
              else
                outcode(" sex\n");
              ccok = 0;
              con -= 8;
            }
            if (!con) {
              didcon++;
              break;
            }
            if (con <= 4) {
              while (con--) {
                if (j)
                  outcode(" lsra\n rorb\n");
                else
                  outcode(" asra\n rorb\n");
              }
              ccok = 0;
              didcon++;
              break;
            }
          }
        case 4:
          if (curtyp < SHORT)
            if (curtyp & UNS)
              outcode(" clra\n");
            else
              outcode(" sex\n");
          ipush();
        case 1:
          loadi(locop2);
          break;
        case 6:
          loadi(locop2);
        case 3:
          ipush();
        case 2:
          if (curtyp < SHORT) {
            loadc(locop1);
            if (curtyp & UNS)
              outcode(" clra\n");
            else
              outcode(" sex\n");
          }
          else
            loadi(locop1);
          r++;
          break;
      }
      if (!didcon) {
        if (j)
          if (r)
            outcode(" jsr urshr\n");
          else
            outcode(" jsr ushr\n");
        else
          if (r)
            outcode(" jsr irshr\n");
          else
            outcode(" jsr ishr\n");
        clntwo();
        ccok++;
      }
      dvalid = '\0';
      rsltd();
      break;
    case LONG:
      loadc(locop2);
      slong(locop1);
      if (j)
        outcode(" jsr ushrlong\n");
      else
        outcode(" jsr shrlong\n");
      slrslt();
      clnlong();
      ccok = 0;
      break;
  }
}

/* Generate code for shift left operator. */

shl() {
  int i, j, con, didcon;
  char r;

  i = where();
  j = didcon = 0;
  r = '\0';
  if (curtyp & UNS)
    j++;
  switch (curtyp & 0xfffe) {
    case CHR:
    case SHORT:
    case INT:
      switch (i) {
        case 5:
        case 7:
          if (curtyp < SHORT) {
            loadc(locop1);
            if (curtyp & UNS)
              outcode(" clra\n");
            else
              outcode(" sex\n");
          }
          else
            loadi(locop1);
          if (i==7) {
            con = *adregs[locop2 & (NUMADR-1)].ar_con;
            if (con>=8 && con<=11) {
              outcode(" tfr b,a\n clrb\n");
              ccok = 0;
              con -= 8;
            }
            if (!con) {
              didcon++;
              break;
            }
            if (con <= 4) {
              while (con--) {
                outcode(" lslb\n rola\n");
              }
              ccok = 0;
              didcon++;
              break;
            }
          }
        case 4:
          if (curtyp < SHORT)
            if (curtyp & UNS)
              outcode(" clra\n");
            else
              outcode(" sex\n");
          ipush();
        case 1:
          loadi(locop2);
          break;
        case 6:
          loadi(locop2);
        case 3:
          ipush();
        case 2:
          if (curtyp < SHORT) {
            loadc(locop1);
            if (curtyp & UNS)
              outcode(" clra\n");
            else
              outcode(" sex\n");
          }
          else
            loadi(locop1);
          r++;
          break;
      }
      if (!didcon) {
        if (r)
          outcode(" jsr irshl\n");
        else
          outcode(" jsr ishl\n");
        clntwo();
        ccok++;
      }
      dvalid = '\0';
      rsltd();
      break;
    case LONG:
      loadc(locop2);
      slong(locop1);
      if (j)
        outcode(" jsr ushllong\n");
      else
        outcode(" jsr shllong\n");
      slrslt();
      clnlong();
      ccok = 0;
      break;
  }
}

/* Generate code for bit wise and operator */

and() {
  int i;
  char flag;

  switch(curtyp & 0xfffe) {
    case CHR:
      switch (where()) {
        case 1:
        case 3:
        case 6:
          i = locop1;
          locop1 = locop2;
          locop2 = i;
      }
      loadc(locop1);
      finar(locop2);
      ccok++;
      outcode(" andb ");
      genadr(locop2 & (NUMADR-1));
      dvalid = '\0';
      rsltb();
      break;
    case SHORT:
    case INT:
      flag = 0;
      switch (where()) {
        case 7:
          loadi(locop1);
          finar(locop2);
          i = *adregs[locop2 & (NUMADR-1)].ar_con;
          if ((i & 0xff00) == 0) {
            if (spcland())
              flag++;
            else
              outcode(" clra\n");
            ccok = 0;
            if (i != 0xff) {
              outcode(" andb #$%x\n", i);
              ccok++;
            }
          }
          else if ((i & 0xff) == 0) {
            outcode(" clrb\n");
            ccok = 0;
            if (i != 0xff00) {
              outcode(" anda #$%x\n", (i>>8) & 0xff);
              ccok++;
            }
          }
          else {
            if ((i & 0xff00) != 0xff00)
              outcode(" anda #$%x\n", (i>>8) & 0xff);
            if ((i & 0xff) != 0xff)
              outcode(" andb #$%x\n", i & 0xff);
            ccok = 0;
          }
          dvalid = '\0';
          if (flag)
            rsltb();
          else
            rsltd();
          break;
        case 1:
        case 3:
        case 6:
          i = locop1;
          locop1 = locop2;
          locop2 = i;
        default:
          loadi(locop1);
          finar(locop2);
          bitadr("and");
          rsltd();
          break;
      }
      break;
    case LONG:
      slong(locop1);
      slong(locop2);
      outcode(" jsr andlong\n");
      slrslt();
      sclnlong();
      ccok = 0;
      break;
  }
}

/* Generate code for bit wise or operator */

bor() {
  int i;

  switch(curtyp & 0xfffe) {
    case CHR:
      switch (where()) {
        case 1:
        case 3:
        case 6:
          i = locop1;
          locop1 = locop2;
          locop2 = i;
      }
      loadc(locop1);
      finar(locop2);
      ccok++;
      outcode(" orb ");
      genadr(locop2 & (NUMADR-1));
      dvalid = '\0';
      rsltb();
      break;
    case SHORT:
    case INT:
      switch (where()) {
        case 7:
          loadi(locop1);
          finar(locop2);
          i = *adregs[locop2 & (NUMADR-1)].ar_con;
          if ((i & 0xff00) == 0) {
            outcode(" orb #$%x\n", i);
            ccok++;
          }
          else if ((i & 0xff) == 0) {
            outcode(" ora #$%x\n", (i>>8) & 0xff);
            ccok++;
          }
          else {
            outcode(" ora #$%x\n", (i>>8) & 0xff);
            outcode(" orb #$%x\n", i & 0xff);
            ccok = 0;
          }
          dvalid = '\0';
          rsltd();
          break;
        case 1:
        case 3:
        case 6:
          i = locop1;
          locop1 = locop2;
          locop2 = i;
        default:
          loadi(locop1);
          finar(locop2);
          bitadr("or");
          rsltd();
          break;
      }
      break;
    case LONG:
      slong(locop1);
      slong(locop2);
      outcode(" jsr borlong\n");
      slrslt();
      sclnlong();
      ccok = 0;
      break;
  }
}

/* Generate code for exclusive or operator. */

xor() {
  int i;

  switch(curtyp & 0xfffe) {
    case CHR:
      switch (where()) {
        case 1:
        case 3:
        case 6:
          i = locop1;
          locop1 = locop2;
          locop2 = i;
      }
      loadc(locop1);
      finar(locop2);
      ccok++;
      outcode(" eorb ");
      genadr(locop2 & (NUMADR-1));
      dvalid = '\0';
      rsltb();
      break;
    case SHORT:
    case INT:
      switch (where()) {
        case 7:
          loadi(locop1);
          finar(locop2);
          i = *adregs[locop2 & (NUMADR-1)].ar_con;
          if ((i & 0xff00) == 0) {
            if (i != 0xff)
              outcode(" eorb #$%x\n", i);
            else
              outcode(" comb\n");
            ccok++;
          }
          else if ((i & 0xff) == 0) {
            if (i != 0xff00)
              outcode(" eora #$%x\n", (i>>8) & 0xff);
            else
              outcode(" coma\n");
            ccok++;
          }
          else {
            if ((i & 0xff00) != 0xff00)
              outcode(" eora #$%x\n", (i>>8) & 0xff);
            else
              outcode(" coma\n");
            if ((i & 0xff) != 0xff)
              outcode(" eorb #$%x\n", i & 0xff);
            else
              outcode(" comb\n");
            ccok = 0;
          }
          dvalid = '\0';
          rsltd();
          break;
        case 1:
        case 3:
        case 6:
          i = locop1;
          locop1 = locop2;
          locop2 = i;
        default:
          loadi(locop1);
          finar(locop2);
          bitadr("eor");
          rsltd();
          break;
      }
      break;
    case LONG:
      slong(locop1);
      slong(locop2);
      outcode(" jsr xorlong\n");
      slrslt();
      sclnlong();
      ccok = 0;
      break;
  }
}

/* Check if operands are reversed for easy code generation. */

reversd() {
  register struct express *p;

  p = &exptbl[explev];
  if ((p->op1.optype & 0xff) == NNODE) {
    if ((p->op2.optype & 0xff) != NNODE)
      return(0);
    if (p->op1.opkind.node.nnum > p->op2.opkind.node.nnum)
      return(0);
    return(1);
  }
  if ((p->op2.optype & 0xff) == NNODE)
    return(1);
  return(0);
}

/* Determine arrangement of operands for easy code generation.
*    operand 1      operand 2       Return
*      TOS            XXX             1
*      XXX            TOS             2
*      XXX             D              3
*       D             XXX             4
*      XXX   normal   XXX             5
*      XXX   revers   XXX             6
*      XXX            CON             7
*/

where() {
  int ref1, ref2;
  register struct addreg *p1, *p2;

  p1 = &adregs[locop1 & (NUMADR-1)];
  p2 = &adregs[locop2 & (NUMADR-1)];
  ref1 = p1->ar_ref;
  ref2 = p2->ar_ref;
  if ((locop1 & ARREF) && (ref1==TREF || ref1==BREF) && p1->ar_ind==0)
    return(1);
  if (locop2 & ARREF) {
    if ((ref2==BREF || ref2==TREF) && p2->ar_ind==0)
      return(2);
    if (ref2==CREF)
      return(7);
  }
  if ((locop2 & 0xf0) == DATREG)
    return(3);
  if ((locop1 & 0xf0) == DATREG)
    return(4);
  if ((ref1==BREF || ref1==TREF) && p1->ar_ind)
    return(5);
  if (reversd() || ((ref2==BREF || ref2==TREF) && p2->ar_ind))
    return(6);
  return(5);
}

/* special check for comparison after short constant AND op */

spcland() {
  register struct express *p;
  int op;

  p = &exptbl[explev+1];
  op = p->operator & 0xff;
  if (op==BRX || op==BLX)
    return(1);
  if (op>=EQU && op<=GRT) {
    if ((p->op1.optype&0xff)==NNODE && p->op1.opkind.node.nnum==(explev+1)) {
      if ((p->op2.optype&0xff)==NCON && p->op2.opkind.cons.cdata.cint<256) {
        p->rtype = CHR;
        (p-1)->rtype = CHR;
        return(1);
      }
    }
  }
  return(0);
}
