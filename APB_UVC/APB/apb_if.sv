interface apb_if(input clk, input rst);
    import uvm_pkg::*;

    `include "uvm_macros.svh"
    
    parameter int ADDR_WIDTH = 32;
    parameter int DATA_WIDTH = 32;
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
endinterface : apb_if