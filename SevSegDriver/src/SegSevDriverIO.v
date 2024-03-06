`timescale 1ns / 1ps

module SegSevDriverIO (
    input        CLK,
    input        CLK2,
    input        RESET,
    //BUS
    inout  [7:0] BUS_DATA,
    input  [7:0] BUS_ADDR,
    input        BUS_WE,
    //OUT
    output [3:0] SEG_SELECT,
    output [7:0] DEC_OUT,

    output [7:0] DIGIT
);

  // wires
  wire [7:0] dec_out;
  wire [3:0] seg_select;

  // Register bank, holds device state
  reg [7:0] regBank[5:0];

  //Instantiate 7 seg display
  Seg7Display S7 (
      .IN_A(regBank[0][4:0]),
      .IN_B(regBank[1][4:0]),
      .IN_C(regBank[2][4:0]),
      .IN_D(regBank[3][4:0]),
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
  reg [7:0] test;
  reg godhelpme;
  always @(posedge CLK2) begin
    if (RESET) begin
      // If reset, re-init regbank to 0.
      godhelpme <= 0;
      test <= 8'hF0;
      DataBusOutWE <= 1'b0;
      for (i = 0; i < 6; i = i + 1) regBank[i] <= 8'h0;
    end else begin
      godhelpme  <= 1;
      regBank[4] <= dec_out;
      regBank[5] <= {4'h0, seg_select};
      if ((BUS_ADDR >= BaseAddr) & (BUS_ADDR < BaseAddr + 6)) begin
        // Only first 4 addresses are writable
        if (BUS_WE) begin
          DataBusOutWE <= 1'b0;
          if ((BUS_ADDR >= BaseAddr) & (BUS_ADDR < BaseAddr + 4)) begin
            regBank[BUS_ADDR-BaseAddr] <= {4'h0, BufferedBusData[3:0]};
            test <= 8'h01;
          end else test <= 8'h02;
        end else begin
          DataBusOutWE <= 1'b1;
          test <= 8'h03;
        end
      end else begin
        DataBusOutWE <= 1'b0;
        test <= 8'h04;
      end
      DataBusOut <= regBank[BUS_ADDR-BaseAddr];
    end
  end

  assign SEG_SELECT = seg_select;
  assign DEC_OUT = dec_out;

  assign DIGIT = {BUS_DATA[3:0], test[3:0]};
endmodule
