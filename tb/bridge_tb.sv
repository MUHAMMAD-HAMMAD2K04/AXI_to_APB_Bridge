import uvm_pkg::*;
`include "uvm_macros.svh"

class bridge_tb extends uvm_env;
    `uvm_component_utils(bridge_tb)

    apb_env APB_env;
    axi_env AXI_env;   

    function new(string name = "bridge_tb", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        APB_env = apb_env::type_id::create("APB_env", this);
        AXI_env = axi_env::type_id::create("AXI_env", this);
        `uvm_info(get_type_name(), "Build Phase of Testbench executed!", UVM_HIGH)
    endfunction

    function void start_of_simulation_phase(uvm_phase phase);
        `uvm_info(get_type_name(),"Running Simulation---", UVM_HIGH)
    endfunction
endclass