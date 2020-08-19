
/***************************** 68000 SIMULATOR ****************************

File Name: PROTO.H
Version: 1.0

This file contains function prototype definitions for all functions
	in the program

***************************************************************************/



int MOVE(void );
int MOVEP(void );
int MOVEA(void );
int MOVE_FR_SR(void );
int MOVE_TO_CCR(void );
int MOVE_TO_SR(void );
int MOVEM(void );
int MOVE_USP(void );
int MOVEQ(void );
int EXG(void );
int LEA(void );
int PEA(void );
int LINK(void );
int UNLK(void );
int ADD(void );
int ADDA(void );
int ADDI(void );
int ADDQ(void );
int ADDX(void );
int SUB(void );
int SUBA(void );
int SUBI(void );
int SUBQ(void );
int SUBX(void );
int DIVS(void );
int DIVU(void );
int MULS(void );
int MULU(void );
int NEG(void );
int NEGX(void );
int CMP(void );
int CMPA(void );
int CMPI(void );
int CMPM(void );
int TST(void );
int CLR(void );
int EXT(void );
int ABCD(void );
int SBCD(void );
int NBCD(void );
int AND(void );
int ANDI(void );
int ANDI_TO_CCR(void );
int ANDI_TO_SR(void );
int OR(void );
int ORI(void );
int ORI_TO_CCR(void );
int ORI_TO_SR(void );
int EOR(void );
int EORI(void );
int EORI_TO_CCR(void );
int EORI_TO_SR(void );
int NOT(void );
int SHIFT_ROT(void );
int SWAP(void );
int BIT_OP(void );
int TAS(void );
int BCC(void );
int DBCC(void );
int SCC(void );
int BRA(void );
int BSR(void );
int JMP(void );
int JSR(void );
int RTE(void );
int RTR(void );
int RTS(void );
int NOP(void );
int CHK(void );
int ILLEGAL(void );
int RESET(void );
int STOP(void );
int TRAP(void );
int TRAPV(void );
int show_topics(void );
int gethelp(void );
int at(int y,int x);
int home(void );
int clrscr(void );
char chk_buf(void );
int parse(char *str,char * *ptrbuf,int maxcnt);
int iswhite(char c,char *qflag);
int decode_size(long *result);
int eff_addr(long size,int mask,int add_times);
int runprog(void );
int exec_inst(void );
int exception(int class,long loc,int r_w);
int main(void );
int init(void );
int finish(void );
int errmess(void );
int cmderr(void );
int setdis(void );
int scrshow(void );
int mdis(void );
int selbp(void );
int sbpoint(void );
int cbpoint(void );
int dbpoint(void );
int memread(int loc,int MASK);
int memwrite(int loc,long value);
int alter(void );
int hex_to_dec(void );
int dec_to_hex(void );
int intmod(void );
int portmod(void );
int pcmod(void );
int changemem(long oldval,long *result);
int mmod(void );
int regmod(char *regpntr,int data_or_mem);
int mfill(void );
int clear(void );
char *gettext(int word,char *prompt);
int same(char *str1,char *str2);
int eval(char *string);
int eval2(char *string,long *result);
int getval(int word,char *prompt);
int strcopy(char *str1,char *str2);
char *mkfname(char *cp1,char *cp2,char *outbuf);
int pchange(char oldval);
int to_2s_comp(long number,long size,long *result);
int from_2s_comp(long number,long size,long *result);
int sign_extend(int number,long size_from,long *result);
int inc_cyc(int num);
int eff_addr_code(int inst,int start);
int a_reg(int reg_num);
int mem_put(long data,int loc,long size);
int mem_req(int loc,long size,long *result);
int mem_request(int *loc,long size,long *result);
int put(long *dest,long source,long size);
int value_of(long *EA,long *EV,long size);
int cc_update(int x,int n,int z,int v,int c,long source,long dest,long result,long size,int r);
int check_condition(int condition);

