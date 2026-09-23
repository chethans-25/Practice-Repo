`timescale 1ns/1ps

module dma_tb_hdl_top;

  `include "uvm_macros.svh"

  import amba_axi_pkg::*;
  import dma_utils_pkg::*;
  import uvm_pkg::*;
  import mvc_pkg::*;
  import mgc_axi4_v1_0_pkg::*;

  import dma_qvip_tb_params_pkg::*;
  import dma_parameters_pkg::*;
  import dma_uvc_pkg::*;

  localparam int DMA_ID_VAL = 0;
  localparam time CLK_PERIOD = 10ns;

  // ---------------------------------------------------------
  // Including the interface file
  // ---------------------------------------------------------
  `include "dma_interface.sv"

  // ---------------------------------------------------------
  // Clock / Reset generation
  // ---------------------------------------------------------
  logic clk;
  logic rst_n;

  initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
  end

  initial begin
    rst_n = 1'b0;
    #20 rst_n = 1'b1;
  end

  // ---------------------------------------------------------
  // Interface instance
  // ---------------------------------------------------------
  dma_interface dma_axi_vif(clk, rst_n);

 // ── AXI4-Lite master (CSR port) wires ────────────────────────────────────
  wire                                                         axi4_master_0_AWVALID;
  wire [axi4_master_0_params::AXI4_ADDRESS_WIDTH-1:0]         axi4_master_0_AWADDR;
  wire [2:0]                                                   axi4_master_0_AWPROT;
  wire                                                         axi4_master_0_AWREADY;
  wire                                                         axi4_master_0_ARVALID;
  wire [axi4_master_0_params::AXI4_ADDRESS_WIDTH-1:0]         axi4_master_0_ARADDR;
  wire [2:0]                                                   axi4_master_0_ARPROT;
  wire                                                         axi4_master_0_ARREADY;
  wire                                                         axi4_master_0_WVALID;
  wire [axi4_master_0_params::AXI4_WDATA_WIDTH-1:0]           axi4_master_0_WDATA;
  wire [axi4_master_0_params::AXI4_WDATA_WIDTH/8-1:0]         axi4_master_0_WSTRB;
  wire                                                         axi4_master_0_WREADY;
  wire                                                         axi4_master_0_BVALID;
  wire [1:0]                                                   axi4_master_0_BRESP;
  wire                                                         axi4_master_0_BREADY;
  wire                                                         axi4_master_0_RVALID;
  wire [axi4_master_0_params::AXI4_RDATA_WIDTH-1:0]           axi4_master_0_RDATA;
  wire [1:0]                                                   axi4_master_0_RRESP;
  wire                                                         axi4_master_0_RREADY;

  // ── AXI4 slave (memory port) wires ───────────────────────────────────────
  wire                                                         axi4_slave_0_AWVALID;
  wire [axi4_slave_0_params::AXI4_ADDRESS_WIDTH-1:0]          axi4_slave_0_AWADDR;
  wire [2:0]                                                   axi4_slave_0_AWPROT;
  wire [3:0]                                                   axi4_slave_0_AWREGION;
  wire [7:0]                                                   axi4_slave_0_AWLEN;
  wire [2:0]                                                   axi4_slave_0_AWSIZE;
  wire [1:0]                                                   axi4_slave_0_AWBURST;
  wire [1:0]                                                   axi4_slave_0_AWLOCK;
  wire [3:0]                                                   axi4_slave_0_AWCACHE;
  wire [3:0]                                                   axi4_slave_0_AWQOS;
  wire [axi4_slave_0_params::AXI4_ID_WIDTH-1:0]               axi4_slave_0_AWID;
  wire [axi4_slave_0_params::AXI4_USER_WIDTH-1:0]             axi4_slave_0_AWUSER;
  wire                                                         axi4_slave_0_AWREADY;
  wire                                                         axi4_slave_0_ARVALID;
  wire [axi4_slave_0_params::AXI4_ADDRESS_WIDTH-1:0]          axi4_slave_0_ARADDR;
  wire [2:0]                                                   axi4_slave_0_ARPROT;
  wire [3:0]                                                   axi4_slave_0_ARREGION;
  wire [7:0]                                                   axi4_slave_0_ARLEN;
  wire [2:0]                                                   axi4_slave_0_ARSIZE;
  wire [1:0]                                                   axi4_slave_0_ARBURST;
  wire [1:0]                                                   axi4_slave_0_ARLOCK;
  wire [3:0]                                                   axi4_slave_0_ARCACHE;
  wire [3:0]                                                   axi4_slave_0_ARQOS;
  wire [axi4_slave_0_params::AXI4_ID_WIDTH-1:0]               axi4_slave_0_ARID;
  wire [axi4_slave_0_params::AXI4_USER_WIDTH-1:0]             axi4_slave_0_ARUSER;
  wire                                                         axi4_slave_0_ARREADY;
  wire                                                         axi4_slave_0_WVALID;
  wire [axi4_slave_0_params::AXI4_WDATA_WIDTH-1:0]            axi4_slave_0_WDATA;
  wire [axi4_slave_0_params::AXI4_WDATA_WIDTH/8-1:0]          axi4_slave_0_WSTRB;
  wire                                                         axi4_slave_0_WLAST;
  wire [axi4_slave_0_params::AXI4_USER_WIDTH-1:0]             axi4_slave_0_WUSER;
  wire                                                         axi4_slave_0_WREADY;
  wire                                                         axi4_slave_0_BVALID;
  wire [1:0]                                                   axi4_slave_0_BRESP;
  wire [axi4_slave_0_params::AXI4_ID_WIDTH-1:0]               axi4_slave_0_BID;
  wire [axi4_slave_0_params::AXI4_USER_WIDTH-1:0]             axi4_slave_0_BUSER;
  wire                                                         axi4_slave_0_BREADY;
  wire                                                         axi4_slave_0_RVALID;
  wire [axi4_slave_0_params::AXI4_RDATA_WIDTH-1:0]            axi4_slave_0_RDATA;
  wire [1:0]                                                   axi4_slave_0_RRESP;
  wire                                                         axi4_slave_0_RLAST;
  wire [axi4_slave_0_params::AXI4_ID_WIDTH-1:0]               axi4_slave_0_RID;
  wire [axi4_slave_0_params::AXI4_USER_WIDTH-1:0]             axi4_slave_0_RUSER;
  wire                                                         axi4_slave_0_RREADY;

  // ── QVIP AXI4-Lite master (drives DUT CSR slave port) ────────────────────
  axi4_master
  #(
    .ADDR_WIDTH      (axi4_master_0_params::AXI4_ADDRESS_WIDTH),
    .RDATA_WIDTH     (axi4_master_0_params::AXI4_RDATA_WIDTH),
    .WDATA_WIDTH     (axi4_master_0_params::AXI4_WDATA_WIDTH),
    .ID_WIDTH        (axi4_master_0_params::AXI4_ID_WIDTH),
    .USER_WIDTH      (axi4_master_0_params::AXI4_USER_WIDTH),
    .REGION_MAP_SIZE (axi4_master_0_params::AXI4_REGION_MAP_SIZE),
    .IF_NAME         ("axi4_master_0"),
    .PATH_NAME       ("uvm_test_top")
  ) 
  axi4_master_0 
  (
    .ACLK    (clk),
    .ARESETn (~rst),
    // Write address channel
    .AWVALID (axi4_master_0_AWVALID),
    .AWADDR  (axi4_master_0_AWADDR),
    .AWPROT  (axi4_master_0_AWPROT),
    .AWREGION(),
    .AWLEN   (),
    .AWSIZE  (),
    .AWBURST (),
    .AWLOCK  (),
    .AWCACHE (),
    .AWQOS   (),
    .AWID    (),
    .AWUSER  (),
    .AWREADY (axi4_master_0_AWREADY),
    // Write data channel
    .WVALID  (axi4_master_0_WVALID),
    .WDATA   (axi4_master_0_WDATA),
    .WSTRB   (axi4_master_0_WSTRB),
    .WLAST   (),
    .WUSER   (),
    .WREADY  (axi4_master_0_WREADY),
    // Write response channel
    .BVALID  (axi4_master_0_BVALID),
    .BRESP   (axi4_master_0_BRESP),
    .BID     (),
    .BUSER   (),
    .BREADY  (axi4_master_0_BREADY),
    // Read address channel
    .ARVALID (axi4_master_0_ARVALID),
    .ARADDR  (axi4_master_0_ARADDR),
    .ARPROT  (axi4_master_0_ARPROT),
    .ARREGION(),
    .ARLEN   (),
    .ARSIZE  (),
    .ARBURST (),
    .ARLOCK  (),
    .ARCACHE (),
    .ARQOS   (),
    .ARID    (),
    .ARUSER  (),
    .ARREADY (axi4_master_0_ARREADY),
    // Read data channel
    .RVALID  (axi4_master_0_RVALID),
    .RDATA   (axi4_master_0_RDATA),
    .RRESP   (axi4_master_0_RRESP),
    .RLAST   (),
    .RID     (),
    .RUSER   (),
    .RREADY  (axi4_master_0_RREADY)
  );

  // ── QVIP AXI4 slave memory model (responds to DUT master port) ───────────
  axi4_slave
  #(
    .ADDR_WIDTH      (axi4_slave_0_params::AXI4_ADDRESS_WIDTH),
    .RDATA_WIDTH     (axi4_slave_0_params::AXI4_RDATA_WIDTH),
    .WDATA_WIDTH     (axi4_slave_0_params::AXI4_WDATA_WIDTH),
    .ID_WIDTH        (axi4_slave_0_params::AXI4_ID_WIDTH),
    .USER_WIDTH      (axi4_slave_0_params::AXI4_USER_WIDTH),
    .REGION_MAP_SIZE (axi4_slave_0_params::AXI4_REGION_MAP_SIZE),
    .IF_NAME         ("axi4_slave_0"),
    .PATH_NAME       ("uvm_test_top")
  ) axi4_slave_0 (
    .ACLK    (clk),
    .ARESETn (~rst),
    // Write address channel
    .AWVALID (axi4_slave_0_AWVALID),
    .AWADDR  (axi4_slave_0_AWADDR),
    .AWPROT  (axi4_slave_0_AWPROT),
    .AWREGION(axi4_slave_0_AWREGION),
    .AWLEN   (axi4_slave_0_AWLEN),
    .AWSIZE  (axi4_slave_0_AWSIZE),
    .AWBURST (axi4_slave_0_AWBURST),
    .AWLOCK  (axi4_slave_0_AWLOCK),
    .AWCACHE (axi4_slave_0_AWCACHE),
    .AWQOS   (axi4_slave_0_AWQOS),
    .AWID    (axi4_slave_0_AWID),
    .AWUSER  (axi4_slave_0_AWUSER),
    .AWREADY (axi4_slave_0_AWREADY),
    // Write data channel
    .WVALID  (axi4_slave_0_WVALID),
    .WDATA   (axi4_slave_0_WDATA),
    .WSTRB   (axi4_slave_0_WSTRB),
    .WLAST   (axi4_slave_0_WLAST),
    .WUSER   (axi4_slave_0_WUSER),
    .WREADY  (axi4_slave_0_WREADY),
    // Write response channel
    .BVALID  (axi4_slave_0_BVALID),
    .BRESP   (axi4_slave_0_BRESP),
    .BID     (axi4_slave_0_BID),
    .BUSER   (axi4_slave_0_BUSER),
    .BREADY  (axi4_slave_0_BREADY),
    // Read address channel
    .ARVALID (axi4_slave_0_ARVALID),
    .ARADDR  (axi4_slave_0_ARADDR),
    .ARPROT  (axi4_slave_0_ARPROT),
    .ARREGION(axi4_slave_0_ARREGION),
    .ARLEN   (axi4_slave_0_ARLEN),
    .ARSIZE  (axi4_slave_0_ARSIZE),
    .ARBURST (axi4_slave_0_ARBURST),
    .ARLOCK  (axi4_slave_0_ARLOCK),
    .ARCACHE (axi4_slave_0_ARCACHE),
    .ARQOS   (axi4_slave_0_ARQOS),
    .ARID    (axi4_slave_0_ARID),
    .ARUSER  (axi4_slave_0_ARUSER),
    .ARREADY (axi4_slave_0_ARREADY),
    // Read data channel
    .RVALID  (axi4_slave_0_RVALID),
    .RDATA   (axi4_slave_0_RDATA),
    .RRESP   (axi4_slave_0_RRESP),
    .RLAST   (axi4_slave_0_RLAST),
    .RID     (axi4_slave_0_RID),
    .RUSER   (axi4_slave_0_RUSER),
    .RREADY  (axi4_slave_0_RREADY)
  );

   // ---------------------------------------------------------
  // CSR DMA I/F
  // ---------------------------------------------------------
  s_axil_mosi_t csr_mosi;
  s_axil_miso_t csr_miso;
  s_axi_mosi_t  mem_mosi;
  s_axi_miso_t  mem_miso;

// ── QVIP AXI4-Lite master → DUT CSR mosi struct ──────────────────────────
  assign csr_mosi.awvalid = axi4_master_0_AWVALID;
  assign csr_mosi.awaddr  = axi4_master_0_AWADDR;
  assign csr_mosi.awprot  = axi4_master_0_AWPROT;
  assign csr_mosi.awid    = '0;
  assign csr_mosi.wvalid  = axi4_master_0_WVALID;
  assign csr_mosi.wdata   = axi4_master_0_WDATA;
  assign csr_mosi.wstrb   = axi4_master_0_WSTRB;
  assign csr_mosi.bready  = axi4_master_0_BREADY;
  assign csr_mosi.arid    = '0;
  assign csr_mosi.arvalid = axi4_master_0_ARVALID;
  assign csr_mosi.araddr  = axi4_master_0_ARADDR;
  assign csr_mosi.arprot  = axi4_master_0_ARPROT;
  assign csr_mosi.rready  = axi4_master_0_RREADY;

  // ── DUT CSR miso struct → QVIP AXI4-Lite master ──────────────────────────
  assign axi4_master_0_AWREADY = csr_miso.awready;
  assign axi4_master_0_WREADY  = csr_miso.wready;
  assign axi4_master_0_BVALID  = csr_miso.bvalid;
  assign axi4_master_0_BRESP   = csr_miso.bresp;
  assign axi4_master_0_ARREADY = csr_miso.arready;
  assign axi4_master_0_RVALID  = csr_miso.rvalid;
  assign axi4_master_0_RDATA   = csr_miso.rdata;
  assign axi4_master_0_RRESP   = csr_miso.rresp;

  // ── DUT memory master mosi → QVIP AXI4 slave ─────────────────────────────
  assign axi4_slave_0_AWVALID  = mem_mosi.awvalid;
  assign axi4_slave_0_AWADDR   = mem_mosi.awaddr;
  assign axi4_slave_0_AWPROT   = mem_mosi.awprot;
  assign axi4_slave_0_AWREGION = mem_mosi.awregion;
  assign axi4_slave_0_AWLEN    = mem_mosi.awlen;
  assign axi4_slave_0_AWSIZE   = mem_mosi.awsize;
  assign axi4_slave_0_AWBURST  = mem_mosi.awburst;
  assign axi4_slave_0_AWLOCK   = mem_mosi.awlock;
  assign axi4_slave_0_AWCACHE  = mem_mosi.awcache;
  assign axi4_slave_0_AWQOS    = mem_mosi.awqos;
  assign axi4_slave_0_AWID     = mem_mosi.awid;
  assign axi4_slave_0_AWUSER   = mem_mosi.awuser;
  assign axi4_slave_0_WVALID   = mem_mosi.wvalid;
  assign axi4_slave_0_WDATA    = mem_mosi.wdata;
  assign axi4_slave_0_WSTRB    = mem_mosi.wstrb;
  assign axi4_slave_0_WLAST    = mem_mosi.wlast;
  assign axi4_slave_0_WUSER    = mem_mosi.wuser;
  assign axi4_slave_0_BREADY   = mem_mosi.bready;
  assign axi4_slave_0_ARVALID  = mem_mosi.arvalid;
  assign axi4_slave_0_ARADDR   = mem_mosi.araddr;
  assign axi4_slave_0_ARPROT   = mem_mosi.arprot;
  assign axi4_slave_0_ARREGION = mem_mosi.arregion;
  assign axi4_slave_0_ARLEN    = mem_mosi.arlen;
  assign axi4_slave_0_ARSIZE   = mem_mosi.arsize;
  assign axi4_slave_0_ARBURST  = mem_mosi.arburst;
  assign axi4_slave_0_ARLOCK   = mem_mosi.arlock;
  assign axi4_slave_0_ARCACHE  = mem_mosi.arcache;
  assign axi4_slave_0_ARQOS    = mem_mosi.arqos;
  assign axi4_slave_0_ARID     = mem_mosi.arid;
  assign axi4_slave_0_ARUSER   = mem_mosi.aruser;
  assign axi4_slave_0_RREADY   = mem_mosi.rready;

  // ── QVIP AXI4 slave outputs → DUT memory miso struct ─────────────────────
  assign mem_miso.awready = axi4_slave_0_AWREADY;
  assign mem_miso.wready  = axi4_slave_0_WREADY;
  assign mem_miso.bvalid  = axi4_slave_0_BVALID;
  assign mem_miso.bresp   = axi4_slave_0_BRESP;
  assign mem_miso.bid     = axi4_slave_0_BID;
  assign mem_miso.buser   = axi4_slave_0_BUSER;
  assign mem_miso.arready = axi4_slave_0_ARREADY;
  assign mem_miso.rvalid  = axi4_slave_0_RVALID;
  assign mem_miso.rdata   = axi4_slave_0_RDATA;
  assign mem_miso.rresp   = axi4_slave_0_RRESP;
  assign mem_miso.rlast   = axi4_slave_0_RLAST;
  assign mem_miso.rid     = axi4_slave_0_RID;
  assign mem_miso.ruser   = axi4_slave_0_RUSER;

  // DUT instantiation
  dma_axi_wrapper u_dma_axi_wrapper (
    .clk            (clk),
    .rst            (rst_n),
    .dma_csr_mosi_i(csr_mosi),
    .dma_csr_miso_o(csr_miso),
    .dma_m_mosi_o  (mem_mosi),
    .dma_m_miso_i  (mem_miso),
    .dma_done_o      (dma_axi_vif.done),
    .dma_error_o     (dma_axi_vif.error)
  );

  // ---------------------------------------------------------
  // Control signal connections
  // ---------------------------------------------------------
  assign dma_axi_vif.go        = u_dma_axi_wrapper.dma_ctrl.go;
  assign dma_axi_vif.abort     = u_dma_axi_wrapper.dma_ctrl.abort_req;
  assign dma_axi_vif.max_burst = u_dma_axi_wrapper.dma_ctrl.max_burst;

  // ---------------------------------------------------------
  // Error information
  // ---------------------------------------------------------
  assign dma_axi_vif.err_addr = u_dma_axi_wrapper.dma_error.addr;
  assign dma_axi_vif.err_type  = u_dma_axi_wrapper.dma_error.type_err;
  assign dma_axi_vif.err_src   = u_dma_axi_wrapper.dma_error.src;
  assign dma_axi_vif.err_trg   = u_dma_axi_wrapper.dma_error.valid;

  // ---------------------------------------------------------
  // Descriptor-1 information
  // ---------------------------------------------------------
  assign dma_axi_vif.src_addr_desc1 = u_dma_axi_wrapper.dma_desc[1].src_addr;
  assign dma_axi_vif.dst_addr_desc1 = u_dma_axi_wrapper.dma_desc[1].dst_addr;
  assign dma_axi_vif.num_bytes_desc1 = u_dma_axi_wrapper.dma_desc[1].num_bytes;
  assign dma_axi_vif.mode_wr_desc1   = u_dma_axi_wrapper.dma_desc[1].wr_mode;
  assign dma_axi_vif.mode_rd_desc1   = u_dma_axi_wrapper.dma_desc[1].rd_mode;
  assign dma_axi_vif.enable_desc1    = u_dma_axi_wrapper.dma_desc[1].enable;

  // ---------------------------------------------------------
  // Descriptor-0 information
  // ---------------------------------------------------------
  assign dma_axi_vif.src_addr_desc0 = u_dma_axi_wrapper.dma_desc[0].src_addr;
  assign dma_axi_vif.dst_addr_desc0 = u_dma_axi_wrapper.dma_desc[0].dst_addr;
  assign dma_axi_vif.num_bytes_desc0 = u_dma_axi_wrapper.dma_desc[0].num_bytes;
  assign dma_axi_vif.mode_wr_desc0   = u_dma_axi_wrapper.dma_desc[0].wr_mode;
  assign dma_axi_vif.mode_rd_desc0   = u_dma_axi_wrapper.dma_desc[0].rd_mode;
  assign dma_axi_vif.enable_desc0    = u_dma_axi_wrapper.dma_desc[0].enable;

   // ---------------------------------------------------------
  // Set config DB and run test
  // ---------------------------------------------------------
  initial begin
    // Virtual interface
    uvm_config_db#(virtual dma_interface)::set(null, "*", "dma_axi_vif", dma_axi_vif);

    $display("Going to run the test at time %0t", $time);
    run_test();
  end

endmodule
