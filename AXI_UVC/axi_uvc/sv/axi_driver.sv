class axi_driver extends uvm_driver#(axi_transaction);
    
    virtual interface axi_if vif;

    //FACTORY REGISTER "axi_driver"
    `uvm_component_utils(axi_driver)

    //ADD A CONSTRUCTOR 
    function new(string name = "axi_driver", uvm_component parent);
        super.new(name, parent);
    endfunction //new()

    // Build Phase
    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        if(!uvm_config_db#(virtual axi_if)::get(this,"","vif",vif))
        begin
            `uvm_fatal("NOVIF","Virtual Interface not found")
        end

    endfunction

 
    // Reset Bus

    task reset_signals();

        vif.awvalid <= 0;
        vif.wvalid  <= 0;
        vif.bready  <= 0;

        vif.arvalid <= 0;
        vif.rready  <= 0;

        vif.awaddr  <= 0;
        vif.wdata   <= 0;
        vif.wstrb   <= 0;
        vif.wlast   <= 0;

        vif.araddr  <= 0;

    endtask

     
    // Run Phase
     
    task run_phase(uvm_phase phase);

        axi_transaction tr;

        reset_signals();

        forever
        begin

            seq_item_port.get_next_item(tr);

            if(tr.write)
                drive_write(tr);
            else
                drive_read(tr);

            seq_item_port.item_done();

        end

    endtask

     
    // Write Transaction
     
    task drive_write(axi_transaction tr);
         
        // Write Address
        @(posedge vif.ACLK);

        vif.awaddr  <= tr.addr;
        vif.awvalid <= 1;

        wait(vif.awready);

        @(posedge vif.ACLK);

        vif.awvalid <= 0;
         
        // Write Data
        vif.wdata  <= tr.data;
        vif.wstrb  <= tr.strb;
        vif.wlast  <= 1;
        vif.wvalid <= 1;

        wait(vif.wready);

        @(posedge vif.ACLK);

        vif.wvalid <= 0;
        vif.wlast  <= 0;

        // Write Response
        vif.bready <= 1;

        wait(vif.bvalid);

        if(vif.bresp != 2'b00)
        begin
            `uvm_error("WRITE",
                $sformatf(
                "Write Response Error %0d",
                vif.bresp))
        end

        @(posedge vif.ACLK);

        vif.bready <= 0;

        `uvm_info(get_type_name(),"WRITE COMPLETE",UVM_MEDIUM)

    endtask

     
    // Read Transaction

    task drive_read(axi_transaction tr);
         
        // Read Address
        
        @(posedge vif.ACLK);

        vif.araddr  <= tr.addr;
        vif.arvalid <= 1;

        wait(vif.arready);

        @(posedge vif.ACLK);

        vif.arvalid <= 0;

         
        // Read Data

        vif.rready <= 1;

        wait(vif.rvalid);

        tr.data = vif.rdata;

        if(vif.rresp != 2'b00)
        begin
            `uvm_error("READ",$sformatf("Read Response Error %0d",vif.rresp))
        end

        @(posedge vif.ACLK);

        vif.rready <= 0;

        `uvm_info(get_type_name(),$sformatf("READ DATA = %h",tr.data),UVM_MEDIUM)

    endtask

    
   function void start_of_simulation_phase(uvm_phase phase);
        `uvm_info(get_type_name(),"Running Simulation ...",UVM_HIGH);
   endfunction

endclass //axi_driver extends uvm_driver