
`ifndef DMA_UVC_PKG_SV
`define DMA_UVC_PKG_SV

package dma_uvc_pkg;

   //-----------------------------------------------------------------------------------------
   // Importing uvm lib package and macros file
   //-----------------------------------------------------------------------------------------
   import uvm_pkg::*;
   `include "uvm_macros.svh"

   //-----------------------------------------------------------------------------------------
   // Dma uvc list
   //----------------------------------------------------------------------------------------
   import dma_parameters_pkg::*;
   import dma_qvip_tb_params_pkg::*;

   //-----------------------------------------------------------------------------------------
   // RAL packages (designer-generated rggen RAL + CSR block model)
   //-----------------------------------------------------------------------------------------
   import rggen_ral_pkg::*;
   import csr_dma_ral_pkg::*;

   //-----------------------------------------------------------------------------------------
   // Register adapter (must be included before env which uses it)
   //-----------------------------------------------------------------------------------------
   `include "dma_reg2axi4_adapter.svh"

   `include "dma_uvc_lists.svh"
   
endpackage : dma_uvc_pkg
`endif      // DMA_UVC_PKG_SV


