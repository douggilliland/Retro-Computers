////////////////////////////////////////////////////
//功能：使用位拼接，点亮2个LED(置低)，熄灭2个LED(置高)
//
//子模块：无
//
//版本：V0.00
//
//日期：20131003
////////////////////////////////////////////////////
module top(
	//Dual Purpose Pin LED
	output DS_C,DS_D,DS_G,DS_DP
);

wire [3:0]led ;

assign {DS_C,DS_D,DS_G,DS_DP} = led;

assign led 	= 4'b0011;

endmodule
