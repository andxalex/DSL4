`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.02.2024 10:19:09
// Design Name: 
// Module Name: MouseTransceiver
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

module MouseTransceiver (
    //Standard Inputs
    input RESET,
    input CLK,
    input INC_SENS,
    input RED_SENS,

    //IO - Mouse side
    inout CLK_MOUSE,
    inout DATA_MOUSE,

    // Mouse data information
    output reg [5:0] MouseStatus,
    output reg [7:0] MouseX,
    output reg [7:0] MouseY,
    output reg [2:0] MouseZ,

    // Additional Outputs
    output [6:0] MSM_STATE,
    output INTELLIMOUSE,
    output EXPLORER,
    output [1:0] SENSITIVITY,
    output [4:0] ACCUM_X,
    output [4:0] ACCUM_Y,
    output SEND_INTERRUPT
);

  // X, Y Limits of Mouse Position e.g. VGA Screen with 160 x 120 resolution
  parameter [7:0] MouseLimitX = 160;
  parameter [7:0] MouseLimitY = 120;
  parameter [2:0] MouseLimitZ = 5;


  /////////////////////////////////////////////////////////////////////
  //TriState Signals
  //Clk
  reg  ClkMouseIn;
  wire ClkMouseOutEnTrans;
  //Data
  wire DataMouseIn;
  wire DataMouseOutTrans;
  wire DataMouseOutEnTrans;
  //Clk Output - can be driven by host or device
  assign CLK_MOUSE   = ClkMouseOutEnTrans ? 1'b0 : 1'bz;
  //Clk Input
  assign DataMouseIn = DATA_MOUSE;
  //Clk Output - can be driven by host or device
  assign DATA_MOUSE  = DataMouseOutEnTrans ? DataMouseOutTrans : 1'bz;

  /////////////////////////////////////////////////////////////////////
  //This section filters the incoming Mouse clock to make sure that
  //it is stable before data is latched by either transmitter
  //or receiver modules
  reg [7:0] MouseClkFilter;
  always @(posedge CLK) begin
    if (RESET) ClkMouseIn <= 1'b0;
    else begin
      //A simple shift register
      MouseClkFilter[7:1] <= MouseClkFilter[6:0];
      MouseClkFilter[0]   <= CLK_MOUSE;
      //falling edge  
      if (ClkMouseIn & (MouseClkFilter == 8'h00)) ClkMouseIn <= 1'b0;
      //rising edge
      else if (~ClkMouseIn & (MouseClkFilter == 8'hFF)) ClkMouseIn <= 1'b1;
    end
  end
  ///////////////////////////////////////////////////////
  //Instantiate the Transmitter module
  wire SendByteToMouse;
  wire ByteSentToMouse;
  wire [7:0] ByteToSendToMouse;
  MouseTransmitter T (
      //Standard Inputs
      .RESET(RESET),
      .CLK(CLK),
      //Mouse IO - CLK
      .CLK_MOUSE_IN(ClkMouseIn),
      .CLK_MOUSE_OUT_EN(ClkMouseOutEnTrans),
      //Mouse IO - DATA
      .DATA_MOUSE_IN(DataMouseIn),
      .DATA_MOUSE_OUT(DataMouseOutTrans),
      .DATA_MOUSE_OUT_EN(DataMouseOutEnTrans),
      //Control
      .SEND_BYTE(SendByteToMouse),
      .BYTE_TO_SEND(ByteToSendToMouse),
      .BYTE_SENT(ByteSentToMouse)
  );
  ///////////////////////////////////////////////////////
  //Instantiate the Receiver module
  wire ReadEnable;
  wire [7:0] ByteRead;
  wire [1:0] ByteErrorCode;
  wire ByteReady;
  MouseReceiver R (
      //Standard Inputs
      .RESET(RESET),
      .CLK(CLK),
      //Mouse IO - CLK
      .CLK_MOUSE_IN(ClkMouseIn),
      //Mouse IO - DATA
      .DATA_MOUSE_IN(DataMouseIn),
      //Control
      .READ_ENABLE(ReadEnable),
      .BYTE_READ(ByteRead),
      .BYTE_ERROR_CODE(ByteErrorCode),
      .BYTE_READY(ByteReady)
  );
  ///////////////////////////////////////////////////////
  //Instantiate the Master State Machine module
  wire [7:0] MouseStatusRaw;
  wire [7:0] MouseDxRaw;
  wire [7:0] MouseDyRaw;
  wire [7:0] MouseDzRaw;
  wire SendInterrupt;
  MouseMasterSM MSM (
      //Standard Inputs
      .RESET(RESET),
      .CLK(CLK),
      .INC_SENS(INC_SENS),
      .RED_SENS(RED_SENS),
      //Transmitter Interface
      .SEND_BYTE(SendByteToMouse),
      .BYTE_TO_SEND(ByteToSendToMouse),
      .BYTE_SENT(ByteSentToMouse),
      //Receiver Interface
      .READ_ENABLE(ReadEnable),
      .BYTE_READ(ByteRead),
      .BYTE_ERROR_CODE(ByteErrorCode),
      .BYTE_READY(ByteReady),
      //Data Registers
      .MOUSE_STATUS(MouseStatusRaw),
      .MOUSE_DX(MouseDxRaw),
      .MOUSE_DY(MouseDyRaw),
      .MOUSE_DZ(MouseDzRaw),
      .SEND_INTERRUPT(SendInterrupt),
      //Additional Outputs
      .curr_state(MSM_STATE),
      .INTELLIMOUSE(INTELLIMOUSE),
      .EXPLORER(EXPLORER),
      .SENSITIVITY(SENSITIVITY)
  );

  //Pre-processing - handling of overflow and signs.
  //More importantly, this keeps tabs on the actual X/Y
  //location of the mouse.
  wire signed [8:0] MouseDx;
  wire signed [8:0] MouseDy;
  wire signed [3:0] MouseDz;
  wire signed [8:0] MouseNewX;
  wire signed [8:0] MouseNewY;
  wire signed [3:0] MouseNewZ;

  //DX and DY are modified to take account of overflow
  //and direction
  assign MouseDx = (MouseStatusRaw[6]) ? (MouseStatusRaw[4] ? {MouseStatusRaw[4],8'h00} :
    {MouseStatusRaw[4],8'hFF} ) : ((MouseStatusRaw[4]<<8) | MouseDxRaw[7:0]);
  //Assign the proper expression to MouseDy
  assign MouseDy = (MouseStatusRaw[7]) ? (MouseStatusRaw[5] ? {MouseStatusRaw[5],8'h00} :
    {MouseStatusRaw[5],8'hFF} ) : ((MouseStatusRaw[5]<<8) | MouseDyRaw[7:0]);
  //DZ is contiguous, cannot overflow.
  assign MouseDz = MouseDzRaw[3:0];

  ///////////////////////////////////////////////////////
  /************** SENSITIVITY ADJUSTMENT ***************/
  ///////////////////////////////////////////////////////
  //Adjust displacements based on sensitivity (currently 
  //bound to Scroll wheel)
  wire signed [8:0] NewDx;
  wire signed [8:0] NewDy;

  //Simple sensitivity adjustment is easy. Maintaining 
  //a uniform resolution is not. This is because right 
  // shifting can truncate to 0, preventing displacement 
  // if moving slowly. The code below fixes this, and 
  // provides an approximately uniform resolution.

  // 1. Ensure that the displacement is non zero.
  // 2. If the right shift wouldn't lead to a truncation,
  //    simply right shift.
  // 3. If it would, then check the value of the 
  //    accumulator, ensure it has triggered.
  // 4. If the accumulator is equal to the critical value,
  //    output -1 or 1 depending on the sign of displacement.
  assign NewDx = 
    (MouseDx == 0) ? 0 : 
    (((MouseDx >>> MouseZ) == 0) || ((MouseDx >>> MouseZ) == -1)) ? 
        ((accum_X == ((1 << MouseZ) - 1)) ? 
            (MouseDx[8] ? -1 : 1) : 
            0) : 
        (MouseDx >>> MouseZ);

  assign NewDy = 
    (MouseDy == 0) ? 0 : 
    (((MouseDy >>> MouseZ) == 0) || ((MouseDy >>> MouseZ) == -1)) ? 
        ((accum_Y == ((1 << MouseZ) - 1)) ? 
            (MouseDy[8] ? -1 : 1) : 
            0) : 
        (MouseDy >>> MouseZ);

  assign MouseNewX = {1'b0, MouseX} + NewDx;
  assign MouseNewY = {1'b0, MouseY} + NewDy;
  assign MouseNewZ = {1'b0, MouseZ} + MouseDz;

  reg [4:0] accum_X;
  reg [4:0] accum_Y;

  // Accumulator is able to pick up small movements. Triggers based on
  // resolution.
  assign ACCUM_X = accum_X;
  assign ACCUM_Y = accum_Y;
  always @(posedge SendInterrupt) begin
    if (MouseDx != 0) begin
      if (((MouseDx >>> MouseZ) == 0) || ($signed(MouseDx >>> MouseZ) == -1)) begin
        if (accum_X > ((1 << MouseZ) - 1)) accum_X = 0;
        else accum_X = accum_X + 1;
      end
    end

    if (MouseDy != 0) begin
      if (((MouseDy >>> MouseZ) == 0) || ($signed(MouseDy >>> MouseZ) == -1)) begin
        if (accum_Y > ((1 << MouseZ) - 1)) accum_Y = 0;
        else accum_Y = accum_Y + 1;
      end
    end
  end


  always @(posedge CLK) begin
    if (RESET) begin
      MouseStatus <= 0;
      MouseX <= MouseLimitX / 2;
      MouseY <= MouseLimitY / 2;
      MouseZ <= 0;
    end else if (SendInterrupt) begin
      //Status is stripped of all unnecessary info
      MouseStatus <= {MouseDzRaw[5:4], MouseStatusRaw[3:0]};
      //X is modified based on DX with limits on max and min
      if (MouseNewX < 0) MouseX <= 0;
      else if (MouseNewX > (MouseLimitX - 1)) MouseX <= MouseLimitX - 1;
      else MouseX <= MouseNewX[7:0];
      //Y is modified based on DY with limits on max and min
      if (MouseNewY < 0) MouseY <= 0;
      else if (MouseNewY > (MouseLimitY - 1)) MouseY <= MouseLimitY - 1;
      else MouseY <= MouseNewY[7:0];
      //Z is modified based on DZ with limits on max and min
      if (MouseNewZ < 0) MouseZ <= 0;
      else if (MouseNewZ > (MouseLimitZ - 1)) MouseZ <= MouseLimitZ - 1;
      else MouseZ <= MouseNewZ[2:0];
    end
  end

  assign SEND_INTERRUPT = SendInterrupt;
endmodule

