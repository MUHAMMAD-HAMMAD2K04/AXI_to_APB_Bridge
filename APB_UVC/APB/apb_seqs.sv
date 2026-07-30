class apb_base_seq extends uvm_sequence #(axi_to_apb_packet);
  `uvm_object_utils(apb_base_seq)

    function new(string name="apb_base_seq");
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
endclass : apb_base_seq

class apb_5_packets extends apb_base_seq;
  `uvm_object_utils(apb_5_packets)

  function new(string name="apb_5_packets");
    super.new(name);
  endfunction

  virtual task body();
    `uvm_info(get_type_name(), "Executing apb_5_packets sequence", UVM_LOW)

    repeat(5)
        `uvm_do(req)
  endtask
endclass : apb_5_packets
