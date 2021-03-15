// Jim Geist jimg@knights.ucf.edu
//
// CPU testbench
//
`timescale 1ns / 1ps


module cpu_test();
localparam CLOCK = 10;
reg clk = 1;
always #5 clk = ~clk;

// front panel
reg reset = 0;
reg [11:0] sr = 0;
reg [1:0] dispsel = 0;
reg run = 0;
reg loadpc = 0;
reg loadac = 0;
reg step = 0;
reg deposit = 0;
wire [11:0] dispout;
wire linkout;
wire halt;
wire dispselmem;

// memory
wire mem_start_cpu;
wire mem_write_cpu;
wire [11:0] ma_cpu;
wire [11:0] mb_cpu;
wire [11:0] mem;
wire mem_done;

reg test_mem = 0;
reg mem_start_test = 0;
reg mem_write_test = 0;
reg [11:0] ma_test = 0;
reg [11:0] mb_test = 0;

wire mem_start;
wire mem_write;
wire [11:0] ma;
wire [11:0] mb;

assign mem_start = (test_mem == 0) ? mem_start_cpu : mem_start_test;
assign mem_write = (test_mem == 0) ? mem_write_cpu : mem_write_test;
assign ma = (test_mem == 0) ? ma_cpu : ma_test;
assign mb = (test_mem == 0) ? mb_cpu : mb_test;

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

// io bus
wire [5:0] device;
wire [2:0] iop;
wire term_io_skip;

initial
begin
    #CLOCK
    reset <= 1;
    #CLOCK
    reset <= 0;
    #CLOCK
    test_mem <= 1;
    ma_test <= 12'o0000;
    mb_test <= 12'o1111;
    mem_start_test <= 1;
    mem_write_test <= 1;
    #CLOCK
    mem_start_test <= 0;
    mem_write_test <= 0;
    #(CLOCK*3)
    test_mem <= 1;
    ma_test <= 12'o0001;
    mb_test <= 12'o7702;
    mem_start_test <= 1;
    mem_write_test <= 1;
    #CLOCK
    mem_start_test <= 0;
    mem_write_test <= 0;
    #(CLOCK*3)
    test_mem <= 1;
    ma_test <= 12'o0010;
    mb_test <= 12'o7702;
    mem_start_test <= 1;
    mem_write_test <= 1;
    #CLOCK
    mem_start_test <= 0;
    mem_write_test <= 0;
    #(CLOCK*3)
    test_mem <= 1;
    ma_test <= 12'o0100;
    mb_test <= 12'o0200;
    mem_start_test <= 1;
    mem_write_test <= 1;
    #CLOCK
    mem_start_test <= 0;
    mem_write_test <= 0;
    #(CLOCK*3)
    ma_test <= 12'o1111;
    mb_test <= 12'o2222;
    mem_start_test <= 1;
    mem_write_test <= 1;
    #CLOCK
    mem_start_test <= 0;
    mem_write_test <= 0;
    #(CLOCK*3)
    ma_test <= 12'o7701;
    mb_test <= 12'o1234;
    mem_start_test <= 1;
    mem_write_test <= 1;
    #CLOCK
    mem_start_test <= 0;
    mem_write_test <= 0;
    #(CLOCK*3)
    ma_test <= 12'o7702;
    mb_test <= 12'o7776;
    mem_start_test <= 1;
    mem_write_test <= 1;
    #CLOCK
    mem_start_test <= 0;
    mem_write_test <= 0;
    #(CLOCK*3)
    ma_test <= 12'o7756;
    mb_test <= 12'o7421; // MQL
    mem_start_test <= 1;
    mem_write_test <= 1;
    #CLOCK
    mem_start_test <= 0;
    mem_write_test <= 0;
    #(CLOCK*3)
    ma_test <= 12'o7757;
    mb_test <= 12'o1000; // TAD 0000
    mem_start_test <= 1;
    mem_write_test <= 1;
    #CLOCK
    mem_start_test <= 0;
    mem_write_test <= 0;
    #(CLOCK*3)
    ma_test <= 12'o7760;
    mb_test <= 12'o0301; // AND 7701 
    mem_start_test <= 1;
    mem_write_test <= 1;
    #CLOCK
    mem_start_test <= 0;
    mem_write_test <= 0;
    #(CLOCK*3)
    ma_test <= 12'o7761;
    mb_test <= 12'o2401; // ISZ I 0001 
    mem_start_test <= 1;
    mem_write_test <= 1;
    #CLOCK
    mem_start_test <= 0;
    mem_write_test <= 0;
    #(CLOCK*3)
    ma_test <= 12'o7762;
    mb_test <= 12'o2401; // ISZ I 0001 
    mem_start_test <= 1;
    mem_write_test <= 1;
    #CLOCK
    mem_start_test <= 0;
    mem_write_test <= 0;
    #(CLOCK*3)
    ma_test <= 12'o7764;
    mb_test <= 12'o3410; // DCA I 0010 
    mem_start_test <= 1;
    mem_write_test <= 1;
    #CLOCK
    mem_start_test <= 0;
    mem_write_test <= 0;
    #(CLOCK*3)
    ma_test <= 12'o7765;
    mb_test <= 12'o4200; // JMS 7600 
    mem_start_test <= 1;
    mem_write_test <= 1;
    #CLOCK
    mem_start_test <= 0;
    mem_write_test <= 0;
    #(CLOCK*3)
    ma_test <= 12'o7601;
    mb_test <= 12'o5600; // JMP I 7600 
    mem_start_test <= 1;
    mem_write_test <= 1;
    #CLOCK
    mem_start_test <= 0;
    mem_write_test <= 0;
    #(CLOCK*3)
    ma_test <= 12'o7766;
    mb_test <= 12'o7360; // CLA CLL CMA CML 
    mem_start_test <= 1;
    mem_write_test <= 1;
    #CLOCK
    mem_start_test <= 0;
    mem_write_test <= 0;
    #(CLOCK*3)
    ma_test <= 12'o7767;
    mb_test <= 12'o7327; // CLA CLL CML IAC RTL 
    mem_start_test <= 1;
    mem_write_test <= 1;
    #CLOCK
    mem_start_test <= 0;
    mem_write_test <= 0;
    #(CLOCK*3)
    ma_test <= 12'o7770;
    mb_test <= 12'o7200; // CLA 
    mem_start_test <= 1;
    mem_write_test <= 1;
    #CLOCK
    mem_start_test <= 0;
    mem_write_test <= 0;
    #(CLOCK*3)
    ma_test <= 12'o7771;
    mb_test <= 12'o7540; // SMA SZA 
    mem_start_test <= 1;
    mem_write_test <= 1;
    #CLOCK
    mem_start_test <= 0;
    mem_write_test <= 0;
    #(CLOCK*3)
    ma_test <= 12'o7773;
    mb_test <= 12'o5202; // JMP 7602 
    mem_start_test <= 1;
    mem_write_test <= 1;
    #CLOCK
    mem_start_test <= 0;
    mem_write_test <= 0;
    #(CLOCK*3)
    ma_test <= 12'o7602;
    mb_test <= 12'o7500; // SMA  
    mem_start_test <= 1;
    mem_write_test <= 1;
    #CLOCK
    mem_start_test <= 0;
    mem_write_test <= 0;
    #(CLOCK*3)
    ma_test <= 12'o7603;
    mb_test <= 12'o7530; // SPA SZL REV
    mem_start_test <= 1;
    mem_write_test <= 1;
    #CLOCK
    mem_start_test <= 0;
    mem_write_test <= 0;
    #(CLOCK*3)
    ma_test <= 12'o7605;
    mb_test <= 12'o7470; // SNA SZL REV
    mem_start_test <= 1;
    mem_write_test <= 1;
    #CLOCK
    mem_start_test <= 0;
    mem_write_test <= 0;
    #(CLOCK*3)
    ma_test <= 12'o7606;
    mb_test <= 12'o1000; // TAD 0000
    mem_start_test <= 1;
    mem_write_test <= 1;
    #CLOCK
    mem_start_test <= 0;
    mem_write_test <= 0;
    #(CLOCK*3)
    ma_test <= 12'o7607;
    mb_test <= 12'o7650; // CLA SNA 
    mem_start_test <= 1;
    mem_write_test <= 1;
    #CLOCK
    mem_start_test <= 0;
    mem_write_test <= 0;
    #(CLOCK*3)
    ma_test <= 12'o7611;
    mb_test <= 12'o7454; // SNA OSR
    mem_start_test <= 1;
    mem_write_test <= 1;
    #CLOCK
    mem_start_test <= 0;
    mem_write_test <= 0;
    #(CLOCK*3)
    ma_test <= 12'o7612;
    mb_test <= 12'o1000; // TAD 0000
    mem_start_test <= 1;
    mem_write_test <= 1;
    #CLOCK
    mem_start_test <= 0;
    mem_write_test <= 0;
    #(CLOCK*3)
    ma_test <= 12'o7613;
    mb_test <= 12'o7656; // SNA CLA OSR HLT
    mem_start_test <= 1;
    mem_write_test <= 1;
    #CLOCK
    mem_start_test <= 0;
    mem_write_test <= 0;
    #(CLOCK*3)
    ma_test <= 12'o7615;
    mb_test <= 12'o7320; // CLA CLL CML 
    mem_start_test <= 1;
    mem_write_test <= 1;
    #CLOCK
    mem_start_test <= 0;
    mem_write_test <= 0;
    #(CLOCK*3)
    ma_test <= 12'o7616;
    mb_test <= 12'o1000; // TAD 0000
    mem_start_test <= 1;
    mem_write_test <= 1;
    #CLOCK
    mem_start_test <= 0;
    mem_write_test <= 0;
    #(CLOCK*3)
    ma_test <= 12'o7617;
    mb_test <= 12'o7425; // MQA MUY 
    mem_start_test <= 1;
    mem_write_test <= 1;
    #CLOCK
    mem_start_test <= 0;
    mem_write_test <= 0;
    #(CLOCK*3)
    ma_test <= 12'o7620;
    mb_test <= 12'o0012; // 10 decimal 
    mem_start_test <= 1;
    mem_write_test <= 1;
    #CLOCK
    mem_start_test <= 0;
    mem_write_test <= 0;
    #(CLOCK*3)
    ma_test <= 12'o7621;
    mb_test <= 12'o7320; // CLA CLL CML 
    mem_start_test <= 1;
    mem_write_test <= 1;
    #CLOCK
    mem_start_test <= 0;
    mem_write_test <= 0;
    #(CLOCK*3)
    ma_test <= 12'o7622;
    mb_test <= 12'o1000; // TAD 0000
    mem_start_test <= 1;
    mem_write_test <= 1;
    #CLOCK
    mem_start_test <= 0;
    mem_write_test <= 0;
    #(CLOCK*3)
    ma_test <= 12'o7623;
    mb_test <= 12'o7421; // MQL 
    mem_start_test <= 1;
    mem_write_test <= 1;
    #CLOCK
    mem_start_test <= 0;
    mem_write_test <= 0;
    #(CLOCK*3)
    ma_test <= 12'o7624;
    mb_test <= 12'o7327; // CLA CLL CML IAC RTL 
    mem_start_test <= 1;
    mem_write_test <= 1;
    #CLOCK
    mem_start_test <= 0;
    mem_write_test <= 0;
    #(CLOCK*3)
    ma_test <= 12'o7625;
    mb_test <= 12'o7407; // DVI 
    mem_start_test <= 1;
    mem_write_test <= 1;
    #CLOCK
    mem_start_test <= 0;
    mem_write_test <= 0;
    #(CLOCK*3)
    ma_test <= 12'o7626;
    mb_test <= 12'o0011; // 9 decimal
    mem_start_test <= 1;
    mem_write_test <= 1;
    #CLOCK
    mem_start_test <= 0;
    mem_write_test <= 0;
    #(CLOCK*3)
    ma_test <= 12'o7627;
    mb_test <= 12'o7407; // DVI 
    mem_start_test <= 1;
    mem_write_test <= 1;
    #CLOCK
    mem_start_test <= 0;
    mem_write_test <= 0;
    #(CLOCK*3)
    ma_test <= 12'o7630;
    mb_test <= 12'o0006; // 6 decimal
    mem_start_test <= 1;
    mem_write_test <= 1;
    #CLOCK
    mem_start_test <= 0;
    mem_write_test <= 0;
    #(CLOCK*3)
    ma_test <= 12'o7631;
    mb_test <= 12'o6017; // IOT 01 7 
    mem_start_test <= 1;
    mem_write_test <= 1;
    #CLOCK
    mem_start_test <= 0;
    mem_write_test <= 0;
    #(CLOCK*3)
    ma_test <= 12'o7632;
    mb_test <= 12'o5500; // JMP I 0100 
    mem_start_test <= 1;
    mem_write_test <= 1;
    #CLOCK
    mem_start_test <= 0;
    mem_write_test <= 0;
    #(CLOCK*3)
    test_mem <= 0;
    
    
    dispsel <= 2'b11; // AC
    #CLOCK
    sr <= 12'o4321;
    loadac <= 1'b1;
    #CLOCK
    loadac <= 1'b0;
    #CLOCK
    if (dispout != 12'o4321) $display("loadac didn't work");
    #CLOCK
    dispsel <= 2'b00; // PC
    sr <= 12'o7756;
    loadpc <= 1'b1;
    #CLOCK
    loadpc <= 1'b0;
    #CLOCK
    if (dispout != 12'o7756) $display("loadpc didn't work");
    #CLOCK

    // MQL
    // Tests: instruction, fetch with no EA
    step <= 1'b1;
    #CLOCK
    step <= 1'b0;
    #(8*CLOCK)
    if (ac != 12'o0000) $finish(1);
    if (mq != 12'o4321) $finish(1);
    
    // TAD 0000 (zero page) 
    // Tests: instruction, fetch with value from zero page
    step <= 1'b1;
    #CLOCK
    step <= 1'b0;
    #(12*CLOCK)
    if (ac != 12'o1111) $finish(1);

    // AND 7701
    // Tests: instruction, fetch with value from current page
    step <= 1'b1;
    #CLOCK
    step <= 1'b0;
    #(13*CLOCK)
    if (ac != 12'o1010) $finish(1);  // 1234 AND 1111

    // ISZ I 0001 
    // Tests: instruction(no branch), indirect fetch
    step <= 1'b1;
    #CLOCK
    step <= 1'b0;
    #(21*CLOCK)
    if (pc != 12'o7762) $finish(1);
    
    #CLOCK
    test_mem <= 1;
    ma_test <= 12'o7702;
    #CLOCK
    mem_start_test <= 1;
    #CLOCK
    mem_start_test <= 0;
    #(3*CLOCK)
    if (mem != 12'o7777) $finish(1);
    test_mem <= 0;
    #CLOCK

    // ISZ I 0001 
    // Tests: instruction(branch), indirect fetch
    step <= 1'b1;
    #CLOCK
    step <= 1'b0;
    #(21*CLOCK)
    if (pc != 12'o7764) $finish(1);

    // DCA I 0010 
    // Tests: instruction, indirect autoincrement 
    step <= 1'b1;
    #CLOCK
    step <= 1'b0;
    #(20*CLOCK)
    if (ac != 12'o0000) $finish(1);

    #CLOCK
    test_mem <= 1;
    ma_test <= 12'o7703;
    #CLOCK
    mem_start_test <= 1;
    #CLOCK
    mem_start_test <= 0;
    #(3*CLOCK)
    if (mem != 12'o1010) $finish(1);
    test_mem <= 0;
    #CLOCK

    // 7765 JMS 7600 
    // Tests: instruction
    step <= 1'b1;
    #CLOCK
    step <= 1'b0;
    #(11*CLOCK)
    if (pc != 12'o7601) $finish(1);
    
    #CLOCK
    test_mem <= 1;
    ma_test <= 12'o7600;
    #CLOCK
    mem_start_test <= 1;
    #CLOCK
    mem_start_test <= 0;
    #(3*CLOCK)
    if (mem != 12'o7766) $finish(1);
    test_mem <= 0;
    #CLOCK

    // 7601 JMP I 7600 
    // Tests: instruction (this is the return from the JMS as well)
    step <= 1'b1;
    #CLOCK
    step <= 1'b0;
    #(11*CLOCK)
    if (pc != 12'o7766) $finish(1);

    // CLA CLL CMA CML 
    // Tests: instruction
    step <= 1'b1;
    #CLOCK
    step <= 1'b0;
    #(10*CLOCK)
    if (ac != 12'o7777) $finish(1);
    if (link != 1) $finish(1);

    // CLA CLL CML IAC R2L 
    // Tests: instruction
    step <= 1'b1;
    #CLOCK
    step <= 1'b0;
    #(10*CLOCK)
    if (ac != 12'o0006) $finish(1);
    if (link != 0) $finish(1);
    
    // CLA
    // Tests: instruction
    step <= 1'b1;
    #CLOCK
    step <= 1'b0;
    #(10*CLOCK)

    // 7771 SMA SZA 
    // Tests: instruction (positive skip)
    step <= 1'b1;
    #CLOCK
    step <= 1'b0;
    #(10*CLOCK)
    if (pc != 12'o7773) $finish(1);

    // 7773 JMP 7602  
    // Tests: nothing new, just running out of room
    step <= 1'b1;
    #CLOCK
    step <= 1'b0;
    #(7*CLOCK)

    // 7602 SMA  
    // Tests: instruction (positive no skip)
    step <= 1'b1;
    #CLOCK
    step <= 1'b0;
    #(10*CLOCK)
    if (pc != 12'o7603) $finish(1);

    // 7603 SPA SZL
    // Tests: instruction (negative skip)
    step <= 1'b1;
    #CLOCK
    step <= 1'b0;
    #(10*CLOCK)
    if (pc != 12'o7605) $finish(1);

    // 7605 SNA SZL
    // Tests: instruction (negative no skip)
    step <= 1'b1;
    #CLOCK
    step <= 1'b0;
    #(10*CLOCK)
    if (pc != 12'o7606) $finish(1);

    // 7606 TAD 1000
    // Tests: nothing new, setting up AC
    step <= 1'b1;
    #CLOCK
    step <= 1'b0;
    #(12*CLOCK)
    if (ac != 12'o1111) $finish(1);

    // 7607 CLA SNA 
    // Tests: clear AC happens AFTER skip
    step <= 1'b1;
    #CLOCK
    step <= 1'b0;
    #(10*CLOCK)
    if (ac != 12'o0000) $finish(1);
    if (pc != 12'o7611) $finish(1);

    // 7611 SNA OSR
    // Tests: OSR happens AFTER skip
    sr <= 12'o1234;
    #CLOCK
    step <= 1'b1;
    #CLOCK
    step <= 1'b0;
    #(10*CLOCK)
    if (ac != 12'o1234) $finish(1);
    if (pc != 12'o7612) $finish(1);

    // 7612 TAD 1000
    // Tests: nothing new, setting up AC
    step <= 1'b1;
    #CLOCK
    step <= 1'b0;
    #(12*CLOCK)
    if (ac != 12'o2345) $finish(1);

    // 7613 SNA CLA OSR HLT 
    // Tests: everything happens in right order 
    step <= 1'b1;
    #CLOCK
    step <= 1'b0;
    #(9*CLOCK)
    if (ac != 12'o1234) $finish(1);
    if (pc != 12'o7615) $finish(1);
    if (halt == 0) $finish(1);

    // 7615 CLA CLL CML 
    // Tests: instruction
    step <= 1'b1;
    #CLOCK
    step <= 1'b0;
    #(10*CLOCK)
    if (ac != 12'o0000) $finish(1);
    if (link != 1) $finish(1);

    // 7616 TAD 1000
    // Tests: nothing new, setting up AC
    step <= 1'b1;
    #CLOCK
    step <= 1'b0;
    #(12*CLOCK)
    if (ac != 12'o1111) $finish(1);
    if (link != 1) $finish(1);

    
    // 7617 MQL MUY
    // instruction 
    step <= 1'b1;
    #CLOCK
    step <= 1'b0;
    #(12*CLOCK)
    if (ac != 12'o0001) $finish(1);
    if (pc != 12'o7621) $finish(1);
    if (mq != 12'o3332) $finish(1);
    if (link != 0) $finish(1);

    // 7621 CLA CLL CML 
    // Tests: instruction
    step <= 1'b1;
    #CLOCK
    step <= 1'b0;
    #(10*CLOCK)
    if (ac != 12'o0000) $finish(1);
    if (link != 1) $finish(1);

    // 7622 TAD 1000
    // Tests: nothing new, setting up AC
    step <= 1'b1;
    #CLOCK
    step <= 1'b0;
    #(12*CLOCK)
    if (ac != 12'o1111) $finish(1);
    if (link != 1) $finish(1);

    // 7623 MQL
    // Tests: nothing new, setting up MQ 
    step <= 1'b1;
    #CLOCK
    step <= 1'b0;
    #(12*CLOCK)
    if (ac != 12'o0000) $finish(1);
    if (mq != 12'o1111) $finish(1);

    // 7624 CLA CLL CML IAC R2L 
    // Tests: nothing new, setting up AC
    step <= 1'b1;
    #CLOCK
    step <= 1'b0;
    #(10*CLOCK)
    if (ac != 12'o0006) $finish(1);
    if (link != 0) $finish(1);
    
    // 7625 DVI 
    // Tests: instruction
    step <= 1'b1;
    #CLOCK
    step <= 1'b0;
    #(36*CLOCK)
    if (ac != 12'o0006) $finish(1);
    if (mq != 12'o5353) $finish(1);
    if (link != 0) $finish(1);
    
    // 7627 DVI 
    // Tests: instruction with overflow
    step <= 1'b1;
    #CLOCK
    step <= 1'b0;
    #(12*CLOCK)
    if (link != 1) $finish(1);
    
    // 7631 IOT 01 7 
    // Tests: instruction
    step <= 1'b1;
    #CLOCK
    step <= 1'b0;
    #(6*CLOCK)
    if (device != 6'o01) $finish(1);
    if (iop != 3'o1) $finish(1);
    #CLOCK
    if (device != 6'o01) $finish(1);
    if (iop != 3'o2) $finish(1);
    #CLOCK
    if (device != 6'o01) $finish(1);
    if (iop != 3'o4) $finish(1);
    #CLOCK
    
    // 7632 JMP I 0100
    step <= 1'b1;
    #CLOCK
    step <= 1'b0;
    #(11*CLOCK)
    if (pc != 12'o0200) $finish(1);
    $stop();

    run <= 1;

end

always @(*) if (halt) $stop();

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
    .ma(ma_cpu),
    .mb(mb_cpu),
    .mem(mem),
    .ea(ea),
    .sc(sc),
    .acmq(acmq),
    .mem_start(mem_start_cpu),
    .mem_write(mem_write_cpu),
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
    .reset(reset),
    .sr(sr),
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
    .ma(ma_cpu),
    .mb(mb_cpu),
    .mem(mem),

    // registers
    .pc(pc),
    .ac(ac),
    .link(link),
    .ea(ea),
    .ir(ir),
    .mq(mq),
    .pg(pg),
    .sc(sc),
    .acmq(acmq),

    // state
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
    .ac(ac),
    .device(device),
    .iop(iop),
    .ioskip(term_io_skip)
);
endmodule
