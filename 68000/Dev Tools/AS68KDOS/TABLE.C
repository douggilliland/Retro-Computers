#include "table.h"
struct tmpl template[] = {

{ bu, {DN,DN}, RXRY, 0xC100, 0x0 },        /* 0 = abcd */
{ bu, {PREDEC,PREDEC}, RXRY, 0xC108, 0x0 },
{ bwlu, {IMMED,DATALT}, IMMEAS, 0x0600, 0x0 },        /* 2 = add */
{ wlu, {ANYEA,DN}, EAREGS, 0xD000, 0x0 },
{ B, {DATA,DN}, EAREGS, 0xD000, 0x0 },
{ bwlu, {DN,ALTMEM}, REGEAS, 0xD100, 0x0 },
{ wu, {ANYEA,AN}, EAREG, 0xD0C0, 0x0 },
{ L, {ANYEA,AN}, EAREG, 0xD1C0, 0x0 },
{ wu, {ANYEA,AN}, EAREG, 0xD0C0, 0x0 },        /* 8 = adda */
{ L, {ANYEA,AN}, EAREG, 0xD1C0, 0x0 },
{ bwlu, {IMMED,DATALT}, IMMEAS, 0x0600, 0x0 },        /* 10 = addi */
{ bwlu, {IMMED,ALTER}, QUKEA, 0x5000, 0x0 },        /* 11 = addq */
{ bwlu, {DN,DN}, RXRYS, 0xD100, 0x0 },        /* 12 = addx */
{ bwlu, {PREDEC,PREDEC}, RXRYS, 0xD108, 0x0 },
{ bwlu, {DATA,DN}, EAREGS, 0xC000, 0x0 },        /* 14 = and */
{ bwlu, {DN,ALTMEM}, REGEAS, 0xC100, 0x0 },
{ bwlu, {IMMED,DATALT}, IMMEAS, 0x0200, 0x0 },
{ bu, {IMMED,CCR}, IMMB, 0x023C, 0x0 },
{ wu, {IMMED,SR}, IMMW, 0x027C, 0x0 },
{ bwlu, {IMMED,DATALT}, IMMEAS, 0x0200, 0x0 },        /* 19 = andi */
{ bu, {IMMED,CCR}, IMMB, 0x023C, 0x0 },
{ wu, {IMMED,SR}, IMMW, 0x027C, 0x0 },
{ wu, {ALTMEM}, EA, 0xE1C0, 0x0 },        /* 22 = asl */
{ bwlu, {DN,DN}, RSHIFT, 0xE120, 0x0 },
{ bwlu, {IMMED,DN}, QSHIFT, 0xE100, 0x0 },
{ wu, {ALTMEM}, EA, 0xE0C0, 0x0 },        /* 25 = asr */
{ bwlu, {DN,DN}, RSHIFT, 0xE020, 0x0 },
{ bwlu, {IMMED,DN}, QSHIFT, 0xE000, 0x0 },
{ bwlsu, {EXPR}, BCC, 0x6400, 0x0 },        /* 28 = bcc */
{ bwlsu, {EXPR}, BCC, 0x6500, 0x0 },        /* 29 = bcs */
{ bwlsu, {EXPR}, BCC, 0x6700, 0x0 },        /* 30 = beq */
{ bwlsu, {EXPR}, BCC, 0x6C00, 0x0 },        /* 31 = bge */
{ bwlsu, {EXPR}, BCC, 0x6E00, 0x0 },        /* 32 = bgt */
{ bwlsu, {EXPR}, BCC, 0x6200, 0x0 },        /* 33 = bhi */
{ bwlsu, {EXPR}, BCC, 0x6F00, 0x0 },        /* 34 = ble */
{ bwlsu, {EXPR}, BCC, 0x6300, 0x0 },        /* 35 = bls */
{ bwlsu, {EXPR}, BCC, 0x6D00, 0x0 },        /* 36 = blt */
{ bwlsu, {EXPR}, BCC, 0x6B00, 0x0 },        /* 37 = bmi */
{ bwlsu, {EXPR}, BCC, 0x6600, 0x0 },        /* 38 = bne */
{ bwlsu, {EXPR}, BCC, 0x6A00, 0x0 },        /* 39 = bpl */
{ bwlsu, {EXPR}, BCC, 0x6800, 0x0 },        /* 40 = bvc */
{ bwlsu, {EXPR}, BCC, 0x6900, 0x0 },        /* 41 = bvs */
{ bwlsu, {EXPR}, BCC, 0x6000, 0x0 },        /* 42 = bra */
{ bwlsu, {EXPR}, BCC, 0x6100, 0x0 },        /* 43 = bsr */
{ lu, {DN,DN}, REGEA, 0x0140, 0x0 },        /* 44 = bchg */
{ lu, {IMMED,DN}, BIT, 0x0840, 0x0 },
{ bu, {DN,ALTMEM}, REGEA, 0x0140, 0x0 },
{ bu, {IMMED,ALTMEM}, BIT, 0x0840, 0x0 },
{ lu, {DN,DN}, REGEA, 0x0180, 0x0 },        /* 48 = bclr */
{ lu, {IMMED,DN}, BIT, 0x0880, 0x0 },
{ bu, {DN,ALTMEM}, REGEA, 0x0180, 0x0 },
{ bu, {IMMED,ALTMEM}, BIT, 0x0880, 0x0 },
{ lu, {DN,DN}, REGEA, 0x01C0, 0x0 },        /* 52 = bset */
{ lu, {IMMED,DN}, BIT, 0x08C0, 0x0 },
{ bu, {DN,ALTMEM}, REGEA, 0x01C0, 0x0 },
{ bu, {IMMED,ALTMEM}, BIT, 0x08C0, 0x0 },
{ lu, {DN,DN}, REGEA, 0x0100, 0x0 },        /* 56 = btst */
{ lu, {IMMED,DN}, BIT, 0x0800, 0x0 },
{ bu, {DN,DATA}, REGEA, 0x0100, 0x0 },
{ bu, {IMMED,DATA}, BIT, 0x0800, 0x0 },
{ U, {DATALT,FIELD}, BITFLD, 0xEAC0, 0x0 },        /* 60 = bfchg */
{ U, {DATALT,FIELD}, BITFLD, 0xECC0, 0x0 },        /* 61 = bfclr */
{ U, {DN,FIELD,DN}, BITFLD2, 0xEBC0, 0x0 },        /* 62 = bfexts */
{ U, {CONTROL,FIELD,DN}, BITFLD2, 0xEBC0, 0x0 },
{ U, {DN,FIELD,DN}, BITFLD2, 0xE9C0, 0x0 },        /* 64 = bfextu */
{ U, {CONTROL,FIELD,DN}, BITFLD2, 0xE9C0, 0x0 },
{ U, {DN,FIELD,DN}, BITFLD2, 0xEDC0, 0x0 },        /* 66 = bfffo */
{ U, {CONTROL,FIELD,DN}, BITFLD2, 0xEDC0, 0x0 },
{ U, {DN,DATALT,FIELD}, BITFLD2, 0xEFC0, 0x0 },        /* 68 = bfins */
{ U, {DATALT,FIELD}, BITFLD, 0xEEC0, 0x0 },        /* 69 = bfset */
{ U, {DN,FIELD}, BITFLD, 0xE8C0, 0x0 },        /* 70 = bftst */
{ U, {CONTROL,FIELD}, BITFLD, 0xE8C0, 0x0 },
{ U, {IMMED}, IMM3, 0x4848, 0x0 },        /* 72 = bkpt */
{ U, {IMMED,CONTROL}, CALLM, 0x06C0, 0x0 },        /* 73 = callm */
{ bwlu, {DN,DN,ALTMEM}, CAS, 0x08C0, 0x0 },        /* 74 = cas */
{ wlu, {DPAIR,DPAIR,RPAIR}, CAS2, 0x08FC, 0x0 },        /* 75 = cas2 */
{ wlu, {DATA,DN}, CHK, 0x4100, 0x0 },        /* 76 = chk */
{ bwlu, {CONTROL,RN}, CHK2, 0x00C0, 0x0800 },        /* 77 = chk2 */
{ bwlu, {DATALT}, EAS, 0x4200, 0x0 },        /* 78 = clr */
{ bwlu, {IMMED,DATA}, IMMEAS, 0x0C00, 0x0 },        /* 79 = cmp */
{ wlu, {ANYEA,DN}, EAREGS, 0xB000, 0x0 },
{ B, {DATA,DN}, EAREGS, 0xB000, 0x0 },
{ wu, {ANYEA,AN}, EAREG, 0xB0C0, 0x0 },
{ L, {ANYEA,AN}, EAREG, 0xB1C0, 0x0 },
{ bwlu, {PSTINC,PSTINC}, RXRYS, 0xB108, 0x0 },
{ wu, {ANYEA,AN}, EAREG, 0xB0C0, 0x0 },        /* 85 = cmpa */
{ L, {ANYEA,AN}, EAREG, 0xB1C0, 0x0 },
{ bwlu, {IMMED,DATA}, IMMEAS, 0x0C00, 0x0 },        /* 87 = cmpi */
{ bwlu, {PSTINC,PSTINC}, RXRYS, 0xB108, 0x0 },        /* 88 = cmpm */
{ bwlu, {CONTROL,RN}, CHK2, 0x00C0, 0x0000 },        /* 89 = cmp2 */
{ U, {DN,EXPR}, DBCC, 0x54C8, 0x0 },        /* 90 = dbcc */
{ U, {DN,EXPR}, DBCC, 0x55C8, 0x0 },        /* 91 = dbcs */
{ U, {DN,EXPR}, DBCC, 0x57C8, 0x0 },        /* 92 = dbeq */
{ U, {DN,EXPR}, DBCC, 0x51C8, 0x0 },        /* 93 = dbf */
{ U, {DN,EXPR}, DBCC, 0x5CC8, 0x0 },        /* 94 = dbge */
{ U, {DN,EXPR}, DBCC, 0x5EC8, 0x0 },        /* 95 = dbgt */
{ U, {DN,EXPR}, DBCC, 0x52C8, 0x0 },        /* 96 = dbhi */
{ U, {DN,EXPR}, DBCC, 0x5FC8, 0x0 },        /* 97 = dble */
{ U, {DN,EXPR}, DBCC, 0x53C8, 0x0 },        /* 98 = dbls */
{ U, {DN,EXPR}, DBCC, 0x5DC8, 0x0 },        /* 99 = dblt */
{ U, {DN,EXPR}, DBCC, 0x5BC8, 0x0 },        /* 100 = dbmi */
{ U, {DN,EXPR}, DBCC, 0x56C8, 0x0 },        /* 101 = dbne */
{ U, {DN,EXPR}, DBCC, 0x5AC8, 0x0 },        /* 102 = dbpl */
{ U, {DN,EXPR}, DBCC, 0x50C8, 0x0 },        /* 103 = dbt */
{ U, {DN,EXPR}, DBCC, 0x58C8, 0x0 },        /* 104 = dbvc */
{ U, {DN,EXPR}, DBCC, 0x59C8, 0x0 },        /* 105 = dbvs */
{ U, {DN,EXPR}, DBCC, 0x51C8, 0x0 },        /* 106 = dbra */
{ wu, {DATA,DN}, EAREG, 0x81C0, 0x0 },        /* 107 = divs */
{ L, {DATA,DN}, MULDIV, 0x4C40, 0x0800 },
{ L, {DATA,DPAIR}, MULDIV, 0x4C40, 0x0800 },
{ lu, {DATA,DPAIR}, MULDIV, 0x4C40, 0x0C00 },        /* 110 = divsl */
{ wu, {DATA,DN}, EAREG, 0x80C0, 0x0 },        /* 111 = divu */
{ L, {DATA,DN}, MULDIV, 0x4C40, 0x0000 },
{ L, {DATA,DPAIR}, MULDIV, 0x4C40, 0x0000 },
{ lu, {DATA,DPAIR}, MULDIV, 0x4C40, 0x0400 },        /* 114 = divul */
{ bwlu, {DN,DATALT}, REGEAS, 0xB100, 0x0 },        /* 115 = eor */
{ bwlu, {IMMED,DATALT}, IMMEAS, 0x0A00, 0x0 },
{ bu, {IMMED,CCR}, IMMB, 0x0A3C, 0x0 },
{ wu, {IMMED,SR}, IMMW, 0x0A7C, 0x0 },
{ bwlu, {IMMED,DATALT}, IMMEAS, 0x0A00, 0x0 },        /* 119 = eori */
{ bu, {IMMED,CCR}, IMMB, 0x0A3C, 0x0 },
{ wu, {IMMED,SR}, IMMW, 0x0A7C, 0x0 },
{ lu, {DN,DN}, RXRY, 0xC140, 0x0 },        /* 122 = exg */
{ lu, {AN,AN}, RXRY, 0xC148, 0x0 },
{ lu, {DN,AN}, RXRYR, 0xC188, 0x0 },
{ lu, {AN,DN}, RXRY, 0xC188, 0x0 },
{ wu, {DN}, REG, 0x4880, 0x0 },        /* 126 = ext */
{ L, {DN}, REG, 0x48C0, 0x0 },
{ lu, {DN}, REG, 0x49C0, 0x0 },        /* 128 = extb */
{ U, {EMPTY}, INH, 0x4AFC, 0x0 },        /* 129 = illegal */
{ U, {CONTROL}, EA, 0x4EC0, 0x0 },        /* 130 = jmp */
{ U, {CONTROL}, EA, 0x4E80, 0x0 },        /* 131 = jsr */
{ lu, {CONTROL,AN}, EAREG, 0x41C0, 0x0 },        /* 132 = lea */
{ wu, {AN,IMMED}, REGIMM, 0x4E50, 0x0 },        /* 133 = link */
{ L, {AN,IMMED}, REGIMM, 0x4808, 0x0 },
{ wu, {ALTMEM}, EA, 0xE3C0, 0x0 },        /* 135 = lsl */
{ bwlu, {DN,DN}, RSHIFT, 0xE128, 0x0 },
{ bwlu, {IMMED,DN}, QSHIFT, 0xE108, 0x0 },
{ wu, {ALTMEM}, EA, 0xE2C0, 0x0 },        /* 138 = lsr */
{ bwlu, {DN,DN}, RSHIFT, 0xE028, 0x0 },
{ bwlu, {IMMED,DN}, QSHIFT, 0xE008, 0x0 },
{ wu, {ANYEA,DATALT}, MOVE, 0x3000, 0x0 },        /* 141 = move */
{ B, {DATA,DATALT}, MOVE, 0x1000, 0x0 },
{ L, {ANYEA,DATALT}, MOVE, 0x2000, 0x0 },
{ wu, {ANYEA,AN}, MOVE, 0x3000, 0x0 },
{ L, {ANYEA,AN}, MOVE, 0x2000, 0x0 },
{ wu, {CCR,DATALT}, EAREV, 0x42C0, 0x0 },
{ wu, {DATA,CCR}, EA, 0x44C0, 0x0 },
{ wu, {SR,DATALT}, EAREV, 0x40C0, 0x0 },
{ wu, {DATA,SR}, EA, 0x46C0, 0x0 },
{ lu, {CN,AN}, MOVEU, 0x4E68, 0x0 },
{ lu, {AN,CN}, MOVEU, 0x4E60, 0x0 },
{ wu, {ANYEA,AN}, MOVE, 0x3000, 0x0 },        /* 152 = movea */
{ L, {ANYEA,AN}, MOVE, 0x2000, 0x0 },
{ lu, {CN,RN}, MOVEC, 0x4E7A, 0x0 },        /* 154 = movec */
{ lu, {RN,CN}, MOVEC, 0x4E7B, 0x0 },
{ wu, {RN,CALTPR}, MOVEMO, 0x4880, 0x0 },        /* 156 = movem */
{ L, {RN,CALTPR}, MOVEMO, 0x48C0, 0x0 },
{ wu, {RLIST,CALTPR}, MOVEMO, 0x4880, 0x0 },
{ L, {RLIST,CALTPR}, MOVEMO, 0x48C0, 0x0 },
{ wu, {CTLPST,RN}, MOVEMI, 0x4C80, 0x0 },
{ L, {CTLPST,RN}, MOVEMI, 0x4CC0, 0x0 },
{ wu, {CTLPST,RLIST}, MOVEMI, 0x4C80, 0x0 },
{ L, {CTLPST,RLIST}, MOVEMI, 0x4CC0, 0x0 },
{ wu, {DN,INDEX}, MOVEPO, 0x0188, 0x0 },        /* 164 = movep */
{ L, {DN,INDEX}, MOVEPO, 0x01C8, 0x0 },
{ wu, {INDEX,DN}, MOVEPI, 0x0108, 0x0 },
{ L, {INDEX,DN}, MOVEPI, 0x0148, 0x0 },
{ lu, {IMMED,DN}, MOVEQ, 0x7000, 0x0 },        /* 168 = moveq */
{ bwlu, {RN,ALTMEM}, MOVES, 0x0E00, 0x0800 },        /* 169 = moves */
{ bwlu, {ALTMEM,RN}, MOVES, 0x0E00, 0x0000 },
{ wu, {DATA,DN}, EAREG, 0xC1C0, 0x0 },        /* 171 = muls */
{ L, {DATA,DN}, MULDIV, 0x4C00, 0x0800 },
{ L, {DATA,DPAIR}, MULDIV, 0x4C00, 0x0C00 },
{ wu, {DATA,DN}, EAREG, 0xC0C0, 0x0 },        /* 174 = mulu */
{ L, {DATA,DN}, MULDIV, 0x4C00, 0x0000 },
{ L, {DATA,DPAIR}, MULDIV, 0x4C00, 0x0400 },
{ bu, {DATALT}, EA, 0x4800, 0x0 },        /* 177 = nbcd */
{ bwlu, {DATALT}, EAS, 0x4400, 0x0 },        /* 178 = neg */
{ bwlu, {DATALT}, EAS, 0x4000, 0x0 },        /* 179 = negx */
{ U, {EMPTY}, INH, 0x4E71, 0x0 },        /* 180 = nop */
{ bwlu, {DATALT}, EAS, 0x4600, 0x0 },        /* 181 = not */
{ bwlu, {DATA,DN}, EAREGS, 0x8000, 0x0 },        /* 182 = or */
{ bwlu, {DN,ALTMEM}, REGEAS, 0x8100, 0x0 },
{ bwlu, {IMMED,DATALT}, IMMEAS, 0x0000, 0x0 },
{ bu, {IMMED,CCR}, IMMB, 0x003C, 0x0 },
{ wu, {IMMED,SR}, IMMW, 0x007C, 0x0 },
{ bwlu, {IMMED,DATALT}, IMMEAS, 0x0000, 0x0 },        /* 187 = ori */
{ bu, {IMMED,CCR}, IMMB, 0x003C, 0x0 },
{ wu, {IMMED,SR}, IMMW, 0x007C, 0x0 },
{ U, {PREDEC,PREDEC,IMMED}, RXRYP, 0x8148, 0x0000 },        /* 190 = pack */
{ U, {DN,DN,IMMED}, RXRYP, 0x8140, 0x0000 },
{ lu, {CONTROL}, EA, 0x4840, 0x0 },        /* 192 = pea */
{ U, {EMPTY}, INH, 0x4E70, 0x0 },        /* 193 = reset */
{ wu, {ALTMEM}, EA, 0xE7C0, 0x0 },        /* 194 = rol */
{ bwlu, {DN,DN}, RSHIFT, 0xE138, 0x0 },
{ bwlu, {IMMED,DN}, QSHIFT, 0xE118, 0x0 },
{ wu, {ALTMEM}, EA, 0xE6C0, 0x0 },        /* 197 = ror */
{ bwlu, {DN,DN}, RSHIFT, 0xE038, 0x0 },
{ bwlu, {IMMED,DN}, QSHIFT, 0xE018, 0x0 },
{ wu, {ALTMEM}, EA, 0xE5C0, 0x0 },        /* 200 = roxl */
{ bwlu, {DN,DN}, RSHIFT, 0xE130, 0x0 },
{ bwlu, {IMMED,DN}, QSHIFT, 0xE110, 0x0 },
{ wu, {ALTMEM}, EA, 0xE4C0, 0x0 },        /* 203 = roxr */
{ bwlu, {DN,DN}, RSHIFT, 0xE030, 0x0 },
{ bwlu, {IMMED,DN}, QSHIFT, 0xE010, 0x0 },
{ U, {IMMED}, IMMWS, 0x4E74, 0x0 },        /* 206 = rtd */
{ U, {EMPTY}, INH, 0x4E73, 0x0 },        /* 207 = rte */
{ U, {AN}, REG, 0x06C8, 0x0 },        /* 208 = rtm */
{ U, {DN}, REG, 0x06C0, 0x0 },
{ U, {EMPTY}, INH, 0x4E77, 0x0 },        /* 210 = rtr */
{ U, {EMPTY}, INH, 0x4E75, 0x0 },        /* 211 = rts */
{ bu, {DN,DN}, RXRY, 0x8100, 0x0 },        /* 212 = sbcd */
{ bu, {PREDEC,PREDEC}, RXRY, 0x8108, 0x0 },
{ bu, {DATALT}, EA, 0x54C0, 0x0 },        /* 214 = scc */
{ bu, {DATALT}, EA, 0x55C0, 0x0 },        /* 215 = scs */
{ bu, {DATALT}, EA, 0x57C0, 0x0 },        /* 216 = seq */
{ bu, {DATALT}, EA, 0x51C0, 0x0 },        /* 217 = sf */
{ bu, {DATALT}, EA, 0x5CC0, 0x0 },        /* 218 = sge */
{ bu, {DATALT}, EA, 0x5EC0, 0x0 },        /* 219 = sgt */
{ bu, {DATALT}, EA, 0x52C0, 0x0 },        /* 220 = shi */
{ bu, {DATALT}, EA, 0x5FC0, 0x0 },        /* 221 = sle */
{ bu, {DATALT}, EA, 0x53C0, 0x0 },        /* 222 = sls */
{ bu, {DATALT}, EA, 0x5DC0, 0x0 },        /* 223 = slt */
{ bu, {DATALT}, EA, 0x5BC0, 0x0 },        /* 224 = smi */
{ bu, {DATALT}, EA, 0x56C0, 0x0 },        /* 225 = sne */
{ bu, {DATALT}, EA, 0x5AC0, 0x0 },        /* 226 = spl */
{ bu, {DATALT}, EA, 0x50C0, 0x0 },        /* 227 = st */
{ bu, {DATALT}, EA, 0x58C0, 0x0 },        /* 228 = svc */
{ bu, {DATALT}, EA, 0x59C0, 0x0 },        /* 229 = svs */
{ U, {IMMED}, IMMW, 0x4E72, 0x0 },        /* 230 = stop */
{ bwlu, {IMMED,DATALT}, IMMEAS, 0x0400, 0x0 },        /* 231 = sub */
{ wlu, {ANYEA,DN}, EAREGS, 0x9000, 0x0 },
{ B, {DATA,DN}, EAREGS, 0x9000, 0x0 },
{ bwlu, {DN,ALTMEM}, REGEAS, 0x9100, 0x0 },
{ wu, {ANYEA,AN}, EAREG, 0x90C0, 0x0 },
{ L, {ANYEA,AN}, EAREG, 0x91C0, 0x0 },
{ wu, {ANYEA,AN}, EAREG, 0x90C0, 0x0 },        /* 237 = suba */
{ L, {ANYEA,AN}, EAREG, 0x91C0, 0x0 },
{ bwlu, {IMMED,DATALT}, IMMEAS, 0x0400, 0x0 },        /* 239 = subi */
{ bwlu, {IMMED,ALTER}, QUKEA, 0x5100, 0x0 },        /* 240 = subq */
{ bwlu, {DN,DN}, RXRYS, 0x9100, 0x0 },        /* 241 = subx */
{ bwlu, {PREDEC,PREDEC}, RXRYS, 0x9108, 0x0 },
{ wu, {DN}, REG, 0x4840, 0x0 },        /* 243 = swap */
{ bu, {DATALT}, EA, 0x4AC0, 0x0 },        /* 244 = tas */
{ U, {IMMED}, IMM4, 0x4E40, 0x0 },        /* 245 = trap */
{ U, {EMPTY}, INH, 0x54FC, 0x0 },        /* 246 = trapcc */
{ wl, {IMMED}, TRAPCC, 0x54F8, 0x0 },
{ U, {EMPTY}, INH, 0x55FC, 0x0 },        /* 248 = trapcs */
{ wl, {IMMED}, TRAPCC, 0x55F8, 0x0 },
{ U, {EMPTY}, INH, 0x57FC, 0x0 },        /* 250 = trapeq */
{ wl, {IMMED}, TRAPCC, 0x57F8, 0x0 },
{ U, {EMPTY}, INH, 0x51FC, 0x0 },        /* 252 = trapf */
{ wl, {IMMED}, TRAPCC, 0x51F8, 0x0 },
{ U, {EMPTY}, INH, 0x5CFC, 0x0 },        /* 254 = trapge */
{ wl, {IMMED}, TRAPCC, 0x5CF8, 0x0 },
{ U, {EMPTY}, INH, 0x5EFC, 0x0 },        /* 256 = trapgt */
{ wl, {IMMED}, TRAPCC, 0x5EF8, 0x0 },
{ U, {EMPTY}, INH, 0x52FC, 0x0 },        /* 258 = traphi */
{ wl, {IMMED}, TRAPCC, 0x52F8, 0x0 },
{ U, {EMPTY}, INH, 0x5FFC, 0x0 },        /* 260 = traple */
{ wl, {IMMED}, TRAPCC, 0x5FF8, 0x0 },
{ U, {EMPTY}, INH, 0x53FC, 0x0 },        /* 262 = trapls */
{ wl, {IMMED}, TRAPCC, 0x53F8, 0x0 },
{ U, {EMPTY}, INH, 0x5DFC, 0x0 },        /* 264 = traplt */
{ wl, {IMMED}, TRAPCC, 0x5DF8, 0x0 },
{ U, {EMPTY}, INH, 0x5BFC, 0x0 },        /* 266 = trapmi */
{ wl, {IMMED}, TRAPCC, 0x5BF8, 0x0 },
{ U, {EMPTY}, INH, 0x56FC, 0x0 },        /* 268 = trapne */
{ wl, {IMMED}, TRAPCC, 0x56F8, 0x0 },
{ U, {EMPTY}, INH, 0x5AFC, 0x0 },        /* 270 = trappl */
{ wl, {IMMED}, TRAPCC, 0x5AF8, 0x0 },
{ U, {EMPTY}, INH, 0x50FC, 0x0 },        /* 272 = trapt */
{ wl, {IMMED}, TRAPCC, 0x50F8, 0x0 },
{ U, {EMPTY}, INH, 0x58FC, 0x0 },        /* 274 = trapvc */
{ wl, {IMMED}, TRAPCC, 0x58F8, 0x0 },
{ U, {EMPTY}, INH, 0x59FC, 0x0 },        /* 276 = trapvs */
{ wl, {IMMED}, TRAPCC, 0x59F8, 0x0 },
{ U, {EMPTY}, INH, 0x4E76, 0x0 },        /* 278 = trapv */
{ wlu, {ANYEA}, EAS, 0x4A00, 0x0 },        /* 279 = tst */
{ B, {DATA}, EAS, 0x4A00, 0x0 },
{ U, {AN}, REG, 0x4E58, 0x0 },        /* 281 = unlk */
{ U, {PREDEC,PREDEC,IMMED}, RXRYP, 0x8188, 0x0 },        /* 282 = unpk */
{ U, {DN,DN,IMMED}, RXRYP, 0x8180, 0x0 },
{ xu, {FN}, FMONAD, 0xF000, 0x0018 },        /* 284 = fabs */
{ bwlsdxp, {DATA,FN}, FEAREG, 0xF000, 0x4018 },
{ xu, {FN,FN}, FREGREG, 0xF000, 0x0018 },
{ xu, {FN}, FMONAD, 0xF000, 0x001C },        /* 287 = facos */
{ bwlsdxp, {DATA,FN}, FEAREG, 0xF000, 0x401C },
{ xu, {FN,FN}, FREGREG, 0xF000, 0x001C },
{ bwlsdxp, {DATA,FN}, FEAREG, 0xF000, 0x4022 },        /* 290 = fadd */
{ xu, {FN,FN}, FREGREG, 0xF000, 0x0022 },
{ xu, {FN}, FMONAD, 0xF000, 0x000C },        /* 292 = fasin */
{ bwlsdxp, {DATA,FN}, FEAREG, 0xF000, 0x400C },
{ xu, {FN,FN}, FREGREG, 0xF000, 0x000C },
{ xu, {FN}, FMONAD, 0xF000, 0x000A },        /* 295 = fatan */
{ bwlsdxp, {DATA,FN}, FEAREG, 0xF000, 0x400A },
{ xu, {FN,FN}, FREGREG, 0xF000, 0x000A },
{ xu, {FN}, FMONAD, 0xF000, 0x000D },        /* 298 = fatanh */
{ bwlsdxp, {DATA,FN}, FEAREG, 0xF000, 0x400D },
{ xu, {FN,FN}, FREGREG, 0xF000, 0x000D },
{ wlu, {EXPR}, FBCC, 0xF081, 0x0000 },        /* 301 = fbeq */
{ wlu, {EXPR}, FBCC, 0xF080, 0x0000 },        /* 302 = fbf */
{ wlu, {EXPR}, FBCC, 0xF093, 0x0000 },        /* 303 = fbge */
{ wlu, {EXPR}, FBCC, 0xF096, 0x0000 },        /* 304 = fbgl */
{ wlu, {EXPR}, FBCC, 0xF097, 0x0000 },        /* 305 = fbgle */
{ wlu, {EXPR}, FBCC, 0xF092, 0x0000 },        /* 306 = fbgt */
{ wlu, {EXPR}, FBCC, 0xF095, 0x0000 },        /* 307 = fble */
{ wlu, {EXPR}, FBCC, 0xF094, 0x0000 },        /* 308 = fblt */
{ wlu, {EXPR}, FBCC, 0xF08E, 0x0000 },        /* 309 = fbne */
{ wlu, {EXPR}, FBCC, 0xF09C, 0x0000 },        /* 310 = fbnge */
{ wlu, {EXPR}, FBCC, 0xF099, 0x0000 },        /* 311 = fbngl */
{ wlu, {EXPR}, FBCC, 0xF098, 0x0000 },        /* 312 = fbngle */
{ wlu, {EXPR}, FBCC, 0xF09D, 0x0000 },        /* 313 = fbngt */
{ wlu, {EXPR}, FBCC, 0xF09A, 0x0000 },        /* 314 = fbnle */
{ wlu, {EXPR}, FBCC, 0xF09B, 0x0000 },        /* 315 = fbnlt */
{ wlu, {EXPR}, FBCC, 0xF083, 0x0000 },        /* 316 = fboge */
{ wlu, {EXPR}, FBCC, 0xF086, 0x0000 },        /* 317 = fbogl */
{ wlu, {EXPR}, FBCC, 0xF082, 0x0000 },        /* 318 = fbogt */
{ wlu, {EXPR}, FBCC, 0xF085, 0x0000 },        /* 319 = fbole */
{ wlu, {EXPR}, FBCC, 0xF084, 0x0000 },        /* 320 = fbolt */
{ wlu, {EXPR}, FBCC, 0xF087, 0x0000 },        /* 321 = fbor */
{ wlu, {EXPR}, FBCC, 0xF08F, 0x0000 },        /* 322 = fbra */
{ wlu, {EXPR}, FBCC, 0xF091, 0x0000 },        /* 323 = fbseq */
{ wlu, {EXPR}, FBCC, 0xF090, 0x0000 },        /* 324 = fbsf */
{ wlu, {EXPR}, FBCC, 0xF09E, 0x0000 },        /* 325 = fbsne */
{ wlu, {EXPR}, FBCC, 0xF09F, 0x0000 },        /* 326 = fbst */
{ wlu, {EXPR}, FBCC, 0xF08F, 0x0000 },        /* 327 = fbt */
{ wlu, {EXPR}, FBCC, 0xF089, 0x0000 },        /* 328 = fbueq */
{ wlu, {EXPR}, FBCC, 0xF08B, 0x0000 },        /* 329 = fbuge */
{ wlu, {EXPR}, FBCC, 0xF08A, 0x0000 },        /* 330 = fbugt */
{ wlu, {EXPR}, FBCC, 0xF08D, 0x0000 },        /* 331 = fbule */
{ wlu, {EXPR}, FBCC, 0xF08C, 0x0000 },        /* 332 = fbult */
{ wlu, {EXPR}, FBCC, 0xF088, 0x0000 },        /* 333 = fbun */
{ bwlsdxp, {DATA,FN}, FEAREG, 0xF000, 0x4038 },        /* 334 = fcmp */
{ xu, {FN,FN}, FREGREG, 0xF000, 0x0038 },
{ xu, {FN}, FMONAD, 0xF000, 0x001D },        /* 336 = fcos */
{ bwlsdxp, {DATA,FN}, FEAREG, 0xF000, 0x401D },
{ xu, {FN,FN}, FREGREG, 0xF000, 0x001D },
{ xu, {FN}, FMONAD, 0xF000, 0x0019 },        /* 339 = fcosh */
{ bwlsdxp, {DATA,FN}, FEAREG, 0xF000, 0x4019 },
{ xu, {FN,FN}, FREGREG, 0xF000, 0x0019 },
{ U, {DN,EXPR}, FDBCC, 0xF048, 0x0001 },        /* 342 = fdbeq */
{ U, {DN,EXPR}, FDBCC, 0xF048, 0x0000 },        /* 343 = fdbf */
{ U, {DN,EXPR}, FDBCC, 0xF048, 0x0013 },        /* 344 = fdbge */
{ U, {DN,EXPR}, FDBCC, 0xF048, 0x0016 },        /* 345 = fdbgl */
{ U, {DN,EXPR}, FDBCC, 0xF048, 0x0017 },        /* 346 = fdbgle */
{ U, {DN,EXPR}, FDBCC, 0xF048, 0x0012 },        /* 347 = fdbgt */
{ U, {DN,EXPR}, FDBCC, 0xF048, 0x0015 },        /* 348 = fdble */
{ U, {DN,EXPR}, FDBCC, 0xF048, 0x0014 },        /* 349 = fdblt */
{ U, {DN,EXPR}, FDBCC, 0xF048, 0x000E },        /* 350 = fdbne */
{ U, {DN,EXPR}, FDBCC, 0xF048, 0x001C },        /* 351 = fdbnge */
{ U, {DN,EXPR}, FDBCC, 0xF048, 0x0019 },        /* 352 = fdbngl */
{ U, {DN,EXPR}, FDBCC, 0xF048, 0x0018 },        /* 353 = fdbngle */
{ U, {DN,EXPR}, FDBCC, 0xF048, 0x001D },        /* 354 = fdbngt */
{ U, {DN,EXPR}, FDBCC, 0xF048, 0x001A },        /* 355 = fdbnle */
{ U, {DN,EXPR}, FDBCC, 0xF048, 0x001B },        /* 356 = fdbnlt */
{ U, {DN,EXPR}, FDBCC, 0xF048, 0x0003 },        /* 357 = fdboge */
{ U, {DN,EXPR}, FDBCC, 0xF048, 0x0006 },        /* 358 = fdbogl */
{ U, {DN,EXPR}, FDBCC, 0xF048, 0x0002 },        /* 359 = fdbogt */
{ U, {DN,EXPR}, FDBCC, 0xF048, 0x0005 },        /* 360 = fdbole */
{ U, {DN,EXPR}, FDBCC, 0xF048, 0x0004 },        /* 361 = fdbolt */
{ U, {DN,EXPR}, FDBCC, 0xF048, 0x0007 },        /* 362 = fdbor */
{ U, {DN,EXPR}, FDBCC, 0xF048, 0x0000 },        /* 363 = fdbra */
{ U, {DN,EXPR}, FDBCC, 0xF048, 0x0011 },        /* 364 = fdbseq */
{ U, {DN,EXPR}, FDBCC, 0xF048, 0x0010 },        /* 365 = fdbsf */
{ U, {DN,EXPR}, FDBCC, 0xF048, 0x001E },        /* 366 = fdbsne */
{ U, {DN,EXPR}, FDBCC, 0xF048, 0x001F },        /* 367 = fdbst */
{ U, {DN,EXPR}, FDBCC, 0xF048, 0x000F },        /* 368 = fdbt */
{ U, {DN,EXPR}, FDBCC, 0xF048, 0x0009 },        /* 369 = fdbueq */
{ U, {DN,EXPR}, FDBCC, 0xF048, 0x000B },        /* 370 = fdbuge */
{ U, {DN,EXPR}, FDBCC, 0xF048, 0x000A },        /* 371 = fdbugt */
{ U, {DN,EXPR}, FDBCC, 0xF048, 0x000D },        /* 372 = fdbule */
{ U, {DN,EXPR}, FDBCC, 0xF048, 0x000C },        /* 373 = fdbult */
{ U, {DN,EXPR}, FDBCC, 0xF048, 0x0008 },        /* 374 = fdbun */
{ bwlsdxp, {DATA,FN}, FEAREG, 0xF000, 0x4020 },        /* 375 = fdiv */
{ xu, {FN,FN}, FREGREG, 0xF000, 0x0020 },
{ xu, {FN}, FMONAD, 0xF000, 0x0010 },        /* 377 = fetox */
{ bwlsdxp, {DATA,FN}, FEAREG, 0xF000, 0x4010 },
{ xu, {FN,FN}, FREGREG, 0xF000, 0x0010 },
{ xu, {FN}, FMONAD, 0xF000, 0x0008 },        /* 380 = fetoxm1 */
{ bwlsdxp, {DATA,FN}, FEAREG, 0xF000, 0x4008 },
{ xu, {FN,FN}, FREGREG, 0xF000, 0x0008 },
{ xu, {FN}, FMONAD, 0xF000, 0x001E },        /* 383 = fgetexp */
{ bwlsdxp, {DATA,FN}, FEAREG, 0xF000, 0x401E },
{ xu, {FN,FN}, FREGREG, 0xF000, 0x001E },
{ xu, {FN}, FMONAD, 0xF000, 0x001F },        /* 386 = fgetman */
{ bwlsdxp, {DATA,FN}, FEAREG, 0xF000, 0x401F },
{ xu, {FN,FN}, FREGREG, 0xF000, 0x001F },
{ xu, {FN}, FMONAD, 0xF000, 0x0001 },        /* 389 = fint */
{ bwlsdxp, {DATA,FN}, FEAREG, 0xF000, 0x4001 },
{ xu, {FN,FN}, FREGREG, 0xF000, 0x0001 },
{ xu, {FN}, FMONAD, 0xF000, 0x0003 },        /* 392 = fintrz */
{ bwlsdxp, {DATA,FN}, FEAREG, 0xF000, 0x4003 },
{ xu, {FN,FN}, FREGREG, 0xF000, 0x0003 },
{ xu, {FN}, FMONAD, 0xF000, 0x0015 },        /* 395 = flog10 */
{ bwlsdxp, {DATA,FN}, FEAREG, 0xF000, 0x4015 },
{ xu, {FN,FN}, FREGREG, 0xF000, 0x0015 },
{ xu, {FN}, FMONAD, 0xF000, 0x0016 },        /* 398 = flog2 */
{ bwlsdxp, {DATA,FN}, FEAREG, 0xF000, 0x4016 },
{ xu, {FN,FN}, FREGREG, 0xF000, 0x0016 },
{ xu, {FN}, FMONAD, 0xF000, 0x0014 },        /* 401 = flogn */
{ bwlsdxp, {DATA,FN}, FEAREG, 0xF000, 0x4014 },
{ xu, {FN,FN}, FREGREG, 0xF000, 0x0014 },
{ xu, {FN}, FMONAD, 0xF000, 0x0006 },        /* 404 = flognp1 */
{ bwlsdxp, {DATA,FN}, FEAREG, 0xF000, 0x4006 },
{ xu, {FN,FN}, FREGREG, 0xF000, 0x0006 },
{ bwlsdxp, {DATA,FN}, FEAREG, 0xF000, 0x4021 },        /* 407 = fmod */
{ xu, {FN,FN}, FREGREG, 0xF000, 0x0021 },
{ bwlsdxp, {DATA,FN}, FEAREG, 0xF000, 0x4000 },        /* 409 = fmove */
{ xu, {FN,FN}, FREGREG, 0xF000, 0x0000 },
{ bwlsdxp, {FN,DATALT}, FMOVE, 0xF000, 0x6000 },
{ P, {FN,DATALT,DYNK}, FMOVE, 0xF000, 0x7C00 },
{ P, {FN,DATALT,STATK}, FMOVE, 0xF000, 0x6C00 },
{ lu, {ANYEA,FCN}, FMOVEMCI, 0xF000, 0x8000 },
{ lu, {FCN,ALTER}, FMOVEMCO, 0xF000, 0xA000 },
{ xu, {IMMED,FN}, FMOVECR, 0xF000, 0x5C00 },        /* 416 = fmovecr */
{ X, {FLIST,CALTPR}, FMOVEMO, 0xF000, 0xE000 },        /* 417 = fmovem */
{ X, {DN,CALTPR}, FMOVEMO, 0xF000, 0xE800 },
{ X, {CTLPST,FLIST}, FMOVEMI, 0xF000, 0xD000 },
{ X, {CTLPST,DN}, FMOVEMI, 0xF000, 0xD800 },
{ lu, {ANYEA,FCLIST}, FMOVEMCI, 0xF000, 0x8000 },
{ lu, {FCLIST,ALTER}, FMOVEMCO, 0xF000, 0xA000 },
{ bwlsdxp, {DATA,FN}, FEAREG, 0xF000, 0x4023 },        /* 423 = fmul */
{ xu, {FN,FN}, FREGREG, 0xF000, 0x0023 },
{ xu, {FN}, FMONAD, 0xF000, 0x001A },        /* 425 = fneg */
{ bwlsdxp, {DATA,FN}, FEAREG, 0xF000, 0x401A },
{ xu, {FN,FN}, FREGREG, 0xF000, 0x001A },
{ U, {EMPTY}, FINH, 0xF080, 0x0000 },        /* 428 = fnop */
{ bwlsdxp, {DATA,FN}, FEAREG, 0xF000, 0x4025 },        /* 429 = frem */
{ xu, {FN,FN}, FREGREG, 0xF000, 0x0025 },
{ U, {CTLPST}, FEA, 0xF140, 0x0000 },        /* 431 = frestore */
{ U, {CALTPR}, FEA, 0xF100, 0x0000 },        /* 432 = fsave */
{ bwlsdxp, {DATA,FN}, FEAREG, 0xF000, 0x4026 },        /* 433 = fscale */
{ xu, {FN,FN}, FREGREG, 0xF000, 0x0026 },
{ bu, {DATALT}, FSCC, 0xF040, 0x0001 },        /* 435 = fseq */
{ bu, {DATALT}, FSCC, 0xF040, 0x0000 },        /* 436 = fsf */
{ bu, {DATALT}, FSCC, 0xF040, 0x0013 },        /* 437 = fsge */
{ bu, {DATALT}, FSCC, 0xF040, 0x0016 },        /* 438 = fsgl */
{ bu, {DATALT}, FSCC, 0xF040, 0x0017 },        /* 439 = fsgle */
{ bu, {DATALT}, FSCC, 0xF040, 0x0012 },        /* 440 = fsgt */
{ bu, {DATALT}, FSCC, 0xF040, 0x0015 },        /* 441 = fsle */
{ bu, {DATALT}, FSCC, 0xF040, 0x0014 },        /* 442 = fslt */
{ bu, {DATALT}, FSCC, 0xF040, 0x000E },        /* 443 = fsne */
{ bu, {DATALT}, FSCC, 0xF040, 0x001C },        /* 444 = fsnge */
{ bu, {DATALT}, FSCC, 0xF040, 0x0019 },        /* 445 = fsngl */
{ bu, {DATALT}, FSCC, 0xF040, 0x0018 },        /* 446 = fsngle */
{ bu, {DATALT}, FSCC, 0xF040, 0x001D },        /* 447 = fsngt */
{ bu, {DATALT}, FSCC, 0xF040, 0x001A },        /* 448 = fsnle */
{ bu, {DATALT}, FSCC, 0xF040, 0x001B },        /* 449 = fsnlt */
{ bu, {DATALT}, FSCC, 0xF040, 0x0003 },        /* 450 = fsoge */
{ bu, {DATALT}, FSCC, 0xF040, 0x0006 },        /* 451 = fsogl */
{ bu, {DATALT}, FSCC, 0xF040, 0x0002 },        /* 452 = fsogt */
{ bu, {DATALT}, FSCC, 0xF040, 0x0005 },        /* 453 = fsole */
{ bu, {DATALT}, FSCC, 0xF040, 0x0004 },        /* 454 = fsolt */
{ bu, {DATALT}, FSCC, 0xF040, 0x0007 },        /* 455 = fsor */
{ bu, {DATALT}, FSCC, 0xF040, 0x0011 },        /* 456 = fsseq */
{ bu, {DATALT}, FSCC, 0xF040, 0x0010 },        /* 457 = fssf */
{ bu, {DATALT}, FSCC, 0xF040, 0x001E },        /* 458 = fssne */
{ bu, {DATALT}, FSCC, 0xF040, 0x001F },        /* 459 = fsst */
{ bu, {DATALT}, FSCC, 0xF040, 0x000F },        /* 460 = fst */
{ bu, {DATALT}, FSCC, 0xF040, 0x0009 },        /* 461 = fsueq */
{ bu, {DATALT}, FSCC, 0xF040, 0x000B },        /* 462 = fsuge */
{ bu, {DATALT}, FSCC, 0xF040, 0x000A },        /* 463 = fsugt */
{ bu, {DATALT}, FSCC, 0xF040, 0x000D },        /* 464 = fsule */
{ bu, {DATALT}, FSCC, 0xF040, 0x000C },        /* 465 = fsult */
{ bu, {DATALT}, FSCC, 0xF040, 0x0008 },        /* 466 = fsun */
{ bwlsdxp, {DATA,FN}, FEAREG, 0xF000, 0x4024 },        /* 467 = fsgldiv */
{ xu, {FN,FN}, FREGREG, 0xF000, 0x0024 },
{ bwlsdxp, {DATA,FN}, FEAREG, 0xF000, 0x4027 },        /* 469 = fsglmul */
{ xu, {FN,FN}, FREGREG, 0xF000, 0x0027 },
{ xu, {FN}, FMONAD, 0xF000, 0x000E },        /* 471 = fsin */
{ bwlsdxp, {DATA,FN}, FEAREG, 0xF000, 0x400E },
{ xu, {FN,FN}, FREGREG, 0xF000, 0x000E },
{ bwlsdxp, {DATA,FPAIR}, FEAPAIR, 0xF000, 0x4030 },        /* 474 = fsincos */
{ X, {FN,FPAIR}, FREGPAIR, 0xF000, 0x0030 },
{ xu, {FN}, FMONAD, 0xF000, 0x0002 },        /* 476 = fsinh */
{ bwlsdxp, {DATA,FN}, FEAREG, 0xF000, 0x4002 },
{ xu, {FN,FN}, FREGREG, 0xF000, 0x0002 },
{ xu, {FN}, FMONAD, 0xF000, 0x0004 },        /* 479 = fsqrt */
{ bwlsdxp, {DATA,FN}, FEAREG, 0xF000, 0x4004 },
{ xu, {FN,FN}, FREGREG, 0xF000, 0x0004 },
{ bwlsdxp, {DATA,FN}, FEAREG, 0xF000, 0x4028 },        /* 482 = fsub */
{ xu, {FN,FN}, FREGREG, 0xF000, 0x0028 },
{ xu, {FN}, FMONAD, 0xF000, 0x000F },        /* 484 = ftan */
{ bwlsdxp, {DATA,FN}, FEAREG, 0xF000, 0x400F },
{ xu, {FN,FN}, FREGREG, 0xF000, 0x000F },
{ xu, {FN}, FMONAD, 0xF000, 0x0009 },        /* 487 = ftanh */
{ bwlsdxp, {DATA,FN}, FEAREG, 0xF000, 0x4009 },
{ xu, {FN,FN}, FREGREG, 0xF000, 0x0009 },
{ xu, {FN}, FMONAD, 0xF000, 0x0012 },        /* 490 = ftentox */
{ bwlsdxp, {DATA,FN}, FEAREG, 0xF000, 0x4012 },
{ xu, {FN,FN}, FREGREG, 0xF000, 0x0012 },
{ U, {EMPTY}, FINH, 0xF07C, 0x0001 },        /* 493 = ftrapeq */
{ wl, {IMMED}, FTRAPCC, 0xF078, 0x0001 },
{ U, {EMPTY}, FINH, 0xF07C, 0x0000 },        /* 495 = ftrapf */
{ wl, {IMMED}, FTRAPCC, 0xF078, 0x0000 },
{ U, {EMPTY}, FINH, 0xF07C, 0x0013 },        /* 497 = ftrapge */
{ wl, {IMMED}, FTRAPCC, 0xF078, 0x0013 },
{ U, {EMPTY}, FINH, 0xF07C, 0x0016 },        /* 499 = ftrapgl */
{ wl, {IMMED}, FTRAPCC, 0xF078, 0x0016 },
{ U, {EMPTY}, FINH, 0xF07C, 0x0017 },        /* 501 = ftrapgle */
{ wl, {IMMED}, FTRAPCC, 0xF078, 0x0017 },
{ U, {EMPTY}, FINH, 0xF07C, 0x0012 },        /* 503 = ftrapgt */
{ wl, {IMMED}, FTRAPCC, 0xF078, 0x0012 },
{ U, {EMPTY}, FINH, 0xF07C, 0x0015 },        /* 505 = ftraple */
{ wl, {IMMED}, FTRAPCC, 0xF078, 0x0015 },
{ U, {EMPTY}, FINH, 0xF07C, 0x0014 },        /* 507 = ftraplt */
{ wl, {IMMED}, FTRAPCC, 0xF078, 0x0014 },
{ U, {EMPTY}, FINH, 0xF07C, 0x000E },        /* 509 = ftrapne */
{ wl, {IMMED}, FTRAPCC, 0xF078, 0x000E },
{ U, {EMPTY}, FINH, 0xF07C, 0x001C },        /* 511 = ftrapnge */
{ wl, {IMMED}, FTRAPCC, 0xF078, 0x001C },
{ U, {EMPTY}, FINH, 0xF07C, 0x0019 },        /* 513 = ftrapngl */
{ wl, {IMMED}, FTRAPCC, 0xF078, 0x0019 },
{ U, {EMPTY}, FINH, 0xF07C, 0x0018 },        /* 515 = ftrapngle */
{ wl, {IMMED}, FTRAPCC, 0xF078, 0x0018 },
{ U, {EMPTY}, FINH, 0xF07C, 0x001D },        /* 517 = ftrapngt */
{ wl, {IMMED}, FTRAPCC, 0xF078, 0x001D },
{ U, {EMPTY}, FINH, 0xF07C, 0x001A },        /* 519 = ftrapnle */
{ wl, {IMMED}, FTRAPCC, 0xF078, 0x001A },
{ U, {EMPTY}, FINH, 0xF07C, 0x001B },        /* 521 = ftrapnlt */
{ wl, {IMMED}, FTRAPCC, 0xF078, 0x001B },
{ U, {EMPTY}, FINH, 0xF07C, 0x0003 },        /* 523 = ftrapoge */
{ wl, {IMMED}, FTRAPCC, 0xF078, 0x0003 },
{ U, {EMPTY}, FINH, 0xF07C, 0x0006 },        /* 525 = ftrapogl */
{ wl, {IMMED}, FTRAPCC, 0xF078, 0x0006 },
{ U, {EMPTY}, FINH, 0xF07C, 0x0002 },        /* 527 = ftrapogt */
{ wl, {IMMED}, FTRAPCC, 0xF078, 0x0002 },
{ U, {EMPTY}, FINH, 0xF07C, 0x0005 },        /* 529 = ftrapole */
{ wl, {IMMED}, FTRAPCC, 0xF078, 0x0005 },
{ U, {EMPTY}, FINH, 0xF07C, 0x0004 },        /* 531 = ftrapolt */
{ wl, {IMMED}, FTRAPCC, 0xF078, 0x0004 },
{ U, {EMPTY}, FINH, 0xF07C, 0x0007 },        /* 533 = ftrapor */
{ wl, {IMMED}, FTRAPCC, 0xF078, 0x0007 },
{ U, {EMPTY}, FINH, 0xF07C, 0x0011 },        /* 535 = ftrapseq */
{ wl, {IMMED}, FTRAPCC, 0xF078, 0x0011 },
{ U, {EMPTY}, FINH, 0xF07C, 0x0010 },        /* 537 = ftrapsf */
{ wl, {IMMED}, FTRAPCC, 0xF078, 0x0010 },
{ U, {EMPTY}, FINH, 0xF07C, 0x001E },        /* 539 = ftrapsne */
{ wl, {IMMED}, FTRAPCC, 0xF078, 0x001E },
{ U, {EMPTY}, FINH, 0xF07C, 0x001F },        /* 541 = ftrapst */
{ wl, {IMMED}, FTRAPCC, 0xF078, 0x001F },
{ U, {EMPTY}, FINH, 0xF07C, 0x000F },        /* 543 = ftrapt */
{ wl, {IMMED}, FTRAPCC, 0xF078, 0x000F },
{ U, {EMPTY}, FINH, 0xF07C, 0x0009 },        /* 545 = ftrapueq */
{ wl, {IMMED}, FTRAPCC, 0xF078, 0x0009 },
{ U, {EMPTY}, FINH, 0xF07C, 0x000B },        /* 547 = ftrapuge */
{ wl, {IMMED}, FTRAPCC, 0xF078, 0x000B },
{ U, {EMPTY}, FINH, 0xF07C, 0x000A },        /* 549 = ftrapugt */
{ wl, {IMMED}, FTRAPCC, 0xF078, 0x000A },
{ U, {EMPTY}, FINH, 0xF07C, 0x000D },        /* 551 = ftrapule */
{ wl, {IMMED}, FTRAPCC, 0xF078, 0x000D },
{ U, {EMPTY}, FINH, 0xF07C, 0x000C },        /* 553 = ftrapult */
{ wl, {IMMED}, FTRAPCC, 0xF078, 0x000C },
{ U, {EMPTY}, FINH, 0xF07C, 0x0008 },        /* 555 = ftrapun */
{ wl, {IMMED}, FTRAPCC, 0xF078, 0x0008 },
{ bwlsdxp, {DATA}, FTSTEA, 0xF000, 0x403A },        /* 557 = ftest */
{ X, {FN}, FTSTREG, 0xF000, 0x003A },
{ xu, {FN}, FMONAD, 0xF000, 0x0011 },        /* 559 = ftwotox */
{ bwlsdxp, {DATA,FN}, FEAREG, 0xF000, 0x4011 },
{ xu, {FN,FN}, FREGREG, 0xF000, 0x0011 },
{ U, {EXPR}, FEQU, 0x0, 0x0 },        /* 562 = fequ */
{ U, {EMPTY}, FOPT, 0x0, 0x0 },        /* 563 = fopt */
{ wlu, {EXPR}, PBCC, 0xF080, 0x0 },        /* 564 = pbbs */
{ wlu, {EXPR}, PBCC, 0xF082, 0x0 },        /* 565 = pbls */
{ wlu, {EXPR}, PBCC, 0xF084, 0x0 },        /* 566 = pbss */
{ wlu, {EXPR}, PBCC, 0xF086, 0x0 },        /* 567 = pbas */
{ wlu, {EXPR}, PBCC, 0xF088, 0x0 },        /* 568 = pbws */
{ wlu, {EXPR}, PBCC, 0xF08A, 0x0 },        /* 569 = pbis */
{ wlu, {EXPR}, PBCC, 0xF08C, 0x0 },        /* 570 = pbgs */
{ wlu, {EXPR}, PBCC, 0xF08E, 0x0 },        /* 571 = pbcs */
{ wlu, {EXPR}, PBCC, 0xF081, 0x0 },        /* 572 = pbbc */
{ wlu, {EXPR}, PBCC, 0xF083, 0x0 },        /* 573 = pblc */
{ wlu, {EXPR}, PBCC, 0xF085, 0x0 },        /* 574 = pbsc */
{ wlu, {EXPR}, PBCC, 0xF087, 0x0 },        /* 575 = pbac */
{ wlu, {EXPR}, PBCC, 0xF089, 0x0 },        /* 576 = pbwc */
{ wlu, {EXPR}, PBCC, 0xF08B, 0x0 },        /* 577 = pbic */
{ wlu, {EXPR}, PBCC, 0xF08D, 0x0 },        /* 578 = pbgc */
{ wlu, {EXPR}, PBCC, 0xF08F, 0x0 },        /* 579 = pbcc */
{ wu, {DN,EXPR}, PDBCC, 0xF048, 0x0000 },        /* 580 = pdbbs */
{ wu, {DN,EXPR}, PDBCC, 0xF048, 0x0002 },        /* 581 = pdbls */
{ wu, {DN,EXPR}, PDBCC, 0xF048, 0x0004 },        /* 582 = pdbss */
{ wu, {DN,EXPR}, PDBCC, 0xF048, 0x0006 },        /* 583 = pdbas */
{ wu, {DN,EXPR}, PDBCC, 0xF048, 0x0008 },        /* 584 = pdbws */
{ wu, {DN,EXPR}, PDBCC, 0xF048, 0x000A },        /* 585 = pdbis */
{ wu, {DN,EXPR}, PDBCC, 0xF048, 0x000C },        /* 586 = pdbgs */
{ wu, {DN,EXPR}, PDBCC, 0xF048, 0x000E },        /* 587 = pdbcs */
{ wu, {DN,EXPR}, PDBCC, 0xF048, 0x0001 },        /* 588 = pdbbc */
{ wu, {DN,EXPR}, PDBCC, 0xF048, 0x0003 },        /* 589 = pdblc */
{ wu, {DN,EXPR}, PDBCC, 0xF048, 0x0005 },        /* 590 = pdbsc */
{ wu, {DN,EXPR}, PDBCC, 0xF048, 0x0007 },        /* 591 = pdbac */
{ wu, {DN,EXPR}, PDBCC, 0xF048, 0x0009 },        /* 592 = pdbwc */
{ wu, {DN,EXPR}, PDBCC, 0xF048, 0x000B },        /* 593 = pdbic */
{ wu, {DN,EXPR}, PDBCC, 0xF048, 0x000D },        /* 594 = pdbgc */
{ wu, {DN,EXPR}, PDBCC, 0xF048, 0x000F },        /* 595 = pdbcc */
{ U, {EMPTY}, PINH, 0xF000, 0x2400 },        /* 596 = pflusha */
{ U, {PEA1,STATK}, PFLUSH, 0xF000, 0x3000 },        /* 597 = pflush */
{ U, {PEA1,STATK,CTLALT}, PFLUSH, 0xF000, 0x3800 },
{ U, {PEA1,EXPR}, PFLUSH, 0xF000, 0x3400 },        /* 599 = pflushg */
{ U, {PEA1,EXPR,CTLALT}, PFLUSH, 0xF000, 0x3C00 },
{ U, {MEMORY}, PSCC, 0xF000, 0xA000 },        /* 601 = pflushr */
{ U, {PEA1,CTLALT}, PLOAD, 0xF000, 0x2200 },        /* 602 = ploadr */
{ U, {PEA1,CTLALT}, PLOAD, 0xF000, 0x2000 },        /* 603 = ploadw */
{ bwlu, {ANYEA,PN}, PMOVEI, 0xF000, 0x0000 },        /* 604 = pmove */
{ bwlu, {PN,ALTER}, PMOVEO, 0xF000, 0x0200 },
{ wlu, {ANYEA,PN}, PMOVEIF, 0xF000, 0x0100 },        /* 606 = pmovefd */
{ U, {CTLPST}, PEA, 0xF140, 0x0 },        /* 607 = prestore */
{ U, {CALTPR}, PEA, 0xF100, 0x0 },        /* 608 = psave */
{ bu, {DATALT}, PSCC, 0xF040, 0x0000 },        /* 609 = psbs */
{ bu, {DATALT}, PSCC, 0xF040, 0x0002 },        /* 610 = psls */
{ bu, {DATALT}, PSCC, 0xF040, 0x0004 },        /* 611 = psss */
{ bu, {DATALT}, PSCC, 0xF040, 0x0006 },        /* 612 = psas */
{ bu, {DATALT}, PSCC, 0xF040, 0x0008 },        /* 613 = psws */
{ bu, {DATALT}, PSCC, 0xF040, 0x000A },        /* 614 = psis */
{ bu, {DATALT}, PSCC, 0xF040, 0x000C },        /* 615 = psgs */
{ bu, {DATALT}, PSCC, 0xF040, 0x000E },        /* 616 = pscs */
{ bu, {DATALT}, PSCC, 0xF040, 0x0001 },        /* 617 = psbc */
{ bu, {DATALT}, PSCC, 0xF040, 0x0003 },        /* 618 = pslc */
{ bu, {DATALT}, PSCC, 0xF040, 0x0005 },        /* 619 = pssc */
{ bu, {DATALT}, PSCC, 0xF040, 0x0007 },        /* 620 = psac */
{ bu, {DATALT}, PSCC, 0xF040, 0x0009 },        /* 621 = pswc */
{ bu, {DATALT}, PSCC, 0xF040, 0x000B },        /* 622 = psic */
{ bu, {DATALT}, PSCC, 0xF040, 0x000D },        /* 623 = psgc */
{ bu, {DATALT}, PSCC, 0xF040, 0x000F },        /* 624 = pscc */
{ U, {PEA1,CTLALT,EXPR}, PTEST, 0xF000, 0x8200 },        /* 625 = ptestr */
{ U, {PEA1,CTLALT,EXPR,AN}, PTEST, 0xF000, 0x8200 },
{ U, {PEA1,CTLALT,EXPR}, PTEST, 0xF000, 0x8000 },        /* 627 = ptestw */
{ U, {PEA1,CTLALT,EXPR,AN}, PTEST, 0xF000, 0x8000 },
{ U, {EMPTY}, PINH, 0xF07C, 0x0000 },        /* 629 = ptrapbs */
{ wl, {IMMED}, PTRAPCC, 0xF078, 0x0000 },
{ U, {EMPTY}, PINH, 0xF07C, 0x0002 },        /* 631 = ptrapls */
{ wl, {IMMED}, PTRAPCC, 0xF078, 0x0002 },
{ U, {EMPTY}, PINH, 0xF07C, 0x0004 },        /* 633 = ptrapss */
{ wl, {IMMED}, PTRAPCC, 0xF078, 0x0004 },
{ U, {EMPTY}, PINH, 0xF07C, 0x0006 },        /* 635 = ptrapas */
{ wl, {IMMED}, PTRAPCC, 0xF078, 0x0006 },
{ U, {EMPTY}, PINH, 0xF07C, 0x0008 },        /* 637 = ptrapws */
{ wl, {IMMED}, PTRAPCC, 0xF078, 0x0008 },
{ U, {EMPTY}, PINH, 0xF07C, 0x000A },        /* 639 = ptrapis */
{ wl, {IMMED}, PTRAPCC, 0xF078, 0x000A },
{ U, {EMPTY}, PINH, 0xF07C, 0x000C },        /* 641 = ptrapgs */
{ wl, {IMMED}, PTRAPCC, 0xF078, 0x000C },
{ U, {EMPTY}, PINH, 0xF07C, 0x000E },        /* 643 = ptrapcs */
{ wl, {IMMED}, PTRAPCC, 0xF078, 0x000E },
{ U, {EMPTY}, PINH, 0xF07C, 0x0001 },        /* 645 = ptrapbc */
{ wl, {IMMED}, PTRAPCC, 0xF078, 0x0001 },
{ U, {EMPTY}, PINH, 0xF07C, 0x0003 },        /* 647 = ptraplc */
{ wl, {IMMED}, PTRAPCC, 0xF078, 0x0003 },
{ U, {EMPTY}, PINH, 0xF07C, 0x0005 },        /* 649 = ptrapsc */
{ wl, {IMMED}, PTRAPCC, 0xF078, 0x0005 },
{ U, {EMPTY}, PINH, 0xF07C, 0x0007 },        /* 651 = ptrapac */
{ wl, {IMMED}, PTRAPCC, 0xF078, 0x0007 },
{ U, {EMPTY}, PINH, 0xF07C, 0x0009 },        /* 653 = ptrapwc */
{ wl, {IMMED}, PTRAPCC, 0xF078, 0x0009 },
{ U, {EMPTY}, PINH, 0xF07C, 0x000B },        /* 655 = ptrapic */
{ wl, {IMMED}, PTRAPCC, 0xF078, 0x000B },
{ U, {EMPTY}, PINH, 0xF07C, 0x000D },        /* 657 = ptrapgc */
{ wl, {IMMED}, PTRAPCC, 0xF078, 0x000D },
{ U, {EMPTY}, PINH, 0xF07C, 0x000F },        /* 659 = ptrapcc */
{ wl, {IMMED}, PTRAPCC, 0xF078, 0x000F },
{ lu, {PN,CTLALT}, PVALID, 0xF000, 0x2400 },        /* 661 = pvalid */
{ lu, {AN,CTLALT}, PVALID, 0xF000, 0x2C00 },
{ bwlu, {EXPR,EXPR,EXPR}, CPBCC, 0xF080, 0x0 },        /* 663 = cpbcc */
{ wu, {EXPR,DN,EXPR}, CPDBCC, 0xF048, 0x0 },        /* 664 = cpdbcc */
{ U, {EXPR,EXPR,ANYEA}, CPGEN, 0xF000, 0x0 },        /* 665 = cpgen */
{ U, {EXPR,CTLPST}, CPEA, 0xF140, 0x0 },        /* 666 = cprestore */
{ U, {EXPR,CALTPR}, CPEA, 0xF100, 0x0 },        /* 667 = cpsave */
{ bu, {EXPR,EXPR,DATALT}, CPSCC, 0xF040, 0x0 },        /* 668 = cpscc */
{ U, {EXPR,EXPR}, CPINH, 0xF07C, 0x0 },        /* 669 = cptrapcc */
{ wl, {EXPR,EXPR,IMMED}, CPTRAPCC, 0xF078, 0x0 },
{ U, {EXPR}, EQU, 0x0, 0x0 },        /* 671 = equ */
{ bwlu, {MULTI}, DC, 0x0, 0x0 },        /* 672 = dc */
{ bwlu, {EXPR,EXPR}, DCB, 0x0, 0x0 },        /* 673 = dcb */
{ U, {EMPTY}, OPT, 0x0, 0x0 },        /* 674 = opt */
{ U, {EXPR}, RORG, 0x0, 0x0 },        /* 675 = rorg */
{ U, {EXPR}, ORG, 0x0, 0x0 },        /* 676 = org */
{ anysz, {EXPR}, DS, 0x0, 0x0 },        /* 677 = ds */
{ U, {EXPR}, ALIGN, 0x0, 0x0 },        /* 678 = align */
{ U, {EMPTY}, INCLUDE, 0x0, 0x0 },        /* 679 = include */
{ U, {NAMES}, XREF, 0x0, 0x0 },        /* 680 = xref */
{ U, {EMPTY}, NULL_OP, 0x0, 0x0 },        /* 681 = xdef */
{ U, {EMPTY}, NULL_OP, 0x0, 0x0 },        /* 682 = end */
{ U, {EMPTY}, NULL_OP, 0x0, 0x0 },        /* 683 = nam */
{ U, {EMPTY}, NULL_OP, 0x0, 0x0 },        /* 684 = name */
{ U, {EMPTY}, NULL_OP, 0x0, 0x0 },        /* 685 = pag */
{ U, {EMPTY}, NULL_OP, 0x0, 0x0 },        /* 686 = page */
{ U, {EMPTY}, NULL_OP, 0x0, 0x0 },        /* 687 = spc */
{ U, {EMPTY}, NULL_OP, 0x0, 0x0 },        /* 688 = ttl */
{ U, {EMPTY}, IDNT, 0x0, 0x0 },        /* 689 = idnt */
{ U, {EMPTY}, NULL_OP, 0x0, 0x0 },        /* 690 = section */
{ U, {EMPTY}, NULL_OP, 0x0, 0x0 },        /* 691 = plen */
{ U, {EMPTY}, NULL_OP, 0x0, 0x0 },        /* 692 = llen */
};

/*  438 mnemonics, 693 templates  */

struct mne mnemonic[] = {
"abcd", 2, &template[0],
"add", 6, &template[2],
"adda", 2, &template[8],
"addi", 1, &template[10],
"addq", 1, &template[11],
"addx", 2, &template[12],
"align", 1, &template[678],
"and", 5, &template[14],
"andi", 3, &template[19],
"asl", 3, &template[22],
"asr", 3, &template[25],
"bcc", 1, &template[28],
"bchg", 4, &template[44],
"bclr", 4, &template[48],
"bcs", 1, &template[29],
"beq", 1, &template[30],
"bfchg", 1, &template[60],
"bfclr", 1, &template[61],
"bfexts", 2, &template[62],
"bfextu", 2, &template[64],
"bfffo", 2, &template[66],
"bfins", 1, &template[68],
"bfset", 1, &template[69],
"bftst", 2, &template[70],
"bge", 1, &template[31],
"bgt", 1, &template[32],
"bhi", 1, &template[33],
"bkpt", 1, &template[72],
"ble", 1, &template[34],
"bls", 1, &template[35],
"blt", 1, &template[36],
"bmi", 1, &template[37],
"bne", 1, &template[38],
"bpl", 1, &template[39],
"bra", 1, &template[42],
"bset", 4, &template[52],
"bsr", 1, &template[43],
"btst", 4, &template[56],
"bvc", 1, &template[40],
"bvs", 1, &template[41],
"callm", 1, &template[73],
"cas", 1, &template[74],
"cas2", 1, &template[75],
"chk", 1, &template[76],
"chk2", 1, &template[77],
"clr", 1, &template[78],
"cmp", 6, &template[79],
"cmp2", 1, &template[89],
"cmpa", 2, &template[85],
"cmpi", 1, &template[87],
"cmpm", 1, &template[88],
"cpbcc", 1, &template[663],
"cpdbcc", 1, &template[664],
"cpgen", 1, &template[665],
"cprestore", 1, &template[666],
"cpsave", 1, &template[667],
"cpscc", 1, &template[668],
"cptrapcc", 2, &template[669],
"dbcc", 1, &template[90],
"dbcs", 1, &template[91],
"dbeq", 1, &template[92],
"dbf", 1, &template[93],
"dbge", 1, &template[94],
"dbgt", 1, &template[95],
"dbhi", 1, &template[96],
"dble", 1, &template[97],
"dbls", 1, &template[98],
"dblt", 1, &template[99],
"dbmi", 1, &template[100],
"dbne", 1, &template[101],
"dbpl", 1, &template[102],
"dbra", 1, &template[106],
"dbt", 1, &template[103],
"dbvc", 1, &template[104],
"dbvs", 1, &template[105],
"dc", 1, &template[672],
"dcb", 1, &template[673],
"divs", 3, &template[107],
"divsl", 1, &template[110],
"divu", 3, &template[111],
"divul", 1, &template[114],
"ds", 1, &template[677],
"end", 1, &template[682],
"eor", 4, &template[115],
"eori", 3, &template[119],
"equ", 1, &template[671],
"exg", 4, &template[122],
"ext", 2, &template[126],
"extb", 1, &template[128],
"fabs", 3, &template[284],
"facos", 3, &template[287],
"fadd", 2, &template[290],
"fasin", 3, &template[292],
"fatan", 3, &template[295],
"fatanh", 3, &template[298],
"fbeq", 1, &template[301],
"fbf", 1, &template[302],
"fbge", 1, &template[303],
"fbgl", 1, &template[304],
"fbgle", 1, &template[305],
"fbgt", 1, &template[306],
"fble", 1, &template[307],
"fblt", 1, &template[308],
"fbne", 1, &template[309],
"fbnge", 1, &template[310],
"fbngl", 1, &template[311],
"fbngle", 1, &template[312],
"fbngt", 1, &template[313],
"fbnle", 1, &template[314],
"fbnlt", 1, &template[315],
"fboge", 1, &template[316],
"fbogl", 1, &template[317],
"fbogt", 1, &template[318],
"fbole", 1, &template[319],
"fbolt", 1, &template[320],
"fbor", 1, &template[321],
"fbra", 1, &template[322],
"fbseq", 1, &template[323],
"fbsf", 1, &template[324],
"fbsne", 1, &template[325],
"fbst", 1, &template[326],
"fbt", 1, &template[327],
"fbueq", 1, &template[328],
"fbuge", 1, &template[329],
"fbugt", 1, &template[330],
"fbule", 1, &template[331],
"fbult", 1, &template[332],
"fbun", 1, &template[333],
"fcmp", 2, &template[334],
"fcos", 3, &template[336],
"fcosh", 3, &template[339],
"fdbeq", 1, &template[342],
"fdbf", 1, &template[343],
"fdbge", 1, &template[344],
"fdbgl", 1, &template[345],
"fdbgle", 1, &template[346],
"fdbgt", 1, &template[347],
"fdble", 1, &template[348],
"fdblt", 1, &template[349],
"fdbne", 1, &template[350],
"fdbnge", 1, &template[351],
"fdbngl", 1, &template[352],
"fdbngle", 1, &template[353],
"fdbngt", 1, &template[354],
"fdbnle", 1, &template[355],
"fdbnlt", 1, &template[356],
"fdboge", 1, &template[357],
"fdbogl", 1, &template[358],
"fdbogt", 1, &template[359],
"fdbole", 1, &template[360],
"fdbolt", 1, &template[361],
"fdbor", 1, &template[362],
"fdbra", 1, &template[363],
"fdbseq", 1, &template[364],
"fdbsf", 1, &template[365],
"fdbsne", 1, &template[366],
"fdbst", 1, &template[367],
"fdbt", 1, &template[368],
"fdbueq", 1, &template[369],
"fdbuge", 1, &template[370],
"fdbugt", 1, &template[371],
"fdbule", 1, &template[372],
"fdbult", 1, &template[373],
"fdbun", 1, &template[374],
"fdiv", 2, &template[375],
"fequ", 1, &template[562],
"fetox", 3, &template[377],
"fetoxm1", 3, &template[380],
"fgetexp", 3, &template[383],
"fgetman", 3, &template[386],
"fint", 3, &template[389],
"fintrz", 3, &template[392],
"flog10", 3, &template[395],
"flog2", 3, &template[398],
"flogn", 3, &template[401],
"flognp1", 3, &template[404],
"fmod", 2, &template[407],
"fmove", 7, &template[409],
"fmovecr", 1, &template[416],
"fmovem", 6, &template[417],
"fmul", 2, &template[423],
"fneg", 3, &template[425],
"fnop", 1, &template[428],
"fopt", 1, &template[563],
"frem", 2, &template[429],
"frestore", 1, &template[431],
"fsave", 1, &template[432],
"fscale", 2, &template[433],
"fseq", 1, &template[435],
"fsf", 1, &template[436],
"fsge", 1, &template[437],
"fsgl", 1, &template[438],
"fsgldiv", 2, &template[467],
"fsgle", 1, &template[439],
"fsglmul", 2, &template[469],
"fsgt", 1, &template[440],
"fsin", 3, &template[471],
"fsincos", 2, &template[474],
"fsinh", 3, &template[476],
"fsle", 1, &template[441],
"fslt", 1, &template[442],
"fsne", 1, &template[443],
"fsnge", 1, &template[444],
"fsngl", 1, &template[445],
"fsngle", 1, &template[446],
"fsngt", 1, &template[447],
"fsnle", 1, &template[448],
"fsnlt", 1, &template[449],
"fsoge", 1, &template[450],
"fsogl", 1, &template[451],
"fsogt", 1, &template[452],
"fsole", 1, &template[453],
"fsolt", 1, &template[454],
"fsor", 1, &template[455],
"fsqrt", 3, &template[479],
"fsseq", 1, &template[456],
"fssf", 1, &template[457],
"fssne", 1, &template[458],
"fsst", 1, &template[459],
"fst", 1, &template[460],
"fsub", 2, &template[482],
"fsueq", 1, &template[461],
"fsuge", 1, &template[462],
"fsugt", 1, &template[463],
"fsule", 1, &template[464],
"fsult", 1, &template[465],
"fsun", 1, &template[466],
"ftan", 3, &template[484],
"ftanh", 3, &template[487],
"ftentox", 3, &template[490],
"ftest", 2, &template[557],
"ftrapeq", 2, &template[493],
"ftrapf", 2, &template[495],
"ftrapge", 2, &template[497],
"ftrapgl", 2, &template[499],
"ftrapgle", 2, &template[501],
"ftrapgt", 2, &template[503],
"ftraple", 2, &template[505],
"ftraplt", 2, &template[507],
"ftrapne", 2, &template[509],
"ftrapnge", 2, &template[511],
"ftrapngl", 2, &template[513],
"ftrapngle", 2, &template[515],
"ftrapngt", 2, &template[517],
"ftrapnle", 2, &template[519],
"ftrapnlt", 2, &template[521],
"ftrapoge", 2, &template[523],
"ftrapogl", 2, &template[525],
"ftrapogt", 2, &template[527],
"ftrapole", 2, &template[529],
"ftrapolt", 2, &template[531],
"ftrapor", 2, &template[533],
"ftrapseq", 2, &template[535],
"ftrapsf", 2, &template[537],
"ftrapsne", 2, &template[539],
"ftrapst", 2, &template[541],
"ftrapt", 2, &template[543],
"ftrapueq", 2, &template[545],
"ftrapuge", 2, &template[547],
"ftrapugt", 2, &template[549],
"ftrapule", 2, &template[551],
"ftrapult", 2, &template[553],
"ftrapun", 2, &template[555],
"ftwotox", 3, &template[559],
"idnt", 1, &template[689],
"illegal", 1, &template[129],
"include", 1, &template[679],
"jmp", 1, &template[130],
"jsr", 1, &template[131],
"lea", 1, &template[132],
"link", 2, &template[133],
"llen", 1, &template[692],
"lsl", 3, &template[135],
"lsr", 3, &template[138],
"move", 11, &template[141],
"movea", 2, &template[152],
"movec", 2, &template[154],
"movem", 8, &template[156],
"movep", 4, &template[164],
"moveq", 1, &template[168],
"moves", 2, &template[169],
"muls", 3, &template[171],
"mulu", 3, &template[174],
"nam", 1, &template[683],
"name", 1, &template[684],
"nbcd", 1, &template[177],
"neg", 1, &template[178],
"negx", 1, &template[179],
"nop", 1, &template[180],
"not", 1, &template[181],
"opt", 1, &template[674],
"or", 5, &template[182],
"org", 1, &template[676],
"ori", 3, &template[187],
"pack", 2, &template[190],
"pag", 1, &template[685],
"page", 1, &template[686],
"pbac", 1, &template[575],
"pbas", 1, &template[567],
"pbbc", 1, &template[572],
"pbbs", 1, &template[564],
"pbcc", 1, &template[579],
"pbcs", 1, &template[571],
"pbgc", 1, &template[578],
"pbgs", 1, &template[570],
"pbic", 1, &template[577],
"pbis", 1, &template[569],
"pblc", 1, &template[573],
"pbls", 1, &template[565],
"pbsc", 1, &template[574],
"pbss", 1, &template[566],
"pbwc", 1, &template[576],
"pbws", 1, &template[568],
"pdbac", 1, &template[591],
"pdbas", 1, &template[583],
"pdbbc", 1, &template[588],
"pdbbs", 1, &template[580],
"pdbcc", 1, &template[595],
"pdbcs", 1, &template[587],
"pdbgc", 1, &template[594],
"pdbgs", 1, &template[586],
"pdbic", 1, &template[593],
"pdbis", 1, &template[585],
"pdblc", 1, &template[589],
"pdbls", 1, &template[581],
"pdbsc", 1, &template[590],
"pdbss", 1, &template[582],
"pdbwc", 1, &template[592],
"pdbws", 1, &template[584],
"pea", 1, &template[192],
"pflush", 2, &template[597],
"pflusha", 1, &template[596],
"pflushg", 2, &template[599],
"pflushr", 1, &template[601],
"plen", 1, &template[691],
"ploadr", 1, &template[602],
"ploadw", 1, &template[603],
"pmove", 2, &template[604],
"pmovefd", 1, &template[606],
"prestore", 1, &template[607],
"psac", 1, &template[620],
"psas", 1, &template[612],
"psave", 1, &template[608],
"psbc", 1, &template[617],
"psbs", 1, &template[609],
"pscc", 1, &template[624],
"pscs", 1, &template[616],
"psgc", 1, &template[623],
"psgs", 1, &template[615],
"psic", 1, &template[622],
"psis", 1, &template[614],
"pslc", 1, &template[618],
"psls", 1, &template[610],
"pssc", 1, &template[619],
"psss", 1, &template[611],
"pswc", 1, &template[621],
"psws", 1, &template[613],
"ptestr", 2, &template[625],
"ptestw", 2, &template[627],
"ptrapac", 2, &template[651],
"ptrapas", 2, &template[635],
"ptrapbc", 2, &template[645],
"ptrapbs", 2, &template[629],
"ptrapcc", 2, &template[659],
"ptrapcs", 2, &template[643],
"ptrapgc", 2, &template[657],
"ptrapgs", 2, &template[641],
"ptrapic", 2, &template[655],
"ptrapis", 2, &template[639],
"ptraplc", 2, &template[647],
"ptrapls", 2, &template[631],
"ptrapsc", 2, &template[649],
"ptrapss", 2, &template[633],
"ptrapwc", 2, &template[653],
"ptrapws", 2, &template[637],
"pvalid", 2, &template[661],
"reset", 1, &template[193],
"rol", 3, &template[194],
"ror", 3, &template[197],
"rorg", 1, &template[675],
"roxl", 3, &template[200],
"roxr", 3, &template[203],
"rtd", 1, &template[206],
"rte", 1, &template[207],
"rtm", 2, &template[208],
"rtr", 1, &template[210],
"rts", 1, &template[211],
"sbcd", 2, &template[212],
"scc", 1, &template[214],
"scs", 1, &template[215],
"section", 1, &template[690],
"seq", 1, &template[216],
"sf", 1, &template[217],
"sge", 1, &template[218],
"sgt", 1, &template[219],
"shi", 1, &template[220],
"sle", 1, &template[221],
"sls", 1, &template[222],
"slt", 1, &template[223],
"smi", 1, &template[224],
"sne", 1, &template[225],
"spc", 1, &template[687],
"spl", 1, &template[226],
"st", 1, &template[227],
"stop", 1, &template[230],
"sub", 6, &template[231],
"suba", 2, &template[237],
"subi", 1, &template[239],
"subq", 1, &template[240],
"subx", 2, &template[241],
"svc", 1, &template[228],
"svs", 1, &template[229],
"swap", 1, &template[243],
"tas", 1, &template[244],
"trap", 1, &template[245],
"trapcc", 2, &template[246],
"trapcs", 2, &template[248],
"trapeq", 2, &template[250],
"trapf", 2, &template[252],
"trapge", 2, &template[254],
"trapgt", 2, &template[256],
"traphi", 2, &template[258],
"traple", 2, &template[260],
"trapls", 2, &template[262],
"traplt", 2, &template[264],
"trapmi", 2, &template[266],
"trapne", 2, &template[268],
"trappl", 2, &template[270],
"trapt", 2, &template[272],
"trapv", 1, &template[278],
"trapvc", 2, &template[274],
"trapvs", 2, &template[276],
"tst", 2, &template[279],
"ttl", 1, &template[688],
"unlk", 1, &template[281],
"unpk", 2, &template[282],
"xdef", 1, &template[681],
"xref", 1, &template[680],
{0}
};
int Nmne = (sizeof(mnemonic)/sizeof(mnemonic[0]))-1;
