`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/06/2026 09:01:45 PM
// Design Name: 
// Module Name: ProgROM_TB
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


module ProgROM_TB();

logic [31:0] TB_ADDR, TB_INSTRUCT;

ProgROM UUT(
    .PROG_ADDR(TB_ADDR),
    .INSTRUCT(TB_INSTRUCT)
);

initial begin
    // Check if machine instr are loaded in order
    TB_ADDR = 32'h00000000;
    #20 TB_ADDR += 32'h4;
    #20 TB_ADDR += 32'h4;
    #20 TB_ADDR += 32'h4;
    #20 TB_ADDR += 32'h4;
    #20 TB_ADDR += 32'h4;
    #20 TB_ADDR += 32'h4;
    
    // Invalid output case
    #20 TB_ADDR += 32'h4;

    #20
    $finish;
end

endmodule
