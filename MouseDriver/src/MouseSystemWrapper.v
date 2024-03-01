`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UoE
// Engineer: Andreas Alexandrou
// 
// Create Date: 30.01.2024 10:43:27
// Design Name: 
// Module Name: MouseSystemWrapper
// Project Name: MouseSystem
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


module MouseSystemWrapper (
    input CLK,
    input RESET,
    //CTRL
    input BTN_L,
    input BTN_R,
    //MOUSE
    inout CLK_MOUSE,
    inout DATA_MOUSE,
    //OUT
    output [15:0] LED_OUT,
    output [3:0] SEG_SELECT,
    output [7:0] DEC_OUT
);

  wire [5:0] status_mouse;
  wire [7:0] x_mouse;
  wire [7:0] y_mouse;
  wire [2:0] z_mouse;
  wire [7:0] byte_read;

  //Additional wires
  wire [6:0] MSM_state;
  wire intellimouse;
  wire explorer;
  wire [1:0] sensitivity;
  wire [4:0] x;
  wire [4:0] y;

  //Detect button falling edges.
  reg BtnLDly, BtnRDly;
  always @(posedge CLK) begin
    BtnLDly <= BTN_L;
    BtnRDly <= BTN_R;
  end

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
      .ACCUM_Y(y)
  );

  //Instantiate 7 seg display
  Seg7Display S7 (
      .IN_A({z_mouse[0], y_mouse[3:0]}),
      .IN_B({z_mouse[1], y_mouse[7:4]}),
      .IN_C({z_mouse[2], x_mouse[3:0]}),
      .IN_D({1'b0, x_mouse[7:4]}),
      .CLK(CLK),
      .SEG_SELECT(SEG_SELECT),
      .DEC_OUT(DEC_OUT)
  );


  assign LED_OUT = {intellimouse, explorer, sensitivity,status_mouse[1:0], x, y};
endmodule
