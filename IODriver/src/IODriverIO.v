`timescale 1ns / 1ps


module IODriverIO (
    input         CLK,
    input         RESET,
    // CTRL
    input         BTN_L,
    input         BTN_R,
    input         BTN_U,
    input         BTN_D,
    input  [15:0] SLIDE_S,
    // BUS
    inout  [ 7:0] BUS_DATA,
    inout  [ 7:0] BUS_ADDR,
    input         BUS_WE,
    // Additional
    output  [15:0] test
);

  // Wires
  wire r_nedge_deb;
  wire l_nedge_deb;
  wire u_nedge_deb;
  wire d_nedge_deb;

  // Debounce and detect negative edges.
  NegEdgeDetector btn_r (
    .CLK(CLK),
    .RESET(RESET),
    .IN(BTN_R),
    .OUT(r_nedge_deb)
  );

  NegEdgeDetector btn_l (
    .CLK(CLK),
    .RESET(RESET),
    .IN(BTN_L),
    .OUT(l_nedge_deb)
  );

  NegEdgeDetector btn_u (
    .CLK(CLK),
    .RESET(RESET),
    .IN(BTN_U),
    .OUT(u_nedge_deb)
  );

  NegEdgeDetector btn_d (
    .CLK(CLK),
    .RESET(RESET),
    .IN(BTN_D),
    .OUT(d_nedge_deb)
  );

  // Also debouncing for side switches
  wire [15:0] slide_switches;

  genvar j;
  generate
    for (j=0; j < 16; j=j+1) begin
      BtnDebounce slide_s (
        .CLK(CLK),
        .RESET(RESET),
        .BTN(SLIDE_S[j]),
        .DB_BTN(slide_switches[j])
      );
    end
  endgenerate

  // Register bank, holds device state
  reg [7:0] regBank[2:0];

  // Tristate
  wire [7:0] BufferedBusData;
  reg [7:0] DataBusOut;
  reg DataBusOutWE;

  // The register bank is effectively an extension of Data memory. The Base address below 
  // corresponds to regBank[0]
  parameter BaseAddr = 8'hE0;

  // Only place data on the bus if processor is not writing, and address is within range
  assign BUS_DATA = (DataBusOutWE) ? DataBusOut : 8'hZZ;

  // Buffer 
  assign BufferedBusData = BUS_DATA;
  
  integer i;
  always @(posedge CLK) begin
    if (RESET) begin
      DataBusOutWE <= 1'b0;
      for (i=0; i<3; i=i+1) regBank[i] <= 8'h00;
    end else begin
      // Small trick to maintain button status until it is lowered by the processor
      regBank[0] <= {4'h0, r_nedge_deb, l_nedge_deb, u_nedge_deb, d_nedge_deb} | regBank[0];
      
      // Slide switches are permanent, can't be modified by processor.
      regBank[1] <= slide_switches[7:0]; 
      regBank[2] <= slide_switches[15:8]; 

      // This assignment takes priority over the one above.
      if ((BUS_ADDR >= BaseAddr) & (BUS_ADDR < (BaseAddr + 3))) begin
        if (BUS_WE) begin
          DataBusOutWE <= 1'b0;
          if (BUS_ADDR == BaseAddr) regBank[BUS_ADDR - BaseAddr] <= BufferedBusData;
        end else DataBusOutWE <= 1'b1;
      end else DataBusOutWE <= 1'b0;
    end
    DataBusOut <= regBank[BUS_ADDR-BaseAddr];
  end

  assign test = {regBank[2],4'h0,regBank[0][3:0]};
endmodule