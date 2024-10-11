// ======================================================================
// ComponentTest.v generated from TopDesign.cysch
// 11/18/2019 at 07:11
// This file is auto generated. ANY EDITS YOU MAKE MAY BE LOST WHEN THIS FILE IS REGENERATED!!!
// ======================================================================

/* -- WARNING: The following section of defines are deprecated and will be removed in a future release -- */
`define CYDEV_CHIP_DIE_LEOPARD 1
`define CYDEV_CHIP_REV_LEOPARD_PRODUCTION 3
`define CYDEV_CHIP_REV_LEOPARD_ES3 3
`define CYDEV_CHIP_REV_LEOPARD_ES2 1
`define CYDEV_CHIP_REV_LEOPARD_ES1 0
`define CYDEV_CHIP_DIE_PSOC5LP 2
`define CYDEV_CHIP_REV_PSOC5LP_PRODUCTION 0
`define CYDEV_CHIP_REV_PSOC5LP_ES0 0
`define CYDEV_CHIP_DIE_PSOC5TM 3
`define CYDEV_CHIP_REV_PSOC5TM_PRODUCTION 1
`define CYDEV_CHIP_REV_PSOC5TM_ES1 1
`define CYDEV_CHIP_REV_PSOC5TM_ES0 0
`define CYDEV_CHIP_DIE_TMA4 4
`define CYDEV_CHIP_REV_TMA4_PRODUCTION 17
`define CYDEV_CHIP_REV_TMA4_ES 17
`define CYDEV_CHIP_REV_TMA4_ES2 33
`define CYDEV_CHIP_DIE_PSOC4A 5
`define CYDEV_CHIP_REV_PSOC4A_PRODUCTION 17
`define CYDEV_CHIP_REV_PSOC4A_ES0 17
`define CYDEV_CHIP_DIE_PSOC6ABLE2 6
`define CYDEV_CHIP_REV_PSOC6ABLE2_ES 17
`define CYDEV_CHIP_REV_PSOC6ABLE2_PRODUCTION 33
`define CYDEV_CHIP_REV_PSOC6ABLE2_NO_UDB 33
`define CYDEV_CHIP_DIE_VOLANS 7
`define CYDEV_CHIP_REV_VOLANS_PRODUCTION 0
`define CYDEV_CHIP_DIE_BERRYPECKER 8
`define CYDEV_CHIP_REV_BERRYPECKER_PRODUCTION 0
`define CYDEV_CHIP_DIE_CRANE 9
`define CYDEV_CHIP_REV_CRANE_PRODUCTION 0
`define CYDEV_CHIP_DIE_FM3 10
`define CYDEV_CHIP_REV_FM3_PRODUCTION 0
`define CYDEV_CHIP_DIE_FM4 11
`define CYDEV_CHIP_REV_FM4_PRODUCTION 0
`define CYDEV_CHIP_DIE_EXPECT 2
`define CYDEV_CHIP_REV_EXPECT 0
`define CYDEV_CHIP_DIE_ACTUAL 2
/* -- WARNING: The previous section of defines are deprecated and will be removed in a future release -- */
`define CYDEV_CHIP_FAMILY_PSOC3 1
`define CYDEV_CHIP_FAMILY_PSOC4 2
`define CYDEV_CHIP_FAMILY_PSOC5 3
`define CYDEV_CHIP_FAMILY_PSOC6 4
`define CYDEV_CHIP_FAMILY_FM0P 5
`define CYDEV_CHIP_FAMILY_FM3 6
`define CYDEV_CHIP_FAMILY_FM4 7
`define CYDEV_CHIP_FAMILY_UNKNOWN 0
`define CYDEV_CHIP_MEMBER_UNKNOWN 0
`define CYDEV_CHIP_MEMBER_3A 1
`define CYDEV_CHIP_REVISION_3A_PRODUCTION 3
`define CYDEV_CHIP_REVISION_3A_ES3 3
`define CYDEV_CHIP_REVISION_3A_ES2 1
`define CYDEV_CHIP_REVISION_3A_ES1 0
`define CYDEV_CHIP_MEMBER_5B 2
`define CYDEV_CHIP_REVISION_5B_PRODUCTION 0
`define CYDEV_CHIP_REVISION_5B_ES0 0
`define CYDEV_CHIP_MEMBER_5A 3
`define CYDEV_CHIP_REVISION_5A_PRODUCTION 1
`define CYDEV_CHIP_REVISION_5A_ES1 1
`define CYDEV_CHIP_REVISION_5A_ES0 0
`define CYDEV_CHIP_MEMBER_4G 4
`define CYDEV_CHIP_REVISION_4G_PRODUCTION 17
`define CYDEV_CHIP_REVISION_4G_ES 17
`define CYDEV_CHIP_REVISION_4G_ES2 33
`define CYDEV_CHIP_MEMBER_4U 5
`define CYDEV_CHIP_REVISION_4U_PRODUCTION 0
`define CYDEV_CHIP_MEMBER_4E 6
`define CYDEV_CHIP_REVISION_4E_PRODUCTION 0
`define CYDEV_CHIP_REVISION_4E_CCG2_NO_USBPD 0
`define CYDEV_CHIP_MEMBER_4O 7
`define CYDEV_CHIP_REVISION_4O_PRODUCTION 0
`define CYDEV_CHIP_MEMBER_4R 8
`define CYDEV_CHIP_REVISION_4R_PRODUCTION 0
`define CYDEV_CHIP_MEMBER_4T 9
`define CYDEV_CHIP_REVISION_4T_PRODUCTION 0
`define CYDEV_CHIP_MEMBER_4N 10
`define CYDEV_CHIP_REVISION_4N_PRODUCTION 0
`define CYDEV_CHIP_MEMBER_4S 11
`define CYDEV_CHIP_REVISION_4S_PRODUCTION 0
`define CYDEV_CHIP_MEMBER_4Q 12
`define CYDEV_CHIP_REVISION_4Q_PRODUCTION 0
`define CYDEV_CHIP_MEMBER_4D 13
`define CYDEV_CHIP_REVISION_4D_PRODUCTION 0
`define CYDEV_CHIP_MEMBER_4J 14
`define CYDEV_CHIP_REVISION_4J_PRODUCTION 0
`define CYDEV_CHIP_MEMBER_4K 15
`define CYDEV_CHIP_REVISION_4K_PRODUCTION 0
`define CYDEV_CHIP_MEMBER_4V 16
`define CYDEV_CHIP_REVISION_4V_PRODUCTION 0
`define CYDEV_CHIP_MEMBER_4H 17
`define CYDEV_CHIP_REVISION_4H_PRODUCTION 0
`define CYDEV_CHIP_MEMBER_4A 18
`define CYDEV_CHIP_REVISION_4A_PRODUCTION 17
`define CYDEV_CHIP_REVISION_4A_ES0 17
`define CYDEV_CHIP_MEMBER_4F 19
`define CYDEV_CHIP_REVISION_4F_PRODUCTION 0
`define CYDEV_CHIP_REVISION_4F_PRODUCTION_256K 0
`define CYDEV_CHIP_REVISION_4F_PRODUCTION_256DMA 0
`define CYDEV_CHIP_MEMBER_4P 20
`define CYDEV_CHIP_REVISION_4P_PRODUCTION 0
`define CYDEV_CHIP_MEMBER_4M 21
`define CYDEV_CHIP_REVISION_4M_PRODUCTION 0
`define CYDEV_CHIP_MEMBER_4L 22
`define CYDEV_CHIP_REVISION_4L_PRODUCTION 0
`define CYDEV_CHIP_MEMBER_4I 23
`define CYDEV_CHIP_REVISION_4I_PRODUCTION 0
`define CYDEV_CHIP_MEMBER_6A 24
`define CYDEV_CHIP_REVISION_6A_ES 17
`define CYDEV_CHIP_REVISION_6A_PRODUCTION 33
`define CYDEV_CHIP_REVISION_6A_NO_UDB 33
`define CYDEV_CHIP_MEMBER_PDL_FM0P_TYPE1 25
`define CYDEV_CHIP_REVISION_PDL_FM0P_TYPE1_PRODUCTION 0
`define CYDEV_CHIP_MEMBER_PDL_FM0P_TYPE2 26
`define CYDEV_CHIP_REVISION_PDL_FM0P_TYPE2_PRODUCTION 0
`define CYDEV_CHIP_MEMBER_PDL_FM0P_TYPE3 27
`define CYDEV_CHIP_REVISION_PDL_FM0P_TYPE3_PRODUCTION 0
`define CYDEV_CHIP_MEMBER_FM3 28
`define CYDEV_CHIP_REVISION_FM3_PRODUCTION 0
`define CYDEV_CHIP_MEMBER_FM4 29
`define CYDEV_CHIP_REVISION_FM4_PRODUCTION 0
`define CYDEV_CHIP_FAMILY_USED 3
`define CYDEV_CHIP_MEMBER_USED 2
`define CYDEV_CHIP_REVISION_USED 0
`include "cypress.v"
/* ==================== Include Component Definitions ==================== */

// Component: Count7_v1_0
`ifdef CY_BLK_DIR
`undef CY_BLK_DIR
`endif

`ifdef WARP
`define CY_BLK_DIR "C:\Program Files (x86)\Cypress\PSoC Creator\4.2\PSoC Creator\psoc\content\CyComponentLibrary\CyComponentLibrary.cylib\Count7_v1_0"
`include "C:\Program Files (x86)\Cypress\PSoC Creator\4.2\PSoC Creator\psoc\content\CyComponentLibrary\CyComponentLibrary.cylib\Count7_v1_0\Count7_v1_0.v"
`else
`define CY_BLK_DIR "C:\Program Files (x86)\Cypress\PSoC Creator\4.2\PSoC Creator\psoc\content\CyComponentLibrary\CyComponentLibrary.cylib\Count7_v1_0"
`include "C:\Program Files (x86)\Cypress\PSoC Creator\4.2\PSoC Creator\psoc\content\CyComponentLibrary\CyComponentLibrary.cylib\Count7_v1_0\Count7_v1_0.v"
`endif

module NSDSPI_UDB_BLOCK (
    input wire clock, 
    input wire MISO, 
    input wire RX_FreeRun, 
    output wire MOSI, 
    output wire SCLK, 
    output wire RXDMA, 
    output wire TXDMA, 
    output wire BYTE_STROBE
);

/* ==================== Wire and Register Declarations ==================== */
localparam [2:0] Idle = 3'b000;
localparam [2:0] LoadTxDat = 3'b001;
localparam [2:0] Load0xFF = 3'b010;
localparam [2:0] Sending = 3'b011;
localparam [2:0] LoadTxDat_1 = 3'b101;
localparam [2:0] Load0xFF_1 = 3'b110;
wire EnableCounter;
wire LoadCounter;
wire NoTXData;
wire SpaceForData;
wire RxDataWaiting;
wire Internal_MOSI;
wire SPI_DPTH_d0_load;
wire SPI_DPTH_d1_load;
wire SPI_DPTH_f0_load;
wire SPI_DPTH_f1_load;
wire SPI_DPTH_route_si;
wire SPI_DPTH_route_ci;
wire  [2:0] SPI_DPTH_select;
wire BIT_COUNTER_en;
wire BIT_COUNTER_load;
wire BIT_COUNTER_reset;
wire  [6:0] BIT_COUNTER_count;
wire FinalBit;
reg  [2:0] SPIStates;

/* ==================== Assignment of Combinatorial Variables ==================== */
assign MOSI = (Internal_MOSI);
assign SCLK = ((SPIStates == Sending) & !clock);
assign RXDMA = (RxDataWaiting);
assign TXDMA = (SpaceForData);
assign BYTE_STROBE = (FinalBit);
assign EnableCounter = (LoadCounter | (SPIStates == Sending));
assign LoadCounter = (SPIStates[0] ^ SPIStates[1]);
assign SPI_DPTH_d0_load = (1'b0);
assign SPI_DPTH_d1_load = (1'b0);
assign SPI_DPTH_f0_load = (1'b0);
assign SPI_DPTH_f1_load = (FinalBit);
assign SPI_DPTH_route_si = (MISO);
assign SPI_DPTH_route_ci = (1'b0);
assign SPI_DPTH_select[0] = (SPIStates[0]);
assign SPI_DPTH_select[1] = (SPIStates[1]);
assign SPI_DPTH_select[2] = (1'b0);
assign BIT_COUNTER_en = (EnableCounter);
assign BIT_COUNTER_load = (LoadCounter);
assign BIT_COUNTER_reset = (1'b0);

/* ==================== SPI_DPTH (Width: 8) Instantiation ==================== */
parameter SPI_DPTH_dpconfig0 = 
{
    `CS_ALU_OP_PASS, `CS_SRCA_A0, `CS_SRCB_D0, `CS_SHFT_OP_PASS, `CS_A0_SRC_NONE, `CS_A1_SRC_NONE, `CS_FEEDBACK_DSBL, `CS_CI_SEL_CFGA, `CS_SI_SEL_CFGA, `CS_CMP_SEL_CFGA,  /*CFGRAM0:  */
    `CS_ALU_OP_PASS, `CS_SRCA_A0, `CS_SRCB_D0, `CS_SHFT_OP_PASS, `CS_A0_SRC___F0, `CS_A1_SRC_NONE, `CS_FEEDBACK_DSBL, `CS_CI_SEL_CFGA, `CS_SI_SEL_CFGA, `CS_CMP_SEL_CFGA,  /*CFGRAM1: Load TX Data */
    `CS_ALU_OP_PASS, `CS_SRCA_A0, `CS_SRCB_D0, `CS_SHFT_OP_PASS, `CS_A0_SRC___D0, `CS_A1_SRC_NONE, `CS_FEEDBACK_DSBL, `CS_CI_SEL_CFGA, `CS_SI_SEL_CFGA, `CS_CMP_SEL_CFGA,  /*CFGRAM2: Load 0xFF */
    `CS_ALU_OP_PASS, `CS_SRCA_A0, `CS_SRCB_D0, `CS_SHFT_OP___SL, `CS_A0_SRC__ALU, `CS_A1_SRC_NONE, `CS_FEEDBACK_DSBL, `CS_CI_SEL_CFGA, `CS_SI_SEL_CFGA, `CS_CMP_SEL_CFGA,  /*CFGRAM3: ShiftBits */
    `CS_ALU_OP_PASS, `CS_SRCA_A0, `CS_SRCB_D0, `CS_SHFT_OP_PASS, `CS_A0_SRC_NONE, `CS_A1_SRC_NONE, `CS_FEEDBACK_DSBL, `CS_CI_SEL_CFGA, `CS_SI_SEL_CFGA, `CS_CMP_SEL_CFGA,  /*CFGRAM4:  */
    `CS_ALU_OP_PASS, `CS_SRCA_A0, `CS_SRCB_D0, `CS_SHFT_OP_PASS, `CS_A0_SRC_NONE, `CS_A1_SRC_NONE, `CS_FEEDBACK_DSBL, `CS_CI_SEL_CFGA, `CS_SI_SEL_CFGA, `CS_CMP_SEL_CFGA,  /*CFGRAM5:  */
    `CS_ALU_OP_PASS, `CS_SRCA_A0, `CS_SRCB_D0, `CS_SHFT_OP_PASS, `CS_A0_SRC_NONE, `CS_A1_SRC_NONE, `CS_FEEDBACK_DSBL, `CS_CI_SEL_CFGA, `CS_SI_SEL_CFGA, `CS_CMP_SEL_CFGA,  /*CFGRAM6:  */
    `CS_ALU_OP_PASS, `CS_SRCA_A0, `CS_SRCB_D0, `CS_SHFT_OP_PASS, `CS_A0_SRC_NONE, `CS_A1_SRC_NONE, `CS_FEEDBACK_DSBL, `CS_CI_SEL_CFGA, `CS_SI_SEL_CFGA, `CS_CMP_SEL_CFGA,  /*CFGRAM7:  */
    8'hFF, 8'h00, /* CFG9 */
    8'hFF, 8'hFF, /* CFG11-10 */
    `SC_CMPB_A1_D1, `SC_CMPA_A0_D1, `SC_CI_B_ARITH, `SC_CI_A_ARITH, `SC_C1_MASK_DSBL, `SC_C0_MASK_DSBL, `SC_A_MASK_DSBL, `SC_DEF_SI_0, `SC_SI_B_ROUTE, `SC_SI_A_ROUTE, /* CFG13-12 */
    `SC_A0_SRC_ACC, `SC_SHIFT_SL, 1'b0, `SC_SR_SRC_REG, `SC_FIFO1_ALU, `SC_FIFO0_BUS, `SC_MSB_ENBL, `SC_MSB_BIT7, `SC_MSB_NOCHN, `SC_FB_NOCHN, `SC_CMP1_NOCHN, `SC_CMP0_NOCHN, /* CFG15-14 */
    3'b000, `SC_FIFO_SYNC_NONE, 2'b000, `SC_FIFO1_DYN_OF, `SC_FIFO0_DYN_OF, `SC_FIFO_CLK1_POS, `SC_FIFO_CLK0_POS, `SC_FIFO_CLK__DP, `SC_FIFO_CAP_AX, `SC_FIFO__EDGE, `SC_FIFO__SYNC, `SC_EXTCRC_DSBL, `SC_WRK16CAT_DSBL /* CFG17-16 */
};
cy_psoc3_dp8 #(
    .cy_dpconfig_a( SPI_DPTH_dpconfig0 ),
    .d0_init_a( 8'b11111111 ),
    .d1_init_a( 8'b00000000 ),
    .a0_init_a( 8'b00000000 ),
    .a1_init_a( 8'b00000000 ))
    SPI_DPTH(
        .clk( clock ),
        .cs_addr( SPI_DPTH_select ),
        .route_si( SPI_DPTH_route_si ),
        .route_ci( SPI_DPTH_route_ci ),
        .f0_load( SPI_DPTH_f0_load ),
        .f1_load( SPI_DPTH_f1_load ),
        .d0_load( SPI_DPTH_d0_load ),
        .d1_load( SPI_DPTH_d1_load ),
        .ce0(  ), 
        .cl0(  ), 
        .z0(  ), 
        .ff0(  ), 
        .ce1(  ), 
        .cl1(  ), 
        .z1(  ), 
        .ff1(  ), 
        .ov_msb(  ), 
        .co_msb(  ), 
        .cmsb(  ), 
        .so( Internal_MOSI ), 
        .f0_bus_stat( SpaceForData ), 
        .f0_blk_stat( NoTXData ), 
        .f1_bus_stat( RxDataWaiting ), 
        .f1_blk_stat(  )
    );

/* ==================== State Machine: SPIStates ==================== */
always @ (posedge clock)
begin : Idle_state_logic
    case(SPIStates)
        Idle : 
        begin
            if (( !NoTXData ) == 1'b1)
            begin
                SPIStates <= LoadTxDat ;
            end
            else if (( NoTXData & RX_FreeRun ) == 1'b1)
            begin
                SPIStates <= Load0xFF ;
            end
        end
        LoadTxDat : 
        begin
            if (( 1'b1 ) == 1'b1)
            begin
                SPIStates <= Sending ;
            end
        end
        Sending : 
        begin
            if (( FinalBit & NoTXData & !RX_FreeRun ) == 1'b1)
            begin
                SPIStates <= Idle ;
            end
            else if (( FinalBit & !NoTXData & !RX_FreeRun ) == 1'b1)
            begin
                SPIStates <= LoadTxDat_1 ;
            end
            else if (( FinalBit & NoTXData & RX_FreeRun ) == 1'b1)
            begin
                SPIStates <= Load0xFF_1 ;
            end
        end
        LoadTxDat_1 : 
        begin
            if (( 1'b1 ) == 1'b1)
            begin
                SPIStates <= Sending ;
            end
        end
        Load0xFF_1 : 
        begin
            if (( 1'b1 ) == 1'b1)
            begin
                SPIStates <= Sending ;
            end
        end
        Load0xFF : 
        begin
            if (( 1'b1 ) == 1'b1)
            begin
                SPIStates <= Sending ;
            end
        end
        default :
        begin
            SPIStates <= Idle;
        end
    endcase
end

/* ==================== BIT_COUNTER ==================== */
    Count7_v1_0 BIT_COUNTER (
        .en(BIT_COUNTER_en),
        .load(BIT_COUNTER_load),
        .clock(clock),
        .reset(BIT_COUNTER_reset),
        .cnt(BIT_COUNTER_count),
        .tc(FinalBit));
    defparam BIT_COUNTER.EnableSignal = 1;
    defparam BIT_COUNTER.LoadSignal = 1;

endmodule

// Component: cy_virtualmux_v1_0
`ifdef CY_BLK_DIR
`undef CY_BLK_DIR
`endif

`ifdef WARP
`define CY_BLK_DIR "C:\Program Files (x86)\Cypress\PSoC Creator\4.2\PSoC Creator\psoc\content\CyPrimitives\cyprimitives.cylib\cy_virtualmux_v1_0"
`include "C:\Program Files (x86)\Cypress\PSoC Creator\4.2\PSoC Creator\psoc\content\CyPrimitives\cyprimitives.cylib\cy_virtualmux_v1_0\cy_virtualmux_v1_0.v"
`else
`define CY_BLK_DIR "C:\Program Files (x86)\Cypress\PSoC Creator\4.2\PSoC Creator\psoc\content\CyPrimitives\cyprimitives.cylib\cy_virtualmux_v1_0"
`include "C:\Program Files (x86)\Cypress\PSoC Creator\4.2\PSoC Creator\psoc\content\CyPrimitives\cyprimitives.cylib\cy_virtualmux_v1_0\cy_virtualmux_v1_0.v"
`endif

// Component: ZeroTerminal
`ifdef CY_BLK_DIR
`undef CY_BLK_DIR
`endif

`ifdef WARP
`define CY_BLK_DIR "C:\Program Files (x86)\Cypress\PSoC Creator\4.2\PSoC Creator\psoc\content\CyPrimitives\cyprimitives.cylib\ZeroTerminal"
`include "C:\Program Files (x86)\Cypress\PSoC Creator\4.2\PSoC Creator\psoc\content\CyPrimitives\cyprimitives.cylib\ZeroTerminal\ZeroTerminal.v"
`else
`define CY_BLK_DIR "C:\Program Files (x86)\Cypress\PSoC Creator\4.2\PSoC Creator\psoc\content\CyPrimitives\cyprimitives.cylib\ZeroTerminal"
`include "C:\Program Files (x86)\Cypress\PSoC Creator\4.2\PSoC Creator\psoc\content\CyPrimitives\cyprimitives.cylib\ZeroTerminal\ZeroTerminal.v"
`endif

// Component: OneTerminal
`ifdef CY_BLK_DIR
`undef CY_BLK_DIR
`endif

`ifdef WARP
`define CY_BLK_DIR "C:\Program Files (x86)\Cypress\PSoC Creator\4.2\PSoC Creator\psoc\content\CyPrimitives\cyprimitives.cylib\OneTerminal"
`include "C:\Program Files (x86)\Cypress\PSoC Creator\4.2\PSoC Creator\psoc\content\CyPrimitives\cyprimitives.cylib\OneTerminal\OneTerminal.v"
`else
`define CY_BLK_DIR "C:\Program Files (x86)\Cypress\PSoC Creator\4.2\PSoC Creator\psoc\content\CyPrimitives\cyprimitives.cylib\OneTerminal"
`include "C:\Program Files (x86)\Cypress\PSoC Creator\4.2\PSoC Creator\psoc\content\CyPrimitives\cyprimitives.cylib\OneTerminal\OneTerminal.v"
`endif

// Component: B_Counter_v3_0
`ifdef CY_BLK_DIR
`undef CY_BLK_DIR
`endif

`ifdef WARP
`define CY_BLK_DIR "C:\Program Files (x86)\Cypress\PSoC Creator\4.2\PSoC Creator\psoc\content\CyComponentLibrary\CyComponentLibrary.cylib\B_Counter_v3_0"
`include "C:\Program Files (x86)\Cypress\PSoC Creator\4.2\PSoC Creator\psoc\content\CyComponentLibrary\CyComponentLibrary.cylib\B_Counter_v3_0\B_Counter_v3_0.v"
`else
`define CY_BLK_DIR "C:\Program Files (x86)\Cypress\PSoC Creator\4.2\PSoC Creator\psoc\content\CyComponentLibrary\CyComponentLibrary.cylib\B_Counter_v3_0"
`include "C:\Program Files (x86)\Cypress\PSoC Creator\4.2\PSoC Creator\psoc\content\CyComponentLibrary\CyComponentLibrary.cylib\B_Counter_v3_0\B_Counter_v3_0.v"
`endif

// Counter_v3_0(CaptureMode=0, CaptureModeSoftware=0, ClockMode=0, CompareMode=0, CompareModeSoftware=0, CompareStatusEdgeSense=true, CompareValue=1, CONTROL3=0, ControlRegRemoved=1, CyGetRegReplacementString=CY_GET_REG16, CySetRegReplacementString=CY_SET_REG16, EnableMode=1, FF16=false, FF8=false, FixedFunction=false, FixedFunctionUsed=0, InitCounterValue=0, InterruptOnCapture=false, InterruptOnCompare=false, InterruptOnOverUnderFlow=false, InterruptOnTC=false, Period=65535, RegDefReplacementString=reg16, RegSizeReplacementString=uint16, ReloadOnCapture=false, ReloadOnCompare=false, ReloadOnOverUnder=true, ReloadOnReset=true, Resolution=16, RunMode=0, UDB16=true, UDB24=false, UDB32=false, UDB8=false, UDBControlReg=false, UseInterrupt=true, VerilogSectionReplacementString=sC16, CY_API_CALLBACK_HEADER_INCLUDE=, CY_COMMENT=, CY_COMPONENT_NAME=Counter_v3_0, CY_CONFIG_TITLE=RX_BYTE_COUNTER, CY_CONST_CONFIG=true, CY_CONTROL_FILE=<:default:>, CY_DATASHEET_FILE=<:default:>, CY_FITTER_NAME=NSDSPI:RX_BYTE_COUNTER, CY_INSTANCE_SHORT_NAME=RX_BYTE_COUNTER, CY_MAJOR_VERSION=3, CY_MINOR_VERSION=0, CY_PDL_DRIVER_NAME=, CY_PDL_DRIVER_REQ_VERSION=, CY_PDL_DRIVER_SUBGROUP=, CY_PDL_DRIVER_VARIANT=, CY_REMOVE=false, CY_SUPPRESS_API_GEN=false, CY_VERSION=PSoC Creator  4.2, INSTANCE_NAME=NSDSPI_RX_BYTE_COUNTER, )
module Counter_v3_0_0 (
    reset,
    tc,
    comp,
    clock,
    interrupt,
    enable,
    capture,
    upCnt,
    downCnt,
    up_ndown,
    count);
    input       reset;
    output      tc;
    output      comp;
    input       clock;
    output      interrupt;
    input       enable;
    input       capture;
    input       upCnt;
    input       downCnt;
    input       up_ndown;
    input       count;

    parameter CaptureMode = 0;
    parameter ClockMode = 0;
    parameter CompareMode = 0;
    parameter CompareStatusEdgeSense = 1;
    parameter EnableMode = 1;
    parameter ReloadOnCapture = 0;
    parameter ReloadOnCompare = 0;
    parameter ReloadOnOverUnder = 1;
    parameter ReloadOnReset = 1;
    parameter Resolution = 16;
    parameter RunMode = 0;
    parameter UseInterrupt = 1;

          wire  Net_47;
          wire  Net_102;
          wire  Net_95;
          wire  Net_82;
          wire  Net_91;
          wire  Net_89;
          wire  Net_49;
          wire  Net_48;
          wire  Net_42;
          wire  Net_43;

	// int_vm (cy_virtualmux_v1_0)
	assign interrupt = Net_43;

	// TC_vm (cy_virtualmux_v1_0)
	assign tc = Net_49;

    ZeroTerminal ZeroTerminal_1 (
        .z(Net_82));

	// VirtualMux_1 (cy_virtualmux_v1_0)
	assign Net_89 = up_ndown;

    ZeroTerminal ZeroTerminal_2 (
        .z(Net_95));

	// vmEnableMode (cy_virtualmux_v1_0)
	assign Net_91 = Net_102;

    OneTerminal OneTerminal_1 (
        .o(Net_102));

    B_Counter_v3_0 CounterUDB (
        .reset(reset),
        .tc_out(Net_49),
        .cmp_out(comp),
        .clock(clock),
        .irq_out(Net_43),
        .up_ndown(Net_89),
        .upcnt(upCnt),
        .dwncnt(downCnt),
        .enable(enable),
        .capture(capture),
        .count(count));
    defparam CounterUDB.CaptureMode = 0;
    defparam CounterUDB.ClockMode = 0;
    defparam CounterUDB.CompareMode = 0;
    defparam CounterUDB.CompareStatusEdgeSense = 1;
    defparam CounterUDB.EnableMode = 1;
    defparam CounterUDB.ReloadOnCapture = 0;
    defparam CounterUDB.ReloadOnCompare = 0;
    defparam CounterUDB.ReloadOnOverUnder = 1;
    defparam CounterUDB.ReloadOnReset = 1;
    defparam CounterUDB.Resolution = 16;
    defparam CounterUDB.RunMode = 0;
    defparam CounterUDB.UseInterrupt = 1;



endmodule

// Component: nor_v1_0
`ifdef CY_BLK_DIR
`undef CY_BLK_DIR
`endif

`ifdef WARP
`define CY_BLK_DIR "C:\Program Files (x86)\Cypress\PSoC Creator\4.2\PSoC Creator\psoc\content\CyPrimitives\cyprimitives.cylib\nor_v1_0"
`include "C:\Program Files (x86)\Cypress\PSoC Creator\4.2\PSoC Creator\psoc\content\CyPrimitives\cyprimitives.cylib\nor_v1_0\nor_v1_0.v"
`else
`define CY_BLK_DIR "C:\Program Files (x86)\Cypress\PSoC Creator\4.2\PSoC Creator\psoc\content\CyPrimitives\cyprimitives.cylib\nor_v1_0"
`include "C:\Program Files (x86)\Cypress\PSoC Creator\4.2\PSoC Creator\psoc\content\CyPrimitives\cyprimitives.cylib\nor_v1_0\nor_v1_0.v"
`endif

// Component: CyControlReg_v1_80
`ifdef CY_BLK_DIR
`undef CY_BLK_DIR
`endif

`ifdef WARP
`define CY_BLK_DIR "C:\Program Files (x86)\Cypress\PSoC Creator\4.2\PSoC Creator\psoc\content\CyPrimitives\cyprimitives.cylib\CyControlReg_v1_80"
`include "C:\Program Files (x86)\Cypress\PSoC Creator\4.2\PSoC Creator\psoc\content\CyPrimitives\cyprimitives.cylib\CyControlReg_v1_80\CyControlReg_v1_80.v"
`else
`define CY_BLK_DIR "C:\Program Files (x86)\Cypress\PSoC Creator\4.2\PSoC Creator\psoc\content\CyPrimitives\cyprimitives.cylib\CyControlReg_v1_80"
`include "C:\Program Files (x86)\Cypress\PSoC Creator\4.2\PSoC Creator\psoc\content\CyPrimitives\cyprimitives.cylib\CyControlReg_v1_80\CyControlReg_v1_80.v"
`endif

// Component: cy_constant_v1_0
`ifdef CY_BLK_DIR
`undef CY_BLK_DIR
`endif

`ifdef WARP
`define CY_BLK_DIR "C:\Program Files (x86)\Cypress\PSoC Creator\4.2\PSoC Creator\psoc\content\CyPrimitives\cyprimitives.cylib\cy_constant_v1_0"
`include "C:\Program Files (x86)\Cypress\PSoC Creator\4.2\PSoC Creator\psoc\content\CyPrimitives\cyprimitives.cylib\cy_constant_v1_0\cy_constant_v1_0.v"
`else
`define CY_BLK_DIR "C:\Program Files (x86)\Cypress\PSoC Creator\4.2\PSoC Creator\psoc\content\CyPrimitives\cyprimitives.cylib\cy_constant_v1_0"
`include "C:\Program Files (x86)\Cypress\PSoC Creator\4.2\PSoC Creator\psoc\content\CyPrimitives\cyprimitives.cylib\cy_constant_v1_0\cy_constant_v1_0.v"
`endif

// Component: or_v1_0
`ifdef CY_BLK_DIR
`undef CY_BLK_DIR
`endif

`ifdef WARP
`define CY_BLK_DIR "C:\Program Files (x86)\Cypress\PSoC Creator\4.2\PSoC Creator\psoc\content\CyPrimitives\cyprimitives.cylib\or_v1_0"
`include "C:\Program Files (x86)\Cypress\PSoC Creator\4.2\PSoC Creator\psoc\content\CyPrimitives\cyprimitives.cylib\or_v1_0\or_v1_0.v"
`else
`define CY_BLK_DIR "C:\Program Files (x86)\Cypress\PSoC Creator\4.2\PSoC Creator\psoc\content\CyPrimitives\cyprimitives.cylib\or_v1_0"
`include "C:\Program Files (x86)\Cypress\PSoC Creator\4.2\PSoC Creator\psoc\content\CyPrimitives\cyprimitives.cylib\or_v1_0\or_v1_0.v"
`endif

// NSDSPI(CY_API_CALLBACK_HEADER_INCLUDE=, CY_COMMENT=, CY_COMPONENT_NAME=NSDSPI, CY_CONFIG_TITLE=NSDSPI, CY_CONST_CONFIG=true, CY_CONTROL_FILE=<:default:>, CY_DATASHEET_FILE=<:default:>, CY_FITTER_NAME=NSDSPI, CY_INSTANCE_SHORT_NAME=NSDSPI, CY_MAJOR_VERSION=0, CY_MINOR_VERSION=0, CY_PDL_DRIVER_NAME=, CY_PDL_DRIVER_REQ_VERSION=, CY_PDL_DRIVER_SUBGROUP=, CY_PDL_DRIVER_VARIANT=, CY_REMOVE=false, CY_SUPPRESS_API_GEN=false, CY_VERSION=PSoC Creator  4.2, INSTANCE_NAME=NSDSPI, )
module NSDSPI_1 (
    Clock,
    MISO,
    MOSI,
    SCLK,
    CS);
    input       Clock;
    input       MISO;
    output      MOSI;
    output      SCLK;
    output      CS;


          wire  Net_173;
          wire  Net_172;
          wire  Net_180;
          wire  Net_179;
          wire  Net_178;
          wire  Net_177;
          wire  Net_176;
          wire  Net_175;
          wire  Net_169;
          wire  Net_168;
          wire  Net_167;
          wire  Net_166;
          wire  Net_147;
          wire  Net_165;
          wire  Net_164;
          wire  Net_171;
          wire  Net_170;
          wire  Net_184;
          wire  Net_63;
          wire  Net_152;
          wire  Net_251;
          wire  Net_61;
          wire  Net_14;
          wire  Net_304;
          wire  Net_15;
          wire  Net_301;

    NSDSPI_UDB_BLOCK UDB (
        .clock(Clock),
        .MISO(MISO),
        .RX_FreeRun(Net_301),
        .MOSI(MOSI),
        .SCLK(SCLK),
        .RXDMA(Net_304),
        .TXDMA(Net_14),
        .BYTE_STROBE(Net_15));


	cy_dma_v1_0
		#(.drq_type(2'b01))
		RX
		 (.drq(Net_304),
		  .trq(1'b0),
		  .nrq(Net_171));


    Counter_v3_0_0 RX_BYTE_COUNTER (
        .reset(Net_63),
        .tc(Net_164),
        .comp(Net_184),
        .clock(Clock),
        .interrupt(Net_165),
        .enable(Net_147),
        .capture(1'b0),
        .upCnt(1'b0),
        .downCnt(1'b0),
        .up_ndown(1'b1),
        .count(Net_15));
    defparam RX_BYTE_COUNTER.CaptureMode = 0;
    defparam RX_BYTE_COUNTER.ClockMode = 0;
    defparam RX_BYTE_COUNTER.CompareMode = 0;
    defparam RX_BYTE_COUNTER.CompareStatusEdgeSense = 1;
    defparam RX_BYTE_COUNTER.EnableMode = 1;
    defparam RX_BYTE_COUNTER.ReloadOnCapture = 0;
    defparam RX_BYTE_COUNTER.ReloadOnCompare = 0;
    defparam RX_BYTE_COUNTER.ReloadOnOverUnder = 1;
    defparam RX_BYTE_COUNTER.ReloadOnReset = 1;
    defparam RX_BYTE_COUNTER.Resolution = 16;
    defparam RX_BYTE_COUNTER.RunMode = 0;
    defparam RX_BYTE_COUNTER.UseInterrupt = 1;


    assign Net_63 = ~(Net_301 | Net_251);


    assign Net_301 = ~(Net_152 | Net_63);

    CyControlReg_v1_80 CTRL (
        .control_1(Net_251),
        .control_2(Net_61),
        .control_3(Net_175),
        .control_0(CS),
        .control_4(Net_176),
        .control_5(Net_177),
        .control_6(Net_178),
        .control_7(Net_179),
        .clock(Clock),
        .reset(1'b0));
    defparam CTRL.Bit0Mode = 0;
    defparam CTRL.Bit1Mode = 3;
    defparam CTRL.Bit2Mode = 3;
    defparam CTRL.Bit3Mode = 0;
    defparam CTRL.Bit4Mode = 0;
    defparam CTRL.Bit5Mode = 0;
    defparam CTRL.Bit6Mode = 0;
    defparam CTRL.Bit7Mode = 0;
    defparam CTRL.BitValue = 1;
    defparam CTRL.BusDisplay = 0;
    defparam CTRL.ExtrReset = 1;
    defparam CTRL.NumOutputs = 3;


	cy_dma_v1_0
		#(.drq_type(2'b01))
		TX
		 (.drq(Net_14),
		  .trq(1'b0),
		  .nrq(Net_173));


    assign Net_147 = 1'h1;


	cy_isr_v1_0
		#(.int_type(2'b00))
		RX_DMA_ISR
		 (.int_signal(Net_171));



	cy_isr_v1_0
		#(.int_type(2'b00))
		TX_DMA_ISR
		 (.int_signal(Net_173));



	cy_isr_v1_0
		#(.int_type(2'b00))
		RX_ISR
		 (.int_signal(Net_304));



    assign Net_152 = Net_184 | Net_61;



endmodule

// top
module top ;

          wire  Net_45;
          wire  Net_94;
          wire  Net_5;
          wire  Net_4;
          wire  Net_3;
          wire  Net_1;
          wire  Net_47;
          wire  Net_2;

    NSDSPI_1 NSDSPI (
        .Clock(Net_1),
        .MISO(Net_2),
        .MOSI(Net_3),
        .SCLK(Net_4),
        .CS(Net_5));


	cy_clock_v1_0
		#(.id("5af1ded5-02cc-46d0-9f4e-f980ed547014"),
		  .source_clock_id("61737EF6-3B74-48f9-8B91-F7473A442AE7"),
		  .divisor(200),
		  .period("0"),
		  .is_direct(0),
		  .is_digital(1))
		SD_CLK
		 (.clock_out(Net_1));


	wire [0:0] tmpOE__SD_MISO_net;
	wire [0:0] tmpIO_0__SD_MISO_net;
	wire [0:0] tmpINTERRUPT_0__SD_MISO_net;
	electrical [0:0] tmpSIOVREF__SD_MISO_net;

	cy_psoc3_pins_v1_10
		#(.id("8d318d8b-cf7b-4b6b-b02c-ab1c5c49d0ba"),
		  .drive_mode(3'b010),
		  .ibuf_enabled(1'b1),
		  .init_dr_st(1'b1),
		  .input_clk_en(0),
		  .input_sync(1'b1),
		  .input_sync_mode(1'b0),
		  .intr_mode(2'b00),
		  .invert_in_clock(0),
		  .invert_in_clock_en(0),
		  .invert_in_reset(0),
		  .invert_out_clock(0),
		  .invert_out_clock_en(0),
		  .invert_out_reset(0),
		  .io_voltage(""),
		  .layout_mode("CONTIGUOUS"),
		  .oe_conn(1'b0),
		  .oe_reset(0),
		  .oe_sync(1'b0),
		  .output_clk_en(0),
		  .output_clock_mode(1'b0),
		  .output_conn(1'b0),
		  .output_mode(1'b0),
		  .output_reset(0),
		  .output_sync(1'b0),
		  .pa_in_clock(-1),
		  .pa_in_clock_en(-1),
		  .pa_in_reset(-1),
		  .pa_out_clock(-1),
		  .pa_out_clock_en(-1),
		  .pa_out_reset(-1),
		  .pin_aliases(""),
		  .pin_mode("I"),
		  .por_state(4),
		  .sio_group_cnt(0),
		  .sio_hyst(1'b1),
		  .sio_ibuf(""),
		  .sio_info(2'b00),
		  .sio_obuf(""),
		  .sio_refsel(""),
		  .sio_vtrip(""),
		  .slew_rate(1'b0),
		  .spanning(0),
		  .use_annotation(1'b0),
		  .vtrip(2'b00),
		  .width(1),
		  .ovt_hyst_trim(1'b0),
		  .ovt_needed(1'b0),
		  .ovt_slew_control(2'b00),
		  .input_buffer_sel(2'b00))
		SD_MISO
		 (.oe(tmpOE__SD_MISO_net),
		  .y({1'b0}),
		  .fb({Net_2}),
		  .io({tmpIO_0__SD_MISO_net[0:0]}),
		  .siovref(tmpSIOVREF__SD_MISO_net),
		  .interrupt({tmpINTERRUPT_0__SD_MISO_net[0:0]}),
		  .in_clock({1'b0}),
		  .in_clock_en({1'b1}),
		  .in_reset({1'b0}),
		  .out_clock({1'b0}),
		  .out_clock_en({1'b1}),
		  .out_reset({1'b0}));

	assign tmpOE__SD_MISO_net = (`CYDEV_CHIP_MEMBER_USED == `CYDEV_CHIP_MEMBER_3A && `CYDEV_CHIP_REVISION_USED < `CYDEV_CHIP_REVISION_3A_ES3) ? ~{1'b1} : {1'b1};

	wire [0:0] tmpOE__SD_MOSI_net;
	wire [0:0] tmpFB_0__SD_MOSI_net;
	wire [0:0] tmpIO_0__SD_MOSI_net;
	wire [0:0] tmpINTERRUPT_0__SD_MOSI_net;
	electrical [0:0] tmpSIOVREF__SD_MOSI_net;

	cy_psoc3_pins_v1_10
		#(.id("e851a3b9-efb8-48be-bbb8-b303b216c393"),
		  .drive_mode(3'b110),
		  .ibuf_enabled(1'b1),
		  .init_dr_st(1'b0),
		  .input_clk_en(0),
		  .input_sync(1'b1),
		  .input_sync_mode(1'b0),
		  .intr_mode(2'b00),
		  .invert_in_clock(0),
		  .invert_in_clock_en(0),
		  .invert_in_reset(0),
		  .invert_out_clock(0),
		  .invert_out_clock_en(0),
		  .invert_out_reset(0),
		  .io_voltage(""),
		  .layout_mode("CONTIGUOUS"),
		  .oe_conn(1'b0),
		  .oe_reset(0),
		  .oe_sync(1'b0),
		  .output_clk_en(0),
		  .output_clock_mode(1'b0),
		  .output_conn(1'b1),
		  .output_mode(1'b0),
		  .output_reset(0),
		  .output_sync(1'b0),
		  .pa_in_clock(-1),
		  .pa_in_clock_en(-1),
		  .pa_in_reset(-1),
		  .pa_out_clock(-1),
		  .pa_out_clock_en(-1),
		  .pa_out_reset(-1),
		  .pin_aliases(""),
		  .pin_mode("O"),
		  .por_state(4),
		  .sio_group_cnt(0),
		  .sio_hyst(1'b1),
		  .sio_ibuf(""),
		  .sio_info(2'b00),
		  .sio_obuf(""),
		  .sio_refsel(""),
		  .sio_vtrip(""),
		  .slew_rate(1'b0),
		  .spanning(0),
		  .use_annotation(1'b0),
		  .vtrip(2'b10),
		  .width(1),
		  .ovt_hyst_trim(1'b0),
		  .ovt_needed(1'b0),
		  .ovt_slew_control(2'b00),
		  .input_buffer_sel(2'b00))
		SD_MOSI
		 (.oe(tmpOE__SD_MOSI_net),
		  .y({Net_3}),
		  .fb({tmpFB_0__SD_MOSI_net[0:0]}),
		  .io({tmpIO_0__SD_MOSI_net[0:0]}),
		  .siovref(tmpSIOVREF__SD_MOSI_net),
		  .interrupt({tmpINTERRUPT_0__SD_MOSI_net[0:0]}),
		  .in_clock({1'b0}),
		  .in_clock_en({1'b1}),
		  .in_reset({1'b0}),
		  .out_clock({1'b0}),
		  .out_clock_en({1'b1}),
		  .out_reset({1'b0}));

	assign tmpOE__SD_MOSI_net = (`CYDEV_CHIP_MEMBER_USED == `CYDEV_CHIP_MEMBER_3A && `CYDEV_CHIP_REVISION_USED < `CYDEV_CHIP_REVISION_3A_ES3) ? ~{1'b1} : {1'b1};

	wire [0:0] tmpOE__SD_SCLK_net;
	wire [0:0] tmpFB_0__SD_SCLK_net;
	wire [0:0] tmpIO_0__SD_SCLK_net;
	wire [0:0] tmpINTERRUPT_0__SD_SCLK_net;
	electrical [0:0] tmpSIOVREF__SD_SCLK_net;

	cy_psoc3_pins_v1_10
		#(.id("220dbeea-ec3a-40fe-9bb4-3caea525fa31"),
		  .drive_mode(3'b110),
		  .ibuf_enabled(1'b1),
		  .init_dr_st(1'b0),
		  .input_clk_en(0),
		  .input_sync(1'b1),
		  .input_sync_mode(1'b0),
		  .intr_mode(2'b00),
		  .invert_in_clock(0),
		  .invert_in_clock_en(0),
		  .invert_in_reset(0),
		  .invert_out_clock(0),
		  .invert_out_clock_en(0),
		  .invert_out_reset(0),
		  .io_voltage(""),
		  .layout_mode("CONTIGUOUS"),
		  .oe_conn(1'b0),
		  .oe_reset(0),
		  .oe_sync(1'b0),
		  .output_clk_en(0),
		  .output_clock_mode(1'b0),
		  .output_conn(1'b1),
		  .output_mode(1'b0),
		  .output_reset(0),
		  .output_sync(1'b0),
		  .pa_in_clock(-1),
		  .pa_in_clock_en(-1),
		  .pa_in_reset(-1),
		  .pa_out_clock(-1),
		  .pa_out_clock_en(-1),
		  .pa_out_reset(-1),
		  .pin_aliases(""),
		  .pin_mode("O"),
		  .por_state(4),
		  .sio_group_cnt(0),
		  .sio_hyst(1'b1),
		  .sio_ibuf(""),
		  .sio_info(2'b00),
		  .sio_obuf(""),
		  .sio_refsel(""),
		  .sio_vtrip(""),
		  .slew_rate(1'b0),
		  .spanning(0),
		  .use_annotation(1'b0),
		  .vtrip(2'b10),
		  .width(1),
		  .ovt_hyst_trim(1'b0),
		  .ovt_needed(1'b0),
		  .ovt_slew_control(2'b00),
		  .input_buffer_sel(2'b00))
		SD_SCLK
		 (.oe(tmpOE__SD_SCLK_net),
		  .y({Net_4}),
		  .fb({tmpFB_0__SD_SCLK_net[0:0]}),
		  .io({tmpIO_0__SD_SCLK_net[0:0]}),
		  .siovref(tmpSIOVREF__SD_SCLK_net),
		  .interrupt({tmpINTERRUPT_0__SD_SCLK_net[0:0]}),
		  .in_clock({1'b0}),
		  .in_clock_en({1'b1}),
		  .in_reset({1'b0}),
		  .out_clock({1'b0}),
		  .out_clock_en({1'b1}),
		  .out_reset({1'b0}));

	assign tmpOE__SD_SCLK_net = (`CYDEV_CHIP_MEMBER_USED == `CYDEV_CHIP_MEMBER_3A && `CYDEV_CHIP_REVISION_USED < `CYDEV_CHIP_REVISION_3A_ES3) ? ~{1'b1} : {1'b1};

	wire [0:0] tmpOE__SD_CS_net;
	wire [0:0] tmpFB_0__SD_CS_net;
	wire [0:0] tmpIO_0__SD_CS_net;
	wire [0:0] tmpINTERRUPT_0__SD_CS_net;
	electrical [0:0] tmpSIOVREF__SD_CS_net;

	cy_psoc3_pins_v1_10
		#(.id("fa62009c-11d0-4555-b394-f7bc0a32d55a"),
		  .drive_mode(3'b110),
		  .ibuf_enabled(1'b1),
		  .init_dr_st(1'b0),
		  .input_clk_en(0),
		  .input_sync(1'b1),
		  .input_sync_mode(1'b0),
		  .intr_mode(2'b00),
		  .invert_in_clock(0),
		  .invert_in_clock_en(0),
		  .invert_in_reset(0),
		  .invert_out_clock(0),
		  .invert_out_clock_en(0),
		  .invert_out_reset(0),
		  .io_voltage(""),
		  .layout_mode("CONTIGUOUS"),
		  .oe_conn(1'b0),
		  .oe_reset(0),
		  .oe_sync(1'b0),
		  .output_clk_en(0),
		  .output_clock_mode(1'b0),
		  .output_conn(1'b1),
		  .output_mode(1'b0),
		  .output_reset(0),
		  .output_sync(1'b0),
		  .pa_in_clock(-1),
		  .pa_in_clock_en(-1),
		  .pa_in_reset(-1),
		  .pa_out_clock(-1),
		  .pa_out_clock_en(-1),
		  .pa_out_reset(-1),
		  .pin_aliases(""),
		  .pin_mode("O"),
		  .por_state(4),
		  .sio_group_cnt(0),
		  .sio_hyst(1'b1),
		  .sio_ibuf(""),
		  .sio_info(2'b00),
		  .sio_obuf(""),
		  .sio_refsel(""),
		  .sio_vtrip(""),
		  .slew_rate(1'b0),
		  .spanning(0),
		  .use_annotation(1'b0),
		  .vtrip(2'b10),
		  .width(1),
		  .ovt_hyst_trim(1'b0),
		  .ovt_needed(1'b0),
		  .ovt_slew_control(2'b00),
		  .input_buffer_sel(2'b00))
		SD_CS
		 (.oe(tmpOE__SD_CS_net),
		  .y({Net_5}),
		  .fb({tmpFB_0__SD_CS_net[0:0]}),
		  .io({tmpIO_0__SD_CS_net[0:0]}),
		  .siovref(tmpSIOVREF__SD_CS_net),
		  .interrupt({tmpINTERRUPT_0__SD_CS_net[0:0]}),
		  .in_clock({1'b0}),
		  .in_clock_en({1'b1}),
		  .in_reset({1'b0}),
		  .out_clock({1'b0}),
		  .out_clock_en({1'b1}),
		  .out_reset({1'b0}));

	assign tmpOE__SD_CS_net = (`CYDEV_CHIP_MEMBER_USED == `CYDEV_CHIP_MEMBER_3A && `CYDEV_CHIP_REVISION_USED < `CYDEV_CHIP_REVISION_3A_ES3) ? ~{1'b1} : {1'b1};


	cy_clock_v1_0
		#(.id("da8c024b-41b2-44e2-8971-0423bcdd41cc"),
		  .source_clock_id(""),
		  .divisor(0),
		  .period("1000000000000"),
		  .is_direct(0),
		  .is_digital(1))
		Clock_1
		 (.clock_out(Net_47));



	cy_isr_v1_0
		#(.int_type(2'b00))
		MillisecISR
		 (.int_signal(Net_47));


	wire [0:0] tmpOE__Pin_1_net;
	wire [0:0] tmpFB_0__Pin_1_net;
	wire [0:0] tmpIO_0__Pin_1_net;
	wire [0:0] tmpINTERRUPT_0__Pin_1_net;
	electrical [0:0] tmpSIOVREF__Pin_1_net;

	cy_psoc3_pins_v1_10
		#(.id("f01c3eec-b9d0-4cb0-9926-5110979d5a73"),
		  .drive_mode(3'b110),
		  .ibuf_enabled(1'b1),
		  .init_dr_st(1'b0),
		  .input_clk_en(0),
		  .input_sync(1'b1),
		  .input_sync_mode(1'b0),
		  .intr_mode(2'b00),
		  .invert_in_clock(0),
		  .invert_in_clock_en(0),
		  .invert_in_reset(0),
		  .invert_out_clock(0),
		  .invert_out_clock_en(0),
		  .invert_out_reset(0),
		  .io_voltage(""),
		  .layout_mode("CONTIGUOUS"),
		  .oe_conn(1'b0),
		  .oe_reset(0),
		  .oe_sync(1'b0),
		  .output_clk_en(0),
		  .output_clock_mode(1'b0),
		  .output_conn(1'b1),
		  .output_mode(1'b0),
		  .output_reset(0),
		  .output_sync(1'b0),
		  .pa_in_clock(-1),
		  .pa_in_clock_en(-1),
		  .pa_in_reset(-1),
		  .pa_out_clock(-1),
		  .pa_out_clock_en(-1),
		  .pa_out_reset(-1),
		  .pin_aliases(""),
		  .pin_mode("O"),
		  .por_state(4),
		  .sio_group_cnt(0),
		  .sio_hyst(1'b1),
		  .sio_ibuf(""),
		  .sio_info(2'b00),
		  .sio_obuf(""),
		  .sio_refsel(""),
		  .sio_vtrip(""),
		  .slew_rate(1'b0),
		  .spanning(0),
		  .use_annotation(1'b0),
		  .vtrip(2'b10),
		  .width(1),
		  .ovt_hyst_trim(1'b0),
		  .ovt_needed(1'b0),
		  .ovt_slew_control(2'b00),
		  .input_buffer_sel(2'b00))
		Pin_1
		 (.oe(tmpOE__Pin_1_net),
		  .y({Net_1}),
		  .fb({tmpFB_0__Pin_1_net[0:0]}),
		  .io({tmpIO_0__Pin_1_net[0:0]}),
		  .siovref(tmpSIOVREF__Pin_1_net),
		  .interrupt({tmpINTERRUPT_0__Pin_1_net[0:0]}),
		  .in_clock({1'b0}),
		  .in_clock_en({1'b1}),
		  .in_reset({1'b0}),
		  .out_clock({1'b0}),
		  .out_clock_en({1'b1}),
		  .out_reset({1'b0}));

	assign tmpOE__Pin_1_net = (`CYDEV_CHIP_MEMBER_USED == `CYDEV_CHIP_MEMBER_3A && `CYDEV_CHIP_REVISION_USED < `CYDEV_CHIP_REVISION_3A_ES3) ? ~{1'b1} : {1'b1};



endmodule

