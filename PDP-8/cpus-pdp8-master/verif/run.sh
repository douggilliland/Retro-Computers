../cver/gplcver-2.12a.src/bin/cver  \
    +loadvpi=../pli/ide/pli_ide.so:vpi_compat_bootstrap \
    +define+use_fake_uart=1 \
    +showpc \
    +cycles=2000000 \
    +pc=07400 \
    test_pdp8.v
exit 0

#    +loadvpi=../pli/disassemble/pli_disassemble.so:vpi_compat_bootstrap \
#

cver \
    +loadvpi=../pli/ide/pli_ide.so:vpi_compat_bootstrap \
    +loadvpi=../pli/disassemble/pli_disassemble.so:vpi_compat_bootstrap \
    +showpc \
    +cycles=2000000 \
    +pc=07400 \
    test_pdp8.v
exit 0

cver \
    +loadvpi=../pli/ide/pli_ide.so:vpi_compat_bootstrap \
    +test=../tests/basic/user.mem +pc=0400 \
    +showpc \
    +cycles=100 \
    +define+no_fake_input=1 \
    test_pdp8.v
exit 0


#    +test=tss8_init.mem +pc=24200 \
#

#cver +showpc +test=../tests/diags/MAINDEC-08-D5FA.mem +pc=0150 +switches=0000 +cycles=200000 +loadvpi=../pli/ide/pli_ide.so:vpi_compat_bootstrap test_pdp8.v >zz

#cver +showpc +test=../tests/diags/MAINDEC-08-D5EB.mem +pc=0200 +switches=4000 +cycles=50000 +loadvpi=../pli/ide/pli_ide.so:vpi_compat_bootstrap test_pdp8.v >zz

#cver +cycles=1000000 +test=boot.mem +pc=7750 +loadvpi=../pli/ide/pli_ide.so:vpi_compat_bootstrap test_pdp8.v >yy2

#grep "rf: go\!" xx
#cat xx | ../utils/ushow/ushow 
