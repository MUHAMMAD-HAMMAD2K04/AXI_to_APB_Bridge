`timescale 1ns/1ps

module hw_top;

     
    // Parameters
    parameter ADDR_WIDTH = 32;
    parameter DATA_WIDTH = 32;

     
    // Clock & Reset
    logic PCLK;
    logic PRESET;

     
    // Clock Generation
    initial begin
        PCLK = 0;
        forever #5 PCLK = ~PCLK;
    end

     
    // Reset Generation
    initial begin
        PRESET = 0;
        repeat(5) @(posedge PCLK);
        PRESET = 1;
    end

     
    // Bridge Interface
    axi_if #(
        .ADDR_WIDTH (ADDR_WIDTH),
        .DATA_WIDTH (DATA_WIDTH)
    ) axi_if_inst (
        .PCLK   (PCLK),
        .PRESET (PRESET)
    );

     
    // APB Dummy Signals
    logic                    PREADY;
    logic [DATA_WIDTH-1:0]   PRDATA;

    // DUT outputs (optional, for waveform visibility)
    logic                    PTRANSFER;
    logic                    PWRITE;
    logic [ADDR_WIDTH-1:0]   PADDR;
    logic [DATA_WIDTH-1:0]   PWDATA;
    logic [(DATA_WIDTH/8)-1:0] PSTRB;

     
    // Dummy APB Slave
     

    assign PREADY = 1'b1;
    assign PRDATA = 32'hDEADBEEF;

     
    // DUT
    Bridge_Complete #(
        .ADDR_WIDTH (ADDR_WIDTH),
        .DATA_WIDTH (DATA_WIDTH)
    ) dut (

        .PCLK               (PCLK),
        .PRESET             (PRESET),

        // Request FIFO
        .req_fifo_empty     (axi_if_inst.req_fifo_empty),
        .req_fifo_rd_data   (axi_if_inst.req_fifo_rd_data),
        .req_fifo_rd_en     (axi_if_inst.req_fifo_rd_en),

        // Write FIFO
        .wr_fifo_empty      (axi_if_inst.wr_fifo_empty),
        .wr_fifo_rd_data    (axi_if_inst.wr_fifo_rd_data),
        .wr_fifo_rd_en      (axi_if_inst.wr_fifo_rd_en),

        // Read FIFO
        .rd_fifo_full       (axi_if_inst.rd_fifo_full),
        .rd_fifo_wr_en      (axi_if_inst.rd_fifo_wr_en),
        .rd_fifo_wr_data    (axi_if_inst.rd_fifo_wr_data),

        // APB
        .PTRANSFER          (PTRANSFER),
        .PWRITE             (PWRITE),
        .PADDR              (PADDR),
        .PWDATA             (PWDATA),
        .PSTRB              (PSTRB),
        .PREADY             (PREADY),
        .PRDATA             (PRDATA)
    );

endmodule