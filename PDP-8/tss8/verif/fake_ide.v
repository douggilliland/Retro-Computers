
module fake_ide(ide_dior, ide_diow, ide_cs, ide_da, ide_data_bus);

   input        ide_dior;
   input        ide_diow;
   input [1:0] 	ide_cs;
   input [2:0] 	ide_da;
   inout [15:0] ide_data_bus;

   reg [7:0] 	data_out;
   reg [7:0] 	cmd;
   reg [7:0] 	status;
   reg [7:0] 	drvhead;
   
   integer 	fifo;
   
   wire 	is_rd;
   wire 	is_wr;

   assign is_rd = ide_dior == 1'b0 && (ide_cs[0] == 1'b0 || ide_cs[1] == 1'b0);
   assign is_wr = ide_diow == 1'b0 && (ide_cs[0] == 1'b0 || ide_cs[1] == 1'b0);
   
   assign ide_data_bus = is_rd ? data_out : 12'bz;

   initial
     begin
	status = 8'h50;
     end

   always @(*)
     begin
	if (ide_dior == 1'b0 && (ide_cs[0] == 1'b0 || ide_cs[1] == 1'b0))
	  begin
	     if (ide_da != 0)
	       #1 $display("ide r cs %b; da %b; bus %x",
			   ide_cs, ide_da, ide_data_bus);
	     case (ide_da)
	       3'd0:
		 begin
		    if (fifo > 0)
		      begin
			 data_out = 0;
			 fifo = fifo - 1;
			 //$display("fifo %d", fifo);
		      end
		    if (fifo == 0)
		      begin
			 $display("ide empty!");
			 status = 8'h50;
			 cmd = 0;
		      end			 
		 end
	       3'd7:
		 data_out = status;
	     endcase
	     
	  end
	if (ide_diow == 1'b0 && (ide_cs[0] == 1'b0 || ide_cs[1] == 1'b0))
	  begin
	     #1 $display("ide w cs %b; da %b; bus %x",
		      ide_cs, ide_da, ide_data_bus);
	     case (ide_da)
	       3'd6:
		 drvhead = ide_data_bus;
	       
	       3'd7:
		 begin
		    //release ide_data_bus;
		    cmd = ide_data_bus;
		    #1 $display("ide cmd %x", cmd);
		    case (cmd)
		      8'h20:
			begin
			   status = 8'h58;
			   fifo = 256;
			end
		    endcase
		 end
	     endcase
	  end
     end

endmodule
