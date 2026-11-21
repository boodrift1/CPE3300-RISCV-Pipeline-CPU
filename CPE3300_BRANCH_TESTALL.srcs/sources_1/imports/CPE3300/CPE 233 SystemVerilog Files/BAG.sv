`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Daniel Huang
//           VT Vo
// 
// Create Date: 05/15/2026 10:59:39 PM
// Design Name: 
// Module Name: BAG
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


module BAG(
    // Define BAG inputs & outputs
    input [31:0] BAG_RS1,
    input [31:0] BAG_I_TYPE,
    input [31:0] BAG_B_TYPE,
    input [31:0] BAG_J_TYPE,
    input [31:0] BAG_PC,
    output logic [31:0] BAG_JAL,
    output logic [31:0] BAG_BRANCH,
    output logic [31:0] BAG_JALR
    );

    always_comb begin
        // IMM is signed for backwards jumps/branches
        BAG_JAL = BAG_PC + $signed(BAG_J_TYPE);
        BAG_BRANCH = BAG_PC + $signed(BAG_B_TYPE);
        BAG_JALR = BAG_RS1 + $signed(BAG_I_TYPE);
    end
endmodule
