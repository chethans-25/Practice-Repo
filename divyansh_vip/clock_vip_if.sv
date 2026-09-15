`ifndef CLOCK_VIP_IF_SV
`define CLOCK_VIP_IF_SV

`include "clock_vip_defines.svh"

interface clock_vip_if(input logic tb_clk);

    localparam int NUM_CLOCKS = `NUM_CLOCKS;

    logic                  reset_n;
    logic [NUM_CLOCKS-1:0] start;
    logic [NUM_CLOCKS-1:0] stop;
    logic [31:0]           frequency_mhz [NUM_CLOCKS];
    logic [NUM_CLOCKS-1:0] dut_clk;
    logic [NUM_CLOCKS-1:0] clock_active;

    // ------------------------------------------------------------------
    // Debug / waveform-visualization signals ONLY. These are not part of
    // the DUT contract -- the DUT never sees them.
    //
    // IMPORTANT: these are all PACKED vectors (one wide bus, sliced per
    // clock), not unpacked arrays. Plain $dumpvars/VCD dumping does not
    // reliably expand unpacked (multi-dimensional) arrays in every tool
    // -- that's exactly why the pre-existing `frequency_mhz` signal
    // above (an unpacked array) never showed up in the wave either.
    // Packed vectors dump the same reliable way dut_clk[NUM_CLOCKS-1:0]
    // already does.
    //
    // Per-clock slice for clock `id`:
    //   dbg_session_id_bus         [id*DBG_ID_W     +: DBG_ID_W]
    //   dbg_expected_period_ps_bus [id*DBG_PERIOD_W +: DBG_PERIOD_W]
    //   dbg_measured_period_ps_bus [id*DBG_PERIOD_W +: DBG_PERIOD_W]
    // Period values are stored as integer PICOSECONDS (not realtime ns)
    // for the same VCD-safety reason -- plain VCD has no reliable "real"
    // value type either, so we scale ns*1000 into a plain integer.
    // ------------------------------------------------------------------
    localparam int DBG_ID_W     = `DBG_ID_W;
    localparam int DBG_PERIOD_W = `DBG_PERIOD_W;

    test_group_e                             dbg_test_group;
    bit  [NUM_CLOCKS-1:0]                     dbg_session_active;
    logic [NUM_CLOCKS*DBG_ID_W-1:0]           dbg_session_id_bus;
    logic [NUM_CLOCKS*DBG_PERIOD_W-1:0]       dbg_expected_period_ps_bus;
    logic [NUM_CLOCKS*DBG_PERIOD_W-1:0]       dbg_measured_period_ps_bus;
    bit  [NUM_CLOCKS-1:0]                     dbg_check_pass_pulse;
    bit  [NUM_CLOCKS-1:0]                     dbg_check_fail_pulse;

    clocking drv_cb @(posedge tb_clk);
        default input #1step output #1step;

        output reset_n;
        output start;
        output stop;
        output frequency_mhz;
    endclocking

    modport DRIVER (
        clocking drv_cb,
        output dut_clk,
        output clock_active
    );

    modport MONITOR (
        input  reset_n,
        input  start,
        input  stop,
        input  frequency_mhz,
        input  dut_clk,
        input  clock_active,

        // Scoreboard reuses this same MONITOR-typed handle (it already
        // needs read access to dut_clk/clock_active for the quiet-window
        // check) to also drive the measured-period/pass-fail debug bus.
        output dbg_measured_period_ps_bus,
        output dbg_check_pass_pulse,
        output dbg_check_fail_pulse
    );

    modport GEN (
        output dbg_test_group,
        output dbg_session_active,
        output dbg_session_id_bus,
        output dbg_expected_period_ps_bus
    );

    modport DUT (
        input reset_n,
        input start,
        input stop,
        input frequency_mhz,
        input dut_clk,
        input clock_active
    );

endinterface

`endif