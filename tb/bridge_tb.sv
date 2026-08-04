import uvm_pkg::*;
`include "uvm_macros.svh"

class bridge_tb extends uvm_env;
    `uvm_component_utils(bridge_tb)

    apb_env APB_env;
    axi_env AXI_env;  
    bridge_ref_model ref_model;
    bridge_scoreboard      scb;
    axi_coverage axi_cov;
    apb_coverage apb_cov; 

    function new(string name = "bridge_tb", uvm_component parent);
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        APB_env = apb_env::type_id::create("APB_env", this);
        AXI_env = axi_env::type_id::create("AXI_env", this);
        ref_model = bridge_ref_model::type_id::create("ref_model", this);
        scb       = bridge_scoreboard::type_id::create("scb", this);
        axi_cov = axi_coverage::type_id::create("axi_cov", this);
        apb_cov = apb_coverage::type_id::create("apb_cov", this);
        `uvm_info(get_type_name(), "Build Phase of Testbench executed!", UVM_HIGH)
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        // AXI Monitor -> Reference Model
        AXI_env.agent.monitor.ap.connect(ref_model.axi_imp);

        // Reference Model -> Scoreboard
        ref_model.expected_apb_port.connect(scb.expected_fifo.analysis_export);

        // APB Monitor -> Scoreboard
        APB_env.agent.monitor.analysis_port.connect(scb.actual_fifo.analysis_export);
        
        //Coverage connection
        AXI_env.agent.monitor.ap.connect(axi_cov.analysis_export);
        APB_env.agent.monitor.analysis_port.connect(apb_cov.analysis_export);
    endfunction

    function void start_of_simulation_phase(uvm_phase phase);
        `uvm_info(get_type_name(),"Running Simulation ...", UVM_HIGH)
    endfunction
endclass