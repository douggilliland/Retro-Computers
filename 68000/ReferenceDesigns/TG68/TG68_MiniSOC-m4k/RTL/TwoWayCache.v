// Two Way Cache, supporting 64 meg address space.
// Would be easy enough to extend to wider address spaces, just need
// to increase the width of the "tag" blockram.

// If we're targetting Cyclone 3, then we have 9kbit blockrams to play with.
// Each burst, assuming we stick with 4-word bursts, is 64 bits, so a single M9K
// can hold 128 cachelines.  Since we're building a 2-way cache, this will end
// up being 2 overlapping sets of 64 cachelines.

// The address is broken down as follows:
//   bit 0 is irrelevant because we're working in 16-bit words.
//   bits 2:1 specify which word of a burst we're interested in.
//   Bits 8:3 specify the six bit address of the cachelines;
//     this will map to {1'b0,addr[8:3]} and {1;b1,addr[8:3]} respectively.
//   Bits 25:9 have to be stored in the tag, which, it turns out is no problem,
//     since we can use have 18-bit wide words.  The highest bit will be used as
//     a "most recently used" flag, leaving one bit spare, so we can support 64 meg
//     without changing bit widths.
// (Storing the MRU flag in both tags in a 2-way cache is redundant, so we'll only 
// store it in the first tag.)

module TwoWayCache
(
	input clk,
	input reset, // active low
	input [31:0] cpu_addr,
	input cpu_req,	// 1 to request attention
	output reg cpu_ack,	// 1 to signal that data is ready.
	input cpu_rw, // 1 for read cycles, 0 for write cycles
	input cpu_wrl, // access low byte
	input cpu_wru, // access high byte
	input [15:0] data_from_cpu,
	output reg [15:0] data_to_cpu,
	output reg [31:0] sdram_addr,
	input [15:0] data_from_sdram,
	output reg [15:0] data_to_sdram,
	output reg sdram_req,
	input sdram_fill,
	input pause, // hack to verify cause of byte problems.
	output reg sdram_rw	// 1 for read cycles, 0 for write cycles
);


// States for state machine
parameter WAITING=0, WAITRD=1, WAITFILL=2,
				FILL2=3, FILL3=4, FILL4=5, FILL5=6, PAUSE1=7,
				WRITE1=8, WRITE2=9, INIT1=10, INIT2=11;
reg [4:0] state = INIT1;
reg init;
reg [7:0] initctr;

// BlockRAM and related signals for data

// In the top two bits of each record we store valid flags.
// Bit 17 indicates that the upper byte is valid,
// while bit 16 indicates that the lower byte is valid.

wire [8:0] data_port1_addr;
wire [8:0] data_port2_addr;
wire [17:0] data_port1_r;
wire [17:0] data_port2_r;
reg[17:0] data_ports_w;
reg data_wren1;
reg data_wren2;

wire data_valid1;
wire data_valid2;


CacheBlockRAM dataram(
	.clock(clk),
	.address_a(data_port1_addr),
	.address_b(data_port2_addr),
	.data_a(data_ports_w),
	.data_b(data_ports_w),
	.q_a(data_port1_r),
	.q_b(data_port2_r),
	.wren_a(data_wren1),
	.wren_b(data_wren2)
);


// data is considered valid if each byte's valid flag is 1, or if any 0 valid flags
// are matched by a high byte select from the CPU.
assign data_valid1=(data_port1_r[17]|cpu_wru) & (data_port1_r[16]|cpu_wrl);
assign data_valid2=(data_port2_r[17]|cpu_wru) & (data_port2_r[16]|cpu_wrl);


// BlockRAM and related signals for tags.

wire [8:0] tag_port1_addr;
wire [8:0] tag_port2_addr;
wire [17:0] tag_port1_r;
wire [17:0] tag_port2_r;
wire [17:0] tag_port1_w;
wire [17:0] tag_port2_w;

wire tag_hit1;
wire tag_hit2;

reg tag_wren1;
reg tag_wren2;
reg tag_mru1;

CacheBlockRAM tagram(
	.clock(clk),
	.address_a(tag_port1_addr),
	.address_b(tag_port2_addr),
	.data_a(tag_port1_w),
	.data_b(tag_port2_w),
	.q_a(tag_port1_r),
	.q_b(tag_port2_r),
	.wren_a(tag_wren1),
	.wren_b(tag_wren2)
);

//   bits 2:1 specify which word of a burst we're interested in.
//   Bits 8:3 specify the six bit address of the cachelines;
//   Since we're building a 2-way cache, we'll map this to 
//   {1'b0,addr[8:3]} and {1;b1,addr[8:3]} respectively.

wire [6:0] cacheline1;
wire [6:0] cacheline2;

assign cacheline1 = {1'b0,cpu_addr[8:3]};
assign cacheline2 = {1'b1,cpu_addr[8:3]};

// We share each tag between all four words of a cacheline.  We could therefore use
// up to four M9Ks for cache and still need only one for tags.  For now, though
// the upper two bits of the tag address are zero.

assign tag_port1_addr = {2'b0,cacheline1};
assign tag_port2_addr = {2'b0,cacheline2};

// The first port contains the mru flag, so we have to write to it on every
// access.  The second tag only needs writing when a cacheline in the second
// block is updated, so we tie the write port of the second tag to part of the
// CPU address.
// The first port has to be toggled between old and new data, depending upon
// the state of the mru flag.
// (Writing both ports on every access for troubleshooting)

assign tag_port1_w = {tag_mru1,(tag_mru1 ? cpu_addr[25:9] : tag_port1_r[16:0])};
assign tag_port2_w = {1'b0,(!tag_mru1 ? cpu_addr[25:9] : tag_port2_r[16:0])};
//assign tag_port2_w = {1'b0,cpu_addr[25:9]};

// Compare the tag value with the CPU address and mark any hits.
assign tag_hit1 = (tag_port1_r[16:0]==cpu_addr[25:9]) ? 1'b1 : 1'b0;
assign tag_hit2 = (tag_port2_r[16:0]==cpu_addr[25:9]) ? 1'b1 : 1'b0;

// In the data blockram the lower two bits of the address determine
// which word of the burst we're reading.  When reading from the cache, this comes
// from the CPU address; when writing to the cache it's determined by the state
// machine.

reg [1:0] readword;

assign data_port1_addr = init ? {1'b0,initctr} : {cacheline1,readword};
assign data_port2_addr = init ? {1'b1,initctr} : {cacheline2,readword};



always @(posedge clk)
begin

	// Defaults
	tag_wren1<=1'b0;
	tag_wren2<=1'b0;
	data_wren1<=1'b0;
	data_wren2<=1'b0;
	cpu_ack<=1'b0;
	init<=1'b0;

	case(state)

		INIT1:
		begin
			init<=1'b1;	// need to mark the entire cache as invalid before starting.
			initctr<=8'b0000_0000;
			data_ports_w<=18'b0; // Mark entire cache as invalid
			data_wren1<=1'b1;
			data_wren2<=1'b1;
			state<=INIT2;
		end
		
		INIT2:
		begin
			init<=1'b1;
			initctr<=initctr+1;
			data_wren1<=1'b1;
			data_wren2<=1'b1;
			if(initctr==8'b1111_1111)
				state<=WAITING;
		end

		WAITING:
		begin
			state<=WAITING;
			readword=cpu_addr[2:1];
			if(cpu_req==1'b1)
			begin
				if(cpu_rw==1'b1)	// Read cycle
					state<=WAITRD;
				else	// Write cycle
					state<=WRITE1;
			end
		end
		WRITE1:
			begin
				// If the current address is in cache,
				// we must update the appropriate cacheline

				// FIXME - this won't work for byte accesses!
				
				readword=cpu_addr[2:1];
				
				// We mark the data as valid only if the entire 16-bit word is written,
				// otherwwise we just flush the cacheline.
//				data_ports_w[17]<=~cpu_wru;
//				data_ports_w[16]<=~cpu_wrl;
				data_ports_w[17:16]<=2'b11;
				data_ports_w[15:0]<=data_from_cpu; // data

 				if(tag_hit1)
				begin
					// Write the data to the first cache way
					data_wren1<=1'b1;
					// Mark tag1 as most recently used.
					tag_mru1<=1'b1;
					tag_wren1<=1'b1;
				end
				else if(tag_hit2)
				begin
					// Write the data to the second cache way
					// Write the data to the first cache way
					data_wren2<=1'b1;
					// Mark tag2 as most recently used.
					tag_mru1<=1'b0;
					tag_wren1<=1'b1;
				end
				// FIXME - ultimately we should clear a cacheline here and cache
				// the data for future use.  Need to have a working valid flag first.
				state<=WRITE2;
			end

		WRITE2:
			begin
				if(cpu_req==1'b0)	// Wait for the write cycle to finish
					state<=WAITING;
			end

		WAITRD:
			begin
				state<=PAUSE1;
				// Check both tags for a match...  Check valid flag, too.
				if(tag_hit1 & data_valid1)
				begin
					// Copy data to output
					data_to_cpu<=data_port1_r;
					cpu_ack<=1'b1;

					// Mark tag1 as most recently used.
					tag_mru1<=1'b1;
					tag_wren1<=1'b1;
				end
				else if(tag_hit2 & data_valid2)
				begin
					// Copy data to output
					data_to_cpu<=data_port2_r;
					cpu_ack<=1'b1;
					
					// Mark tag2 as most recently used.
					tag_mru1<=1'b0;
					tag_wren1<=1'b1;
				end
				else	// No matches?  How do we decide which one to use?
				begin
					// invert most recently used flags on both tags.
					// (Whichever one was least recently used will be overwritten, so
					// is now the most recently used.)

					tag_mru1<=~tag_port1_r[17];

//					For simulation only, to avoid the unknown value of unitialised blockram
//					tag_mru1<=cpu_addr[1];

					tag_wren1<=1'b1;
					tag_wren2<=1'b1;
					// If r[17] is 1, tag_mru1 is 0, so we need to write to the second tag.
					// FIXME - might be simpler to just write every cycle and switch between new and old data.
//					tag_wren2<=tag_port1_r[17];

					readword<=2'b00;
					// Pass request on to RAM controller.
					sdram_addr<={cpu_addr[31:3],3'b000};
					sdram_req<=1'b1;
					sdram_rw<=1'b1;	// Read cycle
					state<=WAITFILL;
				end
			end

		PAUSE1:
			state<=WAITING;
		
		WAITFILL:
		begin
			if (sdram_fill==1'b1)
			begin
				sdram_req<=1'b0;
				// write first word to Cache...
				data_ports_w<={2'b11,data_from_sdram};
				data_wren1<=tag_mru1;
				data_wren2<=~tag_mru1;
				state<=FILL2;
			end
		end

		FILL2:
		begin
			// write second word to Cache...
			readword=2'b01;
			data_ports_w<={2'b11,data_from_sdram};
			data_wren1<=tag_mru1;
			data_wren2<=~tag_mru1;
			state<=FILL3;
		end

		FILL3:
		begin
			// write third word to Cache...
			readword=2'b10;
			data_ports_w<={2'b11,data_from_sdram};
			data_wren1<=tag_mru1;
			data_wren2<=~tag_mru1;
			state<=FILL4;
		end

		FILL4:
		begin
			// write last word to Cache...
			readword=2'b11;
			data_ports_w<={2'b11,data_from_sdram};
			data_wren1<=tag_mru1;
			data_wren2<=~tag_mru1;
			state<=FILL5;
		end
		
		FILL5:
		begin
			readword=cpu_addr[2:1];
			state<=WAITING;
		end

		default:
			state<=WAITING;
	endcase

	if(reset==1'b0)
		state<=INIT1;
end

endmodule
