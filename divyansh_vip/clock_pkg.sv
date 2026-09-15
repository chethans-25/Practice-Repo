`ifndef CLOCK_VIP_PKG_SV
`define CLOCK_VIP_PKG_SV

`include "clock_vip_defines.svh"

package clock_vip_pkg;

    localparam int NUM_CLOCKS = `NUM_CLOCKS;
    `include "clock_vip_txn.sv"
    `include "clock_vip_generator.sv"
    `include "clock_vip_driver.sv"
    `include "clock_vip_monitor.sv"
    `include "clock_vip_scoreboard.sv"
    `include "clock_vip_environment.sv"
    `include "clock_vip_test.sv"

endpackage

`endif