module top;
    import uvm_pkg::*;    
    `include "uvm_macros.svh"

    import apb_pkg::*;
    `include "bridge_tb.sv"
    `include "bridge_test_lib.sv"

    hw_top hwtop(.*);

    initial begin
        apb_mon_vif_config::set(null, "*.tb.APB_env.agent.monitor","vif", hwtop.apb);
        apb_drv_vif_config::set(null, "*.tb.APB_env.agent.driver","vif", hwtop.apb);
        run_test();
    end
endmodule : top