`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.01.2024 14:00:35
// Design Name: 
// Module Name: VGA_top_wrapper
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
/*
This is the top wrapper of the VGA interface. It connects the Frame buffer and the
VGA signal generator modules. All of the inputs will be coming from the microprocessor,
which will contain information about the addresses and the colours of each pixel. The
outputs of the module going to the VGA screen.
*/

//////////////////////////////////////////////////////////////////////////////////


module VGA_top_wrapper (

    //Global  
    input               CLK,           // System clock
    input               RESET,         // System reset
    
    //Inputs from proccesor
    input      [14:0]   A_ADDR,
    input               A_DATA_IN,
    input               A_WE,
    input      [15:0]   CONFIG_COLOURS_IN,
  
    //Outputs to VGA
    output              A_DATA_OUT,
    output              VGA_HS,
    output              VGA_VS,
    output     [7:0]    VGA_COLOUR
  
);

//////////////////////////////////////////////////////////////////////////////////

    wire                B_DATA;
    wire                VGA_DATA;

   // Frame Buffer (Dual Port memory) Interface
    wire                DPR_CLK;
    wire       [14:0]   VGA_ADDR;
   
//////////////////////////////////////////////////////////////////////////////////
   
  
   // Instantiate Frame_Buffer and VGA_Sig_Gen modules
     Frame_Buffer frame_buffer (
       .A_CLK(CLK),
       .A_ADDR(A_ADDR),
       .A_DATA_IN(A_DATA_IN),
       .A_WE(A_WE),
       .B_CLK(DPR_CLK),
       .B_ADDR(VGA_ADDR),
       .A_DATA_OUT(A_DATA_OUT),
       .B_DATA(B_DATA)
     );
   
//////////////////////////////////////////////////////////////////////////////////
   
     VGA_Sig_Gen vga_sig_gen (
       .CLK(CLK),
       .RESET(RESET),
       .CONFIG_COLOURS(CONFIG_COLOURS_IN),
       .VGA_DATA(B_DATA),
       .DPR_CLK(DPR_CLK),
       .VGA_ADDR(VGA_ADDR),
       .VGA_HS(VGA_HS),
       .VGA_VS(VGA_VS),
       .VGA_COLOUR(VGA_COLOUR)
     );
////////////////////////////////////////////////////////////////////////////////// 
endmodule

         