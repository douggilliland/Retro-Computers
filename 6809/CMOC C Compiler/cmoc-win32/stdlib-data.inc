* stdlib-data.inc - Global variables used by stdlib.inc.
*
* By Pierre Sarrazin <http://sarrazip.com/>.
* This file is in the public domain.
*
* Each variable must be defined only with an RMB directive.
* It must be initialized by INILIB in stdlib.inc.

INISTK	RMB	2		receives initial stack pointer

end_of_sbrk_mem	RMB	2
program_break	RMB	2

#if defined(_CMOC_NEED_rand_) || defined(_CMOC_NEED_srand_)
SEED	RMB	2
#endif

#ifdef _CMOC_NEED_sprintf_
chrtomem_writer	RMB	2	used by chrtomem, itself used by _sprintf
sprintf_retaddr	RMB	2	used by _sprintf
sprintf_oldCHROUT	RMB	2	used by _sprintf
#endif

#ifdef _CMOC_CHECK_NULL_POINTERS_

* Initialized by INILIB to an RTS routine.
* Call set_null_ptr_handler() to specify another handler.
* The handler is assumed to have this signature:
* void handler(char *addressOfFailedCheck);
*
null_ptr_handler	RMB	2

#endif  /* _CMOC_CHECK_NULL_POINTERS_ */

#ifdef _CMOC_CHECK_STACK_OVERFLOW_

* Initialized by INILIB to a null pointer.
* Call set_stack_overflow_handler() to specify another handler.
* The handler is assumed to have this signature:
* void handler(char *addressOfFailedCheck, char *stackRegister);
*
stack_overflow_handler	RMB	2

#endif  /* _CMOC_CHECK_STACK_OVERFLOW_ */

#if defined(_CMOC_NEED_putchar_) || defined(_CMOC_NEED_putstr_) || defined(_CMOC_NEED_sprintf_) || defined(_CMOC_NEED_printf_) || defined(_CMOC_NEED_setConsoleOutHook_)
CHROUT	RMB	2	CoCo Basic routine to write char to current device (at $6F)
#endif

#if defined(OS9) && (defined(_CMOC_NEED_readline_) || defined(_CMOC_NEED_readword_))
LINBUF	RMB	LBUFMX+1	buffer where readline() stores line read from user
#endif
