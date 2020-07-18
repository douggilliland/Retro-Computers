/**************************************************************************
* All normal instructions for Z80
**************************************************************************/

                .target "z80"

                .org $8000

                //---------------------------------------------------------
                // ROOT INSTRUCTIONS
                //---------------------------------------------------------

                nop

                //LD (TO, FROM/WHAT)

                ld a,$12
                ld b,$12
                ld c,$12
                ld d,$12
                ld e,$12
                ld h,$12
                ld l,$12
                ld (hl),$12

                ld a,a
                ld a,b
                ld a,c
                ld a,d
                ld a,e
                ld a,h
                ld a,l
                ld a,(hl)

                ld b,a
                ld b,b
                ld b,c
                ld b,d
                ld b,e
                ld b,h
                ld b,l
                ld b,(hl)

                ld c,a
                ld c,b
                ld c,c
                ld c,d
                ld c,e
                ld c,h
                ld c,l
                ld c,(hl)

                ld d,a
                ld d,b
                ld d,c
                ld d,d
                ld d,e
                ld d,h
                ld d,l
                ld d,(hl)

                ld e,a
                ld e,b
                ld e,c
                ld e,d
                ld e,e
                ld e,h
                ld e,l
                ld e,(hl)

                ld h,a
                ld h,b
                ld h,c
                ld h,d
                ld h,e
                ld h,h
                ld h,l
                ld h,(hl)

                ld l,a
                ld l,b
                ld l,c
                ld l,d
                ld l,e
                ld l,h
                ld l,l
                ld l,(hl)

                ld (hl),a
                ld (hl),b
                ld (hl),c
                ld (hl),d
                ld (hl),e
                ld (hl),h
                ld (hl),l

                ld a,(bc)
                ld a,(de)

                ld (bc),a
                ld (de),a

                ld ($1234),a
                ld a,($1234)

                ld bc,$1234
                ld de,$1234
                ld hl,$1234
                ld sp,$1234

                ld hl,($1234)
                ld ($1234),hl

                ld sp,hl


                //PUSH
                push af
                push bc
                push de
                push hl


                //POP
                pop af
                pop bc
                pop de
                pop hl


                //ADD
                add a,$12
                add a,a
                add a,b
                add a,c
                add a,d
                add a,e
                add a,h
                add a,l
                add a,(hl)

                add hl,bc
                add hl,de
                add hl,hl
                add hl,sp


                //ADC
                adc a,$12
                adc a,a
                adc a,b
                adc a,c
                adc a,d
                adc a,e
                adc a,h
                adc a,l
                adc a,(hl)


                //SUB
                sub $12
                sub a
                sub b
                sub c
                sub d
                sub e
                sub h
                sub l
                sub (hl)

                sub a,$12
                sub a,a
                sub a,b
                sub a,c
                sub a,d
                sub a,e
                sub a,h
                sub a,l
                sub a,(hl)


                //SBC
                sbc a,$12
                sbc a,a
                sbc a,b
                sbc a,c
                sbc a,d
                sbc a,e
                sbc a,h
                sbc a,l
                sbc a,(hl)


                //AND
                and $12
                and a
                and b
                and c
                and d
                and e
                and h
                and l
                and (hl)

                and a,$12
                and a,a
                and a,b
                and a,c
                and a,d
                and a,e
                and a,h
                and a,l
                and a,(hl)


                //OR
                or $12
                or a
                or b
                or c
                or d
                or e
                or h
                or l
                or (hl)

                or a,$12
                or a,a
                or a,b
                or a,c
                or a,d
                or a,e
                or a,h
                or a,l
                or a,(hl)


                //XOR
                xor $12
                xor a
                xor b
                xor c
                xor d
                xor e
                xor h
                xor l
                xor (hl)

                xor a,$12
                xor a,a
                xor a,b
                xor a,c
                xor a,d
                xor a,e
                xor a,h
                xor a,l
                xor a,(hl)


                //CP
                cp $12
                cp a
                cp b
                cp c
                cp d
                cp e
                cp h
                cp l
                cp (hl)

                cp a,$12
                cp a,a
                cp a,b
                cp a,c
                cp a,d
                cp a,e
                cp a,h
                cp a,l
                cp a,(hl)


                //INC
                inc a
                inc b
                inc c
                inc d
                inc e
                inc h
                inc l
                inc (hl)
                inc bc
                inc de
                inc hl
                inc sp


                //DEC
                dec a
                dec b
                dec c
                dec d
                dec e
                dec h
                dec l
                dec (hl)
                dec bc
                dec de
                dec hl
                dec sp


                //Misc
                daa
                daa a
                cpl
                cpl a
                ccf
                scf
                di
                ei
                halt
                

                //Rotations and shifts
                rlca
                rlca a
                rla
                rla a
                rrca
                rrca a
                rra
                rra a


                //JP
                jp $1234
                jp nz,$1234
                jp z,$1234
                jp nc,$1234
                jp c,$1234
                jp (hl)
                jp po,$1234
                jp pe,$1234
                jp p,$1234
                jp m,$1234


Label           nop

                //JR
                jr Label
                jr nz,Label
                jr z,Label
                jr nc,Label
                jr c,Label

                djnz Label


                //CALL
                call $1234
                call nz,$1234
                call z,$1234
                call nc,$1234
                call c,$1234
                call po,$1234
                call pe,$1234
                call p,$1234
                call m,$1234


                //RET
                ret
                ret nz
                ret z
                ret nc
                ret c
                ret po
                ret pe
                ret p
                ret m


                //RST
                rst $00
                rst $08
                rst $10
                rst $18
                rst $20
                rst $28
                rst $30
                rst $38


                //IN
                in a,($12)

                //OUT
                out ($12),a


                //EX
                ex af,af'
                ex af,af

                ex (sp),hl
                ex de,hl

                //EXX
                exx


                //---------------------------------------------------------
                // EXTENDED INSTRUCTIONS ($ED)
                //---------------------------------------------------------

                in a,(c)
                in b,(c)
                in c,(c)
                in d,(c)
                in e,(c)
                in h,(c)
                in l,(c)

                out (c),a
                out (c),b
                out (c),c
                out (c),d
                out (c),e
                out (c),h
                out (c),l

                adc hl,bc
                adc hl,de
                adc hl,hl
                adc hl,sp

                sbc hl,bc
                sbc hl,de
                sbc hl,hl
                sbc hl,sp

                ld ($1234),bc
                ld ($1234),de
                ld ($1234),sp

                ld bc,($1234)
                ld de,($1234)
                ld sp,($1234)

                ld i,a
                ld a,i
                ld r,a
                ld a,r

                neg

                reti

                retn

                rld
                rrd

                ldi
                cpi
                ini
                outi

                ldir
                cpir
                inir
                otir

                ldd
                cpd
                ind
                outd

                lddr
                cpdr
                indr
                otdr

                im 0
                im 1
                im 2


                //---------------------------------------------------------
                // IX INSTRUCTIONS ($DD)
                //---------------------------------------------------------

                ld ix,$1234
                ld ($1234),ix
                ld ix,($1234)

                ld (ix+$12),$34

                ld (ix+$12),a
                ld (ix+$12),b
                ld (ix+$12),c
                ld (ix+$12),d
                ld (ix+$12),e
                ld (ix+$12),h
                ld (ix+$12),l

                ld b,(ix+$12)
                ld c,(ix+$12)
                ld d,(ix+$12)
                ld e,(ix+$12)
                ld h,(ix+$12)
                ld l,(ix+$12)
                ld a,(ix+$12)

                ld sp,ix


                add ix,bc
                add ix,de
                add ix,ix
                add ix,sp
                add a,(ix+$12)

                inc ix
                inc (ix+$12)

                dec ix
                dec (ix+$12)

                adc a,(ix+$12)
                sbc a,(ix+$12)

                sub (ix+$12)
                sub a,(ix+$12)
                and (ix+$12)
                and a,(ix+$12)
                or (ix+$12)
                or a,(ix+$12)
                xor (ix+$12)
                xor a,(ix+$12)
                cp (ix+$12)
                cp a,(ix+$12)

                pop ix
                push ix
                jp (ix)
                ex (sp),ix


                //---------------------------------------------------------
                // IY INSTRUCTIONS ($FD)
                //---------------------------------------------------------

                ld iy,$1234
                ld ($1234),iy
                ld iy,($1234)

                ld (iy+$12),$34

                ld (iy+$12),a
                ld (iy+$12),b
                ld (iy+$12),c
                ld (iy+$12),d
                ld (iy+$12),e
                ld (iy+$12),h
                ld (iy+$12),l

                ld b,(iy+$12)
                ld c,(iy+$12)
                ld d,(iy+$12)
                ld e,(iy+$12)
                ld h,(iy+$12)
                ld l,(iy+$12)
                ld a,(iy+$12)

                ld sp,iy


                add iy,bc
                add iy,de
                add iy,iy
                add iy,sp
                add a,(iy+$12)

                inc iy
                inc (iy+$12)

                dec iy
                dec (iy+$12)

                adc a,(iy+$12)
                sbc a,(iy+$12)

                sub (iy+$12)
                sub a,(iy+$12)
                and (iy+$12)
                and a,(iy+$12)
                or (iy+$12)
                or a,(iy+$12)
                xor (iy+$12)
                xor a,(iy+$12)
                cp (iy+$12)
                cp a,(iy+$12)

                pop iy
                push iy
                jp (iy)
                ex (sp),iy


                //---------------------------------------------------------
                // BIT INSTRUCTIONS ($CB)
                //---------------------------------------------------------

                //RLC
                rlc a
                rlc b
                rlc c
                rlc d
                rlc e
                rlc h
                rlc l
                rlc (hl)


                //RL
                rl a
                rl b
                rl c
                rl d
                rl e
                rl h
                rl l
                rl (hl)


                //RRC
                rrc a
                rrc b
                rrc c
                rrc d
                rrc e
                rrc h
                rrc l
                rrc (hl)


                //RR
                rr a
                rr b
                rr c
                rr d
                rr e
                rr h
                rr l
                rr (hl)


                //SLA
                sla a
                sla b
                sla c
                sla d
                sla e
                sla h
                sla l
                sla (hl)


                //SRA
                sra a
                sra b
                sra c
                sra d
                sra e
                sra h
                sra l
                sra (hl)


                //SRL
                srl a
                srl b
                srl c
                srl d
                srl e
                srl h
                srl l
                srl (hl)


                //BIT
                bit 0,a
                bit 0,b
                bit 0,c
                bit 0,d
                bit 0,e
                bit 0,h
                bit 0,l
                bit 0,(hl)
                bit 1,a
                bit 1,b
                bit 1,c
                bit 1,d
                bit 1,e
                bit 1,h
                bit 1,l
                bit 1,(hl)
                bit 2,a
                bit 2,b
                bit 2,c
                bit 2,d
                bit 2,e
                bit 2,h
                bit 2,l
                bit 2,(hl)
                bit 3,a
                bit 3,b
                bit 3,c
                bit 3,d
                bit 3,e
                bit 3,h
                bit 3,l
                bit 3,(hl)
                bit 4,a
                bit 4,b
                bit 4,c
                bit 4,d
                bit 4,e
                bit 4,h
                bit 4,l
                bit 4,(hl)
                bit 5,a
                bit 5,b
                bit 5,c
                bit 5,d
                bit 5,e
                bit 5,h
                bit 5,l
                bit 5,(hl)
                bit 6,a
                bit 6,b
                bit 6,c
                bit 6,d
                bit 6,e
                bit 6,h
                bit 6,l
                bit 6,(hl)
                bit 7,a
                bit 7,b
                bit 7,c
                bit 7,d
                bit 7,e
                bit 7,h
                bit 7,l
                bit 7,(hl)


                //SET
                set 0,a
                set 0,b
                set 0,c
                set 0,d
                set 0,e
                set 0,h
                set 0,l
                set 0,(hl)
                set 1,a
                set 1,b
                set 1,c
                set 1,d
                set 1,e
                set 1,h
                set 1,l
                set 1,(hl)
                set 2,a
                set 2,b
                set 2,c
                set 2,d
                set 2,e
                set 2,h
                set 2,l
                set 2,(hl)
                set 3,a
                set 3,b
                set 3,c
                set 3,d
                set 3,e
                set 3,h
                set 3,l
                set 3,(hl)
                set 4,a
                set 4,b
                set 4,c
                set 4,d
                set 4,e
                set 4,h
                set 4,l
                set 4,(hl)
                set 5,a
                set 5,b
                set 5,c
                set 5,d
                set 5,e
                set 5,h
                set 5,l
                set 5,(hl)
                set 6,a
                set 6,b
                set 6,c
                set 6,d
                set 6,e
                set 6,h
                set 6,l
                set 6,(hl)
                set 7,a
                set 7,b
                set 7,c
                set 7,d
                set 7,e
                set 7,h
                set 7,l
                set 7,(hl)


                //RES
                res 0,a
                res 0,b
                res 0,c
                res 0,d
                res 0,e
                res 0,h
                res 0,l
                res 0,(hl)
                res 1,a
                res 1,b
                res 1,c
                res 1,d
                res 1,e
                res 1,h
                res 1,l
                res 1,(hl)
                res 2,a
                res 2,b
                res 2,c
                res 2,d
                res 2,e
                res 2,h
                res 2,l
                res 2,(hl)
                res 3,a
                res 3,b
                res 3,c
                res 3,d
                res 3,e
                res 3,h
                res 3,l
                res 3,(hl)
                res 4,a
                res 4,b
                res 4,c
                res 4,d
                res 4,e
                res 4,h
                res 4,l
                res 4,(hl)
                res 5,a
                res 5,b
                res 5,c
                res 5,d
                res 5,e
                res 5,h
                res 5,l
                res 5,(hl)
                res 6,a
                res 6,b
                res 6,c
                res 6,d
                res 6,e
                res 6,h
                res 6,l
                res 6,(hl)
                res 7,a
                res 7,b
                res 7,c
                res 7,d
                res 7,e
                res 7,h
                res 7,l
                res 7,(hl)


                //---------------------------------------------------------
                // IX BIT INSTRUCTIONS ($DD, $CB)
                //---------------------------------------------------------

                rlc (ix+$12)
                rrc (ix+$12)
                rl (ix+$12)
                rr (ix+$12)
                sla (ix+$12)
                sra (ix+$12)
                srl (ix+$12)

                bit 0,(ix+$12)
                bit 1,(ix+$12)
                bit 2,(ix+$12)
                bit 3,(ix+$12)
                bit 4,(ix+$12)
                bit 5,(ix+$12)
                bit 6,(ix+$12)
                bit 7,(ix+$12)

                res 0,(ix+$12)
                res 1,(ix+$12)
                res 2,(ix+$12)
                res 3,(ix+$12)
                res 4,(ix+$12)
                res 5,(ix+$12)
                res 6,(ix+$12)
                res 7,(ix+$12)

                set 0,(ix+$12)
                set 1,(ix+$12)
                set 2,(ix+$12)
                set 3,(ix+$12)
                set 4,(ix+$12)
                set 5,(ix+$12)
                set 6,(ix+$12)
                set 7,(ix+$12)


                //---------------------------------------------------------
                // IY BIT INSTRUCTIONS ($FD, $CB)
                //---------------------------------------------------------

                rlc (iy+$12)
                rrc (iy+$12)
                rl (iy+$12)
                rr (iy+$12)
                sla (iy+$12)
                sra (iy+$12)
                srl (iy+$12)

                bit 0,(iy+$12)
                bit 1,(iy+$12)
                bit 2,(iy+$12)
                bit 3,(iy+$12)
                bit 4,(iy+$12)
                bit 5,(iy+$12)
                bit 6,(iy+$12)
                bit 7,(iy+$12)

                res 0,(iy+$12)
                res 1,(iy+$12)
                res 2,(iy+$12)
                res 3,(iy+$12)
                res 4,(iy+$12)
                res 5,(iy+$12)
                res 6,(iy+$12)
                res 7,(iy+$12)

                set 0,(iy+$12)
                set 1,(iy+$12)
                set 2,(iy+$12)
                set 3,(iy+$12)
                set 4,(iy+$12)
                set 5,(iy+$12)
                set 6,(iy+$12)
                set 7,(iy+$12)
