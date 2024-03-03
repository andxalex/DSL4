`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.01.2024 10:58:31
// Design Name: 
// Module Name: Generic_Counter
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


module Generic_counter(
    CLK,
    RESET,
    ENABLE,
    COUNT,
    TRIG_OUT 
);  
    //Parameter definitions
    parameter COUNTER_WIDTH = 4;
    parameter COUNTER_MAX = 9;
    
    //IO Definitions
    input CLK;
    input RESET;
    input ENABLE;
    output TRIG_OUT;
    output [COUNTER_WIDTH-1:0] COUNT;
    
    //registers hold current value, and trigger out between clock cycles.
    //note count_value is instantiated as 0
    reg [COUNTER_WIDTH-1:0] count_value = 0;
    reg trigger_out;

    //Synchronous logic for count_value;    
    always@(posedge CLK) begin
        if (RESET)
            count_value <= 0;
        else begin
            if (ENABLE) begin
                if (count_value == COUNTER_MAX) 
                    count_value <= 0;
                else
                    count_value <= count_value +1;
            end
        end
    end
    
    always@(posedge CLK) begin
        if (RESET)
            trigger_out <= 0;
        else begin
            if (ENABLE && count_value == COUNTER_MAX)
                trigger_out <= 1;
            else
                trigger_out <= 0;
        end
    end
    
    //assign registers to outputs
    assign COUNT = count_value;
    assign TRIG_OUT = trigger_out; 
    
endmodule

