`timescale 1ns / 1ps
/////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.03.2024 14:00:35
// Design Name: 
// Module Name: NegEdgeDetector
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
module NegEdgeDetector (
    input CLK,
    input RESET,

    // Button
    input IN,
    output OUT
);

  wire db_btn;
  reg db_btn_dly;
  reg out;

  BtnDebounce btnDeb (
      .CLK(CLK),
      .RESET(RESET),
      .BTN(IN),
      .DB_BTN(db_btn)
  );

  always@(posedge CLK) begin
    if (RESET)
      out <= 0;
    else begin
        // Detect negative edge
        if (~db_btn & db_btn_dly) out <= 1;
        else out <= 0;
        
        // Update the delayed input.
        db_btn_dly <= db_btn;
    end
  end

  assign OUT = out;
endmodule