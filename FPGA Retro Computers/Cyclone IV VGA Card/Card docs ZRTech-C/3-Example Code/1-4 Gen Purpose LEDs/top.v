////////////////////////////////////////////////////
//功能：点亮2个LED(置低) 熄灭2个LED(置高)
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


assign DS_C 	= 1'b1;
assign DS_D 	= 1'b1;
assign DS_G 	= 1'b0;
assign DS_DP 	= 1'b0;

	
endmodule

