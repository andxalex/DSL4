`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.01.2024 14:00:35
// Design Name: 
// Module Name: VGA_Bus
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

module VGADriverIO (

    //Global  
    input               CLK,           // System clock
    input               RESET,         // System reset
    
    //Inputs from Buses
    input      [7:0]   ADDRESS,
    input      [7:0]   DATA,
    input              BUS_WE,

  
    //Outputs to VGA
    //output              A_DATA_OUT, Still have no clue why you would need this output
    output              VGA_HS,
    output              VGA_VS,
    output     [7:0]    VGA_COLOUR

);
//////////////////////////////////////////////////////////////////////////////////

//Instantiate Registers and Wires 

reg [14:0] TOT_ADDRESS;
reg        BUFFER_DATA;
reg        BUFFER_WE;
reg        CONFIG_COLOURS = 16'b0011001100110011;

wire       drp_clk;
wire [14:0]   vga_addr;
wire       b_data;

//////////////////////////////////////////////////////////////////////////////////

   // Instantiate Frame_Buffer and VGA_Sig_Gen modules
     Frame_Buffer frame_buffer (
       .A_CLK(CLK),
       .A_ADDR(TOT_ADDRESS),
       .A_DATA_IN(BUFFER_DATA),
       .A_WE(BUFFER_WE),
       .B_CLK(drp_clk),
       .B_ADDR(vga_addr),
       .A_DATA_OUT(A_DATA_OUT),
       .B_DATA(b_data)
     );
   
//////////////////////////////////////////////////////////////////////////////////
   
     VGA_Sig_Gen vga_sig_gen (
       .CLK(CLK),
       .RESET(RESET),
       .CONFIG_COLOURS(CONFIG_COLOURS),
       .VGA_DATA(b_data),
       .DPR_CLK(drp_clk),
       .VGA_ADDR(vga_addr),
       .VGA_HS(VGA_HS),
       .VGA_VS(VGA_VS),
       .VGA_COLOUR(VGA_COLOUR)
     );
////////////////////////////////////////////////////////////////////////////////// 

//Create States

wire GVIE_X;
wire GIVE_Y;
wire DATA;

assign Y_ADDR = (ADDR == 8'hB0) ? 1'b1 : 1'b0;
assign X_ADDR = (ADDR == 8'hB1) ? 1'b1 : 1'b0;
assign DATA_IN = (ADDR == 8'hB2) ? 1'b1 : 1'b0;
//////////////////////////////////////////////////////////////////////////////////

always @(posedge CLK) begin

  if(BUS_WE) begin

    //MSBs are Y axis
    if(Y_ADDR) begin
      TOT_ADDRESS[14:8] <= DATA;
      BUFFER_WE <= 1'b0;
    end

    //LSBs are X axis
    if(X_ADDR) begin
      TOT_ADDRESS[7:0] <= DATA;
      BUFFER_WE <= 1'b0;
    end

    if(DATA_IN) begin
      BUFFER_DATA <= DATA[0];
      TOT_ADDRESS <= TOT_ADDRESS;
      BUFFER_WE <= 1'b1;
    end
  end

  else begin
    TOT_ADDRESS <= TOT_ADDRESS;
    BUFFER_DATA <= BUFFER_DATA;
    BUFFER_WE <= BUFFER_WE;

  end


end
//////////////////////////////////////////////////////////////////////////////////


endmodule















