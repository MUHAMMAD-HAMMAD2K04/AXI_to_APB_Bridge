import uvm_pkg::*;
`include "uvm_macros.svh"

class base_test extends uvm_test;
    `uvm_component_utils(base_test)
    
    bridge_tb tb;

    function new(string name="base_test", uvm_component parent);
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        uvm_config_wrapper::set
        (   this, "tb.APB_env.agent.sequencer.run_phase",  
            "default_sequence",
            apb_5_packets::get_type()
        );
                               
        tb = bridge_tb::type_id::create("tb", this);
        `uvm_info(get_type_name(), "Build phase of the test is being executed", UVM_HIGH)
    endfunction

    task run_phase(uvm_phase phase);
        uvm_objection obj = phase.get_objection();
        obj.set_drain_time(this, 200ns);
    endtask

    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        uvm_top.print_topology();
    endfunction

    function void check_phase(uvm_phase phase);
        check_config_usage();
        uvm_config_int::set( this, "*", "recording_detail", 1);
    endfunction
endclass: base_test

class set_config_test extends base_test;
    `uvm_component_utils(set_config_test)

    function new(string name="set_config_test", uvm_component parent);
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);
        uvm_config_int::set( this, "tb.env.agent", "is_active", UVM_PASSIVE);
        super.build_phase(phase);
    endfunction
endclass: set_config_test