`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/06/2026 10:28:39 PM
// Design Name: 
// Module Name: OTTERPLR_Top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module OTTERPLR_Top(
    input RST,
    input INTR,
    input [31:0] IOBUS_IN,
    input CLK,
    output IOBUS_WR,
    output [31:0] IOBUS_OUT,
    output [31:0] IOBUS_ADDR
    );

    // Declare pipeline register struct
    typedef struct packed{
        // IF_DEC_reg signals
        logic [31:0] IR;
        logic [31:0] PC;
        logic [31:0] PC_PLUS4;
        logic [4:0] RF_ADR1;
        logic [4:0] RF_ADR2;
        logic [4:0] RF_WA;

        // DEC_EXEC_reg signals
        logic [31:0] RF_RS1;
        logic [31:0] RF_RS2;
        logic [31:0] ALU_SRCA;
        logic [31:0] ALU_SRCB;
        logic [31:0] IG_U_TYPE;
        logic [31:0] IG_I_TYPE;
        logic [31:0] IG_S_TYPE;
        logic [31:0] IG_B_TYPE;
        logic [31:0] IG_J_TYPE;
        logic CUDCDR_ALU_SRCA;
        logic [1:0] CUDCDR_ALU_SRCB;
        logic [3:0] CUDCDR_ALU_FUN;
        logic [1:0] CUDCDR_PCSOURCE;
        logic [1:0] CUDCDR_RF_WR_SEL;
        logic CUDCDR_RF_WE;
        logic CUDCDR_DM_WE;

        // EXEC_MEM_reg signals
        logic [31:0] FWD_BE_OUT;
        logic [31:0] ALU_RESULT;
        logic [31:0] BAG_JALR;
        logic [31:0] BAG_BRANCH;
        logic [31:0] BAG_JAL;
        logic BCG_BR_EQ;
        logic BCG_BR_LT;
        logic BCG_BR_LTU;

        // MEM_WB_reg signals
        logic [31:0] MEM_DOUT2;
    } pipe_reg;

    // Declare buses
    // Fetch
    // PC
    logic [31:0] BUS_PC;
    logic [31:0] BUS_PC_PLUS4;
    logic [1:0] BUS_PC_SEL;

    // ProgROM (IM)
    logic [31:0] BUS_IR;
    logic [4:0] BUS_RF_ADR1;
    logic [4:0] BUS_RF_ADR2;
    logic [4:0] BUS_RF_WA;

    // Decode
    // REG_FILE
    logic [31:0] BUS_RF_RS1;
    logic [31:0] BUS_RF_RS2;

    // IMMED_GEN
    logic [31:0] BUS_IG_U_TYPE;
    logic [31:0] BUS_IG_I_TYPE;
    logic [31:0] BUS_IG_S_TYPE;
    logic [31:0] BUS_IG_B_TYPE;
    logic [31:0] BUS_IG_J_TYPE;

    // CU_DCDR
    logic [3:0] BUS_CUDCDR_ALU_FUN;
    logic BUS_CUDCDR_ALU_SRCA; // SRCA MUX select
    logic [1:0] BUS_CUDCDR_ALU_SRCB; // SRCB MUX select
    logic [1:0] BUS_CUDCDR_PCSOURCE;
    logic [1:0] BUS_CUDCDR_RF_WR_SEL;
    logic BUS_CUDCDR_RF_WE;
    logic BUS_CUDCDR_DM_WE;

    // RF MUX
    logic [31:0] BUS_RF_WD;

    // Execute
    // ALU MUX outputs
    logic [31:0] BUS_ALU_SRCA;
    logic [31:0] BUS_ALU_SRCB;
    
    // ALU output
    logic [31:0] BUS_ALU_RESULT;

    // BAG
    logic [31:0] BUS_BAG_JALR;
    logic [31:0] BUS_BAG_BRANCH;
    logic [31:0] BUS_BAG_JAL;

    // BCG
    logic BUS_BCG_BR_EQ;
    logic BUS_BCG_BR_LT;
    logic BUS_BCG_BR_LTU;

    // Memory
    // MEMORY (DM)
    logic [31:0] BUS_MEM_DOUT2;
    
    // Hazards
    // HCU Forwarding
    logic [1:0] BUS_FWD_AE;
    logic [1:0] BUS_FWD_BE;
    logic [31:0] BUS_FWD_AE_OUT;
    logic [31:0] BUS_FWD_BE_OUT;

    // HCU Stalls
    logic BUS_STL_F;
    logic BUS_STL_D;
    logic BUS_FSH_E;
    logic BUS_FSH_D;

    // Create MUXes
    always_comb begin
        BUS_ALU_SRCA = 0;
        BUS_ALU_SRCB = 0;
        BUS_FWD_AE_OUT = 0;
        BUS_FWD_BE_OUT = 0;
        BUS_RF_WD = 0;

        // FWD_AE MUX
        case (BUS_FWD_AE)
            2'b00: BUS_FWD_AE_OUT = DEC_EXEC_reg.RF_RS1;
            2'b01: BUS_FWD_AE_OUT = MEM_WB_reg.ALU_RESULT;
            2'b10: BUS_FWD_AE_OUT = EXEC_MEM_reg.ALU_RESULT;
        endcase

        // FWD_BE MUX
        case (BUS_FWD_BE)
            2'b00: BUS_FWD_BE_OUT = DEC_EXEC_reg.RF_RS2;
            2'b01: BUS_FWD_BE_OUT = MEM_WB_reg.ALU_RESULT;
            2'b10: BUS_FWD_BE_OUT = EXEC_MEM_reg.ALU_RESULT;
        endcase
        
        // ALU SRCA MUX
        case (DEC_EXEC_reg.CUDCDR_ALU_SRCA)
            1'b0: BUS_ALU_SRCA = BUS_FWD_AE_OUT;
            1'b1: BUS_ALU_SRCA = DEC_EXEC_reg.IG_U_TYPE;
        endcase

        // ALU SRCB MUX
        case (DEC_EXEC_reg.CUDCDR_ALU_SRCB)
            2'd0: BUS_ALU_SRCB = BUS_FWD_BE_OUT;
            2'd1: BUS_ALU_SRCB = DEC_EXEC_reg.IG_I_TYPE;
            2'd2: BUS_ALU_SRCB = DEC_EXEC_reg.IG_S_TYPE;
            2'd3: BUS_ALU_SRCB = DEC_EXEC_reg.PC;
        endcase

        // RF MUX
        case (MEM_WB_reg.CUDCDR_RF_WR_SEL)
            2'd0: BUS_RF_WD = MEM_WB_reg.PC_PLUS4;
            2'd1: BUS_RF_WD = 0;
            2'd2: BUS_RF_WD = MEM_WB_reg.MEM_DOUT2;
            2'd3: BUS_RF_WD = MEM_WB_reg.ALU_RESULT;
        endcase
    end

    // Create connections between modules
    // Fetch Stage
    PCM PCM1(
        .PCM_RST(RST),
        .PCM_WE(BUS_STL_F),
        .PCM_CLK(CLK),
        .PCM_SEL(BUS_PC_SEL),
        .PCM_JALR(BUS_BAG_JALR),
        .PCM_BRANCH(BUS_BAG_BRANCH),
        .PCM_JAL(BUS_BAG_JAL),
        .PCM_COUNT(BUS_PC),
        .PCM_PLUS4(BUS_PC_PLUS4)
    );

    ProgROM IM1(
        .PROG_ADDR(BUS_PC),
        .INSTRUCT(BUS_IR)
    );

    // Decode Stage
    REGFILE RF1(
        .RF_CLK(CLK),
        .RF_EN(MEM_WB_reg.CUDCDR_RF_WE),
        .RF_IR(IF_DEC_reg.IR),
        .RF_WA(MEM_WB_reg.RF_WA),
        .RF_WD(BUS_RF_WD),
        .RF_RS1(BUS_RF_RS1),
        .RF_RS2(BUS_RF_RS2)
    );

    IMMED_GEN IG1(
        .IG_IR(IF_DEC_reg.IR),
        .IG_U_TYPE(BUS_IG_U_TYPE),
        .IG_I_TYPE(BUS_IG_I_TYPE),
        .IG_S_TYPE(BUS_IG_S_TYPE),
        .IG_B_TYPE(BUS_IG_B_TYPE),
        .IG_J_TYPE(BUS_IG_J_TYPE)
    );

    CU_DCDR CUDCDR1(
        .CUDCDR_IR(IF_DEC_reg.IR),
        .CUDCDR_BR_EQ(1'b0),
        .CUDCDR_BR_LT(1'b0),
        .CUDCDR_BR_LTU(1'b0),
        .CUDCDR_ALU_FUN(BUS_CUDCDR_ALU_FUN),
        .CUDCDR_ALU_SRCA(BUS_CUDCDR_ALU_SRCA),
        .CUDCDR_ALU_SRCB(BUS_CUDCDR_ALU_SRCB),
        .CUDCDR_PCSOURCE(BUS_CUDCDR_PCSOURCE),
        .CUDCDR_RF_WR_SEL(BUS_CUDCDR_RF_WR_SEL),
        .CUDCDR_RF_WE(BUS_CUDCDR_RF_WE),
        .CUDCDR_DM_WE(BUS_CUDCDR_DM_WE)
    );

    // Execute Stage
    ALU ALU1(
        .ALU_A(BUS_ALU_SRCA),
        .ALU_B(BUS_ALU_SRCB),
        .ALU_FUN(DEC_EXEC_reg.CUDCDR_ALU_FUN),
        .ALU_OUT(BUS_ALU_RESULT)
    );

    BAG BAG1(
        .BAG_RS1(BUS_FWD_AE_OUT),
        .BAG_I_TYPE(DEC_EXEC_reg.IG_I_TYPE),
        .BAG_B_TYPE(DEC_EXEC_reg.IG_B_TYPE),
        .BAG_J_TYPE(DEC_EXEC_reg.IG_J_TYPE),
        .BAG_PC(DEC_EXEC_reg.PC),
        .BAG_JAL(BUS_BAG_JAL),
        .BAG_BRANCH(BUS_BAG_BRANCH),
        .BAG_JALR(BUS_BAG_JALR)
    );

    BCG BCG1(
        .BCG_RS1(BUS_FWD_AE_OUT),
        .BCG_RS2(BUS_FWD_BE_OUT),
        .BCG_BR_EQ(BUS_BCG_BR_EQ),
        .BCG_BR_LT(BUS_BCG_BR_LT),
        .BCG_BR_LTU(BUS_BCG_BR_LTU)
    );

    // Memory Stage
    Memory DM1(
        .MEM_CLK(CLK),
        .MEM_RDEN1(1'b0),
        .MEM_RDEN2(1'b1),
        .MEM_WE2(EXEC_MEM_reg.CUDCDR_DM_WE),
        .MEM_ADDR1(14'h0),
        .MEM_ADDR2(EXEC_MEM_reg.ALU_RESULT),
        .MEM_DIN2(EXEC_MEM_reg.FWD_BE_OUT),
        .MEM_SIZE(EXEC_MEM_reg.IR[13:12]),
        .MEM_SIGN(EXEC_MEM_reg.IR[14]),
        .IO_IN(IOBUS_IN),
        .IO_WR(IOBUS_WR),
        .MEM_DOUT1(),
        .MEM_DOUT2(BUS_MEM_DOUT2)
    );
    
    // Hazard Control Unit
    HCU HCU1(
        .RF_IR_E(DEC_EXEC_reg.IR),
        .CUDCDR_ALU_SRCA(DEC_EXEC_reg.CUDCDR_ALU_SRCA),
        .CUDCDR_ALU_SRCB(DEC_EXEC_reg.CUDCDR_ALU_SRCB),
        .RF_WA_M(EXEC_MEM_reg.RF_WA),
        .RF_WA_W(MEM_WB_reg.RF_WA),
        .RF_WE_M(EXEC_MEM_reg.CUDCDR_RF_WE),
        .RF_WE_W(MEM_WB_reg.CUDCDR_RF_WE),

        .RF_IR_D(IF_DEC_reg.IR),
        .RF_WA_E(DEC_EXEC_reg.RF_WA),
        .CUDCDR_RF_WR_SEL_E(DEC_EXEC_reg.CUDCDR_RF_WR_SEL),

        .BCG_BR_EQ_E(BUS_BCG_BR_EQ),
        .BCG_BR_LT_E(BUS_BCG_BR_LT),
        .BCG_BR_LTU_E(BUS_BCG_BR_LTU),
        .RF_IR_M(EXEC_MEM_reg.IR),

        .FWD_AE(BUS_FWD_AE),
        .FWD_BE(BUS_FWD_BE),

        .STL_F(BUS_STL_F),
        .STL_D(BUS_STL_D),
        .FSH_E(BUS_FSH_E),

        .FSH_D(BUS_FSH_D),
        .PC_SOURCE(BUS_PC_SEL)
    );

    // Assign PLR struct signals to buses
    // Fetch-Decode PLR
    pipe_reg IF_DEC_reg;
    always_ff @(posedge CLK) begin
        if (BUS_STL_D) begin
            if (BUS_FSH_D) begin
                IF_DEC_reg.IR <= 32'h0;
                IF_DEC_reg.PC <= 32'h0;
                IF_DEC_reg.PC_PLUS4 <= 32'h0;
                IF_DEC_reg.RF_ADR1 <= 5'b0;
                IF_DEC_reg.RF_ADR2 <= 5'b0;
                IF_DEC_reg.RF_WA <= 5'b0;
            end
            else begin
                IF_DEC_reg.IR <= BUS_IR;
                IF_DEC_reg.PC <= BUS_PC;
                IF_DEC_reg.PC_PLUS4 <= BUS_PC_PLUS4;
                IF_DEC_reg.RF_ADR1 <= BUS_RF_ADR1;
                IF_DEC_reg.RF_ADR2 <= BUS_RF_ADR2;
                IF_DEC_reg.RF_WA <= BUS_RF_WA;
            end
        end
    end

    // Decode-Execute PLR
    pipe_reg DEC_EXEC_reg;
    always_ff @(posedge CLK) begin
        if (BUS_FSH_E) begin
            DEC_EXEC_reg.IR <= 32'h0;
            DEC_EXEC_reg.PC <= 32'h0;
            DEC_EXEC_reg.PC_PLUS4 <= 32'h0;
            DEC_EXEC_reg.RF_ADR1 <= 5'b0;
            DEC_EXEC_reg.RF_ADR2 <= 5'b0;
            DEC_EXEC_reg.RF_WA <= 5'b0;
            DEC_EXEC_reg.RF_RS1 <= 32'h0;
            DEC_EXEC_reg.RF_RS2 <= 32'h0;
            DEC_EXEC_reg.ALU_SRCA <= 32'h0;
            DEC_EXEC_reg.ALU_SRCB <= 32'h0;
            DEC_EXEC_reg.IG_U_TYPE <= 32'h0;
            DEC_EXEC_reg.IG_I_TYPE <= 32'h0;
            DEC_EXEC_reg.IG_S_TYPE <= 32'h0;
            DEC_EXEC_reg.IG_B_TYPE <= 32'h0;
            DEC_EXEC_reg.IG_J_TYPE <= 32'h0;
            DEC_EXEC_reg.CUDCDR_ALU_SRCA <= 1'b0;
            DEC_EXEC_reg.CUDCDR_ALU_SRCB <= 2'b0;
            DEC_EXEC_reg.CUDCDR_ALU_FUN <= 4'b0;
            DEC_EXEC_reg.CUDCDR_PCSOURCE <= 2'b0;
            DEC_EXEC_reg.CUDCDR_RF_WR_SEL <= 2'b0;
            DEC_EXEC_reg.CUDCDR_RF_WE <= 1'b0;
            DEC_EXEC_reg.CUDCDR_DM_WE <= 1'b0;
        end
        else begin
            DEC_EXEC_reg <= IF_DEC_reg;
            DEC_EXEC_reg.RF_RS1 <= BUS_RF_RS1;
            DEC_EXEC_reg.RF_RS2 <= BUS_RF_RS2;
            DEC_EXEC_reg.ALU_SRCA <= BUS_ALU_SRCA;
            DEC_EXEC_reg.ALU_SRCB <= BUS_ALU_SRCB;
            DEC_EXEC_reg.IG_U_TYPE <= BUS_IG_U_TYPE;
            DEC_EXEC_reg.IG_I_TYPE <= BUS_IG_I_TYPE;
            DEC_EXEC_reg.IG_S_TYPE <= BUS_IG_S_TYPE;
            DEC_EXEC_reg.IG_B_TYPE <= BUS_IG_B_TYPE;
            DEC_EXEC_reg.IG_J_TYPE <= BUS_IG_J_TYPE;
            DEC_EXEC_reg.CUDCDR_ALU_SRCA <= BUS_CUDCDR_ALU_SRCA;
            DEC_EXEC_reg.CUDCDR_ALU_SRCB <= BUS_CUDCDR_ALU_SRCB;
            DEC_EXEC_reg.CUDCDR_ALU_FUN <= BUS_CUDCDR_ALU_FUN;
            DEC_EXEC_reg.CUDCDR_PCSOURCE <= BUS_CUDCDR_PCSOURCE;
            DEC_EXEC_reg.CUDCDR_RF_WR_SEL <= BUS_CUDCDR_RF_WR_SEL;
            DEC_EXEC_reg.CUDCDR_RF_WE <= BUS_CUDCDR_RF_WE;
            DEC_EXEC_reg.CUDCDR_DM_WE <= BUS_CUDCDR_DM_WE;
        end
    end

    // Execute-Memory PLR
    pipe_reg EXEC_MEM_reg;
    always_ff @(posedge CLK) begin
        EXEC_MEM_reg <= DEC_EXEC_reg;
        EXEC_MEM_reg.FWD_BE_OUT <= BUS_FWD_BE_OUT;
        EXEC_MEM_reg.ALU_RESULT <= BUS_ALU_RESULT;
        EXEC_MEM_reg.BAG_JALR <= BUS_BAG_JALR;
        EXEC_MEM_reg.BAG_BRANCH <= BUS_BAG_BRANCH;
        EXEC_MEM_reg.BAG_JAL <= BUS_BAG_JAL;
        EXEC_MEM_reg.BCG_BR_EQ <= BUS_BCG_BR_EQ;
        EXEC_MEM_reg.BCG_BR_LT <= BUS_BCG_BR_LT;
        EXEC_MEM_reg.BCG_BR_LTU <= BUS_BCG_BR_LTU;
    end

    // Memory-Writeback PLR
    pipe_reg MEM_WB_reg;
    always_ff @(posedge CLK) begin
        MEM_WB_reg <= EXEC_MEM_reg;
        MEM_WB_reg.MEM_DOUT2 <= BUS_MEM_DOUT2;
    end

    // Assign rs1, rs2, & write address as slice of instruction
    assign BUS_RF_ADR1 = BUS_IR[19:15];
    assign BUS_RF_ADR2 = BUS_IR[24:20];
    assign BUS_RF_WA = BUS_IR[11:7];

endmodule
