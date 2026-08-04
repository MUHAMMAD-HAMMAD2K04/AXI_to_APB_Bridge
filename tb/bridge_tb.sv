import uvm_pkg::*;
`include "uvm_macros.svh"

class bridge_tb extends uvm_env;
    `uvm_component_utils(bridge_tb)

    apb_env APB_env;
    axi_env AXI_env;  
    bridge_ref_model ref_model;
    bridge_scoreboard      scb;
    bridge_cross_coverage cross_cov;   // cross-coverage component   

    function new(string name = "bridge_tb", uvm_component parent);
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        APB_env = apb_env::type_id::create("APB_env", this);
        AXI_env = axi_env::type_id::create("AXI_env", this);
        ref_model = bridge_ref_model::type_id::create("ref_model", this);
        scb       = bridge_scoreboard::type_id::create("scb", this);
        cross_cov = bridge_cross_coverage::type_id::create("cross_cov", this);
        `uvm_info(get_type_name(), "Build Phase of Testbench executed!", UVM_HIGH)
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        // AXI Monitor -> Reference Model
        AXI_env.agent.monitor.ap.connect(ref_model.axi_imp);

        // APB Monitor -> Reference Model
        APB_env.agent.monitor.analysis_port.connect(ref_model.apb_imp);

    // Reference Model -> Scoreboard

        //Expected APB transactions
        ref_model.expected_apb_port.connect(scb.expected_apb_fifo.analysis_export);
        
        // Expected AXI transactions
        ref_model.expected_axi_port.connect(scb.expected_axi_fifo.analysis_export);

    // Actual Monitor -> Scoreboard

        //  Actual APB transactions
        APB_env.agent.monitor.analysis_port.connect(scb.actual_apb_fifo.analysis_export);
        
        //  Actual AXI transactions
        AXI_env.agent.monitor.ap.connect(scb.actual_axi_fifo.analysis_export);
        
        AXI_env.agent.monitor.ap.connect(cross_cov.axi_fifo.analysis_export);
        APB_env.agent.monitor.analysis_port.connect(cross_cov.apb_fifo.analysis_export);
    endfunction

    // Start of Simulation
    function void start_of_simulation_phase(uvm_phase phase);
        `uvm_info(get_type_name(),"Running Simulation ...", UVM_HIGH)
    endfunction
    
endclass