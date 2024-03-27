localparam integer expected_duration = 1000;

`include "../../design/ir_transmitter/ir_transmitter_sm.sv"
`include "../../design/ir_transmitter/ir_consts.sv"

module IRTransmitter_SM_TB;
    logic RESET;
    logic CLK;
    logic [CMD_LEN-1:0] COMMAND;
    logic IR_LED;
    logic [$clog2(CAR_COUNT)-1:0] CAR_SWITCHES;
    logic [$clog2(CAR_COUNT)-1:0] LEDS;
    logic SEND_PACKET;

    // Instantiate the IRTransmitterSM module
    IRTransmitterSM transmitter(
        .RESET(RESET),
        .CLK(CLK),
        .COMMAND(COMMAND),
        .SEND_PACKET(SEND_PACKET),
        .IR_LED(IR_LED),
        .CAR_SWITCHES(CAR_SWITCHES),
        .LEDS(LEDS)
    );

    // -----------------------------
    // Clock generation
    // -----------------------------
    initial begin
        CLK = 0;
        forever #5 CLK = ~CLK; // 100MHz clock (10ns period, 5ns half period)
    end

    // -----------------------------
    // IMEDIATE assertions
    // -----------------------------

    // Asserting IR_LED stays active for a certain duration
    int start_time;
    always_ff @(posedge IR_LED) begin
        start_time = $time;
    end

    always_ff @(negedge IR_LED) begin
        int duration = $time - start_time;
        assert (duration > expected_duration) else $error("IR_LED duration does not match expected duration.");
    end

    // Counter for IR_LED toggles
    int ir_led_toggle_count = 0;
    bit last_ir_led_state = 0;

    // Test sequence
    initial begin
        // Initialize
        COMMAND = 4'b0101;
        CAR_SWITCHES = 2'b01;
        SEND_PACKET = 0;
        RESET = 1; #20;
        RESET = 0; #20;

        #10000;
        SEND_PACKET = 1;
        #10000;
        SEND_PACKET = 0;

        // Wait 120ms seconds
        #12000000;
        COMMAND = 4'b1010;

        // Wait 120 seconds
        #120000000;
        CAR_SWITCHES = 2'b11;

     end

endmodule
