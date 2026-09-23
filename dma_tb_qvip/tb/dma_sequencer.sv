`ifndef DMA_SEQUENCER_SV
`define DMA_SEQUENCER_SV

class dma_sequencer extends uvm_sequencer#(dma_sequence_item);

   //-----------------------------------------------------------
   //factory registration
   //-----------------------------------------------------------
   `uvm_component_utils(dma_sequencer)

   extern function new(string name = "dma_sequencer", uvm_component parent = null);

endclass

//-----------------------------------------------------------
//Standard Constructor
//-----------------------------------------------------------
function dma_sequencer::new(string name = "dma_sequencer", uvm_component parent = null);
   super.new(name,parent);
endfunction

`endif
