// Jim Geist jimg@knights.ucf.edu
//
// Memory controller
//
// This memory controller is set up to handle memory of any speed, 
// although on the Basys-3 we're using block memory which always
// takes 2 cycles. The interface allows us to write the CPU to work
// with any memory.
//
// on start, addr, write, and (if needed) datain are captured
// when done, done is pulsed high for one clock cycle
//
module memctl(
    input clk,
    input reset,
    input start,
    input write,
    input [11:0] addr,
    input [11:0] datain,
    output [11:0] dataout,
    output done
);
    localparam [2:0] IDLE       = 3'b000,
                     READING    = 3'b001,
                     READ       = 3'b010,
                     WRITING    = 3'b100,
                     WROTE      = 3'b101;
    
    reg [2:0] state_reg = IDLE;
    reg [2:0] state_next = IDLE;
    reg done_reg = 1'b1;
    reg done_next = 1'b1;
    reg wea_reg = 1'b0;
    reg wea_next = 1'b0; 
    reg [11:0] addra_reg = 12'o000;
    reg [11:0] addra_next = 12'o000;
    reg [11:0] dina_reg = 12'o000;
    reg [11:0] dina_next = 12'o000;
    
    core mainmem(.clka(clk), .ena(1'b1), .wea(wea_reg), .addra(addra_reg), .dina(dina_reg), .douta(dataout));
    
    assign done = done_reg;

    always @(posedge clk)
    begin
        if (reset)
        begin
            state_reg <= IDLE;
            done_reg <= 1'b1;
            wea_reg <= 1'b0;
            addra_reg <= 12'o000;
            dina_reg <= 12'o000;
        end
        else
        begin
            state_reg <= state_next;
            done_reg <= done_next;
            wea_reg <= wea_next;
            addra_reg <= addra_next;
            dina_reg <= dina_next;
        end
    end
    
    always @(*)
    begin
        state_next = state_reg;
        done_next = done_reg;
        wea_next = wea_reg;
        addra_next = addra_reg;
        dina_next = dina_reg;
        
        case (state_reg)
        IDLE:
            begin
                done_next = 1'b0;
                if (start)
                begin
                    addra_next = addr;
                    if (write)
                    begin
                        wea_next = 1'b1;
                        dina_next = datain;
                        state_next = WRITING;
                    end
                    else
                    begin
                        state_next = READING;
                    end
                end
            end
        WRITING:
            state_next = WROTE;
            
        WROTE:
            begin
                state_next = IDLE;
                wea_next = 1'b0;
                done_next = 1'b1;
            end
            
        READING:
            state_next = READ;
            
        READ:
            begin
                state_next = IDLE;
                done_next = 1'b1;
            end 
        endcase
    end
endmodule
