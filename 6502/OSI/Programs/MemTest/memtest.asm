; 
; Memory test from http://archive.6502.org/publications/dr_dobbs_journal_selected_articles/high_speed_memory_test_for_6502.pdf
; On-line assembler at https://www.masswerk.at/6502/assembler.html
; 

pointl = $fa
pointh = $fb

flag = $70
flip = $71
mod = $72
 
*=$0000    

begin  
.byte $01

end   
.byte $9F

start  lda #0
       tay
       sta *pointl
biglp  sta *flag  
       ldx #2
       stx *mod
pass   lda *begin
       sta *pointh
       ldx *end
       lda *flag
       eor #$ff
       sta *flip
clear  sta (pointl),y
       iny
       bne clear
       inc *pointh
       cpx *pointh
       bcs clear
       ldx *mod       
       lda *begin
       sta *pointh
fill   lda *flag
top    dex
       bpl skip
       ldx #2
       sta (pointl),y
skip   iny
       bne top
       inc *pointh
       lda *end
       cmp *pointh
       bcs fill
       lda *begin
       sta *pointh
       ldx *mod
pop    lda *flip
       dex
       bpl slip
       ldx #2
       lda *flag
slip   cmp (pointl),y
       bne out
       iny
       bne pop
       inc *pointh
       lda *end
       cmp *pointh
       bcs pop
       dec *mod
       bpl pass
       lda *flag
       eor #$ff
       bmi biglp
out    sty *pointl
       jmp $FE00
.END
