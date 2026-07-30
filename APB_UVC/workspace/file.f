// 64 bit option for AWS labs
-64

-uvmhome /home/cc/mnt/XCELIUM2309/tools/methodology/UVM/CDNS-1.1d

// Include directories 
-incdir ../APB
-incdir ../DUT  
-incdir ../tb  

// Compile files
../APB/apb_pkg.sv
../APB/apb_if.sv

../DUT/Bridge_CP.sv
../DUT/Bridge_DP.sv
../DUT/Bridge_Complete.sv

../tb/hw_top.sv
../tb/tb_top.sv

+UVM_TESTNAME=base_test
+UVM_VERBOSITY=UVM_MEDIUM
+SVSEED=random