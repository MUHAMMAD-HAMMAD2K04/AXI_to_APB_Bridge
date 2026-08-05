// File: axi_coverage.sv
class axi_coverage extends uvm_subscriber #(axi_transaction);
    `uvm_component_utils(axi_coverage)

    axi_transaction tr;

    covergroup cg_axi_transaction;
        type_cp: coverpoint tr.write {
            bins write = {1};
            bins read  = {0};
        }

        addr_cp: coverpoint tr.addr {
            bins low    = {[32'h0000_0000 : 32'h0000_3FFF]};
            bins mid    = {[32'h0000_4000 : 32'h0000_7FFF]};
            bins high   = {[32'h0000_8000 : 32'h0000_BFFF]};
            bins top    = {[32'h0000_C000 : 32'h0000_FFFF]};
            bins others = default;
        }

        strb_cp: coverpoint tr.strb {
            bins single_byte[] = {4'b0001, 4'b0010, 4'b0100, 4'b1000};
            bins two_bytes[]   = {4'b0011, 4'b1100, 4'b0101, 4'b1010};
            bins three_bytes   = {4'b0111, 4'b1011, 4'b1101, 4'b1110};
            bins all_bytes     = {4'b1111};
            bins zero          = {4'b0000};
        }

        data_cp: coverpoint tr.data {
            bins low    = {[32'h0000_0000 : 32'h0000_3FFF]};
            bins mid    = {[32'h0000_4000 : 32'h0000_7FFF]};
            bins high   = {[32'h0000_8000 : 32'h0000_BFFF]};
            bins top    = {[32'h0000_C000 : 32'h0000_FFFF]};
            bins others = default;
        }

        cross type_cp, addr_cp;

        cross type_cp, strb_cp {
            bins write_strb = binsof(type_cp.write) && binsof(strb_cp);
            ignore_bins read_strb = binsof(type_cp.read);
        }

        cross addr_cp, data_cp;

        cross type_cp, data_cp;
    endgroup

    function new(string name = "axi_coverage", uvm_component parent);
        super.new(name, parent);
        cg_axi_transaction = new();
    endfunction

    virtual function void write(axi_transaction t);
        tr = t;
        cg_axi_transaction.sample();
    endfunction
endclass