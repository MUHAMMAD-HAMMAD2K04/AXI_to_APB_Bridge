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

endinterface