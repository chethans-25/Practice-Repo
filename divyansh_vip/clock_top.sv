`timescale 1ns/1ps
`include "clock_vip_defines.svh"
`include "clock_vip_if.sv"
`include "clock_pkg.sv" 

module top;
  
	import clock_vip_pkg::*;

    logic tb_clk = 1'b0;

    always #5ns tb_clk = ~tb_clk;

    clock_vip_if vip_if(tb_clk);

    clock_generator_dut #(
        .NUM_CLOCKS (`NUM_CLOCKS)
    ) dut (
        .reset_n       (vip_if.reset_n),
        .start         (vip_if.start),
        .stop          (vip_if.stop),
        .frequency_mhz (vip_if.frequency_mhz),
        .dut_clk       (vip_if.dut_clk),
        .clock_active  (vip_if.clock_active)
    );

    clock_vip_test test_h;

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, top);
        test_h = new(vip_if, vip_if, vip_if);
        test_h.run();
        $finish;
    end

endmodule