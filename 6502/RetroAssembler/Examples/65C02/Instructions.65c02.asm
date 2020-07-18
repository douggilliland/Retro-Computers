/**************************************************************************
* All normal instructions for 65C02
**************************************************************************/

                .target "65c02"

AddressZP       = $12

                .org $0100

Label           nop
                bpl Label
                bmi Label
                bvc Label
                bvs Label
                bcc Label
                bcs Label
                bne Label
                beq Label
                bra Label

                adc #$12
                adc $12
                adc $12,x
                adc $1234
                adc $1234,x
                adc $1234,y
                adc ($12,x)
                adc ($12),y
                adc ($12)

                and #$12
                and $12
                and $12,x
                and $1234
                and $1234,x
                and $1234,y
                and ($12,x)
                and ($12),y
                and ($12)

                asl
                asl a  //Alias for the plain mnemonic
                asl $12
                asl $12,x
                asl $1234
                asl $1234,x

                bit #$12
                bit $12
                bit $12,x
                bit $1234
                bit $1234,x

                cmp #$12
                cmp $12
                cmp $12,x
                cmp $1234
                cmp $1234,x
                cmp $1234,y
                cmp ($12,x)
                cmp ($12),y
                cmp ($12)

                cpx #$12
                cpx $12
                cpx $1234

                cpy #$12
                cpy $12
                cpy $1234

                dec
                dec a  //Alias for the plain mnemonic
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
                eor ($12)

                xor #$12
                xor $12
                xor $12,x
                xor $1234
                xor $1234,x
                xor $1234,y
                xor ($12,x)
                xor ($12),y
                xor ($12)

                clc
                sec
                cli
                sei
                clv
                cld
                sed

                inc
                inc a  //Alias for the plain mnemonic
                inc $12
                inc $12,x
                inc $1234
                inc $1234,x

                //Shows that JMP and JSR work with zero page addresses too
                //They will be compiled with address $0012
                jmp Label
                jmp AddressZP
                jmp $12
                jmp (Label)
                jmp (AddressZP)
                jmp ($12)
                jmp ($1234,x)

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
                lda ($12)

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
                ora ($12)

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
                sbc ($12)

                sta $12
                sta $12,x
                sta $1234
                sta $1234,x
                sta $1234,y
                sta ($12,x)
                sta ($12),y
                sta ($12)

                stx $12
                stx $12,y
                stx $1234

                sty $12
                sty $12,x
                sty $1234

                stz $12
                stz $12,x
                stz $1234
                stz $1234,x

                trb $12
                trb $1234

                tsb $12
                tsb $1234

                txs
                tsx
                pha
                pla
                php
                plp

                phx
                phy
                plx
                ply

                
                //Vendor specific instructions

Label1          
                bbr0 $12,Label1
                bbr1 $12,Label1
                bbr2 $12,Label1
                bbr3 $12,Label1
                bbr4 $12,Label1
                bbr5 $12,Label1
                bbr6 $12,Label1
                bbr7 $12,Label1

                bbs0 $12,Label1
                bbs1 $12,Label1
                bbs2 $12,Label1
                bbs3 $12,Label1
                bbs4 $12,Label1
                bbs5 $12,Label1
                bbs6 $12,Label1
                bbs7 $12,Label1

                rmb0 $12
                rmb1 $12
                rmb2 $12
                rmb3 $12
                rmb4 $12
                rmb5 $12
                rmb6 $12
                rmb7 $12

                smb0 $12
                smb1 $12
                smb2 $12
                smb3 $12
                smb4 $12
                smb5 $12
                smb6 $12
                smb7 $12

                wai
                stp
