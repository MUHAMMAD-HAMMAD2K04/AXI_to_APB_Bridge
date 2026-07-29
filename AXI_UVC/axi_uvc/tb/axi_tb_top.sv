
`timescale 1ns/1ps

`include "uvm_macros.svh"

import uvm_pkg::*;
import axi_pkg::*;

// `include "axi_tb.sv"
// `include "axi_test_lib.sv"

module tb_top;

     
    // Instantiate Hardware Top
    
    hw_top hw();

     
    // Configure UVM
     

    initial begin

        uvm_config_db#(virtual axi_if)::set(
            null,
            "*",
            "vif",
            hw.axi_if_inst
        );

        run_test();

    end

endmodule