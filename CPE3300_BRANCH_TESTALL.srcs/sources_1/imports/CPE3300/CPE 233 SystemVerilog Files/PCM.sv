`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Daniel Huang
// 
// Create Date: 04/14/2026 05:03:29 PM
// Design Name: 
// Module Name: PCM
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


module PCM(
    input PCM_RST,
    input PCM_WE,
    input PCM_CLK,
    input [1:0] PCM_SEL,
    input [31:0] PCM_JALR,
    input [31:0] PCM_BRANCH,
    input [31:0] PCM_JAL,
    output logic [31:0] PCM_COUNT,
    output [31:0] PCM_PLUS4
    );
    
    logic [31:0] PC_DIN; // Declare internal signals
    logic [31:0] PCMUX_OUT;
    
    assign PC_DIN = PCMUX_OUT; // Assign internal signals
    assign PCM_PLUS4 = PCM_COUNT + 4; // Assign PLUS4 block
    
    // Mod: PCM_RST is now asynchronous
    always_ff @(posedge PCM_CLK or posedge PCM_RST) begin // PC block
        if (PCM_RST)
            PCM_COUNT <= 32'h00000000;
        else if (PCM_WE)
            PCM_COUNT <= PC_DIN;
    end
    
    always_comb begin // PC MUX block
        case (PCM_SEL)
            2'd0: PCMUX_OUT = PCM_PLUS4;
            2'd1: PCMUX_OUT = PCM_JALR;
            2'd2: PCMUX_OUT = PCM_BRANCH;
            2'd3: PCMUX_OUT = PCM_JAL;
        endcase
    end
endmodule

