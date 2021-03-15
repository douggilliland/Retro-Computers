verilator -cc -exe --trace --Mdir ./tmp --top-module test verilator_pdp8.v ../verilator/test.cpp ../verilator/ide.cpp && \
(cd tmp; make OPT="-O2" -f Vtest.mk)
