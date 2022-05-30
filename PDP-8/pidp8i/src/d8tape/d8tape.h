
/*
 *	d8tape.h
 *
 *	(C) Copyright 2007 by Robert Krten, all rights reserved.
 *	Please see the LICENSE file for more information.
 *
 *	This module contains the manifest constants and other header
 *	information.
 *
 *	2007 10 25	R. Krten		created
 *	2007 10 28	R. Krten		added TAG_INDIRECTFC
*/

// constants
#define	CORE_SIZE		4096				// size of core memory

#define	TAG_DATA		0x0001				// memory region is tagged as data,
#define	TAG_SUB			0x0002				// subroutine target, or,
#define	TAG_LABEL		0x0004				// label
#define	TAG_RETURN		0x0008				// return from subroutine
#define	TAG_TYPE_MASK	0x00ff				// mask of above types
#define	TAG_WRITABLE	0x0100				// set if anyone writes to this data location (else constant)
#define	TAG_KONSTANT	0x0200				// can be changed from Caaaa -> Kvvvv
#define	TAG_INDIRECTFC	0x0400				// target of an indirect flow control (JMS I / JMP I) (only meaningful if not writable)

#include <stdint.h>

// segment info

typedef struct
{
	uint16_t	saddr;						// starting address
	uint16_t	nwords;						// number of contiguous words
}	segment_t;


// prototypes

// flow.c
extern	void			flow (void);

// dasm.c
extern	int				ea (int addr, int opcode, int *indirect, int *curpage);
extern	void			disassemble (void);
extern	int				is_data (int v);
extern	int				fetch_iot (int code, char *dis, char *com);

