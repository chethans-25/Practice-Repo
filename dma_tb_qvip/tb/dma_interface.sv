`include "uvm_macros.svh"
import uvm_pkg::*;

`ifndef DMA_INTERFACE_SV
`define DMA_INTERFACE_SV

interface dma_interface(input logic clk, input logic rst);
   import dma_parameters_pkg::*;
   
   // Control signal
   logic        go;         
   logic        abort;          
   logic [7:0]  max_burst;         
    
   //status signal
   logic done;
   logic error;

   //error information
   logic[ADDR_WIDTH-1:0] err_addr;
   logic                 err_type;
   logic                 err_src;
   logic                 err_trg;

   //Descriptors-1 information
   logic [ADDR_WIDTH-1:0] src_addr_desc1;
   logic [ADDR_WIDTH-1:0] dst_addr_desc1;
   logic [DATA_WIDTH-1:0] num_bytes_desc1;
   logic                  mode_wr_desc1;
   logic                  mode_rd_desc1;
   logic                  enable_desc1;

   //Descriptors-0 information
   logic [ADDR_WIDTH-1:0] src_addr_desc0;
   logic [ADDR_WIDTH-1:0] dst_addr_desc0;
   logic [DATA_WIDTH-1:0] num_bytes_desc0;
   logic                  mode_wr_desc0;
   logic                  mode_rd_desc0;
   logic                  enable_desc0;

endinterface
`endif

