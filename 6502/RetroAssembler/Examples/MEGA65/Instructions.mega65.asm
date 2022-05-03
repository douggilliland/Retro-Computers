/**************************************************************************
* All instructions for MEGA65 (45GS02)
**************************************************************************/

                .target "MEGA65" //Same as 45GS02

AddressZP       = $12

                //Some zero page exceptions with instructions using 16 bit addresses only.
                * = $00

                jmp Label

                jmp AddressZP
                jmp (AddressZP)
                jsr AddressZP
                rts

                * = $0100

Label           nop
                brk
                eom
                map
                neg
                rti
                rts
                rts #$12


Label1          bbr0 $12,Label1
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


Label2          bcc Label2
                blt Label2
                bcs Label2
                bge Label2
                bpl Label2
                bmi Label2
                bvc Label2
                bvs Label2
                bne Label2
                beq Label2
                bra Label2

                bcc *+$1000
                blt *+$1000
                bcs *+$1000
                bge *+$1000
                bpl *+$1000
                bmi *+$1000
                bvc *+$1000
                bvs *+$1000
                bne *+$1000
                beq *+$1000
                bra *+$1000

                bsr *+$1000


                jmp $1234
                jmp ($1234)
                jmp ($1234,x)

                jsr $1234
                jsr ($1234)
                jsr ($1234,x)


                bit #$12
                bit $12
                bit $12,x
                bit $1234
                bit $1234,x

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

                trb $12
                trb $1234

                tsb $12
                tsb $1234



                asl
                asl a
                asl $12
                asl $12,x
                asl $1234
                asl $1234,x

                asr
                asr a
                asr $12
                asr $12,x

                asw $1234

                lsr
                lsr a
                lsr $12
                lsr $12,x
                lsr $1234
                lsr $1234,x

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

                row $1234


                and #$12
                and $12
                and $12,x
                and $1234
                and $1234,x
                and $1234,y
                and ($12,x)
                and ($12),y
                and ($12),z
                and [$12],z

                ora #$12
                ora $12
                ora $12,x
                ora $1234
                ora $1234,x
                ora $1234,y
                ora ($12,x)
                ora ($12),y
                ora ($12),z
                ora [$12],z

                eor #$12
                eor $12
                eor $12,x
                eor $1234
                eor $1234,x
                eor $1234,y
                eor ($12,x)
                eor ($12),y
                eor ($12),z
                eor [$12],z

                xor #$12
                xor $12
                xor $12,x
                xor $1234
                xor $1234,x
                xor $1234,y
                xor ($12,x)
                xor ($12),y
                xor ($12),z
                xor [$12],z


                adc #$12
                adc $12
                adc $12,x
                adc $1234
                adc $1234,x
                adc $1234,y
                adc ($12,x)
                adc ($12),y
                adc ($12),z
                adc [$12],z

                sbc #$12
                sbc $12
                sbc $12,x
                sbc $1234
                sbc $1234,x
                sbc $1234,y
                sbc ($12,x)
                sbc ($12),y
                sbc ($12),z
                sbc [$12],z


                cmp #$12
                cmp $12
                cmp $12,x
                cmp $1234
                cmp $1234,x
                cmp $1234,y
                cmp ($12,x)
                cmp ($12),y
                cmp ($12),z
                cmp [$12],z

                cpx #$12
                cpx $12
                cpx $1234

                cpy #$12
                cpy $12
                cpy $1234

                cpz #$12
                cpz $12
                cpz $1234


                dec
                dec a
                dec $12
                dec $12,x
                dec $1234
                dec $1234,x

                dew $12

                dex
                dey
                dez


                inc
                inc a
                inc $12
                inc $12,x
                inc $1234
                inc $1234,x

                inw $12

                inx
                iny
                inz


                lda #$12
                lda $12
                lda $12,x
                lda $1234
                lda $1234,x
                lda $1234,y
                lda ($12,x)
                lda ($12),y
                lda ($12),z
                lda [$12],z

                lda ($12,sp),y
                lda ($12,s),y

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

                ldz #$12
                ldz $1234
                ldz $1234,x


                sta $12
                sta $12,x
                sta $1234
                sta $1234,x
                sta $1234,y
                sta ($12,x)
                sta ($12),y
                sta ($12),z
                sta [$12],z

                sta ($12,sp),y
                sta ($12,s),y

                stx $12
                stx $12,y
                stx $1234
                stx $1234,y

                sty $12
                sty $12,x
                sty $1234
                sty $1234,x

                stz $12
                stz $12,x
                stz $1234
                stz $1234,x


                clc
                cld
                cle
                cli
                clv

                sec
                sed
                see
                sei

                pha
                php
                phx
                phy
                phz

                pla
                plp
                plx
                ply
                plz

                phw #$1234
                phw $1234

                tab
                tax
                tay
                taz
                tba
                tsx
                tsy
                txa
                txs
                tya
                tys
                tza



                adcq $12
                adcq $1234
                adcq ($12)
                adcq [$12]

                sbcq $12
                sbcq $1234
                sbcq ($12)
                sbcq [$12]

                andq $12
                andq $1234
                andq ($12)
                andq [$12]

                orq $12
                orq $1234
                orq ($12)
                orq [$12]

                eorq $12
                eorq $1234
                eorq ($12)
                eorq [$12]

                xorq $12
                xorq $1234
                xorq ($12)
                xorq [$12]

                bitq $12
                bitq $1234

                aslq
                aslq q
                aslq $12
                aslq $12,x
                aslq $1234
                aslq $1234,x

                asrq
                asrq q
                asrq $12
                asrq $12,x

                lsrq
                lsrq q
                lsrq $12
                lsrq $12,x
                lsrq $1234
                lsrq $1234,x

                rolq
                rolq q
                rolq $12
                rolq $12,x
                rolq $1234
                rolq $1234,x

                rorq
                rorq q
                rorq $12
                rorq $12,x
                rorq $1234
                rorq $1234,x

                cmpq $12
                cmpq $1234
                cmpq ($12)
                cmpq [$12]

                deq
                deq q
                deq $12
                deq $12,x
                deq $1234
                deq $1234,x

                inq
                inq q
                inq $12
                inq $12,x
                inq $1234
                inq $1234,x

                ldq $12
                ldq $1234
                ldq ($12)
                ldq [$12]

                stq $12
                stq $1234
                stq ($12)
                stq [$12]
