/**************************************************************************
* All instructions for 8080
**************************************************************************/

                .target "8080"

                * = $2000

Label           nop

                daa
                cma
                stc
                cmc

                di
                ei
                hlt
                
                ral
                rar
                rlc
                rrc

                pchl
                sphl

                xthl
                xchg

                ret
                rc
                rm
                rnc
                rnz
                rp
                rpe
                rpo
                rz

//-------------------------------------

                rst 0
                rst 1
                rst 2
                rst 3
                rst 4
                rst 5
                rst 6
                rst 7

//-------------------------------------

                add a
                add b
                add c
                add d
                add e
                add h
                add l
                add m

                adc a
                adc b
                adc c
                adc d
                adc e
                adc h
                adc l
                adc m

                sub a
                sub b
                sub c
                sub d
                sub e
                sub h
                sub l
                sub m

                sbb a
                sbb b
                sbb c
                sbb d
                sbb e
                sbb h
                sbb l
                sbb m

                ana a
                ana b
                ana c
                ana d
                ana e
                ana h
                ana l
                ana m

                xra a
                xra b
                xra c
                xra d
                xra e
                xra h
                xra l
                xra m

                ora a
                ora b
                ora c
                ora d
                ora e
                ora h
                ora l
                ora m

                cmp a
                cmp b
                cmp c
                cmp d
                cmp e
                cmp h
                cmp l
                cmp m

//-------------------------------------

                mov a,a
                mov a,b
                mov a,c
                mov a,d
                mov a,e
                mov a,h
                mov a,l
                mov a,m

                mov b,a
                mov b,b
                mov b,c
                mov b,d
                mov b,e
                mov b,h
                mov b,l
                mov b,m

                mov c,a
                mov c,b
                mov c,c
                mov c,d
                mov c,e
                mov c,h
                mov c,l
                mov c,m

                mov d,a
                mov d,b
                mov d,c
                mov d,d
                mov d,e
                mov d,h
                mov d,l
                mov d,m

                mov e,a
                mov e,b
                mov e,c
                mov e,d
                mov e,e
                mov e,h
                mov e,l
                mov e,m

                mov h,a
                mov h,b
                mov h,c
                mov h,d
                mov h,e
                mov h,h
                mov h,l
                mov h,m

                mov l,a
                mov l,b
                mov l,c
                mov l,d
                mov l,e
                mov l,h
                mov l,l
                mov l,m

                mov m,a
                mov m,b
                mov m,c
                mov m,d
                mov m,e
                mov m,h
                mov m,l

//-------------------------------------

                ldax b
                ldax d

                stax b
                stax d

                dad b
                dad d
                dad h
                dad sp

                dcx b
                dcx d
                dcx h
                dcx sp

                inx b
                inx d
                inx h
                inx sp

                dcr a
                dcr b
                dcr c
                dcr d
                dcr e
                dcr h
                dcr l
                dcr m

                inr a
                inr b
                inr c
                inr d
                inr e
                inr h
                inr l
                inr m

                pop b
                pop d
                pop h
                pop psw

                push b
                push d
                push h
                push psw

//-------------------------------------

                mvi a,$12
                mvi b,$12
                mvi c,$12
                mvi d,$12
                mvi e,$12
                mvi h,$12
                mvi l,$12
                mvi m,$12

//-------------------------------------

                adi $12
                aci $12
                sui $12
                sbi $12
                ani $12
                xri $12
                ori $12
                cpi $12

//-------------------------------------

                in $12
                out $12

//-------------------------------------

                call $1234
                call $12

                cc $1234
                cc $12

                cm $1234
                cm $12

                cnc $1234
                cnc $12

                cnz $1234
                cnz $12

//-------------------------------------

                cp $1234
                cp $12

                cpe $1234
                cpe $12

                cpo $1234
                cpo $12

                cz $1234
                cz $12

//-------------------------------------

                jmp $1234
                jmp $12

                jc $1234
                jc $12

                jm $1234
                jm $12

                jnc $1234
                jnc $12

                jnz $1234
                jnz $12

                jp $1234
                jp $12

                jpe $1234
                jpe $12

                jpo $1234
                jpo $12

                jz $1234
                jz $12

//-------------------------------------

                lda $1234
                lda $12

                sta $1234
                sta $12

                lhld $1234
                lhld $12

                shld $1234
                shld $12

//-------------------------------------

                lxi b,$1234
                lxi b,$12

                lxi d,$1234
                lxi d,$12

                lxi h,$1234
                lxi h,$12

                lxi sp,$1234
                lxi sp,$12
