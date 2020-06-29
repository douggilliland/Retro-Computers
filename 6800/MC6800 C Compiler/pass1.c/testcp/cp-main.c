/*
* This file contains all external symbol definitions, the basic i/o
* routines, and the main calling loop.
*/

#include "cp.h"
#include "il.h"

#define ERROR (-1)

/* global variable definitions */

int pp_if_result;
short curchar;
short curtok;
short tempch;
long convalu;
int *tos;
int astack[100];
char esctab[] = {'n','\n','t','\t','b','\b','r','\r','f','\f','\0'};

/* token arrays */

struct toktab dchtab[] = {
  '=', EQU,
  '+', FPP,
  '-', FMM,
  '&', LND,
  '|', LOR,
  '<', SHL,
  '>', SHR,
  '\0', 0 };

struct toktab eqctab[] = {
  '<', LEQ,
  '>', GEQ,
  '!', NEQ,
  '\0', 0 };

struct toktab chrtab[] = {
  ';', SMC,
  '{', LCB,
  '}', RCB,
  '[', LSB,
  ']', RSB,
  '(', LPR,
  ')', RPR,
  '+', ADD,
  '-', SUB,
  '*', MUL,
  '/', DIV,
  '%', MOD,
  '=', ASN,
  '>', GRT,
  '<', LES,
  '!', NOT,
  '\'', SQU,
  '"', DQU,
  ',', CMA,
  '.', DOT,
  '&', AND,
  '|', BOR,
  '^', XOR,
  '~', COM,
  '?', QUM,
  '\\', BKS,
  ':', COL,
  '\0', 0 };


