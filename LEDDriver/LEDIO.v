`timescale 1ns / 1ps
/////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.03.2024 14:00:35
// Design Name: 
// Module Name: LEDIO
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
module LEDIO (
    input         CLK,
    input         RESET,
    //BUS
    inout  [ 7:0] BUS_DATA,
    input  [ 7:0] BUS_ADDR,
    input         BUS_WE,
    //OUT
    output [15:0] LED_OUT

); 
 

  // Register bank, holds device state
  reg [7:0] regBank[1:0];

  // Tristate
  wire [7:0] BufferedBusData;
  reg [7:0] DataBusOut;
  reg DataBusOutWE;
 


  // The register bank is effectively an extension of Data memory. The Base address below 
  // corresponds to regBank[0]
  parameter BaseAddr = 8'hC0;

  // Only place data on the bus if processor is not writing, and address is within range
  assign BUS_DATA = (DataBusOutWE) ? DataBusOut : 8'hZZ;

  //Buffer 
  assign BufferedBusData = BUS_DATA;
 
  always @(posedge CLK) begin

    if (RESET) begin
      DataBusOutWE <= 1'b0;
      regBank[0]   <= 8'h0; 
      regBank[1]   <= 8'h0;
    end else begin
      if ((BUS_ADDR >= BaseAddr) & (BUS_ADDR < (BaseAddr + 2))) begin
        if (BUS_WE) begin
          DataBusOutWE <= 1'b0;
          regBank[BUS_ADDR-BaseAddr] <= BufferedBusData;
        end else DataBusOutWE <= 1'b1;
      end else DataBusOutWE <= 1'b0;
    end
    DataBusOut <= regBank[BUS_ADDR-BaseAddr];
  end

  assign LED_OUT = {regBank[1], regBank[0]};

endmodule


