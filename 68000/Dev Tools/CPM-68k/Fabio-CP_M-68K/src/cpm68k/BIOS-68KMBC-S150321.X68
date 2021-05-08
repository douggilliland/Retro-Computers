;==================================================================================
;
; CP/M-68K 68k-MBC BIOS - S150321
; 68k-MBC - HW ref: A091020, A091020-R140221 (or following HW revisions unless stated otherwise)
;
; REQUIRED: IOS S310121 (or following SW revisions unless stated otherwise)
;
; Assemble with the Easy68K editor/assembler.
;
;
; IMPORTANT NOTE:
;  This BIOS is intended to be appended to the content of the "patched" CPM400.SR file (the
;  original one has an "oddity" as the .BSS data section is overlapped with the CBIOS itself, so
;  the resulting file cannot work).
;
;
; Easy68K can be downloaded here: 
; http://web.archive.org/web/20200113112413/http://www.easy68k.com/files/SetupEASy68K.exe
;
;---------------------------------------------------------------------------------
;
; Iobyte implementation note: 
;
;  CP/M-68K uses four logical device names (CON:, AXI:, AXO:, LST:) and each logical name 
;  can be assigned to four physical device names as explained in the following table:
;
;             Logical device  |   Physical device
;  ---------------------------+-------------------------
;         iobyte field value  |    0     1     2     3
;  ---------------------------+-------------------------
;            Console    CON:  |   TTY:  CRT:  BAT:  UC1:
;    Auxiliary Input    AXI:  |   TTY:  PTR:  UR1:  UR2:
;   Auxiliary Output    AXO:  |   TTY:  PTP:  UP1:, UP2:
;              List     LST:  |   TTY:  CRT:  LPT:  UL1:
;
;  In this implementation the physical device names are assigned
;  to the IOS virtual devices as explained in the following table:
;
;                                  Physical device name  |   IOS device
;  ------------------------------------------------------+------------------
;                                      CRT:, PTR:, PTP:  |   Serial port 1
;  TTY:, BAT:, UC1:, UR1:, UR2:, UP1:, UP2:, LPT:, UL1:  |   Serial port 2
;
;  More info on iobyte can be found on the CP/M-68K System Guide (Tables 4-3 and 4-4), 
;  and on the CP/M-68K Users Guide (STAT command).
;
;---------------------------------------------------------------------------------
;
; Note: All the Memory Region sizes are rounded to 0xYYYY0 to avoid a problem
;       with the executables generated with the CB68 CBASIC compiler.
;       For more info see here: 
;       https://www.retrobrewcomputers.org/forum/index.php?t=msg&th=576&start=0&
;
;---------------------------------------------------------------------------------
;
;
; CHANGELOG:
;
;
; S091020           First revision;
;
;
;---------------------------------------------------------------------------------
;
; CREDITS:
;
; https://hackaday.io/project/28504-reverse-engineering-soneplex-spx-mpu-sbc/log/71892-port-cpm-68k-to-mpu302-part-1
; https://github.com/dwildie/cpm-68k
; http://s100computers.com/Software%20Folder/CPM68K/CPM68K%20Software.htm
;
;==================================================================================

; IOS equates
IOBASE      EQU     $FFFFC                      ; Address base for the I/O ports
EXCWR_PORT  EQU     IOBASE+0                    ; Address of the EXECUTE WRITE OPCODE write port
EXCRD_PORT  EQU     IOBASE+0                    ; Address of the EXECUTE READ OPCODE read port
STOPC_PORT  EQU     IOBASE+1                    ; Address of the STORE OPCODE write port
SER1RX_PORT EQU     IOBASE+1                    ; Address of the SERIAL 1 RX read port 
SYSFLG_PORT EQU     IOBASE+2                    ; Address of the SYSFLAGS read port
SER2RX_PORT EQU     IOBASE+3                    ; Address of the SERIAL 2 RX read port
USRLED_OPC  EQU     $00                         ; USER LED opcode
SER1TX_OPC  EQU     $01                         ; SERIAL 1 TX opcode
SELDISK_OPC EQU     $09                         ; SELDISK opcode
SELTRCK_OPC EQU     $0A                         ; SELTRACK opcode
SELSECT_OPC EQU     $0B                         ; SELSECT opcode
WRTSECT_OPC EQU     $0C                         ; WRITESECT opcode
SER2TX_OPC  EQU     $10                         ; SERIAL 2 TX opcode
ERRDSK_OPC  EQU     $85                         ; ERRDISK opcode
RDSECT_OPC  EQU     $86                         ; READSECT opcode
SDMOUNT_OPC EQU     $87                         ; SDMOUNT opcode
FLUSHBF_OPC EQU     $88                         ; FLUSHBUFF opcode

; Common ASCII codes
cr          EQU     13
lf          EQU     10
sp          EQU     32
esc         EQU     $1B
eos         EQU     0

; Others equates
RAMCHK1     EQU     $55                         ; RAM check test pattern 1
RAMCHK2     EQU     $AA                         ; RAM check test pattern 2

; CP/M-68K equates
MEMADR      EQU     $07A00                      ; Address of the memory region (just after the BIOS)
SIZE128     EQU     (($1FFFF-MEMADR-$8)>>4)<<4  ; Memory region size for the 128KB configuration (default)
SIZE512     EQU     (($7FFFF-MEMADR-$8)>>4)<<4  ; Memory region size for the 512KB configuration
SIZE1M      EQU     (($FBFFF-MEMADR-$4)>>4)<<4  ; Memory region size for the 1024KB configuration
maxdsk      equ     16                          ; 16 HD drives (from A: to P:)
dphlen      equ     26                          ; Length of Disk Parameter Header (DPH)
_ccp        equ     $004BC                      ; Hard location for _ccp of CPM400.SR
_autost     EQU     $55BE                       ; AUTOEXEC flag for CPM400.SR (see CP/M-68K par. 7.2)
_usercmd    EQU     $55BF                       ; AUTOEXEC string for CPM400.SR (see CP/M-68K par. 7.2)

            org     $06200                      ; This is the hard location for _init for the "patched" CPM400.SR

; ----------------------------------------------------------------------------

_init:  

    move.w  #$2700,sr                   ; Mask off all interrupts
    move.l  #traphndl,$8c               ; Set up trap #3 handler
    lea     Msg1,a1                     ; Print Bios message
    bsr     puts
    bsr     setRam                      ; Set the size of the CP/M memory region and print the RAM size
    bsr     autoexec                    ; Set the execution of AUTOEXEC.SUB if needed
    lea     Msg2(pc),a1                 ; Print CP/M logon message
    bsr     puts
    clr.l   d0                          ; Log on disk A, user 0
    rts

traphndl:
    cmpi    #nfuncs,d0
    bcc     trapng
    lsl     #2,d0                       ; Multiply bios function by 4
    
**X won't assemble here:         movea.l 6(pc,d0),a0        * get handler address
**X replace with this:

    movea.l *+8(pc,d0),a0               ; Get handler address
    jsr     (a0)                        ; Call handler
    
trapng:
    rte

; ----------------------------------------------------------------------------

biosbase:
            dc.l  _init
            dc.l  wboot
            dc.l  constat
            dc.l  conin
            dc.l  conout
            dc.l  lstout
            dc.l  auxout
            dc.l  auxin
            dc.l  home
            dc.l  seldsk
            dc.l  settrk
            dc.l  setsec
            dc.l  setdma
            dc.l  read
            dc.l  write
            dc.l  listst
            dc.l  sectran
            dc.l  setdma
            dc.l  getseg
            dc.l  getiob
            dc.l  setiob
            dc.l  flush
            dc.l  setexc

nfuncs      equ (*-biosbase)/4

; ---------------------------------------------------------------------------- 
;
; BIOS Functions
;
; ----------------------------------------------------------------------------

wboot:      
    bsr     flush                       ; See CP/M-68K System Guide par. 5.3.2, 5.3.4
    jmp     _ccp

; ----------------------------------------------------------------------------

constat: 
; Check for console input. Set D0.W to 0x00FF if console input is pending, 
;  otherwise set to 0x0000.

    clr.l   d0
    move.b  (SYSFLG_PORT).l,d1          ; D1.B = SYSFLAG
    move.b  iobyte+1,d2                 ; D2.B = iobyte
    and.b   #$03,d2                     ; Isolate CON: field
    cmp.b   #$01,d2                     ; CON: = Serial port 1?
    beq     constatSer1                 ; Yes, jump
    btst    #5,d1                       ; No, Serial 2 Rx char ready bit (bit 5) = 1?
    bne     charRdy                     ; Yes, jump
    rts                                 ; No, return with D0.W = 0x0000
    
constatSer1:
    btst    #2,d1                       ; Serial 1 Rx char ready bit (bit 2) = 1?
    bne     charRdy                     ; Yes, jump
    rts                                 ; No, return with D0.W = 0x0000
    
charRdy:
    move.b  #$ff,d0                     ; Yes, D0.W = 0x00FF
    rts

; ----------------------------------------------------------------------------
         
conin:  
; Read a single character from the console into D0.W

    bsr     constat                     ; Check if there is an input pending
    tst.w   d0
    beq     conin                       ; No, wait an input
    move.b  iobyte+1,d2                 ; Yes, D2.B = iobyte
    and.b   #$03,d2                     ; Isolate CON: field
    cmp.b   #$01,d2                     ; CON: = Serial port 1?
    beq     coninSer1                   ; Yes, jump
    move.b  (SER2RX_PORT).l,d0          ; No, read Serial port 2 data into D0.B
    rts
    
coninSer1:
    move.b  (SER1RX_PORT).l,d0          ; Yes, read Serial port 1 data into D0.B
    rts 

; ----------------------------------------------------------------------------

conout: 
; Send a single character in D1.B to the console

    move.b  iobyte+1,d2                 ; D2.B = iobyte
    and.b   #$03,d2                     ; Isolate CON: field
    cmp.b   #$01,d2                     ; CON: = Serial port 1?
    beq     conoutSer1                  ; Yes, jump
    move.b  #SER2TX_OPC,(STOPC_PORT).l  ; No, Write SERIAL 2 TX opcode to IOS
    move.b  d1,(EXCWR_PORT ).l          ; Print current char
    rts

conoutSer1:
    move.b  #SER1TX_OPC,(STOPC_PORT).l  ; Write SERIAL 1 TX opcode to IOS
    move.b  d1,(EXCWR_PORT ).l          ; Print current char
    rts

; ----------------------------------------------------------------------------

lstout:
; Send a single character in D1.B to the List device

    move.b  iobyte+1,d2                 ; D2.B = iobyte
    and.b   #$C0,d2                     ; Isolate LST: field
    cmp.b   #($01 << 6),d2              ; LST: = Serial port 1?
    beq     lstoutSer1                  ; Yes, jump
    move.b  #SER2TX_OPC,(STOPC_PORT).l  ; No, Write SERIAL 2 TX opcode to IOS
    move.b  d1,(EXCWR_PORT ).l          ; Print current char
    rts

lstoutSer1:
    move.b  #SER1TX_OPC,(STOPC_PORT).l  ; Write SERIAL 1 TX opcode to IOS
    move.b  d1,(EXCWR_PORT ).l          ; Print current char
    rts

; ----------------------------------------------------------------------------

auxout:    
; Send a single character in D1.B to the Auxiliary out device

    move.b  iobyte+1,d2                 ; D2.B = iobyte
    and.b   #$30,d2                     ; Isolate AXO: field
    cmp.b   #($01<<4),d2                ; AXO: = Serial port 1?
    beq     auxoutSer1                  ; Yes, jump
    move.b  #SER2TX_OPC,(STOPC_PORT).l  ; Write SERIAL 2 TX opcode to IOS
    move.b  d1,(EXCWR_PORT ).l          ; Print current char
    move.w  d1,d0                       ; Return it to D0.W
    rts
    
auxoutSer1:
    move.b  #SER1TX_OPC,(STOPC_PORT).l  ; Write SERIAL 1 TX opcode to IOS
    move.b  d1,(EXCWR_PORT ).l          ; Print current char
    move.w  d1,d0                       ; Return it to D0.W
    rts

; ----------------------------------------------------------------------------

auxin:
; Read a single character from the Auxiliary input device in D0.W

    clr.l   d0
    move.b  (SYSFLG_PORT).l,d0          ; D0.B = SYSFLAG
    move.b  iobyte+1,d2                 ; D2.B = iobyte
    and.b   #$0C,d2                     ; Isolate AXI: field
    cmp.b   #($01<<2),d2                ; AXI: = Serial port 1?
    beq     auxinSer1                   ; Yes, jump
    btst    #5,d0                       ; Serial 2 Rx char ready bit (bit 5) = 1?
    beq     auxin                       ; No, wait a char
    move.b  (SER2RX_PORT).l,d0          ; Yes, read Serial port 2 data into D0.B
    rts
    
auxinSer1:
    btst    #2,d0                       ; Serial 1 Rx char ready bit (bit 2) = 1?
    beq     auxin                       ; No, wait a char
    move.b  (SER1RX_PORT).l,d0          ; Yes, read Serial port 1 data into D0.B
    rts

; ----------------------------------------------------------------------------

listst: 
; Always ready

    move.w  #$00ff,d0
    rts

; ----------------------------------------------------------------------------

home:   

    clr.w   track
    rts

; ----------------------------------------------------------------------------

seldsk: 
; Select disk given by register D1.B

    moveq   #0,d0
    cmp.b   #maxdsk,d1                  * valid drive number?
    bpl     selrtn                      * if no, return 0 in d0
    move.b  d1,seldrv                   * else, save drive number
    move.b  seldrv,d0
    mulu    #dphlen,d0
    add.l   #dph0,d0                    * point d0 at correct dph
selrtn: 
    rts

; ----------------------------------------------------------------------------

settrk: 
; Select track given by register D1.W

    move.w  d1,track
    rts

; ----------------------------------------------------------------------------

setsec: 
; Select sector given by register D1.W.
; Because max allowed sector number is 31 only a byte is stored.

    move.b  d1,sector
    rts

; ----------------------------------------------------------------------------

sectran:
;   No sector translate, put d1 into d0 and return

    move.w  d1,d0
    rts

; ----------------------------------------------------------------------------

setdma:
; Select the DMA address (even or odd) given by register D1.L

    move.l  d1,dma
    rts

; ----------------------------------------------------------------------------

read:
; Read one sector (128 bytes) using current disk, track, sector values and store it to to DMA

    bsr     setDTS                      ; Select disk, track, sector
    move.b  #RDSECT_OPC,(STOPC_PORT).l  ; Write READSECT opcode to IOS
    clr.l   d0
    move.b  #127,d0                     ; Set D0.B for 128 consecutive I/O read operations
    move.l  dma,a0                      ; A0 = pointer to DMA address
    ;
    ; Read a sector
    ;
readloop:
    move.b  (EXCRD_PORT).l,(A0)+        ; Read a byte from SD and store it to dma
    dbra    d0,readloop                 ; Until all the 128 bytes have been read
    ;
    ; Check for errors
    ;
    clr.l   d0
    move.b  #ERRDSK_OPC,(STOPC_PORT).l  ; Write ERRDISK opcode to IOS
    move.b  (EXCRD_PORT).l,d0           ; D0.W = disk error (0 = no error)
    rts

; Set disk, track and sector routine for a read or write operation
setDTS:
    move.b  lastseldrv,d0               ; D0.B = last selected drive
    move.b  seldrv,d2                   ; D2.B = current selected drive
    cmp.b   d0,d2                       ; Last selected drive = current drive?
    beq     setTrack                    ; Yes, jump ahead
    move.b  #SELDISK_OPC,(STOPC_PORT).l ; Write SELDISK opcode to IOS
    move.b  d2,(EXCWR_PORT ).l          ; Select the disk number
    move.b  d2,lastseldrv               ; Update last drive
; Select track
setTrack:
    move.b  #SELTRCK_OPC,(STOPC_PORT).l ; Write SELTRACK opcode to IOS
    move.b  track+1,(EXCWR_PORT ).l     ; Select the track number (LSB)
    move.b  track,(EXCWR_PORT ).l       ; Select the track number (MSB)
; Select sector (128 bytes)
    move.b  #SELSECT_OPC,(STOPC_PORT).l ; Write SELSECT opcode to IOS
    move.b  sector,(EXCWR_PORT ).l      ; Select the sector number
    rts

; ----------------------------------------------------------------------------

write:
; Write one sector to requested disk, track, sector from dma address

    bsr     setDTS                      ; Select disk, track, sector
    move.b  #WRTSECT_OPC,(STOPC_PORT).l ; Write WRITESECT opcode to IOS
    clr.l   d0
    move.b  #127,d0                     ; Set D0.B for 128 consecutive I/O read operations
    move.l  dma,a0                      ; A0 = pointer to DMA address
wriloop:
    move.b  (A0)+,(EXCRD_PORT).l        ; Read a byte from dma and write it to SD
    dbra    d0,wriloop                  ; Until all the 128 bytes have been written
    ;
    ; Check for errors
    ;
    clr.l   d0
    move.b  #ERRDSK_OPC,(STOPC_PORT).l  ; Write ERRDISK opcode to IOS
    move.b  (EXCRD_PORT).l,d0           ; D0.B = error code (0 = no error)
    ;
    ; Flush the buffer (write to SD) if it is a directory sector write
    ;
    move.b  d0,wrierr                   ; Store the error code
    cmp.w   #1,d1                       ; Is a write to a directory sector?
    bne     wriend                      ; No, jump and return
    bsr     flush                       ; Yes, do a buffer flush (write to SD)
    add.b   wrierr,d0                   ; Check if both the write and flush are with no errors
wriend:
    rts                                 ; D0.W = error code (0 = no error)

; ----------------------------------------------------------------------------

flush:

    clr.l   d0
    move.b  #FLUSHBF_OPC,(STOPC_PORT).l ; Write FLUSHBUFF opcode to IOS
    move.b  (EXCRD_PORT).l,d0           ; D0.W = error code (0 = no error)
    rts

; ----------------------------------------------------------------------------

getseg:
    move.l  #memrgn,d0                  ; Return address of mem region table
    rts

; ----------------------------------------------------------------------------

getiob:
    move.w iobyte,d0                    ; Return with iobyte values
    rts

; ----------------------------------------------------------------------------

setiob:
    move.w d1,iobyte                    ; Update iobyte with content of d1.w
    rts

; ----------------------------------------------------------------------------

setexc:
    andi.l  #$ff,d1                     ; Do only for exceptions 0 - 255
    lsl     #2,d1                       ; Multiply exception nmbr by 4
    movea.l d1,a0
    move.l  (a0),d0                     ; Return old vector value
    move.l  d2,(a0)                     ; Insert new vector
noset:  
    rts

; ----------------------------------------------------------------------------
;
; Others internal functions
;
; ---------------------------------------------------------------------------- 

autoexec:
; ............................................................................
; Set the execution of AUTOEXEC.SUB at cold boot if required by IOS
; ............................................................................
    move.b  (SYSFLG_PORT).l,d0          ; D0.B = SYSFLAGS IOS register
    btst    #0,d0                       ; Autoexec flag set? (bit0 = 1?)
    bne     setAutoexec                 ; Yes, jump
    rts                                 ; No, nothing to do
    
setAutoexec:
    move.b  #1,(_autost).l              ; Set the CP/M autoexec flag
    lea     AutoStr,a1                  ; A1 = pointer to the command string to write
    lea     _usercmd,a2                 ; A2 = pointer to the destination string
autoLoop:
    move.b  (a1)+,(a2)+                 ; Copy a char
    cmp.b   #cr,(a1)                    ; Next char is an CR?
    bne     autoLoop                    ; No, jump
    rts                                 ; Yes, all done

; ---------------------------------------------------------------------------- 

setRam:
; ............................................................................
; Set the size of the CP/M Memory Region and print the RAM size.
; ............................................................................
    bsr     checkRam                    ; Size the RAM
    cmp.b   #2,d0                       ; Found 1024KB RAM?
    bne     Ram512                      ; No, jump
    lea     Msg1024,a1                  ; Yes, print the 1024KB msg
    bsr     puts
    move.l  #SIZE1M,memsize             ; Set the memory region size
    rts
    
Ram512:
    cmp.b   #1,d0                       ; Found 512KB RAM?
    bne     Ram128                      ; No, jump
    lea     Msg512,a1                   ; Yes, print 512KB message
    bsr     puts
    move.l  #SIZE512,memsize            ; Set the memory region size
    rts
    
Ram128:
    lea     Msg128,a1                   ; Print 128KB message
    bsr     puts
    rts

; ---------------------------------------------------------------------------- 

checkRam:
; ............................................................................
; Size the available RAM (128KB/512KB/1024KB) and check for Lite/Full HW 
; configuration.
;
; Returns in D0.B a code giving the amount of the RAM: 0 = 128KB, 1 = 512KB, 
; 2 = 1024KB and store the Lite/Full HW configuration status into the <LiteHwFlg> flag.
;
; Used registers: A0, D0.B
; ............................................................................
    ;
    ; Check for Lite/Full HW configuration
    ;
    move.b  (SYSFLG_PORT).l,d0          ; D0.B = SYSFLAGS IOS register
    btst    #3,d0                       ; Lite HW configuration detected? (bit3 = 1?)
    bne     checkRam512                 ; Yes, jump and continue the check for 512KB (Z = 0)
    lea     LiteHwFlg(pc),a0            ; No, update the LiteHwFlg flag for Full HW configuration
    clr.b   (a0)
    ;move.b  d0,(a0)
    ;
    ; Check for 1024KB RAM
    ;
    move.b  #RAMCHK1,Addr1024           ; Store RAMCHK1 into RAM
    move.b  Addr1024,d0                 ; Read it into D0
    cmp.b   #RAMCHK1,d0                 ; Equal to the original value?
    bne     checkRam512                 ; No, jump and continue the check for 512KB (Z = 0)
    move.b  #RAMCHK2,Addr1024           ; Yes, store RAMCHK2 into RAM
    move.b  Addr1024,d0                 ; Read it into D0
    cmp.b   #RAMCHK2,d0                 ; Equal to the original value?
    bne     checkRam512                 ; No, jump and continue the check for 512KB (Z = 0)
    move.b  #2,d0                       ; Yes, set the value for 1024KB RAM found...
    rts                                 ; ...and return

checkRam512:
    ;
    ; Check for 128KB/512KB RAM
    ;
    move.b  #RAMCHK1,Addr128            ; Store RAMCHK1 into RAM in the first 128KB block
    move.b  Addr512,d0                  ; Read it from a mirrored location into D0
    cmp.b   #RAMCHK1,d0                 ; Equal to the original value?
    bne     found512                    ; No, jump
    move.b  #RAMCHK2,Addr128            ; Yes, store RAMCHK2 into RAM in the first 128KB block
    move.b  Addr512,d0                  ; Read it from a mirrored location into D0
    cmp.b   #RAMCHK2,d0                 ; Equal to the original value?
    bne     found512                    ; No, jump
    clr.b   d0                          ; Yes, set the value for 128KB RAM found...
    rts                                 ; ...and return

found512:
    ;
    ; Found 512KB RAM
    ;
    move.b  #1,d0                       ; Set the value for 512KB RAM found...
    rts                                 ; ...and return

; ---------------------------------------------------------------------------- 

puts:
; ............................................................................
; Send a string to the serial port 1, A1 = pointer to the string.
; ............................................................................
    move.b  (a1)+,d1                    ; D1.B = current char to print
    cmp.b   #eos,d1                     ; Is it an eos?
    beq     puts_end                    ; Yes, jump
    move.b  #SER1TX_OPC,(STOPC_PORT).l  ; No, write SERIAL 1 TX opcode to IOS
    move.b  d1,(EXCWR_PORT ).l          ; Print current char
    bra     puts
    
puts_end:
    rts

; ----------------------------------------------------------------------------
;
; Data area
;
; ----------------------------------------------------------------------------         
            
            org (*+1)/2*2               ; Must be an even address!
memrgn:     dc.w    1                   ; 1 memory region
            dc.l    MEMADR              ; Right after the CP/M
memsize:    dc.l    SIZE128             ; 128KB RAM (default)
seldrv:     dc.b    $ff                 ; Drive requested by seldsk
lastseldrv: dc.b    $ff                 ; Last selected drive ($ff = no drive)
track:      dc.w    0                   ; Track requested by settrk
sector:     dc.b    0                   ; Max sector value is 31
dma:        dc.l    0
wrierr      dc.b    0                   ; Store write error code
iobyte      dc.w    $0001               ; Default value: LST=TTY, AXO=TTY, AXI=TTY, CON=CRT  
LiteHwFlg   DC.B    1                   ; Lite HW configuration flag (1 = Lite config, 0 = Full config)   
Msg1        DC.B    '68k-MBC CP/M-68K BIOS - S150321 - ', eos
Msg2        DC.B    'CP/M-68K Version 1.3', cr, lf
            DC.B    'Copyright (c) 1985 Digital Research Inc.', cr, lf, eos
Msg1024     DC.B    '1024KB', cr, lf, eos
Msg512      DC.B    '512KB', cr, lf, eos
Msg128      DC.B    '128KB', cr, lf, eos
AutoStr     DC.B    'SUBMIT AUTOEXEC', $00, cr

; ----------------------------------------------------------------------------

            org (*+1)/2*2               ; Must be an even address!

; Disk Parameter Headers (DPH)

dph0:   
            dc.l    0                   * no sector translation table
            dc.w    0                   * dummy
            dc.w    0
            dc.w    0
            dc.l    dirbuf              * ptr to directory buffer
            dc.l    dpb0                * ptr to disk parameter block
            dc.l    0                   * permanent drive, no check vector
            dc.l    alv0                * ptr to allocation vector

dph1:
            dc.l    0                   * no sector translation table
            dc.w    0                   * dummy
            dc.w    0
            dc.w    0
            dc.l    dirbuf              * ptr to directory buffer
            dc.l    dpb0                * ptr to disk parameter block
            dc.l    0                   * permanent drive, no check vector
            dc.l    alv1                * ptr to allocation vector
dph2:
            dc.l    0                   * no sector translation table
            dc.w    0                   * dummy
            dc.w    0
            dc.w    0
            dc.l    dirbuf              * ptr to directory buffer
            dc.l    dpb0                * ptr to disk parameter block
            dc.l    0                   * permanent drive, no check vector
            dc.l    alv2                * ptr to allocation vector

dph3:
            dc.l    0                   * no sector translation table
            dc.w    0                   * dummy
            dc.w    0
            dc.w    0
            dc.l    dirbuf              * ptr to directory buffer
            dc.l    dpb0                * ptr to disk parameter block
            dc.l    0                   * permanent drive, no check vector
            dc.l    alv3                * ptr to allocation vector
            
dph4:
            dc.l    0                   * no sector translation table
            dc.w    0                   * dummy
            dc.w    0
            dc.w    0
            dc.l    dirbuf              * ptr to directory buffer
            dc.l    dpb0                * ptr to disk parameter block
            dc.l    0                   * permanent drive, no check vector
            dc.l    alv4                * ptr to allocation vector
            
dph5:
            dc.l    0                   * no sector translation table
            dc.w    0                   * dummy
            dc.w    0
            dc.w    0
            dc.l    dirbuf              * ptr to directory buffer
            dc.l    dpb0                * ptr to disk parameter block
            dc.l    0                   * permanent drive, no check vector
            dc.l    alv5                * ptr to allocation vector
            
dph6:
            dc.l    0                   * no sector translation table
            dc.w    0                   * dummy
            dc.w    0
            dc.w    0
            dc.l    dirbuf              * ptr to directory buffer
            dc.l    dpb0                * ptr to disk parameter block
            dc.l    0                   * permanent drive, no check vector
            dc.l    alv6                * ptr to allocation vector
            
dph7:
            dc.l    0                   * no sector translation table
            dc.w    0                   * dummy
            dc.w    0
            dc.w    0
            dc.l    dirbuf              * ptr to directory buffer
            dc.l    dpb0                * ptr to disk parameter block
            dc.l    0                   * permanent drive, no check vector
            dc.l    alv7                * ptr to allocation vector
            
dph8:
            dc.l    0                   * no sector translation table
            dc.w    0                   * dummy
            dc.w    0
            dc.w    0
            dc.l    dirbuf              * ptr to directory buffer
            dc.l    dpb0                * ptr to disk parameter block
            dc.l    0                   * permanent drive, no check vector
            dc.l    alv8                * ptr to allocation vector
            
dph9:
            dc.l    0                   * no sector translation table
            dc.w    0                   * dummy
            dc.w    0
            dc.w    0
            dc.l    dirbuf              * ptr to directory buffer
            dc.l    dpb0                * ptr to disk parameter block
            dc.l    0                   * permanent drive, no check vector
            dc.l    alv9                * ptr to allocation vector
            
dph10:
            dc.l    0                   * no sector translation table
            dc.w    0                   * dummy
            dc.w    0
            dc.w    0
            dc.l    dirbuf              * ptr to directory buffer
            dc.l    dpb0                * ptr to disk parameter block
            dc.l    0                   * permanent drive, no check vector
            dc.l    alv10               * ptr to allocation vector
            
dph11:
            dc.l    0                   * no sector translation table
            dc.w    0                   * dummy
            dc.w    0
            dc.w    0
            dc.l    dirbuf              * ptr to directory buffer
            dc.l    dpb0                * ptr to disk parameter block
            dc.l    0                   * permanent drive, no check vector
            dc.l    alv11               * ptr to allocation vector
            
dph12:
            dc.l    0                   * no sector translation table
            dc.w    0                   * dummy
            dc.w    0
            dc.w    0
            dc.l    dirbuf              * ptr to directory buffer
            dc.l    dpb0                * ptr to disk parameter block
            dc.l    0                   * permanent drive, no check vector
            dc.l    alv12               * ptr to allocation vector
            
dph13:
            dc.l    0                   * no sector translation table
            dc.w    0                   * dummy
            dc.w    0
            dc.w    0
            dc.l    dirbuf              * ptr to directory buffer
            dc.l    dpb0                * ptr to disk parameter block
            dc.l    0                   * permanent drive, no check vector
            dc.l    alv13               * ptr to allocation vector
            
dph14:
            dc.l    0                   * no sector translation table
            dc.w    0                   * dummy
            dc.w    0
            dc.w    0
            dc.l    dirbuf              * ptr to directory buffer
            dc.l    dpb0                * ptr to disk parameter block
            dc.l    0                   * permanent drive, no check vector
            dc.l    alv14               * ptr to allocation vector
            
dph15:
            dc.l    0                   * no sector translation table
            dc.w    0                   * dummy
            dc.w    0
            dc.w    0
            dc.l    dirbuf              * ptr to directory buffer
            dc.l    dpb0                * ptr to disk parameter block
            dc.l    0                   * permanent drive, no check vector
            dc.l    alv15               * ptr to allocation vector
            
; Disk Parameters Blocks (DPB)
            
dpb0:   
            dc.w    128                 ; SPT - 128 bytes sectors per track (= 32 sectors of 512 bytes)
            dc.b    5                   ; BSH - block shift factor
            dc.b    31                  ; BLM - block mask
            dc.b    1                   ; EXM - Extent mask
            dc.b    0                   ; dummy fill
            dc.w    2047                ; DSM, (512 tracks * 128 sectors * 128 bytes /4096)-1
                           
            dc.w    511                 ; DRM - Number of directory entries - 1
            dc.w    0                   ; Directory mask
            dc.w    0                   ; Permanent mounted drive, check size is zero
            dc.w    0                   ; No track offset
            
; ----------------------------------------------------------------------------
;
; Not initialized data area
;
; ---------------------------------------------------------------------------- 
            
            org (*+1)/2*2               ; Must be an even address!
            
dirbuf:     ds.b    128                 ; Directory buffer

alv0:       ds.b    258                 ; Allocation vector, DSM/8+1 (round up to 258)
alv1:       ds.b    258                 
alv2:       ds.b    258                 
alv3:       ds.b    258                 
alv4:       ds.b    258                 
alv5:       ds.b    258                 
alv6:       ds.b    258                 
alv7:       ds.b    258                 
alv8:       ds.b    258                 
alv9:       ds.b    258                 
alv10:      ds.b    258                 
alv11:      ds.b    258                 
alv12:      ds.b    258                 
alv13:      ds.b    258                 
alv14:      ds.b    258                 
alv15:      ds.b    258                 

biosEnd:                                ; End of BIOS

            ORG     $1aff0
Addr128     DS.B    1                   ; Test byte for 128KB/512KB RAM check

            ORG     $7aff0
Addr512     DS.B    1                   ; Test byte for 128KB/512KB RAM check

            ORG     $fbff0
Addr1024    DS.B    1                   ; Test byte for 1024KB RAM check

            end     $400                ; Start executing CPM at $400 (for CPM400.SR)
