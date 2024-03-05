`timescale 1ns / 1ps

module MouseDriverIO (
    input        CLK,
    input        RESET,
    //BUS
    inout  [7:0] BUS_DATA,
    input  [7:0] BUS_ADDR,
    input        BUS_WE,
    //MOUSE
    inout        CLK_MOUSE,
    inout        DATA_MOUSE,
    //INTERRUPT
    output       BUS_INTERRUPT_RAISE,
    input  [1:0] BUS_INTERRUPTS_ACK
);

  wire [5:0] status_mouse;
  wire [7:0] x_mouse;
  wire [7:0] y_mouse;
  wire [2:0] z_mouse;

  //Additional wires
  wire [6:0] MSM_state;
  wire intellimouse;
  wire explorer;
  wire [1:0] sensitivity;
  wire [4:0] x;
  wire [4:0] y;
  wire SendInterrupt;

  //Instantiate mouse transceiver
  MouseTransceiver TR (
      .RESET(RESET),
      .CLK(CLK),
      .INC_SENS(BtnRDly & ~BTN_R),
      .RED_SENS(BtnLDly & ~BTN_L),
      .CLK_MOUSE(CLK_MOUSE),
      .DATA_MOUSE(DATA_MOUSE),
      .MouseStatus(status_mouse),
      .MouseX(x_mouse),
      .MouseY(y_mouse),
      .MouseZ(z_mouse),

      //Additional outputs
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
      else if (BUS_INTERRUPTS_ACK[0]) InterruptState = 0;
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

  //dual port RAM (from the view of the processor)
  integer i;
  always @(posedge CLK) begin
    if (RESET) begin
      DataBusOutWE <= 1'b0;
      for (i = 0; i < 8; i = i + 1) regBank[i] <= 0'h00;
    end else if ((BUS_ADDR >= BaseAddr) & (BUS_ADDR < BaseAddr + 6)) begin
      // Only first 2 addresses are writable
      if (BUS_WE) begin
        DataBusOutWE <= 1'b0;
        if ((BUS_ADDR >= Base_Addr) & (BUS_ADDR < Base_Addr + 2)) begin
          regBank[BUS_ADDR-Base_Addr] <= BufferedBusData;
        end
      end else begin
        DataBusOutWE <= 1'b1;
        regBank[0]   <= {7'h00, red_sens};
        regBank[1]   <= {7'h00, inc_sens};
        regBank[2]   <= {2'b00, status_mouse};
        regBank[3]   <= x_mouse;
        regBank[4]   <= y_mouse;
        regBank[5]   <= z_mouse;
        regBank[6]   <= {1'b0, intellimouse, explorer, x};
        regBank[7]   <= {1'b0, sensitivity, y};
      end
    end else DataBusOutWE <= 1'b0;

    DataBusOut <= regBank[BUS_ADDR-BaseAddr];
  end
endmodule
