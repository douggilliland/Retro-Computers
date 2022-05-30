// jimg@knights.ucf.edu
//
// Synchronize an async signal to the clock
//
module sig_sync(
    input reset,
    input clk,
    input sig,
    output sigsync);

    reg r0 = 0;
    reg r1 = 0;

    // sync via two registers
    always @(posedge clk)
    begin
        if (reset)
        begin
            r0 <= 0;
            r1 <= 0;
        end
        else
        begin
            r0 <= sig;
            r1 <= r0;
        end
    end

    assign sigsync = r1;
endmodule
