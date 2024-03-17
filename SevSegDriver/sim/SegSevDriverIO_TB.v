`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Andreas Alexandrou
// 
// Create Date: 17.03.2024 16:56:16
// Design Name: 
// Module Name: SegSevDriverIO_TB.v
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

module SegSevDriverIO_TB;

  // Inputs
  reg        CLK;
  reg        RESET;
  reg        BUS_WE;
  reg  [7:0] busdata;
  reg  [7:0] busaddr;

  // inout shenanigans
  wire [7:0] BUS_DATA;
  wire [7:0] BUS_ADDR;
  wire [7:0] REG_BANK [2:0];

  // Further inout shenanigans
  assign BUS_ADDR = busaddr;
  assign BUS_DATA = dut.DataBusOutWE ? 8'hzz : (BUS_WE ? busdata : 8'hzz);

  SegSevDriverIO dut (
      .CLK(CLK),
      .RESET(RESET),
      .BUS_DATA(BUS_DATA),
      .BUS_ADDR(BUS_ADDR),
      .BUS_WE(BUS_WE)

      // Dont really care about these two, we will check 
      // the internal registers to validate instead.
      //.SEG_SELECT(SEG_SELECT),
      //.DEC_OUT(DEC_OUT)
  );

  // Get internal register bank
  assign REG_BANK[0] = dut.regBank[0];
  assign REG_BANK[1] = dut.regBank[1];
  assign REG_BANK[2] = dut.regBank[2];

  initial begin
    CLK = 0;
    forever #5 CLK = ~CLK;
  end

  initial begin
    RESET = 1;
    #100 RESET = 0;
    #7000 $stop;
  end

  initial begin
    busdata = 8'h0;
    busaddr = 8'h0;
    BUS_WE  = 0;
    #1000

    // VALIDATE WRITE
    // Write value to right register bank and validate
    busdata = 8'h0F;
    busaddr = 8'hD0;
    BUS_WE  = 1;
    #10  // Wait a single cycle and lower
    busdata = 8'h00;
    busaddr = 8'h00;
    BUS_WE  = 0;
    // Validate output one cycle after writing
    if (REG_BANK[0] == 8'h0F) $display("Write to right register bank executed correctly");
    else $display("Error in right register bank, %m: REG_BANK[0] != 8'h0F");
    $display("  - Writing digits 1 and 0, expected: 0x%0h got: 0x%0h", 8'h0F, REG_BANK[0]);
    #1000

    // Write value to left register bank and validate
    busdata = 8'hF0;
    busaddr = 8'hD1;
    BUS_WE  = 1;
    #10  // Wait a single cycle and lower
    busdata = 8'h00;
    busaddr = 8'h00;
    BUS_WE  = 0;
    // Validate output one cycle after writing
    if (REG_BANK[1] == 8'hF0) $display("Write to left register bank executed correctly");
    else $display("Error in right register bank, %m: REG_BANK[1] != 8'hF0");
    $display("  - Writing digits 3 and 2, expected: 0x%0h got: 0x%0h", 8'hF0, REG_BANK[1]);
    #1000

    // Write value to DOTS and validate
    busdata = 8'h0F;
    busaddr = 8'hD2;
    BUS_WE  = 1;
    #10  // Wait a single cycle and lower
    busdata = 8'h00;
    busaddr = 8'h00;
    BUS_WE  = 0;
    // Validate output one cycle after writing
    if (REG_BANK[2] == 8'h0F) $display("Write to DOT register bank executed correctly");
    else $display("Error in DOT register bank, %m: REG_BANK[2] != 8'h0F");
    $display("  - Writing DOTS, expected: 0x%0h got: 0x%0h", 8'h0F, REG_BANK[2]);
    #1000

    // VALIDATE READ
    // Read value from right register bank and validate
    busaddr = 8'hD0;
    #10  // Wait a single and verify
    if (BUS_DATA == 8'h0F) $display("Read from right register bank executed correctly");
    else $display("Error in reading right register bank, %m: BUS_DATA != 8'h0F");
    $display("  - Reading digits 1 and 0, expected: 0x%0h got: 0x%0h", 8'h0F, BUS_DATA);
    // Lower after verifying
    busaddr = 8'h00;
    #1000;

    // Read value from left register bank and validate
    busaddr = 8'hD1;
    #10  // Wait a single and verify
    if (BUS_DATA == 8'hF0) $display("Read from left register bank executed correctly");
    else $display("Error in reading left register bank, %m: BUS_DATA != 8'hF0");
    $display("  - Reading digits 3 and 2, expected: 0x%0h got: 0x%0h", 8'hF0, BUS_DATA);
    // Lower after verifying
    busaddr = 8'h00;
    #1000;

    // Read value from DOT register bank and validate
    busaddr = 8'hD2;
    #10  // Wait a single and verify
    if (BUS_DATA == 8'h0F) $display("Read from left register bank executed correctly");
    else $display("Error in reading left register bank, %m: BUS_DATA != 8'h0F");
    $display("  - Reading DOTS, expected: 0x%0h got: 0x%0h", 8'h0F, BUS_DATA);
    // Lower after verifying
    busaddr = 8'h00;
    #1000;
  end
endmodule
