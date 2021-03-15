// Jim Geist jimg@knights.ucf.edu
//
// PDP-8 CPU state machine.
//
// This is the state machine for the front panel and the CPU. It
// generates the proper signals at the proper times to move and
// operate on data in registers and memory, as well as the I/O
// bus.
//
module cpu_state(
    input clk,
    input reset,
    input run,
    input loadac,
    input loadpc,
    input step,
    input deposit,
    input dispselmem,
    input mem_done,
    input [11:0] ac,
    input link,
    input [11:0] sr,
    input [11:0] ir,
    input [11:0] ma,
    input [11:0] mb,
    input [11:0] ea,
    input [11:0] mem,
    input [23:0] acmq,
    input [4:0] sc,
    output mem_start,
    output mem_write,
    output ac_from_sr,
    output clear_ac,
    output com_ac,
    output inc_ac,
    output ral_lac,
    output rar_lac,
    output rot2,
    output ac_from_ac_plus_mem,
    output ac_from_ac_and_mem,
    output ac_from_ac_or_sr,
    output ac_from_ac_or_mq,
    output ac_from_mq,
    output clear_l,
    output set_l,
    output com_l,
    output pc_from_sr,
    output pc_from_ea,
    output pc_from_ea_plus_one,
    output inc_pc,
    output ma_from_pc,
    output ma_from_sr,
    output ma_from_ea,
    output ma_from_mem_page,
    output mb_from_sr,
    output mb_from_mem_plus_one,
    output mb_from_ac,
    output mb_from_pc,
    output mq_from_ac,
    output clear_mq,
    output ir_from_mem,
    output pg_from_pc,
    output ea_from_mem_page,
    output ea_from_mem,
    output ea_from_mb,
    output inc_ea,
    output clear_sc,
    output inc_sc,
    output acmq_from_ac_mq,
    output multiply,
    output dvi_step,
    output halt_cpu,
    output clear_halt,
    output [5:0] device,
    output [2:0] iop
);

localparam [4:0] I0 =  5'b00000, // idle
                 P0R = 5'b00001, // front panel
                 P0W = 5'b00010,
                 P1R = 5'b00011,
                 P1W = 5'b00100,

                 F0  = 5'b00101, // fetch
                 F1  = 5'b00110,
                 F2  = 5'b00111,
                 F3  = 5'b01000,
                 F4  = 5'b01001,
                 F5  = 5'b01010,
                 F6  = 5'b01011,
                 F7  = 5'b01100,
                 F8  = 5'b01101,
                 F9  = 5'b01110,
                 F10 = 5'b01111,

                 E0  = 5'b10000, // execute
                 E1  = 5'b10001,
                 E2  = 5'b10010,
                 E3  = 5'b10011,
                 E4  = 5'b10100;


reg [11:0] sr_last = 12'o000;
reg dispselmem_last = 0;
reg [4:0] state_reg = I0;
reg [4:0] state_next = I0;
reg upddisp_reg = 0;
reg upddisp_next = 0;


always @(posedge clk)
begin
    if (reset)
    begin
        state_reg <= I0;
        sr_last <= 0;
        dispselmem_last <= 0;
        upddisp_reg = 0;
    end
    else
    begin
        state_reg <= state_next;
        sr_last <= sr;
        dispselmem_last <= dispselmem;
        upddisp_reg <= upddisp_next;
    end
end

wire update_memdisp;
assign update_memdisp =
  dispselmem == 1 &&
  (dispselmem_last == 0 || sr != sr_last || upddisp_reg) &&
  loadac == 0 && loadpc == 0 && deposit == 0 &&
  run == 0 && step == 0;

wire running, not_running;
assign running = run == 1 || step == 1;
assign not_running = run == 0 && step == 0;

wire I0_HLT, ir_AND, ir_TAD, ir_ISZ, ir_DCA, ir_JMS, ir_JMP, ir_IOT, ir_OPR, ir_IND;
assign I0_HLT = (state_reg == I0) && not_running;
assign ir_AND = ir[11:9] == 3'b000;
assign ir_TAD = ir[11:9] == 3'b001;
assign ir_ISZ = ir[11:9] == 3'b010;
assign ir_DCA = ir[11:9] == 3'b011;
assign ir_JMS = ir[11:9] == 3'b100;
assign ir_JMP = ir[11:9] == 3'b101;
assign ir_IOT = ir[11:9] == 3'b110;
assign ir_OPR = ir[11:9] == 3'b111;
assign ir_IND = ir[8]    == 1'b1;

wire op_needs_val, op_needs_ea;

// opcodes which need value as well as ea
assign op_needs_val = ir_AND || ir_TAD || ir_ISZ;
// opcodes which need ea
assign op_needs_ea  = op_needs_val || ir_DCA || ir_JMS || ir_JMP;

wire ir_OPR_GROUP_1, ir_OPR_GROUP_2, ir_OPR_GROUP_3;
assign ir_OPR_GROUP_1 = (ir & 12'o7400) == 12'o7000;
assign ir_OPR_GROUP_2 = (ir & 12'o7401) == 12'o7400;
assign ir_OPR_GROUP_3 = (ir & 12'o7401) == 12'o7401; // EAE

wire ir_CLA;
assign ir_CLA = (ir & 12'o0200) == 12'o0200; // common

wire ir_CLL, ir_CMA, ir_CML, ir_RAR, ir_RAL, ir_RT, ir_IAC;
wire ir_SMA, ir_SZA, ir_SNL, ir_REV, ir_OSR, ir_HLT;
wire ir_MQA, ir_SCA, ir_MQL, ir_SCL;
wire ir_MUY, ir_DVI, ir_NMI, ir_SHL, ir_ASR, ir_LSR;

// group1
// TODO here and below these really should be full IR decodings
assign ir_CLL = (ir & 12'o0100) == 12'o0100;
assign ir_CMA = (ir & 12'o0040) == 12'o0040;
assign ir_CML = (ir & 12'o0020) == 12'o0020;
assign ir_RAR = (ir & 12'o0010) == 12'o0010;
assign ir_RAL = (ir & 12'o0004) == 12'o0004;
assign ir_RT  = (ir & 12'o0002) == 12'o0002;
assign ir_IAC = (ir & 12'o0001) == 12'o0001;
// group2
assign ir_SMA = (ir & 12'o0100) == 12'o0100;
assign ir_SZA = (ir & 12'o0040) == 12'o0040;
assign ir_SNL = (ir & 12'o0020) == 12'o0020;
assign ir_REV = (ir & 12'o0010) == 12'o0010;
assign ir_OSR = (ir & 12'o0004) == 12'o0004;
assign ir_HLT = (ir & 12'o0002) == 12'o0002;
// group3 - EAE
assign ir_MQA = (ir & 12'o0100) == 12'o0100;
assign ir_SCA = (ir & 12'o0040) == 12'o0040;
assign ir_MQL = (ir & 12'o0020) == 12'o0020;
assign ir_SCL = (ir & 12'o0016) == 12'o0002;
assign ir_MUY = (ir & 12'o0016) == 12'o0004;
assign ir_DVI = (ir & 12'o0016) == 12'o0006;
assign ir_NMI = (ir & 12'o0016) == 12'o0010;
assign ir_SHL = (ir & 12'o0016) == 12'o0012;
assign ir_ASR = (ir & 12'o0016) == 12'o0014;
assign ir_LSR = (ir & 12'o0016) == 12'o0016;

wire E0_AND, E0_TAD, E0_ISZ, E1_ISZ, E3_ISZ, E0_DCA, E1_DCA, E0_JMS, E1_JMS, E0_JMP;

assign E0_AND = (state_reg == E0) && ir_AND;
assign E0_TAD = (state_reg == E0) && ir_TAD;
assign E0_ISZ = (state_reg == E0) && ir_ISZ;
assign E1_ISZ = (state_reg == E1) && ir_ISZ;
assign E3_ISZ = (state_reg == E3) && ir_ISZ;
assign E0_DCA = (state_reg == E0) && ir_DCA;
assign E1_DCA = (state_reg == E1) && ir_DCA;
assign E0_JMS = (state_reg == E0) && ir_JMS;
assign E1_JMS = (state_reg == E1) && ir_JMS;
assign E0_JMP = (state_reg == E0) && ir_JMP;

wire E0_OPR1, E1_OPR1, E2_OPR1, E3_OPR1, E0_OPR2, E1_OPR2, E2_OPR2, E0_OPR3;
wire E1_OPR3, E2_OPR3, E3_OPR3, E4_OPR3;

assign E0_OPR1= (state_reg == E0) && ir_OPR_GROUP_1;
assign E1_OPR1= (state_reg == E1) && ir_OPR_GROUP_1;
assign E2_OPR1= (state_reg == E2) && ir_OPR_GROUP_1;
assign E3_OPR1= (state_reg == E3) && ir_OPR_GROUP_1;
assign E0_OPR2= (state_reg == E0) && ir_OPR_GROUP_2;
assign E1_OPR2= (state_reg == E1) && ir_OPR_GROUP_2;
assign E2_OPR2= (state_reg == E2) && ir_OPR_GROUP_2;
assign E0_OPR3= (state_reg == E0) && ir_OPR_GROUP_3;
assign E1_OPR3= (state_reg == E1) && ir_OPR_GROUP_3;
assign E2_OPR3= (state_reg == E2) && ir_OPR_GROUP_3;
assign E3_OPR3= (state_reg == E3) && ir_OPR_GROUP_3;
assign E4_OPR3= (state_reg == E4) && ir_OPR_GROUP_3;

wire E0_MUY, E1_MUY, E3_MUY, E0_DVI, E1_DVI, E2_DVI, E3_DVI, E4_DVI;

assign E0_MUY = E0_OPR3 && ir_MUY;
assign E1_MUY = E1_OPR3 && ir_MUY;
assign E3_MUY = E3_OPR3 && ir_MUY;
assign E0_DVI = E0_OPR3 && ir_DVI;
assign E1_DVI = E1_OPR3 && ir_DVI;
assign E2_DVI = E2_OPR3 && ir_DVI;
assign E3_DVI = E3_OPR3 && ir_DVI;
assign E4_DVI = E4_OPR3 && ir_DVI;

wire E1_NOP3;

assign E1_NOP3= E1_OPR3 && ~ir_MUY && ~ir_DVI;

// skips
wire [2:0] skips, opr_skip;

assign skips[0] = ir_SMA ? ((ac & 12'o4000) != 0) : 0;
assign skips[1] = ir_SZA ? (ac == 0) : 0;
assign skips[2] = ir_SNL ? (link != 0) : 0;
assign opr_skip = ir_REV ? (skips == 0) : (skips != 0);

// IOT
wire IOP1, IOP2, IOP4, E0_IOT, E1_IOT, E2_IOT;

assign IOP1 = (ir & 12'o6001) == 12'o6001;
assign IOP2 = (ir & 12'o6002) == 12'o6002;
assign IOP4 = (ir & 12'o6004) == 12'o6004;

assign E0_IOT = (state_reg == E0) && ir_IOT;
assign E1_IOT = (state_reg == E1) && ir_IOT;
assign E2_IOT = (state_reg == E2) && ir_IOT;

assign ac_from_sr = I0_HLT && loadac;
assign clear_ac =
   E0_DCA ||
  (E0_OPR1 && ir_CLA) ||
  (E1_OPR2 && ir_CLA) ||
  (E0_OPR3 && ir_CLA && ~ir_MQL) ||
  (E1_OPR3 && ir_MQL && ~ir_MQA) ||
   E3_DVI;

assign com_ac = E1_OPR1 && ir_CMA;
assign inc_ac = E2_OPR1 && ir_IAC;
assign ac_from_ac_and_mem = E0_AND;
assign ac_from_ac_or_sr = E2_OPR2 && ir_OSR;
assign ac_from_ac_or_mq = E1_OPR3 && ir_MQA && ~ir_MQL;
assign ac_from_mq = E1_OPR3 && ir_MQA && ir_MQL;

assign clear_l =
    (E0_OPR1 && ir_CLL) ||
    E3_MUY ||
    (E3_DVI && (ac < mem));

assign set_l = E3_DVI && (ac >= mem);

assign com_l = E1_OPR1 && ir_CML;

// NB these signals act on both AC and L together
assign ac_from_ac_plus_mem = E0_TAD;
assign ral_lac = E3_OPR1 && ir_RAL;
assign rar_lac = E3_OPR1 && ir_RAR;
assign rot2    = E3_OPR1 && ir_RT;

assign pc_from_sr = I0_HLT && loadpc;
assign pc_from_ea = E0_JMP;
assign pc_from_ea_plus_one = E0_JMS;

assign inc_pc =
    (I0_HLT && deposit) ||
    (state_reg == F0) ||
    (E3_ISZ && mb == 0) ||
    (E0_OPR2 && opr_skip) ||
    E0_MUY ||
    E0_DVI;

assign ma_from_pc =
    (I0_HLT && deposit) ||
    ((state_reg == I0) && running) ||
    E0_MUY ||
    E0_DVI;

assign ma_from_sr = I0_HLT && update_memdisp;
assign ma_from_ea =
    state_reg == F8 ||
    E0_ISZ ||
    E0_DCA ||
    E0_JMS;
assign ma_from_mem_page = state_reg == F1;

assign mb_from_sr = I0_HLT && deposit;
assign mb_from_mem_plus_one =
    E0_ISZ ||
    state_reg == F5;
assign mb_from_ac = E0_DCA;
assign mb_from_pc = E0_JMS;

assign mq_from_ac = E1_OPR3 && ir_MQL;
assign clear_mq = E3_DVI;

assign clear_halt = state_reg == I0;
assign halt_cpu = E2_OPR2 && ir_HLT;


assign mem_write =
    state_reg == P0W ||
    E1_ISZ ||
    E1_DCA ||
    E1_JMS ||
    state_reg == F6;

assign mem_start =
    state_reg == P0R ||
    state_reg == P0W ||
    state_reg == F0 ||
    state_reg == F3 ||
    state_reg == F6 ||
    state_reg == F9 ||
    E1_ISZ ||
    E1_DCA ||
    E1_JMS ||
    E1_MUY ||
    E1_DVI;

assign ir_from_mem = state_reg == F1;
assign pg_from_pc = state_reg == F0;

assign ea_from_mem_page = state_reg == F1;
assign ea_from_mem = state_reg == F4;
assign inc_ea = state_reg == F5;

assign clear_sc = E3_DVI;
assign inc_sc = E4_DVI;

assign acmq_from_ac_mq = E3_DVI;

assign multiply = E3_MUY;
assign dvi_step = E4_DVI;

assign device = ir[8:3];
assign iop[0] = E0_IOT && IOP1;
assign iop[1] = E1_IOT && IOP2;
assign iop[2] = E2_IOT && IOP4;

always @(*)
begin
    state_next = state_reg;
    upddisp_next = upddisp_reg;

    case (state_reg)
    I0: // idle state
        begin
            if (running) state_next = F0;
            upddisp_next = 0;
            if (update_memdisp) state_next = P0R;
            else if (deposit) state_next = P0W;
        end

    P0R: // front panel read cycle
        state_next = P1R;

    P1R: // front panel read wait
        if (mem_done) state_next = I0;

    P0W: // front panel write cycle
        state_next = P1W;

    P1W: // front panel write wait
        if (mem_done)
        begin
            state_next = I0;
            upddisp_next = 1;
        end

    F0:
        state_next = F1;

    F1:
        if (mem_done) state_next = F2;

    F2:
        if (!op_needs_ea) state_next = E0;
        else if (!ir_IND && !op_needs_val) state_next = E0;
        else if (!ir_IND && op_needs_val) state_next = F8;
        else state_next = F3;

    F3:
        state_next = F4;

    F4:
        if (mem_done)
        begin
            if (ma >= 12'o0010 && ma <= 12'o0017) state_next = F5;
            else if (!op_needs_val) state_next = E0;
            else state_next = F8;
        end

    F5:
        state_next = F6;

    F6:
        state_next = F7;

    F7:
        if (mem_done)
        begin
            if (!op_needs_val) state_next = E0;
            else state_next = F8;
        end

    F8:
        state_next = F9;

    F9:
        state_next = F10;

    F10:
        if (mem_done) state_next = E0;

    E0:
        if (ir_ISZ || ir_DCA || ir_JMS || ir_IOT || ir_OPR) state_next = E1;
        else state_next = I0;

    E1:
        if (E1_NOP3) state_next = I0;
        else state_next = E2;

    E2:
        if (ir_OPR_GROUP_1) state_next = E3;
        else if (ir_OPR_GROUP_2 || ir_IOT) state_next = I0;
        else if (mem_done)
        begin
            if (ir_DCA || ir_JMS) state_next = I0;
            else state_next = E3;
        end

    E3:
        if (E3_DVI) 
        begin
            if (ac < mem) state_next <= E4;
            else state_next <= I0; // divide overflow
        end
        else state_next <= I0;

    E4:
        if (sc == 23) state_next <= I0;

    default:
        state_next <= I0;

    endcase
end

endmodule
