// Jim Geist jimg@knights.ucf.edu
//
// memory controller testbench
//
`timescale 1ns / 1ps

module memctl_test();

reg clk = 1;    
always #5 clk = ~clk;

reg reset = 0;
reg start = 0;
reg write = 0;
reg [11:0] addr = 0;
reg [11:0] datain = 0;
wire [11:0] dataout;    
wire done;

initial
begin
    #10
    reset = 1;
    #10
    reset = 0;
    #50
    // write [177] = 555
    addr <= 12'o177;
    datain <= 12'o555;
    start <= 1'b1;
    write <= 1'b1;
    #10
    start <= 1'b0;
    #200
    // write [137] = 444
    addr <= 12'o137;
    datain <= 12'o444;
    start <= 1'b1;
    #10
    start <= 1'b0;
    #200
    // read [177]
    write <= 1'b0;
    addr <= 12'o177;
    start <= 1'b1;
    #10
    start <= 1'b0;
    #200    
    $finish();
    
end

memctl mc(.clk(clk), .reset(reset), .start(start), .write(write), .addr(addr), 
    .datain(datain), .dataout(dataout), .done(done));

endmodule


