////////////////////////////////////////////////////
//功能：移位闪灯 3段注释是不同功能
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
	assign {DS_D,DS_C,DS_G,DS_DP} = led;

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
	
//	//移位寄存器 逐个变亮
//	reg [3:0]led_reg;
//	always@(posedge clk_hz)
//		begin
//			if(led_reg == 4'b0000)
//				led_reg = 4'b1111;
//			else
//				led_reg = {led_reg[2:0],1'b0};
//		end

//	//移位寄存器 逐个变暗
//	reg [3:0]led_reg;
//	always@(posedge clk_hz)
//		begin
//			if(led_reg == 4'b1111)
//				led_reg = 4'b0000;
//			else
//				led_reg = {led_reg[2:0],1'b1};
//		end

//	//移位寄存器 单灯遍历
//	reg [3:0]led_reg;
//	always@(posedge clk_hz)
//		begin
//			if(led_reg == 4'b0000)
//				led_reg = 4'b1110;
//			else if(led_reg == 4'b1111)
//				led_reg = 4'b1110;
//			else if(led_reg == 4'b1110)
//				led_reg = 4'b1101;
//			else if(led_reg == 4'b1101)
//				led_reg = 4'b1011;
//			else if(led_reg == 4'b1011)
//				led_reg = 4'b0111;
//			else if(led_reg == 4'b1011)
//				led_reg = 4'b0111;
//			else if(led_reg == 4'b0111)
//				led_reg = 4'b1110;
//			else
//				led_reg = 4'b1110;
//		end
	
	//移位寄存器 双灯遍历
	reg [3:0]led_reg;
	always@(posedge clk_hz)
		begin
			if(led_reg == 4'b0000)
				led_reg = 4'b1100;
			else if(led_reg == 4'b1111)
				led_reg = 4'b1100;
			else if(led_reg == 4'b1100)
				led_reg = 4'b1001;
			else if(led_reg == 4'b1001)
				led_reg = 4'b0011;
			else if(led_reg == 4'b0011)
				led_reg = 4'b0110;
			else if(led_reg == 4'b0110)
				led_reg = 4'b1100;
			else
				led_reg = 4'b1100;
		end

		assign led = led_reg;  

endmodule
