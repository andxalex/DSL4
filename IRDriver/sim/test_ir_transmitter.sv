`include "../../design/ir_transmitter/ir_transmitter.sv"
`include "../../design/ir_transmitter/ir_consts.sv"

//
// This file contains the testbench for the IR transmitter module.
// It is used to simulate the functionality of the IR transmitter and verify its behavior
module IRTransmitter_TB;
    logic RESET;
    logic CLK;
    logic [CAR_COUNT-1:0] COMMAND;
    logic IR_LED;
    logic [$clog2(CAR_COUNT)-1:0] CAR_SWITCHES;
    logic [$clog2(CAR_COUNT)-1:0] LEDS;

    // Instantiate the IRTransmitterSM module
    IRTransmitter transmitter(
        .RESET(RESET),
        .CLK(CLK),
        .COMMAND(COMMAND),
        .IR_LED(IR_LED),
        .CAR_SWITCHES(CAR_SWITCHES),
        .LEDS(LEDS)
    );

    // Clock generation
    initial begin
        CLK = 0;
        forever #5 CLK = ~CLK; // 100MHz clock (10ns period, 5ns half period)
    end

    // Test sequence
    initial begin
        // Initialize
        #20;
        RESET = 1; #20;
        RESET = 0; #20;
        COMMAND = 4'b0101;
        CAR_SWITCHES = 2'b00;

        // Wait 210ms second
        #21000000;

        COMMAND = 4'b1010;
     end
endmodule

// Count the number of IR LED pulses and check that they add up to the expected
// total number
module IRTransmitter_count_pulses_TB#(
    parameter CAR_COUNT = 4,
    parameter CMD_LEN = 4,
    parameter CMD_LEFT_BIT = 0,
    parameter CMD_RIGHT_BIT = 1,
    parameter CMD_BACK_BIT = 2,
    parameter CMD_FORWARD_BIT = 3
);
    logic RESET;
    logic CLK;
    logic [CMD_LEN-1:0] COMMAND;
    logic IR_LED;
    logic [$clog2(CAR_COUNT)-1:0] CAR_SWITCHES;
    logic [$clog2(CAR_COUNT)-1:0] LEDS;

    CarSettings car_settings;
    integer ir_led_pulse_count;
    integer expected_ir_led_pulse_count;
    logic prev_ir_led_state;
    integer right_burst_size, left_burst_size, backward_burst_size, forward_burst_size;


    IRTransmitter transmitter(
        .RESET(RESET),
        .CLK(CLK),
        .COMMAND(COMMAND),
        .IR_LED(IR_LED),
        .CAR_SWITCHES(CAR_SWITCHES),
        .LEDS(LEDS)
    );

    // Create a car select module as a convient way to translate between the
    // switch state and the car settings
    CarSelect car_select(
        .switches(CAR_SWITCHES),
        .selectedCar(car_settings),
        .leds(LEDS)
    );

    // Clock generation
    initial begin
        CLK = 0;
        forever #5 CLK = ~CLK; // 100MHz clock (10ns period, 5ns half period)
    end

    // Counting IR_LED pulses
    always @(posedge CLK or posedge RESET) begin
        if (RESET) begin
            ir_led_pulse_count <= 0;
            prev_ir_led_state <= 0;
        end else if (IR_LED && !prev_ir_led_state) begin
            ir_led_pulse_count <= ir_led_pulse_count + 1;
        end
        prev_ir_led_state <= IR_LED;
    end

    initial begin
        // Check a variety of different commands
        for (int i = 0; i < 8; i++) begin
            case (i)
                0: COMMAND = 4'b0000;
                1: COMMAND = 4'b1010;
                2: COMMAND = 4'b0101;
                3: COMMAND = 4'b1111;
                4: COMMAND = 4'b1000;
                5: COMMAND = 4'b0100;
                6: COMMAND = 4'b0010;
                7: COMMAND = 4'b0001;
            endcase

            // Check that it works for each of the different cars
            for (int car_index = 0; car_index < 4; car_index++) begin
                RESET = 1; #20;
                RESET = 0; #20;
                COMMAND = 4'b0101;
                CAR_SWITCHES = car_index;

                // Wait 50ms
                #5000000;

                right_burst_size =    (COMMAND[CMD_LEFT_BIT])    ? car_settings.ASSERT_SIZE : car_settings.DEASSERT_SIZE;
                left_burst_size =     (COMMAND[CMD_RIGHT_BIT])   ? car_settings.ASSERT_SIZE : car_settings.DEASSERT_SIZE;
                backward_burst_size = (COMMAND[CMD_BACK_BIT])    ? car_settings.ASSERT_SIZE : car_settings.DEASSERT_SIZE;
                forward_burst_size =  (COMMAND[CMD_FORWARD_BIT]) ? car_settings.ASSERT_SIZE : car_settings.DEASSERT_SIZE;

                expected_ir_led_pulse_count = car_settings.START_SIZE
                                                + right_burst_size
                                                + left_burst_size
                                                + forward_burst_size
                                                + backward_burst_size;

                assert(ir_led_pulse_count == expected_ir_led_pulse_count);
            end
        end
     end
endmodule
