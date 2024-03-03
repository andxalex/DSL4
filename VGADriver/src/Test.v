`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.01.2024 15:11:47
// Design Name: s
// Module Name: Test
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:s
// 
//////////////////////////////////////////////////////////////////////////////////
/*
This module is the wrapper of the whole design, whcih incldues the VGA interface
as well as the "simulated" microprocessor. The inputs come from the FPGA and the
oututs go directly to the VGA. Another output is also included in an LED ligth
which is the A_DATA_OUT signal. Lastly, a button is used for the enable signal.
The rest of the buttons are used to change the picture of cars.
*/

//////////////////////////////////////////////////////////////////////////////////
module Test(

    //Global  
    input               CLK,           // System clock
    input               RESET,         // System reset
    input               BTNL,         //controls he A_WE
    input [15:0]        CONFIG_COLOURS_IN,
    input               BTNR,
    input               BTNU,
    input               BTND,
    
    
    
    //Outputs to VGA
    output              A_DATA_OUT,
    output              VGA_HS,
    output              VGA_VS,
    output [7:0]        VGA_COLOUR
    );
//////////////////////////////////////////////////////////////////////////////////
     
     wire  [14:0]       A_ADDR;
     wire               A_DATA_IN;   
     wire  [15:0]       CONFIG_COLOURS_OUT;

//////////////////////////////////////////////////////////////////////////////////
    
    Outside_module outside_inst (
      .CLK(CLK),
      .RESET(RESET),
      .BTNR(BTNR),
      .BTNU(BTNU),
      .BTND(BTND),
      .A_ADDR(A_ADDR),
      .A_DATA_IN(A_DATA_IN)
    );
//////////////////////////////////////////////////////////////////////////////////
    
    VGA_top_wrapper vga_top_inst (
      .CLK(CLK),
      .RESET(RESET),
      .A_ADDR(A_ADDR),
      .A_DATA_IN(A_DATA_IN),
      .A_WE(BTNL),
      .CONFIG_COLOURS_IN(CONFIG_COLOURS_OUT),
      .A_DATA_OUT(A_DATA_OUT),
      .VGA_HS(VGA_HS),
      .VGA_VS(VGA_VS),
      .VGA_COLOUR(VGA_COLOUR)
    );
//////////////////////////////////////////////////////////////////////////////////

    Colour_module color_inst(
    .CLK(CLK),
    .RESET(RESET),
    .CONFIG_COLOURS_IN(CONFIG_COLOURS_IN),
    .CONFIG_COLOURS_OUT(CONFIG_COLOURS_OUT) 
    );

 //////////////////////////////////////////////////////////////////////////////////
   
endmodule
