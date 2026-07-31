class axi_agent extends uvm_agent;

  axi_sequencer sequencer;
  axi_driver    driver;
  axi_monitor   monitor;

    //FACTORY REGISTER "axi_agent"
    `uvm_component_utils_begin(axi_agent)
        `uvm_field_enum(uvm_active_passive_enum, is_active, UVM_ALL_ON)
    `uvm_component_utils_end

    //Constructor
  function new(string name = "axi_agent", uvm_component parent);
    super.new(name,parent);
  endfunction 

  function void build_phase(uvm_phase phase);
    super.build_phase(phase); 
        monitor = axi_monitor::type_id::create("monitor", this);
    if (is_active == UVM_ACTIVE)
    begin
        driver = axi_driver::type_id::create("driver", this);
        sequencer = axi_sequencer::type_id::create("sequencer", this);
    end
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
        if (is_active == UVM_ACTIVE)
    driver.seq_item_port.connect(sequencer.seq_item_export);
  endfunction

  function void start_of_simulation_phase(uvm_phase phase);
     `uvm_info(get_type_name(),"Running Simulation ...",UVM_HIGH);
  endfunction

endclass //axi_agent extends uvm_agent
