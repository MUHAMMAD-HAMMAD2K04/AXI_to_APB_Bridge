# APB UVC (Universal Verification Component)

## Overview

The APB UVC is a reusable UVM-based Verification Component developed to verify the APB interface of an AXI-to-APB Bridge. It emulates APB slave behavior, monitors APB transactions, and provides reusable protocol verification components for APB-based peripherals.

The UVC follows the standard UVM architecture and is designed for easy integration into larger verification environments.

---

## Features

- UVM compliant architecture
- Reusable APB Verification Component
- APB Read support
- APB Write support
- Active and Passive Agent modes
- Virtual Interface based communication
- Analysis Port for transaction broadcasting
- Transaction-level modeling using UVM TLM
- Configurable using `uvm_config_db`

---

## UVC Architecture

```
             Test
              │
         APB Sequence
              │
        APB Sequencer
              │
         APB Driver
              │
        APB Interface
              │
             DUT
              │
        APB Monitor
              │
        Analysis Port
```

---

## Components

### APB Interface

Defines the APB bus signals and provides the communication layer between the DUT and the UVM environment using virtual interfaces.

---

### APB Transaction

Represents an APB transfer including:

- Address
- Write Data
- Read Data
- Write Control
- Byte Strobes
- Ready Signal

---

### APB Sequencer

Supplies APB transaction objects to the driver.

---

### APB Driver

Implements the APB protocol handshake and drives slave responses based on sequence items.

Supports:

- Read Transfers
- Write Transfers
- Ready Signal Generation

---

### APB Monitor

Passively monitors APB bus activity and reconstructs protocol transactions.

Observed transactions are published through an Analysis Port for scoreboards, subscribers, and functional coverage.

---

### APB Agent

Integrates:

- Driver
- Sequencer
- Monitor

Supports configurable Active and Passive modes.

---

### APB Environment

Top-level verification container responsible for instantiating and configuring the APB Agent.

---

## Current Status

✔ APB Interface

✔ APB Transaction

✔ APB Driver

✔ APB Monitor

✔ APB Sequencer

✔ APB Agent

✔ APB Environment

✔ APB Sequences

✔ Successfully Validated Read Transactions

✔ Integrated with AXI-to-APB Bridge

---

## Planned Improvements

- Scoreboard Integration
- Functional Coverage
- Wait-State Injection
- Error Injection (PSLVERR)
- Randomized Regression Tests
- Protocol Assertions

---

## Applications

The APB UVC can be reused for verifying:

- APB Slaves
- APB Peripherals
- APB Bridges
- Control Register Interfaces
- Embedded SoCs
- AMBA-based Designs

---

## License

Developed for educational and research purposes.