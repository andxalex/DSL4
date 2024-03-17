`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
module Timer_TB;

  reg CLK;
  reg RESET;
  reg InterruptACK;

  wire Interrupt = dut.Interrupt;
  wire [31:0] DownCounter = dut.DownCounter;
  wire [31:0] Timer = dut.Timer;

  Timer dut (
      .CLK(CLK),
      .RESET(RESET),
      .BUS_INTERRUPT_ACK(InterruptACK)
  );

  initial begin
    CLK = 0;
    forever #5 CLK = ~CLK;
  end

  initial begin
    RESET = 1;
    #100 RESET = 0;
    #10000000 $stop;
  end

  // Acknowledge interrupt immediately to continue triggering
  always @(posedge CLK) begin
    if (Interrupt) InterruptACK <= 1;
    else InterruptACK <= 0;
  end
endmodule
