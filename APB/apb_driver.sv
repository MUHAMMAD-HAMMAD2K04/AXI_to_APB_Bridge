class apb_driver extends uvm_driver #(axi_to_apb_packet);
    `uvm_component_utils(apb_driver)

    virtual interface apb_if.driver_mp vif;

    int num_sent;
    int packet_delay=10;

    function new(string name = "apb_driver", uvm_component parent);
        super.new(name,parent);
    endfunction

    function void start_of_simulation_phase(uvm_phase phase);
        `uvm_info(get_type_name(),"Running Simulation---", UVM_HIGH)
    endfunction

    task run_phase(uvm_phase phase);
        fork 
            send_to_dut();
            reset();
        join
    endtask

    function void connect_phase(uvm_phase phase);
        if(!uvm_config_db#(virtual interface apb_if.driver_mp)::get(this, "","vif", vif))
            `uvm_error("NO-VIF", "Missing virtual interface")
    endfunction

    task send_to_dut();
        axi_to_apb_packet pkt;  
        
        repeat(packet_delay);
        
        forever begin
            @(negedge vif.clk);
            
            if (vif.PTRANSFER) begin
                
                `uvm_info(get_type_name(),
                    $sformatf("APB transfer started: PWRITE=%b, PADDR=0x%0h",
                              vif.PWRITE, vif.PADDR), UVM_MEDIUM)
                
                @(negedge vif.clk);
                
                if (!vif.PWRITE) begin
                    
                    `uvm_info(get_type_name(),
                        "READ transfer waiting for sequencer item...",
                        UVM_MEDIUM)

                    seq_item_port.get_next_item(pkt);

                    `uvm_info(get_type_name(),
                        $sformatf("READ got item: addr=0x%0h, rdata=0x%0h",
                                  pkt.addr, pkt.wdata),
                        UVM_MEDIUM)

                    vif.PRDATA <= pkt.wdata;
                    vif.PREADY <= 1'b1;
                    
                    @(negedge vif.clk);
                    
                    vif.PREADY <= 1'b0;
                    vif.PRDATA <= '0;
                    
                    seq_item_port.item_done();
                end 
                else begin
                    vif.PREADY <= 1'b1;
                
                    @(negedge vif.clk);
                    
                    vif.PREADY <= 1'b0;
                end

                num_sent++;
            end
        end
    endtask

    task reset();
        @(negedge vif.clk);
        vif.PRDATA<=0;
        vif.PREADY<=0;
    endtask
endclass