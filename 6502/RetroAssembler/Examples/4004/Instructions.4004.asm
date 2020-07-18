/**************************************************************************
* All instructions for 4004
**************************************************************************/

                .target "4004"

                * = $2000

Label           nop

                wrm
                wmp
                wrr
                wpm
                wr0
                wr1
                wr2
                wr3
                sbm
                rdm
                rdr
                adm
                rd0
                rd1
                rd2
                rd3

                clb
                clc
                iac
                cmc
                cma
                ral
                rar
                tcc
                dac
                tcs
                stc
                daa
                kbp
                dcl

//-------------------------------------

                fin 0
                fin 1
                fin 2
                fin 3
                fin 4
                fin 5
                fin 6
                fin 7

                jin 0
                jin 1
                jin 2
                jin 3
                jin 4
                jin 5
                jin 6
                jin 7

                src 0
                src 1
                src 2
                src 3
                src 4
                src 5
                src 6
                src 7

//-------------------------------------

                inc 0
                inc 1
                inc 2
                inc 3
                inc 4
                inc 5
                inc 6
                inc 7
                inc 8
                inc 9
                inc 10
                inc 11
                inc 12
                inc 13
                inc 14
                inc 15

                add 0
                add 1
                add 2
                add 3
                add 4
                add 5
                add 6
                add 7
                add 8
                add 9
                add 10
                add 11
                add 12
                add 13
                add 14
                add 15

                sub 0
                sub 1
                sub 2
                sub 3
                sub 4
                sub 5
                sub 6
                sub 7
                sub 8
                sub 9
                sub 10
                sub 11
                sub 12
                sub 13
                sub 14
                sub 15

                ld 0
                ld 1
                ld 2
                ld 3
                ld 4
                ld 5
                ld 6
                ld 7
                ld 8
                ld 9
                ld 10
                ld 11
                ld 12
                ld 13
                ld 14
                ld 15

                xch 0
                xch 1
                xch 2
                xch 3
                xch 4
                xch 5
                xch 6
                xch 7
                xch 8
                xch 9
                xch 10
                xch 11
                xch 12
                xch 13
                xch 14
                xch 15

                bbl 0
                bbl 1
                bbl 2
                bbl 3
                bbl 4
                bbl 5
                bbl 6
                bbl 7
                bbl 8
                bbl 9
                bbl 10
                bbl 11
                bbl 12
                bbl 13
                bbl 14
                bbl 15

                ldm 0
                ldm 1
                ldm 2
                ldm 3
                ldm 4
                ldm 5
                ldm 6
                ldm 7
                ldm 8
                ldm 9
                ldm 10
                ldm 11
                ldm 12
                ldm 13
                ldm 14
                ldm 15

//-------------------------------------

                jnt $ff
                jc $ff
                jz $ff
                jt $ff
                jnc $ff
                jnz $ff

//-------------------------------------

                fim 0, $ff
                fim 1, $ff
                fim 2, $ff
                fim 3, $ff
                fim 4, $ff
                fim 5, $ff
                fim 6, $ff
                fim 7, $ff

                jcn 0, $ff
                jcn 3, $ff
                jcn 5, $ff
                jcn 6, $ff
                jcn 7, $ff
                jcn 8, $ff
                jcn 11, $ff
                jcn 13, $ff
                jcn 14, $ff
                jcn 15, $ff

                jun 0, $ff
                jun 1, $ff
                jun 2, $ff
                jun 3, $ff
                jun 4, $ff
                jun 5, $ff
                jun 6, $ff
                jun 7, $ff
                jun 8, $ff
                jun 9, $ff
                jun 10, $ff
                jun 11, $ff
                jun 12, $ff
                jun 13, $ff
                jun 14, $ff
                jun 15, $ff

                jms 0, $ff
                jms 1, $ff
                jms 2, $ff
                jms 3, $ff
                jms 4, $ff
                jms 5, $ff
                jms 6, $ff
                jms 7, $ff
                jms 8, $ff
                jms 9, $ff
                jms 10, $ff
                jms 11, $ff
                jms 12, $ff
                jms 13, $ff
                jms 14, $ff
                jms 15, $ff

                isz 0, $ff
                isz 1, $ff
                isz 2, $ff
                isz 3, $ff
                isz 4, $ff
                isz 5, $ff
                isz 6, $ff
                isz 7, $ff
                isz 8, $ff
                isz 9, $ff
                isz 10, $ff
                isz 11, $ff
                isz 12, $ff
                isz 13, $ff
                isz 14, $ff
                isz 15, $ff
