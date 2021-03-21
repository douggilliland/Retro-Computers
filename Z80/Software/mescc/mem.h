/**
 * @file   mem.h
 * @brief  Memory functions.
 * @author Miguel I. Garcia Lopez / FloppySoftware
 *
 * Memory functions, for MESCC (Mike's Enhanced
 * Small C Compiler for Z80 & CP/M).
 *
 * Revisions:
 *  - 25 Oct 2000 : Last revision.
 *  - 16 Apr 2007 : GPL'd.
 *  - 25 Aug 2016 : Documented. GPL v3.
 *  - 25 Dec 2018 : Optimize memset() for speed.
 *
 * Copyright (c) 1999-2018 Miguel I. Garcia Lopez / FloppySoftware.
 *
 * Licensed under the GNU General Public License v3.
 *
 * http://www.floppysoftware.es
 * floppysoftware@gmail.com
 */
#ifndef MEM_H

#define MEM_H

/**
 * @fn     char *memset(char *dst, char data, int count)
 * @brief  Fill 'count' bytes with 'data' into 'dst'.
 * @param  dst - destination
 * @param  data - fill byte
 * @param  count - how many
 * @return pointer to 'dst'
 */
#asm

memset:
    POP  AF
    POP  BC
    POP  DE
    POP  HL
    PUSH HL
    PUSH DE
    PUSH BC
    PUSH AF
	
    LD  A,B
    OR  C
    RET Z
	
    PUSH HL
	
    LD  (HL),E
    LD  D,H
    LD  E,L
    INC DE
    DEC BC
    LDIR

    POP HL
    RET
#endasm

/**
 * @fn     char *memcpy(char *dst, char *src, int count)
 * @brief  Copy 'count' bytes from 'src' to 'dst'.
 * @param  dst - destination
 * @param  src - source
 * @param  count - how many
 * @return pointer to 'dst'
 */
#asm

memcpy:
    POP  AF
    POP  BC
    POP  HL
    POP  DE
    PUSH DE
    PUSH HL
    PUSH BC
    PUSH AF
    PUSH DE
    LD A,B
    OR C
    JR Z,memcpy2
    LDIR
memcpy2
    POP HL
    RET
#endasm

/**
 * @fn     int memcmp(char *mem1, char *mem2, int count)
 * @brief  Compare 'count' bytes.
 * @param  mem1 - pointer
 * @param  mem2 - pointer
 * @param  count - how many
 * @return <0 on mem1 < mem2; =0 on mem1 == mem2; >0 on mem1 > mem2
 */
#asm

memcmp
    POP  AF
    POP  BC
    POP  HL
    POP  DE
    PUSH DE
    PUSH HL
    PUSH BC
    PUSH AF

memcmp1
    LD  A,C
    OR  B
    JR  Z,memcmp2

    DEC BC

    LD  A,(DE)
    CP  (HL)
    INC DE
    INC HL
    JR  Z,memcmp1

memcmp2
    LD  HL,0
    RET Z
    JR  NC,memcmp3
    DEC HL
    RET

memcmp3
    INC L
    RET
#endasm

#endif

