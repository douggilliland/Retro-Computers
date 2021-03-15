//
// boot rom occupies one page from 7400 - 7577
//

//`define bootrom_uart 1

`ifndef bootrom_uart
 `define bootrom_tss8 1
`endif

module bootrom(clk, reset, addr, data_out, rd, selected);

   input clk;
   input reset;
   input [14:0] addr;
   output [11:0] data_out;
   input 	 rd;
   output 	 selected;

   //
   reg		 deactivate;
   reg [2:0] 	 delay;
   reg [11:0] 	 data;
   wire 	 active;
   
   always @(posedge clk)
     if (reset)
       delay <= 3'o7;
     else
       if (deactivate || (delay != 3'o7 && delay != 3'o0))
	 delay <= delay - 3'o1;

    assign active = delay != 3'b000;
    assign selected = active && (addr >= 15'o07400 && addr <= 15'o07577);
		
    assign data_out = data;

   always @(*)
     begin
	deactivate = 0;

//`define debug_rom
`ifdef debug_rom
	$display("rom: active %b delay %o addr %o", active, delay, addr);
`endif

`ifdef bootrom_tss8
	if (rd)
	  case (addr)
	    // copy tss8 bootstrap to ram and jump to it
	    // (see ../rom/rom.pal)
	    15'o7400: data = 12'o7240;
	    15'o7401: data = 12'o1224;
	    15'o7402: data = 12'o3010;
	    15'o7403: data = 12'o1217;
	    15'o7404: data = 12'o3410;
	    15'o7405: data = 12'o1220;
	    15'o7406: data = 12'o3410;
	    15'o7407: data = 12'o1221;
	    15'o7410: data = 12'o3410;
	    15'o7411: data = 12'o1222;
	    15'o7412: data = 12'o3410;
	    15'o7413: data = 12'o1223;
	    15'o7414: data = 12'o3410;
	    15'o7415: data = 12'o7300;
	    15'o7416: data = 12'o5624;
	    15'o7417: data = 12'o7600;
	    15'o7420: data = 12'o6603;
	    15'o7421: data = 12'o6622;
	    15'o7422: data = 12'o5352;
	    15'o7423: data = 12'o5752;
	    15'o7424: data = 12'o7750;
	  endcase // case(addr)

	if (rd && active && addr == 15'o07416)
	  deactivate = 1;
`endif
`ifdef bootrom_uart
	if (rd)
	case (addr)
	  // run simple uart test
	  12'o7400: data = 12'o7240;
	  12'o7401: data = 12'o1215;
	  12'o7402: data = 12'o3010;
	  12'o7403: data = 12'o1216;
	  12'o7404: data = 12'o3007;
	  12'o7405: data = 12'o7200;
	  12'o7406: data = 12'o1410;
	  12'o7407: data = 12'o6046;
	  12'o7410: data = 12'o6041;
	  12'o7411: data = 12'o5210;
	  12'o7412: data = 12'o2007;
	  12'o7413: data = 12'o5205;
	  12'o7414: data = 12'o5214;
	  12'o7415: data = 12'o7417;
	  12'o7416: data = 12'o7766;
	  12'o7417: data = 12'o0215;
	  12'o7420: data = 12'o0212;
	  12'o7421: data = 12'o0310;
	  12'o7422: data = 12'o0305;
	  12'o7423: data = 12'o0314;
	  12'o7424: data = 12'o0314;
	  12'o7425: data = 12'o0317;
	  12'o7426: data = 12'o0241;
	  12'o7427: data = 12'o0215;
	  12'o7430: data = 12'o0212;
	endcase // case(addr)
`endif	
     end
   
endmodule
