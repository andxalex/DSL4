`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Andreas Alexandrou
// 
// Create Date: 17.03.2024 16:56:16
// Design Name: 
// Module Name: MouseDriverIO_TB.v
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

module MouseDriverIO_TB;

  // Inputs
  reg        CLK;
  reg        RESET;
  reg  [7:0] busdata;
  reg  [7:0] busaddr;
  reg        mouseclk;
  reg        mousedata;
  reg        INT_ACK;
  reg        BUS_WE;


  // inout shenanigans
  // Mouse
  wire       CLK_MOUSE;
  wire       DATA_MOUSE;
  wire       SEND_INT;
  wire       INT_RAISE;
  wire [6:0] MSM_STATE;

  // RAM Bus
  wire [7:0] BUS_DATA;
  wire [7:0] BUS_ADDR;

  // Monitor internal register bank
  wire [7:0] REG_BANK   [2:0];


  // Further inout shenanigans
  assign BUS_ADDR   = busaddr;
  assign BUS_DATA   = dut.DataBusOutWE ? 8'hzz : (BUS_WE ? busdata : 8'hzz);
  assign CLK_MOUSE  = dut.TR.ClkMouseOutEnTrans ? 1'bz : mouseclk;
  assign DATA_MOUSE = dut.TR.DataMouseOutEnTrans ? 1'bz : mousedata;

  MouseDriverIO dut (
      .CLK(CLK),
      .RESET(RESET),
      .BUS_DATA(BUS_DATA),
      .BUS_ADDR(BUS_ADDR),
      .BUS_WE(BUS_WE),
      .CLK_MOUSE(CLK_MOUSE),
      .DATA_MOUSE(DATA_MOUSE),
      .BUS_INTERRUPT_RAISE(INT_RAISE),
      .BUS_INTERRUPT_ACK(INT_ACK),
      .SEND_INTERRUPT(SEND_INT)
  );

  // Get internal register bank, and MSM state
  assign REG_BANK[0] = dut.regBank[0];
  assign REG_BANK[1] = dut.regBank[1];
  assign REG_BANK[2] = dut.regBank[2];
  assign MSM_STATE   = dut.TR.MSM.Curr_State;

  initial begin
    CLK = 0;
    forever #5 CLK = ~CLK;
  end

  // More dummy variables to simulate device
  integer i;
  integer j;
  reg [10:0] PacketToSend;


  // Overwrite some variables for the purposes of the Simulation
  always @* begin
    // Dont wait for timer
    if (dut.TR.MSM.Curr_State == 7'd0) dut.TR.MSM.Next_State = 7'd1;

    // Small hack to overwrite internal state, and skip intellimouse
    // and explorer mode initialisation
    if (dut.TR.MSM.Curr_State == 7'd8) begin
      if (dut.TR.MSM.Next_State == 7'd9) begin
        dut.TR.MSM.Next_State = 7'd53;
      end
    end

  end

  initial begin
    // Init and RESET
    RESET     = 1;
    busdata   = 8'h0;
    busaddr   = 8'h0;
    mouseclk  = 1'b0;
    mousedata = 1'b0;
    BUS_WE    = 0;
    #100 RESET = 0;

    // Wait for host to initialise
    #100000

    // Host Transmit FF 
    for (
        i = 0; i < 22; i = i + 1
    )
    #40000 mouseclk = ~mouseclk;
    #105 mouseclk = 0;
    mousedata = 0;
    #40000;
    mouseclk  = 1;
    mousedata = 1;
    #40000;

    // Device Transmit FA
    PacketToSend = {1'b1, 1'b1, 8'hFA, 1'b0};
    for (i = 0; i < 11; i = i + 1) begin
      mousedata = PacketToSend[0];
      PacketToSend = {1'b0, PacketToSend[10:1]};
      for (j = 0; j < 2; j = j + 1) begin
        #40000 mouseclk = ~mouseclk;
      end
    end

    // Device Transmit AA
    mouseclk = 1;
    #40000;
    PacketToSend = {1'b1, 1'b1, 8'hAA, 1'b0};
    for (i = 0; i < 11; i = i + 1) begin
      mousedata = PacketToSend[0];
      PacketToSend = {1'b0, PacketToSend[10:1]};
      for (j = 0; j < 2; j = j + 1) begin
        #40000 mouseclk = ~mouseclk;
      end
    end

    // Device Transmit 00
    mouseclk = 1;
    #40000;
    PacketToSend = {1'b1, 1'b1, 8'h00, 1'b0};
    for (i = 0; i < 11; i = i + 1) begin
      mousedata = PacketToSend[0];
      PacketToSend = {1'b0, PacketToSend[10:1]};
      for (j = 0; j < 2; j = j + 1) begin
        #40000 mouseclk = ~mouseclk;
      end
    end

    // Host Transmit F4
    #100000;
    mouseclk = 1'b0;

    for (i = 0; i < 22; i = i + 1) begin
      #40000 mouseclk = ~mouseclk;
    end

    // Bring CLK, DATA LOW, THEN RELEASE
    #105 mouseclk = 0;
    mousedata = 0;
    #40000;
    mouseclk  = 1;
    mousedata = 1;
    #40000;

    // Device Transmit FA
    PacketToSend = {1'b1, 1'b1, 8'hFA, 1'b0};
    for (i = 0; i < 11; i = i + 1) begin
      mousedata = PacketToSend[0];
      PacketToSend = {1'b0, PacketToSend[10:1]};
      for (j = 0; j < 2; j = j + 1) begin
        #40000 mouseclk = ~mouseclk;
      end
    end

    // Device Transmit Status
    mouseclk = 1;
    #40000;
    PacketToSend = {1'b1, 1'b1, 8'h0A, 1'b0};
    for (i = 0; i < 11; i = i + 1) begin
      mousedata = PacketToSend[0];
      PacketToSend = {1'b0, PacketToSend[10:1]};
      for (j = 0; j < 2; j = j + 1) begin
        #40000 mouseclk = ~mouseclk;
      end
    end

    // Device Transmit X
    mouseclk = 1;
    #40000;
    PacketToSend = {1'b1, 1'b1, 8'h28, 1'b0};
    for (i = 0; i < 11; i = i + 1) begin
      mousedata = PacketToSend[0];
      PacketToSend = {1'b0, PacketToSend[10:1]};
      for (j = 0; j < 2; j = j + 1) begin
        #40000 mouseclk = ~mouseclk;
      end
    end

    // Device Transmit Y
    mouseclk = 1;
    #40000;
    PacketToSend = {1'b1, 1'b1, 8'h1E, 1'b0};
    for (i = 0; i < 11; i = i + 1) begin
      mousedata = PacketToSend[0];
      PacketToSend = {1'b0, PacketToSend[10:1]};
      for (j = 0; j < 2; j = j + 1) begin
        #40000 mouseclk = ~mouseclk;
      end
    end

    // Mouse initialisation has finished, can now read registers
    // VALIDATE READ
    // Read value from right register bank and validate
    busaddr = 8'hA0;
    #10  // Wait a single and verify
    if (BUS_DATA == 8'd10) $display("Read from right register bank executed correctly");
    else $display("Error in reading first register bank, %m: BUS_DATA != 8'd10");
    $display("  - Reading Status, expected: %0d got: %0d", 8'd10, BUS_DATA);
    // Lower after verifying
    busaddr = 8'h00;
    #1000;

    // Read value from left register bank and validate
    busaddr = 8'hA1;
    #10  // Wait a single and verify
    if (BUS_DATA == 8'd120) $display("Read from left register bank executed correctly");
    else $display("Error in reading second register bank, %m: BUS_DATA != 8'd120");
    $display("  - Reading X, expected: %0d got: %0d", 8'd120, BUS_DATA);
    // Lower after verifying
    busaddr = 8'h00;
    #1000;

    // Read value from DOT register bank and validate
    busaddr = 8'hA2;
    #10  // Wait a single and verify
    if (BUS_DATA == 8'd90) $display("Read from left register bank executed correctly");
    else $display("Error in reading third register bank, %m: BUS_DATA != 8'd90");
    $display("  - Reading Y, expected: %0d got: %0d", 8'd90, BUS_DATA);
    // Lower after verifying
    busaddr = 8'h00;
    #1000;

    // Stop after finalising program flow
    $stop;
  end
endmodule
