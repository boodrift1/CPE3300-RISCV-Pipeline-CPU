`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Daniel Huang
// 
// Create Date: 05/20/2026 10:33:55 AM
// Design Name: 
// Module Name: CU_DCDR
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


module CU_DCDR(
    // Define CU_DCDR inputs & outputs
    input [31:0] CUDCDR_IR,
    input CUDCDR_BR_EQ,
    input CUDCDR_BR_LT,
    input CUDCDR_BR_LTU,
    output logic [3:0] CUDCDR_ALU_FUN,
    output logic CUDCDR_ALU_SRCA,
    output logic [1:0] CUDCDR_ALU_SRCB,
    output logic [1:0] CUDCDR_PCSOURCE,
    output logic [1:0] CUDCDR_RF_WR_SEL,
    output logic CUDCDR_RF_WE,
    output logic CUDCDR_DM_WE
    );

    // Split IR into opcode, funct3, & funct7 bit
    logic [6:0] CUDCDR_OPCODE;
    logic [14:12] CUDCDR_FUNCT3;
    logic CUDCDR_FUNCT7BIT;
    assign CUDCDR_OPCODE = CUDCDR_IR[6:0];
    assign CUDCDR_FUNCT3 = CUDCDR_IR[14:12];
    assign CUDCDR_FUNCT7BIT = CUDCDR_IR[30];

    // Combinational logic
    always_comb begin
        // Initialize outputs to 0
        CUDCDR_ALU_FUN = 0;
        CUDCDR_ALU_SRCA = 0;
        CUDCDR_ALU_SRCB = 0;
        CUDCDR_PCSOURCE = 0;
        CUDCDR_RF_WR_SEL = 0;
        CUDCDR_RF_WE = 0;
        CUDCDR_DM_WE = 0;

        case (CUDCDR_OPCODE)
            // R-type
            7'h33: begin
                CUDCDR_ALU_SRCA = 0;
                CUDCDR_ALU_SRCB = 0;
                CUDCDR_PCSOURCE = 0;
                CUDCDR_RF_WR_SEL = 3;
                CUDCDR_RF_WE = 1;
                CUDCDR_DM_WE = 0;
                
                case (CUDCDR_FUNCT3)
                    // add & sub
                    3'b000: begin
                        case (CUDCDR_FUNCT7BIT)
                            // add
                            1'b0:
                                CUDCDR_ALU_FUN = 4'b0000;

                            // sub
                            1'b1:
                                CUDCDR_ALU_FUN = 4'b1000;
                        endcase
                    end

                    // and
                    3'b111:
                        CUDCDR_ALU_FUN = 4'b0111;
                    
                    // or
                    3'b110:
                        CUDCDR_ALU_FUN = 4'b0110;

                    // sll
                    3'b001:
                        CUDCDR_ALU_FUN = 4'b0001;
                        
                    // slt
                    3'b010:
                        CUDCDR_ALU_FUN = 4'b0010;

                    // sltu
                    3'b011:
                        CUDCDR_ALU_FUN = 4'b0011;

                    // sra & srl
                    3'b101: begin
                        case (CUDCDR_FUNCT7BIT)
                            // sra
                            1'b1:
                                CUDCDR_ALU_FUN = 4'b1101;

                            // srl
                            1'b0:
                                CUDCDR_ALU_FUN = 4'b0101;
                        endcase
                    end

                    // xor
                    3'b100:
                        CUDCDR_ALU_FUN = 4'b0100;

                endcase
            end

            // I-type: non-jalr & non-load
            7'h13: begin
                CUDCDR_ALU_SRCA = 0;
                CUDCDR_ALU_SRCB = 1;
                CUDCDR_PCSOURCE = 0;
                CUDCDR_RF_WR_SEL = 3;
                CUDCDR_RF_WE = 1;
                CUDCDR_DM_WE = 0;
                
                case (CUDCDR_FUNCT3)
                    // addi
                    3'b000: begin
                        CUDCDR_ALU_FUN = 4'b0000;
                    end

                    // andi
                    3'b111: begin
                        CUDCDR_ALU_FUN = 4'b0111;
                    end

                    // ori
                    3'b110: begin
                        CUDCDR_ALU_FUN = 4'b0110;
                    end

                    // slli
                    3'b001: begin
                        CUDCDR_ALU_FUN = 4'b0001;
                    end

                    // slti
                    3'b010: begin
                        CUDCDR_ALU_FUN = 4'b0010;
                    end

                    // sltiu
                    3'b011: begin
                        CUDCDR_ALU_FUN = 4'b0011;
                    end

                    // srai & srli
                    3'b101: begin
                        case (CUDCDR_FUNCT7BIT)
                            // srai
                            1'b1: begin
                                CUDCDR_ALU_FUN = 4'b1101;
                            end

                            // srli
                            1'b0: begin
                                CUDCDR_ALU_FUN = 4'b0101;
                            end
                        endcase
                    end

                    // xori
                    3'b100: begin
                        CUDCDR_ALU_FUN = 4'b0100;
                    end
                endcase
            end

            // I-type: jalr
            7'h67: begin
                CUDCDR_ALU_FUN = 4'b0000;
                CUDCDR_ALU_SRCA = 0;
                CUDCDR_ALU_SRCB = 0;
                CUDCDR_PCSOURCE = 1;
                CUDCDR_RF_WR_SEL = 0;
                CUDCDR_RF_WE = 1;
                CUDCDR_DM_WE = 0;
            end

            // I-type: load
            7'h03: begin
                CUDCDR_ALU_FUN = 4'b0000;
                CUDCDR_ALU_SRCA = 0;
                CUDCDR_ALU_SRCB = 1;
                CUDCDR_PCSOURCE = 0;
                CUDCDR_RF_WR_SEL = 2;
                CUDCDR_RF_WE = 1;
                CUDCDR_DM_WE = 0;
            end

            // S-type
            7'h23: begin
                CUDCDR_ALU_FUN = 4'b0000;
                CUDCDR_ALU_SRCA = 0;
                CUDCDR_ALU_SRCB = 2;
                CUDCDR_PCSOURCE = 0;
                CUDCDR_RF_WR_SEL = 0;
                CUDCDR_RF_WE = 0;
                CUDCDR_DM_WE = 1;
            end

            // B-type
            7'h63: begin
                CUDCDR_RF_WE = 0;
                CUDCDR_DM_WE = 0;

                case (CUDCDR_FUNCT3)
                    // beq
                    3'b000: begin
                        case (CUDCDR_BR_EQ)
                            // true case
                            1'b1: begin
                                CUDCDR_ALU_FUN = 4'b0000;
                                CUDCDR_ALU_SRCA = 0;
                                CUDCDR_ALU_SRCB = 0;
                                CUDCDR_PCSOURCE = 2;
                                CUDCDR_RF_WR_SEL = 0;
                            end
                            
                            // false case
                            1'b0: begin
                                CUDCDR_ALU_FUN = 4'b0000;
                                CUDCDR_ALU_SRCA = 0;
                                CUDCDR_ALU_SRCB = 0;
                                CUDCDR_PCSOURCE = 0;
                                CUDCDR_RF_WR_SEL = 0;
                            end
                        endcase
                    end

                    // bne
                    3'b001: begin
                        case (CUDCDR_BR_EQ)
                            // true case
                            1'b0: begin
                                CUDCDR_ALU_FUN = 4'b0000;
                                CUDCDR_ALU_SRCA = 0;
                                CUDCDR_ALU_SRCB = 0;
                                CUDCDR_PCSOURCE = 2;
                                CUDCDR_RF_WR_SEL = 0;
                            end
                            
                            // false case
                            1'b1: begin
                                CUDCDR_ALU_FUN = 4'b0000;
                                CUDCDR_ALU_SRCA = 0;
                                CUDCDR_ALU_SRCB = 0;
                                CUDCDR_PCSOURCE = 0;
                                CUDCDR_RF_WR_SEL = 0;
                            end
                        endcase
                    end

                    // blt
                    3'b100: begin
                        case (CUDCDR_BR_LT)
                            // true case
                            1'b1: begin
                                CUDCDR_ALU_FUN = 4'b0000;
                                CUDCDR_ALU_SRCA = 0;
                                CUDCDR_ALU_SRCB = 0;
                                CUDCDR_PCSOURCE = 2;
                                CUDCDR_RF_WR_SEL = 0;
                            end
                            
                            // false case
                            1'b0: begin
                                CUDCDR_ALU_FUN = 4'b0000;
                                CUDCDR_ALU_SRCA = 0;
                                CUDCDR_ALU_SRCB = 0;
                                CUDCDR_PCSOURCE = 0;
                                CUDCDR_RF_WR_SEL = 0;
                            end
                        endcase
                    end

                    // bge
                    3'b101: begin
                        case (CUDCDR_BR_LT)
                            // true case
                            1'b0: begin
                                CUDCDR_ALU_FUN = 4'b0000;
                                CUDCDR_ALU_SRCA = 0;
                                CUDCDR_ALU_SRCB = 0;
                                CUDCDR_PCSOURCE = 2;
                                CUDCDR_RF_WR_SEL = 0;
                            end
                            
                            // false case
                            1'b1: begin
                                CUDCDR_ALU_FUN = 4'b0000;
                                CUDCDR_ALU_SRCA = 0;
                                CUDCDR_ALU_SRCB = 0;
                                CUDCDR_PCSOURCE = 0;
                                CUDCDR_RF_WR_SEL = 0;
                            end
                        endcase
                    end

                    // bltu
                    3'b110: begin
                        case (CUDCDR_BR_LTU)
                            // true case
                            1'b1: begin
                                CUDCDR_ALU_FUN = 4'b0000;
                                CUDCDR_ALU_SRCA = 0;
                                CUDCDR_ALU_SRCB = 0;
                                CUDCDR_PCSOURCE = 2;
                                CUDCDR_RF_WR_SEL = 0;
                            end
                            
                            // false case
                            1'b0: begin
                                CUDCDR_ALU_FUN = 4'b0000;
                                CUDCDR_ALU_SRCA = 0;
                                CUDCDR_ALU_SRCB = 0;
                                CUDCDR_PCSOURCE = 0;
                                CUDCDR_RF_WR_SEL = 0;
                            end
                        endcase
                    end

                    // bgeu
                    3'b111: begin
                        case (CUDCDR_BR_LTU)
                            // true case
                            1'b0: begin
                                CUDCDR_ALU_FUN = 4'b0000;
                                CUDCDR_ALU_SRCA = 0;
                                CUDCDR_ALU_SRCB = 0;
                                CUDCDR_PCSOURCE = 2;
                                CUDCDR_RF_WR_SEL = 0;
                            end
                            
                            // false case
                            1'b1: begin
                                CUDCDR_ALU_FUN = 4'b0000;
                                CUDCDR_ALU_SRCA = 0;
                                CUDCDR_ALU_SRCB = 0;
                                CUDCDR_PCSOURCE = 0;
                                CUDCDR_RF_WR_SEL = 0;
                            end
                        endcase
                    end
                endcase
            end

            // U-type: lui
            7'h37: begin
                CUDCDR_ALU_FUN = 4'b1001;
                CUDCDR_ALU_SRCA = 1;
                CUDCDR_ALU_SRCB = 0;
                CUDCDR_PCSOURCE = 0;
                CUDCDR_RF_WR_SEL = 3;
                CUDCDR_RF_WE = 1;
                CUDCDR_DM_WE = 0;
            end

            // U-type: auipc
            7'h17: begin
                CUDCDR_ALU_FUN = 4'b0000;
                CUDCDR_ALU_SRCA = 1;
                CUDCDR_ALU_SRCB = 3;
                CUDCDR_PCSOURCE = 0;
                CUDCDR_RF_WR_SEL = 3;
                CUDCDR_RF_WE = 1;
                CUDCDR_DM_WE = 0;
            end

            // J-type
            7'h6F: begin
                CUDCDR_ALU_FUN = 4'b0000;
                CUDCDR_ALU_SRCA = 0;
                CUDCDR_ALU_SRCB = 0;
                CUDCDR_PCSOURCE = 3;
                CUDCDR_RF_WR_SEL = 0;
                CUDCDR_RF_WE = 1;
                CUDCDR_DM_WE = 0;
            end
        endcase
    end
endmodule
