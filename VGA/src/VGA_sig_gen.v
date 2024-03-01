`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.01.2024 14:00:35
// Design Name: 
// Module Name: VGA_top_wrapper
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
/*
This is the signal generator module which reads the colour of the pixels from the
frame buffer, and sends it to the VGA screen. It also controls the timing singals
for the things being displayed on the screen.
*/
//////////////////////////////////////////////////////////////////////////////////
module VGA_Sig_Gen(

    input           CLK,
    input           RESET,
    
    //Colour Configuration Interface
    input [15:0]    CONFIG_COLOURS,
    input           VGA_DATA,

    // Frame Buffer (Dual Port memory) Interface
    output          DPR_CLK,
    output [14:0]   VGA_ADDR,
    
    //VGA Port Interface
    output reg      VGA_HS,
    output reg      VGA_VS,
    output [7:0]    VGA_COLOUR
 
 
 );
//////////////////////////////////////////////////////////////////////////////////////////////////

//Halve the clock to 25MHz to drive the VGA display
wire [2:0] counter;
wire VGA_CLK;
 
     //Counter of 25MHz
  Generic_counter  # (.COUNTER_WIDTH(3),
                 .COUNTER_MAX(3)
                 )
                 General_Counter(
                 .CLK(CLK),
                 .RESET(RESET),
                 .ENABLE(1'b1),
                 .TRIG_OUT(VGA_CLK),
                 .COUNT(counter)
                 );
 
//////////////////////////////////////////////////////////////////////////////////////////////////
 

/*
Define VGA signal parameters e.g. Horizontal and Vertical display time, pulse widths, front and back
porch widths etc.
*/

 // Use the following signal parameters
parameter VTs = 521;        // Total Vertical Sync Pulse Time
parameter VTpw = 2;         // Vertical Pulse Width Time (You start displaying from here when bigger VS)
parameter VTDisp = 480;     // Vertical Display Time
parameter Vbp = 29;         // Vertical Back Porch Time
parameter Vfp = 10;         // Vertical Front Porch Time

parameter HTs = 800;        // Total Horizontal Sync Pulse Time
parameter HTpw = 96;        // Horizontal Pulse Width Time (You start displaying from here when bigger HS)
parameter HTDisp = 640;     // Horizontal Display Time
parameter Hbp = 48;         // Horizontal Back Porch Time
parameter Hfp = 16;         // Horizontal Front Porch Time


///////////////////////////////////////////////////////////////////////////////

//Vertical Lines. Colour should be black outside of this range.

parameter VertTimeToBackPorchEnd = VTpw + Vbp; //(From here the colouring should start)

parameter VertTimeToDisplayTimeEnd = VertTimeToBackPorchEnd + VTDisp; //(This is where the colouring stops)


//Time is Front Horizontal Lines

parameter HorzTimeToBackPorchEnd = Hbp + HTpw;  //(From here the colouring should start)

parameter HorzTimeToDisplayTimeEnd = HorzTimeToBackPorchEnd + HTDisp;   //(This is where the colouring stops)


///////////////////////////////////////////////////////////////////////////////

 // Define Horizontal and Vertical Counters to generate the VGA signals
reg [9:0] HCounter;
reg [9:0] VCounter;

/*
Create a process that assigns the proper horizontal and vertical counter values for raster scan of the
display.
*/

///////////////////////////////////////////////////////////////////////////////
wire X_out;
wire [9:0] X_count;
wire [9:0] Y_count;


//Horizontal Counter
Generic_counter  # (.COUNTER_WIDTH(10),
                .COUNTER_MAX(799)
                )
                Horizontal_Counter(
                .CLK(CLK),
                .RESET(RESET),
                .ENABLE(VGA_CLK),
                .TRIG_OUT(X_out),
                .COUNT(X_count)
                );
                
//Vertical Counter
Generic_counter  # (.COUNTER_WIDTH(10),
                .COUNTER_MAX(520)
                )
                Vertical_Counter(
                .CLK(CLK),
                .RESET(RESET),
                .ENABLE(X_out),
                .COUNT(Y_count)
                );


///////////////////////////////////////////////////////////////////////////////

/*
Need to create the address of the next pixel. Concatenate and tie the look ahead address to the frame
buffer address.
*/

assign DPR_CLK = VGA_CLK;
assign VGA_ADDR = {VCounter[8:2], HCounter[9:2]};

/*
Create a process that generates the horizontal and vertical synchronisation signals, as well as the pixel
colour information, using HCounter and VCounter. Do not forget to use CONFIG_COLOURS input to
display the right foreground and background colours.
*/

///////////////////////////////////////////////////////////////////////////////

//If statement for HS to be 1  
always@(posedge CLK) begin  
        if (HTpw < X_count)
            VGA_HS = 1;
        else
            VGA_HS = 0;
            end
           
//If statement for VS to be 1      
always@(posedge CLK) begin
    if (VTpw < Y_count)
        VGA_VS = 1;
    else
        VGA_VS = 0;
end

reg [15:0] col;

 always@(posedge CLK) begin

    if ((HorzTimeToBackPorchEnd< X_count) && (X_count <= HorzTimeToDisplayTimeEnd) && (VertTimeToBackPorchEnd < Y_count) &&(Y_count <= VertTimeToDisplayTimeEnd)) begin
        col <=  CONFIG_COLOURS;  
        HCounter <= (X_count - HorzTimeToBackPorchEnd);
        VCounter <= (Y_count - VertTimeToBackPorchEnd);
    end

    else begin
        col <= 16'h000;
        HCounter <= 0;
        VCounter <= 0;
    end
end


///////////////////////////////////////////////////////////////////////////////
/*
Finally, tie the output of the frame buffer to the colour output VGA_COLOUR.
*/
reg [7:0] final_col;

always@(posedge CLK) begin 

    if(RESET)
        final_col <= 8'h000;
   
    else    

        if (VGA_DATA)
            final_col <= col[7:0];
        else
          final_col <= col[15:8];
end

assign VGA_COLOUR = final_col;

///////////////////////////////////////////////////////////////////////////////
endmodule