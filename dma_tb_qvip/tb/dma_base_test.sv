`ifndef DMA_BASE_TEST_SV
`define DMA_BASE_TEST_SV

class dma_base_test extends uvm_test;

  `uvm_component_utils(dma_base_test)

  dma_env               m_env;
  virtual dma_interface dma_axi_vif;
  dma_env_config        m_env_cfg;
  dma_base_sequence     base_seq;
axi4_master_0_cfg_t  axi4_master_0_cfg;
  axi4_slave_0_cfg_t   axi4_slave_0_cfg;
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Create and initialize env config
    m_env_cfg = dma_env_config::type_id::create("m_env_cfg");
    m_env_cfg.initialize();

 axi4_slave_0_cfg = axi4_slave_0_cfg_t::type_id::create("axi4_slave_0_cfg");
    if (!uvm_config_db #(axi4_slave_0_bfm_t)::get(this, "", "axi4_slave_0", axi4_slave_0_cfg.m_bfm))
      `uvm_error("build_phase", "Unable to get axi4_slave_0 BFM from uvm_config_db")
    axi4_slave_0_config_policy::configure(axi4_slave_0_cfg, null);
    m_env_cfg.axi4_slave_0_cfg = axi4_slave_0_cfg;

    axi4_master_0_cfg = axi4_master_0_cfg_t::type_id::create("axi4_master_0_cfg");
    if (!uvm_config_db #(axi4_master_0_bfm_t)::get(this, "", "axi4_master_0", axi4_master_0_cfg.m_bfm))
      `uvm_error("build_phase", "Unable to get axi4_master_0 BFM from uvm_config_db")
    axi4_master_0_config_policy::configure(axi4_master_0_cfg, null);
    m_env_cfg.axi4_master_0_cfg = axi4_master_0_cfg;

    // Put env config in config DB so dma_env can retrieve it
    uvm_config_db#(dma_env_config)::set(this, "m_env*", "env_cfg", m_env_cfg);

    // Create environment
    m_env = dma_env::type_id::create("m_env", this);

    // Get virtual interface
    if (!uvm_config_db#(virtual dma_interface)::get(this, "", "dma_axi_vif", dma_axi_vif))
      `uvm_error(get_type_name(), "Could not find dma_axi_vif")

  endfunction

  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    uvm_top.print_topology();
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);

    $display("Entered dma_base_test run_phase at time %0t", $time);

    base_seq = dma_base_sequence::type_id::create("base_seq");

    if (m_env == null || m_env.m_agent == null || m_env.m_agent.seqr == null)
      `uvm_fatal(get_type_name(), "DMA sequencer is not available")

    base_seq.start(m_env.m_agent.seqr);

    #200;

    phase.drop_objection(this);
  endtask

endclass : dma_base_test

`endif
