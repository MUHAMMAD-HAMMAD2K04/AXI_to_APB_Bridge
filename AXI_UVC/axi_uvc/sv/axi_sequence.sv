class axi_sequence extends uvm_sequence #(axi_transaction);
  
  // Required macro for sequences automation
  `uvm_object_utils(axi_sequence)

  // Constructor
  function new(string name="axi_sequence");
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

endclass : axi_sequence

class axi_single_write_seq extends axi_sequence;

    `uvm_object_utils(axi_single_write_seq)

    axi_transaction tr;

    function new(string name="axi_single_write_seq");
        super.new(name);
    endfunction

    virtual task body();

        tr = axi_transaction::type_id::create("tr");

        start_item(tr);

        if(!tr.randomize() with
        {
            write == 1;
            addr inside {[32'h0000_0000:32'h0000_FFFF]};
            strb == 4'b1111;
        })
            `uvm_error(get_type_name(),"Randomization Failed")

        finish_item(tr);

        `uvm_info(get_type_name(),
                  tr.sprint(),
                  UVM_MEDIUM)

    endtask

endclass