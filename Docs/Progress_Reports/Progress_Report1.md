# APB UVM Testbench - Progress Report

Date: July 28, 2026

Author: Syed Zain ul Aabideen

## 1. Overview

This document provides a status update on the development of the UVM-based verification environment for the APB (Advanced Peripheral Bus) protocol. The environment is built to be reusable and configurable, allowing for both active (stimulus generation) and passive (monitoring only) operation modes.

## 2. Completed Work

The foundational structure of the UVM environment has been successfully implemented. This includes the core components required to build and connect a testbench.

### 2.1. Core Components

1. `apb_pkg.sv`: A SystemVerilog package acting as the central container for all UVM components, sequences, and data objects. It imports the UVM library and includes all necessary files.
2. `apb_if.sv`: The APB virtual interface has been defined. This interface acts as the primary connection between the DUT and the testbench.
3. Signals: All standard APB control and data signals (`PTRANSFER`, `PWRITE`, `PADDR`, `PWDATA`, `PSTRB`, `PREADY`, `PRDATA`) are included.
4. Clocking: A `slave_cb` clocking block is defined to manage synchronous signal drives and samples.
5. Modport: A `slave_mp` modport is provided for the driver to drive specific signals and the monitor to sample others.

### 2.2. UVM Environment Structure

1. `apb_sequencer.sv`: The sequencer has been defined. It is parameterized to generate `apb_packet` type sequence items, which will be sent to the driver.
2. `apb_agent.sv`: The agent class has been implemented with full UVM compliance.
3. Functionality: It instantiates and connects the `apb_sequencer`, `apb_driver`, and `apb_monitor`.
4. Configuration: The agent is configurable via the standard UVM `is_active` field. Based on this setting, it conditionally builds the driver and sequencer, allowing for active or passive mode operation.
5. Connection: The TLM port between the driver and sequencer (`seq_item_port` to `seq_item_export`) is correctly connected in the `connect_phase`.
6. `apb_env.sv`: The top-level environment has been created. Its current role is to instantiate the APB agent.

## 3. Pending Tasks & Next Steps

The environment is a work in progress. The following tasks are identified as the immediate next priorities for the verification IP to become operational.

### 3.1. High Priority

1.  Implement `apb_packet.sv`:
    - Define the transaction object. This class must include fields for all APB signals (`ADDR`, `DATA`, `WRITE`, etc.) and standard UVM macros (``uvm_object_utils`, `do_compare`, `do_print`, `do_copy`).

2.  Implement `apb_monitor.sv`:
    - Create the monitor class responsible for observing the APB interface (`slave_mp` modport).
    - Implement the behavior to sample signals and create `apb_packet` objects.
    - The monitor should use an analysis port to broadcast captured transactions to the scoreboard or other subscribers.

3.  Implement `apb_driver.sv`:
    - Create the driver class responsible for accepting `apb_packet` items from the sequencer.
    - Map the packet's fields to the virtual interface signals using the defined clocking block.
    - Implement the protocol handshake to drive transfers correctly.

### 3.2. Medium Priority

1.  Implement `apb_seqs.sv`:
    - Define a base sequence class for APB transactions.
    - Create a basic sequence for simple read/write operations. This will be the minimum starting point for testing.

2.  `apb_resp.sv`:
    - Create a response class to represent the DUT's response to a transaction.

3.  Environment Connectivity:
    - Add logic to `apb_env` to retrieve the virtual interface from the UVM configuration database (`uvm_config_db`) and pass it down to the agent and its components.

## 4. Summary

The foundation of the APB UVM environment is in place, providing a solid and configurable agent structure. The immediate priority is the implementation of the core active components: the transaction packet, the driver, and the monitor. Once these are complete, the testbench will be capable of generating and capturing traffic, paving the way for the development of sequences and test cases.

