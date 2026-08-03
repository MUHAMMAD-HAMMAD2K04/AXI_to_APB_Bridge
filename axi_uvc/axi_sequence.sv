class axi_base_seq extends uvm_sequence #(axi_transaction);
  `uvm_object_utils(axi_base_seq)

    function new(string name="axi_base_seq");
        super.new(name);
    endfunction

    task pre_body();
        uvm_phase phase;
        `ifdef UVM_VERSION_1_2
        // in UVM1.2, get starting phase from method
        phase = get_starting_phase();
        `else
        phase = starting_phase;
        `endif
        if (phase != null) begin
        phase.raise_objection(this, get_type_name());
        `uvm_info(get_type_name(), "raise objection", UVM_MEDIUM)
        end
    endtask : pre_body

    task post_body();
        uvm_phase phase;
        `ifdef UVM_VERSION_1_2
        // in UVM1.2, get starting phase from method
        phase = get_starting_phase();
        `else
        phase = starting_phase;
        `endif
        if (phase != null) begin
        phase.drop_objection(this, get_type_name());
        `uvm_info(get_type_name(), "drop objection", UVM_MEDIUM)
        end
    endtask : post_body
endclass : axi_base_seq

// Reset Sequence
class reset_seq extends axi_base_seq;

    `uvm_object_utils(reset_seq)

    function new(string name="reset_seq");
        super.new(name);
    endfunction

    virtual task body();

        req = axi_transaction::type_id::create("req");

        start_item(req);

        assert(req.randomize() with {
            write == 0;
            addr  == 32'h0;
            data  == 32'h0;
            strb  == 4'h0;
        });

        `uvm_info(get_type_name(),
        {"Generated RESET Transaction\n",req.sprint()},
        UVM_MEDIUM)

        finish_item(req);

    endtask

endclass

// Single Write Sequence
class axi_write_seq extends axi_base_seq;

    `uvm_object_utils(axi_write_seq)

    function new(string name="axi_write_seq");
        super.new(name);
    endfunction

    virtual task body();

        req = axi_transaction::type_id::create("req");

        start_item(req);

        assert(req.randomize() with {
            write == 1;
            addr inside {[32'h0:32'hFFFF]};
            strb == 4'hF;
        });

        `uvm_info(get_type_name(),
        {"Generated WRITE Transaction\n",req.sprint()},
        UVM_MEDIUM)

        finish_item(req);

    endtask

endclass

// Single Read Sequence
class axi_read_seq extends axi_base_seq;

    `uvm_object_utils(axi_read_seq)

    function new(string name="axi_read_seq");
        super.new(name);
    endfunction

    virtual task body();

        req = axi_transaction::type_id::create("req");

        start_item(req);

        assert(req.randomize() with {
            write == 0;
            addr inside {[32'h0:32'hFFFF]};
        });

        `uvm_info(get_type_name(),
        {"Generated READ Transaction\n",req.sprint()},
        UVM_MEDIUM)

        finish_item(req);

    endtask

endclass 

// Five Consecutive Write Sequence
class axi_five_write_seq extends axi_base_seq;

    `uvm_object_utils(axi_five_write_seq)

    function new(string name="axi_five_write_seq");
        super.new(name);
    endfunction

    virtual task body();

        repeat(5) begin

            req = axi_transaction::type_id::create("req");

            start_item(req);

            assert(req.randomize() with {
                write == 1;
                addr inside {[32'h0:32'hFFFF]};
                strb == 4'hF;
            });

            `uvm_info(get_type_name(),
            {"Generated WRITE\n",req.sprint()},
            UVM_MEDIUM)

            finish_item(req);

        end

    endtask

endclass

// Five Consecutive Read Sequence
class axi_five_read_seq extends axi_base_seq;

    `uvm_object_utils(axi_five_read_seq)

    function new(string name="axi_five_read_seq");
        super.new(name);
    endfunction

    virtual task body();

        repeat(5) begin

            req = axi_transaction::type_id::create("req");

            start_item(req);

            assert(req.randomize() with {
                write == 0;
                addr inside {[32'h0:32'hFFFF]};
            });

            `uvm_info(get_type_name(),
            {"Generated READ\n",req.sprint()},
            UVM_MEDIUM)

            finish_item(req);

        end

    endtask

endclass

// Wait State Sequence
class axi_wait_state_seq extends axi_base_seq;

    `uvm_object_utils(axi_wait_state_seq)

    function new(string name="axi_wait_state_seq");
        super.new(name);
    endfunction

    virtual task body();

        repeat(10) begin

            req = axi_transaction::type_id::create("req");

            start_item(req);

            assert(req.randomize() with {
                addr inside {[32'h0:32'hFFFF]};
            });

            `uvm_info(get_type_name(),
            {"Generated WAIT STATE SEQ\n",req.sprint()},
            UVM_MEDIUM)


            finish_item(req);

        end

    endtask

endclass

// Random Stress Sequence
class axi_stress_seq extends axi_base_seq;

    `uvm_object_utils(axi_stress_seq)

    function new(string name="axi_stress_seq");
        super.new(name);
    endfunction

    virtual task body();

        repeat(1000) begin

            req = axi_transaction::type_id::create("req");

            start_item(req);

            assert(req.randomize() with {
                addr inside {[32'h0:32'hFFFF]};
            });

            `uvm_info(get_type_name(),
            {"Generated STRESS STATE SEQ\n",req.sprint()},
            UVM_MEDIUM)

            finish_item(req);

        end

    endtask

endclass