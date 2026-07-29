class axi_monitor extends uvm_monitor;

    `uvm_component_utils(axi_monitor)

    virtual axi_if vif;
    uvm_analysis_port #(axi_transaction) ap;

    function new(string name="axi_monitor", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap = new("ap", this);
        if(!uvm_config_db#(virtual axi_if)::get(this, "", "vif", vif))
            `uvm_fatal("NOVIF", "axi_if not found")
    endfunction

    task run_phase(uvm_phase phase);
        axi_transaction tr;

        forever begin
            @(vif.mon_cb);

            if(!vif.PRESET)
                continue;

            // Monitor detects request read enable pulse from DUT
            if(vif.mon_cb.req_fifo_rd_en) begin
                tr = axi_transaction::type_id::create("tr");

                tr.write = vif.mon_cb.req_fifo_rd_data[32];
                tr.addr  = vif.mon_cb.req_fifo_rd_data[31:0];

                // Handles Write transaction capture
                if(tr.write) begin
                    do @(vif.mon_cb);
                    while (!vif.mon_cb.wr_fifo_rd_en);

                    tr.data = vif.mon_cb.wr_fifo_rd_data[31:0];
                    tr.strb = vif.mon_cb.wr_fifo_rd_data[35:32];
                end 
                // Handles Read transaction capture
                else begin
                    do @(vif.mon_cb);
                    while (!vif.mon_cb.rd_fifo_wr_en);

                    tr.data = vif.mon_cb.rd_fifo_wr_data;
                end

                ap.write(tr);

                `uvm_info(get_type_name(), $sformatf("Recieved Write Transaction:\n%s", tr.sprint()), UVM_MEDIUM)

                `uvm_info(get_type_name(),
                    $sformatf("MONITOR CAPTURED: ADDR=%h WRITE=%0d DATA=%h", tr.addr, tr.write, tr.data),
                    UVM_MEDIUM)
            end
        end
    endtask

endclass