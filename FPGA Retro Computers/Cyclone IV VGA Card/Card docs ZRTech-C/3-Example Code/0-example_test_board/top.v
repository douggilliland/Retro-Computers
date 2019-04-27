////////////////////////////////////////////////////
//功能：使用IP中的PLL产生多种时钟
//
//子模块：1、闪灯  2、蜂鸣器  3、数码管 4、按键 5、红外
//			6、PLL  7、AD		8、VGA
//
//版本：V0.00
//
//日期：20131008
////////////////////////////////////////////////////
module top(
	//Clock Input:48M
	input	 	CLK,
	//input key
	input	 	KEY1,KEY2,KEY3,KEY4,
	//红外
	input 	IRDA,
	//Bell
	output 	BP1,
	//AD
	input 	ADDAT,
	output 	ADCLK,ADCSN,
	//Digital tube
	output 	DS_A,DS_B,DS_E,DS_F,
	output	DS_EN1,DS_EN2,DS_EN3,DS_EN4,
	//Dual Purpose Pin LED
	output 	DS_C,DS_D,DS_G,DS_DP,
	//Serial COM
	output	RXD,
	input		TXD,
	//VGA
	output	V_SYNC,H_SYNC,
	output	[4:0]V_B,
	output	[4:0]V_R,
	output	[5:0]V_G
);
///////////////////////////////////////////
//			CLK MODULE (PLL)
///////////////////////////////////////////
reg  clk5k;
wire clk40k;
wire clk1m;
wire clk2m;
wire clk40m;
	pll pll_inst
	(
		.inclk0	(CLK),
		.c0		(clk40m),
		.c1		(clk40k),
		.c2		(clk1m),
		.c3		(clk2m)
	);
reg [2:0]cnt_5k;
	always @(posedge clk40k)
	begin
		cnt_5k = cnt_5k + 1;
		if(cnt_5k==3'h7)
			clk5k = !clk5k;
	end
///////////////////////////////////////////
//			LED MODULE
///////////////////////////////////////////
	wire [3:0]led;
//	assign {DS_D,DS_C,DS_G,DS_DP} = led;
	led_module led_ct(
		.clk(CLK),
		.en(1'b1),
		.led(led)
	);
///////////////////////////////////////////
//			BEEP MODULE	
///////////////////////////////////////////
wire bp_en;
	beep_module beep_ct(
		.clk(CLK),
		.en(bp_en),
		.beep(BP1)
	);
///////////////////////////////////////////
//			KEY MODULE
///////////////////////////////////////////	
wire [3:0]key_in = {KEY4,KEY1,KEY2,KEY3};
wire [3:0]key_value;
key_module key_ct(
	.clk(CLK),
	.key(key_in),
	.key_flag(key_value)
);	
///////////////////////////////////////////
//			DIGITAL TUBE MODULE
///////////////////////////////////////////	
wire [6:0]ds_reg;
wire [3:0]ds_en;
assign {DS_G,DS_F,DS_E,DS_D,DS_C,DS_B,DS_A} = ds_reg ;
assign {DS_EN1,DS_EN2,DS_EN3,DS_EN4} = ds_en;

reg  [3:0]num_dt[3:0];
	dt_module dt_ct(
	.clk(CLK),
	.num1(num_dt[0]),
	.num2(num_dt[1]),
	.num3(num_dt[2]),
	.num4(num_dt[3]),
	.ds_en(ds_en),
	.ds_reg(ds_reg)
);
assign DS_DP = 1'b1;
///////////////////////////////////////////
//			Serial COM MODULE
//	RXD: PL2303 input		——		FPGA output
//	TXD: PL2303 output 	——		FPGA input 	
///////////////////////////////////////////
assign RXD = TXD;
///////////////////////////////////////////
//			IRDA MODULE
///////////////////////////////////////////	
wire [7:0]ir_code;
ir_module ir_ct(
	.clk_1m(clk1m),
	.ir(IRDA),
	.Code(ir_code)
);
///////////////////////////////////////////
//			AD MODULE
///////////////////////////////////////////	
//always@(posedge clk5k)
//	V_G <= V_G + 1'b1;
		
wire [7:0]adc_data;
ad_module ad_ct(
	.clk1m(clk1m),
	.clk40k(clk40k),
	.adc_data_in(ADDAT),
	.adc_data(adc_data),
	.adc_clk(ADCLK),
	.adc_cs_n(ADCSN)
);

///////////////////////////////////////////
//			VGA MODULE
///////////////////////////////////////////
vga_module vga_ct(
	.clk40m(clk40m),
	.hsync(H_SYNC),
	.vsync(V_SYNC),
	.pixel({V_B,V_G,V_R})
);

///////////////////////////////////////////
//			TOP FUNCTION
///////////////////////////////////////////	
wire key_down = key_value[0] | key_value[1] |key_value[2] |key_value[3] ;
reg [31:0]cnt;
always @(posedge CLK)
	begin
		cnt = cnt + 1;
		num_dt[0] = ir_code[3:0];
		num_dt[1] = ir_code[7:4];
		num_dt[2] = key_value[0] ? cnt[25:22] : num_dt[2];
		num_dt[3] = key_down ? cnt[24:21] : num_dt[3];
	end
	
assign  bp_en = key_down;
endmodule



