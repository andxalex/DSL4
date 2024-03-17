`timescale 1ns / 1ps

module MouseDriverIO (
    input        CLK,
    input        RESET,
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
    output SEND_INTERRUPT
);

  wire [5:0] status_mouse;
  wire [7:0] x_mouse;
  wire [7:0] y_mouse;
  wire [2:0] z_mouse;



  // Additional wires
  wire [6:0] MSM_state;
  wire intellimouse;
  wire explorer;
  wire [1:0] sensitivity;
  wire [4:0] x;
  wire [4:0] y;
  wire SendInterrupt;

  assign SEND_INTERRUPT = SendInterrupt;

  wire inc_sens;
  wire dec_sens;
  wire [2:0] resolution;
  // Instantiate mouse transceiver
  MouseTransceiver TR (
      .RESET(RESET),
      .CLK(CLK),
      .INC_SENS(inc_sens),
      .RED_SENS(dec_sens),
      .RESOLUTION(resolution),
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
  reg [7:0] regBank[6:0];

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
      for (i = 0; i < 7; i = i + 1) regBank[i] <= 0'h00;
    end else begin
      regBank[0] <= {2'b00, status_mouse};
      regBank[1] <= x_mouse;
      regBank[2] <= y_mouse;
      regBank[3] <= z_mouse;
      regBank[4] <= {1'b0, intellimouse, explorer, x};
      regBank[5] <= {1'b0, sensitivity, y};

      if ((BUS_ADDR >= BaseAddr) & (BUS_ADDR < BaseAddr + 8)) begin
        // Only first 2 addresses are writable
        if (BUS_WE) begin
          DataBusOutWE <= 1'b0;
          if (BUS_ADDR == (BaseAddr + 6)) begin
            regBank[BUS_ADDR-BaseAddr] <= BufferedBusData;
          end
        end else DataBusOutWE <= 1'b1;
      end else DataBusOutWE <= 1'b0;

      DataBusOut <= regBank[BUS_ADDR-BaseAddr];
    end
  end

  // Additional
  assign dec_sens   = regBank[6][6];
  assign inc_sens   = regBank[6][7];
  assign resolution = regBank[6][3:0];
endmodule
