`ifndef CLOCK_VIP_DEFINES_SVH
`define CLOCK_VIP_DEFINES_SVH

// ----------------------------------------------------------------------
// Single source of truth for the number of clocks this VIP drives and
// checks. clock_vip_if.sv, clock_pkg.sv, clock_dut.sv and clock_top.sv
// all `include this file instead of each declaring their own copy of
// NUM_CLOCKS, so there is exactly one number to change to scale the
// testbench up or down.
// ----------------------------------------------------------------------
`define NUM_CLOCKS 4

// ----------------------------------------------------------------------
// Debug/waveform-only marker of which directed test group is currently
// running. Declared here (not inside the package, not inside the
// interface) so BOTH clock_vip_if.sv and clock_vip_generator.sv can
// use the identical type without importing from one another. Purely
// for waveform readability -- nothing in the checking logic reads this.
// ----------------------------------------------------------------------
typedef enum bit [2:0] {
    TG_NONE               = 3'd0,
    TG_CONCURRENT_NORMAL  = 3'd1,  // Test Group 1
    TG_RESET_INTERRUPT    = 3'd2,  // Test Group 2
    TG_SEQUENTIAL_SWEEP   = 3'd3,  // Test Group 3
    TG_CONCURRENT_MIXED   = 3'd4,  // Test Group 4
    TG_RAPID_RESTART      = 3'd5   // Test Group 5
} test_group_e;

// ----------------------------------------------------------------------
// Bit widths for the packed debug buses in clock_vip_if.sv. Macros, not
// localparams, for the same reason NUM_CLOCKS is a macro: they need to
// be usable identically inside the interface AND inside the package
// (clock_vip_generator.sv / clock_vip_scoreboard.sv), and a package
// cannot see plain localparams declared inside an interface.
// ----------------------------------------------------------------------
`define DBG_ID_W     8   // bits per clock for the session-id debug bus
`define DBG_PERIOD_W 32  // bits per clock for period debug buses (units: picoseconds)

`endif