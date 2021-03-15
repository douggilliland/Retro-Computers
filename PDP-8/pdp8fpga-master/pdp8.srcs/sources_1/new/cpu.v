// Jim Geist jimg@knights.ucf.edu
//
// PDP-8 CPU
//
// This is the data portion of the CPU, which includes the registers and
// the ALU. It is driven by signals which are generated in the state 
// module.
//
module cpu(
    // global
    input clk,
    input reset,

    // front panel
    input [11:0] sr,
    input [1:0] dispsel,
    input run,
    input loadpc,
    input loadac,
    input step,
    input deposit,
    output [11:0] dispout,
    output linkout,
    output halt,
    input dispselmem,

    // memory
    output [11:0] ma,
    output [11:0] mb,
    input [11:0] mem,

    // registers 
    output [11:0] pc,
    output [11:0] ac,
    output link,
    output [11:0] ea,
    output [11:0] ir,
    output [11:0] mq,
    output [4:0] pg,
    output [4:0] sc,
    output [23:0] acmq,

    // state signals
    input ac_from_sr,
    input clear_ac,
    input com_ac,
    input inc_ac,
    input ac_from_ac_plus_mem,
    input ac_from_ac_and_mem,
    input ac_from_ac_or_sr,
    input ac_from_ac_or_mq,
    input ac_from_mq,

    input clear_l,
    input set_l,
    input com_l,

    input rar_lac,
    input ral_lac,
    input rot2,

    input inc_pc,
    input pc_from_sr,
    input pc_from_ea,
    input pc_from_ea_plus_one,

    input ma_from_pc,
    input ma_from_sr,
    input ma_from_ea,
    input ma_from_mem_page,

    input mb_from_sr,
    input mb_from_mem_plus_one,
    input mb_from_ac,
    input mb_from_pc,

    input mq_from_ac,
    input clear_mq,

    input ir_from_mem,

    input pg_from_pc,

    input ea_from_mem_page,
    input ea_from_mem,
    input ea_from_mb,
    input inc_ea,

    input clear_sc,
    input inc_sc,

    input acmq_from_ac_mq,

    input multiply,
    input dvi_step,

    input halt_cpu,
    input clear_halt
);

reg hlt_reg;
reg [11:0] pc_reg;
reg [11:0] ac_reg;
reg link_reg;
reg [11:0] ea_reg;
reg [11:0] ir_reg;
reg [11:0] ma_reg;
reg [11:0] mb_reg;
reg [11:0] mq_reg;
reg [23:0] acmq_reg;
reg [4:0] pg_reg;
reg [4:0] sc_reg;

assign pc = pc_reg;
assign ac = ac_reg;
assign link = link_reg;
assign ea = ea_reg;
assign ir = ir_reg;
assign ma = ma_reg;
assign mb = mb_reg;
assign mq = mq_reg;
assign pg = pg_reg;
assign sc = sc_reg;
assign acmq = acmq_reg;

wire [11:0] ac_dvi_next;
assign ac_dvi_next = { ac[10:0], acmq[23] };

assign halt = hlt_reg;

// front panel display
localparam [1:0] DISP_PC = 2'b00,
                 DISP_MQ = 2'b01,
                 DISP_MEM = 2'b10,
                 DISP_AC = 2'b11;

assign dispout =
    (dispsel == DISP_PC) ? pc :
    (dispsel == DISP_MQ) ? mq :
    (dispsel == DISP_MEM)? mem :
                           ac;
assign linkout = (dispsel == DISP_AC) && link;
assign dispselmem = dispsel == DISP_MEM;

wire mem_PAG;
assign mem_PAG = mem[7]    == 1'b1;

// honor data path requests
always @(posedge clk)
begin
    if (reset)
    begin
        pc_reg <= 0;
        ac_reg <= 0;
        link_reg <= 0;
        ma_reg <= 0;
        mb_reg <= 0;
        ea_reg <= 0;
        ir_reg <= 0;
        mq_reg <= 0;
        pg_reg <= 0;
        hlt_reg <= 0;
    end
    else
    begin
        if (halt_cpu) hlt_reg <= 1;
        else if (clear_halt) hlt_reg <= 0;

        if (ac_from_sr) ac_reg <= sr;
        else if (ac_from_ac_or_sr) ac_reg <= ac | sr;
        else if (ac_from_ac_plus_mem) { link_reg, ac_reg } <= { link_reg, ac_reg } + { 1'b0, mem };
        else if (ac_from_ac_and_mem) ac_reg <= ac_reg & mem;
        else if (clear_ac) ac_reg <= 0;
        else if (com_ac) ac_reg <= ~ac;
        else if (inc_ac) ac_reg <= ac + 1;
        else if (ac_from_ac_or_mq) ac_reg <= ac_reg | mq_reg;
        else if (ac_from_mq) ac_reg <= mq_reg;

        if (clear_l) link_reg <= 0;
        else if (set_l) link_reg <= 1;
        else if (com_l) link_reg <= ~link_reg;

        if (rar_lac && !ral_lac)
        begin
            if (rot2)
            begin
                ac_reg[9:0] <= ac_reg[11:2];
                ac_reg[10] <= link_reg;
                ac_reg[11] <= ac_reg[0];
                link_reg <= ac_reg[1];
            end
            else
            begin
                ac_reg[10:0] <= ac_reg[11:1];
                ac_reg[11] <= link_reg;
                link_reg <= ac_reg[0];
            end
        end

        if (ral_lac && !rar_lac)
        begin
            if (rot2)
            begin
                ac_reg[11:2] <= ac_reg[9:0];
                ac_reg[1] <= link_reg;
                ac_reg[0] <= ac_reg[11];
                link_reg <= ac_reg[10];
            end
            else
            begin
                ac_reg[11:1] <= ac_reg[10:0];
                ac_reg[0] <= link_reg;
                link_reg <= ac_reg[11];
            end
        end

        if (pc_from_sr) pc_reg <= sr;
        else if (pc_from_ea) pc_reg <= ea_reg;
        else if (pc_from_ea_plus_one) pc_reg <= ea_reg + 1;
        else if (inc_pc) pc_reg <= pc_reg + 1;

        if (ma_from_pc) ma_reg <= pc_reg;
        else if (ma_from_sr) ma_reg <= sr;
        else if (ma_from_ea) ma_reg <= ea_reg;
        else if (ma_from_mem_page) ma_reg <= { (mem_PAG ? pg_reg : 5'b00000), mem[6:0] };

        if (mb_from_sr) mb_reg <= sr;
        else if (mb_from_mem_plus_one) mb_reg <= mem + 1;
        else if (mb_from_ac) mb_reg <= ac_reg;
        else if (mb_from_pc) mb_reg <= pc_reg;

        if (mq_from_ac) mq_reg <= ac_reg;
        else if (clear_mq) mq_reg <= 0;

        if (ir_from_mem) ir_reg <= mem;

        if (pg_from_pc) pg_reg <= pc_reg[11:7];

        if (ea_from_mem_page) ea_reg <= { (mem_PAG ? pg_reg : 5'b00000), mem[6:0] };
        else if (ea_from_mem) ea_reg <= mem;
        else if (ea_from_mb) ea_reg <= mb_reg;
        else if (inc_ea) ea_reg <= ea_reg + 1;

        if (clear_sc) sc_reg <= 0;
        else if (inc_sc) sc_reg <= sc_reg + 1;

        if (acmq_from_ac_mq) acmq_reg <= { ac_reg, mq_reg };

        if (multiply) { ac_reg, mq_reg } <= mq_reg * mem;

        if (dvi_step)
        begin
            if (ac_dvi_next >= mem)
            begin
                ac_reg <= ac_dvi_next - mem;
                mq_reg <= { mq_reg[10:0], 1'b1 };
            end
            else
            begin
                ac_reg <= ac_dvi_next;
                mq_reg <= { mq_reg[10:0], 1'b0 };
            end
            acmq_reg <= { acmq_reg[22:0], 1'b0 };
        end
    end
end
endmodule
