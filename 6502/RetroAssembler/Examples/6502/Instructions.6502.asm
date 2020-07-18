/**************************************************************************
* All normal instructions for 6502
**************************************************************************/

                .target "6502"

AddressZP       = $12

                .org $1000

Label           nop
                brk
                bpl Label
                bmi Label
                bvc Label
                bvs Label
                bcc Label
                bcs Label
                bne Label
                beq Label

                adc #$12
                adc $12
                adc $12,x
                adc $1234
                adc $1234,x
                adc $1234,y
                adc ($12,x)
                adc ($12),y

                and #$12
                and $12
                and $12,x
                and $1234
                and $1234,x
                and $1234,y
                and ($12,x)
                and ($12),y

                asl
                asl a  //Alias for the plain mnemonic
                asl $12
                asl $12,x
                asl $1234
                asl $1234,x

                bit $12
                bit $1234

                cmp #$12
                cmp $12
                cmp $12,x
                cmp $1234
                cmp $1234,x
                cmp $1234,y
                cmp ($12,x)
                cmp ($12),y

                cpx #$12
                cpx $12
                cpx $1234

                cpy #$12
                cpy $12
                cpy $1234

                dec $12
                dec $12,x
                dec $1234
                dec $1234,x

                eor #$12
                eor $12
                eor $12,x
                eor $1234
                eor $1234,x
                eor $1234,y
                eor ($12,x)
                eor ($12),y

                //Alias for "eor"
                xor #$12
                xor $12
                xor $12,x
                xor $1234
                xor $1234,x
                xor $1234,y
                xor ($12,x)
                xor ($12),y

                clc
                sec
                cli
                sei
                clv
                cld
                sed

                inc $12
                inc $12,x
                inc $1234
                inc $1234,x

                //Shows that JMP and JSR work with zero page addresses too.
                //They will be compiled with address $0012
                jmp Label
                jmp AddressZP
                jmp $12
                jmp (Label)
                jmp (AddressZP)
                jmp ($12)

                jsr Label
                jsr AddressZP
                jsr $12

                lda #$12
                lda $12
                lda $12,x
                lda $1234
                lda $1234,x
                lda $1234,y
                lda ($12,x)
                lda ($12),y

                ldx #$12
                ldx $12
                ldx $12,y
                ldx $1234
                ldx $1234,y

                ldy #$12
                ldy $12
                ldy $12,x
                ldy $1234
                ldy $1234,x

                lsr
                lsr a  //Alias for the plain mnemonic
                lsr $12
                lsr $12,x
                lsr $1234
                lsr $1234,x

                ora #$12
                ora $12
                ora $12,x
                ora $1234
                ora $1234,x
                ora $1234,y
                ora ($12,x)
                ora ($12),y

                tax
                txa
                dex
                inx
                tay
                tya
                dey
                iny

                rol
                rol a  //Alias for the plain mnemonic
                rol $12
                rol $12,x
                rol $1234
                rol $1234,x

                ror
                ror a  //Alias for the plain mnemonic
                ror $12
                ror $12,x
                ror $1234
                ror $1234,x

                rti

                rts

                sbc #$12
                sbc $12
                sbc $12,x
                sbc $1234
                sbc $1234,x
                sbc $1234,y
                sbc ($12,x)
                sbc ($12),y

                sta $12
                sta $12,x
                sta $1234
                sta $1234,x
                sta $1234,y
                sta ($12,x)
                sta ($12),y

                stx $12
                stx $12,y
                stx $1234

                sty $12
                sty $12,x
                sty $1234

                txs
                tsx
                pha
                pla
                php
                plp
