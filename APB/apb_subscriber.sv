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
            bins reg0    = {32'h0000_0000};
            bins reg1    = {[32'h0000_0004 : 32'h0000_000C]};
            bins reg2    = {[32'h0000_0010 : 32'h0000_001C]};
            bins others  = default;
        }

        strb_cp: coverpoint pkt.strb {
            bins single_byte[] = {4'b0001, 4'b0010, 4'b0100, 4'b1000};
            bins two_bytes[]   = {4'b0011, 4'b1100, 4'b0101, 4'b1010};
            bins three_bytes   = {4'b0111, 4'b1011, 4'b1101, 4'b1110};
            bins all_bytes     = {4'b1111};
            bins zero          = {4'b0000};  // Only valid for reads
        }

        ready_cp: coverpoint pkt.ready {
            bins ready_0 = {0};  // Wait state
            bins ready_1 = {1};  // No wait state
        }

        rdata_cp: coverpoint pkt.rdata {
            bins zero      = {32'h0000_0000};
            bins all_ones  = {32'hFFFF_FFFF};
            bins patterns  = {32'hDEAD_BEEF, 32'hCAFE_BABE, 32'hA5A5_A5A5};
            bins others    = default;
        }

        wdata_cp: coverpoint pkt.wdata {
            bins zero      = {32'h0000_0000};
            bins all_ones  = {32'hFFFF_FFFF};
            bins patterns  = {32'hDEAD_BEEF, 32'hCAFE_BABE, 32'hA5A5_A5A5};
            bins others    = default;
        }

        cross type_cp, addr_cp;

        cross type_cp, strb_cp {
            bins write_strb = binsof(type_cp.write) && binsof(strb_cp);
            ignore_bins read_strb = binsof(type_cp.read);
        }

        cross type_cp, ready_cp;

        cross addr_cp, ready_cp;
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