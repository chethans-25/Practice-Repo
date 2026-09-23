`ifndef DMA_ENV_SV
`define DMA_ENV_SV

class dma_env extends uvm_env;

  `uvm_component_utils(dma_env)

  // DMA agent
  dma_agent              m_agent;

  // Environment config
  dma_env_config         m_env_cfg;

  // QVIP AXI4 master for CSR side
   axi4_master_0_agent_t  m_csr_agent;   // QVIP AXI4-Lite master (CSR port)
  axi4_slave_0_agent_t   m_axi_slv;

  extern function new(string name = "dma_env", uvm_component parent = null);
  extern function void build_phase(uvm_phase phase);
  extern function void connect_phase(uvm_phase phase);

endclass : dma_env

// ---------------------------------------------------------
// Constructor
// ---------------------------------------------------------
function dma_env::new(string name = "dma_env", uvm_component parent = null);
  super.new(name, parent);
endfunction

// ---------------------------------------------------------
// build_phase
// ---------------------------------------------------------
function void dma_env::build_phase(uvm_phase phase);
  super.build_phase(phase);

  // Create DMA agent
  m_agent = dma_agent::type_id::create("m_agent", this);

  // Get env config from config DB
  if (m_env_cfg == null) begin
    if (!uvm_config_db#(dma_env_config)::get(this, "", "env_cfg", m_env_cfg)) begin
      `uvm_fatal(get_type_name(), "env_cfg not found in uvm_config_db")
    end
  end

  // Create QVIP master agent
  m_csr_agent = axi4_master_0_agent_t::type_id::create("m_csr_agent", this);
    m_csr_agent.set_mvc_config(m_env_cfg.axi4_master_0_cfg);

    m_axi_slv = axi4_slave_0_agent_t::type_id::create("m_axi_slv", this);
    m_axi_slv.set_mvc_config(m_env_cfg.axi4_slave_0_cfg);

endfunction

// ---------------------------------------------------------
// connect_phase
// ---------------------------------------------------------
function void dma_env::connect_phase(uvm_phase phase);
  super.connect_phase(phase);
endfunction

`endif
