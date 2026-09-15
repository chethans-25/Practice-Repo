`include "clock_vip_defines.svh"

module clock_generator_dut #(parameter int NUM_CLOCKS = `NUM_CLOCKS) (
    input logic                  reset_n,
    input logic [NUM_CLOCKS-1:0] start,
    input logic [NUM_CLOCKS-1:0] stop,
    input logic [31:0]           frequency_mhz [NUM_CLOCKS],
    input logic [NUM_CLOCKS-1:0] dut_clk,
    input logic [NUM_CLOCKS-1:0] clock_active
);

    // Sample DUT: simply tracks running state from control signals.
    // The VIP verifies only externally visible clock behavior,
    // not this internal logic.
    logic [NUM_CLOCKS-1:0] running;

    genvar i;
    generate
        for (i = 0; i < NUM_CLOCKS; i++) begin : gen_clocks
            always_ff @(posedge dut_clk[i] or negedge reset_n) begin
                if (!reset_n)
                    running[i] <= 1'b0;
                else if (stop[i])
                    running[i] <= 1'b0;
                else if (start[i])
                    running[i] <= 1'b1;
            end
        end
    endgenerate

endmodule