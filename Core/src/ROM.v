`timescale 1ns / 1ps

module ROM (
    //standard signals
    input            CLK,
    //BUS signals
    output reg [7:0] BUS_DATA,
    input      [7:0] BUS_ADDR
);

  parameter RAMAddrWidth = 8;

  //Memory
  reg [7:0] ROM[2**RAMAddrWidth-1:0];

  // Load program
  initial $readmemh("Complete_Demo_ROM.txt", ROM);

  //single port ram
  always @(posedge CLK) BUS_DATA <= ROM[BUS_ADDR];

endmodule
