class axi_transaction extends uvm_sequence_item;

    // AXI Transaction Type
    rand bit write;
    
    // Address Channel
    rand bit [31:0] addr;

    // Write Data Channel
    rand bit [31:0] data;
    rand bit [3:0] strb;

    // Response Channel
    bit [1:0] resp;

    // Read/Write Identification
    bit read;

    // Factory Registration
    `uvm_object_utils_begin(axi_transaction)
        `uvm_field_int(write, UVM_ALL_ON)
        `uvm_field_int(addr, UVM_ALL_ON)
        `uvm_field_int(data, UVM_ALL_ON)
        `uvm_field_int(strb, UVM_ALL_ON)
        `uvm_field_int(resp, UVM_ALL_ON)
    `uvm_object_utils_end

    // Constructor
    function new(string name="axi_transaction");
        super.new(name);
    endfunction

    // Constraints
    constraint addr_align_c { addr % 4 == 0; }

    constraint addr_range {addr inside {[32'h0000_0000 : 32'h0000_3FFF], 
                                   [32'h0000_4000 : 32'h0000_7FFF], 
                                   [32'h0000_8000 : 32'h0000_BFFF],
                                   [32'h0000_C000 : 32'h0000_FFFF]}; }

    constraint data_range {data inside {[32'h0000_0000 : 32'h0000_3FFF], 
                                   [32'h0000_4000 : 32'h0000_7FFF], 
                                   [32'h0000_8000 : 32'h0000_BFFF],
                                   [32'h0000_C000 : 32'h0000_FFFF]}; }

    // Display Transaction
    function void do_print(uvm_printer printer);
        super.do_print(printer);

        printer.print_field("WRITE",write,1,UVM_BIN);

        printer.print_field("ADDR",addr,32,UVM_HEX);

        printer.print_field("DATA",data,32,UVM_HEX);

        printer.print_field("STRB",strb,4,UVM_BIN);

        printer.print_field("RESP",resp,2,UVM_BIN);

    endfunction


endclass