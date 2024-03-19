`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.03.2024 14:00:35
// Design Name: 
// Module Name: ALU
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
module ALU (
    //standard signals
    input CLK,
    input RESET,
    //I/O
    input [7:0] IN_A,
    input [7:0] IN_B,
    input [7:0] IMM,
    input [7:0] INSTRUCT,
    output [7:0] OUT_RESULT
);
  reg [7:0] Out;
  wire [3:0] ALU_Op_Code;
  wire immA; 
  wire immB; 
  wire [7:0] argA;
  wire [7:0] argB;

  assign ALU_Op_Code = INSTRUCT[7:4];
  assign immA = (INSTRUCT[3:0] == 4'hD) ? 1:0;
  assign immB = (INSTRUCT[3:0] == 4'hE) ? 1:0;
  assign argA = immB? IMM : IN_A;
  assign argB = immA? IMM : IN_B;
                   
  //Arithmetic Computation
  always @(posedge CLK) begin
    if (RESET) begin
       Out <= 0;
    end
    else begin

      case (ALU_Op_Code)
        //Maths Operations
        //Add A + B
        4'h0: Out <= argA + argB;
        //Subtract A - B
        4'h1: Out <= argA - argB;
        //Multiply A * B
        4'h2: Out <= argA * argB;
        //Shift Left A << 1
        4'h3: Out <= argA << (immA?argB:1);
        //Shift Right A >> 1 
        4'h4: Out <= argA >> (immA?argB:1);
        //Increment A+1
        4'h5: Out <= IN_A + 1'b1;
        //Increment B+1
        4'h6: Out <= IN_B + 1'b1; 
        //Decrement A-1
        4'h7: Out <= IN_A - 1'b1;
        //Decrement B-1
        4'h8: Out <= IN_B - 1'b1;
        // In/Equality Operations
        //A == B
        4'h9: Out <= (IN_A == IN_B) ? 8'h01 : 8'h00;
        //A > B
        4'hA: Out <= (IN_A > IN_B) ? 8'h01 : 8'h00;
        //A < B
        4'hB: Out <= (IN_A < IN_B) ? 8'h01 : 8'h00;
        // A & B
        4'hC: Out <= argA & argB;
        // A | B
        4'hD: Out <= argA | argB;
        //Shift Left B << 1
        4'hE: Out <= argB << (immB?argA:1);
        //Shift Right B >> 1
        4'hF: Out <= argB >> (immB?argA:1);
        //Default A  
        default: Out <= IN_A;
      endcase
    end 
  end
  assign OUT_RESULT = Out;
endmodule
