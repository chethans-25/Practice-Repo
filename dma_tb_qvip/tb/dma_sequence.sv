`ifndef DMA_SEQUENCE_SV
`define DMA_SEQUENCE_SV

class dma_sequence extends uvm_sequence#(dma_sequence_item);

   //-----------------------------------------------------------
   //factory registration
   //-----------------------------------------------------------
   `uvm_object_utils(dma_sequence)

   extern function new(string name = "dma_sequence");

endclass

//-----------------------------------------------------------
//Standard Constructor
//-----------------------------------------------------------
function dma_sequence::new(string name = "dma_sequence");
   super.new(name);
endfunction

`endif
