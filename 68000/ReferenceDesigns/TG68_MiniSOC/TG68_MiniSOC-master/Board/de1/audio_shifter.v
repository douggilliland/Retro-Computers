/* audio_shifter.v */


module audio_shifter(
  input  wire           clk,    //32MHz
  input  wire           nreset,
  input  wire [15:0]    rdata,
  input  wire [15:0]    ldata,
  output wire           aud_bclk,
  output wire           aud_daclrck,
  output wire           aud_dacdat,
  output wire           aud_xck
);


//// audio output shifter ////

reg  [  9-1:0] shiftcnt;
reg  [ 16-1:0] shift;

always @(posedge clk, negedge nreset) begin
  if(~nreset)
    shiftcnt <= 9'd0;
  else
    shiftcnt <= shiftcnt - 9'd1;
end

always @ (posedge clk) begin
  if(~|shiftcnt[2:0]) begin
    if (~|shiftcnt[6:3])
      shift <= #1 (shiftcnt[7]) ? ldata : rdata;
    else
      shift <= #1 {shift[14:0], 1'b0};
  end
end


//// output ////
assign aud_daclrck = shiftcnt[7];
assign aud_bclk    = ~shiftcnt[2];
assign aud_xck     = shiftcnt[0];
assign aud_dacdat  = shift[15];


endmodule

