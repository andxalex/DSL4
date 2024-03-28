// Global constants for the system. These constants are so widely used
// throughout the system that they need to be defined within global scope
// More specific constants should be defined within the module folder which uses
// them.
`ifndef CONSTS_SV
`define CONSTS_SV

// -------------------------
// Simulation
// -------------------------

`timescale 1ns / 100ps

// -------------------------
// Data widths
// -------------------------
parameter byte INT_SIZE = 32;
parameter byte INT_MAX_INDEX = INT_SIZE - 1;

parameter integer BUS_WIDTH = 8;
parameter integer BUS_MAX_INDEX = BUS_WIDTH - 1;
parameter integer INTERUPT_WIDTH = 2;
parameter integer INTERUPT_MAX_INDEX = INTERUPT_WIDTH - 1;
parameter integer ALU_OP_WIDTH = 4;
parameter integer ALU_OP_MAX_INDEX = ALU_OP_WIDTH - 1;
parameter integer FB_COLOUR_DEPTH = 2;

parameter integer PC_OFFSET_WIDTH = 2;

// -------------------------
// Memory map
// -------------------------
parameter logic[BUS_WIDTH-1:0] RAM_BASE_ADDR = 8'h00;
parameter integer RAM_ADDR_WIDTH = 7; // 128 x 8-bits memory
parameter logic[BUS_WIDTH-1:0] RAM_HIGH_ADDR = RAM_BASE_ADDR + 2**RAM_ADDR_WIDTH - 1;

parameter logic[BUS_WIDTH-1:0] IR_TRANSMITTER_BASE_ADDR = 8'h90;
parameter logic[BUS_WIDTH-1:0] IR_TRANSMITTER_HIGH_ADDR = 8'h90;

parameter logic[BUS_WIDTH-1:0] MOUSE_BASE_ADDR = 8'hA0;
parameter logic[BUS_WIDTH-1:0] MOUSE_HIGH_ADDR = 8'hA2;

parameter logic[BUS_WIDTH-1:0] VGA_BASE_ADDR = 8'hB0;
parameter logic[BUS_WIDTH-1:0] VGA_HIGH_ADDR = 8'hB2;
parameter logic[BUS_WIDTH-1:0] VGA_FB_DATA_ADDR = 8'hB0;
parameter logic[BUS_WIDTH-1:0] VGA_FB_ADDR_LO_ADDR = 8'hB1;
parameter logic[BUS_WIDTH-1:0] VGA_FB_ADDR_HI_ADDR = 8'hB2;
parameter logic[BUS_WIDTH-1:0] VGA_COLOUR_SELECT_ADDR = 8'hB3;

parameter logic[BUS_WIDTH-1:0] LEDS_BASE_ADDR = 8'hC0;
parameter logic[BUS_WIDTH-1:0] LEDS_HIGH_ADDR = 8'hC0;

parameter logic[BUS_WIDTH-1:0] SEVEN_SEG_BASE_ADDR = 8'hD0;
parameter logic[BUS_WIDTH-1:0] SEVEN_SEG_HIGH_ADDR = 8'hD1;

parameter logic[BUS_WIDTH-1:0] TIMER_BASE_ADDR = 8'hF0;
parameter logic[BUS_WIDTH-1:0] TIMER_HIGH_ADDR = 8'hF3;
parameter logic[BUS_WIDTH-1:0] TIMER_COUNT_OFFSET = 8'h00;
parameter logic[BUS_WIDTH-1:0] TIMER_RESET_OFFSET = 8'h01;
parameter logic[BUS_WIDTH-1:0] TIMER_INTERRUPT_ENABLE_OFFSET = 8'h02;
parameter logic[BUS_WIDTH-1:0] TIMER_INTERVAL_OFFSET   = 8'h03;
parameter logic[BUS_WIDTH-1:0] TIMER_INTERVAL_OFFSET_0 = 8'h03;
parameter logic[BUS_WIDTH-1:0] TIMER_INTERVAL_OFFSET_1 = 8'h04;
parameter logic[BUS_WIDTH-1:0] TIMER_INTERVAL_OFFSET_2 = 8'h05;
parameter logic[BUS_WIDTH-1:0] TIMER_INTERVAL_OFFSET_3 = 8'h06;

// -------------------------
// System Parameters
// -------------------------

parameter logic[INT_SIZE-1:0] SYS_CLK_FREQ_HZ = 100_000_000;

parameter string BIN_PATH_ROOT = "C:/Users/edwin/OneDrive University of Edinburgh/OneDrive - University of Edinburgh/digital_systems_lab_5/src/simulation/system_test/bin/";
parameter string ROM_NAME_DEFAULT = "write_checkerboard_to_vga_memory.rom";
parameter string RAM_NAME_DEFAULT = "write_checkerboard_to_vga_memory.ram";
parameter string ROM_PATH_DEFAULT = {BIN_PATH_ROOT, ROM_NAME_DEFAULT};
parameter string RAM_PATH_DEFAULT = {BIN_PATH_ROOT, RAM_NAME_DEFAULT};

parameter string CPU_TEST_PROGRAMS_PATH = "C:/Users/edwin/OneDrive University of Edinburgh/OneDrive - University of Edinburgh/digital_systems_lab_5/src/simulation/cpu/test_programs/";

// -------------------------
// Timer Parameters
// -------------------------

parameter integer INITAL_INTERUPT_PERIOD_MS = 1000;
parameter integer INITAL_INTERUPT_ENABLE = 1;
parameter integer DesiredTimerCountFrequencyHz = 1000;
parameter integer PreScalarMax = SYS_CLK_FREQ_HZ / DesiredTimerCountFrequencyHz - 1;


`endif