/*
** cpu.c 650x/65C02/6510/6280 cpu-description file
** (c) in 2002,2006,2008-2012,2014-2020 by Frank Wille
*/

#include "vasm.h"

mnemonic mnemonics[] = {
#include "opcodes.h"
};

int mnemonic_cnt=sizeof(mnemonics)/sizeof(mnemonics[0]);

char *cpu_copyright="vasm 6502 cpu backend 0.8d (c) 2002,2006,2008-2012,2014-2020 Frank Wille";
char *cpuname = "6502";
int bitsperbyte = 8;
int bytespertaddr = 2;

static uint16_t cpu_type = M6502;
static int branchopt = 0;
static int modifier;      /* set by find_base() */
static utaddr dpage = 0;  /* default zero/direct page - set with SETDP */
static int bbcade;        /* GMGM - set for BBC ADE compatibility */


int ext_unary_type(char *s)
{
  if (bbcade)  /* GMGM - BBC ADE assembler swaps meaning of < and > */
    return *s=='<' ? HIBYTE : LOBYTE;
  return *s=='<' ? LOBYTE : HIBYTE;
}


int ext_unary_eval(int type,taddr val,taddr *result,int cnst)
{
  switch (type) {
    case LOBYTE:
      *result = cnst ? (val & 0xff) : val;
      return 1;
    case HIBYTE:
      *result = cnst ? ((val >> 8) & 0xff) : val;
      return 1;
    default:
      break;
  }
  return 0;  /* unknown type */
}


int ext_find_base(symbol **base,expr *p,section *sec,taddr pc)
{
  /* addr/256 equals >addr, addr%256 and addr&255 equal <addr */
  if (p->type==DIV || p->type==MOD) {
    if (p->right->type==NUM && p->right->c.val==256)
      p->type = p->type == DIV ? HIBYTE : LOBYTE;
  }
  else if (p->type==BAND && p->right->type==NUM && p->right->c.val==255)
    p->type = LOBYTE;

  if (p->type==LOBYTE || p->type==HIBYTE) {
    modifier = p->type;
    return find_base(p->left,base,sec,pc);
  }
  return BASE_ILLEGAL;
}


int parse_operand(char *p,int len,operand *op,int required)
{
  char *start = p;
  int indir = 0;

  p = skip(p);
  if (len>0 && required!=DATAOP && check_indir(p,start+len)) {
    indir = 1;
    p = skip(p+1);
  }

  switch (required) {
    case IMMED:
      if (*p++ != '#')
        return PO_NOMATCH;
      p = skip(p);
      break;
    case INDIR:
    case INDIRX:
    case INDX:
    case INDY:
    case DPINDIR:
      if (!indir)
        return PO_NOMATCH;
      break;
    case WBIT:
      if (*p == '#')  /* # is optional */
        p = skip(p+1);
    default:
      if (indir)
        return PO_NOMATCH;
      break;
  }

  op->dp = dpage;
  if (required < ACCU)
    op->value = parse_expr(&p);
  else
    op->value = NULL;

  switch (required) {
    case INDX:
    case INDIRX:
      if (*p++ == ',') {
        p = skip(p);
        if (toupper((unsigned char)*p++) != 'X')
          return PO_NOMATCH;
      }
      else
        return PO_NOMATCH;
      break;
    case ACCU:
      if (len != 0) {
        if (len!=1 || toupper((unsigned char)*p++) != 'A')
          return PO_NOMATCH;
      }
      break;
    case DUMX:
      if (toupper((unsigned char)*p++) != 'X')
        return PO_NOMATCH;
      break;
    case DUMY:
      if (toupper((unsigned char)*p++) != 'Y')
        return PO_NOMATCH;
      break;
  }

  if (required==INDIR || required==INDX || required==INDY
      || required==DPINDIR || required==INDIRX) {
    p = skip(p);
    if (*p++ != ')') {
      cpu_error(2);  /* missing closing parenthesis */
      return PO_CORRUPT;
    }
  }

  p = skip(p);
  if (p-start < len)
    cpu_error(1);  /* trailing garbage in operand */
  op->type = required;
  return PO_MATCH;
}


char *parse_cpu_special(char *start)
{
  char *name=start,*s=start;

  if (ISIDSTART(*s)) {
    s++;
    while (ISIDCHAR(*s))
      s++;

    if (s-name==5 && !strnicmp(name,"setdp",5)) {
      s = skip(s);
      dpage = (utaddr)parse_constexpr(&s);
      eol(s);
      return skip_line(s);
    }
    else if (s-name==5 && !strnicmp(name,"zpage",5)) {
      char *name;
      s = skip(s);
      if (name = parse_identifier(&s)) {
        symbol *sym = new_import(name);
        myfree(name);
        sym->flags |= ZPAGESYM;
        eol(s);
      }
      else
        cpu_error(8);  /* identifier expected */
      return skip_line(s);
    }
  }
  return start;
}


int parse_cpu_label(char *labname,char **start)
/* parse cpu-specific directives following a label field,
   return zero when no valid directive was recognized */
{
  char *dir=*start,*s=*start;

  if (ISIDSTART(*s)) {
    s++;
    while (ISIDCHAR(*s))
      s++;

    if (s-dir==3 && !strnicmp(dir,"ezp",3)) {
      /* label EZP <expression> */
      symbol *sym;

      s = skip(s);
      sym = new_equate(labname,parse_expr_tmplab(&s));
      sym->flags |= ZPAGESYM;
      eol(s);
      *start = skip_line(s);
      return 1;
    }
  }
  return 0;
}


static void optimize_instruction(instruction *ip,section *sec,
                                 taddr pc,int final)
{
  mnemonic *mnemo = &mnemonics[ip->code];
  symbol *base;
  operand *op;
  taddr val;
  int i;

  for (i=0; i<MAX_OPERANDS; i++) {
    if ((op = ip->op[i]) != NULL) {
      if (op->value != NULL) {
        if (eval_expr(op->value,&val,sec,pc))
          base = NULL;  /* val is constant/absolute */
        else
          find_base(op->value,&base,sec,pc);  /* get base-symbol */

        if ((op->type==ABS || op->type==ABSX || op->type==ABSY) &&
            ((base==NULL
              && ((val>=0 && val<=0xff) ||
                  ((utaddr)val>=op->dp && (utaddr)val<=op->dp+0xff))) ||
            (base!=NULL && (base->flags&ZPAGESYM)))
            && mnemo->ext.zp_opcode!=0) {
          /* we can use a zero page addressing mode for absolute 16-bit */
          op->type += ZPAGE-ABS;
        }
        else if (op->type==REL && (base==NULL || !is_pc_reloc(base,sec))) {
          taddr bd = val - (pc + 2);

          if ((bd<-0x80 || bd>0x7f) && branchopt) {
            /* branch dest. out of range: use a B!cc/JMP combination */
            op->type = RELJMP;
          }
        }
      }
    }
  }
}


static size_t get_inst_size(instruction *ip)
{
  size_t sz = 1;
  int i;

  for (i=0; i<MAX_OPERANDS; i++) {
    if (ip->op[i] != NULL) {
      switch (ip->op[i]->type) {
        case REL:
        case INDX:
        case INDY:
        case DPINDIR:
        case IMMED:
        case ZPAGE:
        case ZPAGEX:
        case ZPAGEY:
          sz += 1;
          break;
        case ABS:
        case ABSX:
        case ABSY:
        case INDIR:
        case INDIRX:
          sz += 2;
          break;
        case RELJMP:
          sz += 4;
          break;
      }
    }
  }
  return sz;
}


size_t instruction_size(instruction *ip,section *sec,taddr pc)
{
  instruction *ipcopy;
  int i;

  for (i=0; i<MAX_OPERANDS-1; i++) {
    /* convert DUMX/DUMY operands into real addressing modes first */
    if (ip->op[i]!=NULL && ip->op[i+1]!=NULL) {
      if (ip->op[i]->type == ABS) {
        if (ip->op[i+1]->type == DUMX) {
          ip->op[i]->type = ABSX;
          break;
        }
        else if (ip->op[i+1]->type == DUMY) {
          ip->op[i]->type = ABSY;
          break;
        }
      }
      else if (ip->op[i]->type == INDIR) {
        if (ip->op[i+1]->type == DUMY) {
          ip->op[0]->type = INDY;
          break;
        }
      }
    }
  }

  if (++i < MAX_OPERANDS) {
    /* we removed a DUMX/DUMY operand at the end */
    myfree(ip->op[i]);
    ip->op[i] = NULL;
  }

  ipcopy = copy_inst(ip);
  optimize_instruction(ipcopy,sec,pc,0);
  return get_inst_size(ipcopy);
}


static void rangecheck(taddr val,operand *op)
{
  switch (op->type) {
    case ZPAGE:
    case ZPAGEX:
    case ZPAGEY:
    case INDX:
    case INDY:
    case DPINDIR:
      if ((utaddr)val>=op->dp && (utaddr)val<=op->dp+0xff)
        break;
    case IMMED:
      if (val<-0x80 || val>0xff)
        cpu_error(5,8); /* operand doesn't fit into 8-bits */
      break;
    case REL:
      if (val<-0x80 || val>0x7f)
        cpu_error(6);   /* branch destination out of range */
      break;
    case WBIT:
      if (val<0 || val>7)
        cpu_error(7);   /* illegal bit number */
      break;
  }
}


dblock *eval_instruction(instruction *ip,section *sec,taddr pc)
{
  dblock *db = new_dblock();
  unsigned char *d,oc;
  int optype,i;
  taddr val;

  optimize_instruction(ip,sec,pc,1);  /* really execute optimizations now */

  db->size = get_inst_size(ip);
  d = db->data = mymalloc(db->size);

  /* write opcode */
  oc = mnemonics[ip->code].ext.opcode;
  for (i=0; i<MAX_OPERANDS; i++) {
    optype = ip->op[i]!=NULL ? ip->op[i]->type : IMPLIED;
    switch (optype) {
      case ZPAGE:
      case ZPAGEX:
      case ZPAGEY:
        oc = mnemonics[ip->code].ext.zp_opcode;
        break;
      case RELJMP:
        oc ^= 0x20;  /* B!cc branch */
        break;
    }
  }
  *d++ = oc;

  for (i=0; i<MAX_OPERANDS; i++) {
    if (ip->op[i] != NULL){
      operand *op = ip->op[i];
      int offs = d - db->data;
      symbol *base;

      optype = (int)op->type;
      if (op->value != NULL) {
        if (!eval_expr(op->value,&val,sec,pc)) {
          taddr add = 0;

          modifier = 0;
          if (optype!=WBIT && find_base(op->value,&base,sec,pc) == BASE_OK) {
            if (optype==REL && !is_pc_reloc(base,sec)) {
              /* relative branch requires no relocation */
              val = val - (pc + offs + 1);
            }
            else {
              int type = REL_ABS;
              int size;
              rlist *rl;

              switch (optype) {
                case ABS:
                case ABSX:
                case ABSY:
                case INDIR:
                case INDIRX:
                  size = 16;
                  break;
                case INDX:
                case INDY:
                case DPINDIR:
                case ZPAGE:
                case ZPAGEX:
                case ZPAGEY:
                case IMMED:
                  size = 8;
                  break;
                case RELJMP:
                  size = 16;
                  offs = 3;
                  break;
                case REL:
                  type = REL_PC;
                  size = 8;
                  add = -1;  /* 6502 addend correction */
                  break;
                default:
                  ierror(0);
                  break;
              }

              rl = add_extnreloc(&db->relocs,base,val+add,type,0,size,offs);
              switch (modifier) {
                case LOBYTE:
                  if (rl)
                    ((nreloc *)rl->reloc)->mask = 0xff;
                  val = val & 0xff;
                  break;
                case HIBYTE:
                  if (rl)
                    ((nreloc *)rl->reloc)->mask = 0xff00;
                  val = (val >> 8) & 0xff;
                  break;
              }
            }
          }
          else
            general_error(38);  /* illegal relocation */
        }
        else {
          /* constant/absolute value */
          if (optype == REL)
            val = val - (pc + offs + 1);
        }

        rangecheck(val,op);

        /* write operand data */
        switch (optype) {
          case ABSX:
          case ABSY:
            if (!*(db->data)) /* STX/STY allow only ZeroPage addressing mode */
              cpu_error(5,8); /* operand doesn't fit into 8 bits */
          case ABS:
          case INDIR:
          case INDIRX:
            *d++ = val & 0xff;
            *d++ = (val>>8) & 0xff;
            break;
          case DPINDIR:
          case INDX:
          case INDY:
          case ZPAGE:
          case ZPAGEX:
          case ZPAGEY:
            if ((utaddr)val>=op->dp && (utaddr)val<=op->dp+0xff)
              val -= op->dp;
          case IMMED:
          case REL:
            *d++ = val & 0xff;
            break;
          case RELJMP:
            if (d - db->data > 1)
              ierror(0);
            *d++ = 3;     /* B!cc *+3 */
            *d++ = 0x4c;  /* JMP */
            *d++ = val & 0xff;
            *d++ = (val>>8) & 0xff;
            break;
          case WBIT:
            *(db->data) |= (val&7) << 4;  /* set bit number in opcode */
            break;
        }
      }
    }
  }

  return db;
}


dblock *eval_data(operand *op,size_t bitsize,section *sec,taddr pc)
{
  dblock *db = new_dblock();
  taddr val;

  if (bitsize!=8 && bitsize!=16 && bitsize!=32)
    cpu_error(3,bitsize);  /* data size not supported */

  db->size = bitsize >> 3;
  db->data = mymalloc(db->size);
  if (!eval_expr(op->value,&val,sec,pc)) {
    symbol *base;
    int btype;
    rlist *rl;
    
    modifier = 0;
    btype = find_base(op->value,&base,sec,pc);
    if (btype==BASE_OK || (btype==BASE_PCREL && modifier==0)) {
      rl = add_extnreloc(&db->relocs,base,val,
                         btype==BASE_PCREL?REL_PC:REL_ABS,0,bitsize,0);
      switch (modifier) {
        case LOBYTE:
          if (rl)
            ((nreloc *)rl->reloc)->mask = 0xff;
          val = val & 0xff;
          break;
        case HIBYTE:
          if (rl)
            ((nreloc *)rl->reloc)->mask = 0xff00;
          val = (val >> 8) & 0xff;
          break;
      }
    }
    else if (btype != BASE_NONE)
      general_error(38);  /* illegal relocation */
  }
  if (bitsize < 16) {
    if (val<-0x80 || val>0xff)
      cpu_error(5,8);  /* operand doesn't fit into 8-bits */
  } else if (bitsize < 32) {
    if (val<-0x8000 || val>0xffff)
      cpu_error(5,16);  /* operand doesn't fit into 16-bits */
  }

  setval(0,db->data,db->size,val);
  return db;
}


operand *new_operand()
{
  operand *new = mymalloc(sizeof(*new));
  new->type = -1;
  return new;
}


int cpu_available(int idx)
{
  return (mnemonics[idx].ext.available & cpu_type) != 0;
}


int init_cpu()
{
  return 1;
}


int cpu_args(char *p)
{
  if (!strcmp(p,"-opt-branch"))
    branchopt = 1;
  else if (!strcmp(p,"-bbcade")) /* GMGM */
    bbcade = 1;
  else if (!strcmp(p,"-illegal"))
    cpu_type |= ILL;
  else if (!strcmp(p,"-dtv"))
    cpu_type |= DTV;
  else if (!strcmp(p,"-c02"))
    cpu_type = M6502 | M65C02;
  else if (!strcmp(p,"-wdc02"))
    cpu_type = M6502 | M65C02 | WDC02;
  else if (!strcmp(p,"-ce02"))
    cpu_type = M6502 | M65C02 | WDC02 | CSGCE02;
  else if (!strcmp(p,"-6280"))
    cpu_type = M6502 | M65C02 | WDC02 | HU6280;
  else
    return 0;

  return 1;
}
