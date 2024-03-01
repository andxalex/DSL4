`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.01.2024 11:00:55
// Design Name: 
// Module Name: Mux_4
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


module Mux_4(
    input [4:0] IN_A,
    input [4:0] IN_B,
    input [4:0] IN_C,
    input [4:0] IN_D,
    input [1:0] CTRL,
    output reg [4:0] OUT
    );
    
    always@(    IN_A    or
                IN_B    or
                IN_C    or
                IN_D    or
                CTRL
                )
    begin
        case(CTRL)
            2'b00   :   OUT <= IN_A;
            2'b01   :   OUT <= IN_B;
            2'b10   :   OUT <= IN_C;
            2'b11   :   OUT <= IN_D;
            default :   OUT <= 5'b00000;
        endcase
    end
endmodule
