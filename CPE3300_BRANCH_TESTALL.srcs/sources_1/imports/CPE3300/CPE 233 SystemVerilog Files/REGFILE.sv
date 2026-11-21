`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Daniel Huang
//           VT Vo
// 
// Create Date: 04/21/2026 04:23:38 PM
// Design Name: 
// Module Name: REGFILE
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


module REGFILE(
    // Define RF inputs & outputs
    input RF_CLK,
    input RF_EN,
    input [31:0] RF_IR,
    input [4:0] RF_WA,
    input [31:0] RF_WD,
    output logic [31:0] RF_RS1,
    output logic [31:0] RF_RS2
    );

    // Split IR into ADR1 and ADR2
    logic [4:0] RF_ADR1;
    logic [4:0] RF_ADR2;
    assign RF_ADR1 = RF_IR[19:15];
    assign RF_ADR2 = RF_IR[24:20];

    logic [31:0] ram [0:31]; // 32 32-bit registers
    
    initial begin
        for (int i = 0; i < 32; i++) begin // for loop
            ram[i] = 0;
        end
    end
    
    // MOD: RF is written to on falling edge of CLK
    always_ff @(negedge RF_CLK) begin // synchronous write block
        if (RF_EN) begin
            if (RF_WA == 5'b00000)
                ram[RF_WA] <= 0;
            else
                ram[RF_WA] <= RF_WD;
        end
    end
    
    always_comb begin // asynchronous read block
        RF_RS1 = ram[RF_ADR1];
        RF_RS2 = ram[RF_ADR2];
    end
endmodule
