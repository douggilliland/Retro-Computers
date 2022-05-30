/* 32kx12 static ram */
module ram_32kx12(A, DI, DO, CE_N, WE_N);

  input[14:0] A;
  input[11:0] DI;
  input CE_N, WE_N;
  output[11:0] DO;

  reg[11:0] ram [0:32767];

   // synthesis translate_off
   integer  i;
   reg [11:0] v;
   reg [63:0] file;
   reg [1023:0] str;
   reg [1023:0] testfilename;
   integer 	n;
   
  initial
    begin
      for (i = 0; i < 32768; i=i+1)
        ram[i] = 12'b0;

       n = 0;

`ifdef __ICARUS__
       n = $value$plusargs("test=%s", testfilename);
`endif
       
`ifdef __CVER__
       n = $scan$plusargs("test=", testfilename);
`endif

       if (n == 0)
	 begin
	    testfilename = "../verif/default.mem";
	    n = 1;
	 end
       
       if (n > 0)
	 begin
	    $display("ram: code filename: %s", testfilename);
	    file = $fopen(testfilename, "r");
	    if (file > 0)
	      begin
		 while ($fscanf(file, "%o %o\n", i, v) > 0)
		   begin
		      $display("ram[%o] <- %o", i, v);
		      ram[i] = v;
		   end
		 
		 $display("ram: done reading");
		 $fclose(file);
	      end
	 end
    end
   // synthesis translate_on
   

  always @(WE_N or CE_N or A or DI)
    begin
       if (WE_N == 0 && CE_N == 0)
        begin
`ifdef debug_ram
	   $display("ram: write [%o] <- %o", A, DI);
`endif
           ram[ A ] = DI;
        end

`ifdef debug_ram_read
	if (WE_N == 1 && CE_N == 0)
	  $display("ram: read [%o] -> %o", A, ram[A]);
`endif
    end

   assign DO = ram[ A ];
//   assign DO = (^A === 1'bX || A === 1'bz) ? ram[0] : ram[A];

endmodule

