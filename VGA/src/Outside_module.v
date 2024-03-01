`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.01.2024 14:58:31
// Design Name: 
// Module Name: Outside_module
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
This is a module that simulates the microprocessor. It does it in a way that it 
outputs the respective pixel data for each pixel of the screen. It also contains
the necessary logic to implement the required patter on the screen. The pattern
is displayed by checking the location of the screen and then assigning the 
necessary colour. The module also reads a text files to create memories so that
images of the cars are dislpayed.The user should make sure that the path
used for the text files is correct.
*/

//////////////////////////////////////////////////////////////////////////////////


module Outside_module(

    //Global  
    input               CLK,           // System clock
    input               RESET,         // System reset
    input               BTNR,
    input               BTNU,
    input               BTND,
   
    //Inputs from proccesor
    output      [14:0]  A_ADDR,
    output      reg     A_DATA_IN
  
    );
    
//////////////////////////////////////////////////////////////////////////////////
   
    
//Make the clock to 25MHz to drive the VGA display
reg                     VGA_CLK;
    
    always@(posedge CLK) begin
        if(RESET)
            VGA_CLK <= 0;
        else
            VGA_CLK <= ~VGA_CLK;
     end    

                    
//////////////////////////////////////////////////////////////////////////////////////


wire                    sec_wire;
wire            [7:0]   count;
wire            [3:0]   level;

 //1 Second Counter
 Generic_counter  # (.COUNTER_WIDTH(27),
                .COUNTER_MAX(10000000)
                )
                General_Counter(
                .CLK(CLK),
                .RESET(1'b0),
                .ENABLE(1'b1),
                .TRIG_OUT(sec_wire)
                );


//Counter that will move image on the horizontal axis
 Generic_counter  # (.COUNTER_WIDTH(24),
                .COUNTER_MAX(256)
                )
                moving(
                .CLK(CLK),
                .RESET(1'b0),
                .ENABLE(sec_wire),
                .COUNT(count)
                );


////////////////////////////////////////////////////////////////////////////////////   

//Counters that control the logic for the address of the display. They are the same
//size as the buffer.

wire                    X_out;
wire            [7:0]   X_count;
wire            [6:0]   Y_count;   

    //Horizontal Counter
    Generic_counter  # (.COUNTER_WIDTH(10),
                    .COUNTER_MAX(256)
                    )
                    x_address(
                    .CLK(CLK),
                    .RESET(RESET),
                    .ENABLE(VGA_CLK),
                    .TRIG_OUT(X_out),
                    .COUNT(X_count)
                    );
                    
    //Vertical Counter
    Generic_counter  # (.COUNTER_WIDTH(10),
                    .COUNTER_MAX(128)
                    )
                    y_address(
                    .CLK(CLK),
                    .RESET(RESET),
                    .ENABLE(X_out),
                    .COUNT(Y_count)
                    );
////////////////////////////////////////////////////////////////////////////////////   
                                                        
// Memory to store pixel data
reg             [0:0]   pixel_data[2**15-1:0]; // Each pixel represented by 1 bit

// Load pixel data from file
initial begin
    $readmemb("/home/s2061395/Year_4/Digital_laboratory/python_script/Image_8.txt", pixel_data);
end
////////////////////////////////////////////////////////////////////////////////////
// Memory to store pixel data
reg             [0:0]   pixel_data_2[2**15-1:0]; // Each pixel represented by 1 bit

// Load pixel data from file
initial begin
    $readmemb("/home/s2061395/Year_4/Digital_laboratory/python_script/taxi.txt", pixel_data_2);
end
////////////////////////////////////////////////////////////////////////////////////

// Memory to store pixel data
reg             [0:0]   pixel_data_3[2**15-1:0]; // Each pixel represented by 1 bit

// Load pixel data from file
initial begin
    $readmemb("/home/s2061395/Year_4/Digital_laboratory/python_script/fiat.txt", pixel_data_3);
end

////////////////////////////////////////////////////////////////////////////////////   

//Logic that reads either memmory to display image or counter to display pattern

always @(posedge CLK) begin

    if (BTNR) begin
        A_DATA_IN <= pixel_data[Y_count*256 + X_count+ (count)];   
    end
    else if (BTNU)
        A_DATA_IN <= pixel_data_2[Y_count*256 + X_count+ (count)]; 
    else if (BTND)    
        A_DATA_IN <= pixel_data_3[Y_count*256 + X_count+ (count)];  
    else begin
        if ((((X_count + (count)) % 2) < 1) && (((Y_count) % 2) < 1))
              A_DATA_IN <= 1;       
        else
            A_DATA_IN <= 0;
    end
end
////////////////////////////////////////////////////////////////////////////////////   
assign A_ADDR = {Y_count, X_count};
//////////////////////////////////////////////////////////////////////////////////
endmodule
