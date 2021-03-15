// video_mem.v

/* 1kx32 static ram */

module video_ram(addr, data_in, data_out, ce_n, we_n);

   input [10:0] addr;
   input [7:0] 	data_in;
   input 	ce_n, we_n;
   output [7:0] data_out;

   reg [7:0] ram [0:2047];

   always @(negedge we_n)
     begin
	if (ce_n == 0)
          ram[addr] = data_in;
    end

   assign data_out = ram[addr];
endmodule


