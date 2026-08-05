module hw_top;
    logic         PCLK;
    logic         PRESET;

    parameter ADDR_WIDTH = 32;
    parameter DATA_WIDTH = 32;

    apb_if#(
        .ADDR_WIDTH (ADDR_WIDTH),
        .DATA_WIDTH (DATA_WIDTH)
    ) apb(PCLK, PRESET);
    
    // Bridge Interface
    axi_if #(
        .ADDR_WIDTH (ADDR_WIDTH),
        .DATA_WIDTH (DATA_WIDTH)
    ) axi_if_inst (
        .PCLK   (PCLK),
        .PRESET (PRESET)
    );

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
        .PTRANSFER          (apb.PTRANSFER),
        .PWRITE             (apb.PWRITE),
        .PADDR              (apb.PADDR),
        .PWDATA             (apb.PWDATA),
        .PSTRB              (apb.PSTRB),
        .PREADY             (apb.PREADY),
        .PRDATA             (apb.PRDATA)
    );

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

        forever begin
            @(posedge PCLK);
            if (axi_if_inst.reset_request) begin
                PRESET = 0;
                while (axi_if_inst.reset_request)
                    @(posedge PCLK);
                PRESET = 1;
            end
        end
    end
endmodule
