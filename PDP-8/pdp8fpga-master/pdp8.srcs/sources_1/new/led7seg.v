// Jim Geist jimg@knights.ucf.edu
//
// 7-segment driver.
//
module led7seg(
    input clk,
    input reset,
    input [12:0] value,
    output [6:0] seg,
    output [3:0] an,
    output dp
);

parameter CLOCK_RATE = 100_000_000;
localparam DISP_CLOCK = 500;
localparam DISP_COUNTER_MAX = CLOCK_RATE / DISP_CLOCK;

integer disp_ctr = 0;
reg [1:0] dig_idx = 0;
reg [6:0] segreg = 0;
reg [3:0] anreg = 4'b1111;
reg dpreg = 0;

wire [3:0] digit;

// decode in octal
assign digit =
    dig_idx == 0 ? value & 7 :
    dig_idx == 1 ? (value >> 3) & 7 :
    dig_idx == 2 ? (value >> 6) & 7 :
                   (value >> 9) & 7;

always @ (posedge clk)
begin
    if (reset)
    begin
        disp_ctr <= 0;
        dig_idx <= 0;
        segreg <= 0;
        anreg <= 4'b1111;
        dpreg <= 0;
    end
    else
    if (disp_ctr == DISP_COUNTER_MAX - 1)
    begin
        disp_ctr <= 0;
        dig_idx <= dig_idx + 1;
    end
    else
    begin
        disp_ctr <= disp_ctr + 1;
    end

    anreg <= ~(1 << dig_idx);

    dpreg <= ~((dig_idx == 3) & (value[12] != 0));

    case (digit)
                       // gfedcba
            0 : segreg <= 7'b1000000;
            1 : segreg <= 7'b1111001;
            2 : segreg <= 7'b0100100;
            3 : segreg <= 7'b0110000;
            4 : segreg <= 7'b0011001;
            5 : segreg <= 7'b0010010;
            6 : segreg <= 7'b0000010;
            7 : segreg <= 7'b1111000;
            8 : segreg <= 7'b0000000;
            9 : segreg <= 7'b0010000;
            10: segreg <= 7'b0001000; // A
            11: segreg <= 7'b0000011; // b
            12: segreg <= 7'b1000110; // C
            13: segreg <= 7'b0100001; // d
            14: segreg <= 7'b0000110; // E
            15: segreg <= 7'b0001110; // F
    endcase
end

assign dp = dpreg;
assign an = anreg;
assign seg = segreg;

endmodule
