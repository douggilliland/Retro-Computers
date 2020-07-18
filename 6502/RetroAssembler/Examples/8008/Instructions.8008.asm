/**************************************************************************
* All instructions for 8008
**************************************************************************/

                .target "8008"

                * = $2000

Label           nop

                hlt

                ret

//-------------------------------------

                rlc
                rrc

                ral
                rar

//-------------------------------------

                rfc
                rfs
                rtc
                rts

                rfz
                rfp
                rtz
                rtp

//-------------------------------------

                inb
                inc
                ind
                ine
                inh
                inl
                
                dcb
                dcc
                dcd
                dce
                dch
                dcl

//-------------------------------------

                ada
                adb
                adc
                add
                ade
                adh
                adl
                adm

                aca
                acb
                acc
                acd
                ace
                ach
                acl
                acm

                sua
                sub
                suc
                sud
                sue
                suh
                sul
                sum

                sba
                sbb
                sbc
                sbd
                sbe
                sbh
                sbl
                sbm

                nda
                ndb
                ndc
                ndd
                nde
                ndh
                ndl
                ndm

                xra
                xrb
                xrc
                xrd
                xre
                xrh
                xrl
                xrm

                ora
                orb
                orc
                ord
                ore
                orh
                orl
                orm

                cpa
                cpb
                cpc
                cpd
                cpe
                cph
                cpl
                cpm

//-------------------------------------

                lab
                lac
                lad
                lae
                lah
                lal
                lam

                lba
                lbb
                lbc
                lbd
                lbe
                lbh
                lbl
                lbm

                lca
                lcb
                lcc
                lcd
                lce
                lch
                lcl
                lcm

                lda
                ldb
                ldc
                ldd
                lde
                ldh
                ldl
                ldm

                lea
                leb
                lec
                led
                lee
                leh
                lel
                lem

                lha
                lhb
                lhc
                lhd
                lhe
                lhh
                lhl
                lhm

                lla
                llb
                llc
                lld
                lle
                llh
                lll
                llm

                lma
                lmb
                lmc
                lmd
                lme
                lmh
                lml

//-------------------------------------

                adi $12
                sui $12
                ndi $12
                ori $12

                aci $12
                sbi $12
                xri $12
                cpi $12

                lai $12
                lbi $12
                lci $12
                ldi $12
                lei $12
                lhi $12
                lli $12
                lmi $12

//-------------------------------------

                jmp $1234

                jfc $1234
                jfz $1234
                jfs $1234
                jfp $1234
                jtc $1234
                jtz $1234
                jts $1234
                jtp $1234


                cal $1234

                cfc $1234
                cfz $1234
                cfs $1234
                cfp $1234
                ctc $1234
                ctz $1234
                cts $1234
                ctp $1234

//-------------------------------------

                rst 0
                rst 1
                rst 2
                rst 3
                rst 4
                rst 5
                rst 6
                rst 7

                inp 0
                inp 1
                inp 2
                inp 3
                inp 4
                inp 5
                inp 6
                inp 7

                out 8
                out 9
                out 10
                out 11
                out 12
                out 13
                out 14
                out 15
                out 16
                out 17
                out 18
                out 19
                out 20
                out 21
                out 22
                out 23
                out 24
                out 25
                out 26
                out 27
                out 28
                out 29
                out 30
                out 31
