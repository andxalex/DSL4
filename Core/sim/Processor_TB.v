`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
module Procecessor_TB;

    
    // Signals
    //Inputs
    reg CLK;
    reg RESET;
    wire [7:0] BUS_DATA;
    wire [7:0] BUS_ADDR;
    wire BUS_WE;
    
    // ROM signals
    wire [7:0] ROM_ADDRESS;
    reg  [7:0] ROM_DATA;
    // INTERRUPT signals
    reg  [1:0] BUS_INTERRUPTS_RAISE;
    wire [1:0] BUS_INTERRUPTS_ACK;

    //Inside register
    reg [7:0]inout_drive;  // locally driven value


    assign BUS_DATA = inout_drive;

    reg [7:0] state;
    reg [7:0] expected_state;
    reg flag;

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

    // Check for correct state
    always @(posedge CLK) begin
        if (state != expected_state) begin
            flag = 1;
        end
    end


   // Clock Definition
    initial begin
        CLK = 0;
        forever #1 CLK = ~CLK;
    end 


 
    always @(posedge CLK) begin
        state <= dut.CurrState;
        $display("State: %h", state);
        end

//////////////////////////////////////////////////////////////////////////////////

    // Initial stimulus
    initial begin
        // Initialize signals
        CLK = 0;
        RESET = 1;
        inout_drive = 8'h00;
        flag = 0;

        // Reset
        #5;
        RESET = 0;

        ////////////////////////////////////////////////////////////////////////

        ROM_DATA = 8'h10;
        BUS_INTERRUPTS_RAISE = 2'b00;
        inout_drive = 8'h00;
        #2 expected_state = 8'h00;
        #2 expected_state = 8'h10;
        #2 expected_state = 8'h12;
        #2 expected_state = 8'h13;
        #2 expected_state = 8'h14;
        #2 $stop;



    // Add more expected states as needed

    
        
    


    #14 $finish;


    end



endmodule