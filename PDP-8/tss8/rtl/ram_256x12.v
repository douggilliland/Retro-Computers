/* 256x12 static ram */
module ram_256x12(clk, reset, a, din, dout, ce, we);

   input clk;
   input reset;
   
   input [7:0]   a;
   input [11:0]  din;
   input 	 ce, we;
   output [11:0] dout;

   reg [11:0] 	 ram [0:255];

   // synthesis translate_off
   integer 	 i;
`ifdef debug
   integer 	 ram_debug;
`endif

   initial
     begin
	for (i = 0; i < 256; i=i+1)
          ram[i] = 12'b0;
     end
   // synthesis translate_on
   
   always @(posedge clk)
     begin
	if (we && ce)
          begin
`ifdef debug_rf_buffer
	     if (ram_debug != 0)
	       $display("rf: buffer ram write [%o] <- %o", a, din);
`endif
             ram[a] = din;
          end

`ifdef debug_rf_buffer
	if (ram_debug != 0&& we == 0 && ce == 1)
	  $display("rf: buffer ram read [%o] -> %o", a, ram[a]);
`endif
     end

//`define is_async   
`ifdef is_async
   assign dout = ram[a];
`else
   reg [11:0] dout;
   
   always @(posedge clk)
     if (reset)
       dout <= 0;
     else
       if (~we && ce)
	 dout <= ram[a];
`endif

endmodule

