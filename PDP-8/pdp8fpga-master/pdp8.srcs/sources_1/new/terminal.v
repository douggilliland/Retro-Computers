// Jim Geist jimg@knights.ucf.edu
//
// Terminal device. Implements the PDP-8 IO bus as device 4 
// (printer) and displays the result as text on a VGA monitor.
//
module terminal(
    input clk,
    input reset,
    input [11:0] ac,
    input [5:0] device,
    input [2:0] iop,
    output ioskip,
    output [3:0] red,
    output [3:0] green,
    output [3:0] blue,
    output hsync,
    output vsync
);

// color output registers
reg [3:0] red_reg = 0;
reg [3:0] green_reg = 0;
reg [3:0] blue_reg = 0;

assign red = red_reg;
assign green = green_reg;
assign blue = blue_reg;

// VGA timing signals
wire pixclk;
wire [1:0] pixcnt;
wire [15:0] x;
wire [15:0] y;

// Frame buffer interface
reg [12:0] fbwaddr = 0;     // addr to write into video memory (frame buffer)
reg [12:0] fbwaddr_next = 0;
wire fbwen;                 // frame buffer write enable
reg [12:0] fbaddr = 0;      // addr for reading from the frame buffer
wire [7:0] fbdata;          //   and the data returned

// font ROM interface
wire [7:0] data;            // 8 bits of pixel data
reg [7:0] line;             // the cached current line of the font 

// cursor location
reg [12:0] curx_reg = 0;    // current x and y *character* position
reg [12:0] cury_reg = 0;    //  to write next character
reg [12:0] curx_next = 0;
reg [12:0] cury_next = 0;

localparam MAX_COL = 79,
           COLUMNS = 80,
           MAX_ROW = 59;

// device interface
wire TSF, TCF, TPC;
assign TSF = (device == 4) && (iop[0] != 0);
assign TCF = (device == 4) && (iop[1] != 0);
assign TPC = (device == 4) && (iop[2] != 0);

localparam [1:0] IDLE = 0,
                 DECODE = 1,
                 PREWRITE = 2,
                 WRITE = 3;

reg [1:0] state_reg = IDLE;
reg [1:0] state_next = IDLE;
reg device_flag_reg = 1;
reg device_flag_next = 1;
reg [7:0] buf_reg = 0;
reg [7:0] buf_next = 0;
reg [2:0] write_count_reg = 0;
reg [2:0] write_count_next = 0;

assign ioskip = TSF && device_flag_reg;

assign fbwen = state_reg == WRITE;

always @(posedge clk)
begin
    if (reset)
    begin
        state_reg <= IDLE;
        device_flag_reg <= 1;
        buf_reg <= 0;
        curx_reg <= 0;
        cury_reg <= 0;
        fbwaddr <= 0;
        write_count_reg <= 0;
    end
    else
    begin
        state_reg <= state_next;
        device_flag_reg <= device_flag_next;
        buf_reg <= buf_next;
        curx_reg <= curx_next;
        cury_reg <= cury_next;
        fbwaddr <= fbwaddr_next;
        write_count_reg <= write_count_next;
    end
end

always @(*)
begin
    state_next = state_reg;
    device_flag_next = device_flag_reg;
    buf_next = buf_reg;
    curx_next = curx_reg;
    cury_next = cury_reg;
    fbwaddr_next = fbwaddr;
    write_count_next = write_count_reg;

    if (TCF) device_flag_next = 0;

    case (state_reg)
    IDLE:
        if (TPC)
        begin
            buf_next = ac[7:0];
            state_next = DECODE;
        end

    DECODE:
        if (buf_reg == 10)
        begin
            // line feed
            cury_next = (cury_reg == MAX_ROW) ? 0 : cury_reg + 1;
            device_flag_next = 1;
            state_next = IDLE;
        end
        else if (buf_reg == 13)
        begin
            // carriage return
            curx_next = 0;
            device_flag_next = 1;
            state_next = IDLE;
        end
        else if (buf_reg < 32 || buf_reg > 126)
        begin
            // non ASCII, ignore it
            device_flag_next = 1;
            state_next = IDLE;
        end
        else
        begin
            // printable character
            fbwaddr_next = cury_reg * COLUMNS + curx_reg;
            state_next = PREWRITE;
        end

    PREWRITE:
        begin
            write_count_next = 2;
            state_next = WRITE;
            if (curx_reg == MAX_COL)
            begin
                curx_next = 0;
                if (cury_reg == MAX_ROW)
                    cury_next = 0;
                else
                    cury_next = cury_reg + 1;
            end
            else
            begin
                curx_next = curx_reg + 1;
            end
        end

    WRITE:
        begin
            if (write_count_reg == 0)
            begin
                device_flag_next = 1;
                state_next = IDLE;
            end
            else
            begin
                write_count_next = write_count_reg - 1;
            end
        end

    default:
        state_next = IDLE;
    endcase
end


// TODO make this in the style of the project

// The timing
vga_timing timing(
    .clk(clk), .pixclk(pixclk), .Hsync(hsync), .Vsync(vsync), .pixcnt(pixcnt),
    .x(x), .y(y));

// the frame buffer, which is a dual-port RAM
// 
vram fb(
    .clka(clk), .ena(1), .wea(1'b0), .addra(fbaddr), .dina(8'h00), .douta(fbdata),
    .clkb(clk), .enb(fbwen), .web(fbwen), .addrb(fbwaddr), .dinb(buf_reg)
);

// the font ROM. this is from a 70's era microcomputer, and is an 8x8 font that
// contains 256 characters (the characters outside of ASCII are meant for 
// games). 
// 
// the address input of the ROM is hard-wired to be the character at the current
// frame buffer location, followed by the low 3 bits of the current scan line 
// number, which selects which row of the character should be displayed.
//
fontrom font(.clka(clk), .addra({ fbdata, y[2:0] }), .douta(data));


// display the font data on the screen. this is a bit tricky because of timing.
// we have to account for the time to ready *two* memories per character and there
// are only 4 clock cycles per character. since each character is 8 pixels, we 
// end up having 32 clock cycles per character. we have to arrange for `line`
// to be set to the data for the next character *after* the last time it's needed
// for the current character. 
//
always @ (posedge clk)
begin
    case ({x[2:0], pixcnt})
        // x = 6, start reading the frame buffer for the next
        // character. we can do this as early as we like.
        5'b11001: fbaddr <= (y[15:3] * 80) + ((x+2)>>3);
        
        // x = 7, system clock cycle just before we start the next
        // character. by now `data` has been read from the font 
        // and we can safely move it into `line`
        5'b11110: line <= data;
    endcase

    // on the last system clock cycle of a pixel clock, prepare 
    // the vga output to be the next pixel of the font, which will
    // therefore be ready on the rising edge of the upcoming pixel
    // clock.
    //
    // we also handle blanking here by ensuring x and y are in the 
    // display region.
    //
    // only green to simulate an old-school monochrome CRT
    //
    if (pixcnt == 3)
    begin
        if ((x == 16'hffff || x < 639) && (y <= 480))
            green_reg <= {4{line[(x+1) & 3'b111]}};
        else
            green_reg <= 0;
    end
end


endmodule

