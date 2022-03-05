//------------------------------------------------------------------
//-- Hello world example
//-- Turn on all the leds
//-- This example has been tested on the following boards:
//--   * Lattice icestick
//--   * Icezum alhambra (https://github.com/FPGAwars/icezum)
//------------------------------------------------------------------



module vga (
    output VSYNC,
    output HSYNC,
    //output OE,
    output reg [2:0] red,
    output reg [2:0] green,
    output reg [1:0] blue,
    output reg [2:0] led,
    output DIR,
    input CLK_12M,
    input CLK_CPU,
    input RW,
    input EN,
    input [2:0] REG,
    input [7:0] DATA
);
    //assign OE = 1;
// Input                   Input/output
// OE      DIR             An      Bn
// L       L               A = B   input
// L       H               input   B = A
// H       X               Z       Z
    // DIR only goes low when reading and enabled
    assign DIR = 1; //(EN | ~RW);

    `define CTRL_REG 3'd0       // Formatted as follows |INCR_NEG|INCR_4|INCR_3|INCR_2|INCR_1|INCR_0|MODE_1|MODE_0|  default to LORES
    `define ADDR_LOW_REG 3'd1   // also contains the increment ||||ADDR4|ADDR_3|ADDR_2|ADDR_1|ADDR_0|
    `define ADDR_HIGH_REG 3'd2
    `define DATA_REG 3'd3
    `define IEN_REG 3'd4    // formatted as follows |VSYNC| | | | | | |HSYNC|
    `define INTR_REG 3'd5   // formatted as follows |VSYNC| | | | | | |HSYNC|
    `define HSCROLL_REG 3'd6    // Scrolls one column in character mode and one pixel in pixel mode - negative is left, positive is right
    `define VSCROLL_REG 3'd7    // Scrolls one line in character mode and one pixel in pixel mode - negative is down, positive is up

    `define SAVE_STATE_INIT 2'd0
    `define SAVE_STATE_SAVE 2'd1
    `define SAVE_STATE_INCREMENT 2'd2
    `define SAVE_STATE_END 2'd3

    `define READ_STATE_INIT 2'd0
    `define READ_STATE_READ 2'd1
    `define READ_STATE_INCREMENT 2'd2
    `define READ_STATE_WAIT 2'd3

    `define MODE_LORES 2'd0;
    `define MODE_HIRES 2'd1;

    localparam H_RES_FULL = 799;
    localparam V_RES_FULL = 524;
    localparam H_RES = 640;
    localparam V_RES = 480;
    localparam V_CHAR_HIRES = 60;
    localparam H_CHAR_HIRES = 80;
    localparam V_CHAR_LORES = 30;
    localparam H_CHAR_LORES = 40;

    localparam RAM_SIZE = 14'h1800;// + 'h400;
    localparam SCREEN_CHARS = 'h1D4B;

    reg [1:0]   mode;
    reg [7:0]   ien_reg;
    reg [7:0]   intr_reg;
    reg [3:0]   increment_reg;
    reg         increment_neg;
    reg [7:0]   hscroll_reg;
    reg [7:0]   vscroll_reg;
    reg [13:0]  address_reg;
    wire [13:0]  char_address_reg = (address_reg >= RAM_SIZE) ? (address_reg - RAM_SIZE) : 14'h0;

    wire [7:0] increment = (increment_reg == 0) ? 0 : ((increment_reg <= 8) ? (1 << (increment_reg-1)) : 
    ((increment_reg == 9) ? 3 : 
    ((increment_reg == 10) ? 10 : 
    ((increment_reg == 11) ? H_CHAR_LORES : 
    ((increment_reg == 12) ? H_CHAR_HIRES : 
    ((increment_reg == 13) ? H_CHAR_HIRES*2 : 
    ((increment_reg == 14) ? H_CHAR_LORES*3 : H_CHAR_HIRES*3
    )))))));


   //assign DATA = (!EN && RW) ? data_out : 8'bzzzzzzzz;

    reg [7:0] data_out;

    parameter CHAR_INIT_FILE = "char_data.mem";
    parameter MEM_INIT_FILE = "start_data.mem";

    reg [7:0] character_rom['h400-1:0];
    //reg [7:0] character_ram['h400-1:0];
    reg [7:0] fb0[RAM_SIZE-1:0];

    reg [13:0] move_pos;
    reg [7:0] move_tmp;
    reg [7:0] do_scroll;
    reg move_state;

    reg [7:0] bgcolor;
    reg [7:0] fgcolor;

    reg RESET;

    integer i;


    initial begin
        RESET <= 1'b1;
        // address_reg <= 0;

        // for (i = 0; i < RAM_SIZE; i = i + 1) begin
        //     fb0[i] <= 8'h20;
        // end
        if (CHAR_INIT_FILE != "") begin
            $readmemh(CHAR_INIT_FILE, character_rom);

        end
        if (MEM_INIT_FILE != "") begin
            $readmemh(MEM_INIT_FILE, fb0);

        end
    end

    initial begin
        CLK_PIX <= 1'b0;
        RESET <= 1'b0;
        move_pos <= 8'h0;
        move_state <= 1'b0;
        //save_data <= 1'b0;
        address_reg <= 14'd0;
        show_cursor <= 1'd0;
        cursor_counter <= 0;
        char_write <= 1'b1;
        fgcolor <= 8'hE0;
        bgcolor <= 8'h00;
        led <= 3'b111;
        do_scroll <= 1'b0;
        save_state <= `SAVE_STATE_INIT;
        //read_state <= `READ_STATE_INIT;
        //read_data <= 1'b0;
        //read_reg <= 3'd0;
        //read_reg <= `CTRL_REG;
        mode <= 1;
        increment_reg <= 1;
        increment_neg <= 0;
        data_out <= 8'h41;
        vscroll_reg <= 0;
        command_buf_r_ptr <= 0;
        command_buf_w_ptr <= 0;
        get_command <= 0;
        // next_fb0_char = 0;
        // second_fb0_char = 0;
        // fb0_char = 0;
        // cur_char = 0;
        //char_data_line = 0;
    end

    wire CLK;

    reg [1:0] save_state;

    wire enabled = ~EN;
    wire write = ~RW;

    wire CLK_FAST;
    reg CLK_PIX;
    wire locked;

    pll mypll(.clock_in(CLK_12M), .clock_out(CLK_FAST), .locked(locked), .reset(~RESET));
    ////////
    // make a simple blink circuit
    ////////

    // keep track of time and location in blink_pattern
    reg fast_counter = 1'b0;


    wire DE;
    wire [9:0] XPOS;
    wire [9:0] YPOS;

    reg [7:0] cursor_counter;
    reg show_cursor;

    // CLK_PIX is CLK_FAST divided by 8
    always @(posedge CLK_FAST) begin
        fast_counter <= ~fast_counter;
    end


    always @(posedge fast_counter) begin
        CLK_PIX <= ~CLK_PIX;
    end

    // Set up VGA timing
    display_timings timings (.vsync(VSYNC), .hsync(HSYNC), .clk_pix(CLK_PIX), .de(DE), .sx(XPOS), .sy(YPOS), .rst(RESET));

    // hardware cursor
    always @(posedge VSYNC) begin
        if (char_write == 1'b0) begin
            cursor_stopped <= 0;
            cursor_counter <= cursor_counter + 1;
            if  (cursor_counter == 0) begin
                show_cursor <= ~show_cursor;
            end
        end else begin
            // Show cursor when a character was recently written
            cursor_counter <= 1;
            show_cursor <= 1;
            cursor_stopped <= 1;
        end
    end
    

    // TRY WITH DOUBLE BUFFER INSTEAD OF FIFO
    // Maybe with SPRAM

    // Now it is true that for the ice40 BRAM there needs to be two clock cycles between setting the address and reading the byte, but we can already set the new address in the next cycle, allowing us to read a byte every clock cycle once we set the initial address. 
    // https://fpga.michelanders.nl/2020/02/ice40-bram-spram-access-need-for-speed.html

    reg [2:0] tmp_command;
    reg [7:0] tmp_data;
    reg [2:0] command_reg;
    reg [7:0] command_data;

    reg [10:0] command_buffer[1 << 10];
    reg [10:0] command;
    reg [9:0] command_buf_r_ptr;
    reg [9:0] command_buf_w_ptr;

    reg [2:0] read_reg;

    reg [3:0] get_command;
    reg [3:0] save_data;



    // always @(posedge CLK_12M) begin
    //     if ((EN == 1'b0) && (RW == 1'b1) && (read_data == 1'b0)) begin
    //         read_data <= 1'b1;
    //         read_reg <= REG;
    //     end
    //     else begin
    //         //led <= 3'd7;
    //         read_data <= 1'b0;
    //         //read_reg <= 1'b0;
    //     end
    // end

    //FIFO fifo ()

    //wire writing = (!CLK_CPU & !EN & !RW);
    wire writing = (CLK_CPU | EN | RW);

    wire [7:0] cnt1 = command_buf_w_ptr - command_buf_r_ptr;
    wire [7:0] cnt2 = command_buf_r_ptr - command_buf_w_ptr;

    wire [7:0] buf_cnt = (command_buf_w_ptr >= command_buf_r_ptr) ? cnt1 : cnt2;

    reg [10:0] data_tmp;

    reg [4:0] did_write;

    reg char_write;
    reg cursor_stopped;



    always @(negedge CLK_CPU) begin
        if (~EN & ~RW) begin
            data_tmp <= ((REG << 8) | DATA);
            did_write <= 4'd0;
            
        end else if (did_write < 4'd4) begin
            did_write <= did_write + 1;
            command_buffer[command_buf_w_ptr] <= data_tmp;
            if (did_write == 4'd0) begin
                command_buf_w_ptr <= command_buf_w_ptr + 1;
            end
        end
    end


    always @(posedge CLK_FAST) begin
        if (cursor_stopped) begin
            char_write <= 0;
        end
        case(save_state)
        `SAVE_STATE_INIT:
        begin
            if (buf_cnt > 0) begin
                //
                if (get_command == 4'd4) begin
                    save_state <= `SAVE_STATE_SAVE;
                    command_reg <= command[10:8];
                    command_data <= command[7:0];
                    get_command <= 4'd0;

                end else begin
                    command <= command_buffer[command_buf_r_ptr];
                    get_command <= get_command + 1;
                    save_state <= `SAVE_STATE_INIT;
                end
            end
            else begin

                save_state <= `SAVE_STATE_INIT;
                //char_write <= 1'b0;
                if (do_scroll && !DE) begin
                    // fb0[move_pos] <= move_tmp;
                    // move_pos <= move_pos + 1;
                end
            end
        end
        `SAVE_STATE_SAVE:
        begin
            //led <= 3'b000;
            case (command_reg)
            `CTRL_REG:
            begin
                mode <= command_data[1:0];
                increment_reg <= command_data[6:2];
                increment_neg <= command_data[7];
                save_state <= `SAVE_STATE_END;
            end
            `DATA_REG:
            begin
                if (!DE) begin
                    if (save_data == 4'd4) begin
                        save_state <= `SAVE_STATE_INCREMENT;
                        save_data <= 4'd0;
                    end else begin
                        if (address_reg == 'h1FFE) begin
                            bgcolor <= command_data;
                            // led <= 3'b110;
                        end else if (address_reg == 'h1FFF) begin
                            fgcolor <= command_data;
                            // led <= 3'b101;
                        end else if ((address_reg < SCREEN_CHARS)) begin
                            fb0[address_reg] <= command_data;
                            char_write <= 1;
                        end
                        save_data <= save_data + 1;
                        save_state <= `SAVE_STATE_SAVE;
                    end
                end
            end
            `ADDR_LOW_REG:
            begin
                
                address_reg[4:0] <= command_data[5:0];
                save_state <= `SAVE_STATE_END;
            end
            `ADDR_HIGH_REG:
            begin
                address_reg[12:5] <= command_data;
                save_state <= `SAVE_STATE_END;
            end
            `VSCROLL_REG:
            begin
                do_scroll <= command_data;
                save_state <= `SAVE_STATE_END;
            end
            default:
            begin
                save_state <= `SAVE_STATE_END;
                
            end
            endcase
        end
        
        `SAVE_STATE_INCREMENT:
        begin
            if (increment_neg == 1'b0) begin
                if (address_reg < 'h2000) begin
                    address_reg <= address_reg + increment;
                end
                else begin
                    address_reg <= (address_reg + increment) - 'h2000;
                end
            end else begin
                if (address_reg <= increment) begin
                    address_reg <= address_reg + 'h2000 - increment;
                end
                else begin
                    address_reg <= address_reg - increment;
                end
            end

            save_state <= `SAVE_STATE_END;
        end
        `SAVE_STATE_END:
        begin
            command_buf_r_ptr <= command_buf_r_ptr + 1;
            save_state <= `SAVE_STATE_INIT;
        end
        default:
        begin
            save_state <= `SAVE_STATE_INIT;
        end
        endcase
    end

    reg [7:0] ram_char;
    reg [7:0] rom_char;
    reg [7:0] cur_char;
    reg [7:0] fb0_char;
    reg [7:0] next_fb0_char;
    reg [7:0] second_fb0_char;
    // reg [7:0] fb1_char;

    // reg [7:0] ram_data;

    // reg get_state;

    //wire [7:0] char_data_line = character_rom[((cur_char & 8'h7F) << 3) + (YPOS & 8'h7)];
    //wire [7:0] char_data_line = (cur_char < 8'h80) ? character_rom[((cur_char & 8'h7F) << 3) + (YPOS & 8'h7)] : (DE ? character_ram[((cur_char & 8'h7F) << 3) + (YPOS & 8'h7)] : 8'h0);
    

    //wire [12:0] char_add = (YPOS >> 3)* H_CHAR_HIRES +(XPOS >> 3);

    //wire [12:0] ram_add = DE ? char_add : copy_addr;
    //reg [12:0] ram_add;

    // RAM address to get character from
    wire [6:0] line = (YPOS >> 3);
    wire [6:0] char = ((XPOS+2) >> 3);
    wire [12:0] next_line_addr = (YPOS > V_RES) ? 0 : ((line+1) * H_CHAR_HIRES);
    wire [12:0] this_line_addr = ((line * H_CHAR_HIRES) + char);
    wire [12:0] ram_add = DE ? this_line_addr : next_line_addr;

    //reg [12:0] ram_add;


    reg [7:0] char_data_line;


    //wire cur_px = (char_data_line >> (XPOS & 8'h7)) & 1'b1;

    reg cur_px;


    

    always @(posedge CLK_FAST) begin

        if (DE) begin
            //ram_add <= ((line * H_CHAR_HIRES) + char);
            fb0_char <= fb0[ram_add];
            cur_char <= (show_cursor && (ram_add == address_reg)) ? 8 : fb0_char;
            char_data_line <= character_rom[((cur_char & 8'h7F) << 3) | (YPOS & 8'h7)];
            cur_px <= (char_data_line >> (XPOS & 8'h7)) & 1'b1;
        end else if (do_scroll) begin

            //move_tmp <= fb0[move_pos + do_scroll * V_CHAR_HIRES];

        end

    end

    always @(posedge CLK_PIX) begin
        
        red   = (DE == 1'b1) ? (cur_px ? fgcolor[7:5] : bgcolor[7:5]) : 3'h0;
        green = (DE == 1'b1) ? (cur_px ? fgcolor[4:2] : bgcolor[4:2]) : 3'h0;
        blue  = (DE == 1'b1) ? (cur_px ? fgcolor[1:0] : bgcolor[1:0]) : 2'h0;

        // red   = (DE == 1'b1) ? (XPOS[2:0]) : 3'h0;
        // green = (DE == 1'b1) ? (XPOS[5:3])  : 3'h0;
        // blue  = (DE == 1'b1) ? (XPOS[7:6]) : 2'h0;
        // if ((YPOS == V_RES) && (XPOS == 1'b0)) begin
        //     current_fb <= ~current_fb;
        // end
    end
    
endmodule
