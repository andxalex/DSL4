`timescale 1ns / 1ps

module SegSevDriverIO (
    input        CLK,
    input        RESET,
    //BUS
    inout  [7:0] BUS_DATA,
    input  [7:0] BUS_ADDR,
    input        BUS_WE,
    //OUT
    output [3:0] SEG_SELECT,
    output [7:0] DEC_OUT
);

  // wires
  wire [7:0] dec_out;
  wire [3:0] seg_select;

  // Register bank, holds device input state
  reg [7:0] regBank[2:0];

  //Instantiate 7 seg display
  Seg7Display S7 (
      .IN_A({regBank[2][0], regBank[0][3:0]}),
      .IN_B({regBank[2][1], regBank[0][7:4]}),
      .IN_C({regBank[2][2], regBank[1][3:0]}),
      .IN_D({regBank[2][3], regBank[1][7:4]}),
      .CLK(CLK),
      .SEG_SELECT(seg_select),
      .DEC_OUT(dec_out)
  );

  // Tristate
  wire [7:0] BufferedBusData;
  reg [7:0] DataBusOut;
  reg DataBusOutWE;

  // The register bank is effectively an extension of Data memory. The Base address below 
  // corresponds to regBank[0]
  parameter BaseAddr = 8'hD0;

  // Only place data on the bus if processor is not writing, and address is within range
  assign BUS_DATA = (DataBusOutWE) ? DataBusOut : 8'hZZ;

  // Buffer 
  assign BufferedBusData = BUS_DATA;

  // dual port RAM (from the view of the processor)
  integer i;
  always @(posedge CLK) begin
    if (RESET) begin
      // If reset, re-init regbank to 0.
      DataBusOutWE <= 1'b0;
      for (i = 0; i < 3; i = i + 1) regBank[i] <= 8'h0;
    end else begin
      if ((BUS_ADDR >= BaseAddr) & (BUS_ADDR < BaseAddr + 3)) begin
        if (BUS_WE) begin
          DataBusOutWE <= 1'b0;
          regBank[BUS_ADDR-BaseAddr] <= BufferedBusData;
        end else DataBusOutWE <= 1'b1;
      end else DataBusOutWE <= 1'b0;

      DataBusOut <= regBank[BUS_ADDR-BaseAddr];
    end
  end

  assign SEG_SELECT = seg_select;
  assign DEC_OUT = dec_out;

endmodule
