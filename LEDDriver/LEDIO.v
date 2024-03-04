`timescale 1ns / 1ps

module LEDIO (
    input        CLK,
    input        RESET,
    //BUS
    inout  [7:0] BUS_DATA,
    input  [7:0] BUS_ADDR,
    input        BUS_WE,
    //OUT
    output [7:0] LED_OUT,

);

  
  // Register bank, holds device state
  reg [7:0] regBank;

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

    if(RESET) begin
        DataBusOutWE <= 1'b0;
        regBank <= 8'h0;
    end    

    if(BUS_ADDR == BaseAddr) begin

        if(BUS_WE) begin
             DataBusOutWE <= 1'b0;
            regBank <= BufferedBusData;

        end

        else DataBusOutWE <= 1'b1;

    end

    else DataBusOutWE <= 1'b0;

    DataBusOut <= regBank;

  end

endmodule

	
