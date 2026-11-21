`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Daniel Huang
// 
// Create Date: 05/04/2026 06:39:46 PM
// Design Name: 
// Module Name: IMMED_GEN
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


module IMMED_GEN(
    // Define IG inputs & outputs
    input [31:0] IG_IR,
    output [31:0] IG_U_TYPE,
    output [31:0] IG_I_TYPE,
    output [31:0] IG_S_TYPE,
    output [31:0] IG_B_TYPE,
    output [31:0] IG_J_TYPE
    );

    logic [31:7] IG_IN;
    assign IG_IN = IG_IR[31:7];  // Machine code without opcode
    
    // Bit parsing for different immediate types
    assign IG_U_TYPE = {IG_IN[31:12], {12{1'b0}}}; 
    assign IG_I_TYPE = {{21{IG_IN[31]}}, IG_IN[30:25], IG_IN[24:20]};
    assign IG_S_TYPE = {{21{IG_IN[31]}}, IG_IN[30:25], IG_IN[11:7]};
    assign IG_B_TYPE = {{20{IG_IN[31]}}, IG_IN[7], IG_IN[30:25], IG_IN[11:8], 1'b0};
    assign IG_J_TYPE = {{12{IG_IN[31]}}, IG_IN[19:12], IG_IN[20], IG_IN[30:21], 1'b0};
endmodule
