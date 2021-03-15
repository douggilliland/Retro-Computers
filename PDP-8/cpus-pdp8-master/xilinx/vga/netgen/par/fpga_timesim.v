////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995-2006 Xilinx, Inc.  All rights reserved.
////////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor: Xilinx
// \   \   \/     Version: I.31
//  \   \         Application: netgen
//  /   /         Filename: fpga_timesim.v
// /___/   /\     Timestamp: Fri Dec 29 10:07:45 2006
// \   \  /  \ 
//  \___\/\___\
//             
// Command	: -intstyle ise -s 5 -pcf fpga.pcf -sdf_anno true -sdf_path netgen/par -insert_glbl true -w -dir netgen/par -ofmt verilog -sim fpga.ncd fpga_timesim.v 
// Device	: 2s200fg256-5 (PRODUCTION 1.27 2006-05-03)
// Input file	: fpga.ncd
// Output file	: /mwave/work/nt/xess/xilinx/vga/netgen/par/fpga_timesim.v
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
  wire gray_cnt_FFd1_0;
  wire reset_n_IBUF_0;
  wire \vga/ps2/rdy_r_1 ;
  wire \vga/ps2/ps2_clk_fall_edge_0 ;
  wire \pixel<8>_0 ;
  wire \vga/vgacore/vsync_2 ;
  wire \vga/vgacore/hsync_3 ;
  wire \vga/crtclk1 ;
  wire \vga/crtclk_4 ;
  wire clka_BUFGP;
  wire gray_cnt_FFd11;
  wire \vga/ram_wclk_5 ;
  wire \vga/N226_0 ;
  wire \vga/ram_addr_mux<11>_0 ;
  wire \vga/ram_addr_mux<10>_0 ;
  wire \vga/ram_addr_mux<9>_0 ;
  wire \vga/ram_addr_mux<8>_0 ;
  wire \vga/ram_addr_mux<7>_0 ;
  wire \vga/ram_addr_mux<6>_0 ;
  wire \vga/ram_addr_mux<5>_0 ;
  wire \vga/ram_addr_mux<4>_0 ;
  wire \vga/ram_addr_mux<3>_0 ;
  wire \vga/ram_addr_mux<2>_0 ;
  wire \vga/ram_addr_mux<1>_0 ;
  wire \vga/ram_addr_mux<0>_0 ;
  wire \vga/scancode_convert/scancode_rom/data<6>1_map1831 ;
  wire N3084_0;
  wire \vga/scancode_convert/scancode_rom/N9 ;
  wire \vga/scancode_convert/scancode_rom/data<1>2_map1774_0 ;
  wire \vga/scancode_convert/scancode_rom/data<3>1_map1229_0 ;
  wire N3141_0;
  wire N3142_0;
  wire \vga/scancode_convert/scancode_rom/N28_0 ;
  wire \vga/scancode_convert/scancode_rom/data<2>1_map1056_0 ;
  wire \vga/scancode_convert/scancode_rom/data<2>1_map1098_0 ;
  wire \vga/rom_addr_char<4>11_0 ;
  wire \vga/rom_addr_char<4>_f5_0 ;
  wire \vga/rom_addr_char<3>_f6_0_6 ;
  wire \vga/rom_addr_char<3>_f61_0 ;
  wire N560_0;
  wire \vga/scancode_convert/_or0000_0 ;
  wire \vga/scancode_convert/scancode_rom/data<3>1_map1201_0 ;
  wire \vga/scancode_convert/scancode_rom/data<3>1_map1221_0 ;
  wire \vga/scancode_convert/scancode_rom/data<3>1_map1158_0 ;
  wire \vga/scancode_convert/scancode_rom/data<3>1_map1171_0 ;
  wire \vga/scancode_convert/scancode_rom/data<3>1_map1185_0 ;
  wire \vga/scancode_convert/raise ;
  wire \vga/scancode_convert/scancode_rom/data<4>1_map1633_0 ;
  wire \vga/scancode_convert/scancode_rom/data<4>1_map1669_0 ;
  wire \vga/scancode_convert/scancode_rom/data<0>1_map1534_0 ;
  wire \vga/scancode_convert/scancode_rom/data<4>1_map1560_0 ;
  wire \vga/scancode_convert/scancode_rom/data<4>1_map1565_0 ;
  wire \vga/scancode_convert/scancode_rom/data<4>1_map1609_0 ;
  wire \vga/N11_0 ;
  wire \vga/N12_0 ;
  wire \vga/rom_addr_char<2>_f51_0 ;
  wire \vga/N10_0 ;
  wire \vga/rom_addr_char_1_1_7 ;
  wire \vga/scancode_convert/scancode_rom/data<4>1_map1666_0 ;
  wire \vga/N21_0 ;
  wire \vga/N22_0 ;
  wire \vga/rom_addr_char<2>_f53_0 ;
  wire \vga/N20_0 ;
  wire \vga/vgacore/vcnt_1_1_8 ;
  wire N3146_0;
  wire \vga/N16_0 ;
  wire \vga/N17_0 ;
  wire \vga/vgacore/N51_0 ;
  wire \vga/vgacore/vcnt_2_1_9 ;
  wire \vga/pixel<8>_map785_0 ;
  wire N3222_0;
  wire \vga/N29_0 ;
  wire \vga/N30_0 ;
  wire \vga/rom_addr_char<2>_f55_0 ;
  wire \vga/N27_0 ;
  wire \vga/N28_0 ;
  wire \vga/rom_addr_char<3>_f62_0 ;
  wire \vga/N25_0 ;
  wire \vga/N26_0 ;
  wire \vga/N23_0 ;
  wire \vga/N24_0 ;
  wire \vga/N7_0 ;
  wire \vga/N37_0 ;
  wire \vga/rom_addr_char<2>_f57_0 ;
  wire \vga/N35_0 ;
  wire \vga/rom_addr_char<3>_f63_0 ;
  wire \vga/N33_0 ;
  wire \vga/N34_0 ;
  wire \vga/N31_0 ;
  wire \vga/N32_0 ;
  wire \vga/N45_0 ;
  wire \vga/N43_0 ;
  wire \vga/N44_0 ;
  wire \vga/rom_addr_char<2>_f58_0 ;
  wire \vga/N40_0 ;
  wire \vga/N41_0 ;
  wire \vga/N38_0 ;
  wire \vga/N39_0 ;
  wire \vga/rom_addr_char<2>_f59_0 ;
  wire \vga/N113_0 ;
  wire \vga/N75_0 ;
  wire \vga/rom_addr_char<2>_f5111_0 ;
  wire \vga/N72_0 ;
  wire \vga/N99_0 ;
  wire \vga/rom_addr_char<3>_f65_0 ;
  wire \vga/scancode_convert/sc_0_1_10 ;
  wire \vga/scancode_convert/scancode_rom/data<5>3_map1337_0 ;
  wire \vga/N224_0 ;
  wire N3150_0;
  wire \vga/N14 ;
  wire \vga/N15_0 ;
  wire \vga/N13_0 ;
  wire \vga/rom_addr_char<1>112_0 ;
  wire \vga/rom_addr_char<1>_mmx_out_0 ;
  wire \vga/rom_addr_char<1>2_0 ;
  wire \vga/rom_addr_char<3>_f5_0 ;
  wire \vga/scancode_convert/scancode_rom/data<0>1_map1461_0 ;
  wire \vga/scancode_convert/scancode_rom/data<0>1_map1475_0 ;
  wire \vga/scancode_convert/scancode_rom/data<0>1_map1449_0 ;
  wire \vga/scancode_convert/scancode_rom/N7 ;
  wire N3104_0;
  wire \vga/rom_addr_char<2>11_0 ;
  wire \vga/rom_addr_char<2>2_0 ;
  wire \vga/rom_addr_char<3>_f621_0 ;
  wire \vga/rom_addr_char<3>_f631_0 ;
  wire \vga/rom_addr_char<3>_f64_0 ;
  wire \vga/rom_addr_char<5>_f5_0 ;
  wire \vga/scancode_convert/scancode_rom/N12 ;
  wire N3126_0;
  wire \vga/crt/state_FFd3_11 ;
  wire \vga/crt/state_FFd2_12 ;
  wire \vga/crt/state_FFd1_13 ;
  wire \vga/scancode_convert/key_up_14 ;
  wire \vga/scancode_convert/strobe_out_15 ;
  wire \vga/crt/scroll_0 ;
  wire \vga/crt/eol_0 ;
  wire \vga/ps2/error_r_16 ;
  wire \vga/ps2/_cmp_eq0001 ;
  wire \vga/vgacore/vcnt_0_1_17 ;
  wire \vga/rom_addr_char_0_1_18 ;
  wire \vga/charload_19 ;
  wire \vga/cursor_match_0 ;
  wire \vga/charload2_map865_0 ;
  wire \vga/N142_0 ;
  wire \vga/N143_0 ;
  wire \vga/rom_addr_char<2>_f511_0 ;
  wire \vga/rom_addr_char<3>_f612_0 ;
  wire \vga/N53_0 ;
  wire \vga/rom_addr_char<2>_f5112_0 ;
  wire \vga/rom_addr_char<3>_f6123_0 ;
  wire \vga/N94_0 ;
  wire \vga/N95_0 ;
  wire N3166_0;
  wire \vga/rom_addr_char<2>_f51234_0 ;
  wire \vga/N2_0 ;
  wire \vga/rom_addr_char<2>_f511234_0 ;
  wire \vga/N186_0 ;
  wire \vga/rom_addr_char<3>_f612345_0 ;
  wire \vga/charload3_map953_0 ;
  wire \vga/N70_0 ;
  wire \vga/N71_0 ;
  wire \vga/rom_addr_char<2>_f51112_0 ;
  wire \vga/N68_0 ;
  wire \vga/N69_0 ;
  wire \vga/charload4_map979_0 ;
  wire \vga/scancode_convert/scancode_rom/data<1>2_map1751_0 ;
  wire \vga/rom_addr_char<3>_f6212_0 ;
  wire \vga/rom_addr_char<3>_f6312_0 ;
  wire \vga/rom_addr_char<3>_f641_0 ;
  wire \vga/rom_addr_char<3>_f651_0 ;
  wire \vga/rom_addr_char<5>_f51_0 ;
  wire \vga/rom_addr_char<3>_f61123_0 ;
  wire \vga/rom_addr_char<3>_f62123_0 ;
  wire \vga/rom_addr_char<3>_f63123_0 ;
  wire \vga/rom_addr_char<3>_f6412_0 ;
  wire \vga/rom_addr_char<5>_f512_0 ;
  wire \vga/rom_addr_char<3>_f621234_0 ;
  wire \vga/rom_addr_char<3>_f631234_0 ;
  wire \vga/rom_addr_char<3>_f64123_0 ;
  wire \vga/rom_addr_char<5>_f5123_0 ;
  wire \vga/charload5_map965_0 ;
  wire \vga/charload7_map993_0 ;
  wire \vga/scancode_convert/scancode_rom/data<4>1_map1548_0 ;
  wire \vga/ram_we_n ;
  wire \vga/scancode_convert/scancode_rom/data<1>2_map1717_0 ;
  wire \vga/scancode_convert/scancode_rom/data<1>2_map1729_0 ;
  wire \vga/scancode_convert/scancode_rom/data<1>2_map1701_0 ;
  wire \vga/scancode_convert/scancode_rom/data<1>2_map1708_0 ;
  wire N3106_0;
  wire \vga/N4 ;
  wire N3164_0;
  wire \vga/crt/newline_20 ;
  wire \vga/crt/_cmp_eq0001_0 ;
  wire N3144_0;
  wire \vga/N138_0 ;
  wire \vga/N139_0 ;
  wire \vga/N47_0 ;
  wire \vga/N137_0 ;
  wire \vga/N49_0 ;
  wire \vga/N50_0 ;
  wire \vga/N48_0 ;
  wire \vga/N155_0 ;
  wire \vga/N64_0 ;
  wire \vga/N104_0 ;
  wire \vga/N105_0 ;
  wire \vga/rom_addr_char<2>_f52123_0 ;
  wire \vga/rom_addr_char<3>_f61234_0 ;
  wire \vga/N150_0 ;
  wire \vga/N151_0 ;
  wire \vga/rom_addr_char<2>_f531_0 ;
  wire \vga/N55_0 ;
  wire \vga/N149_0 ;
  wire \vga/rom_addr_char<3>_f611_0 ;
  wire \vga/N184_0 ;
  wire \vga/N8 ;
  wire \vga/N183_0 ;
  wire \vga/N59_0 ;
  wire \vga/N60_0 ;
  wire \vga/rom_addr_char<2>_f5312_0 ;
  wire \vga/N58_0 ;
  wire \vga/rom_addr_char<3>_f6112_0 ;
  wire \vga/N101_0 ;
  wire \vga/N102_0 ;
  wire \vga/N146_0 ;
  wire \vga/N147_0 ;
  wire \vga/N144_0 ;
  wire \vga/N145_0 ;
  wire \vga/N194_0 ;
  wire \vga/rom_addr_char<2>_f531234_0 ;
  wire \vga/N193_0 ;
  wire \vga/rom_addr_char<3>_f611234_0 ;
  wire \vga/N56_0 ;
  wire \vga/N57_0 ;
  wire \vga/N54_0 ;
  wire \vga/N127_0 ;
  wire \vga/N128_0 ;
  wire \vga/rom_addr_char<2>_f54123_0 ;
  wire \vga/N125_0 ;
  wire \vga/N126_0 ;
  wire \vga/rom_addr_char<2>_f551_0 ;
  wire \vga/N171_0 ;
  wire \vga/N172_0 ;
  wire \vga/N191_0 ;
  wire \vga/N192_0 ;
  wire \vga/N190_0 ;
  wire \vga/N82_0 ;
  wire \vga/N83_0 ;
  wire \vga/rom_addr_char<2>_f5512_0 ;
  wire \vga/N80_0 ;
  wire \vga/N81_0 ;
  wire \vga/N78_0 ;
  wire \vga/N79_0 ;
  wire \vga/N121_0 ;
  wire \vga/N170_0 ;
  wire \vga/N167_0 ;
  wire \vga/N213_0 ;
  wire \vga/rom_addr_char<2>_f551234_0 ;
  wire N3170_0;
  wire \vga/N133_0 ;
  wire \vga/N134_0 ;
  wire \vga/rom_addr_char<2>_f56123_0 ;
  wire \vga/N131_0 ;
  wire \vga/N132_0 ;
  wire N3160_0;
  wire \vga/rom_addr_char<2>_f571_0 ;
  wire \vga/N178_0 ;
  wire \vga/N179_0 ;
  wire N3148_0;
  wire \vga/N208_0 ;
  wire \vga/N89_0 ;
  wire \vga/N90_0 ;
  wire \vga/rom_addr_char<2>_f5712_0 ;
  wire \vga/N87_0 ;
  wire \vga/N88_0 ;
  wire \vga/N129_0 ;
  wire \vga/N130_0 ;
  wire \vga/N176_0 ;
  wire \vga/N86_0 ;
  wire \vga/N175_0 ;
  wire \vga/rom_addr_char<2>_f571234_0 ;
  wire \vga/N218_0 ;
  wire \vga/N219_0 ;
  wire \vga/N85_0 ;
  wire N3172_0;
  wire \vga/rom_addr_char<2>_f58123_0 ;
  wire \vga/N110_0 ;
  wire \vga/N111_0 ;
  wire \vga/N67_0 ;
  wire \vga/N159_0 ;
  wire \vga/rom_addr_char<2>_f591_0 ;
  wire \vga/N65_0 ;
  wire \vga/N157_0 ;
  wire \vga/N216_0 ;
  wire \vga/N214_0 ;
  wire \vga/N215_0 ;
  wire \vga/rom_addr_char<2>_f5912_0 ;
  wire \vga/N66_0 ;
  wire \vga/N63_0 ;
  wire \vga/N106_0 ;
  wire \vga/N62_0 ;
  wire \vga/N152_0 ;
  wire \vga/rom_addr_char<2>_f591234_0 ;
  wire \vga/N205_0 ;
  wire \vga/N61_0 ;
  wire \vga/N120_0 ;
  wire \vga/rom_addr_char<2>_f51012_0 ;
  wire \vga/N117_0 ;
  wire \vga/N118_0 ;
  wire \vga/N74_0 ;
  wire \vga/N73_0 ;
  wire \vga/N201_0 ;
  wire \vga/N115_0 ;
  wire \vga/N116_0 ;
  wire \vga/N114_0 ;
  wire \vga/scancode_convert/scancode_rom/data<5>3_map1249_0 ;
  wire \vga/scancode_convert/scancode_rom/data<5>3_map1245_0 ;
  wire \vga/scancode_convert/scancode_rom/data<5>3_map1260_0 ;
  wire N3112_0;
  wire \vga/crt/Madd_ram_addrR2_0 ;
  wire \vga/ram_addr_write<5>_0 ;
  wire \vga/ram_addr_write<6>_0 ;
  wire \vga/ram_addr_write<8>_0 ;
  wire \vga/ram_addr_write<9>_0 ;
  wire \vga/ram_addr_write<10>_0 ;
  wire \vga/ram_addr_write<11>_0 ;
  wire GLOBAL_LOGIC1;
  wire GLOBAL_LOGIC0;
  wire \vga/vgacore/Mcompar__cmp_lt0000_cy<4>_0 ;
  wire \vga/vgacore/hblank_21 ;
  wire \vga/Madd_ram_addr_videoR2_0 ;
  wire \vga/ram_addr_video<5>_0 ;
  wire \vga/ram_addr_video<6>_0 ;
  wire \vga/ram_addr_video<8>_0 ;
  wire \vga/ram_addr_video<9>_0 ;
  wire \vga/ram_addr_video<10>_0 ;
  wire \vga/ram_addr_video<11>_0 ;
  wire \vga/ps2/_addsub0000<1>_0 ;
  wire \vga/ps2/_addsub0000<2>_0 ;
  wire \vga/ps2/_addsub0000<3>_0 ;
  wire \vga/ps2/_addsub0000<4>_0 ;
  wire \vga/ps2/_addsub0000<5>_0 ;
  wire \vga/ps2/_addsub0000<6>_0 ;
  wire \vga/ps2/_addsub0000<7>_0 ;
  wire \vga/ps2/_addsub0000<8>_0 ;
  wire \vga/ps2/_addsub0000<9>_0 ;
  wire \vga/ps2/_addsub0000<10>_0 ;
  wire \vga/ps2/_addsub0000<11>_0 ;
  wire \vga/ps2/_addsub0000<12>_0 ;
  wire \vga/ps2/_addsub0000<13>_0 ;
  wire \vga/crt/Result<1>_0 ;
  wire \vga/crt/Result<2>_0 ;
  wire \vga/crt/Result<3>_0 ;
  wire \vga/crt/Result<4>_0 ;
  wire \vga/crt/Result<5>_0 ;
  wire \vga/crt/Result<1>1_0 ;
  wire \vga/crt/Result<2>1_0 ;
  wire \vga/crt/Result<3>1_0 ;
  wire \vga/crt/Result<4>1_0 ;
  wire \vga/crt/Result<5>1_0 ;
  wire \vga/crt/Result<6>_0 ;
  wire \vga/vgacore/hcnt_Eqn_bis_0 ;
  wire \vga/vgacore/vcnt_Eqn_bis_0_0 ;
  wire N839_0;
  wire \vga/vgacore/Result<1>1_0 ;
  wire \vga/vgacore/Result<2>1_0 ;
  wire N786_0;
  wire \vga/vgacore/N0 ;
  wire \vga/scancode_convert/scancode_rom/data<0>1437/O ;
  wire \vga/scancode_convert/scancode_rom/data<0>1_map1526_0 ;
  wire \vga/scancode_convert/scancode_rom/data<0>1_map1529_0 ;
  wire \vga/scancode_convert/ctrl_22 ;
  wire \vga/scancode_convert/sc_1_1_23 ;
  wire \vga/scancode_convert/shift_24 ;
  wire \vga/scancode_convert/capslock_25 ;
  wire \vga/scancode_convert/scancode_rom/data<0>1_map1503_0 ;
  wire \vga/scancode_convert/scancode_rom/data<0>1539/O ;
  wire \vga/scancode_convert/scancode_rom/data<0>1_map1445_0 ;
  wire \vga/scancode_convert/scancode_rom/data<6>1_map1808_0 ;
  wire N3085_0;
  wire \vga/scancode_convert/_cmp_eq00041_SW0/O ;
  wire \vga/scancode_convert/N10_0 ;
  wire \vga/scancode_convert/scancode_rom/data<1>2465/O ;
  wire \vga/scancode_convert/scancode_rom/data<1>2_map1690_0 ;
  wire \vga/scancode_convert/scancode_rom/data<2>1264/O ;
  wire \vga/scancode_convert/scancode_rom/data<2>1_map1121_0 ;
  wire \vga/scancode_convert/scancode_rom/data<2>1_map1124_0 ;
  wire \vga/scancode_convert/scancode_rom/data<2>1_map1129_0 ;
  wire \vga/scancode_convert/scancode_rom/data<2>1410/O ;
  wire \vga/scancode_convert/scancode_rom/data<3>199/O ;
  wire N3174_0;
  wire \vga/scancode_convert/scancode_rom/data<4>1308_SW1/O ;
  wire \vga/scancode_convert/N31 ;
  wire \vga/scancode_convert/N11_0 ;
  wire \vga/scancode_convert/scancode_rom/data<4>1392_SW0/O ;
  wire \vga/scancode_convert/scancode_rom/data<6>1_map1820_0 ;
  wire \vga/scancode_convert/scancode_rom/data<6>1_map1803_0 ;
  wire \vga/scancode_convert/scancode_rom/data<6>1247/O ;
  wire \vga/scancode_convert/scancode_rom/data<6>1_map1863_0 ;
  wire \vga/scancode_convert/scancode_rom/data<5>3247/O ;
  wire \vga/scancode_convert/scancode_rom/data<5>3_map1276_0 ;
  wire \vga/scancode_convert/scancode_rom/data<5>3_map1295_0 ;
  wire \vga/scancode_convert/scancode_rom/data<5>3359/O ;
  wire \vga/scancode_convert/scancode_rom/data<5>3_map1340_0 ;
  wire N3130_0;
  wire \vga/scancode_convert/scancode_rom/data<6>1333/O ;
  wire \vga/scancode_convert/scancode_rom/data<6>1_map1850_0 ;
  wire \vga/scancode_convert/scancode_rom/data<5>3_map1394_0 ;
  wire \vga/scancode_convert/scancode_rom/data<5>3852_SW0/O ;
  wire N3136_0;
  wire \vga/scancode_convert/scancode_rom/data<5>3_map1416_0 ;
  wire \vga/scancode_convert/scancode_rom/data<5>3664/O ;
  wire \vga/scancode_convert/scancode_rom/data<5>3_map1363_0 ;
  wire \vga/scancode_convert/scancode_rom/data<5>3_map1381_0 ;
  wire \vga/scancode_convert/scancode_rom/data<5>3895_SW0/O ;
  wire N3108_0;
  wire \vga/scancode_convert/release_prefix_26 ;
  wire \vga/scancode_convert/_and0000_0 ;
  wire \vga/scancode_convert/_cmp_eq0000_27 ;
  wire \vga/scancode_convert/state_FFd2-In_SW0/O ;
  wire \vga/scancode_convert/state_FFd2_28 ;
  wire \vga/scancode_convert/state_FFd3-In_SW0/O ;
  wire \vga/scancode_convert/state_FFd3_29 ;
  wire N306_0;
  wire \vga/crt/_and0000_SW0/O ;
  wire \vga/crt/_and0000_0 ;
  wire \vga/crt/eol_SW0/O ;
  wire N3100_0;
  wire \vga/scancode_convert/state_FFd4_30 ;
  wire \vga/scancode_convert/state_FFd5_31 ;
  wire \vga/scancode_convert/_not0010_0 ;
  wire \vga/crt/scroll_SW0/O ;
  wire \vga/scancode_convert/state_FFd4-In24/O ;
  wire \vga/crt/_not0007_0 ;
  wire N235_0;
  wire \vga/crt/_and0001_32 ;
  wire \vga/scancode_convert/scancode_rom/N18_0 ;
  wire \vga/scancode_convert/scancode_rom/data<1>218/O ;
  wire \vga/scancode_convert/scancode_rom/N25 ;
  wire \vga/scancode_convert/shift_set_map833 ;
  wire \vga/scancode_convert/_not0007_0 ;
  wire \vga/scancode_convert/scancode_rom/data<3>126_SW1/O ;
  wire \vga/scancode_convert/scancode_rom/N43_0 ;
  wire \vga/scancode_convert/scancode_rom/data<4>145/O ;
  wire \vga/scancode_convert/raise1_33 ;
  wire N3124_0;
  wire \vga/_and0000_map879_0 ;
  wire \vga/_and0000_map890_0 ;
  wire \vga/_and000093/O ;
  wire \vga/_and0000_map943_0 ;
  wire \vga/scancode_convert/scancode_rom/data<0>1_map1429_0 ;
  wire \vga/scancode_convert/scancode_rom/data<0>1_map1438_0 ;
  wire \vga/scancode_convert/scancode_rom/data<0>176/O ;
  wire \vga/scancode_convert/scancode_rom/data<0>1_map1423_0 ;
  wire N3178_0;
  wire \vga/scancode_convert/scancode_rom/data<0>1370_SW1/O ;
  wire \vga/crt/_not0008_0 ;
  wire \vga/scancode_convert/_cmp_eq0005 ;
  wire \vga/scancode_convert/state_FFd1_34 ;
  wire \vga/scancode_convert/_not0012_0 ;
  wire N124_0;
  wire \vga/scancode_convert/state_FFd6_35 ;
  wire \vga/scancode_convert/shift_set_map836_0 ;
  wire \vga/scancode_convert/capslock_toggle_0 ;
  wire \vga/ps2/ps2_clk_edge ;
  wire \vga/ps2/error_x_map855_0 ;
  wire \vga/ram_addr_write<7>_0 ;
  wire \vga/ram_addr_video<7>_0 ;
  wire \vga/scancode_convert/_not0011_0 ;
  wire \vga/ps2/_cmp_eq0001_map1047_0 ;
  wire \vga/crt/_cmp_eq0004 ;
  wire \vga/crt/_not0010 ;
  wire \vga/clearing ;
  wire \vga/crt/N91 ;
  wire \vga/crt/_not0006_0 ;
  wire \vga/insert_crt_data ;
  wire \vga/N222_0 ;
  wire \vga/N221_0 ;
  wire \vga/N98_0 ;
  wire \vga/N96_0 ;
  wire N3162;
  wire \vga/scancode_convert/_not0009_0 ;
  wire N3158;
  wire \vga/crt/Madd_ram_addrC2 ;
  wire \vga/rom_addr_char<4>11234_0 ;
  wire N562;
  wire gray_cnt_FFd2_36;
  wire \vga/Madd_ram_addr_videoC2 ;
  wire \vga/ps2/_cmp_eq0000_0 ;
  wire \vga/ps2/_cmp_eq0001_map1032_0 ;
  wire N3132_0;
  wire \vga/vgacore/_and0000_map807 ;
  wire \vga/vgacore/_and0000_map811_0 ;
  wire \vga/N6_0 ;
  wire \vga/N0112 ;
  wire \vga/N11123_0 ;
  wire \vga/N011234567 ;
  wire \vga/N1112_0 ;
  wire \vga/crt/state_FFd3-In_map800 ;
  wire N116_0;
  wire N117;
  wire \vga/crt/N16 ;
  wire \vga/_and0000_map918_0 ;
  wire \vga/charload6_map1018_0 ;
  wire \vga/charload6_map1022 ;
  wire \vga/_and0000_map929_0 ;
  wire \vga/ps2/_cmp_eq0001_map1035_0 ;
  wire \vga/_and0000_map940_0 ;
  wire \vga/_and0000_map941 ;
  wire \vga/ps2/_cmp_eq0001_map1041_0 ;
  wire \vga/vgacore/_and0000_map817_0 ;
  wire \vga/vgacore/_and0000_map824_0 ;
  wire \vga/vgacore/_and0000_map825 ;
  wire \vga/charload6_map1010 ;
  wire \vga/charload6_map1012_0 ;
  wire \vga/charload6_map1014 ;
  wire N44;
  wire N89;
  wire \ps2_clk/IDELAY ;
  wire ps2_clk_IBUF_37;
  wire \fpga_d1/OUTMUX_38 ;
  wire \fpga_d2/OUTMUX_39 ;
  wire \fpga_d3/OUTMUX_40 ;
  wire \fpga_d4/OUTMUX_41 ;
  wire \fpga_d5/OUTMUX_42 ;
  wire \fpga_d6/OUTMUX_43 ;
  wire \fpga_d7/OUTMUX_44 ;
  wire \ps2_data/IDELAY ;
  wire ps2_data_IBUF_45;
  wire \fpga_din_d0/OUTMUX_46 ;
  wire \vga_blue0/OUTMUX_47 ;
  wire \vga_blue1/OUTMUX_48 ;
  wire \vga_vsync_n/OUTMUX_49 ;
  wire \vga_blue2/OUTMUX_50 ;
  wire \vga_hsync_n/OUTMUX_51 ;
  wire \vga_red0/OUTMUX_52 ;
  wire \vga_red1/OUTMUX_53 ;
  wire \vga_red2/OUTMUX_54 ;
  wire reset_n_IBUF_55;
  wire \vga_green0/OUTMUX_56 ;
  wire \vga_green1/OUTMUX_57 ;
  wire \vga_green2/OUTMUX_58 ;
  wire \vga/inst_Mram_mem11/DOA0 ;
  wire \vga/inst_Mram_mem11/DIB0 ;
  wire \vga/inst_Mram_mem11/LOGIC_ZERO_59 ;
  wire \vga/inst_Mram_mem11/LOGIC_ONE_60 ;
  wire \vga/inst_Mram_mem11/CLKB_INTNOT ;
  wire \vga/inst_Mram_mem21/DOA0 ;
  wire \vga/inst_Mram_mem21/DIB0 ;
  wire \vga/inst_Mram_mem21/LOGIC_ZERO_61 ;
  wire \vga/inst_Mram_mem21/LOGIC_ONE_62 ;
  wire \vga/inst_Mram_mem21/CLKB_INTNOT ;
  wire \vga/inst_Mram_mem31/DOA0 ;
  wire \vga/inst_Mram_mem31/DIB0 ;
  wire \vga/inst_Mram_mem31/LOGIC_ZERO_63 ;
  wire \vga/inst_Mram_mem31/LOGIC_ONE_64 ;
  wire \vga/inst_Mram_mem31/CLKB_INTNOT ;
  wire \vga/inst_Mram_mem41/DOA0 ;
  wire \vga/inst_Mram_mem41/DIB0 ;
  wire \vga/inst_Mram_mem41/LOGIC_ZERO_65 ;
  wire \vga/inst_Mram_mem41/LOGIC_ONE_66 ;
  wire \vga/inst_Mram_mem41/CLKB_INTNOT ;
  wire \vga/inst_Mram_mem51/DOA0 ;
  wire \vga/inst_Mram_mem51/DIB0 ;
  wire \vga/inst_Mram_mem51/LOGIC_ZERO_67 ;
  wire \vga/inst_Mram_mem51/LOGIC_ONE_68 ;
  wire \vga/inst_Mram_mem51/CLKB_INTNOT ;
  wire \vga/inst_Mram_mem61/DOA0 ;
  wire \vga/inst_Mram_mem61/DIB0 ;
  wire \vga/inst_Mram_mem61/LOGIC_ZERO_69 ;
  wire \vga/inst_Mram_mem61/LOGIC_ONE_70 ;
  wire \vga/inst_Mram_mem61/CLKB_INTNOT ;
  wire \vga/inst_Mram_mem8/DOA0 ;
  wire \vga/inst_Mram_mem8/DIB0 ;
  wire \vga/inst_Mram_mem8/LOGIC_ZERO_71 ;
  wire \vga/inst_Mram_mem8/LOGIC_ONE_72 ;
  wire \vga/inst_Mram_mem8/CLKB_INTNOT ;
  wire N3199;
  wire N3198;
  wire N3084;
  wire N3187;
  wire N3186;
  wire \vga/scancode_convert/scancode_rom/data<1>2_map1774 ;
  wire N3245;
  wire \vga/scancode_convert/scancode_rom/data<3>1_map1229/GROM ;
  wire \vga/scancode_convert/scancode_rom/data<3>1_map1229 ;
  wire N3201;
  wire N3200;
  wire \vga/scancode_convert/scancode_rom/data<2>1_map1098 ;
  wire N3193;
  wire N3192;
  wire N560;
  wire N3117;
  wire N3116;
  wire N3191;
  wire N3190;
  wire \vga/scancode_convert/scancode_rom/data<3>1_map1221 ;
  wire N3119;
  wire N3118;
  wire \vga/scancode_convert/scancode_rom/data<4>1_map1633 ;
  wire N3121;
  wire N3120;
  wire \vga/N2123 ;
  wire \vga/N312 ;
  wire \vga/rom_addr_char<2>_f51_73 ;
  wire N3203;
  wire N3202;
  wire \vga/scancode_convert/scancode_rom/data<4>1_map1666 ;
  wire \vga/N412 ;
  wire \vga/N512 ;
  wire \vga/rom_addr_char<3>_f61_74 ;
  wire \vga/rom_addr_char<2>_f52_75 ;
  wire \vga/N612 ;
  wire \vga/N712 ;
  wire \vga/rom_addr_char<2>_f53_76 ;
  wire N3221;
  wire \vga/pixel<8>_map785 ;
  wire N3222;
  wire \vga/N912 ;
  wire \vga/N1011 ;
  wire \vga/rom_addr_char<3>_f62_77 ;
  wire \vga/rom_addr_char<2>_f54_78 ;
  wire \vga/N1111 ;
  wire \vga/N1211 ;
  wire \vga/rom_addr_char<2>_f55 ;
  wire \vga/N1311 ;
  wire \vga/N1411 ;
  wire \vga/rom_addr_char<3>_f63_79 ;
  wire \vga/rom_addr_char<2>_f56 ;
  wire N3078;
  wire \vga/N1611 ;
  wire \vga/rom_addr_char<2>_f57 ;
  wire \vga/N1711 ;
  wire \vga/N1811 ;
  wire \vga/rom_addr_char<2>_f58 ;
  wire \vga/N2011 ;
  wire \vga/N2111 ;
  wire \vga/rom_addr_char<2>_f59 ;
  wire \vga/N2112 ;
  wire \vga/N2212 ;
  wire \vga/rom_addr_char<3>_f65 ;
  wire \vga/rom_addr_char<2>_f510 ;
  wire N3215;
  wire N3214;
  wire \vga/scancode_convert/scancode_rom/data<5>3_map1337 ;
  wire N3259;
  wire \N3150/GROM ;
  wire N3150;
  wire \vga/N01 ;
  wire \vga/N1101 ;
  wire \vga/rom_addr_char<3>_f6_80 ;
  wire \vga/rom_addr_char<2>_f5_85 ;
  wire \vga/N1712345 ;
  wire \vga/N1812345 ;
  wire \vga/rom_addr_char<3>_f5_86 ;
  wire N3189;
  wire N3188;
  wire N3104;
  wire \vga/N1911 ;
  wire \vga/N2211 ;
  wire \vga/rom_addr_char<4>_f5_87 ;
  wire \vga/N1612 ;
  wire \vga/N251 ;
  wire \vga/rom_addr_char<5>_f5_88 ;
  wire N3254;
  wire N3255;
  wire N3126;
  wire N3226;
  wire N3227;
  wire \vga/crt/state_FFd2-In ;
  wire N3207;
  wire N3206;
  wire \vga/ps2/bitcnt_r<2>/FFX/RST ;
  wire N3224;
  wire N3225;
  wire \vga/ps2/bitcnt_r<0>/FFX/RST ;
  wire N3230;
  wire N3231;
  wire \vga/ps2/bitcnt_r<1>/FFX/RST ;
  wire N3242;
  wire N3243;
  wire \vga/scancode_convert/scancode_rom/data<2>1_map1056 ;
  wire N3261;
  wire N3262;
  wire \vga/rom_addr_char<1>_mmx_out ;
  wire N3228;
  wire N3229;
  wire \vga/N01123 ;
  wire \vga/N111234 ;
  wire \vga/rom_addr_char<3>_f612 ;
  wire \vga/rom_addr_char<2>_f512 ;
  wire \vga/vgacore/N51/FROM ;
  wire N3244;
  wire \vga/vgacore/N51 ;
  wire \vga/N011234 ;
  wire \vga/N1112345 ;
  wire \vga/rom_addr_char<3>_f6123 ;
  wire \vga/rom_addr_char<2>_f5123 ;
  wire \vga/N0112345 ;
  wire \vga/N11123456 ;
  wire \vga/rom_addr_char<2>_f51234 ;
  wire \vga/N01123456 ;
  wire \vga/N111234567 ;
  wire \vga/rom_addr_char<3>_f612345 ;
  wire \vga/rom_addr_char<2>_f512345 ;
  wire N3233;
  wire \vga/pixel_hold<0>_rt_89 ;
  wire \vga/N231 ;
  wire \vga/N2412 ;
  wire \vga/rom_addr_char<2>_f51112 ;
  wire N3236;
  wire N3237;
  wire N3249;
  wire N3250;
  wire \vga/scancode_convert/scancode_rom/data<1>2_map1751 ;
  wire \vga/N16123 ;
  wire \vga/N2512 ;
  wire \vga/rom_addr_char<5>_f51_90 ;
  wire \vga/N141234 ;
  wire \vga/N23123 ;
  wire \vga/rom_addr_char<5>_f512 ;
  wire \vga/N1612345 ;
  wire \vga/N231234 ;
  wire \vga/rom_addr_char<5>_f5123 ;
  wire N3234;
  wire N3235;
  wire N3205;
  wire N3204;
  wire \vga/ps2/bitcnt_r<3>/FFX/RST ;
  wire N3238;
  wire N3239;
  wire N3256;
  wire N3257;
  wire \vga/scancode_convert/scancode_rom/data<3>1_map1171 ;
  wire N3248;
  wire \vga/scancode_convert/sc<3>_rt_91 ;
  wire \vga/scancode_convert/scancode_rom/data<4>1_map1548 ;
  wire N3219;
  wire N3220;
  wire N3185;
  wire N3184;
  wire N3106;
  wire N3211;
  wire N3210;
  wire \vga/charload2_map865 ;
  wire N3209;
  wire N3208;
  wire N3144;
  wire N3195;
  wire N3194;
  wire \vga/rom_addr_char<1>112_92 ;
  wire N3197;
  wire N3196;
  wire \vga/rom_addr_char<1>2_93 ;
  wire \vga/N21234 ;
  wire \vga/N3123 ;
  wire \vga/rom_addr_char<2>_f511 ;
  wire \vga/N212345 ;
  wire \vga/N31234 ;
  wire \vga/rom_addr_char<2>_f5112 ;
  wire N3079;
  wire \vga/N241 ;
  wire \vga/rom_addr_char<2>_f5111 ;
  wire \vga/N2123456 ;
  wire \vga/N312345 ;
  wire \vga/rom_addr_char<3>_f61234 ;
  wire \vga/rom_addr_char<2>_f51123 ;
  wire \vga/N4123 ;
  wire \vga/N5 ;
  wire \vga/rom_addr_char<3>_f611 ;
  wire \vga/rom_addr_char<2>_f521 ;
  wire \vga/N21234567 ;
  wire \vga/N3123456 ;
  wire \vga/rom_addr_char<2>_f511234 ;
  wire \vga/N41234 ;
  wire \vga/N5123 ;
  wire \vga/rom_addr_char<3>_f6112 ;
  wire \vga/rom_addr_char<2>_f5212 ;
  wire \vga/N412345 ;
  wire \vga/N51234 ;
  wire \vga/rom_addr_char<2>_f52123 ;
  wire \vga/N6123 ;
  wire \vga/N7123 ;
  wire \vga/rom_addr_char<2>_f531 ;
  wire \vga/N4123456 ;
  wire \vga/N512345 ;
  wire \vga/rom_addr_char<3>_f611234 ;
  wire \vga/rom_addr_char<2>_f521234 ;
  wire \vga/N61234 ;
  wire \vga/N71234 ;
  wire \vga/rom_addr_char<2>_f5312 ;
  wire \vga/N612345 ;
  wire \vga/N712345 ;
  wire \vga/rom_addr_char<3>_f61123 ;
  wire \vga/rom_addr_char<2>_f53123 ;
  wire \vga/N8123 ;
  wire \vga/N9 ;
  wire \vga/rom_addr_char<3>_f621 ;
  wire \vga/rom_addr_char<2>_f541 ;
  wire \vga/N6123456 ;
  wire \vga/N7123456 ;
  wire \vga/rom_addr_char<2>_f531234 ;
  wire \vga/N81234 ;
  wire \vga/N91 ;
  wire \vga/rom_addr_char<3>_f6212 ;
  wire \vga/rom_addr_char<2>_f5412 ;
  wire \vga/N10123 ;
  wire \vga/N9123 ;
  wire \vga/rom_addr_char<2>_f54123 ;
  wire \vga/N1012 ;
  wire \vga/N11112 ;
  wire \vga/rom_addr_char<2>_f551 ;
  wire \vga/N8123456 ;
  wire \vga/N91234 ;
  wire \vga/rom_addr_char<3>_f621234 ;
  wire \vga/rom_addr_char<2>_f541234 ;
  wire N3080;
  wire \vga/N111123 ;
  wire \vga/rom_addr_char<2>_f5512 ;
  wire \vga/N101234 ;
  wire \vga/N1110 ;
  wire \vga/rom_addr_char<3>_f62123 ;
  wire \vga/rom_addr_char<2>_f55123 ;
  wire \vga/N1212 ;
  wire \vga/N1312 ;
  wire \vga/rom_addr_char<3>_f631 ;
  wire \vga/rom_addr_char<2>_f561 ;
  wire \vga/N1012345 ;
  wire \vga/N1111234 ;
  wire \vga/rom_addr_char<2>_f551234 ;
  wire \vga/N12123 ;
  wire \vga/N13123 ;
  wire \vga/rom_addr_char<3>_f6312 ;
  wire \vga/rom_addr_char<2>_f5612 ;
  wire \vga/N121234 ;
  wire \vga/N131234 ;
  wire \vga/rom_addr_char<2>_f56123 ;
  wire \vga/N1412 ;
  wire \vga/N1512 ;
  wire \vga/rom_addr_char<2>_f571 ;
  wire \vga/N1212345 ;
  wire \vga/N1312345 ;
  wire \vga/rom_addr_char<3>_f631234 ;
  wire \vga/rom_addr_char<2>_f561234 ;
  wire \vga/N14123 ;
  wire \vga/N15123 ;
  wire \vga/rom_addr_char<2>_f5712 ;
  wire \vga/N151234 ;
  wire \vga/N161234 ;
  wire \vga/rom_addr_char<3>_f63123 ;
  wire \vga/rom_addr_char<2>_f57123 ;
  wire \vga/N1712 ;
  wire \vga/N1812 ;
  wire \vga/rom_addr_char<3>_f64_94 ;
  wire \vga/rom_addr_char<2>_f581 ;
  wire \vga/N1412345 ;
  wire \vga/N1512345 ;
  wire \vga/rom_addr_char<2>_f571234 ;
  wire \vga/N17123 ;
  wire \vga/N18123 ;
  wire \vga/rom_addr_char<3>_f641 ;
  wire \vga/rom_addr_char<2>_f5812 ;
  wire \vga/N19123 ;
  wire \vga/N181234 ;
  wire \vga/rom_addr_char<2>_f58123 ;
  wire \vga/N1912 ;
  wire \vga/N2012 ;
  wire \vga/rom_addr_char<2>_f591 ;
  wire \vga/N1912345 ;
  wire \vga/N2012345 ;
  wire \vga/rom_addr_char<3>_f64123 ;
  wire \vga/rom_addr_char<2>_f581234 ;
  wire N3081;
  wire \vga/N20123 ;
  wire \vga/rom_addr_char<2>_f5912 ;
  wire \vga/N191234 ;
  wire \vga/N201234 ;
  wire \vga/rom_addr_char<3>_f6412 ;
  wire \vga/rom_addr_char<2>_f59123 ;
  wire \vga/N21123 ;
  wire \vga/N22123 ;
  wire \vga/rom_addr_char<3>_f651 ;
  wire \vga/rom_addr_char<2>_f5101 ;
  wire \vga/N1511 ;
  wire \vga/N2212345 ;
  wire \vga/rom_addr_char<2>_f591234 ;
  wire \vga/N211234 ;
  wire \vga/N221234 ;
  wire \vga/rom_addr_char<2>_f51012 ;
  wire N3264;
  wire N3265;
  wire \vga/scancode_convert/scancode_rom/data<3>1_map1201 ;
  wire N3213;
  wire N3212;
  wire N3112;
  wire \vga/crt/Madd_ram_addrC_mand1 ;
  wire \vga/ram_addr_write<5>/CYMUXG ;
  wire \vga/crt/Madd_ram_addrC1_mand1 ;
  wire \vga/crt/N8 ;
  wire \vga/crt/Madd_ram_addr_Madd_cy[5] ;
  wire \vga/ram_addr_write<5>/LOGIC_ZERO_95 ;
  wire \vga/crt/Madd_ram_addrC3_mand1 ;
  wire \vga/crt/N10 ;
  wire \vga/ram_addr_write<8>/CYMUXG ;
  wire \vga/crt/Madd_ram_addrC4_mand1 ;
  wire \vga/crt/N11 ;
  wire \vga/crt/Madd_ram_addr_Madd_cy[8] ;
  wire \vga/ram_addr_write<8>/CYINIT_96 ;
  wire \vga/crt/N12 ;
  wire \vga/crt/cursor_v<5>_rt_97 ;
  wire \vga/crt/Madd_ram_addr_Madd_cy[10] ;
  wire \vga/ram_addr_write<10>/CYINIT_98 ;
  wire \vga/vgacore/N4 ;
  wire \vga/vgacore/Mcompar__cmp_lt0000_cy<1>/CYMUXG ;
  wire \vga/vgacore/hcnt<4>_rt_99 ;
  wire \vga/vgacore/Mcompar__cmp_lt0000_cy[0] ;
  wire \vga/vgacore/Mcompar__cmp_lt0000_cy<1>/LOGIC_ZERO_100 ;
  wire \vga/vgacore/Mcompar__cmp_lt0000_cy<1>/LOGIC_ONE_101 ;
  wire \vga/vgacore/N5 ;
  wire \vga/vgacore/Mcompar__cmp_lt0000_cy<3>/CYMUXG ;
  wire \vga/vgacore/N6 ;
  wire \vga/vgacore/Mcompar__cmp_lt0000_cy[2] ;
  wire \vga/vgacore/Mcompar__cmp_lt0000_cy<3>/CYINIT_102 ;
  wire \vga/vgacore/hblank/LOGIC_ONE_103 ;
  wire \vga/vgacore/N7 ;
  wire \vga/vgacore/Mcompar__cmp_lt0000_cy[4] ;
  wire \vga/vgacore/hblank/CYINIT_104 ;
  wire \vga/vgacore/_mux0002 ;
  wire \vga/Madd_ram_addr_videoC_mand1 ;
  wire \vga/ram_addr_video<5>/CYMUXG ;
  wire \vga/Madd_ram_addr_videoC1_mand1 ;
  wire \vga/N229 ;
  wire \vga/Madd_ram_addr_video_Madd_cy[5] ;
  wire \vga/ram_addr_video<5>/LOGIC_ZERO_105 ;
  wire \vga/Madd_ram_addr_videoC3_mand1 ;
  wire \vga/N2313 ;
  wire \vga/ram_addr_video<8>/CYMUXG ;
  wire \vga/Madd_ram_addr_videoC4_mand1 ;
  wire \vga/N232 ;
  wire \vga/Madd_ram_addr_video_Madd_cy[8] ;
  wire \vga/ram_addr_video<8>/CYINIT_106 ;
  wire \vga/N233 ;
  wire \vga/vgacore/vcnt<8>_rt_107 ;
  wire \vga/Madd_ram_addr_video_Madd_cy[10] ;
  wire \vga/ram_addr_video<10>/CYINIT_108 ;
  wire \vga/ps2/N5 ;
  wire \vga/ps2/_addsub0000<1>/CYMUXG ;
  wire \vga/ps2/_addsub0000<1>/GROM ;
  wire \vga/ps2/Madd__addsub0000_cy[0] ;
  wire \vga/ps2/_addsub0000<1>/LOGIC_ZERO_109 ;
  wire \vga/ps2/_addsub0000<2>/FROM ;
  wire \vga/ps2/_addsub0000<2>/CYMUXG ;
  wire \vga/ps2/_addsub0000<2>/LOGIC_ZERO_110 ;
  wire \vga/ps2/_addsub0000<2>/GROM ;
  wire \vga/ps2/Madd__addsub0000_cy[2] ;
  wire \vga/ps2/_addsub0000<2>/CYINIT_111 ;
  wire \vga/ps2/_addsub0000<4>/FROM ;
  wire \vga/ps2/_addsub0000<4>/CYMUXG ;
  wire \vga/ps2/_addsub0000<4>/LOGIC_ZERO_112 ;
  wire \vga/ps2/_addsub0000<4>/GROM ;
  wire \vga/ps2/Madd__addsub0000_cy[4] ;
  wire \vga/ps2/_addsub0000<4>/CYINIT_113 ;
  wire \vga/ps2/_addsub0000<6>/FROM ;
  wire \vga/ps2/_addsub0000<6>/CYMUXG ;
  wire \vga/ps2/_addsub0000<6>/LOGIC_ZERO_114 ;
  wire \vga/ps2/_addsub0000<6>/GROM ;
  wire \vga/ps2/Madd__addsub0000_cy[6] ;
  wire \vga/ps2/_addsub0000<6>/CYINIT_115 ;
  wire \vga/ps2/_addsub0000<8>/FROM ;
  wire \vga/ps2/_addsub0000<8>/CYMUXG ;
  wire \vga/ps2/_addsub0000<8>/LOGIC_ZERO_116 ;
  wire \vga/ps2/_addsub0000<8>/GROM ;
  wire \vga/ps2/Madd__addsub0000_cy[8] ;
  wire \vga/ps2/_addsub0000<8>/CYINIT_117 ;
  wire \vga/ps2/_addsub0000<10>/FROM ;
  wire \vga/ps2/_addsub0000<10>/CYMUXG ;
  wire \vga/ps2/_addsub0000<10>/LOGIC_ZERO_118 ;
  wire \vga/ps2/_addsub0000<10>/GROM ;
  wire \vga/ps2/Madd__addsub0000_cy[10] ;
  wire \vga/ps2/_addsub0000<10>/CYINIT_119 ;
  wire \vga/ps2/_addsub0000<12>/LOGIC_ZERO_120 ;
  wire \vga/ps2/_addsub0000<12>/FROM ;
  wire \vga/ps2/timer_r<13>_rt_121 ;
  wire \vga/ps2/Madd__addsub0000_cy[12] ;
  wire \vga/ps2/_addsub0000<12>/CYINIT_122 ;
  wire \vga/crt/Result<1>/CYMUXG ;
  wire \vga/crt/Result<1>/GROM ;
  wire \vga/crt/Mcount_cursor_v_cy[0] ;
  wire \vga/crt/Result<1>/LOGIC_ZERO_123 ;
  wire \vga/crt/Result<2>/FROM ;
  wire \vga/crt/Result<2>/CYMUXG ;
  wire \vga/crt/Result<2>/LOGIC_ZERO_124 ;
  wire \vga/crt/Result<2>/GROM ;
  wire \vga/crt/Mcount_cursor_v_cy[2] ;
  wire \vga/crt/Result<2>/CYINIT_125 ;
  wire \vga/crt/Result<4>/LOGIC_ZERO_126 ;
  wire \vga/crt/Result<4>/FROM ;
  wire \vga/crt/Result<4>/GROM ;
  wire \vga/crt/Mcount_cursor_v_cy[4] ;
  wire \vga/crt/Result<4>/CYINIT_127 ;
  wire \vga/crt/Result<0>1 ;
  wire \vga/crt/Result<1>1/CYMUXG ;
  wire \vga/crt/Result<1>1 ;
  wire \vga/crt/Result<1>1/GROM ;
  wire \vga/crt/Mcount_cursor_h_cy[0] ;
  wire \vga/crt/Result<1>1/LOGIC_ZERO_128 ;
  wire \vga/crt/Result<2>1/FROM ;
  wire \vga/crt/Result<2>1 ;
  wire \vga/crt/Result<2>1/CYMUXG ;
  wire \vga/crt/Result<2>1/LOGIC_ZERO_129 ;
  wire \vga/crt/Result<3>1 ;
  wire \vga/crt/Result<2>1/GROM ;
  wire \vga/crt/Mcount_cursor_h_cy[2] ;
  wire \vga/crt/Result<2>1/CYINIT_130 ;
  wire \vga/crt/Result<4>1/FROM ;
  wire \vga/crt/Result<4>1 ;
  wire \vga/crt/Result<4>1/CYMUXG ;
  wire \vga/crt/Result<4>1/LOGIC_ZERO_131 ;
  wire \vga/crt/Result<5>1 ;
  wire \vga/crt/Result<4>1/GROM ;
  wire \vga/crt/Mcount_cursor_h_cy[4] ;
  wire \vga/crt/Result<4>1/CYINIT_132 ;
  wire \vga/crt/cursor_h<6>_rt_133 ;
  wire \vga/crt/Result<6>/CYINIT_134 ;
  wire \vga/vgacore/hcnt_Eqn_1 ;
  wire \vga/vgacore/hcnt<1>/CYMUXG ;
  wire \vga/vgacore/hcnt<1>/LOGIC_ZERO_135 ;
  wire \vga/vgacore/hcnt_Eqn_2 ;
  wire \vga/vgacore/Mcount_hcnt_cy[1] ;
  wire \vga/vgacore/hcnt<1>/CYINIT_136 ;
  wire \vga/vgacore/hcnt<1>/SRMUX_OUTPUTNOT ;
  wire \vga/vgacore/hcnt<1>/FFX/RST ;
  wire \vga/vgacore/hcnt_Eqn_3 ;
  wire \vga/vgacore/hcnt<3>/CYMUXG ;
  wire \vga/vgacore/hcnt<3>/LOGIC_ZERO_137 ;
  wire \vga/vgacore/hcnt_Eqn_4 ;
  wire \vga/vgacore/Mcount_hcnt_cy[3] ;
  wire \vga/vgacore/hcnt<3>/CYINIT_138 ;
  wire \vga/vgacore/hcnt<3>/SRMUX_OUTPUTNOT ;
  wire \vga/vgacore/hcnt_Eqn_5 ;
  wire \vga/vgacore/hcnt<5>/CYMUXG ;
  wire \vga/vgacore/hcnt<5>/LOGIC_ZERO_139 ;
  wire \vga/vgacore/hcnt_Eqn_6 ;
  wire \vga/vgacore/Mcount_hcnt_cy[5] ;
  wire \vga/vgacore/hcnt<5>/CYINIT_140 ;
  wire \vga/vgacore/hcnt<5>/SRMUX_OUTPUTNOT ;
  wire \vga/vgacore/hcnt_Eqn_7 ;
  wire \vga/vgacore/hcnt<7>/CYMUXG ;
  wire \vga/vgacore/hcnt<7>/LOGIC_ZERO_141 ;
  wire \vga/vgacore/hcnt_Eqn_8 ;
  wire \vga/vgacore/Mcount_hcnt_cy[7] ;
  wire \vga/vgacore/hcnt<7>/CYINIT_142 ;
  wire \vga/vgacore/hcnt<7>/SRMUX_OUTPUTNOT ;
  wire \vga/vgacore/hcnt<9>/LOGIC_ZERO_143 ;
  wire \vga/vgacore/hcnt_Eqn_9 ;
  wire \vga/vgacore/hcnt_Eqn_10 ;
  wire \vga/vgacore/Mcount_hcnt_cy[9] ;
  wire \vga/vgacore/hcnt<9>/CYINIT_144 ;
  wire \vga/vgacore/hcnt<9>/SRMUX_OUTPUTNOT ;
  wire \vga/vgacore/hcnt<9>/FFX/RST ;
  wire \vga/vgacore/vcnt_Eqn_0_mand1 ;
  wire \vga/vgacore/Result<0>1 ;
  wire \vga/vgacore/vcnt<0>/CYMUXG ;
  wire \vga/vgacore/vcnt<0>/LOGIC_ONE_145 ;
  wire \vga/vgacore/Mcount_vcnt_cy<0>_rt_146 ;
  wire \vga/vgacore/vcnt<0>/LOGIC_ZERO_147 ;
  wire \vga/vgacore/vcnt<0>/SRMUX_OUTPUTNOT ;
  wire N3216;
  wire \vga/vgacore/vcnt<0>/CKMUXNOT ;
  wire \vga/vgacore/vcnt<0>/FFX/RST ;
  wire \vga/vgacore/vcnt_Eqn_1_148 ;
  wire \vga/vgacore/Result<1>1 ;
  wire \vga/vgacore/vcnt<1>/CYMUXG ;
  wire \vga/vgacore/vcnt<1>/LOGIC_ZERO_149 ;
  wire \vga/vgacore/vcnt_Eqn_2 ;
  wire \vga/vgacore/Mcount_vcnt_cy[1] ;
  wire \vga/vgacore/vcnt<1>/CYINIT_150 ;
  wire \vga/vgacore/vcnt<1>/SRMUX_OUTPUTNOT ;
  wire \vga/vgacore/Result<2>1 ;
  wire \vga/vgacore/vcnt<1>/CKMUXNOT ;
  wire \vga/vgacore/vcnt_Eqn_3_151 ;
  wire \vga/vgacore/Result<3>1 ;
  wire \vga/vgacore/vcnt<3>/CYMUXG ;
  wire \vga/vgacore/vcnt<3>/LOGIC_ZERO_152 ;
  wire \vga/vgacore/vcnt_Eqn_4 ;
  wire \vga/vgacore/Mcount_vcnt_cy[3] ;
  wire \vga/vgacore/vcnt<3>/CYINIT_153 ;
  wire \vga/vgacore/vcnt<3>/SRMUX_OUTPUTNOT ;
  wire \vga/vgacore/Result<4>1 ;
  wire \vga/vgacore/vcnt<3>/CKMUXNOT ;
  wire \vga/vgacore/vcnt_Eqn_5 ;
  wire \vga/vgacore/Result<5>1 ;
  wire \vga/vgacore/vcnt<5>/CYMUXG ;
  wire \vga/vgacore/vcnt<5>/LOGIC_ZERO_154 ;
  wire \vga/vgacore/vcnt_Eqn_6 ;
  wire \vga/vgacore/Mcount_vcnt_cy[5] ;
  wire \vga/vgacore/vcnt<5>/CYINIT_155 ;
  wire \vga/vgacore/vcnt<5>/SRMUX_OUTPUTNOT ;
  wire \vga/vgacore/Result<6>1 ;
  wire \vga/vgacore/vcnt<5>/CKMUXNOT ;
  wire \vga/vgacore/vcnt_Eqn_7 ;
  wire \vga/vgacore/Result<7>1 ;
  wire \vga/vgacore/vcnt<7>/CYMUXG ;
  wire \vga/vgacore/vcnt<7>/LOGIC_ZERO_156 ;
  wire \vga/vgacore/vcnt_Eqn_8 ;
  wire \vga/vgacore/Mcount_vcnt_cy[7] ;
  wire \vga/vgacore/vcnt<7>/CYINIT_157 ;
  wire \vga/vgacore/vcnt<7>/SRMUX_OUTPUTNOT ;
  wire \vga/vgacore/Result<8>1 ;
  wire \vga/vgacore/vcnt<7>/CKMUXNOT ;
  wire \vga/vgacore/vcnt_Eqn_9 ;
  wire \vga/vgacore/Result<9>1 ;
  wire \vga/vgacore/vcnt<9>/CKMUXNOT ;
  wire \vga/vgacore/vcnt<9>/CYINIT_158 ;
  wire \vga/scancode_convert/scancode_rom/data<0>1437/O_pack_1 ;
  wire \vga/scancode_convert/scancode_rom/data<0>1_map1529 ;
  wire \vga/scancode_convert/scancode_rom/N9_pack_1 ;
  wire \vga/scancode_convert/scancode_rom/data<0>1_map1526 ;
  wire \vga/scancode_convert/scancode_rom/data<0>1539/O_pack_1 ;
  wire \vga/scancode_convert/scancode_rom/data<6>1_map1831_pack_1 ;
  wire N3085;
  wire \vga/scancode_convert/_cmp_eq00041_SW0/O_pack_1 ;
  wire \vga/scancode_convert/N10 ;
  wire \vga/scancode_convert/scancode_rom/data<1>2465/O_pack_1 ;
  wire \vga/scancode_convert/scancode_rom/data<2>1264/O_pack_1 ;
  wire \vga/scancode_convert/scancode_rom/data<2>1_map1124 ;
  wire \vga/scancode_convert/scancode_rom/data<2>1410/O_pack_1 ;
  wire \vga/scancode_convert/scancode_rom/data<3>199/O_pack_1 ;
  wire \vga/scancode_convert/scancode_rom/data<3>1_map1185 ;
  wire \vga/scancode_convert/scancode_rom/data<4>1308_SW1/O_pack_1 ;
  wire \vga/scancode_convert/scancode_rom/data<4>1_map1609 ;
  wire \vga/scancode_convert/N31_pack_1 ;
  wire \vga/scancode_convert/N11 ;
  wire \vga/scancode_convert/scancode_rom/data<4>1392_SW0/O_pack_1 ;
  wire \vga/scancode_convert/scancode_rom/data<4>1_map1669 ;
  wire \vga/scancode_convert/scancode_rom/data<6>1247/O_pack_1 ;
  wire \vga/scancode_convert/scancode_rom/data<5>3247/O_pack_1 ;
  wire \vga/scancode_convert/scancode_rom/data<5>3_map1295 ;
  wire \vga/scancode_convert/scancode_rom/N12_pack_1 ;
  wire \vga/scancode_convert/scancode_rom/data<6>1_map1820 ;
  wire \vga/scancode_convert/scancode_rom/data<5>3359/O_pack_1 ;
  wire \vga/scancode_convert/scancode_rom/data<5>3_map1340 ;
  wire \vga/scancode_convert/scancode_rom/data<6>1333/O_pack_1 ;
  wire \vga/scancode_convert/scancode_rom/data<6>1_map1863 ;
  wire \vga/scancode_convert/scancode_rom/data<5>3852_SW0/O_pack_1 ;
  wire \vga/scancode_convert/scancode_rom/data<5>3_map1416 ;
  wire \vga/scancode_convert/scancode_rom/data<5>3664/O_pack_1 ;
  wire \vga/scancode_convert/scancode_rom/data<5>3_map1381 ;
  wire \vga/scancode_convert/scancode_rom/data<5>3895_SW0/O_pack_1 ;
  wire \vga/vgacore/N0_pack_1 ;
  wire \vga/vgacore/vcnt_Eqn_bis_0 ;
  wire \vga/scancode_convert/state_FFd2-In_SW0/O_pack_1 ;
  wire \vga/scancode_convert/state_FFd2-In_159 ;
  wire \vga/scancode_convert/state_FFd2/FFY/RST ;
  wire \vga/scancode_convert/state_FFd3-In_SW0/O_pack_1 ;
  wire \vga/scancode_convert/state_FFd3-In_160 ;
  wire \vga/scancode_convert/state_FFd3/FFY/RST ;
  wire \vga/crt/_and0000_SW0/O_pack_1 ;
  wire \vga/crt/_and0000_161 ;
  wire \vga/crt/eol_SW0/O_pack_1 ;
  wire \vga/crt/eol_162 ;
  wire \vga/scancode_convert/_cmp_eq0000_pack_1 ;
  wire \vga/scancode_convert/_not0010 ;
  wire \vga/crt/scroll_SW0/O_pack_1 ;
  wire \vga/crt/scroll_163 ;
  wire \vga/scancode_convert/state_FFd4-In24/O_pack_1 ;
  wire \vga/scancode_convert/state_FFd4-In ;
  wire \vga/scancode_convert/state_FFd4/FFY/RST ;
  wire \vga/crt/_and0001_pack_1 ;
  wire \vga/crt/cursor_v_Eqn_1 ;
  wire \vga/crt/cursor_v<1>/FFY/RST ;
  wire \vga/scancode_convert/scancode_rom/data<1>218/O_pack_1 ;
  wire \vga/scancode_convert/scancode_rom/data<1>2_map1690 ;
  wire \vga/scancode_convert/shift_set_map833_pack_1 ;
  wire \vga/scancode_convert/_not0007_164 ;
  wire \vga/scancode_convert/scancode_rom/data<3>126_SW1/O_pack_1 ;
  wire \vga/scancode_convert/scancode_rom/data<3>1_map1158 ;
  wire \vga/scancode_convert/scancode_rom/data<4>145/O_pack_1 ;
  wire \vga/scancode_convert/scancode_rom/data<4>1_map1560 ;
  wire \vga/scancode_convert/raise1_pack_1 ;
  wire \vga/scancode_convert/scancode_rom/data<5>3_map1260 ;
  wire \vga/scancode_convert/scancode_rom/N25_pack_1 ;
  wire \vga/scancode_convert/scancode_rom/data<6>1_map1803 ;
  wire \vga/_and000093/O_pack_1 ;
  wire \vga/cursor_match ;
  wire \vga/scancode_convert/scancode_rom/data<0>176/O_pack_1 ;
  wire \vga/scancode_convert/scancode_rom/data<0>1_map1445 ;
  wire \vga/scancode_convert/scancode_rom/data<0>1370_SW1/O_pack_1 ;
  wire \vga/scancode_convert/scancode_rom/data<0>1_map1503 ;
  wire \vga/scancode_convert/scancode_rom/N7_pack_1 ;
  wire \vga/scancode_convert/scancode_rom/data<0>1_map1534 ;
  wire \vga/crt/Madd_ram_addrR2 ;
  wire \vga/crt/cursor_v_Eqn_0 ;
  wire \vga/crt/cursor_v<0>/FFY/RST ;
  wire \vga/crt/cursor_v_Eqn_3 ;
  wire \vga/crt/cursor_v<3>/SRMUX_OUTPUTNOT ;
  wire \vga/crt/cursor_v_Eqn_2 ;
  wire \vga/crt/cursor_v_Eqn_5 ;
  wire \vga/crt/cursor_v<5>/SRMUX_OUTPUTNOT ;
  wire \vga/crt/cursor_v_Eqn_4 ;
  wire \vga/crt/ram_data<1>/SRMUX_OUTPUTNOT ;
  wire \vga/crt/ram_data<3>/SRMUX_OUTPUTNOT ;
  wire \vga/crt/ram_data<5>/SRMUX_OUTPUTNOT ;
  wire \vga/scancode_convert/_not0012 ;
  wire \vga/scancode_convert/state_FFd1-In ;
  wire \vga/scancode_convert/state_FFd1/FFY/RST ;
  wire \vga/scancode_convert/state_FFd6/LOGIC_ZERO_165 ;
  wire \vga/scancode_convert/_and0000 ;
  wire \vga/scancode_convert/state_FFd6/SRMUX_OUTPUTNOT ;
  wire \vga/scancode_convert/state_FFd5-In_166 ;
  wire \vga/scancode_convert/capslock_toggle ;
  wire \vga/scancode_convert/shift_set ;
  wire \vga/scancode_convert/shift/FFY/RST ;
  wire \vga/scancode_convert/shift_set_map836 ;
  wire \vga/scancode_convert/release_prefix_set ;
  wire \vga/scancode_convert/release_prefix/FFY/RST ;
  wire \vga/ps2/timer_r<11>/SRMUX_OUTPUTNOT ;
  wire \vga/ps2/timer_r<13>/SRMUX_OUTPUTNOT ;
  wire \vga/ps2/timer_r<13>/FFX/RST ;
  wire \vga/ps2/ps2_clk_fall_edge ;
  wire \vga/ps2/error_x ;
  wire \vga/ps2/error_r/FFY/RST ;
  wire \vga/scancode_convert/hold_count<1>/SRMUX_OUTPUTNOT ;
  wire \vga/scancode_convert/_not0011 ;
  wire \vga/scancode_convert/hold_count<2>/FFY/RST ;
  wire \vga/ps2/_cmp_eq0001_map1047 ;
  wire \vga/ps2/timer_r<0>/FFY/RST ;
  wire \vga/ps2/timer_r<3>/SRMUX_OUTPUTNOT ;
  wire \vga/ps2/timer_r<5>/SRMUX_OUTPUTNOT ;
  wire \vga/ps2/timer_r<7>/SRMUX_OUTPUTNOT ;
  wire \vga/ps2/timer_r<7>/FFX/RST ;
  wire \vga/ps2/timer_r<9>/SRMUX_OUTPUTNOT ;
  wire \vga/N226 ;
  wire \vga/crt/write_delay<0>/FFY/RST ;
  wire \vga/crt/write_delay<2>/FFY/RST ;
  wire \vga/_cmp_eq0000 ;
  wire \vga/charload/CKMUXNOT ;
  wire \vga/charload/FFY/RST ;
  wire \vga/crt/_not0010_pack_1 ;
  wire \vga/crt/N3 ;
  wire \vga/crt/newline/FFY/RST ;
  wire \vga/pclk<1>/SRMUX_OUTPUTNOT ;
  wire \vga/crt/cursor_h_Eqn_1 ;
  wire \vga/crt/cursor_h<1>/SRMUX_OUTPUTNOT ;
  wire \vga/crt/cursor_h_Eqn_0 ;
  wire \vga/crt/cursor_h_Eqn_3 ;
  wire \vga/crt/cursor_h<3>/SRMUX_OUTPUTNOT ;
  wire \vga/crt/cursor_h_Eqn_2 ;
  wire \vga/crt/cursor_h_Eqn_5 ;
  wire \vga/crt/cursor_h<5>/SRMUX_OUTPUTNOT ;
  wire \vga/crt/cursor_h_Eqn_4 ;
  wire \vga/crt/cursor_h_Eqn_6 ;
  wire \vga/crt/cursor_h<6>/FFY/RST ;
  wire \vga/ps2/ps2_clk_r<2>/SRMUX_OUTPUTNOT ;
  wire \vga/ps2/ps2_clk_r<2>/FFY/SET ;
  wire \vga/ps2/ps2_clk_r<4>/SRMUX_OUTPUTNOT ;
  wire \vga/ps2/ps2_clk_r<4>/FFY/SET ;
  wire \vga/scancode_convert/scancode_rom/data<2>1_map1129 ;
  wire \vga/scancode_convert/scancode_rom/data<1>2_map1708 ;
  wire N3178;
  wire \vga/scancode_convert/scancode_rom/data<1>2_map1717 ;
  wire N3136;
  wire \vga/scancode_convert/scancode_rom/data<1>2_map1729 ;
  wire \vga/scancode_convert/_cmp_eq0005_pack_1 ;
  wire N124;
  wire \vga/crt/_not0007 ;
  wire \vga/crt/_not0006 ;
  wire \vga/scancode_convert/scancode_rom/data<0>1_map1449 ;
  wire \vga/scancode_convert/scancode_rom/data<2>1_map1121 ;
  wire N235;
  wire \vga/crt/_not0008 ;
  wire \vga/N224 ;
  wire \vga/N13 ;
  wire \vga/N14_pack_1 ;
  wire \vga/rom_addr_char<2>11_167 ;
  wire \vga/N222 ;
  wire \vga/N23 ;
  wire \vga/N221 ;
  wire \vga/N15 ;
  wire \vga/N219 ;
  wire \vga/N24 ;
  wire \vga/N218 ;
  wire \vga/N16 ;
  wire \vga/N104 ;
  wire \vga/N33 ;
  wire \vga/N216 ;
  wire \vga/N25 ;
  wire \vga/N215 ;
  wire \vga/N17 ;
  wire \vga/N102 ;
  wire \vga/N34 ;
  wire \vga/N214 ;
  wire \vga/N26 ;
  wire \vga/N101 ;
  wire \vga/N43 ;
  wire \vga/N99 ;
  wire \vga/N35 ;
  wire \vga/N213 ;
  wire \vga/N27 ;
  wire \vga/N98 ;
  wire \vga/N44 ;
  wire \vga/N208 ;
  wire \vga/N28 ;
  wire \vga/N205 ;
  wire \vga/N20 ;
  wire \vga/N96 ;
  wire \vga/N54 ;
  wire \vga/N95 ;
  wire \vga/N45 ;
  wire \vga/N94 ;
  wire \vga/N37 ;
  wire \vga/N31 ;
  wire \vga/N29 ;
  wire \vga/N201 ;
  wire \vga/N21 ;
  wire N3166;
  wire \vga/N55 ;
  wire \vga/N90 ;
  wire \vga/N47 ;
  wire \vga/N89 ;
  wire \vga/N38 ;
  wire N3146;
  wire \vga/N30 ;
  wire \vga/N194 ;
  wire \vga/N22 ;
  wire \vga/N88 ;
  wire \vga/N64 ;
  wire \vga/N87 ;
  wire \vga/N56 ;
  wire \vga/N86 ;
  wire \vga/N48 ;
  wire \vga/N85 ;
  wire \vga/N39 ;
  wire \vga/N83 ;
  wire \vga/N65 ;
  wire \vga/N82 ;
  wire \vga/N57 ;
  wire \vga/N81 ;
  wire \vga/N49 ;
  wire \vga/N80 ;
  wire \vga/N40 ;
  wire \vga/N79 ;
  wire \vga/N32 ;
  wire N3162_pack_1;
  wire \vga/rom_addr_char<2>2 ;
  wire \vga/N78 ;
  wire \vga/N74 ;
  wire \vga/N75 ;
  wire \vga/N66 ;
  wire \vga/N73 ;
  wire \vga/N58 ;
  wire \vga/N72 ;
  wire \vga/N50 ;
  wire \vga/N71 ;
  wire \vga/N41 ;
  wire \vga/N70 ;
  wire \vga/N67 ;
  wire \vga/N69 ;
  wire \vga/N59 ;
  wire \vga/N63 ;
  wire \vga/N68 ;
  wire \vga/N62 ;
  wire \vga/N60 ;
  wire N3164;
  wire \vga/N61 ;
  wire \vga/N11 ;
  wire \vga/N53 ;
  wire N3158_pack_1;
  wire \vga/scancode_convert/ctrl_set_168 ;
  wire \vga/scancode_convert/ctrl/FFY/RST ;
  wire N3142;
  wire \vga/scancode_convert/scancode_rom/data<4>1_map1565 ;
  wire \vga/N193 ;
  wire \vga/N105 ;
  wire \vga/N192 ;
  wire \vga/N106 ;
  wire \vga/N191 ;
  wire \vga/N115 ;
  wire \vga/N190 ;
  wire \vga/N116 ;
  wire \vga/scancode_convert/scancode_rom/data<6>1_map1808 ;
  wire N3141;
  wire \vga/N186 ;
  wire \vga/N125 ;
  wire \vga/N184 ;
  wire \vga/N117 ;
  wire \vga/N183 ;
  wire \vga/N126 ;
  wire \vga/N179 ;
  wire \vga/N118 ;
  wire \vga/N178 ;
  wire \vga/N110 ;
  wire \vga/N176 ;
  wire \vga/N127 ;
  wire \vga/N175 ;
  wire \vga/N111 ;
  wire \vga/N172 ;
  wire \vga/N137 ;
  wire \vga/N171 ;
  wire \vga/N128 ;
  wire \vga/N170 ;
  wire \vga/N120 ;
  wire \vga/N167 ;
  wire \vga/N146 ;
  wire \vga/N159 ;
  wire \vga/N138 ;
  wire \vga/N157 ;
  wire \vga/N129 ;
  wire \vga/N155 ;
  wire \vga/N121 ;
  wire \vga/N152 ;
  wire \vga/N113 ;
  wire N3174;
  wire \vga/scancode_convert/scancode_rom/data<5>3_map1276 ;
  wire \vga/scancode_convert/key_up/FFY/RST ;
  wire \vga/N151 ;
  wire \vga/N147 ;
  wire \vga/N150 ;
  wire \vga/N139 ;
  wire \vga/N149 ;
  wire \vga/N130 ;
  wire \vga/N145 ;
  wire \vga/N114 ;
  wire \vga/N144 ;
  wire \vga/N131 ;
  wire \vga/N143 ;
  wire \vga/N132 ;
  wire \vga/N134 ;
  wire \vga/N142 ;
  wire \vga/N2 ;
  wire \vga/N133 ;
  wire \vga/scancode_convert/scancode_rom/data<0>1_map1475 ;
  wire \vga/scancode_convert/scancode_rom/data<5>3_map1363 ;
  wire N3124;
  wire \vga/scancode_convert/scancode_rom/data<6>1_map1850 ;
  wire \vga/crt/N9 ;
  wire \vga/crt/Madd_ram_addrC2_pack_1 ;
  wire \vga/ram_addr_write<7>/CYMUXG ;
  wire \vga/ram_addr_write<7>/LOGIC_ONE_169 ;
  wire \vga/crt/Madd_ram_addr_Madd_cy<7>_rt_170 ;
  wire \vga/ram_addr_write<7>/CYINIT_171 ;
  wire \vga/scancode_convert/raise_pack_1 ;
  wire \vga/scancode_convert/scancode_rom/data<0>1_map1438 ;
  wire \vga/scancode_convert/scancode_rom/N43 ;
  wire \vga/scancode_convert/scancode_rom/data<5>3_map1394 ;
  wire N562_pack_1;
  wire \vga/scancode_convert/scancode_rom/data<1>2_map1701 ;
  wire N3130;
  wire \vga/crt/_cmp_eq0004_pack_1 ;
  wire \vga/crt/write_delay<1>/FFY/RST ;
  wire \vga/clearing_pack_1 ;
  wire \vga/_mux0000 ;
  wire \gray_cnt_FFd11/SRMUX_OUTPUTNOT ;
  wire \gray_cnt_FFd11/BYMUXNOT ;
  wire \gray_cnt_FFd11/FFY/RST ;
  wire \vga/ram_we_n_pack_1 ;
  wire \vga/scancode_convert/capslock/BYMUXNOT ;
  wire \vga/scancode_convert/capslock/FFY/RST ;
  wire \vga/N230 ;
  wire \vga/Madd_ram_addr_videoC2_pack_1 ;
  wire \vga/ram_addr_video<7>/CYMUXG ;
  wire \vga/ram_addr_video<7>/LOGIC_ONE_172 ;
  wire \vga/Madd_ram_addr_video_Madd_cy<7>_rt_173 ;
  wire \vga/ram_addr_video<7>/CYINIT_174 ;
  wire N839;
  wire \vga/Madd_ram_addr_videoR2 ;
  wire \vga/ps2/ps2_clk_edge_pack_1 ;
  wire \vga/ps2/timer_r<1>/FFY/RST ;
  wire \vga/ps2/error_x_map855 ;
  wire \vga/ps2/_cmp_eq0000 ;
  wire \vga/ps2/_cmp_eq0001_map1032 ;
  wire \vga/vgacore/_and0000_map807_pack_1 ;
  wire \vga/vgacore/_and0000_map811 ;
  wire \vga/vgacore/vcnt_1_1/CKMUXNOT ;
  wire \vga/vgacore/vcnt_1_1/FFY/RST ;
  wire \vga/vgacore/vcnt_2_1/CKMUXNOT ;
  wire \vga/vgacore/vcnt_2_1/FFY/RST ;
  wire \vga/scancode_convert/_not0009 ;
  wire \vga/N0112_pack_1 ;
  wire \vga/charload3_map953 ;
  wire \vga/N011234567_pack_1 ;
  wire \vga/rom_addr_char<4>11234 ;
  wire \vga/charload7_map993 ;
  wire \vga/rom_addr_char<4>11_175 ;
  wire \vga/scancode_convert/strobe_out/FFY/RST ;
  wire \vga/N4_pack_1 ;
  wire \vga/N1112 ;
  wire \vga/N10 ;
  wire \vga/N6 ;
  wire N3170;
  wire \vga/N7 ;
  wire \vga/N8_pack_1 ;
  wire \vga/N11123 ;
  wire N3160;
  wire \vga/N12 ;
  wire \vga/crt/N91_pack_1 ;
  wire \vga/crt/state_FFd3-In_map800_pack_1 ;
  wire \vga/crt/state_FFd3-In ;
  wire \vga/crt/state_FFd3/FFY/RST ;
  wire \vga/insert_crt_data_pack_1 ;
  wire N116;
  wire N117_pack_1;
  wire \vga/crt/state_FFd1-In_176 ;
  wire \vga/crt/state_FFd1/FFY/RST ;
  wire \vga/crt/N16_pack_1 ;
  wire N306;
  wire \vga/rom_addr_char<1>/CKMUXNOT ;
  wire \vga/rom_addr_char<3>/CKMUXNOT ;
  wire \vga/rom_addr_char<5>/CKMUXNOT ;
  wire \vga/rom_addr_char<6>/CKMUXNOT ;
  wire \vga/scancode_convert/scancode_rom/data<0>1_map1461 ;
  wire \vga/scancode_convert/scancode_rom/data<0>1_map1429 ;
  wire \vga/scancode_convert/scancode_rom/N28 ;
  wire \vga/scancode_convert/scancode_rom/N18 ;
  wire \vga/ps2/sc_r<1>/FFX/RST ;
  wire \vga/ps2/sc_r<1>/SRMUX_OUTPUTNOT ;
  wire \vga/ps2/sc_r<1>/FFY/RST ;
  wire \vga/ps2/sc_r<3>/FFX/RST ;
  wire \vga/ps2/sc_r<3>/SRMUX_OUTPUTNOT ;
  wire \vga/ps2/sc_r<3>/FFY/RST ;
  wire \vga/ps2/sc_r<5>/FFX/RST ;
  wire \vga/ps2/sc_r<5>/SRMUX_OUTPUTNOT ;
  wire \vga/ps2/sc_r<5>/FFY/RST ;
  wire \vga/ps2/sc_r<7>/FFX/RST ;
  wire \vga/ps2/sc_r<7>/SRMUX_OUTPUTNOT ;
  wire \vga/ps2/sc_r<7>/FFY/RST ;
  wire \vga/ps2/sc_r<8>/FFY/RST ;
  wire \vga/scancode_convert/scancode_rom/data<5>3_map1245 ;
  wire \vga/scancode_convert/scancode_rom/data<5>3_map1249 ;
  wire N786;
  wire N3108;
  wire \vga/_and0000_map918 ;
  wire \vga/scancode_convert/_or0000 ;
  wire \vga/charload6_map1022_pack_1 ;
  wire \vga/_and0000_map929 ;
  wire \vga/pixelData<0>/SRMUX_OUTPUTNOT ;
  wire \vga/pixelData<0>/LOGIC_ONE_177 ;
  wire \vga/ps2/_cmp_eq0001_map1035 ;
  wire \vga/_and0000_map940 ;
  wire \vga/_and0000_map941_pack_1 ;
  wire \vga/_and0000_map943 ;
  wire \vga/ps2/_cmp_eq0001_map1041 ;
  wire \vga/rom_addr_char_0_1/CKMUXNOT ;
  wire \vga/rom_addr_char_1_1/CKMUXNOT ;
  wire \vga/ps2/_cmp_eq0001_pack_1 ;
  wire \vga/ps2/scancode_rdy ;
  wire \vga/ps2/rdy_r/FFY/RST ;
  wire \vga/crt/_cmp_eq0001 ;
  wire \vga/scancode_convert/scancode_rom/data<0>1_map1423 ;
  wire N3132;
  wire \vga/vgacore/_and0000_map817 ;
  wire \vga/_and0000_map879 ;
  wire \vga/vgacore/_and0000_map824 ;
  wire \vga/vgacore/_and0000_map825_pack_1 ;
  wire \vga/vgacore/_and0000 ;
  wire \vga/vgacore/hsync/FFY/RST ;
  wire \vga/charload5_map965 ;
  wire \vga/charload4_map979 ;
  wire N3172;
  wire N3148;
  wire \vga/_and0000_map890 ;
  wire \vga/charload6_map1010_pack_1 ;
  wire \vga/charload6_map1012 ;
  wire \vga/charload6_map1014_pack_1 ;
  wire \vga/charload6_map1018 ;
  wire \vga/crtclk1/BYMUXNOT ;
  wire \vga/crtclk1/FFY/RST ;
  wire \vga/crt_data<1>/SRMUX_OUTPUTNOT ;
  wire \vga/crt_data<1>/FFY/RST ;
  wire \vga/crt_data<3>/SRMUX_OUTPUTNOT ;
  wire \vga/crt_data<3>/FFY/RST ;
  wire \vga/crt_data<5>/SRMUX_OUTPUTNOT ;
  wire \vga/crt_data<5>/FFY/RST ;
  wire \vga/crt_data<6>/FFY/RST ;
  wire \vga/vgacore/hcnt_Eqn_0_mand1 ;
  wire \vga/vgacore/hcnt_Eqn_bis_0_pack_1 ;
  wire \vga/vgacore/hcnt<0>/CYMUXG ;
  wire \vga/vgacore/hcnt<0>/LOGIC_ONE_178 ;
  wire \vga/vgacore/Mcount_hcnt_cy<0>_rt_179 ;
  wire \vga/vgacore/hcnt<0>/LOGIC_ZERO_180 ;
  wire \vga/vgacore/hcnt<0>/FFX/RST ;
  wire N3100;
  wire N44_pack_1;
  wire \vga/vgacore/_and0001_181 ;
  wire \vga/vgacore/vsync/FFY/RST ;
  wire N89_pack_1;
  wire \vga/pclk<2>/FFY/SET ;
  wire \vga/vgacore/hblank/FFY/RST ;
  wire \vga/vgacore/hcnt<1>/FFY/RST ;
  wire \vga/vgacore/hcnt<3>/FFY/RST ;
  wire \vga/vgacore/hcnt<5>/FFY/RST ;
  wire \vga/vgacore/hcnt<7>/FFY/RST ;
  wire \vga/vgacore/hcnt<9>/FFY/RST ;
  wire \vga/vgacore/vcnt<0>/FFY/RST ;
  wire \vga/vgacore/vcnt<1>/FFY/RST ;
  wire \vga/vgacore/vcnt<3>/FFY/RST ;
  wire \vga/vgacore/vcnt<5>/FFY/RST ;
  wire \vga/vgacore/vcnt<7>/FFY/RST ;
  wire \vga/crt/cursor_v<3>/FFY/RST ;
  wire \vga/crt/cursor_v<5>/FFY/RST ;
  wire \vga/crt/ram_data<1>/FFY/RST ;
  wire \vga/crt/ram_data<3>/FFY/RST ;
  wire \vga/crt/ram_data<5>/FFY/RST ;
  wire \vga/scancode_convert/state_FFd6/FFY/RST ;
  wire \vga/ps2/timer_r<11>/FFY/RST ;
  wire \vga/ps2/timer_r<13>/FFY/RST ;
  wire \vga/scancode_convert/hold_count<1>/FFY/RST ;
  wire \vga/ps2/timer_r<3>/FFY/RST ;
  wire \vga/ps2/timer_r<5>/FFY/RST ;
  wire \vga/ps2/timer_r<7>/FFY/RST ;
  wire \vga/ps2/timer_r<9>/FFY/RST ;
  wire \vga/pclk<1>/FFY/SET ;
  wire \vga/crt/cursor_h<1>/FFY/RST ;
  wire \vga/crt/cursor_h<3>/FFY/RST ;
  wire \vga/crt/cursor_h<5>/FFY/RST ;
  wire \vga/ram_wclk/FFY/RST ;
  wire \vga/crt/ram_data<6>/FFY/RST ;
  wire \ps2_clk/IFF/SET ;
  wire \ps2_data/IFF/RST ;
  wire \vga/crt/state_FFd2/FFX/RST ;
  wire \vga/vgacore/hcnt<3>/FFX/RST ;
  wire \vga/vgacore/hcnt<5>/FFX/RST ;
  wire \vga/vgacore/hcnt<7>/FFX/RST ;
  wire \vga/vgacore/vcnt<1>/FFX/RST ;
  wire \vga/vgacore/vcnt<3>/FFX/RST ;
  wire \vga/vgacore/vcnt<5>/FFX/RST ;
  wire \vga/vgacore/vcnt<7>/FFX/RST ;
  wire \vga/vgacore/vcnt<9>/FFX/RST ;
  wire \vga/crt/cursor_v<3>/FFX/RST ;
  wire \vga/crt/cursor_v<5>/FFX/RST ;
  wire \vga/crt/ram_data<1>/FFX/RST ;
  wire \vga/crt/ram_data<3>/FFX/RST ;
  wire \vga/crt/ram_data<5>/FFX/RST ;
  wire \vga/scancode_convert/state_FFd6/FFX/SET ;
  wire \vga/ps2/timer_r<11>/FFX/RST ;
  wire \vga/scancode_convert/hold_count<1>/FFX/RST ;
  wire \vga/ps2/timer_r<3>/FFX/RST ;
  wire \vga/ps2/timer_r<5>/FFX/RST ;
  wire \vga/ps2/timer_r<9>/FFX/RST ;
  wire \vga/pclk<1>/FFX/SET ;
  wire \vga/crt/cursor_h<1>/FFX/RST ;
  wire \vga/crt/cursor_h<3>/FFX/RST ;
  wire \vga/crt/cursor_h<5>/FFX/RST ;
  wire \vga/ps2/ps2_clk_r<2>/FFX/SET ;
  wire \vga/ps2/ps2_clk_r<4>/FFX/SET ;
  wire \gray_cnt_FFd11/FFX/RST ;
  wire \vga/crt_data<1>/FFX/RST ;
  wire \vga/crt_data<3>/FFX/RST ;
  wire \vga/crt_data<5>/FFX/RST ;
  wire GND;
  wire VCC;
  wire \NLW_vga/vgacore/Mcount_vcnt_cy<0>_rt_IA_UNCONNECTED ;
  wire \NLW_vga/crt/Madd_ram_addr_Madd_cy<7>_rt_IA_UNCONNECTED ;
  wire \NLW_vga/Madd_ram_addr_video_Madd_cy<7>_rt_IA_UNCONNECTED ;
  wire \NLW_vga/vgacore/Mcount_hcnt_cy<0>_rt_IA_UNCONNECTED ;
  wire [4 : 0] \vga/ps2/ps2_clk_r ;
  wire [6 : 0] \vga/scancode_convert/ascii ;
  wire [9 : 0] \vga/ps2/sc_r ;
  wire [2 : 0] \vga/pclk ;
  wire [11 : 0] \vga/video_ram/ram_addr_w ;
  wire [6 : 0] \vga/crt/ram_data ;
  wire [6 : 0] \vga/ram_data_out ;
  wire [6 : 0] \vga/scancode_convert/sc ;
  wire [6 : 0] \vga/rom_addr_char ;
  wire [9 : 0] \vga/vgacore/vcnt ;
  wire [3 : 0] \vga/ps2/bitcnt_r ;
  wire [7 : 0] \vga/pixel_hold ;
  wire [6 : 0] \vga/crt/cursor_h ;
  wire [5 : 0] \vga/crt/cursor_v ;
  wire [10 : 0] \vga/vgacore/hcnt ;
  wire [13 : 0] \vga/ps2/timer_r ;
  wire [6 : 0] \vga/crt_data ;
  wire [2 : 0] \vga/scancode_convert/hold_count ;
  wire [2 : 0] \vga/crt/write_delay ;
  wire [0 : 0] \vga/pixelData ;
  wire [5 : 0] \vga/scancode_convert/rom_data ;
  wire [3 : 0] \vga/ps2/bitcnt_x ;
  wire [7 : 0] \vga/_mux0002 ;
  wire [11 : 0] \vga/ram_addr_mux ;
  wire [11 : 5] \vga/ram_addr_write ;
  wire [11 : 5] \vga/ram_addr_video ;
  wire [13 : 1] \vga/ps2/_addsub0000 ;
  wire [6 : 0] \vga/crt/Result ;
  wire [10 : 0] \vga/vgacore/Result ;
  wire [6 : 6] \vga/scancode_convert/_mux0008 ;
  wire [6 : 0] \vga/crt/_mux0002 ;
  wire [13 : 0] \vga/ps2/timer_x ;
  wire [2 : 0] \vga/scancode_convert/hold_count__mux0000 ;
  wire [2 : 0] \vga/crt/write_delay__mux0000 ;
  wire [2 : 0] \vga/pclk__mux0000 ;
  wire [8 : 8] pixel;
  initial $sdf_annotate("netgen/par/fpga_timesim.sdf");
  defparam \ps2_clk/PAD .LOC = "PAD309";
  X_IPAD \ps2_clk/PAD  (
    .PAD(ps2_clk)
  );
  defparam ps2_clk_IBUF.LOC = "PAD309";
  X_BUF ps2_clk_IBUF (
    .I(ps2_clk),
    .O(ps2_clk_IBUF_37)
  );
  defparam \ps2_clk/DELAY .LOC = "PAD309";
  X_BUF \ps2_clk/DELAY  (
    .I(ps2_clk_IBUF_37),
    .O(\ps2_clk/IDELAY )
  );
  defparam \fpga_d1/PAD .LOC = "PAD106";
  X_OPAD \fpga_d1/PAD  (
    .PAD(fpga_d1)
  );
  defparam fpga_d1_OBUF.LOC = "PAD106";
  X_OBUF fpga_d1_OBUF (
    .I(\fpga_d1/OUTMUX_38 ),
    .O(fpga_d1)
  );
  defparam \fpga_d1/OUTMUX .LOC = "PAD106";
  X_BUF \fpga_d1/OUTMUX  (
    .I(\vga/ps2/rdy_r_1 ),
    .O(\fpga_d1/OUTMUX_38 )
  );
  defparam \fpga_d2/PAD .LOC = "PAD107";
  X_OPAD \fpga_d2/PAD  (
    .PAD(fpga_d2)
  );
  defparam fpga_d2_OBUF.LOC = "PAD107";
  X_OBUF fpga_d2_OBUF (
    .I(\fpga_d2/OUTMUX_39 ),
    .O(fpga_d2)
  );
  defparam \fpga_d2/OUTMUX .LOC = "PAD107";
  X_BUF \fpga_d2/OUTMUX  (
    .I(\vga/scancode_convert/ascii [5]),
    .O(\fpga_d2/OUTMUX_39 )
  );
  defparam \fpga_d3/PAD .LOC = "PAD118";
  X_OPAD \fpga_d3/PAD  (
    .PAD(fpga_d3)
  );
  defparam fpga_d3_OBUF.LOC = "PAD118";
  X_OBUF fpga_d3_OBUF (
    .I(\fpga_d3/OUTMUX_40 ),
    .O(fpga_d3)
  );
  defparam \fpga_d3/OUTMUX .LOC = "PAD118";
  X_BUF \fpga_d3/OUTMUX  (
    .I(\vga/scancode_convert/ascii [4]),
    .O(\fpga_d3/OUTMUX_40 )
  );
  defparam \fpga_d4/PAD .LOC = "PAD135";
  X_OPAD \fpga_d4/PAD  (
    .PAD(fpga_d4)
  );
  defparam fpga_d4_OBUF.LOC = "PAD135";
  X_OBUF fpga_d4_OBUF (
    .I(\fpga_d4/OUTMUX_41 ),
    .O(fpga_d4)
  );
  defparam \fpga_d4/OUTMUX .LOC = "PAD135";
  X_BUF \fpga_d4/OUTMUX  (
    .I(\vga/scancode_convert/ascii [3]),
    .O(\fpga_d4/OUTMUX_41 )
  );
  defparam \fpga_d5/PAD .LOC = "PAD146";
  X_OPAD \fpga_d5/PAD  (
    .PAD(fpga_d5)
  );
  defparam fpga_d5_OBUF.LOC = "PAD146";
  X_OBUF fpga_d5_OBUF (
    .I(\fpga_d5/OUTMUX_42 ),
    .O(fpga_d5)
  );
  defparam \fpga_d5/OUTMUX .LOC = "PAD146";
  X_BUF \fpga_d5/OUTMUX  (
    .I(\vga/scancode_convert/ascii [2]),
    .O(\fpga_d5/OUTMUX_42 )
  );
  defparam \fpga_d6/PAD .LOC = "PAD147";
  X_OPAD \fpga_d6/PAD  (
    .PAD(fpga_d6)
  );
  defparam fpga_d6_OBUF.LOC = "PAD147";
  X_OBUF fpga_d6_OBUF (
    .I(\fpga_d6/OUTMUX_43 ),
    .O(fpga_d6)
  );
  defparam \fpga_d6/OUTMUX .LOC = "PAD147";
  X_BUF \fpga_d6/OUTMUX  (
    .I(\vga/scancode_convert/ascii [1]),
    .O(\fpga_d6/OUTMUX_43 )
  );
  defparam \fpga_d7/PAD .LOC = "PAD167";
  X_OPAD \fpga_d7/PAD  (
    .PAD(fpga_d7)
  );
  defparam fpga_d7_OBUF.LOC = "PAD167";
  X_OBUF fpga_d7_OBUF (
    .I(\fpga_d7/OUTMUX_44 ),
    .O(fpga_d7)
  );
  defparam \fpga_d7/OUTMUX .LOC = "PAD167";
  X_BUF \fpga_d7/OUTMUX  (
    .I(\vga/scancode_convert/ascii [0]),
    .O(\fpga_d7/OUTMUX_44 )
  );
  defparam \ps2_data/PAD .LOC = "PAD315";
  X_IPAD \ps2_data/PAD  (
    .PAD(ps2_data)
  );
  defparam ps2_data_IBUF.LOC = "PAD315";
  X_BUF ps2_data_IBUF (
    .I(ps2_data),
    .O(ps2_data_IBUF_45)
  );
  defparam \ps2_data/DELAY .LOC = "PAD315";
  X_BUF \ps2_data/DELAY  (
    .I(ps2_data_IBUF_45),
    .O(\ps2_data/IDELAY )
  );
  defparam \fpga_din_d0/PAD .LOC = "PAD86";
  X_OPAD \fpga_din_d0/PAD  (
    .PAD(fpga_din_d0)
  );
  defparam fpga_din_d0_OBUF.LOC = "PAD86";
  X_OBUF fpga_din_d0_OBUF (
    .I(\fpga_din_d0/OUTMUX_46 ),
    .O(fpga_din_d0)
  );
  defparam \fpga_din_d0/OUTMUX .LOC = "PAD86";
  X_BUF \fpga_din_d0/OUTMUX  (
    .I(\vga/scancode_convert/ascii [6]),
    .O(\fpga_din_d0/OUTMUX_46 )
  );
  defparam \vga_blue0/PAD .LOC = "PAD296";
  X_OPAD \vga_blue0/PAD  (
    .PAD(vga_blue0)
  );
  defparam vga_blue0_OBUF.LOC = "PAD296";
  X_OBUF vga_blue0_OBUF (
    .I(\vga_blue0/OUTMUX_47 ),
    .O(vga_blue0)
  );
  defparam \vga_blue0/OUTMUX .LOC = "PAD296";
  X_BUF \vga_blue0/OUTMUX  (
    .I(\pixel<8>_0 ),
    .O(\vga_blue0/OUTMUX_47 )
  );
  defparam \vga_blue1/PAD .LOC = "PAD279";
  X_OPAD \vga_blue1/PAD  (
    .PAD(vga_blue1)
  );
  defparam vga_blue1_OBUF.LOC = "PAD279";
  X_OBUF vga_blue1_OBUF (
    .I(\vga_blue1/OUTMUX_48 ),
    .O(vga_blue1)
  );
  defparam \vga_blue1/OUTMUX .LOC = "PAD279";
  X_BUF \vga_blue1/OUTMUX  (
    .I(\pixel<8>_0 ),
    .O(\vga_blue1/OUTMUX_48 )
  );
  defparam \vga_vsync_n/PAD .LOC = "PAD280";
  X_OPAD \vga_vsync_n/PAD  (
    .PAD(vga_vsync_n)
  );
  defparam vga_vsync_n_OBUF.LOC = "PAD280";
  X_OBUF vga_vsync_n_OBUF (
    .I(\vga_vsync_n/OUTMUX_49 ),
    .O(vga_vsync_n)
  );
  defparam \vga_vsync_n/OUTMUX .LOC = "PAD280";
  X_INV \vga_vsync_n/OUTMUX  (
    .I(\vga/vgacore/vsync_2 ),
    .O(\vga_vsync_n/OUTMUX_49 )
  );
  defparam \vga_blue2/PAD .LOC = "PAD263";
  X_OPAD \vga_blue2/PAD  (
    .PAD(vga_blue2)
  );
  defparam vga_blue2_OBUF.LOC = "PAD263";
  X_OBUF vga_blue2_OBUF (
    .I(\vga_blue2/OUTMUX_50 ),
    .O(vga_blue2)
  );
  defparam \vga_blue2/OUTMUX .LOC = "PAD263";
  X_BUF \vga_blue2/OUTMUX  (
    .I(\pixel<8>_0 ),
    .O(\vga_blue2/OUTMUX_50 )
  );
  defparam \vga_hsync_n/PAD .LOC = "PAD274";
  X_OPAD \vga_hsync_n/PAD  (
    .PAD(vga_hsync_n)
  );
  defparam vga_hsync_n_OBUF.LOC = "PAD274";
  X_OBUF vga_hsync_n_OBUF (
    .I(\vga_hsync_n/OUTMUX_51 ),
    .O(vga_hsync_n)
  );
  defparam \vga_hsync_n/OUTMUX .LOC = "PAD274";
  X_INV \vga_hsync_n/OUTMUX  (
    .I(\vga/vgacore/hsync_3 ),
    .O(\vga_hsync_n/OUTMUX_51 )
  );
  defparam \vga_red0/PAD .LOC = "PAD286";
  X_OPAD \vga_red0/PAD  (
    .PAD(vga_red0)
  );
  defparam vga_red0_OBUF.LOC = "PAD286";
  X_OBUF vga_red0_OBUF (
    .I(\vga_red0/OUTMUX_52 ),
    .O(vga_red0)
  );
  defparam \vga_red0/OUTMUX .LOC = "PAD286";
  X_BUF \vga_red0/OUTMUX  (
    .I(\pixel<8>_0 ),
    .O(\vga_red0/OUTMUX_52 )
  );
  defparam \vga_red1/PAD .LOC = "PAD273";
  X_OPAD \vga_red1/PAD  (
    .PAD(vga_red1)
  );
  defparam vga_red1_OBUF.LOC = "PAD273";
  X_OBUF vga_red1_OBUF (
    .I(\vga_red1/OUTMUX_53 ),
    .O(vga_red1)
  );
  defparam \vga_red1/OUTMUX .LOC = "PAD273";
  X_BUF \vga_red1/OUTMUX  (
    .I(\pixel<8>_0 ),
    .O(\vga_red1/OUTMUX_53 )
  );
  defparam \vga_red2/PAD .LOC = "PAD246";
  X_OPAD \vga_red2/PAD  (
    .PAD(vga_red2)
  );
  defparam vga_red2_OBUF.LOC = "PAD246";
  X_OBUF vga_red2_OBUF (
    .I(\vga_red2/OUTMUX_54 ),
    .O(vga_red2)
  );
  defparam \vga_red2/OUTMUX .LOC = "PAD246";
  X_BUF \vga_red2/OUTMUX  (
    .I(\pixel<8>_0 ),
    .O(\vga_red2/OUTMUX_54 )
  );
  defparam \reset_n/PAD .LOC = "PAD326";
  X_IPAD \reset_n/PAD  (
    .PAD(reset_n)
  );
  defparam \reset_n/IMUX .LOC = "PAD326";
  X_BUF \reset_n/IMUX  (
    .I(reset_n_IBUF_55),
    .O(reset_n_IBUF_0)
  );
  defparam reset_n_IBUF.LOC = "PAD326";
  X_BUF reset_n_IBUF (
    .I(reset_n),
    .O(reset_n_IBUF_55)
  );
  defparam \vga_green0/PAD .LOC = "PAD300";
  X_OPAD \vga_green0/PAD  (
    .PAD(vga_green0)
  );
  defparam vga_green0_OBUF.LOC = "PAD300";
  X_OBUF vga_green0_OBUF (
    .I(\vga_green0/OUTMUX_56 ),
    .O(vga_green0)
  );
  defparam \vga_green0/OUTMUX .LOC = "PAD300";
  X_BUF \vga_green0/OUTMUX  (
    .I(\pixel<8>_0 ),
    .O(\vga_green0/OUTMUX_56 )
  );
  defparam \vga_green1/PAD .LOC = "PAD284";
  X_OPAD \vga_green1/PAD  (
    .PAD(vga_green1)
  );
  defparam vga_green1_OBUF.LOC = "PAD284";
  X_OBUF vga_green1_OBUF (
    .I(\vga_green1/OUTMUX_57 ),
    .O(vga_green1)
  );
  defparam \vga_green1/OUTMUX .LOC = "PAD284";
  X_BUF \vga_green1/OUTMUX  (
    .I(\pixel<8>_0 ),
    .O(\vga_green1/OUTMUX_57 )
  );
  defparam \vga_green2/PAD .LOC = "PAD254";
  X_OPAD \vga_green2/PAD  (
    .PAD(vga_green2)
  );
  defparam vga_green2_OBUF.LOC = "PAD254";
  X_OBUF vga_green2_OBUF (
    .I(\vga_green2/OUTMUX_58 ),
    .O(vga_green2)
  );
  defparam \vga_green2/OUTMUX .LOC = "PAD254";
  X_BUF \vga_green2/OUTMUX  (
    .I(\pixel<8>_0 ),
    .O(\vga_green2/OUTMUX_58 )
  );
  defparam \vga/inst_Mram_mem11/LOGIC_ONE .LOC = "RAMB4_R4C0";
  X_ONE \vga/inst_Mram_mem11/LOGIC_ONE  (
    .O(\vga/inst_Mram_mem11/LOGIC_ONE_60 )
  );
  defparam \vga/inst_Mram_mem11/LOGIC_ZERO .LOC = "RAMB4_R4C0";
  X_ZERO \vga/inst_Mram_mem11/LOGIC_ZERO  (
    .O(\vga/inst_Mram_mem11/LOGIC_ZERO_59 )
  );
  defparam \vga/inst_Mram_mem11/CLKBMUX .LOC = "RAMB4_R4C0";
  X_INV \vga/inst_Mram_mem11/CLKBMUX  (
    .I(\vga/pclk [2]),
    .O(\vga/inst_Mram_mem11/CLKB_INTNOT )
  );
  defparam \vga/inst_Mram_mem11 .INIT_00 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem11 .INIT_01 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem11 .INIT_02 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem11 .INIT_03 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem11 .INIT_04 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem11 .INIT_05 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem11 .INIT_06 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem11 .INIT_07 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem11 .INIT_08 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem11 .INIT_09 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem11 .INIT_0A = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem11 .INIT_0B = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem11 .INIT_0C = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem11 .INIT_0D = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem11 .INIT_0E = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem11 .INIT_0F = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem11 .LOC = "RAMB4_R4C0";
  defparam \vga/inst_Mram_mem11 .SETUP_ALL = 3737;
  X_RAMB4_S1_S1 \vga/inst_Mram_mem11  (
    .CLKA(\vga/ram_wclk_5 ),
    .CLKB(\vga/inst_Mram_mem11/CLKB_INTNOT ),
    .ENA(\vga/inst_Mram_mem11/LOGIC_ONE_60 ),
    .ENB(\vga/inst_Mram_mem11/LOGIC_ONE_60 ),
    .RSTA(\vga/inst_Mram_mem11/LOGIC_ZERO_59 ),
    .RSTB(\vga/inst_Mram_mem11/LOGIC_ZERO_59 ),
    .WEA(\vga/N226_0 ),
    .WEB(\vga/inst_Mram_mem11/LOGIC_ZERO_59 ),
    .ADDRA({\vga/video_ram/ram_addr_w [11], \vga/video_ram/ram_addr_w [10], \vga/video_ram/ram_addr_w [9], \vga/video_ram/ram_addr_w [8], 
\vga/video_ram/ram_addr_w [7], \vga/video_ram/ram_addr_w [6], \vga/video_ram/ram_addr_w [5], \vga/video_ram/ram_addr_w [4], 
\vga/video_ram/ram_addr_w [3], \vga/video_ram/ram_addr_w [2], \vga/video_ram/ram_addr_w [1], \vga/video_ram/ram_addr_w [0]}),
    .ADDRB({\vga/ram_addr_mux<11>_0 , \vga/ram_addr_mux<10>_0 , \vga/ram_addr_mux<9>_0 , \vga/ram_addr_mux<8>_0 , \vga/ram_addr_mux<7>_0 , 
\vga/ram_addr_mux<6>_0 , \vga/ram_addr_mux<5>_0 , \vga/ram_addr_mux<4>_0 , \vga/ram_addr_mux<3>_0 , \vga/ram_addr_mux<2>_0 , \vga/ram_addr_mux<1>_0 , 
\vga/ram_addr_mux<0>_0 }),
    .DIA({\vga/crt/ram_data [1]}),
    .DIB({\vga/inst_Mram_mem11/DIB0 }),
    .DOA({\vga/inst_Mram_mem11/DOA0 }),
    .DOB({\vga/ram_data_out [1]})
  );
  defparam \vga/inst_Mram_mem21/LOGIC_ONE .LOC = "RAMB4_R5C0";
  X_ONE \vga/inst_Mram_mem21/LOGIC_ONE  (
    .O(\vga/inst_Mram_mem21/LOGIC_ONE_62 )
  );
  defparam \vga/inst_Mram_mem21/LOGIC_ZERO .LOC = "RAMB4_R5C0";
  X_ZERO \vga/inst_Mram_mem21/LOGIC_ZERO  (
    .O(\vga/inst_Mram_mem21/LOGIC_ZERO_61 )
  );
  defparam \vga/inst_Mram_mem21/CLKBMUX .LOC = "RAMB4_R5C0";
  X_INV \vga/inst_Mram_mem21/CLKBMUX  (
    .I(\vga/pclk [2]),
    .O(\vga/inst_Mram_mem21/CLKB_INTNOT )
  );
  defparam \vga/inst_Mram_mem21 .INIT_00 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem21 .INIT_01 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem21 .INIT_02 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem21 .INIT_03 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem21 .INIT_04 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem21 .INIT_05 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem21 .INIT_06 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem21 .INIT_07 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem21 .INIT_08 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem21 .INIT_09 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem21 .INIT_0A = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem21 .INIT_0B = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem21 .INIT_0C = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem21 .INIT_0D = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem21 .INIT_0E = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem21 .INIT_0F = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem21 .LOC = "RAMB4_R5C0";
  defparam \vga/inst_Mram_mem21 .SETUP_ALL = 3737;
  X_RAMB4_S1_S1 \vga/inst_Mram_mem21  (
    .CLKA(\vga/ram_wclk_5 ),
    .CLKB(\vga/inst_Mram_mem21/CLKB_INTNOT ),
    .ENA(\vga/inst_Mram_mem21/LOGIC_ONE_62 ),
    .ENB(\vga/inst_Mram_mem21/LOGIC_ONE_62 ),
    .RSTA(\vga/inst_Mram_mem21/LOGIC_ZERO_61 ),
    .RSTB(\vga/inst_Mram_mem21/LOGIC_ZERO_61 ),
    .WEA(\vga/N226_0 ),
    .WEB(\vga/inst_Mram_mem21/LOGIC_ZERO_61 ),
    .ADDRA({\vga/video_ram/ram_addr_w [11], \vga/video_ram/ram_addr_w [10], \vga/video_ram/ram_addr_w [9], \vga/video_ram/ram_addr_w [8], 
\vga/video_ram/ram_addr_w [7], \vga/video_ram/ram_addr_w [6], \vga/video_ram/ram_addr_w [5], \vga/video_ram/ram_addr_w [4], 
\vga/video_ram/ram_addr_w [3], \vga/video_ram/ram_addr_w [2], \vga/video_ram/ram_addr_w [1], \vga/video_ram/ram_addr_w [0]}),
    .ADDRB({\vga/ram_addr_mux<11>_0 , \vga/ram_addr_mux<10>_0 , \vga/ram_addr_mux<9>_0 , \vga/ram_addr_mux<8>_0 , \vga/ram_addr_mux<7>_0 , 
\vga/ram_addr_mux<6>_0 , \vga/ram_addr_mux<5>_0 , \vga/ram_addr_mux<4>_0 , \vga/ram_addr_mux<3>_0 , \vga/ram_addr_mux<2>_0 , \vga/ram_addr_mux<1>_0 , 
\vga/ram_addr_mux<0>_0 }),
    .DIA({\vga/crt/ram_data [2]}),
    .DIB({\vga/inst_Mram_mem21/DIB0 }),
    .DOA({\vga/inst_Mram_mem21/DOA0 }),
    .DOB({\vga/ram_data_out [2]})
  );
  defparam \vga/inst_Mram_mem31/LOGIC_ONE .LOC = "RAMB4_R6C0";
  X_ONE \vga/inst_Mram_mem31/LOGIC_ONE  (
    .O(\vga/inst_Mram_mem31/LOGIC_ONE_64 )
  );
  defparam \vga/inst_Mram_mem31/LOGIC_ZERO .LOC = "RAMB4_R6C0";
  X_ZERO \vga/inst_Mram_mem31/LOGIC_ZERO  (
    .O(\vga/inst_Mram_mem31/LOGIC_ZERO_63 )
  );
  defparam \vga/inst_Mram_mem31/CLKBMUX .LOC = "RAMB4_R6C0";
  X_INV \vga/inst_Mram_mem31/CLKBMUX  (
    .I(\vga/pclk [2]),
    .O(\vga/inst_Mram_mem31/CLKB_INTNOT )
  );
  defparam \vga/inst_Mram_mem31 .INIT_00 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem31 .INIT_01 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem31 .INIT_02 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem31 .INIT_03 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem31 .INIT_04 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem31 .INIT_05 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem31 .INIT_06 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem31 .INIT_07 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem31 .INIT_08 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem31 .INIT_09 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem31 .INIT_0A = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem31 .INIT_0B = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem31 .INIT_0C = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem31 .INIT_0D = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem31 .INIT_0E = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem31 .INIT_0F = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem31 .LOC = "RAMB4_R6C0";
  defparam \vga/inst_Mram_mem31 .SETUP_ALL = 3737;
  X_RAMB4_S1_S1 \vga/inst_Mram_mem31  (
    .CLKA(\vga/ram_wclk_5 ),
    .CLKB(\vga/inst_Mram_mem31/CLKB_INTNOT ),
    .ENA(\vga/inst_Mram_mem31/LOGIC_ONE_64 ),
    .ENB(\vga/inst_Mram_mem31/LOGIC_ONE_64 ),
    .RSTA(\vga/inst_Mram_mem31/LOGIC_ZERO_63 ),
    .RSTB(\vga/inst_Mram_mem31/LOGIC_ZERO_63 ),
    .WEA(\vga/N226_0 ),
    .WEB(\vga/inst_Mram_mem31/LOGIC_ZERO_63 ),
    .ADDRA({\vga/video_ram/ram_addr_w [11], \vga/video_ram/ram_addr_w [10], \vga/video_ram/ram_addr_w [9], \vga/video_ram/ram_addr_w [8], 
\vga/video_ram/ram_addr_w [7], \vga/video_ram/ram_addr_w [6], \vga/video_ram/ram_addr_w [5], \vga/video_ram/ram_addr_w [4], 
\vga/video_ram/ram_addr_w [3], \vga/video_ram/ram_addr_w [2], \vga/video_ram/ram_addr_w [1], \vga/video_ram/ram_addr_w [0]}),
    .ADDRB({\vga/ram_addr_mux<11>_0 , \vga/ram_addr_mux<10>_0 , \vga/ram_addr_mux<9>_0 , \vga/ram_addr_mux<8>_0 , \vga/ram_addr_mux<7>_0 , 
\vga/ram_addr_mux<6>_0 , \vga/ram_addr_mux<5>_0 , \vga/ram_addr_mux<4>_0 , \vga/ram_addr_mux<3>_0 , \vga/ram_addr_mux<2>_0 , \vga/ram_addr_mux<1>_0 , 
\vga/ram_addr_mux<0>_0 }),
    .DIA({\vga/crt/ram_data [3]}),
    .DIB({\vga/inst_Mram_mem31/DIB0 }),
    .DOA({\vga/inst_Mram_mem31/DOA0 }),
    .DOB({\vga/ram_data_out [3]})
  );
  defparam \vga/inst_Mram_mem41/LOGIC_ONE .LOC = "RAMB4_R0C0";
  X_ONE \vga/inst_Mram_mem41/LOGIC_ONE  (
    .O(\vga/inst_Mram_mem41/LOGIC_ONE_66 )
  );
  defparam \vga/inst_Mram_mem41/LOGIC_ZERO .LOC = "RAMB4_R0C0";
  X_ZERO \vga/inst_Mram_mem41/LOGIC_ZERO  (
    .O(\vga/inst_Mram_mem41/LOGIC_ZERO_65 )
  );
  defparam \vga/inst_Mram_mem41/CLKBMUX .LOC = "RAMB4_R0C0";
  X_INV \vga/inst_Mram_mem41/CLKBMUX  (
    .I(\vga/pclk [2]),
    .O(\vga/inst_Mram_mem41/CLKB_INTNOT )
  );
  defparam \vga/inst_Mram_mem41 .INIT_00 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem41 .INIT_01 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem41 .INIT_02 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem41 .INIT_03 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem41 .INIT_04 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem41 .INIT_05 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem41 .INIT_06 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem41 .INIT_07 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem41 .INIT_08 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem41 .INIT_09 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem41 .INIT_0A = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem41 .INIT_0B = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem41 .INIT_0C = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem41 .INIT_0D = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem41 .INIT_0E = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem41 .INIT_0F = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem41 .LOC = "RAMB4_R0C0";
  defparam \vga/inst_Mram_mem41 .SETUP_ALL = 3737;
  X_RAMB4_S1_S1 \vga/inst_Mram_mem41  (
    .CLKA(\vga/ram_wclk_5 ),
    .CLKB(\vga/inst_Mram_mem41/CLKB_INTNOT ),
    .ENA(\vga/inst_Mram_mem41/LOGIC_ONE_66 ),
    .ENB(\vga/inst_Mram_mem41/LOGIC_ONE_66 ),
    .RSTA(\vga/inst_Mram_mem41/LOGIC_ZERO_65 ),
    .RSTB(\vga/inst_Mram_mem41/LOGIC_ZERO_65 ),
    .WEA(\vga/N226_0 ),
    .WEB(\vga/inst_Mram_mem41/LOGIC_ZERO_65 ),
    .ADDRA({\vga/video_ram/ram_addr_w [11], \vga/video_ram/ram_addr_w [10], \vga/video_ram/ram_addr_w [9], \vga/video_ram/ram_addr_w [8], 
\vga/video_ram/ram_addr_w [7], \vga/video_ram/ram_addr_w [6], \vga/video_ram/ram_addr_w [5], \vga/video_ram/ram_addr_w [4], 
\vga/video_ram/ram_addr_w [3], \vga/video_ram/ram_addr_w [2], \vga/video_ram/ram_addr_w [1], \vga/video_ram/ram_addr_w [0]}),
    .ADDRB({\vga/ram_addr_mux<11>_0 , \vga/ram_addr_mux<10>_0 , \vga/ram_addr_mux<9>_0 , \vga/ram_addr_mux<8>_0 , \vga/ram_addr_mux<7>_0 , 
\vga/ram_addr_mux<6>_0 , \vga/ram_addr_mux<5>_0 , \vga/ram_addr_mux<4>_0 , \vga/ram_addr_mux<3>_0 , \vga/ram_addr_mux<2>_0 , \vga/ram_addr_mux<1>_0 , 
\vga/ram_addr_mux<0>_0 }),
    .DIA({\vga/crt/ram_data [4]}),
    .DIB({\vga/inst_Mram_mem41/DIB0 }),
    .DOA({\vga/inst_Mram_mem41/DOA0 }),
    .DOB({\vga/ram_data_out [4]})
  );
  defparam \vga/inst_Mram_mem51/LOGIC_ONE .LOC = "RAMB4_R2C0";
  X_ONE \vga/inst_Mram_mem51/LOGIC_ONE  (
    .O(\vga/inst_Mram_mem51/LOGIC_ONE_68 )
  );
  defparam \vga/inst_Mram_mem51/LOGIC_ZERO .LOC = "RAMB4_R2C0";
  X_ZERO \vga/inst_Mram_mem51/LOGIC_ZERO  (
    .O(\vga/inst_Mram_mem51/LOGIC_ZERO_67 )
  );
  defparam \vga/inst_Mram_mem51/CLKBMUX .LOC = "RAMB4_R2C0";
  X_INV \vga/inst_Mram_mem51/CLKBMUX  (
    .I(\vga/pclk [2]),
    .O(\vga/inst_Mram_mem51/CLKB_INTNOT )
  );
  defparam \vga/inst_Mram_mem51 .INIT_00 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem51 .INIT_01 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem51 .INIT_02 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem51 .INIT_03 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem51 .INIT_04 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem51 .INIT_05 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem51 .INIT_06 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem51 .INIT_07 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem51 .INIT_08 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem51 .INIT_09 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem51 .INIT_0A = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem51 .INIT_0B = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem51 .INIT_0C = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem51 .INIT_0D = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem51 .INIT_0E = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem51 .INIT_0F = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem51 .LOC = "RAMB4_R2C0";
  defparam \vga/inst_Mram_mem51 .SETUP_ALL = 3737;
  X_RAMB4_S1_S1 \vga/inst_Mram_mem51  (
    .CLKA(\vga/ram_wclk_5 ),
    .CLKB(\vga/inst_Mram_mem51/CLKB_INTNOT ),
    .ENA(\vga/inst_Mram_mem51/LOGIC_ONE_68 ),
    .ENB(\vga/inst_Mram_mem51/LOGIC_ONE_68 ),
    .RSTA(\vga/inst_Mram_mem51/LOGIC_ZERO_67 ),
    .RSTB(\vga/inst_Mram_mem51/LOGIC_ZERO_67 ),
    .WEA(\vga/N226_0 ),
    .WEB(\vga/inst_Mram_mem51/LOGIC_ZERO_67 ),
    .ADDRA({\vga/video_ram/ram_addr_w [11], \vga/video_ram/ram_addr_w [10], \vga/video_ram/ram_addr_w [9], \vga/video_ram/ram_addr_w [8], 
\vga/video_ram/ram_addr_w [7], \vga/video_ram/ram_addr_w [6], \vga/video_ram/ram_addr_w [5], \vga/video_ram/ram_addr_w [4], 
\vga/video_ram/ram_addr_w [3], \vga/video_ram/ram_addr_w [2], \vga/video_ram/ram_addr_w [1], \vga/video_ram/ram_addr_w [0]}),
    .ADDRB({\vga/ram_addr_mux<11>_0 , \vga/ram_addr_mux<10>_0 , \vga/ram_addr_mux<9>_0 , \vga/ram_addr_mux<8>_0 , \vga/ram_addr_mux<7>_0 , 
\vga/ram_addr_mux<6>_0 , \vga/ram_addr_mux<5>_0 , \vga/ram_addr_mux<4>_0 , \vga/ram_addr_mux<3>_0 , \vga/ram_addr_mux<2>_0 , \vga/ram_addr_mux<1>_0 , 
\vga/ram_addr_mux<0>_0 }),
    .DIA({\vga/crt/ram_data [5]}),
    .DIB({\vga/inst_Mram_mem51/DIB0 }),
    .DOA({\vga/inst_Mram_mem51/DOA0 }),
    .DOB({\vga/ram_data_out [5]})
  );
  defparam \vga/inst_Mram_mem61/LOGIC_ONE .LOC = "RAMB4_R1C0";
  X_ONE \vga/inst_Mram_mem61/LOGIC_ONE  (
    .O(\vga/inst_Mram_mem61/LOGIC_ONE_70 )
  );
  defparam \vga/inst_Mram_mem61/LOGIC_ZERO .LOC = "RAMB4_R1C0";
  X_ZERO \vga/inst_Mram_mem61/LOGIC_ZERO  (
    .O(\vga/inst_Mram_mem61/LOGIC_ZERO_69 )
  );
  defparam \vga/inst_Mram_mem61/CLKBMUX .LOC = "RAMB4_R1C0";
  X_INV \vga/inst_Mram_mem61/CLKBMUX  (
    .I(\vga/pclk [2]),
    .O(\vga/inst_Mram_mem61/CLKB_INTNOT )
  );
  defparam \vga/inst_Mram_mem61 .INIT_00 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem61 .INIT_01 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem61 .INIT_02 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem61 .INIT_03 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem61 .INIT_04 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem61 .INIT_05 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem61 .INIT_06 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem61 .INIT_07 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem61 .INIT_08 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem61 .INIT_09 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem61 .INIT_0A = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem61 .INIT_0B = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem61 .INIT_0C = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem61 .INIT_0D = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem61 .INIT_0E = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem61 .INIT_0F = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem61 .LOC = "RAMB4_R1C0";
  defparam \vga/inst_Mram_mem61 .SETUP_ALL = 3737;
  X_RAMB4_S1_S1 \vga/inst_Mram_mem61  (
    .CLKA(\vga/ram_wclk_5 ),
    .CLKB(\vga/inst_Mram_mem61/CLKB_INTNOT ),
    .ENA(\vga/inst_Mram_mem61/LOGIC_ONE_70 ),
    .ENB(\vga/inst_Mram_mem61/LOGIC_ONE_70 ),
    .RSTA(\vga/inst_Mram_mem61/LOGIC_ZERO_69 ),
    .RSTB(\vga/inst_Mram_mem61/LOGIC_ZERO_69 ),
    .WEA(\vga/N226_0 ),
    .WEB(\vga/inst_Mram_mem61/LOGIC_ZERO_69 ),
    .ADDRA({\vga/video_ram/ram_addr_w [11], \vga/video_ram/ram_addr_w [10], \vga/video_ram/ram_addr_w [9], \vga/video_ram/ram_addr_w [8], 
\vga/video_ram/ram_addr_w [7], \vga/video_ram/ram_addr_w [6], \vga/video_ram/ram_addr_w [5], \vga/video_ram/ram_addr_w [4], 
\vga/video_ram/ram_addr_w [3], \vga/video_ram/ram_addr_w [2], \vga/video_ram/ram_addr_w [1], \vga/video_ram/ram_addr_w [0]}),
    .ADDRB({\vga/ram_addr_mux<11>_0 , \vga/ram_addr_mux<10>_0 , \vga/ram_addr_mux<9>_0 , \vga/ram_addr_mux<8>_0 , \vga/ram_addr_mux<7>_0 , 
\vga/ram_addr_mux<6>_0 , \vga/ram_addr_mux<5>_0 , \vga/ram_addr_mux<4>_0 , \vga/ram_addr_mux<3>_0 , \vga/ram_addr_mux<2>_0 , \vga/ram_addr_mux<1>_0 , 
\vga/ram_addr_mux<0>_0 }),
    .DIA({\vga/crt/ram_data [6]}),
    .DIB({\vga/inst_Mram_mem61/DIB0 }),
    .DOA({\vga/inst_Mram_mem61/DOA0 }),
    .DOB({\vga/ram_data_out [6]})
  );
  defparam \vga/inst_Mram_mem8/LOGIC_ONE .LOC = "RAMB4_R3C0";
  X_ONE \vga/inst_Mram_mem8/LOGIC_ONE  (
    .O(\vga/inst_Mram_mem8/LOGIC_ONE_72 )
  );
  defparam \vga/inst_Mram_mem8/LOGIC_ZERO .LOC = "RAMB4_R3C0";
  X_ZERO \vga/inst_Mram_mem8/LOGIC_ZERO  (
    .O(\vga/inst_Mram_mem8/LOGIC_ZERO_71 )
  );
  defparam \vga/inst_Mram_mem8/CLKBMUX .LOC = "RAMB4_R3C0";
  X_INV \vga/inst_Mram_mem8/CLKBMUX  (
    .I(\vga/pclk [2]),
    .O(\vga/inst_Mram_mem8/CLKB_INTNOT )
  );
  defparam \vga/inst_Mram_mem8 .INIT_00 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem8 .INIT_01 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem8 .INIT_02 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem8 .INIT_03 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem8 .INIT_04 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem8 .INIT_05 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem8 .INIT_06 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem8 .INIT_07 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem8 .INIT_08 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem8 .INIT_09 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem8 .INIT_0A = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem8 .INIT_0B = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem8 .INIT_0C = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem8 .INIT_0D = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem8 .INIT_0E = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem8 .INIT_0F = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam \vga/inst_Mram_mem8 .LOC = "RAMB4_R3C0";
  defparam \vga/inst_Mram_mem8 .SETUP_ALL = 3737;
  X_RAMB4_S1_S1 \vga/inst_Mram_mem8  (
    .CLKA(\vga/ram_wclk_5 ),
    .CLKB(\vga/inst_Mram_mem8/CLKB_INTNOT ),
    .ENA(\vga/inst_Mram_mem8/LOGIC_ONE_72 ),
    .ENB(\vga/inst_Mram_mem8/LOGIC_ONE_72 ),
    .RSTA(\vga/inst_Mram_mem8/LOGIC_ZERO_71 ),
    .RSTB(\vga/inst_Mram_mem8/LOGIC_ZERO_71 ),
    .WEA(\vga/N226_0 ),
    .WEB(\vga/inst_Mram_mem8/LOGIC_ZERO_71 ),
    .ADDRA({\vga/video_ram/ram_addr_w [11], \vga/video_ram/ram_addr_w [10], \vga/video_ram/ram_addr_w [9], \vga/video_ram/ram_addr_w [8], 
\vga/video_ram/ram_addr_w [7], \vga/video_ram/ram_addr_w [6], \vga/video_ram/ram_addr_w [5], \vga/video_ram/ram_addr_w [4], 
\vga/video_ram/ram_addr_w [3], \vga/video_ram/ram_addr_w [2], \vga/video_ram/ram_addr_w [1], \vga/video_ram/ram_addr_w [0]}),
    .ADDRB({\vga/ram_addr_mux<11>_0 , \vga/ram_addr_mux<10>_0 , \vga/ram_addr_mux<9>_0 , \vga/ram_addr_mux<8>_0 , \vga/ram_addr_mux<7>_0 , 
\vga/ram_addr_mux<6>_0 , \vga/ram_addr_mux<5>_0 , \vga/ram_addr_mux<4>_0 , \vga/ram_addr_mux<3>_0 , \vga/ram_addr_mux<2>_0 , \vga/ram_addr_mux<1>_0 , 
\vga/ram_addr_mux<0>_0 }),
    .DIA({\vga/crt/ram_data [0]}),
    .DIB({\vga/inst_Mram_mem8/DIB0 }),
    .DOA({\vga/inst_Mram_mem8/DOA0 }),
    .DOB({\vga/ram_data_out [0]})
  );
  defparam \vga/scancode_convert/scancode_rom/data<6>1201_SW0 .LOC = "CLB_R11C37.S0";
  X_MUX2 \vga/scancode_convert/scancode_rom/data<6>1201_SW0  (
    .IA(N3198),
    .IB(N3199),
    .SEL(\vga/scancode_convert/sc [3]),
    .O(N3084)
  );
  defparam \vga/scancode_convert/scancode_rom/data<6>1201_SW0_G .INIT = 16'hDF8F;
  defparam \vga/scancode_convert/scancode_rom/data<6>1201_SW0_G .LOC = "CLB_R11C37.S0";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<6>1201_SW0_G  (
    .ADR0(\vga/scancode_convert/sc [2]),
    .ADR1(\vga/scancode_convert/scancode_rom/data<6>1_map1831 ),
    .ADR2(\vga/scancode_convert/sc [5]),
    .ADR3(\vga/scancode_convert/sc [1]),
    .O(N3199)
  );
  defparam \vga/scancode_convert/scancode_rom/data<6>1201_SW0_F .INIT = 16'h0FEF;
  defparam \vga/scancode_convert/scancode_rom/data<6>1201_SW0_F .LOC = "CLB_R11C37.S0";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<6>1201_SW0_F  (
    .ADR0(\vga/scancode_convert/sc [1]),
    .ADR1(\vga/scancode_convert/sc [0]),
    .ADR2(\vga/scancode_convert/sc [5]),
    .ADR3(\vga/scancode_convert/sc [2]),
    .O(N3198)
  );
  defparam \N3084/XUSED .LOC = "CLB_R11C37.S0";
  X_BUF \N3084/XUSED  (
    .I(N3084),
    .O(N3084_0)
  );
  defparam \vga/scancode_convert/scancode_rom/data<1>2416 .LOC = "CLB_R13C36.S1";
  X_MUX2 \vga/scancode_convert/scancode_rom/data<1>2416  (
    .IA(N3186),
    .IB(N3187),
    .SEL(\vga/scancode_convert/sc [0]),
    .O(\vga/scancode_convert/scancode_rom/data<1>2_map1774 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<1>2416_G .INIT = 16'h7555;
  defparam \vga/scancode_convert/scancode_rom/data<1>2416_G .LOC = "CLB_R13C36.S1";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<1>2416_G  (
    .ADR0(\vga/scancode_convert/sc [2]),
    .ADR1(\vga/scancode_convert/sc [3]),
    .ADR2(\vga/scancode_convert/scancode_rom/N9 ),
    .ADR3(\vga/scancode_convert/sc [4]),
    .O(N3187)
  );
  defparam \vga/scancode_convert/scancode_rom/data<1>2416_F .INIT = 16'h13FF;
  defparam \vga/scancode_convert/scancode_rom/data<1>2416_F .LOC = "CLB_R13C36.S1";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<1>2416_F  (
    .ADR0(\vga/scancode_convert/sc [3]),
    .ADR1(\vga/scancode_convert/sc [1]),
    .ADR2(\vga/scancode_convert/sc [4]),
    .ADR3(\vga/scancode_convert/sc [2]),
    .O(N3186)
  );
  defparam \vga/scancode_convert/scancode_rom/data<1>2_map1774/XUSED .LOC = "CLB_R13C36.S1";
  X_BUF \vga/scancode_convert/scancode_rom/data<1>2_map1774/XUSED  (
    .I(\vga/scancode_convert/scancode_rom/data<1>2_map1774 ),
    .O(\vga/scancode_convert/scancode_rom/data<1>2_map1774_0 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<3>1352_f5 .LOC = "CLB_R18C34.S0";
  X_MUX2 \vga/scancode_convert/scancode_rom/data<3>1352_f5  (
    .IA(\vga/scancode_convert/scancode_rom/data<3>1_map1229/GROM ),
    .IB(N3245),
    .SEL(\vga/scancode_convert/sc [5]),
    .O(\vga/scancode_convert/scancode_rom/data<3>1_map1229 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<3>13521 .INIT = 16'h0040;
  defparam \vga/scancode_convert/scancode_rom/data<3>13521 .LOC = "CLB_R18C34.S0";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<3>13521  (
    .ADR0(\vga/scancode_convert/sc [3]),
    .ADR1(\vga/scancode_convert/sc [1]),
    .ADR2(\vga/scancode_convert/sc [2]),
    .ADR3(\vga/scancode_convert/sc [0]),
    .O(N3245)
  );
  defparam \vga/scancode_convert/scancode_rom/data<3>1_map1229/G .INIT = 16'hFFFF;
  defparam \vga/scancode_convert/scancode_rom/data<3>1_map1229/G .LOC = "CLB_R18C34.S0";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<3>1_map1229/G  (
    .ADR0(VCC),
    .ADR1(VCC),
    .ADR2(VCC),
    .ADR3(VCC),
    .O(\vga/scancode_convert/scancode_rom/data<3>1_map1229/GROM )
  );
  defparam \vga/scancode_convert/scancode_rom/data<3>1_map1229/XUSED .LOC = "CLB_R18C34.S0";
  X_BUF \vga/scancode_convert/scancode_rom/data<3>1_map1229/XUSED  (
    .I(\vga/scancode_convert/scancode_rom/data<3>1_map1229 ),
    .O(\vga/scancode_convert/scancode_rom/data<3>1_map1229_0 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<2>1207 .LOC = "CLB_R15C37.S0";
  X_MUX2 \vga/scancode_convert/scancode_rom/data<2>1207  (
    .IA(N3200),
    .IB(N3201),
    .SEL(\vga/scancode_convert/sc [5]),
    .O(\vga/scancode_convert/scancode_rom/data<2>1_map1098 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<2>1207_G .INIT = 16'h4477;
  defparam \vga/scancode_convert/scancode_rom/data<2>1207_G .LOC = "CLB_R15C37.S0";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<2>1207_G  (
    .ADR0(N3142_0),
    .ADR1(\vga/scancode_convert/sc [4]),
    .ADR2(VCC),
    .ADR3(N3141_0),
    .O(N3201)
  );
  defparam \vga/scancode_convert/scancode_rom/data<2>1207_F .INIT = 16'h88AA;
  defparam \vga/scancode_convert/scancode_rom/data<2>1207_F .LOC = "CLB_R15C37.S0";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<2>1207_F  (
    .ADR0(\vga/scancode_convert/scancode_rom/data<2>1_map1056_0 ),
    .ADR1(\vga/scancode_convert/sc [4]),
    .ADR2(VCC),
    .ADR3(\vga/scancode_convert/scancode_rom/N28_0 ),
    .O(N3200)
  );
  defparam \vga/scancode_convert/scancode_rom/data<2>1_map1098/XUSED .LOC = "CLB_R15C37.S0";
  X_BUF \vga/scancode_convert/scancode_rom/data<2>1_map1098/XUSED  (
    .I(\vga/scancode_convert/scancode_rom/data<2>1_map1098 ),
    .O(\vga/scancode_convert/scancode_rom/data<2>1_map1098_0 )
  );
  defparam \vga/charload1_SW0 .LOC = "CLB_R12C3.S0";
  X_MUX2 \vga/charload1_SW0  (
    .IA(N3192),
    .IB(N3193),
    .SEL(\vga/rom_addr_char [6]),
    .O(N560)
  );
  defparam \vga/charload1_SW0_G .INIT = 16'hF3C0;
  defparam \vga/charload1_SW0_G .LOC = "CLB_R12C3.S0";
  X_LUT4 \vga/charload1_SW0_G  (
    .ADR0(VCC),
    .ADR1(\vga/rom_addr_char [5]),
    .ADR2(\vga/rom_addr_char<4>_f5_0 ),
    .ADR3(\vga/rom_addr_char<4>11_0 ),
    .O(N3193)
  );
  defparam \vga/charload1_SW0_F .INIT = 16'h88C0;
  defparam \vga/charload1_SW0_F .LOC = "CLB_R12C3.S0";
  X_LUT4 \vga/charload1_SW0_F  (
    .ADR0(\vga/rom_addr_char<3>_f61_0 ),
    .ADR1(\vga/rom_addr_char [5]),
    .ADR2(\vga/rom_addr_char<3>_f6_0_6 ),
    .ADR3(\vga/rom_addr_char [4]),
    .O(N3192)
  );
  defparam \N560/XUSED .LOC = "CLB_R12C3.S0";
  X_BUF \N560/XUSED  (
    .I(N560),
    .O(N560_0)
  );
  defparam \vga/scancode_convert/scancode_rom/data<3>1382 .LOC = "CLB_R18C35.S1";
  X_MUX2 \vga/scancode_convert/scancode_rom/data<3>1382  (
    .IA(N3116),
    .IB(N3117),
    .SEL(\vga/scancode_convert/sc [6]),
    .O(\vga/scancode_convert/rom_data [3])
  );
  defparam \vga/scancode_convert/scancode_rom/data<3>1382_G .INIT = 16'hEA00;
  defparam \vga/scancode_convert/scancode_rom/data<3>1382_G .LOC = "CLB_R18C35.S1";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<3>1382_G  (
    .ADR0(\vga/scancode_convert/sc [5]),
    .ADR1(\vga/scancode_convert/scancode_rom/data<3>1_map1221_0 ),
    .ADR2(\vga/scancode_convert/scancode_rom/data<3>1_map1201_0 ),
    .ADR3(\vga/scancode_convert/scancode_rom/data<3>1_map1229_0 ),
    .O(N3117)
  );
  defparam \vga/scancode_convert/scancode_rom/data<3>1382_F .INIT = 16'h8F80;
  defparam \vga/scancode_convert/scancode_rom/data<3>1382_F .LOC = "CLB_R18C35.S1";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<3>1382_F  (
    .ADR0(\vga/scancode_convert/scancode_rom/data<3>1_map1171_0 ),
    .ADR1(\vga/scancode_convert/scancode_rom/data<3>1_map1185_0 ),
    .ADR2(\vga/scancode_convert/sc [5]),
    .ADR3(\vga/scancode_convert/scancode_rom/data<3>1_map1158_0 ),
    .O(N3116)
  );
  defparam \vga/scancode_convert/scancode_rom/data<3>1299 .LOC = "CLB_R17C35.S1";
  X_MUX2 \vga/scancode_convert/scancode_rom/data<3>1299  (
    .IA(N3190),
    .IB(N3191),
    .SEL(\vga/scancode_convert/sc [4]),
    .O(\vga/scancode_convert/scancode_rom/data<3>1_map1221 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<3>1299_G .INIT = 16'h7377;
  defparam \vga/scancode_convert/scancode_rom/data<3>1299_G .LOC = "CLB_R17C35.S1";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<3>1299_G  (
    .ADR0(\vga/scancode_convert/sc [1]),
    .ADR1(\vga/scancode_convert/sc [2]),
    .ADR2(\vga/scancode_convert/sc [0]),
    .ADR3(\vga/scancode_convert/sc [3]),
    .O(N3191)
  );
  defparam \vga/scancode_convert/scancode_rom/data<3>1299_F .INIT = 16'h7F5F;
  defparam \vga/scancode_convert/scancode_rom/data<3>1299_F .LOC = "CLB_R17C35.S1";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<3>1299_F  (
    .ADR0(\vga/scancode_convert/sc [2]),
    .ADR1(\vga/scancode_convert/sc [3]),
    .ADR2(\vga/scancode_convert/sc [0]),
    .ADR3(\vga/scancode_convert/scancode_rom/N9 ),
    .O(N3190)
  );
  defparam \vga/scancode_convert/scancode_rom/data<3>1_map1221/XUSED .LOC = "CLB_R17C35.S1";
  X_BUF \vga/scancode_convert/scancode_rom/data<3>1_map1221/XUSED  (
    .I(\vga/scancode_convert/scancode_rom/data<3>1_map1221 ),
    .O(\vga/scancode_convert/scancode_rom/data<3>1_map1221_0 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<4>1437 .LOC = "CLB_R10C36.S0";
  X_MUX2 \vga/scancode_convert/scancode_rom/data<4>1437  (
    .IA(N3118),
    .IB(N3119),
    .SEL(\vga/scancode_convert/raise ),
    .O(\vga/scancode_convert/scancode_rom/data<4>1_map1633 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<4>1437_G .INIT = 16'h9040;
  defparam \vga/scancode_convert/scancode_rom/data<4>1437_G .LOC = "CLB_R10C36.S0";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<4>1437_G  (
    .ADR0(\vga/scancode_convert/sc [4]),
    .ADR1(\vga/scancode_convert/sc [0]),
    .ADR2(\vga/scancode_convert/sc [3]),
    .ADR3(\vga/scancode_convert/sc [1]),
    .O(N3119)
  );
  defparam \vga/scancode_convert/scancode_rom/data<4>1437_F .INIT = 16'h8000;
  defparam \vga/scancode_convert/scancode_rom/data<4>1437_F .LOC = "CLB_R10C36.S0";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<4>1437_F  (
    .ADR0(\vga/scancode_convert/sc [0]),
    .ADR1(\vga/scancode_convert/sc [3]),
    .ADR2(\vga/scancode_convert/sc [4]),
    .ADR3(\vga/scancode_convert/sc [1]),
    .O(N3118)
  );
  defparam \vga/scancode_convert/scancode_rom/data<4>1_map1633/XUSED .LOC = "CLB_R10C36.S0";
  X_BUF \vga/scancode_convert/scancode_rom/data<4>1_map1633/XUSED  (
    .I(\vga/scancode_convert/scancode_rom/data<4>1_map1633 ),
    .O(\vga/scancode_convert/scancode_rom/data<4>1_map1633_0 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<4>1673 .LOC = "CLB_R12C36.S1";
  X_MUX2 \vga/scancode_convert/scancode_rom/data<4>1673  (
    .IA(N3120),
    .IB(N3121),
    .SEL(\vga/scancode_convert/sc [6]),
    .O(\vga/scancode_convert/rom_data [4])
  );
  defparam \vga/scancode_convert/scancode_rom/data<4>1673_G .INIT = 16'hF0A0;
  defparam \vga/scancode_convert/scancode_rom/data<4>1673_G .LOC = "CLB_R12C36.S1";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<4>1673_G  (
    .ADR0(\vga/scancode_convert/sc [5]),
    .ADR1(VCC),
    .ADR2(\vga/scancode_convert/scancode_rom/data<0>1_map1534_0 ),
    .ADR3(\vga/scancode_convert/scancode_rom/data<4>1_map1669_0 ),
    .O(N3121)
  );
  defparam \vga/scancode_convert/scancode_rom/data<4>1673_F .INIT = 16'hE444;
  defparam \vga/scancode_convert/scancode_rom/data<4>1673_F .LOC = "CLB_R12C36.S1";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<4>1673_F  (
    .ADR0(\vga/scancode_convert/sc [5]),
    .ADR1(\vga/scancode_convert/scancode_rom/data<4>1_map1560_0 ),
    .ADR2(\vga/scancode_convert/scancode_rom/data<4>1_map1609_0 ),
    .ADR3(\vga/scancode_convert/scancode_rom/data<4>1_map1565_0 ),
    .O(N3120)
  );
  defparam \vga/rom_addr_char<2>_f5_0 .LOC = "CLB_R19C3.S0";
  X_MUX2 \vga/rom_addr_char<2>_f5_0  (
    .IA(\vga/N312 ),
    .IB(\vga/N2123 ),
    .SEL(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f51_73 )
  );
  defparam \vga/rom_addr_char<1>2 .INIT = 16'hF5A0;
  defparam \vga/rom_addr_char<1>2 .LOC = "CLB_R19C3.S0";
  X_LUT4 \vga/rom_addr_char<1>2  (
    .ADR0(\vga/rom_addr_char [1]),
    .ADR1(VCC),
    .ADR2(\vga/N12_0 ),
    .ADR3(\vga/N11_0 ),
    .O(\vga/N2123 )
  );
  defparam \vga/rom_addr_char<1>3 .INIT = 16'hF000;
  defparam \vga/rom_addr_char<1>3 .LOC = "CLB_R19C3.S0";
  X_LUT4 \vga/rom_addr_char<1>3  (
    .ADR0(VCC),
    .ADR1(VCC),
    .ADR2(\vga/N10_0 ),
    .ADR3(\vga/rom_addr_char_1_1_7 ),
    .O(\vga/N312 )
  );
  defparam \vga/rom_addr_char<2>_f51/F5USED .LOC = "CLB_R19C3.S0";
  X_BUF \vga/rom_addr_char<2>_f51/F5USED  (
    .I(\vga/rom_addr_char<2>_f51_73 ),
    .O(\vga/rom_addr_char<2>_f51_0 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<4>1588 .LOC = "CLB_R10C35.S1";
  X_MUX2 \vga/scancode_convert/scancode_rom/data<4>1588  (
    .IA(N3202),
    .IB(N3203),
    .SEL(\vga/scancode_convert/raise ),
    .O(\vga/scancode_convert/scancode_rom/data<4>1_map1666 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<4>1588_G .INIT = 16'h2212;
  defparam \vga/scancode_convert/scancode_rom/data<4>1588_G .LOC = "CLB_R10C35.S1";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<4>1588_G  (
    .ADR0(\vga/scancode_convert/sc [3]),
    .ADR1(\vga/scancode_convert/sc [1]),
    .ADR2(\vga/scancode_convert/sc [4]),
    .ADR3(\vga/scancode_convert/sc [0]),
    .O(N3203)
  );
  defparam \vga/scancode_convert/scancode_rom/data<4>1588_F .INIT = 16'h4556;
  defparam \vga/scancode_convert/scancode_rom/data<4>1588_F .LOC = "CLB_R10C35.S1";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<4>1588_F  (
    .ADR0(\vga/scancode_convert/sc [1]),
    .ADR1(\vga/scancode_convert/sc [0]),
    .ADR2(\vga/scancode_convert/sc [4]),
    .ADR3(\vga/scancode_convert/sc [3]),
    .O(N3202)
  );
  defparam \vga/scancode_convert/scancode_rom/data<4>1_map1666/XUSED .LOC = "CLB_R10C35.S1";
  X_BUF \vga/scancode_convert/scancode_rom/data<4>1_map1666/XUSED  (
    .I(\vga/scancode_convert/scancode_rom/data<4>1_map1666 ),
    .O(\vga/scancode_convert/scancode_rom/data<4>1_map1666_0 )
  );
  defparam \vga/rom_addr_char<2>_f5_1 .LOC = "CLB_R3C3.S1";
  X_MUX2 \vga/rom_addr_char<2>_f5_1  (
    .IA(\vga/N512 ),
    .IB(\vga/N412 ),
    .SEL(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f52_75 )
  );
  defparam \vga/rom_addr_char<1>4 .INIT = 16'hEE22;
  defparam \vga/rom_addr_char<1>4 .LOC = "CLB_R3C3.S1";
  X_LUT4 \vga/rom_addr_char<1>4  (
    .ADR0(\vga/N21_0 ),
    .ADR1(\vga/rom_addr_char_1_1_7 ),
    .ADR2(VCC),
    .ADR3(\vga/N22_0 ),
    .O(\vga/N412 )
  );
  defparam \vga/rom_addr_char<1>5 .INIT = 16'h00F0;
  defparam \vga/rom_addr_char<1>5 .LOC = "CLB_R3C3.S1";
  X_LUT4 \vga/rom_addr_char<1>5  (
    .ADR0(VCC),
    .ADR1(VCC),
    .ADR2(\vga/N20_0 ),
    .ADR3(\vga/rom_addr_char_1_1_7 ),
    .O(\vga/N512 )
  );
  defparam \vga/rom_addr_char<3>_f61/YUSED .LOC = "CLB_R3C3.S1";
  X_BUF \vga/rom_addr_char<3>_f61/YUSED  (
    .I(\vga/rom_addr_char<3>_f61_74 ),
    .O(\vga/rom_addr_char<3>_f61_0 )
  );
  defparam \vga/rom_addr_char<3>_f6_0 .LOC = "CLB_R3C3.S1";
  X_MUX2 \vga/rom_addr_char<3>_f6_0  (
    .IA(\vga/rom_addr_char<2>_f53_0 ),
    .IB(\vga/rom_addr_char<2>_f52_75 ),
    .SEL(\vga/rom_addr_char [3]),
    .O(\vga/rom_addr_char<3>_f61_74 )
  );
  defparam \vga/rom_addr_char<2>_f5_2 .LOC = "CLB_R3C3.S0";
  X_MUX2 \vga/rom_addr_char<2>_f5_2  (
    .IA(\vga/N712 ),
    .IB(\vga/N612 ),
    .SEL(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f53_76 )
  );
  defparam \vga/rom_addr_char<1>6 .INIT = 16'h0033;
  defparam \vga/rom_addr_char<1>6 .LOC = "CLB_R3C3.S0";
  X_LUT4 \vga/rom_addr_char<1>6  (
    .ADR0(VCC),
    .ADR1(N3146_0),
    .ADR2(VCC),
    .ADR3(\vga/vgacore/vcnt_1_1_8 ),
    .O(\vga/N612 )
  );
  defparam \vga/rom_addr_char<1>7 .INIT = 16'hAAF0;
  defparam \vga/rom_addr_char<1>7 .LOC = "CLB_R3C3.S0";
  X_LUT4 \vga/rom_addr_char<1>7  (
    .ADR0(\vga/N17_0 ),
    .ADR1(VCC),
    .ADR2(\vga/N16_0 ),
    .ADR3(\vga/rom_addr_char_1_1_7 ),
    .O(\vga/N712 )
  );
  defparam \vga/rom_addr_char<2>_f53/F5USED .LOC = "CLB_R3C3.S0";
  X_BUF \vga/rom_addr_char<2>_f53/F5USED  (
    .I(\vga/rom_addr_char<2>_f53_76 ),
    .O(\vga/rom_addr_char<2>_f53_0 )
  );
  defparam \vga/pixel<8>19_f5 .LOC = "CLB_R16C8.S1";
  X_MUX2 \vga/pixel<8>19_f5  (
    .IA(N3222),
    .IB(N3221),
    .SEL(\vga/vgacore/vcnt [9]),
    .O(\vga/pixel<8>_map785 )
  );
  defparam \vga/pixel<8>191 .INIT = 16'hDD55;
  defparam \vga/pixel<8>191 .LOC = "CLB_R16C8.S1";
  X_LUT4 \vga/pixel<8>191  (
    .ADR0(\vga/vgacore/N51_0 ),
    .ADR1(\vga/vgacore/vcnt [3]),
    .ADR2(VCC),
    .ADR3(\vga/vgacore/vcnt_2_1_9 ),
    .O(N3221)
  );
  defparam \vga/vgacore/_or000011 .INIT = 16'h7FFF;
  defparam \vga/vgacore/_or000011 .LOC = "CLB_R16C8.S1";
  X_LUT4 \vga/vgacore/_or000011  (
    .ADR0(\vga/vgacore/vcnt [6]),
    .ADR1(\vga/vgacore/vcnt [5]),
    .ADR2(\vga/vgacore/vcnt [7]),
    .ADR3(\vga/vgacore/vcnt [8]),
    .O(N3222)
  );
  defparam \vga/pixel<8>_map785/XUSED .LOC = "CLB_R16C8.S1";
  X_BUF \vga/pixel<8>_map785/XUSED  (
    .I(\vga/pixel<8>_map785 ),
    .O(\vga/pixel<8>_map785_0 )
  );
  defparam \vga/pixel<8>_map785/YUSED .LOC = "CLB_R16C8.S1";
  X_BUF \vga/pixel<8>_map785/YUSED  (
    .I(N3222),
    .O(N3222_0)
  );
  defparam \vga/rom_addr_char<2>_f5_3 .LOC = "CLB_R4C3.S1";
  X_MUX2 \vga/rom_addr_char<2>_f5_3  (
    .IA(\vga/N1011 ),
    .IB(\vga/N912 ),
    .SEL(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f54_78 )
  );
  defparam \vga/rom_addr_char<1>8 .INIT = 16'hEE44;
  defparam \vga/rom_addr_char<1>8 .LOC = "CLB_R4C3.S1";
  X_LUT4 \vga/rom_addr_char<1>8  (
    .ADR0(\vga/rom_addr_char_1_1_7 ),
    .ADR1(\vga/N29_0 ),
    .ADR2(VCC),
    .ADR3(\vga/N30_0 ),
    .O(\vga/N912 )
  );
  defparam \vga/rom_addr_char<1>9 .INIT = 16'hEE44;
  defparam \vga/rom_addr_char<1>9 .LOC = "CLB_R4C3.S1";
  X_LUT4 \vga/rom_addr_char<1>9  (
    .ADR0(\vga/rom_addr_char_1_1_7 ),
    .ADR1(\vga/N27_0 ),
    .ADR2(VCC),
    .ADR3(\vga/N28_0 ),
    .O(\vga/N1011 )
  );
  defparam \vga/rom_addr_char<3>_f62/YUSED .LOC = "CLB_R4C3.S1";
  X_BUF \vga/rom_addr_char<3>_f62/YUSED  (
    .I(\vga/rom_addr_char<3>_f62_77 ),
    .O(\vga/rom_addr_char<3>_f62_0 )
  );
  defparam \vga/rom_addr_char<3>_f6_1 .LOC = "CLB_R4C3.S1";
  X_MUX2 \vga/rom_addr_char<3>_f6_1  (
    .IA(\vga/rom_addr_char<2>_f55_0 ),
    .IB(\vga/rom_addr_char<2>_f54_78 ),
    .SEL(\vga/rom_addr_char [3]),
    .O(\vga/rom_addr_char<3>_f62_77 )
  );
  defparam \vga/rom_addr_char<2>_f5_4 .LOC = "CLB_R4C3.S0";
  X_MUX2 \vga/rom_addr_char<2>_f5_4  (
    .IA(\vga/N1211 ),
    .IB(\vga/N1111 ),
    .SEL(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f55 )
  );
  defparam \vga/rom_addr_char<1>10 .INIT = 16'hACAC;
  defparam \vga/rom_addr_char<1>10 .LOC = "CLB_R4C3.S0";
  X_LUT4 \vga/rom_addr_char<1>10  (
    .ADR0(\vga/N26_0 ),
    .ADR1(\vga/N25_0 ),
    .ADR2(\vga/rom_addr_char [1]),
    .ADR3(VCC),
    .O(\vga/N1111 )
  );
  defparam \vga/rom_addr_char<1>11 .INIT = 16'hFA0A;
  defparam \vga/rom_addr_char<1>11 .LOC = "CLB_R4C3.S0";
  X_LUT4 \vga/rom_addr_char<1>11  (
    .ADR0(\vga/N23_0 ),
    .ADR1(VCC),
    .ADR2(\vga/rom_addr_char [1]),
    .ADR3(\vga/N24_0 ),
    .O(\vga/N1211 )
  );
  defparam \vga/rom_addr_char<2>_f55/F5USED .LOC = "CLB_R4C3.S0";
  X_BUF \vga/rom_addr_char<2>_f55/F5USED  (
    .I(\vga/rom_addr_char<2>_f55 ),
    .O(\vga/rom_addr_char<2>_f55_0 )
  );
  defparam \vga/rom_addr_char<2>_f5_5 .LOC = "CLB_R10C2.S1";
  X_MUX2 \vga/rom_addr_char<2>_f5_5  (
    .IA(\vga/N1411 ),
    .IB(\vga/N1311 ),
    .SEL(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f56 )
  );
  defparam \vga/rom_addr_char<1>12 .INIT = 16'hAACC;
  defparam \vga/rom_addr_char<1>12 .LOC = "CLB_R10C2.S1";
  X_LUT4 \vga/rom_addr_char<1>12  (
    .ADR0(\vga/N37_0 ),
    .ADR1(\vga/N7_0 ),
    .ADR2(VCC),
    .ADR3(\vga/rom_addr_char [1]),
    .O(\vga/N1311 )
  );
  defparam \vga/rom_addr_char<1>13 .INIT = 16'h3300;
  defparam \vga/rom_addr_char<1>13 .LOC = "CLB_R10C2.S1";
  X_LUT4 \vga/rom_addr_char<1>13  (
    .ADR0(VCC),
    .ADR1(\vga/rom_addr_char [1]),
    .ADR2(VCC),
    .ADR3(\vga/N35_0 ),
    .O(\vga/N1411 )
  );
  defparam \vga/rom_addr_char<3>_f63/YUSED .LOC = "CLB_R10C2.S1";
  X_BUF \vga/rom_addr_char<3>_f63/YUSED  (
    .I(\vga/rom_addr_char<3>_f63_79 ),
    .O(\vga/rom_addr_char<3>_f63_0 )
  );
  defparam \vga/rom_addr_char<3>_f6_2 .LOC = "CLB_R10C2.S1";
  X_MUX2 \vga/rom_addr_char<3>_f6_2  (
    .IA(\vga/rom_addr_char<2>_f57_0 ),
    .IB(\vga/rom_addr_char<2>_f56 ),
    .SEL(\vga/rom_addr_char [3]),
    .O(\vga/rom_addr_char<3>_f63_79 )
  );
  defparam \vga/rom_addr_char<2>_f5_6 .LOC = "CLB_R10C2.S0";
  X_MUX2 \vga/rom_addr_char<2>_f5_6  (
    .IA(\vga/N1611 ),
    .IB(N3078),
    .SEL(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f57 )
  );
  defparam \vga/rom_addr_char<2>_f5_65 .INIT = 16'hB8B8;
  defparam \vga/rom_addr_char<2>_f5_65 .LOC = "CLB_R10C2.S0";
  X_LUT4 \vga/rom_addr_char<2>_f5_65  (
    .ADR0(\vga/N34_0 ),
    .ADR1(\vga/rom_addr_char_1_1_7 ),
    .ADR2(\vga/N33_0 ),
    .ADR3(VCC),
    .O(N3078)
  );
  defparam \vga/rom_addr_char<1>15 .INIT = 16'hCFC0;
  defparam \vga/rom_addr_char<1>15 .LOC = "CLB_R10C2.S0";
  X_LUT4 \vga/rom_addr_char<1>15  (
    .ADR0(VCC),
    .ADR1(\vga/N32_0 ),
    .ADR2(\vga/rom_addr_char [1]),
    .ADR3(\vga/N31_0 ),
    .O(\vga/N1611 )
  );
  defparam \vga/rom_addr_char<2>_f57/F5USED .LOC = "CLB_R10C2.S0";
  X_BUF \vga/rom_addr_char<2>_f57/F5USED  (
    .I(\vga/rom_addr_char<2>_f57 ),
    .O(\vga/rom_addr_char<2>_f57_0 )
  );
  defparam \vga/rom_addr_char<2>_f5_7 .LOC = "CLB_R8C1.S1";
  X_MUX2 \vga/rom_addr_char<2>_f5_7  (
    .IA(\vga/N1811 ),
    .IB(\vga/N1711 ),
    .SEL(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f58 )
  );
  defparam \vga/rom_addr_char<1>16 .INIT = 16'hF000;
  defparam \vga/rom_addr_char<1>16 .LOC = "CLB_R8C1.S1";
  X_LUT4 \vga/rom_addr_char<1>16  (
    .ADR0(VCC),
    .ADR1(VCC),
    .ADR2(\vga/rom_addr_char [1]),
    .ADR3(\vga/N45_0 ),
    .O(\vga/N1711 )
  );
  defparam \vga/rom_addr_char<1>17 .INIT = 16'hDD88;
  defparam \vga/rom_addr_char<1>17 .LOC = "CLB_R8C1.S1";
  X_LUT4 \vga/rom_addr_char<1>17  (
    .ADR0(\vga/rom_addr_char [1]),
    .ADR1(\vga/N44_0 ),
    .ADR2(VCC),
    .ADR3(\vga/N43_0 ),
    .O(\vga/N1811 )
  );
  defparam \vga/rom_addr_char<2>_f58/XUSED .LOC = "CLB_R8C1.S1";
  X_BUF \vga/rom_addr_char<2>_f58/XUSED  (
    .I(\vga/rom_addr_char<2>_f58 ),
    .O(\vga/rom_addr_char<2>_f58_0 )
  );
  defparam \vga/rom_addr_char<2>_f5_8 .LOC = "CLB_R21C5.S1";
  X_MUX2 \vga/rom_addr_char<2>_f5_8  (
    .IA(\vga/N2111 ),
    .IB(\vga/N2011 ),
    .SEL(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f59 )
  );
  defparam \vga/rom_addr_char<1>18 .INIT = 16'hF3C0;
  defparam \vga/rom_addr_char<1>18 .LOC = "CLB_R21C5.S1";
  X_LUT4 \vga/rom_addr_char<1>18  (
    .ADR0(VCC),
    .ADR1(\vga/rom_addr_char [1]),
    .ADR2(\vga/N41_0 ),
    .ADR3(\vga/N40_0 ),
    .O(\vga/N2011 )
  );
  defparam \vga/rom_addr_char<1>19 .INIT = 16'hAACC;
  defparam \vga/rom_addr_char<1>19 .LOC = "CLB_R21C5.S1";
  X_LUT4 \vga/rom_addr_char<1>19  (
    .ADR0(\vga/N39_0 ),
    .ADR1(\vga/N38_0 ),
    .ADR2(VCC),
    .ADR3(\vga/rom_addr_char [1]),
    .O(\vga/N2111 )
  );
  defparam \vga/rom_addr_char<2>_f59/XUSED .LOC = "CLB_R21C5.S1";
  X_BUF \vga/rom_addr_char<2>_f59/XUSED  (
    .I(\vga/rom_addr_char<2>_f59 ),
    .O(\vga/rom_addr_char<2>_f59_0 )
  );
  defparam \vga/rom_addr_char<2>_f5_9 .LOC = "CLB_R27C13.S1";
  X_MUX2 \vga/rom_addr_char<2>_f5_9  (
    .IA(\vga/N2212 ),
    .IB(\vga/N2112 ),
    .SEL(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f510 )
  );
  defparam \vga/rom_addr_char<1>201 .INIT = 16'hCFC0;
  defparam \vga/rom_addr_char<1>201 .LOC = "CLB_R27C13.S1";
  X_LUT4 \vga/rom_addr_char<1>201  (
    .ADR0(VCC),
    .ADR1(\vga/N75_0 ),
    .ADR2(\vga/rom_addr_char [1]),
    .ADR3(\vga/N113_0 ),
    .O(\vga/N2112 )
  );
  defparam \vga/rom_addr_char<1>211 .INIT = 16'hF3C0;
  defparam \vga/rom_addr_char<1>211 .LOC = "CLB_R27C13.S1";
  X_LUT4 \vga/rom_addr_char<1>211  (
    .ADR0(VCC),
    .ADR1(\vga/rom_addr_char_1_1_7 ),
    .ADR2(\vga/N99_0 ),
    .ADR3(\vga/N72_0 ),
    .O(\vga/N2212 )
  );
  defparam \vga/rom_addr_char<3>_f65/YUSED .LOC = "CLB_R27C13.S1";
  X_BUF \vga/rom_addr_char<3>_f65/YUSED  (
    .I(\vga/rom_addr_char<3>_f65 ),
    .O(\vga/rom_addr_char<3>_f65_0 )
  );
  defparam \vga/rom_addr_char<3>_f6_4 .LOC = "CLB_R27C13.S1";
  X_MUX2 \vga/rom_addr_char<3>_f6_4  (
    .IA(\vga/rom_addr_char<2>_f5111_0 ),
    .IB(\vga/rom_addr_char<2>_f510 ),
    .SEL(\vga/rom_addr_char [3]),
    .O(\vga/rom_addr_char<3>_f65 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<5>3450 .LOC = "CLB_R11C34.S1";
  X_MUX2 \vga/scancode_convert/scancode_rom/data<5>3450  (
    .IA(N3214),
    .IB(N3215),
    .SEL(\vga/scancode_convert/raise ),
    .O(\vga/scancode_convert/scancode_rom/data<5>3_map1337 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<5>3450_G .INIT = 16'h5FD5;
  defparam \vga/scancode_convert/scancode_rom/data<5>3450_G .LOC = "CLB_R11C34.S1";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<5>3450_G  (
    .ADR0(\vga/scancode_convert/sc [3]),
    .ADR1(\vga/scancode_convert/sc [4]),
    .ADR2(\vga/scancode_convert/sc_0_1_10 ),
    .ADR3(\vga/scancode_convert/sc [1]),
    .O(N3215)
  );
  defparam \vga/scancode_convert/scancode_rom/data<5>3450_F .INIT = 16'h77FF;
  defparam \vga/scancode_convert/scancode_rom/data<5>3450_F .LOC = "CLB_R11C34.S1";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<5>3450_F  (
    .ADR0(\vga/scancode_convert/sc_0_1_10 ),
    .ADR1(\vga/scancode_convert/sc [3]),
    .ADR2(VCC),
    .ADR3(\vga/scancode_convert/sc [1]),
    .O(N3214)
  );
  defparam \vga/scancode_convert/scancode_rom/data<5>3_map1337/XUSED .LOC = "CLB_R11C34.S1";
  X_BUF \vga/scancode_convert/scancode_rom/data<5>3_map1337/XUSED  (
    .I(\vga/scancode_convert/scancode_rom/data<5>3_map1337 ),
    .O(\vga/scancode_convert/scancode_rom/data<5>3_map1337_0 )
  );
  defparam \vga/charload8_SW0_SW0_f5 .LOC = "CLB_R11C5.S1";
  X_MUX2 \vga/charload8_SW0_SW0_f5  (
    .IA(\N3150/GROM ),
    .IB(N3259),
    .SEL(\vga/rom_addr_char [4]),
    .O(N3150)
  );
  defparam \vga/charload8_SW0_SW01 .INIT = 16'h7FFF;
  defparam \vga/charload8_SW0_SW01 .LOC = "CLB_R11C5.S1";
  X_LUT4 \vga/charload8_SW0_SW01  (
    .ADR0(\vga/N224_0 ),
    .ADR1(\vga/rom_addr_char [2]),
    .ADR2(\vga/rom_addr_char [3]),
    .ADR3(\vga/rom_addr_char_1_1_7 ),
    .O(N3259)
  );
  defparam \N3150/G .INIT = 16'hFFFF;
  defparam \N3150/G .LOC = "CLB_R11C5.S1";
  X_LUT4 \N3150/G  (
    .ADR0(VCC),
    .ADR1(VCC),
    .ADR2(VCC),
    .ADR3(VCC),
    .O(\N3150/GROM )
  );
  defparam \N3150/XUSED .LOC = "CLB_R11C5.S1";
  X_BUF \N3150/XUSED  (
    .I(N3150),
    .O(N3150_0)
  );
  defparam \vga/rom_addr_char<2>_f5 .LOC = "CLB_R19C3.S1";
  X_MUX2 \vga/rom_addr_char<2>_f5  (
    .IA(\vga/N1101 ),
    .IB(\vga/N01 ),
    .SEL(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f5_85 )
  );
  defparam \vga/rom_addr_char<1> .INIT = 16'hF5A0;
  defparam \vga/rom_addr_char<1> .LOC = "CLB_R19C3.S1";
  X_LUT4 \vga/rom_addr_char<1>  (
    .ADR0(\vga/rom_addr_char [1]),
    .ADR1(VCC),
    .ADR2(\vga/N15_0 ),
    .ADR3(\vga/N14 ),
    .O(\vga/N01 )
  );
  defparam \vga/rom_addr_char<1>1 .INIT = 16'hA0A0;
  defparam \vga/rom_addr_char<1>1 .LOC = "CLB_R19C3.S1";
  X_LUT4 \vga/rom_addr_char<1>1  (
    .ADR0(\vga/rom_addr_char [1]),
    .ADR1(VCC),
    .ADR2(\vga/N13_0 ),
    .ADR3(VCC),
    .O(\vga/N1101 )
  );
  defparam \vga/rom_addr_char<3>_f6/YUSED .LOC = "CLB_R19C3.S1";
  X_BUF \vga/rom_addr_char<3>_f6/YUSED  (
    .I(\vga/rom_addr_char<3>_f6_80 ),
    .O(\vga/rom_addr_char<3>_f6_0_6 )
  );
  defparam \vga/rom_addr_char<3>_f6 .LOC = "CLB_R19C3.S1";
  X_MUX2 \vga/rom_addr_char<3>_f6  (
    .IA(\vga/rom_addr_char<2>_f51_0 ),
    .IB(\vga/rom_addr_char<2>_f5_85 ),
    .SEL(\vga/rom_addr_char [3]),
    .O(\vga/rom_addr_char<3>_f6_80 )
  );
  defparam \vga/rom_addr_char<3>_f5 .LOC = "CLB_R3C5.S0";
  X_MUX2 \vga/rom_addr_char<3>_f5  (
    .IA(\vga/N1812345 ),
    .IB(\vga/N1712345 ),
    .SEL(\vga/rom_addr_char [3]),
    .O(\vga/rom_addr_char<3>_f5_86 )
  );
  defparam \vga/rom_addr_char<2>5 .INIT = 16'hCCF0;
  defparam \vga/rom_addr_char<2>5 .LOC = "CLB_R3C5.S0";
  X_LUT4 \vga/rom_addr_char<2>5  (
    .ADR0(VCC),
    .ADR1(\vga/rom_addr_char<1>_mmx_out_0 ),
    .ADR2(\vga/rom_addr_char<1>112_0 ),
    .ADR3(\vga/rom_addr_char [2]),
    .O(\vga/N1712345 )
  );
  defparam \vga/rom_addr_char<2>13 .INIT = 16'hF0AA;
  defparam \vga/rom_addr_char<2>13 .LOC = "CLB_R3C5.S0";
  X_LUT4 \vga/rom_addr_char<2>13  (
    .ADR0(\vga/rom_addr_char<1>2_0 ),
    .ADR1(VCC),
    .ADR2(\vga/rom_addr_char<1>_mmx_out_0 ),
    .ADR3(\vga/rom_addr_char [2]),
    .O(\vga/N1812345 )
  );
  defparam \vga/rom_addr_char<3>_f5/XUSED .LOC = "CLB_R3C5.S0";
  X_BUF \vga/rom_addr_char<3>_f5/XUSED  (
    .I(\vga/rom_addr_char<3>_f5_86 ),
    .O(\vga/rom_addr_char<3>_f5_0 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<0>1291_SW0 .LOC = "CLB_R16C33.S0";
  X_MUX2 \vga/scancode_convert/scancode_rom/data<0>1291_SW0  (
    .IA(N3188),
    .IB(N3189),
    .SEL(\vga/scancode_convert/sc [2]),
    .O(N3104)
  );
  defparam \vga/scancode_convert/scancode_rom/data<0>1291_SW0_G .INIT = 16'h2A0A;
  defparam \vga/scancode_convert/scancode_rom/data<0>1291_SW0_G .LOC = "CLB_R16C33.S0";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<0>1291_SW0_G  (
    .ADR0(\vga/scancode_convert/sc [5]),
    .ADR1(\vga/scancode_convert/scancode_rom/data<0>1_map1475_0 ),
    .ADR2(\vga/scancode_convert/scancode_rom/data<0>1_map1461_0 ),
    .ADR3(\vga/scancode_convert/sc [3]),
    .O(N3189)
  );
  defparam \vga/scancode_convert/scancode_rom/data<0>1291_SW0_F .INIT = 16'h80CC;
  defparam \vga/scancode_convert/scancode_rom/data<0>1291_SW0_F .LOC = "CLB_R16C33.S0";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<0>1291_SW0_F  (
    .ADR0(\vga/scancode_convert/sc [3]),
    .ADR1(\vga/scancode_convert/sc [5]),
    .ADR2(\vga/scancode_convert/scancode_rom/N7 ),
    .ADR3(\vga/scancode_convert/scancode_rom/data<0>1_map1449_0 ),
    .O(N3188)
  );
  defparam \N3104/XUSED .LOC = "CLB_R16C33.S0";
  X_BUF \N3104/XUSED  (
    .I(N3104),
    .O(N3104_0)
  );
  defparam \vga/rom_addr_char<4>_f5 .LOC = "CLB_R14C2.S0";
  X_MUX2 \vga/rom_addr_char<4>_f5  (
    .IA(\vga/N2211 ),
    .IB(\vga/N1911 ),
    .SEL(\vga/rom_addr_char [4]),
    .O(\vga/rom_addr_char<4>_f5_87 )
  );
  defparam \vga/rom_addr_char<3> .INIT = 16'hCFC0;
  defparam \vga/rom_addr_char<3> .LOC = "CLB_R14C2.S0";
  X_LUT4 \vga/rom_addr_char<3>  (
    .ADR0(VCC),
    .ADR1(\vga/rom_addr_char<2>11_0 ),
    .ADR2(\vga/rom_addr_char [3]),
    .ADR3(\vga/rom_addr_char<2>_f58_0 ),
    .O(\vga/N1911 )
  );
  defparam \vga/rom_addr_char<3>1 .INIT = 16'hCFC0;
  defparam \vga/rom_addr_char<3>1 .LOC = "CLB_R14C2.S0";
  X_LUT4 \vga/rom_addr_char<3>1  (
    .ADR0(VCC),
    .ADR1(\vga/rom_addr_char<2>2_0 ),
    .ADR2(\vga/rom_addr_char [3]),
    .ADR3(\vga/rom_addr_char<2>_f59_0 ),
    .O(\vga/N2211 )
  );
  defparam \vga/rom_addr_char<4>_f5/XUSED .LOC = "CLB_R14C2.S0";
  X_BUF \vga/rom_addr_char<4>_f5/XUSED  (
    .I(\vga/rom_addr_char<4>_f5_87 ),
    .O(\vga/rom_addr_char<4>_f5_0 )
  );
  defparam \vga/rom_addr_char<5>_f5 .LOC = "CLB_R26C12.S1";
  X_MUX2 \vga/rom_addr_char<5>_f5  (
    .IA(\vga/N251 ),
    .IB(\vga/N1612 ),
    .SEL(\vga/rom_addr_char [5]),
    .O(\vga/rom_addr_char<5>_f5_88 )
  );
  defparam \vga/rom_addr_char<4>3 .INIT = 16'hF0AA;
  defparam \vga/rom_addr_char<4>3 .LOC = "CLB_R26C12.S1";
  X_LUT4 \vga/rom_addr_char<4>3  (
    .ADR0(\vga/rom_addr_char<3>_f621_0 ),
    .ADR1(VCC),
    .ADR2(\vga/rom_addr_char<3>_f631_0 ),
    .ADR3(\vga/rom_addr_char [4]),
    .O(\vga/N1612 )
  );
  defparam \vga/rom_addr_char<4>11 .INIT = 16'hAFA0;
  defparam \vga/rom_addr_char<4>11 .LOC = "CLB_R26C12.S1";
  X_LUT4 \vga/rom_addr_char<4>11  (
    .ADR0(\vga/rom_addr_char<3>_f65_0 ),
    .ADR1(VCC),
    .ADR2(\vga/rom_addr_char [4]),
    .ADR3(\vga/rom_addr_char<3>_f64_0 ),
    .O(\vga/N251 )
  );
  defparam \vga/rom_addr_char<5>_f5/XUSED .LOC = "CLB_R26C12.S1";
  X_BUF \vga/rom_addr_char<5>_f5/XUSED  (
    .I(\vga/rom_addr_char<5>_f5_88 ),
    .O(\vga/rom_addr_char<5>_f5_0 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<2>1410_SW0_f5 .LOC = "CLB_R16C36.S1";
  X_MUX2 \vga/scancode_convert/scancode_rom/data<2>1410_SW0_f5  (
    .IA(N3255),
    .IB(N3254),
    .SEL(\vga/scancode_convert/sc [4]),
    .O(N3126)
  );
  defparam \vga/scancode_convert/scancode_rom/data<2>1410_SW01 .INIT = 16'hFFFC;
  defparam \vga/scancode_convert/scancode_rom/data<2>1410_SW01 .LOC = "CLB_R16C36.S1";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<2>1410_SW01  (
    .ADR0(VCC),
    .ADR1(\vga/scancode_convert/sc [3]),
    .ADR2(\vga/scancode_convert/sc [0]),
    .ADR3(\vga/scancode_convert/scancode_rom/N12 ),
    .O(N3254)
  );
  defparam \vga/scancode_convert/scancode_rom/data<2>1410_SW02 .INIT = 16'hFFF5;
  defparam \vga/scancode_convert/scancode_rom/data<2>1410_SW02 .LOC = "CLB_R16C36.S1";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<2>1410_SW02  (
    .ADR0(\vga/scancode_convert/sc [0]),
    .ADR1(VCC),
    .ADR2(\vga/scancode_convert/sc [3]),
    .ADR3(\vga/scancode_convert/sc [1]),
    .O(N3255)
  );
  defparam \N3126/XUSED .LOC = "CLB_R16C36.S1";
  X_BUF \N3126/XUSED  (
    .I(N3126),
    .O(N3126_0)
  );
  defparam \vga/crt/state_FFd2-In_f5 .LOC = "CLB_R15C18.S0";
  X_MUX2 \vga/crt/state_FFd2-In_f5  (
    .IA(N3227),
    .IB(N3226),
    .SEL(\vga/crt/state_FFd3_11 ),
    .O(\vga/crt/state_FFd2-In )
  );
  defparam \vga/crt/state_FFd2-In1 .INIT = 16'hFFF7;
  defparam \vga/crt/state_FFd2-In1 .LOC = "CLB_R15C18.S0";
  X_LUT4 \vga/crt/state_FFd2-In1  (
    .ADR0(\vga/crt/state_FFd2_12 ),
    .ADR1(\vga/scancode_convert/strobe_out_15 ),
    .ADR2(\vga/scancode_convert/key_up_14 ),
    .ADR3(\vga/crt/state_FFd1_13 ),
    .O(N3226)
  );
  defparam \vga/crt/state_FFd2-In2 .INIT = 16'hEC00;
  defparam \vga/crt/state_FFd2-In2 .LOC = "CLB_R15C18.S0";
  X_LUT4 \vga/crt/state_FFd2-In2  (
    .ADR0(\vga/crt/eol_0 ),
    .ADR1(\vga/crt/state_FFd1_13 ),
    .ADR2(\vga/crt/scroll_0 ),
    .ADR3(\vga/crt/state_FFd2_12 ),
    .O(N3227)
  );
  defparam \vga/ps2/bitcnt_x<2>1 .LOC = "CLB_R7C19.S0";
  X_MUX2 \vga/ps2/bitcnt_x<2>1  (
    .IA(N3206),
    .IB(N3207),
    .SEL(\vga/ps2/ps2_clk_fall_edge_0 ),
    .O(\vga/ps2/bitcnt_x [2])
  );
  defparam \vga/ps2/bitcnt_x<2>1_G .INIT = 16'h7788;
  defparam \vga/ps2/bitcnt_x<2>1_G .LOC = "CLB_R7C19.S0";
  X_LUT4 \vga/ps2/bitcnt_x<2>1_G  (
    .ADR0(\vga/ps2/bitcnt_r [0]),
    .ADR1(\vga/ps2/bitcnt_r [1]),
    .ADR2(VCC),
    .ADR3(\vga/ps2/bitcnt_r [2]),
    .O(N3207)
  );
  defparam \vga/ps2/bitcnt_x<2>1_F .INIT = 16'h1050;
  defparam \vga/ps2/bitcnt_x<2>1_F .LOC = "CLB_R7C19.S0";
  X_LUT4 \vga/ps2/bitcnt_x<2>1_F  (
    .ADR0(\vga/ps2/error_r_16 ),
    .ADR1(\vga/ps2/_cmp_eq0001 ),
    .ADR2(\vga/ps2/bitcnt_r [2]),
    .ADR3(\vga/ps2/ps2_clk_r [1]),
    .O(N3206)
  );
  defparam \vga/ps2/bitcnt_r_2 .LOC = "CLB_R7C19.S0";
  defparam \vga/ps2/bitcnt_r_2 .INIT = 1'b0;
  X_FF \vga/ps2/bitcnt_r_2  (
    .I(\vga/ps2/bitcnt_x [2]),
    .CE(VCC),
    .CLK(gray_cnt_FFd1_0),
    .SET(GND),
    .RST(\vga/ps2/bitcnt_r<2>/FFX/RST ),
    .O(\vga/ps2/bitcnt_r [2])
  );
  defparam \vga/ps2/bitcnt_r<2>/FFX/RSTOR .LOC = "CLB_R7C19.S0";
  X_INV \vga/ps2/bitcnt_r<2>/FFX/RSTOR  (
    .I(reset_n_IBUF_0),
    .O(\vga/ps2/bitcnt_r<2>/FFX/RST )
  );
  defparam \vga/ps2/bitcnt_x<0>1_f5 .LOC = "CLB_R7C18.S0";
  X_MUX2 \vga/ps2/bitcnt_x<0>1_f5  (
    .IA(N3225),
    .IB(N3224),
    .SEL(\vga/ps2/_cmp_eq0001 ),
    .O(\vga/ps2/bitcnt_x [0])
  );
  defparam \vga/ps2/bitcnt_x<0>11 .INIT = 16'h3304;
  defparam \vga/ps2/bitcnt_x<0>11 .LOC = "CLB_R7C18.S0";
  X_LUT4 \vga/ps2/bitcnt_x<0>11  (
    .ADR0(\vga/ps2/ps2_clk_r [1]),
    .ADR1(\vga/ps2/bitcnt_r [0]),
    .ADR2(\vga/ps2/error_r_16 ),
    .ADR3(\vga/ps2/ps2_clk_fall_edge_0 ),
    .O(N3224)
  );
  defparam \vga/ps2/bitcnt_x<0>12 .INIT = 16'h303C;
  defparam \vga/ps2/bitcnt_x<0>12 .LOC = "CLB_R7C18.S0";
  X_LUT4 \vga/ps2/bitcnt_x<0>12  (
    .ADR0(VCC),
    .ADR1(\vga/ps2/bitcnt_r [0]),
    .ADR2(\vga/ps2/ps2_clk_fall_edge_0 ),
    .ADR3(\vga/ps2/error_r_16 ),
    .O(N3225)
  );
  defparam \vga/ps2/bitcnt_r_0 .LOC = "CLB_R7C18.S0";
  defparam \vga/ps2/bitcnt_r_0 .INIT = 1'b0;
  X_FF \vga/ps2/bitcnt_r_0  (
    .I(\vga/ps2/bitcnt_x [0]),
    .CE(VCC),
    .CLK(gray_cnt_FFd1_0),
    .SET(GND),
    .RST(\vga/ps2/bitcnt_r<0>/FFX/RST ),
    .O(\vga/ps2/bitcnt_r [0])
  );
  defparam \vga/ps2/bitcnt_r<0>/FFX/RSTOR .LOC = "CLB_R7C18.S0";
  X_INV \vga/ps2/bitcnt_r<0>/FFX/RSTOR  (
    .I(reset_n_IBUF_0),
    .O(\vga/ps2/bitcnt_r<0>/FFX/RST )
  );
  defparam \vga/ps2/bitcnt_x<1>1_f5 .LOC = "CLB_R7C18.S1";
  X_MUX2 \vga/ps2/bitcnt_x<1>1_f5  (
    .IA(N3231),
    .IB(N3230),
    .SEL(\vga/ps2/ps2_clk_fall_edge_0 ),
    .O(\vga/ps2/bitcnt_x [1])
  );
  defparam \vga/ps2/bitcnt_x<1>11 .INIT = 16'h0FF0;
  defparam \vga/ps2/bitcnt_x<1>11 .LOC = "CLB_R7C18.S1";
  X_LUT4 \vga/ps2/bitcnt_x<1>11  (
    .ADR0(VCC),
    .ADR1(VCC),
    .ADR2(\vga/ps2/bitcnt_r [0]),
    .ADR3(\vga/ps2/bitcnt_r [1]),
    .O(N3230)
  );
  defparam \vga/ps2/bitcnt_x<1>12 .INIT = 16'h004C;
  defparam \vga/ps2/bitcnt_x<1>12 .LOC = "CLB_R7C18.S1";
  X_LUT4 \vga/ps2/bitcnt_x<1>12  (
    .ADR0(\vga/ps2/_cmp_eq0001 ),
    .ADR1(\vga/ps2/bitcnt_r [1]),
    .ADR2(\vga/ps2/ps2_clk_r [1]),
    .ADR3(\vga/ps2/error_r_16 ),
    .O(N3231)
  );
  defparam \vga/ps2/bitcnt_r_1 .LOC = "CLB_R7C18.S1";
  defparam \vga/ps2/bitcnt_r_1 .INIT = 1'b0;
  X_FF \vga/ps2/bitcnt_r_1  (
    .I(\vga/ps2/bitcnt_x [1]),
    .CE(VCC),
    .CLK(gray_cnt_FFd1_0),
    .SET(GND),
    .RST(\vga/ps2/bitcnt_r<1>/FFX/RST ),
    .O(\vga/ps2/bitcnt_r [1])
  );
  defparam \vga/ps2/bitcnt_r<1>/FFX/RSTOR .LOC = "CLB_R7C18.S1";
  X_INV \vga/ps2/bitcnt_r<1>/FFX/RSTOR  (
    .I(reset_n_IBUF_0),
    .O(\vga/ps2/bitcnt_r<1>/FFX/RST )
  );
  defparam \vga/scancode_convert/scancode_rom/data<2>111_f5 .LOC = "CLB_R16C37.S0";
  X_MUX2 \vga/scancode_convert/scancode_rom/data<2>111_f5  (
    .IA(N3243),
    .IB(N3242),
    .SEL(\vga/scancode_convert/sc [4]),
    .O(\vga/scancode_convert/scancode_rom/data<2>1_map1056 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<2>1111 .INIT = 16'h0800;
  defparam \vga/scancode_convert/scancode_rom/data<2>1111 .LOC = "CLB_R16C37.S0";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<2>1111  (
    .ADR0(\vga/scancode_convert/sc [3]),
    .ADR1(\vga/scancode_convert/sc [2]),
    .ADR2(\vga/scancode_convert/sc [1]),
    .ADR3(\vga/scancode_convert/sc [0]),
    .O(N3242)
  );
  defparam \vga/scancode_convert/scancode_rom/data<2>1112 .INIT = 16'hAA00;
  defparam \vga/scancode_convert/scancode_rom/data<2>1112 .LOC = "CLB_R16C37.S0";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<2>1112  (
    .ADR0(\vga/scancode_convert/sc [3]),
    .ADR1(VCC),
    .ADR2(VCC),
    .ADR3(\vga/scancode_convert/sc [2]),
    .O(N3243)
  );
  defparam \vga/scancode_convert/scancode_rom/data<2>1_map1056/XUSED .LOC = "CLB_R16C37.S0";
  X_BUF \vga/scancode_convert/scancode_rom/data<2>1_map1056/XUSED  (
    .I(\vga/scancode_convert/scancode_rom/data<2>1_map1056 ),
    .O(\vga/scancode_convert/scancode_rom/data<2>1_map1056_0 )
  );
  defparam \vga/rom_addr_char<1>_mmx_out1_f5 .LOC = "CLB_R2C5.S0";
  X_MUX2 \vga/rom_addr_char<1>_mmx_out1_f5  (
    .IA(N3262),
    .IB(N3261),
    .SEL(\vga/vgacore/vcnt_2_1_9 ),
    .O(\vga/rom_addr_char<1>_mmx_out )
  );
  defparam \vga/rom_addr_char<1>_mmx_out11 .INIT = 16'h373F;
  defparam \vga/rom_addr_char<1>_mmx_out11 .LOC = "CLB_R2C5.S0";
  X_LUT4 \vga/rom_addr_char<1>_mmx_out11  (
    .ADR0(\vga/rom_addr_char_0_1_18 ),
    .ADR1(\vga/vgacore/vcnt_1_1_8 ),
    .ADR2(\vga/vgacore/vcnt_0_1_17 ),
    .ADR3(\vga/rom_addr_char_1_1_7 ),
    .O(N3261)
  );
  defparam \vga/rom_addr_char<1>_mmx_out12 .INIT = 16'hFDFF;
  defparam \vga/rom_addr_char<1>_mmx_out12 .LOC = "CLB_R2C5.S0";
  X_LUT4 \vga/rom_addr_char<1>_mmx_out12  (
    .ADR0(\vga/rom_addr_char_1_1_7 ),
    .ADR1(\vga/vgacore/vcnt_0_1_17 ),
    .ADR2(\vga/vgacore/vcnt_1_1_8 ),
    .ADR3(\vga/rom_addr_char_0_1_18 ),
    .O(N3262)
  );
  defparam \vga/rom_addr_char<1>_mmx_out/XUSED .LOC = "CLB_R2C5.S0";
  X_BUF \vga/rom_addr_char<1>_mmx_out/XUSED  (
    .I(\vga/rom_addr_char<1>_mmx_out ),
    .O(\vga/rom_addr_char<1>_mmx_out_0 )
  );
  defparam \vga/charload237_f5 .LOC = "CLB_R13C8.S0";
  X_MUX2 \vga/charload237_f5  (
    .IA(N3229),
    .IB(N3228),
    .SEL(\vga/rom_addr_char [6]),
    .O(\vga/_mux0002 [7])
  );
  defparam \vga/charload2371 .INIT = 16'hF000;
  defparam \vga/charload2371 .LOC = "CLB_R13C8.S0";
  X_LUT4 \vga/charload2371  (
    .ADR0(VCC),
    .ADR1(VCC),
    .ADR2(\vga/charload_19 ),
    .ADR3(\vga/cursor_match_0 ),
    .O(N3228)
  );
  defparam \vga/charload2372 .INIT = 16'hF800;
  defparam \vga/charload2372 .LOC = "CLB_R13C8.S0";
  X_LUT4 \vga/charload2372  (
    .ADR0(\vga/rom_addr_char [5]),
    .ADR1(\vga/charload2_map865_0 ),
    .ADR2(\vga/cursor_match_0 ),
    .ADR3(\vga/charload_19 ),
    .O(N3229)
  );
  defparam \vga/rom_addr_char<2>_f51 .LOC = "CLB_R20C3.S1";
  X_MUX2 \vga/rom_addr_char<2>_f51  (
    .IA(\vga/N111234 ),
    .IB(\vga/N01123 ),
    .SEL(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f512 )
  );
  defparam \vga/rom_addr_char<1>20 .INIT = 16'hF5A0;
  defparam \vga/rom_addr_char<1>20 .LOC = "CLB_R20C3.S1";
  X_LUT4 \vga/rom_addr_char<1>20  (
    .ADR0(\vga/rom_addr_char [1]),
    .ADR1(VCC),
    .ADR2(\vga/N143_0 ),
    .ADR3(\vga/N142_0 ),
    .O(\vga/N01123 )
  );
  defparam \vga/rom_addr_char<1>110 .INIT = 16'hCCF0;
  defparam \vga/rom_addr_char<1>110 .LOC = "CLB_R20C3.S1";
  X_LUT4 \vga/rom_addr_char<1>110  (
    .ADR0(VCC),
    .ADR1(\vga/N13_0 ),
    .ADR2(\vga/N25_0 ),
    .ADR3(\vga/rom_addr_char [1]),
    .O(\vga/N111234 )
  );
  defparam \vga/rom_addr_char<3>_f612/YUSED .LOC = "CLB_R20C3.S1";
  X_BUF \vga/rom_addr_char<3>_f612/YUSED  (
    .I(\vga/rom_addr_char<3>_f612 ),
    .O(\vga/rom_addr_char<3>_f612_0 )
  );
  defparam \vga/rom_addr_char<3>_f61 .LOC = "CLB_R20C3.S1";
  X_MUX2 \vga/rom_addr_char<3>_f61  (
    .IA(\vga/rom_addr_char<2>_f511_0 ),
    .IB(\vga/rom_addr_char<2>_f512 ),
    .SEL(\vga/rom_addr_char [3]),
    .O(\vga/rom_addr_char<3>_f612 )
  );
  defparam \vga/vgacore/vblank2_f5 .LOC = "CLB_R16C9.S0";
  X_MUX2 \vga/vgacore/vblank2_f5  (
    .IA(N3244),
    .IB(\vga/vgacore/N51/FROM ),
    .SEL(\vga/vgacore/vcnt [8]),
    .O(\vga/vgacore/N51 )
  );
  defparam \vga/vgacore/N51/F .INIT = 16'h0000;
  defparam \vga/vgacore/N51/F .LOC = "CLB_R16C9.S0";
  X_LUT4 \vga/vgacore/N51/F  (
    .ADR0(VCC),
    .ADR1(VCC),
    .ADR2(VCC),
    .ADR3(VCC),
    .O(\vga/vgacore/N51/FROM )
  );
  defparam \vga/vgacore/vblank21 .INIT = 16'h0001;
  defparam \vga/vgacore/vblank21 .LOC = "CLB_R16C9.S0";
  X_LUT4 \vga/vgacore/vblank21  (
    .ADR0(\vga/vgacore/vcnt [5]),
    .ADR1(\vga/vgacore/vcnt [7]),
    .ADR2(\vga/vgacore/vcnt [6]),
    .ADR3(\vga/vgacore/vcnt [4]),
    .O(N3244)
  );
  defparam \vga/vgacore/N51/XUSED .LOC = "CLB_R16C9.S0";
  X_BUF \vga/vgacore/N51/XUSED  (
    .I(\vga/vgacore/N51 ),
    .O(\vga/vgacore/N51_0 )
  );
  defparam \vga/rom_addr_char<2>_f52 .LOC = "CLB_R24C6.S1";
  X_MUX2 \vga/rom_addr_char<2>_f52  (
    .IA(\vga/N1112345 ),
    .IB(\vga/N011234 ),
    .SEL(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f5123 )
  );
  defparam \vga/rom_addr_char<1>24 .INIT = 16'hFC30;
  defparam \vga/rom_addr_char<1>24 .LOC = "CLB_R24C6.S1";
  X_LUT4 \vga/rom_addr_char<1>24  (
    .ADR0(VCC),
    .ADR1(\vga/rom_addr_char_1_1_7 ),
    .ADR2(\vga/N14 ),
    .ADR3(\vga/N53_0 ),
    .O(\vga/N011234 )
  );
  defparam \vga/rom_addr_char<1>112 .INIT = 16'hF000;
  defparam \vga/rom_addr_char<1>112 .LOC = "CLB_R24C6.S1";
  X_LUT4 \vga/rom_addr_char<1>112  (
    .ADR0(VCC),
    .ADR1(VCC),
    .ADR2(\vga/N40_0 ),
    .ADR3(\vga/rom_addr_char [1]),
    .O(\vga/N1112345 )
  );
  defparam \vga/rom_addr_char<3>_f6123/YUSED .LOC = "CLB_R24C6.S1";
  X_BUF \vga/rom_addr_char<3>_f6123/YUSED  (
    .I(\vga/rom_addr_char<3>_f6123 ),
    .O(\vga/rom_addr_char<3>_f6123_0 )
  );
  defparam \vga/rom_addr_char<3>_f62 .LOC = "CLB_R24C6.S1";
  X_MUX2 \vga/rom_addr_char<3>_f62  (
    .IA(\vga/rom_addr_char<2>_f5112_0 ),
    .IB(\vga/rom_addr_char<2>_f5123 ),
    .SEL(\vga/rom_addr_char [3]),
    .O(\vga/rom_addr_char<3>_f6123 )
  );
  defparam \vga/rom_addr_char<2>_f53 .LOC = "CLB_R9C1.S0";
  X_MUX2 \vga/rom_addr_char<2>_f53  (
    .IA(\vga/N11123456 ),
    .IB(\vga/N0112345 ),
    .SEL(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f51234 )
  );
  defparam \vga/rom_addr_char<1>26 .INIT = 16'hEE22;
  defparam \vga/rom_addr_char<1>26 .LOC = "CLB_R9C1.S0";
  X_LUT4 \vga/rom_addr_char<1>26  (
    .ADR0(\vga/N94_0 ),
    .ADR1(\vga/rom_addr_char_1_1_7 ),
    .ADR2(VCC),
    .ADR3(\vga/N95_0 ),
    .O(\vga/N0112345 )
  );
  defparam \vga/rom_addr_char<1>114 .INIT = 16'h0C0C;
  defparam \vga/rom_addr_char<1>114 .LOC = "CLB_R9C1.S0";
  X_LUT4 \vga/rom_addr_char<1>114  (
    .ADR0(VCC),
    .ADR1(\vga/rom_addr_char_0_1_18 ),
    .ADR2(N3166_0),
    .ADR3(VCC),
    .O(\vga/N11123456 )
  );
  defparam \vga/rom_addr_char<2>_f51234/XUSED .LOC = "CLB_R9C1.S0";
  X_BUF \vga/rom_addr_char<2>_f51234/XUSED  (
    .I(\vga/rom_addr_char<2>_f51234 ),
    .O(\vga/rom_addr_char<2>_f51234_0 )
  );
  defparam \vga/rom_addr_char<2>_f54 .LOC = "CLB_R23C5.S1";
  X_MUX2 \vga/rom_addr_char<2>_f54  (
    .IA(\vga/N111234567 ),
    .IB(\vga/N01123456 ),
    .SEL(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f512345 )
  );
  defparam \vga/rom_addr_char<1>28 .INIT = 16'hF0CC;
  defparam \vga/rom_addr_char<1>28 .LOC = "CLB_R23C5.S1";
  X_LUT4 \vga/rom_addr_char<1>28  (
    .ADR0(VCC),
    .ADR1(\vga/N14 ),
    .ADR2(\vga/N2_0 ),
    .ADR3(\vga/rom_addr_char_1_1_7 ),
    .O(\vga/N01123456 )
  );
  defparam \vga/rom_addr_char<1>116 .INIT = 16'hA0A0;
  defparam \vga/rom_addr_char<1>116 .LOC = "CLB_R23C5.S1";
  X_LUT4 \vga/rom_addr_char<1>116  (
    .ADR0(\vga/rom_addr_char [1]),
    .ADR1(VCC),
    .ADR2(\vga/N186_0 ),
    .ADR3(VCC),
    .O(\vga/N111234567 )
  );
  defparam \vga/rom_addr_char<3>_f612345/YUSED .LOC = "CLB_R23C5.S1";
  X_BUF \vga/rom_addr_char<3>_f612345/YUSED  (
    .I(\vga/rom_addr_char<3>_f612345 ),
    .O(\vga/rom_addr_char<3>_f612345_0 )
  );
  defparam \vga/rom_addr_char<3>_f64 .LOC = "CLB_R23C5.S1";
  X_MUX2 \vga/rom_addr_char<3>_f64  (
    .IA(\vga/rom_addr_char<2>_f511234_0 ),
    .IB(\vga/rom_addr_char<2>_f512345 ),
    .SEL(\vga/rom_addr_char [3]),
    .O(\vga/rom_addr_char<3>_f612345 )
  );
  defparam \vga/charload354_f5 .LOC = "CLB_R13C7.S0";
  X_MUX2 \vga/charload354_f5  (
    .IA(\vga/pixel_hold<0>_rt_89 ),
    .IB(N3233),
    .SEL(\vga/charload_19 ),
    .O(\vga/_mux0002 [6])
  );
  defparam \vga/charload3541 .INIT = 16'hFF08;
  defparam \vga/charload3541 .LOC = "CLB_R13C7.S0";
  X_LUT4 \vga/charload3541  (
    .ADR0(\vga/rom_addr_char [5]),
    .ADR1(\vga/charload3_map953_0 ),
    .ADR2(\vga/rom_addr_char [6]),
    .ADR3(\vga/cursor_match_0 ),
    .O(N3233)
  );
  defparam \vga/pixel_hold<0>_rt .INIT = 16'hF0F0;
  defparam \vga/pixel_hold<0>_rt .LOC = "CLB_R13C7.S0";
  X_LUT4 \vga/pixel_hold<0>_rt  (
    .ADR0(VCC),
    .ADR1(VCC),
    .ADR2(\vga/pixel_hold [0]),
    .ADR3(VCC),
    .O(\vga/pixel_hold<0>_rt_89 )
  );
  defparam \vga/rom_addr_char<2>_f5_101 .LOC = "CLB_R27C12.S0";
  X_MUX2 \vga/rom_addr_char<2>_f5_101  (
    .IA(\vga/N2412 ),
    .IB(\vga/N231 ),
    .SEL(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f51112 )
  );
  defparam \vga/rom_addr_char<1>22 .INIT = 16'hF5A0;
  defparam \vga/rom_addr_char<1>22 .LOC = "CLB_R27C12.S0";
  X_LUT4 \vga/rom_addr_char<1>22  (
    .ADR0(\vga/rom_addr_char_1_1_7 ),
    .ADR1(VCC),
    .ADR2(\vga/N71_0 ),
    .ADR3(\vga/N70_0 ),
    .O(\vga/N231 )
  );
  defparam \vga/rom_addr_char<1>231 .INIT = 16'hEE44;
  defparam \vga/rom_addr_char<1>231 .LOC = "CLB_R27C12.S0";
  X_LUT4 \vga/rom_addr_char<1>231  (
    .ADR0(\vga/rom_addr_char_1_1_7 ),
    .ADR1(\vga/N68_0 ),
    .ADR2(VCC),
    .ADR3(\vga/N69_0 ),
    .O(\vga/N2412 )
  );
  defparam \vga/rom_addr_char<2>_f51112/F5USED .LOC = "CLB_R27C12.S0";
  X_BUF \vga/rom_addr_char<2>_f51112/F5USED  (
    .I(\vga/rom_addr_char<2>_f51112 ),
    .O(\vga/rom_addr_char<2>_f51112_0 )
  );
  defparam \vga/charload458_f5 .LOC = "CLB_R13C9.S0";
  X_MUX2 \vga/charload458_f5  (
    .IA(N3237),
    .IB(N3236),
    .SEL(\vga/rom_addr_char [6]),
    .O(\vga/_mux0002 [2])
  );
  defparam \vga/charload4581 .INIT = 16'hFCAA;
  defparam \vga/charload4581 .LOC = "CLB_R13C9.S0";
  X_LUT4 \vga/charload4581  (
    .ADR0(\vga/pixel_hold [4]),
    .ADR1(\vga/rom_addr_char<5>_f5_0 ),
    .ADR2(\vga/cursor_match_0 ),
    .ADR3(\vga/charload_19 ),
    .O(N3236)
  );
  defparam \vga/charload4582 .INIT = 16'hFCB8;
  defparam \vga/charload4582 .LOC = "CLB_R13C9.S0";
  X_LUT4 \vga/charload4582  (
    .ADR0(\vga/cursor_match_0 ),
    .ADR1(\vga/charload_19 ),
    .ADR2(\vga/pixel_hold [4]),
    .ADR3(\vga/charload4_map979_0 ),
    .O(N3237)
  );
  defparam \vga/scancode_convert/scancode_rom/data<1>2319_f5 .LOC = "CLB_R17C36.S0";
  X_MUX2 \vga/scancode_convert/scancode_rom/data<1>2319_f5  (
    .IA(N3250),
    .IB(N3249),
    .SEL(\vga/scancode_convert/sc [4]),
    .O(\vga/scancode_convert/scancode_rom/data<1>2_map1751 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<1>23191 .INIT = 16'hAAAE;
  defparam \vga/scancode_convert/scancode_rom/data<1>23191 .LOC = "CLB_R17C36.S0";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<1>23191  (
    .ADR0(\vga/scancode_convert/sc [2]),
    .ADR1(\vga/scancode_convert/sc [1]),
    .ADR2(\vga/scancode_convert/sc [3]),
    .ADR3(\vga/scancode_convert/sc [0]),
    .O(N3249)
  );
  defparam \vga/scancode_convert/scancode_rom/data<1>23192 .INIT = 16'hCEFC;
  defparam \vga/scancode_convert/scancode_rom/data<1>23192 .LOC = "CLB_R17C36.S0";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<1>23192  (
    .ADR0(\vga/scancode_convert/sc [3]),
    .ADR1(\vga/scancode_convert/sc [2]),
    .ADR2(\vga/scancode_convert/sc [1]),
    .ADR3(\vga/scancode_convert/sc [0]),
    .O(N3250)
  );
  defparam \vga/scancode_convert/scancode_rom/data<1>2_map1751/XUSED .LOC = "CLB_R17C36.S0";
  X_BUF \vga/scancode_convert/scancode_rom/data<1>2_map1751/XUSED  (
    .I(\vga/scancode_convert/scancode_rom/data<1>2_map1751 ),
    .O(\vga/scancode_convert/scancode_rom/data<1>2_map1751_0 )
  );
  defparam \vga/rom_addr_char<5>_f51 .LOC = "CLB_R25C10.S1";
  X_MUX2 \vga/rom_addr_char<5>_f51  (
    .IA(\vga/N2512 ),
    .IB(\vga/N16123 ),
    .SEL(\vga/rom_addr_char [5]),
    .O(\vga/rom_addr_char<5>_f51_90 )
  );
  defparam \vga/rom_addr_char<4>4 .INIT = 16'hF0CC;
  defparam \vga/rom_addr_char<4>4 .LOC = "CLB_R25C10.S1";
  X_LUT4 \vga/rom_addr_char<4>4  (
    .ADR0(VCC),
    .ADR1(\vga/rom_addr_char<3>_f6212_0 ),
    .ADR2(\vga/rom_addr_char<3>_f6312_0 ),
    .ADR3(\vga/rom_addr_char [4]),
    .O(\vga/N16123 )
  );
  defparam \vga/rom_addr_char<4>12 .INIT = 16'hAACC;
  defparam \vga/rom_addr_char<4>12 .LOC = "CLB_R25C10.S1";
  X_LUT4 \vga/rom_addr_char<4>12  (
    .ADR0(\vga/rom_addr_char<3>_f651_0 ),
    .ADR1(\vga/rom_addr_char<3>_f641_0 ),
    .ADR2(VCC),
    .ADR3(\vga/rom_addr_char [4]),
    .O(\vga/N2512 )
  );
  defparam \vga/rom_addr_char<5>_f51/XUSED .LOC = "CLB_R25C10.S1";
  X_BUF \vga/rom_addr_char<5>_f51/XUSED  (
    .I(\vga/rom_addr_char<5>_f51_90 ),
    .O(\vga/rom_addr_char<5>_f51_0 )
  );
  defparam \vga/rom_addr_char<5>_f52 .LOC = "CLB_R26C9.S0";
  X_MUX2 \vga/rom_addr_char<5>_f52  (
    .IA(\vga/N23123 ),
    .IB(\vga/N141234 ),
    .SEL(\vga/rom_addr_char [5]),
    .O(\vga/rom_addr_char<5>_f512 )
  );
  defparam \vga/rom_addr_char<4>5 .INIT = 16'hCACA;
  defparam \vga/rom_addr_char<4>5 .LOC = "CLB_R26C9.S0";
  X_LUT4 \vga/rom_addr_char<4>5  (
    .ADR0(\vga/rom_addr_char<3>_f61123_0 ),
    .ADR1(\vga/rom_addr_char<3>_f62123_0 ),
    .ADR2(\vga/rom_addr_char [4]),
    .ADR3(VCC),
    .O(\vga/N141234 )
  );
  defparam \vga/rom_addr_char<4>13 .INIT = 16'hFC0C;
  defparam \vga/rom_addr_char<4>13 .LOC = "CLB_R26C9.S0";
  X_LUT4 \vga/rom_addr_char<4>13  (
    .ADR0(VCC),
    .ADR1(\vga/rom_addr_char<3>_f63123_0 ),
    .ADR2(\vga/rom_addr_char [4]),
    .ADR3(\vga/rom_addr_char<3>_f6412_0 ),
    .O(\vga/N23123 )
  );
  defparam \vga/rom_addr_char<5>_f512/XUSED .LOC = "CLB_R26C9.S0";
  X_BUF \vga/rom_addr_char<5>_f512/XUSED  (
    .I(\vga/rom_addr_char<5>_f512 ),
    .O(\vga/rom_addr_char<5>_f512_0 )
  );
  defparam \vga/rom_addr_char<5>_f53 .LOC = "CLB_R8C3.S1";
  X_MUX2 \vga/rom_addr_char<5>_f53  (
    .IA(\vga/N231234 ),
    .IB(\vga/N1612345 ),
    .SEL(\vga/rom_addr_char [5]),
    .O(\vga/rom_addr_char<5>_f5123 )
  );
  defparam \vga/rom_addr_char<4>6 .INIT = 16'hDD88;
  defparam \vga/rom_addr_char<4>6 .LOC = "CLB_R8C3.S1";
  X_LUT4 \vga/rom_addr_char<4>6  (
    .ADR0(\vga/rom_addr_char [4]),
    .ADR1(\vga/rom_addr_char<3>_f631234_0 ),
    .ADR2(VCC),
    .ADR3(\vga/rom_addr_char<3>_f621234_0 ),
    .O(\vga/N1612345 )
  );
  defparam \vga/rom_addr_char<4>14 .INIT = 16'hE4E4;
  defparam \vga/rom_addr_char<4>14 .LOC = "CLB_R8C3.S1";
  X_LUT4 \vga/rom_addr_char<4>14  (
    .ADR0(\vga/rom_addr_char [4]),
    .ADR1(\vga/rom_addr_char<3>_f5_0 ),
    .ADR2(\vga/rom_addr_char<3>_f64123_0 ),
    .ADR3(VCC),
    .O(\vga/N231234 )
  );
  defparam \vga/rom_addr_char<5>_f5123/XUSED .LOC = "CLB_R8C3.S1";
  X_BUF \vga/rom_addr_char<5>_f5123/XUSED  (
    .I(\vga/rom_addr_char<5>_f5123 ),
    .O(\vga/rom_addr_char<5>_f5123_0 )
  );
  defparam \vga/charload558_f5 .LOC = "CLB_R13C8.S1";
  X_MUX2 \vga/charload558_f5  (
    .IA(N3235),
    .IB(N3234),
    .SEL(\vga/rom_addr_char [6]),
    .O(\vga/_mux0002 [4])
  );
  defparam \vga/charload5581 .INIT = 16'hFBC8;
  defparam \vga/charload5581 .LOC = "CLB_R13C8.S1";
  X_LUT4 \vga/charload5581  (
    .ADR0(\vga/rom_addr_char<5>_f51_0 ),
    .ADR1(\vga/charload_19 ),
    .ADR2(\vga/cursor_match_0 ),
    .ADR3(\vga/pixel_hold [2]),
    .O(N3234)
  );
  defparam \vga/charload5582 .INIT = 16'hFCB8;
  defparam \vga/charload5582 .LOC = "CLB_R13C8.S1";
  X_LUT4 \vga/charload5582  (
    .ADR0(\vga/cursor_match_0 ),
    .ADR1(\vga/charload_19 ),
    .ADR2(\vga/pixel_hold [2]),
    .ADR3(\vga/charload5_map965_0 ),
    .O(N3235)
  );
  defparam \vga/ps2/bitcnt_x<3> .LOC = "CLB_R7C19.S1";
  X_MUX2 \vga/ps2/bitcnt_x<3>  (
    .IA(N3204),
    .IB(N3205),
    .SEL(\vga/ps2/ps2_clk_fall_edge_0 ),
    .O(\vga/ps2/bitcnt_x [3])
  );
  defparam \vga/ps2/bitcnt_x<3>_G .INIT = 16'h6CCC;
  defparam \vga/ps2/bitcnt_x<3>_G .LOC = "CLB_R7C19.S1";
  X_LUT4 \vga/ps2/bitcnt_x<3>_G  (
    .ADR0(\vga/ps2/bitcnt_r [2]),
    .ADR1(\vga/ps2/bitcnt_r [3]),
    .ADR2(\vga/ps2/bitcnt_r [1]),
    .ADR3(\vga/ps2/bitcnt_r [0]),
    .O(N3205)
  );
  defparam \vga/ps2/bitcnt_x<3>_F .INIT = 16'h020A;
  defparam \vga/ps2/bitcnt_x<3>_F .LOC = "CLB_R7C19.S1";
  X_LUT4 \vga/ps2/bitcnt_x<3>_F  (
    .ADR0(\vga/ps2/bitcnt_r [3]),
    .ADR1(\vga/ps2/ps2_clk_r [1]),
    .ADR2(\vga/ps2/error_r_16 ),
    .ADR3(\vga/ps2/_cmp_eq0001 ),
    .O(N3204)
  );
  defparam \vga/ps2/bitcnt_r_3 .LOC = "CLB_R7C19.S1";
  defparam \vga/ps2/bitcnt_r_3 .INIT = 1'b0;
  X_FF \vga/ps2/bitcnt_r_3  (
    .I(\vga/ps2/bitcnt_x [3]),
    .CE(VCC),
    .CLK(gray_cnt_FFd1_0),
    .SET(GND),
    .RST(\vga/ps2/bitcnt_r<3>/FFX/RST ),
    .O(\vga/ps2/bitcnt_r [3])
  );
  defparam \vga/ps2/bitcnt_r<3>/FFX/RSTOR .LOC = "CLB_R7C19.S1";
  X_INV \vga/ps2/bitcnt_r<3>/FFX/RSTOR  (
    .I(reset_n_IBUF_0),
    .O(\vga/ps2/bitcnt_r<3>/FFX/RST )
  );
  defparam \vga/charload758_f5 .LOC = "CLB_R12C6.S0";
  X_MUX2 \vga/charload758_f5  (
    .IA(N3239),
    .IB(N3238),
    .SEL(\vga/rom_addr_char [6]),
    .O(\vga/_mux0002 [1])
  );
  defparam \vga/charload7581 .INIT = 16'hFCAA;
  defparam \vga/charload7581 .LOC = "CLB_R12C6.S0";
  X_LUT4 \vga/charload7581  (
    .ADR0(\vga/pixel_hold [5]),
    .ADR1(\vga/cursor_match_0 ),
    .ADR2(\vga/rom_addr_char<5>_f5123_0 ),
    .ADR3(\vga/charload_19 ),
    .O(N3238)
  );
  defparam \vga/charload7582 .INIT = 16'hEEF0;
  defparam \vga/charload7582 .LOC = "CLB_R12C6.S0";
  X_LUT4 \vga/charload7582  (
    .ADR0(\vga/charload7_map993_0 ),
    .ADR1(\vga/cursor_match_0 ),
    .ADR2(\vga/pixel_hold [5]),
    .ADR3(\vga/charload_19 ),
    .O(N3239)
  );
  defparam \vga/scancode_convert/scancode_rom/data<3>172_f5 .LOC = "CLB_R18C35.S0";
  X_MUX2 \vga/scancode_convert/scancode_rom/data<3>172_f5  (
    .IA(N3257),
    .IB(N3256),
    .SEL(\vga/scancode_convert/sc [4]),
    .O(\vga/scancode_convert/scancode_rom/data<3>1_map1171 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<3>1721 .INIT = 16'hFCFA;
  defparam \vga/scancode_convert/scancode_rom/data<3>1721 .LOC = "CLB_R18C35.S0";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<3>1721  (
    .ADR0(\vga/scancode_convert/sc [0]),
    .ADR1(\vga/scancode_convert/sc [1]),
    .ADR2(\vga/scancode_convert/sc [2]),
    .ADR3(\vga/scancode_convert/sc [3]),
    .O(N3256)
  );
  defparam \vga/scancode_convert/scancode_rom/data<3>1722 .INIT = 16'hF0F4;
  defparam \vga/scancode_convert/scancode_rom/data<3>1722 .LOC = "CLB_R18C35.S0";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<3>1722  (
    .ADR0(\vga/scancode_convert/sc [0]),
    .ADR1(\vga/scancode_convert/sc [1]),
    .ADR2(\vga/scancode_convert/sc [2]),
    .ADR3(\vga/scancode_convert/sc [3]),
    .O(N3257)
  );
  defparam \vga/scancode_convert/scancode_rom/data<3>1_map1171/XUSED .LOC = "CLB_R18C35.S0";
  X_BUF \vga/scancode_convert/scancode_rom/data<3>1_map1171/XUSED  (
    .I(\vga/scancode_convert/scancode_rom/data<3>1_map1171 ),
    .O(\vga/scancode_convert/scancode_rom/data<3>1_map1171_0 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<4>122_f5 .LOC = "CLB_R12C35.S1";
  X_MUX2 \vga/scancode_convert/scancode_rom/data<4>122_f5  (
    .IA(\vga/scancode_convert/sc<3>_rt_91 ),
    .IB(N3248),
    .SEL(\vga/scancode_convert/sc [4]),
    .O(\vga/scancode_convert/scancode_rom/data<4>1_map1548 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<4>1221 .INIT = 16'hCDEF;
  defparam \vga/scancode_convert/scancode_rom/data<4>1221 .LOC = "CLB_R12C35.S1";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<4>1221  (
    .ADR0(\vga/scancode_convert/sc [0]),
    .ADR1(\vga/scancode_convert/sc [3]),
    .ADR2(\vga/scancode_convert/scancode_rom/N12 ),
    .ADR3(\vga/scancode_convert/sc [1]),
    .O(N3248)
  );
  defparam \vga/scancode_convert/sc<3>_rt .INIT = 16'hFF00;
  defparam \vga/scancode_convert/sc<3>_rt .LOC = "CLB_R12C35.S1";
  X_LUT4 \vga/scancode_convert/sc<3>_rt  (
    .ADR0(VCC),
    .ADR1(VCC),
    .ADR2(VCC),
    .ADR3(\vga/scancode_convert/sc [3]),
    .O(\vga/scancode_convert/sc<3>_rt_91 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<4>1_map1548/XUSED .LOC = "CLB_R12C35.S1";
  X_BUF \vga/scancode_convert/scancode_rom/data<4>1_map1548/XUSED  (
    .I(\vga/scancode_convert/scancode_rom/data<4>1_map1548 ),
    .O(\vga/scancode_convert/scancode_rom/data<4>1_map1548_0 )
  );
  defparam \vga/ram_addr_mux<4>_f5 .LOC = "CLB_R15C4.S0";
  X_MUX2 \vga/ram_addr_mux<4>_f5  (
    .IA(N3220),
    .IB(N3219),
    .SEL(\vga/vgacore/vcnt [3]),
    .O(\vga/ram_addr_mux [4])
  );
  defparam \vga/ram_addr_mux<4>1 .INIT = 16'h353A;
  defparam \vga/ram_addr_mux<4>1 .LOC = "CLB_R15C4.S0";
  X_LUT4 \vga/ram_addr_mux<4>1  (
    .ADR0(\vga/crt/cursor_v [0]),
    .ADR1(\vga/vgacore/hcnt [7]),
    .ADR2(\vga/ram_we_n ),
    .ADR3(\vga/crt/cursor_h [4]),
    .O(N3219)
  );
  defparam \vga/ram_addr_mux<4>2 .INIT = 16'hCC5A;
  defparam \vga/ram_addr_mux<4>2 .LOC = "CLB_R15C4.S0";
  X_LUT4 \vga/ram_addr_mux<4>2  (
    .ADR0(\vga/crt/cursor_h [4]),
    .ADR1(\vga/vgacore/hcnt [7]),
    .ADR2(\vga/crt/cursor_v [0]),
    .ADR3(\vga/ram_we_n ),
    .O(N3220)
  );
  defparam \vga/video_ram/ram_addr_w<4>/XUSED .LOC = "CLB_R15C4.S0";
  X_BUF \vga/video_ram/ram_addr_w<4>/XUSED  (
    .I(\vga/ram_addr_mux [4]),
    .O(\vga/ram_addr_mux<4>_0 )
  );
  defparam \vga/video_ram/ram_addr_w_4 .LOC = "CLB_R15C4.S0";
  defparam \vga/video_ram/ram_addr_w_4 .INIT = 1'b0;
  X_FF \vga/video_ram/ram_addr_w_4  (
    .I(\vga/ram_addr_mux [4]),
    .CE(VCC),
    .CLK(\vga/ram_wclk_5 ),
    .SET(GND),
    .RST(GND),
    .O(\vga/video_ram/ram_addr_w [4])
  );
  defparam \vga/scancode_convert/scancode_rom/data<1>2260_SW0 .LOC = "CLB_R14C36.S0";
  X_MUX2 \vga/scancode_convert/scancode_rom/data<1>2260_SW0  (
    .IA(N3184),
    .IB(N3185),
    .SEL(\vga/scancode_convert/sc [2]),
    .O(N3106)
  );
  defparam \vga/scancode_convert/scancode_rom/data<1>2260_SW0_G .INIT = 16'h2A0A;
  defparam \vga/scancode_convert/scancode_rom/data<1>2260_SW0_G .LOC = "CLB_R14C36.S0";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<1>2260_SW0_G  (
    .ADR0(\vga/scancode_convert/sc [5]),
    .ADR1(\vga/scancode_convert/scancode_rom/data<1>2_map1729_0 ),
    .ADR2(\vga/scancode_convert/scancode_rom/data<1>2_map1717_0 ),
    .ADR3(\vga/scancode_convert/sc [3]),
    .O(N3185)
  );
  defparam \vga/scancode_convert/scancode_rom/data<1>2260_SW0_F .INIT = 16'h0300;
  defparam \vga/scancode_convert/scancode_rom/data<1>2260_SW0_F .LOC = "CLB_R14C36.S0";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<1>2260_SW0_F  (
    .ADR0(VCC),
    .ADR1(\vga/scancode_convert/scancode_rom/data<1>2_map1708_0 ),
    .ADR2(\vga/scancode_convert/scancode_rom/data<1>2_map1701_0 ),
    .ADR3(\vga/scancode_convert/sc [5]),
    .O(N3184)
  );
  defparam \N3106/XUSED .LOC = "CLB_R14C36.S0";
  X_BUF \N3106/XUSED  (
    .I(N3106),
    .O(N3106_0)
  );
  defparam \vga/charload217 .LOC = "CLB_R12C8.S0";
  X_MUX2 \vga/charload217  (
    .IA(N3210),
    .IB(N3211),
    .SEL(\vga/rom_addr_char [3]),
    .O(\vga/charload2_map865 )
  );
  defparam \vga/charload217_G .INIT = 16'h0200;
  defparam \vga/charload217_G .LOC = "CLB_R12C8.S0";
  X_LUT4 \vga/charload217_G  (
    .ADR0(\vga/rom_addr_char [1]),
    .ADR1(\vga/rom_addr_char [4]),
    .ADR2(\vga/rom_addr_char [2]),
    .ADR3(\vga/N4 ),
    .O(N3211)
  );
  defparam \vga/charload217_F .INIT = 16'h0020;
  defparam \vga/charload217_F .LOC = "CLB_R12C8.S0";
  X_LUT4 \vga/charload217_F  (
    .ADR0(\vga/vgacore/vcnt_2_1_9 ),
    .ADR1(N3164_0),
    .ADR2(\vga/rom_addr_char [2]),
    .ADR3(\vga/rom_addr_char [4]),
    .O(N3210)
  );
  defparam \vga/charload2_map865/XUSED .LOC = "CLB_R12C8.S0";
  X_BUF \vga/charload2_map865/XUSED  (
    .I(\vga/charload2_map865 ),
    .O(\vga/charload2_map865_0 )
  );
  defparam \vga/crt/state_FFd3-In48_SW0 .LOC = "CLB_R16C18.S1";
  X_MUX2 \vga/crt/state_FFd3-In48_SW0  (
    .IA(N3208),
    .IB(N3209),
    .SEL(\vga/crt/state_FFd2_12 ),
    .O(N3144)
  );
  defparam \vga/crt/state_FFd3-In48_SW0_G .INIT = 16'hFFF3;
  defparam \vga/crt/state_FFd3-In48_SW0_G .LOC = "CLB_R16C18.S1";
  X_LUT4 \vga/crt/state_FFd3-In48_SW0_G  (
    .ADR0(VCC),
    .ADR1(\vga/scancode_convert/strobe_out_15 ),
    .ADR2(\vga/crt/state_FFd1_13 ),
    .ADR3(\vga/scancode_convert/key_up_14 ),
    .O(N3209)
  );
  defparam \vga/crt/state_FFd3-In48_SW0_F .INIT = 16'h0020;
  defparam \vga/crt/state_FFd3-In48_SW0_F .LOC = "CLB_R16C18.S1";
  X_LUT4 \vga/crt/state_FFd3-In48_SW0_F  (
    .ADR0(\vga/crt/state_FFd3_11 ),
    .ADR1(\vga/crt/newline_20 ),
    .ADR2(\vga/crt/state_FFd1_13 ),
    .ADR3(\vga/crt/_cmp_eq0001_0 ),
    .O(N3208)
  );
  defparam \N3144/XUSED .LOC = "CLB_R16C18.S1";
  X_BUF \N3144/XUSED  (
    .I(N3144),
    .O(N3144_0)
  );
  defparam \vga/rom_addr_char<1>1641 .LOC = "CLB_R4C5.S0";
  X_MUX2 \vga/rom_addr_char<1>1641  (
    .IA(N3194),
    .IB(N3195),
    .SEL(\vga/vgacore/vcnt_1_1_8 ),
    .O(\vga/rom_addr_char<1>112_92 )
  );
  defparam \vga/rom_addr_char<1>1641_G .INIT = 16'h21A5;
  defparam \vga/rom_addr_char<1>1641_G .LOC = "CLB_R4C5.S0";
  X_LUT4 \vga/rom_addr_char<1>1641_G  (
    .ADR0(\vga/rom_addr_char_0_1_18 ),
    .ADR1(\vga/vgacore/vcnt_2_1_9 ),
    .ADR2(\vga/rom_addr_char [1]),
    .ADR3(\vga/vgacore/vcnt_0_1_17 ),
    .O(N3195)
  );
  defparam \vga/rom_addr_char<1>1641_F .INIT = 16'hE3E3;
  defparam \vga/rom_addr_char<1>1641_F .LOC = "CLB_R4C5.S0";
  X_LUT4 \vga/rom_addr_char<1>1641_F  (
    .ADR0(\vga/vgacore/vcnt_2_1_9 ),
    .ADR1(\vga/rom_addr_char_0_1_18 ),
    .ADR2(\vga/rom_addr_char [1]),
    .ADR3(VCC),
    .O(N3194)
  );
  defparam \vga/rom_addr_char<1>112/XUSED .LOC = "CLB_R4C5.S0";
  X_BUF \vga/rom_addr_char<1>112/XUSED  (
    .I(\vga/rom_addr_char<1>112_92 ),
    .O(\vga/rom_addr_char<1>112_0 )
  );
  defparam \vga/rom_addr_char<1>1741 .LOC = "CLB_R3C5.S1";
  X_MUX2 \vga/rom_addr_char<1>1741  (
    .IA(N3196),
    .IB(N3197),
    .SEL(\vga/vgacore/vcnt_2_1_9 ),
    .O(\vga/rom_addr_char<1>2_93 )
  );
  defparam \vga/rom_addr_char<1>1741_G .INIT = 16'h5775;
  defparam \vga/rom_addr_char<1>1741_G .LOC = "CLB_R3C5.S1";
  X_LUT4 \vga/rom_addr_char<1>1741_G  (
    .ADR0(\vga/vgacore/vcnt_1_1_8 ),
    .ADR1(\vga/vgacore/vcnt_0_1_17 ),
    .ADR2(\vga/rom_addr_char [1]),
    .ADR3(\vga/rom_addr_char_0_1_18 ),
    .O(N3197)
  );
  defparam \vga/rom_addr_char<1>1741_F .INIT = 16'hFFDC;
  defparam \vga/rom_addr_char<1>1741_F .LOC = "CLB_R3C5.S1";
  X_LUT4 \vga/rom_addr_char<1>1741_F  (
    .ADR0(\vga/rom_addr_char_0_1_18 ),
    .ADR1(\vga/vgacore/vcnt_1_1_8 ),
    .ADR2(\vga/rom_addr_char [1]),
    .ADR3(\vga/vgacore/vcnt_0_1_17 ),
    .O(N3196)
  );
  defparam \vga/rom_addr_char<1>2/XUSED .LOC = "CLB_R3C5.S1";
  X_BUF \vga/rom_addr_char<1>2/XUSED  (
    .I(\vga/rom_addr_char<1>2_93 ),
    .O(\vga/rom_addr_char<1>2_0 )
  );
  defparam \vga/rom_addr_char<2>_f5_01 .LOC = "CLB_R20C3.S0";
  X_MUX2 \vga/rom_addr_char<2>_f5_01  (
    .IA(\vga/N3123 ),
    .IB(\vga/N21234 ),
    .SEL(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f511 )
  );
  defparam \vga/rom_addr_char<1>21 .INIT = 16'hEE44;
  defparam \vga/rom_addr_char<1>21 .LOC = "CLB_R20C3.S0";
  X_LUT4 \vga/rom_addr_char<1>21  (
    .ADR0(\vga/rom_addr_char_1_1_7 ),
    .ADR1(\vga/N138_0 ),
    .ADR2(VCC),
    .ADR3(\vga/N139_0 ),
    .O(\vga/N21234 )
  );
  defparam \vga/rom_addr_char<1>31 .INIT = 16'hAACC;
  defparam \vga/rom_addr_char<1>31 .LOC = "CLB_R20C3.S0";
  X_LUT4 \vga/rom_addr_char<1>31  (
    .ADR0(\vga/N137_0 ),
    .ADR1(\vga/N47_0 ),
    .ADR2(VCC),
    .ADR3(\vga/rom_addr_char_1_1_7 ),
    .O(\vga/N3123 )
  );
  defparam \vga/rom_addr_char<2>_f511/F5USED .LOC = "CLB_R20C3.S0";
  X_BUF \vga/rom_addr_char<2>_f511/F5USED  (
    .I(\vga/rom_addr_char<2>_f511 ),
    .O(\vga/rom_addr_char<2>_f511_0 )
  );
  defparam \vga/rom_addr_char<2>_f5_02 .LOC = "CLB_R24C6.S0";
  X_MUX2 \vga/rom_addr_char<2>_f5_02  (
    .IA(\vga/N31234 ),
    .IB(\vga/N212345 ),
    .SEL(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f5112 )
  );
  defparam \vga/rom_addr_char<1>25 .INIT = 16'hFA50;
  defparam \vga/rom_addr_char<1>25 .LOC = "CLB_R24C6.S0";
  X_LUT4 \vga/rom_addr_char<1>25  (
    .ADR0(\vga/rom_addr_char_1_1_7 ),
    .ADR1(VCC),
    .ADR2(\vga/N49_0 ),
    .ADR3(\vga/N50_0 ),
    .O(\vga/N212345 )
  );
  defparam \vga/rom_addr_char<1>32 .INIT = 16'hEE22;
  defparam \vga/rom_addr_char<1>32 .LOC = "CLB_R24C6.S0";
  X_LUT4 \vga/rom_addr_char<1>32  (
    .ADR0(\vga/N47_0 ),
    .ADR1(\vga/rom_addr_char_1_1_7 ),
    .ADR2(VCC),
    .ADR3(\vga/N48_0 ),
    .O(\vga/N31234 )
  );
  defparam \vga/rom_addr_char<2>_f5112/F5USED .LOC = "CLB_R24C6.S0";
  X_BUF \vga/rom_addr_char<2>_f5112/F5USED  (
    .I(\vga/rom_addr_char<2>_f5112 ),
    .O(\vga/rom_addr_char<2>_f5112_0 )
  );
  defparam \vga/rom_addr_char<2>_f5_10 .LOC = "CLB_R27C13.S0";
  X_MUX2 \vga/rom_addr_char<2>_f5_10  (
    .IA(\vga/N241 ),
    .IB(N3079),
    .SEL(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f5111 )
  );
  defparam \vga/rom_addr_char<2>_f5_102 .INIT = 16'hF0CC;
  defparam \vga/rom_addr_char<2>_f5_102 .LOC = "CLB_R27C13.S0";
  X_LUT4 \vga/rom_addr_char<2>_f5_102  (
    .ADR0(VCC),
    .ADR1(\vga/N70_0 ),
    .ADR2(\vga/N71_0 ),
    .ADR3(\vga/rom_addr_char_1_1_7 ),
    .O(N3079)
  );
  defparam \vga/rom_addr_char<1>23 .INIT = 16'hF5A0;
  defparam \vga/rom_addr_char<1>23 .LOC = "CLB_R27C13.S0";
  X_LUT4 \vga/rom_addr_char<1>23  (
    .ADR0(\vga/rom_addr_char_1_1_7 ),
    .ADR1(VCC),
    .ADR2(\vga/N64_0 ),
    .ADR3(\vga/N155_0 ),
    .O(\vga/N241 )
  );
  defparam \vga/rom_addr_char<2>_f5111/F5USED .LOC = "CLB_R27C13.S0";
  X_BUF \vga/rom_addr_char<2>_f5111/F5USED  (
    .I(\vga/rom_addr_char<2>_f5111 ),
    .O(\vga/rom_addr_char<2>_f5111_0 )
  );
  defparam \vga/rom_addr_char<2>_f5_03 .LOC = "CLB_R11C3.S1";
  X_MUX2 \vga/rom_addr_char<2>_f5_03  (
    .IA(\vga/N312345 ),
    .IB(\vga/N2123456 ),
    .SEL(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f51123 )
  );
  defparam \vga/rom_addr_char<1>33 .INIT = 16'hEE22;
  defparam \vga/rom_addr_char<1>33 .LOC = "CLB_R11C3.S1";
  X_LUT4 \vga/rom_addr_char<1>33  (
    .ADR0(\vga/N104_0 ),
    .ADR1(\vga/rom_addr_char_1_1_7 ),
    .ADR2(VCC),
    .ADR3(\vga/N105_0 ),
    .O(\vga/N2123456 )
  );
  defparam \vga/rom_addr_char<1>43 .INIT = 16'h7861;
  defparam \vga/rom_addr_char<1>43 .LOC = "CLB_R11C3.S1";
  X_LUT4 \vga/rom_addr_char<1>43  (
    .ADR0(\vga/vgacore/vcnt_0_1_17 ),
    .ADR1(\vga/vgacore/vcnt_2_1_9 ),
    .ADR2(\vga/vgacore/vcnt_1_1_8 ),
    .ADR3(\vga/rom_addr_char_1_1_7 ),
    .O(\vga/N312345 )
  );
  defparam \vga/rom_addr_char<3>_f61234/YUSED .LOC = "CLB_R11C3.S1";
  X_BUF \vga/rom_addr_char<3>_f61234/YUSED  (
    .I(\vga/rom_addr_char<3>_f61234 ),
    .O(\vga/rom_addr_char<3>_f61234_0 )
  );
  defparam \vga/rom_addr_char<3>_f63 .LOC = "CLB_R11C3.S1";
  X_MUX2 \vga/rom_addr_char<3>_f63  (
    .IA(\vga/rom_addr_char<2>_f52123_0 ),
    .IB(\vga/rom_addr_char<2>_f51123 ),
    .SEL(\vga/rom_addr_char [3]),
    .O(\vga/rom_addr_char<3>_f61234 )
  );
  defparam \vga/rom_addr_char<2>_f5_11 .LOC = "CLB_R23C3.S1";
  X_MUX2 \vga/rom_addr_char<2>_f5_11  (
    .IA(\vga/N5 ),
    .IB(\vga/N4123 ),
    .SEL(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f521 )
  );
  defparam \vga/rom_addr_char<1>41 .INIT = 16'hFA50;
  defparam \vga/rom_addr_char<1>41 .LOC = "CLB_R23C3.S1";
  X_LUT4 \vga/rom_addr_char<1>41  (
    .ADR0(\vga/rom_addr_char_1_1_7 ),
    .ADR1(VCC),
    .ADR2(\vga/N150_0 ),
    .ADR3(\vga/N151_0 ),
    .O(\vga/N4123 )
  );
  defparam \vga/rom_addr_char<1>51 .INIT = 16'hF5A0;
  defparam \vga/rom_addr_char<1>51 .LOC = "CLB_R23C3.S1";
  X_LUT4 \vga/rom_addr_char<1>51  (
    .ADR0(\vga/rom_addr_char_1_1_7 ),
    .ADR1(VCC),
    .ADR2(\vga/N149_0 ),
    .ADR3(\vga/N55_0 ),
    .O(\vga/N5 )
  );
  defparam \vga/rom_addr_char<3>_f611/YUSED .LOC = "CLB_R23C3.S1";
  X_BUF \vga/rom_addr_char<3>_f611/YUSED  (
    .I(\vga/rom_addr_char<3>_f611 ),
    .O(\vga/rom_addr_char<3>_f611_0 )
  );
  defparam \vga/rom_addr_char<3>_f6_01 .LOC = "CLB_R23C3.S1";
  X_MUX2 \vga/rom_addr_char<3>_f6_01  (
    .IA(\vga/rom_addr_char<2>_f531_0 ),
    .IB(\vga/rom_addr_char<2>_f521 ),
    .SEL(\vga/rom_addr_char [3]),
    .O(\vga/rom_addr_char<3>_f611 )
  );
  defparam \vga/rom_addr_char<2>_f5_04 .LOC = "CLB_R23C5.S0";
  X_MUX2 \vga/rom_addr_char<2>_f5_04  (
    .IA(\vga/N3123456 ),
    .IB(\vga/N21234567 ),
    .SEL(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f511234 )
  );
  defparam \vga/rom_addr_char<1>29 .INIT = 16'hF0CC;
  defparam \vga/rom_addr_char<1>29 .LOC = "CLB_R23C5.S0";
  X_LUT4 \vga/rom_addr_char<1>29  (
    .ADR0(VCC),
    .ADR1(\vga/N184_0 ),
    .ADR2(\vga/N8 ),
    .ADR3(\vga/rom_addr_char_1_1_7 ),
    .O(\vga/N21234567 )
  );
  defparam \vga/rom_addr_char<1>34 .INIT = 16'hA0A0;
  defparam \vga/rom_addr_char<1>34 .LOC = "CLB_R23C5.S0";
  X_LUT4 \vga/rom_addr_char<1>34  (
    .ADR0(\vga/rom_addr_char_1_1_7 ),
    .ADR1(VCC),
    .ADR2(\vga/N183_0 ),
    .ADR3(VCC),
    .O(\vga/N3123456 )
  );
  defparam \vga/rom_addr_char<2>_f511234/F5USED .LOC = "CLB_R23C5.S0";
  X_BUF \vga/rom_addr_char<2>_f511234/F5USED  (
    .I(\vga/rom_addr_char<2>_f511234 ),
    .O(\vga/rom_addr_char<2>_f511234_0 )
  );
  defparam \vga/rom_addr_char<2>_f5_12 .LOC = "CLB_R24C11.S1";
  X_MUX2 \vga/rom_addr_char<2>_f5_12  (
    .IA(\vga/N5123 ),
    .IB(\vga/N41234 ),
    .SEL(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f5212 )
  );
  defparam \vga/rom_addr_char<1>42 .INIT = 16'hFC0C;
  defparam \vga/rom_addr_char<1>42 .LOC = "CLB_R24C11.S1";
  X_LUT4 \vga/rom_addr_char<1>42  (
    .ADR0(VCC),
    .ADR1(\vga/N59_0 ),
    .ADR2(\vga/rom_addr_char_1_1_7 ),
    .ADR3(\vga/N60_0 ),
    .O(\vga/N41234 )
  );
  defparam \vga/rom_addr_char<1>52 .INIT = 16'h0A0A;
  defparam \vga/rom_addr_char<1>52 .LOC = "CLB_R24C11.S1";
  X_LUT4 \vga/rom_addr_char<1>52  (
    .ADR0(\vga/N58_0 ),
    .ADR1(VCC),
    .ADR2(\vga/rom_addr_char_1_1_7 ),
    .ADR3(VCC),
    .O(\vga/N5123 )
  );
  defparam \vga/rom_addr_char<3>_f6112/YUSED .LOC = "CLB_R24C11.S1";
  X_BUF \vga/rom_addr_char<3>_f6112/YUSED  (
    .I(\vga/rom_addr_char<3>_f6112 ),
    .O(\vga/rom_addr_char<3>_f6112_0 )
  );
  defparam \vga/rom_addr_char<3>_f6_02 .LOC = "CLB_R24C11.S1";
  X_MUX2 \vga/rom_addr_char<3>_f6_02  (
    .IA(\vga/rom_addr_char<2>_f5312_0 ),
    .IB(\vga/rom_addr_char<2>_f5212 ),
    .SEL(\vga/rom_addr_char [3]),
    .O(\vga/rom_addr_char<3>_f6112 )
  );
  defparam \vga/rom_addr_char<2>_f5_13 .LOC = "CLB_R11C3.S0";
  X_MUX2 \vga/rom_addr_char<2>_f5_13  (
    .IA(\vga/N51234 ),
    .IB(\vga/N412345 ),
    .SEL(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f52123 )
  );
  defparam \vga/rom_addr_char<1>53 .INIT = 16'hCFC0;
  defparam \vga/rom_addr_char<1>53 .LOC = "CLB_R11C3.S0";
  X_LUT4 \vga/rom_addr_char<1>53  (
    .ADR0(VCC),
    .ADR1(\vga/N102_0 ),
    .ADR2(\vga/rom_addr_char_1_1_7 ),
    .ADR3(\vga/N101_0 ),
    .O(\vga/N412345 )
  );
  defparam \vga/rom_addr_char<1>63 .INIT = 16'hFA0A;
  defparam \vga/rom_addr_char<1>63 .LOC = "CLB_R11C3.S0";
  X_LUT4 \vga/rom_addr_char<1>63  (
    .ADR0(\vga/N99_0 ),
    .ADR1(VCC),
    .ADR2(\vga/rom_addr_char_1_1_7 ),
    .ADR3(\vga/N55_0 ),
    .O(\vga/N51234 )
  );
  defparam \vga/rom_addr_char<2>_f52123/F5USED .LOC = "CLB_R11C3.S0";
  X_BUF \vga/rom_addr_char<2>_f52123/F5USED  (
    .I(\vga/rom_addr_char<2>_f52123 ),
    .O(\vga/rom_addr_char<2>_f52123_0 )
  );
  defparam \vga/rom_addr_char<2>_f5_21 .LOC = "CLB_R23C3.S0";
  X_MUX2 \vga/rom_addr_char<2>_f5_21  (
    .IA(\vga/N7123 ),
    .IB(\vga/N6123 ),
    .SEL(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f531 )
  );
  defparam \vga/rom_addr_char<1>61 .INIT = 16'hAAF0;
  defparam \vga/rom_addr_char<1>61 .LOC = "CLB_R23C3.S0";
  X_LUT4 \vga/rom_addr_char<1>61  (
    .ADR0(\vga/N147_0 ),
    .ADR1(VCC),
    .ADR2(\vga/N146_0 ),
    .ADR3(\vga/rom_addr_char_1_1_7 ),
    .O(\vga/N6123 )
  );
  defparam \vga/rom_addr_char<1>71 .INIT = 16'hCCAA;
  defparam \vga/rom_addr_char<1>71 .LOC = "CLB_R23C3.S0";
  X_LUT4 \vga/rom_addr_char<1>71  (
    .ADR0(\vga/N144_0 ),
    .ADR1(\vga/N145_0 ),
    .ADR2(VCC),
    .ADR3(\vga/rom_addr_char_1_1_7 ),
    .O(\vga/N7123 )
  );
  defparam \vga/rom_addr_char<2>_f531/F5USED .LOC = "CLB_R23C3.S0";
  X_BUF \vga/rom_addr_char<2>_f531/F5USED  (
    .I(\vga/rom_addr_char<2>_f531 ),
    .O(\vga/rom_addr_char<2>_f531_0 )
  );
  defparam \vga/rom_addr_char<2>_f5_14 .LOC = "CLB_R16C3.S1";
  X_MUX2 \vga/rom_addr_char<2>_f5_14  (
    .IA(\vga/N512345 ),
    .IB(\vga/N4123456 ),
    .SEL(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f521234 )
  );
  defparam \vga/rom_addr_char<1>44 .INIT = 16'hFC0C;
  defparam \vga/rom_addr_char<1>44 .LOC = "CLB_R16C3.S1";
  X_LUT4 \vga/rom_addr_char<1>44  (
    .ADR0(VCC),
    .ADR1(\vga/N194_0 ),
    .ADR2(\vga/rom_addr_char_1_1_7 ),
    .ADR3(\vga/N15_0 ),
    .O(\vga/N4123456 )
  );
  defparam \vga/rom_addr_char<1>54 .INIT = 16'h00F0;
  defparam \vga/rom_addr_char<1>54 .LOC = "CLB_R16C3.S1";
  X_LUT4 \vga/rom_addr_char<1>54  (
    .ADR0(VCC),
    .ADR1(VCC),
    .ADR2(\vga/N193_0 ),
    .ADR3(\vga/rom_addr_char_1_1_7 ),
    .O(\vga/N512345 )
  );
  defparam \vga/rom_addr_char<3>_f611234/YUSED .LOC = "CLB_R16C3.S1";
  X_BUF \vga/rom_addr_char<3>_f611234/YUSED  (
    .I(\vga/rom_addr_char<3>_f611234 ),
    .O(\vga/rom_addr_char<3>_f611234_0 )
  );
  defparam \vga/rom_addr_char<3>_f6_04 .LOC = "CLB_R16C3.S1";
  X_MUX2 \vga/rom_addr_char<3>_f6_04  (
    .IA(\vga/rom_addr_char<2>_f531234_0 ),
    .IB(\vga/rom_addr_char<2>_f521234 ),
    .SEL(\vga/rom_addr_char [3]),
    .O(\vga/rom_addr_char<3>_f611234 )
  );
  defparam \vga/rom_addr_char<2>_f5_22 .LOC = "CLB_R24C11.S0";
  X_MUX2 \vga/rom_addr_char<2>_f5_22  (
    .IA(\vga/N71234 ),
    .IB(\vga/N61234 ),
    .SEL(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f5312 )
  );
  defparam \vga/rom_addr_char<1>62 .INIT = 16'hB8B8;
  defparam \vga/rom_addr_char<1>62 .LOC = "CLB_R24C11.S0";
  X_LUT4 \vga/rom_addr_char<1>62  (
    .ADR0(\vga/N57_0 ),
    .ADR1(\vga/rom_addr_char_1_1_7 ),
    .ADR2(\vga/N56_0 ),
    .ADR3(VCC),
    .O(\vga/N61234 )
  );
  defparam \vga/rom_addr_char<1>72 .INIT = 16'hBB88;
  defparam \vga/rom_addr_char<1>72 .LOC = "CLB_R24C11.S0";
  X_LUT4 \vga/rom_addr_char<1>72  (
    .ADR0(\vga/N55_0 ),
    .ADR1(\vga/rom_addr_char_1_1_7 ),
    .ADR2(VCC),
    .ADR3(\vga/N54_0 ),
    .O(\vga/N71234 )
  );
  defparam \vga/rom_addr_char<2>_f5312/F5USED .LOC = "CLB_R24C11.S0";
  X_BUF \vga/rom_addr_char<2>_f5312/F5USED  (
    .I(\vga/rom_addr_char<2>_f5312 ),
    .O(\vga/rom_addr_char<2>_f5312_0 )
  );
  defparam \vga/rom_addr_char<2>_f5_23 .LOC = "CLB_R26C5.S1";
  X_MUX2 \vga/rom_addr_char<2>_f5_23  (
    .IA(\vga/N712345 ),
    .IB(\vga/N612345 ),
    .SEL(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f53123 )
  );
  defparam \vga/rom_addr_char<1>73 .INIT = 16'hACAC;
  defparam \vga/rom_addr_char<1>73 .LOC = "CLB_R26C5.S1";
  X_LUT4 \vga/rom_addr_char<1>73  (
    .ADR0(\vga/N128_0 ),
    .ADR1(\vga/N127_0 ),
    .ADR2(\vga/rom_addr_char_1_1_7 ),
    .ADR3(VCC),
    .O(\vga/N612345 )
  );
  defparam \vga/rom_addr_char<1>83 .INIT = 16'hCFC0;
  defparam \vga/rom_addr_char<1>83 .LOC = "CLB_R26C5.S1";
  X_LUT4 \vga/rom_addr_char<1>83  (
    .ADR0(VCC),
    .ADR1(\vga/N126_0 ),
    .ADR2(\vga/rom_addr_char_1_1_7 ),
    .ADR3(\vga/N125_0 ),
    .O(\vga/N712345 )
  );
  defparam \vga/rom_addr_char<3>_f61123/YUSED .LOC = "CLB_R26C5.S1";
  X_BUF \vga/rom_addr_char<3>_f61123/YUSED  (
    .I(\vga/rom_addr_char<3>_f61123 ),
    .O(\vga/rom_addr_char<3>_f61123_0 )
  );
  defparam \vga/rom_addr_char<3>_f6_03 .LOC = "CLB_R26C5.S1";
  X_MUX2 \vga/rom_addr_char<3>_f6_03  (
    .IA(\vga/rom_addr_char<2>_f54123_0 ),
    .IB(\vga/rom_addr_char<2>_f53123 ),
    .SEL(\vga/rom_addr_char [3]),
    .O(\vga/rom_addr_char<3>_f61123 )
  );
  defparam \vga/rom_addr_char<2>_f5_31 .LOC = "CLB_R27C5.S1";
  X_MUX2 \vga/rom_addr_char<2>_f5_31  (
    .IA(\vga/N9 ),
    .IB(\vga/N8123 ),
    .SEL(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f541 )
  );
  defparam \vga/rom_addr_char<1>81 .INIT = 16'hEE44;
  defparam \vga/rom_addr_char<1>81 .LOC = "CLB_R27C5.S1";
  X_LUT4 \vga/rom_addr_char<1>81  (
    .ADR0(\vga/rom_addr_char_1_1_7 ),
    .ADR1(\vga/N53_0 ),
    .ADR2(VCC),
    .ADR3(\vga/N128_0 ),
    .O(\vga/N8123 )
  );
  defparam \vga/rom_addr_char<1>91 .INIT = 16'hF0AA;
  defparam \vga/rom_addr_char<1>91 .LOC = "CLB_R27C5.S1";
  X_LUT4 \vga/rom_addr_char<1>91  (
    .ADR0(\vga/N171_0 ),
    .ADR1(VCC),
    .ADR2(\vga/N172_0 ),
    .ADR3(\vga/rom_addr_char_1_1_7 ),
    .O(\vga/N9 )
  );
  defparam \vga/rom_addr_char<3>_f621/YUSED .LOC = "CLB_R27C5.S1";
  X_BUF \vga/rom_addr_char<3>_f621/YUSED  (
    .I(\vga/rom_addr_char<3>_f621 ),
    .O(\vga/rom_addr_char<3>_f621_0 )
  );
  defparam \vga/rom_addr_char<3>_f6_11 .LOC = "CLB_R27C5.S1";
  X_MUX2 \vga/rom_addr_char<3>_f6_11  (
    .IA(\vga/rom_addr_char<2>_f551_0 ),
    .IB(\vga/rom_addr_char<2>_f541 ),
    .SEL(\vga/rom_addr_char [3]),
    .O(\vga/rom_addr_char<3>_f621 )
  );
  defparam \vga/rom_addr_char<2>_f5_24 .LOC = "CLB_R16C3.S0";
  X_MUX2 \vga/rom_addr_char<2>_f5_24  (
    .IA(\vga/N7123456 ),
    .IB(\vga/N6123456 ),
    .SEL(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f531234 )
  );
  defparam \vga/rom_addr_char<1>64 .INIT = 16'hFA50;
  defparam \vga/rom_addr_char<1>64 .LOC = "CLB_R16C3.S0";
  X_LUT4 \vga/rom_addr_char<1>64  (
    .ADR0(\vga/rom_addr_char_1_1_7 ),
    .ADR1(VCC),
    .ADR2(\vga/N191_0 ),
    .ADR3(\vga/N192_0 ),
    .O(\vga/N6123456 )
  );
  defparam \vga/rom_addr_char<1>74 .INIT = 16'hBB88;
  defparam \vga/rom_addr_char<1>74 .LOC = "CLB_R16C3.S0";
  X_LUT4 \vga/rom_addr_char<1>74  (
    .ADR0(\vga/N190_0 ),
    .ADR1(\vga/rom_addr_char_1_1_7 ),
    .ADR2(VCC),
    .ADR3(\vga/N16_0 ),
    .O(\vga/N7123456 )
  );
  defparam \vga/rom_addr_char<2>_f531234/F5USED .LOC = "CLB_R16C3.S0";
  X_BUF \vga/rom_addr_char<2>_f531234/F5USED  (
    .I(\vga/rom_addr_char<2>_f531234 ),
    .O(\vga/rom_addr_char<2>_f531234_0 )
  );
  defparam \vga/rom_addr_char<2>_f5_32 .LOC = "CLB_R26C8.S1";
  X_MUX2 \vga/rom_addr_char<2>_f5_32  (
    .IA(\vga/N91 ),
    .IB(\vga/N81234 ),
    .SEL(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f5412 )
  );
  defparam \vga/rom_addr_char<1>82 .INIT = 16'hDD88;
  defparam \vga/rom_addr_char<1>82 .LOC = "CLB_R26C8.S1";
  X_LUT4 \vga/rom_addr_char<1>82  (
    .ADR0(\vga/rom_addr_char_1_1_7 ),
    .ADR1(\vga/N83_0 ),
    .ADR2(VCC),
    .ADR3(\vga/N82_0 ),
    .O(\vga/N81234 )
  );
  defparam \vga/rom_addr_char<1>92 .INIT = 16'hF5A0;
  defparam \vga/rom_addr_char<1>92 .LOC = "CLB_R26C8.S1";
  X_LUT4 \vga/rom_addr_char<1>92  (
    .ADR0(\vga/rom_addr_char_1_1_7 ),
    .ADR1(VCC),
    .ADR2(\vga/N81_0 ),
    .ADR3(\vga/N80_0 ),
    .O(\vga/N91 )
  );
  defparam \vga/rom_addr_char<3>_f6212/YUSED .LOC = "CLB_R26C8.S1";
  X_BUF \vga/rom_addr_char<3>_f6212/YUSED  (
    .I(\vga/rom_addr_char<3>_f6212 ),
    .O(\vga/rom_addr_char<3>_f6212_0 )
  );
  defparam \vga/rom_addr_char<3>_f6_12 .LOC = "CLB_R26C8.S1";
  X_MUX2 \vga/rom_addr_char<3>_f6_12  (
    .IA(\vga/rom_addr_char<2>_f5512_0 ),
    .IB(\vga/rom_addr_char<2>_f5412 ),
    .SEL(\vga/rom_addr_char [3]),
    .O(\vga/rom_addr_char<3>_f6212 )
  );
  defparam \vga/rom_addr_char<2>_f5_33 .LOC = "CLB_R26C5.S0";
  X_MUX2 \vga/rom_addr_char<2>_f5_33  (
    .IA(\vga/N9123 ),
    .IB(\vga/N10123 ),
    .SEL(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f54123 )
  );
  defparam \vga/rom_addr_char<1>102 .INIT = 16'hEE44;
  defparam \vga/rom_addr_char<1>102 .LOC = "CLB_R26C5.S0";
  X_LUT4 \vga/rom_addr_char<1>102  (
    .ADR0(\vga/rom_addr_char [1]),
    .ADR1(\vga/N78_0 ),
    .ADR2(VCC),
    .ADR3(\vga/N79_0 ),
    .O(\vga/N10123 )
  );
  defparam \vga/rom_addr_char<1>103 .INIT = 16'h5D08;
  defparam \vga/rom_addr_char<1>103 .LOC = "CLB_R26C5.S0";
  X_LUT4 \vga/rom_addr_char<1>103  (
    .ADR0(\vga/rom_addr_char [1]),
    .ADR1(\vga/vgacore/vcnt_1_1_8 ),
    .ADR2(\vga/vgacore/vcnt_0_1_17 ),
    .ADR3(\vga/N121_0 ),
    .O(\vga/N9123 )
  );
  defparam \vga/rom_addr_char<2>_f54123/F5USED .LOC = "CLB_R26C5.S0";
  X_BUF \vga/rom_addr_char<2>_f54123/F5USED  (
    .I(\vga/rom_addr_char<2>_f54123 ),
    .O(\vga/rom_addr_char<2>_f54123_0 )
  );
  defparam \vga/rom_addr_char<2>_f5_41 .LOC = "CLB_R27C5.S0";
  X_MUX2 \vga/rom_addr_char<2>_f5_41  (
    .IA(\vga/N11112 ),
    .IB(\vga/N1012 ),
    .SEL(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f551 )
  );
  defparam \vga/rom_addr_char<1>101 .INIT = 16'hF5A0;
  defparam \vga/rom_addr_char<1>101 .LOC = "CLB_R27C5.S0";
  X_LUT4 \vga/rom_addr_char<1>101  (
    .ADR0(\vga/rom_addr_char [1]),
    .ADR1(VCC),
    .ADR2(\vga/N170_0 ),
    .ADR3(\vga/N78_0 ),
    .O(\vga/N1012 )
  );
  defparam \vga/rom_addr_char<1>111 .INIT = 16'h7250;
  defparam \vga/rom_addr_char<1>111 .LOC = "CLB_R27C5.S0";
  X_LUT4 \vga/rom_addr_char<1>111  (
    .ADR0(\vga/rom_addr_char [1]),
    .ADR1(\vga/vgacore/vcnt_0_1_17 ),
    .ADR2(\vga/N167_0 ),
    .ADR3(\vga/vgacore/vcnt_1_1_8 ),
    .O(\vga/N11112 )
  );
  defparam \vga/rom_addr_char<2>_f551/F5USED .LOC = "CLB_R27C5.S0";
  X_BUF \vga/rom_addr_char<2>_f551/F5USED  (
    .I(\vga/rom_addr_char<2>_f551 ),
    .O(\vga/rom_addr_char<2>_f551_0 )
  );
  defparam \vga/rom_addr_char<2>_f5_34 .LOC = "CLB_R5C3.S1";
  X_MUX2 \vga/rom_addr_char<2>_f5_34  (
    .IA(\vga/N91234 ),
    .IB(\vga/N8123456 ),
    .SEL(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f541234 )
  );
  defparam \vga/rom_addr_char<1>84 .INIT = 16'hAACC;
  defparam \vga/rom_addr_char<1>84 .LOC = "CLB_R5C3.S1";
  X_LUT4 \vga/rom_addr_char<1>84  (
    .ADR0(\vga/N213_0 ),
    .ADR1(\vga/N41_0 ),
    .ADR2(VCC),
    .ADR3(\vga/rom_addr_char_1_1_7 ),
    .O(\vga/N8123456 )
  );
  defparam \vga/rom_addr_char<1>94 .INIT = 16'hE4E4;
  defparam \vga/rom_addr_char<1>94 .LOC = "CLB_R5C3.S1";
  X_LUT4 \vga/rom_addr_char<1>94  (
    .ADR0(\vga/rom_addr_char_1_1_7 ),
    .ADR1(\vga/N27_0 ),
    .ADR2(\vga/N29_0 ),
    .ADR3(VCC),
    .O(\vga/N91234 )
  );
  defparam \vga/rom_addr_char<3>_f621234/YUSED .LOC = "CLB_R5C3.S1";
  X_BUF \vga/rom_addr_char<3>_f621234/YUSED  (
    .I(\vga/rom_addr_char<3>_f621234 ),
    .O(\vga/rom_addr_char<3>_f621234_0 )
  );
  defparam \vga/rom_addr_char<3>_f6_14 .LOC = "CLB_R5C3.S1";
  X_MUX2 \vga/rom_addr_char<3>_f6_14  (
    .IA(\vga/rom_addr_char<2>_f551234_0 ),
    .IB(\vga/rom_addr_char<2>_f541234 ),
    .SEL(\vga/rom_addr_char [3]),
    .O(\vga/rom_addr_char<3>_f621234 )
  );
  defparam \vga/rom_addr_char<2>_f5_42 .LOC = "CLB_R26C8.S0";
  X_MUX2 \vga/rom_addr_char<2>_f5_42  (
    .IA(\vga/N111123 ),
    .IB(N3080),
    .SEL(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f5512 )
  );
  defparam \vga/rom_addr_char<2>_f5_421 .INIT = 16'hEE22;
  defparam \vga/rom_addr_char<2>_f5_421 .LOC = "CLB_R26C8.S0";
  X_LUT4 \vga/rom_addr_char<2>_f5_421  (
    .ADR0(\vga/N78_0 ),
    .ADR1(\vga/rom_addr_char_1_1_7 ),
    .ADR2(VCC),
    .ADR3(\vga/N79_0 ),
    .O(N3080)
  );
  defparam \vga/rom_addr_char<1>113 .INIT = 16'h00D8;
  defparam \vga/rom_addr_char<1>113 .LOC = "CLB_R26C8.S0";
  X_LUT4 \vga/rom_addr_char<1>113  (
    .ADR0(\vga/rom_addr_char [1]),
    .ADR1(\vga/vgacore/vcnt_1_1_8 ),
    .ADR2(N3170_0),
    .ADR3(\vga/vgacore/vcnt_0_1_17 ),
    .O(\vga/N111123 )
  );
  defparam \vga/rom_addr_char<2>_f5512/F5USED .LOC = "CLB_R26C8.S0";
  X_BUF \vga/rom_addr_char<2>_f5512/F5USED  (
    .I(\vga/rom_addr_char<2>_f5512 ),
    .O(\vga/rom_addr_char<2>_f5512_0 )
  );
  defparam \vga/rom_addr_char<2>_f5_43 .LOC = "CLB_R22C2.S1";
  X_MUX2 \vga/rom_addr_char<2>_f5_43  (
    .IA(\vga/N1110 ),
    .IB(\vga/N101234 ),
    .SEL(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f55123 )
  );
  defparam \vga/rom_addr_char<1>115 .INIT = 16'hEE44;
  defparam \vga/rom_addr_char<1>115 .LOC = "CLB_R22C2.S1";
  X_LUT4 \vga/rom_addr_char<1>115  (
    .ADR0(\vga/rom_addr_char [1]),
    .ADR1(\vga/N133_0 ),
    .ADR2(VCC),
    .ADR3(\vga/N134_0 ),
    .O(\vga/N101234 )
  );
  defparam \vga/rom_addr_char<1>123 .INIT = 16'hF5A0;
  defparam \vga/rom_addr_char<1>123 .LOC = "CLB_R22C2.S1";
  X_LUT4 \vga/rom_addr_char<1>123  (
    .ADR0(\vga/rom_addr_char [1]),
    .ADR1(VCC),
    .ADR2(\vga/N132_0 ),
    .ADR3(\vga/N131_0 ),
    .O(\vga/N1110 )
  );
  defparam \vga/rom_addr_char<3>_f62123/YUSED .LOC = "CLB_R22C2.S1";
  X_BUF \vga/rom_addr_char<3>_f62123/YUSED  (
    .I(\vga/rom_addr_char<3>_f62123 ),
    .O(\vga/rom_addr_char<3>_f62123_0 )
  );
  defparam \vga/rom_addr_char<3>_f6_13 .LOC = "CLB_R22C2.S1";
  X_MUX2 \vga/rom_addr_char<3>_f6_13  (
    .IA(\vga/rom_addr_char<2>_f56123_0 ),
    .IB(\vga/rom_addr_char<2>_f55123 ),
    .SEL(\vga/rom_addr_char [3]),
    .O(\vga/rom_addr_char<3>_f62123 )
  );
  defparam \vga/rom_addr_char<2>_f5_51 .LOC = "CLB_R25C12.S1";
  X_MUX2 \vga/rom_addr_char<2>_f5_51  (
    .IA(\vga/N1312 ),
    .IB(\vga/N1212 ),
    .SEL(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f561 )
  );
  defparam \vga/rom_addr_char<1>121 .INIT = 16'h0033;
  defparam \vga/rom_addr_char<1>121 .LOC = "CLB_R25C12.S1";
  X_LUT4 \vga/rom_addr_char<1>121  (
    .ADR0(VCC),
    .ADR1(N3160_0),
    .ADR2(VCC),
    .ADR3(\vga/vgacore/vcnt_0_1_17 ),
    .O(\vga/N1212 )
  );
  defparam \vga/rom_addr_char<1>131 .INIT = 16'hACAC;
  defparam \vga/rom_addr_char<1>131 .LOC = "CLB_R25C12.S1";
  X_LUT4 \vga/rom_addr_char<1>131  (
    .ADR0(\vga/N179_0 ),
    .ADR1(\vga/N178_0 ),
    .ADR2(\vga/rom_addr_char [1]),
    .ADR3(VCC),
    .O(\vga/N1312 )
  );
  defparam \vga/rom_addr_char<3>_f631/YUSED .LOC = "CLB_R25C12.S1";
  X_BUF \vga/rom_addr_char<3>_f631/YUSED  (
    .I(\vga/rom_addr_char<3>_f631 ),
    .O(\vga/rom_addr_char<3>_f631_0 )
  );
  defparam \vga/rom_addr_char<3>_f6_21 .LOC = "CLB_R25C12.S1";
  X_MUX2 \vga/rom_addr_char<3>_f6_21  (
    .IA(\vga/rom_addr_char<2>_f571_0 ),
    .IB(\vga/rom_addr_char<2>_f561 ),
    .SEL(\vga/rom_addr_char [3]),
    .O(\vga/rom_addr_char<3>_f631 )
  );
  defparam \vga/rom_addr_char<2>_f5_44 .LOC = "CLB_R5C3.S0";
  X_MUX2 \vga/rom_addr_char<2>_f5_44  (
    .IA(\vga/N1111234 ),
    .IB(\vga/N1012345 ),
    .SEL(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f551234 )
  );
  defparam \vga/rom_addr_char<1>104 .INIT = 16'h0388;
  defparam \vga/rom_addr_char<1>104 .LOC = "CLB_R5C3.S0";
  X_LUT4 \vga/rom_addr_char<1>104  (
    .ADR0(\vga/vgacore/vcnt_0_1_17 ),
    .ADR1(\vga/vgacore/vcnt_1_1_8 ),
    .ADR2(N3148_0),
    .ADR3(\vga/vgacore/vcnt_2_1_9 ),
    .O(\vga/N1012345 )
  );
  defparam \vga/rom_addr_char<1>117 .INIT = 16'hAFA0;
  defparam \vga/rom_addr_char<1>117 .LOC = "CLB_R5C3.S0";
  X_LUT4 \vga/rom_addr_char<1>117  (
    .ADR0(\vga/N208_0 ),
    .ADR1(VCC),
    .ADR2(\vga/rom_addr_char [1]),
    .ADR3(\vga/N2_0 ),
    .O(\vga/N1111234 )
  );
  defparam \vga/rom_addr_char<2>_f551234/F5USED .LOC = "CLB_R5C3.S0";
  X_BUF \vga/rom_addr_char<2>_f551234/F5USED  (
    .I(\vga/rom_addr_char<2>_f551234 ),
    .O(\vga/rom_addr_char<2>_f551234_0 )
  );
  defparam \vga/rom_addr_char<2>_f5_52 .LOC = "CLB_R21C11.S1";
  X_MUX2 \vga/rom_addr_char<2>_f5_52  (
    .IA(\vga/N13123 ),
    .IB(\vga/N12123 ),
    .SEL(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f5612 )
  );
  defparam \vga/rom_addr_char<1>122 .INIT = 16'hE2E2;
  defparam \vga/rom_addr_char<1>122 .LOC = "CLB_R21C11.S1";
  X_LUT4 \vga/rom_addr_char<1>122  (
    .ADR0(\vga/N89_0 ),
    .ADR1(\vga/rom_addr_char [1]),
    .ADR2(\vga/N90_0 ),
    .ADR3(VCC),
    .O(\vga/N12123 )
  );
  defparam \vga/rom_addr_char<1>132 .INIT = 16'hE2E2;
  defparam \vga/rom_addr_char<1>132 .LOC = "CLB_R21C11.S1";
  X_LUT4 \vga/rom_addr_char<1>132  (
    .ADR0(\vga/N87_0 ),
    .ADR1(\vga/rom_addr_char [1]),
    .ADR2(\vga/N88_0 ),
    .ADR3(VCC),
    .O(\vga/N13123 )
  );
  defparam \vga/rom_addr_char<3>_f6312/YUSED .LOC = "CLB_R21C11.S1";
  X_BUF \vga/rom_addr_char<3>_f6312/YUSED  (
    .I(\vga/rom_addr_char<3>_f6312 ),
    .O(\vga/rom_addr_char<3>_f6312_0 )
  );
  defparam \vga/rom_addr_char<3>_f6_22 .LOC = "CLB_R21C11.S1";
  X_MUX2 \vga/rom_addr_char<3>_f6_22  (
    .IA(\vga/rom_addr_char<2>_f5712_0 ),
    .IB(\vga/rom_addr_char<2>_f5612 ),
    .SEL(\vga/rom_addr_char [3]),
    .O(\vga/rom_addr_char<3>_f6312 )
  );
  defparam \vga/rom_addr_char<2>_f5_53 .LOC = "CLB_R22C2.S0";
  X_MUX2 \vga/rom_addr_char<2>_f5_53  (
    .IA(\vga/N131234 ),
    .IB(\vga/N121234 ),
    .SEL(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f56123 )
  );
  defparam \vga/rom_addr_char<1>133 .INIT = 16'hF0AA;
  defparam \vga/rom_addr_char<1>133 .LOC = "CLB_R22C2.S0";
  X_LUT4 \vga/rom_addr_char<1>133  (
    .ADR0(\vga/N129_0 ),
    .ADR1(VCC),
    .ADR2(\vga/N130_0 ),
    .ADR3(\vga/rom_addr_char [1]),
    .O(\vga/N121234 )
  );
  defparam \vga/rom_addr_char<1>143 .INIT = 16'hCC0A;
  defparam \vga/rom_addr_char<1>143 .LOC = "CLB_R22C2.S0";
  X_LUT4 \vga/rom_addr_char<1>143  (
    .ADR0(\vga/vgacore/vcnt_1_1_8 ),
    .ADR1(\vga/N78_0 ),
    .ADR2(\vga/vgacore/vcnt_0_1_17 ),
    .ADR3(\vga/rom_addr_char [1]),
    .O(\vga/N131234 )
  );
  defparam \vga/rom_addr_char<2>_f56123/F5USED .LOC = "CLB_R22C2.S0";
  X_BUF \vga/rom_addr_char<2>_f56123/F5USED  (
    .I(\vga/rom_addr_char<2>_f56123 ),
    .O(\vga/rom_addr_char<2>_f56123_0 )
  );
  defparam \vga/rom_addr_char<2>_f5_61 .LOC = "CLB_R25C12.S0";
  X_MUX2 \vga/rom_addr_char<2>_f5_61  (
    .IA(\vga/N1512 ),
    .IB(\vga/N1412 ),
    .SEL(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f571 )
  );
  defparam \vga/rom_addr_char<1>141 .INIT = 16'hCCAA;
  defparam \vga/rom_addr_char<1>141 .LOC = "CLB_R25C12.S0";
  X_LUT4 \vga/rom_addr_char<1>141  (
    .ADR0(\vga/N176_0 ),
    .ADR1(\vga/N86_0 ),
    .ADR2(VCC),
    .ADR3(\vga/rom_addr_char [1]),
    .O(\vga/N1412 )
  );
  defparam \vga/rom_addr_char<1>151 .INIT = 16'hD1C0;
  defparam \vga/rom_addr_char<1>151 .LOC = "CLB_R25C12.S0";
  X_LUT4 \vga/rom_addr_char<1>151  (
    .ADR0(\vga/vgacore/vcnt_0_1_17 ),
    .ADR1(\vga/rom_addr_char [1]),
    .ADR2(\vga/N175_0 ),
    .ADR3(\vga/vgacore/vcnt_1_1_8 ),
    .O(\vga/N1512 )
  );
  defparam \vga/rom_addr_char<2>_f571/F5USED .LOC = "CLB_R25C12.S0";
  X_BUF \vga/rom_addr_char<2>_f571/F5USED  (
    .I(\vga/rom_addr_char<2>_f571 ),
    .O(\vga/rom_addr_char<2>_f571_0 )
  );
  defparam \vga/rom_addr_char<2>_f5_54 .LOC = "CLB_R3C2.S1";
  X_MUX2 \vga/rom_addr_char<2>_f5_54  (
    .IA(\vga/N1312345 ),
    .IB(\vga/N1212345 ),
    .SEL(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f561234 )
  );
  defparam \vga/rom_addr_char<1>124 .INIT = 16'hF000;
  defparam \vga/rom_addr_char<1>124 .LOC = "CLB_R3C2.S1";
  X_LUT4 \vga/rom_addr_char<1>124  (
    .ADR0(VCC),
    .ADR1(VCC),
    .ADR2(\vga/rom_addr_char [1]),
    .ADR3(\vga/N134_0 ),
    .O(\vga/N1212345 )
  );
  defparam \vga/rom_addr_char<1>134 .INIT = 16'hF5A0;
  defparam \vga/rom_addr_char<1>134 .LOC = "CLB_R3C2.S1";
  X_LUT4 \vga/rom_addr_char<1>134  (
    .ADR0(\vga/rom_addr_char [1]),
    .ADR1(VCC),
    .ADR2(\vga/N219_0 ),
    .ADR3(\vga/N218_0 ),
    .O(\vga/N1312345 )
  );
  defparam \vga/rom_addr_char<3>_f631234/YUSED .LOC = "CLB_R3C2.S1";
  X_BUF \vga/rom_addr_char<3>_f631234/YUSED  (
    .I(\vga/rom_addr_char<3>_f631234 ),
    .O(\vga/rom_addr_char<3>_f631234_0 )
  );
  defparam \vga/rom_addr_char<3>_f6_24 .LOC = "CLB_R3C2.S1";
  X_MUX2 \vga/rom_addr_char<3>_f6_24  (
    .IA(\vga/rom_addr_char<2>_f571234_0 ),
    .IB(\vga/rom_addr_char<2>_f561234 ),
    .SEL(\vga/rom_addr_char [3]),
    .O(\vga/rom_addr_char<3>_f631234 )
  );
  defparam \vga/rom_addr_char<2>_f5_62 .LOC = "CLB_R21C11.S0";
  X_MUX2 \vga/rom_addr_char<2>_f5_62  (
    .IA(\vga/N15123 ),
    .IB(\vga/N14123 ),
    .SEL(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f5712 )
  );
  defparam \vga/rom_addr_char<1>142 .INIT = 16'hFC0C;
  defparam \vga/rom_addr_char<1>142 .LOC = "CLB_R21C11.S0";
  X_LUT4 \vga/rom_addr_char<1>142  (
    .ADR0(VCC),
    .ADR1(\vga/N85_0 ),
    .ADR2(\vga/rom_addr_char [1]),
    .ADR3(\vga/N86_0 ),
    .O(\vga/N14123 )
  );
  defparam \vga/rom_addr_char<1>152 .INIT = 16'h1310;
  defparam \vga/rom_addr_char<1>152 .LOC = "CLB_R21C11.S0";
  X_LUT4 \vga/rom_addr_char<1>152  (
    .ADR0(N3172_0),
    .ADR1(\vga/vgacore/vcnt_0_1_17 ),
    .ADR2(\vga/vgacore/vcnt_2_1_9 ),
    .ADR3(\vga/vgacore/vcnt_1_1_8 ),
    .O(\vga/N15123 )
  );
  defparam \vga/rom_addr_char<2>_f5712/F5USED .LOC = "CLB_R21C11.S0";
  X_BUF \vga/rom_addr_char<2>_f5712/F5USED  (
    .I(\vga/rom_addr_char<2>_f5712 ),
    .O(\vga/rom_addr_char<2>_f5712_0 )
  );
  defparam \vga/rom_addr_char<2>_f5_63 .LOC = "CLB_R26C15.S1";
  X_MUX2 \vga/rom_addr_char<2>_f5_63  (
    .IA(\vga/N161234 ),
    .IB(\vga/N151234 ),
    .SEL(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f57123 )
  );
  defparam \vga/rom_addr_char<1>153 .INIT = 16'hDD88;
  defparam \vga/rom_addr_char<1>153 .LOC = "CLB_R26C15.S1";
  X_LUT4 \vga/rom_addr_char<1>153  (
    .ADR0(\vga/rom_addr_char [1]),
    .ADR1(\vga/N113_0 ),
    .ADR2(VCC),
    .ADR3(\vga/N82_0 ),
    .O(\vga/N151234 )
  );
  defparam \vga/rom_addr_char<1>163 .INIT = 16'hFA0A;
  defparam \vga/rom_addr_char<1>163 .LOC = "CLB_R26C15.S1";
  X_LUT4 \vga/rom_addr_char<1>163  (
    .ADR0(\vga/N110_0 ),
    .ADR1(VCC),
    .ADR2(\vga/rom_addr_char [1]),
    .ADR3(\vga/N111_0 ),
    .O(\vga/N161234 )
  );
  defparam \vga/rom_addr_char<3>_f63123/YUSED .LOC = "CLB_R26C15.S1";
  X_BUF \vga/rom_addr_char<3>_f63123/YUSED  (
    .I(\vga/rom_addr_char<3>_f63123 ),
    .O(\vga/rom_addr_char<3>_f63123_0 )
  );
  defparam \vga/rom_addr_char<3>_f6_23 .LOC = "CLB_R26C15.S1";
  X_MUX2 \vga/rom_addr_char<3>_f6_23  (
    .IA(\vga/rom_addr_char<2>_f58123_0 ),
    .IB(\vga/rom_addr_char<2>_f57123 ),
    .SEL(\vga/rom_addr_char [3]),
    .O(\vga/rom_addr_char<3>_f63123 )
  );
  defparam \vga/rom_addr_char<2>_f5_71 .LOC = "CLB_R25C13.S1";
  X_MUX2 \vga/rom_addr_char<2>_f5_71  (
    .IA(\vga/N1812 ),
    .IB(\vga/N1712 ),
    .SEL(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f581 )
  );
  defparam \vga/rom_addr_char<1>161 .INIT = 16'hF3C0;
  defparam \vga/rom_addr_char<1>161 .LOC = "CLB_R25C13.S1";
  X_LUT4 \vga/rom_addr_char<1>161  (
    .ADR0(VCC),
    .ADR1(\vga/rom_addr_char [1]),
    .ADR2(\vga/N159_0 ),
    .ADR3(\vga/N67_0 ),
    .O(\vga/N1712 )
  );
  defparam \vga/rom_addr_char<1>171 .INIT = 16'hFC0C;
  defparam \vga/rom_addr_char<1>171 .LOC = "CLB_R25C13.S1";
  X_LUT4 \vga/rom_addr_char<1>171  (
    .ADR0(VCC),
    .ADR1(\vga/N65_0 ),
    .ADR2(\vga/rom_addr_char [1]),
    .ADR3(\vga/N157_0 ),
    .O(\vga/N1812 )
  );
  defparam \vga/rom_addr_char<3>_f64/YUSED .LOC = "CLB_R25C13.S1";
  X_BUF \vga/rom_addr_char<3>_f64/YUSED  (
    .I(\vga/rom_addr_char<3>_f64_94 ),
    .O(\vga/rom_addr_char<3>_f64_0 )
  );
  defparam \vga/rom_addr_char<3>_f6_3 .LOC = "CLB_R25C13.S1";
  X_MUX2 \vga/rom_addr_char<3>_f6_3  (
    .IA(\vga/rom_addr_char<2>_f591_0 ),
    .IB(\vga/rom_addr_char<2>_f581 ),
    .SEL(\vga/rom_addr_char [3]),
    .O(\vga/rom_addr_char<3>_f64_94 )
  );
  defparam \vga/rom_addr_char<2>_f5_64 .LOC = "CLB_R3C2.S0";
  X_MUX2 \vga/rom_addr_char<2>_f5_64  (
    .IA(\vga/N1512345 ),
    .IB(\vga/N1412345 ),
    .SEL(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f571234 )
  );
  defparam \vga/rom_addr_char<1>144 .INIT = 16'hF3C0;
  defparam \vga/rom_addr_char<1>144 .LOC = "CLB_R3C2.S0";
  X_LUT4 \vga/rom_addr_char<1>144  (
    .ADR0(VCC),
    .ADR1(\vga/rom_addr_char [1]),
    .ADR2(\vga/N45_0 ),
    .ADR3(\vga/N216_0 ),
    .O(\vga/N1412345 )
  );
  defparam \vga/rom_addr_char<1>154 .INIT = 16'hBB88;
  defparam \vga/rom_addr_char<1>154 .LOC = "CLB_R3C2.S0";
  X_LUT4 \vga/rom_addr_char<1>154  (
    .ADR0(\vga/N215_0 ),
    .ADR1(\vga/rom_addr_char [1]),
    .ADR2(VCC),
    .ADR3(\vga/N214_0 ),
    .O(\vga/N1512345 )
  );
  defparam \vga/rom_addr_char<2>_f571234/F5USED .LOC = "CLB_R3C2.S0";
  X_BUF \vga/rom_addr_char<2>_f571234/F5USED  (
    .I(\vga/rom_addr_char<2>_f571234 ),
    .O(\vga/rom_addr_char<2>_f571234_0 )
  );
  defparam \vga/rom_addr_char<2>_f5_72 .LOC = "CLB_R25C15.S1";
  X_MUX2 \vga/rom_addr_char<2>_f5_72  (
    .IA(\vga/N18123 ),
    .IB(\vga/N17123 ),
    .SEL(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f5812 )
  );
  defparam \vga/rom_addr_char<1>162 .INIT = 16'hF5A0;
  defparam \vga/rom_addr_char<1>162 .LOC = "CLB_R25C15.S1";
  X_LUT4 \vga/rom_addr_char<1>162  (
    .ADR0(\vga/rom_addr_char [1]),
    .ADR1(VCC),
    .ADR2(\vga/N65_0 ),
    .ADR3(\vga/N67_0 ),
    .O(\vga/N17123 )
  );
  defparam \vga/rom_addr_char<1>172 .INIT = 16'hCCF0;
  defparam \vga/rom_addr_char<1>172 .LOC = "CLB_R25C15.S1";
  X_LUT4 \vga/rom_addr_char<1>172  (
    .ADR0(VCC),
    .ADR1(\vga/N66_0 ),
    .ADR2(\vga/N65_0 ),
    .ADR3(\vga/rom_addr_char [1]),
    .O(\vga/N18123 )
  );
  defparam \vga/rom_addr_char<3>_f641/YUSED .LOC = "CLB_R25C15.S1";
  X_BUF \vga/rom_addr_char<3>_f641/YUSED  (
    .I(\vga/rom_addr_char<3>_f641 ),
    .O(\vga/rom_addr_char<3>_f641_0 )
  );
  defparam \vga/rom_addr_char<3>_f6_31 .LOC = "CLB_R25C15.S1";
  X_MUX2 \vga/rom_addr_char<3>_f6_31  (
    .IA(\vga/rom_addr_char<2>_f5912_0 ),
    .IB(\vga/rom_addr_char<2>_f5812 ),
    .SEL(\vga/rom_addr_char [3]),
    .O(\vga/rom_addr_char<3>_f641 )
  );
  defparam \vga/rom_addr_char<2>_f5_73 .LOC = "CLB_R26C15.S0";
  X_MUX2 \vga/rom_addr_char<2>_f5_73  (
    .IA(\vga/N181234 ),
    .IB(\vga/N19123 ),
    .SEL(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f58123 )
  );
  defparam \vga/rom_addr_char<1>182 .INIT = 16'hF5A0;
  defparam \vga/rom_addr_char<1>182 .LOC = "CLB_R26C15.S0";
  X_LUT4 \vga/rom_addr_char<1>182  (
    .ADR0(\vga/rom_addr_char [1]),
    .ADR1(VCC),
    .ADR2(\vga/N64_0 ),
    .ADR3(\vga/N63_0 ),
    .O(\vga/N19123 )
  );
  defparam \vga/rom_addr_char<1>183 .INIT = 16'hCCF0;
  defparam \vga/rom_addr_char<1>183 .LOC = "CLB_R26C15.S0";
  X_LUT4 \vga/rom_addr_char<1>183  (
    .ADR0(VCC),
    .ADR1(\vga/N62_0 ),
    .ADR2(\vga/N106_0 ),
    .ADR3(\vga/rom_addr_char [1]),
    .O(\vga/N181234 )
  );
  defparam \vga/rom_addr_char<2>_f58123/F5USED .LOC = "CLB_R26C15.S0";
  X_BUF \vga/rom_addr_char<2>_f58123/F5USED  (
    .I(\vga/rom_addr_char<2>_f58123 ),
    .O(\vga/rom_addr_char<2>_f58123_0 )
  );
  defparam \vga/rom_addr_char<2>_f5_81 .LOC = "CLB_R25C13.S0";
  X_MUX2 \vga/rom_addr_char<2>_f5_81  (
    .IA(\vga/N2012 ),
    .IB(\vga/N1912 ),
    .SEL(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f591 )
  );
  defparam \vga/rom_addr_char<1>181 .INIT = 16'hACAC;
  defparam \vga/rom_addr_char<1>181 .LOC = "CLB_R25C13.S0";
  X_LUT4 \vga/rom_addr_char<1>181  (
    .ADR0(\vga/N155_0 ),
    .ADR1(\vga/N63_0 ),
    .ADR2(\vga/rom_addr_char [1]),
    .ADR3(VCC),
    .O(\vga/N1912 )
  );
  defparam \vga/rom_addr_char<1>191 .INIT = 16'hF3C0;
  defparam \vga/rom_addr_char<1>191 .LOC = "CLB_R25C13.S0";
  X_LUT4 \vga/rom_addr_char<1>191  (
    .ADR0(VCC),
    .ADR1(\vga/rom_addr_char [1]),
    .ADR2(\vga/N62_0 ),
    .ADR3(\vga/N152_0 ),
    .O(\vga/N2012 )
  );
  defparam \vga/rom_addr_char<2>_f591/F5USED .LOC = "CLB_R25C13.S0";
  X_BUF \vga/rom_addr_char<2>_f591/F5USED  (
    .I(\vga/rom_addr_char<2>_f591 ),
    .O(\vga/rom_addr_char<2>_f591_0 )
  );
  defparam \vga/rom_addr_char<2>_f5_74 .LOC = "CLB_R9C2.S1";
  X_MUX2 \vga/rom_addr_char<2>_f5_74  (
    .IA(\vga/N2012345 ),
    .IB(\vga/N1912345 ),
    .SEL(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f581234 )
  );
  defparam \vga/rom_addr_char<1>184 .INIT = 16'hE2E2;
  defparam \vga/rom_addr_char<1>184 .LOC = "CLB_R9C2.S1";
  X_LUT4 \vga/rom_addr_char<1>184  (
    .ADR0(\vga/N134_0 ),
    .ADR1(\vga/rom_addr_char [1]),
    .ADR2(\vga/N37_0 ),
    .ADR3(VCC),
    .O(\vga/N1912345 )
  );
  defparam \vga/rom_addr_char<1>194 .INIT = 16'hAFA0;
  defparam \vga/rom_addr_char<1>194 .LOC = "CLB_R9C2.S1";
  X_LUT4 \vga/rom_addr_char<1>194  (
    .ADR0(\vga/N205_0 ),
    .ADR1(VCC),
    .ADR2(\vga/rom_addr_char [1]),
    .ADR3(\vga/N35_0 ),
    .O(\vga/N2012345 )
  );
  defparam \vga/rom_addr_char<3>_f64123/YUSED .LOC = "CLB_R9C2.S1";
  X_BUF \vga/rom_addr_char<3>_f64123/YUSED  (
    .I(\vga/rom_addr_char<3>_f64123 ),
    .O(\vga/rom_addr_char<3>_f64123_0 )
  );
  defparam \vga/rom_addr_char<3>_f6_33 .LOC = "CLB_R9C2.S1";
  X_MUX2 \vga/rom_addr_char<3>_f6_33  (
    .IA(\vga/rom_addr_char<2>_f591234_0 ),
    .IB(\vga/rom_addr_char<2>_f581234 ),
    .SEL(\vga/rom_addr_char [3]),
    .O(\vga/rom_addr_char<3>_f64123 )
  );
  defparam \vga/rom_addr_char<2>_f5_82 .LOC = "CLB_R25C15.S0";
  X_MUX2 \vga/rom_addr_char<2>_f5_82  (
    .IA(\vga/N20123 ),
    .IB(N3081),
    .SEL(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f5912 )
  );
  defparam \vga/rom_addr_char<2>_f5_821 .INIT = 16'hDD88;
  defparam \vga/rom_addr_char<2>_f5_821 .LOC = "CLB_R25C15.S0";
  X_LUT4 \vga/rom_addr_char<2>_f5_821  (
    .ADR0(\vga/rom_addr_char_1_1_7 ),
    .ADR1(\vga/N64_0 ),
    .ADR2(VCC),
    .ADR3(\vga/N63_0 ),
    .O(N3081)
  );
  defparam \vga/rom_addr_char<1>192 .INIT = 16'hDD88;
  defparam \vga/rom_addr_char<1>192 .LOC = "CLB_R25C15.S0";
  X_LUT4 \vga/rom_addr_char<1>192  (
    .ADR0(\vga/rom_addr_char [1]),
    .ADR1(\vga/N62_0 ),
    .ADR2(VCC),
    .ADR3(\vga/N61_0 ),
    .O(\vga/N20123 )
  );
  defparam \vga/rom_addr_char<2>_f5912/F5USED .LOC = "CLB_R25C15.S0";
  X_BUF \vga/rom_addr_char<2>_f5912/F5USED  (
    .I(\vga/rom_addr_char<2>_f5912 ),
    .O(\vga/rom_addr_char<2>_f5912_0 )
  );
  defparam \vga/rom_addr_char<2>_f5_83 .LOC = "CLB_R26C13.S1";
  X_MUX2 \vga/rom_addr_char<2>_f5_83  (
    .IA(\vga/N201234 ),
    .IB(\vga/N191234 ),
    .SEL(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f59123 )
  );
  defparam \vga/rom_addr_char<1>193 .INIT = 16'hE4E4;
  defparam \vga/rom_addr_char<1>193 .LOC = "CLB_R26C13.S1";
  X_LUT4 \vga/rom_addr_char<1>193  (
    .ADR0(\vga/rom_addr_char [1]),
    .ADR1(\vga/N65_0 ),
    .ADR2(\vga/N120_0 ),
    .ADR3(VCC),
    .O(\vga/N191234 )
  );
  defparam \vga/rom_addr_char<1>203 .INIT = 16'hFC0C;
  defparam \vga/rom_addr_char<1>203 .LOC = "CLB_R26C13.S1";
  X_LUT4 \vga/rom_addr_char<1>203  (
    .ADR0(VCC),
    .ADR1(\vga/N117_0 ),
    .ADR2(\vga/rom_addr_char_1_1_7 ),
    .ADR3(\vga/N118_0 ),
    .O(\vga/N201234 )
  );
  defparam \vga/rom_addr_char<3>_f6412/YUSED .LOC = "CLB_R26C13.S1";
  X_BUF \vga/rom_addr_char<3>_f6412/YUSED  (
    .I(\vga/rom_addr_char<3>_f6412 ),
    .O(\vga/rom_addr_char<3>_f6412_0 )
  );
  defparam \vga/rom_addr_char<3>_f6_32 .LOC = "CLB_R26C13.S1";
  X_MUX2 \vga/rom_addr_char<3>_f6_32  (
    .IA(\vga/rom_addr_char<2>_f51012_0 ),
    .IB(\vga/rom_addr_char<2>_f59123 ),
    .SEL(\vga/rom_addr_char [3]),
    .O(\vga/rom_addr_char<3>_f6412 )
  );
  defparam \vga/rom_addr_char<2>_f5_91 .LOC = "CLB_R27C12.S1";
  X_MUX2 \vga/rom_addr_char<2>_f5_91  (
    .IA(\vga/N22123 ),
    .IB(\vga/N21123 ),
    .SEL(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f5101 )
  );
  defparam \vga/rom_addr_char<1>202 .INIT = 16'hCCF0;
  defparam \vga/rom_addr_char<1>202 .LOC = "CLB_R27C12.S1";
  X_LUT4 \vga/rom_addr_char<1>202  (
    .ADR0(VCC),
    .ADR1(\vga/N75_0 ),
    .ADR2(\vga/N74_0 ),
    .ADR3(\vga/rom_addr_char [1]),
    .O(\vga/N21123 )
  );
  defparam \vga/rom_addr_char<1>212 .INIT = 16'hF0AA;
  defparam \vga/rom_addr_char<1>212 .LOC = "CLB_R27C12.S1";
  X_LUT4 \vga/rom_addr_char<1>212  (
    .ADR0(\vga/N72_0 ),
    .ADR1(VCC),
    .ADR2(\vga/N73_0 ),
    .ADR3(\vga/rom_addr_char_1_1_7 ),
    .O(\vga/N22123 )
  );
  defparam \vga/rom_addr_char<3>_f651/YUSED .LOC = "CLB_R27C12.S1";
  X_BUF \vga/rom_addr_char<3>_f651/YUSED  (
    .I(\vga/rom_addr_char<3>_f651 ),
    .O(\vga/rom_addr_char<3>_f651_0 )
  );
  defparam \vga/rom_addr_char<3>_f6_41 .LOC = "CLB_R27C12.S1";
  X_MUX2 \vga/rom_addr_char<3>_f6_41  (
    .IA(\vga/rom_addr_char<2>_f51112_0 ),
    .IB(\vga/rom_addr_char<2>_f5101 ),
    .SEL(\vga/rom_addr_char [3]),
    .O(\vga/rom_addr_char<3>_f651 )
  );
  defparam \vga/rom_addr_char<2>_f5_84 .LOC = "CLB_R9C2.S0";
  X_MUX2 \vga/rom_addr_char<2>_f5_84  (
    .IA(\vga/N2212345 ),
    .IB(\vga/N1511 ),
    .SEL(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f591234 )
  );
  defparam \vga/rom_addr_char<1>14 .INIT = 16'hB8B8;
  defparam \vga/rom_addr_char<1>14 .LOC = "CLB_R9C2.S0";
  X_LUT4 \vga/rom_addr_char<1>14  (
    .ADR0(\vga/N34_0 ),
    .ADR1(\vga/rom_addr_char [1]),
    .ADR2(\vga/N33_0 ),
    .ADR3(VCC),
    .O(\vga/N1511 )
  );
  defparam \vga/rom_addr_char<1>214 .INIT = 16'hD8D8;
  defparam \vga/rom_addr_char<1>214 .LOC = "CLB_R9C2.S0";
  X_LUT4 \vga/rom_addr_char<1>214  (
    .ADR0(\vga/rom_addr_char_1_1_7 ),
    .ADR1(\vga/N201_0 ),
    .ADR2(\vga/N30_0 ),
    .ADR3(VCC),
    .O(\vga/N2212345 )
  );
  defparam \vga/rom_addr_char<2>_f591234/F5USED .LOC = "CLB_R9C2.S0";
  X_BUF \vga/rom_addr_char<2>_f591234/F5USED  (
    .I(\vga/rom_addr_char<2>_f591234 ),
    .O(\vga/rom_addr_char<2>_f591234_0 )
  );
  defparam \vga/rom_addr_char<2>_f5_92 .LOC = "CLB_R26C13.S0";
  X_MUX2 \vga/rom_addr_char<2>_f5_92  (
    .IA(\vga/N221234 ),
    .IB(\vga/N211234 ),
    .SEL(\vga/rom_addr_char [2]),
    .O(\vga/rom_addr_char<2>_f51012 )
  );
  defparam \vga/rom_addr_char<1>213 .INIT = 16'hCFC0;
  defparam \vga/rom_addr_char<1>213 .LOC = "CLB_R26C13.S0";
  X_LUT4 \vga/rom_addr_char<1>213  (
    .ADR0(VCC),
    .ADR1(\vga/N116_0 ),
    .ADR2(\vga/rom_addr_char_1_1_7 ),
    .ADR3(\vga/N115_0 ),
    .O(\vga/N211234 )
  );
  defparam \vga/rom_addr_char<1>222 .INIT = 16'hE4E4;
  defparam \vga/rom_addr_char<1>222 .LOC = "CLB_R26C13.S0";
  X_LUT4 \vga/rom_addr_char<1>222  (
    .ADR0(\vga/rom_addr_char_1_1_7 ),
    .ADR1(\vga/N114_0 ),
    .ADR2(\vga/N64_0 ),
    .ADR3(VCC),
    .O(\vga/N221234 )
  );
  defparam \vga/rom_addr_char<2>_f51012/F5USED .LOC = "CLB_R26C13.S0";
  X_BUF \vga/rom_addr_char<2>_f51012/F5USED  (
    .I(\vga/rom_addr_char<2>_f51012 ),
    .O(\vga/rom_addr_char<2>_f51012_0 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<3>1217_f5 .LOC = "CLB_R18C34.S1";
  X_MUX2 \vga/scancode_convert/scancode_rom/data<3>1217_f5  (
    .IA(N3265),
    .IB(N3264),
    .SEL(\vga/scancode_convert/sc [4]),
    .O(\vga/scancode_convert/scancode_rom/data<3>1_map1201 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<3>12171 .INIT = 16'hFCCC;
  defparam \vga/scancode_convert/scancode_rom/data<3>12171 .LOC = "CLB_R18C34.S1";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<3>12171  (
    .ADR0(VCC),
    .ADR1(\vga/scancode_convert/sc [2]),
    .ADR2(\vga/scancode_convert/sc [1]),
    .ADR3(\vga/scancode_convert/sc [3]),
    .O(N3264)
  );
  defparam \vga/scancode_convert/scancode_rom/data<3>12172 .INIT = 16'hFFFC;
  defparam \vga/scancode_convert/scancode_rom/data<3>12172 .LOC = "CLB_R18C34.S1";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<3>12172  (
    .ADR0(VCC),
    .ADR1(\vga/scancode_convert/sc [2]),
    .ADR2(\vga/scancode_convert/sc [1]),
    .ADR3(\vga/scancode_convert/sc [0]),
    .O(N3265)
  );
  defparam \vga/scancode_convert/scancode_rom/data<3>1_map1201/XUSED .LOC = "CLB_R18C34.S1";
  X_BUF \vga/scancode_convert/scancode_rom/data<3>1_map1201/XUSED  (
    .I(\vga/scancode_convert/scancode_rom/data<3>1_map1201 ),
    .O(\vga/scancode_convert/scancode_rom/data<3>1_map1201_0 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<5>3159_SW0 .LOC = "CLB_R12C33.S1";
  X_MUX2 \vga/scancode_convert/scancode_rom/data<5>3159_SW0  (
    .IA(N3212),
    .IB(N3213),
    .SEL(\vga/scancode_convert/sc [2]),
    .O(N3112)
  );
  defparam \vga/scancode_convert/scancode_rom/data<5>3159_SW0_G .INIT = 16'h3F55;
  defparam \vga/scancode_convert/scancode_rom/data<5>3159_SW0_G .LOC = "CLB_R12C33.S1";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<5>3159_SW0_G  (
    .ADR0(\vga/scancode_convert/scancode_rom/data<5>3_map1245_0 ),
    .ADR1(\vga/scancode_convert/scancode_rom/data<5>3_map1260_0 ),
    .ADR2(\vga/scancode_convert/scancode_rom/data<5>3_map1249_0 ),
    .ADR3(\vga/scancode_convert/sc [3]),
    .O(N3213)
  );
  defparam \vga/scancode_convert/scancode_rom/data<5>3159_SW0_F .INIT = 16'hDFDF;
  defparam \vga/scancode_convert/scancode_rom/data<5>3159_SW0_F .LOC = "CLB_R12C33.S1";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<5>3159_SW0_F  (
    .ADR0(\vga/scancode_convert/sc [3]),
    .ADR1(\vga/scancode_convert/scancode_rom/N12 ),
    .ADR2(\vga/scancode_convert/sc [4]),
    .ADR3(VCC),
    .O(N3212)
  );
  defparam \N3112/XUSED .LOC = "CLB_R12C33.S1";
  X_BUF \N3112/XUSED  (
    .I(N3112),
    .O(N3112_0)
  );
  defparam \vga/ram_addr_write<5>/LOGIC_ZERO .LOC = "CLB_R16C10.S1";
  X_ZERO \vga/ram_addr_write<5>/LOGIC_ZERO  (
    .O(\vga/ram_addr_write<5>/LOGIC_ZERO_95 )
  );
  defparam \vga/crt/Madd_ram_addr_Madd_cy<5> .LOC = "CLB_R16C10.S1";
  X_MUX2 \vga/crt/Madd_ram_addr_Madd_cy<5>  (
    .IA(\vga/crt/Madd_ram_addrC_mand1 ),
    .IB(\vga/ram_addr_write<5>/LOGIC_ZERO_95 ),
    .SEL(\vga/ram_addr_write [5]),
    .O(\vga/crt/Madd_ram_addr_Madd_cy[5] )
  );
  defparam \vga/crt/Madd_ram_addrC_mand .LOC = "CLB_R16C10.S1";
  X_AND2 \vga/crt/Madd_ram_addrC_mand  (
    .I0(\vga/crt/cursor_v [0]),
    .I1(\vga/crt/cursor_h [4]),
    .O(\vga/crt/Madd_ram_addrC_mand1 )
  );
  defparam \vga/crt/Madd_ram_addr_Madd_lut<5> .INIT = 16'h8778;
  defparam \vga/crt/Madd_ram_addr_Madd_lut<5> .LOC = "CLB_R16C10.S1";
  X_LUT4 \vga/crt/Madd_ram_addr_Madd_lut<5>  (
    .ADR0(\vga/crt/cursor_h [4]),
    .ADR1(\vga/crt/cursor_v [0]),
    .ADR2(\vga/crt/cursor_h [5]),
    .ADR3(\vga/crt/cursor_v [1]),
    .O(\vga/ram_addr_write [5])
  );
  defparam \vga/crt/Madd_ram_addr_Madd_lut<6> .INIT = 16'h7788;
  defparam \vga/crt/Madd_ram_addr_Madd_lut<6> .LOC = "CLB_R16C10.S1";
  X_LUT4 \vga/crt/Madd_ram_addr_Madd_lut<6>  (
    .ADR0(\vga/crt/cursor_h [5]),
    .ADR1(\vga/crt/cursor_v [1]),
    .ADR2(VCC),
    .ADR3(\vga/crt/Madd_ram_addrR2_0 ),
    .O(\vga/crt/N8 )
  );
  defparam \vga/ram_addr_write<5>/XUSED .LOC = "CLB_R16C10.S1";
  X_BUF \vga/ram_addr_write<5>/XUSED  (
    .I(\vga/ram_addr_write [5]),
    .O(\vga/ram_addr_write<5>_0 )
  );
  defparam \vga/ram_addr_write<5>/YUSED .LOC = "CLB_R16C10.S1";
  X_BUF \vga/ram_addr_write<5>/YUSED  (
    .I(\vga/ram_addr_write [6]),
    .O(\vga/ram_addr_write<6>_0 )
  );
  defparam \vga/crt/Madd_ram_addrC1_mand .LOC = "CLB_R16C10.S1";
  X_AND2 \vga/crt/Madd_ram_addrC1_mand  (
    .I0(\vga/crt/cursor_v [1]),
    .I1(\vga/crt/cursor_h [5]),
    .O(\vga/crt/Madd_ram_addrC1_mand1 )
  );
  defparam \vga/crt/Madd_ram_addr_Madd_cy<6> .LOC = "CLB_R16C10.S1";
  X_MUX2 \vga/crt/Madd_ram_addr_Madd_cy<6>  (
    .IA(\vga/crt/Madd_ram_addrC1_mand1 ),
    .IB(\vga/crt/Madd_ram_addr_Madd_cy[5] ),
    .SEL(\vga/crt/N8 ),
    .O(\vga/ram_addr_write<5>/CYMUXG )
  );
  defparam \vga/crt/Madd_ram_addr_Madd_xor<6> .LOC = "CLB_R16C10.S1";
  X_XOR2 \vga/crt/Madd_ram_addr_Madd_xor<6>  (
    .I0(\vga/crt/Madd_ram_addr_Madd_cy[5] ),
    .I1(\vga/crt/N8 ),
    .O(\vga/ram_addr_write [6])
  );
  defparam \vga/crt/Madd_ram_addr_Madd_cy<8> .LOC = "CLB_R14C10.S1";
  X_MUX2 \vga/crt/Madd_ram_addr_Madd_cy<8>  (
    .IA(\vga/crt/Madd_ram_addrC3_mand1 ),
    .IB(\vga/ram_addr_write<8>/CYINIT_96 ),
    .SEL(\vga/crt/N10 ),
    .O(\vga/crt/Madd_ram_addr_Madd_cy[8] )
  );
  defparam \vga/crt/Madd_ram_addr_Madd_xor<8> .LOC = "CLB_R14C10.S1";
  X_XOR2 \vga/crt/Madd_ram_addr_Madd_xor<8>  (
    .I0(\vga/ram_addr_write<8>/CYINIT_96 ),
    .I1(\vga/crt/N10 ),
    .O(\vga/ram_addr_write [8])
  );
  defparam \vga/crt/Madd_ram_addrC3_mand .LOC = "CLB_R14C10.S1";
  X_AND2 \vga/crt/Madd_ram_addrC3_mand  (
    .I0(\vga/crt/cursor_v [3]),
    .I1(\vga/crt/cursor_v [1]),
    .O(\vga/crt/Madd_ram_addrC3_mand1 )
  );
  defparam \vga/crt/Madd_ram_addr_Madd_lut<8> .INIT = 16'h8778;
  defparam \vga/crt/Madd_ram_addr_Madd_lut<8> .LOC = "CLB_R14C10.S1";
  X_LUT4 \vga/crt/Madd_ram_addr_Madd_lut<8>  (
    .ADR0(\vga/crt/cursor_v [1]),
    .ADR1(\vga/crt/cursor_v [3]),
    .ADR2(\vga/crt/cursor_v [4]),
    .ADR3(\vga/crt/cursor_v [2]),
    .O(\vga/crt/N10 )
  );
  defparam \vga/crt/Madd_ram_addr_Madd_lut<9> .INIT = 16'h8778;
  defparam \vga/crt/Madd_ram_addr_Madd_lut<9> .LOC = "CLB_R14C10.S1";
  X_LUT4 \vga/crt/Madd_ram_addr_Madd_lut<9>  (
    .ADR0(\vga/crt/cursor_v [2]),
    .ADR1(\vga/crt/cursor_v [4]),
    .ADR2(\vga/crt/cursor_v [3]),
    .ADR3(\vga/crt/cursor_v [5]),
    .O(\vga/crt/N11 )
  );
  defparam \vga/ram_addr_write<8>/XUSED .LOC = "CLB_R14C10.S1";
  X_BUF \vga/ram_addr_write<8>/XUSED  (
    .I(\vga/ram_addr_write [8]),
    .O(\vga/ram_addr_write<8>_0 )
  );
  defparam \vga/ram_addr_write<8>/YUSED .LOC = "CLB_R14C10.S1";
  X_BUF \vga/ram_addr_write<8>/YUSED  (
    .I(\vga/ram_addr_write [9]),
    .O(\vga/ram_addr_write<9>_0 )
  );
  defparam \vga/crt/Madd_ram_addrC4_mand .LOC = "CLB_R14C10.S1";
  X_AND2 \vga/crt/Madd_ram_addrC4_mand  (
    .I0(\vga/crt/cursor_v [4]),
    .I1(\vga/crt/cursor_v [2]),
    .O(\vga/crt/Madd_ram_addrC4_mand1 )
  );
  defparam \vga/crt/Madd_ram_addr_Madd_cy<9> .LOC = "CLB_R14C10.S1";
  X_MUX2 \vga/crt/Madd_ram_addr_Madd_cy<9>  (
    .IA(\vga/crt/Madd_ram_addrC4_mand1 ),
    .IB(\vga/crt/Madd_ram_addr_Madd_cy[8] ),
    .SEL(\vga/crt/N11 ),
    .O(\vga/ram_addr_write<8>/CYMUXG )
  );
  defparam \vga/crt/Madd_ram_addr_Madd_xor<9> .LOC = "CLB_R14C10.S1";
  X_XOR2 \vga/crt/Madd_ram_addr_Madd_xor<9>  (
    .I0(\vga/crt/Madd_ram_addr_Madd_cy[8] ),
    .I1(\vga/crt/N11 ),
    .O(\vga/ram_addr_write [9])
  );
  defparam \vga/ram_addr_write<8>/CYINIT .LOC = "CLB_R14C10.S1";
  X_BUF \vga/ram_addr_write<8>/CYINIT  (
    .I(\vga/ram_addr_write<7>/CYMUXG ),
    .O(\vga/ram_addr_write<8>/CYINIT_96 )
  );
  defparam \vga/crt/Madd_ram_addr_Madd_cy<10> .LOC = "CLB_R13C10.S1";
  X_MUX2 \vga/crt/Madd_ram_addr_Madd_cy<10>  (
    .IA(\vga/crt/cursor_v [4]),
    .IB(\vga/ram_addr_write<10>/CYINIT_98 ),
    .SEL(\vga/crt/N12 ),
    .O(\vga/crt/Madd_ram_addr_Madd_cy[10] )
  );
  defparam \vga/crt/Madd_ram_addr_Madd_xor<10> .LOC = "CLB_R13C10.S1";
  X_XOR2 \vga/crt/Madd_ram_addr_Madd_xor<10>  (
    .I0(\vga/ram_addr_write<10>/CYINIT_98 ),
    .I1(\vga/crt/N12 ),
    .O(\vga/ram_addr_write [10])
  );
  defparam \vga/crt/Madd_ram_addr_Madd_lut<10> .INIT = 16'h66AA;
  defparam \vga/crt/Madd_ram_addr_Madd_lut<10> .LOC = "CLB_R13C10.S1";
  X_LUT4 \vga/crt/Madd_ram_addr_Madd_lut<10>  (
    .ADR0(\vga/crt/cursor_v [4]),
    .ADR1(\vga/crt/cursor_v [3]),
    .ADR2(VCC),
    .ADR3(\vga/crt/cursor_v [5]),
    .O(\vga/crt/N12 )
  );
  defparam \vga/crt/cursor_v<5>_rt .INIT = 16'hAAAA;
  defparam \vga/crt/cursor_v<5>_rt .LOC = "CLB_R13C10.S1";
  X_LUT4 \vga/crt/cursor_v<5>_rt  (
    .ADR0(\vga/crt/cursor_v [5]),
    .ADR1(VCC),
    .ADR2(VCC),
    .ADR3(VCC),
    .O(\vga/crt/cursor_v<5>_rt_97 )
  );
  defparam \vga/ram_addr_write<10>/XUSED .LOC = "CLB_R13C10.S1";
  X_BUF \vga/ram_addr_write<10>/XUSED  (
    .I(\vga/ram_addr_write [10]),
    .O(\vga/ram_addr_write<10>_0 )
  );
  defparam \vga/ram_addr_write<10>/YUSED .LOC = "CLB_R13C10.S1";
  X_BUF \vga/ram_addr_write<10>/YUSED  (
    .I(\vga/ram_addr_write [11]),
    .O(\vga/ram_addr_write<11>_0 )
  );
  defparam \vga/crt/Madd_ram_addr_Madd_xor<11> .LOC = "CLB_R13C10.S1";
  X_XOR2 \vga/crt/Madd_ram_addr_Madd_xor<11>  (
    .I0(\vga/crt/Madd_ram_addr_Madd_cy[10] ),
    .I1(\vga/crt/cursor_v<5>_rt_97 ),
    .O(\vga/ram_addr_write [11])
  );
  defparam \vga/ram_addr_write<10>/CYINIT .LOC = "CLB_R13C10.S1";
  X_BUF \vga/ram_addr_write<10>/CYINIT  (
    .I(\vga/ram_addr_write<8>/CYMUXG ),
    .O(\vga/ram_addr_write<10>/CYINIT_98 )
  );
  defparam \vga/vgacore/Mcompar__cmp_lt0000_cy<1>/LOGIC_ONE .LOC = "CLB_R18C7.S0";
  X_ONE \vga/vgacore/Mcompar__cmp_lt0000_cy<1>/LOGIC_ONE  (
    .O(\vga/vgacore/Mcompar__cmp_lt0000_cy<1>/LOGIC_ONE_101 )
  );
  defparam \vga/vgacore/Mcompar__cmp_lt0000_cy<1>/LOGIC_ZERO .LOC = "CLB_R18C7.S0";
  X_ZERO \vga/vgacore/Mcompar__cmp_lt0000_cy<1>/LOGIC_ZERO  (
    .O(\vga/vgacore/Mcompar__cmp_lt0000_cy<1>/LOGIC_ZERO_100 )
  );
  defparam \vga/vgacore/Mcompar__cmp_lt0000_cy<0> .LOC = "CLB_R18C7.S0";
  X_MUX2 \vga/vgacore/Mcompar__cmp_lt0000_cy<0>  (
    .IA(\vga/vgacore/Mcompar__cmp_lt0000_cy<1>/LOGIC_ZERO_100 ),
    .IB(\vga/vgacore/Mcompar__cmp_lt0000_cy<1>/LOGIC_ONE_101 ),
    .SEL(\vga/vgacore/N4 ),
    .O(\vga/vgacore/Mcompar__cmp_lt0000_cy[0] )
  );
  defparam \vga/vgacore/Mcompar__cmp_lt0000_lut<0> .INIT = 16'h8000;
  defparam \vga/vgacore/Mcompar__cmp_lt0000_lut<0> .LOC = "CLB_R18C7.S0";
  X_LUT4 \vga/vgacore/Mcompar__cmp_lt0000_lut<0>  (
    .ADR0(\vga/vgacore/hcnt [1]),
    .ADR1(\vga/vgacore/hcnt [3]),
    .ADR2(\vga/vgacore/hcnt [0]),
    .ADR3(\vga/vgacore/hcnt [2]),
    .O(\vga/vgacore/N4 )
  );
  defparam \vga/vgacore/hcnt<4>_rt .INIT = 16'hF0F0;
  defparam \vga/vgacore/hcnt<4>_rt .LOC = "CLB_R18C7.S0";
  X_LUT4 \vga/vgacore/hcnt<4>_rt  (
    .ADR0(VCC),
    .ADR1(VCC),
    .ADR2(\vga/vgacore/hcnt [4]),
    .ADR3(VCC),
    .O(\vga/vgacore/hcnt<4>_rt_99 )
  );
  defparam \vga/vgacore/Mcompar__cmp_lt0000_cy<1> .LOC = "CLB_R18C7.S0";
  X_MUX2 \vga/vgacore/Mcompar__cmp_lt0000_cy<1>  (
    .IA(\vga/vgacore/Mcompar__cmp_lt0000_cy<1>/LOGIC_ZERO_100 ),
    .IB(\vga/vgacore/Mcompar__cmp_lt0000_cy[0] ),
    .SEL(\vga/vgacore/hcnt<4>_rt_99 ),
    .O(\vga/vgacore/Mcompar__cmp_lt0000_cy<1>/CYMUXG )
  );
  defparam \vga/vgacore/Mcompar__cmp_lt0000_cy<2> .LOC = "CLB_R17C7.S0";
  X_MUX2 \vga/vgacore/Mcompar__cmp_lt0000_cy<2>  (
    .IA(GLOBAL_LOGIC1),
    .IB(\vga/vgacore/Mcompar__cmp_lt0000_cy<3>/CYINIT_102 ),
    .SEL(\vga/vgacore/N5 ),
    .O(\vga/vgacore/Mcompar__cmp_lt0000_cy[2] )
  );
  defparam \vga/vgacore/Mcompar__cmp_lt0000_lut<2> .INIT = 16'h0003;
  defparam \vga/vgacore/Mcompar__cmp_lt0000_lut<2> .LOC = "CLB_R17C7.S0";
  X_LUT4 \vga/vgacore/Mcompar__cmp_lt0000_lut<2>  (
    .ADR0(GLOBAL_LOGIC1),
    .ADR1(\vga/vgacore/hcnt [6]),
    .ADR2(\vga/vgacore/hcnt [5]),
    .ADR3(\vga/vgacore/hcnt [7]),
    .O(\vga/vgacore/N5 )
  );
  defparam \vga/vgacore/Mcompar__cmp_lt0000_lut<3> .INIT = 16'hF000;
  defparam \vga/vgacore/Mcompar__cmp_lt0000_lut<3> .LOC = "CLB_R17C7.S0";
  X_LUT4 \vga/vgacore/Mcompar__cmp_lt0000_lut<3>  (
    .ADR0(GLOBAL_LOGIC0),
    .ADR1(VCC),
    .ADR2(\vga/vgacore/hcnt [8]),
    .ADR3(\vga/vgacore/hcnt [9]),
    .O(\vga/vgacore/N6 )
  );
  defparam \vga/vgacore/Mcompar__cmp_lt0000_cy<3> .LOC = "CLB_R17C7.S0";
  X_MUX2 \vga/vgacore/Mcompar__cmp_lt0000_cy<3>  (
    .IA(GLOBAL_LOGIC0),
    .IB(\vga/vgacore/Mcompar__cmp_lt0000_cy[2] ),
    .SEL(\vga/vgacore/N6 ),
    .O(\vga/vgacore/Mcompar__cmp_lt0000_cy<3>/CYMUXG )
  );
  defparam \vga/vgacore/Mcompar__cmp_lt0000_cy<3>/CYINIT .LOC = "CLB_R17C7.S0";
  X_BUF \vga/vgacore/Mcompar__cmp_lt0000_cy<3>/CYINIT  (
    .I(\vga/vgacore/Mcompar__cmp_lt0000_cy<1>/CYMUXG ),
    .O(\vga/vgacore/Mcompar__cmp_lt0000_cy<3>/CYINIT_102 )
  );
  defparam \vga/vgacore/hblank/LOGIC_ONE .LOC = "CLB_R16C7.S0";
  X_ONE \vga/vgacore/hblank/LOGIC_ONE  (
    .O(\vga/vgacore/hblank/LOGIC_ONE_103 )
  );
  defparam \vga/vgacore/Mcompar__cmp_lt0000_cy<4> .LOC = "CLB_R16C7.S0";
  X_MUX2 \vga/vgacore/Mcompar__cmp_lt0000_cy<4>  (
    .IA(\vga/vgacore/hblank/LOGIC_ONE_103 ),
    .IB(\vga/vgacore/hblank/CYINIT_104 ),
    .SEL(\vga/vgacore/N7 ),
    .O(\vga/vgacore/Mcompar__cmp_lt0000_cy[4] )
  );
  defparam \vga/vgacore/Mcompar__cmp_lt0000_lut<4>_INV_0 .INIT = 16'h00FF;
  defparam \vga/vgacore/Mcompar__cmp_lt0000_lut<4>_INV_0 .LOC = "CLB_R16C7.S0";
  X_LUT4 \vga/vgacore/Mcompar__cmp_lt0000_lut<4>_INV_0  (
    .ADR0(VCC),
    .ADR1(VCC),
    .ADR2(VCC),
    .ADR3(\vga/vgacore/hcnt [10]),
    .O(\vga/vgacore/N7 )
  );
  defparam \vga/vgacore/_mux00021 .INIT = 16'hFEF0;
  defparam \vga/vgacore/_mux00021 .LOC = "CLB_R16C7.S0";
  X_LUT4 \vga/vgacore/_mux00021  (
    .ADR0(\vga/vgacore/hcnt [7]),
    .ADR1(\vga/vgacore/hcnt [8]),
    .ADR2(\vga/vgacore/hcnt [10]),
    .ADR3(\vga/vgacore/hcnt [9]),
    .O(\vga/vgacore/_mux0002 )
  );
  defparam \vga/vgacore/hblank/XBUSED .LOC = "CLB_R16C7.S0";
  X_BUF \vga/vgacore/hblank/XBUSED  (
    .I(\vga/vgacore/Mcompar__cmp_lt0000_cy[4] ),
    .O(\vga/vgacore/Mcompar__cmp_lt0000_cy<4>_0 )
  );
  defparam \vga/vgacore/hblank/CYINIT .LOC = "CLB_R16C7.S0";
  X_BUF \vga/vgacore/hblank/CYINIT  (
    .I(\vga/vgacore/Mcompar__cmp_lt0000_cy<3>/CYMUXG ),
    .O(\vga/vgacore/hblank/CYINIT_104 )
  );
  defparam \vga/ram_addr_video<5>/LOGIC_ZERO .LOC = "CLB_R17C5.S0";
  X_ZERO \vga/ram_addr_video<5>/LOGIC_ZERO  (
    .O(\vga/ram_addr_video<5>/LOGIC_ZERO_105 )
  );
  defparam \vga/Madd_ram_addr_video_Madd_cy<5> .LOC = "CLB_R17C5.S0";
  X_MUX2 \vga/Madd_ram_addr_video_Madd_cy<5>  (
    .IA(\vga/Madd_ram_addr_videoC_mand1 ),
    .IB(\vga/ram_addr_video<5>/LOGIC_ZERO_105 ),
    .SEL(\vga/ram_addr_video [5]),
    .O(\vga/Madd_ram_addr_video_Madd_cy[5] )
  );
  defparam \vga/Madd_ram_addr_videoC_mand .LOC = "CLB_R17C5.S0";
  X_AND2 \vga/Madd_ram_addr_videoC_mand  (
    .I0(\vga/vgacore/vcnt [3]),
    .I1(\vga/vgacore/hcnt [7]),
    .O(\vga/Madd_ram_addr_videoC_mand1 )
  );
  defparam \vga/Madd_ram_addr_video_Madd_lut<5> .INIT = 16'h8778;
  defparam \vga/Madd_ram_addr_video_Madd_lut<5> .LOC = "CLB_R17C5.S0";
  X_LUT4 \vga/Madd_ram_addr_video_Madd_lut<5>  (
    .ADR0(\vga/vgacore/hcnt [7]),
    .ADR1(\vga/vgacore/vcnt [3]),
    .ADR2(\vga/vgacore/vcnt [4]),
    .ADR3(\vga/vgacore/hcnt [8]),
    .O(\vga/ram_addr_video [5])
  );
  defparam \vga/Madd_ram_addr_video_Madd_lut<6> .INIT = 16'h7878;
  defparam \vga/Madd_ram_addr_video_Madd_lut<6> .LOC = "CLB_R17C5.S0";
  X_LUT4 \vga/Madd_ram_addr_video_Madd_lut<6>  (
    .ADR0(\vga/vgacore/hcnt [8]),
    .ADR1(\vga/vgacore/vcnt [4]),
    .ADR2(\vga/Madd_ram_addr_videoR2_0 ),
    .ADR3(VCC),
    .O(\vga/N229 )
  );
  defparam \vga/ram_addr_video<5>/XUSED .LOC = "CLB_R17C5.S0";
  X_BUF \vga/ram_addr_video<5>/XUSED  (
    .I(\vga/ram_addr_video [5]),
    .O(\vga/ram_addr_video<5>_0 )
  );
  defparam \vga/ram_addr_video<5>/YUSED .LOC = "CLB_R17C5.S0";
  X_BUF \vga/ram_addr_video<5>/YUSED  (
    .I(\vga/ram_addr_video [6]),
    .O(\vga/ram_addr_video<6>_0 )
  );
  defparam \vga/Madd_ram_addr_videoC1_mand .LOC = "CLB_R17C5.S0";
  X_AND2 \vga/Madd_ram_addr_videoC1_mand  (
    .I0(\vga/vgacore/vcnt [4]),
    .I1(\vga/vgacore/hcnt [8]),
    .O(\vga/Madd_ram_addr_videoC1_mand1 )
  );
  defparam \vga/Madd_ram_addr_video_Madd_cy<6> .LOC = "CLB_R17C5.S0";
  X_MUX2 \vga/Madd_ram_addr_video_Madd_cy<6>  (
    .IA(\vga/Madd_ram_addr_videoC1_mand1 ),
    .IB(\vga/Madd_ram_addr_video_Madd_cy[5] ),
    .SEL(\vga/N229 ),
    .O(\vga/ram_addr_video<5>/CYMUXG )
  );
  defparam \vga/Madd_ram_addr_video_Madd_xor<6> .LOC = "CLB_R17C5.S0";
  X_XOR2 \vga/Madd_ram_addr_video_Madd_xor<6>  (
    .I0(\vga/Madd_ram_addr_video_Madd_cy[5] ),
    .I1(\vga/N229 ),
    .O(\vga/ram_addr_video [6])
  );
  defparam \vga/Madd_ram_addr_video_Madd_cy<8> .LOC = "CLB_R15C5.S0";
  X_MUX2 \vga/Madd_ram_addr_video_Madd_cy<8>  (
    .IA(\vga/Madd_ram_addr_videoC3_mand1 ),
    .IB(\vga/ram_addr_video<8>/CYINIT_106 ),
    .SEL(\vga/N2313 ),
    .O(\vga/Madd_ram_addr_video_Madd_cy[8] )
  );
  defparam \vga/Madd_ram_addr_video_Madd_xor<8> .LOC = "CLB_R15C5.S0";
  X_XOR2 \vga/Madd_ram_addr_video_Madd_xor<8>  (
    .I0(\vga/ram_addr_video<8>/CYINIT_106 ),
    .I1(\vga/N2313 ),
    .O(\vga/ram_addr_video [8])
  );
  defparam \vga/Madd_ram_addr_videoC3_mand .LOC = "CLB_R15C5.S0";
  X_AND2 \vga/Madd_ram_addr_videoC3_mand  (
    .I0(\vga/vgacore/vcnt [6]),
    .I1(\vga/vgacore/vcnt [4]),
    .O(\vga/Madd_ram_addr_videoC3_mand1 )
  );
  defparam \vga/Madd_ram_addr_video_Madd_lut<8> .INIT = 16'h8778;
  defparam \vga/Madd_ram_addr_video_Madd_lut<8> .LOC = "CLB_R15C5.S0";
  X_LUT4 \vga/Madd_ram_addr_video_Madd_lut<8>  (
    .ADR0(\vga/vgacore/vcnt [4]),
    .ADR1(\vga/vgacore/vcnt [6]),
    .ADR2(\vga/vgacore/vcnt [7]),
    .ADR3(\vga/vgacore/vcnt [5]),
    .O(\vga/N2313 )
  );
  defparam \vga/Madd_ram_addr_video_Madd_lut<9> .INIT = 16'h8778;
  defparam \vga/Madd_ram_addr_video_Madd_lut<9> .LOC = "CLB_R15C5.S0";
  X_LUT4 \vga/Madd_ram_addr_video_Madd_lut<9>  (
    .ADR0(\vga/vgacore/vcnt [5]),
    .ADR1(\vga/vgacore/vcnt [7]),
    .ADR2(\vga/vgacore/vcnt [8]),
    .ADR3(\vga/vgacore/vcnt [6]),
    .O(\vga/N232 )
  );
  defparam \vga/ram_addr_video<8>/XUSED .LOC = "CLB_R15C5.S0";
  X_BUF \vga/ram_addr_video<8>/XUSED  (
    .I(\vga/ram_addr_video [8]),
    .O(\vga/ram_addr_video<8>_0 )
  );
  defparam \vga/ram_addr_video<8>/YUSED .LOC = "CLB_R15C5.S0";
  X_BUF \vga/ram_addr_video<8>/YUSED  (
    .I(\vga/ram_addr_video [9]),
    .O(\vga/ram_addr_video<9>_0 )
  );
  defparam \vga/Madd_ram_addr_videoC4_mand .LOC = "CLB_R15C5.S0";
  X_AND2 \vga/Madd_ram_addr_videoC4_mand  (
    .I0(\vga/vgacore/vcnt [7]),
    .I1(\vga/vgacore/vcnt [5]),
    .O(\vga/Madd_ram_addr_videoC4_mand1 )
  );
  defparam \vga/Madd_ram_addr_video_Madd_cy<9> .LOC = "CLB_R15C5.S0";
  X_MUX2 \vga/Madd_ram_addr_video_Madd_cy<9>  (
    .IA(\vga/Madd_ram_addr_videoC4_mand1 ),
    .IB(\vga/Madd_ram_addr_video_Madd_cy[8] ),
    .SEL(\vga/N232 ),
    .O(\vga/ram_addr_video<8>/CYMUXG )
  );
  defparam \vga/Madd_ram_addr_video_Madd_xor<9> .LOC = "CLB_R15C5.S0";
  X_XOR2 \vga/Madd_ram_addr_video_Madd_xor<9>  (
    .I0(\vga/Madd_ram_addr_video_Madd_cy[8] ),
    .I1(\vga/N232 ),
    .O(\vga/ram_addr_video [9])
  );
  defparam \vga/ram_addr_video<8>/CYINIT .LOC = "CLB_R15C5.S0";
  X_BUF \vga/ram_addr_video<8>/CYINIT  (
    .I(\vga/ram_addr_video<7>/CYMUXG ),
    .O(\vga/ram_addr_video<8>/CYINIT_106 )
  );
  defparam \vga/Madd_ram_addr_video_Madd_cy<10> .LOC = "CLB_R14C5.S0";
  X_MUX2 \vga/Madd_ram_addr_video_Madd_cy<10>  (
    .IA(\vga/vgacore/vcnt [7]),
    .IB(\vga/ram_addr_video<10>/CYINIT_108 ),
    .SEL(\vga/N233 ),
    .O(\vga/Madd_ram_addr_video_Madd_cy[10] )
  );
  defparam \vga/Madd_ram_addr_video_Madd_xor<10> .LOC = "CLB_R14C5.S0";
  X_XOR2 \vga/Madd_ram_addr_video_Madd_xor<10>  (
    .I0(\vga/ram_addr_video<10>/CYINIT_108 ),
    .I1(\vga/N233 ),
    .O(\vga/ram_addr_video [10])
  );
  defparam \vga/Madd_ram_addr_video_Madd_lut<10> .INIT = 16'h6A6A;
  defparam \vga/Madd_ram_addr_video_Madd_lut<10> .LOC = "CLB_R14C5.S0";
  X_LUT4 \vga/Madd_ram_addr_video_Madd_lut<10>  (
    .ADR0(\vga/vgacore/vcnt [7]),
    .ADR1(\vga/vgacore/vcnt [6]),
    .ADR2(\vga/vgacore/vcnt [8]),
    .ADR3(VCC),
    .O(\vga/N233 )
  );
  defparam \vga/vgacore/vcnt<8>_rt .INIT = 16'hAAAA;
  defparam \vga/vgacore/vcnt<8>_rt .LOC = "CLB_R14C5.S0";
  X_LUT4 \vga/vgacore/vcnt<8>_rt  (
    .ADR0(\vga/vgacore/vcnt [8]),
    .ADR1(VCC),
    .ADR2(VCC),
    .ADR3(VCC),
    .O(\vga/vgacore/vcnt<8>_rt_107 )
  );
  defparam \vga/ram_addr_video<10>/XUSED .LOC = "CLB_R14C5.S0";
  X_BUF \vga/ram_addr_video<10>/XUSED  (
    .I(\vga/ram_addr_video [10]),
    .O(\vga/ram_addr_video<10>_0 )
  );
  defparam \vga/ram_addr_video<10>/YUSED .LOC = "CLB_R14C5.S0";
  X_BUF \vga/ram_addr_video<10>/YUSED  (
    .I(\vga/ram_addr_video [11]),
    .O(\vga/ram_addr_video<11>_0 )
  );
  defparam \vga/Madd_ram_addr_video_Madd_xor<11> .LOC = "CLB_R14C5.S0";
  X_XOR2 \vga/Madd_ram_addr_video_Madd_xor<11>  (
    .I0(\vga/Madd_ram_addr_video_Madd_cy[10] ),
    .I1(\vga/vgacore/vcnt<8>_rt_107 ),
    .O(\vga/ram_addr_video [11])
  );
  defparam \vga/ram_addr_video<10>/CYINIT .LOC = "CLB_R14C5.S0";
  X_BUF \vga/ram_addr_video<10>/CYINIT  (
    .I(\vga/ram_addr_video<8>/CYMUXG ),
    .O(\vga/ram_addr_video<10>/CYINIT_108 )
  );
  defparam \vga/ps2/_addsub0000<1>/LOGIC_ZERO .LOC = "CLB_R11C16.S1";
  X_ZERO \vga/ps2/_addsub0000<1>/LOGIC_ZERO  (
    .O(\vga/ps2/_addsub0000<1>/LOGIC_ZERO_109 )
  );
  defparam \vga/ps2/Madd__addsub0000_cy<0> .LOC = "CLB_R11C16.S1";
  X_MUX2 \vga/ps2/Madd__addsub0000_cy<0>  (
    .IA(GLOBAL_LOGIC1),
    .IB(\vga/ps2/_addsub0000<1>/LOGIC_ZERO_109 ),
    .SEL(\vga/ps2/N5 ),
    .O(\vga/ps2/Madd__addsub0000_cy[0] )
  );
  defparam \vga/ps2/Madd__addsub0000_lut<0>_INV_0 .INIT = 16'h0F0F;
  defparam \vga/ps2/Madd__addsub0000_lut<0>_INV_0 .LOC = "CLB_R11C16.S1";
  X_LUT4 \vga/ps2/Madd__addsub0000_lut<0>_INV_0  (
    .ADR0(GLOBAL_LOGIC1),
    .ADR1(VCC),
    .ADR2(\vga/ps2/timer_r [0]),
    .ADR3(VCC),
    .O(\vga/ps2/N5 )
  );
  defparam \vga/ps2/_addsub0000<1>/G .INIT = 16'hFF00;
  defparam \vga/ps2/_addsub0000<1>/G .LOC = "CLB_R11C16.S1";
  X_LUT4 \vga/ps2/_addsub0000<1>/G  (
    .ADR0(GLOBAL_LOGIC0),
    .ADR1(VCC),
    .ADR2(VCC),
    .ADR3(\vga/ps2/timer_r [1]),
    .O(\vga/ps2/_addsub0000<1>/GROM )
  );
  defparam \vga/ps2/_addsub0000<1>/YUSED .LOC = "CLB_R11C16.S1";
  X_BUF \vga/ps2/_addsub0000<1>/YUSED  (
    .I(\vga/ps2/_addsub0000 [1]),
    .O(\vga/ps2/_addsub0000<1>_0 )
  );
  defparam \vga/ps2/Madd__addsub0000_cy<1> .LOC = "CLB_R11C16.S1";
  X_MUX2 \vga/ps2/Madd__addsub0000_cy<1>  (
    .IA(GLOBAL_LOGIC0),
    .IB(\vga/ps2/Madd__addsub0000_cy[0] ),
    .SEL(\vga/ps2/_addsub0000<1>/GROM ),
    .O(\vga/ps2/_addsub0000<1>/CYMUXG )
  );
  defparam \vga/ps2/Madd__addsub0000_xor<1> .LOC = "CLB_R11C16.S1";
  X_XOR2 \vga/ps2/Madd__addsub0000_xor<1>  (
    .I0(\vga/ps2/Madd__addsub0000_cy[0] ),
    .I1(\vga/ps2/_addsub0000<1>/GROM ),
    .O(\vga/ps2/_addsub0000 [1])
  );
  defparam \vga/ps2/_addsub0000<2>/LOGIC_ZERO .LOC = "CLB_R10C16.S1";
  X_ZERO \vga/ps2/_addsub0000<2>/LOGIC_ZERO  (
    .O(\vga/ps2/_addsub0000<2>/LOGIC_ZERO_110 )
  );
  defparam \vga/ps2/Madd__addsub0000_cy<2> .LOC = "CLB_R10C16.S1";
  X_MUX2 \vga/ps2/Madd__addsub0000_cy<2>  (
    .IA(\vga/ps2/_addsub0000<2>/LOGIC_ZERO_110 ),
    .IB(\vga/ps2/_addsub0000<2>/CYINIT_111 ),
    .SEL(\vga/ps2/_addsub0000<2>/FROM ),
    .O(\vga/ps2/Madd__addsub0000_cy[2] )
  );
  defparam \vga/ps2/Madd__addsub0000_xor<2> .LOC = "CLB_R10C16.S1";
  X_XOR2 \vga/ps2/Madd__addsub0000_xor<2>  (
    .I0(\vga/ps2/_addsub0000<2>/CYINIT_111 ),
    .I1(\vga/ps2/_addsub0000<2>/FROM ),
    .O(\vga/ps2/_addsub0000 [2])
  );
  defparam \vga/ps2/_addsub0000<2>/F .INIT = 16'hFF00;
  defparam \vga/ps2/_addsub0000<2>/F .LOC = "CLB_R10C16.S1";
  X_LUT4 \vga/ps2/_addsub0000<2>/F  (
    .ADR0(VCC),
    .ADR1(VCC),
    .ADR2(VCC),
    .ADR3(\vga/ps2/timer_r [2]),
    .O(\vga/ps2/_addsub0000<2>/FROM )
  );
  defparam \vga/ps2/_addsub0000<2>/G .INIT = 16'hFF00;
  defparam \vga/ps2/_addsub0000<2>/G .LOC = "CLB_R10C16.S1";
  X_LUT4 \vga/ps2/_addsub0000<2>/G  (
    .ADR0(VCC),
    .ADR1(VCC),
    .ADR2(VCC),
    .ADR3(\vga/ps2/timer_r [3]),
    .O(\vga/ps2/_addsub0000<2>/GROM )
  );
  defparam \vga/ps2/_addsub0000<2>/XUSED .LOC = "CLB_R10C16.S1";
  X_BUF \vga/ps2/_addsub0000<2>/XUSED  (
    .I(\vga/ps2/_addsub0000 [2]),
    .O(\vga/ps2/_addsub0000<2>_0 )
  );
  defparam \vga/ps2/_addsub0000<2>/YUSED .LOC = "CLB_R10C16.S1";
  X_BUF \vga/ps2/_addsub0000<2>/YUSED  (
    .I(\vga/ps2/_addsub0000 [3]),
    .O(\vga/ps2/_addsub0000<3>_0 )
  );
  defparam \vga/ps2/Madd__addsub0000_cy<3> .LOC = "CLB_R10C16.S1";
  X_MUX2 \vga/ps2/Madd__addsub0000_cy<3>  (
    .IA(\vga/ps2/_addsub0000<2>/LOGIC_ZERO_110 ),
    .IB(\vga/ps2/Madd__addsub0000_cy[2] ),
    .SEL(\vga/ps2/_addsub0000<2>/GROM ),
    .O(\vga/ps2/_addsub0000<2>/CYMUXG )
  );
  defparam \vga/ps2/Madd__addsub0000_xor<3> .LOC = "CLB_R10C16.S1";
  X_XOR2 \vga/ps2/Madd__addsub0000_xor<3>  (
    .I0(\vga/ps2/Madd__addsub0000_cy[2] ),
    .I1(\vga/ps2/_addsub0000<2>/GROM ),
    .O(\vga/ps2/_addsub0000 [3])
  );
  defparam \vga/ps2/_addsub0000<2>/CYINIT .LOC = "CLB_R10C16.S1";
  X_BUF \vga/ps2/_addsub0000<2>/CYINIT  (
    .I(\vga/ps2/_addsub0000<1>/CYMUXG ),
    .O(\vga/ps2/_addsub0000<2>/CYINIT_111 )
  );
  defparam \vga/ps2/_addsub0000<4>/LOGIC_ZERO .LOC = "CLB_R9C16.S1";
  X_ZERO \vga/ps2/_addsub0000<4>/LOGIC_ZERO  (
    .O(\vga/ps2/_addsub0000<4>/LOGIC_ZERO_112 )
  );
  defparam \vga/ps2/Madd__addsub0000_cy<4> .LOC = "CLB_R9C16.S1";
  X_MUX2 \vga/ps2/Madd__addsub0000_cy<4>  (
    .IA(\vga/ps2/_addsub0000<4>/LOGIC_ZERO_112 ),
    .IB(\vga/ps2/_addsub0000<4>/CYINIT_113 ),
    .SEL(\vga/ps2/_addsub0000<4>/FROM ),
    .O(\vga/ps2/Madd__addsub0000_cy[4] )
  );
  defparam \vga/ps2/Madd__addsub0000_xor<4> .LOC = "CLB_R9C16.S1";
  X_XOR2 \vga/ps2/Madd__addsub0000_xor<4>  (
    .I0(\vga/ps2/_addsub0000<4>/CYINIT_113 ),
    .I1(\vga/ps2/_addsub0000<4>/FROM ),
    .O(\vga/ps2/_addsub0000 [4])
  );
  defparam \vga/ps2/_addsub0000<4>/F .INIT = 16'hFF00;
  defparam \vga/ps2/_addsub0000<4>/F .LOC = "CLB_R9C16.S1";
  X_LUT4 \vga/ps2/_addsub0000<4>/F  (
    .ADR0(VCC),
    .ADR1(VCC),
    .ADR2(VCC),
    .ADR3(\vga/ps2/timer_r [4]),
    .O(\vga/ps2/_addsub0000<4>/FROM )
  );
  defparam \vga/ps2/_addsub0000<4>/G .INIT = 16'hF0F0;
  defparam \vga/ps2/_addsub0000<4>/G .LOC = "CLB_R9C16.S1";
  X_LUT4 \vga/ps2/_addsub0000<4>/G  (
    .ADR0(VCC),
    .ADR1(VCC),
    .ADR2(\vga/ps2/timer_r [5]),
    .ADR3(VCC),
    .O(\vga/ps2/_addsub0000<4>/GROM )
  );
  defparam \vga/ps2/_addsub0000<4>/XUSED .LOC = "CLB_R9C16.S1";
  X_BUF \vga/ps2/_addsub0000<4>/XUSED  (
    .I(\vga/ps2/_addsub0000 [4]),
    .O(\vga/ps2/_addsub0000<4>_0 )
  );
  defparam \vga/ps2/_addsub0000<4>/YUSED .LOC = "CLB_R9C16.S1";
  X_BUF \vga/ps2/_addsub0000<4>/YUSED  (
    .I(\vga/ps2/_addsub0000 [5]),
    .O(\vga/ps2/_addsub0000<5>_0 )
  );
  defparam \vga/ps2/Madd__addsub0000_cy<5> .LOC = "CLB_R9C16.S1";
  X_MUX2 \vga/ps2/Madd__addsub0000_cy<5>  (
    .IA(\vga/ps2/_addsub0000<4>/LOGIC_ZERO_112 ),
    .IB(\vga/ps2/Madd__addsub0000_cy[4] ),
    .SEL(\vga/ps2/_addsub0000<4>/GROM ),
    .O(\vga/ps2/_addsub0000<4>/CYMUXG )
  );
  defparam \vga/ps2/Madd__addsub0000_xor<5> .LOC = "CLB_R9C16.S1";
  X_XOR2 \vga/ps2/Madd__addsub0000_xor<5>  (
    .I0(\vga/ps2/Madd__addsub0000_cy[4] ),
    .I1(\vga/ps2/_addsub0000<4>/GROM ),
    .O(\vga/ps2/_addsub0000 [5])
  );
  defparam \vga/ps2/_addsub0000<4>/CYINIT .LOC = "CLB_R9C16.S1";
  X_BUF \vga/ps2/_addsub0000<4>/CYINIT  (
    .I(\vga/ps2/_addsub0000<2>/CYMUXG ),
    .O(\vga/ps2/_addsub0000<4>/CYINIT_113 )
  );
  defparam \vga/ps2/_addsub0000<6>/LOGIC_ZERO .LOC = "CLB_R8C16.S1";
  X_ZERO \vga/ps2/_addsub0000<6>/LOGIC_ZERO  (
    .O(\vga/ps2/_addsub0000<6>/LOGIC_ZERO_114 )
  );
  defparam \vga/ps2/Madd__addsub0000_cy<6> .LOC = "CLB_R8C16.S1";
  X_MUX2 \vga/ps2/Madd__addsub0000_cy<6>  (
    .IA(\vga/ps2/_addsub0000<6>/LOGIC_ZERO_114 ),
    .IB(\vga/ps2/_addsub0000<6>/CYINIT_115 ),
    .SEL(\vga/ps2/_addsub0000<6>/FROM ),
    .O(\vga/ps2/Madd__addsub0000_cy[6] )
  );
  defparam \vga/ps2/Madd__addsub0000_xor<6> .LOC = "CLB_R8C16.S1";
  X_XOR2 \vga/ps2/Madd__addsub0000_xor<6>  (
    .I0(\vga/ps2/_addsub0000<6>/CYINIT_115 ),
    .I1(\vga/ps2/_addsub0000<6>/FROM ),
    .O(\vga/ps2/_addsub0000 [6])
  );
  defparam \vga/ps2/_addsub0000<6>/F .INIT = 16'hCCCC;
  defparam \vga/ps2/_addsub0000<6>/F .LOC = "CLB_R8C16.S1";
  X_LUT4 \vga/ps2/_addsub0000<6>/F  (
    .ADR0(VCC),
    .ADR1(\vga/ps2/timer_r [6]),
    .ADR2(VCC),
    .ADR3(VCC),
    .O(\vga/ps2/_addsub0000<6>/FROM )
  );
  defparam \vga/ps2/_addsub0000<6>/G .INIT = 16'hF0F0;
  defparam \vga/ps2/_addsub0000<6>/G .LOC = "CLB_R8C16.S1";
  X_LUT4 \vga/ps2/_addsub0000<6>/G  (
    .ADR0(VCC),
    .ADR1(VCC),
    .ADR2(\vga/ps2/timer_r [7]),
    .ADR3(VCC),
    .O(\vga/ps2/_addsub0000<6>/GROM )
  );
  defparam \vga/ps2/_addsub0000<6>/XUSED .LOC = "CLB_R8C16.S1";
  X_BUF \vga/ps2/_addsub0000<6>/XUSED  (
    .I(\vga/ps2/_addsub0000 [6]),
    .O(\vga/ps2/_addsub0000<6>_0 )
  );
  defparam \vga/ps2/_addsub0000<6>/YUSED .LOC = "CLB_R8C16.S1";
  X_BUF \vga/ps2/_addsub0000<6>/YUSED  (
    .I(\vga/ps2/_addsub0000 [7]),
    .O(\vga/ps2/_addsub0000<7>_0 )
  );
  defparam \vga/ps2/Madd__addsub0000_cy<7> .LOC = "CLB_R8C16.S1";
  X_MUX2 \vga/ps2/Madd__addsub0000_cy<7>  (
    .IA(\vga/ps2/_addsub0000<6>/LOGIC_ZERO_114 ),
    .IB(\vga/ps2/Madd__addsub0000_cy[6] ),
    .SEL(\vga/ps2/_addsub0000<6>/GROM ),
    .O(\vga/ps2/_addsub0000<6>/CYMUXG )
  );
  defparam \vga/ps2/Madd__addsub0000_xor<7> .LOC = "CLB_R8C16.S1";
  X_XOR2 \vga/ps2/Madd__addsub0000_xor<7>  (
    .I0(\vga/ps2/Madd__addsub0000_cy[6] ),
    .I1(\vga/ps2/_addsub0000<6>/GROM ),
    .O(\vga/ps2/_addsub0000 [7])
  );
  defparam \vga/ps2/_addsub0000<6>/CYINIT .LOC = "CLB_R8C16.S1";
  X_BUF \vga/ps2/_addsub0000<6>/CYINIT  (
    .I(\vga/ps2/_addsub0000<4>/CYMUXG ),
    .O(\vga/ps2/_addsub0000<6>/CYINIT_115 )
  );
  defparam \vga/ps2/_addsub0000<8>/LOGIC_ZERO .LOC = "CLB_R7C16.S1";
  X_ZERO \vga/ps2/_addsub0000<8>/LOGIC_ZERO  (
    .O(\vga/ps2/_addsub0000<8>/LOGIC_ZERO_116 )
  );
  defparam \vga/ps2/Madd__addsub0000_cy<8> .LOC = "CLB_R7C16.S1";
  X_MUX2 \vga/ps2/Madd__addsub0000_cy<8>  (
    .IA(\vga/ps2/_addsub0000<8>/LOGIC_ZERO_116 ),
    .IB(\vga/ps2/_addsub0000<8>/CYINIT_117 ),
    .SEL(\vga/ps2/_addsub0000<8>/FROM ),
    .O(\vga/ps2/Madd__addsub0000_cy[8] )
  );
  defparam \vga/ps2/Madd__addsub0000_xor<8> .LOC = "CLB_R7C16.S1";
  X_XOR2 \vga/ps2/Madd__addsub0000_xor<8>  (
    .I0(\vga/ps2/_addsub0000<8>/CYINIT_117 ),
    .I1(\vga/ps2/_addsub0000<8>/FROM ),
    .O(\vga/ps2/_addsub0000 [8])
  );
  defparam \vga/ps2/_addsub0000<8>/F .INIT = 16'hAAAA;
  defparam \vga/ps2/_addsub0000<8>/F .LOC = "CLB_R7C16.S1";
  X_LUT4 \vga/ps2/_addsub0000<8>/F  (
    .ADR0(\vga/ps2/timer_r [8]),
    .ADR1(VCC),
    .ADR2(VCC),
    .ADR3(VCC),
    .O(\vga/ps2/_addsub0000<8>/FROM )
  );
  defparam \vga/ps2/_addsub0000<8>/G .INIT = 16'hCCCC;
  defparam \vga/ps2/_addsub0000<8>/G .LOC = "CLB_R7C16.S1";
  X_LUT4 \vga/ps2/_addsub0000<8>/G  (
    .ADR0(VCC),
    .ADR1(\vga/ps2/timer_r [9]),
    .ADR2(VCC),
    .ADR3(VCC),
    .O(\vga/ps2/_addsub0000<8>/GROM )
  );
  defparam \vga/ps2/_addsub0000<8>/XUSED .LOC = "CLB_R7C16.S1";
  X_BUF \vga/ps2/_addsub0000<8>/XUSED  (
    .I(\vga/ps2/_addsub0000 [8]),
    .O(\vga/ps2/_addsub0000<8>_0 )
  );
  defparam \vga/ps2/_addsub0000<8>/YUSED .LOC = "CLB_R7C16.S1";
  X_BUF \vga/ps2/_addsub0000<8>/YUSED  (
    .I(\vga/ps2/_addsub0000 [9]),
    .O(\vga/ps2/_addsub0000<9>_0 )
  );
  defparam \vga/ps2/Madd__addsub0000_cy<9> .LOC = "CLB_R7C16.S1";
  X_MUX2 \vga/ps2/Madd__addsub0000_cy<9>  (
    .IA(\vga/ps2/_addsub0000<8>/LOGIC_ZERO_116 ),
    .IB(\vga/ps2/Madd__addsub0000_cy[8] ),
    .SEL(\vga/ps2/_addsub0000<8>/GROM ),
    .O(\vga/ps2/_addsub0000<8>/CYMUXG )
  );
  defparam \vga/ps2/Madd__addsub0000_xor<9> .LOC = "CLB_R7C16.S1";
  X_XOR2 \vga/ps2/Madd__addsub0000_xor<9>  (
    .I0(\vga/ps2/Madd__addsub0000_cy[8] ),
    .I1(\vga/ps2/_addsub0000<8>/GROM ),
    .O(\vga/ps2/_addsub0000 [9])
  );
  defparam \vga/ps2/_addsub0000<8>/CYINIT .LOC = "CLB_R7C16.S1";
  X_BUF \vga/ps2/_addsub0000<8>/CYINIT  (
    .I(\vga/ps2/_addsub0000<6>/CYMUXG ),
    .O(\vga/ps2/_addsub0000<8>/CYINIT_117 )
  );
  defparam \vga/ps2/_addsub0000<10>/LOGIC_ZERO .LOC = "CLB_R6C16.S1";
  X_ZERO \vga/ps2/_addsub0000<10>/LOGIC_ZERO  (
    .O(\vga/ps2/_addsub0000<10>/LOGIC_ZERO_118 )
  );
  defparam \vga/ps2/Madd__addsub0000_cy<10> .LOC = "CLB_R6C16.S1";
  X_MUX2 \vga/ps2/Madd__addsub0000_cy<10>  (
    .IA(\vga/ps2/_addsub0000<10>/LOGIC_ZERO_118 ),
    .IB(\vga/ps2/_addsub0000<10>/CYINIT_119 ),
    .SEL(\vga/ps2/_addsub0000<10>/FROM ),
    .O(\vga/ps2/Madd__addsub0000_cy[10] )
  );
  defparam \vga/ps2/Madd__addsub0000_xor<10> .LOC = "CLB_R6C16.S1";
  X_XOR2 \vga/ps2/Madd__addsub0000_xor<10>  (
    .I0(\vga/ps2/_addsub0000<10>/CYINIT_119 ),
    .I1(\vga/ps2/_addsub0000<10>/FROM ),
    .O(\vga/ps2/_addsub0000 [10])
  );
  defparam \vga/ps2/_addsub0000<10>/F .INIT = 16'hCCCC;
  defparam \vga/ps2/_addsub0000<10>/F .LOC = "CLB_R6C16.S1";
  X_LUT4 \vga/ps2/_addsub0000<10>/F  (
    .ADR0(VCC),
    .ADR1(\vga/ps2/timer_r [10]),
    .ADR2(VCC),
    .ADR3(VCC),
    .O(\vga/ps2/_addsub0000<10>/FROM )
  );
  defparam \vga/ps2/_addsub0000<10>/G .INIT = 16'hAAAA;
  defparam \vga/ps2/_addsub0000<10>/G .LOC = "CLB_R6C16.S1";
  X_LUT4 \vga/ps2/_addsub0000<10>/G  (
    .ADR0(\vga/ps2/timer_r [11]),
    .ADR1(VCC),
    .ADR2(VCC),
    .ADR3(VCC),
    .O(\vga/ps2/_addsub0000<10>/GROM )
  );
  defparam \vga/ps2/_addsub0000<10>/XUSED .LOC = "CLB_R6C16.S1";
  X_BUF \vga/ps2/_addsub0000<10>/XUSED  (
    .I(\vga/ps2/_addsub0000 [10]),
    .O(\vga/ps2/_addsub0000<10>_0 )
  );
  defparam \vga/ps2/_addsub0000<10>/YUSED .LOC = "CLB_R6C16.S1";
  X_BUF \vga/ps2/_addsub0000<10>/YUSED  (
    .I(\vga/ps2/_addsub0000 [11]),
    .O(\vga/ps2/_addsub0000<11>_0 )
  );
  defparam \vga/ps2/Madd__addsub0000_cy<11> .LOC = "CLB_R6C16.S1";
  X_MUX2 \vga/ps2/Madd__addsub0000_cy<11>  (
    .IA(\vga/ps2/_addsub0000<10>/LOGIC_ZERO_118 ),
    .IB(\vga/ps2/Madd__addsub0000_cy[10] ),
    .SEL(\vga/ps2/_addsub0000<10>/GROM ),
    .O(\vga/ps2/_addsub0000<10>/CYMUXG )
  );
  defparam \vga/ps2/Madd__addsub0000_xor<11> .LOC = "CLB_R6C16.S1";
  X_XOR2 \vga/ps2/Madd__addsub0000_xor<11>  (
    .I0(\vga/ps2/Madd__addsub0000_cy[10] ),
    .I1(\vga/ps2/_addsub0000<10>/GROM ),
    .O(\vga/ps2/_addsub0000 [11])
  );
  defparam \vga/ps2/_addsub0000<10>/CYINIT .LOC = "CLB_R6C16.S1";
  X_BUF \vga/ps2/_addsub0000<10>/CYINIT  (
    .I(\vga/ps2/_addsub0000<8>/CYMUXG ),
    .O(\vga/ps2/_addsub0000<10>/CYINIT_119 )
  );
  defparam \vga/ps2/_addsub0000<12>/LOGIC_ZERO .LOC = "CLB_R5C16.S1";
  X_ZERO \vga/ps2/_addsub0000<12>/LOGIC_ZERO  (
    .O(\vga/ps2/_addsub0000<12>/LOGIC_ZERO_120 )
  );
  defparam \vga/ps2/Madd__addsub0000_cy<12> .LOC = "CLB_R5C16.S1";
  X_MUX2 \vga/ps2/Madd__addsub0000_cy<12>  (
    .IA(\vga/ps2/_addsub0000<12>/LOGIC_ZERO_120 ),
    .IB(\vga/ps2/_addsub0000<12>/CYINIT_122 ),
    .SEL(\vga/ps2/_addsub0000<12>/FROM ),
    .O(\vga/ps2/Madd__addsub0000_cy[12] )
  );
  defparam \vga/ps2/Madd__addsub0000_xor<12> .LOC = "CLB_R5C16.S1";
  X_XOR2 \vga/ps2/Madd__addsub0000_xor<12>  (
    .I0(\vga/ps2/_addsub0000<12>/CYINIT_122 ),
    .I1(\vga/ps2/_addsub0000<12>/FROM ),
    .O(\vga/ps2/_addsub0000 [12])
  );
  defparam \vga/ps2/_addsub0000<12>/F .INIT = 16'hFF00;
  defparam \vga/ps2/_addsub0000<12>/F .LOC = "CLB_R5C16.S1";
  X_LUT4 \vga/ps2/_addsub0000<12>/F  (
    .ADR0(VCC),
    .ADR1(VCC),
    .ADR2(VCC),
    .ADR3(\vga/ps2/timer_r [12]),
    .O(\vga/ps2/_addsub0000<12>/FROM )
  );
  defparam \vga/ps2/timer_r<13>_rt .INIT = 16'hAAAA;
  defparam \vga/ps2/timer_r<13>_rt .LOC = "CLB_R5C16.S1";
  X_LUT4 \vga/ps2/timer_r<13>_rt  (
    .ADR0(\vga/ps2/timer_r [13]),
    .ADR1(VCC),
    .ADR2(VCC),
    .ADR3(VCC),
    .O(\vga/ps2/timer_r<13>_rt_121 )
  );
  defparam \vga/ps2/_addsub0000<12>/XUSED .LOC = "CLB_R5C16.S1";
  X_BUF \vga/ps2/_addsub0000<12>/XUSED  (
    .I(\vga/ps2/_addsub0000 [12]),
    .O(\vga/ps2/_addsub0000<12>_0 )
  );
  defparam \vga/ps2/_addsub0000<12>/YUSED .LOC = "CLB_R5C16.S1";
  X_BUF \vga/ps2/_addsub0000<12>/YUSED  (
    .I(\vga/ps2/_addsub0000 [13]),
    .O(\vga/ps2/_addsub0000<13>_0 )
  );
  defparam \vga/ps2/Madd__addsub0000_xor<13> .LOC = "CLB_R5C16.S1";
  X_XOR2 \vga/ps2/Madd__addsub0000_xor<13>  (
    .I0(\vga/ps2/Madd__addsub0000_cy[12] ),
    .I1(\vga/ps2/timer_r<13>_rt_121 ),
    .O(\vga/ps2/_addsub0000 [13])
  );
  defparam \vga/ps2/_addsub0000<12>/CYINIT .LOC = "CLB_R5C16.S1";
  X_BUF \vga/ps2/_addsub0000<12>/CYINIT  (
    .I(\vga/ps2/_addsub0000<10>/CYMUXG ),
    .O(\vga/ps2/_addsub0000<12>/CYINIT_122 )
  );
  defparam \vga/crt/Result<1>/LOGIC_ZERO .LOC = "CLB_R16C12.S1";
  X_ZERO \vga/crt/Result<1>/LOGIC_ZERO  (
    .O(\vga/crt/Result<1>/LOGIC_ZERO_123 )
  );
  defparam \vga/crt/Mcount_cursor_v_cy<0> .LOC = "CLB_R16C12.S1";
  X_MUX2 \vga/crt/Mcount_cursor_v_cy<0>  (
    .IA(GLOBAL_LOGIC1),
    .IB(\vga/crt/Result<1>/LOGIC_ZERO_123 ),
    .SEL(\vga/crt/Result [0]),
    .O(\vga/crt/Mcount_cursor_v_cy[0] )
  );
  defparam \vga/crt/Mcount_cursor_v_lut<0>_INV_0 .INIT = 16'h3333;
  defparam \vga/crt/Mcount_cursor_v_lut<0>_INV_0 .LOC = "CLB_R16C12.S1";
  X_LUT4 \vga/crt/Mcount_cursor_v_lut<0>_INV_0  (
    .ADR0(GLOBAL_LOGIC1),
    .ADR1(\vga/crt/cursor_v [0]),
    .ADR2(VCC),
    .ADR3(VCC),
    .O(\vga/crt/Result [0])
  );
  defparam \vga/crt/Result<1>/G .INIT = 16'hFF00;
  defparam \vga/crt/Result<1>/G .LOC = "CLB_R16C12.S1";
  X_LUT4 \vga/crt/Result<1>/G  (
    .ADR0(GLOBAL_LOGIC0),
    .ADR1(VCC),
    .ADR2(VCC),
    .ADR3(\vga/crt/cursor_v [1]),
    .O(\vga/crt/Result<1>/GROM )
  );
  defparam \vga/crt/Result<1>/YUSED .LOC = "CLB_R16C12.S1";
  X_BUF \vga/crt/Result<1>/YUSED  (
    .I(\vga/crt/Result [1]),
    .O(\vga/crt/Result<1>_0 )
  );
  defparam \vga/crt/Mcount_cursor_v_cy<1> .LOC = "CLB_R16C12.S1";
  X_MUX2 \vga/crt/Mcount_cursor_v_cy<1>  (
    .IA(GLOBAL_LOGIC0),
    .IB(\vga/crt/Mcount_cursor_v_cy[0] ),
    .SEL(\vga/crt/Result<1>/GROM ),
    .O(\vga/crt/Result<1>/CYMUXG )
  );
  defparam \vga/crt/Mcount_cursor_v_xor<1> .LOC = "CLB_R16C12.S1";
  X_XOR2 \vga/crt/Mcount_cursor_v_xor<1>  (
    .I0(\vga/crt/Mcount_cursor_v_cy[0] ),
    .I1(\vga/crt/Result<1>/GROM ),
    .O(\vga/crt/Result [1])
  );
  defparam \vga/crt/Result<2>/LOGIC_ZERO .LOC = "CLB_R15C12.S1";
  X_ZERO \vga/crt/Result<2>/LOGIC_ZERO  (
    .O(\vga/crt/Result<2>/LOGIC_ZERO_124 )
  );
  defparam \vga/crt/Mcount_cursor_v_cy<2> .LOC = "CLB_R15C12.S1";
  X_MUX2 \vga/crt/Mcount_cursor_v_cy<2>  (
    .IA(\vga/crt/Result<2>/LOGIC_ZERO_124 ),
    .IB(\vga/crt/Result<2>/CYINIT_125 ),
    .SEL(\vga/crt/Result<2>/FROM ),
    .O(\vga/crt/Mcount_cursor_v_cy[2] )
  );
  defparam \vga/crt/Mcount_cursor_v_xor<2> .LOC = "CLB_R15C12.S1";
  X_XOR2 \vga/crt/Mcount_cursor_v_xor<2>  (
    .I0(\vga/crt/Result<2>/CYINIT_125 ),
    .I1(\vga/crt/Result<2>/FROM ),
    .O(\vga/crt/Result [2])
  );
  defparam \vga/crt/Result<2>/F .INIT = 16'hAAAA;
  defparam \vga/crt/Result<2>/F .LOC = "CLB_R15C12.S1";
  X_LUT4 \vga/crt/Result<2>/F  (
    .ADR0(\vga/crt/cursor_v [2]),
    .ADR1(VCC),
    .ADR2(VCC),
    .ADR3(VCC),
    .O(\vga/crt/Result<2>/FROM )
  );
  defparam \vga/crt/Result<2>/G .INIT = 16'hCCCC;
  defparam \vga/crt/Result<2>/G .LOC = "CLB_R15C12.S1";
  X_LUT4 \vga/crt/Result<2>/G  (
    .ADR0(VCC),
    .ADR1(\vga/crt/cursor_v [3]),
    .ADR2(VCC),
    .ADR3(VCC),
    .O(\vga/crt/Result<2>/GROM )
  );
  defparam \vga/crt/Result<2>/XUSED .LOC = "CLB_R15C12.S1";
  X_BUF \vga/crt/Result<2>/XUSED  (
    .I(\vga/crt/Result [2]),
    .O(\vga/crt/Result<2>_0 )
  );
  defparam \vga/crt/Result<2>/YUSED .LOC = "CLB_R15C12.S1";
  X_BUF \vga/crt/Result<2>/YUSED  (
    .I(\vga/crt/Result [3]),
    .O(\vga/crt/Result<3>_0 )
  );
  defparam \vga/crt/Mcount_cursor_v_cy<3> .LOC = "CLB_R15C12.S1";
  X_MUX2 \vga/crt/Mcount_cursor_v_cy<3>  (
    .IA(\vga/crt/Result<2>/LOGIC_ZERO_124 ),
    .IB(\vga/crt/Mcount_cursor_v_cy[2] ),
    .SEL(\vga/crt/Result<2>/GROM ),
    .O(\vga/crt/Result<2>/CYMUXG )
  );
  defparam \vga/crt/Mcount_cursor_v_xor<3> .LOC = "CLB_R15C12.S1";
  X_XOR2 \vga/crt/Mcount_cursor_v_xor<3>  (
    .I0(\vga/crt/Mcount_cursor_v_cy[2] ),
    .I1(\vga/crt/Result<2>/GROM ),
    .O(\vga/crt/Result [3])
  );
  defparam \vga/crt/Result<2>/CYINIT .LOC = "CLB_R15C12.S1";
  X_BUF \vga/crt/Result<2>/CYINIT  (
    .I(\vga/crt/Result<1>/CYMUXG ),
    .O(\vga/crt/Result<2>/CYINIT_125 )
  );
  defparam \vga/crt/Result<4>/LOGIC_ZERO .LOC = "CLB_R14C12.S1";
  X_ZERO \vga/crt/Result<4>/LOGIC_ZERO  (
    .O(\vga/crt/Result<4>/LOGIC_ZERO_126 )
  );
  defparam \vga/crt/Mcount_cursor_v_cy<4> .LOC = "CLB_R14C12.S1";
  X_MUX2 \vga/crt/Mcount_cursor_v_cy<4>  (
    .IA(\vga/crt/Result<4>/LOGIC_ZERO_126 ),
    .IB(\vga/crt/Result<4>/CYINIT_127 ),
    .SEL(\vga/crt/Result<4>/FROM ),
    .O(\vga/crt/Mcount_cursor_v_cy[4] )
  );
  defparam \vga/crt/Mcount_cursor_v_xor<4> .LOC = "CLB_R14C12.S1";
  X_XOR2 \vga/crt/Mcount_cursor_v_xor<4>  (
    .I0(\vga/crt/Result<4>/CYINIT_127 ),
    .I1(\vga/crt/Result<4>/FROM ),
    .O(\vga/crt/Result [4])
  );
  defparam \vga/crt/Result<4>/F .INIT = 16'hCCCC;
  defparam \vga/crt/Result<4>/F .LOC = "CLB_R14C12.S1";
  X_LUT4 \vga/crt/Result<4>/F  (
    .ADR0(VCC),
    .ADR1(\vga/crt/cursor_v [4]),
    .ADR2(VCC),
    .ADR3(VCC),
    .O(\vga/crt/Result<4>/FROM )
  );
  defparam \vga/crt/cursor_v<5>_rt.1 .INIT = 16'hF0F0;
  defparam \vga/crt/cursor_v<5>_rt.1 .LOC = "CLB_R14C12.S1";
  X_LUT4 \vga/crt/cursor_v<5>_rt.1  (
    .ADR0(VCC),
    .ADR1(VCC),
    .ADR2(\vga/crt/cursor_v [5]),
    .ADR3(VCC),
    .O(\vga/crt/Result<4>/GROM )
  );
  defparam \vga/crt/Result<4>/XUSED .LOC = "CLB_R14C12.S1";
  X_BUF \vga/crt/Result<4>/XUSED  (
    .I(\vga/crt/Result [4]),
    .O(\vga/crt/Result<4>_0 )
  );
  defparam \vga/crt/Result<4>/YUSED .LOC = "CLB_R14C12.S1";
  X_BUF \vga/crt/Result<4>/YUSED  (
    .I(\vga/crt/Result [5]),
    .O(\vga/crt/Result<5>_0 )
  );
  defparam \vga/crt/Mcount_cursor_v_xor<5> .LOC = "CLB_R14C12.S1";
  X_XOR2 \vga/crt/Mcount_cursor_v_xor<5>  (
    .I0(\vga/crt/Mcount_cursor_v_cy[4] ),
    .I1(\vga/crt/Result<4>/GROM ),
    .O(\vga/crt/Result [5])
  );
  defparam \vga/crt/Result<4>/CYINIT .LOC = "CLB_R14C12.S1";
  X_BUF \vga/crt/Result<4>/CYINIT  (
    .I(\vga/crt/Result<2>/CYMUXG ),
    .O(\vga/crt/Result<4>/CYINIT_127 )
  );
  defparam \vga/crt/Result<1>1/LOGIC_ZERO .LOC = "CLB_R19C12.S0";
  X_ZERO \vga/crt/Result<1>1/LOGIC_ZERO  (
    .O(\vga/crt/Result<1>1/LOGIC_ZERO_128 )
  );
  defparam \vga/crt/Mcount_cursor_h_cy<0> .LOC = "CLB_R19C12.S0";
  X_MUX2 \vga/crt/Mcount_cursor_h_cy<0>  (
    .IA(GLOBAL_LOGIC1),
    .IB(\vga/crt/Result<1>1/LOGIC_ZERO_128 ),
    .SEL(\vga/crt/Result<0>1 ),
    .O(\vga/crt/Mcount_cursor_h_cy[0] )
  );
  defparam \vga/crt/Mcount_cursor_h_lut<0>_INV_0 .INIT = 16'h0F0F;
  defparam \vga/crt/Mcount_cursor_h_lut<0>_INV_0 .LOC = "CLB_R19C12.S0";
  X_LUT4 \vga/crt/Mcount_cursor_h_lut<0>_INV_0  (
    .ADR0(GLOBAL_LOGIC1),
    .ADR1(VCC),
    .ADR2(\vga/crt/cursor_h [0]),
    .ADR3(VCC),
    .O(\vga/crt/Result<0>1 )
  );
  defparam \vga/crt/Result<1>1/G .INIT = 16'hF0F0;
  defparam \vga/crt/Result<1>1/G .LOC = "CLB_R19C12.S0";
  X_LUT4 \vga/crt/Result<1>1/G  (
    .ADR0(GLOBAL_LOGIC0),
    .ADR1(VCC),
    .ADR2(\vga/crt/cursor_h [1]),
    .ADR3(VCC),
    .O(\vga/crt/Result<1>1/GROM )
  );
  defparam \vga/crt/Result<1>1/YUSED .LOC = "CLB_R19C12.S0";
  X_BUF \vga/crt/Result<1>1/YUSED  (
    .I(\vga/crt/Result<1>1 ),
    .O(\vga/crt/Result<1>1_0 )
  );
  defparam \vga/crt/Mcount_cursor_h_cy<1> .LOC = "CLB_R19C12.S0";
  X_MUX2 \vga/crt/Mcount_cursor_h_cy<1>  (
    .IA(GLOBAL_LOGIC0),
    .IB(\vga/crt/Mcount_cursor_h_cy[0] ),
    .SEL(\vga/crt/Result<1>1/GROM ),
    .O(\vga/crt/Result<1>1/CYMUXG )
  );
  defparam \vga/crt/Mcount_cursor_h_xor<1> .LOC = "CLB_R19C12.S0";
  X_XOR2 \vga/crt/Mcount_cursor_h_xor<1>  (
    .I0(\vga/crt/Mcount_cursor_h_cy[0] ),
    .I1(\vga/crt/Result<1>1/GROM ),
    .O(\vga/crt/Result<1>1 )
  );
  defparam \vga/crt/Result<2>1/LOGIC_ZERO .LOC = "CLB_R18C12.S0";
  X_ZERO \vga/crt/Result<2>1/LOGIC_ZERO  (
    .O(\vga/crt/Result<2>1/LOGIC_ZERO_129 )
  );
  defparam \vga/crt/Mcount_cursor_h_cy<2> .LOC = "CLB_R18C12.S0";
  X_MUX2 \vga/crt/Mcount_cursor_h_cy<2>  (
    .IA(\vga/crt/Result<2>1/LOGIC_ZERO_129 ),
    .IB(\vga/crt/Result<2>1/CYINIT_130 ),
    .SEL(\vga/crt/Result<2>1/FROM ),
    .O(\vga/crt/Mcount_cursor_h_cy[2] )
  );
  defparam \vga/crt/Mcount_cursor_h_xor<2> .LOC = "CLB_R18C12.S0";
  X_XOR2 \vga/crt/Mcount_cursor_h_xor<2>  (
    .I0(\vga/crt/Result<2>1/CYINIT_130 ),
    .I1(\vga/crt/Result<2>1/FROM ),
    .O(\vga/crt/Result<2>1 )
  );
  defparam \vga/crt/Result<2>1/F .INIT = 16'hCCCC;
  defparam \vga/crt/Result<2>1/F .LOC = "CLB_R18C12.S0";
  X_LUT4 \vga/crt/Result<2>1/F  (
    .ADR0(VCC),
    .ADR1(\vga/crt/cursor_h [2]),
    .ADR2(VCC),
    .ADR3(VCC),
    .O(\vga/crt/Result<2>1/FROM )
  );
  defparam \vga/crt/Result<2>1/G .INIT = 16'hAAAA;
  defparam \vga/crt/Result<2>1/G .LOC = "CLB_R18C12.S0";
  X_LUT4 \vga/crt/Result<2>1/G  (
    .ADR0(\vga/crt/cursor_h [3]),
    .ADR1(VCC),
    .ADR2(VCC),
    .ADR3(VCC),
    .O(\vga/crt/Result<2>1/GROM )
  );
  defparam \vga/crt/Result<2>1/XUSED .LOC = "CLB_R18C12.S0";
  X_BUF \vga/crt/Result<2>1/XUSED  (
    .I(\vga/crt/Result<2>1 ),
    .O(\vga/crt/Result<2>1_0 )
  );
  defparam \vga/crt/Result<2>1/YUSED .LOC = "CLB_R18C12.S0";
  X_BUF \vga/crt/Result<2>1/YUSED  (
    .I(\vga/crt/Result<3>1 ),
    .O(\vga/crt/Result<3>1_0 )
  );
  defparam \vga/crt/Mcount_cursor_h_cy<3> .LOC = "CLB_R18C12.S0";
  X_MUX2 \vga/crt/Mcount_cursor_h_cy<3>  (
    .IA(\vga/crt/Result<2>1/LOGIC_ZERO_129 ),
    .IB(\vga/crt/Mcount_cursor_h_cy[2] ),
    .SEL(\vga/crt/Result<2>1/GROM ),
    .O(\vga/crt/Result<2>1/CYMUXG )
  );
  defparam \vga/crt/Mcount_cursor_h_xor<3> .LOC = "CLB_R18C12.S0";
  X_XOR2 \vga/crt/Mcount_cursor_h_xor<3>  (
    .I0(\vga/crt/Mcount_cursor_h_cy[2] ),
    .I1(\vga/crt/Result<2>1/GROM ),
    .O(\vga/crt/Result<3>1 )
  );
  defparam \vga/crt/Result<2>1/CYINIT .LOC = "CLB_R18C12.S0";
  X_BUF \vga/crt/Result<2>1/CYINIT  (
    .I(\vga/crt/Result<1>1/CYMUXG ),
    .O(\vga/crt/Result<2>1/CYINIT_130 )
  );
  defparam \vga/crt/Result<4>1/LOGIC_ZERO .LOC = "CLB_R17C12.S0";
  X_ZERO \vga/crt/Result<4>1/LOGIC_ZERO  (
    .O(\vga/crt/Result<4>1/LOGIC_ZERO_131 )
  );
  defparam \vga/crt/Mcount_cursor_h_cy<4> .LOC = "CLB_R17C12.S0";
  X_MUX2 \vga/crt/Mcount_cursor_h_cy<4>  (
    .IA(\vga/crt/Result<4>1/LOGIC_ZERO_131 ),
    .IB(\vga/crt/Result<4>1/CYINIT_132 ),
    .SEL(\vga/crt/Result<4>1/FROM ),
    .O(\vga/crt/Mcount_cursor_h_cy[4] )
  );
  defparam \vga/crt/Mcount_cursor_h_xor<4> .LOC = "CLB_R17C12.S0";
  X_XOR2 \vga/crt/Mcount_cursor_h_xor<4>  (
    .I0(\vga/crt/Result<4>1/CYINIT_132 ),
    .I1(\vga/crt/Result<4>1/FROM ),
    .O(\vga/crt/Result<4>1 )
  );
  defparam \vga/crt/Result<4>1/F .INIT = 16'hF0F0;
  defparam \vga/crt/Result<4>1/F .LOC = "CLB_R17C12.S0";
  X_LUT4 \vga/crt/Result<4>1/F  (
    .ADR0(VCC),
    .ADR1(VCC),
    .ADR2(\vga/crt/cursor_h [4]),
    .ADR3(VCC),
    .O(\vga/crt/Result<4>1/FROM )
  );
  defparam \vga/crt/Result<4>1/G .INIT = 16'hFF00;
  defparam \vga/crt/Result<4>1/G .LOC = "CLB_R17C12.S0";
  X_LUT4 \vga/crt/Result<4>1/G  (
    .ADR0(VCC),
    .ADR1(VCC),
    .ADR2(VCC),
    .ADR3(\vga/crt/cursor_h [5]),
    .O(\vga/crt/Result<4>1/GROM )
  );
  defparam \vga/crt/Result<4>1/XUSED .LOC = "CLB_R17C12.S0";
  X_BUF \vga/crt/Result<4>1/XUSED  (
    .I(\vga/crt/Result<4>1 ),
    .O(\vga/crt/Result<4>1_0 )
  );
  defparam \vga/crt/Result<4>1/YUSED .LOC = "CLB_R17C12.S0";
  X_BUF \vga/crt/Result<4>1/YUSED  (
    .I(\vga/crt/Result<5>1 ),
    .O(\vga/crt/Result<5>1_0 )
  );
  defparam \vga/crt/Mcount_cursor_h_cy<5> .LOC = "CLB_R17C12.S0";
  X_MUX2 \vga/crt/Mcount_cursor_h_cy<5>  (
    .IA(\vga/crt/Result<4>1/LOGIC_ZERO_131 ),
    .IB(\vga/crt/Mcount_cursor_h_cy[4] ),
    .SEL(\vga/crt/Result<4>1/GROM ),
    .O(\vga/crt/Result<4>1/CYMUXG )
  );
  defparam \vga/crt/Mcount_cursor_h_xor<5> .LOC = "CLB_R17C12.S0";
  X_XOR2 \vga/crt/Mcount_cursor_h_xor<5>  (
    .I0(\vga/crt/Mcount_cursor_h_cy[4] ),
    .I1(\vga/crt/Result<4>1/GROM ),
    .O(\vga/crt/Result<5>1 )
  );
  defparam \vga/crt/Result<4>1/CYINIT .LOC = "CLB_R17C12.S0";
  X_BUF \vga/crt/Result<4>1/CYINIT  (
    .I(\vga/crt/Result<2>1/CYMUXG ),
    .O(\vga/crt/Result<4>1/CYINIT_132 )
  );
  defparam \vga/crt/Mcount_cursor_h_xor<6> .LOC = "CLB_R16C12.S0";
  X_XOR2 \vga/crt/Mcount_cursor_h_xor<6>  (
    .I0(\vga/crt/Result<6>/CYINIT_134 ),
    .I1(\vga/crt/cursor_h<6>_rt_133 ),
    .O(\vga/crt/Result [6])
  );
  defparam \vga/crt/cursor_h<6>_rt .INIT = 16'hF0F0;
  defparam \vga/crt/cursor_h<6>_rt .LOC = "CLB_R16C12.S0";
  X_LUT4 \vga/crt/cursor_h<6>_rt  (
    .ADR0(VCC),
    .ADR1(VCC),
    .ADR2(\vga/crt/cursor_h [6]),
    .ADR3(VCC),
    .O(\vga/crt/cursor_h<6>_rt_133 )
  );
  defparam \vga/crt/Result<6>/XUSED .LOC = "CLB_R16C12.S0";
  X_BUF \vga/crt/Result<6>/XUSED  (
    .I(\vga/crt/Result [6]),
    .O(\vga/crt/Result<6>_0 )
  );
  defparam \vga/crt/Result<6>/CYINIT .LOC = "CLB_R16C12.S0";
  X_BUF \vga/crt/Result<6>/CYINIT  (
    .I(\vga/crt/Result<4>1/CYMUXG ),
    .O(\vga/crt/Result<6>/CYINIT_134 )
  );
  defparam \vga/vgacore/hcnt<1>/LOGIC_ZERO .LOC = "CLB_R19C7.S1";
  X_ZERO \vga/vgacore/hcnt<1>/LOGIC_ZERO  (
    .O(\vga/vgacore/hcnt<1>/LOGIC_ZERO_135 )
  );
  defparam \vga/vgacore/Mcount_hcnt_cy<1> .LOC = "CLB_R19C7.S1";
  X_MUX2 \vga/vgacore/Mcount_hcnt_cy<1>  (
    .IA(\vga/vgacore/hcnt<1>/LOGIC_ZERO_135 ),
    .IB(\vga/vgacore/hcnt<1>/CYINIT_136 ),
    .SEL(\vga/vgacore/hcnt_Eqn_1 ),
    .O(\vga/vgacore/Mcount_hcnt_cy[1] )
  );
  defparam \vga/vgacore/Mcount_hcnt_xor<1> .LOC = "CLB_R19C7.S1";
  X_XOR2 \vga/vgacore/Mcount_hcnt_xor<1>  (
    .I0(\vga/vgacore/hcnt<1>/CYINIT_136 ),
    .I1(\vga/vgacore/hcnt_Eqn_1 ),
    .O(\vga/vgacore/Result [1])
  );
  defparam \vga/vgacore/hcnt_Eqn_11 .INIT = 16'hF000;
  defparam \vga/vgacore/hcnt_Eqn_11 .LOC = "CLB_R19C7.S1";
  X_LUT4 \vga/vgacore/hcnt_Eqn_11  (
    .ADR0(VCC),
    .ADR1(VCC),
    .ADR2(\vga/vgacore/hcnt [1]),
    .ADR3(\vga/vgacore/hcnt_Eqn_bis_0 ),
    .O(\vga/vgacore/hcnt_Eqn_1 )
  );
  defparam \vga/vgacore/hcnt_Eqn_21 .INIT = 16'hF000;
  defparam \vga/vgacore/hcnt_Eqn_21 .LOC = "CLB_R19C7.S1";
  X_LUT4 \vga/vgacore/hcnt_Eqn_21  (
    .ADR0(VCC),
    .ADR1(VCC),
    .ADR2(\vga/vgacore/hcnt_Eqn_bis_0 ),
    .ADR3(\vga/vgacore/hcnt [2]),
    .O(\vga/vgacore/hcnt_Eqn_2 )
  );
  defparam \vga/vgacore/Mcount_hcnt_cy<2> .LOC = "CLB_R19C7.S1";
  X_MUX2 \vga/vgacore/Mcount_hcnt_cy<2>  (
    .IA(\vga/vgacore/hcnt<1>/LOGIC_ZERO_135 ),
    .IB(\vga/vgacore/Mcount_hcnt_cy[1] ),
    .SEL(\vga/vgacore/hcnt_Eqn_2 ),
    .O(\vga/vgacore/hcnt<1>/CYMUXG )
  );
  defparam \vga/vgacore/Mcount_hcnt_xor<2> .LOC = "CLB_R19C7.S1";
  X_XOR2 \vga/vgacore/Mcount_hcnt_xor<2>  (
    .I0(\vga/vgacore/Mcount_hcnt_cy[1] ),
    .I1(\vga/vgacore/hcnt_Eqn_2 ),
    .O(\vga/vgacore/Result [2])
  );
  defparam \vga/vgacore/hcnt<1>/SRMUX .LOC = "CLB_R19C7.S1";
  X_INV \vga/vgacore/hcnt<1>/SRMUX  (
    .I(reset_n_IBUF_0),
    .O(\vga/vgacore/hcnt<1>/SRMUX_OUTPUTNOT )
  );
  defparam \vga/vgacore/hcnt<1>/CYINIT .LOC = "CLB_R19C7.S1";
  X_BUF \vga/vgacore/hcnt<1>/CYINIT  (
    .I(\vga/vgacore/hcnt<0>/CYMUXG ),
    .O(\vga/vgacore/hcnt<1>/CYINIT_136 )
  );
  defparam \vga/vgacore/hcnt_1 .LOC = "CLB_R19C7.S1";
  defparam \vga/vgacore/hcnt_1 .INIT = 1'b0;
  X_FF \vga/vgacore/hcnt_1  (
    .I(\vga/vgacore/Result [1]),
    .CE(VCC),
    .CLK(gray_cnt_FFd1_0),
    .SET(GND),
    .RST(\vga/vgacore/hcnt<1>/FFX/RST ),
    .O(\vga/vgacore/hcnt [1])
  );
  defparam \vga/vgacore/hcnt<1>/FFX/RSTOR .LOC = "CLB_R19C7.S1";
  X_BUF \vga/vgacore/hcnt<1>/FFX/RSTOR  (
    .I(\vga/vgacore/hcnt<1>/SRMUX_OUTPUTNOT ),
    .O(\vga/vgacore/hcnt<1>/FFX/RST )
  );
  defparam \vga/vgacore/hcnt<3>/LOGIC_ZERO .LOC = "CLB_R18C7.S1";
  X_ZERO \vga/vgacore/hcnt<3>/LOGIC_ZERO  (
    .O(\vga/vgacore/hcnt<3>/LOGIC_ZERO_137 )
  );
  defparam \vga/vgacore/Mcount_hcnt_cy<3> .LOC = "CLB_R18C7.S1";
  X_MUX2 \vga/vgacore/Mcount_hcnt_cy<3>  (
    .IA(\vga/vgacore/hcnt<3>/LOGIC_ZERO_137 ),
    .IB(\vga/vgacore/hcnt<3>/CYINIT_138 ),
    .SEL(\vga/vgacore/hcnt_Eqn_3 ),
    .O(\vga/vgacore/Mcount_hcnt_cy[3] )
  );
  defparam \vga/vgacore/Mcount_hcnt_xor<3> .LOC = "CLB_R18C7.S1";
  X_XOR2 \vga/vgacore/Mcount_hcnt_xor<3>  (
    .I0(\vga/vgacore/hcnt<3>/CYINIT_138 ),
    .I1(\vga/vgacore/hcnt_Eqn_3 ),
    .O(\vga/vgacore/Result [3])
  );
  defparam \vga/vgacore/hcnt_Eqn_31 .INIT = 16'hCC00;
  defparam \vga/vgacore/hcnt_Eqn_31 .LOC = "CLB_R18C7.S1";
  X_LUT4 \vga/vgacore/hcnt_Eqn_31  (
    .ADR0(VCC),
    .ADR1(\vga/vgacore/hcnt [3]),
    .ADR2(VCC),
    .ADR3(\vga/vgacore/hcnt_Eqn_bis_0 ),
    .O(\vga/vgacore/hcnt_Eqn_3 )
  );
  defparam \vga/vgacore/hcnt_Eqn_41 .INIT = 16'h8888;
  defparam \vga/vgacore/hcnt_Eqn_41 .LOC = "CLB_R18C7.S1";
  X_LUT4 \vga/vgacore/hcnt_Eqn_41  (
    .ADR0(\vga/vgacore/hcnt_Eqn_bis_0 ),
    .ADR1(\vga/vgacore/hcnt [4]),
    .ADR2(VCC),
    .ADR3(VCC),
    .O(\vga/vgacore/hcnt_Eqn_4 )
  );
  defparam \vga/vgacore/Mcount_hcnt_cy<4> .LOC = "CLB_R18C7.S1";
  X_MUX2 \vga/vgacore/Mcount_hcnt_cy<4>  (
    .IA(\vga/vgacore/hcnt<3>/LOGIC_ZERO_137 ),
    .IB(\vga/vgacore/Mcount_hcnt_cy[3] ),
    .SEL(\vga/vgacore/hcnt_Eqn_4 ),
    .O(\vga/vgacore/hcnt<3>/CYMUXG )
  );
  defparam \vga/vgacore/Mcount_hcnt_xor<4> .LOC = "CLB_R18C7.S1";
  X_XOR2 \vga/vgacore/Mcount_hcnt_xor<4>  (
    .I0(\vga/vgacore/Mcount_hcnt_cy[3] ),
    .I1(\vga/vgacore/hcnt_Eqn_4 ),
    .O(\vga/vgacore/Result [4])
  );
  defparam \vga/vgacore/hcnt<3>/SRMUX .LOC = "CLB_R18C7.S1";
  X_INV \vga/vgacore/hcnt<3>/SRMUX  (
    .I(reset_n_IBUF_0),
    .O(\vga/vgacore/hcnt<3>/SRMUX_OUTPUTNOT )
  );
  defparam \vga/vgacore/hcnt<3>/CYINIT .LOC = "CLB_R18C7.S1";
  X_BUF \vga/vgacore/hcnt<3>/CYINIT  (
    .I(\vga/vgacore/hcnt<1>/CYMUXG ),
    .O(\vga/vgacore/hcnt<3>/CYINIT_138 )
  );
  defparam \vga/vgacore/hcnt<5>/LOGIC_ZERO .LOC = "CLB_R17C7.S1";
  X_ZERO \vga/vgacore/hcnt<5>/LOGIC_ZERO  (
    .O(\vga/vgacore/hcnt<5>/LOGIC_ZERO_139 )
  );
  defparam \vga/vgacore/Mcount_hcnt_cy<5> .LOC = "CLB_R17C7.S1";
  X_MUX2 \vga/vgacore/Mcount_hcnt_cy<5>  (
    .IA(\vga/vgacore/hcnt<5>/LOGIC_ZERO_139 ),
    .IB(\vga/vgacore/hcnt<5>/CYINIT_140 ),
    .SEL(\vga/vgacore/hcnt_Eqn_5 ),
    .O(\vga/vgacore/Mcount_hcnt_cy[5] )
  );
  defparam \vga/vgacore/Mcount_hcnt_xor<5> .LOC = "CLB_R17C7.S1";
  X_XOR2 \vga/vgacore/Mcount_hcnt_xor<5>  (
    .I0(\vga/vgacore/hcnt<5>/CYINIT_140 ),
    .I1(\vga/vgacore/hcnt_Eqn_5 ),
    .O(\vga/vgacore/Result [5])
  );
  defparam \vga/vgacore/hcnt_Eqn_51 .INIT = 16'hF000;
  defparam \vga/vgacore/hcnt_Eqn_51 .LOC = "CLB_R17C7.S1";
  X_LUT4 \vga/vgacore/hcnt_Eqn_51  (
    .ADR0(VCC),
    .ADR1(VCC),
    .ADR2(\vga/vgacore/hcnt_Eqn_bis_0 ),
    .ADR3(\vga/vgacore/hcnt [5]),
    .O(\vga/vgacore/hcnt_Eqn_5 )
  );
  defparam \vga/vgacore/hcnt_Eqn_61 .INIT = 16'hAA00;
  defparam \vga/vgacore/hcnt_Eqn_61 .LOC = "CLB_R17C7.S1";
  X_LUT4 \vga/vgacore/hcnt_Eqn_61  (
    .ADR0(\vga/vgacore/hcnt_Eqn_bis_0 ),
    .ADR1(VCC),
    .ADR2(VCC),
    .ADR3(\vga/vgacore/hcnt [6]),
    .O(\vga/vgacore/hcnt_Eqn_6 )
  );
  defparam \vga/vgacore/Mcount_hcnt_cy<6> .LOC = "CLB_R17C7.S1";
  X_MUX2 \vga/vgacore/Mcount_hcnt_cy<6>  (
    .IA(\vga/vgacore/hcnt<5>/LOGIC_ZERO_139 ),
    .IB(\vga/vgacore/Mcount_hcnt_cy[5] ),
    .SEL(\vga/vgacore/hcnt_Eqn_6 ),
    .O(\vga/vgacore/hcnt<5>/CYMUXG )
  );
  defparam \vga/vgacore/Mcount_hcnt_xor<6> .LOC = "CLB_R17C7.S1";
  X_XOR2 \vga/vgacore/Mcount_hcnt_xor<6>  (
    .I0(\vga/vgacore/Mcount_hcnt_cy[5] ),
    .I1(\vga/vgacore/hcnt_Eqn_6 ),
    .O(\vga/vgacore/Result [6])
  );
  defparam \vga/vgacore/hcnt<5>/SRMUX .LOC = "CLB_R17C7.S1";
  X_INV \vga/vgacore/hcnt<5>/SRMUX  (
    .I(reset_n_IBUF_0),
    .O(\vga/vgacore/hcnt<5>/SRMUX_OUTPUTNOT )
  );
  defparam \vga/vgacore/hcnt<5>/CYINIT .LOC = "CLB_R17C7.S1";
  X_BUF \vga/vgacore/hcnt<5>/CYINIT  (
    .I(\vga/vgacore/hcnt<3>/CYMUXG ),
    .O(\vga/vgacore/hcnt<5>/CYINIT_140 )
  );
  defparam \vga/vgacore/hcnt<7>/LOGIC_ZERO .LOC = "CLB_R16C7.S1";
  X_ZERO \vga/vgacore/hcnt<7>/LOGIC_ZERO  (
    .O(\vga/vgacore/hcnt<7>/LOGIC_ZERO_141 )
  );
  defparam \vga/vgacore/Mcount_hcnt_cy<7> .LOC = "CLB_R16C7.S1";
  X_MUX2 \vga/vgacore/Mcount_hcnt_cy<7>  (
    .IA(\vga/vgacore/hcnt<7>/LOGIC_ZERO_141 ),
    .IB(\vga/vgacore/hcnt<7>/CYINIT_142 ),
    .SEL(\vga/vgacore/hcnt_Eqn_7 ),
    .O(\vga/vgacore/Mcount_hcnt_cy[7] )
  );
  defparam \vga/vgacore/Mcount_hcnt_xor<7> .LOC = "CLB_R16C7.S1";
  X_XOR2 \vga/vgacore/Mcount_hcnt_xor<7>  (
    .I0(\vga/vgacore/hcnt<7>/CYINIT_142 ),
    .I1(\vga/vgacore/hcnt_Eqn_7 ),
    .O(\vga/vgacore/Result [7])
  );
  defparam \vga/vgacore/hcnt_Eqn_71 .INIT = 16'hA0A0;
  defparam \vga/vgacore/hcnt_Eqn_71 .LOC = "CLB_R16C7.S1";
  X_LUT4 \vga/vgacore/hcnt_Eqn_71  (
    .ADR0(\vga/vgacore/hcnt [7]),
    .ADR1(VCC),
    .ADR2(\vga/vgacore/hcnt_Eqn_bis_0 ),
    .ADR3(VCC),
    .O(\vga/vgacore/hcnt_Eqn_7 )
  );
  defparam \vga/vgacore/hcnt_Eqn_81 .INIT = 16'hF000;
  defparam \vga/vgacore/hcnt_Eqn_81 .LOC = "CLB_R16C7.S1";
  X_LUT4 \vga/vgacore/hcnt_Eqn_81  (
    .ADR0(VCC),
    .ADR1(VCC),
    .ADR2(\vga/vgacore/hcnt [8]),
    .ADR3(\vga/vgacore/hcnt_Eqn_bis_0 ),
    .O(\vga/vgacore/hcnt_Eqn_8 )
  );
  defparam \vga/vgacore/Mcount_hcnt_cy<8> .LOC = "CLB_R16C7.S1";
  X_MUX2 \vga/vgacore/Mcount_hcnt_cy<8>  (
    .IA(\vga/vgacore/hcnt<7>/LOGIC_ZERO_141 ),
    .IB(\vga/vgacore/Mcount_hcnt_cy[7] ),
    .SEL(\vga/vgacore/hcnt_Eqn_8 ),
    .O(\vga/vgacore/hcnt<7>/CYMUXG )
  );
  defparam \vga/vgacore/Mcount_hcnt_xor<8> .LOC = "CLB_R16C7.S1";
  X_XOR2 \vga/vgacore/Mcount_hcnt_xor<8>  (
    .I0(\vga/vgacore/Mcount_hcnt_cy[7] ),
    .I1(\vga/vgacore/hcnt_Eqn_8 ),
    .O(\vga/vgacore/Result [8])
  );
  defparam \vga/vgacore/hcnt<7>/SRMUX .LOC = "CLB_R16C7.S1";
  X_INV \vga/vgacore/hcnt<7>/SRMUX  (
    .I(reset_n_IBUF_0),
    .O(\vga/vgacore/hcnt<7>/SRMUX_OUTPUTNOT )
  );
  defparam \vga/vgacore/hcnt<7>/CYINIT .LOC = "CLB_R16C7.S1";
  X_BUF \vga/vgacore/hcnt<7>/CYINIT  (
    .I(\vga/vgacore/hcnt<5>/CYMUXG ),
    .O(\vga/vgacore/hcnt<7>/CYINIT_142 )
  );
  defparam \vga/vgacore/hcnt<9>/LOGIC_ZERO .LOC = "CLB_R15C7.S1";
  X_ZERO \vga/vgacore/hcnt<9>/LOGIC_ZERO  (
    .O(\vga/vgacore/hcnt<9>/LOGIC_ZERO_143 )
  );
  defparam \vga/vgacore/Mcount_hcnt_cy<9> .LOC = "CLB_R15C7.S1";
  X_MUX2 \vga/vgacore/Mcount_hcnt_cy<9>  (
    .IA(\vga/vgacore/hcnt<9>/LOGIC_ZERO_143 ),
    .IB(\vga/vgacore/hcnt<9>/CYINIT_144 ),
    .SEL(\vga/vgacore/hcnt_Eqn_9 ),
    .O(\vga/vgacore/Mcount_hcnt_cy[9] )
  );
  defparam \vga/vgacore/Mcount_hcnt_xor<9> .LOC = "CLB_R15C7.S1";
  X_XOR2 \vga/vgacore/Mcount_hcnt_xor<9>  (
    .I0(\vga/vgacore/hcnt<9>/CYINIT_144 ),
    .I1(\vga/vgacore/hcnt_Eqn_9 ),
    .O(\vga/vgacore/Result [9])
  );
  defparam \vga/vgacore/hcnt_Eqn_91 .INIT = 16'hCC00;
  defparam \vga/vgacore/hcnt_Eqn_91 .LOC = "CLB_R15C7.S1";
  X_LUT4 \vga/vgacore/hcnt_Eqn_91  (
    .ADR0(VCC),
    .ADR1(\vga/vgacore/hcnt [9]),
    .ADR2(VCC),
    .ADR3(\vga/vgacore/hcnt_Eqn_bis_0 ),
    .O(\vga/vgacore/hcnt_Eqn_9 )
  );
  defparam \vga/vgacore/hcnt_Eqn_101 .INIT = 16'hF000;
  defparam \vga/vgacore/hcnt_Eqn_101 .LOC = "CLB_R15C7.S1";
  X_LUT4 \vga/vgacore/hcnt_Eqn_101  (
    .ADR0(VCC),
    .ADR1(VCC),
    .ADR2(\vga/vgacore/hcnt [10]),
    .ADR3(\vga/vgacore/hcnt_Eqn_bis_0 ),
    .O(\vga/vgacore/hcnt_Eqn_10 )
  );
  defparam \vga/vgacore/Mcount_hcnt_xor<10> .LOC = "CLB_R15C7.S1";
  X_XOR2 \vga/vgacore/Mcount_hcnt_xor<10>  (
    .I0(\vga/vgacore/Mcount_hcnt_cy[9] ),
    .I1(\vga/vgacore/hcnt_Eqn_10 ),
    .O(\vga/vgacore/Result [10])
  );
  defparam \vga/vgacore/hcnt<9>/SRMUX .LOC = "CLB_R15C7.S1";
  X_INV \vga/vgacore/hcnt<9>/SRMUX  (
    .I(reset_n_IBUF_0),
    .O(\vga/vgacore/hcnt<9>/SRMUX_OUTPUTNOT )
  );
  defparam \vga/vgacore/hcnt<9>/CYINIT .LOC = "CLB_R15C7.S1";
  X_BUF \vga/vgacore/hcnt<9>/CYINIT  (
    .I(\vga/vgacore/hcnt<7>/CYMUXG ),
    .O(\vga/vgacore/hcnt<9>/CYINIT_144 )
  );
  defparam \vga/vgacore/hcnt_9 .LOC = "CLB_R15C7.S1";
  defparam \vga/vgacore/hcnt_9 .INIT = 1'b0;
  X_FF \vga/vgacore/hcnt_9  (
    .I(\vga/vgacore/Result [9]),
    .CE(VCC),
    .CLK(gray_cnt_FFd1_0),
    .SET(GND),
    .RST(\vga/vgacore/hcnt<9>/FFX/RST ),
    .O(\vga/vgacore/hcnt [9])
  );
  defparam \vga/vgacore/hcnt<9>/FFX/RSTOR .LOC = "CLB_R15C7.S1";
  X_BUF \vga/vgacore/hcnt<9>/FFX/RSTOR  (
    .I(\vga/vgacore/hcnt<9>/SRMUX_OUTPUTNOT ),
    .O(\vga/vgacore/hcnt<9>/FFX/RST )
  );
  defparam \vga/vgacore/vcnt<0>/LOGIC_ONE .LOC = "CLB_R19C9.S1";
  X_ONE \vga/vgacore/vcnt<0>/LOGIC_ONE  (
    .O(\vga/vgacore/vcnt<0>/LOGIC_ONE_145 )
  );
  defparam \vga/vgacore/vcnt<0>/LOGIC_ZERO .LOC = "CLB_R19C9.S1";
  X_ZERO \vga/vgacore/vcnt<0>/LOGIC_ZERO  (
    .O(\vga/vgacore/vcnt<0>/LOGIC_ZERO_147 )
  );
  defparam \vga/vgacore/Mcount_vcnt_cy<0> .LOC = "CLB_R19C9.S1";
  X_MUX2 \vga/vgacore/Mcount_vcnt_cy<0>  (
    .IA(\vga/vgacore/vcnt_Eqn_0_mand1 ),
    .IB(\vga/vgacore/vcnt<0>/LOGIC_ZERO_147 ),
    .SEL(\vga/vgacore/Result<0>1 ),
    .O(\vga/vgacore/Mcount_vcnt_cy<0>_rt_146 )
  );
  defparam \vga/vgacore/vcnt_Eqn_0_mand .LOC = "CLB_R19C9.S1";
  X_AND2 \vga/vgacore/vcnt_Eqn_0_mand  (
    .I0(\vga/vgacore/vcnt_Eqn_bis_0_0 ),
    .I1(\vga/vgacore/vcnt [0]),
    .O(\vga/vgacore/vcnt_Eqn_0_mand1 )
  );
  defparam \vga/vgacore/Mcount_vcnt_lut<0> .INIT = 16'h4444;
  defparam \vga/vgacore/Mcount_vcnt_lut<0> .LOC = "CLB_R19C9.S1";
  X_LUT4 \vga/vgacore/Mcount_vcnt_lut<0>  (
    .ADR0(\vga/vgacore/vcnt [0]),
    .ADR1(\vga/vgacore/vcnt_Eqn_bis_0_0 ),
    .ADR2(VCC),
    .ADR3(VCC),
    .O(\vga/vgacore/Result<0>1 )
  );
  defparam \vga/vgacore/Mcount_vcnt_lut<0>_1 .INIT = 16'h4444;
  defparam \vga/vgacore/Mcount_vcnt_lut<0>_1 .LOC = "CLB_R19C9.S1";
  X_LUT4 \vga/vgacore/Mcount_vcnt_lut<0>_1  (
    .ADR0(\vga/vgacore/vcnt [0]),
    .ADR1(\vga/vgacore/vcnt_Eqn_bis_0_0 ),
    .ADR2(VCC),
    .ADR3(VCC),
    .O(N3216)
  );
  defparam \vga/vgacore/vcnt<0>/CKINV .LOC = "CLB_R19C9.S1";
  X_INV \vga/vgacore/vcnt<0>/CKINV  (
    .I(\vga/vgacore/hblank_21 ),
    .O(\vga/vgacore/vcnt<0>/CKMUXNOT )
  );
  defparam \vga/vgacore/Mcount_vcnt_cy<0>_rt .LOC = "CLB_R19C9.S1";
  X_MUX2 \vga/vgacore/Mcount_vcnt_cy<0>_rt  (
    .IA(\NLW_vga/vgacore/Mcount_vcnt_cy<0>_rt_IA_UNCONNECTED ),
    .IB(\vga/vgacore/Mcount_vcnt_cy<0>_rt_146 ),
    .SEL(\vga/vgacore/vcnt<0>/LOGIC_ONE_145 ),
    .O(\vga/vgacore/vcnt<0>/CYMUXG )
  );
  defparam \vga/vgacore/vcnt<0>/SRMUX .LOC = "CLB_R19C9.S1";
  X_INV \vga/vgacore/vcnt<0>/SRMUX  (
    .I(reset_n_IBUF_0),
    .O(\vga/vgacore/vcnt<0>/SRMUX_OUTPUTNOT )
  );
  defparam \vga/vgacore/vcnt_0 .LOC = "CLB_R19C9.S1";
  defparam \vga/vgacore/vcnt_0 .INIT = 1'b0;
  X_FF \vga/vgacore/vcnt_0  (
    .I(\vga/vgacore/Result<0>1 ),
    .CE(VCC),
    .CLK(\vga/vgacore/vcnt<0>/CKMUXNOT ),
    .SET(GND),
    .RST(\vga/vgacore/vcnt<0>/FFX/RST ),
    .O(\vga/vgacore/vcnt [0])
  );
  defparam \vga/vgacore/vcnt<0>/FFX/RSTOR .LOC = "CLB_R19C9.S1";
  X_BUF \vga/vgacore/vcnt<0>/FFX/RSTOR  (
    .I(\vga/vgacore/vcnt<0>/SRMUX_OUTPUTNOT ),
    .O(\vga/vgacore/vcnt<0>/FFX/RST )
  );
  defparam \vga/vgacore/vcnt<1>/LOGIC_ZERO .LOC = "CLB_R18C9.S1";
  X_ZERO \vga/vgacore/vcnt<1>/LOGIC_ZERO  (
    .O(\vga/vgacore/vcnt<1>/LOGIC_ZERO_149 )
  );
  defparam \vga/vgacore/Mcount_vcnt_cy<1> .LOC = "CLB_R18C9.S1";
  X_MUX2 \vga/vgacore/Mcount_vcnt_cy<1>  (
    .IA(\vga/vgacore/vcnt<1>/LOGIC_ZERO_149 ),
    .IB(\vga/vgacore/vcnt<1>/CYINIT_150 ),
    .SEL(\vga/vgacore/vcnt_Eqn_1_148 ),
    .O(\vga/vgacore/Mcount_vcnt_cy[1] )
  );
  defparam \vga/vgacore/Mcount_vcnt_xor<1> .LOC = "CLB_R18C9.S1";
  X_XOR2 \vga/vgacore/Mcount_vcnt_xor<1>  (
    .I0(\vga/vgacore/vcnt<1>/CYINIT_150 ),
    .I1(\vga/vgacore/vcnt_Eqn_1_148 ),
    .O(\vga/vgacore/Result<1>1 )
  );
  defparam \vga/vgacore/vcnt_Eqn_1 .INIT = 16'h08CC;
  defparam \vga/vgacore/vcnt_Eqn_1 .LOC = "CLB_R18C9.S1";
  X_LUT4 \vga/vgacore/vcnt_Eqn_1  (
    .ADR0(\vga/vgacore/N51_0 ),
    .ADR1(\vga/vgacore/vcnt [1]),
    .ADR2(N839_0),
    .ADR3(\vga/vgacore/vcnt [9]),
    .O(\vga/vgacore/vcnt_Eqn_1_148 )
  );
  defparam \vga/vgacore/vcnt_Eqn_21 .INIT = 16'h20AA;
  defparam \vga/vgacore/vcnt_Eqn_21 .LOC = "CLB_R18C9.S1";
  X_LUT4 \vga/vgacore/vcnt_Eqn_21  (
    .ADR0(\vga/vgacore/vcnt [2]),
    .ADR1(\vga/vgacore/vcnt [3]),
    .ADR2(\vga/vgacore/N51_0 ),
    .ADR3(\vga/vgacore/vcnt [9]),
    .O(\vga/vgacore/vcnt_Eqn_2 )
  );
  defparam \vga/vgacore/vcnt<1>/XUSED .LOC = "CLB_R18C9.S1";
  X_BUF \vga/vgacore/vcnt<1>/XUSED  (
    .I(\vga/vgacore/Result<1>1 ),
    .O(\vga/vgacore/Result<1>1_0 )
  );
  defparam \vga/vgacore/vcnt<1>/CKINV .LOC = "CLB_R18C9.S1";
  X_INV \vga/vgacore/vcnt<1>/CKINV  (
    .I(\vga/vgacore/hblank_21 ),
    .O(\vga/vgacore/vcnt<1>/CKMUXNOT )
  );
  defparam \vga/vgacore/vcnt<1>/YUSED .LOC = "CLB_R18C9.S1";
  X_BUF \vga/vgacore/vcnt<1>/YUSED  (
    .I(\vga/vgacore/Result<2>1 ),
    .O(\vga/vgacore/Result<2>1_0 )
  );
  defparam \vga/vgacore/Mcount_vcnt_cy<2> .LOC = "CLB_R18C9.S1";
  X_MUX2 \vga/vgacore/Mcount_vcnt_cy<2>  (
    .IA(\vga/vgacore/vcnt<1>/LOGIC_ZERO_149 ),
    .IB(\vga/vgacore/Mcount_vcnt_cy[1] ),
    .SEL(\vga/vgacore/vcnt_Eqn_2 ),
    .O(\vga/vgacore/vcnt<1>/CYMUXG )
  );
  defparam \vga/vgacore/Mcount_vcnt_xor<2> .LOC = "CLB_R18C9.S1";
  X_XOR2 \vga/vgacore/Mcount_vcnt_xor<2>  (
    .I0(\vga/vgacore/Mcount_vcnt_cy[1] ),
    .I1(\vga/vgacore/vcnt_Eqn_2 ),
    .O(\vga/vgacore/Result<2>1 )
  );
  defparam \vga/vgacore/vcnt<1>/SRMUX .LOC = "CLB_R18C9.S1";
  X_INV \vga/vgacore/vcnt<1>/SRMUX  (
    .I(reset_n_IBUF_0),
    .O(\vga/vgacore/vcnt<1>/SRMUX_OUTPUTNOT )
  );
  defparam \vga/vgacore/vcnt<1>/CYINIT .LOC = "CLB_R18C9.S1";
  X_BUF \vga/vgacore/vcnt<1>/CYINIT  (
    .I(\vga/vgacore/vcnt<0>/CYMUXG ),
    .O(\vga/vgacore/vcnt<1>/CYINIT_150 )
  );
  defparam \vga/vgacore/vcnt<3>/LOGIC_ZERO .LOC = "CLB_R17C9.S1";
  X_ZERO \vga/vgacore/vcnt<3>/LOGIC_ZERO  (
    .O(\vga/vgacore/vcnt<3>/LOGIC_ZERO_152 )
  );
  defparam \vga/vgacore/Mcount_vcnt_cy<3> .LOC = "CLB_R17C9.S1";
  X_MUX2 \vga/vgacore/Mcount_vcnt_cy<3>  (
    .IA(\vga/vgacore/vcnt<3>/LOGIC_ZERO_152 ),
    .IB(\vga/vgacore/vcnt<3>/CYINIT_153 ),
    .SEL(\vga/vgacore/vcnt_Eqn_3_151 ),
    .O(\vga/vgacore/Mcount_vcnt_cy[3] )
  );
  defparam \vga/vgacore/Mcount_vcnt_xor<3> .LOC = "CLB_R17C9.S1";
  X_XOR2 \vga/vgacore/Mcount_vcnt_xor<3>  (
    .I0(\vga/vgacore/vcnt<3>/CYINIT_153 ),
    .I1(\vga/vgacore/vcnt_Eqn_3_151 ),
    .O(\vga/vgacore/Result<3>1 )
  );
  defparam \vga/vgacore/vcnt_Eqn_3 .INIT = 16'h2A0A;
  defparam \vga/vgacore/vcnt_Eqn_3 .LOC = "CLB_R17C9.S1";
  X_LUT4 \vga/vgacore/vcnt_Eqn_3  (
    .ADR0(\vga/vgacore/vcnt [3]),
    .ADR1(N786_0),
    .ADR2(\vga/vgacore/vcnt [9]),
    .ADR3(\vga/vgacore/N51_0 ),
    .O(\vga/vgacore/vcnt_Eqn_3_151 )
  );
  defparam \vga/vgacore/vcnt_Eqn_41 .INIT = 16'h3030;
  defparam \vga/vgacore/vcnt_Eqn_41 .LOC = "CLB_R17C9.S1";
  X_LUT4 \vga/vgacore/vcnt_Eqn_41  (
    .ADR0(VCC),
    .ADR1(\vga/vgacore/vcnt [9]),
    .ADR2(\vga/vgacore/vcnt [4]),
    .ADR3(VCC),
    .O(\vga/vgacore/vcnt_Eqn_4 )
  );
  defparam \vga/vgacore/vcnt<3>/CKINV .LOC = "CLB_R17C9.S1";
  X_INV \vga/vgacore/vcnt<3>/CKINV  (
    .I(\vga/vgacore/hblank_21 ),
    .O(\vga/vgacore/vcnt<3>/CKMUXNOT )
  );
  defparam \vga/vgacore/Mcount_vcnt_cy<4> .LOC = "CLB_R17C9.S1";
  X_MUX2 \vga/vgacore/Mcount_vcnt_cy<4>  (
    .IA(\vga/vgacore/vcnt<3>/LOGIC_ZERO_152 ),
    .IB(\vga/vgacore/Mcount_vcnt_cy[3] ),
    .SEL(\vga/vgacore/vcnt_Eqn_4 ),
    .O(\vga/vgacore/vcnt<3>/CYMUXG )
  );
  defparam \vga/vgacore/Mcount_vcnt_xor<4> .LOC = "CLB_R17C9.S1";
  X_XOR2 \vga/vgacore/Mcount_vcnt_xor<4>  (
    .I0(\vga/vgacore/Mcount_vcnt_cy[3] ),
    .I1(\vga/vgacore/vcnt_Eqn_4 ),
    .O(\vga/vgacore/Result<4>1 )
  );
  defparam \vga/vgacore/vcnt<3>/SRMUX .LOC = "CLB_R17C9.S1";
  X_INV \vga/vgacore/vcnt<3>/SRMUX  (
    .I(reset_n_IBUF_0),
    .O(\vga/vgacore/vcnt<3>/SRMUX_OUTPUTNOT )
  );
  defparam \vga/vgacore/vcnt<3>/CYINIT .LOC = "CLB_R17C9.S1";
  X_BUF \vga/vgacore/vcnt<3>/CYINIT  (
    .I(\vga/vgacore/vcnt<1>/CYMUXG ),
    .O(\vga/vgacore/vcnt<3>/CYINIT_153 )
  );
  defparam \vga/vgacore/vcnt<5>/LOGIC_ZERO .LOC = "CLB_R16C9.S1";
  X_ZERO \vga/vgacore/vcnt<5>/LOGIC_ZERO  (
    .O(\vga/vgacore/vcnt<5>/LOGIC_ZERO_154 )
  );
  defparam \vga/vgacore/Mcount_vcnt_cy<5> .LOC = "CLB_R16C9.S1";
  X_MUX2 \vga/vgacore/Mcount_vcnt_cy<5>  (
    .IA(\vga/vgacore/vcnt<5>/LOGIC_ZERO_154 ),
    .IB(\vga/vgacore/vcnt<5>/CYINIT_155 ),
    .SEL(\vga/vgacore/vcnt_Eqn_5 ),
    .O(\vga/vgacore/Mcount_vcnt_cy[5] )
  );
  defparam \vga/vgacore/Mcount_vcnt_xor<5> .LOC = "CLB_R16C9.S1";
  X_XOR2 \vga/vgacore/Mcount_vcnt_xor<5>  (
    .I0(\vga/vgacore/vcnt<5>/CYINIT_155 ),
    .I1(\vga/vgacore/vcnt_Eqn_5 ),
    .O(\vga/vgacore/Result<5>1 )
  );
  defparam \vga/vgacore/vcnt_Eqn_51 .INIT = 16'h5500;
  defparam \vga/vgacore/vcnt_Eqn_51 .LOC = "CLB_R16C9.S1";
  X_LUT4 \vga/vgacore/vcnt_Eqn_51  (
    .ADR0(\vga/vgacore/vcnt [9]),
    .ADR1(VCC),
    .ADR2(VCC),
    .ADR3(\vga/vgacore/vcnt [5]),
    .O(\vga/vgacore/vcnt_Eqn_5 )
  );
  defparam \vga/vgacore/vcnt_Eqn_61 .INIT = 16'h0A0A;
  defparam \vga/vgacore/vcnt_Eqn_61 .LOC = "CLB_R16C9.S1";
  X_LUT4 \vga/vgacore/vcnt_Eqn_61  (
    .ADR0(\vga/vgacore/vcnt [6]),
    .ADR1(VCC),
    .ADR2(\vga/vgacore/vcnt [9]),
    .ADR3(VCC),
    .O(\vga/vgacore/vcnt_Eqn_6 )
  );
  defparam \vga/vgacore/vcnt<5>/CKINV .LOC = "CLB_R16C9.S1";
  X_INV \vga/vgacore/vcnt<5>/CKINV  (
    .I(\vga/vgacore/hblank_21 ),
    .O(\vga/vgacore/vcnt<5>/CKMUXNOT )
  );
  defparam \vga/vgacore/Mcount_vcnt_cy<6> .LOC = "CLB_R16C9.S1";
  X_MUX2 \vga/vgacore/Mcount_vcnt_cy<6>  (
    .IA(\vga/vgacore/vcnt<5>/LOGIC_ZERO_154 ),
    .IB(\vga/vgacore/Mcount_vcnt_cy[5] ),
    .SEL(\vga/vgacore/vcnt_Eqn_6 ),
    .O(\vga/vgacore/vcnt<5>/CYMUXG )
  );
  defparam \vga/vgacore/Mcount_vcnt_xor<6> .LOC = "CLB_R16C9.S1";
  X_XOR2 \vga/vgacore/Mcount_vcnt_xor<6>  (
    .I0(\vga/vgacore/Mcount_vcnt_cy[5] ),
    .I1(\vga/vgacore/vcnt_Eqn_6 ),
    .O(\vga/vgacore/Result<6>1 )
  );
  defparam \vga/vgacore/vcnt<5>/SRMUX .LOC = "CLB_R16C9.S1";
  X_INV \vga/vgacore/vcnt<5>/SRMUX  (
    .I(reset_n_IBUF_0),
    .O(\vga/vgacore/vcnt<5>/SRMUX_OUTPUTNOT )
  );
  defparam \vga/vgacore/vcnt<5>/CYINIT .LOC = "CLB_R16C9.S1";
  X_BUF \vga/vgacore/vcnt<5>/CYINIT  (
    .I(\vga/vgacore/vcnt<3>/CYMUXG ),
    .O(\vga/vgacore/vcnt<5>/CYINIT_155 )
  );
  defparam \vga/vgacore/vcnt<7>/LOGIC_ZERO .LOC = "CLB_R15C9.S1";
  X_ZERO \vga/vgacore/vcnt<7>/LOGIC_ZERO  (
    .O(\vga/vgacore/vcnt<7>/LOGIC_ZERO_156 )
  );
  defparam \vga/vgacore/Mcount_vcnt_cy<7> .LOC = "CLB_R15C9.S1";
  X_MUX2 \vga/vgacore/Mcount_vcnt_cy<7>  (
    .IA(\vga/vgacore/vcnt<7>/LOGIC_ZERO_156 ),
    .IB(\vga/vgacore/vcnt<7>/CYINIT_157 ),
    .SEL(\vga/vgacore/vcnt_Eqn_7 ),
    .O(\vga/vgacore/Mcount_vcnt_cy[7] )
  );
  defparam \vga/vgacore/Mcount_vcnt_xor<7> .LOC = "CLB_R15C9.S1";
  X_XOR2 \vga/vgacore/Mcount_vcnt_xor<7>  (
    .I0(\vga/vgacore/vcnt<7>/CYINIT_157 ),
    .I1(\vga/vgacore/vcnt_Eqn_7 ),
    .O(\vga/vgacore/Result<7>1 )
  );
  defparam \vga/vgacore/vcnt_Eqn_71 .INIT = 16'h5500;
  defparam \vga/vgacore/vcnt_Eqn_71 .LOC = "CLB_R15C9.S1";
  X_LUT4 \vga/vgacore/vcnt_Eqn_71  (
    .ADR0(\vga/vgacore/vcnt [9]),
    .ADR1(VCC),
    .ADR2(VCC),
    .ADR3(\vga/vgacore/vcnt [7]),
    .O(\vga/vgacore/vcnt_Eqn_7 )
  );
  defparam \vga/vgacore/vcnt_Eqn_81 .INIT = 16'h0F00;
  defparam \vga/vgacore/vcnt_Eqn_81 .LOC = "CLB_R15C9.S1";
  X_LUT4 \vga/vgacore/vcnt_Eqn_81  (
    .ADR0(VCC),
    .ADR1(VCC),
    .ADR2(\vga/vgacore/vcnt [9]),
    .ADR3(\vga/vgacore/vcnt [8]),
    .O(\vga/vgacore/vcnt_Eqn_8 )
  );
  defparam \vga/vgacore/vcnt<7>/CKINV .LOC = "CLB_R15C9.S1";
  X_INV \vga/vgacore/vcnt<7>/CKINV  (
    .I(\vga/vgacore/hblank_21 ),
    .O(\vga/vgacore/vcnt<7>/CKMUXNOT )
  );
  defparam \vga/vgacore/Mcount_vcnt_cy<8> .LOC = "CLB_R15C9.S1";
  X_MUX2 \vga/vgacore/Mcount_vcnt_cy<8>  (
    .IA(\vga/vgacore/vcnt<7>/LOGIC_ZERO_156 ),
    .IB(\vga/vgacore/Mcount_vcnt_cy[7] ),
    .SEL(\vga/vgacore/vcnt_Eqn_8 ),
    .O(\vga/vgacore/vcnt<7>/CYMUXG )
  );
  defparam \vga/vgacore/Mcount_vcnt_xor<8> .LOC = "CLB_R15C9.S1";
  X_XOR2 \vga/vgacore/Mcount_vcnt_xor<8>  (
    .I0(\vga/vgacore/Mcount_vcnt_cy[7] ),
    .I1(\vga/vgacore/vcnt_Eqn_8 ),
    .O(\vga/vgacore/Result<8>1 )
  );
  defparam \vga/vgacore/vcnt<7>/SRMUX .LOC = "CLB_R15C9.S1";
  X_INV \vga/vgacore/vcnt<7>/SRMUX  (
    .I(reset_n_IBUF_0),
    .O(\vga/vgacore/vcnt<7>/SRMUX_OUTPUTNOT )
  );
  defparam \vga/vgacore/vcnt<7>/CYINIT .LOC = "CLB_R15C9.S1";
  X_BUF \vga/vgacore/vcnt<7>/CYINIT  (
    .I(\vga/vgacore/vcnt<5>/CYMUXG ),
    .O(\vga/vgacore/vcnt<7>/CYINIT_157 )
  );
  defparam \vga/vgacore/Mcount_vcnt_xor<9> .LOC = "CLB_R14C9.S1";
  X_XOR2 \vga/vgacore/Mcount_vcnt_xor<9>  (
    .I0(\vga/vgacore/vcnt<9>/CYINIT_158 ),
    .I1(\vga/vgacore/vcnt_Eqn_9 ),
    .O(\vga/vgacore/Result<9>1 )
  );
  defparam \vga/vgacore/vcnt_Eqn_92 .INIT = 16'h8800;
  defparam \vga/vgacore/vcnt_Eqn_92 .LOC = "CLB_R14C9.S1";
  X_LUT4 \vga/vgacore/vcnt_Eqn_92  (
    .ADR0(\vga/vgacore/vcnt [9]),
    .ADR1(\vga/vgacore/N0 ),
    .ADR2(VCC),
    .ADR3(\vga/vgacore/N51_0 ),
    .O(\vga/vgacore/vcnt_Eqn_9 )
  );
  defparam \vga/vgacore/vcnt<9>/CKINV .LOC = "CLB_R14C9.S1";
  X_INV \vga/vgacore/vcnt<9>/CKINV  (
    .I(\vga/vgacore/hblank_21 ),
    .O(\vga/vgacore/vcnt<9>/CKMUXNOT )
  );
  defparam \vga/vgacore/vcnt<9>/CYINIT .LOC = "CLB_R14C9.S1";
  X_BUF \vga/vgacore/vcnt<9>/CYINIT  (
    .I(\vga/vgacore/vcnt<7>/CYMUXG ),
    .O(\vga/vgacore/vcnt<9>/CYINIT_158 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<0>1437 .INIT = 16'h0F1B;
  defparam \vga/scancode_convert/scancode_rom/data<0>1437 .LOC = "CLB_R16C34.S1";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<0>1437  (
    .ADR0(\vga/scancode_convert/sc [4]),
    .ADR1(\vga/scancode_convert/sc [0]),
    .ADR2(\vga/scancode_convert/sc [1]),
    .ADR3(\vga/scancode_convert/raise ),
    .O(\vga/scancode_convert/scancode_rom/data<0>1437/O_pack_1 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<0>1492 .INIT = 16'hF3B3;
  defparam \vga/scancode_convert/scancode_rom/data<0>1492 .LOC = "CLB_R16C34.S1";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<0>1492  (
    .ADR0(\vga/scancode_convert/sc [3]),
    .ADR1(\vga/scancode_convert/sc [2]),
    .ADR2(\vga/scancode_convert/scancode_rom/data<0>1_map1526_0 ),
    .ADR3(\vga/scancode_convert/scancode_rom/data<0>1437/O ),
    .O(\vga/scancode_convert/scancode_rom/data<0>1_map1529 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<0>1437/O/XUSED .LOC = "CLB_R16C34.S1";
  X_BUF \vga/scancode_convert/scancode_rom/data<0>1437/O/XUSED  (
    .I(\vga/scancode_convert/scancode_rom/data<0>1437/O_pack_1 ),
    .O(\vga/scancode_convert/scancode_rom/data<0>1437/O )
  );
  defparam \vga/scancode_convert/scancode_rom/data<0>1437/O/YUSED .LOC = "CLB_R16C34.S1";
  X_BUF \vga/scancode_convert/scancode_rom/data<0>1437/O/YUSED  (
    .I(\vga/scancode_convert/scancode_rom/data<0>1_map1529 ),
    .O(\vga/scancode_convert/scancode_rom/data<0>1_map1529_0 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<0>1110 .INIT = 16'h3332;
  defparam \vga/scancode_convert/scancode_rom/data<0>1110 .LOC = "CLB_R13C33.S1";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<0>1110  (
    .ADR0(\vga/scancode_convert/shift_24 ),
    .ADR1(\vga/scancode_convert/sc_1_1_23 ),
    .ADR2(\vga/scancode_convert/capslock_25 ),
    .ADR3(\vga/scancode_convert/ctrl_22 ),
    .O(\vga/scancode_convert/scancode_rom/N9_pack_1 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<0>1469 .INIT = 16'h3337;
  defparam \vga/scancode_convert/scancode_rom/data<0>1469 .LOC = "CLB_R13C33.S1";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<0>1469  (
    .ADR0(\vga/scancode_convert/sc [4]),
    .ADR1(\vga/scancode_convert/sc [3]),
    .ADR2(\vga/scancode_convert/sc [0]),
    .ADR3(\vga/scancode_convert/scancode_rom/N9 ),
    .O(\vga/scancode_convert/scancode_rom/data<0>1_map1526 )
  );
  defparam \vga/scancode_convert/scancode_rom/N9/XUSED .LOC = "CLB_R13C33.S1";
  X_BUF \vga/scancode_convert/scancode_rom/N9/XUSED  (
    .I(\vga/scancode_convert/scancode_rom/N9_pack_1 ),
    .O(\vga/scancode_convert/scancode_rom/N9 )
  );
  defparam \vga/scancode_convert/scancode_rom/N9/YUSED .LOC = "CLB_R13C33.S1";
  X_BUF \vga/scancode_convert/scancode_rom/N9/YUSED  (
    .I(\vga/scancode_convert/scancode_rom/data<0>1_map1526 ),
    .O(\vga/scancode_convert/scancode_rom/data<0>1_map1526_0 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<0>1539 .INIT = 16'hEA00;
  defparam \vga/scancode_convert/scancode_rom/data<0>1539 .LOC = "CLB_R16C34.S0";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<0>1539  (
    .ADR0(\vga/scancode_convert/sc [5]),
    .ADR1(\vga/scancode_convert/scancode_rom/data<0>1_map1529_0 ),
    .ADR2(\vga/scancode_convert/scancode_rom/data<0>1_map1503_0 ),
    .ADR3(\vga/scancode_convert/scancode_rom/data<0>1_map1534_0 ),
    .O(\vga/scancode_convert/scancode_rom/data<0>1539/O_pack_1 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<0>1569 .INIT = 16'hF404;
  defparam \vga/scancode_convert/scancode_rom/data<0>1569 .LOC = "CLB_R16C34.S0";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<0>1569  (
    .ADR0(N3104_0),
    .ADR1(\vga/scancode_convert/scancode_rom/data<0>1_map1445_0 ),
    .ADR2(\vga/scancode_convert/sc [6]),
    .ADR3(\vga/scancode_convert/scancode_rom/data<0>1539/O ),
    .O(\vga/scancode_convert/rom_data [0])
  );
  defparam \vga/scancode_convert/ascii<0>/XUSED .LOC = "CLB_R16C34.S0";
  X_BUF \vga/scancode_convert/ascii<0>/XUSED  (
    .I(\vga/scancode_convert/scancode_rom/data<0>1539/O_pack_1 ),
    .O(\vga/scancode_convert/scancode_rom/data<0>1539/O )
  );
  defparam \vga/scancode_convert/ascii_0 .LOC = "CLB_R16C34.S0";
  defparam \vga/scancode_convert/ascii_0 .INIT = 1'b0;
  X_FF \vga/scancode_convert/ascii_0  (
    .I(\vga/scancode_convert/rom_data [0]),
    .CE(\vga/scancode_convert/_or0000_0 ),
    .CLK(gray_cnt_FFd1_0),
    .SET(GND),
    .RST(GND),
    .O(\vga/scancode_convert/ascii [0])
  );
  defparam \vga/scancode_convert/scancode_rom/data<6>1181 .INIT = 16'h15FF;
  defparam \vga/scancode_convert/scancode_rom/data<6>1181 .LOC = "CLB_R11C36.S0";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<6>1181  (
    .ADR0(\vga/scancode_convert/sc [1]),
    .ADR1(\vga/scancode_convert/sc [0]),
    .ADR2(\vga/scancode_convert/sc [4]),
    .ADR3(\vga/scancode_convert/sc [3]),
    .O(\vga/scancode_convert/scancode_rom/data<6>1_map1831_pack_1 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<6>1201_SW1 .INIT = 16'hF575;
  defparam \vga/scancode_convert/scancode_rom/data<6>1201_SW1 .LOC = "CLB_R11C36.S0";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<6>1201_SW1  (
    .ADR0(\vga/scancode_convert/sc [5]),
    .ADR1(\vga/scancode_convert/sc [2]),
    .ADR2(\vga/scancode_convert/scancode_rom/data<6>1_map1808_0 ),
    .ADR3(\vga/scancode_convert/scancode_rom/data<6>1_map1831 ),
    .O(N3085)
  );
  defparam \vga/scancode_convert/scancode_rom/data<6>1_map1831/XUSED .LOC = "CLB_R11C36.S0";
  X_BUF \vga/scancode_convert/scancode_rom/data<6>1_map1831/XUSED  (
    .I(\vga/scancode_convert/scancode_rom/data<6>1_map1831_pack_1 ),
    .O(\vga/scancode_convert/scancode_rom/data<6>1_map1831 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<6>1_map1831/YUSED .LOC = "CLB_R11C36.S0";
  X_BUF \vga/scancode_convert/scancode_rom/data<6>1_map1831/YUSED  (
    .I(N3085),
    .O(N3085_0)
  );
  defparam \vga/scancode_convert/_cmp_eq00041_SW0 .INIT = 16'hFAFF;
  defparam \vga/scancode_convert/_cmp_eq00041_SW0 .LOC = "CLB_R11C28.S0";
  X_LUT4 \vga/scancode_convert/_cmp_eq00041_SW0  (
    .ADR0(\vga/ps2/sc_r [3]),
    .ADR1(VCC),
    .ADR2(\vga/ps2/sc_r [0]),
    .ADR3(\vga/ps2/sc_r [4]),
    .O(\vga/scancode_convert/_cmp_eq00041_SW0/O_pack_1 )
  );
  defparam \vga/scancode_convert/_cmp_eq00041 .INIT = 16'h0001;
  defparam \vga/scancode_convert/_cmp_eq00041 .LOC = "CLB_R11C28.S0";
  X_LUT4 \vga/scancode_convert/_cmp_eq00041  (
    .ADR0(\vga/ps2/sc_r [6]),
    .ADR1(\vga/ps2/sc_r [5]),
    .ADR2(\vga/ps2/sc_r [7]),
    .ADR3(\vga/scancode_convert/_cmp_eq00041_SW0/O ),
    .O(\vga/scancode_convert/N10 )
  );
  defparam \vga/scancode_convert/_cmp_eq00041_SW0/O/XUSED .LOC = "CLB_R11C28.S0";
  X_BUF \vga/scancode_convert/_cmp_eq00041_SW0/O/XUSED  (
    .I(\vga/scancode_convert/_cmp_eq00041_SW0/O_pack_1 ),
    .O(\vga/scancode_convert/_cmp_eq00041_SW0/O )
  );
  defparam \vga/scancode_convert/_cmp_eq00041_SW0/O/YUSED .LOC = "CLB_R11C28.S0";
  X_BUF \vga/scancode_convert/_cmp_eq00041_SW0/O/YUSED  (
    .I(\vga/scancode_convert/N10 ),
    .O(\vga/scancode_convert/N10_0 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<1>2465 .INIT = 16'hA888;
  defparam \vga/scancode_convert/scancode_rom/data<1>2465 .LOC = "CLB_R15C36.S1";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<1>2465  (
    .ADR0(\vga/scancode_convert/scancode_rom/data<0>1_map1534_0 ),
    .ADR1(\vga/scancode_convert/sc [5]),
    .ADR2(\vga/scancode_convert/scancode_rom/data<1>2_map1751_0 ),
    .ADR3(\vga/scancode_convert/scancode_rom/data<1>2_map1774_0 ),
    .O(\vga/scancode_convert/scancode_rom/data<1>2465/O_pack_1 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<1>2497 .INIT = 16'hAE04;
  defparam \vga/scancode_convert/scancode_rom/data<1>2497 .LOC = "CLB_R15C36.S1";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<1>2497  (
    .ADR0(\vga/scancode_convert/sc [6]),
    .ADR1(\vga/scancode_convert/scancode_rom/data<1>2_map1690_0 ),
    .ADR2(N3106_0),
    .ADR3(\vga/scancode_convert/scancode_rom/data<1>2465/O ),
    .O(\vga/scancode_convert/rom_data [1])
  );
  defparam \vga/scancode_convert/ascii<1>/XUSED .LOC = "CLB_R15C36.S1";
  X_BUF \vga/scancode_convert/ascii<1>/XUSED  (
    .I(\vga/scancode_convert/scancode_rom/data<1>2465/O_pack_1 ),
    .O(\vga/scancode_convert/scancode_rom/data<1>2465/O )
  );
  defparam \vga/scancode_convert/ascii_1 .LOC = "CLB_R15C36.S1";
  defparam \vga/scancode_convert/ascii_1 .INIT = 1'b0;
  X_FF \vga/scancode_convert/ascii_1  (
    .I(\vga/scancode_convert/rom_data [1]),
    .CE(\vga/scancode_convert/_or0000_0 ),
    .CLK(gray_cnt_FFd1_0),
    .SET(GND),
    .RST(GND),
    .O(\vga/scancode_convert/ascii [1])
  );
  defparam \vga/scancode_convert/scancode_rom/data<2>1264 .INIT = 16'h0109;
  defparam \vga/scancode_convert/scancode_rom/data<2>1264 .LOC = "CLB_R15C35.S1";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<2>1264  (
    .ADR0(\vga/scancode_convert/sc [0]),
    .ADR1(\vga/scancode_convert/sc [4]),
    .ADR2(\vga/scancode_convert/sc [1]),
    .ADR3(\vga/scancode_convert/raise ),
    .O(\vga/scancode_convert/scancode_rom/data<2>1264/O_pack_1 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<2>1329 .INIT = 16'hF3B3;
  defparam \vga/scancode_convert/scancode_rom/data<2>1329 .LOC = "CLB_R15C35.S1";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<2>1329  (
    .ADR0(\vga/scancode_convert/sc [3]),
    .ADR1(\vga/scancode_convert/sc [2]),
    .ADR2(\vga/scancode_convert/scancode_rom/data<2>1_map1121_0 ),
    .ADR3(\vga/scancode_convert/scancode_rom/data<2>1264/O ),
    .O(\vga/scancode_convert/scancode_rom/data<2>1_map1124 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<2>1264/O/XUSED .LOC = "CLB_R15C35.S1";
  X_BUF \vga/scancode_convert/scancode_rom/data<2>1264/O/XUSED  (
    .I(\vga/scancode_convert/scancode_rom/data<2>1264/O_pack_1 ),
    .O(\vga/scancode_convert/scancode_rom/data<2>1264/O )
  );
  defparam \vga/scancode_convert/scancode_rom/data<2>1264/O/YUSED .LOC = "CLB_R15C35.S1";
  X_BUF \vga/scancode_convert/scancode_rom/data<2>1264/O/YUSED  (
    .I(\vga/scancode_convert/scancode_rom/data<2>1_map1124 ),
    .O(\vga/scancode_convert/scancode_rom/data<2>1_map1124_0 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<2>1410 .INIT = 16'h3323;
  defparam \vga/scancode_convert/scancode_rom/data<2>1410 .LOC = "CLB_R15C37.S1";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<2>1410  (
    .ADR0(\vga/scancode_convert/sc [2]),
    .ADR1(\vga/scancode_convert/sc [5]),
    .ADR2(N3126_0),
    .ADR3(\vga/scancode_convert/scancode_rom/data<2>1_map1129_0 ),
    .O(\vga/scancode_convert/scancode_rom/data<2>1410/O_pack_1 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<2>1458 .INIT = 16'hE222;
  defparam \vga/scancode_convert/scancode_rom/data<2>1458 .LOC = "CLB_R15C37.S1";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<2>1458  (
    .ADR0(\vga/scancode_convert/scancode_rom/data<2>1_map1098_0 ),
    .ADR1(\vga/scancode_convert/sc [6]),
    .ADR2(\vga/scancode_convert/scancode_rom/data<2>1_map1124_0 ),
    .ADR3(\vga/scancode_convert/scancode_rom/data<2>1410/O ),
    .O(\vga/scancode_convert/rom_data [2])
  );
  defparam \vga/scancode_convert/ascii<2>/XUSED .LOC = "CLB_R15C37.S1";
  X_BUF \vga/scancode_convert/ascii<2>/XUSED  (
    .I(\vga/scancode_convert/scancode_rom/data<2>1410/O_pack_1 ),
    .O(\vga/scancode_convert/scancode_rom/data<2>1410/O )
  );
  defparam \vga/scancode_convert/ascii_2 .LOC = "CLB_R15C37.S1";
  defparam \vga/scancode_convert/ascii_2 .INIT = 1'b0;
  X_FF \vga/scancode_convert/ascii_2  (
    .I(\vga/scancode_convert/rom_data [2]),
    .CE(\vga/scancode_convert/_or0000_0 ),
    .CLK(gray_cnt_FFd1_0),
    .SET(GND),
    .RST(GND),
    .O(\vga/scancode_convert/ascii [2])
  );
  defparam \vga/scancode_convert/scancode_rom/data<3>199 .INIT = 16'h4A00;
  defparam \vga/scancode_convert/scancode_rom/data<3>199 .LOC = "CLB_R18C36.S0";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<3>199  (
    .ADR0(\vga/scancode_convert/sc [0]),
    .ADR1(\vga/scancode_convert/raise ),
    .ADR2(\vga/scancode_convert/sc [1]),
    .ADR3(\vga/scancode_convert/sc [4]),
    .O(\vga/scancode_convert/scancode_rom/data<3>199/O_pack_1 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<3>1125 .INIT = 16'h7F73;
  defparam \vga/scancode_convert/scancode_rom/data<3>1125 .LOC = "CLB_R18C36.S0";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<3>1125  (
    .ADR0(\vga/scancode_convert/scancode_rom/N7 ),
    .ADR1(\vga/scancode_convert/sc [2]),
    .ADR2(\vga/scancode_convert/sc [3]),
    .ADR3(\vga/scancode_convert/scancode_rom/data<3>199/O ),
    .O(\vga/scancode_convert/scancode_rom/data<3>1_map1185 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<3>199/O/XUSED .LOC = "CLB_R18C36.S0";
  X_BUF \vga/scancode_convert/scancode_rom/data<3>199/O/XUSED  (
    .I(\vga/scancode_convert/scancode_rom/data<3>199/O_pack_1 ),
    .O(\vga/scancode_convert/scancode_rom/data<3>199/O )
  );
  defparam \vga/scancode_convert/scancode_rom/data<3>199/O/YUSED .LOC = "CLB_R18C36.S0";
  X_BUF \vga/scancode_convert/scancode_rom/data<3>199/O/YUSED  (
    .I(\vga/scancode_convert/scancode_rom/data<3>1_map1185 ),
    .O(\vga/scancode_convert/scancode_rom/data<3>1_map1185_0 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<4>1308_SW1 .INIT = 16'hEF95;
  defparam \vga/scancode_convert/scancode_rom/data<4>1308_SW1 .LOC = "CLB_R12C35.S0";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<4>1308_SW1  (
    .ADR0(\vga/scancode_convert/sc [3]),
    .ADR1(\vga/scancode_convert/sc [0]),
    .ADR2(\vga/scancode_convert/sc [4]),
    .ADR3(\vga/scancode_convert/sc [1]),
    .O(\vga/scancode_convert/scancode_rom/data<4>1308_SW1/O_pack_1 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<4>1308 .INIT = 16'h57F7;
  defparam \vga/scancode_convert/scancode_rom/data<4>1308 .LOC = "CLB_R12C35.S0";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<4>1308  (
    .ADR0(\vga/scancode_convert/sc [2]),
    .ADR1(N3174_0),
    .ADR2(\vga/scancode_convert/raise ),
    .ADR3(\vga/scancode_convert/scancode_rom/data<4>1308_SW1/O ),
    .O(\vga/scancode_convert/scancode_rom/data<4>1_map1609 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<4>1308_SW1/O/XUSED .LOC = "CLB_R12C35.S0";
  X_BUF \vga/scancode_convert/scancode_rom/data<4>1308_SW1/O/XUSED  (
    .I(\vga/scancode_convert/scancode_rom/data<4>1308_SW1/O_pack_1 ),
    .O(\vga/scancode_convert/scancode_rom/data<4>1308_SW1/O )
  );
  defparam \vga/scancode_convert/scancode_rom/data<4>1308_SW1/O/YUSED .LOC = "CLB_R12C35.S0";
  X_BUF \vga/scancode_convert/scancode_rom/data<4>1308_SW1/O/YUSED  (
    .I(\vga/scancode_convert/scancode_rom/data<4>1_map1609 ),
    .O(\vga/scancode_convert/scancode_rom/data<4>1_map1609_0 )
  );
  defparam \vga/scancode_convert/_cmp_eq000211 .INIT = 16'h0008;
  defparam \vga/scancode_convert/_cmp_eq000211 .LOC = "CLB_R10C29.S0";
  X_LUT4 \vga/scancode_convert/_cmp_eq000211  (
    .ADR0(\vga/ps2/sc_r [4]),
    .ADR1(\vga/ps2/sc_r [6]),
    .ADR2(\vga/ps2/sc_r [1]),
    .ADR3(\vga/ps2/sc_r [2]),
    .O(\vga/scancode_convert/N31_pack_1 )
  );
  defparam \vga/scancode_convert/_cmp_eq000221 .INIT = 16'h0200;
  defparam \vga/scancode_convert/_cmp_eq000221 .LOC = "CLB_R10C29.S0";
  X_LUT4 \vga/scancode_convert/_cmp_eq000221  (
    .ADR0(\vga/ps2/sc_r [3]),
    .ADR1(\vga/ps2/sc_r [5]),
    .ADR2(\vga/ps2/sc_r [7]),
    .ADR3(\vga/scancode_convert/N31 ),
    .O(\vga/scancode_convert/N11 )
  );
  defparam \vga/scancode_convert/N31/XUSED .LOC = "CLB_R10C29.S0";
  X_BUF \vga/scancode_convert/N31/XUSED  (
    .I(\vga/scancode_convert/N31_pack_1 ),
    .O(\vga/scancode_convert/N31 )
  );
  defparam \vga/scancode_convert/N31/YUSED .LOC = "CLB_R10C29.S0";
  X_BUF \vga/scancode_convert/N31/YUSED  (
    .I(\vga/scancode_convert/N11 ),
    .O(\vga/scancode_convert/N11_0 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<4>1392_SW0 .INIT = 16'hFFF7;
  defparam \vga/scancode_convert/scancode_rom/data<4>1392_SW0 .LOC = "CLB_R10C36.S1";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<4>1392_SW0  (
    .ADR0(\vga/scancode_convert/sc [0]),
    .ADR1(\vga/scancode_convert/scancode_rom/N9 ),
    .ADR2(\vga/scancode_convert/sc [4]),
    .ADR3(\vga/scancode_convert/sc [3]),
    .O(\vga/scancode_convert/scancode_rom/data<4>1392_SW0/O_pack_1 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<4>1620 .INIT = 16'hFB0B;
  defparam \vga/scancode_convert/scancode_rom/data<4>1620 .LOC = "CLB_R10C36.S1";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<4>1620  (
    .ADR0(\vga/scancode_convert/scancode_rom/data<4>1_map1633_0 ),
    .ADR1(\vga/scancode_convert/scancode_rom/data<4>1392_SW0/O ),
    .ADR2(\vga/scancode_convert/sc [2]),
    .ADR3(\vga/scancode_convert/scancode_rom/data<4>1_map1666_0 ),
    .O(\vga/scancode_convert/scancode_rom/data<4>1_map1669 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<4>1392_SW0/O/XUSED .LOC = "CLB_R10C36.S1";
  X_BUF \vga/scancode_convert/scancode_rom/data<4>1392_SW0/O/XUSED  (
    .I(\vga/scancode_convert/scancode_rom/data<4>1392_SW0/O_pack_1 ),
    .O(\vga/scancode_convert/scancode_rom/data<4>1392_SW0/O )
  );
  defparam \vga/scancode_convert/scancode_rom/data<4>1392_SW0/O/YUSED .LOC = "CLB_R10C36.S1";
  X_BUF \vga/scancode_convert/scancode_rom/data<4>1392_SW0/O/YUSED  (
    .I(\vga/scancode_convert/scancode_rom/data<4>1_map1669 ),
    .O(\vga/scancode_convert/scancode_rom/data<4>1_map1669_0 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<6>1247 .INIT = 16'hA808;
  defparam \vga/scancode_convert/scancode_rom/data<6>1247 .LOC = "CLB_R11C37.S1";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<6>1247  (
    .ADR0(\vga/scancode_convert/scancode_rom/data<6>1_map1803_0 ),
    .ADR1(N3084_0),
    .ADR2(\vga/scancode_convert/scancode_rom/data<6>1_map1820_0 ),
    .ADR3(N3085_0),
    .O(\vga/scancode_convert/scancode_rom/data<6>1247/O_pack_1 )
  );
  defparam \vga/scancode_convert/_mux0008<6>1 .INIT = 16'h5A78;
  defparam \vga/scancode_convert/_mux0008<6>1 .LOC = "CLB_R11C37.S1";
  X_LUT4 \vga/scancode_convert/_mux0008<6>1  (
    .ADR0(\vga/scancode_convert/scancode_rom/data<6>1_map1863_0 ),
    .ADR1(\vga/scancode_convert/sc [6]),
    .ADR2(\vga/scancode_convert/ctrl_22 ),
    .ADR3(\vga/scancode_convert/scancode_rom/data<6>1247/O ),
    .O(\vga/scancode_convert/_mux0008 [6])
  );
  defparam \vga/scancode_convert/ascii<6>/XUSED .LOC = "CLB_R11C37.S1";
  X_BUF \vga/scancode_convert/ascii<6>/XUSED  (
    .I(\vga/scancode_convert/scancode_rom/data<6>1247/O_pack_1 ),
    .O(\vga/scancode_convert/scancode_rom/data<6>1247/O )
  );
  defparam \vga/scancode_convert/ascii_6 .LOC = "CLB_R11C37.S1";
  defparam \vga/scancode_convert/ascii_6 .INIT = 1'b0;
  X_FF \vga/scancode_convert/ascii_6  (
    .I(\vga/scancode_convert/_mux0008 [6]),
    .CE(\vga/scancode_convert/_or0000_0 ),
    .CLK(gray_cnt_FFd1_0),
    .SET(GND),
    .RST(GND),
    .O(\vga/scancode_convert/ascii [6])
  );
  defparam \vga/scancode_convert/scancode_rom/data<5>3247 .INIT = 16'h550C;
  defparam \vga/scancode_convert/scancode_rom/data<5>3247 .LOC = "CLB_R11C34.S0";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<5>3247  (
    .ADR0(\vga/scancode_convert/raise ),
    .ADR1(\vga/scancode_convert/sc [0]),
    .ADR2(\vga/scancode_convert/sc [4]),
    .ADR3(\vga/scancode_convert/sc [1]),
    .O(\vga/scancode_convert/scancode_rom/data<5>3247/O_pack_1 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<5>3282 .INIT = 16'hFABA;
  defparam \vga/scancode_convert/scancode_rom/data<5>3282 .LOC = "CLB_R11C34.S0";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<5>3282  (
    .ADR0(\vga/scancode_convert/sc [2]),
    .ADR1(\vga/scancode_convert/sc [3]),
    .ADR2(\vga/scancode_convert/scancode_rom/data<5>3_map1276_0 ),
    .ADR3(\vga/scancode_convert/scancode_rom/data<5>3247/O ),
    .O(\vga/scancode_convert/scancode_rom/data<5>3_map1295 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<5>3247/O/XUSED .LOC = "CLB_R11C34.S0";
  X_BUF \vga/scancode_convert/scancode_rom/data<5>3247/O/XUSED  (
    .I(\vga/scancode_convert/scancode_rom/data<5>3247/O_pack_1 ),
    .O(\vga/scancode_convert/scancode_rom/data<5>3247/O )
  );
  defparam \vga/scancode_convert/scancode_rom/data<5>3247/O/YUSED .LOC = "CLB_R11C34.S0";
  X_BUF \vga/scancode_convert/scancode_rom/data<5>3247/O/YUSED  (
    .I(\vga/scancode_convert/scancode_rom/data<5>3_map1295 ),
    .O(\vga/scancode_convert/scancode_rom/data<5>3_map1295_0 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<0>152 .INIT = 16'hFFFB;
  defparam \vga/scancode_convert/scancode_rom/data<0>152 .LOC = "CLB_R12C34.S0";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<0>152  (
    .ADR0(\vga/scancode_convert/capslock_25 ),
    .ADR1(\vga/scancode_convert/sc_1_1_23 ),
    .ADR2(\vga/scancode_convert/shift_24 ),
    .ADR3(\vga/scancode_convert/ctrl_22 ),
    .O(\vga/scancode_convert/scancode_rom/N12_pack_1 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<6>1141 .INIT = 16'h2B21;
  defparam \vga/scancode_convert/scancode_rom/data<6>1141 .LOC = "CLB_R12C34.S0";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<6>1141  (
    .ADR0(\vga/scancode_convert/sc [4]),
    .ADR1(\vga/scancode_convert/sc [1]),
    .ADR2(\vga/scancode_convert/sc [0]),
    .ADR3(\vga/scancode_convert/scancode_rom/N12 ),
    .O(\vga/scancode_convert/scancode_rom/data<6>1_map1820 )
  );
  defparam \vga/scancode_convert/scancode_rom/N12/XUSED .LOC = "CLB_R12C34.S0";
  X_BUF \vga/scancode_convert/scancode_rom/N12/XUSED  (
    .I(\vga/scancode_convert/scancode_rom/N12_pack_1 ),
    .O(\vga/scancode_convert/scancode_rom/N12 )
  );
  defparam \vga/scancode_convert/scancode_rom/N12/YUSED .LOC = "CLB_R12C34.S0";
  X_BUF \vga/scancode_convert/scancode_rom/N12/YUSED  (
    .I(\vga/scancode_convert/scancode_rom/data<6>1_map1820 ),
    .O(\vga/scancode_convert/scancode_rom/data<6>1_map1820_0 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<5>3359 .INIT = 16'h134F;
  defparam \vga/scancode_convert/scancode_rom/data<5>3359 .LOC = "CLB_R11C35.S0";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<5>3359  (
    .ADR0(\vga/scancode_convert/sc [4]),
    .ADR1(\vga/scancode_convert/sc [1]),
    .ADR2(\vga/scancode_convert/raise ),
    .ADR3(\vga/scancode_convert/sc [0]),
    .O(\vga/scancode_convert/scancode_rom/data<5>3359/O_pack_1 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<5>3483 .INIT = 16'hBBB3;
  defparam \vga/scancode_convert/scancode_rom/data<5>3483 .LOC = "CLB_R11C35.S0";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<5>3483  (
    .ADR0(\vga/scancode_convert/scancode_rom/data<5>3_map1337_0 ),
    .ADR1(\vga/scancode_convert/sc [2]),
    .ADR2(\vga/scancode_convert/sc [3]),
    .ADR3(\vga/scancode_convert/scancode_rom/data<5>3359/O ),
    .O(\vga/scancode_convert/scancode_rom/data<5>3_map1340 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<5>3359/O/XUSED .LOC = "CLB_R11C35.S0";
  X_BUF \vga/scancode_convert/scancode_rom/data<5>3359/O/XUSED  (
    .I(\vga/scancode_convert/scancode_rom/data<5>3359/O_pack_1 ),
    .O(\vga/scancode_convert/scancode_rom/data<5>3359/O )
  );
  defparam \vga/scancode_convert/scancode_rom/data<5>3359/O/YUSED .LOC = "CLB_R11C35.S0";
  X_BUF \vga/scancode_convert/scancode_rom/data<5>3359/O/YUSED  (
    .I(\vga/scancode_convert/scancode_rom/data<5>3_map1340 ),
    .O(\vga/scancode_convert/scancode_rom/data<5>3_map1340_0 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<6>1333 .INIT = 16'h00AE;
  defparam \vga/scancode_convert/scancode_rom/data<6>1333 .LOC = "CLB_R12C37.S0";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<6>1333  (
    .ADR0(\vga/scancode_convert/sc [2]),
    .ADR1(\vga/scancode_convert/sc [1]),
    .ADR2(N3130_0),
    .ADR3(\vga/scancode_convert/sc [5]),
    .O(\vga/scancode_convert/scancode_rom/data<6>1333/O_pack_1 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<6>1360 .INIT = 16'hBB33;
  defparam \vga/scancode_convert/scancode_rom/data<6>1360 .LOC = "CLB_R12C37.S0";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<6>1360  (
    .ADR0(\vga/scancode_convert/scancode_rom/data<6>1_map1850_0 ),
    .ADR1(\vga/scancode_convert/sc [6]),
    .ADR2(VCC),
    .ADR3(\vga/scancode_convert/scancode_rom/data<6>1333/O ),
    .O(\vga/scancode_convert/scancode_rom/data<6>1_map1863 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<6>1333/O/XUSED .LOC = "CLB_R12C37.S0";
  X_BUF \vga/scancode_convert/scancode_rom/data<6>1333/O/XUSED  (
    .I(\vga/scancode_convert/scancode_rom/data<6>1333/O_pack_1 ),
    .O(\vga/scancode_convert/scancode_rom/data<6>1333/O )
  );
  defparam \vga/scancode_convert/scancode_rom/data<6>1333/O/YUSED .LOC = "CLB_R12C37.S0";
  X_BUF \vga/scancode_convert/scancode_rom/data<6>1333/O/YUSED  (
    .I(\vga/scancode_convert/scancode_rom/data<6>1_map1863 ),
    .O(\vga/scancode_convert/scancode_rom/data<6>1_map1863_0 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<5>3852_SW0 .INIT = 16'h0077;
  defparam \vga/scancode_convert/scancode_rom/data<5>3852_SW0 .LOC = "CLB_R13C35.S0";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<5>3852_SW0  (
    .ADR0(\vga/scancode_convert/sc [3]),
    .ADR1(\vga/scancode_convert/scancode_rom/data<5>3_map1394_0 ),
    .ADR2(VCC),
    .ADR3(\vga/scancode_convert/sc [2]),
    .O(\vga/scancode_convert/scancode_rom/data<5>3852_SW0/O_pack_1 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<5>3852 .INIT = 16'h0307;
  defparam \vga/scancode_convert/scancode_rom/data<5>3852 .LOC = "CLB_R13C35.S0";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<5>3852  (
    .ADR0(\vga/scancode_convert/sc [3]),
    .ADR1(\vga/scancode_convert/scancode_rom/data<5>3852_SW0/O ),
    .ADR2(\vga/scancode_convert/sc [5]),
    .ADR3(N3136_0),
    .O(\vga/scancode_convert/scancode_rom/data<5>3_map1416 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<5>3852_SW0/O/XUSED .LOC = "CLB_R13C35.S0";
  X_BUF \vga/scancode_convert/scancode_rom/data<5>3852_SW0/O/XUSED  (
    .I(\vga/scancode_convert/scancode_rom/data<5>3852_SW0/O_pack_1 ),
    .O(\vga/scancode_convert/scancode_rom/data<5>3852_SW0/O )
  );
  defparam \vga/scancode_convert/scancode_rom/data<5>3852_SW0/O/YUSED .LOC = "CLB_R13C35.S0";
  X_BUF \vga/scancode_convert/scancode_rom/data<5>3852_SW0/O/YUSED  (
    .I(\vga/scancode_convert/scancode_rom/data<5>3_map1416 ),
    .O(\vga/scancode_convert/scancode_rom/data<5>3_map1416_0 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<5>3664 .INIT = 16'h4037;
  defparam \vga/scancode_convert/scancode_rom/data<5>3664 .LOC = "CLB_R14C34.S1";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<5>3664  (
    .ADR0(\vga/scancode_convert/sc [1]),
    .ADR1(\vga/scancode_convert/sc [0]),
    .ADR2(\vga/scancode_convert/raise ),
    .ADR3(\vga/scancode_convert/sc [4]),
    .O(\vga/scancode_convert/scancode_rom/data<5>3664/O_pack_1 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<5>3696 .INIT = 16'hFB73;
  defparam \vga/scancode_convert/scancode_rom/data<5>3696 .LOC = "CLB_R14C34.S1";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<5>3696  (
    .ADR0(\vga/scancode_convert/sc [3]),
    .ADR1(\vga/scancode_convert/sc [2]),
    .ADR2(\vga/scancode_convert/scancode_rom/data<5>3_map1363_0 ),
    .ADR3(\vga/scancode_convert/scancode_rom/data<5>3664/O ),
    .O(\vga/scancode_convert/scancode_rom/data<5>3_map1381 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<5>3664/O/XUSED .LOC = "CLB_R14C34.S1";
  X_BUF \vga/scancode_convert/scancode_rom/data<5>3664/O/XUSED  (
    .I(\vga/scancode_convert/scancode_rom/data<5>3664/O_pack_1 ),
    .O(\vga/scancode_convert/scancode_rom/data<5>3664/O )
  );
  defparam \vga/scancode_convert/scancode_rom/data<5>3664/O/YUSED .LOC = "CLB_R14C34.S1";
  X_BUF \vga/scancode_convert/scancode_rom/data<5>3664/O/YUSED  (
    .I(\vga/scancode_convert/scancode_rom/data<5>3_map1381 ),
    .O(\vga/scancode_convert/scancode_rom/data<5>3_map1381_0 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<5>3895_SW0 .INIT = 16'h7F2A;
  defparam \vga/scancode_convert/scancode_rom/data<5>3895_SW0 .LOC = "CLB_R11C35.S1";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<5>3895_SW0  (
    .ADR0(\vga/scancode_convert/sc [5]),
    .ADR1(\vga/scancode_convert/scancode_rom/data<5>3_map1340_0 ),
    .ADR2(\vga/scancode_convert/scancode_rom/data<5>3_map1295_0 ),
    .ADR3(N3112_0),
    .O(\vga/scancode_convert/scancode_rom/data<5>3895_SW0/O_pack_1 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<5>3895 .INIT = 16'h808F;
  defparam \vga/scancode_convert/scancode_rom/data<5>3895 .LOC = "CLB_R11C35.S1";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<5>3895  (
    .ADR0(\vga/scancode_convert/scancode_rom/data<5>3_map1416_0 ),
    .ADR1(\vga/scancode_convert/scancode_rom/data<5>3_map1381_0 ),
    .ADR2(\vga/scancode_convert/sc [6]),
    .ADR3(\vga/scancode_convert/scancode_rom/data<5>3895_SW0/O ),
    .O(\vga/scancode_convert/rom_data [5])
  );
  defparam \vga/scancode_convert/ascii<5>/XUSED .LOC = "CLB_R11C35.S1";
  X_BUF \vga/scancode_convert/ascii<5>/XUSED  (
    .I(\vga/scancode_convert/scancode_rom/data<5>3895_SW0/O_pack_1 ),
    .O(\vga/scancode_convert/scancode_rom/data<5>3895_SW0/O )
  );
  defparam \vga/vgacore/vcnt_Eqn_911 .INIT = 16'h0F7F;
  defparam \vga/vgacore/vcnt_Eqn_911 .LOC = "CLB_R19C9.S0";
  X_LUT4 \vga/vgacore/vcnt_Eqn_911  (
    .ADR0(\vga/vgacore/vcnt [1]),
    .ADR1(\vga/vgacore/vcnt [0]),
    .ADR2(\vga/vgacore/vcnt [3]),
    .ADR3(\vga/vgacore/vcnt [2]),
    .O(\vga/vgacore/N0_pack_1 )
  );
  defparam \vga/vgacore/vcnt_Eqn_bis_021 .INIT = 16'h3733;
  defparam \vga/vgacore/vcnt_Eqn_bis_021 .LOC = "CLB_R19C9.S0";
  X_LUT4 \vga/vgacore/vcnt_Eqn_bis_021  (
    .ADR0(\vga/vgacore/vcnt [8]),
    .ADR1(\vga/vgacore/vcnt [9]),
    .ADR2(N3108_0),
    .ADR3(\vga/vgacore/N0 ),
    .O(\vga/vgacore/vcnt_Eqn_bis_0 )
  );
  defparam \vga/vgacore/N0/XUSED .LOC = "CLB_R19C9.S0";
  X_BUF \vga/vgacore/N0/XUSED  (
    .I(\vga/vgacore/N0_pack_1 ),
    .O(\vga/vgacore/N0 )
  );
  defparam \vga/vgacore/N0/YUSED .LOC = "CLB_R19C9.S0";
  X_BUF \vga/vgacore/N0/YUSED  (
    .I(\vga/vgacore/vcnt_Eqn_bis_0 ),
    .O(\vga/vgacore/vcnt_Eqn_bis_0_0 )
  );
  defparam \vga/scancode_convert/state_FFd2-In_SW0 .INIT = 16'hF4F8;
  defparam \vga/scancode_convert/state_FFd2-In_SW0 .LOC = "CLB_R12C29.S0";
  X_LUT4 \vga/scancode_convert/state_FFd2-In_SW0  (
    .ADR0(\vga/ps2/sc_r [1]),
    .ADR1(\vga/scancode_convert/N10_0 ),
    .ADR2(\vga/scancode_convert/release_prefix_26 ),
    .ADR3(\vga/ps2/sc_r [2]),
    .O(\vga/scancode_convert/state_FFd2-In_SW0/O_pack_1 )
  );
  defparam \vga/scancode_convert/state_FFd2-In .INIT = 16'h0010;
  defparam \vga/scancode_convert/state_FFd2-In .LOC = "CLB_R12C29.S0";
  X_LUT4 \vga/scancode_convert/state_FFd2-In  (
    .ADR0(\vga/scancode_convert/_cmp_eq0000_27 ),
    .ADR1(\vga/scancode_convert/N11_0 ),
    .ADR2(\vga/scancode_convert/_and0000_0 ),
    .ADR3(\vga/scancode_convert/state_FFd2-In_SW0/O ),
    .O(\vga/scancode_convert/state_FFd2-In_159 )
  );
  defparam \vga/scancode_convert/state_FFd2/XUSED .LOC = "CLB_R12C29.S0";
  X_BUF \vga/scancode_convert/state_FFd2/XUSED  (
    .I(\vga/scancode_convert/state_FFd2-In_SW0/O_pack_1 ),
    .O(\vga/scancode_convert/state_FFd2-In_SW0/O )
  );
  defparam \vga/scancode_convert/state_FFd2 .LOC = "CLB_R12C29.S0";
  defparam \vga/scancode_convert/state_FFd2 .INIT = 1'b0;
  X_FF \vga/scancode_convert/state_FFd2  (
    .I(\vga/scancode_convert/state_FFd2-In_159 ),
    .CE(VCC),
    .CLK(gray_cnt_FFd1_0),
    .SET(GND),
    .RST(\vga/scancode_convert/state_FFd2/FFY/RST ),
    .O(\vga/scancode_convert/state_FFd2_28 )
  );
  defparam \vga/scancode_convert/state_FFd2/FFY/RSTOR .LOC = "CLB_R12C29.S0";
  X_INV \vga/scancode_convert/state_FFd2/FFY/RSTOR  (
    .I(reset_n_IBUF_0),
    .O(\vga/scancode_convert/state_FFd2/FFY/RST )
  );
  defparam \vga/scancode_convert/state_FFd3-In_SW0 .INIT = 16'h8C4C;
  defparam \vga/scancode_convert/state_FFd3-In_SW0 .LOC = "CLB_R13C29.S1";
  X_LUT4 \vga/scancode_convert/state_FFd3-In_SW0  (
    .ADR0(\vga/ps2/sc_r [2]),
    .ADR1(\vga/scancode_convert/release_prefix_26 ),
    .ADR2(\vga/scancode_convert/N10_0 ),
    .ADR3(\vga/ps2/sc_r [1]),
    .O(\vga/scancode_convert/state_FFd3-In_SW0/O_pack_1 )
  );
  defparam \vga/scancode_convert/state_FFd3-In .INIT = 16'h0200;
  defparam \vga/scancode_convert/state_FFd3-In .LOC = "CLB_R13C29.S1";
  X_LUT4 \vga/scancode_convert/state_FFd3-In  (
    .ADR0(\vga/scancode_convert/_and0000_0 ),
    .ADR1(\vga/scancode_convert/N11_0 ),
    .ADR2(\vga/scancode_convert/_cmp_eq0000_27 ),
    .ADR3(\vga/scancode_convert/state_FFd3-In_SW0/O ),
    .O(\vga/scancode_convert/state_FFd3-In_160 )
  );
  defparam \vga/scancode_convert/state_FFd3/XUSED .LOC = "CLB_R13C29.S1";
  X_BUF \vga/scancode_convert/state_FFd3/XUSED  (
    .I(\vga/scancode_convert/state_FFd3-In_SW0/O_pack_1 ),
    .O(\vga/scancode_convert/state_FFd3-In_SW0/O )
  );
  defparam \vga/scancode_convert/state_FFd3 .LOC = "CLB_R13C29.S1";
  defparam \vga/scancode_convert/state_FFd3 .INIT = 1'b0;
  X_FF \vga/scancode_convert/state_FFd3  (
    .I(\vga/scancode_convert/state_FFd3-In_160 ),
    .CE(VCC),
    .CLK(gray_cnt_FFd1_0),
    .SET(GND),
    .RST(\vga/scancode_convert/state_FFd3/FFY/RST ),
    .O(\vga/scancode_convert/state_FFd3_29 )
  );
  defparam \vga/scancode_convert/state_FFd3/FFY/RSTOR .LOC = "CLB_R13C29.S1";
  X_INV \vga/scancode_convert/state_FFd3/FFY/RSTOR  (
    .I(reset_n_IBUF_0),
    .O(\vga/scancode_convert/state_FFd3/FFY/RST )
  );
  defparam \vga/crt/_and0000_SW0 .INIT = 16'h033F;
  defparam \vga/crt/_and0000_SW0 .LOC = "CLB_R17C14.S1";
  X_LUT4 \vga/crt/_and0000_SW0  (
    .ADR0(VCC),
    .ADR1(\vga/crt/state_FFd2_12 ),
    .ADR2(\vga/crt/state_FFd1_13 ),
    .ADR3(\vga/crt/eol_0 ),
    .O(\vga/crt/_and0000_SW0/O_pack_1 )
  );
  defparam \vga/crt/_and0000 .INIT = 16'h083B;
  defparam \vga/crt/_and0000 .LOC = "CLB_R17C14.S1";
  X_LUT4 \vga/crt/_and0000  (
    .ADR0(\vga/crt_data [2]),
    .ADR1(\vga/crt/state_FFd3_11 ),
    .ADR2(N306_0),
    .ADR3(\vga/crt/_and0000_SW0/O ),
    .O(\vga/crt/_and0000_161 )
  );
  defparam \vga/crt/_and0000_SW0/O/XUSED .LOC = "CLB_R17C14.S1";
  X_BUF \vga/crt/_and0000_SW0/O/XUSED  (
    .I(\vga/crt/_and0000_SW0/O_pack_1 ),
    .O(\vga/crt/_and0000_SW0/O )
  );
  defparam \vga/crt/_and0000_SW0/O/YUSED .LOC = "CLB_R17C14.S1";
  X_BUF \vga/crt/_and0000_SW0/O/YUSED  (
    .I(\vga/crt/_and0000_161 ),
    .O(\vga/crt/_and0000_0 )
  );
  defparam \vga/crt/eol_SW0 .INIT = 16'hDFFF;
  defparam \vga/crt/eol_SW0 .LOC = "CLB_R17C13.S1";
  X_LUT4 \vga/crt/eol_SW0  (
    .ADR0(\vga/crt/cursor_h [3]),
    .ADR1(\vga/crt/cursor_h [4]),
    .ADR2(\vga/crt/cursor_h [2]),
    .ADR3(\vga/crt/cursor_h [1]),
    .O(\vga/crt/eol_SW0/O_pack_1 )
  );
  defparam \vga/crt/eol .INIT = 16'h0020;
  defparam \vga/crt/eol .LOC = "CLB_R17C13.S1";
  X_LUT4 \vga/crt/eol  (
    .ADR0(\vga/crt/cursor_h [6]),
    .ADR1(\vga/crt/cursor_h [5]),
    .ADR2(\vga/crt/cursor_h [0]),
    .ADR3(\vga/crt/eol_SW0/O ),
    .O(\vga/crt/eol_162 )
  );
  defparam \vga/crt/eol_SW0/O/XUSED .LOC = "CLB_R17C13.S1";
  X_BUF \vga/crt/eol_SW0/O/XUSED  (
    .I(\vga/crt/eol_SW0/O_pack_1 ),
    .O(\vga/crt/eol_SW0/O )
  );
  defparam \vga/crt/eol_SW0/O/YUSED .LOC = "CLB_R17C13.S1";
  X_BUF \vga/crt/eol_SW0/O/YUSED  (
    .I(\vga/crt/eol_162 ),
    .O(\vga/crt/eol_0 )
  );
  defparam \vga/scancode_convert/_cmp_eq0000 .INIT = 16'h0010;
  defparam \vga/scancode_convert/_cmp_eq0000 .LOC = "CLB_R12C29.S1";
  X_LUT4 \vga/scancode_convert/_cmp_eq0000  (
    .ADR0(\vga/ps2/sc_r [3]),
    .ADR1(\vga/ps2/sc_r [0]),
    .ADR2(\vga/scancode_convert/N31 ),
    .ADR3(N3100_0),
    .O(\vga/scancode_convert/_cmp_eq0000_pack_1 )
  );
  defparam \vga/scancode_convert/_not00101 .INIT = 16'hF8F0;
  defparam \vga/scancode_convert/_not00101 .LOC = "CLB_R12C29.S1";
  X_LUT4 \vga/scancode_convert/_not00101  (
    .ADR0(\vga/scancode_convert/state_FFd5_31 ),
    .ADR1(\vga/ps2/rdy_r_1 ),
    .ADR2(\vga/scancode_convert/state_FFd4_30 ),
    .ADR3(\vga/scancode_convert/_cmp_eq0000_27 ),
    .O(\vga/scancode_convert/_not0010 )
  );
  defparam \vga/scancode_convert/_cmp_eq0000/XUSED .LOC = "CLB_R12C29.S1";
  X_BUF \vga/scancode_convert/_cmp_eq0000/XUSED  (
    .I(\vga/scancode_convert/_cmp_eq0000_pack_1 ),
    .O(\vga/scancode_convert/_cmp_eq0000_27 )
  );
  defparam \vga/scancode_convert/_cmp_eq0000/YUSED .LOC = "CLB_R12C29.S1";
  X_BUF \vga/scancode_convert/_cmp_eq0000/YUSED  (
    .I(\vga/scancode_convert/_not0010 ),
    .O(\vga/scancode_convert/_not0010_0 )
  );
  defparam \vga/crt/scroll_SW0 .INIT = 16'hF3FF;
  defparam \vga/crt/scroll_SW0 .LOC = "CLB_R15C13.S0";
  X_LUT4 \vga/crt/scroll_SW0  (
    .ADR0(VCC),
    .ADR1(\vga/crt/cursor_v [3]),
    .ADR2(\vga/crt/cursor_v [2]),
    .ADR3(\vga/crt/cursor_v [1]),
    .O(\vga/crt/scroll_SW0/O_pack_1 )
  );
  defparam \vga/crt/scroll .INIT = 16'h0080;
  defparam \vga/crt/scroll .LOC = "CLB_R15C13.S0";
  X_LUT4 \vga/crt/scroll  (
    .ADR0(\vga/crt/cursor_v [4]),
    .ADR1(\vga/crt/cursor_v [0]),
    .ADR2(\vga/crt/cursor_v [5]),
    .ADR3(\vga/crt/scroll_SW0/O ),
    .O(\vga/crt/scroll_163 )
  );
  defparam \vga/crt/scroll_SW0/O/XUSED .LOC = "CLB_R15C13.S0";
  X_BUF \vga/crt/scroll_SW0/O/XUSED  (
    .I(\vga/crt/scroll_SW0/O_pack_1 ),
    .O(\vga/crt/scroll_SW0/O )
  );
  defparam \vga/crt/scroll_SW0/O/YUSED .LOC = "CLB_R15C13.S0";
  X_BUF \vga/crt/scroll_SW0/O/YUSED  (
    .I(\vga/crt/scroll_163 ),
    .O(\vga/crt/scroll_0 )
  );
  defparam \vga/scancode_convert/state_FFd4-In24 .INIT = 16'hBAEA;
  defparam \vga/scancode_convert/state_FFd4-In24 .LOC = "CLB_R13C29.S0";
  X_LUT4 \vga/scancode_convert/state_FFd4-In24  (
    .ADR0(\vga/scancode_convert/N11_0 ),
    .ADR1(\vga/ps2/sc_r [1]),
    .ADR2(\vga/scancode_convert/N10_0 ),
    .ADR3(\vga/ps2/sc_r [2]),
    .O(\vga/scancode_convert/state_FFd4-In24/O_pack_1 )
  );
  defparam \vga/scancode_convert/state_FFd4-In34 .INIT = 16'hFEFA;
  defparam \vga/scancode_convert/state_FFd4-In34 .LOC = "CLB_R13C29.S0";
  X_LUT4 \vga/scancode_convert/state_FFd4-In34  (
    .ADR0(\vga/scancode_convert/state_FFd3_29 ),
    .ADR1(\vga/scancode_convert/_and0000_0 ),
    .ADR2(\vga/scancode_convert/state_FFd2_28 ),
    .ADR3(\vga/scancode_convert/state_FFd4-In24/O ),
    .O(\vga/scancode_convert/state_FFd4-In )
  );
  defparam \vga/scancode_convert/state_FFd4/XUSED .LOC = "CLB_R13C29.S0";
  X_BUF \vga/scancode_convert/state_FFd4/XUSED  (
    .I(\vga/scancode_convert/state_FFd4-In24/O_pack_1 ),
    .O(\vga/scancode_convert/state_FFd4-In24/O )
  );
  defparam \vga/scancode_convert/state_FFd4 .LOC = "CLB_R13C29.S0";
  defparam \vga/scancode_convert/state_FFd4 .INIT = 1'b0;
  X_FF \vga/scancode_convert/state_FFd4  (
    .I(\vga/scancode_convert/state_FFd4-In ),
    .CE(VCC),
    .CLK(gray_cnt_FFd1_0),
    .SET(GND),
    .RST(\vga/scancode_convert/state_FFd4/FFY/RST ),
    .O(\vga/scancode_convert/state_FFd4_30 )
  );
  defparam \vga/scancode_convert/state_FFd4/FFY/RSTOR .LOC = "CLB_R13C29.S0";
  X_INV \vga/scancode_convert/state_FFd4/FFY/RSTOR  (
    .I(reset_n_IBUF_0),
    .O(\vga/scancode_convert/state_FFd4/FFY/RST )
  );
  defparam \vga/crt/_and0001 .INIT = 16'h1000;
  defparam \vga/crt/_and0001 .LOC = "CLB_R15C14.S1";
  X_LUT4 \vga/crt/_and0001  (
    .ADR0(\vga/crt/state_FFd3_11 ),
    .ADR1(N235_0),
    .ADR2(\vga/crt/scroll_0 ),
    .ADR3(\vga/crt/eol_0 ),
    .O(\vga/crt/_and0001_pack_1 )
  );
  defparam \vga/crt/cursor_v_Eqn_11 .INIT = 16'h00F0;
  defparam \vga/crt/cursor_v_Eqn_11 .LOC = "CLB_R15C14.S1";
  X_LUT4 \vga/crt/cursor_v_Eqn_11  (
    .ADR0(VCC),
    .ADR1(VCC),
    .ADR2(\vga/crt/Result<1>_0 ),
    .ADR3(\vga/crt/_and0001_32 ),
    .O(\vga/crt/cursor_v_Eqn_1 )
  );
  defparam \vga/crt/cursor_v<1>/XUSED .LOC = "CLB_R15C14.S1";
  X_BUF \vga/crt/cursor_v<1>/XUSED  (
    .I(\vga/crt/_and0001_pack_1 ),
    .O(\vga/crt/_and0001_32 )
  );
  defparam \vga/crt/cursor_v_1 .LOC = "CLB_R15C14.S1";
  defparam \vga/crt/cursor_v_1 .INIT = 1'b0;
  X_FF \vga/crt/cursor_v_1  (
    .I(\vga/crt/cursor_v_Eqn_1 ),
    .CE(\vga/crt/_not0007_0 ),
    .CLK(\vga/crtclk_4 ),
    .SET(GND),
    .RST(\vga/crt/cursor_v<1>/FFY/RST ),
    .O(\vga/crt/cursor_v [1])
  );
  defparam \vga/crt/cursor_v<1>/FFY/RSTOR .LOC = "CLB_R15C14.S1";
  X_INV \vga/crt/cursor_v<1>/FFY/RSTOR  (
    .I(reset_n_IBUF_0),
    .O(\vga/crt/cursor_v<1>/FFY/RST )
  );
  defparam \vga/scancode_convert/scancode_rom/data<1>218 .INIT = 16'h5030;
  defparam \vga/scancode_convert/scancode_rom/data<1>218 .LOC = "CLB_R15C36.S0";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<1>218  (
    .ADR0(\vga/scancode_convert/scancode_rom/N18_0 ),
    .ADR1(\vga/scancode_convert/scancode_rom/N28_0 ),
    .ADR2(\vga/scancode_convert/sc [3]),
    .ADR3(\vga/scancode_convert/sc [4]),
    .O(\vga/scancode_convert/scancode_rom/data<1>218/O_pack_1 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<1>242 .INIT = 16'hFDCD;
  defparam \vga/scancode_convert/scancode_rom/data<1>242 .LOC = "CLB_R15C36.S0";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<1>242  (
    .ADR0(\vga/scancode_convert/scancode_rom/N25 ),
    .ADR1(\vga/scancode_convert/sc [5]),
    .ADR2(\vga/scancode_convert/sc [2]),
    .ADR3(\vga/scancode_convert/scancode_rom/data<1>218/O ),
    .O(\vga/scancode_convert/scancode_rom/data<1>2_map1690 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<1>218/O/XUSED .LOC = "CLB_R15C36.S0";
  X_BUF \vga/scancode_convert/scancode_rom/data<1>218/O/XUSED  (
    .I(\vga/scancode_convert/scancode_rom/data<1>218/O_pack_1 ),
    .O(\vga/scancode_convert/scancode_rom/data<1>218/O )
  );
  defparam \vga/scancode_convert/scancode_rom/data<1>218/O/YUSED .LOC = "CLB_R15C36.S0";
  X_BUF \vga/scancode_convert/scancode_rom/data<1>218/O/YUSED  (
    .I(\vga/scancode_convert/scancode_rom/data<1>2_map1690 ),
    .O(\vga/scancode_convert/scancode_rom/data<1>2_map1690_0 )
  );
  defparam \vga/scancode_convert/shift_set6 .INIT = 16'h0088;
  defparam \vga/scancode_convert/shift_set6 .LOC = "CLB_R12C31.S0";
  X_LUT4 \vga/scancode_convert/shift_set6  (
    .ADR0(\vga/scancode_convert/N10_0 ),
    .ADR1(\vga/ps2/sc_r [1]),
    .ADR2(VCC),
    .ADR3(\vga/ps2/sc_r [2]),
    .O(\vga/scancode_convert/shift_set_map833_pack_1 )
  );
  defparam \vga/scancode_convert/_not0007 .INIT = 16'hAA80;
  defparam \vga/scancode_convert/_not0007 .LOC = "CLB_R12C31.S0";
  X_LUT4 \vga/scancode_convert/_not0007  (
    .ADR0(\vga/scancode_convert/_and0000_0 ),
    .ADR1(\vga/ps2/sc_r [0]),
    .ADR2(\vga/scancode_convert/N11_0 ),
    .ADR3(\vga/scancode_convert/shift_set_map833 ),
    .O(\vga/scancode_convert/_not0007_164 )
  );
  defparam \vga/scancode_convert/shift_set_map833/XUSED .LOC = "CLB_R12C31.S0";
  X_BUF \vga/scancode_convert/shift_set_map833/XUSED  (
    .I(\vga/scancode_convert/shift_set_map833_pack_1 ),
    .O(\vga/scancode_convert/shift_set_map833 )
  );
  defparam \vga/scancode_convert/shift_set_map833/YUSED .LOC = "CLB_R12C31.S0";
  X_BUF \vga/scancode_convert/shift_set_map833/YUSED  (
    .I(\vga/scancode_convert/_not0007_164 ),
    .O(\vga/scancode_convert/_not0007_0 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<3>126_SW1 .INIT = 16'hFF5F;
  defparam \vga/scancode_convert/scancode_rom/data<3>126_SW1 .LOC = "CLB_R17C35.S0";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<3>126_SW1  (
    .ADR0(\vga/scancode_convert/sc [1]),
    .ADR1(VCC),
    .ADR2(\vga/scancode_convert/sc [3]),
    .ADR3(\vga/scancode_convert/sc [0]),
    .O(\vga/scancode_convert/scancode_rom/data<3>126_SW1/O_pack_1 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<3>126 .INIT = 16'h0062;
  defparam \vga/scancode_convert/scancode_rom/data<3>126 .LOC = "CLB_R17C35.S0";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<3>126  (
    .ADR0(\vga/scancode_convert/sc [4]),
    .ADR1(\vga/scancode_convert/sc [2]),
    .ADR2(\vga/scancode_convert/raise ),
    .ADR3(\vga/scancode_convert/scancode_rom/data<3>126_SW1/O ),
    .O(\vga/scancode_convert/scancode_rom/data<3>1_map1158 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<3>126_SW1/O/XUSED .LOC = "CLB_R17C35.S0";
  X_BUF \vga/scancode_convert/scancode_rom/data<3>126_SW1/O/XUSED  (
    .I(\vga/scancode_convert/scancode_rom/data<3>126_SW1/O_pack_1 ),
    .O(\vga/scancode_convert/scancode_rom/data<3>126_SW1/O )
  );
  defparam \vga/scancode_convert/scancode_rom/data<3>126_SW1/O/YUSED .LOC = "CLB_R17C35.S0";
  X_BUF \vga/scancode_convert/scancode_rom/data<3>126_SW1/O/YUSED  (
    .I(\vga/scancode_convert/scancode_rom/data<3>1_map1158 ),
    .O(\vga/scancode_convert/scancode_rom/data<3>1_map1158_0 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<4>145 .INIT = 16'h773F;
  defparam \vga/scancode_convert/scancode_rom/data<4>145 .LOC = "CLB_R12C36.S0";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<4>145  (
    .ADR0(\vga/scancode_convert/scancode_rom/N18_0 ),
    .ADR1(\vga/scancode_convert/sc [3]),
    .ADR2(\vga/scancode_convert/scancode_rom/N43_0 ),
    .ADR3(\vga/scancode_convert/sc [4]),
    .O(\vga/scancode_convert/scancode_rom/data<4>145/O_pack_1 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<4>182 .INIT = 16'h8B03;
  defparam \vga/scancode_convert/scancode_rom/data<4>182 .LOC = "CLB_R12C36.S0";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<4>182  (
    .ADR0(\vga/scancode_convert/scancode_rom/data<4>1_map1548_0 ),
    .ADR1(\vga/scancode_convert/sc [2]),
    .ADR2(\vga/scancode_convert/scancode_rom/N25 ),
    .ADR3(\vga/scancode_convert/scancode_rom/data<4>145/O ),
    .O(\vga/scancode_convert/scancode_rom/data<4>1_map1560 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<4>145/O/XUSED .LOC = "CLB_R12C36.S0";
  X_BUF \vga/scancode_convert/scancode_rom/data<4>145/O/XUSED  (
    .I(\vga/scancode_convert/scancode_rom/data<4>145/O_pack_1 ),
    .O(\vga/scancode_convert/scancode_rom/data<4>145/O )
  );
  defparam \vga/scancode_convert/scancode_rom/data<4>145/O/YUSED .LOC = "CLB_R12C36.S0";
  X_BUF \vga/scancode_convert/scancode_rom/data<4>145/O/YUSED  (
    .I(\vga/scancode_convert/scancode_rom/data<4>1_map1560 ),
    .O(\vga/scancode_convert/scancode_rom/data<4>1_map1560_0 )
  );
  defparam \vga/scancode_convert/raise1_1 .INIT = 16'hFFEE;
  defparam \vga/scancode_convert/raise1_1 .LOC = "CLB_R12C33.S0";
  X_LUT4 \vga/scancode_convert/raise1_1  (
    .ADR0(\vga/scancode_convert/ctrl_22 ),
    .ADR1(\vga/scancode_convert/shift_24 ),
    .ADR2(VCC),
    .ADR3(\vga/scancode_convert/capslock_25 ),
    .O(\vga/scancode_convert/raise1_pack_1 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<5>374 .INIT = 16'h757F;
  defparam \vga/scancode_convert/scancode_rom/data<5>374 .LOC = "CLB_R12C33.S0";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<5>374  (
    .ADR0(\vga/scancode_convert/sc [4]),
    .ADR1(\vga/scancode_convert/sc_0_1_10 ),
    .ADR2(\vga/scancode_convert/sc_1_1_23 ),
    .ADR3(\vga/scancode_convert/raise1_33 ),
    .O(\vga/scancode_convert/scancode_rom/data<5>3_map1260 )
  );
  defparam \vga/scancode_convert/raise1/XUSED .LOC = "CLB_R12C33.S0";
  X_BUF \vga/scancode_convert/raise1/XUSED  (
    .I(\vga/scancode_convert/raise1_pack_1 ),
    .O(\vga/scancode_convert/raise1_33 )
  );
  defparam \vga/scancode_convert/raise1/YUSED .LOC = "CLB_R12C33.S0";
  X_BUF \vga/scancode_convert/raise1/YUSED  (
    .I(\vga/scancode_convert/scancode_rom/data<5>3_map1260 ),
    .O(\vga/scancode_convert/scancode_rom/data<5>3_map1260_0 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<1>111 .INIT = 16'h5FFF;
  defparam \vga/scancode_convert/scancode_rom/data<1>111 .LOC = "CLB_R13C37.S0";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<1>111  (
    .ADR0(\vga/scancode_convert/sc [4]),
    .ADR1(VCC),
    .ADR2(\vga/scancode_convert/sc [1]),
    .ADR3(\vga/scancode_convert/sc [3]),
    .O(\vga/scancode_convert/scancode_rom/N25_pack_1 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<6>186 .INIT = 16'hEAFB;
  defparam \vga/scancode_convert/scancode_rom/data<6>186 .LOC = "CLB_R13C37.S0";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<6>186  (
    .ADR0(\vga/scancode_convert/sc [5]),
    .ADR1(\vga/scancode_convert/sc [2]),
    .ADR2(N3124_0),
    .ADR3(\vga/scancode_convert/scancode_rom/N25 ),
    .O(\vga/scancode_convert/scancode_rom/data<6>1_map1803 )
  );
  defparam \vga/scancode_convert/scancode_rom/N25/XUSED .LOC = "CLB_R13C37.S0";
  X_BUF \vga/scancode_convert/scancode_rom/N25/XUSED  (
    .I(\vga/scancode_convert/scancode_rom/N25_pack_1 ),
    .O(\vga/scancode_convert/scancode_rom/N25 )
  );
  defparam \vga/scancode_convert/scancode_rom/N25/YUSED .LOC = "CLB_R13C37.S0";
  X_BUF \vga/scancode_convert/scancode_rom/N25/YUSED  (
    .I(\vga/scancode_convert/scancode_rom/data<6>1_map1803 ),
    .O(\vga/scancode_convert/scancode_rom/data<6>1_map1803_0 )
  );
  defparam \vga/_and000093 .INIT = 16'h8241;
  defparam \vga/_and000093 .LOC = "CLB_R14C9.S0";
  X_LUT4 \vga/_and000093  (
    .ADR0(\vga/vgacore/hcnt [7]),
    .ADR1(\vga/crt/cursor_h [5]),
    .ADR2(\vga/vgacore/hcnt [8]),
    .ADR3(\vga/crt/cursor_h [4]),
    .O(\vga/_and000093/O_pack_1 )
  );
  defparam \vga/_and0000238 .INIT = 16'h8000;
  defparam \vga/_and0000238 .LOC = "CLB_R14C9.S0";
  X_LUT4 \vga/_and0000238  (
    .ADR0(\vga/_and0000_map879_0 ),
    .ADR1(\vga/_and0000_map943_0 ),
    .ADR2(\vga/_and0000_map890_0 ),
    .ADR3(\vga/_and000093/O ),
    .O(\vga/cursor_match )
  );
  defparam \vga/_and000093/O/XUSED .LOC = "CLB_R14C9.S0";
  X_BUF \vga/_and000093/O/XUSED  (
    .I(\vga/_and000093/O_pack_1 ),
    .O(\vga/_and000093/O )
  );
  defparam \vga/_and000093/O/YUSED .LOC = "CLB_R14C9.S0";
  X_BUF \vga/_and000093/O/YUSED  (
    .I(\vga/cursor_match ),
    .O(\vga/cursor_match_0 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<0>176 .INIT = 16'hCF4F;
  defparam \vga/scancode_convert/scancode_rom/data<0>176 .LOC = "CLB_R15C34.S0";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<0>176  (
    .ADR0(\vga/scancode_convert/sc [3]),
    .ADR1(\vga/scancode_convert/scancode_rom/data<0>1_map1429_0 ),
    .ADR2(\vga/scancode_convert/sc [2]),
    .ADR3(\vga/scancode_convert/scancode_rom/data<0>1_map1438_0 ),
    .O(\vga/scancode_convert/scancode_rom/data<0>176/O_pack_1 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<0>1104 .INIT = 16'hFEF0;
  defparam \vga/scancode_convert/scancode_rom/data<0>1104 .LOC = "CLB_R15C34.S0";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<0>1104  (
    .ADR0(\vga/scancode_convert/sc [2]),
    .ADR1(\vga/scancode_convert/scancode_rom/data<0>1_map1423_0 ),
    .ADR2(\vga/scancode_convert/sc [5]),
    .ADR3(\vga/scancode_convert/scancode_rom/data<0>176/O ),
    .O(\vga/scancode_convert/scancode_rom/data<0>1_map1445 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<0>176/O/XUSED .LOC = "CLB_R15C34.S0";
  X_BUF \vga/scancode_convert/scancode_rom/data<0>176/O/XUSED  (
    .I(\vga/scancode_convert/scancode_rom/data<0>176/O_pack_1 ),
    .O(\vga/scancode_convert/scancode_rom/data<0>176/O )
  );
  defparam \vga/scancode_convert/scancode_rom/data<0>176/O/YUSED .LOC = "CLB_R15C34.S0";
  X_BUF \vga/scancode_convert/scancode_rom/data<0>176/O/YUSED  (
    .I(\vga/scancode_convert/scancode_rom/data<0>1_map1445 ),
    .O(\vga/scancode_convert/scancode_rom/data<0>1_map1445_0 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<0>1370_SW1 .INIT = 16'hD710;
  defparam \vga/scancode_convert/scancode_rom/data<0>1370_SW1 .LOC = "CLB_R16C35.S1";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<0>1370_SW1  (
    .ADR0(\vga/scancode_convert/sc [0]),
    .ADR1(\vga/scancode_convert/sc [3]),
    .ADR2(\vga/scancode_convert/sc [4]),
    .ADR3(\vga/scancode_convert/sc [1]),
    .O(\vga/scancode_convert/scancode_rom/data<0>1370_SW1/O_pack_1 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<0>1370 .INIT = 16'hEEFC;
  defparam \vga/scancode_convert/scancode_rom/data<0>1370 .LOC = "CLB_R16C35.S1";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<0>1370  (
    .ADR0(N3178_0),
    .ADR1(\vga/scancode_convert/sc [2]),
    .ADR2(\vga/scancode_convert/scancode_rom/data<0>1370_SW1/O ),
    .ADR3(\vga/scancode_convert/scancode_rom/N12 ),
    .O(\vga/scancode_convert/scancode_rom/data<0>1_map1503 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<0>1370_SW1/O/XUSED .LOC = "CLB_R16C35.S1";
  X_BUF \vga/scancode_convert/scancode_rom/data<0>1370_SW1/O/XUSED  (
    .I(\vga/scancode_convert/scancode_rom/data<0>1370_SW1/O_pack_1 ),
    .O(\vga/scancode_convert/scancode_rom/data<0>1370_SW1/O )
  );
  defparam \vga/scancode_convert/scancode_rom/data<0>1370_SW1/O/YUSED .LOC = "CLB_R16C35.S1";
  X_BUF \vga/scancode_convert/scancode_rom/data<0>1370_SW1/O/YUSED  (
    .I(\vga/scancode_convert/scancode_rom/data<0>1_map1503 ),
    .O(\vga/scancode_convert/scancode_rom/data<0>1_map1503_0 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<0>31 .INIT = 16'hCFFF;
  defparam \vga/scancode_convert/scancode_rom/data<0>31 .LOC = "CLB_R16C35.S0";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<0>31  (
    .ADR0(VCC),
    .ADR1(\vga/scancode_convert/sc [0]),
    .ADR2(\vga/scancode_convert/sc [4]),
    .ADR3(\vga/scancode_convert/sc [1]),
    .O(\vga/scancode_convert/scancode_rom/N7_pack_1 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<0>1536 .INIT = 16'h0F2F;
  defparam \vga/scancode_convert/scancode_rom/data<0>1536 .LOC = "CLB_R16C35.S0";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<0>1536  (
    .ADR0(\vga/scancode_convert/sc [2]),
    .ADR1(\vga/scancode_convert/sc [3]),
    .ADR2(\vga/scancode_convert/sc [5]),
    .ADR3(\vga/scancode_convert/scancode_rom/N7 ),
    .O(\vga/scancode_convert/scancode_rom/data<0>1_map1534 )
  );
  defparam \vga/scancode_convert/scancode_rom/N7/XUSED .LOC = "CLB_R16C35.S0";
  X_BUF \vga/scancode_convert/scancode_rom/N7/XUSED  (
    .I(\vga/scancode_convert/scancode_rom/N7_pack_1 ),
    .O(\vga/scancode_convert/scancode_rom/N7 )
  );
  defparam \vga/scancode_convert/scancode_rom/N7/YUSED .LOC = "CLB_R16C35.S0";
  X_BUF \vga/scancode_convert/scancode_rom/N7/YUSED  (
    .I(\vga/scancode_convert/scancode_rom/data<0>1_map1534 ),
    .O(\vga/scancode_convert/scancode_rom/data<0>1_map1534_0 )
  );
  defparam \vga/ram_addr_mux<10>1 .INIT = 16'hE2E2;
  defparam \vga/ram_addr_mux<10>1 .LOC = "CLB_R12C3.S1";
  X_LUT4 \vga/ram_addr_mux<10>1  (
    .ADR0(\vga/ram_addr_write<10>_0 ),
    .ADR1(\vga/ram_we_n ),
    .ADR2(\vga/ram_addr_video<10>_0 ),
    .ADR3(VCC),
    .O(\vga/ram_addr_mux [10])
  );
  defparam \vga/video_ram/ram_addr_w<10>/YUSED .LOC = "CLB_R12C3.S1";
  X_BUF \vga/video_ram/ram_addr_w<10>/YUSED  (
    .I(\vga/ram_addr_mux [10]),
    .O(\vga/ram_addr_mux<10>_0 )
  );
  defparam \vga/video_ram/ram_addr_w_10 .LOC = "CLB_R12C3.S1";
  defparam \vga/video_ram/ram_addr_w_10 .INIT = 1'b0;
  X_FF \vga/video_ram/ram_addr_w_10  (
    .I(\vga/ram_addr_mux [10]),
    .CE(VCC),
    .CLK(\vga/ram_wclk_5 ),
    .SET(GND),
    .RST(GND),
    .O(\vga/video_ram/ram_addr_w [10])
  );
  defparam \vga/crt/Madd_ram_addrR21 .INIT = 16'h9966;
  defparam \vga/crt/Madd_ram_addrR21 .LOC = "CLB_R16C13.S0";
  X_LUT4 \vga/crt/Madd_ram_addrR21  (
    .ADR0(\vga/crt/cursor_v [2]),
    .ADR1(\vga/crt/cursor_h [6]),
    .ADR2(VCC),
    .ADR3(\vga/crt/cursor_v [0]),
    .O(\vga/crt/Madd_ram_addrR2 )
  );
  defparam \vga/crt/cursor_v_Eqn_01 .INIT = 16'h000F;
  defparam \vga/crt/cursor_v_Eqn_01 .LOC = "CLB_R16C13.S0";
  X_LUT4 \vga/crt/cursor_v_Eqn_01  (
    .ADR0(VCC),
    .ADR1(VCC),
    .ADR2(\vga/crt/cursor_v [0]),
    .ADR3(\vga/crt/_and0001_32 ),
    .O(\vga/crt/cursor_v_Eqn_0 )
  );
  defparam \vga/crt/cursor_v<0>/XUSED .LOC = "CLB_R16C13.S0";
  X_BUF \vga/crt/cursor_v<0>/XUSED  (
    .I(\vga/crt/Madd_ram_addrR2 ),
    .O(\vga/crt/Madd_ram_addrR2_0 )
  );
  defparam \vga/crt/cursor_v_0 .LOC = "CLB_R16C13.S0";
  defparam \vga/crt/cursor_v_0 .INIT = 1'b0;
  X_FF \vga/crt/cursor_v_0  (
    .I(\vga/crt/cursor_v_Eqn_0 ),
    .CE(\vga/crt/_not0007_0 ),
    .CLK(\vga/crtclk_4 ),
    .SET(GND),
    .RST(\vga/crt/cursor_v<0>/FFY/RST ),
    .O(\vga/crt/cursor_v [0])
  );
  defparam \vga/crt/cursor_v<0>/FFY/RSTOR .LOC = "CLB_R16C13.S0";
  X_INV \vga/crt/cursor_v<0>/FFY/RSTOR  (
    .I(reset_n_IBUF_0),
    .O(\vga/crt/cursor_v<0>/FFY/RST )
  );
  defparam \vga/crt/cursor_v_Eqn_31 .INIT = 16'h5050;
  defparam \vga/crt/cursor_v_Eqn_31 .LOC = "CLB_R15C13.S1";
  X_LUT4 \vga/crt/cursor_v_Eqn_31  (
    .ADR0(\vga/crt/_and0001_32 ),
    .ADR1(VCC),
    .ADR2(\vga/crt/Result<3>_0 ),
    .ADR3(VCC),
    .O(\vga/crt/cursor_v_Eqn_3 )
  );
  defparam \vga/crt/cursor_v_Eqn_21 .INIT = 16'h5500;
  defparam \vga/crt/cursor_v_Eqn_21 .LOC = "CLB_R15C13.S1";
  X_LUT4 \vga/crt/cursor_v_Eqn_21  (
    .ADR0(\vga/crt/_and0001_32 ),
    .ADR1(VCC),
    .ADR2(VCC),
    .ADR3(\vga/crt/Result<2>_0 ),
    .O(\vga/crt/cursor_v_Eqn_2 )
  );
  defparam \vga/crt/cursor_v<3>/SRMUX .LOC = "CLB_R15C13.S1";
  X_INV \vga/crt/cursor_v<3>/SRMUX  (
    .I(reset_n_IBUF_0),
    .O(\vga/crt/cursor_v<3>/SRMUX_OUTPUTNOT )
  );
  defparam \vga/crt/cursor_v_Eqn_51 .INIT = 16'h5500;
  defparam \vga/crt/cursor_v_Eqn_51 .LOC = "CLB_R15C14.S0";
  X_LUT4 \vga/crt/cursor_v_Eqn_51  (
    .ADR0(\vga/crt/_and0001_32 ),
    .ADR1(VCC),
    .ADR2(VCC),
    .ADR3(\vga/crt/Result<5>_0 ),
    .O(\vga/crt/cursor_v_Eqn_5 )
  );
  defparam \vga/crt/cursor_v_Eqn_41 .INIT = 16'h5500;
  defparam \vga/crt/cursor_v_Eqn_41 .LOC = "CLB_R15C14.S0";
  X_LUT4 \vga/crt/cursor_v_Eqn_41  (
    .ADR0(\vga/crt/_and0001_32 ),
    .ADR1(VCC),
    .ADR2(VCC),
    .ADR3(\vga/crt/Result<4>_0 ),
    .O(\vga/crt/cursor_v_Eqn_4 )
  );
  defparam \vga/crt/cursor_v<5>/SRMUX .LOC = "CLB_R15C14.S0";
  X_INV \vga/crt/cursor_v<5>/SRMUX  (
    .I(reset_n_IBUF_0),
    .O(\vga/crt/cursor_v<5>/SRMUX_OUTPUTNOT )
  );
  defparam \vga/crt/_mux0002<1>1 .INIT = 16'hDF80;
  defparam \vga/crt/_mux0002<1>1 .LOC = "CLB_R18C13.S0";
  X_LUT4 \vga/crt/_mux0002<1>1  (
    .ADR0(\vga/crt/state_FFd2_12 ),
    .ADR1(\vga/crt_data [1]),
    .ADR2(\vga/crt/state_FFd3_11 ),
    .ADR3(\vga/crt/cursor_h [1]),
    .O(\vga/crt/_mux0002 [1])
  );
  defparam \vga/crt/_mux0002<0>1 .INIT = 16'hD8F0;
  defparam \vga/crt/_mux0002<0>1 .LOC = "CLB_R18C13.S0";
  X_LUT4 \vga/crt/_mux0002<0>1  (
    .ADR0(\vga/crt/state_FFd2_12 ),
    .ADR1(\vga/crt_data [0]),
    .ADR2(\vga/crt/cursor_h [0]),
    .ADR3(\vga/crt/state_FFd3_11 ),
    .O(\vga/crt/_mux0002 [0])
  );
  defparam \vga/crt/ram_data<1>/SRMUX .LOC = "CLB_R18C13.S0";
  X_INV \vga/crt/ram_data<1>/SRMUX  (
    .I(reset_n_IBUF_0),
    .O(\vga/crt/ram_data<1>/SRMUX_OUTPUTNOT )
  );
  defparam \vga/crt/_mux0002<3>1 .INIT = 16'hBF80;
  defparam \vga/crt/_mux0002<3>1 .LOC = "CLB_R18C9.S0";
  X_LUT4 \vga/crt/_mux0002<3>1  (
    .ADR0(\vga/crt_data [3]),
    .ADR1(\vga/crt/state_FFd2_12 ),
    .ADR2(\vga/crt/state_FFd3_11 ),
    .ADR3(\vga/crt/cursor_h [3]),
    .O(\vga/crt/_mux0002 [3])
  );
  defparam \vga/crt/_mux0002<2>1 .INIT = 16'hBF80;
  defparam \vga/crt/_mux0002<2>1 .LOC = "CLB_R18C9.S0";
  X_LUT4 \vga/crt/_mux0002<2>1  (
    .ADR0(\vga/crt_data [2]),
    .ADR1(\vga/crt/state_FFd2_12 ),
    .ADR2(\vga/crt/state_FFd3_11 ),
    .ADR3(\vga/crt/cursor_h [2]),
    .O(\vga/crt/_mux0002 [2])
  );
  defparam \vga/crt/ram_data<3>/SRMUX .LOC = "CLB_R18C9.S0";
  X_INV \vga/crt/ram_data<3>/SRMUX  (
    .I(reset_n_IBUF_0),
    .O(\vga/crt/ram_data<3>/SRMUX_OUTPUTNOT )
  );
  defparam \vga/crt/_mux0002<5>1 .INIT = 16'hB313;
  defparam \vga/crt/_mux0002<5>1 .LOC = "CLB_R14C13.S1";
  X_LUT4 \vga/crt/_mux0002<5>1  (
    .ADR0(\vga/crt/state_FFd2_12 ),
    .ADR1(\vga/crt/cursor_h [5]),
    .ADR2(\vga/crt/state_FFd3_11 ),
    .ADR3(\vga/crt_data [5]),
    .O(\vga/crt/_mux0002 [5])
  );
  defparam \vga/crt/_mux0002<4>1 .INIT = 16'hCAAA;
  defparam \vga/crt/_mux0002<4>1 .LOC = "CLB_R14C13.S1";
  X_LUT4 \vga/crt/_mux0002<4>1  (
    .ADR0(\vga/crt/cursor_h [4]),
    .ADR1(\vga/crt_data [4]),
    .ADR2(\vga/crt/state_FFd3_11 ),
    .ADR3(\vga/crt/state_FFd2_12 ),
    .O(\vga/crt/_mux0002 [4])
  );
  defparam \vga/crt/ram_data<5>/SRMUX .LOC = "CLB_R14C13.S1";
  X_INV \vga/crt/ram_data<5>/SRMUX  (
    .I(reset_n_IBUF_0),
    .O(\vga/crt/ram_data<5>/SRMUX_OUTPUTNOT )
  );
  defparam \vga/scancode_convert/_not00121 .INIT = 16'hFFC0;
  defparam \vga/scancode_convert/_not00121 .LOC = "CLB_R14C26.S1";
  X_LUT4 \vga/scancode_convert/_not00121  (
    .ADR0(VCC),
    .ADR1(\vga/scancode_convert/state_FFd1_34 ),
    .ADR2(\vga/scancode_convert/_cmp_eq0005 ),
    .ADR3(\vga/scancode_convert/state_FFd3_29 ),
    .O(\vga/scancode_convert/_not0012 )
  );
  defparam \vga/scancode_convert/state_FFd1-In1 .INIT = 16'hF5F0;
  defparam \vga/scancode_convert/state_FFd1-In1 .LOC = "CLB_R14C26.S1";
  X_LUT4 \vga/scancode_convert/state_FFd1-In1  (
    .ADR0(\vga/scancode_convert/_cmp_eq0005 ),
    .ADR1(VCC),
    .ADR2(\vga/scancode_convert/state_FFd4_30 ),
    .ADR3(\vga/scancode_convert/state_FFd1_34 ),
    .O(\vga/scancode_convert/state_FFd1-In )
  );
  defparam \vga/scancode_convert/state_FFd1/XUSED .LOC = "CLB_R14C26.S1";
  X_BUF \vga/scancode_convert/state_FFd1/XUSED  (
    .I(\vga/scancode_convert/_not0012 ),
    .O(\vga/scancode_convert/_not0012_0 )
  );
  defparam \vga/scancode_convert/state_FFd1 .LOC = "CLB_R14C26.S1";
  defparam \vga/scancode_convert/state_FFd1 .INIT = 1'b0;
  X_FF \vga/scancode_convert/state_FFd1  (
    .I(\vga/scancode_convert/state_FFd1-In ),
    .CE(VCC),
    .CLK(gray_cnt_FFd1_0),
    .SET(GND),
    .RST(\vga/scancode_convert/state_FFd1/FFY/RST ),
    .O(\vga/scancode_convert/state_FFd1_34 )
  );
  defparam \vga/scancode_convert/state_FFd1/FFY/RSTOR .LOC = "CLB_R14C26.S1";
  X_INV \vga/scancode_convert/state_FFd1/FFY/RSTOR  (
    .I(reset_n_IBUF_0),
    .O(\vga/scancode_convert/state_FFd1/FFY/RST )
  );
  defparam \vga/scancode_convert/state_FFd6/LOGIC_ZERO .LOC = "CLB_R12C28.S0";
  X_ZERO \vga/scancode_convert/state_FFd6/LOGIC_ZERO  (
    .O(\vga/scancode_convert/state_FFd6/LOGIC_ZERO_165 )
  );
  defparam \vga/scancode_convert/state_FFd2-In111 .INIT = 16'hC0C0;
  defparam \vga/scancode_convert/state_FFd2-In111 .LOC = "CLB_R12C28.S0";
  X_LUT4 \vga/scancode_convert/state_FFd2-In111  (
    .ADR0(VCC),
    .ADR1(\vga/scancode_convert/state_FFd5_31 ),
    .ADR2(\vga/ps2/rdy_r_1 ),
    .ADR3(VCC),
    .O(\vga/scancode_convert/_and0000 )
  );
  defparam \vga/scancode_convert/state_FFd5-In .INIT = 16'hEECE;
  defparam \vga/scancode_convert/state_FFd5-In .LOC = "CLB_R12C28.S0";
  X_LUT4 \vga/scancode_convert/state_FFd5-In  (
    .ADR0(\vga/scancode_convert/state_FFd5_31 ),
    .ADR1(N124_0),
    .ADR2(\vga/ps2/rdy_r_1 ),
    .ADR3(\vga/scancode_convert/_cmp_eq0000_27 ),
    .O(\vga/scancode_convert/state_FFd5-In_166 )
  );
  defparam \vga/scancode_convert/state_FFd6/XUSED .LOC = "CLB_R12C28.S0";
  X_BUF \vga/scancode_convert/state_FFd6/XUSED  (
    .I(\vga/scancode_convert/_and0000 ),
    .O(\vga/scancode_convert/_and0000_0 )
  );
  defparam \vga/scancode_convert/state_FFd6/SRMUX .LOC = "CLB_R12C28.S0";
  X_INV \vga/scancode_convert/state_FFd6/SRMUX  (
    .I(reset_n_IBUF_0),
    .O(\vga/scancode_convert/state_FFd6/SRMUX_OUTPUTNOT )
  );
  defparam \vga/scancode_convert/capslock_toggle1 .INIT = 16'h4000;
  defparam \vga/scancode_convert/capslock_toggle1 .LOC = "CLB_R12C32.S0";
  X_LUT4 \vga/scancode_convert/capslock_toggle1  (
    .ADR0(\vga/ps2/sc_r [0]),
    .ADR1(\vga/scancode_convert/N11_0 ),
    .ADR2(\vga/scancode_convert/_and0000_0 ),
    .ADR3(\vga/scancode_convert/release_prefix_26 ),
    .O(\vga/scancode_convert/capslock_toggle )
  );
  defparam \vga/scancode_convert/shift_set17 .INIT = 16'hEC00;
  defparam \vga/scancode_convert/shift_set17 .LOC = "CLB_R12C32.S0";
  X_LUT4 \vga/scancode_convert/shift_set17  (
    .ADR0(\vga/scancode_convert/N11_0 ),
    .ADR1(\vga/scancode_convert/shift_set_map833 ),
    .ADR2(\vga/ps2/sc_r [0]),
    .ADR3(\vga/scancode_convert/shift_set_map836_0 ),
    .O(\vga/scancode_convert/shift_set )
  );
  defparam \vga/scancode_convert/shift/XUSED .LOC = "CLB_R12C32.S0";
  X_BUF \vga/scancode_convert/shift/XUSED  (
    .I(\vga/scancode_convert/capslock_toggle ),
    .O(\vga/scancode_convert/capslock_toggle_0 )
  );
  defparam \vga/scancode_convert/shift .LOC = "CLB_R12C32.S0";
  defparam \vga/scancode_convert/shift .INIT = 1'b0;
  X_FF \vga/scancode_convert/shift  (
    .I(\vga/scancode_convert/shift_set ),
    .CE(\vga/scancode_convert/_not0007_0 ),
    .CLK(gray_cnt_FFd1_0),
    .SET(GND),
    .RST(\vga/scancode_convert/shift/FFY/RST ),
    .O(\vga/scancode_convert/shift_24 )
  );
  defparam \vga/scancode_convert/shift/FFY/RSTOR .LOC = "CLB_R12C32.S0";
  X_INV \vga/scancode_convert/shift/FFY/RSTOR  (
    .I(reset_n_IBUF_0),
    .O(\vga/scancode_convert/shift/FFY/RST )
  );
  defparam \vga/scancode_convert/shift_set14 .INIT = 16'h0C00;
  defparam \vga/scancode_convert/shift_set14 .LOC = "CLB_R12C28.S1";
  X_LUT4 \vga/scancode_convert/shift_set14  (
    .ADR0(VCC),
    .ADR1(\vga/ps2/rdy_r_1 ),
    .ADR2(\vga/scancode_convert/release_prefix_26 ),
    .ADR3(\vga/scancode_convert/state_FFd5_31 ),
    .O(\vga/scancode_convert/shift_set_map836 )
  );
  defparam \vga/scancode_convert/release_prefix_set1 .INIT = 16'h8080;
  defparam \vga/scancode_convert/release_prefix_set1 .LOC = "CLB_R12C28.S1";
  X_LUT4 \vga/scancode_convert/release_prefix_set1  (
    .ADR0(\vga/scancode_convert/_cmp_eq0000_27 ),
    .ADR1(\vga/ps2/rdy_r_1 ),
    .ADR2(\vga/scancode_convert/state_FFd5_31 ),
    .ADR3(VCC),
    .O(\vga/scancode_convert/release_prefix_set )
  );
  defparam \vga/scancode_convert/release_prefix/XUSED .LOC = "CLB_R12C28.S1";
  X_BUF \vga/scancode_convert/release_prefix/XUSED  (
    .I(\vga/scancode_convert/shift_set_map836 ),
    .O(\vga/scancode_convert/shift_set_map836_0 )
  );
  defparam \vga/scancode_convert/release_prefix .LOC = "CLB_R12C28.S1";
  defparam \vga/scancode_convert/release_prefix .INIT = 1'b0;
  X_FF \vga/scancode_convert/release_prefix  (
    .I(\vga/scancode_convert/release_prefix_set ),
    .CE(\vga/scancode_convert/_not0010_0 ),
    .CLK(gray_cnt_FFd1_0),
    .SET(GND),
    .RST(\vga/scancode_convert/release_prefix/FFY/RST ),
    .O(\vga/scancode_convert/release_prefix_26 )
  );
  defparam \vga/scancode_convert/release_prefix/FFY/RSTOR .LOC = "CLB_R12C28.S1";
  X_INV \vga/scancode_convert/release_prefix/FFY/RSTOR  (
    .I(reset_n_IBUF_0),
    .O(\vga/scancode_convert/release_prefix/FFY/RST )
  );
  defparam \vga/ps2/timer_x<11>1 .INIT = 16'h3300;
  defparam \vga/ps2/timer_x<11>1 .LOC = "CLB_R6C17.S0";
  X_LUT4 \vga/ps2/timer_x<11>1  (
    .ADR0(VCC),
    .ADR1(\vga/ps2/ps2_clk_edge ),
    .ADR2(VCC),
    .ADR3(\vga/ps2/_addsub0000<11>_0 ),
    .O(\vga/ps2/timer_x [11])
  );
  defparam \vga/ps2/timer_x<10>1 .INIT = 16'h3030;
  defparam \vga/ps2/timer_x<10>1 .LOC = "CLB_R6C17.S0";
  X_LUT4 \vga/ps2/timer_x<10>1  (
    .ADR0(VCC),
    .ADR1(\vga/ps2/ps2_clk_edge ),
    .ADR2(\vga/ps2/_addsub0000<10>_0 ),
    .ADR3(VCC),
    .O(\vga/ps2/timer_x [10])
  );
  defparam \vga/ps2/timer_r<11>/SRMUX .LOC = "CLB_R6C17.S0";
  X_INV \vga/ps2/timer_r<11>/SRMUX  (
    .I(reset_n_IBUF_0),
    .O(\vga/ps2/timer_r<11>/SRMUX_OUTPUTNOT )
  );
  defparam \vga/ps2/timer_x<13>1 .INIT = 16'h00AA;
  defparam \vga/ps2/timer_x<13>1 .LOC = "CLB_R6C16.S0";
  X_LUT4 \vga/ps2/timer_x<13>1  (
    .ADR0(\vga/ps2/_addsub0000<13>_0 ),
    .ADR1(VCC),
    .ADR2(VCC),
    .ADR3(\vga/ps2/ps2_clk_edge ),
    .O(\vga/ps2/timer_x [13])
  );
  defparam \vga/ps2/timer_x<12>1 .INIT = 16'h4444;
  defparam \vga/ps2/timer_x<12>1 .LOC = "CLB_R6C16.S0";
  X_LUT4 \vga/ps2/timer_x<12>1  (
    .ADR0(\vga/ps2/ps2_clk_edge ),
    .ADR1(\vga/ps2/_addsub0000<12>_0 ),
    .ADR2(VCC),
    .ADR3(VCC),
    .O(\vga/ps2/timer_x [12])
  );
  defparam \vga/ps2/timer_r<13>/SRMUX .LOC = "CLB_R6C16.S0";
  X_INV \vga/ps2/timer_r<13>/SRMUX  (
    .I(reset_n_IBUF_0),
    .O(\vga/ps2/timer_r<13>/SRMUX_OUTPUTNOT )
  );
  defparam \vga/ps2/timer_r_13 .LOC = "CLB_R6C16.S0";
  defparam \vga/ps2/timer_r_13 .INIT = 1'b0;
  X_FF \vga/ps2/timer_r_13  (
    .I(\vga/ps2/timer_x [13]),
    .CE(VCC),
    .CLK(gray_cnt_FFd1_0),
    .SET(GND),
    .RST(\vga/ps2/timer_r<13>/FFX/RST ),
    .O(\vga/ps2/timer_r [13])
  );
  defparam \vga/ps2/timer_r<13>/FFX/RSTOR .LOC = "CLB_R6C16.S0";
  X_BUF \vga/ps2/timer_r<13>/FFX/RSTOR  (
    .I(\vga/ps2/timer_r<13>/SRMUX_OUTPUTNOT ),
    .O(\vga/ps2/timer_r<13>/FFX/RST )
  );
  defparam \vga/ps2/ps2_clk_edge11 .INIT = 16'h0400;
  defparam \vga/ps2/ps2_clk_edge11 .LOC = "CLB_R10C18.S0";
  X_LUT4 \vga/ps2/ps2_clk_edge11  (
    .ADR0(\vga/ps2/ps2_clk_r [2]),
    .ADR1(\vga/ps2/ps2_clk_r [3]),
    .ADR2(\vga/ps2/ps2_clk_r [1]),
    .ADR3(\vga/ps2/ps2_clk_r [4]),
    .O(\vga/ps2/ps2_clk_fall_edge )
  );
  defparam \vga/ps2/error_x24 .INIT = 16'hEFCC;
  defparam \vga/ps2/error_x24 .LOC = "CLB_R10C18.S0";
  X_LUT4 \vga/ps2/error_x24  (
    .ADR0(\vga/ps2/error_x_map855_0 ),
    .ADR1(\vga/ps2/error_r_16 ),
    .ADR2(\vga/ps2/ps2_clk_r [1]),
    .ADR3(\vga/ps2/_cmp_eq0001 ),
    .O(\vga/ps2/error_x )
  );
  defparam \vga/ps2/error_r/XUSED .LOC = "CLB_R10C18.S0";
  X_BUF \vga/ps2/error_r/XUSED  (
    .I(\vga/ps2/ps2_clk_fall_edge ),
    .O(\vga/ps2/ps2_clk_fall_edge_0 )
  );
  defparam \vga/ps2/error_r .LOC = "CLB_R10C18.S0";
  defparam \vga/ps2/error_r .INIT = 1'b0;
  X_FF \vga/ps2/error_r  (
    .I(\vga/ps2/error_x ),
    .CE(VCC),
    .CLK(gray_cnt_FFd1_0),
    .SET(GND),
    .RST(\vga/ps2/error_r/FFY/RST ),
    .O(\vga/ps2/error_r_16 )
  );
  defparam \vga/ps2/error_r/FFY/RSTOR .LOC = "CLB_R10C18.S0";
  X_INV \vga/ps2/error_r/FFY/RSTOR  (
    .I(reset_n_IBUF_0),
    .O(\vga/ps2/error_r/FFY/RST )
  );
  defparam \vga/charload1 .INIT = 16'hFBC8;
  defparam \vga/charload1 .LOC = "CLB_R12C7.S0";
  X_LUT4 \vga/charload1  (
    .ADR0(N560_0),
    .ADR1(\vga/charload_19 ),
    .ADR2(\vga/cursor_match_0 ),
    .ADR3(\vga/pixel_hold [1]),
    .O(\vga/_mux0002 [5])
  );
  defparam \vga/pixel_hold_2 .LOC = "CLB_R12C7.S0";
  defparam \vga/pixel_hold_2 .INIT = 1'b0;
  X_FF \vga/pixel_hold_2  (
    .I(\vga/_mux0002 [5]),
    .CE(VCC),
    .CLK(gray_cnt_FFd1_0),
    .SET(GND),
    .RST(GND),
    .O(\vga/pixel_hold [2])
  );
  defparam \vga/ram_addr_mux<1>1 .INIT = 16'hF0AA;
  defparam \vga/ram_addr_mux<1>1 .LOC = "CLB_R19C4.S0";
  X_LUT4 \vga/ram_addr_mux<1>1  (
    .ADR0(\vga/crt/cursor_h [1]),
    .ADR1(VCC),
    .ADR2(\vga/vgacore/hcnt [4]),
    .ADR3(\vga/ram_we_n ),
    .O(\vga/ram_addr_mux [1])
  );
  defparam \vga/ram_addr_mux<0>1 .INIT = 16'hF0AA;
  defparam \vga/ram_addr_mux<0>1 .LOC = "CLB_R19C4.S0";
  X_LUT4 \vga/ram_addr_mux<0>1  (
    .ADR0(\vga/crt/cursor_h [0]),
    .ADR1(VCC),
    .ADR2(\vga/vgacore/hcnt [3]),
    .ADR3(\vga/ram_we_n ),
    .O(\vga/ram_addr_mux [0])
  );
  defparam \vga/video_ram/ram_addr_w<1>/XUSED .LOC = "CLB_R19C4.S0";
  X_BUF \vga/video_ram/ram_addr_w<1>/XUSED  (
    .I(\vga/ram_addr_mux [1]),
    .O(\vga/ram_addr_mux<1>_0 )
  );
  defparam \vga/video_ram/ram_addr_w<1>/YUSED .LOC = "CLB_R19C4.S0";
  X_BUF \vga/video_ram/ram_addr_w<1>/YUSED  (
    .I(\vga/ram_addr_mux [0]),
    .O(\vga/ram_addr_mux<0>_0 )
  );
  defparam \vga/video_ram/ram_addr_w_0 .LOC = "CLB_R19C4.S0";
  defparam \vga/video_ram/ram_addr_w_0 .INIT = 1'b0;
  X_FF \vga/video_ram/ram_addr_w_0  (
    .I(\vga/ram_addr_mux [0]),
    .CE(VCC),
    .CLK(\vga/ram_wclk_5 ),
    .SET(GND),
    .RST(GND),
    .O(\vga/video_ram/ram_addr_w [0])
  );
  defparam \vga/ram_addr_mux<3>1 .INIT = 16'hF5A0;
  defparam \vga/ram_addr_mux<3>1 .LOC = "CLB_R15C2.S0";
  X_LUT4 \vga/ram_addr_mux<3>1  (
    .ADR0(\vga/ram_we_n ),
    .ADR1(VCC),
    .ADR2(\vga/vgacore/hcnt [6]),
    .ADR3(\vga/crt/cursor_h [3]),
    .O(\vga/ram_addr_mux [3])
  );
  defparam \vga/ram_addr_mux<2>1 .INIT = 16'hCCF0;
  defparam \vga/ram_addr_mux<2>1 .LOC = "CLB_R15C2.S0";
  X_LUT4 \vga/ram_addr_mux<2>1  (
    .ADR0(VCC),
    .ADR1(\vga/vgacore/hcnt [5]),
    .ADR2(\vga/crt/cursor_h [2]),
    .ADR3(\vga/ram_we_n ),
    .O(\vga/ram_addr_mux [2])
  );
  defparam \vga/video_ram/ram_addr_w<3>/XUSED .LOC = "CLB_R15C2.S0";
  X_BUF \vga/video_ram/ram_addr_w<3>/XUSED  (
    .I(\vga/ram_addr_mux [3]),
    .O(\vga/ram_addr_mux<3>_0 )
  );
  defparam \vga/video_ram/ram_addr_w<3>/YUSED .LOC = "CLB_R15C2.S0";
  X_BUF \vga/video_ram/ram_addr_w<3>/YUSED  (
    .I(\vga/ram_addr_mux [2]),
    .O(\vga/ram_addr_mux<2>_0 )
  );
  defparam \vga/video_ram/ram_addr_w_2 .LOC = "CLB_R15C2.S0";
  defparam \vga/video_ram/ram_addr_w_2 .INIT = 1'b0;
  X_FF \vga/video_ram/ram_addr_w_2  (
    .I(\vga/ram_addr_mux [2]),
    .CE(VCC),
    .CLK(\vga/ram_wclk_5 ),
    .SET(GND),
    .RST(GND),
    .O(\vga/video_ram/ram_addr_w [2])
  );
  defparam \vga/ram_addr_mux<5>1 .INIT = 16'hCFC0;
  defparam \vga/ram_addr_mux<5>1 .LOC = "CLB_R18C3.S1";
  X_LUT4 \vga/ram_addr_mux<5>1  (
    .ADR0(VCC),
    .ADR1(\vga/ram_addr_video<5>_0 ),
    .ADR2(\vga/ram_we_n ),
    .ADR3(\vga/ram_addr_write<5>_0 ),
    .O(\vga/ram_addr_mux [5])
  );
  defparam \vga/video_ram/ram_addr_w<5>/YUSED .LOC = "CLB_R18C3.S1";
  X_BUF \vga/video_ram/ram_addr_w<5>/YUSED  (
    .I(\vga/ram_addr_mux [5]),
    .O(\vga/ram_addr_mux<5>_0 )
  );
  defparam \vga/video_ram/ram_addr_w_5 .LOC = "CLB_R18C3.S1";
  defparam \vga/video_ram/ram_addr_w_5 .INIT = 1'b0;
  X_FF \vga/video_ram/ram_addr_w_5  (
    .I(\vga/ram_addr_mux [5]),
    .CE(VCC),
    .CLK(\vga/ram_wclk_5 ),
    .SET(GND),
    .RST(GND),
    .O(\vga/video_ram/ram_addr_w [5])
  );
  defparam \vga/ram_addr_mux<7>1 .INIT = 16'hCCF0;
  defparam \vga/ram_addr_mux<7>1 .LOC = "CLB_R15C2.S1";
  X_LUT4 \vga/ram_addr_mux<7>1  (
    .ADR0(VCC),
    .ADR1(\vga/ram_addr_video<7>_0 ),
    .ADR2(\vga/ram_addr_write<7>_0 ),
    .ADR3(\vga/ram_we_n ),
    .O(\vga/ram_addr_mux [7])
  );
  defparam \vga/ram_addr_mux<6>1 .INIT = 16'hE4E4;
  defparam \vga/ram_addr_mux<6>1 .LOC = "CLB_R15C2.S1";
  X_LUT4 \vga/ram_addr_mux<6>1  (
    .ADR0(\vga/ram_we_n ),
    .ADR1(\vga/ram_addr_write<6>_0 ),
    .ADR2(\vga/ram_addr_video<6>_0 ),
    .ADR3(VCC),
    .O(\vga/ram_addr_mux [6])
  );
  defparam \vga/video_ram/ram_addr_w<7>/XUSED .LOC = "CLB_R15C2.S1";
  X_BUF \vga/video_ram/ram_addr_w<7>/XUSED  (
    .I(\vga/ram_addr_mux [7]),
    .O(\vga/ram_addr_mux<7>_0 )
  );
  defparam \vga/video_ram/ram_addr_w<7>/YUSED .LOC = "CLB_R15C2.S1";
  X_BUF \vga/video_ram/ram_addr_w<7>/YUSED  (
    .I(\vga/ram_addr_mux [6]),
    .O(\vga/ram_addr_mux<6>_0 )
  );
  defparam \vga/video_ram/ram_addr_w_6 .LOC = "CLB_R15C2.S1";
  defparam \vga/video_ram/ram_addr_w_6 .INIT = 1'b0;
  X_FF \vga/video_ram/ram_addr_w_6  (
    .I(\vga/ram_addr_mux [6]),
    .CE(VCC),
    .CLK(\vga/ram_wclk_5 ),
    .SET(GND),
    .RST(GND),
    .O(\vga/video_ram/ram_addr_w [6])
  );
  defparam \vga/ram_addr_mux<9>1 .INIT = 16'hAAF0;
  defparam \vga/ram_addr_mux<9>1 .LOC = "CLB_R15C4.S1";
  X_LUT4 \vga/ram_addr_mux<9>1  (
    .ADR0(\vga/ram_addr_video<9>_0 ),
    .ADR1(VCC),
    .ADR2(\vga/ram_addr_write<9>_0 ),
    .ADR3(\vga/ram_we_n ),
    .O(\vga/ram_addr_mux [9])
  );
  defparam \vga/ram_addr_mux<8>1 .INIT = 16'hCCF0;
  defparam \vga/ram_addr_mux<8>1 .LOC = "CLB_R15C4.S1";
  X_LUT4 \vga/ram_addr_mux<8>1  (
    .ADR0(VCC),
    .ADR1(\vga/ram_addr_video<8>_0 ),
    .ADR2(\vga/ram_addr_write<8>_0 ),
    .ADR3(\vga/ram_we_n ),
    .O(\vga/ram_addr_mux [8])
  );
  defparam \vga/video_ram/ram_addr_w<9>/XUSED .LOC = "CLB_R15C4.S1";
  X_BUF \vga/video_ram/ram_addr_w<9>/XUSED  (
    .I(\vga/ram_addr_mux [9]),
    .O(\vga/ram_addr_mux<9>_0 )
  );
  defparam \vga/video_ram/ram_addr_w<9>/YUSED .LOC = "CLB_R15C4.S1";
  X_BUF \vga/video_ram/ram_addr_w<9>/YUSED  (
    .I(\vga/ram_addr_mux [8]),
    .O(\vga/ram_addr_mux<8>_0 )
  );
  defparam \vga/video_ram/ram_addr_w_8 .LOC = "CLB_R15C4.S1";
  defparam \vga/video_ram/ram_addr_w_8 .INIT = 1'b0;
  X_FF \vga/video_ram/ram_addr_w_8  (
    .I(\vga/ram_addr_mux [8]),
    .CE(VCC),
    .CLK(\vga/ram_wclk_5 ),
    .SET(GND),
    .RST(GND),
    .O(\vga/video_ram/ram_addr_w [8])
  );
  defparam \vga/scancode_convert/hold_count__mux0000<1>1 .INIT = 16'h6600;
  defparam \vga/scancode_convert/hold_count__mux0000<1>1 .LOC = "CLB_R14C26.S0";
  X_LUT4 \vga/scancode_convert/hold_count__mux0000<1>1  (
    .ADR0(\vga/scancode_convert/hold_count [0]),
    .ADR1(\vga/scancode_convert/hold_count [1]),
    .ADR2(VCC),
    .ADR3(\vga/scancode_convert/state_FFd1_34 ),
    .O(\vga/scancode_convert/hold_count__mux0000 [1])
  );
  defparam \vga/scancode_convert/hold_count__mux0000<0>1 .INIT = 16'h0C0C;
  defparam \vga/scancode_convert/hold_count__mux0000<0>1 .LOC = "CLB_R14C26.S0";
  X_LUT4 \vga/scancode_convert/hold_count__mux0000<0>1  (
    .ADR0(VCC),
    .ADR1(\vga/scancode_convert/state_FFd1_34 ),
    .ADR2(\vga/scancode_convert/hold_count [0]),
    .ADR3(VCC),
    .O(\vga/scancode_convert/hold_count__mux0000 [0])
  );
  defparam \vga/scancode_convert/hold_count<1>/SRMUX .LOC = "CLB_R14C26.S0";
  X_INV \vga/scancode_convert/hold_count<1>/SRMUX  (
    .I(reset_n_IBUF_0),
    .O(\vga/scancode_convert/hold_count<1>/SRMUX_OUTPUTNOT )
  );
  defparam \vga/scancode_convert/_not00111 .INIT = 16'hFEFC;
  defparam \vga/scancode_convert/_not00111 .LOC = "CLB_R13C26.S0";
  X_LUT4 \vga/scancode_convert/_not00111  (
    .ADR0(\vga/scancode_convert/_cmp_eq0005 ),
    .ADR1(\vga/scancode_convert/state_FFd3_29 ),
    .ADR2(\vga/scancode_convert/state_FFd2_28 ),
    .ADR3(\vga/scancode_convert/state_FFd1_34 ),
    .O(\vga/scancode_convert/_not0011 )
  );
  defparam \vga/scancode_convert/hold_count__mux0000<2>1 .INIT = 16'h60C0;
  defparam \vga/scancode_convert/hold_count__mux0000<2>1 .LOC = "CLB_R13C26.S0";
  X_LUT4 \vga/scancode_convert/hold_count__mux0000<2>1  (
    .ADR0(\vga/scancode_convert/hold_count [0]),
    .ADR1(\vga/scancode_convert/hold_count [2]),
    .ADR2(\vga/scancode_convert/state_FFd1_34 ),
    .ADR3(\vga/scancode_convert/hold_count [1]),
    .O(\vga/scancode_convert/hold_count__mux0000 [2])
  );
  defparam \vga/scancode_convert/hold_count<2>/XUSED .LOC = "CLB_R13C26.S0";
  X_BUF \vga/scancode_convert/hold_count<2>/XUSED  (
    .I(\vga/scancode_convert/_not0011 ),
    .O(\vga/scancode_convert/_not0011_0 )
  );
  defparam \vga/scancode_convert/hold_count_2 .LOC = "CLB_R13C26.S0";
  defparam \vga/scancode_convert/hold_count_2 .INIT = 1'b0;
  X_FF \vga/scancode_convert/hold_count_2  (
    .I(\vga/scancode_convert/hold_count__mux0000 [2]),
    .CE(VCC),
    .CLK(gray_cnt_FFd1_0),
    .SET(GND),
    .RST(\vga/scancode_convert/hold_count<2>/FFY/RST ),
    .O(\vga/scancode_convert/hold_count [2])
  );
  defparam \vga/scancode_convert/hold_count<2>/FFY/RSTOR .LOC = "CLB_R13C26.S0";
  X_INV \vga/scancode_convert/hold_count<2>/FFY/RSTOR  (
    .I(reset_n_IBUF_0),
    .O(\vga/scancode_convert/hold_count<2>/FFY/RST )
  );
  defparam \vga/ps2/_cmp_eq000142 .INIT = 16'h0002;
  defparam \vga/ps2/_cmp_eq000142 .LOC = "CLB_R11C16.S0";
  X_LUT4 \vga/ps2/_cmp_eq000142  (
    .ADR0(\vga/ps2/timer_r [2]),
    .ADR1(\vga/ps2/timer_r [0]),
    .ADR2(\vga/ps2/timer_r [1]),
    .ADR3(\vga/ps2/timer_r [3]),
    .O(\vga/ps2/_cmp_eq0001_map1047 )
  );
  defparam \vga/ps2/timer_x<0>1 .INIT = 16'h000F;
  defparam \vga/ps2/timer_x<0>1 .LOC = "CLB_R11C16.S0";
  X_LUT4 \vga/ps2/timer_x<0>1  (
    .ADR0(VCC),
    .ADR1(VCC),
    .ADR2(\vga/ps2/timer_r [0]),
    .ADR3(\vga/ps2/ps2_clk_edge ),
    .O(\vga/ps2/timer_x [0])
  );
  defparam \vga/ps2/timer_r<0>/XUSED .LOC = "CLB_R11C16.S0";
  X_BUF \vga/ps2/timer_r<0>/XUSED  (
    .I(\vga/ps2/_cmp_eq0001_map1047 ),
    .O(\vga/ps2/_cmp_eq0001_map1047_0 )
  );
  defparam \vga/ps2/timer_r_0 .LOC = "CLB_R11C16.S0";
  defparam \vga/ps2/timer_r_0 .INIT = 1'b0;
  X_FF \vga/ps2/timer_r_0  (
    .I(\vga/ps2/timer_x [0]),
    .CE(VCC),
    .CLK(gray_cnt_FFd1_0),
    .SET(GND),
    .RST(\vga/ps2/timer_r<0>/FFY/RST ),
    .O(\vga/ps2/timer_r [0])
  );
  defparam \vga/ps2/timer_r<0>/FFY/RSTOR .LOC = "CLB_R11C16.S0";
  X_INV \vga/ps2/timer_r<0>/FFY/RSTOR  (
    .I(reset_n_IBUF_0),
    .O(\vga/ps2/timer_r<0>/FFY/RST )
  );
  defparam \vga/ps2/timer_x<3>1 .INIT = 16'h00F0;
  defparam \vga/ps2/timer_x<3>1 .LOC = "CLB_R9C16.S0";
  X_LUT4 \vga/ps2/timer_x<3>1  (
    .ADR0(VCC),
    .ADR1(VCC),
    .ADR2(\vga/ps2/_addsub0000<3>_0 ),
    .ADR3(\vga/ps2/ps2_clk_edge ),
    .O(\vga/ps2/timer_x [3])
  );
  defparam \vga/ps2/timer_x<2>1 .INIT = 16'h00AA;
  defparam \vga/ps2/timer_x<2>1 .LOC = "CLB_R9C16.S0";
  X_LUT4 \vga/ps2/timer_x<2>1  (
    .ADR0(\vga/ps2/_addsub0000<2>_0 ),
    .ADR1(VCC),
    .ADR2(VCC),
    .ADR3(\vga/ps2/ps2_clk_edge ),
    .O(\vga/ps2/timer_x [2])
  );
  defparam \vga/ps2/timer_r<3>/SRMUX .LOC = "CLB_R9C16.S0";
  X_INV \vga/ps2/timer_r<3>/SRMUX  (
    .I(reset_n_IBUF_0),
    .O(\vga/ps2/timer_r<3>/SRMUX_OUTPUTNOT )
  );
  defparam \vga/ps2/timer_x<5>1 .INIT = 16'h00F0;
  defparam \vga/ps2/timer_x<5>1 .LOC = "CLB_R8C16.S0";
  X_LUT4 \vga/ps2/timer_x<5>1  (
    .ADR0(VCC),
    .ADR1(VCC),
    .ADR2(\vga/ps2/_addsub0000<5>_0 ),
    .ADR3(\vga/ps2/ps2_clk_edge ),
    .O(\vga/ps2/timer_x [5])
  );
  defparam \vga/ps2/timer_x<4>1 .INIT = 16'h00AA;
  defparam \vga/ps2/timer_x<4>1 .LOC = "CLB_R8C16.S0";
  X_LUT4 \vga/ps2/timer_x<4>1  (
    .ADR0(\vga/ps2/_addsub0000<4>_0 ),
    .ADR1(VCC),
    .ADR2(VCC),
    .ADR3(\vga/ps2/ps2_clk_edge ),
    .O(\vga/ps2/timer_x [4])
  );
  defparam \vga/ps2/timer_r<5>/SRMUX .LOC = "CLB_R8C16.S0";
  X_INV \vga/ps2/timer_r<5>/SRMUX  (
    .I(reset_n_IBUF_0),
    .O(\vga/ps2/timer_r<5>/SRMUX_OUTPUTNOT )
  );
  defparam \vga/ps2/timer_x<7>1 .INIT = 16'h2222;
  defparam \vga/ps2/timer_x<7>1 .LOC = "CLB_R8C15.S1";
  X_LUT4 \vga/ps2/timer_x<7>1  (
    .ADR0(\vga/ps2/_addsub0000<7>_0 ),
    .ADR1(\vga/ps2/ps2_clk_edge ),
    .ADR2(VCC),
    .ADR3(VCC),
    .O(\vga/ps2/timer_x [7])
  );
  defparam \vga/ps2/timer_x<6>1 .INIT = 16'h5050;
  defparam \vga/ps2/timer_x<6>1 .LOC = "CLB_R8C15.S1";
  X_LUT4 \vga/ps2/timer_x<6>1  (
    .ADR0(\vga/ps2/ps2_clk_edge ),
    .ADR1(VCC),
    .ADR2(\vga/ps2/_addsub0000<6>_0 ),
    .ADR3(VCC),
    .O(\vga/ps2/timer_x [6])
  );
  defparam \vga/ps2/timer_r<7>/SRMUX .LOC = "CLB_R8C15.S1";
  X_INV \vga/ps2/timer_r<7>/SRMUX  (
    .I(reset_n_IBUF_0),
    .O(\vga/ps2/timer_r<7>/SRMUX_OUTPUTNOT )
  );
  defparam \vga/ps2/timer_r_7 .LOC = "CLB_R8C15.S1";
  defparam \vga/ps2/timer_r_7 .INIT = 1'b0;
  X_FF \vga/ps2/timer_r_7  (
    .I(\vga/ps2/timer_x [7]),
    .CE(VCC),
    .CLK(gray_cnt_FFd1_0),
    .SET(GND),
    .RST(\vga/ps2/timer_r<7>/FFX/RST ),
    .O(\vga/ps2/timer_r [7])
  );
  defparam \vga/ps2/timer_r<7>/FFX/RSTOR .LOC = "CLB_R8C15.S1";
  X_BUF \vga/ps2/timer_r<7>/FFX/RSTOR  (
    .I(\vga/ps2/timer_r<7>/SRMUX_OUTPUTNOT ),
    .O(\vga/ps2/timer_r<7>/FFX/RST )
  );
  defparam \vga/ps2/timer_x<9>1 .INIT = 16'h0C0C;
  defparam \vga/ps2/timer_x<9>1 .LOC = "CLB_R7C17.S0";
  X_LUT4 \vga/ps2/timer_x<9>1  (
    .ADR0(VCC),
    .ADR1(\vga/ps2/_addsub0000<9>_0 ),
    .ADR2(\vga/ps2/ps2_clk_edge ),
    .ADR3(VCC),
    .O(\vga/ps2/timer_x [9])
  );
  defparam \vga/ps2/timer_x<8>1 .INIT = 16'h0A0A;
  defparam \vga/ps2/timer_x<8>1 .LOC = "CLB_R7C17.S0";
  X_LUT4 \vga/ps2/timer_x<8>1  (
    .ADR0(\vga/ps2/_addsub0000<8>_0 ),
    .ADR1(VCC),
    .ADR2(\vga/ps2/ps2_clk_edge ),
    .ADR3(VCC),
    .O(\vga/ps2/timer_x [8])
  );
  defparam \vga/ps2/timer_r<9>/SRMUX .LOC = "CLB_R7C17.S0";
  X_INV \vga/ps2/timer_r<9>/SRMUX  (
    .I(reset_n_IBUF_0),
    .O(\vga/ps2/timer_r<9>/SRMUX_OUTPUTNOT )
  );
  defparam \vga/write_ctrl .INIT = 16'h1144;
  defparam \vga/write_ctrl .LOC = "CLB_R16C14.S1";
  X_LUT4 \vga/write_ctrl  (
    .ADR0(\vga/crt/state_FFd2_12 ),
    .ADR1(\vga/crt/state_FFd3_11 ),
    .ADR2(VCC),
    .ADR3(\vga/crt/state_FFd1_13 ),
    .O(\vga/N226 )
  );
  defparam \vga/crt/write_delay__mux0000<0>1 .INIT = 16'h0010;
  defparam \vga/crt/write_delay__mux0000<0>1 .LOC = "CLB_R16C14.S1";
  X_LUT4 \vga/crt/write_delay__mux0000<0>1  (
    .ADR0(\vga/crt/write_delay [0]),
    .ADR1(\vga/crt/state_FFd3_11 ),
    .ADR2(\vga/crt/state_FFd1_13 ),
    .ADR3(\vga/crt/state_FFd2_12 ),
    .O(\vga/crt/write_delay__mux0000 [0])
  );
  defparam \vga/crt/write_delay<0>/XUSED .LOC = "CLB_R16C14.S1";
  X_BUF \vga/crt/write_delay<0>/XUSED  (
    .I(\vga/N226 ),
    .O(\vga/N226_0 )
  );
  defparam \vga/crt/write_delay_0 .LOC = "CLB_R16C14.S1";
  defparam \vga/crt/write_delay_0 .INIT = 1'b0;
  X_FF \vga/crt/write_delay_0  (
    .I(\vga/crt/write_delay__mux0000 [0]),
    .CE(VCC),
    .CLK(\vga/crtclk_4 ),
    .SET(GND),
    .RST(\vga/crt/write_delay<0>/FFY/RST ),
    .O(\vga/crt/write_delay [0])
  );
  defparam \vga/crt/write_delay<0>/FFY/RSTOR .LOC = "CLB_R16C14.S1";
  X_INV \vga/crt/write_delay<0>/FFY/RSTOR  (
    .I(reset_n_IBUF_0),
    .O(\vga/crt/write_delay<0>/FFY/RST )
  );
  defparam \vga/crt/write_delay__mux0000<2>1 .INIT = 16'h28A0;
  defparam \vga/crt/write_delay__mux0000<2>1 .LOC = "CLB_R16C15.S0";
  X_LUT4 \vga/crt/write_delay__mux0000<2>1  (
    .ADR0(\vga/crt/_cmp_eq0004 ),
    .ADR1(\vga/crt/write_delay [1]),
    .ADR2(\vga/crt/write_delay [2]),
    .ADR3(\vga/crt/write_delay [0]),
    .O(\vga/crt/write_delay__mux0000 [2])
  );
  defparam \vga/crt/write_delay_2 .LOC = "CLB_R16C15.S0";
  defparam \vga/crt/write_delay_2 .INIT = 1'b0;
  X_FF \vga/crt/write_delay_2  (
    .I(\vga/crt/write_delay__mux0000 [2]),
    .CE(VCC),
    .CLK(\vga/crtclk_4 ),
    .SET(GND),
    .RST(\vga/crt/write_delay<2>/FFY/RST ),
    .O(\vga/crt/write_delay [2])
  );
  defparam \vga/crt/write_delay<2>/FFY/RSTOR .LOC = "CLB_R16C15.S0";
  X_INV \vga/crt/write_delay<2>/FFY/RSTOR  (
    .I(reset_n_IBUF_0),
    .O(\vga/crt/write_delay<2>/FFY/RST )
  );
  defparam \vga/_cmp_eq00001 .INIT = 16'hA000;
  defparam \vga/_cmp_eq00001 .LOC = "CLB_R13C6.S0";
  X_LUT4 \vga/_cmp_eq00001  (
    .ADR0(\vga/pclk [2]),
    .ADR1(VCC),
    .ADR2(\vga/pclk [1]),
    .ADR3(\vga/pclk [0]),
    .O(\vga/_cmp_eq0000 )
  );
  defparam \vga/charload/CKINV .LOC = "CLB_R13C6.S0";
  X_INV \vga/charload/CKINV  (
    .I(gray_cnt_FFd1_0),
    .O(\vga/charload/CKMUXNOT )
  );
  defparam \vga/charload .LOC = "CLB_R13C6.S0";
  defparam \vga/charload .INIT = 1'b0;
  X_FF \vga/charload  (
    .I(\vga/_cmp_eq0000 ),
    .CE(VCC),
    .CLK(\vga/charload/CKMUXNOT ),
    .SET(GND),
    .RST(\vga/charload/FFY/RST ),
    .O(\vga/charload_19 )
  );
  defparam \vga/charload/FFY/RSTOR .LOC = "CLB_R13C6.S0";
  X_INV \vga/charload/FFY/RSTOR  (
    .I(reset_n_IBUF_0),
    .O(\vga/charload/FFY/RST )
  );
  defparam \vga/crt/_not00101 .INIT = 16'hF008;
  defparam \vga/crt/_not00101 .LOC = "CLB_R15C17.S0";
  X_LUT4 \vga/crt/_not00101  (
    .ADR0(\vga/crt/state_FFd1_13 ),
    .ADR1(\vga/crt/eol_0 ),
    .ADR2(\vga/crt/state_FFd3_11 ),
    .ADR3(\vga/crt/state_FFd2_12 ),
    .O(\vga/crt/_not0010_pack_1 )
  );
  defparam \vga/crt/Mrom_set_newline1 .INIT = 16'h0040;
  defparam \vga/crt/Mrom_set_newline1 .LOC = "CLB_R15C17.S0";
  X_LUT4 \vga/crt/Mrom_set_newline1  (
    .ADR0(\vga/crt/state_FFd3_11 ),
    .ADR1(\vga/crt/eol_0 ),
    .ADR2(\vga/crt/state_FFd1_13 ),
    .ADR3(\vga/crt/state_FFd2_12 ),
    .O(\vga/crt/N3 )
  );
  defparam \vga/crt/newline/XUSED .LOC = "CLB_R15C17.S0";
  X_BUF \vga/crt/newline/XUSED  (
    .I(\vga/crt/_not0010_pack_1 ),
    .O(\vga/crt/_not0010 )
  );
  defparam \vga/crt/newline .LOC = "CLB_R15C17.S0";
  defparam \vga/crt/newline .INIT = 1'b0;
  X_FF \vga/crt/newline  (
    .I(\vga/crt/N3 ),
    .CE(\vga/crt/_not0010 ),
    .CLK(\vga/crtclk_4 ),
    .SET(GND),
    .RST(\vga/crt/newline/FFY/RST ),
    .O(\vga/crt/newline_20 )
  );
  defparam \vga/crt/newline/FFY/RSTOR .LOC = "CLB_R15C17.S0";
  X_INV \vga/crt/newline/FFY/RSTOR  (
    .I(reset_n_IBUF_0),
    .O(\vga/crt/newline/FFY/RST )
  );
  defparam \vga/pclk__mux0000<1>1 .INIT = 16'hFDFE;
  defparam \vga/pclk__mux0000<1>1 .LOC = "CLB_R14C6.S1";
  X_LUT4 \vga/pclk__mux0000<1>1  (
    .ADR0(\vga/pclk [0]),
    .ADR1(\vga/clearing ),
    .ADR2(\vga/vgacore/hblank_21 ),
    .ADR3(\vga/pclk [1]),
    .O(\vga/pclk__mux0000 [1])
  );
  defparam \vga/pclk__mux0000<0>1 .INIT = 16'hDDFD;
  defparam \vga/pclk__mux0000<0>1 .LOC = "CLB_R14C6.S1";
  X_LUT4 \vga/pclk__mux0000<0>1  (
    .ADR0(\vga/pclk [0]),
    .ADR1(\vga/vgacore/hblank_21 ),
    .ADR2(\vga/crt/N91 ),
    .ADR3(\vga/crt/state_FFd1_13 ),
    .O(\vga/pclk__mux0000 [0])
  );
  defparam \vga/pclk<1>/SRMUX .LOC = "CLB_R14C6.S1";
  X_INV \vga/pclk<1>/SRMUX  (
    .I(reset_n_IBUF_0),
    .O(\vga/pclk<1>/SRMUX_OUTPUTNOT )
  );
  defparam \vga/crt/cursor_h_Eqn_11 .INIT = 16'h5050;
  defparam \vga/crt/cursor_h_Eqn_11 .LOC = "CLB_R18C13.S1";
  X_LUT4 \vga/crt/cursor_h_Eqn_11  (
    .ADR0(\vga/crt/_and0000_0 ),
    .ADR1(VCC),
    .ADR2(\vga/crt/Result<1>1_0 ),
    .ADR3(VCC),
    .O(\vga/crt/cursor_h_Eqn_1 )
  );
  defparam \vga/crt/cursor_h_Eqn_01 .INIT = 16'h000F;
  defparam \vga/crt/cursor_h_Eqn_01 .LOC = "CLB_R18C13.S1";
  X_LUT4 \vga/crt/cursor_h_Eqn_01  (
    .ADR0(VCC),
    .ADR1(VCC),
    .ADR2(\vga/crt/cursor_h [0]),
    .ADR3(\vga/crt/_and0000_0 ),
    .O(\vga/crt/cursor_h_Eqn_0 )
  );
  defparam \vga/crt/cursor_h<1>/SRMUX .LOC = "CLB_R18C13.S1";
  X_INV \vga/crt/cursor_h<1>/SRMUX  (
    .I(reset_n_IBUF_0),
    .O(\vga/crt/cursor_h<1>/SRMUX_OUTPUTNOT )
  );
  defparam \vga/crt/cursor_h_Eqn_31 .INIT = 16'h00F0;
  defparam \vga/crt/cursor_h_Eqn_31 .LOC = "CLB_R17C13.S0";
  X_LUT4 \vga/crt/cursor_h_Eqn_31  (
    .ADR0(VCC),
    .ADR1(VCC),
    .ADR2(\vga/crt/Result<3>1_0 ),
    .ADR3(\vga/crt/_and0000_0 ),
    .O(\vga/crt/cursor_h_Eqn_3 )
  );
  defparam \vga/crt/cursor_h_Eqn_21 .INIT = 16'h00F0;
  defparam \vga/crt/cursor_h_Eqn_21 .LOC = "CLB_R17C13.S0";
  X_LUT4 \vga/crt/cursor_h_Eqn_21  (
    .ADR0(VCC),
    .ADR1(VCC),
    .ADR2(\vga/crt/Result<2>1_0 ),
    .ADR3(\vga/crt/_and0000_0 ),
    .O(\vga/crt/cursor_h_Eqn_2 )
  );
  defparam \vga/crt/cursor_h<3>/SRMUX .LOC = "CLB_R17C13.S0";
  X_INV \vga/crt/cursor_h<3>/SRMUX  (
    .I(reset_n_IBUF_0),
    .O(\vga/crt/cursor_h<3>/SRMUX_OUTPUTNOT )
  );
  defparam \vga/crt/cursor_h_Eqn_51 .INIT = 16'h3030;
  defparam \vga/crt/cursor_h_Eqn_51 .LOC = "CLB_R17C14.S0";
  X_LUT4 \vga/crt/cursor_h_Eqn_51  (
    .ADR0(VCC),
    .ADR1(\vga/crt/_and0000_0 ),
    .ADR2(\vga/crt/Result<5>1_0 ),
    .ADR3(VCC),
    .O(\vga/crt/cursor_h_Eqn_5 )
  );
  defparam \vga/crt/cursor_h_Eqn_41 .INIT = 16'h2222;
  defparam \vga/crt/cursor_h_Eqn_41 .LOC = "CLB_R17C14.S0";
  X_LUT4 \vga/crt/cursor_h_Eqn_41  (
    .ADR0(\vga/crt/Result<4>1_0 ),
    .ADR1(\vga/crt/_and0000_0 ),
    .ADR2(VCC),
    .ADR3(VCC),
    .O(\vga/crt/cursor_h_Eqn_4 )
  );
  defparam \vga/crt/cursor_h<5>/SRMUX .LOC = "CLB_R17C14.S0";
  X_INV \vga/crt/cursor_h<5>/SRMUX  (
    .I(reset_n_IBUF_0),
    .O(\vga/crt/cursor_h<5>/SRMUX_OUTPUTNOT )
  );
  defparam \vga/crt/cursor_h_Eqn_61 .INIT = 16'h00F0;
  defparam \vga/crt/cursor_h_Eqn_61 .LOC = "CLB_R16C13.S1";
  X_LUT4 \vga/crt/cursor_h_Eqn_61  (
    .ADR0(VCC),
    .ADR1(VCC),
    .ADR2(\vga/crt/Result<6>_0 ),
    .ADR3(\vga/crt/_and0000_0 ),
    .O(\vga/crt/cursor_h_Eqn_6 )
  );
  defparam \vga/crt/cursor_h_6 .LOC = "CLB_R16C13.S1";
  defparam \vga/crt/cursor_h_6 .INIT = 1'b0;
  X_FF \vga/crt/cursor_h_6  (
    .I(\vga/crt/cursor_h_Eqn_6 ),
    .CE(\vga/crt/_not0006_0 ),
    .CLK(\vga/crtclk_4 ),
    .SET(GND),
    .RST(\vga/crt/cursor_h<6>/FFY/RST ),
    .O(\vga/crt/cursor_h [6])
  );
  defparam \vga/crt/cursor_h<6>/FFY/RSTOR .LOC = "CLB_R16C13.S1";
  X_INV \vga/crt/cursor_h<6>/FFY/RSTOR  (
    .I(reset_n_IBUF_0),
    .O(\vga/crt/cursor_h<6>/FFY/RST )
  );
  defparam \vga/ps2/ps2_clk_r<2>/SRMUX .LOC = "CLB_R11C8.S1";
  X_INV \vga/ps2/ps2_clk_r<2>/SRMUX  (
    .I(reset_n_IBUF_0),
    .O(\vga/ps2/ps2_clk_r<2>/SRMUX_OUTPUTNOT )
  );
  defparam \vga/ps2/ps2_clk_r_1 .LOC = "CLB_R11C8.S1";
  defparam \vga/ps2/ps2_clk_r_1 .INIT = 1'b1;
  X_FF \vga/ps2/ps2_clk_r_1  (
    .I(\vga/ps2/ps2_clk_r [0]),
    .CE(VCC),
    .CLK(gray_cnt_FFd1_0),
    .SET(\vga/ps2/ps2_clk_r<2>/FFY/SET ),
    .RST(GND),
    .O(\vga/ps2/ps2_clk_r [1])
  );
  defparam \vga/ps2/ps2_clk_r<2>/FFY/SETOR .LOC = "CLB_R11C8.S1";
  X_BUF \vga/ps2/ps2_clk_r<2>/FFY/SETOR  (
    .I(\vga/ps2/ps2_clk_r<2>/SRMUX_OUTPUTNOT ),
    .O(\vga/ps2/ps2_clk_r<2>/FFY/SET )
  );
  defparam \vga/ps2/ps2_clk_r<4>/SRMUX .LOC = "CLB_R10C13.S0";
  X_INV \vga/ps2/ps2_clk_r<4>/SRMUX  (
    .I(reset_n_IBUF_0),
    .O(\vga/ps2/ps2_clk_r<4>/SRMUX_OUTPUTNOT )
  );
  defparam \vga/ps2/ps2_clk_r_3 .LOC = "CLB_R10C13.S0";
  defparam \vga/ps2/ps2_clk_r_3 .INIT = 1'b1;
  X_FF \vga/ps2/ps2_clk_r_3  (
    .I(\vga/ps2/ps2_clk_r [2]),
    .CE(VCC),
    .CLK(gray_cnt_FFd1_0),
    .SET(\vga/ps2/ps2_clk_r<4>/FFY/SET ),
    .RST(GND),
    .O(\vga/ps2/ps2_clk_r [3])
  );
  defparam \vga/ps2/ps2_clk_r<4>/FFY/SETOR .LOC = "CLB_R10C13.S0";
  X_BUF \vga/ps2/ps2_clk_r<4>/FFY/SETOR  (
    .I(\vga/ps2/ps2_clk_r<4>/SRMUX_OUTPUTNOT ),
    .O(\vga/ps2/ps2_clk_r<4>/FFY/SET )
  );
  defparam \vga/scancode_convert/scancode_rom/data<2>1354 .INIT = 16'hD0C0;
  defparam \vga/scancode_convert/scancode_rom/data<2>1354 .LOC = "CLB_R14C35.S1";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<2>1354  (
    .ADR0(\vga/scancode_convert/sc [4]),
    .ADR1(\vga/scancode_convert/sc [1]),
    .ADR2(\vga/scancode_convert/sc [3]),
    .ADR3(\vga/scancode_convert/sc [0]),
    .O(\vga/scancode_convert/scancode_rom/data<2>1_map1129 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<1>2109 .INIT = 16'h8A00;
  defparam \vga/scancode_convert/scancode_rom/data<1>2109 .LOC = "CLB_R14C35.S1";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<1>2109  (
    .ADR0(\vga/scancode_convert/sc [3]),
    .ADR1(\vga/scancode_convert/sc [0]),
    .ADR2(\vga/scancode_convert/sc [4]),
    .ADR3(\vga/scancode_convert/sc [1]),
    .O(\vga/scancode_convert/scancode_rom/data<1>2_map1708 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<2>1_map1129/XUSED .LOC = "CLB_R14C35.S1";
  X_BUF \vga/scancode_convert/scancode_rom/data<2>1_map1129/XUSED  (
    .I(\vga/scancode_convert/scancode_rom/data<2>1_map1129 ),
    .O(\vga/scancode_convert/scancode_rom/data<2>1_map1129_0 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<2>1_map1129/YUSED .LOC = "CLB_R14C35.S1";
  X_BUF \vga/scancode_convert/scancode_rom/data<2>1_map1129/YUSED  (
    .I(\vga/scancode_convert/scancode_rom/data<1>2_map1708 ),
    .O(\vga/scancode_convert/scancode_rom/data<1>2_map1708_0 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<0>1370_SW2 .INIT = 16'hA02A;
  defparam \vga/scancode_convert/scancode_rom/data<0>1370_SW2 .LOC = "CLB_R16C36.S0";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<0>1370_SW2  (
    .ADR0(\vga/scancode_convert/sc [1]),
    .ADR1(\vga/scancode_convert/sc [0]),
    .ADR2(\vga/scancode_convert/sc [3]),
    .ADR3(\vga/scancode_convert/sc [4]),
    .O(N3178)
  );
  defparam \vga/scancode_convert/scancode_rom/data<1>2147 .INIT = 16'hCFCE;
  defparam \vga/scancode_convert/scancode_rom/data<1>2147 .LOC = "CLB_R16C36.S0";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<1>2147  (
    .ADR0(\vga/scancode_convert/sc [1]),
    .ADR1(\vga/scancode_convert/sc [3]),
    .ADR2(\vga/scancode_convert/sc [0]),
    .ADR3(\vga/scancode_convert/sc [4]),
    .O(\vga/scancode_convert/scancode_rom/data<1>2_map1717 )
  );
  defparam \N3178/XUSED .LOC = "CLB_R16C36.S0";
  X_BUF \N3178/XUSED  (
    .I(N3178),
    .O(N3178_0)
  );
  defparam \N3178/YUSED .LOC = "CLB_R16C36.S0";
  X_BUF \N3178/YUSED  (
    .I(\vga/scancode_convert/scancode_rom/data<1>2_map1717 ),
    .O(\vga/scancode_convert/scancode_rom/data<1>2_map1717_0 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<5>3852_SW1 .INIT = 16'hEC2F;
  defparam \vga/scancode_convert/scancode_rom/data<5>3852_SW1 .LOC = "CLB_R13C36.S0";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<5>3852_SW1  (
    .ADR0(\vga/scancode_convert/raise ),
    .ADR1(\vga/scancode_convert/sc [4]),
    .ADR2(\vga/scancode_convert/sc [1]),
    .ADR3(\vga/scancode_convert/sc [0]),
    .O(N3136)
  );
  defparam \vga/scancode_convert/scancode_rom/data<1>2184 .INIT = 16'h0F80;
  defparam \vga/scancode_convert/scancode_rom/data<1>2184 .LOC = "CLB_R13C36.S0";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<1>2184  (
    .ADR0(\vga/scancode_convert/sc [4]),
    .ADR1(\vga/scancode_convert/raise ),
    .ADR2(\vga/scancode_convert/sc [1]),
    .ADR3(\vga/scancode_convert/sc [0]),
    .O(\vga/scancode_convert/scancode_rom/data<1>2_map1729 )
  );
  defparam \N3136/XUSED .LOC = "CLB_R13C36.S0";
  X_BUF \N3136/XUSED  (
    .I(N3136),
    .O(N3136_0)
  );
  defparam \N3136/YUSED .LOC = "CLB_R13C36.S0";
  X_BUF \N3136/YUSED  (
    .I(\vga/scancode_convert/scancode_rom/data<1>2_map1729 ),
    .O(\vga/scancode_convert/scancode_rom/data<1>2_map1729_0 )
  );
  defparam \vga/scancode_convert/_cmp_eq00051 .INIT = 16'h1010;
  defparam \vga/scancode_convert/_cmp_eq00051 .LOC = "CLB_R13C26.S1";
  X_LUT4 \vga/scancode_convert/_cmp_eq00051  (
    .ADR0(\vga/scancode_convert/hold_count [0]),
    .ADR1(\vga/scancode_convert/hold_count [1]),
    .ADR2(\vga/scancode_convert/hold_count [2]),
    .ADR3(VCC),
    .O(\vga/scancode_convert/_cmp_eq0005_pack_1 )
  );
  defparam \vga/scancode_convert/state_FFd5-In_SW0 .INIT = 16'hFCF0;
  defparam \vga/scancode_convert/state_FFd5-In_SW0 .LOC = "CLB_R13C26.S1";
  X_LUT4 \vga/scancode_convert/state_FFd5-In_SW0  (
    .ADR0(VCC),
    .ADR1(\vga/scancode_convert/state_FFd1_34 ),
    .ADR2(\vga/scancode_convert/state_FFd6_35 ),
    .ADR3(\vga/scancode_convert/_cmp_eq0005 ),
    .O(N124)
  );
  defparam \vga/scancode_convert/_cmp_eq0005/XUSED .LOC = "CLB_R13C26.S1";
  X_BUF \vga/scancode_convert/_cmp_eq0005/XUSED  (
    .I(\vga/scancode_convert/_cmp_eq0005_pack_1 ),
    .O(\vga/scancode_convert/_cmp_eq0005 )
  );
  defparam \vga/scancode_convert/_cmp_eq0005/YUSED .LOC = "CLB_R13C26.S1";
  X_BUF \vga/scancode_convert/_cmp_eq0005/YUSED  (
    .I(N124),
    .O(N124_0)
  );
  defparam \vga/crt/_not00071 .INIT = 16'hC0E0;
  defparam \vga/crt/_not00071 .LOC = "CLB_R16C14.S0";
  X_LUT4 \vga/crt/_not00071  (
    .ADR0(\vga/crt/eol_0 ),
    .ADR1(\vga/crt/state_FFd1_13 ),
    .ADR2(\vga/crt/state_FFd2_12 ),
    .ADR3(\vga/crt/state_FFd3_11 ),
    .O(\vga/crt/_not0007 )
  );
  defparam \vga/crt/_not00061 .INIT = 16'hAEAC;
  defparam \vga/crt/_not00061 .LOC = "CLB_R16C14.S0";
  X_LUT4 \vga/crt/_not00061  (
    .ADR0(\vga/crt/state_FFd1_13 ),
    .ADR1(\vga/crt/state_FFd2_12 ),
    .ADR2(\vga/crt/state_FFd3_11 ),
    .ADR3(\vga/crt/eol_0 ),
    .O(\vga/crt/_not0006 )
  );
  defparam \vga/crt/_not0007/XUSED .LOC = "CLB_R16C14.S0";
  X_BUF \vga/crt/_not0007/XUSED  (
    .I(\vga/crt/_not0007 ),
    .O(\vga/crt/_not0007_0 )
  );
  defparam \vga/crt/_not0007/YUSED .LOC = "CLB_R16C14.S0";
  X_BUF \vga/crt/_not0007/YUSED  (
    .I(\vga/crt/_not0006 ),
    .O(\vga/crt/_not0006_0 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<0>1123 .INIT = 16'hCCDC;
  defparam \vga/scancode_convert/scancode_rom/data<0>1123 .LOC = "CLB_R15C33.S0";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<0>1123  (
    .ADR0(\vga/scancode_convert/sc [1]),
    .ADR1(\vga/scancode_convert/sc [3]),
    .ADR2(\vga/scancode_convert/sc [0]),
    .ADR3(\vga/scancode_convert/sc [4]),
    .O(\vga/scancode_convert/scancode_rom/data<0>1_map1449 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<2>1308 .INIT = 16'h24FF;
  defparam \vga/scancode_convert/scancode_rom/data<2>1308 .LOC = "CLB_R15C33.S0";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<2>1308  (
    .ADR0(\vga/scancode_convert/sc [0]),
    .ADR1(\vga/scancode_convert/sc [1]),
    .ADR2(\vga/scancode_convert/sc [4]),
    .ADR3(\vga/scancode_convert/sc [3]),
    .O(\vga/scancode_convert/scancode_rom/data<2>1_map1121 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<0>1_map1449/XUSED .LOC = "CLB_R15C33.S0";
  X_BUF \vga/scancode_convert/scancode_rom/data<0>1_map1449/XUSED  (
    .I(\vga/scancode_convert/scancode_rom/data<0>1_map1449 ),
    .O(\vga/scancode_convert/scancode_rom/data<0>1_map1449_0 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<0>1_map1449/YUSED .LOC = "CLB_R15C33.S0";
  X_BUF \vga/scancode_convert/scancode_rom/data<0>1_map1449/YUSED  (
    .I(\vga/scancode_convert/scancode_rom/data<2>1_map1121 ),
    .O(\vga/scancode_convert/scancode_rom/data<2>1_map1121_0 )
  );
  defparam \vga/crt/_and0001_SW0 .INIT = 16'hFF55;
  defparam \vga/crt/_and0001_SW0 .LOC = "CLB_R15C15.S0";
  X_LUT4 \vga/crt/_and0001_SW0  (
    .ADR0(\vga/crt/state_FFd2_12 ),
    .ADR1(VCC),
    .ADR2(VCC),
    .ADR3(\vga/crt/state_FFd1_13 ),
    .O(N235)
  );
  defparam \vga/crt/_not00081 .INIT = 16'h0D00;
  defparam \vga/crt/_not00081 .LOC = "CLB_R15C15.S0";
  X_LUT4 \vga/crt/_not00081  (
    .ADR0(\vga/crt/state_FFd3_11 ),
    .ADR1(\vga/insert_crt_data ),
    .ADR2(\vga/crt/state_FFd1_13 ),
    .ADR3(\vga/crt/state_FFd2_12 ),
    .O(\vga/crt/_not0008 )
  );
  defparam \N235/XUSED .LOC = "CLB_R15C15.S0";
  X_BUF \N235/XUSED  (
    .I(N235),
    .O(N235_0)
  );
  defparam \N235/YUSED .LOC = "CLB_R15C15.S0";
  X_BUF \N235/YUSED  (
    .I(\vga/crt/_not0008 ),
    .O(\vga/crt/_not0008_0 )
  );
  defparam \vga/char_rom/Mrom_data216 .INIT = 16'h8000;
  defparam \vga/char_rom/Mrom_data216 .LOC = "CLB_R11C5.S0";
  X_LUT4 \vga/char_rom/Mrom_data216  (
    .ADR0(\vga/vgacore/vcnt [0]),
    .ADR1(\vga/vgacore/vcnt [2]),
    .ADR2(\vga/rom_addr_char [0]),
    .ADR3(\vga/vgacore/vcnt [1]),
    .O(\vga/N224 )
  );
  defparam \vga/char_rom/Mrom_data10 .INIT = 16'h2034;
  defparam \vga/char_rom/Mrom_data10 .LOC = "CLB_R11C5.S0";
  X_LUT4 \vga/char_rom/Mrom_data10  (
    .ADR0(\vga/vgacore/vcnt [0]),
    .ADR1(\vga/vgacore/vcnt [2]),
    .ADR2(\vga/vgacore/vcnt [1]),
    .ADR3(\vga/rom_addr_char [0]),
    .O(\vga/N13 )
  );
  defparam \vga/N224/XUSED .LOC = "CLB_R11C5.S0";
  X_BUF \vga/N224/XUSED  (
    .I(\vga/N224 ),
    .O(\vga/N224_0 )
  );
  defparam \vga/N224/YUSED .LOC = "CLB_R11C5.S0";
  X_BUF \vga/N224/YUSED  (
    .I(\vga/N13 ),
    .O(\vga/N13_0 )
  );
  defparam \vga/char_rom/Mrom_data11 .INIT = 16'h0080;
  defparam \vga/char_rom/Mrom_data11 .LOC = "CLB_R19C2.S0";
  X_LUT4 \vga/char_rom/Mrom_data11  (
    .ADR0(\vga/vgacore/vcnt [1]),
    .ADR1(\vga/rom_addr_char [0]),
    .ADR2(\vga/vgacore/vcnt [0]),
    .ADR3(\vga/vgacore/vcnt [2]),
    .O(\vga/N14_pack_1 )
  );
  defparam \vga/rom_addr_char<2>4 .INIT = 16'h0A00;
  defparam \vga/rom_addr_char<2>4 .LOC = "CLB_R19C2.S0";
  X_LUT4 \vga/rom_addr_char<2>4  (
    .ADR0(\vga/rom_addr_char [2]),
    .ADR1(VCC),
    .ADR2(\vga/rom_addr_char_1_1_7 ),
    .ADR3(\vga/N14 ),
    .O(\vga/rom_addr_char<2>11_167 )
  );
  defparam \vga/N14/XUSED .LOC = "CLB_R19C2.S0";
  X_BUF \vga/N14/XUSED  (
    .I(\vga/N14_pack_1 ),
    .O(\vga/N14 )
  );
  defparam \vga/N14/YUSED .LOC = "CLB_R19C2.S0";
  X_BUF \vga/N14/YUSED  (
    .I(\vga/rom_addr_char<2>11_167 ),
    .O(\vga/rom_addr_char<2>11_0 )
  );
  defparam \vga/char_rom/Mrom_data214 .INIT = 16'h0004;
  defparam \vga/char_rom/Mrom_data214 .LOC = "CLB_R1C3.S1";
  X_LUT4 \vga/char_rom/Mrom_data214  (
    .ADR0(\vga/vgacore/vcnt [1]),
    .ADR1(\vga/vgacore/vcnt [2]),
    .ADR2(\vga/rom_addr_char [0]),
    .ADR3(\vga/vgacore/vcnt [0]),
    .O(\vga/N222 )
  );
  defparam \vga/char_rom/Mrom_data20 .INIT = 16'h3BBC;
  defparam \vga/char_rom/Mrom_data20 .LOC = "CLB_R1C3.S1";
  X_LUT4 \vga/char_rom/Mrom_data20  (
    .ADR0(\vga/rom_addr_char [0]),
    .ADR1(\vga/vgacore/vcnt [2]),
    .ADR2(\vga/vgacore/vcnt [1]),
    .ADR3(\vga/vgacore/vcnt [0]),
    .O(\vga/N23 )
  );
  defparam \vga/N222/XUSED .LOC = "CLB_R1C3.S1";
  X_BUF \vga/N222/XUSED  (
    .I(\vga/N222 ),
    .O(\vga/N222_0 )
  );
  defparam \vga/N222/YUSED .LOC = "CLB_R1C3.S1";
  X_BUF \vga/N222/YUSED  (
    .I(\vga/N23 ),
    .O(\vga/N23_0 )
  );
  defparam \vga/char_rom/Mrom_data213 .INIT = 16'h2418;
  defparam \vga/char_rom/Mrom_data213 .LOC = "CLB_R13C3.S1";
  X_LUT4 \vga/char_rom/Mrom_data213  (
    .ADR0(\vga/rom_addr_char [0]),
    .ADR1(\vga/vgacore/vcnt [0]),
    .ADR2(\vga/vgacore/vcnt [1]),
    .ADR3(\vga/vgacore/vcnt [2]),
    .O(\vga/N221 )
  );
  defparam \vga/char_rom/Mrom_data12 .INIT = 16'h0400;
  defparam \vga/char_rom/Mrom_data12 .LOC = "CLB_R13C3.S1";
  X_LUT4 \vga/char_rom/Mrom_data12  (
    .ADR0(\vga/vgacore/vcnt [1]),
    .ADR1(\vga/rom_addr_char [0]),
    .ADR2(\vga/vgacore/vcnt [2]),
    .ADR3(\vga/vgacore/vcnt [0]),
    .O(\vga/N15 )
  );
  defparam \vga/N221/XUSED .LOC = "CLB_R13C3.S1";
  X_BUF \vga/N221/XUSED  (
    .I(\vga/N221 ),
    .O(\vga/N221_0 )
  );
  defparam \vga/N221/YUSED .LOC = "CLB_R13C3.S1";
  X_BUF \vga/N221/YUSED  (
    .I(\vga/N15 ),
    .O(\vga/N15_0 )
  );
  defparam \vga/char_rom/Mrom_data212 .INIT = 16'h1282;
  defparam \vga/char_rom/Mrom_data212 .LOC = "CLB_R3C1.S0";
  X_LUT4 \vga/char_rom/Mrom_data212  (
    .ADR0(\vga/vgacore/vcnt [1]),
    .ADR1(\vga/rom_addr_char [0]),
    .ADR2(\vga/vgacore/vcnt [0]),
    .ADR3(\vga/vgacore/vcnt [2]),
    .O(\vga/N219 )
  );
  defparam \vga/char_rom/Mrom_data21 .INIT = 16'h2326;
  defparam \vga/char_rom/Mrom_data21 .LOC = "CLB_R3C1.S0";
  X_LUT4 \vga/char_rom/Mrom_data21  (
    .ADR0(\vga/vgacore/vcnt [0]),
    .ADR1(\vga/vgacore/vcnt [1]),
    .ADR2(\vga/rom_addr_char [0]),
    .ADR3(\vga/vgacore/vcnt [2]),
    .O(\vga/N24 )
  );
  defparam \vga/N219/XUSED .LOC = "CLB_R3C1.S0";
  X_BUF \vga/N219/XUSED  (
    .I(\vga/N219 ),
    .O(\vga/N219_0 )
  );
  defparam \vga/N219/YUSED .LOC = "CLB_R3C1.S0";
  X_BUF \vga/N219/YUSED  (
    .I(\vga/N24 ),
    .O(\vga/N24_0 )
  );
  defparam \vga/char_rom/Mrom_data211 .INIT = 16'h9C6C;
  defparam \vga/char_rom/Mrom_data211 .LOC = "CLB_R2C2.S1";
  X_LUT4 \vga/char_rom/Mrom_data211  (
    .ADR0(\vga/rom_addr_char [0]),
    .ADR1(\vga/vgacore/vcnt [1]),
    .ADR2(\vga/vgacore/vcnt [2]),
    .ADR3(\vga/vgacore/vcnt [0]),
    .O(\vga/N218 )
  );
  defparam \vga/char_rom/Mrom_data13 .INIT = 16'h030E;
  defparam \vga/char_rom/Mrom_data13 .LOC = "CLB_R2C2.S1";
  X_LUT4 \vga/char_rom/Mrom_data13  (
    .ADR0(\vga/vgacore/vcnt [0]),
    .ADR1(\vga/vgacore/vcnt [2]),
    .ADR2(\vga/rom_addr_char [0]),
    .ADR3(\vga/vgacore/vcnt [1]),
    .O(\vga/N16 )
  );
  defparam \vga/N218/XUSED .LOC = "CLB_R2C2.S1";
  X_BUF \vga/N218/XUSED  (
    .I(\vga/N218 ),
    .O(\vga/N218_0 )
  );
  defparam \vga/N218/YUSED .LOC = "CLB_R2C2.S1";
  X_BUF \vga/N218/YUSED  (
    .I(\vga/N16 ),
    .O(\vga/N16_0 )
  );
  defparam \vga/char_rom/Mrom_data99 .INIT = 16'h4250;
  defparam \vga/char_rom/Mrom_data99 .LOC = "CLB_R10C3.S1";
  X_LUT4 \vga/char_rom/Mrom_data99  (
    .ADR0(\vga/vgacore/vcnt_1_1_8 ),
    .ADR1(\vga/vgacore/vcnt_2_1_9 ),
    .ADR2(\vga/vgacore/vcnt_0_1_17 ),
    .ADR3(\vga/rom_addr_char_0_1_18 ),
    .O(\vga/N104 )
  );
  defparam \vga/char_rom/Mrom_data30 .INIT = 16'h7701;
  defparam \vga/char_rom/Mrom_data30 .LOC = "CLB_R10C3.S1";
  X_LUT4 \vga/char_rom/Mrom_data30  (
    .ADR0(\vga/vgacore/vcnt_1_1_8 ),
    .ADR1(\vga/vgacore/vcnt_2_1_9 ),
    .ADR2(\vga/vgacore/vcnt_0_1_17 ),
    .ADR3(\vga/rom_addr_char_0_1_18 ),
    .O(\vga/N33 )
  );
  defparam \vga/N104/XUSED .LOC = "CLB_R10C3.S1";
  X_BUF \vga/N104/XUSED  (
    .I(\vga/N104 ),
    .O(\vga/N104_0 )
  );
  defparam \vga/N104/YUSED .LOC = "CLB_R10C3.S1";
  X_BUF \vga/N104/YUSED  (
    .I(\vga/N33 ),
    .O(\vga/N33_0 )
  );
  defparam \vga/char_rom/Mrom_data209 .INIT = 16'h282C;
  defparam \vga/char_rom/Mrom_data209 .LOC = "CLB_R2C2.S0";
  X_LUT4 \vga/char_rom/Mrom_data209  (
    .ADR0(\vga/rom_addr_char [0]),
    .ADR1(\vga/vgacore/vcnt [1]),
    .ADR2(\vga/vgacore/vcnt [2]),
    .ADR3(\vga/vgacore/vcnt [0]),
    .O(\vga/N216 )
  );
  defparam \vga/char_rom/Mrom_data22 .INIT = 16'h1596;
  defparam \vga/char_rom/Mrom_data22 .LOC = "CLB_R2C2.S0";
  X_LUT4 \vga/char_rom/Mrom_data22  (
    .ADR0(\vga/rom_addr_char [0]),
    .ADR1(\vga/vgacore/vcnt [2]),
    .ADR2(\vga/vgacore/vcnt [1]),
    .ADR3(\vga/vgacore/vcnt [0]),
    .O(\vga/N25 )
  );
  defparam \vga/N216/XUSED .LOC = "CLB_R2C2.S0";
  X_BUF \vga/N216/XUSED  (
    .I(\vga/N216 ),
    .O(\vga/N216_0 )
  );
  defparam \vga/N216/YUSED .LOC = "CLB_R2C2.S0";
  X_BUF \vga/N216/YUSED  (
    .I(\vga/N25 ),
    .O(\vga/N25_0 )
  );
  defparam \vga/char_rom/Mrom_data208 .INIT = 16'h4030;
  defparam \vga/char_rom/Mrom_data208 .LOC = "CLB_R3C1.S1";
  X_LUT4 \vga/char_rom/Mrom_data208  (
    .ADR0(\vga/vgacore/vcnt [2]),
    .ADR1(\vga/rom_addr_char [0]),
    .ADR2(\vga/vgacore/vcnt [1]),
    .ADR3(\vga/vgacore/vcnt [0]),
    .O(\vga/N215 )
  );
  defparam \vga/char_rom/Mrom_data14 .INIT = 16'h0D78;
  defparam \vga/char_rom/Mrom_data14 .LOC = "CLB_R3C1.S1";
  X_LUT4 \vga/char_rom/Mrom_data14  (
    .ADR0(\vga/vgacore/vcnt [2]),
    .ADR1(\vga/rom_addr_char [0]),
    .ADR2(\vga/vgacore/vcnt [1]),
    .ADR3(\vga/vgacore/vcnt [0]),
    .O(\vga/N17 )
  );
  defparam \vga/N215/XUSED .LOC = "CLB_R3C1.S1";
  X_BUF \vga/N215/XUSED  (
    .I(\vga/N215 ),
    .O(\vga/N215_0 )
  );
  defparam \vga/N215/YUSED .LOC = "CLB_R3C1.S1";
  X_BUF \vga/N215/YUSED  (
    .I(\vga/N17 ),
    .O(\vga/N17_0 )
  );
  defparam \vga/char_rom/Mrom_data97 .INIT = 16'h4611;
  defparam \vga/char_rom/Mrom_data97 .LOC = "CLB_R11C2.S0";
  X_LUT4 \vga/char_rom/Mrom_data97  (
    .ADR0(\vga/vgacore/vcnt_2_1_9 ),
    .ADR1(\vga/vgacore/vcnt_0_1_17 ),
    .ADR2(\vga/rom_addr_char_0_1_18 ),
    .ADR3(\vga/vgacore/vcnt_1_1_8 ),
    .O(\vga/N102 )
  );
  defparam \vga/char_rom/Mrom_data31 .INIT = 16'h7757;
  defparam \vga/char_rom/Mrom_data31 .LOC = "CLB_R11C2.S0";
  X_LUT4 \vga/char_rom/Mrom_data31  (
    .ADR0(\vga/vgacore/vcnt_2_1_9 ),
    .ADR1(\vga/vgacore/vcnt_1_1_8 ),
    .ADR2(\vga/vgacore/vcnt_0_1_17 ),
    .ADR3(\vga/rom_addr_char_0_1_18 ),
    .O(\vga/N34 )
  );
  defparam \vga/N102/XUSED .LOC = "CLB_R11C2.S0";
  X_BUF \vga/N102/XUSED  (
    .I(\vga/N102 ),
    .O(\vga/N102_0 )
  );
  defparam \vga/N102/YUSED .LOC = "CLB_R11C2.S0";
  X_BUF \vga/N102/YUSED  (
    .I(\vga/N34 ),
    .O(\vga/N34_0 )
  );
  defparam \vga/char_rom/Mrom_data207 .INIT = 16'h64EE;
  defparam \vga/char_rom/Mrom_data207 .LOC = "CLB_R1C3.S0";
  X_LUT4 \vga/char_rom/Mrom_data207  (
    .ADR0(\vga/vgacore/vcnt [1]),
    .ADR1(\vga/vgacore/vcnt [2]),
    .ADR2(\vga/vgacore/vcnt [0]),
    .ADR3(\vga/rom_addr_char [0]),
    .O(\vga/N214 )
  );
  defparam \vga/char_rom/Mrom_data23 .INIT = 16'h7C01;
  defparam \vga/char_rom/Mrom_data23 .LOC = "CLB_R1C3.S0";
  X_LUT4 \vga/char_rom/Mrom_data23  (
    .ADR0(\vga/vgacore/vcnt [1]),
    .ADR1(\vga/vgacore/vcnt [2]),
    .ADR2(\vga/vgacore/vcnt [0]),
    .ADR3(\vga/rom_addr_char [0]),
    .O(\vga/N26 )
  );
  defparam \vga/N214/XUSED .LOC = "CLB_R1C3.S0";
  X_BUF \vga/N214/XUSED  (
    .I(\vga/N214 ),
    .O(\vga/N214_0 )
  );
  defparam \vga/N214/YUSED .LOC = "CLB_R1C3.S0";
  X_BUF \vga/N214/YUSED  (
    .I(\vga/N26 ),
    .O(\vga/N26_0 )
  );
  defparam \vga/char_rom/Mrom_data96 .INIT = 16'h0992;
  defparam \vga/char_rom/Mrom_data96 .LOC = "CLB_R10C1.S1";
  X_LUT4 \vga/char_rom/Mrom_data96  (
    .ADR0(\vga/rom_addr_char_0_1_18 ),
    .ADR1(\vga/vgacore/vcnt_1_1_8 ),
    .ADR2(\vga/vgacore/vcnt_2_1_9 ),
    .ADR3(\vga/vgacore/vcnt_0_1_17 ),
    .O(\vga/N101 )
  );
  defparam \vga/char_rom/Mrom_data40 .INIT = 16'hDAD8;
  defparam \vga/char_rom/Mrom_data40 .LOC = "CLB_R10C1.S1";
  X_LUT4 \vga/char_rom/Mrom_data40  (
    .ADR0(\vga/vgacore/vcnt_1_1_8 ),
    .ADR1(\vga/rom_addr_char_0_1_18 ),
    .ADR2(\vga/vgacore/vcnt_2_1_9 ),
    .ADR3(\vga/vgacore/vcnt_0_1_17 ),
    .O(\vga/N43 )
  );
  defparam \vga/N101/XUSED .LOC = "CLB_R10C1.S1";
  X_BUF \vga/N101/XUSED  (
    .I(\vga/N101 ),
    .O(\vga/N101_0 )
  );
  defparam \vga/N101/YUSED .LOC = "CLB_R10C1.S1";
  X_BUF \vga/N101/YUSED  (
    .I(\vga/N43 ),
    .O(\vga/N43_0 )
  );
  defparam \vga/char_rom/Mrom_data94 .INIT = 16'h4EED;
  defparam \vga/char_rom/Mrom_data94 .LOC = "CLB_R11C2.S1";
  X_LUT4 \vga/char_rom/Mrom_data94  (
    .ADR0(\vga/vgacore/vcnt_1_1_8 ),
    .ADR1(\vga/rom_addr_char_0_1_18 ),
    .ADR2(\vga/vgacore/vcnt_2_1_9 ),
    .ADR3(\vga/vgacore/vcnt_0_1_17 ),
    .O(\vga/N99 )
  );
  defparam \vga/char_rom/Mrom_data32 .INIT = 16'h0675;
  defparam \vga/char_rom/Mrom_data32 .LOC = "CLB_R11C2.S1";
  X_LUT4 \vga/char_rom/Mrom_data32  (
    .ADR0(\vga/vgacore/vcnt_1_1_8 ),
    .ADR1(\vga/vgacore/vcnt_0_1_17 ),
    .ADR2(\vga/rom_addr_char_0_1_18 ),
    .ADR3(\vga/vgacore/vcnt_2_1_9 ),
    .O(\vga/N35 )
  );
  defparam \vga/N99/XUSED .LOC = "CLB_R11C2.S1";
  X_BUF \vga/N99/XUSED  (
    .I(\vga/N99 ),
    .O(\vga/N99_0 )
  );
  defparam \vga/N99/YUSED .LOC = "CLB_R11C2.S1";
  X_BUF \vga/N99/YUSED  (
    .I(\vga/N35 ),
    .O(\vga/N35_0 )
  );
  defparam \vga/char_rom/Mrom_data206 .INIT = 16'h1FD0;
  defparam \vga/char_rom/Mrom_data206 .LOC = "CLB_R6C3.S1";
  X_LUT4 \vga/char_rom/Mrom_data206  (
    .ADR0(\vga/rom_addr_char [0]),
    .ADR1(\vga/vgacore/vcnt [0]),
    .ADR2(\vga/vgacore/vcnt [1]),
    .ADR3(\vga/vgacore/vcnt [2]),
    .O(\vga/N213 )
  );
  defparam \vga/char_rom/Mrom_data24 .INIT = 16'h070F;
  defparam \vga/char_rom/Mrom_data24 .LOC = "CLB_R6C3.S1";
  X_LUT4 \vga/char_rom/Mrom_data24  (
    .ADR0(\vga/vgacore/vcnt [2]),
    .ADR1(\vga/vgacore/vcnt [0]),
    .ADR2(\vga/rom_addr_char [0]),
    .ADR3(\vga/vgacore/vcnt [1]),
    .O(\vga/N27 )
  );
  defparam \vga/N213/XUSED .LOC = "CLB_R6C3.S1";
  X_BUF \vga/N213/XUSED  (
    .I(\vga/N213 ),
    .O(\vga/N213_0 )
  );
  defparam \vga/N213/YUSED .LOC = "CLB_R6C3.S1";
  X_BUF \vga/N213/YUSED  (
    .I(\vga/N27 ),
    .O(\vga/N27_0 )
  );
  defparam \vga/char_rom/Mrom_data93 .INIT = 16'h1280;
  defparam \vga/char_rom/Mrom_data93 .LOC = "CLB_R8C2.S1";
  X_LUT4 \vga/char_rom/Mrom_data93  (
    .ADR0(\vga/vgacore/vcnt_0_1_17 ),
    .ADR1(\vga/rom_addr_char_0_1_18 ),
    .ADR2(\vga/vgacore/vcnt_1_1_8 ),
    .ADR3(\vga/vgacore/vcnt_2_1_9 ),
    .O(\vga/N98 )
  );
  defparam \vga/char_rom/Mrom_data41 .INIT = 16'h0480;
  defparam \vga/char_rom/Mrom_data41 .LOC = "CLB_R8C2.S1";
  X_LUT4 \vga/char_rom/Mrom_data41  (
    .ADR0(\vga/vgacore/vcnt_2_1_9 ),
    .ADR1(\vga/vgacore/vcnt_0_1_17 ),
    .ADR2(\vga/rom_addr_char_0_1_18 ),
    .ADR3(\vga/vgacore/vcnt_1_1_8 ),
    .O(\vga/N44 )
  );
  defparam \vga/N98/XUSED .LOC = "CLB_R8C2.S1";
  X_BUF \vga/N98/XUSED  (
    .I(\vga/N98 ),
    .O(\vga/N98_0 )
  );
  defparam \vga/N98/YUSED .LOC = "CLB_R8C2.S1";
  X_BUF \vga/N98/YUSED  (
    .I(\vga/N44 ),
    .O(\vga/N44_0 )
  );
  defparam \vga/char_rom/Mrom_data201 .INIT = 16'h5B3B;
  defparam \vga/char_rom/Mrom_data201 .LOC = "CLB_R2C3.S1";
  X_LUT4 \vga/char_rom/Mrom_data201  (
    .ADR0(\vga/vgacore/vcnt [2]),
    .ADR1(\vga/rom_addr_char [0]),
    .ADR2(\vga/vgacore/vcnt [1]),
    .ADR3(\vga/vgacore/vcnt [0]),
    .O(\vga/N208 )
  );
  defparam \vga/char_rom/Mrom_data25 .INIT = 16'h1597;
  defparam \vga/char_rom/Mrom_data25 .LOC = "CLB_R2C3.S1";
  X_LUT4 \vga/char_rom/Mrom_data25  (
    .ADR0(\vga/rom_addr_char [0]),
    .ADR1(\vga/vgacore/vcnt_2_1_9 ),
    .ADR2(\vga/vgacore/vcnt [1]),
    .ADR3(\vga/vgacore/vcnt [0]),
    .O(\vga/N28 )
  );
  defparam \vga/N208/XUSED .LOC = "CLB_R2C3.S1";
  X_BUF \vga/N208/XUSED  (
    .I(\vga/N208 ),
    .O(\vga/N208_0 )
  );
  defparam \vga/N208/YUSED .LOC = "CLB_R2C3.S1";
  X_BUF \vga/N208/YUSED  (
    .I(\vga/N28 ),
    .O(\vga/N28_0 )
  );
  defparam \vga/char_rom/Mrom_data198 .INIT = 16'h0071;
  defparam \vga/char_rom/Mrom_data198 .LOC = "CLB_R4C2.S0";
  X_LUT4 \vga/char_rom/Mrom_data198  (
    .ADR0(\vga/vgacore/vcnt [1]),
    .ADR1(\vga/vgacore/vcnt [0]),
    .ADR2(\vga/vgacore/vcnt [2]),
    .ADR3(\vga/rom_addr_char [0]),
    .O(\vga/N205 )
  );
  defparam \vga/char_rom/Mrom_data17 .INIT = 16'h07BC;
  defparam \vga/char_rom/Mrom_data17 .LOC = "CLB_R4C2.S0";
  X_LUT4 \vga/char_rom/Mrom_data17  (
    .ADR0(\vga/rom_addr_char [0]),
    .ADR1(\vga/vgacore/vcnt [0]),
    .ADR2(\vga/vgacore/vcnt [1]),
    .ADR3(\vga/vgacore/vcnt [2]),
    .O(\vga/N20 )
  );
  defparam \vga/N205/XUSED .LOC = "CLB_R4C2.S0";
  X_BUF \vga/N205/XUSED  (
    .I(\vga/N205 ),
    .O(\vga/N205_0 )
  );
  defparam \vga/N205/YUSED .LOC = "CLB_R4C2.S0";
  X_BUF \vga/N205/YUSED  (
    .I(\vga/N20 ),
    .O(\vga/N20_0 )
  );
  defparam \vga/char_rom/Mrom_data91 .INIT = 16'h46C9;
  defparam \vga/char_rom/Mrom_data91 .LOC = "CLB_R11C7.S0";
  X_LUT4 \vga/char_rom/Mrom_data91  (
    .ADR0(\vga/vgacore/vcnt_1_1_8 ),
    .ADR1(\vga/rom_addr_char_0_1_18 ),
    .ADR2(\vga/vgacore/vcnt_0_1_17 ),
    .ADR3(\vga/vgacore/vcnt_2_1_9 ),
    .O(\vga/N96 )
  );
  defparam \vga/char_rom/Mrom_data50 .INIT = 16'h0B01;
  defparam \vga/char_rom/Mrom_data50 .LOC = "CLB_R11C7.S0";
  X_LUT4 \vga/char_rom/Mrom_data50  (
    .ADR0(\vga/vgacore/vcnt_2_1_9 ),
    .ADR1(\vga/rom_addr_char_0_1_18 ),
    .ADR2(\vga/vgacore/vcnt_0_1_17 ),
    .ADR3(\vga/vgacore/vcnt_1_1_8 ),
    .O(\vga/N54 )
  );
  defparam \vga/N96/XUSED .LOC = "CLB_R11C7.S0";
  X_BUF \vga/N96/XUSED  (
    .I(\vga/N96 ),
    .O(\vga/N96_0 )
  );
  defparam \vga/N96/YUSED .LOC = "CLB_R11C7.S0";
  X_BUF \vga/N96/YUSED  (
    .I(\vga/N54 ),
    .O(\vga/N54_0 )
  );
  defparam \vga/char_rom/Mrom_data90 .INIT = 16'h0345;
  defparam \vga/char_rom/Mrom_data90 .LOC = "CLB_R7C1.S0";
  X_LUT4 \vga/char_rom/Mrom_data90  (
    .ADR0(\vga/vgacore/vcnt_0_1_17 ),
    .ADR1(\vga/vgacore/vcnt_1_1_8 ),
    .ADR2(\vga/vgacore/vcnt_2_1_9 ),
    .ADR3(\vga/rom_addr_char_0_1_18 ),
    .O(\vga/N95 )
  );
  defparam \vga/char_rom/Mrom_data42 .INIT = 16'h31CC;
  defparam \vga/char_rom/Mrom_data42 .LOC = "CLB_R7C1.S0";
  X_LUT4 \vga/char_rom/Mrom_data42  (
    .ADR0(\vga/vgacore/vcnt_0_1_17 ),
    .ADR1(\vga/vgacore/vcnt_1_1_8 ),
    .ADR2(\vga/rom_addr_char_0_1_18 ),
    .ADR3(\vga/vgacore/vcnt_2_1_9 ),
    .O(\vga/N45 )
  );
  defparam \vga/N95/XUSED .LOC = "CLB_R7C1.S0";
  X_BUF \vga/N95/XUSED  (
    .I(\vga/N95 ),
    .O(\vga/N95_0 )
  );
  defparam \vga/N95/YUSED .LOC = "CLB_R7C1.S0";
  X_BUF \vga/N95/YUSED  (
    .I(\vga/N45 ),
    .O(\vga/N45_0 )
  );
  defparam \vga/char_rom/Mrom_data89 .INIT = 16'h1B3B;
  defparam \vga/char_rom/Mrom_data89 .LOC = "CLB_R9C1.S1";
  X_LUT4 \vga/char_rom/Mrom_data89  (
    .ADR0(\vga/vgacore/vcnt_0_1_17 ),
    .ADR1(\vga/rom_addr_char_0_1_18 ),
    .ADR2(\vga/vgacore/vcnt_2_1_9 ),
    .ADR3(\vga/vgacore/vcnt_1_1_8 ),
    .O(\vga/N94 )
  );
  defparam \vga/char_rom/Mrom_data34 .INIT = 16'h8010;
  defparam \vga/char_rom/Mrom_data34 .LOC = "CLB_R9C1.S1";
  X_LUT4 \vga/char_rom/Mrom_data34  (
    .ADR0(\vga/vgacore/vcnt_0_1_17 ),
    .ADR1(\vga/vgacore/vcnt_2_1_9 ),
    .ADR2(\vga/vgacore/vcnt_1_1_8 ),
    .ADR3(\vga/rom_addr_char_0_1_18 ),
    .O(\vga/N37 )
  );
  defparam \vga/N94/XUSED .LOC = "CLB_R9C1.S1";
  X_BUF \vga/N94/XUSED  (
    .I(\vga/N94 ),
    .O(\vga/N94_0 )
  );
  defparam \vga/N94/YUSED .LOC = "CLB_R9C1.S1";
  X_BUF \vga/N94/YUSED  (
    .I(\vga/N37 ),
    .O(\vga/N37_0 )
  );
  defparam \vga/char_rom/Mrom_data28 .INIT = 16'h3E12;
  defparam \vga/char_rom/Mrom_data28 .LOC = "CLB_R5C2.S0";
  X_LUT4 \vga/char_rom/Mrom_data28  (
    .ADR0(\vga/vgacore/vcnt [1]),
    .ADR1(\vga/vgacore/vcnt_2_1_9 ),
    .ADR2(\vga/vgacore/vcnt_0_1_17 ),
    .ADR3(\vga/rom_addr_char_0_1_18 ),
    .O(\vga/N31 )
  );
  defparam \vga/char_rom/Mrom_data26 .INIT = 16'h7F08;
  defparam \vga/char_rom/Mrom_data26 .LOC = "CLB_R5C2.S0";
  X_LUT4 \vga/char_rom/Mrom_data26  (
    .ADR0(\vga/vgacore/vcnt [1]),
    .ADR1(\vga/vgacore/vcnt_2_1_9 ),
    .ADR2(\vga/vgacore/vcnt [0]),
    .ADR3(\vga/rom_addr_char_0_1_18 ),
    .O(\vga/N29 )
  );
  defparam \vga/N31/XUSED .LOC = "CLB_R5C2.S0";
  X_BUF \vga/N31/XUSED  (
    .I(\vga/N31 ),
    .O(\vga/N31_0 )
  );
  defparam \vga/N31/YUSED .LOC = "CLB_R5C2.S0";
  X_BUF \vga/N31/YUSED  (
    .I(\vga/N29 ),
    .O(\vga/N29_0 )
  );
  defparam \vga/char_rom/Mrom_data194 .INIT = 16'h17F3;
  defparam \vga/char_rom/Mrom_data194 .LOC = "CLB_R4C2.S1";
  X_LUT4 \vga/char_rom/Mrom_data194  (
    .ADR0(\vga/vgacore/vcnt [2]),
    .ADR1(\vga/rom_addr_char [0]),
    .ADR2(\vga/vgacore/vcnt [0]),
    .ADR3(\vga/vgacore/vcnt [1]),
    .O(\vga/N201 )
  );
  defparam \vga/char_rom/Mrom_data18 .INIT = 16'h1080;
  defparam \vga/char_rom/Mrom_data18 .LOC = "CLB_R4C2.S1";
  X_LUT4 \vga/char_rom/Mrom_data18  (
    .ADR0(\vga/vgacore/vcnt [0]),
    .ADR1(\vga/vgacore/vcnt [2]),
    .ADR2(\vga/rom_addr_char [0]),
    .ADR3(\vga/vgacore/vcnt [1]),
    .O(\vga/N21 )
  );
  defparam \vga/N201/XUSED .LOC = "CLB_R4C2.S1";
  X_BUF \vga/N201/XUSED  (
    .I(\vga/N201 ),
    .O(\vga/N201_0 )
  );
  defparam \vga/N201/YUSED .LOC = "CLB_R4C2.S1";
  X_BUF \vga/N201/YUSED  (
    .I(\vga/N21 ),
    .O(\vga/N21_0 )
  );
  defparam \vga/pixel<8>27 .INIT = 16'h00A0;
  defparam \vga/pixel<8>27 .LOC = "CLB_R15C8.S0";
  X_LUT4 \vga/pixel<8>27  (
    .ADR0(\vga/pixelData [0]),
    .ADR1(VCC),
    .ADR2(\vga/pixel<8>_map785_0 ),
    .ADR3(\vga/vgacore/hblank_21 ),
    .O(pixel[8])
  );
  defparam \pixel<8>/YUSED .LOC = "CLB_R15C8.S0";
  X_BUF \pixel<8>/YUSED  (
    .I(pixel[8]),
    .O(\pixel<8>_0 )
  );
  defparam \vga/rom_addr_char<1>114_SW0 .INIT = 16'hE788;
  defparam \vga/rom_addr_char<1>114_SW0 .LOC = "CLB_R10C1.S0";
  X_LUT4 \vga/rom_addr_char<1>114_SW0  (
    .ADR0(\vga/vgacore/vcnt_0_1_17 ),
    .ADR1(\vga/vgacore/vcnt_2_1_9 ),
    .ADR2(\vga/vgacore/vcnt_1_1_8 ),
    .ADR3(\vga/rom_addr_char [1]),
    .O(N3166)
  );
  defparam \vga/char_rom/Mrom_data51 .INIT = 16'h30C3;
  defparam \vga/char_rom/Mrom_data51 .LOC = "CLB_R10C1.S0";
  X_LUT4 \vga/char_rom/Mrom_data51  (
    .ADR0(VCC),
    .ADR1(\vga/vgacore/vcnt_0_1_17 ),
    .ADR2(\vga/vgacore/vcnt_1_1_8 ),
    .ADR3(\vga/vgacore/vcnt_2_1_9 ),
    .O(\vga/N55 )
  );
  defparam \N3166/XUSED .LOC = "CLB_R10C1.S0";
  X_BUF \N3166/XUSED  (
    .I(N3166),
    .O(N3166_0)
  );
  defparam \N3166/YUSED .LOC = "CLB_R10C1.S0";
  X_BUF \N3166/YUSED  (
    .I(\vga/N55 ),
    .O(\vga/N55_0 )
  );
  defparam \vga/char_rom/Mrom_data86 .INIT = 16'h0001;
  defparam \vga/char_rom/Mrom_data86 .LOC = "CLB_R21C6.S0";
  X_LUT4 \vga/char_rom/Mrom_data86  (
    .ADR0(\vga/vgacore/vcnt_1_1_8 ),
    .ADR1(\vga/vgacore/vcnt_2_1_9 ),
    .ADR2(\vga/rom_addr_char_0_1_18 ),
    .ADR3(\vga/vgacore/vcnt_0_1_17 ),
    .O(\vga/N90 )
  );
  defparam \vga/char_rom/Mrom_data43 .INIT = 16'h1020;
  defparam \vga/char_rom/Mrom_data43 .LOC = "CLB_R21C6.S0";
  X_LUT4 \vga/char_rom/Mrom_data43  (
    .ADR0(\vga/vgacore/vcnt_0_1_17 ),
    .ADR1(\vga/vgacore/vcnt_2_1_9 ),
    .ADR2(\vga/rom_addr_char_0_1_18 ),
    .ADR3(\vga/vgacore/vcnt_1_1_8 ),
    .O(\vga/N47 )
  );
  defparam \vga/N90/XUSED .LOC = "CLB_R21C6.S0";
  X_BUF \vga/N90/XUSED  (
    .I(\vga/N90 ),
    .O(\vga/N90_0 )
  );
  defparam \vga/N90/YUSED .LOC = "CLB_R21C6.S0";
  X_BUF \vga/N90/YUSED  (
    .I(\vga/N47 ),
    .O(\vga/N47_0 )
  );
  defparam \vga/char_rom/Mrom_data85 .INIT = 16'h0AA8;
  defparam \vga/char_rom/Mrom_data85 .LOC = "CLB_R21C5.S0";
  X_LUT4 \vga/char_rom/Mrom_data85  (
    .ADR0(\vga/rom_addr_char_0_1_18 ),
    .ADR1(\vga/vgacore/vcnt_0_1_17 ),
    .ADR2(\vga/vgacore/vcnt_1_1_8 ),
    .ADR3(\vga/vgacore/vcnt_2_1_9 ),
    .O(\vga/N89 )
  );
  defparam \vga/char_rom/Mrom_data35 .INIT = 16'h60A0;
  defparam \vga/char_rom/Mrom_data35 .LOC = "CLB_R21C5.S0";
  X_LUT4 \vga/char_rom/Mrom_data35  (
    .ADR0(\vga/vgacore/vcnt_2_1_9 ),
    .ADR1(\vga/vgacore/vcnt_0_1_17 ),
    .ADR2(\vga/rom_addr_char_0_1_18 ),
    .ADR3(\vga/vgacore/vcnt_1_1_8 ),
    .O(\vga/N38 )
  );
  defparam \vga/N89/XUSED .LOC = "CLB_R21C5.S0";
  X_BUF \vga/N89/XUSED  (
    .I(\vga/N89 ),
    .O(\vga/N89_0 )
  );
  defparam \vga/N89/YUSED .LOC = "CLB_R21C5.S0";
  X_BUF \vga/N89/YUSED  (
    .I(\vga/N38 ),
    .O(\vga/N38_0 )
  );
  defparam \vga/rom_addr_char<1>6_SW0 .INIT = 16'h9873;
  defparam \vga/rom_addr_char<1>6_SW0 .LOC = "CLB_R2C3.S0";
  X_LUT4 \vga/rom_addr_char<1>6_SW0  (
    .ADR0(\vga/rom_addr_char_1_1_7 ),
    .ADR1(\vga/vgacore/vcnt_2_1_9 ),
    .ADR2(\vga/vgacore/vcnt_0_1_17 ),
    .ADR3(\vga/rom_addr_char_0_1_18 ),
    .O(N3146)
  );
  defparam \vga/char_rom/Mrom_data27 .INIT = 16'h57FB;
  defparam \vga/char_rom/Mrom_data27 .LOC = "CLB_R2C3.S0";
  X_LUT4 \vga/char_rom/Mrom_data27  (
    .ADR0(\vga/vgacore/vcnt [1]),
    .ADR1(\vga/rom_addr_char_0_1_18 ),
    .ADR2(\vga/vgacore/vcnt_0_1_17 ),
    .ADR3(\vga/vgacore/vcnt_2_1_9 ),
    .O(\vga/N30 )
  );
  defparam \N3146/XUSED .LOC = "CLB_R2C3.S0";
  X_BUF \N3146/XUSED  (
    .I(N3146),
    .O(N3146_0)
  );
  defparam \N3146/YUSED .LOC = "CLB_R2C3.S0";
  X_BUF \N3146/YUSED  (
    .I(\vga/N30 ),
    .O(\vga/N30_0 )
  );
  defparam \vga/char_rom/Mrom_data187 .INIT = 16'h4220;
  defparam \vga/char_rom/Mrom_data187 .LOC = "CLB_R8C3.S0";
  X_LUT4 \vga/char_rom/Mrom_data187  (
    .ADR0(\vga/vgacore/vcnt [1]),
    .ADR1(\vga/vgacore/vcnt [2]),
    .ADR2(\vga/rom_addr_char [0]),
    .ADR3(\vga/vgacore/vcnt [0]),
    .O(\vga/N194 )
  );
  defparam \vga/char_rom/Mrom_data19 .INIT = 16'h0068;
  defparam \vga/char_rom/Mrom_data19 .LOC = "CLB_R8C3.S0";
  X_LUT4 \vga/char_rom/Mrom_data19  (
    .ADR0(\vga/vgacore/vcnt [0]),
    .ADR1(\vga/rom_addr_char [0]),
    .ADR2(\vga/vgacore/vcnt [1]),
    .ADR3(\vga/vgacore/vcnt [2]),
    .O(\vga/N22 )
  );
  defparam \vga/N194/XUSED .LOC = "CLB_R8C3.S0";
  X_BUF \vga/N194/XUSED  (
    .I(\vga/N194 ),
    .O(\vga/N194_0 )
  );
  defparam \vga/N194/YUSED .LOC = "CLB_R8C3.S0";
  X_BUF \vga/N194/YUSED  (
    .I(\vga/N22 ),
    .O(\vga/N22_0 )
  );
  defparam \vga/char_rom/Mrom_data84 .INIT = 16'h1D02;
  defparam \vga/char_rom/Mrom_data84 .LOC = "CLB_R25C18.S0";
  X_LUT4 \vga/char_rom/Mrom_data84  (
    .ADR0(\vga/rom_addr_char_0_1_18 ),
    .ADR1(\vga/vgacore/vcnt_2_1_9 ),
    .ADR2(\vga/vgacore/vcnt_0_1_17 ),
    .ADR3(\vga/vgacore/vcnt_1_1_8 ),
    .O(\vga/N88 )
  );
  defparam \vga/char_rom/Mrom_data60 .INIT = 16'h6211;
  defparam \vga/char_rom/Mrom_data60 .LOC = "CLB_R25C18.S0";
  X_LUT4 \vga/char_rom/Mrom_data60  (
    .ADR0(\vga/vgacore/vcnt_0_1_17 ),
    .ADR1(\vga/vgacore/vcnt_2_1_9 ),
    .ADR2(\vga/rom_addr_char_0_1_18 ),
    .ADR3(\vga/vgacore/vcnt_1_1_8 ),
    .O(\vga/N64 )
  );
  defparam \vga/N88/XUSED .LOC = "CLB_R25C18.S0";
  X_BUF \vga/N88/XUSED  (
    .I(\vga/N88 ),
    .O(\vga/N88_0 )
  );
  defparam \vga/N88/YUSED .LOC = "CLB_R25C18.S0";
  X_BUF \vga/N88/YUSED  (
    .I(\vga/N64 ),
    .O(\vga/N64_0 )
  );
  defparam \vga/char_rom/Mrom_data83 .INIT = 16'h36CC;
  defparam \vga/char_rom/Mrom_data83 .LOC = "CLB_R23C11.S0";
  X_LUT4 \vga/char_rom/Mrom_data83  (
    .ADR0(\vga/vgacore/vcnt_0_1_17 ),
    .ADR1(\vga/vgacore/vcnt_1_1_8 ),
    .ADR2(\vga/rom_addr_char_0_1_18 ),
    .ADR3(\vga/vgacore/vcnt_2_1_9 ),
    .O(\vga/N87 )
  );
  defparam \vga/char_rom/Mrom_data52 .INIT = 16'h497F;
  defparam \vga/char_rom/Mrom_data52 .LOC = "CLB_R23C11.S0";
  X_LUT4 \vga/char_rom/Mrom_data52  (
    .ADR0(\vga/vgacore/vcnt_2_1_9 ),
    .ADR1(\vga/vgacore/vcnt_1_1_8 ),
    .ADR2(\vga/vgacore/vcnt_0_1_17 ),
    .ADR3(\vga/rom_addr_char_0_1_18 ),
    .O(\vga/N56 )
  );
  defparam \vga/N87/XUSED .LOC = "CLB_R23C11.S0";
  X_BUF \vga/N87/XUSED  (
    .I(\vga/N87 ),
    .O(\vga/N87_0 )
  );
  defparam \vga/N87/YUSED .LOC = "CLB_R23C11.S0";
  X_BUF \vga/N87/YUSED  (
    .I(\vga/N56 ),
    .O(\vga/N56_0 )
  );
  defparam \vga/char_rom/Mrom_data82 .INIT = 16'h6020;
  defparam \vga/char_rom/Mrom_data82 .LOC = "CLB_R24C8.S1";
  X_LUT4 \vga/char_rom/Mrom_data82  (
    .ADR0(\vga/vgacore/vcnt_0_1_17 ),
    .ADR1(\vga/vgacore/vcnt_1_1_8 ),
    .ADR2(\vga/vgacore/vcnt_2_1_9 ),
    .ADR3(\vga/rom_addr_char_0_1_18 ),
    .O(\vga/N86 )
  );
  defparam \vga/char_rom/Mrom_data44 .INIT = 16'h7E13;
  defparam \vga/char_rom/Mrom_data44 .LOC = "CLB_R24C8.S1";
  X_LUT4 \vga/char_rom/Mrom_data44  (
    .ADR0(\vga/vgacore/vcnt_0_1_17 ),
    .ADR1(\vga/vgacore/vcnt_2_1_9 ),
    .ADR2(\vga/vgacore/vcnt_1_1_8 ),
    .ADR3(\vga/rom_addr_char_0_1_18 ),
    .O(\vga/N48 )
  );
  defparam \vga/N86/XUSED .LOC = "CLB_R24C8.S1";
  X_BUF \vga/N86/XUSED  (
    .I(\vga/N86 ),
    .O(\vga/N86_0 )
  );
  defparam \vga/N86/YUSED .LOC = "CLB_R24C8.S1";
  X_BUF \vga/N86/YUSED  (
    .I(\vga/N48 ),
    .O(\vga/N48_0 )
  );
  defparam \vga/char_rom/Mrom_data81 .INIT = 16'h7A42;
  defparam \vga/char_rom/Mrom_data81 .LOC = "CLB_R21C6.S1";
  X_LUT4 \vga/char_rom/Mrom_data81  (
    .ADR0(\vga/vgacore/vcnt_1_1_8 ),
    .ADR1(\vga/vgacore/vcnt_0_1_17 ),
    .ADR2(\vga/vgacore/vcnt_2_1_9 ),
    .ADR3(\vga/rom_addr_char_0_1_18 ),
    .O(\vga/N85 )
  );
  defparam \vga/char_rom/Mrom_data36 .INIT = 16'h4588;
  defparam \vga/char_rom/Mrom_data36 .LOC = "CLB_R21C6.S1";
  X_LUT4 \vga/char_rom/Mrom_data36  (
    .ADR0(\vga/vgacore/vcnt_1_1_8 ),
    .ADR1(\vga/vgacore/vcnt_0_1_17 ),
    .ADR2(\vga/rom_addr_char_0_1_18 ),
    .ADR3(\vga/vgacore/vcnt_2_1_9 ),
    .O(\vga/N39 )
  );
  defparam \vga/N85/XUSED .LOC = "CLB_R21C6.S1";
  X_BUF \vga/N85/XUSED  (
    .I(\vga/N85 ),
    .O(\vga/N85_0 )
  );
  defparam \vga/N85/YUSED .LOC = "CLB_R21C6.S1";
  X_BUF \vga/N85/YUSED  (
    .I(\vga/N39 ),
    .O(\vga/N39_0 )
  );
  defparam \vga/char_rom/Mrom_data79 .INIT = 16'h560C;
  defparam \vga/char_rom/Mrom_data79 .LOC = "CLB_R26C18.S0";
  X_LUT4 \vga/char_rom/Mrom_data79  (
    .ADR0(\vga/vgacore/vcnt_0_1_17 ),
    .ADR1(\vga/vgacore/vcnt_2_1_9 ),
    .ADR2(\vga/rom_addr_char_0_1_18 ),
    .ADR3(\vga/vgacore/vcnt_1_1_8 ),
    .O(\vga/N83 )
  );
  defparam \vga/char_rom/Mrom_data61 .INIT = 16'h0940;
  defparam \vga/char_rom/Mrom_data61 .LOC = "CLB_R26C18.S0";
  X_LUT4 \vga/char_rom/Mrom_data61  (
    .ADR0(\vga/vgacore/vcnt_2_1_9 ),
    .ADR1(\vga/vgacore/vcnt_1_1_8 ),
    .ADR2(\vga/vgacore/vcnt_0_1_17 ),
    .ADR3(\vga/rom_addr_char_0_1_18 ),
    .O(\vga/N65 )
  );
  defparam \vga/N83/XUSED .LOC = "CLB_R26C18.S0";
  X_BUF \vga/N83/XUSED  (
    .I(\vga/N83 ),
    .O(\vga/N83_0 )
  );
  defparam \vga/N83/YUSED .LOC = "CLB_R26C18.S0";
  X_BUF \vga/N83/YUSED  (
    .I(\vga/N65 ),
    .O(\vga/N65_0 )
  );
  defparam \vga/char_rom/Mrom_data78 .INIT = 16'h1040;
  defparam \vga/char_rom/Mrom_data78 .LOC = "CLB_R26C11.S0";
  X_LUT4 \vga/char_rom/Mrom_data78  (
    .ADR0(\vga/vgacore/vcnt_0_1_17 ),
    .ADR1(\vga/vgacore/vcnt_2_1_9 ),
    .ADR2(\vga/vgacore/vcnt_1_1_8 ),
    .ADR3(\vga/rom_addr_char_0_1_18 ),
    .O(\vga/N82 )
  );
  defparam \vga/char_rom/Mrom_data53 .INIT = 16'h1161;
  defparam \vga/char_rom/Mrom_data53 .LOC = "CLB_R26C11.S0";
  X_LUT4 \vga/char_rom/Mrom_data53  (
    .ADR0(\vga/vgacore/vcnt_0_1_17 ),
    .ADR1(\vga/vgacore/vcnt_2_1_9 ),
    .ADR2(\vga/vgacore/vcnt_1_1_8 ),
    .ADR3(\vga/rom_addr_char_0_1_18 ),
    .O(\vga/N57 )
  );
  defparam \vga/N82/XUSED .LOC = "CLB_R26C11.S0";
  X_BUF \vga/N82/XUSED  (
    .I(\vga/N82 ),
    .O(\vga/N82_0 )
  );
  defparam \vga/N82/YUSED .LOC = "CLB_R26C11.S0";
  X_BUF \vga/N82/YUSED  (
    .I(\vga/N57 ),
    .O(\vga/N57_0 )
  );
  defparam \vga/char_rom/Mrom_data77 .INIT = 16'h447D;
  defparam \vga/char_rom/Mrom_data77 .LOC = "CLB_R26C7.S1";
  X_LUT4 \vga/char_rom/Mrom_data77  (
    .ADR0(\vga/vgacore/vcnt_0_1_17 ),
    .ADR1(\vga/vgacore/vcnt_1_1_8 ),
    .ADR2(\vga/vgacore/vcnt_2_1_9 ),
    .ADR3(\vga/rom_addr_char_0_1_18 ),
    .O(\vga/N81 )
  );
  defparam \vga/char_rom/Mrom_data45 .INIT = 16'h3058;
  defparam \vga/char_rom/Mrom_data45 .LOC = "CLB_R26C7.S1";
  X_LUT4 \vga/char_rom/Mrom_data45  (
    .ADR0(\vga/rom_addr_char_0_1_18 ),
    .ADR1(\vga/vgacore/vcnt_1_1_8 ),
    .ADR2(\vga/vgacore/vcnt_0_1_17 ),
    .ADR3(\vga/vgacore/vcnt_2_1_9 ),
    .O(\vga/N49 )
  );
  defparam \vga/N81/XUSED .LOC = "CLB_R26C7.S1";
  X_BUF \vga/N81/XUSED  (
    .I(\vga/N81 ),
    .O(\vga/N81_0 )
  );
  defparam \vga/N81/YUSED .LOC = "CLB_R26C7.S1";
  X_BUF \vga/N81/YUSED  (
    .I(\vga/N49 ),
    .O(\vga/N49_0 )
  );
  defparam \vga/char_rom/Mrom_data76 .INIT = 16'h14D0;
  defparam \vga/char_rom/Mrom_data76 .LOC = "CLB_R26C6.S1";
  X_LUT4 \vga/char_rom/Mrom_data76  (
    .ADR0(\vga/rom_addr_char_0_1_18 ),
    .ADR1(\vga/vgacore/vcnt_1_1_8 ),
    .ADR2(\vga/vgacore/vcnt_2_1_9 ),
    .ADR3(\vga/vgacore/vcnt_0_1_17 ),
    .O(\vga/N80 )
  );
  defparam \vga/char_rom/Mrom_data37 .INIT = 16'h1B33;
  defparam \vga/char_rom/Mrom_data37 .LOC = "CLB_R26C6.S1";
  X_LUT4 \vga/char_rom/Mrom_data37  (
    .ADR0(\vga/vgacore/vcnt_1_1_8 ),
    .ADR1(\vga/rom_addr_char_0_1_18 ),
    .ADR2(\vga/vgacore/vcnt_2_1_9 ),
    .ADR3(\vga/vgacore/vcnt_0_1_17 ),
    .O(\vga/N40 )
  );
  defparam \vga/N80/XUSED .LOC = "CLB_R26C6.S1";
  X_BUF \vga/N80/XUSED  (
    .I(\vga/N80 ),
    .O(\vga/N80_0 )
  );
  defparam \vga/N80/YUSED .LOC = "CLB_R26C6.S1";
  X_BUF \vga/N80/YUSED  (
    .I(\vga/N40 ),
    .O(\vga/N40_0 )
  );
  defparam \vga/char_rom/Mrom_data75 .INIT = 16'h9481;
  defparam \vga/char_rom/Mrom_data75 .LOC = "CLB_R21C2.S0";
  X_LUT4 \vga/char_rom/Mrom_data75  (
    .ADR0(\vga/vgacore/vcnt_2_1_9 ),
    .ADR1(\vga/rom_addr_char_0_1_18 ),
    .ADR2(\vga/vgacore/vcnt_0_1_17 ),
    .ADR3(\vga/vgacore/vcnt_1_1_8 ),
    .O(\vga/N79 )
  );
  defparam \vga/char_rom/Mrom_data29 .INIT = 16'h0F58;
  defparam \vga/char_rom/Mrom_data29 .LOC = "CLB_R21C2.S0";
  X_LUT4 \vga/char_rom/Mrom_data29  (
    .ADR0(\vga/rom_addr_char_0_1_18 ),
    .ADR1(\vga/vgacore/vcnt_2_1_9 ),
    .ADR2(\vga/vgacore/vcnt_1_1_8 ),
    .ADR3(\vga/vgacore/vcnt_0_1_17 ),
    .O(\vga/N32 )
  );
  defparam \vga/N79/XUSED .LOC = "CLB_R21C2.S0";
  X_BUF \vga/N79/XUSED  (
    .I(\vga/N79 ),
    .O(\vga/N79_0 )
  );
  defparam \vga/N79/YUSED .LOC = "CLB_R21C2.S0";
  X_BUF \vga/N79/YUSED  (
    .I(\vga/N32 ),
    .O(\vga/N32_0 )
  );
  defparam \vga/rom_addr_char<2>15_SW0 .INIT = 16'hE50F;
  defparam \vga/rom_addr_char<2>15_SW0 .LOC = "CLB_R14C2.S1";
  X_LUT4 \vga/rom_addr_char<2>15_SW0  (
    .ADR0(\vga/vgacore/vcnt_0_1_17 ),
    .ADR1(\vga/rom_addr_char_1_1_7 ),
    .ADR2(\vga/vgacore/vcnt_2_1_9 ),
    .ADR3(\vga/vgacore/vcnt_1_1_8 ),
    .O(N3162_pack_1)
  );
  defparam \vga/rom_addr_char<2>15 .INIT = 16'h00C0;
  defparam \vga/rom_addr_char<2>15 .LOC = "CLB_R14C2.S1";
  X_LUT4 \vga/rom_addr_char<2>15  (
    .ADR0(VCC),
    .ADR1(\vga/rom_addr_char_0_1_18 ),
    .ADR2(\vga/rom_addr_char [2]),
    .ADR3(N3162),
    .O(\vga/rom_addr_char<2>2 )
  );
  defparam \N3162/XUSED .LOC = "CLB_R14C2.S1";
  X_BUF \N3162/XUSED  (
    .I(N3162_pack_1),
    .O(N3162)
  );
  defparam \N3162/YUSED .LOC = "CLB_R14C2.S1";
  X_BUF \N3162/YUSED  (
    .I(\vga/rom_addr_char<2>2 ),
    .O(\vga/rom_addr_char<2>2_0 )
  );
  defparam \vga/char_rom/Mrom_data74 .INIT = 16'h00EC;
  defparam \vga/char_rom/Mrom_data74 .LOC = "CLB_R27C8.S0";
  X_LUT4 \vga/char_rom/Mrom_data74  (
    .ADR0(\vga/vgacore/vcnt_2_1_9 ),
    .ADR1(\vga/vgacore/vcnt_1_1_8 ),
    .ADR2(\vga/rom_addr_char_0_1_18 ),
    .ADR3(\vga/vgacore/vcnt_0_1_17 ),
    .O(\vga/N78 )
  );
  defparam \vga/char_rom/Mrom_data70 .INIT = 16'h4CCE;
  defparam \vga/char_rom/Mrom_data70 .LOC = "CLB_R27C8.S0";
  X_LUT4 \vga/char_rom/Mrom_data70  (
    .ADR0(\vga/vgacore/vcnt_2_1_9 ),
    .ADR1(\vga/rom_addr_char_0_1_18 ),
    .ADR2(\vga/vgacore/vcnt_0_1_17 ),
    .ADR3(\vga/vgacore/vcnt_1_1_8 ),
    .O(\vga/N74 )
  );
  defparam \vga/N78/XUSED .LOC = "CLB_R27C8.S0";
  X_BUF \vga/N78/XUSED  (
    .I(\vga/N78 ),
    .O(\vga/N78_0 )
  );
  defparam \vga/N78/YUSED .LOC = "CLB_R27C8.S0";
  X_BUF \vga/N78/YUSED  (
    .I(\vga/N74 ),
    .O(\vga/N74_0 )
  );
  defparam \vga/char_rom/Mrom_data71 .INIT = 16'h8002;
  defparam \vga/char_rom/Mrom_data71 .LOC = "CLB_R27C18.S1";
  X_LUT4 \vga/char_rom/Mrom_data71  (
    .ADR0(\vga/vgacore/vcnt_0_1_17 ),
    .ADR1(\vga/rom_addr_char_0_1_18 ),
    .ADR2(\vga/vgacore/vcnt_2_1_9 ),
    .ADR3(\vga/vgacore/vcnt_1_1_8 ),
    .O(\vga/N75 )
  );
  defparam \vga/char_rom/Mrom_data62 .INIT = 16'h1088;
  defparam \vga/char_rom/Mrom_data62 .LOC = "CLB_R27C18.S1";
  X_LUT4 \vga/char_rom/Mrom_data62  (
    .ADR0(\vga/vgacore/vcnt_0_1_17 ),
    .ADR1(\vga/rom_addr_char_0_1_18 ),
    .ADR2(\vga/vgacore/vcnt_2_1_9 ),
    .ADR3(\vga/vgacore/vcnt_1_1_8 ),
    .O(\vga/N66 )
  );
  defparam \vga/N75/XUSED .LOC = "CLB_R27C18.S1";
  X_BUF \vga/N75/XUSED  (
    .I(\vga/N75 ),
    .O(\vga/N75_0 )
  );
  defparam \vga/N75/YUSED .LOC = "CLB_R27C18.S1";
  X_BUF \vga/N75/YUSED  (
    .I(\vga/N66 ),
    .O(\vga/N66_0 )
  );
  defparam \vga/char_rom/Mrom_data69 .INIT = 16'h3007;
  defparam \vga/char_rom/Mrom_data69 .LOC = "CLB_R25C11.S1";
  X_LUT4 \vga/char_rom/Mrom_data69  (
    .ADR0(\vga/rom_addr_char_0_1_18 ),
    .ADR1(\vga/vgacore/vcnt_0_1_17 ),
    .ADR2(\vga/vgacore/vcnt_2_1_9 ),
    .ADR3(\vga/vgacore/vcnt_1_1_8 ),
    .O(\vga/N73 )
  );
  defparam \vga/char_rom/Mrom_data54 .INIT = 16'h24C3;
  defparam \vga/char_rom/Mrom_data54 .LOC = "CLB_R25C11.S1";
  X_LUT4 \vga/char_rom/Mrom_data54  (
    .ADR0(\vga/rom_addr_char_0_1_18 ),
    .ADR1(\vga/vgacore/vcnt_1_1_8 ),
    .ADR2(\vga/vgacore/vcnt_0_1_17 ),
    .ADR3(\vga/vgacore/vcnt_2_1_9 ),
    .O(\vga/N58 )
  );
  defparam \vga/N73/XUSED .LOC = "CLB_R25C11.S1";
  X_BUF \vga/N73/XUSED  (
    .I(\vga/N73 ),
    .O(\vga/N73_0 )
  );
  defparam \vga/N73/YUSED .LOC = "CLB_R25C11.S1";
  X_BUF \vga/N73/YUSED  (
    .I(\vga/N58 ),
    .O(\vga/N58_0 )
  );
  defparam \vga/char_rom/Mrom_data68 .INIT = 16'h2006;
  defparam \vga/char_rom/Mrom_data68 .LOC = "CLB_R27C6.S0";
  X_LUT4 \vga/char_rom/Mrom_data68  (
    .ADR0(\vga/vgacore/vcnt_1_1_8 ),
    .ADR1(\vga/vgacore/vcnt_2_1_9 ),
    .ADR2(\vga/rom_addr_char_0_1_18 ),
    .ADR3(\vga/vgacore/vcnt_0_1_17 ),
    .O(\vga/N72 )
  );
  defparam \vga/char_rom/Mrom_data46 .INIT = 16'h0508;
  defparam \vga/char_rom/Mrom_data46 .LOC = "CLB_R27C6.S0";
  X_LUT4 \vga/char_rom/Mrom_data46  (
    .ADR0(\vga/vgacore/vcnt_2_1_9 ),
    .ADR1(\vga/vgacore/vcnt_1_1_8 ),
    .ADR2(\vga/rom_addr_char_0_1_18 ),
    .ADR3(\vga/vgacore/vcnt_0_1_17 ),
    .O(\vga/N50 )
  );
  defparam \vga/N72/XUSED .LOC = "CLB_R27C6.S0";
  X_BUF \vga/N72/XUSED  (
    .I(\vga/N72 ),
    .O(\vga/N72_0 )
  );
  defparam \vga/N72/YUSED .LOC = "CLB_R27C6.S0";
  X_BUF \vga/N72/YUSED  (
    .I(\vga/N50 ),
    .O(\vga/N50_0 )
  );
  defparam \vga/char_rom/Mrom_data67 .INIT = 16'h2008;
  defparam \vga/char_rom/Mrom_data67 .LOC = "CLB_R21C8.S0";
  X_LUT4 \vga/char_rom/Mrom_data67  (
    .ADR0(\vga/vgacore/vcnt_2_1_9 ),
    .ADR1(\vga/vgacore/vcnt_0_1_17 ),
    .ADR2(\vga/vgacore/vcnt_1_1_8 ),
    .ADR3(\vga/rom_addr_char_0_1_18 ),
    .O(\vga/N71 )
  );
  defparam \vga/char_rom/Mrom_data38 .INIT = 16'h2AA0;
  defparam \vga/char_rom/Mrom_data38 .LOC = "CLB_R21C8.S0";
  X_LUT4 \vga/char_rom/Mrom_data38  (
    .ADR0(\vga/rom_addr_char_0_1_18 ),
    .ADR1(\vga/vgacore/vcnt_0_1_17 ),
    .ADR2(\vga/vgacore/vcnt_1_1_8 ),
    .ADR3(\vga/vgacore/vcnt_2_1_9 ),
    .O(\vga/N41 )
  );
  defparam \vga/N71/XUSED .LOC = "CLB_R21C8.S0";
  X_BUF \vga/N71/XUSED  (
    .I(\vga/N71 ),
    .O(\vga/N71_0 )
  );
  defparam \vga/N71/YUSED .LOC = "CLB_R21C8.S0";
  X_BUF \vga/N71/YUSED  (
    .I(\vga/N41 ),
    .O(\vga/N41_0 )
  );
  defparam \vga/char_rom/Mrom_data66 .INIT = 16'h2001;
  defparam \vga/char_rom/Mrom_data66 .LOC = "CLB_R28C18.S0";
  X_LUT4 \vga/char_rom/Mrom_data66  (
    .ADR0(\vga/vgacore/vcnt_2_1_9 ),
    .ADR1(\vga/vgacore/vcnt_0_1_17 ),
    .ADR2(\vga/rom_addr_char_0_1_18 ),
    .ADR3(\vga/vgacore/vcnt_1_1_8 ),
    .O(\vga/N70 )
  );
  defparam \vga/char_rom/Mrom_data63 .INIT = 16'h1008;
  defparam \vga/char_rom/Mrom_data63 .LOC = "CLB_R28C18.S0";
  X_LUT4 \vga/char_rom/Mrom_data63  (
    .ADR0(\vga/vgacore/vcnt_2_1_9 ),
    .ADR1(\vga/vgacore/vcnt_1_1_8 ),
    .ADR2(\vga/vgacore/vcnt_0_1_17 ),
    .ADR3(\vga/rom_addr_char_0_1_18 ),
    .O(\vga/N67 )
  );
  defparam \vga/N70/XUSED .LOC = "CLB_R28C18.S0";
  X_BUF \vga/N70/XUSED  (
    .I(\vga/N70 ),
    .O(\vga/N70_0 )
  );
  defparam \vga/N70/YUSED .LOC = "CLB_R28C18.S0";
  X_BUF \vga/N70/YUSED  (
    .I(\vga/N67 ),
    .O(\vga/N67_0 )
  );
  defparam \vga/char_rom/Mrom_data65 .INIT = 16'h09A5;
  defparam \vga/char_rom/Mrom_data65 .LOC = "CLB_R26C11.S1";
  X_LUT4 \vga/char_rom/Mrom_data65  (
    .ADR0(\vga/vgacore/vcnt_1_1_8 ),
    .ADR1(\vga/rom_addr_char_0_1_18 ),
    .ADR2(\vga/vgacore/vcnt_0_1_17 ),
    .ADR3(\vga/vgacore/vcnt_2_1_9 ),
    .O(\vga/N69 )
  );
  defparam \vga/char_rom/Mrom_data55 .INIT = 16'h2049;
  defparam \vga/char_rom/Mrom_data55 .LOC = "CLB_R26C11.S1";
  X_LUT4 \vga/char_rom/Mrom_data55  (
    .ADR0(\vga/rom_addr_char_0_1_18 ),
    .ADR1(\vga/vgacore/vcnt_1_1_8 ),
    .ADR2(\vga/vgacore/vcnt_2_1_9 ),
    .ADR3(\vga/vgacore/vcnt_0_1_17 ),
    .O(\vga/N59 )
  );
  defparam \vga/N69/XUSED .LOC = "CLB_R26C11.S1";
  X_BUF \vga/N69/XUSED  (
    .I(\vga/N69 ),
    .O(\vga/N69_0 )
  );
  defparam \vga/N69/YUSED .LOC = "CLB_R26C11.S1";
  X_BUF \vga/N69/YUSED  (
    .I(\vga/N59 ),
    .O(\vga/N59_0 )
  );
  defparam \vga/char_rom/Mrom_data59 .INIT = 16'h2909;
  defparam \vga/char_rom/Mrom_data59 .LOC = "CLB_R27C18.S0";
  X_LUT4 \vga/char_rom/Mrom_data59  (
    .ADR0(\vga/vgacore/vcnt_1_1_8 ),
    .ADR1(\vga/vgacore/vcnt_2_1_9 ),
    .ADR2(\vga/vgacore/vcnt_0_1_17 ),
    .ADR3(\vga/rom_addr_char_0_1_18 ),
    .O(\vga/N63 )
  );
  defparam \vga/char_rom/Mrom_data64 .INIT = 16'h4025;
  defparam \vga/char_rom/Mrom_data64 .LOC = "CLB_R27C18.S0";
  X_LUT4 \vga/char_rom/Mrom_data64  (
    .ADR0(\vga/vgacore/vcnt_1_1_8 ),
    .ADR1(\vga/rom_addr_char_0_1_18 ),
    .ADR2(\vga/vgacore/vcnt_0_1_17 ),
    .ADR3(\vga/vgacore/vcnt_2_1_9 ),
    .O(\vga/N68 )
  );
  defparam \vga/N63/XUSED .LOC = "CLB_R27C18.S0";
  X_BUF \vga/N63/XUSED  (
    .I(\vga/N63 ),
    .O(\vga/N63_0 )
  );
  defparam \vga/N63/YUSED .LOC = "CLB_R27C18.S0";
  X_BUF \vga/N63/YUSED  (
    .I(\vga/N68 ),
    .O(\vga/N68_0 )
  );
  defparam \vga/char_rom/Mrom_data58 .INIT = 16'h0929;
  defparam \vga/char_rom/Mrom_data58 .LOC = "CLB_R25C11.S0";
  X_LUT4 \vga/char_rom/Mrom_data58  (
    .ADR0(\vga/vgacore/vcnt_1_1_8 ),
    .ADR1(\vga/vgacore/vcnt_2_1_9 ),
    .ADR2(\vga/vgacore/vcnt_0_1_17 ),
    .ADR3(\vga/rom_addr_char_0_1_18 ),
    .O(\vga/N62 )
  );
  defparam \vga/char_rom/Mrom_data56 .INIT = 16'h2106;
  defparam \vga/char_rom/Mrom_data56 .LOC = "CLB_R25C11.S0";
  X_LUT4 \vga/char_rom/Mrom_data56  (
    .ADR0(\vga/vgacore/vcnt_1_1_8 ),
    .ADR1(\vga/vgacore/vcnt_2_1_9 ),
    .ADR2(\vga/vgacore/vcnt_0_1_17 ),
    .ADR3(\vga/rom_addr_char_0_1_18 ),
    .O(\vga/N60 )
  );
  defparam \vga/N62/XUSED .LOC = "CLB_R25C11.S0";
  X_BUF \vga/N62/XUSED  (
    .I(\vga/N62 ),
    .O(\vga/N62_0 )
  );
  defparam \vga/N62/YUSED .LOC = "CLB_R25C11.S0";
  X_BUF \vga/N62/YUSED  (
    .I(\vga/N60 ),
    .O(\vga/N60_0 )
  );
  defparam \vga/rom_addr_char<2>2_SW0 .INIT = 16'hFDAF;
  defparam \vga/rom_addr_char<2>2_SW0 .LOC = "CLB_R20C11.S1";
  X_LUT4 \vga/rom_addr_char<2>2_SW0  (
    .ADR0(\vga/rom_addr_char_0_1_18 ),
    .ADR1(\vga/vgacore/vcnt_1_1_8 ),
    .ADR2(\vga/rom_addr_char_1_1_7 ),
    .ADR3(\vga/vgacore/vcnt_0_1_17 ),
    .O(N3164)
  );
  defparam \vga/char_rom/Mrom_data57 .INIT = 16'h030F;
  defparam \vga/char_rom/Mrom_data57 .LOC = "CLB_R20C11.S1";
  X_LUT4 \vga/char_rom/Mrom_data57  (
    .ADR0(VCC),
    .ADR1(\vga/rom_addr_char_0_1_18 ),
    .ADR2(\vga/vgacore/vcnt_0_1_17 ),
    .ADR3(\vga/vgacore/vcnt_1_1_8 ),
    .O(\vga/N61 )
  );
  defparam \N3164/XUSED .LOC = "CLB_R20C11.S1";
  X_BUF \N3164/XUSED  (
    .I(N3164),
    .O(N3164_0)
  );
  defparam \N3164/YUSED .LOC = "CLB_R20C11.S1";
  X_BUF \N3164/YUSED  (
    .I(\vga/N61 ),
    .O(\vga/N61_0 )
  );
  defparam \vga/char_rom/Mrom_data8 .INIT = 16'h17C0;
  defparam \vga/char_rom/Mrom_data8 .LOC = "CLB_R24C5.S0";
  X_LUT4 \vga/char_rom/Mrom_data8  (
    .ADR0(\vga/vgacore/vcnt_1_1_8 ),
    .ADR1(\vga/vgacore/vcnt_2_1_9 ),
    .ADR2(\vga/rom_addr_char_0_1_18 ),
    .ADR3(\vga/vgacore/vcnt_0_1_17 ),
    .O(\vga/N11 )
  );
  defparam \vga/char_rom/Mrom_data49 .INIT = 16'h0040;
  defparam \vga/char_rom/Mrom_data49 .LOC = "CLB_R24C5.S0";
  X_LUT4 \vga/char_rom/Mrom_data49  (
    .ADR0(\vga/vgacore/vcnt_2_1_9 ),
    .ADR1(\vga/vgacore/vcnt_1_1_8 ),
    .ADR2(\vga/rom_addr_char_0_1_18 ),
    .ADR3(\vga/vgacore/vcnt_0_1_17 ),
    .O(\vga/N53 )
  );
  defparam \vga/N11/XUSED .LOC = "CLB_R24C5.S0";
  X_BUF \vga/N11/XUSED  (
    .I(\vga/N11 ),
    .O(\vga/N11_0 )
  );
  defparam \vga/N11/YUSED .LOC = "CLB_R24C5.S0";
  X_BUF \vga/N11/YUSED  (
    .I(\vga/N53 ),
    .O(\vga/N53_0 )
  );
  defparam \vga/scancode_convert/ctrl_set_SW1 .INIT = 16'hBBFF;
  defparam \vga/scancode_convert/ctrl_set_SW1 .LOC = "CLB_R12C32.S1";
  X_LUT4 \vga/scancode_convert/ctrl_set_SW1  (
    .ADR0(\vga/scancode_convert/release_prefix_26 ),
    .ADR1(\vga/ps2/rdy_r_1 ),
    .ADR2(VCC),
    .ADR3(\vga/scancode_convert/state_FFd5_31 ),
    .O(N3158_pack_1)
  );
  defparam \vga/scancode_convert/ctrl_set .INIT = 16'h0040;
  defparam \vga/scancode_convert/ctrl_set .LOC = "CLB_R12C32.S1";
  X_LUT4 \vga/scancode_convert/ctrl_set  (
    .ADR0(\vga/ps2/sc_r [1]),
    .ADR1(\vga/ps2/sc_r [2]),
    .ADR2(\vga/scancode_convert/N10_0 ),
    .ADR3(N3158),
    .O(\vga/scancode_convert/ctrl_set_168 )
  );
  defparam \vga/scancode_convert/ctrl/XUSED .LOC = "CLB_R12C32.S1";
  X_BUF \vga/scancode_convert/ctrl/XUSED  (
    .I(N3158_pack_1),
    .O(N3158)
  );
  defparam \vga/scancode_convert/ctrl .LOC = "CLB_R12C32.S1";
  defparam \vga/scancode_convert/ctrl .INIT = 1'b0;
  X_FF \vga/scancode_convert/ctrl  (
    .I(\vga/scancode_convert/ctrl_set_168 ),
    .CE(\vga/scancode_convert/_not0009_0 ),
    .CLK(gray_cnt_FFd1_0),
    .SET(GND),
    .RST(\vga/scancode_convert/ctrl/FFY/RST ),
    .O(\vga/scancode_convert/ctrl_22 )
  );
  defparam \vga/scancode_convert/ctrl/FFY/RSTOR .LOC = "CLB_R12C32.S1";
  X_INV \vga/scancode_convert/ctrl/FFY/RSTOR  (
    .I(reset_n_IBUF_0),
    .O(\vga/scancode_convert/ctrl/FFY/RST )
  );
  defparam \vga/scancode_convert/scancode_rom/data<2>1180_SW1 .INIT = 16'hED4B;
  defparam \vga/scancode_convert/scancode_rom/data<2>1180_SW1 .LOC = "CLB_R10C37.S0";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<2>1180_SW1  (
    .ADR0(\vga/scancode_convert/sc [3]),
    .ADR1(\vga/scancode_convert/sc [0]),
    .ADR2(\vga/scancode_convert/sc [2]),
    .ADR3(\vga/scancode_convert/sc [1]),
    .O(N3142)
  );
  defparam \vga/scancode_convert/scancode_rom/data<4>1118 .INIT = 16'hCDCC;
  defparam \vga/scancode_convert/scancode_rom/data<4>1118 .LOC = "CLB_R10C37.S0";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<4>1118  (
    .ADR0(\vga/scancode_convert/sc [0]),
    .ADR1(\vga/scancode_convert/sc [2]),
    .ADR2(\vga/scancode_convert/sc [4]),
    .ADR3(\vga/scancode_convert/sc [1]),
    .O(\vga/scancode_convert/scancode_rom/data<4>1_map1565 )
  );
  defparam \N3142/XUSED .LOC = "CLB_R10C37.S0";
  X_BUF \N3142/XUSED  (
    .I(N3142),
    .O(N3142_0)
  );
  defparam \N3142/YUSED .LOC = "CLB_R10C37.S0";
  X_BUF \N3142/YUSED  (
    .I(\vga/scancode_convert/scancode_rom/data<4>1_map1565 ),
    .O(\vga/scancode_convert/scancode_rom/data<4>1_map1565_0 )
  );
  defparam \vga/char_rom/Mrom_data186 .INIT = 16'h114E;
  defparam \vga/char_rom/Mrom_data186 .LOC = "CLB_R15C3.S0";
  X_LUT4 \vga/char_rom/Mrom_data186  (
    .ADR0(\vga/vgacore/vcnt [2]),
    .ADR1(\vga/vgacore/vcnt [0]),
    .ADR2(\vga/rom_addr_char [0]),
    .ADR3(\vga/vgacore/vcnt [1]),
    .O(\vga/N193 )
  );
  defparam \vga/char_rom/Mrom_data100 .INIT = 16'h2686;
  defparam \vga/char_rom/Mrom_data100 .LOC = "CLB_R15C3.S0";
  X_LUT4 \vga/char_rom/Mrom_data100  (
    .ADR0(\vga/rom_addr_char [0]),
    .ADR1(\vga/vgacore/vcnt [0]),
    .ADR2(\vga/vgacore/vcnt [1]),
    .ADR3(\vga/vgacore/vcnt [2]),
    .O(\vga/N105 )
  );
  defparam \vga/N193/XUSED .LOC = "CLB_R15C3.S0";
  X_BUF \vga/N193/XUSED  (
    .I(\vga/N193 ),
    .O(\vga/N193_0 )
  );
  defparam \vga/N193/YUSED .LOC = "CLB_R15C3.S0";
  X_BUF \vga/N193/YUSED  (
    .I(\vga/N105 ),
    .O(\vga/N105_0 )
  );
  defparam \vga/char_rom/Mrom_data185 .INIT = 16'h1216;
  defparam \vga/char_rom/Mrom_data185 .LOC = "CLB_R22C11.S0";
  X_LUT4 \vga/char_rom/Mrom_data185  (
    .ADR0(\vga/vgacore/vcnt [1]),
    .ADR1(\vga/rom_addr_char [0]),
    .ADR2(\vga/vgacore/vcnt [2]),
    .ADR3(\vga/vgacore/vcnt [0]),
    .O(\vga/N192 )
  );
  defparam \vga/char_rom/Mrom_data101 .INIT = 16'h131B;
  defparam \vga/char_rom/Mrom_data101 .LOC = "CLB_R22C11.S0";
  X_LUT4 \vga/char_rom/Mrom_data101  (
    .ADR0(\vga/vgacore/vcnt [1]),
    .ADR1(\vga/vgacore/vcnt [0]),
    .ADR2(\vga/rom_addr_char [0]),
    .ADR3(\vga/vgacore/vcnt [2]),
    .O(\vga/N106 )
  );
  defparam \vga/N192/XUSED .LOC = "CLB_R22C11.S0";
  X_BUF \vga/N192/XUSED  (
    .I(\vga/N192 ),
    .O(\vga/N192_0 )
  );
  defparam \vga/N192/YUSED .LOC = "CLB_R22C11.S0";
  X_BUF \vga/N192/YUSED  (
    .I(\vga/N106 ),
    .O(\vga/N106_0 )
  );
  defparam \vga/char_rom/Mrom_data184 .INIT = 16'h54D2;
  defparam \vga/char_rom/Mrom_data184 .LOC = "CLB_R26C10.S1";
  X_LUT4 \vga/char_rom/Mrom_data184  (
    .ADR0(\vga/vgacore/vcnt [2]),
    .ADR1(\vga/vgacore/vcnt [0]),
    .ADR2(\vga/rom_addr_char [0]),
    .ADR3(\vga/vgacore/vcnt [1]),
    .O(\vga/N191 )
  );
  defparam \vga/char_rom/Mrom_data110 .INIT = 16'h5333;
  defparam \vga/char_rom/Mrom_data110 .LOC = "CLB_R26C10.S1";
  X_LUT4 \vga/char_rom/Mrom_data110  (
    .ADR0(\vga/vgacore/vcnt [0]),
    .ADR1(\vga/rom_addr_char [0]),
    .ADR2(\vga/vgacore/vcnt [1]),
    .ADR3(\vga/vgacore/vcnt [2]),
    .O(\vga/N115 )
  );
  defparam \vga/N191/XUSED .LOC = "CLB_R26C10.S1";
  X_BUF \vga/N191/XUSED  (
    .I(\vga/N191 ),
    .O(\vga/N191_0 )
  );
  defparam \vga/N191/YUSED .LOC = "CLB_R26C10.S1";
  X_BUF \vga/N191/YUSED  (
    .I(\vga/N115 ),
    .O(\vga/N115_0 )
  );
  defparam \vga/char_rom/Mrom_data183 .INIT = 16'h3308;
  defparam \vga/char_rom/Mrom_data183 .LOC = "CLB_R24C10.S0";
  X_LUT4 \vga/char_rom/Mrom_data183  (
    .ADR0(\vga/vgacore/vcnt [2]),
    .ADR1(\vga/vgacore/vcnt [1]),
    .ADR2(\vga/rom_addr_char [0]),
    .ADR3(\vga/vgacore/vcnt [0]),
    .O(\vga/N190 )
  );
  defparam \vga/char_rom/Mrom_data111 .INIT = 16'h6068;
  defparam \vga/char_rom/Mrom_data111 .LOC = "CLB_R24C10.S0";
  X_LUT4 \vga/char_rom/Mrom_data111  (
    .ADR0(\vga/vgacore/vcnt [2]),
    .ADR1(\vga/vgacore/vcnt [1]),
    .ADR2(\vga/rom_addr_char [0]),
    .ADR3(\vga/vgacore/vcnt [0]),
    .O(\vga/N116 )
  );
  defparam \vga/N190/XUSED .LOC = "CLB_R24C10.S0";
  X_BUF \vga/N190/XUSED  (
    .I(\vga/N190 ),
    .O(\vga/N190_0 )
  );
  defparam \vga/N190/YUSED .LOC = "CLB_R24C10.S0";
  X_BUF \vga/N190/YUSED  (
    .I(\vga/N116 ),
    .O(\vga/N116_0 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<6>1108 .INIT = 16'hEEFE;
  defparam \vga/scancode_convert/scancode_rom/data<6>1108 .LOC = "CLB_R13C37.S1";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<6>1108  (
    .ADR0(\vga/scancode_convert/sc [2]),
    .ADR1(\vga/scancode_convert/sc [1]),
    .ADR2(\vga/scancode_convert/sc [0]),
    .ADR3(\vga/scancode_convert/sc [3]),
    .O(\vga/scancode_convert/scancode_rom/data<6>1_map1808 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<2>1180_SW0 .INIT = 16'hB91D;
  defparam \vga/scancode_convert/scancode_rom/data<2>1180_SW0 .LOC = "CLB_R13C37.S1";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<2>1180_SW0  (
    .ADR0(\vga/scancode_convert/sc [2]),
    .ADR1(\vga/scancode_convert/sc [1]),
    .ADR2(\vga/scancode_convert/sc [3]),
    .ADR3(\vga/scancode_convert/sc [0]),
    .O(N3141)
  );
  defparam \vga/scancode_convert/scancode_rom/data<6>1_map1808/XUSED .LOC = "CLB_R13C37.S1";
  X_BUF \vga/scancode_convert/scancode_rom/data<6>1_map1808/XUSED  (
    .I(\vga/scancode_convert/scancode_rom/data<6>1_map1808 ),
    .O(\vga/scancode_convert/scancode_rom/data<6>1_map1808_0 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<6>1_map1808/YUSED .LOC = "CLB_R13C37.S1";
  X_BUF \vga/scancode_convert/scancode_rom/data<6>1_map1808/YUSED  (
    .I(N3141),
    .O(N3141_0)
  );
  defparam \vga/char_rom/Mrom_data179 .INIT = 16'h1B00;
  defparam \vga/char_rom/Mrom_data179 .LOC = "CLB_R25C5.S1";
  X_LUT4 \vga/char_rom/Mrom_data179  (
    .ADR0(\vga/vgacore/vcnt [1]),
    .ADR1(\vga/rom_addr_char [0]),
    .ADR2(\vga/vgacore/vcnt [2]),
    .ADR3(\vga/vgacore/vcnt [0]),
    .O(\vga/N186 )
  );
  defparam \vga/char_rom/Mrom_data120 .INIT = 16'h2BA2;
  defparam \vga/char_rom/Mrom_data120 .LOC = "CLB_R25C5.S1";
  X_LUT4 \vga/char_rom/Mrom_data120  (
    .ADR0(\vga/rom_addr_char [0]),
    .ADR1(\vga/vgacore/vcnt [0]),
    .ADR2(\vga/vgacore/vcnt [2]),
    .ADR3(\vga/vgacore/vcnt [1]),
    .O(\vga/N125 )
  );
  defparam \vga/N186/XUSED .LOC = "CLB_R25C5.S1";
  X_BUF \vga/N186/XUSED  (
    .I(\vga/N186 ),
    .O(\vga/N186_0 )
  );
  defparam \vga/N186/YUSED .LOC = "CLB_R25C5.S1";
  X_BUF \vga/N186/YUSED  (
    .I(\vga/N125 ),
    .O(\vga/N125_0 )
  );
  defparam \vga/char_rom/Mrom_data177 .INIT = 16'h503C;
  defparam \vga/char_rom/Mrom_data177 .LOC = "CLB_R24C10.S1";
  X_LUT4 \vga/char_rom/Mrom_data177  (
    .ADR0(\vga/vgacore/vcnt [1]),
    .ADR1(\vga/rom_addr_char [0]),
    .ADR2(\vga/vgacore/vcnt [0]),
    .ADR3(\vga/vgacore/vcnt [2]),
    .O(\vga/N184 )
  );
  defparam \vga/char_rom/Mrom_data112 .INIT = 16'h4C20;
  defparam \vga/char_rom/Mrom_data112 .LOC = "CLB_R24C10.S1";
  X_LUT4 \vga/char_rom/Mrom_data112  (
    .ADR0(\vga/vgacore/vcnt [0]),
    .ADR1(\vga/rom_addr_char [0]),
    .ADR2(\vga/vgacore/vcnt [1]),
    .ADR3(\vga/vgacore/vcnt [2]),
    .O(\vga/N117 )
  );
  defparam \vga/N184/XUSED .LOC = "CLB_R24C10.S1";
  X_BUF \vga/N184/XUSED  (
    .I(\vga/N184 ),
    .O(\vga/N184_0 )
  );
  defparam \vga/N184/YUSED .LOC = "CLB_R24C10.S1";
  X_BUF \vga/N184/YUSED  (
    .I(\vga/N117 ),
    .O(\vga/N117_0 )
  );
  defparam \vga/char_rom/Mrom_data176 .INIT = 16'h4207;
  defparam \vga/char_rom/Mrom_data176 .LOC = "CLB_R25C5.S0";
  X_LUT4 \vga/char_rom/Mrom_data176  (
    .ADR0(\vga/vgacore/vcnt [1]),
    .ADR1(\vga/vgacore/vcnt [0]),
    .ADR2(\vga/vgacore/vcnt [2]),
    .ADR3(\vga/rom_addr_char [0]),
    .O(\vga/N183 )
  );
  defparam \vga/char_rom/Mrom_data121 .INIT = 16'h2890;
  defparam \vga/char_rom/Mrom_data121 .LOC = "CLB_R25C5.S0";
  X_LUT4 \vga/char_rom/Mrom_data121  (
    .ADR0(\vga/vgacore/vcnt [0]),
    .ADR1(\vga/rom_addr_char [0]),
    .ADR2(\vga/vgacore/vcnt [1]),
    .ADR3(\vga/vgacore/vcnt [2]),
    .O(\vga/N126 )
  );
  defparam \vga/N183/XUSED .LOC = "CLB_R25C5.S0";
  X_BUF \vga/N183/XUSED  (
    .I(\vga/N183 ),
    .O(\vga/N183_0 )
  );
  defparam \vga/N183/YUSED .LOC = "CLB_R25C5.S0";
  X_BUF \vga/N183/YUSED  (
    .I(\vga/N126 ),
    .O(\vga/N126_0 )
  );
  defparam \vga/char_rom/Mrom_data173 .INIT = 16'h53E2;
  defparam \vga/char_rom/Mrom_data173 .LOC = "CLB_R25C16.S0";
  X_LUT4 \vga/char_rom/Mrom_data173  (
    .ADR0(\vga/vgacore/vcnt [1]),
    .ADR1(\vga/vgacore/vcnt [0]),
    .ADR2(\vga/rom_addr_char [0]),
    .ADR3(\vga/vgacore/vcnt [2]),
    .O(\vga/N179 )
  );
  defparam \vga/char_rom/Mrom_data113 .INIT = 16'h009D;
  defparam \vga/char_rom/Mrom_data113 .LOC = "CLB_R25C16.S0";
  X_LUT4 \vga/char_rom/Mrom_data113  (
    .ADR0(\vga/vgacore/vcnt [2]),
    .ADR1(\vga/vgacore/vcnt [1]),
    .ADR2(\vga/rom_addr_char [0]),
    .ADR3(\vga/vgacore/vcnt [0]),
    .O(\vga/N118 )
  );
  defparam \vga/N179/XUSED .LOC = "CLB_R25C16.S0";
  X_BUF \vga/N179/XUSED  (
    .I(\vga/N179 ),
    .O(\vga/N179_0 )
  );
  defparam \vga/N179/YUSED .LOC = "CLB_R25C16.S0";
  X_BUF \vga/N179/YUSED  (
    .I(\vga/N118 ),
    .O(\vga/N118_0 )
  );
  defparam \vga/char_rom/Mrom_data172 .INIT = 16'hC010;
  defparam \vga/char_rom/Mrom_data172 .LOC = "CLB_R26C16.S1";
  X_LUT4 \vga/char_rom/Mrom_data172  (
    .ADR0(\vga/vgacore/vcnt [1]),
    .ADR1(\vga/rom_addr_char [0]),
    .ADR2(\vga/vgacore/vcnt [2]),
    .ADR3(\vga/vgacore/vcnt [0]),
    .O(\vga/N178 )
  );
  defparam \vga/char_rom/Mrom_data105 .INIT = 16'h7F08;
  defparam \vga/char_rom/Mrom_data105 .LOC = "CLB_R26C16.S1";
  X_LUT4 \vga/char_rom/Mrom_data105  (
    .ADR0(\vga/vgacore/vcnt [1]),
    .ADR1(\vga/vgacore/vcnt [0]),
    .ADR2(\vga/vgacore/vcnt [2]),
    .ADR3(\vga/rom_addr_char [0]),
    .O(\vga/N110 )
  );
  defparam \vga/N178/XUSED .LOC = "CLB_R26C16.S1";
  X_BUF \vga/N178/XUSED  (
    .I(\vga/N178 ),
    .O(\vga/N178_0 )
  );
  defparam \vga/N178/YUSED .LOC = "CLB_R26C16.S1";
  X_BUF \vga/N178/YUSED  (
    .I(\vga/N110 ),
    .O(\vga/N110_0 )
  );
  defparam \vga/char_rom/Mrom_data170 .INIT = 16'h205E;
  defparam \vga/char_rom/Mrom_data170 .LOC = "CLB_R25C10.S0";
  X_LUT4 \vga/char_rom/Mrom_data170  (
    .ADR0(\vga/vgacore/vcnt [2]),
    .ADR1(\vga/vgacore/vcnt [0]),
    .ADR2(\vga/vgacore/vcnt [1]),
    .ADR3(\vga/rom_addr_char [0]),
    .O(\vga/N176 )
  );
  defparam \vga/char_rom/Mrom_data122 .INIT = 16'h1B73;
  defparam \vga/char_rom/Mrom_data122 .LOC = "CLB_R25C10.S0";
  X_LUT4 \vga/char_rom/Mrom_data122  (
    .ADR0(\vga/vgacore/vcnt [1]),
    .ADR1(\vga/rom_addr_char [0]),
    .ADR2(\vga/vgacore/vcnt [2]),
    .ADR3(\vga/vgacore/vcnt [0]),
    .O(\vga/N127 )
  );
  defparam \vga/N176/XUSED .LOC = "CLB_R25C10.S0";
  X_BUF \vga/N176/XUSED  (
    .I(\vga/N176 ),
    .O(\vga/N176_0 )
  );
  defparam \vga/N176/YUSED .LOC = "CLB_R25C10.S0";
  X_BUF \vga/N176/YUSED  (
    .I(\vga/N127 ),
    .O(\vga/N127_0 )
  );
  defparam \vga/char_rom/Mrom_data169 .INIT = 16'h5760;
  defparam \vga/char_rom/Mrom_data169 .LOC = "CLB_R25C16.S1";
  X_LUT4 \vga/char_rom/Mrom_data169  (
    .ADR0(\vga/vgacore/vcnt [0]),
    .ADR1(\vga/rom_addr_char [0]),
    .ADR2(\vga/vgacore/vcnt [1]),
    .ADR3(\vga/vgacore/vcnt [2]),
    .O(\vga/N175 )
  );
  defparam \vga/char_rom/Mrom_data106 .INIT = 16'h1440;
  defparam \vga/char_rom/Mrom_data106 .LOC = "CLB_R25C16.S1";
  X_LUT4 \vga/char_rom/Mrom_data106  (
    .ADR0(\vga/vgacore/vcnt [0]),
    .ADR1(\vga/vgacore/vcnt [2]),
    .ADR2(\vga/vgacore/vcnt [1]),
    .ADR3(\vga/rom_addr_char [0]),
    .O(\vga/N111 )
  );
  defparam \vga/N175/XUSED .LOC = "CLB_R25C16.S1";
  X_BUF \vga/N175/XUSED  (
    .I(\vga/N175 ),
    .O(\vga/N175_0 )
  );
  defparam \vga/N175/YUSED .LOC = "CLB_R25C16.S1";
  X_BUF \vga/N175/YUSED  (
    .I(\vga/N111 ),
    .O(\vga/N111_0 )
  );
  defparam \vga/char_rom/Mrom_data166 .INIT = 16'h0820;
  defparam \vga/char_rom/Mrom_data166 .LOC = "CLB_R26C3.S0";
  X_LUT4 \vga/char_rom/Mrom_data166  (
    .ADR0(\vga/vgacore/vcnt [2]),
    .ADR1(\vga/vgacore/vcnt [0]),
    .ADR2(\vga/rom_addr_char [0]),
    .ADR3(\vga/vgacore/vcnt [1]),
    .O(\vga/N172 )
  );
  defparam \vga/char_rom/Mrom_data131 .INIT = 16'h7E05;
  defparam \vga/char_rom/Mrom_data131 .LOC = "CLB_R26C3.S0";
  X_LUT4 \vga/char_rom/Mrom_data131  (
    .ADR0(\vga/vgacore/vcnt [2]),
    .ADR1(\vga/vgacore/vcnt [0]),
    .ADR2(\vga/vgacore/vcnt [1]),
    .ADR3(\vga/rom_addr_char [0]),
    .O(\vga/N137 )
  );
  defparam \vga/N172/XUSED .LOC = "CLB_R26C3.S0";
  X_BUF \vga/N172/XUSED  (
    .I(\vga/N172 ),
    .O(\vga/N172_0 )
  );
  defparam \vga/N172/YUSED .LOC = "CLB_R26C3.S0";
  X_BUF \vga/N172/YUSED  (
    .I(\vga/N137 ),
    .O(\vga/N137_0 )
  );
  defparam \vga/char_rom/Mrom_data165 .INIT = 16'h0004;
  defparam \vga/char_rom/Mrom_data165 .LOC = "CLB_R28C5.S0";
  X_LUT4 \vga/char_rom/Mrom_data165  (
    .ADR0(\vga/vgacore/vcnt [2]),
    .ADR1(\vga/vgacore/vcnt [1]),
    .ADR2(\vga/vgacore/vcnt [0]),
    .ADR3(\vga/rom_addr_char [0]),
    .O(\vga/N171 )
  );
  defparam \vga/char_rom/Mrom_data123 .INIT = 16'h2030;
  defparam \vga/char_rom/Mrom_data123 .LOC = "CLB_R28C5.S0";
  X_LUT4 \vga/char_rom/Mrom_data123  (
    .ADR0(\vga/rom_addr_char [0]),
    .ADR1(\vga/vgacore/vcnt [0]),
    .ADR2(\vga/vgacore/vcnt [1]),
    .ADR3(\vga/vgacore/vcnt [2]),
    .O(\vga/N128 )
  );
  defparam \vga/N171/XUSED .LOC = "CLB_R28C5.S0";
  X_BUF \vga/N171/XUSED  (
    .I(\vga/N171 ),
    .O(\vga/N171_0 )
  );
  defparam \vga/N171/YUSED .LOC = "CLB_R28C5.S0";
  X_BUF \vga/N171/YUSED  (
    .I(\vga/N128 ),
    .O(\vga/N128_0 )
  );
  defparam \vga/char_rom/Mrom_data164 .INIT = 16'hD33A;
  defparam \vga/char_rom/Mrom_data164 .LOC = "CLB_R27C10.S0";
  X_LUT4 \vga/char_rom/Mrom_data164  (
    .ADR0(\vga/vgacore/vcnt [1]),
    .ADR1(\vga/rom_addr_char [0]),
    .ADR2(\vga/vgacore/vcnt [0]),
    .ADR3(\vga/vgacore/vcnt [2]),
    .O(\vga/N170 )
  );
  defparam \vga/char_rom/Mrom_data115 .INIT = 16'h8001;
  defparam \vga/char_rom/Mrom_data115 .LOC = "CLB_R27C10.S0";
  X_LUT4 \vga/char_rom/Mrom_data115  (
    .ADR0(\vga/vgacore/vcnt [1]),
    .ADR1(\vga/rom_addr_char [0]),
    .ADR2(\vga/vgacore/vcnt [0]),
    .ADR3(\vga/vgacore/vcnt [2]),
    .O(\vga/N120 )
  );
  defparam \vga/N170/XUSED .LOC = "CLB_R27C10.S0";
  X_BUF \vga/N170/XUSED  (
    .I(\vga/N170 ),
    .O(\vga/N170_0 )
  );
  defparam \vga/N170/YUSED .LOC = "CLB_R27C10.S0";
  X_BUF \vga/N170/YUSED  (
    .I(\vga/N120 ),
    .O(\vga/N120_0 )
  );
  defparam \vga/char_rom/Mrom_data161 .INIT = 16'h3025;
  defparam \vga/char_rom/Mrom_data161 .LOC = "CLB_R27C3.S0";
  X_LUT4 \vga/char_rom/Mrom_data161  (
    .ADR0(\vga/vgacore/vcnt [2]),
    .ADR1(\vga/vgacore/vcnt [0]),
    .ADR2(\vga/rom_addr_char [0]),
    .ADR3(\vga/vgacore/vcnt [1]),
    .O(\vga/N167 )
  );
  defparam \vga/char_rom/Mrom_data140 .INIT = 16'h6112;
  defparam \vga/char_rom/Mrom_data140 .LOC = "CLB_R27C3.S0";
  X_LUT4 \vga/char_rom/Mrom_data140  (
    .ADR0(\vga/vgacore/vcnt [2]),
    .ADR1(\vga/vgacore/vcnt [0]),
    .ADR2(\vga/rom_addr_char [0]),
    .ADR3(\vga/vgacore/vcnt [1]),
    .O(\vga/N146 )
  );
  defparam \vga/N167/XUSED .LOC = "CLB_R27C3.S0";
  X_BUF \vga/N167/XUSED  (
    .I(\vga/N167 ),
    .O(\vga/N167_0 )
  );
  defparam \vga/N167/YUSED .LOC = "CLB_R27C3.S0";
  X_BUF \vga/N167/YUSED  (
    .I(\vga/N146 ),
    .O(\vga/N146_0 )
  );
  defparam \vga/char_rom/Mrom_data153 .INIT = 16'h4012;
  defparam \vga/char_rom/Mrom_data153 .LOC = "CLB_R23C10.S0";
  X_LUT4 \vga/char_rom/Mrom_data153  (
    .ADR0(\vga/vgacore/vcnt [0]),
    .ADR1(\vga/vgacore/vcnt [1]),
    .ADR2(\vga/rom_addr_char [0]),
    .ADR3(\vga/vgacore/vcnt [2]),
    .O(\vga/N159 )
  );
  defparam \vga/char_rom/Mrom_data132 .INIT = 16'h134C;
  defparam \vga/char_rom/Mrom_data132 .LOC = "CLB_R23C10.S0";
  X_LUT4 \vga/char_rom/Mrom_data132  (
    .ADR0(\vga/vgacore/vcnt [1]),
    .ADR1(\vga/rom_addr_char [0]),
    .ADR2(\vga/vgacore/vcnt [2]),
    .ADR3(\vga/vgacore/vcnt [0]),
    .O(\vga/N138 )
  );
  defparam \vga/N159/XUSED .LOC = "CLB_R23C10.S0";
  X_BUF \vga/N159/XUSED  (
    .I(\vga/N159 ),
    .O(\vga/N159_0 )
  );
  defparam \vga/N159/YUSED .LOC = "CLB_R23C10.S0";
  X_BUF \vga/N159/YUSED  (
    .I(\vga/N138 ),
    .O(\vga/N138_0 )
  );
  defparam \vga/char_rom/Mrom_data151 .INIT = 16'h4020;
  defparam \vga/char_rom/Mrom_data151 .LOC = "CLB_R22C11.S1";
  X_LUT4 \vga/char_rom/Mrom_data151  (
    .ADR0(\vga/vgacore/vcnt [2]),
    .ADR1(\vga/rom_addr_char [0]),
    .ADR2(\vga/vgacore/vcnt [1]),
    .ADR3(\vga/vgacore/vcnt [0]),
    .O(\vga/N157 )
  );
  defparam \vga/char_rom/Mrom_data124 .INIT = 16'h200C;
  defparam \vga/char_rom/Mrom_data124 .LOC = "CLB_R22C11.S1";
  X_LUT4 \vga/char_rom/Mrom_data124  (
    .ADR0(\vga/vgacore/vcnt [2]),
    .ADR1(\vga/vgacore/vcnt [1]),
    .ADR2(\vga/vgacore/vcnt [0]),
    .ADR3(\vga/rom_addr_char [0]),
    .O(\vga/N129 )
  );
  defparam \vga/N157/XUSED .LOC = "CLB_R22C11.S1";
  X_BUF \vga/N157/XUSED  (
    .I(\vga/N157 ),
    .O(\vga/N157_0 )
  );
  defparam \vga/N157/YUSED .LOC = "CLB_R22C11.S1";
  X_BUF \vga/N157/YUSED  (
    .I(\vga/N129 ),
    .O(\vga/N129_0 )
  );
  defparam \vga/char_rom/Mrom_data149 .INIT = 16'h0491;
  defparam \vga/char_rom/Mrom_data149 .LOC = "CLB_R27C11.S0";
  X_LUT4 \vga/char_rom/Mrom_data149  (
    .ADR0(\vga/vgacore/vcnt [2]),
    .ADR1(\vga/vgacore/vcnt [1]),
    .ADR2(\vga/rom_addr_char [0]),
    .ADR3(\vga/vgacore/vcnt [0]),
    .O(\vga/N155 )
  );
  defparam \vga/char_rom/Mrom_data116 .INIT = 16'h0E13;
  defparam \vga/char_rom/Mrom_data116 .LOC = "CLB_R27C11.S0";
  X_LUT4 \vga/char_rom/Mrom_data116  (
    .ADR0(\vga/vgacore/vcnt [1]),
    .ADR1(\vga/vgacore/vcnt [2]),
    .ADR2(\vga/vgacore/vcnt [0]),
    .ADR3(\vga/rom_addr_char [0]),
    .O(\vga/N121 )
  );
  defparam \vga/N155/XUSED .LOC = "CLB_R27C11.S0";
  X_BUF \vga/N155/XUSED  (
    .I(\vga/N155 ),
    .O(\vga/N155_0 )
  );
  defparam \vga/N155/YUSED .LOC = "CLB_R27C11.S0";
  X_BUF \vga/N155/YUSED  (
    .I(\vga/N121 ),
    .O(\vga/N121_0 )
  );
  defparam \vga/char_rom/Mrom_data146 .INIT = 16'h0039;
  defparam \vga/char_rom/Mrom_data146 .LOC = "CLB_R26C16.S0";
  X_LUT4 \vga/char_rom/Mrom_data146  (
    .ADR0(\vga/vgacore/vcnt [2]),
    .ADR1(\vga/vgacore/vcnt [1]),
    .ADR2(\vga/rom_addr_char [0]),
    .ADR3(\vga/vgacore/vcnt [0]),
    .O(\vga/N152 )
  );
  defparam \vga/char_rom/Mrom_data108 .INIT = 16'h0806;
  defparam \vga/char_rom/Mrom_data108 .LOC = "CLB_R26C16.S0";
  X_LUT4 \vga/char_rom/Mrom_data108  (
    .ADR0(\vga/rom_addr_char [0]),
    .ADR1(\vga/vgacore/vcnt [1]),
    .ADR2(\vga/vgacore/vcnt [0]),
    .ADR3(\vga/vgacore/vcnt [2]),
    .O(\vga/N113 )
  );
  defparam \vga/N152/XUSED .LOC = "CLB_R26C16.S0";
  X_BUF \vga/N152/XUSED  (
    .I(\vga/N152 ),
    .O(\vga/N152_0 )
  );
  defparam \vga/N152/YUSED .LOC = "CLB_R26C16.S0";
  X_BUF \vga/N152/YUSED  (
    .I(\vga/N113 ),
    .O(\vga/N113_0 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<4>1308_SW0 .INIT = 16'hC0C3;
  defparam \vga/scancode_convert/scancode_rom/data<4>1308_SW0 .LOC = "CLB_R11C36.S1";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<4>1308_SW0  (
    .ADR0(VCC),
    .ADR1(\vga/scancode_convert/sc [0]),
    .ADR2(\vga/scancode_convert/sc [1]),
    .ADR3(\vga/scancode_convert/sc [3]),
    .O(N3174)
  );
  defparam \vga/scancode_convert/scancode_rom/data<5>3193 .INIT = 16'hF3F2;
  defparam \vga/scancode_convert/scancode_rom/data<5>3193 .LOC = "CLB_R11C36.S1";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<5>3193  (
    .ADR0(\vga/scancode_convert/sc [0]),
    .ADR1(\vga/scancode_convert/raise ),
    .ADR2(\vga/scancode_convert/sc [3]),
    .ADR3(\vga/scancode_convert/sc [1]),
    .O(\vga/scancode_convert/scancode_rom/data<5>3_map1276 )
  );
  defparam \N3174/XUSED .LOC = "CLB_R11C36.S1";
  X_BUF \N3174/XUSED  (
    .I(N3174),
    .O(N3174_0)
  );
  defparam \N3174/YUSED .LOC = "CLB_R11C36.S1";
  X_BUF \N3174/YUSED  (
    .I(\vga/scancode_convert/scancode_rom/data<5>3_map1276 ),
    .O(\vga/scancode_convert/scancode_rom/data<5>3_map1276_0 )
  );
  defparam \vga/scancode_convert/key_up .LOC = "CLB_R15C26.S0";
  defparam \vga/scancode_convert/key_up .INIT = 1'b0;
  X_FF \vga/scancode_convert/key_up  (
    .I(\vga/scancode_convert/state_FFd3_29 ),
    .CE(\vga/scancode_convert/_not0012_0 ),
    .CLK(gray_cnt_FFd1_0),
    .SET(GND),
    .RST(\vga/scancode_convert/key_up/FFY/RST ),
    .O(\vga/scancode_convert/key_up_14 )
  );
  defparam \vga/scancode_convert/key_up/FFY/RSTOR .LOC = "CLB_R15C26.S0";
  X_INV \vga/scancode_convert/key_up/FFY/RSTOR  (
    .I(reset_n_IBUF_0),
    .O(\vga/scancode_convert/key_up/FFY/RST )
  );
  defparam \vga/char_rom/Mrom_data145 .INIT = 16'h0141;
  defparam \vga/char_rom/Mrom_data145 .LOC = "CLB_R24C3.S1";
  X_LUT4 \vga/char_rom/Mrom_data145  (
    .ADR0(\vga/vgacore/vcnt [0]),
    .ADR1(\vga/vgacore/vcnt [1]),
    .ADR2(\vga/vgacore/vcnt [2]),
    .ADR3(\vga/rom_addr_char [0]),
    .O(\vga/N151 )
  );
  defparam \vga/char_rom/Mrom_data141 .INIT = 16'h19AC;
  defparam \vga/char_rom/Mrom_data141 .LOC = "CLB_R24C3.S1";
  X_LUT4 \vga/char_rom/Mrom_data141  (
    .ADR0(\vga/vgacore/vcnt [2]),
    .ADR1(\vga/rom_addr_char [0]),
    .ADR2(\vga/vgacore/vcnt [1]),
    .ADR3(\vga/vgacore/vcnt [0]),
    .O(\vga/N147 )
  );
  defparam \vga/N151/XUSED .LOC = "CLB_R24C3.S1";
  X_BUF \vga/N151/XUSED  (
    .I(\vga/N151 ),
    .O(\vga/N151_0 )
  );
  defparam \vga/N151/YUSED .LOC = "CLB_R24C3.S1";
  X_BUF \vga/N151/YUSED  (
    .I(\vga/N147 ),
    .O(\vga/N147_0 )
  );
  defparam \vga/char_rom/Mrom_data144 .INIT = 16'h0582;
  defparam \vga/char_rom/Mrom_data144 .LOC = "CLB_R21C3.S0";
  X_LUT4 \vga/char_rom/Mrom_data144  (
    .ADR0(\vga/vgacore/vcnt [2]),
    .ADR1(\vga/rom_addr_char [0]),
    .ADR2(\vga/vgacore/vcnt [0]),
    .ADR3(\vga/vgacore/vcnt [1]),
    .O(\vga/N150 )
  );
  defparam \vga/char_rom/Mrom_data133 .INIT = 16'h1531;
  defparam \vga/char_rom/Mrom_data133 .LOC = "CLB_R21C3.S0";
  X_LUT4 \vga/char_rom/Mrom_data133  (
    .ADR0(\vga/vgacore/vcnt [2]),
    .ADR1(\vga/vgacore/vcnt [0]),
    .ADR2(\vga/vgacore/vcnt [1]),
    .ADR3(\vga/rom_addr_char [0]),
    .O(\vga/N139 )
  );
  defparam \vga/N150/XUSED .LOC = "CLB_R21C3.S0";
  X_BUF \vga/N150/XUSED  (
    .I(\vga/N150 ),
    .O(\vga/N150_0 )
  );
  defparam \vga/N150/YUSED .LOC = "CLB_R21C3.S0";
  X_BUF \vga/N150/YUSED  (
    .I(\vga/N139 ),
    .O(\vga/N139_0 )
  );
  defparam \vga/char_rom/Mrom_data143 .INIT = 16'hBFC0;
  defparam \vga/char_rom/Mrom_data143 .LOC = "CLB_R23C2.S0";
  X_LUT4 \vga/char_rom/Mrom_data143  (
    .ADR0(\vga/rom_addr_char [0]),
    .ADR1(\vga/vgacore/vcnt [0]),
    .ADR2(\vga/vgacore/vcnt [2]),
    .ADR3(\vga/vgacore/vcnt [1]),
    .O(\vga/N149 )
  );
  defparam \vga/char_rom/Mrom_data125 .INIT = 16'h10A0;
  defparam \vga/char_rom/Mrom_data125 .LOC = "CLB_R23C2.S0";
  X_LUT4 \vga/char_rom/Mrom_data125  (
    .ADR0(\vga/rom_addr_char [0]),
    .ADR1(\vga/vgacore/vcnt [0]),
    .ADR2(\vga/vgacore/vcnt [2]),
    .ADR3(\vga/vgacore/vcnt [1]),
    .O(\vga/N130 )
  );
  defparam \vga/N149/XUSED .LOC = "CLB_R23C2.S0";
  X_BUF \vga/N149/XUSED  (
    .I(\vga/N149 ),
    .O(\vga/N149_0 )
  );
  defparam \vga/N149/YUSED .LOC = "CLB_R23C2.S0";
  X_BUF \vga/N149/YUSED  (
    .I(\vga/N130 ),
    .O(\vga/N130_0 )
  );
  defparam \vga/char_rom/Mrom_data139 .INIT = 16'h2391;
  defparam \vga/char_rom/Mrom_data139 .LOC = "CLB_R26C10.S0";
  X_LUT4 \vga/char_rom/Mrom_data139  (
    .ADR0(\vga/vgacore/vcnt [1]),
    .ADR1(\vga/vgacore/vcnt [0]),
    .ADR2(\vga/rom_addr_char [0]),
    .ADR3(\vga/vgacore/vcnt [2]),
    .O(\vga/N145 )
  );
  defparam \vga/char_rom/Mrom_data109 .INIT = 16'h4521;
  defparam \vga/char_rom/Mrom_data109 .LOC = "CLB_R26C10.S0";
  X_LUT4 \vga/char_rom/Mrom_data109  (
    .ADR0(\vga/vgacore/vcnt [0]),
    .ADR1(\vga/vgacore/vcnt [2]),
    .ADR2(\vga/vgacore/vcnt [1]),
    .ADR3(\vga/rom_addr_char [0]),
    .O(\vga/N114 )
  );
  defparam \vga/N145/XUSED .LOC = "CLB_R26C10.S0";
  X_BUF \vga/N145/XUSED  (
    .I(\vga/N145 ),
    .O(\vga/N145_0 )
  );
  defparam \vga/N145/YUSED .LOC = "CLB_R26C10.S0";
  X_BUF \vga/N145/YUSED  (
    .I(\vga/N114 ),
    .O(\vga/N114_0 )
  );
  defparam \vga/char_rom/Mrom_data138 .INIT = 16'h180D;
  defparam \vga/char_rom/Mrom_data138 .LOC = "CLB_R23C2.S1";
  X_LUT4 \vga/char_rom/Mrom_data138  (
    .ADR0(\vga/vgacore/vcnt [1]),
    .ADR1(\vga/vgacore/vcnt [2]),
    .ADR2(\vga/vgacore/vcnt [0]),
    .ADR3(\vga/rom_addr_char [0]),
    .O(\vga/N144 )
  );
  defparam \vga/char_rom/Mrom_data126 .INIT = 16'h4804;
  defparam \vga/char_rom/Mrom_data126 .LOC = "CLB_R23C2.S1";
  X_LUT4 \vga/char_rom/Mrom_data126  (
    .ADR0(\vga/vgacore/vcnt [1]),
    .ADR1(\vga/vgacore/vcnt [2]),
    .ADR2(\vga/vgacore/vcnt [0]),
    .ADR3(\vga/rom_addr_char [0]),
    .O(\vga/N131 )
  );
  defparam \vga/N144/XUSED .LOC = "CLB_R23C2.S1";
  X_BUF \vga/N144/XUSED  (
    .I(\vga/N144 ),
    .O(\vga/N144_0 )
  );
  defparam \vga/N144/YUSED .LOC = "CLB_R23C2.S1";
  X_BUF \vga/N144/YUSED  (
    .I(\vga/N131 ),
    .O(\vga/N131_0 )
  );
  defparam \vga/char_rom/Mrom_data137 .INIT = 16'h0448;
  defparam \vga/char_rom/Mrom_data137 .LOC = "CLB_R20C2.S0";
  X_LUT4 \vga/char_rom/Mrom_data137  (
    .ADR0(\vga/vgacore/vcnt [0]),
    .ADR1(\vga/vgacore/vcnt [2]),
    .ADR2(\vga/rom_addr_char [0]),
    .ADR3(\vga/vgacore/vcnt [1]),
    .O(\vga/N143 )
  );
  defparam \vga/char_rom/Mrom_data127 .INIT = 16'h00D6;
  defparam \vga/char_rom/Mrom_data127 .LOC = "CLB_R20C2.S0";
  X_LUT4 \vga/char_rom/Mrom_data127  (
    .ADR0(\vga/rom_addr_char [0]),
    .ADR1(\vga/vgacore/vcnt [1]),
    .ADR2(\vga/vgacore/vcnt [2]),
    .ADR3(\vga/vgacore/vcnt [0]),
    .O(\vga/N132 )
  );
  defparam \vga/N143/XUSED .LOC = "CLB_R20C2.S0";
  X_BUF \vga/N143/XUSED  (
    .I(\vga/N143 ),
    .O(\vga/N143_0 )
  );
  defparam \vga/N143/YUSED .LOC = "CLB_R20C2.S0";
  X_BUF \vga/N143/YUSED  (
    .I(\vga/N132 ),
    .O(\vga/N132_0 )
  );
  defparam \vga/char_rom/Mrom_data129 .INIT = 16'h0010;
  defparam \vga/char_rom/Mrom_data129 .LOC = "CLB_R20C2.S1";
  X_LUT4 \vga/char_rom/Mrom_data129  (
    .ADR0(\vga/vgacore/vcnt [2]),
    .ADR1(\vga/rom_addr_char [0]),
    .ADR2(\vga/vgacore/vcnt [0]),
    .ADR3(\vga/vgacore/vcnt [1]),
    .O(\vga/N134 )
  );
  defparam \vga/char_rom/Mrom_data136 .INIT = 16'h40A8;
  defparam \vga/char_rom/Mrom_data136 .LOC = "CLB_R20C2.S1";
  X_LUT4 \vga/char_rom/Mrom_data136  (
    .ADR0(\vga/vgacore/vcnt [2]),
    .ADR1(\vga/vgacore/vcnt [1]),
    .ADR2(\vga/vgacore/vcnt [0]),
    .ADR3(\vga/rom_addr_char [0]),
    .O(\vga/N142 )
  );
  defparam \vga/N134/XUSED .LOC = "CLB_R20C2.S1";
  X_BUF \vga/N134/XUSED  (
    .I(\vga/N134 ),
    .O(\vga/N134_0 )
  );
  defparam \vga/N134/YUSED .LOC = "CLB_R20C2.S1";
  X_BUF \vga/N134/YUSED  (
    .I(\vga/N142 ),
    .O(\vga/N142_0 )
  );
  defparam \vga/char_rom/Mrom_data1 .INIT = 16'h4000;
  defparam \vga/char_rom/Mrom_data1 .LOC = "CLB_R22C3.S1";
  X_LUT4 \vga/char_rom/Mrom_data1  (
    .ADR0(\vga/vgacore/vcnt [1]),
    .ADR1(\vga/vgacore/vcnt [0]),
    .ADR2(\vga/rom_addr_char [0]),
    .ADR3(\vga/vgacore/vcnt [2]),
    .O(\vga/N2 )
  );
  defparam \vga/char_rom/Mrom_data128 .INIT = 16'h415F;
  defparam \vga/char_rom/Mrom_data128 .LOC = "CLB_R22C3.S1";
  X_LUT4 \vga/char_rom/Mrom_data128  (
    .ADR0(\vga/vgacore/vcnt [0]),
    .ADR1(\vga/vgacore/vcnt [2]),
    .ADR2(\vga/vgacore/vcnt [1]),
    .ADR3(\vga/rom_addr_char [0]),
    .O(\vga/N133 )
  );
  defparam \vga/N2/XUSED .LOC = "CLB_R22C3.S1";
  X_BUF \vga/N2/XUSED  (
    .I(\vga/N2 ),
    .O(\vga/N2_0 )
  );
  defparam \vga/N2/YUSED .LOC = "CLB_R22C3.S1";
  X_BUF \vga/N2/YUSED  (
    .I(\vga/N133 ),
    .O(\vga/N133_0 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<0>1206 .INIT = 16'h112A;
  defparam \vga/scancode_convert/scancode_rom/data<0>1206 .LOC = "CLB_R14C33.S0";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<0>1206  (
    .ADR0(\vga/scancode_convert/sc [4]),
    .ADR1(\vga/scancode_convert/sc [0]),
    .ADR2(\vga/scancode_convert/raise ),
    .ADR3(\vga/scancode_convert/sc [1]),
    .O(\vga/scancode_convert/scancode_rom/data<0>1_map1475 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<5>3614 .INIT = 16'h0E3D;
  defparam \vga/scancode_convert/scancode_rom/data<5>3614 .LOC = "CLB_R14C33.S0";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<5>3614  (
    .ADR0(\vga/scancode_convert/raise ),
    .ADR1(\vga/scancode_convert/sc [0]),
    .ADR2(\vga/scancode_convert/sc [1]),
    .ADR3(\vga/scancode_convert/sc [4]),
    .O(\vga/scancode_convert/scancode_rom/data<5>3_map1363 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<0>1_map1475/XUSED .LOC = "CLB_R14C33.S0";
  X_BUF \vga/scancode_convert/scancode_rom/data<0>1_map1475/XUSED  (
    .I(\vga/scancode_convert/scancode_rom/data<0>1_map1475 ),
    .O(\vga/scancode_convert/scancode_rom/data<0>1_map1475_0 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<0>1_map1475/YUSED .LOC = "CLB_R14C33.S0";
  X_BUF \vga/scancode_convert/scancode_rom/data<0>1_map1475/YUSED  (
    .I(\vga/scancode_convert/scancode_rom/data<5>3_map1363 ),
    .O(\vga/scancode_convert/scancode_rom/data<5>3_map1363_0 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<6>186_SW0 .INIT = 16'h5420;
  defparam \vga/scancode_convert/scancode_rom/data<6>186_SW0 .LOC = "CLB_R14C37.S0";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<6>186_SW0  (
    .ADR0(\vga/scancode_convert/sc [1]),
    .ADR1(\vga/scancode_convert/sc [0]),
    .ADR2(\vga/scancode_convert/sc [3]),
    .ADR3(\vga/scancode_convert/sc [4]),
    .O(N3124)
  );
  defparam \vga/scancode_convert/scancode_rom/data<6>1305 .INIT = 16'h3B37;
  defparam \vga/scancode_convert/scancode_rom/data<6>1305 .LOC = "CLB_R14C37.S0";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<6>1305  (
    .ADR0(\vga/scancode_convert/sc [3]),
    .ADR1(\vga/scancode_convert/sc [2]),
    .ADR2(\vga/scancode_convert/sc [1]),
    .ADR3(\vga/scancode_convert/sc [0]),
    .O(\vga/scancode_convert/scancode_rom/data<6>1_map1850 )
  );
  defparam \N3124/XUSED .LOC = "CLB_R14C37.S0";
  X_BUF \N3124/XUSED  (
    .I(N3124),
    .O(N3124_0)
  );
  defparam \N3124/YUSED .LOC = "CLB_R14C37.S0";
  X_BUF \N3124/YUSED  (
    .I(\vga/scancode_convert/scancode_rom/data<6>1_map1850 ),
    .O(\vga/scancode_convert/scancode_rom/data<6>1_map1850_0 )
  );
  defparam \vga/ram_addr_write<7>/LOGIC_ONE .LOC = "CLB_R15C10.S1";
  X_ONE \vga/ram_addr_write<7>/LOGIC_ONE  (
    .O(\vga/ram_addr_write<7>/LOGIC_ONE_169 )
  );
  defparam \vga/crt/Madd_ram_addr_Madd_cy<7> .LOC = "CLB_R15C10.S1";
  X_MUX2 \vga/crt/Madd_ram_addr_Madd_cy<7>  (
    .IA(\vga/crt/Madd_ram_addrC2 ),
    .IB(\vga/ram_addr_write<7>/CYINIT_171 ),
    .SEL(\vga/crt/N9 ),
    .O(\vga/crt/Madd_ram_addr_Madd_cy<7>_rt_170 )
  );
  defparam \vga/crt/Madd_ram_addr_Madd_xor<7> .LOC = "CLB_R15C10.S1";
  X_XOR2 \vga/crt/Madd_ram_addr_Madd_xor<7>  (
    .I0(\vga/ram_addr_write<7>/CYINIT_171 ),
    .I1(\vga/crt/N9 ),
    .O(\vga/ram_addr_write [7])
  );
  defparam \vga/crt/Madd_ram_addr_Madd_lut<7> .INIT = 16'h9966;
  defparam \vga/crt/Madd_ram_addr_Madd_lut<7> .LOC = "CLB_R15C10.S1";
  X_LUT4 \vga/crt/Madd_ram_addr_Madd_lut<7>  (
    .ADR0(\vga/crt/Madd_ram_addrC2 ),
    .ADR1(\vga/crt/cursor_v [1]),
    .ADR2(VCC),
    .ADR3(\vga/crt/cursor_v [3]),
    .O(\vga/crt/N9 )
  );
  defparam \vga/crt/Madd_ram_addrC21 .INIT = 16'hFAA0;
  defparam \vga/crt/Madd_ram_addrC21 .LOC = "CLB_R15C10.S1";
  X_LUT4 \vga/crt/Madd_ram_addrC21  (
    .ADR0(\vga/crt/cursor_v [0]),
    .ADR1(VCC),
    .ADR2(\vga/crt/cursor_h [6]),
    .ADR3(\vga/crt/cursor_v [2]),
    .O(\vga/crt/Madd_ram_addrC2_pack_1 )
  );
  defparam \vga/ram_addr_write<7>/XUSED .LOC = "CLB_R15C10.S1";
  X_BUF \vga/ram_addr_write<7>/XUSED  (
    .I(\vga/ram_addr_write [7]),
    .O(\vga/ram_addr_write<7>_0 )
  );
  defparam \vga/ram_addr_write<7>/YUSED .LOC = "CLB_R15C10.S1";
  X_BUF \vga/ram_addr_write<7>/YUSED  (
    .I(\vga/crt/Madd_ram_addrC2_pack_1 ),
    .O(\vga/crt/Madd_ram_addrC2 )
  );
  defparam \vga/crt/Madd_ram_addr_Madd_cy<7>_rt .LOC = "CLB_R15C10.S1";
  X_MUX2 \vga/crt/Madd_ram_addr_Madd_cy<7>_rt  (
    .IA(\NLW_vga/crt/Madd_ram_addr_Madd_cy<7>_rt_IA_UNCONNECTED ),
    .IB(\vga/crt/Madd_ram_addr_Madd_cy<7>_rt_170 ),
    .SEL(\vga/ram_addr_write<7>/LOGIC_ONE_169 ),
    .O(\vga/ram_addr_write<7>/CYMUXG )
  );
  defparam \vga/ram_addr_write<7>/CYINIT .LOC = "CLB_R15C10.S1";
  X_BUF \vga/ram_addr_write<7>/CYINIT  (
    .I(\vga/ram_addr_write<5>/CYMUXG ),
    .O(\vga/ram_addr_write<7>/CYINIT_171 )
  );
  defparam \vga/scancode_convert/raise1 .INIT = 16'hFFFC;
  defparam \vga/scancode_convert/raise1 .LOC = "CLB_R13C34.S0";
  X_LUT4 \vga/scancode_convert/raise1  (
    .ADR0(VCC),
    .ADR1(\vga/scancode_convert/ctrl_22 ),
    .ADR2(\vga/scancode_convert/capslock_25 ),
    .ADR3(\vga/scancode_convert/shift_24 ),
    .O(\vga/scancode_convert/raise_pack_1 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<0>144 .INIT = 16'h0A0E;
  defparam \vga/scancode_convert/scancode_rom/data<0>144 .LOC = "CLB_R13C34.S0";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<0>144  (
    .ADR0(\vga/scancode_convert/sc [4]),
    .ADR1(\vga/scancode_convert/sc [0]),
    .ADR2(\vga/scancode_convert/sc [1]),
    .ADR3(\vga/scancode_convert/raise ),
    .O(\vga/scancode_convert/scancode_rom/data<0>1_map1438 )
  );
  defparam \vga/scancode_convert/raise/XUSED .LOC = "CLB_R13C34.S0";
  X_BUF \vga/scancode_convert/raise/XUSED  (
    .I(\vga/scancode_convert/raise_pack_1 ),
    .O(\vga/scancode_convert/raise )
  );
  defparam \vga/scancode_convert/raise/YUSED .LOC = "CLB_R13C34.S0";
  X_BUF \vga/scancode_convert/raise/YUSED  (
    .I(\vga/scancode_convert/scancode_rom/data<0>1_map1438 ),
    .O(\vga/scancode_convert/scancode_rom/data<0>1_map1438_0 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<3>81 .INIT = 16'hFF5F;
  defparam \vga/scancode_convert/scancode_rom/data<3>81 .LOC = "CLB_R13C35.S1";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<3>81  (
    .ADR0(\vga/scancode_convert/sc [1]),
    .ADR1(VCC),
    .ADR2(\vga/scancode_convert/raise ),
    .ADR3(\vga/scancode_convert/sc [0]),
    .O(\vga/scancode_convert/scancode_rom/N43 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<5>3746 .INIT = 16'h9322;
  defparam \vga/scancode_convert/scancode_rom/data<5>3746 .LOC = "CLB_R13C35.S1";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<5>3746  (
    .ADR0(\vga/scancode_convert/sc [1]),
    .ADR1(\vga/scancode_convert/sc [4]),
    .ADR2(\vga/scancode_convert/raise ),
    .ADR3(\vga/scancode_convert/sc [0]),
    .O(\vga/scancode_convert/scancode_rom/data<5>3_map1394 )
  );
  defparam \vga/scancode_convert/scancode_rom/N43/XUSED .LOC = "CLB_R13C35.S1";
  X_BUF \vga/scancode_convert/scancode_rom/N43/XUSED  (
    .I(\vga/scancode_convert/scancode_rom/N43 ),
    .O(\vga/scancode_convert/scancode_rom/N43_0 )
  );
  defparam \vga/scancode_convert/scancode_rom/N43/YUSED .LOC = "CLB_R13C35.S1";
  X_BUF \vga/scancode_convert/scancode_rom/N43/YUSED  (
    .I(\vga/scancode_convert/scancode_rom/data<5>3_map1394 ),
    .O(\vga/scancode_convert/scancode_rom/data<5>3_map1394_0 )
  );
  defparam \vga/charload8_SW0 .INIT = 16'h2064;
  defparam \vga/charload8_SW0 .LOC = "CLB_R11C7.S1";
  X_LUT4 \vga/charload8_SW0  (
    .ADR0(\vga/rom_addr_char [5]),
    .ADR1(\vga/rom_addr_char [6]),
    .ADR2(\vga/rom_addr_char<4>11234_0 ),
    .ADR3(N3150_0),
    .O(N562_pack_1)
  );
  defparam \vga/charload8 .INIT = 16'hEEE2;
  defparam \vga/charload8 .LOC = "CLB_R11C7.S1";
  X_LUT4 \vga/charload8  (
    .ADR0(\vga/pixel_hold [6]),
    .ADR1(\vga/charload_19 ),
    .ADR2(\vga/cursor_match_0 ),
    .ADR3(N562),
    .O(\vga/_mux0002 [0])
  );
  defparam \vga/pixel_hold<7>/XUSED .LOC = "CLB_R11C7.S1";
  X_BUF \vga/pixel_hold<7>/XUSED  (
    .I(N562_pack_1),
    .O(N562)
  );
  defparam \vga/pixel_hold_7 .LOC = "CLB_R11C7.S1";
  defparam \vga/pixel_hold_7 .INIT = 1'b0;
  X_FF \vga/pixel_hold_7  (
    .I(\vga/_mux0002 [0]),
    .CE(VCC),
    .CLK(gray_cnt_FFd1_0),
    .SET(GND),
    .RST(GND),
    .O(\vga/pixel_hold [7])
  );
  defparam \vga/scancode_convert/scancode_rom/data<1>281 .INIT = 16'h002C;
  defparam \vga/scancode_convert/scancode_rom/data<1>281 .LOC = "CLB_R14C37.S1";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<1>281  (
    .ADR0(\vga/scancode_convert/sc [4]),
    .ADR1(\vga/scancode_convert/sc [0]),
    .ADR2(\vga/scancode_convert/sc [1]),
    .ADR3(\vga/scancode_convert/sc [3]),
    .O(\vga/scancode_convert/scancode_rom/data<1>2_map1701 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<6>1333_SW0 .INIT = 16'h0FCC;
  defparam \vga/scancode_convert/scancode_rom/data<6>1333_SW0 .LOC = "CLB_R14C37.S1";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<6>1333_SW0  (
    .ADR0(VCC),
    .ADR1(\vga/scancode_convert/sc [4]),
    .ADR2(\vga/scancode_convert/sc [0]),
    .ADR3(\vga/scancode_convert/sc [3]),
    .O(N3130)
  );
  defparam \vga/scancode_convert/scancode_rom/data<1>2_map1701/XUSED .LOC = "CLB_R14C37.S1";
  X_BUF \vga/scancode_convert/scancode_rom/data<1>2_map1701/XUSED  (
    .I(\vga/scancode_convert/scancode_rom/data<1>2_map1701 ),
    .O(\vga/scancode_convert/scancode_rom/data<1>2_map1701_0 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<1>2_map1701/YUSED .LOC = "CLB_R14C37.S1";
  X_BUF \vga/scancode_convert/scancode_rom/data<1>2_map1701/YUSED  (
    .I(N3130),
    .O(N3130_0)
  );
  defparam \vga/crt/state_Out41 .INIT = 16'h0044;
  defparam \vga/crt/state_Out41 .LOC = "CLB_R16C15.S1";
  X_LUT4 \vga/crt/state_Out41  (
    .ADR0(\vga/crt/state_FFd3_11 ),
    .ADR1(\vga/crt/state_FFd1_13 ),
    .ADR2(VCC),
    .ADR3(\vga/crt/state_FFd2_12 ),
    .O(\vga/crt/_cmp_eq0004_pack_1 )
  );
  defparam \vga/crt/write_delay__mux0000<1>1 .INIT = 16'h5A00;
  defparam \vga/crt/write_delay__mux0000<1>1 .LOC = "CLB_R16C15.S1";
  X_LUT4 \vga/crt/write_delay__mux0000<1>1  (
    .ADR0(\vga/crt/write_delay [0]),
    .ADR1(VCC),
    .ADR2(\vga/crt/write_delay [1]),
    .ADR3(\vga/crt/_cmp_eq0004 ),
    .O(\vga/crt/write_delay__mux0000 [1])
  );
  defparam \vga/crt/write_delay<1>/XUSED .LOC = "CLB_R16C15.S1";
  X_BUF \vga/crt/write_delay<1>/XUSED  (
    .I(\vga/crt/_cmp_eq0004_pack_1 ),
    .O(\vga/crt/_cmp_eq0004 )
  );
  defparam \vga/crt/write_delay_1 .LOC = "CLB_R16C15.S1";
  defparam \vga/crt/write_delay_1 .INIT = 1'b0;
  X_FF \vga/crt/write_delay_1  (
    .I(\vga/crt/write_delay__mux0000 [1]),
    .CE(VCC),
    .CLK(\vga/crtclk_4 ),
    .SET(GND),
    .RST(\vga/crt/write_delay<1>/FFY/RST ),
    .O(\vga/crt/write_delay [1])
  );
  defparam \vga/crt/write_delay<1>/FFY/RSTOR .LOC = "CLB_R16C15.S1";
  X_INV \vga/crt/write_delay<1>/FFY/RSTOR  (
    .I(reset_n_IBUF_0),
    .O(\vga/crt/write_delay<1>/FFY/RST )
  );
  defparam \vga/crt/state_Out92 .INIT = 16'h1155;
  defparam \vga/crt/state_Out92 .LOC = "CLB_R15C6.S0";
  X_LUT4 \vga/crt/state_Out92  (
    .ADR0(\vga/crt/state_FFd1_13 ),
    .ADR1(\vga/crt/state_FFd3_11 ),
    .ADR2(VCC),
    .ADR3(\vga/crt/state_FFd2_12 ),
    .O(\vga/clearing_pack_1 )
  );
  defparam \vga/_mux00001 .INIT = 16'h550C;
  defparam \vga/_mux00001 .LOC = "CLB_R15C6.S0";
  X_LUT4 \vga/_mux00001  (
    .ADR0(\vga/crtclk1 ),
    .ADR1(\vga/pclk [2]),
    .ADR2(\vga/pclk [1]),
    .ADR3(\vga/clearing ),
    .O(\vga/_mux0000 )
  );
  defparam \vga/ram_wclk/XUSED .LOC = "CLB_R15C6.S0";
  X_BUF \vga/ram_wclk/XUSED  (
    .I(\vga/clearing_pack_1 ),
    .O(\vga/clearing )
  );
  defparam \gray_cnt_FFd11/BYMUX .LOC = "CLB_R2C21.S0";
  X_INV \gray_cnt_FFd11/BYMUX  (
    .I(gray_cnt_FFd1_0),
    .O(\gray_cnt_FFd11/BYMUXNOT )
  );
  defparam \gray_cnt_FFd11/SRMUX .LOC = "CLB_R2C21.S0";
  X_INV \gray_cnt_FFd11/SRMUX  (
    .I(reset_n_IBUF_0),
    .O(\gray_cnt_FFd11/SRMUX_OUTPUTNOT )
  );
  defparam gray_cnt_FFd2.LOC = "CLB_R2C21.S0";
  defparam gray_cnt_FFd2.INIT = 1'b0;
  X_FF gray_cnt_FFd2 (
    .I(\gray_cnt_FFd11/BYMUXNOT ),
    .CE(VCC),
    .CLK(clka_BUFGP),
    .SET(GND),
    .RST(\gray_cnt_FFd11/FFY/RST ),
    .O(gray_cnt_FFd2_36)
  );
  defparam \gray_cnt_FFd11/FFY/RSTOR .LOC = "CLB_R2C21.S0";
  X_BUF \gray_cnt_FFd11/FFY/RSTOR  (
    .I(\gray_cnt_FFd11/SRMUX_OUTPUTNOT ),
    .O(\gray_cnt_FFd11/FFY/RST )
  );
  defparam \vga/crt/ram_we_n1 .INIT = 16'hFCCF;
  defparam \vga/crt/ram_we_n1 .LOC = "CLB_R14C3.S0";
  X_LUT4 \vga/crt/ram_we_n1  (
    .ADR0(VCC),
    .ADR1(\vga/crt/state_FFd2_12 ),
    .ADR2(\vga/crt/state_FFd3_11 ),
    .ADR3(\vga/crt/state_FFd1_13 ),
    .O(\vga/ram_we_n_pack_1 )
  );
  defparam \vga/ram_addr_mux<11>1 .INIT = 16'hCCAA;
  defparam \vga/ram_addr_mux<11>1 .LOC = "CLB_R14C3.S0";
  X_LUT4 \vga/ram_addr_mux<11>1  (
    .ADR0(\vga/ram_addr_write<11>_0 ),
    .ADR1(\vga/ram_addr_video<11>_0 ),
    .ADR2(VCC),
    .ADR3(\vga/ram_we_n ),
    .O(\vga/ram_addr_mux [11])
  );
  defparam \vga/video_ram/ram_addr_w<11>/XUSED .LOC = "CLB_R14C3.S0";
  X_BUF \vga/video_ram/ram_addr_w<11>/XUSED  (
    .I(\vga/ram_we_n_pack_1 ),
    .O(\vga/ram_we_n )
  );
  defparam \vga/video_ram/ram_addr_w<11>/YUSED .LOC = "CLB_R14C3.S0";
  X_BUF \vga/video_ram/ram_addr_w<11>/YUSED  (
    .I(\vga/ram_addr_mux [11]),
    .O(\vga/ram_addr_mux<11>_0 )
  );
  defparam \vga/video_ram/ram_addr_w_11 .LOC = "CLB_R14C3.S0";
  defparam \vga/video_ram/ram_addr_w_11 .INIT = 1'b0;
  X_FF \vga/video_ram/ram_addr_w_11  (
    .I(\vga/ram_addr_mux [11]),
    .CE(VCC),
    .CLK(\vga/ram_wclk_5 ),
    .SET(GND),
    .RST(GND),
    .O(\vga/video_ram/ram_addr_w [11])
  );
  defparam \vga/scancode_convert/capslock/BYMUX .LOC = "CLB_R13C32.S0";
  X_INV \vga/scancode_convert/capslock/BYMUX  (
    .I(\vga/scancode_convert/capslock_25 ),
    .O(\vga/scancode_convert/capslock/BYMUXNOT )
  );
  defparam \vga/scancode_convert/capslock .LOC = "CLB_R13C32.S0";
  defparam \vga/scancode_convert/capslock .INIT = 1'b0;
  X_FF \vga/scancode_convert/capslock  (
    .I(\vga/scancode_convert/capslock/BYMUXNOT ),
    .CE(\vga/scancode_convert/capslock_toggle_0 ),
    .CLK(gray_cnt_FFd1_0),
    .SET(GND),
    .RST(\vga/scancode_convert/capslock/FFY/RST ),
    .O(\vga/scancode_convert/capslock_25 )
  );
  defparam \vga/scancode_convert/capslock/FFY/RSTOR .LOC = "CLB_R13C32.S0";
  X_INV \vga/scancode_convert/capslock/FFY/RSTOR  (
    .I(reset_n_IBUF_0),
    .O(\vga/scancode_convert/capslock/FFY/RST )
  );
  defparam \vga/ram_addr_video<7>/LOGIC_ONE .LOC = "CLB_R16C5.S0";
  X_ONE \vga/ram_addr_video<7>/LOGIC_ONE  (
    .O(\vga/ram_addr_video<7>/LOGIC_ONE_172 )
  );
  defparam \vga/Madd_ram_addr_video_Madd_cy<7> .LOC = "CLB_R16C5.S0";
  X_MUX2 \vga/Madd_ram_addr_video_Madd_cy<7>  (
    .IA(\vga/Madd_ram_addr_videoC2 ),
    .IB(\vga/ram_addr_video<7>/CYINIT_174 ),
    .SEL(\vga/N230 ),
    .O(\vga/Madd_ram_addr_video_Madd_cy<7>_rt_173 )
  );
  defparam \vga/Madd_ram_addr_video_Madd_xor<7> .LOC = "CLB_R16C5.S0";
  X_XOR2 \vga/Madd_ram_addr_video_Madd_xor<7>  (
    .I0(\vga/ram_addr_video<7>/CYINIT_174 ),
    .I1(\vga/N230 ),
    .O(\vga/ram_addr_video [7])
  );
  defparam \vga/Madd_ram_addr_video_Madd_lut<7> .INIT = 16'h9966;
  defparam \vga/Madd_ram_addr_video_Madd_lut<7> .LOC = "CLB_R16C5.S0";
  X_LUT4 \vga/Madd_ram_addr_video_Madd_lut<7>  (
    .ADR0(\vga/Madd_ram_addr_videoC2 ),
    .ADR1(\vga/vgacore/vcnt [6]),
    .ADR2(VCC),
    .ADR3(\vga/vgacore/vcnt [4]),
    .O(\vga/N230 )
  );
  defparam \vga/Madd_ram_addr_videoC21 .INIT = 16'hEE88;
  defparam \vga/Madd_ram_addr_videoC21 .LOC = "CLB_R16C5.S0";
  X_LUT4 \vga/Madd_ram_addr_videoC21  (
    .ADR0(\vga/vgacore/vcnt [3]),
    .ADR1(\vga/vgacore/vcnt [5]),
    .ADR2(VCC),
    .ADR3(\vga/vgacore/hcnt [9]),
    .O(\vga/Madd_ram_addr_videoC2_pack_1 )
  );
  defparam \vga/ram_addr_video<7>/XUSED .LOC = "CLB_R16C5.S0";
  X_BUF \vga/ram_addr_video<7>/XUSED  (
    .I(\vga/ram_addr_video [7]),
    .O(\vga/ram_addr_video<7>_0 )
  );
  defparam \vga/ram_addr_video<7>/YUSED .LOC = "CLB_R16C5.S0";
  X_BUF \vga/ram_addr_video<7>/YUSED  (
    .I(\vga/Madd_ram_addr_videoC2_pack_1 ),
    .O(\vga/Madd_ram_addr_videoC2 )
  );
  defparam \vga/Madd_ram_addr_video_Madd_cy<7>_rt .LOC = "CLB_R16C5.S0";
  X_MUX2 \vga/Madd_ram_addr_video_Madd_cy<7>_rt  (
    .IA(\NLW_vga/Madd_ram_addr_video_Madd_cy<7>_rt_IA_UNCONNECTED ),
    .IB(\vga/Madd_ram_addr_video_Madd_cy<7>_rt_173 ),
    .SEL(\vga/ram_addr_video<7>/LOGIC_ONE_172 ),
    .O(\vga/ram_addr_video<7>/CYMUXG )
  );
  defparam \vga/ram_addr_video<7>/CYINIT .LOC = "CLB_R16C5.S0";
  X_BUF \vga/ram_addr_video<7>/CYINIT  (
    .I(\vga/ram_addr_video<5>/CYMUXG ),
    .O(\vga/ram_addr_video<7>/CYINIT_174 )
  );
  defparam \vga/vgacore/vcnt_Eqn_1_SW0 .INIT = 16'hFA00;
  defparam \vga/vgacore/vcnt_Eqn_1_SW0 .LOC = "CLB_R17C9.S0";
  X_LUT4 \vga/vgacore/vcnt_Eqn_1_SW0  (
    .ADR0(\vga/vgacore/vcnt [2]),
    .ADR1(VCC),
    .ADR2(\vga/vgacore/vcnt [0]),
    .ADR3(\vga/vgacore/vcnt [3]),
    .O(N839)
  );
  defparam \vga/Madd_ram_addr_videoR21 .INIT = 16'hA55A;
  defparam \vga/Madd_ram_addr_videoR21 .LOC = "CLB_R17C9.S0";
  X_LUT4 \vga/Madd_ram_addr_videoR21  (
    .ADR0(\vga/vgacore/vcnt [5]),
    .ADR1(VCC),
    .ADR2(\vga/vgacore/vcnt [3]),
    .ADR3(\vga/vgacore/hcnt [9]),
    .O(\vga/Madd_ram_addr_videoR2 )
  );
  defparam \N839/XUSED .LOC = "CLB_R17C9.S0";
  X_BUF \N839/XUSED  (
    .I(N839),
    .O(N839_0)
  );
  defparam \N839/YUSED .LOC = "CLB_R17C9.S0";
  X_BUF \N839/YUSED  (
    .I(\vga/Madd_ram_addr_videoR2 ),
    .O(\vga/Madd_ram_addr_videoR2_0 )
  );
  defparam \vga/ps2/ps2_clk_edge2 .INIT = 16'h1008;
  defparam \vga/ps2/ps2_clk_edge2 .LOC = "CLB_R10C16.S0";
  X_LUT4 \vga/ps2/ps2_clk_edge2  (
    .ADR0(\vga/ps2/ps2_clk_r [1]),
    .ADR1(\vga/ps2/ps2_clk_r [2]),
    .ADR2(\vga/ps2/ps2_clk_r [3]),
    .ADR3(\vga/ps2/ps2_clk_r [4]),
    .O(\vga/ps2/ps2_clk_edge_pack_1 )
  );
  defparam \vga/ps2/timer_x<1>1 .INIT = 16'h00AA;
  defparam \vga/ps2/timer_x<1>1 .LOC = "CLB_R10C16.S0";
  X_LUT4 \vga/ps2/timer_x<1>1  (
    .ADR0(\vga/ps2/_addsub0000<1>_0 ),
    .ADR1(VCC),
    .ADR2(VCC),
    .ADR3(\vga/ps2/ps2_clk_edge ),
    .O(\vga/ps2/timer_x [1])
  );
  defparam \vga/ps2/timer_r<1>/XUSED .LOC = "CLB_R10C16.S0";
  X_BUF \vga/ps2/timer_r<1>/XUSED  (
    .I(\vga/ps2/ps2_clk_edge_pack_1 ),
    .O(\vga/ps2/ps2_clk_edge )
  );
  defparam \vga/ps2/timer_r_1 .LOC = "CLB_R10C16.S0";
  defparam \vga/ps2/timer_r_1 .INIT = 1'b0;
  X_FF \vga/ps2/timer_r_1  (
    .I(\vga/ps2/timer_x [1]),
    .CE(VCC),
    .CLK(gray_cnt_FFd1_0),
    .SET(GND),
    .RST(\vga/ps2/timer_r<1>/FFY/RST ),
    .O(\vga/ps2/timer_r [1])
  );
  defparam \vga/ps2/timer_r<1>/FFY/RSTOR .LOC = "CLB_R10C16.S0";
  X_INV \vga/ps2/timer_r<1>/FFY/RSTOR  (
    .I(reset_n_IBUF_0),
    .O(\vga/ps2/timer_r<1>/FFY/RST )
  );
  defparam \vga/ps2/error_x13 .INIT = 16'hFF7E;
  defparam \vga/ps2/error_x13 .LOC = "CLB_R8C19.S0";
  X_LUT4 \vga/ps2/error_x13  (
    .ADR0(\vga/ps2/bitcnt_r [3]),
    .ADR1(\vga/ps2/bitcnt_r [0]),
    .ADR2(\vga/ps2/bitcnt_r [1]),
    .ADR3(\vga/ps2/bitcnt_r [2]),
    .O(\vga/ps2/error_x_map855 )
  );
  defparam \vga/ps2/_cmp_eq00001 .INIT = 16'h0080;
  defparam \vga/ps2/_cmp_eq00001 .LOC = "CLB_R8C19.S0";
  X_LUT4 \vga/ps2/_cmp_eq00001  (
    .ADR0(\vga/ps2/bitcnt_r [0]),
    .ADR1(\vga/ps2/bitcnt_r [1]),
    .ADR2(\vga/ps2/bitcnt_r [3]),
    .ADR3(\vga/ps2/bitcnt_r [2]),
    .O(\vga/ps2/_cmp_eq0000 )
  );
  defparam \vga/ps2/error_x_map855/XUSED .LOC = "CLB_R8C19.S0";
  X_BUF \vga/ps2/error_x_map855/XUSED  (
    .I(\vga/ps2/error_x_map855 ),
    .O(\vga/ps2/error_x_map855_0 )
  );
  defparam \vga/ps2/error_x_map855/YUSED .LOC = "CLB_R8C19.S0";
  X_BUF \vga/ps2/error_x_map855/YUSED  (
    .I(\vga/ps2/_cmp_eq0000 ),
    .O(\vga/ps2/_cmp_eq0000_0 )
  );
  defparam \vga/ps2/_cmp_eq00018 .INIT = 16'h0008;
  defparam \vga/ps2/_cmp_eq00018 .LOC = "CLB_R8C15.S0";
  X_LUT4 \vga/ps2/_cmp_eq00018  (
    .ADR0(\vga/ps2/timer_r [6]),
    .ADR1(\vga/ps2/timer_r [7]),
    .ADR2(\vga/ps2/timer_r [4]),
    .ADR3(\vga/ps2/timer_r [5]),
    .O(\vga/ps2/_cmp_eq0001_map1032 )
  );
  defparam \vga/ps2/_cmp_eq0001_map1032/YUSED .LOC = "CLB_R8C15.S0";
  X_BUF \vga/ps2/_cmp_eq0001_map1032/YUSED  (
    .I(\vga/ps2/_cmp_eq0001_map1032 ),
    .O(\vga/ps2/_cmp_eq0001_map1032_0 )
  );
  defparam \vga/vgacore/_and00005 .INIT = 16'h8000;
  defparam \vga/vgacore/_and00005 .LOC = "CLB_R17C8.S0";
  X_LUT4 \vga/vgacore/_and00005  (
    .ADR0(\vga/vgacore/hcnt [1]),
    .ADR1(\vga/vgacore/hcnt [2]),
    .ADR2(\vga/vgacore/hcnt [4]),
    .ADR3(\vga/vgacore/hcnt [3]),
    .O(\vga/vgacore/_and0000_map807_pack_1 )
  );
  defparam \vga/vgacore/_and000015 .INIT = 16'h4404;
  defparam \vga/vgacore/_and000015 .LOC = "CLB_R17C8.S0";
  X_LUT4 \vga/vgacore/_and000015  (
    .ADR0(\vga/vgacore/hcnt [8]),
    .ADR1(\vga/vgacore/hcnt [7]),
    .ADR2(N3132_0),
    .ADR3(\vga/vgacore/_and0000_map807 ),
    .O(\vga/vgacore/_and0000_map811 )
  );
  defparam \vga/vgacore/_and0000_map807/XUSED .LOC = "CLB_R17C8.S0";
  X_BUF \vga/vgacore/_and0000_map807/XUSED  (
    .I(\vga/vgacore/_and0000_map807_pack_1 ),
    .O(\vga/vgacore/_and0000_map807 )
  );
  defparam \vga/vgacore/_and0000_map807/YUSED .LOC = "CLB_R17C8.S0";
  X_BUF \vga/vgacore/_and0000_map807/YUSED  (
    .I(\vga/vgacore/_and0000_map811 ),
    .O(\vga/vgacore/_and0000_map811_0 )
  );
  defparam \vga/vgacore/vcnt_1_1/CKINV .LOC = "CLB_R18C8.S1";
  X_INV \vga/vgacore/vcnt_1_1/CKINV  (
    .I(\vga/vgacore/hblank_21 ),
    .O(\vga/vgacore/vcnt_1_1/CKMUXNOT )
  );
  defparam \vga/vgacore/vcnt_1_1 .LOC = "CLB_R18C8.S1";
  defparam \vga/vgacore/vcnt_1_1 .INIT = 1'b0;
  X_FF \vga/vgacore/vcnt_1_1  (
    .I(\vga/vgacore/Result<1>1_0 ),
    .CE(VCC),
    .CLK(\vga/vgacore/vcnt_1_1/CKMUXNOT ),
    .SET(GND),
    .RST(\vga/vgacore/vcnt_1_1/FFY/RST ),
    .O(\vga/vgacore/vcnt_1_1_8 )
  );
  defparam \vga/vgacore/vcnt_1_1/FFY/RSTOR .LOC = "CLB_R18C8.S1";
  X_INV \vga/vgacore/vcnt_1_1/FFY/RSTOR  (
    .I(reset_n_IBUF_0),
    .O(\vga/vgacore/vcnt_1_1/FFY/RST )
  );
  defparam \vga/vgacore/vcnt_2_1/CKINV .LOC = "CLB_R18C8.S0";
  X_INV \vga/vgacore/vcnt_2_1/CKINV  (
    .I(\vga/vgacore/hblank_21 ),
    .O(\vga/vgacore/vcnt_2_1/CKMUXNOT )
  );
  defparam \vga/vgacore/vcnt_2_1 .LOC = "CLB_R18C8.S0";
  defparam \vga/vgacore/vcnt_2_1 .INIT = 1'b0;
  X_FF \vga/vgacore/vcnt_2_1  (
    .I(\vga/vgacore/Result<2>1_0 ),
    .CE(VCC),
    .CLK(\vga/vgacore/vcnt_2_1/CKMUXNOT ),
    .SET(GND),
    .RST(\vga/vgacore/vcnt_2_1/FFY/RST ),
    .O(\vga/vgacore/vcnt_2_1_9 )
  );
  defparam \vga/vgacore/vcnt_2_1/FFY/RSTOR .LOC = "CLB_R18C8.S0";
  X_INV \vga/vgacore/vcnt_2_1/FFY/RSTOR  (
    .I(reset_n_IBUF_0),
    .O(\vga/vgacore/vcnt_2_1/FFY/RST )
  );
  defparam \vga/scancode_convert/_not00091 .INIT = 16'h0080;
  defparam \vga/scancode_convert/_not00091 .LOC = "CLB_R12C31.S1";
  X_LUT4 \vga/scancode_convert/_not00091  (
    .ADR0(\vga/ps2/sc_r [2]),
    .ADR1(\vga/scancode_convert/_and0000_0 ),
    .ADR2(\vga/scancode_convert/N10_0 ),
    .ADR3(\vga/ps2/sc_r [1]),
    .O(\vga/scancode_convert/_not0009 )
  );
  defparam \vga/scancode_convert/_not0009/YUSED .LOC = "CLB_R12C31.S1";
  X_BUF \vga/scancode_convert/_not0009/YUSED  (
    .I(\vga/scancode_convert/_not0009 ),
    .O(\vga/scancode_convert/_not0009_0 )
  );
  defparam \vga/rom_addr_char<2>3 .INIT = 16'hC808;
  defparam \vga/rom_addr_char<2>3 .LOC = "CLB_R15C6.S1";
  X_LUT4 \vga/rom_addr_char<2>3  (
    .ADR0(\vga/N6_0 ),
    .ADR1(\vga/rom_addr_char [2]),
    .ADR2(\vga/rom_addr_char_1_1_7 ),
    .ADR3(\vga/N7_0 ),
    .O(\vga/N0112_pack_1 )
  );
  defparam \vga/charload317 .INIT = 16'h4540;
  defparam \vga/charload317 .LOC = "CLB_R15C6.S1";
  X_LUT4 \vga/charload317  (
    .ADR0(\vga/rom_addr_char [4]),
    .ADR1(\vga/N11123_0 ),
    .ADR2(\vga/rom_addr_char [3]),
    .ADR3(\vga/N0112 ),
    .O(\vga/charload3_map953 )
  );
  defparam \vga/N0112/XUSED .LOC = "CLB_R15C6.S1";
  X_BUF \vga/N0112/XUSED  (
    .I(\vga/N0112_pack_1 ),
    .O(\vga/N0112 )
  );
  defparam \vga/N0112/YUSED .LOC = "CLB_R15C6.S1";
  X_BUF \vga/N0112/YUSED  (
    .I(\vga/charload3_map953 ),
    .O(\vga/charload3_map953_0 )
  );
  defparam \vga/rom_addr_char<2>6 .INIT = 16'hC480;
  defparam \vga/rom_addr_char<2>6 .LOC = "CLB_R10C3.S0";
  X_LUT4 \vga/rom_addr_char<2>6  (
    .ADR0(\vga/rom_addr_char_1_1_7 ),
    .ADR1(\vga/rom_addr_char [2]),
    .ADR2(\vga/N222_0 ),
    .ADR3(\vga/N221_0 ),
    .O(\vga/N011234567_pack_1 )
  );
  defparam \vga/rom_addr_char<4>71 .INIT = 16'h0B08;
  defparam \vga/rom_addr_char<4>71 .LOC = "CLB_R10C3.S0";
  X_LUT4 \vga/rom_addr_char<4>71  (
    .ADR0(\vga/N1112_0 ),
    .ADR1(\vga/rom_addr_char [3]),
    .ADR2(\vga/rom_addr_char [4]),
    .ADR3(\vga/N011234567 ),
    .O(\vga/rom_addr_char<4>11234 )
  );
  defparam \vga/N011234567/XUSED .LOC = "CLB_R10C3.S0";
  X_BUF \vga/N011234567/XUSED  (
    .I(\vga/N011234567_pack_1 ),
    .O(\vga/N011234567 )
  );
  defparam \vga/N011234567/YUSED .LOC = "CLB_R10C3.S0";
  X_BUF \vga/N011234567/YUSED  (
    .I(\vga/rom_addr_char<4>11234 ),
    .O(\vga/rom_addr_char<4>11234_0 )
  );
  defparam \vga/charload713 .INIT = 16'hD080;
  defparam \vga/charload713 .LOC = "CLB_R12C4.S0";
  X_LUT4 \vga/charload713  (
    .ADR0(\vga/rom_addr_char [4]),
    .ADR1(\vga/rom_addr_char<3>_f611234_0 ),
    .ADR2(\vga/rom_addr_char [5]),
    .ADR3(\vga/rom_addr_char<3>_f612345_0 ),
    .O(\vga/charload7_map993 )
  );
  defparam \vga/rom_addr_char<4>1 .INIT = 16'hCFC0;
  defparam \vga/rom_addr_char<4>1 .LOC = "CLB_R12C4.S0";
  X_LUT4 \vga/rom_addr_char<4>1  (
    .ADR0(VCC),
    .ADR1(\vga/rom_addr_char<3>_f63_0 ),
    .ADR2(\vga/rom_addr_char [4]),
    .ADR3(\vga/rom_addr_char<3>_f62_0 ),
    .O(\vga/rom_addr_char<4>11_175 )
  );
  defparam \vga/charload7_map993/XUSED .LOC = "CLB_R12C4.S0";
  X_BUF \vga/charload7_map993/XUSED  (
    .I(\vga/charload7_map993 ),
    .O(\vga/charload7_map993_0 )
  );
  defparam \vga/charload7_map993/YUSED .LOC = "CLB_R12C4.S0";
  X_BUF \vga/charload7_map993/YUSED  (
    .I(\vga/rom_addr_char<4>11_175 ),
    .O(\vga/rom_addr_char<4>11_0 )
  );
  defparam \vga/scancode_convert/strobe_out .LOC = "CLB_R13C25.S1";
  defparam \vga/scancode_convert/strobe_out .INIT = 1'b0;
  X_FF \vga/scancode_convert/strobe_out  (
    .I(\vga/scancode_convert/state_FFd2_28 ),
    .CE(\vga/scancode_convert/_not0011_0 ),
    .CLK(gray_cnt_FFd1_0),
    .SET(GND),
    .RST(\vga/scancode_convert/strobe_out/FFY/RST ),
    .O(\vga/scancode_convert/strobe_out_15 )
  );
  defparam \vga/scancode_convert/strobe_out/FFY/RSTOR .LOC = "CLB_R13C25.S1";
  X_INV \vga/scancode_convert/strobe_out/FFY/RSTOR  (
    .I(reset_n_IBUF_0),
    .O(\vga/scancode_convert/strobe_out/FFY/RST )
  );
  defparam \vga/char_rom/Mrom_data3 .INIT = 16'h1201;
  defparam \vga/char_rom/Mrom_data3 .LOC = "CLB_R10C8.S0";
  X_LUT4 \vga/char_rom/Mrom_data3  (
    .ADR0(\vga/vgacore/vcnt_0_1_17 ),
    .ADR1(\vga/rom_addr_char_0_1_18 ),
    .ADR2(\vga/vgacore/vcnt_2_1_9 ),
    .ADR3(\vga/vgacore/vcnt_1_1_8 ),
    .O(\vga/N4_pack_1 )
  );
  defparam \vga/rom_addr_char<2>11 .INIT = 16'h4400;
  defparam \vga/rom_addr_char<2>11 .LOC = "CLB_R10C8.S0";
  X_LUT4 \vga/rom_addr_char<2>11  (
    .ADR0(\vga/rom_addr_char [2]),
    .ADR1(\vga/rom_addr_char_1_1_7 ),
    .ADR2(VCC),
    .ADR3(\vga/N4 ),
    .O(\vga/N1112 )
  );
  defparam \vga/N4/XUSED .LOC = "CLB_R10C8.S0";
  X_BUF \vga/N4/XUSED  (
    .I(\vga/N4_pack_1 ),
    .O(\vga/N4 )
  );
  defparam \vga/N4/YUSED .LOC = "CLB_R10C8.S0";
  X_BUF \vga/N4/YUSED  (
    .I(\vga/N1112 ),
    .O(\vga/N1112_0 )
  );
  defparam \vga/char_rom/Mrom_data7 .INIT = 16'h0843;
  defparam \vga/char_rom/Mrom_data7 .LOC = "CLB_R15C3.S1";
  X_LUT4 \vga/char_rom/Mrom_data7  (
    .ADR0(\vga/vgacore/vcnt_0_1_17 ),
    .ADR1(\vga/rom_addr_char_0_1_18 ),
    .ADR2(\vga/vgacore/vcnt_1_1_8 ),
    .ADR3(\vga/vgacore/vcnt_2_1_9 ),
    .O(\vga/N10 )
  );
  defparam \vga/char_rom/Mrom_data4 .INIT = 16'h0D14;
  defparam \vga/char_rom/Mrom_data4 .LOC = "CLB_R15C3.S1";
  X_LUT4 \vga/char_rom/Mrom_data4  (
    .ADR0(\vga/vgacore/vcnt_1_1_8 ),
    .ADR1(\vga/vgacore/vcnt_2_1_9 ),
    .ADR2(\vga/vgacore/vcnt_0_1_17 ),
    .ADR3(\vga/rom_addr_char_0_1_18 ),
    .O(\vga/N6 )
  );
  defparam \vga/N10/XUSED .LOC = "CLB_R15C3.S1";
  X_BUF \vga/N10/XUSED  (
    .I(\vga/N10 ),
    .O(\vga/N10_0 )
  );
  defparam \vga/N10/YUSED .LOC = "CLB_R15C3.S1";
  X_BUF \vga/N10/YUSED  (
    .I(\vga/N6 ),
    .O(\vga/N6_0 )
  );
  defparam \vga/rom_addr_char<1>113_SW0 .INIT = 16'hCCC0;
  defparam \vga/rom_addr_char<1>113_SW0 .LOC = "CLB_R17C6.S0";
  X_LUT4 \vga/rom_addr_char<1>113_SW0  (
    .ADR0(VCC),
    .ADR1(\vga/rom_addr_char_0_1_18 ),
    .ADR2(\vga/vgacore/vcnt_2_1_9 ),
    .ADR3(\vga/vgacore/vcnt_1_1_8 ),
    .O(N3170)
  );
  defparam \vga/char_rom/Mrom_data5 .INIT = 16'h0040;
  defparam \vga/char_rom/Mrom_data5 .LOC = "CLB_R17C6.S0";
  X_LUT4 \vga/char_rom/Mrom_data5  (
    .ADR0(\vga/vgacore/vcnt_1_1_8 ),
    .ADR1(\vga/vgacore/vcnt_0_1_17 ),
    .ADR2(\vga/vgacore/vcnt_2_1_9 ),
    .ADR3(\vga/rom_addr_char_0_1_18 ),
    .O(\vga/N7 )
  );
  defparam \N3170/XUSED .LOC = "CLB_R17C6.S0";
  X_BUF \N3170/XUSED  (
    .I(N3170),
    .O(N3170_0)
  );
  defparam \N3170/YUSED .LOC = "CLB_R17C6.S0";
  X_BUF \N3170/YUSED  (
    .I(\vga/N7 ),
    .O(\vga/N7_0 )
  );
  defparam \vga/char_rom/Mrom_data6 .INIT = 16'h1050;
  defparam \vga/char_rom/Mrom_data6 .LOC = "CLB_R20C6.S0";
  X_LUT4 \vga/char_rom/Mrom_data6  (
    .ADR0(\vga/rom_addr_char_0_1_18 ),
    .ADR1(\vga/vgacore/vcnt_2_1_9 ),
    .ADR2(\vga/vgacore/vcnt_0_1_17 ),
    .ADR3(\vga/vgacore/vcnt_1_1_8 ),
    .O(\vga/N8_pack_1 )
  );
  defparam \vga/rom_addr_char<2>12 .INIT = 16'h5000;
  defparam \vga/rom_addr_char<2>12 .LOC = "CLB_R20C6.S0";
  X_LUT4 \vga/rom_addr_char<2>12  (
    .ADR0(\vga/rom_addr_char [2]),
    .ADR1(VCC),
    .ADR2(\vga/rom_addr_char_1_1_7 ),
    .ADR3(\vga/N8 ),
    .O(\vga/N11123 )
  );
  defparam \vga/N8/XUSED .LOC = "CLB_R20C6.S0";
  X_BUF \vga/N8/XUSED  (
    .I(\vga/N8_pack_1 ),
    .O(\vga/N8 )
  );
  defparam \vga/N8/YUSED .LOC = "CLB_R20C6.S0";
  X_BUF \vga/N8/YUSED  (
    .I(\vga/N11123 ),
    .O(\vga/N11123_0 )
  );
  defparam \vga/rom_addr_char<1>121_SW0 .INIT = 16'hDFEB;
  defparam \vga/rom_addr_char<1>121_SW0 .LOC = "CLB_R21C3.S1";
  X_LUT4 \vga/rom_addr_char<1>121_SW0  (
    .ADR0(\vga/vgacore/vcnt_2_1_9 ),
    .ADR1(\vga/rom_addr_char [1]),
    .ADR2(\vga/rom_addr_char_0_1_18 ),
    .ADR3(\vga/vgacore/vcnt_1_1_8 ),
    .O(N3160)
  );
  defparam \vga/char_rom/Mrom_data9 .INIT = 16'h0022;
  defparam \vga/char_rom/Mrom_data9 .LOC = "CLB_R21C3.S1";
  X_LUT4 \vga/char_rom/Mrom_data9  (
    .ADR0(\vga/vgacore/vcnt_2_1_9 ),
    .ADR1(\vga/rom_addr_char_0_1_18 ),
    .ADR2(VCC),
    .ADR3(\vga/vgacore/vcnt_1_1_8 ),
    .O(\vga/N12 )
  );
  defparam \N3160/XUSED .LOC = "CLB_R21C3.S1";
  X_BUF \N3160/XUSED  (
    .I(N3160),
    .O(N3160_0)
  );
  defparam \N3160/YUSED .LOC = "CLB_R21C3.S1";
  X_BUF \N3160/YUSED  (
    .I(\vga/N12 ),
    .O(\vga/N12_0 )
  );
  defparam \vga/crt/state_Out911 .INIT = 16'h33FF;
  defparam \vga/crt/state_Out911 .LOC = "CLB_R14C13.S0";
  X_LUT4 \vga/crt/state_Out911  (
    .ADR0(VCC),
    .ADR1(\vga/crt/state_FFd3_11 ),
    .ADR2(VCC),
    .ADR3(\vga/crt/state_FFd2_12 ),
    .O(\vga/crt/N91_pack_1 )
  );
  defparam \vga/crt/_mux0002<6>1 .INIT = 16'h3CAA;
  defparam \vga/crt/_mux0002<6>1 .LOC = "CLB_R14C13.S0";
  X_LUT4 \vga/crt/_mux0002<6>1  (
    .ADR0(\vga/crt_data [6]),
    .ADR1(\vga/crt/cursor_h [5]),
    .ADR2(\vga/crt/cursor_h [6]),
    .ADR3(\vga/crt/N91 ),
    .O(\vga/crt/_mux0002 [6])
  );
  defparam \vga/crt/ram_data<6>/XUSED .LOC = "CLB_R14C13.S0";
  X_BUF \vga/crt/ram_data<6>/XUSED  (
    .I(\vga/crt/N91_pack_1 ),
    .O(\vga/crt/N91 )
  );
  defparam \vga/crt/state_FFd3-In37 .INIT = 16'h2F0F;
  defparam \vga/crt/state_FFd3-In37 .LOC = "CLB_R16C16.S0";
  X_LUT4 \vga/crt/state_FFd3-In37  (
    .ADR0(\vga/crt/write_delay [1]),
    .ADR1(\vga/crt/write_delay [2]),
    .ADR2(\vga/crt/state_FFd1_13 ),
    .ADR3(\vga/crt/write_delay [0]),
    .O(\vga/crt/state_FFd3-In_map800_pack_1 )
  );
  defparam \vga/crt/state_FFd3-In48 .INIT = 16'hF5F0;
  defparam \vga/crt/state_FFd3-In48 .LOC = "CLB_R16C16.S0";
  X_LUT4 \vga/crt/state_FFd3-In48  (
    .ADR0(\vga/crt/state_FFd3_11 ),
    .ADR1(VCC),
    .ADR2(N3144_0),
    .ADR3(\vga/crt/state_FFd3-In_map800 ),
    .O(\vga/crt/state_FFd3-In )
  );
  defparam \vga/crt/state_FFd3/XUSED .LOC = "CLB_R16C16.S0";
  X_BUF \vga/crt/state_FFd3/XUSED  (
    .I(\vga/crt/state_FFd3-In_map800_pack_1 ),
    .O(\vga/crt/state_FFd3-In_map800 )
  );
  defparam \vga/crt/state_FFd3 .LOC = "CLB_R16C16.S0";
  defparam \vga/crt/state_FFd3 .INIT = 1'b0;
  X_FF \vga/crt/state_FFd3  (
    .I(\vga/crt/state_FFd3-In ),
    .CE(VCC),
    .CLK(\vga/crtclk_4 ),
    .SET(GND),
    .RST(\vga/crt/state_FFd3/FFY/RST ),
    .O(\vga/crt/state_FFd3_11 )
  );
  defparam \vga/crt/state_FFd3/FFY/RSTOR .LOC = "CLB_R16C16.S0";
  X_INV \vga/crt/state_FFd3/FFY/RSTOR  (
    .I(reset_n_IBUF_0),
    .O(\vga/crt/state_FFd3/FFY/RST )
  );
  defparam \vga/insert_crt_data1 .INIT = 16'h5050;
  defparam \vga/insert_crt_data1 .LOC = "CLB_R16C18.S0";
  X_LUT4 \vga/insert_crt_data1  (
    .ADR0(\vga/scancode_convert/key_up_14 ),
    .ADR1(VCC),
    .ADR2(\vga/scancode_convert/strobe_out_15 ),
    .ADR3(VCC),
    .O(\vga/insert_crt_data_pack_1 )
  );
  defparam \vga/crt/state_FFd1-In_SW0 .INIT = 16'hA00C;
  defparam \vga/crt/state_FFd1-In_SW0 .LOC = "CLB_R16C18.S0";
  X_LUT4 \vga/crt/state_FFd1-In_SW0  (
    .ADR0(\vga/insert_crt_data ),
    .ADR1(\vga/crt/state_FFd1_13 ),
    .ADR2(\vga/crt/state_FFd3_11 ),
    .ADR3(\vga/crt/state_FFd2_12 ),
    .O(N116)
  );
  defparam \vga/insert_crt_data/XUSED .LOC = "CLB_R16C18.S0";
  X_BUF \vga/insert_crt_data/XUSED  (
    .I(\vga/insert_crt_data_pack_1 ),
    .O(\vga/insert_crt_data )
  );
  defparam \vga/insert_crt_data/YUSED .LOC = "CLB_R16C18.S0";
  X_BUF \vga/insert_crt_data/YUSED  (
    .I(N116),
    .O(N116_0)
  );
  defparam \vga/crt/state_FFd1-In_SW1 .INIT = 16'hF380;
  defparam \vga/crt/state_FFd1-In_SW1 .LOC = "CLB_R16C17.S1";
  X_LUT4 \vga/crt/state_FFd1-In_SW1  (
    .ADR0(\vga/insert_crt_data ),
    .ADR1(\vga/crt/state_FFd2_12 ),
    .ADR2(\vga/crt/state_FFd3_11 ),
    .ADR3(\vga/crt/state_FFd1_13 ),
    .O(N117_pack_1)
  );
  defparam \vga/crt/state_FFd1-In .INIT = 16'hFE02;
  defparam \vga/crt/state_FFd1-In .LOC = "CLB_R16C17.S1";
  X_LUT4 \vga/crt/state_FFd1-In  (
    .ADR0(N116_0),
    .ADR1(\vga/crt/_cmp_eq0001_0 ),
    .ADR2(\vga/crt/newline_20 ),
    .ADR3(N117),
    .O(\vga/crt/state_FFd1-In_176 )
  );
  defparam \vga/crt/state_FFd1/XUSED .LOC = "CLB_R16C17.S1";
  X_BUF \vga/crt/state_FFd1/XUSED  (
    .I(N117_pack_1),
    .O(N117)
  );
  defparam \vga/crt/state_FFd1 .LOC = "CLB_R16C17.S1";
  defparam \vga/crt/state_FFd1 .INIT = 1'b0;
  X_FF \vga/crt/state_FFd1  (
    .I(\vga/crt/state_FFd1-In_176 ),
    .CE(VCC),
    .CLK(\vga/crtclk_4 ),
    .SET(GND),
    .RST(\vga/crt/state_FFd1/FFY/RST ),
    .O(\vga/crt/state_FFd1_13 )
  );
  defparam \vga/crt/state_FFd1/FFY/RSTOR .LOC = "CLB_R16C17.S1";
  X_INV \vga/crt/state_FFd1/FFY/RSTOR  (
    .I(reset_n_IBUF_0),
    .O(\vga/crt/state_FFd1/FFY/RST )
  );
  defparam \vga/crt/_cmp_eq000111 .INIT = 16'h0002;
  defparam \vga/crt/_cmp_eq000111 .LOC = "CLB_R16C16.S1";
  X_LUT4 \vga/crt/_cmp_eq000111  (
    .ADR0(\vga/crt_data [3]),
    .ADR1(\vga/crt_data [5]),
    .ADR2(\vga/crt_data [6]),
    .ADR3(\vga/crt_data [4]),
    .O(\vga/crt/N16_pack_1 )
  );
  defparam \vga/crt/_and0000_SW1 .INIT = 16'hBFFF;
  defparam \vga/crt/_and0000_SW1 .LOC = "CLB_R16C16.S1";
  X_LUT4 \vga/crt/_and0000_SW1  (
    .ADR0(\vga/crt_data [1]),
    .ADR1(\vga/crt/state_FFd1_13 ),
    .ADR2(\vga/crt_data [0]),
    .ADR3(\vga/crt/N16 ),
    .O(N306)
  );
  defparam \vga/crt/N16/XUSED .LOC = "CLB_R16C16.S1";
  X_BUF \vga/crt/N16/XUSED  (
    .I(\vga/crt/N16_pack_1 ),
    .O(\vga/crt/N16 )
  );
  defparam \vga/crt/N16/YUSED .LOC = "CLB_R16C16.S1";
  X_BUF \vga/crt/N16/YUSED  (
    .I(N306),
    .O(N306_0)
  );
  defparam \vga/rom_addr_char<1>/CKINV .LOC = "CLB_R16C1.S0";
  X_INV \vga/rom_addr_char<1>/CKINV  (
    .I(\vga/pclk [2]),
    .O(\vga/rom_addr_char<1>/CKMUXNOT )
  );
  defparam \vga/rom_addr_char_0 .LOC = "CLB_R16C1.S0";
  defparam \vga/rom_addr_char_0 .INIT = 1'b0;
  X_FF \vga/rom_addr_char_0  (
    .I(\vga/ram_data_out [0]),
    .CE(VCC),
    .CLK(\vga/rom_addr_char<1>/CKMUXNOT ),
    .SET(GND),
    .RST(GND),
    .O(\vga/rom_addr_char [0])
  );
  defparam \vga/rom_addr_char<3>/CKINV .LOC = "CLB_R27C1.S0";
  X_INV \vga/rom_addr_char<3>/CKINV  (
    .I(\vga/pclk [2]),
    .O(\vga/rom_addr_char<3>/CKMUXNOT )
  );
  defparam \vga/rom_addr_char_2 .LOC = "CLB_R27C1.S0";
  defparam \vga/rom_addr_char_2 .INIT = 1'b0;
  X_FF \vga/rom_addr_char_2  (
    .I(\vga/ram_data_out [2]),
    .CE(VCC),
    .CLK(\vga/rom_addr_char<3>/CKMUXNOT ),
    .SET(GND),
    .RST(GND),
    .O(\vga/rom_addr_char [2])
  );
  defparam \vga/rom_addr_char<5>/CKINV .LOC = "CLB_R12C1.S0";
  X_INV \vga/rom_addr_char<5>/CKINV  (
    .I(\vga/pclk [2]),
    .O(\vga/rom_addr_char<5>/CKMUXNOT )
  );
  defparam \vga/rom_addr_char_4 .LOC = "CLB_R12C1.S0";
  defparam \vga/rom_addr_char_4 .INIT = 1'b0;
  X_FF \vga/rom_addr_char_4  (
    .I(\vga/ram_data_out [4]),
    .CE(VCC),
    .CLK(\vga/rom_addr_char<5>/CKMUXNOT ),
    .SET(GND),
    .RST(GND),
    .O(\vga/rom_addr_char [4])
  );
  defparam \vga/rom_addr_char<6>/CKINV .LOC = "CLB_R8C1.S0";
  X_INV \vga/rom_addr_char<6>/CKINV  (
    .I(\vga/pclk [2]),
    .O(\vga/rom_addr_char<6>/CKMUXNOT )
  );
  defparam \vga/rom_addr_char_6 .LOC = "CLB_R8C1.S0";
  defparam \vga/rom_addr_char_6 .INIT = 1'b0;
  X_FF \vga/rom_addr_char_6  (
    .I(\vga/ram_data_out [6]),
    .CE(VCC),
    .CLK(\vga/rom_addr_char<6>/CKMUXNOT ),
    .SET(GND),
    .RST(GND),
    .O(\vga/rom_addr_char [6])
  );
  defparam \vga/scancode_convert/scancode_rom/data<0>1158 .INIT = 16'hF4F7;
  defparam \vga/scancode_convert/scancode_rom/data<0>1158 .LOC = "CLB_R15C34.S1";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<0>1158  (
    .ADR0(\vga/scancode_convert/sc [1]),
    .ADR1(\vga/scancode_convert/sc [4]),
    .ADR2(\vga/scancode_convert/sc [3]),
    .ADR3(\vga/scancode_convert/sc [0]),
    .O(\vga/scancode_convert/scancode_rom/data<0>1_map1461 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<0>119 .INIT = 16'hAEEA;
  defparam \vga/scancode_convert/scancode_rom/data<0>119 .LOC = "CLB_R15C34.S1";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<0>119  (
    .ADR0(\vga/scancode_convert/sc [3]),
    .ADR1(\vga/scancode_convert/sc [4]),
    .ADR2(\vga/scancode_convert/sc [0]),
    .ADR3(\vga/scancode_convert/sc [1]),
    .O(\vga/scancode_convert/scancode_rom/data<0>1_map1429 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<0>1_map1461/XUSED .LOC = "CLB_R15C34.S1";
  X_BUF \vga/scancode_convert/scancode_rom/data<0>1_map1461/XUSED  (
    .I(\vga/scancode_convert/scancode_rom/data<0>1_map1461 ),
    .O(\vga/scancode_convert/scancode_rom/data<0>1_map1461_0 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<0>1_map1461/YUSED .LOC = "CLB_R15C34.S1";
  X_BUF \vga/scancode_convert/scancode_rom/data<0>1_map1461/YUSED  (
    .I(\vga/scancode_convert/scancode_rom/data<0>1_map1429 ),
    .O(\vga/scancode_convert/scancode_rom/data<0>1_map1429_0 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<1>101 .INIT = 16'hBBDD;
  defparam \vga/scancode_convert/scancode_rom/data<1>101 .LOC = "CLB_R15C35.S0";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<1>101  (
    .ADR0(\vga/scancode_convert/sc [0]),
    .ADR1(\vga/scancode_convert/sc [1]),
    .ADR2(VCC),
    .ADR3(\vga/scancode_convert/raise ),
    .O(\vga/scancode_convert/scancode_rom/N28 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<0>241 .INIT = 16'hAA55;
  defparam \vga/scancode_convert/scancode_rom/data<0>241 .LOC = "CLB_R15C35.S0";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<0>241  (
    .ADR0(\vga/scancode_convert/sc [1]),
    .ADR1(VCC),
    .ADR2(VCC),
    .ADR3(\vga/scancode_convert/sc [0]),
    .O(\vga/scancode_convert/scancode_rom/N18 )
  );
  defparam \vga/scancode_convert/scancode_rom/N28/XUSED .LOC = "CLB_R15C35.S0";
  X_BUF \vga/scancode_convert/scancode_rom/N28/XUSED  (
    .I(\vga/scancode_convert/scancode_rom/N28 ),
    .O(\vga/scancode_convert/scancode_rom/N28_0 )
  );
  defparam \vga/scancode_convert/scancode_rom/N28/YUSED .LOC = "CLB_R15C35.S0";
  X_BUF \vga/scancode_convert/scancode_rom/N28/YUSED  (
    .I(\vga/scancode_convert/scancode_rom/N18 ),
    .O(\vga/scancode_convert/scancode_rom/N18_0 )
  );
  defparam \vga/scancode_convert/sc_0 .LOC = "CLB_R14C35.S0";
  defparam \vga/scancode_convert/sc_0 .INIT = 1'b0;
  X_FF \vga/scancode_convert/sc_0  (
    .I(\vga/ps2/sc_r [0]),
    .CE(\vga/scancode_convert/_and0000_0 ),
    .CLK(gray_cnt_FFd1_0),
    .SET(GND),
    .RST(GND),
    .O(\vga/scancode_convert/sc [0])
  );
  defparam \vga/scancode_convert/sc_2 .LOC = "CLB_R13C34.S1";
  defparam \vga/scancode_convert/sc_2 .INIT = 1'b0;
  X_FF \vga/scancode_convert/sc_2  (
    .I(\vga/ps2/sc_r [2]),
    .CE(\vga/scancode_convert/_and0000_0 ),
    .CLK(gray_cnt_FFd1_0),
    .SET(GND),
    .RST(GND),
    .O(\vga/scancode_convert/sc [2])
  );
  defparam \vga/scancode_convert/sc_4 .LOC = "CLB_R10C35.S0";
  defparam \vga/scancode_convert/sc_4 .INIT = 1'b0;
  X_FF \vga/scancode_convert/sc_4  (
    .I(\vga/ps2/sc_r [4]),
    .CE(\vga/scancode_convert/_and0000_0 ),
    .CLK(gray_cnt_FFd1_0),
    .SET(GND),
    .RST(GND),
    .O(\vga/scancode_convert/sc [4])
  );
  defparam \vga/scancode_convert/sc_6 .LOC = "CLB_R11C30.S0";
  defparam \vga/scancode_convert/sc_6 .INIT = 1'b0;
  X_FF \vga/scancode_convert/sc_6  (
    .I(\vga/ps2/sc_r [6]),
    .CE(\vga/scancode_convert/_and0000_0 ),
    .CLK(gray_cnt_FFd1_0),
    .SET(GND),
    .RST(GND),
    .O(\vga/scancode_convert/sc [6])
  );
  defparam \vga/ps2/sc_r<1>/FFX/RSTOR .LOC = "CLB_R11C28.S1";
  X_BUF \vga/ps2/sc_r<1>/FFX/RSTOR  (
    .I(\vga/ps2/sc_r<1>/SRMUX_OUTPUTNOT ),
    .O(\vga/ps2/sc_r<1>/FFX/RST )
  );
  defparam \vga/ps2/sc_r_1 .LOC = "CLB_R11C28.S1";
  defparam \vga/ps2/sc_r_1 .INIT = 1'b0;
  X_FF \vga/ps2/sc_r_1  (
    .I(\vga/ps2/sc_r [2]),
    .CE(\vga/ps2/ps2_clk_fall_edge_0 ),
    .CLK(gray_cnt_FFd1_0),
    .SET(GND),
    .RST(\vga/ps2/sc_r<1>/FFX/RST ),
    .O(\vga/ps2/sc_r [1])
  );
  defparam \vga/ps2/sc_r<1>/SRMUX .LOC = "CLB_R11C28.S1";
  X_INV \vga/ps2/sc_r<1>/SRMUX  (
    .I(reset_n_IBUF_0),
    .O(\vga/ps2/sc_r<1>/SRMUX_OUTPUTNOT )
  );
  defparam \vga/ps2/sc_r_0 .LOC = "CLB_R11C28.S1";
  defparam \vga/ps2/sc_r_0 .INIT = 1'b0;
  X_FF \vga/ps2/sc_r_0  (
    .I(\vga/ps2/sc_r [1]),
    .CE(\vga/ps2/ps2_clk_fall_edge_0 ),
    .CLK(gray_cnt_FFd1_0),
    .SET(GND),
    .RST(\vga/ps2/sc_r<1>/FFY/RST ),
    .O(\vga/ps2/sc_r [0])
  );
  defparam \vga/ps2/sc_r<1>/FFY/RSTOR .LOC = "CLB_R11C28.S1";
  X_BUF \vga/ps2/sc_r<1>/FFY/RSTOR  (
    .I(\vga/ps2/sc_r<1>/SRMUX_OUTPUTNOT ),
    .O(\vga/ps2/sc_r<1>/FFY/RST )
  );
  defparam \vga/ps2/sc_r<3>/FFX/RSTOR .LOC = "CLB_R11C29.S1";
  X_BUF \vga/ps2/sc_r<3>/FFX/RSTOR  (
    .I(\vga/ps2/sc_r<3>/SRMUX_OUTPUTNOT ),
    .O(\vga/ps2/sc_r<3>/FFX/RST )
  );
  defparam \vga/ps2/sc_r_3 .LOC = "CLB_R11C29.S1";
  defparam \vga/ps2/sc_r_3 .INIT = 1'b0;
  X_FF \vga/ps2/sc_r_3  (
    .I(\vga/ps2/sc_r [4]),
    .CE(\vga/ps2/ps2_clk_fall_edge_0 ),
    .CLK(gray_cnt_FFd1_0),
    .SET(GND),
    .RST(\vga/ps2/sc_r<3>/FFX/RST ),
    .O(\vga/ps2/sc_r [3])
  );
  defparam \vga/ps2/sc_r<3>/SRMUX .LOC = "CLB_R11C29.S1";
  X_INV \vga/ps2/sc_r<3>/SRMUX  (
    .I(reset_n_IBUF_0),
    .O(\vga/ps2/sc_r<3>/SRMUX_OUTPUTNOT )
  );
  defparam \vga/ps2/sc_r_2 .LOC = "CLB_R11C29.S1";
  defparam \vga/ps2/sc_r_2 .INIT = 1'b0;
  X_FF \vga/ps2/sc_r_2  (
    .I(\vga/ps2/sc_r [3]),
    .CE(\vga/ps2/ps2_clk_fall_edge_0 ),
    .CLK(gray_cnt_FFd1_0),
    .SET(GND),
    .RST(\vga/ps2/sc_r<3>/FFY/RST ),
    .O(\vga/ps2/sc_r [2])
  );
  defparam \vga/ps2/sc_r<3>/FFY/RSTOR .LOC = "CLB_R11C29.S1";
  X_BUF \vga/ps2/sc_r<3>/FFY/RSTOR  (
    .I(\vga/ps2/sc_r<3>/SRMUX_OUTPUTNOT ),
    .O(\vga/ps2/sc_r<3>/FFY/RST )
  );
  defparam \vga/ps2/sc_r<5>/FFX/RSTOR .LOC = "CLB_R10C28.S1";
  X_BUF \vga/ps2/sc_r<5>/FFX/RSTOR  (
    .I(\vga/ps2/sc_r<5>/SRMUX_OUTPUTNOT ),
    .O(\vga/ps2/sc_r<5>/FFX/RST )
  );
  defparam \vga/ps2/sc_r_5 .LOC = "CLB_R10C28.S1";
  defparam \vga/ps2/sc_r_5 .INIT = 1'b0;
  X_FF \vga/ps2/sc_r_5  (
    .I(\vga/ps2/sc_r [6]),
    .CE(\vga/ps2/ps2_clk_fall_edge_0 ),
    .CLK(gray_cnt_FFd1_0),
    .SET(GND),
    .RST(\vga/ps2/sc_r<5>/FFX/RST ),
    .O(\vga/ps2/sc_r [5])
  );
  defparam \vga/ps2/sc_r<5>/SRMUX .LOC = "CLB_R10C28.S1";
  X_INV \vga/ps2/sc_r<5>/SRMUX  (
    .I(reset_n_IBUF_0),
    .O(\vga/ps2/sc_r<5>/SRMUX_OUTPUTNOT )
  );
  defparam \vga/ps2/sc_r_4 .LOC = "CLB_R10C28.S1";
  defparam \vga/ps2/sc_r_4 .INIT = 1'b0;
  X_FF \vga/ps2/sc_r_4  (
    .I(\vga/ps2/sc_r [5]),
    .CE(\vga/ps2/ps2_clk_fall_edge_0 ),
    .CLK(gray_cnt_FFd1_0),
    .SET(GND),
    .RST(\vga/ps2/sc_r<5>/FFY/RST ),
    .O(\vga/ps2/sc_r [4])
  );
  defparam \vga/ps2/sc_r<5>/FFY/RSTOR .LOC = "CLB_R10C28.S1";
  X_BUF \vga/ps2/sc_r<5>/FFY/RSTOR  (
    .I(\vga/ps2/sc_r<5>/SRMUX_OUTPUTNOT ),
    .O(\vga/ps2/sc_r<5>/FFY/RST )
  );
  defparam \vga/ps2/sc_r<7>/FFX/RSTOR .LOC = "CLB_R10C28.S0";
  X_BUF \vga/ps2/sc_r<7>/FFX/RSTOR  (
    .I(\vga/ps2/sc_r<7>/SRMUX_OUTPUTNOT ),
    .O(\vga/ps2/sc_r<7>/FFX/RST )
  );
  defparam \vga/ps2/sc_r_7 .LOC = "CLB_R10C28.S0";
  defparam \vga/ps2/sc_r_7 .INIT = 1'b0;
  X_FF \vga/ps2/sc_r_7  (
    .I(\vga/ps2/sc_r [8]),
    .CE(\vga/ps2/ps2_clk_fall_edge_0 ),
    .CLK(gray_cnt_FFd1_0),
    .SET(GND),
    .RST(\vga/ps2/sc_r<7>/FFX/RST ),
    .O(\vga/ps2/sc_r [7])
  );
  defparam \vga/ps2/sc_r<7>/SRMUX .LOC = "CLB_R10C28.S0";
  X_INV \vga/ps2/sc_r<7>/SRMUX  (
    .I(reset_n_IBUF_0),
    .O(\vga/ps2/sc_r<7>/SRMUX_OUTPUTNOT )
  );
  defparam \vga/ps2/sc_r_6 .LOC = "CLB_R10C28.S0";
  defparam \vga/ps2/sc_r_6 .INIT = 1'b0;
  X_FF \vga/ps2/sc_r_6  (
    .I(\vga/ps2/sc_r [7]),
    .CE(\vga/ps2/ps2_clk_fall_edge_0 ),
    .CLK(gray_cnt_FFd1_0),
    .SET(GND),
    .RST(\vga/ps2/sc_r<7>/FFY/RST ),
    .O(\vga/ps2/sc_r [6])
  );
  defparam \vga/ps2/sc_r<7>/FFY/RSTOR .LOC = "CLB_R10C28.S0";
  X_BUF \vga/ps2/sc_r<7>/FFY/RSTOR  (
    .I(\vga/ps2/sc_r<7>/SRMUX_OUTPUTNOT ),
    .O(\vga/ps2/sc_r<7>/FFY/RST )
  );
  defparam \vga/ps2/sc_r_8 .LOC = "CLB_R9C7.S1";
  defparam \vga/ps2/sc_r_8 .INIT = 1'b0;
  X_FF \vga/ps2/sc_r_8  (
    .I(\vga/ps2/sc_r [9]),
    .CE(\vga/ps2/ps2_clk_fall_edge_0 ),
    .CLK(gray_cnt_FFd1_0),
    .SET(GND),
    .RST(\vga/ps2/sc_r<8>/FFY/RST ),
    .O(\vga/ps2/sc_r [8])
  );
  defparam \vga/ps2/sc_r<8>/FFY/RSTOR .LOC = "CLB_R9C7.S1";
  X_INV \vga/ps2/sc_r<8>/FFY/RSTOR  (
    .I(reset_n_IBUF_0),
    .O(\vga/ps2/sc_r<8>/FFY/RST )
  );
  defparam \vga/scancode_convert/scancode_rom/data<5>327 .INIT = 16'h0288;
  defparam \vga/scancode_convert/scancode_rom/data<5>327 .LOC = "CLB_R12C34.S1";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<5>327  (
    .ADR0(\vga/scancode_convert/sc [4]),
    .ADR1(\vga/scancode_convert/sc_1_1_23 ),
    .ADR2(\vga/scancode_convert/raise1_33 ),
    .ADR3(\vga/scancode_convert/sc_0_1_10 ),
    .O(\vga/scancode_convert/scancode_rom/data<5>3_map1245 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<5>341 .INIT = 16'hFF0C;
  defparam \vga/scancode_convert/scancode_rom/data<5>341 .LOC = "CLB_R12C34.S1";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<5>341  (
    .ADR0(VCC),
    .ADR1(\vga/scancode_convert/sc_1_1_23 ),
    .ADR2(\vga/scancode_convert/sc_0_1_10 ),
    .ADR3(\vga/scancode_convert/sc [4]),
    .O(\vga/scancode_convert/scancode_rom/data<5>3_map1249 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<5>3_map1245/XUSED .LOC = "CLB_R12C34.S1";
  X_BUF \vga/scancode_convert/scancode_rom/data<5>3_map1245/XUSED  (
    .I(\vga/scancode_convert/scancode_rom/data<5>3_map1245 ),
    .O(\vga/scancode_convert/scancode_rom/data<5>3_map1245_0 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<5>3_map1245/YUSED .LOC = "CLB_R12C34.S1";
  X_BUF \vga/scancode_convert/scancode_rom/data<5>3_map1245/YUSED  (
    .I(\vga/scancode_convert/scancode_rom/data<5>3_map1249 ),
    .O(\vga/scancode_convert/scancode_rom/data<5>3_map1249_0 )
  );
  defparam \vga/vgacore/vcnt_Eqn_3_SW0 .INIT = 16'hEAEA;
  defparam \vga/vgacore/vcnt_Eqn_3_SW0 .LOC = "CLB_R17C10.S0";
  X_LUT4 \vga/vgacore/vcnt_Eqn_3_SW0  (
    .ADR0(\vga/vgacore/vcnt [2]),
    .ADR1(\vga/vgacore/vcnt [0]),
    .ADR2(\vga/vgacore/vcnt [1]),
    .ADR3(VCC),
    .O(N786)
  );
  defparam \N786/YUSED .LOC = "CLB_R17C10.S0";
  X_BUF \N786/YUSED  (
    .I(N786),
    .O(N786_0)
  );
  defparam \vga/vgacore/vcnt_Eqn_bis_021_SW0 .INIT = 16'hFFFE;
  defparam \vga/vgacore/vcnt_Eqn_bis_021_SW0 .LOC = "CLB_R15C9.S0";
  X_LUT4 \vga/vgacore/vcnt_Eqn_bis_021_SW0  (
    .ADR0(\vga/vgacore/vcnt [7]),
    .ADR1(\vga/vgacore/vcnt [6]),
    .ADR2(\vga/vgacore/vcnt [5]),
    .ADR3(\vga/vgacore/vcnt [4]),
    .O(N3108)
  );
  defparam \vga/_and0000129 .INIT = 16'h8241;
  defparam \vga/_and0000129 .LOC = "CLB_R15C9.S0";
  X_LUT4 \vga/_and0000129  (
    .ADR0(\vga/crt/cursor_v [1]),
    .ADR1(\vga/crt/cursor_v [0]),
    .ADR2(\vga/vgacore/vcnt [3]),
    .ADR3(\vga/vgacore/vcnt [4]),
    .O(\vga/_and0000_map918 )
  );
  defparam \N3108/XUSED .LOC = "CLB_R15C9.S0";
  X_BUF \N3108/XUSED  (
    .I(N3108),
    .O(N3108_0)
  );
  defparam \N3108/YUSED .LOC = "CLB_R15C9.S0";
  X_BUF \N3108/YUSED  (
    .I(\vga/_and0000_map918 ),
    .O(\vga/_and0000_map918_0 )
  );
  defparam \vga/scancode_convert/_or00001 .INIT = 16'hFFAA;
  defparam \vga/scancode_convert/_or00001 .LOC = "CLB_R13C30.S0";
  X_LUT4 \vga/scancode_convert/_or00001  (
    .ADR0(\vga/scancode_convert/state_FFd3_29 ),
    .ADR1(VCC),
    .ADR2(VCC),
    .ADR3(\vga/scancode_convert/state_FFd2_28 ),
    .O(\vga/scancode_convert/_or0000 )
  );
  defparam \vga/scancode_convert/_or0000/YUSED .LOC = "CLB_R13C30.S0";
  X_BUF \vga/scancode_convert/_or0000/YUSED  (
    .I(\vga/scancode_convert/_or0000 ),
    .O(\vga/scancode_convert/_or0000_0 )
  );
  defparam \vga/charload6111 .INIT = 16'hD888;
  defparam \vga/charload6111 .LOC = "CLB_R13C9.S1";
  X_LUT4 \vga/charload6111  (
    .ADR0(\vga/rom_addr_char [6]),
    .ADR1(\vga/rom_addr_char<5>_f512_0 ),
    .ADR2(\vga/charload6_map1018_0 ),
    .ADR3(\vga/rom_addr_char [5]),
    .O(\vga/charload6_map1022_pack_1 )
  );
  defparam \vga/charload6153 .INIT = 16'hEEE2;
  defparam \vga/charload6153 .LOC = "CLB_R13C9.S1";
  X_LUT4 \vga/charload6153  (
    .ADR0(\vga/pixel_hold [3]),
    .ADR1(\vga/charload_19 ),
    .ADR2(\vga/cursor_match_0 ),
    .ADR3(\vga/charload6_map1022 ),
    .O(\vga/_mux0002 [3])
  );
  defparam \vga/pixel_hold<4>/XUSED .LOC = "CLB_R13C9.S1";
  X_BUF \vga/pixel_hold<4>/XUSED  (
    .I(\vga/charload6_map1022_pack_1 ),
    .O(\vga/charload6_map1022 )
  );
  defparam \vga/pixel_hold_4 .LOC = "CLB_R13C9.S1";
  defparam \vga/pixel_hold_4 .INIT = 1'b0;
  X_FF \vga/pixel_hold_4  (
    .I(\vga/_mux0002 [3]),
    .CE(VCC),
    .CLK(gray_cnt_FFd1_0),
    .SET(GND),
    .RST(GND),
    .O(\vga/pixel_hold [4])
  );
  defparam \vga/_and0000156 .INIT = 16'h9009;
  defparam \vga/_and0000156 .LOC = "CLB_R15C10.S0";
  X_LUT4 \vga/_and0000156  (
    .ADR0(\vga/crt/cursor_v [3]),
    .ADR1(\vga/vgacore/vcnt [6]),
    .ADR2(\vga/crt/cursor_v [2]),
    .ADR3(\vga/vgacore/vcnt [5]),
    .O(\vga/_and0000_map929 )
  );
  defparam \vga/_and0000_map929/YUSED .LOC = "CLB_R15C10.S0";
  X_BUF \vga/_and0000_map929/YUSED  (
    .I(\vga/_and0000_map929 ),
    .O(\vga/_and0000_map929_0 )
  );
  defparam \vga/pixelData<0>/LOGIC_ONE .LOC = "CLB_R12C8.S1";
  X_ONE \vga/pixelData<0>/LOGIC_ONE  (
    .O(\vga/pixelData<0>/LOGIC_ONE_177 )
  );
  defparam \vga/pixelData<0>/SRMUX .LOC = "CLB_R12C8.S1";
  X_INV \vga/pixelData<0>/SRMUX  (
    .I(\vga/pixel_hold [7]),
    .O(\vga/pixelData<0>/SRMUX_OUTPUTNOT )
  );
  defparam \vga/pixelData_0 .LOC = "CLB_R12C8.S1";
  defparam \vga/pixelData_0 .INIT = 1'b0;
  X_SFF \vga/pixelData_0  (
    .I(\vga/pixelData<0>/LOGIC_ONE_177 ),
    .CE(VCC),
    .CLK(gray_cnt_FFd1_0),
    .SET(GND),
    .RST(GND),
    .SSET(GND),
    .SRST(\vga/pixelData<0>/SRMUX_OUTPUTNOT ),
    .O(\vga/pixelData [0])
  );
  defparam \vga/ps2/_cmp_eq000112 .INIT = 16'h000F;
  defparam \vga/ps2/_cmp_eq000112 .LOC = "CLB_R6C17.S1";
  X_LUT4 \vga/ps2/_cmp_eq000112  (
    .ADR0(VCC),
    .ADR1(VCC),
    .ADR2(\vga/ps2/timer_r [12]),
    .ADR3(\vga/ps2/timer_r [13]),
    .O(\vga/ps2/_cmp_eq0001_map1035 )
  );
  defparam \vga/ps2/_cmp_eq0001_map1035/YUSED .LOC = "CLB_R6C17.S1";
  X_BUF \vga/ps2/_cmp_eq0001_map1035/YUSED  (
    .I(\vga/ps2/_cmp_eq0001_map1035 ),
    .O(\vga/ps2/_cmp_eq0001_map1035_0 )
  );
  defparam \vga/_and0000183 .INIT = 16'h8241;
  defparam \vga/_and0000183 .LOC = "CLB_R13C10.S0";
  X_LUT4 \vga/_and0000183  (
    .ADR0(\vga/crt/cursor_v [4]),
    .ADR1(\vga/vgacore/vcnt [8]),
    .ADR2(\vga/crt/cursor_v [5]),
    .ADR3(\vga/vgacore/vcnt [7]),
    .O(\vga/_and0000_map940 )
  );
  defparam \vga/_and0000_map940/YUSED .LOC = "CLB_R13C10.S0";
  X_BUF \vga/_and0000_map940/YUSED  (
    .I(\vga/_and0000_map940 ),
    .O(\vga/_and0000_map940_0 )
  );
  defparam \vga/_and0000184 .INIT = 16'hCC00;
  defparam \vga/_and0000184 .LOC = "CLB_R14C10.S0";
  X_LUT4 \vga/_and0000184  (
    .ADR0(VCC),
    .ADR1(\vga/_and0000_map940_0 ),
    .ADR2(VCC),
    .ADR3(\vga/_and0000_map929_0 ),
    .O(\vga/_and0000_map941_pack_1 )
  );
  defparam \vga/_and0000215 .INIT = 16'h8200;
  defparam \vga/_and0000215 .LOC = "CLB_R14C10.S0";
  X_LUT4 \vga/_and0000215  (
    .ADR0(\vga/_and0000_map918_0 ),
    .ADR1(\vga/vgacore/hcnt [9]),
    .ADR2(\vga/crt/cursor_h [6]),
    .ADR3(\vga/_and0000_map941 ),
    .O(\vga/_and0000_map943 )
  );
  defparam \vga/_and0000_map941/XUSED .LOC = "CLB_R14C10.S0";
  X_BUF \vga/_and0000_map941/XUSED  (
    .I(\vga/_and0000_map941_pack_1 ),
    .O(\vga/_and0000_map941 )
  );
  defparam \vga/_and0000_map941/YUSED .LOC = "CLB_R14C10.S0";
  X_BUF \vga/_and0000_map941/YUSED  (
    .I(\vga/_and0000_map943 ),
    .O(\vga/_and0000_map943_0 )
  );
  defparam \vga/ps2/_cmp_eq000130 .INIT = 16'h0200;
  defparam \vga/ps2/_cmp_eq000130 .LOC = "CLB_R7C17.S1";
  X_LUT4 \vga/ps2/_cmp_eq000130  (
    .ADR0(\vga/ps2/timer_r [11]),
    .ADR1(\vga/ps2/timer_r [10]),
    .ADR2(\vga/ps2/timer_r [9]),
    .ADR3(\vga/ps2/timer_r [8]),
    .O(\vga/ps2/_cmp_eq0001_map1041 )
  );
  defparam \vga/ps2/_cmp_eq0001_map1041/YUSED .LOC = "CLB_R7C17.S1";
  X_BUF \vga/ps2/_cmp_eq0001_map1041/YUSED  (
    .I(\vga/ps2/_cmp_eq0001_map1041 ),
    .O(\vga/ps2/_cmp_eq0001_map1041_0 )
  );
  defparam \vga/rom_addr_char_0_1/CKINV .LOC = "CLB_R16C1.S1";
  X_INV \vga/rom_addr_char_0_1/CKINV  (
    .I(\vga/pclk [2]),
    .O(\vga/rom_addr_char_0_1/CKMUXNOT )
  );
  defparam \vga/rom_addr_char_0_1 .LOC = "CLB_R16C1.S1";
  defparam \vga/rom_addr_char_0_1 .INIT = 1'b0;
  X_FF \vga/rom_addr_char_0_1  (
    .I(\vga/ram_data_out [0]),
    .CE(VCC),
    .CLK(\vga/rom_addr_char_0_1/CKMUXNOT ),
    .SET(GND),
    .RST(GND),
    .O(\vga/rom_addr_char_0_1_18 )
  );
  defparam \vga/rom_addr_char_1_1/CKINV .LOC = "CLB_R17C1.S1";
  X_INV \vga/rom_addr_char_1_1/CKINV  (
    .I(\vga/pclk [2]),
    .O(\vga/rom_addr_char_1_1/CKMUXNOT )
  );
  defparam \vga/rom_addr_char_1_1 .LOC = "CLB_R17C1.S1";
  defparam \vga/rom_addr_char_1_1 .INIT = 1'b0;
  X_FF \vga/rom_addr_char_1_1  (
    .I(\vga/ram_data_out [1]),
    .CE(VCC),
    .CLK(\vga/rom_addr_char_1_1/CKMUXNOT ),
    .SET(GND),
    .RST(GND),
    .O(\vga/rom_addr_char_1_1_7 )
  );
  defparam \vga/ps2/_cmp_eq000156 .INIT = 16'h8000;
  defparam \vga/ps2/_cmp_eq000156 .LOC = "CLB_R8C18.S0";
  X_LUT4 \vga/ps2/_cmp_eq000156  (
    .ADR0(\vga/ps2/_cmp_eq0001_map1047_0 ),
    .ADR1(\vga/ps2/_cmp_eq0001_map1041_0 ),
    .ADR2(\vga/ps2/_cmp_eq0001_map1032_0 ),
    .ADR3(\vga/ps2/_cmp_eq0001_map1035_0 ),
    .O(\vga/ps2/_cmp_eq0001_pack_1 )
  );
  defparam \vga/ps2/scancode_rdy1 .INIT = 16'hA000;
  defparam \vga/ps2/scancode_rdy1 .LOC = "CLB_R8C18.S0";
  X_LUT4 \vga/ps2/scancode_rdy1  (
    .ADR0(\vga/ps2/ps2_clk_r [1]),
    .ADR1(VCC),
    .ADR2(\vga/ps2/_cmp_eq0000_0 ),
    .ADR3(\vga/ps2/_cmp_eq0001 ),
    .O(\vga/ps2/scancode_rdy )
  );
  defparam \vga/ps2/rdy_r/XUSED .LOC = "CLB_R8C18.S0";
  X_BUF \vga/ps2/rdy_r/XUSED  (
    .I(\vga/ps2/_cmp_eq0001_pack_1 ),
    .O(\vga/ps2/_cmp_eq0001 )
  );
  defparam \vga/ps2/rdy_r .LOC = "CLB_R8C18.S0";
  defparam \vga/ps2/rdy_r .INIT = 1'b0;
  X_FF \vga/ps2/rdy_r  (
    .I(\vga/ps2/scancode_rdy ),
    .CE(VCC),
    .CLK(gray_cnt_FFd1_0),
    .SET(GND),
    .RST(\vga/ps2/rdy_r/FFY/RST ),
    .O(\vga/ps2/rdy_r_1 )
  );
  defparam \vga/ps2/rdy_r/FFY/RSTOR .LOC = "CLB_R8C18.S0";
  X_INV \vga/ps2/rdy_r/FFY/RSTOR  (
    .I(reset_n_IBUF_0),
    .O(\vga/ps2/rdy_r/FFY/RST )
  );
  defparam \vga/crt/_cmp_eq00011 .INIT = 16'h0020;
  defparam \vga/crt/_cmp_eq00011 .LOC = "CLB_R16C17.S0";
  X_LUT4 \vga/crt/_cmp_eq00011  (
    .ADR0(\vga/crt/N16 ),
    .ADR1(\vga/crt_data [0]),
    .ADR2(\vga/crt_data [1]),
    .ADR3(\vga/crt_data [2]),
    .O(\vga/crt/_cmp_eq0001 )
  );
  defparam \vga/crt/_cmp_eq0001/YUSED .LOC = "CLB_R16C17.S0";
  X_BUF \vga/crt/_cmp_eq0001/YUSED  (
    .I(\vga/crt/_cmp_eq0001 ),
    .O(\vga/crt/_cmp_eq0001_0 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<0>14 .INIT = 16'h8000;
  defparam \vga/scancode_convert/scancode_rom/data<0>14 .LOC = "CLB_R15C33.S1";
  X_LUT4 \vga/scancode_convert/scancode_rom/data<0>14  (
    .ADR0(\vga/scancode_convert/sc [3]),
    .ADR1(\vga/scancode_convert/sc [4]),
    .ADR2(\vga/scancode_convert/sc [0]),
    .ADR3(\vga/scancode_convert/sc [1]),
    .O(\vga/scancode_convert/scancode_rom/data<0>1_map1423 )
  );
  defparam \vga/scancode_convert/scancode_rom/data<0>1_map1423/YUSED .LOC = "CLB_R15C33.S1";
  X_BUF \vga/scancode_convert/scancode_rom/data<0>1_map1423/YUSED  (
    .I(\vga/scancode_convert/scancode_rom/data<0>1_map1423 ),
    .O(\vga/scancode_convert/scancode_rom/data<0>1_map1423_0 )
  );
  defparam \vga/vgacore/_and000015_SW0 .INIT = 16'h0055;
  defparam \vga/vgacore/_and000015_SW0 .LOC = "CLB_R15C8.S1";
  X_LUT4 \vga/vgacore/_and000015_SW0  (
    .ADR0(\vga/vgacore/hcnt [6]),
    .ADR1(VCC),
    .ADR2(VCC),
    .ADR3(\vga/vgacore/hcnt [5]),
    .O(N3132)
  );
  defparam \vga/vgacore/_and000033 .INIT = 16'h0010;
  defparam \vga/vgacore/_and000033 .LOC = "CLB_R15C8.S1";
  X_LUT4 \vga/vgacore/_and000033  (
    .ADR0(\vga/vgacore/hcnt [5]),
    .ADR1(\vga/vgacore/hcnt [7]),
    .ADR2(\vga/vgacore/hcnt [8]),
    .ADR3(\vga/vgacore/hcnt [6]),
    .O(\vga/vgacore/_and0000_map817 )
  );
  defparam \N3132/XUSED .LOC = "CLB_R15C8.S1";
  X_BUF \N3132/XUSED  (
    .I(N3132),
    .O(N3132_0)
  );
  defparam \N3132/YUSED .LOC = "CLB_R15C8.S1";
  X_BUF \N3132/YUSED  (
    .I(\vga/vgacore/_and0000_map817 ),
    .O(\vga/vgacore/_and0000_map817_0 )
  );
  defparam \vga/_and000026 .INIT = 16'h8421;
  defparam \vga/_and000026 .LOC = "CLB_R17C8.S1";
  X_LUT4 \vga/_and000026  (
    .ADR0(\vga/vgacore/hcnt [3]),
    .ADR1(\vga/vgacore/hcnt [4]),
    .ADR2(\vga/crt/cursor_h [0]),
    .ADR3(\vga/crt/cursor_h [1]),
    .O(\vga/_and0000_map879 )
  );
  defparam \vga/vgacore/_and000046 .INIT = 16'h0001;
  defparam \vga/vgacore/_and000046 .LOC = "CLB_R17C8.S1";
  X_LUT4 \vga/vgacore/_and000046  (
    .ADR0(\vga/vgacore/hcnt [1]),
    .ADR1(\vga/vgacore/hcnt [4]),
    .ADR2(\vga/vgacore/hcnt [2]),
    .ADR3(\vga/vgacore/hcnt [3]),
    .O(\vga/vgacore/_and0000_map824 )
  );
  defparam \vga/_and0000_map879/XUSED .LOC = "CLB_R17C8.S1";
  X_BUF \vga/_and0000_map879/XUSED  (
    .I(\vga/_and0000_map879 ),
    .O(\vga/_and0000_map879_0 )
  );
  defparam \vga/_and0000_map879/YUSED .LOC = "CLB_R17C8.S1";
  X_BUF \vga/_and0000_map879/YUSED  (
    .I(\vga/vgacore/_and0000_map824 ),
    .O(\vga/vgacore/_and0000_map824_0 )
  );
  defparam \vga/vgacore/_and000047 .INIT = 16'h8888;
  defparam \vga/vgacore/_and000047 .LOC = "CLB_R16C8.S0";
  X_LUT4 \vga/vgacore/_and000047  (
    .ADR0(\vga/vgacore/_and0000_map824_0 ),
    .ADR1(\vga/vgacore/_and0000_map817_0 ),
    .ADR2(VCC),
    .ADR3(VCC),
    .O(\vga/vgacore/_and0000_map825_pack_1 )
  );
  defparam \vga/vgacore/_and000074 .INIT = 16'h4440;
  defparam \vga/vgacore/_and000074 .LOC = "CLB_R16C8.S0";
  X_LUT4 \vga/vgacore/_and000074  (
    .ADR0(\vga/vgacore/hcnt [10]),
    .ADR1(\vga/vgacore/hcnt [9]),
    .ADR2(\vga/vgacore/_and0000_map811_0 ),
    .ADR3(\vga/vgacore/_and0000_map825 ),
    .O(\vga/vgacore/_and0000 )
  );
  defparam \vga/vgacore/hsync/XUSED .LOC = "CLB_R16C8.S0";
  X_BUF \vga/vgacore/hsync/XUSED  (
    .I(\vga/vgacore/_and0000_map825_pack_1 ),
    .O(\vga/vgacore/_and0000_map825 )
  );
  defparam \vga/vgacore/hsync .LOC = "CLB_R16C8.S0";
  defparam \vga/vgacore/hsync .INIT = 1'b0;
  X_FF \vga/vgacore/hsync  (
    .I(\vga/vgacore/_and0000 ),
    .CE(VCC),
    .CLK(gray_cnt_FFd1_0),
    .SET(GND),
    .RST(\vga/vgacore/hsync/FFY/RST ),
    .O(\vga/vgacore/hsync_3 )
  );
  defparam \vga/vgacore/hsync/FFY/RSTOR .LOC = "CLB_R16C8.S0";
  X_INV \vga/vgacore/hsync/FFY/RSTOR  (
    .I(reset_n_IBUF_0),
    .O(\vga/vgacore/hsync/FFY/RST )
  );
  defparam \vga/charload513 .INIT = 16'hE040;
  defparam \vga/charload513 .LOC = "CLB_R20C7.S0";
  X_LUT4 \vga/charload513  (
    .ADR0(\vga/rom_addr_char [4]),
    .ADR1(\vga/rom_addr_char<3>_f6123_0 ),
    .ADR2(\vga/rom_addr_char [5]),
    .ADR3(\vga/rom_addr_char<3>_f6112_0 ),
    .O(\vga/charload5_map965 )
  );
  defparam \vga/charload413 .INIT = 16'hAC00;
  defparam \vga/charload413 .LOC = "CLB_R20C7.S0";
  X_LUT4 \vga/charload413  (
    .ADR0(\vga/rom_addr_char<3>_f611_0 ),
    .ADR1(\vga/rom_addr_char<3>_f612_0 ),
    .ADR2(\vga/rom_addr_char [4]),
    .ADR3(\vga/rom_addr_char [5]),
    .O(\vga/charload4_map979 )
  );
  defparam \vga/charload5_map965/XUSED .LOC = "CLB_R20C7.S0";
  X_BUF \vga/charload5_map965/XUSED  (
    .I(\vga/charload5_map965 ),
    .O(\vga/charload5_map965_0 )
  );
  defparam \vga/charload5_map965/YUSED .LOC = "CLB_R20C7.S0";
  X_BUF \vga/charload5_map965/YUSED  (
    .I(\vga/charload4_map979 ),
    .O(\vga/charload4_map979_0 )
  );
  defparam \vga/rom_addr_char<1>152_SW0 .INIT = 16'h2277;
  defparam \vga/rom_addr_char<1>152_SW0 .LOC = "CLB_R13C7.S1";
  X_LUT4 \vga/rom_addr_char<1>152_SW0  (
    .ADR0(\vga/rom_addr_char [1]),
    .ADR1(\vga/rom_addr_char_0_1_18 ),
    .ADR2(VCC),
    .ADR3(\vga/vgacore/vcnt_1_1_8 ),
    .O(N3172)
  );
  defparam \vga/rom_addr_char<1>104_SW0 .INIT = 16'h88AA;
  defparam \vga/rom_addr_char<1>104_SW0 .LOC = "CLB_R13C7.S1";
  X_LUT4 \vga/rom_addr_char<1>104_SW0  (
    .ADR0(\vga/rom_addr_char [1]),
    .ADR1(\vga/vgacore/vcnt_0_1_17 ),
    .ADR2(VCC),
    .ADR3(\vga/rom_addr_char_0_1_18 ),
    .O(N3148)
  );
  defparam \N3172/XUSED .LOC = "CLB_R13C7.S1";
  X_BUF \N3172/XUSED  (
    .I(N3172),
    .O(N3172_0)
  );
  defparam \N3172/YUSED .LOC = "CLB_R13C7.S1";
  X_BUF \N3172/YUSED  (
    .I(N3148),
    .O(N3148_0)
  );
  defparam \vga/_and000053 .INIT = 16'h9009;
  defparam \vga/_and000053 .LOC = "CLB_R15C7.S0";
  X_LUT4 \vga/_and000053  (
    .ADR0(\vga/vgacore/hcnt [5]),
    .ADR1(\vga/crt/cursor_h [2]),
    .ADR2(\vga/vgacore/hcnt [6]),
    .ADR3(\vga/crt/cursor_h [3]),
    .O(\vga/_and0000_map890 )
  );
  defparam \vga/_and0000_map890/YUSED .LOC = "CLB_R15C7.S0";
  X_BUF \vga/_and0000_map890/YUSED  (
    .I(\vga/_and0000_map890 ),
    .O(\vga/_and0000_map890_0 )
  );
  defparam \vga/charload617 .INIT = 16'h3202;
  defparam \vga/charload617 .LOC = "CLB_R9C3.S1";
  X_LUT4 \vga/charload617  (
    .ADR0(\vga/N96_0 ),
    .ADR1(\vga/rom_addr_char [2]),
    .ADR2(\vga/rom_addr_char [1]),
    .ADR3(\vga/N30_0 ),
    .O(\vga/charload6_map1010_pack_1 )
  );
  defparam \vga/charload628 .INIT = 16'hCC80;
  defparam \vga/charload628 .LOC = "CLB_R9C3.S1";
  X_LUT4 \vga/charload628  (
    .ADR0(\vga/rom_addr_char [2]),
    .ADR1(\vga/rom_addr_char [3]),
    .ADR2(\vga/N98_0 ),
    .ADR3(\vga/charload6_map1010 ),
    .O(\vga/charload6_map1012 )
  );
  defparam \vga/charload6_map1010/XUSED .LOC = "CLB_R9C3.S1";
  X_BUF \vga/charload6_map1010/XUSED  (
    .I(\vga/charload6_map1010_pack_1 ),
    .O(\vga/charload6_map1010 )
  );
  defparam \vga/charload6_map1010/YUSED .LOC = "CLB_R9C3.S1";
  X_BUF \vga/charload6_map1010/YUSED  (
    .I(\vga/charload6_map1012 ),
    .O(\vga/charload6_map1012_0 )
  );
  defparam \vga/charload637 .INIT = 16'h2222;
  defparam \vga/charload637 .LOC = "CLB_R9C3.S0";
  X_LUT4 \vga/charload637  (
    .ADR0(\vga/rom_addr_char<2>_f51234_0 ),
    .ADR1(\vga/rom_addr_char [3]),
    .ADR2(VCC),
    .ADR3(VCC),
    .O(\vga/charload6_map1014_pack_1 )
  );
  defparam \vga/charload669 .INIT = 16'hF5E4;
  defparam \vga/charload669 .LOC = "CLB_R9C3.S0";
  X_LUT4 \vga/charload669  (
    .ADR0(\vga/rom_addr_char [4]),
    .ADR1(\vga/charload6_map1012_0 ),
    .ADR2(\vga/rom_addr_char<3>_f61234_0 ),
    .ADR3(\vga/charload6_map1014 ),
    .O(\vga/charload6_map1018 )
  );
  defparam \vga/charload6_map1014/XUSED .LOC = "CLB_R9C3.S0";
  X_BUF \vga/charload6_map1014/XUSED  (
    .I(\vga/charload6_map1014_pack_1 ),
    .O(\vga/charload6_map1014 )
  );
  defparam \vga/charload6_map1014/YUSED .LOC = "CLB_R9C3.S0";
  X_BUF \vga/charload6_map1014/YUSED  (
    .I(\vga/charload6_map1018 ),
    .O(\vga/charload6_map1018_0 )
  );
  defparam \vga/crtclk1/BYMUX .LOC = "CLB_R24C21.S0";
  X_INV \vga/crtclk1/BYMUX  (
    .I(\vga/crtclk_4 ),
    .O(\vga/crtclk1/BYMUXNOT )
  );
  defparam \vga/crtclk .LOC = "CLB_R24C21.S0";
  defparam \vga/crtclk .INIT = 1'b0;
  X_FF \vga/crtclk  (
    .I(\vga/crtclk1/BYMUXNOT ),
    .CE(VCC),
    .CLK(gray_cnt_FFd1_0),
    .SET(GND),
    .RST(\vga/crtclk1/FFY/RST ),
    .O(\vga/crtclk1 )
  );
  defparam \vga/crtclk1/FFY/RSTOR .LOC = "CLB_R24C21.S0";
  X_INV \vga/crtclk1/FFY/RSTOR  (
    .I(reset_n_IBUF_0),
    .O(\vga/crtclk1/FFY/RST )
  );
  defparam \vga/scancode_convert/sc_0_1 .LOC = "CLB_R13C32.S1";
  defparam \vga/scancode_convert/sc_0_1 .INIT = 1'b0;
  X_FF \vga/scancode_convert/sc_0_1  (
    .I(\vga/ps2/sc_r [0]),
    .CE(\vga/scancode_convert/_and0000_0 ),
    .CLK(gray_cnt_FFd1_0),
    .SET(GND),
    .RST(GND),
    .O(\vga/scancode_convert/sc_0_1_10 )
  );
  defparam \vga/crt_data<1>/SRMUX .LOC = "CLB_R16C25.S0";
  X_INV \vga/crt_data<1>/SRMUX  (
    .I(reset_n_IBUF_0),
    .O(\vga/crt_data<1>/SRMUX_OUTPUTNOT )
  );
  defparam \vga/crt_data_0 .LOC = "CLB_R16C25.S0";
  defparam \vga/crt_data_0 .INIT = 1'b0;
  X_FF \vga/crt_data_0  (
    .I(\vga/scancode_convert/ascii [0]),
    .CE(VCC),
    .CLK(\vga/scancode_convert/strobe_out_15 ),
    .SET(GND),
    .RST(\vga/crt_data<1>/FFY/RST ),
    .O(\vga/crt_data [0])
  );
  defparam \vga/crt_data<1>/FFY/RSTOR .LOC = "CLB_R16C25.S0";
  X_BUF \vga/crt_data<1>/FFY/RSTOR  (
    .I(\vga/crt_data<1>/SRMUX_OUTPUTNOT ),
    .O(\vga/crt_data<1>/FFY/RST )
  );
  defparam \vga/scancode_convert/sc_1_1 .LOC = "CLB_R13C33.S0";
  defparam \vga/scancode_convert/sc_1_1 .INIT = 1'b0;
  X_FF \vga/scancode_convert/sc_1_1  (
    .I(\vga/ps2/sc_r [1]),
    .CE(\vga/scancode_convert/_and0000_0 ),
    .CLK(gray_cnt_FFd1_0),
    .SET(GND),
    .RST(GND),
    .O(\vga/scancode_convert/sc_1_1_23 )
  );
  defparam \vga/crt_data<3>/SRMUX .LOC = "CLB_R16C21.S0";
  X_INV \vga/crt_data<3>/SRMUX  (
    .I(reset_n_IBUF_0),
    .O(\vga/crt_data<3>/SRMUX_OUTPUTNOT )
  );
  defparam \vga/crt_data_2 .LOC = "CLB_R16C21.S0";
  defparam \vga/crt_data_2 .INIT = 1'b0;
  X_FF \vga/crt_data_2  (
    .I(\vga/scancode_convert/ascii [2]),
    .CE(VCC),
    .CLK(\vga/scancode_convert/strobe_out_15 ),
    .SET(GND),
    .RST(\vga/crt_data<3>/FFY/RST ),
    .O(\vga/crt_data [2])
  );
  defparam \vga/crt_data<3>/FFY/RSTOR .LOC = "CLB_R16C21.S0";
  X_BUF \vga/crt_data<3>/FFY/RSTOR  (
    .I(\vga/crt_data<3>/SRMUX_OUTPUTNOT ),
    .O(\vga/crt_data<3>/FFY/RST )
  );
  defparam \vga/crt_data<5>/SRMUX .LOC = "CLB_R14C25.S1";
  X_INV \vga/crt_data<5>/SRMUX  (
    .I(reset_n_IBUF_0),
    .O(\vga/crt_data<5>/SRMUX_OUTPUTNOT )
  );
  defparam \vga/crt_data_4 .LOC = "CLB_R14C25.S1";
  defparam \vga/crt_data_4 .INIT = 1'b0;
  X_FF \vga/crt_data_4  (
    .I(\vga/scancode_convert/ascii [4]),
    .CE(VCC),
    .CLK(\vga/scancode_convert/strobe_out_15 ),
    .SET(GND),
    .RST(\vga/crt_data<5>/FFY/RST ),
    .O(\vga/crt_data [4])
  );
  defparam \vga/crt_data<5>/FFY/RSTOR .LOC = "CLB_R14C25.S1";
  X_BUF \vga/crt_data<5>/FFY/RSTOR  (
    .I(\vga/crt_data<5>/SRMUX_OUTPUTNOT ),
    .O(\vga/crt_data<5>/FFY/RST )
  );
  defparam \vga/crt_data_6 .LOC = "CLB_R14C25.S0";
  defparam \vga/crt_data_6 .INIT = 1'b0;
  X_FF \vga/crt_data_6  (
    .I(\vga/scancode_convert/ascii [6]),
    .CE(VCC),
    .CLK(\vga/scancode_convert/strobe_out_15 ),
    .SET(GND),
    .RST(\vga/crt_data<6>/FFY/RST ),
    .O(\vga/crt_data [6])
  );
  defparam \vga/crt_data<6>/FFY/RSTOR .LOC = "CLB_R14C25.S0";
  X_INV \vga/crt_data<6>/FFY/RSTOR  (
    .I(reset_n_IBUF_0),
    .O(\vga/crt_data<6>/FFY/RST )
  );
  defparam \vga/vgacore/hcnt<0>/LOGIC_ONE .LOC = "CLB_R20C7.S1";
  X_ONE \vga/vgacore/hcnt<0>/LOGIC_ONE  (
    .O(\vga/vgacore/hcnt<0>/LOGIC_ONE_178 )
  );
  defparam \vga/vgacore/hcnt<0>/LOGIC_ZERO .LOC = "CLB_R20C7.S1";
  X_ZERO \vga/vgacore/hcnt<0>/LOGIC_ZERO  (
    .O(\vga/vgacore/hcnt<0>/LOGIC_ZERO_180 )
  );
  defparam \vga/vgacore/Mcount_hcnt_cy<0> .LOC = "CLB_R20C7.S1";
  X_MUX2 \vga/vgacore/Mcount_hcnt_cy<0>  (
    .IA(\vga/vgacore/hcnt_Eqn_0_mand1 ),
    .IB(\vga/vgacore/hcnt<0>/LOGIC_ZERO_180 ),
    .SEL(\vga/vgacore/Result [0]),
    .O(\vga/vgacore/Mcount_hcnt_cy<0>_rt_179 )
  );
  defparam \vga/vgacore/hcnt_Eqn_0_mand .LOC = "CLB_R20C7.S1";
  X_AND2 \vga/vgacore/hcnt_Eqn_0_mand  (
    .I0(\vga/vgacore/hcnt_Eqn_bis_0 ),
    .I1(\vga/vgacore/hcnt [0]),
    .O(\vga/vgacore/hcnt_Eqn_0_mand1 )
  );
  defparam \vga/vgacore/Mcount_hcnt_lut<0> .INIT = 16'h4444;
  defparam \vga/vgacore/Mcount_hcnt_lut<0> .LOC = "CLB_R20C7.S1";
  X_LUT4 \vga/vgacore/Mcount_hcnt_lut<0>  (
    .ADR0(\vga/vgacore/hcnt [0]),
    .ADR1(\vga/vgacore/hcnt_Eqn_bis_0 ),
    .ADR2(VCC),
    .ADR3(VCC),
    .O(\vga/vgacore/Result [0])
  );
  defparam \vga/vgacore/Mcompar__cmp_lt0000_cy<4>_inv_INV_0 .INIT = 16'h5555;
  defparam \vga/vgacore/Mcompar__cmp_lt0000_cy<4>_inv_INV_0 .LOC = "CLB_R20C7.S1";
  X_LUT4 \vga/vgacore/Mcompar__cmp_lt0000_cy<4>_inv_INV_0  (
    .ADR0(\vga/vgacore/Mcompar__cmp_lt0000_cy<4>_0 ),
    .ADR1(VCC),
    .ADR2(VCC),
    .ADR3(VCC),
    .O(\vga/vgacore/hcnt_Eqn_bis_0_pack_1 )
  );
  defparam \vga/vgacore/hcnt<0>/YUSED .LOC = "CLB_R20C7.S1";
  X_BUF \vga/vgacore/hcnt<0>/YUSED  (
    .I(\vga/vgacore/hcnt_Eqn_bis_0_pack_1 ),
    .O(\vga/vgacore/hcnt_Eqn_bis_0 )
  );
  defparam \vga/vgacore/Mcount_hcnt_cy<0>_rt .LOC = "CLB_R20C7.S1";
  X_MUX2 \vga/vgacore/Mcount_hcnt_cy<0>_rt  (
    .IA(\NLW_vga/vgacore/Mcount_hcnt_cy<0>_rt_IA_UNCONNECTED ),
    .IB(\vga/vgacore/Mcount_hcnt_cy<0>_rt_179 ),
    .SEL(\vga/vgacore/hcnt<0>/LOGIC_ONE_178 ),
    .O(\vga/vgacore/hcnt<0>/CYMUXG )
  );
  defparam \vga/vgacore/hcnt_0 .LOC = "CLB_R20C7.S1";
  defparam \vga/vgacore/hcnt_0 .INIT = 1'b0;
  X_FF \vga/vgacore/hcnt_0  (
    .I(\vga/vgacore/Result [0]),
    .CE(VCC),
    .CLK(gray_cnt_FFd1_0),
    .SET(GND),
    .RST(\vga/vgacore/hcnt<0>/FFX/RST ),
    .O(\vga/vgacore/hcnt [0])
  );
  defparam \vga/vgacore/hcnt<0>/FFX/RSTOR .LOC = "CLB_R20C7.S1";
  X_INV \vga/vgacore/hcnt<0>/FFX/RSTOR  (
    .I(reset_n_IBUF_0),
    .O(\vga/vgacore/hcnt<0>/FFX/RST )
  );
  defparam \vga/scancode_convert/_cmp_eq0000_SW0_SW0 .INIT = 16'h0FFF;
  defparam \vga/scancode_convert/_cmp_eq0000_SW0_SW0 .LOC = "CLB_R11C29.S0";
  X_LUT4 \vga/scancode_convert/_cmp_eq0000_SW0_SW0  (
    .ADR0(VCC),
    .ADR1(VCC),
    .ADR2(\vga/ps2/sc_r [7]),
    .ADR3(\vga/ps2/sc_r [5]),
    .O(N3100)
  );
  defparam \N3100/YUSED .LOC = "CLB_R11C29.S0";
  X_BUF \N3100/YUSED  (
    .I(N3100),
    .O(N3100_0)
  );
  defparam \vga/vgacore/_and0001_SW0 .INIT = 16'hFCFF;
  defparam \vga/vgacore/_and0001_SW0 .LOC = "CLB_R16C6.S1";
  X_LUT4 \vga/vgacore/_and0001_SW0  (
    .ADR0(VCC),
    .ADR1(N3222_0),
    .ADR2(\vga/vgacore/vcnt [9]),
    .ADR3(\vga/vgacore/vcnt_1_1_8 ),
    .O(N44_pack_1)
  );
  defparam \vga/vgacore/_and0001 .INIT = 16'h0004;
  defparam \vga/vgacore/_and0001 .LOC = "CLB_R16C6.S1";
  X_LUT4 \vga/vgacore/_and0001  (
    .ADR0(\vga/vgacore/vcnt_2_1_9 ),
    .ADR1(\vga/vgacore/vcnt [3]),
    .ADR2(\vga/vgacore/vcnt [4]),
    .ADR3(N44),
    .O(\vga/vgacore/_and0001_181 )
  );
  defparam \vga/vgacore/vsync/XUSED .LOC = "CLB_R16C6.S1";
  X_BUF \vga/vgacore/vsync/XUSED  (
    .I(N44_pack_1),
    .O(N44)
  );
  defparam \vga/vgacore/vsync .LOC = "CLB_R16C6.S1";
  defparam \vga/vgacore/vsync .INIT = 1'b0;
  X_FF \vga/vgacore/vsync  (
    .I(\vga/vgacore/_and0001_181 ),
    .CE(VCC),
    .CLK(gray_cnt_FFd1_0),
    .SET(GND),
    .RST(\vga/vgacore/vsync/FFY/RST ),
    .O(\vga/vgacore/vsync_2 )
  );
  defparam \vga/vgacore/vsync/FFY/RSTOR .LOC = "CLB_R16C6.S1";
  X_INV \vga/vgacore/vsync/FFY/RSTOR  (
    .I(reset_n_IBUF_0),
    .O(\vga/vgacore/vsync/FFY/RST )
  );
  defparam \vga/pclk__mux0000<2>_SW0 .INIT = 16'hFF15;
  defparam \vga/pclk__mux0000<2>_SW0 .LOC = "CLB_R14C6.S0";
  X_LUT4 \vga/pclk__mux0000<2>_SW0  (
    .ADR0(\vga/crt/state_FFd1_13 ),
    .ADR1(\vga/crt/state_FFd3_11 ),
    .ADR2(\vga/crt/state_FFd2_12 ),
    .ADR3(\vga/vgacore/hblank_21 ),
    .O(N89_pack_1)
  );
  defparam \vga/pclk__mux0000<2> .INIT = 16'hFF6C;
  defparam \vga/pclk__mux0000<2> .LOC = "CLB_R14C6.S0";
  X_LUT4 \vga/pclk__mux0000<2>  (
    .ADR0(\vga/pclk [1]),
    .ADR1(\vga/pclk [2]),
    .ADR2(\vga/pclk [0]),
    .ADR3(N89),
    .O(\vga/pclk__mux0000 [2])
  );
  defparam \vga/pclk<2>/XUSED .LOC = "CLB_R14C6.S0";
  X_BUF \vga/pclk<2>/XUSED  (
    .I(N89_pack_1),
    .O(N89)
  );
  defparam \vga/pclk_2 .LOC = "CLB_R14C6.S0";
  defparam \vga/pclk_2 .INIT = 1'b1;
  X_FF \vga/pclk_2  (
    .I(\vga/pclk__mux0000 [2]),
    .CE(VCC),
    .CLK(gray_cnt_FFd1_0),
    .SET(\vga/pclk<2>/FFY/SET ),
    .RST(GND),
    .O(\vga/pclk [2])
  );
  defparam \vga/pclk<2>/FFY/SETOR .LOC = "CLB_R14C6.S0";
  X_INV \vga/pclk<2>/FFY/SETOR  (
    .I(reset_n_IBUF_0),
    .O(\vga/pclk<2>/FFY/SET )
  );
  defparam \vga/scancode_convert/ascii_3 .LOC = "CLB_R18C35.S1";
  defparam \vga/scancode_convert/ascii_3 .INIT = 1'b0;
  X_FF \vga/scancode_convert/ascii_3  (
    .I(\vga/scancode_convert/rom_data [3]),
    .CE(\vga/scancode_convert/_or0000_0 ),
    .CLK(gray_cnt_FFd1_0),
    .SET(GND),
    .RST(GND),
    .O(\vga/scancode_convert/ascii [3])
  );
  defparam \vga/scancode_convert/ascii_4 .LOC = "CLB_R12C36.S1";
  defparam \vga/scancode_convert/ascii_4 .INIT = 1'b0;
  X_FF \vga/scancode_convert/ascii_4  (
    .I(\vga/scancode_convert/rom_data [4]),
    .CE(\vga/scancode_convert/_or0000_0 ),
    .CLK(gray_cnt_FFd1_0),
    .SET(GND),
    .RST(GND),
    .O(\vga/scancode_convert/ascii [4])
  );
  defparam \vga/pixel_hold_0 .LOC = "CLB_R13C8.S0";
  defparam \vga/pixel_hold_0 .INIT = 1'b0;
  X_FF \vga/pixel_hold_0  (
    .I(\vga/_mux0002 [7]),
    .CE(VCC),
    .CLK(gray_cnt_FFd1_0),
    .SET(GND),
    .RST(GND),
    .O(\vga/pixel_hold [0])
  );
  defparam \vga/pixel_hold_1 .LOC = "CLB_R13C7.S0";
  defparam \vga/pixel_hold_1 .INIT = 1'b0;
  X_FF \vga/pixel_hold_1  (
    .I(\vga/_mux0002 [6]),
    .CE(VCC),
    .CLK(gray_cnt_FFd1_0),
    .SET(GND),
    .RST(GND),
    .O(\vga/pixel_hold [1])
  );
  defparam \vga/pixel_hold_5 .LOC = "CLB_R13C9.S0";
  defparam \vga/pixel_hold_5 .INIT = 1'b0;
  X_FF \vga/pixel_hold_5  (
    .I(\vga/_mux0002 [2]),
    .CE(VCC),
    .CLK(gray_cnt_FFd1_0),
    .SET(GND),
    .RST(GND),
    .O(\vga/pixel_hold [5])
  );
  defparam \vga/pixel_hold_3 .LOC = "CLB_R13C8.S1";
  defparam \vga/pixel_hold_3 .INIT = 1'b0;
  X_FF \vga/pixel_hold_3  (
    .I(\vga/_mux0002 [4]),
    .CE(VCC),
    .CLK(gray_cnt_FFd1_0),
    .SET(GND),
    .RST(GND),
    .O(\vga/pixel_hold [3])
  );
  defparam \vga/pixel_hold_6 .LOC = "CLB_R12C6.S0";
  defparam \vga/pixel_hold_6 .INIT = 1'b0;
  X_FF \vga/pixel_hold_6  (
    .I(\vga/_mux0002 [1]),
    .CE(VCC),
    .CLK(gray_cnt_FFd1_0),
    .SET(GND),
    .RST(GND),
    .O(\vga/pixel_hold [6])
  );
  defparam \vga/vgacore/hblank .LOC = "CLB_R16C7.S0";
  defparam \vga/vgacore/hblank .INIT = 1'b0;
  X_FF \vga/vgacore/hblank  (
    .I(\vga/vgacore/_mux0002 ),
    .CE(VCC),
    .CLK(gray_cnt_FFd1_0),
    .SET(GND),
    .RST(\vga/vgacore/hblank/FFY/RST ),
    .O(\vga/vgacore/hblank_21 )
  );
  defparam \vga/vgacore/hblank/FFY/RSTOR .LOC = "CLB_R16C7.S0";
  X_INV \vga/vgacore/hblank/FFY/RSTOR  (
    .I(reset_n_IBUF_0),
    .O(\vga/vgacore/hblank/FFY/RST )
  );
  defparam \vga/vgacore/hcnt_2 .LOC = "CLB_R19C7.S1";
  defparam \vga/vgacore/hcnt_2 .INIT = 1'b0;
  X_FF \vga/vgacore/hcnt_2  (
    .I(\vga/vgacore/Result [2]),
    .CE(VCC),
    .CLK(gray_cnt_FFd1_0),
    .SET(GND),
    .RST(\vga/vgacore/hcnt<1>/FFY/RST ),
    .O(\vga/vgacore/hcnt [2])
  );
  defparam \vga/vgacore/hcnt<1>/FFY/RSTOR .LOC = "CLB_R19C7.S1";
  X_BUF \vga/vgacore/hcnt<1>/FFY/RSTOR  (
    .I(\vga/vgacore/hcnt<1>/SRMUX_OUTPUTNOT ),
    .O(\vga/vgacore/hcnt<1>/FFY/RST )
  );
  defparam \vga/vgacore/hcnt_4 .LOC = "CLB_R18C7.S1";
  defparam \vga/vgacore/hcnt_4 .INIT = 1'b0;
  X_FF \vga/vgacore/hcnt_4  (
    .I(\vga/vgacore/Result [4]),
    .CE(VCC),
    .CLK(gray_cnt_FFd1_0),
    .SET(GND),
    .RST(\vga/vgacore/hcnt<3>/FFY/RST ),
    .O(\vga/vgacore/hcnt [4])
  );
  defparam \vga/vgacore/hcnt<3>/FFY/RSTOR .LOC = "CLB_R18C7.S1";
  X_BUF \vga/vgacore/hcnt<3>/FFY/RSTOR  (
    .I(\vga/vgacore/hcnt<3>/SRMUX_OUTPUTNOT ),
    .O(\vga/vgacore/hcnt<3>/FFY/RST )
  );
  defparam \vga/vgacore/hcnt_6 .LOC = "CLB_R17C7.S1";
  defparam \vga/vgacore/hcnt_6 .INIT = 1'b0;
  X_FF \vga/vgacore/hcnt_6  (
    .I(\vga/vgacore/Result [6]),
    .CE(VCC),
    .CLK(gray_cnt_FFd1_0),
    .SET(GND),
    .RST(\vga/vgacore/hcnt<5>/FFY/RST ),
    .O(\vga/vgacore/hcnt [6])
  );
  defparam \vga/vgacore/hcnt<5>/FFY/RSTOR .LOC = "CLB_R17C7.S1";
  X_BUF \vga/vgacore/hcnt<5>/FFY/RSTOR  (
    .I(\vga/vgacore/hcnt<5>/SRMUX_OUTPUTNOT ),
    .O(\vga/vgacore/hcnt<5>/FFY/RST )
  );
  defparam \vga/vgacore/hcnt_8 .LOC = "CLB_R16C7.S1";
  defparam \vga/vgacore/hcnt_8 .INIT = 1'b0;
  X_FF \vga/vgacore/hcnt_8  (
    .I(\vga/vgacore/Result [8]),
    .CE(VCC),
    .CLK(gray_cnt_FFd1_0),
    .SET(GND),
    .RST(\vga/vgacore/hcnt<7>/FFY/RST ),
    .O(\vga/vgacore/hcnt [8])
  );
  defparam \vga/vgacore/hcnt<7>/FFY/RSTOR .LOC = "CLB_R16C7.S1";
  X_BUF \vga/vgacore/hcnt<7>/FFY/RSTOR  (
    .I(\vga/vgacore/hcnt<7>/SRMUX_OUTPUTNOT ),
    .O(\vga/vgacore/hcnt<7>/FFY/RST )
  );
  defparam \vga/vgacore/hcnt_10 .LOC = "CLB_R15C7.S1";
  defparam \vga/vgacore/hcnt_10 .INIT = 1'b0;
  X_FF \vga/vgacore/hcnt_10  (
    .I(\vga/vgacore/Result [10]),
    .CE(VCC),
    .CLK(gray_cnt_FFd1_0),
    .SET(GND),
    .RST(\vga/vgacore/hcnt<9>/FFY/RST ),
    .O(\vga/vgacore/hcnt [10])
  );
  defparam \vga/vgacore/hcnt<9>/FFY/RSTOR .LOC = "CLB_R15C7.S1";
  X_BUF \vga/vgacore/hcnt<9>/FFY/RSTOR  (
    .I(\vga/vgacore/hcnt<9>/SRMUX_OUTPUTNOT ),
    .O(\vga/vgacore/hcnt<9>/FFY/RST )
  );
  defparam \vga/vgacore/vcnt_0_1 .LOC = "CLB_R19C9.S1";
  defparam \vga/vgacore/vcnt_0_1 .INIT = 1'b0;
  X_FF \vga/vgacore/vcnt_0_1  (
    .I(N3216),
    .CE(VCC),
    .CLK(\vga/vgacore/vcnt<0>/CKMUXNOT ),
    .SET(GND),
    .RST(\vga/vgacore/vcnt<0>/FFY/RST ),
    .O(\vga/vgacore/vcnt_0_1_17 )
  );
  defparam \vga/vgacore/vcnt<0>/FFY/RSTOR .LOC = "CLB_R19C9.S1";
  X_BUF \vga/vgacore/vcnt<0>/FFY/RSTOR  (
    .I(\vga/vgacore/vcnt<0>/SRMUX_OUTPUTNOT ),
    .O(\vga/vgacore/vcnt<0>/FFY/RST )
  );
  defparam \vga/vgacore/vcnt_2 .LOC = "CLB_R18C9.S1";
  defparam \vga/vgacore/vcnt_2 .INIT = 1'b0;
  X_FF \vga/vgacore/vcnt_2  (
    .I(\vga/vgacore/Result<2>1 ),
    .CE(VCC),
    .CLK(\vga/vgacore/vcnt<1>/CKMUXNOT ),
    .SET(GND),
    .RST(\vga/vgacore/vcnt<1>/FFY/RST ),
    .O(\vga/vgacore/vcnt [2])
  );
  defparam \vga/vgacore/vcnt<1>/FFY/RSTOR .LOC = "CLB_R18C9.S1";
  X_BUF \vga/vgacore/vcnt<1>/FFY/RSTOR  (
    .I(\vga/vgacore/vcnt<1>/SRMUX_OUTPUTNOT ),
    .O(\vga/vgacore/vcnt<1>/FFY/RST )
  );
  defparam \vga/vgacore/vcnt_4 .LOC = "CLB_R17C9.S1";
  defparam \vga/vgacore/vcnt_4 .INIT = 1'b0;
  X_FF \vga/vgacore/vcnt_4  (
    .I(\vga/vgacore/Result<4>1 ),
    .CE(VCC),
    .CLK(\vga/vgacore/vcnt<3>/CKMUXNOT ),
    .SET(GND),
    .RST(\vga/vgacore/vcnt<3>/FFY/RST ),
    .O(\vga/vgacore/vcnt [4])
  );
  defparam \vga/vgacore/vcnt<3>/FFY/RSTOR .LOC = "CLB_R17C9.S1";
  X_BUF \vga/vgacore/vcnt<3>/FFY/RSTOR  (
    .I(\vga/vgacore/vcnt<3>/SRMUX_OUTPUTNOT ),
    .O(\vga/vgacore/vcnt<3>/FFY/RST )
  );
  defparam \vga/vgacore/vcnt_6 .LOC = "CLB_R16C9.S1";
  defparam \vga/vgacore/vcnt_6 .INIT = 1'b0;
  X_FF \vga/vgacore/vcnt_6  (
    .I(\vga/vgacore/Result<6>1 ),
    .CE(VCC),
    .CLK(\vga/vgacore/vcnt<5>/CKMUXNOT ),
    .SET(GND),
    .RST(\vga/vgacore/vcnt<5>/FFY/RST ),
    .O(\vga/vgacore/vcnt [6])
  );
  defparam \vga/vgacore/vcnt<5>/FFY/RSTOR .LOC = "CLB_R16C9.S1";
  X_BUF \vga/vgacore/vcnt<5>/FFY/RSTOR  (
    .I(\vga/vgacore/vcnt<5>/SRMUX_OUTPUTNOT ),
    .O(\vga/vgacore/vcnt<5>/FFY/RST )
  );
  defparam \vga/vgacore/vcnt_8 .LOC = "CLB_R15C9.S1";
  defparam \vga/vgacore/vcnt_8 .INIT = 1'b0;
  X_FF \vga/vgacore/vcnt_8  (
    .I(\vga/vgacore/Result<8>1 ),
    .CE(VCC),
    .CLK(\vga/vgacore/vcnt<7>/CKMUXNOT ),
    .SET(GND),
    .RST(\vga/vgacore/vcnt<7>/FFY/RST ),
    .O(\vga/vgacore/vcnt [8])
  );
  defparam \vga/vgacore/vcnt<7>/FFY/RSTOR .LOC = "CLB_R15C9.S1";
  X_BUF \vga/vgacore/vcnt<7>/FFY/RSTOR  (
    .I(\vga/vgacore/vcnt<7>/SRMUX_OUTPUTNOT ),
    .O(\vga/vgacore/vcnt<7>/FFY/RST )
  );
  defparam \vga/crt/cursor_v_2 .LOC = "CLB_R15C13.S1";
  defparam \vga/crt/cursor_v_2 .INIT = 1'b0;
  X_FF \vga/crt/cursor_v_2  (
    .I(\vga/crt/cursor_v_Eqn_2 ),
    .CE(\vga/crt/_not0007_0 ),
    .CLK(\vga/crtclk_4 ),
    .SET(GND),
    .RST(\vga/crt/cursor_v<3>/FFY/RST ),
    .O(\vga/crt/cursor_v [2])
  );
  defparam \vga/crt/cursor_v<3>/FFY/RSTOR .LOC = "CLB_R15C13.S1";
  X_BUF \vga/crt/cursor_v<3>/FFY/RSTOR  (
    .I(\vga/crt/cursor_v<3>/SRMUX_OUTPUTNOT ),
    .O(\vga/crt/cursor_v<3>/FFY/RST )
  );
  defparam \vga/crt/cursor_v_4 .LOC = "CLB_R15C14.S0";
  defparam \vga/crt/cursor_v_4 .INIT = 1'b0;
  X_FF \vga/crt/cursor_v_4  (
    .I(\vga/crt/cursor_v_Eqn_4 ),
    .CE(\vga/crt/_not0007_0 ),
    .CLK(\vga/crtclk_4 ),
    .SET(GND),
    .RST(\vga/crt/cursor_v<5>/FFY/RST ),
    .O(\vga/crt/cursor_v [4])
  );
  defparam \vga/crt/cursor_v<5>/FFY/RSTOR .LOC = "CLB_R15C14.S0";
  X_BUF \vga/crt/cursor_v<5>/FFY/RSTOR  (
    .I(\vga/crt/cursor_v<5>/SRMUX_OUTPUTNOT ),
    .O(\vga/crt/cursor_v<5>/FFY/RST )
  );
  defparam \vga/crt/ram_data_0 .LOC = "CLB_R18C13.S0";
  defparam \vga/crt/ram_data_0 .INIT = 1'b0;
  X_FF \vga/crt/ram_data_0  (
    .I(\vga/crt/_mux0002 [0]),
    .CE(\vga/crt/_not0008_0 ),
    .CLK(\vga/crtclk_4 ),
    .SET(GND),
    .RST(\vga/crt/ram_data<1>/FFY/RST ),
    .O(\vga/crt/ram_data [0])
  );
  defparam \vga/crt/ram_data<1>/FFY/RSTOR .LOC = "CLB_R18C13.S0";
  X_BUF \vga/crt/ram_data<1>/FFY/RSTOR  (
    .I(\vga/crt/ram_data<1>/SRMUX_OUTPUTNOT ),
    .O(\vga/crt/ram_data<1>/FFY/RST )
  );
  defparam \vga/crt/ram_data_2 .LOC = "CLB_R18C9.S0";
  defparam \vga/crt/ram_data_2 .INIT = 1'b0;
  X_FF \vga/crt/ram_data_2  (
    .I(\vga/crt/_mux0002 [2]),
    .CE(\vga/crt/_not0008_0 ),
    .CLK(\vga/crtclk_4 ),
    .SET(GND),
    .RST(\vga/crt/ram_data<3>/FFY/RST ),
    .O(\vga/crt/ram_data [2])
  );
  defparam \vga/crt/ram_data<3>/FFY/RSTOR .LOC = "CLB_R18C9.S0";
  X_BUF \vga/crt/ram_data<3>/FFY/RSTOR  (
    .I(\vga/crt/ram_data<3>/SRMUX_OUTPUTNOT ),
    .O(\vga/crt/ram_data<3>/FFY/RST )
  );
  defparam \vga/crt/ram_data_4 .LOC = "CLB_R14C13.S1";
  defparam \vga/crt/ram_data_4 .INIT = 1'b0;
  X_FF \vga/crt/ram_data_4  (
    .I(\vga/crt/_mux0002 [4]),
    .CE(\vga/crt/_not0008_0 ),
    .CLK(\vga/crtclk_4 ),
    .SET(GND),
    .RST(\vga/crt/ram_data<5>/FFY/RST ),
    .O(\vga/crt/ram_data [4])
  );
  defparam \vga/crt/ram_data<5>/FFY/RSTOR .LOC = "CLB_R14C13.S1";
  X_BUF \vga/crt/ram_data<5>/FFY/RSTOR  (
    .I(\vga/crt/ram_data<5>/SRMUX_OUTPUTNOT ),
    .O(\vga/crt/ram_data<5>/FFY/RST )
  );
  defparam \vga/scancode_convert/state_FFd5 .LOC = "CLB_R12C28.S0";
  defparam \vga/scancode_convert/state_FFd5 .INIT = 1'b0;
  X_FF \vga/scancode_convert/state_FFd5  (
    .I(\vga/scancode_convert/state_FFd5-In_166 ),
    .CE(VCC),
    .CLK(gray_cnt_FFd1_0),
    .SET(GND),
    .RST(\vga/scancode_convert/state_FFd6/FFY/RST ),
    .O(\vga/scancode_convert/state_FFd5_31 )
  );
  defparam \vga/scancode_convert/state_FFd6/FFY/RSTOR .LOC = "CLB_R12C28.S0";
  X_BUF \vga/scancode_convert/state_FFd6/FFY/RSTOR  (
    .I(\vga/scancode_convert/state_FFd6/SRMUX_OUTPUTNOT ),
    .O(\vga/scancode_convert/state_FFd6/FFY/RST )
  );
  defparam \vga/ps2/timer_r_10 .LOC = "CLB_R6C17.S0";
  defparam \vga/ps2/timer_r_10 .INIT = 1'b0;
  X_FF \vga/ps2/timer_r_10  (
    .I(\vga/ps2/timer_x [10]),
    .CE(VCC),
    .CLK(gray_cnt_FFd1_0),
    .SET(GND),
    .RST(\vga/ps2/timer_r<11>/FFY/RST ),
    .O(\vga/ps2/timer_r [10])
  );
  defparam \vga/ps2/timer_r<11>/FFY/RSTOR .LOC = "CLB_R6C17.S0";
  X_BUF \vga/ps2/timer_r<11>/FFY/RSTOR  (
    .I(\vga/ps2/timer_r<11>/SRMUX_OUTPUTNOT ),
    .O(\vga/ps2/timer_r<11>/FFY/RST )
  );
  defparam \vga/ps2/timer_r_12 .LOC = "CLB_R6C16.S0";
  defparam \vga/ps2/timer_r_12 .INIT = 1'b0;
  X_FF \vga/ps2/timer_r_12  (
    .I(\vga/ps2/timer_x [12]),
    .CE(VCC),
    .CLK(gray_cnt_FFd1_0),
    .SET(GND),
    .RST(\vga/ps2/timer_r<13>/FFY/RST ),
    .O(\vga/ps2/timer_r [12])
  );
  defparam \vga/ps2/timer_r<13>/FFY/RSTOR .LOC = "CLB_R6C16.S0";
  X_BUF \vga/ps2/timer_r<13>/FFY/RSTOR  (
    .I(\vga/ps2/timer_r<13>/SRMUX_OUTPUTNOT ),
    .O(\vga/ps2/timer_r<13>/FFY/RST )
  );
  defparam \vga/scancode_convert/hold_count_0 .LOC = "CLB_R14C26.S0";
  defparam \vga/scancode_convert/hold_count_0 .INIT = 1'b0;
  X_FF \vga/scancode_convert/hold_count_0  (
    .I(\vga/scancode_convert/hold_count__mux0000 [0]),
    .CE(VCC),
    .CLK(gray_cnt_FFd1_0),
    .SET(GND),
    .RST(\vga/scancode_convert/hold_count<1>/FFY/RST ),
    .O(\vga/scancode_convert/hold_count [0])
  );
  defparam \vga/scancode_convert/hold_count<1>/FFY/RSTOR .LOC = "CLB_R14C26.S0";
  X_BUF \vga/scancode_convert/hold_count<1>/FFY/RSTOR  (
    .I(\vga/scancode_convert/hold_count<1>/SRMUX_OUTPUTNOT ),
    .O(\vga/scancode_convert/hold_count<1>/FFY/RST )
  );
  defparam \vga/ps2/timer_r_2 .LOC = "CLB_R9C16.S0";
  defparam \vga/ps2/timer_r_2 .INIT = 1'b0;
  X_FF \vga/ps2/timer_r_2  (
    .I(\vga/ps2/timer_x [2]),
    .CE(VCC),
    .CLK(gray_cnt_FFd1_0),
    .SET(GND),
    .RST(\vga/ps2/timer_r<3>/FFY/RST ),
    .O(\vga/ps2/timer_r [2])
  );
  defparam \vga/ps2/timer_r<3>/FFY/RSTOR .LOC = "CLB_R9C16.S0";
  X_BUF \vga/ps2/timer_r<3>/FFY/RSTOR  (
    .I(\vga/ps2/timer_r<3>/SRMUX_OUTPUTNOT ),
    .O(\vga/ps2/timer_r<3>/FFY/RST )
  );
  defparam \vga/ps2/timer_r_4 .LOC = "CLB_R8C16.S0";
  defparam \vga/ps2/timer_r_4 .INIT = 1'b0;
  X_FF \vga/ps2/timer_r_4  (
    .I(\vga/ps2/timer_x [4]),
    .CE(VCC),
    .CLK(gray_cnt_FFd1_0),
    .SET(GND),
    .RST(\vga/ps2/timer_r<5>/FFY/RST ),
    .O(\vga/ps2/timer_r [4])
  );
  defparam \vga/ps2/timer_r<5>/FFY/RSTOR .LOC = "CLB_R8C16.S0";
  X_BUF \vga/ps2/timer_r<5>/FFY/RSTOR  (
    .I(\vga/ps2/timer_r<5>/SRMUX_OUTPUTNOT ),
    .O(\vga/ps2/timer_r<5>/FFY/RST )
  );
  defparam \vga/ps2/timer_r_6 .LOC = "CLB_R8C15.S1";
  defparam \vga/ps2/timer_r_6 .INIT = 1'b0;
  X_FF \vga/ps2/timer_r_6  (
    .I(\vga/ps2/timer_x [6]),
    .CE(VCC),
    .CLK(gray_cnt_FFd1_0),
    .SET(GND),
    .RST(\vga/ps2/timer_r<7>/FFY/RST ),
    .O(\vga/ps2/timer_r [6])
  );
  defparam \vga/ps2/timer_r<7>/FFY/RSTOR .LOC = "CLB_R8C15.S1";
  X_BUF \vga/ps2/timer_r<7>/FFY/RSTOR  (
    .I(\vga/ps2/timer_r<7>/SRMUX_OUTPUTNOT ),
    .O(\vga/ps2/timer_r<7>/FFY/RST )
  );
  defparam \vga/ps2/timer_r_8 .LOC = "CLB_R7C17.S0";
  defparam \vga/ps2/timer_r_8 .INIT = 1'b0;
  X_FF \vga/ps2/timer_r_8  (
    .I(\vga/ps2/timer_x [8]),
    .CE(VCC),
    .CLK(gray_cnt_FFd1_0),
    .SET(GND),
    .RST(\vga/ps2/timer_r<9>/FFY/RST ),
    .O(\vga/ps2/timer_r [8])
  );
  defparam \vga/ps2/timer_r<9>/FFY/RSTOR .LOC = "CLB_R7C17.S0";
  X_BUF \vga/ps2/timer_r<9>/FFY/RSTOR  (
    .I(\vga/ps2/timer_r<9>/SRMUX_OUTPUTNOT ),
    .O(\vga/ps2/timer_r<9>/FFY/RST )
  );
  defparam \vga/pclk_0 .LOC = "CLB_R14C6.S1";
  defparam \vga/pclk_0 .INIT = 1'b1;
  X_FF \vga/pclk_0  (
    .I(\vga/pclk__mux0000 [0]),
    .CE(VCC),
    .CLK(gray_cnt_FFd1_0),
    .SET(\vga/pclk<1>/FFY/SET ),
    .RST(GND),
    .O(\vga/pclk [0])
  );
  defparam \vga/pclk<1>/FFY/SETOR .LOC = "CLB_R14C6.S1";
  X_BUF \vga/pclk<1>/FFY/SETOR  (
    .I(\vga/pclk<1>/SRMUX_OUTPUTNOT ),
    .O(\vga/pclk<1>/FFY/SET )
  );
  defparam \vga/crt/cursor_h_0 .LOC = "CLB_R18C13.S1";
  defparam \vga/crt/cursor_h_0 .INIT = 1'b0;
  X_FF \vga/crt/cursor_h_0  (
    .I(\vga/crt/cursor_h_Eqn_0 ),
    .CE(\vga/crt/_not0006_0 ),
    .CLK(\vga/crtclk_4 ),
    .SET(GND),
    .RST(\vga/crt/cursor_h<1>/FFY/RST ),
    .O(\vga/crt/cursor_h [0])
  );
  defparam \vga/crt/cursor_h<1>/FFY/RSTOR .LOC = "CLB_R18C13.S1";
  X_BUF \vga/crt/cursor_h<1>/FFY/RSTOR  (
    .I(\vga/crt/cursor_h<1>/SRMUX_OUTPUTNOT ),
    .O(\vga/crt/cursor_h<1>/FFY/RST )
  );
  defparam \vga/crt/cursor_h_2 .LOC = "CLB_R17C13.S0";
  defparam \vga/crt/cursor_h_2 .INIT = 1'b0;
  X_FF \vga/crt/cursor_h_2  (
    .I(\vga/crt/cursor_h_Eqn_2 ),
    .CE(\vga/crt/_not0006_0 ),
    .CLK(\vga/crtclk_4 ),
    .SET(GND),
    .RST(\vga/crt/cursor_h<3>/FFY/RST ),
    .O(\vga/crt/cursor_h [2])
  );
  defparam \vga/crt/cursor_h<3>/FFY/RSTOR .LOC = "CLB_R17C13.S0";
  X_BUF \vga/crt/cursor_h<3>/FFY/RSTOR  (
    .I(\vga/crt/cursor_h<3>/SRMUX_OUTPUTNOT ),
    .O(\vga/crt/cursor_h<3>/FFY/RST )
  );
  defparam \vga/crt/cursor_h_4 .LOC = "CLB_R17C14.S0";
  defparam \vga/crt/cursor_h_4 .INIT = 1'b0;
  X_FF \vga/crt/cursor_h_4  (
    .I(\vga/crt/cursor_h_Eqn_4 ),
    .CE(\vga/crt/_not0006_0 ),
    .CLK(\vga/crtclk_4 ),
    .SET(GND),
    .RST(\vga/crt/cursor_h<5>/FFY/RST ),
    .O(\vga/crt/cursor_h [4])
  );
  defparam \vga/crt/cursor_h<5>/FFY/RSTOR .LOC = "CLB_R17C14.S0";
  X_BUF \vga/crt/cursor_h<5>/FFY/RSTOR  (
    .I(\vga/crt/cursor_h<5>/SRMUX_OUTPUTNOT ),
    .O(\vga/crt/cursor_h<5>/FFY/RST )
  );
  defparam \vga/ram_wclk .LOC = "CLB_R15C6.S0";
  defparam \vga/ram_wclk .INIT = 1'b0;
  X_FF \vga/ram_wclk  (
    .I(\vga/_mux0000 ),
    .CE(VCC),
    .CLK(gray_cnt_FFd1_0),
    .SET(GND),
    .RST(\vga/ram_wclk/FFY/RST ),
    .O(\vga/ram_wclk_5 )
  );
  defparam \vga/ram_wclk/FFY/RSTOR .LOC = "CLB_R15C6.S0";
  X_INV \vga/ram_wclk/FFY/RSTOR  (
    .I(reset_n_IBUF_0),
    .O(\vga/ram_wclk/FFY/RST )
  );
  defparam \vga/crt/ram_data_6 .LOC = "CLB_R14C13.S0";
  defparam \vga/crt/ram_data_6 .INIT = 1'b0;
  X_FF \vga/crt/ram_data_6  (
    .I(\vga/crt/_mux0002 [6]),
    .CE(\vga/crt/_not0008_0 ),
    .CLK(\vga/crtclk_4 ),
    .SET(GND),
    .RST(\vga/crt/ram_data<6>/FFY/RST ),
    .O(\vga/crt/ram_data [6])
  );
  defparam \vga/crt/ram_data<6>/FFY/RSTOR .LOC = "CLB_R14C13.S0";
  X_INV \vga/crt/ram_data<6>/FFY/RSTOR  (
    .I(reset_n_IBUF_0),
    .O(\vga/crt/ram_data<6>/FFY/RST )
  );
  defparam \vga/ps2/ps2_clk_r_0 .LOC = "PAD309";
  defparam \vga/ps2/ps2_clk_r_0 .INIT = 1'b1;
  X_FF \vga/ps2/ps2_clk_r_0  (
    .I(\ps2_clk/IDELAY ),
    .CE(VCC),
    .CLK(gray_cnt_FFd1_0),
    .SET(\ps2_clk/IFF/SET ),
    .RST(GND),
    .O(\vga/ps2/ps2_clk_r [0])
  );
  defparam \ps2_clk/IFF/SETOR .LOC = "PAD309";
  X_INV \ps2_clk/IFF/SETOR  (
    .I(reset_n_IBUF_0),
    .O(\ps2_clk/IFF/SET )
  );
  defparam \vga/ps2/sc_r_9 .LOC = "PAD315";
  defparam \vga/ps2/sc_r_9 .INIT = 1'b0;
  X_FF \vga/ps2/sc_r_9  (
    .I(\ps2_data/IDELAY ),
    .CE(\vga/ps2/ps2_clk_fall_edge_0 ),
    .CLK(gray_cnt_FFd1_0),
    .SET(GND),
    .RST(\ps2_data/IFF/RST ),
    .O(\vga/ps2/sc_r [9])
  );
  defparam \ps2_data/IFF/RSTOR .LOC = "PAD315";
  X_INV \ps2_data/IFF/RSTOR  (
    .I(reset_n_IBUF_0),
    .O(\ps2_data/IFF/RST )
  );
  defparam \vga/crt/state_FFd2 .LOC = "CLB_R15C18.S0";
  defparam \vga/crt/state_FFd2 .INIT = 1'b0;
  X_FF \vga/crt/state_FFd2  (
    .I(\vga/crt/state_FFd2-In ),
    .CE(VCC),
    .CLK(\vga/crtclk_4 ),
    .SET(GND),
    .RST(\vga/crt/state_FFd2/FFX/RST ),
    .O(\vga/crt/state_FFd2_12 )
  );
  defparam \vga/crt/state_FFd2/FFX/RSTOR .LOC = "CLB_R15C18.S0";
  X_INV \vga/crt/state_FFd2/FFX/RSTOR  (
    .I(reset_n_IBUF_0),
    .O(\vga/crt/state_FFd2/FFX/RST )
  );
  defparam \vga/vgacore/hcnt_3 .LOC = "CLB_R18C7.S1";
  defparam \vga/vgacore/hcnt_3 .INIT = 1'b0;
  X_FF \vga/vgacore/hcnt_3  (
    .I(\vga/vgacore/Result [3]),
    .CE(VCC),
    .CLK(gray_cnt_FFd1_0),
    .SET(GND),
    .RST(\vga/vgacore/hcnt<3>/FFX/RST ),
    .O(\vga/vgacore/hcnt [3])
  );
  defparam \vga/vgacore/hcnt<3>/FFX/RSTOR .LOC = "CLB_R18C7.S1";
  X_BUF \vga/vgacore/hcnt<3>/FFX/RSTOR  (
    .I(\vga/vgacore/hcnt<3>/SRMUX_OUTPUTNOT ),
    .O(\vga/vgacore/hcnt<3>/FFX/RST )
  );
  defparam \vga/vgacore/hcnt_5 .LOC = "CLB_R17C7.S1";
  defparam \vga/vgacore/hcnt_5 .INIT = 1'b0;
  X_FF \vga/vgacore/hcnt_5  (
    .I(\vga/vgacore/Result [5]),
    .CE(VCC),
    .CLK(gray_cnt_FFd1_0),
    .SET(GND),
    .RST(\vga/vgacore/hcnt<5>/FFX/RST ),
    .O(\vga/vgacore/hcnt [5])
  );
  defparam \vga/vgacore/hcnt<5>/FFX/RSTOR .LOC = "CLB_R17C7.S1";
  X_BUF \vga/vgacore/hcnt<5>/FFX/RSTOR  (
    .I(\vga/vgacore/hcnt<5>/SRMUX_OUTPUTNOT ),
    .O(\vga/vgacore/hcnt<5>/FFX/RST )
  );
  defparam \vga/vgacore/hcnt_7 .LOC = "CLB_R16C7.S1";
  defparam \vga/vgacore/hcnt_7 .INIT = 1'b0;
  X_FF \vga/vgacore/hcnt_7  (
    .I(\vga/vgacore/Result [7]),
    .CE(VCC),
    .CLK(gray_cnt_FFd1_0),
    .SET(GND),
    .RST(\vga/vgacore/hcnt<7>/FFX/RST ),
    .O(\vga/vgacore/hcnt [7])
  );
  defparam \vga/vgacore/hcnt<7>/FFX/RSTOR .LOC = "CLB_R16C7.S1";
  X_BUF \vga/vgacore/hcnt<7>/FFX/RSTOR  (
    .I(\vga/vgacore/hcnt<7>/SRMUX_OUTPUTNOT ),
    .O(\vga/vgacore/hcnt<7>/FFX/RST )
  );
  defparam \vga/vgacore/vcnt_1 .LOC = "CLB_R18C9.S1";
  defparam \vga/vgacore/vcnt_1 .INIT = 1'b0;
  X_FF \vga/vgacore/vcnt_1  (
    .I(\vga/vgacore/Result<1>1 ),
    .CE(VCC),
    .CLK(\vga/vgacore/vcnt<1>/CKMUXNOT ),
    .SET(GND),
    .RST(\vga/vgacore/vcnt<1>/FFX/RST ),
    .O(\vga/vgacore/vcnt [1])
  );
  defparam \vga/vgacore/vcnt<1>/FFX/RSTOR .LOC = "CLB_R18C9.S1";
  X_BUF \vga/vgacore/vcnt<1>/FFX/RSTOR  (
    .I(\vga/vgacore/vcnt<1>/SRMUX_OUTPUTNOT ),
    .O(\vga/vgacore/vcnt<1>/FFX/RST )
  );
  defparam \vga/vgacore/vcnt_3 .LOC = "CLB_R17C9.S1";
  defparam \vga/vgacore/vcnt_3 .INIT = 1'b0;
  X_FF \vga/vgacore/vcnt_3  (
    .I(\vga/vgacore/Result<3>1 ),
    .CE(VCC),
    .CLK(\vga/vgacore/vcnt<3>/CKMUXNOT ),
    .SET(GND),
    .RST(\vga/vgacore/vcnt<3>/FFX/RST ),
    .O(\vga/vgacore/vcnt [3])
  );
  defparam \vga/vgacore/vcnt<3>/FFX/RSTOR .LOC = "CLB_R17C9.S1";
  X_BUF \vga/vgacore/vcnt<3>/FFX/RSTOR  (
    .I(\vga/vgacore/vcnt<3>/SRMUX_OUTPUTNOT ),
    .O(\vga/vgacore/vcnt<3>/FFX/RST )
  );
  defparam \vga/vgacore/vcnt_5 .LOC = "CLB_R16C9.S1";
  defparam \vga/vgacore/vcnt_5 .INIT = 1'b0;
  X_FF \vga/vgacore/vcnt_5  (
    .I(\vga/vgacore/Result<5>1 ),
    .CE(VCC),
    .CLK(\vga/vgacore/vcnt<5>/CKMUXNOT ),
    .SET(GND),
    .RST(\vga/vgacore/vcnt<5>/FFX/RST ),
    .O(\vga/vgacore/vcnt [5])
  );
  defparam \vga/vgacore/vcnt<5>/FFX/RSTOR .LOC = "CLB_R16C9.S1";
  X_BUF \vga/vgacore/vcnt<5>/FFX/RSTOR  (
    .I(\vga/vgacore/vcnt<5>/SRMUX_OUTPUTNOT ),
    .O(\vga/vgacore/vcnt<5>/FFX/RST )
  );
  defparam \vga/vgacore/vcnt_7 .LOC = "CLB_R15C9.S1";
  defparam \vga/vgacore/vcnt_7 .INIT = 1'b0;
  X_FF \vga/vgacore/vcnt_7  (
    .I(\vga/vgacore/Result<7>1 ),
    .CE(VCC),
    .CLK(\vga/vgacore/vcnt<7>/CKMUXNOT ),
    .SET(GND),
    .RST(\vga/vgacore/vcnt<7>/FFX/RST ),
    .O(\vga/vgacore/vcnt [7])
  );
  defparam \vga/vgacore/vcnt<7>/FFX/RSTOR .LOC = "CLB_R15C9.S1";
  X_BUF \vga/vgacore/vcnt<7>/FFX/RSTOR  (
    .I(\vga/vgacore/vcnt<7>/SRMUX_OUTPUTNOT ),
    .O(\vga/vgacore/vcnt<7>/FFX/RST )
  );
  defparam \vga/vgacore/vcnt_9 .LOC = "CLB_R14C9.S1";
  defparam \vga/vgacore/vcnt_9 .INIT = 1'b0;
  X_FF \vga/vgacore/vcnt_9  (
    .I(\vga/vgacore/Result<9>1 ),
    .CE(VCC),
    .CLK(\vga/vgacore/vcnt<9>/CKMUXNOT ),
    .SET(GND),
    .RST(\vga/vgacore/vcnt<9>/FFX/RST ),
    .O(\vga/vgacore/vcnt [9])
  );
  defparam \vga/vgacore/vcnt<9>/FFX/RSTOR .LOC = "CLB_R14C9.S1";
  X_INV \vga/vgacore/vcnt<9>/FFX/RSTOR  (
    .I(reset_n_IBUF_0),
    .O(\vga/vgacore/vcnt<9>/FFX/RST )
  );
  defparam \vga/scancode_convert/ascii_5 .LOC = "CLB_R11C35.S1";
  defparam \vga/scancode_convert/ascii_5 .INIT = 1'b0;
  X_FF \vga/scancode_convert/ascii_5  (
    .I(\vga/scancode_convert/rom_data [5]),
    .CE(\vga/scancode_convert/_or0000_0 ),
    .CLK(gray_cnt_FFd1_0),
    .SET(GND),
    .RST(GND),
    .O(\vga/scancode_convert/ascii [5])
  );
  defparam \vga/crt/cursor_v_3 .LOC = "CLB_R15C13.S1";
  defparam \vga/crt/cursor_v_3 .INIT = 1'b0;
  X_FF \vga/crt/cursor_v_3  (
    .I(\vga/crt/cursor_v_Eqn_3 ),
    .CE(\vga/crt/_not0007_0 ),
    .CLK(\vga/crtclk_4 ),
    .SET(GND),
    .RST(\vga/crt/cursor_v<3>/FFX/RST ),
    .O(\vga/crt/cursor_v [3])
  );
  defparam \vga/crt/cursor_v<3>/FFX/RSTOR .LOC = "CLB_R15C13.S1";
  X_BUF \vga/crt/cursor_v<3>/FFX/RSTOR  (
    .I(\vga/crt/cursor_v<3>/SRMUX_OUTPUTNOT ),
    .O(\vga/crt/cursor_v<3>/FFX/RST )
  );
  defparam \vga/crt/cursor_v_5 .LOC = "CLB_R15C14.S0";
  defparam \vga/crt/cursor_v_5 .INIT = 1'b0;
  X_FF \vga/crt/cursor_v_5  (
    .I(\vga/crt/cursor_v_Eqn_5 ),
    .CE(\vga/crt/_not0007_0 ),
    .CLK(\vga/crtclk_4 ),
    .SET(GND),
    .RST(\vga/crt/cursor_v<5>/FFX/RST ),
    .O(\vga/crt/cursor_v [5])
  );
  defparam \vga/crt/cursor_v<5>/FFX/RSTOR .LOC = "CLB_R15C14.S0";
  X_BUF \vga/crt/cursor_v<5>/FFX/RSTOR  (
    .I(\vga/crt/cursor_v<5>/SRMUX_OUTPUTNOT ),
    .O(\vga/crt/cursor_v<5>/FFX/RST )
  );
  defparam \vga/crt/ram_data_1 .LOC = "CLB_R18C13.S0";
  defparam \vga/crt/ram_data_1 .INIT = 1'b0;
  X_FF \vga/crt/ram_data_1  (
    .I(\vga/crt/_mux0002 [1]),
    .CE(\vga/crt/_not0008_0 ),
    .CLK(\vga/crtclk_4 ),
    .SET(GND),
    .RST(\vga/crt/ram_data<1>/FFX/RST ),
    .O(\vga/crt/ram_data [1])
  );
  defparam \vga/crt/ram_data<1>/FFX/RSTOR .LOC = "CLB_R18C13.S0";
  X_BUF \vga/crt/ram_data<1>/FFX/RSTOR  (
    .I(\vga/crt/ram_data<1>/SRMUX_OUTPUTNOT ),
    .O(\vga/crt/ram_data<1>/FFX/RST )
  );
  defparam \vga/crt/ram_data_3 .LOC = "CLB_R18C9.S0";
  defparam \vga/crt/ram_data_3 .INIT = 1'b0;
  X_FF \vga/crt/ram_data_3  (
    .I(\vga/crt/_mux0002 [3]),
    .CE(\vga/crt/_not0008_0 ),
    .CLK(\vga/crtclk_4 ),
    .SET(GND),
    .RST(\vga/crt/ram_data<3>/FFX/RST ),
    .O(\vga/crt/ram_data [3])
  );
  defparam \vga/crt/ram_data<3>/FFX/RSTOR .LOC = "CLB_R18C9.S0";
  X_BUF \vga/crt/ram_data<3>/FFX/RSTOR  (
    .I(\vga/crt/ram_data<3>/SRMUX_OUTPUTNOT ),
    .O(\vga/crt/ram_data<3>/FFX/RST )
  );
  defparam \vga/crt/ram_data_5 .LOC = "CLB_R14C13.S1";
  defparam \vga/crt/ram_data_5 .INIT = 1'b0;
  X_FF \vga/crt/ram_data_5  (
    .I(\vga/crt/_mux0002 [5]),
    .CE(\vga/crt/_not0008_0 ),
    .CLK(\vga/crtclk_4 ),
    .SET(GND),
    .RST(\vga/crt/ram_data<5>/FFX/RST ),
    .O(\vga/crt/ram_data [5])
  );
  defparam \vga/crt/ram_data<5>/FFX/RSTOR .LOC = "CLB_R14C13.S1";
  X_BUF \vga/crt/ram_data<5>/FFX/RSTOR  (
    .I(\vga/crt/ram_data<5>/SRMUX_OUTPUTNOT ),
    .O(\vga/crt/ram_data<5>/FFX/RST )
  );
  defparam \vga/scancode_convert/state_FFd6 .LOC = "CLB_R12C28.S0";
  defparam \vga/scancode_convert/state_FFd6 .INIT = 1'b1;
  X_FF \vga/scancode_convert/state_FFd6  (
    .I(\vga/scancode_convert/state_FFd6/LOGIC_ZERO_165 ),
    .CE(VCC),
    .CLK(gray_cnt_FFd1_0),
    .SET(\vga/scancode_convert/state_FFd6/FFX/SET ),
    .RST(GND),
    .O(\vga/scancode_convert/state_FFd6_35 )
  );
  defparam \vga/scancode_convert/state_FFd6/FFX/SETOR .LOC = "CLB_R12C28.S0";
  X_BUF \vga/scancode_convert/state_FFd6/FFX/SETOR  (
    .I(\vga/scancode_convert/state_FFd6/SRMUX_OUTPUTNOT ),
    .O(\vga/scancode_convert/state_FFd6/FFX/SET )
  );
  defparam \vga/ps2/timer_r_11 .LOC = "CLB_R6C17.S0";
  defparam \vga/ps2/timer_r_11 .INIT = 1'b0;
  X_FF \vga/ps2/timer_r_11  (
    .I(\vga/ps2/timer_x [11]),
    .CE(VCC),
    .CLK(gray_cnt_FFd1_0),
    .SET(GND),
    .RST(\vga/ps2/timer_r<11>/FFX/RST ),
    .O(\vga/ps2/timer_r [11])
  );
  defparam \vga/ps2/timer_r<11>/FFX/RSTOR .LOC = "CLB_R6C17.S0";
  X_BUF \vga/ps2/timer_r<11>/FFX/RSTOR  (
    .I(\vga/ps2/timer_r<11>/SRMUX_OUTPUTNOT ),
    .O(\vga/ps2/timer_r<11>/FFX/RST )
  );
  defparam \vga/video_ram/ram_addr_w_1 .LOC = "CLB_R19C4.S0";
  defparam \vga/video_ram/ram_addr_w_1 .INIT = 1'b0;
  X_FF \vga/video_ram/ram_addr_w_1  (
    .I(\vga/ram_addr_mux [1]),
    .CE(VCC),
    .CLK(\vga/ram_wclk_5 ),
    .SET(GND),
    .RST(GND),
    .O(\vga/video_ram/ram_addr_w [1])
  );
  defparam \vga/video_ram/ram_addr_w_3 .LOC = "CLB_R15C2.S0";
  defparam \vga/video_ram/ram_addr_w_3 .INIT = 1'b0;
  X_FF \vga/video_ram/ram_addr_w_3  (
    .I(\vga/ram_addr_mux [3]),
    .CE(VCC),
    .CLK(\vga/ram_wclk_5 ),
    .SET(GND),
    .RST(GND),
    .O(\vga/video_ram/ram_addr_w [3])
  );
  defparam \vga/video_ram/ram_addr_w_7 .LOC = "CLB_R15C2.S1";
  defparam \vga/video_ram/ram_addr_w_7 .INIT = 1'b0;
  X_FF \vga/video_ram/ram_addr_w_7  (
    .I(\vga/ram_addr_mux [7]),
    .CE(VCC),
    .CLK(\vga/ram_wclk_5 ),
    .SET(GND),
    .RST(GND),
    .O(\vga/video_ram/ram_addr_w [7])
  );
  defparam \vga/video_ram/ram_addr_w_9 .LOC = "CLB_R15C4.S1";
  defparam \vga/video_ram/ram_addr_w_9 .INIT = 1'b0;
  X_FF \vga/video_ram/ram_addr_w_9  (
    .I(\vga/ram_addr_mux [9]),
    .CE(VCC),
    .CLK(\vga/ram_wclk_5 ),
    .SET(GND),
    .RST(GND),
    .O(\vga/video_ram/ram_addr_w [9])
  );
  defparam \vga/scancode_convert/hold_count_1 .LOC = "CLB_R14C26.S0";
  defparam \vga/scancode_convert/hold_count_1 .INIT = 1'b0;
  X_FF \vga/scancode_convert/hold_count_1  (
    .I(\vga/scancode_convert/hold_count__mux0000 [1]),
    .CE(VCC),
    .CLK(gray_cnt_FFd1_0),
    .SET(GND),
    .RST(\vga/scancode_convert/hold_count<1>/FFX/RST ),
    .O(\vga/scancode_convert/hold_count [1])
  );
  defparam \vga/scancode_convert/hold_count<1>/FFX/RSTOR .LOC = "CLB_R14C26.S0";
  X_BUF \vga/scancode_convert/hold_count<1>/FFX/RSTOR  (
    .I(\vga/scancode_convert/hold_count<1>/SRMUX_OUTPUTNOT ),
    .O(\vga/scancode_convert/hold_count<1>/FFX/RST )
  );
  defparam \vga/ps2/timer_r_3 .LOC = "CLB_R9C16.S0";
  defparam \vga/ps2/timer_r_3 .INIT = 1'b0;
  X_FF \vga/ps2/timer_r_3  (
    .I(\vga/ps2/timer_x [3]),
    .CE(VCC),
    .CLK(gray_cnt_FFd1_0),
    .SET(GND),
    .RST(\vga/ps2/timer_r<3>/FFX/RST ),
    .O(\vga/ps2/timer_r [3])
  );
  defparam \vga/ps2/timer_r<3>/FFX/RSTOR .LOC = "CLB_R9C16.S0";
  X_BUF \vga/ps2/timer_r<3>/FFX/RSTOR  (
    .I(\vga/ps2/timer_r<3>/SRMUX_OUTPUTNOT ),
    .O(\vga/ps2/timer_r<3>/FFX/RST )
  );
  defparam \vga/ps2/timer_r_5 .LOC = "CLB_R8C16.S0";
  defparam \vga/ps2/timer_r_5 .INIT = 1'b0;
  X_FF \vga/ps2/timer_r_5  (
    .I(\vga/ps2/timer_x [5]),
    .CE(VCC),
    .CLK(gray_cnt_FFd1_0),
    .SET(GND),
    .RST(\vga/ps2/timer_r<5>/FFX/RST ),
    .O(\vga/ps2/timer_r [5])
  );
  defparam \vga/ps2/timer_r<5>/FFX/RSTOR .LOC = "CLB_R8C16.S0";
  X_BUF \vga/ps2/timer_r<5>/FFX/RSTOR  (
    .I(\vga/ps2/timer_r<5>/SRMUX_OUTPUTNOT ),
    .O(\vga/ps2/timer_r<5>/FFX/RST )
  );
  defparam \vga/ps2/timer_r_9 .LOC = "CLB_R7C17.S0";
  defparam \vga/ps2/timer_r_9 .INIT = 1'b0;
  X_FF \vga/ps2/timer_r_9  (
    .I(\vga/ps2/timer_x [9]),
    .CE(VCC),
    .CLK(gray_cnt_FFd1_0),
    .SET(GND),
    .RST(\vga/ps2/timer_r<9>/FFX/RST ),
    .O(\vga/ps2/timer_r [9])
  );
  defparam \vga/ps2/timer_r<9>/FFX/RSTOR .LOC = "CLB_R7C17.S0";
  X_BUF \vga/ps2/timer_r<9>/FFX/RSTOR  (
    .I(\vga/ps2/timer_r<9>/SRMUX_OUTPUTNOT ),
    .O(\vga/ps2/timer_r<9>/FFX/RST )
  );
  defparam \vga/pclk_1 .LOC = "CLB_R14C6.S1";
  defparam \vga/pclk_1 .INIT = 1'b1;
  X_FF \vga/pclk_1  (
    .I(\vga/pclk__mux0000 [1]),
    .CE(VCC),
    .CLK(gray_cnt_FFd1_0),
    .SET(\vga/pclk<1>/FFX/SET ),
    .RST(GND),
    .O(\vga/pclk [1])
  );
  defparam \vga/pclk<1>/FFX/SETOR .LOC = "CLB_R14C6.S1";
  X_BUF \vga/pclk<1>/FFX/SETOR  (
    .I(\vga/pclk<1>/SRMUX_OUTPUTNOT ),
    .O(\vga/pclk<1>/FFX/SET )
  );
  defparam \vga/crt/cursor_h_1 .LOC = "CLB_R18C13.S1";
  defparam \vga/crt/cursor_h_1 .INIT = 1'b0;
  X_FF \vga/crt/cursor_h_1  (
    .I(\vga/crt/cursor_h_Eqn_1 ),
    .CE(\vga/crt/_not0006_0 ),
    .CLK(\vga/crtclk_4 ),
    .SET(GND),
    .RST(\vga/crt/cursor_h<1>/FFX/RST ),
    .O(\vga/crt/cursor_h [1])
  );
  defparam \vga/crt/cursor_h<1>/FFX/RSTOR .LOC = "CLB_R18C13.S1";
  X_BUF \vga/crt/cursor_h<1>/FFX/RSTOR  (
    .I(\vga/crt/cursor_h<1>/SRMUX_OUTPUTNOT ),
    .O(\vga/crt/cursor_h<1>/FFX/RST )
  );
  defparam \vga/crt/cursor_h_3 .LOC = "CLB_R17C13.S0";
  defparam \vga/crt/cursor_h_3 .INIT = 1'b0;
  X_FF \vga/crt/cursor_h_3  (
    .I(\vga/crt/cursor_h_Eqn_3 ),
    .CE(\vga/crt/_not0006_0 ),
    .CLK(\vga/crtclk_4 ),
    .SET(GND),
    .RST(\vga/crt/cursor_h<3>/FFX/RST ),
    .O(\vga/crt/cursor_h [3])
  );
  defparam \vga/crt/cursor_h<3>/FFX/RSTOR .LOC = "CLB_R17C13.S0";
  X_BUF \vga/crt/cursor_h<3>/FFX/RSTOR  (
    .I(\vga/crt/cursor_h<3>/SRMUX_OUTPUTNOT ),
    .O(\vga/crt/cursor_h<3>/FFX/RST )
  );
  defparam \vga/crt/cursor_h_5 .LOC = "CLB_R17C14.S0";
  defparam \vga/crt/cursor_h_5 .INIT = 1'b0;
  X_FF \vga/crt/cursor_h_5  (
    .I(\vga/crt/cursor_h_Eqn_5 ),
    .CE(\vga/crt/_not0006_0 ),
    .CLK(\vga/crtclk_4 ),
    .SET(GND),
    .RST(\vga/crt/cursor_h<5>/FFX/RST ),
    .O(\vga/crt/cursor_h [5])
  );
  defparam \vga/crt/cursor_h<5>/FFX/RSTOR .LOC = "CLB_R17C14.S0";
  X_BUF \vga/crt/cursor_h<5>/FFX/RSTOR  (
    .I(\vga/crt/cursor_h<5>/SRMUX_OUTPUTNOT ),
    .O(\vga/crt/cursor_h<5>/FFX/RST )
  );
  defparam \vga/scancode_convert/sc_1 .LOC = "CLB_R14C35.S0";
  defparam \vga/scancode_convert/sc_1 .INIT = 1'b0;
  X_FF \vga/scancode_convert/sc_1  (
    .I(\vga/ps2/sc_r [1]),
    .CE(\vga/scancode_convert/_and0000_0 ),
    .CLK(gray_cnt_FFd1_0),
    .SET(GND),
    .RST(GND),
    .O(\vga/scancode_convert/sc [1])
  );
  defparam \vga/scancode_convert/sc_3 .LOC = "CLB_R13C34.S1";
  defparam \vga/scancode_convert/sc_3 .INIT = 1'b0;
  X_FF \vga/scancode_convert/sc_3  (
    .I(\vga/ps2/sc_r [3]),
    .CE(\vga/scancode_convert/_and0000_0 ),
    .CLK(gray_cnt_FFd1_0),
    .SET(GND),
    .RST(GND),
    .O(\vga/scancode_convert/sc [3])
  );
  defparam \vga/scancode_convert/sc_5 .LOC = "CLB_R10C35.S0";
  defparam \vga/scancode_convert/sc_5 .INIT = 1'b0;
  X_FF \vga/scancode_convert/sc_5  (
    .I(\vga/ps2/sc_r [5]),
    .CE(\vga/scancode_convert/_and0000_0 ),
    .CLK(gray_cnt_FFd1_0),
    .SET(GND),
    .RST(GND),
    .O(\vga/scancode_convert/sc [5])
  );
  defparam \vga/rom_addr_char_1 .LOC = "CLB_R16C1.S0";
  defparam \vga/rom_addr_char_1 .INIT = 1'b0;
  X_FF \vga/rom_addr_char_1  (
    .I(\vga/ram_data_out [1]),
    .CE(VCC),
    .CLK(\vga/rom_addr_char<1>/CKMUXNOT ),
    .SET(GND),
    .RST(GND),
    .O(\vga/rom_addr_char [1])
  );
  defparam \vga/rom_addr_char_3 .LOC = "CLB_R27C1.S0";
  defparam \vga/rom_addr_char_3 .INIT = 1'b0;
  X_FF \vga/rom_addr_char_3  (
    .I(\vga/ram_data_out [3]),
    .CE(VCC),
    .CLK(\vga/rom_addr_char<3>/CKMUXNOT ),
    .SET(GND),
    .RST(GND),
    .O(\vga/rom_addr_char [3])
  );
  defparam \vga/rom_addr_char_5 .LOC = "CLB_R12C1.S0";
  defparam \vga/rom_addr_char_5 .INIT = 1'b0;
  X_FF \vga/rom_addr_char_5  (
    .I(\vga/ram_data_out [5]),
    .CE(VCC),
    .CLK(\vga/rom_addr_char<5>/CKMUXNOT ),
    .SET(GND),
    .RST(GND),
    .O(\vga/rom_addr_char [5])
  );
  defparam \vga/ps2/ps2_clk_r_2 .LOC = "CLB_R11C8.S1";
  defparam \vga/ps2/ps2_clk_r_2 .INIT = 1'b1;
  X_FF \vga/ps2/ps2_clk_r_2  (
    .I(\vga/ps2/ps2_clk_r [1]),
    .CE(VCC),
    .CLK(gray_cnt_FFd1_0),
    .SET(\vga/ps2/ps2_clk_r<2>/FFX/SET ),
    .RST(GND),
    .O(\vga/ps2/ps2_clk_r [2])
  );
  defparam \vga/ps2/ps2_clk_r<2>/FFX/SETOR .LOC = "CLB_R11C8.S1";
  X_BUF \vga/ps2/ps2_clk_r<2>/FFX/SETOR  (
    .I(\vga/ps2/ps2_clk_r<2>/SRMUX_OUTPUTNOT ),
    .O(\vga/ps2/ps2_clk_r<2>/FFX/SET )
  );
  defparam \vga/ps2/ps2_clk_r_4 .LOC = "CLB_R10C13.S0";
  defparam \vga/ps2/ps2_clk_r_4 .INIT = 1'b1;
  X_FF \vga/ps2/ps2_clk_r_4  (
    .I(\vga/ps2/ps2_clk_r [3]),
    .CE(VCC),
    .CLK(gray_cnt_FFd1_0),
    .SET(\vga/ps2/ps2_clk_r<4>/FFX/SET ),
    .RST(GND),
    .O(\vga/ps2/ps2_clk_r [4])
  );
  defparam \vga/ps2/ps2_clk_r<4>/FFX/SETOR .LOC = "CLB_R10C13.S0";
  X_BUF \vga/ps2/ps2_clk_r<4>/FFX/SETOR  (
    .I(\vga/ps2/ps2_clk_r<4>/SRMUX_OUTPUTNOT ),
    .O(\vga/ps2/ps2_clk_r<4>/FFX/SET )
  );
  defparam gray_cnt_FFd1.LOC = "CLB_R2C21.S0";
  defparam gray_cnt_FFd1.INIT = 1'b0;
  X_FF gray_cnt_FFd1 (
    .I(gray_cnt_FFd2_36),
    .CE(VCC),
    .CLK(clka_BUFGP),
    .SET(GND),
    .RST(\gray_cnt_FFd11/FFX/RST ),
    .O(gray_cnt_FFd11)
  );
  defparam \gray_cnt_FFd11/FFX/RSTOR .LOC = "CLB_R2C21.S0";
  X_BUF \gray_cnt_FFd11/FFX/RSTOR  (
    .I(\gray_cnt_FFd11/SRMUX_OUTPUTNOT ),
    .O(\gray_cnt_FFd11/FFX/RST )
  );
  defparam \vga/crt_data_1 .LOC = "CLB_R16C25.S0";
  defparam \vga/crt_data_1 .INIT = 1'b0;
  X_FF \vga/crt_data_1  (
    .I(\vga/scancode_convert/ascii [1]),
    .CE(VCC),
    .CLK(\vga/scancode_convert/strobe_out_15 ),
    .SET(GND),
    .RST(\vga/crt_data<1>/FFX/RST ),
    .O(\vga/crt_data [1])
  );
  defparam \vga/crt_data<1>/FFX/RSTOR .LOC = "CLB_R16C25.S0";
  X_BUF \vga/crt_data<1>/FFX/RSTOR  (
    .I(\vga/crt_data<1>/SRMUX_OUTPUTNOT ),
    .O(\vga/crt_data<1>/FFX/RST )
  );
  defparam \vga/crt_data_3 .LOC = "CLB_R16C21.S0";
  defparam \vga/crt_data_3 .INIT = 1'b0;
  X_FF \vga/crt_data_3  (
    .I(\vga/scancode_convert/ascii [3]),
    .CE(VCC),
    .CLK(\vga/scancode_convert/strobe_out_15 ),
    .SET(GND),
    .RST(\vga/crt_data<3>/FFX/RST ),
    .O(\vga/crt_data [3])
  );
  defparam \vga/crt_data<3>/FFX/RSTOR .LOC = "CLB_R16C21.S0";
  X_BUF \vga/crt_data<3>/FFX/RSTOR  (
    .I(\vga/crt_data<3>/SRMUX_OUTPUTNOT ),
    .O(\vga/crt_data<3>/FFX/RST )
  );
  defparam \vga/crt_data_5 .LOC = "CLB_R14C25.S1";
  defparam \vga/crt_data_5 .INIT = 1'b0;
  X_FF \vga/crt_data_5  (
    .I(\vga/scancode_convert/ascii [5]),
    .CE(VCC),
    .CLK(\vga/scancode_convert/strobe_out_15 ),
    .SET(GND),
    .RST(\vga/crt_data<5>/FFX/RST ),
    .O(\vga/crt_data [5])
  );
  defparam \vga/crt_data<5>/FFX/RSTOR .LOC = "CLB_R14C25.S1";
  X_BUF \vga/crt_data<5>/FFX/RSTOR  (
    .I(\vga/crt_data<5>/SRMUX_OUTPUTNOT ),
    .O(\vga/crt_data<5>/FFX/RST )
  );
  X_ONE GLOBAL_LOGIC1_VCC (
    .O(GLOBAL_LOGIC1)
  );
  X_ZERO GLOBAL_LOGIC0_GND (
    .O(GLOBAL_LOGIC0)
  );
  defparam \clka/PAD .LOC = "GCLKPAD1";
  X_IPAD \clka/PAD  (
    .PAD(clka)
  );
  defparam \vga/crtclk_BUFG/BUF .LOC = "GCLKBUF0";
  X_CKBUF \vga/crtclk_BUFG/BUF  (
    .I(\vga/crtclk1 ),
    .O(\vga/crtclk_4 )
  );
  defparam \clka_BUFGP/BUFG/BUF .LOC = "GCLKBUF1";
  X_CKBUF \clka_BUFGP/BUFG/BUF  (
    .I(clka),
    .O(clka_BUFGP)
  );
  defparam \gray_cnt_FFd1_BUFG/BUF .LOC = "GCLKBUF3";
  X_CKBUF \gray_cnt_FFd1_BUFG/BUF  (
    .I(gray_cnt_FFd11),
    .O(gray_cnt_FFd1_0)
  );
  X_ZERO NlwBlock_fpga_GND (
    .O(GND)
  );
  X_ONE NlwBlock_fpga_VCC (
    .O(VCC)
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

