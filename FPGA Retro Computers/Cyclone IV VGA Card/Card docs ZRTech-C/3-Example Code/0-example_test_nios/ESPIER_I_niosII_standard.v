/*
ESPIER_I_niosII_standard.v
This is a top level wrapper file that instanciates the
nios2 sopc builder system
*/

module ESPIER_I_niosII_standard(
	input						clk,
	input						resetn,
	
//	output		[  3: 0]	led,
	input			[  2: 0]	key,
	output					beep,
	input						rxd,
	output					txd,
	input 					irda,

	output 					ds_a,
	output					ds_b,
	output 					ds_c,
	output					ds_d,
	output					ds_e,
	output					ds_f,
	output					ds_g,
	output					ds_dp,
	output					ds_en1,
	output					ds_en2,
	output					ds_en3,
	output					ds_en4,
	
	output					ep_dclk,
	output					epcs_ncs,
	output					epcs_asdi,
	input						epcs_data,
	
	output		[ 12: 0]	sdram_addr,
	output		[  1: 0]	sdram_ba,
	output					sdram_cas_n,
	output					sdram_cke,
	output					sdram_cs_n,
	inout			[ 15: 0]	sdram_dq,
	output		[  1: 0]	sdram_dqm,
	output					sdram_ras_n,
	output					sdram_we_n,
	output					sdram_clk,

	input						flash_do,
	output					flash_di,
	output					flash_clk,
	output					flash_cs_n,

	input						adc_data,
	output					adc_clk,
	output					adc_cs_n,
	
	output reg	[  5: 0]	v_g,
	
	output					lcd_e,
	output					lcd_rs,
	output					lcd_rw,
	inout			[  7: 0]	lcd_data
);
	

//	clock
	wire						nios_clk;
	wire 						clk5k;
	wire 						clk40k;
	wire 						clk1m;

	pll pll_inst
	(
		.inclk0	(clk),
		.c0		(nios_clk),
		.c1		(sdram_clk)
	);
	
	pll1 pll1_inst
	(
		.inclk0	(clk),
		.c0		(clk5k),
		.c1		(clk40k),
		.c2		(clk1m),
	);

//  NIOS
	ESPIER_I_niosII_standard_sopc ESPIER_I_niosII_standard_sopc_inst
	(
		.clk											(nios_clk),
		.reset_n										(resetn),
      
		.out_port_from_the_led         		(num_dt[3]),

      .in_port_to_the_key            		(),
      .out_port_from_the_beep        		(),
		
		.rxd_to_the_uart               		(rxd),
      .txd_from_the_uart             		(txd),

		.data0_to_the_epcs_controller			(epcs_data),
		.dclk_from_the_epcs_controller		(ep_dclk),
		.sce_from_the_epcs_controller			(epcs_ncs),
		.sdo_from_the_epcs_controller			(epcs_asdi),

		.zs_addr_from_the_sdram					(sdram_addr),
		.zs_ba_from_the_sdram					(sdram_ba),
		.zs_cas_n_from_the_sdram				(sdram_cas_n),
		.zs_cke_from_the_sdram					(sdram_cke),
		.zs_cs_n_from_the_sdram					(sdram_cs_n),
		.zs_dq_to_and_from_the_sdram			(sdram_dq),
		.zs_dqm_from_the_sdram					(sdram_dqm),
		.zs_ras_n_from_the_sdram				(sdram_ras_n),
		.zs_we_n_from_the_sdram					(sdram_we_n),
		
		.MISO_to_the_spi_flash					(flash_do),
		.MOSI_from_the_spi_flash				(flash_di),
		.SCLK_from_the_spi_flash				(flash_clk),
		.SS_n_from_the_spi_flash				(flash_cs_n),
		
      .MISO_to_the_spi_adc           		(),
      .MOSI_from_the_spi_adc         		(),
      .SCLK_from_the_spi_adc         		(),
      .SS_n_from_the_spi_adc         		(),

      .LCD_E_from_the_lcd            		(lcd_e),
      .LCD_RS_from_the_lcd           		(lcd_rs),
      .LCD_RW_from_the_lcd           		(lcd_rw),
      .LCD_data_to_and_from_the_lcd  		(lcd_data)

	);
		
//	beep module	
	wire				bp_en;
	
	beep_module beep_ct
	(
		.clk			(clk),
		.en			(bp_en),
		.beep			(beep)
	);
	
//	key module
	wire [  2: 0]	key_value;
	
	key_module key_ct
	(
		.clk			(clk),
		.key			(key),
		.key_flag	(key_value)
	);
	
//	digital tube module
	wire [  6: 0]	ds_reg;
	wire [  3: 0]	ds_en;

	assign {ds_g,ds_f,ds_e,ds_d,ds_c,ds_b,ds_a} = ds_reg ;
	assign {ds_en1,ds_en2,ds_en3,ds_en4} = ds_en;

	reg  [  3: 0]	num_dt[  3: 0];

	dt_module dt_ct
	(
		.clk			(clk),
		.num1			(num_dt[0]),
		.num2			(num_dt[1]),
		.num3			(num_dt[2]),
		.num4			(num_dt[3]),
		.ds_en		(ds_en),
		.ds_reg		(ds_reg)
	);
	
//	irda module
	wire [  7: 0]	ir_code;

	ir_module ir_ct
	(
		.clk_1m		(clk1m),
		.ir			(irda),
		.code			(ir_code)
	);
	
//	ad module
	always@(posedge clk5k)
		v_g <= v_g + 1;
		
	wire [  7: 0]	adc_data_out;
	
	ad_module ad_ct
	(
		.clk1m			(clk1m),
		.clk40k			(clk40k),
		.adc_data_in	(adc_data),
		.adc_data		(adc_data_out),
		.adc_clk			(adc_clk),
		.adc_cs_n		(adc_cs_n)
	);
	
// initial
	wire key_down = key_value[0] | key_value[1] | key_value[2];
	reg [31:0]cnt;
	
	always @(posedge clk)
		begin
			cnt = cnt + 1;
			num_dt[0] = ir_code[3:0];
			num_dt[1] = ir_code[7:4];
			num_dt[2] = key_down ? cnt[24:21] : num_dt[2];
		end
	
	assign  bp_en = key_down;
	
endmodule
