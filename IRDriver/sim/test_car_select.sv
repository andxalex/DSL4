`include "../../design/consts.sv"

// Testbench for CarSelect module
module CarSelect_TB;
    logic [$clog2(CAR_COUNT)-1:0] switches;
    logic [$clog2(CAR_COUNT)-1:0] leds;
    CarSettings selected_car;

    CarSelect UUT(
        .switches(switches),
        .selectedCar(selected_car),
        .leds(leds)
    );

    // Subroutine for running an assertion test and reporting the result
    task automatic run_test(input bit[1:0] switch_val, CarSettings expected_car, input string carName);
        switches = switch_val;
        #10;

        // Display initial part of the message without a newline
        $write("%0t: switches == 2'b%2b... ", $time, switch_val);

        // Perform the assertion check and display the result
        assert (selected_car == expected_car) begin
            $display("selectedCar == %0s... OK", carName);
        end else begin
            $display("selectedCar == %0s... FAIL", carName);
        end
    endtask

    // Test cases
    initial begin
        // Test case 1: switches = 2'b00
        run_test(2'b00, BLUE_PARAMS, "BLUE_PARAMS");

        // Test case 2: switches = 2'b01
        run_test(2'b01, YELLOW_PARAMS, "YELLOW_PARAMS");

        // Test case 3: switches = 2'b10
        run_test(2'b10, GREEN_PARAMS, "GREEN_PARAMS");

        // Test case 4: switches = 2'b11
        run_test(2'b11, RED_PARAMS, "RED_PARAMS");

        $error("Testbench finished");
    end
endmodule

