// File: apb_coverage.sv
class apb_coverage extends uvm_subscriber #(axi_to_apb_packet);
    `uvm_component_utils(apb_coverage)

    axi_to_apb_packet pkt;

    covergroup cg_apb_transaction;
        type_cp: coverpoint pkt.write {
            bins write = {1};
            bins read  = {0};
        }

        addr_cp: coverpoint pkt.addr {
            bins low    = {[0:32'h3FFF]};
            bins mid    = {[32'h4000:32'h7FFF]};
            bins high   = {[32'h8000:32'hBFFF]};
            bins top    = {[32'hC000:32'hFFFF]};
        }

        strb_cp: coverpoint pkt.strb {
            bins single_byte[] = {4'b0001, 4'b0010, 4'b0100, 4'b1000};
            bins two_bytes[]   = {4'b0011, 4'b1100, 4'b0101, 4'b1010};
            bins three_bytes   = {4'b0111, 4'b1011, 4'b1101, 4'b1110};
            bins all_bytes     = {4'b1111};
            bins zero          = {4'b0000};  // Only valid for reads
        }

        ready_cp: coverpoint pkt.ready {
            bins ready_1 = {1};  // No wait state
        }

        rdata_cp: coverpoint pkt.rdata {
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

        cross addr_cp, rdata_cp;
    endgroup

    function new(string name = "apb_coverage", uvm_component parent);
        super.new(name, parent);
        cg_apb_transaction = new();
    endfunction

    virtual function void write(axi_to_apb_packet t);
        pkt = t;
        cg_apb_transaction.sample();
    endfunction
endclass