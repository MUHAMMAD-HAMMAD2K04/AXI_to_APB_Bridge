class bridge_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(bridge_scoreboard)
     
    // Analysis FIFOs
    uvm_tlm_analysis_fifo #(axi_to_apb_packet) expected_fifo;
    uvm_tlm_analysis_fifo #(axi_to_apb_packet) actual_fifo;

     
    // Statistics
    int total_compares;
    int pass_count;
    int fail_count;
     
    // Constructor
    function new(string name="bridge_scoreboard",
                 uvm_component parent);
        super.new(name,parent);
    endfunction

    // Build Phase
    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        expected_fifo = new("expected_fifo", this);
        actual_fifo   = new("actual_fifo", this);

    endfunction

    // Run Phase
    task run_phase(uvm_phase phase);

        axi_to_apb_packet exp_pkt;
        axi_to_apb_packet act_pkt;

        forever begin

            // Wait for one packet from Reference Model
            expected_fifo.get(exp_pkt);
             
            // Wait for one packet from APB Monitor
            actual_fifo.get(act_pkt);

            total_compares++;

            compare_packets(exp_pkt, act_pkt);

        end

    endtask

     
    // Compare Task
    task compare_packets(
        axi_to_apb_packet exp_pkt,
        axi_to_apb_packet act_pkt
    );

        bit match = 1;
         
        // Compare WRITE / READ
        if(exp_pkt.write != act_pkt.write) begin

            match = 0;

            `uvm_error(get_type_name(),
                $sformatf("WRITE mismatch Expected=%0d Actual=%0d",
                exp_pkt.write,
                act_pkt.write))

        end
         
        // Compare Address
        if(exp_pkt.addr != act_pkt.addr) begin

            match = 0;

            `uvm_error(get_type_name(),
                $sformatf("ADDR mismatch Expected=%08h Actual=%08h",
                exp_pkt.addr,
                act_pkt.addr))

        end

        // Compare Write Data
        if(exp_pkt.write) begin

            if(exp_pkt.wdata != act_pkt.wdata) begin

                match = 0;

                `uvm_error(get_type_name(),
                    $sformatf("WDATA mismatch Expected=%08h Actual=%08h",
                    exp_pkt.wdata,
                    act_pkt.wdata))

            end

            if(exp_pkt.strb != act_pkt.strb) begin

                match = 0;

                `uvm_error(get_type_name(),
                    $sformatf("STRB mismatch Expected=%0h Actual=%0h",
                    exp_pkt.strb,
                    act_pkt.strb))

            end

        end

        // Compare Read Data
        else begin

            if(exp_pkt.rdata != act_pkt.rdata) begin

                match = 0;

                `uvm_error(get_type_name(),
                    $sformatf("RDATA mismatch Expected=%08h Actual=%08h",
                    exp_pkt.rdata,
                    act_pkt.rdata))

            end

        end

        // Compare Ready
        if(exp_pkt.ready != act_pkt.ready) begin

            match = 0;

            `uvm_error(get_type_name(),
                $sformatf("PREADY mismatch Expected=%0d Actual=%0d",
                exp_pkt.ready,
                act_pkt.ready))

        end

        // PASS / FAIL
        if(match) begin

            pass_count++;

            `uvm_info(get_type_name(),
            $sformatf(
            "\n============================================\
             \n SCOREBOARD PASS\
             \n TYPE  : %s\
             \n ADDR  : %08h\
             \n DATA  : %08h\
             \n============================================",
             exp_pkt.write ? "WRITE":"READ",
             exp_pkt.addr,
             exp_pkt.write ?
                exp_pkt.wdata :
                exp_pkt.rdata),
             UVM_LOW);

        end
        else begin

            fail_count++;

            `uvm_error(get_type_name(),
            "\n============================================\
             \n SCOREBOARD FAILED\
             \n============================================")

        end

    endtask

     
    // Report
    function void report_phase(uvm_phase phase);

        super.report_phase(phase);

        `uvm_info(get_type_name(),
        $sformatf(
        "\n================================================\
         \n SCOREBOARD REPORT\
         \n------------------------------------------------\
         \n Total Compared : %0d\
         \n Passed         : %0d\
         \n Failed         : %0d\
         \n================================================",
         total_compares,
         pass_count,
         fail_count),
         UVM_NONE);

    endfunction

endclass