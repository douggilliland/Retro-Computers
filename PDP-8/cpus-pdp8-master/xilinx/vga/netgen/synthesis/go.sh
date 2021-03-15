#!/bin/sh

B=/wide/opt/Xilinx/verilog/src/unisims
C=/wide/opt/Xilinx/verilog/src/uni9000

#cver
iverilog $B/LUT*.v $B/VCC.v $B/GND.v $B/INV.* $B/IBUF.v $B/OBUF.v $B/MUXCY.v $B/FDCE.v $B/FDE.v $B/MUXF5.v $B/FDP.v $B/FDR.v $B/FDC.v $B/FD.v $B/RAMB4_S1_S1.v $B/MULT_AND.v $B/XORCY.v $B/FDC_1.v $B/BUFGP.v  $B/BUFG.v $B/MUXF6.v fpga_synthesis.v


