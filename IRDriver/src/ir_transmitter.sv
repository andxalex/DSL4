`include "ir_consts.sv"
`include "../frequency_generator.sv"
`include "ir_transmitter_sm.sv"

// The top level module for the IR transmitter. This module contains the state
// machine and a timer which triggers it once per second as specified.
// The parameter TRANSMISSION_FREQUENCY_HZ is used to specify the frequency at
// which the packets should be sent.
//
// @param RESET: The reset signal
// @param CLK: The system clock
// @param COMMAND: The command to send to the car 4 bit vector
// @param CAR_SWITCHES: The switches to select the car
// @param LEDS: The lights above the switches
// @param IR_LED: The signal to assert the IR LED
module IRTransmitter #(
    parameter TRANSMISSION_FREQUENCY_HZ = 10,
    parameter CAR_COUNT = 4,
    parameter CMD_LEN = 4
) (
    input logic RESET,
    input logic CLK,
    input logic [CMD_LEN-1:0] COMMAND,
    input logic [$clog2(CAR_COUNT)-1:0] CAR_SWITCHES,
    output logic [$clog2(CAR_COUNT)-1:0] LEDS,
    output logic IR_LED
);
    logic transmission_clk;
    logic IR_LED;
    logic send_packet;

    localparam integer SEND_COUNTER_MAX = SYS_CLK_FREQ_HZ/TRANSMISSION_FREQUENCY_HZ;

    IRTransmitterSM #(
        .CAR_COUNT(CAR_COUNT),
        .CMD_LEN(CMD_LEN)
    ) transmitter(
        .RESET(RESET),
        .CLK(CLK),
        .COMMAND(COMMAND),
        .CAR_SWITCHES(CAR_SWITCHES),
        .SEND_PACKET(send_packet),
        .LEDS(LEDS),
        .IR_LED(IR_LED)
    );

    FrequencyGenerator send_clk_gen(.sys_clk(CLK),
                                    .out_clk(transmission_clk),
                                    .out_pulse(send_packet),
                                    .max_counter_value(SEND_COUNTER_MAX),
                                    .reset(RESET));

endmodule
