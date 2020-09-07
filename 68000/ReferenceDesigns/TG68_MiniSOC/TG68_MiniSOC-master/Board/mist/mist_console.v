// mist_console.v
//
// receive serial data and forware it to the io controller
// 

module mist_console #(parameter CLKFREQ=100) (
		     // system interface
		     input 	  clk,      // 125MHz
		     input 	  n_reset,
	
		     input 	  ser_in,

		     //	input par_out_
		     output [7:0] par_out_data,
		     output   par_out_strobe
); 

localparam TICKSPERBIT = (CLKFREQ*1000000)/115200;

assign par_out_data = rx_byte;
assign par_out_strobe = strobe;
 
reg strobe;
reg [7:0] rx_byte /* synthese noprune */;
reg [5:0] state;
reg [15:0] recheck; 

always @(posedge clk) begin
	if(!n_reset) begin
		state <= 6'd0;  // idle
		strobe <= 1'b0;
	end else begin
		if(state == 0) begin
 
			// detecting low in idle state
			if(!ser_in) begin 
				recheck <= 3*TICKSPERBIT/2;
				state <= 9;
				strobe <= 1'b0;
			end
		end else begin
			if(recheck != 0) 
				recheck <= recheck - 1;
			else begin
				if(state > 1)
					rx_byte <= { ser_in, rx_byte[7:1]};
					
				recheck <= TICKSPERBIT;
				state <= state - 1;
				
				// last bit is stop bit and needs to be '1'
				if((state == 1) && (ser_in == 1))
					strobe <= 1'b1;
			end
		end
	end
end

endmodule
