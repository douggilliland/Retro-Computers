../cver/gplcver-2.12a.src/bin/cver  \
    +loadvpi=../pli/rf/pli_rf.so:vpi_compat_bootstrap \
    +define+use_rf_pli=1 \
    +define+use_fake_uart=1 \
    +define+sim_time_kw=1 \
    +showpc \
    +cycles=2000000 \
    +pc=07400 \
    test_pdp8.v
exit 0

