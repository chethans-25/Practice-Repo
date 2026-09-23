`ifndef DMA_ENV_CONFIG_SV
`define DMA_ENV_CONFIG_SV

class dma_env_config extends uvm_object;

  `uvm_object_utils(dma_env_config)

  // QVIP configuration objects — names match the VIP instance names in tb_top
  axi4_master_0_cfg_t  axi4_master_0_cfg;   // AXI4-Lite CSR master
  axi4_slave_0_cfg_t   axi4_slave_0_cfg;    // AXI4 memory slave

  function new(string name = "dma_env_config");
    super.new(name);
    axi4_master_0_cfg = new("axi4_master_0_cfg");
    axi4_slave_0_cfg  = new("axi4_slave_0_cfg");
  endfunction

  // Called from test_base after BFM handles are fetched from config_db,
  // giving the policy a chance to apply settings that depend on the BFM handle.
  function void initialize();
  endfunction

endclass : dma_env_config

`endif
