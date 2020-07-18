/**************************************************************************
* All undocumented instructions for 6502, compile it with the "-u" option!
**************************************************************************/

                .target "6502"

                .org $1000

Label           nop //This is a normal instruction.
                nop #$12
                nop $12
                nop $12,x
                nop $1234
                nop $1234,x

                kil
                jam
                hlt

                anc #$12
                alr #$12
                asr #$12
                arr #$12
                xaa #$12
                lax #$12
                axs #$12

                ahx $1234,y
                ahx ($12),y

                shx $1234,y

                shy $1234,x

                tas $1234,y

                las $1234,y
                lar $1234,y

                slo $12
                slo $12,x
                slo $1234
                slo $1234,x
                slo $1234,y
                slo ($12,x)
                slo ($12),y

                aso $12
                aso $12,x
                aso $1234
                aso $1234,x
                aso $1234,y
                aso ($12,x)
                aso ($12),y

                sre $12
                sre $12,x
                sre $1234
                sre $1234,x
                sre $1234,y
                sre ($12,x)
                sre ($12),y

                lse $12
                lse $12,x
                lse $1234
                lse $1234,x
                lse $1234,y
                lse ($12,x)
                lse ($12),y

                rla $12
                rla $12,x
                rla $1234
                rla $1234,x
                rla $1234,y
                rla ($12,x)
                rla ($12),y

                rra $12
                rra $12,x
                rra $1234
                rra $1234,x
                rra $1234,y
                rra ($12,x)
                rra ($12),y

                lax $12
                lax $12,y
                lax $1234
                lax $1234,y
                lax ($12,x)
                lax ($12),y

                sax $12
                sax $12,y
                sax $1234
                sax ($12,x)

                dcp $12
                dcp $12,x
                dcp $1234
                dcp $1234,x
                dcp $1234,y
                dcp ($12,x)
                dcp ($12),y

                isc $12
                isc $12,x
                isc $1234
                isc $1234,x
                isc $1234,y
                isc ($12,x)
                isc ($12),y

                isb $12
                isb $12,x
                isb $1234
                isb $1234,x
                isb $1234,y
                isb ($12,x)
                isb ($12),y
