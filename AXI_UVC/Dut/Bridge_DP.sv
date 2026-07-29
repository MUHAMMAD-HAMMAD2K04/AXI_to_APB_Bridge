`timescale 1ns / 1ps
module Bridge_DP#(
    parameter int ADDR_WIDTH = 32,
    parameter int DATA_WIDTH = 32
)(
    input  logic PCLK,
    input  logic PRESET,

    input  logic [ADDR_WIDTH:0] req_fifo_rd_data,
    input  logic [DATA_WIDTH+((DATA_WIDTH/8)-1):0] wr_fifo_rd_data,
    input  logic [2:0] state,
    input  logic [DATA_WIDTH-1:0] PRDATA,

    output logic [ADDR_WIDTH-1:0] PADDR,
    output logic [DATA_WIDTH-1:0] PWDATA,
    output logic [(DATA_WIDTH/8)-1:0] PSTRB,
    output logic [DATA_WIDTH-1:0] rd_fifo_wr_data
);

    localparam int STRB_WIDTH = DATA_WIDTH / 8;

    logic [ADDR_WIDTH-1:0] addr;
    logic [DATA_WIDTH-1:0] wdata;
    logic [STRB_WIDTH-1:0] wstrb;
    logic is_write;

    logic [DATA_WIDTH-1:0] prdata_latched;

    always_ff @(posedge PCLK or negedge PRESET) begin
        if (!PRESET) begin
            prdata_latched <= '0;
        end else if (state == 3'd3) begin // ACCESS
            prdata_latched <= PRDATA;
        end
    end

    always_comb begin
        addr    = req_fifo_rd_data[ADDR_WIDTH-1:0];
        is_write = req_fifo_rd_data[ADDR_WIDTH];

        wdata   = wr_fifo_rd_data[DATA_WIDTH-1:0];
        wstrb   = wr_fifo_rd_data[DATA_WIDTH +: STRB_WIDTH];

        PADDR   = addr;
        PWDATA  = wdata;
        PSTRB   = wstrb;

        rd_fifo_wr_data = prdata_latched;
    end
endmodule