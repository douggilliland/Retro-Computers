////////////////////////////////////////////////////
//功能：1KHz频率驱动蜂鸣器
//
//子模块：闪灯
//
//版本：V0.00
//
//日期：20131003
////////////////////////////////////////////////////
module top(
	//Clock Input:48M
	input	 CLK,
	//Bell
	output BP1,
	//Dual Purpose Pin LED
	output DS_C,DS_D,DS_G,DS_DP
);

	wire [3:0]led ;
	assign {DS_D,DS_C,DS_G,DS_DP} = led;

	led_module led_ct(
		.clk(CLK),
		.led(led)
	);
	
	parameter DIV_KHZ = 32'd48_000;
	reg[31:0]cnt_khz;
	reg clk_1k;

	always@(posedge CLK)
		if(cnt_khz == DIV_KHZ/2)
			begin 
				cnt_khz <= 32'b0; 
				clk_1k = !clk_1k;
			end
		else cnt_khz <= cnt_khz + 1'b1;	
	
	assign BP1 = clk_1k;
	

endmodule
