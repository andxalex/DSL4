`timescale 1ns / 1ps
/////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.03.2024 14:00:35
// Design Name: 
// Module Name: Timer_TB
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
module BtnDebounce (
    input CLK,
    input RESET,

    // Button
    input BTN,
    output DB_BTN
);

  // Output generated after 2 ** width cycles
  parameter width = 17;

  // Counting starts after shift reg is filled.
  reg [width - 1:0] shift_reg;
  reg [width - 1:0] deb_counter;

  reg db_btn;

  always@(posedge CLK) begin
    if (RESET) begin
        shift_reg <= 0;
        deb_counter <= 0;
    end else begin
      shift_reg <= {shift_reg[width - 2:0], BTN};

      // Start counting after shift reg is filled
      if (BTN == shift_reg[width - 1])
        deb_counter <= deb_counter + 1;
      else    
        deb_counter <= 0;
    end
  end

  always@(posedge CLK) begin
    if (RESET)
        db_btn <= 0;
    else if (deb_counter == (1 << width - 1))
        db_btn <= shift_reg[width - 1]; 
  end

  assign DB_BTN = db_btn;
endmodule