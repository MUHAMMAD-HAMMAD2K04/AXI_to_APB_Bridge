class apb_sequencer extends uvm_sequencer #(axi_to_apb_packet);
    `uvm_component_utils(apb_sequencer)

    function new(string name = "apb_sequencer" , uvm_component parent);
        super.new(name,parent);
    endfunction

    function void start_of_simulation_phase(uvm_phase phase);
        `uvm_info(get_type_name(),"Running Simulation---", UVM_HIGH)
    endfunction
endclass