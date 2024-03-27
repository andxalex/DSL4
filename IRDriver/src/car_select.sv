`include "ir_consts.sv"

// Use the switches on the board to allow the user to select the car
// Set the lights above the switches to make it clear which car is selected
// @param switches: The switches on the board
// @param selectedCar: The struct representing the selected car settings
// @param leds: The lights above the switches
//
module CarSelect# (
    parameter CAR_COUNT = 4
) (
    input logic [$clog2(CAR_COUNT)-1:0] switches,
    output logic [$clog2(CAR_COUNT)-1:0] leds,
    output CarSettings selectedCar
);
    always_comb begin
        leds = switches;

        case (switches)
            2'b00: selectedCar = BLUE_PARAMS;
            2'b01: selectedCar = YELLOW_PARAMS;
            2'b10: selectedCar = GREEN_PARAMS;
            2'b11: selectedCar = RED_PARAMS;
            default: selectedCar = BLUE_PARAMS; // Default to BLUE if switches are in an invalid state
        endcase
    end
endmodule

