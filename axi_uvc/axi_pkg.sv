`timescale 1ns/1ps
package axi_pkg;
    
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    
    typedef uvm_config_db#(virtual axi_if) axi_vif_config;

    // INCLUDING ALL MY CLASSES IN "axi_pkg.sv" 
    // SO THAT TOP COULD ACCESS THEM EASILY
    
    `include "axi_transaction.sv"
    `include "axi_sequencer.sv"
    `include "axi_driver.sv"
    `include "axi_monitor.sv"
    `include "axi_agent.sv"
    `include "axi_subscriber.sv"
    `include "axi_env.sv"
    `include "axi_sequence.sv"

endpackage 