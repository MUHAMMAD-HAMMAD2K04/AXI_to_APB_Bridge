// AXI Base Test 
class axi_base_test extends uvm_test;

    `uvm_component_utils(axi_base_test)

    bridge_tb tb;

    function new(string name="axi_base_test",
                 uvm_component parent);
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        uvm_config_db#(int)::set(this,"*agent.driver*","wait_cycles",0);
        tb = bridge_tb::type_id::create("tb", this);
    endfunction

    task run_phase(uvm_phase phase);
     phase.phase_done.set_drain_time(this, 500ns);
    endtask

    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        uvm_top.print_topology();
    endfunction
endclass


// Reset Sequence Test
class reset_seq_test extends axi_base_test;

    `uvm_component_utils(reset_seq_test)


    function new(string name="reset_seq_test",
                 uvm_component parent);
        super.new(name,parent);
    endfunction


    function void build_phase(uvm_phase phase);

        super.build_phase(phase);


        uvm_config_db#(uvm_object_wrapper)::set(
            this,
            "tb.AXI_env.agent.sequencer.run_phase",
            "default_sequence",
            reset_seq::type_id::get()
        );
    endfunction
endclass


// Single AXI Write Test
class axi_write_seq_test extends axi_base_test;

    `uvm_component_utils(axi_write_seq_test)


    function new(string name="axi_write_seq_test",
                 uvm_component parent);
        super.new(name,parent);
    endfunction


    function void build_phase(uvm_phase phase);

        super.build_phase(phase);


        uvm_config_db#(uvm_object_wrapper)::set(
            this,
            "tb.AXI_env.agent.sequencer.run_phase",
            "default_sequence",
            axi_write_seq::type_id::get()
        );
    endfunction

endclass

 
// AXI Read Test
class axi_read_seq_test extends axi_base_test;

    `uvm_component_utils(axi_read_seq_test)


    function new(string name="axi_read_seq_test",
                 uvm_component parent);
        super.new(name,parent);
    endfunction


    function void build_phase(uvm_phase phase);

        super.build_phase(phase);


        uvm_config_db#(uvm_object_wrapper)::set(
            this,
            "tb.AXI_env.agent.sequencer.run_phase",
            "default_sequence",
            axi_read_seq::type_id::get()
        );
    endfunction
endclass


// Five Write Sequence Test
class axi_five_write_seq_test extends axi_base_test;

    `uvm_component_utils(axi_five_write_seq_test)


    function new(string name="axi_five_write_seq_test",
                 uvm_component parent);
        super.new(name,parent);
    endfunction


    function void build_phase(uvm_phase phase);

        super.build_phase(phase);


        uvm_config_db#(uvm_object_wrapper)::set(
            this,
            "tb.AXI_env.agent.sequencer.run_phase",
            "default_sequence",
            axi_five_write_seq::type_id::get()
        );
    endfunction

endclass

// Wait State Sequence Test
class wait_state_test extends axi_base_test;

    `uvm_component_utils(wait_state_test)


    function new(string name="wait_state_test",
                 uvm_component parent);
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        uvm_config_db#(int)::set(
            this,
            "*agent.driver*",
            "wait_cycles",
            3
        );

        uvm_config_db#(uvm_object_wrapper)::set(
            this,
            "tb.AXI_env.agent.sequencer.run_phase",
            "default_sequence",
            axi_wait_state_seq::type_id::get()
            );
    endfunction
endclass


// Stress Sequence Test
class stress_test extends axi_base_test;

    `uvm_component_utils(stress_test)


    function new(string name="stress_test",
                 uvm_component parent);
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);

        int delay;

        super.build_phase(phase);

        delay = $urandom_range(0,5);

        uvm_config_db#(int)::set(
            this,
            "*agent.driver*",
            "wait_cycles",
            delay
        );

        uvm_config_db#(uvm_object_wrapper)::set(
            this,
            "tb.AXI_env.agent.sequencer.run_phase",
            "default_sequence",
            axi_stress_seq::type_id::get()
        );
    endfunction
endclass