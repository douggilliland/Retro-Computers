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

;==============================================================================
;
; DEFINES SECTION
;

DEFC    RAMSTART        =   RAMSTART_CA0
DEFC    RAMSTOP         =   RAMSTOP_CA1

DEFC    STACKTOP        =   $26FE   ; start of a global stack (any pushes pre-decrement)

;   RAM Vector Address for Z80 RST Table, and for Z180 Vector Table
DEFC    Z80_VECTOR_BASE =   RAMSTART_CA0

; Top of BASIC line input buffer (CURPOS WRKSPC+0ABH)
; so it is "free ram" when BASIC resets
; set BASIC Work space WRKSPC $2700, in RAM

DEFC    WRKSPC          =   $2700           ; set BASIC Work space WRKSPC

DEFC    TEMPSTACK       =   WRKSPC+$AB      ; Top of BASIC line input buffer
                                            ; (CURPOS = WRKSPC+0ABH)
                                            ; so it is "free ram" when BASIC resets

;==============================================================================

