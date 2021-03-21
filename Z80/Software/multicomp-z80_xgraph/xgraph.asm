; -------------------------------------------
;                  xgraph.asm
;                  ==========
; Graphical and Char. Functions  for  the
;
;              Multicomp Z80
;
;            RSX for CP/M Plus
;
; Written for Multicomp Z80 / Kurt Mueller
; -------------------------------------------
;
; Copyright (c) 2019 Kurt Mueller
;
; This program is free software; you can redistribute it and/or modify it
; under the terms of the GNU General Public License as published by the
; Free Software Foundation; either version 2, or (at your option) any
; later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with this program; if not, write to the Free Software
; Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.
;
; Changes:
;
; 31 Jan 2019 : v1.00 : First version for Multicomp-Graphic
;
; ----------------------------------------------------------------------
;
; Original:
;
; 'xpcw.asm', FloppySoftware / Miguel I. Garcia Lopez
; -----------------------------------------------------------
; The RSX-StartUp-Code is used unchanged from 'xpcw.asm'.
; All other code is completely new for Multicomp-Graphics
;
; Changes:
;
; 31 Jan 2019 : V1.00 : First Version for Multicomp-Graphic
; 15 Mar 2019 : V1.23 : First complete version
; 11 Apr 2019 : V1.25 : Some bugfixes generating Struct data
; -----------------------------------------------------------
; To assemble to the RSX do the following steps:
;
;     m80 =xgraph.asm
;     link xgraph[op]
;     era xgraph.rsx
;     COPY xgraph.prl xgraph.rsx;
;
; -----------------------------------------------------------
; Call format:
;
; ld   c,60      ; Bdos function
; ld   de,x_dat  ; Data for RSX
; call 5
;
; Data format:
;
; x_dat:  defb 9  ; RSX function # for this RSX
;         defb 6  ; # of parameters, including subfunction
; x_func: defw 0  ; Subfunction as required
;         defw 0  ; Parameter #1
;         defw 0  ; Parameter #2
;         defw 0  ; Parameter #3
;         defw 0  ; Parameter #4
;         defw 0  ; Parameter #5
; -----------------------------------------------------------

        .Z80

; -----------
; Definitions
; -----------

BDOS_RSX   equ 60       ; Bdos function to call an RSX
RSX_FUN    equ 9        ; RSX subfunction (this RSX)
FUNCTIONS  equ (FuncTabEnd-functable)/2+1 ; Num. of avail. Subfunc.
RSXVerNo   equ 125      ; RSX-Vers. = 1.2.5

;BUFSIZE    equ 640     ; Buffer size (80 characters * 8 bytes each)
BytePerChr equ 8        ; Each Char. has 8 Byte
ChrBufSize equ BytePerChr ; Buffer for 1 Char.

ScreenBase equ 0000h    ; Screen-RAM starts at 0000h
MaxColumn  equ 80       ; Max. 80 Char per Row
MaxRow     equ 30       ; Max. 30 Rows pr Screen
MaxScanLne equ MaxRow*8 ; Max. 240 Scanline on Screen (Row = 30)
MaxGraRAM  equ 19200    ; Length Graphic-RAM

SIGNATURE  equ 0DADAh   ; Signature for Hello function

;Logic defintions
ON         equ 0
OFF        equ -1

;Line-Pattern for Lo/HiRes:
LnePat0    equ 1111111111111111b  ;'****************'
LnePat1    equ 0101010101010101b  ;'-*-*-*-*-*-*-*-*'
LnePat2    equ 0110011001100110b  ;'-**--**--**--**-'
LnePat3    equ 0110000110001100b  ;'-**----**---**--'
LnePat4    equ 0110000001100000b  ;'-**------**-----'
LnePat5    equ 0111111001100110b  ;'-******--**--**-'
LnePat6    equ 0111111001111110b  ;'-******--******-'
LnePat7    equ 0110000000000000b  ;'-**-------------'

; -----------------------------------
; Line Graphic
; -----------------------------------
; Circle, Ellipse, Box, Triangle
; Bit-Flags for Sector switching
; Beware: also defined in 'xgraph.h' !
; -----------------------------------
;
;All Octants ON/OFF definition
S_NULL     equ    0  ; Plot nothing (for testing etc.)
S_ALL      equ   -1  ; Plot all Quadrants
;
;Single Octants definition
S_NNW      equ    1  ; Plot North-North-West Quadrant
S_NNE      equ    2  ; Plot North-North-East Quadrant
S_WWN      equ    4  ; Plot West-West-North  Quadrant
S_EEN      equ    8  ; Plot East-East-North  Quadrant
S_SSW      equ   16  ; Plot South-South-West Quadrant
S_SSE      equ   32  ; Plot South-South-East Quadrant
S_WWS      equ   64  ; Plot West-West-South  Quadrant
S_EES      equ  128  ; Plot East-East-South  Quadrant
;
;Definition of Hemisphere's as addition of single Octant definitions
S_NOH      equ  S_NNW + S_NNE + S_WWN + S_EEN ;Northern Hem.
S_SOH      equ  S_SSW + S_SSE + S_WWS + S_EES ;Southern Hem.
S_WEH      equ  S_NNW + S_SSW + S_WWS + S_WWN ;Western Hem.
S_EAH      equ  S_NNE + S_EEN + S_EES + S_SSE ;Eastern Hem.

;Definition of coord.-param. names for data extraction in 'SearchOct()'
S_OctLnNum equ    0  ;=> LByte = Oct. Number, HByte = Linestyle
S_OctStXCo equ    1  ;=> Oct. Start X_Coord.
S_OctStYCo equ    2  ;=> Oct. Start Y-Coord.
S_OctEnXCo equ    3  ;=> Oct. End X-Coord.
S_OctEnYCo equ    4  ;=> Oct. End Y-Coord.

;############### Definition of 'STAT'-Register = 'par6' ################
; ----------------------------------------------------------------------
; Initialize all bit-flags for graphics mode = '320'
;
; Entry: --
; Exit: (GRON, ACON)    := 'ON'
;       (SCREEN, HIRES) := '320'
;       (RCXY)          := '80x30' := 'RC'
;       (TMODE, TWIDTH) := Text noninverted, normal width
;       (TxFNT, TxADDR) := use internal Font,TxADDR = 0 ('internal')
;       (LnePat)        := active linestyle pattern
;       (USEPAT)        := 0=No Pat. in LineGraphic
;       (PATROT)        := 0=Pat. rot. ON
;       (DBLBIT)        := 0=No DblBit in 'PutScrByRC'
; ----------------------------------------------------------------------
;Bits of 'par6' = Reg. 'STAT':
;
;=== STAT+0:
; BIT(0)      = SCREEN          (0=320|1=640)      CalcXY Resol. Control
; BIT(1)      = RCXY            (0=80x30|1=320x240|640x240) Text-Graphic
; BIT(2)      = TWIDTH          (0=8x8-Nwidth|1=16x8-Dwidth)Text-Graphic
; BIT(3)      = TMODE           (0=norm|1=inv)              Text-Graphic
; BIT(4)      = HIRES           (0=320|1=640)               Text-Graphic
; BIT(5..6)   = PXMODE = '0..3' (0=SET|1=CLR|2=INV|3=2)  Pixel-Operation
; BIT(7)      = TXTFNT          (0=internal|1:= external)   Font-Source
;
;=== STAT+1:
; BIT(8)      = USEPAT          (0=No Pat.|1=Use Pat. LineGraphic
; BIT(9)      = PATROT          (0=Pat. rot. ON|1=No Pat. rotation
; BIT(10)     = DBLBIT          (0=No DblBit|1=DblBit, used in 'PutScrByRC'
; BIT(11..15) = ...... = '0..4'  meaning see list of symbolic names below
;
;Some symbolic names for param-fields
STAT         equ     par6
STAT2        equ     par6+1
FNTADDR      equ     par7
;
;special names for STAT bit[5..6]
PxINV        equ    6   ;
PxSET        equ    5   ;
PxCLR        equ    5   ;
;
;'STAT+0' Bit-Flag names:
;= LByte = STAT+0 ========
SCREEN       equ    0   ;
RCXY         equ    1   ;
TWIDTH       equ    2   ;
TMODE        equ    3   ;
HIRES        equ    4   ;
PXMODSC      equ    5   ;
PXMODIN      equ    6   ;
TXTFNT       equ    7   ;
;
;'STAT+1' Bit-Flag names:
;= HByte = STAT+1 ========
USEPAT       equ    0   ; 0 = Use no pattern
PATROT       equ    1   ; 0 = Do Rotate pattern
PLTRBOX      equ    2   ; 0 = Circle/Ellipse Plot|1 = RBox Plot
DBLBIT       equ    3   ; 0 = No Bit-Doubling, normal BitMap write
STATBIT4     equ    4   ; -+
STATBIT5     equ    5   ;  |
STATBIT6     equ    6   ;  | reserved for future use !
STATBIT7     equ    7   ; -+
;=========================
;
;This 'XS_HIRES' bit-mask is a copy of a '#define' done in 'xgraph.h' !
;and is needed for 'ChkHiRes'-Subroutine below !!!
XS_HIRES        EQU     16

; --------------------
; RSX Startup of code
; --------------------

        cseg             ;deactivate, when tb_xgraph is used !

       ;########################################################
       ;# activate these 3 lines when tb_xgraph should be used #
       ;org  0100h
       ;jp   tb_xgraph   ;####### Shortcut zum debuggen ########
       ;ld   de,par1     ;#### DE auf Param.-Array stellen #####
       ;########################################################
        defb 0,0,0,0,0,0 ;Serial number
        jp   Trap        ;Jump to this RSX
Cont:
        jp   0           ;Jump to next RSX
        defw 0           ;Address of previous RSX
        defb 255         ;Remove flag (0 = permanent)
        defb 0           ;Non banked only flag
            ;'12345678'  nur so als Ruler
        defb 'XGraph  '  ;RSX name (8 bytes)
        defb 0           ;Loader flag
        defw 0           ;Reserved for CP/M

Trap:
        ld  a,c         ;Bdos function
        cp  BDOS_RSX    ;a = 60 ?
        jr  nz,Cont

        ld  a,(de)      ;hole RSX-subfunc
        cp  RSX_FUN     ; u. ueberpruefe...
        jr  nz,Cont

        inc de

        ; Check if it is a legal subfunction #
        inc de
        ld  a,(de)      ;hole # of parameters, including subfunction
        cp  FUNCTIONS
        ret nc

        ; Disable the interrupts to gain some speed
        di

        inc de
        inc de

        ; Copy the parameters
        ex  de,hl    ;from...
        ld  de,par1  ;to...
        ld  bc,10    ;  5 parameters as WORD
        ldir         ;  copy par1..par5 ONLY !

        ; Save the SP
        ld (oldsp),sp
        ld sp,newsp

        ; Compute the subfunction address:
        ; func-addr = 2 * hl + functable-addr
        ld  h,0
        ld  l,a
        add hl,hl         ;hl * 2
        ld  de,functable
        add hl,de         ; hl + functable
        ld  a,(hl)        ; hole Sprung-adr.
        inc hl
        ld  h,(hl)
        ld  l,a

        ; Fake a call
        ld   de,SysTrapRet ; retn-adr. vorbereiten
        push de

        ; Call the subfunction
        jp   (hl)

        ; The subfunction returns here
SysTrapRet:
        ld sp,(oldsp)  ; Restore the SP
        ei             ; Enable the interrupts
        ret            ; Return to the user program

; ----------
; Data Area
; ----------

oldsp:  defw 0        ; Old SP

par1:   defw 0        ; 'X0'            Parameter #1
par2:   defw 0        ; 'Y0'            Parameter #2
par3:   defw 0        ; mode|radius     Parameter #3
par4:   defw 0        ; CHAR|'X1'|width Parameter #4
par5:   defw 0        ; ADDR|'Y1'|hight Parameter #5
par6:   defw 0        ; STAT            Bit-Flag Reg. for Graphic-Management

;addr of ext. font-rom
par7:   defw 0        ; FNTADDR     external Font address or '0' for internal

;active/selected line pattern
PATNUM:  defw 0        ; PATNUM = 0  Holds Number of selected line pattern
SELPAT:  defw LnePat0  ; SELPAT = 0  Holds Selected Line-Pattern (by 'SetLneSty')
LNEPAT:  defw LnePat0  ; LNEPAT = 0  Holds Active Line Pattern
QUADRT:  defw S_ALL    ; QUADRT = -1 Holds active quadrants of FnCircle/FnEllipse
rbwidth: defw 0        ;             Holds the width when 'PltRBox' is requested
rbhight: defw 0        ;             Holds the hight when 'PltRBox' is requested

LPattern:
        defs 16         ;8 Words for Line Pattern

;--------------------------------------------------------------
;Coord.-Array base address for pointer to CALLer... All Data in this
;Array is ONLY valid for the actual plotted ellipse. Any new ellipse plot
;updates this data for the newly plotted ellipse ! If this data is needed
;later, it should be copied using the returned pointer. Valid data is from
;label 'OctCoord:' to 'OctCoord1:' = 10 * 5 WORD's= 50 WORD in total !
;
;           +==+==+==+==+==+
OctCoord:;  |+0|+2|+4|+6|+8| <= Offset
;===========+==+==+==+==+==+============================================
O_ELL: defw   0, 0, 0, 0, 0  ; Data of Ellipse when called
;             ^  ^  ^  ^  ^--- Hight Radius
;             |  |  |  +------ Width Radius
;             |  |  +--------- Y-Center Coord.
;             |  +------------ X-Center Coord.
;             +--------------- LByte= plotted Oct. Mask, HByte = Array-Length
;                              HByte is set in 'ClrOctArray' Routine !
O_BXEL: defw  0, 0, 0, 0, 0  ; Data of RBOX-Ellipse (when requested) ELSE '0'
;             ^  ^  ^  ^  ^--- rbhight = RBox-Hight between rounded corners
;             |  |  |  +------ rbwidth = RBox-Width between rounded corners
;             |  |  +--------- SRhight: Surounding rectangular box hight
;             |  +------------ SRwidth: Surounding rectangular box width
;             +--------------- LByte = -1 if RBox  used ELSE '0',
;                              HByte = -1 if HiRes used ELSE '0'.
;-----------------------------------------------------------------------
;           +==+==+==+==+==+
;           |OL|X0|Y0|X1|Y1|   'O' = LByte: Oct., 'L' = HByte:Linestyle
OctCoord0: ;|+0|+2|+4|+6|+8| <= Offset
;===========+==+==+==+==+==+============================================
O_NNW:  defw  0, 0, 0, 0, 0  ; Coord. North-North-West Octant
O_NNE:  defw  0, 0, 0, 0, 0  ; Coord. North-North-East Octant
O_WWN:  defw  0, 0, 0, 0, 0  ; Coord. West-West-North  Octant
O_EEN:  defw  0, 0, 0, 0, 0  ; Coord. East-East-North  Octant
O_SSW:  defw  0, 0, 0, 0, 0  ; Coord. South-South-West Octant
O_SSE:  defw  0, 0, 0, 0, 0  ; Coord. South-South-East Octant
O_WWS:  defw  0, 0, 0, 0, 0  ; Coord. West-West-South  Octant
O_EES:  defw  0, 0, 0, 0, 0  ; Coord. East-East-South  Octant
;             ^  ^  ^  ^  ^--- Oct. End Y-Coord.
;             |  |  |  +------ Oct. End X-Coord.
;             |  |  +--------- Oct. Start Y-Coord.
;             |  +------------ Oct. Start X_Coord.
;             +--------------- LByte= Oct. Number, HByte = Linestyle
;--------------------------------------------------------------
OctCoord1:;Coord.-Struct End
;--------------------------------------------------------------

; ----------------
; Bit-Mask Table
; ----------------

BitMask320:             ; BIT-MASKs FOR 320/640 PIXEL-Mode
        defb 0C0H       ; BIT(7,6)=0C0H Index(0)
        defb 030H       ; BIT(5,4)=060H Index(1)
        defb 00CH       ; BIT(3,2)=030H Index(2)
        defb 003H       ; BIT(1,0)=018H Index(3)
BitMask640:             ; read with (BitMask320 + 4) + index
        defb 080H       ; BIT(7)=080H   Index(0)
        defb 040H       ; BIT(6)=040H   Index(1)
        defb 020H       ; BIT(5)=020H   Index(2)
        defb 010H       ; BIT(4)=010H   Index(3)
        defb 008H       ; BIT(3)=008H   Index(4)
        defb 004H       ; BIT(2)=004H   Index(5)
        defb 002H       ; BIT(1)=002H   Index(6)
        defb 001H       ; BIT(0)=001H   Index(7)

; -----------------
; some data buffers
;------------------

ChrBuf: defs ChrBufSize ; 8 byte Buffer for 1 Char-Cell

; --------------
;   RSX Stack
; --------------
        defs 48
newsp:

;==============================================================
functable:         ; --    Subfunction Description
   defw Hello      ; #0    Detect RSX
   defw RSXVersion ; #1    Return RSX-Version Value
   defw RSXName    ; #2    Return Pointer to RSX-Name String
   defw Initgraph  ; #3    Init Graphic-System
   defw GetStat    ; #4    Get 'STAT'-Register
   defw SetPxMode  ; #5    Set Bit-Flags for Pix-Graph.-Mode
   defw SetTxMode  ; #6    Set Bit-Flags for Text-Outp.-Mode
   defw GRON       ; #7    Graphic-Screen ON/OFF
   defw ACON       ; #8    ASCII-Cursor   ON/OFF
   defw GClrScr    ; #9    Clear entire Graphic Screen (Write w/ Param.)
   defw PutScrRC   ; #10   Write to screen from addr to addr+count with 'byte'
   defw WrToFnROM  ; #11   Write n Char-Cells from addr     to Font-ROM
   defw RdfrFnROM  ; #12   Read  n Char-Cells from Font-ROM to addr
   defw SetTxFnt   ; #13   Define Addr. of ext. Font
   defw ResTxFnt   ; #14   Define Font to internal
   defw SetLnSty   ; #15   Set Line Style Pattern
   defw SetPatRot  ; #16   Stop or Enable Line Pattern Rotation
   defw RotatePat  ; #17   Rotate Line Pattern by 1 Position to the left
   defw LoadPat    ; #18   Re-Load Pattern from 'SELPAT' to 'USEPAT'
   defw OutChr     ; #19   Print single ASCII-Char on Screen
   defw OutStr     ; #20   Print ASCII-String on Screen
   defw PltPix     ; #21   Set/Clr/Get Pixel status from Screen/Inv Pixel (for 640/320 Pix)
   defw GetPix     ; #22   Get Pixel status from Screen
   defw GetPxMask  ; #23   Get Pixel Mask for Pixel(x,y) on Screen
   defw ScrPortRd  ; #24   Write 1 byte to Screen using Port-WR access
   defw ScrPortWr  ; #25   Read  1 from Screen using Port-RD access
   defw PutChRC    ; #26   Write 1 Char-Cell from ChrBuf to 'addr' (in memory)
   defw GetChRC    ; #27   Read  1 Char-Cell from 'addr' to ChrBuf (from memory)
   defw WrChToAddr ; #28   Write 1 Char from ChrBuf to 'addr' in memory
   defw RdChfrAddr ; #29   Read  1 Char from 'addr' in memory to ChrBuf
   defw GetBmpRC   ; #30   copy a Bitmap from screen to addr
   defw PutBmpRC   ; #31   copy a Bitmap from addr to screen
   defw WriteBmpRC ; #32   copy a Bitmap from addr to screen w/ aspect-ratio corr.
   defw CalcRC     ; #33   Calc screen addr of Pc(r,c)
   defw CalcXY     ; #34   Calc screen addr and Pix-Mask of Px(y,x)
   defw SetQuad    ; #35   Load Quadrant definition for FnCircle/FnEllipse
   defw ResQuad    ; #36   Reset Quadrant disable status
   defw ChkQuadStat; #37   Check Quadrant against Bit-Mask
   defw GetStruct  ; #38   Get Ell.-Struct. or requested single Param.
   defw SetRBox    ; #39   Set 'PltRBox'-Flag & 'xwidth'/'yhight' for RBox
   defw ResRBox    ; #40   Reset PltRBox, rbwidth, rbhight for RBox-Plotting
   defw FnLine     ; #41   Plot a Line at Px(y0,x0,x1,y1)
   defw FnLine2    ; #42   Plot a Line at Px(y0,x0,width,hight)
   defw FnBox      ; #43   Plot a Box at Px(x,y,width,hight)
   defw FnElipse   ; #44   Plot a Ellipse at Px(x,y,width,hight)
FuncTabEnd:

; ------------------------------
; Checks if the RSX is in memory
;
; Entry: -
; Exit:  hl = SIGNATURE
; ------------------------------
Hello:
        ld hl,SIGNATURE
        ret

;------------------------------------------------------
;                      tb_bench
;------------------------------------------------------
;
; =====================================================
; ==== Test Bench Test Bench Test Bench Test Bench ====
; =====================================================
; Test Bench for Subroutines in xgraph. Parameters and
; subroutine calls are inserted by hand as needed. 'STAT'
; is GENERELLY modified by the corresponding Bit-Flip
; routines ! ONLY 'par1...par5' should be loaded by hand.
; When "Test-Benching" the following lines at the beginning
; have to be commented out/uncommented:
;
; Line (1,5):    uncomment when running as '.rsx'
; Line (2..4,6): uncomment when running as '.com'
;
; (1)  ;cseg             ;deactivate, when tb_xgraph is used as
;                        ;stand-alone program
;      ;########################################################
;      ;# activate these 3 lines when tb_xgraph runs as stand- #
; (2)  ;org  0100h       ;                       alone program #
; (3)  ;jp   tb_xgraph   ;####### Shortcut for debugging #######
; (4)  ;ld   de,par1     ;#### DE to Param.-Array        #######
;      ;########################################################
;
;
; -----------------------------------------------------
; Param:  par1   par2   par3   par4   par5   par6
; Entry:   x      y     mode   char   addr   STAT
; Exit:   depending on test
; =====================================================
;tb_xgraph: ;test-bench routine for runing not as RSX
;; ====================================================
;; Save the SP
;        ld      (oldsp),sp      ;Use RSX Stack-Area
;        ld      sp,newsp
;
;; ====================================================
;;Graphic Init.
;        call    Initgraph
;        call    ResTMODE        ;noninverted text
;        call    SetXY           ;set XY-Mode
;        call    ResTWIDTH       ;Double width char
;        call    SetLoRES        ;Set LoRes for Graphic
;        call    SetRotON        ;Rotation = ON
;        call    ResQuad         ;All Octants = ON
;        call    GClrScr         ;clear graphic screen
;
;; == FnEllipse =======================================
;;
;;-----------------------------------------------------
;;Set Quadr./Oct. param.
;
;        ld      hl,S_ALL        ;ALL
;        ld      (par3),hl       ;Quadrants
;        call    SetQuad         ;Set Octants
;;-----------------------------------------------------
;;RBox Param.
;        ld      hl,10
;        ld      (par4),hl       ;rbwidth
;        ld      hl,11
;        ld      (par5),hl       ;rbhight
;        call    SetRBox
;;-----------------------------------------------------
;;Ellipse Param.
;        ld      hl,160
;        ld      (par1),hl       ;X
;        ld      hl,120
;        ld      (par2),hl       ;Y
;
;        ld      hl,30
;        ld      (par4),hl       ;width
;        ld      hl,20
;        ld      (par5),hl       ;hight
;
;        ld      hl,0
;        ld      (par3),hl       ;Linestyle
;        call    SetLnSty
;
;        call    SetLoRES        ;Set Resolution for Graphic
;        call    FnElipse
;
;; ----------------------------------------------------
;;Clr Ell-Struct at RSXend
;        ld      hl,RSXend
;        ld      b,100
;        xor     a
;StructClrLoop:
;        ld      (hl),a
;        inc     hl
;        djnz    StructClrLoop
;
;; ----------------------------------------------------
;;Get Ell-Struct
;        ld      hl,S_NULL       ;set 'COPY'-Request
;        ld      (par3),hl       ;XO_mask
;        ld      hl,RSXend
;        ld      (par5),hl       ;Array-Pointer
;
;        call    GetStruct       ;Copy Struct to End of RSX
;
;; ----------------------------------------------------
;;Search Ell-Struct
;        ld      hl,S_NNE        ;Requested Octant Name
;        ld      (par3),hl       ;XO_mask
;        ld      hl,S_OctStXCo   ;Requested Coord. Part: Start-X
;        ld      (par4),hl       ;XO_param
;        ld      hl,RSXend
;        ld      (par5),hl       ;Array-Pointer
;
;        call    GetStruct       ;Use copied Struct at End of RSX
;; ====================================================
;;       ret                ;(5) ;uncomment when called from 'xdemo.com'
;                                ;as RSX-Extension
;; ======================================================================
;; Reload old SP
;        ld      sp,(oldsp) ;(6) ;Restore the SP
;        jp      0x0000     ;(6) ;uncomment when assembled as stand-alone
;                                ;programm
;
;TestStr: defb   "Hello World !",0
;
;
;======  E N D - O F - T E S T B E N C H - A R E A  =======


Initgraph:
        ld    hl,0000h
        ld    (par1),hl  ;clear x-pos
        ld    (par2),hl  ;clear y-pos
        ld    (par3),hl  ;clear MODE
        ld    (par4),hl  ;clear CHAR
        ld    (par5),hl  ;clear ADDR
;             (par6)     ;      STAT
        ld    (par7),hl  ;set Font-addr. to 'internal'

InitLnSty:
        ld    hl,STAT+1         ;set Line-Style = OFF
        res   USEPAT,(hl)
        ld    hl,LnePat0        ;init line pattern array
        ld    (LPattern+0),hl
        ld    hl,LnePat1
        ld    (LPattern+2),hl
        ld    hl,LnePat2
        ld    (LPattern+4),hl
        ld    hl,LnePat3
        ld    (LPattern+6),hl
        ld    hl,LnePat4
        ld    (LPattern+8),hl
        ld    hl,LnePat5
        ld    (LPattern+10),hl
        ld    hl,LnePat6
        ld    (LPattern+12),hl
        ld    hl,LnePat7
        ld    (LPattern+14),hl

InitStat:
        call  GRON       ;switch graphic screen ON
        call  ACON       ;switch ASCII-Cursor ON
        call  SetScr320  ;pixel-coord. for 320x240px (CalcXY)
        call  SetRC      ;switch to RC-Coord. for text output
        call  SetLoRES   ;line graphic in 320x240px
        call  PxMODEset  ;plot pixel in set-Mode
        call  ResTMODE   ;noninverted text output
        call  ResTWIDTH  ;text in normal width
        call  ResTxFnt   ;use internal Font-ROM
        call  SetRotON   ;Enable Pattern Rotation
        call  ResQuad    ;Enable Octant plotting for all 'Fn'-Func.
        call  ResRBox    ;Reset Flag for RBox-Plot of Circle/Ellipse
        call  ResDblBit  ;Reset Flag for aspect-ratio correction
        call  ClrOctArray;Initialize FnEllipse Struct & set Struct length
__NOP:  ret              ;'No_Operation' for Func-Table

; ------------------------------
; Get RSX-Version Number
;
; Param: par1  par2  par3   par4  par5
; Entry:  --    --    --     --    --
; Exit:  Version-Number in 'HL'
; ------------------------------
RSXVersion:
        ld      hl,RSXVerNo     ;Load Vers.-No.
        ret

; ------------------------------
; Get RSX-Version Name
;
; Param: par1  par2  par3   par4  par5
; Entry:  --    --    --     --    --
; Exit:  Pointer to RSX-Name in 'HL'
; ------------------------------
RSXName:
        ld      hl,RSXNme     ;Load Pointer to RSX-Name
        ret

RSXNme: defb    'XGRAPH',0

; ------------------------------
; Get Graphic Stat-Reg.
;
; Param: par1  par2  par3   par4  par5
; Entry:  --    --   mask   --    --
; Exit:  IF 'mask' = 0 THEN hl ='STAT' ELSE
;            hl = 'TRUE' | 'FALSE'
; ------------------------------
GetStat:
        ld      hl,(STAT)       ;get STAT-Reg
        ld      de,(par3)       ;get mask
        res     SCREEN,l        ;SCREEN is dynamic and only
                                ;for'CalcXY' of any importance
GetSta0:
        ld      a,e
        or      d
        jr      z,GetSta1       ;return with 'STAT'-Bits in hl
MaskStat:
        ld      a,l
        and     e
        ld      l,a
        ld      a,h
        and     d
        ld      de,-1           ;pre-set de with 'TRUE'
        ld      h,a
        or      l
        jr      z,GetSta1       ;return with 'FALSE' in hl
        ex      de,hl
GetSta1:
        ret                     ;return with 'TRUE' in hl

; -----------------------------------------
; Set pattern rotation status in Stat-Reg.
; Call from User-Prog.:
;               'SetPatRot(X_ON|X_OFF);
;
; Param: par1  par2  par3   par4  par5
; Entry:  --    --   mode   --    --
; Exit:   --
; ------------------------------------------
SetPatRot:
        ld      a,(par3)        ;get ON/OFF Rotation wish
        or      a
        jr      nz,SetRotOFF
SetRotON:
        push    hl
        ld      hl,STAT+1       ;get high STAT-Reg
        res     PATROT,(hl)     ;Enable Pat.-Rotation
        jr      SetRotEnd
SetRotOFF:
        push    hl
        ld      hl,STAT+1       ;get high STAT-Reg
        set     PATROT,(hl)     ;Stop Pat.-Rotation
SetRotEnd:
        pop     hl
        ret

; ------------------------------------------------
; Rotate Line Pattern by 1 Position to the left
;
; Param: par1  par2  par3   par4  par5
; Entry:  --    --    --     --    --
; Exit:   --
; ------------------------------------------------
RotatePat:
        push    af
        push    hl
DoRotate:
        ld      hl,(LNEPAT)   ;get pattern
        xor     a
        adc     hl,hl      ;rotate pattern left
        adc     a,l        ;add in possible carry from left shift
        ld      l,a        ;Bit0 is ALLWAYS '0'
        ld      (LNEPAT),hl;store pattern for next pixel
RotateEnd:
        pop     hl
        pop     af
        ret

; ------------------------------------------------
; Load Line Pattern from 'SELPAT'
;
; Param: par1  par2  par3   par4  par5
; Entry:  --    --    --     --    --
; Exit:   --
; ------------------------------------------------
LoadPat:
        push    hl
        ld      hl,(SELPAT)     ;get selected pattern and...
        ld      (LNEPAT),hl     ;do restart pattern
        pop     hl
        ret

; ------------------------------------------------
; Load Quadrant definition for FnCircle/FnEllipse
;
; Param: par1  par2  par3   par4  par5
; Entry:  --    --   mode    --    --
; Exit:   --
; ------------------------------------------------
SetQuad:
        push    hl
        ld      hl,(par3)     ;get 'mode' with Quadrat definition
SetQuad0:
        ld      h,00h         ;set HByte to zero
        ld      (QUADRT),hl   ;'l' holds definition
        pop     hl
        ret

ResQuad: ;This Entry-Point is for re-enable all quadrants RSX-Internal
        push    hl
        ld      hl,S_ALL
        jr      SetQuad0

SetAQuad: ;load Quadr. from 'a'. RSX-Internal use ONLY !
        push    hl
        ld      l,a
        jr      SetQuad0

ClrFnEllIni:;Clear the Ellipse Data area, RSX-Internal use ONLY !
        ld      hl,FnEllDat
        ld      b,FnEllDat1 - FnEllDat
        jr      ClrOctArray2

ClrOctArray:;Clear the Octand Array, RSX-Internal use ONLY !
ALENGTH equ     (OctCoord1 - OctCoord)*256
        ld      hl,OctCoord
        ld      bc,ALENGTH
        ld      (O_ELL+0),bc    ;Initialize byte with array-length
ClrOctArray2:
        xor     a
ClrOctArray1:
        ld      (hl),a
        inc     hl
        djnz    ClrOctArray1
        ret

; -----------------------------------
;Octants Bit-Value definition: Only single-bit Oct.-Requests
;                              are allowed !
;
;'XO_parm' = 'S_NULL' forces copy of complete struct
;                     to 16-bit *ParVal pointer position.
;'XO_parm' = 'S_ALL'  returns size of Data-Struct. in hl
;
;S_NULL   equ     0  ; Copy all Quadrant-Data to *ParVal
;S_ALL    equ    -1  ; Return-Value: LByte = size of struct
;                                    HByte = plotted Oct.-mask
;Single Octants definition:
;S_NNW   equ      1  ; Get North-North-West Quadrant Data
;S_NNE   equ      2  ; Get North-North-East Quadrant Data
;S_WWN   equ      4  ; Get West-West-North  Quadrant Data
;S_EEN   equ      8  ; Get East-East-North  Quadrant Data
;S_SSW   equ     16  ; Get South-South-West Quadrant Data
;S_SSE   equ     32  ; Get South-South-East Quadrant Data
;S_WWS   equ     64  ; Get West-West-South  Quadrant Data
;S_EES   equ    128  ; Get East-East-South  Quadrant Data
; --------------------------------------------------------
; --------------------------------------------------------
; Get Param. Definitions for FnEllipse-Struct:
; ============================================
; 'XO_mask'   = Oct. Bit-Mask to search for
; 'XO_parm'   = Requested Param.
; 'addr'      = Pointer to C-Array or Ell.-Struct. in RSX
; XO_OctLnNum = 0 => LByte = Oct. Mask, HByte = Linestyle Number
; XO_OctStXCo = 1 => Oct. Start X_Coord.
; XO_OctStYCo = 2 => Oct. Start Y-Coord.
; XO_OctEnXCo = 3 => Oct. End X-Coord.
; XO_OctEnYCo = 4 => Oct. End Y-Coord.
; --------------------------------------------------
; Param: par1  par2  par3     par4     par5
; Entry:  --    --   XO_mask  XO_parm  pointer
; Exit:  hl = 'value' or '*ptr', depending on request
;        IX = destroyed
; --------------------------------------------------
GetStruct:
        ld      a,(par3)        ;Test for XO_NULL or XO_ALL case
        or      a
        jr      z,CopyStruct    ;XO_NULL = COPY requested
        cp      S_ALL
        jr      nz,SearchOct
        ld      hl,(par5)       ;hl = 'C-Array' or 'Oct.-Struct' in RSX
        ld      a,h
        or      l
        jr      nz,GetStruct0   ;if par5 <> 0 then external struct-buffer
        ld      hl,(O_ELL+0)    ;Oct. Mask/Struct-Size from internal
        ret
GetStruct0:
        ld      e,(HL)          ;get Oct-Mask from ext. struct.
        inc     hl
        ld      d,(hl)          ;get Struct-Size from ext. struct.
        ex      de,hl           ;swap to hl for return
        ret

CopyStruct: ;Copy Ellipse-Struct by *Ptr in hl
        ;check if target = source pointer
        ld      de,(par5)       ;get pointer to {C-Array|Ell-Struct}
        ld      hl,OctCoord     ;get address of Ell-Struct
        or      a
        sbc     hl,de
        jr      nz ,CopyStruct1 ;IF z THEN copy to itself ! Do nothing.
        ld      hl,(O_ELL+0)    ;get plotted oct. + Struct-Size
        ret
;
CopyStruct1:
        ld      hl,(par5)       ;get pointer to {C-Array|Ell-Struct}
        ld      bc,(O_ELL+0)    ;get Struct-Size into b
        push    bc
        ld      de,OctCoord     ;get address of Ell-Struct

CopyStruct0:
        ld      a,(de)
        ld      (hl),a
        inc     de
        inc     hl
        djnz    CopyStruct0
        pop     hl              ;h = Struct Size, l = active Oct.-Mask
        ret

SearchOct:
RowCnt0 equ     (OctCoord1 - OctCoord0)/(O_NNE - O_NNW)

        ld      bc,(par3)       ;get Oct.-Mask
        ld      hl,(par5)       ;hl = 'C-Array' or 'Oct.-Struct' in RSX
        ld      de,OctCoord0 - O_ELL ;skip first 20 Byte
        add     hl,de
        ld      de,O_NNE - O_NNW ;each row is 10 bytes in width
        ;'b' = Row-Cnt,'c' holds 'mask'
        ld      b,RowCnt0

SearchOct0:
        ld      a,(hl)          ;get Oct.-Number
        cp      c
        jr      z,SearchOct1    ;IF 'z' THEN Oct. found
        add     hl,de           ;next Row
        djnz    SearchOct0      ;all Row's done ?
        jp      z,SearchOct2    ;we fail, Oct.-Num not single Bit !

SearchOct1:
        push    hl
        pop     ix              ;use ix for data retrival
        ld      a,(par4)        ;get req. param.-number
        or      a               ;Oct.-Num + Line-Style ?
        jr      nz,SearchOct3   ;IF NZ THEN next
        ld      h,0
        ld      l,(ix+1)        ;get Number of LineStyle
        inc     a               ;who cares ?
        or      a               ;set Z-Flag to 'NZ' for 'TRUE'
        ret

SearchOct3:
        cp      1               ;is it Oct. Start X_Coord. ?
        jr      nz,SearchOct4   ;IF NZ THEN next
        ld      l,(ix+2)
        ld      h,(ix+3)
        or      a               ;set Z-Flag to 'NZ' for 'TRUE'
        ret

SearchOct4:
        cp      2               ;is it Oct. Start Y_Coord. ?
        jr      nz,SearchOct5   ;IF NZ THEN next
        ld      l,(ix+4)
        ld      h,(ix+5)
        or      a               ;set Z-Flag to 'NZ' for 'TRUE'
        ret

SearchOct5:
        cp      3               ;is it Oct. End X_Coord. ?
        jr      nz,SearchOct6   ;IF NZ THEN next
        ld      l,(ix+6)
        ld      h,(ix+7)
        or      a               ;set Z-Flag to 'NZ' for 'TRUE'
        ret

SearchOct6:
        cp      4               ;is it Oct. End Y_Coord. ?
        jr      nz,SearchOct2   ;IF NZ THEN next
        ld      l,(ix+8)
        ld      h,(ix+9)
        or      a               ;set Z-Flag to 'NZ' for 'TRUE'
        ret

SearchOct2:
        xor     a               ;clear Z-Flag for 'FALSE'
        ld      hl,0
        ret

; ------------------------------------------------
; Set RBox-Mode when plotting a Circle/Ellipse
;
; Param: par1  par2  par3   par4  par5
; Entry:  --    --   octm   width hight
; Exit:   --
; ------------------------------------------------
SetRBox:
        push    hl
        ld      hl,STAT+1
        set     PLTRBOX,(hl)
        ld      hl,(par4)       ;'ChkHiRes' destroys hl, so load now...
SetRBox0:
        ld      (rbwidth),hl
        ld      hl,(par5)
        ld      (rbhight),hl
        pop     hl
        call    SetQuad
        ret

ResRBox: ;Reset RBox-Mode Flag, for RSX-Internal use ONLY !
        push    hl
        ld      hl,STAT+1
        res     PLTRBOX,(hl)
        ld      hl,0
        ld      (rbwidth),hl
        ld      (rbhight),hl
        pop     hl
        ret

; ------------------------------------------------
; Check single Octant (= 'mask') against activ Oct.
; and return.
; 'SET' = TRUE, 'Not SET' = FALSE status
;
; Param: par1  par2  par3   par4  par5
; Entry:  --    --   mask    --    --
; Exit:   --
; ------------------------------------------------
; Entry 'TstQuadStat:' RSX-internal only !
TstQuadStat: ;Bit-Mask for Oct-Test is in 'l', RSX-Internal use only !
        push    de      ; hl holds requested octant mask fom caller
        jr      ChkQuadStat0

ChkQuadStat:
        push    de
        ld      hl,(par3)     ;get 'mask' with single Octant definition

ChkQuadStat0:
        ld      de,(QUADRT)   ;get Octant Plot-Status
        ld      a,e
        and     l             ;check requested Octant
        ld      hl,-1         ;pre-load 'TRUE'
        jr      nz,ChkQuadStat1 ;return 'TRUE'
        ld      hl,0          ;return 'FALSE'
ChkQuadStat1:
        pop     de
        ret

; ------------------------------
; switch GRAPHIC SCREEN on/off
;
; Param: par1  par2  par3   par4  par5
; Entry:  --    --   mode    --    --
; Exit:   --
; ------------------------------
GRON:
        ld   a,(par3)   ;get MODE byte
        or   a          ;check if Z
        jr   z,GRON2
GRON1:  out (094H),a    ;graphic screen = OFF
        ret
GRON2:  out (095H),a    ;graphic screen = ON
        ret

; ------------------------------
; switch ASCII-Cursor ON/OFF
;
; Param: par1  par2  par3   par4  par5
; Entry:  --    --   mode    --    --
; Exit:   --
; ------------------------------
ACON:
        ld   a,(par3)   ;get MODE byte
        or   a          ;check if Z
        jr   z,ACON2
ACON1:  out  (09AH),a   ;ASCII Cursor = OFF
        ret
ACON2:   out (09BH),a   ;ASCII-Cursor = ON
        ret

;##################### stst-bit Routines ######################
; -----------------------------------------
; sets flags in 'STAT' mode '320' or '640'
;
; Param: par1  par2  par3   par4  par5
; Entry:  --    --   mode    --    --
; Exit:   --
; -----------------------------------------
; =====================================================================
; Screen-Coord. control func.
; =====================================================================
;Note: 'SetScr640' & 'SetScr320' are used to temporarily change the
;       screen-rolution for 'CalcXY'. Line-graphics always uses 'calcXY'
;       for address-calculation. Char-Graphic uses 'CalcRC'.
;
;====================
;Symbolic func-codes:
;====================

G_HiRes  equ    0       ;for C-Func: X_HiRes
G_LoRes  equ    1       ;for C-Func: X_LoRes
G_PxSET  equ    2       ;for C-Func: X_PxSET
G_PxCLR  equ    3       ;for C-Func: X_PxCLR
G_PxINV  equ    4       ;for C-Func: X_PxINV
G_Scr640 equ    5       ;for C-Func: X_HiRes
G_Scr320 equ    6       ;for C-Func: X_LoRes

SetPxMode:
        ld      a,(par3)
SetPxMod0:
        and     07h             ;limit number range
        cp      G_PxINV+1       ;Func-Code 0..4 ?
        ret     nc              ;code > 'G_PxINV', do nothing...

        cp      G_Scr640
        jr      z,SetScr640
        cp      G_Scr320
        jr      z,SetScr320

        cp      G_HiRes
        jr      z,SetHiRES
        cp      G_LoRes
        jr      z,SetLoRES
        cp      G_PxSET
        jr      z,PxMODEset
        cp      G_PxCLR
        jr      z,PxMODEclr
        jr      PxMODEinv

;####################################################################
;########## ONLY for RSX-Internal operation to control 'CalcXY' #####
;####################################################################
SetScr640: ; switches calcXY for addr calc. to 640x240px
        push    hl
        ld      hl,STAT
        set     SCREEN,(hl)     ;Resol. to 640px
        pop     hl
        ret

SetScr320: ; switches calcXY for addr calc. to 320x240px
        push    hl
        ld      hl,STAT
        res     SCREEN,(hl)     ;Resol. to 320px
        pop     hl
        ret
;####################################################################

SetHiRES: ; defines all bit-mask & line graphic operation in 640x240 resol.
        push    hl
        ld      hl,STAT
        set     HIRES,(hl)
        pop     hl
        ret

SetLoRES: ; defines all bit-mask & line graphic operation in 320x240 resol.
        push    hl
        ld      hl,STAT
        res     HIRES,(hl)
        pop     hl
        ret

PxMODEset: ;Pixel-Operation is 'SET'
        push    hl
        ld      hl,STAT
        res     PxSET,(hl)
        res     PxINV,(hl)
        pop     hl
        ret

PxMODEclr: ;Pixel-Operation is 'CLR'
        push    hl
        ld      hl,STAT
        set     PxSET,(hl)
        res     PxINV,(hl)
        pop     hl
        ret

PxMODEinv: ;Pixel-Operation is 'INV'
        push    hl
        ld      hl,STAT
        res     PxSET,(hl)
        set     PxINV,(hl)
        pop     hl
        ret

;========================
;text shape control func.
;========================
;
;Symbolic func-codes:
;====================
T_RC     equ     0       ;for C-Func: X_RC
T_XY     equ     1       ;for C-Func: X_XY
T_DW     equ     2       ;for C-Func: X_DW
T_SW     equ     3       ;for C-Func: X_SW
T_TI     equ     4       ;for C-Func: X_TI
T_TN     equ     5       ;for C-Func: X_TN
; -----------------------------------------------------
;
; 'SetTxMode' is a wrapper-routine
; Param: par1 par2  par3   par4   par5
; Entry:  --   --   mode    --     --
; Exit:   --
; -----------------------------------------------------
SetTxMode: ;Func-Code in a
        ld      a,(par3)        ;get text-mode code
        and     07h             ;limit number range ..
        cp      T_TN+1          ;Func-Code > T_TN ?
        ret     nc              ;code > 'T_TN', do nothing...
        cp      T_RC
        jr      z,SetRC
        cp      T_XY
        jr      z,SetXY
        cp      T_DW
        jr      z,SetTWIDTH
        cp      T_SW
        jr      z,ResTWIDTH
        cp      T_TI
        jr      z,SetTMODE
        jr      ResTMODE

;
; -------------------------------------------------------
SetRC: ;print text at (row x col)-coord., addr-calc. is done with 'calcRC'
        push    hl
        ld      hl,STAT
        res     RCXY,(hl)
        pop     hl
        ret

SetXY: ;print text at (X,Y)-coord., addr-calc. is done with 'calcXY'
        push    hl
        ld      hl,STAT
        set     RCXY,(hl)
        pop     hl
        ret

SetTWIDTH: ;print all text in double-width
        push    hl
        ld      hl,STAT
        set     TWIDTH,(hl)
        pop     hl
        ret

ResTWIDTH: ;print all text in single-width
        push    hl
        ld      hl,STAT
        res     TWIDTH,(hl)
        pop     hl
        ret

SetTMODE: ;print all text inverted
        push    hl
        ld      hl,STAT
        set     TMODE,(hl)
        pop     hl
        ret

ResTMODE: ;print all text non-inverted
        push    hl
        ld      hl,STAT
        res     TMODE,(hl)
        pop     hl
        ret

; ------------------------------------------
; Get STAT of pixel(x;y): Z = Res, NZ = Set
;
; Param: par1  par2  par3   par4  par5
; Entry:  x     y     --     --    --
; Exit:  a = h = l = Z or NZ
; ------------------------------------------
GetPix: call CalcXY
        ld   c,a          ;Bitmask to c
        in   a,(093h)     ;get byte
        and  c            ;mask bit
        ld   h,0          ;hl holds return-value in MESCC
        ld   l,a
        ret

; ------------------------------------------
; Get Pixel-Mask from pixel(x;y). Pixelmask
; according to Graphic-Mode Flags in 'STAT'
;
; Param: par1  par2  par3   par4  par5
; Entry:  x     y     --     --    --
; Exit:  hl = pixel mask
; ------------------------------------------
GetPxMask:
        call CalcXY
        ld   h,0          ;hl holds return-value in MESCC
        ld   l,a
        ret

; ------------------------------------------------
; Handle Pixel according to bits in STAT for Line-
; Graphic Functions
;
; Param: par1  par2  par3   par4  par5
; Entry:  x     y     --     --    --
; Exit:   --
; ------------------------------------------------
PltPix: push bc         ;save used registers
        push de
        push hl
        call SetScr320
        ld   a,(STAT)   ; STAT-byte (low byte of par6)
        bit  HIRES,a    ;Bit4 = '640px' ?
        call nz,SetScr640
        call CalcXY     ;calc addr, set ports, ret: hl=addr, a=bitmask
        call PixMode
        pop  hl
        pop  de
        pop  bc
        ret

PixMode: ;Ports are set by CalcXY !, hl holds 'addr'
        ld   c,a        ; a holds the bitmask, move to c
        ld   a,(STAT)   ; STAT-byte (low byte of par6)
        bit  PxINV,a    ;Bit6 = 'INV' ?
        jr   nz,InvPix
        bit  PxCLR,a
        jr   nz,ClrPix  ;if bit5 = z fall through to 'SET'
CkPattern:
        ld   a,(STAT+1) ; get HByte for line-style check
        bit  USEPAT,a
        jr   z,SetPix   ;'0' = pattern inactive, otherwise...
        bit  PATROT,a    ;Check if PatRot allowed
        call z,RotatePat ;if PATROT = '0' then rotate
NoRot:
        ld   hl,(LNEPAT);get pattern
        bit  7,h        ;
        jr   z,ClrPix   ;if Bit7 = 0 => 'CLR' pixel, otherwise...

        ; Set mode
SetPix: in   a,(093h)   ;get byte
        or   c          ;set bit
        jr   InvPx2

        ; Clear mode
ClrPix: in   a,(093h)   ;get byte
        or   c          ;force bit to '1'
        jr   InvPx1

        ; Toggle mode
InvPix: in   a,(093h)   ;get byte
InvPx1: xor  c          ;inv./clr bit
InvPx2: out  (092h),a   ;write byte back
        ret

; ------------------------------------
; Write Byte to addr on Screen
;
; param: par1  par2  par3   par4   par5
; entry:  --    --    --    byte   addr
; exit:   --
; ------------------------------------
ScrPortWr:
        ld      de,(par5)       ;get addr
        ld      a,(par4)        ;read byte from par4
        call    WrScrPort       ;write byte to screen
        ret

; ------------------------------------
; Read Byte from addr on Screen
;
; param: par1  par2  par3   par4   par5
; entry:  --    --    --      --   addr
; exit:   hl = byte
; ------------------------------------
ScrPortRd:
        ld      de,(par5)       ;get addr
        call    RdScrPort       ;read byte from screen
        ld      l,a             ;prepare return value in hl
        ld      h,0
        ret

; -----------------------------------------
; Write addr in de to Screen Port $96/$97
; Write a to Screen Port $92
; Entry: de = addr, a = byte
; Exit:  --
; -----------------------------------------
WrScrPort:
        push    af              ;save data
        ld      a,e
        out     (096h),a        ;set low-byte addr.
        ld      a,d
        out     (097h),a        ;set high-byte addr.
        pop     af              ;restore data
        out     (092h),a        ;write byte to screen
        ret

; -----------------------------------------
; Write addr in de to Screen Port $96/$97
; Read a byte from Screen Port $92 to a
; Entry: de = addr
; Exit:  a = byte
; -----------------------------------------
RdScrPort:
        ld      a,e
        out     (096h),a        ;set low-byte addr.
        ld      a,d
        out     (097h),a        ;set high-byte addr.
        in      a,(093h)        ;read byte from screen
        ret

; ------------------------------------
; Set font from (par5) = addr or
; font addr = 0 for internal
;
; param: par1  par2  par3   par4   par5
; entry:  --    --    --      --   addr
; exit:   --
; ------------------------------------
SetTxFnt:
        push    hl
        ld      hl,STAT
        set     TXTFNT,(hl)     ;enable external Font
        ld      hl,(par5)       ;get new 'fntaddr'
        ld      (FNTADDR),hl    ;set addr for 'external' font
        xor     a
        or      h
        or      l               ;IF 'adr' is 0x0000 THEN
        jr      z,ResTxFnt1     ;   DROP 'TXTFNT' and 'addr'...
        pop     hl
        ret

ResTxFnt:
        push    hl
ResTxFnt1:
        ld      hl,STAT
        res     TXTFNT,(hl)     ;reset font-flag
        ld      hl,0
        ld      (FNTADDR),hl    ;reset font-'addr'
        pop     hl
        ret

; ---------------------------------------
; Set Line Style from (par3). Only Bit[0..3]
; is allowed.
;
; param: par1  par2  par3   par4   par5
; entry:  --    --   style   --     --
; exit:   --
; ---------------------------------------
SetLnSty:
        push    hl
        push    de
        ld      hl,STAT+1       ;pointer to 'USEPAT'
        set     USEPAT,(hl)     ;pre-activate Line-Patern
        res     PATROT,(hl)     ;Activate Pat. rotation by default
        ld      a,(par3)        ;get Style-Code
        and     07h             ;Limit to 3 Bits = 8 pattern
        ld      (PATNUM),a      ;Save pattern-number
        ld      (PATNUM+1),a
        jr      nz,SetLnSty1
        res     USEPAT,(hl)     ;LPattern0 deactivates Line-Pattern
SetLnSty1:
        add     a,a
        ld      d,0
        ld      e,a
        ld      hl,LPattern     ;load pointer to pattern base
        add     hl,de
        ld      e,(hl)
        inc     hl
        ld      d,(hl)
        ld      (SELPAT),de     ;set Line pattern
        ld      (LNEPAT),de
        pop     de
        pop     hl
        ret

; ---------------------------------------------
; Print a single char on the screen 'STAT',
; consider 'XA_DW' Flag for output
;
; Param: par1  par2  par3   par4   par5
; Entry:  x     y     --    char    --
; Exit:   --
; ---------------------------------------------
OutChr:
        push    hl              ;save (hl)
        ld      hl,(par1)
        push    hl              ;save orig. xpos
        ld      a,(STAT)
        bit     RCXY,a
        jr      z,OutChr2       ;RC-Mode has no TWIDTH
        add     hl,hl           ;go from 320px to 640px
        bit     TWIDTH,a
        jr      z,OutChr1
        sra     h               ;1 = DW: div hl by 2 for const. pos.
        rr      l               ;0 = SW: do nothing...
OutChr1:
        ld      (par1),hl       ;store corrected XPOS
OutChr2:
        call    OutCh           ;do single char output
        pop     hl
        ld      (par1),hl       ;restore xpos
        pop     hl
        ret

; ---------------------------------------------
; Print a single char on the screen 'STAT' de-
; pendent
; if 'RCXY' = 0 then Pc(x;y) else Px(x;y)
;
; Param: par1  par2  par3   par4   par5
; Entry:  x     y     --    char    --
; Exit:   --
; ---------------------------------------------
OutCh: ;Print one ASCII-char on Screen
        push    hl         ;caller needs (hl) !
        call    RdCROM     ;Read Char from CROM to ChrBuf
        ld      a,(STAT)   ;get 'RCXY'-Bit
        bit     RCXY,a     ;print with RC or XY coord. ?
        jr      nz,OutCh1  ;if RCXY=1 then print in pixel-mode
        call    PutChRC    ;Write Char in RC_Mode to Screen
        pop     hl
        ret
OutCh1:
        call    WrChXY     ;Write Char in Pixel-Mode to Screen
        pop     hl
        ret
; ----------------------------------------------------
; Print a null-terminated text-string from
; addr on screen 'STAT' dependent
; at Pc(x;y) or Px(x;y). Uses 'OutCh' for Output:
;
; (X,Y) unchanged after String-Output
;
; Param: par1  par2  par3   par4   par5
; Entry:  x     y     --     --    addr
; Exit:   --
; ----------------------------------------------------
OutStr: ; Print ASCII-String on Screen
        ; (Single Char-Output is done by "OutCh")
        ; String is NULL-terminated.
        push    hl              ;save (hl)
        push    de
        ld      hl,(par4)
        push    hl              ;save par4, internal use for 'OutChr'
        ld      hl,(par2)
        push    hl              ;save y-pos
        ld      hl,(par1)
        push    hl              ;save x-pos
        ld      a,(STAT)
        bit     RCXY,a
        jr      z,OutStr0       ;RC-Mode has no TWIDTH
        add     hl,hl           ;go from 320px to 640px
        bit     TWIDTH,a
        jr      z,OutStr3
        sra     h               ;1 = DW: div hl by 2
        rr      l
OutStr3:
        ld      (par1),hl       ;store divided XPOS
OutStr0:
        ld      de,(par5)       ;get str addr
OutStr1:
        ld      a,(de)          ;get char.
        or      a
        jr      z,OutStr2       ;return if end of str
        ld      (par4),a        ;store char in (par4)
        call    OutCh           ;'WrCh..' auto-incr. X-POS !
        inc     de              ;next char pos. in str
        jr      OutStr1
OutStr2:
        pop     hl
        ld      (par1),hl       ;restore x-pos
        pop     hl
        ld      (par2),hl       ;restore y-pos
        pop     hl
        ld      (par4),hl       ;restore par4
        pop     de
        pop     hl              ;restore old (hl)
        ret

; --------------------------------------
; Write  ChrBuf to Screen at Pc(x;y).
; X-POS is auto-incr. by 1 char.-pos.
;
; Param: par1 par2  par3   par4  par5
; Entry:  x    y    --      --    --
; Exit:  Char-Cell to Pc(X;Y) on Screen
; --------------------------------------
PutChRC:
        push    hl              ;save used register
        push    de
        push    bc
        push    af
        call    CalcRC          ;Calc addr from Pc(x;y), hl holds screen-adr.
        ld      de,ChrBuf
        ex      de,hl           ;hl points now to ChrBuf, de to screen
        ld      b,8
PutChRC1:                       ;(par5) holds the pre-calculated Char-Addr.
        push    hl
        ld      hl,STAT         ;lade Zeiger auf STAT
        bit     TMODE,(hl)      ;tmode = invers ?
        pop     hl
        ld      a,(hl)          ;read byte from ChrBuf
        jr      z,PutChRC2
        xor     0FFh            ;yes, 'invers' mode
PutChRC2:
        call    WrScrPort       ;write byte to screen
        inc     hl
        inc     de
        dec     b
        jr      nz,PutChRC1      ;8 times done ?

        ld      hl,(par1)       ;auto-incr. X-POS
        inc     hl
        ld      (par1),hl
        pop     af              ;Restore register
        pop     bc
        pop     de
        pop     hl
        ret

; ------------------------------------------
; Read 1 Char-Cell from Pc(x;y) to ChrBuf
;
; Param: par1 par2  par3   par4   par5
; Entry:  x    y     --     --     --
; Exit:   --
; ------------------------------------------
GetChRC:
        push hl          ;save used register
        push de
        push bc
        push af
        call CalcRC     ;calc addr from Xc & Yc, addr to ports, addr in hl
        ld   de,ChrBuf
        ex   de,hl      ;de points now to Screen, hl to ChrBuff
        ld   b,8        ;Length of Char-Cell
GetChRC1:
        call RdScrPort  ;byte in a
        ld   (hl),a     ;write to ChrBuf
        inc  de         ; incr. screen-addr.
        inc  hl         ; next position in ChrBuf
        dec  b          ; decr. byte count
        jr   nz,GetChRC1 ;are we ready ?
        pop  af         ;Restore register
        pop  bc
        pop  de
        pop  hl
        ret

; ----------------------------------------
; Write 1 Char-Cell from ChrBuf in Pixel-
; Mode to Screen. X-POS is auto-inc. by
; 'WrChXY' for each printed char, so Str-
; Output is simplyfied !
;
; Param: par1 par2  par3   par4  par5
; Entry:  x    y     --     --    --
; Exit:  x points to next char-pos.
; ----------------------------------------
WrChXY: push    bc              ;save some used reg.
        push    de
        push    hl

        ld      hl,(par2)       ;save y-coord.
        push    hl
        ld      b,08h           ;reg b = byte per char counter
        ld      de,ChrBuf
WrChXY1:
        call    WrByXY          ;scan 1 byte, de points to cell-byte
        ld      hl,(par2)       ;next y-pos.
        inc     hl
        ld      (par2),hl
        inc     de              ;next byte of char-cel
        dec     b
        jr      nz,WrChXY1      ;loop until 8 bytes ar scanned
        pop     hl
        ld      (par2),hl       ;restore y-coord.

        ld      hl,(par1)       ;autoincr. to next x-pos.
        ld      bc,8
        add     hl,bc
        ld      (par1),hl       ;move on to next char-pos.

        pop     hl
        pop     de
        pop     bc
        ret

;DE holds pointer to ChrBuf Cell-Byte to output
WrByXY: push    bc              ;reg bc is needed
        ld      hl,(par1)       ;save x-pos
        push    hl
        ld      c,08h           ;load bit counter
        ld      a,(de)          ;get cell-byte from ChrBuf
        ld      hl,STAT         ;lade Zeiger auf STAT
        bit     TMODE,(hl)      ;tmode = invers ?
        jr      z,WrByXY1
        xor     0FFh            ;yes, 'invers' mode
WrByXY1:
        ld      b,a             ;save a to b, CalcXY needs reg a
WrByXY2:
        push    bc              ;save cell-byte & loop-counter
        ld      hl,STAT
        set     SCREEN,(hl)     ;preset SCREEN to 640px
        bit     TWIDTH,(hl)     ;should we print in double width ?
        jr      z,WrByXY3
        res     SCREEN,(hl)     ;yes, double width, set SCREEN to 320px

WrByXY3:
        call    CalcXY          ;port=addr is set, a=bitmask
        ld      c,a
        bit     7,b             ;test bit7 in reg b
        call    nz,SetPix       ; if z then setpix
        bit     7,b             ;    test bit again
        call    z,ClrPix        ; if nz then clrpix
        pop     bc              ;get back loop-counter

        ld      hl,(par1)       ;prepare for next x-pos
        inc     hl
        ld      (par1),hl
        sla     b               ;prepare for next bit
        dec     c
        jr      nz,WrByXY2      ;next bit

        pop     hl
        ld      (par1),hl       ;byte ready, restore x-pos
        pop     bc
        ret

; -----------------------------------------------
; Clear the graphic screen with 'data', uses
; internal (par3), (par5) for calling "PutScrRC"
; to clear the Screen, (par3) & (par5) are saved
; and restored after clearing.
;
; Param: par1   par2   par3   par4   par5
; Entry:  --     --     ..    data    ..
; Exit:   --
; -----------------------------------------------
GClrScr: ;does some pre-preparations...
        push hl         ;save hl
        ld   hl,(par5)
        push hl
        ld   hl,(par3)
        push hl

        ld   hl,0000
        ld   (par5),hl     ;Start-Address = 0000h

        ld   hl,MaxGraRAM  ;clear the whole screen
        ld   (par3),hl
        call PutScrRC

        pop  hl
        ld   (par3),hl
        pop  hl
        ld   (par5),hl
        pop  hl
        ret

; ------------------------------------------------------------
; Write to graphic screen from addr to addr+count with 'byte'.
; This could be used to write any byte to graphic screen.
;
; Param: par1  par2    par3   par4  par5
; Entry:  --    --     count  byte  addr
; Exit:   --
; ------------------------------------------------------------
PutScrRC:
        push hl         ;save used register
        push de
        push af
        ld   hl,(par5)  ;check whether addr + count > MaxGraRAM
        ld   de,(par3)  ;get count
        add  hl,de
        ld   de,MaxGraRAM+1
        or   a          ;clear carry
        sbc  hl,de      ;result should be negativ then -> ok
        jr   nc,PutScr2  ;if nc then count + addr > MaxGraRAM

        ld   de,(par5)  ; get start-address
        ld   hl,(par3)  ;Length RAM-Block

PutScr1:
        ld   a,(par4)   ;get byte for clearing
        call WrScrPort  ;write byte to screen
        inc  de         ; incr. screen addr.
        dec  hl         ; decr. byte-count
        ld   a,l
        or   h
        jr   nz,PutScr1  ;are we ready ?
PutScr2:
        pop  af           ;Restore register
        pop  de
        pop  hl
        ret

; ------------------------------------------------
; Read Char-Cell from (addr + (char * 8)) to ChrBuf.
;
; Param: par1 par2  par3   par4   par5
; Entry:  --   --    --    char   addr
; Exit:  hl = points to next 8 byte chr-definition
; ------------------------------------------------
RdChfrAddr:
        push    de
        push    bc
        ld      hl,(par4)       ;get char-code
        ld      h,0
        add     hl,hl           ; * 8
        add     hl,hl
        add     hl,hl
        ex      de,hl
        ld      hl,(par5)       ;get read-addr...
        add     hl,de
        ld      bc,BytePerChr   ;1 char-cell...
        ld      de,ChrBuf       ;to chrbuf
        ldir
        pop     bc
        pop     de
        ret

; ------------------------------------------------
; Write Char-Cell from ChrBuf to (addr + (char * 8)).
;
; Param: par1 par2  par3   par4   par5
; Entry:  --   --    --    char   addr
; Exit:  hl = points to next char-storage position
; ------------------------------------------------
WrChToAddr:
        push    de
        push    bc
        ld      hl,(par4)       ;get char-code
        ld      h,0
        add     hl,hl           ; * 8
        add     hl,hl
        add     hl,hl
        ld      de,(par5)       ;get addr
        add     hl,de           ;calc final addr...
        ex      de,hl           ;swap to de
        ld      hl,ChrBuf       ;read from ChrBuf...
        ld      bc,BytePerChr   ;1 char-cell...
        ldir
        ex      de,hl           ;swap addr of next chr-pos. to hl
        pop     bc
        pop     de
        ret

;#################### BitMap Read/Write Routines ###################
; ------------------------------------------------------------------
; Write Bitmap from addr to Pc(x1;y1,width;hight) on Screen.
; When writing to Screen respect 'TMODE' = 'INV'-Mode, additional
; the written Bitmap is converted from linear BmpMap-Format
; to char-Cell Screen format by 'PutScrByRC' !, so 'PutBmpRC'
; needs only to handle RC-scanline counting, last but not least,
; the aspect ration dur to the rectangulat bit shape is corrected
;
; Param:  par1   par2   par3   par4   par5
; Entry:   x1     y1     x2     y2    addr <= OLD version
; Entry:   x1     y1    width  hight  addr
; Exit:    --
; -------------------------------------------------------------------
WriteBmpRC:
        call    SetDblBit       ;set ctrl-bit for ascpect ratio corr.
        jr      PutBmpRC

; ------------------------------------------------------------------
; Write Bitmap from addr to Pc(x1;y1,width;hight) on Screen.
; When writing to Screen respect 'TMODE' = 'INV'-Mode.
; The written Bitmap is converted from linear BmpMap-Format
; to char-Cell Screen format by 'PutScrByRC' !, so 'PutBmpRC'
; needs only to handle RC-scanline counting.
;
; Param:  par1   par2   par3   par4   par5
; Entry:   x1     y1     x2     y2    addr <= OLD version
; Entry:   x1     y1    width  hight  addr
; Exit:    --
; -------------------------------------------------------------------
PutBmpRC:
        ld      c,00h           ;Set Flag for 'CALL PutScrByRC'
        jr      GetBmpRC0

; ----------------------------------------------------------------------
; Read Bitmap from Pc(x1;y1,width;hight) to addr. Only Char-Mode 'TMODE =
; 'INV' respected !  The read Bitmap is converted from char-Cell
; Screen format to linear BmpMap-Format by 'GetBmpRC', so 'GetBmpRC'
; needs only to handle RC-scanline counting. 'GetScrByRC' does autoincr. of
; 'addr' !. Internal use of param. par2, par3, par4. Restore at exit.
;
; Param: (par1) (par2) (par3) (par4) (par5)
; Entry:   x1     y1    width  hight  addr
; Exit:  RET -1: width = 0; RET -2: hight = 0;
;        RET -3: x1 + width > 79; RET -4: y1 + hight > 29;
; ----------------------------------------------------------------------
GetBmpRC:
        ld      c,0FFh          ;Set Flag for 'CALL GetScrByRC'

GetBmpRC0:
        ld      hl,-1           ;Error, width = 0
        ld      de,(par3)       ;width
        ld      a,d
        or      e
        ret     z               ;ERROR-Return

        ld      hl,-2           ;Error, hight = 0
        ld      de,(par4)       ;hight
        ld      a,d
        or      e
        ret     z               ;ERROR-Return

        ld      hl,-3           ;Error, width > 79
        ld      de,(par3)       ;width
        ld      d,0
        ld      a,e
        and     07Fh            ;block negative numbers
        ld      e,a
        ld      (par3),de       ;restore width
        cp      MaxColumn       ;width > 79 ?
        ret     nc

        ld      hl,-4           ;Error, hight > 29
        ld      de,(par4)       ;hight
        ld      d,0
        ld      a,e
        and     01Fh            ;block negative numbers
        ld      e,a
        ld      (par4),de       ;restore hight
        cp      MaxRow          ;hight > 29 ?
        ret     nc

;Zero-Check OK, continue...
GetBmpRC3:
        ld      hl,(par5)       ;save addr
        push    hl
        ld      hl,(par2)       ;save y1
        push    hl

;transfer Bitmap to addr...
GetBmpRC1:
        ld      b,a             ;CharLine cnt to b
GetBmpRC2:
        ld      a,c             ;IF c = 0 THEN'call PutScrByRC' ?
        or      a
        call    z,PutScrByRC    ;   'call PutScrByRC'  ELSE
        ld      a,c             ;IF a != 0 THEN 'call GetScrByRC' ?
        or      a
        call    nz,GetScrByRC   ;   'call GetScrByRC'
        ld      hl,(par2)
        inc     hl              ;y1 = y1 + 1
        ld      (par2),hl       ;next CharLine
        djnz    GetBmpRC2

;restore param.
        call    ResDblBit       ;auto-clr 'DBLBIT' in 'STAT+1'
        pop     hl
        ld      (par2),hl       ;Restore y1
        pop     hl
        ld      (par5),hl       ;Restore addr
        ld      hl,0            ;return with 'No Error'
        ret

; ------------------------------------------------------
; Read 1 CharLine = 1..80 bytes from Pc(x;y) in 8-byte
; interleave and write data to addr, 'addr' will be auto-
; incr. by 'GetBmpRC'
;
; Param:  par1   par2   par3   par4   par5
; Entry:   x      y      n      --    addr
; Exit:  n bytes from Screen at addr
; ------------------------------------------------------
GetScrByRC:
        push hl         ;save used register
        push de
        push bc
        push af

        call CalcRC     ;calc & set addr. to port & hl
        push hl         ;backup screen addr
        ld   de,(par5)  ;get memory-addr.
        ex   de,hl      ;hl = memory, de = screen
        ld   c,BytePerChr ;8 bytes  per Char as interleave
GetScrBy0:
        ld   a,(par3)   ;get width = n
        ld   b,a
        or   a
        jr   z,GetScrBy2 ;if Length = 0 then do nothing...
        cp   MaxColumn  ;Length > 79 ?
        jr   c,GetScrBy1
        ld   b,MaxColumn ;limit to 80 bytes
GetScrBy1:
        call RdScrPort  ;read byte from screen
        push hl         ;save memory pointer
        ld   hl,STAT
        bit  TMODE,(hl) ;invert Bitmap ?
        jr   z,GetScrBy3
        xor  0FFh       ;  yes
GetScrBy3:
        pop  hl         ;restore memory pointer
        ld   (hl),a     ;write byte to memory addr.
        inc  hl         ;incr. meory addr.
        inc  de         ;incr. screen addr. by 8
        inc  de
        inc  de
        inc  de
        inc  de
        inc  de
        inc  de
        inc  de
        djnz GetScrBy1  ;decr. width count: are we ready ?

        pop  de         ;get start-addr of scanline to de
        inc  de         ;1 byte shift to get in next scanline pos.
        push de         ;put a copy of incr. screen addr to stack
        dec  c
        jr   nz,GetScrBy0 ;are we ready with 8 scanlines ?
        ld   (par5),hl  ;save memory pointer for next data-block
GetScrBy2:
        pop  hl         ;destroy screen addr backup
;
        pop  af         ;Restore register
        pop  bc
        pop  de
        pop  hl
        ret


; ------------------------------------------------------
; Write 1 Charline = 1..80 bytes from addr in 8-byte
; interleave steps to Pc(x;y)
;
; Param:  par1   par2   par3   par4   par5
; Entry:   x      y      n      --    addr
; Exit:    --
; ------------------------------------------------------
PutScrByRC:
        push hl         ;save used register
        push de
        push bc
        push af

        call CalcRC     ;calc & put addr. to port & hl
        push hl         ;backup screen addr
        ld   de,(par5)  ;get memory-addr.
        ex   de,hl      ;hl = memory, de = screen
        ld   c,BytePerChr ;8 bytes  per Char !
PutScrBy0:
        ld   a,(par3)   ;get width = n
        ld   b,a
        or   a
        jr   z,PutScrBy2 ;if Length = 0 then do nothing...
        cp   MaxColumn  ;Length > 79 ?
        jr   c,PutScrBy1
        ld   b,MaxColumn ;limit to 80 bytes
PutScrBy1:
        ld   a,(hl)     ;read from memory addr.
        push hl         ;we need 1 more free reg.
        ld   hl,STAT
        bit  TMODE,(hl) ;invert Bitmap = ON ?
        jr   z,PutScrBy3
        xor  0FFh       ;  yes
PutScrBy3:
        pop  hl
        call ChkDblBit
        call nz,DblBitWrRC ;write 2 Dbl-Bit byte to screen
        jr   nz,PutScrBy4
        call WrScrPort     ;write 'single-bit' byte to screen

PutScrBy4:
        inc  hl         ;incr. memory addr.
        inc  de         ;incr. screen addr. by 8
        inc  de
        inc  de
        inc  de
        inc  de
        inc  de
        inc  de
        inc  de
        djnz PutScrBy1 ;are we with byte-cnt ready ?

        pop  de         ;get start-addr of scanline to de
        inc  de         ;1 byte shift to get in next scanline pos.
        push de         ;put a copy of incr. screen addr to stack
        dec  c
        jr   nz,PutScrBy0 ;are we ready with 8 scanlines ?
        ld   (par5),hl  ;save memory-pointer for next data-block
PutScrBy2:
        pop  hl         ;destroy screen addr backup
;
        pop  af         ;Restore register
        pop  bc
        pop  de
        pop  hl
        ret

;-----------------------------------------------------
;called from 'PutBmpRC' when 'DBLBIT' is set to '1' in
;'STAT+1'
;
;ENTRY:
;'HL' = memory pointer
;'DE' = 'col+0' Screen-Address
;'A'  = Data Byte to scan
;
;EXIT:
;   - 'DE' points to 'col+1'
;-----------------------------------------------------
DblBitWrRC: ;Scan bits in 'a' and double each bit in hl
            ;for aspect ratio correction. Then write both
            ;bytes from HL to screen.
        push    hl
        push    bc
        push    af
        ld      hl,0
        ld      b,7

DblBitWrRC0:
        bit     7,a
        jr      z,DblBitWrRC1
        set     0,l
        set     1,l

DblBitWrRC1:
        add     hl,hl
        add     hl,hl
        sla     a
        djnz    DblBitWrRC0

        bit     7,a
        jr      z,DblBitWrRC2
        set     0,l
        set     1,l

DblBitWrRC2:
        ld      a,h             ;write H-Nibble
        call    WrScrPort       ;write 1st byte to screen
        inc     de              ;incr. screen addr. by 8
        inc     de
        inc     de
        inc     de
        inc     de
        inc     de
        inc     de
        inc     de
        ld      a,l             ;write L-Nibble
        call    WrScrPort       ;write 2nd byte to screen
;
        pop     af
        pop     bc
        pop     hl
        ret

ResDblBit: ;Reset 'DBLBIT' in 'STAT+1', RSX-Internal use ONLY !
        push    hl
        ld      hl,STAT+1
        res     DBLBIT,(hl)
        pop     hl
        ret

SetDblBit: ;Set 'DBLBIT' in 'STAT+1', RSX-Internal use ONLY !
        push    hl
        ld      hl,STAT+1
        set     DBLBIT,(hl)
        pop     hl
        ret

ChkDblBit: ;Set 'DBLBIT' in 'STAT+1', RSX-Internal use ONLY !
        push    hl
        ld      hl,STAT+1
        bit     DBLBIT,(hl)
        pop     hl
        ret

;#################### Input/Output CROM-Data ##################
; -------------------------------------------
; Read n Char from CROM starting w/ chr
; and write data to (addr + 8 * chr) in Memory
;
; Param: par1 par2  par3   par4  par5
; Entry:  --   --    n      chr  addr
; Exit:  Font-Data from CROM at addr
; --------------------------------------------
RdfrFnROM:
        push hl           ;save used register
        push de
        push bc
        push af
        ld   hl,(par4)    ;get char and calc offset into memory
        push hl           ;save start-char.
        ld   h,00         ; limit code range to 0..255
        add  hl,hl
        add  hl,hl
        add  hl,hl
        ld   de,(par5)    ;get Memory-Adr.
        add  hl,de        ;hl holds now (memory + 8 * char)
        ld   de,ChrBuf
        ld   a,(par3)     ;Loop for (par3) = (n) Char. = max. 2040 Byte
        or   a
        jr   z,RdFnROM4   ;if (par3)=0 => do nothing, min. is '1'
        ld   c,a
RdFnROM1:                 ;start with (par4) = Char.
        call RdCROM       ;read 1 Char-Cell into ChrBuf
        ld   de,ChrBuf
        ld   b,8          ;Loop for 8 Byte from ChrBuf
RdFnROM2:                 ;Write 1 Char-Cell to ChrBuf
        ld   a,(de)       ;read from ChrBuf
        ld   (hl),a       ;write to addr
        inc  de
        inc  hl
        dec  b
        jr   nz,RdFnROM2  ;complete Char. read in ?
        ld   a,(par4)     ;prepare for next char.
        inc  a            ;step to next char.
        ld   (par4),a
RdFnROM3:
        dec  c            ;decr. char-counter
        jr   nz,RdFnROM1  ;complete Font-Set read in ?
RdFnROM4:
        pop  hl
        ld   (par4),hl    ;restore start char.
        pop  af           ;Restore register
        pop  bc
        pop  de
        pop  hl
        ret

; --------------------------------------------------
; Read n Char from (addr + 8 * chr)
; and write Char to CROM, replacing n chr's
;
; Param: par1 par2  par3   par4  par5
; Entry:  --   --    n     chr   addr
; Exit:  Font-Data from Memory to CROM
; --------------------------------------------------
WrToFnROM:
        push hl           ;save used register
        push de
        push bc
        push af
        ld   hl,(par4)    ;get start char.
        push hl           ;save start-char.
        ld   h,00         ; limit code range to 0..255
        add  hl,hl
        add  hl,hl
        add  hl,hl
        ld   de,(par5)    ;get Memory-Adr.
        add  hl,de        ;hl holds now (memory + 8 * char)
        ld   a,(par3)     ;Loop for (par3) = (n) Char. := max. 2040 Byte
        or   a
        jr   z,WrFnROM4   ;if (par1)=0 => do nothing, min is '1'
        ld   c,a
WrFnROM1:                 ;start with (par4) = Char.
        ld   de,ChrBuf
        ld   b,8          ;Loop for 8 Byte from ChrBuf
WrFnROM2:
        ld   a,(hl)       ;read char from memory
        ld   (de),a       ;write to ChrBuf
        inc  de
        inc  hl
        dec  b
        jr   nz,WrFnROM2  ;complete Char. read in ?
        call WrCROM       ;write 1 Char-Cell to CROM starting with par4

        ld   a,(par4)     ;prepare for next char. pos.
        inc  a
        ld   (par4),a
WrFnROM3:
        dec  c
        jr   nz,WrFnROM1  ;complete Font-Set read in ?
WrFnROM4:
        pop  hl
        ld   (par4),hl    ;restore start char.
        pop  af           ;Restore register
        pop  bc
        pop  de
        pop  hl
        ret

; ---------------------------------
; Write 1 Char from CROM to ChrBuf
;
; Param: par1 par2  par3   par4  par5
; Entry:  --   --    --     chr   --
; Exit:   --
; ---------------------------------
RdCROM:
        push hl          ;save used register
        push de
        push bc
        push af

        call CROMADDR     ;calc. font-addr

        ; Char-ROM font, HL holds char-addr
        ld   de,ChrBuf
        ld   b,8         ;BytePerChr
        ex   de,hl       ;hl = ChrBuf, de = addr CROM
RdCROM1:
        call RdFntRom    ;get byte from internal/external font-ROM

        inc  hl
        inc  de
        djnz RdCROM1     ;8 times done ?

        pop  af          ;Restore register
        pop  bc
        pop  de
        pop  hl
        ret

; ---------------------------------
; Write 1 Char from ChrBuf to Font-ROM
;
; Param: par1 par2  par3   par4  par5
; Entry:  --   --    --     chr   --
; Exit:   --
; ---------------------------------
WrCROM:
        push hl           ;save used register
        push de
        push bc
        push af

        call CROMADDR     ;calc. font-addr

        ; Char-ROM font, HL holds Char-Addr. into CROM
        ld   de,ChrBuf
        ld   b,8
        ex   de,hl       ;hl points to ChrBuf, de to CROM
WrCROM1:
        call WrFntRom

        inc  hl
        inc  de
        djnz WrCROM1      ;8 times done ?
        pop  af           ;Restore register
        pop  bc
        pop  de
        pop  hl
        ret

CROMADDR:
        ld   hl,(par4)   ; hl = ASCII-Code
        ld   h,00        ;limit Code to 255 max.
        add  hl,hl
        add  hl,hl
        add  hl,hl       ; hl * 8 = Char.Addr. into CROM
        ld   de,(FNTADDR);get ext. font-addr., for internal = 0
        add  hl,de       ;add in ext. font-addr.
        ret

WrFntRom: ;Write to Internal/External Font-ROM
        ld   a,(STAT)
        bit  TXTFNT,a
        jr   nz,WrFntRom1; If 'NZ' THEN external
        ld   a,e
        out  (09Ch),a    ;set Char.-addr. into CROM
        ld   a,d
        out  (09Dh),a
        ld   a,(hl)     ;get char-byte from ChrBuf
        out  (09Eh),a    ; store byte in CROM
        ret
WrFntRom1:
        ld   a,(hl)     ;get char-byte from ChrBuf
        ld   (de),a     ;store byte in ext. Font-ROM
        ret

RdFntRom: ;Read from Internal/External Font-ROM
        ld   a,(STAT)
        bit  TXTFNT,a
        jr   nz,RdFntRom1; If 'NZ' THEN external
        ld   a,e
        out  (09Ch),a    ;set addr into CROM
        ld   a,d
        out  (09Dh),a
        in   a,(09Fh)    ;read char-byte from CROM
        ld   (hl),a      ;store byte in ChrBuf
        ret
RdFntRom1:
        ld   a,(de)     ;get char-byte from ext. Font-ROM
        ld   (hl),a     ;store byte in ChrBuf
        ret

;################# Coordinates Calculation Routines #################
; --------------------------------------------------------------------------------
; Calculate the screen ram address, and the mask for a pixel
; ADDR  = ((XPOS%*(640=1|320=2) AND FFF8h)+(YPOS% AND 07H)+(80*(YPOS% AND FFF8h)))
; MASK  = BMASK%((XPOS% AND PMASK%)+OFFSET%): OFFSET% :=     0 = 320,     4 = 640
;                                             PMASK%  := 0003h = 320, 0007h = 640
;
; Param:  par1    par2     par3    par4    par5
; Entry:   x       y        --      --      --
; Exit:  hl =  addr, port(96h,97h) = addr, a = bmask
; --------------------------------------------------------------------------------
CalcXY: ;(XPOS*(640px=1|320px=2) AND FFF8h)...
        push de                 ;save used reg. for caller
        ld  hl,(par1)           ;get XPOS
        ld  a,(STAT)            ;load Graphic-Status Byte
        bit SCREEN,a            ;Test Screen-Resol.: 0=320|1=640
        jr  nz,Calc0            ;nz = 640px; z = 320px
        add hl,hl               ;if Bit0 = 1 -> XPOS * 2
Calc0:  ld a,l
        and 11111000b           ;mask off Bit(2..0) = Bit-Number
        ld l,a

        ;...+(YPOS AND 07H)
        ld   de,(par2)          ;do: YPOS AND 07H
        ld   a,00000111b        ;mask off bit(7..3) = row
        and  e
        ld   e,a
        ld   d,00000000b

        add  hl,de
        push hl                 ;save (XPOS*(Nwidth=1|Dwidth=2) AND FFF8h)

        ;...+(80*(YPOS AND FFF8h)
        ld   hl,(par2)          ;YPOS(high)
        ld   a,11111000b        ;YPOS(low)
        and  l                  ;set Scan-line per Char. = 0
        ld   l,a
        add  hl,hl              ; * 2
        add  hl,hl              ; * 4
        add  hl,hl              ; * 8
        add  hl,hl              ; * 16
        push hl
        add  hl,hl              ; * 32
        add  hl,hl              ; * 64
        pop  de
        add  hl,de              ;now it's (YPOS * 80)
        pop  de                 ;get back ((XPOS*(320=2|640=1) AND FF80h)+(YPOS% AND 07H)
        add  hl,de              ;finalize calculation and
        push hl                 ;  save addr on stack
        ex    de,hl
        call  RdScrPort         ;only to set port-addr (expected by Pixel-
        ex    de,hl             ;   Operation and others)
;                                                               (640|320)
CalcXYMask:  ; BMASK = ((XPOS AND PMASK(07h|03h))+OFFSET(4|0);  (1Px|2Px)
        ld   a,(par1)           ;XPOS-low, XPOS-high not important
        ld   hl,STAT            ;load 'STAT'-pointer into hl
        bit  SCREEN,(hl)        ;determine PMASK(0=320|1=640) Pixel-Mode
        jr   z,cgaXY            ;if SCREEN=1 => 1Px then goto CalcXY2
        and  07h                ;   mask off bit(2..0) for '640'
        add  a,04h              ;   add offset for Nwidth Pixel-Mode
        jr   vgaXY              ;goto vgaXY
cgaXY:
        and  03h                ;   Mask off bit(1..0) for '320'
vgaXY:
        ld   d,00h              ;set d=0 HByte of addr for Bit-Masks
        ld   e,a                ;bit-index to e, next calc. Bit-Masks address
        ld   hl,BitMask320      ;Pointer to Bit-Mask array
        add  hl,de
        ld   a,(hl)             ;get Bit-Mask
        pop  hl                 ;hl = addr (saved on stack)

CalcXYEnd:
        pop  de                 ;restore de from caller
        ret

; -------------------------------------------------
; Calculate the ram-address of the chr-cell on Screen:
; addr  = (8 * XPOS + 640*YPOS
;
; Entry:  par1   par2   par3   par4   par5
; Entry:   x      y      --     --     --
; Exit:  hl = addr, port(low,high) = addr
; -------------------------------------------------
CalcRC: ;8 * XPOS + ...
        push de
        push bc
        push af

        ;(xpos * 8)
        ld  hl,(par1)     ; row
        add hl,hl         ; * 2
        add hl,hl         ; * 4
        add hl,hl         ; * 8
        push hl           ; save XPOS*8

        ;(YPOS*640)
        ld    hl,(par2)   ; get col.

CalcRC1:
        add   hl,hl       ; * 2
        add   hl,hl       ; * 4
        add   hl,hl       ; * 8
        add   hl,hl       ; * 16
        add   hl,hl       ; * 32
        add   hl,hl       ; * 64
        add   hl,hl       ; * 128
        push  hl
        add   hl,hl       ; * 256
        add   hl,hl       ; * 512
        pop   de          ; + 128
        add   hl,de       ; = 640*YPOS
        pop   de          ;get (XPOS*8) back
        add   hl,de       ;addr = (XPOS*8) + (640*YPOS)
        ex    de,hl
        call  RdScrPort   ;only to set port-addr, we drop a
        ex    de,hl       ; hl = return value
CalcRC2:
        pop  af           ;Restore register
        pop  bc
        pop  de
        ret

; ----------------------------------------------------
; Draw a Line starting at Px(x0,y0) with 'width' &
; 'hight' on Screen:
;
; Entry:  par1   par2   par3   par4   par5
; Entry:   x0     y0     --    width  hight
; Exit:    --
; ----------------------------------------------------
FnLine2:
;Calculate Px(X1,Y1) from Px(X0,Y0) & (width,hight)
        ld      hl,(width)
        push    hl
        ld      de,(X0)
        add     hl,de
        ld      (X1),hl
;
        ld      hl,(hight)
        push    hl
        ld      de,(Y0)
        add     hl,de
        ld      (Y1),hl
;
;Draw now the line
        call    FnLine
;
;Restore 'width' & 'hight'
        pop     hl
        ld      (hight),hl
        pop     hl
        ld      (width),hl
;
        ret


; ----------------------------------------------------
; Draw a Line from Px(x0,y0) to Px(x1,y1) on GScreen:
;
; Entry:  par1   par2   par3   par4   par5
; Entry:   x0     y0     --     x1     y1
; Exit:    --
; ----------------------------------------------------
VarFnLne:
X0      equ     par1
Y0      equ     par2
CHAR    equ     par3
X1      equ     par4
Y1      equ     par5
XE:     defw    0
YE:     defw    0
DX:     defw    0
DY:     defw    0
AA:     defw    0
BB:     defw    0
FZ:     defw    0
xstep:  defw    0
ystep:  defw    0

FnLine:
;do some savings and precalculation...
        ld      hl,(par1)       ;X0
        push    hl              ;save X0
        ld      hl,(par2)       ;Y0
        push    hl              ;save Y0
        ld      hl,(par4)       ;X1
        push    hl              ;save X1

CkLnStyle:
        call    SetRotON        ;activate Pat.-rotation
        ld      a,(STAT+1)
        bit     USEPAT,a        ;do we use dashed/dotted Lines ?
        jr      z,CkHiRes       ;'z' = No
        ld      hl,(SELPAT)
        ld      (LNEPAT),hl     ;do restart pattern
CkHiRes:
        ld      a,(STAT)        ;get STAT for Resol. Bits
        bit     HIRES,a
        jr      z,NoHiRes       ;IF nz THEN HiRes DO...
                                ;   double Line-Length for
        ld      hl,(X0)         ;   X0 = Start-Point
        add     hl,hl
        ld      (X0),hl
        ld      hl,(X1)         ;   X0 = End-Point
        add     hl,hl
        ld      (X1),hl
NoHiRes:
        ;XE=X1
        ld      de,(X1)
        ld      (XE),de
        ;DX=X1-X0
        ld      hl,(X1)
        ld      de,(X0)
        or      a
        sbc     hl,de
        ld      (DX),hl

        ;YE=Y1
        ld      de,(Y1)
        ld      (YE),de

        ;DY=Y1-Y0
        ld      hl,(Y1)
        ld      de,(Y0)
        or      a
        sbc     hl,de
        ld      (DY),hl

        ;preset: xstep=1; ystep=1
        ld      hl,0001
        ld      (xstep),hl
        ld      (ystep),hl

;determine in witch quadrant we are working...
;IF DX < 0 THEN DX = -DX; xstep = -1
TstDX:  ld      a,(DX+1)        ;get HByte of DX
        bit     7,a
        jr      z,TstDY

        ;xstep = -1
        ld      hl,-1
        ld      (xstep),hl

        ;DX = -DX
        ld      hl,0
        ld      de,(DX)
        or      a
        sbc     hl,de
        ld      (DX),hl

;IF DY < 0 THEN DX = -DX; ystep = -1
TstDY:  ld      a,(DY+1)        ;get HByte of DY
        bit     7,a
        jr      z,LPIncX

        ;ystep = -1
        ld      hl,-1
        ld      (ystep),hl

        ;DY = -DY
        ld      hl,0
        ld      de,(DY)
        or      a
        sbc     hl,de
        ld      (DY),hl

;Set the linepath increment...
;AA=DX+DX
LPIncX: ld      hl,(DX)
        add     hl,hl
        ld      (AA),hl

;BB=DY+DY
LPIncY: ld      hl,(DY)
        add     hl,hl
        ld      (BB),hl

;Calculate wether we should go on in Y or X direction...
;IF DY <= DX THEN FZ = -DX; WHILE ...
        ld      hl,(DY)
        ld      de,(DX)
        inc     de              ;carry only if DX > DY
        or      a
        sbc     hl,de
        jr      c,_FZMDX
        jp      ELSE1           ;Goto ELSE1

        ;FZ = -DX
_FZMDX: ld      de,(DX)
        ld      hl,0
        or      a
        sbc     hl,de
        ld      (FZ),hl

;WHILE X0 <> XE
_WHILE1:
        ld      hl,(X0)
        ld      de,(XE)
        or      a
        sbc     hl,de
        ld      a,h
        or      l
        jr      z,WEND1         ;IF X0 = XE THEN Goto WEND1

;Plot Point and prepare next round...
        call    PltPix          ;Plot Pixel according to 'STAT'
        ;FZ = FZ + BB
        ld      de,(FZ)
        ld      hl,(BB)
        add     hl,de
        ld      (FZ),hl

;IF FZ > 0 THEN
        bit     7,h
        jr      nz,ENDIF1       ;IF FZ < 0 THEN Goto ENDIF1
        ld      a,h
        or      l
        jr      z,ENDIF1        ;IF FZ = 0 THEN Goto ENDIF1

        ;FZ = FZ - AA
        ld      hl,(FZ)
        ld      de,(AA)
        or      a
        sbc     hl,de
        ld      (FZ),hl

        ;Y0 = Y0 + YSTEP
        ld      hl,(Y0)
        ld      de,(ystep)
        add     hl,de
        ld      (Y0),hl
ENDIF1:
        ;X0 = X0 + xstep
        ld      hl,(X0)         ;X0
        ld      de,(xstep)      ;xstep
        add     hl,de
        ld      (X0),hl

        jp      _WHILE1         ;Next turne
WEND1:  jp      WEND2           ;Goto EndLine, we are ready...

ELSE1:
        ; FZ = -DY
        ld      hl,0
        ld      de,(DY)
        or      a
        sbc     hl,de
        ld      (FZ),hl

;WHILE Y0 <> YE
_WHILE2:
        ld      hl,(Y0)         ;Y0
        ld      de,(YE)         ;YE
        or      a
        sbc     hl,de           ;Y0 - YE
        ld      a,h
        or      l
        jr      z,WEND2         ;IF Y0 = YE THEN Goto WEND2

;Plot Point and prepare next round...
        call    PltPix          ;Plot Pixel according to 'STAT'
        ;FZ = FZ + AA
        ld      hl,(FZ)
        ld      de,(AA)
        add     hl,de
        ld      (FZ),hl

;IF FZ > 0 THEN
        bit     7,h
        jr      nz,ENDIF2       ;IF bit[15] = 1 THEN Goto ENDIF2
        ld      a,l
        or      h
        jr      z,ENDIF2        ;IF FZ = 0 THEN Goto ENDIF2

        ;FZ = FZ - BB
        ld      hl,(FZ)
        ld      de,(BB)
        or      a
        sbc     hl,de
        ld      (FZ),hl         ;FZ = FZ - BB

        ;X0 = X0 + xstep
        ld      hl,(X0)         ;X0
        ld      de,(xstep)      ;xstep
        add     hl,de
        ld      (X0),hl         ;X0 = X0 + xstep

ENDIF2:
        ;Y0 = Y0 + ystep
        ld      hl,(Y0)
        ld      de,(ystep)
        add     hl,de
        ld      (Y0),hl
        jp      _WHILE2         ;next turne
WEND2:
        call    PltPix          ;Set last Pixel
LnRetrn:
        pop     hl              ;Restore some coord. data
        ld      (par4),hl
        pop     hl
        ld      (par2),hl
        pop     hl
        ld      (par1),hl
        ld      hl,0            ;RET = TRUE
        ret

; ------------------------------------------------------------------
; Draw a Box from Px(x0,y0) to Px(x0+width-1,y0+hight-1) on Screen:
;
; Entry:  par1   par2   par3   par4   par5
; Entry:   x0     y0     --    width  hight
; Exit:    --
; ------------------------------------------------------------------
VarFnBox:
;Symbolic names for par1..5 from FNLine
;'LoadPat' & 'RotPatON/OFF' are done by 'FnLine'
X2:     defw    0
Y2:     defw    0
X3:     defw    0
Y3:     defw    0
X4:     defw    0  ;for FnTriangle
Y4:     defw    0  ;for FnTriangle

;1st box side: Px(X2,Y2;X3,Y2)
;2nd box side: Px(X2,Y2;X2,Y3)
;3rd box side: Px(X2,Y3;X3,Y3)
;4th box side: Px(X3,Y3;X3,Y2)

FnBox:
;Backup Box-Parameters...
        ld      hl,(par1)       ;X0
        ld      (X2),hl         ;   -> X2

        ld      de,(par4)       ;X0 + width
        push    de              ;save width
        add     hl,de
        dec     hl
        ld      (X3),hl         ;   -> X3

        ld      hl,(par2)       ;Y0
        ld      (Y2),hl         ;   -> Y2

        ld      de,(par5)       ;Y1 + hight
        push    de              ;save hight
        add     hl,de           ;
        dec     hl              ;
        ld      (Y3),hl         ;   -> Y3

;1st side: Px(X2,Y2;X3,Y2)
        ld      hl,(X2)
        ld      (X0),hl
        ld      hl,(X3)
        ld      (X1),hl
        ld      hl,(Y2)
        ld      (Y0),hl
        ld      hl,(Y2)
        ld      (Y1),hl
        call    FnLine

;2nd side: Px(X2,Y2;X2,Y3)
;       ld      hl,(X2)
;       ld      (X0),hl
        ld      hl,(X2)
        ld      (X1),hl
;       ld      hl,(Y2)
;       ld      (Y0),hl
        ld      hl,(Y3)
        ld      (Y1),hl
        call    FnLine

;3rd side: Px(X2,Y3;X3,Y3)
;       ld      hl,(X2)
;       ld      (X0),hl
        ld      hl,(X3)
        ld      (X1),hl
        ld      hl,(Y3)
        ld      (Y0),hl
;       ld      hl,(Y3)
;       ld      (Y1),hl
        call    FnLine

;4th side: Px(X3,Y3;X3,Y2)
        ld      hl,(X3)
        ld      (X0),hl
;       ld      hl,(X3)
;       ld      (X1),hl
;       ld      hl,(Y3)
;       ld      (Y0),hl
        ld      hl,(Y2)
        ld      (Y1),hl
        call    FnLine

;Restore Parameters...
        ld      hl,(X2)
        ld      (X0),hl         ;restore X0
        ld      hl,(Y2)
        ld      (Y0),hl         ;restore Y0

        call    ResQuad         ;Reset Plot-Quadrant Selection to 'ALL'
        pop     hl
        ld      (Y1),hl         ;restore hight
        pop     hl
        ld      (X1),hl         ;restore width

BoxEnd: ret

;===============================================================
;======              Package Name: Math32.asm           ========
;===============================================================
;
;  Stack-Organization:
;  ===================
;  TOP-1  TOP      TOP
;   OP1   OP2  -> RESULT
;
;  MATH-OPERATION:
;  ===============
;  (TOP-1) +-/* (TOP) = (TOP)
;
;All math operations are handled on the stack. Due to fact,
;that the routines are FORTH-like, the CALL/RET procedure is
;a little bit "strange". After PUSHing all operants onto the stack,
;the subroutine is called. The return address is now on TOP of the
;stack and has to be removed to a register. The IY-register isn't
;used, so it can hold the return address. The final "RET" is then
;done by a "JP (IY)" as a walkaround. IX is used as Variable pointer,
;pointing to the low byte of the loaded/stored variable.

;======================================================
;================ Math32 Main-Routines ================
;======================================================

;        ; TOP = TOP-1  TOP
;ADD:    ;<HL> = <HL> + <DE>

;        ; TOP = TOP-1  TOP
;DADD:   ;<HLHL> = <HLHL> + <BCDE>

;        ; TOP = TOP-1  TOP
;SUB:    ;<HL> = <HL> - <DE>

;        ; TOP = TOP-1  TOP
;DSUB:   ;<HL> = <HL> - <DE>

;        ;  TOP   =  TOP    TOP-1
;MUL32:  ;<HL'HL> = BC'BC * DE'DE


;======================================================
;=============== Math32 Support-Routinen ==============
;======================================================

;PUSH16:   ;Load <HLDE> with 16-Bit sign extend variable and push to stack

;POP16:    ;POP a operand from stack and store to 16-bit variable

;PUSH32:   ;Get 32-bit variable and push to stack

;POP32:    ;Pop operand from stack and storeto 32-bit variable

;RLOAD16:  ;load <HLDE> with 16-bit sign-extended variable from RAM

;RSTORE16: ;Store <DE> to 16-bit variable in RAM

;RLOAD32:  ;Load a 32-bit variable from RAM to <HLDE>

;RSTORE32: ;Store <HLDE> to 32-bit variable in RAM

;DUP32:    ;TOP -> TOP TOP

;OVER32:   ;TOP-1 TOP -> TOP-1 TOP TOP-1

;SWAP32:   ;TOP-1 TOP -> TOP TOP-1

;ROT32:    ;TOP-2 TOP-1 TOP -> TOP-1 TOP TOP-2

;LSHIFT32  ;<HLDE> = <HLDE> << 1
;IFGT32    ;IFV TOP-1 > TOP THEN...
;IFLT32    ;IFV TOP-1 < TOP THEN...
;IFEQ32    ;IFV TOP-1 = TOP THEN...

;######################################################################
;########################## CONSTANT VALUES ###########################
;######################################################################

;-----------------------------------------------------
; Load some 32-bit Constants: 1, 2, 4, 6
;-----------------------------------------------------
LDZERO: pop     iy
        ld      de,0000
        jr      LD0NE0

LDONE:  pop     iy
        ld      de,0001
LD0NE0: ld      hl,0000
        push    de
        push    hl
        jp      (iy)
;
LDTWO:  pop     iy
        ld      de,0002
        jr      LD0NE0
;
LDFOUR: pop     iy
        ld      de,0004
        jr      LD0NE0
;
LDSIX:  pop     iy
        ld      de,0006
        jr      LD0NE0

;######################################################################
;################ 16-bit LOAD/STORE Stack Operations ##################
;######################################################################
;----------------------------------------------------
; Entry: (IX) points to 16-bit variable. Variable will
;        sign-extended before pushing to stack
; Exit:  TOP <- <SSDE> <- VAR(DE)
;----------------------------------------------------
        ;Load a Variable and PUSH to stack
PUSH16: ;IX points low byte of 16-bit data
          pop     IY
          call    RLOAD16
          push    de
          push    hl
          jp      (IY)

;----------------------------------------------------
; Entry: (IX) points to 16-bit variable. Variable will
;        be trancated to 16 bit when strored
; Exit:  TOP -> VAR(DE)
;----------------------------------------------------
POP16:  ;POP a operand and Store to Variable
        ;IX points low byte of 16-bit data
          pop     IY
          pop     hl
          pop     de
          call    RSTORE16
          jp      (IY)

;----------------------------------------------------
; Entry: (IX) points to 16-bit variable. Variable will
;        be sign-extended and stored in <HLDE>
; Exit:  <HLDE> <- <SSDE> <- (IX)
;----------------------------------------------------
RLOAD16: ;load a 16-bit sign-extendet Variable from RAM
          ld      e,(ix+0)
          ld      d,(ix+1)
          ld      hl,0
          bit     7,d           ;<de> = positive ?
          ret     z
          ld      hl,-1         ;<hl> = negative !
          ret

;----------------------------------------------------
; Entry: (IX) points to 16-bit variable. Operand will
;        be trancated to 16 bit when strored
; Exit:  <SSBC> -> (IX) ->VAR(DE)
;----------------------------------------------------
RSTORE16: ;Store a operand to 16-bit Variable
          ld      (ix+0),e
          ld      (ix+1),d
          ret

;######################################################################
;################ 32-bit LOAD/STORE Stack Operations ##################
;######################################################################
;----------------------------------------------------
; Entry: (IX) points to 32-bit variable. Variable will
;        be pushed to stack
; Exit:  TOP <- (IX)
;----------------------------------------------------
PUSH32: ;IX points to 32-bit variable
          pop     IY
          call    RLOAD32        ;VAR-Addr. in (IX)
          push    de
          push    hl
          jp      (IY)

;----------------------------------------------------
; Entry: (IX) points to 32-bit variable. TOP will
;        be stored to (IX)
; Exit:  TOP -> (IX)
;----------------------------------------------------
POP32:;IX points to 32-bit variable
          pop     IY
          pop     hl
          pop     de
          call    RSTORE32       ;VAR-Addr. in (IX)
          jp      (IY)

;######################################################################
;############ Special functions for multiply by 2 or by 4 #############
;######################################################################
;----------------------------------------------------
; Entry: 32-bit variable will be pushed to stack
; Exit:  TOP <- (HLDE)
;----------------------------------------------------
RPUSH32: ;PUSH <HLDE> to stack
          pop     IY
          push    de
          push    hl
          jp      (IY)

;----------------------------------------------------
; Entry: 32-bit variable will be poped to <HLDE>
; Exit:  TOP -> (HLDE)
;----------------------------------------------------
RPOP32:  ;Load 32-bit TOP into <HLDE>
          pop     IY
          pop     hl
          pop     de
          jp      (IY)

;----------------------------------------------------
; Entry: (IX) points to 32-bit variable. Variable will
;        be loaded to <DEBC>
; Exit:  <DEBC> <- (IX)
;----------------------------------------------------
RLOAD32: ;load a 32-bit variable from RAM to <DEBC>
          ld    e,(ix+0)
          ld    d,(ix+1)
          ld    l,(ix+2)
          ld    h,(ix+3)
          ret

;----------------------------------------------------
; Entry: (IX) points to 32-bit variable. <DEBC> will
;        be strored in variable IX is is pointing to.
; Exit:  TOP <- <SSBC>
;----------------------------------------------------
RSTORE32:;store <DEBC> to 32-bit variable in RAM
          ld      (ix+0),e
          ld      (ix+1),d
          ld      (ix+2),l
          ld      (ix+3),h
          ret

;;=================================================
;; Shift <HLDE> left 1 Bit
;;=================================================
LSHIFT32: ;Shift 32-bit value 1 bit left
          and   a               ;HL = HWORD, DE = LWORD
          ex    de,hl           ;start with LWORD
          adc   hl,hl           ;get LResult
          ex    de,hl           ;switch to HWORD
          adc   hl,hl           ;get HResult
          ret

;######################################################################
;################### 16-bit & 32-bit math functions ###################
;######################################################################
;        ; TOP = TOP-1 + TOP
;ADD16:  ;<HL> = <HL>  + <DE>
;          POP     IY            ;retrive return address
;          POP     DE            ;2nd OP
;          POP     HL            ;1st OP
;          ADD     HL,DE
;          PUSH    HL            ;Result to Stack
;          JP      (IY)          ;return via IY

        ; TOP = TOP-1 + TOP
;SUB16:  ;<HL> = <HL>  + <DE>
;          POP     IY            ;retrive return address
;          POP     DE            ;2nd OP
;          POP     HL            ;1st OP
;          AND     A
;          SBC     HL,DE
;          PUSH    HL            ;Result to Stack
;          JP      (IY)          ;return via IY

        ; TOP   = TOP-1  +  TOP
DADD:   ;<HLHL> = <HLHL> + <BCDE>
          POP     IY            ;retrive return address
          POP     BC            ;HWord
          POP     DE            ;LWord
          POP     HL            ;HWord
          EX      (SP),HL       ;get LWORD first
          ADD     HL,DE
          EX      (SP),HL       ;LResult to Stack
          ADC     HL,BC
          PUSH    HL            ;HResult to Stack
          JP      (IY)          ;return via IY

        ; TOP   =  TOP-1 -  TOP
DSUB:   ;<HLHL> = <HLHL> - <BCDE>
          POP     IY            ;retrive return address
          POP     BC            ;HWord
          POP     DE            ;LWord
          POP     HL            ;HWord
          EX      (SP),HL       ;get LWORD first
          XOR     A
          SBC     HL,DE
          EX      (SP),HL       ;LResult to Stack
          SBC     HL,BC
          PUSH    HL            ;HResult to Stack
          JP      (IY)          ;return via IY

;==================================================
; MULTIPLY ROUTINE 32*32BIT=32BIT
; H'L'HL = B'C'BC * D'E'DE
; NEEDS ALL REGISTERS & A, CHANGES FLAGS
;==================================================
MUL32: ;get 32-bit operands...
        pop     IY
        POP     BC              ; B'C' = 2st OP H-WORD
        EXX
        POP     BC              ; BC   = 2st OP L-WORD
        EXX
        POP     DE              ; D'E' = 1nd OP H-WORD
        EXX
        POP     DE              ; DE   = 1nd OP L-WORD
                                ;Now do: LWord1 * LWORD2
;--------------------------------------------------------------
        AND     A               ; RESET CARRY FLAG
        SBC     HL,HL           ; LOWER RESULT = 0
        EXX
        SBC     HL,HL           ; HIGHER RESULT = 0
        LD      A,B             ; MPR IS AC'BC
        LD      B,32            ; INITIALIZE LOOP COUNTER
MUL32LOOP:
        SRA     A               ; RIGHT SHIFT MPR
        RR      C
        EXX
        RR      B
        RR      C               ; LOWEST BIT INTO CARRY
        JR      NC,MUL32NOADD
        ADD     HL,DE           ; RESULT += MPD
        EXX
        ADC     HL,DE
        EXX
MUL32NOADD:
        SLA     E               ; LEFT SHIFT MPD
        RL      D
        EXX
        RL      E
        RL      D
        DJNZ    MUL32LOOP
        EXX

; RESULT IN H'L'HL
        PUSH    HL              ;LResult to Stack
        EXX
        PUSH    HL              ;HResult to Stack
        JP      (IY)


;;##################################################################
;;######################## Stack Operations  #######################
;;##################################################################
;
;;;=================================================
;;; {TOP-1} {TOP} -> {TOP-1} {TOP} {TOP-1}
;;; HLDE = TOP
;;;=================================================
;OVER32: ;Duplicate a 32-bit value on stack
;        pop     iy      ;get return address
;        pop     hl      ;get top
;        pop     de
;        exx
;        pop     hl      ;get top-1
;        pop     de
;        push    de      ;push top-1
;        push    hl
;        exx
;        push    de      ;push top
;        push    hl
;        exx
;        push    de      ;push top-1
;        push    hl
;        EXX             ;now TOP in HLDE
;        jp      (iy)    ;return to caller
;
;;;=================================================
;;; {TOP} -> {TOP} {TOP}
;;; HLDE = TOP
;;;=================================================
;DUP32: ;Duplicate a 32-bit value on stack
;        pop     iy      ;get return address
;        pop     hl      ;get top
;        pop     de
;        push    de      ;push top
;        push    hl
;        push    de      ;push top
;        push    hl
;        jp      (iy)    ;return to caller
;
;;;=================================================
;;; {TOP-1} {TOP} -> {TOP} {TOP-1}
;;;=================================================
;SWAP32: ;Duplicate a 32-bit value on stack
;        pop     iy      ;get return address
;        pop     hl      ;get top
;        pop     de
;        exx
;        pop     hl      ;get top-1
;        pop     de
;        exx
;        push    de      ;push top
;        push    hl
;        exx
;        push    de      ;push top-1
;        push    hl
;        EXX             ;now TOP-1 in HLDE
;        jp      (iy)    ;return to caller
;
;;;=================================================
;;; {TOP-2} {TOP-1} {TOP} -> {TOP-1} {TOP} {TOP-2}
;;;=================================================
;ROT32: ;Duplicate a 32-bit value on stack
;        pop     iy      ;get return address
;        pop     hl      ;get top
;        pop     de
;        exx
;        pop     hl      ;get top-1
;        pop     de
;        exx
;        pop     bc      ;get TOP-2H
;        exx
;        pop     bc      ;get TOP-2L
;        push    de      ;push top-1
;        push    hl
;        exx
;        push    de      ;push top
;        push    hl
;        exx
;        push    bc      ;get TOP-2L
;        exx
;        push    bc      ;get TOP-2H
;        jp      (iy)    ;return to caller
;
;
;##################################################################
;############# Logical Operations IF OP1 {>|<|==} OP2 #############
;##################################################################

;;=================================================
;; long HLHL, DEDE;
;;  char A;
;;
;;  HLHL = {TOP-1};
;;  DEDE = {TOP};
;;  if (HLHL == DEDE) {
;;    A = 1;
;;  } else {
;;    A = 0;
;;  }
;;
;==================================================
;IFEQ32:
;        POP     IY
;        POP     DE              ;DE = HByte  \       ;
;        EXX                     ;             > {TOP}
;        POP     DE              ;DE' = LByte /
;        EXX                     ;x
;        POP     HL              ;HL = HByte  \        ;
;        EXX                     ;             > {TOP-1}
;        POP     HL              ;HL' = LByte /
;
;                                ;Now do: LWord1 - LWORD2
;        AND     A               ; if (HLHL == DEDE)
;        SBC     HL,DE           ;LWord1 - LWORD2
;        JR      NZ,ELSE321      ;LWords are the same ?
;        EXX                     ;Next is L-WORDs
;        SBC     HL,DE           ;HWord1 - HWORD2
;;
;        JR      NZ,ELSE321      ;HWords are the same ?
;
;        LD      A,-1            ;YES -> A = TRUE;
;        JR      ENDIF321
;ELSE321:                        ;else
;        LD      A,0             ;  NO  -> A = FALSE;
;ENDIF321:                       ;
;        and     a               ;set Z-Flag
;        JP      (IY)


;;=================================================
;; long HLHL, DEDE;
;;  char A;
;;
;;  HLHL = {TOP-1};
;;  DEDE = {TOP};
;;  if (HLHL < DEDE) {
;;    A = 1;
;;  } else {
;;    A = 0;
;;  }
;;
;==================================================
;IFLT32:
;        POP     IY
;        POP     DE              ;DE = HByte  \       ;
;        EXX                     ;             > {TOP}
;        POP     DE              ;DE' = LByte /
;        EXX                     ;
;        POP     HL              ;HL = HByte  \        ;
;        EXX                     ;             > {TOP-1}
;        POP     HL              ;HL' = LByte /
;
;                                ;Now do: LWord1 - LWORD2
;        AND     A               ;if (HLHL < DEDE)
;        SBC     HL,DE           ;LWord1 - LWORD2
;        EXX
;        SBC     HL,DE           ;HWord1 - HWORD2
;;
;        JP      P,ELSE322       ;IF 'P' THEN (HLHL) > (DEDE) -> FALSE
;        JR      Z,ELSE322       ;IF 'Z' THEN (HLHL) = (DEDE) -> FALSE
;;
;        LD      A,-1            ;YES -> A = TRUE;
;        JR      ENDIF322
;ELSE322:                        ;else
;        LD      A,0             ;NO  -> A = FALSE;
;ENDIF322:                         ;
;        and     a               ;set Z-Flag
;        JP      (IY)

;;=================================================
;; long HLHL, DEDE;
;;  char A;
;;
;;  HLHL = {TOP-1};
;;  DEDE = {TOP};
;;  if (HLHL <= DEDE) {
;;    A = 1;
;;  } else {
;;    A = 0;
;;  }
;;
;==================================================
IFLE32:
        POP     IY
        POP     DE              ;DE = HByte  \       ;
        EXX                     ;             > {TOP}
        POP     DE              ;DE' = LByte /
        EXX                     ;
        POP     HL              ;HL = HByte  \        ;
        EXX                     ;             > {TOP-1}
        POP     HL              ;HL' = LByte /

                                ;Now do: LWord1 - LWORD2
        AND     A               ;if (HLHL < DEDE)
        SBC     HL,DE           ;LWord1 - LWORD2
        EXX
        SBC     HL,DE           ;HWord1 - HWORD2
;
        JP      M,TRUE324       ;{TOP-1} - {TOP} < '0' => is 'LT' test
        LD      A,H
        OR      L
        EXX                     ;Operate on HL' Reg. set
        OR      H
        OR      L
        EXX                     ;Back to HL Reg. set
        JR      Z,TRUE324       ;32-Bit Result = '0' ? => is 'EQ' test
;
FALSE324:
        LD      A,0             ;NO  -> A = FALSE;
        JR      ENDIF324
TRUE324:
        LD      A,-1            ;YES -> A = TRUE;
ENDIF324:                         ;
        and     a               ;set Z-Flag
        JP      (IY)

;;=================================================
;; long HLHL, DEDE;
;;  char A;
;;
;;  HLHL = {TOP-1};
;;  DEDE = {TOP};
;;  if (HLHL > DEDE) {
;;    A = 1;
;;  } else {
;;    A = 0;
;;  }
;;
;==================================================
;IFGT32: ;OP1 > OP2 => {TOP-1} - {TOP} > 0
;        POP     IY
;        POP     DE              ;DE = HByte  \       ;
;        EXX                     ;             > {TOP}
;        POP     DE              ;DE' = LByte /
;        EXX                     ;x
;        POP     HL              ;HL = HByte  \        ;
;        EXX                     ;             > {TOP-1}
;        POP     HL              ;HL' = LByte /
;
;                                ;Now do: LWord1 - LHWORD2
;        AND     A               ;if (HLHL > DEDE)
;        SBC     HL,DE           ;LWord1 - LWORD2
;        EXX
;        SBC     HL,DE           ;HWord1 - HWORD2
;;
;        JP      M,FALSE323      ;IF 'M'  THEN (HLHL) < (DEDE) -> FALSE
;        LD      A,H
;        OR      L
;        EXX                     ;Operate on HL' Reg. set
;        OR      H
;        OR      L               ;IF 'NZ' THEN (HLHL') > '0' -> TRUE
;        EXX                     ;Back to HL Reg. set
;        JR      NZ,TRUE324      ;32-Bit Result > '0' ? => is 'GT' test
;;
;FALSE323:
;        LD      A,0             ; (HLHL) <= (DEDE) -> A = FALSE;
;        JR      ENDIF323
;TRUE323:
;        LD      A,-1            ; (HLHL) > (DEDE) -> A = TRUE;
;ENDIF323:
;        and     a               ;set Z-Flag
;        JP      (IY)

;;=================================================
;; long HLHL, DEDE;
;;  char A;
;;
;;  HLHL = {TOP-1};
;;  DEDE = {TOP};
;;  if (HLHL >= DEDE) {
;;    A = 1;
;;  } else {
;;    A = 0;
;;  }
;;
;==================================================
IFGE32: ;OP1 >= OP2 => {TOP-1} >= {TOP} !!!
        POP     IY
        POP     DE              ;DE = HByte  \       ;
        EXX                     ;             > {TOP}
        POP     DE              ;DE' = LByte /
        EXX                     ;x
        POP     HL              ;HL = HByte  \        ;
        EXX                     ;             > {TOP-1}
        POP     HL              ;HL' = LByte /

                                ;Now do: LWord1 - LHWORD2
        AND     A               ;if (HLHL > DEDE)
        SBC     HL,DE           ;LWord1 - LWORD2
        EXX
        SBC     HL,DE           ;HWord1 - HWORD2
;
        JP      M,ELSE325       ;IF 'M' THEN (HLHL) < (DEDE) -> FALSE
;
        LD      A,-1            ; (HLHL) > (DEDE) -> A = TRUE;
        JR      ENDIF325
ELSE325:                        ;else
        LD      A,0             ; (HLHL) < (DEDE) -> A = FALSE;
ENDIF325:                         ;
        and     a               ;set Z-Flag
        JP      (IY)

;##################################################################
;          E N D     OF     M A T H - F U N C T I O N S
;##################################################################


;--------------------------------------------------
; Destroys 'hl' !!!
; Exit: hl : TRUE = -1 / FALSE = 0,
;       IF 'HiRes' = 'SET' THEN a and hl = TRUE
;                          ELSE a and hl = FALSE;
;       IF a = true -> 'Z = reset' ELSE 'Z = set'
;--------------------------------------------------
ChkHiRes: ;Check 'HiRes' status
        push    de
        ld      hl,(STAT)       ;get STAT-Reg
        ld      de,XS_HIRES
        call    GetSta0         ;use 2nd entry-point of 'GetSta'
        pop     de
        ret

;--------------------------------------------------
;Support-Routines for RBox-Plotting requests
;--------------------------------------------------
ADDRBw: ;add in RBox-Width shift
        ld      a,(STAT+1)
        bit     PLTRBOX ,a
        ret     z
        ld      hl,(xpos)
        ld      de,(rbw)
        add     hl,de
        ld      (xpos),hl
        ret

ADDRBh: ;add in RBox-Hight shift
        ld      a,(STAT+1)
        bit     PLTRBOX ,a
        ret     z
        ld      hl,(ypos)
        ld      de,(rbh)
        add     hl,de
        ld      (ypos),hl
        ret

SUBRBw: ;sub in RBox-Width shift
        ld      a,(STAT+1)
        bit     PLTRBOX ,a
        ret     z
        ld      hl,(xpos)
        ld      de,(rbw)
        or      a
        sbc     hl,de
        ld      (xpos),hl
        ret

SUBRBh: ;sub in RBox-Hight shift
        ld      a,(STAT+1)
        bit     PLTRBOX ,a
        ret     z
        ld      hl,(ypos)
        ld      de,(rbh)
        or      a
        sbc     hl,de
        ld      (ypos),hl
        ret
;--------------------------------------------------

;------------------------------------------
; Shift hl arithmetical right one bit
; Called from FnEllipse to correct x-coord.
; in 'EllStruct' when in 'HiRes'-Mode
;------------------------------------------
HiResRShft:
        push    ix
        push    hl
        call    ChkHiRes
        jr      z,HiResRShft1    ;IF not in HiRes skip Rightshift
        ;process all 8 octants
        ld      ix,O_NNW
        call    RightShift
        ld      ix,O_NNE
        call    RightShift
        ld      ix,O_WWN
        call    RightShift
        ld      ix,O_EEN
        call    RightShift
        ld      ix,O_SSW
        call    RightShift
        ld      ix,O_SSE
        call    RightShift
        ld      ix,O_WWS
        call    RightShift
        ld      ix,O_EES
        call    RightShift
;we have to stay 2 byte below due to RightShift1's (IX+OFFSET) !
        ld      ix,O_ELL+0      ;correct X-Center coord.
        call    RightShift1
        ld      ix,O_ELL+4      ;correct X-radius
        call    RightShift1
        ld      ix,O_BXEL+4     ;correct RBwidth
        call    RightShift1
HiResRShft1:
        pop     hl
        pop     ix
        ret

RightShift: ;Shift (hl) arithmetic right
;process x-end coord.
        ld      l,(ix+6)
        ld      h,(ix+7)
        ccf
        sra     h
        rr      l
        ld      (ix+6),l
        ld      (ix+7),h
;process x-start coord.
RightShift1:
        ld      l,(ix+2)
        ld      h,(ix+3)
        ccf
        sra     h
        rr      l
        ld      (ix+2),l
        ld      (ix+3),h
        ret

;;=================================================
;; Draw  CIRCLE  (width =  hight) oder
;;       ELLIPSE (width <> hight)
;; All param. mentioned here are 16-bit !
;; Param: par1  par2  par3   par4  par5
;; Entry:  x0    y0   qseq   width hight
;; Exit:   --
;;=================================================
;;
;;FnEllipse(xpos, ypos, width, hight)
;;int xpos, ypos, width, hight;
;;{
;;=================================================

;;=================================================
;; 16-Bit Variable declarations:
;;=================================================
xpos    equ     par1
ypos    equ     par2
octm    equ     par3
width   equ     par4
hight   equ     par5

;;=================================================
;;   long int xc, yc, a2, b2, fa2, fb2;
;;   long int  x,  y, sigma;
;;=================================================
FnEllDat:
xc:     defw    0,0
yc:     defw    0,0
a2:     defw    0,0
b2:     defw    0,0
fa2:    defw    0,0
fb2:    defw    0,0
xx:     defw    0,0
yy:     defw    0,0
sigma:  defw    0,0
rbw:    defw    0,0
rbh:    defw    0,0
FnEllDat1:              ;for data field length calc.


;;=================================================
;;############### Begin of Ellipse ################
;;    int xc, yc, a2, b2, fa2, fb2;
;;    int x,  y,  sigma;
;;=================================================
FnElipse: ;Begin of Ellipse-Algorithm
;First clear some Data Arrays
        call    ClrFnEllIni
        call    ClrOctArray

FnElSaveXY:
;Save general Ellipse param., part1
        ld      hl,(xpos)
        push    hl
        ld      hl,(ypos)
        push    hl
        ld      hl,(rbwidth)
        push    hl

;;=================================================
;;   if (GetStat(XS_HIRES)) {
;;      xpos    = xpos    << 1;
;;      width   = width   << 1;
;;      rbwidth = rbwidth << 1;
;;   }
;;=================================================
        call    ChkHiRes        ;IF HiRes = FALSE THEN...
        jr      z,NoHiRes1      ;GOTO NoHiRes1
        ld      ix,xpos         ;  we are in 'HiRes' mode
        call    RLOAD16
        call    LSHIFT32        ;  Double 'xpos'
        call    RSTORE16
        ld      ix,width
        call    RLOAD16
        call    LSHIFT32        ;  Double 'width'
        call    RSTORE16
        ld      ix,rbwidth
        call    RLOAD16
        call    LSHIFT32        ;  Double 'rbwidth'
        call    RSTORE16
        ld      a,-1
        ld      (O_BXEL+1),a    ;  set HiRes-Flag to TRUE
NoHiRes1:

;Store general Ellipse param., part2
        ld      hl,(xpos)
        ld      (O_ELL+2),hl
        ld      hl,(ypos)
        ld      (O_ELL+4),hl

;Store general Ellipse param., part2
        ld      a,(QUADRT)
        ld      (O_ELL+0),a
        ld      a,OctCoord1-OctCoord    ;Struct Length
        ld      (O_ELL+1),a
        ld      hl,(width)              ;horiz. radius
        ld      (O_ELL+6),hl
        ld      hl,(hight)              ;vert. radius
        ld      (O_ELL+8),hl
;Process RBox-Request
        ld      a,(STAT+1)
        bit     PLTRBOX,a
        jr      z,NoRBoxEl1
;
        ld      a,-1
        ld      (O_BXEL+0),a      ;set RBox-Flag to TRUE
;        ld      hl,(width)
;        ld      (O_BXEL+2),hl     ;store in SRwidth
;        ld      hl,(hight)
;        ld      (O_BXEL+4),hl     ;store in SRhight
        ld      hl,(rbwidth)
        ld      (O_BXEL+6),hl     ;store RBwidth in struct.
        ld      (rbw),hl          ;...and a copy to rbw
        ld      hl,(rbhight)
        ld      (O_BXEL+8),hl     ;store RBhigh in struct.
        ld      (rbh),hl
NoRBoxEl1:

;;=================================================
;;   xc=xwidth;
;;   yc=yhight;
;;   xc=xpos;
;;   yc=ypos;
;;   a2 = width * width;
;;   b2 = hight * hight;
;;=================================================
FnEllIni1:
        ld      ix,xpos         ;get 'xpos'
        call    RLOAD16
        ld      ix,xc
        call    RSTORE32        ;xc=xpos;

        ld      ix,ypos         ;get 'ypos'
        call    RLOAD16
        ld      ix,yc
        call    RSTORE32        ;yc=ypos;

        ld      ix,width        ;get 'width'
        call    PUSH16
        call    PUSH16
        call    MUL32           ;width * width
        ld      ix,a2
        call    POP32           ;a2 = width * width;

        ld      ix,hight        ;get 'hight'
        call    PUSH16
        call    PUSH16
        call    MUL32           ;hight * hight
        ld      ix,b2
        call    POP32           ;b2 = hight * hight;

;;=================================================
;;   fa2 = 4 * a2;
;;   fb2 = 4 * b2;
;;   xx=0;
;;   yy=0;
;;   sigma=0;
;;=================================================
        ld      ix,a2
        call    PUSH32
        call    LDFOUR
        call    MUL32           ;TOP = 4 * a2;
        ld      ix,fa2
        call    POP32           ;fa2 = TOP;

        ld      ix,b2
        call    PUSH32
        call    LDFOUR
        call    MUL32           ;TOP = 4 * b2;
        ld      ix,fb2
        call    POP32           ;fb2 = TOP;

; zeroing xx, yy & sigma is already done at 'FnEllIni0',
; that's ok, because we will not go here again !

;;=================================================
;;   /* first half */
;;   xx = 0;
;;   yy = hight;
;;   sigma = 2*b2+a2*(1-2*hight);
;;
;;   ReLoadPat();
;;   RotatePat();
;;   SetPatRot(X_OFF);
;;=================================================
;       'xx' = 0 already done at 'FnEllIni0'
        ld      ix,hight        ;get 'hight'
        call    RLOAD16
        ld      ix,yy
        call    RSTORE32        ;yy = hight
;
        ld      ix,b2           ;get 'b2'
        call    RLOAD32
        call    LSHIFT32        ;'b2' * 2
        call    RPUSH32         ;push 'b2 * 2' to stack

        ld      ix,a2           ;get 'a2'
        call    PUSH32
        call    LDONE           ;'1' to stack

        ld      ix,hight        ;get 'hight'
        call    RLOAD16
        call    LSHIFT32        ;'hight' * 2
        call    RPUSH32         ;push to stack
        call    DSUB            ;'(1-2*hight)'
        call    MUL32           ;'a2*(1-2*hight)'
        call    DADD            ;TOP = '2*b2' + 'a2*(1-2*hight)'
        ld      ix,sigma        ;get 'sigma'
        call    POP32           ;sigma = TOP
;
        call    LoadPat         ;reload line pattern
        call    RotatePat       ;rotate pattern 1 bit
        call    SetRotOFF       ;Pattern rotation = OFF

;;==== Do "Northern Hemisphere" ==================
;;   while1 (b2*xx <= a2*yy) {
;;      PlotPixel(xpos=xc + xx, ypos=yc + yy);
;;      PlotPixel(xpos=xc - xx, ypos=yc + yy);
;;      PlotPixel(xpos=xc + xx, ypos=yc - yy);
;;      PlotPixel(xpos=xc - xx, ypos=yc - yy);
;;      RotatePat();
;;      if(sigma >= 0) {
;;         sigma = sigma + fa2 * (1 - yy);
;;         yy=yy-1;
;;      }
;;      sigma = sigma + b2 * ((4 * xx) + 6);
;;      xx=xx+1;
;;   }
;;=================================================
DoWhileE1: ;while1 (b2*xx <= a2*yy)
        ld      ix,b2           ;get 'b2'
        call    PUSH32
        ld      ix,xx           ;get 'xx'
        call    PUSH32
        call    MUL32           ;'b2' * 'xx'
;
        ld      ix,a2           ;get 'a2'
        call    PUSH32
        ld      ix,yy           ;get 'yy'
        call    PUSH32
        call    MUL32           ;'a2' * 'yy'
;
        call    IFLE32          ;IF (a2*yy <= b2*xx) THEN DO...
        jp      z,WendE1
;--------------------------------------------------
;;==== Do "NorthEast Quadrant" ==================
;PlotPixel(xpos=xc + xx, ypos=yc + yy);
        ld      ix,xc           ;get 'xc'
        call    PUSH32
        ld      ix,xx           ;get 'xx'
        call    PUSH32
        call    DADD            ;TOP = xc + xx + rbw
        ld      ix,xpos
        call    POP16           ;xpos = TOP

;add in RBox-Width shift
        call    ADDRBw

        ld      ix,yc           ;get 'yc'
        call    PUSH32
        ld      ix,yy           ;get 'YY'
        call    PUSH32
        call    DADD            ;yc + yy
        ld      ix,ypos
        call    POP16           ;ypos=yc + yy + rbh

;add in RBox-Hight shift
        call    ADDRBh

NNEQChk11:
        ld      a,(O_NNE)       ;if 'Z' save starting-point of oct.
        or      a
        jr      nz,NNEQChk1a
;
        ld      l,S_NNE         ;"NorthNorthEast Octant"
        ld      a,(PATNUM)
        ld      h,a
        ld      (O_NNE),hl      ;save oct.-no. + (x0,y0)-coord.
        ld      hl,(xpos)
        ld      (O_NNE+2),hl
        ld      hl,(ypos)
        ld      (O_NNE+4),hl
NNEQChk1a:
        ld      hl,(xpos)       ;save coord. of actual plotted pixel
        ld      (O_NNE+6),hl
        ld      hl,(ypos)
        ld      (O_NNE+8),hl
;
        ld      l,S_NNE         ;"NorthNorthEast Octant"
        call    TstQuadStat
        jr      z,NNWQChk11     ;if 'Z' Oct. not enabled for plotting...
        call    PltPix          ;Plot Pixel
NNWQChk11:
;--------------------------------------------------
;;==== Do "NorthWest Quadrant" ==================
;PlotPixel(xpos=xc - xx, ypos=yc + yy);
        ld      ix,xc
        call    PUSH32
        ld      ix,xx
        call    PUSH32
        call    DSUB            ;TOP = xc - xx - rbw
        ld      ix,xpos
        call    POP16           ;xpos = TOP;

;sub in RBox-Width shift
        call    SUBRBw

        ld      ix,yc           ;get 'yc'
        call    PUSH32
        ld      ix,yy           ;get 'YY'
        call    PUSH32
        call    DADD            ;yc + yy
        ld      ix,ypos
        call    POP16           ;ypos=yc + yy + rbh

;add in RBox-Hight shift
        call    ADDRBh

NNWQChk12:
        ld      a,(O_NNW)       ;if 'Z' save starting-point of oct.
        or      a
        jr      nz,NNWQChk1b
;
        ld      l,S_NNW         ;"NorthNorthWest Octrant"
        ld      a,(PATNUM)
        ld      h,a
        ld      (O_NNW),hl      ;save oct.-no. + (x0,y0)-coord.
        ld      hl,(xpos)
        ld      (O_NNW+2),hl
        ld      hl,(ypos)
        ld      (O_NNW+4),hl
NNWQChk1b:
        ld      hl,(xpos)       ;save coord. of actual plotted pixel
        ld      (O_NNW+6),hl
        ld      hl,(ypos)
        ld      (O_NNW+8),hl
;
        ld      l,S_NNW          ;"NorthNorthWest Octrant"
        call    TstQuadStat
        jr      z,SSEQChk12
        call    PltPix          ;Plot Pixel
SSEQChk12:
;--------------------------------------------------
;;==== Do "SouthEast Quadrant" ==================
;PlotPixel(xpos=xc + xx, ypos=yc - yy);
        ld      ix,xc           ;get 'xc'
        call    PUSH32
        ld      ix,xx           ;get 'xx'
        call    PUSH32
        call    DADD            ;TOP = xc + xx +rbw
        ld      ix,xpos
        call    POP16           ;xpos = TOP

;add in RBox-Width shift
        call    ADDRBw

        ld      ix,yc           ;get 'yc'
        call    PUSH32
        ld      ix,yy           ;get 'yy'
        call    PUSH32
        call    DSUB            ;TOP = yc - yy - rbh
        ld      ix,ypos
        call    POP16           ;ypos = TOP

;sub in RBox-Hight shift
        call    SUBRBh

SSEQChk13:
        ld      a,(O_SSE)       ;if 'Z' save starting-point of oct.
        or      a
        jr      nz,SSEQChk1c
;
        ld      l,S_SSE         ;"SouthSouthEast Octrant"
        ld      a,(PATNUM)
        ld      h,a
        ld      (O_SSE),hl      ;save oct.-no. + (x0,y0)-coord.
        ld      hl,(xpos)
        ld      (O_SSE+2),hl
        ld      hl,(ypos)
        ld      (O_SSE+4),hl
SSEQChk1c:
        ld      hl,(xpos)       ;save coord. of actual plotted pixel
        ld      (O_SSE+6),hl
        ld      hl,(ypos)
        ld      (O_SSE+8),hl
;
        ld      l,S_SSE          ;"SouthSouthEast Octrant"
        call    TstQuadStat
        jr      z,SSWQChk13
        call    PltPix          ;Plot Pixel
SSWQChk13:
;--------------------------------------------------
;;==== Do "SouthWest Quadrant" ==================
;PlotPixel(xpos=xc - xx, ypos=yc - yy);
        ld      ix,xc           ;het 'xc'
        call    PUSH32
        ld      ix,xx           ;get 'xx'
        call    PUSH32
        call    DSUB            ;TOP = xc - xx -rbw
        ld      ix,xpos
        call    POP16           ;xpos = TOP;

;sub in RBox-Width shift
        call    SUBRBw

        ld      ix,yc           ;get 'yc'
        call    PUSH32
        ld      ix,yy           ;get 'yy'
        call    PUSH32
        call    DSUB            ;TOP = yc - yy - rbh
        ld      ix,ypos
        call    POP16           ;ypos = TOP

;sub in RBox-Hight shift
        call    SUBRBh

SSWQChk14:
        ld      a,(O_SSW)       ;if 'Z' save starting-point of oct.
        or      a
        jr      nz,SSWQChk1d
;
        ld      l,S_SSW         ;"SouthSouthWest Octrant"
        ld      a,(PATNUM)
        ld      h,a
        ld      (O_SSW),hl      ;save oct.-no. + (x0,y0)-coord.
        ld      hl,(xpos)
        ld      (O_SSW+2),hl
        ld      hl,(ypos)
        ld      (O_SSW+4),hl
SSWQChk1d:
        ld      hl,(xpos)       ;save coord. of actual plotted pixel
        ld      (O_SSW+6),hl
        ld      hl,(ypos)
        ld      (O_SSW+8),hl
;
        ld      l,S_SSW          ;"SouthSouthWest Octrant"
        call    TstQuadStat
        jr      z,QTstW1
        call    PltPix          ;Plot Pixel
QTstW1: call    RotatePat       ;
;--------------------------------------------------
;;      if(sigma >= 0) {
;;         sigma = sigma + fa2 * (1 - yy);
;;         yy=yy-1;
;;      }
;--------------------------------------------------
        ld      ix,sigma        ;get 'sigma'
        call    PUSH32
        call    LDZERO          ;push '0' to stack
        call    IFGE32          ;IF (sigma >= 0) THEN...
        jp      z,ENFIF13
        call    LDONE           ;PUSH '1' to stack
        ld      ix,yy
        call    PUSH32
        call    DSUB            ;TOP = '(1 - yy)'
        ld      ix,fa2
        call    PUSH32          ;get 'fa2'
        call    MUL32           ;TOP = 'fa2 * (1 - yy)'
        ld      ix,sigma
        call    PUSH32
        call    DADD            ;TOP = 'sigma + fb2 * (1 - yy)'
;        ld      ix,sigma
        call    POP32          ;'sigma' = TOP

        ld      ix,yy
        call    PUSH32          ;PUSH 'yy' to stack
        call    LDONE
        call    DSUB            ;TOP = 'yy - 1'
;        ld      ix,yy
        call    POP32          ;'yy' = TOP
ENFIF13:

;--------------------------------------------------
;;      sigma = sigma + b2 * ((4 * xx) + 6);
;;      xx=xx+1;
;--------------------------------------------------
        ld      ix,b2
        call    PUSH32          ;get b2 to stack
        call    LDSIX           ;'6' to stack
        ld      ix,xx           ;get 'xx' to stack
        call    RLOAD32         ;get b2 to stack
        call    LSHIFT32        ;shift left = *2
        call    LSHIFT32        ;shift left = *2
        call    RPUSH32         ;and push to stack
        call    DADD            ;TOP = '(4 * xx)' + '6'
        call    MUL32           ;TOP = 'b2 * ((4 * xx) + 6)'
        ld      ix,sigma        ;get 'sigma'
        call    PUSH32
        call    DADD            ;TOP = 'sigma + b2 * ((4 * xx) + 6)'
;        ld      ix,sigma
        call    POP32           ;'sigma' = TOP
        ld      ix,xx
        call    PUSH32          ;get 'xx' to stack
        call    LDONE
        call    DADD            ;TOP = 'xx-1'
;        ld      ix,xx
        call    POP32         ;'xx' = TOP
;
        jp      DoWhileE1
WendE1:

;;=================================================
;;   /* second half */
;;   xx = width;
;;   yy = 0;
;;   sigma = 2*a2+b2*(1-2*width);
;;=================================================
        ld      ix,width        ;get 'width'
        call    RLOAD16         ;...and sign extend 'width'
        ld      ix,xx
        call    RSTORE32        ;xx = width
        ld      hl,0
        ld      de,0
        ld      ix,yy
        call    RSTORE32        ;yy = 0
;
        ld      ix,a2
        call    RLOAD32
        call    LSHIFT32
        call    RPUSH32         ;push '2*a2' to stack
        ld      ix,b2           ;get 'b2'
        call    PUSH32
        call    LDONE           ;'1' to stack
        ld      ix,width
        call    RLOAD16         ;get 'width'
        call    LSHIFT32        ;'<< 1'
        call    RPUSH32         ;'2*width' to stack
        call    DSUB            ;'(1-2*width)'
        call    MUL32           ;'b2*(1-2*width)'
        call    DADD            ;TOP = '2*a2' + 'b2*(1-2*width)'
        ld      ix,sigma
        call    POP32           ;'sigma' = TOP

;;==== Do "Southern Hemisphere" ==================
;;   while2 (a2*yy <= b2*xx) {
;;      PlotPixel(xpos=xc + xx, ypos=yc + yy);
;;      PlotPixel(xpos=xc - xx, ypos=yc + yy);
;;      PlotPixel(xpos=xc + xx, ypos=yc - yy);
;;      PlotPixel(xpos=xc - xx, ypos=yc - yy);
;;      RotatePat();
;;      if(sigma >= 0) {
;;         sigma = sigma + fb2 * (1 - xx);
;;         xx=xx-1;
;;      }
;;      sigma = sigma + a2 * ((4 * yy) + 6);
;;      yy=yy+1;
;;   }
;;   SetPatRot(X_ON);
;;}
;;=================================================
        call    LoadPat
DoWhileE2: ;IF (a2*yy <= b2*xx) THEN...
        ld      ix,a2           ;get 'a2'
        call    PUSH32
        ld      ix,yy           ;get 'y'
        call    PUSH32
        call    MUL32           ;TOP = 'a2' * 'yy'
;
        ld      ix,b2           ;get 'b2'
        call    PUSH32
        ld      ix,xx           ;get 'x'
        call    PUSH32
        call    MUL32           ;TOP = 'b2' * 'xx'
;
        call    IFLE32          ;IF (a2*yy <= b2*xx) THEN DO...
        jp      z,WendE2
;--------------------------------------------------
;;==== Do "SouthEast Quadrant" ==================
;PlotPixel(xpos=xc + xx, ypos=yc + yy);
        ld      ix,xc
        call    PUSH32
        ld      ix,xx
        call    PUSH32
        call    DADD            ;TOP = xc + xx + rbw
        ld      ix,xpos
        call    POP16           ;xpos = TOP

;add in RBox-Width shift
        call    ADDRBw

        ld      ix,yc
        call    PUSH32
        ld      ix,yy
        call    PUSH32
        call    DADD            ;TOP = yc + yy + rbh
        ld      ix,ypos
        call    POP16           ;ypos = TOP

;add in RBox-Hight shift
        call    ADDRBh

EENQChk21:
        ld      a,(O_EEN)       ;if 'Z' save starting-point of oct.
        or      a
        jr      nz,EENQChk2a
;
        ld      l,S_EEN         ;"EastEastNorth Quadrant"
        ld      a,(PATNUM)
        ld      h,a
        ld      (O_EEN),hl      ;save oct.-no. + (x0,y0)-coord.
        ld      hl,(xpos)
        ld      (O_EEN+2),hl
        ld      hl,(ypos)
        ld      (O_EEN+4),hl
EENQChk2a:
        ld      hl,(xpos)       ;save coord. of actual plotted pixel
        ld      (O_EEN+6),hl
        ld      hl,(ypos)
        ld      (O_EEN+8),hl
;
        ld      l,S_EEN          ;"EastEastNorth Quadrant"
        call    TstQuadStat
        jr      z,WWSQChk21
        call    PltPix          ;Plot Pixel
WWSQChk21:
;;--------------------------------------------------
;;==== Do "SouthWest Quadrant" ==================
;PlotPixel(xpos=xc - xx, ypos=yc + yy);
        ld      ix,xc
        call    PUSH32
        ld      ix,xx
        call    PUSH32
        call    DSUB            ;TOP = xc - xx -rbw
        ld      ix,xpos
        call    POP16           ;xpos = TOP;

;sub in RBox-Width shift
        call    SUBRBw

        ld      ix,yc
        call    PUSH32
        ld      ix,yy
        call    PUSH32
        call    DADD            ;TOP = yc + yy + rbh
        ld      ix,ypos
        call    POP16           ;ypos = TOP

;add in RBox-Hight shift
        call    ADDRBh

WWNQChk22:
        ld      a,(O_WWN)       ;if 'Z' save starting-point of oct.
        or      a
        jr      nz,WWNQChk2b
;
        ld      l,S_WWN         ;"WestWestNorth Quadrant"
        ld      a,(PATNUM)
        ld      h,a
        ld      (O_WWN),hl      ;save oct.-no. + (x0,y0)-coord.
        ld      hl,(xpos)
        ld      (O_WWN+2),hl
        ld      hl,(ypos)
        ld      (O_WWN+4),hl
WWNQChk2b:
        ld      hl,(xpos)       ;save coord. of actual plotted pixel
        ld      (O_WWN+6),hl
        ld      hl,(ypos)
        ld      (O_WWN+8),hl
;
        ld      l,S_WWN          ;"WestWestNorth Quadrant"
        call    TstQuadStat
        jr      z,EENQChk22
        call    PltPix          ;Plot Pixel
EENQChk22:
;;--------------------------------------------------
;;==== Do "NorthEast Quadrant" ==================
;PlotPixel(xpos=xc + xx, ypos=yc - yy);
        ld      ix,xc
        call    PUSH32
        ld      ix,xx
        call    PUSH32
        call    DADD            ;TOP = xc + xx + rbw
        ld      ix,xpos
        call    POP16           ;xpos = TOP

;add in RBox-Width shift
        call    ADDRBw

        ld      ix,yc
        call    PUSH32
        ld      ix,yy
        call    PUSH32
        call    DSUB            ;TOP = yc - yy -rbh
        ld      ix,ypos
        call    POP16           ;ypos = TOP

;sub in RBox-Hight shift
        call    SUBRBh

EESQChk23:
        ld      a,(O_EES)       ;if 'Z' save starting-point of oct.
        or      a
        jr      nz,EESQChk2c
;
        ld      l,S_EES         ;"EastEastSouth Quadrant"
        ld      a,(PATNUM)
        ld      h,a
        ld      (O_EES),hl      ;save oct.-no. + (x0,y0)-coord.
        ld      hl,(xpos)
        ld      (O_EES+2),hl
        ld      hl,(ypos)
        ld      (O_EES+4),hl
EESQChk2c:
        ld      hl,(xpos)       ;save coord. of actual plotted pixel
        ld      (O_EES+6),hl
        ld      hl,(ypos)
        ld      (O_EES+8),hl
;
        ld      l,S_EES          ;"EastEastSouth Quadrant"
        call    TstQuadStat
        jr      z,WWNQChk23
        call    PltPix          ;Plot Pixel
WWNQChk23:
;;--------------------------------------------------
;;==== Do "NorthWest Quadrant" ==================
;PlotPixel(xpos=xc - xx, ypos=yc - yy);
        ld      ix,xc
        call    PUSH32
        ld      ix,xx
        call    PUSH32
        call    DSUB            ;TOP = xc - xx -rbw
        ld      ix,xpos
        call    POP16           ;xpos = TOP;

;sub in RBox-Width shift
        call    SUBRBw

        ld      ix,yc
        call    PUSH32
        ld      ix,yy
        call    PUSH32
        call    DSUB            ;TOP = yc - yy - rbh
        ld      ix,ypos
        call    POP16           ;ypos = TOP

;sub in RBox-Hight shift
        call    SUBRBh

WWSQChk24:
        ld      a,(O_WWS)       ;if 'Z' save starting-point of oct.
        or      a
        jr      nz,WWSQChk2d
;
        ld      l,S_WWS         ;"WestWestsouth Quadrant"
        ld      a,(PATNUM)
        ld      h,a
        ld      (O_WWS),hl      ;save oct.-no. + (x0,y0)-coord.
        ld      hl,(xpos)
        ld      (O_WWS+2),hl
        ld      hl,(ypos)
        ld      (O_WWS+4),hl
WWSQChk2d:
        ld      hl,(xpos)       ;save coord. of actual plotted pixel
        ld      (O_WWS+6),hl
        ld      hl,(ypos)
        ld      (O_WWS+8),hl
;
        ld      l,S_WWS          ;"WestWestsouth Quadrant"
        call    TstQuadStat
        jr      z,QTstW2
        call    PltPix          ;Plot Pixel
QTstW2: call    RotatePat;
;--------------------------------------------------
;;      if(sigma >= 0) {
;;         sigma = sigma + fb2 * (1 - xx);
;;         xx=xx-1;
;;      }
;--------------------------------------------------
        ld      ix,sigma
        call    PUSH32
        call    LDZERO          ;push '0' to stack
        call    IFGE32          ;IF (sigma >= 0) THEN...
        jp      z,WendE23
        call    LDONE           ;TOP = '1' to stack
        ld      ix,xx           ;'xx' to stack
        call    PUSH32
        call    DSUB            ;TOP = '(1 - xx)'
        ld      ix,fb2
        call    PUSH32
        call    MUL32           ;TOP = 'fb2 * (1 - xx)'
        ld      ix,sigma
        call    PUSH32
        call    DADD            ;TOP = 'sigma + fb2 * (1 - xx)'
        call    POP32           ;'sigma' = TOP
        ld      ix,xx
        call    PUSH32          ;get 'xx' to stack
        call    LDONE
        call    DSUB            ;TOP = 'xx-1'
;        ld      ix,xx
        call    POP32           ;'xx' = TOP
WendE23:
;--------------------------------------------------
;;      sigma = sigma + a2 * ((4 * yy) + 6);
;;      yy=yy+1;
;--------------------------------------------------
        ld      ix,a2
        call    PUSH32          ;get a2 to stack
        call    LDSIX           ;'6' to stack
        ld      ix,yy           ;get 'yy' to stack
        call    RLOAD32         ;get b2 to stack
        call    LSHIFT32        ;shift left = *2
        call    LSHIFT32        ;shift left = *2
        call    RPUSH32         ;and push to stack
        call    DADD            ;TOP = '(4 * yy)' + '6'
        call    MUL32           ;TOP = 'a2 * ((4 * yy) + 6)'
        ld      ix,sigma
        call    PUSH32
        call    DADD            ;TOP = 'sigma + a2 * ((4 * yy) + 6)'
;        ld      ix,sigma
        call    POP32           ;'sigma' = TOP

        ld      ix,yy
        call    PUSH32          ;get 'yy'
        call    LDONE
        call    DADD            ;TOP = 'yy + 1'
;        ld      ix,yy
        call    POP32           ;'yy' = TOP
;
        jp      DoWhileE2
WendE2:
        call    LoadPat         ;Restart pattern
        call    SetRotON        ;Pattern rotation = ON
        call    ResQuad         ;Reset Plot-Quadrant Selection to 'ALL'
        call    ResRBox         ;Reset RBox Flag and data
        call    HiResRShft      ;If in HiRes div all XPOS by 2 in struct
                                ; and roll back to 320x240px coord.-system
FnElReLdXY:
        pop     hl
        ld      (O_BXEL+6),hl   ;save RBwidth to struct.

;Next calc. 'SRwidth' for 320x240px...
        push    de
        ld      de,0            ;preload if RBbox-Flag = 0
        ld      a,(O_BXEL+0)    ;get RBox-Flag
        or      a
        jr      z,FnEllNoRBox1
        ld      de,(O_BXEL+6)    ;get rbwidth, we have RBox = TRUE
FnEllNoRBox1:
        ld      hl,(O_ELL+6)    ;get width-radius
        add     hl,de
        ld      (O_BXEL+2),hl   ;store result in SRwidth

;Next calc. 'SRhight' for 320x240px...
        or      a               ;RBox-Flag stil in a !
        jr      z,FnEllNoRBox2  ;if Z we add de = 0 to hl !
        ld      de,(O_BXEL+8)   ;get rbhight
FnEllNoRBox2:
        ld      hl,(O_ELL+8)    ;get hight-radius
        add     hl,de
        ld      (O_BXEL+4),hl   ;store result in SRhight
        pop     de
;
        pop     hl
        ld      (ypos),hl       ;restore orig. ypos
        pop     hl
        ld      (xpos),hl       ;restore orig. xpos
;
        ld      hl,OctCoord     ;return pointer to Oct.-Coordinates
        ret                     ;return to caller, Ellipse DONE !
;=====================================================
;
RSXend:

;     #######
        end
;     #######
