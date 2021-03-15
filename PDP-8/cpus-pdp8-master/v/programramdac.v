// programramdac.v

// hardcoded values for initialising the RAMDAC
module dac_data(addr, o);
   
   input[2:0] addr;
   output     o;
   reg [7:0]  o;
   
  // hard code initial control register programming values
  // DAC(76543210)
  always @(addr)
    case (addr)
      3'd0: o <= 8'b10000001; // Cmd reg A, high colour dual edged mode
      3'd1: o <= 8'b00000000; // Pallette address reg gets $00
      3'd2: o <= 8'b11111111; // Read mask reg gets $FF
      3'd3: o <= 8'b00000010; // Pallette address reg gets $02
      3'd4: o <= 8'b00000010; // Command reg B gets $02
      3'd5: o <= 8'b00000000; // Pallette address reg gets $00
    endcase // case(addr)
endmodule
 
module dac_rs(addr, o);

   input[2:0] addr;
   output     o;
   reg [2:0]  o;

   // RS(210)
   always @(addr)
     case (addr)
       3'd0: o <= 3'b110; // RS gets Command reg A	
       3'd1: o <= 3'b000; // RS gets Pallette address reg
       3'd2: o <= 3'b010; // RS gets Read mask reg
       3'd3: o <= 3'b000; // RS gets Pallette address reg
       3'd4: o <= 3'b010; // RS gets Command reg B
       3'd5: o <= 3'b000; // RS gets Pallette address reg
     endcase
endmodule

module programramdac(rstn, clk, start, done, WRn, RDn, RS, data);

   input rstn;
   input clk;
   input start;		// start signal
   output done;
   output WRn;		// write line to ramdac
   output RDn;		// read line ot ramdac
   input [2:0] RS;	// register select lines to ramdac
   inout [7:0] data;	// data lines to ramdac

   reg 	       done, WRn;
  
   // FSM states for the main mealy FSM
   parameter [2:0]
		stIdle = 3'd0,
		stWrite = 3'd1,
		stWrCycle = 3'd2,
		stNextWrite = 3'd3;
   
   reg [2:0] presState, nextState;

   // initCnt controls write state
   reg [2:0]   initCnt;
   reg 	       increment;

   // signals to create a 12.5MHz clock from the 50MHz input clock
   wire	       divclk;
   reg [1:0]   gray_cnt;

   // create signals so the data and RS lines can be used as tristate
   //  buffers. this is important as they share lines with the ethernet PHY
   reg [7:0]   prgData;
   reg [2:0]   prgRS;
   reg 	       latchData;
   reg 	       latchRS;

   wire [7:0]  theData;
   wire [2:0]  theRs;
   
   
   // data and register select
   dac_data arraydac(.addr(initCnt), .o(theData));
   dac_rs arrayrs(.addr(initCnt), .o(theRS));

   // clock divider by 4 to for a slower clock to avoid timing violations
   // uses grey code for minimized logic
   always @(posedge clk or rstn)
     if (~rstn)
       gray_cnt <= 2'b00;
     else
       case (gray_cnt)
	 2'b00: gray_cnt <= 2'b01;
	 2'b01: gray_cnt <= 2'b11;
	 2'b11: gray_cnt <= 2'b10;
	 2'b10: gray_cnt <= 2'b00;
	 default: gray_cnt <= 2'b00;
       endcase
	
   // assign the clock that this entity runs off
   assign divclk = gray_cnt[1];
	
   // read isn't needed, tie high
   assign RDn = 1;

   // main clocked process
   always @(posedge divclk or rstn)
     if (~rstn)
       begin
	  presState <= stIdle;
	  initCnt <= 0;
       end
     else
       if (divclk == 1)
       begin
	  presState <= nextState;
	  if (increment)
	    if (initCnt < 5)
	      initCnt <= initCnt + 1;
	    else
	      initCnt <= 0;
       end

   // Main FSM process
   always @(presState, start, initCnt)
     begin
	// default signals and outputs for each FSM state
	// note that the latch data and rs signals are defaulted to 1,
	// so are only 0 in the idle state
	WRn <= 1;
	increment <= 0;
	prgData <= 0;
	prgRS <= 3'b001;
	latchData <= 1;
	latchRS <= 1;
	done <= 0;
						
	case (presState)
	  stIdle:
	    begin
	       // wait for start signal from another process
	       if (start)
		 begin
		    nextState <= stWrite;
		    // setup for the first write to the RAMDAC for use
		    //  by setting the register select lines and
		    //  the data lines
		    prgRS <= theRS;
		    prgData <= theData;
		 end
	       else
		 begin
		    nextState <= stIdle;
		    latchData <= 0;
		    latchRS <=0;
		 end
	       end
	  
	  stWrite:
	    begin
	       // hold the register select and data lines for
	       //  the write cycle and set the active low write signal
	       nextState <= stWrCycle;
 	       prgRS <= theRS;
	       prgData <= theData;
	       WRn <= 0;
	    end
	  
	  stWrCycle:
	    begin
	       // continue if all 5 registers have been programmed
	       if (initCnt == 5)
		 begin
		    nextState <= stIdle;
		    done <= 1;
		 end
	       else
		 // continue writing to the registers
		 nextState <= stNextWrite;

	       // hold the data to be sure the hold times aren't violated
	       prgRS <= theRS;
	       prgData <= theData;

	       // increment initCnt to program the next register
	       increment <= 1;
	    end
	  
	  stNextWrite:
	    begin
	       nextState <= stWrite;
	       // setup for the next write cycle
	       prgRS <= theRS;
	       prgData <= theData;
	    end
	  
	endcase;
		
	// assign data and RS prgData and prgRS respectively when they
	//  need to be latched otherwise keep them at high impedance
	//  to create a tri state buffer
     end // always @ (presState, start, initCnt)
   
   assign data = latchData ? prgData : 8'bz;
   assign RS = latchRS ? prgRS : 3'bz;
	
endmodule

