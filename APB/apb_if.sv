import uvm_pkg::*;
`include "uvm_macros.svh"

interface apb_if#(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
)(input clk, input rst);

    localparam int STRB_WIDTH = DATA_WIDTH / 8;

    // APB-side control signals
    logic                       PTRANSFER; //output port from rtl
    logic                       PWRITE;    //output port from rtl
    logic [ADDR_WIDTH-1:0]      PADDR;     //output port from rtl
    logic [DATA_WIDTH-1:0]      PWDATA;    //output port from rtl
    logic [STRB_WIDTH-1:0]      PSTRB;     //output port from rtl
    logic                       PREADY;    //input port to rtl
    logic [DATA_WIDTH-1:0]      PRDATA;    //input port to rtl

    modport driver_mp (
        input clk, 
        input rst,
        //Output From DUT
        input  PTRANSFER,
        input  PWRITE,
        input  PADDR,
        input  PWDATA,
        input  PSTRB,
        //Input to DUT
        output PRDATA,           
        output PREADY
    );

    modport monitor_mp (
        input clk, 
        input rst,
        //Output From DUT
        input  PTRANSFER,
        input  PWRITE,
        input  PADDR,
        input  PWDATA,
        input  PSTRB,
        //Input to DUT
        input PRDATA,           
        input PREADY
    );

    /*property p_apb_addr_stable;
        @(posedge clk) disable iff (!rst)
        (PTRANSFER && !$past(PTRANSFER)) |=> $stable({PADDR, PWRITE, PWDATA, PSTRB}) throughout (PTRANSFER);
    endproperty
    assert property (p_apb_addr_stable)
    else `uvm_error("APB_IF", "Address/control/data changed while PTRANSFER was high");*/

    property p_apb_pready_after_ptransfer;
        @(posedge clk) disable iff (!rst)
        PREADY |-> PTRANSFER;
    endproperty
    assert property (p_apb_pready_after_ptransfer)
    else `uvm_error("APB_IF", "PREADY asserted before PTRANSFER");

    always_comb begin
        if (rst) begin
            assert (!$isunknown({PTRANSFER, PWRITE, PADDR, PWDATA, PSTRB, PREADY, PRDATA}))
                else `uvm_error("APB_IF", "Unknown value detected on APB bus");
        end
    end
endinterface : apb_if