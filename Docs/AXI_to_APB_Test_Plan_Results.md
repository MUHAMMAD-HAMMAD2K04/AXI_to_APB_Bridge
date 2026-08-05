# AXI-to-APB Bridge Verification Test Plan and Results

## 1. Verification Objective

This test plan verifies correct conversion of FIFO-based AXI-side requests into APB transfers. It covers directed operation, readback integrity, FIFO flow control, reset recovery, address handling, randomized traffic, and APB wait states.

The DUT source was not modified as part of testbench development or regression execution.

## 2. Test Environment

| Item | Value |
|---|---|
| Verification methodology | UVM 1.1d |
| Simulator | Cadence Xcelium 23.09 |
| AXI-side model | Request, write-data, and read-data FIFO interface |
| APB-side model | APB slave driver and monitor |
| Checking | AXI-to-APB and APB-to-AXI reference-model comparisons |
| Transaction reporting | AXI driver, AXI monitor, APB driver, APB monitor |
| Regression test | `axi_regression_test` |
| Regression sequence | `axi_regression_seq` |
| Regression log | `workspace/expanded_regression.log` |

## 3. Required Test Plan Results

| ID | Test | Objective | Sequence | UVM test class | Type | Transactions | Result |
|---:|---|---|---|---|---|---:|---|
| 1 | Reset Test | Verify reset and default initialization | `reset_seq` | `reset_seq_test` | Directed | 1 | PASS |
| 2 | Read Test | Verify a single AXI read operation | `axi_read_seq` | `axi_read_seq_test` | Directed | 1 | PASS |
| 3 | Write Test | Verify a single AXI write operation | `axi_write_seq` | `axi_write_seq_test` | Directed | 1 | PASS |
| 4 | Read-After-Write Test | Write known data and read it from the same address | `axi_read_after_write_seq` | `axi_read_after_write_seq_test` | Directed | 2 | PASS |
| 5 | FIFO Full Test | Hold the read-data FIFO full, verify no write occurs while full, release it, and complete the read | `axi_fifo_full_seq` | `axi_fifo_full_seq_test` | Directed | 2 | PASS |
| 6 | FIFO Empty Test | Hold the request FIFO empty and verify the DUT does not read it until a request becomes available | `axi_fifo_empty_seq` | `axi_fifo_empty_seq_test` | Directed | 1 | PASS |
| 7 | Multiple Write Test | Verify five consecutive write transactions | `axi_five_write_seq` | `axi_multiple_write_seq_test` | Directed | 5 | PASS |
| 8 | Random Read/Write Test | Verify randomized read and write traffic over valid addresses | `axi_random_read_write_seq` | `axi_random_read_write_seq_test` | Randomized | 20 | PASS |
| 9 | Multiple Read Test | Verify five consecutive read transactions | `axi_five_read_seq` | `axi_multiple_read_seq_test` | Directed | 5 | PASS |
| 10 | Invalid Address Test | Exercise write and read transfers outside the normal valid-address constraint | `axi_invalid_address_seq` | `axi_invalid_address_seq_test` | Directed | 2 | PASS |
| 11 | Reset During Transaction Test | Assert reset after request acceptance, recover, retry, and verify readback | `axi_reset_during_transaction_seq` | `axi_reset_during_transaction_seq_test` | Directed | 2 | PASS |
| 12 | Random Address Test | Exercise 25 randomized, aligned addresses within the valid address range | `axi_random_address_seq` | `axi_random_address_seq_test` | Randomized | 25 | PASS |
| 13 | Random FIFO Stress Test | Apply randomized request-empty and read-FIFO-full delays with checked write/readback pairs | `axi_random_fifo_stress_seq` | `axi_random_fifo_stress_seq_test` | Randomized | 200 | PASS |
| 14 | Random Wait-State Test | Exercise randomized read/write traffic while the APB slave inserts randomized `PREADY` delays | `axi_random_wait_state_seq` | `axi_random_wait_state_seq_test` | Randomized | 20 | PASS |
|  | **Required regression total** |  |  |  |  | **287** | **PASS** |

## 4. Regression Summary

The complete 14-test regression produced the following final scoreboard result:

```text
AXI->APB Compared : 287
AXI->APB PASS     : 287
AXI->APB FAIL     : 0

APB->AXI Compared : 287
APB->AXI PASS     : 287
APB->AXI FAIL     : 0

UVM_WARNING : 0
UVM_ERROR   : 0
UVM_FATAL   : 0
```

Overall required-test result: **PASS**.

## 5. Supplemental Sequence Results

These sequences remain available in addition to the required 14-test plan.

| Sequence/test | Purpose | Transactions | Result | Evidence |
|---|---|---:|---|---|
| `axi_multiple_write_read_seq` / `axi_multiple_write_read_seq_test` | Perform five writes, retain their address/data pairs, then read and self-check all five locations | 10 | PASS | `workspace/axi_multiple_write_read_seq_test.log` |
| `axi_stress_seq` / `stress_test` | Perform 500 randomized write/readback pairs using the same address and self-check every returned value | 1000 | PASS | `workspace/stress_test.log` |
| `axi_wait_state_seq` / `wait_state_test` | Generate ten transfers with a configured APB wait-state delay | 10 | Covered by directed test library | Available as an individual test |

Supplemental verified scoreboard results:

```text
axi_multiple_write_read_seq_test
  AXI->APB : 10/10 PASS
  APB->AXI : 10/10 PASS
  Warnings/Errors/Fatals: 0/0/0

stress_test
  AXI->APB : 1000/1000 PASS
  APB->AXI : 1000/1000 PASS
  Warnings/Errors/Fatals: 0/0/0
```

## 6. Pass/Fail Criteria

A test is marked PASS when all of the following conditions are satisfied:

1. The intended sequence reaches completion.
2. All expected AXI and APB transactions are observed.
3. AXI-to-APB and APB-to-AXI scoreboard comparisons pass.
4. Directed readback checks return the data written to the same address.
5. FIFO control assertions report no illegal read or write operation.
6. The UVM report contains zero warnings, errors, and fatals.

## 7. Notes and Limitations

- Invalid-address traffic is transported and checked, but the current DUT interface has no explicit APB `PSLVERR` or AXI error-response output. Therefore, this test verifies transaction handling rather than an error response code.
- Functional and code coverage percentages should be attached separately if required for formal verification closure.
- Result screenshots are available in `/home/cc/Downloads/Final_Project/Project_Pictures`.

## 8. Final Status

All required directed and randomized scenarios completed successfully. The current implementation satisfies the defined functional verification test plan with **287/287** regression comparisons passing in both bridge directions and no UVM warnings, errors, or fatal reports.
