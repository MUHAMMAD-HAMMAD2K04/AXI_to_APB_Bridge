class axi_base_seq extends uvm_sequence #(axi_transaction);

    `uvm_object_utils(axi_base_seq)

    axi_transaction req;

    function new(string name="axi_base_seq");
        super.new(name);
    endfunction

    virtual task body();
    endtask

endclass
//--------------------------------------------------------
class axi_five_write_seq extends axi_base_seq;

    `uvm_object_utils(axi_five_write_seq)

    function new(string name = "axi_five_write_seq");
        super.new(name);
    endfunction

    virtual task body();
        axi_transaction tr;
        `uvm_info(get_type_name(),
                "Starting sequence to write packet...",
                UVM_LOW)
        repeat (5)begin
        tr = axi_transaction::type_id::create("tr");
        start_item(tr);
        if (!tr.randomize() with {
                write == 1'b1;
                addr inside {[32'h0000_0000 : 32'h0000_FFFF]};
                strb == 4'b1111;
            })
        begin
            `uvm_error(get_type_name(),
                    "Randomization failed!")
        end
        `uvm_info(get_type_name(),
                $sformatf("Sent Write Transaction:\n%s",
                tr.sprint()),
                UVM_MEDIUM)

        finish_item(tr);
        end
    endtask

endclass

//----------------------------------------------------------
class reset_seq extends axi_base_seq;

    `uvm_object_utils(reset_seq)

    function new(string name = "reset_seq");
        super.new(name);
    endfunction

    virtual task body();

        `uvm_info(get_type_name(),
                  "Reset sequence started. DUT reset is handled through the interface, not as an AXI transaction.",
                  UVM_LOW)

    endtask

endclass
//------------------------------------------
class axi_write_seq extends axi_base_seq;

    `uvm_object_utils(axi_write_seq)

    function new(string name = "axi_write_seq");
        super.new(name);
    endfunction

    virtual task body(); 

        axi_transaction tr;

        `uvm_info(get_type_name(),
                  "Starting AXI Write Sequence...",
                  UVM_LOW)

        tr = axi_transaction::type_id::create("tr");

        start_item(tr);

        if (!tr.randomize() with {
                write == 1'b1;
                addr inside {[32'h0000_0000 : 32'h0000_FFFF]};
                strb == 4'b1111;
            })
        begin
            `uvm_error(get_type_name(),"Randomization failed!")
             end

        `uvm_info(get_type_name(), $sformatf("Sent Write Transaction:\n%s", tr.sprint()), UVM_MEDIUM)
        finish_item(tr);
    endtask

endclass
//---------------------------------------
class axi_read_seq extends axi_base_seq;

    `uvm_object_utils(axi_read_seq)

    function new(string name = "axi_read_seq");
        super.new(name);
    endfunction

    virtual task body();
        axi_transaction tr;

        `uvm_info(get_type_name(), "Starting AXI Read Sequence...",UVM_LOW)

        tr = axi_transaction::type_id::create("tr");
        start_item(tr);
        if (!tr.randomize() with {
                write == 1'b0;
                addr inside {[32'h0000_0000 : 32'h0000_FFFF]};
            })
        begin
            `uvm_error(get_type_name(), "Randomization failed!")
        end
        `uvm_info(get_type_name(), $sformatf("Sent Read Transaction:\n%s", tr.sprint()), UVM_MEDIUM)
        finish_item(tr);
    endtask

endclass
