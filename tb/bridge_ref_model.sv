class bridge_ref_model extends uvm_component;
    
    `uvm_component_utils(bridge_ref_model)

    //Imp through decl bcz of multiple ports
    `uvm_analysis_imp_decl(_axi)
    `uvm_analysis_imp_decl(_apb)

    // Receive AXI transactions
    uvm_analysis_imp_axi #(axi_transaction, bridge_ref_model) axi_imp;

    // Receive APB transactions
    uvm_analysis_imp_apb #(axi_to_apb_packet, bridge_ref_model) apb_imp;

    // Send expected APB transactions
    uvm_analysis_port #(axi_to_apb_packet) expected_apb_port;

    // Send expected AXI transaction
    uvm_analysis_port #(axi_transaction) expected_axi_port;

    // Reference Memory Model
    bit [31:0] mem [bit [31:0]];

    function new(string name = "bridge_ref_model", uvm_component  parent);
        super .new(name,parent);
    // Ports Creation
        axi_imp = new("axi_imp", this);
        apb_imp = new("apb_imp", this);
        expected_apb_port = new("expected_apb_port", this);
        expected_axi_port = new("expected_axi_port", this);
    endfunction //new()


    //AXI -> APB Prediction
     function void write_axi(axi_transaction axi_tr);

        axi_to_apb_packet apb_exp;

        apb_exp = axi_to_apb_packet::type_id::create("apb_exp");

        apb_exp.addr  = axi_tr.addr;
        apb_exp.write = axi_tr.write;
        apb_exp.strb  = axi_tr.strb;
    
        // WRITE
        if(axi_tr.write) begin

            mem[axi_tr.addr] = axi_tr.data;
            apb_exp.wdata = axi_tr.data;

        end

        // READ
        else begin
            if(mem.exists(axi_tr.addr))
                apb_exp.rdata = mem[axi_tr.addr];
            else
                apb_exp.rdata = 32'h0;
        end

        apb_exp.ready = 1;

        expected_apb_port.write(apb_exp);

        `uvm_info(get_type_name(),
        $sformatf("AXI->APB Prediction ADDR=%08h",
                  axi_tr.addr),
                  UVM_DEBUG)
    endfunction

    // APB -> AXI Prediction
    function void write_apb(axi_to_apb_packet apb_tr);

        axi_transaction axi_exp;

        axi_exp = axi_transaction::type_id::create("axi_exp");

        axi_exp.addr  = apb_tr.addr;
        axi_exp.write = apb_tr.write;
         
        // WRITE
        if(apb_tr.write) begin

            mem[apb_tr.addr] = apb_tr.wdata;
            axi_exp.data = apb_tr.wdata;
            axi_exp.strb = apb_tr.strb;

        end
         
        // READ
        else begin

            if(mem.exists(apb_tr.addr))
                axi_exp.data = mem[apb_tr.addr];
            else
                axi_exp.data = 32'h0;
                axi_exp.strb = 4'h0;
        end

        expected_axi_port.write(axi_exp);

        `uvm_info(get_type_name(),
        $sformatf("APB->AXI Prediction ADDR=%08h",
                  apb_tr.addr),
                  UVM_DEBUG)

    endfunction

endclass //bridge_ref_model extends uvm_component
