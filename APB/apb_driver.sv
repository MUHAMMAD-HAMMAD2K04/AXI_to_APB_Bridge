class apb_driver extends uvm_driver #(axi_to_apb_packet);

    `uvm_component_utils(apb_driver)

    virtual apb_if.driver_mp vif;

    // APB Slave Memory Model
    bit [31:0] mem [bit [31:0]];

    // Statistics
    int num_reads;
    int num_writes;

    // Wait State Configuration
    int cfg_wait_cycles;
    bit random_wait = 1;

    rand int unsigned rand_wait_cycles;

    constraint c_wait {
        rand_wait_cycles inside {[0:5]};
    }

    // Constructor
    function new(string name="apb_driver",
                 uvm_component parent);
        super.new(name,parent);
    endfunction

    // Build Phase
    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        if(!uvm_config_db#(virtual apb_if.driver_mp)::get(
                this,"","vif",vif))
            `uvm_fatal("NOVIF","APB Interface not found")

         
        // If test provides wait_cycles use that.
        // Otherwise driver randomizes them.
         
        if(uvm_config_db#(int)::get(
                this,"","wait_cycles",cfg_wait_cycles))
            random_wait = 0;
        else
            random_wait = 1;

    endfunction
     
    // Run Phase
    task run_phase(uvm_phase phase);

        reset_signals();

        wait(vif.rst);

        forever begin

             
            // Wait for APB SETUP Phase
            @(posedge vif.clk);

            if(!vif.PTRANSFER)
                continue;

            `uvm_info(get_type_name(),
            $sformatf(
            "\n----------------------------------\
             \n APB TRANSFER START\
             \n TYPE  : %s\
             \n ADDR  : %08h\
             \n WDATA : %08h\
             \n----------------------------------",
             vif.PWRITE ? "WRITE":"READ",
             vif.PADDR,
             vif.PWDATA),
             UVM_MEDIUM)

             
            // ACCESS PHASE
            @(posedge vif.clk);

            // Determine Wait States
            vif.PREADY <= 0;

            if(random_wait)
                assert(randomize(rand_wait_cycles));
            else
                rand_wait_cycles = cfg_wait_cycles;

            repeat(rand_wait_cycles)
                @(posedge vif.clk);

             
            // WRITE Operatio
            if(vif.PWRITE) begin

                mem[vif.PADDR] = vif.PWDATA;

                num_writes++;

                `uvm_info(get_type_name(),
                $sformatf("WRITE : MEM[%08h] = %08h",
                          vif.PADDR,
                          vif.PWDATA),
                          UVM_HIGH)

            end

             
            // READ Operation

            else begin

                if(mem.exists(vif.PADDR))
                    vif.PRDATA <= mem[vif.PADDR];
                else
                    vif.PRDATA <= 32'h00000000;

                num_reads++;

                `uvm_info(get_type_name(),
                $sformatf("READ : MEM[%08h] -> %08h",
                          vif.PADDR,
                          mem.exists(vif.PADDR) ?
                          mem[vif.PADDR] : 32'h0),
                          UVM_HIGH)

            end

             
            // Complete Transfer
            vif.PREADY <= 1'b1;

            @(posedge vif.clk);

             
            // Return to Idle
            vif.PREADY <= 1'b0;
            vif.PRDATA <= '0;

            `uvm_info(get_type_name(),
                      "APB Transfer Completed",
                      UVM_MEDIUM);

        end

    endtask
     
    // Reset Task
    task reset_signals();

        vif.PREADY <= 0;
        vif.PRDATA <= 0;

    endtask


     
    // Report Phase
    function void report_phase(uvm_phase phase);

        super.report_phase(phase);

        `uvm_info(get_type_name(),
        $sformatf(
        "\n====================================\
         \n APB DRIVER REPORT\
         \n------------------------------------\
         \n WRITE Transactions : %0d\
         \n READ Transactions  : %0d\
         \n====================================",
         num_writes,
         num_reads),
         UVM_LOW);

    endfunction

endclass