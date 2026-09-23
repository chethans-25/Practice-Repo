module dma_tb_hvl_top;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import dma_uvc_pkg::*;
  import dma_parameters_pkg::*;
  import dma_qvip_tb_params_pkg::*;
  import dma_typedef_pkg::*;

  // ---------------------------------------------------------
  // Set virtual interface handles and environment config
  // ---------------------------------------------------------
  initial begin
    dma_env_config env_cfg;

    // Create environment config object
    env_cfg = dma_env_config::type_id::create("env_cfg");

    // Optional customization hook
    env_cfg.initialize();

    // Put env config into config DB for the environment
    uvm_config_db#(dma_env_config)::set(null,"uvm_test_top*","env_cfg",env_cfg);

    // Set the DUT-facing virtual interfaces
    uvm_config_db#(virtual dma_interface)::set(null,"uvm_test_top*","dma_axi_vif",dma_tb_hdl_top.dma_axi_vif);

    uvm_config_db#(virtual dma_interface)::set(null,"uvm_test_top*","dma_axil_vif",dma_tb_hdl_top.dma_axil_vif);

    $display("Going to run the test. time : %0t", $time);
    run_test("dma_base_test");
  end

  // ---------------------------------------------------------
  // Simulation watchdog
  // ---------------------------------------------------------
  initial begin
    #5ms;
    `uvm_fatal("DMA_TB_HVL_TOP", "Simulation timeout expired")
  end

endmodule : dma_tb_hvl_top
