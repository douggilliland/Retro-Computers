../cver/gplcver-2.12a.src/bin/cver  \
    +loadvpi=../pli/ide/pli_ide.so:vpi_compat_bootstrap \
    +test=../tests/basic/uart.mem +pc=00400 \
    +define+debug_vcd=1 \
    +showpc \
    +cycles=100000 \
    test_pdp8.v
exit 0

