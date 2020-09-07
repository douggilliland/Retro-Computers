/********************************************/
/* audio_top.v                              */
/*                                          */
/* 2012, rok.krajnc@gmail.com               */
/* Simplified for non-Minimig use by AMR    */
/********************************************/


module audio_top (
  input  wire           clk,
  input  wire           rst_n,
  // audio shifter
  input  wire [ 15:0] rdata,
  input  wire [ 15:0] ldata,
  output wire           aud_bclk,
  output wire           aud_daclrck,
  output wire           aud_dacdat,
  output wire           aud_xck,
  // I2C audio config
  output wire           i2c_sclk,
  inout                 i2c_sdat
);



////////////////////////////////////////
// modules                            //
////////////////////////////////////////


// audio shifter
audio_shifter audio_shifter (
  .clk          (clk              ),
  .nreset       (rst_n            ),
  .rdata        (rdata            ),
  .ldata        (ldata            ),
  .aud_bclk     (aud_bclk         ),
  .aud_daclrck  (aud_daclrck      ),
  .aud_dacdat   (aud_dacdat       ),
  .aud_xck      (aud_xck          )
);


// I2C audio config
I2C_AV_Config audio_config (
  // host side
  .iCLK         (clk              ),
  .iRST_N       (rst_n            ),
  // i2c side
  .oI2C_SCLK    (i2c_sclk         ),
  .oI2C_SDAT    (i2c_sdat         )
);


endmodule

