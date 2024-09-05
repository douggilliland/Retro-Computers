/*
 *      MC6809 specific processing
 */

#define PAGE2   0x10
#define PAGE3   0x11
#define IPBYTE  0x9F    /* extended indirect postbyte */
#define SWI     0x3F

/* register names */

#define RD      0
#define RX      1
#define RY      2
#define RU      3
#define RS      4
#define RPC     5
#define RA      8
#define RB      9
#define RCC     10
#define RDP     11
#define RPCR    12

/* convert tfr/exg reg number into psh/pul format */
int     regs[] = { 6,16,32,64,64,128,0,0,2,4,1,8,0};
int     rcycl[]= { 2,2, 2, 2, 2, 2,  0,0,1,1,1,1,0};

/* addressing modes */
#define IMMED   0       /* immediate */
#define IND     1       /* indexed */
#define INDIR   2       /* indirect */
#define OTHER   3       /* NOTA */

/*
 *      localinit --- machine specific initialization
 */
localinit()
{
}

/*
 *      do_op --- process mnemonic
 *
 *      Called with the base opcode and it's class. Optr points to
 *      the beginning of the operand field.
 */
do_op(opcode,class)
int opcode;     /* base opcode */
int class;      /* mnemonic class */
{
        int     dist;   /* relative branch distance */
        int     src,dst;/* source and destination registers */
        int     pbyte;  /* postbyte value */
        int     amode;  /* indicated addressing mode */
        int     j;

        amode = set_mode();     /* pickup indicated addressing mode */

        switch(class){
                case INH:                       /* inherent addressing */
                        emit(opcode);
                        return;
                case GEN:                       /* general addressing */
                        do_gen(opcode,amode);
                        return;
                case IMM:                       /* immediate addressing */
                        if( amode != IMMED ){
                                error("Immediate Operand Required");
                                return;
                                }
                        Optr++;
                        eval();
                        emit(opcode);
                        emit(lobyte(Result));
                        return;
                case REL:                       /* short relative branches */
                        eval();
                        dist = Result - (Pc+2);
                        emit(opcode);
                        if( (dist >127 || dist <-128) && Pass==2){
                                error("Branch out of Range");
                                emit(lobyte(-2));
                                return;
                                }
                        emit(lobyte(dist));
                        return;
                case P2REL:                     /* long relative branches */
                        eval();
                        dist = Result - (Pc+4);
                        emit(PAGE2);
                        emit(opcode);
                        eword(dist);
                        return;
                case P1REL:                     /* lbra and lbsr */
                        if( amode == IMMED)
                                Optr++; /* kludge for C compiler */
                        eval();
                        dist = Result - (Pc+3);
                        emit(opcode);
                        eword(dist);
                        return;
                case NOIMM:
                        if( amode == IMMED ){
                                error("Immediate Addressing Illegal");
                                return;
                                }
                        do_gen(opcode,amode);
                        return;
                case P2GEN:
                        emit(PAGE2);
                        if( amode == IMMED ){
                                emit(opcode);
                                Optr++;
                                eval();
                                eword(Result);
                                return;
                                }
                        do_gen(opcode,amode);
                        return;
                case P3GEN:
                        emit(PAGE3);
                        if( amode == IMMED ){
                                emit(opcode);
                                Optr++;
                                eval();
                                eword(Result);
                                return;
                                }
                        do_gen(opcode,amode);
                        return;
                case RTOR:                      /* tfr and exg */
                        emit(opcode);
                        src = regnum();
                        while(alpha(*Optr))Optr++;
                        if(src==ERR){
                                error("Register Name Required");
                                emit(0);
                                return;
                                }
                        if(*Optr++ != ','){
                                error("Missing ,");
                                emit(0);
                                return;
                                }
                        dst = regnum();
                        while(alpha(*Optr))Optr++;
                        if(dst==ERR){
                                error("Register Name Required");
                                emit(0);
                                return;
                                }
                        if( src==RPCR || dst==RPCR){
                                error("PCR illegal here");
                                emit(0);
                                return;
                                }
                        if( (src <=5 && dst >=8) ||
                            (src >=8 && dst <=5)){
                                error("Register Size Mismatch");
                                emit(0);
                                return;
                                }
                        emit( (src<<4)+dst );
                        return;
                case INDEXED:                   /* indexed addressing only */
                        if( *Optr == '#'){
                                Optr++;         /* kludge city */
                                amode = IND;
                                }
                        if( amode != IND ){
                                error("Indexed Addressing Required");
                                return;
                                }
                        do_indexed(opcode);
                        return;
                case RLIST:                     /* pushes and pulls */
                        if(*Operand == EOS){
                                error("Register List Required");
                                return;
                                }
                        emit(opcode);
                        pbyte = 0;
                        do{
                                j = regnum();
                                if( j == ERR || j==RPCR)
                                        error("Illegal Register Name");
                                else if(j==RS && (opcode==52))
                                        error("Can't Push S on S");
                                else if(j==RU && (opcode==54))
                                        error("Can't Push U on U");
                                else if(j==RS && (opcode==53))
                                        error("Can't Pull S from S");
                                else if(j==RU && (opcode==55))
                                        error("Can't Pull U from U");
                                else{
                                        pbyte |= regs[j];
                                        Cycles += rcycl[j];
                                        }
                                while(*Optr != EOS && alpha(*Optr))Optr++;
                        }while( *Optr++ == ',' );
                        emit(lobyte(pbyte));
                        return;
                case P2NOIMM:
                        if( amode == IMMED )
                                error("Immediate Addressing Illegal");
                        else{
                                emit(PAGE2);
                                do_gen(opcode,amode);
                                }
                        return;
                case P2INH:                     /* Page 2 inherent */
                        emit(PAGE2);
                        emit(opcode);
                        return;
                case P3INH:                     /* Page 3 inherent */
                        emit(PAGE3);
                        emit(opcode);
                        return;
                case LONGIMM:
                        if( amode == IMMED ){
                                emit(opcode);
                                Optr++;
                                eval();
                                eword(Result);
                                }
                        else
                                do_gen(opcode,amode);
                        return;
                case GRP2:
                        if( amode == IND ){
                                do_indexed(opcode+0x60);
                                return;
                                }
                        else if( amode == INDIR){
                                Optr++;
                                emit(opcode + 0x60);
                                emit(IPBYTE);
                                eval();
                                eword(Result);
                                Cycles += 7;
                                if(*Optr == ']'){
                                        Optr++;
                                        return;
                                        }
                                error("Missing ']'");
                                return;
                                }
                        eval();
                        if(Force_word){
                                emit(opcode+0x70);
                                eword(Result);
                                Cycles += 3;
                                return;
                                }
                        if(Force_byte){
                                emit(opcode);
                                emit(lobyte(Result));
                                Cycles += 2;
                                return;
                                }
                        if(Result>=0 && Result <=0xFF){
                                emit(opcode);
                                emit(lobyte(Result));
                                Cycles += 2;
                                return;
                                }
                        else {
                                emit(opcode+0x70);
                                eword(Result);
                                Cycles += 3;
                                return;
                                }
                case SYS:                       /* system call */
                        emit(SWI);
                        eval();
                        emit(lobyte(Result));
                        return;
                default:
                        fatal("Error in Mnemonic table");
                }
}


/*
 *      do_gen --- process general addressing mode stuff
 */
do_gen(op,mode)
int     op;
int     mode;
{
        if( mode == IMMED){
                Optr++;
                emit(op);
                eval();
                emit(lobyte(Result));
                return;
                }
        else if( mode == IND ){
                do_indexed(op+0x20);
                return;
                }
        else if( mode == INDIR){
                Optr++;
                emit(op+0x20);
                emit(IPBYTE);
                eval();
                eword(Result);
                Cycles += 7;
                if(*Optr == ']'){
                        Optr++;
                        return;
                        }
                error("Missing ']'");
                return;
                }
        else if( mode == OTHER){
                eval();
                if(Force_word){
                        emit(op+0x30);
                        eword(Result);
                        Cycles += 3;
                        return;
                        }
                if(Force_byte){
                        emit(op+0x10);
                        emit(lobyte(Result));
                        Cycles += 2;
                        return;
                        }
                if(Result>=0 && Result <=0xFF){
                        emit(op+0x10);
                        emit(lobyte(Result));
                        Cycles += 2;
                        return;
                        }
                else {
                        emit(op+0x30);
                        eword(Result);
                        Cycles += 3;
                        return;
                        }
                }
        else {
                error("Unknown Addressing Mode");
                return;
                }
}

/*
 *      do_indexed --- handle all wierd stuff for indexed addressing
 */
do_indexed(op)
int op;
{
        int     pbyte;
        int     j,k;
        int     predec,pstinc;

        Cycles += 2;    /* indexed is always 2+ base cycle count */
        predec=0;
        pstinc=0;
        pbyte=128;
        emit(op);
        if(*Optr=='['){
                pbyte |= 0x10;    /* set indirect bit */
                Optr++;
                if( !any((char)']',Optr))
                        error("Missing ']'");
                Cycles += 3;    /* indirection takes this much longer */
                }
        j=regnum();
        if(j==RA){
                Cycles++;
                abd_index(pbyte+6);
                return;
                }
        if(j==RB){
                Cycles++;
                abd_index(pbyte+5);
                return;
                }
        if(j==RD){
                Cycles += 4;
                abd_index(pbyte+11);
                return;
                }
        eval();
        Optr++;
        while(*Optr=='-'){
                predec++;
                Optr++;
                }
        j=regnum();
        while( alpha(*Optr) )Optr++;
        while(*Optr=='+'){
                pstinc++;
                Optr++;
                }
        if(j==RPC || j==RPCR){
                if( pstinc || predec ){
                        error("Auto Inc/Dec Illegal on PC");
                        return;
                        }
                if(j==RPC){
                        if(Force_word){
                                emit(pbyte+13);
                                eword(Result);
                                Cycles += 5;
                                return;
                                }
                        if(Force_byte){
                                emit(pbyte+12);
                                emit(lobyte(Result));
                                Cycles++;
                                return;
                                }
                        if(Result>=-128 && Result <=127){
                                emit(pbyte+12);
                                emit(lobyte(Result));
                                Cycles++;
                                return;
                                }
                        else {
                                emit(pbyte+13);
                                eword(Result);
                                Cycles += 5;
                                return;
                                }
                        }
                /* PCR addressing */
                if(Force_word){
                        emit(pbyte+13);
                        eword(Result-(Pc+2));
                        Cycles += 5;
                        return;
                        }
                if(Force_byte){
                        emit(pbyte+12);
                        emit(lobyte(Result-(Pc+1)));
                        Cycles++;
                        return;
                        }
                k=Result-(Pc+2);
                if( k >= -128 && k <= 127){
                        emit(pbyte+12);
                        emit(lobyte(Result-(Pc+1)));
                        Cycles++;
                        return;
                        }
                else{
                        emit(pbyte+13);
                        eword(Result-(Pc+2));
                        Cycles += 5;
                        return;
                        }
                }
        if(predec || pstinc){
                if(Result != 0){
                        error("Offset must be Zero");
                        return;
                        }
                if(predec>2 || pstinc>2){
                        error("Auto Inc/Dec by 1 or 2 only");
                        return;
                        }
                if((predec==1 && (pbyte&0x10) != 0) ||
                   (pstinc==1 && (pbyte&0x10) != 0)){
                        error("No Auto Inc/Dec by 1 for Indirect");
                        return;
                        }
                if(predec && pstinc){
                        error("Can't do both!");
                        return;
                        }
                if(predec)
                        pbyte += predec+1;
                if(pstinc)
                        pbyte += pstinc-1;
                pbyte += rtype(j);
                emit(pbyte);
                Cycles += 1 + predec + pstinc;
                return;
                }
        pbyte += rtype(j);
        if(Force_word){
                emit(pbyte+0x09);
                eword(Result);
                Cycles += 4;
                return;
                }
        if(Force_byte){
                emit(pbyte+0x08);
                emit(lobyte(Result));
                Cycles++;
                return;
                }
        if(Result==0){
                emit(pbyte+0x04);
                return;
                }
        if((Result >= -16) && (Result <= 15) && ((pbyte&16)==0)){
                pbyte &= 127;
                pbyte += Result&31;
                emit(pbyte);
                Cycles++;
                return;
                }
        if(Result >= -128 && Result <= 127){
                emit(pbyte+0x08);
                emit(lobyte(Result));
                Cycles++;
                return;
                }
        emit(pbyte+0x09);
        eword(Result);
        Cycles += 4;
        return;
}


/*
 *      abd_index --- a,b or d indexed
 */

abd_index(pbyte)
int pbyte;
{
        int     k;

        Optr += 2;
        k=regnum();
        pbyte += rtype(k);
        emit(pbyte);
        return;
}

/*
 *      rtype --- return register type in post-byte format
 */
rtype(r)
int r;
{
        switch(r){
        case RX:        return(0x00);
        case RY:        return(0x20);
        case RU:        return(0x40);
        case RS:        return(0x60);
                }
        error("Illegal Register for Indexed");
        return(0);
}

/*
 *      set_mode --- determine addressing mode from operand field
 */
set_mode()
{
        register char *p;

        if( *Operand == '#' )
                return(IMMED);          /* immediate addressing */
        p = Operand;
        while( *p != EOS && *p != BLANK && *p != TAB){/* any , before break */
                if( *p == ',')
                        return(IND);    /* indexed addressing */
                p++;
                }
        if( *Operand == '[')
                return(INDIR);          /* indirect addressing */
        return(OTHER);                  /* NOTA */
}

/*
 *      regnum --- return register number of *Optr
 */
regnum()
{
        if( head(Optr,"D" ))return(RD);
        if( head(Optr,"X" ))return(RX);
        if( head(Optr,"Y" ))return(RY);
        if( head(Optr,"U" ))return(RU);
        if( head(Optr,"S" ))return(RS);
        if( head(Optr,"PC" ))return(RPC);
        if( head(Optr,"PCR" ))return(RPCR);
        if( head(Optr,"A" ))return(RA);
        if( head(Optr,"B" ))return(RB);
        if( head(Optr,"CC" ))return(RCC);
        if( head(Optr,"DP" ))return(RDP);
        return(ERR);
}
