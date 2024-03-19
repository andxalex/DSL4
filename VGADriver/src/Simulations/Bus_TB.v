`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
// 
// Create Date: 06.03.2024 21:39:41
// Design Name: 
// Module Name: System
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
This is a test bench for the VGA periphreal. It was four different tests of different
comlexities. Each test examines seperate parts of the VGA and then the final one
tests the whole functionality by writting values on different parts of the frame
buffer.

INSTRUCTIONS FOR THE USER: If the user want to run the test, they better comment
out the rest of the tests, and run each test seperately. 
*/
//////////////////////////////////////////////////////////////////////////////////
module VGADriverIO_2_tb;
//////////////////////////////////////////////////////////////////////////////////
//Register and wire definition

    // Signals
    //Inputs
    reg                 CLK;
    reg                 RESET;
    wire    [7:0]       BUS_DATA;
    reg     [7:0]       BUS_ADDR;
    reg                 BUS_WE;
    //Outputs
    wire                A_DATA_OUT;
    wire                VGA_HS;
    wire                VGA_VS;
    wire    [7:0]       VGA_COLOUR;

    //Inside register
    reg     [7:0]       inout_drive;  // locally driven value
    assign BUS_DATA = inout_drive;

//////////////////////////////////////////////////////////////////////////////////

    // Instantiate the VGADriverIO_2 module
    VGADriverIO_2 dut (
        .CLK(CLK),
        .RESET(RESET),
        .BUS_DATA(BUS_DATA),
        .BUS_ADDR(BUS_ADDR),
        .BUS_WE(BUS_WE),
        .A_DATA_OUT(A_DATA_OUT),
        .VGA_HS(VGA_HS),
        .VGA_VS(VGA_VS),
        .VGA_COLOUR(VGA_COLOUR)
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

        /*
        Test 1: Leave everything empty and let the module run on the clock. This 
        allows to see if the base modules are working.

        Status: PASSED
        */

        //////////////////////////////////////////////////////////////////////////
        /*
        Test 2: Put the WE of the frame buffer to the lasst part of the register bank.
        See if the always statement and the adressing is correct.

        Result: The write enable goes hight and then it goes down. The result is that
        only one address is written in th  buffer.

        Status: PASSED
        */
        /*
        BUS_WE = 1;
        BUS_ADDR = 8'hB1;
        inout_drive = 8'b10000000;
        #3
        BUS_WE = 0;
        */
        //////////////////////////////////////////////////////////////////////////
        /*
        Test 3: Put part of the register bank for the data in. Will turn it once
        on and try to write a zero, with the constant address.

        Result: Should see a zero in the address 1 of the frame buffer. And then 
                see a one

        Status: PASSED
        */
        /*
        BUS_WE = 1;
        BUS_ADDR = 8'hB1;
        inout_drive = 8'b10000000;
        #3
        BUS_WE = 0;
        //inout_drive = 8'b00000000;
        #3
        BUS_WE = 1;
        BUS_ADDR = 8'hB2;
        inout_drive = 8'b00000000;
        #3
        BUS_WE = 0;
        #3
        BUS_WE = 1;
        BUS_ADDR = 8'hB2;
        inout_drive = 8'b00000001;
        #3
        BUS_WE = 0;
        */
        //////////////////////////////////////////////////////////////////////////
        /*
        Test 4: Put the register bank in the address to write on the frame buffer.
                It is important to send the x and y in two instructions.

        Result: Wrte a 1 in 2 different adresses. These should be 1 and 3000.

        Status: PASSED
        */

        
        //Process to write 1 on asdress 0
        //Get X
        BUS_WE = 1;
        BUS_ADDR = 8'hB0;
        inout_drive = 8'b00000000;
        #3
        BUS_WE = 0;
        //Get Y
        #3
        BUS_WE = 1;
        BUS_ADDR = 8'hB1;
        inout_drive = 8'b00000000;
        #3
        BUS_WE = 0;
        //Write Colour
        #3
        BUS_WE = 1;
        BUS_ADDR = 8'hB2;
        inout_drive = 8'b00000001;
        #3
        BUS_WE = 0;
        //Write on the Adress
        #3
        BUS_WE = 1;
        BUS_ADDR = 8'hB1;
        inout_drive = 8'b10000000;
        #3
        BUS_WE = 0;
        #3
        //Process to write 0 on asdress 3000 
        //Get X
        BUS_WE = 1;
        BUS_ADDR = 8'hB0;
        inout_drive = 8'b10111000;
        #3
        BUS_WE = 0;
        //Get Y
        #3
        BUS_WE = 1;
        BUS_ADDR = 8'hB1;
        inout_drive = 8'b00001011;
        #3
        BUS_WE = 0;
        //Write Colour
        #3
        BUS_WE = 1;
        BUS_ADDR = 8'hB2;
        inout_drive = 8'b00000001;
        #3
        BUS_WE = 0;
        //Write on the Adress
        #3
        BUS_WE = 1;
        BUS_ADDR = 8'hB1;
        inout_drive = 8'b10001011;
        #3
        BUS_WE = 0;
        
        
    end

endmodule