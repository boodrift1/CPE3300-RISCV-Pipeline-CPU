`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/04/2026 03:50:24 PM
// Design Name: 
// Module Name: PCM_TB
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


module PCM_TB();

logic TB_RST, TB_WE, TB_CLK;
logic [1:0] TB_SEL;
logic [31:0] TB_JALR, TB_BRANCH, TB_JAL, TB_COUNT, TB_PLUS4;

PCM UUT(
    .PCM_RST(TB_RST),
    .PCM_WE(TB_WE),
    .PCM_CLK(TB_CLK),
    .PCM_SEL(TB_SEL),
    .PCM_JALR(TB_JALR),
    .PCM_BRANCH(TB_BRANCH),
    .PCM_JAL(TB_JAL),
    .PCM_COUNT(TB_COUNT),
    .PCM_PLUS4(TB_PLUS4)    
);

// create 20ns clock for 50MHz
always begin
    TB_CLK = 0; #10;
    TB_CLK = 1; #10;
end

// initialize
initial begin
    #20
    TB_RST = 1'b1;
    TB_WE = 1'b0;
    TB_SEL = 2'd0; 
    TB_JALR = 32'h0;
    TB_BRANCH = 32'h0;
    TB_JAL = 32'h0;
    
    #15 TB_RST = 1'b0;

    // test cases
    // test async reset & reset priority over we
    #20 TB_WE = 1'b1;
    #20 TB_RST = 1'b1;

    #20 TB_RST = 1'b0;
    #40;
    $finish;
end 

endmodule
