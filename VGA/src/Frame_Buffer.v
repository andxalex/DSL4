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
This module is the frame buffer. It stores the information of the colour of every
pixel to be displayed in a memory.
*/
//////////////////////////////////////////////////////////////////////////////////

module Frame_Buffer (
  /// Port A - Read/Write, Inputs
  input             A_CLK,       // has to be synchronized to the clock of the Microprossesor
  input      [14:0] A_ADDR,      // 8 + 7 bits = 15 bits hence [14:0]
  input             A_DATA_IN,   // Pixel Data In, which determines the colour on the screen
  
  input             A_WE,        // Write Enable
  //Port B - Read Only
  input             B_CLK,       //Syncrhonized to appropriate VGA speed 25 MHz
  input      [14:0] B_ADDR,      // Pixel Data Out
  


  //Outputs
  output reg        A_DATA_OUT,
  output reg        B_DATA
);
//////////////////////////////////////////////////////////////////////////////////

// A 256 x 128 1-bit memory to hold frame data
//The LSBs of the address correspond to the X axis, and the MSBs to the Y axis

reg [0:0] Mem[2**15-1:0];
//////////////////////////////////////////////////////////////////////////////////


// Port A - Read/Write e.g. to be used by microprocessor
always @(posedge A_CLK) begin

      if (A_WE)
      
          Mem[A_ADDR] <= A_DATA_IN;
          
      A_DATA_OUT <= Mem[A_ADDR];

end
//////////////////////////////////////////////////////////////////////////////////

// Port B - Read Only e.g. to be read from the VGA signal generator module for display

always @(posedge B_CLK) begin

  B_DATA <= Mem[B_ADDR];
  
end

//////////////////////////////////////////////////////////////////////////////////
 
endmodule