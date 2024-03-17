`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
module LEDDriver_TB;

  // Inputs
  reg         CLK;
  reg         RESET;
  reg         BUS_WE;
  reg  [ 7:0] busdata;
  reg  [ 7:0] busaddr;

  // Outputs and inout shenanigans
  wire [ 7:0] BUS_DATA;
  wire [ 7:0] BUS_ADDR;
  wire [15:0] LED_OUT;

  // Further inout shenanigans
  assign BUS_ADDR = busaddr;
  assign BUS_DATA = busdata;

  LEDIO dut (
      .CLK(CLK),
      .RESET(RESET),
      .BUS_DATA(BUS_DATA),
      .BUS_ADDR(BUS_ADDR),
      .BUS_WE(BUS_WE),
      .LED_OUT(LED_OUT)
  );

  initial begin
    CLK = 0;
    forever #5 CLK = ~CLK;
  end

  initial begin
    RESET = 1;
    #100 RESET = 0;
    #3000 $stop;
  end

  initial begin
    busdata = 8'h0;
    busaddr = 8'h0;
    BUS_WE = 0;
    #1000

    // Write value to left register bank and validate
    busdata = 8'h0F;
    busaddr = 8'hC0;
    BUS_WE = 1;
    #10  // Wait a single cycle and lower
    busdata = 8'h00;
    busaddr = 8'h00;
    BUS_WE = 0;
    // Validate output one cycle after writing
    if (LED_OUT[7:0] != 8'h0F) $display("Error in left register bank, %m: LED_OUT[7:0] != 8'hF0");
    else $display("Write to left register bank executed correctly");
    #1000

    // Write value to right register bank and validate
    busdata = 8'hF0;
    busaddr = 8'hC1;
    BUS_WE = 1;
    #10  // Wait a single cycle and lower
    busdata = 8'h00;
    busaddr = 8'h00;
    BUS_WE = 0;
    // Validate output one cycle after writing
    if (LED_OUT[15:8] != 8'hF0) $display("Error in right register bank, %m: LED_OUT[7:0] != 8'hF0");
    else $display("Write to right register bank executed correctly");
  end
endmodule
