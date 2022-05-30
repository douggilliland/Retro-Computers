////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995-2006 Xilinx, Inc.  All rights reserved.
////////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor: Xilinx
// \   \   \/     Version: I.31
//  \   \         Application: netgen
//  /   /         Filename: fpga_synthesis.v
// /___/   /\     Timestamp: Fri Dec 29 10:06:07 2006
// \   \  /  \ 
//  \___\/\___\
//             
// Command	: -intstyle ise -insert_glbl true -w -dir netgen/synthesis -ofmt verilog -sim fpga.ngc fpga_synthesis.v 
// Device	: xc2s200-5-fg256
// Input file	: fpga.ngc
// Output file	: /mwave/work/nt/xess/xilinx/vga/netgen/synthesis/fpga_synthesis.v
// # of Modules	: 1
// Design Name	: fpga
// Xilinx        : /opt/Xilinx
//             
// Purpose:    
//     This verilog netlist is a verification model and uses simulation 
//     primitives which may not represent the true implementation of the 
//     device, however the netlist is functionally correct and should not 
//     be modified. This file cannot be synthesized and should only be used 
//     with supported simulation tools.
//             
// Reference:  
//     Development System Reference Guide, Chapter 23
//     Synthesis and Simulation Design Guide, Chapter 6
//             
////////////////////////////////////////////////////////////////////////////////

`timescale 1 ns/1 ps

module fpga (
  reset_n, ps2_clk, ps2_data, clka, vga_hsync_n, fpga_din_d0, vga_red0, vga_red1, vga_red2, vga_green0, vga_green1, vga_green2, vga_blue0, vga_blue1, 
vga_blue2, vga_vsync_n, fpga_d1, fpga_d2, fpga_d3, fpga_d4, fpga_d5, fpga_d6, fpga_d7
);
  input reset_n;
  input ps2_clk;
  input ps2_data;
  input clka;
  output vga_hsync_n;
  output fpga_din_d0;
  output vga_red0;
  output vga_red1;
  output vga_red2;
  output vga_green0;
  output vga_green1;
  output vga_green2;
  output vga_blue0;
  output vga_blue1;
  output vga_blue2;
  output vga_vsync_n;
  output fpga_d1;
  output fpga_d2;
  output fpga_d3;
  output fpga_d4;
  output fpga_d5;
  output fpga_d6;
  output fpga_d7;
  wire reset_n_IBUF_0;
  wire ps2_clk_IBUF_1;
  wire ps2_data_IBUF_2;
  wire vga_hsync_n_OBUF_3;
  wire clka_BUFGP_4;
  wire vga_vsync_n_OBUF_5;
  wire \vga/vgacore/vsync_6 ;
  wire \vga/vgacore/hsync_7 ;
  wire \vga/ps2/rdy_r_8 ;
  wire N2;
  wire N3;
  wire gray_cnt_FFd1_9;
  wire gray_cnt_FFd2_10;
  wire \gray_cnt_FFd2-In ;
  wire gray_cnt_Rst_inv;
  wire \vga/ram_wclk_11 ;
  wire \vga/_cmp_eq0000 ;
  wire \vga/_not0001 ;
  wire \vga/insert_crt_data ;
  wire \vga/_mux0000 ;
  wire \vga/vgacore/hblank_12 ;
  wire \vga/cursor_match ;
  wire \vga/charload_13 ;
  wire \vga/clearing ;
  wire \vga/charclk ;
  wire \vga/scancode_convert/strobe_out_14 ;
  wire \vga/crtclk_15 ;
  wire \vga/ram_we_n ;
  wire \vga/scancode_convert/key_up_16 ;
  wire \vga/pixel_hold<7>_inv ;
  wire \vga/Madd_ram_addr_videoR2 ;
  wire \vga/Madd_ram_addr_videoC2 ;
  wire \vga/N2 ;
  wire \vga/N4 ;
  wire \vga/N6 ;
  wire \vga/N7 ;
  wire \vga/N8 ;
  wire \vga/N10 ;
  wire \vga/N11 ;
  wire \vga/N12 ;
  wire \vga/N13 ;
  wire \vga/N14 ;
  wire \vga/N15 ;
  wire \vga/N16 ;
  wire \vga/N17 ;
  wire \vga/N20 ;
  wire \vga/N21 ;
  wire \vga/N22 ;
  wire \vga/N23 ;
  wire \vga/N24 ;
  wire \vga/N25 ;
  wire \vga/N26 ;
  wire \vga/N27 ;
  wire \vga/N28 ;
  wire \vga/N29 ;
  wire \vga/N30 ;
  wire \vga/N31 ;
  wire \vga/N32 ;
  wire \vga/N33 ;
  wire \vga/N34 ;
  wire \vga/N35 ;
  wire \vga/N37 ;
  wire \vga/N38 ;
  wire \vga/N39 ;
  wire \vga/N40 ;
  wire \vga/N41 ;
  wire \vga/N43 ;
  wire \vga/N44 ;
  wire \vga/N45 ;
  wire \vga/N47 ;
  wire \vga/N48 ;
  wire \vga/N49 ;
  wire \vga/N50 ;
  wire \vga/N53 ;
  wire \vga/N54 ;
  wire \vga/N55 ;
  wire \vga/N56 ;
  wire \vga/N57 ;
  wire \vga/N58 ;
  wire \vga/N59 ;
  wire \vga/N60 ;
  wire \vga/N61 ;
  wire \vga/N62 ;
  wire \vga/N63 ;
  wire \vga/N64 ;
  wire \vga/N65 ;
  wire \vga/N66 ;
  wire \vga/N67 ;
  wire \vga/N68 ;
  wire \vga/N69 ;
  wire \vga/N70 ;
  wire \vga/N71 ;
  wire \vga/N72 ;
  wire \vga/N73 ;
  wire \vga/N74 ;
  wire \vga/N75 ;
  wire \vga/N78 ;
  wire \vga/N79 ;
  wire \vga/N80 ;
  wire \vga/N81 ;
  wire \vga/N82 ;
  wire \vga/N83 ;
  wire \vga/N85 ;
  wire \vga/N86 ;
  wire \vga/N87 ;
  wire \vga/N88 ;
  wire \vga/N89 ;
  wire \vga/N90 ;
  wire \vga/N94 ;
  wire \vga/N95 ;
  wire \vga/N96 ;
  wire \vga/N98 ;
  wire \vga/N99 ;
  wire \vga/N101 ;
  wire \vga/N102 ;
  wire \vga/N104 ;
  wire \vga/N105 ;
  wire \vga/N106 ;
  wire \vga/N110 ;
  wire \vga/N111 ;
  wire \vga/N113 ;
  wire \vga/N114 ;
  wire \vga/N115 ;
  wire \vga/N116 ;
  wire \vga/N117 ;
  wire \vga/N118 ;
  wire \vga/N120 ;
  wire \vga/N121 ;
  wire \vga/N125 ;
  wire \vga/N126 ;
  wire \vga/N127 ;
  wire \vga/N128 ;
  wire \vga/N129 ;
  wire \vga/N130 ;
  wire \vga/N131 ;
  wire \vga/N132 ;
  wire \vga/N133 ;
  wire \vga/N134 ;
  wire \vga/N137 ;
  wire \vga/N138 ;
  wire \vga/N139 ;
  wire \vga/N142 ;
  wire \vga/N143 ;
  wire \vga/N144 ;
  wire \vga/N145 ;
  wire \vga/N146 ;
  wire \vga/N147 ;
  wire \vga/N149 ;
  wire \vga/N150 ;
  wire \vga/N151 ;
  wire \vga/N152 ;
  wire \vga/N155 ;
  wire \vga/N157 ;
  wire \vga/N159 ;
  wire \vga/N167 ;
  wire \vga/N170 ;
  wire \vga/N171 ;
  wire \vga/N172 ;
  wire \vga/N175 ;
  wire \vga/N176 ;
  wire \vga/N178 ;
  wire \vga/N179 ;
  wire \vga/N183 ;
  wire \vga/N184 ;
  wire \vga/N186 ;
  wire \vga/N190 ;
  wire \vga/N191 ;
  wire \vga/N192 ;
  wire \vga/N193 ;
  wire \vga/N194 ;
  wire \vga/N201 ;
  wire \vga/N205 ;
  wire \vga/N208 ;
  wire \vga/N213 ;
  wire \vga/N214 ;
  wire \vga/N215 ;
  wire \vga/N216 ;
  wire \vga/N218 ;
  wire \vga/N219 ;
  wire \vga/N221 ;
  wire \vga/N222 ;
  wire \vga/N224 ;
  wire \vga/N226 ;
  wire \vga/N01 ;
  wire \vga/N1101 ;
  wire \vga/rom_addr_char<2>_f5_17 ;
  wire \vga/N2123 ;
  wire \vga/N312 ;
  wire \vga/rom_addr_char<2>_f51_18 ;
  wire \vga/rom_addr_char<3>_f6_19 ;
  wire \vga/N412 ;
  wire \vga/N512 ;
  wire \vga/rom_addr_char<2>_f52_20 ;
  wire \vga/N612 ;
  wire \vga/N712 ;
  wire \vga/rom_addr_char<2>_f53_21 ;
  wire \vga/rom_addr_char<3>_f61_22 ;
  wire \vga/N912 ;
  wire \vga/N1011 ;
  wire \vga/rom_addr_char<2>_f54_23 ;
  wire \vga/N1111 ;
  wire \vga/N1211 ;
  wire \vga/rom_addr_char<2>_f55 ;
  wire \vga/rom_addr_char<3>_f62_24 ;
  wire \vga/N1311 ;
  wire \vga/N1411 ;
  wire \vga/rom_addr_char<2>_f56 ;
  wire \vga/N1511 ;
  wire \vga/N1611 ;
  wire \vga/rom_addr_char<2>_f57 ;
  wire \vga/rom_addr_char<3>_f63_25 ;
  wire \vga/rom_addr_char<4>11_26 ;
  wire \vga/N1711 ;
  wire \vga/N1811 ;
  wire \vga/rom_addr_char<2>_f58 ;
  wire \vga/rom_addr_char<2>11_27 ;
  wire \vga/N1911 ;
  wire \vga/N2011 ;
  wire \vga/N2111 ;
  wire \vga/rom_addr_char<2>_f59 ;
  wire \vga/rom_addr_char<2>2 ;
  wire \vga/N2211 ;
  wire \vga/rom_addr_char<4>_f5_28 ;
  wire \vga/N1112 ;
  wire \vga/N0112 ;
  wire \vga/N11123 ;
  wire \vga/N01123 ;
  wire \vga/N111234 ;
  wire \vga/rom_addr_char<2>_f512 ;
  wire \vga/N21234 ;
  wire \vga/N3123 ;
  wire \vga/rom_addr_char<2>_f511 ;
  wire \vga/rom_addr_char<3>_f612 ;
  wire \vga/N4123 ;
  wire \vga/N5 ;
  wire \vga/rom_addr_char<2>_f521 ;
  wire \vga/N6123 ;
  wire \vga/N7123 ;
  wire \vga/rom_addr_char<2>_f531 ;
  wire \vga/rom_addr_char<3>_f611 ;
  wire \vga/N8123 ;
  wire \vga/N9 ;
  wire \vga/rom_addr_char<2>_f541 ;
  wire \vga/N1012 ;
  wire \vga/N11112 ;
  wire \vga/rom_addr_char<2>_f551 ;
  wire \vga/rom_addr_char<3>_f621 ;
  wire \vga/N1212 ;
  wire \vga/N1312 ;
  wire \vga/rom_addr_char<2>_f561 ;
  wire \vga/N1412 ;
  wire \vga/N1512 ;
  wire \vga/rom_addr_char<2>_f571 ;
  wire \vga/rom_addr_char<3>_f631 ;
  wire \vga/N1612 ;
  wire \vga/N1712 ;
  wire \vga/N1812 ;
  wire \vga/rom_addr_char<2>_f581 ;
  wire \vga/N1912 ;
  wire \vga/N2012 ;
  wire \vga/rom_addr_char<2>_f591 ;
  wire \vga/rom_addr_char<3>_f64_29 ;
  wire \vga/N2112 ;
  wire \vga/N2212 ;
  wire \vga/rom_addr_char<2>_f510 ;
  wire \vga/N231 ;
  wire \vga/N241 ;
  wire \vga/rom_addr_char<2>_f5111 ;
  wire \vga/rom_addr_char<3>_f65 ;
  wire \vga/N251 ;
  wire \vga/rom_addr_char<5>_f5_30 ;
  wire \vga/N011234 ;
  wire \vga/N1112345 ;
  wire \vga/rom_addr_char<2>_f5123 ;
  wire \vga/N212345 ;
  wire \vga/N31234 ;
  wire \vga/rom_addr_char<2>_f5112 ;
  wire \vga/rom_addr_char<3>_f6123 ;
  wire \vga/N41234 ;
  wire \vga/N5123 ;
  wire \vga/rom_addr_char<2>_f5212 ;
  wire \vga/N61234 ;
  wire \vga/N71234 ;
  wire \vga/rom_addr_char<2>_f5312 ;
  wire \vga/rom_addr_char<3>_f6112 ;
  wire \vga/N81234 ;
  wire \vga/N91 ;
  wire \vga/rom_addr_char<2>_f5412 ;
  wire \vga/N10123 ;
  wire \vga/N111123 ;
  wire \vga/rom_addr_char<2>_f5512 ;
  wire \vga/rom_addr_char<3>_f6212 ;
  wire \vga/N12123 ;
  wire \vga/N13123 ;
  wire \vga/rom_addr_char<2>_f5612 ;
  wire \vga/N14123 ;
  wire \vga/N15123 ;
  wire \vga/rom_addr_char<2>_f5712 ;
  wire \vga/rom_addr_char<3>_f6312 ;
  wire \vga/N16123 ;
  wire \vga/N17123 ;
  wire \vga/N18123 ;
  wire \vga/rom_addr_char<2>_f5812 ;
  wire \vga/N19123 ;
  wire \vga/N20123 ;
  wire \vga/rom_addr_char<2>_f5912 ;
  wire \vga/rom_addr_char<3>_f641 ;
  wire \vga/N21123 ;
  wire \vga/N22123 ;
  wire \vga/rom_addr_char<2>_f5101 ;
  wire \vga/N2412 ;
  wire \vga/rom_addr_char<2>_f51112 ;
  wire \vga/rom_addr_char<3>_f651 ;
  wire \vga/N2512 ;
  wire \vga/rom_addr_char<5>_f51_31 ;
  wire \vga/N0112345 ;
  wire \vga/N11123456 ;
  wire \vga/rom_addr_char<2>_f51234 ;
  wire \vga/N2123456 ;
  wire \vga/N312345 ;
  wire \vga/rom_addr_char<2>_f51123 ;
  wire \vga/N412345 ;
  wire \vga/N51234 ;
  wire \vga/rom_addr_char<2>_f52123 ;
  wire \vga/rom_addr_char<3>_f61234 ;
  wire \vga/N612345 ;
  wire \vga/N712345 ;
  wire \vga/rom_addr_char<2>_f53123 ;
  wire \vga/N9123 ;
  wire \vga/rom_addr_char<2>_f54123 ;
  wire \vga/rom_addr_char<3>_f61123 ;
  wire \vga/N101234 ;
  wire \vga/N1110 ;
  wire \vga/rom_addr_char<2>_f55123 ;
  wire \vga/N121234 ;
  wire \vga/N131234 ;
  wire \vga/rom_addr_char<2>_f56123 ;
  wire \vga/rom_addr_char<3>_f62123 ;
  wire \vga/N141234 ;
  wire \vga/N151234 ;
  wire \vga/N161234 ;
  wire \vga/rom_addr_char<2>_f57123 ;
  wire \vga/N181234 ;
  wire \vga/rom_addr_char<2>_f58123 ;
  wire \vga/rom_addr_char<3>_f63123 ;
  wire \vga/N191234 ;
  wire \vga/N201234 ;
  wire \vga/rom_addr_char<2>_f59123 ;
  wire \vga/N211234 ;
  wire \vga/N221234 ;
  wire \vga/rom_addr_char<2>_f51012 ;
  wire \vga/rom_addr_char<3>_f6412 ;
  wire \vga/N23123 ;
  wire \vga/rom_addr_char<5>_f512 ;
  wire \vga/rom_addr_char<1>_mmx_out ;
  wire \vga/N01123456 ;
  wire \vga/N111234567 ;
  wire \vga/rom_addr_char<2>_f512345 ;
  wire \vga/N21234567 ;
  wire \vga/N3123456 ;
  wire \vga/rom_addr_char<2>_f511234 ;
  wire \vga/rom_addr_char<3>_f612345 ;
  wire \vga/N4123456 ;
  wire \vga/N512345 ;
  wire \vga/rom_addr_char<2>_f521234 ;
  wire \vga/N6123456 ;
  wire \vga/N7123456 ;
  wire \vga/rom_addr_char<2>_f531234 ;
  wire \vga/rom_addr_char<3>_f611234 ;
  wire \vga/N8123456 ;
  wire \vga/N91234 ;
  wire \vga/rom_addr_char<2>_f541234 ;
  wire \vga/N1012345 ;
  wire \vga/N1111234 ;
  wire \vga/rom_addr_char<2>_f551234 ;
  wire \vga/rom_addr_char<3>_f621234 ;
  wire \vga/N1212345 ;
  wire \vga/N1312345 ;
  wire \vga/rom_addr_char<2>_f561234 ;
  wire \vga/N1412345 ;
  wire \vga/N1512345 ;
  wire \vga/rom_addr_char<2>_f571234 ;
  wire \vga/rom_addr_char<3>_f631234 ;
  wire \vga/N1612345 ;
  wire \vga/rom_addr_char<1>112_32 ;
  wire \vga/N1712345 ;
  wire \vga/rom_addr_char<1>2_33 ;
  wire \vga/N1812345 ;
  wire \vga/rom_addr_char<3>_f5_34 ;
  wire \vga/N1912345 ;
  wire \vga/N2012345 ;
  wire \vga/rom_addr_char<2>_f581234 ;
  wire \vga/N2212345 ;
  wire \vga/rom_addr_char<2>_f591234 ;
  wire \vga/rom_addr_char<3>_f64123 ;
  wire \vga/N231234 ;
  wire \vga/rom_addr_char<5>_f5123 ;
  wire \vga/N011234567 ;
  wire \vga/rom_addr_char<4>11234 ;
  wire \vga/Madd_ram_addr_videoC_mand1 ;
  wire \vga/Madd_ram_addr_videoC1_mand1 ;
  wire \vga/N229 ;
  wire \vga/N230 ;
  wire \vga/Madd_ram_addr_videoC3_mand1 ;
  wire \vga/N2313 ;
  wire \vga/Madd_ram_addr_videoC4_mand1 ;
  wire \vga/N232 ;
  wire \vga/N233 ;
  wire \vga/crt/_cmp_eq0001 ;
  wire \vga/crt/_cmp_eq0004 ;
  wire \vga/crt/_not0010 ;
  wire \vga/crt/_not0006 ;
  wire \vga/crt/_not0007 ;
  wire \vga/crt/_not0008 ;
  wire \vga/crt/eol_35 ;
  wire \vga/crt/scroll_36 ;
  wire \vga/crt/newline_37 ;
  wire \vga/crt/_and0000_38 ;
  wire \vga/crt/_and0001_39 ;
  wire \vga/crt/Madd_ram_addrR2 ;
  wire \vga/crt/Madd_ram_addrC2 ;
  wire \vga/crt/cursor_v_Eqn_0 ;
  wire \vga/crt/cursor_v_Eqn_1 ;
  wire \vga/crt/cursor_v_Eqn_2 ;
  wire \vga/crt/cursor_v_Eqn_3 ;
  wire \vga/crt/cursor_v_Eqn_4 ;
  wire \vga/crt/cursor_v_Eqn_5 ;
  wire \vga/crt/Result<0>1 ;
  wire \vga/crt/cursor_h_Eqn_0 ;
  wire \vga/crt/Result<1>1 ;
  wire \vga/crt/cursor_h_Eqn_1 ;
  wire \vga/crt/Result<2>1 ;
  wire \vga/crt/cursor_h_Eqn_2 ;
  wire \vga/crt/Result<3>1 ;
  wire \vga/crt/cursor_h_Eqn_3 ;
  wire \vga/crt/Result<4>1 ;
  wire \vga/crt/cursor_h_Eqn_4 ;
  wire \vga/crt/Result<5>1 ;
  wire \vga/crt/cursor_h_Eqn_5 ;
  wire \vga/crt/cursor_h_Eqn_6 ;
  wire \vga/crt/N3 ;
  wire \vga/crt/Madd_ram_addrC_mand1 ;
  wire \vga/crt/Madd_ram_addrC1_mand1 ;
  wire \vga/crt/N8 ;
  wire \vga/crt/N9 ;
  wire \vga/crt/Madd_ram_addrC3_mand1 ;
  wire \vga/crt/N10 ;
  wire \vga/crt/Madd_ram_addrC4_mand1 ;
  wire \vga/crt/N11 ;
  wire \vga/crt/N12 ;
  wire \vga/crt/state_FFd1_40 ;
  wire \vga/crt/state_FFd2_41 ;
  wire \vga/crt/state_FFd3_42 ;
  wire \vga/crt/state_FFd1-In_43 ;
  wire \vga/crt/state_FFd2-In ;
  wire \vga/crt/state_FFd3-In ;
  wire \vga/crt/N91 ;
  wire \vga/crt/N16 ;
  wire \vga/vgacore/_mux0002 ;
  wire \vga/vgacore/_and0000 ;
  wire \vga/vgacore/_and0001_44 ;
  wire \vga/vgacore/hcnt_Eqn_1 ;
  wire \vga/vgacore/hcnt_Eqn_2 ;
  wire \vga/vgacore/hcnt_Eqn_3 ;
  wire \vga/vgacore/hcnt_Eqn_4 ;
  wire \vga/vgacore/hcnt_Eqn_5 ;
  wire \vga/vgacore/hcnt_Eqn_6 ;
  wire \vga/vgacore/hcnt_Eqn_7 ;
  wire \vga/vgacore/hcnt_Eqn_8 ;
  wire \vga/vgacore/hcnt_Eqn_9 ;
  wire \vga/vgacore/hcnt_Eqn_10 ;
  wire \vga/vgacore/hcnt_Eqn_bis_0 ;
  wire \vga/vgacore/vcnt_Eqn_1_45 ;
  wire \vga/vgacore/vcnt_Eqn_2 ;
  wire \vga/vgacore/vcnt_Eqn_3_46 ;
  wire \vga/vgacore/vcnt_Eqn_4 ;
  wire \vga/vgacore/vcnt_Eqn_5 ;
  wire \vga/vgacore/vcnt_Eqn_6 ;
  wire \vga/vgacore/vcnt_Eqn_7 ;
  wire \vga/vgacore/vcnt_Eqn_8 ;
  wire \vga/vgacore/vcnt_Eqn_9 ;
  wire \vga/vgacore/Result<0>1 ;
  wire \vga/vgacore/Result<1>1 ;
  wire \vga/vgacore/Result<2>1 ;
  wire \vga/vgacore/Result<3>1 ;
  wire \vga/vgacore/Result<4>1 ;
  wire \vga/vgacore/Result<5>1 ;
  wire \vga/vgacore/Result<6>1 ;
  wire \vga/vgacore/Result<7>1 ;
  wire \vga/vgacore/Result<8>1 ;
  wire \vga/vgacore/Result<9>1 ;
  wire \vga/vgacore/vcnt_Eqn_bis_0 ;
  wire \vga/vgacore/N4 ;
  wire \vga/vgacore/N5 ;
  wire \vga/vgacore/N6 ;
  wire \vga/vgacore/N7 ;
  wire \vga/vgacore/hcnt_Eqn_0_mand1 ;
  wire \vga/vgacore/vcnt_Eqn_0_mand1 ;
  wire \vga/vgacore/N0 ;
  wire \vga/vgacore/N51 ;
  wire \vga/vgacore/N61 ;
  wire \vga/ps2/error_r_47 ;
  wire \vga/ps2/error_x ;
  wire \vga/ps2/_cmp_eq0000 ;
  wire \vga/ps2/_cmp_eq0001 ;
  wire \vga/ps2/ps2_clk_fall_edge ;
  wire \vga/ps2/scancode_rdy ;
  wire \vga/ps2/ps2_clk_edge ;
  wire \vga/ps2/N5 ;
  wire \vga/scancode_convert/release_prefix_set ;
  wire \vga/scancode_convert/capslock_48 ;
  wire \vga/scancode_convert/shift_49 ;
  wire \vga/scancode_convert/capslock_toggle ;
  wire \vga/scancode_convert/state_FFd4_50 ;
  wire \vga/scancode_convert/_cmp_eq0000_51 ;
  wire \vga/scancode_convert/state_FFd2_52 ;
  wire \vga/scancode_convert/_cmp_eq0005 ;
  wire \vga/scancode_convert/state_FFd1_53 ;
  wire \vga/scancode_convert/state_FFd5_54 ;
  wire \vga/scancode_convert/_not0010 ;
  wire \vga/scancode_convert/_not0011 ;
  wire \vga/scancode_convert/_not0012 ;
  wire \vga/scancode_convert/_not0007_55 ;
  wire \vga/scancode_convert/_not0008 ;
  wire \vga/scancode_convert/_not0009 ;
  wire \vga/scancode_convert/state_FFd3_56 ;
  wire \vga/scancode_convert/raise ;
  wire \vga/scancode_convert/ctrl_57 ;
  wire \vga/scancode_convert/_and0000 ;
  wire \vga/scancode_convert/ctrl_set_58 ;
  wire \vga/scancode_convert/shift_set ;
  wire \vga/scancode_convert/_or0000 ;
  wire \vga/scancode_convert/release_prefix_59 ;
  wire \vga/scancode_convert/state_FFd6_60 ;
  wire \vga/scancode_convert/state_FFd1-In ;
  wire \vga/scancode_convert/state_FFd2-In_61 ;
  wire \vga/scancode_convert/state_FFd3-In_62 ;
  wire \vga/scancode_convert/state_FFd4-In ;
  wire \vga/scancode_convert/state_FFd5-In_63 ;
  wire \vga/scancode_convert/N31 ;
  wire \vga/scancode_convert/N10 ;
  wire \vga/scancode_convert/N11 ;
  wire \vga/scancode_convert/scancode_rom/N7 ;
  wire \vga/scancode_convert/scancode_rom/N9 ;
  wire \vga/scancode_convert/scancode_rom/N12 ;
  wire \vga/scancode_convert/scancode_rom/N18 ;
  wire \vga/scancode_convert/scancode_rom/N25 ;
  wire \vga/scancode_convert/scancode_rom/N28 ;
  wire \vga/scancode_convert/scancode_rom/N43 ;
  wire N44;
  wire \vga/pixel<8>_map785 ;
  wire N89;
  wire N116;
  wire N117;
  wire N124;
  wire N126;
  wire N128;
  wire \vga/crt/state_FFd3-In_map800 ;
  wire \vga/vgacore/_and0000_map807 ;
  wire \vga/vgacore/_and0000_map811 ;
  wire \vga/vgacore/_and0000_map817 ;
  wire \vga/vgacore/_and0000_map824 ;
  wire \vga/vgacore/_and0000_map825 ;
  wire N235;
  wire N237;
  wire \vga/scancode_convert/shift_set_map833 ;
  wire \vga/scancode_convert/shift_set_map836 ;
  wire \vga/scancode_convert/state_FFd4-In_map845 ;
  wire N293;
  wire N301;
  wire N305;
  wire N306;
  wire \vga/ps2/error_x_map855 ;
  wire \vga/charload2_map865 ;
  wire \vga/_and0000_map879 ;
  wire \vga/_and0000_map890 ;
  wire \vga/_and0000_map902 ;
  wire \vga/_and0000_map918 ;
  wire \vga/_and0000_map929 ;
  wire \vga/_and0000_map940 ;
  wire \vga/_and0000_map941 ;
  wire \vga/_and0000_map943 ;
  wire N560;
  wire N562;
  wire \vga/charload3_map953 ;
  wire \vga/charload5_map965 ;
  wire \vga/charload4_map979 ;
  wire \vga/charload7_map993 ;
  wire \vga/charload6_map1010 ;
  wire \vga/charload6_map1012 ;
  wire \vga/charload6_map1014 ;
  wire \vga/charload6_map1018 ;
  wire \vga/charload6_map1022 ;
  wire N786;
  wire \vga/ps2/_cmp_eq0001_map1032 ;
  wire \vga/ps2/_cmp_eq0001_map1035 ;
  wire \vga/ps2/_cmp_eq0001_map1041 ;
  wire \vga/ps2/_cmp_eq0001_map1047 ;
  wire N839;
  wire \vga/scancode_convert/scancode_rom/data<2>1_map1056 ;
  wire \vga/scancode_convert/scancode_rom/data<2>1_map1098 ;
  wire \vga/scancode_convert/scancode_rom/data<2>1_map1110 ;
  wire \vga/scancode_convert/scancode_rom/data<2>1_map1121 ;
  wire \vga/scancode_convert/scancode_rom/data<2>1_map1124 ;
  wire \vga/scancode_convert/scancode_rom/data<2>1_map1129 ;
  wire \vga/scancode_convert/scancode_rom/data<2>1_map1144 ;
  wire \vga/scancode_convert/scancode_rom/data<3>1_map1158 ;
  wire \vga/scancode_convert/scancode_rom/data<3>1_map1171 ;
  wire \vga/scancode_convert/scancode_rom/data<3>1_map1178 ;
  wire \vga/scancode_convert/scancode_rom/data<3>1_map1185 ;
  wire \vga/scancode_convert/scancode_rom/data<3>1_map1201 ;
  wire \vga/scancode_convert/scancode_rom/data<3>1_map1221 ;
  wire \vga/scancode_convert/scancode_rom/data<3>1_map1229 ;
  wire \vga/scancode_convert/scancode_rom/data<5>3_map1245 ;
  wire \vga/scancode_convert/scancode_rom/data<5>3_map1249 ;
  wire \vga/scancode_convert/scancode_rom/data<5>3_map1260 ;
  wire \vga/scancode_convert/scancode_rom/data<5>3_map1276 ;
  wire \vga/scancode_convert/scancode_rom/data<5>3_map1291 ;
  wire \vga/scancode_convert/scancode_rom/data<5>3_map1295 ;
  wire \vga/scancode_convert/scancode_rom/data<5>3_map1314 ;
  wire \vga/scancode_convert/scancode_rom/data<5>3_map1337 ;
  wire \vga/scancode_convert/scancode_rom/data<5>3_map1340 ;
  wire \vga/scancode_convert/scancode_rom/data<5>3_map1363 ;
  wire \vga/scancode_convert/scancode_rom/data<5>3_map1376 ;
  wire \vga/scancode_convert/scancode_rom/data<5>3_map1381 ;
  wire \vga/scancode_convert/scancode_rom/data<5>3_map1394 ;
  wire \vga/scancode_convert/scancode_rom/data<5>3_map1416 ;
  wire \vga/scancode_convert/scancode_rom/data<0>1_map1423 ;
  wire \vga/scancode_convert/scancode_rom/data<0>1_map1429 ;
  wire \vga/scancode_convert/scancode_rom/data<0>1_map1438 ;
  wire \vga/scancode_convert/scancode_rom/data<0>1_map1443 ;
  wire \vga/scancode_convert/scancode_rom/data<0>1_map1445 ;
  wire \vga/scancode_convert/scancode_rom/data<0>1_map1449 ;
  wire \vga/scancode_convert/scancode_rom/data<0>1_map1461 ;
  wire \vga/scancode_convert/scancode_rom/data<0>1_map1475 ;
  wire \vga/scancode_convert/scancode_rom/data<0>1_map1503 ;
  wire \vga/scancode_convert/scancode_rom/data<0>1_map1517 ;
  wire \vga/scancode_convert/scancode_rom/data<0>1_map1526 ;
  wire \vga/scancode_convert/scancode_rom/data<0>1_map1529 ;
  wire \vga/scancode_convert/scancode_rom/data<0>1_map1534 ;
  wire \vga/scancode_convert/scancode_rom/data<0>1_map1535 ;
  wire \vga/scancode_convert/scancode_rom/data<4>1_map1548 ;
  wire \vga/scancode_convert/scancode_rom/data<4>1_map1556 ;
  wire \vga/scancode_convert/scancode_rom/data<4>1_map1560 ;
  wire \vga/scancode_convert/scancode_rom/data<4>1_map1565 ;
  wire \vga/scancode_convert/scancode_rom/data<4>1_map1609 ;
  wire \vga/scancode_convert/scancode_rom/data<4>1_map1633 ;
  wire \vga/scancode_convert/scancode_rom/data<4>1_map1666 ;
  wire \vga/scancode_convert/scancode_rom/data<4>1_map1669 ;
  wire \vga/scancode_convert/scancode_rom/data<1>2_map1686 ;
  wire \vga/scancode_convert/scancode_rom/data<1>2_map1690 ;
  wire \vga/scancode_convert/scancode_rom/data<1>2_map1701 ;
  wire \vga/scancode_convert/scancode_rom/data<1>2_map1708 ;
  wire \vga/scancode_convert/scancode_rom/data<1>2_map1717 ;
  wire \vga/scancode_convert/scancode_rom/data<1>2_map1729 ;
  wire \vga/scancode_convert/scancode_rom/data<1>2_map1751 ;
  wire \vga/scancode_convert/scancode_rom/data<1>2_map1774 ;
  wire \vga/scancode_convert/scancode_rom/data<1>2_map1780 ;
  wire \vga/scancode_convert/scancode_rom/data<6>1_map1803 ;
  wire \vga/scancode_convert/scancode_rom/data<6>1_map1808 ;
  wire \vga/scancode_convert/scancode_rom/data<6>1_map1820 ;
  wire \vga/scancode_convert/scancode_rom/data<6>1_map1831 ;
  wire \vga/scancode_convert/scancode_rom/data<6>1_map1838 ;
  wire \vga/scancode_convert/scancode_rom/data<6>1_map1850 ;
  wire \vga/scancode_convert/scancode_rom/data<6>1_map1860 ;
  wire \vga/scancode_convert/scancode_rom/data<6>1_map1863 ;
  wire \vga/crt/cursor_v_1_rt_64 ;
  wire \vga/crt/cursor_v_2_rt_65 ;
  wire \vga/crt/cursor_v_3_rt_66 ;
  wire \vga/crt/cursor_v_4_rt_67 ;
  wire \vga/crt/cursor_h_1_rt_68 ;
  wire \vga/crt/cursor_h_2_rt_69 ;
  wire \vga/crt/cursor_h_3_rt_70 ;
  wire \vga/crt/cursor_h_4_rt_71 ;
  wire \vga/crt/cursor_h_5_rt_72 ;
  wire \vga/vgacore/hcnt_4_rt_73 ;
  wire \vga/ps2/timer_r_1_rt_74 ;
  wire \vga/ps2/timer_r_2_rt_75 ;
  wire \vga/ps2/timer_r_3_rt_76 ;
  wire \vga/ps2/timer_r_4_rt_77 ;
  wire \vga/ps2/timer_r_5_rt_78 ;
  wire \vga/ps2/timer_r_6_rt_79 ;
  wire \vga/ps2/timer_r_7_rt_80 ;
  wire \vga/ps2/timer_r_8_rt_81 ;
  wire \vga/ps2/timer_r_9_rt_82 ;
  wire \vga/ps2/timer_r_10_rt_83 ;
  wire \vga/ps2/timer_r_11_rt_84 ;
  wire \vga/ps2/timer_r_12_rt_85 ;
  wire \vga/vgacore/vcnt_8_rt_86 ;
  wire \vga/crt/cursor_v_5_rt_87 ;
  wire \vga/crt/cursor_v_5_rt1_88 ;
  wire \vga/crt/cursor_h_6_rt_89 ;
  wire \vga/ps2/timer_r_13_rt_90 ;
  wire N3078;
  wire N3079;
  wire N3080;
  wire N3081;
  wire N3084;
  wire N3085;
  wire N3087;
  wire N3089;
  wire N3100;
  wire N3104;
  wire N3106;
  wire N3108;
  wire N3110;
  wire N3112;
  wire N3116;
  wire N3117;
  wire N3118;
  wire N3119;
  wire N3120;
  wire N3121;
  wire N3124;
  wire N3126;
  wire N3130;
  wire N3132;
  wire N3136;
  wire N3141;
  wire N3142;
  wire N3144;
  wire N3146;
  wire N3148;
  wire N3150;
  wire N3158;
  wire N3160;
  wire N3162;
  wire N3164;
  wire N3166;
  wire N3170;
  wire N3172;
  wire N3174;
  wire N3175;
  wire N3177;
  wire N3178;
  wire N3180;
  wire \vga/scancode_convert/sc_1_1_91 ;
  wire \vga/scancode_convert/raise1_92 ;
  wire \vga/scancode_convert/sc_0_1_93 ;
  wire N3184;
  wire N3185;
  wire N3186;
  wire N3187;
  wire N3188;
  wire N3189;
  wire N3190;
  wire N3191;
  wire N3192;
  wire N3193;
  wire N3194;
  wire N3195;
  wire N3196;
  wire N3197;
  wire N3198;
  wire N3199;
  wire N3200;
  wire N3201;
  wire N3202;
  wire N3203;
  wire N3204;
  wire N3205;
  wire N3206;
  wire N3207;
  wire N3208;
  wire N3209;
  wire N3210;
  wire N3211;
  wire N3212;
  wire N3213;
  wire N3214;
  wire N3215;
  wire gray_cnt_FFd11;
  wire \vga/crtclk1 ;
  wire \vga/rom_addr_char_0_1_94 ;
  wire \vga/rom_addr_char_1_1_95 ;
  wire N3216;
  wire \vga/vgacore/vcnt_0_1_96 ;
  wire \vga/vgacore/vcnt_1_1_97 ;
  wire \vga/vgacore/vcnt_2_1_98 ;
  wire gray_cnt_Rst_inv1_INV_0_1_99;
  wire N3219;
  wire N3220;
  wire N3221;
  wire N3222;
  wire N3224;
  wire N3225;
  wire N3226;
  wire N3227;
  wire N3228;
  wire N3229;
  wire N3230;
  wire N3231;
  wire N3233;
  wire N3234;
  wire N3235;
  wire N3236;
  wire N3237;
  wire N3238;
  wire N3239;
  wire N3242;
  wire N3243;
  wire N3244;
  wire N3245;
  wire N3248;
  wire N3249;
  wire N3250;
  wire N3254;
  wire N3255;
  wire N3256;
  wire N3257;
  wire N3259;
  wire N3261;
  wire N3262;
  wire N3264;
  wire N3265;
  wire N3266;
  wire N3267;
  wire N3268;
  wire N3269;
  wire N3270;
  wire N3271;
  wire N3272;
  wire N3273;
  wire N3274;
  wire N3275;
  wire N3276;
  wire \NLW_vga/inst_Mram_mem8_DIB<0>_UNCONNECTED ;
  wire \NLW_vga/inst_Mram_mem8_DOA<0>_UNCONNECTED ;
  wire \NLW_vga/inst_Mram_mem11_DIB<0>_UNCONNECTED ;
  wire \NLW_vga/inst_Mram_mem11_DOA<0>_UNCONNECTED ;
  wire \NLW_vga/inst_Mram_mem21_DIB<0>_UNCONNECTED ;
  wire \NLW_vga/inst_Mram_mem21_DOA<0>_UNCONNECTED ;
  wire \NLW_vga/inst_Mram_mem31_DIB<0>_UNCONNECTED ;
  wire \NLW_vga/inst_Mram_mem31_DOA<0>_UNCONNECTED ;
  wire \NLW_vga/inst_Mram_mem41_DIB<0>_UNCONNECTED ;
  wire \NLW_vga/inst_Mram_mem41_DOA<0>_UNCONNECTED ;
  wire \NLW_vga/inst_Mram_mem51_DIB<0>_UNCONNECTED ;
  wire \NLW_vga/inst_Mram_mem51_DOA<0>_UNCONNECTED ;
  wire \NLW_vga/inst_Mram_mem61_DIB<0>_UNCONNECTED ;
  wire \NLW_vga/inst_Mram_mem61_DOA<0>_UNCONNECTED ;
  wire [8 : 8] pixel;
  wire [6 : 0] \vga/scancode_convert/ascii ;
  wire [0 : 0] \vga/pixelData ;
  wire [9 : 0] \vga/vgacore/vcnt ;
  wire [10 : 0] \vga/vgacore/hcnt ;
  wire [11 : 5] \vga/ram_addr_video ;
  wire [11 : 5] \vga/ram_addr_write ;
  wire [11 : 0] \vga/ram_addr_mux ;
  wire [7 : 0] \vga/pixel_hold ;
  wire [2 : 0] \vga/pclk ;
  wire [6 : 0] \vga/rom_addr_char ;
  wire [6 : 0] \vga/crt/ram_data ;
  wire [6 : 0] \vga/ram_data_out ;
  wire [9 : 0] \vga/ps2/sc_r ;
  wire [6 : 0] \vga/crt_data ;
  wire [6 : 0] \vga/crt/cursor_h ;
  wire [5 : 0] \vga/crt/cursor_v ;
  wire [7 : 0] \vga/_mux0002 ;
  wire [11 : 0] \vga/video_ram/ram_addr_w ;
  wire [2 : 0] \vga/pclk__mux0000 ;
  wire [10 : 5] \vga/Madd_ram_addr_video_Madd_cy ;
  wire [2 : 0] \vga/crt/write_delay ;
  wire [6 : 0] \vga/crt/_mux0002 ;
  wire [2 : 0] \vga/crt/write_delay__mux0000 ;
  wire [6 : 0] \vga/crt/Result ;
  wire [10 : 5] \vga/crt/Madd_ram_addr_Madd_cy ;
  wire [4 : 0] \vga/crt/Mcount_cursor_v_cy ;
  wire [5 : 0] \vga/crt/Mcount_cursor_h_cy ;
  wire [10 : 0] \vga/vgacore/Result ;
  wire [4 : 0] \vga/vgacore/Mcompar__cmp_lt0000_cy ;
  wire [9 : 0] \vga/vgacore/Mcount_hcnt_cy ;
  wire [8 : 0] \vga/vgacore/Mcount_vcnt_cy ;
  wire [13 : 1] \vga/ps2/_addsub0000 ;
  wire [13 : 0] \vga/ps2/timer_x ;
  wire [3 : 0] \vga/ps2/bitcnt_r ;
  wire [4 : 0] \vga/ps2/ps2_clk_r ;
  wire [13 : 0] \vga/ps2/timer_r ;
  wire [3 : 0] \vga/ps2/bitcnt_x ;
  wire [12 : 0] \vga/ps2/Madd__addsub0000_cy ;
  wire [5 : 0] \vga/scancode_convert/rom_data ;
  wire [6 : 6] \vga/scancode_convert/_mux0008 ;
  wire [6 : 0] \vga/scancode_convert/sc ;
  wire [2 : 0] \vga/scancode_convert/hold_count ;
  wire [2 : 0] \vga/scancode_convert/hold_count__mux0000 ;
  GND XST_GND (
    .G(N2)
  );
  VCC XST_VCC (
    .P(N3)
  );
  FDC gray_cnt_FFd2 (
    .D(\gray_cnt_FFd2-In ),
    .CLR(gray_cnt_Rst_inv),
    .C(clka_BUFGP_4),
    .Q(gray_cnt_FFd2_10)
  );
  FDC gray_cnt_FFd1 (
    .D(gray_cnt_FFd2_10),
    .CLR(gray_cnt_Rst_inv),
    .C(clka_BUFGP_4),
    .Q(gray_cnt_FFd11)
  );
  FDC \vga/crtclk  (
    .D(\vga/_not0001 ),
    .CLR(gray_cnt_Rst_inv),
    .C(gray_cnt_FFd1_9),
    .Q(\vga/crtclk1 )
  );
  FDC \vga/ram_wclk  (
    .D(\vga/_mux0000 ),
    .CLR(gray_cnt_Rst_inv1_INV_0_1_99),
    .C(gray_cnt_FFd1_9),
    .Q(\vga/ram_wclk_11 )
  );
  FDC_1 \vga/charload  (
    .D(\vga/_cmp_eq0000 ),
    .CLR(gray_cnt_Rst_inv),
    .C(gray_cnt_FFd1_9),
    .Q(\vga/charload_13 )
  );
  FDC \vga/crt_data_0  (
    .D(\vga/scancode_convert/ascii [0]),
    .CLR(gray_cnt_Rst_inv),
    .C(\vga/scancode_convert/strobe_out_14 ),
    .Q(\vga/crt_data [0])
  );
  FDC \vga/crt_data_1  (
    .D(\vga/scancode_convert/ascii [1]),
    .CLR(gray_cnt_Rst_inv),
    .C(\vga/scancode_convert/strobe_out_14 ),
    .Q(\vga/crt_data [1])
  );
  FDC \vga/crt_data_2  (
    .D(\vga/scancode_convert/ascii [2]),
    .CLR(gray_cnt_Rst_inv),
    .C(\vga/scancode_convert/strobe_out_14 ),
    .Q(\vga/crt_data [2])
  );
  FDC \vga/crt_data_3  (
    .D(\vga/scancode_convert/ascii [3]),
    .CLR(gray_cnt_Rst_inv),
    .C(\vga/scancode_convert/strobe_out_14 ),
    .Q(\vga/crt_data [3])
  );
  FDC \vga/crt_data_4  (
    .D(\vga/scancode_convert/ascii [4]),
    .CLR(gray_cnt_Rst_inv),
    .C(\vga/scancode_convert/strobe_out_14 ),
    .Q(\vga/crt_data [4])
  );
  FDC \vga/crt_data_5  (
    .D(\vga/scancode_convert/ascii [5]),
    .CLR(gray_cnt_Rst_inv),
    .C(\vga/scancode_convert/strobe_out_14 ),
    .Q(\vga/crt_data [5])
  );
  FDC \vga/crt_data_6  (
    .D(\vga/scancode_convert/ascii [6]),
    .CLR(gray_cnt_Rst_inv),
    .C(\vga/scancode_convert/strobe_out_14 ),
    .Q(\vga/crt_data [6])
  );
  FD \vga/rom_addr_char_0  (
    .D(\vga/ram_data_out [0]),
    .C(\vga/charclk ),
    .Q(\vga/rom_addr_char [0])
  );
  FD \vga/rom_addr_char_1  (
    .D(\vga/ram_data_out [1]),
    .C(\vga/charclk ),
    .Q(\vga/rom_addr_char [1])
  );
  FD \vga/rom_addr_char_2  (
    .D(\vga/ram_data_out [2]),
    .C(\vga/charclk ),
    .Q(\vga/rom_addr_char [2])
  );
  FD \vga/rom_addr_char_3  (
    .D(\vga/ram_data_out [3]),
    .C(\vga/charclk ),
    .Q(\vga/rom_addr_char [3])
  );
  FD \vga/rom_addr_char_4  (
    .D(\vga/ram_data_out [4]),
    .C(\vga/charclk ),
    .Q(\vga/rom_addr_char [4])
  );
  FD \vga/rom_addr_char_5  (
    .D(\vga/ram_data_out [5]),
    .C(\vga/charclk ),
    .Q(\vga/rom_addr_char [5])
  );
  FD \vga/rom_addr_char_6  (
    .D(\vga/ram_data_out [6]),
    .C(\vga/charclk ),
    .Q(\vga/rom_addr_char [6])
  );
  FD \vga/pixel_hold_0  (
    .D(\vga/_mux0002 [7]),
    .C(gray_cnt_FFd1_9),
    .Q(\vga/pixel_hold [0])
  );
  FD \vga/pixel_hold_1  (
    .D(\vga/_mux0002 [6]),
    .C(gray_cnt_FFd1_9),
    .Q(\vga/pixel_hold [1])
  );
  FD \vga/pixel_hold_2  (
    .D(\vga/_mux0002 [5]),
    .C(gray_cnt_FFd1_9),
    .Q(\vga/pixel_hold [2])
  );
  FD \vga/pixel_hold_3  (
    .D(\vga/_mux0002 [4]),
    .C(gray_cnt_FFd1_9),
    .Q(\vga/pixel_hold [3])
  );
  FD \vga/pixel_hold_4  (
    .D(\vga/_mux0002 [3]),
    .C(gray_cnt_FFd1_9),
    .Q(\vga/pixel_hold [4])
  );
  FD \vga/pixel_hold_5  (
    .D(\vga/_mux0002 [2]),
    .C(gray_cnt_FFd1_9),
    .Q(\vga/pixel_hold [5])
  );
  FD \vga/pixel_hold_6  (
    .D(\vga/_mux0002 [1]),
    .C(gray_cnt_FFd1_9),
    .Q(\vga/pixel_hold [6])
  );
  FD \vga/pixel_hold_7  (
    .D(\vga/_mux0002 [0]),
    .C(gray_cnt_FFd1_9),
    .Q(\vga/pixel_hold [7])
  );
  FDR \vga/pixelData_0  (
    .D(N3),
    .R(\vga/pixel_hold<7>_inv ),
    .C(gray_cnt_FFd1_9),
    .Q(\vga/pixelData [0])
  );
  FD \vga/video_ram/ram_addr_w_0  (
    .D(\vga/ram_addr_mux [0]),
    .C(\vga/ram_wclk_11 ),
    .Q(\vga/video_ram/ram_addr_w [0])
  );
  FD \vga/video_ram/ram_addr_w_1  (
    .D(\vga/ram_addr_mux [1]),
    .C(\vga/ram_wclk_11 ),
    .Q(\vga/video_ram/ram_addr_w [1])
  );
  FD \vga/video_ram/ram_addr_w_2  (
    .D(\vga/ram_addr_mux [2]),
    .C(\vga/ram_wclk_11 ),
    .Q(\vga/video_ram/ram_addr_w [2])
  );
  FD \vga/video_ram/ram_addr_w_3  (
    .D(\vga/ram_addr_mux [3]),
    .C(\vga/ram_wclk_11 ),
    .Q(\vga/video_ram/ram_addr_w [3])
  );
  FD \vga/video_ram/ram_addr_w_4  (
    .D(\vga/ram_addr_mux [4]),
    .C(\vga/ram_wclk_11 ),
    .Q(\vga/video_ram/ram_addr_w [4])
  );
  FD \vga/video_ram/ram_addr_w_5  (
    .D(\vga/ram_addr_mux [5]),
    .C(\vga/ram_wclk_11 ),
    .Q(\vga/video_ram/ram_addr_w [5])
  );
  FD \vga/video_ram/ram_addr_w_6  (
    .D(\vga/ram_addr_mux [6]),
    .C(\vga/ram_wclk_11 ),
    .Q(\vga/video_ram/ram_addr_w [6])
  );
  FD \vga/video_ram/ram_addr_w_7  (
    .D(\vga/ram_addr_mux [7]),
    .C(\vga/ram_wclk_11 ),
    .Q(\vga/video_ram/ram_addr_w [7])
  );
  FD \vga/video_ram/ram_addr_w_8  (
    .D(\vga/ram_addr_mux [8]),
    .C(\vga/ram_wclk_11 ),
    .Q(\vga/video_ram/ram_addr_w [8])
  );
  FD \vga/video_ram/ram_addr_w_9  (
    .D(\vga/ram_addr_mux [9]),
    .C(\vga/ram_wclk_11 ),
    .Q(\vga/video_ram/ram_addr_w [9])
  );
  FD \vga/video_ram/ram_addr_w_10  (
    .D(\vga/ram_addr_mux [10]),
    .C(\vga/ram_wclk_11 ),
    .Q(\vga/video_ram/ram_addr_w [10])
  );
  FD \vga/video_ram/ram_addr_w_11  (
    .D(\vga/ram_addr_mux [11]),
    .C(\vga/ram_wclk_11 ),
    .Q(\vga/video_ram/ram_addr_w [11])
  );
  FDP \vga/pclk_0  (
    .D(\vga/pclk__mux0000 [0]),
    .PRE(gray_cnt_Rst_inv),
    .C(gray_cnt_FFd1_9),
    .Q(\vga/pclk [0])
  );
  FDP \vga/pclk_1  (
    .D(\vga/pclk__mux0000 [1]),
    .PRE(gray_cnt_Rst_inv),
    .C(gray_cnt_FFd1_9),
    .Q(\vga/pclk [1])
  );
  FDP \vga/pclk_2  (
    .D(\vga/pclk__mux0000 [2]),
    .PRE(gray_cnt_Rst_inv),
    .C(gray_cnt_FFd1_9),
    .Q(\vga/pclk [2])
  );
  defparam \vga/char_rom/Mrom_data1 .INIT = 16'h2000;
  LUT4 \vga/char_rom/Mrom_data1  (
    .I0(\vga/vgacore/vcnt [0]),
    .I1(\vga/vgacore/vcnt [1]),
    .I2(\vga/vgacore/vcnt [2]),
    .I3(\vga/rom_addr_char [0]),
    .O(\vga/N2 )
  );
  defparam \vga/char_rom/Mrom_data3 .INIT = 16'h0049;
  LUT4 \vga/char_rom/Mrom_data3  (
    .I0(\vga/vgacore/vcnt_0_1_96 ),
    .I1(\vga/vgacore/vcnt_1_1_97 ),
    .I2(\vga/vgacore/vcnt_2_1_98 ),
    .I3(\vga/rom_addr_char_0_1_94 ),
    .O(\vga/N4 )
  );
  defparam \vga/char_rom/Mrom_data4 .INIT = 16'h5112;
  LUT4 \vga/char_rom/Mrom_data4  (
    .I0(\vga/vgacore/vcnt_0_1_96 ),
    .I1(\vga/vgacore/vcnt_1_1_97 ),
    .I2(\vga/vgacore/vcnt_2_1_98 ),
    .I3(\vga/rom_addr_char_0_1_94 ),
    .O(\vga/N6 )
  );
  defparam \vga/char_rom/Mrom_data5 .INIT = 16'h0020;
  LUT4 \vga/char_rom/Mrom_data5  (
    .I0(\vga/vgacore/vcnt_0_1_96 ),
    .I1(\vga/vgacore/vcnt_1_1_97 ),
    .I2(\vga/vgacore/vcnt_2_1_98 ),
    .I3(\vga/rom_addr_char_0_1_94 ),
    .O(\vga/N7 )
  );
  defparam \vga/char_rom/Mrom_data6 .INIT = 16'h0222;
  LUT4 \vga/char_rom/Mrom_data6  (
    .I0(\vga/vgacore/vcnt_0_1_96 ),
    .I1(\vga/rom_addr_char_0_1_94 ),
    .I2(\vga/vgacore/vcnt_1_1_97 ),
    .I3(\vga/vgacore/vcnt_2_1_98 ),
    .O(\vga/N8 )
  );
  defparam \vga/char_rom/Mrom_data7 .INIT = 16'h2403;
  LUT4 \vga/char_rom/Mrom_data7  (
    .I0(\vga/vgacore/vcnt_0_1_96 ),
    .I1(\vga/vgacore/vcnt_1_1_97 ),
    .I2(\vga/vgacore/vcnt_2_1_98 ),
    .I3(\vga/rom_addr_char_0_1_94 ),
    .O(\vga/N10 )
  );
  defparam \vga/char_rom/Mrom_data8 .INIT = 16'h522A;
  LUT4 \vga/char_rom/Mrom_data8  (
    .I0(\vga/vgacore/vcnt_0_1_96 ),
    .I1(\vga/vgacore/vcnt_1_1_97 ),
    .I2(\vga/rom_addr_char_0_1_94 ),
    .I3(\vga/vgacore/vcnt_2_1_98 ),
    .O(\vga/N11 )
  );
  defparam \vga/char_rom/Mrom_data9 .INIT = 8'h04;
  LUT3 \vga/char_rom/Mrom_data9  (
    .I0(\vga/vgacore/vcnt_1_1_97 ),
    .I1(\vga/vgacore/vcnt_2_1_98 ),
    .I2(\vga/rom_addr_char_0_1_94 ),
    .O(\vga/N12 )
  );
  defparam \vga/char_rom/Mrom_data10 .INIT = 16'h081C;
  LUT4 \vga/char_rom/Mrom_data10  (
    .I0(\vga/vgacore/vcnt [0]),
    .I1(\vga/vgacore/vcnt [1]),
    .I2(\vga/vgacore/vcnt [2]),
    .I3(\vga/rom_addr_char [0]),
    .O(\vga/N13 )
  );
  defparam \vga/char_rom/Mrom_data11 .INIT = 16'h2000;
  LUT4 \vga/char_rom/Mrom_data11  (
    .I0(\vga/vgacore/vcnt [1]),
    .I1(\vga/vgacore/vcnt [2]),
    .I2(\vga/vgacore/vcnt [0]),
    .I3(\vga/rom_addr_char [0]),
    .O(\vga/N14 )
  );
  defparam \vga/char_rom/Mrom_data12 .INIT = 16'h0020;
  LUT4 \vga/char_rom/Mrom_data12  (
    .I0(\vga/rom_addr_char [0]),
    .I1(\vga/vgacore/vcnt [1]),
    .I2(\vga/vgacore/vcnt [0]),
    .I3(\vga/vgacore/vcnt [2]),
    .O(\vga/N15 )
  );
  defparam \vga/char_rom/Mrom_data13 .INIT = 16'h0706;
  LUT4 \vga/char_rom/Mrom_data13  (
    .I0(\vga/vgacore/vcnt [1]),
    .I1(\vga/vgacore/vcnt [2]),
    .I2(\vga/rom_addr_char [0]),
    .I3(\vga/vgacore/vcnt [0]),
    .O(\vga/N16 )
  );
  defparam \vga/char_rom/Mrom_data14 .INIT = 16'h3646;
  LUT4 \vga/char_rom/Mrom_data14  (
    .I0(\vga/vgacore/vcnt [0]),
    .I1(\vga/vgacore/vcnt [1]),
    .I2(\vga/vgacore/vcnt [2]),
    .I3(\vga/rom_addr_char [0]),
    .O(\vga/N17 )
  );
  defparam \vga/char_rom/Mrom_data17 .INIT = 16'h1E36;
  LUT4 \vga/char_rom/Mrom_data17  (
    .I0(\vga/vgacore/vcnt [0]),
    .I1(\vga/vgacore/vcnt [1]),
    .I2(\vga/vgacore/vcnt [2]),
    .I3(\vga/rom_addr_char [0]),
    .O(\vga/N20 )
  );
  defparam \vga/char_rom/Mrom_data18 .INIT = 16'h2400;
  LUT4 \vga/char_rom/Mrom_data18  (
    .I0(\vga/vgacore/vcnt [0]),
    .I1(\vga/vgacore/vcnt [1]),
    .I2(\vga/vgacore/vcnt [2]),
    .I3(\vga/rom_addr_char [0]),
    .O(\vga/N21 )
  );
  defparam \vga/char_rom/Mrom_data19 .INIT = 16'h0608;
  LUT4 \vga/char_rom/Mrom_data19  (
    .I0(\vga/vgacore/vcnt [0]),
    .I1(\vga/vgacore/vcnt [1]),
    .I2(\vga/vgacore/vcnt [2]),
    .I3(\vga/rom_addr_char [0]),
    .O(\vga/N22 )
  );
  defparam \vga/char_rom/Mrom_data20 .INIT = 16'h7E36;
  LUT4 \vga/char_rom/Mrom_data20  (
    .I0(\vga/vgacore/vcnt [1]),
    .I1(\vga/vgacore/vcnt [2]),
    .I2(\vga/vgacore/vcnt [0]),
    .I3(\vga/rom_addr_char [0]),
    .O(\vga/N23 )
  );
  defparam \vga/char_rom/Mrom_data21 .INIT = 16'h5506;
  LUT4 \vga/char_rom/Mrom_data21  (
    .I0(\vga/vgacore/vcnt [1]),
    .I1(\vga/vgacore/vcnt [2]),
    .I2(\vga/rom_addr_char [0]),
    .I3(\vga/vgacore/vcnt [0]),
    .O(\vga/N24 )
  );
  defparam \vga/char_rom/Mrom_data22 .INIT = 16'h0796;
  LUT4 \vga/char_rom/Mrom_data22  (
    .I0(\vga/vgacore/vcnt [1]),
    .I1(\vga/vgacore/vcnt [2]),
    .I2(\vga/rom_addr_char [0]),
    .I3(\vga/vgacore/vcnt [0]),
    .O(\vga/N25 )
  );
  defparam \vga/char_rom/Mrom_data23 .INIT = 16'h4C89;
  LUT4 \vga/char_rom/Mrom_data23  (
    .I0(\vga/vgacore/vcnt [2]),
    .I1(\vga/rom_addr_char [0]),
    .I2(\vga/vgacore/vcnt [1]),
    .I3(\vga/vgacore/vcnt [0]),
    .O(\vga/N26 )
  );
  defparam \vga/char_rom/Mrom_data24 .INIT = 16'h1555;
  LUT4 \vga/char_rom/Mrom_data24  (
    .I0(\vga/rom_addr_char [0]),
    .I1(\vga/vgacore/vcnt [1]),
    .I2(\vga/vgacore/vcnt [0]),
    .I3(\vga/vgacore/vcnt [2]),
    .O(\vga/N27 )
  );
  defparam \vga/char_rom/Mrom_data25 .INIT = 16'h215F;
  LUT4 \vga/char_rom/Mrom_data25  (
    .I0(\vga/vgacore/vcnt_2_1_98 ),
    .I1(\vga/vgacore/vcnt [0]),
    .I2(\vga/vgacore/vcnt [1]),
    .I3(\vga/rom_addr_char [0]),
    .O(\vga/N28 )
  );
  defparam \vga/char_rom/Mrom_data26 .INIT = 16'h2AEA;
  LUT4 \vga/char_rom/Mrom_data26  (
    .I0(\vga/rom_addr_char_0_1_94 ),
    .I1(\vga/vgacore/vcnt_2_1_98 ),
    .I2(\vga/vgacore/vcnt [1]),
    .I3(\vga/vgacore/vcnt [0]),
    .O(\vga/N29 )
  );
  defparam \vga/char_rom/Mrom_data27 .INIT = 16'h1FFB;
  LUT4 \vga/char_rom/Mrom_data27  (
    .I0(\vga/vgacore/vcnt_0_1_96 ),
    .I1(\vga/rom_addr_char_0_1_94 ),
    .I2(\vga/vgacore/vcnt_2_1_98 ),
    .I3(\vga/vgacore/vcnt [1]),
    .O(\vga/N30 )
  );
  defparam \vga/char_rom/Mrom_data28 .INIT = 16'h31E2;
  LUT4 \vga/char_rom/Mrom_data28  (
    .I0(\vga/vgacore/vcnt [1]),
    .I1(\vga/vgacore/vcnt_2_1_98 ),
    .I2(\vga/rom_addr_char_0_1_94 ),
    .I3(\vga/vgacore/vcnt_0_1_96 ),
    .O(\vga/N31 )
  );
  defparam \vga/char_rom/Mrom_data29 .INIT = 16'h5562;
  LUT4 \vga/char_rom/Mrom_data29  (
    .I0(\vga/vgacore/vcnt_1_1_97 ),
    .I1(\vga/rom_addr_char_0_1_94 ),
    .I2(\vga/vgacore/vcnt_2_1_98 ),
    .I3(\vga/vgacore/vcnt_0_1_96 ),
    .O(\vga/N32 )
  );
  defparam \vga/char_rom/Mrom_data30 .INIT = 16'h2A2B;
  LUT4 \vga/char_rom/Mrom_data30  (
    .I0(\vga/rom_addr_char_0_1_94 ),
    .I1(\vga/vgacore/vcnt_2_1_98 ),
    .I2(\vga/vgacore/vcnt_1_1_97 ),
    .I3(\vga/vgacore/vcnt_0_1_96 ),
    .O(\vga/N33 )
  );
  defparam \vga/char_rom/Mrom_data31 .INIT = 16'h4F5F;
  LUT4 \vga/char_rom/Mrom_data31  (
    .I0(\vga/vgacore/vcnt_1_1_97 ),
    .I1(\vga/rom_addr_char_0_1_94 ),
    .I2(\vga/vgacore/vcnt_2_1_98 ),
    .I3(\vga/vgacore/vcnt_0_1_96 ),
    .O(\vga/N34 )
  );
  defparam \vga/char_rom/Mrom_data32 .INIT = 16'h0673;
  LUT4 \vga/char_rom/Mrom_data32  (
    .I0(\vga/vgacore/vcnt_0_1_96 ),
    .I1(\vga/vgacore/vcnt_1_1_97 ),
    .I2(\vga/rom_addr_char_0_1_94 ),
    .I3(\vga/vgacore/vcnt_2_1_98 ),
    .O(\vga/N35 )
  );
  defparam \vga/char_rom/Mrom_data34 .INIT = 16'h8004;
  LUT4 \vga/char_rom/Mrom_data34  (
    .I0(\vga/vgacore/vcnt_0_1_96 ),
    .I1(\vga/vgacore/vcnt_1_1_97 ),
    .I2(\vga/vgacore/vcnt_2_1_98 ),
    .I3(\vga/rom_addr_char_0_1_94 ),
    .O(\vga/N37 )
  );
  defparam \vga/char_rom/Mrom_data35 .INIT = 16'h4888;
  LUT4 \vga/char_rom/Mrom_data35  (
    .I0(\vga/vgacore/vcnt_2_1_98 ),
    .I1(\vga/rom_addr_char_0_1_94 ),
    .I2(\vga/vgacore/vcnt_1_1_97 ),
    .I3(\vga/vgacore/vcnt_0_1_96 ),
    .O(\vga/N38 )
  );
  defparam \vga/char_rom/Mrom_data36 .INIT = 16'h6064;
  LUT4 \vga/char_rom/Mrom_data36  (
    .I0(\vga/vgacore/vcnt_1_1_97 ),
    .I1(\vga/vgacore/vcnt_2_1_98 ),
    .I2(\vga/vgacore/vcnt_0_1_96 ),
    .I3(\vga/rom_addr_char_0_1_94 ),
    .O(\vga/N39 )
  );
  defparam \vga/char_rom/Mrom_data37 .INIT = 16'h15D5;
  LUT4 \vga/char_rom/Mrom_data37  (
    .I0(\vga/rom_addr_char_0_1_94 ),
    .I1(\vga/vgacore/vcnt_1_1_97 ),
    .I2(\vga/vgacore/vcnt_0_1_96 ),
    .I3(\vga/vgacore/vcnt_2_1_98 ),
    .O(\vga/N40 )
  );
  defparam \vga/char_rom/Mrom_data38 .INIT = 16'h4C88;
  LUT4 \vga/char_rom/Mrom_data38  (
    .I0(\vga/vgacore/vcnt_2_1_98 ),
    .I1(\vga/rom_addr_char_0_1_94 ),
    .I2(\vga/vgacore/vcnt_0_1_96 ),
    .I3(\vga/vgacore/vcnt_1_1_97 ),
    .O(\vga/N41 )
  );
  defparam \vga/char_rom/Mrom_data40 .INIT = 16'hDAD8;
  LUT4 \vga/char_rom/Mrom_data40  (
    .I0(\vga/vgacore/vcnt_1_1_97 ),
    .I1(\vga/rom_addr_char_0_1_94 ),
    .I2(\vga/vgacore/vcnt_2_1_98 ),
    .I3(\vga/vgacore/vcnt_0_1_96 ),
    .O(\vga/N43 )
  );
  defparam \vga/char_rom/Mrom_data41 .INIT = 16'h2400;
  LUT4 \vga/char_rom/Mrom_data41  (
    .I0(\vga/vgacore/vcnt_2_1_98 ),
    .I1(\vga/vgacore/vcnt_1_1_97 ),
    .I2(\vga/rom_addr_char_0_1_94 ),
    .I3(\vga/vgacore/vcnt_0_1_96 ),
    .O(\vga/N44 )
  );
  defparam \vga/char_rom/Mrom_data42 .INIT = 16'h6266;
  LUT4 \vga/char_rom/Mrom_data42  (
    .I0(\vga/vgacore/vcnt_1_1_97 ),
    .I1(\vga/vgacore/vcnt_2_1_98 ),
    .I2(\vga/rom_addr_char_0_1_94 ),
    .I3(\vga/vgacore/vcnt_0_1_96 ),
    .O(\vga/N45 )
  );
  defparam \vga/char_rom/Mrom_data43 .INIT = 16'h0600;
  LUT4 \vga/char_rom/Mrom_data43  (
    .I0(\vga/vgacore/vcnt_0_1_96 ),
    .I1(\vga/vgacore/vcnt_1_1_97 ),
    .I2(\vga/vgacore/vcnt_2_1_98 ),
    .I3(\vga/rom_addr_char_0_1_94 ),
    .O(\vga/N47 )
  );
  defparam \vga/char_rom/Mrom_data44 .INIT = 16'h71E3;
  LUT4 \vga/char_rom/Mrom_data44  (
    .I0(\vga/vgacore/vcnt_0_1_96 ),
    .I1(\vga/vgacore/vcnt_2_1_98 ),
    .I2(\vga/rom_addr_char_0_1_94 ),
    .I3(\vga/vgacore/vcnt_1_1_97 ),
    .O(\vga/N48 )
  );
  defparam \vga/char_rom/Mrom_data45 .INIT = 16'h242A;
  LUT4 \vga/char_rom/Mrom_data45  (
    .I0(\vga/vgacore/vcnt_0_1_96 ),
    .I1(\vga/vgacore/vcnt_1_1_97 ),
    .I2(\vga/vgacore/vcnt_2_1_98 ),
    .I3(\vga/rom_addr_char_0_1_94 ),
    .O(\vga/N49 )
  );
  defparam \vga/char_rom/Mrom_data46 .INIT = 16'h0602;
  LUT4 \vga/char_rom/Mrom_data46  (
    .I0(\vga/vgacore/vcnt_0_1_96 ),
    .I1(\vga/vgacore/vcnt_2_1_98 ),
    .I2(\vga/rom_addr_char_0_1_94 ),
    .I3(\vga/vgacore/vcnt_1_1_97 ),
    .O(\vga/N50 )
  );
  defparam \vga/char_rom/Mrom_data49 .INIT = 16'h0020;
  LUT4 \vga/char_rom/Mrom_data49  (
    .I0(\vga/rom_addr_char_0_1_94 ),
    .I1(\vga/vgacore/vcnt_0_1_96 ),
    .I2(\vga/vgacore/vcnt_1_1_97 ),
    .I3(\vga/vgacore/vcnt_2_1_98 ),
    .O(\vga/N53 )
  );
  defparam \vga/char_rom/Mrom_data50 .INIT = 16'h4501;
  LUT4 \vga/char_rom/Mrom_data50  (
    .I0(\vga/vgacore/vcnt_0_1_96 ),
    .I1(\vga/vgacore/vcnt_2_1_98 ),
    .I2(\vga/rom_addr_char_0_1_94 ),
    .I3(\vga/vgacore/vcnt_1_1_97 ),
    .O(\vga/N54 )
  );
  defparam \vga/char_rom/Mrom_data51 .INIT = 8'h49;
  LUT3 \vga/char_rom/Mrom_data51  (
    .I0(\vga/vgacore/vcnt_0_1_96 ),
    .I1(\vga/vgacore/vcnt_1_1_97 ),
    .I2(\vga/vgacore/vcnt_2_1_98 ),
    .O(\vga/N55 )
  );
  defparam \vga/char_rom/Mrom_data52 .INIT = 16'h297F;
  LUT4 \vga/char_rom/Mrom_data52  (
    .I0(\vga/vgacore/vcnt_1_1_97 ),
    .I1(\vga/vgacore/vcnt_2_1_98 ),
    .I2(\vga/vgacore/vcnt_0_1_96 ),
    .I3(\vga/rom_addr_char_0_1_94 ),
    .O(\vga/N56 )
  );
  defparam \vga/char_rom/Mrom_data53 .INIT = 16'h0549;
  LUT4 \vga/char_rom/Mrom_data53  (
    .I0(\vga/vgacore/vcnt_0_1_96 ),
    .I1(\vga/vgacore/vcnt_1_1_97 ),
    .I2(\vga/vgacore/vcnt_2_1_98 ),
    .I3(\vga/rom_addr_char_0_1_94 ),
    .O(\vga/N57 )
  );
  defparam \vga/char_rom/Mrom_data54 .INIT = 16'h2949;
  LUT4 \vga/char_rom/Mrom_data54  (
    .I0(\vga/vgacore/vcnt_0_1_96 ),
    .I1(\vga/vgacore/vcnt_1_1_97 ),
    .I2(\vga/vgacore/vcnt_2_1_98 ),
    .I3(\vga/rom_addr_char_0_1_94 ),
    .O(\vga/N58 )
  );
  defparam \vga/char_rom/Mrom_data55 .INIT = 16'h2441;
  LUT4 \vga/char_rom/Mrom_data55  (
    .I0(\vga/vgacore/vcnt_0_1_96 ),
    .I1(\vga/vgacore/vcnt_1_1_97 ),
    .I2(\vga/vgacore/vcnt_2_1_98 ),
    .I3(\vga/rom_addr_char_0_1_94 ),
    .O(\vga/N59 )
  );
  defparam \vga/char_rom/Mrom_data56 .INIT = 16'h0914;
  LUT4 \vga/char_rom/Mrom_data56  (
    .I0(\vga/vgacore/vcnt_0_1_96 ),
    .I1(\vga/vgacore/vcnt_1_1_97 ),
    .I2(\vga/vgacore/vcnt_2_1_98 ),
    .I3(\vga/rom_addr_char_0_1_94 ),
    .O(\vga/N60 )
  );
  defparam \vga/char_rom/Mrom_data57 .INIT = 8'h15;
  LUT3 \vga/char_rom/Mrom_data57  (
    .I0(\vga/vgacore/vcnt_0_1_96 ),
    .I1(\vga/vgacore/vcnt_1_1_97 ),
    .I2(\vga/rom_addr_char_0_1_94 ),
    .O(\vga/N61 )
  );
  defparam \vga/char_rom/Mrom_data58 .INIT = 16'h4149;
  LUT4 \vga/char_rom/Mrom_data58  (
    .I0(\vga/vgacore/vcnt_0_1_96 ),
    .I1(\vga/vgacore/vcnt_1_1_97 ),
    .I2(\vga/vgacore/vcnt_2_1_98 ),
    .I3(\vga/rom_addr_char_0_1_94 ),
    .O(\vga/N62 )
  );
  defparam \vga/char_rom/Mrom_data59 .INIT = 16'h4941;
  LUT4 \vga/char_rom/Mrom_data59  (
    .I0(\vga/vgacore/vcnt_0_1_96 ),
    .I1(\vga/vgacore/vcnt_1_1_97 ),
    .I2(\vga/vgacore/vcnt_2_1_98 ),
    .I3(\vga/rom_addr_char_0_1_94 ),
    .O(\vga/N63 )
  );
  defparam \vga/char_rom/Mrom_data60 .INIT = 16'h4941;
  LUT4 \vga/char_rom/Mrom_data60  (
    .I0(\vga/vgacore/vcnt_2_1_98 ),
    .I1(\vga/vgacore/vcnt_1_1_97 ),
    .I2(\vga/vgacore/vcnt_0_1_96 ),
    .I3(\vga/rom_addr_char_0_1_94 ),
    .O(\vga/N64 )
  );
  defparam \vga/char_rom/Mrom_data61 .INIT = 16'h4108;
  LUT4 \vga/char_rom/Mrom_data61  (
    .I0(\vga/vgacore/vcnt_0_1_96 ),
    .I1(\vga/vgacore/vcnt_1_1_97 ),
    .I2(\vga/vgacore/vcnt_2_1_98 ),
    .I3(\vga/rom_addr_char_0_1_94 ),
    .O(\vga/N65 )
  );
  defparam \vga/char_rom/Mrom_data62 .INIT = 16'h2420;
  LUT4 \vga/char_rom/Mrom_data62  (
    .I0(\vga/vgacore/vcnt_0_1_96 ),
    .I1(\vga/vgacore/vcnt_1_1_97 ),
    .I2(\vga/rom_addr_char_0_1_94 ),
    .I3(\vga/vgacore/vcnt_2_1_98 ),
    .O(\vga/N66 )
  );
  defparam \vga/char_rom/Mrom_data63 .INIT = 16'h0240;
  LUT4 \vga/char_rom/Mrom_data63  (
    .I0(\vga/vgacore/vcnt_0_1_96 ),
    .I1(\vga/vgacore/vcnt_1_1_97 ),
    .I2(\vga/vgacore/vcnt_2_1_98 ),
    .I3(\vga/rom_addr_char_0_1_94 ),
    .O(\vga/N67 )
  );
  defparam \vga/char_rom/Mrom_data64 .INIT = 16'h2403;
  LUT4 \vga/char_rom/Mrom_data64  (
    .I0(\vga/rom_addr_char_0_1_94 ),
    .I1(\vga/vgacore/vcnt_1_1_97 ),
    .I2(\vga/vgacore/vcnt_2_1_98 ),
    .I3(\vga/vgacore/vcnt_0_1_96 ),
    .O(\vga/N68 )
  );
  defparam \vga/char_rom/Mrom_data65 .INIT = 16'h4919;
  LUT4 \vga/char_rom/Mrom_data65  (
    .I0(\vga/vgacore/vcnt_0_1_96 ),
    .I1(\vga/vgacore/vcnt_1_1_97 ),
    .I2(\vga/vgacore/vcnt_2_1_98 ),
    .I3(\vga/rom_addr_char_0_1_94 ),
    .O(\vga/N69 )
  );
  defparam \vga/char_rom/Mrom_data66 .INIT = 16'h4001;
  LUT4 \vga/char_rom/Mrom_data66  (
    .I0(\vga/vgacore/vcnt_0_1_96 ),
    .I1(\vga/vgacore/vcnt_1_1_97 ),
    .I2(\vga/vgacore/vcnt_2_1_98 ),
    .I3(\vga/rom_addr_char_0_1_94 ),
    .O(\vga/N70 )
  );
  defparam \vga/char_rom/Mrom_data67 .INIT = 16'h2400;
  LUT4 \vga/char_rom/Mrom_data67  (
    .I0(\vga/vgacore/vcnt_1_1_97 ),
    .I1(\vga/vgacore/vcnt_0_1_96 ),
    .I2(\vga/rom_addr_char_0_1_94 ),
    .I3(\vga/vgacore/vcnt_2_1_98 ),
    .O(\vga/N71 )
  );
  defparam \vga/char_rom/Mrom_data68 .INIT = 16'h0814;
  LUT4 \vga/char_rom/Mrom_data68  (
    .I0(\vga/vgacore/vcnt_0_1_96 ),
    .I1(\vga/vgacore/vcnt_1_1_97 ),
    .I2(\vga/vgacore/vcnt_2_1_98 ),
    .I3(\vga/rom_addr_char_0_1_94 ),
    .O(\vga/N72 )
  );
  defparam \vga/char_rom/Mrom_data69 .INIT = 16'h4143;
  LUT4 \vga/char_rom/Mrom_data69  (
    .I0(\vga/vgacore/vcnt_0_1_96 ),
    .I1(\vga/vgacore/vcnt_1_1_97 ),
    .I2(\vga/vgacore/vcnt_2_1_98 ),
    .I3(\vga/rom_addr_char_0_1_94 ),
    .O(\vga/N73 )
  );
  defparam \vga/char_rom/Mrom_data70 .INIT = 16'h2BAA;
  LUT4 \vga/char_rom/Mrom_data70  (
    .I0(\vga/rom_addr_char_0_1_94 ),
    .I1(\vga/vgacore/vcnt_1_1_97 ),
    .I2(\vga/vgacore/vcnt_0_1_96 ),
    .I3(\vga/vgacore/vcnt_2_1_98 ),
    .O(\vga/N74 )
  );
  defparam \vga/char_rom/Mrom_data71 .INIT = 16'h8004;
  LUT4 \vga/char_rom/Mrom_data71  (
    .I0(\vga/vgacore/vcnt_1_1_97 ),
    .I1(\vga/vgacore/vcnt_0_1_96 ),
    .I2(\vga/vgacore/vcnt_2_1_98 ),
    .I3(\vga/rom_addr_char_0_1_94 ),
    .O(\vga/N75 )
  );
  defparam \vga/char_rom/Mrom_data74 .INIT = 16'h5444;
  LUT4 \vga/char_rom/Mrom_data74  (
    .I0(\vga/vgacore/vcnt_0_1_96 ),
    .I1(\vga/vgacore/vcnt_1_1_97 ),
    .I2(\vga/vgacore/vcnt_2_1_98 ),
    .I3(\vga/rom_addr_char_0_1_94 ),
    .O(\vga/N78 )
  );
  defparam \vga/char_rom/Mrom_data75 .INIT = 16'hA409;
  LUT4 \vga/char_rom/Mrom_data75  (
    .I0(\vga/vgacore/vcnt_0_1_96 ),
    .I1(\vga/vgacore/vcnt_1_1_97 ),
    .I2(\vga/vgacore/vcnt_2_1_98 ),
    .I3(\vga/rom_addr_char_0_1_94 ),
    .O(\vga/N79 )
  );
  defparam \vga/char_rom/Mrom_data76 .INIT = 16'h086C;
  LUT4 \vga/char_rom/Mrom_data76  (
    .I0(\vga/vgacore/vcnt_1_1_97 ),
    .I1(\vga/vgacore/vcnt_2_1_98 ),
    .I2(\vga/vgacore/vcnt_0_1_96 ),
    .I3(\vga/rom_addr_char_0_1_94 ),
    .O(\vga/N80 )
  );
  defparam \vga/char_rom/Mrom_data77 .INIT = 16'h06AF;
  LUT4 \vga/char_rom/Mrom_data77  (
    .I0(\vga/vgacore/vcnt_1_1_97 ),
    .I1(\vga/vgacore/vcnt_2_1_98 ),
    .I2(\vga/rom_addr_char_0_1_94 ),
    .I3(\vga/vgacore/vcnt_0_1_96 ),
    .O(\vga/N81 )
  );
  defparam \vga/char_rom/Mrom_data78 .INIT = 16'h0600;
  LUT4 \vga/char_rom/Mrom_data78  (
    .I0(\vga/rom_addr_char_0_1_94 ),
    .I1(\vga/vgacore/vcnt_2_1_98 ),
    .I2(\vga/vgacore/vcnt_0_1_96 ),
    .I3(\vga/vgacore/vcnt_1_1_97 ),
    .O(\vga/N82 )
  );
  defparam \vga/char_rom/Mrom_data79 .INIT = 16'h1E22;
  LUT4 \vga/char_rom/Mrom_data79  (
    .I0(\vga/vgacore/vcnt_2_1_98 ),
    .I1(\vga/rom_addr_char_0_1_94 ),
    .I2(\vga/vgacore/vcnt_0_1_96 ),
    .I3(\vga/vgacore/vcnt_1_1_97 ),
    .O(\vga/N83 )
  );
  defparam \vga/char_rom/Mrom_data81 .INIT = 16'h64E2;
  LUT4 \vga/char_rom/Mrom_data81  (
    .I0(\vga/vgacore/vcnt_1_1_97 ),
    .I1(\vga/vgacore/vcnt_2_1_98 ),
    .I2(\vga/rom_addr_char_0_1_94 ),
    .I3(\vga/vgacore/vcnt_0_1_96 ),
    .O(\vga/N85 )
  );
  defparam \vga/char_rom/Mrom_data82 .INIT = 16'h6040;
  LUT4 \vga/char_rom/Mrom_data82  (
    .I0(\vga/vgacore/vcnt_1_1_97 ),
    .I1(\vga/vgacore/vcnt_0_1_96 ),
    .I2(\vga/vgacore/vcnt_2_1_98 ),
    .I3(\vga/rom_addr_char_0_1_94 ),
    .O(\vga/N86 )
  );
  defparam \vga/char_rom/Mrom_data83 .INIT = 16'h36CC;
  LUT4 \vga/char_rom/Mrom_data83  (
    .I0(\vga/rom_addr_char_0_1_94 ),
    .I1(\vga/vgacore/vcnt_1_1_97 ),
    .I2(\vga/vgacore/vcnt_0_1_96 ),
    .I3(\vga/vgacore/vcnt_2_1_98 ),
    .O(\vga/N87 )
  );
  defparam \vga/char_rom/Mrom_data84 .INIT = 16'h414C;
  LUT4 \vga/char_rom/Mrom_data84  (
    .I0(\vga/vgacore/vcnt_0_1_96 ),
    .I1(\vga/vgacore/vcnt_1_1_97 ),
    .I2(\vga/vgacore/vcnt_2_1_98 ),
    .I3(\vga/rom_addr_char_0_1_94 ),
    .O(\vga/N88 )
  );
  defparam \vga/char_rom/Mrom_data85 .INIT = 16'h7060;
  LUT4 \vga/char_rom/Mrom_data85  (
    .I0(\vga/vgacore/vcnt_1_1_97 ),
    .I1(\vga/vgacore/vcnt_2_1_98 ),
    .I2(\vga/rom_addr_char_0_1_94 ),
    .I3(\vga/vgacore/vcnt_0_1_96 ),
    .O(\vga/N89 )
  );
  defparam \vga/char_rom/Mrom_data86 .INIT = 16'h0001;
  LUT4 \vga/char_rom/Mrom_data86  (
    .I0(\vga/vgacore/vcnt_0_1_96 ),
    .I1(\vga/vgacore/vcnt_1_1_97 ),
    .I2(\vga/vgacore/vcnt_2_1_98 ),
    .I3(\vga/rom_addr_char_0_1_94 ),
    .O(\vga/N90 )
  );
  defparam \vga/char_rom/Mrom_data89 .INIT = 16'h1D5D;
  LUT4 \vga/char_rom/Mrom_data89  (
    .I0(\vga/rom_addr_char_0_1_94 ),
    .I1(\vga/vgacore/vcnt_0_1_96 ),
    .I2(\vga/vgacore/vcnt_2_1_98 ),
    .I3(\vga/vgacore/vcnt_1_1_97 ),
    .O(\vga/N94 )
  );
  defparam \vga/char_rom/Mrom_data90 .INIT = 16'h0427;
  LUT4 \vga/char_rom/Mrom_data90  (
    .I0(\vga/rom_addr_char_0_1_94 ),
    .I1(\vga/vgacore/vcnt_1_1_97 ),
    .I2(\vga/vgacore/vcnt_0_1_96 ),
    .I3(\vga/vgacore/vcnt_2_1_98 ),
    .O(\vga/N95 )
  );
  defparam \vga/char_rom/Mrom_data91 .INIT = 16'h34E1;
  LUT4 \vga/char_rom/Mrom_data91  (
    .I0(\vga/vgacore/vcnt_0_1_96 ),
    .I1(\vga/vgacore/vcnt_1_1_97 ),
    .I2(\vga/rom_addr_char_0_1_94 ),
    .I3(\vga/vgacore/vcnt_2_1_98 ),
    .O(\vga/N96 )
  );
  defparam \vga/char_rom/Mrom_data93 .INIT = 16'h0860;
  LUT4 \vga/char_rom/Mrom_data93  (
    .I0(\vga/vgacore/vcnt_0_1_96 ),
    .I1(\vga/vgacore/vcnt_1_1_97 ),
    .I2(\vga/vgacore/vcnt_2_1_98 ),
    .I3(\vga/rom_addr_char_0_1_94 ),
    .O(\vga/N98 )
  );
  defparam \vga/char_rom/Mrom_data94 .INIT = 16'h7F49;
  LUT4 \vga/char_rom/Mrom_data94  (
    .I0(\vga/vgacore/vcnt_0_1_96 ),
    .I1(\vga/vgacore/vcnt_1_1_97 ),
    .I2(\vga/vgacore/vcnt_2_1_98 ),
    .I3(\vga/rom_addr_char_0_1_94 ),
    .O(\vga/N99 )
  );
  defparam \vga/char_rom/Mrom_data96 .INIT = 16'h4912;
  LUT4 \vga/char_rom/Mrom_data96  (
    .I0(\vga/vgacore/vcnt_0_1_96 ),
    .I1(\vga/vgacore/vcnt_1_1_97 ),
    .I2(\vga/vgacore/vcnt_2_1_98 ),
    .I3(\vga/rom_addr_char_0_1_94 ),
    .O(\vga/N101 )
  );
  defparam \vga/char_rom/Mrom_data97 .INIT = 16'h4149;
  LUT4 \vga/char_rom/Mrom_data97  (
    .I0(\vga/vgacore/vcnt_2_1_98 ),
    .I1(\vga/vgacore/vcnt_1_1_97 ),
    .I2(\vga/vgacore/vcnt_0_1_96 ),
    .I3(\vga/rom_addr_char_0_1_94 ),
    .O(\vga/N102 )
  );
  defparam \vga/char_rom/Mrom_data99 .INIT = 16'h2422;
  LUT4 \vga/char_rom/Mrom_data99  (
    .I0(\vga/vgacore/vcnt_0_1_96 ),
    .I1(\vga/vgacore/vcnt_1_1_97 ),
    .I2(\vga/vgacore/vcnt_2_1_98 ),
    .I3(\vga/rom_addr_char_0_1_94 ),
    .O(\vga/N104 )
  );
  defparam \vga/char_rom/Mrom_data100 .INIT = 16'h5292;
  LUT4 \vga/char_rom/Mrom_data100  (
    .I0(\vga/vgacore/vcnt [0]),
    .I1(\vga/vgacore/vcnt [1]),
    .I2(\vga/rom_addr_char [0]),
    .I3(\vga/vgacore/vcnt [2]),
    .O(\vga/N105 )
  );
  defparam \vga/char_rom/Mrom_data101 .INIT = 16'h131B;
  LUT4 \vga/char_rom/Mrom_data101  (
    .I0(\vga/vgacore/vcnt [1]),
    .I1(\vga/vgacore/vcnt [0]),
    .I2(\vga/rom_addr_char [0]),
    .I3(\vga/vgacore/vcnt [2]),
    .O(\vga/N106 )
  );
  defparam \vga/char_rom/Mrom_data105 .INIT = 16'h2AEA;
  LUT4 \vga/char_rom/Mrom_data105  (
    .I0(\vga/rom_addr_char [0]),
    .I1(\vga/vgacore/vcnt [0]),
    .I2(\vga/vgacore/vcnt [1]),
    .I3(\vga/vgacore/vcnt [2]),
    .O(\vga/N110 )
  );
  defparam \vga/char_rom/Mrom_data106 .INIT = 16'h0608;
  LUT4 \vga/char_rom/Mrom_data106  (
    .I0(\vga/vgacore/vcnt [2]),
    .I1(\vga/vgacore/vcnt [1]),
    .I2(\vga/vgacore/vcnt [0]),
    .I3(\vga/rom_addr_char [0]),
    .O(\vga/N111 )
  );
  defparam \vga/char_rom/Mrom_data108 .INIT = 16'h4104;
  LUT4 \vga/char_rom/Mrom_data108  (
    .I0(\vga/vgacore/vcnt [0]),
    .I1(\vga/vgacore/vcnt [1]),
    .I2(\vga/vgacore/vcnt [2]),
    .I3(\vga/rom_addr_char [0]),
    .O(\vga/N113 )
  );
  defparam \vga/char_rom/Mrom_data109 .INIT = 16'h4251;
  LUT4 \vga/char_rom/Mrom_data109  (
    .I0(\vga/vgacore/vcnt [0]),
    .I1(\vga/vgacore/vcnt [2]),
    .I2(\vga/rom_addr_char [0]),
    .I3(\vga/vgacore/vcnt [1]),
    .O(\vga/N114 )
  );
  defparam \vga/char_rom/Mrom_data110 .INIT = 16'h15D5;
  LUT4 \vga/char_rom/Mrom_data110  (
    .I0(\vga/rom_addr_char [0]),
    .I1(\vga/vgacore/vcnt [2]),
    .I2(\vga/vgacore/vcnt [1]),
    .I3(\vga/vgacore/vcnt [0]),
    .O(\vga/N115 )
  );
  defparam \vga/char_rom/Mrom_data111 .INIT = 16'h6068;
  LUT4 \vga/char_rom/Mrom_data111  (
    .I0(\vga/vgacore/vcnt [1]),
    .I1(\vga/vgacore/vcnt [2]),
    .I2(\vga/rom_addr_char [0]),
    .I3(\vga/vgacore/vcnt [0]),
    .O(\vga/N116 )
  );
  defparam \vga/char_rom/Mrom_data112 .INIT = 16'h1888;
  LUT4 \vga/char_rom/Mrom_data112  (
    .I0(\vga/rom_addr_char [0]),
    .I1(\vga/vgacore/vcnt [2]),
    .I2(\vga/vgacore/vcnt [1]),
    .I3(\vga/vgacore/vcnt [0]),
    .O(\vga/N117 )
  );
  defparam \vga/char_rom/Mrom_data113 .INIT = 16'h4145;
  LUT4 \vga/char_rom/Mrom_data113  (
    .I0(\vga/vgacore/vcnt [0]),
    .I1(\vga/vgacore/vcnt [1]),
    .I2(\vga/vgacore/vcnt [2]),
    .I3(\vga/rom_addr_char [0]),
    .O(\vga/N118 )
  );
  defparam \vga/char_rom/Mrom_data115 .INIT = 16'h8001;
  LUT4 \vga/char_rom/Mrom_data115  (
    .I0(\vga/vgacore/vcnt [0]),
    .I1(\vga/vgacore/vcnt [1]),
    .I2(\vga/vgacore/vcnt [2]),
    .I3(\vga/rom_addr_char [0]),
    .O(\vga/N120 )
  );
  defparam \vga/char_rom/Mrom_data116 .INIT = 16'h4453;
  LUT4 \vga/char_rom/Mrom_data116  (
    .I0(\vga/vgacore/vcnt [0]),
    .I1(\vga/rom_addr_char [0]),
    .I2(\vga/vgacore/vcnt [1]),
    .I3(\vga/vgacore/vcnt [2]),
    .O(\vga/N121 )
  );
  defparam \vga/char_rom/Mrom_data120 .INIT = 16'h28AE;
  LUT4 \vga/char_rom/Mrom_data120  (
    .I0(\vga/rom_addr_char [0]),
    .I1(\vga/vgacore/vcnt [1]),
    .I2(\vga/vgacore/vcnt [2]),
    .I3(\vga/vgacore/vcnt [0]),
    .O(\vga/N125 )
  );
  defparam \vga/char_rom/Mrom_data121 .INIT = 16'h2884;
  LUT4 \vga/char_rom/Mrom_data121  (
    .I0(\vga/vgacore/vcnt [0]),
    .I1(\vga/vgacore/vcnt [1]),
    .I2(\vga/vgacore/vcnt [2]),
    .I3(\vga/rom_addr_char [0]),
    .O(\vga/N126 )
  );
  defparam \vga/char_rom/Mrom_data122 .INIT = 16'h17D5;
  LUT4 \vga/char_rom/Mrom_data122  (
    .I0(\vga/rom_addr_char [0]),
    .I1(\vga/vgacore/vcnt [1]),
    .I2(\vga/vgacore/vcnt [0]),
    .I3(\vga/vgacore/vcnt [2]),
    .O(\vga/N127 )
  );
  defparam \vga/char_rom/Mrom_data123 .INIT = 16'h4404;
  LUT4 \vga/char_rom/Mrom_data123  (
    .I0(\vga/vgacore/vcnt [0]),
    .I1(\vga/vgacore/vcnt [1]),
    .I2(\vga/vgacore/vcnt [2]),
    .I3(\vga/rom_addr_char [0]),
    .O(\vga/N128 )
  );
  defparam \vga/char_rom/Mrom_data124 .INIT = 16'h2404;
  LUT4 \vga/char_rom/Mrom_data124  (
    .I0(\vga/vgacore/vcnt [0]),
    .I1(\vga/vgacore/vcnt [1]),
    .I2(\vga/rom_addr_char [0]),
    .I3(\vga/vgacore/vcnt [2]),
    .O(\vga/N129 )
  );
  defparam \vga/char_rom/Mrom_data125 .INIT = 16'h4048;
  LUT4 \vga/char_rom/Mrom_data125  (
    .I0(\vga/vgacore/vcnt [1]),
    .I1(\vga/vgacore/vcnt [2]),
    .I2(\vga/rom_addr_char [0]),
    .I3(\vga/vgacore/vcnt [0]),
    .O(\vga/N130 )
  );
  defparam \vga/char_rom/Mrom_data126 .INIT = 16'h6010;
  LUT4 \vga/char_rom/Mrom_data126  (
    .I0(\vga/vgacore/vcnt [0]),
    .I1(\vga/vgacore/vcnt [1]),
    .I2(\vga/vgacore/vcnt [2]),
    .I3(\vga/rom_addr_char [0]),
    .O(\vga/N131 )
  );
  defparam \vga/char_rom/Mrom_data127 .INIT = 16'h4514;
  LUT4 \vga/char_rom/Mrom_data127  (
    .I0(\vga/vgacore/vcnt [0]),
    .I1(\vga/vgacore/vcnt [2]),
    .I2(\vga/rom_addr_char [0]),
    .I3(\vga/vgacore/vcnt [1]),
    .O(\vga/N132 )
  );
  defparam \vga/char_rom/Mrom_data128 .INIT = 16'h4177;
  LUT4 \vga/char_rom/Mrom_data128  (
    .I0(\vga/vgacore/vcnt [0]),
    .I1(\vga/vgacore/vcnt [1]),
    .I2(\vga/vgacore/vcnt [2]),
    .I3(\vga/rom_addr_char [0]),
    .O(\vga/N133 )
  );
  defparam \vga/char_rom/Mrom_data129 .INIT = 16'h0002;
  LUT4 \vga/char_rom/Mrom_data129  (
    .I0(\vga/vgacore/vcnt [0]),
    .I1(\vga/vgacore/vcnt [1]),
    .I2(\vga/vgacore/vcnt [2]),
    .I3(\vga/rom_addr_char [0]),
    .O(\vga/N134 )
  );
  defparam \vga/char_rom/Mrom_data131 .INIT = 16'h4DC9;
  LUT4 \vga/char_rom/Mrom_data131  (
    .I0(\vga/vgacore/vcnt [2]),
    .I1(\vga/rom_addr_char [0]),
    .I2(\vga/vgacore/vcnt [1]),
    .I3(\vga/vgacore/vcnt [0]),
    .O(\vga/N137 )
  );
  defparam \vga/char_rom/Mrom_data132 .INIT = 16'h0666;
  LUT4 \vga/char_rom/Mrom_data132  (
    .I0(\vga/rom_addr_char [0]),
    .I1(\vga/vgacore/vcnt [0]),
    .I2(\vga/vgacore/vcnt [1]),
    .I3(\vga/vgacore/vcnt [2]),
    .O(\vga/N138 )
  );
  defparam \vga/char_rom/Mrom_data133 .INIT = 16'h042F;
  LUT4 \vga/char_rom/Mrom_data133  (
    .I0(\vga/rom_addr_char [0]),
    .I1(\vga/vgacore/vcnt [1]),
    .I2(\vga/vgacore/vcnt [0]),
    .I3(\vga/vgacore/vcnt [2]),
    .O(\vga/N139 )
  );
  defparam \vga/char_rom/Mrom_data136 .INIT = 16'h2C08;
  LUT4 \vga/char_rom/Mrom_data136  (
    .I0(\vga/vgacore/vcnt [1]),
    .I1(\vga/vgacore/vcnt [2]),
    .I2(\vga/rom_addr_char [0]),
    .I3(\vga/vgacore/vcnt [0]),
    .O(\vga/N142 )
  );
  defparam \vga/char_rom/Mrom_data137 .INIT = 16'h1060;
  LUT4 \vga/char_rom/Mrom_data137  (
    .I0(\vga/vgacore/vcnt [0]),
    .I1(\vga/vgacore/vcnt [1]),
    .I2(\vga/vgacore/vcnt [2]),
    .I3(\vga/rom_addr_char [0]),
    .O(\vga/N143 )
  );
  defparam \vga/char_rom/Mrom_data138 .INIT = 16'h4251;
  LUT4 \vga/char_rom/Mrom_data138  (
    .I0(\vga/vgacore/vcnt [0]),
    .I1(\vga/vgacore/vcnt [1]),
    .I2(\vga/vgacore/vcnt [2]),
    .I3(\vga/rom_addr_char [0]),
    .O(\vga/N144 )
  );
  defparam \vga/char_rom/Mrom_data139 .INIT = 16'h4951;
  LUT4 \vga/char_rom/Mrom_data139  (
    .I0(\vga/vgacore/vcnt [0]),
    .I1(\vga/vgacore/vcnt [1]),
    .I2(\vga/vgacore/vcnt [2]),
    .I3(\vga/rom_addr_char [0]),
    .O(\vga/N145 )
  );
  defparam \vga/char_rom/Mrom_data140 .INIT = 16'h4914;
  LUT4 \vga/char_rom/Mrom_data140  (
    .I0(\vga/vgacore/vcnt [0]),
    .I1(\vga/vgacore/vcnt [1]),
    .I2(\vga/vgacore/vcnt [2]),
    .I3(\vga/rom_addr_char [0]),
    .O(\vga/N146 )
  );
  defparam \vga/char_rom/Mrom_data141 .INIT = 16'h741A;
  LUT4 \vga/char_rom/Mrom_data141  (
    .I0(\vga/vgacore/vcnt [0]),
    .I1(\vga/vgacore/vcnt [1]),
    .I2(\vga/rom_addr_char [0]),
    .I3(\vga/vgacore/vcnt [2]),
    .O(\vga/N147 )
  );
  defparam \vga/char_rom/Mrom_data143 .INIT = 16'hE6CC;
  LUT4 \vga/char_rom/Mrom_data143  (
    .I0(\vga/vgacore/vcnt [0]),
    .I1(\vga/vgacore/vcnt [1]),
    .I2(\vga/rom_addr_char [0]),
    .I3(\vga/vgacore/vcnt [2]),
    .O(\vga/N149 )
  );
  defparam \vga/char_rom/Mrom_data144 .INIT = 16'h2414;
  LUT4 \vga/char_rom/Mrom_data144  (
    .I0(\vga/vgacore/vcnt [0]),
    .I1(\vga/vgacore/vcnt [1]),
    .I2(\vga/vgacore/vcnt [2]),
    .I3(\vga/rom_addr_char [0]),
    .O(\vga/N150 )
  );
  defparam \vga/char_rom/Mrom_data145 .INIT = 16'h0141;
  LUT4 \vga/char_rom/Mrom_data145  (
    .I0(\vga/vgacore/vcnt [0]),
    .I1(\vga/vgacore/vcnt [1]),
    .I2(\vga/vgacore/vcnt [2]),
    .I3(\vga/rom_addr_char [0]),
    .O(\vga/N151 )
  );
  defparam \vga/char_rom/Mrom_data146 .INIT = 16'h1411;
  LUT4 \vga/char_rom/Mrom_data146  (
    .I0(\vga/vgacore/vcnt [0]),
    .I1(\vga/vgacore/vcnt [1]),
    .I2(\vga/rom_addr_char [0]),
    .I3(\vga/vgacore/vcnt [2]),
    .O(\vga/N152 )
  );
  defparam \vga/char_rom/Mrom_data149 .INIT = 16'h2403;
  LUT4 \vga/char_rom/Mrom_data149  (
    .I0(\vga/rom_addr_char [0]),
    .I1(\vga/vgacore/vcnt [0]),
    .I2(\vga/vgacore/vcnt [2]),
    .I3(\vga/vgacore/vcnt [1]),
    .O(\vga/N155 )
  );
  defparam \vga/char_rom/Mrom_data151 .INIT = 16'h2400;
  LUT4 \vga/char_rom/Mrom_data151  (
    .I0(\vga/vgacore/vcnt [0]),
    .I1(\vga/vgacore/vcnt [2]),
    .I2(\vga/rom_addr_char [0]),
    .I3(\vga/vgacore/vcnt [1]),
    .O(\vga/N157 )
  );
  defparam \vga/char_rom/Mrom_data153 .INIT = 16'h0814;
  LUT4 \vga/char_rom/Mrom_data153  (
    .I0(\vga/vgacore/vcnt [1]),
    .I1(\vga/rom_addr_char [0]),
    .I2(\vga/vgacore/vcnt [0]),
    .I3(\vga/vgacore/vcnt [2]),
    .O(\vga/N159 )
  );
  defparam \vga/char_rom/Mrom_data161 .INIT = 16'h4443;
  LUT4 \vga/char_rom/Mrom_data161  (
    .I0(\vga/vgacore/vcnt [0]),
    .I1(\vga/rom_addr_char [0]),
    .I2(\vga/vgacore/vcnt [1]),
    .I3(\vga/vgacore/vcnt [2]),
    .O(\vga/N167 )
  );
  defparam \vga/char_rom/Mrom_data164 .INIT = 16'h9B72;
  LUT4 \vga/char_rom/Mrom_data164  (
    .I0(\vga/vgacore/vcnt [0]),
    .I1(\vga/rom_addr_char [0]),
    .I2(\vga/vgacore/vcnt [1]),
    .I3(\vga/vgacore/vcnt [2]),
    .O(\vga/N170 )
  );
  defparam \vga/char_rom/Mrom_data165 .INIT = 16'h0002;
  LUT4 \vga/char_rom/Mrom_data165  (
    .I0(\vga/vgacore/vcnt [1]),
    .I1(\vga/vgacore/vcnt [0]),
    .I2(\vga/vgacore/vcnt [2]),
    .I3(\vga/rom_addr_char [0]),
    .O(\vga/N171 )
  );
  defparam \vga/char_rom/Mrom_data166 .INIT = 16'h2400;
  LUT4 \vga/char_rom/Mrom_data166  (
    .I0(\vga/vgacore/vcnt [1]),
    .I1(\vga/rom_addr_char [0]),
    .I2(\vga/vgacore/vcnt [0]),
    .I3(\vga/vgacore/vcnt [2]),
    .O(\vga/N172 )
  );
  defparam \vga/char_rom/Mrom_data169 .INIT = 16'h326A;
  LUT4 \vga/char_rom/Mrom_data169  (
    .I0(\vga/vgacore/vcnt [2]),
    .I1(\vga/vgacore/vcnt [0]),
    .I2(\vga/vgacore/vcnt [1]),
    .I3(\vga/rom_addr_char [0]),
    .O(\vga/N175 )
  );
  defparam \vga/char_rom/Mrom_data170 .INIT = 16'h0786;
  LUT4 \vga/char_rom/Mrom_data170  (
    .I0(\vga/vgacore/vcnt [1]),
    .I1(\vga/vgacore/vcnt [2]),
    .I2(\vga/rom_addr_char [0]),
    .I3(\vga/vgacore/vcnt [0]),
    .O(\vga/N176 )
  );
  defparam \vga/char_rom/Mrom_data172 .INIT = 16'h8084;
  LUT4 \vga/char_rom/Mrom_data172  (
    .I0(\vga/vgacore/vcnt [0]),
    .I1(\vga/vgacore/vcnt [2]),
    .I2(\vga/rom_addr_char [0]),
    .I3(\vga/vgacore/vcnt [1]),
    .O(\vga/N178 )
  );
  defparam \vga/char_rom/Mrom_data173 .INIT = 16'h35E4;
  LUT4 \vga/char_rom/Mrom_data173  (
    .I0(\vga/vgacore/vcnt [0]),
    .I1(\vga/vgacore/vcnt [2]),
    .I2(\vga/rom_addr_char [0]),
    .I3(\vga/vgacore/vcnt [1]),
    .O(\vga/N179 )
  );
  defparam \vga/char_rom/Mrom_data176 .INIT = 16'h2407;
  LUT4 \vga/char_rom/Mrom_data176  (
    .I0(\vga/vgacore/vcnt [0]),
    .I1(\vga/vgacore/vcnt [1]),
    .I2(\vga/vgacore/vcnt [2]),
    .I3(\vga/rom_addr_char [0]),
    .O(\vga/N183 )
  );
  defparam \vga/char_rom/Mrom_data177 .INIT = 16'h129A;
  LUT4 \vga/char_rom/Mrom_data177  (
    .I0(\vga/vgacore/vcnt [0]),
    .I1(\vga/vgacore/vcnt [2]),
    .I2(\vga/rom_addr_char [0]),
    .I3(\vga/vgacore/vcnt [1]),
    .O(\vga/N184 )
  );
  defparam \vga/char_rom/Mrom_data179 .INIT = 16'h082A;
  LUT4 \vga/char_rom/Mrom_data179  (
    .I0(\vga/vgacore/vcnt [0]),
    .I1(\vga/vgacore/vcnt [1]),
    .I2(\vga/vgacore/vcnt [2]),
    .I3(\vga/rom_addr_char [0]),
    .O(\vga/N186 )
  );
  defparam \vga/char_rom/Mrom_data183 .INIT = 16'h2262;
  LUT4 \vga/char_rom/Mrom_data183  (
    .I0(\vga/vgacore/vcnt [0]),
    .I1(\vga/vgacore/vcnt [1]),
    .I2(\vga/vgacore/vcnt [2]),
    .I3(\vga/rom_addr_char [0]),
    .O(\vga/N190 )
  );
  defparam \vga/char_rom/Mrom_data184 .INIT = 16'h54C6;
  LUT4 \vga/char_rom/Mrom_data184  (
    .I0(\vga/vgacore/vcnt [2]),
    .I1(\vga/rom_addr_char [0]),
    .I2(\vga/vgacore/vcnt [0]),
    .I3(\vga/vgacore/vcnt [1]),
    .O(\vga/N191 )
  );
  defparam \vga/char_rom/Mrom_data185 .INIT = 16'h0616;
  LUT4 \vga/char_rom/Mrom_data185  (
    .I0(\vga/vgacore/vcnt [1]),
    .I1(\vga/vgacore/vcnt [2]),
    .I2(\vga/rom_addr_char [0]),
    .I3(\vga/vgacore/vcnt [0]),
    .O(\vga/N192 )
  );
  defparam \vga/char_rom/Mrom_data186 .INIT = 16'h1526;
  LUT4 \vga/char_rom/Mrom_data186  (
    .I0(\vga/vgacore/vcnt [1]),
    .I1(\vga/vgacore/vcnt [2]),
    .I2(\vga/rom_addr_char [0]),
    .I3(\vga/vgacore/vcnt [0]),
    .O(\vga/N193 )
  );
  defparam \vga/char_rom/Mrom_data187 .INIT = 16'h0860;
  LUT4 \vga/char_rom/Mrom_data187  (
    .I0(\vga/rom_addr_char [0]),
    .I1(\vga/vgacore/vcnt [0]),
    .I2(\vga/vgacore/vcnt [1]),
    .I3(\vga/vgacore/vcnt [2]),
    .O(\vga/N194 )
  );
  defparam \vga/char_rom/Mrom_data194 .INIT = 16'h1B7B;
  LUT4 \vga/char_rom/Mrom_data194  (
    .I0(\vga/vgacore/vcnt [0]),
    .I1(\vga/rom_addr_char [0]),
    .I2(\vga/vgacore/vcnt [1]),
    .I3(\vga/vgacore/vcnt [2]),
    .O(\vga/N201 )
  );
  defparam \vga/char_rom/Mrom_data198 .INIT = 16'h0223;
  LUT4 \vga/char_rom/Mrom_data198  (
    .I0(\vga/vgacore/vcnt [2]),
    .I1(\vga/rom_addr_char [0]),
    .I2(\vga/vgacore/vcnt [1]),
    .I3(\vga/vgacore/vcnt [0]),
    .O(\vga/N205 )
  );
  defparam \vga/char_rom/Mrom_data201 .INIT = 16'h1FB3;
  LUT4 \vga/char_rom/Mrom_data201  (
    .I0(\vga/vgacore/vcnt [0]),
    .I1(\vga/rom_addr_char [0]),
    .I2(\vga/vgacore/vcnt [1]),
    .I3(\vga/vgacore/vcnt [2]),
    .O(\vga/N208 )
  );
  defparam \vga/char_rom/Mrom_data206 .INIT = 16'h47AA;
  LUT4 \vga/char_rom/Mrom_data206  (
    .I0(\vga/vgacore/vcnt [2]),
    .I1(\vga/vgacore/vcnt [0]),
    .I2(\vga/rom_addr_char [0]),
    .I3(\vga/vgacore/vcnt [1]),
    .O(\vga/N213 )
  );
  defparam \vga/char_rom/Mrom_data207 .INIT = 16'h64EE;
  LUT4 \vga/char_rom/Mrom_data207  (
    .I0(\vga/vgacore/vcnt [1]),
    .I1(\vga/vgacore/vcnt [2]),
    .I2(\vga/vgacore/vcnt [0]),
    .I3(\vga/rom_addr_char [0]),
    .O(\vga/N214 )
  );
  defparam \vga/char_rom/Mrom_data208 .INIT = 16'h0484;
  LUT4 \vga/char_rom/Mrom_data208  (
    .I0(\vga/rom_addr_char [0]),
    .I1(\vga/vgacore/vcnt [1]),
    .I2(\vga/vgacore/vcnt [0]),
    .I3(\vga/vgacore/vcnt [2]),
    .O(\vga/N215 )
  );
  defparam \vga/char_rom/Mrom_data209 .INIT = 16'h6064;
  LUT4 \vga/char_rom/Mrom_data209  (
    .I0(\vga/vgacore/vcnt [2]),
    .I1(\vga/vgacore/vcnt [1]),
    .I2(\vga/rom_addr_char [0]),
    .I3(\vga/vgacore/vcnt [0]),
    .O(\vga/N216 )
  );
  defparam \vga/char_rom/Mrom_data211 .INIT = 16'h96CC;
  LUT4 \vga/char_rom/Mrom_data211  (
    .I0(\vga/rom_addr_char [0]),
    .I1(\vga/vgacore/vcnt [1]),
    .I2(\vga/vgacore/vcnt [0]),
    .I3(\vga/vgacore/vcnt [2]),
    .O(\vga/N218 )
  );
  defparam \vga/char_rom/Mrom_data212 .INIT = 16'h0864;
  LUT4 \vga/char_rom/Mrom_data212  (
    .I0(\vga/vgacore/vcnt [0]),
    .I1(\vga/vgacore/vcnt [1]),
    .I2(\vga/vgacore/vcnt [2]),
    .I3(\vga/rom_addr_char [0]),
    .O(\vga/N219 )
  );
  defparam \vga/char_rom/Mrom_data213 .INIT = 16'h4224;
  LUT4 \vga/char_rom/Mrom_data213  (
    .I0(\vga/vgacore/vcnt [0]),
    .I1(\vga/vgacore/vcnt [1]),
    .I2(\vga/vgacore/vcnt [2]),
    .I3(\vga/rom_addr_char [0]),
    .O(\vga/N221 )
  );
  defparam \vga/char_rom/Mrom_data214 .INIT = 16'h0002;
  LUT4 \vga/char_rom/Mrom_data214  (
    .I0(\vga/vgacore/vcnt [2]),
    .I1(\vga/vgacore/vcnt [0]),
    .I2(\vga/vgacore/vcnt [1]),
    .I3(\vga/rom_addr_char [0]),
    .O(\vga/N222 )
  );
  defparam \vga/char_rom/Mrom_data216 .INIT = 16'h8000;
  LUT4 \vga/char_rom/Mrom_data216  (
    .I0(\vga/vgacore/vcnt [0]),
    .I1(\vga/vgacore/vcnt [1]),
    .I2(\vga/vgacore/vcnt [2]),
    .I3(\vga/rom_addr_char [0]),
    .O(\vga/N224 )
  );
  RAMB4_S1_S1 \vga/inst_Mram_mem8  (
    .CLKA(\vga/ram_wclk_11 ),
    .CLKB(\vga/charclk ),
    .ENA(N3),
    .ENB(N3),
    .RSTA(N2),
    .RSTB(N2),
    .WEA(\vga/N226 ),
    .WEB(N2),
    .ADDRA({\vga/video_ram/ram_addr_w [11], \vga/video_ram/ram_addr_w [10], \vga/video_ram/ram_addr_w [9], \vga/video_ram/ram_addr_w [8], 
\vga/video_ram/ram_addr_w [7], \vga/video_ram/ram_addr_w [6], \vga/video_ram/ram_addr_w [5], \vga/video_ram/ram_addr_w [4], 
\vga/video_ram/ram_addr_w [3], \vga/video_ram/ram_addr_w [2], \vga/video_ram/ram_addr_w [1], \vga/video_ram/ram_addr_w [0]}),
    .ADDRB({\vga/ram_addr_mux [11], \vga/ram_addr_mux [10], \vga/ram_addr_mux [9], \vga/ram_addr_mux [8], \vga/ram_addr_mux [7], \vga/ram_addr_mux [6]
, \vga/ram_addr_mux [5], \vga/ram_addr_mux [4], \vga/ram_addr_mux [3], \vga/ram_addr_mux [2], \vga/ram_addr_mux [1], \vga/ram_addr_mux [0]}),
    .DIA({\vga/crt/ram_data [0]}),
    .DIB({\NLW_vga/inst_Mram_mem8_DIB<0>_UNCONNECTED }),
    .DOA({\NLW_vga/inst_Mram_mem8_DOA<0>_UNCONNECTED }),
    .DOB({\vga/ram_data_out [0]})
  );
  RAMB4_S1_S1 \vga/inst_Mram_mem11  (
    .CLKA(\vga/ram_wclk_11 ),
    .CLKB(\vga/charclk ),
    .ENA(N3),
    .ENB(N3),
    .RSTA(N2),
    .RSTB(N2),
    .WEA(\vga/N226 ),
    .WEB(N2),
    .ADDRA({\vga/video_ram/ram_addr_w [11], \vga/video_ram/ram_addr_w [10], \vga/video_ram/ram_addr_w [9], \vga/video_ram/ram_addr_w [8], 
\vga/video_ram/ram_addr_w [7], \vga/video_ram/ram_addr_w [6], \vga/video_ram/ram_addr_w [5], \vga/video_ram/ram_addr_w [4], 
\vga/video_ram/ram_addr_w [3], \vga/video_ram/ram_addr_w [2], \vga/video_ram/ram_addr_w [1], \vga/video_ram/ram_addr_w [0]}),
    .ADDRB({\vga/ram_addr_mux [11], \vga/ram_addr_mux [10], \vga/ram_addr_mux [9], \vga/ram_addr_mux [8], \vga/ram_addr_mux [7], \vga/ram_addr_mux [6]
, \vga/ram_addr_mux [5], \vga/ram_addr_mux [4], \vga/ram_addr_mux [3], \vga/ram_addr_mux [2], \vga/ram_addr_mux [1], \vga/ram_addr_mux [0]}),
    .DIA({\vga/crt/ram_data [1]}),
    .DIB({\NLW_vga/inst_Mram_mem11_DIB<0>_UNCONNECTED }),
    .DOA({\NLW_vga/inst_Mram_mem11_DOA<0>_UNCONNECTED }),
    .DOB({\vga/ram_data_out [1]})
  );
  RAMB4_S1_S1 \vga/inst_Mram_mem21  (
    .CLKA(\vga/ram_wclk_11 ),
    .CLKB(\vga/charclk ),
    .ENA(N3),
    .ENB(N3),
    .RSTA(N2),
    .RSTB(N2),
    .WEA(\vga/N226 ),
    .WEB(N2),
    .ADDRA({\vga/video_ram/ram_addr_w [11], \vga/video_ram/ram_addr_w [10], \vga/video_ram/ram_addr_w [9], \vga/video_ram/ram_addr_w [8], 
\vga/video_ram/ram_addr_w [7], \vga/video_ram/ram_addr_w [6], \vga/video_ram/ram_addr_w [5], \vga/video_ram/ram_addr_w [4], 
\vga/video_ram/ram_addr_w [3], \vga/video_ram/ram_addr_w [2], \vga/video_ram/ram_addr_w [1], \vga/video_ram/ram_addr_w [0]}),
    .ADDRB({\vga/ram_addr_mux [11], \vga/ram_addr_mux [10], \vga/ram_addr_mux [9], \vga/ram_addr_mux [8], \vga/ram_addr_mux [7], \vga/ram_addr_mux [6]
, \vga/ram_addr_mux [5], \vga/ram_addr_mux [4], \vga/ram_addr_mux [3], \vga/ram_addr_mux [2], \vga/ram_addr_mux [1], \vga/ram_addr_mux [0]}),
    .DIA({\vga/crt/ram_data [2]}),
    .DIB({\NLW_vga/inst_Mram_mem21_DIB<0>_UNCONNECTED }),
    .DOA({\NLW_vga/inst_Mram_mem21_DOA<0>_UNCONNECTED }),
    .DOB({\vga/ram_data_out [2]})
  );
  RAMB4_S1_S1 \vga/inst_Mram_mem31  (
    .CLKA(\vga/ram_wclk_11 ),
    .CLKB(\vga/charclk ),
    .ENA(N3),
    .ENB(N3),
    .RSTA(N2),
    .RSTB(N2),
    .WEA(\vga/N226 ),
    .WEB(N2),
    .ADDRA({\vga/video_ram/ram_addr_w [11], \vga/video_ram/ram_addr_w [10], \vga/video_ram/ram_addr_w [9], \vga/video_ram/ram_addr_w [8], 
\vga/video_ram/ram_addr_w [7], \vga/video_ram/ram_addr_w [6], \vga/video_ram/ram_addr_w [5], \vga/video_ram/ram_addr_w [4], 
\vga/video_ram/ram_addr_w [3], \vga/video_ram/ram_addr_w [2], \vga/video_ram/ram_addr_w [1], \vga/video_ram/ram_addr_w [0]}),
    .ADDRB({\vga/ram_addr_mux [11], \vga/ram_addr_mux [10], \vga/ram_addr_mux [9], \vga/ram_addr_mux [8], \vga/ram_addr_mux [7], \vga/ram_addr_mux [6]
, \vga/ram_addr_mux [5], \vga/ram_addr_mux [4], \vga/ram_addr_mux [3], \vga/ram_addr_mux [2], \vga/ram_addr_mux [1], \vga/ram_addr_mux [0]}),
    .DIA({\vga/crt/ram_data [3]}),
    .DIB({\NLW_vga/inst_Mram_mem31_DIB<0>_UNCONNECTED }),
    .DOA({\NLW_vga/inst_Mram_mem31_DOA<0>_UNCONNECTED }),
    .DOB({\vga/ram_data_out [3]})
  );
  RAMB4_S1_S1 \vga/inst_Mram_mem41  (
    .CLKA(\vga/ram_wclk_11 ),
    .CLKB(\vga/charclk ),
    .ENA(N3),
    .ENB(N3),
    .RSTA(N2),
    .RSTB(N2),
    .WEA(\vga/N226 ),
    .WEB(N2),
    .ADDRA({\vga/video_ram/ram_addr_w [11], \vga/video_ram/ram_addr_w [10], \vga/video_ram/ram_addr_w [9], \vga/video_ram/ram_addr_w [8], 
\vga/video_ram/ram_addr_w [7], \vga/video_ram/ram_addr_w [6], \vga/video_ram/ram_addr_w [5], \vga/video_ram/ram_addr_w [4], 
\vga/video_ram/ram_addr_w [3], \vga/video_ram/ram_addr_w [2], \vga/video_ram/ram_addr_w [1], \vga/video_ram/ram_addr_w [0]}),
    .ADDRB({\vga/ram_addr_mux [11], \vga/ram_addr_mux [10], \vga/ram_addr_mux [9], \vga/ram_addr_mux [8], \vga/ram_addr_mux [7], \vga/ram_addr_mux [6]
, \vga/ram_addr_mux [5], \vga/ram_addr_mux [4], \vga/ram_addr_mux [3], \vga/ram_addr_mux [2], \vga/ram_addr_mux [1], \vga/ram_addr_mux [0]}),
    .DIA({\vga/crt/ram_data [4]}),
    .DIB({\NLW_vga/inst_Mram_mem41_DIB<0>_UNCONNECTED }),
    .DOA({\NLW_vga/inst_Mram_mem41_DOA<0>_UNCONNECTED }),
    .DOB({\vga/ram_data_out [4]})
  );
  RAMB4_S1_S1 \vga/inst_Mram_mem51  (
    .CLKA(\vga/ram_wclk_11 ),
    .CLKB(\vga/charclk ),
    .ENA(N3),
    .ENB(N3),
    .RSTA(N2),
    .RSTB(N2),
    .WEA(\vga/N226 ),
    .WEB(N2),
    .ADDRA({\vga/video_ram/ram_addr_w [11], \vga/video_ram/ram_addr_w [10], \vga/video_ram/ram_addr_w [9], \vga/video_ram/ram_addr_w [8], 
\vga/video_ram/ram_addr_w [7], \vga/video_ram/ram_addr_w [6], \vga/video_ram/ram_addr_w [5], \vga/video_ram/ram_addr_w [4], 
\vga/video_ram/ram_addr_w [3], \vga/video_ram/ram_addr_w [2], \vga/video_ram/ram_addr_w [1], \vga/video_ram/ram_addr_w [0]}),
    .ADDRB({\vga/ram_addr_mux [11], \vga/ram_addr_mux [10], \vga/ram_addr_mux [9], \vga/ram_addr_mux [8], \vga/ram_addr_mux [7], \vga/ram_addr_mux [6]
, \vga/ram_addr_mux [5], \vga/ram_addr_mux [4], \vga/ram_addr_mux [3], \vga/ram_addr_mux [2], \vga/ram_addr_mux [1], \vga/ram_addr_mux [0]}),
    .DIA({\vga/crt/ram_data [5]}),
    .DIB({\NLW_vga/inst_Mram_mem51_DIB<0>_UNCONNECTED }),
    .DOA({\NLW_vga/inst_Mram_mem51_DOA<0>_UNCONNECTED }),
    .DOB({\vga/ram_data_out [5]})
  );
  RAMB4_S1_S1 \vga/inst_Mram_mem61  (
    .CLKA(\vga/ram_wclk_11 ),
    .CLKB(\vga/charclk ),
    .ENA(N3),
    .ENB(N3),
    .RSTA(N2),
    .RSTB(N2),
    .WEA(\vga/N226 ),
    .WEB(N2),
    .ADDRA({\vga/video_ram/ram_addr_w [11], \vga/video_ram/ram_addr_w [10], \vga/video_ram/ram_addr_w [9], \vga/video_ram/ram_addr_w [8], 
\vga/video_ram/ram_addr_w [7], \vga/video_ram/ram_addr_w [6], \vga/video_ram/ram_addr_w [5], \vga/video_ram/ram_addr_w [4], 
\vga/video_ram/ram_addr_w [3], \vga/video_ram/ram_addr_w [2], \vga/video_ram/ram_addr_w [1], \vga/video_ram/ram_addr_w [0]}),
    .ADDRB({\vga/ram_addr_mux [11], \vga/ram_addr_mux [10], \vga/ram_addr_mux [9], \vga/ram_addr_mux [8], \vga/ram_addr_mux [7], \vga/ram_addr_mux [6]
, \vga/ram_addr_mux [5], \vga/ram_addr_mux [4], \vga/ram_addr_mux [3], \vga/ram_addr_mux [2], \vga/ram_addr_mux [1], \vga/ram_addr_mux [0]}),
    .DIA({\vga/crt/ram_data [6]}),
    .DIB({\NLW_vga/inst_Mram_mem61_DIB<0>_UNCONNECTED }),
    .DOA({\NLW_vga/inst_Mram_mem61_DOA<0>_UNCONNECTED }),
    .DOB({\vga/ram_data_out [6]})
  );
  defparam \vga/rom_addr_char<1> .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<1>  (
    .I0(\vga/rom_addr_char [1]),
    .I1(\vga/N14 ),
    .I2(\vga/N15 ),
    .O(\vga/N01 )
  );
  defparam \vga/rom_addr_char<1>1 .INIT = 4'h8;
  LUT2 \vga/rom_addr_char<1>1  (
    .I0(\vga/N13 ),
    .I1(\vga/rom_addr_char [1]),
    .O(\vga/N1101 )
  );
  MUXF5 \vga/rom_addr_char<2>_f5  (
    .I0(\vga/N1101 ),
    .I1(\vga/N01 ),
    .S(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f5_17 )
  );
  defparam \vga/rom_addr_char<1>2 .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<1>2  (
    .I0(\vga/rom_addr_char [1]),
    .I1(\vga/N11 ),
    .I2(\vga/N12 ),
    .O(\vga/N2123 )
  );
  defparam \vga/rom_addr_char<1>3 .INIT = 4'h8;
  LUT2 \vga/rom_addr_char<1>3  (
    .I0(\vga/N10 ),
    .I1(\vga/rom_addr_char_1_1_95 ),
    .O(\vga/N312 )
  );
  MUXF5 \vga/rom_addr_char<2>_f5_0  (
    .I0(\vga/N312 ),
    .I1(\vga/N2123 ),
    .S(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f51_18 )
  );
  MUXF6 \vga/rom_addr_char<3>_f6  (
    .I0(\vga/rom_addr_char<2>_f51_18 ),
    .I1(\vga/rom_addr_char<2>_f5_17 ),
    .S(\vga/rom_addr_char [3]),
    .O(\vga/rom_addr_char<3>_f6_19 )
  );
  defparam \vga/rom_addr_char<1>4 .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<1>4  (
    .I0(\vga/rom_addr_char_1_1_95 ),
    .I1(\vga/N21 ),
    .I2(\vga/N22 ),
    .O(\vga/N412 )
  );
  defparam \vga/rom_addr_char<1>5 .INIT = 4'h4;
  LUT2 \vga/rom_addr_char<1>5  (
    .I0(\vga/rom_addr_char_1_1_95 ),
    .I1(\vga/N20 ),
    .O(\vga/N512 )
  );
  MUXF5 \vga/rom_addr_char<2>_f5_1  (
    .I0(\vga/N512 ),
    .I1(\vga/N412 ),
    .S(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f52_20 )
  );
  defparam \vga/rom_addr_char<1>7 .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<1>7  (
    .I0(\vga/rom_addr_char_1_1_95 ),
    .I1(\vga/N16 ),
    .I2(\vga/N17 ),
    .O(\vga/N712 )
  );
  MUXF5 \vga/rom_addr_char<2>_f5_2  (
    .I0(\vga/N712 ),
    .I1(\vga/N612 ),
    .S(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f53_21 )
  );
  MUXF6 \vga/rom_addr_char<3>_f6_0  (
    .I0(\vga/rom_addr_char<2>_f53_21 ),
    .I1(\vga/rom_addr_char<2>_f52_20 ),
    .S(\vga/rom_addr_char [3]),
    .O(\vga/rom_addr_char<3>_f61_22 )
  );
  defparam \vga/rom_addr_char<1>8 .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<1>8  (
    .I0(\vga/rom_addr_char_1_1_95 ),
    .I1(\vga/N29 ),
    .I2(\vga/N30 ),
    .O(\vga/N912 )
  );
  defparam \vga/rom_addr_char<1>9 .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<1>9  (
    .I0(\vga/rom_addr_char_1_1_95 ),
    .I1(\vga/N27 ),
    .I2(\vga/N28 ),
    .O(\vga/N1011 )
  );
  MUXF5 \vga/rom_addr_char<2>_f5_3  (
    .I0(\vga/N1011 ),
    .I1(\vga/N912 ),
    .S(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f54_23 )
  );
  defparam \vga/rom_addr_char<1>10 .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<1>10  (
    .I0(\vga/rom_addr_char [1]),
    .I1(\vga/N25 ),
    .I2(\vga/N26 ),
    .O(\vga/N1111 )
  );
  defparam \vga/rom_addr_char<1>11 .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<1>11  (
    .I0(\vga/rom_addr_char [1]),
    .I1(\vga/N23 ),
    .I2(\vga/N24 ),
    .O(\vga/N1211 )
  );
  MUXF5 \vga/rom_addr_char<2>_f5_4  (
    .I0(\vga/N1211 ),
    .I1(\vga/N1111 ),
    .S(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f55 )
  );
  MUXF6 \vga/rom_addr_char<3>_f6_1  (
    .I0(\vga/rom_addr_char<2>_f55 ),
    .I1(\vga/rom_addr_char<2>_f54_23 ),
    .S(\vga/rom_addr_char [3]),
    .O(\vga/rom_addr_char<3>_f62_24 )
  );
  defparam \vga/rom_addr_char<1>12 .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<1>12  (
    .I0(\vga/rom_addr_char [1]),
    .I1(\vga/N7 ),
    .I2(\vga/N37 ),
    .O(\vga/N1311 )
  );
  defparam \vga/rom_addr_char<1>13 .INIT = 4'h4;
  LUT2 \vga/rom_addr_char<1>13  (
    .I0(\vga/rom_addr_char [1]),
    .I1(\vga/N35 ),
    .O(\vga/N1411 )
  );
  MUXF5 \vga/rom_addr_char<2>_f5_5  (
    .I0(\vga/N1411 ),
    .I1(\vga/N1311 ),
    .S(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f56 )
  );
  defparam \vga/rom_addr_char<1>14 .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<1>14  (
    .I0(\vga/rom_addr_char [1]),
    .I1(\vga/N33 ),
    .I2(\vga/N34 ),
    .O(\vga/N1511 )
  );
  defparam \vga/rom_addr_char<1>15 .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<1>15  (
    .I0(\vga/rom_addr_char [1]),
    .I1(\vga/N31 ),
    .I2(\vga/N32 ),
    .O(\vga/N1611 )
  );
  MUXF5 \vga/rom_addr_char<2>_f5_6  (
    .I0(\vga/N1611 ),
    .I1(N3078),
    .S(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f57 )
  );
  MUXF6 \vga/rom_addr_char<3>_f6_2  (
    .I0(\vga/rom_addr_char<2>_f57 ),
    .I1(\vga/rom_addr_char<2>_f56 ),
    .S(\vga/rom_addr_char [3]),
    .O(\vga/rom_addr_char<3>_f63_25 )
  );
  defparam \vga/rom_addr_char<1>16 .INIT = 4'h8;
  LUT2 \vga/rom_addr_char<1>16  (
    .I0(\vga/N45 ),
    .I1(\vga/rom_addr_char [1]),
    .O(\vga/N1711 )
  );
  defparam \vga/rom_addr_char<1>17 .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<1>17  (
    .I0(\vga/rom_addr_char [1]),
    .I1(\vga/N43 ),
    .I2(\vga/N44 ),
    .O(\vga/N1811 )
  );
  MUXF5 \vga/rom_addr_char<2>_f5_7  (
    .I0(\vga/N1811 ),
    .I1(\vga/N1711 ),
    .S(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f58 )
  );
  defparam \vga/rom_addr_char<3> .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<3>  (
    .I0(\vga/rom_addr_char [3]),
    .I1(\vga/rom_addr_char<2>_f58 ),
    .I2(\vga/rom_addr_char<2>11_27 ),
    .O(\vga/N1911 )
  );
  defparam \vga/rom_addr_char<1>18 .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<1>18  (
    .I0(\vga/rom_addr_char [1]),
    .I1(\vga/N40 ),
    .I2(\vga/N41 ),
    .O(\vga/N2011 )
  );
  defparam \vga/rom_addr_char<1>19 .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<1>19  (
    .I0(\vga/rom_addr_char [1]),
    .I1(\vga/N38 ),
    .I2(\vga/N39 ),
    .O(\vga/N2111 )
  );
  MUXF5 \vga/rom_addr_char<2>_f5_8  (
    .I0(\vga/N2111 ),
    .I1(\vga/N2011 ),
    .S(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f59 )
  );
  defparam \vga/rom_addr_char<3>1 .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<3>1  (
    .I0(\vga/rom_addr_char [3]),
    .I1(\vga/rom_addr_char<2>_f59 ),
    .I2(\vga/rom_addr_char<2>2 ),
    .O(\vga/N2211 )
  );
  MUXF5 \vga/rom_addr_char<4>_f5  (
    .I0(\vga/N2211 ),
    .I1(\vga/N1911 ),
    .S(\vga/rom_addr_char [4]),
    .O(\vga/rom_addr_char<4>_f5_28 )
  );
  defparam \vga/rom_addr_char<2>11 .INIT = 8'h08;
  LUT3 \vga/rom_addr_char<2>11  (
    .I0(\vga/N4 ),
    .I1(\vga/rom_addr_char_1_1_95 ),
    .I2(\vga/rom_addr_char [2]),
    .O(\vga/N1112 )
  );
  defparam \vga/rom_addr_char<2>3 .INIT = 16'hE040;
  LUT4 \vga/rom_addr_char<2>3  (
    .I0(\vga/rom_addr_char_1_1_95 ),
    .I1(\vga/N6 ),
    .I2(\vga/rom_addr_char [2]),
    .I3(\vga/N7 ),
    .O(\vga/N0112 )
  );
  defparam \vga/rom_addr_char<2>12 .INIT = 8'h08;
  LUT3 \vga/rom_addr_char<2>12  (
    .I0(\vga/N8 ),
    .I1(\vga/rom_addr_char_1_1_95 ),
    .I2(\vga/rom_addr_char [2]),
    .O(\vga/N11123 )
  );
  defparam \vga/rom_addr_char<1>20 .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<1>20  (
    .I0(\vga/rom_addr_char [1]),
    .I1(\vga/N142 ),
    .I2(\vga/N143 ),
    .O(\vga/N01123 )
  );
  defparam \vga/rom_addr_char<1>110 .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<1>110  (
    .I0(\vga/rom_addr_char [1]),
    .I1(\vga/N25 ),
    .I2(\vga/N13 ),
    .O(\vga/N111234 )
  );
  MUXF5 \vga/rom_addr_char<2>_f51  (
    .I0(\vga/N111234 ),
    .I1(\vga/N01123 ),
    .S(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f512 )
  );
  defparam \vga/rom_addr_char<1>21 .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<1>21  (
    .I0(\vga/rom_addr_char_1_1_95 ),
    .I1(\vga/N138 ),
    .I2(\vga/N139 ),
    .O(\vga/N21234 )
  );
  defparam \vga/rom_addr_char<1>31 .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<1>31  (
    .I0(\vga/rom_addr_char_1_1_95 ),
    .I1(\vga/N47 ),
    .I2(\vga/N137 ),
    .O(\vga/N3123 )
  );
  MUXF5 \vga/rom_addr_char<2>_f5_01  (
    .I0(\vga/N3123 ),
    .I1(\vga/N21234 ),
    .S(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f511 )
  );
  MUXF6 \vga/rom_addr_char<3>_f61  (
    .I0(\vga/rom_addr_char<2>_f511 ),
    .I1(\vga/rom_addr_char<2>_f512 ),
    .S(\vga/rom_addr_char [3]),
    .O(\vga/rom_addr_char<3>_f612 )
  );
  defparam \vga/rom_addr_char<1>41 .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<1>41  (
    .I0(\vga/rom_addr_char_1_1_95 ),
    .I1(\vga/N150 ),
    .I2(\vga/N151 ),
    .O(\vga/N4123 )
  );
  defparam \vga/rom_addr_char<1>51 .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<1>51  (
    .I0(\vga/rom_addr_char_1_1_95 ),
    .I1(\vga/N55 ),
    .I2(\vga/N149 ),
    .O(\vga/N5 )
  );
  MUXF5 \vga/rom_addr_char<2>_f5_11  (
    .I0(\vga/N5 ),
    .I1(\vga/N4123 ),
    .S(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f521 )
  );
  defparam \vga/rom_addr_char<1>61 .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<1>61  (
    .I0(\vga/rom_addr_char_1_1_95 ),
    .I1(\vga/N146 ),
    .I2(\vga/N147 ),
    .O(\vga/N6123 )
  );
  defparam \vga/rom_addr_char<1>71 .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<1>71  (
    .I0(\vga/rom_addr_char_1_1_95 ),
    .I1(\vga/N144 ),
    .I2(\vga/N145 ),
    .O(\vga/N7123 )
  );
  MUXF5 \vga/rom_addr_char<2>_f5_21  (
    .I0(\vga/N7123 ),
    .I1(\vga/N6123 ),
    .S(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f531 )
  );
  MUXF6 \vga/rom_addr_char<3>_f6_01  (
    .I0(\vga/rom_addr_char<2>_f531 ),
    .I1(\vga/rom_addr_char<2>_f521 ),
    .S(\vga/rom_addr_char [3]),
    .O(\vga/rom_addr_char<3>_f611 )
  );
  defparam \vga/rom_addr_char<1>81 .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<1>81  (
    .I0(\vga/rom_addr_char_1_1_95 ),
    .I1(\vga/N53 ),
    .I2(\vga/N128 ),
    .O(\vga/N8123 )
  );
  defparam \vga/rom_addr_char<1>91 .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<1>91  (
    .I0(\vga/rom_addr_char_1_1_95 ),
    .I1(\vga/N171 ),
    .I2(\vga/N172 ),
    .O(\vga/N9 )
  );
  MUXF5 \vga/rom_addr_char<2>_f5_31  (
    .I0(\vga/N9 ),
    .I1(\vga/N8123 ),
    .S(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f541 )
  );
  defparam \vga/rom_addr_char<1>101 .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<1>101  (
    .I0(\vga/rom_addr_char [1]),
    .I1(\vga/N78 ),
    .I2(\vga/N170 ),
    .O(\vga/N1012 )
  );
  MUXF5 \vga/rom_addr_char<2>_f5_41  (
    .I0(\vga/N11112 ),
    .I1(\vga/N1012 ),
    .S(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f551 )
  );
  MUXF6 \vga/rom_addr_char<3>_f6_11  (
    .I0(\vga/rom_addr_char<2>_f551 ),
    .I1(\vga/rom_addr_char<2>_f541 ),
    .S(\vga/rom_addr_char [3]),
    .O(\vga/rom_addr_char<3>_f621 )
  );
  defparam \vga/rom_addr_char<1>131 .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<1>131  (
    .I0(\vga/rom_addr_char [1]),
    .I1(\vga/N178 ),
    .I2(\vga/N179 ),
    .O(\vga/N1312 )
  );
  MUXF5 \vga/rom_addr_char<2>_f5_51  (
    .I0(\vga/N1312 ),
    .I1(\vga/N1212 ),
    .S(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f561 )
  );
  defparam \vga/rom_addr_char<1>141 .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<1>141  (
    .I0(\vga/rom_addr_char [1]),
    .I1(\vga/N176 ),
    .I2(\vga/N86 ),
    .O(\vga/N1412 )
  );
  MUXF5 \vga/rom_addr_char<2>_f5_61  (
    .I0(\vga/N1512 ),
    .I1(\vga/N1412 ),
    .S(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f571 )
  );
  MUXF6 \vga/rom_addr_char<3>_f6_21  (
    .I0(\vga/rom_addr_char<2>_f571 ),
    .I1(\vga/rom_addr_char<2>_f561 ),
    .S(\vga/rom_addr_char [3]),
    .O(\vga/rom_addr_char<3>_f631 )
  );
  defparam \vga/rom_addr_char<4>3 .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<4>3  (
    .I0(\vga/rom_addr_char [4]),
    .I1(\vga/rom_addr_char<3>_f621 ),
    .I2(\vga/rom_addr_char<3>_f631 ),
    .O(\vga/N1612 )
  );
  defparam \vga/rom_addr_char<1>161 .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<1>161  (
    .I0(\vga/rom_addr_char [1]),
    .I1(\vga/N67 ),
    .I2(\vga/N159 ),
    .O(\vga/N1712 )
  );
  defparam \vga/rom_addr_char<1>171 .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<1>171  (
    .I0(\vga/rom_addr_char [1]),
    .I1(\vga/N65 ),
    .I2(\vga/N157 ),
    .O(\vga/N1812 )
  );
  MUXF5 \vga/rom_addr_char<2>_f5_71  (
    .I0(\vga/N1812 ),
    .I1(\vga/N1712 ),
    .S(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f581 )
  );
  defparam \vga/rom_addr_char<1>181 .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<1>181  (
    .I0(\vga/rom_addr_char [1]),
    .I1(\vga/N63 ),
    .I2(\vga/N155 ),
    .O(\vga/N1912 )
  );
  defparam \vga/rom_addr_char<1>191 .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<1>191  (
    .I0(\vga/rom_addr_char [1]),
    .I1(\vga/N152 ),
    .I2(\vga/N62 ),
    .O(\vga/N2012 )
  );
  MUXF5 \vga/rom_addr_char<2>_f5_81  (
    .I0(\vga/N2012 ),
    .I1(\vga/N1912 ),
    .S(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f591 )
  );
  MUXF6 \vga/rom_addr_char<3>_f6_3  (
    .I0(\vga/rom_addr_char<2>_f591 ),
    .I1(\vga/rom_addr_char<2>_f581 ),
    .S(\vga/rom_addr_char [3]),
    .O(\vga/rom_addr_char<3>_f64_29 )
  );
  defparam \vga/rom_addr_char<1>201 .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<1>201  (
    .I0(\vga/rom_addr_char [1]),
    .I1(\vga/N113 ),
    .I2(\vga/N75 ),
    .O(\vga/N2112 )
  );
  defparam \vga/rom_addr_char<1>211 .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<1>211  (
    .I0(\vga/rom_addr_char_1_1_95 ),
    .I1(\vga/N72 ),
    .I2(\vga/N99 ),
    .O(\vga/N2212 )
  );
  MUXF5 \vga/rom_addr_char<2>_f5_9  (
    .I0(\vga/N2212 ),
    .I1(\vga/N2112 ),
    .S(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f510 )
  );
  defparam \vga/rom_addr_char<1>22 .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<1>22  (
    .I0(\vga/rom_addr_char_1_1_95 ),
    .I1(\vga/N70 ),
    .I2(\vga/N71 ),
    .O(\vga/N231 )
  );
  defparam \vga/rom_addr_char<1>23 .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<1>23  (
    .I0(\vga/rom_addr_char_1_1_95 ),
    .I1(\vga/N155 ),
    .I2(\vga/N64 ),
    .O(\vga/N241 )
  );
  MUXF5 \vga/rom_addr_char<2>_f5_10  (
    .I0(\vga/N241 ),
    .I1(N3079),
    .S(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f5111 )
  );
  MUXF6 \vga/rom_addr_char<3>_f6_4  (
    .I0(\vga/rom_addr_char<2>_f5111 ),
    .I1(\vga/rom_addr_char<2>_f510 ),
    .S(\vga/rom_addr_char [3]),
    .O(\vga/rom_addr_char<3>_f65 )
  );
  defparam \vga/rom_addr_char<4>11 .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<4>11  (
    .I0(\vga/rom_addr_char [4]),
    .I1(\vga/rom_addr_char<3>_f64_29 ),
    .I2(\vga/rom_addr_char<3>_f65 ),
    .O(\vga/N251 )
  );
  MUXF5 \vga/rom_addr_char<5>_f5  (
    .I0(\vga/N251 ),
    .I1(\vga/N1612 ),
    .S(\vga/rom_addr_char [5]),
    .O(\vga/rom_addr_char<5>_f5_30 )
  );
  defparam \vga/rom_addr_char<1>24 .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<1>24  (
    .I0(\vga/rom_addr_char_1_1_95 ),
    .I1(\vga/N14 ),
    .I2(\vga/N53 ),
    .O(\vga/N011234 )
  );
  defparam \vga/rom_addr_char<1>112 .INIT = 4'h8;
  LUT2 \vga/rom_addr_char<1>112  (
    .I0(\vga/N40 ),
    .I1(\vga/rom_addr_char [1]),
    .O(\vga/N1112345 )
  );
  MUXF5 \vga/rom_addr_char<2>_f52  (
    .I0(\vga/N1112345 ),
    .I1(\vga/N011234 ),
    .S(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f5123 )
  );
  defparam \vga/rom_addr_char<1>25 .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<1>25  (
    .I0(\vga/rom_addr_char_1_1_95 ),
    .I1(\vga/N49 ),
    .I2(\vga/N50 ),
    .O(\vga/N212345 )
  );
  defparam \vga/rom_addr_char<1>32 .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<1>32  (
    .I0(\vga/rom_addr_char_1_1_95 ),
    .I1(\vga/N47 ),
    .I2(\vga/N48 ),
    .O(\vga/N31234 )
  );
  MUXF5 \vga/rom_addr_char<2>_f5_02  (
    .I0(\vga/N31234 ),
    .I1(\vga/N212345 ),
    .S(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f5112 )
  );
  MUXF6 \vga/rom_addr_char<3>_f62  (
    .I0(\vga/rom_addr_char<2>_f5112 ),
    .I1(\vga/rom_addr_char<2>_f5123 ),
    .S(\vga/rom_addr_char [3]),
    .O(\vga/rom_addr_char<3>_f6123 )
  );
  defparam \vga/rom_addr_char<1>42 .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<1>42  (
    .I0(\vga/rom_addr_char_1_1_95 ),
    .I1(\vga/N59 ),
    .I2(\vga/N60 ),
    .O(\vga/N41234 )
  );
  defparam \vga/rom_addr_char<1>52 .INIT = 4'h4;
  LUT2 \vga/rom_addr_char<1>52  (
    .I0(\vga/rom_addr_char_1_1_95 ),
    .I1(\vga/N58 ),
    .O(\vga/N5123 )
  );
  MUXF5 \vga/rom_addr_char<2>_f5_12  (
    .I0(\vga/N5123 ),
    .I1(\vga/N41234 ),
    .S(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f5212 )
  );
  defparam \vga/rom_addr_char<1>62 .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<1>62  (
    .I0(\vga/rom_addr_char_1_1_95 ),
    .I1(\vga/N56 ),
    .I2(\vga/N57 ),
    .O(\vga/N61234 )
  );
  defparam \vga/rom_addr_char<1>72 .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<1>72  (
    .I0(\vga/rom_addr_char_1_1_95 ),
    .I1(\vga/N54 ),
    .I2(\vga/N55 ),
    .O(\vga/N71234 )
  );
  MUXF5 \vga/rom_addr_char<2>_f5_22  (
    .I0(\vga/N71234 ),
    .I1(\vga/N61234 ),
    .S(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f5312 )
  );
  MUXF6 \vga/rom_addr_char<3>_f6_02  (
    .I0(\vga/rom_addr_char<2>_f5312 ),
    .I1(\vga/rom_addr_char<2>_f5212 ),
    .S(\vga/rom_addr_char [3]),
    .O(\vga/rom_addr_char<3>_f6112 )
  );
  defparam \vga/rom_addr_char<1>82 .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<1>82  (
    .I0(\vga/rom_addr_char_1_1_95 ),
    .I1(\vga/N82 ),
    .I2(\vga/N83 ),
    .O(\vga/N81234 )
  );
  defparam \vga/rom_addr_char<1>92 .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<1>92  (
    .I0(\vga/rom_addr_char_1_1_95 ),
    .I1(\vga/N80 ),
    .I2(\vga/N81 ),
    .O(\vga/N91 )
  );
  MUXF5 \vga/rom_addr_char<2>_f5_32  (
    .I0(\vga/N91 ),
    .I1(\vga/N81234 ),
    .S(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f5412 )
  );
  defparam \vga/rom_addr_char<1>102 .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<1>102  (
    .I0(\vga/rom_addr_char [1]),
    .I1(\vga/N78 ),
    .I2(\vga/N79 ),
    .O(\vga/N10123 )
  );
  MUXF5 \vga/rom_addr_char<2>_f5_42  (
    .I0(\vga/N111123 ),
    .I1(N3080),
    .S(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f5512 )
  );
  MUXF6 \vga/rom_addr_char<3>_f6_12  (
    .I0(\vga/rom_addr_char<2>_f5512 ),
    .I1(\vga/rom_addr_char<2>_f5412 ),
    .S(\vga/rom_addr_char [3]),
    .O(\vga/rom_addr_char<3>_f6212 )
  );
  defparam \vga/rom_addr_char<1>122 .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<1>122  (
    .I0(\vga/rom_addr_char [1]),
    .I1(\vga/N89 ),
    .I2(\vga/N90 ),
    .O(\vga/N12123 )
  );
  defparam \vga/rom_addr_char<1>132 .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<1>132  (
    .I0(\vga/rom_addr_char [1]),
    .I1(\vga/N87 ),
    .I2(\vga/N88 ),
    .O(\vga/N13123 )
  );
  MUXF5 \vga/rom_addr_char<2>_f5_52  (
    .I0(\vga/N13123 ),
    .I1(\vga/N12123 ),
    .S(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f5612 )
  );
  defparam \vga/rom_addr_char<1>142 .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<1>142  (
    .I0(\vga/rom_addr_char [1]),
    .I1(\vga/N85 ),
    .I2(\vga/N86 ),
    .O(\vga/N14123 )
  );
  MUXF5 \vga/rom_addr_char<2>_f5_62  (
    .I0(\vga/N15123 ),
    .I1(\vga/N14123 ),
    .S(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f5712 )
  );
  MUXF6 \vga/rom_addr_char<3>_f6_22  (
    .I0(\vga/rom_addr_char<2>_f5712 ),
    .I1(\vga/rom_addr_char<2>_f5612 ),
    .S(\vga/rom_addr_char [3]),
    .O(\vga/rom_addr_char<3>_f6312 )
  );
  defparam \vga/rom_addr_char<4>4 .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<4>4  (
    .I0(\vga/rom_addr_char [4]),
    .I1(\vga/rom_addr_char<3>_f6212 ),
    .I2(\vga/rom_addr_char<3>_f6312 ),
    .O(\vga/N16123 )
  );
  defparam \vga/rom_addr_char<1>162 .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<1>162  (
    .I0(\vga/rom_addr_char [1]),
    .I1(\vga/N67 ),
    .I2(\vga/N65 ),
    .O(\vga/N17123 )
  );
  defparam \vga/rom_addr_char<1>172 .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<1>172  (
    .I0(\vga/rom_addr_char [1]),
    .I1(\vga/N65 ),
    .I2(\vga/N66 ),
    .O(\vga/N18123 )
  );
  MUXF5 \vga/rom_addr_char<2>_f5_72  (
    .I0(\vga/N18123 ),
    .I1(\vga/N17123 ),
    .S(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f5812 )
  );
  defparam \vga/rom_addr_char<1>182 .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<1>182  (
    .I0(\vga/rom_addr_char [1]),
    .I1(\vga/N63 ),
    .I2(\vga/N64 ),
    .O(\vga/N19123 )
  );
  defparam \vga/rom_addr_char<1>192 .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<1>192  (
    .I0(\vga/rom_addr_char [1]),
    .I1(\vga/N61 ),
    .I2(\vga/N62 ),
    .O(\vga/N20123 )
  );
  MUXF5 \vga/rom_addr_char<2>_f5_82  (
    .I0(\vga/N20123 ),
    .I1(N3081),
    .S(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f5912 )
  );
  MUXF6 \vga/rom_addr_char<3>_f6_31  (
    .I0(\vga/rom_addr_char<2>_f5912 ),
    .I1(\vga/rom_addr_char<2>_f5812 ),
    .S(\vga/rom_addr_char [3]),
    .O(\vga/rom_addr_char<3>_f641 )
  );
  defparam \vga/rom_addr_char<1>202 .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<1>202  (
    .I0(\vga/rom_addr_char [1]),
    .I1(\vga/N74 ),
    .I2(\vga/N75 ),
    .O(\vga/N21123 )
  );
  defparam \vga/rom_addr_char<1>212 .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<1>212  (
    .I0(\vga/rom_addr_char_1_1_95 ),
    .I1(\vga/N72 ),
    .I2(\vga/N73 ),
    .O(\vga/N22123 )
  );
  MUXF5 \vga/rom_addr_char<2>_f5_91  (
    .I0(\vga/N22123 ),
    .I1(\vga/N21123 ),
    .S(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f5101 )
  );
  defparam \vga/rom_addr_char<1>231 .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<1>231  (
    .I0(\vga/rom_addr_char_1_1_95 ),
    .I1(\vga/N68 ),
    .I2(\vga/N69 ),
    .O(\vga/N2412 )
  );
  MUXF5 \vga/rom_addr_char<2>_f5_101  (
    .I0(\vga/N2412 ),
    .I1(\vga/N231 ),
    .S(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f51112 )
  );
  MUXF6 \vga/rom_addr_char<3>_f6_41  (
    .I0(\vga/rom_addr_char<2>_f51112 ),
    .I1(\vga/rom_addr_char<2>_f5101 ),
    .S(\vga/rom_addr_char [3]),
    .O(\vga/rom_addr_char<3>_f651 )
  );
  defparam \vga/rom_addr_char<4>12 .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<4>12  (
    .I0(\vga/rom_addr_char [4]),
    .I1(\vga/rom_addr_char<3>_f641 ),
    .I2(\vga/rom_addr_char<3>_f651 ),
    .O(\vga/N2512 )
  );
  MUXF5 \vga/rom_addr_char<5>_f51  (
    .I0(\vga/N2512 ),
    .I1(\vga/N16123 ),
    .S(\vga/rom_addr_char [5]),
    .O(\vga/rom_addr_char<5>_f51_31 )
  );
  defparam \vga/rom_addr_char<1>26 .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<1>26  (
    .I0(\vga/rom_addr_char_1_1_95 ),
    .I1(\vga/N94 ),
    .I2(\vga/N95 ),
    .O(\vga/N0112345 )
  );
  MUXF5 \vga/rom_addr_char<2>_f53  (
    .I0(\vga/N11123456 ),
    .I1(\vga/N0112345 ),
    .S(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f51234 )
  );
  defparam \vga/rom_addr_char<1>33 .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<1>33  (
    .I0(\vga/rom_addr_char_1_1_95 ),
    .I1(\vga/N104 ),
    .I2(\vga/N105 ),
    .O(\vga/N2123456 )
  );
  MUXF5 \vga/rom_addr_char<2>_f5_03  (
    .I0(\vga/N312345 ),
    .I1(\vga/N2123456 ),
    .S(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f51123 )
  );
  defparam \vga/rom_addr_char<1>53 .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<1>53  (
    .I0(\vga/rom_addr_char_1_1_95 ),
    .I1(\vga/N101 ),
    .I2(\vga/N102 ),
    .O(\vga/N412345 )
  );
  defparam \vga/rom_addr_char<1>63 .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<1>63  (
    .I0(\vga/rom_addr_char_1_1_95 ),
    .I1(\vga/N99 ),
    .I2(\vga/N55 ),
    .O(\vga/N51234 )
  );
  MUXF5 \vga/rom_addr_char<2>_f5_13  (
    .I0(\vga/N51234 ),
    .I1(\vga/N412345 ),
    .S(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f52123 )
  );
  MUXF6 \vga/rom_addr_char<3>_f63  (
    .I0(\vga/rom_addr_char<2>_f52123 ),
    .I1(\vga/rom_addr_char<2>_f51123 ),
    .S(\vga/rom_addr_char [3]),
    .O(\vga/rom_addr_char<3>_f61234 )
  );
  defparam \vga/rom_addr_char<1>73 .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<1>73  (
    .I0(\vga/rom_addr_char_1_1_95 ),
    .I1(\vga/N127 ),
    .I2(\vga/N128 ),
    .O(\vga/N612345 )
  );
  defparam \vga/rom_addr_char<1>83 .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<1>83  (
    .I0(\vga/rom_addr_char_1_1_95 ),
    .I1(\vga/N125 ),
    .I2(\vga/N126 ),
    .O(\vga/N712345 )
  );
  MUXF5 \vga/rom_addr_char<2>_f5_23  (
    .I0(\vga/N712345 ),
    .I1(\vga/N612345 ),
    .S(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f53123 )
  );
  MUXF5 \vga/rom_addr_char<2>_f5_33  (
    .I0(\vga/N9123 ),
    .I1(\vga/N10123 ),
    .S(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f54123 )
  );
  MUXF6 \vga/rom_addr_char<3>_f6_03  (
    .I0(\vga/rom_addr_char<2>_f54123 ),
    .I1(\vga/rom_addr_char<2>_f53123 ),
    .S(\vga/rom_addr_char [3]),
    .O(\vga/rom_addr_char<3>_f61123 )
  );
  defparam \vga/rom_addr_char<1>115 .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<1>115  (
    .I0(\vga/rom_addr_char [1]),
    .I1(\vga/N133 ),
    .I2(\vga/N134 ),
    .O(\vga/N101234 )
  );
  defparam \vga/rom_addr_char<1>123 .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<1>123  (
    .I0(\vga/rom_addr_char [1]),
    .I1(\vga/N131 ),
    .I2(\vga/N132 ),
    .O(\vga/N1110 )
  );
  MUXF5 \vga/rom_addr_char<2>_f5_43  (
    .I0(\vga/N1110 ),
    .I1(\vga/N101234 ),
    .S(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f55123 )
  );
  defparam \vga/rom_addr_char<1>133 .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<1>133  (
    .I0(\vga/rom_addr_char [1]),
    .I1(\vga/N129 ),
    .I2(\vga/N130 ),
    .O(\vga/N121234 )
  );
  MUXF5 \vga/rom_addr_char<2>_f5_53  (
    .I0(\vga/N131234 ),
    .I1(\vga/N121234 ),
    .S(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f56123 )
  );
  MUXF6 \vga/rom_addr_char<3>_f6_13  (
    .I0(\vga/rom_addr_char<2>_f56123 ),
    .I1(\vga/rom_addr_char<2>_f55123 ),
    .S(\vga/rom_addr_char [3]),
    .O(\vga/rom_addr_char<3>_f62123 )
  );
  defparam \vga/rom_addr_char<4>5 .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<4>5  (
    .I0(\vga/rom_addr_char [4]),
    .I1(\vga/rom_addr_char<3>_f61123 ),
    .I2(\vga/rom_addr_char<3>_f62123 ),
    .O(\vga/N141234 )
  );
  defparam \vga/rom_addr_char<1>153 .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<1>153  (
    .I0(\vga/rom_addr_char [1]),
    .I1(\vga/N82 ),
    .I2(\vga/N113 ),
    .O(\vga/N151234 )
  );
  defparam \vga/rom_addr_char<1>163 .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<1>163  (
    .I0(\vga/rom_addr_char [1]),
    .I1(\vga/N110 ),
    .I2(\vga/N111 ),
    .O(\vga/N161234 )
  );
  MUXF5 \vga/rom_addr_char<2>_f5_63  (
    .I0(\vga/N161234 ),
    .I1(\vga/N151234 ),
    .S(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f57123 )
  );
  defparam \vga/rom_addr_char<1>183 .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<1>183  (
    .I0(\vga/rom_addr_char [1]),
    .I1(\vga/N106 ),
    .I2(\vga/N62 ),
    .O(\vga/N181234 )
  );
  MUXF5 \vga/rom_addr_char<2>_f5_73  (
    .I0(\vga/N181234 ),
    .I1(\vga/N19123 ),
    .S(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f58123 )
  );
  MUXF6 \vga/rom_addr_char<3>_f6_23  (
    .I0(\vga/rom_addr_char<2>_f58123 ),
    .I1(\vga/rom_addr_char<2>_f57123 ),
    .S(\vga/rom_addr_char [3]),
    .O(\vga/rom_addr_char<3>_f63123 )
  );
  defparam \vga/rom_addr_char<1>193 .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<1>193  (
    .I0(\vga/rom_addr_char [1]),
    .I1(\vga/N65 ),
    .I2(\vga/N120 ),
    .O(\vga/N191234 )
  );
  defparam \vga/rom_addr_char<1>203 .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<1>203  (
    .I0(\vga/rom_addr_char_1_1_95 ),
    .I1(\vga/N117 ),
    .I2(\vga/N118 ),
    .O(\vga/N201234 )
  );
  MUXF5 \vga/rom_addr_char<2>_f5_83  (
    .I0(\vga/N201234 ),
    .I1(\vga/N191234 ),
    .S(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f59123 )
  );
  defparam \vga/rom_addr_char<1>213 .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<1>213  (
    .I0(\vga/rom_addr_char_1_1_95 ),
    .I1(\vga/N115 ),
    .I2(\vga/N116 ),
    .O(\vga/N211234 )
  );
  defparam \vga/rom_addr_char<1>222 .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<1>222  (
    .I0(\vga/rom_addr_char_1_1_95 ),
    .I1(\vga/N114 ),
    .I2(\vga/N64 ),
    .O(\vga/N221234 )
  );
  MUXF5 \vga/rom_addr_char<2>_f5_92  (
    .I0(\vga/N221234 ),
    .I1(\vga/N211234 ),
    .S(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f51012 )
  );
  MUXF6 \vga/rom_addr_char<3>_f6_32  (
    .I0(\vga/rom_addr_char<2>_f51012 ),
    .I1(\vga/rom_addr_char<2>_f59123 ),
    .S(\vga/rom_addr_char [3]),
    .O(\vga/rom_addr_char<3>_f6412 )
  );
  defparam \vga/rom_addr_char<4>13 .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<4>13  (
    .I0(\vga/rom_addr_char [4]),
    .I1(\vga/rom_addr_char<3>_f63123 ),
    .I2(\vga/rom_addr_char<3>_f6412 ),
    .O(\vga/N23123 )
  );
  MUXF5 \vga/rom_addr_char<5>_f52  (
    .I0(\vga/N23123 ),
    .I1(\vga/N141234 ),
    .S(\vga/rom_addr_char [5]),
    .O(\vga/rom_addr_char<5>_f512 )
  );
  defparam \vga/rom_addr_char<1>28 .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<1>28  (
    .I0(\vga/rom_addr_char_1_1_95 ),
    .I1(\vga/N14 ),
    .I2(\vga/N2 ),
    .O(\vga/N01123456 )
  );
  defparam \vga/rom_addr_char<1>116 .INIT = 4'h8;
  LUT2 \vga/rom_addr_char<1>116  (
    .I0(\vga/N186 ),
    .I1(\vga/rom_addr_char [1]),
    .O(\vga/N111234567 )
  );
  MUXF5 \vga/rom_addr_char<2>_f54  (
    .I0(\vga/N111234567 ),
    .I1(\vga/N01123456 ),
    .S(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f512345 )
  );
  defparam \vga/rom_addr_char<1>29 .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<1>29  (
    .I0(\vga/rom_addr_char_1_1_95 ),
    .I1(\vga/N184 ),
    .I2(\vga/N8 ),
    .O(\vga/N21234567 )
  );
  defparam \vga/rom_addr_char<1>34 .INIT = 4'h8;
  LUT2 \vga/rom_addr_char<1>34  (
    .I0(\vga/N183 ),
    .I1(\vga/rom_addr_char_1_1_95 ),
    .O(\vga/N3123456 )
  );
  MUXF5 \vga/rom_addr_char<2>_f5_04  (
    .I0(\vga/N3123456 ),
    .I1(\vga/N21234567 ),
    .S(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f511234 )
  );
  MUXF6 \vga/rom_addr_char<3>_f64  (
    .I0(\vga/rom_addr_char<2>_f511234 ),
    .I1(\vga/rom_addr_char<2>_f512345 ),
    .S(\vga/rom_addr_char [3]),
    .O(\vga/rom_addr_char<3>_f612345 )
  );
  defparam \vga/rom_addr_char<1>44 .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<1>44  (
    .I0(\vga/rom_addr_char_1_1_95 ),
    .I1(\vga/N194 ),
    .I2(\vga/N15 ),
    .O(\vga/N4123456 )
  );
  defparam \vga/rom_addr_char<1>54 .INIT = 4'h4;
  LUT2 \vga/rom_addr_char<1>54  (
    .I0(\vga/rom_addr_char_1_1_95 ),
    .I1(\vga/N193 ),
    .O(\vga/N512345 )
  );
  MUXF5 \vga/rom_addr_char<2>_f5_14  (
    .I0(\vga/N512345 ),
    .I1(\vga/N4123456 ),
    .S(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f521234 )
  );
  defparam \vga/rom_addr_char<1>64 .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<1>64  (
    .I0(\vga/rom_addr_char_1_1_95 ),
    .I1(\vga/N191 ),
    .I2(\vga/N192 ),
    .O(\vga/N6123456 )
  );
  defparam \vga/rom_addr_char<1>74 .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<1>74  (
    .I0(\vga/rom_addr_char_1_1_95 ),
    .I1(\vga/N16 ),
    .I2(\vga/N190 ),
    .O(\vga/N7123456 )
  );
  MUXF5 \vga/rom_addr_char<2>_f5_24  (
    .I0(\vga/N7123456 ),
    .I1(\vga/N6123456 ),
    .S(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f531234 )
  );
  MUXF6 \vga/rom_addr_char<3>_f6_04  (
    .I0(\vga/rom_addr_char<2>_f531234 ),
    .I1(\vga/rom_addr_char<2>_f521234 ),
    .S(\vga/rom_addr_char [3]),
    .O(\vga/rom_addr_char<3>_f611234 )
  );
  defparam \vga/rom_addr_char<1>84 .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<1>84  (
    .I0(\vga/rom_addr_char_1_1_95 ),
    .I1(\vga/N41 ),
    .I2(\vga/N213 ),
    .O(\vga/N8123456 )
  );
  defparam \vga/rom_addr_char<1>94 .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<1>94  (
    .I0(\vga/rom_addr_char_1_1_95 ),
    .I1(\vga/N27 ),
    .I2(\vga/N29 ),
    .O(\vga/N91234 )
  );
  MUXF5 \vga/rom_addr_char<2>_f5_34  (
    .I0(\vga/N91234 ),
    .I1(\vga/N8123456 ),
    .S(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f541234 )
  );
  defparam \vga/rom_addr_char<1>117 .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<1>117  (
    .I0(\vga/rom_addr_char [1]),
    .I1(\vga/N2 ),
    .I2(\vga/N208 ),
    .O(\vga/N1111234 )
  );
  MUXF5 \vga/rom_addr_char<2>_f5_44  (
    .I0(\vga/N1111234 ),
    .I1(\vga/N1012345 ),
    .S(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f551234 )
  );
  MUXF6 \vga/rom_addr_char<3>_f6_14  (
    .I0(\vga/rom_addr_char<2>_f551234 ),
    .I1(\vga/rom_addr_char<2>_f541234 ),
    .S(\vga/rom_addr_char [3]),
    .O(\vga/rom_addr_char<3>_f621234 )
  );
  defparam \vga/rom_addr_char<1>124 .INIT = 4'h8;
  LUT2 \vga/rom_addr_char<1>124  (
    .I0(\vga/N134 ),
    .I1(\vga/rom_addr_char [1]),
    .O(\vga/N1212345 )
  );
  defparam \vga/rom_addr_char<1>134 .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<1>134  (
    .I0(\vga/rom_addr_char [1]),
    .I1(\vga/N218 ),
    .I2(\vga/N219 ),
    .O(\vga/N1312345 )
  );
  MUXF5 \vga/rom_addr_char<2>_f5_54  (
    .I0(\vga/N1312345 ),
    .I1(\vga/N1212345 ),
    .S(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f561234 )
  );
  defparam \vga/rom_addr_char<1>144 .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<1>144  (
    .I0(\vga/rom_addr_char [1]),
    .I1(\vga/N216 ),
    .I2(\vga/N45 ),
    .O(\vga/N1412345 )
  );
  defparam \vga/rom_addr_char<1>154 .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<1>154  (
    .I0(\vga/rom_addr_char [1]),
    .I1(\vga/N214 ),
    .I2(\vga/N215 ),
    .O(\vga/N1512345 )
  );
  MUXF5 \vga/rom_addr_char<2>_f5_64  (
    .I0(\vga/N1512345 ),
    .I1(\vga/N1412345 ),
    .S(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f571234 )
  );
  MUXF6 \vga/rom_addr_char<3>_f6_24  (
    .I0(\vga/rom_addr_char<2>_f571234 ),
    .I1(\vga/rom_addr_char<2>_f561234 ),
    .S(\vga/rom_addr_char [3]),
    .O(\vga/rom_addr_char<3>_f631234 )
  );
  defparam \vga/rom_addr_char<4>6 .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<4>6  (
    .I0(\vga/rom_addr_char [4]),
    .I1(\vga/rom_addr_char<3>_f621234 ),
    .I2(\vga/rom_addr_char<3>_f631234 ),
    .O(\vga/N1612345 )
  );
  defparam \vga/rom_addr_char<2>5 .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<2>5  (
    .I0(\vga/rom_addr_char [2]),
    .I1(\vga/rom_addr_char<1>112_32 ),
    .I2(\vga/rom_addr_char<1>_mmx_out ),
    .O(\vga/N1712345 )
  );
  defparam \vga/rom_addr_char<2>13 .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<2>13  (
    .I0(\vga/rom_addr_char [2]),
    .I1(\vga/rom_addr_char<1>2_33 ),
    .I2(\vga/rom_addr_char<1>_mmx_out ),
    .O(\vga/N1812345 )
  );
  MUXF5 \vga/rom_addr_char<3>_f5  (
    .I0(\vga/N1812345 ),
    .I1(\vga/N1712345 ),
    .S(\vga/rom_addr_char [3]),
    .O(\vga/rom_addr_char<3>_f5_34 )
  );
  defparam \vga/rom_addr_char<1>184 .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<1>184  (
    .I0(\vga/rom_addr_char [1]),
    .I1(\vga/N134 ),
    .I2(\vga/N37 ),
    .O(\vga/N1912345 )
  );
  defparam \vga/rom_addr_char<1>194 .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<1>194  (
    .I0(\vga/rom_addr_char [1]),
    .I1(\vga/N35 ),
    .I2(\vga/N205 ),
    .O(\vga/N2012345 )
  );
  MUXF5 \vga/rom_addr_char<2>_f5_74  (
    .I0(\vga/N2012345 ),
    .I1(\vga/N1912345 ),
    .S(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f581234 )
  );
  defparam \vga/rom_addr_char<1>214 .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<1>214  (
    .I0(\vga/rom_addr_char_1_1_95 ),
    .I1(\vga/N30 ),
    .I2(\vga/N201 ),
    .O(\vga/N2212345 )
  );
  MUXF5 \vga/rom_addr_char<2>_f5_84  (
    .I0(\vga/N2212345 ),
    .I1(\vga/N1511 ),
    .S(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f591234 )
  );
  MUXF6 \vga/rom_addr_char<3>_f6_33  (
    .I0(\vga/rom_addr_char<2>_f591234 ),
    .I1(\vga/rom_addr_char<2>_f581234 ),
    .S(\vga/rom_addr_char [3]),
    .O(\vga/rom_addr_char<3>_f64123 )
  );
  defparam \vga/rom_addr_char<4>14 .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<4>14  (
    .I0(\vga/rom_addr_char [4]),
    .I1(\vga/rom_addr_char<3>_f5_34 ),
    .I2(\vga/rom_addr_char<3>_f64123 ),
    .O(\vga/N231234 )
  );
  MUXF5 \vga/rom_addr_char<5>_f53  (
    .I0(\vga/N231234 ),
    .I1(\vga/N1612345 ),
    .S(\vga/rom_addr_char [5]),
    .O(\vga/rom_addr_char<5>_f5123 )
  );
  defparam \vga/rom_addr_char<2>6 .INIT = 16'hE040;
  LUT4 \vga/rom_addr_char<2>6  (
    .I0(\vga/rom_addr_char_1_1_95 ),
    .I1(\vga/N221 ),
    .I2(\vga/rom_addr_char [2]),
    .I3(\vga/N222 ),
    .O(\vga/N011234567 )
  );
  MULT_AND \vga/Madd_ram_addr_videoC_mand  (
    .I0(\vga/vgacore/vcnt [3]),
    .I1(\vga/vgacore/hcnt [7]),
    .LO(\vga/Madd_ram_addr_videoC_mand1 )
  );
  defparam \vga/Madd_ram_addr_video_Madd_lut<5> .INIT = 16'h8778;
  LUT4 \vga/Madd_ram_addr_video_Madd_lut<5>  (
    .I0(\vga/vgacore/vcnt [3]),
    .I1(\vga/vgacore/hcnt [7]),
    .I2(\vga/vgacore/hcnt [8]),
    .I3(\vga/vgacore/vcnt [4]),
    .O(\vga/ram_addr_video [5])
  );
  MUXCY \vga/Madd_ram_addr_video_Madd_cy<5>  (
    .CI(N2),
    .DI(\vga/Madd_ram_addr_videoC_mand1 ),
    .S(\vga/ram_addr_video [5]),
    .O(\vga/Madd_ram_addr_video_Madd_cy [5])
  );
  MULT_AND \vga/Madd_ram_addr_videoC1_mand  (
    .I0(\vga/vgacore/vcnt [4]),
    .I1(\vga/vgacore/hcnt [8]),
    .LO(\vga/Madd_ram_addr_videoC1_mand1 )
  );
  defparam \vga/Madd_ram_addr_video_Madd_lut<6> .INIT = 8'h78;
  LUT3 \vga/Madd_ram_addr_video_Madd_lut<6>  (
    .I0(\vga/vgacore/vcnt [4]),
    .I1(\vga/vgacore/hcnt [8]),
    .I2(\vga/Madd_ram_addr_videoR2 ),
    .O(\vga/N229 )
  );
  MUXCY \vga/Madd_ram_addr_video_Madd_cy<6>  (
    .CI(\vga/Madd_ram_addr_video_Madd_cy [5]),
    .DI(\vga/Madd_ram_addr_videoC1_mand1 ),
    .S(\vga/N229 ),
    .O(\vga/Madd_ram_addr_video_Madd_cy [6])
  );
  XORCY \vga/Madd_ram_addr_video_Madd_xor<6>  (
    .CI(\vga/Madd_ram_addr_video_Madd_cy [5]),
    .LI(\vga/N229 ),
    .O(\vga/ram_addr_video [6])
  );
  MUXCY \vga/Madd_ram_addr_video_Madd_cy<7>  (
    .CI(\vga/Madd_ram_addr_video_Madd_cy [6]),
    .DI(\vga/Madd_ram_addr_videoC2 ),
    .S(\vga/N230 ),
    .O(\vga/Madd_ram_addr_video_Madd_cy [7])
  );
  XORCY \vga/Madd_ram_addr_video_Madd_xor<7>  (
    .CI(\vga/Madd_ram_addr_video_Madd_cy [6]),
    .LI(\vga/N230 ),
    .O(\vga/ram_addr_video [7])
  );
  MULT_AND \vga/Madd_ram_addr_videoC3_mand  (
    .I0(\vga/vgacore/vcnt [4]),
    .I1(\vga/vgacore/vcnt [6]),
    .LO(\vga/Madd_ram_addr_videoC3_mand1 )
  );
  defparam \vga/Madd_ram_addr_video_Madd_lut<8> .INIT = 16'h8778;
  LUT4 \vga/Madd_ram_addr_video_Madd_lut<8>  (
    .I0(\vga/vgacore/vcnt [4]),
    .I1(\vga/vgacore/vcnt [6]),
    .I2(\vga/vgacore/vcnt [7]),
    .I3(\vga/vgacore/vcnt [5]),
    .O(\vga/N2313 )
  );
  MUXCY \vga/Madd_ram_addr_video_Madd_cy<8>  (
    .CI(\vga/Madd_ram_addr_video_Madd_cy [7]),
    .DI(\vga/Madd_ram_addr_videoC3_mand1 ),
    .S(\vga/N2313 ),
    .O(\vga/Madd_ram_addr_video_Madd_cy [8])
  );
  XORCY \vga/Madd_ram_addr_video_Madd_xor<8>  (
    .CI(\vga/Madd_ram_addr_video_Madd_cy [7]),
    .LI(\vga/N2313 ),
    .O(\vga/ram_addr_video [8])
  );
  MULT_AND \vga/Madd_ram_addr_videoC4_mand  (
    .I0(\vga/vgacore/vcnt [5]),
    .I1(\vga/vgacore/vcnt [7]),
    .LO(\vga/Madd_ram_addr_videoC4_mand1 )
  );
  defparam \vga/Madd_ram_addr_video_Madd_lut<9> .INIT = 16'h8778;
  LUT4 \vga/Madd_ram_addr_video_Madd_lut<9>  (
    .I0(\vga/vgacore/vcnt [5]),
    .I1(\vga/vgacore/vcnt [7]),
    .I2(\vga/vgacore/vcnt [8]),
    .I3(\vga/vgacore/vcnt [6]),
    .O(\vga/N232 )
  );
  MUXCY \vga/Madd_ram_addr_video_Madd_cy<9>  (
    .CI(\vga/Madd_ram_addr_video_Madd_cy [8]),
    .DI(\vga/Madd_ram_addr_videoC4_mand1 ),
    .S(\vga/N232 ),
    .O(\vga/Madd_ram_addr_video_Madd_cy [9])
  );
  XORCY \vga/Madd_ram_addr_video_Madd_xor<9>  (
    .CI(\vga/Madd_ram_addr_video_Madd_cy [8]),
    .LI(\vga/N232 ),
    .O(\vga/ram_addr_video [9])
  );
  MUXCY \vga/Madd_ram_addr_video_Madd_cy<10>  (
    .CI(\vga/Madd_ram_addr_video_Madd_cy [9]),
    .DI(\vga/vgacore/vcnt [7]),
    .S(\vga/N233 ),
    .O(\vga/Madd_ram_addr_video_Madd_cy [10])
  );
  XORCY \vga/Madd_ram_addr_video_Madd_xor<10>  (
    .CI(\vga/Madd_ram_addr_video_Madd_cy [9]),
    .LI(\vga/N233 ),
    .O(\vga/ram_addr_video [10])
  );
  XORCY \vga/Madd_ram_addr_video_Madd_xor<11>  (
    .CI(\vga/Madd_ram_addr_video_Madd_cy [10]),
    .LI(\vga/vgacore/vcnt_8_rt_86 ),
    .O(\vga/ram_addr_video [11])
  );
  FDCE \vga/crt/newline  (
    .D(\vga/crt/N3 ),
    .CE(\vga/crt/_not0010 ),
    .CLR(gray_cnt_Rst_inv),
    .C(\vga/crtclk_15 ),
    .Q(\vga/crt/newline_37 )
  );
  FDCE \vga/crt/ram_data_0  (
    .D(\vga/crt/_mux0002 [0]),
    .CE(\vga/crt/_not0008 ),
    .CLR(gray_cnt_Rst_inv),
    .C(\vga/crtclk_15 ),
    .Q(\vga/crt/ram_data [0])
  );
  FDCE \vga/crt/ram_data_1  (
    .D(\vga/crt/_mux0002 [1]),
    .CE(\vga/crt/_not0008 ),
    .CLR(gray_cnt_Rst_inv),
    .C(\vga/crtclk_15 ),
    .Q(\vga/crt/ram_data [1])
  );
  FDCE \vga/crt/ram_data_2  (
    .D(\vga/crt/_mux0002 [2]),
    .CE(\vga/crt/_not0008 ),
    .CLR(gray_cnt_Rst_inv),
    .C(\vga/crtclk_15 ),
    .Q(\vga/crt/ram_data [2])
  );
  FDCE \vga/crt/ram_data_3  (
    .D(\vga/crt/_mux0002 [3]),
    .CE(\vga/crt/_not0008 ),
    .CLR(gray_cnt_Rst_inv),
    .C(\vga/crtclk_15 ),
    .Q(\vga/crt/ram_data [3])
  );
  FDCE \vga/crt/ram_data_4  (
    .D(\vga/crt/_mux0002 [4]),
    .CE(\vga/crt/_not0008 ),
    .CLR(gray_cnt_Rst_inv),
    .C(\vga/crtclk_15 ),
    .Q(\vga/crt/ram_data [4])
  );
  FDCE \vga/crt/ram_data_5  (
    .D(\vga/crt/_mux0002 [5]),
    .CE(\vga/crt/_not0008 ),
    .CLR(gray_cnt_Rst_inv),
    .C(\vga/crtclk_15 ),
    .Q(\vga/crt/ram_data [5])
  );
  FDCE \vga/crt/ram_data_6  (
    .D(\vga/crt/_mux0002 [6]),
    .CE(\vga/crt/_not0008 ),
    .CLR(gray_cnt_Rst_inv),
    .C(\vga/crtclk_15 ),
    .Q(\vga/crt/ram_data [6])
  );
  FDC \vga/crt/write_delay_0  (
    .D(\vga/crt/write_delay__mux0000 [0]),
    .CLR(gray_cnt_Rst_inv),
    .C(\vga/crtclk_15 ),
    .Q(\vga/crt/write_delay [0])
  );
  FDC \vga/crt/write_delay_1  (
    .D(\vga/crt/write_delay__mux0000 [1]),
    .CLR(gray_cnt_Rst_inv),
    .C(\vga/crtclk_15 ),
    .Q(\vga/crt/write_delay [1])
  );
  FDC \vga/crt/write_delay_2  (
    .D(\vga/crt/write_delay__mux0000 [2]),
    .CLR(gray_cnt_Rst_inv),
    .C(\vga/crtclk_15 ),
    .Q(\vga/crt/write_delay [2])
  );
  FDCE \vga/crt/cursor_h_0  (
    .D(\vga/crt/cursor_h_Eqn_0 ),
    .CE(\vga/crt/_not0006 ),
    .CLR(gray_cnt_Rst_inv),
    .C(\vga/crtclk_15 ),
    .Q(\vga/crt/cursor_h [0])
  );
  FDCE \vga/crt/cursor_h_1  (
    .D(\vga/crt/cursor_h_Eqn_1 ),
    .CE(\vga/crt/_not0006 ),
    .CLR(gray_cnt_Rst_inv),
    .C(\vga/crtclk_15 ),
    .Q(\vga/crt/cursor_h [1])
  );
  FDCE \vga/crt/cursor_h_2  (
    .D(\vga/crt/cursor_h_Eqn_2 ),
    .CE(\vga/crt/_not0006 ),
    .CLR(gray_cnt_Rst_inv),
    .C(\vga/crtclk_15 ),
    .Q(\vga/crt/cursor_h [2])
  );
  FDCE \vga/crt/cursor_h_3  (
    .D(\vga/crt/cursor_h_Eqn_3 ),
    .CE(\vga/crt/_not0006 ),
    .CLR(gray_cnt_Rst_inv),
    .C(\vga/crtclk_15 ),
    .Q(\vga/crt/cursor_h [3])
  );
  FDCE \vga/crt/cursor_h_4  (
    .D(\vga/crt/cursor_h_Eqn_4 ),
    .CE(\vga/crt/_not0006 ),
    .CLR(gray_cnt_Rst_inv),
    .C(\vga/crtclk_15 ),
    .Q(\vga/crt/cursor_h [4])
  );
  FDCE \vga/crt/cursor_h_5  (
    .D(\vga/crt/cursor_h_Eqn_5 ),
    .CE(\vga/crt/_not0006 ),
    .CLR(gray_cnt_Rst_inv),
    .C(\vga/crtclk_15 ),
    .Q(\vga/crt/cursor_h [5])
  );
  FDCE \vga/crt/cursor_h_6  (
    .D(\vga/crt/cursor_h_Eqn_6 ),
    .CE(\vga/crt/_not0006 ),
    .CLR(gray_cnt_Rst_inv),
    .C(\vga/crtclk_15 ),
    .Q(\vga/crt/cursor_h [6])
  );
  FDCE \vga/crt/cursor_v_0  (
    .D(\vga/crt/cursor_v_Eqn_0 ),
    .CE(\vga/crt/_not0007 ),
    .CLR(gray_cnt_Rst_inv),
    .C(\vga/crtclk_15 ),
    .Q(\vga/crt/cursor_v [0])
  );
  FDCE \vga/crt/cursor_v_1  (
    .D(\vga/crt/cursor_v_Eqn_1 ),
    .CE(\vga/crt/_not0007 ),
    .CLR(gray_cnt_Rst_inv),
    .C(\vga/crtclk_15 ),
    .Q(\vga/crt/cursor_v [1])
  );
  FDCE \vga/crt/cursor_v_2  (
    .D(\vga/crt/cursor_v_Eqn_2 ),
    .CE(\vga/crt/_not0007 ),
    .CLR(gray_cnt_Rst_inv),
    .C(\vga/crtclk_15 ),
    .Q(\vga/crt/cursor_v [2])
  );
  FDCE \vga/crt/cursor_v_3  (
    .D(\vga/crt/cursor_v_Eqn_3 ),
    .CE(\vga/crt/_not0007 ),
    .CLR(gray_cnt_Rst_inv),
    .C(\vga/crtclk_15 ),
    .Q(\vga/crt/cursor_v [3])
  );
  FDCE \vga/crt/cursor_v_4  (
    .D(\vga/crt/cursor_v_Eqn_4 ),
    .CE(\vga/crt/_not0007 ),
    .CLR(gray_cnt_Rst_inv),
    .C(\vga/crtclk_15 ),
    .Q(\vga/crt/cursor_v [4])
  );
  FDCE \vga/crt/cursor_v_5  (
    .D(\vga/crt/cursor_v_Eqn_5 ),
    .CE(\vga/crt/_not0007 ),
    .CLR(gray_cnt_Rst_inv),
    .C(\vga/crtclk_15 ),
    .Q(\vga/crt/cursor_v [5])
  );
  MULT_AND \vga/crt/Madd_ram_addrC_mand  (
    .I0(\vga/crt/cursor_h [4]),
    .I1(\vga/crt/cursor_v [0]),
    .LO(\vga/crt/Madd_ram_addrC_mand1 )
  );
  defparam \vga/crt/Madd_ram_addr_Madd_lut<5> .INIT = 16'h8778;
  LUT4 \vga/crt/Madd_ram_addr_Madd_lut<5>  (
    .I0(\vga/crt/cursor_h [4]),
    .I1(\vga/crt/cursor_v [0]),
    .I2(\vga/crt/cursor_v [1]),
    .I3(\vga/crt/cursor_h [5]),
    .O(\vga/ram_addr_write [5])
  );
  MUXCY \vga/crt/Madd_ram_addr_Madd_cy<5>  (
    .CI(N2),
    .DI(\vga/crt/Madd_ram_addrC_mand1 ),
    .S(\vga/ram_addr_write [5]),
    .O(\vga/crt/Madd_ram_addr_Madd_cy [5])
  );
  MULT_AND \vga/crt/Madd_ram_addrC1_mand  (
    .I0(\vga/crt/cursor_h [5]),
    .I1(\vga/crt/cursor_v [1]),
    .LO(\vga/crt/Madd_ram_addrC1_mand1 )
  );
  defparam \vga/crt/Madd_ram_addr_Madd_lut<6> .INIT = 8'h78;
  LUT3 \vga/crt/Madd_ram_addr_Madd_lut<6>  (
    .I0(\vga/crt/cursor_h [5]),
    .I1(\vga/crt/cursor_v [1]),
    .I2(\vga/crt/Madd_ram_addrR2 ),
    .O(\vga/crt/N8 )
  );
  MUXCY \vga/crt/Madd_ram_addr_Madd_cy<6>  (
    .CI(\vga/crt/Madd_ram_addr_Madd_cy [5]),
    .DI(\vga/crt/Madd_ram_addrC1_mand1 ),
    .S(\vga/crt/N8 ),
    .O(\vga/crt/Madd_ram_addr_Madd_cy [6])
  );
  XORCY \vga/crt/Madd_ram_addr_Madd_xor<6>  (
    .CI(\vga/crt/Madd_ram_addr_Madd_cy [5]),
    .LI(\vga/crt/N8 ),
    .O(\vga/ram_addr_write [6])
  );
  MUXCY \vga/crt/Madd_ram_addr_Madd_cy<7>  (
    .CI(\vga/crt/Madd_ram_addr_Madd_cy [6]),
    .DI(\vga/crt/Madd_ram_addrC2 ),
    .S(\vga/crt/N9 ),
    .O(\vga/crt/Madd_ram_addr_Madd_cy [7])
  );
  XORCY \vga/crt/Madd_ram_addr_Madd_xor<7>  (
    .CI(\vga/crt/Madd_ram_addr_Madd_cy [6]),
    .LI(\vga/crt/N9 ),
    .O(\vga/ram_addr_write [7])
  );
  MULT_AND \vga/crt/Madd_ram_addrC3_mand  (
    .I0(\vga/crt/cursor_v [1]),
    .I1(\vga/crt/cursor_v [3]),
    .LO(\vga/crt/Madd_ram_addrC3_mand1 )
  );
  defparam \vga/crt/Madd_ram_addr_Madd_lut<8> .INIT = 16'h8778;
  LUT4 \vga/crt/Madd_ram_addr_Madd_lut<8>  (
    .I0(\vga/crt/cursor_v [1]),
    .I1(\vga/crt/cursor_v [3]),
    .I2(\vga/crt/cursor_v [4]),
    .I3(\vga/crt/cursor_v [2]),
    .O(\vga/crt/N10 )
  );
  MUXCY \vga/crt/Madd_ram_addr_Madd_cy<8>  (
    .CI(\vga/crt/Madd_ram_addr_Madd_cy [7]),
    .DI(\vga/crt/Madd_ram_addrC3_mand1 ),
    .S(\vga/crt/N10 ),
    .O(\vga/crt/Madd_ram_addr_Madd_cy [8])
  );
  XORCY \vga/crt/Madd_ram_addr_Madd_xor<8>  (
    .CI(\vga/crt/Madd_ram_addr_Madd_cy [7]),
    .LI(\vga/crt/N10 ),
    .O(\vga/ram_addr_write [8])
  );
  MULT_AND \vga/crt/Madd_ram_addrC4_mand  (
    .I0(\vga/crt/cursor_v [2]),
    .I1(\vga/crt/cursor_v [4]),
    .LO(\vga/crt/Madd_ram_addrC4_mand1 )
  );
  defparam \vga/crt/Madd_ram_addr_Madd_lut<9> .INIT = 16'h8778;
  LUT4 \vga/crt/Madd_ram_addr_Madd_lut<9>  (
    .I0(\vga/crt/cursor_v [2]),
    .I1(\vga/crt/cursor_v [4]),
    .I2(\vga/crt/cursor_v [5]),
    .I3(\vga/crt/cursor_v [3]),
    .O(\vga/crt/N11 )
  );
  MUXCY \vga/crt/Madd_ram_addr_Madd_cy<9>  (
    .CI(\vga/crt/Madd_ram_addr_Madd_cy [8]),
    .DI(\vga/crt/Madd_ram_addrC4_mand1 ),
    .S(\vga/crt/N11 ),
    .O(\vga/crt/Madd_ram_addr_Madd_cy [9])
  );
  XORCY \vga/crt/Madd_ram_addr_Madd_xor<9>  (
    .CI(\vga/crt/Madd_ram_addr_Madd_cy [8]),
    .LI(\vga/crt/N11 ),
    .O(\vga/ram_addr_write [9])
  );
  MUXCY \vga/crt/Madd_ram_addr_Madd_cy<10>  (
    .CI(\vga/crt/Madd_ram_addr_Madd_cy [9]),
    .DI(\vga/crt/cursor_v [4]),
    .S(\vga/crt/N12 ),
    .O(\vga/crt/Madd_ram_addr_Madd_cy [10])
  );
  XORCY \vga/crt/Madd_ram_addr_Madd_xor<10>  (
    .CI(\vga/crt/Madd_ram_addr_Madd_cy [9]),
    .LI(\vga/crt/N12 ),
    .O(\vga/ram_addr_write [10])
  );
  XORCY \vga/crt/Madd_ram_addr_Madd_xor<11>  (
    .CI(\vga/crt/Madd_ram_addr_Madd_cy [10]),
    .LI(\vga/crt/cursor_v_5_rt_87 ),
    .O(\vga/ram_addr_write [11])
  );
  MUXCY \vga/crt/Mcount_cursor_v_cy<0>  (
    .CI(N2),
    .DI(N3),
    .S(\vga/crt/Result [0]),
    .O(\vga/crt/Mcount_cursor_v_cy [0])
  );
  MUXCY \vga/crt/Mcount_cursor_v_cy<1>  (
    .CI(\vga/crt/Mcount_cursor_v_cy [0]),
    .DI(N2),
    .S(\vga/crt/cursor_v_1_rt_64 ),
    .O(\vga/crt/Mcount_cursor_v_cy [1])
  );
  XORCY \vga/crt/Mcount_cursor_v_xor<1>  (
    .CI(\vga/crt/Mcount_cursor_v_cy [0]),
    .LI(\vga/crt/cursor_v_1_rt_64 ),
    .O(\vga/crt/Result [1])
  );
  MUXCY \vga/crt/Mcount_cursor_v_cy<2>  (
    .CI(\vga/crt/Mcount_cursor_v_cy [1]),
    .DI(N2),
    .S(\vga/crt/cursor_v_2_rt_65 ),
    .O(\vga/crt/Mcount_cursor_v_cy [2])
  );
  XORCY \vga/crt/Mcount_cursor_v_xor<2>  (
    .CI(\vga/crt/Mcount_cursor_v_cy [1]),
    .LI(\vga/crt/cursor_v_2_rt_65 ),
    .O(\vga/crt/Result [2])
  );
  MUXCY \vga/crt/Mcount_cursor_v_cy<3>  (
    .CI(\vga/crt/Mcount_cursor_v_cy [2]),
    .DI(N2),
    .S(\vga/crt/cursor_v_3_rt_66 ),
    .O(\vga/crt/Mcount_cursor_v_cy [3])
  );
  XORCY \vga/crt/Mcount_cursor_v_xor<3>  (
    .CI(\vga/crt/Mcount_cursor_v_cy [2]),
    .LI(\vga/crt/cursor_v_3_rt_66 ),
    .O(\vga/crt/Result [3])
  );
  MUXCY \vga/crt/Mcount_cursor_v_cy<4>  (
    .CI(\vga/crt/Mcount_cursor_v_cy [3]),
    .DI(N2),
    .S(\vga/crt/cursor_v_4_rt_67 ),
    .O(\vga/crt/Mcount_cursor_v_cy [4])
  );
  XORCY \vga/crt/Mcount_cursor_v_xor<4>  (
    .CI(\vga/crt/Mcount_cursor_v_cy [3]),
    .LI(\vga/crt/cursor_v_4_rt_67 ),
    .O(\vga/crt/Result [4])
  );
  XORCY \vga/crt/Mcount_cursor_v_xor<5>  (
    .CI(\vga/crt/Mcount_cursor_v_cy [4]),
    .LI(\vga/crt/cursor_v_5_rt1_88 ),
    .O(\vga/crt/Result [5])
  );
  MUXCY \vga/crt/Mcount_cursor_h_cy<0>  (
    .CI(N2),
    .DI(N3),
    .S(\vga/crt/Result<0>1 ),
    .O(\vga/crt/Mcount_cursor_h_cy [0])
  );
  MUXCY \vga/crt/Mcount_cursor_h_cy<1>  (
    .CI(\vga/crt/Mcount_cursor_h_cy [0]),
    .DI(N2),
    .S(\vga/crt/cursor_h_1_rt_68 ),
    .O(\vga/crt/Mcount_cursor_h_cy [1])
  );
  XORCY \vga/crt/Mcount_cursor_h_xor<1>  (
    .CI(\vga/crt/Mcount_cursor_h_cy [0]),
    .LI(\vga/crt/cursor_h_1_rt_68 ),
    .O(\vga/crt/Result<1>1 )
  );
  MUXCY \vga/crt/Mcount_cursor_h_cy<2>  (
    .CI(\vga/crt/Mcount_cursor_h_cy [1]),
    .DI(N2),
    .S(\vga/crt/cursor_h_2_rt_69 ),
    .O(\vga/crt/Mcount_cursor_h_cy [2])
  );
  XORCY \vga/crt/Mcount_cursor_h_xor<2>  (
    .CI(\vga/crt/Mcount_cursor_h_cy [1]),
    .LI(\vga/crt/cursor_h_2_rt_69 ),
    .O(\vga/crt/Result<2>1 )
  );
  MUXCY \vga/crt/Mcount_cursor_h_cy<3>  (
    .CI(\vga/crt/Mcount_cursor_h_cy [2]),
    .DI(N2),
    .S(\vga/crt/cursor_h_3_rt_70 ),
    .O(\vga/crt/Mcount_cursor_h_cy [3])
  );
  XORCY \vga/crt/Mcount_cursor_h_xor<3>  (
    .CI(\vga/crt/Mcount_cursor_h_cy [2]),
    .LI(\vga/crt/cursor_h_3_rt_70 ),
    .O(\vga/crt/Result<3>1 )
  );
  MUXCY \vga/crt/Mcount_cursor_h_cy<4>  (
    .CI(\vga/crt/Mcount_cursor_h_cy [3]),
    .DI(N2),
    .S(\vga/crt/cursor_h_4_rt_71 ),
    .O(\vga/crt/Mcount_cursor_h_cy [4])
  );
  XORCY \vga/crt/Mcount_cursor_h_xor<4>  (
    .CI(\vga/crt/Mcount_cursor_h_cy [3]),
    .LI(\vga/crt/cursor_h_4_rt_71 ),
    .O(\vga/crt/Result<4>1 )
  );
  MUXCY \vga/crt/Mcount_cursor_h_cy<5>  (
    .CI(\vga/crt/Mcount_cursor_h_cy [4]),
    .DI(N2),
    .S(\vga/crt/cursor_h_5_rt_72 ),
    .O(\vga/crt/Mcount_cursor_h_cy [5])
  );
  XORCY \vga/crt/Mcount_cursor_h_xor<5>  (
    .CI(\vga/crt/Mcount_cursor_h_cy [4]),
    .LI(\vga/crt/cursor_h_5_rt_72 ),
    .O(\vga/crt/Result<5>1 )
  );
  XORCY \vga/crt/Mcount_cursor_h_xor<6>  (
    .CI(\vga/crt/Mcount_cursor_h_cy [5]),
    .LI(\vga/crt/cursor_h_6_rt_89 ),
    .O(\vga/crt/Result [6])
  );
  FDC \vga/crt/state_FFd3  (
    .D(\vga/crt/state_FFd3-In ),
    .CLR(gray_cnt_Rst_inv),
    .C(\vga/crtclk_15 ),
    .Q(\vga/crt/state_FFd3_42 )
  );
  FDC \vga/crt/state_FFd1  (
    .D(\vga/crt/state_FFd1-In_43 ),
    .CLR(gray_cnt_Rst_inv),
    .C(\vga/crtclk_15 ),
    .Q(\vga/crt/state_FFd1_40 )
  );
  FDC \vga/crt/state_FFd2  (
    .D(\vga/crt/state_FFd2-In ),
    .CLR(gray_cnt_Rst_inv),
    .C(\vga/crtclk_15 ),
    .Q(\vga/crt/state_FFd2_41 )
  );
  FDC \vga/vgacore/hsync  (
    .D(\vga/vgacore/_and0000 ),
    .CLR(gray_cnt_Rst_inv1_INV_0_1_99),
    .C(gray_cnt_FFd1_9),
    .Q(\vga/vgacore/hsync_7 )
  );
  FDC \vga/vgacore/vsync  (
    .D(\vga/vgacore/_and0001_44 ),
    .CLR(gray_cnt_Rst_inv1_INV_0_1_99),
    .C(gray_cnt_FFd1_9),
    .Q(\vga/vgacore/vsync_6 )
  );
  FDC \vga/vgacore/hblank  (
    .D(\vga/vgacore/_mux0002 ),
    .CLR(gray_cnt_Rst_inv1_INV_0_1_99),
    .C(gray_cnt_FFd1_9),
    .Q(\vga/vgacore/hblank_12 )
  );
  FDC \vga/vgacore/hcnt_0  (
    .D(\vga/vgacore/Result [0]),
    .CLR(gray_cnt_Rst_inv1_INV_0_1_99),
    .C(gray_cnt_FFd1_9),
    .Q(\vga/vgacore/hcnt [0])
  );
  FDC \vga/vgacore/hcnt_1  (
    .D(\vga/vgacore/Result [1]),
    .CLR(gray_cnt_Rst_inv1_INV_0_1_99),
    .C(gray_cnt_FFd1_9),
    .Q(\vga/vgacore/hcnt [1])
  );
  FDC \vga/vgacore/hcnt_2  (
    .D(\vga/vgacore/Result [2]),
    .CLR(gray_cnt_Rst_inv1_INV_0_1_99),
    .C(gray_cnt_FFd1_9),
    .Q(\vga/vgacore/hcnt [2])
  );
  FDC \vga/vgacore/hcnt_3  (
    .D(\vga/vgacore/Result [3]),
    .CLR(gray_cnt_Rst_inv1_INV_0_1_99),
    .C(gray_cnt_FFd1_9),
    .Q(\vga/vgacore/hcnt [3])
  );
  FDC \vga/vgacore/hcnt_4  (
    .D(\vga/vgacore/Result [4]),
    .CLR(gray_cnt_Rst_inv1_INV_0_1_99),
    .C(gray_cnt_FFd1_9),
    .Q(\vga/vgacore/hcnt [4])
  );
  FDC \vga/vgacore/hcnt_5  (
    .D(\vga/vgacore/Result [5]),
    .CLR(gray_cnt_Rst_inv1_INV_0_1_99),
    .C(gray_cnt_FFd1_9),
    .Q(\vga/vgacore/hcnt [5])
  );
  FDC \vga/vgacore/hcnt_6  (
    .D(\vga/vgacore/Result [6]),
    .CLR(gray_cnt_Rst_inv1_INV_0_1_99),
    .C(gray_cnt_FFd1_9),
    .Q(\vga/vgacore/hcnt [6])
  );
  FDC \vga/vgacore/hcnt_7  (
    .D(\vga/vgacore/Result [7]),
    .CLR(gray_cnt_Rst_inv1_INV_0_1_99),
    .C(gray_cnt_FFd1_9),
    .Q(\vga/vgacore/hcnt [7])
  );
  FDC \vga/vgacore/hcnt_8  (
    .D(\vga/vgacore/Result [8]),
    .CLR(gray_cnt_Rst_inv1_INV_0_1_99),
    .C(gray_cnt_FFd1_9),
    .Q(\vga/vgacore/hcnt [8])
  );
  FDC \vga/vgacore/hcnt_9  (
    .D(\vga/vgacore/Result [9]),
    .CLR(gray_cnt_Rst_inv1_INV_0_1_99),
    .C(gray_cnt_FFd1_9),
    .Q(\vga/vgacore/hcnt [9])
  );
  FDC \vga/vgacore/hcnt_10  (
    .D(\vga/vgacore/Result [10]),
    .CLR(gray_cnt_Rst_inv1_INV_0_1_99),
    .C(gray_cnt_FFd1_9),
    .Q(\vga/vgacore/hcnt [10])
  );
  FDC_1 \vga/vgacore/vcnt_0  (
    .D(\vga/vgacore/Result<0>1 ),
    .CLR(gray_cnt_Rst_inv1_INV_0_1_99),
    .C(\vga/vgacore/hblank_12 ),
    .Q(\vga/vgacore/vcnt [0])
  );
  FDC_1 \vga/vgacore/vcnt_1  (
    .D(\vga/vgacore/Result<1>1 ),
    .CLR(gray_cnt_Rst_inv1_INV_0_1_99),
    .C(\vga/vgacore/hblank_12 ),
    .Q(\vga/vgacore/vcnt [1])
  );
  FDC_1 \vga/vgacore/vcnt_2  (
    .D(\vga/vgacore/Result<2>1 ),
    .CLR(gray_cnt_Rst_inv1_INV_0_1_99),
    .C(\vga/vgacore/hblank_12 ),
    .Q(\vga/vgacore/vcnt [2])
  );
  FDC_1 \vga/vgacore/vcnt_3  (
    .D(\vga/vgacore/Result<3>1 ),
    .CLR(gray_cnt_Rst_inv1_INV_0_1_99),
    .C(\vga/vgacore/hblank_12 ),
    .Q(\vga/vgacore/vcnt [3])
  );
  FDC_1 \vga/vgacore/vcnt_4  (
    .D(\vga/vgacore/Result<4>1 ),
    .CLR(gray_cnt_Rst_inv1_INV_0_1_99),
    .C(\vga/vgacore/hblank_12 ),
    .Q(\vga/vgacore/vcnt [4])
  );
  FDC_1 \vga/vgacore/vcnt_5  (
    .D(\vga/vgacore/Result<5>1 ),
    .CLR(gray_cnt_Rst_inv1_INV_0_1_99),
    .C(\vga/vgacore/hblank_12 ),
    .Q(\vga/vgacore/vcnt [5])
  );
  FDC_1 \vga/vgacore/vcnt_6  (
    .D(\vga/vgacore/Result<6>1 ),
    .CLR(gray_cnt_Rst_inv1_INV_0_1_99),
    .C(\vga/vgacore/hblank_12 ),
    .Q(\vga/vgacore/vcnt [6])
  );
  FDC_1 \vga/vgacore/vcnt_7  (
    .D(\vga/vgacore/Result<7>1 ),
    .CLR(gray_cnt_Rst_inv1_INV_0_1_99),
    .C(\vga/vgacore/hblank_12 ),
    .Q(\vga/vgacore/vcnt [7])
  );
  FDC_1 \vga/vgacore/vcnt_8  (
    .D(\vga/vgacore/Result<8>1 ),
    .CLR(gray_cnt_Rst_inv1_INV_0_1_99),
    .C(\vga/vgacore/hblank_12 ),
    .Q(\vga/vgacore/vcnt [8])
  );
  FDC_1 \vga/vgacore/vcnt_9  (
    .D(\vga/vgacore/Result<9>1 ),
    .CLR(gray_cnt_Rst_inv1_INV_0_1_99),
    .C(\vga/vgacore/hblank_12 ),
    .Q(\vga/vgacore/vcnt [9])
  );
  defparam \vga/vgacore/Mcompar__cmp_lt0000_lut<0> .INIT = 16'h8000;
  LUT4 \vga/vgacore/Mcompar__cmp_lt0000_lut<0>  (
    .I0(\vga/vgacore/hcnt [0]),
    .I1(\vga/vgacore/hcnt [1]),
    .I2(\vga/vgacore/hcnt [2]),
    .I3(\vga/vgacore/hcnt [3]),
    .O(\vga/vgacore/N4 )
  );
  MUXCY \vga/vgacore/Mcompar__cmp_lt0000_cy<0>  (
    .CI(N3),
    .DI(N2),
    .S(\vga/vgacore/N4 ),
    .O(\vga/vgacore/Mcompar__cmp_lt0000_cy [0])
  );
  MUXCY \vga/vgacore/Mcompar__cmp_lt0000_cy<1>  (
    .CI(\vga/vgacore/Mcompar__cmp_lt0000_cy [0]),
    .DI(N2),
    .S(\vga/vgacore/hcnt_4_rt_73 ),
    .O(\vga/vgacore/Mcompar__cmp_lt0000_cy [1])
  );
  defparam \vga/vgacore/Mcompar__cmp_lt0000_lut<2> .INIT = 8'h01;
  LUT3 \vga/vgacore/Mcompar__cmp_lt0000_lut<2>  (
    .I0(\vga/vgacore/hcnt [5]),
    .I1(\vga/vgacore/hcnt [6]),
    .I2(\vga/vgacore/hcnt [7]),
    .O(\vga/vgacore/N5 )
  );
  MUXCY \vga/vgacore/Mcompar__cmp_lt0000_cy<2>  (
    .CI(\vga/vgacore/Mcompar__cmp_lt0000_cy [1]),
    .DI(N3),
    .S(\vga/vgacore/N5 ),
    .O(\vga/vgacore/Mcompar__cmp_lt0000_cy [2])
  );
  defparam \vga/vgacore/Mcompar__cmp_lt0000_lut<3> .INIT = 4'h8;
  LUT2 \vga/vgacore/Mcompar__cmp_lt0000_lut<3>  (
    .I0(\vga/vgacore/hcnt [8]),
    .I1(\vga/vgacore/hcnt [9]),
    .O(\vga/vgacore/N6 )
  );
  MUXCY \vga/vgacore/Mcompar__cmp_lt0000_cy<3>  (
    .CI(\vga/vgacore/Mcompar__cmp_lt0000_cy [2]),
    .DI(N2),
    .S(\vga/vgacore/N6 ),
    .O(\vga/vgacore/Mcompar__cmp_lt0000_cy [3])
  );
  MUXCY \vga/vgacore/Mcompar__cmp_lt0000_cy<4>  (
    .CI(\vga/vgacore/Mcompar__cmp_lt0000_cy [3]),
    .DI(N3),
    .S(\vga/vgacore/N7 ),
    .O(\vga/vgacore/Mcompar__cmp_lt0000_cy [4])
  );
  MULT_AND \vga/vgacore/hcnt_Eqn_0_mand  (
    .I0(\vga/vgacore/hcnt_Eqn_bis_0 ),
    .I1(\vga/vgacore/hcnt [0]),
    .LO(\vga/vgacore/hcnt_Eqn_0_mand1 )
  );
  defparam \vga/vgacore/Mcount_hcnt_lut<0> .INIT = 4'h4;
  LUT2 \vga/vgacore/Mcount_hcnt_lut<0>  (
    .I0(\vga/vgacore/hcnt [0]),
    .I1(\vga/vgacore/hcnt_Eqn_bis_0 ),
    .O(\vga/vgacore/Result [0])
  );
  MUXCY \vga/vgacore/Mcount_hcnt_cy<0>  (
    .CI(N2),
    .DI(\vga/vgacore/hcnt_Eqn_0_mand1 ),
    .S(\vga/vgacore/Result [0]),
    .O(\vga/vgacore/Mcount_hcnt_cy [0])
  );
  MUXCY \vga/vgacore/Mcount_hcnt_cy<1>  (
    .CI(\vga/vgacore/Mcount_hcnt_cy [0]),
    .DI(N2),
    .S(\vga/vgacore/hcnt_Eqn_1 ),
    .O(\vga/vgacore/Mcount_hcnt_cy [1])
  );
  XORCY \vga/vgacore/Mcount_hcnt_xor<1>  (
    .CI(\vga/vgacore/Mcount_hcnt_cy [0]),
    .LI(\vga/vgacore/hcnt_Eqn_1 ),
    .O(\vga/vgacore/Result [1])
  );
  MUXCY \vga/vgacore/Mcount_hcnt_cy<2>  (
    .CI(\vga/vgacore/Mcount_hcnt_cy [1]),
    .DI(N2),
    .S(\vga/vgacore/hcnt_Eqn_2 ),
    .O(\vga/vgacore/Mcount_hcnt_cy [2])
  );
  XORCY \vga/vgacore/Mcount_hcnt_xor<2>  (
    .CI(\vga/vgacore/Mcount_hcnt_cy [1]),
    .LI(\vga/vgacore/hcnt_Eqn_2 ),
    .O(\vga/vgacore/Result [2])
  );
  MUXCY \vga/vgacore/Mcount_hcnt_cy<3>  (
    .CI(\vga/vgacore/Mcount_hcnt_cy [2]),
    .DI(N2),
    .S(\vga/vgacore/hcnt_Eqn_3 ),
    .O(\vga/vgacore/Mcount_hcnt_cy [3])
  );
  XORCY \vga/vgacore/Mcount_hcnt_xor<3>  (
    .CI(\vga/vgacore/Mcount_hcnt_cy [2]),
    .LI(\vga/vgacore/hcnt_Eqn_3 ),
    .O(\vga/vgacore/Result [3])
  );
  MUXCY \vga/vgacore/Mcount_hcnt_cy<4>  (
    .CI(\vga/vgacore/Mcount_hcnt_cy [3]),
    .DI(N2),
    .S(\vga/vgacore/hcnt_Eqn_4 ),
    .O(\vga/vgacore/Mcount_hcnt_cy [4])
  );
  XORCY \vga/vgacore/Mcount_hcnt_xor<4>  (
    .CI(\vga/vgacore/Mcount_hcnt_cy [3]),
    .LI(\vga/vgacore/hcnt_Eqn_4 ),
    .O(\vga/vgacore/Result [4])
  );
  MUXCY \vga/vgacore/Mcount_hcnt_cy<5>  (
    .CI(\vga/vgacore/Mcount_hcnt_cy [4]),
    .DI(N2),
    .S(\vga/vgacore/hcnt_Eqn_5 ),
    .O(\vga/vgacore/Mcount_hcnt_cy [5])
  );
  XORCY \vga/vgacore/Mcount_hcnt_xor<5>  (
    .CI(\vga/vgacore/Mcount_hcnt_cy [4]),
    .LI(\vga/vgacore/hcnt_Eqn_5 ),
    .O(\vga/vgacore/Result [5])
  );
  MUXCY \vga/vgacore/Mcount_hcnt_cy<6>  (
    .CI(\vga/vgacore/Mcount_hcnt_cy [5]),
    .DI(N2),
    .S(\vga/vgacore/hcnt_Eqn_6 ),
    .O(\vga/vgacore/Mcount_hcnt_cy [6])
  );
  XORCY \vga/vgacore/Mcount_hcnt_xor<6>  (
    .CI(\vga/vgacore/Mcount_hcnt_cy [5]),
    .LI(\vga/vgacore/hcnt_Eqn_6 ),
    .O(\vga/vgacore/Result [6])
  );
  MUXCY \vga/vgacore/Mcount_hcnt_cy<7>  (
    .CI(\vga/vgacore/Mcount_hcnt_cy [6]),
    .DI(N2),
    .S(\vga/vgacore/hcnt_Eqn_7 ),
    .O(\vga/vgacore/Mcount_hcnt_cy [7])
  );
  XORCY \vga/vgacore/Mcount_hcnt_xor<7>  (
    .CI(\vga/vgacore/Mcount_hcnt_cy [6]),
    .LI(\vga/vgacore/hcnt_Eqn_7 ),
    .O(\vga/vgacore/Result [7])
  );
  MUXCY \vga/vgacore/Mcount_hcnt_cy<8>  (
    .CI(\vga/vgacore/Mcount_hcnt_cy [7]),
    .DI(N2),
    .S(\vga/vgacore/hcnt_Eqn_8 ),
    .O(\vga/vgacore/Mcount_hcnt_cy [8])
  );
  XORCY \vga/vgacore/Mcount_hcnt_xor<8>  (
    .CI(\vga/vgacore/Mcount_hcnt_cy [7]),
    .LI(\vga/vgacore/hcnt_Eqn_8 ),
    .O(\vga/vgacore/Result [8])
  );
  MUXCY \vga/vgacore/Mcount_hcnt_cy<9>  (
    .CI(\vga/vgacore/Mcount_hcnt_cy [8]),
    .DI(N2),
    .S(\vga/vgacore/hcnt_Eqn_9 ),
    .O(\vga/vgacore/Mcount_hcnt_cy [9])
  );
  XORCY \vga/vgacore/Mcount_hcnt_xor<9>  (
    .CI(\vga/vgacore/Mcount_hcnt_cy [8]),
    .LI(\vga/vgacore/hcnt_Eqn_9 ),
    .O(\vga/vgacore/Result [9])
  );
  XORCY \vga/vgacore/Mcount_hcnt_xor<10>  (
    .CI(\vga/vgacore/Mcount_hcnt_cy [9]),
    .LI(\vga/vgacore/hcnt_Eqn_10 ),
    .O(\vga/vgacore/Result [10])
  );
  MULT_AND \vga/vgacore/vcnt_Eqn_0_mand  (
    .I0(\vga/vgacore/vcnt_Eqn_bis_0 ),
    .I1(\vga/vgacore/vcnt [0]),
    .LO(\vga/vgacore/vcnt_Eqn_0_mand1 )
  );
  defparam \vga/vgacore/Mcount_vcnt_lut<0> .INIT = 4'h4;
  LUT2 \vga/vgacore/Mcount_vcnt_lut<0>  (
    .I0(\vga/vgacore/vcnt [0]),
    .I1(\vga/vgacore/vcnt_Eqn_bis_0 ),
    .O(\vga/vgacore/Result<0>1 )
  );
  MUXCY \vga/vgacore/Mcount_vcnt_cy<0>  (
    .CI(N2),
    .DI(\vga/vgacore/vcnt_Eqn_0_mand1 ),
    .S(\vga/vgacore/Result<0>1 ),
    .O(\vga/vgacore/Mcount_vcnt_cy [0])
  );
  MUXCY \vga/vgacore/Mcount_vcnt_cy<1>  (
    .CI(\vga/vgacore/Mcount_vcnt_cy [0]),
    .DI(N2),
    .S(\vga/vgacore/vcnt_Eqn_1_45 ),
    .O(\vga/vgacore/Mcount_vcnt_cy [1])
  );
  XORCY \vga/vgacore/Mcount_vcnt_xor<1>  (
    .CI(\vga/vgacore/Mcount_vcnt_cy [0]),
    .LI(\vga/vgacore/vcnt_Eqn_1_45 ),
    .O(\vga/vgacore/Result<1>1 )
  );
  MUXCY \vga/vgacore/Mcount_vcnt_cy<2>  (
    .CI(\vga/vgacore/Mcount_vcnt_cy [1]),
    .DI(N2),
    .S(\vga/vgacore/vcnt_Eqn_2 ),
    .O(\vga/vgacore/Mcount_vcnt_cy [2])
  );
  XORCY \vga/vgacore/Mcount_vcnt_xor<2>  (
    .CI(\vga/vgacore/Mcount_vcnt_cy [1]),
    .LI(\vga/vgacore/vcnt_Eqn_2 ),
    .O(\vga/vgacore/Result<2>1 )
  );
  MUXCY \vga/vgacore/Mcount_vcnt_cy<3>  (
    .CI(\vga/vgacore/Mcount_vcnt_cy [2]),
    .DI(N2),
    .S(\vga/vgacore/vcnt_Eqn_3_46 ),
    .O(\vga/vgacore/Mcount_vcnt_cy [3])
  );
  XORCY \vga/vgacore/Mcount_vcnt_xor<3>  (
    .CI(\vga/vgacore/Mcount_vcnt_cy [2]),
    .LI(\vga/vgacore/vcnt_Eqn_3_46 ),
    .O(\vga/vgacore/Result<3>1 )
  );
  MUXCY \vga/vgacore/Mcount_vcnt_cy<4>  (
    .CI(\vga/vgacore/Mcount_vcnt_cy [3]),
    .DI(N2),
    .S(\vga/vgacore/vcnt_Eqn_4 ),
    .O(\vga/vgacore/Mcount_vcnt_cy [4])
  );
  XORCY \vga/vgacore/Mcount_vcnt_xor<4>  (
    .CI(\vga/vgacore/Mcount_vcnt_cy [3]),
    .LI(\vga/vgacore/vcnt_Eqn_4 ),
    .O(\vga/vgacore/Result<4>1 )
  );
  MUXCY \vga/vgacore/Mcount_vcnt_cy<5>  (
    .CI(\vga/vgacore/Mcount_vcnt_cy [4]),
    .DI(N2),
    .S(\vga/vgacore/vcnt_Eqn_5 ),
    .O(\vga/vgacore/Mcount_vcnt_cy [5])
  );
  XORCY \vga/vgacore/Mcount_vcnt_xor<5>  (
    .CI(\vga/vgacore/Mcount_vcnt_cy [4]),
    .LI(\vga/vgacore/vcnt_Eqn_5 ),
    .O(\vga/vgacore/Result<5>1 )
  );
  MUXCY \vga/vgacore/Mcount_vcnt_cy<6>  (
    .CI(\vga/vgacore/Mcount_vcnt_cy [5]),
    .DI(N2),
    .S(\vga/vgacore/vcnt_Eqn_6 ),
    .O(\vga/vgacore/Mcount_vcnt_cy [6])
  );
  XORCY \vga/vgacore/Mcount_vcnt_xor<6>  (
    .CI(\vga/vgacore/Mcount_vcnt_cy [5]),
    .LI(\vga/vgacore/vcnt_Eqn_6 ),
    .O(\vga/vgacore/Result<6>1 )
  );
  MUXCY \vga/vgacore/Mcount_vcnt_cy<7>  (
    .CI(\vga/vgacore/Mcount_vcnt_cy [6]),
    .DI(N2),
    .S(\vga/vgacore/vcnt_Eqn_7 ),
    .O(\vga/vgacore/Mcount_vcnt_cy [7])
  );
  XORCY \vga/vgacore/Mcount_vcnt_xor<7>  (
    .CI(\vga/vgacore/Mcount_vcnt_cy [6]),
    .LI(\vga/vgacore/vcnt_Eqn_7 ),
    .O(\vga/vgacore/Result<7>1 )
  );
  MUXCY \vga/vgacore/Mcount_vcnt_cy<8>  (
    .CI(\vga/vgacore/Mcount_vcnt_cy [7]),
    .DI(N2),
    .S(\vga/vgacore/vcnt_Eqn_8 ),
    .O(\vga/vgacore/Mcount_vcnt_cy [8])
  );
  XORCY \vga/vgacore/Mcount_vcnt_xor<8>  (
    .CI(\vga/vgacore/Mcount_vcnt_cy [7]),
    .LI(\vga/vgacore/vcnt_Eqn_8 ),
    .O(\vga/vgacore/Result<8>1 )
  );
  XORCY \vga/vgacore/Mcount_vcnt_xor<9>  (
    .CI(\vga/vgacore/Mcount_vcnt_cy [8]),
    .LI(\vga/vgacore/vcnt_Eqn_9 ),
    .O(\vga/vgacore/Result<9>1 )
  );
  FDC \vga/ps2/rdy_r  (
    .D(\vga/ps2/scancode_rdy ),
    .CLR(gray_cnt_Rst_inv),
    .C(gray_cnt_FFd1_9),
    .Q(\vga/ps2/rdy_r_8 )
  );
  FDP \vga/ps2/ps2_clk_r_0  (
    .D(ps2_clk_IBUF_1),
    .PRE(gray_cnt_Rst_inv),
    .C(gray_cnt_FFd1_9),
    .Q(\vga/ps2/ps2_clk_r [0])
  );
  FDP \vga/ps2/ps2_clk_r_1  (
    .D(\vga/ps2/ps2_clk_r [0]),
    .PRE(gray_cnt_Rst_inv),
    .C(gray_cnt_FFd1_9),
    .Q(\vga/ps2/ps2_clk_r [1])
  );
  FDP \vga/ps2/ps2_clk_r_2  (
    .D(\vga/ps2/ps2_clk_r [1]),
    .PRE(gray_cnt_Rst_inv),
    .C(gray_cnt_FFd1_9),
    .Q(\vga/ps2/ps2_clk_r [2])
  );
  FDP \vga/ps2/ps2_clk_r_3  (
    .D(\vga/ps2/ps2_clk_r [2]),
    .PRE(gray_cnt_Rst_inv),
    .C(gray_cnt_FFd1_9),
    .Q(\vga/ps2/ps2_clk_r [3])
  );
  FDP \vga/ps2/ps2_clk_r_4  (
    .D(\vga/ps2/ps2_clk_r [3]),
    .PRE(gray_cnt_Rst_inv),
    .C(gray_cnt_FFd1_9),
    .Q(\vga/ps2/ps2_clk_r [4])
  );
  FDC \vga/ps2/timer_r_0  (
    .D(\vga/ps2/timer_x [0]),
    .CLR(gray_cnt_Rst_inv1_INV_0_1_99),
    .C(gray_cnt_FFd1_9),
    .Q(\vga/ps2/timer_r [0])
  );
  FDC \vga/ps2/timer_r_1  (
    .D(\vga/ps2/timer_x [1]),
    .CLR(gray_cnt_Rst_inv1_INV_0_1_99),
    .C(gray_cnt_FFd1_9),
    .Q(\vga/ps2/timer_r [1])
  );
  FDC \vga/ps2/timer_r_2  (
    .D(\vga/ps2/timer_x [2]),
    .CLR(gray_cnt_Rst_inv1_INV_0_1_99),
    .C(gray_cnt_FFd1_9),
    .Q(\vga/ps2/timer_r [2])
  );
  FDC \vga/ps2/timer_r_3  (
    .D(\vga/ps2/timer_x [3]),
    .CLR(gray_cnt_Rst_inv1_INV_0_1_99),
    .C(gray_cnt_FFd1_9),
    .Q(\vga/ps2/timer_r [3])
  );
  FDC \vga/ps2/timer_r_4  (
    .D(\vga/ps2/timer_x [4]),
    .CLR(gray_cnt_Rst_inv1_INV_0_1_99),
    .C(gray_cnt_FFd1_9),
    .Q(\vga/ps2/timer_r [4])
  );
  FDC \vga/ps2/timer_r_5  (
    .D(\vga/ps2/timer_x [5]),
    .CLR(gray_cnt_Rst_inv1_INV_0_1_99),
    .C(gray_cnt_FFd1_9),
    .Q(\vga/ps2/timer_r [5])
  );
  FDC \vga/ps2/timer_r_6  (
    .D(\vga/ps2/timer_x [6]),
    .CLR(gray_cnt_Rst_inv1_INV_0_1_99),
    .C(gray_cnt_FFd1_9),
    .Q(\vga/ps2/timer_r [6])
  );
  FDC \vga/ps2/timer_r_7  (
    .D(\vga/ps2/timer_x [7]),
    .CLR(gray_cnt_Rst_inv1_INV_0_1_99),
    .C(gray_cnt_FFd1_9),
    .Q(\vga/ps2/timer_r [7])
  );
  FDC \vga/ps2/timer_r_8  (
    .D(\vga/ps2/timer_x [8]),
    .CLR(gray_cnt_Rst_inv1_INV_0_1_99),
    .C(gray_cnt_FFd1_9),
    .Q(\vga/ps2/timer_r [8])
  );
  FDC \vga/ps2/timer_r_9  (
    .D(\vga/ps2/timer_x [9]),
    .CLR(gray_cnt_Rst_inv1_INV_0_1_99),
    .C(gray_cnt_FFd1_9),
    .Q(\vga/ps2/timer_r [9])
  );
  FDC \vga/ps2/timer_r_10  (
    .D(\vga/ps2/timer_x [10]),
    .CLR(gray_cnt_Rst_inv1_INV_0_1_99),
    .C(gray_cnt_FFd1_9),
    .Q(\vga/ps2/timer_r [10])
  );
  FDC \vga/ps2/timer_r_11  (
    .D(\vga/ps2/timer_x [11]),
    .CLR(gray_cnt_Rst_inv1_INV_0_1_99),
    .C(gray_cnt_FFd1_9),
    .Q(\vga/ps2/timer_r [11])
  );
  FDC \vga/ps2/timer_r_12  (
    .D(\vga/ps2/timer_x [12]),
    .CLR(gray_cnt_Rst_inv1_INV_0_1_99),
    .C(gray_cnt_FFd1_9),
    .Q(\vga/ps2/timer_r [12])
  );
  FDC \vga/ps2/timer_r_13  (
    .D(\vga/ps2/timer_x [13]),
    .CLR(gray_cnt_Rst_inv1_INV_0_1_99),
    .C(gray_cnt_FFd1_9),
    .Q(\vga/ps2/timer_r [13])
  );
  FDC \vga/ps2/error_r  (
    .D(\vga/ps2/error_x ),
    .CLR(gray_cnt_Rst_inv),
    .C(gray_cnt_FFd1_9),
    .Q(\vga/ps2/error_r_47 )
  );
  FDC \vga/ps2/bitcnt_r_0  (
    .D(\vga/ps2/bitcnt_x [0]),
    .CLR(gray_cnt_Rst_inv),
    .C(gray_cnt_FFd1_9),
    .Q(\vga/ps2/bitcnt_r [0])
  );
  FDC \vga/ps2/bitcnt_r_1  (
    .D(\vga/ps2/bitcnt_x [1]),
    .CLR(gray_cnt_Rst_inv),
    .C(gray_cnt_FFd1_9),
    .Q(\vga/ps2/bitcnt_r [1])
  );
  FDC \vga/ps2/bitcnt_r_2  (
    .D(\vga/ps2/bitcnt_x [2]),
    .CLR(gray_cnt_Rst_inv),
    .C(gray_cnt_FFd1_9),
    .Q(\vga/ps2/bitcnt_r [2])
  );
  FDC \vga/ps2/bitcnt_r_3  (
    .D(\vga/ps2/bitcnt_x [3]),
    .CLR(gray_cnt_Rst_inv),
    .C(gray_cnt_FFd1_9),
    .Q(\vga/ps2/bitcnt_r [3])
  );
  MUXCY \vga/ps2/Madd__addsub0000_cy<0>  (
    .CI(N2),
    .DI(N3),
    .S(\vga/ps2/N5 ),
    .O(\vga/ps2/Madd__addsub0000_cy [0])
  );
  MUXCY \vga/ps2/Madd__addsub0000_cy<1>  (
    .CI(\vga/ps2/Madd__addsub0000_cy [0]),
    .DI(N2),
    .S(\vga/ps2/timer_r_1_rt_74 ),
    .O(\vga/ps2/Madd__addsub0000_cy [1])
  );
  XORCY \vga/ps2/Madd__addsub0000_xor<1>  (
    .CI(\vga/ps2/Madd__addsub0000_cy [0]),
    .LI(\vga/ps2/timer_r_1_rt_74 ),
    .O(\vga/ps2/_addsub0000 [1])
  );
  MUXCY \vga/ps2/Madd__addsub0000_cy<2>  (
    .CI(\vga/ps2/Madd__addsub0000_cy [1]),
    .DI(N2),
    .S(\vga/ps2/timer_r_2_rt_75 ),
    .O(\vga/ps2/Madd__addsub0000_cy [2])
  );
  XORCY \vga/ps2/Madd__addsub0000_xor<2>  (
    .CI(\vga/ps2/Madd__addsub0000_cy [1]),
    .LI(\vga/ps2/timer_r_2_rt_75 ),
    .O(\vga/ps2/_addsub0000 [2])
  );
  MUXCY \vga/ps2/Madd__addsub0000_cy<3>  (
    .CI(\vga/ps2/Madd__addsub0000_cy [2]),
    .DI(N2),
    .S(\vga/ps2/timer_r_3_rt_76 ),
    .O(\vga/ps2/Madd__addsub0000_cy [3])
  );
  XORCY \vga/ps2/Madd__addsub0000_xor<3>  (
    .CI(\vga/ps2/Madd__addsub0000_cy [2]),
    .LI(\vga/ps2/timer_r_3_rt_76 ),
    .O(\vga/ps2/_addsub0000 [3])
  );
  MUXCY \vga/ps2/Madd__addsub0000_cy<4>  (
    .CI(\vga/ps2/Madd__addsub0000_cy [3]),
    .DI(N2),
    .S(\vga/ps2/timer_r_4_rt_77 ),
    .O(\vga/ps2/Madd__addsub0000_cy [4])
  );
  XORCY \vga/ps2/Madd__addsub0000_xor<4>  (
    .CI(\vga/ps2/Madd__addsub0000_cy [3]),
    .LI(\vga/ps2/timer_r_4_rt_77 ),
    .O(\vga/ps2/_addsub0000 [4])
  );
  MUXCY \vga/ps2/Madd__addsub0000_cy<5>  (
    .CI(\vga/ps2/Madd__addsub0000_cy [4]),
    .DI(N2),
    .S(\vga/ps2/timer_r_5_rt_78 ),
    .O(\vga/ps2/Madd__addsub0000_cy [5])
  );
  XORCY \vga/ps2/Madd__addsub0000_xor<5>  (
    .CI(\vga/ps2/Madd__addsub0000_cy [4]),
    .LI(\vga/ps2/timer_r_5_rt_78 ),
    .O(\vga/ps2/_addsub0000 [5])
  );
  MUXCY \vga/ps2/Madd__addsub0000_cy<6>  (
    .CI(\vga/ps2/Madd__addsub0000_cy [5]),
    .DI(N2),
    .S(\vga/ps2/timer_r_6_rt_79 ),
    .O(\vga/ps2/Madd__addsub0000_cy [6])
  );
  XORCY \vga/ps2/Madd__addsub0000_xor<6>  (
    .CI(\vga/ps2/Madd__addsub0000_cy [5]),
    .LI(\vga/ps2/timer_r_6_rt_79 ),
    .O(\vga/ps2/_addsub0000 [6])
  );
  MUXCY \vga/ps2/Madd__addsub0000_cy<7>  (
    .CI(\vga/ps2/Madd__addsub0000_cy [6]),
    .DI(N2),
    .S(\vga/ps2/timer_r_7_rt_80 ),
    .O(\vga/ps2/Madd__addsub0000_cy [7])
  );
  XORCY \vga/ps2/Madd__addsub0000_xor<7>  (
    .CI(\vga/ps2/Madd__addsub0000_cy [6]),
    .LI(\vga/ps2/timer_r_7_rt_80 ),
    .O(\vga/ps2/_addsub0000 [7])
  );
  MUXCY \vga/ps2/Madd__addsub0000_cy<8>  (
    .CI(\vga/ps2/Madd__addsub0000_cy [7]),
    .DI(N2),
    .S(\vga/ps2/timer_r_8_rt_81 ),
    .O(\vga/ps2/Madd__addsub0000_cy [8])
  );
  XORCY \vga/ps2/Madd__addsub0000_xor<8>  (
    .CI(\vga/ps2/Madd__addsub0000_cy [7]),
    .LI(\vga/ps2/timer_r_8_rt_81 ),
    .O(\vga/ps2/_addsub0000 [8])
  );
  MUXCY \vga/ps2/Madd__addsub0000_cy<9>  (
    .CI(\vga/ps2/Madd__addsub0000_cy [8]),
    .DI(N2),
    .S(\vga/ps2/timer_r_9_rt_82 ),
    .O(\vga/ps2/Madd__addsub0000_cy [9])
  );
  XORCY \vga/ps2/Madd__addsub0000_xor<9>  (
    .CI(\vga/ps2/Madd__addsub0000_cy [8]),
    .LI(\vga/ps2/timer_r_9_rt_82 ),
    .O(\vga/ps2/_addsub0000 [9])
  );
  MUXCY \vga/ps2/Madd__addsub0000_cy<10>  (
    .CI(\vga/ps2/Madd__addsub0000_cy [9]),
    .DI(N2),
    .S(\vga/ps2/timer_r_10_rt_83 ),
    .O(\vga/ps2/Madd__addsub0000_cy [10])
  );
  XORCY \vga/ps2/Madd__addsub0000_xor<10>  (
    .CI(\vga/ps2/Madd__addsub0000_cy [9]),
    .LI(\vga/ps2/timer_r_10_rt_83 ),
    .O(\vga/ps2/_addsub0000 [10])
  );
  MUXCY \vga/ps2/Madd__addsub0000_cy<11>  (
    .CI(\vga/ps2/Madd__addsub0000_cy [10]),
    .DI(N2),
    .S(\vga/ps2/timer_r_11_rt_84 ),
    .O(\vga/ps2/Madd__addsub0000_cy [11])
  );
  XORCY \vga/ps2/Madd__addsub0000_xor<11>  (
    .CI(\vga/ps2/Madd__addsub0000_cy [10]),
    .LI(\vga/ps2/timer_r_11_rt_84 ),
    .O(\vga/ps2/_addsub0000 [11])
  );
  MUXCY \vga/ps2/Madd__addsub0000_cy<12>  (
    .CI(\vga/ps2/Madd__addsub0000_cy [11]),
    .DI(N2),
    .S(\vga/ps2/timer_r_12_rt_85 ),
    .O(\vga/ps2/Madd__addsub0000_cy [12])
  );
  XORCY \vga/ps2/Madd__addsub0000_xor<12>  (
    .CI(\vga/ps2/Madd__addsub0000_cy [11]),
    .LI(\vga/ps2/timer_r_12_rt_85 ),
    .O(\vga/ps2/_addsub0000 [12])
  );
  XORCY \vga/ps2/Madd__addsub0000_xor<13>  (
    .CI(\vga/ps2/Madd__addsub0000_cy [12]),
    .LI(\vga/ps2/timer_r_13_rt_90 ),
    .O(\vga/ps2/_addsub0000 [13])
  );
  FDCE \vga/scancode_convert/shift  (
    .D(\vga/scancode_convert/shift_set ),
    .CE(\vga/scancode_convert/_not0007_55 ),
    .CLR(gray_cnt_Rst_inv1_INV_0_1_99),
    .C(gray_cnt_FFd1_9),
    .Q(\vga/scancode_convert/shift_49 )
  );
  FDCE \vga/scancode_convert/capslock  (
    .D(\vga/scancode_convert/_not0008 ),
    .CE(\vga/scancode_convert/capslock_toggle ),
    .CLR(gray_cnt_Rst_inv1_INV_0_1_99),
    .C(gray_cnt_FFd1_9),
    .Q(\vga/scancode_convert/capslock_48 )
  );
  FDCE \vga/scancode_convert/ctrl  (
    .D(\vga/scancode_convert/ctrl_set_58 ),
    .CE(\vga/scancode_convert/_not0009 ),
    .CLR(gray_cnt_Rst_inv1_INV_0_1_99),
    .C(gray_cnt_FFd1_9),
    .Q(\vga/scancode_convert/ctrl_57 )
  );
  FDCE \vga/scancode_convert/release_prefix  (
    .D(\vga/scancode_convert/release_prefix_set ),
    .CE(\vga/scancode_convert/_not0010 ),
    .CLR(gray_cnt_Rst_inv1_INV_0_1_99),
    .C(gray_cnt_FFd1_9),
    .Q(\vga/scancode_convert/release_prefix_59 )
  );
  FDE \vga/scancode_convert/sc_0  (
    .D(\vga/ps2/sc_r [0]),
    .CE(\vga/scancode_convert/_and0000 ),
    .C(gray_cnt_FFd1_9),
    .Q(\vga/scancode_convert/sc [0])
  );
  FDE \vga/scancode_convert/sc_1  (
    .D(\vga/ps2/sc_r [1]),
    .CE(\vga/scancode_convert/_and0000 ),
    .C(gray_cnt_FFd1_9),
    .Q(\vga/scancode_convert/sc [1])
  );
  FDE \vga/scancode_convert/sc_2  (
    .D(\vga/ps2/sc_r [2]),
    .CE(\vga/scancode_convert/_and0000 ),
    .C(gray_cnt_FFd1_9),
    .Q(\vga/scancode_convert/sc [2])
  );
  FDE \vga/scancode_convert/sc_3  (
    .D(\vga/ps2/sc_r [3]),
    .CE(\vga/scancode_convert/_and0000 ),
    .C(gray_cnt_FFd1_9),
    .Q(\vga/scancode_convert/sc [3])
  );
  FDE \vga/scancode_convert/sc_4  (
    .D(\vga/ps2/sc_r [4]),
    .CE(\vga/scancode_convert/_and0000 ),
    .C(gray_cnt_FFd1_9),
    .Q(\vga/scancode_convert/sc [4])
  );
  FDE \vga/scancode_convert/sc_5  (
    .D(\vga/ps2/sc_r [5]),
    .CE(\vga/scancode_convert/_and0000 ),
    .C(gray_cnt_FFd1_9),
    .Q(\vga/scancode_convert/sc [5])
  );
  FDE \vga/scancode_convert/sc_6  (
    .D(\vga/ps2/sc_r [6]),
    .CE(\vga/scancode_convert/_and0000 ),
    .C(gray_cnt_FFd1_9),
    .Q(\vga/scancode_convert/sc [6])
  );
  FDE \vga/scancode_convert/ascii_0  (
    .D(\vga/scancode_convert/rom_data [0]),
    .CE(\vga/scancode_convert/_or0000 ),
    .C(gray_cnt_FFd1_9),
    .Q(\vga/scancode_convert/ascii [0])
  );
  FDE \vga/scancode_convert/ascii_1  (
    .D(\vga/scancode_convert/rom_data [1]),
    .CE(\vga/scancode_convert/_or0000 ),
    .C(gray_cnt_FFd1_9),
    .Q(\vga/scancode_convert/ascii [1])
  );
  FDE \vga/scancode_convert/ascii_2  (
    .D(\vga/scancode_convert/rom_data [2]),
    .CE(\vga/scancode_convert/_or0000 ),
    .C(gray_cnt_FFd1_9),
    .Q(\vga/scancode_convert/ascii [2])
  );
  FDE \vga/scancode_convert/ascii_3  (
    .D(\vga/scancode_convert/rom_data [3]),
    .CE(\vga/scancode_convert/_or0000 ),
    .C(gray_cnt_FFd1_9),
    .Q(\vga/scancode_convert/ascii [3])
  );
  FDE \vga/scancode_convert/ascii_4  (
    .D(\vga/scancode_convert/rom_data [4]),
    .CE(\vga/scancode_convert/_or0000 ),
    .C(gray_cnt_FFd1_9),
    .Q(\vga/scancode_convert/ascii [4])
  );
  FDE \vga/scancode_convert/ascii_5  (
    .D(\vga/scancode_convert/rom_data [5]),
    .CE(\vga/scancode_convert/_or0000 ),
    .C(gray_cnt_FFd1_9),
    .Q(\vga/scancode_convert/ascii [5])
  );
  FDE \vga/scancode_convert/ascii_6  (
    .D(\vga/scancode_convert/_mux0008 [6]),
    .CE(\vga/scancode_convert/_or0000 ),
    .C(gray_cnt_FFd1_9),
    .Q(\vga/scancode_convert/ascii [6])
  );
  FDCE \vga/scancode_convert/strobe_out  (
    .D(\vga/scancode_convert/state_FFd2_52 ),
    .CE(\vga/scancode_convert/_not0011 ),
    .CLR(gray_cnt_Rst_inv1_INV_0_1_99),
    .C(gray_cnt_FFd1_9),
    .Q(\vga/scancode_convert/strobe_out_14 )
  );
  FDCE \vga/scancode_convert/key_up  (
    .D(\vga/scancode_convert/state_FFd3_56 ),
    .CE(\vga/scancode_convert/_not0012 ),
    .CLR(gray_cnt_Rst_inv1_INV_0_1_99),
    .C(gray_cnt_FFd1_9),
    .Q(\vga/scancode_convert/key_up_16 )
  );
  FDC \vga/scancode_convert/hold_count_0  (
    .D(\vga/scancode_convert/hold_count__mux0000 [0]),
    .CLR(gray_cnt_Rst_inv1_INV_0_1_99),
    .C(gray_cnt_FFd1_9),
    .Q(\vga/scancode_convert/hold_count [0])
  );
  FDC \vga/scancode_convert/hold_count_1  (
    .D(\vga/scancode_convert/hold_count__mux0000 [1]),
    .CLR(gray_cnt_Rst_inv1_INV_0_1_99),
    .C(gray_cnt_FFd1_9),
    .Q(\vga/scancode_convert/hold_count [1])
  );
  FDC \vga/scancode_convert/hold_count_2  (
    .D(\vga/scancode_convert/hold_count__mux0000 [2]),
    .CLR(gray_cnt_Rst_inv1_INV_0_1_99),
    .C(gray_cnt_FFd1_9),
    .Q(\vga/scancode_convert/hold_count [2])
  );
  FDC \vga/scancode_convert/state_FFd3  (
    .D(\vga/scancode_convert/state_FFd3-In_62 ),
    .CLR(gray_cnt_Rst_inv1_INV_0_1_99),
    .C(gray_cnt_FFd1_9),
    .Q(\vga/scancode_convert/state_FFd3_56 )
  );
  FDC \vga/scancode_convert/state_FFd1  (
    .D(\vga/scancode_convert/state_FFd1-In ),
    .CLR(gray_cnt_Rst_inv1_INV_0_1_99),
    .C(gray_cnt_FFd1_9),
    .Q(\vga/scancode_convert/state_FFd1_53 )
  );
  FDC \vga/scancode_convert/state_FFd2  (
    .D(\vga/scancode_convert/state_FFd2-In_61 ),
    .CLR(gray_cnt_Rst_inv1_INV_0_1_99),
    .C(gray_cnt_FFd1_9),
    .Q(\vga/scancode_convert/state_FFd2_52 )
  );
  FDP \vga/scancode_convert/state_FFd6  (
    .D(N2),
    .PRE(gray_cnt_Rst_inv1_INV_0_1_99),
    .C(gray_cnt_FFd1_9),
    .Q(\vga/scancode_convert/state_FFd6_60 )
  );
  FDC \vga/scancode_convert/state_FFd4  (
    .D(\vga/scancode_convert/state_FFd4-In ),
    .CLR(gray_cnt_Rst_inv1_INV_0_1_99),
    .C(gray_cnt_FFd1_9),
    .Q(\vga/scancode_convert/state_FFd4_50 )
  );
  FDC \vga/scancode_convert/state_FFd5  (
    .D(\vga/scancode_convert/state_FFd5-In_63 ),
    .CLR(gray_cnt_Rst_inv1_INV_0_1_99),
    .C(gray_cnt_FFd1_9),
    .Q(\vga/scancode_convert/state_FFd5_54 )
  );
  defparam \vga/insert_crt_data1 .INIT = 4'h4;
  LUT2 \vga/insert_crt_data1  (
    .I0(\vga/scancode_convert/key_up_16 ),
    .I1(\vga/scancode_convert/strobe_out_14 ),
    .O(\vga/insert_crt_data )
  );
  defparam \vga/rom_addr_char<2>4 .INIT = 8'h08;
  LUT3 \vga/rom_addr_char<2>4  (
    .I0(\vga/rom_addr_char [2]),
    .I1(\vga/N14 ),
    .I2(\vga/rom_addr_char_1_1_95 ),
    .O(\vga/rom_addr_char<2>11_27 )
  );
  defparam \vga/ram_addr_mux<11>1 .INIT = 8'hE4;
  LUT3 \vga/ram_addr_mux<11>1  (
    .I0(\vga/ram_we_n ),
    .I1(\vga/ram_addr_write [11]),
    .I2(\vga/ram_addr_video [11]),
    .O(\vga/ram_addr_mux [11])
  );
  defparam \vga/ram_addr_mux<10>1 .INIT = 8'hE4;
  LUT3 \vga/ram_addr_mux<10>1  (
    .I0(\vga/ram_we_n ),
    .I1(\vga/ram_addr_write [10]),
    .I2(\vga/ram_addr_video [10]),
    .O(\vga/ram_addr_mux [10])
  );
  defparam \vga/ram_addr_mux<9>1 .INIT = 8'hE4;
  LUT3 \vga/ram_addr_mux<9>1  (
    .I0(\vga/ram_we_n ),
    .I1(\vga/ram_addr_write [9]),
    .I2(\vga/ram_addr_video [9]),
    .O(\vga/ram_addr_mux [9])
  );
  defparam \vga/ram_addr_mux<8>1 .INIT = 8'hE4;
  LUT3 \vga/ram_addr_mux<8>1  (
    .I0(\vga/ram_we_n ),
    .I1(\vga/ram_addr_write [8]),
    .I2(\vga/ram_addr_video [8]),
    .O(\vga/ram_addr_mux [8])
  );
  defparam \vga/ram_addr_mux<7>1 .INIT = 8'hE4;
  LUT3 \vga/ram_addr_mux<7>1  (
    .I0(\vga/ram_we_n ),
    .I1(\vga/ram_addr_write [7]),
    .I2(\vga/ram_addr_video [7]),
    .O(\vga/ram_addr_mux [7])
  );
  defparam \vga/ram_addr_mux<6>1 .INIT = 8'hE4;
  LUT3 \vga/ram_addr_mux<6>1  (
    .I0(\vga/ram_we_n ),
    .I1(\vga/ram_addr_write [6]),
    .I2(\vga/ram_addr_video [6]),
    .O(\vga/ram_addr_mux [6])
  );
  defparam \vga/ram_addr_mux<5>1 .INIT = 8'hE4;
  LUT3 \vga/ram_addr_mux<5>1  (
    .I0(\vga/ram_we_n ),
    .I1(\vga/ram_addr_write [5]),
    .I2(\vga/ram_addr_video [5]),
    .O(\vga/ram_addr_mux [5])
  );
  defparam \vga/ram_addr_mux<2>1 .INIT = 8'hE4;
  LUT3 \vga/ram_addr_mux<2>1  (
    .I0(\vga/ram_we_n ),
    .I1(\vga/crt/cursor_h [2]),
    .I2(\vga/vgacore/hcnt [5]),
    .O(\vga/ram_addr_mux [2])
  );
  defparam \vga/ram_addr_mux<3>1 .INIT = 8'hE4;
  LUT3 \vga/ram_addr_mux<3>1  (
    .I0(\vga/ram_we_n ),
    .I1(\vga/crt/cursor_h [3]),
    .I2(\vga/vgacore/hcnt [6]),
    .O(\vga/ram_addr_mux [3])
  );
  defparam \vga/ram_addr_mux<1>1 .INIT = 8'hE4;
  LUT3 \vga/ram_addr_mux<1>1  (
    .I0(\vga/ram_we_n ),
    .I1(\vga/crt/cursor_h [1]),
    .I2(\vga/vgacore/hcnt [4]),
    .O(\vga/ram_addr_mux [1])
  );
  defparam \vga/ram_addr_mux<0>1 .INIT = 8'hE4;
  LUT3 \vga/ram_addr_mux<0>1  (
    .I0(\vga/ram_we_n ),
    .I1(\vga/crt/cursor_h [0]),
    .I2(\vga/vgacore/hcnt [3]),
    .O(\vga/ram_addr_mux [0])
  );
  defparam \vga/rom_addr_char<4>1 .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<4>1  (
    .I0(\vga/rom_addr_char [4]),
    .I1(\vga/rom_addr_char<3>_f62_24 ),
    .I2(\vga/rom_addr_char<3>_f63_25 ),
    .O(\vga/rom_addr_char<4>11_26 )
  );
  defparam \vga/Madd_ram_addr_videoC21 .INIT = 8'hE8;
  LUT3 \vga/Madd_ram_addr_videoC21  (
    .I0(\vga/vgacore/vcnt [3]),
    .I1(\vga/vgacore/vcnt [5]),
    .I2(\vga/vgacore/hcnt [9]),
    .O(\vga/Madd_ram_addr_videoC2 )
  );
  defparam \vga/crt/Madd_ram_addrC21 .INIT = 8'hE8;
  LUT3 \vga/crt/Madd_ram_addrC21  (
    .I0(\vga/crt/cursor_v [0]),
    .I1(\vga/crt/cursor_v [2]),
    .I2(\vga/crt/cursor_h [6]),
    .O(\vga/crt/Madd_ram_addrC2 )
  );
  defparam \vga/crt/ram_we_n1 .INIT = 8'hF9;
  LUT3 \vga/crt/ram_we_n1  (
    .I0(\vga/crt/state_FFd3_42 ),
    .I1(\vga/crt/state_FFd1_40 ),
    .I2(\vga/crt/state_FFd2_41 ),
    .O(\vga/ram_we_n )
  );
  defparam \vga/Madd_ram_addr_videoR21 .INIT = 8'h96;
  LUT3 \vga/Madd_ram_addr_videoR21  (
    .I0(\vga/vgacore/hcnt [9]),
    .I1(\vga/vgacore/vcnt [3]),
    .I2(\vga/vgacore/vcnt [5]),
    .O(\vga/Madd_ram_addr_videoR2 )
  );
  defparam \vga/crt/Madd_ram_addrR21 .INIT = 8'h96;
  LUT3 \vga/crt/Madd_ram_addrR21  (
    .I0(\vga/crt/cursor_h [6]),
    .I1(\vga/crt/cursor_v [0]),
    .I2(\vga/crt/cursor_v [2]),
    .O(\vga/crt/Madd_ram_addrR2 )
  );
  defparam \vga/crt/_cmp_eq000111 .INIT = 16'h0002;
  LUT4 \vga/crt/_cmp_eq000111  (
    .I0(\vga/crt_data [3]),
    .I1(\vga/crt_data [6]),
    .I2(\vga/crt_data [5]),
    .I3(\vga/crt_data [4]),
    .O(\vga/crt/N16 )
  );
  defparam \vga/crt/_cmp_eq00011 .INIT = 16'h0020;
  LUT4 \vga/crt/_cmp_eq00011  (
    .I0(\vga/crt_data [1]),
    .I1(\vga/crt_data [0]),
    .I2(\vga/crt/N16 ),
    .I3(\vga/crt_data [2]),
    .O(\vga/crt/_cmp_eq0001 )
  );
  defparam \vga/vgacore/_or000011 .INIT = 16'h8000;
  LUT4 \vga/vgacore/_or000011  (
    .I0(\vga/vgacore/vcnt [7]),
    .I1(\vga/vgacore/vcnt [8]),
    .I2(\vga/vgacore/vcnt [6]),
    .I3(\vga/vgacore/vcnt [5]),
    .O(\vga/vgacore/N61 )
  );
  defparam \vga/rom_addr_char<4>71 .INIT = 16'h5410;
  LUT4 \vga/rom_addr_char<4>71  (
    .I0(\vga/rom_addr_char [4]),
    .I1(\vga/rom_addr_char [3]),
    .I2(\vga/N011234567 ),
    .I3(\vga/N1112 ),
    .O(\vga/rom_addr_char<4>11234 )
  );
  defparam \vga/vgacore/_and0001_SW0 .INIT = 8'hF7;
  LUT3 \vga/vgacore/_and0001_SW0  (
    .I0(\vga/vgacore/vcnt_1_1_97 ),
    .I1(\vga/vgacore/N61 ),
    .I2(\vga/vgacore/vcnt [9]),
    .O(N44)
  );
  defparam \vga/vgacore/_and0001 .INIT = 16'h0002;
  LUT4 \vga/vgacore/_and0001  (
    .I0(\vga/vgacore/vcnt [3]),
    .I1(\vga/vgacore/vcnt [4]),
    .I2(\vga/vgacore/vcnt_2_1_98 ),
    .I3(N44),
    .O(\vga/vgacore/_and0001_44 )
  );
  defparam \vga/pixel<8>27 .INIT = 8'h08;
  LUT3 \vga/pixel<8>27  (
    .I0(\vga/pixel<8>_map785 ),
    .I1(\vga/pixelData [0]),
    .I2(\vga/vgacore/hblank_12 ),
    .O(pixel[8])
  );
  defparam \vga/scancode_convert/hold_count__mux0000<0>1 .INIT = 4'h4;
  LUT2 \vga/scancode_convert/hold_count__mux0000<0>1  (
    .I0(\vga/scancode_convert/hold_count [0]),
    .I1(\vga/scancode_convert/state_FFd1_53 ),
    .O(\vga/scancode_convert/hold_count__mux0000 [0])
  );
  defparam \vga/scancode_convert/hold_count__mux0000<1>1 .INIT = 8'h28;
  LUT3 \vga/scancode_convert/hold_count__mux0000<1>1  (
    .I0(\vga/scancode_convert/state_FFd1_53 ),
    .I1(\vga/scancode_convert/hold_count [0]),
    .I2(\vga/scancode_convert/hold_count [1]),
    .O(\vga/scancode_convert/hold_count__mux0000 [1])
  );
  defparam \vga/vgacore/_mux00021 .INIT = 16'hFCF8;
  LUT4 \vga/vgacore/_mux00021  (
    .I0(\vga/vgacore/hcnt [7]),
    .I1(\vga/vgacore/hcnt [9]),
    .I2(\vga/vgacore/hcnt [10]),
    .I3(\vga/vgacore/hcnt [8]),
    .O(\vga/vgacore/_mux0002 )
  );
  defparam \vga/_mux00001 .INIT = 16'h04AE;
  LUT4 \vga/_mux00001  (
    .I0(\vga/clearing ),
    .I1(\vga/pclk [2]),
    .I2(\vga/pclk [1]),
    .I3(\vga/crtclk1 ),
    .O(\vga/_mux0000 )
  );
  defparam \vga/pclk__mux0000<1>1 .INIT = 16'hFFF6;
  LUT4 \vga/pclk__mux0000<1>1  (
    .I0(\vga/pclk [0]),
    .I1(\vga/pclk [1]),
    .I2(\vga/vgacore/hblank_12 ),
    .I3(\vga/clearing ),
    .O(\vga/pclk__mux0000 [1])
  );
  defparam \vga/scancode_convert/hold_count__mux0000<2>1 .INIT = 16'h4888;
  LUT4 \vga/scancode_convert/hold_count__mux0000<2>1  (
    .I0(\vga/scancode_convert/hold_count [2]),
    .I1(\vga/scancode_convert/state_FFd1_53 ),
    .I2(\vga/scancode_convert/hold_count [0]),
    .I3(\vga/scancode_convert/hold_count [1]),
    .O(\vga/scancode_convert/hold_count__mux0000 [2])
  );
  defparam \vga/scancode_convert/_or00001 .INIT = 4'hE;
  LUT2 \vga/scancode_convert/_or00001  (
    .I0(\vga/scancode_convert/state_FFd2_52 ),
    .I1(\vga/scancode_convert/state_FFd3_56 ),
    .O(\vga/scancode_convert/_or0000 )
  );
  defparam \vga/crt/_not00081 .INIT = 16'h4404;
  LUT4 \vga/crt/_not00081  (
    .I0(\vga/crt/state_FFd1_40 ),
    .I1(\vga/crt/state_FFd2_41 ),
    .I2(\vga/crt/state_FFd3_42 ),
    .I3(\vga/insert_crt_data ),
    .O(\vga/crt/_not0008 )
  );
  defparam \vga/pclk__mux0000<2> .INIT = 16'hFF6A;
  LUT4 \vga/pclk__mux0000<2>  (
    .I0(\vga/pclk [2]),
    .I1(\vga/pclk [1]),
    .I2(\vga/pclk [0]),
    .I3(N89),
    .O(\vga/pclk__mux0000 [2])
  );
  defparam \vga/scancode_convert/state_FFd1-In1 .INIT = 8'hAE;
  LUT3 \vga/scancode_convert/state_FFd1-In1  (
    .I0(\vga/scancode_convert/state_FFd4_50 ),
    .I1(\vga/scancode_convert/state_FFd1_53 ),
    .I2(\vga/scancode_convert/_cmp_eq0005 ),
    .O(\vga/scancode_convert/state_FFd1-In )
  );
  defparam \vga/crt/write_delay__mux0000<1>1 .INIT = 8'h28;
  LUT3 \vga/crt/write_delay__mux0000<1>1  (
    .I0(\vga/crt/_cmp_eq0004 ),
    .I1(\vga/crt/write_delay [0]),
    .I2(\vga/crt/write_delay [1]),
    .O(\vga/crt/write_delay__mux0000 [1])
  );
  defparam \vga/crt/_mux0002<6>1 .INIT = 16'h7D28;
  LUT4 \vga/crt/_mux0002<6>1  (
    .I0(\vga/crt/N91 ),
    .I1(\vga/crt/cursor_h [5]),
    .I2(\vga/crt/cursor_h [6]),
    .I3(\vga/crt_data [6]),
    .O(\vga/crt/_mux0002 [6])
  );
  defparam \vga/crt/write_delay__mux0000<2>1 .INIT = 16'h4888;
  LUT4 \vga/crt/write_delay__mux0000<2>1  (
    .I0(\vga/crt/write_delay [2]),
    .I1(\vga/crt/_cmp_eq0004 ),
    .I2(\vga/crt/write_delay [0]),
    .I3(\vga/crt/write_delay [1]),
    .O(\vga/crt/write_delay__mux0000 [2])
  );
  defparam \vga/ps2/ps2_clk_edge2 .INIT = 16'h0240;
  LUT4 \vga/ps2/ps2_clk_edge2  (
    .I0(\vga/ps2/ps2_clk_r [3]),
    .I1(\vga/ps2/ps2_clk_r [1]),
    .I2(\vga/ps2/ps2_clk_r [2]),
    .I3(\vga/ps2/ps2_clk_r [4]),
    .O(\vga/ps2/ps2_clk_edge )
  );
  defparam \vga/scancode_convert/_not00111 .INIT = 16'hFFEA;
  LUT4 \vga/scancode_convert/_not00111  (
    .I0(\vga/scancode_convert/state_FFd3_56 ),
    .I1(\vga/scancode_convert/state_FFd1_53 ),
    .I2(\vga/scancode_convert/_cmp_eq0005 ),
    .I3(\vga/scancode_convert/state_FFd2_52 ),
    .O(\vga/scancode_convert/_not0011 )
  );
  defparam \vga/crt/state_Out911 .INIT = 4'h7;
  LUT2 \vga/crt/state_Out911  (
    .I0(\vga/crt/state_FFd2_41 ),
    .I1(\vga/crt/state_FFd3_42 ),
    .O(\vga/crt/N91 )
  );
  defparam \vga/ps2/_cmp_eq00001 .INIT = 16'h2000;
  LUT4 \vga/ps2/_cmp_eq00001  (
    .I0(\vga/ps2/bitcnt_r [0]),
    .I1(\vga/ps2/bitcnt_r [2]),
    .I2(\vga/ps2/bitcnt_r [3]),
    .I3(\vga/ps2/bitcnt_r [1]),
    .O(\vga/ps2/_cmp_eq0000 )
  );
  defparam \vga/crt/state_FFd1-In_SW0 .INIT = 16'h9810;
  LUT4 \vga/crt/state_FFd1-In_SW0  (
    .I0(\vga/crt/state_FFd3_42 ),
    .I1(\vga/crt/state_FFd2_41 ),
    .I2(\vga/crt/state_FFd1_40 ),
    .I3(\vga/insert_crt_data ),
    .O(N116)
  );
  defparam \vga/crt/state_FFd1-In_SW1 .INIT = 16'hBB80;
  LUT4 \vga/crt/state_FFd1-In_SW1  (
    .I0(\vga/crt/state_FFd3_42 ),
    .I1(\vga/crt/state_FFd2_41 ),
    .I2(\vga/insert_crt_data ),
    .I3(\vga/crt/state_FFd1_40 ),
    .O(N117)
  );
  defparam \vga/crt/state_FFd1-In .INIT = 16'hFE02;
  LUT4 \vga/crt/state_FFd1-In  (
    .I0(N116),
    .I1(\vga/crt/newline_37 ),
    .I2(\vga/crt/_cmp_eq0001 ),
    .I3(N117),
    .O(\vga/crt/state_FFd1-In_43 )
  );
  defparam \vga/scancode_convert/_not00091 .INIT = 16'h2000;
  LUT4 \vga/scancode_convert/_not00091  (
    .I0(\vga/scancode_convert/_and0000 ),
    .I1(\vga/ps2/sc_r [1]),
    .I2(\vga/scancode_convert/N10 ),
    .I3(\vga/ps2/sc_r [2]),
    .O(\vga/scancode_convert/_not0009 )
  );
  defparam \vga/crt/_not00071 .INIT = 16'h88A8;
  LUT4 \vga/crt/_not00071  (
    .I0(\vga/crt/state_FFd2_41 ),
    .I1(\vga/crt/state_FFd1_40 ),
    .I2(\vga/crt/eol_35 ),
    .I3(\vga/crt/state_FFd3_42 ),
    .O(\vga/crt/_not0007 )
  );
  defparam \vga/crt/_not00061 .INIT = 16'hAFA8;
  LUT4 \vga/crt/_not00061  (
    .I0(\vga/crt/state_FFd1_40 ),
    .I1(\vga/crt/eol_35 ),
    .I2(\vga/crt/state_FFd3_42 ),
    .I3(\vga/crt/state_FFd2_41 ),
    .O(\vga/crt/_not0006 )
  );
  defparam \vga/vgacore/vcnt_Eqn_81 .INIT = 4'h4;
  LUT2 \vga/vgacore/vcnt_Eqn_81  (
    .I0(\vga/vgacore/vcnt [9]),
    .I1(\vga/vgacore/vcnt [8]),
    .O(\vga/vgacore/vcnt_Eqn_8 )
  );
  defparam \vga/scancode_convert/state_FFd5-In_SW0 .INIT = 8'hEA;
  LUT3 \vga/scancode_convert/state_FFd5-In_SW0  (
    .I0(\vga/scancode_convert/state_FFd6_60 ),
    .I1(\vga/scancode_convert/_cmp_eq0005 ),
    .I2(\vga/scancode_convert/state_FFd1_53 ),
    .O(N124)
  );
  defparam \vga/scancode_convert/state_FFd5-In .INIT = 16'hFF8C;
  LUT4 \vga/scancode_convert/state_FFd5-In  (
    .I0(\vga/scancode_convert/_cmp_eq0000_51 ),
    .I1(\vga/scancode_convert/state_FFd5_54 ),
    .I2(\vga/ps2/rdy_r_8 ),
    .I3(N124),
    .O(\vga/scancode_convert/state_FFd5-In_63 )
  );
  defparam \vga/scancode_convert/state_FFd2-In .INIT = 16'h0002;
  LUT4 \vga/scancode_convert/state_FFd2-In  (
    .I0(\vga/scancode_convert/_and0000 ),
    .I1(\vga/scancode_convert/N11 ),
    .I2(\vga/scancode_convert/_cmp_eq0000_51 ),
    .I3(N126),
    .O(\vga/scancode_convert/state_FFd2-In_61 )
  );
  defparam \vga/scancode_convert/state_FFd3-In .INIT = 16'h0020;
  LUT4 \vga/scancode_convert/state_FFd3-In  (
    .I0(N128),
    .I1(\vga/scancode_convert/N11 ),
    .I2(\vga/scancode_convert/_and0000 ),
    .I3(\vga/scancode_convert/_cmp_eq0000_51 ),
    .O(\vga/scancode_convert/state_FFd3-In_62 )
  );
  defparam \vga/crt/state_FFd3-In37 .INIT = 16'h55D5;
  LUT4 \vga/crt/state_FFd3-In37  (
    .I0(\vga/crt/state_FFd1_40 ),
    .I1(\vga/crt/write_delay [0]),
    .I2(\vga/crt/write_delay [1]),
    .I3(\vga/crt/write_delay [2]),
    .O(\vga/crt/state_FFd3-In_map800 )
  );
  defparam \vga/vgacore/_and00005 .INIT = 16'h8000;
  LUT4 \vga/vgacore/_and00005  (
    .I0(\vga/vgacore/hcnt [2]),
    .I1(\vga/vgacore/hcnt [1]),
    .I2(\vga/vgacore/hcnt [4]),
    .I3(\vga/vgacore/hcnt [3]),
    .O(\vga/vgacore/_and0000_map807 )
  );
  defparam \vga/vgacore/_and000033 .INIT = 16'h0002;
  LUT4 \vga/vgacore/_and000033  (
    .I0(\vga/vgacore/hcnt [8]),
    .I1(\vga/vgacore/hcnt [7]),
    .I2(\vga/vgacore/hcnt [6]),
    .I3(\vga/vgacore/hcnt [5]),
    .O(\vga/vgacore/_and0000_map817 )
  );
  defparam \vga/vgacore/_and000046 .INIT = 16'h0001;
  LUT4 \vga/vgacore/_and000046  (
    .I0(\vga/vgacore/hcnt [4]),
    .I1(\vga/vgacore/hcnt [3]),
    .I2(\vga/vgacore/hcnt [2]),
    .I3(\vga/vgacore/hcnt [1]),
    .O(\vga/vgacore/_and0000_map824 )
  );
  defparam \vga/vgacore/_and000047 .INIT = 4'h8;
  LUT2 \vga/vgacore/_and000047  (
    .I0(\vga/vgacore/_and0000_map817 ),
    .I1(\vga/vgacore/_and0000_map824 ),
    .O(\vga/vgacore/_and0000_map825 )
  );
  defparam \vga/vgacore/vcnt_Eqn_71 .INIT = 4'h4;
  LUT2 \vga/vgacore/vcnt_Eqn_71  (
    .I0(\vga/vgacore/vcnt [9]),
    .I1(\vga/vgacore/vcnt [7]),
    .O(\vga/vgacore/vcnt_Eqn_7 )
  );
  defparam \vga/vgacore/vcnt_Eqn_92 .INIT = 8'h80;
  LUT3 \vga/vgacore/vcnt_Eqn_92  (
    .I0(\vga/vgacore/N51 ),
    .I1(\vga/vgacore/vcnt [9]),
    .I2(\vga/vgacore/N0 ),
    .O(\vga/vgacore/vcnt_Eqn_9 )
  );
  defparam \vga/vgacore/vcnt_Eqn_61 .INIT = 4'h4;
  LUT2 \vga/vgacore/vcnt_Eqn_61  (
    .I0(\vga/vgacore/vcnt [9]),
    .I1(\vga/vgacore/vcnt [6]),
    .O(\vga/vgacore/vcnt_Eqn_6 )
  );
  defparam \vga/vgacore/vcnt_Eqn_51 .INIT = 4'h4;
  LUT2 \vga/vgacore/vcnt_Eqn_51  (
    .I0(\vga/vgacore/vcnt [9]),
    .I1(\vga/vgacore/vcnt [5]),
    .O(\vga/vgacore/vcnt_Eqn_5 )
  );
  defparam \vga/scancode_convert/state_FFd2-In111 .INIT = 4'h8;
  LUT2 \vga/scancode_convert/state_FFd2-In111  (
    .I0(\vga/ps2/rdy_r_8 ),
    .I1(\vga/scancode_convert/state_FFd5_54 ),
    .O(\vga/scancode_convert/_and0000 )
  );
  defparam \vga/crt/state_Out41 .INIT = 8'h04;
  LUT3 \vga/crt/state_Out41  (
    .I0(\vga/crt/state_FFd3_42 ),
    .I1(\vga/crt/state_FFd1_40 ),
    .I2(\vga/crt/state_FFd2_41 ),
    .O(\vga/crt/_cmp_eq0004 )
  );
  defparam \vga/scancode_convert/_cmp_eq00051 .INIT = 8'h04;
  LUT3 \vga/scancode_convert/_cmp_eq00051  (
    .I0(\vga/scancode_convert/hold_count [0]),
    .I1(\vga/scancode_convert/hold_count [2]),
    .I2(\vga/scancode_convert/hold_count [1]),
    .O(\vga/scancode_convert/_cmp_eq0005 )
  );
  defparam \vga/scancode_convert/capslock_toggle1 .INIT = 16'h2000;
  LUT4 \vga/scancode_convert/capslock_toggle1  (
    .I0(\vga/scancode_convert/_and0000 ),
    .I1(\vga/ps2/sc_r [0]),
    .I2(\vga/scancode_convert/release_prefix_59 ),
    .I3(\vga/scancode_convert/N11 ),
    .O(\vga/scancode_convert/capslock_toggle )
  );
  defparam \vga/vgacore/vcnt_Eqn_41 .INIT = 4'h4;
  LUT2 \vga/vgacore/vcnt_Eqn_41  (
    .I0(\vga/vgacore/vcnt [9]),
    .I1(\vga/vgacore/vcnt [4]),
    .O(\vga/vgacore/vcnt_Eqn_4 )
  );
  defparam \vga/crt/_and0001_SW0 .INIT = 4'hD;
  LUT2 \vga/crt/_and0001_SW0  (
    .I0(\vga/crt/state_FFd2_41 ),
    .I1(\vga/crt/state_FFd1_40 ),
    .O(N235)
  );
  defparam \vga/scancode_convert/_cmp_eq00041 .INIT = 16'h0001;
  LUT4 \vga/scancode_convert/_cmp_eq00041  (
    .I0(\vga/ps2/sc_r [7]),
    .I1(\vga/ps2/sc_r [6]),
    .I2(\vga/ps2/sc_r [5]),
    .I3(N237),
    .O(\vga/scancode_convert/N10 )
  );
  defparam \vga/scancode_convert/shift_set17 .INIT = 16'hC888;
  LUT4 \vga/scancode_convert/shift_set17  (
    .I0(\vga/scancode_convert/shift_set_map833 ),
    .I1(\vga/scancode_convert/shift_set_map836 ),
    .I2(\vga/scancode_convert/N11 ),
    .I3(\vga/ps2/sc_r [0]),
    .O(\vga/scancode_convert/shift_set )
  );
  defparam \vga/ps2/ps2_clk_edge11 .INIT = 16'h0020;
  LUT4 \vga/ps2/ps2_clk_edge11  (
    .I0(\vga/ps2/ps2_clk_r [4]),
    .I1(\vga/ps2/ps2_clk_r [1]),
    .I2(\vga/ps2/ps2_clk_r [3]),
    .I3(\vga/ps2/ps2_clk_r [2]),
    .O(\vga/ps2/ps2_clk_fall_edge )
  );
  defparam \vga/scancode_convert/_cmp_eq000221 .INIT = 16'h0020;
  LUT4 \vga/scancode_convert/_cmp_eq000221  (
    .I0(N3268),
    .I1(\vga/ps2/sc_r [5]),
    .I2(\vga/ps2/sc_r [3]),
    .I3(\vga/ps2/sc_r [7]),
    .O(\vga/scancode_convert/N11 )
  );
  defparam \vga/scancode_convert/_not0007 .INIT = 16'hC888;
  LUT4 \vga/scancode_convert/_not0007  (
    .I0(N3267),
    .I1(\vga/scancode_convert/_and0000 ),
    .I2(\vga/ps2/sc_r [0]),
    .I3(\vga/scancode_convert/N11 ),
    .O(\vga/scancode_convert/_not0007_55 )
  );
  defparam \vga/crt/eol .INIT = 16'h0020;
  LUT4 \vga/crt/eol  (
    .I0(\vga/crt/cursor_h [6]),
    .I1(\vga/crt/cursor_h [5]),
    .I2(\vga/crt/cursor_h [0]),
    .I3(N293),
    .O(\vga/crt/eol_35 )
  );
  defparam \vga/crt/cursor_v_Eqn_11 .INIT = 4'h4;
  LUT2 \vga/crt/cursor_v_Eqn_11  (
    .I0(N3266),
    .I1(\vga/crt/Result [1]),
    .O(\vga/crt/cursor_v_Eqn_1 )
  );
  defparam \vga/ps2/timer_x<1>1 .INIT = 4'h4;
  LUT2 \vga/ps2/timer_x<1>1  (
    .I0(\vga/ps2/ps2_clk_edge ),
    .I1(\vga/ps2/_addsub0000 [1]),
    .O(\vga/ps2/timer_x [1])
  );
  defparam \vga/crt/cursor_h_Eqn_11 .INIT = 4'h4;
  LUT2 \vga/crt/cursor_h_Eqn_11  (
    .I0(\vga/crt/_and0000_38 ),
    .I1(\vga/crt/Result<1>1 ),
    .O(\vga/crt/cursor_h_Eqn_1 )
  );
  defparam \vga/crt/scroll .INIT = 16'h2000;
  LUT4 \vga/crt/scroll  (
    .I0(\vga/crt/cursor_v [5]),
    .I1(N301),
    .I2(\vga/crt/cursor_v [4]),
    .I3(\vga/crt/cursor_v [0]),
    .O(\vga/crt/scroll_36 )
  );
  defparam \vga/crt/_and0000_SW1 .INIT = 16'hFF7F;
  LUT4 \vga/crt/_and0000_SW1  (
    .I0(\vga/crt/state_FFd1_40 ),
    .I1(\vga/crt_data [0]),
    .I2(\vga/crt/N16 ),
    .I3(\vga/crt_data [1]),
    .O(N306)
  );
  defparam \vga/crt/_and0000 .INIT = 16'h085D;
  LUT4 \vga/crt/_and0000  (
    .I0(\vga/crt/state_FFd3_42 ),
    .I1(\vga/crt_data [2]),
    .I2(N306),
    .I3(N305),
    .O(\vga/crt/_and0000_38 )
  );
  defparam \vga/crt/cursor_v_Eqn_21 .INIT = 4'h4;
  LUT2 \vga/crt/cursor_v_Eqn_21  (
    .I0(\vga/crt/_and0001_39 ),
    .I1(\vga/crt/Result [2]),
    .O(\vga/crt/cursor_v_Eqn_2 )
  );
  defparam \vga/crt/cursor_h_Eqn_21 .INIT = 4'h4;
  LUT2 \vga/crt/cursor_h_Eqn_21  (
    .I0(\vga/crt/_and0000_38 ),
    .I1(\vga/crt/Result<2>1 ),
    .O(\vga/crt/cursor_h_Eqn_2 )
  );
  defparam \vga/ps2/timer_x<2>1 .INIT = 4'h4;
  LUT2 \vga/ps2/timer_x<2>1  (
    .I0(\vga/ps2/ps2_clk_edge ),
    .I1(\vga/ps2/_addsub0000 [2]),
    .O(\vga/ps2/timer_x [2])
  );
  defparam \vga/crt/cursor_v_Eqn_31 .INIT = 4'h4;
  LUT2 \vga/crt/cursor_v_Eqn_31  (
    .I0(\vga/crt/_and0001_39 ),
    .I1(\vga/crt/Result [3]),
    .O(\vga/crt/cursor_v_Eqn_3 )
  );
  defparam \vga/crt/cursor_h_Eqn_31 .INIT = 4'h4;
  LUT2 \vga/crt/cursor_h_Eqn_31  (
    .I0(\vga/crt/_and0000_38 ),
    .I1(\vga/crt/Result<3>1 ),
    .O(\vga/crt/cursor_h_Eqn_3 )
  );
  defparam \vga/ps2/timer_x<3>1 .INIT = 4'h4;
  LUT2 \vga/ps2/timer_x<3>1  (
    .I0(\vga/ps2/ps2_clk_edge ),
    .I1(\vga/ps2/_addsub0000 [3]),
    .O(\vga/ps2/timer_x [3])
  );
  defparam \vga/crt/cursor_v_Eqn_41 .INIT = 4'h4;
  LUT2 \vga/crt/cursor_v_Eqn_41  (
    .I0(\vga/crt/_and0001_39 ),
    .I1(\vga/crt/Result [4]),
    .O(\vga/crt/cursor_v_Eqn_4 )
  );
  defparam \vga/crt/cursor_h_Eqn_41 .INIT = 4'h4;
  LUT2 \vga/crt/cursor_h_Eqn_41  (
    .I0(\vga/crt/_and0000_38 ),
    .I1(\vga/crt/Result<4>1 ),
    .O(\vga/crt/cursor_h_Eqn_4 )
  );
  defparam \vga/ps2/timer_x<4>1 .INIT = 4'h4;
  LUT2 \vga/ps2/timer_x<4>1  (
    .I0(\vga/ps2/ps2_clk_edge ),
    .I1(\vga/ps2/_addsub0000 [4]),
    .O(\vga/ps2/timer_x [4])
  );
  defparam \vga/crt/cursor_v_Eqn_51 .INIT = 4'h4;
  LUT2 \vga/crt/cursor_v_Eqn_51  (
    .I0(\vga/crt/_and0001_39 ),
    .I1(\vga/crt/Result [5]),
    .O(\vga/crt/cursor_v_Eqn_5 )
  );
  defparam \vga/crt/cursor_h_Eqn_51 .INIT = 4'h4;
  LUT2 \vga/crt/cursor_h_Eqn_51  (
    .I0(\vga/crt/_and0000_38 ),
    .I1(\vga/crt/Result<5>1 ),
    .O(\vga/crt/cursor_h_Eqn_5 )
  );
  defparam \vga/ps2/timer_x<5>1 .INIT = 4'h4;
  LUT2 \vga/ps2/timer_x<5>1  (
    .I0(\vga/ps2/ps2_clk_edge ),
    .I1(\vga/ps2/_addsub0000 [5]),
    .O(\vga/ps2/timer_x [5])
  );
  defparam \vga/crt/cursor_h_Eqn_61 .INIT = 4'h4;
  LUT2 \vga/crt/cursor_h_Eqn_61  (
    .I0(\vga/crt/_and0000_38 ),
    .I1(\vga/crt/Result [6]),
    .O(\vga/crt/cursor_h_Eqn_6 )
  );
  defparam \vga/ps2/timer_x<6>1 .INIT = 4'h4;
  LUT2 \vga/ps2/timer_x<6>1  (
    .I0(\vga/ps2/ps2_clk_edge ),
    .I1(\vga/ps2/_addsub0000 [6]),
    .O(\vga/ps2/timer_x [6])
  );
  defparam \vga/ps2/timer_x<7>1 .INIT = 4'h4;
  LUT2 \vga/ps2/timer_x<7>1  (
    .I0(\vga/ps2/ps2_clk_edge ),
    .I1(\vga/ps2/_addsub0000 [7]),
    .O(\vga/ps2/timer_x [7])
  );
  defparam \vga/_and000026 .INIT = 16'h9009;
  LUT4 \vga/_and000026  (
    .I0(\vga/crt/cursor_h [0]),
    .I1(\vga/vgacore/hcnt [3]),
    .I2(\vga/crt/cursor_h [1]),
    .I3(\vga/vgacore/hcnt [4]),
    .O(\vga/_and0000_map879 )
  );
  defparam \vga/_and000053 .INIT = 16'h9009;
  LUT4 \vga/_and000053  (
    .I0(\vga/crt/cursor_h [2]),
    .I1(\vga/vgacore/hcnt [5]),
    .I2(\vga/crt/cursor_h [3]),
    .I3(\vga/vgacore/hcnt [6]),
    .O(\vga/_and0000_map890 )
  );
  defparam \vga/_and0000129 .INIT = 16'h9009;
  LUT4 \vga/_and0000129  (
    .I0(\vga/crt/cursor_v [0]),
    .I1(\vga/vgacore/vcnt [3]),
    .I2(\vga/crt/cursor_v [1]),
    .I3(\vga/vgacore/vcnt [4]),
    .O(\vga/_and0000_map918 )
  );
  defparam \vga/_and0000156 .INIT = 16'h9009;
  LUT4 \vga/_and0000156  (
    .I0(\vga/crt/cursor_v [2]),
    .I1(\vga/vgacore/vcnt [5]),
    .I2(\vga/crt/cursor_v [3]),
    .I3(\vga/vgacore/vcnt [6]),
    .O(\vga/_and0000_map929 )
  );
  defparam \vga/_and0000183 .INIT = 16'h9009;
  LUT4 \vga/_and0000183  (
    .I0(\vga/crt/cursor_v [4]),
    .I1(\vga/vgacore/vcnt [7]),
    .I2(\vga/crt/cursor_v [5]),
    .I3(\vga/vgacore/vcnt [8]),
    .O(\vga/_and0000_map940 )
  );
  defparam \vga/_and0000184 .INIT = 4'h8;
  LUT2 \vga/_and0000184  (
    .I0(\vga/_and0000_map929 ),
    .I1(\vga/_and0000_map940 ),
    .O(\vga/_and0000_map941 )
  );
  defparam \vga/_and0000215 .INIT = 16'h9000;
  LUT4 \vga/_and0000215  (
    .I0(\vga/crt/cursor_h [6]),
    .I1(\vga/vgacore/hcnt [9]),
    .I2(\vga/_and0000_map918 ),
    .I3(\vga/_and0000_map941 ),
    .O(\vga/_and0000_map943 )
  );
  defparam \vga/_and0000238 .INIT = 16'h8000;
  LUT4 \vga/_and0000238  (
    .I0(\vga/_and0000_map879 ),
    .I1(\vga/_and0000_map890 ),
    .I2(\vga/_and0000_map902 ),
    .I3(\vga/_and0000_map943 ),
    .O(\vga/cursor_match )
  );
  defparam \vga/ps2/timer_x<8>1 .INIT = 4'h4;
  LUT2 \vga/ps2/timer_x<8>1  (
    .I0(\vga/ps2/ps2_clk_edge ),
    .I1(\vga/ps2/_addsub0000 [8]),
    .O(\vga/ps2/timer_x [8])
  );
  defparam \vga/ps2/timer_x<9>1 .INIT = 4'h4;
  LUT2 \vga/ps2/timer_x<9>1  (
    .I0(\vga/ps2/ps2_clk_edge ),
    .I1(\vga/ps2/_addsub0000 [9]),
    .O(\vga/ps2/timer_x [9])
  );
  defparam \vga/ps2/timer_x<10>1 .INIT = 4'h4;
  LUT2 \vga/ps2/timer_x<10>1  (
    .I0(\vga/ps2/ps2_clk_edge ),
    .I1(\vga/ps2/_addsub0000 [10]),
    .O(\vga/ps2/timer_x [10])
  );
  defparam \vga/ps2/timer_x<11>1 .INIT = 4'h4;
  LUT2 \vga/ps2/timer_x<11>1  (
    .I0(\vga/ps2/ps2_clk_edge ),
    .I1(\vga/ps2/_addsub0000 [11]),
    .O(\vga/ps2/timer_x [11])
  );
  defparam \vga/ps2/timer_x<12>1 .INIT = 4'h4;
  LUT2 \vga/ps2/timer_x<12>1  (
    .I0(\vga/ps2/ps2_clk_edge ),
    .I1(\vga/ps2/_addsub0000 [12]),
    .O(\vga/ps2/timer_x [12])
  );
  defparam \vga/ps2/timer_x<13>1 .INIT = 4'h4;
  LUT2 \vga/ps2/timer_x<13>1  (
    .I0(\vga/ps2/ps2_clk_edge ),
    .I1(\vga/ps2/_addsub0000 [13]),
    .O(\vga/ps2/timer_x [13])
  );
  defparam \vga/vgacore/vcnt_Eqn_21 .INIT = 16'h22A2;
  LUT4 \vga/vgacore/vcnt_Eqn_21  (
    .I0(\vga/vgacore/vcnt [2]),
    .I1(\vga/vgacore/vcnt [9]),
    .I2(\vga/vgacore/N51 ),
    .I3(\vga/vgacore/vcnt [3]),
    .O(\vga/vgacore/vcnt_Eqn_2 )
  );
  defparam \vga/vgacore/hcnt_Eqn_101 .INIT = 4'h8;
  LUT2 \vga/vgacore/hcnt_Eqn_101  (
    .I0(\vga/vgacore/hcnt_Eqn_bis_0 ),
    .I1(\vga/vgacore/hcnt [10]),
    .O(\vga/vgacore/hcnt_Eqn_10 )
  );
  defparam \vga/_cmp_eq00001 .INIT = 8'h80;
  LUT3 \vga/_cmp_eq00001  (
    .I0(\vga/pclk [2]),
    .I1(\vga/pclk [0]),
    .I2(\vga/pclk [1]),
    .O(\vga/_cmp_eq0000 )
  );
  defparam \vga/charload1 .INIT = 16'hFAD8;
  LUT4 \vga/charload1  (
    .I0(\vga/charload_13 ),
    .I1(\vga/cursor_match ),
    .I2(\vga/pixel_hold [1]),
    .I3(N560),
    .O(\vga/_mux0002 [5])
  );
  defparam \vga/charload8 .INIT = 16'hFAD8;
  LUT4 \vga/charload8  (
    .I0(\vga/charload_13 ),
    .I1(\vga/cursor_match ),
    .I2(\vga/pixel_hold [6]),
    .I3(N562),
    .O(\vga/_mux0002 [0])
  );
  defparam \vga/charload317 .INIT = 16'h5410;
  LUT4 \vga/charload317  (
    .I0(\vga/rom_addr_char [4]),
    .I1(\vga/rom_addr_char [3]),
    .I2(\vga/N0112 ),
    .I3(\vga/N11123 ),
    .O(\vga/charload3_map953 )
  );
  defparam \vga/charload513 .INIT = 16'hE040;
  LUT4 \vga/charload513  (
    .I0(\vga/rom_addr_char [4]),
    .I1(\vga/rom_addr_char<3>_f6123 ),
    .I2(\vga/rom_addr_char [5]),
    .I3(\vga/rom_addr_char<3>_f6112 ),
    .O(\vga/charload5_map965 )
  );
  defparam \vga/charload413 .INIT = 16'hE040;
  LUT4 \vga/charload413  (
    .I0(\vga/rom_addr_char [4]),
    .I1(\vga/rom_addr_char<3>_f612 ),
    .I2(\vga/rom_addr_char [5]),
    .I3(\vga/rom_addr_char<3>_f611 ),
    .O(\vga/charload4_map979 )
  );
  defparam \vga/charload713 .INIT = 16'hE040;
  LUT4 \vga/charload713  (
    .I0(\vga/rom_addr_char [4]),
    .I1(\vga/rom_addr_char<3>_f612345 ),
    .I2(\vga/rom_addr_char [5]),
    .I3(\vga/rom_addr_char<3>_f611234 ),
    .O(\vga/charload7_map993 )
  );
  defparam \vga/charload617 .INIT = 16'h5410;
  LUT4 \vga/charload617  (
    .I0(\vga/rom_addr_char [2]),
    .I1(\vga/rom_addr_char [1]),
    .I2(\vga/N96 ),
    .I3(\vga/N30 ),
    .O(\vga/charload6_map1010 )
  );
  defparam \vga/charload628 .INIT = 16'hC888;
  LUT4 \vga/charload628  (
    .I0(\vga/charload6_map1010 ),
    .I1(\vga/rom_addr_char [3]),
    .I2(\vga/rom_addr_char [2]),
    .I3(\vga/N98 ),
    .O(\vga/charload6_map1012 )
  );
  defparam \vga/charload637 .INIT = 4'h4;
  LUT2 \vga/charload637  (
    .I0(\vga/rom_addr_char [3]),
    .I1(\vga/rom_addr_char<2>_f51234 ),
    .O(\vga/charload6_map1014 )
  );
  defparam \vga/charload669 .INIT = 16'hFE54;
  LUT4 \vga/charload669  (
    .I0(\vga/rom_addr_char [4]),
    .I1(\vga/charload6_map1012 ),
    .I2(\vga/charload6_map1014 ),
    .I3(\vga/rom_addr_char<3>_f61234 ),
    .O(\vga/charload6_map1018 )
  );
  defparam \vga/charload6111 .INIT = 16'hEA40;
  LUT4 \vga/charload6111  (
    .I0(\vga/rom_addr_char [6]),
    .I1(\vga/rom_addr_char [5]),
    .I2(\vga/charload6_map1018 ),
    .I3(\vga/rom_addr_char<5>_f512 ),
    .O(\vga/charload6_map1022 )
  );
  defparam \vga/charload6153 .INIT = 16'hFAD8;
  LUT4 \vga/charload6153  (
    .I0(\vga/charload_13 ),
    .I1(\vga/cursor_match ),
    .I2(\vga/pixel_hold [3]),
    .I3(\vga/charload6_map1022 ),
    .O(\vga/_mux0002 [3])
  );
  defparam \vga/vgacore/vcnt_Eqn_3_SW0 .INIT = 8'hEA;
  LUT3 \vga/vgacore/vcnt_Eqn_3_SW0  (
    .I0(\vga/vgacore/vcnt [2]),
    .I1(\vga/vgacore/vcnt [1]),
    .I2(\vga/vgacore/vcnt [0]),
    .O(N786)
  );
  defparam \vga/vgacore/vcnt_Eqn_3 .INIT = 16'h22A2;
  LUT4 \vga/vgacore/vcnt_Eqn_3  (
    .I0(\vga/vgacore/vcnt [3]),
    .I1(\vga/vgacore/vcnt [9]),
    .I2(\vga/vgacore/N51 ),
    .I3(N786),
    .O(\vga/vgacore/vcnt_Eqn_3_46 )
  );
  defparam \vga/ps2/_cmp_eq00018 .INIT = 16'h0020;
  LUT4 \vga/ps2/_cmp_eq00018  (
    .I0(\vga/ps2/timer_r [7]),
    .I1(\vga/ps2/timer_r [4]),
    .I2(\vga/ps2/timer_r [6]),
    .I3(\vga/ps2/timer_r [5]),
    .O(\vga/ps2/_cmp_eq0001_map1032 )
  );
  defparam \vga/ps2/_cmp_eq000112 .INIT = 4'h1;
  LUT2 \vga/ps2/_cmp_eq000112  (
    .I0(\vga/ps2/timer_r [12]),
    .I1(\vga/ps2/timer_r [13]),
    .O(\vga/ps2/_cmp_eq0001_map1035 )
  );
  defparam \vga/ps2/_cmp_eq000130 .INIT = 16'h0020;
  LUT4 \vga/ps2/_cmp_eq000130  (
    .I0(\vga/ps2/timer_r [8]),
    .I1(\vga/ps2/timer_r [9]),
    .I2(\vga/ps2/timer_r [11]),
    .I3(\vga/ps2/timer_r [10]),
    .O(\vga/ps2/_cmp_eq0001_map1041 )
  );
  defparam \vga/ps2/_cmp_eq000142 .INIT = 16'h0002;
  LUT4 \vga/ps2/_cmp_eq000142  (
    .I0(\vga/ps2/timer_r [2]),
    .I1(\vga/ps2/timer_r [3]),
    .I2(\vga/ps2/timer_r [0]),
    .I3(\vga/ps2/timer_r [1]),
    .O(\vga/ps2/_cmp_eq0001_map1047 )
  );
  defparam \vga/ps2/_cmp_eq000156 .INIT = 16'h8000;
  LUT4 \vga/ps2/_cmp_eq000156  (
    .I0(\vga/ps2/_cmp_eq0001_map1032 ),
    .I1(\vga/ps2/_cmp_eq0001_map1035 ),
    .I2(\vga/ps2/_cmp_eq0001_map1041 ),
    .I3(\vga/ps2/_cmp_eq0001_map1047 ),
    .O(\vga/ps2/_cmp_eq0001 )
  );
  defparam \vga/vgacore/vcnt_Eqn_1_SW0 .INIT = 8'hC8;
  LUT3 \vga/vgacore/vcnt_Eqn_1_SW0  (
    .I0(\vga/vgacore/vcnt [2]),
    .I1(\vga/vgacore/vcnt [3]),
    .I2(\vga/vgacore/vcnt [0]),
    .O(N839)
  );
  defparam \vga/vgacore/vcnt_Eqn_1 .INIT = 16'h22A2;
  LUT4 \vga/vgacore/vcnt_Eqn_1  (
    .I0(\vga/vgacore/vcnt [1]),
    .I1(\vga/vgacore/vcnt [9]),
    .I2(\vga/vgacore/N51 ),
    .I3(N839),
    .O(\vga/vgacore/vcnt_Eqn_1_45 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<1>101 .INIT = 8'hBD;
  LUT3 \vga/scancode_convert/scancode_rom/data<1>101  (
    .I0(\vga/scancode_convert/sc [0]),
    .I1(\vga/scancode_convert/sc [1]),
    .I2(\vga/scancode_convert/raise ),
    .O(\vga/scancode_convert/scancode_rom/N28 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<2>1308 .INIT = 16'h24FF;
  LUT4 \vga/scancode_convert/scancode_rom/data<2>1308  (
    .I0(\vga/scancode_convert/sc [4]),
    .I1(\vga/scancode_convert/sc [1]),
    .I2(\vga/scancode_convert/sc [0]),
    .I3(\vga/scancode_convert/sc [3]),
    .O(\vga/scancode_convert/scancode_rom/data<2>1_map1121 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<2>1329 .INIT = 16'hCF8F;
  LUT4 \vga/scancode_convert/scancode_rom/data<2>1329  (
    .I0(\vga/scancode_convert/scancode_rom/data<2>1_map1110 ),
    .I1(\vga/scancode_convert/scancode_rom/data<2>1_map1121 ),
    .I2(\vga/scancode_convert/sc [2]),
    .I3(\vga/scancode_convert/sc [3]),
    .O(\vga/scancode_convert/scancode_rom/data<2>1_map1124 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<2>1458 .INIT = 16'hE444;
  LUT4 \vga/scancode_convert/scancode_rom/data<2>1458  (
    .I0(\vga/scancode_convert/sc [6]),
    .I1(\vga/scancode_convert/scancode_rom/data<2>1_map1098 ),
    .I2(\vga/scancode_convert/scancode_rom/data<2>1_map1124 ),
    .I3(\vga/scancode_convert/scancode_rom/data<2>1_map1144 ),
    .O(\vga/scancode_convert/rom_data [2])
  );
  defparam \vga/scancode_convert/scancode_rom/data<0>241 .INIT = 4'h9;
  LUT2 \vga/scancode_convert/scancode_rom/data<0>241  (
    .I0(\vga/scancode_convert/sc [0]),
    .I1(\vga/scancode_convert/sc [1]),
    .O(\vga/scancode_convert/scancode_rom/N18 )
  );
  defparam \vga/vgacore/hcnt_Eqn_91 .INIT = 4'h8;
  LUT2 \vga/vgacore/hcnt_Eqn_91  (
    .I0(\vga/vgacore/hcnt_Eqn_bis_0 ),
    .I1(\vga/vgacore/hcnt [9]),
    .O(\vga/vgacore/hcnt_Eqn_9 )
  );
  defparam \vga/vgacore/hcnt_Eqn_81 .INIT = 4'h8;
  LUT2 \vga/vgacore/hcnt_Eqn_81  (
    .I0(\vga/vgacore/hcnt_Eqn_bis_0 ),
    .I1(\vga/vgacore/hcnt [8]),
    .O(\vga/vgacore/hcnt_Eqn_8 )
  );
  defparam \vga/vgacore/hcnt_Eqn_71 .INIT = 4'h8;
  LUT2 \vga/vgacore/hcnt_Eqn_71  (
    .I0(\vga/vgacore/hcnt_Eqn_bis_0 ),
    .I1(\vga/vgacore/hcnt [7]),
    .O(\vga/vgacore/hcnt_Eqn_7 )
  );
  defparam \vga/vgacore/hcnt_Eqn_61 .INIT = 4'h8;
  LUT2 \vga/vgacore/hcnt_Eqn_61  (
    .I0(\vga/vgacore/hcnt_Eqn_bis_0 ),
    .I1(\vga/vgacore/hcnt [6]),
    .O(\vga/vgacore/hcnt_Eqn_6 )
  );
  defparam \vga/vgacore/hcnt_Eqn_51 .INIT = 4'h8;
  LUT2 \vga/vgacore/hcnt_Eqn_51  (
    .I0(\vga/vgacore/hcnt_Eqn_bis_0 ),
    .I1(\vga/vgacore/hcnt [5]),
    .O(\vga/vgacore/hcnt_Eqn_5 )
  );
  defparam \vga/vgacore/hcnt_Eqn_41 .INIT = 4'h8;
  LUT2 \vga/vgacore/hcnt_Eqn_41  (
    .I0(\vga/vgacore/hcnt_Eqn_bis_0 ),
    .I1(\vga/vgacore/hcnt [4]),
    .O(\vga/vgacore/hcnt_Eqn_4 )
  );
  defparam \vga/vgacore/hcnt_Eqn_31 .INIT = 4'h8;
  LUT2 \vga/vgacore/hcnt_Eqn_31  (
    .I0(\vga/vgacore/hcnt_Eqn_bis_0 ),
    .I1(\vga/vgacore/hcnt [3]),
    .O(\vga/vgacore/hcnt_Eqn_3 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<3>81 .INIT = 8'hF7;
  LUT3 \vga/scancode_convert/scancode_rom/data<3>81  (
    .I0(\vga/scancode_convert/sc [1]),
    .I1(\vga/scancode_convert/raise ),
    .I2(\vga/scancode_convert/sc [0]),
    .O(\vga/scancode_convert/scancode_rom/N43 )
  );
  defparam \vga/vgacore/hcnt_Eqn_21 .INIT = 4'h8;
  LUT2 \vga/vgacore/hcnt_Eqn_21  (
    .I0(\vga/vgacore/hcnt_Eqn_bis_0 ),
    .I1(\vga/vgacore/hcnt [2]),
    .O(\vga/vgacore/hcnt_Eqn_2 )
  );
  defparam \vga/vgacore/hcnt_Eqn_11 .INIT = 4'h8;
  LUT2 \vga/vgacore/hcnt_Eqn_11  (
    .I0(\vga/vgacore/hcnt_Eqn_bis_0 ),
    .I1(\vga/vgacore/hcnt [1]),
    .O(\vga/vgacore/hcnt_Eqn_1 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<5>327 .INIT = 16'h4048;
  LUT4 \vga/scancode_convert/scancode_rom/data<5>327  (
    .I0(\vga/scancode_convert/sc_0_1_93 ),
    .I1(\vga/scancode_convert/sc [4]),
    .I2(\vga/scancode_convert/sc_1_1_91 ),
    .I3(\vga/scancode_convert/raise1_92 ),
    .O(\vga/scancode_convert/scancode_rom/data<5>3_map1245 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<5>341 .INIT = 8'hAE;
  LUT3 \vga/scancode_convert/scancode_rom/data<5>341  (
    .I0(\vga/scancode_convert/sc [4]),
    .I1(\vga/scancode_convert/sc_1_1_91 ),
    .I2(\vga/scancode_convert/sc_0_1_93 ),
    .O(\vga/scancode_convert/scancode_rom/data<5>3_map1249 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<5>374 .INIT = 16'h1FBF;
  LUT4 \vga/scancode_convert/scancode_rom/data<5>374  (
    .I0(\vga/scancode_convert/sc_1_1_91 ),
    .I1(N3276),
    .I2(\vga/scancode_convert/sc [4]),
    .I3(\vga/scancode_convert/sc_0_1_93 ),
    .O(\vga/scancode_convert/scancode_rom/data<5>3_map1260 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<5>3193 .INIT = 16'hF3F2;
  LUT4 \vga/scancode_convert/scancode_rom/data<5>3193  (
    .I0(\vga/scancode_convert/sc [1]),
    .I1(\vga/scancode_convert/raise ),
    .I2(\vga/scancode_convert/sc [3]),
    .I3(\vga/scancode_convert/sc [0]),
    .O(\vga/scancode_convert/scancode_rom/data<5>3_map1276 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<5>3282 .INIT = 16'hFF8C;
  LUT4 \vga/scancode_convert/scancode_rom/data<5>3282  (
    .I0(\vga/scancode_convert/scancode_rom/data<5>3_map1291 ),
    .I1(\vga/scancode_convert/scancode_rom/data<5>3_map1276 ),
    .I2(\vga/scancode_convert/sc [3]),
    .I3(\vga/scancode_convert/sc [2]),
    .O(\vga/scancode_convert/scancode_rom/data<5>3_map1295 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<5>3483 .INIT = 16'hCF8F;
  LUT4 \vga/scancode_convert/scancode_rom/data<5>3483  (
    .I0(\vga/scancode_convert/scancode_rom/data<5>3_map1314 ),
    .I1(\vga/scancode_convert/scancode_rom/data<5>3_map1337 ),
    .I2(\vga/scancode_convert/sc [2]),
    .I3(\vga/scancode_convert/sc [3]),
    .O(\vga/scancode_convert/scancode_rom/data<5>3_map1340 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<5>3614 .INIT = 16'h3365;
  LUT4 \vga/scancode_convert/scancode_rom/data<5>3614  (
    .I0(\vga/scancode_convert/sc [4]),
    .I1(\vga/scancode_convert/sc [1]),
    .I2(\vga/scancode_convert/raise ),
    .I3(\vga/scancode_convert/sc [0]),
    .O(\vga/scancode_convert/scancode_rom/data<5>3_map1363 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<5>3746 .INIT = 16'h9454;
  LUT4 \vga/scancode_convert/scancode_rom/data<5>3746  (
    .I0(\vga/scancode_convert/sc [4]),
    .I1(\vga/scancode_convert/sc [1]),
    .I2(\vga/scancode_convert/sc [0]),
    .I3(\vga/scancode_convert/raise ),
    .O(\vga/scancode_convert/scancode_rom/data<5>3_map1394 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<0>14 .INIT = 16'h8000;
  LUT4 \vga/scancode_convert/scancode_rom/data<0>14  (
    .I0(\vga/scancode_convert/sc [3]),
    .I1(\vga/scancode_convert/sc [4]),
    .I2(\vga/scancode_convert/sc [0]),
    .I3(\vga/scancode_convert/sc [1]),
    .O(\vga/scancode_convert/scancode_rom/data<0>1_map1423 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<0>119 .INIT = 16'hFF60;
  LUT4 \vga/scancode_convert/scancode_rom/data<0>119  (
    .I0(\vga/scancode_convert/sc [0]),
    .I1(\vga/scancode_convert/sc [1]),
    .I2(\vga/scancode_convert/sc [4]),
    .I3(\vga/scancode_convert/sc [3]),
    .O(\vga/scancode_convert/scancode_rom/data<0>1_map1429 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<0>144 .INIT = 16'h2232;
  LUT4 \vga/scancode_convert/scancode_rom/data<0>144  (
    .I0(\vga/scancode_convert/sc [4]),
    .I1(\vga/scancode_convert/sc [1]),
    .I2(\vga/scancode_convert/sc [0]),
    .I3(\vga/scancode_convert/raise ),
    .O(\vga/scancode_convert/scancode_rom/data<0>1_map1438 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<0>1158 .INIT = 16'hFF27;
  LUT4 \vga/scancode_convert/scancode_rom/data<0>1158  (
    .I0(\vga/scancode_convert/sc [4]),
    .I1(\vga/scancode_convert/sc [1]),
    .I2(\vga/scancode_convert/sc [0]),
    .I3(\vga/scancode_convert/sc [3]),
    .O(\vga/scancode_convert/scancode_rom/data<0>1_map1461 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<0>1206 .INIT = 16'h0626;
  LUT4 \vga/scancode_convert/scancode_rom/data<0>1206  (
    .I0(\vga/scancode_convert/sc [4]),
    .I1(\vga/scancode_convert/sc [1]),
    .I2(\vga/scancode_convert/sc [0]),
    .I3(\vga/scancode_convert/raise ),
    .O(\vga/scancode_convert/scancode_rom/data<0>1_map1475 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<0>1492 .INIT = 16'hCF8F;
  LUT4 \vga/scancode_convert/scancode_rom/data<0>1492  (
    .I0(\vga/scancode_convert/scancode_rom/data<0>1_map1517 ),
    .I1(\vga/scancode_convert/scancode_rom/data<0>1_map1526 ),
    .I2(\vga/scancode_convert/sc [2]),
    .I3(\vga/scancode_convert/sc [3]),
    .O(\vga/scancode_convert/scancode_rom/data<0>1_map1529 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<1>281 .INIT = 16'h0602;
  LUT4 \vga/scancode_convert/scancode_rom/data<1>281  (
    .I0(\vga/scancode_convert/sc [0]),
    .I1(\vga/scancode_convert/sc [1]),
    .I2(\vga/scancode_convert/sc [3]),
    .I3(\vga/scancode_convert/sc [4]),
    .O(\vga/scancode_convert/scancode_rom/data<1>2_map1701 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<1>2109 .INIT = 16'h8808;
  LUT4 \vga/scancode_convert/scancode_rom/data<1>2109  (
    .I0(\vga/scancode_convert/sc [3]),
    .I1(\vga/scancode_convert/sc [1]),
    .I2(\vga/scancode_convert/sc [4]),
    .I3(\vga/scancode_convert/sc [0]),
    .O(\vga/scancode_convert/scancode_rom/data<1>2_map1708 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<1>2147 .INIT = 16'hF3F2;
  LUT4 \vga/scancode_convert/scancode_rom/data<1>2147  (
    .I0(\vga/scancode_convert/sc [1]),
    .I1(\vga/scancode_convert/sc [0]),
    .I2(\vga/scancode_convert/sc [3]),
    .I3(\vga/scancode_convert/sc [4]),
    .O(\vga/scancode_convert/scancode_rom/data<1>2_map1717 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<1>2184 .INIT = 16'h2C0C;
  LUT4 \vga/scancode_convert/scancode_rom/data<1>2184  (
    .I0(\vga/scancode_convert/sc [4]),
    .I1(\vga/scancode_convert/sc [0]),
    .I2(\vga/scancode_convert/sc [1]),
    .I3(\vga/scancode_convert/raise ),
    .O(\vga/scancode_convert/scancode_rom/data<1>2_map1729 )
  );
  defparam \vga/scancode_convert/raise1 .INIT = 8'hFE;
  LUT3 \vga/scancode_convert/raise1  (
    .I0(\vga/scancode_convert/ctrl_57 ),
    .I1(\vga/scancode_convert/shift_49 ),
    .I2(\vga/scancode_convert/capslock_48 ),
    .O(\vga/scancode_convert/raise )
  );
  defparam \vga/scancode_convert/scancode_rom/data<6>1141 .INIT = 16'h20B9;
  LUT4 \vga/scancode_convert/scancode_rom/data<6>1141  (
    .I0(\vga/scancode_convert/sc [4]),
    .I1(\vga/scancode_convert/sc [0]),
    .I2(N3272),
    .I3(\vga/scancode_convert/sc [1]),
    .O(\vga/scancode_convert/scancode_rom/data<6>1_map1820 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<6>1305 .INIT = 16'h09FF;
  LUT4 \vga/scancode_convert/scancode_rom/data<6>1305  (
    .I0(\vga/scancode_convert/sc [3]),
    .I1(\vga/scancode_convert/sc [0]),
    .I2(\vga/scancode_convert/sc [1]),
    .I3(\vga/scancode_convert/sc [2]),
    .O(\vga/scancode_convert/scancode_rom/data<6>1_map1850 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<6>1360 .INIT = 8'hD5;
  LUT3 \vga/scancode_convert/scancode_rom/data<6>1360  (
    .I0(\vga/scancode_convert/sc [6]),
    .I1(\vga/scancode_convert/scancode_rom/data<6>1_map1860 ),
    .I2(\vga/scancode_convert/scancode_rom/data<6>1_map1850 ),
    .O(\vga/scancode_convert/scancode_rom/data<6>1_map1863 )
  );
  BUFGP clka_BUFGP (
    .I(clka),
    .O(clka_BUFGP_4)
  );
  IBUF reset_n_IBUF (
    .I(reset_n),
    .O(reset_n_IBUF_0)
  );
  IBUF ps2_clk_IBUF (
    .I(ps2_clk),
    .O(ps2_clk_IBUF_1)
  );
  IBUF ps2_data_IBUF (
    .I(ps2_data),
    .O(ps2_data_IBUF_2)
  );
  OBUF vga_hsync_n_OBUF (
    .I(vga_hsync_n_OBUF_3),
    .O(vga_hsync_n)
  );
  OBUF fpga_din_d0_OBUF (
    .I(\vga/scancode_convert/ascii [6]),
    .O(fpga_din_d0)
  );
  OBUF vga_red0_OBUF (
    .I(pixel[8]),
    .O(vga_red0)
  );
  OBUF vga_red1_OBUF (
    .I(pixel[8]),
    .O(vga_red1)
  );
  OBUF vga_red2_OBUF (
    .I(pixel[8]),
    .O(vga_red2)
  );
  OBUF vga_green0_OBUF (
    .I(pixel[8]),
    .O(vga_green0)
  );
  OBUF vga_green1_OBUF (
    .I(pixel[8]),
    .O(vga_green1)
  );
  OBUF vga_green2_OBUF (
    .I(pixel[8]),
    .O(vga_green2)
  );
  OBUF vga_blue0_OBUF (
    .I(pixel[8]),
    .O(vga_blue0)
  );
  OBUF vga_blue1_OBUF (
    .I(pixel[8]),
    .O(vga_blue1)
  );
  OBUF vga_blue2_OBUF (
    .I(pixel[8]),
    .O(vga_blue2)
  );
  OBUF vga_vsync_n_OBUF (
    .I(vga_vsync_n_OBUF_5),
    .O(vga_vsync_n)
  );
  OBUF fpga_d1_OBUF (
    .I(\vga/ps2/rdy_r_8 ),
    .O(fpga_d1)
  );
  OBUF fpga_d2_OBUF (
    .I(\vga/scancode_convert/ascii [5]),
    .O(fpga_d2)
  );
  OBUF fpga_d3_OBUF (
    .I(\vga/scancode_convert/ascii [4]),
    .O(fpga_d3)
  );
  OBUF fpga_d4_OBUF (
    .I(\vga/scancode_convert/ascii [3]),
    .O(fpga_d4)
  );
  OBUF fpga_d5_OBUF (
    .I(\vga/scancode_convert/ascii [2]),
    .O(fpga_d5)
  );
  OBUF fpga_d6_OBUF (
    .I(\vga/scancode_convert/ascii [1]),
    .O(fpga_d6)
  );
  OBUF fpga_d7_OBUF (
    .I(\vga/scancode_convert/ascii [0]),
    .O(fpga_d7)
  );
  FDCE \vga/ps2/sc_r_0  (
    .D(\vga/ps2/sc_r [1]),
    .CE(\vga/ps2/ps2_clk_fall_edge ),
    .CLR(gray_cnt_Rst_inv),
    .C(gray_cnt_FFd1_9),
    .Q(\vga/ps2/sc_r [0])
  );
  FDCE \vga/ps2/sc_r_1  (
    .D(\vga/ps2/sc_r [2]),
    .CE(\vga/ps2/ps2_clk_fall_edge ),
    .CLR(gray_cnt_Rst_inv),
    .C(gray_cnt_FFd1_9),
    .Q(\vga/ps2/sc_r [1])
  );
  FDCE \vga/ps2/sc_r_2  (
    .D(\vga/ps2/sc_r [3]),
    .CE(\vga/ps2/ps2_clk_fall_edge ),
    .CLR(gray_cnt_Rst_inv),
    .C(gray_cnt_FFd1_9),
    .Q(\vga/ps2/sc_r [2])
  );
  FDCE \vga/ps2/sc_r_3  (
    .D(\vga/ps2/sc_r [4]),
    .CE(\vga/ps2/ps2_clk_fall_edge ),
    .CLR(gray_cnt_Rst_inv),
    .C(gray_cnt_FFd1_9),
    .Q(\vga/ps2/sc_r [3])
  );
  FDCE \vga/ps2/sc_r_4  (
    .D(\vga/ps2/sc_r [5]),
    .CE(\vga/ps2/ps2_clk_fall_edge ),
    .CLR(gray_cnt_Rst_inv),
    .C(gray_cnt_FFd1_9),
    .Q(\vga/ps2/sc_r [4])
  );
  FDCE \vga/ps2/sc_r_5  (
    .D(\vga/ps2/sc_r [6]),
    .CE(\vga/ps2/ps2_clk_fall_edge ),
    .CLR(gray_cnt_Rst_inv),
    .C(gray_cnt_FFd1_9),
    .Q(\vga/ps2/sc_r [5])
  );
  FDCE \vga/ps2/sc_r_6  (
    .D(\vga/ps2/sc_r [7]),
    .CE(\vga/ps2/ps2_clk_fall_edge ),
    .CLR(gray_cnt_Rst_inv),
    .C(gray_cnt_FFd1_9),
    .Q(\vga/ps2/sc_r [6])
  );
  FDCE \vga/ps2/sc_r_7  (
    .D(\vga/ps2/sc_r [8]),
    .CE(\vga/ps2/ps2_clk_fall_edge ),
    .CLR(gray_cnt_Rst_inv),
    .C(gray_cnt_FFd1_9),
    .Q(\vga/ps2/sc_r [7])
  );
  FDCE \vga/ps2/sc_r_8  (
    .D(\vga/ps2/sc_r [9]),
    .CE(\vga/ps2/ps2_clk_fall_edge ),
    .CLR(gray_cnt_Rst_inv1_INV_0_1_99),
    .C(gray_cnt_FFd1_9),
    .Q(\vga/ps2/sc_r [8])
  );
  FDCE \vga/ps2/sc_r_9  (
    .D(ps2_data_IBUF_2),
    .CE(\vga/ps2/ps2_clk_fall_edge ),
    .CLR(gray_cnt_Rst_inv1_INV_0_1_99),
    .C(gray_cnt_FFd1_9),
    .Q(\vga/ps2/sc_r [9])
  );
  defparam \vga/crt/cursor_v_1_rt .INIT = 4'h2;
  LUT1 \vga/crt/cursor_v_1_rt  (
    .I0(\vga/crt/cursor_v [1]),
    .O(\vga/crt/cursor_v_1_rt_64 )
  );
  defparam \vga/crt/cursor_v_2_rt .INIT = 4'h2;
  LUT1 \vga/crt/cursor_v_2_rt  (
    .I0(\vga/crt/cursor_v [2]),
    .O(\vga/crt/cursor_v_2_rt_65 )
  );
  defparam \vga/crt/cursor_v_3_rt .INIT = 4'h2;
  LUT1 \vga/crt/cursor_v_3_rt  (
    .I0(\vga/crt/cursor_v [3]),
    .O(\vga/crt/cursor_v_3_rt_66 )
  );
  defparam \vga/crt/cursor_v_4_rt .INIT = 4'h2;
  LUT1 \vga/crt/cursor_v_4_rt  (
    .I0(\vga/crt/cursor_v [4]),
    .O(\vga/crt/cursor_v_4_rt_67 )
  );
  defparam \vga/crt/cursor_h_1_rt .INIT = 4'h2;
  LUT1 \vga/crt/cursor_h_1_rt  (
    .I0(\vga/crt/cursor_h [1]),
    .O(\vga/crt/cursor_h_1_rt_68 )
  );
  defparam \vga/crt/cursor_h_2_rt .INIT = 4'h2;
  LUT1 \vga/crt/cursor_h_2_rt  (
    .I0(\vga/crt/cursor_h [2]),
    .O(\vga/crt/cursor_h_2_rt_69 )
  );
  defparam \vga/crt/cursor_h_3_rt .INIT = 4'h2;
  LUT1 \vga/crt/cursor_h_3_rt  (
    .I0(\vga/crt/cursor_h [3]),
    .O(\vga/crt/cursor_h_3_rt_70 )
  );
  defparam \vga/crt/cursor_h_4_rt .INIT = 4'h2;
  LUT1 \vga/crt/cursor_h_4_rt  (
    .I0(\vga/crt/cursor_h [4]),
    .O(\vga/crt/cursor_h_4_rt_71 )
  );
  defparam \vga/crt/cursor_h_5_rt .INIT = 4'h2;
  LUT1 \vga/crt/cursor_h_5_rt  (
    .I0(\vga/crt/cursor_h [5]),
    .O(\vga/crt/cursor_h_5_rt_72 )
  );
  defparam \vga/vgacore/hcnt_4_rt .INIT = 4'h2;
  LUT1 \vga/vgacore/hcnt_4_rt  (
    .I0(\vga/vgacore/hcnt [4]),
    .O(\vga/vgacore/hcnt_4_rt_73 )
  );
  defparam \vga/ps2/timer_r_1_rt .INIT = 4'h2;
  LUT1 \vga/ps2/timer_r_1_rt  (
    .I0(\vga/ps2/timer_r [1]),
    .O(\vga/ps2/timer_r_1_rt_74 )
  );
  defparam \vga/ps2/timer_r_2_rt .INIT = 4'h2;
  LUT1 \vga/ps2/timer_r_2_rt  (
    .I0(\vga/ps2/timer_r [2]),
    .O(\vga/ps2/timer_r_2_rt_75 )
  );
  defparam \vga/ps2/timer_r_3_rt .INIT = 4'h2;
  LUT1 \vga/ps2/timer_r_3_rt  (
    .I0(\vga/ps2/timer_r [3]),
    .O(\vga/ps2/timer_r_3_rt_76 )
  );
  defparam \vga/ps2/timer_r_4_rt .INIT = 4'h2;
  LUT1 \vga/ps2/timer_r_4_rt  (
    .I0(\vga/ps2/timer_r [4]),
    .O(\vga/ps2/timer_r_4_rt_77 )
  );
  defparam \vga/ps2/timer_r_5_rt .INIT = 4'h2;
  LUT1 \vga/ps2/timer_r_5_rt  (
    .I0(\vga/ps2/timer_r [5]),
    .O(\vga/ps2/timer_r_5_rt_78 )
  );
  defparam \vga/ps2/timer_r_6_rt .INIT = 4'h2;
  LUT1 \vga/ps2/timer_r_6_rt  (
    .I0(\vga/ps2/timer_r [6]),
    .O(\vga/ps2/timer_r_6_rt_79 )
  );
  defparam \vga/ps2/timer_r_7_rt .INIT = 4'h2;
  LUT1 \vga/ps2/timer_r_7_rt  (
    .I0(\vga/ps2/timer_r [7]),
    .O(\vga/ps2/timer_r_7_rt_80 )
  );
  defparam \vga/ps2/timer_r_8_rt .INIT = 4'h2;
  LUT1 \vga/ps2/timer_r_8_rt  (
    .I0(\vga/ps2/timer_r [8]),
    .O(\vga/ps2/timer_r_8_rt_81 )
  );
  defparam \vga/ps2/timer_r_9_rt .INIT = 4'h2;
  LUT1 \vga/ps2/timer_r_9_rt  (
    .I0(\vga/ps2/timer_r [9]),
    .O(\vga/ps2/timer_r_9_rt_82 )
  );
  defparam \vga/ps2/timer_r_10_rt .INIT = 4'h2;
  LUT1 \vga/ps2/timer_r_10_rt  (
    .I0(\vga/ps2/timer_r [10]),
    .O(\vga/ps2/timer_r_10_rt_83 )
  );
  defparam \vga/ps2/timer_r_11_rt .INIT = 4'h2;
  LUT1 \vga/ps2/timer_r_11_rt  (
    .I0(\vga/ps2/timer_r [11]),
    .O(\vga/ps2/timer_r_11_rt_84 )
  );
  defparam \vga/ps2/timer_r_12_rt .INIT = 4'h2;
  LUT1 \vga/ps2/timer_r_12_rt  (
    .I0(\vga/ps2/timer_r [12]),
    .O(\vga/ps2/timer_r_12_rt_85 )
  );
  defparam \vga/vgacore/vcnt_8_rt .INIT = 4'h2;
  LUT1 \vga/vgacore/vcnt_8_rt  (
    .I0(\vga/vgacore/vcnt [8]),
    .O(\vga/vgacore/vcnt_8_rt_86 )
  );
  defparam \vga/crt/cursor_v_5_rt .INIT = 4'h2;
  LUT1 \vga/crt/cursor_v_5_rt  (
    .I0(\vga/crt/cursor_v [5]),
    .O(\vga/crt/cursor_v_5_rt_87 )
  );
  defparam \vga/crt/cursor_v_5_rt1 .INIT = 4'h2;
  LUT1 \vga/crt/cursor_v_5_rt1  (
    .I0(\vga/crt/cursor_v [5]),
    .O(\vga/crt/cursor_v_5_rt1_88 )
  );
  defparam \vga/crt/cursor_h_6_rt .INIT = 4'h2;
  LUT1 \vga/crt/cursor_h_6_rt  (
    .I0(\vga/crt/cursor_h [6]),
    .O(\vga/crt/cursor_h_6_rt_89 )
  );
  defparam \vga/ps2/timer_r_13_rt .INIT = 4'h2;
  LUT1 \vga/ps2/timer_r_13_rt  (
    .I0(\vga/ps2/timer_r [13]),
    .O(\vga/ps2/timer_r_13_rt_90 )
  );
  defparam \vga/rom_addr_char<2>_f5_65 .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<2>_f5_65  (
    .I0(\vga/rom_addr_char_1_1_95 ),
    .I1(\vga/N33 ),
    .I2(\vga/N34 ),
    .O(N3078)
  );
  defparam \vga/rom_addr_char<2>_f5_102 .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<2>_f5_102  (
    .I0(\vga/rom_addr_char_1_1_95 ),
    .I1(\vga/N70 ),
    .I2(\vga/N71 ),
    .O(N3079)
  );
  defparam \vga/rom_addr_char<2>_f5_421 .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<2>_f5_421  (
    .I0(\vga/rom_addr_char_1_1_95 ),
    .I1(\vga/N78 ),
    .I2(\vga/N79 ),
    .O(N3080)
  );
  defparam \vga/rom_addr_char<2>_f5_821 .INIT = 8'hE4;
  LUT3 \vga/rom_addr_char<2>_f5_821  (
    .I0(\vga/rom_addr_char_1_1_95 ),
    .I1(\vga/N63 ),
    .I2(\vga/N64 ),
    .O(N3081)
  );
  defparam \vga/scancode_convert/_mux0008<6>1 .INIT = 16'h36CC;
  LUT4 \vga/scancode_convert/_mux0008<6>1  (
    .I0(\vga/scancode_convert/scancode_rom/data<6>1_map1838 ),
    .I1(\vga/scancode_convert/ctrl_57 ),
    .I2(\vga/scancode_convert/sc [6]),
    .I3(\vga/scancode_convert/scancode_rom/data<6>1_map1863 ),
    .O(\vga/scancode_convert/_mux0008 [6])
  );
  defparam \vga/scancode_convert/scancode_rom/data<6>1201_SW1 .INIT = 16'hCF4F;
  LUT4 \vga/scancode_convert/scancode_rom/data<6>1201_SW1  (
    .I0(\vga/scancode_convert/sc [2]),
    .I1(\vga/scancode_convert/scancode_rom/data<6>1_map1808 ),
    .I2(\vga/scancode_convert/sc [5]),
    .I3(N3271),
    .O(N3085)
  );
  defparam \vga/scancode_convert/scancode_rom/data<0>1536 .INIT = 16'h555D;
  LUT4 \vga/scancode_convert/scancode_rom/data<0>1536  (
    .I0(\vga/scancode_convert/sc [5]),
    .I1(\vga/scancode_convert/sc [2]),
    .I2(\vga/scancode_convert/sc [3]),
    .I3(N3274),
    .O(\vga/scancode_convert/scancode_rom/data<0>1_map1534 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<3>1125 .INIT = 16'h4EFF;
  LUT4 \vga/scancode_convert/scancode_rom/data<3>1125  (
    .I0(\vga/scancode_convert/sc [3]),
    .I1(\vga/scancode_convert/scancode_rom/data<3>1_map1178 ),
    .I2(\vga/scancode_convert/scancode_rom/N7 ),
    .I3(\vga/scancode_convert/sc [2]),
    .O(\vga/scancode_convert/scancode_rom/data<3>1_map1185 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<5>3696 .INIT = 16'hF7D5;
  LUT4 \vga/scancode_convert/scancode_rom/data<5>3696  (
    .I0(\vga/scancode_convert/sc [2]),
    .I1(\vga/scancode_convert/sc [3]),
    .I2(\vga/scancode_convert/scancode_rom/data<5>3_map1376 ),
    .I3(\vga/scancode_convert/scancode_rom/data<5>3_map1363 ),
    .O(\vga/scancode_convert/scancode_rom/data<5>3_map1381 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<0>1104 .INIT = 16'hFCF8;
  LUT4 \vga/scancode_convert/scancode_rom/data<0>1104  (
    .I0(\vga/scancode_convert/sc [2]),
    .I1(\vga/scancode_convert/scancode_rom/data<0>1_map1443 ),
    .I2(\vga/scancode_convert/sc [5]),
    .I3(\vga/scancode_convert/scancode_rom/data<0>1_map1423 ),
    .O(\vga/scancode_convert/scancode_rom/data<0>1_map1445 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<5>3895 .INIT = 16'hB111;
  LUT4 \vga/scancode_convert/scancode_rom/data<5>3895  (
    .I0(\vga/scancode_convert/sc [6]),
    .I1(N3089),
    .I2(\vga/scancode_convert/scancode_rom/data<5>3_map1416 ),
    .I3(\vga/scancode_convert/scancode_rom/data<5>3_map1381 ),
    .O(\vga/scancode_convert/rom_data [5])
  );
  defparam \vga/scancode_convert/scancode_rom/data<6>1108 .INIT = 16'hFFAE;
  LUT4 \vga/scancode_convert/scancode_rom/data<6>1108  (
    .I0(\vga/scancode_convert/sc [1]),
    .I1(\vga/scancode_convert/sc [0]),
    .I2(\vga/scancode_convert/sc [3]),
    .I3(\vga/scancode_convert/sc [2]),
    .O(\vga/scancode_convert/scancode_rom/data<6>1_map1808 )
  );
  defparam \vga/scancode_convert/_cmp_eq0000_SW0_SW0 .INIT = 4'h7;
  LUT2 \vga/scancode_convert/_cmp_eq0000_SW0_SW0  (
    .I0(\vga/ps2/sc_r [7]),
    .I1(\vga/ps2/sc_r [5]),
    .O(N3100)
  );
  defparam \vga/scancode_convert/scancode_rom/data<4>182 .INIT = 16'hB111;
  LUT4 \vga/scancode_convert/scancode_rom/data<4>182  (
    .I0(\vga/scancode_convert/sc [2]),
    .I1(\vga/scancode_convert/scancode_rom/N25 ),
    .I2(\vga/scancode_convert/scancode_rom/data<4>1_map1556 ),
    .I3(\vga/scancode_convert/scancode_rom/data<4>1_map1548 ),
    .O(\vga/scancode_convert/scancode_rom/data<4>1_map1560 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<1>242 .INIT = 16'hFF8B;
  LUT4 \vga/scancode_convert/scancode_rom/data<1>242  (
    .I0(\vga/scancode_convert/scancode_rom/data<1>2_map1686 ),
    .I1(\vga/scancode_convert/sc [2]),
    .I2(\vga/scancode_convert/scancode_rom/N25 ),
    .I3(\vga/scancode_convert/sc [5]),
    .O(\vga/scancode_convert/scancode_rom/data<1>2_map1690 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<0>1569 .INIT = 16'h88D8;
  LUT4 \vga/scancode_convert/scancode_rom/data<0>1569  (
    .I0(\vga/scancode_convert/sc [6]),
    .I1(\vga/scancode_convert/scancode_rom/data<0>1_map1535 ),
    .I2(\vga/scancode_convert/scancode_rom/data<0>1_map1445 ),
    .I3(N3104),
    .O(\vga/scancode_convert/rom_data [0])
  );
  defparam \vga/scancode_convert/scancode_rom/data<1>2497 .INIT = 16'h88D8;
  LUT4 \vga/scancode_convert/scancode_rom/data<1>2497  (
    .I0(\vga/scancode_convert/sc [6]),
    .I1(\vga/scancode_convert/scancode_rom/data<1>2_map1780 ),
    .I2(\vga/scancode_convert/scancode_rom/data<1>2_map1690 ),
    .I3(N3106),
    .O(\vga/scancode_convert/rom_data [1])
  );
  defparam \vga/vgacore/vcnt_Eqn_bis_021_SW0 .INIT = 16'hFFFE;
  LUT4 \vga/vgacore/vcnt_Eqn_bis_021_SW0  (
    .I0(\vga/vgacore/vcnt [7]),
    .I1(\vga/vgacore/vcnt [6]),
    .I2(\vga/vgacore/vcnt [5]),
    .I3(\vga/vgacore/vcnt [4]),
    .O(N3108)
  );
  defparam \vga/vgacore/vcnt_Eqn_bis_021 .INIT = 16'h555D;
  LUT4 \vga/vgacore/vcnt_Eqn_bis_021  (
    .I0(\vga/vgacore/vcnt [9]),
    .I1(N3270),
    .I2(\vga/vgacore/vcnt [8]),
    .I3(N3108),
    .O(\vga/vgacore/vcnt_Eqn_bis_0 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<4>1620 .INIT = 16'hEF45;
  LUT4 \vga/scancode_convert/scancode_rom/data<4>1620  (
    .I0(\vga/scancode_convert/sc [2]),
    .I1(\vga/scancode_convert/scancode_rom/data<4>1_map1633 ),
    .I2(N3110),
    .I3(\vga/scancode_convert/scancode_rom/data<4>1_map1666 ),
    .O(\vga/scancode_convert/scancode_rom/data<4>1_map1669 )
  );
  MUXF5 \vga/scancode_convert/scancode_rom/data<3>1382  (
    .I0(N3116),
    .I1(N3117),
    .S(\vga/scancode_convert/sc [6]),
    .O(\vga/scancode_convert/rom_data [3])
  );
  defparam \vga/scancode_convert/scancode_rom/data<3>1382_F .INIT = 16'hE444;
  LUT4 \vga/scancode_convert/scancode_rom/data<3>1382_F  (
    .I0(\vga/scancode_convert/sc [5]),
    .I1(\vga/scancode_convert/scancode_rom/data<3>1_map1158 ),
    .I2(\vga/scancode_convert/scancode_rom/data<3>1_map1171 ),
    .I3(\vga/scancode_convert/scancode_rom/data<3>1_map1185 ),
    .O(N3116)
  );
  defparam \vga/scancode_convert/scancode_rom/data<3>1382_G .INIT = 16'hC888;
  LUT4 \vga/scancode_convert/scancode_rom/data<3>1382_G  (
    .I0(\vga/scancode_convert/sc [5]),
    .I1(\vga/scancode_convert/scancode_rom/data<3>1_map1229 ),
    .I2(\vga/scancode_convert/scancode_rom/data<3>1_map1201 ),
    .I3(\vga/scancode_convert/scancode_rom/data<3>1_map1221 ),
    .O(N3117)
  );
  MUXF5 \vga/scancode_convert/scancode_rom/data<4>1437  (
    .I0(N3118),
    .I1(N3119),
    .S(\vga/scancode_convert/raise ),
    .O(\vga/scancode_convert/scancode_rom/data<4>1_map1633 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<4>1437_F .INIT = 16'h8000;
  LUT4 \vga/scancode_convert/scancode_rom/data<4>1437_F  (
    .I0(\vga/scancode_convert/sc [3]),
    .I1(\vga/scancode_convert/sc [4]),
    .I2(\vga/scancode_convert/sc [1]),
    .I3(\vga/scancode_convert/sc [0]),
    .O(N3118)
  );
  defparam \vga/scancode_convert/scancode_rom/data<4>1437_G .INIT = 16'h8220;
  LUT4 \vga/scancode_convert/scancode_rom/data<4>1437_G  (
    .I0(\vga/scancode_convert/sc [3]),
    .I1(\vga/scancode_convert/sc [4]),
    .I2(\vga/scancode_convert/sc [1]),
    .I3(\vga/scancode_convert/sc [0]),
    .O(N3119)
  );
  MUXF5 \vga/scancode_convert/scancode_rom/data<4>1673  (
    .I0(N3120),
    .I1(N3121),
    .S(\vga/scancode_convert/sc [6]),
    .O(\vga/scancode_convert/rom_data [4])
  );
  defparam \vga/scancode_convert/scancode_rom/data<4>1673_F .INIT = 16'hE444;
  LUT4 \vga/scancode_convert/scancode_rom/data<4>1673_F  (
    .I0(\vga/scancode_convert/sc [5]),
    .I1(\vga/scancode_convert/scancode_rom/data<4>1_map1560 ),
    .I2(\vga/scancode_convert/scancode_rom/data<4>1_map1565 ),
    .I3(\vga/scancode_convert/scancode_rom/data<4>1_map1609 ),
    .O(N3120)
  );
  defparam \vga/scancode_convert/scancode_rom/data<4>1673_G .INIT = 8'hC8;
  LUT3 \vga/scancode_convert/scancode_rom/data<4>1673_G  (
    .I0(\vga/scancode_convert/scancode_rom/data<4>1_map1669 ),
    .I1(\vga/scancode_convert/scancode_rom/data<0>1_map1534 ),
    .I2(\vga/scancode_convert/sc [5]),
    .O(N3121)
  );
  defparam \vga/ps2/error_x13 .INIT = 16'hFF7E;
  LUT4 \vga/ps2/error_x13  (
    .I0(\vga/ps2/bitcnt_r [0]),
    .I1(\vga/ps2/bitcnt_r [3]),
    .I2(\vga/ps2/bitcnt_r [1]),
    .I3(\vga/ps2/bitcnt_r [2]),
    .O(\vga/ps2/error_x_map855 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<6>186_SW0 .INIT = 16'h02C8;
  LUT4 \vga/scancode_convert/scancode_rom/data<6>186_SW0  (
    .I0(\vga/scancode_convert/sc [3]),
    .I1(\vga/scancode_convert/sc [4]),
    .I2(\vga/scancode_convert/sc [0]),
    .I3(\vga/scancode_convert/sc [1]),
    .O(N3124)
  );
  defparam \vga/scancode_convert/scancode_rom/data<6>186 .INIT = 16'hFF8B;
  LUT4 \vga/scancode_convert/scancode_rom/data<6>186  (
    .I0(N3124),
    .I1(\vga/scancode_convert/sc [2]),
    .I2(N3269),
    .I3(\vga/scancode_convert/sc [5]),
    .O(\vga/scancode_convert/scancode_rom/data<6>1_map1803 )
  );
  defparam \vga/scancode_convert/_not00121 .INIT = 8'hEA;
  LUT3 \vga/scancode_convert/_not00121  (
    .I0(\vga/scancode_convert/state_FFd3_56 ),
    .I1(\vga/scancode_convert/_cmp_eq0005 ),
    .I2(\vga/scancode_convert/state_FFd1_53 ),
    .O(\vga/scancode_convert/_not0012 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<6>1333_SW0 .INIT = 8'h4E;
  LUT3 \vga/scancode_convert/scancode_rom/data<6>1333_SW0  (
    .I0(\vga/scancode_convert/sc [3]),
    .I1(\vga/scancode_convert/sc [4]),
    .I2(\vga/scancode_convert/sc [0]),
    .O(N3130)
  );
  defparam \vga/vgacore/_and000015_SW0 .INIT = 4'h1;
  LUT2 \vga/vgacore/_and000015_SW0  (
    .I0(\vga/vgacore/hcnt [6]),
    .I1(\vga/vgacore/hcnt [5]),
    .O(N3132)
  );
  defparam \vga/vgacore/_and000015 .INIT = 16'h4404;
  LUT4 \vga/vgacore/_and000015  (
    .I0(\vga/vgacore/hcnt [8]),
    .I1(\vga/vgacore/hcnt [7]),
    .I2(N3132),
    .I3(\vga/vgacore/_and0000_map807 ),
    .O(\vga/vgacore/_and0000_map811 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<5>3852_SW1 .INIT = 16'hDDB1;
  LUT4 \vga/scancode_convert/scancode_rom/data<5>3852_SW1  (
    .I0(\vga/scancode_convert/sc [1]),
    .I1(\vga/scancode_convert/sc [0]),
    .I2(\vga/scancode_convert/raise ),
    .I3(\vga/scancode_convert/sc [4]),
    .O(N3136)
  );
  defparam \vga/scancode_convert/scancode_rom/data<5>3852 .INIT = 16'h1113;
  LUT4 \vga/scancode_convert/scancode_rom/data<5>3852  (
    .I0(N3087),
    .I1(\vga/scancode_convert/sc [5]),
    .I2(\vga/scancode_convert/sc [3]),
    .I3(N3136),
    .O(\vga/scancode_convert/scancode_rom/data<5>3_map1416 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<2>1180_SW0 .INIT = 16'hE437;
  LUT4 \vga/scancode_convert/scancode_rom/data<2>1180_SW0  (
    .I0(\vga/scancode_convert/sc [3]),
    .I1(\vga/scancode_convert/sc [1]),
    .I2(\vga/scancode_convert/sc [0]),
    .I3(\vga/scancode_convert/sc [2]),
    .O(N3141)
  );
  defparam \vga/scancode_convert/scancode_rom/data<2>1180_SW1 .INIT = 16'hDE87;
  LUT4 \vga/scancode_convert/scancode_rom/data<2>1180_SW1  (
    .I0(\vga/scancode_convert/sc [3]),
    .I1(\vga/scancode_convert/sc [1]),
    .I2(\vga/scancode_convert/sc [2]),
    .I3(\vga/scancode_convert/sc [0]),
    .O(N3142)
  );
  defparam \vga/crt/state_FFd3-In48 .INIT = 8'hAE;
  LUT3 \vga/crt/state_FFd3-In48  (
    .I0(N3144),
    .I1(\vga/crt/state_FFd3-In_map800 ),
    .I2(\vga/crt/state_FFd3_42 ),
    .O(\vga/crt/state_FFd3-In )
  );
  defparam \vga/vgacore/_and000074 .INIT = 16'h4440;
  LUT4 \vga/vgacore/_and000074  (
    .I0(\vga/vgacore/hcnt [10]),
    .I1(\vga/vgacore/hcnt [9]),
    .I2(\vga/vgacore/_and0000_map811 ),
    .I3(\vga/vgacore/_and0000_map825 ),
    .O(\vga/vgacore/_and0000 )
  );
  defparam \vga/rom_addr_char<1>6_SW0 .INIT = 16'hC22F;
  LUT4 \vga/rom_addr_char<1>6_SW0  (
    .I0(\vga/vgacore/vcnt_0_1_96 ),
    .I1(\vga/rom_addr_char_1_1_95 ),
    .I2(\vga/vgacore/vcnt_2_1_98 ),
    .I3(\vga/rom_addr_char_0_1_94 ),
    .O(N3146)
  );
  defparam \vga/rom_addr_char<1>6 .INIT = 4'h1;
  LUT2 \vga/rom_addr_char<1>6  (
    .I0(\vga/vgacore/vcnt_1_1_97 ),
    .I1(N3146),
    .O(\vga/N612 )
  );
  defparam \vga/rom_addr_char<1>43 .INIT = 16'h2CC9;
  LUT4 \vga/rom_addr_char<1>43  (
    .I0(\vga/rom_addr_char_1_1_95 ),
    .I1(\vga/vgacore/vcnt_1_1_97 ),
    .I2(\vga/vgacore/vcnt_0_1_96 ),
    .I3(\vga/vgacore/vcnt_2_1_98 ),
    .O(\vga/N312345 )
  );
  defparam \vga/rom_addr_char<1>104_SW0 .INIT = 8'hC4;
  LUT3 \vga/rom_addr_char<1>104_SW0  (
    .I0(\vga/rom_addr_char_0_1_94 ),
    .I1(\vga/rom_addr_char [1]),
    .I2(\vga/vgacore/vcnt_0_1_96 ),
    .O(N3148)
  );
  defparam \vga/rom_addr_char<1>104 .INIT = 16'h4602;
  LUT4 \vga/rom_addr_char<1>104  (
    .I0(\vga/vgacore/vcnt_2_1_98 ),
    .I1(\vga/vgacore/vcnt_1_1_97 ),
    .I2(N3148),
    .I3(\vga/vgacore/vcnt_0_1_96 ),
    .O(\vga/N1012345 )
  );
  defparam \vga/charload8_SW0 .INIT = 16'h4602;
  LUT4 \vga/charload8_SW0  (
    .I0(\vga/rom_addr_char [6]),
    .I1(\vga/rom_addr_char [5]),
    .I2(N3150),
    .I3(\vga/rom_addr_char<4>11234 ),
    .O(N562)
  );
  defparam \vga/Madd_ram_addr_video_Madd_lut<7> .INIT = 8'h96;
  LUT3 \vga/Madd_ram_addr_video_Madd_lut<7>  (
    .I0(\vga/Madd_ram_addr_videoC2 ),
    .I1(\vga/vgacore/vcnt [4]),
    .I2(\vga/vgacore/vcnt [6]),
    .O(\vga/N230 )
  );
  defparam \vga/Madd_ram_addr_video_Madd_lut<10> .INIT = 8'h6C;
  LUT3 \vga/Madd_ram_addr_video_Madd_lut<10>  (
    .I0(\vga/vgacore/vcnt [6]),
    .I1(\vga/vgacore/vcnt [7]),
    .I2(\vga/vgacore/vcnt [8]),
    .O(\vga/N233 )
  );
  defparam \vga/crt/Madd_ram_addr_Madd_lut<7> .INIT = 8'h96;
  LUT3 \vga/crt/Madd_ram_addr_Madd_lut<7>  (
    .I0(\vga/crt/Madd_ram_addrC2 ),
    .I1(\vga/crt/cursor_v [1]),
    .I2(\vga/crt/cursor_v [3]),
    .O(\vga/crt/N9 )
  );
  defparam \vga/crt/Madd_ram_addr_Madd_lut<10> .INIT = 8'h6C;
  LUT3 \vga/crt/Madd_ram_addr_Madd_lut<10>  (
    .I0(\vga/crt/cursor_v [3]),
    .I1(\vga/crt/cursor_v [4]),
    .I2(\vga/crt/cursor_v [5]),
    .O(\vga/crt/N12 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<0>1123 .INIT = 16'hAAAE;
  LUT4 \vga/scancode_convert/scancode_rom/data<0>1123  (
    .I0(\vga/scancode_convert/sc [3]),
    .I1(\vga/scancode_convert/sc [0]),
    .I2(\vga/scancode_convert/sc [4]),
    .I3(\vga/scancode_convert/sc [1]),
    .O(\vga/scancode_convert/scancode_rom/data<0>1_map1449 )
  );
  defparam \vga/ps2/scancode_rdy1 .INIT = 8'h80;
  LUT3 \vga/ps2/scancode_rdy1  (
    .I0(\vga/ps2/_cmp_eq0000 ),
    .I1(\vga/ps2/_cmp_eq0001 ),
    .I2(\vga/ps2/ps2_clk_r [1]),
    .O(\vga/ps2/scancode_rdy )
  );
  defparam \vga/scancode_convert/scancode_rom/data<4>1118 .INIT = 16'hAAAE;
  LUT4 \vga/scancode_convert/scancode_rom/data<4>1118  (
    .I0(\vga/scancode_convert/sc [2]),
    .I1(\vga/scancode_convert/sc [1]),
    .I2(\vga/scancode_convert/sc [4]),
    .I3(\vga/scancode_convert/sc [0]),
    .O(\vga/scancode_convert/scancode_rom/data<4>1_map1565 )
  );
  defparam \vga/scancode_convert/shift_set14 .INIT = 8'h08;
  LUT3 \vga/scancode_convert/shift_set14  (
    .I0(\vga/scancode_convert/state_FFd5_54 ),
    .I1(\vga/ps2/rdy_r_8 ),
    .I2(\vga/scancode_convert/release_prefix_59 ),
    .O(\vga/scancode_convert/shift_set_map836 )
  );
  defparam \vga/crt/write_delay__mux0000<0>1 .INIT = 16'h0002;
  LUT4 \vga/crt/write_delay__mux0000<0>1  (
    .I0(\vga/crt/state_FFd1_40 ),
    .I1(\vga/crt/write_delay [0]),
    .I2(\vga/crt/state_FFd3_42 ),
    .I3(\vga/crt/state_FFd2_41 ),
    .O(\vga/crt/write_delay__mux0000 [0])
  );
  defparam \vga/crt/_mux0002<0>1 .INIT = 16'hEC4C;
  LUT4 \vga/crt/_mux0002<0>1  (
    .I0(\vga/crt/state_FFd2_41 ),
    .I1(\vga/crt/cursor_h [0]),
    .I2(\vga/crt/state_FFd3_42 ),
    .I3(\vga/crt_data [0]),
    .O(\vga/crt/_mux0002 [0])
  );
  defparam \vga/crt/_mux0002<1>1 .INIT = 16'hEC4C;
  LUT4 \vga/crt/_mux0002<1>1  (
    .I0(\vga/crt/state_FFd2_41 ),
    .I1(\vga/crt/cursor_h [1]),
    .I2(\vga/crt/state_FFd3_42 ),
    .I3(\vga/crt_data [1]),
    .O(\vga/crt/_mux0002 [1])
  );
  defparam \vga/crt/_mux0002<2>1 .INIT = 16'hEC4C;
  LUT4 \vga/crt/_mux0002<2>1  (
    .I0(\vga/crt/state_FFd2_41 ),
    .I1(\vga/crt/cursor_h [2]),
    .I2(\vga/crt/state_FFd3_42 ),
    .I3(\vga/crt_data [2]),
    .O(\vga/crt/_mux0002 [2])
  );
  defparam \vga/crt/_mux0002<4>1 .INIT = 16'hEC4C;
  LUT4 \vga/crt/_mux0002<4>1  (
    .I0(\vga/crt/state_FFd2_41 ),
    .I1(\vga/crt/cursor_h [4]),
    .I2(\vga/crt/state_FFd3_42 ),
    .I3(\vga/crt_data [4]),
    .O(\vga/crt/_mux0002 [4])
  );
  defparam \vga/crt/_mux0002<3>1 .INIT = 16'hEC4C;
  LUT4 \vga/crt/_mux0002<3>1  (
    .I0(\vga/crt/state_FFd2_41 ),
    .I1(\vga/crt/cursor_h [3]),
    .I2(\vga/crt/state_FFd3_42 ),
    .I3(\vga/crt_data [3]),
    .O(\vga/crt/_mux0002 [3])
  );
  defparam \vga/crt/_mux0002<5>1 .INIT = 16'hB313;
  LUT4 \vga/crt/_mux0002<5>1  (
    .I0(\vga/crt/state_FFd3_42 ),
    .I1(\vga/crt/cursor_h [5]),
    .I2(\vga/crt/state_FFd2_41 ),
    .I3(\vga/crt_data [5]),
    .O(\vga/crt/_mux0002 [5])
  );
  defparam \vga/scancode_convert/scancode_rom/data<0>1469 .INIT = 16'h5557;
  LUT4 \vga/scancode_convert/scancode_rom/data<0>1469  (
    .I0(\vga/scancode_convert/sc [3]),
    .I1(\vga/scancode_convert/sc [4]),
    .I2(\vga/scancode_convert/sc [0]),
    .I3(N3273),
    .O(\vga/scancode_convert/scancode_rom/data<0>1_map1526 )
  );
  defparam \vga/scancode_convert/ctrl_set_SW1 .INIT = 8'hF7;
  LUT3 \vga/scancode_convert/ctrl_set_SW1  (
    .I0(\vga/scancode_convert/state_FFd5_54 ),
    .I1(\vga/ps2/rdy_r_8 ),
    .I2(\vga/scancode_convert/release_prefix_59 ),
    .O(N3158)
  );
  defparam \vga/scancode_convert/ctrl_set .INIT = 16'h0020;
  LUT4 \vga/scancode_convert/ctrl_set  (
    .I0(\vga/ps2/sc_r [2]),
    .I1(\vga/ps2/sc_r [1]),
    .I2(\vga/scancode_convert/N10 ),
    .I3(N3158),
    .O(\vga/scancode_convert/ctrl_set_58 )
  );
  defparam \vga/crt/cursor_h_Eqn_01 .INIT = 4'h1;
  LUT2 \vga/crt/cursor_h_Eqn_01  (
    .I0(\vga/crt/_and0000_38 ),
    .I1(\vga/crt/cursor_h [0]),
    .O(\vga/crt/cursor_h_Eqn_0 )
  );
  defparam \vga/crt/cursor_v_Eqn_01 .INIT = 4'h1;
  LUT2 \vga/crt/cursor_v_Eqn_01  (
    .I0(\vga/crt/_and0001_39 ),
    .I1(\vga/crt/cursor_v [0]),
    .O(\vga/crt/cursor_v_Eqn_0 )
  );
  defparam \vga/scancode_convert/state_FFd4-In34 .INIT = 16'hFFEA;
  LUT4 \vga/scancode_convert/state_FFd4-In34  (
    .I0(\vga/scancode_convert/state_FFd2_52 ),
    .I1(\vga/scancode_convert/_and0000 ),
    .I2(\vga/scancode_convert/state_FFd4-In_map845 ),
    .I3(\vga/scancode_convert/state_FFd3_56 ),
    .O(\vga/scancode_convert/state_FFd4-In )
  );
  defparam \vga/scancode_convert/_not00101 .INIT = 16'hEAAA;
  LUT4 \vga/scancode_convert/_not00101  (
    .I0(\vga/scancode_convert/state_FFd4_50 ),
    .I1(N3275),
    .I2(\vga/ps2/rdy_r_8 ),
    .I3(\vga/scancode_convert/state_FFd5_54 ),
    .O(\vga/scancode_convert/_not0010 )
  );
  defparam \vga/scancode_convert/release_prefix_set1 .INIT = 8'h80;
  LUT3 \vga/scancode_convert/release_prefix_set1  (
    .I0(\vga/scancode_convert/_cmp_eq0000_51 ),
    .I1(\vga/ps2/rdy_r_8 ),
    .I2(\vga/scancode_convert/state_FFd5_54 ),
    .O(\vga/scancode_convert/release_prefix_set )
  );
  defparam \vga/ps2/timer_x<0>1 .INIT = 4'h1;
  LUT2 \vga/ps2/timer_x<0>1  (
    .I0(\vga/ps2/ps2_clk_edge ),
    .I1(\vga/ps2/timer_r [0]),
    .O(\vga/ps2/timer_x [0])
  );
  defparam \vga/pclk__mux0000<0>1 .INIT = 16'hDDFD;
  LUT4 \vga/pclk__mux0000<0>1  (
    .I0(\vga/pclk [0]),
    .I1(\vga/vgacore/hblank_12 ),
    .I2(\vga/crt/N91 ),
    .I3(\vga/crt/state_FFd1_40 ),
    .O(\vga/pclk__mux0000 [0])
  );
  defparam \vga/rom_addr_char<1>121_SW0 .INIT = 16'hBFF9;
  LUT4 \vga/rom_addr_char<1>121_SW0  (
    .I0(\vga/rom_addr_char [1]),
    .I1(\vga/rom_addr_char_0_1_94 ),
    .I2(\vga/vgacore/vcnt_2_1_98 ),
    .I3(\vga/vgacore/vcnt_1_1_97 ),
    .O(N3160)
  );
  defparam \vga/rom_addr_char<1>121 .INIT = 4'h1;
  LUT2 \vga/rom_addr_char<1>121  (
    .I0(\vga/vgacore/vcnt_0_1_96 ),
    .I1(N3160),
    .O(\vga/N1212 )
  );
  defparam \vga/rom_addr_char<2>15_SW0 .INIT = 16'hA877;
  LUT4 \vga/rom_addr_char<2>15_SW0  (
    .I0(\vga/vgacore/vcnt_1_1_97 ),
    .I1(\vga/vgacore/vcnt_0_1_96 ),
    .I2(\vga/rom_addr_char_1_1_95 ),
    .I3(\vga/vgacore/vcnt_2_1_98 ),
    .O(N3162)
  );
  defparam \vga/rom_addr_char<2>15 .INIT = 8'h08;
  LUT3 \vga/rom_addr_char<2>15  (
    .I0(\vga/rom_addr_char [2]),
    .I1(\vga/rom_addr_char_0_1_94 ),
    .I2(N3162),
    .O(\vga/rom_addr_char<2>2 )
  );
  defparam \vga/rom_addr_char<2>2_SW0 .INIT = 16'hFDBD;
  LUT4 \vga/rom_addr_char<2>2_SW0  (
    .I0(\vga/rom_addr_char_1_1_95 ),
    .I1(\vga/vgacore/vcnt_0_1_96 ),
    .I2(\vga/rom_addr_char_0_1_94 ),
    .I3(\vga/vgacore/vcnt_1_1_97 ),
    .O(N3164)
  );
  defparam \vga/rom_addr_char<1>114_SW0 .INIT = 16'hE878;
  LUT4 \vga/rom_addr_char<1>114_SW0  (
    .I0(\vga/vgacore/vcnt_0_1_96 ),
    .I1(\vga/vgacore/vcnt_2_1_98 ),
    .I2(\vga/rom_addr_char [1]),
    .I3(\vga/vgacore/vcnt_1_1_97 ),
    .O(N3166)
  );
  defparam \vga/rom_addr_char<1>114 .INIT = 4'h4;
  LUT2 \vga/rom_addr_char<1>114  (
    .I0(N3166),
    .I1(\vga/rom_addr_char_0_1_94 ),
    .O(\vga/N11123456 )
  );
  defparam \vga/rom_addr_char<1>113_SW0 .INIT = 8'hC8;
  LUT3 \vga/rom_addr_char<1>113_SW0  (
    .I0(\vga/vgacore/vcnt_2_1_98 ),
    .I1(\vga/rom_addr_char_0_1_94 ),
    .I2(\vga/vgacore/vcnt_1_1_97 ),
    .O(N3170)
  );
  defparam \vga/rom_addr_char<1>113 .INIT = 16'h5410;
  LUT4 \vga/rom_addr_char<1>113  (
    .I0(\vga/vgacore/vcnt_0_1_96 ),
    .I1(\vga/rom_addr_char [1]),
    .I2(N3170),
    .I3(\vga/vgacore/vcnt_1_1_97 ),
    .O(\vga/N111123 )
  );
  defparam \vga/rom_addr_char<1>152_SW0 .INIT = 8'h1B;
  LUT3 \vga/rom_addr_char<1>152_SW0  (
    .I0(\vga/rom_addr_char [1]),
    .I1(\vga/vgacore/vcnt_1_1_97 ),
    .I2(\vga/rom_addr_char_0_1_94 ),
    .O(N3172)
  );
  defparam \vga/rom_addr_char<1>152 .INIT = 16'h040E;
  LUT4 \vga/rom_addr_char<1>152  (
    .I0(\vga/vgacore/vcnt_2_1_98 ),
    .I1(\vga/vgacore/vcnt_1_1_97 ),
    .I2(\vga/vgacore/vcnt_0_1_96 ),
    .I3(N3172),
    .O(\vga/N15123 )
  );
  defparam \vga/write_ctrl .INIT = 8'h14;
  LUT3 \vga/write_ctrl  (
    .I0(\vga/crt/state_FFd2_41 ),
    .I1(\vga/crt/state_FFd1_40 ),
    .I2(\vga/crt/state_FFd3_42 ),
    .O(\vga/N226 )
  );
  defparam \vga/rom_addr_char<1>111 .INIT = 16'h5D08;
  LUT4 \vga/rom_addr_char<1>111  (
    .I0(\vga/rom_addr_char [1]),
    .I1(\vga/vgacore/vcnt_1_1_97 ),
    .I2(\vga/vgacore/vcnt_0_1_96 ),
    .I3(\vga/N167 ),
    .O(\vga/N11112 )
  );
  defparam \vga/rom_addr_char<1>151 .INIT = 16'h88D8;
  LUT4 \vga/rom_addr_char<1>151  (
    .I0(\vga/rom_addr_char [1]),
    .I1(\vga/N175 ),
    .I2(\vga/vgacore/vcnt_1_1_97 ),
    .I3(\vga/vgacore/vcnt_0_1_96 ),
    .O(\vga/N1512 )
  );
  defparam \vga/rom_addr_char<1>103 .INIT = 16'h5D08;
  LUT4 \vga/rom_addr_char<1>103  (
    .I0(\vga/rom_addr_char [1]),
    .I1(\vga/vgacore/vcnt_1_1_97 ),
    .I2(\vga/vgacore/vcnt_0_1_96 ),
    .I3(\vga/N121 ),
    .O(\vga/N9123 )
  );
  defparam \vga/rom_addr_char<1>143 .INIT = 16'h88D8;
  LUT4 \vga/rom_addr_char<1>143  (
    .I0(\vga/rom_addr_char [1]),
    .I1(\vga/N78 ),
    .I2(\vga/vgacore/vcnt_1_1_97 ),
    .I3(\vga/vgacore/vcnt_0_1_96 ),
    .O(\vga/N131234 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<4>1308_SW0 .INIT = 8'h89;
  LUT3 \vga/scancode_convert/scancode_rom/data<4>1308_SW0  (
    .I0(\vga/scancode_convert/sc [0]),
    .I1(\vga/scancode_convert/sc [1]),
    .I2(\vga/scancode_convert/sc [3]),
    .O(N3174)
  );
  defparam \vga/scancode_convert/scancode_rom/data<4>1308 .INIT = 16'h1FBF;
  LUT4 \vga/scancode_convert/scancode_rom/data<4>1308  (
    .I0(\vga/scancode_convert/raise ),
    .I1(N3174),
    .I2(\vga/scancode_convert/sc [2]),
    .I3(N3175),
    .O(\vga/scancode_convert/scancode_rom/data<4>1_map1609 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<0>1370_SW2 .INIT = 16'h90D0;
  LUT4 \vga/scancode_convert/scancode_rom/data<0>1370_SW2  (
    .I0(\vga/scancode_convert/sc [4]),
    .I1(\vga/scancode_convert/sc [3]),
    .I2(\vga/scancode_convert/sc [1]),
    .I3(\vga/scancode_convert/sc [0]),
    .O(N3178)
  );
  defparam \vga/scancode_convert/scancode_rom/data<0>1370 .INIT = 16'hFFD8;
  LUT4 \vga/scancode_convert/scancode_rom/data<0>1370  (
    .I0(\vga/scancode_convert/scancode_rom/N12 ),
    .I1(N3178),
    .I2(N3177),
    .I3(\vga/scancode_convert/sc [2]),
    .O(\vga/scancode_convert/scancode_rom/data<0>1_map1503 )
  );
  defparam \vga/ps2/error_x24 .INIT = 16'hFF8C;
  LUT4 \vga/ps2/error_x24  (
    .I0(\vga/ps2/error_x_map855 ),
    .I1(\vga/ps2/_cmp_eq0001 ),
    .I2(\vga/ps2/ps2_clk_r [1]),
    .I3(\vga/ps2/error_r_47 ),
    .O(\vga/ps2/error_x )
  );
  defparam \vga/scancode_convert/scancode_rom/data<3>126 .INIT = 16'h0602;
  LUT4 \vga/scancode_convert/scancode_rom/data<3>126  (
    .I0(\vga/scancode_convert/sc [4]),
    .I1(\vga/scancode_convert/sc [2]),
    .I2(N3180),
    .I3(\vga/scancode_convert/raise ),
    .O(\vga/scancode_convert/scancode_rom/data<3>1_map1158 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<2>1354 .INIT = 16'h88A8;
  LUT4 \vga/scancode_convert/scancode_rom/data<2>1354  (
    .I0(\vga/scancode_convert/sc [3]),
    .I1(\vga/scancode_convert/sc [1]),
    .I2(\vga/scancode_convert/sc [0]),
    .I3(\vga/scancode_convert/sc [4]),
    .O(\vga/scancode_convert/scancode_rom/data<2>1_map1129 )
  );
  defparam \vga/crt/_not00101 .INIT = 16'h9888;
  LUT4 \vga/crt/_not00101  (
    .I0(\vga/crt/state_FFd2_41 ),
    .I1(\vga/crt/state_FFd3_42 ),
    .I2(\vga/crt/eol_35 ),
    .I3(\vga/crt/state_FFd1_40 ),
    .O(\vga/crt/_not0010 )
  );
  defparam \vga/crt/Mrom_set_newline1 .INIT = 16'h0020;
  LUT4 \vga/crt/Mrom_set_newline1  (
    .I0(\vga/crt/eol_35 ),
    .I1(\vga/crt/state_FFd3_42 ),
    .I2(\vga/crt/state_FFd1_40 ),
    .I3(\vga/crt/state_FFd2_41 ),
    .O(\vga/crt/N3 )
  );
  defparam \vga/pclk__mux0000<2>_SW0 .INIT = 16'hFF13;
  LUT4 \vga/pclk__mux0000<2>_SW0  (
    .I0(\vga/crt/state_FFd3_42 ),
    .I1(\vga/crt/state_FFd1_40 ),
    .I2(\vga/crt/state_FFd2_41 ),
    .I3(\vga/vgacore/hblank_12 ),
    .O(N89)
  );
  defparam \vga/crt/state_Out92 .INIT = 8'h15;
  LUT3 \vga/crt/state_Out92  (
    .I0(\vga/crt/state_FFd1_40 ),
    .I1(\vga/crt/state_FFd2_41 ),
    .I2(\vga/crt/state_FFd3_42 ),
    .O(\vga/clearing )
  );
  FDE \vga/scancode_convert/sc_1_1  (
    .D(\vga/ps2/sc_r [1]),
    .CE(\vga/scancode_convert/_and0000 ),
    .C(gray_cnt_FFd1_9),
    .Q(\vga/scancode_convert/sc_1_1_91 )
  );
  FDE \vga/scancode_convert/sc_0_1  (
    .D(\vga/ps2/sc_r [0]),
    .CE(\vga/scancode_convert/_and0000 ),
    .C(gray_cnt_FFd1_9),
    .Q(\vga/scancode_convert/sc_0_1_93 )
  );
  MUXF5 \vga/scancode_convert/scancode_rom/data<1>2260_SW0  (
    .I0(N3184),
    .I1(N3185),
    .S(\vga/scancode_convert/sc [2]),
    .O(N3106)
  );
  defparam \vga/scancode_convert/scancode_rom/data<1>2260_SW0_F .INIT = 8'h04;
  LUT3 \vga/scancode_convert/scancode_rom/data<1>2260_SW0_F  (
    .I0(\vga/scancode_convert/scancode_rom/data<1>2_map1701 ),
    .I1(\vga/scancode_convert/sc [5]),
    .I2(\vga/scancode_convert/scancode_rom/data<1>2_map1708 ),
    .O(N3184)
  );
  defparam \vga/scancode_convert/scancode_rom/data<1>2260_SW0_G .INIT = 16'h22A2;
  LUT4 \vga/scancode_convert/scancode_rom/data<1>2260_SW0_G  (
    .I0(\vga/scancode_convert/sc [5]),
    .I1(\vga/scancode_convert/scancode_rom/data<1>2_map1717 ),
    .I2(\vga/scancode_convert/sc [3]),
    .I3(\vga/scancode_convert/scancode_rom/data<1>2_map1729 ),
    .O(N3185)
  );
  MUXF5 \vga/scancode_convert/scancode_rom/data<1>2416  (
    .I0(N3186),
    .I1(N3187),
    .S(\vga/scancode_convert/sc [0]),
    .O(\vga/scancode_convert/scancode_rom/data<1>2_map1774 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<1>2416_F .INIT = 16'h15FF;
  LUT4 \vga/scancode_convert/scancode_rom/data<1>2416_F  (
    .I0(\vga/scancode_convert/sc [1]),
    .I1(\vga/scancode_convert/sc [3]),
    .I2(\vga/scancode_convert/sc [4]),
    .I3(\vga/scancode_convert/sc [2]),
    .O(N3186)
  );
  defparam \vga/scancode_convert/scancode_rom/data<1>2416_G .INIT = 16'h55D5;
  LUT4 \vga/scancode_convert/scancode_rom/data<1>2416_G  (
    .I0(\vga/scancode_convert/sc [2]),
    .I1(\vga/scancode_convert/scancode_rom/N9 ),
    .I2(\vga/scancode_convert/sc [4]),
    .I3(\vga/scancode_convert/sc [3]),
    .O(N3187)
  );
  MUXF5 \vga/scancode_convert/scancode_rom/data<0>1291_SW0  (
    .I0(N3188),
    .I1(N3189),
    .S(\vga/scancode_convert/sc [2]),
    .O(N3104)
  );
  defparam \vga/scancode_convert/scancode_rom/data<0>1291_SW0_F .INIT = 16'hA222;
  LUT4 \vga/scancode_convert/scancode_rom/data<0>1291_SW0_F  (
    .I0(\vga/scancode_convert/sc [5]),
    .I1(\vga/scancode_convert/scancode_rom/data<0>1_map1449 ),
    .I2(\vga/scancode_convert/sc [3]),
    .I3(\vga/scancode_convert/scancode_rom/N7 ),
    .O(N3188)
  );
  defparam \vga/scancode_convert/scancode_rom/data<0>1291_SW0_G .INIT = 16'h22A2;
  LUT4 \vga/scancode_convert/scancode_rom/data<0>1291_SW0_G  (
    .I0(\vga/scancode_convert/sc [5]),
    .I1(\vga/scancode_convert/scancode_rom/data<0>1_map1461 ),
    .I2(\vga/scancode_convert/sc [3]),
    .I3(\vga/scancode_convert/scancode_rom/data<0>1_map1475 ),
    .O(N3189)
  );
  MUXF5 \vga/scancode_convert/scancode_rom/data<3>1299  (
    .I0(N3190),
    .I1(N3191),
    .S(\vga/scancode_convert/sc [4]),
    .O(\vga/scancode_convert/scancode_rom/data<3>1_map1221 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<3>1299_F .INIT = 16'h2FFF;
  LUT4 \vga/scancode_convert/scancode_rom/data<3>1299_F  (
    .I0(\vga/scancode_convert/scancode_rom/N9 ),
    .I1(\vga/scancode_convert/sc [3]),
    .I2(\vga/scancode_convert/sc [0]),
    .I3(\vga/scancode_convert/sc [2]),
    .O(N3190)
  );
  defparam \vga/scancode_convert/scancode_rom/data<3>1299_G .INIT = 16'h4F5F;
  LUT4 \vga/scancode_convert/scancode_rom/data<3>1299_G  (
    .I0(\vga/scancode_convert/sc [1]),
    .I1(\vga/scancode_convert/sc [0]),
    .I2(\vga/scancode_convert/sc [2]),
    .I3(\vga/scancode_convert/sc [3]),
    .O(N3191)
  );
  MUXF5 \vga/charload1_SW0  (
    .I0(N3192),
    .I1(N3193),
    .S(\vga/rom_addr_char [6]),
    .O(N560)
  );
  defparam \vga/charload1_SW0_F .INIT = 16'hE040;
  LUT4 \vga/charload1_SW0_F  (
    .I0(\vga/rom_addr_char [4]),
    .I1(\vga/rom_addr_char<3>_f6_19 ),
    .I2(\vga/rom_addr_char [5]),
    .I3(\vga/rom_addr_char<3>_f61_22 ),
    .O(N3192)
  );
  defparam \vga/charload1_SW0_G .INIT = 8'hE4;
  LUT3 \vga/charload1_SW0_G  (
    .I0(\vga/rom_addr_char [5]),
    .I1(\vga/rom_addr_char<4>11_26 ),
    .I2(\vga/rom_addr_char<4>_f5_28 ),
    .O(N3193)
  );
  MUXF5 \vga/rom_addr_char<1>1641  (
    .I0(N3194),
    .I1(N3195),
    .S(\vga/vgacore/vcnt_1_1_97 ),
    .O(\vga/rom_addr_char<1>112_32 )
  );
  defparam \vga/rom_addr_char<1>1641_F .INIT = 8'hB9;
  LUT3 \vga/rom_addr_char<1>1641_F  (
    .I0(\vga/rom_addr_char [1]),
    .I1(\vga/rom_addr_char_0_1_94 ),
    .I2(\vga/vgacore/vcnt_2_1_98 ),
    .O(N3194)
  );
  defparam \vga/rom_addr_char<1>1641_G .INIT = 16'h0999;
  LUT4 \vga/rom_addr_char<1>1641_G  (
    .I0(\vga/rom_addr_char [1]),
    .I1(\vga/rom_addr_char_0_1_94 ),
    .I2(\vga/vgacore/vcnt_0_1_96 ),
    .I3(\vga/vgacore/vcnt_2_1_98 ),
    .O(N3195)
  );
  MUXF5 \vga/rom_addr_char<1>1741  (
    .I0(N3196),
    .I1(N3197),
    .S(\vga/vgacore/vcnt_2_1_98 ),
    .O(\vga/rom_addr_char<1>2_33 )
  );
  defparam \vga/rom_addr_char<1>1741_F .INIT = 16'hFFAE;
  LUT4 \vga/rom_addr_char<1>1741_F  (
    .I0(\vga/vgacore/vcnt_1_1_97 ),
    .I1(\vga/rom_addr_char [1]),
    .I2(\vga/rom_addr_char_0_1_94 ),
    .I3(\vga/vgacore/vcnt_0_1_96 ),
    .O(N3196)
  );
  defparam \vga/rom_addr_char<1>1741_G .INIT = 16'h06FF;
  LUT4 \vga/rom_addr_char<1>1741_G  (
    .I0(\vga/rom_addr_char [1]),
    .I1(\vga/rom_addr_char_0_1_94 ),
    .I2(\vga/vgacore/vcnt_0_1_96 ),
    .I3(\vga/vgacore/vcnt_1_1_97 ),
    .O(N3197)
  );
  MUXF5 \vga/scancode_convert/scancode_rom/data<6>1201_SW0  (
    .I0(N3198),
    .I1(N3199),
    .S(\vga/scancode_convert/sc [3]),
    .O(N3084)
  );
  defparam \vga/scancode_convert/scancode_rom/data<6>1201_SW0_F .INIT = 16'h3F2F;
  LUT4 \vga/scancode_convert/scancode_rom/data<6>1201_SW0_F  (
    .I0(\vga/scancode_convert/sc [1]),
    .I1(\vga/scancode_convert/sc [2]),
    .I2(\vga/scancode_convert/sc [5]),
    .I3(\vga/scancode_convert/sc [0]),
    .O(N3198)
  );
  defparam \vga/scancode_convert/scancode_rom/data<6>1201_SW0_G .INIT = 16'hF7D5;
  LUT4 \vga/scancode_convert/scancode_rom/data<6>1201_SW0_G  (
    .I0(\vga/scancode_convert/sc [5]),
    .I1(\vga/scancode_convert/sc [2]),
    .I2(\vga/scancode_convert/scancode_rom/data<6>1_map1831 ),
    .I3(\vga/scancode_convert/sc [1]),
    .O(N3199)
  );
  MUXF5 \vga/scancode_convert/scancode_rom/data<2>1207  (
    .I0(N3200),
    .I1(N3201),
    .S(\vga/scancode_convert/sc [5]),
    .O(\vga/scancode_convert/scancode_rom/data<2>1_map1098 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<2>1207_F .INIT = 8'hC4;
  LUT3 \vga/scancode_convert/scancode_rom/data<2>1207_F  (
    .I0(\vga/scancode_convert/scancode_rom/N28 ),
    .I1(\vga/scancode_convert/scancode_rom/data<2>1_map1056 ),
    .I2(\vga/scancode_convert/sc [4]),
    .O(N3200)
  );
  defparam \vga/scancode_convert/scancode_rom/data<2>1207_G .INIT = 8'h1B;
  LUT3 \vga/scancode_convert/scancode_rom/data<2>1207_G  (
    .I0(\vga/scancode_convert/sc [4]),
    .I1(N3141),
    .I2(N3142),
    .O(N3201)
  );
  MUXF5 \vga/scancode_convert/scancode_rom/data<4>1588  (
    .I0(N3202),
    .I1(N3203),
    .S(\vga/scancode_convert/raise ),
    .O(\vga/scancode_convert/scancode_rom/data<4>1_map1666 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<4>1588_F .INIT = 16'h0F16;
  LUT4 \vga/scancode_convert/scancode_rom/data<4>1588_F  (
    .I0(\vga/scancode_convert/sc [4]),
    .I1(\vga/scancode_convert/sc [3]),
    .I2(\vga/scancode_convert/sc [1]),
    .I3(\vga/scancode_convert/sc [0]),
    .O(N3202)
  );
  defparam \vga/scancode_convert/scancode_rom/data<4>1588_G .INIT = 16'h00C6;
  LUT4 \vga/scancode_convert/scancode_rom/data<4>1588_G  (
    .I0(\vga/scancode_convert/sc [4]),
    .I1(\vga/scancode_convert/sc [3]),
    .I2(\vga/scancode_convert/sc [0]),
    .I3(\vga/scancode_convert/sc [1]),
    .O(N3203)
  );
  MUXF5 \vga/ps2/bitcnt_x<3>  (
    .I0(N3204),
    .I1(N3205),
    .S(\vga/ps2/ps2_clk_fall_edge ),
    .O(\vga/ps2/bitcnt_x [3])
  );
  defparam \vga/ps2/bitcnt_x<3>_F .INIT = 16'h0222;
  LUT4 \vga/ps2/bitcnt_x<3>_F  (
    .I0(\vga/ps2/bitcnt_r [3]),
    .I1(\vga/ps2/error_r_47 ),
    .I2(\vga/ps2/ps2_clk_r [1]),
    .I3(\vga/ps2/_cmp_eq0001 ),
    .O(N3204)
  );
  defparam \vga/ps2/bitcnt_x<3>_G .INIT = 16'h6AAA;
  LUT4 \vga/ps2/bitcnt_x<3>_G  (
    .I0(\vga/ps2/bitcnt_r [3]),
    .I1(\vga/ps2/bitcnt_r [2]),
    .I2(\vga/ps2/bitcnt_r [1]),
    .I3(\vga/ps2/bitcnt_r [0]),
    .O(N3205)
  );
  MUXF5 \vga/ps2/bitcnt_x<2>1  (
    .I0(N3206),
    .I1(N3207),
    .S(\vga/ps2/ps2_clk_fall_edge ),
    .O(\vga/ps2/bitcnt_x [2])
  );
  defparam \vga/ps2/bitcnt_x<2>1_F .INIT = 16'h0222;
  LUT4 \vga/ps2/bitcnt_x<2>1_F  (
    .I0(\vga/ps2/bitcnt_r [2]),
    .I1(\vga/ps2/error_r_47 ),
    .I2(\vga/ps2/ps2_clk_r [1]),
    .I3(\vga/ps2/_cmp_eq0001 ),
    .O(N3206)
  );
  defparam \vga/ps2/bitcnt_x<2>1_G .INIT = 8'h6C;
  LUT3 \vga/ps2/bitcnt_x<2>1_G  (
    .I0(\vga/ps2/bitcnt_r [1]),
    .I1(\vga/ps2/bitcnt_r [2]),
    .I2(\vga/ps2/bitcnt_r [0]),
    .O(N3207)
  );
  MUXF5 \vga/crt/state_FFd3-In48_SW0  (
    .I0(N3208),
    .I1(N3209),
    .S(\vga/crt/state_FFd2_41 ),
    .O(N3144)
  );
  defparam \vga/crt/state_FFd3-In48_SW0_F .INIT = 16'h0020;
  LUT4 \vga/crt/state_FFd3-In48_SW0_F  (
    .I0(\vga/crt/state_FFd3_42 ),
    .I1(\vga/crt/newline_37 ),
    .I2(\vga/crt/state_FFd1_40 ),
    .I3(\vga/crt/_cmp_eq0001 ),
    .O(N3208)
  );
  defparam \vga/crt/state_FFd3-In48_SW0_G .INIT = 8'hFD;
  LUT3 \vga/crt/state_FFd3-In48_SW0_G  (
    .I0(\vga/scancode_convert/strobe_out_14 ),
    .I1(\vga/scancode_convert/key_up_16 ),
    .I2(\vga/crt/state_FFd1_40 ),
    .O(N3209)
  );
  MUXF5 \vga/charload217  (
    .I0(N3210),
    .I1(N3211),
    .S(\vga/rom_addr_char [3]),
    .O(\vga/charload2_map865 )
  );
  defparam \vga/charload217_F .INIT = 16'h0020;
  LUT4 \vga/charload217_F  (
    .I0(\vga/vgacore/vcnt_2_1_98 ),
    .I1(\vga/rom_addr_char [4]),
    .I2(\vga/rom_addr_char [2]),
    .I3(N3164),
    .O(N3210)
  );
  defparam \vga/charload217_G .INIT = 16'h0020;
  LUT4 \vga/charload217_G  (
    .I0(\vga/N4 ),
    .I1(\vga/rom_addr_char [4]),
    .I2(\vga/rom_addr_char [1]),
    .I3(\vga/rom_addr_char [2]),
    .O(N3211)
  );
  MUXF5 \vga/scancode_convert/scancode_rom/data<5>3159_SW0  (
    .I0(N3212),
    .I1(N3213),
    .S(\vga/scancode_convert/sc [2]),
    .O(N3112)
  );
  defparam \vga/scancode_convert/scancode_rom/data<5>3159_SW0_F .INIT = 8'hF7;
  LUT3 \vga/scancode_convert/scancode_rom/data<5>3159_SW0_F  (
    .I0(\vga/scancode_convert/sc [3]),
    .I1(\vga/scancode_convert/sc [4]),
    .I2(\vga/scancode_convert/scancode_rom/N12 ),
    .O(N3212)
  );
  defparam \vga/scancode_convert/scancode_rom/data<5>3159_SW0_G .INIT = 16'h47CF;
  LUT4 \vga/scancode_convert/scancode_rom/data<5>3159_SW0_G  (
    .I0(\vga/scancode_convert/scancode_rom/data<5>3_map1249 ),
    .I1(\vga/scancode_convert/sc [3]),
    .I2(\vga/scancode_convert/scancode_rom/data<5>3_map1245 ),
    .I3(\vga/scancode_convert/scancode_rom/data<5>3_map1260 ),
    .O(N3213)
  );
  MUXF5 \vga/scancode_convert/scancode_rom/data<5>3450  (
    .I0(N3214),
    .I1(N3215),
    .S(\vga/scancode_convert/raise ),
    .O(\vga/scancode_convert/scancode_rom/data<5>3_map1337 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<5>3450_F .INIT = 8'h7F;
  LUT3 \vga/scancode_convert/scancode_rom/data<5>3450_F  (
    .I0(\vga/scancode_convert/sc [1]),
    .I1(\vga/scancode_convert/sc [3]),
    .I2(\vga/scancode_convert/sc_0_1_93 ),
    .O(N3214)
  );
  defparam \vga/scancode_convert/scancode_rom/data<5>3450_G .INIT = 16'h62FF;
  LUT4 \vga/scancode_convert/scancode_rom/data<5>3450_G  (
    .I0(\vga/scancode_convert/sc [1]),
    .I1(\vga/scancode_convert/sc_0_1_93 ),
    .I2(\vga/scancode_convert/sc [4]),
    .I3(\vga/scancode_convert/sc [3]),
    .O(N3215)
  );
  BUFG gray_cnt_FFd1_BUFG (
    .I(gray_cnt_FFd11),
    .O(gray_cnt_FFd1_9)
  );
  BUFG \vga/crtclk_BUFG  (
    .I(\vga/crtclk1 ),
    .O(\vga/crtclk_15 )
  );
  INV \vga/crt/Mcount_cursor_v_lut<0>_INV_0  (
    .I(\vga/crt/cursor_v [0]),
    .O(\vga/crt/Result [0])
  );
  INV \vga/crt/Mcount_cursor_h_lut<0>_INV_0  (
    .I(\vga/crt/cursor_h [0]),
    .O(\vga/crt/Result<0>1 )
  );
  INV \vga/vgacore/Mcompar__cmp_lt0000_lut<4>_INV_0  (
    .I(\vga/vgacore/hcnt [10]),
    .O(\vga/vgacore/N7 )
  );
  INV \vga/vgacore/Mcompar__cmp_lt0000_cy<4>_inv_INV_0  (
    .I(\vga/vgacore/Mcompar__cmp_lt0000_cy [4]),
    .O(\vga/vgacore/hcnt_Eqn_bis_0 )
  );
  INV \vga/ps2/Madd__addsub0000_lut<0>_INV_0  (
    .I(\vga/ps2/timer_r [0]),
    .O(\vga/ps2/N5 )
  );
  INV vga_hsync_n1_INV_0 (
    .I(\vga/vgacore/hsync_7 ),
    .O(vga_hsync_n_OBUF_3)
  );
  INV vga_vsync_n1_INV_0 (
    .I(\vga/vgacore/vsync_6 ),
    .O(vga_vsync_n_OBUF_5)
  );
  INV gray_cnt_Rst_inv1_INV_0 (
    .I(reset_n_IBUF_0),
    .O(gray_cnt_Rst_inv)
  );
  INV \vga/charclk1_INV_0  (
    .I(\vga/pclk [2]),
    .O(\vga/charclk )
  );
  INV \vga/_not00011_INV_0  (
    .I(\vga/crtclk_15 ),
    .O(\vga/_not0001 )
  );
  INV \gray_cnt_FFd2-In1_INV_0  (
    .I(gray_cnt_FFd1_9),
    .O(\gray_cnt_FFd2-In )
  );
  INV \vga/scancode_convert/_not00081_INV_0  (
    .I(\vga/scancode_convert/capslock_48 ),
    .O(\vga/scancode_convert/_not0008 )
  );
  INV \vga/pixel_hold<7>_inv1_INV_0  (
    .I(\vga/pixel_hold [7]),
    .O(\vga/pixel_hold<7>_inv )
  );
  FD \vga/rom_addr_char_0_1  (
    .D(\vga/ram_data_out [0]),
    .C(\vga/charclk ),
    .Q(\vga/rom_addr_char_0_1_94 )
  );
  FD \vga/rom_addr_char_1_1  (
    .D(\vga/ram_data_out [1]),
    .C(\vga/charclk ),
    .Q(\vga/rom_addr_char_1_1_95 )
  );
  FDC_1 \vga/vgacore/vcnt_0_1  (
    .D(N3216),
    .CLR(gray_cnt_Rst_inv1_INV_0_1_99),
    .C(\vga/vgacore/hblank_12 ),
    .Q(\vga/vgacore/vcnt_0_1_96 )
  );
  defparam \vga/vgacore/Mcount_vcnt_lut<0>_1 .INIT = 4'h4;
  LUT2 \vga/vgacore/Mcount_vcnt_lut<0>_1  (
    .I0(\vga/vgacore/vcnt [0]),
    .I1(\vga/vgacore/vcnt_Eqn_bis_0 ),
    .O(N3216)
  );
  FDC_1 \vga/vgacore/vcnt_1_1  (
    .D(\vga/vgacore/Result<1>1 ),
    .CLR(gray_cnt_Rst_inv1_INV_0_1_99),
    .C(\vga/vgacore/hblank_12 ),
    .Q(\vga/vgacore/vcnt_1_1_97 )
  );
  FDC_1 \vga/vgacore/vcnt_2_1  (
    .D(\vga/vgacore/Result<2>1 ),
    .CLR(gray_cnt_Rst_inv1_INV_0_1_99),
    .C(\vga/vgacore/hblank_12 ),
    .Q(\vga/vgacore/vcnt_2_1_98 )
  );
  INV gray_cnt_Rst_inv1_INV_0_1 (
    .I(reset_n_IBUF_0),
    .O(gray_cnt_Rst_inv1_INV_0_1_99)
  );
  defparam \vga/ram_addr_mux<4>1 .INIT = 16'h14BE;
  LUT4 \vga/ram_addr_mux<4>1  (
    .I0(\vga/ram_we_n ),
    .I1(\vga/crt/cursor_h [4]),
    .I2(\vga/crt/cursor_v [0]),
    .I3(\vga/vgacore/hcnt [7]),
    .O(N3219)
  );
  defparam \vga/ram_addr_mux<4>2 .INIT = 16'hBE14;
  LUT4 \vga/ram_addr_mux<4>2  (
    .I0(\vga/ram_we_n ),
    .I1(\vga/crt/cursor_v [0]),
    .I2(\vga/crt/cursor_h [4]),
    .I3(\vga/vgacore/hcnt [7]),
    .O(N3220)
  );
  MUXF5 \vga/ram_addr_mux<4>_f5  (
    .I0(N3220),
    .I1(N3219),
    .S(\vga/vgacore/vcnt [3]),
    .O(\vga/ram_addr_mux [4])
  );
  defparam \vga/pixel<8>191 .INIT = 8'hD5;
  LUT3 \vga/pixel<8>191  (
    .I0(\vga/vgacore/N51 ),
    .I1(\vga/vgacore/vcnt_2_1_98 ),
    .I2(\vga/vgacore/vcnt [3]),
    .O(N3221)
  );
  MUXF5 \vga/pixel<8>19_f5  (
    .I0(N3222),
    .I1(N3221),
    .S(\vga/vgacore/vcnt [9]),
    .O(\vga/pixel<8>_map785 )
  );
  defparam \vga/ps2/bitcnt_x<0>11 .INIT = 16'h4446;
  LUT4 \vga/ps2/bitcnt_x<0>11  (
    .I0(\vga/ps2/bitcnt_r [0]),
    .I1(\vga/ps2/ps2_clk_fall_edge ),
    .I2(\vga/ps2/ps2_clk_r [1]),
    .I3(\vga/ps2/error_r_47 ),
    .O(N3224)
  );
  defparam \vga/ps2/bitcnt_x<0>12 .INIT = 8'h46;
  LUT3 \vga/ps2/bitcnt_x<0>12  (
    .I0(\vga/ps2/bitcnt_r [0]),
    .I1(\vga/ps2/ps2_clk_fall_edge ),
    .I2(\vga/ps2/error_r_47 ),
    .O(N3225)
  );
  MUXF5 \vga/ps2/bitcnt_x<0>1_f5  (
    .I0(N3225),
    .I1(N3224),
    .S(\vga/ps2/_cmp_eq0001 ),
    .O(\vga/ps2/bitcnt_x [0])
  );
  defparam \vga/crt/state_FFd2-In1 .INIT = 8'hF7;
  LUT3 \vga/crt/state_FFd2-In1  (
    .I0(\vga/crt/state_FFd2_41 ),
    .I1(\vga/insert_crt_data ),
    .I2(\vga/crt/state_FFd1_40 ),
    .O(N3226)
  );
  defparam \vga/crt/state_FFd2-In2 .INIT = 16'hC888;
  LUT4 \vga/crt/state_FFd2-In2  (
    .I0(\vga/crt/state_FFd1_40 ),
    .I1(\vga/crt/state_FFd2_41 ),
    .I2(\vga/crt/scroll_36 ),
    .I3(\vga/crt/eol_35 ),
    .O(N3227)
  );
  MUXF5 \vga/crt/state_FFd2-In_f5  (
    .I0(N3227),
    .I1(N3226),
    .S(\vga/crt/state_FFd3_42 ),
    .O(\vga/crt/state_FFd2-In )
  );
  defparam \vga/charload2371 .INIT = 4'h8;
  LUT2 \vga/charload2371  (
    .I0(\vga/charload_13 ),
    .I1(\vga/cursor_match ),
    .O(N3228)
  );
  defparam \vga/charload2372 .INIT = 16'hC888;
  LUT4 \vga/charload2372  (
    .I0(\vga/cursor_match ),
    .I1(\vga/charload_13 ),
    .I2(\vga/charload2_map865 ),
    .I3(\vga/rom_addr_char [5]),
    .O(N3229)
  );
  MUXF5 \vga/charload237_f5  (
    .I0(N3229),
    .I1(N3228),
    .S(\vga/rom_addr_char [6]),
    .O(\vga/_mux0002 [7])
  );
  defparam \vga/ps2/bitcnt_x<1>11 .INIT = 4'h6;
  LUT2 \vga/ps2/bitcnt_x<1>11  (
    .I0(\vga/ps2/bitcnt_r [1]),
    .I1(\vga/ps2/bitcnt_r [0]),
    .O(N3230)
  );
  defparam \vga/ps2/bitcnt_x<1>12 .INIT = 16'h0222;
  LUT4 \vga/ps2/bitcnt_x<1>12  (
    .I0(\vga/ps2/bitcnt_r [1]),
    .I1(\vga/ps2/error_r_47 ),
    .I2(\vga/ps2/ps2_clk_r [1]),
    .I3(\vga/ps2/_cmp_eq0001 ),
    .O(N3231)
  );
  MUXF5 \vga/ps2/bitcnt_x<1>1_f5  (
    .I0(N3231),
    .I1(N3230),
    .S(\vga/ps2/ps2_clk_fall_edge ),
    .O(\vga/ps2/bitcnt_x [1])
  );
  defparam \vga/charload3541 .INIT = 16'hAAEA;
  LUT4 \vga/charload3541  (
    .I0(\vga/cursor_match ),
    .I1(\vga/charload3_map953 ),
    .I2(\vga/rom_addr_char [5]),
    .I3(\vga/rom_addr_char [6]),
    .O(N3233)
  );
  MUXF5 \vga/charload354_f5  (
    .I0(\vga/pixel_hold [0]),
    .I1(N3233),
    .S(\vga/charload_13 ),
    .O(\vga/_mux0002 [6])
  );
  defparam \vga/charload5581 .INIT = 16'hFAD8;
  LUT4 \vga/charload5581  (
    .I0(\vga/charload_13 ),
    .I1(\vga/rom_addr_char<5>_f51_31 ),
    .I2(\vga/pixel_hold [2]),
    .I3(\vga/cursor_match ),
    .O(N3234)
  );
  defparam \vga/charload5582 .INIT = 16'hFAD8;
  LUT4 \vga/charload5582  (
    .I0(\vga/charload_13 ),
    .I1(\vga/charload5_map965 ),
    .I2(\vga/pixel_hold [2]),
    .I3(\vga/cursor_match ),
    .O(N3235)
  );
  MUXF5 \vga/charload558_f5  (
    .I0(N3235),
    .I1(N3234),
    .S(\vga/rom_addr_char [6]),
    .O(\vga/_mux0002 [4])
  );
  defparam \vga/charload4581 .INIT = 16'hFAD8;
  LUT4 \vga/charload4581  (
    .I0(\vga/charload_13 ),
    .I1(\vga/rom_addr_char<5>_f5_30 ),
    .I2(\vga/pixel_hold [4]),
    .I3(\vga/cursor_match ),
    .O(N3236)
  );
  defparam \vga/charload4582 .INIT = 16'hFAD8;
  LUT4 \vga/charload4582  (
    .I0(\vga/charload_13 ),
    .I1(\vga/charload4_map979 ),
    .I2(\vga/pixel_hold [4]),
    .I3(\vga/cursor_match ),
    .O(N3237)
  );
  MUXF5 \vga/charload458_f5  (
    .I0(N3237),
    .I1(N3236),
    .S(\vga/rom_addr_char [6]),
    .O(\vga/_mux0002 [2])
  );
  defparam \vga/charload7581 .INIT = 16'hFAD8;
  LUT4 \vga/charload7581  (
    .I0(\vga/charload_13 ),
    .I1(\vga/rom_addr_char<5>_f5123 ),
    .I2(\vga/pixel_hold [5]),
    .I3(\vga/cursor_match ),
    .O(N3238)
  );
  defparam \vga/charload7582 .INIT = 16'hFAD8;
  LUT4 \vga/charload7582  (
    .I0(\vga/charload_13 ),
    .I1(\vga/charload7_map993 ),
    .I2(\vga/pixel_hold [5]),
    .I3(\vga/cursor_match ),
    .O(N3239)
  );
  MUXF5 \vga/charload758_f5  (
    .I0(N3239),
    .I1(N3238),
    .S(\vga/rom_addr_char [6]),
    .O(\vga/_mux0002 [1])
  );
  defparam \vga/scancode_convert/scancode_rom/data<2>1111 .INIT = 16'h2000;
  LUT4 \vga/scancode_convert/scancode_rom/data<2>1111  (
    .I0(\vga/scancode_convert/sc [0]),
    .I1(\vga/scancode_convert/sc [1]),
    .I2(\vga/scancode_convert/sc [3]),
    .I3(\vga/scancode_convert/sc [2]),
    .O(N3242)
  );
  defparam \vga/scancode_convert/scancode_rom/data<2>1112 .INIT = 4'h8;
  LUT2 \vga/scancode_convert/scancode_rom/data<2>1112  (
    .I0(\vga/scancode_convert/sc [3]),
    .I1(\vga/scancode_convert/sc [2]),
    .O(N3243)
  );
  MUXF5 \vga/scancode_convert/scancode_rom/data<2>111_f5  (
    .I0(N3243),
    .I1(N3242),
    .S(\vga/scancode_convert/sc [4]),
    .O(\vga/scancode_convert/scancode_rom/data<2>1_map1056 )
  );
  defparam \vga/vgacore/vblank21 .INIT = 16'h0001;
  LUT4 \vga/vgacore/vblank21  (
    .I0(\vga/vgacore/vcnt [7]),
    .I1(\vga/vgacore/vcnt [4]),
    .I2(\vga/vgacore/vcnt [6]),
    .I3(\vga/vgacore/vcnt [5]),
    .O(N3244)
  );
  MUXF5 \vga/vgacore/vblank2_f5  (
    .I0(N3244),
    .I1(N2),
    .S(\vga/vgacore/vcnt [8]),
    .O(\vga/vgacore/N51 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<3>13521 .INIT = 16'h0020;
  LUT4 \vga/scancode_convert/scancode_rom/data<3>13521  (
    .I0(\vga/scancode_convert/sc [1]),
    .I1(\vga/scancode_convert/sc [0]),
    .I2(\vga/scancode_convert/sc [2]),
    .I3(\vga/scancode_convert/sc [3]),
    .O(N3245)
  );
  MUXF5 \vga/scancode_convert/scancode_rom/data<3>1352_f5  (
    .I0(N3),
    .I1(N3245),
    .S(\vga/scancode_convert/sc [5]),
    .O(\vga/scancode_convert/scancode_rom/data<3>1_map1229 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<4>1221 .INIT = 16'hFF27;
  LUT4 \vga/scancode_convert/scancode_rom/data<4>1221  (
    .I0(\vga/scancode_convert/sc [0]),
    .I1(\vga/scancode_convert/sc [1]),
    .I2(\vga/scancode_convert/scancode_rom/N12 ),
    .I3(\vga/scancode_convert/sc [3]),
    .O(N3248)
  );
  MUXF5 \vga/scancode_convert/scancode_rom/data<4>122_f5  (
    .I0(\vga/scancode_convert/sc [3]),
    .I1(N3248),
    .S(\vga/scancode_convert/sc [4]),
    .O(\vga/scancode_convert/scancode_rom/data<4>1_map1548 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<1>23191 .INIT = 16'hAAAE;
  LUT4 \vga/scancode_convert/scancode_rom/data<1>23191  (
    .I0(\vga/scancode_convert/sc [2]),
    .I1(\vga/scancode_convert/sc [1]),
    .I2(\vga/scancode_convert/sc [3]),
    .I3(\vga/scancode_convert/sc [0]),
    .O(N3249)
  );
  defparam \vga/scancode_convert/scancode_rom/data<1>23192 .INIT = 16'hFF62;
  LUT4 \vga/scancode_convert/scancode_rom/data<1>23192  (
    .I0(\vga/scancode_convert/sc [1]),
    .I1(\vga/scancode_convert/sc [0]),
    .I2(\vga/scancode_convert/sc [3]),
    .I3(\vga/scancode_convert/sc [2]),
    .O(N3250)
  );
  MUXF5 \vga/scancode_convert/scancode_rom/data<1>2319_f5  (
    .I0(N3250),
    .I1(N3249),
    .S(\vga/scancode_convert/sc [4]),
    .O(\vga/scancode_convert/scancode_rom/data<1>2_map1751 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<2>1410_SW01 .INIT = 8'hFE;
  LUT3 \vga/scancode_convert/scancode_rom/data<2>1410_SW01  (
    .I0(\vga/scancode_convert/scancode_rom/N12 ),
    .I1(\vga/scancode_convert/sc [3]),
    .I2(\vga/scancode_convert/sc [0]),
    .O(N3254)
  );
  defparam \vga/scancode_convert/scancode_rom/data<2>1410_SW02 .INIT = 8'hFD;
  LUT3 \vga/scancode_convert/scancode_rom/data<2>1410_SW02  (
    .I0(\vga/scancode_convert/sc [0]),
    .I1(\vga/scancode_convert/sc [1]),
    .I2(\vga/scancode_convert/sc [3]),
    .O(N3255)
  );
  MUXF5 \vga/scancode_convert/scancode_rom/data<2>1410_SW0_f5  (
    .I0(N3255),
    .I1(N3254),
    .S(\vga/scancode_convert/sc [4]),
    .O(N3126)
  );
  defparam \vga/scancode_convert/scancode_rom/data<3>1721 .INIT = 16'hFFD8;
  LUT4 \vga/scancode_convert/scancode_rom/data<3>1721  (
    .I0(\vga/scancode_convert/sc [3]),
    .I1(\vga/scancode_convert/sc [1]),
    .I2(\vga/scancode_convert/sc [0]),
    .I3(\vga/scancode_convert/sc [2]),
    .O(N3256)
  );
  defparam \vga/scancode_convert/scancode_rom/data<3>1722 .INIT = 16'hAAAE;
  LUT4 \vga/scancode_convert/scancode_rom/data<3>1722  (
    .I0(\vga/scancode_convert/sc [2]),
    .I1(\vga/scancode_convert/sc [1]),
    .I2(\vga/scancode_convert/sc [3]),
    .I3(\vga/scancode_convert/sc [0]),
    .O(N3257)
  );
  MUXF5 \vga/scancode_convert/scancode_rom/data<3>172_f5  (
    .I0(N3257),
    .I1(N3256),
    .S(\vga/scancode_convert/sc [4]),
    .O(\vga/scancode_convert/scancode_rom/data<3>1_map1171 )
  );
  defparam \vga/charload8_SW0_SW01 .INIT = 16'h7FFF;
  LUT4 \vga/charload8_SW0_SW01  (
    .I0(\vga/rom_addr_char [2]),
    .I1(\vga/rom_addr_char [3]),
    .I2(\vga/rom_addr_char_1_1_95 ),
    .I3(\vga/N224 ),
    .O(N3259)
  );
  MUXF5 \vga/charload8_SW0_SW0_f5  (
    .I0(N3),
    .I1(N3259),
    .S(\vga/rom_addr_char [4]),
    .O(N3150)
  );
  defparam \vga/rom_addr_char<1>_mmx_out11 .INIT = 16'h15FF;
  LUT4 \vga/rom_addr_char<1>_mmx_out11  (
    .I0(\vga/vgacore/vcnt_0_1_96 ),
    .I1(\vga/rom_addr_char_0_1_94 ),
    .I2(\vga/rom_addr_char_1_1_95 ),
    .I3(\vga/vgacore/vcnt_1_1_97 ),
    .O(N3261)
  );
  defparam \vga/rom_addr_char<1>_mmx_out12 .INIT = 16'hFBFF;
  LUT4 \vga/rom_addr_char<1>_mmx_out12  (
    .I0(\vga/vgacore/vcnt_0_1_96 ),
    .I1(\vga/rom_addr_char_1_1_95 ),
    .I2(\vga/vgacore/vcnt_1_1_97 ),
    .I3(\vga/rom_addr_char_0_1_94 ),
    .O(N3262)
  );
  MUXF5 \vga/rom_addr_char<1>_mmx_out1_f5  (
    .I0(N3262),
    .I1(N3261),
    .S(\vga/vgacore/vcnt_2_1_98 ),
    .O(\vga/rom_addr_char<1>_mmx_out )
  );
  defparam \vga/scancode_convert/scancode_rom/data<3>12171 .INIT = 8'hEA;
  LUT3 \vga/scancode_convert/scancode_rom/data<3>12171  (
    .I0(\vga/scancode_convert/sc [2]),
    .I1(\vga/scancode_convert/sc [1]),
    .I2(\vga/scancode_convert/sc [3]),
    .O(N3264)
  );
  defparam \vga/scancode_convert/scancode_rom/data<3>12172 .INIT = 8'hFE;
  LUT3 \vga/scancode_convert/scancode_rom/data<3>12172  (
    .I0(\vga/scancode_convert/sc [2]),
    .I1(\vga/scancode_convert/sc [1]),
    .I2(\vga/scancode_convert/sc [0]),
    .O(N3265)
  );
  MUXF5 \vga/scancode_convert/scancode_rom/data<3>1217_f5  (
    .I0(N3265),
    .I1(N3264),
    .S(\vga/scancode_convert/sc [4]),
    .O(\vga/scancode_convert/scancode_rom/data<3>1_map1201 )
  );
  defparam \vga/scancode_convert/state_FFd2-In_SW0 .INIT = 16'hFF60;
  LUT4_L \vga/scancode_convert/state_FFd2-In_SW0  (
    .I0(\vga/ps2/sc_r [2]),
    .I1(\vga/ps2/sc_r [1]),
    .I2(\vga/scancode_convert/N10 ),
    .I3(\vga/scancode_convert/release_prefix_59 ),
    .LO(N126)
  );
  defparam \vga/scancode_convert/state_FFd3-In_SW0 .INIT = 16'h90F0;
  LUT4_L \vga/scancode_convert/state_FFd3-In_SW0  (
    .I0(\vga/ps2/sc_r [1]),
    .I1(\vga/ps2/sc_r [2]),
    .I2(\vga/scancode_convert/release_prefix_59 ),
    .I3(\vga/scancode_convert/N10 ),
    .LO(N128)
  );
  defparam \vga/crt/_and0001 .INIT = 16'h0020;
  LUT4_D \vga/crt/_and0001  (
    .I0(\vga/crt/eol_35 ),
    .I1(\vga/crt/state_FFd3_42 ),
    .I2(\vga/crt/scroll_36 ),
    .I3(N235),
    .LO(N3266),
    .O(\vga/crt/_and0001_39 )
  );
  defparam \vga/scancode_convert/_cmp_eq00041_SW0 .INIT = 8'hFD;
  LUT3_L \vga/scancode_convert/_cmp_eq00041_SW0  (
    .I0(\vga/ps2/sc_r [4]),
    .I1(\vga/ps2/sc_r [3]),
    .I2(\vga/ps2/sc_r [0]),
    .LO(N237)
  );
  defparam \vga/scancode_convert/shift_set6 .INIT = 8'h08;
  LUT3_D \vga/scancode_convert/shift_set6  (
    .I0(\vga/scancode_convert/N10 ),
    .I1(\vga/ps2/sc_r [1]),
    .I2(\vga/ps2/sc_r [2]),
    .LO(N3267),
    .O(\vga/scancode_convert/shift_set_map833 )
  );
  defparam \vga/scancode_convert/state_FFd4-In24 .INIT = 16'hFF60;
  LUT4_L \vga/scancode_convert/state_FFd4-In24  (
    .I0(\vga/ps2/sc_r [1]),
    .I1(\vga/ps2/sc_r [2]),
    .I2(\vga/scancode_convert/N10 ),
    .I3(\vga/scancode_convert/N11 ),
    .LO(\vga/scancode_convert/state_FFd4-In_map845 )
  );
  defparam \vga/scancode_convert/_cmp_eq000211 .INIT = 16'h0020;
  LUT4_D \vga/scancode_convert/_cmp_eq000211  (
    .I0(\vga/ps2/sc_r [4]),
    .I1(\vga/ps2/sc_r [2]),
    .I2(\vga/ps2/sc_r [6]),
    .I3(\vga/ps2/sc_r [1]),
    .LO(N3268),
    .O(\vga/scancode_convert/N31 )
  );
  defparam \vga/crt/eol_SW0 .INIT = 16'hFF7F;
  LUT4_L \vga/crt/eol_SW0  (
    .I0(\vga/crt/cursor_h [3]),
    .I1(\vga/crt/cursor_h [2]),
    .I2(\vga/crt/cursor_h [1]),
    .I3(\vga/crt/cursor_h [4]),
    .LO(N293)
  );
  defparam \vga/crt/scroll_SW0 .INIT = 8'hF7;
  LUT3_L \vga/crt/scroll_SW0  (
    .I0(\vga/crt/cursor_v [1]),
    .I1(\vga/crt/cursor_v [3]),
    .I2(\vga/crt/cursor_v [2]),
    .LO(N301)
  );
  defparam \vga/crt/_and0000_SW0 .INIT = 8'h17;
  LUT3_L \vga/crt/_and0000_SW0  (
    .I0(\vga/crt/state_FFd2_41 ),
    .I1(\vga/crt/state_FFd1_40 ),
    .I2(\vga/crt/eol_35 ),
    .LO(N305)
  );
  defparam \vga/_and000093 .INIT = 16'h9009;
  LUT4_L \vga/_and000093  (
    .I0(\vga/crt/cursor_h [4]),
    .I1(\vga/vgacore/hcnt [7]),
    .I2(\vga/crt/cursor_h [5]),
    .I3(\vga/vgacore/hcnt [8]),
    .LO(\vga/_and0000_map902 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<1>111 .INIT = 8'h7F;
  LUT3_D \vga/scancode_convert/scancode_rom/data<1>111  (
    .I0(\vga/scancode_convert/sc [3]),
    .I1(\vga/scancode_convert/sc [4]),
    .I2(\vga/scancode_convert/sc [1]),
    .LO(N3269),
    .O(\vga/scancode_convert/scancode_rom/N25 )
  );
  defparam \vga/vgacore/vcnt_Eqn_911 .INIT = 16'h15FF;
  LUT4_D \vga/vgacore/vcnt_Eqn_911  (
    .I0(\vga/vgacore/vcnt [2]),
    .I1(\vga/vgacore/vcnt [1]),
    .I2(\vga/vgacore/vcnt [0]),
    .I3(\vga/vgacore/vcnt [3]),
    .LO(N3270),
    .O(\vga/vgacore/N0 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<2>1264 .INIT = 16'h0141;
  LUT4_L \vga/scancode_convert/scancode_rom/data<2>1264  (
    .I0(\vga/scancode_convert/sc [1]),
    .I1(\vga/scancode_convert/sc [0]),
    .I2(\vga/scancode_convert/sc [4]),
    .I3(\vga/scancode_convert/raise ),
    .LO(\vga/scancode_convert/scancode_rom/data<2>1_map1110 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<3>199 .INIT = 16'h6040;
  LUT4_L \vga/scancode_convert/scancode_rom/data<3>199  (
    .I0(\vga/scancode_convert/sc [1]),
    .I1(\vga/scancode_convert/sc [0]),
    .I2(\vga/scancode_convert/sc [4]),
    .I3(\vga/scancode_convert/raise ),
    .LO(\vga/scancode_convert/scancode_rom/data<3>1_map1178 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<5>3247 .INIT = 16'h04AE;
  LUT4_L \vga/scancode_convert/scancode_rom/data<5>3247  (
    .I0(\vga/scancode_convert/sc [1]),
    .I1(\vga/scancode_convert/sc [0]),
    .I2(\vga/scancode_convert/sc [4]),
    .I3(\vga/scancode_convert/raise ),
    .LO(\vga/scancode_convert/scancode_rom/data<5>3_map1291 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<5>3359 .INIT = 16'h153B;
  LUT4_L \vga/scancode_convert/scancode_rom/data<5>3359  (
    .I0(\vga/scancode_convert/sc [0]),
    .I1(\vga/scancode_convert/raise ),
    .I2(\vga/scancode_convert/sc [4]),
    .I3(\vga/scancode_convert/sc [1]),
    .LO(\vga/scancode_convert/scancode_rom/data<5>3_map1314 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<5>3664 .INIT = 16'h1915;
  LUT4_L \vga/scancode_convert/scancode_rom/data<5>3664  (
    .I0(\vga/scancode_convert/sc [4]),
    .I1(\vga/scancode_convert/sc [0]),
    .I2(\vga/scancode_convert/sc [1]),
    .I3(\vga/scancode_convert/raise ),
    .LO(\vga/scancode_convert/scancode_rom/data<5>3_map1376 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<0>176 .INIT = 16'hCF4F;
  LUT4_L \vga/scancode_convert/scancode_rom/data<0>176  (
    .I0(\vga/scancode_convert/sc [3]),
    .I1(\vga/scancode_convert/scancode_rom/data<0>1_map1429 ),
    .I2(\vga/scancode_convert/sc [2]),
    .I3(\vga/scancode_convert/scancode_rom/data<0>1_map1438 ),
    .LO(\vga/scancode_convert/scancode_rom/data<0>1_map1443 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<0>1437 .INIT = 16'h5457;
  LUT4_L \vga/scancode_convert/scancode_rom/data<0>1437  (
    .I0(\vga/scancode_convert/sc [1]),
    .I1(\vga/scancode_convert/raise ),
    .I2(\vga/scancode_convert/sc [4]),
    .I3(\vga/scancode_convert/sc [0]),
    .LO(\vga/scancode_convert/scancode_rom/data<0>1_map1517 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<0>1539 .INIT = 16'hC888;
  LUT4_L \vga/scancode_convert/scancode_rom/data<0>1539  (
    .I0(\vga/scancode_convert/sc [5]),
    .I1(\vga/scancode_convert/scancode_rom/data<0>1_map1534 ),
    .I2(\vga/scancode_convert/scancode_rom/data<0>1_map1503 ),
    .I3(\vga/scancode_convert/scancode_rom/data<0>1_map1529 ),
    .LO(\vga/scancode_convert/scancode_rom/data<0>1_map1535 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<4>145 .INIT = 16'h1FBF;
  LUT4_L \vga/scancode_convert/scancode_rom/data<4>145  (
    .I0(\vga/scancode_convert/sc [4]),
    .I1(\vga/scancode_convert/scancode_rom/N43 ),
    .I2(\vga/scancode_convert/sc [3]),
    .I3(\vga/scancode_convert/scancode_rom/N18 ),
    .LO(\vga/scancode_convert/scancode_rom/data<4>1_map1556 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<1>218 .INIT = 16'h082A;
  LUT4_L \vga/scancode_convert/scancode_rom/data<1>218  (
    .I0(\vga/scancode_convert/sc [3]),
    .I1(\vga/scancode_convert/sc [4]),
    .I2(\vga/scancode_convert/scancode_rom/N18 ),
    .I3(\vga/scancode_convert/scancode_rom/N28 ),
    .LO(\vga/scancode_convert/scancode_rom/data<1>2_map1686 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<1>2465 .INIT = 16'hC888;
  LUT4_L \vga/scancode_convert/scancode_rom/data<1>2465  (
    .I0(\vga/scancode_convert/sc [5]),
    .I1(\vga/scancode_convert/scancode_rom/data<0>1_map1534 ),
    .I2(\vga/scancode_convert/scancode_rom/data<1>2_map1751 ),
    .I3(\vga/scancode_convert/scancode_rom/data<1>2_map1774 ),
    .LO(\vga/scancode_convert/scancode_rom/data<1>2_map1780 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<6>1181 .INIT = 16'h15FF;
  LUT4_D \vga/scancode_convert/scancode_rom/data<6>1181  (
    .I0(\vga/scancode_convert/sc [1]),
    .I1(\vga/scancode_convert/sc [4]),
    .I2(\vga/scancode_convert/sc [0]),
    .I3(\vga/scancode_convert/sc [3]),
    .LO(N3271),
    .O(\vga/scancode_convert/scancode_rom/data<6>1_map1831 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<0>152 .INIT = 16'hFFEF;
  LUT4_D \vga/scancode_convert/scancode_rom/data<0>152  (
    .I0(\vga/scancode_convert/shift_49 ),
    .I1(\vga/scancode_convert/ctrl_57 ),
    .I2(\vga/scancode_convert/sc_1_1_91 ),
    .I3(\vga/scancode_convert/capslock_48 ),
    .LO(N3272),
    .O(\vga/scancode_convert/scancode_rom/N12 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<6>1247 .INIT = 16'hE040;
  LUT4_L \vga/scancode_convert/scancode_rom/data<6>1247  (
    .I0(\vga/scancode_convert/scancode_rom/data<6>1_map1820 ),
    .I1(N3084),
    .I2(\vga/scancode_convert/scancode_rom/data<6>1_map1803 ),
    .I3(N3085),
    .LO(\vga/scancode_convert/scancode_rom/data<6>1_map1838 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<5>3852_SW0 .INIT = 8'h15;
  LUT3_L \vga/scancode_convert/scancode_rom/data<5>3852_SW0  (
    .I0(\vga/scancode_convert/sc [2]),
    .I1(\vga/scancode_convert/sc [3]),
    .I2(\vga/scancode_convert/scancode_rom/data<5>3_map1394 ),
    .LO(N3087)
  );
  defparam \vga/scancode_convert/scancode_rom/data<0>1110 .INIT = 16'h3332;
  LUT4_D \vga/scancode_convert/scancode_rom/data<0>1110  (
    .I0(\vga/scancode_convert/ctrl_57 ),
    .I1(\vga/scancode_convert/sc_1_1_91 ),
    .I2(\vga/scancode_convert/shift_49 ),
    .I3(\vga/scancode_convert/capslock_48 ),
    .LO(N3273),
    .O(\vga/scancode_convert/scancode_rom/N9 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<0>31 .INIT = 8'hF7;
  LUT3_D \vga/scancode_convert/scancode_rom/data<0>31  (
    .I0(\vga/scancode_convert/sc [4]),
    .I1(\vga/scancode_convert/sc [1]),
    .I2(\vga/scancode_convert/sc [0]),
    .LO(N3274),
    .O(\vga/scancode_convert/scancode_rom/N7 )
  );
  defparam \vga/scancode_convert/_cmp_eq0000 .INIT = 16'h0002;
  LUT4_D \vga/scancode_convert/_cmp_eq0000  (
    .I0(\vga/scancode_convert/N31 ),
    .I1(\vga/ps2/sc_r [3]),
    .I2(\vga/ps2/sc_r [0]),
    .I3(N3100),
    .LO(N3275),
    .O(\vga/scancode_convert/_cmp_eq0000_51 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<5>3895_SW0 .INIT = 16'h74FC;
  LUT4_L \vga/scancode_convert/scancode_rom/data<5>3895_SW0  (
    .I0(\vga/scancode_convert/scancode_rom/data<5>3_map1340 ),
    .I1(\vga/scancode_convert/sc [5]),
    .I2(N3112),
    .I3(\vga/scancode_convert/scancode_rom/data<5>3_map1295 ),
    .LO(N3089)
  );
  defparam \vga/scancode_convert/scancode_rom/data<2>1410 .INIT = 16'h5551;
  LUT4_L \vga/scancode_convert/scancode_rom/data<2>1410  (
    .I0(\vga/scancode_convert/sc [5]),
    .I1(N3126),
    .I2(\vga/scancode_convert/sc [2]),
    .I3(\vga/scancode_convert/scancode_rom/data<2>1_map1129 ),
    .LO(\vga/scancode_convert/scancode_rom/data<2>1_map1144 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<6>1333 .INIT = 16'h2232;
  LUT4_L \vga/scancode_convert/scancode_rom/data<6>1333  (
    .I0(\vga/scancode_convert/sc [2]),
    .I1(\vga/scancode_convert/sc [5]),
    .I2(\vga/scancode_convert/sc [1]),
    .I3(N3130),
    .LO(\vga/scancode_convert/scancode_rom/data<6>1_map1860 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<4>1392_SW0 .INIT = 16'hFBFF;
  LUT4_L \vga/scancode_convert/scancode_rom/data<4>1392_SW0  (
    .I0(\vga/scancode_convert/sc [3]),
    .I1(\vga/scancode_convert/scancode_rom/N9 ),
    .I2(\vga/scancode_convert/sc [4]),
    .I3(\vga/scancode_convert/sc [0]),
    .LO(N3110)
  );
  defparam \vga/scancode_convert/scancode_rom/data<4>1308_SW1 .INIT = 16'hFD93;
  LUT4_L \vga/scancode_convert/scancode_rom/data<4>1308_SW1  (
    .I0(\vga/scancode_convert/sc [4]),
    .I1(\vga/scancode_convert/sc [3]),
    .I2(\vga/scancode_convert/sc [0]),
    .I3(\vga/scancode_convert/sc [1]),
    .LO(N3175)
  );
  defparam \vga/scancode_convert/scancode_rom/data<0>1370_SW1 .INIT = 16'h9F02;
  LUT4_L \vga/scancode_convert/scancode_rom/data<0>1370_SW1  (
    .I0(\vga/scancode_convert/sc [4]),
    .I1(\vga/scancode_convert/sc [3]),
    .I2(\vga/scancode_convert/sc [0]),
    .I3(\vga/scancode_convert/sc [1]),
    .LO(N3177)
  );
  defparam \vga/scancode_convert/scancode_rom/data<3>126_SW1 .INIT = 8'hF7;
  LUT3_L \vga/scancode_convert/scancode_rom/data<3>126_SW1  (
    .I0(\vga/scancode_convert/sc [3]),
    .I1(\vga/scancode_convert/sc [1]),
    .I2(\vga/scancode_convert/sc [0]),
    .LO(N3180)
  );
  defparam \vga/scancode_convert/raise1_1 .INIT = 8'hFE;
  LUT3_D \vga/scancode_convert/raise1_1  (
    .I0(\vga/scancode_convert/ctrl_57 ),
    .I1(\vga/scancode_convert/shift_49 ),
    .I2(\vga/scancode_convert/capslock_48 ),
    .LO(N3276),
    .O(\vga/scancode_convert/raise1_92 )
  );
  INV \vga/pixel<8>192_INV_0  (
    .I(\vga/vgacore/N61 ),
    .O(N3222)
  );
endmodule


`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;

    wire GSR;
    wire GTS;
    wire PRLD;

    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (weak1, weak0) GSR = GSR_int;
    assign (weak1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

endmodule

