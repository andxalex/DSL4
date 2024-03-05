`timescale 1ns / 1ps


module System (
    input         CLK,
    input         RESET,
    // CTRL
    input         BTN_L,
    input         BTN_R,
    // MOUSE
    inout         CLK_MOUSE,
    inout         DATA_MOUSE,
    // OUT
    output [15:0] LED_OUT,
    output [ 3:0] SEG_SELECT,
    output [ 7:0] DEC_OUT,
    output        VGA_HS,
    output        VGA_VS,
    output [ 7:0] VGA_COLOUR
);

  //////////////////////////////////////////////////////////////////////////////////
  // wires
  wire [7:0] bus_data;
  wire [7:0] bus_addr;
  wire bus_we;
  wire [7:0] rom_addr;
  wire [7:0] rom_data;
  wire [1:0] bus_interrupts_raise;
  wire [1:0] bus_interrupts_ack;

  //////////////////////////////////////////////////////////////////////////////////
  Processor ryzen_7800x3d (
      .CLK(CLK),
      .RESET(RESET),
      .BUS_DATA(bus_data),
      .BUS_ADDR(bus_addr),
      .BUS_WE(bus_we),
      .ROM_ADDRESS(rom_addr),
      .ROM_DATA(rom_data),
      .BUS_INTERRUPTS_RAISE(bus_interrupts_raise),
      .BUS_INTERRUPTS_ACK(bus_interrupts_ack)
  );
  //////////////////////////////////////////////////////////////////////////////////
  RAM Corsair_Vengeance_Black_32GB_7000MHz_DDR5 (
      .CLK(CLK),
      .BUS_DATA(bus_data),
      .BUS_ADDR(bus_addr),
      .BUS_WE(bus_we)
  );
  //////////////////////////////////////////////////////////////////////////////////
  ROM theres_no_fancy_rom_stick (
      .CLK(CLK),
      .BUS_DATA(rom_data),
      .BUS_ADDR(rom_addr)
  );
  //////////////////////////////////////////////////////////////////////////////////
  Timer same_as_above (
      .CLK(CLK),
      .RESET(RESET),
      .BUS_DATA(bus_data),
      .BUS_ADDR(bus_addr),
      .BUS_WE(bus_we),
      .BUS_INTERRUPT_RAISE(bus_interrupts_raise[0]),
      .BUS_INTERRUPT_ACK(bus_interrupts_ack[0])
  );
  //////////////////////////////////////////////////////////////////////////////////
  SegSevDriverIO Samsung_odyssey_neo_g9 (
      .CLK(CLK),
      .RESET(RESET),
      .BUS_DATA(bus_data),
      .BUS_ADDR(bus_addr),
      .BUS_WE(bus_we),
      .SEG_SELECT(SEG_SELECT),
      .DEC_OUT(DEC_OUT)
  );
  //////////////////////////////////////////////////////////////////////////////////
  LEDIO rgb (
      .CLK(CLK),
      .RESET(RESET),
      .BUS_DATA(bus_data),
      .BUS_ADDR(bus_addr),
      .BUS_WE(bus_we),
      .LED_OUT(LED_OUT)
  );
  //////////////////////////////////////////////////////////////////////////////////
  // Debounce buttons
  reg BtnLDly, BtnRDly;
  always @(posedge CLK) begin
    BtnLDly <= BTN_L;
    BtnRDly <= BTN_R;
  end

  MouseDriverIO logitech_g1_pro (
      .CLK(CLK),
      .RESET(RESET),
      .INC_SENS(BtnRDly & ~BTN_R),
      .RED_SENS(BtnLDly & ~BTN_L),
      .BUS_DATA(bus_data),
      .BUS_ADDR(bus_addr),
      .BUS_WE(bus_we),
      .CLK_MOUSE(CLK_MOUSE),
      .DATA_MOUSE(DATA_MOUSE),
      .BUS_INTERRUPT_RAISE(bus_interrupts_raise[1]),
      .BUS_INTERRUPT_ACK(bus_interrupts_ack[1])
  );
  //////////////////////////////////////////////////////////////////////////////////
  VGADriverIO to_mouni (
      .CLK(CLK),
      .RESET(RESET),
      .ADDRESS(bus_addr),
      .DATA(bus_data),
      .BUS_WE(bus_we),
      .VGA_HS(VGA_HS),
      .VGA_VS(VGA_VS),
      .VGA_COLOUR(VGA_COLOUR)
  );

  //////////////////////////////////////////////////////////////////////////////////
endmodule
