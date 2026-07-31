class axi_env extends uvm_env;

    // agent handle
    axi_agent agent; 
    //axi_scoreboard scb;

    `uvm_component_utils(axi_env)

    function new(string name = "axi_env", uvm_component parent);
        super.new(name, parent);
    endfunction //new()

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        agent = axi_agent::type_id::create("agent",this);
        //scb   = axi_scoreboard::type_id::create("scb",this);

    endfunction

    // function void connect_phase(uvm_phase phase);
    //     super.connect_phase(phase);
    //     agent.monitor.ap.connect(scb.analysis_export);
    // endfunction

    function void start_of_simulation_phase(uvm_phase phase);
        `uvm_info(get_type_name(),"Running Simulation ...",UVM_HIGH);
    endfunction

endclass //axi_env extends uvm_env