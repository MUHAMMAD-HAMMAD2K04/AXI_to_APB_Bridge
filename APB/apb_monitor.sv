class apb_monitor extends uvm_monitor;

    `uvm_component_utils(apb_monitor)

    virtual apb_if.monitor_mp vif;

    axi_to_apb_packet pkt;

    uvm_analysis_port #(axi_to_apb_packet) analysis_port;

    int num_pkt_col;

    function new(string name="apb_monitor", uvm_component parent);
        super.new(name,parent);

        analysis_port = new("analysis_port", this);
    endfunction

    function void connect_phase(uvm_phase phase);

        super.connect_phase(phase);

        if(!uvm_config_db#(virtual apb_if.monitor_mp)::get(this,"","vif",vif))
            `uvm_fatal("NO_VIF","Virtual Interface Not Found");

    endfunction

    function void start_of_simulation_phase(uvm_phase phase);

        `uvm_info(get_type_name(),
                  "APB Monitor Started",
                  UVM_LOW);

    endfunction

    task run_phase(uvm_phase phase);

        wait(vif.rst);

        forever begin

            @(posedge vif.clk);

              
            // Detect APB SETUP phase    
            if(vif.PTRANSFER) begin

                pkt = axi_to_apb_packet::type_id::create("pkt", this);

                pkt.addr  = vif.PADDR;
                pkt.write = vif.PWRITE;
                pkt.wdata = vif.PWDATA;
                pkt.strb  = vif.PSTRB;

                `uvm_info(get_type_name(),
                          $sformatf("SETUP : ADDR=%08h WRITE=%0d WDATA=%08h STRB=%0h",
                                    pkt.addr,
                                    pkt.write,
                                    pkt.wdata,
                                    pkt.strb),
                          UVM_HIGH)

                 
                // Wait until APB transfer completes     
                while(!vif.PREADY)
                    @(posedge vif.clk);

                pkt.ready = vif.PREADY;

                if(!pkt.write)
                    pkt.rdata = vif.PRDATA;
                else
                    pkt.rdata = '0;

                num_pkt_col++;

                analysis_port.write(pkt);

                `uvm_info(get_type_name(),
                          $sformatf(
                          "\n----------------------------------------\
                           \n APB TRANSACTION COMPLETE\
                           \n WRITE : %0d\
                           \n ADDR  : %08h\
                           \n WDATA : %08h\
                           \n RDATA : %08h\
                           \n STRB  : %0h\
                           \n READY : %0d\
                           \n Packet Count : %0d\
                           \n----------------------------------------",
                          pkt.write,
                          pkt.addr,
                          pkt.wdata,
                          pkt.rdata,
                          pkt.strb,
                          pkt.ready,
                          num_pkt_col),
                          UVM_MEDIUM);

            end

        end

    endtask

    function void report_phase(uvm_phase phase);

        super.report_phase(phase);

        `uvm_info(get_type_name(),
                  $sformatf("APB Monitor Collected %0d Packets",
                            num_pkt_col),
                  UVM_LOW);

    endfunction

endclass