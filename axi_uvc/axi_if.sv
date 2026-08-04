import uvm_pkg::*;
`include "uvm_macros.svh"

interface axi_if #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
)(
    input logic PCLK,
    input logic PRESET
);

    localparam STRB_WIDTH = DATA_WIDTH/8;

    // Request FIFO
    logic                        req_fifo_empty;
    logic [ADDR_WIDTH:0]         req_fifo_rd_data;
    logic                        req_fifo_rd_en;

    // Write FIFO
    logic                        wr_fifo_empty;
    logic [DATA_WIDTH+STRB_WIDTH-1:0] wr_fifo_rd_data;
    logic                        wr_fifo_rd_en;

    // Read FIFO
    logic                        rd_fifo_full;
    logic                        rd_fifo_wr_en;
    logic [DATA_WIDTH-1:0]       rd_fifo_wr_data;

    // Clocking Block for Driver
    clocking drv_cb @(posedge PCLK);
        default input #1step output #1ns;

        output req_fifo_empty;
        output req_fifo_rd_data;

        output wr_fifo_empty;
        output wr_fifo_rd_data;

        output rd_fifo_full;

        input req_fifo_rd_en;
        input wr_fifo_rd_en;
        input rd_fifo_wr_en;
        input rd_fifo_wr_data;
    endclocking

    // Clocking Block for Monitor
    clocking mon_cb @(posedge PCLK);
        default input #1step;

        input req_fifo_empty;
        input req_fifo_rd_data;
        input req_fifo_rd_en;

        input wr_fifo_empty;
        input wr_fifo_rd_data;
        input wr_fifo_rd_en;

        input rd_fifo_full;
        input rd_fifo_wr_en;
        input rd_fifo_wr_data;
    endclocking

    modport DRIVER(
        clocking drv_cb,
        input PCLK,
        input PRESET
    );

    modport MONITOR(
        clocking mon_cb,
        input PCLK,
        input PRESET
    );

    // Use the main clock PCLK for assertions
    property p_axi_req_rd_en_valid;
        @(posedge PCLK) disable iff (!PRESET)
        req_fifo_rd_en |-> !req_fifo_empty;
    endproperty
    assert property (p_axi_req_rd_en_valid)
    else `uvm_error("AXI_IF", "req_fifo_rd_en asserted while FIFO empty");

    property p_axi_wr_rd_en_valid;
        @(posedge PCLK) disable iff (!PRESET)
        wr_fifo_rd_en |-> !wr_fifo_empty;
    endproperty
    assert property (p_axi_wr_rd_en_valid)
    else `uvm_error("AXI_IF", "wr_fifo_rd_en asserted while FIFO empty");

    property p_axi_rd_wr_en_valid;
        @(posedge PCLK) disable iff (!PRESET)
        rd_fifo_wr_en |-> !rd_fifo_full;
    endproperty
    assert property (p_axi_rd_wr_en_valid)
    else `uvm_error("AXI_IF", "rd_fifo_wr_en asserted while FIFO full");

    property p_axi_req_data_stable;
        @(posedge PCLK) disable iff (!PRESET)
        req_fifo_rd_en |=> $stable(req_fifo_rd_data);
    endproperty
    assert property (p_axi_req_data_stable)
    else `uvm_error("AXI_IF", "req_fifo_rd_data changed during read enable");

    // (Optional) check that read FIFO data is stable when rd_fifo_wr_en is asserted
    property p_axi_rd_data_stable;
        @(posedge PCLK) disable iff (!PRESET)
        rd_fifo_wr_en |=> $stable(rd_fifo_wr_data);
    endproperty
    assert property (p_axi_rd_data_stable)
    else `uvm_error("AXI_IF", "rd_fifo_wr_data changed during write enable");

    always_comb begin
        if (PRESET) begin
            assert (!$isunknown({req_fifo_empty, req_fifo_rd_data, req_fifo_rd_en,
                                wr_fifo_empty, wr_fifo_rd_data, wr_fifo_rd_en,
                                rd_fifo_full, rd_fifo_wr_en, rd_fifo_wr_data}))
                else `uvm_error("AXI_IF", "Unknown value on FIFO signals");
        end
    end
endinterface