////////////////////////////////////////////////////
//功能：按键输入使用移位寄存器去抖
//
//子模块：无
//
//版本：V0.00
//
//日期：20131003
////////////////////////////////////////////////////
module key_module(
	input	 clk,
	
	input  [3:0]key,
	output [3:0]key_flag
	
);
	//定义一个参数为输入时钟分配做准备
	parameter DIV_FACTOR = 32'd48_000;

	reg clk_khz;
	//标准计数器一只
	reg [31:0]cnt;
	always@(posedge clk)
		if(cnt == DIV_FACTOR/2)
			begin 
				cnt <= 32'b0; 
				clk_khz = !clk_khz;
			end
		else cnt <= cnt + 1'b1;
	
	reg	[31:0]key_reg0;
	reg	[31:0]key_reg1;
	reg	[31:0]key_reg2;
	reg	[31:0]key_reg3;
	always@(posedge clk_khz)
		begin 
			key_reg0 <= {key_reg0[30:0],!key[0]}; 
			key_reg1 <= {key_reg1[30:0],!key[1]}; 
			key_reg2 <= {key_reg2[30:0],!key[2]}; 
			key_reg3 <= {key_reg3[30:0],!key[3]}; 
		end
		
	assign key_flag[0] = (key_reg0 == 32'hffffffff);
	assign key_flag[1] = (key_reg1 == 32'hffffffff);
	assign key_flag[2] = (key_reg2 == 32'hffffffff);
	assign key_flag[3] = (key_reg3 == 32'hffffffff);

	
endmodule
