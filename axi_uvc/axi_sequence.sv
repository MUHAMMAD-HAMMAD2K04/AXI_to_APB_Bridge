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

// axi_read_after_write_seq
class axi_read_after_write_seq extends axi_base_seq;

    `uvm_object_utils(axi_read_after_write_seq)

    function new(string name = "axi_read_after_write_seq");
        super.new(name);
    endfunction

    virtual task body();

        axi_transaction tr;

        `uvm_info(get_type_name(),"Starting Read-After-Write Sequence...", UVM_LOW)

        `uvm_do_with(tr,{
            write == 1'b1;
            addr  == 32'h0000_1000;
            data  == 32'h1234_ABCD;
            strb  == 4'b1111;
        })

        `uvm_info(get_type_name(), $sformatf("WRITE : ADDR=0x%08h DATA=0x%08h",tr.addr, tr.data), UVM_MEDIUM)

        `uvm_do_with(tr,{
            write == 1'b0;
            addr  == 32'h0000_1000;
        })

        `uvm_info(get_type_name(), $sformatf("READ  : ADDR=0x%08h",tr.addr), UVM_MEDIUM)

    endtask
endclass

//axi_random_read_write_seq
class axi_random_read_write_seq extends axi_base_seq;

    `uvm_object_utils(axi_random_read_write_seq)

    function new(string name = "axi_random_read_write_seq");
        super.new(name);
    endfunction

    virtual task body();

        axi_transaction tr;

        `uvm_info(get_type_name(), "Starting Random Read/Write Sequence...", UVM_LOW)

        // Generate 20 random transactions
        repeat (20) begin

            `uvm_do_with(tr,{
                write dist {1 := 50, 0 := 50};
                addr inside {[32'h0000_0000 : 32'h0000_FFFF]};
                strb inside {4'b0001,
                             4'b0011,
                             4'b0111,
                             4'b1111};
            })

            if (tr.write)
                `uvm_info(get_type_name(), $sformatf("WRITE : ADDR=0x%08h DATA=0x%08h STRB=%b",tr.addr, tr.data, tr.strb),UVM_MEDIUM)
            else
                `uvm_info(get_type_name(),   $sformatf("READ  : ADDR=0x%08h", tr.addr), UVM_MEDIUM)
        end

        `uvm_info(get_type_name(), "Random Read/Write Sequence Completed", UVM_LOW)

    endtask

endclass

// axi_multiple_write_read_seq
class axi_multiple_write_read_seq extends axi_base_seq;

    `uvm_object_utils(axi_multiple_write_read_seq)

    bit [31:0] addr_q[$];
    bit [31:0] data_q[$];

    function new(string name = "axi_multiple_write_read_seq");
        super.new(name);
    endfunction

    virtual task body();

        `uvm_info(get_type_name(),  "Starting Multiple Write-Read Sequence",  UVM_LOW)

        repeat (5) begin

            `uvm_do_with(req,{
                write == 1'b1;
                addr inside {[32'h0000_1000 : 32'h0000_FFFF]};
                strb == 4'b1111;
            })

            addr_q.push_back(req.addr);
            data_q.push_back(req.data);

            `uvm_info(get_type_name(), $sformatf("WRITE : ADDR=0x%08h DATA=0x%08h",  req.addr, req.data), UVM_MEDIUM)

        end

        for (int i = 0; i < addr_q.size(); i++) begin

            `uvm_do_with(req,{
                write == 1'b0;
                addr  == local::addr_q[i];
            })

            `uvm_info(get_type_name(), $sformatf("READ  : ADDR=0x%08h",  req.addr), UVM_MEDIUM)
        end
        `uvm_info(get_type_name(),  "Multiple Write-Read Sequence Completed", UVM_LOW)

    endtask

endclass

// Invalid Address Sequence
class axi_invalid_address_seq extends axi_base_seq;

    `uvm_object_utils(axi_invalid_address_seq)

    function new(string name = "axi_invalid_address_seq");
        super.new(name);
    endfunction

    virtual task body();

        `uvm_info(get_type_name(), "Starting Invalid Address Test", UVM_LOW)

        // Invalid Write
        `uvm_do_with(req,{
            write == 1'b1;
            addr  == 32'hFFFF_0000;   // Invalid Address
            strb  == 4'b1111;
        })

        `uvm_info(get_type_name(), $sformatf("INVALID WRITE : ADDR=0x%08h DATA=0x%08h", req.addr, req.data),UVM_MEDIUM)

        // Invalid Read
        `uvm_do_with(req,{
            write == 1'b0;
            addr  == 32'hFFFF_0000;   // Same Invalid Address
        })

        `uvm_info(get_type_name(),  $sformatf("INVALID READ  : ADDR=0x%08h",  req.addr),  UVM_MEDIUM)

        `uvm_info(get_type_name(),  "Invalid Address Test Completed",  UVM_LOW)

    endtask

endclass

//axi_random_wait_state_seq
class axi_random_wait_state_seq extends axi_base_seq;

    `uvm_object_utils(axi_random_wait_state_seq)

    function new(string name="axi_random_wait_state_seq");
        super.new(name);
    endfunction

    virtual task body();

        `uvm_info(get_type_name(),  "Starting Random Wait-State Test", UVM_LOW)

        repeat (20) begin

            `uvm_do_with(req,{
                write dist {1:=50,0:=50};

                addr inside {[32'h0000_0000:32'h0000_FFFF]};

                if(write)
                    strb inside {4'b0001,
                                 4'b0011,
                                 4'b0111,
                                 4'b1111};
            })

            if(req.write)
                `uvm_info(get_type_name(), $sformatf("WRITE : ADDR=0x%08h DATA=0x%08h", req.addr,req.data),UVM_MEDIUM)
            else
                `uvm_info(get_type_name(), $sformatf("READ  : ADDR=0x%08h", req.addr),UVM_MEDIUM);

        end

        `uvm_info(get_type_name(),  "Random Wait-State Test Completed",  UVM_LOW)

    endtask

endclass
