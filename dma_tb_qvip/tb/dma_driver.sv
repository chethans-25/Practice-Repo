`ifndef DMA_DRIVER_SV
`define DMA_DRIVER_SV


class dma_driver extends uvm_driver#(dma_sequence_item);

   //-----------------------------------------------------------
   //factory registration
   //-----------------------------------------------------------
   `uvm_component_utils(dma_driver)

   //-----------------------------------------------------------
   //handle for the interface and seq_item
   //-----------------------------------------------------------
   virtual dma_interface dma_axi_vif;
   dma_sequence_item dma_trans;
   
  
   extern function new(string name = "dma_driver",uvm_component parent = null);
   extern virtual function void build_phase(uvm_phase phase);
   extern virtual task drive_data;
   extern virtual task run_phase(uvm_phase phase);

endclass

//-----------------------------------------------------------
//Standard Constructor
//-----------------------------------------------------------
function dma_driver::new(string name = "dma_driver", uvm_component parent = null);
   super.new(name,parent);
endfunction


//-----------------------------------------------------------
//build phase
//-----------------------------------------------------------
function void dma_driver::build_phase(uvm_phase phase);
   super.build_phase(phase);
   dma_trans = dma_sequence_item::type_id::create("dma_trans");
   if(!uvm_config_db#(virtual dma_interface)::get(this,"","dma_axi_vif",dma_axi_vif))
      `uvm_error(get_type_name(),"Could not find interface handle")
endfunction

//-----------------------------------------------------------
//drive_data task
//-----------------------------------------------------------
task dma_driver::drive_data;
   //logic
endtask

//-----------------------------------------------------------
//run_phase task
//-----------------------------------------------------------
task dma_driver::run_phase(uvm_phase phase);
   super.run_phase(phase);
   //logic
endtask

`endif
