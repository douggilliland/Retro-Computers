////////////////////////////////////////////////////
//功能：数码管驱动，静态7段码
//
//子模块：1、闪灯 2、蜂鸣器
//
//版本：V0.00
//
//日期：20131003
////////////////////////////////////////////////////
module top(
	//Clock Input:48M
	input	 	CLK,
	//Bell
	output 	BP1,
	//Digital tube
	output 	DS_A,DS_B,DS_E,DS_F,
	output	DS_EN1,DS_EN2,DS_EN3,DS_EN4,
	//Dual Purpose Pin LED
	output 	DS_C,DS_D,DS_G,DS_DP
);

//LED MODULE
	wire [3:0]led;
//	assign {DS_D,DS_C,DS_G,DS_DP} = led;
	led_module led_ct(
		.clk(CLK),
		.en(1'b1),
		.led(led)
	);
//BEEP MODULE	
	beep_module beep_ct(
		.clk(CLK),
		.en(1'b0),
		.beep(BP1)
	);
	
parameter [6:0]NUM_0=7'b0111111;
parameter [6:0]NUM_1=7'b0000110;
parameter [6:0]NUM_2=7'b1011011;
parameter [6:0]NUM_3=7'b1001111;
parameter [6:0]NUM_4=7'b1100110;
parameter [6:0]NUM_5=7'b1101101;
parameter [6:0]NUM_6=7'b1111101;
parameter [6:0]NUM_7=7'b0000111;
parameter [6:0]NUM_8=7'b1111111;
parameter [6:0]NUM_9=7'b1101111;
parameter [6:0]NUM_B=7'b0000000;

parameter [7:0]EN_1=4'b1110;
parameter [7:0]EN_2=4'b1101;
parameter [7:0]EN_3=4'b1011;
parameter [7:0]EN_4=4'b0111;
parameter [3:0]EN_A=4'b0000;
	
assign {DS_G,DS_F,DS_E,DS_D,DS_C,DS_B,DS_A} = NUM_8 ;
assign {DS_EN1,DS_EN2,DS_EN3,DS_EN4} = EN_A;



endmodule
