package apb_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    typedef uvm_config_db#(virtual apb_if.driver_mp) apb_drv_vif_config;
    typedef uvm_config_db#(virtual apb_if.monitor_mp) apb_mon_vif_config;

    `include "apb_packet.sv"
    `include "apb_monitor.sv"
    `include "apb_sequencer.sv"
    `include "apb_driver.sv"
    `include "apb_agent.sv"
    `include "apb_seqs.sv"
    `include "apb_env.sv"
endpackage : apb_pkg