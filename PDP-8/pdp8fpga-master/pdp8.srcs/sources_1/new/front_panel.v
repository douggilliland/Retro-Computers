// Jim Geist jimg@knights.ucf.edu
//
// PDP-8 front panel.
//
module front_panel#(
    // to make testing easier, the outer module can lower
    // the number of counter pins to make button recognition
    // much faster.
    parameter DEBCLOCK_BITS = 18
)(
    // hardware
    input reset,
    input clk,
    output [15:0] led,
    output [6:0] seg,
    output dp,
    output [3:0] an,
    input btnU,
    input btnD,
    input btnL,
    input btnR,
    input btnC,
    input [15:0] sw,

    // to CPU
    output [11:0] swreg,
    output [1:0] dispsel,
    output run,
    // these are all one cycle
    output loadpc,
    output loadac,
    output step,
    output deposit,

    // from CPU
    input [11:0] dispout,
    input linkout,
    input halt
);

    // debounce clock, shared for all buttons
    reg [DEBCLOCK_BITS-1:0] deb_cnt = 0;
    always @(posedge clk) deb_cnt <= deb_cnt + 1;
    wire deb_clk;
    assign deb_clk = deb_cnt == 0;

    // Button UP is step
    wire btnU_sync,  btnU_deb;
    sig_sync sync_u(.reset(reset), .clk(clk), .sig(btnU), .sigsync(btnU_sync));
    debbtn deb_u(.reset(reset), .clk(clk), .debclk(deb_clk), .btn(btnU_sync), .debbtn(btnU_deb));
    oneshot oneshot_u(.reset(reset), .clk(clk), .signal(btnU_deb), .pulse(step));

    // Button DOWN is deposit
    wire btnD_sync,  btnD_deb;
    sig_sync sync_d(.reset(reset), .clk(clk), .sig(btnD), .sigsync(btnD_sync));
    debbtn deb_d(.reset(reset), .clk(clk), .debclk(deb_clk), .btn(btnD_sync), .debbtn(btnD_deb));
    oneshot oneshot_d(.reset(reset), .clk(clk), .signal(btnD_deb), .pulse(deposit));

    // Button LEFT is load pc
    wire btnL_sync,  btnL_deb;
    sig_sync sync_l(.reset(reset), .clk(clk), .sig(btnL), .sigsync(btnL_sync));
    debbtn deb_l(.reset(reset), .clk(clk), .debclk(deb_clk), .btn(btnL_sync), .debbtn(btnL_deb));
    oneshot oneshot_l(.reset(reset), .clk(clk), .signal(btnL_deb), .pulse(loadpc));

    // Button RIGHT is load ac
    wire btnR_sync,  btnR_deb;
    sig_sync sync_r(.reset(reset), .clk(clk), .sig(btnR), .sigsync(btnR_sync));
    debbtn deb_r(.reset(reset), .clk(clk), .debclk(deb_clk), .btn(btnR_sync), .debbtn(btnR_deb));
    oneshot oneshot_r(.reset(reset), .clk(clk), .signal(btnR_deb), .pulse(loadac));

    // Button CENTER is select -- note that this signal is processed in this module
    wire btnC_sync,  btnC_deb, select;
    sig_sync sync_c(.reset(reset), .clk(clk), .sig(btnC), .sigsync(btnC_sync));
    debbtn deb_c(.reset(reset), .clk(clk), .debclk(deb_clk), .btn(btnC_sync), .debbtn(btnC_deb));
    oneshot oneshot_c(.reset(reset), .clk(clk), .signal(btnC_deb), .pulse(select));

    // we also want to sync and debounce the switch register, we could instantiate 12 of the
    // the above or just duplicate the logic for a 12-bit register.
    //

    // sync
    //
    reg [11:0] swreg_t = 0;
    reg [11:0] swreg_sync = 0;

    always @(posedge clk)
    begin
        if (reset)
        begin
            swreg_t <= 0;
            swreg_sync <= 0;
        end
        else
        begin
            swreg_sync <= swreg_t;
            swreg_t =  sw[11:0];
        end
    end

    // debounce
    //
    reg [11:0] swreg_reg = 0;

    always @(posedge clk)
    begin
        if (reset)
        begin
            swreg_reg <= 0;
        end
        else if (deb_clk == 0)
        begin
            swreg_reg <= swreg_sync;
        end
    end

    assign swreg = swreg_reg;

    // display select
    reg [1:0] dispsel_reg = 0;
    localparam [1:0] DISP_PC = 2'b00,
                     DISP_MQ = 2'b01,
                     DISP_MEM = 2'b10,
                     DISP_AC = 2'b11;

    // The select button cycles through the possible registers to display
    //
    always @(posedge clk)
    begin
        if (select)
        begin
            dispsel_reg <= dispsel_reg + 1;
        end
    end

    assign dispsel = dispsel_reg;

    // LED's on the front panel say which register we're looking at
    //
    reg [3:0] led_regbits = 04'b0000;

    always @(posedge clk)
    begin
        if (reset)
            led_regbits <= 4'b0000;
        else case (dispsel_reg)
            DISP_PC: led_regbits <= 4'b1000;
            DISP_MQ: led_regbits <= 4'b0010;
            DISP_MEM:led_regbits <= 4'b0001;
            DISP_AC: led_regbits <= 4'b0100;
        endcase
    end

    assign led[3:0] = led_regbits;

    // 7 sement is the 12-bit value in dispout with the left-hand decimal indicating link out
    //
    led7seg sseg(.clk(clk), .reset(reset), .value({ linkout, dispout }), .seg(seg), .an(an), .dp(dp));

    // state machine for run/stop
    //
    localparam [1:0] STOPPED = 2'b00,
                     STOPPING = 2'b01,
                     RUNNING = 2'b10;

    // run/stop switch and state machine
    //
    wire rs_sync;
    wire runstop;

    sig_sync sync_rs(.reset(reset), .clk(clk), .sig(sw[15]), .sigsync(rs_sync));
    debbtn deb_rs(.reset(reset), .clk(clk), .debclk(deb_clk), .btn(rs_sync), .debbtn(runstop));

    localparam RS_STOP = 0,
               RS_RUN = 1;

    reg [1:0] rs_curr = STOPPED;
    reg [1:0] rs_next = STOPPED;

    // state machine
    always @(posedge clk)
    begin
        if (reset)
        begin
            rs_curr <= 0;
        end
        else
        begin
            rs_curr <= rs_next;
        end
    end

    // next state logic
    always @(*)
    begin
        rs_next = rs_curr;

        case (rs_curr)
        STOPPED:
            if (runstop == RS_RUN && halt == 1'b0)
                rs_next = RUNNING;

        RUNNING:
            if (halt)
                rs_next = STOPPING;
            else if (runstop == RS_STOP)
                rs_next = STOPPED;

        STOPPING:
            if (runstop == RS_STOP)
                rs_next = STOPPED;
        endcase
    end

    assign run = rs_curr == RUNNING;
    assign led[15] = run;
endmodule
