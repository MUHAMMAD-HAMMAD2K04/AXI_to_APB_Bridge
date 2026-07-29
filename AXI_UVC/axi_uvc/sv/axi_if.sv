interface axi_if #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
)(
    input logic ACLK,
    input logic ARESETn
);

 
// Write Address Channel
logic [ADDR_WIDTH-1:0] awaddr;
logic                  awvalid;
logic                  awready;

 
// Write Data Channel
logic [DATA_WIDTH-1:0] wdata;
logic [(DATA_WIDTH/8)-1:0] wstrb;
logic                  wlast;
logic                  wvalid;
logic                  wready;

 
// Write Response Channel
logic [1:0]            bresp;
logic                  bvalid;
logic                  bready;

 
// Read Address Channel
logic [ADDR_WIDTH-1:0] araddr;
logic                  arvalid;
logic                  arready;

 
// Read Data Channel
logic [DATA_WIDTH-1:0] rdata;
logic [1:0]            rresp;
logic                  rlast;
logic                  rvalid;
logic                  rready;

 
// Master Clocking Block
 

clocking master_cb @(posedge ACLK);

    default input #1step output #1step;

    // Write Address
    output awaddr;
    output awvalid;
    input  awready;

    // Write Data
    output wdata;
    output wstrb;
    output wlast;
    output wvalid;
    input  wready;

    // Write Response
    input  bresp;
    input  bvalid;
    output bready;

    // Read Address
    output araddr;
    output arvalid;
    input  arready;

    // Read Data
    input  rdata;
    input  rresp;
    input  rlast;
    input  rvalid;
    output rready;

endclocking

 
// Slave Clocking Block
 
clocking slave_cb @(posedge ACLK);

    default input #1step output #1step;

    // Write Address
    input  awaddr;
    input  awvalid;
    output awready;

    // Write Data
    input  wdata;
    input  wstrb;
    input  wlast;
    input  wvalid;
    output wready;

    // Write Response
    output bresp;
    output bvalid;
    input  bready;

    // Read Address
    input  araddr;
    input  arvalid;
    output arready;

    // Read Data
    output rdata;
    output rresp;
    output rlast;
    output rvalid;
    input  rready;

endclocking

 
// Monitor Clocking Block
 

clocking monitor_cb @(posedge ACLK);

    default input #1step;

    // Write Address
    input awaddr;
    input awvalid;
    input awready;

    // Write Data
    input wdata;
    input wstrb;
    input wlast;
    input wvalid;
    input wready;

    // Write Response
    input bresp;
    input bvalid;
    input bready;

    // Read Address
    input araddr;
    input arvalid;
    input arready;

    // Read Data
    input rdata;
    input rresp;
    input rlast;
    input rvalid;
    input rready;

endclocking

 
// Modports
 
// Used by AXI Master Driver
modport MASTER (
    clocking master_cb,
    input ACLK,
    input ARESETn
);

// Used by AXI Slave (if needed)
modport SLAVE (
    clocking slave_cb,
    input ACLK,
    input ARESETn
);

// Used by Monitor
modport MONITOR (
    clocking monitor_cb,
    input ACLK,
    input ARESETn
);

endinterface