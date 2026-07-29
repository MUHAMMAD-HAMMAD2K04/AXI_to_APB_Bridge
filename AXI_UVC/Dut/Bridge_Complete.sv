`timescale 1ns / 1ps
module Bridge_Complete#(
    parameter int ADDR_WIDTH = 32,
    parameter int DATA_WIDTH = 32
)(
    input  logic PCLK,
    input  logic PRESET,

    // FIFO interfaces
    input  logic                    req_fifo_empty,
    input  logic [ADDR_WIDTH:0]     req_fifo_rd_data,
    output logic                    req_fifo_rd_en,

    input  logic                    wr_fifo_empty,
    input  logic [DATA_WIDTH+((DATA_WIDTH/8)-1):0] wr_fifo_rd_data,
    output logic                    wr_fifo_rd_en,

    output logic                    rd_fifo_wr_en,
    output logic [DATA_WIDTH-1:0]   rd_fifo_wr_data,
    input  logic                    rd_fifo_full,

    // APB-side control signals
    output logic                    PTRANSFER,
    output logic                    PWRITE,
    output logic [ADDR_WIDTH-1:0]   PADDR,
    output logic [DATA_WIDTH-1:0]   PWDATA,
    output logic [(DATA_WIDTH/8)-1:0] PSTRB,
    input  logic                    PREADY,
    input  logic [DATA_WIDTH-1:0]   PRDATA
);

    logic [2:0] state_ctrl;

    Bridge_CP #(
        .ADDR_WIDTH(ADDR_WIDTH)
    ) control_path (
        .PCLK(PCLK),
        .PRESET(PRESET),
        .req_fifo_empty(req_fifo_empty),
        .req_fifo_rd_data(req_fifo_rd_data),
        .req_fifo_rd_en(req_fifo_rd_en),
        .wr_fifo_empty(wr_fifo_empty),
        .wr_fifo_rd_en(wr_fifo_rd_en),
        .rd_fifo_full(rd_fifo_full),
        .rd_fifo_wr_en(rd_fifo_wr_en),
        .PREADY(PREADY),
        .PTRANSFER(PTRANSFER),
        .PWRITE(PWRITE),
        .state_out(state_ctrl)
    );

    Bridge_DP #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) data_path (
        .PCLK(PCLK),
        .PRESET(PRESET),
        .state(state_ctrl),
        .req_fifo_rd_data(req_fifo_rd_data),
        .wr_fifo_rd_data(wr_fifo_rd_data),
        .PRDATA(PRDATA),
        .PADDR(PADDR),
        .PWDATA(PWDATA),
        .PSTRB(PSTRB),
        .rd_fifo_wr_data(rd_fifo_wr_data)
    );
endmodule