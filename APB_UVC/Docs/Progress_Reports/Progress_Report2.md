# APB UVM Testbench - Progress Report #2

Date: July 29, 2026  
Author: Syed Zain ul Aabideen  
Status: Active – UVC complete, simulation passing.

1. Overview

This report summarises the progress made since the initial testbench skeleton (Report #1). The APB UVC (Universal Verification Component) has been fully implemented and validated against the `Bridge_Complete` DUT. All components are functional and integrated, and the simulation runs without errors, successfully completing multiple APB read transactions.

2. Completed Work (Phase 2)

2.1. Core Components – Enhanced and Completed
2.1.1. APB Interface (`apb_if.sv`)
1. Full set of APB signals (`PTRANSFER`, `PWRITE`, `PADDR`, `PWDATA`, `PSTRB`, `PREADY`, `PRDATA`) is declared.
2. Two modports are defined:
  2.1 `driver_mp`: Driver observes DUT outputs (`PTRANSFER`, `PWRITE`, `PADDR`, `PWDATA`, `PSTRB`) and drives slave responses (`PRDATA`, `PREADY`).
  2.2`monitor_mp`: Monitor observes all signals passively.
3. `clk` and `rst` are included in both modports, enabling reset handling.
4. The interface is correctly connected to the DUT in the testbench top.

2.1.2. APB Transaction Packet (`axi_to_apb_packet.sv`)
1. Extended from `uvm_sequence_item`.
2. Fields: `addr`, `write` flag, `wdata`, `strb`, `rdata`, `ready`.
3. Standard UVM macros (`uvm_object_utils`, `do_copy`, `convert2string`) are implemented.
4. Used both by the sequencer (to generate items) and the monitor (to capture bus activity).

2.2. Fully Functional APB Driver (`apb_driver.sv`)
1. Protocol Handshake: Detects transfers using `PTRANSFER` and `PWRITE`.
  1.1 Reads: Calls `seq_item_port.get_next_item()` to obtain a response packet, drives `PRDATA` and `PREADY` high, then releases the bus.
  1.2 Writes: Acknowledges with `PREADY=1` without sequencer interaction (as per APB specification).
2. Reset Handling: Checks reset inside the main loop; drives idle values (`PRDATA=0`, `PREADY=0`) while reset is active.
3. Logging: Extensive `uvm_info` messages trace transfer start, branch selection, and completion.
4. Validation: Successfully completed 5 read transactions in simulation.

2.3. Fully Passive APB Monitor (`apb_monitor.sv`)
1. Sampling: Uses `@(posedge vif.clk)` to avoid race conditions.
  1.1 Captures SETUP phase data (`PADDR`, `PWRITE`, `PWDATA`, `PSTRB`) when `PTRANSFER` is asserted.
  1.2 Waits for ACCESS phase to capture `PRDATA` and `PREADY`.
2. Transaction Reconstruction: Creates `axi_to_apb_packet` objects from sampled signals.
3. Analysis Port: Declared (`uvm_analysis_port #(axi_to_apb_packet) ap`) and connected. The monitor writes each captured packet to this port.
4. Counters: Tracks number of collected packets and reports them in `report_phase`.
5. Validation: The monitor correctly captured all 5 read transactions with matching `rdata` and `ready=1` values.

2.4. APB Sequencer (`apb_sequencer.sv`)
1. Parameterised for `axi_to_apb_packet`.
2. Used by the driver to obtain response items.

2.5. APB Agent (`apb_agent.sv`)
1. Instantiates the driver, monitor, and sequencer.
2. Supports `is_active` configuration (active/passive mode) to conditionally build the driver and sequencer.
3. Connects the driver’s `seq_item_port` to the sequencer’s `seq_item_export` in `connect_phase`.

2.6. APB Environment (`apb_env.sv`)
1. Instantiates the agent, providing a top‑level container for the verification environment.

2.7. APB Sequences (`apb_seqs.sv`)
1. Base sequence class and a concrete sequence `apb_5_packets` are implemented.
2. `apb_5_packets` generates 5 random `axi_to_apb_packet` items and sends them to the driver via the sequencer.
3. Proper objection handling: raises an objection at the start and drops it after the last item is sent.

2.8. Hardware Top (`hw_top.sv`)
1. Clock and reset generation (active‑low reset).
2. Instantiates the `Bridge_Complete` DUT and connects the APB interface.
3. A simple `force` block drives `req_fifo_empty=0` and `req_fifo_rd_data=33'd0` (read address 0x0) to trigger APB transfers. This stimulus will later be replaced by a full AXI UVC.

2.9. Testbench Top (`tb_top.sv`)
1. Configures the virtual interface for both driver and monitor via `uvm_config_db`.
2. Calls `run_test()` to start the UVM test.

2.10. Test Classes (`bridge_test_lib.sv`)
1. `base_test`: Sets the default sequence (`apb_5_packets`) using `uvm_config_wrapper` and prints the UVM topology.
2. `set_config_test`: Demonstrates passive mode configuration.

2.11. Simulation Results
1. The testbench successfully executed 5 APB read transactions.
2. All transactions completed:
  2.1 The driver received sequencer items and drove valid `PRDATA` and `PREADY`.
  2.2 The monitor captured all 5 transactions with correct data and `ready=1`.
3.No deadlocks, compilation errors, or simulation hangs occurred.
4. The monitor reported collection of 5 packets in its `report_phase`.

3. Pending Tasks & Next Steps

3.1. High Priority
1. Scoreboard Implementation  
   1.1 Connect the monitor’s analysis port to a scoreboard.
   1.2 The scoreboard will compare captured APB transactions against expected values from the sequencer or a reference model.

2. AXI UVC Integration  
   2.1 Replace the hardcoded `force` stimulus with a proper AXI driver/monitor.
   2.2 The AXI UVC will drive the FIFO signals (`req_fifo_empty`, `req_fifo_rd_data`, etc.) and handle full AXI protocol handshaking.

3.2. Medium Priority
3. Full Regression & Coverage 
   3.1 Add write transactions and mixed read/write scenarios.
   3.2 Implement functional coverage for address ranges, strobes, and error conditions.

4. Error Injection
   4.1 Extend the driver to support wait states (`PREADY=0`) and test the DUT’s response under various timing conditions.

4. Summary

The APB UVC is now complete and validated against the `Bridge_Complete` DUT. All components, interface, packet, driver, monitor, sequencer, agent, environment, and test sequences – are fully functional. The testbench is capable of generating APB traffic (via sequencer/driver) and capturing APB transactions (via monitor) simultaneously. The simulation has proven that the driver and monitor work correctly together on a real DUT.

The environment is ready for the next phase: building a scoreboard and integrating a full AXI UVC to enable comprehensive end‑to‑end verification of the bridge.