`ifndef DMA_AGENT_SV
`define DMA_AGENT_SV

class dma_agent extends uvm_agent;

  `uvm_component_utils(dma_agent)

  dma_monitor   mon;
  dma_driver    drv;
  dma_sequencer seqr;

  extern function new(string name = "dma_agent", uvm_component parent = null);
  extern function void build_phase(uvm_phase phase);

endclass

// ---------------------------------------------------------
// Standard Constructor
// ---------------------------------------------------------
function dma_agent::new(string name = "dma_agent", uvm_component parent = null);
  super.new(name, parent);
endfunction

// ---------------------------------------------------------
// build_phase
// ---------------------------------------------------------
function void dma_agent::build_phase(uvm_phase phase);
  super.build_phase(phase);

  mon  = dma_monitor::type_id::create("mon", this);
  drv  = dma_driver::type_id::create("drv", this);
  seqr = dma_sequencer::type_id::create("seqr", this);

endfunction

`endif
