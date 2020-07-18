/**************************************************************************
* All undocumented instructions for Z80, compile it with the "-u" option!
**************************************************************************/

                .target "z80"

                .org $8000

                //---------------------------------------------------------
                // ROOT INSTRUCTIONS
                //---------------------------------------------------------

                //A normal instruction, just for testing...
                nop


                //---------------------------------------------------------
                // EXTENDED INSTRUCTIONS ($ED)
                //---------------------------------------------------------

                in (c)

                out (c),0
                out (c)


                //---------------------------------------------------------
                // IX INSTRUCTIONS ($DD)
                //---------------------------------------------------------

                //LD
                ld a,ixh
                ld b,ixh
                ld c,ixh
                ld d,ixh
                ld e,ixh

                ld a,ixl
                ld b,ixl
                ld c,ixl
                ld d,ixl
                ld e,ixl

                ld ixh,a
                ld ixh,b
                ld ixh,c
                ld ixh,d
                ld ixh,e
                ld ixh,ixh
                ld ixh,ixl

                ld ixl,a
                ld ixl,b
                ld ixl,c
                ld ixl,d
                ld ixl,e
                ld ixl,ixh
                ld ixl,ixl

                ld a,ixh
                ld a,ixl

                ld ixh,$12
                ld ixl,$12


                //INC
                inc ixh
                inc ixl


                //DEC
                dec ixh
                dec ixl


                //ADD
                add a,ixh
                add a,ixl


                //ADC
                adc a,ixh
                adc a,ixl


                //SBC
                sbc a,ixh
                sbc a,ixl


                //SUB
                sub ixh
                sub a,ixh

                sub ixl
                sub a,ixl


                //AND
                and ixh
                and a,ixh

                and ixl
                and a,ixl


                //OR
                or ixh
                or a,ixh

                or ixl
                or a,ixl


                //XOR
                xor ixh
                xor a,ixh

                xor ixl
                xor a,ixl


                //CP
                cp ixh
                cp a,ixh

                cp ixl
                cp a,ixl



                //---------------------------------------------------------
                // IY INSTRUCTIONS ($FD)
                //---------------------------------------------------------

                //LD
                ld a,iyh
                ld b,iyh
                ld c,iyh
                ld d,iyh
                ld e,iyh

                ld a,iyl
                ld b,iyl
                ld c,iyl
                ld d,iyl
                ld e,iyl

                ld iyh,a
                ld iyh,b
                ld iyh,c
                ld iyh,d
                ld iyh,e
                ld iyh,iyh
                ld iyh,iyl

                ld iyl,a
                ld iyl,b
                ld iyl,c
                ld iyl,d
                ld iyl,e
                ld iyl,iyh
                ld iyl,iyl

                ld a,iyh
                ld a,iyl

                ld iyh,$12
                ld iyl,$12


                //INC
                inc iyh
                inc iyl


                //DEC
                dec iyh
                dec iyl


                //ADD
                add a,iyh
                add a,iyl


                //ADC
                adc a,iyh
                adc a,iyl


                //SBC
                sbc a,iyh
                sbc a,iyl


                //SUB
                sub iyh
                sub a,iyh

                sub iyl
                sub a,iyl


                //AND
                and iyh
                and a,iyh

                and iyl
                and a,iyl


                //OR
                or iyh
                or a,iyh

                or iyl
                or a,iyl


                //XOR
                xor iyh
                xor a,iyh

                xor iyl
                xor a,iyl


                //CP
                cp iyh
                cp a,iyh

                cp iyl
                cp a,iyl



                //---------------------------------------------------------
                // BIT INSTRUCTIONS ($CB)
                //---------------------------------------------------------

                //SLL
                sll a
                sll b
                sll c
                sll d
                sll e
                sll h
                sll l
                sll (hl)


                //---------------------------------------------------------
                // IX BIT INSTRUCTIONS ($DD, $CB)
                //---------------------------------------------------------

                //RLC
                rlc (ix+$12),a
                rlc (ix+$12),b
                rlc (ix+$12),c
                rlc (ix+$12),d
                rlc (ix+$12),e
                rlc (ix+$12),h
                rlc (ix+$12),l

                //RRC
                rrc (ix+$12),a
                rrc (ix+$12),b
                rrc (ix+$12),c
                rrc (ix+$12),d
                rrc (ix+$12),e
                rrc (ix+$12),h
                rrc (ix+$12),l

                //RL
                rl (ix+$12),a
                rl (ix+$12),b
                rl (ix+$12),c
                rl (ix+$12),d
                rl (ix+$12),e
                rl (ix+$12),h
                rl (ix+$12),l

                //RR
                rr (ix+$12),a
                rr (ix+$12),b
                rr (ix+$12),c
                rr (ix+$12),d
                rr (ix+$12),e
                rr (ix+$12),h
                rr (ix+$12),l

                //SLA
                sla (ix+$12),a
                sla (ix+$12),b
                sla (ix+$12),c
                sla (ix+$12),d
                sla (ix+$12),e
                sla (ix+$12),h
                sla (ix+$12),l

                //SRA
                sra (ix+$12),a
                sra (ix+$12),b
                sra (ix+$12),c
                sra (ix+$12),d
                sra (ix+$12),e
                sra (ix+$12),h
                sra (ix+$12),l

                //SLL
                sll (ix+$12),a
                sll (ix+$12),b
                sll (ix+$12),c
                sll (ix+$12),d
                sll (ix+$12),e
                sll (ix+$12),h
                sll (ix+$12),l

                //SRL
                srl (ix+$12),a
                srl (ix+$12),b
                srl (ix+$12),c
                srl (ix+$12),d
                srl (ix+$12),e
                srl (ix+$12),h
                srl (ix+$12),l

                //RES
                res 0,(ix+$12),a
                res 0,(ix+$12),b
                res 0,(ix+$12),c
                res 0,(ix+$12),d
                res 0,(ix+$12),e
                res 0,(ix+$12),h
                res 0,(ix+$12),l
                res 1,(ix+$12),a
                res 1,(ix+$12),b
                res 1,(ix+$12),c
                res 1,(ix+$12),d
                res 1,(ix+$12),e
                res 1,(ix+$12),h
                res 1,(ix+$12),l
                res 2,(ix+$12),a
                res 2,(ix+$12),b
                res 2,(ix+$12),c
                res 2,(ix+$12),d
                res 2,(ix+$12),e
                res 2,(ix+$12),h
                res 2,(ix+$12),l
                res 3,(ix+$12),a
                res 3,(ix+$12),b
                res 3,(ix+$12),c
                res 3,(ix+$12),d
                res 3,(ix+$12),e
                res 3,(ix+$12),h
                res 3,(ix+$12),l
                res 4,(ix+$12),a
                res 4,(ix+$12),b
                res 4,(ix+$12),c
                res 4,(ix+$12),d
                res 4,(ix+$12),e
                res 4,(ix+$12),h
                res 4,(ix+$12),l
                res 5,(ix+$12),a
                res 5,(ix+$12),b
                res 5,(ix+$12),c
                res 5,(ix+$12),d
                res 5,(ix+$12),e
                res 5,(ix+$12),h
                res 5,(ix+$12),l
                res 6,(ix+$12),a
                res 6,(ix+$12),b
                res 6,(ix+$12),c
                res 6,(ix+$12),d
                res 6,(ix+$12),e
                res 6,(ix+$12),h
                res 6,(ix+$12),l
                res 7,(ix+$12),a
                res 7,(ix+$12),b
                res 7,(ix+$12),c
                res 7,(ix+$12),d
                res 7,(ix+$12),e
                res 7,(ix+$12),h
                res 7,(ix+$12),l

                //SET
                set 0,(ix+$12),a
                set 0,(ix+$12),b
                set 0,(ix+$12),c
                set 0,(ix+$12),d
                set 0,(ix+$12),e
                set 0,(ix+$12),h
                set 0,(ix+$12),l
                set 1,(ix+$12),a
                set 1,(ix+$12),b
                set 1,(ix+$12),c
                set 1,(ix+$12),d
                set 1,(ix+$12),e
                set 1,(ix+$12),h
                set 1,(ix+$12),l
                set 2,(ix+$12),a
                set 2,(ix+$12),b
                set 2,(ix+$12),c
                set 2,(ix+$12),d
                set 2,(ix+$12),e
                set 2,(ix+$12),h
                set 2,(ix+$12),l
                set 3,(ix+$12),a
                set 3,(ix+$12),b
                set 3,(ix+$12),c
                set 3,(ix+$12),d
                set 3,(ix+$12),e
                set 3,(ix+$12),h
                set 3,(ix+$12),l
                set 4,(ix+$12),a
                set 4,(ix+$12),b
                set 4,(ix+$12),c
                set 4,(ix+$12),d
                set 4,(ix+$12),e
                set 4,(ix+$12),h
                set 4,(ix+$12),l
                set 5,(ix+$12),a
                set 5,(ix+$12),b
                set 5,(ix+$12),c
                set 5,(ix+$12),d
                set 5,(ix+$12),e
                set 5,(ix+$12),h
                set 5,(ix+$12),l
                set 6,(ix+$12),a
                set 6,(ix+$12),b
                set 6,(ix+$12),c
                set 6,(ix+$12),d
                set 6,(ix+$12),e
                set 6,(ix+$12),h
                set 6,(ix+$12),l
                set 7,(ix+$12),a
                set 7,(ix+$12),b
                set 7,(ix+$12),c
                set 7,(ix+$12),d
                set 7,(ix+$12),e
                set 7,(ix+$12),h
                set 7,(ix+$12),l


                //---------------------------------------------------------
                // IY BIT INSTRUCTIONS ($FD, $CB)
                //---------------------------------------------------------

                //RLC
                rlc (iy+$12),a
                rlc (iy+$12),b
                rlc (iy+$12),c
                rlc (iy+$12),d
                rlc (iy+$12),e
                rlc (iy+$12),h
                rlc (iy+$12),l

                //RRC
                rrc (iy+$12),a
                rrc (iy+$12),b
                rrc (iy+$12),c
                rrc (iy+$12),d
                rrc (iy+$12),e
                rrc (iy+$12),h
                rrc (iy+$12),l

                //RL
                rl (iy+$12),a
                rl (iy+$12),b
                rl (iy+$12),c
                rl (iy+$12),d
                rl (iy+$12),e
                rl (iy+$12),h
                rl (iy+$12),l

                //RR
                rr (iy+$12),a
                rr (iy+$12),b
                rr (iy+$12),c
                rr (iy+$12),d
                rr (iy+$12),e
                rr (iy+$12),h
                rr (iy+$12),l

                //SLA
                sla (iy+$12),a
                sla (iy+$12),b
                sla (iy+$12),c
                sla (iy+$12),d
                sla (iy+$12),e
                sla (iy+$12),h
                sla (iy+$12),l

                //SRA
                sra (iy+$12),a
                sra (iy+$12),b
                sra (iy+$12),c
                sra (iy+$12),d
                sra (iy+$12),e
                sra (iy+$12),h
                sra (iy+$12),l

                //SLL
                sll (iy+$12),a
                sll (iy+$12),b
                sll (iy+$12),c
                sll (iy+$12),d
                sll (iy+$12),e
                sll (iy+$12),h
                sll (iy+$12),l

                //SRL
                srl (iy+$12),a
                srl (iy+$12),b
                srl (iy+$12),c
                srl (iy+$12),d
                srl (iy+$12),e
                srl (iy+$12),h
                srl (iy+$12),l

                //RES
                res 0,(iy+$12),a
                res 0,(iy+$12),b
                res 0,(iy+$12),c
                res 0,(iy+$12),d
                res 0,(iy+$12),e
                res 0,(iy+$12),h
                res 0,(iy+$12),l
                res 1,(iy+$12),a
                res 1,(iy+$12),b
                res 1,(iy+$12),c
                res 1,(iy+$12),d
                res 1,(iy+$12),e
                res 1,(iy+$12),h
                res 1,(iy+$12),l
                res 2,(iy+$12),a
                res 2,(iy+$12),b
                res 2,(iy+$12),c
                res 2,(iy+$12),d
                res 2,(iy+$12),e
                res 2,(iy+$12),h
                res 2,(iy+$12),l
                res 3,(iy+$12),a
                res 3,(iy+$12),b
                res 3,(iy+$12),c
                res 3,(iy+$12),d
                res 3,(iy+$12),e
                res 3,(iy+$12),h
                res 3,(iy+$12),l
                res 4,(iy+$12),a
                res 4,(iy+$12),b
                res 4,(iy+$12),c
                res 4,(iy+$12),d
                res 4,(iy+$12),e
                res 4,(iy+$12),h
                res 4,(iy+$12),l
                res 5,(iy+$12),a
                res 5,(iy+$12),b
                res 5,(iy+$12),c
                res 5,(iy+$12),d
                res 5,(iy+$12),e
                res 5,(iy+$12),h
                res 5,(iy+$12),l
                res 6,(iy+$12),a
                res 6,(iy+$12),b
                res 6,(iy+$12),c
                res 6,(iy+$12),d
                res 6,(iy+$12),e
                res 6,(iy+$12),h
                res 6,(iy+$12),l
                res 7,(iy+$12),a
                res 7,(iy+$12),b
                res 7,(iy+$12),c
                res 7,(iy+$12),d
                res 7,(iy+$12),e
                res 7,(iy+$12),h
                res 7,(iy+$12),l

                //SET
                set 0,(iy+$12),a
                set 0,(iy+$12),b
                set 0,(iy+$12),c
                set 0,(iy+$12),d
                set 0,(iy+$12),e
                set 0,(iy+$12),h
                set 0,(iy+$12),l
                set 1,(iy+$12),a
                set 1,(iy+$12),b
                set 1,(iy+$12),c
                set 1,(iy+$12),d
                set 1,(iy+$12),e
                set 1,(iy+$12),h
                set 1,(iy+$12),l
                set 2,(iy+$12),a
                set 2,(iy+$12),b
                set 2,(iy+$12),c
                set 2,(iy+$12),d
                set 2,(iy+$12),e
                set 2,(iy+$12),h
                set 2,(iy+$12),l
                set 3,(iy+$12),a
                set 3,(iy+$12),b
                set 3,(iy+$12),c
                set 3,(iy+$12),d
                set 3,(iy+$12),e
                set 3,(iy+$12),h
                set 3,(iy+$12),l
                set 4,(iy+$12),a
                set 4,(iy+$12),b
                set 4,(iy+$12),c
                set 4,(iy+$12),d
                set 4,(iy+$12),e
                set 4,(iy+$12),h
                set 4,(iy+$12),l
                set 5,(iy+$12),a
                set 5,(iy+$12),b
                set 5,(iy+$12),c
                set 5,(iy+$12),d
                set 5,(iy+$12),e
                set 5,(iy+$12),h
                set 5,(iy+$12),l
                set 6,(iy+$12),a
                set 6,(iy+$12),b
                set 6,(iy+$12),c
                set 6,(iy+$12),d
                set 6,(iy+$12),e
                set 6,(iy+$12),h
                set 6,(iy+$12),l
                set 7,(iy+$12),a
                set 7,(iy+$12),b
                set 7,(iy+$12),c
                set 7,(iy+$12),d
                set 7,(iy+$12),e
                set 7,(iy+$12),h
                set 7,(iy+$12),l
