`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Daniel Huang
// 
// Create Date: 05/03/2026 07:58:55 PM
// Design Name: 
// Module Name: ALU
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


module ALU(
    // Define ALU inputs & outputs
    input [31:0] ALU_A,
    input [31:0] ALU_B,
    input [3:0] ALU_FUN,
    output logic [31:0] ALU_OUT
    );
    
    always_comb begin // Combinational logic based on alu_fun
        case(ALU_FUN)
            4'b0000: ALU_OUT = ALU_A + ALU_B; // add
            4'b1000: ALU_OUT = ALU_A - ALU_B; // sub
            4'b0110: ALU_OUT = ALU_A | ALU_B; // or
            4'b0111: ALU_OUT = ALU_A & ALU_B; // and
            4'b0100: ALU_OUT = ALU_A ^ ALU_B; // xor
            4'b0101: ALU_OUT = ALU_A >> ALU_B[4:0]; // srl
            4'b0001: ALU_OUT = ALU_A << ALU_B[4:0]; // sll
            4'b1101: ALU_OUT = $signed(ALU_A) >>> $signed(ALU_B[4:0]); // sra
            4'b0010: ALU_OUT = $signed(ALU_A) < $signed(ALU_B); // slt
            4'b0011: ALU_OUT = ALU_A < ALU_B; // sltu
            4'b1001: ALU_OUT = ALU_A; // lui-copy
            
            default: ALU_OUT = 32'b0;
        endcase
    end           
endmodule
