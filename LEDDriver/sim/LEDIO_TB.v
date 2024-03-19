`timescale 1ns / 1ps
/////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.03.2024 14:00:35
// Design Name: 
// Module Name: LEDIO_TB
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
module LEDIO_TB;

  // Inputs
  reg         CLK;
  reg         RESET;
  reg         BUS_WE;
  reg  [ 7:0] busdata;
  reg  [ 7:0] busaddr;

  // Outputs and inout shenanigans
  wire [ 7:0] BUSDATA;
  wire [ 7:0] BUSADDR;
  wire [15:0] LEDOUT;

  // Further inout shenanigans
  assign BUSADDR = busaddr;
  assign BUSDATA = dut.DataBusOutWE ? 8'hzz : (BUS_WE ? busdata : 8'hzz);

  LEDIO dut (
      .CLK(CLK),
      .RESET(RESET),
      .BUS_DATA(BUSDATA),
      .BUS_ADDR(BUSADDR),
      .BUS_WE(BUS_WE),
      .LED_OUT(LEDOUT)
  );

  initial begin
    CLK = 0;
    forever #5 CLK = ~CLK;
  end

  initial begin
    RESET = 1;
    #100 RESET = 0;
    #5000 $stop;
  end

  initial begin
    busdata = 8'h0;
    busaddr = 8'h0;
    BUS_WE  = 0;
    #1000

    // VALIDATE WRITE
    // Write value to right register bank and validate
    busdata = 8'h0F;
    busaddr = 8'hC0;
    BUS_WE  = 1;
    #10  // Wait a single cycle and lower
    busdata = 8'h00;
    busaddr = 8'h00;
    BUS_WE  = 0;
    // Validate output one cycle after writing
    if (LEDOUT[7:0] == 8'h0F) $display("Write to right register bank executed correctly");
    else $display("Error in right register bank, %m: LED_OUT[7:0] != 8'h0F");
    $display("  - Writing LEDS 0 to 7, expected: 0x%0h got: 0x%0h", 8'h0F, LEDOUT[7:0]);
    #1000

    // Write value to left register bank and validate
    busdata = 8'hF0;
    busaddr = 8'hC1;
    BUS_WE  = 1;
    #10  // Wait a single cycle and lower
    busdata = 8'h00;
    busaddr = 8'h00;
    BUS_WE  = 0;
    // Validate output one cycle after writing
    if (LEDOUT[15:8] == 8'hF0) $display("Write to left register bank executed correctly");
    else $display("Error in left register bank, %m: LED_OUT[15:8] != 8'hF0");
    $display("  - Writing LEDS 15 to 8, expected: 0x%0h got: 0x%0h", 8'hF0, LEDOUT[15:8]);
    #1000

    // VALIDATE READ
    // Read value from right register bank and validate
    busaddr = 8'hC0;
    #10  // Wait a single and verify
    if (BUSDATA == 8'h0F) $display("Read from right register bank executed correctly");
    else $display("Error in reading right register bank, %m: BUSDATA != 8'h0F");
    $display("  - Reading LEDS 7 to 0, expected 0x%0h got 0x%0h", 8'h0F, BUSDATA);
    // Lower after verifying
    busaddr = 8'h00;
    #1000;

    // Read value from left register bank and validate
    busaddr = 8'hC1;
    #10  // Wait a single and verify
    if (BUSDATA == 8'hF0) $display("Read from left register bank executed correctly");
    else $display("Error in reading left register bank, %m: BUSDATA != 8'hF0");
    $display("  - Reading LEDS 15 to 8, expected 0x%0h got 0x%0h", 8'hF0, BUSDATA);
    // Lower after verifying
    busaddr = 8'h00;
    #1000;
  end
endmodule
