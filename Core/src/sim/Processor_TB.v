`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
module VGADriverIO_2_tb;

    
    // Signals
    //Inputs
    reg CLK;
    reg RESET;
    wire [7:0] BUS_DATA;
    reg [7:0] BUS_ADDR;
    reg BUS_WE;
    
    // ROM signals
    wire [7:0] ROM_ADDRESS,
    reg  [7:0] ROM_DATA,
    // INTERRUPT signals
    reg  [1:0] BUS_INTERRUPTS_RAISE,
    wire [1:0] BUS_INTERRUPTS_ACK

    //Inside register
    reg [7:0]inout_drive;  // locally driven value
    wire [7:0]inout_recv;

    assign BUS_DATA = inout_drive;
//////////////////////////////////////////////////////////////////////////////////


 Processor dut(
    //Standard Signals
    .CLK(CLK),
    .RESET(RESET),
    .BUS_DATA(BUS_DATA),
    .BUS_ADDR(BUS_ADDR),
    .BUS_WE(BUS_WE),
    .ROM_ADDRESS(ROM_ADDRESS),
    .ROM_DATA(ROM_DATA),
    .BUS_INTERRUPTS_RAISE(BUS_INTERRUPTS_RAISE),
    .BUS_INTERRUPTS_ACK(BUS_INTERRUPTS_ACK)
);
//////////////////////////////////////////////////////////////////////////////////

   // Clock Definition
    initial begin
        CLK = 0;
        forever #1 CLK = ~CLK;
    end 
//////////////////////////////////////////////////////////////////////////////////

    // Initial stimulus
    initial begin
        // Initialize signals
        CLK = 0;
        RESET = 1;
        BUS_WE = 0;
        inout_drive = 8'h00;
        BUS_ADDR = 8'h00;

        // Reset
        #5;
        RESET = 0;
    end



endmodule