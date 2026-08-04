class apb_driver extends uvm_driver #(axi_to_apb_packet);

    `uvm_component_utils(apb_driver)

    virtual apb_if.driver_mp vif;

    // Simple APB Slave Memory
    bit [31:0] mem [bit [31:0]];

    // Statistics
    int num_reads;
    int num_writes;

     
    // Wait-State Configuration
    int cfg_wait_cycles;
    bit random_wait = 1;

    rand int unsigned rand_wait_cycles;

    constraint c_wait {
        rand_wait_cycles inside {[0:5]};
    }

    // Error Injection
    bit enable_pslverr = 0;

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
            `uvm_fatal("NOVIF","APB interface not found")

        if(uvm_config_db#(int)::get(
                this,"","wait_cycles",cfg_wait_cycles))
            random_wait = 0;
        else
            random_wait = 1;

        void'(uvm_config_db#(bit)::get(
                this,"","enable_pslverr",enable_pslverr));

    endfunction


    // Run Phase
    task run_phase(uvm_phase phase);

        bit        write;
        bit [31:0] addr;
        bit [31:0] wdata;
        bit [3:0]  strb;

        reset_signals();

        wait(vif.rst);

        forever begin
             
            // Wait for Setup Phase
            @(posedge vif.clk);

            if(!vif.PTRANSFER)
                continue;

             
            // LATCH EVERYTHING HERE
            write = vif.PWRITE;
            addr  = vif.PADDR;
            wdata = vif.PWDATA;
            strb  = vif.PSTRB;

            `uvm_info(get_type_name(),
            $sformatf(
            "\n-------------------------------------\
             \n APB TRANSFER START\
             \n TYPE  : %s\
             \n ADDR  : %08h\
             \n WDATA : %08h\
             \n STRB  : %0h\
             \n-------------------------------------",
             write ? "WRITE":"READ",
             addr,
             wdata,
             strb),
             UVM_MEDIUM)

             
            // ACCESS PHASE
            @(posedge vif.clk);

            vif.PREADY  <= 0;
            // vif.PSLVERR <= 0;

             
            // Wait States
             
            if(random_wait)
                assert(randomize(rand_wait_cycles));
            else
                rand_wait_cycles = cfg_wait_cycles;

            repeat(rand_wait_cycles)
                @(posedge vif.clk);

             
            // WRITE
            if(write) begin

                case(strb)

                    4'b1111:
                        mem[addr] = wdata;

                    4'b0011:
                        mem[addr][15:0] = wdata[15:0];

                    4'b1100:
                        mem[addr][31:16] = wdata[31:16];

                    4'b0001:
                        mem[addr][7:0] = wdata[7:0];

                    default:
                        mem[addr] = wdata;

                endcase

                num_writes++;

                `uvm_info(get_type_name(),
                $sformatf(
                "WRITE : MEM[%08h] = %08h",
                addr,
                mem[addr]),
                UVM_HIGH)

            end

             
            // READ
             
            else begin

                if(mem.exists(addr))
                    vif.PRDATA <= mem[addr];
                else
                    vif.PRDATA <= 32'h0;

                num_reads++;

                `uvm_info(get_type_name(),
                $sformatf(
                "READ : MEM[%08h] -> %08h",
                addr,
                mem.exists(addr) ? mem[addr] : 32'h0),
                UVM_HIGH)

            end

             
            // Finish Transfer
            vif.PREADY <= 1;

            @(posedge vif.clk);

            vif.PREADY  <= 0;
            vif.PRDATA  <= '0;

            `uvm_info(get_type_name(),
                "APB Transfer Completed",
                UVM_MEDIUM)

        end

    endtask


     
    // Reset
    task reset_signals();

        vif.PREADY  <= 0;
        vif.PRDATA  <= 0;

    endtask


     
    // Report
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
         UVM_LOW)

    endfunction

endclass