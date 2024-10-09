  .org $e000

  .include "hwconfig.s"
  .include "libsd.s"
  .include "libfat32.s"
  .include "liblcd.s"


zp_sd_address = $40         ; 2 bytes
zp_sd_currentsector = $42   ; 4 bytes
zp_fat32_variables = $46    ; 24 bytes

fat32_workspace = $200      ; two pages

buffer = $400


subdirname:
  .asciiz "SUBFOLDR   "
filename:
  .asciiz "DEEPFILETXT"

reset:
  ldx #$ff
  txs

  ; Initialise
  jsr via_init
  jsr lcd_init
  jsr sd_init
  jsr fat32_init
  bcc .initsuccess
 
  ; Error during FAT32 initialization
  lda #'Z'
  jsr print_char
  lda fat32_errorstage
  jsr print_hex
  jmp loop

.initsuccess

  ; Open root directory
  jsr fat32_openroot

  ; Find subdirectory by name
  ldx #<subdirname
  ldy #>subdirname
  jsr fat32_finddirent
  bcc .foundsubdir

  ; Subdirectory not found
  lda #'X'
  jsr print_char
  jmp loop

.foundsubdir

  ; Open subdirectory
  jsr fat32_opendirent

  ; Find file by name
  ldx #<filename
  ldy #>filename
  jsr fat32_finddirent
  bcc .foundfile

  ; File not found
  lda #'Y'
  jsr print_char
  jmp loop

.foundfile
 
  ; Open file
  jsr fat32_opendirent

  ; Read file contents into buffer
  lda #<buffer
  sta fat32_address
  lda #>buffer
  sta fat32_address+1

  jsr fat32_file_read


  ; Dump data to LCD

  jsr lcd_cleardisplay

  ldy #0
.printloop
  lda buffer,y
  jsr print_char

  iny

  cpy #16
  bne .not16
  jsr lcd_setpos_startline1
.not16

  cpy #32
  bne .printloop


  ; loop forever
loop:
  jmp loop


  .org $fffc
  .word reset
  .word $0000
