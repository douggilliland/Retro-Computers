// Jim Geist jimg@knights.ucf.edu
//
// Main module 
//
module main#(
    parameter DEBCLOCK_BITS = 18
)(
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
    output [3:0] vgaRed,
    output [3:0] vgaGreen,
    output [3:0] vgaBlue,
    output Hsync,
    output Vsync
);

wire reset;
assign reset = 0;

// front panel
wire [11:0] sr;
wire [1:0] dispsel;
wire dispselmem;
wire run;
wire loadpc;
wire loadac;
wire step;
wire deposit;
wire [11:0] dispout;
wire linkout;

// memory
wire mem_start;
wire mem_write;
wire [11:0] ma;
wire [11:0] mb;
wire [11:0] mem;
wire mem_done;

// registers
wire [11:0] pc;
wire [11:0] ac;
wire link;
wire [11:0] ea;
wire [11:0] ir;
wire [11:0] mq;
wire [4:0] pg;
wire [4:0] sc;
wire [23:0] acmq;

// state
wire ac_from_sr;
wire clear_ac;
wire com_ac;
wire inc_ac;
wire ral_lac;
wire rar_lac;
wire rot2;
wire ac_from_ac_plus_mem;
wire ac_from_ac_and_mem;
wire ac_from_ac_or_sr;
wire ac_from_ac_or_mq;
wire ac_from_mq;
wire clear_l;
wire set_l;
wire com_l;
wire pc_from_sr;
wire pc_from_ea;
wire pc_from_ea_plus_one;
wire inc_pc;
wire ma_from_pc;
wire ma_from_sr;
wire ma_from_ea;
wire ma_from_mem_page;
wire mb_from_sr;
wire mb_from_mem_plus_one;
wire mb_from_ac;
wire mb_from_pc;
wire mq_from_ac;
wire clear_mq;
wire ir_from_mem;
wire pg_from_pc;
wire ea_from_mem_page;
wire ea_from_mem;
wire ea_from_mb;
wire inc_ea;
wire clear_sc;
wire inc_sc;
wire acmq_from_ac_mq;
wire multiply;
wire dvi_step;
wire halt_cpu;
wire clear_halt;

// I/O
wire [5:0] device;
wire [2:0] iop;
wire term_io_skip;

front_panel fp(
    .clk(clk),
    .reset(reset),
    .led(led),
    .seg(seg),
    .dp(dp),
    .an(an),
    .btnU(btnU),
    .btnD(btnD),
    .btnL(btnL),
    .btnR(btnR),
    .btnC(btnC),
    .sw(sw),
    .swreg(sr),
    .run(run),
    .loadpc(loadpc),
    .loadac(loadac),
    .step(step),
    .deposit(deposit),
    .dispsel(dispsel),
    .dispout(dispout),
    .linkout(link),
    .halt(halt)
);

defparam fp.DEBCLOCK_BITS = DEBCLOCK_BITS;

memctl mc(
    .clk(clk),
    .reset(reset),
    .start(mem_start),
    .write(mem_write),
    .addr(ma),
    .datain(mb),
    .dataout(mem),
    .done(mem_done)
);

cpu_state cpu_state_inst(
    .clk(clk),
    .reset(reset),
    .run(run),
    .loadac(loadac),
    .loadpc(loadpc),
    .step(step),
    .deposit(deposit),
    .dispselmem(dispselmem),
    .mem_done(mem_done),
    .ac(ac),
    .link(link),
    .sr(sr),
    .ir(ir),
    .ma(ma),
    .mb(mb),
    .mem(mem),
    .ea(ea),
    .acmq(acmq),
    .sc(sc),
    .mem_start(mem_start),
    .mem_write(mem_write),
    .ac_from_sr(ac_from_sr),
    .clear_ac(clear_ac),
    .com_ac(com_ac),
    .inc_ac(inc_ac),
    .ral_lac(ral_lac),
    .rar_lac(rar_lac),
    .rot2(rot2),
    .ac_from_ac_plus_mem(ac_from_ac_plus_mem),
    .ac_from_ac_and_mem(ac_from_ac_and_mem),
    .ac_from_ac_or_sr(ac_from_ac_or_sr),
    .ac_from_ac_or_mq(ac_from_ac_or_mq),
    .ac_from_mq(ac_from_mq),
    .clear_l(clear_l),
    .set_l(set_l),
    .com_l(com_l),
    .pc_from_sr(pc_from_sr),
    .pc_from_ea(pc_from_ea),
    .pc_from_ea_plus_one(pc_from_ea_plus_one),
    .inc_pc(inc_pc),
    .ma_from_pc(ma_from_pc),
    .ma_from_sr(ma_from_sr),
    .ma_from_ea(ma_from_ea),
    .ma_from_mem_page(ma_from_mem_page),
    .mb_from_sr(mb_from_sr),
    .mb_from_mem_plus_one(mb_from_mem_plus_one),
    .mb_from_ac(mb_from_ac),
    .mb_from_pc(mb_from_pc),
    .mq_from_ac(mq_from_ac),
    .clear_mq(clear_mq),
    .ir_from_mem(ir_from_mem),
    .pg_from_pc(pg_from_pc),
    .ea_from_mem_page(ea_from_mem_page),
    .ea_from_mem(ea_from_mem),
    .ea_from_mb(ea_from_mb),
    .inc_ea(inc_ea),
    .clear_sc(clear_sc),
    .inc_sc(inc_sc),
    .acmq_from_ac_mq(acmq_from_ac_mq),
    .multiply(multiply),
    .dvi_step(dvi_step),
    .halt_cpu(halt_cpu),
    .clear_halt(clear_halt),
    .device(device),
    .iop(iop)
);

cpu cpu_inst(
    .clk(clk),
    .reset(0),

    // front panel
    .sr(sw),
    .dispsel(dispsel),
    .run(run),
    .loadpc(loadpc),
    .loadac(loadac),
    .step(step),
    .deposit(deposit),
    .dispout(dispout),
    .linkout(linkout),
    .halt(halt),
    .dispselmem(dispselmem),

    // memory
    .ma(ma),
    .mb(mb),
    .mem(mem),

    // registers
    .pc(pc),
    .ac(ac),
    .link(link),
    .ea(ea),
    .ir(ir),
    .mq(mq),
    .pg(pg),
    .acmq(acmq),
    .sc(sc),

    .ac_from_sr(ac_from_sr),
    .clear_ac(clear_ac),
    .com_ac(com_ac),
    .inc_ac(inc_ac),
    .ac_from_ac_plus_mem(ac_from_ac_plus_mem),
    .ac_from_ac_and_mem(ac_from_ac_and_mem),
    .ac_from_ac_or_sr(ac_from_ac_or_sr),
    .ac_from_ac_or_mq(ac_from_ac_or_mq),
    .ac_from_mq(ac_from_mq),
    .clear_l(clear_l),
    .set_l(set_l),
    .com_l(com_l),
    .rar_lac(rar_lac),
    .ral_lac(ral_lac),
    .rot2(rot2),
    .inc_pc(inc_pc || term_io_skip),
    .pc_from_sr(pc_from_sr),
    .pc_from_ea(pc_from_ea),
    .pc_from_ea_plus_one(pc_from_ea_plus_one),
    .ma_from_pc(ma_from_pc),
    .ma_from_sr(ma_from_sr),
    .ma_from_ea(ma_from_ea),
    .ma_from_mem_page(ma_from_mem_page),
    .mb_from_sr(mb_from_sr),
    .mb_from_mem_plus_one(mb_from_mem_plus_one),
    .mb_from_ac(mb_from_ac),
    .mb_from_pc(mb_from_pc),
    .mq_from_ac(mq_from_ac),
    .clear_mq(clear_mq),
    .ir_from_mem(ir_from_mem),
    .pg_from_pc(pg_from_pc),
    .ea_from_mem_page(ea_from_mem_page),
    .ea_from_mem(ea_from_mem),
    .ea_from_mb(ea_from_mb),
    .inc_ea(inc_ea),
    .clear_sc(clear_sc),
    .inc_sc(inc_sc),
    .acmq_from_ac_mq(acmq_from_ac_mq),
    .halt_cpu(halt_cpu),
    .clear_halt(clear_halt),
    .multiply(multiply),
    .dvi_step(dvi_step)
);

terminal term_inst(
    .clk(clk),
    .reset(reset),
    .ac(ac),
    .device(device),
    .iop(iop),
    .ioskip(term_io_skip),
    .red(vgaRed),
    .green(vgaGreen),
    .blue(vgaBlue),
    .hsync(Hsync),
    .vsync(Vsync)
);

endmodule
