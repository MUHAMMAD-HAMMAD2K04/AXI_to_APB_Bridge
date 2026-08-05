class bridge_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(bridge_scoreboard)
     
    // APB Side Analysis FIFOs
    uvm_tlm_analysis_fifo #(axi_to_apb_packet) expected_apb_fifo;
    uvm_tlm_analysis_fifo #(axi_to_apb_packet) actual_apb_fifo;


    // AXI Side Analysis FIFOs
    uvm_tlm_analysis_fifo #(axi_transaction) expected_axi_fifo;
    uvm_tlm_analysis_fifo #(axi_transaction) actual_axi_fifo;

    // Transactions captured directly at each driver.  These allow one
    // deterministic, ordered log block per completed bridge transfer.
    uvm_tlm_analysis_fifo #(axi_transaction) axi_driver_fifo;
    uvm_tlm_analysis_fifo #(axi_to_apb_packet) apb_driver_fifo;
     
    // Statistics
    int total_apb;
    int pass_apb;
    int fail_apb;

    int total_axi;
    int pass_axi;
    int fail_axi;;
    int transaction_count;
     
    // Constructor
    function new(string name="bridge_scoreboard",
                 uvm_component parent);
        super.new(name,parent);
    endfunction

    // Build Phase
    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

    expected_apb_fifo = new("expected_apb_fifo", this);
    actual_apb_fifo   = new("actual_apb_fifo", this);

    expected_axi_fifo = new("expected_axi_fifo", this);
    actual_axi_fifo   = new("actual_axi_fifo", this);
    axi_driver_fifo   = new("axi_driver_fifo", this);
    apb_driver_fifo   = new("apb_driver_fifo", this);

    endfunction

    // Run Phase
    task run_phase(uvm_phase phase);

        compare_ordered_transactions();

    endtask

    task compare_ordered_transactions();
        axi_transaction   drv_axi;
        axi_transaction   act_axi;
        axi_transaction   exp_axi;
        axi_to_apb_packet drv_apb;
        axi_to_apb_packet act_apb;
        axi_to_apb_packet exp_apb;

        forever begin
            axi_driver_fifo.get(drv_axi);
            actual_axi_fifo.get(act_axi);
            apb_driver_fifo.get(drv_apb);
            actual_apb_fifo.get(act_apb);
            expected_apb_fifo.get(exp_apb);
            expected_axi_fifo.get(exp_axi);

            transaction_count++;

            `uvm_info("ORDERED_TRANSACTION",
                $sformatf(
                "\n============================================================\
                 \n TRANSACTION %0d\
                 \n------------------------------------------------------------\
                 \n [1] AXI DRIVER\n%s\
                 \n [2] AXI MONITOR\n%s\
                 \n [3] APB DRIVER\n%s\
                 \n [4] APB MONITOR\n%s\
                 \n============================================================",
                 transaction_count,
                 drv_axi.sprint(), act_axi.sprint(),
                 drv_apb.sprint(), act_apb.sprint()),
                 UVM_MEDIUM)

            total_apb++;
            if (compare_apb_packet(exp_apb, act_apb))
                pass_apb++;
            else
                fail_apb++;

            total_axi++;
            if (compare_axi_packet(exp_axi, act_axi))
                pass_axi++;
            else
                fail_axi++;
        end
    endtask

         
    // AXI->APB Comparison
    task compare_apb();

        axi_to_apb_packet exp_pkt;
        axi_to_apb_packet act_pkt;

        forever begin

            expected_apb_fifo.get(exp_pkt);
            actual_apb_fifo.get(act_pkt);

            total_apb++;

            if(compare_apb_packet(exp_pkt,act_pkt))
                pass_apb++;
            else
                fail_apb++;

        end

    endtask

     
    // APB->AXI Comparison
    task compare_axi();
        axi_transaction exp_tr;
        axi_transaction act_tr;

        forever begin

            expected_axi_fifo.get(exp_tr);
            actual_axi_fifo.get(act_tr);

            total_axi++;

            if(compare_axi_packet(exp_tr,act_tr))
                pass_axi++;
            else
                fail_axi++;

        end

    endtask

     
    // Compare APB Packets
    function bit compare_apb_packet(
        axi_to_apb_packet exp_pkt,
        axi_to_apb_packet act_pkt
    );

        bit match = 1;

        if(exp_pkt.write != act_pkt.write) begin
            match = 0;
            `uvm_error(get_type_name(),
            $sformatf("WRITE mismatch Exp=%0d Act=%0d",
            exp_pkt.write,
            act_pkt.write))
        end

        if(exp_pkt.addr != act_pkt.addr) begin
            match = 0;
            `uvm_error(get_type_name(),
            $sformatf("ADDR mismatch Exp=%08h Act=%08h",
            exp_pkt.addr,
            act_pkt.addr))
        end

        if(exp_pkt.write) begin

            if(exp_pkt.wdata != act_pkt.wdata) begin
                match=0;
                `uvm_error(get_type_name(),
                $sformatf("WDATA mismatch Exp=%08h Act=%08h",
                exp_pkt.wdata,
                act_pkt.wdata))
            end

            if(exp_pkt.strb != act_pkt.strb) begin
                match=0;
                `uvm_error(get_type_name(),
                $sformatf("STRB mismatch Exp=%0h Act=%0h",
                exp_pkt.strb,
                act_pkt.strb))
            end

        end
        else begin

            if(exp_pkt.rdata != act_pkt.rdata) begin
                match=0;
                `uvm_error(get_type_name(),
                $sformatf("RDATA mismatch Exp=%08h Act=%08h",
                exp_pkt.rdata,
                act_pkt.rdata))
            end

        end

        if(exp_pkt.ready != act_pkt.ready) begin
            match=0;
            `uvm_error(get_type_name(),
            $sformatf("READY mismatch Exp=%0d Act=%0d",
            exp_pkt.ready,
            act_pkt.ready))
        end

        if(match)
            `uvm_info(get_type_name(),
            $sformatf("APB Compare PASS Addr=%08h",exp_pkt.addr),
            UVM_DEBUG)
        else
            `uvm_error(get_type_name(),"APB Compare FAILED")

        return match;

    endfunction

     
    // Compare AXI Packets
    function bit compare_axi_packet(
        axi_transaction exp_tr,
        axi_transaction act_tr
    );

        bit match=1;

        if(exp_tr.write != act_tr.write) begin
            match=0;
            `uvm_error(get_type_name(),"AXI WRITE mismatch")
        end

        if(exp_tr.addr != act_tr.addr) begin
            match=0;
            `uvm_error(get_type_name(),
            $sformatf("AXI ADDR mismatch Exp=%08h Act=%08h",
            exp_tr.addr,
            act_tr.addr))
        end

        if(exp_tr.write) begin

            if(exp_tr.data != act_tr.data) begin
                match=0;
                `uvm_error(get_type_name(),
                $sformatf("AXI DATA mismatch Exp=%08h Act=%08h",
                exp_tr.data,
                act_tr.data))
            end

            if(exp_tr.strb != act_tr.strb) begin
                match=0;
                `uvm_error(get_type_name(),
                $sformatf("AXI STRB mismatch Exp=%0h Act=%0h",
                exp_tr.strb,
                act_tr.strb))
            end

        end
        else begin

            if(exp_tr.data != act_tr.data) begin
                match=0;
                `uvm_error(get_type_name(),
                $sformatf("AXI READ DATA mismatch Exp=%08h Act=%08h",
                exp_tr.data,
                act_tr.data))
            end

        end

        if(match)
            `uvm_info(get_type_name(),
            $sformatf("AXI Compare PASS Addr=%08h",exp_tr.addr),
            UVM_DEBUG)
        else
            `uvm_error(get_type_name(),"AXI Compare FAILED")

        return match;

    endfunction

     
    // Report
    function void report_phase(uvm_phase phase);

        super.report_phase(phase);

        `uvm_info(get_type_name(),
        $sformatf(
        "\n==================================================\
         \n             BRIDGE SCOREBOARD REPORT\
         \n--------------------------------------------------\
         \n AXI->APB Compared : %0d\
         \n AXI->APB PASS     : %0d\
         \n AXI->APB FAIL     : %0d\
         \n--------------------------------------------------\
         \n APB->AXI Compared : %0d\
         \n APB->AXI PASS     : %0d\
         \n APB->AXI FAIL     : %0d\
         \n==================================================",
         total_apb,
         pass_apb,
         fail_apb,
         total_axi,
         pass_axi,
         fail_axi),
         UVM_NONE);

    endfunction

endclass
