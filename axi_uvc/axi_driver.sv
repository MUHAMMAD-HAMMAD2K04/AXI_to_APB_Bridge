class axi_driver extends uvm_driver #(axi_transaction);

    `uvm_component_utils(axi_driver)

    virtual axi_if vif;
    uvm_analysis_port #(axi_transaction) analysis_port;

    function new(string name="axi_driver", uvm_component parent);
        super.new(name, parent);
        analysis_port = new("analysis_port", this);
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
        vif.drv_cb.reset_request    <= 1'b0;
    endtask

    // Run Phase
    task run_phase(uvm_phase phase);
        axi_transaction tr;
        axi_transaction tr_copy;
        reset_signals();

        // Wait for reset to deassert
        wait(vif.PRESET == 1'b1);
        @(vif.drv_cb);

        forever begin
            `uvm_info("DRV", "Waiting for sequence item...", UVM_DEBUG)
            seq_item_port.get_next_item(tr);

            // Preserve exactly what the driver received.  Read data is filled
            // later, so publish a clone rather than the live request handle.
            $cast(tr_copy, tr.clone());
            analysis_port.write(tr_copy);

           `uvm_info(get_type_name(), $sformatf("Send Transaction:\n%s", tr.sprint()), UVM_DEBUG)

            `uvm_info("DRV", $sformatf("Sequence received: WRITE=%0d ADDR=%h DATA=%h", tr.write, tr.addr, tr.data), UVM_DEBUG)

            if(tr.write)
                drive_write(tr);
            else
                drive_read(tr);

            seq_item_port.item_done();
        end
    endtask

    // Write Transaction
    task drive_write(axi_transaction tr);
        repeat (tr.req_empty_cycles) begin
            @(vif.drv_cb);
            if (vif.drv_cb.req_fifo_rd_en)
                `uvm_error("FIFO_EMPTY", "DUT read request FIFO while empty")
        end

        // Step 1: Put request in FIFO (Write request bit = 1)
        @(vif.drv_cb);
        vif.drv_cb.req_fifo_rd_data <= {1'b1, tr.addr};
        vif.drv_cb.req_fifo_empty   <= 1'b0;

        // Wait until DUT acknowledges request
        do @(vif.drv_cb);
        while (!vif.drv_cb.req_fifo_rd_en);

        // Deassert request empty flag
        vif.drv_cb.req_fifo_empty <= 1'b1;

        if (tr.reset_during) begin
            vif.drv_cb.reset_request <= 1'b1;
            repeat (2) @(vif.drv_cb);
            vif.drv_cb.reset_request <= 1'b0;
            wait (vif.PRESET == 1'b0);
            wait (vif.PRESET == 1'b1);
            @(vif.drv_cb);

            // Retry the transaction that reset intentionally interrupted.
            vif.drv_cb.req_fifo_rd_data <= {1'b1, tr.addr};
            vif.drv_cb.req_fifo_empty   <= 1'b0;
            do @(vif.drv_cb);
            while (!vif.drv_cb.req_fifo_rd_en);
            vif.drv_cb.req_fifo_empty <= 1'b1;
        end

        // Step 2: Provide write data to Write FIFO
        vif.drv_cb.wr_fifo_rd_data <= {tr.strb, tr.data};
        vif.drv_cb.wr_fifo_empty   <= 1'b0;

        // Wait until DUT accepts write data
        do @(vif.drv_cb);
        while (!vif.drv_cb.wr_fifo_rd_en);

        vif.drv_cb.wr_fifo_empty <= 1'b1;
        `uvm_info("DRV", "Write transaction complete", UVM_DEBUG)
    endtask

    // Read Transaction
    task drive_read(axi_transaction tr);
        repeat (tr.req_empty_cycles) begin
            @(vif.drv_cb);
            if (vif.drv_cb.req_fifo_rd_en)
                `uvm_error("FIFO_EMPTY", "DUT read request FIFO while empty")
        end

        // Step 1: Put request in FIFO (Read request bit = 0)
        @(vif.drv_cb);
        vif.drv_cb.req_fifo_rd_data <= {1'b0, tr.addr};
        vif.drv_cb.req_fifo_empty   <= 1'b0;

        // Wait until DUT acknowledges request
        do @(vif.drv_cb);
        while (!vif.drv_cb.req_fifo_rd_en);

        vif.drv_cb.req_fifo_empty <= 1'b1;

        if (tr.reset_during) begin
            vif.drv_cb.reset_request <= 1'b1;
            repeat (2) @(vif.drv_cb);
            vif.drv_cb.reset_request <= 1'b0;
            wait (vif.PRESET == 1'b0);
            wait (vif.PRESET == 1'b1);
            @(vif.drv_cb);

            vif.drv_cb.req_fifo_rd_data <= {1'b0, tr.addr};
            vif.drv_cb.req_fifo_empty   <= 1'b0;
            do @(vif.drv_cb);
            while (!vif.drv_cb.req_fifo_rd_en);
            vif.drv_cb.req_fifo_empty <= 1'b1;
        end

        if (tr.rd_full_cycles != 0) begin
            vif.drv_cb.rd_fifo_full <= 1'b1;
            repeat (tr.rd_full_cycles) begin
                @(vif.drv_cb);
                if (vif.drv_cb.rd_fifo_wr_en)
                    `uvm_error("FIFO_FULL", "DUT wrote read FIFO while full")
            end
            vif.drv_cb.rd_fifo_full <= 1'b0;
        end

        // Step 2: Wait for DUT to place read data into Read FIFO
        do @(vif.drv_cb);
        while (!vif.drv_cb.rd_fifo_wr_en);

        tr.data = vif.drv_cb.rd_fifo_wr_data;

        `uvm_info("DRV", $sformatf("READ COMPLETE ADDR=%h DATA=%h", tr.addr, tr.data), UVM_DEBUG)
    endtask

endclass
