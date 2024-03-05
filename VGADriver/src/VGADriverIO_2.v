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

module VGADriverIO_2 (

    //Global  
    input               CLK,           // System clock
    input               RESET,         // System reset
    
    //Inputs from Buses
    inout      [7:0]   ADDRESS,
    input      [7:0]   DATA,
    input              BUS_WE,

  
    //Outputs to VGA
    //output              A_DATA_OUT, Still have no clue why you would need this output
    output              VGA_HS,
    output              VGA_VS,
    output     [7:0]    VGA_COLOUR

);
//////////////////////////////////////////////////////////////////////////////////
// Register bank, holds device state
  reg [7:0] regBank[3:0];

  // Tristate
  wire [7:0] BufferedBusData;
  reg [7:0] DataBusOut;
  reg DataBusOutWE;



  // The register bank is effectively an extension of Data memory. The Base address below 
  // corresponds to regBank[0]
  parameter BaseAddr = 8'hB0;

  // Only place data on the bus if processor is not writing, and address is within range
  assign BUS_DATA = (DataBusOutWE) ? DataBusOut : 8'hZZ;

  //Buffer 
  assign BufferedBusData = BUS_DATA;

wire       drp_clk;
wire [14:0]   vga_addr;
wire       b_data;



reg        CONFIG_COLOURS = 16'b1111111111111111;


//////////////////////////////////////////////////////////////////////////////////

   // Instantiate Frame_Buffer and VGA_Sig_Gen modules
     Frame_Buffer frame_buffer (
       .A_CLK(CLK),
       .A_ADDR({regBank[0], regBank[1]}),
       .A_DATA_IN(regBank[2][0]),
       .A_WE(regBank[3][0]),
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
  always @(posedge CLK) begin

    if (RESET) begin
      DataBusOutWE <= 1'b0;
      regBank[0]   <= 8'h0;
      regBank[1]   <= 8'h0;
      regBank[2]   <= 8'h0;
      regBank[3]   <= 8'h0;
    end else begin
      if ((BUS_ADDR >= BaseAddr) & (BUS_ADDR < (BaseAddr + 4))) begin
        if (BUS_WE) begin
          DataBusOutWE <= 1'b0;
          regBank[BUS_ADDR-BaseAddr] <= BufferedBusData;

        end else DataBusOutWE <= 1'b1;

      end else DataBusOutWE <= 1'b0;
    end
    DataBusOut <= regBank[BUS_ADDR-BaseAddr];
  end

//////////////////////////////////////////////////////////////////////////////////


endmodule















