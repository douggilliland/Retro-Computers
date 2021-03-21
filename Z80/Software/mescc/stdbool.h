/**
 * @file   stdbool.h
 * @brief  Boolean type and values.
 * @author Miguel I. Garcia Lopez / FloppySoftware
 *
 * Boolean type and values for MESCC (Mike's Enhanced Small C Compiler
 * for Z80 & CP/M).
 *
 * Defined macros:
 *  - bool
 *  - true
 *  - false
 *
 * Revisions:
 *  - 13 May 2016 : 1st version.
 *
 * Notes:
 *  - In standard / ISO C, bool type is _Bool, not int.
 *  - ISO C defines bool_true_false_are_defined = 1.
 *
 * Copyright (c) 2016 Miguel I. Garcia Lopez / FloppySoftware.
 *
 * Licensed under the GNU General Public License v3.
 *
 * http://www.floppysoftware.es
 * floppysoftware@gmail.com
 */
#ifndef STDBOOL_H

#define STDBOOL_H

#define bool  int
#define true  1
#define false 0

#endif

