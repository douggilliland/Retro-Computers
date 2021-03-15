// Jim Geist jimg@knights.ucf.edu
//
// main module test
//
module main_test();
reg clk = 0;
always #5 clk = ~clk;

reg btnU, btnD, btnR, btnL, btnC;
reg [15:0] sw;

initial
begin
    btnU <= 0;
    btnD <= 0;
    btnL <= 0;
    btnR <= 0;
    sw <= 0;
    #10
    sw <= 16'o0200;
    btnL <= 1; 
    #100
    btnL <= 0;
    #100
    sw[15] <= 1;
    #1000
    $stop();
end

wire [15:0] led;
wire [6:0] seg;
wire dp;
wire [3:0] an;
wire halt;

main main_t(
    .clk(clk), .led(led), .seg(seg), .dp(dp), .an(an),
    .btnU(btnU), .btnD(btnD), .btnL(btnL), .btnR(btnR), .btnC(btnC), 
    .sw(sw), .halt(halt)
);

always @(*) if (halt) $stop();

defparam main.DEBCLOCK_BITS = 2;

endmodule
