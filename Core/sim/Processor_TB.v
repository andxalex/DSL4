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
    reg [7:0]ram_data = 8'd0;  // locally driven value


    assign BUS_DATA = ram_data;

    reg [7:0] state;
    reg [7:0] expected_state;
    reg flag;
    reg fnished = 0;

    //Register A
    wire [7:0] regA;
    wire[7:0]  regB;
    reg [7:0] old_regA;
    reg [7:0]  old_regB;
    reg [7:0] sum;
    reg [7:0] old_prog_counter;

    assign  regA = dut.CurrRegA;
    assign  regB = dut.CurrRegB;

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

   // Clock Definition
    initial begin
        CLK = 0;
        forever #5 CLK = ~CLK;
    end 

    reg [10:0] edge_counter = 11'b00000000000;
 
    always @(posedge CLK) begin
        state <= dut.CurrState;
        edge_counter <= edge_counter + 1;
        if(edge_counter == 9)  edge_counter <= 0;

        end
//////////////////////////////////////////////////////////////////////////////////

// always @(negedge CLK) begin

//     case(ROM_DATA)

//         8'h10: begin    //READ_FROM_MEM_TO_A 

//             if(edge_counter == 3) begin

//                 if(state != 8'h00) flag = 1;

//                 if(BUS_ADDR != 8'hff) flag = 1;

//                 if(ROM_ADDRESS != 8'h01) flag = 1;
//             end

//             if(edge_counter == 4) begin

//                 if(state != 8'h00) flag = 1;

//                 if(BUS_ADDR != 8'hff) flag = 1;

//                 if(ROM_ADDRESS != 8'h01) flag = 1;
//             end

//             if(edge_counter == 5) begin

//                 if(state != 8'h10) flag = 1;

//                 if(BUS_ADDR != 8'hff) flag = 1;

//                 if(ROM_ADDRESS != 8'h00) flag = 1;
//             end

//             if(edge_counter == 6) begin

//                 if(state != 8'h12) flag = 1;

//                 if(BUS_ADDR != 8'h10) flag = 1;

//                 if(ROM_ADDRESS != 8'h00) flag = 1;
//             end

//             if(edge_counter == 7) begin

//                 if(state != 8'h13) flag = 1;

//                 if(BUS_ADDR != 8'hff) flag = 1;

//                 if(ROM_ADDRESS != 8'h02) flag = 1;
//             end

//             if(edge_counter == 8) begin

                
//                 if(state != 8'h14) flag = 1;

//                 if(BUS_ADDR != 8'hff) flag = 1;

//                 if(ROM_ADDRESS != 8'h02) flag = 1;
//             end

//             if(edge_counter == 9) begin
                
//                 if(state != 8'h00) flag = 1;

//                 if(BUS_ADDR != 8'hff) flag = 1;

//                 if(ROM_ADDRESS != 8'h03) flag = 1;
      

//             end
//         end

//         8'h11: begin

//             if(edge_counter == 0) begin

//                 if(state != 8'h11) flag = 1;

//                 if(BUS_ADDR != 8'hff) flag = 1;

//                 if(ROM_ADDRESS != 8'h02) flag = 1;
//             end

//             if(edge_counter == 1) begin

//                 if(state != 8'h12) flag = 1;

//                 if(BUS_ADDR != 8'h11) flag = 1;

//                 if(ROM_ADDRESS != 8'h02) flag = 1;
//             end

//             if(edge_counter == 2) begin

//                 if(state != 8'h13) flag = 1;

//                 if(BUS_ADDR != 8'hff) flag = 1;

//                 if(ROM_ADDRESS != 8'h04) flag = 1;
//             end

//             if(edge_counter == 3) begin

//                 ROM_DATA = 8'h20;           //next instruction

//                 if(state != 8'h14) flag = 1;

//                 if(BUS_ADDR != 8'hff) flag = 1;

//                 if(ROM_ADDRESS != 8'h04) flag = 1;
//             end

//             if(edge_counter == 4) begin
                 
//                 if(state != 8'h00) flag = 1;

//                 if(BUS_ADDR != 8'hff) flag = 1;

//                 if(ROM_ADDRESS != 8'h05) flag = 1;

//                 fnished = 1;
//                 inout_drive = 8'h01;
      
//             end
            
//         end


//     endcase
// end


// //////////////////////////////////////////////////////////////////////////////////
    event wait_for_a;

    // Initial stimulus
    initial begin
        // Initialize signal
        CLK = 0;
        RESET = 1;
        BUS_INTERRUPTS_RAISE = 2'b00;
        flag = 0;
        //ROM_DATA = 8'h00;
        // Reset
        #12;
        RESET = 0;
        
        ////////////////////////////////////////////////////////////////////////
       
        //READ_FROM_MEM_TO_A
        ROM_DATA = 8'h00;
        wait (dut.CurrState == 8'h12);

        ROM_DATA = 8'h01;
        ram_data = 8'h05;
        wait (dut.CurrState == 8'h00);
        if((regA != ram_data)) $display("READ_FROM_MEM_TO_A: fail");
        else $display("READ_FROM_MEM_TO_A Passed");
        $display("  - READ_FROM_MEM_TO_A expected: 0x%0h got: 0x%0h", ram_data, regA);

        #10
        //WRITE_TO_MEM_FROM_A
        ROM_DATA = 8'h02;
        wait (dut.CurrState == 8'h22);
        ROM_DATA = 8'h01;
        ram_data = 8'h05;
        wait (dut.CurrState == 8'h00);
        if((regB != ram_data)) $display("WRITE_TO_MEM_FROM_A: fail");
        else $display("WRITE_TO_MEM_FROM_A Passed");
        $display("  - WRITE_TO_MEM_FROM_A expected: 0x%0h got: 0x%0h", ram_data, regB);

         #10
        //ALU Operation
        ROM_DATA = 8'h04;
        old_regA <= regA;
        wait (dut.CurrState == 8'h00);
        if((regA != (old_regA + old_regB))) $display("ALU Operation: fail");
        else $display("ALU Operation Passed");
         $display("  - ALU Operation expected: 0x%0h got: 0x%0h", 8'h05, regA);
        
        #20
        //Branch greater
        ROM_DATA = 8'h96;
        wait (dut.CurrState == 8'h36);
        ROM_DATA = 8'h01;
        wait (dut.CurrState == 8'h00);
        if((dut.CurrProgCounter != ROM_DATA)) $display("Branch: fail");
        else $display("Branch Passed");
        $display("  - Branch: 0x%0h got: 0x%0h", ROM_DATA, dut.CurrProgCounter);

        #10
        //Go to
        ROM_DATA = 8'h07;
        wait (dut.CurrState == 8'h39);
        ROM_DATA = 8'h00;
        wait (dut.CurrState == 8'h00);
        if((ROM_ADDRESS != dut.CurrProgCounter)) $display("Go to: fail");
        else $display("Go to Passed");
        $display("  - Go to Passed: 0x%0h got: 0x%0h", ROM_ADDRESS, dut.CurrProgCounter);

        #8
        //Function call
        ROM_DATA = 8'h09;
        wait (dut.CurrState == 8'h45);
        ROM_DATA = 8'h0A;
        old_prog_counter <= dut.CurrProgCounter;
        wait (dut.CurrState == 8'h00);
        if(((ROM_DATA) != dut.CurrProgCounter)) $display("Function call: fail");
        else $display("Function call Passed");
        $display("  - Function call: 0x%0h got: 0x%0h", ROM_DATA, dut.CurrProgCounter);



        #8
        //Return
        ROM_DATA = 8'h0A;
        wait (dut.CurrState == 8'h00);
        if(((old_prog_counter + 2) != dut.CurrProgContext)) $display("Return: fail");
        else $display("Return: Passed");
        $display("  - Return: 0x%0h got: 0x%0h", 8'h02, dut.CurrProgContext);

        #8
        //Dereference
        ROM_DATA = 8'h0B;
        wait (dut.CurrState == 8'h51);
        ram_data = 8'h05;
        wait (dut.CurrState == 8'h00);
        if((regA != ram_data)) $display("Dereference: fail");
        else $display("Dereference: Passed");
        $display("  - Dereference: 0x%0h got: 0x%0h", ram_data, regA);


        #8
        //Go to idle
        ROM_DATA = 8'h08;
        wait (dut.CurrState == 8'hF0);
        if((dut.NextState != 8'hF0)) $display("Go to idle: fail");
        else $display("Go to idle Passed");
        $display("  - Go to idle: 0x%0h got: 0x%0h", 8'hF0, dut.NextState);


   
        

        #90 $stop;



    // Add more expected states as needed

    
        
    


    #14 $finish;


    end



endmodule