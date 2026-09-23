`ifndef DMA_TYPEDEF_PKG_SV
`define DMA_TYPEDEF_PKG_SV
import dma_parameters_pkg::*;

package dma_typedef_pkg;

//defining typedef of axi miso/mosi signals and axil miso/mosi signals
//AXI_MISO
 typedef struct packed {
   // Write Addr channel
    logic                  awready;
    // Write Data channel
    logic                  wready;
    // Write Response channel
    logic [ID_WIDTH-1:0]   bid;
    logic [1:0]            bresp;
    logic [USER_WIDTH-1:0] buser;
    logic                  bvalid;
    // Read addr channel
    logic                  arready;
    // Read data channel
    logic [7:0]            rid;
    logic [DATA_WIDTH-1:0] rdata;
    logic [1:0]            rresp;
    logic                  rlast;
    logic [USER_WIDTH-1:0] ruser;
    logic                  rvalid;
  } axi_miso_t;

//AXI MOSI
  typedef struct packed {
    // Write Address channel
   logic [ID_WIDTH-1:0]    awid;
   logic [ADDR_WIDTH-1:0]  awaddr;
   logic [7:0]             awlen;    
   logic [2:0]             awsize;   
   logic [1:0]             awburst;
   logic                   awlock;
   logic [3:0]             awcache;
   logic [2:0]             awprot;
   logic [USER_WIDTH-1:0]  awuser;
   logic                   awvalid;
    // Write Data channel
   logic [DATA_WIDTH-1:0]  wdata;
   logic [STRB_WIDTH-1:0]  wstrb;
   logic                   wlast;
   logic [USER_WIDTH-1:0]  wuser;
   logic                   wvalid;
    // Write Response channel
    logic           bready;
    // Read Address channel
    logic [ID_WIDTH-1:0]   arid;
   logic [ADDR_WIDTH-1:0]  araddr;
   logic [7:0]             arlen;
   logic [2:0]             arsize;
   logic [1:0]             arburst;
   logic                   arlock;
   logic [3:0]             arcache;
   logic [2:0]             arprot;
   logic [USER_WIDTH-1:0]  aruser;
   logic                   arvalid;
   // Read Data channel
    logic                  rready;
  } axi_mosi_t;

//AXIL MISO
 typedef struct packed {
    // Write Addr channel
    logic                  s_awready;
    // Write Data channel
    logic                  s_wready;
    // Write Response channel
    logic [ID_WIDTH-1:0]   s_bid;
    logic [1:0]            s_bresp;
    logic                  s_bvalid;
    // Read addr channel
    logic                  s_arready;
    // Read data channel
    logic [ID_WIDTH-1:0]   s_rid;
    logic [DATA_WIDTH-1:0] s_rdata;
    logic [1:0]            s_rresp;
    logic                  s_rvalid;
  } axil_miso_t;
 
 //AXIL MOSI
 typedef struct packed {
    // Write Address channel
   logic [ID_WIDTH-1:0]    s_awid;
   logic [ADDR_WIDTH-1:0]  s_awaddr;
   logic [2:0]             s_awprot;
   logic                   s_awvalid;
    // Write Data channel
   logic [DATA_WIDTH-1:0]  s_wdata;
   logic [STRB_WIDTH-1:0]  s_wstrb;
   logic                   s_wvalid;
    // Write Response channel
    logic           bready;
    // Read Address channel
   logic [ID_WIDTH-1:0]    s_arid;
   logic [ADDR_WIDTH-1:0]  s_araddr;
   logic [2:0]             s_arprot;
   logic                   s_arvalid;
    // Read Data channel
    logic          s_rready;
  } axil_mosi_t;


endpackage  
`endif 

