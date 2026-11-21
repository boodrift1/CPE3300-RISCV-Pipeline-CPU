`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Daniel Huang
// 
// Create Date: 05/15/2026 10:36:23 PM
// Design Name: 
// Module Name: BCG
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


module BCG(
    // Define BCG inputs & outputs
    input [31:0] BCG_RS1,
    input [31:0] BCG_RS2,
    output logic BCG_BR_EQ,
    output logic BCG_BR_LT,
    output logic BCG_BR_LTU
    );
    
    always_comb begin
        if (BCG_RS1 == BCG_RS2) // Check if branch equal
            BCG_BR_EQ = 1;
        else
            BCG_BR_EQ = 0;
        
        if ($signed(BCG_RS1) < $signed(BCG_RS2)) // Check if branch less than signed
            BCG_BR_LT = 1;
        else
            BCG_BR_LT = 0;
        
        if (BCG_RS1 < BCG_RS2) // Check if branch less than unsigned
            BCG_BR_LTU = 1;
        else
            BCG_BR_LTU = 0;  
    end
endmodule
