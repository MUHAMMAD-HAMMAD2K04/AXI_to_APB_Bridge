
class axi_base_test extends uvm_test;

    `uvm_component_utils(axi_base_test)

    bridge_tb tb;

    function new(string name="axi_base_test", uvm_component parent);
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        tb = bridge_tb::type_id::create("tb", this);

    endfunction

    task run_phase(uvm_phase phase);
        uvm_objection obj = phase.get_objection();
        obj.set_drain_time(this, 200ns);
    endtask

    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        uvm_top.print_topology();
    endfunction

endclass

class axi_single_write_seq_test extends axi_base_test;

    `uvm_component_utils(axi_single_write_seq_test)

    function new(string name="axi_single_write_seq_test",uvm_component parent);
        super.new(name,parent);
    endfunction


    task run_phase(uvm_phase phase);

        axi_five_write_seq seq;

        super.run_phase(phase);

        phase.raise_objection(this);

        seq = axi_five_write_seq::type_id::create("seq");

        seq.start(tb.AXI_env.agent.sequencer);

        phase.drop_objection(this);

    endtask

endclass
//----------------------------------------------
//----------------------------------------------
class reset_seq_test extends axi_base_test;

    `uvm_component_utils(reset_seq_test)

    function new(string name="reset_seq_test",uvm_component parent);
        super.new(name,parent);
    endfunction


    task run_phase(uvm_phase phase);

        reset_seq seq;

        super.run_phase(phase);

        phase.raise_objection(this);

        seq = reset_seq::type_id::create("seq");

        seq.start(tb.env.agent.sequencer);

        phase.drop_objection(this);

    endtask

endclass

//--------------------------------------------
//--------------------------------------------
class axi_write_seq_test extends axi_base_test;

    `uvm_component_utils(axi_write_seq_test)

    function new(string name="axi_write_seq_test",uvm_component parent);
        super.new(name,parent);
    endfunction


    task run_phase(uvm_phase phase);

        axi_write_seq seq;

        super.run_phase(phase);

        phase.raise_objection(this);

        seq = axi_write_seq::type_id::create("seq");

        seq.start(tb.env.agent.sequencer);

        phase.drop_objection(this);

    endtask

endclass
//--------------------------------------------
//--------------------------------------------
class axi_read_seq_test extends axi_base_test;

    `uvm_component_utils(axi_read_seq_test)

    function new(string name="axi_read_seq_test",uvm_component parent);
        super.new(name,parent);
    endfunction


    task run_phase(uvm_phase phase);

        axi_read_seq seq;

        super.run_phase(phase);

        phase.raise_objection(this);

        seq = axi_read_seq::type_id::create("seq");

        seq.start(tb.env.agent.sequencer);

        phase.drop_objection(this);

    endtask

endclass
