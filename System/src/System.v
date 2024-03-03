`timescale 1ns / 1ps


module System (
    input CLK,
    input RESET,
    // CTRL
    // input BTN_L,
    // input BTN_R,
    // MOUSE
    inout CLK_MOUSE,
    inout DATA_MOUSE,
    // OUT
    // output [15:0] LED_OUT,
    output [3:0] SEG_SELECT,
    output [7:0] DEC_OUT
);

  // wires
  wire [7:0] bus_data;
  wire [7:0] bus_addr;
  wire bus_we;
  wire [7:0] rom_addr;
  wire [7:0] rom_data;
  wire [1:0] bus_interrupt_raise;
  wire [1:0] bus_interrupts_ack;


  Processor ryzen_7800x3d (
      .CLK(CLK),
      .RESET(RESET),
      .BUS_DATA(bus_data),
      .BUS_ADDR(bus_addr),
      .BUS_WE(bus_we),
      .ROM_ADDRESS(rom_addr),
      .ROM_DATA(rom_data),
      .BUS_INTERRUPT_RAISE(bus_interrupt_raise),
      .BUS_INTERRUPTS_ACK(bus_interrupts_ack)
  );

  RAM Corsair_Vengeance_Black_32GB_7000MHz_DDR5 (
      .CLK(CLK),
      .BUS_DATA(bus_data),
      .BUS_ADDR(bus_addr),
      .BUS_WE(bus_we)
  );

  ROM theres_no_fancy_rom_stick (
      .CLK(CLK),
      .BUS_DATA(bus_data),
      .BUS_ADDR(bus_addr),
      .BUS_WE(bus_we)
  );

  Timer same_as_above (
      .CLK(CLK),
      .RESET(RESET),
      .BUS_DATA(bus_data),
      .BUS_ADDR(bus_addr),
      .BUS_WE(bus_we),
      .BUS_INTERRUPT_RAISE(bus_interrupt_raise[0]),
      .BUS_INTERRUPT_ACK(bus_interrupts_ack[0])
  );

  SegSevDriverIO Samsung_odyssey_neo_g9 (
      .CLK(CLK),
      .RESET(RESET),
      .BUS_DATA(bus_data),
      .BUS_ADDR(bus_addr),
      .BUS_WE(bus_we),
      .SEG_SELECT(SEG_SELECT),
      .DEC_OUT(DEC_OUT)
  );

endmodule
