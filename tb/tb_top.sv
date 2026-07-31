module top;
    import uvm_pkg::*;    
    `include "uvm_macros.svh"

    import apb_pkg::*;
    import axi_pkg::*;
    `include "bridge_tb.sv"
    `include "bridge_test_lib.sv"

    hw_top hwtop(.*);

    initial begin
        apb_mon_vif_config::set(null, "*.tb.APB_env.agent.monitor","vif", hwtop.apb);
        apb_drv_vif_config::set(null, "*.tb.APB_env.agent.driver","vif", hwtop.apb);
        axi_vif_config::set(null, "*.tb.AXI_env.agent.*","vif", hwtop.axi_if_inst);
        run_test();
    end
endmodule : top