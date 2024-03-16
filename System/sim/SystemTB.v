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
    wire [7:0] B0;
    wire [7:0] B1;
    wire [7:0] B2;
    wire [7:0] B3;
    wire vgaInterrupt;
    wire [7:0] romAddr;
    wire [7:0] rawAddr;
    wire offset;
    wire [7:0] ROM [255:0];
   // wire frame_buf_addres_1;
   // wire frame_buf_addres_2;
    wire  VGA_HS;
    wire  VGA_VS;
    wire     [7:0]    VGA_COLOUR;
    wire [7:0] VGA_x;
    wire [6:0] VGA_y;
    wire [7:0] buffer_x;
    wire [6:0] buffer_y;
    
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
    assign B0 = dut.to_mouni.regBank[0];
    assign B1 = dut.to_mouni.regBank[1];
    assign B2 = dut.to_mouni.regBank[2];
    //assign Buffer_WE = dut.to_mouni.regBank[3][0];
    assign vgaInterrupt = dut.ryzen_7800x3d.BUS_INTERRUPTS_RAISE[1];
    assign CpuState = dut.ryzen_7800x3d.CurrState;
    assign romAddr = dut.rom_addr;
    assign offset = dut.ryzen_7800x3d.CurrProgCounterOffset;
    assign rawAddr = dut.ryzen_7800x3d.CurrProgCounter;
   // assign frame_buf_addres_1 = dut.to_mouni.frame_buffer.Mem[0];
   // assign frame_buf_addres_2 = dut.to_mouni.frame_buffer.Mem[1];
    assign VGA_HS = dut.to_mouni.VGA_HS;
    assign VGA_VS = dut.to_mouni.VGA_VS;
    assign VGA_COLOUR = dut.to_mouni.VGA_COLOUR;
    assign buffer_x = dut.to_mouni.frame_buffer.A_ADDR[7:0];
    assign buffer_y = dut.to_mouni.frame_buffer.A_ADDR[14:8];
    assign VGA_x = dut.to_mouni.vga_addr[7:0];
    assign VGA_y = dut.to_mouni.vga_addr[14:8];


    genvar i;
    generate
        for (i = 0; i< 256; i = i + 1)begin
            assign ROM[i] = dut.theres_no_fancy_rom_stick.ROM[i];
        end
    endgenerate
    
    initial begin
    CLK = 0;
    forever #1 CLK = ~CLK;
    end
    
    initial begin
    RESET = 1;
    #20 RESET = 0;
    

    
    end
    
endmodule
