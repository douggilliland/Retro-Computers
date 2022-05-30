// Jim Geist jimg@knights.ucf.edu
//
// Generate VGA timing.
//

// generates timing signals for a VGA monitor running in 640x480 mode at 60 Hz
//
module vga_timing(
    input clk,
    output reg pixclk = 1,                  // pixel clock (25 Mhz)
    output reg Hsync = 0,                   // VGA hsync output
    output reg Vsync = 0,                   // VGA vsync output
    output reg [1:0] pixcnt = 0,            // sub pixel clock counter
    output reg [15:0] x = 16'hffff,         // x pixel position
    output reg [15:0] y = 16'hffff) ;       // y pixel position

// everything on VGA is timed on the pixel clock. the pixel clock for 640x480@60Hz
// is 25.175Mhz. we can't get that exactly from dividing a 100Mhz clock, but most
// monitors will sync to 25Mhz.
//
// One scan line - counts are pixel clocks
//
// Function     start   length   notes
// hsync pulse      0       96   HSYNC low, no video; beam moved to left of screen
// back porch      96       48   left overscan, no video
// video          144      640   video enabled and pixels clocked out
// front porch    784       16   right overscan, no video
// TOTAL                   800   entire scan line is 800 color clocks long
//
// One frame - not worrying about interlace here
// Counts here are in 800 clock scan lines
//
// Function     start   length   notes
// vsync pulse      0        2   VSYNC low, no video; beam moved to top of screen
// back porch       2    29/33   top overscan, no video
// video           31      480   480 horizontal scan lines are clocked out
// front porch    511       10   bottom overscan no video
// TOTAL               521/524   entire frame is 524 scan lines long
//

localparam HSYNC = 96;
localparam HBP = 48;
localparam HVIDEO = 640;
localparam HFP = 16;
localparam HLINE = HSYNC + HBP + HVIDEO + HFP;

localparam VSYNC = 2;
localparam VBP = 33;
localparam VVIDEO = 480;
localparam VFP = 10;
localparam VFRAME = VSYNC + VBP + VVIDEO + VFP;

reg [$clog2(HLINE):0]  hctr = 0;
reg [$clog2(VFRAME):0] vctr = 0;

// generate all the timing
//
always @ (posedge clk)
begin
    pixcnt <= pixcnt + 1;
    if (pixcnt == 2'b01) begin
        // trailing edge of pixel clock
        pixclk <= 0;
    end else if (pixcnt == 2'b11) begin
        // rising edge of pixel clock
        pixclk <= 1;

        if (hctr == HLINE - 1) begin
            // end of horizontal line
            hctr <= 0;
            if (vctr == VFRAME - 1) begin
                // end of frame
                vctr <= 0;
            end else begin
                vctr <= vctr + 1;
            end
            // compute vsync and y based on vertical line counter
            Vsync <= (vctr != VFRAME - 1) && (vctr+1 >= VSYNC);
            y <= vctr - (VSYNC + VBP - 1);
        end else begin
            hctr <= hctr + 1;
        end
        // compute hsync and x based on horizontal line counter
        Hsync <= (hctr != HLINE - 1) && (hctr+1 >= HSYNC);
        x <= hctr - (HSYNC + HBP - 1);
    end
end

endmodule
