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
    reg [7:0]inout_drive = 8'd0;  // locally driven value


    assign BUS_DATA = inout_drive;

    reg [7:0] state;
    reg [7:0] expected_state;
    reg flag;
    reg fnished = 0;

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
        forever #1 CLK = ~CLK;
    end 

    reg [10:0] edge_counter = 11'b00000000000;
 
    always @(posedge CLK) begin
        state <= dut.CurrState;
        edge_counter <= edge_counter + 1;
        if(edge_counter == 9 || (edge_counter == 4 && fnished))  edge_counter <= 0;

        end
//////////////////////////////////////////////////////////////////////////////////

always @(negedge CLK) begin

    case(ROM_DATA)

        8'h10: begin    //READ_FROM_MEM_TO_A 

            if(edge_counter == 3) begin

                if(state != 8'h00) flag = 1;

                if(BUS_ADDR != 8'hff) flag = 1;

                if(ROM_ADDRESS != 8'h01) flag = 1;
            end

            if(edge_counter == 4) begin

                if(state != 8'h00) flag = 1;

                if(BUS_ADDR != 8'hff) flag = 1;

                if(ROM_ADDRESS != 8'h01) flag = 1;
            end

            if(edge_counter == 5) begin

                if(state != 8'h10) flag = 1;

                if(BUS_ADDR != 8'hff) flag = 1;

                if(ROM_ADDRESS != 8'h00) flag = 1;
            end

            if(edge_counter == 6) begin

                if(state != 8'h12) flag = 1;

                if(BUS_ADDR != 8'h10) flag = 1;

                if(ROM_ADDRESS != 8'h00) flag = 1;
            end

            if(edge_counter == 7) begin

                if(state != 8'h13) flag = 1;

                if(BUS_ADDR != 8'hff) flag = 1;

                if(ROM_ADDRESS != 8'h02) flag = 1;
            end

            if(edge_counter == 8) begin

                ROM_DATA = 8'h11;
                if(state != 8'h14) flag = 1;

                if(BUS_ADDR != 8'hff) flag = 1;

                if(ROM_ADDRESS != 8'h02) flag = 1;
            end

            if(edge_counter == 9) begin
                
                if(state != 8'h00) flag = 1;

                if(BUS_ADDR != 8'hff) flag = 1;

                if(ROM_ADDRESS != 8'h03) flag = 1;
      

            end
        end

        8'h11: begin

            if(edge_counter == 0) begin

                if(state != 8'h11) flag = 1;

                if(BUS_ADDR != 8'hff) flag = 1;

                if(ROM_ADDRESS != 8'h02) flag = 1;
            end

            if(edge_counter == 1) begin

                if(state != 8'h12) flag = 1;

                if(BUS_ADDR != 8'h11) flag = 1;

                if(ROM_ADDRESS != 8'h02) flag = 1;
            end

            if(edge_counter == 2) begin

                if(state != 8'h13) flag = 1;

                if(BUS_ADDR != 8'hff) flag = 1;

                if(ROM_ADDRESS != 8'h04) flag = 1;
            end

            if(edge_counter == 3) begin

                ROM_DATA = 8'h20;           //next instruction

                if(state != 8'h14) flag = 1;

                if(BUS_ADDR != 8'hff) flag = 1;

                if(ROM_ADDRESS != 8'h04) flag = 1;
            end

            if(edge_counter == 4) begin
                 
                if(state != 8'h00) flag = 1;

                if(BUS_ADDR != 8'hff) flag = 1;

                if(ROM_ADDRESS != 8'h05) flag = 1;

                fnished = 1;
                inout_drive = 8'h01;
      
            end
            
        end


    endcase
end


// //////////////////////////////////////////////////////////////////////////////////

    // Initial stimulus
    initial begin
        // Initialize signals
        CLK = 0;
        RESET = 1;
        BUS_INTERRUPTS_RAISE = 2'b00;
        flag = 0;

        // Reset
        #5;
        RESET = 0;

        ////////////////////////////////////////////////////////////////////////

        ROM_DATA = 8'h10;
   
        

        #90 $stop;



    // Add more expected states as needed

    
        
    


    #14 $finish;


    end



endmodule