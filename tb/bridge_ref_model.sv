class bridge_ref_model extends uvm_component;
    
    `uvm_component_utils(bridge_ref_model)

    // Receive AXI transactions
    uvm_analysis_imp #(axi_transaction, bridge_ref_model) axi_imp;

    // Send expected APB transactions
    uvm_analysis_port #(axi_to_apb_packet) expected_apb_port;

    // Reference Memory Model
    bit [31:0] mem [bit [31:0]];

    function new(string name = "bridge_ref_model", uvm_component  parent);
        super .new(name,parent);
    // Ports Creation
        axi_imp = new("axi_imp", this);
        expected_apb_port = new("expected_apb_port", this);
    endfunction //new()

         
    // Receive AXI Transaction
    virtual function void write(axi_transaction axi_tr);

        axi_to_apb_packet apb_exp;

        apb_exp = axi_to_apb_packet::type_id::create("apb_exp");

        // Common Fields
        apb_exp.addr  = axi_tr.addr;
        apb_exp.write = axi_tr.write;
         
        // WRITE Transaction
        if(axi_tr.write) begin

            apb_exp.wdata = axi_tr.data;
            apb_exp.strb  = axi_tr.strb;

            // Update reference memory
            mem[axi_tr.addr] = axi_tr.data;

            // `uvm_info(get_type_name(),
            //     $sformatf(
            //     "\nREFERENCE MODEL (WRITE)"
            //     "\nADDR  = %08h"
            //     "\nWDATA = %08h"
            //     "\nSTRB  = %0h",
            //     apb_exp.addr,
            //     apb_exp.wdata,
            //     apb_exp.strb),
            //     UVM_MEDIUM)

            `uvm_info(get_type_name(),
                $sformatf("\nREFERENCE MODEL (WRITE)\nADDR=%08h\nWDATA=%08h\nSTRB=%0h",
                        apb_exp.addr,
                        apb_exp.wdata,
                        apb_exp.strb),
                UVM_MEDIUM)

        end

        // READ Transaction
        else begin

            apb_exp.wdata = '0;
            apb_exp.strb  = '0;

            // Predict expected read data
            if(mem.exists(axi_tr.addr))
                apb_exp.rdata = mem[axi_tr.addr];
            else
                apb_exp.rdata = '0;

            // `uvm_info(get_type_name(),
            //     $sformatf(
            //     "\nREFERENCE MODEL (READ)"
            //     "\nADDR  = %08h"
            //     "\nExpected RDATA = %08h",
            //     apb_exp.addr,
            //     apb_exp.rdata),
            //     UVM_MEDIUM)

            `uvm_info(get_type_name(),
                $sformatf("\nREFERENCE MODEL (READ)\nADDR=%08h\nExpected RDATA=%08h",
                        apb_exp.addr,
                        apb_exp.rdata),
                UVM_MEDIUM)

        end
         
        // APB Transfer Expected Complete
        apb_exp.ready = 1'b1;
         
        // Send Expected Packet
        expected_apb_port.write(apb_exp);

    endfunction

endclass //bridge_ref_model extends uvm_component;
