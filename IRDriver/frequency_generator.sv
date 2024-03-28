`include "consts.sv"


// Creates a clock signal with a frequency of the clock_frequcency/max_counter_value
// An output pulse is created as well as a squarewave
//
// @param sys_clk: The input clock signal
// @param out_clk: The output clock signal
// @param out_pulse: The output pulse signal
// @param max_counter_value: The maximum value the counter can reach
// @param reset: The reset signal
//
// It was considerd to make this more generic and allow sys clk to be any clk
// but then you are creating a divider not clocked off the system clock, thereby
// creating asynchronicous logic which is not recommended.
//
// NB: Whilst max_counter_value is of `integer` which can lead to code which
// does not synthesize it is there as a run time parameter which can be only
// be passed a set of values which are constant and of integer type. This
// allows the compiler to dynamically use the correct register width and
// discard the unused bits.
module FrequencyGenerator(
    input logic sys_clk,
    output logic out_clk,
    output logic out_pulse,
    input integer max_counter_value,
    input logic reset
);
    logic[INT_SIZE-1:0] counter = 0;

    always @(posedge sys_clk) begin
        if (reset) begin
            counter <= 0;
            out_clk <= 0;
            out_pulse <= 0;
        end else begin
            counter <= (counter == max_counter_value - 1) ? 0 : counter + 1;
            out_clk <= (counter < max_counter_value / 2) ? 1'b1 : 1'b0;
            out_pulse <= (counter == 0) ? 1'b1 : 1'b0;
        end
    end;
endmodule