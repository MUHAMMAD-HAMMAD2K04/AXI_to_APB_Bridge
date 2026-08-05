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

        bit [31:0] saved_addr;
        bit [31:0] saved_data;

        // 500 write/read pairs = 1000 AXI transactions.  Every read checks
        // the exact address and data generated by the preceding write.
        repeat(500) begin

            req = axi_transaction::type_id::create("req");
            start_item(req);
            assert(req.randomize() with {
                write == 1'b1;
                addr inside {[32'h0:32'hFFFF]};
                strb == 4'hF;
            });
            saved_addr = req.addr;
            saved_data = req.data;
            finish_item(req);

            req = axi_transaction::type_id::create("req");
            start_item(req);
            assert(req.randomize() with {
                write == 1'b0;
                addr  == saved_addr;
                strb  == 4'h0;
            });
            finish_item(req);

            if (req.data !== saved_data)
                `uvm_error(get_type_name(),
                    $sformatf("STRESS READBACK FAILED ADDR=%08h EXP=%08h ACT=%08h",
                              saved_addr, saved_data, req.data))
            else
                `uvm_info(get_type_name(),
                    $sformatf("STRESS READBACK PASS ADDR=%08h DATA=%08h",
                              saved_addr, req.data), UVM_DEBUG)
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
            data  == 32'h0000_ABCD;
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
                if (write)
                    strb inside {4'b0001,
                                 4'b0011,
                                 4'b0111,
                                 4'b1111};
                else
                    strb == 4'b0000;
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

        bit [31:0] saved_addr;

        `uvm_info(get_type_name(),  "Starting Multiple Write-Read Sequence",  UVM_LOW)

        repeat (5) begin

            req = axi_transaction::type_id::create("req");
            start_item(req);
            assert(req.randomize() with {
                write == 1'b1;
                addr inside {[32'h0000_1000 : 32'h0000_FFFF]};
                strb == 4'b1111;
            });

            `uvm_info(get_type_name(),
                      {"AXI WRITE TRANSACTION\n", req.sprint()},
                      UVM_DEBUG)

            finish_item(req);

            addr_q.push_back(req.addr);
            data_q.push_back(req.data);

            `uvm_info(get_type_name(), $sformatf("WRITE : ADDR=0x%08h DATA=0x%08h",  req.addr, req.data), UVM_DEBUG)

        end

        for (int i = 0; i < addr_q.size(); i++) begin

            saved_addr = addr_q[i];
            req = axi_transaction::type_id::create("req");
            start_item(req);
            assert(req.randomize() with {
                write == 1'b0;
                addr  == saved_addr;
                strb  == 4'h0;
            });

            `uvm_info(get_type_name(),
                      {"AXI READ TRANSACTION\n", req.sprint()},
                      UVM_DEBUG)

            finish_item(req);

            if (req.data !== data_q[i])
                `uvm_error(get_type_name(),
                    $sformatf("MULTI READBACK FAILED ADDR=%08h EXP=%08h ACT=%08h",
                              saved_addr, data_q[i], req.data))
            else
                `uvm_info(get_type_name(),
                    $sformatf("MULTI READBACK PASS ADDR=%08h DATA=%08h",
                              saved_addr, req.data), UVM_DEBUG)

            `uvm_info(get_type_name(), $sformatf("READ  : ADDR=0x%08h",  req.addr), UVM_DEBUG)
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

        // Invalid write: explicitly disable the normal valid-address
        // constraint because this sequence intentionally goes out of range.
        req = axi_transaction::type_id::create("invalid_write_req");
        req.addr_range.constraint_mode(0);
        start_item(req);
        assert(req.randomize() with {
            write == 1'b1;
            addr  == 32'hFFFF_0000;   // Invalid Address
            strb  == 4'b1111;
        });
        finish_item(req);

        `uvm_info(get_type_name(), $sformatf("INVALID WRITE : ADDR=0x%08h DATA=0x%08h", req.addr, req.data),UVM_MEDIUM)

        // Invalid read
        req = axi_transaction::type_id::create("invalid_read_req");
        req.addr_range.constraint_mode(0);
        start_item(req);
        assert(req.randomize() with {
            write == 1'b0;
            addr  == 32'hFFFF_0000;   // Same Invalid Address
            strb  == 4'h0;
        });
        finish_item(req);

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

// FIFO Full Sequence
class axi_fifo_full_seq extends axi_base_seq;
    `uvm_object_utils(axi_fifo_full_seq)

    function new(string name="axi_fifo_full_seq");
        super.new(name);
    endfunction

    virtual task body();
        bit [31:0] expected_data = 32'h0000_F11F;

        req = axi_transaction::type_id::create("fifo_full_write");
        start_item(req);
        assert(req.randomize() with {
            write == 1'b1; addr == 32'h0000_2000;
            data == expected_data; strb == 4'hF;
        });
        finish_item(req);

        req = axi_transaction::type_id::create("fifo_full_read");
        start_item(req);
        assert(req.randomize() with {
            write == 1'b0; addr == 32'h0000_2000;
        });
        req.rd_full_cycles = 10;
        finish_item(req);

        if (req.data !== expected_data)
            `uvm_error(get_type_name(), "FIFO-full readback mismatch")
    endtask
endclass

// FIFO Empty Sequence
class axi_fifo_empty_seq extends axi_base_seq;
    `uvm_object_utils(axi_fifo_empty_seq)

    function new(string name="axi_fifo_empty_seq");
        super.new(name);
    endfunction

    virtual task body();
        req = axi_transaction::type_id::create("fifo_empty_req");
        start_item(req);
        assert(req.randomize() with {
            write == 1'b1; addr == 32'h0000_2400; strb == 4'hF;
        });
        req.req_empty_cycles = 8;
        finish_item(req);
    endtask
endclass

// Reset During Active Transaction Sequence
class axi_reset_during_transaction_seq extends axi_base_seq;
    `uvm_object_utils(axi_reset_during_transaction_seq)

    function new(string name="axi_reset_during_transaction_seq");
        super.new(name);
    endfunction

    virtual task body();
        bit [31:0] expected_data = 32'h0000_A55A;

        req = axi_transaction::type_id::create("reset_during_write");
        start_item(req);
        assert(req.randomize() with {
            write == 1'b1; addr == 32'h0000_2800;
            data == expected_data; strb == 4'hF;
        });
        req.reset_during = 1'b1;
        finish_item(req);

        req = axi_transaction::type_id::create("post_reset_read");
        start_item(req);
        assert(req.randomize() with {
            write == 1'b0; addr == 32'h0000_2800;
        });
        finish_item(req);

        if (req.data !== expected_data)
            `uvm_error(get_type_name(), "Reset-during-transaction recovery failed")
    endtask
endclass

// Random Valid Address Sequence
class axi_random_address_seq extends axi_base_seq;
    `uvm_object_utils(axi_random_address_seq)

    function new(string name="axi_random_address_seq");
        super.new(name);
    endfunction

    virtual task body();
        repeat (25) begin
            req = axi_transaction::type_id::create("random_address_req");
            start_item(req);
            assert(req.randomize() with {
                addr inside {[32'h0000_0000:32'h0000_FFFF]};
                write dist {1 := 50, 0 := 50};
                if (write) strb == 4'hF;
            });
            finish_item(req);
        end
    endtask
endclass

// Random FIFO Stress Sequence
class axi_random_fifo_stress_seq extends axi_base_seq;
    `uvm_object_utils(axi_random_fifo_stress_seq)

    function new(string name="axi_random_fifo_stress_seq");
        super.new(name);
    endfunction

    virtual task body();
        bit [31:0] saved_addr;
        bit [31:0] saved_data;

        repeat (100) begin
            req = axi_transaction::type_id::create("fifo_stress_write");
            start_item(req);
            assert(req.randomize() with { write == 1'b1; strb == 4'hF; });
            req.req_empty_cycles = $urandom_range(0, 5);
            saved_addr = req.addr;
            saved_data = req.data;
            finish_item(req);

            req = axi_transaction::type_id::create("fifo_stress_read");
            start_item(req);
            assert(req.randomize() with { write == 1'b0; addr == saved_addr; });
            req.req_empty_cycles = $urandom_range(0, 5);
            req.rd_full_cycles  = $urandom_range(0, 10);
            finish_item(req);

            if (req.data !== saved_data)
                `uvm_error(get_type_name(),
                    $sformatf("Random FIFO stress mismatch ADDR=%08h EXP=%08h ACT=%08h",
                              saved_addr, saved_data, req.data))
        end
    endtask
endclass

// axi_regression_seq
class axi_regression_seq extends axi_base_seq;

    `uvm_object_utils(axi_regression_seq)

    function new(string name="axi_regression_seq");
        super.new(name);
    endfunction

    virtual task body();

        reset_seq                        reset;
        axi_read_seq                     rd;
        axi_write_seq                    wr;
        axi_read_after_write_seq         raw_seq;
        axi_fifo_full_seq                fifo_full;
        axi_fifo_empty_seq               fifo_empty;
        axi_five_write_seq               multi_write;
        axi_random_read_write_seq        rand_rw;
        axi_five_read_seq                multi_read;
        axi_invalid_address_seq          invalid;
        axi_reset_during_transaction_seq reset_active;
        axi_random_address_seq           rand_addr;
        axi_random_fifo_stress_seq       fifo_stress;
        axi_random_wait_state_seq        rand_wait;

        `uvm_info(get_type_name(),
                  "========== STARTING REGRESSION ==========",
                  UVM_LOW)

        reset = reset_seq::type_id::create("reset");
        reset.start(m_sequencer);

        rd = axi_read_seq::type_id::create("rd");
        rd.start(m_sequencer);

        wr = axi_write_seq::type_id::create("wr");
        wr.start(m_sequencer);

        raw_seq = axi_read_after_write_seq::type_id::create("raw_seq");
        raw_seq.start(m_sequencer);

        fifo_full = axi_fifo_full_seq::type_id::create("fifo_full");
        fifo_full.start(m_sequencer);

        fifo_empty = axi_fifo_empty_seq::type_id::create("fifo_empty");
        fifo_empty.start(m_sequencer);

        multi_write = axi_five_write_seq::type_id::create("multi_write");
        multi_write.start(m_sequencer);

        rand_rw = axi_random_read_write_seq::type_id::create("rand_rw");
        rand_rw.start(m_sequencer);

        multi_read = axi_five_read_seq::type_id::create("multi_read");
        multi_read.start(m_sequencer);

        invalid = axi_invalid_address_seq::type_id::create("invalid");
        invalid.start(m_sequencer);

        reset_active = axi_reset_during_transaction_seq::type_id::create("reset_active");
        reset_active.start(m_sequencer);

        rand_addr = axi_random_address_seq::type_id::create("rand_addr");
        rand_addr.start(m_sequencer);

        fifo_stress = axi_random_fifo_stress_seq::type_id::create("fifo_stress");
        fifo_stress.start(m_sequencer);

        rand_wait = axi_random_wait_state_seq::type_id::create("rand_wait");
        rand_wait.start(m_sequencer);

        `uvm_info(get_type_name(),
                  "========== REGRESSION COMPLETED ==========",
                  UVM_LOW)

    endtask

endclass
