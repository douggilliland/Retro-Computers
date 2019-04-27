////////////////////////////////////////////////////
//功能：任意按键按下，数码管按顺序增加，计数从0-9、A-F
//
//子模块：1、闪灯  2、蜂鸣器  3、数码管 4、按键
//
//版本：V0.00
//
//日期：20131007
////////////////////////////////////////////////////
module top(
	//Clock Input:48M
	input	 	CLK,
	//input key
	input	 	KEY1,KEY2,KEY3,KEY4,
	//Bell
	output 	BP1,
	//Digital tube
	output 	DS_A,DS_B,DS_E,DS_F,
	output	DS_EN1,DS_EN2,DS_EN3,DS_EN4,
	//Dual Purpose Pin LED
	output 	DS_C,DS_D,DS_G,DS_DP
);
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
	beep_module beep_ct(
		.clk(CLK),
		.en(1'b0),
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

///////////////////////////////////////////
//			TOP FUNCTION
///////////////////////////////////////////	
reg [31:0]cnt;
always @(posedge CLK)
	begin
		cnt = cnt + 1;
		num_dt[0] = key_value[0] ? cnt[25:22] : num_dt[0];
		num_dt[1] = key_value[1] ? cnt[26:23] : num_dt[1];
		num_dt[2] = key_value[2] ? cnt[27:24] : num_dt[2];
		num_dt[3] = key_value[3] ? cnt[28:25] : num_dt[3];
	end
	
endmodule



