`include "uvm_macros.svh"
import uvm_pkg::*;

import apb_pkg::*;
import axi_pkg::*;

class bridge_cross_coverage extends uvm_component;
    `uvm_component_utils(bridge_cross_coverage)

    uvm_tlm_analysis_fifo #(axi_transaction) axi_fifo;
    uvm_tlm_analysis_fifo #(axi_to_apb_packet) apb_fifo;

    uvm_get_port #(axi_transaction) axi_get_port;
    uvm_get_port #(axi_to_apb_packet) apb_get_port;

    axi_transaction axi_tr;
    axi_to_apb_packet apb_pkt;

    //Covergroup
    covergroup cg_axi_apb_cross;
        axi_write_cp: coverpoint axi_tr.write {
            bins write = {1};
            bins read  = {0};
        }
        axi_addr_cp: coverpoint axi_tr.addr {
            bins low    = {[0:32'h3FFF]};
            bins mid    = {[32'h4000:32'h7FFF]};
            bins high   = {[32'h8000:32'hBFFF]};
            bins top    = {[32'hC000:32'hFFFF]};
        }
        axi_strb_cp: coverpoint axi_tr.strb {
            bins single[] = {4'b0001, 4'b0010, 4'b0100, 4'b1000};
            bins two[]   = {4'b0011, 4'b1100, 4'b0101, 4'b1010};
            bins all     = {4'b1111};
        }
        axi_data_cp: coverpoint axi_tr.data {
            bins low    = {[32'h0000_0000 : 32'h0000_3FFF]};
            bins mid    = {[32'h0000_4000 : 32'h0000_7FFF]};
            bins high   = {[32'h0000_8000 : 32'h0000_BFFF]};
            bins top    = {[32'h0000_C000 : 32'h0000_FFFF]};
            bins others = default;
        }
        apb_write_cp: coverpoint apb_pkt.write {
            bins write = {1};
            bins read  = {0};
        }
        apb_addr_cp: coverpoint apb_pkt.addr {
            bins low    = {[0:32'h3FFF]};
            bins mid    = {[32'h4000:32'h7FFF]};
            bins high   = {[32'h8000:32'hBFFF]};
            bins top    = {[32'hC000:32'hFFFF]};
        }
        apb_strb_cp: coverpoint apb_pkt.strb {
            bins single[] = {4'b0001, 4'b0010, 4'b0100, 4'b1000};
            bins two[]   = {4'b0011, 4'b1100, 4'b0101, 4'b1010};
            bins all     = {4'b1111};
        }
        apb_rdata_cp: coverpoint apb_pkt.rdata {
            bins low    = {[32'h0000_0000 : 32'h0000_3FFF]};
            bins mid    = {[32'h0000_4000 : 32'h0000_7FFF]};
            bins high   = {[32'h0000_8000 : 32'h0000_BFFF]};
            bins top    = {[32'h0000_C000 : 32'h0000_FFFF]};
            bins others = default;
        }

        // Cross coverage
        cross axi_addr_cp, apb_addr_cp;
        cross axi_data_cp, apb_rdata_cp;
        cross axi_addr_cp, apb_rdata_cp;
        cross apb_addr_cp, axi_data_cp;
    endgroup

    function new(string name = "bridge_cross_coverage", uvm_component parent);
        super.new(name, parent);
        axi_fifo = new("axi_fifo", this);
        apb_fifo = new("apb_fifo", this);
        axi_get_port = new("axi_get_port", this);
        apb_get_port = new("apb_get_port", this);
        cg_axi_apb_cross = new();
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        axi_get_port.connect(axi_fifo.get_peek_export);
        apb_get_port.connect(apb_fifo.get_peek_export);
    endfunction

    task run_phase(uvm_phase phase);
        forever begin
            axi_fifo.get(axi_tr);
            apb_fifo.get(apb_pkt);
            cg_axi_apb_cross.sample();
        end
    endtask
endclass