class axi_sequencer extends uvm_sequencer#(axi_transaction);
    
    //FACTORY REGISTER "axi_sequencer"
    `uvm_component_utils(axi_sequencer)

     //ADD A CONSTRUCTOR    
    function new(string name = "axi_sequencer", uvm_component parent);
        super.new(name,parent);
    endfunction //new()

    function void start_of_simulation_phase(uvm_phase phase);
        `uvm_info(get_type_name(),"Running Simulation ...", UVM_HIGH);
    endfunction

endclass //axi_sequencer extends uvm_sequencer