`ifndef DMA_BASE_SEQUENCE_SV
`define DMA_BASE_SEQUENCE_SV
 
class dma_base_sequence extends uvm_sequence#(dma_sequence_item);
   
   //------------------------------------------------------------------------------------------
   //   UVM factory registration 
   //-----------------------------------------------------------------------------------------
   `uvm_object_utils(dma_base_sequence)

   //-----------------------------------------------------------------------------------------
   //  DMA base sequence Method declaration 
   //-----------------------------------------------------------------------------------------
   extern         function         new    (string name = "dma_base_sequence");
   extern virtual task             pre_body();
   extern virtual task             start_seq_banner();
   extern virtual task             send_transaction();
   extern virtual task             end_seq_banner();
   extern virtual task             body   ();
   extern virtual task             post_body();
   extern         function void    pre_randomize();
   extern         function void    post_randomize();
endclass : dma_base_sequence

//----------------------------------------------------------------------------------------
//   Function    : new    
//   Arguments   : string name = "dma_base_sequence"
//   Description : This function is the constructor of the class. It is being used to 
//                 create the class object
//----------------------------------------------------------------------------------------
function dma_base_sequence:: new(string name = "dma_base_sequence");
   super.new(name);
endfunction : new

//----------------------------------------------------------------------------------------
//   Task        : pre_body    
//   Arguments   :
//   Description : This task raises objection in pre_body so the objection is only raised 
//                 for root sequences only 
//----------------------------------------------------------------------------------------
task dma_base_sequence:: pre_body();
   uvm_phase starting_phase = get_starting_phase();
   if (starting_phase!=null) begin
      `uvm_info(get_full_name(),$sformatf("%s pre_body() raising %s objection", get_sequence_path(), starting_phase.get_name()), UVM_LOW);
      starting_phase.raise_objection(this);
   end
endtask : pre_body

//----------------------------------------------------------------------------------------
//   Task        : send_transaction    
//   Arguments   : dma_sequence_item dma_trans
//   Description : This task is used to send transaction   
//                 
//----------------------------------------------------------------------------------------
task dma_base_sequence:: send_transaction();
   //logic
endtask : send_transaction

//----------------------------------------------------------------------------------------
//   Task        : start_seq_banner    
//   Arguments   : 
//   Description : This task is used to notify the start of sequence   
//----------------------------------------------------------------------------------------
task dma_base_sequence:: start_seq_banner();
   `uvm_info_context(get_type_name(), "----------------------------------------------------------------", UVM_LOW, uvm_top)
   `uvm_info_context(get_type_name(), $psprintf("      Starting Sequence:  %s            ",get_type_name()), UVM_LOW, uvm_top)
   `uvm_info_context(get_type_name(), "----------------------------------------------------------------", UVM_LOW, uvm_top)
endtask : start_seq_banner

//----------------------------------------------------------------------------------------
//   Task        : end_seq_banner    
//   Arguments   : 
//   Description : This task is used to notify the end of sequence   
//----------------------------------------------------------------------------------------
task dma_base_sequence:: end_seq_banner();
   `uvm_info_context(get_type_name(), "----------------------------------------------------------------", UVM_LOW, uvm_top)
   `uvm_info_context(get_type_name(), $psprintf("      Ending Sequence:  %s            ",get_type_name()), UVM_LOW, uvm_top)
   `uvm_info_context(get_type_name(), "----------------------------------------------------------------", UVM_LOW, uvm_top)
endtask : end_seq_banner

//----------------------------------------------------------------------------------------
//   Task        : body    
//   Arguments   : 
//   Description : This task generates stimulus as per the constraint random scenarios   
//----------------------------------------------------------------------------------------
task dma_base_sequence:: body ();
   start_seq_banner();
   //logic
   `uvm_info("DMA_BASE_SEQ", "Hello World!!", UVM_NONE)
   end_seq_banner();
endtask : body

//----------------------------------------------------------------------------------------
//   Task        : post_body    
//   Arguments   : 
//   Description : This task drops objection in the post_body so the objections are dropped 
//                for root sequence only
//----------------------------------------------------------------------------------------
task dma_base_sequence:: post_body();
   uvm_phase starting_phase = get_starting_phase();
   if (starting_phase!=null) begin
      `uvm_info(get_full_name(),$sformatf("%s post_body() dropping %s objection",get_sequence_path(),starting_phase.get_name()), UVM_LOW);
       starting_phase.drop_objection(this);
   end
endtask : post_body

//---------------------------------------------------------------------------------------
//   Function    : pre_randomize    
//   Arguments   : 
//   Description : This function is used to print the value of transaction class before 
//                 randomize 
//----------------------------------------------------------------------------------------
function void dma_base_sequence::pre_randomize();
   super.pre_randomize();
endfunction:pre_randomize 

//----------------------------------------------------------------------------------------
//   Function    : post_randomize    
//   Arguments   : 
//   Description : This function is used to print the randomized value of transaction class  
//               Override the random value if needed from the command line 
//----------------------------------------------------------------------------------------
function void dma_base_sequence::post_randomize();
   super.post_randomize();
endfunction:post_randomize 


`endif //DMA_BASE_SEQUENCE_SV   




