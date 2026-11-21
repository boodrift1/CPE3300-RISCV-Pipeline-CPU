`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/16/2026 10:35:31 AM
// Design Name: 
// Module Name: HCU
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


module HCU(
    input [31:0] RF_IR_E,       // Forward inputs
    input CUDCDR_ALU_SRCA,
    input [1:0] CUDCDR_ALU_SRCB,
    input [4:0] RF_WA_M,
    input [4:0] RF_WA_W,
    input RF_WE_M,
    input RF_WE_W,

    input [31:0] RF_IR_D,       // Stall inputs
    input [4:0] RF_WA_E,
    input [1:0] CUDCDR_RF_WR_SEL_E,

    input BCG_BR_EQ_E,          // Branch prediction inputs
    input BCG_BR_LT_E,
    input BCG_BR_LTU_E,
    input [31:0] RF_IR_M,

    output logic [1:0] FWD_AE,  // Forward outputs
    output logic [1:0] FWD_BE,

    output logic STL_F,         // Stall outputs
    output logic STL_D,
    output logic FSH_E,

    output logic FSH_D,          // Branch prediction outputs
    output logic [1:0] PC_SOURCE
    );
    
    logic [4:0] RF_ADR1_E;
    logic [4:0] RF_ADR2_E;
    logic [4:0] RF_ADR1_D;
    logic [4:0] RF_ADR2_D;
    logic [6:0] RF_OPCODE_E;
    logic [2:0] RF_FUNCT3_E;
    logic [6:0] RF_OPCODE_D;
    logic [6:0] RF_OPCODE_M;
    logic BRANCH_TAKEN;
    
    assign RF_ADR1_E = RF_IR_E[19:15];
    assign RF_ADR2_E = RF_IR_E[24:20];
    assign RF_ADR1_D = RF_IR_D[19:15];
    assign RF_ADR2_D = RF_IR_D[24:20];
    assign RF_OPCODE_E = RF_IR_E[6:0];
    assign RF_FUNCT3_E = RF_IR_E[14:12];
    assign RF_OPCODE_D = RF_IR_D[6:0];
    assign RF_OPCODE_M = RF_IR_M[6:0];

    always_comb begin
        FWD_AE = 2'b00;
        FWD_BE = 2'b00;

        STL_F = 1'b1;
        STL_D = 1'b1;
        FSH_E = 1'b0;
        FSH_D = 1'b0;

        // Forwarding logic
        // FWD_AE: source register ADR1
        if (RF_WE_M && (CUDCDR_ALU_SRCA == 2'b00) && (RF_ADR1_E != 0) && (RF_ADR1_E == RF_WA_M))
            FWD_AE = 2'b10;
        else if (RF_WE_W && (CUDCDR_ALU_SRCA == 2'b00) && (RF_ADR1_E != 0) && (RF_ADR1_E == RF_WA_W))
            FWD_AE = 2'b01;

        // FWD_BE: source register ADR2
        if (RF_WE_M && ((CUDCDR_ALU_SRCB == 2'b00) || (RF_OPCODE_E == 7'h23)) && (RF_ADR2_E != 0) && (RF_ADR2_E == RF_WA_M))
            FWD_BE = 2'b10;
        else if (RF_WE_W && ((CUDCDR_ALU_SRCB == 2'b00) || (RF_OPCODE_E == 7'h23)) && (RF_ADR2_E != 0) && (RF_ADR2_E == RF_WA_W))
            FWD_BE = 2'b01;       

        // Stall logic
        if ((CUDCDR_RF_WR_SEL_E == 2'b10) && ((RF_ADR1_D == RF_WA_E) || (RF_ADR2_D == RF_WA_E))) begin
            STL_F = 1'b0;
            STL_D = 1'b0;
            FSH_E = 1'b1;
        end

        // Simplified CUDCDR-BCG logic
        PC_SOURCE = 0;
        BRANCH_TAKEN = 1'b0;
    
        case (RF_OPCODE_E)
            // B-type
            7'h63: begin
                case (RF_FUNCT3_E)
                    // beq
                    3'b000: begin
                        case (BCG_BR_EQ_E)
                            // true case
                            1'b1: begin
                                BRANCH_TAKEN = 1'b1;
                            end
                        endcase
                    end

                    // bne
                    3'b001: begin
                        case (BCG_BR_EQ_E)
                            // true case
                            1'b0: begin
                                BRANCH_TAKEN = 1'b1;
                            end
                        endcase
                    end

                    // blt
                    3'b100: begin
                        case (BCG_BR_LT_E)
                            // true case
                            1'b1: begin
                                BRANCH_TAKEN = 1'b1;
                            end
                        endcase
                    end

                    // bge
                    3'b101: begin
                        case (BCG_BR_LT_E)
                            // true case
                            1'b0: begin
                                BRANCH_TAKEN = 1'b1;
                            end
                        endcase
                    end

                    // bltu
                    3'b110: begin
                        case (BCG_BR_LTU_E)
                            // true case
                            1'b1: begin
                                BRANCH_TAKEN = 1'b1;
                            end
                        endcase
                    end

                    // bgeu
                    3'b111: begin
                        case (BCG_BR_LTU_E)
                            // true case
                            1'b0: begin
                                BRANCH_TAKEN = 1'b1;
                            end
                        endcase
                    end
                endcase
            end
        endcase

        // Branch prediction flush logic
        if (BRANCH_TAKEN) begin
            PC_SOURCE = 2'd2;
            FSH_D = 1'b1;
            FSH_E = 1'b1;
        end
        else if (RF_OPCODE_E == 7'h67) begin
            PC_SOURCE = 2'd1;
            FSH_D = 1'b1;
            FSH_E = 1'b1;
        end
        else if ((RF_OPCODE_E == 7'h6F)) begin
            PC_SOURCE = 2'd3;
            FSH_D = 1'b1;
            FSH_E = 1'b1;
        end
    end
    
endmodule