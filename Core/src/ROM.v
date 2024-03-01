module ROM (
    //standard signals
    input            CLK,
    //BUS signals
    output reg [7:0] DATA,
    input      [7:0] ADDR
);

  parameter RAMAddrWidth = 8;

  //Memory
  reg [7:0] ROM[2**RAMAddrWidth-1:0];

  // Load program
  initial $readmemh("Complete_Demo_ROM.txt", ROM);

  //single port ram
  always @(posedge CLK) DATA <= ROM[ADDR];

endmodule
