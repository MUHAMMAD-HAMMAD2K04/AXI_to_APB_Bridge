-64
-sv

-uvmhome /home/cc/mnt/XCELIUM2309/tools/methodology/UVM/CDNS-1.1d

-timescale 1ns/1ns

-incdir /home/cc/Documents/AXI_to_APB_Bridge/axi_uvc/sv
-incdir /home/cc/Documents/AXI_to_APB_Bridge/APB
-incdir /home/cc/Documents/AXI_to_APB_Bridge/DUT
-incdir /home/cc/Documents/AXI_to_APB_Bridge/tb


/home/cc/Documents/AXI_to_APB_Bridge/axi_uvc/sv/axi_if.sv
/home/cc/Documents/AXI_to_APB_Bridge/axi_uvc/sv/axi_pkg.sv

/home/cc/Documents/AXI_to_APB_Bridge/APB/apb_if.sv
/home/cc/Documents/AXI_to_APB_Bridge/APB/apb_pkg.sv

/home/cc/Documents/AXI_to_APB_Bridge/tb/hw_top.sv
/home/cc/Documents/AXI_to_APB_Bridge/tb/tb_top.sv

/home/cc/Documents/AXI_to_APB_Bridge/DUT/Bridge_CP.sv
/home/cc/Documents/AXI_to_APB_Bridge/DUT/Bridge_DP.sv
/home/cc/Documents/AXI_to_APB_Bridge/DUT/Bridge_Complete.sv

// -access
// +rwc
// -gui

+UVM_TESTNAME=axi_single_write_seq_test
+UVM_VERBOSITY=UVM_FULL