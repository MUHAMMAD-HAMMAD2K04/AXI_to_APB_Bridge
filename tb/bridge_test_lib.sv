// AXI Base Test 
class axi_base_test extends uvm_test;

    `uvm_component_utils(axi_base_test)

    axi_tb tb;

    function new(string name="axi_base_test",
                 uvm_component parent);
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        tb = axi_tb::type_id::create("tb", this);

    endfunction

    function void end_of_elaboration_phase(uvm_phase phase);

        super.end_of_elaboration_phase(phase);

        uvm_top.print_topology();

        phase.phase_done.set_drain_time(this, 100ns);

    endfunction


endclass


// Five Write Sequence Test
class axi_single_write_seq_test extends axi_base_test;

    `uvm_component_utils(axi_single_write_seq_test)


    function new(string name="axi_single_write_seq_test",
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