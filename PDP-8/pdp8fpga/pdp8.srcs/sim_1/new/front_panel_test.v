// Jim Geist jimg@knights.ucf.edu
//
// Front panel test
//
`timescale 1ns / 1ps


module front_panel_test();
reg clk = 1;
always #5 clk = ~clk;

reg btnU, btnD, btnR, btnL, btnC;
reg [15:0] sw;
reg [11:0] dispout;
reg linkout;
reg halt;
reg reset;

initial
begin
    btnU = 0;
    btnD = 0;
    btnL = 0;
    btnR = 0;
    sw = 0;
    linkout = 0;
    halt = 0;
    reset = 0;
    #10
    reset = 1;
    #50
    reset = 0;
    #10
    btnU = 1;
    #2000
    btnU = 0;
    #2000
    sw[15] = 1;
    #2000
    halt = 1;
    #2000
    halt = 0;
    #2000
    sw[15] = 0;
    #2000
    sw[15] = 1;
    
end

front_panel #(.DEBCLOCK_BITS(6)) panel(
    .reset(reset), .clk(clk), .btnU(btnU), .btnD(btnD), .btnL(btnL), .btnR(btnR), .btnC(btnC),
    .sw(sw), .dispout(dispout), .linkout(linkout), .halt(halt));  

endmodule
