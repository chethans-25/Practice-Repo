`ifndef DMA_RAL_SEQUENCE_SV
`define DMA_RAL_SEQUENCE_SV

// =============================================================================
// dma_ral_sequence
//
// RAL-based sequence that provides reusable write_reg() and read_reg() helper
// tasks. The RAL model handle is passed in before starting the sequence.
//
// This sequence is started on the QVIP AXI4 master sequencer. The RAL layer
// translates write_reg/read_reg calls into AXI4-Lite bus transactions via the
// dma_reg2axi4_adapter wired in dma_env::connect_phase.
//
// Usage from test:
//   dma_ral_sequence seq = dma_ral_sequence::type_id::create("seq");
//   seq.ral = m_env.m_ral_model;
//   seq.start(m_env.m_csr_agent.m_sequencer);
// =============================================================================
class dma_ral_sequence extends uvm_sequence;

  `uvm_object_utils(dma_ral_sequence)

  // RAL model handle — must be set by the test before calling start()
  csr_dma_block_model  ral;

  function new(string name = "dma_ral_sequence");
    super.new(name);
  endfunction

  // ---------------------------------------------------------------------------
  // write_reg : Write a value to any register in the RAL model
  //
  //   reg_handle  — the uvm_reg to write (e.g. ral.dma_control)
  //   data        — 64-bit value to write
  // ---------------------------------------------------------------------------
  task write_reg(input uvm_reg reg_handle, input uvm_reg_data_t data);
    uvm_status_e status;

    if (reg_handle == null)
      `uvm_fatal(get_type_name(), "write_reg called with null register handle")

    reg_handle.write(status, data, .parent(this));

    if (status != UVM_IS_OK)
      `uvm_error(get_type_name(), $sformatf("write_reg FAILED: %s addr=0x%08h data=0x%016h",
                reg_handle.get_name(), reg_handle.get_address(), data))
    else
      `uvm_info(get_type_name(), $sformatf("write_reg: %s addr=0x%08h data=0x%016h",
                reg_handle.get_name(), reg_handle.get_address(), data), UVM_MEDIUM)
  endtask

  // ---------------------------------------------------------------------------
  // read_reg : Read a register and return its value
  //
  //   reg_handle  — the uvm_reg to read (e.g. ral.dma_status)
  //   data        — output: 64-bit value read back from hardware
  // ---------------------------------------------------------------------------
  task read_reg(input uvm_reg reg_handle, output uvm_reg_data_t data);
    uvm_status_e status;

    if (reg_handle == null)
      `uvm_fatal(get_type_name(), "read_reg called with null register handle")

    reg_handle.read(status, data, .parent(this));

    if (status != UVM_IS_OK)
      `uvm_error(get_type_name(), $sformatf("read_reg FAILED: %s addr=0x%08h",
                reg_handle.get_name(), reg_handle.get_address()))
    else
      `uvm_info(get_type_name(), $sformatf("read_reg: %s addr=0x%08h data=0x%016h",
                reg_handle.get_name(), reg_handle.get_address(), data), UVM_MEDIUM)
  endtask

  // ---------------------------------------------------------------------------
  // body : Example DMA programming sequence using write_reg / read_reg
  // ---------------------------------------------------------------------------
  virtual task body();
    uvm_reg_data_t rdata;

    `uvm_info(get_type_name(), "================================================================", UVM_LOW)
    `uvm_info(get_type_name(), "  DMA RAL Sequence — START", UVM_LOW)
    `uvm_info(get_type_name(), "================================================================", UVM_LOW)

    if (ral == null)
      `uvm_fatal(get_type_name(), "RAL model handle (ral) is null — set it before starting this sequence")

    // ------------------------------------------------------------------
    // 1. Read status register (version should be 0xCAFE)
    // ------------------------------------------------------------------
    read_reg(ral.dma_status, rdata);
    `uvm_info(get_type_name(), $sformatf("STATUS: version=0x%04h done=%0b error=%0b",
              rdata[15:0], rdata[16], rdata[17]), UVM_LOW)

    // ------------------------------------------------------------------
    // 2. Program descriptor 0
    // ------------------------------------------------------------------
    write_reg(ral.dma_desc_src_addr[0],  64'h0000_0000_1000_0000);  // src = 0x1000_0000
    write_reg(ral.dma_desc_dst_addr[0],  64'h0000_0000_2000_0000);  // dst = 0x2000_0000
    write_reg(ral.dma_desc_num_bytes[0], 64'h0000_0000_0000_0100);  // 256 bytes
    write_reg(ral.dma_desc_cfg[0],       64'h0000_0000_0000_0004);  // enable=1

    // ------------------------------------------------------------------
    // 3. Read-back descriptor 0 to verify
    // ------------------------------------------------------------------
    read_reg(ral.dma_desc_src_addr[0],  rdata);
    read_reg(ral.dma_desc_dst_addr[0],  rdata);
    read_reg(ral.dma_desc_num_bytes[0], rdata);
    read_reg(ral.dma_desc_cfg[0],       rdata);

    // ------------------------------------------------------------------
    // 4. Kick off DMA: control.go = 1
    // ------------------------------------------------------------------
    write_reg(ral.dma_control, 64'h0000_0000_0000_0001);
    `uvm_info(get_type_name(), "DMA CONTROL: go=1 — transfer started", UVM_LOW)

    // ------------------------------------------------------------------
    // 5. Poll status.done
    // ------------------------------------------------------------------
    repeat (50) begin
      #100;
      read_reg(ral.dma_status, rdata);
      if (rdata[16]) begin
        `uvm_info(get_type_name(), "DMA transfer DONE", UVM_LOW)
        break;
      end
    end

    if (!rdata[16])
      `uvm_warning(get_type_name(), "DMA transfer did not complete within polling window")

    // ------------------------------------------------------------------
    // 6. Check error status
    // ------------------------------------------------------------------
    read_reg(ral.dma_error_stats, rdata);
    `uvm_info(get_type_name(), $sformatf("ERROR_STATS: error_trig=%0b error_src=%0b error_type=%0b",
              rdata[2], rdata[1], rdata[0]), UVM_LOW)

    if (rdata[2]) begin
      read_reg(ral.dma_error_addr, rdata);
      `uvm_info(get_type_name(), $sformatf("ERROR_ADDR = 0x%08h", rdata[31:0]), UVM_LOW)
    end

    `uvm_info(get_type_name(), "================================================================", UVM_LOW)
    `uvm_info(get_type_name(), "  DMA RAL Sequence — END", UVM_LOW)
    `uvm_info(get_type_name(), "================================================================", UVM_LOW)
  endtask

endclass : dma_ral_sequence

`endif // DMA_RAL_SEQUENCE_SV
