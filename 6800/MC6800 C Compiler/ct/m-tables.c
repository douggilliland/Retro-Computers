#include <stdio.h>
#include "tbdef.h"
#include "boolean.h"

#define INCREASE 4096 /* Increment size for memory increase */

static char *memend; /* End of memory */
static BOOLEAN preset; /* set TRUE when "tbprs" executed */

static move(from,to,count) /* Move data */

char from[], to[];
unsigned int count;

{
	if (from > to)
		while (count--)
			*to++ = *from++;
	else {
		from += count;
		to += count;
		while (count--)
			*--to = *--from; }
}

BOOLEAN tbadb(ta,tn,b,n) /* add bytes to a table */
/*	ta : table array address
	tn : table number
	b  : pointer to bytes to be added
	n  : number of bytes to be added */

struct table ta[];
int tn;
char *b;
int n;

{
	char *space;
 
	if (tbats(ta,tn,n,&space)) {
		while (n--) *space++ = *b++;
		return TRUE; }
	else return FALSE;
}

BOOLEAN tbats(ta,tn,al,sp) /* Allocate table space */
/*	ta : table array address
	tn : table number
	al : allocation size
	sp : pointer to allocated space */

struct table ta[];
int tn;
unsigned int al;
char (*sp)[];

{
	int last;
	unsigned int increment;

	if (preset == FALSE) {
		printf("Managed tables not initialized.\n");
		exit(255); }
	if (ta[tn].lwad+al <= ta[tn].lwas) {
		sp = ta[tn].lwad;
		ta[tn].lwad += al;
		return TRUE; }
	else {
		last = sizeof(ta)/sizeof(struct table) - 1;
		increment = (al>ta[tn].incr) ? al : ta[tn].incr ;
		if (ta[last].lwas+increment > memend) return FALSE;
		for (;last > tn; last--) tbmov(&ta[last],increment);
		ta[tn].lwas += increment;
		sp = ta[tn].lwad;
		ta[tn].lwad += al;
		return TRUE; }
}

static tbmov(ta,am)  /* Move managed table */
/*	ta : table information structure
	am : amount to move */

struct table *ta;
int am;

{
	move(ta.fwad,ta.fwad+am,ta.lwad-ta.fwad);
	ta.fwad += am;
	ta.lwad += am;
	ta.ptr1 += am;
	ta.ptr2 += am;
	ta.lwas += am;
	return;
}

tbprs(ta,st,en) /*  Initialize table structures  */
/*	ta : address of table array
	st : starting address of table space
	en : ending address of table space */

struct table ta[];
char *st;
char *en;

{
	int count;
	extern char *end;
	extern char *edata;

	if (st == 0) {
		st = &edata;
		en = &end; }
	else if (en < st) {
		printf("End of tables < start of tables.\n");
		exit(255); }
	memend = en;
	count = sizeof(ta)/sizeof(struct table);
	while (count--) {
		ta[count].fwad = st;
		ta[count].lwad = st;
		ta[count].ptr1 = st;
		ta[count].ptr2 = st;
		ta[count].lwas = st;
		ta[count].incr = 0; }
	preset = TRUE;
}

tbrdi(ta,tn,ia,is) /* Remove item from table */
/*	ta : table array address
	tn : table number
	ia : item address
	is : item size */

struct table ta[];
int tn;
char ia[];
int is;

{
	if (ia+is < ta[tn].lwad ) move(ia+is,ia,ta[tn].lwad-ia-is);
	ta[tn].lwad -= is;
	return;
}

BOOLEAN ats(ta,tn,al,sp)  /* Allocate space with memory increase */
/*	ta : table array address
	tn : table number
	al : allocation size
	sp : pointer to allocated space */

struct table ta[];
int tn;
unsigned int al;
char (*sp)[];

{
	if (tbats(ta,tn,al,sp)) return TRUE;
	else if (brk(memend+INCREASE)) {
		memend += INCREASE;
		return tbats(ta,tn,al,sp); }
	else return FALSE;
}

BOOLEAN adb(ta,tn,b,n) /* add bytes to a table with increase */
/*	ta : table array address
	tn : table number
	b  : pointer to bytes to be added
	n  : number of bytes to be added */

struct table ta[];
int tn;
char *b;
int n;

{
	char *space;
 
	if (ats(ta,tn,n,&space)) {
		while (n--) *space++ = *b++;
		return TRUE; }
	else return FALSE;
}
