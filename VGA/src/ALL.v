`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.02.2024 17:15:14
// Design Name: 
// Module Name: ALL
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


module ALL(

    );
    
    
     Test_2 uut(
    
        //Global  
        .CLK(CLK),           // System clock
        .RESET(RESET),         // System reset
        .BTNL(BTNL),         //controls he A_WE
        .CONFIG_COLOURS_IN(CONFIG_COLOURS_IN),
        .MOUSE_IN(mouse),  
        
        
        //Outputs to VGA
        .A_DATA_OUT(A_DATA_OUT),
        .VGA_HS(VGA_HS),
        .VGA_VS(VGA_VS),
        .VGA_COLOUR(VGA_COLOUR)
        );
        
wire [15:0] mouse;       
        
        MouseSystemWrapper uut2(
            .RESET(RESET),
            .CLK(CLK),
            .CLK_MOUSE(CLK_MOUSE),
            .DATA_MOUSE(DATA_MOUSE),
            .LED_OUT(mouse),
            .SEG_SELECT(SEG_SELECT),
            .DEC_OUT(DEC_OUT)
        );
        
        
        
        
        
endmodule
