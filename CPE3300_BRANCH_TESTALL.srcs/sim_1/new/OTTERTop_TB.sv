`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/09/2026 03:57:51 PM
// Design Name: 
// Module Name: OTTERTop_TB
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


module OTTERTop_TB();

logic TB_RST, TB_INTR, TB_CLK, TB_IOBUS_WR;
logic [31:0] TB_IOBUS_IN, TB_IOBUS_OUT, TB_IOBUS_ADDR;

OTTERPLR_Top UUT(
    .RST(TB_RST),
    .INTR(TB_INTR),
    .IOBUS_IN(TB_IOBUS_IN),
    .CLK(TB_CLK),
    .IOBUS_WR(TB_IOBUS_WR),
    .IOBUS_OUT(TB_IOBUS_OUT),
    .IOBUS_ADDR(TB_IOBUS_ADDR)
);

// create 20ns clock for 50MHz
always begin
    TB_CLK = 0; #10;
    TB_CLK = 1; #10;
end

initial begin
    TB_RST = 1;
    TB_INTR = 0;
    TB_IOBUS_IN = 32'h00000000;

    #15 TB_RST = 0;
end

endmodule
