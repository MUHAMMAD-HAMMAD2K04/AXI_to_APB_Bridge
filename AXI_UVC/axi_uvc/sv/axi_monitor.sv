class axi_monitor extends uvm_monitor;

    `uvm_component_utils(axi_monitor)

    // Virtual Interface
    virtual axi_if vif;

    // Analysis Port
    uvm_analysis_port #(axi_transaction) ap;

    // Constructor
    function new(string name="axi_monitor", uvm_component parent);
        super.new(name,parent);
    endfunction
      
    // Build Phase
    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        ap = new("ap",this);

        if(!uvm_config_db#(virtual axi_if)::get(this,"","vif",vif))
        begin

        `uvm_fatal("NOVIF", "AXI virtual interface not found")

        end

    endfunction

    // Run Phase
    task run_phase(uvm_phase phase);

        forever
        begin

            @(posedge vif.ACLK);

            if(!vif.ARESETn)
                continue;

            // Check write transaction
            if(vif.awvalid && vif.awready)
            begin

                collect_write();

            end

            // Check read transaction
            if(vif.arvalid && vif.arready)
            begin

                collect_read();

            end

        end

    endtask

    // Capture Write Transaction
    task collect_write();

        axi_transaction tr;
        tr = axi_transaction::type_id::create("tr");

        tr.write = 1;

        // Capture Address
        tr.addr = vif.awaddr;

        // Wait for Write Data
        @(posedge vif.ACLK);

        wait(vif.wvalid && vif.wready);

        tr.data = vif.wdata;

        tr.strb = vif.wstrb;
         
        // Wait for Response
        @(posedge vif.ACLK);

        wait(vif.bvalid && vif.bready);

        tr.resp = vif.bresp;

        ap.write(tr);

        `uvm_info(
        get_type_name(),$sformatf("WRITE MONITOR : ADDR=%h DATA=%h RESP=%0d", tr.addr, tr.data, tr.resp), UVM_MEDIUM)

    endtask

    // Capture Read Transaction
    task collect_read();

        axi_transaction tr;

        tr = axi_transaction::type_id::create("tr");

        tr.write = 0;

        // Capture Address
        tr.addr = vif.araddr;
         
        // Wait for Read Data
        @(posedge vif.ACLK);

        wait(vif.rvalid && vif.rready);

        tr.data = vif.rdata;

        tr.resp = vif.rresp;

        ap.write(tr);

        `uvm_info(
        get_type_name(), $sformatf("READ MONITOR : ADDR=%h DATA=%h RESP=%0d", tr.addr, tr.data, tr.resp), UVM_MEDIUM)

    endtask

endclass