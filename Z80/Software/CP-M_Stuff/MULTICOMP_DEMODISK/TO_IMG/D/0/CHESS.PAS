(*$G+,S+,R-*)

PROGRAM CHESS(INPUT,OUTPUT);

(*                                                                   *)
(* (C) COPYRIGHT 1979 BY MARK H. BUTLER.  ALL RIGHTS RESERVED.       *)
(*                                                                   *)
(* THIS IS THE CHESS 0.5 PROGRAM PUBLISHED BY ATKIN AND FREY IN BYTE *)
(* MAGAZINE'S OCTOBER 1978 THROUGH JANUARY 1979 ISSUES.  THIS        *)
(* PROGRAM HAS BEEN CONVERTED TO UCSD AND ENHANCED BY:               *)
(*                                                                   *)
(*                MARK H. BUTLER                                     *)
(*                2130 BASSWOOD COURT                                *)
(*                WESTLAKE VILLAGE, CA. 91361                        *)
(*                (213) 889-4038                                     *)
(*                                                                   *)
(* MODIFICATIONS WERE REQUIRED TO THIS PROGRAM TO MAKE IT COMPATIBLE *)
(* WITH UCSD PASCAL RELEASE 1.5 (SEPTEMBER 1978).  MODIFICATIONS     *)
(* WERE ALSO REQUIRED TO ORIENT THE PROGRAM TO THE WORD SIZE (8-BITS)*)
(* AND THE MAXIMUM MEMORY SIZE AVAILABLE (56-60K) OF AN 8080/Z80     *)
(* TYPE MICROCOMPUTER SYSTEM.  SOME OF THE MAJOR CHANGES REQUIRED    *)
(* TO MAKE IT COMPATIBLE WITH UCSD PASCAL, AS WELL AS THE NECESSARY  *)
(* VARIABLE CHANGES AND CONSIDERATIONS, ARE DISCUSSED IN THE USER'S  *)
(* GUIDE.  THIS PROGRAM WILL RUN (WITH FEW IF ANY CHANGES) ON ANY    *)
(* MAXI, MINI, OR MICRO COMPUTER RUNNING THE 1.5 OR LATER VERSION    *)
(* OF UCSD PASCAL.                                                   *)
(*                                                                   *)

LABEL
  
  1,                            (* INITIALIZE FOR NEW GAME *)
  2,                            (* EXECUTE MACHINE'S MOVE *)
  9;                            (* END OF PROGRAM *)
  
CONST

  AA = 1;       ZA = 10;        (* CHARACTERS IN A WORD *)
  AC = ' ';     ZC = 'Z';       (* CHARACTER LIMITS *)
  AD = -21;     ZD = +21;       (* DIRECTION LIMITS *)
  AJ = 0;       ZJ = 73;        (* CHARACTERS IN A STRING *)
  AK = 0;       ZK = 4;         (* SEARCH DEPTH LIMITS - WERE 0 & 16 *)
  AKM2 = -2;                    (* AK - 2 *)
  ZKP1 = 5;                     (* ZK + 1 *)
  AL = 0;       ZL = 119;       (* LARGE BOARD VECTOR LIMITS *)
  AZL = -119;   ZAL = 119;      (* LARGE BOARD DIFFERENCES LIMITS *)
  AN = 1;       ZN = 30;        (* MESSAGE LIMITS *)
  AS = 0;       ZS = 63;        (* BOARD VECTOR LIMITS *)
  AT = -1;      ZT = 63;        (* AS..ZS PLUS ANOTHER VALUE *)
  AV = -32767;  ZV = +32767;    (* EVALUATION LIMITS *)
  AW = 1;       ZW = 125;       (* MOVE STACK LIMITS - WERE 1 & 500 *)
  AX = 0;       ZX = 7;         (* SUBSETS OF SQUARES - WERE 0 & 31 *)
  AY = 0;       ZY = 7;         (* ARRAY OF SUBSETS TO FOR A SET OF *)
                                (* ALL SQUARES ON THE BOARD         *)
  Š  LPP = 20;                     (* LINES PER PAGE *)
  PZX8 = 1;                     (* 2^(ZX-7) *)
  
  SYNCF = 1;                    (* FIRST CAPTURE SYNTAX *)
  SYNCL = 36;                   (* LAST CAPTURE SYNTAX *)
  SYNMF = 37;                   (* FIRST MOVE SYNTAX *)
  SYNML = 47;                   (* LAST MOVE SYNTAX *)

TYPE

  (* SIMPLE TYPES *)
  TA = AA..ZA;                  (* INDEX TO WORDS OF CHAR *)
  TB = BOOLEAN;                 (* TRUE OR FALSE *)
  TC = CHAR;                    (* SINGLE CHARACTERS *)
  TD = AD..ZD;                  (* DIRECTIONS *)
  TE = (B1,B2,B3,B4,            (* NUMBER OF DIRECTIONS *)
        S1,S2,S3,S4,
        N1,N2,N3,N4,N5,N6,N7,N8);
  TF = (F1,F2,F3,F4,            (* FILES *)
        F5,F6,F7,F8);
  TG = (PQ,PR,PN,PB);           (* PROMOTION PIECES *)
  TH = (H0,H1,H2,H3,            (* TREE SEARCH MODES *)
        H4,H5,H6,H7);
  TI = INTEGER;                 (* INTEGER NUMBERS *)
  TJ = AJ..ZJ;                  (* INDEX TO STRINGS *)
  TK = AK..ZK;                  (* PLY INDEX *)
  TL = AL..ZL;                  (* LARGE (10X12) BOARD *)
  TM = (LITE,DARK,NONE);        (* SIDES *)
  TN = AN..ZN;                  (* INDEX TO MESSAGES *)
  TP = (LP,LR,LN,LB,LQ,LK,      (* PIECES : LITE, DARK, & EMPTY SQUARES *)
        DP,DR,DN,DB,DQ,DK,MT);
  TQ = (LS,LL,DS,DL);           (* QUADRANTS *)
  TR = (R1,R2,R3,R4,            (* RANKS *)
        R5,R6,R7,R8);
  TS = AS..ZS;                  (* SQUARES *)
  TT = AT..ZT;                  (* SQUARES AND ANOTHER VALUE *)
  TU = (EP,ER,EN,EB,EQ,EK);     (* TYPES : PAWN, ROOK, ..., KING *)
  TV = AV..ZV;                  (* EVALUATIONS *)
  TW = AW..ZW;                  (* MOVES INDEX *)
  TX = AX..ZX;                  (* SOME SQUARES *)
  TY = AY..ZY;                  (* NUMBER OF TX'S IN A BOARD *)
  TZ = REAL;                    (* FLOATING POINT NUMBERS *)
  
  (* SETS *)
  
  SC = SET OF AC..ZC;           (* SET OF CHARACTERS *)
  SF = SET OF TF;               (* SET OF FILES *)
  SQ = SET OF TQ;               (* SET OF CASTLING TYPES *)
  SR = SET OF TR;               (* SET OF RANKS *)
  SX = SET OF TX;               (* SET OF SOME SQUARES *)
  
  (* RECORDS *)
  
  RB = RECORD                   (* BOARD DESCRIPTIONS *)Š    RBTM : TM;                  (* SIDE TO MOVE *)
    RBTS : TT;                  (* ENPASSANT SQUARE *)
    RBTI : TI;                  (* MOVE NUMBER *)
    RBSQ : SQ;                  (* CASTLE FLAGS *)
    CASE INTEGER OF
      0: (RBIS: ARRAY [TS] OF TP);      (* INDEXED BY SQUARE # *)
      1: (RBIRF: ARRAY [TR,TF] OF TP)   (* INDEXED BY RANK & FILE *)
    END;
  
  RA = PACKED ARRAY [TA] OF TC;
  RC = ARRAY [TS] OF TP;
  RN = PACKED ARRAY [TN] OF TC;
  RJ = PACKED ARRAY [TJ] OF TC;
  
  RD = PACKED RECORD            (* SYNTAX DESC. FOR SINGLE SQUARE *)
    RDPC : TB;                  (* PIECE *)
    RDSL : TB;                  (* / *)
    RDKQ : TB;                  (* KING OR QUEEN *)
    RDNB : TB;                  (* ROOK, KNIGHT, OR BISHOP *)
    RDRK : TB;                  (* RANK *)
    END;
    
  RM = PACKED RECORD            (* MOVE DESCRIPTION *)
    RMFR : TS;                  (* FROM SQUARE *)
    RMTO : TS;                  (* TO SQUARE *)
    RMCP : TP;                  (* CAPTURED PIECE *)
    RMCA : TB;                  (* CAPTURE *)
    RMAC : TB;                  (* AFFECTS CASTLE STATUS *)
    RMCH : TB;                  (* CHECK CONDITION *)
    RMMT : TB;                  (* MATE CONDITION *)
    RMIL : TB;                  (* ILLEGAL MOVE *)
    RMSU : TB;                  (* SEARCHED *)
    CASE RMPR : TB OF           (* PROMOTION STATUS *)
      FALSE:                    (* NO PROMOTION *) 
        (
          CASE RMOO  : TB OF    (* CASTLE STATUS *)
            FALSE : (RMEP : TB);(* NO, ENPASSANT *)
            TRUE  : (RMQS : TB) (* YES, QUEEN SIDE *)
        );
      TRUE : (RMPP : TG)        (* PROMOTION, TYPE *)
    END;
  
  RS = RECORD                   (* BIT BOARDS DESCRIPTION *)
    CASE INTEGER OF
      0: (RSSS : ARRAY [TY] OF SX); (* ARRAY OF SETS *)
      1: (RSTI : ARRAY [TY] OF TI)  (* ARRAY OF INTEGERS *)
    END;

  RX = ARRAY [TS] OF RS;        (* ATTACK MAPS *)

  RY = PACKED RECORD            (* MOVE SYNTAX DESCRIPTION *)
    RYLS : RD;                  (* LEFT SIDE DESCRIPTION *)
    RYCH : TC;                  (* MOVE OR CAPTURE INDICATOR *)
    RYRS : RD;                  (* RIGHT SIDE DESCRIPTION *)Š    END;
  
  RE = ARRAY [TW] OF TV;        (* ARRAY OF VALUES *)
  RF = ARRAY [TW] OF RM;        (* ARRAY OF MOVES *)

VAR

  (* DATA BASE *)
  
  BOARD : RB;                   (* THE BOARD *)
  NBORD : ARRAY [TS] OF TP;     (* LOOK-AHEAD BOARD *)
  ATKFR : ARRAY [TS] OF RS;     (* ATTACKS FROM A SQUARE *)
  ATKTO : ARRAY [TS] OF RS;     (* ATTACKS TO A SQUARE *)
  ALATK : ARRAY [TM] OF RS;     (* ATTACKS BY EACH COLOR *)
  TPLOC : ARRAY [TP] OF RS;     (* LOCATIONS OF PIECE BY TYPE *)
  TMLOC : ARRAY [TM] OF RS;     (* LOCATIONS OF PIECE BY COLOR *)
  MOVES : ARRAY [TW] OF RM;
  VALUE : ARRAY [TW] OF TV;
  ALLOC : ARRAY [TK] OF RS;     (* ALL PIECES *)
  BSTMV : ARRAY [TK] OF TW;     (* BEST MOVE SO FAR *)
  BSTVL : ARRAY [AKM2..ZKP1] OF TV;(* VALUE OF THE BEST MOVE *)
  CSTAT : ARRAY [TK] OF RS;
  ENPAS : ARRAY [TK] OF RS;
  GENPN : ARRAY [TK] OF RS;
  GENTO : ARRAY [TK] OF RS;
  GENFR : ARRAY [TK] OF RS;
  MBVAL : ARRAY [TK] OF TV;
  MVSEL : ARRAY [TK] OF TI;     (* MATERIAL BALANCE VALUES *)
  INDEX : ARRAY [AK..ZKP1] OF TW;(* CURRENT MOVE FOR PLY *)
  KILLR : ARRAY [TK] OF RM;     (* KILLER MOVES BY PLY *)
  LINDX : ARRAY [TK] OF TW;     (* LAST MOVE FOR PLY *)
  SRCHM : ARRAY [TK] OF TH;     (* SEARCH MODES *)
  GOING : TI;
  LSTMV : RM;                   (* PREVIOUS MOVE *)
  MAXPS : TV;                   (* MAXIMUM POSITIONAL SCORE *)
  MBLTE : TV;
  MBPWN : ARRAY [TM] OF TI;     (* NUMBER OF PAWNS BY SIDE *)
  MBTOT : TV;                   (* TOTAL MATERIAL ON NBORD *)
  NODES : TI;                   (* NUMBER OF NODES SEARCHED *)
  
  JNTK : TK;                    (* PLY INDEX *)
  JMTK : TK;                    (* ITERATION *)
  JNTM : TM;                    (* SIDE TO MOVE *)
  JNTW : TW;                    (* MOVES STACK POINTER *)
  
  (* LETS *)
  
  FKPSHD : TI;
  FKSANQ : TI;
  FMAXMT : TI;
  FNODEL : TI;                  (* NODE LIMIT FOR SEARCH *)
  FPADCR : ARRAY [TF] OF TI;
  FPBLOK : TI;
  FPCONN : TI;Š  FPFLNX : TI;
  FRDUBL : TI;
  FRK7TH : TI;
  FTRADE : TI;
  FTRDSL : TI;
  FTRPOK : TI;
  FTRPWN : TI;
  FWKING : TI;
  FWMAJM : TI;
  FWMINM : TI;
  FWPAWN : TI;
  FWROOK : TI;
  WINDOW : TI;                  (* SIZE OF ALPHA-BETA WINDOW *)
  
  (* SWITCHES *)
  
  SWEC : TB;                    (* ECHO KEYBOARD INPUT *)
  SWPA : TB;                    (* PAGING *)
  SWPS : TB;                    (* PRINT PRELIMINARY SCORES *)
  SWRE : TB;                    (* REPLY WITH MOVE *)
  SWSU : TB;                    (* PRINT STATISTICS SUMMARY *)
  SWTR : TB;                    (* TRACE TREE SEARCH *)
  CEND : TB;                    (* PROGRAM END REQUESTED *)
  CINI : TB;                    (* INITIALIZE FOR A NEW GAME REQUESTED *)
  
  (* COMMAND PROCESSING DATA *)
  
  ICARD : RJ;                   (* INPUT CARD IMAGE *)
  ILINE : RJ;                   (* CURRENT COMMAND *)
  JMTJ  : TJ;                   (* CURRENT INPUT LINE POSITION *)
  JNTJ  : TJ;                   (* CURRENT COMMAND POSITION *)
  MOVMS : RN;                   (* MOVE MESSAGE *)
  
  (* TRANSLATION TABLES *)
  
  XSPB : ARRAY [TP] OF TB;
  XFPE : ARRAY [TP] OF TE;
  XLLD : ARRAY [AZL..ZAL] OF TD;
  XLPE : ARRAY [TP] OF TE;
  XRFS : ARRAY [TF] OF RS;
  XRRS : ARRAY [TR] OF RS;
  XNFS : ARRAY [TF] OF RS;
  XNRS : ARRAY [TR] OF RS;
  XRSS : ARRAY [TS] OF RS;
  XRQM : ARRAY [TQ] OF RM;
  XSQS : ARRAY [TQ] OF RS;
  XSSX : ARRAY [TS] OF SX;
  XTBC : ARRAY [TB] OF TC;
  XTED : ARRAY [TE] OF TD;
  XTGC : ARRAY [TG] OF TC;
  XTGMP: ARRAY [TG,TM] OF TP;
  XTLS : ARRAY [TL] OF TT;
  XTMA : ARRAY [TM] OF RA;
  XTMQ : ARRAY [TM] OF TQ;Š  XTMV : ARRAY [TM] OF TV;
  XTPC : ARRAY [TP] OF TC;
  XTPM : ARRAY [TP] OF TM;
  XTPU : ARRAY [TP] OF TU;
  XTPV : ARRAY [TP] OF TV;
  XTQA : ARRAY [TQ] OF RA;
  XTQS : ARRAY [TQ] OF TS;
  XTRFS: ARRAY [TR,TF] OF TS;
  XTSF : ARRAY [TS] OF TF;
  XTSL : ARRAY [TS] OF TL;
  XTSR : ARRAY [TS] OF TR;
  XTSX : ARRAY [TS] OF TX;
  XTSY : ARRAY [TS] OF TY;
  XTUC : ARRAY [TU] OF TC;
  XTUMP: ARRAY [TU,TM] OF TP;
  XRQSO: ARRAY [TQ] OF RS;
  XRQSA: ARRAY [TQ] OF RS;
  EDGE : ARRAY [TE] OF RS;
  CORNR: RS;
  NULMV: RM;
  OTHER: ARRAY [TM] OF TM;
  SYNTX: ARRAY [SYNCF..SYNML] OF RY;
  
  PRNTR: TEXT;
  

PROCEDURE ANDRS(VAR C:RS; A,B:RS);    FORWARD;
PROCEDURE CPYRS(VAR C:RS; A:RS);      FORWARD;
PROCEDURE IORRS(VAR C:RS; A,B:RS);    FORWARD;
PROCEDURE NEWRS(VAR A:RS);            FORWARD;
PROCEDURE NOTRS(VAR C:RS; A:RS);      FORWARD;
PROCEDURE SETRS(VAR C:RS; A:TS);      FORWARD;
PROCEDURE PAUSER;                     FORWARD;
PROCEDURE PRIMOV(A:RM);               FORWARD;
PROCEDURE PTRMOV(A:RM);               FORWARD;
PROCEDURE PRINTB(A:RC);               FORWARD;
PROCEDURE PRINAM(A:RX);               FORWARD;
PROCEDURE PRISWI(A:RA; B:TB);         FORWARD;
PROCEDURE CLSTAT;                     FORWARD;
PROCEDURE LSTMOV;                     FORWARD;
PROCEDURE YRMOVE;                     FORWARD;

SEGMENT PROCEDURE INICON1; (* INIT. GLOBAL CONSTANTS - SEGMENT #1 *)
VAR
  INTD : TD;
  INTE : TE;
  INTF : TF;
  INTI : TI;
  INTL : TL;
  INTQ : TQ;
  INTR : TR;
  INTT : TT;
  INTX : TX;
  INTY : TY;Š  IMTI : TI;
  INRS : RS;
  
  
  PROCEDURE INIXTP(A:TP; B:TC; C:TM; D:TU; E:TB; F:TE; G:TE; H:TV);
  BEGIN
    XTPC[A] := B;
    XTPM[A] := C;
    XSPB[A] := E;
    XFPE[A] := F;
    XLPE[A] := G;
    XTPU[A] := D;
    XTPV[A] := H;
    IF A <> MT THEN
      XTUMP[D,C] := A;
  END;

BEGIN
  
  (* PIECE CHARACTERISTICS *)
  
  INIXTP(LP,'A',LITE,EP,FALSE,B1,B2,1*64);
  INIXTP(LR,'B',LITE,ER,TRUE,S1,S4,5*64);
  INIXTP(LN,'C',LITE,EN,FALSE,N1,N8,3*64);
  INIXTP(LB,'D',LITE,EB,TRUE,B1,B4,3*64);
  INIXTP(LQ,'E',LITE,EQ,TRUE,B1,S4,9*64);
  INIXTP(LK,'F',LITE,EK,FALSE,B1,S4,0);
  INIXTP(DP,'1',DARK,EP,FALSE,B3,B4,-1*64);
  INIXTP(DR,'2',DARK,ER,TRUE,S1,S4,-5*64);
  INIXTP(DN,'3',DARK,EN,FALSE,N1,N8,-3*64);
  INIXTP(DB,'4',DARK,EB,TRUE,B1,B4,-3*64);
  INIXTP(DQ,'5',DARK,EQ,TRUE,B1,S4,-9*64);
  INIXTP(DK,'6',DARK,EK,FALSE,B1,S4,0);
  INIXTP(MT,'-',NONE,EP,FALSE,B2,B1,0);
  XTGMP[PQ,LITE] := LQ;  XTGMP[PQ,DARK] := DQ;  XTGC[PQ] := 'Q';
  XTGMP[PR,LITE] := LR;  XTGMP[PR,DARK] := DR;  XTGC[PR] := 'R';
  XTGMP[PN,LITE] := LN;  XTGMP[PN,DARK] := DN;  XTGC[PN] := 'N';
  XTGMP[PB,LITE] := LB;  XTGMP[PB,DARK] := DB;  XTGC[PB] := 'B';
  XTUC[EK] := 'K';
  XTUC[EQ] := 'Q';
  XTUC[ER] := 'R';
  XTUC[EN] := 'N';
  XTUC[EB] := 'B';
  XTUC[EP] := 'P';
  
  (* OTHER CONSTANTS *)
  
  XTBC[FALSE] := '-';
  XTBC[TRUE]  := '*';
  OTHER[LITE] := DARK;  XTMV[LITE] := 1;
  OTHER[DARK] := LITE;  XTMV[DARK] := -1;
  OTHER[NONE] := NONE;
  XTMA[LITE] := '    WHITE ';
  XTMA[DARK] := '    BLACK ';Š  XTMA[NONE] := '   NO ONE ';
  XTQA[LS] := 'WHITE KING';
  XTQA[LL] := 'WHITE LONG';
  XTQA[DS] := 'BLACK KING';
  XTQA[DL] := 'BLACK LONG';
  
  (* 10X12 TO 8X8 AND 8X8 TO 10X12 TRANSLATION TABLES *)
  
  FOR INTL := AL TO ZL DO
    XTLS[INTL] := -1;
  INTL := 21;
  INTT := -1;
  FOR INTR := R1 TO R8 DO
  BEGIN
    FOR INTF := F1 TO F8 DO
    BEGIN
      INTT := INTT + 1;
      XTRFS[INTR,INTF] := INTT;
      XTLS[INTL] := INTT;
      XTSL[INTT] := INTL;
      XTSR[INTT] := INTR;
      XTSF[INTT] := INTF;
      INTL := INTL + 1;
    END;
    INTL := INTL + 2;
  END;
END;

SEGMENT PROCEDURE INICON2; (* INIT. GLOBAL CONSTANTS - SEGMENT #2 *)
VAR
  INTD : TD;
  INTE : TE;
  INTF : TF;
  INTI : TI;
  INTL : TL;
  INTQ : TQ;
  INTR : TR;
  INTT : TT;
  INTX : TX;
  INTY : TY;
  IMTI : TI;
  INRS : RS;
BEGIN

  (* 8X8 TO BIT BOARD TABLES *)
  
  INTT := -1;
  FOR INTY := AY TO ZY DO
  BEGIN
    FOR INTX := AX TO ZX DO
    BEGIN
      INTT := INTT + 1;
      XTSX[INTT] := INTX;
      XTSY[INTT] := INTY;Š      XSSX[INTT] := [INTX];
      NEWRS(XRSS[INTT]);
      XRSS[INTT].RSSS[INTY] := [INTX];
    END;
  END;
  
  (* CONSTANT BIT BOARDS *)
  
  FOR INTR := R1 TO R8 DO
    NEWRS(XRRS[INTR]);
  FOR INTF := F1 TO F8 DO
    NEWRS(XRFS[INTF]);
  FOR INTR := R1 TO R8 DO
    FOR INTF := F1 TO F8 DO
    BEGIN
      SETRS(XRRS[INTR],XTRFS[INTR,INTF]);
      SETRS(XRFS[INTF],XTRFS[INTR,INTF]);
    END;
  FOR INTF := F1 TO F8 DO
    NOTRS(XNFS[INTF],XRFS[INTF]);
  FOR INTR := R1 TO R8 DO
    NOTRS(XNRS[INTR],XRRS[INTR]);
  
  (* EDGES *)
  
  CPYRS(EDGE[S1],XRFS[F1]);
  CPYRS(EDGE[S2],XRRS[R8]);
  CPYRS(EDGE[S3],XRFS[F8]);
  CPYRS(EDGE[S4],XRRS[R1]);
  IORRS(EDGE[B1],EDGE[S1],EDGE[S2]);
  IORRS(EDGE[B2],EDGE[S2],EDGE[S3]);
  IORRS(EDGE[B3],EDGE[S3],EDGE[S4]);
  IORRS(EDGE[B4],EDGE[S4],EDGE[S1]);
  IORRS(EDGE[N1],EDGE[B1],XRRS[R7]);
  IORRS(EDGE[N2],EDGE[B2],XRRS[R7]);
  IORRS(EDGE[N3],EDGE[B2],XRFS[F7]);
  IORRS(EDGE[N4],EDGE[B3],XRFS[F7]);
  IORRS(EDGE[N5],EDGE[B3],XRRS[R2]);
  IORRS(EDGE[N6],EDGE[B4],XRRS[R2]);
  IORRS(EDGE[N7],EDGE[B4],XRFS[F2]);
  IORRS(EDGE[N8],EDGE[B1],XRFS[F2]);
  
  (* CORNER MASK *)
  
  IORRS(INRS,XRRS[R1],XRRS[R2]);
  IORRS(INRS,INRS,XRRS[R7]);
  IORRS(INRS,INRS,XRRS[R8]);
  IORRS(CORNR,XRFS[F1],XRFS[F2]);
  IORRS(CORNR,CORNR,XRFS[F7]);
  IORRS(CORNR,CORNR,XRFS[F8]);
  ANDRS(CORNR,CORNR,INRS);

  (* DIRECTION TABLE *)
  Š                XTED[N1]:=19;               XTED[N2]:= 21;
  XTED[N8]:=  8;XTED[B1]:=  9;XTED[S2]:= 10;XTED[B2]:= 11;XTED[N3]:=12;
                XTED[S1]:= -1;              XTED[S3]:=  1;
END;
  
SEGMENT PROCEDURE INICON3;
VAR
  INTD : TD;
  INTE : TE;
  INTF : TF;
  INTI : TI;
  INTL : TL;
  INTQ : TQ;
  INTR : TR;
  INTT : TT;
  INTX : TX;
  INTY : TY;
  IMTI : TI;
  INRS : RS;
BEGIN
  XTED[N7]:=-12;XTED[B4]:=-11;XTED[S4]:=-10;XTED[B3]:= -9;XTED[N4]:=-8;
                XTED[N6]:=-21;              XTED[N5]:=-19;
  
  (* SQUARE DIFFERENCE TO DIRECTION TABLE *)
  
  FOR INTI := AZL TO ZAL DO
    XLLD[INTI] := 0;
  FOR INTE := B1 TO S4 DO
  BEGIN
    INTD := XTED[INTE];
    FOR IMTI := 1 TO 7 DO
      XLLD[IMTI*INTD] := INTD;
  END;
  FOR INTE := N1 TO N8 DO
    XLLD[XTED[INTE]] := XTED[INTE];

  (* CASTLING TRANSLATION TABLES *)
  
  IORRS(XSQS[LS],XRSS[XTRFS[R1,F8]],XRSS[XTRFS[R1,F5]]);
  IORRS(XSQS[LL],XRSS[XTRFS[R1,F1]],XRSS[XTRFS[R1,F5]]);
  IORRS(XSQS[DS],XRSS[XTRFS[R8,F8]],XRSS[XTRFS[R8,F5]]);
  IORRS(XSQS[DL],XRSS[XTRFS[R8,F1]],XRSS[XTRFS[R8,F5]]);
  IORRS(XRQSO[LS],XRSS[XTRFS[R1,F6]],XRSS[XTRFS[R1,F7]]);
  IORRS(XRQSO[LL],XRSS[XTRFS[R1,F4]],XRSS[XTRFS[R1,F3]]);
  IORRS(XRQSA[LS],XRSS[XTRFS[R1,F5]],XRQSO[LS]);
  IORRS(XRQSA[LL],XRSS[XTRFS[R1,F5]],XRQSO[LL]);
  IORRS(XRQSO[LL],XRSS[XTRFS[R1,F2]],XRQSO[LL]);
  IORRS(XRQSO[DS],XRSS[XTRFS[R8,F6]],XRSS[XTRFS[R8,F7]]);
  IORRS(XRQSO[DL],XRSS[XTRFS[R8,F4]],XRSS[XTRFS[R8,F3]]);
  IORRS(XRQSA[DS],XRSS[XTRFS[R8,F5]],XRQSO[DS]);
  IORRS(XRQSA[DL],XRSS[XTRFS[R8,F5]],XRQSO[DL]);
  IORRS(XRQSO[DL],XRSS[XTRFS[R8,F2]],XRQSO[DL]);
  FOR INTQ := LS TO DL DO
    WITH XRQM[INTQ] DOŠ    BEGIN
      RMCP := MT;
      RMCA := FALSE;
      RMAC := TRUE;
      RMCH := FALSE;
      RMMT := FALSE;
      RMIL := FALSE;
      RMSU := FALSE;
      RMPR := FALSE;
      RMOO := TRUE;
    END;
END;
  
SEGMENT PROCEDURE INICON4; (* INIT. GLOBAL CONSTANTS - SEGMENT #4 *)
VAR
  INTD : TD;
  INTE : TE;
  INTF : TF;
  INTI : TI;
  INTL : TL;
  INTQ : TQ;
  INTR : TR;
  INTT : TT;
  INTX : TX;
  INTY : TY;
  IMTI : TI;
  INRS : RS;
  PC : TC;
  PD : RA;
  INIFL1 : TEXT;
  
  PROCEDURE INISYN(A:RA);
  BEGIN
    WITH SYNTX[INTI] DO
    BEGIN
      WITH RYLS DO
      BEGIN
        RDPC := TRUE;
        IF A[AA+0] <> ' ' THEN
          RDSL := TRUE
        ELSE
          RDSL := FALSE;
        IF A[AA+1] <> ' ' THEN
          RDKQ := TRUE
        ELSE
          RDKQ := FALSE;
        IF A[AA+2] <> ' ' THEN
          RDNB := TRUE
        ELSE
          RDNB := FALSE;
        IF A[AA+3] <> ' ' THEN
          RDRK := TRUE
        ELSE
          RDRK := FALSE;Š      END;
      RYCH := A[AA+4];
      WITH RYRS DO
      BEGIN
        IF A[AA+5] <> ' ' THEN
          RDPC := TRUE
        ELSE
          RDPC := FALSE;
        IF A[AA+6] <> ' ' THEN
          RDSL := TRUE
        ELSE
          RDSL := FALSE;
        IF A[AA+7] <> ' ' THEN
          RDKQ := TRUE
        ELSE
          RDKQ := FALSE;
        IF A[AA+8] <> ' ' THEN
          RDNB := TRUE
        ELSE
          RDNB := FALSE;
        IF A[AA+9] <> ' ' THEN
          RDRK := TRUE
        ELSE
          RDRK := FALSE;
      END;
    END;
  END;

BEGIN
  XRQM[LS].RMFR := XTRFS[R1,F5];  XRQM[LS].RMTO := XTRFS[R1,F7];
  XRQM[LL].RMFR := XTRFS[R1,F5];  XRQM[LL].RMTO := XTRFS[R1,F3];
  XRQM[DS].RMFR := XTRFS[R8,F5];  XRQM[DS].RMTO := XTRFS[R8,F7];
  XRQM[DL].RMFR := XTRFS[R8,F5];  XRQM[DL].RMTO := XTRFS[R8,F3];
  XRQM[LS].RMQS := FALSE;
  XRQM[LL].RMQS := TRUE;
  XRQM[DS].RMQS := FALSE;
  XRQM[DL].RMQS := TRUE;
  XTMQ[LITE] := LS;
  XTMQ[DARK] := DS;
  XTQS[LS] := XTRFS[R1,F8];
  XTQS[LL] := XTRFS[R1,F1];
  XTQS[DS] := XTRFS[R8,F8];
  XTQS[DL] := XTRFS[R8,F1];
  
  (* NULL MOVE *)
  
  WITH NULMV DO
  BEGIN
    RMFR := AS;
    RMTO := AS;
    RMCP := MT;
    RMCA := FALSE;
    RMAC := TRUE;
    RMCH := FALSE;Š    RMMT := FALSE;
    RMIL := FALSE;
    RMSU := FALSE;
    RMPR := TRUE;
    RMPP := PB;
  END;
  
  
  (* COMMAND PROCESSING VARIABLES *)
  
  JMTJ := ZJ;
  ICARD[ZJ] := ';';
  ILINE[ZJ] := ';';
  
  (* MOVES SYNTAX TABLE *)
  
  RESET(INIFL1,'CHESS:INIFL1.TEXT');
  FOR INTI := SYNCF TO SYNML DO
  BEGIN
    REPEAT
      READ(INIFL1,PC)
    UNTIL PC = '.';
    FOR IMTI := AA TO ZA DO
    BEGIN
      READ(INIFL1,PC);
      PD[IMTI] := PC;
    END;
    INISYN(PD);
    READ(INIFL1,PC);
  END;
  CLOSE(INIFL1,LOCK);
  
  (* LETS *)
  
  FKPSHD := 10;
  FKSANQ := 150;
  FMAXMT := 256;
  FNODEL := 100;
  FPADCR[F1] := 0;
  FPADCR[F2] := 0;
  FPADCR[F3] := 5;
  FPADCR[F4] := 10;
  FPADCR[F5] := 15;
  FPADCR[F6] := 5;
  FPADCR[F7] := 0;
  FPADCR[F8] := 0;
  FPBLOK := 20;
  FPCONN := 5;
  FPFLNX := 12;
  FRDUBL := 60;
  FRK7TH := 120;
  FTRADE := 36;
  FTRDSL := 5156;
  FTRPOK := 2;Š  FTRPWN := 8;
  FWKING := 50;
  FWMAJM := 1;
  FWMINM := 200;
  FWPAWN := 100;
  FWROOK := 2;
  WINDOW := 30;
  
  (* SWITCHES *)
  
  SWEC := FALSE;
  SWPA := FALSE;
  SWPS := FALSE;
  SWRE := TRUE;
  SWSU := FALSE;
  SWTR := FALSE;
  
  (* MAIN LOOP CONTROL VARIABLES *)
  
  GOING := 0;
  
END;


SEGMENT PROCEDURE READER; (* READ INPUT FROM USER *)

LABEL 11;

VAR
  INRA : RA;
  INTJ : TJ;
  RDCER, RDRCL : TB;
  
  PROCEDURE RDRCMD(A:RA; XXXCMD:TI);            FORWARD;
  
  PROCEDURE RDRERR(A:RN); (* PRINT DIAGNOSTIC AND EXIT *)
  VAR
    INTJ : TJ;
    INTN : TN;
  BEGIN
    IF NOT SWEC THEN
    BEGIN
      WRITE(' ');
      FOR INTJ := AJ TO ZJ-1 DO
        WRITE(ILINE[INTJ]);
      WRITELN;
    END;
    FOR INTJ := AJ TO JNTJ DO
      WRITE(' ');
    WRITE('^');
    FOR INTN := AN TO ZN DO
      WRITE(A[INTN]);
    WRITELN;
    IF NOT RDRCL THENŠ      EXIT(RDRCMD);
  END;
  
  FUNCTION RDRGNT(VAR A:RA):TB; (* GET NEXT TOKEN FROM COMMAND *)
  VAR INTJ : TJ;
  BEGIN
    WHILE (JNTJ < ZJ) AND (( NOT (ILINE[JNTJ] IN ['0'..'9'])) AND
                           ( NOT (ILINE[JNTJ] IN ['A'..'Z']))) DO
      JNTJ := JNTJ + 1;
    A := '          ';
    INTJ := AA;
    WHILE (JNTJ < ZJ) AND (INTJ < ZA) AND ((ILINE[JNTJ] IN ['0'..'9']) OR
                           (ILINE[JNTJ] IN ['A'..'Z'])) DO
    BEGIN
      A[INTJ] := ILINE[JNTJ];
      INTJ := INTJ + 1;
      JNTJ := JNTJ + 1;
    END;
    IF INTJ <> AA THEN
      RDRGNT := TRUE
    ELSE
      RDRGNT := FALSE;
    WHILE (INTJ < ZJ) AND ((ILINE[JNTJ] IN ['0'..'9']) OR
                           (ILINE[JNTJ] IN ['A'..'Z'])) DO
      JNTJ := JNTJ + 1;
  END;
  
  PROCEDURE RDRSFT; (* SKIP 1ST TOKEN IN COMMAND LINE *)
  VAR
    INRA : RA;
    INTB : TB;
  BEGIN
    JNTJ := AJ;
    INTB := RDRGNT(INRA);
  END;
  
  PROCEDURE RDLINE; (* GET NEXT INPUT LINE FROM USER *)
  VAR
    INTC : TC;
    INTJ : TJ;
  BEGIN
    INTJ := AJ;
    WHILE NOT EOLN AND (INTJ < ZJ) DO
    BEGIN
      READ(INTC);
      ICARD[INTJ] := INTC;
      INTJ := INTJ + 1;
    END;
    WHILE NOT EOLN DO
      READ(INTC);
    WHILE INTJ < ZJ DO
    BEGIN
      ICARD[INTJ] := ' ';
      INTJ := INTJ + 1;Š    END;
    ICARD[ZJ] := ';';
    JMTJ := AJ;
    READLN;
  END;
  
  FUNCTION RDRMOV:TB; (* EXTRACT NEXT COMMAND FROM INPUT LINE *)
  VAR IMTJ : TJ;
  BEGIN
    WHILE (JMTJ < ZJ) AND (ICARD[JMTJ] = ' ') DO
      JMTJ := JMTJ + 1;
    IMTJ := AJ;
    WHILE (JMTJ < ZJ) AND (ICARD[JMTJ] <> ';') DO
    BEGIN
      ILINE[IMTJ] := ICARD[JMTJ];
      IMTJ := IMTJ + 1;
      JMTJ := JMTJ + 1;
    END;
    IF (ICARD[JMTJ] = ';') AND (JMTJ < ZJ) THEN
      JMTJ := JMTJ + 1;
    IF IMTJ <> AJ THEN
      RDRMOV := TRUE
    ELSE
      RDRMOV := FALSE;
    WHILE IMTJ < ZJ DO
    BEGIN
      ILINE[IMTJ] := ' ';
      IMTJ := IMTJ + 1;
    END;
    ILINE[ZJ] := ';';
    JNTJ := AJ;
  END;
  
  FUNCTION RDRNUM:TI; (* CRACK NUMBER FROM COMMAND LINE *)
  VAR
    INTB : TB;
    INTI : TI;
  BEGIN
    WHILE (JNTJ < ZJ) AND (ILINE[JNTJ] = ' ') DO
      JNTJ := JNTJ + 1;
    IF ILINE[JNTJ] = '-' THEN
    BEGIN
      INTB := TRUE;
      JNTJ := JNTJ + 1;
    END
    ELSE
    BEGIN
    INTB := FALSE;
      IF ILINE[JNTJ] = '+' THEN
        JNTJ := JNTJ + 1;
    END;
    INTI := 0;
    WHILE ILINE[JNTJ] IN ['0'..'9'] DO
    BEGINŠ      IF INTI < MAXINT/10 THEN
        INTI := 10 * INTI + ORD(ILINE[JNTJ]) - ORD('0')
      ELSE
        RDRERR(' NUMBER TOO LARGE             ');
      JNTJ := JNTJ + 1;
    END;
    IF ILINE[JNTJ] IN ['A'..'Z'] THEN
      RDRERR(' DIGIT EXPECTED               ');
    IF INTB THEN
      INTI := -INTI;
    RDRNUM := INTI;
  END;
  
  PROCEDURE BOACMD; (* COMMAND - SET UP POSITION *)
  VAR
    INTM : TM;
    INTS : TS;
    
    PROCEDURE BOAADV(A:TI); (* ADVANCE N FILES *)
    BEGIN
      IF INTS+A < ZS THEN
        INTS := INTS + A
      ELSE
        INTS := ZS;
    END;
    
    PROCEDURE BOASTO(A:TP); (* STORE PIECE ON BOARD *)
    BEGIN
      BOARD.RBIS[INTS] := A;
      IF INTS < ZS THEN
        INTS := INTS + 1;
    END;
  
  BEGIN (* BOACMD *)
    RDCER := FALSE;
    CLSTAT;
    LSTMV := NULMV;
    FOR INTS := AS TO ZS DO
      BOARD.RBIS[INTS] := MT;
    INTM := LITE;
    INTS := 0;
    REPEAT
      IF ILINE[JNTJ] IN ['P','R','N','B','Q','K','L','D','1'..'8'] THEN
      CASE ILINE[JNTJ] OF
        'P': BOASTO(XTUMP[EP,INTM]);
        'R': BOASTO(XTUMP[ER,INTM]);
        'N': BOASTO(XTUMP[EN,INTM]);
        'B': BOASTO(XTUMP[EB,INTM]);
        'Q': BOASTO(XTUMP[EQ,INTM]);
        'K': BOASTO(XTUMP[EK,INTM]);
        'L': INTM := LITE;
        'D': INTM := DARK;
        '1','2','3','4','5','6','7','8':
             BOAADV(ORD(ILINE[JNTJ])-ORD('0'))Š      END
      ELSE
        IF (ILINE[JNTJ] IN ['0'..'9']) OR (ILINE[JNTJ] IN ['A'..'Z']) THEN
        BEGIN
          FOR INTS := AS TO ZS DO
            BOARD.RBIS[INTS] := MT;
          CLSTAT;
          RDRERR(' ILLEGAL BOARD OPTION         ');
        END;
      JNTJ := JNTJ + 1;
    UNTIL JNTJ = ZJ;
  END;
  
  PROCEDURE ENDCMD; (* COMMAND - END PROGRAM *)
  BEGIN
    CEND := TRUE;
    SWRE := TRUE;
    EXIT(YRMOVE);
  END;
  
  PROCEDURE GONCMD; (* COMMAND - GO N MOVES *)
  BEGIN
    GOING := RDRNUM;
    IF GOING <= 0 THEN
      GOING := 1;
    SWRE := TRUE;
    EXIT(YRMOVE);
  END;
  
  PROCEDURE INICMD; (* COMMAND - INITIALIZE FOR A NEW GAME *)
  BEGIN
    CINI := TRUE;
    SWRE := TRUE;
    EXIT(YRMOVE);
  END;
  
  PROCEDURE LETCMD; (* COMMAND - CHANGE VARIABLE *)
  VAR LTER : TB;
  
    PROCEDURE LETONE(A:RA; VAR B:TI); (* TEST FOR & SET 1 VARIABLE *)
    BEGIN
      IF A = INRA THEN
      BEGIN
        B := RDRNUM;
        LTER := FALSE;
      END;
    END;
    
  BEGIN
    RDCER := FALSE;
    IF RDRGNT(INRA) THEN
    BEGIN
      LTER := TRUE;
      LETONE('FKPSHD    ',FKPSHD);Š      LETONE('FKSANQ    ',FKSANQ);
      LETONE('FMAXMT    ',FMAXMT);
      LETONE('FNODEL    ',FNODEL);
      LETONE('FPADQR    ',FPADCR[F1]);
      LETONE('FPADQN    ',FPADCR[F2]);
      LETONE('FPADQB    ',FPADCR[F3]);
      LETONE('FPADQF    ',FPADCR[F4]);
      LETONE('FPADKF    ',FPADCR[F5]);
      LETONE('FPADKB    ',FPADCR[F6]);
      LETONE('FPADKN    ',FPADCR[F7]);
      LETONE('FPADKR    ',FPADCR[F8]);
      LETONE('FPBLOK    ',FPBLOK);
      LETONE('FPCONN    ',FPCONN);
      LETONE('FPFLNX    ',FPFLNX);
      LETONE('FRDUBL    ',FRDUBL);
      LETONE('FRK7TH    ',FRK7TH);
      LETONE('FTRADE    ',FTRADE);
      LETONE('FTRDSL    ',FTRDSL);
      LETONE('FTRPOK    ',FTRPOK);
      LETONE('FTRPWN    ',FTRPWN);
      LETONE('FWKING    ',FWKING);
      LETONE('FWMAJM    ',FWMAJM);
      LETONE('FWMINM    ',FWMINM);
      LETONE('FWPAWN    ',FWPAWN);
      LETONE('FWROOK    ',FWROOK);
      LETONE('WINDOW    ',WINDOW);
      IF LTER THEN
        RDRERR(' ILLEGAL LET VARIABLE NAME    ');
    END;
  END;
  
  PROCEDURE PLECMD; (* COMMAND - PRINT VARIABLE *)
  VAR PLER : TB;
    
    PROCEDURE PRIONE(A:RA; B:TI); (* TEST FOR & PRINT VARIABLE *)
    BEGIN
      IF INRA = A THEN
      BEGIN
        WRITELN(A,B);
        PLER := FALSE;;
      END;
    END;
  
  BEGIN
    RDCER := FALSE;
    WHILE RDRGNT(INRA) DO
    BEGIN
      PLER := TRUE;
      PRIONE('FKPSHD    ',FKPSHD);
      PRIONE('FKSANQ    ',FKSANQ);
      PRIONE('FMAXMT    ',FMAXMT);
      PRIONE('FNODEL    ',FNODEL);
      PRIONE('FPADQR    ',FPADCR[F1]);
      PRIONE('FPADQN    ',FPADCR[F2]);Š      PRIONE('FPADQB    ',FPADCR[F3]);
      PRIONE('FPADQF    ',FPADCR[F4]);
      PRIONE('FPADKF    ',FPADCR[F5]);
      PRIONE('FPADKB    ',FPADCR[F6]);
      PRIONE('FPADKN    ',FPADCR[F7]);
      PRIONE('FPADKR    ',FPADCR[F8]);
      PRIONE('FPBLOK    ',FPBLOK);
      PRIONE('FPCONN    ',FPCONN);
      PRIONE('FPFLNX    ',FPFLNX);
      PRIONE('FRDUBL    ',FRDUBL);
      PRIONE('FRK7TH    ',FRK7TH);
      PRIONE('FTRADE    ',FTRADE);
      PRIONE('FTRDSL    ',FTRDSL);
      PRIONE('FTRPOK    ',FTRPOK);
      PRIONE('FTRPWN    ',FTRPWN);
      PRIONE('FWKING    ',FWKING);
      PRIONE('FWMAJM    ',FWMAJM);
      PRIONE('FWMINM    ',FWMINM);
      PRIONE('FWPAWN    ',FWPAWN);
      PRIONE('FWROOK    ',FWROOK);
      PRIONE('WINDOW    ',WINDOW);
      IF PLER THEN
        RDRERR(' ILLEGAL VARIABLE NAME        ');
    END;
  END;
  
  PROCEDURE PRICMD; (* COMMAND - PRINT BOARD *)
  BEGIN
    RDCER := FALSE;
    IF RDRGNT(INRA) THEN
      PRINTB(NBORD)
    ELSE
      PRINTB(BOARD.RBIS);
  END;
  
  PROCEDURE PAMCMD; (* COMMAND - PRINT ATTACK MAP *)
  BEGIN
    RDCER := FALSE;
    WHILE RDRGNT(INRA) DO
      IF INRA[AA] = 'T' THEN
        PRINAM(ATKTO)
      ELSE
        IF INRA[AA] = 'F' THEN
          PRINAM(ATKFR)
        ELSE
          RDRERR(' ATTACK MAP NOT <TO> OR <FROM>');
  END;
  
  PROCEDURE POPCMD; (* COMMAND - PRINT OTHER STUFF *)
  VAR INTQ : TQ;
  BEGIN
    RDCER := FALSE;
    WITH BOARD DO
    BEGINŠ      WRITELN(XTMA[RBTM],' TO MOVE.');
      WRITELN(RBTS,' ENPASSANT.');
      WRITELN('MOVE NUMBER',RBTI);
      FOR INTQ := LS TO DL DO
        IF INTQ IN RBSQ THEN
          WRITELN(XTQA[INTQ],' SIDE CASTLE LEGAL.');
    END;
  END;
  
  PROCEDURE PMVCMD; (* COMMAND - PRINT MOVE LIST *)
  VAR INTW : TW;
  BEGIN
    RDCER := FALSE;
    LSTMOV;
    FOR INTW := AW TO JNTW-1 DO
    BEGIN
      WRITE(INTW:4,' ');
      PRIMOV(MOVES[INTW]);
      IF INTW/LPP = INTW DIV LPP THEN
        PAUSER;
    END;
  END;
  
  PROCEDURE SWICMD; (* COMMAND - FLIP SWITCH *)
  VAR SWER : TB;
  
    PROCEDURE SWIONE(A:RA; VAR B:TB); (* PROCESS 1 SWITCH *)
    VAR IMTJ : TJ;
    BEGIN
      IF INRA = A THEN
      BEGIN
        IMTJ := JNTJ;
        IF RDRGNT(INRA) THEN
        BEGIN
          IF INRA = 'ON        ' THEN
            B := TRUE
          ELSE
            IF INRA = 'OFF       ' THEN
              B := FALSE
            ELSE
              JNTJ := IMTJ;
          PRISWI(A,B);
        END
        ELSE
          PRISWI(A,B);
        SWER := FALSE;
      END;
    END;
    
  BEGIN
    RDCER := FALSE;
    WHILE RDRGNT(INRA) DO
    BEGIN
      SWER := TRUE;Š      SWIONE('EC        ',SWEC);
      SWIONE('PA        ',SWPA);
      SWIONE('PS        ',SWPS);
      SWIONE('RE        ',SWRE);
      SWIONE('SU        ',SWSU);
      SWIONE('TR        ',SWTR);
      IF SWER THEN
        RDRERR(' INVALID SWITCH OPTION        ');
    END;
  END;
  
  PROCEDURE STACMD; (* COMMAND - STATUS CHANGES *)
  LABEL 21;
  VAR
    INRA : RA;
    INTM : TM;
    STER : TB;
    
    PROCEDURE STAENP;           FORWARD;
    
    PROCEDURE STAEPF(A:RA; B:TF); (* PROCESS EP FILE *)
    BEGIN
      IF A = INRA THEN
      BEGIN
        IF INTM = LITE THEN
          BOARD.RBTS := XTRFS[R6,B]
        ELSE
          BOARD.RBTS := XTRFS[R3,B];
        STER := FALSE;
        EXIT(STAENP);
      END;
    END;
    
    PROCEDURE STACAK; (* ALLOW CASTLE KING SIDE *)
    BEGIN
      IF INTM = LITE THEN
        BOARD.RBSQ := BOARD.RBSQ + [LS]
      ELSE
        BOARD.RBSQ := BOARD.RBSQ + [DS];
    END;
    
    PROCEDURE STACAQ; (* ALLOW CASTLE QUEEN SIDE *)
    BEGIN
      IF INTM = LITE THEN
        BOARD.RBSQ := BOARD.RBSQ + [LL]
      ELSE
        BOARD.RBSQ := BOARD.RBSQ + [DL];
    END;
    
    PROCEDURE STADRK; (* SET BLACK OPTIONS *)
    BEGIN
      INTM := DARK;
    END;
    Š    PROCEDURE STAENP; (* SET ENPASSANT FILE *)
    BEGIN
      IF NOT RDRGNT(INRA) THEN
      BEGIN
        CLSTAT;
        RDRERR(' ENPASSANT FILE OMITTED       ');
      END;
      STAEPF('QR        ',F1);
      STAEPF('QN        ',F2);
      STAEPF('QB        ',F3);
      STAEPF('Q         ',F4);
      STAEPF('K         ',F5);
      STAEPF('KB        ',F6);
      STAEPF('KN        ',F7);
      STAEPF('KR        ',F8);
      CLSTAT;
      RDRERR(' ILLEGAL ENPASSANT FILE       ');
    END;
    
    PROCEDURE STAGOS; (* SET SIDE TO MOVE *)
    BEGIN
      BOARD.RBTM := INTM;
      JNTM := INTM;
    END;
    
    PROCEDURE STALIT; (* SET WHITE OPTIONS *)
    BEGIN
      INTM := LITE;
    END;
    
    PROCEDURE STANUM; (* SET MOVE NUMBER *)
    BEGIN
      BOARD.RBTI := RDRNUM;
    END;
    
    PROCEDURE STAOPT(A:RA; STAXXX:TI); (* TEST STATUS OPTION *)
    BEGIN
      IF INRA = A THEN
      BEGIN
        CASE STAXXX OF
          1 : STADRK;
          2 : STAENP;
          3 : STAGOS;
          4 : STALIT;
          5 : STANUM;
          6 : STACAK;
          7 : STACAQ
        END;
        STER := FALSE;
      END;
    END;
    
  BEGIN (* STACMD *)
    RDCER := FALSE;Š    CLSTAT;
    INTM := LITE;
21: WHILE RDRGNT(INRA) DO
    BEGIN
      STER := TRUE;
      STAOPT('D         ',1);
      STAOPT('EP        ',2);
      STAOPT('G         ',3);
      STAOPT('L         ',4);
      STAOPT('N         ',5);
      STAOPT('OO        ',6);
      STAOPT('OOO       ',7);
      IF STER THEN
      BEGIN
        CLSTAT;
        RDRERR(' INVALID STATUS OPTION        ');
      END;
    END;
  END;
  
  PROCEDURE WHACMD; (* COMMAND - WHAT? *)
  BEGIN
    RDCER := FALSE;
    WRITELN(MOVMS);
  END;
  
  PROCEDURE RDRCMD; (* TEST FOR AND EXECUTE COMMAND *)
  BEGIN
    IF INRA = A THEN
    BEGIN
      CASE XXXCMD OF
        1 : BOACMD;
        2 : ENDCMD;
        3 : GONCMD;
        4 : INICMD;
        5 : LETCMD;
        6 : PAMCMD;
        7 : POPCMD;
        8 : PLECMD;
        9 : PMVCMD;
        10: PRICMD;
        11: STACMD;
        12: SWICMD;
        13: WHACMD
      END;
      RDCER:= FALSE;
    END;
  END; (* RDRCMD *)
  
BEGIN (* READER *)
11: (* COMMAND EXIT *)
  WHILE NOT RDRMOV DO
    RDLINE;
  IF SWEC THENŠ  BEGIN
    WRITE(' ');
    FOR INTJ := AJ TO ZJ-1 DO
      WRITE(ILINE[INTJ]);
    WRITELN;
  END;
  IF ILINE[AJ+1] IN ['A'..'W','Y','Z'] THEN
  BEGIN
    INRA := '          ';
    INRA[AA] := ILINE[AJ];
    INRA[AA+1] := ILINE[AJ+1];
    RDRSFT;
    RDCER := TRUE;
    RDRCL := FALSE;
    RDRCMD('BO        ',1);
    RDRCMD('EN        ',2);
    RDRCMD('GO        ',3);
    RDRCMD('IN        ',4);
    RDRCMD('LE        ',5);
    RDRCMD('PB        ',6);
    RDRCMD('PO        ',7);
    RDRCMD('PL        ',8);
    RDRCMD('PM        ',9);
    RDRCMD('PR        ',10);
    RDRCMD('ST        ',11);
    RDRCMD('SW        ',12);
    RDRCMD('WH        ',13);
    IF RDCER THEN
    BEGIN
      RDRCL := TRUE;
      RDRERR(' INVALID COMMAND              ');
    END;
    GOTO 11;
  END;
END; (* READER *)




FUNCTION MAX(A,B:TI):TI;        (* LARGER OF TWO NUMBERS *)
BEGIN
  IF A > B THEN
    MAX := A
  ELSE
    MAX := B;
END;

FUNCTION MIN(A,B:TI):TI;        (* SMALLER OF TWO NUMBERS *)
BEGIN
  IF A < B THEN
    MIN := A
  ELSE
    MIN := B
END;Š
FUNCTION SIGN(A,B:TI):TI;       (* SIGN OF B APPLIED TO *)
BEGIN                           (* ABSOLUTE VALUE OF A *)
  IF B = 0 THEN
    SIGN := 1 * ABS(A)
  ELSE
    SIGN := TRUNC(B/ABS(B)) * ABS(A);
END;

PROCEDURE SORTIT(VAR A:RE; VAR B:RF; C:TW); (* SORT PRELIMINARY SCORES *)
  VAR
    INTB : TB;
    INTW : TW;
    INTI : TI;
    INTV : TV;
    INRM : RM;
  BEGIN
    FOR INTW := AW+2 TO C DO
    BEGIN
      INTI := INTW - 1;
      INTV := A[INTW];
      INRM := B[INTW];
      INTB := TRUE;
      WHILE (INTI > AW) AND INTB DO
        IF INTV < A[INTI] THEN
          BEGIN
            A[INTI+1] := A[INTI];
            B[INTI+1] := B[INTI];
            INTI := INTI - 1;
          END
        ELSE
          INTB := FALSE;
      A[INTI+1] := INTV;
      B[INTI+1] := INRM;
    END;
  END;

PROCEDURE ANDRS; (* INTERSECTION OF 2 BIT BOARDS *)
VAR INTY : TY;
BEGIN
  FOR INTY := AY TO ZY DO
    C.RSSS[INTY] := A.RSSS[INTY] * B.RSSS[INTY];
END;

PROCEDURE CLRRS(VAR C:RS; A:TS); (* REMOVE SQUARE FROM BIT BOARD *)
BEGIN
  C.RSSS[XTSY[A]] := C.RSSS[XTSY[A]] - XSSX[A];
END;

PROCEDURE CPYRS; (* COPY OF A BIT BOARD *)
VAR INTY : TY;
BEGIN
  FOR INTY := AY TO ZY DO
    C.RSSS[INTY] := A.RSSS[INTY];ŠEND;

PROCEDURE IORRS; (* UNION OF 2 BIT BOARDS *)
VAR INTY : TY;
BEGIN
  FOR INTY := AY TO ZY DO
    C.RSSS[INTY] := A.RSSS[INTY] + B.RSSS[INTY];
END;

PROCEDURE NEWRS; (* CLEAR BIT BOARD *)
VAR INTY : TY;
BEGIN
  FOR INTY := AY TO ZY DO
    A.RSSS[INTY] := [];
END;

PROCEDURE NOTRS; (* COMPLIMENT OF A BIT BOARD *)
VAR INTY : TY;
BEGIN
  FOR INTY := AY TO ZY DO
    C.RSSS[INTY] := [AX..ZX] - A.RSSS[INTY];
END;

FUNCTION NXTTS(VAR A:RS; VAR B:TS):TB; (*NEXT ELEMENT IN BIT BOARD *)
LABEL 11;
VAR
  INTX : TX;
  INTY : TY;
BEGIN
  FOR INTY := ZY DOWNTO AY DO
    IF A.RSTI[INTY] <> 0 THEN
      BEGIN
        FOR INTX := ZX DOWNTO AX DO
          IF INTX IN A.RSSS[INTY] THEN
            BEGIN
              B := INTX + INTY * (ZX+1);
              A.RSSS[INTY] := A.RSSS[INTY] - [INTX];
              NXTTS := TRUE;
              GOTO 11;
            END;
      END;
    NXTTS := FALSE;
11:
END;

FUNCTION CNTRS(A:RS):TS; (* COUNT MEMBERS OF A BIT BOARD *)
VAR
  INTY : TY;
  INTS : TS;
  IMRS : RS;
  IMTS : TS;
BEGIN
  INTS := 0;
  CPYRS(IMRS,A);Š  WHILE NXTTS(IMRS,IMTS) DO
    INTS := INTS + 1;
  CNTRS := INTS;
END;

PROCEDURE SETRS; (* INSERT SQUARE INTO BIT BOARD *)
BEGIN
  C.RSSS[XTSY[A]] := C.RSSS[XTSY[A]] + XSSX[A];
END;

PROCEDURE SFTRS(VAR A:RS; B:RS; C:TE); (* SHIFT BIT BOARD *)
VAR
  INRS : RS;
  INTS : TS;
  INTY : TY;
BEGIN
  NEWRS(A);
  WHILE NXTTS(B,INTS) DO
    IF XTLS[XTSL[INTS]+XTED[C]] > 0 THEN
      SETRS(A,XTLS[XTSL[INTS]+XTED[C]]);
END;

FUNCTION INRSTB(A:RS; B:TS):TB; (* SQUARE IN BIT BOARD BOOLEAN *)
BEGIN
  IF XSSX[B] <= A.RSSS[XTSY[B]] THEN
    INRSTB := TRUE
  ELSE
    INRSTB := FALSE;
END;

FUNCTION NULRS(A:RS):TB; (* NULL BIT BOARD *)
VAR
  INTY : TY;
  INTB, INXB : TB;
BEGIN
  INTB := TRUE;
  FOR INTY := AY TO ZY DO
  BEGIN
    IF A.RSTI[INTY] = 0 THEN
      INXB := TRUE
    ELSE
      INXB := FALSE;
    INTB := INTB AND INXB;
  END;
  NULRS := INTB;
END;

FUNCTION NULMVB(A:RM):TB; (* NULL MOVE BOOLEAN *)
BEGIN
  WITH A DO
    IF RMAC AND RMPR AND (NOT RMCA) THEN
      NULMVB := TRUE
    ELSE
      NULMVB := FALSE;ŠEND;

PROCEDURE INICON; (* INITIALIZE CONSTANTS *)
BEGIN
  INICON1;
  INICON2;
  INICON3;
  INICON4;
END;

PROCEDURE INITIAL(VAR A:RB); (* INITIALIZE FOR A NEW GAME *)
VAR
  INTF : TF;
  INTR : TR;
BEGIN
  WITH A DO
  BEGIN
    RBTM := LITE;
    RBTS := -1;
    RBTI := 0;
    RBSQ := [LS,LL,DS,DL];
    FOR INTF := F1 TO F8 DO
    BEGIN
      RBIRF[R2,INTF] := LP;
      FOR INTR := R3 TO R6 DO
        RBIRF[INTR,INTF] := MT;
      RBIRF[R7,INTF] := DP;
    END;
    RBIRF[R1,F1] := LR;
    RBIRF[R1,F2] := LN;
    RBIRF[R1,F3] := LB;
    RBIRF[R1,F4] := LQ;
    RBIRF[R1,F5] := LK;
    RBIRF[R1,F6] := LB;
    RBIRF[R1,F7] := LN;
    RBIRF[R1,F8] := LR;
    RBIRF[R8,F1] := DR;
    RBIRF[R8,F2] := DN;
    RBIRF[R8,F3] := DB;
    RBIRF[R8,F4] := DQ;
    RBIRF[R8,F5] := DK;
    RBIRF[R8,F6] := DB;
    RBIRF[R8,F7] := DN;
    RBIRF[R8,F8] := DR;
    MOVMS := ' ENTER MOVE OR TYPE GO.       ';
    WRITELN(MOVMS);
    LSTMV := NULMV;
  END;
END;

PROCEDURE PAUSER; (* PAUSE FOR CARRIAGE RETURN *)
BEGIN
  IF SWPA THEN
    BEGINŠ      WRITELN(' PAUSING ');
      READLN;
    END;
END;

PROCEDURE PRIMOV;  (* PRINT A MOVE *)
BEGIN
  WITH A DO
    BEGIN
      WRITE(' FROM ',RMFR:2,' TO ',RMTO:2);
      IF NULMVB(A) THEN
        WRITE(', NULL MOVE')
      ELSE
        BEGIN
          IF RMCA THEN
            WRITE(', CAPTURE ',XTPC[RMCP],',')
          ELSE
            WRITE(', SIMPLE,');
          IF NOT RMAC THEN
            WRITE(' NO');
          WRITE (' ACS');
          IF RMCH THEN
            WRITE(', CHECK');
          IF RMMT THEN
            WRITE(' MATE');
          IF RMIL THEN
            WRITE(', ILLEGAL');
          IF RMSU THEN
            WRITE(', SEARCHED');
          CASE RMPR OF
            FALSE :
              CASE RMOO OF
                FALSE :
                  IF RMEP THEN
                    WRITE(', ENPASSANT');
                TRUE :
                  BEGIN
                    WRITE(', CASTLE-');
                    IF RMQS THEN
                      WRITE('LONG')
                    ELSE
                      WRITE('SHORT');
                  END
              END;
            TRUE :
              BEGIN
                WRITE(', PROMOTE TO ');
                CASE RMPP OF
                  PQ: WRITE('QUEEN');
                  PR: WRITE('ROOK');
                  PB: WRITE('BISHOP');
                  PN: WRITE('KNIGHT')
                END;
              ENDŠ          END;
        END;
      END;
  WRITELN('.');
END;

PROCEDURE PTRMOV;  (* PRINT A MOVE ON SYSTEM PRINTER *)
BEGIN
  WITH A DO
    BEGIN
      WRITE(PRNTR,' FROM ',RMFR:2,' TO ',RMTO:2);
      IF NULMVB(A) THEN
        WRITE(PRNTR,', NULL MOVE')
      ELSE
        BEGIN
          IF RMCA THEN
            WRITE(PRNTR,', CAPTURE ',XTPC[RMCP],',')
          ELSE
            WRITE(PRNTR,', SIMPLE,');
          IF NOT RMAC THEN
            WRITE(PRNTR,' NO');
          WRITE (PRNTR,' ACS');
          IF RMCH THEN
            WRITE(PRNTR,', CHECK');
          IF RMMT THEN
            WRITE(PRNTR,' MATE');
          IF RMIL THEN
            WRITE(PRNTR,', ILLEGAL');
          IF RMSU THEN
            WRITE(PRNTR,', SEARCHED');
          CASE RMPR OF
            FALSE :
              CASE RMOO OF
                FALSE :
                  IF RMEP THEN
                    WRITE(PRNTR,', ENPASSANT');
                TRUE :
                  BEGIN
                    WRITE(PRNTR,', CASTLE-');
                    IF RMQS THEN
                      WRITE(PRNTR,'LONG')
                    ELSE
                      WRITE(PRNTR,'SHORT');
                  END
              END;
            TRUE :
              BEGIN
                WRITE(PRNTR,', PROMOTE TO ');
                CASE RMPP OF
                  PQ: WRITE(PRNTR,'QUEEN');
                  PR: WRITE(PRNTR,'ROOK');
                  PB: WRITE(PRNTR,'BISHOP');
                  PN: WRITE(PRNTR,'KNIGHT')
                END;Š              END
          END;
        END;
      END;
  WRITELN(PRNTR,'.');
END;

PROCEDURE PRINTB; (* PRINT A BOARD *)
VAR
  INTR : TR;
  INTF : TF;
BEGIN
  WRITELN;
  FOR INTR := R8 DOWNTO R1 DO
    BEGIN
      WRITE(' ',ORD(INTR)+1:1,' ');
      FOR INTF := F1 TO F8 DO
        WRITE(XTPC[A[XTRFS[INTR,INTF]]]);
      WRITELN;
    END;
  WRITELN(' W RNBQKBNR');
END;

PROCEDURE PRINAM; (* PRINT ATTACK MAP *)
VAR
  INTR, JNTR : TR;
  INTF, JNTF : TF;
BEGIN
  WRITELN;
  FOR INTR := R8 DOWNTO R1 DO
  BEGIN
    FOR JNTR := R8 DOWNTO R1 DO
    BEGIN
      FOR INTF := F1 TO F8 DO
      BEGIN
        WRITE(' ');
        FOR JNTF := F1 TO F8 DO
        BEGIN
          WRITE(XTBC[INRSTB(A[XTRFS[INTR,INTF]],XTRFS[JNTR,JNTF])]);
        END;
        WRITE(' ');
      END;
      WRITELN;
    END;
    WRITELN;
    IF INTR IN [R1,R3,R5,R7] THEN
      PAUSER;
  END;
END;

PROCEDURE PRISWI;  (* PRINT A SWITCH*)
BEGIN
  WRITE(' ',A[AA],A[AA+1]);
  IF B THENŠ    WRITELN(' ON')
  ELSE
    WRITELN(' OFF');
END;

PROCEDURE MBEVAL; (* EVALUATE MATERIAL BALANCE *)
VAR
  INTI, IAA, IMB : TI;
  RMA, RFA, RFB : TZ;
  RFMAXMT, RMBLTE, RFTRADE, RFTRDSL : TZ;
  RMBTOT, RINTI, RFTRPOK, RFTRPWN : TZ;
BEGIN
  IF MBLTE <> 0 THEN
    IF MBLTE > 0 THEN
      INTI := MBPWN[LITE]
    ELSE
      INTI := MBPWN[DARK]
  ELSE
    INTI := 0;
  (*MBVAL[JNTK] := SIGN(MIN(MIN(FMAXMT,ABS(MBLTE))
               +FTRADE*ABS(MBLTE)*(FTRDSL-MBTOT)*(4*INTI+FTRPOK)
               DIV (4*INTI+FTRPWN) DIV 262144,16320),MBLTE);*)
  RFMAXMT := FMAXMT;
  RMBLTE  := MBLTE;
  RFTRADE := FTRADE;
  RFTRDSL := FTRDSL;
  RMBTOT  := MBTOT;
  RINTI   := INTI;
  RFTRPOK := FTRPOK;
  RFTRPWN := FTRPWN;
  RMA := MIN(FMAXMT,ABS(MBLTE));
  RFA := RMA+RFTRADE*ABS(RMBLTE)*(RFTRDSL-RMBTOT)*(4.0*RINTI+RFTRPOK);
  RFB := 4.0 * RINTI + RFTRPWN;
  IAA := TRUNC(RFA/RFB/262144.0);
  IMB := MIN(IAA,16320);
  MBVAL[JNTK] := SIGN(IMB,MBLTE);
END;

PROCEDURE MBCAPT(A:TP); (* EVALUATE MATERIAL AFTER CAPTURE *)
BEGIN
  MBTOT := MBTOT - ABS(XTPV[A]);
  IF XTPU[A] = EP THEN
    MBPWN[XTPM[A]] := MBPWN[XTPM[A]] - 1;
  MBLTE := MBLTE - XTPV[A];
  MBEVAL;
END;

PROCEDURE MBTPAC(A:TP); (* RMV CAPTURE FROM MATERIAL BALANCE DATA *)
BEGIN
  MBTOT := MBTOT + ABS(XTPV[A]);
  IF XTPU[A] = EP THEN
    MBPWN[XTPM[A]] := MBPWN[XTPM[A]] + 1;
  MBLTE := MBLTE + XTPV[A];
END;Š
PROCEDURE MBPROM(A:TP); (* EVAL MTRL BAL CHG DUE TO PAWN PROMOTION *)
    BEGIN
  MBTOT := MBTOT + ABS(XTPV[A]-XTPV[XTUMP[EP,XTPM[A]]]);
  MBPWN[XTPM[A]] := MBPWN[XTPM[A]] - 1;
  MBLTE := MBLTE + XTPV[A] - XTPV[XTUMP[EP,XTPM[A]]];
  MBEVAL;
END;

PROCEDURE MBMORP(A:TP); (* RMV PAWM PROMOTION FROM MTRL BAL DATA *)
BEGIN
  MBTOT := MBTOT - ABS(XTPV[A] - XTPV[XTUMP[EP,XTPM[A]]]);
  MBPWN[XTPM[A]] := MBPWN[XTPM[A]] + 1;
  MBLTE := MBLTE - (XTPV[A] - XTPV[XTUMP[EP,XTPM[A]]]);
END;

PROCEDURE ADDATK(A:TS); (* ADD ATTACKS OF PIECE TO DATA BASE *)
VAR
  INTB : TB;
  INTD : TD;
  INTE : TE;
  INTM : TM;
  INTP : TP;
  INTT : TT;
BEGIN
  INTP := NBORD[A];
  INTM := XTPM[INTP];
  FOR INTE := XFPE[INTP] TO XLPE[INTP] DO
  BEGIN
    INTT := A;
    INTB := XSPB[INTP];
    INTD := XTED[INTE];
    REPEAT
      INTT := XTLS[XTSL[INTT] + INTD];
      IF INTT >= 0 THEN
      BEGIN
        SETRS(ATKFR[A],INTT);
        SETRS(ATKTO[INTT],A);
        SETRS(ALATK[INTM],INTT);
        IF NBORD[INTT] <> MT THEN
          INTB := FALSE;
      END
      ELSE
        INTB := FALSE;
    UNTIL NOT INTB;
  END;
END;

PROCEDURE ADDLOC(A:TS; B:TP); (* ADD PIECE TO DATA BASE *)
BEGIN
  CLRRS(TPLOC[MT],A);
  SETRS(TPLOC[B],A);
  SETRS(TMLOC[XTPM[B]],A);
  SETRS(ALLOC[JNTK],A);Š  NBORD[A] := B;
END;

PROCEDURE CLSTAT; (* CLEAR POSITION STATUS *)
BEGIN
  WITH BOARD DO
  BEGIN
    RBTM := LITE;
    RBTS := -1;
    RBSQ := [];
  END;
END;

PROCEDURE CUTATK(A:TS); (* CUT ATTACKS THROUGH SQUARE *)
VAR
  INRS : RS;
  INTS : TS;
  IMRS : RS;
  INTD : TD;
  INTM : TM;
  INTL : TL;
  INTT : TT;
BEGIN
  CPYRS(INRS,ATKTO[A]);
  WHILE NXTTS(INRS,INTS) DO
    IF XSPB[NBORD[INTS]] THEN
    BEGIN
      INTD := XLLD[XTSL[A] - XTSL[INTS]];
      INTM := XTPM[NBORD[INTS]];
      INTL := XTSL[A] + INTD;
      INTT := XTLS[INTL];
      WHILE INTT > AT DO
      BEGIN
        CLRRS(ATKFR[INTS],INTT);
        CLRRS(ATKTO[INTT],INTS);
        ANDRS(IMRS,ATKTO[INTT],TMLOC[INTM]);
        IF NULRS(IMRS) THEN
          CLRRS(ALATK[INTM],INTT);
        IF NBORD[INTT] = MT THEN
        BEGIN
          INTL := INTL + INTD;
          INTT := XTLS[INTL];
        END
        ELSE
          INTT := AT;
      END;
  END;
END;

PROCEDURE DELATK(A:TS); (* DELETE ATTACKS FROM SQUARE *)
VAR
  INRS : RS;
  IMRS : RS;
  INTS : TS;Š  INTM : TM;
BEGIN
  CPYRS(INRS,ATKFR[A]);
  NEWRS(ATKFR[A]);
  INTM := XTPM[NBORD[A]];
  WHILE NXTTS(INRS,INTS) DO
  BEGIN
    CLRRS(ATKTO[INTS],A);
    ANDRS(IMRS,ATKTO[INTS],TMLOC[INTM]);
    IF NULRS(IMRS) THEN
      CLRRS(ALATK[INTM],INTS);
    CLRRS(TPLOC[NBORD[A]],A);
    CLRRS(TMLOC[INTM],A);
    CLRRS(ALLOC[JNTK],A);
    SETRS(TPLOC[MT],A);
    NBORD[A] := MT;
  END;
END;

PROCEDURE PRPATK(A:TS); (* PROPAGATE ATTACKS THROUGH SQUARE *)
VAR
  INRS : RS;
  INTS : TS;
  INTD : TD;
  INTM : TM;
  INTL : TL;
  INTT : TT;
BEGIN
  CPYRS(INRS,ATKTO[A]);
  WHILE NXTTS(INRS,INTS) DO
    IF XSPB[NBORD[INTS]] THEN
    BEGIN
      INTD := XLLD[XTSL[A] - XTSL[INTS]];
      INTM := XTPM[NBORD[INTS]];
      INTL := XTSL[A] + INTD;
      INTT := XTLS[INTL];
      WHILE INTT >= 0 DO
      BEGIN
        SETRS(ATKFR[INTS],INTT);
        SETRS(ATKTO[INTT],INTS);
        SETRS(ALATK[INTM],INTT);
        IF NBORD[INTT] = MT THEN
        BEGIN
          INTL := INTL + INTD;
          INTT := XTLS[INTL];
        END
        ELSE
          INTT := -1;
      END;
    END;
END;

PROCEDURE GAINIT(A:RM); (* UNPROCESS CAPTURE MOVE *)
BEGINŠ  WITH A DO
  BEGIN
    ADDLOC(RMFR,NBORD[RMTO]);
    ADDATK(RMFR);
    CUTATK(RMFR);
    DELATK(RMTO);
    ADDLOC(RMTO,RMCP);
    ADDATK(RMTO);
    MBTPAC(NBORD[RMTO]);
  END;
END;

PROCEDURE LOSEIT(A:RM); (* PROCESS CAPTURE MOVE *)
BEGIN
  WITH A DO
  BEGIN
    MBCAPT(NBORD[RMTO]);
    DELATK(RMTO);
    ADDLOC(RMTO,NBORD[RMFR]);
    DELATK(RMFR);
    PRPATK(RMFR);
    ADDATK(RMTO);
  END;
END;

PROCEDURE MOVEIT(A:RM); (* PROCESS ORDINARY MOVE *)
BEGIN
  WITH A DO
  BEGIN
    ADDLOC(RMTO,NBORD[RMFR]);
    CUTATK(RMTO);
    DELATK(RMFR);
    PRPATK(RMFR);
    ADDATK(RMTO);
  END;
END;

PROCEDURE RTRKIT(A:RM); (* UNPROCESS ORDINARY MOVE *)
BEGIN
  WITH A DO
  BEGIN
    ADDLOC(RMFR,NBORD[RMTO]);
    CUTATK(RMFR);
    DELATK(RMTO);
    PRPATK(RMTO);
    ADDATK(RMFR);
  END;
END;

PROCEDURE PAWNIT(A:RM); (* UNPROMOTE A PAWN *)
BEGIN
  WITH A DO
  BEGIN
    MBMORP(NBORD[RMTO]);Š    NBORD[RMTO] := XTUMP[EP,XTPM[NBORD[RMTO]]];
  END;
END;

PROCEDURE PROACA(A:TS); (* PROCESS CASTLE STATUS CHANGES *)
VAR
  INRS : RS;
  IMRS : RS;
BEGIN
  CLRRS(CSTAT[JNTK],A);
  ANDRS(INRS,CSTAT[JNTK],XRRS[XTSR[A]]);
  IF NOT INRSTB(INRS,XTRFS[XTSR[A],F5]) THEN
    ANDRS(CSTAT[JNTK],CSTAT[JNTK],XNRS[XTSR[A]]);
  ANDRS(IMRS,INRS,XRFS[F8]);
  ANDRS(INRS,INRS,XRFS[F1]);
  IORRS(INRS,INRS,IMRS);
  IF NULRS(INRS) THEN
    ANDRS(CSTAT[JNTK],CSTAT[JNTK],XNRS[XTSR[A]]);
END;

PROCEDURE PROACS(A:RM); (* PROCESS MOVES AFFECTING CASTLE STATUS *)
BEGIN
  WITH A DO
  BEGIN
    IF INRSTB(CSTAT[JNTK],RMFR) THEN
      PROACA(RMFR);
    IF INRSTB(CSTAT[JNTK],RMTO) THEN
      PROACA(RMTO);
  END;
END;

PROCEDURE PROMOT(A:RM); (* PROCESS PROMOTION *)
BEGIN
  WITH A DO
  BEGIN
    MBPROM(XTGMP[RMPP,JNTM]);
    NBORD[RMFR] := XTGMP[RMPP,JNTM];
  END;
END;


PROCEDURE CREATE; (* CREATE GLOBAL DATA BASE *)
VAR
  INRS : RS;
  INTM : TM;
  INTP : TP;
  INTQ : TQ;
  INTS : TS;
BEGIN
  WITH BOARD DO
  BEGIN
    JNTW := AW + 1;
    JNTK := AK;
    JNTM := RBTM;Š    NODES := 0;
    LINDX[JNTK] := JNTW;
    SRCHM[JNTK] := H0;
    FOR INTS := AS TO ZS DO
    BEGIN
      NEWRS(ATKFR[INTS]);
      NEWRS(ATKTO[INTS]);
      NBORD[INTS] := MT;
    END;
    NEWRS(ALLOC[JNTK]);
    FOR INTP := LP TO MT DO
      NEWRS(TPLOC[INTP]);
    FOR INTM := LITE TO NONE DO
    BEGIN
      NEWRS(TMLOC[INTM]);
      NEWRS(ALATK[INTM]);
    END;
    MBTOT := 0;
    MBPWN[LITE] := 0;
    MBPWN[DARK] := 0;
    MBLTE := 0;
    FOR INTS := AS TO ZS DO
      IF RBIS[INTS] <> MT THEN
      BEGIN
        ADDLOC(INTS,RBIS[INTS]);
        MBTPAC(RBIS[INTS]);
      END
      ELSE
        SETRS(TPLOC[MT],INTS);
    MBEVAL;
    CPYRS(INRS,ALLOC[JNTK]);
    WHILE NXTTS(INRS,INTS) DO
      ADDATK(INTS);
    NEWRS(CSTAT[JNTK]);
    FOR INTQ := LS TO DL DO
      IF INTQ IN RBSQ THEN
        IORRS(CSTAT[JNTK],CSTAT[JNTK],XSQS[INTQ]);
    NEWRS(ENPAS[JNTK]);
    IF RBTS >= 0 THEN
      SETRS(ENPAS[JNTK],RBTS);
    CPYRS(GENPN[JNTK],TPLOC[XTUMP[EP,JNTM]]);
    NOTRS(GENTO[JNTK],TMLOC[JNTM]);
    NOTRS(INRS,GENPN[JNTK]);
    ANDRS(GENFR[JNTK],TMLOC[JNTM],INRS);
  END;
END;

PROCEDURE DNDATE(A:RM); (* DOWNDATE DATA BASE TO BACK OUT A MOVE *)
VAR
  INTS : TS;
  INTR : TR;
  INTF : TF;
  RKFR : TS;
  RKTO : TS;ŠBEGIN
  WITH A DO
  BEGIN
    CASE ORD(RMCA)*4 + ORD(RMAC)*2 + ORD(RMPR) OF
      0: RTRKIT(A);
      1: BEGIN
           PAWNIT(A);
           RTRKIT(A);
         END;
      2: IF RMOO THEN
         BEGIN
           IF RMQS THEN
             INTF := F1
           ELSE
             INTF := F8;
           INTR := XTSR[RMFR];
           RKFR := XTRFS[INTR,INTF];
           RKTO := (RMFR+RMTO) DIV 2;
           ADDLOC(RKFR,NBORD[RKTO]);
           DELATK(RKTO);
           PRPATK(RKTO);
           ADDATK(RKFR);
           RTRKIT(A);
         END
         ELSE
           RTRKIT(A);
      3: ;
      4: IF RMEP THEN
         BEGIN
           INTS := XTRFS[XTSR[RMFR],XTSF[RMTO]];
           ADDLOC(INTS,RMCP);
           CUTATK(INTS);
           ADDATK(INTS);
           RTRKIT(A);
           MBTPAC(NBORD[INTS]);
         END
         ELSE
           GAINIT(A);
      5: BEGIN
           PAWNIT(A);
           GAINIT(A);
         END;
      6: GAINIT(A);
      7: BEGIN
           PAWNIT(A);
           GAINIT(A);
         END
    END;
    JNTW := LINDX[JNTK];
    JNTK := JNTK - 1;
    JNTM := OTHER[JNTM];
  END;
END;
ŠFUNCTION UPDATE(VAR A:RM):TB; (* UPDATE DATA BASE FOR A MOVE *)
VAR
  INRS : RS;
  IMRS : RS;
  INTS : TS;
  INTF : TF;
  INTR : TR;
  RKTO : TS;
  RKFR : TS;
BEGIN
  WITH A DO
  BEGIN
    JNTK := JNTK + 1;
    NEWRS(ENPAS[JNTK]);
    CPYRS(CSTAT[JNTK],CSTAT[JNTK-1]);
    CPYRS(ALLOC[JNTK],ALLOC[JNTK-1]);
    MBVAL[JNTK] := MBVAL[JNTK-1];
    LINDX[JNTK] := JNTW;
    CASE ORD(RMCA) * 4 + ORD(RMAC) * 2 + ORD(RMPR) OF
      0: IF RMEP THEN
         BEGIN
           SFTRS(INRS,XRSS[RMTO],S1);
           SFTRS(IMRS,XRSS[RMTO],S3);
           IORRS(INRS,INRS,IMRS);
           ANDRS(INRS,INRS,TPLOC[XTUMP[EP,OTHER[JNTM]]]);
           IF NOT NULRS(INRS) THEN
             SETRS(ENPAS[JNTK],(RMTO+RMFR) DIV 2);
           MOVEIT(A);
         END
         ELSE
           MOVEIT(A);
      1: BEGIN
           PROMOT(A);
           MOVEIT(A);
         END;
      2: BEGIN
           IF RMOO THEN
           BEGIN
             IF RMQS THEN
               INTF := F1
             ELSE
               INTF := F8;
             INTR := XTSR[RMFR];
             RKFR := XTRFS[INTR,INTF];
             RKTO := (RMFR+RMTO) DIV 2;
             ANDRS(CSTAT[JNTK],CSTAT[JNTK],XNRS[INTR]);
             ADDLOC(RKTO,NBORD[RKFR]);
             ADDATK(RKTO);
             DELATK(RKFR);
             MOVEIT(A);
           END
           ELSE
           BEGIN
             PROACS(A);Š             MOVEIT(A);
           END;
         END;
      3: ;
      4: IF RMEP THEN
         BEGIN
           INTS := XTRFS[XTSR[RMFR],XTSF[RMTO]];
           MBCAPT(NBORD[INTS]);
           DELATK(INTS);
           PRPATK(INTS);
           MOVEIT(A);
         END
         ELSE
           LOSEIT(A);
      5: BEGIN
           PROMOT(A);
           LOSEIT(A);
         END;
      6: BEGIN
           PROACS(A);
           LOSEIT(A);
         END;
      7: BEGIN
           PROMOT(A);
           PROACS(A);
           LOSEIT(A);
         END
    END;
    JNTM := OTHER[JNTM];
    CPYRS(GENPN[JNTK],TPLOC[XTUMP[EP,JNTM]]);
    NOTRS(GENTO[JNTK],TMLOC[JNTM]);
    NOTRS(INRS,GENPN[JNTK]);
    ANDRS(GENFR[JNTK],TMLOC[JNTM],INRS);
    ANDRS(INRS,TPLOC[XTUMP[EK,JNTM]],ALATK[OTHER[JNTM]]);
    IF NOT NULRS(INRS) THEN
      RMCH := TRUE
    ELSE
      RMCH := FALSE;
    ANDRS(INRS,TPLOC[XTUMP[EK,OTHER[JNTM]]],ALATK[JNTM]);
    IF NOT NULRS(INRS) THEN
      RMIL := TRUE
    ELSE
      RMIL := FALSE;
    UPDATE := NOT RMIL;
    IF NOT RMIL THEN
      MVSEL[JNTK-1] := MVSEL[JNTK-1] + 1;
    SRCHM[JNTK] := H1;
    NODES := NODES + 1;
  END;
END;

PROCEDURE GENONE(A:TT; B:TS); (* STACK 1 GENERATED MOVE *)
VAR INRS : RS;
BEGINŠ  WITH MOVES[JNTW] DO
  BEGIN
    RMFR := A;
    RMTO := B;
    RMCP := NBORD[B];
    IF NBORD[B] <> MT THEN
      RMCA := TRUE
    ELSE
      RMCA := FALSE;
    IORRS(INRS,XRSS[A],XRSS[B]);
    ANDRS(INRS,INRS,CSTAT[JNTK]);
    IF NOT NULRS(INRS) THEN
      RMAC := TRUE
    ELSE
      RMAC := FALSE;
    RMCH := FALSE;
    RMMT := FALSE;
    RMIL := FALSE;
    RMSU := FALSE;
    RMPR := FALSE;
    RMOO := FALSE;
    RMEP := FALSE;
  END;
  VALUE[JNTW] := 0;
  IF JNTW < ZW THEN
    JNTW := JNTW + 1;
END;

PROCEDURE PWNPRO; (* GENERATE ALL PROMOTION MOVES *)
VAR INTG : TG;
BEGIN
  MOVES[JNTW-1].RMPR := TRUE;
  MOVES[JNTW-1].RMPP := PQ;
  FOR INTG := PR TO PB DO
  BEGIN
    MOVES[JNTW] := MOVES[JNTW-1];
    MOVES[JNTW].RMPP := INTG;
    JNTW := JNTW + 1;
  END;
END;

PROCEDURE GENPWN(A:RS; B:RS); (* GENERATE PAWN MOVES *)
VAR
  INRS, IMRS: RS;
  INTS : TS;
  
  PROCEDURE GENPWN1(FLG:TI);
  BEGIN
    MOVES[JNTW-1].RMCA := TRUE;
    IF INRSTB(ENPAS[JNTK],INTS) THEN
      MOVES[JNTW-1].RMEP := TRUE
    ELSE
      MOVES[JNTW-1].RMEP := FALSE;
    IF MOVES[JNTW-1].RMEP THENŠ    BEGIN
      IF FLG = 81 THEN
        MOVES[JNTW-1].RMCP := DP
      ELSE
        MOVES[JNTW-1].RMCP := LP;
    END;
    IF FLG = 81 THEN
    BEGIN
      IF INTS >= XTRFS[R8,F1] THEN
        PWNPRO;
    END
    ELSE
    BEGIN
      IF INTS <= XTRFS[R1,F8] THEN
        PWNPRO;
    END;
  END;

BEGIN
  IF JNTM = LITE THEN
  BEGIN
    SFTRS(INRS,A,S2);
    ANDRS(INRS,TPLOC[MT],INRS);
    CPYRS(IMRS,INRS);
    ANDRS(INRS,B,INRS);
    WHILE NXTTS(INRS,INTS) DO
    BEGIN
      GENONE(XTLS[XTSL[INTS]-XTED[S2]],INTS);
      IF INTS >= XTRFS[R8,F1] THEN
        PWNPRO;
    END;
    ANDRS(INRS,IMRS,XRRS[R3]);
    SFTRS(INRS,INRS,S2);
    ANDRS(INRS,INRS,TPLOC[MT]);
    ANDRS(INRS,INRS,B);
    WHILE NXTTS(INRS,INTS) DO
    BEGIN
      GENONE(XTLS[XTSL[INTS]-2*XTED[S2]],INTS);
      MOVES[JNTW-1].RMEP := TRUE;
    END;
    SFTRS(INRS,A,B1);
    IORRS(IMRS,TMLOC[OTHER[JNTM]],ENPAS[JNTK]);
    ANDRS(IMRS,IMRS,B);
    ANDRS(INRS,INRS,IMRS);
    WHILE NXTTS(INRS,INTS) DO
    BEGIN
      GENONE(XTLS[XTSL[INTS]-XTED[B1]],INTS);
      GENPWN1(81);
    END;
    SFTRS(INRS,A,B2);
    IORRS(IMRS,TMLOC[OTHER[JNTM]],ENPAS[JNTK]);
    ANDRS(IMRS,IMRS,B);
    ANDRS(INRS,INRS,IMRS);
    WHILE NXTTS(INRS,INTS) DOŠ    BEGIN
      GENONE(XTLS[XTSL[INTS]-XTED[B2]],INTS);
      GENPWN1(81);
    END;
  END
  ELSE
  BEGIN
    SFTRS(INRS,A,S4);
    ANDRS(INRS,TPLOC[MT],INRS);
    CPYRS(IMRS,INRS);
    ANDRS(INRS,B,INRS);
    WHILE NXTTS(INRS,INTS) DO
    BEGIN
      GENONE(XTLS[XTSL[INTS]-XTED[S4]],INTS);
      IF INTS <= XTRFS[R1,F8] THEN
        PWNPRO;
    END;
    ANDRS(INRS,IMRS,XRRS[R6]);
    SFTRS(INRS,INRS,S4);
    ANDRS(INRS,INRS,TPLOC[MT]);
    ANDRS(INRS,INRS,B);
    WHILE NXTTS(INRS,INTS) DO
    BEGIN
      GENONE(XTLS[XTSL[INTS]-2*XTED[S4]],INTS);
      MOVES[JNTW-1].RMEP := TRUE;
    END;
    SFTRS(INRS,A,B3);
    IORRS(IMRS,TMLOC[OTHER[JNTM]],ENPAS[JNTK]);
    ANDRS(IMRS,IMRS,B);
    ANDRS(INRS,INRS,IMRS);
    WHILE NXTTS(INRS,INTS) DO
    BEGIN
      GENONE(XTLS[XTSL[INTS]-XTED[B3]],INTS);
      GENPWN1(18);
    END;
    SFTRS(INRS,A,B4);
    IORRS(IMRS,TMLOC[OTHER[JNTM]],ENPAS[JNTK]);
    ANDRS(IMRS,IMRS,B);
    ANDRS(INRS,INRS,IMRS);
    WHILE NXTTS(INRS,INTS) DO
    BEGIN
      GENONE(XTLS[XTSL[INTS]-XTED[B4]],INTS);
      GENPWN1(18);
    END;
  END;
END;

PROCEDURE GENFSL(A:RS); (* GENERATE ALL MOVES FROM A SET OF SQUARES *)
VAR
  INRS : RS;
  IMRS : RS;
  IPRS : RS;
  INTS : TS;
  IMTS : TS;ŠBEGIN
  ANDRS(INRS,A,GENFR[JNTK]);
  NOTRS(IMRS,A);
  ANDRS(GENFR[JNTK],GENFR[JNTK],IMRS);
  ANDRS(IPRS,A,GENPN[JNTK]);
  ANDRS(GENPN[JNTK],GENPN[JNTK],IMRS);
  WHILE NXTTS(INRS,INTS) DO
  BEGIN
    ANDRS(IMRS,ATKFR[INTS],GENTO[JNTK]);
    WHILE NXTTS(IMRS,IMTS) DO
      GENONE(INTS,IMTS);
  END;
  GENPWN(IPRS,GENTO[JNTK]);
END;

PROCEDURE GENTSL(A:RS); (* GEN ALL MOVES TO A SET OF SQUARES *)
VAR
  INRS : RS;
  IMRS : RS;
  IPRS : RS;
  INTS : TS;
  IMTS : TS;
BEGIN
  ANDRS(INRS,A,GENTO[JNTK]);
  NOTRS(IMRS,A);
  ANDRS(GENTO[JNTK],GENTO[JNTK],IMRS);
  CPYRS(IPRS,INRS);
  WHILE NXTTS(INRS,INTS) DO
  BEGIN
    ANDRS(IMRS,ATKTO[INTS],GENFR[JNTK]);
    WHILE NXTTS(IMRS,IMTS) DO
      GENONE(IMTS,INTS);
  END;
  GENPWN(GENPN[JNTK],IPRS);
END;

PROCEDURE GENCAP; (* GENERATE CAPTURE MOVES *)
VAR INRS : RS;
BEGIN
  IORRS(INRS,ENPAS[JNTK],TMLOC[OTHER[JNTM]]);
  GENTSL(INRS);
END;

PROCEDURE GENCAS; (* GENERATE CASTLE MOVES *)
VAR
  INTQ : TQ;
  INRS : RS;
  IMRS : RS;
BEGIN
  FOR INTQ := XTMQ[JNTM] TO SUCC(XTMQ[JNTM]) DO
    IF INRSTB(CSTAT[JNTK],XTQS[INTQ]) THEN
    BEGIN
      ANDRS(INRS,XRQSO[INTQ],ALLOC[JNTK]);
      ANDRS(IMRS,XRQSA[INTQ],ALATK[OTHER[JNTM]]);Š      IF NULRS(INRS) AND NULRS(IMRS) THEN
      BEGIN
        MOVES[JNTW] := XRQM[INTQ];
        VALUE[JNTW] := 0;
        JNTW := JNTW + 1;
      END;
    END;
END;

PROCEDURE GENALL; (* GENERATE ALL LEGAL MOVES *)
BEGIN
  GENFSL(ALLOC[JNTK]);
  GENCAS;
END;

PROCEDURE LSTMOV; (* LIST LEGAL PLAYER'S MOVES *)
VAR INTW : TW;
BEGIN
  CREATE;
  GENALL;
  FOR INTW := AW+1 TO JNTW-1 DO
  BEGIN
    IF UPDATE(MOVES[INTW]) THEN;
    DNDATE(MOVES[INTW]);
  END;
END;

PROCEDURE THEMOV(A:RM); (* MAKE THE MOVE FOR REAL *)
VAR
  INTB : TB;
  INRS : RS;
  INTQ : TQ;
  INTS : TS;
BEGIN
  LSTMV := A;
  IF UPDATE(A) THEN
    INTB := TRUE
  ELSE
    INTB := FALSE;
  WITH BOARD DO
  BEGIN
    RBTM := JNTM;
    CPYRS(INRS,ENPAS[JNTK]);
    IF NXTTS(INRS,INTS) THEN
      RBTS := INTS
    ELSE
      RBTS := AT;
    IF JNTM = DARK THEN
      RBTI := RBTI + 1;
    FOR INTQ := LS TO DL DO
      IF INRSTB(CSTAT[JNTK],XTQS[INTQ]) THEN
        RBSQ := RBSQ + [INTQ]
      ELSE
        RBSQ := RBSQ - [INTQ];Š    FOR INTS := AS TO ZS DO
      RBIS[INTS] := NBORD[INTS];
  END;
END;



PROCEDURE EVALU8; (* EVALUTE CURRENT POSITION *)
VAR INTV : TV;
 
  FUNCTION EVKING(A:RS; B:RS):TV; (* EVALUATE KING *)
  VAR
    INTS : TS;
    INRS : RS;
    INTV : TV;
  BEGIN
    ANDRS(INRS,A,CORNR);
    IF NULRS(INRS) THEN
      INTV := 0
    ELSE
      INTV := FKSANQ;
    INRS := A;
    IF NXTTS(INRS,INTS) THEN
    BEGIN
      ANDRS(INRS,ATKFR[INTS],B);
      INTV := INTV + CNTRS(INRS) * FKPSHD;
    END;
    EVKING := INTV;
  END; (* EVKING *)
   
  FUNCTION EVMOBL(A,B:TP):TV; (* EVALUATE MOBILITY *)
  VAR
    INRS : RS;
    INTS : TS;
    INTV : TV;
  BEGIN
    IORRS(INRS,TPLOC[A],TPLOC[B]);
    INTV := 0;
    WHILE NXTTS(INRS,INTS) DO
      INTV := INTV + CNTRS(ATKFR[INTS]);
    EVMOBL := INTV;
  END; (* EVMOBL *)
  
  FUNCTION EVPAWN(A:RS; B:TE; C:TR):TV; (* EVALUATE PAWNS *)
  VAR
    INRS : RS;
    IMRS : RS;
    INTS : TS;
    INTV : TV;
  BEGIN
    SFTRS(INRS,A,S1);
    ANDRS(INRS,INRS,A);
    INTV := CNTRS(INRS) * FPFLNX;
    SFTRS(INRS,A,B1);Š    ANDRS(INRS,INRS,A);
    INTV := INTV + CNTRS(INRS) * FPCONN;
    SFTRS(INRS,A,B2);
    ANDRS(INRS,INRS,A);
    INTV := INTV + CNTRS(INRS) * FPCONN;
    SFTRS(INRS,A,B);
    NOTRS(IMRS,TPLOC[MT]);
    ANDRS(INRS,INRS,IMRS);
    INTV := INTV - CNTRS(INRS) * FPBLOK;
    CPYRS(INRS,A);
    WHILE NXTTS(INRS,INTS) DO
      INTV := INTV + (ABS(ORD(C)-ORD(XTSR[INTS])))*FPADCR[XTSF[INTS]];
    EVPAWN := INTV;
  END; (* EVPAWN *)
  
  FUNCTION EVROOK(A:RS; B:RS):TV; (* EVALUATE ROOKS *)
  VAR
    INTV : TV;
    INTI : TI;
    INTS : TS;
    INRS : RS;
  BEGIN
    INTV := 0;
    INRS := A;
    IF NXTTS(INRS,INTS) THEN
    BEGIN
      ANDRS(INRS,A,ATKFR[INTS]);
      IF NOT NULRS(INRS) THEN
        INTV := INTV + FRDUBL;
    END;
    ANDRS(INRS,A,B);
    INTI := CNTRS(INRS);
    EVROOK := INTV + INTI * INTI * FRK7TH;
  END;(* EVROOK *)

BEGIN (* EVALU8 *)
  IF XTMV[JNTM]*MBVAL[JNTK]+MAXPS <= BSTVL[JNTK-2] THEN
    INTV := XTMV[JNTM] * MBVAL[JNTK]
  ELSE
  BEGIN
    INTV := ( FWPAWN*(EVPAWN(TPLOC[LP],S2,R2)-EVPAWN(TPLOC[DP],S4,R7))
             +FWMINM*(EVMOBL(LB,LN)          -EVMOBL(DB,DN)          )
             +FWMAJM*(EVMOBL(LR,LQ)          -EVMOBL(DR,DQ)          )
             +FWROOK*(EVROOK(TPLOC[LR],XRRS[R7])
                     -EVROOK(TPLOC[DR],XRRS[R2])                     )
             +FWKING*(EVKING(TPLOC[LK],TPLOC[LP])
                     -EVKING(TPLOC[DK],TPLOC[DP])                    )
            ) DIV 64;
    MAXPS := MAX(MAXPS,ABS(INTV));
    INTV := XTMV[JNTM] * (MBVAL[JNTK]+INTV);
  END;
  IF SWTR THEN
  BEGIN
    WRITE(' EVALU8 ',JNTK:2,JNTW:4,INDEX[JNTK]:3,INTV:4);Š    PRIMOV(MOVES[INDEX[JNTK]]);
    IF SWEC THEN
    BEGIN
      WRITE(PRNTR,' EVALU8 ',JNTK:2,JNTW:4,INDEX[JNTK]:3,INTV:4);
      PTRMOV(MOVES[INDEX[JNTK]]);
    END;
  END;
  VALUE[INDEX[JNTK]] := INTV;
END; (* EVALU8 *)

FUNCTION SEARCH:TW; (* SEARCH LOOK-AHEAD TREE *)
LABEL 11,12,13,14,15,16;
  
  PROCEDURE NEWBST(A:TK); (* SAVE BEST MOVE INFORMATION *)
  VAR
    INTW : TW;
    INRM : RM;
  BEGIN
    BSTMV[A] := INDEX[A+1];
    IF A = AK THEN
    BEGIN
      INRM := MOVES[BSTMV[A]];
      FOR INTW := BSTMV[A]-1 DOWNTO AW+1 DO
        MOVES[INTW+1] := MOVES[INTW];
      MOVES[AW+1] := INRM;
      BSTMV[AK] := AW + 1;
    END
    ELSE
      IF NOT MOVES[BSTMV[A]].RMCA THEN
        KILLR[JNTK] := MOVES[BSTMV[A]];
  END; (* NEWBST *)
  
  FUNCTION MINMAX(A:TK):TB; (* PERFORM MINIMAX OPERATION *)
  BEGIN
  MINMAX := FALSE;
    IF SWTR THEN
    BEGIN
      WRITE(' MINMAX ',A:6,-BSTVL[A-1]:6,BSTVL[A]:6,-BSTVL[A+1]:6);
      IF SWEC THEN
        WRITE(PRNTR,' MINMAX ',A:6,-BSTVL[A-1]:6,BSTVL[A]:6,-BSTVL[A+1]:6);
    END;
    IF -BSTVL[A+1] > BSTVL[A] THEN
    BEGIN
      BSTVL[A] := -BSTVL[A+1];
      NEWBST(A);
      IF BSTVL[A+1] <= BSTVL[A-1] THEN
        MINMAX := TRUE
      ELSE
        MINMAX := FALSE;
      IF SWTR THEN
      BEGIN
        WRITE('  NEW BEST. PRUNE: ');
        IF BSTVL[A+1] <= BSTVL[A-1] THEN
          WRITE('YES.')Š        ELSE
          WRITE('NO.');
        IF SWEC THEN
        BEGIN
          WRITE(PRNTR,'  NEW BEST PRUNE: ');
          IF BSTVL[A+1] <= BSTVL[A-1] THEN
            WRITE(PRNTR,'YES.')
          ELSE
            WRITE(PRNTR,'NO.');
        END;
      END;
    END;
    IF SWTR THEN
    BEGIN
      WRITELN;
      IF SWEC THEN
        WRITELN(PRNTR,' ');
    END;
  END; (* MINMAX *)
  
  PROCEDURE SCOREM; (* SCORE MATE *)
  BEGIN
    MOVES[INDEX[JNTK]].RMMT := TRUE;
    IF MOVES[INDEX[JNTK]].RMCH THEN
      VALUE[INDEX[JNTK]] := 64 * JNTK - ZV
    ELSE
      VALUE[INDEX[JNTK]] := 0;
    IF SWTR THEN
    BEGIN
      WRITELN(' SCOREM ',JNTK:3,JNTW:4,INDEX[JNTK]:6,VALUE[INDEX[JNTK]]:6);
      IF SWEC THEN
        WRITELN(PRNTR,' SCOREM ',JNTK:3,JNTW:4,INDEX[JNTK]:6,
                      VALUE[INDEX[JNTK]]:6);
    END;
  END; (* SCOREM *)
  
  FUNCTION SELECT:TB; 	(* SELECT NEXT MOVE TO SEARCH *)
  LABEL 21, 22;
  VAR
    INTB : TB;
    INTK : TK;
    INTW : TW;
    IMTW : TW;
    INTV : TV;
    SLMV : TB;
    
    PROCEDURE SELDON; (* SELECT EXIT - DONE *)
    BEGIN
      INTB := FALSE;
      IF SWTR THEN
      BEGIN
        WRITELN(' SELECT ',JNTK,' END.');
        IF SWEC THEN
          WRITELN(PRNTR,' SELECT ',JNTK,' END.');Š      END;
    END; (* SELDON *)
    
    PROCEDURE SELMOV(A:TW); (* SELECT EXIT - SEARCH *)
    BEGIN
      INTB := TRUE;
      INDEX[JNTK+1] := A;
      MOVES[A].RMSU := TRUE;
      IF SWTR THEN
      BEGIN
        WRITE(' SELECT ',JNTK:2,ORD(SRCHM[JNTK]):6,A:6);
        PRIMOV(MOVES[A]);
        IF SWEC THEN
        BEGIN
          WRITE(PRNTR,' SELECT ',JNTK:2,ORD(SRCHM[JNTK]):6,A:6);
          PTRMOV(MOVES[A]);
        END;
      END;
    END; (* SELMOV *)
    
    PROCEDURE SELNXT(A:TH); (* SELECT EXIT - NEW MODE *)
    BEGIN
      INDEX[JNTK+1] := LINDX[JNTK] - 1;
      SRCHM[JNTK] := A;
    END; (* SELNXT *)
    
    PROCEDURE SELANY; (* SEARCH ALREADY GENERATED AND NOT SEARCHED *)
    VAR INTW : TW;
    BEGIN
      SLMV := FALSE;
      FOR INTW := INDEX[JNTK+1]+1 TO JNTW-1 DO
      BEGIN
        IF NOT MOVES[INTW].RMSU THEN
        BEGIN
          SELMOV(INTW);
          SLMV := TRUE;
          EXIT(SELANY);
        END;
      END;
    END; (* SELANY *)
  
    PROCEDURE SELSBA;
    BEGIN
        FOR IMTW :½ LINDX[JNTKÝ TÏ JNTW-± DÏ     
	 WITH MOVES[IMTW] DO
          IF NOT RMSU THEN
            IF ABS(XTPV[RMCP]) > INTV THEN
            BEGIN
              INTV := ABS(XTPV[RMCP]);
              INTW := IMTW;
            END;
    	END; (* SELSBA *)Š    
    PROCEDURE PRELIM;
    VAR
      INTW : TW;
    BEGIN
      FOR INTW := AW+1 TO JNTW-1 DO
      BEGIN
        WRITE(' PRELIM ',INTW:3,VALUE[INTW]:6);
        PRIMOV(MOVES[INTW]);
        IF SWEC THEN
        BEGIN
          WRITE(PRNTR,' PRELIM ',INTW:3,VALUE[INTW]:6);
          PTRMOV(MOVES[INTW]);
        END;
      END;
    END;
    
  BEGIN (* SELECT *)
  21: (* NEW SEARCH MODE *)
    CASE SRCHM[JNTK] OF
      H0: (* INITIALIZE FOR NEW MOVE *)
          BEGIN
            MVSEL[JNTK] := 0;
            INTV := BSTVL[JNTK-2];
            BSTVL[JNTK-2] := -ZV;
            MAXPS := 0;
            GENALL;
            FOR INTW := AW+1 TO JNTW-1 DO
            BEGIN
              IF UPDATE(MOVES[INTW]) THEN
              BEGIN
                INDEX[JNTK] := INTW;
                EVALU8;
              END;
              DNDATE(MOVES[INTW]);
            END;
            BSTVL[JNTK-2] := INTV;
            SORTIT(VALUE,MOVES,JNTW-1);  
            FOR INTK := AK TO ZK DO
              KILLR[INTK] := NULMV;
            IF SWTR OR SWPS THEN
              PRELIM;
            SELNXT(H6);
            GOTO 21;
          END;
      
      H1: (* INITIALIZE AT NEW DEPTH *)
          BEGIN
            MVSEL[JNTK] := 0;
            IF JNTK > JMTK THEN
            BEGIN
              EVALU8;
              INDEX[JNTK+1] := AW;
              BSTVL[JNTK+1] := -VALUE[INDEX[JNTK]];Š              IF MINMAX(JNTK) OR (JNTK = ZK) THEN
              BEGIN
                SELDON;
                GOTO 22;
              END;
              SRCHM[JNTK] := H2;
            END
            ELSE
              SRCHM[JNTK] := H3;
            GENCAP;
            SELNXT(SRCHM[JNTK]);
            GOTO 21;
          END;
      H2: (* CAPTURE SEARCH *)
          BEGIN
            INTW := AW;
            INTV := AV;
            SELSBA;
            IF INTW <> AW THEN
              SELMOV(INTW)
            ELSE
              SELDON;
          END;

      H3: (* FULL WIDTH SEARCH - CAPTURES *)
          BEGIN
            INTW := AW;
            INTV := AV;
            SELSBA;
            IF INTW <> AW THEN
            BEGIN
              SELMOV(INTW);
              GOTO 22;
            END
            ELSE
              IF NOT NULMVB(KILLR[JNTK]) THEN
              BEGIN
                IMTW := JNTW;
                GENFSL(XRSS[KILLR[JNTK].RMFR]);
                SRCHM[JNTK] := H4;
                FOR INTW := IMTW TO JNTW-1 DO
                  IF KILLR[JNTK].RMTO = MOVES[INTW].RMTO THEN
                  BEGIN
                    SELMOV(INTW);
                    GOTO 22;
                  END;
              END;
            SELNXT(H4);
            GOTO 21;
          END;
          
      H4: (* INIT. SCAN OF CASTLE MOVES & OTHER MOVES BY KILLER PIECE *)
          BEGIN
            GENCAS;Š            SELNXT(H5);
            GOTO 21;
          END;
      
      H5: (* FULL WIDTH SEARCH - CASTLES & OTHER MOVES BY KILLER PIECE *)
          BEGIN
            SELANY;
            IF NOT SLMV THEN
            BEGIN
              GENFSL(ALLOC[JNTK]);
              SELNXT(H6);
              GOTO 21;
            END;
          END;
          
      H6: (* FULL WIDTH SEARCH - REMAINING MOVES *)
          BEGIN
            SELANY;
            IF NOT SLMV THEN
            BEGIN
              IF MVSEL[JNTK] = 0 THEN
                SCOREM;
              SELDON;
            END;
          END;
          
      H7: (* RESEARCH 1ST PLY *)
          BEGIN
            JNTW := LINDX[AK+1];
            MVSEL[AK] := 0;
            FOR INTW := AW+1 TO JNTW-1 DO
              MOVES[INTW].RMSU := FALSE;
            IF SWTR THEN
            BEGIN
              WRITELN(' REDO  ',JMTK:2,BSTVL[AK-2]:6,BSTVL[AK-1]:6);
              IF SWEC THEN
                WRITELN(PRNTR,' REDO  ',JMTK:2,BSTVL[AK-2]:6,BSTVL[AK-1]:6);
            END;
            SELNXT(H6);
            GOTO 21;
          END
    END;
  22: (* SELECT EXIT *)
      SELECT := INTB;
  END; (* SELECT *)
    
BEGIN (* SEARCH *)
  BSTMV[AK] := AW;
  INDEX[JNTK] := AW;
  MOVES[AW] := LSTMV;
  EVALU8;
  BSTVL[AK-2] :=  VALUE[AW] - WINDOW;
  BSTVL[AK-1] := -VALUE[AW] - WINDOW;
  JMTK := AK + 1;Š  WHILE (NODES < FNODEL) AND (JMTK < MAX(ZK DIV 2, ZK-8)) DO
  BEGIN
11: (* START NEW PLY *)
    BSTVL[JNTK] := BSTVL[JNTK-2];
12: (* DIFFERENT FIRST MOVE *)
    IF NOT SELECT THEN
    BEGIN
      BSTVL[JNTK] := VALUE[INDEX[JNTK]];
      NEWBST(JNTK);
    END
    ELSE
    BEGIN
      IF UPDATE(MOVES[INDEX[JNTK+1]]) THEN
        GOTO 11
      ELSE
      BEGIN
        DNDATE(MOVES[INDEX[JNTK]]);
        GOTO 12;
      END;
13: (* FLOAT VALUE BACK *)
      IF MINMAX(JNTK) THEN
        GOTO 15;
14: (* FIND ANOTHER MOVE AT THIS PLY *)
      IF SELECT THEN
        IF UPDATE(MOVES[INDEX[JNTK+1]]) THEN
          GOTO 11
        ELSE
        BEGIN
          DNDATE(MOVES[INDEX[JNTK]]);
          GOTO 14;
        END;
    END;
15: (* BACK UP A PLY *)
    IF JNTK > AK THEN
    BEGIN
      DNDATE(MOVES[INDEX[JNTK]]);
      GOTO 13;
    END;
    IF (BSTVL[AK] <=  BSTVL[AK-2]) OR 
       (BSTVL[AK] >= -BSTVL[AK-1]) THEN
    BEGIN
      IF MVSEL[AK] = 0 THEN
      BEGIN
        GOTO 16;
      END;
      BSTVL[AK-2] := -ZV;
      BSTVL[AK-1] := -ZV;
      SRCHM[AK] := H7;
      JNTW := AK + 1;
      GOTO 11;
    END;
    BSTVL[AK-2] :=  BSTVL[AK] - WINDOW;
    BSTVL[AK-1] := -BSTVL[AK] - WINDOW;
    JMTK := JMTK + 1;Š    SRCHM[AK] := H7;
  END;
   
                                                                                                                                                                                                                                                   16: (* EXIT SEARCH *)
  SEARCH := BSTMV[AK];
END; (* SEARCH *)



PROCEDURE MINENG(A:RM; B:RA); (* GEN. MINIMUM ENGLISH NOTATION *)
VAR INTN : TN;
  
  PROCEDURE ADDCHR(A:TC); (* ADD CHARACTER TO MESSAGE *)
  BEGIN
    MOVMS[INTN] := A;
    IF INTN < ZN THEN
      INTN := INTN + 1;
  END; (* ADDCHR *)
  
  PROCEDURE ADDSQR(A:TS; B:RD);
  BEGIN
    WITH B DO
    BEGIN
      IF RDPC THEN
        ADDCHR(XTUC[XTPU[NBORD[A]]]);
      IF RDSL THEN
        ADDCHR('/');
      IF RDKQ THEN
        IF XTSF[A] IN [F1..F4] THEN
          ADDCHR('Q')
        ELSE
          ADDCHR('K');
      IF RDNB THEN
        CASE XTSF[A] OF
          F1,F8: ADDCHR('R');
          F2,F7: ADDCHR('N');
          F3,F6: ADDCHR('B');
          F4   : ADDCHR('Q');
          F5   : ADDCHR('K')
        END;
      IF RDRK THEN
        IF JNTM = LITE THEN
          CASE XTSR[A] OF
            R1: ADDCHR('1');
            R2: ADDCHR('2');
            R3: ADDCHR('3');
            R4: ADDCHR('4');
            R5: ADDCHR('5');
            R6: ADDCHR('6');
            R7: ADDCHR('7');
            R8: ADDCHR('8')
          END
        ELSE
          CASE XTSR[A] OFŠ            R1: ADDCHR('8');
            R2: ADDCHR('7');
            R3: ADDCHR('6');
            R4: ADDCHR('5');
            R5: ADDCHR('4');
            R6: ADDCHR('3');
            R7: ADDCHR('2');
            R8: ADDCHR('1')
          END;
    END;
  END; (* ADDSQR *)
  
  PROCEDURE ADDWRD(A:RA; B:TA); (* ADD WORD TO MESSAGE *)
  VAR INTA : TA;
  BEGIN
    FOR INTA := AA TO B DO
      ADDCHR(A[INTA]);
  END; (* ADDWRD *)
  
  FUNCTION DIFFER(A,B:RM):TB; (* COMPARE MOVES *)
  VAR INTB, INAB, INBB, INCB, INDB : TB;
  BEGIN
    IF A.RMFR <> B.RMFR THEN
      INAB := TRUE
    ELSE
      INAB := FALSE;
    IF A.RMTO <> B.RMTO THEN
      INBB := TRUE
    ELSE
      INBB := FALSE;
    IF A.RMCP <> B.RMCP THEN
      INCB := TRUE
    ELSE
      INCB := FALSE;
    IF INAB OR INBB OR INCB THEN
      INTB := TRUE
    ELSE
      INTB := FALSE;
    IF A.RMPR = B.RMPR THEN
      IF A.RMPR THEN
      BEGIN
        IF A.RMPP <> B.RMPP THEN
          INAB := TRUE
        ELSE
          INAB := FALSE;
        IF INTB OR INAB THEN
          DIFFER := TRUE
        ELSE
          DIFFER := FALSE;
      END
      ELSE
        IF A.RMOO = B.RMOO THEN
          IF A.RMOO THEN
            DIFFER := INTB OR (A.RMQS <> B.RMQS)Š          ELSE
            DIFFER := INTB
        ELSE
          DIFFER := TRUE
    ELSE
      DIFFER := TRUE;
  END; (* DIFFER *)
  
  PROCEDURE SETSQD(A:TS; B:RD; VAR C:SR; VAR D:SF);
  (* DEFINE SPECIFIC SQUARE DESCRIPTOR *)
  BEGIN
    C := [R1..R8];
    D := [F1..F8];
    WITH B DO
    BEGIN
      IF RDKQ AND RDNB THEN
        D := [XTSF[A]];
      IF (NOT RDKQ) AND RDNB THEN
        CASE XTSF[A] OF
          F1,F8: D := [F1,F8];
          F2,F7: D := [F2,F7];
          F3,F6: D := [F3,F6];
          F4   : D := [F4];
          F5   : D := [F5]
        END;
      IF RDRK THEN
        C := [XTSR[A]];
    END;
  END; (* SETSQD *)
  
  PROCEDURE MINGEN(A:RM; B:TI; C:TI);
  (* PRODUCE MINIMUM ENGLISH NOTATION FOR MOVES AND CAPTURES *)
  LABEL 21, 22;
  VAR
    INTG : TG;
    INTI : TI;
    INTW : TW;
    INLR : SR;
    INRR : SR;
    INLF : SF;
    INRF : SF;
  BEGIN
    FOR INTI := B TO C DO
      WITH SYNTX[INTI] DO
      BEGIN
        IF A.RMPR THEN
          INTG := A.RMPP
        ELSE
          INTG := PB;
        SETSQD(A.RMFR,RYLS,INLR,INLF);
        SETSQD(A.RMTO,RYRS,INRR,INRF);
        FOR INTW := AW+1 TO JNTW-1 DO
          IF DIFFER(MOVES[INTW],A) THEN
            IF (NBORD[A.RMFR] = NBORD[MOVES[INTW].RMFR]) ANDŠ               (A.RMCP = MOVES[INTW].RMCP) THEN
              WITH MOVES[INTW] DO
                IF (XTSR[RMFR] IN INLR) AND
                   (XTSR[RMTO] IN INRR) AND
                   (XTSF[RMFR] IN INLF) AND
                   (XTSF[RMTO] IN INRF) AND
                  ((RMPR AND (INTG = RMPP)) OR (NOT RMPR)) THEN
                  GOTO 21;
        ADDSQR(A.RMFR,RYLS);
        ADDCHR(RYCH);
        ADDSQR(A.RMTO,RYRS);
        GOTO 22;
  21: (* TRY NEXT SYNTAX *)
      END;
  22: (* EXIT MINGEN *)
  END; (* MINGEN *)
  
BEGIN (* MINENG *)
  MOVMS := '                              ';
  INTN := AN + 1;
  ADDWRD(B,ZA);
  ADDWRD('-         ',2);
  WITH A DO
  BEGIN
    IF RMOO THEN
    BEGIN
      ADDWRD('0-0       ',3);
      IF RMQS THEN
        ADDWRD('-0        ',2);
    END
    ELSE
      IF RMCA THEN
        MINGEN(A,SYNCF,SYNCL)
      ELSE
        MINGEN(A,SYNMF,SYNML);
    IF RMPR THEN
    BEGIN
      ADDCHR('=');
      ADDCHR(XTGC[RMPP]);
    END;
    ADDWRD('.         ',3);
    IF RMCH THEN
    BEGIN
      ADDWRD('CHECK     ',5);
      IF RMMT THEN
        ADDWRD('MATE      ',4);
      ADDCHR('.');
    END
    ELSE
      IF RMMT THEN
        ADDWRD('STALEMATE.',10);
  END;
END; (* MINENG *)
ŠPROCEDURE MYMOVE; (* MAKE MACHINE'S MOVE *)
VAR INRM : RM;
BEGIN
  CREATE;
  INRM := MOVES[SEARCH];
  IF INRM.RMIL THEN
  BEGIN
    GOING := 0;
    IF LSTMV.RMCH THEN
      WRITELN(' CONGRATULATIONS.')
    ELSE
      WRITELN(' DRAWN. ');
  END
  ELSE
  BEGIN
    MINENG(INRM,'  MY MOVE ');
    WRITELN(MOVMS);
    IF SWEC AND (SWTR OR SWPS OR SWSU) THEN
      WRITELN(PRNTR,MOVMS);
    IF (SWTR OR SWPS OR SWSU) THEN
    BEGIN
      PRIMOV(INRM);
      IF SWEC THEN
        PTRMOV(INRM);
    END;
    THEMOV(INRM);
    IF SWSU THEN
    BEGIN
      WRITELN('MOVE #',BOARD.RBTI:2,':  ',NODES:3,
              ' NODES,  VALUE OF BEST MOVE = ',BSTVL[AK]:4);
      IF SWEC THEN
        WRITELN(PRNTR,'MOVE #',BOARD.RBTI:2,':  ',NODES:3,
                      ' NODES,  VALUE OF BEST MOVE = ',BSTVL[AK]:6);
    END;
  END;
END; (* MYMOVE *)

PROCEDURE YRMOVE; (* MAKE PLAYER'S MOVE *)
LABEL 6, 7, 8;
VAR
  INTB : TB;
  INTC : TC;
  INTW : TW;
  INTP : TP;
  INCP : TP;
  IFCA : TB;
  IFPR : TB;
  IFOO : TB;
  IFQS : TB;
  INTG : TG;
  IFMV : TB;
  IFLD : TB;
  IFLF : TB;
  IFRD : TB;Š  IFRF : TB;
  INLF : SF;
  INLR : SR;
  INRF : SF;
  INRR : SR;
  INRM : RM;
  AMBG : TB;
  SYNE : TB;
  
  PROCEDURE YRMHIT; (* FOUND A MOVE *)
  BEGIN
    AMBG := FALSE;
    IF IFMV THEN
      AMBG := TRUE
    ELSE
    BEGIN
      IFMV := TRUE;
      INRM := MOVES[INTW];
    END;
  END; (* YRMHIT *)
  
  PROCEDURE YRMCOM; (* COMPARE SQUARES *)
  BEGIN
    AMBG := FALSE;
    WITH MOVES[INTW] DO
      IF (XTSR[RMFR] IN INLR) AND (XTSF[RMFR] IN INLF) AND
         (XTSR[RMTO] IN INRR) AND (XTSF[RMTO] IN INRF) AND
         (NOT RMIL) AND (BOARD.RBIS[RMFR] = INTP) THEN
        IF RMCA = IFCA THEN
          IF RMCA THEN
            IF RMCP = INCP THEN
              YRMHIT
            ELSE
          ELSE
            YRMHIT;
  END; (* YRMCOM *)
  
  PROCEDURE YRMCAP; (* SEMANTICS - CAPTURE *)
  BEGIN
    IFCA := TRUE;
  END; (* YRMCAP *)
  
  PROCEDURE YRMCAS; (* SEMANTICS - CASTLE *)
  BEGIN
    IFOO := TRUE;
  END; (* YRMCAS *)
  
  PROCEDURE YRMCPC; (* SEMANTICS - CAPTURED PIECE *)
  BEGIN
    CASE INTC OF
      'P': INCP := XTUMP[EP,OTHER[JNTM]];
      'R': INCP := XTUMP[ER,OTHER[JNTM]];
      'N': INCP := XTUMP[EN,OTHER[JNTM]];
      'B': INCP := XTUMP[EB,OTHER[JNTM]];Š      'Q': INCP := XTUMP[EQ,OTHER[JNTM]]
    END;
  END;
  
  PROCEDURE YRMCQS; (* SEMANTICS - CASTLE LONG *)
  BEGIN
    IFQS := TRUE;
  END; (* YRMCQS *)
  
  PROCEDURE YRMLKQ; (* SEMANTICS - K OR Q ON LEFT *)
  BEGIN
    CASE INTC OF
      'K': INLF := [F5..F8] * INLF;
      'Q': INLF := [F1..F4] * INLF
    END;
    IFLF := TRUE;
  END; (* YRMLKQ *)
  
  PROCEDURE YRMLRB; (* SEMANTICS - R, N, OR B ON LEFT *)
  BEGIN
    CASE INTC OF
      'R': INLF := [F1,F8] * INLF;
      'N': INLF := [F2,F7] * INLF;
      'B': INLF := [F3,F6] * INLF
    END;
    IFLD := TRUE;
  END; (* YRMLRB *)
  
  PROCEDURE YRMLRK; (* SEMANTICS - RANK ON LEFT *)
  BEGIN
    IF JNTM = LITE THEN
      CASE INTC OF
        '1': INLR := [R1];
        '2': INLR := [R2];
        '3': INLR := [R3];
        '4': INLR := [R4];
        '5': INLR := [R5];
        '6': INLR := [R6];
        '7': INLR := [R7];
        '8': INLR := [R8]
      END
    ELSE
      CASE INTC OF
        '1': INLR := [R8];
        '2': INLR := [R7];
        '3': INLR := [R6];
        '4': INLR := [R5];
        '5': INLR := [R4];
        '6': INLR := [R3];
        '7': INLR := [R2];
        '8': INLR := [R1]
      END;
  END; (* YRMLRK *)
    Š  PROCEDURE YRMNUL; (* SEMANTICS - NULL *)
  BEGIN
  END; (* YRMNUL *)
  
  PROCEDURE YRMPCM; (* SEMANTICS - PIECE MOVED *)
  BEGIN
    CASE INTC OF
      'P': INTP := XTUMP[EP,JNTM];        (* PAWN *)
      'R': INTP := XTUMP[ER,JNTM];        (* ROOK *)
      'N': INTP := XTUMP[EN,JNTM];        (* KNIGHT *)
      'B': INTP := XTUMP[EB,JNTM];        (* BISHOP *)
      'Q': INTP := XTUMP[EQ,JNTM];        (* QUEEN *)
      'K': INTP := XTUMP[EK,JNTM]         (* KING *)
    END;
  END; (* YRMPCM *)
  
  PROCEDURE YRMPRO; (* SEMANTICS - PROMOTION *)
  BEGIN
    CASE INTC OF
      'R': INTG := PR;
      'N': INTG := PN;
      'B': INTG := PB;
      'Q': INTG := PQ
    END;
    IFPR := TRUE;
  END; (* YRMPRO *)
  
  PROCEDURE YRMRKQ; (* SEMANTICS - K OR Q ON RIGHT *)
  BEGIN
    CASE INTC OF
      'K': INRF := [F5..F8] * INRF;
      'Q': INRF := [F1..F4] * INRF
    END;
    IFRF := TRUE;
  END; (* YRMRKQ *)
  
  PROCEDURE YRMRRB; (* SEMANTICS - R, N, OR B ON RIGHT *)
  BEGIN
    CASE INTC OF
      'R': INRF := [F1,F8] * INRF;
      'N': INRF := [F2,F7] * INRF;
      'B': INRF := [F3,F6] * INRF
    END;
    IFRD := TRUE;
  END; (* YRMRRB *)
  
  PROCEDURE YRMRRK; (* SEMANTICS - RANK ON RIGHT *)
  BEGIN
    IF JNTM = LITE THEN
      CASE INTC OF
        '1': INRR := [R1];
        '2': INRR := [R2];
        '3': INRR := [R3];
        '4': INRR := [R4];Š        '5': INRR := [R5];
        '6': INRR := [R6];
        '7': INRR := [R7];
        '8': INRR := [R8]
      END
    ELSE
      CASE INTC OF
        '1': INRR := [R8];
        '2': INRR := [R7];
        '3': INRR := [R6];
        '4': INRR := [R5];
        '5': INRR := [R4];
        '6': INRR := [R3];
        '7': INRR := [R2];
        '8': INRR := [R1]
      END;
  END; (* YRMRRK *)
  
  PROCEDURE PNCHIN; (* PROCESS INPUT LINE *)
  LABEL 11, 12, 13, 14, 15, 16, 18;
  
    FUNCTION NCHIN(A:SC; YRMXXX:TI):TB; (* SEMANTICS RTN TO CALL *)
    VAR INTB : TB;
    BEGIN (* NCHIN *)
      INTB := NOT (INTC IN A);
      IF NOT INTB THEN
      BEGIN
        CASE YRMXXX OF
          1 : YRMCAP;
          2 : YRMCAS;
          3 : YRMCPC;
          4 : YRMCQS;
          5 : YRMLKQ;
          6 : YRMLRB;
          7 : YRMLRK;
          8 : YRMNUL;
          9 : YRMPCM;
          10: YRMPRO;
          11: YRMRKQ;
          12: YRMRRB;
          13: YRMRRK
        END;
        JNTJ := JNTJ + 1;
        WHILE (JNTJ < ZJ) AND
             ((ILINE[JNTJ] = ' ') OR (ORD(ILINE[JNTJ]) > ORD(ZC))) DO
          JNTJ := JNTJ + 1;
        INTC := ILINE[JNTJ];
        IF (INTC = '.') OR (INTC = ';') THEN
          EXIT(PNCHIN);
      END;
      NCHIN := INTB;
    END; (* NCHIN *)
    
  BEGIN (* PNCHIN *)Š    IF     NCHIN(['P','R','N','B','Q','K'],9) THEN GOTO 14;
    IF     NCHIN(['/']                    ,8) THEN GOTO 11;
    IF     NCHIN(['K','Q']                ,5) THEN ;
    IF     NCHIN(['R','N','B']            ,6) THEN ;
    IF     NCHIN(['1'..'8']               ,7) THEN ;
11: (* LEFT SIDE DONE *)
    IF NOT NCHIN(['-']                    ,8) THEN GOTO 12;
    IF     NCHIN(['*','X']                ,1) THEN GOTO 16;
    IF     NCHIN(['P','R','N','B','Q']    ,3) THEN GOTO 16;
    IF     NCHIN(['/']                    ,8) THEN GOTO 13;
12: (* RIGHT SIDE SQUARE *)
    IF     NCHIN(['K','Q']                ,11) THEN ;
    IF     NCHIN(['R','N','B']            ,12) THEN ;
    IF     NCHIN(['1'..'8']               ,13) THEN ;
13: (* PROMOTION *)
    IF     NCHIN(['=']                    ,8) THEN GOTO 15;
    IF     NCHIN(['R','N','B','Q']        ,10) THEN GOTO 16;
    GOTO 15;
14: (* CASTLING *)
    IF     NCHIN(['O','0']                ,8) THEN GOTO 16;
    IF     NCHIN(['-']                    ,8) THEN GOTO 16;
    IF     NCHIN(['O','0']                ,2) THEN GOTO 16;
    IF     NCHIN(['-']                    ,4) THEN GOTO 15;
    IF     NCHIN(['O','0']                ,8) THEN GOTO 16;
15: (* SYNTAX CORRECT *)
    GOTO 18;
16: (* SYNTAX ERROR *)
    SYNE := TRUE;
18: (* EXIT *)
  END; (* PNCHIN *)
  
BEGIN (* YRMOVE *)
  INTB := FALSE;
  WHILE NOT INTB DO
  BEGIN
    CEND := FALSE;
    CINI := FALSE;
    READER;                             (* READ NEXT MOVE *)
    LSTMOV;                             (* LIST LEGAL MOVES *)
    IFCA := FALSE;
    IFPR := FALSE;
    IFOO := FALSE;
    IFQS := FALSE;
    IFLD := FALSE;
    IFLF := FALSE;
    IFRD := FALSE;
    IFRF := FALSE;
    INTP := MT;
    INCP := MT;
    INLF := [F1..F8];
    INRF := [F1..F8];
    INLR := [R1..R8];
    INRR := [R1..R8];
    INTC := ILINE[JNTJ];Š    AMBG := FALSE;
    SYNE := FALSE;
    PNCHIN;
    IF SYNE THEN
      GOTO 6;
    IF IFRF AND NOT IFRD THEN
      INRF := INRF * [F4,F5];
    IF IFLF AND NOT IFLD THEN
      INLF := INLF * [F4,F5];
    IFMV := FALSE;
    INTW := AW;
    WHILE INTW < JNTW DO
      WITH MOVES[INTW] DO
      BEGIN
        IF RMPR = IFPR THEN
          IF RMPR THEN
            IF RMPP = INTG THEN
            BEGIN
              YRMCOM;
              IF AMBG THEN
                GOTO 7;
            END
            ELSE
          ELSE
            IF RMOO = IFOO THEN
              IF RMOO THEN
                IF RMQS = IFQS THEN
                BEGIN
                  YRMHIT;
                  IF AMBG THEN
                    GOTO 7;
                END
                ELSE
              ELSE
              BEGIN
                YRMCOM;
                IF AMBG THEN
                  GOTO 7;
              END;
        INTW := INTW + 1;
      END;
    IF IFMV THEN
    BEGIN
      MINENG(INRM,'YOUR MOVE ');
      WRITELN(MOVMS);
      IF SWEC AND (SWTR OR SWPS OR SWSU) THEN
        WRITELN(PRNTR,MOVMS);
      IF (SWTR OR SWPS OR SWSU) THEN
      BEGIN
        PRIMOV(INRM);
        IF SWEC THEN
          PTRMOV(INRM);
      END;
      THEMOV(INRM);Š      INTB := TRUE;
    END
    ELSE
      WRITELN(' ILLEGAL MOVE.');
    GOTO 8;
6:  (* SYNTAX ERROR *)
    WRITELN(' SYNTAX ERROR ');
    GOTO 8;
7:  (* AMBIGUOUS MOVE *)
    WRITELN(' AMBIGUOUS MOVE.');
8:  (* EXIT *)
  END;
END; (* YRMOVE *)




BEGIN (* MAIN PROGRAM *)
  
  GOTOXY(25,11);
  WRITELN('HELLO.  WELCOME TO CHESS 0.5');
  GOTOXY(30,12);
  WRITELN('DEBUG/TRACE VERSION');
  WRITELN;
  
  WRITELN('INITIALIZING VARIABLES AND ARRAYS.');
  WRITELN;
  INICON;
  WRITELN('OPENING PRINTER DEBUG/TRACE FILE.');
  WRITELN;
  REWRITE(PRNTR,'PRINTER:');  (* OPEN PRINTER OUTPUT DEVICE *)

1: (* INITIALIZE FOR A NEW GAME *)
  WRITELN('INITIALIZING BOARD.');
  WRITELN;
  INITIAL(BOARD);
  REPEAT
    (* PROCESS PLAYER'S MOVE *)
    REPEAT
      YRMOVE;
    UNTIL SWRE;

    (* WAS GAME 'END' OR 'INITIALIZE FOR NEW GAME' REQUESTED *)
    IF CEND THEN
      GOTO 9;
    IF CINI THEN
      GOTO 1;

2: (* PROCESS MACHINE'S MOVE *)
    REPEAT
      MYMOVE;
      IF GOING > 0 THEN
        GOING := GOING - 1;
    UNTIL GOING = 0;Š  UNTIL FALSE;

9: (* END OF PROGRAM *)
  CLOSE(PRNTR);
END (* MAIN PROGRAM *).

