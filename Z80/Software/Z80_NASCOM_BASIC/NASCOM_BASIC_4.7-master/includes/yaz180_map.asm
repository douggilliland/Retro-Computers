;==============================================================================
; Contents of this file are copyright Phillip Stevens
;
; You have permission to use this for NON COMMERCIAL USE ONLY
; If you wish to use it elsewhere, please include an acknowledgement to myself.
;
; https://github.com/feilipu/
;
; https://feilipu.me/
;

INCLUDE     "yaz180.inc"

SECTION     z80_vector_rst
ORG         0x0000

SECTION     z80_vector_table_prototype
ORG         Z80_VECTOR_PROTO

SECTION     z80_vector_null_ret
ORG         Z80_VECTOR_PROTO+Z80_VECTOR_SIZE

SECTION     z80_vector_nmi
ORG         0x0066

SECTION     z180_vector_trap_handler
ORG         Z180_VECTOR_TRAP

SECTION     z180_vector_table_prototype
ORG         Z180_VECTOR_PROTO

SECTION     z180_interrupts
ORG         0x00F0

SECTION     z180_asci0
ORG         -1

SECTION     z180_asci0_print
ORG         -1

SECTION     z180_hexloadr
ORG         -1

SECTION     z180_init
ORG         -1

SECTION     z180_init_strings
ORG         -1

;==============================================================================
