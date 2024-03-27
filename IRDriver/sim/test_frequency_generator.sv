`include "../../design/frequency_generator.sv"
`include "../../design/ir_transmitter/ir_consts.sv"

module FrequencyGenerator_stability_TB;

    // Inputs
    logic clk;
    logic out_clk;
    logic out_pulse;
    logic[INT_SIZE-1:0] max_counter_value;
    logic reset;

    localparam logic[INT_SIZE-1:0] STABLE_CYCLES = 5; // Number of cycles the signal must remain stable

    FrequencyGenerator UUT(
        .sys_clk(clk),
        .out_clk(out_clk),
        .out_pulse(out_pulse),
        .max_counter_value(max_counter_value),
        .reset(reset)
    );

    initial begin
        reset = 1;
        #10 reset = 0;

        clk = 1'b1; // Initializing sys_clk to 1
        max_counter_value = STABLE_CYCLES * 2;

        forever #5 clk = ~clk; // Generate a 100MHz sys_clk (5ns 1/2 period
    end

    // Vivaldo doesn't support system verilog assertions and just ignores them
    // in the code:
    // https://support.xilinx.com/s/question/0D52E00006hpbFESAY/vivado-and-assertions?language=en_US
    // They are working on adding support but these haven't been added suppoprt
    // for just yet. For now here are the SVA which I would have liked be able
    // to use:
    //
    // -------------------------------------------------------------------------
    // Define a property for stability
    // property signal_stable_after_rise;
    //     @(posedge clk)
    //     $rose(out_clk) |-> ##[1:STABLE_CYCLES] ($stable(out_clk));
    // endproperty

    // // Assert the property
    // assert property (signal_stable_after_rise)
    //     else $error("Signal did not remain stable for %0d cycles after rising", STABLE_CYCLES);
    // -------------------------------------------------------------------------

    // The same assertion but converted into an immediate assertion
    always @(posedge clk) begin
        if ($rose(out_clk)) begin
            logic[INT_SIZE-1:0] cycles_stable = 1;
            // Check stability for the next STABLE_CYCLES cycles
            repeat (STABLE_CYCLES - 1) begin
                @(posedge clk);
                if (out_clk !== 1'b1) begin
                    $error("Signal did not remain stable at cycle %0d", cycles_stable);
                    break;
                end
                cycles_stable++;
            end
            $display("%0t ns clock stability test... ok", $time);
        end
    end
endmodule


// Build a counter outside of the main module to test the FrequencyGenerator
// Also verifies that the RESET actually resets the state of the simulation
// checks that the frequency generator argees with an external counter
module FrequencyGenerator_counter_TB;
    logic sys_clk;
    logic out_clk;
    logic out_pulse;
    logic[INT_SIZE-1:0] max_counter_value = 10;
    logic[INT_SIZE-1:0] counter;
    logic[INT_SIZE-1:0] counter_values[5] = '{10, 20, 50, 128, 256};
    logic reset;

    FrequencyGenerator uut (
        .sys_clk(sys_clk),
        .out_clk(out_clk),
        .out_pulse(out_pulse),
        .max_counter_value(max_counter_value),
        .reset(reset)
    );

    always begin
        #5 sys_clk = ~sys_clk;
    end

    initial begin
        sys_clk = 0;
        counter = 0;

        // Test different counter values
        foreach (counter_values[i]) begin
            max_counter_value = counter_values[i];
            reset = 1;
            @(posedge sys_clk)
            repeat (max_counter_value * 2) begin
                @(posedge sys_clk);
                if (out_pulse) begin
                    if (counter != max_counter_value) begin
                        $error("Error: Counter should be %0d, but it's %0d", max_counter_value, counter);
                    end
                    counter = 0;
                end else begin
                    counter = counter + 1;
                end
            end
            $display("Counter value %0d... ok", counter);
        end

        $finish;
    end
endmodule
