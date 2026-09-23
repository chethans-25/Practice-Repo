//
// File: top_params_pkg.sv
//
// Generated from Questa VIP Configurator (20260112)
// Generated using Questa VIP Library ( 2026.1 : 01/30/2026:13:50 )
//
package dma_qvip_tb_params_pkg;
    import addr_map_pkg::*;
    import rw_delay_db_pkg::*;
    //
    // Import the necessary QVIP packages:
    //
    import mgc_axi4_v1_0_pkg::*;
    class axi4_slave_0_params;
        localparam int AXI4_ADDRESS_WIDTH   = 32;  // AXI_ADDR_WIDTH
        localparam int AXI4_RDATA_WIDTH     = 64;  // AXI_DATA_WIDTH (+define+AXI_DATA_WIDTH=64)
        localparam int AXI4_WDATA_WIDTH     = 64;  // AXI_DATA_WIDTH (+define+AXI_DATA_WIDTH=64)
        localparam int AXI4_ID_WIDTH        = 8;   // AXI_TXN_ID_WIDTH
        localparam int AXI4_USER_WIDTH      = 1;   // AXI_USER_REQ/DATA/RESP_WIDTH
        localparam int AXI4_REGION_MAP_SIZE = 16;
    endclass: axi4_slave_0_params
    
    typedef axi4_vip_config #(axi4_slave_0_params::AXI4_ADDRESS_WIDTH,axi4_slave_0_params::AXI4_RDATA_WIDTH,axi4_slave_0_params::AXI4_WDATA_WIDTH,axi4_slave_0_params::AXI4_ID_WIDTH,axi4_slave_0_params::AXI4_USER_WIDTH,axi4_slave_0_params::AXI4_REGION_MAP_SIZE) axi4_slave_0_cfg_t;
    
    typedef axi4_agent #(axi4_slave_0_params::AXI4_ADDRESS_WIDTH,axi4_slave_0_params::AXI4_RDATA_WIDTH,axi4_slave_0_params::AXI4_WDATA_WIDTH,axi4_slave_0_params::AXI4_ID_WIDTH,axi4_slave_0_params::AXI4_USER_WIDTH,axi4_slave_0_params::AXI4_REGION_MAP_SIZE) axi4_slave_0_agent_t;
    
    typedef virtual mgc_axi4 #(axi4_slave_0_params::AXI4_ADDRESS_WIDTH,axi4_slave_0_params::AXI4_RDATA_WIDTH,axi4_slave_0_params::AXI4_WDATA_WIDTH,axi4_slave_0_params::AXI4_ID_WIDTH,axi4_slave_0_params::AXI4_USER_WIDTH,axi4_slave_0_params::AXI4_REGION_MAP_SIZE) axi4_slave_0_bfm_t;
    
    class axi4_master_0_params;
        localparam int AXI4_ADDRESS_WIDTH   = 32;  // AXI_ADDR_WIDTH
        localparam int AXI4_RDATA_WIDTH     = 64;  // AXI_DATA_WIDTH (+define+AXI_DATA_WIDTH=64)
        localparam int AXI4_WDATA_WIDTH     = 64;  // AXI_DATA_WIDTH (+define+AXI_DATA_WIDTH=64)
        localparam int AXI4_ID_WIDTH        = 8;   // AXI_TXN_ID_WIDTH
        localparam int AXI4_USER_WIDTH      = 1;   // AXI_USER_REQ/DATA/RESP_WIDTH
        localparam int AXI4_REGION_MAP_SIZE = 16;
    endclass: axi4_master_0_params
    
    typedef axi4_vip_config #(axi4_master_0_params::AXI4_ADDRESS_WIDTH,axi4_master_0_params::AXI4_RDATA_WIDTH,axi4_master_0_params::AXI4_WDATA_WIDTH,axi4_master_0_params::AXI4_ID_WIDTH,axi4_master_0_params::AXI4_USER_WIDTH,axi4_master_0_params::AXI4_REGION_MAP_SIZE) axi4_master_0_cfg_t;
    
    typedef axi4_agent #(axi4_master_0_params::AXI4_ADDRESS_WIDTH,axi4_master_0_params::AXI4_RDATA_WIDTH,axi4_master_0_params::AXI4_WDATA_WIDTH,axi4_master_0_params::AXI4_ID_WIDTH,axi4_master_0_params::AXI4_USER_WIDTH,axi4_master_0_params::AXI4_REGION_MAP_SIZE) axi4_master_0_agent_t;
    
    typedef virtual mgc_axi4 #(axi4_master_0_params::AXI4_ADDRESS_WIDTH,axi4_master_0_params::AXI4_RDATA_WIDTH,axi4_master_0_params::AXI4_WDATA_WIDTH,axi4_master_0_params::AXI4_ID_WIDTH,axi4_master_0_params::AXI4_USER_WIDTH,axi4_master_0_params::AXI4_REGION_MAP_SIZE) axi4_master_0_bfm_t;
    
    //
    // `includes for the config policy classes:
    //
    `include "axi4_slave_0_config_policy.svh"
    `include "axi4_master_0_config_policy.svh"
endpackage: dma_qvip_tb_params_pkg

