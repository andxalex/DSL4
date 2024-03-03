`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.02.2024 17:18:12
// Design Name: 
// Module Name: Colour_module
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
This is an outside module that controls the colour configuration that is diaplyed
in the VGA screen.
Inputs:
    - The clock of the FPGA
    - A RESET button
    - The colour that the user decides by using the slide switches of the boaard.
    
Outputs:
    - The output of the module is the solour that will go into the signal generator
    and will be displayed.
    
The module chnages the colour every one second, by increasing its value. The ones second
is counted by instantiating a counter.
*/

//////////////////////////////////////////////////////////////////////////////////

module Colour_module(

    input           CLK,
    input    [15:0] CONFIG_COLOURS_IN,
    input           RESET,
    
    output   [15:0] CONFIG_COLOURS_OUT 
    
    );
//////////////////////////////////////////////////////////////////////////////////

//Wire and register definition

wire                sec_wire;
reg          [15:0] colour;

//////////////////////////////////////////////////////////////////////////////////

 //1 Second Counter
 Generic_counter  # (.COUNTER_WIDTH(27),
                .COUNTER_MAX(100000000)
                )
                General_Counter(
                .CLK(CLK),
                .RESET(1'b0),
                .ENABLE(1'b1),
                .TRIG_OUT(sec_wire)
                );
    
//////////////////////////////////////////////////////////////////////////////////

//Logic to change the output colour every one second.
   
always@(posedge CLK) begin

    if(RESET)
        colour <= CONFIG_COLOURS_IN;
    else
        if(sec_wire)
            colour <=  colour +10;
        else
           colour <=  colour; 
end

 //////////////////////////////////////////////////////////////////////////////////
   
 assign CONFIG_COLOURS_OUT = colour; 
    
//////////////////////////////////////////////////////////////////////////////////
    
 endmodule
