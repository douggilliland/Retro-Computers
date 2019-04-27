////////////////////////////////////////////////////
//功能：数码管驱动，动态7段码
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
	
//DIGITAL TUBE MODULE
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
parameter [6:0]NUM_A=7'b1110111;
parameter [6:0]NUM_B=7'b1111100;
parameter [6:0]NUM_C=7'b1011000;
parameter [6:0]NUM_D=7'b1011110;
parameter [6:0]NUM_E=7'b1111001;
parameter [6:0]NUM_F=7'b1110001;
parameter [6:0]NUM_BLK=7'b0000000;

parameter [3:0]EN_1=4'b1110;
parameter [3:0]EN_2=4'b1101;
parameter [3:0]EN_3=4'b1011;
parameter [3:0]EN_4=4'b0111;
parameter [3:0]EN_A=4'b0000;


reg  [3:0]num_dt[3:0];
reg [6:0]ds_reg;
reg [3:0]ds_en;
assign {DS_G,DS_F,DS_E,DS_D,DS_C,DS_B,DS_A} = ds_reg ;
assign {DS_EN1,DS_EN2,DS_EN3,DS_EN4} = ds_en;

reg [31:0]cnt_dt;
always @(posedge CLK)
	begin
		cnt_dt = cnt_dt + 1'b1;
	end

always @(posedge CLK)
	begin
			case (cnt_dt[27:24])
			4'h0 :   begin ds_reg = NUM_0; ds_en=EN_A;end
			4'h1 :   begin ds_reg = NUM_1; ds_en=EN_A;end
			4'h2 :   begin ds_reg = NUM_2; ds_en=EN_A;end
			4'h3 :   begin ds_reg = NUM_3; ds_en=EN_A;end
			4'h4 :   begin ds_reg = NUM_4; ds_en=EN_A;end
			4'h5 :   begin ds_reg = NUM_5; ds_en=EN_A;end
			4'h6 :   begin ds_reg = NUM_6; ds_en=EN_A;end
			4'h7 :   begin ds_reg = NUM_7; ds_en=EN_A;end
			4'h8 :   begin ds_reg = NUM_8; ds_en=EN_A;end
			4'h9 :   begin ds_reg = NUM_9; ds_en=EN_A;end
			4'ha :   begin ds_reg = NUM_A; ds_en=EN_A;end
			4'hb :   begin ds_reg = NUM_B; ds_en=EN_A;end
			4'hc :   begin ds_reg = NUM_C; ds_en=EN_A;end
			4'hd :   begin ds_reg = NUM_D; ds_en=EN_A;end
			4'he :   begin ds_reg = NUM_E; ds_en=EN_A;end
			4'hf :   begin ds_reg = NUM_F; ds_en=EN_A;end
			default: begin ds_reg = NUM_BLK; ds_en=EN_A;end
			endcase  
	end
endmodule



