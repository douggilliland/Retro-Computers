/**************************************************************************
* All undocumented instructions for 8085
**************************************************************************/

                .target "8085"

                * = $2000

                dsub
                arhl
                rdel
                rstv
                shlx
                lhlx

                ldhi $12
                ldsi $12

                jk $1234
                jk $12
                jui $1234
                jui $12

                jnk $1234
                jnk $12
                jnui $1234
                jnui $12
