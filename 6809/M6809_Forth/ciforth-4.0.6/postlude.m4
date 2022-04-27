dnl $Id: postlude.m4,v 4.1.2.6 2005/02/14 11:19:17 albert Exp $
dnl Copyright(2000): Albert van der Horst, HCC FIG Holland by GNU Public License
include(header.m4)
dnl architectural consequences
dnl Look at this as a knowledge base:
dnl A(define(B),y) means if we have A, then we need B too.
dnl A({B({define(C),y})}) means if we have A and B then we need C too.
dnl A(define(C),y) combined with B(define(C),y) means
dnl if we have A or we have B, then we need C too.
dnl A(define(B),y) followed by C(define(B),n) means
dnl normally A requiries with an exception for C.

dnl Combinations
_BOOTSECTRK_({define({_BOOTED_}, _yes)})
_BOOTLBA_({define({_BOOTED_}, _yes)})
_LINUX_N_({ define( {_HOSTED_LINUX_}, _yes)})
_LINUX_C_({ define( {_HOSTED_LINUX_}, _yes)})
_HOSTED_DPMI_({define({_HOSTED_}, _yes)})
_HOSTED_LINUX_({define({_HOSTED_}, _yes)})
_HOSTED_MSDOS_({define({_HOSTED_}, _yes)})

dnl Hard consequences
_REAL_({define({_BITS16_}, _yes)})
_BOOTSECTRK_({define({_RWSECTRK_}, _yes)})
_BOOTLBA_({define({_RWLBA_}, _yes)})
_BOOTED_({define({_PC_}, _yes)})
_HOSTED_DPMI_({define({_PC_}, _yes)})
_HOSTED_MSDOS_({define({_PC_}, _yes)})
_HOSTED_LINUX_({ define( {_BITS32_}, _yes)})
_HOSTED_LINUX_({ define({_BLOCKSINFILE_}, _yes)})
_HOSTED_DPMI_({define({_PROTECTED_}, _yes)})
_BOOTED_({define({_USEBIOS_}, _yes)})
_USEBIOS_({define({_KEY_BY_KEY_}, _yes )})
_CLASSIC_({define({_KEY_BY_KEY_}, _yes )})
_BITS32_({define({_PROTECTED_}, _yes)})
;{The following consequences are hard because otherwise you wouldn't have blocks.}
define({_FILES_}, _no)
_MODERN_({define({_FILES_}, _yes)})
_LINUX_N_({define({_FILES_}, _yes)})
_LINUX_N_({define({M4_EM},M4_EM-0x74)})dnl

dnl Other consequences
_BITS32_({define({M4_RTS}, 0x10000)})
dnl _BITS32_({define({M4_NBUF}, 16 )}) NOT YET!
dnl _BITS32_({define({M4_MAXWORDLIST}, 16 )}) NOT YET!

dnl Consequences with exceptions
dnl switch back and forth between protected and real mode.
define({_NO_DPMI_}, _yes)
_HOSTED_DPMI_({define({_NO_DPMI_}, _no)})
_PC_({_PROTECTED_({define({_SWITCH_}, _yes)})})
_HOSTED_DPMI_({define({_SWITCH_}, _no)})
_PC_({define({_NORMAL_BIOS_}, _yes)})
_HOSTED_DPMI_({define({_NORMAL_BIOS_}, _no)})
_HOSTED_DPMI_({define({_SIMULATE_BIOS_}, _yes)})

_PC_({define({_DIRECTMAPPED_}, _yes)})
_SWITCH_({include(protect.m4)})
_SWITCH_({define({_LOW_BUF_}, _yes)})
_SWITCH_({define({_HIGH_BUF_}, _no)})
_SWITCH_({define({_ABSOLUTELOAD_}, _yes)})
dnl after the real memorya plus the high memory.
_SWITCH_({_BITS32_({define({M4_INITDP},{0x100000})})})
_HOSTED_LINUX_({define( {_EQULAYOUT_},  _no )})
_MODERN_({define({_RWFILE_}, _yes)})
_RWFILE_({ define({_BLOCKSINFILE_}, _yes)})

define({_BLOCKSBYFILEWS_}, _no)
_BLOCKSINFILE_({ define({_BLOCKSBYFILEWS_}, _yes)})
_LINUX_C_({ define({_BLOCKSBYFILEWS_}, _no)})

_PC_({define({_MSDOS_BYE_}, _yes)})
_ABSOLUTELOAD_({define({_CLEANUP_BYE_}, _yes)})
_HOSTED_DPMI_({define({_CLEANUP_BYE_}, _yes)})
_CLEANUP_BYE_({define({_MSDOS_BYE_}, _no)})

dnl Defines that directly regulate source inclusions, without depending defines.
define({_NO_RESPECTDOS_}, _yes) dnl default
_RESPECTDOS_({define({_NO_RESPECTDOS_}, _no)}) dnl exception
define({_NO_SECURITY_}, _yes) dnl default
_SECURITY_({define({_NO_SECURITY_}, _no)}) dnl exception
define({_CIF_IN_}, _yes)
_ISO_IN_({define({_CIF_IN_}, _no)})

dnl Detectable error situations. Terminate.
_RWSECTRK_({ _RWLBA_({errprint({LBA disk access conflicts with access by sectors and tracks.
})m4exit(1000)})})
_BOOTED_({_HOSTED_LINUX_({errprint({Cannot boot into a Linux hosted Forth.
})m4exit(1001)})})
_BOOTED_({ _HOSTED_MSDOS_({errprint({Cannot boot into a MSDOS hosted Forth.
})m4exit(1002)})})
_BITS16_({ _BITS32_({errprint({32 and 16 bits at the same time? Choose one option!
})m4exit(1003)})})
_LINUX_C_({ _LINUX_N_( {errprint({C library and native calls at the same time? Choose one option!
})m4exit(1004)})})
_CLASSIC_({ _USEBIOS_( {errprint({Classic and BIOS I/O model are in conflict. Choose one option!
})m4exit(1005)})})
_CLASSIC_({ _MODERN_( {errprint({Classic and Modern I/O model are in conflict. Choose one option!
})m4exit(1006)})})
_USEBIOS_({ _MODERN_( {errprint({BIOS and Modern I/O model are in conflict. Choose one option!
})m4exit(1007)})})
_HOSTED_DPMI_({ _HOSTED_MSDOS_({errprint({You must choose either hosting by dos or by windows, not both.
})m4exit(1008)})})
_SOURCEFIELD_({ _LOAD_(, {errprint({You must have BLK to use source fields, hence require loadables.
})m4exit(1009)})})
_HOSTED_({_RESPECTDOS_( {errprint({Respecting dos makes no sense for a hosted system.
})m4exit(1010)})})
dnl immediate consequences
_SOURCEFIELD_({define({M4_HS},M4_HS+1)})dnl
_EXTRAFIELD_({define({M4_HS},M4_HS+1)})dnl
_BITS32_({define({M4_CELLWIDTH}, 4)})
_BITS16_({define({M4_CELLWIDTH}, 2)})
_BITS16_({define({M4_INITDP}, {TEXTEND})})
_BITS32_({define({_NEXT}, {_NEXT32})})
_BITS32_({define({_PUSH}, {_PUSH32})})
_BITS32_({define({_2PUSH}, {_2PUSH32})})
dnl must be overruled after inclusion of postlude.4m
_HOSTED({_BITS32_({define({M4_NBUF}, 16)})})
_HOSTED({_SWITCH_({_BITS32_({define({M4_INITDP},{0x110000})})})})
_BITS32_({define({M4_MAXWORDLIST}, 16)})

dnl LEAVE THIS! THE BOOT CODE IS ALWAYS 16 BITS.
include(width16.m4)
include(namescooked.m4)
divert{}dnl
