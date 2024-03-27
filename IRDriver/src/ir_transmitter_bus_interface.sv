`include "consts.sv"

/**Provides an abstraction over the IR Transmitter module to allow for
 * addressing on a bus.
 * @param TRANSMISSION_FREQUENCY_HZ The frequency of the transmission
 * @param CAR_COUNT The number of cars
 * @param CMD_LEN The length of the command
 *
 * @input CLK The system clock
 * @input RESET The reset signal
 * @input BUS_DATA The data from the bus
 * @input BUS_ADDR The address of the bus
 * @input BUS_WE The write enable signal
 * @output IR_LED The IR LED signal
 * @output CAR_LEDS The car LEDs
 * @input CAR_SWITCHES The car switches
**/
module IRTransmitterBusInterface #(
    parameter TRANSMISSION_FREQUENCY_HZ = 10,
    parameter CAR_COUNT = 4,
    parameter CMD_LEN = 4
) (
    // Standard signals
    input CLK,
    input RESET,

    // BUS signals
    inout [BUS_MAX_INDEX:0] BUS_DATA,
    input [BUS_MAX_INDEX:0] BUS_ADDR,
    input BUS_WE,

    // IRTransmitter signals
    output logic IR_LED,
    output logic [$clog2(CAR_COUNT)-1:0] CAR_LEDS,
    input logic [$clog2(CAR_COUNT)-1:0] CAR_SWITCHES
);

    wire [BUS_MAX_INDEX:0] bus_in;
    reg [BUS_MAX_INDEX:0] bus_out;
    reg output_enable;

    logic [CMD_LEN-1:0] command;

    // Only place data on the bus if the processor is NOT writing, and it is
    // addressing this memory
    assign BUS_DATA = (output_enable) ? bus_out : 'hZZ;
    assign bus_in = BUS_DATA;

    always @(posedge CLK) begin
        if (RESET) begin
            output_enable <= 'b0;
            command <= 0;
        end else begin
            output_enable <= (!BUS_WE
                            & (BUS_ADDR == IR_TRANSMITTER_BASE_ADDR))
                            ? 1
                            : 0;

            command <= (BUS_WE
                        & (BUS_ADDR == IR_TRANSMITTER_BASE_ADDR))
                        ? bus_in[CMD_LEN-1:0]
                        : command;

            bus_out <= {'b0, command};
        end
    end

    IRTransmitter ir_transmitter (
        .RESET(RESET),
        .CLK(CLK),
        .IR_LED(IR_LED),
        .CAR_SWITCHES(CAR_SWITCHES),
        .LEDS(CAR_LEDS),
        .COMMAND(command)
    );

endmodule