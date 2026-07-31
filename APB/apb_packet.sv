class axi_to_apb_packet extends uvm_sequence_item;

    localparam int ADDR_WIDTH = 32;
    localparam int DATA_WIDTH = 32;
    localparam int STRB_WIDTH = DATA_WIDTH / 8;

    rand bit                  write;             // 1 = Write, 0 = Read
    rand bit [ADDR_WIDTH-1:0] addr;
    rand bit [DATA_WIDTH-1:0] wdata;            // Valid only for writes
    rand bit [STRB_WIDTH-1:0] strb;            // Byte strobes (write mask)

    bit                  ready;          // PREADY (0 = wait state, 1 = complete)
    bit [DATA_WIDTH-1:0] rdata;         // Valid only for reads

    `uvm_object_utils_begin(axi_to_apb_packet)
        `uvm_field_int(write, UVM_ALL_ON)
        `uvm_field_int(addr,  UVM_ALL_ON)
        `uvm_field_int(wdata, UVM_ALL_ON)
        `uvm_field_int(strb,  UVM_ALL_ON)
        `uvm_field_int(ready, UVM_ALL_ON)
        `uvm_field_int(rdata, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "axi_to_apb_packet");
        super.new(name);
    endfunction

    constraint c_addr_range {
        addr inside { [0:2**ADDR_WIDTH-1] };
    }

    constraint c_strb_valid {
        write -> (strb != 0);
    }

    constraint c_strb_zero_for_read {
        !write -> (strb == 0);
    }

    function string convert2string();
        string s;
        s = super.convert2string();
        s = {s, $sformatf("\n  APB Packet:"),
             $sformatf("\n    Type   : %s", write ? "WRITE" : "READ"),
             $sformatf("\n    Addr   : 0x%0h", addr),
             $sformatf("\n    Wdata  : 0x%0h", wdata),
             $sformatf("\n    Strb   : 0x%0h", strb),
             $sformatf("\n    Ready  : %0d", ready),
             $sformatf("\n    Rdata  : 0x%0h", rdata)};
        return s;
    endfunction

    function bit is_write();
        return write;
    endfunction

    function bit is_read();
        return !write;
    endfunction
endclass : axi_to_apb_packet
