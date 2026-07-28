# AXI_to_APB_Bridge

Create an AXI Master UVC to bridge the AXI with APB slave UVC though their interfaces and verify it compltely with UVM environment

## Understanding the functionality of AXI

AXI contains 5 channels :

1. Write    Address  (input)
2. Read     Address  (input)
3. Write    Data     (input)
4. Read     Data     (output)
5. Write    Response (output)  