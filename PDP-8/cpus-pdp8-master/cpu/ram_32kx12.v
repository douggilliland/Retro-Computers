
/* 32kx12 static ram */
module ram_32kx12(A, DI, DO, CE_N, WE_N);

  input[14:0] A;
  input[11:0] DI;
  input CE_N, WE_N;
  output[11:0] DO;

  reg[11:0] ram [0:32767];
  integer i;

  initial
    begin
      for (i = 0; i < 32768; i=i+1)
        ram[i] = 12'b0;

	ram[15'o0000] = 12'o5177;
	ram[15'o0200] = 12'o7300;
	ram[15'o0201] = 12'o1300;
	ram[15'o0202] = 12'o1301;
	ram[15'o0203] = 12'o3302;
	ram[15'o0204] = 12'o7402;
	ram[15'o0205] = 12'o5200;

`include "focal.v"
	ram[15'o0000] = 12'o5404;
	ram[15'o0004] = 12'o0200;
    end

  always @(WE_N or CE_N or A or DI)
    begin
       if (WE_N == 0 && CE_N == 0)
        begin
	   $display("ram: write [%o] <- %o", A, DI);
           ram[ A ] = DI;
        end
    end

//always @(A)
//  begin
//    $display("ram: ce %b, we %b [%o] -> %o", CE_N, WE_N, A, ram[A]);
//  end

//  assign DO = ram[ A ];
assign DO = (^A === 1'bX || A === 1'bz) ? ram[0] : ram[A];

endmodule

