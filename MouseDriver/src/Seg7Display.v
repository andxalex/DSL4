`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.01.2024 11:01:54
// Design Name: 
// Module Name: Seg7Display
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


module Seg7Display(
    input [4:0] IN_A,
    input [4:0] IN_B,
    input [4:0] IN_C,
    input [4:0] IN_D,
    input CLK,
    output [3:0] SEG_SELECT,
    output [7:0] DEC_OUT
    );
    
    //multiplexer output
    wire[4:0] mux_out;
    
    //counter wires
    wire [1:0] strobe_count; //mux control input
    wire b17_trig_out;       //controls strobe count speed
    
    //17 bit counter to update display           
    Generic_counter # (.COUNTER_WIDTH(17),
                       .COUNTER_MAX(99999)
                       )
                       b17_counter (
                       .CLK(CLK),
                       .RESET(1'b0),
                       .ENABLE(1'b1),
                       .TRIG_OUT(b17_trig_out) 
                       );
    //2bit counter to display on 4 displays      
    Generic_counter # (.COUNTER_WIDTH(2),
                       .COUNTER_MAX(3)
                       )
                       strobe_counter (
                       .CLK(CLK),
                       .RESET(1'b0),
                       .ENABLE(b17_trig_out),
                       .COUNT(strobe_count) 
                       );
    //multiplexer to swap between displayed digits                   
    Mux_4 mux(.IN_A(IN_A),
              .IN_B(IN_B),
              .IN_C(IN_C),
              .IN_D(IN_D),
              .CTRL(strobe_count),
              .OUT(mux_out)
              );
              
    //decoder instantiation
    seg7decoder seg7(
       .SEG_SELECT_IN(strobe_count),
       .BIN_IN(mux_out[3:0]),
       .DOT_IN(mux_out[4]),
       .SEG_SELECT_OUT(SEG_SELECT),
       .HEX_OUT(DEC_OUT)
       );
endmodule
