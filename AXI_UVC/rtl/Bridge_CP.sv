`timescale 1ns / 1ps
module Bridge_CP#(
    parameter int ADDR_WIDTH = 32
)(
    input  logic PCLK,
    input  logic PRESET,

    input  logic req_fifo_empty,
    input  logic [ADDR_WIDTH:0] req_fifo_rd_data,
    output logic req_fifo_rd_en,

    input  logic wr_fifo_empty,
    output logic wr_fifo_rd_en,

    input  logic PREADY,
    input  logic rd_fifo_full,
    output logic rd_fifo_wr_en,

    output logic PTRANSFER,
    output logic PWRITE,

    output logic [2:0] state_out
);

    typedef enum logic [2:0] {
        S_IDLE       = 3'd0,
        S_REQ_DECODE = 3'd1,
        S_WAIT_WDATA = 3'd2,
        S_SETUP      = 3'd3,
        S_ACCESS     = 3'd4,
        S_STORE_RDATA= 3'd5
    } state_t;

    state_t state, next;
    logic is_write, is_write_latched;

    assign state_out = state;

    // Latched write/read type
    always_ff @(posedge PCLK or negedge PRESET) begin
        if (!PRESET)
            is_write_latched <= 0;
        else if (state == S_REQ_DECODE)
            is_write_latched <= req_fifo_rd_data[ADDR_WIDTH];
    end

    // FSM sequential
    always_ff @(posedge PCLK or negedge PRESET) begin
        if (!PRESET)
            state <= S_IDLE;
        else
            state <= next;
    end

    // FSM combinational
    always_comb begin
        // Defaults
        req_fifo_rd_en = 0;
        wr_fifo_rd_en  = 0;
        rd_fifo_wr_en  = 0;
        PTRANSFER      = 0;
        PWRITE         = 0;
        next           = state;

        case (state)
            S_IDLE: begin
                if (!req_fifo_empty) begin
                    req_fifo_rd_en = 1;
                    next = S_REQ_DECODE;
                end
            end

            S_REQ_DECODE: begin
                // Decode type and wait if write
                if (req_fifo_rd_data[ADDR_WIDTH]) begin
                    next = S_WAIT_WDATA;
                end else begin
                    next = S_SETUP;
                end
            end

            S_WAIT_WDATA: begin
                if (!wr_fifo_empty) begin
                    wr_fifo_rd_en = 1;
                    next = S_SETUP;
                end
            end

            S_SETUP: begin
                PTRANSFER = 1;
                PWRITE    = is_write_latched;
                next = S_ACCESS;
            end

            S_ACCESS: begin
                PTRANSFER = 1;
                PWRITE    = is_write_latched;
                if (PREADY) begin
                    next = is_write_latched ? S_IDLE : S_STORE_RDATA;
                end
            end

            S_STORE_RDATA: begin
                if (!rd_fifo_full) begin
                    rd_fifo_wr_en = 1;
                    next = S_IDLE;
                end
            end

            default: next = S_IDLE;
        endcase
    end
endmodule