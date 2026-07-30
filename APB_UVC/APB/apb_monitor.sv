class apb_monitor extends uvm_monitor;
    `uvm_component_utils(apb_monitor)

    virtual interface apb_if.monitor_mp vif;

    axi_to_apb_packet pkt;

    int num_pkt_col;

    function new(string name = "apb_monitor" , uvm_component parent);
        super.new(name,parent);
    endfunction

    function void connect_phase(uvm_phase phase);
        if(!uvm_config_db#(virtual interface apb_if.monitor_mp)::get(this, "","vif", vif))
            `uvm_error("NO-VIF", "Missing virtual interface")
    endfunction

    function void start_of_simulation_phase(uvm_phase phase);
        `uvm_info(get_type_name(),"Running Simulation---", UVM_HIGH)
    endfunction

    task run_phase(uvm_phase phase);
        fork
            collected_packet();
        join
    endtask

    task collected_packet();
        wait (vif.rst == 1);
        forever begin

            @(posedge vif.clk);

            if (vif.PTRANSFER) begin
                pkt = axi_to_apb_packet::type_id::create("pkt");

                pkt.addr  = vif.PADDR;
                pkt.write = vif.PWRITE;
                pkt.wdata = vif.PWDATA;   // Valid for writes (ignored for reads)
                pkt.strb  = vif.PSTRB;    // Valid for writes (ignored for reads)

                `uvm_info(get_type_name(),
                    $sformatf("SETUP phase: addr=0x%0h, write=%b, wdata=0x%0h, strb=0x%0h",
                            pkt.addr, pkt.write, pkt.rdata, pkt.strb),
                    UVM_HIGH)

                @(posedge vif.clk);

                pkt.rdata = vif.PRDATA;
                pkt.ready = vif.PREADY;

                while (vif.PTRANSFER)
                    @(posedge vif.clk);

                num_pkt_col++;

                `uvm_info(get_type_name(),
                    $sformatf("APB transfer complete: addr=0x%0h, write=%b, rdata=0x%0h, ready=%b",
                            pkt.addr, pkt.write, pkt.rdata, pkt.ready),
                    UVM_MEDIUM)
            end
        end
    endtask

    function void report_phase(uvm_phase phase);
        `uvm_info(get_type_name(), $sformatf("Report: YAPP Monitor Collected %0d Packets", num_pkt_col), UVM_LOW)
    endfunction : report_phase
endclass