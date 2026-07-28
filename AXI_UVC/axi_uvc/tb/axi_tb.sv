
class axi_tb extends uvm_env;

    //env axi_UVC
    axi_env env;

    `uvm_component_utils(axi_tb)

    function new(string name = "axi_tb" , uvm_component parent);
        super.new(name,parent);
    endfunction //new()

   function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    env = axi_env::type_id::create("env", this);

    `uvm_info ("AXI_TB",": BUILT PHASE EXECUTED", UVM_HIGH);
   endfunction

    function void start_of_simulation_phase(uvm_phase phase);
        `uvm_info(get_type_name(),"Running Simulation ...",UVM_HIGH);
    endfunction

endclass // axi_tb extends uvm_env