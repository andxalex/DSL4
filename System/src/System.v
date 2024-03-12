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

  // additional
  wire [7:0] processor_state;
  wire [7:0] x;
  wire [7:0] y;
  wire [7:0] rega;
  wire interrupt;

  //////////////////////////////////////////////////////////////////////////////////
  // Debounce buttons
  reg BtnLDly, BtnRDly;
  always @(posedge CLK) begin
    BtnLDly <= BTN_L;
    BtnRDly <= BTN_R;
  end

  // USE BELOW TO CONTROL PROCESSOR FLOW
  // assign bus_interrupts_raise[1] = BTN_L;
  // assign bus_interrupts_raise[0] = 1'b0;  //BTN_R;
  reg [15:0] debounce_counter;
  reg deb;
  reg deb_last;  // To detect the transition and generate a single pulse

  always @(posedge CLK) begin
    if (BTN_R) begin
      debounce_counter <= (debounce_counter == 16'hFFFF) ? 16'hFFFF : debounce_counter + 1;
      // Generate a pulse when the counter transitions from 16'hFFFE to 16'hFFFF
      if (debounce_counter == 16'hFFFE) begin
        deb <= 1'b1;
      end else if (deb != deb_last) begin
        deb <= 1'b0;  // Ensure deb goes low after the pulse
      end
      deb_last <= deb;  // Update last debounced value
    end else begin
      debounce_counter <= 0;  // Reset counter when BTN_R is not pressed
      deb <= 0;  // Ensure deb is low when BTN_R is not pressed
      deb_last <= 0;  // Reset last debounced value
    end
  end


  Processor ryzen_7800x3d (
      .CLK(CLK),
      .RESET(RESET),
      .BUS_DATA(bus_data),
      .BUS_ADDR(bus_addr),
      .BUS_WE(bus_we),
      .ROM_ADDRESS(rom_addr),
      .ROM_DATA(rom_data),
      .BUS_INTERRUPTS_RAISE({bus_interrupts_raise[1], bus_interrupts_raise[0]}),
      .BUS_INTERRUPTS_ACK(bus_interrupts_ack),

      // Test
      .state(processor_state),
      .regA (rega)
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
      .BUS_INTERRUPT_RAISE(bus_interrupts_raise[1]),
      .BUS_INTERRUPT_ACK(bus_interrupts_ack[1])
  );
  //////////////////////////////////////////////////////////////////////////////////
  SegSevDriverIO Samsung_odyssey_neo_g9 (
      .CLK(CLK),
      .CLK2(CLK),
      .RESET(RESET),
      .BUS_DATA(bus_data),
      .BUS_ADDR(bus_addr),
      .BUS_WE(bus_we),
      .SEG_SELECT(SEG_SELECT),
      .DEC_OUT(DEC_OUT)
  );

  //   Seg7Display S7 (
  //       .IN_A(bus_addr[3:0]),
  //       .IN_B(bus_addr[7:4]),
  //       .IN_C(rega[3:0]),
  //       .IN_D(rega[7:4]),
  //       .CLK(CLK),
  //       .SEG_SELECT(SEG_SELECT),
  //       .DEC_OUT(DEC_OUT)
  //   );

  //////////////////////////////////////////////////////////////////////////////////
  //   LEDIO rgb (
  //       .CLK(CLK),
  //       .RESET(RESET),
  //       .BUS_DATA(bus_data),
  //       .BUS_ADDR(bus_addr),
  //       .BUS_WE(bus_we),
  //       .LED_OUT(LED_OUT)
  //   );

  assign LED_OUT = {processor_state, processor_state};

  //////////////////////////////////////////////////////////////////////////////////


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
      .BUS_INTERRUPT_RAISE(bus_interrupts_raise[0]),
      .BUS_INTERRUPT_ACK(bus_interrupts_ack[0]),
      .X(x),
      .Y(y),
      .SEND_INTERRUPT(interrupt)
  );

  //////////////////////////////////////////////////////////////////////////////////
    VGADriverIO_2 to_mouni (
        .CLK(CLK),
        .RESET(RESET),
        .BUS_ADDR(bus_addr),
        .BUS_DATA(bus_data),
        .BUS_WE(bus_we),
        .VGA_HS(VGA_HS),
        .VGA_VS(VGA_VS),
        .VGA_COLOUR(VGA_COLOUR)
    );

  //////////////////////////////////////////////////////////////////////////////////


endmodule
