`include "car_select.sv"
`include "frequency_generator.sv"
`include "ir_consts.sv"

// Progresses through a state machine which represents the different stages of
// the packet with which to send to the car. Each state contains the value
// for how many car clock cycles to assert the IR LED for. After it has been
// asserted for the given time the state machine will progress to the next state
// After each LED asserted state the state machine will progress to a gap state.
// Once the end of the packet is reached the statemachine will remain in the
// IDLE state until the SEND_PACKET signal is asserted again.
//
// Internally the state machine uses a counter to keep track of how many car
// clock cycles have passed. Once the counter reaches the value for the current
// at the end of each
//
// @param RESET: The reset signal
// @param CLK: The system clock
// @param COMMAND: The command to send to the car
// @param CAR_SWITCHES: The switches to select the car
// @param SEND_PACKET: The signal to send the packet
// @param LEDS: The lights above the switches
// @param IR_LED: The signal to assert the IR LED
//
module IRTransmitterSM #(
    parameter CAR_COUNT = 4,
    parameter CMD_LEN = 4,
    parameter CMD_LEFT_BIT = 0,
    parameter CMD_RIGHT_BIT = 1,
    parameter CMD_BACK_BIT = 2,
    parameter CMD_FORWARD_BIT = 3
) (
    input logic RESET,
    input logic CLK,
    input logic [CMD_LEN-1:0] COMMAND,
    input logic [$clog2(CAR_COUNT)-1:0] CAR_SWITCHES,
    output logic [$clog2(CAR_COUNT)-1:0] LEDS,
    input logic SEND_PACKET,
    output logic IR_LED
);
    logic car_clk;
    logic car_clk_pulse;
    logic move_state;
    logic [INT_SIZE-1:0] pulseCounter;
    logic [INT_SIZE-1:0] burstSize;
    State currentState;
    State nextState;
    CarSettings selected_car;
    integer right_burst_size, left_burst_size, backward_burst_size, forward_burst_size;

    // ----------------------------------------
    // Submodules initstanation
    // ----------------------------------------
    CarSelect #(
        .CAR_COUNT(CAR_COUNT)
    ) car_select(
        .switches(CAR_SWITCHES),
        .selectedCar(selected_car),
        .leds(LEDS)
    );

    FrequencyGenerator car_clk_gen(.sys_clk(CLK),
                                   .out_clk(car_clk),
                                   .out_pulse(car_clk_pulse),
                                   .max_counter_value(selected_car.SYS_CLK_COUNTER_MAX),
                                   .reset(RESET));

    // ----------------------------------------
    // Sequential logic
    // ----------------------------------------
    // Handles the case of:
    // RESET - Reset the state machine
    // SEND_PACKET - Start the state machine
    // move_state - Progress the state machine
    // The state machine will default to incrementing the pulse counter with
    // every car clock pulse (which only occurs at the start of each of the
    // car clk cycles)
    always @(posedge CLK) begin
        if (RESET) begin
            currentState <= CAR_IDLE;
            pulseCounter <= 0;
        end else if (SEND_PACKET) begin
            currentState <= START;
            pulseCounter <= 0;
        end else if (move_state) begin
            currentState <= nextState;
            pulseCounter <= 0;
        end else begin
            if (car_clk_pulse) begin
                pulseCounter <= pulseCounter + 1;
            end
        end
    end

    always_comb begin
        // ----------------------------------------
        // If we have been in the current state for enough car clock cycles
        // move to the next state.
        move_state = (pulseCounter >= burstSize - 1) ? 1 : 0;

        // ----------------------------------------
        // Define the state relations and properties
        right_burst_size =    (COMMAND[CMD_LEFT_BIT])    ? selected_car.ASSERT_SIZE : selected_car.DEASSERT_SIZE;
        left_burst_size =     (COMMAND[CMD_RIGHT_BIT])   ? selected_car.ASSERT_SIZE : selected_car.DEASSERT_SIZE;
        backward_burst_size = (COMMAND[CMD_BACK_BIT])    ? selected_car.ASSERT_SIZE : selected_car.DEASSERT_SIZE;
        forward_burst_size =  (COMMAND[CMD_FORWARD_BIT]) ? selected_car.ASSERT_SIZE : selected_car.DEASSERT_SIZE;

        case (currentState)
            START:      begin nextState = GAP_0;      burstSize = selected_car.START_SIZE;      end
            GAP_0:      begin nextState = CAR_SELECT; burstSize = selected_car.GAP_SIZE;        end
            CAR_SELECT: begin nextState = GAP_1;      burstSize = selected_car.SELECT_SIZE;     end
            GAP_1:      begin nextState = RIGHT;      burstSize = selected_car.GAP_SIZE;        end
            RIGHT:      begin nextState = GAP_2;      burstSize = right_burst_size;             end
            GAP_2:      begin nextState = LEFT;       burstSize = selected_car.GAP_SIZE;        end
            LEFT:       begin nextState = GAP_3;      burstSize = left_burst_size;              end
            GAP_3:      begin nextState = BACKWARD;   burstSize = selected_car.GAP_SIZE;        end
            BACKWARD:   begin nextState = GAP_4;      burstSize = backward_burst_size;          end
            GAP_4:      begin nextState = FORWARD;    burstSize = selected_car.GAP_SIZE;        end
            FORWARD:    begin nextState = GAP_5;      burstSize = forward_burst_size;           end
            GAP_5:      begin nextState = CAR_IDLE;       burstSize = selected_car.GAP_SIZE;    end
        default:
            nextState = CAR_IDLE;
        endcase

        // ----------------------------------------
        // Modulate the IR LED at the car clock frequency
        if (currentState inside {START, CAR_SELECT, RIGHT, LEFT, BACKWARD, FORWARD}) begin
            IR_LED = car_clk;
        end else begin
            IR_LED = 0;
        end
    end

endmodule