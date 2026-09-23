// Generated from Questa VIP Configurator (20260112)
// Using Questa VIP Library 2026.1 — customised for AXI DMA testbench.
//
// Interface type  : AXI4 slave (memory model for DUT master port)
// Data width      : 64-bit  (AXI_DATA_WIDTH=64)
// Address width   : 32-bit
// ID width        : 8-bit   (AXI_TXN_ID_WIDTH=8)
// User width      : 1-bit   (AXI_USER_REQ/DATA/RESP_WIDTH=1)
// Outstanding     : 2 read, 2 write  (AXI_MAX_OUTSTD_RD/WR=2)

class dma_axi_master_config_policy;

  static function void configure(
    input dma_axi_master_cfg_t cfg,
    input address_map addrm
  );

    // Agent configuration
    cfg.agent_cfg.is_active  = 1;
    cfg.agent_cfg.agent_type = mgc_axi4_v1_0_pkg::AXI4_MASTER;
    cfg.agent_cfg.if_type    = mgc_axi4_v1_0_pkg::AXI4_LITE;
    cfg.agent_cfg.ext_clock  = 1;
    cfg.agent_cfg.ext_reset  = 1;

    // Coverage disabled for initial bring-up
/*    cfg.agent_cfg.en_cvg.func         = 1'b0;
    cfg.agent_cfg.en_cvg.wr_ch_toggle = 1'b0;
    cfg.agent_cfg.en_cvg.rd_ch_toggle = 1'b0;

    // Transaction and beat loggers disabled
    cfg.agent_cfg.en_logger.txn_log  = 0;
    cfg.agent_cfg.en_logger.beat_log = 0;

    // Scoreboard, slave sequence enabled; listener and generic adapter disabled
    cfg.agent_cfg.en_sb         = 1;
    cfg.agent_cfg.en_slv_seq    = 1;
    cfg.agent_cfg.en_txn_ltnr   = 1'b0;
    cfg.agent_cfg.en_rw_adapter = 1'b0;

    // ── Address map ───────────────────────────────────────────────────────
    if (addrm != null)
      cfg.addr_map = addrm;

    cfg.slave_delay = new();
    if (addrm != null)
      cfg.slave_delay.set_address_map(addrm);
    cfg.slave_delay.set_ready_delay_mode(.random_delay(1'b0), .valid2ready(1'b1));

    // Coverage sideband fields disabled
    cfg.cov_enable.raddr_user = 1'b0;
    cfg.cov_enable.wdata_user = 1'b0;
    cfg.cov_enable.wresp_user = 1'b0;
    cfg.cov_enable.waddr_user = 1'b0;
    cfg.cov_enable.rdata_user = 1'b0;

    // ── Outstanding transaction limits (match AXI_MAX_OUTSTD_RD/WR=2) ────
    cfg.m_max_outstanding_read_addrs   = 2;
    cfg.m_max_outstanding_write_addrs  = 2;
    cfg.m_max_outstanding_wdata        = 2;

    // DMA issues in-order transactions — disable out-of-order responses
    cfg.m_read_resp_out_of_order       = 0;
    cfg.m_read_interleaved_resp_enable = 0;
    cfg.m_write_resp_out_of_order      = 0;

    // Warn if DMA reads a memory address that was never written (catches test bugs)
    cfg.m_warn_on_uninitialized_read   = 1'b1;

    // ── BFM configuration ─────────────────────────────────────────────────
    // Reordering/interleave depth — match AXI_MAX_OUTSTD_RD=2
    cfg.m_bfm.config_read_data_reordering_depth = 2;
    cfg.m_bfm.config_rd_interleave_depth        = 2;

    // User sideband widths — match AXI_USER_REQ/DATA/RESP_WIDTH=1
    cfg.m_bfm.config_awuser_width = 1;
    cfg.m_bfm.config_wuser_width  = 1;
    cfg.m_bfm.config_aruser_width = 1;
    cfg.m_bfm.config_ruser_width  = 1;
    cfg.m_bfm.config_buser_width  = 1;

    // Outstanding read/write limits — match AXI_MAX_OUTSTD_RD/WR=2
    cfg.m_bfm.config_num_max_outstanding_reads  = 2;
    cfg.m_bfm.config_num_max_outstanding_writes = 2;*/

  endfunction : configure

endclass 

