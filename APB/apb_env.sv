class apb_env extends uvm_env;
    `uvm_component_utils(apb_env)

    apb_agent agent;
    apb_coverage apb_cov; 

    function new(string name = "apb_env", uvm_component parent);
        super.new(name,parent);
    endfunction

    function void build_phase (uvm_phase phase);
        super.build_phase(phase);
        agent=apb_agent::type_id::create("agent", this);
        apb_cov = apb_coverage::type_id::create("apb_cov", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        agent.monitor.analysis_port.connect(apb_cov.analysis_export);
    endfunction

    function void start_of_simulation_phase(uvm_phase phase);
        `uvm_info(get_type_name(),"Running Simulation---", UVM_HIGH)
    endfunction
endclass