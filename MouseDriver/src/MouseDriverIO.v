`timescale 1ns / 1ps

module MouseDriverIO (
    input        CLK,
    input        RESET,
    // CTRL 
    input        INC_SENS,
    input        RED_SENS,
    // BUS
    inout  [7:0] BUS_DATA,
    input  [7:0] BUS_ADDR,
    input        BUS_WE,
    // MOUSE
    inout        CLK_MOUSE,
    inout        DATA_MOUSE,
    // INTERRUPT
    output       BUS_INTERRUPT_RAISE,
    input        BUS_INTERRUPT_ACK,

    // Additional
    output [7:0] X,
    output [7:0] Y
);

  wire [5:0] status_mouse;
  wire [7:0] x_mouse;
  wire [7:0] y_mouse;
  wire [2:0] z_mouse;

  // Additional
  assign X = x_mouse;
  assign Y = regBank[3];

  // Additional wires
  wire [6:0] MSM_state;
  wire intellimouse;
  wire explorer;
  wire [1:0] sensitivity;
  wire [4:0] x;
  wire [4:0] y;
  wire SendInterrupt;

  // Instantiate mouse transceiver
  MouseTransceiver TR (
      .RESET(RESET),
      .CLK(CLK),
      .INC_SENS(INC_SENS),
      .RED_SENS(RED_SENS),
      .CLK_MOUSE(CLK_MOUSE),
      .DATA_MOUSE(DATA_MOUSE),
      .MouseStatus(status_mouse),
      .MouseX(x_mouse),
      .MouseY(y_mouse),
      .MouseZ(z_mouse),

      // Additional outputs
      .MSM_STATE(MSM_state),
      .INTELLIMOUSE(intellimouse),
      .EXPLORER(explorer),
      .SENSITIVITY(sensitivity),
      .ACCUM_X(x),
      .ACCUM_Y(y),
      .SEND_INTERRUPT(SendInterrupt)
  );

  ///////////////////////////////////////////////////////////////////////////////////////
  // Set Interrupt IO
  reg InterruptState;
  always @(posedge CLK) begin
    if (RESET) InterruptState = 0;
    else begin
      if (SendInterrupt) InterruptState = 1;
      else if (BUS_INTERRUPT_ACK) InterruptState = 0;
    end
  end
  assign BUS_INTERRUPT_RAISE = InterruptState;


  ///////////////////////////////////////////////////////////////////////////////////////
  // Tristate
  wire [7:0] BufferedBusData;
  reg [7:0] DataBusOut;
  reg DataBusOutWE;

  // Register bank, holds device state.
  reg [7:0] regBank[7:0];

  // The above block is effectively an extension of Data memory. The Base address below 
  // corresponds to regBank[0]
  parameter BaseAddr = 8'hA0;

  // Only place data on the bus if processor is not writing, and address is within range
  assign BUS_DATA = (DataBusOutWE) ? DataBusOut : 8'hZZ;

  // Buffer 
  assign BufferedBusData = BUS_DATA;

  // dual port RAM (from the view of the processor)
  integer i;
  always @(posedge CLK) begin
    if (RESET) begin
      DataBusOutWE <= 1'b0;
      for (i = 0; i < 8; i = i + 1) regBank[i] <= 0'h00;
    end else begin
      regBank[2] <= {2'b00, status_mouse};
      regBank[3] <= x_mouse;
      regBank[4] <= y_mouse;
      regBank[5] <= z_mouse;
      regBank[6] <= {1'b0, intellimouse, explorer, x};
      regBank[7] <= {1'b0, sensitivity, y};

      if ((BUS_ADDR >= BaseAddr) & (BUS_ADDR < BaseAddr + 8)) begin
        // Only first 2 addresses are writable
        if (BUS_WE) begin
          DataBusOutWE <= 1'b0;
          if ((BUS_ADDR >= BaseAddr) & (BUS_ADDR < BaseAddr + 2)) begin
            regBank[BUS_ADDR-BaseAddr] <= BufferedBusData;
          end
        end else DataBusOutWE <= 1'b1;
      end else DataBusOutWE <= 1'b0;

      DataBusOut <= regBank[BUS_ADDR-BaseAddr];
    end
  end
endmodule
