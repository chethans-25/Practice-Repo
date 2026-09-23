`ifndef DMA_PARAMETERS_PKG_SV
`define DMA_PARAMETERS_PKG_SV

package dma_parameters_pkg;
  parameter int ADDR_WIDTH  = 32;
  parameter int DATA_WIDTH  = 32;
  parameter int ID_WIDTH    = 8;
  parameter int USER_WIDTH  = 8;
  parameter int STRB_WIDTH   = 4;
endpackage

`endif
