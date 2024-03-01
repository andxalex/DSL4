module ROM(
//standard signals
);
endmodule
input
//BUS signals output reg input
[7:0] [7:0]
CLK,
DATA, ADDR
= 8;
parameter RAMAddrWidth
//Memory
reg [7:0] ROM [2**RAMAddrWidth-1:0];
// Load program
initial $readmemh("Complete_Demo_ROM.txt", ROM);
//single port ram always@(posedge CLK)
DATA <= ROM[ADDR];