// This file contains constant definitions used in the design.
// These constants represent fixed values that are used throughout the design
// to provide meaningful names and improve code readability.
// They help in avoiding the use of magic numbers and make the code more maintainable.
//
`ifndef IR_CONSTS_SV
`define IR_CONSTS_SV

`include "../consts.sv"

// The set of states that the IR transmitter can be in
typedef enum {
    START,      GAP_0,
    CAR_SELECT, GAP_1,
    RIGHT,      GAP_2,
    LEFT,       GAP_3,
    BACKWARD,   GAP_4,
    FORWARD,    GAP_5,
    CAR_IDLE
} State;

typedef struct {
    integer START_SIZE;
    integer GAP_SIZE;
    integer SELECT_SIZE;
    integer ASSERT_SIZE;
    integer DEASSERT_SIZE;
    integer FREQ_HZ;
    integer SYS_CLK_COUNTER_MAX; // Stores the maxium value which a sysclk counter
                                 // needs to generate the frequency
} CarSettings;

CarSettings BLUE_PARAMS = '{
    START_SIZE: 191,
    GAP_SIZE: 25,
    SELECT_SIZE: 47,
    ASSERT_SIZE: 47,
    DEASSERT_SIZE: 22,
    FREQ_HZ: 36_000,
    SYS_CLK_COUNTER_MAX: SYS_CLK_FREQ_HZ / 36_000
};

CarSettings YELLOW_PARAMS = '{
    START_SIZE: 88,
    GAP_SIZE: 40,
    SELECT_SIZE: 22,
    ASSERT_SIZE: 44,
    DEASSERT_SIZE: 22,
    FREQ_HZ: 40_000,
    SYS_CLK_COUNTER_MAX: SYS_CLK_FREQ_HZ / 40_000
};

CarSettings GREEN_PARAMS = '{
    START_SIZE: 88,
    GAP_SIZE: 40,
    SELECT_SIZE: 44,
    ASSERT_SIZE: 44,
    DEASSERT_SIZE: 22,
    FREQ_HZ: 37_500,
    SYS_CLK_COUNTER_MAX: SYS_CLK_FREQ_HZ / 37_500
};

CarSettings RED_PARAMS = '{
    START_SIZE: 192,
    GAP_SIZE: 24,
    SELECT_SIZE: 24,
    ASSERT_SIZE: 48,
    DEASSERT_SIZE: 24,
    FREQ_HZ: 36_000,
    SYS_CLK_COUNTER_MAX: SYS_CLK_FREQ_HZ / 36_000
};

parameter integer CMD_LEN = 4;
parameter integer CAR_COUNT = 4;

`endif