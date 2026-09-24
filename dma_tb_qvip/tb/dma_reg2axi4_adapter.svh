`ifndef DMA_REG2AXI4_ADAPTER_SVH
`define DMA_REG2AXI4_ADAPTER_SVH

// =============================================================================
// dma_reg2axi4_adapter
//
// UVM register adapter that bridges the abstract uvm_reg read()/write() calls
// to concrete Questa VIP AXI4-Lite transactions on the CSR master sequencer.
//
// The QVIP master is configured as AXI4_LITE with 64-bit data / 32-bit address.
// =============================================================================
class dma_reg2axi4_adapter extends uvm_reg_adapter;

  `uvm_object_utils(dma_reg2axi4_adapter)

  function new(string name = "dma_reg2axi4_adapter");
    super.new(name);
    supports_byte_enable = 1;
    provides_responses   = 1;
  endfunction

  // ---------------------------------------------------------------------------
  // reg2bus : RAL uvm_reg_bus_op --> QVIP AXI4 master transaction
  // ---------------------------------------------------------------------------
  virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
    axi4_master_rw_transaction #(
      axi4_master_0_params::AXI4_ADDRESS_WIDTH,
      axi4_master_0_params::AXI4_RDATA_WIDTH,
      axi4_master_0_params::AXI4_WDATA_WIDTH,
      axi4_master_0_params::AXI4_ID_WIDTH,
      axi4_master_0_params::AXI4_USER_WIDTH,
      axi4_master_0_params::AXI4_REGION_MAP_SIZE
    ) txn;

    txn = axi4_master_rw_transaction #(
      axi4_master_0_params::AXI4_ADDRESS_WIDTH,
      axi4_master_0_params::AXI4_RDATA_WIDTH,
      axi4_master_0_params::AXI4_WDATA_WIDTH,
      axi4_master_0_params::AXI4_ID_WIDTH,
      axi4_master_0_params::AXI4_USER_WIDTH,
      axi4_master_0_params::AXI4_REGION_MAP_SIZE
    )::type_id::create("reg_txn");

    // Address and direction
    txn.set_addr(rw.addr);
    txn.set_read_or_write((rw.kind == UVM_WRITE) ? AXI4_TRANS_WRITE : AXI4_TRANS_READ);

    // Single-beat AXI4-Lite transfer (burst_length=0 means 1 beat)
    txn.set_burst_length(0);
    txn.set_burst_size(AXI4_BURST_SIZE_64BIT);  // 8 bytes = 64-bit data bus
    txn.set_burst_type(AXI4_FIXED);

    if (rw.kind == UVM_WRITE) begin
      txn.set_data_words(rw.data);
      txn.set_write_strobes(rw.byte_en);
    end

    `uvm_info("REG2AXI4", $sformatf("%s addr=0x%08h data=0x%016h",
              (rw.kind == UVM_WRITE) ? "WRITE" : "READ", rw.addr, rw.data), UVM_HIGH)

    return txn;
  endfunction

  // ---------------------------------------------------------------------------
  // bus2reg : QVIP AXI4 response --> RAL uvm_reg_bus_op
  // ---------------------------------------------------------------------------
  virtual function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
    axi4_master_rw_transaction #(
      axi4_master_0_params::AXI4_ADDRESS_WIDTH,
      axi4_master_0_params::AXI4_RDATA_WIDTH,
      axi4_master_0_params::AXI4_WDATA_WIDTH,
      axi4_master_0_params::AXI4_ID_WIDTH,
      axi4_master_0_params::AXI4_USER_WIDTH,
      axi4_master_0_params::AXI4_REGION_MAP_SIZE
    ) txn;

    if (!$cast(txn, bus_item)) begin
      `uvm_fatal("REG2AXI4", "Failed to cast bus_item to axi4_master_rw_transaction")
    end

    rw.addr   = txn.get_addr();
    rw.kind   = (txn.get_read_or_write() == AXI4_TRANS_WRITE) ? UVM_WRITE : UVM_READ;
    rw.data   = txn.get_data_words();
    rw.status = UVM_IS_OK;

    `uvm_info("REG2AXI4", $sformatf("bus2reg: %s addr=0x%08h data=0x%016h",
              (rw.kind == UVM_WRITE) ? "WRITE" : "READ", rw.addr, rw.data), UVM_HIGH)
  endfunction

endclass : dma_reg2axi4_adapter

`endif // DMA_REG2AXI4_ADAPTER_SVH
