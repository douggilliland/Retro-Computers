module fake_ram(clk, reset, 
		ram_read_req, ram_write_req, ram_done,
		ram_ma, ram_in, ram_out);
   
   input clk;
   input reset;

   input ram_read_req;
   input ram_write_req;

   output ram_done;
   
   input [14:0] ram_ma;
   input [11:0] ram_in;
   output [11:0] ram_out;

   //--------------

   reg [11:0] 	 ram [0:32767];
   integer 	 i;
   integer 	 ram_debug;
   
   initial
     begin
	ram_debug = 0;
	for (i = 0; i < 32768; i=i+1)
          ram[i] = 12'b0;
     end

   reg [2:0] ram_state;
   wire [2:0] ram_state_next;
   
   always @(posedge clk)
     if (reset)
       ram_state <= 0;
     else
       ram_state <= ram_state_next;

   assign ram_state_next =
			  (ram_state == 0 && ram_read_req) ? 1 :
			  (ram_state == 1) ? 0 :
			  (ram_state == 0 && ram_write_req) ? 2 :
			  (ram_state == 2) ? 0 :
			  0;
   assign ram_done = ram_state == 1 || ram_state == 2;

  always @(ram_state)
    begin
       if (ram_state == 2)
        begin
	   if (ram_debug) $display("ram: write [%o] <- %o", ram_ma, ram_in);
           ram[ ram_ma ] = ram_in;
        end

       if (ram_state  == 1)
	 begin
	    if (ram_debug) $display("ram: read [%o] -> %o", ram_ma, ram[ram_ma]);
	 end
    end

   assign ram_out = ram[ ram_ma ];
   
endmodule

