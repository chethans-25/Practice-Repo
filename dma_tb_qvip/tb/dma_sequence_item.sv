`ifndef DMA_SEQUENCE_ITEM_SV
`define DMA_SEQUENCE_ITEM_SV

class dma_sequence_item extends uvm_sequence_item;

   //-----------------------------------------------------------
   //Variable Declaration
   //-----------------------------------------------------------
   rand bit [31:0] data;

   //-----------------------------------------------------------
   //factory registration
   //-----------------------------------------------------------
   `uvm_object_utils(dma_sequence_item)


   extern function new(string name = "dma_sequence_item");

endclass

//-----------------------------------------------------------
//Standard Constructor
//-----------------------------------------------------------
function dma_sequence_item::new(string name = "dma_sequence_item");
   super.new(name);
endfunction

`endif
