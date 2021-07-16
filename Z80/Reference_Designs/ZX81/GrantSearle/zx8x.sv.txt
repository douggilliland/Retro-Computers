//============================================================================
// 
//  ZX80-ZX81 replica for MiST
//  Copyright (C) 2018 György Szombathelyi
//
//  This program is free software; you can redistribute it and/or modify it
//  under the terms of the GNU General Public License as published by the Free
//  Software Foundation; either version 2 of the License, or (at your option)
//  any later version.
//
//  This program is distributed in the hope that it will be useful, but WITHOUT
//  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
//  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
//  more details.
//
//  You should have received a copy of the GNU General Public License along
//  with this program; if not, write to the Free Software Foundation, Inc.,
//  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
//
//============================================================================

`default_nettype none

module zx8x
(
   input         CLOCK_27,   // Input clock 27 MHz

   output  [5:0] VGA_R,
   output  [5:0] VGA_G,
   output  [5:0] VGA_B,
   output        VGA_HS,
   output        VGA_VS,

   output        LED,

   output        AUDIO_L,
   output        AUDIO_R,

	input         UART_RX,

   input         SPI_SCK,
   output        SPI_DO,
   input         SPI_DI,
   input         SPI_SS2,
   input         SPI_SS3,
   input         CONF_DATA0,

   output [12:0] SDRAM_A,
   inout  [15:0] SDRAM_DQ,
   output        SDRAM_DQML,
   output        SDRAM_DQMH,
   output        SDRAM_nWE,
   output        SDRAM_nCAS,
   output        SDRAM_nRAS,
   output        SDRAM_nCS,
   output  [1:0] SDRAM_BA,
   output        SDRAM_CLK,
   output        SDRAM_CKE
);

assign LED = ~ioctl_download & ~tape_ready;

`include "build_id.v"
localparam CONF_STR = 
{
	"ZX8X;;",
	"F,O  P  ,Load tape;",
	"O4,Model,ZX80,ZX81;",
	"OAB,RAM size,1k,16k,32k,64k;",
   "OC,CHR128 support,Off,On;",
	"O8,Swap joy axle,Off,On;",
	"O6,Video frequency,50Hz,60Hz;",
	"O7,Inverse video,Off,On;",
	"O9,Scanlines,Off,On;",
	"T0,Reset;",
	"V,v1.0.",`BUILD_DATE
};


////////////////////   CLOCKS   ///////////////////
wire clk_sys;
wire locked;

pll pll
(
	.inclk0(CLOCK_27),
	.c0(clk_sys), //52 MHz
	.locked(locked)
);

reg  ce_cpu_p;
reg  ce_cpu_n;
reg  ce_13,ce_65,ce_psg;

always @(negedge clk_sys) begin
	reg [4:0] counter = 0;

	counter  <=  counter + 1'd1;
	ce_cpu_p <= !counter[3] & !counter[2:0];
	ce_cpu_n <=  counter[3] & !counter[2:0];
	ce_65    <= !counter[2:0];
	ce_13    <= !counter[1:0];
	ce_psg   <= !counter[4:0];
end

//////////////////   MIST ARM I/O   ///////////////////
wire [10:0] ps2_key;
wire [24:0] ps2_mouse;

wire  [7:0] joystick_0;
wire  [7:0] joystick_1;
wire  [1:0] buttons;
wire  [1:0] switches;
wire        scandoubler_disable;
wire        ypbpr;
wire [31:0] status;

wire        ioctl_wr;
wire [13:0] ioctl_addr;
wire  [7:0] ioctl_dout;
wire        ioctl_download;
wire  [7:0] ioctl_index;
mist_io #(.STRLEN($size(CONF_STR)>>3)) user_io
(
	.clk_sys(clk_sys),
	.CONF_DATA0(CONF_DATA0),
	.SPI_SCK(SPI_SCK),
	.SPI_DI(SPI_DI),
	.SPI_DO(SPI_DO),
	.SPI_SS2(SPI_SS2),
	
	.conf_str(CONF_STR),

	.status(status),
	.scandoubler_disable(scandoubler_disable),
	.ypbpr(ypbpr),
	.buttons(buttons),
	.switches(switches),
	.joystick_0(joystick_0),
	.joystick_1(joystick_1),
	.ps2_key(ps2_key),

	.sd_conf(0),
	.sd_sdhc(1),
	.ioctl_ce(1),
	.ioctl_wr(ioctl_wr),
	.ioctl_addr(ioctl_addr),
	.ioctl_dout(ioctl_dout),
	.ioctl_download(ioctl_download),
	.ioctl_index(ioctl_index),

	// unused
	.ps2_kbd_clk(),
	.ps2_kbd_data(),
	.ps2_mouse_clk(),
	.ps2_mouse_data(),
	.joystick_analog_0(),
	.joystick_analog_1(),
	.sd_ack_conf()
);


///////////////////   CPU   ///////////////////
wire [15:0] addr;
wire  [7:0] cpu_din;
wire  [7:0] cpu_dout;
wire        nM1;
wire        nMREQ;
wire        nIORQ;
wire        nRD;
wire        nWR;
wire        nRFSH;
wire        nHALT;
wire        nINT = addr[6];
wire        nNMI;
wire        nWAIT;
reg       	reset;

T80pa cpu
(
	.RESET_n(~reset),
	.CLK(clk_sys),
	.CEN_p(ce_cpu_p),
	.CEN_n(ce_cpu_n),
	.WAIT_n(nWAIT),
	.INT_n(nINT),
	.NMI_n(nNMI),
	.BUSRQ_n(1),
	.M1_n(nM1),
	.MREQ_n(nMREQ),
	.IORQ_n(nIORQ),
	.RD_n(nRD),
	.WR_n(nWR),
	.RFSH_n(nRFSH),
	.HALT_n(nHALT),
	.A(addr),
	.DO(cpu_dout),
	.DI(cpu_din)
);

wire [7:0] io_dout = kbd_n ? (psg_sel ? psg_out : 8'hFF) : { tape_in, hz50, 1'b0, key_data[4:0] & ({5{addr[12]}} | ~joykeys) };

always_comb begin
	case({nMREQ, ~nM1 | nIORQ | nRD})
	    'b01: cpu_din = (~nM1 & nopgen) ? 8'h0 : mem_out;
	    'b10: cpu_din = io_dout;
	 default: cpu_din = 8'hFF;
	endcase
end

wire       tape_in = ~UART_RX;
reg        init_reset = 1;
reg        zx81;
reg  [1:0] mem_size; //00-1k, 01 - 16k 10 - 32k
wire       hz50 = ~status[6];
wire       joyrev = status[8];
wire [4:0] joykeys = joyrev ? {joystick_0[2], joystick_0[3], joystick_0[0], joystick_0[1], joystick_0[4]} :
										{joystick_0[1:0], joystick_0[2], joystick_0[3], joystick_0[4]};

always @(posedge clk_sys) begin
	reg old_download;
	old_download <= ioctl_download;
	if(~ioctl_download && old_download && !ioctl_index) init_reset <= 0;
	if(~ioctl_download && old_download && ioctl_index) tape_ready <= 1;
	
	reset <= buttons[1] | status[0] | (mod[1] & Fn[11]) | init_reset;
	if (reset) begin
		zx81 <= status[4];
		mem_size <= status[11:10];
		tape_ready <= 0;
	end
end

//////////////////   MEMORY   //////////////////
assign SDRAM_CLK = clk_sys;

sdram ram
(
	.*,
	.init(~locked),
	.clk(clk_sys),
	.wtbt(0),
	.dout(ram_out),
	.din (ram_in),
	.addr(ram_a),
	.we(ram_we | tapewrite_we),
	.rd(ram_e & (~nRFSH | (~nRD & ~nMREQ)) & ~ce_cpu_n & ~tapeloader),
	.ready(ram_ready)
);

wire        ram_ready;
reg   [7:0] rom[12288];
wire [12:0] rom_a  = nRFSH ? addr[12:0] : { addr[12:9], ram_data_latch[5:0], row_counter };
wire [15:0] tape_load_addr = 16'h4000 + ((ioctl_index[7:6] == 1) ? tape_addr + 4'd8 : tape_addr-1'd1);
wire [15:0] ram_a;
wire        ram_e_64k = &mem_size & (addr[13] | (addr[15] & nM1));
wire        rom_e  = ~addr[14] & (~addr[12] | zx81) & ~ram_e_64k & ~chr128_mem;
wire        ram_e  = addr[14] | ram_e_64k | chr128_mem;
wire        ram_we = ~nWR & ~nMREQ & ram_e;
wire  [7:0] ram_in = tapeloader ? tape_in_byte : cpu_dout;
wire  [7:0] rom_out;
wire  [7:0] ram_out;
wire  [7:0] mem_out;

wire        chr128 = status[12];
wire        chr128_mem = chr128 & (addr[15:12] == 4'h3);

always_comb begin
	casex({ tapeloader, rom_e, ram_e })
		'b110: mem_out = tape_loader_patch[addr - (zx81 ? 13'h0347 : 13'h0207)];
		'b010: mem_out = rom_out;
		'b001: mem_out = ram_out;
		default: mem_out = 8'd0;
	endcase

    casex({tapeloader, mem_size, chr128_mem })
        'b1_XX_X: ram_a = tape_load_addr;
        'b0_00_0: ram_a = { 6'b010000,             addr[9:0] }; //1k
        'b0_01_0: ram_a = { 2'b01,                addr[13:0] }; //16k
        'b0_10_0: ram_a = { 1'b0, addr[15] & nM1, addr[13:0] } + 16'h4000; //32k
        'b0_11_0: ram_a = { addr[15] & nM1,       addr[14:0] }; //64k
        'b0_XX_1: ram_a = nRFSH ? addr[15:0] : { addr[15:10], addr[8] & ram_data_latch[7], ram_data_latch[5:0], row_counter }; //chr
    endcase
end

always @(posedge clk_sys) begin
	if (ioctl_wr & !ioctl_index) begin
		rom[ioctl_addr] <= ioctl_dout;
	end
end

always @(posedge clk_sys) begin
	rom_out <= rom[{ (zx81 ? rom_a[12] : 2'h2), rom_a[11:0] }];
end

////////////////////  TAPE  //////////////////////
reg   [7:0] tape_ram[16384];
reg         tapeloader, tapewrite_we;
reg  [13:0] tape_addr;
reg   [7:0] tape_in_byte;
reg         tape_ready;  // there is data in the tape memory
// patch the load ROM routines to loop until the memory is filled from $4000(.o file ) $4009 (.p file)
// xor a; loop: nop or scf, jr nc loop, jp h0207 (jp h0203 - ZX80)
reg   [7:0] tape_loader_patch[7] = '{8'haf, 8'h00, 8'h30, 8'hfd, 8'hc3, 8'h07, 8'h02};

always @(posedge clk_sys) begin
	if (ioctl_wr & ioctl_index) begin
		tape_ram[ioctl_addr] <= ioctl_dout;
	end
end

always @(posedge clk_sys) begin
	tape_in_byte <= tape_ram[tape_addr];
end

always @(posedge clk_sys) begin
	reg old_nM1;
	
	old_nM1 <= nM1;
	tapewrite_we <= 0;
	
	if (~nM1 & old_nM1 & tape_ready) begin
		if (zx81) begin
			if (addr == 16'h0347) begin
				tape_loader_patch[1] <= 8'h00; //nop
				tape_loader_patch[5] <= 8'h07; //0207h
				tape_addr <= 14'h0;
				tapeloader <= 1;
			end
			if (addr >= 16'h03c3 || addr < 16'h0347) begin
				tapeloader <= 0;
			end
		end else begin
			if (addr == 16'h0207) begin
				tape_loader_patch[1] <= 8'h00; //nop
				tape_loader_patch[5] <= 8'h03; //0203h
				tape_addr <= 14'h0;
				tapeloader <= 1;
			end
			if (addr >= 16'h024d || addr < 16'h0207) begin
				tapeloader <= 0;
			end
		end
	end

	if (tapeloader & ce_cpu_p) begin
		if (tape_addr != ioctl_addr) begin
			tape_addr <= tape_addr + 1'h1;
			tapewrite_we <= 1;
		end else begin
			tape_loader_patch[1] <= 8'h37; //scf
		end
	end
end

////////////////////  VIDEO //////////////////////
// Based on the schematic:
// http://searle.hostei.com/grant/zx80/zx80.html

// character generation
wire      nopgen = addr[15] & ~mem_out[6] & nHALT;
wire      data_latch_enable = nRFSH & ce_cpu_n & ~nMREQ;
reg [7:0] ram_data_latch;
reg       nopgen_store;
reg [2:0] row_counter;
wire      shifter_start = nMREQ & nopgen_store & ce_cpu_p & (~zx81 | ~NMIlatch);
reg [7:0] shifter_reg;
wire      video_out = (~status[7] ^ shifter_reg[7] ^ inverse) & !back_porch_counter & csync;
reg       inverse;

reg[4:0]  back_porch_counter = 1;

always @(posedge clk_sys) begin
	reg old_csync;
	reg old_shifter_start;
	
	old_csync <= csync;
	old_shifter_start <= shifter_start;

	if (data_latch_enable) begin
		ram_data_latch <= mem_out;
		nopgen_store <= nopgen;
	end

	if (nMREQ & ce_cpu_p) inverse <= 0;

	if (~old_shifter_start & shifter_start) begin
		shifter_reg <= (~nM1 & nopgen) ? 8'h0 : mem_out;
		inverse <= ram_data_latch[7];
	end else if (ce_65) begin
		shifter_reg <= { shifter_reg[6:0], 1'b0 };
	end

	if (old_csync & ~csync)	row_counter <= row_counter + 1'd1;
	if (~vsync) row_counter <= 0;

	if (~old_csync & csync) back_porch_counter <= 1;
   if (ce_65 && back_porch_counter) back_porch_counter <= back_porch_counter + 1'd1;

	end

// ZX80 sync generator
reg ic11,ic18,ic19_1,ic19_2;
//wire csync = ic19_2; //ZX80 original
wire csync = vsync & hsync;
wire vsync = ic11;

always @(posedge clk_sys) begin

	reg old_nM1;
	old_nM1 <= nM1;

	if (~(nIORQ | nWR) & (~zx81 | ~NMIlatch)) ic11 <= 1; // stop vsync - any OUT
	if (~kbd_n & (~zx81 | ~NMIlatch)) ic11 <= 0; // start vsync - keyboard IN

	if (~nIORQ) ic18 <= 1;  // if IORQ - preset HSYNC start
	if (~ic19_2) ic18 <= 0; // if sync active - preset sync end

	// And 2 M1 later the presetted sync arrives at the csync pin
	if (old_nM1 & ~nM1) begin
		ic19_1 <= ~ic18;
		ic19_2 <= ic19_1;
	end
	if (~ic11) ic19_2 <= 0; //vsync keeps csync low
end

// ZX81 upgrade
// http://searle.hostei.com/grant/zx80/zx80nmi.html

wire      hsync = ~(sync_counter >= 16 && sync_counter <= 31);
reg       NMIlatch;
reg [7:0] sync_counter = 0;

assign nWAIT = ~(nHALT & ~nNMI) | ~zx81;
assign nNMI = ~(NMIlatch & ~hsync) | ~zx81;

always @(posedge clk_sys) begin
	reg       old_cpu_n;

	old_cpu_n <= ce_cpu_n;

	if (old_cpu_n & ~ce_cpu_n) begin
		sync_counter <= sync_counter + 1'd1;
	   if (sync_counter == 8'd206 | (~nM1 & ~nIORQ)) sync_counter <= 0;
	end

	if (zx81) begin
		if (~nIORQ & ~nWR & (addr[0] ^ addr[1])) NMIlatch <= addr[1];
	end
end

wire       v_sd_out, HS_sd_out, VS_sd_out;

scandoubler scandoubler
(
	.clk(clk_sys),
	.ce_2pix(ce_13),

	.scanlines(status[9]),

	.csync(csync),
	.v_in(video_out),

	.hs_out(HS_sd_out),
	.vs_out(VS_sd_out),
	.v_out(v_sd_out)
);

wire [5:0] R_out,G_out,B_out;
osd osd
(
	.*,
	.R_in((scandoubler_disable ? video_out : v_sd_out) ? 6'b111111 : 6'd0),
	.G_in((scandoubler_disable ? video_out : v_sd_out) ? 6'b111111 : 6'd0),
	.B_in((scandoubler_disable ? video_out : v_sd_out) ? 6'b111111 : 6'd0),
	
	.R_out(R_out),
	.G_out(G_out),
	.B_out(B_out),
	.HSync(scandoubler_disable ? hsync : HS_sd_out),
	.VSync(scandoubler_disable ? vsync : VS_sd_out)
);

wire [5:0] y, pb, pr;
rgb2ypbpr rgb2ypbpr 
(
	.red   ( R_out ),
	.green ( G_out ),
	.blue  ( B_out ),
	.y     ( y     ),
	.pb    ( pb    ),
	.pr    ( pr    )
);

assign VGA_HS = scandoubler_disable ? csync : (ypbpr ? !(HS_sd_out ^ VS_sd_out) : HS_sd_out);
assign VGA_VS = (scandoubler_disable || ypbpr) ? 1'd1 : VS_sd_out;
assign VGA_R = ypbpr?pr:R_out;
assign VGA_G = ypbpr? y:G_out;
assign VGA_B = ypbpr?pb:B_out;

////////////////////  SOUND //////////////////////
wire [7:0] psg_out;
wire       psg_sel = ~nIORQ & &addr[3:0]; //xF
wire [7:0] psg_ch_a, psg_ch_b, psg_ch_c;

YM2149 psg
(
	.CLK(clk_sys),
	.CE(ce_psg),
	.RESET(reset),
	.BDIR(psg_sel & ~nWR),
	.BC(psg_sel & (&addr[7:6] ^ nWR)),
	.DI(cpu_dout),
	.DO(psg_out),
	.CHANNEL_A(psg_ch_a),
	.CHANNEL_B(psg_ch_b),
	.CHANNEL_C(psg_ch_c)
);

// Route vsync through a high-pass filter to filter out sync signals from the
// tape audio
wire [7:0] mic_out;
wire       mic_bit = mic_out > 8'd8 && mic_out < 8'd224;

rc_filter_1o #(
	.R_ohms_g(33000),
	.C_p_farads_g(47000),
	.fclk_hz_g(6500000),
	.cwidth_g(18)) mic_filter
(
	.clk_i(clk_sys),
	.clken_i(ce_65),
	.res_i(reset),
	.din_i({1'b0, vsync, 6'd0 }),
	.dout_o(mic_out)
);

wire [8:0] audio_l = { 1'b0, psg_ch_a } + { 1'b0, psg_ch_c } + { mic_bit, 4'd0 };
wire [8:0] audio_r = { 1'b0, psg_ch_b } + { 1'b0, psg_ch_c } + { mic_bit, 4'd0 };

sigma_delta_dac #(7) dac_l
(
	.CLK(clk_sys),
	.RESET(reset),
	.DACin(audio_l[8:1]),
	.DACout(AUDIO_L)
);

sigma_delta_dac #(7) dac_r
(
	.CLK(clk_sys),
	.RESET(reset),
	.DACin(audio_r[8:1]),
	.DACout(AUDIO_R)
);
////////////////////   HID   /////////////////////

wire kbd_n = nIORQ | nRD | addr[0];

wire [11:1] Fn;
wire  [2:0] mod;
wire  [4:0] key_data;

keyboard kbd( .* );

endmodule
