`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UoE
// Engineer: Andreas Alexandrou
// 
// Create Date: 05.02.2024 23:40:01
// Design Name: 
// Module Name: MouseMSM
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


module MouseMasterSM (
    input        CLK,
    input        RESET,
    input        INC_SENS,
    input        RED_SENS,
    //Transmitter Control
    output       SEND_BYTE,
    output [7:0] BYTE_TO_SEND,
    input        BYTE_SENT,
    //Receiver Control
    output       READ_ENABLE,
    input  [7:0] BYTE_READ,
    input  [1:0] BYTE_ERROR_CODE,
    input        BYTE_READY,
    //Data Registers
    output [7:0] MOUSE_DX,
    output [7:0] MOUSE_DY,
    output [7:0] MOUSE_DZ,
    output [7:0] MOUSE_STATUS,
    output       SEND_INTERRUPT,

    //Additional outptus
    output [6:0] curr_state,
    output INTELLIMOUSE,
    output EXPLORER,
    output [1:0] SENSITIVITY
);

  // Main state machine - There is a setup sequence
  //
  // 1) Send FF -- Reset command,
  // 2) Read FA -- Mouse Acknowledge,
  // 2) Read AA -- Self-Test Pass
  // 3) Read 00 -- Mouse ID
  // 4) Send F4 -- Start transmitting command,
  // 5) Read FA -- Mouse Acknowledge,
  //
  // If at any time this chain is broken, the SM will restart from
  // the beginning. Once it has finished the set-up sequence, the read enable flag
  // is raised.
  // The host is then ready to read mouse information 3 bytes at a time:
  // S1) Wait for first read, When it arrives, save it to Status. Goto S2.
  // S2) Wait for second read, When it arrives, save it to DX. Goto S3.
  // S3) Wait for third read, When it arrives, save it to DY. Goto S1.
  // Send interrupt

  //State Control
  reg [6:0] Curr_State, Next_State;
  reg [23:0] Curr_Counter, Next_Counter;
  //Transmitter Control
  reg Curr_SendByte, Next_SendByte;
  reg [7:0] Curr_ByteToSend, Next_ByteToSend;
  //Receiver Control
  reg Curr_ReadEnable, Next_ReadEnable;
  //Data Registers
  reg [7:0] Curr_Status, Next_Status;
  reg [7:0] Curr_Dx, Next_Dx;
  reg [7:0] Curr_Dy, Next_Dy;
  reg [7:0] Curr_Dz, Next_Dz;
  reg Curr_SendInterrupt, Next_SendInterrupt;

  reg Curr_intl, Next_intl;
  reg Curr_expl, Next_expl;

  reg Curr_inc_sens, Next_inc_sens;
  reg Curr_red_sens, Next_red_sens;
  reg [1:0] Curr_sens, Next_sens;
  ;
  assign curr_state = Curr_State;
  assign SENSITIVITY = Next_sens;
  assign INTELLIMOUSE = Curr_intl;
  assign EXPLORER = Curr_expl;
  //Sequential
  always @(posedge CLK) begin

    if (RESET) begin
      Curr_State <= 7'd0;
      Curr_Counter <= 0;
      Curr_SendByte <= 1'b0;
      Curr_ByteToSend <= 8'h00;
      Curr_ReadEnable <= 1'b0;
      Curr_Status <= 8'h00;
      Curr_Dx <= 8'h00;
      Curr_Dy <= 8'h00;
      Curr_Dz <= 8'h00;
      Curr_SendInterrupt <= 1'b0;
      Curr_intl <= 1'b0;
      Curr_expl <= 1'b0;
      Curr_inc_sens <= 1'b0;
      Curr_red_sens <= 1'b0;
      Curr_sens <= 2'b10;
    end else begin
      Curr_State <= Next_State;
      Curr_Counter <= Next_Counter;
      Curr_SendByte <= Next_SendByte;
      Curr_ByteToSend <= Next_ByteToSend;
      Curr_ReadEnable <= Next_ReadEnable;
      Curr_Status <= Next_Status;
      Curr_Dx <= Next_Dx;
      Curr_Dy <= Next_Dy;
      Curr_Dz <= Next_Dz;
      Curr_SendInterrupt <= Next_SendInterrupt;
      Curr_intl <= Next_intl;
      Curr_expl <= Next_expl;
      Curr_sens <= Next_sens;
      Curr_inc_sens <= INC_SENS;
      Curr_red_sens <= RED_SENS;
    end
  end

  //Combinational
  always @* begin

    Next_State = Curr_State;
    Next_Counter = Curr_Counter;
    Next_SendByte = 1'b0;
    Next_ByteToSend = Curr_ByteToSend;
    Next_ReadEnable = 1'b0;
    Next_Status = Curr_Status;
    Next_Dx = Curr_Dx;
    Next_Dy = Curr_Dy;
    Next_Dz = Curr_Dz;
    Next_SendInterrupt = 1'b0;
    Next_expl = Curr_expl;
    Next_intl = Curr_intl;
    Next_inc_sens = Curr_inc_sens;
    Next_red_sens = Curr_red_sens;
    Next_sens = Curr_sens;


    case (Curr_State)
      //Initialise State - Wait here for 10ms before trying to initialise the mouse.
      7'd0: begin
        if (Curr_Counter == 1000000/**/ /*Remove 3 zeroes to sim*/) begin  // 1/100th sec at 50MHz clock
          Next_State   = 7'd1;
          Next_Counter = 0;
        end else Next_Counter = Curr_Counter + 1'b1;
      end

      //Start initialisation by sending FF
      7'd1: begin
        Next_sens = 2'b10;
        Next_State = 7'd2;
        Next_SendByte = 1'b1;
        Next_ByteToSend = 8'hFF;
      end

      //Wait for confirmation of the byte being sent
      7'd2: begin
        if (BYTE_SENT) Next_State = 7'd3;
      end

      //Wait for confirmation of a byte being received
      //If the byte is FA goto next state, else re-initialise.
      7'd3: begin
        if (BYTE_READY) begin
          if ((BYTE_READ == 8'hFA) & (BYTE_ERROR_CODE == 2'b00)) Next_State = 7'd4;
          else Next_State = 7'd0;
        end
        Next_ReadEnable = 1'b1;
      end

      //Wait for self-test pass confirmation
      //If the byte received is AA goto next state, else re-initialise
      7'd4: begin
        if (BYTE_READY) begin
          if ((BYTE_READ == 8'hAA) & (BYTE_ERROR_CODE == 2'b00)) Next_State = 7'd5;
          else Next_State = 7'd0;
        end
        Next_ReadEnable = 1'b1;
      end

      //Wait for confirmation of a byte being received
      //If the byte is 00 goto next state (MOUSE ID) else re-initialise
      7'd5: begin
        if (BYTE_READY) begin
          if ((BYTE_READ == 8'h00) & (BYTE_ERROR_CODE == 2'b00)) Next_State = 7'd6;
          else Next_State = 7'd0;
        end
        Next_ReadEnable = 1'b1;
      end

      //Send F4 - to start mouse transmit
      7'd6: begin
        Next_State = 7'd7;
        Next_SendByte = 1'b1;
        Next_ByteToSend = 8'hF4;
      end

      //Wait for confirmation of the byte being sent

      7'd7: if (BYTE_SENT) Next_State = 7'd8;

      //Wait for confirmation of a byte being received
      //If the byte is FA goto next state, else re-initialise
      7'd8: begin
        if (BYTE_READY) begin
          if (BYTE_READ == 8'hFA) Next_State = 7'd9;
          else Next_State = 7'd0;
        end
        Next_ReadEnable = 1'b1;
      end

      /////////////////////////////////////////////////////////////////////
      // Intellimouse initialisation:
      // Sets sample rate to 200 - 100 = 80
      // Through sequence F3-C8-F3-64-F3-50

      //Start Intellimouse initialization
      //F3 to set sample rate, 1
      7'd9: begin
        Next_State = 7'd10;
        Next_SendByte = 1'b1;
        Next_ByteToSend = 8'hF3;
      end

      7'd10: begin
        if (BYTE_SENT) Next_State = 7'd11;
      end

      7'd11: begin
        if (BYTE_READY) begin
          if ((BYTE_READ == 8'hFA) & (BYTE_ERROR_CODE == 2'b00)) Next_State = 7'd12;
          else Next_State = 7'd0;
        end
        Next_ReadEnable = 1'b1;
      end

      //Set sample rate to 200
      7'd12: begin
        Next_State = 7'd13;
        Next_SendByte = 1'b1;
        Next_ByteToSend = 8'hC8;
      end

      7'd13: begin
        if (BYTE_SENT) Next_State = 7'd14;
      end

      7'd14: begin
        if (BYTE_READY) begin
          if ((BYTE_READ == 8'hFA) & (BYTE_ERROR_CODE == 2'b00)) Next_State = 7'd15;
          else Next_State = 7'd0;
        end
        Next_ReadEnable = 1'b1;
      end

      //F3 to set sample rate, 2
      7'd15: begin
        Next_State = 7'd16;
        Next_SendByte = 1'b1;
        Next_ByteToSend = 8'hF3;
      end

      7'd16: begin
        if (BYTE_SENT) Next_State = 7'd17;
      end

      7'd17: begin
        if (BYTE_READY) begin
          if ((BYTE_READ == 8'hFA) & (BYTE_ERROR_CODE == 2'b00)) Next_State = 7'd18;
          else Next_State = 7'd0;
        end
        Next_ReadEnable = 1'b1;
      end

      //Set sample rate to 100
      7'd18: begin
        Next_State = 7'd19;
        Next_SendByte = 1'b1;
        Next_ByteToSend = 8'h64;
      end

      7'd19: begin
        if (BYTE_SENT) Next_State = 7'd20;
      end

      7'd20: begin
        if (BYTE_READY) begin
          if ((BYTE_READ == 8'hFA) & (BYTE_ERROR_CODE == 2'b00)) Next_State = 7'd21;
          else Next_State = 7'd0;
        end
        Next_ReadEnable = 1'b1;
      end

      //F3 to set sample rate, 3
      7'd21: begin
        Next_State = 7'd22;
        Next_SendByte = 1'b1;
        Next_ByteToSend = 8'hF3;
      end

      7'd22: begin
        if (BYTE_SENT) Next_State = 7'd23;
      end

      7'd23: begin
        if (BYTE_READY) begin
          if ((BYTE_READ == 8'hFA) & (BYTE_ERROR_CODE == 2'b00)) Next_State = 7'd24;
          else Next_State = 7'd0;
        end
        Next_ReadEnable = 1'b1;
      end

      //Set sample rate to 80
      7'd24: begin
        Next_State = 7'd25;
        Next_SendByte = 1'b1;
        Next_ByteToSend = 8'h50;
      end

      7'd25: begin
        if (BYTE_SENT) Next_State = 7'd26;
      end

      7'd26: begin
        if (BYTE_READY) begin
          if ((BYTE_READ == 8'hFA) & (BYTE_ERROR_CODE == 2'b00)) Next_State = 7'd27;
          else Next_State = 7'd0;
        end
        Next_ReadEnable = 1'b1;
      end

      //Verify intellimouse mode
      //Request mouse id:
      7'd27: begin
        Next_State = 7'd28;
        Next_SendByte = 1'b1;
        Next_ByteToSend = 8'hF2;
      end

      7'd28: begin
        if (BYTE_SENT) Next_State = 7'd29;
      end

      7'd29: begin
        if (BYTE_READY) begin
          if ((BYTE_READ == 8'hFA) & (BYTE_ERROR_CODE == 2'b00)) Next_State = 7'd30;
          else Next_State = 7'd0;
        end
        Next_ReadEnable = 1'b1;
      end

      //If mouse id is 3, intellimouse mode initialisation was succesful.
      //If mouse id is 0, the device does not support intellimouse mode.
      7'd30: begin
        if (BYTE_READY) begin
          if ((BYTE_READ == 8'h03) & (BYTE_ERROR_CODE == 2'b00)) begin
            Next_State = 7'd31;
            Next_intl  = 1'b1;
          end else if ((BYTE_READ == 8'h00) & (BYTE_ERROR_CODE == 2'b00)) begin
            Next_State = 7'd31;
            Next_intl  = 1'b0;
          end else Next_State = 7'd0;
        end
        Next_ReadEnable = 1'b1;
      end

      /////////////////////////////////////////////////////////////////////
      // Explorer initialisation
      // Sample rate set to 200 - 200 - 80
      // By transmitting F3-C8-F3-C8-F3-50

      //Start explorer initialization
      //F3 to set sample rate, 1
      7'd31: begin
        Next_State = 7'd32;
        Next_SendByte = 1'b1;
        Next_ByteToSend = 8'hF3;
      end

      7'd32: begin
        if (BYTE_SENT) Next_State = 7'd33;
      end

      7'd33: begin
        if (BYTE_READY) begin
          if ((BYTE_READ == 8'hFA) & (BYTE_ERROR_CODE == 2'b00)) Next_State = 7'd34;
          else Next_State = 7'd0;
        end
        Next_ReadEnable = 1'b1;
      end

      //Set sample rate to 200
      7'd34: begin
        Next_State = 7'd35;
        Next_SendByte = 1'b1;
        Next_ByteToSend = 8'hC8;
      end

      7'd35: begin
        if (BYTE_SENT) Next_State = 7'd36;
      end

      7'd36: begin
        if (BYTE_READY) begin
          if ((BYTE_READ == 8'hFA) & (BYTE_ERROR_CODE == 2'b00)) Next_State = 7'd37;
          else Next_State = 7'd0;
        end
        Next_ReadEnable = 1'b1;
      end

      //F3 to set sample rate, 2
      7'd37: begin
        Next_State = 7'd38;
        Next_SendByte = 1'b1;
        Next_ByteToSend = 8'hF3;
      end

      7'd38: begin
        if (BYTE_SENT) Next_State = 7'd39;
      end

      7'd39: begin
        if (BYTE_READY) begin
          if ((BYTE_READ == 8'hFA) & (BYTE_ERROR_CODE == 2'b00)) Next_State = 7'd40;
          else Next_State = 7'd0;
        end
        Next_ReadEnable = 1'b1;
      end

      //Set sample rate to 200
      7'd40: begin
        Next_State = 7'd41;
        Next_SendByte = 1'b1;
        Next_ByteToSend = 8'hC8;
      end

      7'd41: begin
        if (BYTE_SENT) Next_State = 7'd42;
      end

      7'd42: begin
        if (BYTE_READY) begin
          if ((BYTE_READ == 8'hFA) & (BYTE_ERROR_CODE == 2'b00)) Next_State = 7'd43;
          else Next_State = 7'd0;
        end
        Next_ReadEnable = 1'b1;
      end

      //F3 to set sample rate, 3
      7'd43: begin
        Next_State = 7'd44;
        Next_SendByte = 1'b1;
        Next_ByteToSend = 8'hF3;
      end

      7'd44: begin
        if (BYTE_SENT) Next_State = 7'd45;
      end

      7'd45: begin
        if (BYTE_READY) begin
          if ((BYTE_READ == 8'hFA) & (BYTE_ERROR_CODE == 2'b00)) Next_State = 7'd46;
          else Next_State = 7'd0;
        end
        Next_ReadEnable = 1'b1;
      end

      //Set sample rate to 80.
      7'd46: begin
        Next_State = 7'd47;
        Next_SendByte = 1'b1;
        Next_ByteToSend = 8'h50;
      end

      7'd47: begin
        if (BYTE_SENT) Next_State = 7'd48;
      end

      7'd48: begin
        if (BYTE_READY) begin
          if ((BYTE_READ == 8'hFA) & (BYTE_ERROR_CODE == 2'b00)) Next_State = 7'd49;
          else Next_State = 7'd0;
        end
        Next_ReadEnable = 1'b1;
      end

      //Verify intellimouse explorer mode
      //Read mouse id:
      7'd49: begin
        Next_State = 7'd50;
        Next_SendByte = 1'b1;
        Next_ByteToSend = 8'hF2;
      end

      7'd50: begin
        if (BYTE_SENT) Next_State = 7'd51;
      end

      7'd51: begin
        if (BYTE_READY) begin
          if ((BYTE_READ == 8'hFA) & (BYTE_ERROR_CODE == 2'b00)) Next_State = 7'd52;
          else Next_State = 7'd0;
        end
        Next_ReadEnable = 1'b1;
      end

      7'd52: begin
        if (BYTE_READY) begin
          if ((BYTE_READ == 8'h04) & (BYTE_ERROR_CODE == 2'b00)) begin
            Next_State = 7'd53;
            Next_expl  = 1'b1;
            Next_intl  = 1'b1;
          end else if ((BYTE_READ == 8'h03) & (BYTE_ERROR_CODE == 2'b00)) begin
            Next_State = 7'd53;
            Next_expl  = 1'b0;
            Next_intl  = 1'b1;
          end else if ((BYTE_READ == 8'h00) & (BYTE_ERROR_CODE == 2'b00)) begin
            Next_State = 7'd53;
            Next_expl  = 1'b0;
            Next_intl  = 1'b0;
          end else Next_State = 7'd0;
        end
        Next_ReadEnable = 1'b1;
      end

      /////////////////////////////////////////////////////////////////////
      //At this point the SM has initialised the mouse.
      //Now we are constantly reading. If at any time
      //there is an error, we will re-initialise
      //the mouse - just in case.
      /////////////////////////////////////////////////////////////////////
      //Wait for the confirmation of a byte being received.
      //This byte will be the first of three, the status byte.
      //If a byte arrives, but is corrupted, then we re-initialise
      7'd53: begin
        if (Next_inc_sens || Next_red_sens) begin
          Next_State = 7'd58;
          if (Next_sens == 3) Next_sens = Next_sens - Next_red_sens;
          else if (Next_sens == 0) Next_sens = Next_sens + Next_inc_sens;
          else Next_sens = Next_sens + Next_inc_sens - Next_red_sens;
        end else begin
          if (BYTE_READY) begin
            if (BYTE_ERROR_CODE == 2'b00) begin
              Next_State  = 7'd54;
              Next_Status = BYTE_READ;
            end else Next_State = 7'd0;
          end
          Next_Counter = 0;
          Next_ReadEnable = 1'b1;
        end
      end
      //Wait for confirmation of a byte being received
      //This byte will be the second of three, the Dx byte.
      7'd54: begin
        if (BYTE_READY) begin
          if (BYTE_ERROR_CODE == 2'b00) begin
            Next_State = 7'd55;
            Next_Dx = BYTE_READ;
          end else Next_State = 7'd0;
        end
        Next_Counter = 0;
        Next_ReadEnable = 1'b1;
      end
      //Wait for confirmation of a byte being received
      //This byte will be the third of three, the Dy byte.
      7'd55: begin
        if (BYTE_READY) begin
          if (BYTE_ERROR_CODE == 2'b00) begin
            if (Next_intl) Next_State = 7'd56;
            else Next_State = 7'd57;
            Next_Dy = BYTE_READ;
          end else Next_State = 7'd0;
        end
        Next_Counter = 0;
        Next_ReadEnable = 1'b1;
      end
      //Wait for confirmation of a byte being received
      //This byte will be the fourth of the three, the Dz byte.
      7'd56: begin
        if (BYTE_READY) begin
          if (BYTE_ERROR_CODE == 2'b00) begin
            Next_State = 7'd57;
            Next_Dz = BYTE_READ;
          end else Next_State = 7'd0;
        end
        Next_Counter = 0;
        Next_ReadEnable = 1'b1;
      end
      //Send Interrupt State
      7'd57: begin
        Next_State = 7'd53;
        Next_SendInterrupt = 1'b1;
      end

      /////////////////////////////////////////////////////////////////////
      // PS2 allows for resolution control, which changes the sensitivity
      // of the mouse counters.
      // This is achieved by setting E8, followed by one of [0,1,2,3]
      // At a baseline, the mouse starts at resolution 2.
      // The new resolution can be validates by transmitting E9.
      // Following the acknowledge, three bytes are transmitted.
      // The second contains the resolution

      //Transmit E8 to change resolution
      7'd58: begin
        Next_State = 7'd59;
        Next_SendByte = 1'b1;
        Next_ByteToSend = 8'hE8;
      end

      7'd59: begin
        if (BYTE_SENT) Next_State = 7'd60;
      end

      7'd60: begin
        if (BYTE_READY) begin
          if ((BYTE_READ == 8'hFA) & (BYTE_ERROR_CODE == 2'b00)) Next_State = 7'd61;
          else Next_State = 7'd0;
        end
        Next_ReadEnable = 1'b1;
      end

      //Transmit new resolution
      7'd61: begin
        Next_State = 7'd62;
        Next_SendByte = 1'b1;
        Next_ByteToSend = {6'b000000, Next_sens};
      end

      7'd62: begin
        if (BYTE_SENT) Next_State = 7'd63;
      end

      7'd63: begin
        if (BYTE_READY) begin
          if ((BYTE_READ == 8'hFA) & (BYTE_ERROR_CODE == 2'b00)) Next_State = 7'd64;
          else Next_State = 7'd0;
        end
        Next_ReadEnable = 1'b1;
      end

      //Validate new resolution
      7'd64: begin
        Next_State = 7'd65;
        Next_SendByte = 1'b1;
        Next_ByteToSend = 8'hE9;
      end

      7'd65: begin
        if (BYTE_SENT) Next_State = 7'd66;
      end

      7'd66: begin
        if (BYTE_READY) begin
          if ((BYTE_READ == 8'hFA) & (BYTE_ERROR_CODE == 2'b00)) Next_State = 7'd67;
          else Next_State = 7'd0;
        end
        Next_ReadEnable = 1'b1;
      end

      7'd67: begin
        //We only want to validate resolution, this byte is unimportant
        if (BYTE_READY) begin
          Next_State = 7'd68;
        end
        Next_ReadEnable = 1'b1;
      end

      7'd68: begin
        if (BYTE_READY) begin
          if (BYTE_READ == {6'b000000, Next_sens}) Next_State = 7'd69;
          else Next_State = 7'd0;
        end
        Next_ReadEnable = 1'b1;
      end

      7'd69: begin
        if (BYTE_READY) begin
          //We only want to validate resolution, this byte is unimportant
          Next_State = 7'd53;
        end
        Next_ReadEnable = 1'b1;
      end

      //Default State
      default: begin
        Next_State = 7'd0;
        Next_Counter = 0;
        Next_SendByte = 1'b0;
        Next_ByteToSend = 8'hFF;
        Next_ReadEnable = 1'b0;
        Next_Status = 8'h00;
        Next_Dx = 8'h00;
        Next_Dy = 8'h00;
        Next_SendInterrupt = 1'b0;
      end
    endcase
  end
  ///////////////////////////////////////////////////
  //Tie the SM signals to the IO
  //Transmitter
  assign SEND_BYTE = Curr_SendByte;
  assign BYTE_TO_SEND = Curr_ByteToSend;
  //Receiver
  assign READ_ENABLE = Curr_ReadEnable;
  //Output Mouse Data
  assign MOUSE_DX = Curr_Dx;
  assign MOUSE_DY = Curr_Dy;
  assign MOUSE_DZ = Curr_Dz;
  assign MOUSE_STATUS = Curr_Status;
  assign SEND_INTERRUPT = Curr_SendInterrupt;

endmodule
