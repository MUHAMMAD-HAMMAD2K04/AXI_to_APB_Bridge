module hw_top;

    logic [31:0]  clock_period = 5;
    logic         run_clock = 1'b1;
    logic         clock;
    logic         reset;

    apb_if apb(clock, reset);

    Bridge_Complete #(32,32) u_bridge (
        .PCLK               (clock),
        .PRESET             (reset),
        .req_fifo_empty     (1'b0),
        .req_fifo_rd_data   (33'd0),
        .req_fifo_rd_en     (),
        .wr_fifo_empty      (),
        .wr_fifo_rd_data    (),
        .wr_fifo_rd_en      (),
        .rd_fifo_wr_en      (),
        .rd_fifo_wr_data    (),
        .rd_fifo_full       (1'b0),
        .PTRANSFER          (apb.PTRANSFER),
        .PWRITE             (apb.PWRITE),
        .PADDR              (apb.PADDR),
        .PWDATA             (apb.PWDATA),
        .PSTRB              (apb.PSTRB),
        .PREADY             (apb.PREADY),
        .PRDATA             (apb.PRDATA)
    );

    initial begin
        clock = 0;
        forever #(clock_period/2) clock = ~clock;
    end

    initial begin
        reset = 0;   
        #100;
        reset = 1;
        #10;         
    end
endmodule