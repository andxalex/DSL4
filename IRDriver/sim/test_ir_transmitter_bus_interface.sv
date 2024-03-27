`include "../../design/consts.sv"
`include "../../design/ir_transmitter/ir_consts.sv"

module IRTransmitterBusInterfaceTB;

logic CLK;
logic RESET;

wire [BUS_MAX_INDEX:0] BUS_DATA;
wire [BUS_MAX_INDEX:0] BUS_ADDR;
wire BUS_WE;

// IRTransmitter signals
logic IR_LED;
logic [$clog2(CAR_COUNT)-1:0] CAR_LEDS;
logic [$clog2(CAR_COUNT)-1:0] CAR_SWITCHES;

logic [BUS_MAX_INDEX:0] bus_data_in;
logic [BUS_MAX_INDEX:0] bus_data_out;
logic [BUS_MAX_INDEX:0] bus_addr;
logic bus_data_outWE;

assign bus_data_in = BUS_DATA;

assign BUS_DATA           = bus_data_outWE ? bus_data_out : 8'hZZ;
assign BUS_WE             = bus_data_outWE;
assign BUS_ADDR           = bus_addr;

// Instantiate the IRTransmitterBusInterface module
IRTransmitterBusInterface #(
    .TRANSMISSION_FREQUENCY_HZ(10),
    .CAR_COUNT(4),
    .CMD_LEN(4)
) ir_transmitter_bus_interface_0 (
    .CLK(CLK),
    .RESET(RESET),
    .BUS_DATA(BUS_DATA),
    .BUS_ADDR(BUS_ADDR),
    .BUS_WE(BUS_WE),
    .IR_LED(IR_LED),
    .CAR_LEDS(CAR_LEDS),
    .CAR_SWITCHES(CAR_SWITCHES)
);


// Clock generation
initial begin
    CLK = 1;
    forever #5 CLK = ~CLK; // 100MHz clock (10ns period, 5ns half period)
end

initial begin
    // Initialize
    #10;
    RESET = 1;
    bus_data_outWE = 1'b0;
    bus_addr = 8'h00;
    bus_data_out = 8'h00;
    CAR_SWITCHES = 2'b00;
    #10;
    RESET = 0;
    #10;
    #10;
    // Write forwards to the bus
    $display("IR_TRANSMITTER_BASE_ADDR = %h", IR_TRANSMITTER_BASE_ADDR);
    bus_addr = IR_TRANSMITTER_BASE_ADDR;
    bus_data_out = 4'b0101;
    bus_data_outWE = 1'b1;
    #10;
    bus_data_outWE = 1'b0;

    // Wait 210ms second
    #21000000;

end

endmodule


module IRTransmitterBusInterface_AssertionBased_tb;

    // Parameters
    parameter CLK_PERIOD = 10; // Clock period in ns
    parameter CAR_COUNT = 4;
    parameter CMD_LEN = 4;

    // Signals
    logic CLK;
    logic RESET;
    wire [BUS_MAX_INDEX:0] BUS_DATA;
    wire [BUS_MAX_INDEX:0] BUS_ADDR;
    wire BUS_WE;

    // IRTransmitter signals
    logic IR_LED;
    logic [$clog2(CAR_COUNT)-1:0] CAR_LEDS;
    logic [$clog2(CAR_COUNT)-1:0] CAR_SWITCHES;

    logic [BUS_MAX_INDEX:0] bus_data_in;
    logic [BUS_MAX_INDEX:0] bus_data_out;
    logic [BUS_MAX_INDEX:0] bus_addr;
    logic bus_data_outWE;

    assign bus_data_in = BUS_DATA;

    assign BUS_DATA           = bus_data_outWE ? bus_data_out : 8'hZZ;
    assign BUS_WE             = bus_data_outWE;
    assign BUS_ADDR           = bus_addr;

    // DUT instantiation
    IRTransmitterBusInterface #(
        .TRANSMISSION_FREQUENCY_HZ(10),
        .CAR_COUNT(CAR_COUNT),
        .CMD_LEN(CMD_LEN)
    ) dut (
        .CLK(CLK),
        .RESET(RESET),
        .BUS_DATA(BUS_DATA),
        .BUS_ADDR(BUS_ADDR),
        .BUS_WE(BUS_WE),
        .IR_LED(IR_LED),
        .CAR_LEDS(CAR_LEDS),
        .CAR_SWITCHES(CAR_SWITCHES)
    );

    // Clock generation
    initial begin
        CLK <= 1;
        forever CLK <= #5 ~CLK;
    end

    // Assertions
    always @(posedge CLK) begin
        // Assert output enable only active when not writing (BUS_WE = 0) and
        // addressing the IR transmitter (BUS_ADDR == IR_TRANSMITTER_BASE_ADDR)
        assert (!(~BUS_WE & (BUS_ADDR == IR_TRANSMITTER_BASE_ADDR)) | (dut.output_enable == 1));

        // Assert bus data driven only when output enable is active
        assert (!dut.output_enable | (bus_data_in != 'hZZ));

        // Add more assertions for IR_LED behavior based on commands
    end

    // Test scenario (modify as needed)
    initial begin
        RESET <= 1;
        #10; // Hold reset for some time
        RESET <= 0;

        // Test 1: Write a command to the IR Transmitter
        bus_data_outWE <= 1;
        bus_addr <= IR_TRANSMITTER_BASE_ADDR;
        bus_data_out <= {4'b0, 1'b1, CMD_LEN-1'b0}; // Write a sample command

        #10; // Wait for write operation

        bus_data_outWE <= 0; // Stop writing
        bus_addr <= 'hZZZ; // Set random address

        // Add more test scenarios
    end

endmodule
