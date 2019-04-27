////////////////////////////////////////////////////
//功能：同步闪灯
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
	parameter SEC_TIME = 48_000_000;

	wire [3:0]led ;
	assign {DS_C,DS_D,DS_G,DS_DP} = led;

	//定义计数器，并初始化为0
	//此处初始化仅对仿真有效，综合器会自动无视，下同
	reg	[31:0]		cnt1;
	initial cnt1 = 32'b0;
	//定义hz级时钟
	reg clk_hz;
	initial clk_hz = 1'b0;

	//标准计数器一只
	always@(posedge CLK)
		if(cnt1 == SEC_TIME/2) 
			begin 
				cnt1 <= 0; 
				clk_hz = !clk_hz;
			end
		else cnt1 <= cnt1 + 1;

assign led = {clk_hz,clk_hz,clk_hz,clk_hz};

endmodule




//`endif
//
//`ifndef led_demo
//	//关闭数码管，一心一意的用LED Play show
//	assign {DS_EN1,DS_EN2,DS_EN3,DS_EN4} = {4'b1111};
//	
//	wire sys_clk = CLK;
//	wire sys_rstn = 1; 
//	reg [3:0] led_out;
//	initial led_out = 4'h0;
//
//	parameter T48M=26'd48_000_000;
//	reg [25:0] Count;
//	initial Count = 26'h0;
//	reg [1:0] i;
//	initial i = 2'h0;
//	reg led;
//	initial led = 1'h0;
//
//	always@(posedge sys_clk or negedge sys_rstn)
//	begin
//		 if(!sys_rstn)
//			  Count<=26'b0;
//		 else
//			  if(Count==T48M)
//			  begin
//					Count<=26'b0;
//					i<=i+1'b1;
//			  end
//			  else
//					Count<=Count+1'b1;
//	end
//
//	 
//	always@(i)
//	begin
//		if(i==2'b00)
//			begin
//				led <= 0;
//				led_out<={led,3'b110};
//			end
//		else if(i==2'b01)
//			begin
//				led <= 1;
//				led_out<={led,3'b101};
//			end
//		else if(i==2'b10)
//			begin
//				led <= 0;
//				led_out<={led,3'b011};
//			end
//		else if(i==2'b11)
//			begin
//				led <= 1;
//				led_out<={led,3'b111};
//			end
//	end    
//	
//	assign {DS_DP,DS_G,DS_C,DS_D} = led_out;
//`endif
//	
//endmodule
