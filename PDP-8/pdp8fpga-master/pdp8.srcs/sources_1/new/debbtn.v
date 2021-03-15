// Jim Geist jimg@knights.ucf.edu
//
// Debounce a button
//
module debbtn(
    input reset,
    input clk,
    input debclk,
    input btn,
    output debbtn
);
    reg deb_reg = 0;

    always @(posedge clk)
    begin
        if (reset)
        begin
            deb_reg <= 0;
        end
        else if (debclk == 1'b1)
        begin
            deb_reg <= btn;
        end    
    end
    
    assign debbtn = deb_reg;    
endmodule
