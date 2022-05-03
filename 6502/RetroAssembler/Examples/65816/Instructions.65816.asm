/**************************************************************************
* All instructions for 65816
**************************************************************************/

                .target "65816"

AddressZP       = $12

                .org $1000

Label           nop
                brk
                brk $12
                cop
                cop $12
                bpl Label
                bmi Label
                bvc Label
                bvs Label
                bcc Label
                blt Label   //Alias of bcc
                bcs Label
                bge Label   //Alias of bcs
                bne Label
                beq Label
                bra Label
                brl *+$1000

                adc #$12
                adc #$1234
                adc #$0012
                adc $12
                adc $12,x
                adc $1234
                adc $1234,x
                adc $1234,y
                adc ($12,x)
                adc ($12),y
                adc ($12)
                adc $12,sp
                adc $12,s
                adc ($12,sp),y
                adc ($12,s),y
                adc [$12]
                adc [$12],y
                adc $123456
                adc $123456,x

                and #$12
                and #$1234
                and #$0012
                and $12
                and $12,x
                and $1234
                and $1234,x
                and $1234,y
                and ($12,x)
                and ($12),y
                and ($12)
                and $12,sp
                and $12,s
                and ($12,sp),y
                and ($12,s),y
                and [$12]
                and [$12],y
                and $123456
                and $123456,x

                asl
                asl a
                asl $12
                asl $12,x
                asl $1234
                asl $1234,x

                bit #$12
                bit #$1234
                bit #$0012
                bit $12
                bit $1234
                bit $12,x
                bit $1234,x

                cmp #$12
                cmp #$1234
                cmp #$0012
                cmp $12
                cmp $12,x
                cmp $1234
                cmp $1234,x
                cmp $1234,y
                cmp ($12,x)
                cmp ($12),y
                cmp ($12)
                cmp $12,sp
                cmp $12,s
                cmp ($12,sp),y
                cmp ($12,s),y
                cmp [$12]
                cmp [$12],y
                cmp $123456
                cmp $123456,x

                cpx #$12
                cpx #$1234
                cpx #$0012
                cpx $12
                cpx $1234

                cpy #$12
                cpy #$1234
                cpy #$0012
                cpy $12
                cpy $1234

                dec
                dec a
                dec $12
                dec $12,x
                dec $1234
                dec $1234,x

                eor #$12
                eor #$1234
                eor #$0012
                eor $12
                eor $12,x
                eor $1234
                eor $1234,x
                eor $1234,y
                eor ($12,x)
                eor ($12),y
                eor ($12)
                eor $12,sp
                eor $12,s
                eor ($12,sp),y
                eor ($12,s),y
                eor [$12]
                eor [$12],y
                eor $123456
                eor $123456,x

                xor #$12        //alias of eor
                xor #$1234
                xor #$0012
                xor $12
                xor $12,x
                xor $1234
                xor $1234,x
                xor $1234,y
                xor ($12,x)
                xor ($12),y
                xor ($12)
                xor $12,sp
                xor $12,s
                xor ($12,sp),y
                xor ($12,s),y
                xor [$12]
                xor [$12],y
                xor $123456
                xor $123456,x

                clc
                sec
                cli
                sei
                clv
                cld
                sed

                inc
                inc a
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
                jmp (Label,x)
                jmp (AddressZP,x)
                jmp ($12,x)
                jmp $123456
                jmp [Label]
                jmp [AddressZP]
                jmp [$12]
                jml $123456     //Alias of jmp long
                jml [Label]
                jml [AddressZP]
                jml [$12]

                jsr Label
                jsr AddressZP
                jsr $12
                jsr (Label,x)
                jsr (AddressZP,x)
                jsr ($12,x)
                jsr $123456
                jsl $123456     //Alias of jsr long

                lda #$12
                lda #$1234
                lda #$0012
                lda $12
                lda $12,x
                lda $1234
                lda $1234,x
                lda $1234,y
                lda ($12,x)
                lda ($12),y
                lda ($12)
                lda $12,sp
                lda $12,s
                lda ($12,sp),y
                lda ($12,s),y
                lda [$12]
                lda [$12],y
                lda $123456
                lda $123456,x

                ldx #$12
                ldx #$1234
                ldx #$0012
                ldx $12
                ldx $12,y
                ldx $1234
                ldx $1234,y

                ldy #$12
                ldy #$1234
                ldy #$0012
                ldy $12
                ldy $12,x
                ldy $1234
                ldy $1234,x

                lsr
                lsr a
                lsr $12
                lsr $12,x
                lsr $1234
                lsr $1234,x

                mvn $fe,$ff

                mvp $fe,$ff

                ora #$12
                ora #$1234
                ora #$0012
                ora $12
                ora $12,x
                ora $1234
                ora $1234,x
                ora $1234,y
                ora ($12,x)
                ora ($12),y
                ora ($12)
                ora $12,sp
                ora $12,s
                ora ($12,sp),y
                ora ($12,s),y
                ora [$12]
                ora [$12],y
                ora $123456
                ora $123456,x

                dex
                dey
                inx
                iny

                rol
                rol a
                rol $12
                rol $12,x
                rol $1234
                rol $1234,x

                ror
                ror a
                ror $12
                ror $12,x
                ror $1234
                ror $1234,x

                rti

                rtl

                rts

                sbc #$12
                sbc #$1234
                sbc #$0012
                sbc $12
                sbc $12,x
                sbc $1234
                sbc $1234,x
                sbc $1234,y
                sbc ($12,x)
                sbc ($12),y
                sbc ($12)
                sbc $12,sp
                sbc $12,s
                sbc ($12,sp),y
                sbc ($12,s),y
                sbc [$12]
                sbc [$12],y
                sbc $123456
                sbc $123456,x

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

                stz $12
                stz $12,x
                stz $1234
                stz $1234,x

                rep #$ff
                sep #$ff

                trb $12
                trb $1234
                tsb $12
                tsb $1234

                pea $1234
                pei ($12)
                per *+$1000
                pha
                phb
                phd
                phk
                php
                phx
                phy
                pla
                plb
                pld
                plp
                plx
                ply

                tax
                tay
                tcd
                tcs
                tdc
                tsc
                tsx
                txa
                txs
                txy
                tya
                tyx
                xba
                xce

                wai
                stp
