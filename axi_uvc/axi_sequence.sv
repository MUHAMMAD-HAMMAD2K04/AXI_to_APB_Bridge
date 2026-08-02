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

 
// Five Write Sequence
class axi_five_write_seq extends axi_base_seq;

    `uvm_object_utils(axi_five_write_seq)

    function new(string name="axi_five_write_seq");
        super.new(name);
    endfunction


    virtual task body();

        `uvm_info(get_type_name(),
                  "Starting Five Write Sequence",
                  UVM_LOW)

        repeat(5) begin

            `uvm_do_with(req,
            {
                write == 1'b1;
                addr inside {[32'h0000_0000 :
                              32'h0000_FFFF]};
                strb == 4'b1111;
            })

            `uvm_info(get_type_name(),
                      $sformatf("Write Transaction:\n%s",
                      req.sprint()),
                      UVM_MEDIUM)

        end

    endtask

endclass

// Reset Sequence
class reset_seq extends axi_base_seq;

    `uvm_object_utils(reset_seq)

    function new(string name = "reset_seq");
        super.new(name);
    endfunction

    virtual task body();

        `uvm_info(get_type_name(),
                  "Starting Reset Sequence",
                  UVM_LOW)

        `uvm_do_with(req,
        {
            write == 0;
            addr  == 32'h0000_0000;
            data  == 32'h0000_0000;
            strb  == 4'b0000;
        })

        `uvm_info(get_type_name(),
                  "Reset Sequence Completed",
                  UVM_MEDIUM)

    endtask

endclass


// Single AXI Write Sequence
class axi_write_seq extends axi_base_seq;

    `uvm_object_utils(axi_write_seq)


    function new(string name="axi_write_seq");
        super.new(name);
    endfunction


    virtual task body();


        `uvm_info(get_type_name(),
                  "Starting AXI Write Sequence",
                  UVM_LOW)


        `uvm_do_with(req,
        {
            write == 1'b1;
            addr inside {[32'h0000_0000 :
                          32'h0000_FFFF]};
            strb == 4'b1111;
        })


        `uvm_info(get_type_name(),
                  $sformatf("Write Transaction:\n%s",
                  req.sprint()),
                  UVM_MEDIUM)

    endtask

endclass


// AXI Read Sequence
class axi_read_seq extends axi_base_seq;

    `uvm_object_utils(axi_read_seq)


    function new(string name="axi_read_seq");
        super.new(name);
    endfunction


    virtual task body();


        `uvm_info(get_type_name(),
                  "Starting AXI Read Sequence",
                  UVM_LOW)


        `uvm_do_with(req,
        {
            write == 1'b0;
            addr inside {[32'h0000_0000 :
                          32'h0000_FFFF]};
        })


        `uvm_info(get_type_name(),
                  $sformatf("Read Transaction:\n%s",
                  req.sprint()),
                  UVM_MEDIUM)

    endtask

endclass