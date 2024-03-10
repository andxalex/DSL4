`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.03.2024 21:39:41
// Design Name: 
// Module Name: SystemTB
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


module SystemTB(
    );
    
    reg CLK;
    reg RESET;
    wire [7:0] CpuState;
    wire [7:0] regA;
    wire [7:0] regB;
    wire [7:0] instruction;
    wire [3:0] D0;
    wire [3:0] D1;
    wire [3:0] D2;
    wire [3:0] D3;
    wire mouseInterrupt;
    wire [7:0] romAddr;
    wire [7:0] rawAddr;
    wire offset;
    wire [7:0] ROM [255:0];
    
    System dut (
           .CLK(CLK),
           .RESET(RESET));
            // CTRL
            //.BTN_L,
            //.BTN_R,
            // MOUSE
            //.CLK_MOUSE,
            //.DATA_MOUSE,
            // OUT
            //.LED_OUT,
            //.SEG_SELECT,
            //.DEC_OUT);
    
    assign regA = dut.ryzen_7800x3d.CurrRegA;
    assign regB = dut.ryzen_7800x3d.CurrRegB;
    assign instruction = dut.ryzen_7800x3d.ProgMemoryOut;
    assign D0 = dut.Samsung_odyssey_neo_g9.regBank[0];
    assign D1 = dut.Samsung_odyssey_neo_g9.regBank[1];
    assign D2 = dut.Samsung_odyssey_neo_g9.regBank[2];
    assign D3 = dut.Samsung_odyssey_neo_g9.regBank[3];
    assign mouseInterrupt = dut.logitech_g1_pro.InterruptState;
    assign CpuState = dut.ryzen_7800x3d.CurrState;
    assign romAddr = dut.rom_addr;
    assign offset = dut.ryzen_7800x3d.CurrProgCounterOffset;
    assign rawAddr = dut.ryzen_7800x3d.CurrProgCounter;
    
    genvar i;
    generate
        for (i = 0; i< 256; i = i + 1)begin
            assign ROM[i] = dut.theres_no_fancy_rom_stick.ROM[i];
        end
    endgenerate
    
    initial begin
    CLK = 0;
    forever #5 CLK = ~CLK;
    end
    
    initial begin
    RESET = 1;
    #10000 RESET = 0;
    
    #10000 dut.logitech_g1_pro.InterruptState = 1;
    #100   dut.logitech_g1_pro.InterruptState = 0;
    #10000 $stop;
    end
    
endmodule
