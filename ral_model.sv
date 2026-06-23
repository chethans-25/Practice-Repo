package ral_model_pkg;
  import amba_axi_pkg::*;

  // DMA CSR register space constants
  localparam int DMA_NUM_DESC = 2;
  localparam bit [7:0] DMA_BYTE_SIZE             = 8'h100;
  localparam bit [7:0] DMA_CONTROL_ADDR          = 8'h00;
  localparam bit [7:0] DMA_STATUS_ADDR           = 8'h08;
  localparam bit [7:0] DMA_ERROR_ADDR_ADDR       = 8'h10;
  localparam bit [7:0] DMA_ERROR_STATS_ADDR      = 8'h18;
  localparam bit [7:0] DMA_DESC_SRC_ADDR_BASE    = 8'h20;
  localparam bit [7:0] DMA_DESC_DST_ADDR_BASE    = 8'h30;
  localparam bit [7:0] DMA_DESC_NUM_BYTES_BASE   = 8'h40;
  localparam bit [7:0] DMA_DESC_CFG_BASE         = 8'h50;
  localparam bit [7:0] DMA_DESC_STRIDE          = 8'h08;

  // DMA register models
  class dma_control_reg;
    bit        go;
    bit        abort;
    logic [7:0] max_burst;

    function new();
      reset();
    endfunction

    function void reset();
      go        = 1'b0;
      abort     = 1'b0;
      max_burst = 8'hff;
    endfunction

    function axi_data_t pack();
      return {54'b0, max_burst, abort, go};
    endfunction

    function void unpack(axi_data_t data, axi_wr_strb_t wstrb);
      axi_data_t masked = apply_write_mask(pack(), data, wstrb);
      go        = masked[0];
      abort     = masked[1];
      max_burst = masked[9:2];
    endfunction

    function axi_data_t apply_write_mask(axi_data_t current_value, axi_data_t write_data, axi_wr_strb_t wstrb);
      axi_data_t mask = '0;
      for (int i = 0; i < $bits(wstrb); i++) begin
        if (wstrb[i]) mask |= (axi_data_t)'(64'hff) << (i * 8);
      end
      return (current_value & ~mask) | (write_data & mask);
    endfunction
  endclass

  class dma_status_reg;
    logic [15:0] version;
    bit          done;
    bit          error;

    function new();
      reset();
    endfunction

    function void reset();
      version = 16'hcafe;
      done    = 1'b0;
      error   = 1'b0;
    endfunction

    function axi_data_t pack();
      return {46'b0, error, done, version};
    endfunction

    function void update_done(bit i_done);
      done = i_done;
    endfunction

    function void update_error(bit i_error);
      error = i_error;
    endfunction
  endclass

  class dma_error_addr_reg;
    logic [31:0] error_addr;

    function new();
      reset();
    endfunction

    function void reset();
      error_addr = 32'h0000_0000;
    endfunction

    function axi_data_t pack();
      return {32'b0, error_addr};
    endfunction

    function void update_error_addr(logic [31:0] addr);
      error_addr = addr;
    endfunction
  endclass

  class dma_error_stats_reg;
    bit error_type;
    bit error_src;
    bit error_trig;

    function new();
      reset();
    endfunction

    function void reset();
      error_type = 1'b0;
      error_src  = 1'b0;
      error_trig = 1'b0;
    endfunction

    function axi_data_t pack();
      return {61'b0, error_trig, error_src, error_type};
    endfunction

    function void update_error_stats(bit i_type, bit i_src, bit i_trig);
      error_type = i_type;
      error_src  = i_src;
      error_trig = i_trig;
    endfunction
  endclass

  class dma_desc_addr_reg;
    logic [31:0] addr;

    function new();
      reset();
    endfunction

    function void reset();
      addr = 32'h0000_0000;
    endfunction

    function axi_data_t pack();
      return {32'b0, addr};
    endfunction

    function void unpack(axi_data_t data, axi_wr_strb_t wstrb);
      axi_data_t masked = apply_write_mask(pack(), data, wstrb);
      addr = masked[31:0];
    endfunction

    function axi_data_t apply_write_mask(axi_data_t current_value, axi_data_t write_data, axi_wr_strb_t wstrb);
      axi_data_t mask = '0;
      for (int i = 0; i < $bits(wstrb); i++) begin
        if (wstrb[i]) mask |= (axi_data_t)'(64'hff) << (i * 8);
      end
      return (current_value & ~mask) | (write_data & mask);
    endfunction
  endclass

  class dma_desc_num_bytes_reg;
    logic [31:0] num_bytes;

    function new();
      reset();
    endfunction

    function void reset();
      num_bytes = 32'h0000_0000;
    endfunction

    function axi_data_t pack();
      return {32'b0, num_bytes};
    endfunction

    function void unpack(axi_data_t data, axi_wr_strb_t wstrb);
      axi_data_t masked = apply_write_mask(pack(), data, wstrb);
      num_bytes = masked[31:0];
    endfunction

    function axi_data_t apply_write_mask(axi_data_t current_value, axi_data_t write_data, axi_wr_strb_t wstrb);
      axi_data_t mask = '0;
      for (int i = 0; i < $bits(wstrb); i++) begin
        if (wstrb[i]) mask |= (axi_data_t)'(64'hff) << (i * 8);
      end
      return (current_value & ~mask) | (write_data & mask);
    endfunction
  endclass

  class dma_desc_cfg_reg;
    bit write_mode;
    bit read_mode;
    bit enable;

    function new();
      reset();
    endfunction

    function void reset();
      write_mode = 1'b0;
      read_mode  = 1'b0;
      enable     = 1'b0;
    endfunction

    function axi_data_t pack();
      return {61'b0, enable, read_mode, write_mode};
    endfunction

    function void unpack(axi_data_t data, axi_wr_strb_t wstrb);
      axi_data_t masked = apply_write_mask(pack(), data, wstrb);
      write_mode = masked[0];
      read_mode  = masked[1];
      enable     = masked[2];
    endfunction

    function axi_data_t apply_write_mask(axi_data_t current_value, axi_data_t write_data, axi_wr_strb_t wstrb);
      axi_data_t mask = '0;
      for (int i = 0; i < $bits(wstrb); i++) begin
        if (wstrb[i]) mask |= (axi_data_t)'(64'hff) << (i * 8);
      end
      return (current_value & ~mask) | (write_data & mask);
    endfunction
  endclass

  class dma_reg_map;
    dma_control_reg        dma_control;
    dma_status_reg         dma_status;
    dma_error_addr_reg     dma_error_addr;
    dma_error_stats_reg    dma_error_stats;
    dma_desc_addr_reg      dma_desc_src_addr[DMA_NUM_DESC];
    dma_desc_addr_reg      dma_desc_dst_addr[DMA_NUM_DESC];
    dma_desc_num_bytes_reg dma_desc_num_bytes[DMA_NUM_DESC];
    dma_desc_cfg_reg       dma_desc_cfg[DMA_NUM_DESC];

    function new();
      dma_control        = new();
      dma_status         = new();
      dma_error_addr     = new();
      dma_error_stats    = new();
      for (int i = 0; i < DMA_NUM_DESC; i++) begin
        dma_desc_src_addr[i]   = new();
        dma_desc_dst_addr[i]   = new();
        dma_desc_num_bytes[i]  = new();
        dma_desc_cfg[i]        = new();
      end
    endfunction

    function void reset();
      dma_control.reset();
      dma_status.reset();
      dma_error_addr.reset();
      dma_error_stats.reset();
      for (int i = 0; i < DMA_NUM_DESC; i++) begin
        dma_desc_src_addr[i].reset();
        dma_desc_dst_addr[i].reset();
        dma_desc_num_bytes[i].reset();
        dma_desc_cfg[i].reset();
      end
    endfunction

    function axi_data_t read_reg(axi_addr_t address);
      case (address)
        DMA_CONTROL_ADDR:        return dma_control.pack();
        DMA_STATUS_ADDR:         return dma_status.pack();
        DMA_ERROR_ADDR_ADDR:     return dma_error_addr.pack();
        DMA_ERROR_STATS_ADDR:    return dma_error_stats.pack();
        DMA_DESC_SRC_ADDR_BASE:  return dma_desc_src_addr[0].pack();
        DMA_DESC_SRC_ADDR_BASE + DMA_DESC_STRIDE: return dma_desc_src_addr[1].pack();
        DMA_DESC_DST_ADDR_BASE:  return dma_desc_dst_addr[0].pack();
        DMA_DESC_DST_ADDR_BASE + DMA_DESC_STRIDE: return dma_desc_dst_addr[1].pack();
        DMA_DESC_NUM_BYTES_BASE: return dma_desc_num_bytes[0].pack();
        DMA_DESC_NUM_BYTES_BASE + DMA_DESC_STRIDE: return dma_desc_num_bytes[1].pack();
        DMA_DESC_CFG_BASE:       return dma_desc_cfg[0].pack();
        DMA_DESC_CFG_BASE + DMA_DESC_STRIDE: return dma_desc_cfg[1].pack();
        default:                 return '0;
      endcase
    endfunction

    function void write_reg(axi_addr_t address, axi_data_t write_data, axi_wr_strb_t wstrb);
      case (address)
        DMA_CONTROL_ADDR:        dma_control.unpack(write_data, wstrb);
        DMA_DESC_SRC_ADDR_BASE:  dma_desc_src_addr[0].unpack(write_data, wstrb);
        DMA_DESC_SRC_ADDR_BASE + DMA_DESC_STRIDE: dma_desc_src_addr[1].unpack(write_data, wstrb);
        DMA_DESC_DST_ADDR_BASE:  dma_desc_dst_addr[0].unpack(write_data, wstrb);
        DMA_DESC_DST_ADDR_BASE + DMA_DESC_STRIDE: dma_desc_dst_addr[1].unpack(write_data, wstrb);
        DMA_DESC_NUM_BYTES_BASE: dma_desc_num_bytes[0].unpack(write_data, wstrb);
        DMA_DESC_NUM_BYTES_BASE + DMA_DESC_STRIDE: dma_desc_num_bytes[1].unpack(write_data, wstrb);
        DMA_DESC_CFG_BASE:       dma_desc_cfg[0].unpack(write_data, wstrb);
        DMA_DESC_CFG_BASE + DMA_DESC_STRIDE: dma_desc_cfg[1].unpack(write_data, wstrb);
        default: ;
      endcase
    endfunction

    function void update_status(bit done, bit error);
      dma_status.update_done(done);
      dma_status.update_error(error);
    endfunction

    function void update_error_addr(logic [31:0] addr);
      dma_error_addr.update_error_addr(addr);
    endfunction

    function void update_error_stats(bit error_type, bit error_src, bit error_trig);
      dma_error_stats.update_error_stats(error_type, error_src, error_trig);
    endfunction
  endclass

  class axi4lite_reg_adapter;
    function axi_data_t reg2bus(dma_reg_map regs, axi_addr_t address);
      return regs.read_reg(address);
    endfunction

    function void bus2reg(dma_reg_map regs, axi_addr_t address, axi_data_t write_data, axi_wr_strb_t wstrb);
      regs.write_reg(address, write_data, wstrb);
    endfunction
  endclass

endpackage : ral_model_pkg
