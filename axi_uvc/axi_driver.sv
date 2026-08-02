class axi_driver extends uvm_driver #(axi_transaction);

    `uvm_component_utils(axi_driver)

    virtual axi_if vif;

    function new(string name="axi_driver", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual axi_if)::get(this, "", "vif", vif))
            `uvm_fatal("NOVIF", "axi_if not found")
    endfunction

    // Reset Interface
    task reset_signals();
        vif.drv_cb.req_fifo_empty   <= 1'b1;
        vif.drv_cb.req_fifo_rd_data <= '0;
        vif.drv_cb.wr_fifo_empty    <= 1'b1;
        vif.drv_cb.wr_fifo_rd_data  <= '0;
        vif.drv_cb.rd_fifo_full     <= 1'b0;
    endtask

    // Run Phase
    task run_phase(uvm_phase phase);
        axi_transaction tr;
        reset_signals();

        // Wait for reset to deassert
        wait(vif.PRESET == 1'b1);
        @(vif.drv_cb);

        forever begin
            `uvm_info("DRV", "Waiting for sequence item...", UVM_HIGH)
            seq_item_port.get_next_item(tr);

            //`uvm_info("DRV", $sformatf("Sequence received: WRITE=%0d ADDR=%h DATA=%h", tr.write, tr.addr, tr.data), UVM_MEDIUM)

            if(tr.write)
                drive_write(tr);
            else
                drive_read(tr);

            seq_item_port.item_done();
        end
    endtask

    // Write Transaction
    task drive_write(axi_transaction tr);
        // Step 1: Put request in FIFO (Write request bit = 1)
        @(vif.drv_cb);
        vif.drv_cb.req_fifo_rd_data <= {1'b1, tr.addr};
        vif.drv_cb.req_fifo_empty   <= 1'b0;

        // Wait until DUT acknowledges request
        do @(vif.drv_cb);
        while (!vif.drv_cb.req_fifo_rd_en);

        // Deassert request empty flag
        vif.drv_cb.req_fifo_empty <= 1'b1;

        // Step 2: Provide write data to Write FIFO
        vif.drv_cb.wr_fifo_rd_data <= {tr.strb, tr.data};
        vif.drv_cb.wr_fifo_empty   <= 1'b0;

        // Wait until DUT accepts write data
        do @(vif.drv_cb);
        while (!vif.drv_cb.wr_fifo_rd_en);

        vif.drv_cb.wr_fifo_empty <= 1'b1;
        `uvm_info("DRV", "Write transaction complete", UVM_HIGH)
    endtask

    // Read Transaction
    task drive_read(axi_transaction tr);
        // Step 1: Put request in FIFO (Read request bit = 0)
        @(vif.drv_cb);
        vif.drv_cb.req_fifo_rd_data <= {1'b0, tr.addr};
        vif.drv_cb.req_fifo_empty   <= 1'b0;

        // Wait until DUT acknowledges request
        do @(vif.drv_cb);
        while (!vif.drv_cb.req_fifo_rd_en);

        vif.drv_cb.req_fifo_empty <= 1'b1;

        // Step 2: Wait for DUT to place read data into Read FIFO
        do @(vif.drv_cb);
        while (!vif.drv_cb.rd_fifo_wr_en);

        tr.data = vif.drv_cb.rd_fifo_wr_data;

        `uvm_info("DRV", $sformatf("READ COMPLETE ADDR=%h DATA=%h", tr.addr, tr.data), UVM_MEDIUM)
    endtask

endclass