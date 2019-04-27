////////////////////////////////////////////////////
//功能：计数方式闪灯
//
//子模块：无
//
//版本：V0.00
//
//日期：20131003
////////////////////////////////////////////////////
module top(
	//Clock Input:48M
	input	 CLK,
	//Dual Purpose Pin LED
	output DS_C,DS_D,DS_G,DS_DP
);

	//定义一个参数为下面以秒计数做准备
	parameter SEC_TIME = 32'd48_000_000;

	wire [3:0]led ;
	assign {DS_C,DS_D,DS_G,DS_DP} = led;

	//定义计数器，并初始化为0
	//此处初始化仅对仿真有效，综合器会自动无视，下同
	reg	[31:0]cnt1;
	initial cnt1 = 32'b0;
	
	//定义hz级时钟
	reg clk_hz;
	initial clk_hz = 1'b0;

	//标准计数器一只
	always@(posedge CLK)
		if(cnt1 == SEC_TIME/2)
			begin 
				cnt1 <= 32'b0; 
				clk_hz = !clk_hz;
			end
		else cnt1 <= cnt1 + 1'b1;

assign led = {cnt1[24],cnt1[23],cnt1[22],cnt1[21]};

endmodule
