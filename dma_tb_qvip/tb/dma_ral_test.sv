`ifndef DMA_RAL_TEST_SV
`define DMA_RAL_TEST_SV

// =============================================================================
// dma_ral_test
//
// Creates a dma_ral_sequence, passes the RAL model handle, and starts it
// on the QVIP AXI4-Lite master sequencer. The sequence's write_reg()/read_reg()
// tasks drive AXI4 transactions through the RAL adapter automatically.
//
// Run with: +UVM_TESTNAME=dma_ral_test
// =============================================================================
class dma_ral_test extends dma_base_test;

  `uvm_component_utils(dma_ral_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    dma_ral_sequence ral_seq;

    phase.raise_objection(this);

    `uvm_info(get_type_name(), "================================================================", UVM_LOW)
    `uvm_info(get_type_name(), "  RAL Register Access Test — START", UVM_LOW)
    `uvm_info(get_type_name(), "================================================================", UVM_LOW)

    // Wait for reset de-assertion
    #100;

    // Create the RAL sequence
    ral_seq = dma_ral_sequence::type_id::create("ral_seq");

    // Pass the RAL model handle to the sequence
    ral_seq.ral = m_env.m_ral_model;

    // Start the sequence on the QVIP AXI4-Lite master sequencer
    // The RAL adapter converts write_reg/read_reg calls into AXI4 bus transactions
    ral_seq.start(m_env.m_csr_agent.m_sequencer);

    #200;

    `uvm_info(get_type_name(), "================================================================", UVM_LOW)
    `uvm_info(get_type_name(), "  RAL Register Access Test — END", UVM_LOW)
    `uvm_info(get_type_name(), "================================================================", UVM_LOW)

    phase.drop_objection(this);
  endtask

endclass : dma_ral_test

`endif // DMA_RAL_TEST_SV
