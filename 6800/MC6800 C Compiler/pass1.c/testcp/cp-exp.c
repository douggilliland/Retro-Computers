#include "cp.h"
#include "il.h"

extern int pp_if_result;
extern short curchar, curtok;
extern long convalu;
extern int *tos;
extern int astack[];

/* evaluate expression */

ppcexp() {
  int stat = 0;

  curchar = curtok = 0;
  pp_if_result = 0;
  tos = astack;
  if (stat = exp13())
    pp_if_result = *(tos-1);
  else {
    pp_if_result = 0;
  }
  return(stat);
}

/* priority level 13 - conditional operator */

exp13() {
  char flag;
  int val;

  if (!exp10())
    return(FALSE);
  while (getok() == QUM) {
    curtok = 0;
    flag = 0;
    val = *(--tos);
    if (val)
      flag=1;
    else
      flag=2;
    if (!exp13())
      return(FALSE);
    if (getok() != COL)
      return(FALSE);
    curtok = 0;
    if (flag == 2)
      tos--;
    if (!exp13())
      return(FALSE);
    if (flag == 1)
      tos--;
  }
  return(TRUE);
}

/* priority level 10 - bitwise or operator */

exp10() {
  int val;

  if (!exp9())
    return(FALSE);
  while (getok() == BOR) {
    curtok = 0;
    if (!exp9())
      return(FALSE);
    val = *(--tos);
    *(tos-1) |= val;
  }
  return(TRUE);
}

/* priority level 9 - exclusive or operator */

exp9() {
  int val;

  if (!exp8())
    return(FALSE);
  while (getok() == XOR) {
    curtok = 0;
    if (!exp8())
      return(FALSE);
    val = *(--tos);
    *(tos-1) ^= val;
  }
  return(TRUE);
}

/* priority level 8 - bitwise and operator */

exp8() {
  int val;

  if (!exp7())
    return(FALSE);
  while (getok() == AND) {
    curtok = 0;
    if (!exp7())
      return(FALSE);
    val = *(--tos);
    *(tos-1) &= val;
  }
  return(TRUE);
}

/* priority level 7 - equality operators */

exp7() {
  int val;
  short tok;

  if (!exp6())
    return(FALSE);
  while (getok()==EQU || curtok==NEQ) {
    tok = curtok;
    curtok = 0;
    if (!exp6())
      return(FALSE);
    val = *(--tos);
    *(tos-1) = ((tok==EQU)?(*(tos-1)==val):(*(tos-1)!=val));
  }
  return(TRUE);
}

/* priority level 6 - relational operators */

exp6() {
  short tok;
  int val;

  if (!exp5())
    return(FALSE);
  while (getok()>=LEQ && curtok<=GRT) {
    tok = curtok;
    curtok = 0;
    if (!exp5())
      return(FALSE);
    val = *(--tos);
    switch (tok) {
      case LEQ:
        *(tos-1) = (*(tos-1) <= val);
        break;
      case LES:
        *(tos-1) = (*(tos-1) < val);
        break;
      case GEQ:
        *(tos-1) = (*(tos-1) >= val);
        break;
      case GRT:
        *(tos-1) = (*(tos-1) > val);
        break;
    }
  }
  return(TRUE);
}

/* priority level 5 - shift operators */

exp5() {
  short tok;
  int val;

  if (!exp4())
    return(FALSE);
  while (getok()==SHL || curtok==SHR) {
    tok = curtok;
    curtok = 0;
    if (!exp4())
      return(FALSE);
    val = *(--tos);
    if (tok == SHL)
      *(tos-1) <<= val;
    else
      *(tos-1) >>= val;
  }
  return(TRUE);
}

/* priority level 4 - add and subtract operators */

exp4() {
  short tok;
  int val;

  if (!exp3())
    return(FALSE);
  while (getok()==ADD || curtok==SUB) {
    tok = curtok;
    curtok = 0;
    if (!exp3())
      return(FALSE);
    val = *(--tos);
    if (tok == ADD)
      *(tos-1) += val;
    else
      *(tos-1) -= val;
  }
  return(TRUE);
}

/* priority level 3 - multiplicative operators */

exp3() {
  short tok;
  int val;

  if (!exp2())
    return(FALSE);
  while (getok()==MUL || curtok==DIV || curtok==MOD) {
    tok = curtok;
    curtok = 0;
    if (!exp2())
      return(FALSE);
    val = *(--tos);
    if (tok == MUL)
      *(tos-1) *= val;
    else if (tok == DIV)
      *(tos-1) /= val;
    else
      *(tos-1) %= val;
  }
  return(TRUE);
}

/* priority level 2 - unary operators */

exp2() {
  short tok;

  switch (getok()) {
    case SUB:
      tok = UNM;
      break;
    case COM:
      tok = COM;
      break;
    default:
      if (!exp1())
        return(FALSE);
      tok = 0;
  }
  if (tok) {
    curtok = 0;
    if (!exp2())
      return(FALSE);
    if (tok == UNM)
      *(tos-1) = -*(tos-1);
    else
      *(tos-1) = ~*(tos-1);
  }
  return(TRUE);
}

/* priority level 1 - operands */

exp1() {
  switch (getok()) {
    case CON:
      return(xcon());
    case LPR:
      return(xsub());
    default:
      rptern(44);
      return FALSE;
  }
}

/* process a constant operand */

xcon() {
  curtok = 0;
  *tos++ = convalu;
  return(TRUE);
}

/* process sub expression */

xsub() {
  curtok = 0;
  exp13();
  if (getok() != RPR) {
    rptern(45);
    return FALSE;
  }
  else
    curtok = 0;
  return(TRUE);
}
