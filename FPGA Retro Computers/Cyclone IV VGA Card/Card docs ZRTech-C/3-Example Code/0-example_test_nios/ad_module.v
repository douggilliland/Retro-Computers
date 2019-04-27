////////////////////////////////////////////////////
//功能：ad
//
//子模块：无
//
//版本：V0.00
//
//日期：20131003
////////////////////////////////////////////////////
module ad_module(
	input					clk1m,
	input 				clk40k,
	input					adc_data_in,
	output reg	[7: 0]adc_data,
	output 				adc_clk,
	output reg			adc_cs_n
);
	
	reg	[7: 0]		adc_data_buf;
	
	reg	[3: 0]		cnt;
	reg					adc_clk_valid;
	reg					adc_cs_n_valid;


	
	always@(posedge clk1m)
	begin
		if(clk40k == 0)
			cnt <= 0;
		else if(cnt == 10)
			cnt <= 10;
		else
			cnt <= cnt + 1'b1;
			
		adc_clk_valid <= !((cnt == 0) | (cnt == 1) | (cnt == 10));
		adc_cs_n <= (cnt == 0) | (cnt == 10);

		end
	
	assign adc_clk = adc_clk_valid ? clk1m : 1'b0;

	always@(posedge adc_clk)
		if(adc_cs_n == 0)
			adc_data_buf <= {adc_data_in, adc_data_buf[7:1]};

	always@(posedge clk40k)
		adc_data <= adc_data_buf;
		
endmodule
