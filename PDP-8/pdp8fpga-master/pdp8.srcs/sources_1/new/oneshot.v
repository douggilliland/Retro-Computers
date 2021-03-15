// Jim Geist jimg@knights.ucf.edu
//
// Generate a single clock pulse on the leading edge transition of the given signal
//
module oneshot(
    input reset,
    input clk,
    input signal,
    output pulse
);

    localparam [0:0] WAIT = 1'b0,
                     ACTIVE = 1'b1;

    reg state = WAIT;
    reg pulse_reg = 0;

    // single pulse
    always @(posedge clk)
    begin
        if (reset)
        begin
            state <= WAIT;
            pulse_reg <= 0;
        end
        else
        case (state)
        WAIT:
        begin
            if (signal == 1'b1)
            begin
                pulse_reg <= 1;
                state <= ACTIVE;
            end
        end

        ACTIVE:
        begin
            pulse_reg <= 0;
            if (signal == 1'b0)
                state <= WAIT;
        end
        endcase
    end

    assign pulse = pulse_reg;
endmodule
